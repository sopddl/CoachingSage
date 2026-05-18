// CoachingSageTests/Coaching/Replanify/ReplanifyServiceTests.swift
// Story 3.11 AC25 — tests unitaires du `DefaultReplanifyService` :
//   - `reportSession` : fin de semaine OU fallback S+1
//   - `shiftWeek` : `weekStartDate` muté, `shiftGeneration` incrémenté
//   - garde-fou routineCyclic
import XCTest
import TemplateModel
@testable import CoachingSage

@MainActor
final class ReplanifyServiceTests: XCTestCase {
    private var repo: MockAdaptedProgramRepository!
    private var service: DefaultReplanifyService!

    override func setUp() async throws {
        try await super.setUp()
        repo = MockAdaptedProgramRepository()
        service = DefaultReplanifyService(adaptedProgramRepository: repo)
    }

    // MARK: - reportSession (AC12)

    func testReportSession_whenMaxDayBelow7_movesToEndOfWeek() async throws {
        let target = makeSession(weekNumber: 1, day: 2)
        let other = makeSession(weekNumber: 1, day: 5)
        let record = makeRecord(
            sessions: [target, other],
            durationMode: .deadlineFixed,
            weekStartDate: Date(timeIntervalSinceNow: -14 * 86_400)
        )
        repo.stubbedActive = [record]

        try await service.reportSession(programId: record.id, sessionId: target.id)

        let updated = try XCTUnwrap(repo.updatedRecords.last)
        let movedSession = try XCTUnwrap(updated.sessions.first { $0.id == target.id })
        XCTAssertEqual(movedSession.weekNumber, 1)
        XCTAssertEqual(movedSession.day, 6, "maxDay (5) + 1")
    }

    func testReportSession_whenMaxDayIs7_fallbacksToWeekPlusOne() async throws {
        let target = makeSession(weekNumber: 1, day: 3)
        let lastOfWeek = makeSession(weekNumber: 1, day: 7)
        let record = makeRecord(
            sessions: [target, lastOfWeek],
            durationMode: .deadlineFixed,
            weekStartDate: Date(timeIntervalSinceNow: -14 * 86_400)
        )
        repo.stubbedActive = [record]

        try await service.reportSession(programId: record.id, sessionId: target.id)

        let updated = try XCTUnwrap(repo.updatedRecords.last)
        let movedSession = try XCTUnwrap(updated.sessions.first { $0.id == target.id })
        XCTAssertEqual(movedSession.weekNumber, 2, "Fallback S+1")
        XCTAssertEqual(movedSession.day, 1)
    }

    func testReportSession_throwsForRoutineCyclic() async {
        let target = makeSession(weekNumber: 1, day: 1)
        let record = makeRecord(
            sessions: [target],
            durationMode: .routineCyclic,
            weekStartDate: Date(timeIntervalSinceNow: -7 * 86_400)
        )
        repo.stubbedActive = [record]

        do {
            try await service.reportSession(programId: record.id, sessionId: target.id)
            XCTFail("Devrait throw ReplanifyError.unsupportedForRoutineMode")
        } catch ReplanifyError.unsupportedForRoutineMode {
            // OK
        } catch {
            XCTFail("Mauvaise erreur : \(error)")
        }
    }

    func testReportSession_throwsForUnknownProgram() async {
        let randomId = UUID()
        do {
            try await service.reportSession(programId: randomId, sessionId: UUID())
            XCTFail("Devrait throw")
        } catch ReplanifyError.programNotFound {
            // OK
        } catch {
            XCTFail("Mauvaise erreur : \(error)")
        }
    }

    func testReportSession_throwsForUnknownSession() async {
        let record = makeRecord(
            sessions: [makeSession(weekNumber: 1, day: 1)],
            durationMode: .deadlineFixed,
            weekStartDate: Date(timeIntervalSinceNow: -14 * 86_400)
        )
        repo.stubbedActive = [record]

        do {
            try await service.reportSession(programId: record.id, sessionId: UUID())
            XCTFail("Devrait throw")
        } catch ReplanifyError.sessionNotFound {
            // OK
        } catch {
            XCTFail("Mauvaise erreur : \(error)")
        }
    }

    // MARK: - shiftWeek (AC15-16)

    func testShiftWeek_recadrageOnPickedDate_preservesProgression() async throws {
        // Setup : user en semaine 3 du programme.
        // weekStart d'origine = il y a 14j (mardi)
        // Date courante = aujourd'hui (donc semaine 3)
        // Pick = lundi prochain → newWeekStart = lundi prochain − 14j
        let cal = DefaultReplanifyService.isoMondayCalendar()
        let now = Date()
        let originalWeekStart = cal.date(byAdding: .day, value: -14, to: weekMonday(of: now))!
        let record = makeRecord(
            sessions: [makeSession(weekNumber: 1, day: 1), makeSession(weekNumber: 3, day: 1)],
            durationMode: .deadlineFixed,
            weekStartDate: originalWeekStart
        )
        repo.stubbedActive = [record]

        let nextMonday = cal.date(byAdding: .day, value: 7, to: weekMonday(of: now))!
        try await service.shiftWeek(programId: record.id, to: nextMonday)

        let updated = try XCTUnwrap(repo.updatedRecords.last)
        XCTAssertEqual(updated.shiftGeneration, 1, "AC16 : shiftGeneration += 1")
        // newWeekStart = nextMonday - (currentWeek-1)*7 = nextMonday - 14j
        let expected = cal.date(byAdding: .day, value: -14, to: nextMonday)!
        XCTAssertEqual(
            updated.weekStartDate?.timeIntervalSinceReferenceDate ?? 0,
            expected.timeIntervalSinceReferenceDate,
            accuracy: 1,
            "Le recadrage doit positionner S3 sur la date pickée"
        )
    }

    func testShiftWeek_pickingSameWeekIsNoOp() async throws {
        let cal = DefaultReplanifyService.isoMondayCalendar()
        let now = Date()
        let monday = weekMonday(of: now)
        let originalWeekStart = cal.date(byAdding: .day, value: -14, to: monday)!  // user en S3
        let record = makeRecord(
            sessions: [makeSession(weekNumber: 1, day: 1)],
            durationMode: .deadlineFixed,
            weekStartDate: originalWeekStart
        )
        repo.stubbedActive = [record]

        // Pick = aujourd'hui (= dans la semaine courante S3) → no-op.
        try await service.shiftWeek(programId: record.id, to: now)

        XCTAssertTrue(repo.updatedRecords.isEmpty, "AC16.4 : no-op si même semaine")
        XCTAssertEqual(record.shiftGeneration, 0)
    }

    func testShiftWeek_throwsForRoutineCyclic() async {
        let record = makeRecord(
            sessions: [makeSession(weekNumber: 1, day: 1)],
            durationMode: .routineCyclic,
            weekStartDate: Date(timeIntervalSinceNow: -7 * 86_400)
        )
        repo.stubbedActive = [record]

        do {
            try await service.shiftWeek(programId: record.id, to: Date().addingTimeInterval(7 * 86_400))
            XCTFail("Devrait throw")
        } catch ReplanifyError.unsupportedForRoutineMode {
            // OK
        } catch {
            XCTFail("Mauvaise erreur : \(error)")
        }
    }

    func testShiftWeek_throwsForDormantProgram() async {
        let record = makeRecord(
            sessions: [makeSession(weekNumber: 1, day: 1)],
            durationMode: .deadlineFixed,
            weekStartDate: nil
        )
        repo.stubbedActive = [record]

        do {
            try await service.shiftWeek(programId: record.id, to: Date().addingTimeInterval(7 * 86_400))
            XCTFail("Devrait throw")
        } catch ReplanifyError.dormantProgram {
            // OK
        } catch {
            XCTFail("Mauvaise erreur : \(error)")
        }
    }

    // MARK: - Helpers

    private func weekMonday(of date: Date) -> Date {
        let cal = DefaultReplanifyService.isoMondayCalendar()
        let comps = cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return cal.date(from: comps) ?? date
    }

    private func makeSession(
        weekNumber: Int,
        day: Int
    ) -> PersistedSession {
        PersistedSession(
            id: UUID(),
            weekNumber: weekNumber,
            weekTheme: "Test",
            weekGoal: "Test",
            day: day,
            name: "S\(weekNumber)D\(day)",
            durationMinutes: 30,
            type: .endurance,
            warmup: nil,
            exercises: [],
            cooldown: nil
        )
    }

    private func makeRecord(
        sessions: [PersistedSession],
        durationMode: ProgramDurationMode,
        weekStartDate: Date?
    ) -> AdaptedProgramRecord {
        AdaptedProgramRecord(
            userId: UUID(),
            sportCode: "running",
            level: "beginner",
            templateId: "test",
            adaptedAt: Date(),
            weekStartDate: weekStartDate,
            mode: .planned,
            sessions: sessions,
            durationMode: durationMode
        )
    }
}
