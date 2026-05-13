// CoachingSageTests/Regen/RegenInputsBuilderTests.swift
// Story 3.4 Phase B.3 — tests `RegenInputsBuilder` (impl `WeeklyRegenInputsProviding`).
//
// Focus orchestration (wiring inputs → engine, fallbacks hrMax, edge cases).
// La logique de l'engine elle-même est couverte par les tests Phase A.4.
// Mocks partagés : `MockHealthKitService` + `MockCoachingProfileRepository`
// (cf `CoachingSageTests/Mocks/`). `LocalRegenRepoStub` local au fichier.
import XCTest
import TemplateModel
@testable import CoachingSage

@MainActor
final class RegenInputsBuilderTests: XCTestCase {

    // MARK: - weekStartDate (math pure)

    func testWeekStartDate_week1ReturnsProgramStart() {
        let builder = makeBuilder()
        let programStart = makeMonday()
        XCTAssertEqual(
            builder.weekStartDate(of: 1, programStart: programStart),
            programStart
        )
    }

    func testWeekStartDate_week3IsTwoWeeksAfterStart() {
        let builder = makeBuilder()
        let programStart = makeMonday()
        let expected = programStart.addingTimeInterval(14 * 24 * 3600)
        XCTAssertEqual(
            builder.weekStartDate(of: 3, programStart: programStart),
            expected
        )
    }

    // MARK: - makeDecision : gardes

    func testMakeDecision_returnsNilForInvalidWeekNumber() async throws {
        let builder = makeBuilder()
        let record = makeRecord(sessions: [makeSession(weekNumber: 1, day: 1)])
        let decision = try await builder.makeDecision(for: record, analyzedWeekNumber: 0, now: Date())
        XCTAssertNil(decision)
    }

    func testMakeDecision_returnsNilForEmptySessionsInTargetWeek() async throws {
        let builder = makeBuilder()
        let record = makeRecord(sessions: [makeSession(weekNumber: 1, day: 1)])
        // analyzedWeek=5 → aucune session dans le record → nil.
        let decision = try await builder.makeDecision(for: record, analyzedWeekNumber: 5, now: Date())
        XCTAssertNil(decision)
    }

    // MARK: - makeDecision : wiring engine

    func testMakeDecision_returnsDecisionForValidWeek() async throws {
        let (builder, _, _, _) = makeSystem()
        let record = makeRecord(sessions: [
            makeSession(weekNumber: 1, day: 1, durationMinutes: 30),
            makeSession(weekNumber: 1, day: 3, durationMinutes: 40),
            makeSession(weekNumber: 1, day: 5, durationMinutes: 20)
        ])

        let decision = try await builder.makeDecision(for: record, analyzedWeekNumber: 1, now: Date())

        let unwrapped = try XCTUnwrap(decision)
        XCTAssertEqual(unwrapped.analyzedWeekNumber, 1)
        XCTAssertEqual(unwrapped.targetWeekNumber, 2)
        // Pas de workouts HK + pas de previousReports → tout missed → reduce 25%.
        XCTAssertEqual(unwrapped.reason, RegressionDecision.Reason.missedSessions)
    }

    func testMakeDecision_passesPreviousReportsToEngine() async throws {
        let (builder, _, regenRepo, _) = makeSystem()
        // 3 semaines sub-seuil consécutives en S-1, S-2, S-3 → moderate (S+1 reduce 25%)
        // Mais PauseDetector regarde le PASSÉ. Avec 2 sem sub-seuil + S courante sub-seuil
        // détecté missed, c'est missedSessions qui prime sinon moderate pause.
        regenRepo.stubbedReports = [
            makeSnapshot(weekNumber: 1, completionRate: 0.1, plannedActive: 3),
            makeSnapshot(weekNumber: 2, completionRate: 0.1, plannedActive: 3),
            makeSnapshot(weekNumber: 3, completionRate: 0.1, plannedActive: 3)
        ]
        let record = makeRecord(sessions: [
            makeSession(weekNumber: 4, day: 1, durationMinutes: 30)
        ])

        let decision = try await builder.makeDecision(for: record, analyzedWeekNumber: 4, now: Date())

        let unwrapped = try XCTUnwrap(decision)
        // PauseDetector voit 3 sem consécutives sub-seuil → extended → restart.
        XCTAssertEqual(unwrapped.reason, RegressionDecision.Reason.pauseExtended)
        XCTAssertTrue(unwrapped.adjustment.requiresRebuild)
    }

    func testMakeDecision_propagatesDaysSinceLastWorkout() async throws {
        let (builder, hkMock, _, _) = makeSystem()
        // Dernier workout il y a 20 jours → extended pause → restart.
        hkMock.stubbedRecentWorkoutDetails = [
            makeWorkoutDetail(daysAgo: 20)
        ]
        let record = makeRecord(sessions: [
            makeSession(weekNumber: 1, day: 1, durationMinutes: 30)
        ])

        let decision = try await builder.makeDecision(for: record, analyzedWeekNumber: 1, now: Date())

        let unwrapped = try XCTUnwrap(decision)
        XCTAssertEqual(unwrapped.pauseLevel, PauseLevel.extended)
        XCTAssertEqual(unwrapped.reason, RegressionDecision.Reason.pauseExtended)
    }

    // MARK: - HRMax résolution

    func testMakeDecision_succeedsWithDefaultHRMaxWhenNoProfile() async throws {
        let (builder, _, _, profileRepo) = makeSystem()
        profileRepo.stubbedProfile = nil
        let record = makeRecord(sessions: [makeSession(weekNumber: 1, day: 1)])

        let decision = try await builder.makeDecision(for: record, analyzedWeekNumber: 1, now: Date())

        XCTAssertNotNil(decision, "Décision attendue avec hrMax default (180), même sans profile.")
    }

    func testMakeDecision_succeedsWithAgeBasedHRMax() async throws {
        let (builder, _, _, profileRepo) = makeSystem()
        let profile = CoachingProfile(id: UUID())
        // 40 ans = 1985-01-01
        var dob = DateComponents()
        dob.year = 1985
        dob.month = 1
        dob.day = 1
        profile.dateOfBirth = Calendar.current.date(from: dob)
        profileRepo.stubbedProfile = profile
        let record = makeRecord(sessions: [makeSession(weekNumber: 1, day: 1)])

        let decision = try await builder.makeDecision(for: record, analyzedWeekNumber: 1, now: Date())

        XCTAssertNotNil(decision, "Décision attendue avec hrMax = 220 - 40 = 180.")
    }

    // MARK: - Helpers / fixtures

    private func makeBuilder() -> RegenInputsBuilder {
        makeSystem().0
    }

    private func makeSystem() -> (RegenInputsBuilder, MockHealthKitService, LocalRegenRepoStub, MockCoachingProfileRepository) {
        let hk = MockHealthKitService()
        let repo = LocalRegenRepoStub()
        let profileRepo = MockCoachingProfileRepository()
        let builder = RegenInputsBuilder(
            healthKit: hk,
            regenRepository: repo,
            coachingProfileRepository: profileRepo
        )
        return (builder, hk, repo, profileRepo)
    }

    private func makeMonday() -> Date {
        var c = DateComponents()
        c.year = 2024
        c.month = 7
        c.day = 8
        c.hour = 0
        return Calendar.current.date(from: c)!
    }

    private func makeSession(
        weekNumber: Int,
        day: Int,
        durationMinutes: Int = 30,
        type: SessionType = .endurance
    ) -> PersistedSession {
        PersistedSession(
            weekNumber: weekNumber,
            weekTheme: "test",
            weekGoal: "test",
            day: day,
            name: "Test session",
            durationMinutes: durationMinutes,
            type: type,
            warmup: nil,
            exercises: [],
            cooldown: nil
        )
    }

    private func makeRecord(
        userId: UUID = UUID(),
        sessions: [PersistedSession]
    ) -> AdaptedProgramRecord {
        AdaptedProgramRecord(
            userId: userId,
            sportCode: "running",
            level: Level.regular.rawValue,
            templateId: "test_template",
            adaptedAt: Date(),
            weekStartDate: makeMonday(),
            mode: .ondemand,
            sessions: sessions
        )
    }

    private func makeSnapshot(
        weekNumber: Int,
        completionRate: Double,
        plannedActive: Int
    ) -> WeeklyExecutionReportSnapshot {
        WeeklyExecutionReportSnapshot(
            weekNumber: weekNumber,
            weekStartDate: makeMonday(),
            plannedSessionCount: plannedActive,
            plannedActiveSessionCount: plannedActive,
            completedSessionCount: Int(Double(plannedActive) * completionRate),
            completionRate: completionRate,
            globalQuality: 50,
            overExecutedCount: 0,
            isOverallOverExecuted: false
        )
    }

    private func makeWorkoutDetail(daysAgo: Int) -> HealthKitWorkoutDetail {
        HealthKitWorkoutDetail(
            activityTypeRawValue: 37, // running
            durationMinutes: 30,
            averageHeartRateBpm: 140,
            maxHeartRateBpm: 170,
            daysAgo: daysAgo,
            fromAppleWatch: true
        )
    }
}

// MARK: - Mocks

// `MockHealthKitService` (partagé : `CoachingSageTests/Mocks/MockHealthKitService.swift`).
// `MockCoachingProfileRepository` (partagé : `CoachingSageTests/Mocks/MockCoachingProfileRepository.swift`).
// `LocalRegenRepoStub` local au fichier (pas encore partagé — à factoriser si re-utilisé).

@MainActor
private final class LocalRegenRepoStub: WeeklyRegenRepository {
    var stubbedReports: [WeeklyExecutionReportSnapshot] = []
    var savedJournalEntries: [RegenJournalEntry] = []

    func fetchReports(recordId: UUID, before weekNumber: Int, limit: Int) async throws -> [WeeklyExecutionReportSnapshot] {
        stubbedReports
            .filter { $0.weekNumber < weekNumber }
            .sorted { $0.weekNumber > $1.weekNumber }
            .prefix(limit)
            .map { $0 }
    }
    func saveReport(_ snapshot: WeeklyExecutionReportSnapshot, recordId: UUID, userId: UUID, sportCode: String) async throws {}
    func fetchJournal(recordId: UUID, targetWeek: Int) async throws -> RegenJournalEntry? { nil }
    func saveJournal(_ entry: RegenJournalEntry) async throws { savedJournalEntries.append(entry) }
    func fetchJournalForCurrentWeek(userId: UUID, weekStart: Date) async throws -> [RegenJournalEntry] { [] }
}

