import XCTest
import TemplateModel

/// Filet golden — chantier structuration i18n du dosage, Lot 8 tennis + football.
///
/// Verrouille la VALEUR exacte rendue FR/EN/ES :
///  - comptages sport STRUCTURÉS (services/passes/séquences/frappes — décision Sophie 2026-06-15) ;
///  - intervalles PLATS effort+récup STRUCTURÉS via `Dose.interval` (activités drill neuves :
///    cross/jeu/pattern/tie-break/long de ligne/sprint + récup/récup marche/ON-OFF/course-marche) ;
///  - segment de comptage SANS activité (« 30 frappes ») et effort nu (« 5 min » + récup) ;
///  - composites/imbriqués/jeu effectif/match → freeText traduit (lossless).
/// `strikes` repurposé frappe→shot/golpe (naturel tennis/foot, ≠ combat). Complète l'absence-de-
/// fuite garantie par `NoFreeTextFRInDoseTests`.
final class DoseFormatterTennisFootballTests: XCTestCase {

    private let fr = Locale(identifier: "fr")
    private let en = Locale(identifier: "en")
    private let es = Locale(identifier: "es")

    private func assertRender(_ dose: Dose, fr: String, en: String, es: String,
                              file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(DoseFormatter.string(dose, locale: self.fr), fr, "FR", file: file, line: line)
        XCTAssertEqual(DoseFormatter.string(dose, locale: self.en), en, "EN", file: file, line: line)
        XCTAssertEqual(DoseFormatter.string(dose, locale: self.es), es, "ES", file: file, line: line)
    }

    // MARK: Comptages sport structurés

    func testServes() {
        assertRender(.structured(StructuredDose(value: "10", unit: .serves)),
                     fr: "10 services", en: "10 serves", es: "10 servicios")
        assertRender(.structured(StructuredDose(value: "15", unit: .serves, qualifier: .perSet)),
                     fr: "15 services par série", en: "15 serves per set", es: "15 servicios por serie")
    }

    func testSequencesAndPasses() {
        assertRender(.structured(StructuredDose(value: "8", unit: .sequences)),
                     fr: "8 séquences", en: "8 sequences", es: "8 secuencias")
        assertRender(.structured(StructuredDose(value: "8", unit: .passes, qualifier: .perFoot)),
                     fr: "8 passes par pied", en: "8 passes per foot", es: "8 pases por pie")
    }

    // strikes repurposé : frappe / shot / golpe (≠ combat « strike »).
    func testStrikes() {
        assertRender(.structured(StructuredDose(value: "10", unit: .strikes)),
                     fr: "10 frappes", en: "10 shots", es: "10 golpes")
        assertRender(.structured(StructuredDose(value: "10", unit: .strikes, qualifier: .perFoot)),
                     fr: "10 frappes par pied", en: "10 shots per foot", es: "10 golpes por pie")
    }

    // MARK: Intervalles plats structurés (activités drill neuves)

    func testTennisDrillIntervals() {
        assertRender(.interval([IntervalSegment(value: "5", unit: .minutes, activity: .crossCourt),
                                IntervalSegment(value: "90", unit: .seconds, activity: .rest)]),
                     fr: "5 min de cross + 90 s de récup",
                     en: "5 min cross-court + 90 s rest",
                     es: "5 min cruzado + 90 s de descanso")
        assertRender(.interval([IntervalSegment(value: "8", unit: .minutes, activity: .game),
                                IntervalSegment(value: "2", unit: .minutes, activity: .rest)]),
                     fr: "8 min de jeu + 2 min de récup",
                     en: "8 min of play + 2 min rest",
                     es: "8 min de juego + 2 min de descanso")
        assertRender(.interval([IntervalSegment(value: "10", unit: .minutes, activity: .tieBreak),
                                IntervalSegment(value: "3", unit: .minutes, activity: .rest)]),
                     fr: "10 min de tie-break + 3 min de récup",
                     en: "10 min tie-break + 3 min rest",
                     es: "10 min de tie-break + 3 min de descanso")
        assertRender(.interval([IntervalSegment(value: "20", unit: .meters, activity: .sprint),
                                IntervalSegment(value: "30", unit: .seconds, activity: .walkingRecovery)]),
                     fr: "20 m de sprint + 30 s de marche de récupération",
                     en: "20 m sprint + 30 s recovery walk",
                     es: "20 m de sprint + 30 s de caminata de recuperación")
    }

    // Segment de comptage SANS activité (« 30 frappes » + récup marche).
    func testCountSegmentNoActivity() {
        assertRender(.interval([IntervalSegment(value: "30", unit: .strikes),
                                IntervalSegment(value: "1", unit: .minutes, activity: .walkingRecovery)]),
                     fr: "30 frappes + 1 min de marche de récupération",
                     en: "30 shots + 1 min recovery walk",
                     es: "30 golpes + 1 min de caminata de recuperación")
    }

    // Effort nu (« 5 min » sans activité) + récup.
    func testBareWorkSegment() {
        assertRender(.interval([IntervalSegment(value: "5", unit: .minutes),
                                IntervalSegment(value: "90", unit: .seconds, activity: .rest)]),
                     fr: "5 min + 90 s de récup",
                     en: "5 min + 90 s rest",
                     es: "5 min + 90 s de descanso")
    }

    func testFootballIntervals() {
        assertRender(.interval([IntervalSegment(value: "4-5", unit: .minutes, activity: .work),
                                IntervalSegment(value: "2", unit: .minutes, activity: .rest)]),
                     fr: "4-5 min d'effort + 2 min de récup",
                     en: "4-5 min work + 2 min rest",
                     es: "4-5 min de trabajo + 2 min de descanso")
        assertRender(.interval([IntervalSegment(value: "30", unit: .seconds, activity: .running),
                                IntervalSegment(value: "30", unit: .seconds, activity: .walking)]),
                     fr: "30 s de course + 30 s de marche",
                     en: "30 s running + 30 s walking",
                     es: "30 s de carrera + 30 s de caminata")
    }

    // MARK: freeText (composites / imbriqués / jeu effectif / match)

    func testFreeTextComposites() {
        // Imbriqué (2 niveaux, hors gabarit interval) — intensité « au seuil » droppée.
        assertRender(.freeText(LocalizedText(fr: "8 × (30 s de course au seuil + 30 s de marche)",
                                             en: "8 × (30 s threshold run + 30 s walk)",
                                             es: "8 × (30 s de carrera a umbral + 30 s de caminata)")),
                     fr: "8 × (30 s de course au seuil + 30 s de marche)",
                     en: "8 × (30 s threshold run + 30 s walk)",
                     es: "8 × (30 s de carrera a umbral + 30 s de caminata)")
        // Service composite (sous-spec gardée).
        assertRender(.freeText(LocalizedText(fr: "10 services (5 au T + 5 extérieurs)",
                                             en: "10 serves (5 down the T + 5 wide)",
                                             es: "10 servicios (5 al centro + 5 abiertos)")),
                     fr: "10 services (5 au T + 5 extérieurs)",
                     en: "10 serves (5 down the T + 5 wide)",
                     es: "10 servicios (5 al centro + 5 abiertos)")
        // Jeu effectif (temps universel).
        assertRender(.freeText(LocalizedText(fr: "90 min de jeu effectif",
                                             en: "90 min effective play",
                                             es: "90 min de juego efectivo")),
                     fr: "90 min de jeu effectif",
                     en: "90 min effective play",
                     es: "90 min de juego efectivo")
        // Corners / coups francs.
        assertRender(.freeText(LocalizedText(fr: "5 corners + 5 coups francs",
                                             en: "5 corners + 5 free kicks",
                                             es: "5 córners + 5 tiros libres")),
                     fr: "5 corners + 5 coups francs",
                     en: "5 corners + 5 free kicks",
                     es: "5 córners + 5 tiros libres")
    }
}
