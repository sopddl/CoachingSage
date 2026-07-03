// CoachingSageTests/Adapter/DensityCoverageDumpTests.swift
// Densité B — dump de couverture RÉELLE par sport (question Sophie 2026-07-03
// « pour tous les sports ? ») : applique DensityRule avec signal actif sur chaque
// template GATÉ (beginner/recreational) du bundle prod et compte les densifications.
// Pattern StrengthResolutionDumpTests : test-dump permanent, échoue seulement si
// la densité devient un no-op TOTAL sur un sport censé avoir du gisement.
import XCTest
import TemplateModel
import TemplateLoader
@testable import CoachingSage

@MainActor
final class DensityCoverageDumpTests: XCTestCase {

    func testDumpDensityCoveragePerGatedTemplate() async throws {
        let templates = try await TemplateLoader.loadAll()
        guard templates.count >= 30 else { throw XCTSkip("bundle non peuplé (\(templates.count))") }

        let rule = DensityRule()
        let active = AdapterCoachingProfile(requiresMedicalClearance: false, weeklyWorkoutsAverage4w: 2.0)
        let sportProfile = AdapterTestFixtures.sportProfile()
        var coveredSports: Set<Sport> = []

        print("=== DENSITÉ B — couverture par template gaté (signal actif 2,0/sem) ===")
        for template in templates.sorted(by: { $0.id < $1.id })
        where DensityRule.gatedLevels.contains(template.level) {
            let weeks = template.weeks.map { week in
                AdaptedWeek(
                    weekNumber: week.weekNumber, theme: week.theme, goal: week.goal,
                    sessions: week.sessions.map { s in
                        AdaptedSession(
                            day: s.day, name: s.name, durationMinutes: s.durationMinutes,
                            type: s.type, warmup: s.warmup,
                            exercises: s.exercises.map { AdaptedExercise.passthrough($0, sport: template.sport) },
                            cooldown: s.cooldown
                        )
                    }
                )
            }
            let result = rule.apply(
                weeks: weeks, template: template, sport: template.sport,
                level: template.level, sportProfile: sportProfile, coachingProfile: active
            )
            let densifiedSessions = Set(result.appliedRules.map { "\($0.weekNumber)-\($0.day)" }).count
            let totalSessions = weeks.reduce(0) { $0 + $1.sessions.filter { $0.type != .rest }.count }
            print(String(format: "%-52s %3d règles · %3d/%3d séances densifiées",
                         (template.id as NSString).utf8String!,
                         result.appliedRules.count, densifiedSessions, totalSessions))
            if !result.appliedRules.isEmpty { coveredSports.insert(template.sport) }
        }
        print("=== sports avec densification réelle : \(coveredSports.count)/10 — \(coveredSports.map(\.rawValue).sorted()) ===")

        // Filet minimal : le gros gisement doctrine ne doit jamais retomber à zéro.
        for sport in [Sport.strengthTraining, .swimming, .yoga] {
            XCTAssertTrue(coveredSports.contains(sport),
                          "densité no-op TOTAL sur \(sport.rawValue) — régression de whitelist/comptage ?")
        }
    }
}
