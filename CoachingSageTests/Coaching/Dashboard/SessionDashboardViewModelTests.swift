// CoachingSageTests/Coaching/Dashboard/SessionDashboardViewModelTests.swift
// Story 3.8 — tests bascule modes (cf spec AC « test bascule mode-vide ↔ mode-actif ») :
//   - 0 programme → .empty
//   - 1 programme → .singleProgram avec next résolu
//   - 2+ programmes → .multiProgram avec dominante
//   - bascule .empty → .singleProgram quand un record arrive entre 2 refresh
//   - erreur repo → mode .empty + error renseigné, loading false
import XCTest
import TemplateModel
@testable import CoachingSage

@MainActor
final class SessionDashboardViewModelTests: XCTestCase {

    private let userId = UUID()
    private let now = Date(timeIntervalSince1970: 1_700_000_000)

    // MARK: - Bascule modes

    func testRefreshSetsEmptyModeWhenNoActiveProgram() async {
        let vm = makeVM(programs: [], routines: [])

        await vm.refresh(userId: userId)

        XCTAssertEqual(vm.mode, .empty)
        XCTAssertTrue(vm.routines.isEmpty)
        XCTAssertFalse(vm.loading)
        XCTAssertNil(vm.error)
    }

    func testRefreshSetsSingleProgramModeWith1Active() async {
        let prog = makeRecord(sportCode: "running", sessionsCount: 3)
        let vm = makeVM(programs: [prog], routines: [])

        await vm.refresh(userId: userId)

        guard case let .singleProgram(record, next) = vm.mode else {
            return XCTFail("Expected .singleProgram, got \(vm.mode)")
        }
        XCTAssertEqual(record.id, prog.id)
        XCTAssertNotNil(next)
        XCTAssertEqual(next?.session.day, 1) // 1re séance ondemand
    }

    func testRefreshSetsMultiProgramModeWith2Plus() async {
        let progA = makeRecord(sportCode: "running", sessionsCount: 2)
        let progB = makeRecord(sportCode: "cycling", sessionsCount: 2)
        let vm = makeVM(programs: [progA, progB], routines: [])

        await vm.refresh(userId: userId)

        guard case let .multiProgram(programs, dominant) = vm.mode else {
            return XCTFail("Expected .multiProgram, got \(vm.mode)")
        }
        XCTAssertEqual(programs.count, 2)
        // Tous deux .ondemand donc tie-break alpha → cycling
        XCTAssertEqual(dominant?.program.sportCode, "cycling")
    }

    func testRefreshTransitionsFromEmptyToActiveWhenProgramAdded() async {
        let repo = MockAdaptedProgramRepository()
        let vm = makeVM(programRepo: repo, routines: [])

        await vm.refresh(userId: userId)
        XCTAssertEqual(vm.mode, .empty)

        // Un programme arrive (entre 2 refresh, ex. wire-up persist on adapt).
        let prog = makeRecord(sportCode: "running", sessionsCount: 1)
        repo.stubbedActive = [prog]
        await vm.refresh(userId: userId)

        guard case .singleProgram = vm.mode else {
            return XCTFail("Expected bascule vers .singleProgram, got \(vm.mode)")
        }
    }

    // MARK: - Routines

    func testRefreshLoadsRoutines() async {
        let routine = RoutineRecord(
            userId: userId,
            name: "Routine matinale",
            durationMinutes: 12
        )
        let vm = makeVM(programs: [], routines: [routine])

        await vm.refresh(userId: userId)

        XCTAssertEqual(vm.routines.count, 1)
        XCTAssertEqual(vm.routines.first?.name, "Routine matinale")
    }

    // MARK: - Erreurs

    func testRefreshFallsBackToEmptyOnRepoError() async {
        let repo = MockAdaptedProgramRepository()
        repo.fetchShouldThrow = true
        let vm = makeVM(programRepo: repo, routines: [])

        await vm.refresh(userId: userId)

        XCTAssertEqual(vm.mode, .empty)
        XCTAssertNotNil(vm.error)
        XCTAssertFalse(vm.loading)
    }

    // MARK: - Mode vide — suggestions selectTopN

    func testRefreshLoadsThreeSuggestionsInEmptyMode() async {
        let library = ProgramTemplateLibrary(templates: [
            makeTemplate(id: "running-beginner-x", sport: .running, level: .beginner),
            makeTemplate(id: "cycling-beginner-x", sport: .cycling, level: .beginner),
            makeTemplate(id: "swimming-beginner-x", sport: .swimming, level: .beginner),
            makeTemplate(id: "yoga-regular-x", sport: .yoga, level: .regular)
        ])
        let profile = CoachingProfile(id: userId)
        profile.activeSports = ["running", "cycling", "swimming"]
        let profileRepo = MockCoachingProfileRepository()
        profileRepo.stubbedProfile = profile

        let vm = makeVM(profileRepo: profileRepo, library: library)
        await vm.refresh(userId: userId)

        XCTAssertEqual(vm.mode, .empty)
        XCTAssertEqual(vm.emptyModeSuggestions.count, 3)
        XCTAssertEqual(Set(vm.emptyModeSuggestions.map(\.sport)), [.running, .cycling, .swimming])
        XCTAssertEqual(vm.declaredSportCodes, ["running", "cycling", "swimming"])
    }

    func testRefreshClearsSuggestionsWhenLeavingEmptyMode() async {
        let library = ProgramTemplateLibrary(templates: [
            makeTemplate(id: "running-beginner-x", sport: .running, level: .beginner)
        ])
        let profileRepo = MockCoachingProfileRepository()
        profileRepo.stubbedProfile = CoachingProfile(id: userId)
        let progRepo = MockAdaptedProgramRepository()
        let vm = makeVM(programRepo: progRepo, profileRepo: profileRepo, library: library)

        await vm.refresh(userId: userId)
        XCTAssertEqual(vm.mode, .empty)
        XCTAssertFalse(vm.emptyModeSuggestions.isEmpty)

        progRepo.stubbedActive = [makeRecord(sportCode: "running", sessionsCount: 1)]
        await vm.refresh(userId: userId)
        XCTAssertTrue(vm.emptyModeSuggestions.isEmpty)
    }

    func testRefreshLeavesSuggestionsEmptyWhenLibraryThrows() async {
        let profileRepo = MockCoachingProfileRepository()
        profileRepo.stubbedProfile = CoachingProfile(id: userId)
        let vm = SessionDashboardViewModel(
            programRepository: { let r = MockAdaptedProgramRepository(); return r }(),
            routineRepository: MockRoutineRepository(),
            coachingProfileRepository: profileRepo,
            templateLibraryProvider: { throw URLError(.cannotLoadFromNetwork) },
            nowProvider: { self.now }
        )

        await vm.refresh(userId: userId)
        XCTAssertEqual(vm.mode, .empty)
        XCTAssertTrue(vm.emptyModeSuggestions.isEmpty)
    }

    // MARK: - Helpers

    private func makeVM(
        programs: [AdaptedProgramRecord] = [],
        routines: [RoutineRecord] = []
    ) -> SessionDashboardViewModel {
        let programRepo = MockAdaptedProgramRepository()
        programRepo.stubbedActive = programs
        return makeVM(programRepo: programRepo, routines: routines)
    }

    private func makeVM(
        programRepo: MockAdaptedProgramRepository,
        routines: [RoutineRecord]
    ) -> SessionDashboardViewModel {
        let routineRepo = MockRoutineRepository()
        routineRepo.stubbedRoutines = routines
        return SessionDashboardViewModel(
            programRepository: programRepo,
            routineRepository: routineRepo,
            coachingProfileRepository: MockCoachingProfileRepository(),
            templateLibraryProvider: { ProgramTemplateLibrary(templates: [
                Self.placeholderTemplate
            ]) },
            nowProvider: { self.now }
        )
    }

    private func makeVM(
        programRepo: MockAdaptedProgramRepository = MockAdaptedProgramRepository(),
        profileRepo: MockCoachingProfileRepository,
        library: ProgramTemplateLibrary
    ) -> SessionDashboardViewModel {
        let routineRepo = MockRoutineRepository()
        return SessionDashboardViewModel(
            programRepository: programRepo,
            routineRepository: routineRepo,
            coachingProfileRepository: profileRepo,
            templateLibraryProvider: { library },
            nowProvider: { self.now }
        )
    }

    private static let placeholderTemplate: ProgramTemplate = ProgramTemplate(
        id: "placeholder", schemaVersion: 1, sport: .running, level: .beginner,
        name: "ph", durationWeeks: 4, sessionsPerWeek: 1,
        defaultObjective: "n/a", assumedProfile: "n/a", summary: "n/a",
        weeks: [], safetyNotes: "n/a", progressionLogic: "n/a"
    )

    private func makeTemplate(id: String, sport: Sport, level: Level) -> ProgramTemplate {
        ProgramTemplate(
            id: id, schemaVersion: 1, sport: sport, level: level,
            name: id, durationWeeks: 8, sessionsPerWeek: 3,
            defaultObjective: "test", assumedProfile: "test", summary: "test",
            weeks: [], safetyNotes: "n/a", progressionLogic: "n/a"
        )
    }

    private func makeRecord(
        sportCode: String,
        sessionsCount: Int
    ) -> AdaptedProgramRecord {
        let sessions = (1...sessionsCount).map { day in
            PersistedSession(
                id: UUID(),
                weekNumber: 1,
                weekTheme: "W1",
                weekGoal: "G1",
                day: day,
                name: "S\(day)",
                durationMinutes: 30,
                type: .endurance,
                warmup: nil,
                exercises: [],
                cooldown: nil
            )
        }
        return AdaptedProgramRecord(
            userId: userId,
            sportCode: sportCode,
            level: "beginner",
            templateId: "test-\(sportCode)",
            adaptedAt: Date(timeIntervalSince1970: 1_699_000_000),
            weekStartDate: Date(),
            mode: .ondemand,
            sessions: sessions
        )
    }
}
