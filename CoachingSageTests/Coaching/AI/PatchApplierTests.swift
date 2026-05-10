// CoachingSageTests/Coaching/AI/PatchApplierTests.swift
// Story 3.3b — tests application patch Léon sur un AdaptedProgram fixture.
// Vérifie : substitutions in-place, idempotence, formatage notes, no-op si patch nil/vide.
import XCTest
import TemplateModel
@testable import CoachingSage

final class PatchApplierTests: XCTestCase {

    // MARK: - No-op cases

    func testApplyNilPatchReturnsProgramUnchanged() {
        let program = makeProgram()
        let result = PatchApplier.apply(nil, to: program)
        XCTAssertEqual(result.program, program)
        XCTAssertNil(result.leonNotes)
    }

    func testApplyEmptyPatchReturnsProgramUnchanged() {
        let program = makeProgram()
        let result = PatchApplier.apply(AdaptationPatch(), to: program)
        XCTAssertEqual(result.program, program)
        XCTAssertNil(result.leonNotes)
    }

    // MARK: - Substitutions

    func testApplySubstitutionMutatesExerciseNameAndFlagsIt() {
        let program = makeProgram()
        let patch = AdaptationPatch(exerciseSubstitutions: [
            .init(weekNumber: 1, day: 2, originalExerciseName: "Footing 30 min",
                  replacementExerciseName: "Marche rapide 30 min", reason: "Reprise douce")
        ])

        let result = PatchApplier.apply(patch, to: program)

        let exo = result.program.weeks[0].sessions[1].exercises[0]
        XCTAssertEqual(exo.name, "Marche rapide 30 min")
        XCTAssertEqual(exo.originalName, "Footing 30 min")
        XCTAssertTrue(exo.wasSubstituted)
        XCTAssertEqual(exo.substitutionReason, "leon-ia: Reprise douce")
    }

    func testApplySubstitutionLeavesUnrelatedExercisesUntouched() {
        let program = makeProgram()
        let patch = AdaptationPatch(exerciseSubstitutions: [
            .init(weekNumber: 1, day: 2, originalExerciseName: "Footing 30 min",
                  replacementExerciseName: "Marche rapide 30 min", reason: "knee")
        ])

        let result = PatchApplier.apply(patch, to: program)

        let unchanged = result.program.weeks[0].sessions[0].exercises[0]
        XCTAssertEqual(unchanged.name, "Footing 25 min")
        XCTAssertFalse(unchanged.wasSubstituted)
    }

    func testApplySubstitutionMatchesByOriginalNameNotMutatedName() {
        // Idempotence : appliquer 2x le même patch produit le même résultat
        // (substitutionRule matche `originalName`, pas `name`).
        let program = makeProgram()
        let patch = AdaptationPatch(exerciseSubstitutions: [
            .init(weekNumber: 1, day: 2, originalExerciseName: "Footing 30 min",
                  replacementExerciseName: "Marche rapide 30 min", reason: "knee")
        ])

        let firstPass = PatchApplier.apply(patch, to: program)
        let secondPass = PatchApplier.apply(patch, to: firstPass.program)

        XCTAssertEqual(firstPass.program, secondPass.program)
    }

    // MARK: - Notes Léon

    func testApplyPersonalizationNoteSurfacesInLeonNotes() {
        let program = makeProgram()
        let patch = AdaptationPatch(personalizationNote: "Bien joué Sarah")

        let result = PatchApplier.apply(patch, to: program)

        XCTAssertEqual(result.leonNotes?.personalizationNote, "Bien joué Sarah")
        XCTAssertEqual(result.leonNotes?.safetyNotes, [])
        XCTAssertEqual(result.leonNotes?.adjustmentNotes, [])
        XCTAssertEqual(result.leonNotes?.hasAnything, true)
    }

    func testApplyEmptyPersonalizationNoteIsTreatedAsNil() {
        let program = makeProgram()
        let patch = AdaptationPatch(personalizationNote: "")

        let result = PatchApplier.apply(patch, to: program)

        // patch.hasContent est false → leonNotes nil (no-op)
        XCTAssertNil(result.leonNotes)
    }

    func testApplySafetyNotesPropagated() {
        let program = makeProgram()
        let patch = AdaptationPatch(safetyNotes: ["Bien hydrater", "Pas avant repas"])

        let result = PatchApplier.apply(patch, to: program)

        XCTAssertEqual(result.leonNotes?.safetyNotes, ["Bien hydrater", "Pas avant repas"])
    }

    func testApplyVolumeAdjustmentFormattedAsBullet() {
        let program = makeProgram()
        let patch = AdaptationPatch(volumeAdjustments: [
            .init(weekNumber: 2, day: nil, exerciseName: nil,
                  adjustment: "Réduire de 15%", reason: "Reprise après pause")
        ])

        let result = PatchApplier.apply(patch, to: program)

        XCTAssertEqual(result.leonNotes?.adjustmentNotes,
                       ["W2 : Réduire de 15% (Reprise après pause)"])
    }

    func testApplyVolumeAdjustmentWithDayAndExerciseName() {
        let program = makeProgram()
        let patch = AdaptationPatch(volumeAdjustments: [
            .init(weekNumber: 1, day: 3, exerciseName: "Squats",
                  adjustment: "3×8 au lieu de 4×10", reason: "Genoux sensibles")
        ])

        let result = PatchApplier.apply(patch, to: program)

        XCTAssertEqual(result.leonNotes?.adjustmentNotes,
                       ["W1 J3 Squats : 3×8 au lieu de 4×10 (Genoux sensibles)"])
    }

    func testApplyProgressionPacingFormatted() {
        let program = makeProgram()
        let patch = AdaptationPatch(progressionPacing: [
            .init(weekNumber: 3, adjustment: "RPE cible 6 au lieu de 7", reason: "Charge W2 trop forte")
        ])

        let result = PatchApplier.apply(patch, to: program)

        XCTAssertEqual(result.leonNotes?.adjustmentNotes,
                       ["W3 : RPE cible 6 au lieu de 7 (Charge W2 trop forte)"])
    }

    func testApplyMultipleAdjustmentsConcatenateInOrder() {
        let program = makeProgram()
        let patch = AdaptationPatch(
            volumeAdjustments: [
                .init(weekNumber: 1, day: nil, exerciseName: nil,
                      adjustment: "Reduce volume 20%", reason: "Beginner")
            ],
            progressionPacing: [
                .init(weekNumber: 2, adjustment: "RPE 6", reason: "tired")
            ]
        )

        let result = PatchApplier.apply(patch, to: program)

        XCTAssertEqual(result.leonNotes?.adjustmentNotes.count, 2)
        XCTAssertEqual(result.leonNotes?.adjustmentNotes[0], "W1 : Reduce volume 20% (Beginner)")
        XCTAssertEqual(result.leonNotes?.adjustmentNotes[1], "W2 : RPE 6 (tired)")
    }

    // MARK: - Préservation du programme structurel

    func testProgramMetadataIsPreserved() {
        let program = makeProgram()
        let patch = AdaptationPatch(personalizationNote: "Hi")

        let result = PatchApplier.apply(patch, to: program)

        XCTAssertEqual(result.program.templateId, program.templateId)
        XCTAssertEqual(result.program.sport, program.sport)
        XCTAssertEqual(result.program.level, program.level)
        XCTAssertEqual(result.program.appliedAt, program.appliedAt)
        XCTAssertEqual(result.program.requiresAIAssist, program.requiresAIAssist)
        XCTAssertEqual(result.program.aiAssistReason, program.aiAssistReason)
        XCTAssertEqual(result.program.weeks.count, program.weeks.count)
    }

    func testNoMatchingSubstitutionLeavesProgramUntouched() {
        let program = makeProgram()
        let patch = AdaptationPatch(exerciseSubstitutions: [
            .init(weekNumber: 99, day: 99, originalExerciseName: "Inexistant",
                  replacementExerciseName: "Marche", reason: "test")
        ])

        let result = PatchApplier.apply(patch, to: program)

        // Pas de substitution appliquée mais notes Léon vides → leonNotes a tous les arrays vides
        XCTAssertEqual(result.program, program)
    }

    // MARK: - Helpers

    private func makeProgram() -> AdaptedProgram {
        AdaptedProgram(
            templateId: "running-beginner-couch-to-5k",
            sport: .running,
            level: .beginner,
            appliedAt: Date(timeIntervalSince1970: 1_700_000_000),
            weeks: [
                AdaptedWeek(weekNumber: 1, theme: "Découverte", goal: "Reprise", sessions: [
                    AdaptedSession(
                        day: 1, name: "S1", durationMinutes: 25, type: .endurance,
                        warmup: nil,
                        exercises: [AdaptedExercise(name: "Footing 25 min", originalName: "Footing 25 min")],
                        cooldown: nil
                    ),
                    AdaptedSession(
                        day: 2, name: "S2", durationMinutes: 30, type: .endurance,
                        warmup: nil,
                        exercises: [AdaptedExercise(name: "Footing 30 min", originalName: "Footing 30 min")],
                        cooldown: nil
                    ),
                    AdaptedSession(
                        day: 3, name: "S3", durationMinutes: 40, type: .strength,
                        warmup: nil,
                        exercises: [AdaptedExercise(name: "Squats", originalName: "Squats", sets: 4, reps: "10")],
                        cooldown: nil
                    )
                ])
            ],
            appliedRules: [],
            requiresAIAssist: true,
            aiAssistReason: "Combinaison rare contraintes"
        )
    }
}
