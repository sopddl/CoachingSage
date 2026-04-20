import Foundation
import TemplateModel

@main
struct TestAdaptabilityCLI {
    static func main() async {
        let args = Array(CommandLine.arguments.dropFirst())
        var inputDir = "References/raw"
        var outDir = "References/adaptability"
        var specificFiles: [String] = []
        var profileIds: [String] = []
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
            case "--profiles":
                i += 1; guard i < args.count else { die("--profiles expects a comma-separated list of profile ids") }
                profileIds = args[i].split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }
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

        // Collect templates
        let files: [URL]
        if !specificFiles.isEmpty {
            files = specificFiles.map { name in
                let withExt = name.hasSuffix(".json") ? name : "\(name).json"
                return inputDirURL.appendingPathComponent(withExt)
            }
        } else {
            let listing = (try? FileManager.default.contentsOfDirectory(at: inputDirURL, includingPropertiesForKeys: nil)) ?? []
            files = listing
                .filter { $0.pathExtension == "json" && !$0.lastPathComponent.hasPrefix("_") }
                .sorted { $0.lastPathComponent < $1.lastPathComponent }
        }

        // Also include the root reference template if no --files filter
        let rootRef = cwd.appendingPathComponent("References/running-debutant-5k-8sem.json")
        var allFiles = files
        if specificFiles.isEmpty && FileManager.default.fileExists(atPath: rootRef.path) {
            if !allFiles.contains(where: { $0.lastPathComponent == "running-debutant-5k-8sem.json" }) {
                allFiles.insert(rootRef, at: 0)
            }
        }

        // Resolve profiles
        let profiles: [AdaptationProfile]
        if profileIds.isEmpty {
            profiles = AdaptationProfiles.all
        } else {
            profiles = profileIds.compactMap { id in
                guard let p = AdaptationProfiles.profile(id: id) else {
                    let known = AdaptationProfiles.all.map(\.id).joined(separator: ", ")
                    die("Unknown profile id: \(id). Known: \(known)")
                }
                return p
            }
        }

        let totalCalls = allFiles.count * profiles.count
        print("Templates     : \(allFiles.count)")
        for f in allFiles.prefix(3) { print("  - \(f.lastPathComponent)") }
        if allFiles.count > 3 { print("  - ... (+\(allFiles.count - 3))") }
        print("Profils       : \(profiles.count)")
        for p in profiles { print("  - \(p.id) — \(p.label)") }
        print("Total calls   : \(totalCalls)")
        print("Modèle        : \(model)")
        print("Sortie        : \(outDirURL.path)")
        print("Dry run       : \(dryRun)")

        if dryRun {
            print("\n===== SYSTEM PROMPT =====\n")
            print(AdaptPrompts.system)
            if let first = allFiles.first,
               let data = try? Data(contentsOf: first),
               let raw = String(data: data, encoding: .utf8),
               let firstProfile = profiles.first {
                let id = first.deletingPathExtension().lastPathComponent
                print("\n===== USER MESSAGE (template=\(id), profile=\(firstProfile.id)) =====\n")
                print(AdaptPrompts.userMessage(templateId: id, templateJSON: raw, profile: firstProfile))
            }
            exit(0)
        }

        guard let apiKey = ApiKeyResolver.resolve(explicitEnvPath: envPath) else {
            die("ANTHROPIC_API_KEY introuvable")
        }

        let client = AnthropicClient(apiKey: apiKey, model: model, maxTokens: 4096, maxRetries: 3)
        var rows: [AdaptabilityRow] = []
        var totalCost = 0.0
        var callIdx = 0

        for fileURL in allFiles {
            let id = fileURL.deletingPathExtension().lastPathComponent
            guard let data = try? Data(contentsOf: fileURL),
                  let raw = String(data: data, encoding: .utf8) else {
                print("  SKIP: cannot read \(fileURL.path)")
                continue
            }

            let templateOutDir = outDirURL.appendingPathComponent(id)
            try? FileManager.default.createDirectory(at: templateOutDir, withIntermediateDirectories: true)

            for profile in profiles {
                callIdx += 1
                print("\n[\(callIdx)/\(totalCalls)] \(id) × \(profile.id) …")
                let user = AdaptPrompts.userMessage(templateId: id, templateJSON: raw, profile: profile)
                do {
                    let result = try await client.call(system: AdaptPrompts.system, userMessage: user)
                    totalCost += result.estimatedCostUSD
                    let stamp = String(format: "%.2f", result.elapsedSeconds)
                    let cost = String(format: "%.4f", result.estimatedCostUSD)
                    let retryTag = result.retriesUsed > 0 ? " (retries=\(result.retriesUsed))" : ""
                    print("  in=\(result.inputTokens) out=\(result.outputTokens) \(stamp)s cost=$\(cost)\(retryTag)")

                    let outURL = templateOutDir.appendingPathComponent("\(profile.id).md")
                    try result.text.write(to: outURL, atomically: true, encoding: .utf8)

                    let (score, issuesCount, contradictionsCount) = extractMetrics(from: result.text)
                    rows.append(AdaptabilityRow(
                        templateId: id,
                        profileId: profile.id,
                        score: score,
                        rigidityIssues: issuesCount,
                        contradictions: contradictionsCount
                    ))
                } catch {
                    print("  ERREUR : \(error)")
                    rows.append(AdaptabilityRow(
                        templateId: id,
                        profileId: profile.id,
                        score: nil,
                        rigidityIssues: -1,
                        contradictions: -1
                    ))
                }
            }
        }

        writeAggregateReport(rows: rows, profiles: profiles, outDir: outDirURL, totalCost: totalCost)

        print("\n========================================")
        print(String(format: "Coût total : $%.4f", totalCost))
        print("Rapport    : \(outDirURL.appendingPathComponent("_adaptability_report.md").path)")
        print("========================================")
    }

    struct AdaptabilityRow {
        let templateId: String
        let profileId: String
        let score: Double?
        let rigidityIssues: Int
        let contradictions: Int
    }

    /// Parse the haiku markdown report. Tolerant : returns nils / -1 if sections missing.
    static func extractMetrics(from md: String) -> (score: Double?, issuesCount: Int, contradictionsCount: Int) {
        let lines = md.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)

        // Score : look for "**X/10**" or "X/10" in Rigidity score section
        var score: Double? = nil
        if let idx = lines.firstIndex(where: { $0.trimmingCharacters(in: .whitespaces).hasPrefix("## Rigidity score") }) {
            for j in (idx + 1)..<min(idx + 5, lines.count) {
                let t = lines[j]
                if let range = t.range(of: #"(\d+(?:\.\d+)?)\s*/\s*10"#, options: .regularExpression) {
                    let match = String(t[range])
                    let num = match.split(separator: "/").first.map(String.init)?.trimmingCharacters(in: .whitespaces) ?? ""
                    score = Double(num)
                    break
                }
            }
        }

        let issuesCount = countBullets(inSection: "## Rigidity issues", lines: lines)
        let contradictionsCount = countBullets(inSection: "## Contradictions", lines: lines)

        return (score, issuesCount, contradictionsCount)
    }

    /// Count bullet lines "- " between a section header and the next "## ". Returns 0 if the section says "Aucun*".
    static func countBullets(inSection header: String, lines: [String]) -> Int {
        guard let idx = lines.firstIndex(where: { $0.trimmingCharacters(in: .whitespaces).hasPrefix(header) }) else {
            return -1
        }
        var count = 0
        for j in (idx + 1)..<lines.count {
            let t = lines[j].trimmingCharacters(in: .whitespaces)
            if t.hasPrefix("##") { break }
            let low = t.lowercased()
            if low.hasPrefix("aucun") || low.hasPrefix("aucune") || low == "none" { return 0 }
            if t.hasPrefix("- ") { count += 1 }
        }
        return count
    }

    static func writeAggregateReport(rows: [AdaptabilityRow], profiles: [AdaptationProfile], outDir: URL, totalCost: Double) {
        var md = "# Adaptability Report — 38 templates × \(profiles.count) profils\n\n"
        md += "Généré le \(ISO8601DateFormatter().string(from: Date()))\n\n"

        // Group rows by template
        let byTemplate = Dictionary(grouping: rows, by: \.templateId)
        let templatesSorted = byTemplate.keys.sorted()

        md += "## Scores par template (moyenne sur \(profiles.count) profils)\n\n"
        md += "| Template |"
        for p in profiles { md += " \(p.id) |" }
        md += " Moyenne | Flags |\n"
        md += "|---|"
        for _ in profiles { md += "---|" }
        md += "---|---|\n"

        var flaggedTemplates: [(id: String, avg: Double, issues: String)] = []

        for tid in templatesSorted {
            let tRows = byTemplate[tid] ?? []
            md += "| \(tid) |"
            var scores: [Double] = []
            for p in profiles {
                let row = tRows.first(where: { $0.profileId == p.id })
                if let s = row?.score {
                    scores.append(s)
                    let marker = s < 6 ? "⚠️ " : ""
                    md += " \(marker)\(fmt(s))/10 |"
                } else {
                    md += " ERR |"
                }
            }
            let avg = scores.isEmpty ? 0.0 : scores.reduce(0, +) / Double(scores.count)
            let totalContradictions = tRows.reduce(0) { $0 + max($1.contradictions, 0) }
            let totalIssues = tRows.reduce(0) { $0 + max($1.rigidityIssues, 0) }
            var flagBits: [String] = []
            if avg < 6 { flagBits.append("rigide") }
            if totalContradictions >= 3 { flagBits.append("contradictions") }
            if !flagBits.isEmpty {
                flaggedTemplates.append((tid, avg, flagBits.joined(separator: "+")))
            }
            md += " **\(fmt(avg))/10** | \(flagBits.isEmpty ? "—" : "⚠️ " + flagBits.joined(separator: ", ")) |\n"
            _ = totalIssues
        }

        md += "\n## Templates flaggés (à revoir en 0.5.4 ou accepter tel quel)\n\n"
        if flaggedTemplates.isEmpty {
            md += "Aucun template flaggé. ✅\n"
        } else {
            for f in flaggedTemplates.sorted(by: { $0.avg < $1.avg }) {
                md += "- **\(f.id)** : \(fmt(f.avg))/10 moyen — \(f.issues)\n"
            }
        }

        md += "\n## Scores agrégés par profil\n\n"
        md += "| Profil | Score moyen |\n|---|---|\n"
        for p in profiles {
            let pRows = rows.filter { $0.profileId == p.id }
            let pScores = pRows.compactMap(\.score)
            let avg = pScores.isEmpty ? 0.0 : pScores.reduce(0, +) / Double(pScores.count)
            md += "| \(p.id) — \(p.label) | \(fmt(avg))/10 |\n"
        }

        md += "\n## Coût total\n\n$" + String(format: "%.4f", totalCost) + "\n"

        let summaryURL = outDir.appendingPathComponent("_adaptability_report.md")
        try? md.write(to: summaryURL, atomically: true, encoding: .utf8)
    }

    static func fmt(_ d: Double) -> String {
        String(format: "%.1f", d)
    }

    static func printUsage() {
        print("""
        Usage: swift run TestAdaptability [options]

        Options:
          --input-dir <path>  Directory with template JSONs (default: References/raw)
          --out <path>        Output dir (default: References/adaptability)
          --files <a,b,c>     Only test these template filenames (basename with or without .json)
          --profiles <ids>    Comma-separated profile ids (default: all 5). Ids: \(AdaptationProfiles.all.map(\.id).joined(separator: ", "))
          --model <name>      Model (default: claude-haiku-4-5)
          --dry-run           Print prompt for first (template, profile) pair, don't call API
          --env <path>        Explicit .env path
          -h, --help          Show this help
        """)
    }

    static func die(_ msg: String) -> Never {
        FileHandle.standardError.write(Data("ERROR: \(msg)\n".utf8))
        exit(2)
    }
}
