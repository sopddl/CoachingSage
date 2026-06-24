// CoachingSageTests/Views/Components/ProgrammeFilSnapshotTests.swift
// Filet régression visuel de l'onboarding PROGRAMME « fil de Léon » (inc1).
// Couvre : état A (Léon attend, CTA vert grisé) + état B (proposition : restitution
// + récap éditable + invite conversation, CTA actif). Garde-fou LAYOUT (zones,
// carrousel, carte proposition, position CTA) — pas le wording (cf. note locale).
//
// ⚠️ Limite locale (cf OnboardingFilSnapshotTests / ProgramCardSnapshotTests) :
// les LocalizedStringKey ne sont pas résolus FR dans le UIHostingController de
// SnapshotTesting → raw keys dans les .png. Mode record : supprimer le .png + relancer.
import XCTest
import SwiftUI
import SnapshotTesting
import SwiftData

@MainActor
final class ProgrammeFilSnapshotTests: XCTestCase {

    private let frenchLocale = Locale(identifier: "fr")
    private var container: ModelContainer!

    override func setUpWithError() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: CoachingSportProfile.self, configurations: config)
        _ = container.mainContext
    }

    override func tearDown() { container = nil }

    private func makeVM() -> ProgrammeOnboardingViewModel {
        ProgrammeOnboardingViewModel(
            userId: UUID(),
            activeSports: [.running, .cycling, .yoga],
            requiresMedicalClearance: false,
            autoprofileLevel: nil,
            generatePreview: { _ in 12 }
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

    func testFil_empty() {
        assert(ProgrammeOnboardingView(viewModel: makeVM(), onCompleted: { _ in }))
    }

    func testFil_proposal() async {
        let vm = makeVM()
        vm.selectSport(.running)
        await vm.regenerate()
        assert(ProgrammeOnboardingView(viewModel: vm, onCompleted: { _ in }))
    }
}
