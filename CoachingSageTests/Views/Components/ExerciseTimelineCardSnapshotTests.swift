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

    // Tolérances : sub-pixel antialiasing varie entre runs (~0.1% pixels / 47-200B
    // sur ~88KB PNG). `perceptualPrecision: 0.97` couvre cette variance sans masquer
    // une vraie régression layout/illustration/chips.
    func testCardStableState_running() {
        let view = runningIntervalCard(isFirst: false)
        assertSnapshot(of: view, as: .image(precision: 0.99, perceptualPrecision: 0.97, layout: .fixed(width: 350, height: 380)))
    }

    func testCardFirstExercise_postPulseDone_running() {
        // Même rendu que non-first quand flag pulse=done : disclosure visible, pas d'anim.
        let view = runningIntervalCard(isFirst: true)
        assertSnapshot(of: view, as: .image(precision: 0.99, perceptualPrecision: 0.97, layout: .fixed(width: 350, height: 380)))
    }

    func testCardSubstituted_strength() {
        let view = substitutedStrengthCard()
        assertSnapshot(of: view, as: .image(precision: 0.99, perceptualPrecision: 0.97, layout: .fixed(width: 350, height: 420)))
    }

    // Note : pas de snapshot EN — `.environment(\.locale, .en)` ne swizzle pas
    // le bundle de localisation, donc les strings restent en FR. Couverture EN
    // visuelle = story snapshot-infra dédiée à venir (bundle swizzle).

    // MARK: - Lot 2 running — dosage localisé (FR/EN/ES)

    // Contrairement au chrome (LocalizedStringKey, non swizzlé → reste FR), les CHIPS dose
    // passent par `DoseFormatter.string(dose, locale:)` qui lit la VALEUR de `\.locale` →
    // ces snapshots montrent bien le dosage localisé EN/ES (zéro fuite FR = l'invariant clé).
    // Exos en `reps`/`duration` legacy → dose via backfill migration (sportCode running).
    private func runningDoseColumn(locale: Locale) -> some View {
        let exos: [AdaptedExercise] = [
            AdaptedExercise(name: "Sortie longue", originalName: "Sortie longue", duration: "9 km", targetZone: "Daniels-E"),
            AdaptedExercise(name: "Montées de genou", originalName: "Montées de genou", sets: 3, reps: "10 par jambe"),
            AdaptedExercise(name: "Run/Walk", originalName: "Run/Walk", sets: 8, duration: "3 min course + 2 min marche"),
            AdaptedExercise(name: "Run/Walk progressif", originalName: "Run/Walk progressif", sets: 6, duration: "1 min 30 course + 2 min marche"),
        ]
        return VStack(spacing: 8) {
            ForEach(Array(exos.enumerated()), id: \.offset) { _, ex in
                ExerciseTimelineCard(exercise: ex, sportCode: "running", isFirstExercise: false)
            }
        }
        .frame(width: 360)
        .padding()
        .background(Color(uiColor: .systemBackground))
        .environment(\.locale, locale)
    }

    func testRunningDose_fr() {
        assertSnapshot(of: runningDoseColumn(locale: Locale(identifier: "fr")),
                       as: .image(precision: 0.99, perceptualPrecision: 0.97, layout: .sizeThatFits))
    }

    func testRunningDose_en() {
        assertSnapshot(of: runningDoseColumn(locale: Locale(identifier: "en")),
                       as: .image(precision: 0.99, perceptualPrecision: 0.97, layout: .sizeThatFits))
    }

    func testRunningDose_es() {
        assertSnapshot(of: runningDoseColumn(locale: Locale(identifier: "es")),
                       as: .image(precision: 0.99, perceptualPrecision: 0.97, layout: .sizeThatFits))
    }

    // MARK: - Lot 3 cycling — dosage localisé (FR/EN/ES)

    // Cas représentatifs : glose d'intensité « tempo soutenu » DROPPÉE → « 10 min » nu,
    // qualificateur neuf `perPosition`, reps per-leg, freeText terrain (D+/montée) + cadence
    // (rpm). Le chrome reste FR (LocalizedStringKey non swizzlé) mais les chips dose suivent
    // `\.locale` → l'invariant « zéro fuite FR EN/ES » est visible directement sur le rendu.
    private func cyclingDoseColumn(locale: Locale) -> some View {
        let exos: [AdaptedExercise] = [
            AdaptedExercise(name: "Sortie tranquille", originalName: "Sortie tranquille", duration: "45 min", targetZone: "FTP-Z2"),
            AdaptedExercise(name: "Blocs allure soutenue", originalName: "Blocs allure soutenue", sets: 3, duration: "10 min tempo soutenu", targetZone: "Sweet-Spot"),
            AdaptedExercise(name: "Cadence haute", originalName: "Cadence haute", sets: 6, duration: "2 min à 100-105 rpm", targetZone: "FTP-Z2"),
            AdaptedExercise(name: "Répétitions en côte", originalName: "Répétitions en côte", sets: 5, duration: "2 min en montée", targetZone: "FTP-Z4"),
            AdaptedExercise(name: "Gainage ventral + dorsal", originalName: "Gainage ventral + dorsal", duration: "40 sec par position", targetZone: "RPE 7-8"),
            AdaptedExercise(name: "Pont fessier unilatéral", originalName: "Pont fessier unilatéral", sets: 2, reps: "12 par jambe"),
            AdaptedExercise(name: "Cyclosportive", originalName: "Cyclosportive", duration: "180-220 km / 3000+ m D+", targetZone: "FTP-Z2"),
        ]
        return VStack(spacing: 8) {
            ForEach(Array(exos.enumerated()), id: \.offset) { _, ex in
                ExerciseTimelineCard(exercise: ex, sportCode: "cycling", isFirstExercise: false)
            }
        }
        .frame(width: 360)
        .padding()
        .background(Color(uiColor: .systemBackground))
        .environment(\.locale, locale)
    }

    func testCyclingDose_fr() {
        assertSnapshot(of: cyclingDoseColumn(locale: Locale(identifier: "fr")),
                       as: .image(precision: 0.99, perceptualPrecision: 0.97, layout: .sizeThatFits))
    }

    func testCyclingDose_en() {
        assertSnapshot(of: cyclingDoseColumn(locale: Locale(identifier: "en")),
                       as: .image(precision: 0.99, perceptualPrecision: 0.97, layout: .sizeThatFits))
    }

    func testCyclingDose_es() {
        assertSnapshot(of: cyclingDoseColumn(locale: Locale(identifier: "es")),
                       as: .image(precision: 0.99, perceptualPrecision: 0.97, layout: .sizeThatFits))
    }

    // MARK: - Lot 4 swimming — dosage localisé (FR/EN/ES)

    // Cas représentatifs : distance nue (glose intensité/allure DROPPÉE → « 1500 m », portée
    // par la chip zone), nage spécifiée crawl/dos en freeText, éducatif/récup/matériel en
    // freeText, renfo à sec `perLetter`. Chips dose suivent `\.locale` → invariant zéro fuite FR.
    private func swimmingDoseColumn(locale: Locale) -> some View {
        let exos: [AdaptedExercise] = [
            AdaptedExercise(name: "Nage longue", originalName: "Nage longue", duration: "1500 m", targetZone: "EN1"),
            AdaptedExercise(name: "Bloc VO2max", originalName: "Bloc VO2max", sets: 8, duration: "100 m endurance haute", targetZone: "EN3"),
            AdaptedExercise(name: "Nage récupération", originalName: "Nage récupération", duration: "150 m dos lent", targetZone: "REC"),
            AdaptedExercise(name: "Bloc endurance", originalName: "Bloc endurance", sets: 8, duration: "100 m crawl + 20 s récup", targetZone: "EN1"),
            AdaptedExercise(name: "Bras au pull-buoy", originalName: "Bras au pull-buoy", sets: 4, duration: "50 m crawl avec pull-buoy entre les jambes + 20 s récup", targetZone: "technique"),
            AdaptedExercise(name: "Position flèche", originalName: "Position flèche", sets: 6, duration: "1 poussée + glisse 8 m", targetZone: "technique"),
            AdaptedExercise(name: "Y-T-W épaules", originalName: "Y-T-W épaules", sets: 2, reps: "10 par lettre", targetZone: "RPE 6-7"),
        ]
        return VStack(spacing: 8) {
            ForEach(Array(exos.enumerated()), id: \.offset) { _, ex in
                ExerciseTimelineCard(exercise: ex, sportCode: "swimming", isFirstExercise: false)
            }
        }
        .frame(width: 360)
        .padding()
        .background(Color(uiColor: .systemBackground))
        .environment(\.locale, locale)
    }

    func testSwimmingDose_fr() {
        assertSnapshot(of: swimmingDoseColumn(locale: Locale(identifier: "fr")),
                       as: .image(precision: 0.99, perceptualPrecision: 0.97, layout: .sizeThatFits))
    }

    func testSwimmingDose_en() {
        assertSnapshot(of: swimmingDoseColumn(locale: Locale(identifier: "en")),
                       as: .image(precision: 0.99, perceptualPrecision: 0.97, layout: .sizeThatFits))
    }

    func testSwimmingDose_es() {
        assertSnapshot(of: swimmingDoseColumn(locale: Locale(identifier: "es")),
                       as: .image(precision: 0.99, perceptualPrecision: 0.97, layout: .sizeThatFits))
    }
}
