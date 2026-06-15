// CoachingSageTests/Coaching/Session/DoseSportGateTests.swift
// Chantier structuration i18n du dosage — Lot 2 running.
//
// Filet du GATE sport : le backfill `LegacyDoseMigration` (display-time) ne doit s'appliquer
// QU'AUX sports migrés (yoga/running). Sinon un dosage legacy générique partagé (« 12 »,
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

    // MARK: Sport NON migré → dosage legacy préservé (gate fermé)

    func testStrengthRepsAreNotReinterpreted() {
        // Cœur de la non-régression muscu : reps « 12 » NE doit PAS sortir un dose.
        let ex = AdaptedExercise(name: "Pompes", originalName: "Pompes", sets: 3, reps: "12")
        XCTAssertNil(ex.localizedDoseLabel(sportCode: "strengthTraining", locale: fr),
                     "la muscu garde son affichage héros (reps legacy non réinterprétées)")
    }

    func testStrengthGenericDurationIsNotReinterpreted() {
        let ex = AdaptedExercise(name: "Gainage", originalName: "Gainage", duration: "30 min")
        XCTAssertNil(ex.localizedDoseLabel(sportCode: "cycling", locale: fr))
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
}
