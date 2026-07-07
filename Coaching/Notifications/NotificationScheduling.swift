// Coaching/Notifications/NotificationScheduling.swift
// Epic 8 — frontière testable vers UNUserNotificationCenter. Le `NotificationService`
// ne parle qu'à ce protocole → les tests injectent un mock sans toucher au système.
//
// ⚠️ i18n : le contenu est localisé via `String.localized(_:locale:)` (bon bundle
// selon la langue in-app) — un `String(localized:)` nu ignorerait `AppLanguage`
// (cf `memo_locale_strict_string_localized_pattern`). Le texte est figé au moment
// de la planification ; un changement de langue est rattrapé au prochain reschedule.
import Foundation
import UserNotifications

protocol NotificationScheduling: Sendable {
    func authorizationStatus() async -> UNAuthorizationStatus
    @discardableResult
    func requestAuthorization() async -> Bool
    /// Remplace tout le pending d'engagement par `plans` (idempotent : identifiants
    /// stables par type). `plans` vide = tout annuler.
    func replacePending(with plans: [ScheduledNotificationPlan], locale: Locale) async
}

// MARK: - Implémentation système

final class SystemNotificationScheduler: NotificationScheduling {
    private let center: UNUserNotificationCenter

    init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }

    func authorizationStatus() async -> UNAuthorizationStatus {
        await center.notificationSettings().authorizationStatus
    }

    @discardableResult
    func requestAuthorization() async -> Bool {
        (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
    }

    func replacePending(with plans: [ScheduledNotificationPlan], locale: Locale) async {
        // Retire d'abord tous les pending d'engagement (idempotence : rejouer la
        // planification ne crée jamais de doublon).
        let allIds = EngagementNotificationKind.allCases.map(\.requestIdentifier)
        center.removePendingNotificationRequests(withIdentifiers: allIds)

        for plan in plans {
            let content = UNMutableNotificationContent()
            content.title = NotificationContentBuilder.title(for: plan.kind, locale: locale)
            content.body = NotificationContentBuilder.body(for: plan, locale: locale)
            content.sound = .default

            // `UNCalendarNotificationTrigger` + `DateComponents` heure locale → suit
            // le fuseau de l'appareil (jamais un `Date` absolu figé une fois).
            let comps = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: plan.fireDate
            )
            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
            let request = UNNotificationRequest(
                identifier: plan.kind.requestIdentifier,
                content: content,
                trigger: trigger
            )
            try? await center.add(request)
        }
    }
}

// MARK: - Contenu localisé (MDR-safe, comportemental)

/// Construit titre/corps localisés. Wording strictement comportemental (séances,
/// semaine) — jamais médical / poids / corporel (contrainte EU MDR).
enum NotificationContentBuilder {
    static func title(for kind: EngagementNotificationKind, locale: Locale) -> String {
        switch kind {
        case .sessionReminder:   return String.localized("notif.session_reminder.title", locale: locale)
        case .routineRenewal:    return String.localized("notif.routine_renewal.title", locale: locale)
        case .nudge:             return String.localized("notif.nudge.title", locale: locale)
        case .weeklyCelebration: return String.localized("notif.celebration.title", locale: locale)
        }
    }

    static func body(for plan: ScheduledNotificationPlan, locale: Locale) -> String {
        switch plan.kind {
        case .sessionReminder:   return String.localized("notif.session_reminder.body", locale: locale)
        case .routineRenewal:    return String.localized("notif.routine_renewal.body", locale: locale)
        case .nudge:             return String.localized("notif.nudge.body", locale: locale)
        case .weeklyCelebration:
            let n = plan.count ?? 0
            return String.localized("notif.celebration.body \(n)", locale: locale)
        }
    }
}
