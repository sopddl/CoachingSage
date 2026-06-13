import XCTest
@testable import TemplateModel

/// Chantier indoor/outdoor vélo (2026-06-10) — modèle variantes de lieu.
final class SessionVariantTests: XCTestCase {

    private func ex(_ name: String) -> TemplateExercise {
        TemplateExercise(name: LocalizedText(fr: name))
    }

    /// Séance vélo : contenu racine = native outdoor + 1 variante indoor.
    private func cyclingSession() -> TemplateSession {
        TemplateSession(
            day: 1,
            name: LocalizedText(fr: "Endurance 50 min", en: "Endurance 50 min", es: "Resistencia 50 min"),
            durationMinutes: 50,
            type: .endurance,
            warmup: LocalizedText(fr: "5 min facile"),
            exercises: [ex("Sortie route")],
            cooldown: LocalizedText(fr: "5 min retour au calme"),
            environment: .outdoor,
            variants: [
                SessionVariant(
                    environment: .indoor,
                    name: LocalizedText(fr: "Home-trainer 50 min", en: "Indoor 50 min", es: "Rodillo 50 min"),
                    durationMinutes: 50,
                    warmup: LocalizedText(fr: "5 min pédalage souple"),
                    exercises: [ex("Home-trainer résistance régulière")],
                    cooldown: LocalizedText(fr: "5 min pédalage léger")
                )
            ]
        )
    }

    func testMonoSessionHasNoEnvironmentVariants() {
        let s = TemplateSession(day: 1, name: "Course", durationMinutes: 30, type: .endurance,
                                warmup: nil, exercises: [], cooldown: nil)
        XCTAssertNil(s.environment)
        XCTAssertNil(s.variants)
        XCTAssertTrue(s.environmentVariants.isEmpty)
        XCTAssertNil(s.variant(for: .indoor))
        XCTAssertNil(s.variant(for: nil))
    }

    func testEnvironmentVariantsIncludesNativeFirst() {
        let envs = cyclingSession().environmentVariants.map(\.environment)
        XCTAssertEqual(envs, [.outdoor, .indoor]) // native (racine) en premier
    }

    func testVariantResolution() {
        let s = cyclingSession()
        XCTAssertEqual(s.variant(for: .outdoor)?.name.fr, "Endurance 50 min")    // native = racine
        XCTAssertEqual(s.variant(for: .indoor)?.name.fr, "Home-trainer 50 min")  // alternate
        XCTAssertEqual(s.variant(for: nil)?.name.fr, "Endurance 50 min")         // défaut = native
    }

    func testRoundTripWithVariants() throws {
        let s = cyclingSession()
        let data = try TemplateCoding.makeEncoder().encode(s)
        let back = try TemplateCoding.makeDecoder().decode(TemplateSession.self, from: data)
        XCTAssertEqual(s, back)
        XCTAssertEqual(back.variants?.count, 1)
        XCTAssertEqual(back.variant(for: .indoor)?.exercises.first?.name.fr, "Home-trainer résistance régulière")
    }

    /// Rétro-compat : un JSON sans `environment`/`variants` (les 39 templates non-vélo
    /// + tout le legacy) décode en séance mono, comportement inchangé.
    func testLegacyJSONWithoutVariantsDecodesAsMono() throws {
        let json = Data(#"{"day":2,"name":{"fr":"Sortie longue"},"durationMinutes":90,"type":"endurance","exercises":[]}"#.utf8)
        let s = try TemplateCoding.makeDecoder().decode(TemplateSession.self, from: json)
        XCTAssertNil(s.environment)
        XCTAssertNil(s.variants)
        XCTAssertTrue(s.environmentVariants.isEmpty)
        XCTAssertEqual(s.name.fr, "Sortie longue")
    }
}
