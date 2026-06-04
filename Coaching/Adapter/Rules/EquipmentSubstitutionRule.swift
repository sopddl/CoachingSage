// Coaching/Adapter/Rules/EquipmentSubstitutionRule.swift
// Story 3.3a — règle 2 : remplace tout exercice dont `requiredEquipment` n'est
// pas couvert par `profile.equipment` par sa première `alternatives[]`. Si pas
// d'alternative, lève `requiresAIAssist` mais conserve l'exercice (l'utilisateur
// jugera s'il le saute ou demande à Léon de retravailler).
import Foundation
import TemplateModel

public struct EquipmentSubstitutionRule: AdaptationRule {
    public let ruleType: AppliedRule.RuleType = .equipmentSubstitution

    public init() {}

    public func apply(
        weeks: [AdaptedWeek],
        template: ProgramTemplate,
        sport: Sport,
        level: Level,
        sportProfile: AdapterSportProfile,
        coachingProfile: AdapterCoachingProfile
    ) -> RuleResult {
        let availableEquipment = Set(sportProfile.equipment)
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
                                availableEquipment: availableEquipment,
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
        availableEquipment: Set<String>,
        appliedRules: inout [AppliedRule],
        triggeredAI: inout Bool,
        aiReason: inout String?
    ) -> AdaptedExercise {
        // Si l'exercice a déjà été remplacé par la règle precedente (constraint),
        // on ne re-touche pas — l'alternative est supposée compatible côté équipement.
        guard !ex.wasSubstituted else { return ex }
        guard let templateEx = template.findExercise(
            weekNumber: weekNumber, day: day, name: ex.originalName
        ) else { return ex }

        let missing = Set(templateEx.requiredEquipment).subtracting(availableEquipment)
        guard !missing.isEmpty else { return ex }

        let missingLabel = missing.sorted().joined(separator: ",")

        if let alternativeName = templateEx.alternatives.first {
            appliedRules.append(AppliedRule(
                ruleType: ruleType,
                weekNumber: weekNumber,
                day: day,
                originalExerciseName: ex.originalName,
                outcome: .substituted,
                detail: "« \(ex.originalName) » → « \(alternativeName.canonical) » (équipement absent: \(missingLabel))"
            ))
            // Bug #8 — si l'alternative embarque sa propre durée dans son nom,
            // elle fait foi (sinon la pastille/minuteur gardent celle du parent).
            // La durée est extraite du nom canonique FR (chiffres language-agnostic).
            return AdaptedExercise(
                name: alternativeName,
                originalName: ex.originalName,
                sets: ex.sets,
                reps: ex.reps,
                duration: AlternativeName.embeddedDuration(in: alternativeName.canonical) ?? ex.duration,
                restSeconds: ex.restSeconds,
                notes: ex.notes,
                targetZone: ex.targetZone,
                volumeAxis: ex.volumeAxis,
                wasSubstituted: true,
                substitutionReason: "equipment:\(missingLabel)"
            )
        } else {
            triggeredAI = true
            if aiReason == nil { aiReason = "Aucune alternative pour l'équipement manquant « \(missingLabel) »" }
            appliedRules.append(AppliedRule(
                ruleType: ruleType,
                weekNumber: weekNumber,
                day: day,
                originalExerciseName: ex.originalName,
                outcome: .requiresAI,
                detail: "« \(ex.originalName) » nécessite \(missingLabel) — pas d'alternative"
            ))
            return ex
        }
    }
}
