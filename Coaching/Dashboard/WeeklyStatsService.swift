// Coaching/Dashboard/WeeklyStatsService.swift
// Story 3.8 sous-tâche 8 — calcule les 3 stats inline du mini-widget « Cette
// semaine » du mode actif single program (volume, séances complétées, streak).
//
// 100% local, sync, < 50ms attendu (cf spec ligne 582). Story 3.9 ajoute
// `compute(programs:, now:, period:, calendar:)` pour les fenêtres month/quarter
// de l'onglet Progrès. Le calcul streak reste global (ne dépend pas de la fenêtre).
import Foundation

/// Story 3.9 — fenêtre temporelle du widget stats / onglet Progrès.
/// `.week` = semaine ISO courante (lundi 00:00 → maintenant) — back-compat dashboard 3.8.
/// `.month` = 30 jours glissants. `.quarter` = 90 jours glissants.
enum ProgressPeriod: String, CaseIterable, Sendable {
    case week
    case month
    case quarter

    /// Nombre de jours pour les fenêtres glissantes. `.week` n'utilise pas cette
    /// valeur (calcul ISO-8601 spécifique).
    var slidingDays: Int {
        switch self {
        case .week:    return 7
        case .month:   return 30
        case .quarter: return 90
        }
    }
}

struct WeeklyStats: Equatable, Sendable {
    /// Durée totale (minutes) effectivement réalisée sur la fenêtre.
    /// Source : `SessionCompletionRecord.actualDurationMinutes` quand présent,
    /// fallback `PersistedSession.durationMinutes` (estimation template).
    let totalMinutes: Int

    /// Nombre de sessions complétées sur la fenêtre.
    let completedCount: Int

    /// Nombre de jours consécutifs avec ≥ 1 session complétée jusqu'à aujourd'hui
    /// (inclus). Global — ne dépend pas de la fenêtre. 0 si rien aujourd'hui ni hier.
    let streakDays: Int

    static let empty = WeeklyStats(totalMinutes: 0, completedCount: 0, streakDays: 0)
}

struct WeeklyStatsService: Sendable {
    init() {}

    /// Calcule les 3 stats sur la **semaine courante** (lundi 00:00 → maintenant).
    /// `programs` agrège tous les programmes actifs (mode 1-prog y mettra une seule
    /// entrée, mais l'API reste multi pour la cohérence Story 3.9).
    func computeCurrentWeek(
        programs: [AdaptedProgramRecord],
        now: Date,
        calendar: Calendar = .current
    ) -> WeeklyStats {
        compute(programs: programs, now: now, period: .week, calendar: calendar)
    }

    /// Story 3.9 — version paramétrisée par `ProgressPeriod`. `.week` délègue au
    /// calcul ISO-8601 historique (back-compat dashboard 3.8). `.month` / `.quarter`
    /// utilisent une fenêtre glissante en jours. Streak reste global dans tous les cas.
    func compute(
        programs: [AdaptedProgramRecord],
        now: Date,
        period: ProgressPeriod,
        calendar: Calendar = .current
    ) -> WeeklyStats {
        var cal = calendar
        cal.firstWeekday = 2 // ISO-8601 lundi
        let windowStart: Date
        switch period {
        case .week:
            windowStart = startOfCurrentWeek(now: now, calendar: cal)
        case .month, .quarter:
            windowStart = cal.date(byAdding: .day, value: -period.slidingDays, to: now)
                ?? startOfCurrentWeek(now: now, calendar: cal)
        }

        var totalMinutes = 0
        var completedCount = 0
        var completionDays = Set<Date>()

        for record in programs {
            let sessionsById = Dictionary(uniqueKeysWithValues: record.sessions.map { ($0.id, $0) })
            for (sessionId, completion) in record.completionState.sessionRecords {
                guard completion.completedAt <= now else { continue }
                // Streak : on garde tout l'historique pour mesurer la chaîne consécutive
                // au-delà de la fenêtre (un user 30j d'affilée veut voir streak=30,
                // peu importe la fenêtre sélectionnée à l'écran Progrès).
                completionDays.insert(cal.startOfDay(for: completion.completedAt))
                // Volume + completed : cantonnés à la fenêtre.
                guard completion.completedAt >= windowStart else { continue }
                completedCount += 1
                let estimated = sessionsById[sessionId]?.durationMinutes ?? 0
                totalMinutes += completion.actualDurationMinutes ?? estimated
            }
        }

        let streak = computeStreak(completionDays: completionDays, now: now, calendar: cal)
        return WeeklyStats(
            totalMinutes: totalMinutes,
            completedCount: completedCount,
            streakDays: streak
        )
    }

    /// Lundi 00:00 (heure locale) — duplique volontairement `AdaptedProgramRecord.startOfCurrentWeek`
    /// pour garder ce service indépendant du modèle SwiftData (testabilité Story 3.9 sans Schema).
    private func startOfCurrentWeek(now: Date, calendar: Calendar) -> Date {
        let comps = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
        return calendar.date(from: comps) ?? now
    }

    /// Streak ascendant : compte les jours consécutifs avec ≥ 1 session jusqu'à
    /// aujourd'hui inclus. Si rien aujourd'hui, on regarde hier comme fin de chaîne
    /// (un user qui s'entraîne 1j sur 2 ne perd pas le streak immédiatement).
    private func computeStreak(completionDays: Set<Date>, now: Date, calendar: Calendar) -> Int {
        guard !completionDays.isEmpty else { return 0 }
        let today = calendar.startOfDay(for: now)
        var anchor = today
        if !completionDays.contains(today) {
            // Tolère un jour vide aujourd'hui — la chaîne s'évalue depuis hier.
            anchor = calendar.date(byAdding: .day, value: -1, to: today) ?? today
            if !completionDays.contains(anchor) { return 0 }
        }
        var streak = 0
        var cursor = anchor
        while completionDays.contains(cursor) {
            streak += 1
            cursor = calendar.date(byAdding: .day, value: -1, to: cursor) ?? cursor
        }
        return streak
    }
}
