import Foundation
import TemplateModel

@main
struct ChallengeTemplatesCLI {
    static func main() async {
        let args = Array(CommandLine.arguments.dropFirst())
        var inputDir = "References/raw"
        var outDir = "References/challenges"
        var specificFiles: [String] = []
        var model = "claude-haiku-4-5"
        var dryRun = false
        var envPath: String? = nil

        var i = 0
        while i < args.count {
            let a = args[i]
            switch a {
            case "--input-dir":
                i += 1; guard i < args.count else { die("--input-dir expects a path") }
                inputDir = args[i]
            case "--out":
                i += 1; guard i < args.count else { die("--out expects a path") }
                outDir = args[i]
            case "--files":
                i += 1; guard i < args.count else { die("--files expects a comma-separated list") }
                specificFiles = args[i].split(separator: ",").map { String($0) }
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

        let cwd = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        let inputDirURL = cwd.appendingPathComponent(inputDir)
        let outDirURL = cwd.appendingPathComponent(outDir)
        try? FileManager.default.createDirectory(at: outDirURL, withIntermediateDirectories: true)

        // Collect files
        let files: [URL]
        if !specificFiles.isEmpty {
            files = specificFiles.map { inputDirURL.appendingPathComponent($0) }
        } else {
            let listing = (try? FileManager.default.contentsOfDirectory(at: inputDirURL, includingPropertiesForKeys: nil)) ?? []
            files = listing
                .filter { $0.pathExtension == "json" && !$0.lastPathComponent.hasPrefix("_") }
                .sorted { $0.lastPathComponent < $1.lastPathComponent }
        }

        // Also check for the root reference template
        let rootRef = cwd.appendingPathComponent("References/running-beginner-5k-8sem.json")
        var allFiles = files
        if FileManager.default.fileExists(atPath: rootRef.path) && !specificFiles.isEmpty == false {
            // only add if no --files filter
            if !allFiles.contains(where: { $0.lastPathComponent == "running-beginner-5k-8sem.json" }) {
                allFiles.insert(rootRef, at: 0)
            }
        }

        print("Templates à challenger : \(allFiles.count)")
        for f in allFiles.prefix(5) { print("  - \(f.lastPathComponent)") }
        if allFiles.count > 5 { print("  - ... (+\(allFiles.count - 5))") }
        print("Modèle    : \(model)")
        print("Sortie    : \(outDirURL.path)")
        print("Dry run   : \(dryRun)")

        if dryRun {
            print("\n===== SYSTEM PROMPT =====\n")
            print(ChallengePrompts.system)
            print("\n===== USER MESSAGE (first file) =====\n")
            if let first = allFiles.first,
               let data = try? Data(contentsOf: first),
               let raw = String(data: data, encoding: .utf8) {
                let id = first.deletingPathExtension().lastPathComponent
                print(ChallengePrompts.userMessage(templateId: id, templateJSON: raw))
            }
            exit(0)
        }

        guard let apiKey = ApiKeyResolver.resolve(explicitEnvPath: envPath) else {
            die("ANTHROPIC_API_KEY introuvable")
        }

        let client = AnthropicClient(apiKey: apiKey, model: model, maxTokens: 8192, maxRetries: 3)
        var summaryRows: [(id: String, verdict: String, globalScore: String, criticalCount: Int)] = []
        var totalCost = 0.0

        for (idx, fileURL) in allFiles.enumerated() {
            let id = fileURL.deletingPathExtension().lastPathComponent
            print("\n[\(idx+1)/\(allFiles.count)] \(id) …")
            guard let data = try? Data(contentsOf: fileURL),
                  let raw = String(data: data, encoding: .utf8) else {
                print("  SKIP: cannot read \(fileURL.path)")
                continue
            }

            let user = ChallengePrompts.userMessage(templateId: id, templateJSON: raw)
            do {
                let result = try await client.call(system: ChallengePrompts.system, userMessage: user)
                totalCost += result.estimatedCostUSD
                let stamp = String(format: "%.2f", result.elapsedSeconds)
                let cost = String(format: "%.4f", result.estimatedCostUSD)
                let retryTag = result.retriesUsed > 0 ? " (retries=\(result.retriesUsed))" : ""
                print("  in=\(result.inputTokens) out=\(result.outputTokens) \(stamp)s cost=$\(cost)\(retryTag)")

                let outURL = outDirURL.appendingPathComponent("challenge_\(id).md")
                try result.text.write(to: outURL, atomically: true, encoding: .utf8)

                // Extract summary rows
                let (verdict, score, critCount) = extractSummary(from: result.text)
                summaryRows.append((id, verdict, score, critCount))
            } catch {
                print("  ERREUR : \(error)")
                summaryRows.append((id, "ERREUR API", "-/10", -1))
            }
        }

        // Write aggregate summary
        let summaryURL = outDirURL.appendingPathComponent("_challenge_summary.md")
        var summary = "# Challenge Summary — 38 templates\n\n"
        summary += "Généré le \(ISO8601DateFormatter().string(from: Date()))\n\n"
        summary += "| Template | Global | Issues critiques | Verdict |\n"
        summary += "|---|---|---|---|\n"
        for row in summaryRows.sorted(by: { $0.globalScore > $1.globalScore }) {
            let critMarker = row.criticalCount > 0 ? "⚠️ \(row.criticalCount)" : (row.criticalCount == 0 ? "✅ 0" : "❌ ERR")
            summary += "| \(row.id) | \(row.globalScore) | \(critMarker) | \(row.verdict.prefix(100))… |\n"
        }
        summary += "\n## Coût total\n\n$" + String(format: "%.4f", totalCost) + "\n"
        try? summary.write(to: summaryURL, atomically: true, encoding: .utf8)

        print("\n========================================")
        print(String(format: "Coût total : $%.4f", totalCost))
        print("Summary    : \(summaryURL.path)")
        print("========================================")
    }

    /// Extract the verdict, global score, and count of critical issues from a challenge report.
    static func extractSummary(from md: String) -> (verdict: String, score: String, critCount: Int) {
        let lines = md.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)

        // Verdict: first line after "## Verdict"
        var verdict = ""
        if let idx = lines.firstIndex(where: { $0.trimmingCharacters(in: .whitespaces).hasPrefix("## Verdict") }) {
            for j in (idx + 1)..<lines.count {
                let t = lines[j].trimmingCharacters(in: .whitespaces)
                if t.hasPrefix("##") { break }
                if !t.isEmpty { verdict += (verdict.isEmpty ? "" : " ") + t }
            }
        }

        // Score: look for "**Global : X/10**" or "Global : X/10"
        var score = "-/10"
        for line in lines {
            if line.contains("Global") && line.contains("/10") {
                // Extract pattern X/10
                if let range = line.range(of: #"\d+(?:\.\d+)?/10"#, options: .regularExpression) {
                    score = String(line[range])
                    break
                }
            }
        }

        // Count critical issues: lines starting with "- " between "## Issues critiques" and next ##
        var critCount = 0
        if let idx = lines.firstIndex(where: { $0.trimmingCharacters(in: .whitespaces).hasPrefix("## Issues critiques") }) {
            for j in (idx + 1)..<lines.count {
                let t = lines[j].trimmingCharacters(in: .whitespaces)
                if t.hasPrefix("##") { break }
                if t.hasPrefix("- ") && !t.lowercased().contains("aucune issue") {
                    critCount += 1
                }
            }
        }

        return (verdict, score, critCount)
    }

    static func printUsage() {
        print("""
        Usage: swift run ChallengeTemplates [options]

        Options:
          --input-dir <path>  Directory containing template JSONs (default: References/raw)
          --out <path>        Output directory for challenge reports (default: References/challenges)
          --files <a,b,c>     Only challenge these specific filenames (e.g. foo.json,bar.json)
          --model <name>      Model to use (default: claude-haiku-4-5)
          --dry-run           Print prompt for first file, don't call API
          --env <path>        Explicit .env path
          -h, --help          Show this help
        """)
    }

    static func die(_ msg: String) -> Never {
        FileHandle.standardError.write(Data("ERROR: \(msg)\n".utf8))
        exit(2)
    }
}
