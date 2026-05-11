// Coaching/Adapter/ProgramAdapter.swift
// Story 3.3a — moteur d'adaptation algo deterministic. 100% local, sync, 0 token,
// 0 réseau. Applique 5 règles en cascade :
//
//   1. ConstraintSubstitution    — incompatible_constraints ↔ profile.constraints
//   2. EquipmentSubstitution     — required_equipment ↔ profile.equipment
//   3. VolumeModulation          — sessionsPerWeek ↔ profile.frequencyPerWeek
//   4. LevelPacing               — stub jusqu'à Story 3.1.5 (HK pre-fill VMA/FTP/CSS)
//   5. MedicalClearance          — downgrade Z1-Z2 si requiresMedicalClearance
//
// Si une règle ne sait pas patcher un exercice, elle lève `requiresAIAssist` et
// l'UI propose le fallback Léon Story 3.3b.
import Foundation
import TemplateModel

public struct ProgramAdapter: Sendable {
    public let rules: [AdaptationRule]
    public let durationResolver: ProgramDurationResolver

    /// Pipeline par défaut, ordre figé (cascade documentée).
    public static let defaultRules: [AdaptationRule] = [
        ConstraintSubstitutionRule(),
        EquipmentSubstitutionRule(),
        VolumeModulationRule(),
        LevelPacingRule(),
        MedicalClearanceRule()
    ]

    public init(
        rules: [AdaptationRule] = ProgramAdapter.defaultRules,
        durationResolver: ProgramDurationResolver = ProgramDurationResolver()
    ) {
        self.rules = rules
        self.durationResolver = durationResolver
    }

    public func adapt(
        template: ProgramTemplate,
        sportProfile: AdapterSportProfile,
        coachingProfile: AdapterCoachingProfile,
        now: Date = Date()
    ) -> AdaptedProgram {
        // Lift initial : passthrough TemplateExercise → AdaptedExercise.
        var weeks: [AdaptedWeek] = template.weeks.map { week in
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
                        exercises: session.exercises.map { AdaptedExercise.passthrough($0) },
                        cooldown: session.cooldown
                    )
                }
            )
        }

        var allAppliedRules: [AppliedRule] = []
        var requiresAI = false
        var aiReason: String?

        for rule in rules {
            let result = rule.apply(
                weeks: weeks,
                template: template,
                sport: template.sport,
                level: template.level,
                sportProfile: sportProfile,
                coachingProfile: coachingProfile
            )
            weeks = result.weeks
            allAppliedRules.append(contentsOf: result.appliedRules)
            if result.triggeredAIAssist {
                requiresAI = true
                aiReason = aiReason ?? result.aiAssistReason
            }
        }

        // Story sœur — resize selon mode + targetDate.
        let (targetWeeks, finalTargetDate) = durationResolver.resolve(
            durationMode: sportProfile.durationMode,
            targetDate: sportProfile.targetDate,
            goal: sportProfile.goal,
            sport: template.sport,
            level: template.level,
            templateDurationWeeks: template.durationWeeks,
            now: now
        )
        weeks = durationResolver.resize(weeks: weeks, to: targetWeeks)

        return AdaptedProgram(
            templateId: template.id,
            sport: template.sport,
            level: template.level,
            appliedAt: now,
            weeks: weeks,
            appliedRules: allAppliedRules,
            requiresAIAssist: requiresAI,
            aiAssistReason: aiReason,
            durationMode: sportProfile.durationMode,
            targetDate: finalTargetDate
        )
    }
}
