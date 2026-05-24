// Coaching/Glossary/GlossaryMatcher.swift
// Story 3.17 Phase 1 — moteur de détection multi-occurrences pour rendu inline
// glossaire. Trouve TOUS les termes connus dans un texte (notes exercices, warmup,
// cooldown, theme semaine), avec word boundaries et priorité longest-first.
//
// Cas couverts :
// - Détection case-insensitive, préservation de la casse originale.
// - Word boundaries non-alphanumériques (point, virgule, espace, début/fin string)
//   — "rpe" matche dans "RPE 7-8" ou "rpe:" mais PAS dans "scrapped" / "supercrepe".
// - Non-overlapping : "Daniels-T pace" ne matche QUE Daniels-T, pas tempo ni
//   threshold (longest-first puis order-of-appearance).
// - Acronymes Z1-Z5 / EN1-EN3 matchent sur token complet seulement.
import Foundation

public struct GlossaryMatch: Equatable, Sendable {
    public let range: Range<String.Index>
    public let entry: GlossaryEntry
    public let matchedSubstring: String

    public init(range: Range<String.Index>, entry: GlossaryEntry, matchedSubstring: String) {
        self.range = range
        self.entry = entry
        self.matchedSubstring = matchedSubstring
    }
}

extension Glossary {
    /// Patterns littéraux à matcher → entry id. Ordre dans le tableau = priorité
    /// d'évaluation par longest-first (les patterns plus longs sont essayés
    /// d'abord — voir `sortedPatterns`). Le détecteur règle ensuite le non-overlap.
    ///
    /// Convention : utiliser des minuscules (la détection est case-insensitive).
    /// Les patterns avec tirets, points ou espaces matchent littéralement (modulo
    /// la casse). Les boundaries non-alphanum sont gérées en amont.
    nonisolated(unsafe) static let detectionPatterns: [(pattern: String, id: String)] = [
        // Daniels — patterns 9 chars, longest-first
        ("daniels-e", "daniels.e"),
        ("daniels-m", "daniels.m"),
        ("daniels-t", "daniels.t"),
        ("daniels-i", "daniels.i"),
        ("daniels-r", "daniels.r"),
        // VO2max — variants
        ("vo2 max", "vo2max"),
        ("vo2max", "vo2max"),
        // Sweet spot
        ("sweet-spot", "sweetspot"),
        ("sweet spot", "sweetspot"),
        ("sweetspot", "sweetspot"),
        // Push-off variants
        ("push-off", "pushoff"),
        ("push off", "pushoff"),
        // Protocoles (4-6 chars)
        ("plyometric", "plyometric"),
        ("hypertrophy", "hypertrophy"),
        ("plyometrics", "plyometric"),
        ("hypertrophic", "hypertrophy"),
        ("plyo", "plyometric"),
        // Plank / planche (Story 3.19) — variante latérale gérée via "side plank"
        ("side plank", "plank"),
        ("planche", "plank"),
        ("plank", "plank"),
        // Drill / éducatif (Story 3.19 Jalon 2)
        ("éducatif", "drill"),
        ("educatif", "drill"),
        ("drills", "drill"),
        ("drill", "drill"),
        ("fartlek", "fartlek"),
        ("tabata", "tabata"),
        ("amrap", "amrap"),
        ("emom", "emom"),
        // Race pace patterns
        ("5k-pace", "race.pace"),
        ("10k-pace", "race.pace"),
        ("race-pace", "race.pace"),
        // CSS / FTP / HMP / VDOT
        ("css", "css"),
        ("ftp", "ftp"),
        ("hmp", "hmp"),
        ("vdot", "vdot"),
        // Multi-sport génériques (plus courts)
        ("threshold", "threshold"),
        ("intervals", "intervals"),
        ("interval", "intervals"),
        ("cadence", "cadence"),
        ("strides", "strides"),
        ("stride", "strides"),
        ("lactate", "lactate"),
        ("lactic", "lactate"),
        ("tempo", "tempo"),
        // Effort (3 chars — risqué : need strict word boundary)
        ("rpe", "rpe"),
        ("1rm", "1rm"),
        // Story 3.24a — strength + mobilité (test simu Sophie 2026-05-24)
        // Multi-mots d'abord (longest-first via sortedPatterns)
        ("shoulder dislocations", "dislocation"),
        ("mobilité thoracique", "thoracic"),
        ("thoracic extension", "thoracic"),
        ("thoracic mobility", "thoracic"),
        ("thoracic rotation", "thoracic"),
        ("t-spine", "thoracic"),
        ("t spine", "thoracic"),
        ("tspine", "thoracic"),
        ("reps in reserve", "rir"),
        ("band pull apart", "bandpullapart"),
        ("dislocations", "dislocation"),
        ("répétitions", "reps"),
        ("pull apart", "bandpullapart"),
        ("barre vide", "barrevide"),
        ("empty bar", "barrevide"),
        ("scapular", "scapular"),
        ("ramp-up", "rampup"),
        ("ramp up", "rampup"),
        ("rampup", "rampup"),
        ("cat-cow", "catcow"),
        ("cat cow", "catcow"),
        ("reps", "reps"),
        ("cars", "cars"),
        ("rir", "rir"),
        // Acronymes zones (Z1-Z5, EN1-EN3) gérés par regex spécial, pas via cette liste.
    ]

    /// Cache du tri par longueur décroissante. Recalculé une fois.
    nonisolated(unsafe) private static let sortedPatterns: [(pattern: String, id: String)] = {
        detectionPatterns.sorted { lhs, rhs in lhs.pattern.count > rhs.pattern.count }
    }()

    /// Cache id → entry pour résolution rapide.
    nonisolated(unsafe) private static let entriesById: [String: GlossaryEntry] = {
        Dictionary(uniqueKeysWithValues: entries.map { ($0.id, $0) })
    }()

    /// Détecte toutes les occurrences glossaire dans `text`. Renvoie des matches
    /// non-overlappants, ordonnés par position dans le texte.
    ///
    /// - Parameter text: texte source (notes exercice, warmup, cooldown, etc.)
    /// - Returns: tableau de `GlossaryMatch`, possiblement vide.
    public static func matches(in text: String) -> [GlossaryMatch] {
        guard !text.isEmpty else { return [] }
        let lower = text.lowercased()

        // 1. Collecte tous les matches candidats (pattern + range).
        var candidates: [(range: Range<String.Index>, entry: GlossaryEntry, matched: String)] = []

        // 1a. Patterns littéraux longest-first.
        for (pattern, id) in sortedPatterns {
            guard let entry = entriesById[id] else { continue }
            var searchStart = lower.startIndex
            while searchStart < lower.endIndex,
                  let foundRange = lower.range(of: pattern, range: searchStart..<lower.endIndex) {
                if hasWordBoundaries(in: lower, range: foundRange) {
                    let originalSubstring = String(text[foundRange])
                    candidates.append((range: foundRange, entry: entry, matched: originalSubstring))
                }
                searchStart = foundRange.upperBound
            }
        }

        // 1b. Zones FC Z1-Z5 (token boundary).
        if let zonesEntry = entriesById["zones"] {
            candidates.append(contentsOf: matchZoneTokens(lower: lower, original: text)
                .map { (range: $0.range, entry: zonesEntry, matched: $0.matched) })
        }

        // 1c. Natation EN1/EN2/EN3 (token boundary).
        if let enEntry = entriesById["en"] {
            candidates.append(contentsOf: matchENTokens(lower: lower, original: text)
                .map { (range: $0.range, entry: enEntry, matched: $0.matched) })
        }

        // 2. Résolution overlap : longest-first puis order-of-appearance.
        let resolved = resolveOverlaps(candidates: candidates)

        // 3. Conversion en GlossaryMatch et tri par position.
        return resolved
            .sorted { $0.range.lowerBound < $1.range.lowerBound }
            .map { GlossaryMatch(range: $0.range, entry: $0.entry, matchedSubstring: $0.matched) }
    }

    // MARK: - Helpers

    /// Vérifie que les caractères avant et après la range sont des non-alphanum
    /// ASCII (espaces, ponctuation, début/fin string). Tirets et apostrophes sont
    /// considérés comme boundaries pour permettre "daniels-t" / "rpe-7-8".
    private static func hasWordBoundaries(in text: String, range: Range<String.Index>) -> Bool {
        let before: Character? = range.lowerBound > text.startIndex
            ? text[text.index(before: range.lowerBound)]
            : nil
        let after: Character? = range.upperBound < text.endIndex
            ? text[range.upperBound]
            : nil

        return isBoundary(before) && isBoundary(after)
    }

    private static func isBoundary(_ char: Character?) -> Bool {
        guard let char else { return true }
        // Boundary = non-alphanumérique ASCII (espace, ponctuation, retour ligne, etc.)
        // Pas les apostrophes/tirets internes — mais Daniels-T est en pattern direct,
        // donc le `-` interne est dans la lookup string elle-même.
        if char.isLetter || char.isNumber { return false }
        return true
    }

    /// Matche les tokens Z1-Z5 entourés de boundaries. "Z2", "z3-cardiac", "Z 1"
    /// non matché ("Z 1" = pas continu).
    private static func matchZoneTokens(
        lower: String,
        original: String
    ) -> [(range: Range<String.Index>, matched: String)] {
        var results: [(range: Range<String.Index>, matched: String)] = []
        var i = lower.startIndex
        while i < lower.endIndex {
            if lower[i] == "z", i < lower.index(before: lower.endIndex) {
                let next = lower.index(after: i)
                if let digit = lower[next].asciiValue,
                   digit >= UInt8(ascii: "1") && digit <= UInt8(ascii: "5") {
                    let endIdx = lower.index(after: next)
                    let range = i..<endIdx
                    if hasWordBoundaries(in: lower, range: range) {
                        let matched = String(original[range])
                        results.append((range: range, matched: matched))
                    }
                    i = endIdx
                    continue
                }
            }
            i = lower.index(after: i)
        }
        return results
    }

    /// Matche les tokens EN1/EN2/EN3 entourés de boundaries.
    private static func matchENTokens(
        lower: String,
        original: String
    ) -> [(range: Range<String.Index>, matched: String)] {
        var results: [(range: Range<String.Index>, matched: String)] = []
        var searchStart = lower.startIndex
        while searchStart < lower.endIndex,
              let foundRange = lower.range(of: "en", range: searchStart..<lower.endIndex) {
            let afterEN = foundRange.upperBound
            // Doit être suivi de 1, 2 ou 3 puis boundary.
            if afterEN < lower.endIndex,
               let digit = lower[afterEN].asciiValue,
               digit >= UInt8(ascii: "1") && digit <= UInt8(ascii: "3") {
                let fullEndIdx = lower.index(after: afterEN)
                let fullRange = foundRange.lowerBound..<fullEndIdx
                if hasWordBoundaries(in: lower, range: fullRange) {
                    let matched = String(original[fullRange])
                    results.append((range: fullRange, matched: matched))
                    searchStart = fullEndIdx
                    continue
                }
            }
            searchStart = foundRange.upperBound
        }
        return results
    }

    /// Résolution overlap longest-first : pour chaque paire de candidats qui se
    /// chevauchent, garde le plus long (départage par position si égalité). On
    /// utilise `matched.count` (Character count) plutôt que les utf16Offset sur
    /// ranges flottants — équivalent fonctionnel suffisant.
    private static func resolveOverlaps(
        candidates: [(range: Range<String.Index>, entry: GlossaryEntry, matched: String)]
    ) -> [(range: Range<String.Index>, entry: GlossaryEntry, matched: String)] {
        let sortedByLength = candidates.sorted { lhs, rhs in
            if lhs.matched.count != rhs.matched.count { return lhs.matched.count > rhs.matched.count }
            return lhs.range.lowerBound < rhs.range.lowerBound
        }

        var kept: [(range: Range<String.Index>, entry: GlossaryEntry, matched: String)] = []
        for candidate in sortedByLength {
            let overlaps = kept.contains { existing in
                rangesOverlap(candidate.range, existing.range)
            }
            if !overlaps {
                kept.append(candidate)
            }
        }
        return kept
    }

    private static func rangesOverlap(_ a: Range<String.Index>, _ b: Range<String.Index>) -> Bool {
        return a.lowerBound < b.upperBound && b.lowerBound < a.upperBound
    }
}
