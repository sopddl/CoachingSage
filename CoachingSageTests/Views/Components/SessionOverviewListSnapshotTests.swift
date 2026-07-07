// CoachingSageTests/Views/Components/SessionOverviewListSnapshotTests.swift
// Passe qualité personas (2026-07-05) — filet régression visuel pour le titre
// de bloc dans l'aperçu "Au programme" (`SessionOverviewList.phaseTitle`).
//
// Contexte : retour persona cross-sport (tennis, football, natation...) — un
// nom de bloc long était tronqué à 1 ligne avant l'info utile ("Coup droit
// crois...", "Jeu réduit 4 contre 4 espace l..."). Root cause vérifiée :
// `.lineLimit(1)` non documenté sur `phaseTitle` (SessionOverviewList.swift:63),
// contrairement au `.lineLimit(1)` volontaire de `SessionWhyPanel` (Story 3.32).
// Fix : passage à `.lineLimit(2)`. Ce test verrouille le rendu 2 lignes pour ne
// pas régresser silencieusement vers la troncature à 1 ligne.
//
// Mode `record` : à la 1ère exécution les .png de référence sont créés sous
// `__Snapshots__/`. Pour reset après un changement UI intentionnel, supprimer
// le .png correspondant et relancer.
import XCTest
import SwiftUI
import SnapshotTesting
import TemplateModel

final class SessionOverviewListSnapshotTests: XCTestCase {

    private let frenchLocale = Locale(identifier: "fr")

    private func ex(name: String, sets: Int? = nil, reps: String? = nil, duration: String? = nil) -> AdaptedExercise {
        AdaptedExercise(name: LocalizedText(fr: name), originalName: name, sets: sets, reps: reps, duration: duration)
    }

    private func list(_ session: AdaptedSession) -> some View {
        SessionOverviewList(session: session, onSelect: { _ in })
            .frame(width: 340)
            .padding()
            .background(Color(uiColor: .systemBackground))
            .environment(\.locale, frenchLocale)
    }

    private func assert(_ view: some View, height: CGFloat,
                        testName: String = #function, line: UInt = #line) {
        assertSnapshot(of: view, as: .image(precision: 0.99, perceptualPrecision: 0.97,
                                            layout: .fixed(width: 340, height: height)),
                       testName: testName, line: line)
    }

    func testLongBlockTitle_wrapsOnTwoLines() {
        // Retour persona tennis/expert : "Coup droit croisé..." tronqué avant la variante.
        let s = AdaptedSession(
            day: 1, name: "Séance", durationMinutes: 45, type: .technique,
            warmup: "10 min mini-tennis",
            exercises: [
                ex(name: "Coup droit croisé, variantes longue ligne et amorti", sets: 4, reps: "10"),
                ex(name: "Jeu réduit 4 contre 4, espace limité au carré de service", duration: "8 min")
            ],
            cooldown: "5 min retour au calme"
        )
        assert(list(s), height: 300)
    }

    func testShortBlockTitle_unaffected() {
        let s = AdaptedSession(
            day: 1, name: "Séance", durationMinutes: 30, type: .strength,
            warmup: "5 min mobilité",
            exercises: [ex(name: "Squat", sets: 4, reps: "8")],
            cooldown: nil
        )
        assert(list(s), height: 130)
    }
}
