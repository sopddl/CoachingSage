# Story 3.31 — Routine cyclique 3 mois + renouvellement (Option A)

**Branche** : `epic-3/story-3.31-routine-cycle-regen`
**Statut** : ready-for-dev
**Trigger** : Sophie 2026-06-01 — « ON SCOPE routine option A ». Reprise du **T5 différé** de la
story sœur (cf mémoire `epic3_sister_story_done.md` § Hors scope) et du chantier
`routine_via_freq_onboarding_comment_ca_marche.md` (MAJ 2026-05-10 soir, point 2 « Mode routine —
durée et regénération » + point 4 « UX fin de programme »).

## Le problème produit

Une **routine** (`ProgramDurationMode.routineCyclic`) = programme sans date cible, pensé pour
s'entretenir « à ton rythme ». La story sœur a livré la **génération initiale** : 12 semaines fixes,
template cyclé depuis la semaine 1. Mais **rien ne se passe à la fin du cycle** :

- À 100 % de complétion, `DefaultAdaptedProgramRepository` **auto-archive en silence**
  (`isActive = false` + `archivedAt`). La routine **disparaît du dashboard** → l'utilisateur qui
  voulait s'entretenir « sans fin » se retrouve devant un dashboard vide. **Trou logique V1.**
- `cycleNumber` (champ `AdaptedProgramRecord`) existe mais **dormant** : jamais incrémenté.
- L'infra regen de la Story 3.4 (`WeeklyRegenApplicationService`) ne traite que l'ajustement
  **hebdomadaire** de volume ; **aucun hook de fin de cycle**.

**Objectif de la story** : à l'approche de la fin d'un cycle routine, proposer à l'utilisateur de
**renouveler** la routine pour 3 mois supplémentaires, **adaptés à ses progrès** des 12 dernières
semaines. Cycle continu, jamais de fin sauf désactivation explicite.

## Décisions produit (Sophie, 2026-06-01)

1. **Push notif différée à Epic 5.** V1 = **hint dashboard seul**. L'utilisateur ouvre l'app → voit
   la carte « Léon prépare la suite » → valide. Pas d'`UNUserNotificationCenter` dans cette story
   (déjà cadré Epic 5 dans `NotificationPreferences.swift`).
2. **Adaptation = algo deterministic sur 3 mois.** On agrège les rapports d'exécution des 12 semaines
   via `WeeklyExecutionAnalyzer` → un **multiplier de cycle** (volume/difficulté du prochain cycle).
   RPE bas + complétion haute → cycle suivant plus ambitieux ; RPE haut + complétion basse → allégé.
   Cohérent avec le pivot algo-first (pas d'IA Léon, qui était dead en V1 cf `epic3_story33b_done`).
3. **Déclencheur = J−14 / début de la semaine 11** (sur 12). 2 semaines avant la fin → la carte de
   renouvellement apparaît. L'utilisateur valide pendant qu'il a encore des séances → **pas de trou**.
4. **Validation explicite** : le cycle suivant n'est **jamais** généré automatiquement. L'utilisateur
   doit **taper** pour confirmer (« Génère la suite »). Tant qu'il ne valide pas, la routine continue.

## État de l'existant (audit code 2026-06-01)

| Pièce | Fichier | État |
|---|---|---|
| `ProgramDurationMode.routineCyclic` | `Coaching/Adapter/AdaptedProgram.swift:17-21` | ✅ DONE |
| Cycle 12 sem depuis week 1 | `Coaching/Adapter/ProgramDurationResolver.swift` (`resolve()` → `(12, nil)`, `resize()` cycle+renumber) | ✅ DONE — réutilisable tel quel pour regénérer |
| `cycleNumber` | `Coaching/Persistence/AdaptedProgramRecord.swift:134` | 💤 dormant (init 1, jamais incrémenté) |
| `targetDate` (nil pour routine) | `AdaptedProgramRecord.swift:129` | ✅ DONE |
| Infra regen hebdo | `Coaching/Regen/WeeklyRegenApplicationService.swift` (`checkAndApplyIfDue`), déclenchée par `SessionDashboardViewModel.refresh()` → `runAutoRegenIfNeeded` | ⚙️ hebdo only, pas de hook fin de cycle |
| Agrégateur exécution | `Coaching/Regen/WeeklyExecutionAnalyzer.swift` + `WeeklyExecutionReportRecord` (@Model) | ✅ réutilisable pour agréger 12 sem |
| Auto-archive 100 % | `Repositories/Implementations/DefaultAdaptedProgramRepository.swift:148-157` | ⚠️ **à brancher** : ne PAS archiver une routine, basculer en « renouvellement prêt » |
| Surface badge/hint | `Coaching/Dashboard/RegenBadge.swift` + `Views/Screens/Dashboard/ActiveDashboardView.swift` (`RegenBadgePill` dans `ProgramCard`) | ✅ pattern prouvé, à étendre pour le hint renouvellement |
| Push / local notif | `Models/NotificationPreferences.swift` (struct seul) | ❌ absent — **hors scope** (Epic 5) |

## Architecture proposée

### Data model — incrémenter `cycleNumber` (pas de migration lourde)

Le champ existe déjà (`AdaptedProgramRecord.cycleNumber`, SchemaV6+). Pas de nouvelle migration.
Le renouvellement **réutilise le même record** (même `id`, même programme actif) et :
- incrémente `cycleNumber` (+1),
- remplace les `sessions` par le nouveau cycle regénéré,
- réinitialise le `completionState` / `currentWeekNumber` à la semaine 1,
- met à jour `updatedAt`.

> Alternative écartée : créer un nouveau record par cycle. Rejeté car ça multiplie les cards
> dashboard et casse la continuité « c'est la même routine ».

### `RoutineCycleService` (nouveau, `@MainActor`, dans `Coaching/Regen/`)

Responsable du cycle de vie de fin de routine. Deux responsabilités :

1. **`renewalState(for:) -> RoutineRenewalState`** — calcule l'état d'une routine active :
   - `.notDue` : avant la semaine 11.
   - `.due(cycleNumber:)` : semaine ≥ 11 et < fin → on affiche le hint « Léon prépare la suite ».
   - `.cycleCompleted` : 100 % atteint sans renouvellement validé → on **maintient la routine
     visible** (pas d'archive) avec CTA « Génère la suite ».
   - Ne s'applique **qu'aux** records `durationMode == .routineCyclic`. Les `deadlineFixed` /
     `deadlineEstimated` gardent l'auto-archive actuelle.

2. **`renew(record:) async throws`** — génère le cycle suivant :
   - Agrège les `WeeklyExecutionReportRecord` des 12 dernières semaines → `WeeklyExecutionAnalyzer`
     (ou un nouvel agrégateur `CycleExecutionAnalyzer` qui réutilise sa logique de multiplier sur la
     fenêtre cycle au lieu de S→S+1).
   - Calcule un **`cycleMultiplier`** (volume/difficulté).
   - Relance le `ProgramAdapter` sur le **même template** + multiplier de cycle → nouvel
     `AdaptedProgram` 12 sem (via `ProgramDurationResolver.resize()`, déjà cyclique).
   - Écrit le résultat dans le record existant (`cycleNumber += 1`, sessions remplacées,
     completion reset, `updatedAt`).
   - Idempotent : un guard (journal ou flag `cycleNumber`) empêche un double renouvellement.

### Garde-fou auto-archive (modif `DefaultAdaptedProgramRepository`)

Le bloc auto-archive (ligne ~148-157) doit **exclure** les routines :

```swift
if record != nil,
   programRecord.completionState.completedCount == programRecord.sessions.count,
   !programRecord.sessions.isEmpty,
   programRecord.durationMode != .routineCyclic {   // ← routines ne s'auto-archivent jamais
    programRecord.isActive = false
    programRecord.archivedAt = Date()
}
```

> Une routine ne s'archive que sur action explicite de désactivation (mécanique existante de
> suppression/désactivation de programme — à vérifier qu'elle reste accessible).

### UI — hint de renouvellement (étendre `ProgramCard` / `RegenBadgePill`)

- Réutiliser la surface badge prouvée. Nouveau composant **`RoutineRenewalCard`** (ou variante du
  `RegenBadgePill`) affiché dans `ProgramCard` quand `renewalState == .due` ou `.cycleCompleted` :
  - icône `sparkles`, texte « Léon prépare la suite de ta routine selon tes progrès »,
  - CTA « Génère la suite » → appelle `RoutineCycleService.renew(record:)`,
  - état loading pendant la génération (algo local = rapide, mais garder un spinner défensif),
  - après succès : toast/feedback « Nouveau cycle prêt » + dashboard se rafraîchit sur la semaine 1.
- Le hint `.due` est **non-bloquant** (la routine continue) ; `.cycleCompleted` est plus proéminent
  (la routine est à court de séances mais reste visible — pas de dashboard vide).

### Wiring

- `SessionDashboardViewModel.refresh()` : après `runAutoRegenIfNeeded`, calculer
  `routineRenewalStatesByRecord` via `RoutineCycleService.renewalState(for:)`, exposé à
  `ActiveDashboardView` comme `regenBadgesByRecord` aujourd'hui.
- `RoutineCycleService` injecté dans `AppDependencies` (même pattern que
  `WeeklyRegenApplicationService`).

## Acceptance Criteria

1. **AC1 — Hint J−14** : étant donné une routine active `routineCyclic` en semaine 11/12, quand
   j'ouvre le dashboard, **alors** une carte « Léon prépare la suite de ta routine selon tes
   progrès » s'affiche sur la card de la routine, avec un CTA « Génère la suite ». En semaine ≤ 10,
   aucune carte.
2. **AC2 — Pas d'auto-archive routine** : étant donné une routine `routineCyclic` à 100 % de
   complétion, **alors** elle reste **visible** sur le dashboard (`isActive == true`), avec la carte
   de renouvellement proéminente. Un programme `deadlineFixed`/`deadlineEstimated` à 100 % continue
   de s'auto-archiver comme avant (non-régression).
3. **AC3 — Renouvellement adapté** : quand je tape « Génère la suite », **alors** un nouveau cycle de
   12 semaines est généré sur le même template, `cycleNumber` est incrémenté de 1, la complétion
   repart à la semaine 1, et la difficulté/volume du nouveau cycle reflète mes 12 dernières semaines
   (RPE + taux de complétion → multiplier). Le record est le **même** (pas de nouvelle card).
4. **AC4 — Validation explicite** : tant que je ne tape pas le CTA, aucun nouveau cycle n'est généré
   automatiquement. La génération est **idempotente** (re-tap pendant le chargement ou double refresh
   ne crée pas 2 cycles).
5. **AC5 — i18n FR/EN** : tous les libellés ajoutés (hint, CTA, toast) sont localisés FR + EN dans
   `Localizable.xcstrings`, sans clé interpolée (cf anti-pattern `hotfix_2026_05_12_adapted_program_i18n`).
6. **AC6 — Non-régression** : la génération initiale d'une routine (story sœur) et la regen hebdo
   (Story 3.4) restent intactes. Les `deadlineFixed/Estimated` ne voient aucun changement.

## Tâches (découpage indicatif)

| # | Tâche | Détail |
|---|---|---|
| T1 | `CycleExecutionAnalyzer` (ou extension `WeeklyExecutionAnalyzer`) | Agrège les `WeeklyExecutionReportRecord` sur la fenêtre 12 sem → `cycleMultiplier`. Tests unitaires sur les bornes (RPE bas/haut, complétion 100/50/0 %). |
| T2 | `RoutineCycleService` | `renewalState(for:)` + `renew(record:)`. Réutilise `ProgramAdapter` + `ProgramDurationResolver.resize()`. Guard idempotence. Tests. |
| T3 | Garde-fou auto-archive | Exclure `routineCyclic` du bloc auto-archive `DefaultAdaptedProgramRepository`. Test non-régression deadline. |
| T4 | Wiring VM + DI | `SessionDashboardViewModel.refresh()` calcule `routineRenewalStatesByRecord` ; `RoutineCycleService` dans `AppDependencies`. Tests VM. |
| T5 | UI `RoutineRenewalCard` | Carte dans `ProgramCard` (états `.due` / `.cycleCompleted`), CTA + loading + feedback succès. |
| T6 | i18n FR/EN | Clés hint + CTA + toast, FR + EN, vérif locale EN. |
| T7 | ui-reviewer + test manuel | Process UI obligatoire (CLAUDE.md). Scénario simu : seeder une routine en semaine 11 (param de debug si besoin) → vérifier carte + génération + reset semaine 1 + cycleNumber. |

## Estimation

**~3-4 j** (algo local, pas de push notif, réutilisation forte de l'infra 3.4 + resolver existant).

## Hors scope (différé)

- **Push notif / local notif** « Léon prépare la suite » → **Epic 5** (Notifications & Engagement).
- **IA Léon** pour le renouvellement (Edge Function) → V2, si l'algo deterministic montre ses limites.
- **Écran fin de programme `deadlineFixed`** (« Bravo, course dans X jours, tapering ») — c'était
  l'autre moitié du T5 mais concerne les modes deadline, pas la routine. À scoper séparément.
- **Switch UI a posteriori** routine ↔ deadline sur un programme existant.

## Pré-requis / liens

- Mémoires : `epic3_sister_story_done` (T5 source), `routine_via_freq_onboarding_comment_ca_marche`
  (spec produit), `epic3_leon_algo_first` (pivot algo), `epic3_story33b_done` (Léon V1 dead → pas
  d'IA), `hotfix_2026_05_12_adapted_program_i18n` (anti-pattern i18n).
- Infra réutilisée : `WeeklyExecutionAnalyzer`, `ProgramAdapter`, `ProgramDurationResolver.resize()`,
  `RegenBadgePill`/`ProgramCard`.
