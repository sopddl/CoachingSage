// Coaching/Notifications/NotificationForegroundPresenter.swift
// Epic 8 — délégué UNUserNotificationCenter pour présenter les notifications même
// quand l'app est au premier plan. Sans ce délégué, iOS supprime SILENCIEUSEMENT
// toute notif qui se déclenche app ouverte (= "elle ne tombe pas" alors qu'elle
// était bien planifiée). Assigné une fois au lancement.
import Foundation
import UserNotifications

final class NotificationForegroundPresenter: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationForegroundPresenter()

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Bannière + son + entrée dans le centre de notifs, même app au premier plan.
        completionHandler([.banner, .sound, .list])
    }
}
