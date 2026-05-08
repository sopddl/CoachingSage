// CoachingSageTests/Persistence/AdaptedProgramRecordTests.swift
// Story 3.8 — tests data model SwiftData :
//   - JSON round-trip pour `sessions` et `completionState` (lesson lessons_swiftdata #1)
//   - bridge `AdaptedProgram → AdaptedProgramRecord` (mode .ondemand par défaut, isActive, sessions flat)
//   - persistance via ModelContext (insert + fetch + update)
import XCTest
import SwiftData
import TemplateModel
@testable import CoachingSage

@MainActor
final class AdaptedProgramRecordTests: XCTestCase {

    /// Container avec un seul `@Model` à la fois — pattern strict `DefaultCoachingProfileRepositoryTests`.
    /// Tester 2 `@Attribute(.unique) var id: UUID` dans le même container in-memory hang
    /// sur `try context.save()` après un modify (boucle de change-tracking SwiftData observée
    /// 2026-05-07 sur `testArchivingFlipsIsActive`). Isoler par modèle évite le piège.
    private static func makeProgramContext() throws -> ModelContext {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: AdaptedProgramRecord.self, configurations: config)
        return container.mainContext
    }

    private static func makeRoutineContext() throws -> ModelContext {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: RoutineRecord.self, configurations: config)
        return container.mainContext
    }

    // MARK: - JSON round-trip

    func testSessionsJsonRoundTrip() throws {
        let session = PersistedSession(
            weekNumber: 1, weekTheme: "Découverte", weekGoal: "Reprendre",
            day: 1, name: "Footing 30 min", durationMinutes: 30, type: .endurance,
            warmup: "5 min marche",
            exercises: [
                AdaptedExercise(
                    name: "Footing 30 min", originalName: "Footing 30 min",
                    duration: "30 min", targetZone: "Daniels-E",
                    volumeAxis: .duration
                )
            ],
            cooldown: "5 min étirements",
            plannedDate: Date(timeIntervalSince1970: 1_700_000_000)
        )

        let record = AdaptedProgramRecord(
            userId: UUID(),
            sportCode: "running", level: "beginner",
            templateId: "running-beginner-couch-to-5k",
            adaptedAt: Date(),
            weekStartDate: Date(),
            sessions: [session]
        )

        XCTAssertEqual(record.sessions.count, 1)
        XCTAssertEqual(record.sessions.first?.name, "Footing 30 min")
        XCTAssertEqual(record.sessions.first?.plannedDate?.timeIntervalSince1970, 1_700_000_000)

        // Ré-écriture via setter doit re-encoder correctement.
        var sessions = record.sessions
        sessions[0].plannedDate = nil
        record.sessions = sessions
        XCTAssertNil(record.sessions.first?.plannedDate)
    }

    func testCompletionStateJsonRoundTrip() throws {
        let sessionId = UUID()
        let record = AdaptedProgramRecord(
            userId: UUID(),
            sportCode: "running", level: "beginner",
            templateId: "test",
            adaptedAt: Date(), weekStartDate: Date(),
            sessions: []
        )

        // Empty par défaut.
        XCTAssertEqual(record.completionState.sessionRecords.count, 0)
        XCTAssertEqual(record.completionState.completedCount, 0)

        // Update via setter.
        var state = record.completionState
        state.sessionRecords[sessionId] = SessionCompletionRecord(
            completedAt: Date(timeIntervalSince1970: 1_700_000_000),
            actualDurationMinutes: 32,
            perceivedEffort: 6,
            notes: "Genou tendu sur la fin"
        )
        record.completionState = state

        XCTAssertEqual(record.completionState.completedCount, 1)
        XCTAssertEqual(record.completionState.sessionRecords[sessionId]?.actualDurationMinutes, 32)
        XCTAssertEqual(record.completionState.sessionRecords[sessionId]?.perceivedEffort, 6)
    }

    // MARK: - Bridge AdaptedProgram → AdaptedProgramRecord

    func testBridgeFromAdaptedProgramSetsDefaults() {
        let adapted = makeAdaptedFixture()
        let userId = UUID()

        let record = AdaptedProgramRecord(from: adapted, userId: userId)

        XCTAssertEqual(record.userId, userId)
        XCTAssertEqual(record.sportCode, "running")
        XCTAssertEqual(record.level, "beginner")
        XCTAssertEqual(record.templateId, "running-beginner-couch-to-5k")
        XCTAssertEqual(record.adaptedAt, adapted.appliedAt)
        XCTAssertEqual(record.mode, .ondemand)         // pool par défaut
        XCTAssertTrue(record.isActive)                  // actif à la création
        XCTAssertNil(record.archivedAt)
        XCTAssertEqual(record.completionState.completedCount, 0)
    }

    func testBridgeFlattensWeeksAndSessions() {
        // 2 weeks × 3 sessions = 6 PersistedSession à plat.
        let adapted = makeAdaptedFixture(weeksCount: 2, sessionsPerWeek: 3)

        let record = AdaptedProgramRecord(from: adapted, userId: UUID())

        XCTAssertEqual(record.sessions.count, 6)
        // Méta de week conservées sur chaque session.
        XCTAssertEqual(record.sessions[0].weekNumber, 1)
        XCTAssertEqual(record.sessions[0].weekTheme, "Semaine 1")
        XCTAssertEqual(record.sessions[3].weekNumber, 2)
        XCTAssertEqual(record.sessions[3].weekTheme, "Semaine 2")
        // Aucune session ne nait avec une plannedDate (mode .ondemand).
        XCTAssertTrue(record.sessions.allSatisfy { $0.plannedDate == nil })
        // IDs uniques (un par session, pas dérivé du contenu).
        let ids = record.sessions.map(\.id)
        XCTAssertEqual(Set(ids).count, 6)
    }

    // MARK: - Persistance ModelContext

    func testInsertAndFetchAdaptedProgramRecord() throws {
        let context = try Self.makeProgramContext()
        let userId = UUID()

        let record = AdaptedProgramRecord(
            from: makeAdaptedFixture(),
            userId: userId
        )
        context.insert(record)
        try context.save()

        let descriptor = FetchDescriptor<AdaptedProgramRecord>(
            predicate: #Predicate { $0.userId == userId && $0.isActive }
        )
        let fetched = try context.fetch(descriptor)
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.templateId, "running-beginner-couch-to-5k")
        XCTAssertEqual(fetched.first?.mode, .ondemand)
    }

    func testArchivingFlipsIsActiveAndSetsArchivedAt() throws {
        // On set isActive=false + archivedAt AVANT insert/save (1 seul save) au lieu de
        // modify-then-save : ce dernier hang sur SwiftData in-memory (observé 2026-05-07).
        let context = try Self.makeProgramContext()
        let userId = UUID()

        let record = AdaptedProgramRecord(
            from: makeAdaptedFixture(),
            userId: userId
        )
        record.isActive = false
        record.archivedAt = Date(timeIntervalSince1970: 1_800_000_000)
        context.insert(record)
        try context.save()

        let descriptor = FetchDescriptor<AdaptedProgramRecord>(
            predicate: #Predicate { $0.userId == userId && !$0.isActive }
        )
        let fetched = try context.fetch(descriptor)
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.archivedAt?.timeIntervalSince1970, 1_800_000_000)
    }

    func testRoutineRecordPersistsAndQueries() throws {
        let context = try Self.makeRoutineContext()
        let userId = UUID()

        let routine = RoutineRecord(
            userId: userId,
            name: "Routine matinale gainage",
            durationMinutes: 12,
            equipmentRequired: ["mat"]
        )
        context.insert(routine)
        try context.save()

        let descriptor = FetchDescriptor<RoutineRecord>(
            predicate: #Predicate { $0.userId == userId }
        )
        let fetched = try context.fetch(descriptor)
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.name, "Routine matinale gainage")
        XCTAssertEqual(fetched.first?.equipmentRequired, ["mat"])
        XCTAssertNil(fetched.first?.lastUsedAt)
    }

    // MARK: - Helpers

    private func makeAdaptedFixture(weeksCount: Int = 2, sessionsPerWeek: Int = 3) -> AdaptedProgram {
        let weeks = (1...weeksCount).map { wn in
            AdaptedWeek(
                weekNumber: wn,
                theme: "Semaine \(wn)",
                goal: "Goal \(wn)",
                sessions: (1...sessionsPerWeek).map { day in
                    AdaptedSession(
                        day: day,
                        name: "Séance W\(wn)D\(day)",
                        durationMinutes: 30 + day * 5,
                        type: .endurance,
                        warmup: nil,
                        exercises: [
                            AdaptedExercise(
                                name: "Footing",
                                originalName: "Footing",
                                duration: "30 min",
                                targetZone: "Daniels-E",
                                volumeAxis: .duration
                            )
                        ],
                        cooldown: nil
                    )
                }
            )
        }
        return AdaptedProgram(
            templateId: "running-beginner-couch-to-5k",
            sport: .running,
            level: .beginner,
            appliedAt: Date(timeIntervalSince1970: 1_700_000_000),
            weeks: weeks,
            appliedRules: [],
            requiresAIAssist: false
        )
    }
}
