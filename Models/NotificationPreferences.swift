// Models/NotificationPreferences.swift
// Structure JSON pour SageCoreProfile.notificationPreferences.
// Epic 8 (Notifications & Engagement) — étendu 2026-06-26 : toggles par type +
// état anti-spam (`lastNudgeSentAt`) pour la règle « une seule relance, silence
// jusqu'à reprise ». Tous les nouveaux champs sont `decodeIfPresent ?? default`
// → rétro-compatible avec les blobs JSONB existants (profils antérieurs).
import Foundation

struct NotificationPreferences: Codable, Equatable {
    /// Interrupteur global. `false` = aucune notification (tout le pending est annulé).
    var enabled: Bool = false
    /// Heure préférée d'envoi (clampée en plage diurne par le moteur de décision).
    var preferredHour: Int = 9
    var preferredMinute: Int = 0

    // MARK: Toggles par type (Epic 8)
    /// Rappel de la séance du jour à l'heure préférée.
    var sessionReminderEnabled: Bool = true
    /// Relance douce après plusieurs jours sans séance.
    var nudgeEnabled: Bool = true
    /// Récap positif de fin de semaine.
    var weeklyCelebrationEnabled: Bool = true
    /// Rappel J−14 avant l'échéance d'une routine cyclique.
    var routineRenewalEnabled: Bool = true

    // MARK: État anti-spam / idempotence (Epic 8)
    /// Date de fire de la dernière relance d'inactivité planifiée. Sert à ne PAS
    /// reproposer de relance tant que l'utilisateur n'a pas refait une séance
    /// (réarmement quand une complétion postérieure survient). Synchronisé via
    /// Supabase → cohérent multi-device.
    var lastNudgeSentAt: Date?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        enabled = try container.decodeIfPresent(Bool.self, forKey: .enabled) ?? false
        preferredHour = try container.decodeIfPresent(Int.self, forKey: .preferredHour) ?? 9
        preferredMinute = try container.decodeIfPresent(Int.self, forKey: .preferredMinute) ?? 0
        sessionReminderEnabled = try container.decodeIfPresent(Bool.self, forKey: .sessionReminderEnabled) ?? true
        nudgeEnabled = try container.decodeIfPresent(Bool.self, forKey: .nudgeEnabled) ?? true
        weeklyCelebrationEnabled = try container.decodeIfPresent(Bool.self, forKey: .weeklyCelebrationEnabled) ?? true
        routineRenewalEnabled = try container.decodeIfPresent(Bool.self, forKey: .routineRenewalEnabled) ?? true
        lastNudgeSentAt = try container.decodeIfPresent(Date.self, forKey: .lastNudgeSentAt)
    }

    init() { }

    enum CodingKeys: String, CodingKey {
        case enabled
        case preferredHour = "preferred_hour"
        case preferredMinute = "preferred_minute"
        case sessionReminderEnabled = "session_reminder_enabled"
        case nudgeEnabled = "nudge_enabled"
        case weeklyCelebrationEnabled = "weekly_celebration_enabled"
        case routineRenewalEnabled = "routine_renewal_enabled"
        case lastNudgeSentAt = "last_nudge_sent_at"
    }
}

extension SageCoreProfile {
    /// Décode les préférences de notification depuis le champ Data? JSON.
    var decodedNotificationPreferences: NotificationPreferences {
        get {
            guard let data = notificationPreferences else {
                return NotificationPreferences()
            }
            return (try? JSONDecoder().decode(NotificationPreferences.self, from: data)) ?? NotificationPreferences()
        }
        set {
            notificationPreferences = try? JSONEncoder().encode(newValue)
        }
    }

    func setNotificationPreferences(_ prefs: NotificationPreferences) {
        notificationPreferences = try? JSONEncoder().encode(prefs)
    }
}
