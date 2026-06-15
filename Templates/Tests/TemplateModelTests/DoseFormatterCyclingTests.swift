import XCTest
import TemplateModel

/// Filet golden — chantier structuration i18n du dosage, Lot 3 cycling.
///
/// `NoFreeTextFRInDoseTests` garantit l'ABSENCE de fuite FR ; ce filet-ci verrouille la
/// VALEUR exacte rendue FR/EN/ES pour les cas représentatifs du lot cycling (structuré +
/// qualificateur `perPosition` neuf, plages/approximatif, freeText terrain/cadence). Une
/// édition future de `DoseFormatter` ou de la table changerait ces sorties user-facing en
/// silence sans ce verrou.
final class DoseFormatterCyclingTests: XCTestCase {

    private let fr = Locale(identifier: "fr")
    private let en = Locale(identifier: "en")
    private let es = Locale(identifier: "es")

    private func assertRender(_ dose: Dose, fr: String, en: String, es: String,
                              file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(DoseFormatter.string(dose, locale: self.fr), fr, "FR", file: file, line: line)
        XCTAssertEqual(DoseFormatter.string(dose, locale: self.en), en, "EN", file: file, line: line)
        XCTAssertEqual(DoseFormatter.string(dose, locale: self.es), es, "ES", file: file, line: line)
    }

    // Glose d'intensité « tempo soutenu » DROPPÉE → minutes nues (intensité portée par target_zone).
    func testDroppedIntensityGlossRendersAsPlainMinutes() {
        assertRender(.structured(StructuredDose(value: "5", unit: .minutes)),
                     fr: "5 min", en: "5 min", es: "5 min")
    }

    // Qualificateur neuf `perPosition` (gainage cycliste ventral/dorsal).
    func testPerPositionQualifier() {
        assertRender(.structured(StructuredDose(value: "40", unit: .seconds, qualifier: .perPosition)),
                     fr: "40 s par position", en: "40 s per position", es: "40 s por posición")
    }

    func testPerLegSecondsAndRangeReps() {
        assertRender(.structured(StructuredDose(value: "60", unit: .seconds, qualifier: .perLeg)),
                     fr: "60 s par jambe", en: "60 s per leg", es: "60 s por pierna")
        assertRender(.structured(StructuredDose(value: "6-8", unit: .reps)),
                     fr: "6-8 reps", en: "6-8 reps", es: "6-8 reps")
    }

    // value String garde « ~ » et la plage : rendu language-agnostic (« min » universel).
    func testApproxAndRangeMinutes() {
        assertRender(.structured(StructuredDose(value: "~150", unit: .minutes)),
                     fr: "~150 min", en: "~150 min", es: "~150 min")
        assertRender(.structured(StructuredDose(value: "300-330", unit: .minutes)),
                     fr: "300-330 min", en: "300-330 min", es: "300-330 min")
    }

    // freeText traduit : terrain (D+/montée) + cadence rpm.
    func testFreeTextTerrainAndCadence() {
        assertRender(.freeText(LocalizedText(fr: "2 min en montée", en: "2 min uphill", es: "2 min en subida")),
                     fr: "2 min en montée", en: "2 min uphill", es: "2 min en subida")
        assertRender(.freeText(LocalizedText(fr: "180-220 km / 3000+ m D+",
                                             en: "180-220 km / 3000+ m elevation gain",
                                             es: "180-220 km / 3000+ m de desnivel")),
                     fr: "180-220 km / 3000+ m D+",
                     en: "180-220 km / 3000+ m elevation gain",
                     es: "180-220 km / 3000+ m de desnivel")
    }
}
