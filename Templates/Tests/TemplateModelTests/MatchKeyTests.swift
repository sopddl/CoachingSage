import XCTest
@testable import TemplateModel

/// i18n B2.1 — découplage de la clé de matching (`stableMatchKey`) du nom affichable
/// (`name`, localisable/vulgarisable). Prouve que `name.fr` peut être réécrit sans
/// déplacer la clé sur laquelle matchent findExercise / pattern resolver / fiches /
/// illustrations.
final class MatchKeyTests: XCTestCase {

    /// Décodeur aligné sur le bundle prod (snake_case `match_key`).
    private func decoder() -> JSONDecoder {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        return d
    }

    func testStableMatchKeyFallsBackToCanonicalWhenAbsent() throws {
        // Template pré-i18n : pas de `match_key` → la clé reste le nom FR canonique.
        let json = Data(#"{"name":{"fr":"Pont fessier"}}"#.utf8)
        let ex = try decoder().decode(TemplateExercise.self, from: json)
        XCTAssertNil(ex.matchKey)
        XCTAssertEqual(ex.stableMatchKey, "Pont fessier")
    }

    func testStableMatchKeyUsesExplicitMatchKey() throws {
        // i18n B2 : `name.fr` vulgarisé, mais `match_key` figé sur le nom technique d'origine.
        let json = Data(#"""
        {"name":{"fr":"Pont de hanches au sol","en":"Glute bridge","es":"Puente de glúteos"},
         "match_key":"Pont fessier"}
        """#.utf8)
        let ex = try decoder().decode(TemplateExercise.self, from: json)
        // Affichage = vulgarisé/traduit…
        XCTAssertEqual(ex.name.resolved(Locale(identifier: "fr")), "Pont de hanches au sol")
        XCTAssertEqual(ex.name.resolved(Locale(identifier: "en")), "Glute bridge")
        // …mais le matching reste sur la clé stable (le nom technique d'origine).
        XCTAssertEqual(ex.stableMatchKey, "Pont fessier")
        XCTAssertNotEqual(ex.stableMatchKey, ex.name.canonical)
    }

    func testMatchKeyRoundTripsAndIsOmittedWhenNil() throws {
        let enc = TemplateCoding.makeEncoder()
        let dec = decoder()

        // Avec match_key → préservé au round-trip.
        let withKey = TemplateExercise(name: LocalizedText(fr: "Vulgarisé"), matchKey: "Technique")
        let reDecoded = try dec.decode(TemplateExercise.self, from: try enc.encode(withKey))
        XCTAssertEqual(reDecoded.matchKey, "Technique")
        XCTAssertEqual(reDecoded.stableMatchKey, "Technique")

        // Sans match_key → omis du JSON (bundle byte-stable, pas de `match_key` parasite).
        let noKey = TemplateExercise(name: LocalizedText(fr: "Simple"))
        let encoded = String(data: try enc.encode(noKey), encoding: .utf8)!
        XCTAssertFalse(encoded.contains("match_key"), "match_key nil ne doit pas être sérialisé")
    }
}
