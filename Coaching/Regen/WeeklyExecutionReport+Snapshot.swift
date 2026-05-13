// Coaching/Regen/WeeklyExecutionReport+Snapshot.swift
// Story 3.4 Phase B.1 — pont bidirectionnel entre `WeeklyExecutionReport` (Phase
// A.2, en mémoire, porte les `matches` détaillés) et
// `WeeklyExecutionReportSnapshot` (Phase B.1, persisté, agrégats seuls).
//
// PauseDetector consomme `WeeklyExecutionReport` mais n'utilise que
// `completionRate` + `plannedActiveSessionCount`. Le reconstructor pose
// `matches: []` (les matches sont inutiles à PauseDetector et seraient lourds
// à persister).
import Foundation

extension WeeklyExecutionReport {
    /// Projette le report vers la représentation persistante mince.
    public var snapshot: WeeklyExecutionReportSnapshot {
        WeeklyExecutionReportSnapshot(
            weekNumber: weekNumber,
            weekStartDate: weekStartDate,
            plannedSessionCount: plannedSessionCount,
            plannedActiveSessionCount: plannedActiveSessionCount,
            completedSessionCount: completedSessionCount,
            completionRate: completionRate,
            globalQuality: globalQuality,
            overExecutedCount: overExecutedCount,
            isOverallOverExecuted: isOverallOverExecuted
        )
    }

    /// Reconstruction depuis un snapshot. Les `matches` ne sont pas persistés ;
    /// PauseDetector ne les utilise pas. Si un consommateur futur a besoin des
    /// matches d'une semaine archivée, il faudra re-run `WorkoutMatcher` à
    /// partir des sessions + workouts HK de l'époque (out-of-scope V1).
    public static func from(snapshot: WeeklyExecutionReportSnapshot) -> WeeklyExecutionReport {
        WeeklyExecutionReport(
            weekNumber: snapshot.weekNumber,
            weekStartDate: snapshot.weekStartDate,
            plannedSessionCount: snapshot.plannedSessionCount,
            plannedActiveSessionCount: snapshot.plannedActiveSessionCount,
            completedSessionCount: snapshot.completedSessionCount,
            completionRate: snapshot.completionRate,
            globalQuality: snapshot.globalQuality,
            overExecutedCount: snapshot.overExecutedCount,
            isOverallOverExecuted: snapshot.isOverallOverExecuted,
            matches: []
        )
    }
}
