import XCTest
import TemplateModel

/// Filet golden — chantier structuration i18n du dosage, Lot 6 hiit.
///
/// Verrouille la VALEUR exacte rendue FR/EN/ES : intervalle work/rest (`DoseActivity` work/rest,
/// extension pilote-sport), « X min par round » structuré, composites de gainage freeText (noms
/// d'exos internationaux gardés, mots de structure traduits). Complète l'absence-de-fuite garantie
/// par `NoFreeTextFRInDoseTests`.
final class DoseFormatterHiitTests: XCTestCase {

    private let fr = Locale(identifier: "fr")
    private let en = Locale(identifier: "en")
    private let es = Locale(identifier: "es")

    private func assertRender(_ dose: Dose, fr: String, en: String, es: String,
                              file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(DoseFormatter.string(dose, locale: self.fr), fr, "FR", file: file, line: line)
        XCTAssertEqual(DoseFormatter.string(dose, locale: self.en), en, "EN", file: file, line: line)
        XCTAssertEqual(DoseFormatter.string(dose, locale: self.es), es, "ES", file: file, line: line)
    }

    // Intervalle work/rest -> Dose.interval (activités work/rest neuves).
    func testWorkRestInterval() {
        assertRender(.interval([IntervalSegment(value: "20", unit: .seconds, activity: .work),
                                IntervalSegment(value: "10", unit: .seconds, activity: .rest)]),
                     fr: "20 s d'effort + 10 s de récup",
                     en: "20 s work + 10 s rest",
                     es: "20 s de trabajo + 10 s de descanso")
    }

    // « X min par round » -> structuré perRound.
    func testPerRound() {
        assertRender(.structured(StructuredDose(value: "1", unit: .minutes, qualifier: .perRound)),
                     fr: "1 min par round", en: "1 min per round", es: "1 min por ronda")
    }

    // Secondes nues + reps par bras -> structuré.
    func testPlainSecondsAndPerArm() {
        assertRender(.structured(StructuredDose(value: "180", unit: .seconds)),
                     fr: "180 s", en: "180 s", es: "180 s")
        assertRender(.structured(StructuredDose(value: "10", unit: .reps, qualifier: .perArm)),
                     fr: "10 reps par bras", en: "10 reps per arm", es: "10 reps por brazo")
    }

    // Composite gainage -> freeText : planche/ventrale/latérale traduits, /côté -> per side.
    func testCoreComposite() {
        assertRender(.freeText(LocalizedText(fr: "60 s de planche ventrale + 30 s de planche latérale par côté",
                                             en: "60 s front plank + 30 s side plank per side",
                                             es: "60 s de plancha frontal + 30 s de plancha lateral por lado")),
                     fr: "60 s de planche ventrale + 30 s de planche latérale par côté",
                     en: "60 s front plank + 30 s side plank per side",
                     es: "60 s de plancha frontal + 30 s de plancha lateral por lado")
    }

    // Noms d'exos internationaux gardés (tibialis raises) ; seul « /jambe » est traduit.
    func testKeptExerciseNames() {
        assertRender(.freeText(LocalizedText(fr: "15 tibialis raises par jambe + 60 s de planche",
                                             en: "15 tibialis raises per leg + 60 s plank",
                                             es: "15 tibialis raises por pierna + 60 s de plancha")),
                     fr: "15 tibialis raises par jambe + 60 s de planche",
                     en: "15 tibialis raises per leg + 60 s plank",
                     es: "15 tibialis raises por pierna + 60 s de plancha")
    }
}
