// CoachingSageTests/Coaching/Dashboard/SessionDashboardViewModelSplitTests.swift
// Story 3.15 AC21 — tests split started/dormant des `ProgramSummary`.
//
// Phase 1 conserve l'enum `Mode` hérité de Story 3.10 (`.empty | .active`) et
// expose les 2 listes (`startedSummaries` / `dormantSummaries`) en propriétés
// dérivées. Phase 3 introduira le mode `.dormantOnly` + tests dédiés à
// `selectProgram(id:)` no-op en mode dormant-only.
//
// Ces tests vérifient :
//   - split correct started (`weekStartDate != nil`) vs dormant (`weekStartDate == nil`)
//   - tri intra-liste `lastUpdatedAt desc`
//   - mode `.dormantOnly` virtuel (Phase 1 : assertion sur les propriétés, pas l'enum)
//   - selectedId ne référence que des `startedSummaries` quand il y a des started
import XCTest
import TemplateModel

@MainActor
final class SessionDashboardViewModelSplitTests: XCTestCase {

    private let userId = UUID()
    private let now = Date(timeIntervalSince1970: 1_700_000_000)

    // MARK: - AC21 — Split started / dormant

    /// **AC21** — 2 lancés + 3 dormants → split correct, tri lastUpdatedAt desc dans chaque sous-liste.
    func testSplit_StartedAndDormant_Correct() async {
        let started1 = makeRecord(sportCode: "running", weekStartDate: now,
                                  lastUpdatedAt: Date(timeIntervalSince1970: 9_000))
        let started2 = makeRecord(sportCode: "cycling", weekStartDate: now,
                                  lastUpdatedAt: Date(timeIntervalSince1970: 8_000))
        let dormant1 = makeRecord(sportCode: "swimming", weekStartDate: nil,
                                  lastUpdatedAt: Date(timeIntervalSince1970: 3_000))
        let dormant2 = makeRecord(sportCode: "yoga", weekStartDate: nil,
                                  lastUpdatedAt: Date(timeIntervalSince1970: 2_000))
        let dormant3 = makeRecord(sportCode: "tennis", weekStartDate: nil,
                                  lastUpdatedAt: Date(timeIntervalSince1970: 1_000))

        let vm = makeVM(programs: [dormant2, started2, dormant1, dormant3, started1])
        await vm.refresh(userId: userId)

        XCTAssertEqual(vm.startedSummaries.count, 2)
        XCTAssertEqual(vm.dormantSummaries.count, 3)

        // Tri started : lastUpdatedAt desc → started1 (9000) avant started2 (8000)
        XCTAssertEqual(vm.startedSummaries.map(\.sport.appSportCode), ["running", "cycling"])
        // Tri dormant : lastUpdatedAt desc → dormant1 (3000), dormant2 (2000), dormant3 (1000)
        XCTAssertEqual(vm.dormantSummaries.map(\.sport.appSportCode), ["swimming", "yoga", "tennis"])
    }

    /// **AC21** — 0 lancés + 3 dormants → mode `.active` (Phase 1 hérité),
    /// `startedSummaries` vide, `dormantSummaries.count == 3`. Phase 3
    /// remplacera par mode `.dormantOnly`.
    func testMode_DormantOnly_StartedEmpty_DormantsListed() async {
        let dormant1 = makeRecord(sportCode: "running", weekStartDate: nil,
                                  lastUpdatedAt: Date(timeIntervalSince1970: 3_000))
        let dormant2 = makeRecord(sportCode: "cycling", weekStartDate: nil,
                                  lastUpdatedAt: Date(timeIntervalSince1970: 2_000))
        let dormant3 = makeRecord(sportCode: "yoga", weekStartDate: nil,
                                  lastUpdatedAt: Date(timeIntervalSince1970: 1_000))

        let vm = makeVM(programs: [dormant3, dormant1, dormant2])
        await vm.refresh(userId: userId)

        XCTAssertTrue(vm.startedSummaries.isEmpty)
        XCTAssertEqual(vm.dormantSummaries.count, 3)
        XCTAssertEqual(vm.dormantSummaries.map(\.sport.appSportCode), ["running", "cycling", "yoga"])
    }

    /// **AC21** — 0 lancés + 0 dormants → mode `.empty`, 2 listes vides.
    func testMode_Empty_WhenNothing() async {
        let vm = makeVM(programs: [])
        await vm.refresh(userId: userId)

        XCTAssertEqual(vm.mode, .empty)
        XCTAssertTrue(vm.startedSummaries.isEmpty)
        XCTAssertTrue(vm.dormantSummaries.isEmpty)
        XCTAssertTrue(vm.activeProgramSummaries.isEmpty)
    }

    /// **AC21** — quand il y a des started, `currentSelectedId` ne référence
    /// QUE des `startedSummaries` (un dormant n'est jamais sélectionné via
    /// la sélection par défaut).
    func testSelectedId_OnlyReferencesStarted_WhenStartedExist() async {
        let started = makeRecord(sportCode: "running", weekStartDate: now,
                                 lastUpdatedAt: Date(timeIntervalSince1970: 5_000))
        let dormant = makeRecord(sportCode: "cycling", weekStartDate: nil,
                                 lastUpdatedAt: Date(timeIntervalSince1970: 9_000)) // plus récent

        let vm = makeVM(programs: [dormant, started])
        await vm.refresh(userId: userId)

        XCTAssertEqual(vm.currentSelectedId, started.id,
                       "Sélection par défaut doit pointer sur le started même si un dormant est plus récent")
        XCTAssertFalse(vm.dormantSummaries.contains { $0.id == vm.currentSelectedId })
    }

    /// **AC21** — `activeProgramSummaries` = started + dormant concaténés
    /// (started en tête). Rétrocompat des call-sites existants.
    func testActiveProgramSummaries_ConcatenatesStartedThenDormant() async {
        let started = makeRecord(sportCode: "running", weekStartDate: now,
                                 lastUpdatedAt: Date(timeIntervalSince1970: 5_000))
        let dormant = makeRecord(sportCode: "cycling", weekStartDate: nil,
                                 lastUpdatedAt: Date(timeIntervalSince1970: 6_000))

        let vm = makeVM(programs: [dormant, started])
        await vm.refresh(userId: userId)

        XCTAssertEqual(vm.activeProgramSummaries.map(\.sport.appSportCode),
                       ["running", "cycling"],
                       "started d'abord, dormant ensuite (rétrocompat)")
    }

    // MARK: - Helpers

    private func makeVM(programs: [AdaptedProgramRecord]) -> SessionDashboardViewModel {
        let programRepo = MockAdaptedProgramRepository()
        programRepo.stubbedActive = programs
        return SessionDashboardViewModel(
            programRepository: programRepo,
            coachingProfileRepository: MockCoachingProfileRepository(),
            templateLibraryProvider: { ProgramTemplateLibrary(templates: [Self.placeholderTemplate]) },
            nowProvider: { self.now }
        )
    }

    private static let placeholderTemplate: ProgramTemplate = ProgramTemplate(
        id: "placeholder", schemaVersion: 1, sport: .running, level: .beginner,
        name: "ph", durationWeeks: 4, sessionsPerWeek: 1,
        defaultObjective: "n/a", assumedProfile: "n/a", summary: "n/a",
        weeks: [], safetyNotes: "n/a", progressionLogic: "n/a"
    )

    private func makeRecord(
        sportCode: String,
        weekStartDate: Date?,
        lastUpdatedAt: Date
    ) -> AdaptedProgramRecord {
        let session = PersistedSession(
            id: UUID(),
            weekNumber: 1,
            weekTheme: "W1",
            weekGoal: "G1",
            day: 1,
            name: "S1",
            durationMinutes: 30,
            type: .endurance,
            warmup: nil,
            exercises: [],
            cooldown: nil
        )
        return AdaptedProgramRecord(
            userId: userId,
            sportCode: sportCode,
            level: "beginner",
            templateId: "test-\(sportCode)",
            adaptedAt: Date(timeIntervalSince1970: 1_699_000_000),
            weekStartDate: weekStartDate,
            mode: .ondemand,
            sessions: [session],
            lastUpdatedAt: lastUpdatedAt
        )
    }
}
