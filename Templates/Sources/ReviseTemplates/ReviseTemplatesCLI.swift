import Foundation
import TemplateModel

@main
struct ReviseTemplatesCLI {
    static func main() async {
        let args = Array(CommandLine.arguments.dropFirst())
        var ids: [String] = []
        var templatesDir = "References/raw"
        var challengesDir = "References/challenges"
        var outDir = "References/revised"
        var model = "claude-sonnet-4-6"
        var dryRun = false
        var envPath: String? = nil

        var i = 0
        while i < args.count {
            let a = args[i]
            switch a {
            case "--ids":
                i += 1; guard i < args.count else { die("--ids expects a comma-separated list") }
                ids = args[i].split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }
            case "--templates-dir":
                i += 1; guard i < args.count else { die("--templates-dir expects a path") }
                templatesDir = args[i]
            case "--challenges-dir":
                i += 1; guard i < args.count else { die("--challenges-dir expects a path") }
                challengesDir = args[i]
            case "--out":
                i += 1; guard i < args.count else { die("--out expects a path") }
                outDir = args[i]
            case "--model":
                i += 1; guard i < args.count else { die("--model expects a model name") }
                model = args[i]
            case "--dry-run":
                dryRun = true
            case "--env":
                i += 1; guard i < args.count else { die("--env expects a .env path") }
                envPath = args[i]
            case "-h", "--help":
                printUsage(); exit(0)
            default:
                die("Unknown arg: \(a)")
            }
            i += 1
        }

        guard !ids.isEmpty else { die("Provide --ids <a,b,c>") }

        let cwd = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        let templatesDirURL = cwd.appendingPathComponent(templatesDir)
        let challengesDirURL = cwd.appendingPathComponent(challengesDir)
        let outDirURL = cwd.appendingPathComponent(outDir)
        try? FileManager.default.createDirectory(at: outDirURL, withIntermediateDirectories: true)

        print("Templates à réviser : \(ids.count)")
        ids.forEach { print("  - \($0)") }
        print("Modèle    : \(model)")
        print("Sortie    : \(outDirURL.path)")
        print("Dry run   : \(dryRun)")

        guard let apiKey = ApiKeyResolver.resolve(explicitEnvPath: envPath) else {
            die("ANTHROPIC_API_KEY introuvable")
        }

        let client = AnthropicClient(apiKey: apiKey, model: model, maxTokens: 64000, maxRetries: 3)
        var totalCost = 0.0

        for (idx, id) in ids.enumerated() {
            print("\n[\(idx+1)/\(ids.count)] \(id) …")

            // Resolve template path (try raw/ then root References/)
            var templateURL = templatesDirURL.appendingPathComponent("\(id).json")
            if !FileManager.default.fileExists(atPath: templateURL.path) {
                templateURL = cwd.appendingPathComponent("References/\(id).json")
            }
            let challengeURL = challengesDirURL.appendingPathComponent("challenge_\(id).md")

            guard let templateData = try? Data(contentsOf: templateURL),
                  let templateString = String(data: templateData, encoding: .utf8) else {
                print("  SKIP: cannot read template at \(templateURL.path)")
                continue
            }
            guard let challengeData = try? Data(contentsOf: challengeURL),
                  let challengeString = String(data: challengeData, encoding: .utf8) else {
                print("  SKIP: cannot read challenge at \(challengeURL.path)")
                continue
            }

            let user = RevisePrompts.userMessage(templateJSON: templateString, challengeReport: challengeString)

            if dryRun {
                print("  [DRY RUN] system+user constructed, not calling API")
                continue
            }

            do {
                let result = try await client.call(system: RevisePrompts.system, userMessage: user)
                totalCost += result.estimatedCostUSD
                let stamp = String(format: "%.2f", result.elapsedSeconds)
                let cost = String(format: "%.4f", result.estimatedCostUSD)
                let retryTag = result.retriesUsed > 0 ? " (retries=\(result.retriesUsed))" : ""

                let rawText = result.text
                let cleaned = stripMarkdownFence(rawText)

                // Backup raw
                let rawURL = outDirURL.appendingPathComponent("\(id).raw.txt")
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
                        let reEncoded = try TemplateCoding.encode(decoded)
                        let outURL = outDirURL.appendingPathComponent("\(id).json")
                        try reEncoded.write(to: outURL)
                        print("  → écrit \(outURL.lastPathComponent) (\(decoded.weeks.count) semaines)")
                    } catch let e {
                        errMsg = "decode: \(e)"
                        let outURL = outDirURL.appendingPathComponent("\(id).json")
                        try? cleaned.write(to: outURL, atomically: true, encoding: .utf8)
                        print("  → JSON invalide, cleaned version écrit en \(outURL.lastPathComponent)")
                    }
                } else {
                    errMsg = "cannot encode response as UTF-8"
                }

                print("  in=\(result.inputTokens) out=\(result.outputTokens) \(stamp)s cost=$\(cost)\(retryTag) json=\(jsonOk ? "OK" : "KO") validator=\(validatorOk ? "OK" : "KO") \(errMsg.isEmpty ? "" : "(\(errMsg))")")
            } catch {
                print("  ERREUR : \(error)")
            }
        }

        print("\n========================================")
        print(String(format: "Coût total révision : $%.4f", totalCost))
        print("========================================")
    }

    static func stripMarkdownFence(_ s: String) -> String {
        guard let firstBrace = s.firstIndex(of: "{"),
              let lastBrace = s.lastIndex(of: "}") else { return s }
        return String(s[firstBrace...lastBrace])
    }

    static func printUsage() {
        print("""
        Usage: swift run ReviseTemplates --ids <a,b,c> [options]

        Options:
          --ids <a,b,c>           Template ids to revise (required)
          --templates-dir <path>  Where to find <id>.json (default: References/raw)
          --challenges-dir <path> Where to find challenge_<id>.md (default: References/challenges)
          --out <path>            Output dir (default: References/revised)
          --model <name>          Model (default: claude-sonnet-4-6)
          --dry-run               Validate inputs, don't call API
          --env <path>            Explicit .env path
        """)
    }

    static func die(_ msg: String) -> Never {
        FileHandle.standardError.write(Data("ERROR: \(msg)\n".utf8))
        exit(2)
    }
}
