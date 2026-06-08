// CoachingSageTests/Views/Components/StrengthResolutionDumpTests.swift
// Diagnostic (revue images muscu 2026-06-08) : dump du pattern RÉELLEMENT résolu pour
// chaque exercice muscu, via le pipeline prod (TemplateLoader → passthrough → resolve).
// Sert à distinguer les vrais trous (→ .generic) des artefacts. Non assertif.
import XCTest
import TemplateLoader
import TemplateModel
@testable import CoachingSage

final class StrengthResolutionDumpTests: XCTestCase {

    func testDumpStrengthResolutions() async throws {
        let all = try await TemplateLoader.loadAll()
        var map: [String: String] = [:]   // stableMatchKey → pattern
        for tpl in all where tpl.sport == .strengthTraining {
            for week in tpl.weeks {
                for session in week.sessions {
                    for ex in session.exercises {
                        let adapted = AdaptedExercise.passthrough(ex)
                        let pattern = ExercisePatternResolver.resolve(adapted, sportCode: "strengthTraining")
                        map[adapted.originalName] = "\(pattern)"
                    }
                }
            }
        }
        let lines = map.keys.sorted().map { "RESO| \(map[$0]!) | \($0)" }
        print("=== STRENGTH RESOLUTIONS (\(map.count) distinct) ===")
        for l in lines { print(l) }
        // Liste explicite des génériques (vrais trous).
        let generics = map.filter { $0.value == "generic" }.keys.sorted()
        print("=== GENERIC FALLBACKS (\(generics.count)) ===")
        for g in generics { print("GENERIC| \(g)") }
        XCTAssertFalse(all.isEmpty)
    }
}
