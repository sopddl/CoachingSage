// Coaching/Adapter/Rules/MedicalClearanceRule.swift
// Story 3.3a — règle 5 : garde-fou EU MDR Story 2.2 (PARQ-light). Si l'utilisateur
// a `requiresMedicalClearance == true`, on bannit toute zone d'intensité haute :
//
// - Daniels-I, Daniels-R, @5K-pace, @10K-pace, allure de race < HMP → Daniels-E
// - FTP-Z5, FTP-Z6, FTP-Z7, Sweet-Spot → FTP-Z2
// - RPE ≥ 7 → RPE 4-5
//
// Et on convertit `SessionType.interval` (HIIT) en `SessionType.endurance`. La
// session garde son nom et sa durée (l'utilisateur sait qu'il fait une version
// adaptée — c'est loggé). Mémoire `epic3_leon_legal_constraints`.
//
// Note : cette règle ne génère AUCUN texte (pas de mots bannis EU MDR à filtrer
// — l'algo ne fait que re-arranger des blocs templates pré-validés).
import Foundation
import TemplateModel

public struct MedicalClearanceRule: AdaptationRule {
    public let ruleType: AppliedRule.RuleType = .medicalClearance

    public init() {}

    public func apply(
        weeks: [AdaptedWeek],
        template: ProgramTemplate,
        sport: Sport,
        level: Level,
        sportProfile: AdapterSportProfile,
        coachingProfile: AdapterCoachingProfile
    ) -> RuleResult {
        guard coachingProfile.requiresMedicalClearance else {
            return RuleResult(weeks: weeks, appliedRules: [])
        }

        var appliedRules: [AppliedRule] = []

        let newWeeks = weeks.map { week in
            AdaptedWeek(
                weekNumber: week.weekNumber,
                theme: week.theme,
                goal: week.goal,
                sessions: week.sessions.map { session in
                    let downgradedType: SessionType = session.type == .interval ? .endurance : session.type
                    if downgradedType != session.type {
                        appliedRules.append(AppliedRule(
                            ruleType: ruleType,
                            weekNumber: week.weekNumber,
                            day: session.day,
                            originalExerciseName: session.name.canonical,
                            outcome: .downgraded,
                            detail: "Session « \(session.name.canonical) » : type interval → endurance (PARQ medical clearance)"
                        ))
                    }
                    return AdaptedSession(
                        day: session.day,
                        name: session.name,
                        durationMinutes: session.durationMinutes,
                        type: downgradedType,
                        warmup: session.warmup,
                        exercises: session.exercises.map { ex in
                            downgrade(exercise: ex, weekNumber: week.weekNumber, day: session.day, appliedRules: &appliedRules)
                        },
                        cooldown: session.cooldown
                    )
                }
            )
        }

        return RuleResult(weeks: newWeeks, appliedRules: appliedRules)
    }

    private func downgrade(
        exercise ex: AdaptedExercise,
        weekNumber: Int,
        day: Int,
        appliedRules: inout [AppliedRule]
    ) -> AdaptedExercise {
        guard let downgradedZone = downgradedZone(for: ex.targetZone), downgradedZone != ex.targetZone else {
            return ex
        }
        appliedRules.append(AppliedRule(
            ruleType: ruleType,
            weekNumber: weekNumber,
            day: day,
            originalExerciseName: ex.originalName,
            outcome: .downgraded,
            detail: "« \(ex.originalName) » : \(ex.targetZone ?? "?") → \(downgradedZone) (PARQ medical clearance)"
        ))
        return AdaptedExercise(
            name: ex.name,
            originalName: ex.originalName,
            sets: ex.sets,
            reps: ex.reps,
            duration: ex.duration,
            restSeconds: ex.restSeconds,
            dose: ex.dose,
            notes: ex.notes,
            targetZone: downgradedZone,
            volumeAxis: ex.volumeAxis,
            wasSubstituted: ex.wasSubstituted,
            substitutionReason: ex.substitutionReason
        )
    }

    /// Renvoie la zone "safe" équivalente, ou nil si la zone est déjà acceptable.
    private func downgradedZone(for zone: String?) -> String? {
        guard let zone else { return nil }

        // Daniels — Zones haute intensité.
        if zone == "Daniels-I" || zone == "Daniels-R" || zone == "Daniels-T" { return "Daniels-E" }
        // Allures de race rapides : @5K, @10K, @MP-... rapide.
        if zone.hasPrefix("@5K") || zone.hasPrefix("@10K") { return "Daniels-E" }

        // FTP / Coggan — bandes hautes.
        if zone == "FTP-Z4" || zone == "FTP-Z5" || zone == "FTP-Z6" || zone == "FTP-Z7" { return "FTP-Z2" }
        if zone == "Sweet-Spot" { return "FTP-Z2" }

        // RPE — toute valeur ≥ 7 (matchera "RPE 7-8", "RPE 8-9").
        if zone.hasPrefix("RPE") {
            for digit in ["7", "8", "9", "10"] where zone.contains(digit) {
                return "RPE 4-5"
            }
        }

        return zone
    }
}
