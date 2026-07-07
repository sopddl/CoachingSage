// CoachingSageTests/Views/SessionSportInferenceDisciplineCodesTests.swift
// Chantier récap hebdo triathlon (2026-07-06) — filet de la fonction d'agrégation
// utilisée par le récap "cette semaine : nage/vélo/course" (AdaptedProgramView).
import XCTest
import TemplateModel

final class SessionSportInferenceDisciplineCodesTests: XCTestCase {

    private func session(_ name: String, type: SessionType = .endurance) -> AdaptedSession {
        AdaptedSession(
            day: 1, name: LocalizedText(fr: name), durationMinutes: 30,
            type: type, warmup: nil, exercises: [], cooldown: nil
        )
    }

    func test_disciplineCodes_triathlonWeek_ordersSwimBikeRun() {
        let week = [
            session("Course — sortie facile"),
            session("Natation — technique crawl"),
            session("Vélo — sortie endurance")
        ]
        XCTAssertEqual(
            SessionSportInference.disciplineCodes(inWeek: week, programSportCode: "triathlon"),
            ["swimming", "cycling", "running"]
        )
    }

    func test_disciplineCodes_excludesStrengthFallbackDays() {
        let week = [
            session("Course — sortie facile"),
            session("Renforcement fondation — triathlon")
        ]
        XCTAssertEqual(
            SessionSportInference.disciplineCodes(inWeek: week, programSportCode: "triathlon"),
            ["running"]
        )
    }

    func test_disciplineCodes_onlyOneDisciplineThisWeek_returnsSingleCode() {
        let week = [
            session("Vélo — endurance"),
            session("Vélo — sortie longue")
        ]
        XCTAssertEqual(
            SessionSportInference.disciplineCodes(inWeek: week, programSportCode: "triathlon"),
            ["cycling"]
        )
    }

    func test_disciplineCodes_monoSportProgram_returnsEmpty() {
        let week = [session("Sortie longue")]
        XCTAssertEqual(
            SessionSportInference.disciplineCodes(inWeek: week, programSportCode: "running"),
            []
        )
    }

    func test_disciplineCodes_allFallbackDays_returnsEmpty() {
        let week = [session("Renforcement fondation — triathlon")]
        XCTAssertEqual(
            SessionSportInference.disciplineCodes(inWeek: week, programSportCode: "triathlon"),
            []
        )
    }
}
