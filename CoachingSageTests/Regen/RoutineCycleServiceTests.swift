// CoachingSageTests/Regen/RoutineCycleServiceTests.swift
// Story 3.31 — tests du cycle de vie de fin de routine :
//   - renewalState : notApplicable / notDue / due (J−14) / cycleCompleted
//   - renew : reset complétion + semaine 1 + cycleNumber++ + shiftGeneration++
//     + scaling des durées, idempotence pratique (l'état retombe en notDue).
import XCTest
import TemplateModel

@MainActor
final class RoutineCycleServiceTests: XCTestCase {

    private var repo: MockAdaptedProgramRepository!
    private var service: DefaultRoutineCycleService!

    /// `now` stable : mercredi 2024-07-17 12:00.
    private let now = Date(timeIntervalSince1970: 1_721_217_600)

    override func setUp() {
        super.setUp()
        repo = MockAdaptedProgramRepository()
        service = DefaultRoutineCycleService(adaptedProgramRepository: repo)
    }

    override func tearDown() {
        service = nil
        repo = nil
        super.tearDown()
    }

    // MARK: - Helpers

    /// Construit un record `totalWeeks` semaines × 1 session active de 30 min.
    /// `weeksElapsed` : nombre de semaines écoulées depuis `weekStartDate`
    /// (`nil` = dormant). `completedAll` : marque toutes les sessions actives faites.
    private func makeRoutine(
        totalWeeks: Int = 12,
        weeksElapsed: Int? = 0,
        durationMode: ProgramDurationMode = .routineCyclic,
        completedAll: Bool = false,
        isActive: Bool = true
    ) -> AdaptedProgramRecord {
        var sessions: [PersistedSession] = []
        for w in 1...totalWeeks {
            sessions.append(PersistedSession(
                weekNumber: w, weekTheme: "t", weekGoal: "g",
                day: 1, name: "S\(w)", durationMinutes: 30,
                type: .endurance, warmup: nil, exercises: [], cooldown: nil
            ))
        }
        let weekStart: Date? = weeksElapsed.map {
            Calendar.current.date(byAdding: .day, value: -($0 * 7), to: now)!
        }
        var completion = ProgramCompletionState.empty
        if completedAll {
            for s in sessions {
                completion.sessionRecords[s.id] = SessionCompletionRecord(completedAt: now, perceivedEffort: 5)
            }
        }
        let record = AdaptedProgramRecord(
            userId: UUID(),
            sportCode: "running",
            level: "beginner",
            templateId: "tpl",
            adaptedAt: now,
            weekStartDate: weekStart,
            mode: weekStart == nil ? .ondemand : .planned,
            sessions: sessions,
            completionState: completion,
            isActive: isActive,
            durationMode: durationMode,
            targetDate: durationMode == .routineCyclic ? nil : now
        )
        repo.stubbedActive.append(record)
        return record
    }

    // MARK: - renewalState

    func testDeadlineMode_notApplicable() {
        let r = makeRoutine(weeksElapsed: 11, durationMode: .deadlineFixed)
        XCTAssertEqual(service.renewalState(for: r, now: now), .notApplicable)
    }

    func testArchivedRoutine_notApplicable() {
        let r = makeRoutine(weeksElapsed: 11, isActive: false)
        XCTAssertEqual(service.renewalState(for: r, now: now), .notApplicable)
    }

    func testDormantRoutine_notDue() {
        let r = makeRoutine(weeksElapsed: nil)
        XCTAssertEqual(service.renewalState(for: r, now: now), .notDue)
    }

    func testMidCycle_notDue() {
        let r = makeRoutine(weeksElapsed: 4) // semaine 5/12
        XCTAssertEqual(service.renewalState(for: r, now: now), .notDue)
    }

    func testWeek11of12_due() {
        let r = makeRoutine(weeksElapsed: 10) // semaine 11/12 = J−14
        XCTAssertEqual(service.renewalState(for: r, now: now), .due(cycleNumber: 1))
    }

    func testPastLastWeek_cycleCompleted() {
        let r = makeRoutine(weeksElapsed: 12) // semaine 13 > 12
        XCTAssertEqual(service.renewalState(for: r, now: now), .cycleCompleted(cycleNumber: 1))
    }

    func testAllSessionsDoneEarly_cycleCompleted() {
        let r = makeRoutine(weeksElapsed: 3, completedAll: true) // semaine 4 mais tout fait
        XCTAssertEqual(service.renewalState(for: r, now: now), .cycleCompleted(cycleNumber: 1))
    }

    // MARK: - renew

    func testRenew_resetsAndIncrements() async throws {
        let r = makeRoutine(weeksElapsed: 11, completedAll: true)
        let before = r.cycleNumber
        let beforeShift = r.shiftGeneration

        let decision = try await service.renew(recordId: r.id, now: now)

        XCTAssertEqual(r.cycleNumber, before + 1)
        XCTAssertEqual(r.shiftGeneration, beforeShift + 1)
        XCTAssertEqual(r.completionState.completedCount, 0, "complétion remise à zéro")
        XCTAssertNotNil(r.weekStartDate)
        // Semaine 1 = maintenant → renewalState retombe en notDue (idempotence pratique).
        XCTAssertEqual(service.renewalState(for: r, now: now), .notDue)
        XCTAssertTrue(repo.updatedRecords.contains { $0.id == r.id })
        // completedAll + RPE 5 → progression (les sessions ont été corsées).
        XCTAssertEqual(decision.reason, .progress)
        XCTAssertEqual(r.sessions.first?.durationMinutes, 33, "30 × 1.10 = 33")
    }

    func testRenew_recoverScalesDown() async throws {
        // Cycle peu suivi (rien fait) → allègement.
        let r = makeRoutine(weeksElapsed: 12, completedAll: false)
        let decision = try await service.renew(recordId: r.id, now: now)
        XCTAssertEqual(decision.reason, .recover)
        XCTAssertEqual(r.sessions.first?.durationMinutes, 27, "30 × 0.90 = 27")
    }

    func testRenew_deadlineThrows() async {
        let r = makeRoutine(weeksElapsed: 11, durationMode: .deadlineFixed)
        do {
            _ = try await service.renew(recordId: r.id, now: now)
            XCTFail("renew aurait dû throw notARoutine")
        } catch RoutineCycleError.notARoutine {
            // OK
        } catch {
            XCTFail("erreur inattendue: \(error)")
        }
    }

    func testRenew_unknownRecordThrows() async {
        do {
            _ = try await service.renew(recordId: UUID(), now: now)
            XCTFail("renew aurait dû throw recordNotFound")
        } catch RoutineCycleError.recordNotFound {
            // OK
        } catch {
            XCTFail("erreur inattendue: \(error)")
        }
    }
}
