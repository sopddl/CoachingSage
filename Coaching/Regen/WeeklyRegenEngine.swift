// Coaching/Regen/WeeklyRegenEngine.swift
// Story 3.4 Phase A.4 — chef d'orchestre du pipeline regen hebdo. Compose A.1
// (ExecutionScore / WorkoutMatcher), A.2 (WeeklyExecutionAnalyzer), A.3
// (PauseDetector + RegressionRule) en une décision unique applicable à la
// semaine S+1.
//
// Pur Swift, 0 dépendance HK live (les workouts arrivent en `WorkoutSnapshot`
// déjà projetés par le HealthKitService). Déterministe, testable.
//
// Le moteur produit une `WeeklyRegenDecision` qui :
//   - rapporte la semaine S analysée (debug + drill-down UI)
//   - précise le numéro de la semaine cible (S+1)
//   - expose le niveau de pause détecté (pour wording UI, jamais santé)
//   - expose l'ajustement de volume (multiplicateur prêt à appliquer)
//   - porte la cause machine-readable (mapping i18n côté UI)
//
// Phase B prendra cette `WeeklyRegenDecision` pour patcher le
// `PersistedProgram` : multiplier sur `durationMinutes` (ou `targetDistanceMeters`)
// des sessions de S+1 dans le cas standard, reconstruction "from base" pour
// `.restart`. Ces effets de bord sortent du scope Phase A (algo pur).
import Foundation
import TemplateModel

// MARK: - WeeklyRegenDecision

/// Résultat consolidé du pipeline regen hebdo pour la semaine S+1.
public struct WeeklyRegenDecision: Equatable, Sendable {

    /// Numéro de la semaine analysée (celle qui vient de se terminer = S).
    public let analyzedWeekNumber: Int

    /// Numéro de la semaine cible de la régen (= analyzedWeekNumber + 1).
    public let targetWeekNumber: Int

    /// Rapport agrégé de S (completionRate, globalQuality, matches…) pour le
    /// drill-down UI.
    public let report: WeeklyExecutionReport

    /// Détection de pause complète : niveau + signaux bruts (jours, sem
    /// consécutives sub-seuil). Le niveau est aussi exposé directement via
    /// `pauseLevel` pour les call-sites qui n'ont pas besoin du détail.
    public let pauseDetection: PauseDetectionResult

    /// Niveau de pause détecté. Raccourci sur `pauseDetection.level`.
    public var pauseLevel: PauseLevel { pauseDetection.level }

    /// Ajustement de volume à appliquer aux sessions de S+1.
    public let adjustment: VolumeAdjustment

    /// Cause de la décision, machine-readable (mapping i18n côté UI).
    public let reason: RegressionDecision.Reason

    /// Multiplicateur prêt à appliquer (raccourci sur `adjustment.multiplier`).
    public var multiplier: Double { adjustment.multiplier }

    public init(
        analyzedWeekNumber: Int,
        targetWeekNumber: Int,
        report: WeeklyExecutionReport,
        pauseDetection: PauseDetectionResult,
        adjustment: VolumeAdjustment,
        reason: RegressionDecision.Reason
    ) {
        self.analyzedWeekNumber = analyzedWeekNumber
        self.targetWeekNumber = targetWeekNumber
        self.report = report
        self.pauseDetection = pauseDetection
        self.adjustment = adjustment
        self.reason = reason
    }
}

// MARK: - WeeklyRegenEngine

public enum WeeklyRegenEngine {

    /// Pipeline complet : matche les workouts HK, analyse la semaine, détecte
    /// la pause, décide de l'ajustement.
    ///
    /// - Parameters:
    ///   - weekNumber: numéro de la semaine S analysée.
    ///   - weekStartDate: lundi 00:00 de S.
    ///   - sessions: sessions planifiées de S (toutes, y compris `.rest`).
    ///   - sportCode: sport ciblé (filtre les workouts HK via `WorkoutMatcher`).
    ///   - workouts: workouts HK candidats.
    ///   - hrMax: HRmax estimé pour calibrer l'intensité. nil → score volume seul.
    ///   - previousReports: rapports des semaines antérieures à S, triés du plus
    ///     RÉCENT au plus ANCIEN (index 0 = S-1). Vide accepté (cas S1).
    ///   - daysSinceLastWorkout: nb de jours depuis le dernier workout HK
    ///     enregistré. nil si HK indispo.
    ///   - now: date « maintenant » (injectable pour les tests).
    public static func regenerate(
        weekNumber: Int,
        weekStartDate: Date,
        sessions: [PersistedSession],
        sportCode: String,
        workouts: [HealthSummary.WorkoutSnapshot],
        hrMax: Int?,
        previousReports: [WeeklyExecutionReport] = [],
        daysSinceLastWorkout: Int? = nil,
        now: Date = Date()
    ) -> WeeklyRegenDecision {
        let report = WeeklyExecutionAnalyzer.analyze(
            weekNumber: weekNumber,
            weekStartDate: weekStartDate,
            sessions: sessions,
            sportCode: sportCode,
            workouts: workouts,
            hrMax: hrMax,
            now: now
        )
        return regenerate(
            currentReport: report,
            previousReports: previousReports,
            daysSinceLastWorkout: daysSinceLastWorkout
        )
    }

    /// Pipeline partiel : si A.4 est appelé après qu'A.2 a déjà produit le
    /// rapport, on évite de re-matcher. Sert aussi aux tests fonctionnels A.4
    /// qui pilotent directement le rapport (sans rejouer A.1 + A.2).
    ///
    /// - Parameters:
    ///   - currentReport: rapport de la semaine S qui vient de se terminer.
    ///   - previousReports: rapports antérieurs (S-1, S-2…). L'ordre est
    ///     **indifférent** côté caller — le moteur trie défensivement par
    ///     `weekStartDate` desc (plus récent en tête) avant de passer à
    ///     PauseDetector. Évite un bug silencieux si Phase B branche une query
    ///     SQLite qui retourne ASC par défaut.
    ///   - daysSinceLastWorkout: voir `regenerate(weekNumber:…)`.
    public static func regenerate(
        currentReport: WeeklyExecutionReport,
        previousReports: [WeeklyExecutionReport] = [],
        daysSinceLastWorkout: Int? = nil
    ) -> WeeklyRegenDecision {
        let sortedPrevious = previousReports.sorted { $0.weekStartDate > $1.weekStartDate }
        // PauseDetector regarde le PASSÉ (semaines déjà archivées), pas la
        // semaine courante. Sinon une sem courante sub-seuil isolée se
        // ferait flagger "pauseLight" et masquerait le signal `missedSessions`
        // de RegressionRule (qui est l'analyse correcte pour une semaine
        // courante ratée : programme trop chargé, pas une vraie pause). Une
        // vraie pause = série historique sub-seuil OU délai HK long ; les
        // deux sont visibles dans `previousReports` + `daysSinceLastWorkout`.
        let pauseDetection = PauseDetector.detect(
            recentReports: sortedPrevious,
            daysSinceLastWorkout: daysSinceLastWorkout
        )
        let regression = RegressionRule.decide(
            currentWeek: currentReport,
            pauseLevel: pauseDetection.level
        )
        return WeeklyRegenDecision(
            analyzedWeekNumber: currentReport.weekNumber,
            targetWeekNumber: currentReport.weekNumber + 1,
            report: currentReport,
            pauseDetection: pauseDetection,
            adjustment: regression.adjustment,
            reason: regression.reason
        )
    }
}
