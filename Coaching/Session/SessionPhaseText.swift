// Coaching/Session/SessionPhaseText.swift
// Story 3.35f — met en forme le texte d'un échauffement / récup : découpe en
// puces sur les « + » (retour Sophie : « aller à la ligne plus souvent »), retire
// les « / » et extrait la durée totale (« Total : 8 min ») pour l'afficher à part
// (en haut à droite du libellé).
import Foundation

enum SessionPhaseText {

    /// Lignes (puces) d'un texte de phase / de notes d'exo. Découpe sur les « + »
    /// ET les fins de phrase (« . »), SAUF à l'intérieur de parenthèses ouvertes,
    /// retire la mention « Total : … » (fin) et « N min : » (préfixe de durée totale
    /// en tête), assainit les « / ». Rend un texte dense lisible (retour Sophie :
    /// « c'est illisible »).
    static func bulletLines(from text: String) -> [String] {
        let withoutTotal = stripTotal(text)
        let withoutLeadingPrefix = stripLeadingDurationPrefix(withoutTotal)
        let parts = splitRespectingParentheses(withoutLeadingPrefix)
        let lines = parts
            .map { $0.sanitizedForDisplay.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        // Si le découpage ne donne rien d'exploitable, renvoie le texte assaini entier.
        return lines.isEmpty ? [withoutLeadingPrefix.sanitizedForDisplay] : lines
    }

    /// Découpe sur « + »/« . » en respectant la profondeur de parenthèses — bug device
    /// ui-reviewer 2026-08-10 (chantier yoga) : un segment du type « poignets (cercles +
    /// paumes mur 30s × 2) » coupé naïvement produisait 2 lignes orphelines avec une
    /// parenthèse non refermée. Comportement identique au split naïf hors parenthèses.
    private static func splitRespectingParentheses(_ text: String) -> [String] {
        var parts: [String] = []
        var current = ""
        var depth = 0
        for ch in text {
            if ch == "(" { depth += 1 } else if ch == ")" { depth = max(0, depth - 1) }
            if (ch == "+" || ch == ".") && depth == 0 {
                parts.append(current)
                current = ""
            } else {
                current.append(ch)
            }
        }
        parts.append(current)
        return parts
    }

    /// Retire le préfixe « N min : » en tête (durée TOTALE du step, déjà affichée à
    /// part) — bug device ui-reviewer 2026-08-10 (chantier yoga) : sans ce retrait,
    /// `SessionDurationParser.seconds` sur le 1ᵉʳ segment lit « N » comme minutes PUIS
    /// absorbe le 1ᵉʳ nombre du texte réel comme secondes (« 7 min : Sukhasana 2 min
    /// Dirgha » → 7*60+2 = 422s au lieu de 120s pour l'instruction réelle). Utilisé par
    /// `bulletLines` ET `SessionPhaseVoiceSchedule.cues` (même défaut sur la voix
    /// égrenée, pas encore audible avant que le nouveau rendu 1-écran/sous-pas ne
    /// l'expose visuellement).
    static func stripLeadingDurationPrefix(_ text: String) -> String {
        let ns = text as NSString
        guard let match = leadingDurationPrefixPattern.firstMatch(
            in: text, range: NSRange(location: 0, length: ns.length)) else { return text }
        return ns.substring(from: match.range.location + match.range.length)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static let leadingDurationPrefixPattern = try! NSRegularExpression(
        pattern: #"^\s*\d+\s*(min|mn)\s*:\s*"#, options: [.caseInsensitive])

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

/// Story voix échauffement/récup (device-test 2026-06-09) — script vocal ÉGRENÉ
/// d'une phase d'échauffement / retour au calme. Avant ce fix la voix ne disait
/// que le mot « Échauffement » ; désormais elle lit le contenu, réparti dans le temps.
///
/// Règle (décisions Sophie 2026-06-10) :
///  - segments AVEC une durée chiffrée (« 5 min vélo ») → annoncés à leur offset
///    cumulé (course à 0:00, le suivant à 5:00…) → « égrené dans le temps » ;
///  - segments SANS durée (cues posturaux « épaules détendues ») → dits au DÉBUT,
///    car on ne peut pas savoir de façon fiable s'il faut les enchaîner plus tard ;
///  - l'annonce d'entrée (offset 0) = `header` (titre + durée) + 1ᵉʳ segment minuté
///    + tous les cues. Pas de plafond : tout est lu.
/// Multilingue : le `text` est déjà résolu dans la langue de contenu en amont.
enum SessionPhaseVoiceSchedule {
    struct Cue: Equatable {
        let offset: Int       // secondes depuis le début de la phase
        let phrase: String
    }

    /// Construit le script. `header` = préfixe parlé déjà localisé (« Échauffement,
    /// 7 minutes »). `text` = contenu brut de l'échauffement/récup (résolu locale).
    static func cues(text: String, header: String) -> [Cue] {
        // Retire le préfixe « N min : » (durée totale du step) AVANT de segmenter —
        // bug device ui-reviewer 2026-08-10, même défaut que `bulletLines` : sinon le
        // 1ᵉʳ segment absorbe ce préfixe et `SessionDurationParser.seconds` le lit comme
        // "N min" + le 1ᵉʳ nombre du texte réel comme secondes (offset totalement faux).
        let withoutLeadingPrefix = SessionPhaseText.stripLeadingDurationPrefix(text)
        // Segmentation au niveau des « + » (cohérent avec `SessionDurationParser`).
        let segments = withoutLeadingPrefix.split(separator: "+").map {
            String($0).trimmingCharacters(in: .whitespacesAndNewlines)
        }

        var timed: [(phrase: String, seconds: Int)] = []
        var posturalCues: [String] = []
        for seg in segments {
            // Texte parlé propre (assaini « / », sans « Total : … », phrases coupées).
            let spoken = SessionPhaseText.bulletLines(from: seg).joined(separator: ". ")
            guard !spoken.isEmpty else { continue }
            if let s = SessionDurationParser.seconds(seg) {
                timed.append((spoken, s))
            } else {
                posturalCues.append(spoken)
            }
        }

        var result: [Cue] = []
        // Entrée (offset 0) : header + 1ᵉʳ segment minuté + cues posturaux.
        var entry: [String] = [header]
        if let first = timed.first { entry.append(first.phrase) }
        entry.append(contentsOf: posturalCues)
        result.append(Cue(offset: 0, phrase: joinSentences(entry)))

        // Segments minutés suivants → à leur offset cumulé.
        var acc = timed.first?.seconds ?? 0
        for seg in timed.dropFirst() {
            result.append(Cue(offset: acc, phrase: ensureSentenceEnd(seg.phrase)))
            acc += seg.seconds
        }
        return result
    }

    private static func joinSentences(_ parts: [String]) -> String {
        parts.map(ensureSentenceEnd).joined(separator: " ")
    }

    private static func ensureSentenceEnd(_ s: String) -> String {
        let t = s.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let last = t.last else { return t }
        return ".!?".contains(last) ? t : t + "."
    }
}
