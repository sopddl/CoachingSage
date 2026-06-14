// CoachingSageTests/Views/Components/SpanishExerciseNameSnapshotTests.swift
// Passe qualité #2c/#2d ES — « screenshot swift » : rend de VRAIES cartes
// d'exercice (`ExerciseTimelineCard`) alimentées par le vrai template PPL chargé
// via `TemplateLoader`, sous locale ES, et les fige en .png. Prouve VISUELLEMENT
// (sans simu ni MCP) que les noms d'exos s'affichent bien en espagnol traduit
// (« Press de banca con barra », « Press militar con barra de pie »…), pas en
// anglais. Double emploi : capture relisible + filet de régression visuel.
//
// La carte lit `@Environment(\.locale)` et rend `exercise.displayName(locale)`
// → `LocalizedText.resolved(locale)` honore directement la locale injectée (≠
// Bundle.main). Le NOM rend donc correctement en ES. (Limite connue partagée
// avec les autres snapshots : les `LocalizedStringKey` des chips — « rest » —
// restent en raw key, hors périmètre de ce filet qui cible le NOM d'exo.)
//
// Mode `record` : 1ʳᵉ exécution crée les .png de référence sous `__Snapshots__/`.
// Pour reset après changement de contenu intentionnel : supprimer le .png + relancer.
import XCTest
import SwiftUI
import SnapshotTesting
import TemplateModel
import TemplateLoader

@MainActor
final class SpanishExerciseNameSnapshotTests: XCTestCase {

    private let spanishLocale = Locale(identifier: "es")

    private func adapted(from t: TemplateExercise) -> AdaptedExercise {
        AdaptedExercise(
            name: t.name,
            originalName: t.stableMatchKey,
            sets: t.sets,
            reps: t.reps,
            duration: t.duration,
            restSeconds: t.restSeconds,
            notes: t.notes,
            targetZone: t.targetZone
        )
    }

    private func card(_ ex: AdaptedExercise) -> some View {
        ExerciseTimelineCard(exercise: ex, sportCode: "strengthTraining", isFirstExercise: false)
            .frame(width: 350)
            .padding()
            .background(Color(uiColor: .systemBackground))
            .environment(\.locale, spanishLocale)
    }

    /// Rend les 3 premiers exos de la vraie séance PPL (semaine 1, Push A) en ES.
    func testRealPPLExercisesRenderInSpanish() async throws {
        let templates = try await TemplateLoader.loadAll()
        guard templates.count >= 30 else { throw XCTSkip("bundle non peuplé (\(templates.count))") }
        guard let ppl = templates.first(where: { $0.id == "strength-training-regular-ppl-12sem" }),
              let session = ppl.weeks.first?.sessions.first else {
            throw XCTSkip("template PPL / séance absente")
        }
        let exos = Array(session.exercises.prefix(3)).map(adapted(from:))
        XCTAssertEqual(exos.count, 3, "séance PPL attendue avec ≥3 exos")

        // Sanity textuel : les noms rendus en ES sont bien espagnols (anchors).
        XCTAssertEqual(exos[0].displayName(spanishLocale), "Press de banca con barra — series tope pesadas")
        XCTAssertEqual(exos[1].displayName(spanishLocale), "Press militar con barra de pie")

        for (i, ex) in exos.enumerated() {
            let view = card(ex)
            assertSnapshot(
                of: view,
                as: .image(precision: 0.99, perceptualPrecision: 0.97,
                           layout: .fixed(width: 350, height: 360)),
                testName: "ppl_es_exo_\(i)"
            )
        }
    }
}
