# Story 3.10 — Dashboard carrousel programmes actifs + 1ʳᵉ séance pose la date (Epic 3)

Status: ready-for-dev
Branche cible : `epic-3/story-3.10-dashboard-carrousel`
Effort estimé : **~6j** (dev solo) — révisé post-review architecte 2026-05-17

## Story

**As a** utilisateur CoachingSage qui suit en parallèle plusieurs programmes (triathlon + piscine + yoga + muscu + kit assistant),
**I want** voir l'ensemble de mes programmes actifs dans un carrousel horizontal façon Decathlon Coach, avec la prochaine séance du programme sélectionné juste en dessous, ET pouvoir générer plusieurs programmes en avance sans les avoir démarrés,
**so that** je gère mon multi-activité sans confusion, je n'ai pas de pression "tu dois commencer maintenant", et la date de référence se pose **uniquement** quand je tape "Démarrer ma 1ʳᵉ séance".

## Contexte produit

- **Constat user** (Sophie, test simu post-merge story sœur 3.z, 2026-05-17) : aujourd'hui le dashboard montre une "card dominante" + liste verticale des programmes. Pas de multi-programmes vraiment navigable. Et tout programme suggestion est commit immédiat → user n'a pas le temps d'en préparer plusieurs en avance.
- **Vision Sophie** (2026-05-17 — cf. mémoire [[backlog_dashboard_seances_refonte_2026_05_17]]) : refonte façon Decathlon Coach avec carrousel horizontal de programmes actifs, prochaine séance affichée sous le programme sélectionné.
- **Bémol Sophie crucial** (2026-05-17) : un programme "initié" n'a **pas obligatoirement** de date de départ. Le user peut générer un programme en avance et le laisser dormir. La `weekStartDate` se pose **uniquement** au moment du 1ᵉʳ tap "Démarrer ma séance" — pas au commit du programme.
- **Concept "Préparé avec Léon" reporté** : le chat Léon est un placeholder en V1 (`LeonChatPlaceholderSheet`). Tant qu'il n'est pas livré, créer un état "Préparé" dans le modèle serait du code mort. On garde le modèle simple : "dormant" = `weekStartDate == nil`, "démarré" = `weekStartDate != nil`.
- **Cap multi-programmes** : 5 démarrés simultanés max + 10 dormants simultanés max (cas user 5 sports en parallèle évolutif).
- **Auto-archive à complétion** : programme dont toutes les séances sont cochées → flip `isActive = false` silencieux, libère le slot du cap. Pas d'auto-archive sur abandon (bloqué 3+ semaines reste actif — couvert Story 3.11).
- **Suppression `RoutineRecord` @Model** : aucune routine n'a jamais été créée en base depuis Story 3.1 (pas d'UI de création). Le concept "routine 3 mois cyclique" est déjà couvert par `ProgramDurationMode.routineCyclic` sur `AdaptedProgramRecord`. On nettoie le code mort.

## Acceptance Criteria

### Partie (a) — Migration breaking : weekStartDate nullable + Schema V8

⚠️ **Migration breaking confirmée par review architecte 2026-05-17** : `AdaptedProgramRecord.weekStartDate` est actuellement `var weekStartDate: Date` (non-nullable, ligne 35). Cette story le passe à `Date?`. Impact ripple ~15 fichiers (tests, helpers regen, init convenience).

1. **AC1** — Création `Models/Schema/SchemaV8.swift` qui dérive de V7. Différences V7→V8 :
   - `AdaptedProgramRecord.weekStartDate: Date` → `Date?` (nullable, default nil pour les nouveaux records).
   - `AdaptedProgramRecord.shiftGeneration: Int` (nouveau champ, default 0) — câblage Story 3.11 mais introduit ici pour ne pas refaire de migration.
   - Drop `@Model RoutineRecord` (suppression complète).
   - **Hors @Model mais inclus dans cette story pour éviter une 2ᵉ migration breaking en 3.11** : ajout `shiftGeneration: Int = 0` au struct Codable `RegenJournalEntry` (`Coaching/Persistence/RegenJournalEntry.swift`). C'est un struct JSON file plat (pas un @Model SwiftData), donc pas dans le schema SwiftData V8 — mais décode rétro-compat obligatoire (entries JSON existantes sans le champ → 0). Story 3.11 utilise ce champ pour l'idempotence post-shift, on l'introduit ici pour cadrer toutes les modifs persistence en 1 seule story.
2. **AC2** — `CoachingSageMigrationPlan.stages = []` reste vide (pattern wipe-simu dev solo, cf commentaire `CoachingSageMigrationPlan.swift:23`). Documenter dans la story que **wipe simu obligatoire** au premier run post-merge. Aucune migration runtime à coder.
3. **AC3** — Init convenience `AdaptedProgramRecord.init(...)` (ligne 108) : default `weekStartDate: Date? = nil` (au lieu de `Date = AdaptedProgramRecord.startOfCurrentWeek()`). Ripple : tous les call-sites `AdaptedProgramRecord(...)` dans les tests qui passent explicitement `weekStartDate: Date()` continuent de marcher (Date → Date? compatible). Les call-sites qui s'appuient sur le default voient désormais `nil`.
4. **AC4** — `AutoProgramFactory.commit()` (ligne ~100) : confirmer que le `AdaptedProgramRecord(from: preview.program, ...)` résulte en `weekStartDate = nil`. Si la conversion porte explicitement la date, la nullifier ici.
5. **AC5** — Helper `AdaptedProgramRecord.startOfCurrentWeek()` (ligne 199-205) inchangé. Reste static, ISO firstWeekday=2.
6. **AC6** — Locale firstWeekday alignée : `SessionDashboardViewModel.loadRegenBadges` ligne 269 utilise `Calendar.current` (firstWeekday locale) → harmoniser sur ISO firstWeekday=2 (cohérence avec `startOfCurrentWeek()`). Bug latent à corriger dans cette story.

### Partie (b) — 1ʳᵉ séance pose la date

7. **AC7** — Ajouter méthode `AdaptedProgramRecord.markStarted()` : si `weekStartDate == nil`, pose `weekStartDate = AdaptedProgramRecord.startOfCurrentWeek()`. Idempotent : 2ᵉ appel = no-op (déjà non-nil).
8. **AC8** — Tap "Démarrer cette séance" sur un programme dormant déclenche `markStarted()` puis `repository.update(record)` (single transaction repository, pas de gestion atomique au niveau SwiftData — l'update suffit).
9. **AC9** — Call-site exact : étendre la closure `startSession` actuellement câblée dans `SessionView.swift` (à grepper, ligne ~330+). Ajouter étape intermédiaire `await markStartedIfNeeded(programId:)` via le repository.

### Partie (c) — Caps + auto-archive

10. **AC10** — `DefaultAdaptedProgramRepository` expose :
    - `fetchStartedCount() async throws -> Int` (count où `weekStartDate != nil && isActive == true`)
    - `fetchDormantCount() async throws -> Int` (count où `weekStartDate == nil && isActive == true`)
    Implémenté via `FetchDescriptor<AdaptedProgramRecord>` avec predicate SwiftData.
11. **AC11** — Nouvelle erreur typée `ProgramCapReached: Error` :
    ```swift
    enum ProgramCapReached: Error {
        case dormant(limit: Int)  // 10
        case started(limit: Int)  // 5
    }
    ```
12. **AC12** — Au commit d'un nouveau programme depuis preview : check `fetchDormantCount() < 10`. Sinon throw `ProgramCapReached.dormant(limit: 10)`. Alerte UX gérée par la View qui catch : **iOS `.alert(_:isPresented:)` natif** avec titre/message/CTA primary "OK" + secondary "Voir mes programmes" qui ferme l'alerte et scroll vers le carrousel haut (`ScrollViewReader.scrollTo(.top)`).
13. **AC13** — Au 1ᵉʳ tap "Démarrer ma séance" sur un dormant : check `fetchStartedCount() < 5`. Sinon throw `ProgramCapReached.started(limit: 5)`. Alerte UX identique à AC12 (titres différents).
14. **AC14** — Auto-archive à complétion : étendre `SessionCompletionViewModel.complete(...)` (`SessionCompletionViewModel.swift:75-93`) → après save du `SessionCompletionRecord`, si `record.completionState.completedCount == record.sessions.count` → flip `record.isActive = false` puis `repository.update(record)`. Silencieux (pas de toast). Test AC25.
15. **AC15** — Programmes bloqués 3+ semaines (cf Story 3.11) **restent actifs et consomment leur slot** — pas d'auto-archive sur abandon. Décision Sophie 2026-05-17 assumée.

### Partie (d) — Suppression RoutineRecord

16. **AC16** — Suppression complète des fichiers :
    - `Coaching/Persistence/RoutineRecord.swift`
    - `Repositories/Protocols/RoutineRepository.swift` (si existe)
    - `Repositories/Implementations/DefaultRoutineRepository.swift`
17. **AC17** — `AppDependencies.routineRepository` injection supprimée. Adapter tous les VMs qui l'injectent (grep `routineRepository`).
18. **AC18** — `ActiveDashboardView.swift` lignes 102-110 (section "Mes routines") → supprimée. Pas de message migration utilisateur (aucune routine en base).
19. **AC19** — `AdaptedProgramRecordTests.swift:30` (et autres tests qui montent un container avec `for: RoutineRecord.self`) → retirer `RoutineRecord.self` de la liste.

### Partie (e) — Refonte dashboard carrousel

20. **AC20** — `SessionDashboardViewModel.Mode` enum (`SessionDashboardViewModel.swift:30`) refondu :
    - **Avant** : `.empty / .singleProgram(...) / .multiProgram(...)`
    - **Après** :
      ```swift
      enum Mode: Equatable {
          case empty
          case active(programs: [ProgramSummary], selectedId: UUID?)
      }
      ```
    - ⚠️ **PORTÉE LIMITÉE** : SEUL `SessionDashboardViewModel.Mode` est refactoré. `WeeklyCalendarViewModel.Mode` (`Coaching/Dashboard/WeeklyCalendarViewModel.swift:30`) est un enum **séparé** et n'est PAS touché par cette story (13 tests `WeeklyCalendarViewModelTests` à ne PAS casser).
21. **AC21** — `ProgramSummary` struct VM (Equatable, Identifiable) :
    ```swift
    struct ProgramSummary: Equatable, Identifiable {
        let id: UUID                        // = recordId
        let templateName: String
        let sport: Sport
        let weekStartDate: Date?            // nil = dormant
        let durationMode: ProgramDurationMode
        let mode: ProgramMode               // .planned / .ondemand
        let nextSession: PersistedSession?  // précalculé par VM, nil = pas commencé ou plus de séance
        let sessionStatusText: LocalizedStringResource  // i18n key prête à afficher
        // Story 3.11 ajoutera : let nextSessionIsLate: Bool
    }
    ```
    - `sessionStatusText` examples : "Non commencé" (dormant), "Semaine 2 — 1/3 séances" (démarré).
22. **AC22** — Tri du carrousel — algo en 3 niveaux pour lever toute ambiguïté :
    - **Niveau 1** : démarrés (`weekStartDate != nil`) AVANT dormants (`weekStartDate == nil`). Sépare les 2 catégories.
    - **Niveau 2 (entre démarrés)** : `nextDate ascending` (préserve `testRefreshSortsActiveProgramsByNextDateAscending` actuel).
    - **Niveau 3 (entre dormants uniquement)** : `lastUpdatedAt desc` (le dernier dormant créé apparaît en tête de la section dormante).
    - ⚠️ Le tri `lastUpdatedAt desc` n'est jamais appliqué entre démarrés et dormants ou entre démarrés (sinon un shift week — qui update `lastUpdatedAt` — ferait remonter le programme devant des démarrés à plannedDate plus proche, comportement non voulu).
23. **AC23** — Carrousel SwiftUI dans `ActiveDashboardView` :
    - `ScrollView(.horizontal, showsIndicators: false)` + `LazyHStack(spacing: 12)` + `.scrollTargetBehavior(.viewAligned)` iOS 17+
    - Cards `ProgramCard` width ~280pt, height fixe ~120pt
    - Card sélectionnée : border `Color.coachingPrimary` 2pt OU shadow plus marqué
    - Sélection par défaut = première card de la liste (`programs.first?.id`)
    - Tap card → update `@State selectedProgramId`, met à jour `NextSessionCard` en dessous
24. **AC24** — `NextSessionCard` SwiftUI sous le carrousel. Cas couverts en V1 :
    - **Programme dormant** (`weekStartDate == nil`) → "Non commencé" + bouton primary **Démarrer** (déclenche `markStarted` + lance la séance).
    - **Programme démarré, séance disponible** → titre séance + durée + bouton primary **Démarrer** (lance la séance).
    - **Programme démarré, semaine complétée** (placeholder en attente Story 3.11) → "Semaine X complétée ✓ — patience, la semaine prochaine arrive". Le vrai blocage doux + Replanifier sont livrés en 3.11.
    - **Programme démarré, plus de séance** (programme complet pas encore auto-archive) → "Programme terminé ✓" (transitoire jusqu'à auto-archive AC14).
    - **Programme à 1 séance** : compléter cette séance via "Démarrer" déclenche dans l'ordre : `markStarted()` (pose `weekStartDate`) → save séance complétée → auto-archive AC14 (flip `isActive = false`). Ordre garanti par la séquentialité du flux (markStarted avant complétion). La card disparaît du carrousel post-archive.
    - **Programme dormant avec séance `requiresAIAssist == true`** : bouton "Démarrer" reste actif. Le flow assist (`AdaptedExercise.requiresAIAssist`) se déclenche normalement après `markStarted()` (comportement actuel préservé, aucune adaptation côté Story 3.10).
25. **AC25** — En cas `Mode.empty` (0 programme actif) → placeholder existant conservé : "Crée ton premier programme — *Suggestions ↓*" + lien vers section suggestions (cf comportement actuel).
26. **AC26** — Section suggestions pré-générées (V2 chantier #6 DONE, cf mémoire [[session_2026_05_11_v2_chantiers_done]]) reste **inchangée** et visible sous le carrousel + NextSessionCard. Pas d'autre section "Préparés avec Léon" en V1.
27. **AC27** — Verrou non-régression preview-and-back (commit `8143baa`) **préservé** : le commit d'un programme depuis preview persiste en `AdaptedProgramRecord(weekStartDate=nil, isActive=true)` via le CTA explicite uniquement. Le "Retour" preview ne persiste rien (test existant `progRepo.stubbedActive.count == 0` après preview reste vert).
28. **AC28** — Pattern matching sur ancien `Mode` dans `SessionView.swift:207, 238, 239` (+ tout autre call-site grepé) → adapté au nouveau `Mode.active`. Tests `SessionDashboardViewModelTests` correspondants à réécrire (cf AC30).

### Partie (f) — Cohérence regen Phase B

29. **AC29** — `WeeklyRegenApplicationService.checkAndApplyIfDue` (`Coaching/Regen/WeeklyRegenApplicationService.swift:106-109`) doit **guarder** sur `weekStartDate != nil`. Programmes dormants (`weekStartDate == nil`) sont **skippés sans erreur** :
    ```swift
    guard let weekStartDate = record.weekStartDate else { return nil }
    ```
    Justification : pas de semaine close à analyser sur un dormant.

### Tests

30. **AC30** — `SessionDashboardViewModelTests` réécrits pour le nouveau `Mode.active` :
    - `testEmptyMode_NoProgram` (= ancien `testEmptyMode`)
    - `testActiveMode_OneDormant`
    - `testActiveMode_OneStarted`
    - `testActiveMode_FiveStartedTenDormant_Sorted`
    - `testRefreshSortsActiveProgramsByNextDateAscending_DormantsLast` (renommé, conserve l'esprit)
    - Switch sélection (`selectedId` changes update tous les downstream computed)
    - Migration des tests de `Mode.singleProgram/.multiProgram` vers `Mode.active` (perte 0 couverture).
31. **AC31** — `AdaptedProgramRecordTests` couvre :
    - Commit factory → `weekStartDate == nil`
    - `markStarted()` pose `weekStartDate`, 2ᵉ appel = no-op
    - Décode/encode `weekStartDate: Date?` rétro-compat (entries sans champ → nil)
    - Décode `shiftGeneration` default 0 si absent
32. **AC32** — `DefaultAdaptedProgramRepositoryTests` couvre :
    - `fetchStartedCount()` retourne le bon count
    - `fetchDormantCount()` retourne le bon count
    - Save avec cap dormant atteint → throw `ProgramCapReached.dormant`
    - `markStarted` avec cap started atteint → throw `ProgramCapReached.started`
33. **AC33** — `SessionCompletionViewModelTests` couvre auto-archive à complétion : compléter la dernière séance → `record.isActive == false` post-save.
34. **AC34** — Snapshot tests : **non câblés en V1** (`swift-snapshot-testing` pas dans le repo). Marquer dette dans la mémoire : "snapshot tests à câbler quand on aura besoin d'un filet régression UI plus serré". Aucun snapshot ajouté dans cette story.

### i18n

35. **AC35** — Nouvelles clés FR/EN dans `Localizable.xcstrings` :
    - `dashboard.program.notStarted` — "Non commencé" / "Not started"
    - `dashboard.program.weekStatus.format` — "Semaine %lld — %lld/%lld séances" / "Week %lld — %lld/%lld sessions"
    - `dashboard.program.weekCompleted.format` — "Semaine %lld complétée" / "Week %lld completed"
    - `dashboard.program.completed` — "Programme terminé" / "Program completed"
    - `dashboard.program.cap.started.alert.title` — "Tu as déjà 5 programmes en cours" / "You already have 5 active programs"
    - `dashboard.program.cap.started.alert.message` — "Termine ou archive l'un d'eux pour commencer celui-ci." / "Finish or archive one to start this one."
    - `dashboard.program.cap.dormant.alert.title` — "10 programmes en attente" / "10 programs queued"
    - `dashboard.program.cap.dormant.alert.message` — "Archive ou démarre l'un d'eux pour en générer un nouveau." / "Archive or start one to generate a new one."
    - `dashboard.program.cap.alert.cta.viewPrograms` — "Voir mes programmes" / "View my programs"
    - `dashboard.program.start.button` — "Démarrer" / "Start"
36. **AC36** — Pas de `LocalizedStringKey` avec interpolation directe (anti-pattern hotfix 2026-05-12 — cf [[hotfix_2026_05_12_adapted_program_i18n]]). Utiliser `String.localizedStringWithFormat` ou `LocalizedStringResource` avec format args.

### Non-régression

37. **AC37** — Drag&drop hebdo Story 3.8 (`WeeklyCalendarView`) continue de fonctionner sur programme démarré. Sur dormant : l'icône `calendar` de la toolbar `AdaptedProgramView` (`Views/Screens/Coaching/AdaptedProgramView.swift:105` — ligne à vérifier) est **conditionnée à `recordId != nil && record.weekStartDate != nil`** → effet de bord "initie implicitement par drag&drop" neutralisé.
38. **AC38** — `WeeklyRegenApplicationService` filtre `weekStartDate != nil` (AC29). Pas de regen sur dormant.
39. **AC39** — `ProgressViewModel.swift:176` `filter { $0.isActive }` reste valide (sémantique inchangée). Un dormant compte comme programme actif côté Progrès — l'user l'a généré, il fait partie de son patrimoine.
40. **AC40** — Tests existants `WeeklyCalendarViewModelTests` (13 tests utilisent `WeeklyCalendarViewModel.Mode.singleProgram`) restent **PASS sans modification** — confirmé par AC20 "portée limitée".
41. **AC41** — UI Review obligatoire `ui-reviewer` (cf `CLAUDE.md` projet) avant commit final. Screenshots :
    - Dashboard `.empty`
    - Dashboard `.active(1 dormant)`
    - Dashboard `.active(1 démarré + 4 dormants)`
    - Dashboard `.active(5 démarrés)`
    - Alerte cap dormant atteint
    - Alerte cap started atteint
    - FR + EN sur tous
    - Checklist 8 points `ui-reviewer.md`.

## Hors scope

- **Concept "Préparé avec Léon"** : reporté à la livraison du vrai chat Léon. Aucun état lifecycle `.draft` ajouté en V1.
- **Drag&drop sur dormant** : icône calendar greyed out / hidden tant que `weekStartDate == nil` (cf AC37).
- **Bouton "Mettre en pause"** un programme démarré : V2 si demandé.
- **Tri du carrousel custom user** (drag-reorder) : V2.
- **Section "Historique"** des programmes archivés / complétés : V2.
- **Sync multi-device** : hors V1, local-first.
- **Snapshot tests** : non câblés V1 (dette mémoire).
- **Migration `templateId` retiré du catalogue** : `templateId` est considéré stable V1 (les templates v2 sont bundlés in-app, voir [[epic05_story0510_done]]). Un dormant créé sur un template puis retiré du catalogue continue à être lisible via le snapshot embarqué dans `AdaptedProgramRecord` (le record contient déjà `sessions: [PersistedSession]` qui ne dépend pas du `templateId` pour s'afficher). Aucune migration silencieuse côté `templateId` n'est prévue en V1.

## Tasks

### Partie (a) — Schema V8 + nullabilité (1j)
- [ ] Créer `Models/Schema/SchemaV8.swift` (clone V7 + 3 changements AC1).
- [ ] Adapter `AdaptedProgramRecord` : `weekStartDate: Date?`, ajouter `shiftGeneration: Int = 0`.
- [ ] Modifier init convenience (AC3) : default `weekStartDate: Date? = nil`.
- [ ] Vérifier `AutoProgramFactory.commit()` (AC4) : `weekStartDate = nil`.
- [ ] Harmoniser `SessionDashboardViewModel.loadRegenBadges` firstWeekday=2 (AC6).
- [ ] Vérifier `WeeklyRegenApplicationService` guard `weekStartDate != nil` (AC29).
- [ ] Vérifier `AdaptedProgramView` toolbar calendar conditional (AC37).

### Partie (b) — markStarted + 1ʳᵉ séance (0.5j)
- [ ] Ajouter méthode `markStarted()` sur `AdaptedProgramRecord` (AC7).
- [ ] Câbler call dans `SessionView` closure démarrage (AC9). Grep `startSession` ou équivalent.

### Partie (c) — Caps + auto-archive (1j)
- [ ] Ajouter `enum ProgramCapReached: Error` (AC11).
- [ ] `DefaultAdaptedProgramRepository` : `fetchStartedCount()`, `fetchDormantCount()` (AC10).
- [ ] Wrap commit dans service / VM qui check cap dormant + alert (AC12).
- [ ] Wrap markStarted dans service / VM qui check cap started + alert (AC13).
- [ ] Étendre `SessionCompletionViewModel.complete()` auto-archive (AC14).
- [ ] Tests AC32, AC33.

### Partie (d) — Suppression RoutineRecord (0.5j)
- [ ] Grep `RoutineRecord`, `DefaultRoutineRepository`, `routineRepository` — confirmer 0 usage actif.
- [ ] Drop fichiers (AC16).
- [ ] Supprimer injection `AppDependencies` (AC17).
- [ ] Supprimer section UI `ActiveDashboardView:102-110` (AC18).
- [ ] Retirer `RoutineRecord.self` des containers tests (AC19).

### Partie (e) — Refonte dashboard carrousel (1.5j)
- [ ] Refondre `SessionDashboardViewModel.Mode` (AC20).
- [ ] Définir struct `ProgramSummary` (AC21).
- [ ] Précalculer `nextSession` pour chaque programme actif au refresh.
- [ ] Adapter `SessionView.swift:207, 238, 239` pattern matching (AC28).
- [ ] Réécrire `SessionDashboardViewModelTests` (AC30).

### Partie (f) — SwiftUI carrousel (1j)
- [ ] Créer composant `ProgramCard` SwiftUI (AC23).
- [ ] Créer composant `NextSessionCard` SwiftUI (AC24).
- [ ] Câbler `@State selectedProgramId` (AC23).
- [ ] Bind sélection ↔ NextSessionCard.
- [ ] Garder section suggestions pré-générées inchangée (AC26).

### i18n + tests (0.5j)
- [ ] Ajouter 10 clés FR+EN `Localizable.xcstrings` (AC35).
- [ ] Vérifier pas de `LocalizedStringKey` interpolé (AC36).
- [ ] Tests repo + VM (AC31-33).

### Review (0.5j)
- [ ] `mcp__xcode__BuildProject` PASS.
- [ ] `RunSomeTests` ciblé sur tests modifiés/ajoutés.
- [ ] Lancer agent `ui-reviewer` (cf `CLAUDE.md`) — screenshots AC41.
- [ ] Fix P0/P1 findings.
- [ ] Cmd+B/U/R Sophie.

## Dépendances

- Story 3.8 — drag&drop hebdo (DONE).
- Story sœur 3.z — `ProgramDurationMode` (DONE).
- Story 3.4 Phase B — regen S+1 (DONE).
- V2 chantier #6 — suggestions pré-générées (DONE).

## Dépendance amont pour Story 3.11

Cette story introduit :
- `ProgramSummary` struct (shape complet AC21) — Story 3.11 ajoutera `nextSessionIsLate: Bool`.
- `NextSessionCard` SwiftUI — Story 3.11 ajoutera badge "En retard" + bouton "Replanifier".
- `ProgramCard` SwiftUI — Story 3.11 ajoutera indicateur "Semaine en retard".
- Schema V8 + `weekStartDate: Date?` + `shiftGeneration: Int` — Story 3.11 utilisera `shiftGeneration` pour idempotence regen post-shift.

3.10 DOIT être mergée avant 3.11.

## Risques identifiés (cf review architecte 2026-05-17)

- **Migration breaking weekStartDate** : ~15 fichiers tests à valider post-refactor. Build PASS = condition nécessaire mais pas suffisante (compile vs sémantique). Tests AC31 critiques.
- **`SessionView.swift` pattern matching** : adaptation Mode dans 3+ call-sites. À grepper exhaustivement avant commit.
- **`WeeklyRegenApplicationService` unwrap** : guard `weekStartDate != nil` AC29 = condition pour ne pas crasher post-migration sur un dormant.
- **`WeeklyCalendarViewModel.Mode` confondu avec `SessionDashboardViewModel.Mode`** : enum différents — AC20 explicit "portée limitée" à ne PAS casser.
- **`AdaptedProgramRecordTests:30` container avec `RoutineRecord.self`** : AC19 explicit.
- **Wipe simu nécessaire au merge** : à rappeler dans message de commit / PR description.
