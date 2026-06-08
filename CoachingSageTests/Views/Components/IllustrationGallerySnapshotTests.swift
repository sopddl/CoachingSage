// CoachingSageTests/Views/Components/IllustrationGallerySnapshotTests.swift
// Revue images muscu 2026-06-08 (demande Sophie) : génère une galerie PNG de TOUTES
// les illustrations muscu telles que l'utilisateur les voit (pipeline réel
// ExercisePatternResolver.resolve → ExercisePatternIllustration, comme
// SessionFocusView.exerciseVisual). Sert (1) de source d'images pour le HTML de revue
// image↔texte, (2) de filet régression snapshot sur les dessins.
//
// 1ère exécution = record (crée les .png sous __Snapshots__/ et "échoue"). Relancer
// ensuite = comparaison. Pour re-record après refonte d'un dessin : supprimer le .png.
import XCTest
import SwiftUI
import SnapshotTesting
import TemplateModel
@testable import CoachingSage

@MainActor
final class IllustrationGallerySnapshotTests: XCTestCase {

    /// (slug fichier, nom affiché, match_key réel du template) — couvre tous les
    /// patterns muscu + variantes + les cas de mismatch suspectés (revue Explore).
    // match_key = valeurs RÉELLES extraites des 4 templates (faithful : le suffixe
    // « (pattern xxx) » est exploité par le resolver comme en prod).
    private let gallery: [(String, String, String)] = [
        ("squat-bodyweight", "Squat poids du corps", "Squat poids du corps (pattern squat)"),
        ("squat-back-barbell", "Back Squat (barre)", "Back Squat (barre)"),
        ("squat-goblet", "Goblet Squat", "Goblet Squat (pattern squat)"),
        ("squat-bulgarian", "Bulgarian Split Squat (haltères)", "Bulgarian Split Squat (haltères)"),
        ("lunge", "Fentes haltères", "Fentes haltères (pattern squat unilatéral)"),
        ("walking-lunge", "Walking lunge haltères", "Walking lunge haltères"),
        ("hinge-deadlift", "Deadlift conventionnel", "Deadlift conventionnel (barre)"),
        ("hinge-rdl-dumbbell", "Romanian Deadlift haltères", "Romanian Deadlift haltères (pattern hinge)"),
        ("hipthrust-hinge-tagged", "Hip Thrust au sol (taggé pattern hinge)", "Hip Thrust au sol poids du corps (pattern hinge)"),
        ("hipthrust-barbell", "Hip thrust barre", "Hip thrust barre"),
        ("glutebridge", "Glute Bridge (barre)", "Glute Bridge (barre)"),
        ("pushh-pushup", "Pompes", "Pompes complètes (pattern push horizontal)"),
        ("pushh-bench-barbell", "Bench Press (barre)", "Bench Press (barre)"),
        ("pushh-bench-dumbbell", "Incline DB bench press 30°", "Incline DB bench press 30°"),
        ("pushh-dips", "Dips lestés", "Dips lestés"),
        ("pushv-barbell", "Overhead Press (barre)", "Overhead Press (barre)"),
        ("pushv-arnold", "Arnold Press assis", "Arnold Press assis (pattern push vertical)"),
        ("pullh-row", "Dumbbell Row", "Dumbbell Row (pattern pull horizontal)"),
        ("pullh-cablerow", "Cable row assis", "Cable row assis (pull H hyp)"),
        ("pullv-pullup", "Pull-up (barre fixe)", "Pull-up (barre fixe)"),
        ("pullv-pulldown", "Lat Pulldown câble", "Lat Pulldown câble (pattern pull vertical — maintenu en cutback)"),
        ("pullv-pullover", "Dumbbell Pullover", "Dumbbell Pullover (pattern pull vertical)"),
        ("biceps", "Curl biceps haltères", "Curl biceps haltères"),
        ("biceps-db", "DB curl", "DB curl"),
        ("triceps-pushdown", "Triceps Pushdown câble", "Triceps Pushdown câble"),
        ("triceps-overhead", "Overhead DB triceps extension", "Overhead DB triceps extension"),
        ("lateral", "Lateral Raises haltères", "Lateral Raises haltères"),
        ("calf", "Calf Raises debout", "Calf Raises debout"),
        ("facepull", "Face Pull câble", "Face Pull câble"),
        ("core-planche", "Planche ventrale", "Planche ventrale (core — EN FIN)"),
        ("core-side", "Side Plank", "Side Plank (core — EN FIN)"),
        ("core-hanging", "Hanging leg raise", "Hanging leg raise (core — EN FIN)"),
        ("forearmplank", "Forearm plank", "Forearm plank"),
        ("pallof", "Pallof Press câble", "Pallof Press câble (core — EN FIN)"),
        ("woodchopper", "Cable woodchopper", "Cable woodchopper (core — EN FIN)"),
        ("nordic", "Nordic curl", "Nordic curl"),
        ("birddog", "Bird-dog", "Bird-dog (core — EN FIN)"),
        ("deadbug", "Dead Bug", "Dead Bug (core — EN FIN)"),
        ("clamshell", "Clamshell", "Clamshell"),
        ("kbswing", "Kettlebell swing", "Kettlebell swing"),
        ("plyo", "Box jumps", "Box jumps (pliométrie warmup OPTIONNEL)"),
        ("ytw", "Y-raise allongé", "Y-raise allongé (pattern pull vertical)"),
        // — Sans dessin dédié (fallback générique = chantier nouveaux dessins)
        ("GAP-cablefly", "Cable Fly", "Cable Fly (poulie haute ou Pec Deck)"),
        ("GAP-legpress", "Leg Press machine", "Leg press machine (quad hyp)"),
        ("GAP-legext", "Leg Extension machine", "Leg extension machine (quad isolation)"),
        ("GAP-legcurl", "Leg Curl machine", "Leg curl machine couché (ischio isolation)"),
        ("GAP-reversehyper", "Reverse hyperextension", "Reverse hyperextension banc"),
    ]

    func testMuscuIllustrationGallery() {
        for (slug, _, matchKey) in gallery {
            let ex = AdaptedExercise(name: LocalizedText(fr: matchKey), originalName: matchKey)
            let pattern = ExercisePatternResolver.resolve(ex, sportCode: "strengthTraining")
            let view = ExercisePatternIllustration(
                pattern: pattern, sportCode: "strengthTraining",
                exerciseName: matchKey, size: 150
            )
            .frame(width: 320, height: 180)
            .background(Color(uiColor: .secondarySystemBackground))

            assertSnapshot(
                of: view,
                as: .image(precision: 0.99, perceptualPrecision: 0.95, layout: .fixed(width: 320, height: 180)),
                named: slug
            )
        }
    }
}
