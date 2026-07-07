// CoachingSageTests/Notifications/NotificationDecisionEngineTests.swift
// Epic 8 — filet de régression du moteur de décision PUR (anti-spam, priorité,
// quiet hours, idempotence). Compilé en logic mode (sources app dans le module).
import XCTest

final class NotificationDecisionEngineTests: XCTestCase {

    private var calendar: Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.firstWeekday = 2
        c.timeZone = TimeZone(identifier: "Europe/Paris")!
        return c
    }()

    // Mercredi 24 juin 2026, 07:00 — avant l'heure préférée (9h) → fire « aujourd'hui ».
    private lazy var now: Date = date(2026, 6, 24, 7, 0)

    private func date(_ y: Int, _ mo: Int, _ d: Int, _ h: Int, _ mi: Int) -> Date {
        var c = DateComponents()
        c.year = y; c.month = mo; c.day = d; c.hour = h; c.minute = mi
        return calendar.date(from: c)!
    }

    private func prefs(
        enabled: Bool = true, hour: Int = 9, lastNudge: Date? = nil,
        session: Bool = true, nudge: Bool = true, celeb: Bool = true, renew: Bool = true
    ) -> NotificationPreferences {
        var p = NotificationPreferences()
        p.enabled = enabled
        p.preferredHour = hour
        p.preferredMinute = 0
        p.sessionReminderEnabled = session
        p.nudgeEnabled = nudge
        p.weeklyCelebrationEnabled = celeb
        p.routineRenewalEnabled = renew
        p.lastNudgeSentAt = lastNudge
        return p
    }

    private func input(
        _ p: NotificationPreferences, pending: Bool = false, last: Date? = nil,
        weekly: Int = 0, renew: Bool = false
    ) -> NotificationDecisionInput {
        NotificationDecisionInput(
            prefs: p, hasPendingSession: pending, lastCompletionDate: last,
            weeklyCompletedCount: weekly, renewalDue: renew, now: now, calendar: calendar
        )
    }

    private func hour(of d: Date) -> Int { calendar.component(.hour, from: d) }

    // MARK: - Tests

    func test_disabled_returnsNoPlans() {
        let d = NotificationDecisionEngine.decide(input(prefs(enabled: false), pending: true))
        XCTAssertTrue(d.plans.isEmpty)
    }

    func test_sessionReminder_scheduledTodayAtPreferredHour() {
        let d = NotificationDecisionEngine.decide(input(prefs(), pending: true))
        XCTAssertEqual(d.plans.map(\.kind), [.sessionReminder])
        XCTAssertEqual(hour(of: d.plans[0].fireDate), 9)
        XCTAssertTrue(calendar.isDate(d.plans[0].fireDate, inSameDayAs: now))
    }

    func test_priority_sessionReminderBeatsNudgeSameDay() {
        let fiveDaysAgo = calendar.date(byAdding: .day, value: -5, to: now)!
        // Séance disponible ET inactivité 5j → les deux visent aujourd'hui : la règle
        // « max 1/jour » garde le rappel de séance (prioritaire).
        let d = NotificationDecisionEngine.decide(input(prefs(), pending: true, last: fiveDaysAgo))
        XCTAssertEqual(d.plans.map(\.kind), [.sessionReminder])
        // P1 régression : la relance évincée NE DOIT PAS être marquée comme envoyée,
        // sinon elle resterait muette à vie même après disparition du rappel de séance.
        XCTAssertNil(d.updatedPrefs.lastNudgeSentAt)
    }

    func test_nudge_emittedAfter4Days() {
        let fiveDaysAgo = calendar.date(byAdding: .day, value: -5, to: now)!
        // Rappel séance OFF pour isoler la relance.
        let d = NotificationDecisionEngine.decide(input(prefs(session: false), last: fiveDaysAgo))
        XCTAssertEqual(d.plans.map(\.kind), [.nudge])
        XCTAssertNotNil(d.updatedPrefs.lastNudgeSentAt)
    }

    func test_nudge_notRepeatedAfterFiredWithoutResumption() {
        // Relance déjà envoyée hier (fire dans le passé), aucune séance depuis.
        var p = prefs(session: false)
        p.lastNudgeSentAt = date(2026, 6, 23, 9, 0)          // passé
        let sixDaysAgo = calendar.date(byAdding: .day, value: -6, to: now)! // < lastNudge
        let d = NotificationDecisionEngine.decide(input(p, last: sixDaysAgo))
        XCTAssertFalse(d.plans.contains { $0.kind == .nudge })
    }

    func test_nudge_belowThreshold_notEmitted() {
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: now)!
        let d = NotificationDecisionEngine.decide(input(prefs(session: false), last: twoDaysAgo))
        XCTAssertFalse(d.plans.contains { $0.kind == .nudge })
    }

    func test_noCelebration_whenZeroSessions() {
        let d = NotificationDecisionEngine.decide(input(prefs(), weekly: 0))
        XCTAssertFalse(d.plans.contains { $0.kind == .weeklyCelebration })
    }

    func test_celebration_whenAtLeastOneSession_carriesCount() {
        let d = NotificationDecisionEngine.decide(
            input(prefs(session: false, nudge: false, renew: false), weekly: 3)
        )
        let cel = d.plans.first { $0.kind == .weeklyCelebration }
        XCTAssertNotNil(cel)
        XCTAssertEqual(cel?.count, 3)
        XCTAssertTrue(cel!.fireDate > now)
    }

    func test_quietHours_clampsNocturnalPreferredHour() {
        let d = NotificationDecisionEngine.decide(input(prefs(hour: 2), pending: true))
        XCTAssertEqual(hour(of: d.plans[0].fireDate), NotificationDecisionEngine.quietHoursLowerBound)
    }

    func test_renewalDue_schedulesRenewal() {
        let d = NotificationDecisionEngine.decide(
            input(prefs(session: false, nudge: false, celeb: false), renew: true)
        )
        XCTAssertEqual(d.plans.map(\.kind), [.routineRenewal])
    }
}
