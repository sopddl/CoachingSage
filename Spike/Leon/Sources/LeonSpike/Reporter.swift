import Foundation

/// Generates a markdown report summarizing the spike run.
/// Sophie can read this to qualitatively validate program quality.
struct Reporter {
    let results: [Runner.CaseResult]
    let outputFile: URL
    let model: String

    func write() throws {
        let successes = results.filter { $0.error == nil }
        let failures = results.filter { $0.error != nil }
        let validJson = results.filter { $0.jsonValid }
        let slow = successes.filter { $0.elapsedSeconds >= 5.0 }
        let fast = successes.filter { $0.elapsedSeconds < 5.0 }

        let avgTime = successes.isEmpty ? 0 :
            successes.map { $0.elapsedSeconds }.reduce(0, +) / Double(successes.count)
        let avgInputTokens = successes.isEmpty ? 0 :
            successes.map { $0.inputTokens }.reduce(0, +) / successes.count
        let avgOutputTokens = successes.isEmpty ? 0 :
            successes.map { $0.outputTokens }.reduce(0, +) / successes.count

        var md = """
        # Spike 0.3 — Qualité programmes Léon

        **Date** : \(isoDate())
        **Model** : `\(model)`
        **Cas testés** : \(results.count) (10 profils × 5+ sports, couvrant débutant→expert, contraintes physiques, multi-discipline, équipement varié)

        ## Résultats quantitatifs

        | Métrique | Valeur | Critère (NFR1) |
        |---|---|---|
        | Cas réussis (API OK) | \(successes.count) / \(results.count) | — |
        | JSON valide | \(validJson.count) / \(results.count) | attendu 100% |
        | Temps moyen | \(String(format: "%.2f", avgTime))s | < 5s |
        | Cas < 5s | \(fast.count) / \(successes.count) | attendu 100% |
        | Cas >= 5s | \(slow.count) | attendu 0 |
        | Tokens input moyens | \(avgInputTokens) | — |
        | Tokens output moyens | \(avgOutputTokens) | — |

        ## Verdict technique (automatique)


        """

        var pass = true
        var reasons: [String] = []
        if !failures.isEmpty {
            pass = false
            reasons.append("❌ \(failures.count) appel(s) API échoué(s)")
        }
        if validJson.count < results.count {
            pass = false
            reasons.append("❌ \(results.count - validJson.count) réponse(s) non-JSON valide")
        }
        if !slow.isEmpty {
            pass = false
            reasons.append("❌ \(slow.count) cas dépassent NFR1 (< 5s)")
        }
        if pass {
            md += "✅ **PASS technique** : tous les critères NFR1/JSON sont satisfaits.\n\n"
        } else {
            md += "❌ **FAIL technique** :\n" + reasons.map { "- \($0)" }.joined(separator: "\n") + "\n\n"
        }

        md += """
        > Le verdict **qualitatif** (qualité des programmes) doit être fait par Sophie en lisant chaque cas ci-dessous.

        ## Détail par cas

        """

        for r in results {
            md += "### \(r.id) — \(r.sport)\n\n"
            md += "- **Durée** : \(String(format: "%.2f", r.elapsedSeconds))s "
            md += r.elapsedSeconds < 5.0 ? "✅" : "❌ (dépasse NFR1)"
            md += "\n"
            md += "- **Tokens** : in=\(r.inputTokens) out=\(r.outputTokens)\n"
            md += "- **JSON** : \(r.jsonValid ? "✅ valide" : "❌ invalide")\n"
            if let stop = r.stopReason {
                md += "- **Stop reason** : `\(stop)` "
                if stop != "end_turn" { md += "⚠️" }
                md += "\n"
            }
            if let err = r.error {
                md += "- **Erreur** : `\(err)`\n"
            }
            md += "- **Checks qualitatifs attendus** :\n"
            for c in r.expectedChecks {
                md += "  - [ ] \(c)\n"
            }
            md += "- **Fichier brut** : `\(r.id).json`\n\n"
        }

        md += """

        ## Instructions pour Sophie

        1. Ouvre chaque fichier `.json` de ce dossier et lis le programme.
        2. Coche les checks qualitatifs dans la liste ci-dessus (ou note ce qui manque).
        3. Verdict :
           - Si **≥ 8/10 cas** ont un programme cohérent et respectent les contraintes → **SPIKE PASS**, on peut démarrer Epic 1.
           - Si **< 8/10 cas** sont bons → identifier les motifs (prompt à améliorer, modèle à changer, scope à réduire) et itérer.

        ## Notes pour la suite

        - Ce spike utilise un appel direct à l'API Anthropic (pas d'Edge Function). En production, on passera par `sage-coaching-ai` sur Supabase (cf. architecture-CoachingSage.md).
        - Le prompt système utilisé est dans `SystemPrompt.swift` — si des itérations sont nécessaires, modifier là.
        - Les cas de test sont dans `TestCases.swift`.
        """

        try md.write(to: outputFile, atomically: true, encoding: .utf8)
    }

    private func isoDate() -> String {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withFullDate]
        return f.string(from: Date())
    }
}
