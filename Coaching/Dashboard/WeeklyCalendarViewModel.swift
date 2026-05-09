// Coaching/Dashboard/WeeklyCalendarViewModel.swift
// Story 3.8 sous-tâche drag&drop (commit 10/3) — VM lecture seule du calendrier
// hebdo. Le drag&drop arrive en commit 11.
//
// **Logique buckets** (per record × per session) :
//   - session complétée → ignorée (passée, pas pertinent pour replan)
//   - `plannedDate == nil` → pool « À planifier »
//   - `plannedDate ∈ [weekStart, weekStart+7d)` → bucket jour [0..6] (lundi=0)
//   - `plannedDate` hors fenêtre semaine courante → ignorée (multi-week deferred V1)
//
// **Mode** :
//   - `.singleProgram(id)` : on filtre sur 1 record (push depuis card programme)
//   - `.allActivePrograms` : agrège tous les records actifs (CTA Réorganiser ma
//     semaine + icône 📅 nav bar)
//
// 100% local, 0 réseau, déterministe. Sert de source de vérité au commit 11
// (drag&drop) qui mutera `loadedPrograms[i].sessions[j].plannedDate` puis
// rappellera `recomputeBuckets()`.
import Foundation
import SwiftUI

@MainActor
@Observable
final class WeeklyCalendarViewModel {

    enum Mode: Hashable {
        /// Calendrier zoomé sur un seul programme actif (push depuis card programme
        /// dans `AdaptedProgramView` — entry point #2 spec ligne 624).
        case singleProgram(id: UUID)
        /// Calendrier agrégé tous programmes actifs (CTA `↻ Réorganiser ma semaine`
        /// + icône 📅 nav bar Séances — entry points #1 et #3 spec ligne 623+625).
        case allActivePrograms
    }

    /// Bucket d'un jour de la semaine courante (lundi=0 ... dimanche=6).
    struct WeekDaySlot: Identifiable, Equatable {
        /// Index ISO 0...6 (lundi=0). Sert de drop target ID en commit 11.
        let id: Int
        /// Date 00:00 du jour (heure locale).
        let date: Date
        let items: [SessionItem]
    }

    /// Item plat affiché : un `PersistedSession` + le sport de son `AdaptedProgramRecord`
    /// parent. Un même `sessionId` apparaît exactement une fois (pool OU bucket jour).
    struct SessionItem: Identifiable, Equatable {
        /// = `PersistedSession.id` (UUID stable). Sert de payload drag&drop commit 11.
        let id: UUID
        /// = `AdaptedProgramRecord.id`. Lookup record parent pour mutation.
        let programId: UUID
        let sportCode: String
        let name: String
        let durationMinutes: Int
        /// `nil` = session dans le pool ondemand. Set = session placée par drag&drop.
        let plannedDate: Date?
    }

    private(set) var pool: [SessionItem] = []
    private(set) var daySlots: [WeekDaySlot] = []
    private(set) var loading: Bool = true
    private(set) var error: String?
    /// Lundi 00:00 local de la semaine actuellement affichée. Re-calculé à chaque `refresh`.
    private(set) var weekStart: Date = .distantPast
    private(set) var hasLoaded: Bool = false

    /// Records actifs filtrés selon `mode`. Conservés pour permettre la mutation
    /// in-place (commit 11) sans refaire un round-trip repo.
    private(set) var loadedPrograms: [AdaptedProgramRecord] = []

    let mode: Mode
    private let programRepository: any AdaptedProgramRepository
    private let nowProvider: () -> Date

    init(
        mode: Mode,
        programRepository: any AdaptedProgramRepository,
        nowProvider: @escaping () -> Date = Date.init
    ) {
        self.mode = mode
        self.programRepository = programRepository
        self.nowProvider = nowProvider
    }

    /// Charge les programmes actifs filtrés selon `mode`, puis recalcule pool +
    /// jour buckets. Idempotent : peut être rappelée à chaque `onAppear`.
    func refresh(userId: UUID) async {
        loading = true
        error = nil
        do {
            let all = try await programRepository.fetchActive(for: userId)
            switch mode {
            case .singleProgram(let id):
                loadedPrograms = all.filter { $0.id == id }
            case .allActivePrograms:
                loadedPrograms = all
            }
            recomputeBuckets()
            hasLoaded = true
        } catch {
            self.error = error.localizedDescription
            loadedPrograms = []
            pool = []
            daySlots = makeEmptyDaySlots()
        }
        loading = false
    }

    /// Recalcule pool + 7 buckets jour depuis `loadedPrograms`. Sera ré-appelée
    /// par le commit 11 après chaque mutation drag&drop pour rafraîchir l'UI.
    func recomputeBuckets() {
        let now = nowProvider()
        let cal = Calendar.current
        let weekStart = Self.startOfWeek(for: now, calendar: cal)
        self.weekStart = weekStart
        let weekEnd = cal.date(byAdding: .day, value: 7, to: weekStart) ?? weekStart

        var pool: [SessionItem] = []
        var perDay: [Int: [SessionItem]] = [:]

        for record in loadedPrograms {
            for session in record.sessions {
                if record.completionState.sessionRecords[session.id] != nil { continue }
                let item = SessionItem(
                    id: session.id,
                    programId: record.id,
                    sportCode: record.sportCode,
                    name: session.name,
                    durationMinutes: session.durationMinutes,
                    plannedDate: session.plannedDate
                )
                if let date = session.plannedDate {
                    if date >= weekStart, date < weekEnd {
                        let dayStart = cal.startOfDay(for: date)
                        let dayIndex = cal.dateComponents([.day], from: weekStart, to: dayStart).day ?? 0
                        let safe = max(0, min(6, dayIndex))
                        perDay[safe, default: []].append(item)
                    }
                    // Sinon : plannedDate hors semaine courante → ignorée V1
                    // (multi-week navigation déférée à une story future).
                } else {
                    pool.append(item)
                }
            }
        }

        pool.sort { lhs, rhs in
            lhs.sportCode != rhs.sportCode
                ? lhs.sportCode < rhs.sportCode
                : lhs.name < rhs.name
        }
        for k in perDay.keys {
            perDay[k]?.sort { $0.name < $1.name }
        }

        self.pool = pool
        self.daySlots = (0...6).map { idx in
            let date = cal.date(byAdding: .day, value: idx, to: weekStart) ?? weekStart
            return WeekDaySlot(id: idx, date: date, items: perDay[idx] ?? [])
        }
    }

    private func makeEmptyDaySlots() -> [WeekDaySlot] {
        let cal = Calendar.current
        let ws = Self.startOfWeek(for: nowProvider(), calendar: cal)
        return (0...6).map { idx in
            WeekDaySlot(
                id: idx,
                date: cal.date(byAdding: .day, value: idx, to: ws) ?? ws,
                items: []
            )
        }
    }

    /// Lundi 00:00 (heure locale) de la semaine ISO contenant `now`.
    /// Identique à `AdaptedProgramRecord.startOfCurrentWeek` mais ré-implémenté
    /// ici pour ne pas créer de dépendance Coaching/Persistence → Coaching/Dashboard.
    static func startOfWeek(for now: Date, calendar: Calendar = .current) -> Date {
        var cal = calendar
        cal.firstWeekday = 2 // ISO Monday
        let comps = cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
        return cal.date(from: comps) ?? now
    }
}
