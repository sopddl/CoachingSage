// CoachingSageTests/Views/Components/OnboardingFilSnapshotTests.swift
// Filet régression visuel du nouvel onboarding « fil de Léon » (party onboarding 2026-06-22/23).
// Couvre : fil vide (CTA vert grisé), fil rempli (prénom + 2 sports, CTA actif), PARQ-light,
// clôture. Garde-fou layout : bulles Léon, grille sports, bloc accord, position des CTA.
//
// ⚠️ Limite locale (cf `ProgramCardSnapshotTests`) : les `LocalizedStringKey` ne sont pas
// résolus à FR dans le `UIHostingController` de SnapshotTesting → raw keys dans les .png.
// Le filet protège le LAYOUT (composition, ordre, présence des éléments), pas le wording
// (verrouillé séparément par les filets de localisation). Mode record : supprimer le .png +
// relancer après un changement UI intentionnel.
import XCTest
import SwiftUI
import SnapshotTesting
import SageCore

@MainActor
final class OnboardingFilSnapshotTests: XCTestCase {

    private let frenchLocale = Locale(identifier: "fr")

    private func makeViewModel() -> OnboardingViewModel {
        OnboardingViewModel(
            coreProfileRepository: MockCoreProfileRepository(),
            coachingProfileRepository: MockCoachingProfileRepository(),
            healthKitService: MockHealthKitService()
        )
    }

    private func host(_ view: some View) -> some View {
        view
            .environment(\.languageManager, LanguageManager())
            .environment(\.locale, frenchLocale)
            .background(Color.coachingBackground)
    }

    private func assert(_ view: some View, testName: String = #function, line: UInt = #line) {
        assertSnapshot(
            of: host(view),
            as: .image(precision: 0.99, perceptualPrecision: 0.97,
                       layout: .device(config: .iPhone13Pro)),
            testName: testName, line: line
        )
    }

    func testWelcomeFil_empty() {
        let vm = makeViewModel()
        assert(WelcomeFilView(viewModel: vm))
    }

    func testWelcomeFil_filled() {
        let vm = makeViewModel()
        vm.firstName = "Sophie"
        vm.activeSports = ["running", "yoga"]
        assert(WelcomeFilView(viewModel: vm))
    }

    func testParq_clean() {
        let vm = makeViewModel()
        assert(DisclaimerPARQView(viewModel: vm))
    }

    func testParq_riskFlagged() {
        let vm = makeViewModel()
        vm.parqResponses[PARQQuestion.q1ChestPain.rawValue] = true
        assert(DisclaimerPARQView(viewModel: vm))
    }

    func testClosing() {
        let vm = makeViewModel()
        vm.firstName = "Sophie"
        // Pré-positionne le succès : le `.task` finalize() court-circuite (idempotent),
        // on évite le chemin Supabase et on rend l'état « terminé » (CTA vert actif).
        vm.saveState = .success(())
        assert(ClosingView(viewModel: vm, onCompleted: {}))
    }
}
