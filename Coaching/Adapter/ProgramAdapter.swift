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
    /// Densité en 4ᵉ position (chantier densité B) : APRÈS VolumeModulation (le cap G4
    /// +20 % se calcule sur les séances restantes — pas de cumul de deux hausses),
    /// AVANT LevelPacing/MedicalClearance.
    public static let defaultRules: [AdaptationRule] = [
        ConstraintSubstitutionRule(),
        EquipmentSubstitutionRule(),
        VolumeModulationRule(),
        DensityRule(),
        LevelPacingRule(),
        MedicalClearanceRule()
    ]

    /// Règles applicables à l'échelle d'UNE séance (indoor/outdoor vélo L1, 2026-06-11) :
    /// uniquement les règles PAR-EXERCICE. On exclut volontairement `VolumeModulation`
    /// (supprime des séances entières — sans objet sur une séance isolée) et
    /// `LevelPacing` (resize/HK programme). Cf `adaptSession(...)`.
    public static let sessionScopedRules: [AdaptationRule] = [
        ConstraintSubstitutionRule(),
        EquipmentSubstitutionRule(),
        MedicalClearanceRule()
    ]

    public init(
        rules: [AdaptationRule] = ProgramAdapter.defaultRules,
        durationResolver: ProgramDurationResolver = ProgramDurationResolver()
    ) {
        self.rules = rules
        self.durationResolver = durationResolver
    }

    /// Adapte le contenu d'UNE variante de séance (indoor/outdoor vélo) en rejouant les
    /// règles par-exercice (constraint/equipment/medical) — la variante ALTERNATE hérite
    /// ainsi des substitutions, exactement comme la séance native (fin de la « LIMITE V1
    /// passthrough »). Construit un mini-template synthétique 1 semaine / 1 séance pour que
    /// `findExercise(weekNumber:day:name:)` résolve les exercices DE LA VARIANTE (et non
    /// ceux de la séance racine). Pur, synchrone, 100% local.
    public func adaptSession(
        variant: SessionVariant,
        day: Int,
        type: SessionType,
        weekNumber: Int,
        sport: Sport,
        level: Level,
        templateId: String,
        sportProfile: AdapterSportProfile,
        coachingProfile: AdapterCoachingProfile
    ) -> AdaptedSession {
        let empty: LocalizedText = ""
        // Lift initial (passthrough) — état de départ identique à `adapt(...)`.
        let lifted = AdaptedSession(
            day: day,
            name: variant.name,
            durationMinutes: variant.durationMinutes,
            type: type,
            warmup: variant.warmup,
            exercises: variant.exercises.map { AdaptedExercise.passthrough($0, sport: sport) },
            cooldown: variant.cooldown
        )
        // Template synthétique : la séance racine = la variante → findExercise la trouve.
        let synthTemplate = ProgramTemplate(
            id: templateId,
            schemaVersion: 2,
            sport: sport,
            level: level,
            name: variant.name,
            durationWeeks: 1,
            sessionsPerWeek: 1,
            defaultObjective: empty,
            assumedProfile: empty,
            summary: empty,
            weeks: [TemplateWeek(
                weekNumber: weekNumber,
                theme: empty,
                goal: empty,
                sessions: [TemplateSession(
                    day: day,
                    name: variant.name,
                    durationMinutes: variant.durationMinutes,
                    type: type,
                    warmup: variant.warmup,
                    exercises: variant.exercises,
                    cooldown: variant.cooldown
                )]
            )],
            safetyNotes: empty,
            progressionLogic: empty
        )
        var weeks: [AdaptedWeek] = [AdaptedWeek(weekNumber: weekNumber, theme: empty, goal: empty, sessions: [lifted])]
        for rule in Self.sessionScopedRules {
            weeks = rule.apply(
                weeks: weeks,
                template: synthTemplate,
                sport: sport,
                level: level,
                sportProfile: sportProfile,
                coachingProfile: coachingProfile
            ).weeks
        }
        return weeks.first?.sessions.first ?? lifted
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
                        exercises: session.exercises.map { AdaptedExercise.passthrough($0, sport: template.sport) },
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
