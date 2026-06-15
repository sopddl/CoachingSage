// CoachingSageTests/Views/Components/StrengthRepsHeroSnapshotTests.swift
// Chantier structuration i18n du dosage — Lot 7 muscu.
//
// Filet VISUEL du bloc HÉROS reps muscu (mode Minuté), extrait de SessionFocusView pour être
// rendable seul. Couvre le câblage SwiftUI que le golden/gate (assertions de String) ne voient
// pas : que le GROS chiffre 80pt = `value` propre (pas « 10 par jambe » qui fuyait avant le Lot 7)
// et que le guidage côté apparaît pour un exo unilatéral. La valeur/latéralité sont tirées du VRAI
// helper `AdaptedExercise.repsHeroDose` → snapshot de bout en bout.
//
// ⚠️ Limite locale documentée : « reps » et « Côté droit · gauche » sont des LocalizedStringKey
// (chrome) → NON swizzlés, restent FR dans les 3 snapshots. Ce que CES snapshots verrouillent =
// le CHIFFRE (verbatim, localisé via le dose) + présence/absence du guidage côté + layout 80pt.
// La traduction du mot « reps »/« côté » est, elle, garantie par les .xcstrings (hors-scope ici).
import XCTest
import SwiftUI
import SnapshotTesting
import TemplateModel

final class StrengthRepsHeroSnapshotTests: XCTestCase {

    private func hero(reps: String, locale: Locale) -> StrengthRepsHero {
        let ex = AdaptedExercise(name: "Exo", originalName: "Exo", sets: 3, reps: reps)
        let d = ex.repsHeroDose(sportCode: "strengthTraining", locale: locale)
        return StrengthRepsHero(value: d?.value ?? reps, isLateral: d?.isLateral ?? false)
    }

    private func heroColumn(locale: Locale) -> some View {
        VStack(spacing: 28) {
            hero(reps: "10 par jambe", locale: locale)        // unilatéral → chiffre « 10 » + côté
            hero(reps: "8-10", locale: locale)                // plage, pas de côté
            hero(reps: "max propre", locale: locale)          // freeText court → « max propre »/« clean max »
            hero(reps: "5, 5, 5, 5+ AMRAP", locale: locale)   // freeText LONG (pire cas) → rétrécit/wrappe, pas de troncature
        }
        .frame(width: 360)
        .padding()
        .background(Color(uiColor: .systemBackground))
        .environment(\.locale, locale)
    }

    func testStrengthHero_fr() {
        assertSnapshot(of: heroColumn(locale: Locale(identifier: "fr")),
                       as: .image(precision: 0.99, perceptualPrecision: 0.97, layout: .sizeThatFits))
    }

    func testStrengthHero_en() {
        assertSnapshot(of: heroColumn(locale: Locale(identifier: "en")),
                       as: .image(precision: 0.99, perceptualPrecision: 0.97, layout: .sizeThatFits))
    }

    func testStrengthHero_es() {
        assertSnapshot(of: heroColumn(locale: Locale(identifier: "es")),
                       as: .image(precision: 0.99, perceptualPrecision: 0.97, layout: .sizeThatFits))
    }
}
