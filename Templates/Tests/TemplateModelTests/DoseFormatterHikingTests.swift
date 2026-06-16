import XCTest
import TemplateModel

/// Filet golden — chantier structuration i18n du dosage, Lot 5 hiking.
///
/// `NoFreeTextFRInDoseTests` garantit l'ABSENCE de fuite FR ; ce filet-ci verrouille la
/// VALEUR exacte rendue FR/EN/ES des cas représentatifs rando : renfo structuré (perSet/perLeg/
/// perLetter), heures freeText universelles, composites terrain (marche/D+/sac, montée+descente,
/// total cumulé) freeText traduits. Une édition future de `DoseFormatter` ou de la table changerait
/// ces sorties user-facing en silence sans ce verrou.
final class DoseFormatterHikingTests: XCTestCase {

    private let fr = Locale(identifier: "fr")
    private let en = Locale(identifier: "en")
    private let es = Locale(identifier: "es")

    private func assertRender(_ dose: Dose, fr: String, en: String, es: String,
                              file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(DoseFormatter.string(dose, locale: self.fr), fr, "FR", file: file, line: line)
        XCTAssertEqual(DoseFormatter.string(dose, locale: self.en), en, "EN", file: file, line: line)
        XCTAssertEqual(DoseFormatter.string(dose, locale: self.es), es, "ES", file: file, line: line)
    }

    // Minutes nues -> structuré (« 240 min »).
    func testPlainMinutes() {
        assertRender(.structured(StructuredDose(value: "240", unit: .minutes)),
                     fr: "240 min", en: "240 min", es: "240 min")
    }

    // Renfo structuré : par série / par jambe / par lettre / plage par jambe.
    func testRenfoQualifiers() {
        assertRender(.structured(StructuredDose(value: "8", unit: .reps, qualifier: .perSet)),
                     fr: "8 reps par série", en: "8 reps per set", es: "8 reps por serie")
        assertRender(.structured(StructuredDose(value: "30", unit: .seconds, qualifier: .perLeg)),
                     fr: "30 s par jambe", en: "30 s per leg", es: "30 s por pierna")
        assertRender(.structured(StructuredDose(value: "8", unit: .reps, qualifier: .perLetter)),
                     fr: "8 reps par lettre", en: "8 reps per letter", es: "8 reps por letra")
        assertRender(.structured(StructuredDose(value: "8-10", unit: .reps, qualifier: .perLeg)),
                     fr: "8-10 reps par jambe", en: "8-10 reps per leg", es: "8-10 reps por pierna")
    }

    // Heures = freeText. FR garde la convention « 6 h » / « 4 h 30 » (espaces) ; EN/ES collent
    // « 6h » / « 4h30 » (« 4 h 30 » est une convention FR qui lit mal hors-FR — décision Sophie 2026-06-16).
    func testHoursFormat() {
        assertRender(.freeText(LocalizedText(fr: "6 h", en: "6h", es: "6h")),
                     fr: "6 h", en: "6h", es: "6h")
        assertRender(.freeText(LocalizedText(fr: "4 h 30", en: "4h30", es: "4h30")),
                     fr: "4 h 30", en: "4h30", es: "4h30")
    }

    // Composite marche / D+ / sac -> freeText traduit (D+ -> elevation gain / desnivel).
    func testWalkElevationPackComposite() {
        assertRender(.freeText(LocalizedText(fr: "100 min de marche / D+ 280 m / sac 6 kg",
                                             en: "100 min walk / 280 m elevation gain / 6 kg pack",
                                             es: "100 min de caminata / 280 m de desnivel / mochila 6 kg")),
                     fr: "100 min de marche / D+ 280 m / sac 6 kg",
                     en: "100 min walk / 280 m elevation gain / 6 kg pack",
                     es: "100 min de caminata / 280 m de desnivel / mochila 6 kg")
    }

    // Intervalle montée/descente (RPE/pente inline) -> freeText fidèle ; RPE = vocabulaire gardé.
    func testUphillDownhillInterval() {
        assertRender(.freeText(LocalizedText(fr: "10 min de montée RPE 8-9, pente 15 %, sac 17 kg + 8 min de descente très facile",
                                             en: "10 min uphill RPE 8-9, 15% grade, 17 kg pack + 8 min very easy downhill",
                                             es: "10 min de subida RPE 8-9, pendiente 15 %, mochila 17 kg + 8 min de bajada muy fácil")),
                     fr: "10 min de montée RPE 8-9, pente 15 %, sac 17 kg + 8 min de descente très facile",
                     en: "10 min uphill RPE 8-9, 15% grade, 17 kg pack + 8 min very easy downhill",
                     es: "10 min de subida RPE 8-9, pendiente 15 %, mochila 17 kg + 8 min de bajada muy fácil")
    }
}
