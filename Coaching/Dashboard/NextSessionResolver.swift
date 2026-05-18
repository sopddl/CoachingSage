// Coaching/Dashboard/NextSessionResolver.swift
// Story 3.8 — résout « la prochaine séance » à partir d'un (ou plusieurs)
// `AdaptedProgramRecord`. 100% sync, déterministe, 0 réseau.
//
// **Logique per-program** (`nextSession(for:now:)`) :
//   1. Story 3.11 AC4 : programme dormant (`weekStartDate == nil`) → retourne `nil`.
//   2. Filtrer les sessions non complétées (absentes de `completionState`).
//   3. En `mode = .planned` ET `durationMode ∈ {.deadlineFixed,.deadlineEstimated}` :
//      **blocage doux Story 3.11 AC1**. La semaine N+1 ne s'ouvre QUE quand toutes
//      les séances de la semaine N (et antérieures) sont complétées. La prochaine
//      séance affichée est la plus ancienne pending de la première semaine
//      `≤ currentWeekNumber` qui en contient — indépendamment de sa `plannedDate`.
//      Si toutes les semaines `≤ currentWeekNumber` sont complétées, on retombe
//      sur la prochaine pending par `(weekNumber, day)`.
//   4. En `mode = .planned` ET `durationMode == .routineCyclic` (cas dégénéré V1)
//      ou autre : comportement original — filter `plannedDate >= startOfDay`, tri
//      `plannedDate` asc.
//   5. En `mode = .ondemand` : trier par `(weekNumber, day)` ascendant. Retourner
//      la première non complétée. Date effective = aujourd'hui (`now`).
//
// **Logique multi-programmes** (`nextSession(across:now:)`) :
//   1. Calculer la prochaine session de chaque programme (étape per-program).
//   2. Retenir celle dont la `effectiveDate` est la plus proche dans le futur (ou aujourd'hui).
//   3. Tie-break : heure la plus proche, sinon ordre alphabétique `sportCode`.
//
// **Pourquoi `effectiveDate` plutôt que `plannedDate` directement** : en
// `.ondemand` ou en mode mixte `.planned` (post-Reporter, Story 3.11 AC13), la
// session n'a pas de date, mais le user peut quand même la démarrer aujourd'hui.
// On normalise donc à `now` pour pouvoir comparer uniformément.
import Foundation

struct NextSessionResolver {
    struct Result: Equatable {
        let program: AdaptedProgramRecord
        let session: PersistedSession
        /// Date utilisée pour le tri multi-prog et l'affichage de la card dominante.
        /// - `.planned` : `session.plannedDate`
        /// - `.ondemand` : `now` (la session est disponible aujourd'hui)
        let effectiveDate: Date

        static func == (lhs: Result, rhs: Result) -> Bool {
            lhs.program.id == rhs.program.id
                && lhs.session.id == rhs.session.id
                && lhs.effectiveDate == rhs.effectiveDate
        }
    }

    /// Liste **toutes** les sessions à venir d'un programme, triées par
    /// `effectiveDate` ascendant. Sert au mode 1-prog pour exposer la 2e
    /// séance (card « Et après » TrainingPeaks-style, sous-tâche 8) sans
    /// dupliquer la logique de filtrage / tri du `nextSession(for:)`.
    func upcomingSessions(for record: AdaptedProgramRecord, now: Date) -> [Result] {
        let completedIds = Set(record.completionState.sessionRecords.keys)
        let pending = record.sessions.filter { !completedIds.contains($0.id) }
        guard !pending.isEmpty else { return [] }

        switch record.mode {
        case .planned:
            let startOfDay = Calendar.current.startOfDay(for: now)
            return pending
                .compactMap { session -> Result? in
                    guard let date = session.plannedDate, date >= startOfDay else { return nil }
                    return Result(program: record, session: session, effectiveDate: date)
                }
                .sorted { $0.effectiveDate < $1.effectiveDate }

        case .ondemand:
            let ordered = pending.sorted {
                $0.weekNumber != $1.weekNumber
                    ? $0.weekNumber < $1.weekNumber
                    : $0.day < $1.day
            }
            return ordered.map { Result(program: record, session: $0, effectiveDate: now) }
        }
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
            // Indépendamment de `plannedDate` (cf AC1 + AC13 mode mixte).
            switch record.durationMode {
            case .deadlineFixed, .deadlineEstimated:
                let currentWeek = Self.currentWeekNumber(weekStartDate: weekStart, now: now)
                // 1ʳᵉ semaine bloquante (`≤ currentWeek` avec du pending).
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
                        let effectiveDate = session.plannedDate ?? now
                        return Result(program: record, session: session, effectiveDate: effectiveDate)
                    }
                }
                // Toutes les semaines `≤ currentWeek` sont complétées → on
                // retombe sur la 1ère semaine future avec pending.
                let ordered = pending.sorted {
                    if $0.weekNumber != $1.weekNumber { return $0.weekNumber < $1.weekNumber }
                    return $0.day < $1.day
                }
                guard let first = ordered.first else { return nil }
                let effectiveDate = first.plannedDate ?? now
                return Result(program: record, session: first, effectiveDate: effectiveDate)

            case .routineCyclic:
                // **AC2** — comportement original préservé. (Note : un programme
                // `.routineCyclic + .planned` n'est pas produit par les flows V1,
                // mais on garde la branche défensive.)
                let startOfDay = Calendar.current.startOfDay(for: now)
                let upcoming = pending
                    .compactMap { session -> (PersistedSession, Date)? in
                        guard let date = session.plannedDate, date >= startOfDay else { return nil }
                        return (session, date)
                    }
                    .sorted { $0.1 < $1.1 }
                guard let first = upcoming.first else { return nil }
                return Result(program: record, session: first.0, effectiveDate: first.1)
            }

        case .ondemand:
            // **AC2/AC3** — comportement inchangé pour routine cyclique +
            // ondemand pur (tri `(weekNumber, day)` asc).
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
            // Tie-break : heure (les `Date` portent déjà l'heure, donc ce check
            // est implicite ci-dessus) puis ordre alphabétique sport pour
            // déterminisme total.
            return lhs.program.sportCode < rhs.program.sportCode
        }
    }
}
