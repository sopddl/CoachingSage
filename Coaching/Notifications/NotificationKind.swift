// Coaching/Notifications/NotificationKind.swift
// Epic 8 — les 4 types de notifications d'engagement V1 (locales).
// Pur, sans dépendance UIKit/UserNotifications → utilisable par le moteur de
// décision testable.
import Foundation

/// Les 4 catégories de notification d'engagement. L'ordre de `priority` encode la
/// règle produit validée : rappel séance > renouvellement > relance > célébration
/// (un seul envoi par jour calendaire, le plus prioritaire l'emporte).
enum EngagementNotificationKind: String, CaseIterable, Sendable {
    /// Rappel de la séance du jour à l'heure préférée (cœur de la rétention).
    case sessionReminder
    /// Rappel J−14 avant l'échéance d'une routine cyclique.
    case routineRenewal
    /// Relance douce après plusieurs jours sans séance.
    case nudge
    /// Récap positif de fin de semaine (jamais culpabilisant).
    case weeklyCelebration

    /// Plus petit = plus prioritaire.
    var priority: Int {
        switch self {
        case .sessionReminder:   return 0
        case .routineRenewal:    return 1
        case .nudge:             return 2
        case .weeklyCelebration: return 3
        }
    }

    /// Identifiant stable de la requête `UNNotificationRequest` : 1 pending max par
    /// type → rejouer la planification ne crée jamais de doublon (idempotence).
    var requestIdentifier: String { "engagement.\(rawValue)" }
}

/// Une notification décidée par le moteur, prête à être planifiée. Ne porte que des
/// données pures (pas de `UNNotificationContent`) — la localisation du contenu est
/// faite par le scheduler système au moment de la planification (bon bundle locale).
struct ScheduledNotificationPlan: Equatable, Sendable {
    let kind: EngagementNotificationKind
    /// Date/heure locale de déclenchement (convertie en `DateComponents` par le
    /// scheduler → `UNCalendarNotificationTrigger`, donc suit le fuseau de l'appareil).
    let fireDate: Date
    /// Argument de contenu pour la célébration (nombre de séances de la semaine).
    /// `nil` pour les autres types.
    let count: Int?

    init(kind: EngagementNotificationKind, fireDate: Date, count: Int? = nil) {
        self.kind = kind
        self.fireDate = fireDate
        self.count = count
    }
}
