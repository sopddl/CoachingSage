// Coaching/Adapter/Rules/ConstraintSubstitutionRule.swift
// Story 3.3a — règle 1 : remplace tout exercice dont `incompatibleConstraints`
// matche une contrainte du profil par sa première `alternatives[]`. Si aucune
// alternative compatible n'existe, l'exercice est conservé en l'état et on
// lève `requiresAIAssist` pour proposer un fallback Léon Story 3.3b.
import Foundation
import TemplateModel

public struct ConstraintSubstitutionRule: AdaptationRule {
    public let ruleType: AppliedRule.RuleType = .constraintSubstitution

    public init() {}

    public func apply(
        weeks: [AdaptedWeek],
        template: ProgramTemplate,
        sport: Sport,
        level: Level,
        sportProfile: AdapterSportProfile,
        coachingProfile: AdapterCoachingProfile
    ) -> RuleResult {
        // ["none"] et [] traités identiquement : pas de contrainte active.
        let activeConstraints = Set(sportProfile.constraints.filter { $0 != "none" })
        guard !activeConstraints.isEmpty else {
            return RuleResult(weeks: weeks, appliedRules: [])
        }

        var appliedRules: [AppliedRule] = []
        var triggeredAI = false
        var aiReason: String?

        let newWeeks = weeks.map { week in
            AdaptedWeek(
                weekNumber: week.weekNumber,
                theme: week.theme,
                goal: week.goal,
                sessions: week.sessions.map { session in
                    AdaptedSession(
                        day: session.day,
                        name: session.name,
                        durationMinutes: session.durationMinutes,
                        type: session.type,
                        warmup: session.warmup,
                        exercises: session.exercises.map { ex in
                            adapt(
                                exercise: ex,
                                weekNumber: week.weekNumber,
                                day: session.day,
                                template: template,
                                activeConstraints: activeConstraints,
                                appliedRules: &appliedRules,
                                triggeredAI: &triggeredAI,
                                aiReason: &aiReason
                            )
                        },
                        cooldown: session.cooldown
                    )
                }
            )
        }

        return RuleResult(
            weeks: newWeeks,
            appliedRules: appliedRules,
            triggeredAIAssist: triggeredAI,
            aiAssistReason: aiReason
        )
    }

    private func adapt(
        exercise ex: AdaptedExercise,
        weekNumber: Int,
        day: Int,
        template: ProgramTemplate,
        activeConstraints: Set<String>,
        appliedRules: inout [AppliedRule],
        triggeredAI: inout Bool,
        aiReason: inout String?
    ) -> AdaptedExercise {
        guard let templateEx = template.findExercise(
            weekNumber: weekNumber, day: day, name: ex.originalName
        ) else { return ex }

        let blockers = activeConstraints.intersection(Set(templateEx.incompatibleConstraints))
        guard !blockers.isEmpty else { return ex }

        let blockerLabel = blockers.sorted().joined(separator: ",")

        if let alternativeName = templateEx.alternatives.first {
            appliedRules.append(AppliedRule(
                ruleType: ruleType,
                weekNumber: weekNumber,
                day: day,
                originalExerciseName: ex.originalName,
                outcome: .substituted,
                detail: "« \(ex.originalName) » → « \(alternativeName.canonical) » (\(blockerLabel))"
            ))
            // Bug #8 — la durée embarquée dans le nom de l'alternative fait foi
            // (extraite du nom canonique FR, chiffres language-agnostic).
            return AdaptedExercise(
                name: alternativeName,
                originalName: ex.originalName,
                sets: ex.sets,
                reps: ex.reps,
                duration: AlternativeName.embeddedDuration(in: alternativeName.canonical) ?? ex.duration,
                restSeconds: ex.restSeconds,
                dose: ex.dose,
                notes: ex.notes,
                targetZone: ex.targetZone,
                volumeAxis: ex.volumeAxis,
                wasSubstituted: true,
                substitutionReason: "constraint:\(blockerLabel)"
            )
        } else {
            triggeredAI = true
            if aiReason == nil { aiReason = "Aucune alternative pour la contrainte « \(blockerLabel) »" }
            appliedRules.append(AppliedRule(
                ruleType: ruleType,
                weekNumber: weekNumber,
                day: day,
                originalExerciseName: ex.originalName,
                outcome: .requiresAI,
                detail: "« \(ex.originalName) » incompatible (\(blockerLabel)) — pas d'alternative"
            ))
            return ex
        }
    }
}
