// CoachingSageTests/Views/Components/RunningComprehensibilitySnapshotTests.swift
// Preuve visuelle — chantier compréhensibilité running (2026-06-25).
// Vérifie que (1) les consignes renfo ajoutées s'affichent dans la timeline et
// (2) le jargon coureur glosé (VMA / seuil / excentrique) ressort en badge tappable
// via GlossaryRichText.
//
// ⚠️ Limite host (cf autres snapshots) : LocalizedStringKey FR non résolus → certains
// libellés chrome en raw key. Le filet protège le rendu des notes + le badging glossaire.
import XCTest
import SwiftUI
import SnapshotTesting

@MainActor
final class RunningComprehensibilitySnapshotTests: XCTestCase {

    private func host(_ view: some View) -> some View {
        view
            .environment(\.locale, Locale(identifier: "fr"))
            .environment(\.languageManager, LanguageManager())
            .background(Color.coachingBackground)
            .frame(width: 390)
    }

    func testRunningSessionShowsConsignesAndGlossaryBadges() {
        let session = AdaptedSession(
            day: 3,
            name: "Tempo + renforcement",
            durationMinutes: 50,
            type: .endurance,
            warmup: "15 min footing facile, montée progressive vers l'allure cible.",
            exercises: [
                AdaptedExercise(
                    name: "Tempo en continu (au seuil)",
                    originalName: "Tempo seuil", sets: 1, reps: "20 min",
                    notes: "Allure au seuil : confortablement dur, tu dis 4-5 mots, pas une phrase. Allure soutenue mais tenable, reste régulier."),
                AdaptedExercise(
                    name: "Séries de 600 m (allure VMA)",
                    originalName: "Series 600 VMA", sets: 5, reps: "600 m",
                    notes: "Allure VMA = très rapide, proche de ton effort max sur quelques minutes. Récup en footing facile entre chaque."),
                AdaptedExercise(
                    name: "Mollets excentriques sur une marche",
                    originalName: "Mollets excentriques marche", sets: 3, reps: "12",
                    notes: "Avant des pieds sur le bord d'une marche, talons dans le vide. Monte à deux pieds, puis redescends lentement (3-4 sec) sur un pied, talon sous le niveau de la marche."),
            ],
            cooldown: "5 min marche + étirements légers mollets + ischio-jambiers."
        )
        let view = ScrollView {
            SessionTimelineView(session: session, sportColor: .coachingPrimary, sportCode: "running")
                .padding()
        }
        assertSnapshot(
            of: host(view),
            as: .image(precision: 0.99, perceptualPrecision: 0.97,
                       layout: .device(config: .iPhone13Pro))
        )
    }
}
