# Story 3.11 — Blocage doux fin de semaine + bouton Replanifier (Epic 3)

Status: ready-for-dev
Branche cible : `epic-3/story-3.11-blocage-doux-replanifier`
Effort estimé : **~3-3.5j** (dev solo) — révisé post-review architecte 2026-05-17

## Story

**As a** utilisateur CoachingSage qui suit un programme calendarisé et qui rate parfois une séance (boulot, fatigue, voyage, maladie),
**I want** que l'app ne me fasse PAS de pression "tu as raté" : la semaine 2 ne démarre pas tant que j'ai pas fini ma semaine 1, ET si j'ai un imprévu réel je peux explicitement décaler ma semaine sans culpabiliser,
**so that** la progression reste douce, l'app respecte mon rythme réel, et le moteur d'adaptation ne change pas mon programme à cause d'**un** événement isolé.

## Contexte produit

- **Constat user** (Sophie, test simu post-merge story sœur 3.z, 2026-05-17) : aujourd'hui, une séance non complétée à date passée **disparaît du dashboard** (filtre `date >= startOfDay` dans `NextSessionResolver.swift:54`). Résultat : l'user qui rate une séance ne la voit plus, et l'app passe silencieusement à la suivante. Anti-pattern.
- **Vision Sophie** (2026-05-17 — cf. mémoire [[backlog_dashboard_seances_refonte_2026_05_17]]) : "bloque doucement" — la prochaine séance reste celle qu'on a loupée, on attend qu'elle soit rattrapée avant de passer à la suivante.
- **Bouton Replanifier** (Sophie 2026-05-17) : soupape explicite pour les imprévus (malade, voyage, boulot). 2 actions :
  - "Reporter cette séance" → glisse 1 séance en avant (en fin de semaine bloquante OU 1ʳᵉ position S+1 si pas de place)
  - "Décaler ma semaine" → date picker "tu reprends quand ?" → toute la semaine décalée à cette date
- **Principe Sophie récurrent** : on n'ajuste pas le programme sur **un** événement isolé. Récurrence avérée (2+ semaines consécutives sub-seuil) = ajustement. Code Phase B déjà conforme (`PauseDetector.swift:19-21` : `light` / `moderate` / `extended` selon `consecutiveLowWeeks`).
- **Routine 3 mois cyclique (`ProgramDurationMode.routineCyclic`)** : PAS de calendrier. Pool ordonné de séances, prochaine séance reste affichée tant que pas faite. **Le blocage doux et le bouton Replanifier ne s'appliquent PAS aux routines** (pas de semaines à bloquer ni à décaler).
- **Décision shift week + journal regen** (Sophie 2026-05-17 — option C) : on **ne supprime PAS** les `RegenJournalEntry` historiques post-shift. À la place, on ajoute un champ `shiftGeneration: Int` (incrémenté à chaque shift) à la clé d'idempotence du journal. Les entries historiques restent figées (= principe "garder figé"). Les nouvelles regen post-shift trouvent leur place sans collision.

## Acceptance Criteria

### Partie (a) — Blocage doux : NextSessionResolver

1. **AC1** — `NextSessionResolver.next(in: AdaptedProgramRecord)` (`Coaching/Dashboard/NextSessionResolver.swift`) ajoute la logique "semaine bloquante" pour programmes dont `durationMode ∈ {.deadlineFixed, .deadlineEstimated}` ET `mode == .planned` :
   - Calculer `currentWeekNumber = floor((Date() - weekStartDate) / 7 days) + 1`.
   - Pour chaque semaine `N <= currentWeekNumber`, si elle contient au moins une séance non complétée → cette séance (la plus ancienne par `(weekNumber, day)`) **devient la prochaine affichée**, indépendamment de sa `plannedDate`.
   - La semaine `N+1` ne devient "active" pour le résolveur QUE quand toutes les séances de N sont complétées.
2. **AC2** — Pour `durationMode == .routineCyclic` : comportement actuel **inchangé**. Pas de blocage doux, tri par `(weekNumber, day)`, première non complétée du pool.
3. **AC3** — Pour `mode == .ondemand` non-cyclique : pas de filtre date (comportement actuel préservé — pas touché par cette story, AC1 ne s'applique qu'à `.planned`).
4. **AC4** — Programme dormant (`weekStartDate == nil`, cf Story 3.10 AC1) : `next(in:)` retourne `nil`. La NextSessionCard affiche "Non commencé" (couvert par Story 3.10 AC24).
5. **AC5** — Tests `NextSessionResolverTests` couvrent :
   - Programme `.deadlineFixed + .planned`, S1 incomplète, date courante = S+2 → prochaine = séance restante de S1 (test `testBlocksOnIncompleteWeek_Planned`).
   - Programme `.deadlineFixed + .planned`, S1 complète, date courante = S+2 → prochaine = première séance de S2.
   - Programme `.deadlineEstimated + .planned`, idem.
   - Programme `.routineCyclic`, comportement inchangé.
   - Programme `.ondemand` non-cyclique, comportement inchangé.
   - Programme `.deadlineFixed + .planned`, S1 contient une séance avec `plannedDate == nil` (= mode mixte introduit par "Reporter cette séance" AC12-13), date courante = S+2 → résolveur la prend en compte comme séance bloquante (test `testBlocksOnSessionWithoutPlannedDate_PlannedMode`).

### Partie (b) — Affichage état "en retard"

6. **AC6** — Ajouter computed `nextSessionIsLate: Bool` à `ProgramSummary` (struct introduite par Story 3.10 AC21) :
   - `true` si la prochaine séance appartient à une semaine `N < currentWeekNumber` (semaine bloquante) ET `durationMode ∈ {.deadlineFixed, .deadlineEstimated}`.
   - `false` pour routine cyclique, dormant, ondemand pur.
7. **AC7** — Dans `NextSessionCard` (Story 3.10 AC24), si `nextSessionIsLate == true` :
   - Badge léger "En retard" : utiliser **`Color.coachingWarning`** (existe `Views/Theme/Color+Coaching.swift`, utilisé `ProfileView:217`). **Ne PAS utiliser** `Color.sageAccentWarning` (n'existe pas dans CoachingSage).
   - Sous-titre "Cette séance était prévue semaine du **{date début semaine}**", date formatée via `DateFormatter` style absolu :
     - FR : `"EEEE d MMMM"` (ex: "lundi 12 mai")
     - EN : `"EEEE, MMMM d"` (ex: "Monday, May 12")
   - Le bouton "Démarrer" reste actif (l'user peut toujours rattraper).
8. **AC8** — Sur `ProgramCard` du carrousel (Story 3.10 AC23), si `nextSessionIsLate == true` : indicateur visuel discret (badge "Semaine X en attente" en bas de la card, `Color.coachingWarning`, font caption2). Pas plus pour ne pas alourdir.

### Partie (c) — Bouton Replanifier

9. **AC9** — Dans `NextSessionCard`, **si** `nextSessionIsLate == true` ET `durationMode ∈ {.deadlineFixed, .deadlineEstimated}` (donc PAS routineCyclic) : ajouter bouton secondaire **"Replanifier"** à droite du bouton primary "Démarrer".
10. **AC10** — Tap "Replanifier" → ouvre `ReplanifySheet` (nouvelle sheet SwiftUI) avec `.presentationDetents([.medium, .large])` (medium par défaut, expandable si user veut plus).
11. **AC11** — Contenu sheet :
    - Titre : "Tu n'as pas pu faire ta séance ?"
    - Sous-titre : "Pas de souci, voici 2 façons de t'adapter."
    - Bouton 1 (rectangulaire, full-width, secondary) : **"Reporter cette séance"** — *"Cette séance passe en fin de semaine."*
    - Bouton 2 (rectangulaire, full-width, secondary) : **"Décaler ma semaine"** — *"J'ai eu un imprévu (malade, voyage). Reprends quand je te dis."*
    - Bouton tertiaire "Annuler" (text-only, en bas) → ferme sheet.

### Partie (d) — Action "Reporter cette séance"

12. **AC12** — Action "Reporter cette séance" :
    1. Identifier la séance courante via `NextSessionResolver.next(in: record)` (= séance la plus ancienne non complétée de la semaine bloquante).
    2. Calculer `maxDayInWeek = record.sessions.filter { $0.weekNumber == session.weekNumber }.map { $0.day }.max() ?? 7`.
    3. Si `maxDayInWeek < 7` : déplacer la séance à `day = maxDayInWeek + 1`, **conserver son `weekNumber`** (= reste dans la semaine bloquante mais en fin).
    4. Si `maxDayInWeek == 7` : **fallback semaine suivante** (décision Sophie 2026-05-17 reco B) — déplacer la séance à `weekNumber = currentWeek + 1, day = 1` (1ʳᵉ position S+1).
    5. Si la séance a une `plannedDate`, la **nullifier** (`plannedDate = nil`) car elle ne correspond plus à un jour spécifique.
    6. Save le `AdaptedProgramRecord` via `repository.update(record)`.
13. **AC13** — Tolérance mode mixte : nullifier `plannedDate` sur 1 session isolée d'un programme `.planned` est **accepté** — le record reste en mode `.planned` (pas de débasculement vers `.ondemand`). Le résolveur en mode `.planned` gère déjà les sessions sans plannedDate (cf comportement existant).
14. **AC14** — Sheet se ferme, dashboard refresh, la séance reportée apparaît en fin de liste de la semaine (ou 1ʳᵉ position S+1 si débordement) — l'user voit le résultat.

### Partie (e) — Action "Décaler ma semaine"

15. **AC15** — "Décaler ma semaine" → ouvre `DatePicker` iOS natif (modal compact ou wheel) avec contrainte `in: Date()...` (pas de date passée). Titre du picker : "Tu reprends quand ?".
16. **AC16** — Date sélectionnée — algorithme **"recadrer la semaine en cours sur la nouvelle date"** (décision Sophie 2026-05-17, préserve la progression) :
    1. Calculer `pickedWeekStart = lundi de la semaine de la date choisie` (ISO firstWeekday=2).
    2. **Calculer `currentWeekNumber` AVANT mutation** : `floor((Date() - record.weekStartDate) / 7 days) + 1` (la semaine où l'user était au moment du shift).
    3. **Calculer `newWeekStartDate = pickedWeekStart - (currentWeekNumber - 1) * 7 jours`**. Sémantique : la semaine en cours (S = `currentWeekNumber`) tombe désormais sur `pickedWeekStart`. Les semaines passées (S1, S2, …) restent passées, leur progression est préservée. Les semaines futures (S+1, S+2…) sont elles aussi décalées du même offset.
    4. **No-op si `newWeekStartDate == record.weekStartDate`** (l'user a choisi la même semaine ISO que celle en cours) → sheet ferme, pas d'incrément `shiftGeneration`, pas d'update repo.
    5. Sinon : mute `record.weekStartDate = newWeekStartDate`, incrémente `record.shiftGeneration += 1` (champ introduit par Story 3.10 AC1), save via `repository.update(record)`.
17. **AC17** — Décalage **ne touche pas** les `plannedDate` des sessions individuelles (elles restent figées sur leurs anciennes dates absolues). Si un user a drag&dropé une session sur une date spécifique, cette `plannedDate` est désormais désalignée avec le `weekNumber + weekStartDate` du record — comportement attendu V1 (le user qui shift accepte que ses ajustements manuels par drag&drop soient désalignés ; à clarifier dans le CTA "tes ajustements manuels par drag&drop pourraient ne plus tomber au bon jour"). Le résolveur en mode `.planned` ignore alors la `plannedDate` désynchro et utilise le tri `(weekNumber, day)` comme fallback (cohérent avec AC13 tolérance mode mixte).
18. **AC18** — Cohérence regen Phase B post-shift (le champ `shiftGeneration: Int` est **déjà introduit côté `RegenJournalEntry` par Story 3.10 AC1** — cette story le câble dans la logique service) :
    - **`WeeklyRegenApplicationService.checkAndApplyIfDue`** : la check d'idempotence existante (fetch journal entries par `(recordId, targetWeekNumber)`) devient `(recordId, targetWeekNumber, shiftGeneration)`. C'est-à-dire : on cherche si une entry existe avec **le `shiftGeneration` courant du record**. Entries pour `shiftGeneration` antérieurs sont ignorées pour la check d'idempotence (mais conservées pour l'historique badges).
    - **`RegenJournalEntry` écrites post-shift** portent le `shiftGeneration` courant du record (passé en argument au moment de l'écriture).
    - Résultat : un user qui shift sa semaine peut re-recevoir des regen sur les mêmes `weekNumber` post-shift, sans collision avec l'historique.
19. **AC19** — Sheet ferme, dashboard refresh, la prochaine séance affichée perd son badge "En retard" (la semaine N redémarre à la nouvelle date).
20. **AC20** — Le `lastUpdatedAt` du record est mis à jour par le repo (comportement existant). Le programme remonte en tête du tri secondaire `lastUpdatedAt desc` du carrousel (cf Story 3.10 AC22). C'est **attendu** — l'user vient d'interagir avec ce programme, son ordre de présentation reflète ça.

### Partie (f) — Cohérence routine cyclique

21. **AC21** — Programmes `.routineCyclic` : aucun bouton "Replanifier", aucun badge "En retard", aucun blocage doux. Cohérent avec décision Sophie 2026-05-17 "pas de calendrier pour routine".
22. **AC22** — `ReplanifyService` (nouveau, cf AC23) refuse si `durationMode == .routineCyclic` : throw `ReplanifyService.UnsupportedForRoutineMode` (jamais déclenché si UI bien câblée AC9, mais filet défensif).

### Tests

23. **AC23** — Créer `ReplanifyService` (`Coaching/Replanify/ReplanifyService.swift`) :
    ```swift
    protocol ReplanifyService {
        func reportSession(programId: UUID, sessionId: UUID) async throws
        func shiftWeek(programId: UUID, to date: Date) async throws
    }
    ```
    Implémentation `DefaultReplanifyService` injecté via `AppDependencies`.
24. **AC24** — `NextSessionResolverTests` : couvre les 5 scénarios AC5.
25. **AC25** — `ReplanifyServiceTests` couvre :
    - `reportSession` quand `maxDayInWeek < 7` → session reste dans la semaine, day = maxDay+1.
    - `reportSession` quand `maxDayInWeek == 7` → session passe à `weekNumber+1, day = 1`.
    - `reportSession` quand session avait `plannedDate` → nullifiée post-action.
    - `reportSession` sur routineCyclic → throw `UnsupportedForRoutineMode`.
    - `shiftWeek` à date valide → `weekStartDate` muté, `shiftGeneration += 1`.
    - `shiftWeek` sur routineCyclic → throw `UnsupportedForRoutineMode`.
26. **AC26** — Test idempotence regen post-shift dans `WeeklyRegenApplicationServiceTests` :
    - Setup : record avec `shiftGeneration = 0`, `RegenJournalEntry` historique pour `(recordId, week=2, shiftGen=0)`.
    - Trigger : shift week → `shiftGeneration = 1`.
    - Re-trigger `checkAndApplyIfDue` post-shift pour `targetWeek=2` → **applique** une nouvelle regen (pas bloquée par l'entry historique `shiftGen=0`).
    - Nouvelle `RegenJournalEntry` créée avec `shiftGeneration = 1`.
    - Re-trigger immédiat → bloqué par idempotence (entry `(recordId, week=2, shiftGen=1)` existe).
27. **AC27** — Test `RegenJournalEntry` decode rétro-compat : JSON sans champ `shiftGeneration` → décode avec `shiftGeneration = 0` (default). Aucune perte d'historique.
28. **AC28** — Snapshot tests : non câblés V1 (cohérent avec Story 3.10 AC34). Pas de snapshot ajouté.

### i18n

29. **AC29** — Nouvelles clés FR/EN dans `Localizable.xcstrings` :
    - `dashboard.session.late.badge` — "En retard" / "Late"
    - `dashboard.session.late.subtitle.format` — "Cette séance était prévue semaine du %@" / "This session was scheduled for the week of %@"
    - `dashboard.program.weekLate.format` — "Semaine %lld en attente" / "Week %lld pending"
    - `replanify.button` — "Replanifier" / "Reschedule"
    - `replanify.sheet.title` — "Tu n'as pas pu faire ta séance ?" / "Couldn't make it?"
    - `replanify.sheet.subtitle` — "Pas de souci, voici 2 façons de t'adapter." / "No worries, two ways to adjust."
    - `replanify.action.report.title` — "Reporter cette séance" / "Move this session"
    - `replanify.action.report.subtitle` — "Cette séance passe en fin de semaine." / "Moves to end of week."
    - `replanify.action.shiftWeek.title` — "Décaler ma semaine" / "Shift my week"
    - `replanify.action.shiftWeek.subtitle` — "J'ai eu un imprévu (malade, voyage). Reprends quand je te dis." / "Something came up (sick, travel). Restart on the date I pick."
    - `replanify.action.shiftWeek.datePickerTitle` — "Tu reprends quand ?" / "When do you restart?"
    - `replanify.cancel` — "Annuler" / "Cancel"
30. **AC30** — Pas de `LocalizedStringKey` avec interpolation directe (anti-pattern hotfix 2026-05-12). Utiliser `String.localizedStringWithFormat` ou `LocalizedStringResource` avec format args.

### Non-régression

31. **AC31** — Si user fait toutes ses séances dans les temps : aucun badge, aucun bouton Replanifier visible, comportement inchangé du dashboard.
32. **AC32** — Drag&drop hebdo Story 3.8 inchangé : opère uniquement sur la semaine courante (cf header `WeeklyCalendarViewModel.swift:7-8`). Ne permet PAS de déplacer une séance vers S+2 (ce qui aurait permis de contourner le blocage doux). Le seul moyen de "rattraper plus tard" hors complétion = "Reporter cette séance".
33. **AC33** — Regen Phase B (`WeeklyRegenApplicationService.refresh()`) continue son cycle normal. Post-shift, les nouvelles semaines closes sont analysées normalement avec le nouveau `shiftGeneration`. Historique journal préservé.
34. **AC34** — UI Review obligatoire `ui-reviewer` avant commit. Screenshots :
    - NextSessionCard "en retard" (programme deadline) avec badges
    - ProgramCard carrousel avec badge "Semaine X en attente"
    - ReplanifySheet ouverte
    - DatePicker shift week
    - Post-décalage (badge "En retard" disparu)
    - FR + EN sur tous
    - Checklist 8 points `ui-reviewer.md`.

## Hors scope

- **"Léon propose On reprend où ?"** (option b initiale) : reportée. Si à l'usage Sophie voit des programmes qui traînent à 3+ semaines de retard sans action, story d'optim dédiée à ajouter.
- **Notification push "Tu as une séance en retard"** : V2.
- **Historique des décalages** (logging audit pour analytics) : V2.
- **Multi-décalages simultanés** (décaler S2 + S3 en même temps) : non prévu V1, l'user décale 1 semaine à la fois.
- **Replanifier sur routine cyclique** : non couvert (cf AC21-22).
- **Action "Sauter cette séance"** : non livrée V1. L'user qui veut vraiment skip = laisse passer le temps (blocage doux) ou utilise "Reporter cette séance" + complète manuellement.
- **Préservation des `plannedDate` drag&dropées post-shift** : V2 si demandé. V1 = les drag&drop manuels sont effacés au shift (cf AC17).

## Tasks

### Partie (a) — Blocage doux NextSessionResolver (0.5j)
- [ ] Modifier `NextSessionResolver.next(in:)` : ajouter logique "semaine bloquante" pour `.planned + .deadlineFixed/.deadlineEstimated`.
- [ ] Helper privé `currentWeekNumber(weekStartDate:now:)` (réutiliser celui de `WeeklyRegenApplicationService` si possible).
- [ ] Tests AC5 (5 scénarios).

### Partie (b) — Affichage état en retard (0.5j)
- [ ] Ajouter computed `nextSessionIsLate: Bool` sur `ProgramSummary` (extension dans cette story).
- [ ] Adapter `makeSummaries` dans `SessionDashboardViewModel` pour calculer ce computed.
- [ ] Composer badge "En retard" + sous-titre dans `NextSessionCard` (utiliser `Color.coachingWarning`).
- [ ] Composer indicateur visuel discret sur `ProgramCard`.
- [ ] Format date FR/EN via `DateFormatter` (AC7).

### Partie (c) — Sheet Replanifier (0.5j)
- [ ] Créer `ReplanifySheet` SwiftUI (titre + sous-titre + 2 boutons + annuler, presentationDetents medium/large).
- [ ] Câbler bouton "Replanifier" dans `NextSessionCard` (conditionnel : late && !routineCyclic).
- [ ] Câbler ouverture sheet via `@State`.

### Partie (d-e) — ReplanifyService + actions (1j)
- [ ] Créer protocole `ReplanifyService` + impl `DefaultReplanifyService` (AC23).
- [ ] Injection `AppDependencies`.
- [ ] Implémenter `reportSession(programId:sessionId:)` (AC12).
- [ ] Implémenter `shiftWeek(programId:to:)` (AC15-16).
- [ ] Tests unitaires `ReplanifyServiceTests` AC25.
- [ ] Câbler boutons sheet → service.

### Partie (f) — Idempotence regen post-shift (0.5j)
- [ ] Le champ `shiftGeneration: Int` est **déjà ajouté à `RegenJournalEntry` par Story 3.10 AC1** (cadré en 1 seule modif persistence). Cette story le câble dans la logique service ci-dessous.
- [ ] Adapter `WeeklyRegenApplicationService.checkAndApplyIfDue` : check par `(recordId, targetWeek, shiftGeneration)` au lieu de `(recordId, targetWeek)`.
- [ ] Adapter écriture journal pour porter le `shiftGeneration` courant du record (passé en argument à `apply()`).
- [ ] Tests AC26-27.

### i18n + review (0.5j)
- [ ] Ajouter 12 clés FR+EN `Localizable.xcstrings` (AC29).
- [ ] Vérifier pas de `LocalizedStringKey` interpolé (AC30).
- [ ] `mcp__xcode__BuildProject` PASS.
- [ ] `RunSomeTests` ciblé.
- [ ] Lancer agent `ui-reviewer` — screenshots AC34.
- [ ] Fix P0/P1 findings.
- [ ] Cmd+B/U/R Sophie.

## Dépendances

- **Story 3.10 (Dashboard carrousel)** — DOIT être mergée avant 3.11. Composants `NextSessionCard`, `ProgramCard`, struct `ProgramSummary`, schema V8 + `weekStartDate: Date?` + `shiftGeneration: Int` sont introduits par 3.10.
- Story 3.8 — drag&drop hebdo (DONE).
- Story sœur 3.z — `ProgramDurationMode` (DONE).
- Story 3.4 Phase B — regen Phase B + `RegenJournalEntry` (DONE).

## Risques identifiés (cf review architecte 2026-05-17)

- **`NextSessionResolver` inversion filtre date** : risque de réintroduire le bug initial qui justifiait le filtre `date >= startOfDay`. AC5 tests critiques pour valider que les cas non-bloquants (routine cyclique, ondemand pur) restent inchangés.
- **Tolérance mode mixte `.planned` avec plannedDate nullifiée** (AC13) : non-trivial. Tester explicitement le résolveur sur ce cas (séance sans plannedDate dans un programme `.planned`). Si bug, fallback envisageable : débasculer le programme en `.ondemand` au "Reporter cette séance". V1 = on tente la tolérance.
- **`RegenJournalEntry.shiftGeneration` rétro-compat** : JSON existants sans le champ doivent décoder avec 0. AC27 explicit. Si Codable strict, ajouter `init(from decoder:)` custom avec `decodeIfPresent`.
- **`shiftWeek` perte des `plannedDate` manuelles** (AC17) : trade-off V1 assumé. À documenter dans le CTA shift "tes ajustements manuels seront recalés sur la nouvelle semaine".
- **Programmes bloqués 3+ semaines** : Sophie 2026-05-17 assume qu'ils consomment leur slot du cap. Pas d'auto-archive abandon V1.
