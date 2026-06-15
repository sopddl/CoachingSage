import XCTest
import TemplateModel

/// Filet golden — chantier structuration i18n du dosage, Lot 4 swimming.
///
/// `NoFreeTextFRInDoseTests` garantit l'ABSENCE de fuite FR ; ce filet-ci verrouille la
/// VALEUR exacte rendue FR/EN/ES pour les cas représentatifs du lot swimming : distance nue
/// (glose intensité/allure DROPPÉE, portée par target_zone), nage spécifiée (crawl/dos) en
/// freeText, éducatif/récup/matériel en freeText, renfo à sec structuré (`perLetter`).
final class DoseFormatterSwimmingTests: XCTestCase {

    private let fr = Locale(identifier: "fr")
    private let en = Locale(identifier: "en")
    private let es = Locale(identifier: "es")

    private func assertRender(_ dose: Dose, fr: String, en: String, es: String,
                              file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(DoseFormatter.string(dose, locale: self.fr), fr, "FR", file: file, line: line)
        XCTAssertEqual(DoseFormatter.string(dose, locale: self.en), en, "EN", file: file, line: line)
        XCTAssertEqual(DoseFormatter.string(dose, locale: self.es), es, "ES", file: file, line: line)
    }

    // Distance nue : glose « endurance haute » (zone EN3) DROPPÉE → « 100 m » (m universel).
    func testPureDistanceDropsRedundantIntensity() {
        assertRender(.structured(StructuredDose(value: "100", unit: .meters)),
                     fr: "100 m", en: "100 m", es: "100 m")
    }

    // Nage spécifiée (crawl/dos) → freeText traduit (la nage n'est PAS dans le nom).
    func testStrokeFreeText() {
        assertRender(.freeText(LocalizedText(fr: "150 m dos lent", en: "150 m easy backstroke", es: "150 m espalda suave")),
                     fr: "150 m dos lent", en: "150 m easy backstroke", es: "150 m espalda suave")
        assertRender(.freeText(LocalizedText(fr: "200 m crawl, endurance facile", en: "200 m freestyle, easy endurance", es: "200 m crol, resistencia fácil")),
                     fr: "200 m crawl, endurance facile", en: "200 m freestyle, easy endurance", es: "200 m crol, resistencia fácil")
    }

    // Éducatif / récup explicite / matériel → freeText.
    func testDrillAndRestFreeText() {
        assertRender(.freeText(LocalizedText(fr: "1 poussée au mur + glisse 8 m", en: "1 wall push-off + 8 m glide", es: "1 impulso en la pared + 8 m de deslizamiento")),
                     fr: "1 poussée au mur + glisse 8 m", en: "1 wall push-off + 8 m glide", es: "1 impulso en la pared + 8 m de deslizamiento")
        assertRender(.freeText(LocalizedText(fr: "50 m crawl avec pull-buoy + 20 s de récup", en: "50 m freestyle with pull-buoy + 20 s rest", es: "50 m crol con pull-buoy + 20 s de descanso")),
                     fr: "50 m crawl avec pull-buoy + 20 s de récup", en: "50 m freestyle with pull-buoy + 20 s rest", es: "50 m crol con pull-buoy + 20 s de descanso")
    }

    // Renfo à sec structuré : qualificateur `perLetter` (Y-T-W).
    func testDryLandPerLetter() {
        assertRender(.structured(StructuredDose(value: "10", unit: .reps, qualifier: .perLetter)),
                     fr: "10 reps par lettre", en: "10 reps per letter", es: "10 reps por letra")
    }
}
