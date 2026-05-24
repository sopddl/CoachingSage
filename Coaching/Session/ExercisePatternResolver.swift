// Coaching/Session/ExercisePatternResolver.swift
// Story 3.19 — résolution `AdaptedExercise.name` → `ExercisePattern`.
//
// Cascade déterministe (pure, 0 side effect) :
//   1. Regex multi-mots `\(pattern ([^)]+)\)` sur `name` — capture le pattern explicite.
//   2. Filtre patterns hebdo/structurels (J1/J3/J5, recommandé, complexité…) → fallback.
//   3. Table de normalisation explicite sur la capture (corpus 32 variantes audité).
//   4. Keyword match sur lemmes du `name` (squat, deadlift, pull-up, row, push-up…).
//   5. Sport fallback (running → endurance/interval/drills selon mots-clés).
//   6. Fallback ultime `.generic`.
//
// Corpus audit : `grep -rohE '\(pattern [^)]+\)' Templates/References Templates/Sources/.../Templates/`
// Mai 2026 → 32 variantes uniques (14 biomécaniques + ~18 hebdo/structurels).
import Foundation

public enum ExercisePatternResolver {

    /// Point d'entrée unique. Pure, deterministic.
    public static func resolve(_ exercise: AdaptedExercise, sportCode: String) -> ExercisePattern {
        let name = exercise.name

        // Étape 1 : capture regex multi-mots
        if let captured = capturedPatternToken(in: name) {
            // Étape 2 : filtre hebdo/structurel
            if isWeeklyOrStructuralPattern(captured) {
                // Tombe en étapes 4/5/6
            } else {
                // Étape 3 : table normalisation
                if let mapped = patternFromTable(captured) {
                    return mapped
                }
                // Capture inconnue (pattern biomécanique futur ?) — tombe en étapes 4/5/6
            }
        }

        // Étape 4 : keyword match sur lemmes name
        if let kw = patternFromKeyword(in: name) {
            return kw
        }

        // Étape 5 : sport fallback
        if let sf = patternFromSport(sportCode: sportCode, name: name) {
            return sf
        }

        // Étape 6 : fallback ultime
        return .generic
    }

    // MARK: - Étape 1 — Capture regex

    /// Regex multi-mots : capture tout le contenu entre parenthèses qui suit
    /// `pattern ` (espace ou `:`). Accents, tirets, espaces autorisés.
    private static let patternCaptureRegex: NSRegularExpression = {
        // `\(pattern[\s:]+([^)]+)\)` — capture group 1 = contenu sans parenthèses.
        // swiftlint:disable:next force_try
        return try! NSRegularExpression(pattern: #"\(pattern[\s:]+([^)]+)\)"#, options: [.caseInsensitive])
    }()

    private static func capturedPatternToken(in name: String) -> String? {
        let range = NSRange(name.startIndex..<name.endIndex, in: name)
        guard let match = patternCaptureRegex.firstMatch(in: name, range: range),
              match.numberOfRanges >= 2,
              let r = Range(match.range(at: 1), in: name) else {
            return nil
        }
        return String(name[r]).trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    // MARK: - Étape 2 — Filtre hebdo/structurel

    /// Vrai si la capture est un pattern de programmation/structurel (PAS biomécanique).
    /// Couvre les ~18 variantes corpus templates qui décrivent la cadence hebdo ou
    /// la complexité tactique.
    static func isWeeklyOrStructuralPattern(_ token: String) -> Bool {
        // J1 / J3 / J5, J1 run / J2 force, etc.
        if token.range(of: #"\bj\d"#, options: .regularExpression) != nil {
            return true
        }
        // "recommandé", "inchangé", "intentionnellement"
        if token.hasPrefix("recommandé")
            || token.hasPrefix("recommande") // ASCII fallback
            || token.contains("inchangé")
            || token.contains("intentionnellement") {
            return true
        }
        // Tactiques foot/tennis + structurels
        let structuralKeywords: [String] = [
            "complexité croissante",
            "complexite croissante",
            "in-in-out-out",
            "3 touches",
            "piège croisé",
            "piege croise",
            "condensé",
            "condense"
        ]
        return structuralKeywords.contains(where: { token.contains($0) })
    }

    // MARK: - Étape 3 — Table normalisation

    /// Table explicite construite à partir du corpus 32 variantes (audit 2026-05-22).
    /// Couvre les ~14 patterns biomécaniques + leurs variantes longues "— partie X".
    static func patternFromTable(_ token: String) -> ExercisePattern? {
        // Match exact d'abord (token déjà lowercased + trimmed)
        if let direct = exactTokenTable[token] {
            return direct
        }
        // Variantes longues "pull vertical — partie 1", "pull vertical — maintenu en cutback"
        // → split sur " — " et match sur la partie 1.
        let separators = [" — ", " - "]
        for sep in separators {
            if let range = token.range(of: sep) {
                let head = String(token[..<range.lowerBound])
                if let mapped = exactTokenTable[head] {
                    return mapped
                }
            }
        }
        // Fallback "contains" pour patterns longs additionnels
        if token.contains("pull vertical") { return .pullVertical }
        if token.contains("pull horizontal") { return .pullHorizontal }
        if token.contains("push vertical") { return .pushVertical }
        if token.contains("push horizontal") { return .pushHorizontal }
        if token.hasPrefix("squat") { return .squat }
        if token.hasPrefix("hinge") { return .hinge }
        return nil
    }

    private static let exactTokenTable: [String: ExercisePattern] = [
        // Squat
        "squat": .squat,
        "squat unilatéral": .squat,
        "squat unilateral": .squat,
        "squat + équilibre": .squat,
        "squat + equilibre": .squat,
        "lower": .squat, // lower body squat-dominant

        // Hinge
        "hinge": .hinge,
        "hinge hyp": .hinge,

        // Core (asymétrique = anti-rotation core work)
        "moteur asymétrique": .core,
        "moteur asymetrique": .core,

        // Push
        "push horizontal": .pushHorizontal,
        "push h": .pushHorizontal,
        "push vertical": .pushVertical,
        "push v": .pushVertical,

        // Pull
        "pull horizontal": .pullHorizontal,
        "pull h": .pullHorizontal,
        "pull vertical": .pullVertical,
        "pull v": .pullVertical,
        "pull v hyp": .pullVertical,
        "pull vertical alternatif": .pullVertical
    ]

    // MARK: - Étape 4 — Keyword match

    static func patternFromKeyword(in name: String) -> ExercisePattern? {
        let lower = name.lowercased()

        // Strength keywords (ordre = du plus spécifique au plus générique)
        if matchesAny(lower, ["deadlift", "rdl", "soulevé de terre", "souleve de terre"]) {
            return .hinge
        }
        if matchesAny(lower, ["pull-up", "pullup", "chin-up", "chinup", "tirage vertical", "tirage nuque", "traction"]) {
            return .pullVertical
        }
        if matchesAny(lower, ["row", "rameur", "tirage horizontal", "tirage bûcheron", "tirage bucheron"]) {
            return .pullHorizontal
        }
        if matchesAny(lower, ["overhead", "développé militaire", "developpe militaire", "développé épaule", "developpe epaule", "shoulder press"]) {
            return .pushVertical
        }
        if matchesAny(lower, ["push-up", "pushup", "pompe", "bench", "développé couché", "developpe couche"]) {
            return .pushHorizontal
        }
        if matchesAny(lower, ["lunge", "fente"]) {
            return .lunge
        }
        if matchesAny(lower, ["plank", "gainage", "crunch", "abs", "hollow"]) {
            return .core
        }
        if matchesAny(lower, ["jump", "burpee", "bondiss", "saut", "box jump"]) {
            return .plyo
        }
        if matchesAny(lower, ["étirement", "etirement", "stretch", "mobility", "mobilité", "mobilite"]) {
            return .mobility
        }
        // Squat en dernier (mot court qui pourrait matcher accidentellement)
        if matchesAny(lower, ["squat", "goblet"]) {
            return .squat
        }
        return nil
    }

    private static func matchesAny(_ haystack: String, _ needles: [String]) -> Bool {
        return needles.contains(where: { haystack.contains($0) })
    }

    // MARK: - Étape 5 — Sport fallback

    static func patternFromSport(sportCode: String, name: String) -> ExercisePattern? {
        let lower = name.lowercased()
        switch sportCode {
        case "running":
            if matchesAny(lower, ["interval", "fractionné", "fractionne", "vo2", "série", "serie", "400", "800", "tempo"]) {
                return .runInterval
            }
            if matchesAny(lower, ["drill", "gammes", "stride", "montée", "montee", "skipping", "talon-fesse", "talons fesses"]) {
                return .runDrills
            }
            return .runEndurance
        case "swimming":
            if matchesAny(lower, ["drill", "technique", "catch", "6-3-6", "rattrapé", "rattrape", "éducatif", "educatif"]) {
                return .swimDrill
            }
            return .swimEndurance
        case "cycling":
            if matchesAny(lower, ["interval", "fractionné", "fractionne", "sfr", "vo2", "seuil"]) {
                return .cycleInterval
            }
            return .cycleEndurance
        case "yoga":
            // Toute pose yoga tombe sur `.yoga` ombrelle. Le dispatch fin
            // (chien tête en bas, guerrier, etc.) se fait dans
            // `YogaIllustration` via détection keyword sur `exerciseName`.
            return .yoga
        default:
            return nil
        }
    }
}
