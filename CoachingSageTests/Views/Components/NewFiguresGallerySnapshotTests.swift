// CoachingSageTests/Views/Components/NewFiguresGallerySnapshotTests.swift
// Filet de régression snapshot sur les 25 figures HIIT + yoga ajoutées par le
// chantier dessins-v1-biblio (rebasé sur main 2026-06-16, validé device Sophie
// « tout ok »). Pendant des 5 figures muscu déjà couvertes par
// IllustrationGallerySnapshotTests. Verrouille le rendu via le VRAI pipeline
// (ExercisePatternIllustration pour HIIT, YogaIllustration pour les asanas) :
// toute édition future d'un dessin qui change le rendu fera échouer le test.
//
// 1ère exécution = record (crée les .png sous __Snapshots__/ et "échoue").
// Relancer = comparaison. Re-record après refonte = supprimer le .png concerné.
import XCTest
import SwiftUI
import SnapshotTesting
import TemplateModel
@testable import CoachingSage

@MainActor
final class NewFiguresGallerySnapshotTests: XCTestCase {

    // 8 mouvements HIIT (rendus directement par pattern, comme SessionFocusView)
    private let hiit: [(slug: String, pattern: ExercisePattern)] = [
        ("mountainClimber", .mountainClimber),
        ("jumpingJack", .jumpingJack),
        ("tibialisRaise", .tibialisRaise),
        ("farmerCarry", .farmerCarry),
        ("doubleUnders", .doubleUnders),
        ("sledPush", .sledPush),
        ("powerClean", .powerClean),
        ("turkishGetUp", .turkishGetUp),
    ]

    // 17 asanas yoga avancées (rendues via le nom sanskrit -> détection poseKind)
    private let yoga: [(slug: String, name: String)] = [
        ("salabhasana", "Salabhasana"),
        ("ustrasana", "Ustrasana"),
        ("dhanurasana", "Dhanurasana"),
        ("phalakasana", "Phalakasana"),
        ("upavisthaKonasana", "Upavistha Konasana"),
        ("bakasana", "Bakasana"),
        ("purvottanasana", "Purvottanasana"),
        ("uttanaPadasana", "Uttana Padasana"),
        ("prasaritaPadottanasana", "Prasarita Padottanasana"),
        ("padahastasana", "Padahastasana"),
        ("ardhaMatsyendrasana", "Ardha Matsyendrasana"),
        ("kapotasana", "Kapotasana"),
        ("bhujapidasana", "Bhujapidasana"),
        ("garbhaPindasana", "Garbha Pindasana"),
        ("karnapidasana", "Karnapidasana"),
        ("utthitaHastaPadangusthasana", "Utthita Hasta Padangusthasana"),
        ("ardhaBaddhaPadmottanasana", "Ardha Baddha Padmottanasana"),
    ]

    func testHiitFiguresGallery() {
        for f in hiit {
            let view = ExercisePatternIllustration(
                pattern: f.pattern, sportCode: "hiitCrossTraining",
                exerciseName: f.slug, size: 150
            )
            .frame(width: 320, height: 180)
            .background(Color(uiColor: .secondarySystemBackground))

            assertSnapshot(
                of: view,
                as: .image(precision: 0.99, perceptualPrecision: 0.95, layout: .fixed(width: 320, height: 180)),
                named: f.slug
            )
        }
    }

    func testYogaAdvancedPosesGallery() {
        for f in yoga {
            let view = YogaIllustration(sportCode: "yoga", exerciseName: f.name, size: 170)
                .frame(width: 320, height: 180)
                .background(Color(uiColor: .secondarySystemBackground))

            assertSnapshot(
                of: view,
                as: .image(precision: 0.99, perceptualPrecision: 0.95, layout: .fixed(width: 320, height: 180)),
                named: f.slug
            )
        }
    }
}
