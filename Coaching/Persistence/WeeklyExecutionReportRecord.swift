// Coaching/Persistence/WeeklyExecutionReportRecord.swift
// Story 3.4 Phase B.1 — persiste une vue mince du `WeeklyExecutionReport` produit
// par Phase A.2 (`WeeklyExecutionAnalyzer`). Sert d'historique pour `PauseDetector`
// (Phase A.3), qui regarde les 3 semaines précédentes pour décider du niveau de
// pause à appliquer à S+1.
//
// On ne persiste PAS les `matches` détaillés du report (chaque match porte la
// session + le workout HK + l'ExecutionScore — relativement lourd et redondant
// avec `AdaptedProgramRecord.completionState`). Le snapshot minimal porte tous
// les champs dont PauseDetector et RegressionRule ont besoin :
//   - completionRate
//   - globalQuality
//   - plannedActiveSessionCount (pour ne pas compter une semaine full-rest comme low)
//   - completedSessionCount
//   - isOverallOverExecuted + overExecutedCount
//
// Pattern SwiftData strict : un seul `xxxJsonData: Data` (cf
// `AdaptedProgramRecord`) + getter/setter computed sur la struct Codable. Évite
// le piège `@Model` + types complexes natifs (lesson lessons_swiftdata #1).
import Foundation
import SwiftData

/// Snapshot mince d'un `WeeklyExecutionReport`, persistable et `Codable`.
/// Mapper bidirectionnel vers `WeeklyExecutionReport` dans `WeeklyExecutionReport+Snapshot.swift`.
public struct WeeklyExecutionReportSnapshot: Codable, Equatable, Sendable {
    public let weekNumber: Int
    public let weekStartDate: Date
    public let plannedSessionCount: Int
    public let plannedActiveSessionCount: Int
    public let completedSessionCount: Int
    public let completionRate: Double
    public let globalQuality: Double
    public let overExecutedCount: Int
    public let isOverallOverExecuted: Bool

    public init(
        weekNumber: Int,
        weekStartDate: Date,
        plannedSessionCount: Int,
        plannedActiveSessionCount: Int,
        completedSessionCount: Int,
        completionRate: Double,
        globalQuality: Double,
        overExecutedCount: Int,
        isOverallOverExecuted: Bool
    ) {
        self.weekNumber = weekNumber
        self.weekStartDate = weekStartDate
        self.plannedSessionCount = plannedSessionCount
        self.plannedActiveSessionCount = plannedActiveSessionCount
        self.completedSessionCount = completedSessionCount
        self.completionRate = completionRate
        self.globalQuality = globalQuality
        self.overExecutedCount = overExecutedCount
        self.isOverallOverExecuted = isOverallOverExecuted
    }
}

@Model
final class WeeklyExecutionReportRecord {
    @Attribute(.unique) var id: UUID
    var userId: UUID
    /// FK logique vers `AdaptedProgramRecord.id`. SwiftData ne pose pas la
    /// contrainte FK : c'est l'application service qui filtre par recordId.
    var recordId: UUID
    var sportCode: String
    var weekNumber: Int
    var weekStartDate: Date

    private var snapshotJsonData: Data
    var snapshot: WeeklyExecutionReportSnapshot {
        get {
            (try? JSONDecoder().decode(WeeklyExecutionReportSnapshot.self, from: snapshotJsonData))
                ?? WeeklyExecutionReportSnapshot(
                    weekNumber: weekNumber,
                    weekStartDate: weekStartDate,
                    plannedSessionCount: 0,
                    plannedActiveSessionCount: 0,
                    completedSessionCount: 0,
                    completionRate: 0,
                    globalQuality: 0,
                    overExecutedCount: 0,
                    isOverallOverExecuted: false
                )
        }
        set { snapshotJsonData = (try? JSONEncoder().encode(newValue)) ?? Data() }
    }

    var createdAt: Date

    init(
        id: UUID = UUID(),
        userId: UUID,
        recordId: UUID,
        sportCode: String,
        snapshot: WeeklyExecutionReportSnapshot,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.recordId = recordId
        self.sportCode = sportCode
        self.weekNumber = snapshot.weekNumber
        self.weekStartDate = snapshot.weekStartDate
        self.snapshotJsonData = (try? JSONEncoder().encode(snapshot)) ?? Data()
        self.createdAt = createdAt
    }
}
