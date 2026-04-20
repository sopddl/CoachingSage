import Foundation

/// Markdown reporter for the V2 spike run (3 dimensions).
enum ReporterV2 {

    static func write(results: [RunnerV2.CaseResult], to file: URL) throws {
        let d1 = results.filter { $0.dimension == "D1-skeleton-sonnet" }
        let d2 = results.filter { $0.dimension == "D2-skeleton-haiku" }
        let d3 = results.filter { $0.dimension == "D3-adapt-haiku" }
        let totalCost = results.reduce(0) { $0 + $1.estimatedCostUSD }

        var md = """
        # Spike 0.3 V2 — Findings

        **Date** : \(isoDate())
        **Architecture testée** : progressive disclosure + template adaptation (décisions 2026-04-06)

        ## Résumé exécutif

        | Dimension | Modèle | Cas | Success | NFR1 OK | JSON OK | Temps moyen | Coût total |
        |---|---|---|---|---|---|---|---|
        \(summaryRow("D1 — Skeleton + S1", "sonnet-4-6", d1))
        \(summaryRow("D2 — Skeleton + S1", "haiku-4-5", d2))
        \(summaryRow("D3 — Template Adapt", "haiku-4-5", d3))

        **Coût total du run V2** : $\(String(format: "%.4f", totalCost))

        """

        md += "\n## Dimension 1 — Progressive disclosure avec sonnet-4-6\n\n"
        md += "Teste si Léon peut produire un squelette + semaine 1 détaillée dans un budget raisonnable (cible NFR1' < 15s).\n\n"
        md += renderCases(d1)

        md += "\n## Dimension 2 — Même prompt avec claude-haiku-4-5\n\n"
        md += "Compare la qualité/vitesse/coût de haiku vs sonnet sur le même prompt. Haiku devrait être ~3× plus rapide et ~5× moins cher.\n\n"
        md += renderCases(d2)

        md += "\n## Dimension 3 — Template adaptation (hot path free tier)\n\n"
        md += "Teste si Léon peut adapter un template pré-existant via un JSON patch. C'est le cas d'usage **principal en production** (80%+ des calls).\n\n"
        md += renderCases(d3)

        md += "\n## Analyse comparative sonnet vs haiku sur le squelette\n\n"
        md += buildComparisonTable(d1: d1, d2: d2)

        md += "\n## Décision recommandée\n\n"
        md += buildDecision(d1: d1, d2: d2, d3: d3)

        try md.write(to: file, atomically: true, encoding: .utf8)
    }

    // MARK: - Helpers

    private static func summaryRow(_ name: String, _ model: String, _ results: [RunnerV2.CaseResult]) -> String {
        let count = results.count
        guard count > 0 else { return "| \(name) | \(model) | 0 | — | — | — | — | — |" }
        let success = results.filter { $0.error == nil }.count
        let nfr = results.filter { $0.nfr1Ok }.count
        let json = results.filter { $0.jsonValid }.count
        let avgTime = results.map { $0.elapsedSeconds }.reduce(0, +) / Double(count)
        let cost = results.reduce(0) { $0 + $1.estimatedCostUSD }
        return "| \(name) | \(model) | \(count) | \(success)/\(count) | \(nfr)/\(count) | \(json)/\(count) | \(String(format: "%.1f", avgTime))s | $\(String(format: "%.4f", cost)) |"
    }

    private static func renderCases(_ results: [RunnerV2.CaseResult]) -> String {
        var md = ""
        for r in results {
            md += "### \(r.caseId) — \(r.sport)\n\n"
            md += "- **Modèle** : `\(r.model)`\n"
            md += "- **Durée** : \(String(format: "%.2f", r.elapsedSeconds))s \(r.nfr1Ok ? "✅" : "❌")\n"
            md += "- **Tokens** : in=\(r.inputTokens) out=\(r.outputTokens)\n"
            md += "- **Coût estimé** : $\(String(format: "%.4f", r.estimatedCostUSD))\n"
            md += "- **JSON** : \(r.jsonValid ? "✅ valide" : "❌ invalide")\n"
            if let stop = r.stopReason, stop != "end_turn" {
                md += "- **Stop reason** : `\(stop)` ⚠️\n"
            }
            if let err = r.error {
                md += "- **Erreur** : `\(err)`\n"
            }
            md += "- **Fichier brut** : `\(r.dimension)_\(r.caseId).json`\n"
            md += "- **Checks qualitatifs attendus** :\n"
            for c in r.expectedChecks {
                md += "  - [ ] \(c)\n"
            }
            md += "\n"
        }
        return md
    }

    private static func buildComparisonTable(d1: [RunnerV2.CaseResult], d2: [RunnerV2.CaseResult]) -> String {
        guard !d1.isEmpty && !d2.isEmpty else { return "_(pas assez de données pour comparer)_\n" }

        var md = "| Cas | sonnet temps | haiku temps | Speedup | sonnet coût | haiku coût | Économie |\n"
        md += "|---|---|---|---|---|---|---|\n"
        for s in d1 {
            if let h = d2.first(where: { $0.caseId == s.caseId }) {
                let speedup = s.elapsedSeconds > 0 && h.elapsedSeconds > 0
                    ? String(format: "%.1f×", s.elapsedSeconds / h.elapsedSeconds)
                    : "—"
                let save = s.estimatedCostUSD > 0 && h.estimatedCostUSD > 0
                    ? String(format: "%.1f×", s.estimatedCostUSD / h.estimatedCostUSD)
                    : "—"
                md += "| \(s.caseId) | \(String(format: "%.1f", s.elapsedSeconds))s | \(String(format: "%.1f", h.elapsedSeconds))s | \(speedup) | $\(String(format: "%.4f", s.estimatedCostUSD)) | $\(String(format: "%.4f", h.estimatedCostUSD)) | \(save) |\n"
            }
        }
        return md
    }

    private static func buildDecision(d1: [RunnerV2.CaseResult], d2: [RunnerV2.CaseResult], d3: [RunnerV2.CaseResult]) -> String {
        var md = ""

        // Dimension 3 is the critical one — if template adaptation works, we have the architecture.
        let d3ok = !d3.isEmpty && d3.allSatisfy { $0.error == nil && $0.jsonValid && $0.nfr1Ok }
        if d3ok {
            md += "✅ **Template adaptation VALIDÉE** : tous les cas D3 passent NFR1' < 10s, JSON valide, pas d'erreur API. L'architecture template+patch est viable pour le hot path free tier.\n\n"
        } else {
            md += "⚠️ **Template adaptation à re-examiner** : certains cas D3 n'ont pas passé tous les critères. À analyser qualitativement avant de conclure.\n\n"
        }

        // Skeleton dimension
        let d1Ok = !d1.isEmpty && d1.allSatisfy { $0.error == nil && $0.jsonValid && $0.nfr1Ok }
        let d2Ok = !d2.isEmpty && d2.allSatisfy { $0.error == nil && $0.jsonValid && $0.nfr1Ok }
        if d1Ok && d2Ok {
            md += "✅ **Progressive disclosure VALIDÉE** sur les 2 modèles. Les 2 peuvent produire un squelette + S1 en < 15s.\n\n"
        } else if d2Ok {
            md += "⚠️ **Progressive disclosure** : haiku valide, sonnet nécessite un budget temps plus large. → Sonnet uniquement sur cas où on a le temps (async, job en background), haiku en temps réel.\n\n"
        } else if d1Ok {
            md += "⚠️ **Progressive disclosure** : sonnet valide mais haiku à problème. Qualité à re-examiner qualitativement — haiku pourrait être trop léger pour ce niveau de détail.\n\n"
        } else {
            md += "❌ **Progressive disclosure non validée** sur cette itération. Revoir le prompt ou la cible de tokens.\n\n"
        }

        md += """
        ## Prochaines actions

        1. Lire les 6 JSON bruts (2 D1 + 2 D2 + 2 D3) et valider qualitativement
        2. Si qualité D3 OK → acter l'architecture template-first et réécrire Epic 2 + Epic 3
        3. Si D2 (haiku) qualité OK → confirmer model tiering sonnet/haiku
        4. Si D1 (sonnet) temps > 15s → relever le budget NFR1' à 30-45s pour les cas edge (acceptable si async)
        """
        return md
    }

    private static func isoDate() -> String {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withFullDate]
        return f.string(from: Date())
    }
}
