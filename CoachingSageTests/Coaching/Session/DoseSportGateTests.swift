// CoachingSageTests/Coaching/Session/DoseSportGateTests.swift
// Chantier structuration i18n du dosage — Lots 2→7 (running, cycling, swimming, hiking, hiit, muscu).
//
// Filet du GATE sport : le backfill `LegacyDoseMigration` (display-time) ne s'applique QU'AUX
// sports de `doseMigratedSports`. Sur un sport NON migré, un dosage legacy générique partagé
// (« 12 », « 30 min »…) ne doit pas être réinterprété (gate fermé → `nil`). Depuis le Lot 7, la
// MUSCU EST migrée : ses reps sont réinterprétées MAIS rendues en COMPACT (« 3 × 12 », pas
// « 3 × 12 reps ») pour préserver l'affichage reps-héros minimal de la party muscu.
import XCTest
import TemplateModel

final class DoseSportGateTests: XCTestCase {

    private let fr = Locale(identifier: "fr")

    // MARK: Sport migré → le backfill s'applique

    func testRunningRepsAreReinterpretedViaMigration() {
        let ex = AdaptedExercise(name: "Fentes", originalName: "Fentes", reps: "12")
        let label = ex.localizedDoseLabel(sportCode: "running", locale: fr)
        XCTAssertEqual(label, "12 reps", "un reps legacy running doit être backfillé en dose structuré")
    }

    func testRunningPerLegRepsLeakWasFixed() {
        // « 10 par jambe » n'était PAS détecté par l'ancien chemin unilatéral (côté/side/lado).
        let ex = AdaptedExercise(name: "Montées de genou", originalName: "Montées de genou", reps: "10 par jambe")
        XCTAssertEqual(ex.localizedDoseLabel(sportCode: "running", locale: Locale(identifier: "en")), "10 reps per leg")
    }

    func testCyclingDurationIsReinterpretedViaMigration() {
        // Lot 3 : un sport migré → backfill display-time depuis la string legacy.
        let ex = AdaptedExercise(name: "Sortie tranquille", originalName: "Sortie tranquille", duration: "45 min")
        XCTAssertEqual(ex.localizedDoseLabel(sportCode: "cycling", locale: fr), "45 min")
    }

    func testCyclingPerPositionIsLocalizedWithoutLeak() {
        // « 40 sec par position » (gainage cycliste) localisé en EN, zéro fuite FR.
        let ex = AdaptedExercise(name: "Gainage", originalName: "Gainage", duration: "40 sec par position")
        XCTAssertEqual(ex.localizedDoseLabel(sportCode: "cycling", locale: Locale(identifier: "en")), "40 s per position")
    }

    func testSwimmingDistanceIsReinterpretedViaMigration() {
        // Lot 4 : distance nue backfillée (« m » universel).
        let ex = AdaptedExercise(name: "Nage continue", originalName: "Nage continue", duration: "1500 m")
        XCTAssertEqual(ex.localizedDoseLabel(sportCode: "swimming", locale: fr), "1500 m")
    }

    func testSwimmingStrokeFreeTextIsLocalized() {
        // « 150 m dos lent » (nage spécifiée) → freeText traduit, zéro fuite FR en EN/ES.
        let ex = AdaptedExercise(name: "Nage récup", originalName: "Nage récup", duration: "150 m dos lent")
        XCTAssertEqual(ex.localizedDoseLabel(sportCode: "swimming", locale: Locale(identifier: "en")), "150 m easy backstroke")
        XCTAssertEqual(ex.localizedDoseLabel(sportCode: "swimming", locale: Locale(identifier: "es")), "150 m espalda suave")
    }

    func testHikingRenfoPerLegIsLocalizedWithoutLeak() {
        // Lot 5 : renfo « 30 sec par jambe » structuré, localisé EN, zéro fuite FR.
        let ex = AdaptedExercise(name: "Fentes", originalName: "Fentes", duration: "30 sec par jambe")
        XCTAssertEqual(ex.localizedDoseLabel(sportCode: "hiking", locale: Locale(identifier: "en")), "30 s per leg")
    }

    func testHikingTerrainCompositeIsLocalized() {
        // Lot 5 : composite marche/D+/sac → freeText traduit (D+ → elevation gain).
        let ex = AdaptedExercise(name: "Marche", originalName: "Marche", duration: "100 min marche / D+ 280 m / sac 6 kg")
        XCTAssertEqual(ex.localizedDoseLabel(sportCode: "hiking", locale: Locale(identifier: "en")),
                       "100 min walk / 280 m elevation gain / 6 kg pack")
    }

    func testHiitWorkRestIntervalIsLocalized() {
        // Lot 6 : intervalle work/rest → Dose.interval, localisé EN/ES sans fuite FR.
        let ex = AdaptedExercise(name: "Tabata", originalName: "Tabata", duration: "20 sec work + 10 sec rest")
        XCTAssertEqual(ex.localizedDoseLabel(sportCode: "hiit", locale: Locale(identifier: "en")), "20 s work + 10 s rest")
        XCTAssertEqual(ex.localizedDoseLabel(sportCode: "hiit", locale: Locale(identifier: "es")), "20 s de trabajo + 10 s de descanso")
    }

    func testHiitPerRoundIsReinterpretedViaMigration() {
        // Lot 6 : « 1 min par round » structuré perRound.
        let ex = AdaptedExercise(name: "AMRAP", originalName: "AMRAP", duration: "1 min par round")
        XCTAssertEqual(ex.localizedDoseLabel(sportCode: "hiit", locale: fr), "1 min par round")
    }

    // MARK: Muscu MIGRÉE (Lot 7) — reps compactes (party reps-héros) + latéralité localisée

    func testStrengthRepsAreCompactNoUnitNoun() {
        // Party muscu : le chip reste minimal « 3 × 12 » (PAS « 3 × 12 reps ») — rendu compact.
        let ex = AdaptedExercise(name: "Pompes", originalName: "Pompes", sets: 3, reps: "12")
        XCTAssertEqual(ex.localizedDoseLabel(sportCode: "strengthTraining", locale: fr), "3 × 12")
    }

    func testStrengthPerLegLeakIsFixed() {
        // LE point du lot : « 10 par jambe » fuyait en EN/ES (non couvert par localizedReps).
        let ex = AdaptedExercise(name: "Fentes", originalName: "Fentes", sets: 3, reps: "10 par jambe")
        XCTAssertEqual(ex.localizedDoseLabel(sportCode: "strengthTraining", locale: Locale(identifier: "en")), "3 × 10 per leg")
        XCTAssertEqual(ex.localizedDoseLabel(sportCode: "strengthTraining", locale: Locale(identifier: "es")), "3 × 10 por pierna")
    }

    func testStrengthPerShoulderLeakIsFixed() {
        // « 5 par épaule » : autre fuite non couverte par l'ancien chemin unilatéral.
        let ex = AdaptedExercise(name: "Press", originalName: "Press", reps: "5 par épaule")
        XCTAssertEqual(ex.localizedDoseLabel(sportCode: "strengthTraining", locale: Locale(identifier: "en")), "5 per shoulder")
    }

    func testStrengthFreeTextSchemeIsLocalized() {
        // « max propre » freeText traduit (pas de fuite FR « propre » en EN).
        let ex = AdaptedExercise(name: "Tractions", originalName: "Tractions", reps: "max propre")
        XCTAssertEqual(ex.localizedDoseLabel(sportCode: "strengthTraining", locale: Locale(identifier: "en")), "clean max")
    }

    func testStrengthHoldSecondsKeepsUnitNoun() {
        // Tenue exprimée dans reps (« 75 sec ») → secondes, le nom « s » est GARDÉ même compact.
        let ex = AdaptedExercise(name: "Planche", originalName: "Planche", reps: "75 sec")
        XCTAssertEqual(ex.localizedDoseLabel(sportCode: "strengthTraining", locale: fr), "75 s")
    }

    // MARK: Héros muscu (mode Minuté) — chiffre + latéralité tirés du dose structuré

    func testRepsHeroDoseStripsLateralityIntoFlag() {
        // « 10 par jambe » → chiffre héros « 10 » + drapeau latéralité (plus de fuite « par jambe »).
        let ex = AdaptedExercise(name: "Fentes", originalName: "Fentes", sets: 3, reps: "10 par jambe")
        let hero = ex.repsHeroDose(sportCode: "strengthTraining", locale: Locale(identifier: "en"))
        XCTAssertEqual(hero?.value, "10")
        XCTAssertEqual(hero?.isLateral, true)
    }

    func testRepsHeroDosePlainRepsNotLateral() {
        let ex = AdaptedExercise(name: "Pompes", originalName: "Pompes", sets: 3, reps: "12")
        let hero = ex.repsHeroDose(sportCode: "strengthTraining", locale: fr)
        XCTAssertEqual(hero?.value, "12")
        XCTAssertEqual(hero?.isLateral, false)
    }

    func testRepsHeroDoseSecondsHoldReturnsNil() {
        // Tenue en secondes → pas un héros reps : la vue retombe sur le chrono/bigTime.
        let ex = AdaptedExercise(name: "Planche", originalName: "Planche", reps: "75 sec")
        XCTAssertNil(ex.repsHeroDose(sportCode: "strengthTraining", locale: fr))
    }

    // MARK: Tennis + football MIGRÉS (Lot 8) — comptages structurés, intervalles, freeText

    func testTennisServesAreStructured() {
        // Comptage sport STRUCTURÉ (décision Sophie) : « 10 services » → serves localisé.
        let ex = AdaptedExercise(name: "Service", originalName: "Service", reps: "10 services")
        XCTAssertEqual(ex.localizedDoseLabel(sportCode: "tennis", locale: fr), "10 services")
        XCTAssertEqual(ex.localizedDoseLabel(sportCode: "tennis", locale: Locale(identifier: "en")), "10 serves")
        XCTAssertEqual(ex.localizedDoseLabel(sportCode: "tennis", locale: Locale(identifier: "es")), "10 servicios")
    }

    func testTennisDrillIntervalIsLocalized() {
        // Intervalle plat « cross + récup » → Dose.interval, activité drill localisée sans fuite.
        let ex = AdaptedExercise(name: "Cross-court", originalName: "Cross-court", duration: "5 min cross + 90 sec récup")
        XCTAssertEqual(ex.localizedDoseLabel(sportCode: "tennis", locale: Locale(identifier: "en")), "5 min cross-court + 90 s rest")
        XCTAssertEqual(ex.localizedDoseLabel(sportCode: "tennis", locale: Locale(identifier: "es")), "5 min cruzado + 90 s de descanso")
    }

    func testFootballPassesPerFootFreeTextIsLocalized() {
        // « 20 passes par pied (40 total) » : sous-spec gardée → freeText traduit, zéro fuite FR.
        let ex = AdaptedExercise(name: "Passes", originalName: "Passes", reps: "20 passes par pied (40 total)")
        XCTAssertEqual(ex.localizedDoseLabel(sportCode: "football", locale: Locale(identifier: "en")), "20 passes per foot (40 total)")
    }

    func testFootballOnOffIntervalIsLocalized() {
        // « 4-5 min ON / 2 min OFF » → interval work/rest localisé.
        let ex = AdaptedExercise(name: "Jeu réduit", originalName: "Jeu réduit", duration: "4-5 min ON / 2 min OFF")
        XCTAssertEqual(ex.localizedDoseLabel(sportCode: "football", locale: Locale(identifier: "en")), "4-5 min work + 2 min rest")
    }

    func testNilSportCodeDoesNotReinterpret() {
        let ex = AdaptedExercise(name: "Pompes", originalName: "Pompes", reps: "12")
        XCTAssertNil(ex.localizedDoseLabel(sportCode: nil, locale: fr))
        XCTAssertNil(ex.repsHeroDose(sportCode: nil, locale: fr))
    }

    // MARK: Overview compact — intervalle répété résumé par sa durée TOTALE (Sophie 2026-06-03)

    func testOverviewSummarizesRepeatedIntervalAsTotalNotSegments() {
        // 8 × (3 min course + 2 min marche) = 40 min : la synthèse 1-ligne montre le total,
        // pas « 8 × 3 min de course + 2 min de marche » (déborde).
        let ex = AdaptedExercise(name: "Fractionné", originalName: "Fractionné",
                                 sets: 8, duration: "3 min course + 2 min marche")
        XCTAssertEqual(SessionOverviewList.compactMetric(for: ex, locale: fr, sportCode: "running"), "40 min")
    }

    func testOverviewSummarizesFreeTextIntervalAsTotal() {
        // « 1 min 30 » → dose freeText (choix Sophie) ; l'overview résume quand même par le
        // total : 8 × (90 s + 120 s) = 1680 s = 28 min. Le critère est la durée, pas le type.
        let ex = AdaptedExercise(name: "Fractionné", originalName: "Fractionné",
                                 sets: 8, duration: "1 min 30 course + 2 min marche")
        XCTAssertEqual(SessionOverviewList.compactMetric(for: ex, locale: fr, sportCode: "running"), "28 min")
    }

    func testOverviewUsesLocalizedDoseForSingleSegment() {
        // Intervalle 1-segment sans répétition : on garde le dose localisé (pas de fuite FR verbatim).
        let ex = AdaptedExercise(name: "Course continue", originalName: "Course continue", duration: "5 min course")
        XCTAssertEqual(SessionOverviewList.compactMetric(for: ex, locale: Locale(identifier: "en"), sportCode: "running"),
                       "5 min running")
    }

    // MARK: Cohérence cross-représentation timer ↔ overview (le gap « live » du Minuté/Audio)

    // Invariant : ce que le TIMER décompte (Minuté/Audio, lu sur la durée FR canonical) doit
    // égaler ce que l'OVERVIEW résume (total). Si un dose désynchronisait l'affichage du chrono,
    // l'utilisateur verrait un total ≠ du temps réellement décompté. Couvre le cas que seul un
    // device-test voyait avant.
    private func timerWorkRestSeconds(_ ex: AdaptedExercise) -> Int {
        let session = AdaptedSession(day: 1, name: "Fractionné", durationMinutes: 40, type: .mixed,
                                     warmup: nil, exercises: [ex], cooldown: nil)
        return SessionTimerPhaseBuilder.phases(for: session, sportCode: "running")
            .filter { $0.kind == .work || $0.kind == .rest }
            .reduce(0) { $0 + $1.duration }
    }

    func testTimerTotalMatchesOverviewForStructuredInterval() {
        // 8 × (3 min course + 2 min marche) = 2400 s = 40 min.
        let ex = AdaptedExercise(name: "Run/Walk", originalName: "Run/Walk",
                                 sets: 8, duration: "3 min course + 2 min marche", restSeconds: 0)
        let timerSec = timerWorkRestSeconds(ex)
        XCTAssertEqual(timerSec, 8 * (180 + 120))
        XCTAssertEqual(SessionOverviewList.compactMetric(for: ex, locale: fr, sportCode: "running"), "\(timerSec / 60) min")
    }

    func testTimerTotalMatchesOverviewForFreeTextInterval() {
        // « 1 min 30 » → dose freeText, mais timer + overview restent cohérents :
        // 6 × (90 s + 120 s) = 1260 s = 21 min.
        let ex = AdaptedExercise(name: "Run/Walk progressif", originalName: "Run/Walk progressif",
                                 sets: 6, duration: "1 min 30 course + 2 min marche", restSeconds: 0)
        let timerSec = timerWorkRestSeconds(ex)
        XCTAssertEqual(timerSec, 6 * (90 + 120))
        XCTAssertEqual(SessionOverviewList.compactMetric(for: ex, locale: fr, sportCode: "running"), "\(timerSec / 60) min")
    }
}
