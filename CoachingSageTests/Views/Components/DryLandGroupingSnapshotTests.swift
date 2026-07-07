// CoachingSageTests/Views/Components/DryLandGroupingSnapshotTests.swift
// Filet visuel — chantier compréhensibilité natation (structurel hors-eau, 2026-06-24).
// Vérifie que SessionTimelineView regroupe les exos HORS DE L'EAU (dryLand) en fin de
// séance derrière le bandeau « à faire hors de l'eau », au lieu de les intercaler.
//
// ⚠️ Limite locale (cf autres snapshots) : LocalizedStringKey non résolus FR dans le
// host SnapshotTesting → le bandeau apparaît en raw key dans le .png. Le filet protège
// le LAYOUT/ordre (eau → cooldown → bandeau → hors-eau), pas le wording.
import XCTest
import SwiftUI
import SnapshotTesting

@MainActor
final class DryLandGroupingSnapshotTests: XCTestCase {

    private func host(_ view: some View) -> some View {
        view
            .environment(\.locale, Locale(identifier: "fr"))
            .environment(\.languageManager, LanguageManager())
            .background(Color.coachingBackground)
            .frame(width: 390)
    }

    func testSwimmingSessionGroupsDryLandAtEnd() {
        let session = AdaptedSession(
            day: 2,
            name: "Technique + renforcement",
            durationMinutes: 45,
            type: .technique,
            warmup: "200 m crawl allure facile",
            exercises: [
                AdaptedExercise(name: "Crawl rattrapé — un bras attend l'autre",
                                originalName: "Crawl rattrapé", sets: 4, reps: "25 m"),
                AdaptedExercise(name: "Godille (mains qui dessinent des 8)",
                                originalName: "Godille", sets: 2, reps: "25 m"),
                // Hors-eau (dryLand: true) → doivent atterrir SOUS le bandeau, en fin.
                AdaptedExercise(name: "Rotation de l'épaule à l'élastique",
                                originalName: "Rotation externe élastique", sets: 3, reps: "15",
                                dryLand: true),
                AdaptedExercise(name: "Serrage des omoplates",
                                originalName: "Serrage omoplates", sets: 3, reps: "12",
                                dryLand: true),
            ],
            cooldown: "100 m dos très lent"
        )
        let view = ScrollView {
            SessionTimelineView(session: session, sportColor: .coachingPrimary, sportCode: "swimming")
                .padding()
        }
        assertSnapshot(
            of: host(view),
            as: .image(precision: 0.99, perceptualPrecision: 0.97,
                       layout: .device(config: .iPhone13Pro))
        )
    }
}
