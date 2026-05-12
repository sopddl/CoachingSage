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

        let vm = makeVM(programRepo: MockAdaptedProgramRepository(), profileRepo: profileRepo, library: library)
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

    // MARK: - Mode actif — tri programmes par date prochaine séance

    func testRefreshSortsActiveProgramsByNextDateAscending() async {
        // 3 progs planned avec sessions datées : J+1, J+0, J+5.
        // Tri attendu : J+0, J+1, J+5 (la plus proche en haut, décision party #3).
        let cal = Calendar.current
        let day0 = cal.startOfDay(for: now)
        let day1 = cal.date(byAdding: .day, value: 1, to: day0)!
        let day5 = cal.date(byAdding: .day, value: 5, to: day0)!

        let progLate = makePlannedRecord(sportCode: "running", date: day5)
        let progNow = makePlannedRecord(sportCode: "swimming", date: day0)
        let progSoon = makePlannedRecord(sportCode: "cycling", date: day1)
        let progRepo = MockAdaptedProgramRepository()
        progRepo.stubbedActive = [progLate, progNow, progSoon]

        let vm = makeVM(
            programRepo: progRepo,
            profileRepo: MockCoachingProfileRepository(),
            library: ProgramTemplateLibrary(templates: [Self.placeholderTemplate])
        )
        await vm.refresh(userId: userId)

        XCTAssertEqual(vm.activeProgramSummaries.count, 3)
        XCTAssertEqual(vm.activeProgramSummaries.map(\.record.sportCode),
                       ["swimming", "cycling", "running"])
    }

    func testRefreshActiveSummariesResolveTemplateNameFromLibrary() async {
        let templateId = "running-beginner-5k-8sem"
        let library = ProgramTemplateLibrary(templates: [
            ProgramTemplate(
                id: templateId, schemaVersion: 1, sport: .running, level: .beginner,
                name: "Mon premier 5K", durationWeeks: 8, sessionsPerWeek: 3,
                defaultObjective: "n/a", assumedProfile: "n/a", summary: "s",
                weeks: [], safetyNotes: "n/a", progressionLogic: "n/a"
            )
        ])
        let prog = makeRecord(sportCode: "running", sessionsCount: 3, templateId: templateId)
        let progRepo = MockAdaptedProgramRepository()
        progRepo.stubbedActive = [prog]

        let vm = makeVM(programRepo: progRepo, profileRepo: MockCoachingProfileRepository(), library: library)
        await vm.refresh(userId: userId)

        XCTAssertEqual(vm.activeProgramSummaries.first?.templateName, "Mon premier 5K")
    }

    func testRefreshActiveSummariesProgressFractionFromCompletionState() async throws {
        let prog = makeRecord(sportCode: "running", sessionsCount: 4)
        // Marque 1 sur 4 sessions complétées.
        var state = ProgramCompletionState.empty
        state.sessionRecords[prog.sessions[0].id] = SessionCompletionRecord(completedAt: Date())
        prog.completionState = state

        let progRepo = MockAdaptedProgramRepository()
        progRepo.stubbedActive = [prog]
        let vm = makeVM(
            programRepo: progRepo,
            profileRepo: MockCoachingProfileRepository(),
            library: ProgramTemplateLibrary(templates: [Self.placeholderTemplate])
        )
        await vm.refresh(userId: userId)

        let progress = try XCTUnwrap(vm.activeProgramSummaries.first?.progress)
        XCTAssertEqual(progress, 0.25, accuracy: 0.01)
    }

    // MARK: - Mode rest day + WeeklyStats + nextAfter (sous-tâche 8)

    func testRefreshSetsRestDayHintWhenDominantIsTomorrow() async {
        let cal = Calendar.current
        let tomorrow = cal.date(byAdding: .day, value: 1, to: cal.startOfDay(for: now))!
        let prog = makePlannedRecord(sportCode: "running", date: tomorrow)
        let progRepo = MockAdaptedProgramRepository()
        progRepo.stubbedActive = [prog]
        let vm = makeVM(programRepo: progRepo, profileRepo: MockCoachingProfileRepository(),
                        library: ProgramTemplateLibrary(templates: [Self.placeholderTemplate]))

        await vm.refresh(userId: userId)

        XCTAssertNotNil(vm.restDayHintKey, "Hint Léon doit être set quand prochaine séance > J+0")
    }

    func testRefreshClearsRestDayHintWhenDominantIsToday() async {
        let prog = makePlannedRecord(sportCode: "running", date: now)
        let progRepo = MockAdaptedProgramRepository()
        progRepo.stubbedActive = [prog]
        let vm = makeVM(programRepo: progRepo, profileRepo: MockCoachingProfileRepository(),
                        library: ProgramTemplateLibrary(templates: [Self.placeholderTemplate]))

        await vm.refresh(userId: userId)

        XCTAssertNil(vm.restDayHintKey, "Hint rest day doit être nil quand prochaine séance aujourd'hui")
    }

    func testRefreshSetsNextAfterDominantWhenSingleProgramHas2PlusSessions() async {
        let cal = Calendar.current
        let day0 = cal.startOfDay(for: now)
        let day1 = cal.date(byAdding: .day, value: 1, to: day0)!
        // Programme planned avec 2 sessions futures.
        let s1 = PersistedSession(
            id: UUID(), weekNumber: 1, weekTheme: "W1", weekGoal: "G1",
            day: 1, name: "S1", durationMinutes: 30,
            type: .endurance, warmup: nil, exercises: [], cooldown: nil,
            plannedDate: day0
        )
        let s2 = PersistedSession(
            id: UUID(), weekNumber: 1, weekTheme: "W1", weekGoal: "G1",
            day: 2, name: "S2", durationMinutes: 30,
            type: .endurance, warmup: nil, exercises: [], cooldown: nil,
            plannedDate: day1
        )
        let prog = AdaptedProgramRecord(
            userId: userId, sportCode: "running", level: "beginner",
            templateId: "t", adaptedAt: Date(), weekStartDate: Date(),
            mode: .planned, sessions: [s1, s2]
        )
        let progRepo = MockAdaptedProgramRepository()
        progRepo.stubbedActive = [prog]
        let vm = makeVM(programRepo: progRepo, profileRepo: MockCoachingProfileRepository(),
                        library: ProgramTemplateLibrary(templates: [Self.placeholderTemplate]))

        await vm.refresh(userId: userId)

        XCTAssertNotNil(vm.nextAfterDominant, "nextAfterDominant doit être set en mode 1-prog ≥ 2 sessions")
        XCTAssertEqual(vm.nextAfterDominant?.session.day, 2)
    }

    func testRefreshLeavesNextAfterNilInMultiProgramMode() async {
        let progA = makeRecord(sportCode: "running", sessionsCount: 2)
        let progB = makeRecord(sportCode: "cycling", sessionsCount: 2)
        let progRepo = MockAdaptedProgramRepository()
        progRepo.stubbedActive = [progA, progB]
        let vm = makeVM(programRepo: progRepo, profileRepo: MockCoachingProfileRepository(),
                        library: ProgramTemplateLibrary(templates: [Self.placeholderTemplate]))

        await vm.refresh(userId: userId)

        XCTAssertNil(vm.nextAfterDominant)
        XCTAssertNil(vm.weeklyStats, "weeklyStats reste nil en multi-prog (mini-widget single only)")
    }

    func testRefreshComputesWeeklyStatsInSingleProgramMode() async {
        let prog = makeRecord(sportCode: "running", sessionsCount: 3)
        let progRepo = MockAdaptedProgramRepository()
        progRepo.stubbedActive = [prog]
        let vm = makeVM(programRepo: progRepo, profileRepo: MockCoachingProfileRepository(),
                        library: ProgramTemplateLibrary(templates: [Self.placeholderTemplate]))

        await vm.refresh(userId: userId)

        XCTAssertNotNil(vm.weeklyStats)
        XCTAssertEqual(vm.weeklyStats?.completedCount, 0)
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

    // MARK: - Phase B.4 — auto-trigger regen

    func testRefreshInvokesWeeklyRegenServiceWithUserIdAndNow() async {
        let service = FakeWeeklyRegenApplicationService()
        let vm = makeVM(
            programRepo: MockAdaptedProgramRepository(),
            profileRepo: MockCoachingProfileRepository(),
            library: ProgramTemplateLibrary(templates: [Self.placeholderTemplate]),
            regenService: service
        )

        await vm.refresh(userId: userId)

        XCTAssertEqual(service.checkAndApplyCallCount, 1)
        XCTAssertEqual(service.lastUserId, userId)
        XCTAssertEqual(service.lastNow, now)
    }

    func testRefreshCallsWeeklyRegenServiceBeforeFetchActive() async {
        // Garantit que la mutation S+1 est faite EN PLACE avant la lecture des
        // programmes — donc les durations affichées au dashboard sont les
        // nouvelles, pas les anciennes.
        let progRepo = MockAdaptedProgramRepository()
        let service = FakeWeeklyRegenApplicationService()

        var events: [String] = []
        service.onCheckAndApply = { _, _ in events.append("regen") }
        progRepo.onFetchActive = { _ in events.append("fetchActive") }

        let vm = makeVM(
            programRepo: progRepo,
            profileRepo: MockCoachingProfileRepository(),
            library: ProgramTemplateLibrary(templates: [Self.placeholderTemplate]),
            regenService: service
        )

        await vm.refresh(userId: userId)

        XCTAssertEqual(events, ["regen", "fetchActive"],
                       "Le service de regen doit tick AVANT fetchActive")
    }

    func testRefreshContinuesWhenWeeklyRegenServiceThrows() async {
        // Best-effort : un échec côté service ne doit jamais empêcher le dashboard
        // de se charger ni propager d'erreur visible.
        let service = FakeWeeklyRegenApplicationService()
        service.checkShouldThrow = true
        let prog = makeRecord(sportCode: "running", sessionsCount: 1)
        let progRepo = MockAdaptedProgramRepository()
        progRepo.stubbedActive = [prog]

        let vm = makeVM(
            programRepo: progRepo,
            profileRepo: MockCoachingProfileRepository(),
            library: ProgramTemplateLibrary(templates: [Self.placeholderTemplate]),
            regenService: service
        )

        await vm.refresh(userId: userId)

        XCTAssertNil(vm.error, "L'erreur regen est best-effort, ne remonte pas dans vm.error")
        guard case .singleProgram = vm.mode else {
            return XCTFail("Dashboard doit afficher .singleProgram même si la regen a throw, got \(vm.mode)")
        }
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
        programRepo: MockAdaptedProgramRepository,
        profileRepo: MockCoachingProfileRepository,
        library: ProgramTemplateLibrary,
        regenService: (any WeeklyRegenApplicationService)? = nil
    ) -> SessionDashboardViewModel {
        let routineRepo = MockRoutineRepository()
        return SessionDashboardViewModel(
            programRepository: programRepo,
            routineRepository: routineRepo,
            coachingProfileRepository: profileRepo,
            weeklyRegenApplicationService: regenService,
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
        sessionsCount: Int,
        templateId: String? = nil
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
            templateId: templateId ?? "test-\(sportCode)",
            adaptedAt: Date(timeIntervalSince1970: 1_699_000_000),
            weekStartDate: Date(),
            mode: .ondemand,
            sessions: sessions
        )
    }

    /// Record en mode `.planned` avec une seule session datée — teste le tri
    /// `activeProgramSummaries` par `effectiveDate` ascendant.
    private func makePlannedRecord(sportCode: String, date: Date) -> AdaptedProgramRecord {
        let session = PersistedSession(
            id: UUID(), weekNumber: 1, weekTheme: "W1", weekGoal: "G1",
            day: 1, name: "Session", durationMinutes: 30,
            type: .endurance, warmup: nil, exercises: [], cooldown: nil,
            plannedDate: date
        )
        return AdaptedProgramRecord(
            userId: userId,
            sportCode: sportCode,
            level: "beginner",
            templateId: "test-\(sportCode)",
            adaptedAt: Date(timeIntervalSince1970: 1_699_000_000),
            weekStartDate: Date(),
            mode: .planned,
            sessions: [session]
        )
    }
}
