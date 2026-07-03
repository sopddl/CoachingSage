// CoachingSageTests/Views/Components/StrengthResolutionDumpTests.swift
// Diagnostic (revue images muscu 2026-06-08) : dump du pattern RÉELLEMENT résolu pour
// chaque exercice muscu, via le pipeline prod (TemplateLoader → passthrough → resolve).
// Sert à distinguer les vrais trous (→ .generic) des artefacts. Non assertif.
import XCTest
import TemplateLoader
import TemplateModel

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

    /// Diagnostic cross-sport (2026-06-08) : combien d'exos tombent en .generic par sport
    /// (= dessins manquants/mismatch potentiels, comme la muscu).
    func testDumpAllSportsGenericCounts() async throws {
        let all = try await TemplateLoader.loadAll()
        var perSport: [String: (total: Int, generic: Int, genKeys: Set<String>)] = [:]
        for tpl in all {
            let code = "\(tpl.sport)"
            for week in tpl.weeks {
                for session in week.sessions {
                    for ex in session.exercises {
                        let adapted = AdaptedExercise.passthrough(ex)
                        let pat = ExercisePatternResolver.resolve(adapted, sportCode: code)
                        var e = perSport[code] ?? (0, 0, [])
                        e.total += 1
                        if "\(pat)" == "generic" { e.generic += 1; e.genKeys.insert(adapted.originalName) }
                        perSport[code] = e
                    }
                }
            }
        }
        print("=== GENERIC PAR SPORT ===")
        for (sport, e) in perSport.sorted(by: { $0.key < $1.key }) {
            print("SPORT| \(sport) : \(e.generic)/\(e.total) generic")
            for k in e.genKeys.sorted().prefix(12) { print("   GEN| \(sport) | \(k)") }
        }
        XCTAssertFalse(all.isEmpty)
    }
}
