// CoachingSageTests/Repositories/DefaultCoachingProfileRepositoryTests.swift
// Story 2.2 — guard IS_UI_TESTING + fetch nil quand pas authentifié.
import XCTest
import SwiftData

@MainActor
final class DefaultCoachingProfileRepositoryTests: XCTestCase {

    /// **Dette SwiftData test_host hang (2026-05-22)** — le `container` DOIT
    /// être retenu par l'appelant, sinon il est déalloué et le mainContext
    /// crash au fetch. Helper retourne désormais le tuple (container, context).
    private static func makeContext() throws -> (ModelContainer, ModelContext) {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("CoachingProfile-\(UUID()).sqlite")
        let config = ModelConfiguration(url: url)
        let container = try ModelContainer(for: CoachingProfile.self, configurations: config)
        return (container, container.mainContext)
    }

    func testFetchReturnsNilWhenNoSession() async throws {
        let (container, context) = try Self.makeContext()
        _ = container
        let repo = DefaultCoachingProfileRepository(modelContext: context)

        // Pas de session Supabase → fetchCurrentProfile() retourne nil sans throw.
        let profile = try await repo.fetchCurrentProfile()
        XCTAssertNil(profile)
    }

    func testSaveUnderUITestingPersistsLocallyAndSkipsSupabase() async throws {
        setenv("IS_UI_TESTING", "1", 1)
        defer { unsetenv("IS_UI_TESTING") }

        let (container, context) = try Self.makeContext()
        _ = container
        let repo = DefaultCoachingProfileRepository(modelContext: context)

        let profile = CoachingProfile(id: UUID())
        try await repo.save(profile)

        let fetched = try context.fetch(FetchDescriptor<CoachingProfile>())
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.id, profile.id)
    }
}
