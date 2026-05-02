// Coaching/Adapter/Rules/VolumeModulationRule.swift
// Story 3.3a — règle 3 : si `profile.frequencyPerWeek < template.sessionsPerWeek`
// pour la cadence régulière, supprime les sessions les moins prioritaires de
// chaque semaine en suivant un ordre doctrine sport-agnostique :
//   other > mobility > technique > strength > mixed > endurance > interval
// (les sessions clés intervals/endurance protégées en dernier). Les semaines
// peak/taper qui ont +1 session vs cadence sont laissées intactes (tolérance
// validator).
//
// Si profile.frequencyPerWeek > template.sessionsPerWeek, on n'invente pas de
// session : on log juste `noChange` (l'utilisateur peut ajouter une sortie
// libre dans les jours vides).
import Foundation
import TemplateModel

public struct VolumeModulationRule: AdaptationRule {
    public let ruleType: AppliedRule.RuleType = .volumeModulation

    /// Priorité de suppression (du moins important au plus important).
    /// Les sessions en TÊTE de la liste sont supprimées EN PREMIER.
    private static let dropPriority: [SessionType] = [
        .other, .mobility, .technique, .strength, .mixed, .endurance, .interval
    ]

    public init() {}

    public func apply(
        weeks: [AdaptedWeek],
        template: ProgramTemplate,
        sport: Sport,
        level: Level,
        sportProfile: AdapterSportProfile,
        coachingProfile: AdapterCoachingProfile
    ) -> RuleResult {
        let target = sportProfile.frequencyPerWeek
        let declared = template.sessionsPerWeek

        // Cadence ≥ template : on ne fait rien (pas d'invention).
        guard target < declared else {
            return RuleResult(weeks: weeks, appliedRules: [])
        }

        let toDrop = declared - target  // nombre de sessions à supprimer en cadence régulière
        var appliedRules: [AppliedRule] = []

        let newWeeks = weeks.map { week -> AdaptedWeek in
            // Sessions actives (rest exclu).
            let active = week.sessions.filter { $0.type != .rest }

            // Si la semaine a déjà ≤ target sessions actives (cas d'une semaine
            // taper/deload qui descend en dessous), on ne touche pas.
            guard active.count > target else { return week }

            // Détermine combien retirer pour cette semaine spécifique.
            // Borne : ne pas retirer plus que `(active.count - target)` (cap au target),
            // mais aussi pas plus que `toDrop + 1` (tolérance peak +1 session).
            let weekDrop = min(active.count - target, toDrop + 1)

            // Sélection : trier les sessions actives par dropPriority puis par day desc.
            let priorityIndex: (SessionType) -> Int = { type in
                Self.dropPriority.firstIndex(of: type) ?? 0
            }
            let droppable = active.sorted { lhs, rhs in
                let lp = priorityIndex(lhs.type), rp = priorityIndex(rhs.type)
                if lp != rp { return lp < rp }
                return lhs.day > rhs.day
            }
            let toRemoveIds = Set(droppable.prefix(weekDrop).map { "\($0.day)-\($0.name)" })

            let kept = week.sessions.filter { session in
                !toRemoveIds.contains("\(session.day)-\(session.name)")
            }

            for s in week.sessions where toRemoveIds.contains("\(s.day)-\(s.name)") {
                appliedRules.append(AppliedRule(
                    ruleType: ruleType,
                    weekNumber: week.weekNumber,
                    day: s.day,
                    originalExerciseName: s.name,
                    outcome: .removed,
                    detail: "Session « \(s.name) » (\(s.type.rawValue)) supprimée — cadence cible \(target)/sem (template \(declared)/sem)"
                ))
            }

            return AdaptedWeek(
                weekNumber: week.weekNumber,
                theme: week.theme,
                goal: week.goal,
                sessions: kept
            )
        }

        return RuleResult(weeks: newWeeks, appliedRules: appliedRules)
    }
}
