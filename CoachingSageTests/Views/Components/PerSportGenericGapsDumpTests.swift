// CoachingSageTests/Views/Components/PerSportGenericGapsDumpTests.swift
// Party illustrations 2026-06-08 : dump diagnostic INVERSE du précédent — liste les exos
// qui tombent sur `.generic` (icône SF muette = VRAI trou de dessin) par sport, via le vrai
// resolver. Exclut les patterns cardio voulus (run/swim/cycle = geste universel, décision
// Sophie 2026-05-23). Lit /tmp/per_sport_matchkeys_10.json (10 sports). Diagnostic only.
import XCTest
import TemplateModel
@testable import CoachingSage

@MainActor
final class PerSportGenericGapsDumpTests: XCTestCase {

    // Patterns cardio voulus SANS dessin (icône sport = correct, pas un trou).
    private let intendedCardioIcons: Set<ExercisePattern> = [
        .runEndurance, .runInterval, .runDrills,
        .swimEndurance, .swimDrill, .cycleEndurance, .cycleInterval,
    ]

    func testDumpPerSportGenericGaps() throws {
        let url = URL(fileURLWithPath: "/tmp/per_sport_matchkeys_10.json")
        guard let data = try? Data(contentsOf: url),
              let perSport = try? JSONDecoder().decode([String: [String: Int]].self, from: data)
        else {
            print("DUMP| /tmp/per_sport_matchkeys_10.json absent — relancer l'extraction Python.")
            return
        }
        var out = ""
        for sport in perSport.keys.sorted() {
            let keys = perSport[sport] ?? [:]
            var gaps: [String] = []     // → .generic (trou franc)
            var cardioIcon = 0          // → icône cardio voulue
            var realFigure = 0          // → vraie figure dessinée
            for matchKey in keys.keys {
                let ex = AdaptedExercise(name: LocalizedText(fr: matchKey), originalName: matchKey)
                let pat = ExercisePatternResolver.resolve(ex, sportCode: sport)
                if pat == .generic { gaps.append(matchKey) }
                else if intendedCardioIcons.contains(pat) { cardioIcon += 1 }
                else { realFigure += 1 }
            }
            out += "\n=== \(sport) : \(gaps.count) TROUS (.generic) / figure=\(realFigure) / icône-cardio=\(cardioIcon) / \(keys.count) distincts ===\n"
            for mk in gaps.sorted() { out += "  TROU| \(mk)\n" }
        }
        try out.write(toFile: "/tmp/gaps_result.txt", atomically: true, encoding: .utf8)
    }
}
