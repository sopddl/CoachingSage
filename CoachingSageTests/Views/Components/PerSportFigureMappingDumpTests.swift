// CoachingSageTests/Views/Components/PerSportFigureMappingDumpTests.swift
// Revue dessins TOUS SPORTS (Sophie 2026-06-08) : dump diagnostic du MAPPING exercice →
// figure réelle, par sport, via le pipeline resolver réel. Exclut les patterns qui rendent
// l'icône sport (generic + run/swim/cycle) : ne reste que les exos qui rendent une VRAIE
// figure dessinée → c'est là que peut se cacher un mauvais mapping (comme en muscu).
// Lit /tmp/per_sport_matchkeys.json (extrait des templates). Diagnostic only, ne « teste » rien.
import XCTest
import TemplateModel
@testable import CoachingSage

@MainActor
final class PerSportFigureMappingDumpTests: XCTestCase {

    // Patterns qui rendent l'ICÔNE sport (pas une figure dessinée) → hors revue dessins.
    private let iconPatterns: Set<ExercisePattern> = [
        .generic, .runEndurance, .runInterval, .runDrills,
        .swimEndurance, .swimDrill, .cycleEndurance, .cycleInterval,
    ]

    func testDumpPerSportRealFigureMappings() throws {
        let url = URL(fileURLWithPath: "/tmp/per_sport_matchkeys.json")
        guard let data = try? Data(contentsOf: url),
              let perSport = try? JSONDecoder().decode([String: [String: String]].self, from: data)
        else {
            print("DUMP| /tmp/per_sport_matchkeys.json absent — relancer l'extraction Python.")
            return
        }
        for sport in perSport.keys.sorted() {
            let keys = perSport[sport] ?? [:]
            var byPattern: [ExercisePattern: [String]] = [:]
            for matchKey in keys.keys {
                let ex = AdaptedExercise(name: LocalizedText(fr: matchKey), originalName: matchKey)
                let pat = ExercisePatternResolver.resolve(ex, sportCode: sport)
                guard !iconPatterns.contains(pat) else { continue }
                byPattern[pat, default: []].append(matchKey)
            }
            let realCount = byPattern.values.reduce(0) { $0 + $1.count }
            print("\n=== \(sport) : \(realCount) exos à VRAIE figure / \(keys.count) distincts ===")
            for pat in byPattern.keys.sorted(by: { $0.rawValue < $1.rawValue }) {
                let list = byPattern[pat] ?? []
                print("  FIG| \(pat.rawValue) (\(list.count)):")
                for mk in list.prefix(8) { print("      · \(mk)") }
                if list.count > 8 { print("      … +\(list.count - 8)") }
            }
        }
    }
}
