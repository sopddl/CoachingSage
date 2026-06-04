// Coaching/AI/PatchApplier.swift
// Story 3.3b — applique un AdaptationPatch sur un AdaptedProgram et retourne
// un AppliedAdaptedProgram (programme muté + notes Léon overlay).
//
// Idempotence : appliquer 2x le même patch produit le même résultat (les
// substitutions matchent sur originalName, pas sur name post-substitution).
import Foundation
import TemplateModel

public enum PatchApplier {

    /// Applique le patch sur le programme. Si `patch` est nil ou vide, retourne
    /// `AppliedAdaptedProgram(program: program, leonNotes: nil)` — le caller
    /// peut tester `applied.leonNotes != nil` pour décider d'afficher la section.
    public static func apply(_ patch: AdaptationPatch?, to program: AdaptedProgram) -> AppliedAdaptedProgram {
        guard let patch, patch.hasContent else {
            return AppliedAdaptedProgram(program: program, leonNotes: nil)
        }

        // 1. Substitutions d'exercices : index par (week, day, originalName) pour
        //    lookup O(1) au lieu d'itérer la liste à chaque exercice.
        let subIndex: [SubstitutionKey: AdaptationPatch.ExerciseSubstitution] = Dictionary(
            uniqueKeysWithValues: (patch.exerciseSubstitutions ?? []).compactMap { sub in
                let key = SubstitutionKey(week: sub.weekNumber, day: sub.day, originalName: sub.originalExerciseName)
                return (key, sub)
            }
        )

        let mutatedWeeks = program.weeks.map { week in
            let mutatedSessions = week.sessions.map { session in
                let mutatedExercises = session.exercises.map { ex -> AdaptedExercise in
                    let key = SubstitutionKey(week: week.weekNumber, day: session.day, originalName: ex.originalName)
                    guard let sub = subIndex[key] else { return ex }
                    return AdaptedExercise(
                        // Patch IA Léon = contenu mono-langue généré à la volée → FR.
                        // (Re-traduction à un changement de langue = story ultérieure.)
                        name: LocalizedText(fr: sub.replacementExerciseName),
                        originalName: ex.originalName,
                        sets: ex.sets,
                        reps: ex.reps,
                        duration: ex.duration,
                        restSeconds: ex.restSeconds,
                        notes: ex.notes,
                        targetZone: ex.targetZone,
                        volumeAxis: ex.volumeAxis,
                        wasSubstituted: true,
                        substitutionReason: "leon-ia: \(sub.reason)"
                    )
                }
                return AdaptedSession(
                    day: session.day,
                    name: session.name,
                    durationMinutes: session.durationMinutes,
                    type: session.type,
                    warmup: session.warmup,
                    exercises: mutatedExercises,
                    cooldown: session.cooldown
                )
            }
            return AdaptedWeek(
                weekNumber: week.weekNumber,
                theme: week.theme,
                goal: week.goal,
                sessions: mutatedSessions
            )
        }

        let mutatedProgram = AdaptedProgram(
            templateId: program.templateId,
            sport: program.sport,
            level: program.level,
            appliedAt: program.appliedAt,
            weeks: mutatedWeeks,
            appliedRules: program.appliedRules,
            requiresAIAssist: program.requiresAIAssist,
            aiAssistReason: program.aiAssistReason
        )

        // 2. Notes Léon : volume + pacing concaténés en bullet list
        //    "W{n} : {adjustment} ({reason})".
        var adjustmentNotes: [String] = []
        for vol in patch.volumeAdjustments ?? [] {
            adjustmentNotes.append(formatVolumeAdjustment(vol))
        }
        for pace in patch.progressionPacing ?? [] {
            adjustmentNotes.append(formatProgressionPacing(pace))
        }

        let notes = LeonAppliedNotes(
            personalizationNote: patch.personalizationNote?.isEmpty == false ? patch.personalizationNote : nil,
            safetyNotes: patch.safetyNotes ?? [],
            adjustmentNotes: adjustmentNotes
        )

        return AppliedAdaptedProgram(program: mutatedProgram, leonNotes: notes)
    }

    // MARK: - Helpers

    private struct SubstitutionKey: Hashable {
        let week: Int
        let day: Int
        let originalName: String
    }

    private static func formatVolumeAdjustment(_ vol: AdaptationPatch.VolumeAdjustment) -> String {
        var parts: [String] = ["W\(vol.weekNumber)"]
        if let day = vol.day { parts.append("J\(day)") }
        if let exo = vol.exerciseName, !exo.isEmpty { parts.append(exo) }
        let scope = parts.joined(separator: " ")
        return "\(scope) : \(vol.adjustment) (\(vol.reason))"
    }

    private static func formatProgressionPacing(_ pace: AdaptationPatch.ProgressionPacing) -> String {
        return "W\(pace.weekNumber) : \(pace.adjustment) (\(pace.reason))"
    }
}
