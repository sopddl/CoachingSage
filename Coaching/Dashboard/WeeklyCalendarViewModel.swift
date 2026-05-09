// Coaching/Dashboard/WeeklyCalendarViewModel.swift
// Story 3.8 sous-tâche drag&drop — VM du calendrier hebdo, lecture + handleDrop.
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
// **Drag&drop** (`handleDrop`) :
//   - mute `loadedPrograms[i].sessions[j].plannedDate` selon `DropTarget`
//   - bascule `mode .ondemand → .planned` au premier drop sur un jour (one-way,
//     spec ligne 619 « le premier drop EST la conversion ») ; un retour pool
//     n'auto-révoque pas le mode (interprétation conservatrice, V1)
//   - debounce 100ms anti-double-fire iOS 17.x : drops identiques dans la
//     fenêtre sont ignorés (spec ligne 630)
//   - persistance best-effort via `programRepository.update(_:)`
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

    /// Cible d'un drop drag&drop hebdo.
    enum DropTarget: Hashable {
        /// Bucket jour de la semaine courante (0=lundi, 6=dimanche).
        case day(Int)
        /// Pool « À planifier » (clear `plannedDate`).
        case pool
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
    private let dropClock: () -> Date
    private let debounceWindow: TimeInterval

    /// Dernier drop appliqué (sessionId, target, timestamp wall-clock). Sert au
    /// debounce 100ms anti-double-fire iOS 17.x sur `.dropDestination()`.
    private var lastDrop: (sessionId: UUID, target: DropTarget, at: Date)?

    init(
        mode: Mode,
        programRepository: any AdaptedProgramRepository,
        nowProvider: @escaping () -> Date = Date.init,
        dropClock: @escaping () -> Date = Date.init,
        debounceWindow: TimeInterval = 0.1
    ) {
        self.mode = mode
        self.programRepository = programRepository
        self.nowProvider = nowProvider
        self.dropClock = dropClock
        self.debounceWindow = debounceWindow
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

    /// Applique un drop drag&drop : déplace la session vers `target` (jour ou
    /// pool), bascule éventuellement le mode du programme parent, recompute
    /// les buckets, et persiste via `update(_:)`. Idempotent + debouncé 100ms.
    ///
    /// - Drop sur `.day(idx)` : `plannedDate = weekStart + idx jours` (00:00
    ///   local) ; bascule `.ondemand → .planned` si c'était le 1er drop daté
    ///   sur ce programme.
    /// - Drop sur `.pool` : `plannedDate = nil` ; ne révoque pas le mode (V1).
    /// - SessionId inconnu, drop identique au state actuel, ou drop debouncé
    ///   → no-op (pas d'appel `update`).
    func handleDrop(sessionId: UUID, to target: DropTarget) async {
        let now = dropClock()
        if let last = lastDrop,
           last.sessionId == sessionId,
           last.target == target,
           now.timeIntervalSince(last.at) < debounceWindow {
            return
        }

        guard let progIdx = loadedPrograms.firstIndex(where: { record in
            record.sessions.contains(where: { $0.id == sessionId })
        }) else { return }
        var sessions = loadedPrograms[progIdx].sessions
        guard let sessIdx = sessions.firstIndex(where: { $0.id == sessionId }) else { return }

        let cal = Calendar.current
        let newPlannedDate: Date?
        switch target {
        case .pool:
            newPlannedDate = nil
        case .day(let dayIdx):
            let safe = max(0, min(6, dayIdx))
            newPlannedDate = cal.date(byAdding: .day, value: safe, to: weekStart) ?? weekStart
        }

        if sessions[sessIdx].plannedDate == newPlannedDate { return }

        lastDrop = (sessionId: sessionId, target: target, at: now)

        sessions[sessIdx].plannedDate = newPlannedDate
        loadedPrograms[progIdx].sessions = sessions
        if newPlannedDate != nil, loadedPrograms[progIdx].mode == .ondemand {
            loadedPrograms[progIdx].mode = .planned
        }
        recomputeBuckets()

        let recordToPersist = loadedPrograms[progIdx]
        try? await programRepository.update(recordToPersist)
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
