import Foundation

/// Conversion des dimensions de dosage en libellés SANS jargon (chantier dosage caméléon,
/// décision D1 + AC1 « Hybride » 2026-06-07). On garde l'INTENTION, on jette le MOT :
/// « RPE 6-7 » devient « effort 6-7 sur 10 ». Les vraies zones d'allure (Z2, Daniels-E…)
/// ne sont PAS converties ici — elles restent gérées par le glossaire (autres sports).
enum DosageFormatting {

    /// Si `targetZone` est un RPE (« RPE 6-7 », « rpe:8 », « RPE 7-8 »), renvoie un libellé
    /// d'effort en français normal (« effort 6-7 sur 10 ») localisé. nil sinon (→ l'appelant
    /// garde le badge glossaire pour les vraies zones d'allure).
    static func plainEffort(from targetZone: String, locale: Locale) -> String? {
        let lower = targetZone.lowercased()
        guard lower.contains("rpe") else { return nil }
        // Isole la portion numérique (« 6-7 », « 8 », « 7-8 ») en retirant le mot + ponctuation.
        let value = targetZone
            .replacingOccurrences(of: #"(?i)\brpe\b"#, with: "", options: .regularExpression)
            .replacingOccurrences(of: ":", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty else { return nil }
        return String.localized("coaching.dosage.effort \(value)", locale: locale)
    }

    /// Exercice unilatéral (chantier dosage D4) ? Détecté depuis le texte des reps
    /// (« 10 par côté », « each side », « cada lado ») tant que les templates n'ont pas
    /// de champ `side` structuré. FR/EN/ES.
    static func isUnilateral(reps: String?) -> Bool {
        guard let r = reps?.lowercased() else { return false }
        return r.contains("côté") || r.contains("cote")
            || r.contains("each side") || r.contains("per side") || r.contains("/side")
            || r.contains("lado")
    }

    /// Nombre de reps « propre » pour le héros : retire le suffixe de latéralité (« 10 par
    /// côté » → « 10 ») — la latéralité est rendue à part en guidage « Côté droit · gauche ».
    static func repsHero(from reps: String) -> String {
        var r = reps
        for token in ["par côté", "par cote", "/côté", "/cote", "each side", "per side", "/side", "por lado", "cada lado"] {
            r = r.replacingOccurrences(of: token, with: "", options: .caseInsensitive)
        }
        return r.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
