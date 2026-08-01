// CoachingSageTests/Services/AccountDataPurgeServiceTests.swift
// Verrou RGPD (bug remonté par Sophie 2026-07-31) : après suppression de compte,
// le profil coaching local ne doit plus jamais faire croire au gate d'onboarding
// (CoachingSageApp.refreshOnboardingState, filtre CoachingProfile.id == userId)
// que l'onboarding a déjà été fait pour un compte qui n'existe plus.
import XCTest
import SwiftData
import SageCore

@MainActor
final class AccountDataPurgeServiceTests: XCTestCase {

    /// cf. dette SwiftData test_host hang (2026-05-22) — le container doit être retenu par l'appelant.
    private static func makeContext() throws -> (ModelContainer, ModelContext) {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("AccountDataPurge-\(UUID()).sqlite")
        let config = ModelConfiguration(url: url)
        let container = try ModelContainer(
            for: CoachingProfile.self, CoachingSportProfile.self,
                 AdaptedProgramRecord.self, WeeklyExecutionReportRecord.self,
                 SageCoreProfile.self, PendingOperation.self,
            configurations: config
        )
        return (container, container.mainContext)
    }

    private func makeJournalStore() -> JournalFileStore {
        JournalFileStore(fileURL: FileManager.default.temporaryDirectory
            .appendingPathComponent("regen_journal_test_\(UUID()).json"))
    }

    private func makeSessionProgressStore() -> SessionProgressStore {
        SessionProgressStore(fileURL: FileManager.default.temporaryDirectory
            .appendingPathComponent("session_progress_test_\(UUID()).json"))
    }

    private func makeSportProfile(userId: UUID) -> CoachingSportProfile {
        CoachingSportProfile(
            userId: userId,
            sportCode: "running",
            level: "beginner",
            goals: GoalsPayload(primary: "5k"),
            equipment: [],
            constraints: [],
            frequencyPerWeek: 3,
            frequencyLabel: "3",
            conversationHistory: [],
            medicalClearanceAcknowledged: false,
            questionnaireVersion: "running_v1"
        )
    }

    private func makeProgramRecord(userId: UUID) -> AdaptedProgramRecord {
        AdaptedProgramRecord(
            userId: userId,
            sportCode: "running",
            level: "beginner",
            templateId: "running-beginner-12sem",
            adaptedAt: Date(),
            sessions: []
        )
    }

    private func makeReportRecord(userId: UUID) -> WeeklyExecutionReportRecord {
        WeeklyExecutionReportRecord(
            userId: userId,
            recordId: UUID(),
            sportCode: "running",
            snapshot: WeeklyExecutionReportSnapshot(
                weekNumber: 1,
                weekStartDate: Date(),
                plannedSessionCount: 3,
                plannedActiveSessionCount: 3,
                completedSessionCount: 3,
                completionRate: 1.0,
                globalQuality: 1.0,
                overExecutedCount: 0,
                isOverallOverExecuted: false
            )
        )
    }

    // MARK: - Cas nominal : tout ce qui appartient au user supprimé disparaît

    func testPurgeLocalDataDeletesEverythingForTargetUser() async throws {
        let (container, context) = try Self.makeContext()
        _ = container
        let deletedUserId = UUID()

        let coachingProfile = CoachingProfile(id: deletedUserId)
        coachingProfile.onboardingCompletedAt = Date() // reproduit le bug : profil "onboardé"
        context.insert(coachingProfile)
        context.insert(makeSportProfile(userId: deletedUserId))
        let programRecord = makeProgramRecord(userId: deletedUserId)
        context.insert(programRecord)
        context.insert(makeReportRecord(userId: deletedUserId))
        let coreProfile = SageCoreProfile(id: deletedUserId)
        coreProfile.isSoftDeleted = true // état post softDelete() avant purge
        context.insert(coreProfile)
        // Queue offline générique (pas de userId) — doit être vidée entièrement (device mono-compte).
        context.insert(PendingOperation(operationType: "update_core_profile", payload: Data()))
        try context.save()

        let journalStore = makeJournalStore()
        try journalStore.saveAll([
            RegenJournalEntry(
                userId: deletedUserId, recordId: UUID(), analyzedWeekNumber: 1,
                targetWeekNumber: 2, reason: .onTrack, multiplier: 1.0,
                pauseLevel: .none, requiresRebuild: false, affectedSessionIds: []
            )
        ])

        let sessionProgressStore = makeSessionProgressStore()
        sessionProgressStore.setStep(0, done: true, recordId: programRecord.id, week: 1, day: 1)

        let defaults = UserDefaults(suiteName: "AccountDataPurgeServiceTests-\(UUID())")!
        defaults.set(true, forKey: "progress_first_launch_seen")
        defaults.set(true, forKey: "pending_questionnaire_\(deletedUserId.uuidString)_running")

        let mockStoreKit = MockStoreKitService()

        let service = AccountDataPurgeService(
            modelContext: context,
            journalStore: journalStore,
            sessionProgressStore: sessionProgressStore,
            userDefaults: defaults,
            storeKitService: mockStoreKit
        )
        service.purgeLocalData(for: deletedUserId)

        XCTAssertTrue(try context.fetch(FetchDescriptor<CoachingProfile>()).isEmpty,
                       "CoachingProfile doit être purgé — sinon le gate d'onboarding le retrouve encore")
        XCTAssertTrue(try context.fetch(FetchDescriptor<CoachingSportProfile>()).isEmpty)
        XCTAssertTrue(try context.fetch(FetchDescriptor<AdaptedProgramRecord>()).isEmpty)
        XCTAssertTrue(try context.fetch(FetchDescriptor<WeeklyExecutionReportRecord>()).isEmpty)
        XCTAssertTrue(try context.fetch(FetchDescriptor<SageCoreProfile>()).isEmpty)
        XCTAssertTrue(try context.fetch(FetchDescriptor<PendingOperation>()).isEmpty,
                      "La queue offline doit être vidée : sinon SyncService rejoue une opération d'un compte supprimé")
        XCTAssertTrue(try journalStore.loadAll().isEmpty)
        XCTAssertTrue(try sessionProgressStore.loadAll().isEmpty,
                      "session_progress.json doit être purgé pour les séances du programme supprimé")
        XCTAssertNil(defaults.object(forKey: "progress_first_launch_seen"))
        XCTAssertNil(defaults.object(forKey: "pending_questionnaire_\(deletedUserId.uuidString)_running"))
        XCTAssertEqual(mockStoreKit.resetForSignOutCallCount, 1,
                       "resetForSignOut doit être appelé pour éviter une fuite de tier d'abonnement entre comptes")
    }

    // MARK: - Scoping : un autre profil local (autre user) ne doit pas être touché

    func testPurgeLocalDataDoesNotTouchOtherUsersData() async throws {
        let (container, context) = try Self.makeContext()
        _ = container
        let deletedUserId = UUID()
        let otherUserId = UUID()

        context.insert(CoachingProfile(id: deletedUserId))
        let otherProfile = CoachingProfile(id: otherUserId)
        context.insert(otherProfile)
        context.insert(makeSportProfile(userId: deletedUserId))
        context.insert(makeSportProfile(userId: otherUserId))
        try context.save()

        let service = AccountDataPurgeService(
            modelContext: context, journalStore: makeJournalStore(), userDefaults: .standard
        )
        service.purgeLocalData(for: deletedUserId)

        let remainingProfiles = try context.fetch(FetchDescriptor<CoachingProfile>())
        XCTAssertEqual(remainingProfiles.map(\.id), [otherUserId])

        let remainingSportProfiles = try context.fetch(FetchDescriptor<CoachingSportProfile>())
        XCTAssertEqual(remainingSportProfiles.map(\.userId), [otherUserId])
    }
}
