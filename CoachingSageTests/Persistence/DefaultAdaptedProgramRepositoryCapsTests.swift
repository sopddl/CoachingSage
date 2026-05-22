// CoachingSageTests/Persistence/DefaultAdaptedProgramRepositoryCapsTests.swift
// Story 3.10 AC32 — tests caps dormant/started + markStarted + auto-archive.
// Recréés 2026-05-22 après résolution dette SwiftData test_host hang (logic test).
import XCTest
import SwiftData

@MainActor
final class DefaultAdaptedProgramRepositoryCapsTests: XCTestCase {

    /// **Dette SwiftData test_host hang (2026-05-22)** — le `container` DOIT
    /// être retenu en property, sinon il est déalloué et le mainContext crash.
    private var container: ModelContainer!
    private var modelContext: ModelContext!
    private var repo: DefaultAdaptedProgramRepository!

    override func setUpWithError() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("AdaptedProgramRepoCaps-\(UUID()).sqlite")
        let config = ModelConfiguration(url: url)
        self.container = try ModelContainer(for: AdaptedProgramRecord.self, configurations: config)
        self.modelContext = container.mainContext
        self.repo = DefaultAdaptedProgramRepository(modelContext: modelContext)
    }

    override func tearDown() {
        self.repo = nil
        self.modelContext = nil
        self.container = nil
    }

    // MARK: - fetchStartedCount / fetchDormantCount

    func testFetchStartedCountAndDormantCount() async throws {
        let userId = UUID()
        // 2 dormants + 1 started + 1 archivé pour un autre user (pollution).
        try await repo.save(makeDormant(userId: userId))
        try await repo.save(makeDormant(userId: userId))
        try await repo.save(makeStarted(userId: userId))
        try await repo.save(makeStarted(userId: UUID()))  // autre user

        let dormants = try await repo.fetchDormantCount(for: userId)
        let starteds = try await repo.fetchStartedCount(for: userId)
        XCTAssertEqual(dormants, 2)
        XCTAssertEqual(starteds, 1)
    }

    // MARK: - Cap dormant

    func testSaveThrowsWhenDormantCapReached() async throws {
        let userId = UUID()
        // Saturer le cap dormants à 10.
        for _ in 0..<DefaultAdaptedProgramRepository.dormantCap {
            try await repo.save(makeDormant(userId: userId))
        }
        // Le 11ᵉ doit throw.
        let extra = makeDormant(userId: userId)
        do {
            try await repo.save(extra)
            XCTFail("save() aurait dû throw ProgramCapReached.dormant")
        } catch ProgramCapReached.dormant(let limit) {
            XCTAssertEqual(limit, DefaultAdaptedProgramRepository.dormantCap)
        }
    }

    // MARK: - Cap started

    func testSaveThrowsWhenStartedCapReached() async throws {
        let userId = UUID()
        // Saturer le cap started à 5.
        for _ in 0..<DefaultAdaptedProgramRepository.startedCap {
            try await repo.save(makeStarted(userId: userId))
        }
        let extra = makeStarted(userId: userId)
        do {
            try await repo.save(extra)
            XCTFail("save() aurait dû throw ProgramCapReached.started")
        } catch ProgramCapReached.started(let limit) {
            XCTAssertEqual(limit, DefaultAdaptedProgramRepository.startedCap)
        }
    }

    // MARK: - markStarted

    func testMarkStartedTransitionsDormantToStarted() async throws {
        let userId = UUID()
        let dormant = makeDormant(userId: userId)
        try await repo.save(dormant)
        XCTAssertNil(dormant.weekStartDate)

        try await repo.markStarted(recordId: dormant.id)
        XCTAssertNotNil(dormant.weekStartDate)
    }

    func testMarkStartedIsIdempotentOnAlreadyStarted() async throws {
        let userId = UUID()
        let started = makeStarted(userId: userId)
        try await repo.save(started)
        let originalDate = started.weekStartDate

        try await repo.markStarted(recordId: started.id)
        XCTAssertEqual(started.weekStartDate, originalDate, "Idempotent : la date ne bouge pas")
    }

    func testMarkStartedThrowsWhenStartedCapReached() async throws {
        let userId = UUID()
        // 5 started saturent le cap.
        for _ in 0..<DefaultAdaptedProgramRepository.startedCap {
            try await repo.save(makeStarted(userId: userId))
        }
        // Un dormant en plus.
        let dormant = makeDormant(userId: userId)
        try await repo.save(dormant)

        // markStarted sur le dormant doit throw.
        do {
            try await repo.markStarted(recordId: dormant.id)
            XCTFail("markStarted() aurait dû throw ProgramCapReached.started")
        } catch ProgramCapReached.started(let limit) {
            XCTAssertEqual(limit, DefaultAdaptedProgramRepository.startedCap)
        }
    }

    // MARK: - archive

    func testArchiveFlipsIsActiveAndPosesArchivedAt() async throws {
        let record = makeStarted(userId: UUID())
        try await repo.save(record)
        XCTAssertTrue(record.isActive)

        try await repo.archive(record)
        XCTAssertFalse(record.isActive)
        XCTAssertNotNil(record.archivedAt)
    }

    // MARK: - Helpers

    private func makeDormant(userId: UUID) -> AdaptedProgramRecord {
        let adapted = makeAdaptedFixture()
        return AdaptedProgramRecord(from: adapted, userId: userId)
    }

    private func makeStarted(userId: UUID) -> AdaptedProgramRecord {
        let record = makeDormant(userId: userId)
        record.markStarted()
        return record
    }

    private func makeAdaptedFixture() -> AdaptedProgram {
        AdaptedProgram(
            templateId: "running-beginner-couch-to-5k",
            sport: .running,
            level: .beginner,
            appliedAt: Date(timeIntervalSince1970: 1_700_000_000),
            weeks: [
                AdaptedWeek(
                    weekNumber: 1, theme: "Découverte", goal: "Reprendre",
                    sessions: [
                        AdaptedSession(
                            day: 1, name: "Footing 30 min",
                            durationMinutes: 30, type: .endurance,
                            warmup: nil,
                            exercises: [
                                AdaptedExercise(
                                    name: "Footing 30 min",
                                    originalName: "Footing 30 min",
                                    duration: "30 min",
                                    targetZone: "Daniels-E",
                                    volumeAxis: .duration
                                )
                            ],
                            cooldown: nil
                        )
                    ]
                )
            ],
            appliedRules: [],
            requiresAIAssist: false,
            aiAssistReason: nil,
            durationMode: .routineCyclic,
            targetDate: nil
        )
    }
}
