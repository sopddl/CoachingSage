// Coaching/Dashboard/NextSessionResolver.swift
// Résout « la prochaine séance » à partir d'un (ou plusieurs) `AdaptedProgramRecord`.
// 100% sync, déterministe, 0 réseau.
//
// **Logique per-program** (`nextSession(for:now:)`) :
//   1. Story 3.11 AC4 : programme dormant (`weekStartDate == nil`) → retourne `nil`.
//   2. Filtrer les sessions non complétées (absentes de `completionState`).
//   3. En `mode = .planned` ET `durationMode ∈ {.deadlineFixed,.deadlineEstimated}` :
//      **blocage doux Story 3.11 AC1**. La semaine N+1 ne s'ouvre QUE quand toutes
//      les séances de la semaine N (et antérieures) sont complétées. La prochaine
//      séance affichée est la plus ancienne pending de la première semaine
//      `≤ currentWeekNumber` qui en contient.
//      Si toutes les semaines `≤ currentWeekNumber` sont complétées, on retombe
//      sur la prochaine pending par `(weekNumber, day)`.
//   4. En `mode = .ondemand` (ou `.planned + .routineCyclic`) : trier par
//      `(weekNumber, day)` ascendant, retourner la première non complétée.
//
// **Logique multi-programmes** (`nextSession(across:now:)`) :
//   1. Calculer la prochaine session de chaque programme (étape per-program).
//   2. Retenir celle dont la `effectiveDate` est la plus proche dans le futur (ou aujourd'hui).
//   3. Tie-break : ordre alphabétique `sportCode`.
//
// **`effectiveDate`** : depuis la refonte vue semaine, la séance n'a plus de date
// planifiée — toute séance pending est disponible aujourd'hui. `effectiveDate = now`
// pour toutes les sessions, ce qui simplifie le tri multi-prog.
import Foundation

struct NextSessionResolver {
    struct Result: Equatable {
        let program: AdaptedProgramRecord
        let session: PersistedSession
        /// Date de référence pour le tri multi-prog. Toujours `now` depuis la
        /// refonte vue semaine (les séances n'ont plus de date individuelle).
        let effectiveDate: Date

        static func == (lhs: Result, rhs: Result) -> Bool {
            lhs.program.id == rhs.program.id
                && lhs.session.id == rhs.session.id
                && lhs.effectiveDate == rhs.effectiveDate
        }
    }

    /// Liste **toutes** les sessions à venir d'un programme, triées par
    /// `(weekNumber, day)` ascendant. Sert au mode 1-prog pour exposer la 2e
    /// séance (card « Et après ») sans dupliquer la logique de filtrage / tri.
    func upcomingSessions(for record: AdaptedProgramRecord, now: Date) -> [Result] {
        let completedIds = Set(record.completionState.sessionRecords.keys)
        let pending = record.sessions.filter { !completedIds.contains($0.id) }
        guard !pending.isEmpty else { return [] }

        let ordered = pending.sorted {
            $0.weekNumber != $1.weekNumber
                ? $0.weekNumber < $1.weekNumber
                : $0.day < $1.day
        }
        return ordered.map { Result(program: record, session: $0, effectiveDate: now) }
    }

    func nextSession(for record: AdaptedProgramRecord, now: Date) -> Result? {
        // **Story 3.11 AC4** — programme dormant (`weekStartDate == nil`) :
        // pas de prochaine séance, l'UI affiche "Non commencé" via `isDormant`.
        guard let weekStart = record.weekStartDate else { return nil }

        let completedIds = Set(record.completionState.sessionRecords.keys)
        let pending = record.sessions.filter { !completedIds.contains($0.id) }
        guard !pending.isEmpty else { return nil }

        switch record.mode {
        case .planned:
            // **Story 3.11 AC1** — blocage doux pour les modes deadline.
            // La semaine N+1 ne devient "active" QUE quand toutes les séances
            // de N sont complétées. Sinon, on affiche la séance la plus ancienne
            // pending de la première semaine ≤ currentWeek qui en contient.
            switch record.durationMode {
            case .deadlineFixed, .deadlineEstimated:
                let currentWeek = Self.currentWeekNumber(weekStartDate: weekStart, now: now)
                let blockingWeek = pending
                    .map(\.weekNumber)
                    .filter { $0 <= currentWeek }
                    .min()
                if let blockingWeek {
                    let firstInBlocking = pending
                        .filter { $0.weekNumber == blockingWeek }
                        .sorted {
                            if $0.day != $1.day { return $0.day < $1.day }
                            return $0.id.uuidString < $1.id.uuidString
                        }
                        .first
                    if let session = firstInBlocking {
                        return Result(program: record, session: session, effectiveDate: now)
                    }
                }
                // Toutes les semaines `≤ currentWeek` sont complétées → on
                // retombe sur la 1ère semaine future avec pending.
                let ordered = pending.sorted {
                    if $0.weekNumber != $1.weekNumber { return $0.weekNumber < $1.weekNumber }
                    return $0.day < $1.day
                }
                guard let first = ordered.first else { return nil }
                return Result(program: record, session: first, effectiveDate: now)

            case .routineCyclic:
                // **AC2** — routine cyclique : pas de blocage doux, tri linéaire.
                let ordered = pending.sorted {
                    if $0.weekNumber != $1.weekNumber { return $0.weekNumber < $1.weekNumber }
                    return $0.day < $1.day
                }
                guard let first = ordered.first else { return nil }
                return Result(program: record, session: first, effectiveDate: now)
            }

        case .ondemand:
            // **AC2/AC3** — tri `(weekNumber, day)` ascendant.
            let ordered = pending.sorted {
                if $0.weekNumber != $1.weekNumber { return $0.weekNumber < $1.weekNumber }
                return $0.day < $1.day
            }
            guard let first = ordered.first else { return nil }
            return Result(program: record, session: first, effectiveDate: now)
        }
    }

    /// **Story 3.11** — Numéro de la semaine courante du programme depuis
    /// `weekStartDate` (= lundi 00:00 de S1). Aligné sur
    /// `WeeklyRegenApplicationService.currentWeekNumber(weekStartDate:now:)`.
    static func currentWeekNumber(
        weekStartDate: Date,
        now: Date,
        calendar: Calendar = .current
    ) -> Int {
        let days = calendar.dateComponents([.day], from: weekStartDate, to: now).day ?? 0
        guard days >= 0 else { return 1 }
        return (days / 7) + 1
    }

    func nextSession(across records: [AdaptedProgramRecord], now: Date) -> Result? {
        let candidates = records.compactMap { nextSession(for: $0, now: now) }
        guard !candidates.isEmpty else { return nil }

        return candidates.min { lhs, rhs in
            if lhs.effectiveDate != rhs.effectiveDate {
                return lhs.effectiveDate < rhs.effectiveDate
            }
            return lhs.program.sportCode < rhs.program.sportCode
        }
    }

    /// **Story 3.15 AC7** — Renvoie la séance focale + son teaser N+1 d'un
    /// programme, dans le respect du blocage doux deadline. Garantit la
    /// cohérence focale↔teaser : en mode `.planned + .deadline*`, les 2 sessions
    /// retournées appartiennent à la même `blockingWeek` (la 1ère semaine
    /// ≤ currentWeek qui contient du pending). Si la blockingWeek n'a qu'1
    /// session pending → `teaser = nil` (on ne révèle pas une session de S+1
    /// tant que la semaine bloquante n'est pas terminée).
    ///
    /// Cas particuliers :
    ///   - `weekStartDate == nil` (dormant) → `(focal: nil, teaser: nil)`
    ///   - Aucune session pending (programme complété) → `(nil, nil)`
    ///   - 1 seule session pending → `(focal: not nil, teaser: nil)` ("dernière
    ///     séance de la semaine" affichable côté UI)
    func nextTwoSessions(
        for record: AdaptedProgramRecord,
        now: Date
    ) -> (focal: Result?, teaser: Result?) {
        let ordered = orderedPendingSessions(for: record, now: now)
        guard let first = ordered.first else { return (focal: nil, teaser: nil) }
        let focalResult = Result(program: record, session: first, effectiveDate: now)
        guard ordered.count >= 2 else { return (focal: focalResult, teaser: nil) }
        let teaserResult = Result(program: record, session: ordered[1], effectiveDate: now)
        return (focal: focalResult, teaser: teaserResult)
    }

    /// **Story 3.15** — helper privé : sessions pending triées selon la même
    /// règle que `nextSession(for:now:)`. Centralise la logique de filtrage et
    /// tri pour permettre à `nextTwoSessions` de respecter `blockingWeek`.
    /// Retourne `[]` si dormant ou programme complété.
    private func orderedPendingSessions(
        for record: AdaptedProgramRecord,
        now: Date
    ) -> [PersistedSession] {
        guard let weekStart = record.weekStartDate else { return [] }
        let completedIds = Set(record.completionState.sessionRecords.keys)
        let pending = record.sessions.filter { !completedIds.contains($0.id) }
        guard !pending.isEmpty else { return [] }

        switch record.mode {
        case .planned:
            switch record.durationMode {
            case .deadlineFixed, .deadlineEstimated:
                let currentWeek = Self.currentWeekNumber(weekStartDate: weekStart, now: now)
                // **Story 3.11 AC1** — blocage doux : on prend la 1ère semaine
                // ≤ currentWeek qui contient du pending. focal + teaser doivent
                // tous deux appartenir à cette blockingWeek.
                let blockingWeek = pending
                    .map(\.weekNumber)
                    .filter { $0 <= currentWeek }
                    .min()
                if let blockingWeek {
                    return pending
                        .filter { $0.weekNumber == blockingWeek }
                        .sorted {
                            if $0.day != $1.day { return $0.day < $1.day }
                            return $0.id.uuidString < $1.id.uuidString
                        }
                }
                // Pas de blockingWeek (toutes semaines ≤ currentWeek complétées)
                // → tri linéaire sur les semaines futures.
                return pending.sorted {
                    if $0.weekNumber != $1.weekNumber { return $0.weekNumber < $1.weekNumber }
                    return $0.day < $1.day
                }

            case .routineCyclic:
                return pending.sorted {
                    if $0.weekNumber != $1.weekNumber { return $0.weekNumber < $1.weekNumber }
                    return $0.day < $1.day
                }
            }

        case .ondemand:
            return pending.sorted {
                if $0.weekNumber != $1.weekNumber { return $0.weekNumber < $1.weekNumber }
                return $0.day < $1.day
            }
        }
    }
}
