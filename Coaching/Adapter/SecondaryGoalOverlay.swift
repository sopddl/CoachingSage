// Coaching/Adapter/SecondaryGoalOverlay.swift
// Story 3.13 Phase C (Epic 3) — applique les goals secondaires sur le programme déjà
// adapté par `ProgramAdapter`. Le primary porte le template structurel, les secondary
// modulent les séances :
//
//   • dedicatedSession : remplace 1 session/sem (la plus "droppable" cf VolumeModulationRule)
//                        par une séance thématique secondary, en rotation entre secondary goals.
//                        Skip si frequency < 2 ou si la semaine est de taper/peak (préserve la cadence).
//   • mixInSession    : prepend 1 drill secondary en début de chaque session (ratio 10-15% volume,
//                       min 5min / max 15min). Rotation entre secondary goals.
//   • hybrid          : dedicatedSession si frequency ≥ 3, sinon mixInSession.
//   • notApplicable   : noop (strength/triathlon — secondary devrait être bloqué upstream).
//
// AC17 garde-fou EU MDR : si TOUS les goals (primary + secondary) sont "performance-like",
// l'overlay cap secondary à 1 seul (évite cumul blocs intensifs). Les goals "wellness/initiation/
// reprise/decouverte" sont par construction exclusifs (cf GoalCompatibilityMatrix.exclusiveGoals)
// donc ce cas se produit ssi toutes les sélections sont des goals de progression.
//
// Catalogue drills : `SecondaryDrillsCatalog` (statique, par sport × secondary goal). Source
// doctrine validée par `template-quality-reviewer` 2026-05-19.
//
// Output : `[AdaptedWeek]` modifié + `[OverlayAppliedRule]` audit log (1 entrée par
// session touchée). Aucun template externe chargé en V1 — drills synthétiques inline.
import Foundation
import TemplateModel

/// Configuration tunable de l'overlay. Constantes par défaut alignées doctrine
/// (cf reviewer patch AC15 2026-05-19).
public struct OverlayConfig: Sendable, Equatable {
    /// Part du volume de la session allouée aux drills secondary (mixInSession).
    public let mixInRatio: Double
    /// Plancher minutes drills (mixInSession).
    public let mixInMinMinutes: Int
    /// Plafond minutes drills (mixInSession).
    public let mixInMaxMinutes: Int
    /// Max secondary goals appliqués quand primary + tous secondary sont "performance-like"
    /// (garde-fou EU MDR AC17).
    public let performanceSecondaryCap: Int

    public init(
        mixInRatio: Double = 0.15,
        mixInMinMinutes: Int = 5,
        mixInMaxMinutes: Int = 15,
        performanceSecondaryCap: Int = 1
    ) {
        self.mixInRatio = mixInRatio
        self.mixInMinMinutes = mixInMinMinutes
        self.mixInMaxMinutes = mixInMaxMinutes
        self.performanceSecondaryCap = performanceSecondaryCap
    }
}

/// Trace d'une modification d'overlay. Audit + UI optionnelle pour expliquer pourquoi
/// une session a un nom "Technique" alors que le template primary est "Endurance".
public struct OverlayAppliedRule: Equatable, Sendable {
    public let weekNumber: Int
    public let day: Int
    public let originalSessionName: String
    public let secondaryGoal: String
    public let strategy: OverlayStrategy

    public init(
        weekNumber: Int,
        day: Int,
        originalSessionName: String,
        secondaryGoal: String,
        strategy: OverlayStrategy
    ) {
        self.weekNumber = weekNumber
        self.day = day
        self.originalSessionName = originalSessionName
        self.secondaryGoal = secondaryGoal
        self.strategy = strategy
    }
}

/// Résultat de l'overlay : nouvelles semaines + log des modifications.
public struct OverlayResult: Equatable, Sendable {
    public let weeks: [AdaptedWeek]
    public let appliedOverlays: [OverlayAppliedRule]

    public init(weeks: [AdaptedWeek], appliedOverlays: [OverlayAppliedRule]) {
        self.weeks = weeks
        self.appliedOverlays = appliedOverlays
    }
}

public enum SecondaryGoalOverlay {

    // MARK: - Entry point

    /// Applique l'overlay secondary sur les semaines déjà adaptées. Noop si :
    ///   • `secondary` est vide
    ///   • `strategy == .notApplicable`
    ///   • `frequency < 2` en `.dedicatedSession` (pas la place pour une séance dédiée)
    public static func apply(
        weeks: [AdaptedWeek],
        template: ProgramTemplate,
        primary: String,
        secondary: [String],
        frequency: Int,
        sportCode: String,
        strategy: OverlayStrategy,
        config: OverlayConfig = OverlayConfig()
    ) -> OverlayResult {
        guard !secondary.isEmpty else {
            return OverlayResult(weeks: weeks, appliedOverlays: [])
        }

        // AC17 garde-fou EU MDR : cap secondary si primary + tous secondary performance-like.
        let cappedSecondary = applyPerformanceCap(
            primary: primary,
            secondary: secondary,
            sportCode: sportCode,
            cap: config.performanceSecondaryCap
        )

        switch strategy {
        case .notApplicable:
            return OverlayResult(weeks: weeks, appliedOverlays: [])
        case .dedicatedSession:
            return applyDedicated(
                weeks: weeks,
                secondary: cappedSecondary,
                frequency: frequency,
                sportCode: sportCode
            )
        case .mixInSession:
            return applyMixIn(
                weeks: weeks,
                secondary: cappedSecondary,
                sportCode: sportCode,
                config: config
            )
        case .hybrid:
            if frequency >= 3 {
                return applyDedicated(
                    weeks: weeks,
                    secondary: cappedSecondary,
                    frequency: frequency,
                    sportCode: sportCode
                )
            } else {
                return applyMixIn(
                    weeks: weeks,
                    secondary: cappedSecondary,
                    sportCode: sportCode,
                    config: config
                )
            }
        }
    }

    // MARK: - dedicatedSession

    /// Remplace 1 session/sem (la plus "droppable" cf doctrine VolumeModulationRule)
    /// par une séance thématique secondary. Si N secondary > 1, rotation circulaire
    /// entre secondary goals d'une semaine à l'autre.
    private static func applyDedicated(
        weeks: [AdaptedWeek],
        secondary: [String],
        frequency: Int,
        sportCode: String
    ) -> OverlayResult {
        guard frequency >= 2, !secondary.isEmpty else {
            return OverlayResult(weeks: weeks, appliedOverlays: [])
        }

        var newWeeks: [AdaptedWeek] = []
        var applied: [OverlayAppliedRule] = []

        for (weekIdx, week) in weeks.enumerated() {
            // Rotation : secondary[weekIdx % secondary.count]
            let secondaryGoal = secondary[weekIdx % secondary.count]
            // Cherche la session active la plus droppable : other > mobility > technique > strength > mixed > endurance > interval.
            // Préserve les semaines de taper (≤ 2 sessions actives — pas la place).
            let activeSessions = week.sessions.filter { $0.type != .rest }
            guard activeSessions.count >= 2,
                  let targetIdx = sessionIndexForReplacement(in: week.sessions) else {
                newWeeks.append(week)
                continue
            }

            let originalSession = week.sessions[targetIdx]
            let replacement = buildDedicatedSession(
                day: originalSession.day,
                durationMinutes: originalSession.durationMinutes,
                secondaryGoal: secondaryGoal,
                sportCode: sportCode
            )

            var newSessions = week.sessions
            newSessions[targetIdx] = replacement
            newWeeks.append(AdaptedWeek(
                weekNumber: week.weekNumber,
                theme: week.theme,
                goal: week.goal,
                sessions: newSessions
            ))
            applied.append(OverlayAppliedRule(
                weekNumber: week.weekNumber,
                day: originalSession.day,
                originalSessionName: originalSession.name.canonical,
                secondaryGoal: secondaryGoal,
                strategy: .dedicatedSession
            ))
        }

        return OverlayResult(weeks: newWeeks, appliedOverlays: applied)
    }

    /// Index de la session à remplacer selon doctrine VolumeModulationRule (du moins prioritaire
    /// au plus prioritaire). Returns nil si aucune session non-rest n'existe.
    private static func sessionIndexForReplacement(in sessions: [AdaptedSession]) -> Int? {
        let dropPriority: [SessionType] = [
            .other, .mobility, .technique, .strength, .mixed, .endurance, .interval
        ]
        for type in dropPriority {
            if let idx = sessions.firstIndex(where: { $0.type == type }) {
                return idx
            }
        }
        return nil
    }

    /// Construit une session synthétique dédiée au secondary goal. Drills depuis le catalogue.
    private static func buildDedicatedSession(
        day: Int,
        durationMinutes: Int,
        secondaryGoal: String,
        sportCode: String
    ) -> AdaptedSession {
        let drills = SecondaryDrillsCatalog.drills(forGoal: secondaryGoal, sportCode: sportCode)
        let exercises = drills.map { drill in
            // Catalogue drills FR-only (contenu synthétique) → wrap LocalizedText(fr:),
            // fallback FR jusqu'à traduction éventuelle du catalogue (B2).
            AdaptedExercise(
                name: LocalizedText(fr: drill.name),
                originalName: drill.name,
                sets: drill.sets,
                reps: drill.reps,
                duration: drill.duration,
                restSeconds: drill.restSeconds,
                notes: drill.notes.map { LocalizedText(fr: $0) },
                targetZone: drill.targetZone,
                volumeAxis: nil,
                wasSubstituted: false,
                substitutionReason: nil
            )
        }
        return AdaptedSession(
            day: day,
            name: LocalizedText(fr: SecondaryDrillsCatalog.sessionName(forGoal: secondaryGoal, sportCode: sportCode)),
            durationMinutes: durationMinutes,
            type: SecondaryDrillsCatalog.sessionType(forGoal: secondaryGoal, sportCode: sportCode),
            warmup: drills.first?.warmupHint.map { LocalizedText(fr: $0) },
            exercises: exercises,
            cooldown: nil
        )
    }

    // MARK: - mixInSession

    /// Prepend 1 drill secondary en début de chaque session active. Durée drill = ratio config
    /// du volume session, bornée min/max. Rotation entre secondary goals d'une session à l'autre.
    private static func applyMixIn(
        weeks: [AdaptedWeek],
        secondary: [String],
        sportCode: String,
        config: OverlayConfig
    ) -> OverlayResult {
        guard !secondary.isEmpty else {
            return OverlayResult(weeks: weeks, appliedOverlays: [])
        }

        var newWeeks: [AdaptedWeek] = []
        var applied: [OverlayAppliedRule] = []
        var sessionCounter = 0  // rotation index global (continue d'une semaine à l'autre)

        for week in weeks {
            var newSessions: [AdaptedSession] = []
            for session in week.sessions {
                guard session.type != .rest else {
                    newSessions.append(session)
                    continue
                }
                let secondaryGoal = secondary[sessionCounter % secondary.count]
                sessionCounter += 1

                let drillMinutes = clampedDrillDuration(
                    sessionDurationMinutes: session.durationMinutes,
                    config: config
                )
                let drill = SecondaryDrillsCatalog.mixInDrill(
                    forGoal: secondaryGoal,
                    sportCode: sportCode,
                    durationMinutes: drillMinutes
                )
                let drillExercise = AdaptedExercise(
                    name: LocalizedText(fr: drill.name),
                    originalName: drill.name,
                    sets: drill.sets,
                    reps: drill.reps,
                    duration: drill.duration,
                    restSeconds: drill.restSeconds,
                    notes: drill.notes.map { LocalizedText(fr: $0) },
                    targetZone: drill.targetZone,
                    volumeAxis: nil,
                    wasSubstituted: false,
                    substitutionReason: nil
                )
                let augmented = AdaptedSession(
                    day: session.day,
                    name: session.name,
                    durationMinutes: session.durationMinutes,
                    type: session.type,
                    warmup: session.warmup,
                    exercises: [drillExercise] + session.exercises,
                    cooldown: session.cooldown,
                    warmupMinutes: session.warmupMinutes,
                    cooldownMinutes: session.cooldownMinutes
                )
                newSessions.append(augmented)
                applied.append(OverlayAppliedRule(
                    weekNumber: week.weekNumber,
                    day: session.day,
                    originalSessionName: session.name.canonical,
                    secondaryGoal: secondaryGoal,
                    strategy: .mixInSession
                ))
            }
            newWeeks.append(AdaptedWeek(
                weekNumber: week.weekNumber,
                theme: week.theme,
                goal: week.goal,
                sessions: newSessions
            ))
        }

        return OverlayResult(weeks: newWeeks, appliedOverlays: applied)
    }

    /// Durée drill mixIn = `mixInRatio` du volume session, bornée par min/max.
    private static func clampedDrillDuration(
        sessionDurationMinutes: Int,
        config: OverlayConfig
    ) -> Int {
        let raw = Double(sessionDurationMinutes) * config.mixInRatio
        let rounded = Int(raw.rounded())
        return max(config.mixInMinMinutes, min(config.mixInMaxMinutes, rounded))
    }

    // MARK: - AC17 performance cap

    /// AC17 — garde-fou EU MDR : si primary + tous secondary sont performance-like
    /// (goals de progression non-exclusifs), cap la liste secondary pour éviter le
    /// cumul de blocs intensifs. Sinon, retourne secondary intact.
    private static func applyPerformanceCap(
        primary: String,
        secondary: [String],
        sportCode: String,
        cap: Int
    ) -> [String] {
        let allGoals = [primary] + secondary
        let exclusiveSet = GoalCompatibilityMatrix.exclusiveGoals(for: sportCode)
        let allPerformance = allGoals.allSatisfy { !exclusiveSet.contains($0) }
        guard allPerformance, secondary.count > cap else {
            return secondary
        }
        return Array(secondary.prefix(cap))
    }
}
