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
    /// Sports dont le dosage a été structuré (chantier i18n : Lot 1 yoga, Lot 2 running,
    /// Lot 3 cycling, Lot 4 swimming, Lot 5 hiking, Lot 6 hiit). Le backfill `LegacyDoseMigration`
    /// ne s'applique QU'À ces sports — ailleurs un dosage legacy générique (« 12 », « 30 min »,
    /// « 5 km »…) ne doit PAS être réinterprété : la muscu, p. ex., rend ses reps en affichage
    /// « héros » propre (party muscu) qu'on écraserait sinon. À étendre à chaque nouveau lot-sport.
    static let doseMigratedSports: Set<String> = ["yoga", "running", "cycling", "swimming", "hiking", "hiit", "strengthTraining", "tennis", "football"]

    func effectiveDose(sportCode: String?) -> Dose? {
        if let dose { return dose }   // contenu neuf (option A) : porte déjà son dose
        guard let sportCode, Self.doseMigratedSports.contains(sportCode) else { return nil }
        return LegacyDoseMigration.dose(duration: duration, reps: reps)
    }

    func localizedDoseLabel(sportCode: String?, locale: Locale) -> String? {
        guard let dose = effectiveDose(sportCode: sportCode) else { return nil }
        // Muscu (Lot 7) : la party muscu veut un affichage reps minimal (« 3 × 12 »,
        // « 10 par côté »), pas « 3 × 12 reps » → rendu compact sans nom d'unité pour les
        // reps. Les autres sports gardent leur nom (« 9 km », « 5 respirations »).
        let base = (sportCode == "strengthTraining")
            ? DoseFormatter.repsCompactString(dose, locale: locale)
            : DoseFormatter.string(dose, locale: locale)
        guard !base.isEmpty else { return nil }
        if let s = sets, s >= 2 { return "\(s) × \(base)" }
        return base
    }

    /// Affichage « héros » muscu (mode Minuté, party reps-driven) : le chiffre SEUL localisé
    /// (« 10 », « 8-10 », ou freeText « max propre » traduit) + un drapeau latéralité. L'unité
    /// « reps » et le guidage côté sont rendus SÉPARÉMENT par la vue. Source unique du chiffre =
    /// le `dose` structuré → fini le strip-string `repsHero(from:)` qui laissait fuir « par
    /// jambe »/« par épaule » en EN/ES (non couverts par `localizedReps`). nil si l'exo n'a pas
    /// de reps OU si le dose n'est pas reps-based (tenue en secondes → la vue retombe sur le
    /// chrono/bigTime, comportement legacy préservé).
    func repsHeroDose(sportCode: String?, locale: Locale) -> (value: String, isLateral: Bool)? {
        guard let reps, !reps.isEmpty else { return nil }   // gate identique au héros legacy
        guard let dose = effectiveDose(sportCode: sportCode) else { return nil }
        switch dose {
        case .structured(let d) where d.unit == .reps:
            let lateral: Set<DoseQualifier> = [.perSide, .perLeg, .perArm, .perFoot, .perShoulder]
            return (d.value, d.qualifier.map(lateral.contains) ?? false)
        case .freeText(let ft):
            return (ft.resolved(locale), false)
        default:
            return nil   // tenue en secondes / intervalle → pas un héros reps
        }
    }
}
