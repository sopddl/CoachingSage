# Template Schema — CoachingSage

**Version courante** : `1` (`schema_version: 1`)

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
| `id` | string | ✅ | kebab-case unique, ex: `running-debutant-5k-8sem` |
| `schema_version` | int | ✅ | Version du schéma utilisée. Actuellement `1`. |
| `sport` | enum string | ✅ | Un de : `running`, `musculation`, `natation`, `velo`, `triathlon`, `tennis`, `yoga`, `hiit`, `remise_en_forme`, `sports_collectifs` |
| `level` | enum string | ✅ | Un de : `debutant`, `intermediaire`, `avance`, `expert` |
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

## Conventions d'encoding

- **Keys** : `snake_case` en JSON, `camelCase` en Swift (`JSONDecoder.keyDecodingStrategy = .convertFromSnakeCase`)
- **Dates** : ISO8601 (`validated_at`)
- **Nullable vs absent** : un champ optionnel peut être omis ou présent avec la valeur `null` ; les deux sont équivalents au décodage

## Règles de validation (`TemplateValidator`)

1. `schema_version` doit être égal à `TemplateCoding.currentSchemaVersion` (actuellement `1`)
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
