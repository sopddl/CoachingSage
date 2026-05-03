// CoachingSageTests/Repositories/DefaultCoachingProfileRepositoryTests.swift
// Story 2.2 — guard IS_UI_TESTING + fetch nil quand pas authentifié.
import XCTest
import SwiftData
@testable import CoachingSage

@MainActor
final class DefaultCoachingProfileRepositoryTests: XCTestCase {

    private static func makeInMemoryContext() throws -> ModelContext {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        // Container minimal : on teste uniquement CoachingProfile, pas besoin du
        // schema versionné complet. Le wrapping `Schema(versionedSchema:)` faisait
        // hang `modelContext.save()` sur le 2e test (machinerie de migration
        // déclenchée même en in-memory neuf).
        let container = try ModelContainer(for: CoachingProfile.self, configurations: config)
        return container.mainContext
    }

    func testFetchReturnsNilWhenNoSession() async throws {
        let context = try Self.makeInMemoryContext()
        let repo = DefaultCoachingProfileRepository(modelContext: context)

        // Pas de session Supabase → fetchCurrentProfile() retourne nil sans throw.
        let profile = try await repo.fetchCurrentProfile()
        XCTAssertNil(profile)
    }

    func testSaveUnderUITestingPersistsLocallyAndSkipsSupabase() async throws {
        setenv("IS_UI_TESTING", "1", 1)
        defer { unsetenv("IS_UI_TESTING") }

        let context = try Self.makeInMemoryContext()
        let repo = DefaultCoachingProfileRepository(modelContext: context)

        let profile = CoachingProfile(id: UUID())
        profile.activeSports = ["running"]
        profile.onboardingCompletedAt = Date()

        try await repo.save(profile)

        let descriptor = FetchDescriptor<CoachingProfile>()
        let stored = try context.fetch(descriptor)
        XCTAssertEqual(stored.count, 1)
        XCTAssertEqual(stored.first?.activeSports, ["running"])
    }
}
