// Coaching/Notifications/NotificationDecisionEngine.swift
// Epic 8 — moteur de décision PUR : « quelles notifications planifier, à quand ».
// Aucune dépendance UserNotifications/SwiftData → 100% testable (injection de
// `now` / `calendar`). Le `NotificationService` (MainActor) dérive les entrées
// primitives depuis les services existants puis appelle `decide(_:)`.
import Foundation

/// Entrées primitives (déjà dérivées des services) — volontairement sans
/// `AdaptedProgramRecord` (@Model SwiftData) pour garder le moteur testable sans
/// ModelContext.
struct NotificationDecisionInput {
    /// Préférences courantes (toggles + état anti-spam).
    var prefs: NotificationPreferences
    /// Y a-t-il une séance non faite « disponible » (NextSessionResolver across actifs) ?
    var hasPendingSession: Bool
    /// Date de complétion la plus récente, tous programmes confondus. `nil` = aucune séance jamais faite.
    var lastCompletionDate: Date?
    /// Nombre de séances complétées sur la semaine ISO courante.
    var weeklyCompletedCount: Int
    /// Au moins une routine active est en état `.due` (J−14).
    var renewalDue: Bool
    var now: Date
    var calendar: Calendar
}

/// Résultat : les plans à (re)planifier + les préférences mises à jour (état anti-spam).
struct NotificationDecision: Equatable {
    var plans: [ScheduledNotificationPlan]
    var updatedPrefs: NotificationPreferences
}

enum NotificationDecisionEngine {

    /// Plage diurne autorisée (quiet hours). On ne notifie jamais avant 8h ni après 21h,
    /// même si l'utilisateur a une `preferredHour` nocturne (vieux blob, edge case).
    static let quietHoursLowerBound = 8
    static let quietHoursUpperBound = 21

    /// Seuil de relance d'inactivité (jours pleins sans aucune séance).
    static let nudgeThresholdDays = 4

    static func decide(_ input: NotificationDecisionInput) -> NotificationDecision {
        var prefs = input.prefs

        // Notifications globalement coupées → rien à planifier, état préservé.
        guard prefs.enabled else {
            return NotificationDecision(plans: [], updatedPrefs: prefs)
        }

        let cal = input.calendar
        let now = input.now
        let firingHour = min(max(prefs.preferredHour, quietHoursLowerBound), quietHoursUpperBound)
        let firingMinute = max(0, min(prefs.preferredMinute, 59))

        var candidates: [ScheduledNotificationPlan] = []

        // 1) Rappel de séance — tant qu'une séance est disponible, au prochain créneau.
        if prefs.sessionReminderEnabled, input.hasPendingSession {
            let fire = nextFiringDate(hour: firingHour, minute: firingMinute, now: now, calendar: cal)
            candidates.append(.init(kind: .sessionReminder, fireDate: fire))
        }

        // 2) Renouvellement de routine — J−14 détecté en amont.
        if prefs.routineRenewalEnabled, input.renewalDue {
            let fire = nextFiringDate(hour: firingHour, minute: firingMinute, now: now, calendar: cal)
            candidates.append(.init(kind: .routineRenewal, fireDate: fire))
        }

        // 3) Relance douce — 4 jours pleins sans séance, UNE fois par période de jeûne.
        // On ajoute seulement le CANDIDAT ici ; le marquage `lastNudgeSentAt` se fait
        // APRÈS le dedupe (sinon on noterait « relance envoyée » alors qu'elle a été
        // évincée par un rappel de séance le même jour → relance muette à vie).
        if prefs.nudgeEnabled, let last = input.lastCompletionDate {
            let daysSince = fullDaysBetween(last, now, calendar: cal)
            if daysSince >= nudgeThresholdDays, shouldEmitNudge(prefs: prefs, lastCompletion: last, now: now) {
                let fire = nextFiringDate(hour: firingHour, minute: firingMinute, now: now, calendar: cal)
                candidates.append(.init(kind: .nudge, fireDate: fire))
            }
        }

        // 4) Célébration hebdo — fin de semaine, uniquement si ≥ 1 séance faite.
        if prefs.weeklyCelebrationEnabled, input.weeklyCompletedCount >= 1 {
            if let fire = endOfWeekFiringDate(hour: firingHour, minute: firingMinute, now: now, calendar: cal),
               fire > now {
                candidates.append(.init(kind: .weeklyCelebration, fireDate: fire, count: input.weeklyCompletedCount))
            }
        }

        // Règle « max 1 notification d'engagement par jour calendaire » : pour chaque
        // jour de fire, on ne garde que le plan le plus prioritaire.
        let deduped = dedupePerDay(candidates, calendar: cal)

        // Marque la relance UNIQUEMENT si elle a réellement survécu au dedupe (= elle
        // sera planifiée). Tant qu'elle est évincée, on ne la considère pas envoyée →
        // elle pourra repartir dès que le rappel de séance disparaît (programme terminé).
        if let nudge = deduped.first(where: { $0.kind == .nudge }) {
            prefs.lastNudgeSentAt = nudge.fireDate
        }

        return NotificationDecision(plans: deduped, updatedPrefs: prefs)
    }

    // MARK: - Helpers (purs)

    /// Prochain créneau `hour:minute` : aujourd'hui s'il est encore à venir, sinon demain.
    static func nextFiringDate(hour: Int, minute: Int, now: Date, calendar: Calendar) -> Date {
        let todayFire = setTime(hour: hour, minute: minute, on: now, calendar: calendar)
        if todayFire > now { return todayFire }
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: now) ?? now
        return setTime(hour: hour, minute: minute, on: tomorrow, calendar: calendar)
    }

    /// Créneau de fin de semaine : dimanche (dernier jour de la semaine ISO) à `hour:minute`.
    static func endOfWeekFiringDate(hour: Int, minute: Int, now: Date, calendar: Calendar) -> Date? {
        var cal = calendar
        cal.firstWeekday = 2 // ISO-8601 : semaine lundi → dimanche
        guard let interval = cal.dateInterval(of: .weekOfYear, for: now) else { return nil }
        // `interval.end` = lundi 00:00 suivant ; le dimanche = end − 1 jour.
        guard let sunday = cal.date(byAdding: .day, value: -1, to: interval.end) else { return nil }
        return setTime(hour: hour, minute: minute, on: sunday, calendar: cal)
    }

    static func setTime(hour: Int, minute: Int, on date: Date, calendar: Calendar) -> Date {
        calendar.date(bySettingHour: hour, minute: minute, second: 0, of: date) ?? date
    }

    /// Nombre de jours pleins entre deux dates (sur les `startOfDay`).
    static func fullDaysBetween(_ from: Date, _ to: Date, calendar: Calendar) -> Int {
        let a = calendar.startOfDay(for: from)
        let b = calendar.startOfDay(for: to)
        return calendar.dateComponents([.day], from: a, to: b).day ?? 0
    }

    /// Émettre une relance ssi : jamais relancé, OU déjà relancé mais l'utilisateur a
    /// repris depuis (complétion postérieure → réarmement), OU la relance précédente
    /// est encore PENDING (fire dans le futur → on la maintient sans en créer d'autre).
    static func shouldEmitNudge(prefs: NotificationPreferences, lastCompletion: Date, now: Date) -> Bool {
        guard let lastNudge = prefs.lastNudgeSentAt else { return true }
        if lastNudge > now { return true }                 // encore pending → on la garde
        return lastCompletion > lastNudge                  // reprise depuis la relance → réarmé
    }

    /// Pour chaque jour calendaire de fire, ne conserve que le plan le plus prioritaire.
    static func dedupePerDay(_ plans: [ScheduledNotificationPlan], calendar: Calendar) -> [ScheduledNotificationPlan] {
        var bestPerDay: [Date: ScheduledNotificationPlan] = [:]
        for plan in plans {
            let day = calendar.startOfDay(for: plan.fireDate)
            if let existing = bestPerDay[day] {
                if plan.kind.priority < existing.kind.priority { bestPerDay[day] = plan }
            } else {
                bestPerDay[day] = plan
            }
        }
        return bestPerDay.values.sorted { $0.fireDate < $1.fireDate }
    }
}
