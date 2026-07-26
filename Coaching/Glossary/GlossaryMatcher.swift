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
        // Audit contenu swimming (2026-07-26) — "EVF" jamais traduit ni glossé en EN/ES.
        ("early vertical forearm", "evf"),
        ("evf", "evf"),
        // Chantier compréhensibilité cycling (2026-06-25) — FCmax rendue tappable (FR/EN/ES).
        ("fréquence cardiaque maximale", "fcmax"),
        ("fréquence cardiaque max", "fcmax"),
        ("frecuencia cardíaca máxima", "fcmax"),
        ("max hr", "fcmax"),
        ("fcmáx", "fcmax"),
        ("fcmax", "fcmax"),
        ("fc max", "fcmax"),
        // Chantier compréhensibilité running (2026-06-25) — jargon orphelin rendu tappable.
        ("vma", "vma"),
        ("seuils", "seuil"),
        ("seuil", "seuil"),
        ("affûtage", "affutage"),
        ("affutage", "affutage"),
        ("aérobie", "aerobie"),
        ("aerobie", "aerobie"),
        ("excentriques", "excentrique"),
        ("excentrique", "excentrique"),
        // Multi-sport génériques (plus courts)
        ("threshold", "threshold"),
        ("intervals", "intervals"),
        ("interval", "intervals"),
        ("cadence", "cadence"),
        // Audit contenu cycling (2026-07-26) — "braquet" jamais glossé.
        ("braquets", "braquet"),
        ("braquet", "braquet"),
        ("strides", "strides"),
        ("stride", "strides"),
        // Chantier compréhensibilité running (2026-07-26) — "lignes droites" jamais
        // tappable malgré une définition FR déjà en place (glossary.strides.title).
        // PAS de singulier "ligne droite" : 25 faux positifs football (conduite de
        // balle / course technique "très lente", sans rapport avec le stride
        // athlétique) — vérifié par review, cf commentaire clôture 2026-07-26.
        ("lignes droites", "strides"),
        ("lignes", "strides"),
        ("lactate", "lactate"),
        ("lactic", "lactate"),
        ("tempo", "tempo"),
        // Effort (3 chars — risqué : need strict word boundary)
        ("rpe", "rpe"),
        ("1rm", "1rm"),
        // Audit contenu strengthTraining (2026-07-26) — "TM" (Training Max) jamais glossé
        // (2 chars, risqué : boundary stricte requise, cf "atm"/"team" non concernés car
        // la lettre adjacente est alphanumérique de part et d'autre).
        ("tm", "tm"),
        // Audit contenu strengthTraining (2026-07-26) — "5/3/1" (protocole Wendler, gardé
        // tel quel dans les 3 langues) jamais glossé. Les "/" internes ne comptent pas pour
        // la boundary (seuls les caractères avant "5" et après le dernier "1" comptent) ;
        // matche aussi "5/3/1+" (le "+" est une boundary valide).
        ("5/3/1", "531"),
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
        // Audit contenu yoga (2026-07-26) — variante FR "scapulaire" jamais reconnue
        // (seul l'EN "scapular" matchait), y compris sur le plan beginner.
        ("scapulaire", "scapular"),
        ("ramp-up", "rampup"),
        ("ramp up", "rampup"),
        ("rampup", "rampup"),
        ("cat-cow", "catcow"),
        ("cat cow", "catcow"),
        ("reps", "reps"),
        ("cars", "cars"),
        ("rir", "rir"),
        // Revue comité 2026-06-06 — jargon échauffement (glutes / band / mobilité / récup).
        // Multi-mots / longs d'abord (le tri global longest-first gère l'ordre réel).
        ("resistance band", "band"),
        ("récupération", "recovery"),
        ("recuperation", "recovery"),
        ("élastique", "band"),
        ("elastique", "band"),
        ("mini-band", "band"),
        ("mini band", "band"),
        ("recovery", "recovery"),
        ("fessiers", "glutes"),
        ("mobilité", "mobility"),
        ("mobilite", "mobility"),
        ("mobility", "mobility"),
        ("glutes", "glutes"),
        ("glute", "glutes"),
        ("récup", "recovery"),
        ("recup", "recovery"),
        ("band", "band"),
        // Story 3.26 Phase A — 27 termes sport-spécifiques (yoga / tennis / football / hiking / triathlon / HIIT).
        // Multi-mots d'abord (longest-first via sortedPatterns).
        // Yoga
        ("salutation au soleil", "yoga.suryanamaskar"),
        ("sun salutation", "yoga.suryanamaskar"),
        ("surya namaskar", "yoga.suryanamaskar"),
        ("suryanamaskar", "yoga.suryanamaskar"),
        ("shavasana", "yoga.savasana"),
        ("savasana", "yoga.savasana"),
        ("pranayama", "yoga.pranayama"),
        ("prânâyâma", "yoga.pranayama"),
        ("ujjayi", "yoga.pranayama"),
        ("vinyasa", "yoga.vinyasa"),
        ("drishti", "yoga.drishti"),
        ("bandhas", "yoga.bandha"),
        ("bandha", "yoga.bandha"),
        ("asanas", "yoga.asana"),
        ("asana", "yoga.asana"),
        ("mudras", "yoga.mudra"),
        ("mudra", "yoga.mudra"),
        // Tennis
        ("split-step", "tennis.splitstep"),
        ("split step", "tennis.splitstep"),
        ("splitstep", "tennis.splitstep"),
        ("kick serve", "tennis.kickserve"),
        ("kick-serve", "tennis.kickserve"),
        ("kickserve", "tennis.kickserve"),
        ("service kické", "tennis.kickserve"),
        ("jeu de jambes", "tennis.footwork"),
        ("footwork", "tennis.footwork"),
        ("topspin", "tennis.topspin"),
        ("lifté", "tennis.topspin"),
        ("slice", "tennis.slice"),
        // Football
        ("repeated sprints", "football.sprintrepete"),
        ("sprints répétés", "football.sprintrepete"),
        ("sprint répété", "football.sprintrepete"),
        ("one-touch", "football.unetouche"),
        ("one touch", "football.unetouche"),
        ("une touche", "football.unetouche"),
        ("transition", "football.transition"),
        ("rsa", "football.rsa"),
        ("fifa 11+", "football.fifa11plus"),
        ("fifa 11", "football.fifa11plus"),
        // Hiking
        ("dénivelé positif", "hiking.denivele"),
        ("dénivelé", "hiking.denivele"),
        ("denivelé", "hiking.denivele"),
        ("denivele", "hiking.denivele"),
        ("total ascent", "hiking.denivele"),
        ("elevation gain", "hiking.elevation"),
        ("élévation", "hiking.elevation"),
        ("elevation", "hiking.elevation"),
        ("switchbacks", "hiking.switchback"),
        ("switchback", "hiking.switchback"),
        ("lacets", "hiking.switchback"),
        ("lacet", "hiking.switchback"),
        ("allure terrain", "hiking.terrainpace"),
        ("terrain pace", "hiking.terrainpace"),
        // Triathlon (T1/T2 patterns littéraux avec boundary check — pas besoin de regex spéciale)
        ("brick session", "triathlon.brick"),
        ("brick workout", "triathlon.brick"),
        ("brick", "triathlon.brick"),
        ("t1", "triathlon.t1"),
        ("t2", "triathlon.t2"),
        // HIIT
        ("micro-intervalles", "hiit.microinterval"),
        ("micro intervalles", "hiit.microinterval"),
        ("microintervalles", "hiit.microinterval"),
        ("micro-intervalle", "hiit.microinterval"),
        ("micro intervalle", "hiit.microinterval"),
        ("microintervalle", "hiit.microinterval"),
        ("micro-intervals", "hiit.microinterval"),
        ("micro intervals", "hiit.microinterval"),
        ("micro-interval", "hiit.microinterval"),
        ("microinterval", "hiit.microinterval"),
        ("ratio effort/récup", "hiit.workrest"),
        ("work-rest", "hiit.workrest"),
        ("work rest", "hiit.workrest"),
        ("work:rest", "hiit.workrest"),
        ("epoc", "hiit.epoc"),
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
