import Foundation

/// V2 runner : tests 3 dimensions to validate the architecture decisions of 2026-04-06.
///
/// Dimension 1 : Progressive disclosure (skeleton + week 1) with sonnet-4-6
/// Dimension 2 : Same, but with haiku-4-5 (quality/cost tradeoff)
/// Dimension 3 : Template adaptation — Léon receives a template + profile, returns a JSON patch
///
/// Between every call we sleep 5 seconds to avoid rate-limit bursts (empirical : 4 large sonnet
/// calls back-to-back triggered rate limits in the v1 run).
struct RunnerV2 {
    let apiKey: String
    let resultsDir: URL

    struct CaseResult: Codable {
        let dimension: String
        let caseId: String
        let sport: String
        let model: String
        let elapsedSeconds: Double
        let inputTokens: Int
        let outputTokens: Int
        let estimatedCostUSD: Double
        let stopReason: String?
        let jsonValid: Bool
        let rawResponse: String
        let expectedChecks: [String]
        let nfr1Ok: Bool
        let error: String?
    }

    /// NFR1' revised : "usable skeleton < 15 seconds" instead of "full program < 5s".
    /// Adaptation should be much faster (< 10s target).
    private let nfr1SkeletonCeilingSeconds: Double = 15.0
    private let nfr1AdaptationCeilingSeconds: Double = 10.0

    func runAll() async throws -> [CaseResult] {
        try FileManager.default.createDirectory(at: resultsDir, withIntermediateDirectories: true)

        var all: [CaseResult] = []

        print("\n========================================")
        print("  DIMENSION 1 — Skeleton + S1 (sonnet)")
        print("========================================\n")
        let sonnet = AnthropicClient(apiKey: apiKey, model: "claude-sonnet-4-6", maxTokens: 6144)
        let skelCases = pickSkeletonCases()
        for (idx, tc) in skelCases.enumerated() {
            print("[D1 \(idx + 1)/\(skelCases.count)] \(tc.id) (\(tc.sport))...")
            let r = await runSkeletonCase(tc: tc, client: sonnet, dimension: "D1-skeleton-sonnet")
            all.append(r)
            await throttle()
        }

        print("\n========================================")
        print("  DIMENSION 2 — Skeleton + S1 (haiku)")
        print("========================================\n")
        let haiku = AnthropicClient(apiKey: apiKey, model: "claude-haiku-4-5-20251001", maxTokens: 6144)
        for (idx, tc) in skelCases.enumerated() {
            print("[D2 \(idx + 1)/\(skelCases.count)] \(tc.id) (\(tc.sport))...")
            let r = await runSkeletonCase(tc: tc, client: haiku, dimension: "D2-skeleton-haiku")
            all.append(r)
            await throttle()
        }

        print("\n========================================")
        print("  DIMENSION 3 — Template adaptation (haiku)")
        print("========================================\n")
        // Template adaptation is the HOT path for free tier → haiku is the target.
        for (idx, ac) in AdaptationCases.all.enumerated() {
            print("[D3 \(idx + 1)/\(AdaptationCases.all.count)] \(ac.id) (\(ac.sport))...")
            let r = await runAdaptationCase(ac: ac, client: haiku, dimension: "D3-adapt-haiku")
            all.append(r)
            await throttle()
        }

        // Save aggregated results
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(all)
        try data.write(to: resultsDir.appendingPathComponent("_v2_summary.json"))

        return all
    }

    // MARK: - Dimension 1 / 2 — skeleton cases

    /// We reuse 2 cases from v1 that are representative edges :
    /// - Running débutante with knee fragility (sécurité + contrainte)
    /// - Triathlon sprint (multi-discipline, complexe)
    private func pickSkeletonCases() -> [TestCase] {
        let wanted: Set<String> = ["01-running-debutant", "08-triathlon-sprint-premier"]
        return TestCases.all.filter { wanted.contains($0.id) }
    }

    private func runSkeletonCase(
        tc: TestCase,
        client: AnthropicClient,
        dimension: String
    ) async -> CaseResult {
        let userMessage = """
        # Profil utilisateur

        \(tc.profile)

        # Demande

        \(tc.request)
        """

        do {
            let call = try await client.call(
                system: Prompts.skeletonAndWeek1,
                userMessage: userMessage
            )
            let jsonValid = isValidJSON(call.text)
            let nfr1Ok = call.elapsedSeconds < nfr1SkeletonCeilingSeconds

            let status = nfr1Ok ? "OK" : "SLOW"
            let jsonStatus = jsonValid ? "valid" : "INVALID"
            print(
                "  -> \(status) \(String(format: "%.2f", call.elapsedSeconds))s"
                + " | in=\(call.inputTokens) out=\(call.outputTokens)"
                + " | $\(String(format: "%.4f", call.estimatedCostUSD))"
                + " | JSON \(jsonStatus)"
                + (call.stopReason != nil && call.stopReason != "end_turn" ? " | stop=\(call.stopReason!)" : "")
            )

            // Save raw response
            let fileName = "\(dimension)_\(tc.id).json"
            try? call.text.write(
                to: resultsDir.appendingPathComponent(fileName),
                atomically: true,
                encoding: .utf8
            )

            return CaseResult(
                dimension: dimension,
                caseId: tc.id,
                sport: tc.sport,
                model: call.model,
                elapsedSeconds: call.elapsedSeconds,
                inputTokens: call.inputTokens,
                outputTokens: call.outputTokens,
                estimatedCostUSD: call.estimatedCostUSD,
                stopReason: call.stopReason,
                jsonValid: jsonValid,
                rawResponse: call.text,
                expectedChecks: tc.expectedChecks,
                nfr1Ok: nfr1Ok,
                error: nil
            )
        } catch {
            print("  -> FAILED: \(error)")
            return CaseResult(
                dimension: dimension,
                caseId: tc.id,
                sport: tc.sport,
                model: client.model,
                elapsedSeconds: 0,
                inputTokens: 0,
                outputTokens: 0,
                estimatedCostUSD: 0,
                stopReason: nil,
                jsonValid: false,
                rawResponse: "",
                expectedChecks: tc.expectedChecks,
                nfr1Ok: false,
                error: String(describing: error)
            )
        }
    }

    // MARK: - Dimension 3 — template adaptation

    private func runAdaptationCase(
        ac: AdaptationCase,
        client: AnthropicClient,
        dimension: String
    ) async -> CaseResult {
        let userMessage = """
        # Programme de base à adapter

        \(ac.template)

        # Profil utilisateur

        \(ac.userProfile)

        # Demande

        Adapte ce programme au profil ci-dessus. Renvoie UNIQUEMENT le JSON patch avec les adaptations, pas le programme complet.
        """

        do {
            let call = try await client.call(
                system: Prompts.templateAdaptation,
                userMessage: userMessage
            )
            let jsonValid = isValidJSON(call.text)
            let nfr1Ok = call.elapsedSeconds < nfr1AdaptationCeilingSeconds

            let status = nfr1Ok ? "OK" : "SLOW"
            let jsonStatus = jsonValid ? "valid" : "INVALID"
            print(
                "  -> \(status) \(String(format: "%.2f", call.elapsedSeconds))s"
                + " | in=\(call.inputTokens) out=\(call.outputTokens)"
                + " | $\(String(format: "%.4f", call.estimatedCostUSD))"
                + " | JSON \(jsonStatus)"
                + (call.stopReason != nil && call.stopReason != "end_turn" ? " | stop=\(call.stopReason!)" : "")
            )

            let fileName = "\(dimension)_\(ac.id).json"
            try? call.text.write(
                to: resultsDir.appendingPathComponent(fileName),
                atomically: true,
                encoding: .utf8
            )

            return CaseResult(
                dimension: dimension,
                caseId: ac.id,
                sport: ac.sport,
                model: call.model,
                elapsedSeconds: call.elapsedSeconds,
                inputTokens: call.inputTokens,
                outputTokens: call.outputTokens,
                estimatedCostUSD: call.estimatedCostUSD,
                stopReason: call.stopReason,
                jsonValid: jsonValid,
                rawResponse: call.text,
                expectedChecks: ac.expectedAdaptations,
                nfr1Ok: nfr1Ok,
                error: nil
            )
        } catch {
            print("  -> FAILED: \(error)")
            return CaseResult(
                dimension: dimension,
                caseId: ac.id,
                sport: ac.sport,
                model: client.model,
                elapsedSeconds: 0,
                inputTokens: 0,
                outputTokens: 0,
                estimatedCostUSD: 0,
                stopReason: nil,
                jsonValid: false,
                rawResponse: "",
                expectedChecks: ac.expectedAdaptations,
                nfr1Ok: false,
                error: String(describing: error)
            )
        }
    }

    // MARK: - Helpers

    private func throttle() async {
        try? await Task.sleep(nanoseconds: 5_000_000_000)
    }

    private func isValidJSON(_ text: String) -> Bool {
        let stripped = stripCodeFence(text.trimmingCharacters(in: .whitespacesAndNewlines))
        guard let data = stripped.data(using: .utf8) else { return false }
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
