// Coaching/Dashboard/NextSessionResolver.swift
// Story 3.8 — résout « la prochaine séance » à partir d'un (ou plusieurs)
// `AdaptedProgramRecord`. 100% sync, déterministe, 0 réseau.
//
// **Logique per-program** (`nextSession(for:now:)`) :
//   1. Filtrer les sessions non complétées (absentes de `completionState`).
//   2. En `mode = .planned` : ne garder que les sessions ayant une `plannedDate`
//      ≥ début du jour `now` (les jours antérieurs sont passés/manqués). Trier
//      par `plannedDate` ascendant. Retourner la première.
//   3. En `mode = .ondemand` : trier par `(weekNumber, day)` ascendant.
//      Retourner la première non complétée. Date effective = aujourd'hui (`now`).
//
// **Logique multi-programmes** (`nextSession(across:now:)`) :
//   1. Calculer la prochaine session de chaque programme (étape per-program).
//   2. Retenir celle dont la `effectiveDate` est la plus proche dans le futur (ou aujourd'hui).
//   3. Tie-break : heure la plus proche, sinon ordre alphabétique `sportCode`.
//
// **Pourquoi `effectiveDate` plutôt que `plannedDate` directement** : en
// `.ondemand`, la session n'a pas de date, mais le user peut quand même la
// démarrer aujourd'hui. On normalise donc à `now` pour pouvoir comparer
// uniformément planned vs ondemand dans le tri multi-prog.
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
        let completedIds = Set(record.completionState.sessionRecords.keys)
        let pending = record.sessions.filter { !completedIds.contains($0.id) }
        guard !pending.isEmpty else { return nil }

        switch record.mode {
        case .planned:
            let startOfDay = Calendar.current.startOfDay(for: now)
            let upcoming = pending
                .compactMap { session -> (PersistedSession, Date)? in
                    guard let date = session.plannedDate, date >= startOfDay else { return nil }
                    return (session, date)
                }
                .sorted { $0.1 < $1.1 }
            guard let first = upcoming.first else { return nil }
            return Result(program: record, session: first.0, effectiveDate: first.1)

        case .ondemand:
            let ordered = pending.sorted {
                $0.weekNumber != $1.weekNumber
                    ? $0.weekNumber < $1.weekNumber
                    : $0.day < $1.day
            }
            guard let first = ordered.first else { return nil }
            return Result(program: record, session: first, effectiveDate: now)
        }
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
