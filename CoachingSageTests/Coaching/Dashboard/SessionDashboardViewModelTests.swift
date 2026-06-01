// CoachingSageTests/Coaching/Dashboard/SessionDashboardViewModelTests.swift
// Story 3.10 — tests refonte Mode :
//   - 0 programme → .empty
//   - ≥ 1 programme → .active(programs, selectedId) avec carrousel trié
//   - Tri 3 niveaux AC22 : démarrés avant dormants ; entre démarrés nextDate asc ;
//     entre dormants lastUpdatedAt desc.
//   - Sélection : par défaut première card, conservée à travers les refresh.
//   - Phase B.4 regen auto-trigger inchangé (toujours câblé).
//
// Tests Story 3.8 sur `.singleProgram` / `.multiProgram` supprimés (modes
// désormais remplacés par `.active`).
import XCTest
import TemplateModel

@MainActor
final class SessionDashboardViewModelTests: XCTestCase {

    private let userId = UUID()
    private let now = Date(timeIntervalSince1970: 1_700_000_000)

    // MARK: - AC30 — Bascule modes Story 3.10

    func testEmptyMode_NoProgram() async {
        let vm = makeVM(programs: [])

        await vm.refresh(userId: userId)

        XCTAssertEqual(vm.mode, .empty)
        XCTAssertFalse(vm.loading)
        XCTAssertNil(vm.error)
        XCTAssertTrue(vm.activeProgramSummaries.isEmpty)
    }

    // MARK: - Story 3.22-F-bis — `emptyState` (3 variantes EmptyDashboardView)

    func testEmptyState_NoProfile_whenProfileNilAndNoPrograms() async {
        let programRepo = MockAdaptedProgramRepository()
        let profileRepo = MockCoachingProfileRepository()
        profileRepo.stubbedProfile = nil // Onboarding non finalisé
        let vm = makeVM(programRepo: programRepo, profileRepo: profileRepo,
                        library: ProgramTemplateLibrary(templates: [Self.placeholderTemplate]))

        await vm.refresh(userId: userId)

        XCTAssertEqual(vm.mode, .empty)
        XCTAssertEqual(vm.emptyState, .noProfile)
    }

    func testEmptyState_NoPrograms_whenProfileExistsButBootstrapFalse() async {
        let programRepo = MockAdaptedProgramRepository()
        let profileRepo = MockCoachingProfileRepository()
        profileRepo.stubbedProfile = CoachingProfile(id: UUID()) // bootstrappedDormants défaut false
        let vm = makeVM(programRepo: programRepo, profileRepo: profileRepo,
                        library: ProgramTemplateLibrary(templates: [Self.placeholderTemplate]))

        await vm.refresh(userId: userId)

        XCTAssertEqual(vm.mode, .empty)
        XCTAssertEqual(vm.emptyState, .noPrograms,
                       "Cas normal : profil OK mais bootstrap pas encore fait")
    }

    func testEmptyState_CrossDeviceMissing_whenBootstrappedTrueButZeroLocalPrograms() async {
        let programRepo = MockAdaptedProgramRepository()
        let profileRepo = MockCoachingProfileRepository()
        let profile = CoachingProfile(id: UUID())
        profile.bootstrappedDormants = true // Flag global Supabase sync OK
        profileRepo.stubbedProfile = profile
        // Mais 0 record local (cross-device) → mode .empty atteint
        let vm = makeVM(programRepo: programRepo, profileRepo: profileRepo,
                        library: ProgramTemplateLibrary(templates: [Self.placeholderTemplate]))

        await vm.refresh(userId: userId)

        XCTAssertEqual(vm.mode, .empty)
        XCTAssertEqual(vm.emptyState, .crossDeviceMissing,
                       "Flag bootstrap=true côté Supabase mais 0 record local : cross-device")
    }

    /// **Story 3.15** — 1 dormant seul : passe désormais en `.dormantOnly`
    /// (avant 3.15, c'était `.active([dormant], dormant.id)`). `selectedId`
    /// n'est plus défini pour un dormant — il est `nil` via `currentSelectedId`.
    func testActiveMode_OneDormant() async {
        let dormant = makeRecord(sportCode: "running", sessionsCount: 3, weekStartDate: nil)
        let vm = makeVM(programs: [dormant])

        await vm.refresh(userId: userId)

        guard case let .dormantOnly(dormants) = vm.mode else {
            return XCTFail("Expected .dormantOnly, got \(vm.mode)")
        }
        XCTAssertEqual(dormants.count, 1)
        XCTAssertEqual(dormants[0].id, dormant.id)
        XCTAssertTrue(dormants[0].isDormant)
        XCTAssertNil(dormants[0].weekStartDate)
        XCTAssertNil(vm.currentSelectedId, "Pas de sélection en .dormantOnly")
    }

    func testActiveMode_OneStarted() async {
        let started = makeRecord(sportCode: "running", sessionsCount: 3, weekStartDate: now)
        let vm = makeVM(programs: [started])

        await vm.refresh(userId: userId)

        guard case let .active(startedList, dormants, selectedId) = vm.mode else {
            return XCTFail("Expected .active, got \(vm.mode)")
        }
        XCTAssertEqual(startedList.count, 1)
        XCTAssertTrue(dormants.isEmpty)
        XCTAssertFalse(startedList[0].isDormant)
        XCTAssertNotNil(startedList[0].weekStartDate)
        XCTAssertEqual(selectedId, started.id)
    }

    /// **Story 3.15** — tri started d'abord (lastUpdatedAt desc), puis dormants
    /// (lastUpdatedAt desc). On vérifie via `activeProgramSummaries` (concat
    /// rétrocompat) qui aplatit started + dormants dans l'ordre attendu.
    func testActiveMode_FiveStartedTenDormant_Sorted() async {
        let startedRecent = makeRecord(sportCode: "running", sessionsCount: 1,
                                       weekStartDate: now,
                                       lastUpdatedAt: Date(timeIntervalSince1970: 9_000))
        let startedOlder = makeRecord(sportCode: "cycling", sessionsCount: 1,
                                      weekStartDate: now,
                                      lastUpdatedAt: Date(timeIntervalSince1970: 8_000))
        let dormantOldest = makeRecord(sportCode: "swimming", sessionsCount: 1, weekStartDate: nil,
                                       lastUpdatedAt: Date(timeIntervalSince1970: 1_000))
        let dormantMid = makeRecord(sportCode: "yoga", sessionsCount: 1, weekStartDate: nil,
                                    lastUpdatedAt: Date(timeIntervalSince1970: 2_000))
        let dormantNewest = makeRecord(sportCode: "tennis", sessionsCount: 1, weekStartDate: nil,
                                       lastUpdatedAt: Date(timeIntervalSince1970: 3_000))

        let vm = makeVM(programs: [dormantOldest, startedOlder, dormantNewest, startedRecent, dormantMid])
        await vm.refresh(userId: userId)

        guard case .active = vm.mode else {
            return XCTFail("Expected .active")
        }
        // Démarrés AVANT dormants, et entre chaque groupe : lastUpdatedAt desc
        XCTAssertEqual(vm.activeProgramSummaries.map(\.sport.appSportCode), [
            "running",  // démarré, lastUpdatedAt 9000
            "cycling",  // démarré, lastUpdatedAt 8000
            "tennis",   // dormant, lastUpdatedAt 3000 (le plus récent)
            "yoga",     // dormant, lastUpdatedAt 2000
            "swimming"  // dormant, lastUpdatedAt 1000 (le plus ancien)
        ])
    }

    /// **Story 3.10 AC22 niveau 2 — refondu Story 3.12** : entre démarrés, `lastUpdatedAt desc`.
    func testRefreshSortsActiveProgramsByLastUpdatedDescending_DormantsLast() async {
        let progFar = makeRecord(sportCode: "cycling", sessionsCount: 1,
                                 weekStartDate: now,
                                 lastUpdatedAt: Date(timeIntervalSince1970: 5_000))
        let progNear = makeRecord(sportCode: "running", sessionsCount: 1,
                                  weekStartDate: now,
                                  lastUpdatedAt: Date(timeIntervalSince1970: 7_000))
        let dormant = makeRecord(sportCode: "yoga", sessionsCount: 1, weekStartDate: nil)

        let vm = makeVM(programs: [progFar, dormant, progNear])
        await vm.refresh(userId: userId)

        let codes = vm.activeProgramSummaries.map(\.sport.appSportCode)
        XCTAssertEqual(codes, ["running", "cycling", "yoga"])
    }

    /// **Story 3.10** — `selectProgram(id:)` bascule la sélection.
    func testSelectProgramUpdatesSelectedId() async {
        let progA = makeRecord(sportCode: "running", sessionsCount: 1, weekStartDate: now)
        let progB = makeRecord(sportCode: "cycling", sessionsCount: 1, weekStartDate: now)
        let vm = makeVM(programs: [progA, progB])
        await vm.refresh(userId: userId)

        let firstId = vm.currentSelectedId
        XCTAssertNotNil(firstId)

        // Bascule sur l'autre
        let otherId = firstId == progA.id ? progB.id : progA.id
        vm.selectProgram(id: otherId)
        XCTAssertEqual(vm.currentSelectedId, otherId)
    }

    /// **Story 3.10** — `selectProgram(id:)` no-op sur un id absent.
    func testSelectProgramNoOpOnUnknownId() async {
        let prog = makeRecord(sportCode: "running", sessionsCount: 1, weekStartDate: now)
        let vm = makeVM(programs: [prog])
        await vm.refresh(userId: userId)

        let initialId = vm.currentSelectedId
        vm.selectProgram(id: UUID()) // id qui n'existe pas
        XCTAssertEqual(vm.currentSelectedId, initialId)
    }

    // MARK: - Bascule .empty → .active

    func testRefreshTransitionsFromEmptyToActiveWhenProgramAdded() async {
        let repo = MockAdaptedProgramRepository()
        let vm = makeVM(programRepo: repo)

        await vm.refresh(userId: userId)
        XCTAssertEqual(vm.mode, .empty)

        // Un programme arrive (entre 2 refresh, ex. wire-up persist on adapt).
        let prog = makeRecord(sportCode: "running", sessionsCount: 1, weekStartDate: now)
        repo.stubbedActive = [prog]
        await vm.refresh(userId: userId)

        guard case .active = vm.mode else {
            return XCTFail("Expected bascule vers .active, got \(vm.mode)")
        }
    }

    // MARK: - Erreurs

    func testRefreshFallsBackToEmptyOnRepoError() async {
        let repo = MockAdaptedProgramRepository()
        repo.fetchShouldThrow = true
        let vm = makeVM(programRepo: repo)

        await vm.refresh(userId: userId)

        XCTAssertEqual(vm.mode, .empty)
        XCTAssertNotNil(vm.error)
        XCTAssertFalse(vm.loading)
    }

    // MARK: - Phase B.4 — auto-trigger regen (inchangé Story 3.10)

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

    func testRefreshSilentlySwallowsRegenServiceThrow() async {
        let service = FakeWeeklyRegenApplicationService()
        service.checkShouldThrow = true
        let vm = makeVM(
            programRepo: MockAdaptedProgramRepository(),
            profileRepo: MockCoachingProfileRepository(),
            library: ProgramTemplateLibrary(templates: [Self.placeholderTemplate]),
            regenService: service
        )

        await vm.refresh(userId: userId)

        XCTAssertEqual(service.checkAndApplyCallCount, 1)
        XCTAssertNil(vm.error) // pas exposé à la View
        XCTAssertEqual(vm.mode, .empty) // fetchActive a réussi, juste regen a throw
    }

    func testRefreshSkipsRegenAutoTriggerWhenServiceAbsent() async {
        let vm = makeVM(programs: [])
        await vm.refresh(userId: userId)
        // Pas d'assertion service car aucun n'est injecté ; juste vérifier que
        // l'absence du service ne casse pas le refresh.
        XCTAssertEqual(vm.mode, .empty)
    }

    // MARK: - Story 3.27 Phase A (party 2026-05-30 D1) — tri carrousel par priorité d'action
    //
    // Le tri des `started` n'est plus `lastUpdatedAt desc` mais :
    //   1. late en premier (séance en retard = priorité absolue)
    //   2. sinon `nextSession.weekNumber` asc (semaine la plus proche)
    //   3. fallback `lastUpdatedAt desc`
    // Couverture absente avant Phase C : les tests legacy n'exerçaient que des
    // cas tous égaux (tombe directement sur lastUpdatedAt).

    /// Niveau 1 — un programme « late » remonte en tête du carrousel, même si un
    /// autre programme non-late a un `lastUpdatedAt` plus récent.
    func testCarouselSort_LateProgramFirst_EvenIfLessRecent() async {
        // Late : weekStart il y a 14j (currentWeek 3), seule pending en semaine 1,
        // deadline mode → nextSession week 1 < currentWeek 3 → late.
        let progLate = makeMultiWeekRecord(
            sportCode: "running", weekStartDate: twoWeeksAgo,
            durationMode: .deadlineFixed,
            weeks: [(week: 1, completed: false)],
            lastUpdatedAt: Date(timeIntervalSince1970: 8_000) // plus ancien
        )
        // Non-late mais touché plus récemment.
        let progNormal = makeMultiWeekRecord(
            sportCode: "cycling", weekStartDate: now,
            durationMode: .deadlineFixed,
            weeks: [(week: 1, completed: false)],
            lastUpdatedAt: Date(timeIntervalSince1970: 9_000) // plus récent
        )

        let vm = makeVM(programs: [progNormal, progLate])
        await vm.refresh(userId: userId)

        XCTAssertEqual(vm.startedSummaries.map(\.sport.appSportCode), ["running", "cycling"],
                       "Le programme late doit passer devant malgré un lastUpdatedAt plus ancien")
        XCTAssertTrue(vm.startedSummaries[0].nextSessionIsLate)
        XCTAssertFalse(vm.startedSummaries[1].nextSessionIsLate)
    }

    /// Niveau 2 — entre deux programmes non-late, celui dont la prochaine séance
    /// est dans une semaine plus proche passe devant (weekNumber asc), même si
    /// l'autre a un `lastUpdatedAt` plus récent.
    func testCarouselSort_NonLate_ByNextSessionWeekAscending() async {
        // nextSession en semaine 1.
        let progEarly = makeMultiWeekRecord(
            sportCode: "running", weekStartDate: now,
            durationMode: .deadlineFixed,
            weeks: [(week: 1, completed: false), (week: 2, completed: false)],
            lastUpdatedAt: Date(timeIntervalSince1970: 8_000)
        )
        // Semaine 1 complétée → nextSession en semaine 2, mais lastUpdatedAt plus récent.
        let progLater = makeMultiWeekRecord(
            sportCode: "cycling", weekStartDate: now,
            durationMode: .deadlineFixed,
            weeks: [(week: 1, completed: true), (week: 2, completed: false)],
            lastUpdatedAt: Date(timeIntervalSince1970: 9_000)
        )

        let vm = makeVM(programs: [progLater, progEarly])
        await vm.refresh(userId: userId)

        XCTAssertEqual(vm.startedSummaries.map(\.sport.appSportCode), ["running", "cycling"],
                       "nextSession.weekNumber asc l'emporte sur lastUpdatedAt entre non-late")
        XCTAssertFalse(vm.startedSummaries[0].nextSessionIsLate)
        XCTAssertFalse(vm.startedSummaries[1].nextSessionIsLate)
    }

    /// `nextSessionIsLate` reste `false` en `routineCyclic`, même quand la
    /// prochaine séance pointe une semaine antérieure à la semaine courante
    /// (pas de blocage doux pour une routine cyclique).
    func testIsLate_FalseForRoutineCyclic_EvenWhenNextWeekBehind() async {
        let routine = makeMultiWeekRecord(
            sportCode: "yoga", weekStartDate: twoWeeksAgo,
            durationMode: .routineCyclic,
            weeks: [(week: 1, completed: false)],
            lastUpdatedAt: now
        )

        let vm = makeVM(programs: [routine])
        await vm.refresh(userId: userId)

        XCTAssertEqual(vm.startedSummaries.count, 1)
        XCTAssertFalse(vm.startedSummaries[0].nextSessionIsLate,
                       "routineCyclic n'est jamais marqué late, même semaine en retard")
    }

    // MARK: - Helpers

    private var twoWeeksAgo: Date { now.addingTimeInterval(-14 * 86_400) }

    /// **Story 3.27 Phase C** — record multi-semaines avec contrôle fin de la
    /// session pending (1 session par entrée `weeks`, `day` croissant). Permet de
    /// piloter `nextSession.weekNumber` (via les `completed`) et `currentWeekNumber`
    /// (via `weekStartDate`) pour tester le tri carrousel + le flag late.
    private func makeMultiWeekRecord(
        sportCode: String,
        weekStartDate: Date?,
        durationMode: ProgramDurationMode,
        weeks: [(week: Int, completed: Bool)],
        lastUpdatedAt: Date = Date()
    ) -> AdaptedProgramRecord {
        var sessions: [PersistedSession] = []
        var completed: [UUID: SessionCompletionRecord] = [:]
        for (idx, entry) in weeks.enumerated() {
            let id = UUID()
            sessions.append(PersistedSession(
                id: id, weekNumber: entry.week, weekTheme: "W\(entry.week)", weekGoal: "G",
                day: idx + 1, name: "S\(idx + 1)", durationMinutes: 30, type: .endurance,
                warmup: nil, exercises: [], cooldown: nil
            ))
            if entry.completed {
                completed[id] = SessionCompletionRecord(completedAt: now)
            }
        }
        return AdaptedProgramRecord(
            userId: userId, sportCode: sportCode, level: "beginner",
            templateId: "test-\(sportCode)",
            adaptedAt: Date(timeIntervalSince1970: 1_699_000_000),
            weekStartDate: weekStartDate, mode: .planned, sessions: sessions,
            completionState: ProgramCompletionState(sessionRecords: completed),
            durationMode: durationMode, lastUpdatedAt: lastUpdatedAt
        )
    }

    private func makeVM(
        programs: [AdaptedProgramRecord] = []
    ) -> SessionDashboardViewModel {
        let programRepo = MockAdaptedProgramRepository()
        programRepo.stubbedActive = programs
        return makeVM(programRepo: programRepo)
    }

    private func makeVM(
        programRepo: MockAdaptedProgramRepository
    ) -> SessionDashboardViewModel {
        return SessionDashboardViewModel(
            programRepository: programRepo,
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
        regenService: (any WeeklyRegenApplicationService)? = nil,
        regenRepo: (any WeeklyRegenRepository)? = nil
    ) -> SessionDashboardViewModel {
        return SessionDashboardViewModel(
            programRepository: programRepo,
            coachingProfileRepository: profileRepo,
            weeklyRegenApplicationService: regenService,
            weeklyRegenRepository: regenRepo,
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

    private func makeRecord(
        sportCode: String,
        sessionsCount: Int,
        templateId: String? = nil,
        weekStartDate: Date? = nil,
        lastUpdatedAt: Date = Date()
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
            weekStartDate: weekStartDate,
            mode: .ondemand,
            sessions: sessions,
            lastUpdatedAt: lastUpdatedAt
        )
    }

}

// FakeWeeklyRegenApplicationService et MockWeeklyRegenRepository sont définis
// ailleurs dans le suite test (Mocks/ ou autre fichier de tests Regen).
