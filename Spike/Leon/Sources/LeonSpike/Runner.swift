import Foundation

/// Runner executes all test cases against Léon and writes results.
/// For each case it measures elapsed time (NFR1: < 5s), tokens, and saves the raw JSON.
struct Runner {
    let client: AnthropicClient
    let resultsDir: URL

    struct CaseResult: Codable {
        let id: String
        let sport: String
        let elapsedSeconds: Double
        let inputTokens: Int
        let outputTokens: Int
        let stopReason: String?
        let jsonValid: Bool
        let rawResponse: String
        let expectedChecks: [String]
        let error: String?
    }

    func runAll() async throws -> [CaseResult] {
        print("Running \(TestCases.all.count) test cases against Léon...\n")

        // Ensure results directory exists
        try FileManager.default.createDirectory(at: resultsDir, withIntermediateDirectories: true)

        var results: [CaseResult] = []

        for (idx, testCase) in TestCases.all.enumerated() {
            print("[\(idx + 1)/\(TestCases.all.count)] \(testCase.id) (\(testCase.sport))...")

            let userMessage = """
            # Profil utilisateur

            \(testCase.profile)

            # Demande

            \(testCase.request)
            """

            do {
                let call = try await client.call(
                    system: SystemPrompt.leon,
                    userMessage: userMessage
                )

                // Validate JSON — Léon is instructed to return strict JSON
                let jsonValid = isValidJSON(call.text)
                let nfr1Ok = call.elapsedSeconds < 5.0

                let status = nfr1Ok ? "OK" : "SLOW"
                let jsonStatus = jsonValid ? "valid JSON" : "INVALID JSON"
                print(
                    "  -> \(status) \(String(format: "%.2f", call.elapsedSeconds))s"
                    + " | tokens in=\(call.inputTokens) out=\(call.outputTokens)"
                    + " | \(jsonStatus)"
                    + (call.stopReason != nil ? " | stop=\(call.stopReason!)" : "")
                )

                let result = CaseResult(
                    id: testCase.id,
                    sport: testCase.sport,
                    elapsedSeconds: call.elapsedSeconds,
                    inputTokens: call.inputTokens,
                    outputTokens: call.outputTokens,
                    stopReason: call.stopReason,
                    jsonValid: jsonValid,
                    rawResponse: call.text,
                    expectedChecks: testCase.expectedChecks,
                    error: nil
                )
                results.append(result)

                // Save individual raw response as JSON file
                let rawFile = resultsDir.appendingPathComponent("\(testCase.id).json")
                try call.text.write(to: rawFile, atomically: true, encoding: .utf8)
            } catch {
                print("  -> FAILED: \(error)")
                results.append(CaseResult(
                    id: testCase.id,
                    sport: testCase.sport,
                    elapsedSeconds: 0,
                    inputTokens: 0,
                    outputTokens: 0,
                    stopReason: nil,
                    jsonValid: false,
                    rawResponse: "",
                    expectedChecks: testCase.expectedChecks,
                    error: String(describing: error)
                ))
            }
        }

        // Save aggregated summary
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let summaryData = try encoder.encode(results)
        let summaryFile = resultsDir.appendingPathComponent("_summary.json")
        try summaryData.write(to: summaryFile)

        return results
    }

    private func isValidJSON(_ text: String) -> Bool {
        // Try to parse as JSON, tolerating leading/trailing whitespace.
        // Léon is instructed NOT to wrap in markdown, but we also strip ```json fences if present.
        let trimmed = stripCodeFence(text.trimmingCharacters(in: .whitespacesAndNewlines))
        guard let data = trimmed.data(using: .utf8) else { return false }
        return (try? JSONSerialization.jsonObject(with: data)) != nil
    }

    private func stripCodeFence(_ text: String) -> String {
        var s = text
        if s.hasPrefix("```json") { s = String(s.dropFirst("```json".count)) }
        else if s.hasPrefix("```") { s = String(s.dropFirst(3)) }
        if s.hasSuffix("```") { s = String(s.dropLast(3)) }
        return s.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
