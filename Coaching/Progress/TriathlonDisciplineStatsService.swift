// Coaching/Progress/TriathlonDisciplineStatsService.swift
// Chantier récap hebdo triathlon (2026-07-06/07) — bloc 5 de l'onglet Progrès :
// répartition des séances COMPLÉTÉES par discipline (nage/vélo/course) sur la
// fenêtre, pour un programme triathlon actif. Miroir de `WeeklyStatsService`
// (bloc 1) : source = complétions app (PersistedSession + completionState),
// PAS HealthKit — contrairement au bloc 3 "Volume par sport" qui agrège tous
// les workouts HK du user, indépendamment du programme suivi.
import Foundation

/// Ligne « répartition triathlon ». `sportCode` ∈ {"swimming", "cycling", "running"}
/// — les séances renfo/mobilité (fallback `programSportCode`) ne comptent pas
/// comme discipline, cf `SessionSportInference`.
struct TriathlonDisciplineRow: Identifiable, Equatable, Sendable {
    let id: String
    let sportCode: String
    let completedCount: Int
    /// Ratio 0...1 vs la discipline la plus pratiquée (pour la barre 6px).
    let ratio: Double
}

struct TriathlonDisciplineStatsService: Sendable {
    init() {}

    /// `[]` si aucun programme triathlon actif, ou aucune séance complétée sur
    /// la fenêtre. Ordre nage→vélo→course (convention affichage, cf `SessionSportInference`).
    func compute(
        programs: [AdaptedProgramRecord],
        now: Date,
        period: ProgressPeriod,
        calendar: Calendar = .current
    ) -> [TriathlonDisciplineRow] {
        let triathlonPrograms = programs.filter { $0.sportCode == "triathlon" }
        guard !triathlonPrograms.isEmpty else { return [] }

        var cal = calendar
        cal.firstWeekday = 2 // ISO-8601 lundi
        let windowStart: Date
        switch period {
        case .week:
            let comps = cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
            windowStart = cal.date(from: comps) ?? now
        case .month, .quarter:
            windowStart = cal.date(byAdding: .day, value: -period.slidingDays, to: now) ?? now
        }

        var countsByCode: [String: Int] = [:]
        for record in triathlonPrograms {
            let sessionsById = Dictionary(uniqueKeysWithValues: record.sessions.map { ($0.id, $0) })
            for (sessionId, completion) in record.completionState.sessionRecords {
                guard completion.completedAt <= now, completion.completedAt >= windowStart else { continue }
                guard let session = sessionsById[sessionId] else { continue }
                let code = SessionSportInference.sportCode(for: session, programSportCode: record.sportCode)
                guard code != record.sportCode else { continue } // exclut fallback renfo/mobilité
                countsByCode[code, default: 0] += 1
            }
        }
        guard !countsByCode.isEmpty else { return [] }

        let maxCount = countsByCode.values.max() ?? 1
        let order = ["swimming", "cycling", "running"]
        return order.compactMap { code in
            guard let count = countsByCode[code] else { return nil }
            return TriathlonDisciplineRow(
                id: code, sportCode: code, completedCount: count,
                ratio: Double(count) / Double(maxCount)
            )
        }
    }
}
