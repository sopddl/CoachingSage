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
        // Résolution de pattern = matching sur la clé stable (nom FR technique + suffixe
        // `(pattern xxx)` propre au FR). `originalName` (= stableMatchKey) reste figé même
        // quand `name.fr` est vulgarisé/traduit (i18n B2), pour ne pas casser les regex.
        let name = exercise.originalName

        // Étape 0 — overrides haute-confiance (revue images muscu 2026-06-08). Corrigent des
        // MISTAGS template « (pattern xxx) » qui contredisent le geste réel, SANS toucher au
        // match_key stable (fix aussi les programmes en cours) :
        //   • une « fente » / « lunge » est toujours un lunge (taggée à tort « squat unilatéral »)
        //   • un « hip thrust » est toujours un hip thrust (taggé à tort « hinge » sur les séances débutant)
        let lowerName = name.lowercased()
        if lowerName.contains("fente") || lowerName.contains("lunge") { return .lunge }
        if lowerName.contains("hip thrust") || lowerName.contains("pont fessier") { return .hipThrust }
        // Y-raise = mouvement de la famille Y-T-W (épaules), taggé à tort « pull vertical »
        // → ne doit PAS rendre le dessin de traction.
        if lowerName.contains("y-raise") || lowerName.contains("y raise") { return .ytwActivation }
        // Revue dessins 2026-06-08 : 4 dessins dédiés CRÉÉS → on route vers eux (avant : générique).
        if lowerName.contains("pullover") { return .pullover }
        if lowerName.contains("overhead") && lowerName.contains("triceps") { return .tricepsOverhead }
        if lowerName.contains("woodchopper") || lowerName.contains("wood chopper") { return .woodchopper }
        if lowerName.contains("hanging leg raise") || lowerName.contains("leg raise")
            || lowerName.contains("relevé de jambe") || lowerName.contains("releve de jambe") { return .hangingLegRaise }

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
        // Story 3.23 Tier 1 Jalon 2 — pattern dédié `.hipThrust` (créé Jalon 2).
        // Mapping initial Jalon 1 vers `.hinge` annulé.
        if matchesAny(lower, ["hip thrust", "glute bridge", "pont fessier", "pont glute"]) {
            return .hipThrust
        }
        // Story 3.23 Tier 1 Jalon 2 — `.calfRaise` (228 occ × 23 templates).
        // Détection mollets / calf / pointe / extension cheville.
        if matchesAny(lower, ["calf raise", "calf-raise", "calves", "mollets", "extension cheville", "pointe pied", "demi-pointe"]) {
            return .calfRaise
        }
        if matchesAny(lower, ["deadlift", "rdl", "soulevé de terre", "souleve de terre"]) {
            return .hinge
        }
        if matchesAny(lower, ["pull-up", "pullup", "chin-up", "chinup", "tirage vertical", "tirage nuque", "traction",
                              "lat pulldown", "pulldown", "pull-down", "lat pull"]) {
            return .pullVertical
        }
        if matchesAny(lower, ["row", "rameur", "tirage horizontal", "tirage bûcheron", "tirage bucheron"]) {
            return .pullHorizontal
        }
        // Revue images muscu 2026-06-08 : « triceps » exclu ici sinon « Overhead DB
        // triceps extension » tombe sur le dessin OHP (développé épaules) au lieu du
        // triceps (cf keyword triceps plus bas).
        if matchesAny(lower, ["overhead", "développé militaire", "developpe militaire", "développé épaule", "developpe epaule", "shoulder press"])
            && !lower.contains("triceps") {
            return .pushVertical
        }
        if matchesAny(lower, ["push-up", "pushup", "pompe", "bench", "développé couché", "developpe couche", "dips", "dip lesté", "dip leste"]) {
            return .pushHorizontal
        }
        if matchesAny(lower, ["lunge", "fente"]) {
            return .lunge
        }
        // Story 3.23 Lot 3 — Bird-dog AVANT plank (mot "dog" peut être ambigu mais
        // "bird-dog" est unique). Pattern dédié pour gainage 4 pattes diagonal.
        if matchesAny(lower, ["bird-dog", "bird dog", "birddog", "chien d'arrêt", "chien d'arret"]) {
            return .birdDog
        }
        // Story 3.23 Lot 3 — Forearm plank avant plank générique (low plank avant-bras).
        if matchesAny(lower, ["forearm plank", "plank avant-bras", "plank avant bras",
                              "planche avant-bras", "planche avant bras", "low plank"]) {
            return .forearmPlank
        }
        if matchesAny(lower, ["plank", "planche", "gainage", "crunch", "abs", "hollow"]) {
            return .core
        }
        // Story 3.23 Lot 3 — Y-T-W shoulder activation (rotator cuff prone)
        if matchesAny(lower, ["y-t-w", "ytw", "y t w", "yt w", "shoulder activation",
                              "activation épaule", "activation epaule", "rotator cuff",
                              "external rotation", "rotation externe"]) {
            return .ytwActivation
        }
        // Story 3.23 Lot 3 — Pallof press câble (anti-rotation)
        if matchesAny(lower, ["pallof", "pallof press", "anti-rotation", "anti rotation"]) {
            return .pallofPress
        }
        // Story 3.23 Lot 3 — Nordic curl (excentrique ischio)
        if matchesAny(lower, ["nordic", "nordic curl", "nordic hamstring",
                              "ischio nordique", "ischio nordic"]) {
            return .nordicCurl
        }
        if matchesAny(lower, ["jump", "burpee", "bondiss", "saut", "box jump", "lateral bound", "bound latéral"]) {
            return .plyo
        }
        // Story 3.23 Lot 5 — Foam rolling AVANT mobility générique
        // (pattern dédié avec rendu rouleau orange).
        if matchesAny(lower, ["foam roll", "foam rolling", "rouleau mousse", "rouleau massage"]) {
            return .foamRolling
        }
        // Story 3.23 — fix bug "Foam rolling tombe .generic" : ajout des keywords
        // "foam" / "rolling" / "rouleau" pour mapper sur `.mobility`.
        if matchesAny(lower, ["étirement", "etirement", "stretch", "mobility", "mobilité", "mobilite", "foam", "rolling", "rouleau"]) {
            return .mobility
        }
        // Story 3.23 Lot 5 — patterns moyenne fréquence
        if matchesAny(lower, ["dead bug", "dead-bug", "deadbug"]) {
            return .deadBug
        }
        if matchesAny(lower, ["clamshell", "coquillage", "clam shell"]) {
            return .clamshell
        }
        if matchesAny(lower, ["kb swing", "kettlebell swing", "swing kettlebell", "russian swing"]) {
            return .kbSwing
        }
        if matchesAny(lower, ["face pull", "face-pull", "facepull"]) {
            return .facePull
        }
        if matchesAny(lower, ["biceps curl", "curl biceps", "curl haltères", "curl halteres", "biceps haltère", "biceps haltere",
                              "db curl", "dumbbell curl", "hammer curl"]) {
            return .bicepsCurl
        }
        // Story 3.23 Lot 7 — Triceps pushdown câble. Revue 2026-06-08 : capter aussi
        // « overhead triceps » / « triceps extension » (sinon → OHP), faute de pattern
        // d'extension dédié — le dessin triceps reste le plus proche.
        if matchesAny(lower, ["triceps pushdown", "triceps push-down", "pushdown triceps",
                              "extension triceps", "triceps extension", "overhead triceps", "triceps overhead",
                              "db triceps", "triceps câble", "triceps cable", "triceps"]) {
            return .tricepsPushdown
        }
        // Story 3.23 Lot 7 — Lateral raises haltères
        if matchesAny(lower, ["lateral raise", "lateral raises", "side raise", "side raises",
                              "élévation latérale", "elevation laterale",
                              "écarté épaule", "ecarte epaule"]) {
            return .lateralRaises
        }
        // Wall sit = squat isométrique dos au mur (running/triathlon/hiking S&C).
        if matchesAny(lower, ["wall sit", "wall-sit", "chaise isométrique", "chaise isometrique"]) {
            return .squat
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
