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

    // MARK: - Lot 5 hiking — dosage localisé (FR/EN/ES)

    // Cas représentatifs : minutes nues, renfo structuré (perSet/perLeg), heures freeText
    // universelles (« 6 h »), composite terrain marche/D+/sac et intervalle montée/descente
    // (RPE/pente inline, vocabulaire gardé) en freeText traduit. Chips dose suivent `\.locale`.
    private func hikingDoseColumn(locale: Locale) -> some View {
        let exos: [AdaptedExercise] = [
            AdaptedExercise(name: "Sortie longue", originalName: "Sortie longue", duration: "240 min", targetZone: "RPE 4-5"),
            AdaptedExercise(name: "Rando journée", originalName: "Rando journée", duration: "6 h", targetZone: "RPE 4-5"),
            AdaptedExercise(name: "Marche chargée", originalName: "Marche chargée", duration: "100 min marche / D+ 280 m / sac 6 kg", targetZone: "RPE 5-6"),
            AdaptedExercise(name: "Répétitions en côte", originalName: "Répétitions en côte", sets: 4, duration: "10 min montée RPE 8-9 gradient 15% sac 17 kg + 8 min descente très facile"),
            AdaptedExercise(name: "Fentes lestées", originalName: "Fentes lestées", sets: 3, reps: "8 par série"),
            AdaptedExercise(name: "Gainage latéral", originalName: "Gainage latéral", duration: "30 sec par jambe"),
        ]
        return VStack(spacing: 8) {
            ForEach(Array(exos.enumerated()), id: \.offset) { _, ex in
                ExerciseTimelineCard(exercise: ex, sportCode: "hiking", isFirstExercise: false)
            }
        }
        .frame(width: 360)
        .padding()
        .background(Color(uiColor: .systemBackground))
        .environment(\.locale, locale)
    }

    func testHikingDose_fr() {
        assertSnapshot(of: hikingDoseColumn(locale: Locale(identifier: "fr")),
                       as: .image(precision: 0.99, perceptualPrecision: 0.97, layout: .sizeThatFits))
    }

    func testHikingDose_en() {
        assertSnapshot(of: hikingDoseColumn(locale: Locale(identifier: "en")),
                       as: .image(precision: 0.99, perceptualPrecision: 0.97, layout: .sizeThatFits))
    }

    func testHikingDose_es() {
        assertSnapshot(of: hikingDoseColumn(locale: Locale(identifier: "es")),
                       as: .image(precision: 0.99, perceptualPrecision: 0.97, layout: .sizeThatFits))
    }

    // MARK: - Lot 6 hiit — dosage localisé (FR/EN/ES)

    // Cas représentatifs : intervalle work/rest (Dose.interval, activités neuves), « X min par
    // round » structuré, secondes nues, reps par bras, composite de gainage freeText (planche/
    // ventrale/latérale traduits, noms d'exos internationaux gardés). Chips dose suivent `\.locale`.
    private func hiitDoseColumn(locale: Locale) -> some View {
        let exos: [AdaptedExercise] = [
            AdaptedExercise(name: "Tabata", originalName: "Tabata", sets: 8, duration: "20 sec work + 10 sec rest", targetZone: "RPE 9"),
            AdaptedExercise(name: "AMRAP", originalName: "AMRAP", sets: 5, duration: "1 min par round", targetZone: "RPE 8"),
            AdaptedExercise(name: "Effort long", originalName: "Effort long", sets: 4, duration: "180 sec", targetZone: "RPE 8"),
            AdaptedExercise(name: "Renforcement épaules", originalName: "Renforcement épaules", sets: 3, reps: "10 par bras"),
            AdaptedExercise(name: "Gainage combiné", originalName: "Gainage combiné", sets: 3, duration: "60 sec ventrale + 30 sec latérale/côté"),
            AdaptedExercise(name: "Nordic + split squat", originalName: "Nordic + split squat", sets: 3, reps: "5 Nordic + 8 split squat/jambe DB 12 kg"),
        ]
        return VStack(spacing: 8) {
            ForEach(Array(exos.enumerated()), id: \.offset) { _, ex in
                ExerciseTimelineCard(exercise: ex, sportCode: "hiit", isFirstExercise: false)
            }
        }
        .frame(width: 360)
        .padding()
        .background(Color(uiColor: .systemBackground))
        .environment(\.locale, locale)
    }

    func testHiitDose_fr() {
        assertSnapshot(of: hiitDoseColumn(locale: Locale(identifier: "fr")),
                       as: .image(precision: 0.99, perceptualPrecision: 0.97, layout: .sizeThatFits))
    }

    func testHiitDose_en() {
        assertSnapshot(of: hiitDoseColumn(locale: Locale(identifier: "en")),
                       as: .image(precision: 0.99, perceptualPrecision: 0.97, layout: .sizeThatFits))
    }

    func testHiitDose_es() {
        assertSnapshot(of: hiitDoseColumn(locale: Locale(identifier: "es")),
                       as: .image(precision: 0.99, perceptualPrecision: 0.97, layout: .sizeThatFits))
    }

    // MARK: - Lot 7 muscu — dosage localisé (FR/EN/ES)

    // Cas représentatifs : reps nues + plage en COMPACT (party muscu : « 3 × 12 », pas
    // « 3 × 12 reps »), latéralité jambe/épaule (LES fuites réelles muscu, non couvertes par
    // l'ancien localizedReps) localisées, tenue exprimée en reps → secondes (nom gardé),
    // schémas AMRAP/max freeText traduits. Chips dose suivent `\.locale` → invariant zéro fuite FR.
    private func strengthDoseColumn(locale: Locale) -> some View {
        let exos: [AdaptedExercise] = [
            AdaptedExercise(name: "Développé couché", originalName: "Développé couché", sets: 4, reps: "8-10", targetZone: "RPE 8"),
            AdaptedExercise(name: "Fentes bulgares", originalName: "Fentes bulgares", sets: 3, reps: "10 par jambe"),
            AdaptedExercise(name: "Élévations latérales", originalName: "Élévations latérales", sets: 3, reps: "5 par épaule"),
            AdaptedExercise(name: "Gainage", originalName: "Gainage", reps: "75 sec"),
            AdaptedExercise(name: "Tractions", originalName: "Tractions", sets: 3, reps: "max propre"),
            AdaptedExercise(name: "Soulevé de terre", originalName: "Soulevé de terre", reps: "5, 5, 5, 5+ AMRAP", targetZone: "RPE 9"),
        ]
        return VStack(spacing: 8) {
            ForEach(Array(exos.enumerated()), id: \.offset) { _, ex in
                ExerciseTimelineCard(exercise: ex, sportCode: "strengthTraining", isFirstExercise: false)
            }
        }
        .frame(width: 360)
        .padding()
        .background(Color(uiColor: .systemBackground))
        .environment(\.locale, locale)
    }

    func testStrengthDose_fr() {
        assertSnapshot(of: strengthDoseColumn(locale: Locale(identifier: "fr")),
                       as: .image(precision: 0.99, perceptualPrecision: 0.97, layout: .sizeThatFits))
    }

    func testStrengthDose_en() {
        assertSnapshot(of: strengthDoseColumn(locale: Locale(identifier: "en")),
                       as: .image(precision: 0.99, perceptualPrecision: 0.97, layout: .sizeThatFits))
    }

    func testStrengthDose_es() {
        assertSnapshot(of: strengthDoseColumn(locale: Locale(identifier: "es")),
                       as: .image(precision: 0.99, perceptualPrecision: 0.97, layout: .sizeThatFits))
    }

    // MARK: - Lot 8 tennis — dosage localisé (FR/EN/ES)

    // Cas représentatifs : comptage sport structuré (services), intervalle drill plat
    // (cross/jeu/tie-break + récup → activité localisée), comptage sans activité (frappes +
    // récup marche), composite service freeText (sous-spec gardée). Chips suivent `\.locale`.
    private func tennisDoseColumn(locale: Locale) -> some View {
        let exos: [AdaptedExercise] = [
            AdaptedExercise(name: "Service", originalName: "Service", reps: "10 services", targetZone: "RPE 6-7"),
            AdaptedExercise(name: "Échange croisé", originalName: "Échange croisé", sets: 4, duration: "5 min cross + 90 sec récup", targetZone: "RPE 7-8"),
            AdaptedExercise(name: "Tie-break", originalName: "Tie-break", sets: 2, duration: "10 min tie-break + 3 min récup"),
            AdaptedExercise(name: "Frappes + récup", originalName: "Frappes + récup", sets: 2, duration: "30 frappes + 1 min récup marche"),
            AdaptedExercise(name: "Service ciblé", originalName: "Service ciblé", reps: "10 services (5 T + 5 extérieur)"),
        ]
        return VStack(spacing: 8) {
            ForEach(Array(exos.enumerated()), id: \.offset) { _, ex in
                ExerciseTimelineCard(exercise: ex, sportCode: "tennis", isFirstExercise: false)
            }
        }
        .frame(width: 360)
        .padding()
        .background(Color(uiColor: .systemBackground))
        .environment(\.locale, locale)
    }

    func testTennisDose_fr() {
        assertSnapshot(of: tennisDoseColumn(locale: Locale(identifier: "fr")),
                       as: .image(precision: 0.99, perceptualPrecision: 0.97, layout: .sizeThatFits))
    }

    func testTennisDose_en() {
        assertSnapshot(of: tennisDoseColumn(locale: Locale(identifier: "en")),
                       as: .image(precision: 0.99, perceptualPrecision: 0.97, layout: .sizeThatFits))
    }

    func testTennisDose_es() {
        assertSnapshot(of: tennisDoseColumn(locale: Locale(identifier: "es")),
                       as: .image(precision: 0.99, perceptualPrecision: 0.97, layout: .sizeThatFits))
    }

    // MARK: - Lot 8 football — dosage localisé (FR/EN/ES)

    // Cas représentatifs : passes par pied (composite freeText, sous-spec gardée), intervalle
    // ON/OFF (work/rest), course/marche (intensité Z droppée), jeu effectif (temps universel),
    // équilibre unipodal yeux fermés (freeText). Chips suivent `\.locale`.
    private func footballDoseColumn(locale: Locale) -> some View {
        let exos: [AdaptedExercise] = [
            AdaptedExercise(name: "Passes", originalName: "Passes", reps: "20 passes par pied (40 total)", targetZone: "technique"),
            AdaptedExercise(name: "Jeu réduit", originalName: "Jeu réduit", sets: 4, duration: "4-5 min ON / 2 min OFF", targetZone: "RPE 7-8 intermittent"),
            AdaptedExercise(name: "Intermittent", originalName: "Intermittent", sets: 2, duration: "30 sec course Z3-Z4 + 30 sec marche"),
            AdaptedExercise(name: "Match", originalName: "Match", duration: "90 min jeu effectif"),
            AdaptedExercise(name: "Équilibre", originalName: "Équilibre", duration: "30 sec / jambe yeux fermés"),
        ]
        return VStack(spacing: 8) {
            ForEach(Array(exos.enumerated()), id: \.offset) { _, ex in
                ExerciseTimelineCard(exercise: ex, sportCode: "football", isFirstExercise: false)
            }
        }
        .frame(width: 360)
        .padding()
        .background(Color(uiColor: .systemBackground))
        .environment(\.locale, locale)
    }

    func testFootballDose_fr() {
        assertSnapshot(of: footballDoseColumn(locale: Locale(identifier: "fr")),
                       as: .image(precision: 0.99, perceptualPrecision: 0.97, layout: .sizeThatFits))
    }

    func testFootballDose_en() {
        assertSnapshot(of: footballDoseColumn(locale: Locale(identifier: "en")),
                       as: .image(precision: 0.99, perceptualPrecision: 0.97, layout: .sizeThatFits))
    }

    func testFootballDose_es() {
        assertSnapshot(of: footballDoseColumn(locale: Locale(identifier: "es")),
                       as: .image(precision: 0.99, perceptualPrecision: 0.97, layout: .sizeThatFits))
    }
}
