// CoachingSageTests/Coaching/Glossary/ExerciseNameGlossaryMapTests.swift
// Story 3.26 Phase B-bis — couvre `Glossary.entry(forExerciseName:sportCode:useFallback:)`.
import XCTest

final class ExerciseNameGlossaryMapTests: XCTestCase {

    // MARK: - Overrides exacts

    func testTadasanaOverridesToYogaAsana() {
        XCTAssertEqual(
            Glossary.entry(forExerciseName: "Tadasana")?.id,
            "yoga.asana"
        )
    }

    func testAdhoMukhaSvanasanaOverridesToYogaAsana() {
        XCTAssertEqual(
            Glossary.entry(forExerciseName: "Adho Mukha Svanasana")?.id,
            "yoga.asana"
        )
    }

    func testDownwardDogOverridesToYogaAsana() {
        XCTAssertEqual(
            Glossary.entry(forExerciseName: "Downward Dog")?.id,
            "yoga.asana"
        )
    }

    func testBirdDogOverridesToReps() {
        XCTAssertEqual(Glossary.entry(forExerciseName: "Bird Dog")?.id, "reps")
        XCTAssertEqual(Glossary.entry(forExerciseName: "Bird-dog")?.id, "reps")
    }

    // MARK: - Fallback texte matcher

    func testFallsBackToTextMatcherWhenNoOverride() {
        // "Squat avec barre" n'est pas dans les overrides, mais contient pas de terme
        // glossaire connu non plus → nil sans fallback.
        XCTAssertNil(Glossary.entry(forExerciseName: "Squat avec barre"))
    }

    func testTextMatcherWinsWhenExerciseNameContainsKnownTerm() {
        // "Side Plank" contient "plank" → doit retourner plank entry.
        XCTAssertEqual(
            Glossary.entry(forExerciseName: "Side Plank")?.id,
            "plank"
        )
    }

    // MARK: - Fallback sport-générique

    func testFallbackSportGenericForYoga() {
        // Nom exo non reconnu, sportCode yoga, useFallback true → yoga.asana.
        XCTAssertEqual(
            Glossary.entry(forExerciseName: "Pose inconnue",
                           sportCode: "yoga",
                           useFallback: true)?.id,
            "yoga.asana"
        )
    }

    func testFallbackSportGenericForSwimming() {
        XCTAssertEqual(
            Glossary.entry(forExerciseName: "Set inconnu",
                           sportCode: "swimming",
                           useFallback: true)?.id,
            "en"
        )
    }

    func testFallbackSportGenericForStrengthTraining() {
        XCTAssertEqual(
            Glossary.entry(forExerciseName: "Exo inconnu",
                           sportCode: "strength_training",
                           useFallback: true)?.id,
            "reps"
        )
    }

    func testNoFallbackByDefault() {
        // Même avec sportCode fourni, useFallback=false (défaut) → nil si rien matché.
        XCTAssertNil(
            Glossary.entry(forExerciseName: "Pose inconnue", sportCode: "yoga")
        )
    }

    // MARK: - Empty / whitespace

    func testEmptyNameReturnsNil() {
        XCTAssertNil(Glossary.entry(forExerciseName: ""))
        XCTAssertNil(Glossary.entry(forExerciseName: "   "))
    }

    // MARK: - Case insensitive

    func testCaseInsensitiveOverride() {
        XCTAssertEqual(Glossary.entry(forExerciseName: "TADASANA")?.id, "yoga.asana")
        XCTAssertEqual(Glossary.entry(forExerciseName: "tadasana")?.id, "yoga.asana")
        XCTAssertEqual(Glossary.entry(forExerciseName: "TaDaSaNa")?.id, "yoga.asana")
    }
}
