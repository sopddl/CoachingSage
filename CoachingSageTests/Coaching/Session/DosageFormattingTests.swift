// CoachingSageTests/Coaching/Session/DosageFormattingTests.swift
// Chantier dosage caméléon (pilote muscu) — D1 (zéro jargon) + D4 (côté).
import XCTest
@testable import CoachingSage

final class DosageFormattingTests: XCTestCase {

    private let fr = Locale(identifier: "fr")

    // D1/AC1 : le jargon RPE devient un libellé d'effort en français normal.
    func test_plainEffort_convertsRPE_noJargon() {
        let out = DosageFormatting.plainEffort(from: "RPE 6-7", locale: fr)
        XCTAssertNotNil(out)
        XCTAssertFalse(out!.uppercased().contains("RPE"))
        XCTAssertTrue(out!.contains("6-7"))
        XCTAssertTrue(out!.contains("10"))
    }

    func test_plainEffort_singleValue() {
        let out = DosageFormatting.plainEffort(from: "rpe:8", locale: fr)
        XCTAssertEqual(out?.contains("8"), true)
        XCTAssertEqual(out?.uppercased().contains("RPE"), false)
    }

    // Les vraies zones d'allure (autres sports) ne sont PAS converties → glossaire préservé.
    func test_plainEffort_nilForRunningZones() {
        XCTAssertNil(DosageFormatting.plainEffort(from: "Z2", locale: fr))
        XCTAssertNil(DosageFormatting.plainEffort(from: "Daniels-E", locale: fr))
        XCTAssertNil(DosageFormatting.plainEffort(from: "", locale: fr))
    }

    // MARK: - Revue qualité thème #1 — sensation d'abord (zones/intensité)

    // Le mapping code → clé sensation couvre les 4 familles, par niveau.
    func test_sensationKey_mapsAllZoneFamilies() {
        // Cyclisme FTP (par niveau, pas collapsé)
        XCTAssertEqual(DosageFormatting.sensationKey(for: "FTP-Z2"), "coaching.zone.sensation.ftp.z2")
        XCTAssertEqual(DosageFormatting.sensationKey(for: "FTP-Z5"), "coaching.zone.sensation.ftp.z5")
        XCTAssertEqual(DosageFormatting.sensationKey(for: "Sweet-Spot"), "coaching.zone.sensation.sweetspot")
        // Course Daniels + allures
        XCTAssertEqual(DosageFormatting.sensationKey(for: "Daniels-E"), "coaching.zone.sensation.daniels.e")
        XCTAssertEqual(DosageFormatting.sensationKey(for: "Daniels-I"), "coaching.zone.sensation.daniels.i")
        XCTAssertEqual(DosageFormatting.sensationKey(for: "@HMP"), "coaching.zone.sensation.hmp")
        XCTAssertEqual(DosageFormatting.sensationKey(for: "@5K-pace"), "coaching.zone.sensation.pace5k")
        XCTAssertEqual(DosageFormatting.sensationKey(for: "@10K-pace"), "coaching.zone.sensation.pace10k")
        // Natation
        XCTAssertEqual(DosageFormatting.sensationKey(for: "EN1"), "coaching.zone.sensation.en1")
        XCTAssertEqual(DosageFormatting.sensationKey(for: "EN3"), "coaching.zone.sensation.en3")
        XCTAssertEqual(DosageFormatting.sensationKey(for: "REC"), "coaching.zone.sensation.rec")
        XCTAssertEqual(DosageFormatting.sensationKey(for: "CSS pace"), "coaching.zone.sensation.css")
        XCTAssertEqual(DosageFormatting.sensationKey(for: "CSS+5s/100m"), "coaching.zone.sensation.css.plus")
        XCTAssertEqual(DosageFormatting.sensationKey(for: "SP1"), "coaching.zone.sensation.sp1")
        // Zones FC génériques (+ variante cardiaque)
        XCTAssertEqual(DosageFormatting.sensationKey(for: "Z2"), "coaching.zone.sensation.hr.z2")
        XCTAssertEqual(DosageFormatting.sensationKey(for: "Z2-cardiac"), "coaching.zone.sensation.hr.z2")
        XCTAssertEqual(DosageFormatting.sensationKey(for: "Z4"), "coaching.zone.sensation.hr.z4")
    }

    // FTP-Zx ne doit PAS être happé par le matcher des zones FC génériques.
    func test_sensationKey_ftpNotConfusedWithGenericHRZone() {
        XCTAssertEqual(DosageFormatting.sensationKey(for: "FTP-Z3"), "coaching.zone.sensation.ftp.z3")
        XCTAssertNotEqual(DosageFormatting.sensationKey(for: "FTP-Z3"), "coaching.zone.sensation.hr.z3")
    }

    // Hors périmètre thème #1 → nil (l'appelant garde le badge glossaire / chip effort).
    func test_sensationKey_nilForOutOfScope() {
        XCTAssertNil(DosageFormatting.sensationKey(for: "RPE 6-7"))      // → plainEffort
        XCTAssertNil(DosageFormatting.sensationKey(for: "%1RM 85-90%"))  // charge muscu (autre chantier)
        XCTAssertNil(DosageFormatting.sensationKey(for: "technique"))    // déjà clair
        XCTAssertNil(DosageFormatting.sensationKey(for: "maintien 30 s"))// déjà clair
        XCTAssertNil(DosageFormatting.sensationKey(for: "EMOM"))         // format HIIT (thème #5)
        XCTAssertNil(DosageFormatting.sensationKey(for: "Tabata 20/10")) // format HIIT
        XCTAssertNil(DosageFormatting.sensationKey(for: ""))
    }

    // Le libellé résolu est en français normal, SANS le code coach (le code reste en sous-texte).
    func test_sensationLabel_isPlainFrench_noCode() {
        let z2 = DosageFormatting.sensationLabel(from: "FTP-Z2", locale: fr)
        XCTAssertEqual(z2, "endurance — tu peux parler")
        XCTAssertFalse(z2!.uppercased().contains("FTP"))
        let css = DosageFormatting.sensationLabel(from: "CSS pace", locale: fr)
        XCTAssertEqual(css, "allure seuil")
        XCTAssertFalse(css!.uppercased().contains("CSS"))
    }

    // Toutes les valeurs target_zone réellement shipées dans les templates sont couvertes,
    // soit par sensationKey (zones), soit par plainEffort (RPE), soit volontairement « déjà clair ».
    func test_sensationLabel_resolvesToTranslatedString_notRawKey() {
        // Garde-fou anti clé manquante : la string ne doit pas être renvoyée brute.
        for code in ["Daniels-T", "FTP-Z7", "EN2", "SP1", "Z3", "Sweet-Spot", "@HMP", "REC"] {
            let out = DosageFormatting.sensationLabel(from: code, locale: fr)
            XCTAssertNotNil(out, "pas de sensation pour \(code)")
            XCTAssertFalse(out!.hasPrefix("coaching.zone.sensation"), "clé non traduite pour \(code): \(out!)")
        }
    }

    // D4 : détection unilatérale depuis le texte des reps (FR/EN/ES).
    func test_isUnilateral() {
        XCTAssertTrue(DosageFormatting.isUnilateral(reps: "10 par côté"))
        XCTAssertTrue(DosageFormatting.isUnilateral(reps: "8 each side"))
        XCTAssertTrue(DosageFormatting.isUnilateral(reps: "12 cada lado"))
        XCTAssertFalse(DosageFormatting.isUnilateral(reps: "8"))
        XCTAssertFalse(DosageFormatting.isUnilateral(reps: "12-15"))
        XCTAssertFalse(DosageFormatting.isUnilateral(reps: nil))
    }

    // AC2 : le héros ne montre que le nombre, la latéralité passe en guidage à part.
    func test_repsHero_stripsSideSuffix() {
        XCTAssertEqual(DosageFormatting.repsHero(from: "10 par côté"), "10")
        XCTAssertEqual(DosageFormatting.repsHero(from: "8 each side"), "8")
        XCTAssertEqual(DosageFormatting.repsHero(from: "8"), "8")
        XCTAssertEqual(DosageFormatting.repsHero(from: "12-15"), "12-15")
    }
}
