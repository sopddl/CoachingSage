// Coaching/Session/SessionPhaseText.swift
// Story 3.35f — met en forme le texte d'un échauffement / récup : découpe en
// puces sur les « + » (retour Sophie : « aller à la ligne plus souvent »), retire
// les « / » et extrait la durée totale (« Total : 8 min ») pour l'afficher à part
// (en haut à droite du libellé).
import Foundation

enum SessionPhaseText {

    /// Lignes (puces) d'un texte de phase / de notes d'exo. Découpe sur les « + »
    /// ET les fins de phrase (« . »), retire la mention « Total : … », assainit les
    /// « / ». Rend un texte dense lisible (retour Sophie : « c'est illisible »).
    static func bulletLines(from text: String) -> [String] {
        let withoutTotal = stripTotal(text)
        let parts = withoutTotal.split(whereSeparator: { $0 == "+" || $0 == "." }).map(String.init)
        let lines = parts
            .map { $0.sanitizedForDisplay.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        // Si le découpage ne donne rien d'exploitable, renvoie le texte assaini entier.
        return lines.isEmpty ? [withoutTotal.sanitizedForDisplay] : lines
    }

    /// Durée totale en SECONDES d'un texte d'échauffement / récup (bug #6 — minuteur
    /// global). Priorité à « Total : N min » explicite, sinon somme des durées des
    /// segments (« 10 min mobilité + 2 min gainage » → 720). nil si rien de parsable.
    static func totalSeconds(from text: String) -> Int? {
        if let label = totalLabel(from: text) {
            let digits = label.prefix { $0.isNumber }
            if let n = Int(digits) { return n * 60 }
        }
        let sum = SessionDurationParser.segments(text).reduce(0) { $0 + $1.seconds }
        return sum > 0 ? sum : nil
    }

    /// Durée totale lisible (« 8 min ») si le texte contient « Total : N min », nil sinon.
    static func totalLabel(from text: String) -> String? {
        // Cherche "total" puis le 1er nombre + "min" qui suit.
        let lower = text.lowercased()
        guard let range = lower.range(of: "total") else { return nil }
        let after = String(lower[range.upperBound...])
        var digits = ""
        var started = false
        for ch in after {
            if ch.isNumber { digits.append(ch); started = true }
            else if started { break }
        }
        guard let n = Int(digits) else { return nil }
        return "\(n) min"
    }

    /// Retire la phrase « Total : … min[.] » du corps.
    private static func stripTotal(_ text: String) -> String {
        guard let r = text.range(of: "Total", options: .caseInsensitive) else { return text }
        // Coupe à partir de "Total" jusqu'au prochain "." inclus (ou fin).
        let tail = text[r.lowerBound...]
        if let dot = tail.firstIndex(of: ".") {
            var result = text
            result.removeSubrange(r.lowerBound...dot)
            return result.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return String(text[..<r.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
