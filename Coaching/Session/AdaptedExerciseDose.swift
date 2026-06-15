import Foundation
import TemplateModel

// Chantier structuration i18n du dosage (party 2026-06-14, pilote yoga). Pont d'affichage
// entre le modèle `Dose` (TemplateModel, source unique `DoseFormatter` FR/EN/ES) et les
// vues : les 3 vues d'affichage du dosage (ExerciseTimelineCard, SessionFocusView,
// SessionOverviewList) appellent `localizedDoseLabel` AVANT le chemin legacy `reps`/`duration`.
extension AdaptedExercise {

    /// Libellé de dosage localisé via le modèle structuré, ou `nil` si l'exercice n'a pas de
    /// `dose` (sport pas encore migré → l'appelant garde le rendu legacy verbatim `reps`/
    /// `duration`). Préfixe « N × » si `sets >= 2` (ex. yoga : « 2 × 5 respirations »).
    /// Dose effective : le `dose` structuré si présent (contenu neuf, option A), sinon le backfill
    /// migration T3 (zéro dette) reconstruit depuis les strings legacy `duration`/`reps` des
    /// séances persistées AVANT le chantier (blob sans `dose`). nil = ni l'un ni l'autre → legacy.
    /// Sports dont le dosage a été structuré (chantier i18n : Lot 1 yoga, Lot 2 running).
    /// Le backfill `LegacyDoseMigration` ne s'applique QU'À ces sports — ailleurs un dosage
    /// legacy générique (« 12 », « 30 min », « 5 km »…) ne doit PAS être réinterprété : la
    /// muscu, p. ex., rend ses reps en affichage « héros » propre (party muscu) qu'on
    /// écraserait sinon. À étendre à chaque nouveau lot-sport.
    static let doseMigratedSports: Set<String> = ["yoga", "running"]

    func effectiveDose(sportCode: String?) -> Dose? {
        if let dose { return dose }   // contenu neuf (option A) : porte déjà son dose
        guard let sportCode, Self.doseMigratedSports.contains(sportCode) else { return nil }
        return LegacyDoseMigration.dose(duration: duration, reps: reps)
    }

    func localizedDoseLabel(sportCode: String?, locale: Locale) -> String? {
        guard let dose = effectiveDose(sportCode: sportCode) else { return nil }
        let base = DoseFormatter.string(dose, locale: locale)
        guard !base.isEmpty else { return nil }
        if let s = sets, s >= 2 { return "\(s) × \(base)" }
        return base
    }
}
