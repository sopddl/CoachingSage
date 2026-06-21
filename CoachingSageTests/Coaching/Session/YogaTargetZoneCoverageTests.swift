// CoachingSageTests/Coaching/Session/YogaTargetZoneCoverageTests.swift
// Garde-fou pérenne — chantier dose i18n yoga (party 2026-06-14).
//
// Le champ `target_zone` du yoga ne porte PAS des codes zone mais des tags
// qualitatifs FR en dur (« réparateur », « méditation », « respiration guidée »,
// « enchaînement », « maintien N s ») ou un RPE. `IntensityLabel` les traduit au
// rendu via plainEffort → yogaZoneLabel → sensationLabel ; si AUCUN ne résout, le
// `else` affiche le badge brut = la chaîne FR identique sous EN/ES → fuite i18n.
//
// `DosageFormattingTests` verrouille le wording de valeurs LITTÉRALES. Ce filet-ci
// charge le bundle PROD (`TemplateLoader.loadAll`) et vérifie que CHAQUE valeur
// `target_zone` réellement shipée dans les templates yoga est résolue par un des
// trois resolvers — donc qu'un futur tag yoga non mappé (nouvelle pose, édition)
// est attrapé ici plutôt que de fuir en français au scroll HUB/FOCUS sous EN/ES.
import XCTest
import TemplateLoader
import TemplateModel
@testable import CoachingSage

final class YogaTargetZoneCoverageTests: XCTestCase {

    private let en = Locale(identifier: "en")

    func test_everyShippedYogaTargetZoneIsLocalized() async throws {
        let all = try await TemplateLoader.loadAll()
        let yoga = all.filter { $0.sport == .yoga }
        try XCTSkipIf(yoga.isEmpty, "bundle yoga non peuplé")

        // Collecte toutes les valeurs target_zone distinctes des exos yoga (sessions + variantes).
        var zones = Set<String>()
        for tpl in yoga {
            for week in tpl.weeks {
                for session in week.sessions {
                    for ex in session.exercises { ex.targetZone.map { zones.insert($0) } }
                    for variant in session.variants ?? [] {
                        for ex in variant.exercises { ex.targetZone.map { zones.insert($0) } }
                    }
                }
            }
        }

        // Invariant : chaque valeur est localisable (pas de retombée sur le badge FR brut).
        let unmapped = zones.filter { zone in
            DosageFormatting.plainEffort(from: zone, locale: en) == nil
                && DosageFormatting.yogaZoneLabel(from: zone, locale: en) == nil
                && DosageFormatting.sensationLabel(from: zone, locale: en) == nil
        }
        XCTAssertTrue(
            unmapped.isEmpty,
            "target_zone yoga non localisé(s) (fuiraient en FR sous EN/ES, à ajouter dans "
                + "DosageFormatting.yogaZoneLabel) : \(unmapped.sorted())")
    }
}
