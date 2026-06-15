// CoachingSageTests/Coaching/Session/DoseSportGateTests.swift
// Chantier structuration i18n du dosage — Lot 2 running, Lot 3 cycling.
//
// Filet du GATE sport : le backfill `LegacyDoseMigration` (display-time) ne doit s'appliquer
// QU'AUX sports migrés (yoga/running/cycling). Sinon un dosage legacy générique partagé (« 12 »,
// « 30 min »…) serait réinterprété sur un sport non migré — typiquement la MUSCU, dont les
// reps « 12 » s'affichent en héros propre (party muscu) qu'on écraserait. Régression réelle
// introduite quand la table migration a gagné des clés génériques (reps nues, durées rondes).
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

    // MARK: Sport NON migré → dosage legacy préservé (gate fermé)

    func testStrengthRepsAreNotReinterpreted() {
        // Cœur de la non-régression muscu : reps « 12 » NE doit PAS sortir un dose.
        let ex = AdaptedExercise(name: "Pompes", originalName: "Pompes", sets: 3, reps: "12")
        XCTAssertNil(ex.localizedDoseLabel(sportCode: "strengthTraining", locale: fr),
                     "la muscu garde son affichage héros (reps legacy non réinterprétées)")
    }

    func testStrengthGenericDurationIsNotReinterpreted() {
        // « 30 min » NE doit PAS sortir un dose sur un sport NON migré (muscu garde son affichage).
        let ex = AdaptedExercise(name: "Gainage", originalName: "Gainage", duration: "30 min")
        XCTAssertNil(ex.localizedDoseLabel(sportCode: "strengthTraining", locale: fr))
    }

    func testNilSportCodeDoesNotReinterpret() {
        let ex = AdaptedExercise(name: "Pompes", originalName: "Pompes", reps: "12")
        XCTAssertNil(ex.localizedDoseLabel(sportCode: nil, locale: fr))
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
