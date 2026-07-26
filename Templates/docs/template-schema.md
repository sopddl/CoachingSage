# Template Schema — CoachingSage

**Version courante** : `2` (`schema_version: 2`) — cf `Templates/Sources/TemplateModel/TemplateCoding.swift`.

**Note de portée (2026-07-26)** : cette doc couvre la structure de base + les hooks « v2 »
(`target_zone`, `required_equipment`, `incompatible_constraints`, `alternatives`, `volume_axis`,
`deload_weeks`). Elle ne couvre PAS les champs ajoutés par des chantiers ultérieurs et
indépendants (`dose` structuré i18n, `role`/`scaling_unit`/`priority`/`estimated_minutes` durée
réglable, `environment`/`variants` indoor-outdoor, `match_key`) — voir directement
`Templates/Sources/TemplateModel/ProgramTemplate.swift` pour l'état exhaustif à jour. Le champ
`week_structure` envisagé dans `template-schema-v2-draft.md` n'a **jamais été implémenté**
(décision de clôture 2026-07-26, cf ce fichier) — il n'existe nulle part, ni JSON ni Swift.

Format de stockage d'un `ProgramTemplate` bundled dans l'app iOS. Chaque template = 1 fichier JSON nommé `<id>.json` dans `Resources/Templates/`.

## Structure

```
ProgramTemplate (top-level)
├── weeks: [TemplateWeek]
│   └── sessions: [TemplateSession]
│       └── exercises: [TemplateExercise]
```

## Champs

### `ProgramTemplate`

| Champ JSON | Type | Obligatoire | Description |
|---|---|---|---|
| `id` | string | ✅ | kebab-case unique, ex: `running-beginner-5k-8sem` |
| `schema_version` | int | ✅ | Version du schéma utilisée. Actuellement `2`. |
| `sport` | enum string | ✅ | Un de : `running`, `cycling`, `swimming`, `triathlon`, `strength_training`, `yoga`, `hiit`, `hiking`, `tennis`, `football` |
| `level` | enum string | ✅ | Un de : `beginner`, `recreational`, `regular`, `competitive` |
| `name` | string | ✅ | Nom affiché à l'utilisateur |
| `duration_weeks` | int | ✅ | 1..52. Doit égaler `weeks.count` |
| `sessions_per_week` | int | ✅ | 1..14. Nombre de sessions actives (hors repos) par semaine |
| `default_objective` | string | ✅ | Objectif pour lequel le template est conçu |
| `assumed_profile` | string | ✅ | Profil générique cible (âge, condition, équipement assumé) |
| `summary` | string | ✅ | Résumé court du programme |
| `weeks` | [TemplateWeek] | ✅ | Détail semaine par semaine (toutes les semaines) |
| `safety_notes` | string | ✅ | Avertissements et signaux d'alerte |
| `progression_logic` | string | ✅ | Logique de progression du programme |
| `validated_at` | string (ISO8601) | ⛔️ | Date de validation humaine. `null` tant que non validé. |
| `validated_by` | string | ⛔️ | `"sophie"`, `"coach-<name>"` ou `"auto-claude-critic"` |
| `deload_weeks` | [int] | ⛔️ | Numéros de semaines décharge/taper — jamais densifiées par `DensityRule` (garde-fou G8). Généré par `scripts/densite_b/generate_deload_weeks.py`. |

### `TemplateWeek`

| Champ | Type | Obligatoire |
|---|---|---|
| `week_number` | int (1..N) | ✅ |
| `theme` | string | ✅ |
| `goal` | string | ✅ |
| `sessions` | [TemplateSession] | ✅ |

### `TemplateSession`

| Champ | Type | Obligatoire |
|---|---|---|
| `day` | int (1..7) | ✅ |
| `name` | string | ✅ |
| `duration_minutes` | int | ✅ |
| `type` | enum string | ✅ — un de : `endurance`, `interval`, `technique`, `strength`, `mixed`, `mobility`, `rest`, `other` |
| `warmup` | string | ⛔️ |
| `exercises` | [TemplateExercise] | ✅ (peut être vide pour `rest`) |
| `cooldown` | string | ⛔️ |

### `TemplateExercise`

| Champ | Type | Obligatoire |
|---|---|---|
| `name` | string | ✅ |
| `sets` | int | ⛔️ |
| `reps` | string | ⛔️ — string pour permettre des ranges (`"8-10"`) ou des précisions (`"12 par côté"`) |
| `duration` | string | ⛔️ — ex : `"5 min"`, `"1 min course + 2 min marche"` |
| `rest_seconds` | int | ⛔️ |
| `notes` | string | ⛔️ |
| `target_zone` | string | ⛔️ | Zone d'effort sport-spécifique (ex: `"Daniels-E"`, `"FTP-Z2"`, `"RPE 7-8"`). Rendu verbatim, glossaire. |
| `required_equipment` | [string] | ⛔️ | `[]` = bodyweight pur. |
| `incompatible_constraints` | [string] | ⛔️ | Contraintes profil qui invalident l'exercice ; consommé par `ConstraintSubstitutionRule`. |
| `alternatives` | [string] | ⛔️ | Exercices de repli piochés par l'algo quand une contrainte matche. |
| `volume_axis` | enum string | ⛔️ | `duration` \| `distance` \| `reps` \| `sets` \| `elevation` — ce que l'algo scale avec la fréquence/objectif. |

## Conventions d'encoding

- **Keys** : `snake_case` en JSON, `camelCase` en Swift (`JSONDecoder.keyDecodingStrategy = .convertFromSnakeCase`)
- **Dates** : ISO8601 (`validated_at`)
- **Nullable vs absent** : un champ optionnel peut être omis ou présent avec la valeur `null` ; les deux sont équivalents au décodage

## Règles de validation (`TemplateValidator`)

1. `schema_version` doit être égal à `TemplateCoding.currentSchemaVersion` (actuellement `2`)
2. `id`, `name` non vides
3. `duration_weeks` dans [1, 52]
4. `sessions_per_week` dans [1, 14]
5. `weeks.count == duration_weeks`
6. Les `week_number` sont uniques dans `weeks`
7. Dans une semaine, les sessions actives (`type != rest`) ≤ `sessions_per_week`
8. Les `day` sont uniques dans une semaine
9. `day` dans [1, 7]

## Évolution du schéma

À chaque changement breaking, incrémenter `currentSchemaVersion` et fournir un migrateur `Vn → Vn+1` dans `TemplateCoding`. Les templates stockés gardent leur `schema_version` d'origine jusqu'à migration.
