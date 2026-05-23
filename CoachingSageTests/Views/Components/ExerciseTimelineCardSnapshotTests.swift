// CoachingSageTests/Views/Components/ExerciseTimelineCardSnapshotTests.swift
// Story 3.19 Jalon 4 — snapshots visuels d'`ExerciseTimelineCard` pour filet
// régression sur le rendu de la card exo (avec/sans illustration, avec/sans
// pulse contexte). Le pulse lui-même (animé) n'est pas snapshotté : son état
// stable post-séquence l'est. La logique pulse est couverte par les tests
// unit `GlossaryFirstVisitPulseTests`.
//
// Mode `record` : à la 1ère exécution, les .png de référence sont créés sous
// `__Snapshots__/`. Pour reset un snapshot après changement intentionnel UI,
// supprimer le .png correspondant et relancer le test.
//
// ⚠️ Limite locale : LocalizedStringKey n'est PAS résolue à FR dans le contexte
// `UIHostingController` de SnapshotTesting (Bundle.main locale non swizzlée).
// Les .strings keys apparaissent en raw dans les .png. Le filet régression reste
// utile (layout, illustration, chips, tip présence/absence). Couverture
// traduction FR/EN visuelle = story snapshot-infra dédiée à venir.
import XCTest
import SwiftUI
import SnapshotTesting
import TemplateModel

final class ExerciseTimelineCardSnapshotTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Reset flag pulse pour éviter cross-talk entre tests.
        GlossaryFirstVisitPulse.resetForTesting()
        // Marquer pulse comme done → forcer state initial tipVisible=true
        // (snapshot stable, pas d'attente animation).
        GlossaryFirstVisitPulse.markPulsed()
    }

    override func tearDown() {
        GlossaryFirstVisitPulse.resetForTesting()
        super.tearDown()
    }

    // MARK: - Fixtures

    private func runningIntervalCard(isFirst: Bool) -> some View {
        ExerciseTimelineCard(
            exercise: AdaptedExercise(
                name: "Bloc 30/30 (pattern run.interval)",
                originalName: "Bloc 30/30",
                sets: 8,
                reps: "30s",
                duration: "30/30",
                restSeconds: 30,
                notes: "30s à Daniels-I, 30s en récup trot relâché. RPE 8.",
                targetZone: "Daniels-I"
            ),
            sportCode: "running",
            isFirstExercise: isFirst
        )
        .frame(width: 350)
        .padding()
        .background(Color(uiColor: .systemBackground))
    }

    private func substitutedStrengthCard() -> some View {
        ExerciseTimelineCard(
            exercise: AdaptedExercise(
                name: "Pompe diamant (pattern push horizontal)",
                originalName: "Bench press barre",
                sets: 3,
                reps: "12",
                duration: nil,
                restSeconds: 60,
                notes: "Garde le dos droit, descente contrôlée.",
                targetZone: nil,
                wasSubstituted: true,
                substitutionReason: "equipment:no_barbell"
            ),
            sportCode: "strengthTraining",
            isFirstExercise: false
        )
        .frame(width: 350)
        .padding()
        .background(Color(uiColor: .systemBackground))
    }

    // MARK: - Tests

    func testCardStableState_running() {
        let view = runningIntervalCard(isFirst: false)
        assertSnapshot(of: view, as: .image(layout: .fixed(width: 350, height: 320)))
    }

    func testCardFirstExercise_postPulseDone_running() {
        // Même rendu que non-first quand flag pulse=done : tip visible, pas d'anim.
        let view = runningIntervalCard(isFirst: true)
        assertSnapshot(of: view, as: .image(layout: .fixed(width: 350, height: 320)))
    }

    func testCardSubstituted_strength() {
        let view = substitutedStrengthCard()
        assertSnapshot(of: view, as: .image(layout: .fixed(width: 350, height: 360)))
    }

    // Note : pas de snapshot EN — `.environment(\.locale, .en)` ne swizzle pas
    // le bundle de localisation, donc les strings restent en FR. Couverture EN
    // visuelle = story snapshot-infra dédiée à venir (bundle swizzle).
}
