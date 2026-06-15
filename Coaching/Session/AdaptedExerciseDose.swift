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
    var effectiveDose: Dose? {
        dose ?? LegacyDoseMigration.dose(duration: duration, reps: reps)
    }

    func localizedDoseLabel(locale: Locale) -> String? {
        guard let dose = effectiveDose else { return nil }
        let base = DoseFormatter.string(dose, locale: locale)
        guard !base.isEmpty else { return nil }
        if let s = sets, s >= 2 { return "\(s) × \(base)" }
        return base
    }
}
