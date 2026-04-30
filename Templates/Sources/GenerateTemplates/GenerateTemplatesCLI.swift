import Foundation
import TemplateModel

@main
struct GenerateTemplatesCLI {
    static func main() async {
        let args = Array(CommandLine.arguments.dropFirst())
        var ids: [String] = []
        var all = false
        var dryRun = false
        var model = "claude-sonnet-4-6"
        var outDir = "References/raw"
        var envPath: String? = nil

        var i = 0
        while i < args.count {
            let a = args[i]
            switch a {
            case "--ids":
                i += 1
                guard i < args.count else { die("--ids expects a comma-separated list") }
                ids = args[i].split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }
            case "--all":
                all = true
            case "--dry-run":
                dryRun = true
            case "--model":
                i += 1
                guard i < args.count else { die("--model expects a model name") }
                model = args[i]
            case "--out":
                i += 1
                guard i < args.count else { die("--out expects a path") }
                outDir = args[i]
            case "--env":
                i += 1
                guard i < args.count else { die("--env expects a .env path") }
                envPath = args[i]
            case "-h", "--help":
                printUsage(); exit(0)
            default:
                die("Unknown arg: \(a)")
            }
            i += 1
        }

        let specs: [TemplateSpec] = {
            if all { return TemplateMatrix.all }
            if ids.isEmpty { die("Provide --ids <a,b,c> or --all") }
            return ids.map { id in
                guard let s = TemplateMatrix.find(id: id) else {
                    die("Unknown template id: \(id). Check TemplateMatrix.swift.")
                }
                return s
            }
        }()

        print("Templates ciblés : \(specs.count)")
        specs.forEach { print("  - \($0.id)") }
        print("Modèle           : \(model)")
        print("Sortie           : \(outDir)")
        print("Dry run          : \(dryRun)")

        // Load schema + reference template
        let cwd = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        let schemaURL = cwd.appendingPathComponent("schema/template.schema.json")
        let refURL = cwd.appendingPathComponent("References/running-beginner-5k-8sem.json")

        guard let schemaData = try? Data(contentsOf: schemaURL),
              let schemaString = String(data: schemaData, encoding: .utf8) else {
            die("Cannot read schema at \(schemaURL.path). Lance la commande depuis le dossier Templates/.")
        }
        guard let refData = try? Data(contentsOf: refURL),
              let refString = String(data: refData, encoding: .utf8) else {
            die("Cannot read reference template at \(refURL.path).")
        }

        if dryRun {
            let firstSpec = specs[0]
            let user = TemplatePrompts.userMessage(for: firstSpec,
                                                   schemaJSON: schemaString,
                                                   referenceTemplateJSON: refString)
            print("\n========== SYSTEM PROMPT ==========\n")
            print(TemplatePrompts.system)
            print("\n========== USER MESSAGE (first template only) ==========\n")
            print(user)
            print("\n========== END DRY RUN ==========")
            print("Pour lancer réellement : retirer --dry-run")
            exit(0)
        }

        // API key
        guard let apiKey = ApiKeyResolver.resolve(explicitEnvPath: envPath) else {
            die("""
            ANTHROPIC_API_KEY introuvable.
            Cherché dans (dans l'ordre) : --env path, ./.env, ../Spike/Leon/.env, process env.
            """)
        }

        // Prepare output dir
        let outDirURL = cwd.appendingPathComponent(outDir)
        try? FileManager.default.createDirectory(at: outDirURL, withIntermediateDirectories: true)

        let client = AnthropicClient(apiKey: apiKey, model: model, maxTokens: 64000, maxRetries: 3)
        var logRows: [String] = ["id,model,input_tokens,output_tokens,elapsed_s,cost_usd,json_ok,validator_ok,error"]

        var totalCost = 0.0
        for (idx, spec) in specs.enumerated() {
            print("\n[\(idx+1)/\(specs.count)] \(spec.id) …")
            let user = TemplatePrompts.userMessage(for: spec,
                                                   schemaJSON: schemaString,
                                                   referenceTemplateJSON: refString)
            do {
                let result = try await client.call(system: TemplatePrompts.system, userMessage: user)
                totalCost += result.estimatedCostUSD

                let rawText = result.text
                let cleaned = stripMarkdownFence(rawText)

                // Write raw (pre-cleanup) for forensics
                let rawURL = outDirURL.appendingPathComponent("\(spec.id).raw.txt")
                try? rawText.write(to: rawURL, atomically: true, encoding: .utf8)

                // Parse + validate
                var jsonOk = false
                var validatorOk = false
                var errMsg = ""
                if let data = cleaned.data(using: .utf8) {
                    do {
                        let decoded = try TemplateCoding.decode(data)
                        jsonOk = true
                        do {
                            try TemplateValidator.validate(decoded)
                            validatorOk = true
                        } catch let e {
                            errMsg = "validator: \(e)"
                        }
                        // Write pretty-printed JSON
                        let reEncoded = try TemplateCoding.encode(decoded)
                        let outURL = outDirURL.appendingPathComponent("\(spec.id).json")
                        try reEncoded.write(to: outURL)
                        print("  → écrit \(outURL.lastPathComponent) (\(decoded.weeks.count) semaines)")
                    } catch let e {
                        errMsg = "decode: \(e)"
                        // Still write the raw cleaned version for inspection
                        let outURL = outDirURL.appendingPathComponent("\(spec.id).json")
                        try? cleaned.write(to: outURL, atomically: true, encoding: .utf8)
                        print("  → JSON invalide, cleaned version écrit en \(outURL.lastPathComponent)")
                    }
                } else {
                    errMsg = "cannot encode response as UTF-8"
                }

                let stamp = String(format: "%.2f", result.elapsedSeconds)
                let cost = String(format: "%.4f", result.estimatedCostUSD)
                let retryTag = result.retriesUsed > 0 ? " (retries=\(result.retriesUsed))" : ""
                print("  in=\(result.inputTokens) out=\(result.outputTokens) \(stamp)s cost=$\(cost)\(retryTag) json=\(jsonOk ? "OK" : "KO") validator=\(validatorOk ? "OK" : "KO") \(errMsg.isEmpty ? "" : "(\(errMsg))")")

                logRows.append([
                    spec.id, result.model,
                    "\(result.inputTokens)", "\(result.outputTokens)",
                    stamp, cost,
                    jsonOk ? "OK" : "KO",
                    validatorOk ? "OK" : "KO",
                    csvEscape(errMsg)
                ].joined(separator: ","))
            } catch {
                print("  ERREUR : \(error)")
                logRows.append([spec.id, model, "0", "0", "0", "0", "KO", "KO", csvEscape("\(error)")].joined(separator: ","))
            }
        }

        // Write CSV log
        let logURL = outDirURL.appendingPathComponent("_log.csv")
        try? logRows.joined(separator: "\n").write(to: logURL, atomically: true, encoding: .utf8)
        print("\n========================================")
        print(String(format: "Coût total : $%.4f", totalCost))
        print("Log        : \(logURL.path)")
        print("========================================")
    }

    /// Removes markdown fences ```json … ``` and trailing text if present.
    /// Keeps everything between the first `{` and the last `}`.
    static func stripMarkdownFence(_ s: String) -> String {
        guard let firstBrace = s.firstIndex(of: "{"),
              let lastBrace = s.lastIndex(of: "}") else { return s }
        return String(s[firstBrace...lastBrace])
    }

    static func csvEscape(_ s: String) -> String {
        guard s.contains(",") || s.contains("\"") || s.contains("\n") else { return s }
        return "\"" + s.replacingOccurrences(of: "\"", with: "\"\"") + "\""
    }

    static func printUsage() {
        print("""
        Usage: swift run GenerateTemplates [options]

        Options:
          --ids <a,b,c>    Generate only the listed template ids
          --all            Generate all 38 templates in the matrix
          --dry-run        Print the system + user prompt for the first template, don't call the API
          --model <name>   Model to use (default: claude-sonnet-4-6)
          --out <dir>      Output directory (default: References/raw relative to cwd)
          --env <path>     Explicit .env file path
          -h, --help       Show this help

        Exemple :
          swift run GenerateTemplates --dry-run --ids running-recreational-10k-8sem
          swift run GenerateTemplates --ids running-recreational-10k-8sem,strength-training-beginner-home-basics-8sem
        """)
    }

    static func die(_ msg: String) -> Never {
        FileHandle.standardError.write(Data("ERROR: \(msg)\n".utf8))
        exit(2)
    }
}
