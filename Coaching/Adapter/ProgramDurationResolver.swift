// Coaching/Adapter/ProgramDurationResolver.swift
// Story sœur post-3.3b — calcule la durée finale (en semaines) du programme
// adapté selon le mode `ProgramDurationMode`, et redimensionne la liste de
// `AdaptedWeek` pour matcher cette durée :
//
//   • `routineCyclic`        → 12 semaines fixes (= 3 mois cyclique)
//   • `deadlineFixed`        → ceil((targetDate − now) / 7) ; clampé [4, 24]
//   • `deadlineEstimated`    → LUT (sport × goal × level) ; targetDate calculée
//
// Resize :
//   • Si N == template.weeks.count → no-op
//   • Si N < template.weeks.count → tronque sur les N PREMIERS weeks (V1 simple)
//   • Si N > template.weeks.count → cycle depuis week 1 du template
//
// LUT : valeurs sourcées doctrine running/cycling/triathlon (ACSM, Daniels) avec
// fallback 8 semaines (mid-range) pour combinaisons non listées.
import Foundation
import TemplateModel

public struct ProgramDurationResolver: Sendable {

    /// Borne min/max pour `deadlineFixed` afin d'éviter des programmes trop courts
    /// (< 4 sem = pas le temps d'adapter) ou trop longs (> 24 sem = perte de motivation).
    public static let minWeeks = 4
    public static let maxWeeks = 24

    public init() {}

    // MARK: - Public API

    /// Calcule (targetWeeks, finalTargetDate) selon mode + profile + sport/level.
    /// `now` injecté pour rendre les tests déterministes.
    public func resolve(
        durationMode: ProgramDurationMode,
        targetDate: Date?,
        goal: String,
        sport: Sport,
        level: Level,
        templateDurationWeeks: Int,
        now: Date
    ) -> (targetWeeks: Int, finalTargetDate: Date?) {
        switch durationMode {
        case .routineCyclic:
            return (12, nil)

        case .deadlineFixed:
            // targetDate doit être présent — defensif : fallback sur template duration.
            guard let target = targetDate else {
                return (templateDurationWeeks, nil)
            }
            let weeks = Self.weeksBetween(now: now, target: target)
            let clamped = min(max(weeks, Self.minWeeks), Self.maxWeeks)
            return (clamped, target)

        case .deadlineEstimated:
            let weeks = Self.estimatedWeeks(sport: sport, goal: goal, level: level)
            let target = Calendar.current.date(byAdding: .weekOfYear, value: weeks, to: now) ?? now
            return (weeks, target)
        }
    }

    /// Adapte la liste de `AdaptedWeek` pour matcher `targetWeeks` :
    /// - tronque aux premiers N si N < count
    /// - cycle depuis week 1 si N > count
    /// - no-op si égal
    /// Renumérote `weekNumber` dans tous les cas pour rester séquentiel 1..N.
    public func resize(weeks: [AdaptedWeek], to targetWeeks: Int) -> [AdaptedWeek] {
        guard !weeks.isEmpty, targetWeeks > 0 else { return weeks }
        guard targetWeeks != weeks.count else { return weeks }

        let resized: [AdaptedWeek]
        if targetWeeks < weeks.count {
            resized = Array(weeks.prefix(targetWeeks))
        } else {
            // Cycle depuis week 1 — modulo sur l'index pour reprendre depuis le début.
            resized = (0..<targetWeeks).map { idx in
                let source = weeks[idx % weeks.count]
                return source
            }
        }

        // Renumérote pour garder la séquence 1..N propre (cycle peut produire 1,2,3,1,2,3 sinon).
        return resized.enumerated().map { idx, week in
            AdaptedWeek(
                weekNumber: idx + 1,
                theme: week.theme,
                goal: week.goal,
                sessions: week.sessions
            )
        }
    }

    // MARK: - Internals

    /// Arrondi entier au plus proche, min `minWeeks` ; négatif → minWeeks (date passée).
    static func weeksBetween(now: Date, target: Date) -> Int {
        let interval = target.timeIntervalSince(now)
        guard interval > 0 else { return minWeeks }
        let weeks = Int((interval / (7 * 24 * 3600)).rounded())
        return max(weeks, minWeeks)
    }

    /// LUT estimated weeks par sport × goal × level. Valeurs sourcées doctrine
    /// (ACSM, Daniels Running Formula, fédérations FFT/FFF). Fallback = 8 sem.
    static func estimatedWeeks(sport: Sport, goal: String, level: Level) -> Int {
        let key = "\(sport.rawValue):\(goal):\(level.rawValue)"
        return lut[key] ?? defaultEstimatedWeeks(level: level)
    }

    /// Fallback générique si la combinaison sport×goal×level n'est pas dans la LUT.
    /// Plus le user est avancé, moins il a besoin de semaines pour préparer.
    private static func defaultEstimatedWeeks(level: Level) -> Int {
        switch level {
        case .beginner:     return 10
        case .recreational: return 8
        case .regular:      return 8
        case .competitive:  return 6
        }
    }

    /// Lookup table indexée `"sport:goal:level"`. Keys lowercase.
    private static let lut: [String: Int] = [
        // Running
        "running:5k:beginner": 8,            "running:5k:recreational": 8,
        "running:5k:regular": 6,             "running:5k:competitive": 6,
        "running:10k:beginner": 10,          "running:10k:recreational": 8,
        "running:10k:regular": 8,            "running:10k:competitive": 6,
        "running:half_marathon:beginner": 14, "running:half_marathon:recreational": 12,
        "running:half_marathon:regular": 12, "running:half_marathon:competitive": 10,
        "running:marathon:beginner": 20,     "running:marathon:recreational": 18,
        "running:marathon:regular": 16,      "running:marathon:competitive": 14,

        // Cycling
        "cycling:cyclosportive:beginner": 12, "cycling:cyclosportive:recreational": 10,
        "cycling:cyclosportive:regular": 10,  "cycling:cyclosportive:competitive": 8,

        // Triathlon
        "triathlon:sprint:beginner": 10,     "triathlon:sprint:recreational": 8,
        "triathlon:sprint:regular": 8,       "triathlon:sprint:competitive": 6,
        "triathlon:distance-m:beginner": 14, "triathlon:distance-m:recreational": 12,
        "triathlon:distance-m:regular": 12,  "triathlon:distance-m:competitive": 10,
        "triathlon:half-ironman:beginner": 20, "triathlon:half-ironman:recreational": 18,
        "triathlon:half-ironman:regular": 16, "triathlon:half-ironman:competitive": 14,

        // Tennis
        "tennis:tournoi-prep:beginner": 8,   "tennis:tournoi-prep:recreational": 6,
        "tennis:tournoi-prep:regular": 6,    "tennis:tournoi-prep:competitive": 4,
        "tennis:match-prep:beginner": 8,     "tennis:match-prep:recreational": 6,
        "tennis:match-prep:regular": 6,      "tennis:match-prep:competitive": 4,

        // Football
        "football:saison-regional:beginner": 12, "football:saison-regional:recreational": 10,
        "football:saison-regional:regular": 8,   "football:saison-regional:competitive": 6
    ]
}
