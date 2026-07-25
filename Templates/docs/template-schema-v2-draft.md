# Template Schema v2 — Draft Story 0.5.10

**Status** : CLÔTURÉ 2026-07-26 (partiellement livré, cf note ci-dessous) — ne plus reprendre ce
draft comme référence active. Voir `template-schema.md` pour l'état réel du schéma en prod.

## ⚠️ Bilan de clôture (2026-07-26)

Ce draft proposait 2 catégories de hooks « v2 » : **exercise-level** (§ `TemplateExercise`) et
**template-level** (§ `ProgramTemplate` : `week_structure` + `deload_weeks`). Sort différent des
deux :

- **Hooks exercise-level** (`target_zone`, `required_equipment`, `incompatible_constraints`,
  `alternatives`, `volume_axis`) : ✅ **livrés** dans `f1fae57` (2026-05-02), consommés par
  `Coaching/Adapter/Rules/{ConstraintSubstitutionRule,EquipmentSubstitutionRule}.swift` et
  d'autres. C'est le scope réel de `schema_version: 2` aujourd'hui.
- **`deload_weeks`** : livré, mais pas par ce chantier — perdu au même moment que
  `week_structure` (voir plus bas), puis régénéré 2 mois plus tard par un chantier indépendant
  (« densité B », `Templates/scripts/densite_b/generate_deload_weeks.py`) qui ignorait que l'IA
  avait déjà produit une version de ce champ ici.
- **`week_structure`** (`type`/`micro_pattern`/`recovery_cadence`) : **abandonné, jamais livré**.
  Généré par l'IA sur les 40 templates en 0.5.10 (`raw-v2/*.json`), mais le bundling prod
  (`f1fae57`) a scopé le modèle Swift aux seuls hooks exercise-level sans reprendre ce champ —
  le round-trip JSON→Swift→JSON l'a donc fait disparaître silencieusement (Codable ignore les
  clés JSON sans propriété correspondante). Aucun code consommateur n'a jamais été construit
  (pas de « règle de périodisation » dans l'Adapter) — absence 100% inerte, aucun bug actif.
  **Décision Sophie 2026-07-26 : ne pas ressusciter.** Rien ne le consomme, aucune règle
  d'adaptation par périodisation n'a été reprise dans les AC réelles qui ont guidé
  l'implémentation de l'Adapter (Story 3.3a) — le faire revivre sans consommateur serait de la
  dette (donnée sans usage). Si le besoin réapparaît un jour, les données sources existent
  toujours dans l'historique git (`git show e0ad6ec:Templates/References/raw-v2/<id>.json`)
  pour les 40 templates, pas besoin de les regénérer.

---

**Cible** : `schema_version: 2` après validation pilote ; rétrocompatibilité `v1` maintenue tant que tous les templates ne sont pas regenérés.

## Pourquoi v2

Story 0.5.10 ajoute des **hooks metadata** indispensables à l'algo deterministic (Story 3.3a `ProgramAdapter.adapt(template:profile:)`). Sans ces hooks structurés, l'algo ne peut pas :

1. Substituer un exercice quand une contrainte utilisateur est rencontrée (`incompatibleConstraints` + `alternatives`).
2. Filtrer les exercices selon l'équipement disponible (`requiredEquipment`).
3. Pacer les efforts selon la doctrine du sport et le niveau (`targetZone` — Daniels VDOT, Coggan FTP, Maglischo CSS, Israetel %1RM, etc.).
4. Moduler le volume selon la fréquence demandée par l'utilisateur (`volumeAxis`).
5. Ajuster la périodisation (`weekStructure`, `deloadWeeks`).

## Changements v1 → v2

### Niveau `ProgramTemplate` (template-level)

Nouveaux champs **OPTIONNELS** (rétrocompatibles v1) :

| Champ JSON | Type | Description |
|---|---|---|
| `week_structure` | object | Pattern structurel des semaines (cf. ci-dessous) |
| `deload_weeks` | [int] | Numéros des semaines de cutback/deload (ex: `[5]` pour W5 cutback dans un plan 8 sem) |

`week_structure` :
```json
{
  "type": "linear" | "block" | "undulating" | "polarized",
  "micro_pattern": "Z1/Z2/Z2/Z3/long",  // pattern type d'une semaine
  "recovery_cadence": "1 deload toutes les 4 semaines"
}
```

`progression_logic` (existant string) : conservé pour la prose lisible humain. La structure `week_structure` + `deload_weeks` sert de version structurée parseable par l'algo.

### Niveau `TemplateExercise` (exercise-level)

Nouveaux champs **OPTIONNELS** :

| Champ JSON | Type | Description |
|---|---|---|
| `target_zone` | string | Zone d'effort sport-spécifique (ex: `"Daniels-E"`, `"Daniels-T"`, `"Z2 FTP"`, `"CSS+5s/100m"`, `"RPE 7-8"`, `"RIR 2-3"`, `"@10K pace"`, `"@MP - 10s/km"`) |
| `required_equipment` | [string] | Liste exhaustive (kebab-case standardisé) ; `[]` = bodyweight pur |
| `incompatible_constraints` | [string] | Contraintes utilisateur qui invalident cet exercice (ex: `"knee-injury"`, `"shoulder-injury"`, `"no-equipment"`) |
| `alternatives` | [string] | Noms d'exercices substitutifs ; l'algo pioche dedans quand contraintes hit |
| `volume_axis` | enum string | `"duration"` \| `"distance"` \| `"sets"` \| `"reps"` — ce que l'algo scale avec la fréquence/objectif |

### Vocabulaire `required_equipment` (kebab-case)

**Running** : `running-shoes` (assumé partout — peut être omis).
**Cycling** : `road-bike`, `mtb`, `indoor-trainer`, `power-meter`, `helmet`.
**Swimming** : `pool`, `pull-buoy`, `kickboard`, `fins`, `swim-paddles`, `goggles`.
**Strength** : `barbell`, `dumbbells`, `kettlebell`, `rack`, `bench`, `pullup-bar`, `cable-machine`, `resistance-band`, `box`.
**Yoga** : `mat`, `yoga-block`, `strap`, `bolster`.
**HIIT** : `box`, `kettlebell`, `medicine-ball`, `jump-rope`, `dumbbells`.
**Hiking** : `trekking-poles`, `hiking-shoes`, `backpack`.
**Tennis** : `racket`, `balls`, `court`, `wall`.
**Football** : `cleats`, `cones`, `field`, `agility-ladder`.
**Triathlon** : combine cycling + swimming + running.

### Vocabulaire `incompatible_constraints` (kebab-case)

Lié au questionnaire onboarding (Story 2.2 + SportQuestionnaire Story 3.1+) :
- Blessures : `knee-injury`, `shoulder-injury`, `lower-back-pain`, `ankle-injury`, `wrist-pain`, `cervical-pain`.
- Équipement : `no-equipment`, `no-pool-access`, `no-bike`, `home-only`, `apartment-noise`.
- Conditions : `pregnancy`, `postpartum-early`, `cardiac-clearance-required`.
- Niveau : `beginner-only`, `competitive-only`.

### Vocabulaire `target_zone` (sport-spécifique)

Doit être documenté dans le master prompt par sport. Convention : indiquer le **système de zone** + valeur.

**Running (Daniels VDOT)** : `Daniels-E` (easy), `Daniels-M` (marathon), `Daniels-T` (threshold), `Daniels-I` (interval/VO2max), `Daniels-R` (repetition). Possibilité allure cible : `@10K-pace`, `@MP-10s/km`.

**Cycling (Coggan FTP)** : `FTP-Z1` (recovery), `FTP-Z2` (endurance), `FTP-Z3` (tempo), `FTP-Z4` (threshold), `FTP-Z5` (VO2max), `FTP-Z6` (anaerobic).

**Swimming (Maglischo CSS)** : `CSS+5s/100m`, `CSS-2s/100m`, `CSS race-pace`, `EN1/EN2/EN3` (endurance), `SP1/SP2/SP3` (sprint). Drills : `technique` (pas de zone).

**Strength (Israetel %1RM + RPE)** : `RPE 6-7`, `RPE 7-8`, `RPE 8-9`, `RIR 2-3`, `%1RM 70-75%`, `%1RM 80-85%`. Hypertrophie : 6-12 reps RPE 7-9 ; force : 1-5 reps RPE 7-9.

**Yoga** : pas de zone d'effort cardiaque ; utiliser `breath-led`, `hold-30s`, `hold-60s`, `flow`, `restorative`.

**HIIT** : ratios travail/repos + RPE (`Tabata 20/10 RPE 9`, `30/30 RPE 8`, `EMOM RPE 7-8`).

**Triathlon** : combine zones running + cycling + swimming.

**Hiking** : `RPE 4-5` (conversational), `RPE 6-7` (sustained climbing), gradient + altitude si pertinent.

**Tennis / Football** : `Z1/Z2 aérobie`, `Z3/Z4 alactique`, `RPE`, intermittences `30s ON / 30s OFF` etc.

## Évolution Swift `TemplateModel`

Modifications minimales (champs optionnels, rétrocompatibles) :

```swift
public struct TemplateExercise: Codable, Equatable, Sendable {
    public let name: String
    public let sets: Int?
    public let reps: String?
    public let duration: String?
    public let restSeconds: Int?
    public let notes: String?
    // V2 hooks (optional)
    public let targetZone: String?
    public let requiredEquipment: [String]?
    public let incompatibleConstraints: [String]?
    public let alternatives: [String]?
    public let volumeAxis: VolumeAxis?  // new enum
}

public enum VolumeAxis: String, Codable, Sendable {
    case duration, distance, sets, reps
}

public struct WeekStructure: Codable, Equatable, Sendable {
    public let type: ProgressionType  // new enum
    public let microPattern: String
    public let recoveryCadence: String
}

public enum ProgressionType: String, Codable, Sendable {
    case linear, block, undulating, polarized
}

public struct ProgramTemplate: Codable, Equatable, Sendable {
    // ... existing fields ...
    // V2 hooks (optional)
    public let weekStructure: WeekStructure?
    public let deloadWeeks: [Int]?
}
```

## Migration

1. **Phase A.1 (cette story)** : design v2 documenté (ce fichier).
2. **Phase B (pilote running)** : 4 templates running regenérés avec hooks v2 → review agent → itération.
3. **Phase C (cascade)** : 36 autres templates regenérés v2.
4. **Phase D** : tous les 40 templates ont les hooks → bump `currentSchemaVersion = 2`, validator stricte.
5. **Phase E** : commit final, merge main, ancienne v1 désactivée.

## Tests

- `RoundTripTests` : encode/decode v2 templates avec hooks.
- `TemplateValidatorTests` : v2 strict (hooks requis), v1 toléré jusqu'à fin Phase C.
- `TemplateLoaderTests.testProductionBundleLoads40Templates` : ajouté Phase D.

---

**Last revised** : 2026-04-30 (Story 0.5.10 kickoff).
