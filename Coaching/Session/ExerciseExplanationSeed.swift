// Coaching/Session/ExerciseExplanationSeed.swift
// Story 3.24b — catalogue manuel seed top 10 exos strength universels.
//
// Choix produit (Sophie 2026-05-24 décision (c) hybride) : ces 10 exos couvrent
// 80% des séances strength template-first sans aucun appel IA. Hit immédiat,
// zéro latence, FR + EN inline (pas dans Localizable.xcstrings pour ne pas
// polluer le fichier ; les phrases sont stables et ne bougent pas).
//
// Garde-fous EU MDR (cf `epic3_leon_legal_constraints.md`) :
//  - aucun "tu dois" / "il faut" prescriptif → consignes en suggestion ("place…",
//    "vise…", "garde…").
//  - pas de prescription médicale (douleur, blessure, articulation).
//  - 3 à 5 steps + 1 commonMistake max — pas de roman.
//
// Audit mots bannis : voir `ExerciseExplanationServiceTests.testSeedHasNoBannedTerms`.
import Foundation

public enum ExerciseExplanationSeed {

    /// Cherche un seed catalogue qui matche `exercise.originalName` ou
    /// `exercise.name` (normalisé minuscules + trim). Renvoie nil si pas trouvé
    /// → le service tombera sur cache disque, puis IA, puis .notAvailable.
    public static func explanation(
        for exercise: AdaptedExercise,
        language: String
    ) -> ExerciseExplanation? {
        let candidates = [exercise.originalName, exercise.name.canonical]
            .map { normalize($0) }

        // On essaie matcher chaque candidat — le premier hit gagne.
        for normalized in candidates {
            if let entry = entries.first(where: { $0.matches(normalized) }) {
                return entry.explanation(language: language)
            }
        }
        return nil
    }

    /// Normalise pour comparaison case-insensitive sans diacritiques et sans
    /// suffixes techniques `(pattern xxx)` / parenthèses tail.
    static func normalize(_ raw: String) -> String {
        let stripped = raw.replacingOccurrences(
            of: #"\s*\([^)]*\)\s*"#,
            with: " ",
            options: .regularExpression
        )
        return stripped
            .folding(options: .diacriticInsensitive, locale: Locale(identifier: "en_US"))
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Catalogue

    struct SeedEntry: Sendable {
        let matchers: [String]
        let fr: ExerciseExplanation
        let en: ExerciseExplanation

        func matches(_ normalized: String) -> Bool {
            matchers.contains { normalized.contains($0) }
        }

        func explanation(language: String) -> ExerciseExplanation? {
            switch language.lowercased() {
            case "fr": return fr
            case "en": return en
            default: return nil
            }
        }
    }

    /// Catalogue effectif = noyau strength manuel (11 exos, Story 3.24b) +
    /// contenu pédagogique généré par sport (Phase 1 pédagogie 2026-06-03,
    /// cf `ExerciseExplanationSeed+Generated.swift`). Le noyau est en TÊTE :
    /// en cas de matcher chevauchant, l'entrée la plus anciennement validée
    /// gagne (first-hit par ordre de tableau dans `explanation(for:)`).
    static var entries: [SeedEntry] {
        coreSeeds + generatedSeeds
    }

    static let coreSeeds: [SeedEntry] = [
        // 1. Développé couché — bench press
        SeedEntry(
            matchers: ["bench press", "developpe couche", "developpe-couche", "bench barre"],
            fr: ExerciseExplanation(
                steps: [
                    "Allonge-toi sur le banc, pieds bien à plat au sol.",
                    "Place tes mains sur la barre, écart un peu plus large que tes épaules.",
                    "Descends la barre vers le bas de ta poitrine en contrôlant.",
                    "Remonte la barre en poussant uniformément, coudes à environ 45°."
                ],
                equipment: ["Barre", "Banc plat", "Disques"],
                commonMistakes: "Évite de faire rebondir la barre sur ta poitrine — descends et remonte de manière contrôlée."
            ),
            en: ExerciseExplanation(
                steps: [
                    "Lie down on the bench, feet flat on the floor.",
                    "Grip the bar slightly wider than shoulder-width.",
                    "Lower the bar to your lower chest with control.",
                    "Press the bar back up evenly, elbows at about 45°."
                ],
                equipment: ["Barbell", "Flat bench", "Plates"],
                commonMistakes: "Avoid bouncing the bar off your chest — keep the descent and press controlled."
            )
        ),

        // 2. Développé couché haltères — DB bench press
        SeedEntry(
            matchers: ["db bench", "dumbbell bench", "halteres bench", "developpe haltere"],
            fr: ExerciseExplanation(
                steps: [
                    "Assieds-toi sur le banc, un haltère posé sur chaque cuisse.",
                    "Allonge-toi en hissant les haltères au-dessus de ta poitrine.",
                    "Descends les haltères de chaque côté jusqu'au niveau de ta poitrine.",
                    "Remonte en rapprochant légèrement les haltères, sans verrouiller les coudes."
                ],
                equipment: ["Paire d'haltères", "Banc plat"],
                commonMistakes: "Ne laisse pas les coudes s'évaser à 90° — garde-les à environ 45° du buste."
            ),
            en: ExerciseExplanation(
                steps: [
                    "Sit on the bench, one dumbbell on each thigh.",
                    "Lie back and hoist the dumbbells over your chest.",
                    "Lower the dumbbells to chest level on each side.",
                    "Press up, bringing the dumbbells slightly closer, without locking your elbows."
                ],
                equipment: ["Pair of dumbbells", "Flat bench"],
                commonMistakes: "Don't flare your elbows to 90° — keep them at about 45° from your torso."
            )
        ),

        // 3. Squat barre — back squat
        SeedEntry(
            matchers: ["back squat", "squat barre", "barbell squat"],
            fr: ExerciseExplanation(
                steps: [
                    "Place la barre sur le haut du dos (trapèzes), pas sur la nuque.",
                    "Pieds écartés à largeur d'épaules, pointes légèrement vers l'extérieur.",
                    "Descends en poussant les hanches en arrière, comme pour t'asseoir.",
                    "Garde la poitrine ouverte, descends au moins jusqu'à ce que les cuisses soient parallèles au sol.",
                    "Remonte en poussant le sol avec tes pieds."
                ],
                equipment: ["Barre", "Rack à squat", "Disques"],
                commonMistakes: "Garde les genoux dans l'axe des pieds — ne les laisse pas rentrer vers l'intérieur."
            ),
            en: ExerciseExplanation(
                steps: [
                    "Place the bar on your upper back (traps), not on your neck.",
                    "Feet shoulder-width apart, toes slightly turned out.",
                    "Lower by pushing your hips back, as if sitting down.",
                    "Keep your chest open, descend at least until thighs are parallel to the floor.",
                    "Stand back up by pushing the floor away with your feet."
                ],
                equipment: ["Barbell", "Squat rack", "Plates"],
                commonMistakes: "Keep your knees in line with your feet — don't let them cave inward."
            )
        ),

        // 4. Soulevé de terre — deadlift
        SeedEntry(
            matchers: ["deadlift", "souleve de terre", "souleve-de-terre"],
            fr: ExerciseExplanation(
                steps: [
                    "Place tes pieds sous la barre, écartés à largeur de hanches.",
                    "Penche-toi en gardant le dos plat, attrape la barre les mains à largeur d'épaules.",
                    "Pousse le sol avec tes pieds en gardant la barre proche de tes tibias.",
                    "Termine le mouvement debout, épaules en arrière, sans hyperextension lombaire."
                ],
                equipment: ["Barre", "Disques"],
                commonMistakes: "Garde le dos plat tout le long — pas d'arrondi lombaire à la descente."
            ),
            en: ExerciseExplanation(
                steps: [
                    "Place your feet under the bar, hip-width apart.",
                    "Hinge forward keeping a flat back, grip the bar shoulder-width.",
                    "Push the floor away with your feet, keeping the bar close to your shins.",
                    "Finish standing tall, shoulders back, without overextending the lower back."
                ],
                equipment: ["Barbell", "Plates"],
                commonMistakes: "Keep your back flat throughout — no rounding of the lower back on the way down."
            )
        ),

        // 5. Romanian deadlift — RDL
        SeedEntry(
            matchers: ["romanian deadlift", "rdl", "souleve de terre roumain"],
            fr: ExerciseExplanation(
                steps: [
                    "Debout, barre devant toi à largeur d'épaules.",
                    "Pousse les hanches en arrière en gardant les jambes presque tendues (genoux légèrement fléchis).",
                    "Descends la barre le long des jambes jusqu'à sentir un étirement à l'arrière des cuisses.",
                    "Remonte en poussant les hanches vers l'avant, dos plat."
                ],
                equipment: ["Barre", "Disques"],
                commonMistakes: "Pas de flexion des genoux pour aller plus bas — c'est un mouvement de hanche, pas de genou."
            ),
            en: ExerciseExplanation(
                steps: [
                    "Stand with the bar at shoulder-width grip.",
                    "Push your hips back keeping legs nearly straight (slight knee bend).",
                    "Lower the bar along your legs until you feel a stretch in your hamstrings.",
                    "Drive your hips forward to stand back up, flat back."
                ],
                equipment: ["Barbell", "Plates"],
                commonMistakes: "Don't bend your knees to go lower — this is a hip hinge, not a knee bend."
            )
        ),

        // 6. Overhead press — développé militaire
        SeedEntry(
            matchers: ["overhead press", "ohp", "developpe militaire", "shoulder press"],
            fr: ExerciseExplanation(
                steps: [
                    "Debout, pieds à largeur de hanches, barre à hauteur des clavicules.",
                    "Mains un peu plus larges que les épaules, coudes sous la barre.",
                    "Pousse la barre verticalement en serrant les fessiers et les abdos.",
                    "Termine bras tendus, barre au-dessus de la tête, sans cambrer le bas du dos."
                ],
                equipment: ["Barre", "Disques"],
                commonMistakes: "Évite la cambrure lombaire — gaine les abdos et serre les fessiers tout le long."
            ),
            en: ExerciseExplanation(
                steps: [
                    "Stand with feet hip-width, bar at collarbone height.",
                    "Hands slightly wider than shoulders, elbows under the bar.",
                    "Press the bar straight up while bracing glutes and abs.",
                    "Finish arms extended, bar overhead, without arching the lower back."
                ],
                equipment: ["Barbell", "Plates"],
                commonMistakes: "Avoid arching the lower back — keep your abs braced and glutes squeezed throughout."
            )
        ),

        // 7. Traction — pull-up / chin-up
        SeedEntry(
            matchers: ["pull-up", "pull up", "pullup", "chin-up", "chin up", "chinup", "traction"],
            fr: ExerciseExplanation(
                steps: [
                    "Suspends-toi à la barre, prise large (paumes vers l'avant) ou prise serrée (paumes vers toi).",
                    "Engage les omoplates en les abaissant, comme pour mettre tes coudes dans tes poches.",
                    "Tire vers le haut jusqu'à passer le menton au-dessus de la barre.",
                    "Redescends contrôlé, sans à-coups."
                ],
                equipment: ["Barre de traction"],
                commonMistakes: "Ne te balance pas — initie le mouvement avec les omoplates puis tire avec les bras."
            ),
            en: ExerciseExplanation(
                steps: [
                    "Hang from the bar, wide grip (palms forward) or close grip (palms toward you).",
                    "Engage your shoulder blades by pulling them down, as if putting elbows in pockets.",
                    "Pull up until your chin clears the bar.",
                    "Lower yourself with control, no swinging."
                ],
                equipment: ["Pull-up bar"],
                commonMistakes: "Don't kip or swing — initiate with the shoulder blades, then pull with your arms."
            )
        ),

        // 8. Bent-over row — rowing barre
        SeedEntry(
            matchers: ["bent-over row", "bent over row", "barbell row", "rowing barre", "row barre"],
            fr: ExerciseExplanation(
                steps: [
                    "Penche-toi en avant en gardant le dos plat, jambes légèrement fléchies.",
                    "Tiens la barre à largeur d'épaules, bras tendus vers le sol.",
                    "Tire la barre vers ton nombril en serrant les omoplates.",
                    "Redescends contrôlé sans laisser le dos s'arrondir."
                ],
                equipment: ["Barre", "Disques"],
                commonMistakes: "Garde le buste stable — ne te redresse pas pour aider à tirer la barre."
            ),
            en: ExerciseExplanation(
                steps: [
                    "Hinge forward keeping a flat back, knees slightly bent.",
                    "Grip the bar shoulder-width, arms extended toward the floor.",
                    "Pull the bar to your navel while squeezing your shoulder blades.",
                    "Lower with control without rounding your back."
                ],
                equipment: ["Barbell", "Plates"],
                commonMistakes: "Keep your torso stable — don't stand up to help pull the bar."
            )
        ),

        // 9. Fente — lunge
        SeedEntry(
            matchers: ["lunge", "fente", "split squat"],
            fr: ExerciseExplanation(
                steps: [
                    "Debout, pieds à largeur de hanches.",
                    "Fais un grand pas en avant en descendant le genou arrière vers le sol.",
                    "Descends jusqu'à former deux angles droits aux genoux.",
                    "Remonte en poussant avec le talon de la jambe avant."
                ],
                equipment: ["Aucun (poids du corps)", "Optionnel : haltères"],
                commonMistakes: "Le genou avant ne dépasse pas la pointe du pied — recule un peu si besoin."
            ),
            en: ExerciseExplanation(
                steps: [
                    "Stand with feet hip-width apart.",
                    "Take a large step forward, lowering the back knee toward the floor.",
                    "Descend until both knees form 90° angles.",
                    "Push back up through the front heel."
                ],
                equipment: ["None (bodyweight)", "Optional: dumbbells"],
                commonMistakes: "Don't let the front knee travel past the toes — step a bit further if needed."
            )
        ),

        // 10. Hip thrust — pont de hanches
        SeedEntry(
            matchers: ["hip thrust", "pont de hanches", "pont fessier", "glute bridge"],
            fr: ExerciseExplanation(
                steps: [
                    "Assieds-toi par terre, dos contre un banc bas (à hauteur d'omoplates).",
                    "Pieds à plat au sol, écartés largeur de hanches, genoux fléchis ~90°.",
                    "Pose la barre sur tes hanches (avec une mousse) ou monte sans charge.",
                    "Pousse avec les talons pour monter les hanches jusqu'à aligner épaules-hanches-genoux.",
                    "Serre les fessiers en haut, redescends contrôlé."
                ],
                equipment: ["Banc plat", "Optionnel : barre + mousse"],
                commonMistakes: "Ne cambre pas le bas du dos en haut — pousse avec les fessiers, pas les lombaires."
            ),
            en: ExerciseExplanation(
                steps: [
                    "Sit on the floor with your upper back against a low bench (at shoulder-blade height).",
                    "Feet flat on the floor, hip-width apart, knees bent ~90°.",
                    "Place a barbell on your hips (with a pad) or go bodyweight.",
                    "Drive through your heels to lift your hips until shoulders-hips-knees align.",
                    "Squeeze your glutes at the top, lower with control."
                ],
                equipment: ["Flat bench", "Optional: barbell + pad"],
                commonMistakes: "Don't arch your lower back at the top — drive with your glutes, not your lumbar spine."
            )
        ),

        // 11. Plank — gainage (bonus universel : couvre forearm plank + plank)
        SeedEntry(
            matchers: ["plank", "planche", "gainage", "forearm plank"],
            fr: ExerciseExplanation(
                steps: [
                    "Pose-toi sur tes avant-bras, coudes alignés sous les épaules.",
                    "Pieds à largeur de hanches, jambes tendues.",
                    "Aligne épaules-hanches-talons sur une seule ligne droite.",
                    "Serre fessiers et abdominaux, regarde au sol, respire calmement."
                ],
                equipment: ["Tapis (optionnel)"],
                commonMistakes: "Évite de laisser les hanches plonger ou monter trop haut — reste aligné."
            ),
            en: ExerciseExplanation(
                steps: [
                    "Get on your forearms, elbows aligned under your shoulders.",
                    "Feet hip-width apart, legs extended.",
                    "Align shoulders-hips-heels in a single straight line.",
                    "Squeeze glutes and abs, look down at the floor, breathe calmly."
                ],
                equipment: ["Mat (optional)"],
                commonMistakes: "Don't let your hips sag or pike too high — stay aligned."
            )
        ),
    ]
}
