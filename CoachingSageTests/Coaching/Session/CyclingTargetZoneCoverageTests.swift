// CoachingSageTests/Coaching/Session/CyclingTargetZoneCoverageTests.swift
// Garde-fou pérenne — clôture du finding "cycling targetZone VIDE" (revue qualité 2026-06-08).
//
// Investigation 2026-07-24 : le finding visait `Templates/References/raw/cycling-*.json`, une
// archive legacy pré-schema-v2 JAMAIS chargée par l'app (absente de `Package.swift`). Le dossier
// réellement shippé (`Templates/Sources/TemplateLoader/Resources/Templates/`) a `target_zone`
// peuplé sur la quasi-totalité des exercices cycling depuis Story 3.3a (2026-05-02) — non
// reproductible aujourd'hui. Ce filet ferme le vrai trou identifié : rien ne détectait une
// régression "targetZone vide/non résolu" sur cycling (contrairement au yoga, cf
// `YogaTargetZoneCoverageTests`).
import XCTest
import TemplateLoader
import TemplateModel

final class CyclingTargetZoneCoverageTests: XCTestCase {

    private let en = Locale(identifier: "en")

    func test_everyShippedCyclingExerciseHasResolvedTargetZone() async throws {
        let all = try await TemplateLoader.loadAll()
        let cycling = all.filter { $0.sport == .cycling }
        try XCTSkipIf(cycling.isEmpty, "bundle cycling non peuplé")

        var missing: [String] = []
        var zones = Set<String>()

        func scan(_ ex: TemplateExercise, _ context: String) {
            guard let zone = ex.targetZone, !zone.isEmpty else {
                // Jours de repos complet légitimement sans zone (pas d'effort à doser).
                if ex.name.en?.localizedCaseInsensitiveContains("rest") == true
                    || ex.name.fr.localizedCaseInsensitiveContains("repos") {
                    return
                }
                missing.append("\(context) — \(ex.name.en ?? ex.name.fr)")
                return
            }
            zones.insert(zone)
        }

        for tpl in cycling {
            for week in tpl.weeks {
                for session in week.sessions {
                    for ex in session.exercises { scan(ex, "\(tpl.id)/\(session.name.en ?? "?")") }
                    for variant in session.variants ?? [] {
                        for ex in variant.exercises { scan(ex, "\(tpl.id)/variant/\(variant.name.en ?? "?")") }
                    }
                }
            }
        }

        XCTAssertTrue(missing.isEmpty,
            "targetZone vide sur \(missing.count) exercice(s) cycling non-repos : \(missing.prefix(20))")

        // Chaque valeur distincte doit être résolue à l'affichage (pas de fuite de code brut).
        let unmapped = zones.filter { zone in
            DosageFormatting.plainEffort(from: zone, locale: en) == nil
                && DosageFormatting.sensationLabel(from: zone, locale: en) == nil
        }
        XCTAssertTrue(unmapped.isEmpty,
            "target_zone cycling non résolu(s) par DosageFormatting (fuite de code brut à "
                + "l'affichage) : \(unmapped.sorted())")
    }
}
