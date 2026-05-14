// Coaching/Progress/PersonalRecordsEngine.swift
// Story 3.9 — détection des Personal Records (PR) à afficher dans le bloc 4
// « Performances récentes » de l'onglet Progrès.
//
// V1 minimal : un seul type de PR détecté — `longestSession` (plus longue
// session par sport sur la fenêtre, comparée à l'historique hors fenêtre).
// Sans historique suffisant (< 3 sessions par sport hors fenêtre), aucun PR
// n'est émis pour ce sport (sinon les "records" seraient gratuits dès la 1re
// semaine d'usage). Les futurs types (allure, FTP, etc.) viendront avec Epic 4
// tracking qui capturera les métriques fines.
//
// Retourne `[]` si rien à montrer → le bloc UI se masque (AC Story 3.9).
import Foundation

struct PRRecord: Identifiable, Equatable, Sendable {
    enum Kind: String, Equatable, Sendable {
        case longestSession
    }

    let id: UUID
    let kind: Kind
    let sportCode: String
    let valueMinutes: Int
    let previousBestMinutes: Int
    let detectedAt: Date

    init(
        id: UUID = UUID(),
        kind: Kind,
        sportCode: String,
        valueMinutes: Int,
        previousBestMinutes: Int,
        detectedAt: Date
    ) {
        self.id = id
        self.kind = kind
        self.sportCode = sportCode
        self.valueMinutes = valueMinutes
        self.previousBestMinutes = previousBestMinutes
        self.detectedAt = detectedAt
    }
}

struct PersonalRecordsEngine: Sendable {
    /// Nombre minimum de sessions historiques (hors fenêtre) par sport pour
    /// pouvoir comparer. < 3 → pas assez de base, on n'émet pas de PR pour ce sport.
    static let minimumHistoricalSessions = 3
    /// Plafond visuel (AC Story 3.9 : "maximum 3 PR cards affichées").
    static let maxPRsReturned = 3

    init() {}

    func detectRecent(
        period: ProgressPeriod,
        programs: [AdaptedProgramRecord],
        now: Date,
        calendar: Calendar = .current
    ) -> [PRRecord] {
        let windowStart = computeWindowStart(period: period, now: now, calendar: calendar)

        var bySport: [String: [(duration: Int, completedAt: Date)]] = [:]
        for record in programs {
            let sessionsById = Dictionary(uniqueKeysWithValues: record.sessions.map { ($0.id, $0) })
            for (sessionId, completion) in record.completionState.sessionRecords {
                guard completion.completedAt <= now else { continue }
                let estimated = sessionsById[sessionId]?.durationMinutes ?? 0
                let duration = completion.actualDurationMinutes ?? estimated
                guard duration > 0 else { continue }
                bySport[record.sportCode, default: []].append((duration, completion.completedAt))
            }
        }

        var detected: [PRRecord] = []
        for (sport, completions) in bySport {
            let historical = completions.filter { $0.completedAt < windowStart }
            guard historical.count >= Self.minimumHistoricalSessions else { continue }
            let previousBest = historical.map(\.duration).max() ?? 0
            let inWindow = completions.filter { $0.completedAt >= windowStart }
            guard let bestInWindow = inWindow.map(\.duration).max(),
                  bestInWindow > previousBest
            else { continue }

            detected.append(PRRecord(
                kind: .longestSession,
                sportCode: sport,
                valueMinutes: bestInWindow,
                previousBestMinutes: previousBest,
                detectedAt: now
            ))
        }

        return detected
            .sorted { ($0.valueMinutes - $0.previousBestMinutes) > ($1.valueMinutes - $1.previousBestMinutes) }
            .prefix(Self.maxPRsReturned)
            .map { $0 }
    }

    private func computeWindowStart(period: ProgressPeriod, now: Date, calendar: Calendar) -> Date {
        var cal = calendar
        cal.firstWeekday = 2
        switch period {
        case .week:
            let comps = cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
            return cal.date(from: comps) ?? now
        case .month, .quarter:
            return cal.date(byAdding: .day, value: -period.slidingDays, to: now) ?? now
        }
    }
}
