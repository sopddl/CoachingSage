// CoachingSageTests/DurationScaling/SessionDurationScalerTests.swift
// Chantier durée réglable, pilote cycling (Increment 2) — filet de régression du moteur
// `SessionDurationScaler` (doctrine section 8) : invariants section 5 (warmup/cooldown
// jamais touchés, core jamais à zéro, accessoire jamais étendu au-dessus de l'original,
// `wasBounded` correct aux bornes exactes, chiffre retourné = chiffre réellement appliqué).
//
// Fixtures construites directement en `PersistedSession`/`AdaptedExercise` (pas de passage
// par `ProgramTemplate`/`ProgramAdapter` — le moteur est isolé, cf doctrine section 7).
// Cibles choisies pour tomber sur des bornes REPS EXACTES quand `scalingUnit == .roundsReps`
// (évite la zone d'ambiguïté d'arrondi à la demi-rep, hors scope de ce filet — l'honnêteté
// du chiffre affiché prime sur la convergence exacte vers la cible, cf doctrine D7).
import XCTest
import TemplateModel

final class SessionDurationScalerTests: XCTestCase {

    private func makeExercise(
        name: String = "Exo",
        sets: Int? = nil,
        estimatedMinutes: Int?,
        targetZone: String? = nil,
        role: BlockRole,
        scalingUnit: ScalingUnit,
        priority: Int? = nil
    ) -> AdaptedExercise {
        AdaptedExercise(
            name: LocalizedText(fr: name),
            originalName: name,
            sets: sets,
            targetZone: targetZone,
            role: role,
            scalingUnit: scalingUnit,
            priority: priority,
            estimatedMinutes: estimatedMinutes
        )
    }

    private func makeSession(
        type: SessionType = .endurance,
        warmupMinutes: Int? = 10,
        cooldownMinutes: Int? = 5,
        exercises: [AdaptedExercise],
        durationMinutes: Int
    ) -> PersistedSession {
        PersistedSession(
            weekNumber: 1,
            weekTheme: "Semaine 1",
            weekGoal: "Goal",
            day: 1,
            name: "Séance test",
            durationMinutes: durationMinutes,
            type: type,
            warmup: "Échauffement",
            exercises: exercises,
            cooldown: "Retour au calme",
            warmupMinutes: warmupMinutes,
            cooldownMinutes: cooldownMinutes
        )
    }

    // MARK: - `continuous` (endurance)

    func testContinuousReducesTowardFloor() {
        let core = makeExercise(estimatedMinutes: 45, role: .core, scalingUnit: .continuous)
        let session = makeSession(exercises: [core], durationMinutes: 60)

        let result = SessionDurationScaler.scale(session, toTargetMinutes: 10, level: .recreational)

        XCTAssertTrue(result.wasBounded)
        XCTAssertEqual(result.session.durationMinutes, 35) // warmup10 + cooldown5 + floor20
        XCTAssertEqual(result.session.exercises.first?.estimatedMinutes, 20)
        XCTAssertEqual(result.session.id, session.id)
        XCTAssertEqual(result.session.warmupMinutes, 10)
        XCTAssertEqual(result.session.cooldownMinutes, 5)
    }

    func testContinuousExtendsTowardRelativeCeilingNotAbsolute() {
        // Absolu recreational = 180 min, mais le garde-fou relatif 2× (45×2=90) est plus
        // strict — doit gagner (doctrine section 4, validé Sophie 2026-07-04).
        let core = makeExercise(estimatedMinutes: 45, role: .core, scalingUnit: .continuous)
        let session = makeSession(exercises: [core], durationMinutes: 60)

        let result = SessionDurationScaler.scale(session, toTargetMinutes: 500, level: .recreational)

        XCTAssertTrue(result.wasBounded)
        XCTAssertEqual(result.session.durationMinutes, 105) // 10 + 5 + 90 (2×45)
        XCTAssertEqual(result.session.exercises.first?.estimatedMinutes, 90)
    }

    func testContinuousWithinRangeIsNotBoundedAndMatchesTargetExactly() {
        let core = makeExercise(estimatedMinutes: 45, role: .core, scalingUnit: .continuous)
        let session = makeSession(exercises: [core], durationMinutes: 60)

        let result = SessionDurationScaler.scale(session, toTargetMinutes: 50, level: .beginner)

        XCTAssertFalse(result.wasBounded)
        XCTAssertEqual(result.session.durationMinutes, 50)
        XCTAssertEqual(result.session.exercises.first?.estimatedMinutes, 35)
    }

    // MARK: - Sacrifice accessory AVANT core (D5)

    func testAccessoriesSacrificedByPriorityBeforeCoreIsTouched() {
        let core = makeExercise(estimatedMinutes: 40, role: .core, scalingUnit: .continuous)
        let accessory1 = makeExercise(
            name: "Gainage", estimatedMinutes: 15, role: .accessory, scalingUnit: .continuous, priority: 1
        )
        let accessory2 = makeExercise(
            name: "Pont fessier", estimatedMinutes: 10, role: .accessory, scalingUnit: .continuous, priority: 2
        )
        let session = makeSession(
            warmupMinutes: 5, cooldownMinutes: 5,
            exercises: [core, accessory1, accessory2], durationMinutes: 75
        )

        let result = SessionDurationScaler.scale(session, toTargetMinutes: 60, level: .beginner)

        XCTAssertFalse(result.wasBounded)
        XCTAssertEqual(result.session.durationMinutes, 60)
        // Accessory priority 1 entièrement sacrifié en premier — retiré de la séance.
        XCTAssertFalse(result.session.exercises.contains { $0.originalName == "Gainage" })
        // Priority 2 pas touché : le déficit était absorbé par le seul accessory 1.
        XCTAssertEqual(result.session.exercises.first { $0.originalName == "Pont fessier" }?.estimatedMinutes, 10)
        // Core intouché tant que les accessoires suffisent.
        XCTAssertEqual(result.session.exercises.first { $0.originalName == "Exo" }?.estimatedMinutes, 40)
    }

    func testCoreReducedToFloorOnlyAfterAllAccessoriesExhausted() {
        let core = makeExercise(estimatedMinutes: 40, role: .core, scalingUnit: .continuous)
        let accessory1 = makeExercise(
            name: "Gainage", estimatedMinutes: 15, role: .accessory, scalingUnit: .continuous, priority: 1
        )
        let accessory2 = makeExercise(
            name: "Pont fessier", estimatedMinutes: 10, role: .accessory, scalingUnit: .continuous, priority: 2
        )
        let session = makeSession(
            warmupMinutes: 5, cooldownMinutes: 5,
            exercises: [core, accessory1, accessory2], durationMinutes: 75
        )

        let result = SessionDurationScaler.scale(session, toTargetMinutes: 25, level: .beginner)

        XCTAssertTrue(result.wasBounded)
        XCTAssertEqual(result.session.durationMinutes, 30) // 5 + 5 + floor(20)
        XCTAssertFalse(result.session.exercises.contains { $0.originalName == "Gainage" })
        XCTAssertFalse(result.session.exercises.contains { $0.originalName == "Pont fessier" })
        XCTAssertEqual(result.session.exercises.first { $0.originalName == "Exo" }?.estimatedMinutes, 20)
    }

    // MARK: - `roundsReps` (interval) — bornes par zone, cibles sur bornes reps exactes

    func testRoundsRepsReducesToZoneFloorReps() {
        let core = makeExercise(
            sets: 3, estimatedMinutes: 30, targetZone: "FTP-Z4", role: .core, scalingUnit: .roundsReps
        )
        let session = makeSession(warmupMinutes: 5, cooldownMinutes: 5, exercises: [core], durationMinutes: 40)

        let result = SessionDurationScaler.scale(session, toTargetMinutes: 0, level: .regular)

        XCTAssertTrue(result.wasBounded)
        XCTAssertEqual(result.session.durationMinutes, 30) // 5 + 5 + floor Z4 (2 reps × 10)
        XCTAssertEqual(result.session.exercises.first?.sets, 2)
        XCTAssertEqual(result.session.exercises.first?.estimatedMinutes, 20)
    }

    func testRoundsRepsExtendsToZoneCeilingReps() {
        let core = makeExercise(
            sets: 3, estimatedMinutes: 30, targetZone: "FTP-Z4", role: .core, scalingUnit: .roundsReps
        )
        let session = makeSession(warmupMinutes: 5, cooldownMinutes: 5, exercises: [core], durationMinutes: 40)

        let result = SessionDurationScaler.scale(session, toTargetMinutes: 1000, level: .regular)

        XCTAssertTrue(result.wasBounded)
        XCTAssertEqual(result.session.durationMinutes, 50) // 5 + 5 + ceiling Z4 (4 reps × 10)
        XCTAssertEqual(result.session.exercises.first?.sets, 4)
        XCTAssertEqual(result.session.exercises.first?.estimatedMinutes, 40)
    }

    func testRoundsRepsFallbackZoneUsesGenericBounds() {
        // Zone absente/texte libre → floor = sets-1 (min 2), ceiling = sets+2 (doctrine 9.4).
        let core = makeExercise(
            sets: 4, estimatedMinutes: 40, targetZone: nil, role: .core, scalingUnit: .roundsReps
        )
        let session = makeSession(warmupMinutes: 0, cooldownMinutes: 0, exercises: [core], durationMinutes: 40)

        let reduced = SessionDurationScaler.scale(session, toTargetMinutes: 0, level: .regular)
        XCTAssertEqual(reduced.session.exercises.first?.sets, 3) // 4-1
        XCTAssertEqual(reduced.session.durationMinutes, 30)

        let extended = SessionDurationScaler.scale(session, toTargetMinutes: 1000, level: .regular)
        XCTAssertEqual(extended.session.exercises.first?.sets, 6) // 4+2
        XCTAssertEqual(extended.session.durationMinutes, 60)
    }

    func testSingleRepRoundsRepsBlockNeverOvershootsOnExtend() {
        // sets == 1 : la doctrine (annotate_cycling_blocks.py) n'annote JAMAIS un bloc à un
        // seul rep en `.roundsReps` (toujours `.continuous`), mais le modèle le permet — le
        // garde-fou d'arrondi (force ±1 rep) ne doit PAS s'appliquer ici : forcer +1 rep sur
        // un bloc à 80 min/rep ferait exploser le budget (160 min) au lieu de rester borné.
        let core = makeExercise(
            sets: 1, estimatedMinutes: 80, targetZone: "Sweet-Spot", role: .core, scalingUnit: .roundsReps
        )
        let session = makeSession(warmupMinutes: 0, cooldownMinutes: 0, exercises: [core], durationMinutes: 80)

        let result = SessionDurationScaler.scale(session, toTargetMinutes: 1000, level: .regular)

        XCTAssertTrue(result.wasBounded)
        XCTAssertLessThanOrEqual(result.session.durationMinutes, 90) // plafond Z3, jamais 160
        XCTAssertEqual(result.session.exercises.first?.sets, 1)
    }

    // MARK: - `fixed` — intouchable

    func testFixedBlockNeverScales() {
        let core = makeExercise(estimatedMinutes: 30, role: .core, scalingUnit: .fixed)
        let session = makeSession(warmupMinutes: 5, cooldownMinutes: 5, exercises: [core], durationMinutes: 40)

        let reduced = SessionDurationScaler.scale(session, toTargetMinutes: 0, level: .beginner)
        XCTAssertTrue(reduced.wasBounded)
        XCTAssertEqual(reduced.session.durationMinutes, 40)
        XCTAssertEqual(reduced.session.exercises.first?.estimatedMinutes, 30)

        let extended = SessionDurationScaler.scale(session, toTargetMinutes: 1000, level: .beginner)
        XCTAssertTrue(extended.wasBounded)
        XCTAssertEqual(extended.session.durationMinutes, 40)
    }

    // MARK: - `.fixed` accessory jamais sacrifié (review angle A/C)

    func testFixedAccessoryIsNeverRemovedEvenUnderHardReduction() {
        let core = makeExercise(estimatedMinutes: 40, role: .core, scalingUnit: .continuous)
        let fixedAccessory = makeExercise(
            name: "Test FTP fixe", estimatedMinutes: 10, role: .accessory, scalingUnit: .fixed, priority: 1
        )
        let sacrificeableAccessory = makeExercise(
            name: "Gainage", estimatedMinutes: 15, role: .accessory, scalingUnit: .continuous, priority: 2
        )
        let session = makeSession(
            warmupMinutes: 5, cooldownMinutes: 5,
            exercises: [core, fixedAccessory, sacrificeableAccessory], durationMinutes: 75
        )

        let result = SessionDurationScaler.scale(session, toTargetMinutes: 0, level: .beginner)

        XCTAssertTrue(result.wasBounded)
        // Plancher réel = warmup+cooldown+coreFloor(20)+fixedAccessory(10) = 40.
        XCTAssertEqual(result.session.durationMinutes, 40)
        XCTAssertTrue(result.session.exercises.contains { $0.originalName == "Test FTP fixe" })
        XCTAssertEqual(
            result.session.exercises.first { $0.originalName == "Test FTP fixe" }?.estimatedMinutes, 10
        )
        XCTAssertFalse(result.session.exercises.contains { $0.originalName == "Gainage" })
        XCTAssertEqual(result.session.exercises.first { $0.originalName == "Exo" }?.estimatedMinutes, 20)
    }

    // MARK: - Accessory `roundsReps` coupé à 0 rep → retiré (pas affiché à 0)

    func testRoundsRepsAccessoryRoundedToZeroRepsIsRemoved() {
        let core = makeExercise(estimatedMinutes: 40, role: .core, scalingUnit: .continuous)
        let accessory = makeExercise(
            name: "Sprint activation", sets: 2, estimatedMinutes: 10,
            role: .accessory, scalingUnit: .roundsReps, priority: 1
        )
        let session = makeSession(
            warmupMinutes: 5, cooldownMinutes: 5, exercises: [core, accessory], durationMinutes: 60
        )

        // Coupe l'accessory de 10 à 2 min (0.4 rep) — arrondit à 0 rep, pas un cas "pile 0".
        let result = SessionDurationScaler.scale(session, toTargetMinutes: 52, level: .beginner)

        XCTAssertFalse(result.wasBounded)
        XCTAssertFalse(result.session.exercises.contains { $0.originalName == "Sprint activation" })
        XCTAssertEqual(result.session.exercises.first { $0.originalName == "Exo" }?.estimatedMinutes, 40)
        XCTAssertEqual(result.session.durationMinutes, 50) // 5 + 5 + 40 (accessory retiré)
    }

    // MARK: - Garde-fous robustesse

    func testPartiallyAnnotatedSessionIsLeftUnchanged() {
        // Exercices annotés role/scalingUnit MAIS session sans warmupMinutes/cooldownMinutes
        // (annotation incomplète) : traité comme non-annoté, jamais un calcul silencieux sur 0.
        let core = makeExercise(estimatedMinutes: 45, role: .core, scalingUnit: .continuous)
        let session = makeSession(warmupMinutes: nil, cooldownMinutes: nil, exercises: [core], durationMinutes: 60)

        let result = SessionDurationScaler.scale(session, toTargetMinutes: 20, level: .beginner)

        XCTAssertEqual(result.session, session)
    }

    func testExerciseMissingEstimatedMinutesLeavesSessionUnchanged() {
        let core = makeExercise(estimatedMinutes: nil, role: .core, scalingUnit: .continuous)
        let session = makeSession(exercises: [core], durationMinutes: 60)

        let result = SessionDurationScaler.scale(session, toTargetMinutes: 20, level: .beginner)

        XCTAssertEqual(result.session, session)
    }

    func testRestSessionIsNeverAdjusted() {
        let session = makeSession(type: .rest, warmupMinutes: nil, cooldownMinutes: nil, exercises: [], durationMinutes: 0)

        let result = SessionDurationScaler.scale(session, toTargetMinutes: 30, level: .beginner)

        XCTAssertEqual(result.session, session)
        XCTAssertTrue(result.wasBounded)
    }

    func testNonAnnotatedSessionIsLeftUnchanged() {
        // Sport hors V1 cycling (ou contenu overlay non annoté) : role/scalingUnit nil.
        let exercise = AdaptedExercise(name: "Exo", originalName: "Exo", estimatedMinutes: 30)
        let session = makeSession(exercises: [exercise], durationMinutes: 45)

        let result = SessionDurationScaler.scale(session, toTargetMinutes: 20, level: .beginner)

        XCTAssertEqual(result.session, session)
        XCTAssertTrue(result.wasBounded)
    }

    func testSessionWithNoCoreBlockIsLeftUnchanged() {
        let onlyAccessory = makeExercise(estimatedMinutes: 30, role: .accessory, scalingUnit: .continuous, priority: 1)
        let session = makeSession(exercises: [onlyAccessory], durationMinutes: 45)

        let result = SessionDurationScaler.scale(session, toTargetMinutes: 20, level: .beginner)

        XCTAssertEqual(result.session, session)
    }

    func testIdIsPreservedAcrossAdjustment() {
        let core = makeExercise(estimatedMinutes: 45, role: .core, scalingUnit: .continuous)
        let session = makeSession(exercises: [core], durationMinutes: 60)

        let result = SessionDurationScaler.scale(session, toTargetMinutes: 40, level: .beginner)

        XCTAssertEqual(result.session.id, session.id)
    }
}
