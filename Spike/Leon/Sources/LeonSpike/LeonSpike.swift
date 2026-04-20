import Foundation

@main
struct LeonSpike {
    static func main() async {
        print("======================================")
        print("  CoachingSage — Spike 0.3 Léon V2")
        print("======================================\n")

        // Resolve API key
        guard let apiKey = resolveApiKey(), !apiKey.isEmpty else {
            print("""
            ERROR : clé API Anthropic introuvable.

            Options :
              1. export ANTHROPIC_API_KEY=sk-ant-...
              2. Créer un fichier .env à côté de Package.swift avec :
                 ANTHROPIC_API_KEY=sk-ant-...
            """)
            exit(1)
        }

        let resultsDir = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            .appendingPathComponent("Results")

        let runner = RunnerV2(apiKey: apiKey, resultsDir: resultsDir)

        do {
            let results = try await runner.runAll()

            print("\n========================================")
            print("  Writing V2 findings report...")
            print("========================================")

            let reportFile = resultsDir.appendingPathComponent("spike-0.3-v2-findings.md")
            try ReporterV2.write(results: results, to: reportFile)
            print("Report written to: \(reportFile.path)")

            // Summary
            let total = results.count
            let succeeded = results.filter { $0.error == nil }.count
            let jsonOk = results.filter { $0.jsonValid }.count
            let nfrOk = results.filter { $0.nfr1Ok }.count
            let totalCost = results.reduce(0) { $0 + $1.estimatedCostUSD }

            print("\n--- Summary ---")
            print("Total calls      : \(total)")
            print("API success      : \(succeeded)/\(total)")
            print("Valid JSON       : \(jsonOk)/\(total)")
            print("NFR1 OK          : \(nfrOk)/\(total)")
            print(String(format: "Total cost (USD) : $%.4f", totalCost))

            exit(0)
        } catch {
            print("\nFATAL : \(error)")
            exit(1)
        }
    }

    /// Resolves ANTHROPIC_API_KEY from local `.env` first (authoritative for the spike),
    /// then falls back to the process environment.
    ///
    /// .env first avoids picking up a stale key from the user's shell profile.
    static func resolveApiKey() -> String? {
        // 1. Try .env in current working directory
        let cwd = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        let envFile = cwd.appendingPathComponent(".env")
        if let contents = try? String(contentsOf: envFile, encoding: .utf8) {
            for rawLine in contents.split(whereSeparator: { $0 == "\n" || $0 == "\r" }) {
                let trimmed = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmed.hasPrefix("#") || trimmed.isEmpty { continue }
                if let eq = trimmed.firstIndex(of: "=") {
                    let key = String(trimmed[..<eq]).trimmingCharacters(in: .whitespacesAndNewlines)
                    var value = String(trimmed[trimmed.index(after: eq)...])
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    if (value.hasPrefix("\"") && value.hasSuffix("\"")) ||
                       (value.hasPrefix("'") && value.hasSuffix("'")) {
                        value = String(value.dropFirst().dropLast())
                    }
                    if key == "ANTHROPIC_API_KEY", !value.isEmpty {
                        print("[resolveApiKey] loaded from .env (length=\(value.count))")
                        return value
                    }
                }
            }
        }

        // 2. Fallback : process environment
        if let env = ProcessInfo.processInfo.environment["ANTHROPIC_API_KEY"], !env.isEmpty {
            print("[resolveApiKey] loaded from environment (length=\(env.count))")
            return env
        }

        return nil
    }
}
