import Foundation

/// Conversion des dimensions de dosage en libellés SANS jargon (chantier dosage caméléon,
/// décision D1 + AC1 « Hybride » 2026-06-07, étendu à tous les sports par la revue qualité
/// thème #1 « zones/intensité » 2026-06-09). On garde l'INTENTION, on jette le MOT :
/// `plainEffort` : « RPE 6-7 » → « effort 6-7 sur 10 ».
/// `sensationLabel` : « FTP-Z2 »/« Daniels-E »/« EN1 »… → « endurance — tu peux parler » (le
/// code coach reste affiché en sous-texte tappable via le glossaire, côté appelant).
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

    /// Revue qualité thème #1 (zones/intensité) — politique d'affichage « sensation d'abord ».
    /// Convertit un code coach d'allure/zone (Daniels-E, FTP-Z2, EN1, CSS, Sweet-Spot, Z2…) en
    /// un libellé de SENSATION localisé (« facile — tu peux parler », « seuil »…) qui devient le
    /// libellé PRIMAIRE. Le code coach brut reste affiché en sous-texte tappable (glossaire) par
    /// l'appelant. nil = code non couvert (déjà clair comme « technique »/« maintien 30 s », ou
    /// hors périmètre comme RPE/%1RM/formats HIIT) → l'appelant garde le badge glossaire tel quel.
    /// Wording aligné sur les définitions glossaire (test de la parole) + référentiel dosage figé.
    static func sensationLabel(from targetZone: String, locale: Locale) -> String? {
        guard let key = sensationKey(for: targetZone) else { return nil }
        return String.localized(String.LocalizationValue(key), locale: locale)
    }

    /// Clé de localisation pour la sensation d'un code de zone, ou nil si non couvert.
    /// Exposé `internal` pour les tests (mapping pur, sans dépendance Locale).
    static func sensationKey(for targetZone: String) -> String? {
        let lower = targetZone.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !lower.isEmpty else { return nil }

        // Cyclisme — FTP-Z1..Z7 (testé AVANT les zones FC génériques pour ne pas confondre).
        if let n = firstCapture(#"ftp[-\s]?z\s?([1-7])"#, in: lower) {
            return "coaching.zone.sensation.ftp.z\(n)"
        }
        if lower.contains("sweet") { return "coaching.zone.sensation.sweetspot" }

        // Muscu — %1RM 75-80 / 80-85 / 85-90 % → échelle de lourdeur (la borne basse distingue).
        // Coexiste avec la consigne de charge (ChargeGuidance) : ici on dit « combien c'est lourd »,
        // la consigne dit « comment doser » — adjacence validée par revue persona (réserve #2).
        if lower.contains("1rm"), let n = firstCapture(#"1rm\D*(\d{2})"#, in: lower) {
            return "coaching.zone.sensation.load.\(n)"
        }

        // Course — Daniels-E/M/T/I/R + allures de référence.
        if let c = firstCapture(#"daniels[-\s]?([emtir])"#, in: lower) {
            return "coaching.zone.sensation.daniels.\(c)"
        }
        if lower.contains("hmp") { return "coaching.zone.sensation.hmp" }
        if lower.contains("10k") { return "coaching.zone.sensation.pace10k" }
        if lower.contains("5k") { return "coaching.zone.sensation.pace5k" }

        // Natation — EN1/2/3, REC, CSS, SP1/2/3.
        if let n = firstCapture(#"\ben\s?([1-3])\b"#, in: lower) {
            return "coaching.zone.sensation.en\(n)"
        }
        if lower == "rec" { return "coaching.zone.sensation.rec" }
        if lower.contains("css") {
            return lower.contains("+") ? "coaching.zone.sensation.css.plus" : "coaching.zone.sensation.css"
        }
        if let n = firstCapture(#"\bsp\s?([1-3])\b"#, in: lower) {
            return "coaching.zone.sensation.sp\(n)"
        }

        // Zones FC génériques Z1-Z4 (+ « Z2-cardiac ») — football, rando, tennis.
        if let n = firstCapture(#"^z\s?([1-4])\b"#, in: lower) {
            return "coaching.zone.sensation.hr.z\(n)"
        }

        return nil
    }

    /// Première capture d'un groupe `()` d'une regex (insensible à la casse déjà gérée en amont).
    private static func firstCapture(_ pattern: String, in text: String) -> String? {
        guard let re = try? NSRegularExpression(pattern: pattern),
              let m = re.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
              m.numberOfRanges > 1,
              let r = Range(m.range(at: 1), in: text)
        else { return nil }
        return String(text[r])
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
        for token in sideTokens {
            r = r.replacingOccurrences(of: token, with: "", options: .caseInsensitive)
        }
        return r.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static let sideTokens = ["par côté", "par cote", "/côté", "/cote",
                                     "each side", "per side", "/side", "por lado", "cada lado"]

    /// Reps localisés pour l'affichage liste/chip : traduit le suffixe de latéralité
    /// (contenu template en FR « par côté ») vers la langue courante — sinon il fuit en
    /// FR sous locale EN/ES (bug attrapé au screenshot ES 2026-06-14). Les chiffres sont
    /// neutres. FR = inchangé.
    static func localizedReps(_ reps: String, locale: Locale) -> String {
        guard sideTokens.contains(where: { reps.range(of: $0, options: .caseInsensitive) != nil })
        else { return reps }
        let suffix: String
        switch locale.language.languageCode?.identifier {
        case "es": suffix = "por lado"
        case "en": suffix = "per side"
        default:   suffix = "par côté"
        }
        let base = repsHero(from: reps)
        return base.isEmpty ? suffix : "\(base) \(suffix)"
    }
}
