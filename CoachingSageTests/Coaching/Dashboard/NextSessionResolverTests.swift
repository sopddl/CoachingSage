// CoachingSageTests/Coaching/Dashboard/NextSessionResolverTests.swift
// Tests paramétriques tri prochaine séance :
//   - per-program planned + deadline : blocage doux Story 3.11 + tri (weekNumber, day)
//   - per-program ondemand : retourne la 1re session non complétée (ordre week/day)
//   - completion : skip les sessions déjà dans completionState
//   - multi-prog : effectiveDate = now toujours → tie-break ordre alphabétique sport
//
// Depuis la refonte vue semaine (Story 3.12), les sessions n'ont plus de
// `plannedDate` — l'`effectiveDate` retournée par le resolver est toujours `now`.
import XCTest
import TemplateModel

@MainActor
final class NextSessionResolverTests: XCTestCase {

    private let resolver = NextSessionResolver()
    private let now = Date(timeIntervalSince1970: 1_700_000_000) // mardi 14 nov 2023 22:13 UTC

    // MARK: - Per-program — ondemand mode

    func testOndemandReturnsFirstUncompletedByWeekDayOrder() {
        let s1 = makeSession(weekNumber: 1, day: 1)
        let s2 = makeSession(weekNumber: 1, day: 2)
        let s3 = makeSession(weekNumber: 2, day: 1)
        let record = makeRecord(mode: .ondemand, sessions: [s3, s1, s2]) // pas dans l'ordre

        let result = resolver.nextSession(for: record, now: now)

        XCTAssertEqual(result?.session.id, s1.id)
        XCTAssertEqual(result?.effectiveDate, now)
    }

    func testOndemandSkipsCompletedSessions() {
        let s1 = makeSession(weekNumber: 1, day: 1)
        let s2 = makeSession(weekNumber: 1, day: 2)
        let record = makeRecord(
            mode: .ondemand,
            sessions: [s1, s2],
            completed: [s1.id]
        )

        let result = resolver.nextSession(for: record, now: now)

        XCTAssertEqual(result?.session.id, s2.id)
    }

    // MARK: - Per-program — planned mode + routineCyclic

    func testPlannedRoutineCyclicReturnsFirstUncompletedByWeekDayOrder() {
        let s1 = makeSession(weekNumber: 1, day: 1)
        let s2 = makeSession(weekNumber: 1, day: 2)
        let s3 = makeSession(weekNumber: 2, day: 1)
        let record = makeRecord(
            mode: .planned,
            sessions: [s3, s1, s2],
            durationMode: .routineCyclic
        )

        let result = resolver.nextSession(for: record, now: now)

        XCTAssertEqual(result?.session.id, s1.id)
        XCTAssertEqual(result?.effectiveDate, now)
    }

    // MARK: - Multi-program

    func testNextSessionAcrossTieBreakOnSportCodeAlphabetical() {
        // Tous les programmes ont effectiveDate = now → tie-break alphabétique sport.
        let progRunning = makeRecord(
            sportCode: "running",
            mode: .ondemand,
            sessions: [makeSession(weekNumber: 1, day: 1)]
        )
        let progCycling = makeRecord(
            sportCode: "cycling",
            mode: .ondemand,
            sessions: [makeSession(weekNumber: 1, day: 1)]
        )

        let result = resolver.nextSession(across: [progRunning, progCycling], now: now)

        XCTAssertEqual(result?.program.sportCode, "cycling") // c < r
    }

    func testNextSessionAcrossReturnsNilWhenAllDormant() {
        let prog = makeRecord(
            mode: .ondemand,
            sessions: [makeSession(weekNumber: 1, day: 1)],
            weekStartDate: nil  // dormant
        )

        XCTAssertNil(resolver.nextSession(across: [prog], now: now))
    }

    func testNextSessionAcrossReturnsNilWhenAllCompleted() {
        let s1 = makeSession(weekNumber: 1, day: 1)
        let prog = makeRecord(
            mode: .ondemand,
            sessions: [s1],
            completed: [s1.id]
        )

        XCTAssertNil(resolver.nextSession(across: [prog], now: now))
    }

    // MARK: - Story 3.11 — blocage doux (AC1-AC5)

    /// Helper : `weekStartDate` = `now` − N semaines.
    private func weekStart(weeksAgo: Int, from now: Date) -> Date {
        now.addingTimeInterval(TimeInterval(-weeksAgo * 7 * 86_400))
    }

    func testBlocksOnIncompleteWeek_Planned_deadlineFixed() {
        // S1 incomplète (2 sessions, 1 complétée + 1 pending), date courante = S+2.
        // Attendu : prochaine = la pending de S1 (day=2), ignorant les pending de S2/S3.
        let s1d1 = makeSession(weekNumber: 1, day: 1)
        let s1d2 = makeSession(weekNumber: 1, day: 2)
        let s2d1 = makeSession(weekNumber: 2, day: 1)
        let s3d1 = makeSession(weekNumber: 3, day: 1)
        let record = makeRecord(
            mode: .planned,
            sessions: [s1d1, s1d2, s2d1, s3d1],
            completed: [s1d1.id],
            durationMode: .deadlineFixed,
            weekStartDate: weekStart(weeksAgo: 2, from: now)
        )

        let result = resolver.nextSession(for: record, now: now)

        XCTAssertEqual(result?.session.id, s1d2.id)
        XCTAssertEqual(result?.session.weekNumber, 1)
        XCTAssertEqual(result?.session.day, 2)
    }

    func testWeekOneCompleteJumpsToWeekTwo_Planned_deadlineFixed() {
        // S1 entièrement complétée, date courante = S+2.
        // Attendu : prochaine = 1ʳᵉ pending de S2.
        let s1d1 = makeSession(weekNumber: 1, day: 1)
        let s1d2 = makeSession(weekNumber: 1, day: 2)
        let s2d1 = makeSession(weekNumber: 2, day: 1)
        let s2d2 = makeSession(weekNumber: 2, day: 2)
        let s3d1 = makeSession(weekNumber: 3, day: 1)
        let record = makeRecord(
            mode: .planned,
            sessions: [s1d1, s1d2, s2d1, s2d2, s3d1],
            completed: [s1d1.id, s1d2.id],
            durationMode: .deadlineFixed,
            weekStartDate: weekStart(weeksAgo: 2, from: now)
        )

        let result = resolver.nextSession(for: record, now: now)

        XCTAssertEqual(result?.session.id, s2d1.id)
        XCTAssertEqual(result?.session.weekNumber, 2)
    }

    func testBlocksOnIncompleteWeek_Planned_deadlineEstimated() {
        // Idem mais durationMode = .deadlineEstimated.
        let s1d1 = makeSession(weekNumber: 1, day: 1)
        let s2d1 = makeSession(weekNumber: 2, day: 1)
        let record = makeRecord(
            mode: .planned,
            sessions: [s1d1, s2d1],
            completed: [],
            durationMode: .deadlineEstimated,
            weekStartDate: weekStart(weeksAgo: 2, from: now)
        )

        let result = resolver.nextSession(for: record, now: now)

        XCTAssertEqual(result?.session.id, s1d1.id)
    }

    func testOndemandLegacyBehaviorUnchanged_AC3() {
        // **AC3** — mode .ondemand, tri (weekNumber, day) inchangé.
        let s1d1 = makeSession(weekNumber: 1, day: 1)
        let s2d1 = makeSession(weekNumber: 2, day: 1)
        let record = makeRecord(
            mode: .ondemand,
            sessions: [s1d1, s2d1],
            durationMode: .deadlineFixed,  // ignoré en .ondemand
            weekStartDate: weekStart(weeksAgo: 2, from: now)
        )

        let result = resolver.nextSession(for: record, now: now)

        XCTAssertEqual(result?.session.id, s1d1.id)
        XCTAssertEqual(result?.effectiveDate, now)
    }

    func testDormantReturnsNil_AC4() {
        // **AC4** — programme dormant (`weekStartDate == nil`) → résolveur retourne nil.
        let s = makeSession(weekNumber: 1, day: 1)
        let record = makeRecord(
            mode: .ondemand,
            sessions: [s],
            durationMode: .deadlineFixed,
            weekStartDate: nil
        )

        XCTAssertNil(resolver.nextSession(for: record, now: now))
    }

    // MARK: - Story 3.15 AC7 / AC23 — nextTwoSessions (focal + teaser N+1)

    /// **AC23** — programme avec ≥ 2 sessions pending → tuple `(focal, teaser)` rempli.
    func testNextTwoSessions_returnsFocalAndTeaser_whenAvailable() {
        let s1 = makeSession(weekNumber: 1, day: 1)
        let s2 = makeSession(weekNumber: 1, day: 2)
        let s3 = makeSession(weekNumber: 2, day: 1)
        let record = makeRecord(mode: .ondemand, sessions: [s3, s1, s2])

        let result = resolver.nextTwoSessions(for: record, now: now)

        XCTAssertEqual(result.focal?.session.id, s1.id)
        XCTAssertEqual(result.teaser?.session.id, s2.id)
        XCTAssertEqual(result.focal?.effectiveDate, now)
        XCTAssertEqual(result.teaser?.effectiveDate, now)
    }

    /// **AC23** — programme avec 1 seule session pending → `teaser = nil` (label
    /// UI "Dernière séance de la semaine" possible).
    func testNextTwoSessions_returnsFocalOnly_whenLastOfWeek() {
        let s1 = makeSession(weekNumber: 1, day: 1)
        let s2 = makeSession(weekNumber: 1, day: 2)
        let record = makeRecord(
            mode: .ondemand,
            sessions: [s1, s2],
            completed: [s1.id]
        )

        let result = resolver.nextTwoSessions(for: record, now: now)

        XCTAssertEqual(result.focal?.session.id, s2.id)
        XCTAssertNil(result.teaser)
    }

    /// **AC23** — dormant → (nil, nil).
    func testNextTwoSessions_dormantReturnsNilNil() {
        let s = makeSession(weekNumber: 1, day: 1)
        let record = makeRecord(mode: .ondemand, sessions: [s], weekStartDate: nil)

        let result = resolver.nextTwoSessions(for: record, now: now)

        XCTAssertNil(result.focal)
        XCTAssertNil(result.teaser)
    }

    /// **AC23 (raffiné Sophie 2026-05-20)** — en mode deadline, focal respecte
    /// le blocage doux MAIS le teaser saute en cross-week pour donner un
    /// horizon visuel à l'user.
    ///
    /// Setup : S1 complétée, S2 = [s2d1, s2d2], S3 = [s3d1]. blockingWeek = S2.
    /// Attendu : focal = s2d1 (blocage doux), teaser = s2d2 (linéaire 2e).
    /// (Dans ce cas, le teaser reste dans S2 parce qu'il y a 2 pending en S2
    /// avant S3. Mais voir le test suivant pour cross-week.)
    func testNextTwoSessions_deadlineBlock_teaserIsLinearSecondPending() {
        let s1d1 = makeSession(weekNumber: 1, day: 1)
        let s2d1 = makeSession(weekNumber: 2, day: 1)
        let s2d2 = makeSession(weekNumber: 2, day: 2)
        let s3d1 = makeSession(weekNumber: 3, day: 1)
        let record = makeRecord(
            mode: .planned,
            sessions: [s1d1, s2d1, s2d2, s3d1],
            completed: [s1d1.id],
            durationMode: .deadlineFixed,
            weekStartDate: weekStart(weeksAgo: 2, from: now)
        )

        let result = resolver.nextTwoSessions(for: record, now: now)

        XCTAssertEqual(result.focal?.session.id, s2d1.id, "Focal = blockingWeek S2 (blocage doux)")
        XCTAssertEqual(result.teaser?.session.id, s2d2.id, "Teaser = 2e session linéaire pending")
    }

    /// **AC23 (raffiné Sophie 2026-05-20)** — blockingWeek S2 avec 1 seule
    /// pending → focal=S2, teaser=S3 (cross-week !). Décision Sophie : « même
    /// si c'est sur une autre semaine il faut que ça apparaisse ».
    func testNextTwoSessions_deadlineBlock_teaserCrossesWeek() {
        let s2d1 = makeSession(weekNumber: 2, day: 1)
        let s3d1 = makeSession(weekNumber: 3, day: 1)
        let record = makeRecord(
            mode: .planned,
            sessions: [s2d1, s3d1],
            completed: [],
            durationMode: .deadlineFixed,
            weekStartDate: weekStart(weeksAgo: 2, from: now)
        )

        let result = resolver.nextTwoSessions(for: record, now: now)

        XCTAssertEqual(result.focal?.session.id, s2d1.id, "Focal reste sur blockingWeek S2")
        XCTAssertEqual(result.teaser?.session.id, s3d1.id,
                       "Teaser saute en S3 (cross-week) — décision Sophie 2026-05-20")
        XCTAssertEqual(result.teaser?.session.weekNumber, 3)
    }

    /// **AC23** — cohérence : focal de `nextTwoSessions` == focal de `nextSession(for:now:)`.
    func testNextTwoSessions_focalIsConsistentWithNextSession() {
        let s1d1 = makeSession(weekNumber: 1, day: 1)
        let s1d2 = makeSession(weekNumber: 1, day: 2)
        let s2d1 = makeSession(weekNumber: 2, day: 1)
        let record = makeRecord(
            mode: .planned,
            sessions: [s1d1, s1d2, s2d1],
            completed: [s1d1.id],
            durationMode: .deadlineFixed,
            weekStartDate: weekStart(weeksAgo: 1, from: now)
        )

        let nextResult = resolver.nextSession(for: record, now: now)
        let twoResult = resolver.nextTwoSessions(for: record, now: now)

        XCTAssertEqual(nextResult?.session.id, twoResult.focal?.session.id,
                       "focal doit être identique à nextSession(for:now:)")
    }

    // MARK: - Helpers

    // MARK: - Story 3.31 follow-up — exclusion des jours de repos

    func testNextSessionSkipsRestDays() {
        // Repos en day 1, séance active en day 2 → la prochaine est l'active.
        let rest = makeRest(weekNumber: 1, day: 1)
        let active = makeSession(weekNumber: 1, day: 2)
        let record = makeRecord(mode: .ondemand, sessions: [rest, active])

        let result = resolver.nextSession(for: record, now: now)
        XCTAssertEqual(result?.session.id, active.id, "un Repos complet n'est jamais la prochaine séance")
    }

    func testUpcomingSessionsExcludeRest() {
        let active1 = makeSession(weekNumber: 1, day: 1)
        let rest = makeRest(weekNumber: 1, day: 2)
        let active2 = makeSession(weekNumber: 1, day: 3)
        let record = makeRecord(mode: .ondemand, sessions: [active1, rest, active2])

        let upcoming = resolver.upcomingSessions(for: record, now: now).map(\.session.id)
        XCTAssertEqual(upcoming, [active1.id, active2.id], "la liste séances ne contient aucun repos")
    }

    func testAllActiveDoneButRestPending_returnsNil() {
        // Toutes les séances actives faites, il ne reste que des repos pending
        // (jamais complétables) → le programme est « terminé » côté resolver.
        let active = makeSession(weekNumber: 1, day: 1)
        let rest = makeRest(weekNumber: 1, day: 2)
        let record = makeRecord(
            mode: .planned, sessions: [active, rest],
            completed: [active.id], durationMode: .deadlineFixed
        )

        XCTAssertNil(resolver.nextSession(for: record, now: now),
                     "un programme dont toutes les actives sont faites n'a plus de prochaine séance")
    }

    private func makeRest(weekNumber: Int, day: Int) -> PersistedSession {
        PersistedSession(
            id: UUID(),
            weekNumber: weekNumber,
            weekTheme: "W\(weekNumber)",
            weekGoal: "G\(weekNumber)",
            day: day,
            name: "Repos complet",
            durationMinutes: 0,
            type: .rest,
            warmup: nil,
            exercises: [],
            cooldown: nil
        )
    }

    private func makeSession(
        weekNumber: Int,
        day: Int
    ) -> PersistedSession {
        PersistedSession(
            id: UUID(),
            weekNumber: weekNumber,
            weekTheme: "W\(weekNumber)",
            weekGoal: "G\(weekNumber)",
            day: day,
            name: "S W\(weekNumber)D\(day)",
            durationMinutes: 30,
            type: .endurance,
            warmup: nil,
            exercises: [],
            cooldown: nil
        )
    }

    private func makeRecord(
        sportCode: String = "running",
        mode: ProgramMode,
        sessions: [PersistedSession],
        completed: [UUID] = [],
        durationMode: ProgramDurationMode = .routineCyclic,
        weekStartDate: Date? = Date()
    ) -> AdaptedProgramRecord {
        let completionState = ProgramCompletionState(
            sessionRecords: Dictionary(
                uniqueKeysWithValues: completed.map { id in
                    (id, SessionCompletionRecord(completedAt: Date()))
                }
            )
        )
        return AdaptedProgramRecord(
            userId: UUID(),
            sportCode: sportCode,
            level: "beginner",
            templateId: "test",
            adaptedAt: Date(timeIntervalSince1970: 1_699_000_000),
            weekStartDate: weekStartDate,
            mode: mode,
            sessions: sessions,
            completionState: completionState,
            durationMode: durationMode
        )
    }
}
