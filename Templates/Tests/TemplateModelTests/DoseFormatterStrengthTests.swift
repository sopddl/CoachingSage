import XCTest
import TemplateModel

/// Filet golden — chantier structuration i18n du dosage, Lot 7 muscu (strength).
///
/// Verrouille la VALEUR exacte rendue FR/EN/ES des cas muscu représentatifs, sur les DEUX
/// chemins : `string()` (chip/overview avec nom d'unité) et `repsCompactString()` (party
/// muscu : reps minimal SANS nom, « 3 × 12 » et pas « 3 × 12 reps »). Couvre la latéralité
/// jambe/épaule (les fuites réelles muscu, non couvertes par l'ancien `localizedReps`), les
/// tenues en secondes (nom gardé) et les schémas AMRAP/max/« de chaque exercice » freeText.
final class DoseFormatterStrengthTests: XCTestCase {

    private let fr = Locale(identifier: "fr")
    private let en = Locale(identifier: "en")
    private let es = Locale(identifier: "es")

    private func assertFull(_ dose: Dose, fr: String, en: String, es: String,
                            file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(DoseFormatter.string(dose, locale: self.fr), fr, "FR full", file: file, line: line)
        XCTAssertEqual(DoseFormatter.string(dose, locale: self.en), en, "EN full", file: file, line: line)
        XCTAssertEqual(DoseFormatter.string(dose, locale: self.es), es, "ES full", file: file, line: line)
    }

    private func assertCompact(_ dose: Dose, fr: String, en: String, es: String,
                               file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(DoseFormatter.repsCompactString(dose, locale: self.fr), fr, "FR compact", file: file, line: line)
        XCTAssertEqual(DoseFormatter.repsCompactString(dose, locale: self.en), en, "EN compact", file: file, line: line)
        XCTAssertEqual(DoseFormatter.repsCompactString(dose, locale: self.es), es, "ES compact", file: file, line: line)
    }

    // Reps nues : full = « 12 reps » ; compact muscu = « 12 » (party reps-héros minimal).
    func testPlainReps() {
        let d = Dose.structured(StructuredDose(value: "12", unit: .reps))
        assertFull(d, fr: "12 reps", en: "12 reps", es: "12 reps")
        assertCompact(d, fr: "12", en: "12", es: "12")
    }

    // Plage de reps : compact garde la plage telle quelle.
    func testRepRange() {
        assertCompact(.structured(StructuredDose(value: "8-10", unit: .reps)),
                      fr: "8-10", en: "8-10", es: "8-10")
    }

    // Latéralité : LE point du lot — « par jambe »/« par épaule » fuyaient en EN/ES.
    func testLateralReps() {
        assertCompact(.structured(StructuredDose(value: "10", unit: .reps, qualifier: .perSide)),
                      fr: "10 par côté", en: "10 per side", es: "10 por lado")
        assertCompact(.structured(StructuredDose(value: "10", unit: .reps, qualifier: .perLeg)),
                      fr: "10 par jambe", en: "10 per leg", es: "10 por pierna")
        assertCompact(.structured(StructuredDose(value: "5", unit: .reps, qualifier: .perShoulder)),
                      fr: "5 par épaule", en: "5 per shoulder", es: "5 por hombro")
        assertCompact(.structured(StructuredDose(value: "8-10", unit: .reps, qualifier: .perSide)),
                      fr: "8-10 par côté", en: "8-10 per side", es: "8-10 por lado")
    }

    // Tenue dans le champ reps -> secondes : compact GARDE le nom (« 75 s », pas « 75 »).
    func testHoldSeconds() {
        assertCompact(.structured(StructuredDose(value: "75", unit: .seconds)),
                      fr: "75 s", en: "75 s", es: "75 s")
        assertCompact(.structured(StructuredDose(value: "50", unit: .seconds, qualifier: .perSide)),
                      fr: "50 s par côté", en: "50 s per side", es: "50 s por lado")
    }

    // Schémas par série / AMRAP / max / « de chaque exercice » -> freeText (T2 tout-ou-rien).
    func testFreeTextSchemes() {
        // Pur numérique : identique 3 langues (aucun mot FR -> aucune fuite).
        assertCompact(.freeText(LocalizedText(fr: "5, 6, 8, 8", en: "5, 6, 8, 8", es: "5, 6, 8, 8")),
                      fr: "5, 6, 8, 8", en: "5, 6, 8, 8", es: "5, 6, 8, 8")
        assertCompact(.freeText(LocalizedText(fr: "5, 5, 5, 5+ AMRAP", en: "5, 5, 5, 5+ AMRAP", es: "5, 5, 5, 5+ AMRAP")),
                      fr: "5, 5, 5, 5+ AMRAP", en: "5, 5, 5, 5+ AMRAP", es: "5, 5, 5, 5+ AMRAP")
        assertCompact(.freeText(LocalizedText(fr: "max propre", en: "clean max", es: "máx. limpias")),
                      fr: "max propre", en: "clean max", es: "máx. limpias")
        assertCompact(.freeText(LocalizedText(fr: "8 de chaque exercice", en: "8 of each exercise", es: "8 de cada ejercicio")),
                      fr: "8 de chaque exercice", en: "8 of each exercise", es: "8 de cada ejercicio")
        assertCompact(.freeText(LocalizedText(fr: "AMRAP — 1 série", en: "AMRAP — 1 set", es: "AMRAP — 1 serie")),
                      fr: "AMRAP — 1 série", en: "AMRAP — 1 set", es: "AMRAP — 1 serie")
    }
}
