# Story 3.15 — Refonte hiérarchique du dashboard Séances (Epic 3)

Status: **ready-for-dev** (décisions Sophie figées 2026-05-20, review agent Plan 2026-05-20 appliquée — P0×4 + P1×7 fixés)
Branche cible : `epic-3/story-3.15-dashboard-hierarchical-refonte`
Effort estimé : **~4-4.5j** (dev solo) — révisé après review agent Plan (3j initial sous-estimait extension factory + i18n + 4 ui-reviewer)

## Story

**As a** utilisatrice qui ouvre l'onglet Séances quotidiennement, parfois avec 1 programme actif, parfois 3, parfois aucun, plus quelques programmes "préparés à l'avance",
**I want** que le dashboard distingue visuellement (i) mes programmes en cours, (ii) ma prochaine séance focale, (iii) mes programmes préparés mais pas démarrés, sans les enterrer dès que j'en lance un,
**so that** je ne perde plus mes préparations dans le carrousel mixte actuel et que l'écran reflète vraiment ma situation d'usage (séance à venir + portefeuille de programmes possibles).

## Contexte produit

- **Constat user** (Sophie, test simu/iPhone 2026-05-20) : *"je perds mes programmes préparés non démarrés dès que j'en crée un, je veux la distinction visuelle"*. Conversation entière préservée dans cette session.
- **État actuel** : depuis Story 3.10/3.12, `ActiveDashboardView` affiche **3 layouts adaptatifs distincts** (1 programme = `singleProgramLayout` full-width 180pt, 2-3 programmes = `adaptiveGridLayout`, ≥4 = carrousel horizontal mixte) trié `démarrés d'abord, puis lastUpdatedAt desc` (`SessionDashboardViewModel.compareSummariesForCarousel()` ligne 356). Dès qu'un programme est démarré, les dormants se font enterrer en queue de carrousel — exactement le pain Sophie.
- **`NextSessionCard` existante** : affichée seulement si N=1 ou N≥4 programmes (cf `ActiveDashboardView.swift:342-380`) — visuellement discrète, manque de poids focal.
- **Suggestions `selectTopN`** : aujourd'hui visibles UNIQUEMENT en mode `.empty` (0 programme actif et 0 dormant). Dès qu'1 programme existe, elles disparaissent → 2e pain Sophie : *"je ne veux pas perdre les suggestions dès que je lance ou prépare un programme"*.
- **Décision conceptuelle Sophie 2026-05-20** : *"suggestions et dormants c'est la même chose, on supprime la distinction"*. Les 3 templates `selectTopN` sont **persistés comme `AdaptedProgramRecord` (dormants) au 1er launch post-onboarding**. Plus jamais de génération auto.

## Décisions Sophie 2026-05-20 (figées)

1. **Carrousel horizontal "Programmes en cours"** — uniquement `weekStartDate != nil`. Toujours visible si ≥1 lancé. **Remplace les 3 layouts adaptatifs actuels** (singleProgramLayout / adaptiveGridLayout / carrousel ≥4) par un carrousel unique snap natif iOS 17.
2. **Séance focale** = prochaine séance du **programme sélectionné** dans le carrousel. Au swipe du carrousel, la séance focale change.
3. **Teaser séance N+1 toujours visible** juste sous la focale (plus petit) — pas de scroll requis pour la révéler.
4. **Section "Préparés"** = liste verticale scrollable des dormants (`weekStartDate == nil` ET `isActive == true`), affichée uniquement si dormants ≠ ∅.
5. **Pas de fallback "Et après"** : si pas de dormants, rien sous le teaser N+1.
6. **Cas "0 lancé + N dormants"** : section "Préparés" remontée en tête, pas de carrousel ni de séance focale.
7. **Cards préparés** : badge texte localisé "Préparé" en haut + opacité ~0.9 (pas de filtre lourd, pas d'icône ambiguë style ⏸).
8. **Bootstrap 3 dormants au 1er launch post-onboarding** via `selectTopN`. Plus jamais de génération auto. L'user peut les supprimer, ils ne reviennent pas.

## Acceptance Criteria

### Partie (a) — Split started / dormant dans le ViewModel

1. **AC1** — `SessionDashboardViewModel.makeProgramSummaries` évolue pour retourner un tuple `(started: [ProgramSummary], dormant: [ProgramSummary])` au lieu d'une seule liste mixte :
   - `var startedSummaries: [ProgramSummary]` — `weekStartDate != nil`, triées par `lastUpdatedAt desc`
   - `var dormantSummaries: [ProgramSummary]` — `weekStartDate == nil`, triées par `lastUpdatedAt desc` (créé/modifié récemment en haut)
   - Le `selectedId` du carrousel ne référence QUE des `startedSummaries`. Si le programme sélectionné disparaît (archive, started → dormant impossible mais started → archived) → réassignation au premier `startedSummaries` restant ou `nil` si vide.
2. **AC2** — `compareSummariesForCarousel()` (ligne 356) est **supprimée**. Le tri se fait localement sur chaque sous-liste (`startedSummaries.sorted(by: \.lastUpdatedAt, descending)` / idem `dormantSummaries`).
3. **AC3** — Enum `DashboardMode` évolue :
   - `.empty` → uniquement si `startedSummaries.isEmpty && dormantSummaries.isEmpty` (cas vraiment vide : user a delete tout)
   - `.dormantOnly([ProgramSummary])` → `startedSummaries.isEmpty && !dormantSummaries.isEmpty`
   - `.active(started: [ProgramSummary], dormants: [ProgramSummary], selectedId: UUID?)` → `!startedSummaries.isEmpty` (dormants peut être vide)

### Partie (b) — Refonte `ActiveDashboardView` en 3 zones

4. **AC4** — Quand `mode == .active`, le layout vertical est :
   ```
   ┌──────────────────────────────────────┐
   │  Zone 1 : Carrousel "Programmes en   │
   │           cours" (started uniquement)│
   ├──────────────────────────────────────┤
   │  Zone 2 : Séance focale (GROS) +     │
   │           teaser N+1 (petit)         │
   ├──────────────────────────────────────┤
   │  Zone 3 : Liste "Préparés"           │
   │           (uniquement si dormants≠∅) │
   └──────────────────────────────────────┘
   ```
   **Les 3 layouts existants** (`singleProgramLayout` ligne 109, `adaptiveGridLayout` ligne 128, branche carrousel ≥4 ligne 90-96) **sont supprimés** au profit d'un carrousel unique avec snap iOS 17. La logique adaptative `if programs.count == 1 / 2-3 / ≥4` disparaît entièrement.
5. **AC5** — Zone 1 réutilise `ProgramCard` existant + snap natif iOS 17 (`.scrollTargetBehavior(.viewAligned)`) + `scrollPosition` bindée à `selectedId`. Largeur card carrousel = `~78%` viewport (style 4+ programmes actuel).
6. **AC6** — Zone 2 séance focale :
   - Si la séance courante du programme sélectionné existe → afficher la card large (style actuel `NextSessionCard` mais avec poids visuel renforcé : padding plus large, fond contrasté coach blue subtil, CTA "Démarrer →" plus visible).
   - États couverts (cohérents avec AC24 Story 3.12) : séance disponible, semaine complétée, programme complété. Pas d'état "dormant" puisque Zone 2 ne s'affiche que pour programmes lancés.
7. **AC7** — Zone 2 teaser N+1 calculé via **nouvelle méthode** `NextSessionResolver.nextTwoSessions(for: AdaptedProgramRecord, now: Date) -> (focal: Result?, teaser: Result?)` :
   - Doit **réutiliser la logique blocage doux deadline** (`.planned + .deadlineFixed/.deadlineEstimated` retourne la première semaine ≤ currentWeek qui a du pending) pour garantir cohérence entre `focal` et `teaser`.
   - Teaser affiché juste sous la séance focale, **toujours visible** (pas de scroll), hauteur réduite (~60-80pt) : préfixe localisé "Puis :" + titre + 1 ligne meta + chevron ⏵ tap → navigue vers la session dans `AdaptedProgramView`.
   - Si pas de teaser (programme à 1 seule session restante ou semaine complétée) → afficher message court localisé "Dernière séance de la semaine".

### Partie (c) — Section "Préparés" (Zone 3)

8. **AC8** — Nouveau composant `DormantProgramsList` (`Views/Screens/Dashboard/DormantProgramsList.swift`) :
   - Section header : `Text("dashboard.section.dormants.title")` ("Préparés" / "Prepared")
   - Compteur entre parenthèses : `(\(dormants.count))`
   - Liste verticale `ForEach(dormants)` rendant un nouveau composant `DormantProgramCard` (ou variante `compact: true` de `ProgramCard`, choix dev) :
     - Largeur 100% du parent (vs carrousel = largeur fixe)
     - Hauteur ~80-100pt
     - Badge "Préparé" en haut + opacité 0.9 sur le contenu
   - Tap sur une card → push `AdaptedProgramView` (cas normal, déjà géré).
9. **AC9** — Mode `.dormantOnly` : la `DormantProgramsList` est l'**unique** contenu visible (pas de carrousel, pas de séance focale). Header de page = `Text("dashboard.dormants_only.title")` ("Programmes préparés" / "Prepared programs") + nav bar usuelle. En `.dormantOnly` : `currentSelectedId` retourne `nil`, `selectProgram(id:)` est no-op (gardes ajoutés).

### Partie (d) — Mode `.empty`

10. **AC10** — `EmptyDashboardView` est **simplifiée** : suppression de la section "SUGGESTIONS POUR TOI" (les suggestions sont désormais des dormants persistés). Conservation du hero card + lien "Crée sur mesure". CTA central renvoie vers questionnaire universel. **Le paramètre `suggestions: [ProgramTemplate]` du constructeur est supprimé** — call-sites (`SessionView.swift`) doivent être mis à jour.
11. **AC11** — Le mode `.empty` ne devrait être atteint que si l'user supprime explicitement tous ses programmes (lancés + dormants). Cas edge, pas le chemin d'usage principal.

### Partie (e) — Bootstrap dormants au 1er launch

12. **AC12** — Nouveau service `DormantBootstrapService` (`Coaching/Bootstrap/DormantBootstrapService.swift`) :
    - Méthode `func bootstrapIfNeeded() async throws -> Int` (retourne le nombre de dormants créés)
    - Vérifie un flag `coachingProfile.bootstrappedDormants: Bool` (champ à ajouter au `CoachingProfile` modèle SwiftData + colonne `coaching_profiles.bootstrapped_dormants`)
    - Si flag = `false` ET `dormantSummaries.isEmpty && startedSummaries.isEmpty` :
      - **Set flag = true ET persiste AVANT toute génération de dormant** (idempotent en cas d'échec partiel — pas de retry au prochain launch même si certaines persistances échouent)
      - Appelle `ProgramTemplateSelector.selectTopN(profile:, n: 3)` (selectTopN existant ligne 72 — pas modifié)
      - Pour chaque template retenu (jusqu'à 3) : utilise la **nouvelle méthode** `AutoProgramFactory.previewGenerate(template: ProgramTemplate, sportProfile: CoachingSportProfile, userId: UUID) async throws -> AutoProgramPreview` (cf AC12bis) puis `commit(preview:, userId:)` pour persister en dormant (`weekStartDate = nil` par défaut dans `AdaptedProgramRecord(from:...)`)
      - Catch silencieusement `ProgramCapReached.dormant(limit:)` → log non-bloquant, on continue (un compte avec déjà ≥10 dormants pré-bootstrap reste rare mais théoriquement possible)
    - Idempotent : si flag = `true`, no-op (retourne 0).
12bis. **AC12bis** — Extension `AutoProgramFactory` (`Coaching/Factory/AutoProgramFactory.swift`) : ajout d'une nouvelle méthode `previewGenerate(template:, sportProfile:, userId:) async throws -> AutoProgramPreview` qui **skip la sélection interne** (`selector.select`) et accepte un template injecté. La méthode existante `previewGenerate(sportCode:, userId:, autoprofileLevel:)` reste inchangée (callers actuels préservés). La nouvelle réutilise `adapterService.adapt(template:, sportProfile:, coachingProfile:)` à l'identique.
13. **AC13** — Trigger bootstrap : **uniquement** à la fin de `OnboardingViewModel.finalize() async` (ligne 306) après création du profil + premier sport choisi. Pas d'appel depuis `SessionDashboardViewModel.refresh()` (pour ne pas re-déclencher chez les users existants pre-3.15 — Sophie flip le flag manuellement via dashboard Supabase pour son compte existant). Si `bootstrapIfNeeded()` throw une exception inattendue → flag flippé manuellement par admin / log d'erreur, l'user atterrit en mode `.empty` simple (acceptable, bouton "Crée un programme" reste fonctionnel).
14. **AC14** — Si `selectTopN(n: 3)` retourne moins de 3 templates (profil très contraint) → on persiste ce qu'on a (1 ou 2 dormants). Pas d'erreur.
15. **AC15** — Pas de regénération automatique. Si l'user supprime les 3 dormants bootstrappés → ils ne reviennent pas (flag déjà = true).

### Partie (f) — Migration Supabase

16. **AC16** — Migration SQL `008_add_bootstrapped_dormants_flag.sql` :
    - `ALTER TABLE coaching_profiles ADD COLUMN bootstrapped_dormants BOOLEAN NOT NULL DEFAULT FALSE;`
    - **Note** : Sophie est seul user actuellement. Pour son compte existant, le flag reste `false` à la première ouverture post-3.15 — mais comme `startedSummaries.isEmpty == false` (elle a des programmes), le bootstrap est skip de toute façon (test `startedSummaries.isEmpty && dormantSummaries.isEmpty`). Si Sophie veut tester le bootstrap, elle delete tous ses programmes et flip manuellement le flag à `false` via dashboard Supabase.
    - Migration cible `coaching_profiles` (CoachingSage-spécifique), **PAS** `core_profiles` (cross-app GardenSage/TailorSage/CoachingSage).
17. **AC17** — Modifications côté Swift :
    - `Models/CoachingProfile.swift` (`final class`, SwiftData `@Model`) : ajout `var bootstrappedDormants: Bool = false` avec default
    - `Services/DTOs/CoachingProfileDTO.swift` : ajout `let bootstrappedDormants: Bool` avec default decoder (`= false`) pour rétrocompat des rows sans la colonne (cas race deploy migration)
    - `Repositories/Implementations/DefaultCoachingProfileRepository.swift` : encoder/decoder du nouveau flag + upsert Supabase

### Partie (g) — Caps Story 3.10 préservés

18. **AC18** — Le bootstrap respecte le cap `dormantCap = 10` :
    - Pré-check : si `try await adaptedProgramRepository.fetchDormantCount() >= 10` → no-op + flag = true
    - Sinon, génère jusqu'à `min(3, 10 - currentDormantCount)` dormants
    - Catch `ProgramCapReached.dormant(limit:)` thrown par `save()` silencieusement (sécurité ceinture+bretelles)

### Partie (h) — i18n FR + EN

19. **AC19** — Nouvelles clés `Localizable.xcstrings` :
    - `dashboard.section.in_progress.title` → "Programmes en cours" / "Active programs"
    - `dashboard.section.next_session.title` → "Ta prochaine séance" / "Your next session"
    - `dashboard.section.dormants.title` → "Préparés" / "Prepared"
    - `dashboard.dormant.badge.prepared` → "Préparé" / "Prepared"
    - `dashboard.next_session.teaser.prefix` → "Puis :" / "Next:" (préfixe teaser N+1)
    - `dashboard.next_session.teaser.last_of_week` → "Dernière séance de la semaine" / "Last session of the week"
    - `dashboard.dormants_only.title` → "Programmes préparés" / "Prepared programs"
    - `dashboard.dormants.count.suffix` → " (%lld)" / " (%lld)" (compteur, `lld` car `Int`)
20. **AC20** — Aucune `LocalizedStringKey("foo.\(bar)")` avec interpolation (anti-pattern `hotfix_2026_05_12_adapted_program_i18n.md`). Utiliser `Sport.localizedKey` / `Level.localizedKey` statiques si besoin.

### Partie (i) — Tests

21. **AC21** — Tests `SessionDashboardViewModelSplitTests.swift` (nouveau fichier) :
    - `test_split_started_dormant_correct` : 2 lancés + 3 dormants → 2 started, 3 dormant, mode `.active`
    - `test_mode_dormantOnly_when_no_started` : 0 lancés + 3 dormants → mode `.dormantOnly`
    - `test_mode_empty_when_nothing` : 0 lancés + 0 dormants → mode `.empty`
    - `test_selected_id_only_references_started` : `selectedId` change quand un started disparaît (archivé) → ne pointe jamais sur un dormant
    - `test_select_program_noop_in_dormantOnly` : `selectProgram(id:)` no-op + `currentSelectedId == nil` quand `mode == .dormantOnly`
22. **AC22** — Tests `DormantBootstrapServiceTests.swift` (nouveau fichier, in-memory `ModelContainer` — pattern direct `Schema(...)` + `ModelConfiguration(isStoredInMemoryOnly: true)` SANS `TestContainer.shared` pour éviter hang in-memory cf `lessons_swiftdata_inmemory_test_hang.md`, et **isoler par modèle** si crash `FetchDescriptor`) :
    - `test_bootstrap_when_flag_false_and_no_programs` : crée 3 dormants, flag → true
    - `test_skip_when_flag_true` : no-op
    - `test_skip_when_programs_exist` : no-op, flag → true quand même (ou no-op selon décision impl — clarifier que flag passe true uniquement après persistance d'au moins 1 dormant OU si flag set avant garde)
    - `test_partial_bootstrap_if_selectTopN_returns_less` : 2 templates → 2 dormants
    - `test_skip_when_dormant_cap_reached` : 10 dormants déjà présents → no-op, flag → true
    - `test_handle_program_cap_reached_silently` : cap atteint pendant la boucle → on continue/sort sans throw
23. **AC23** — Tests `NextSessionResolverTests` (ajouter à fichier existant) :
    - `test_nextTwoSessions_returns_focal_and_teaser_when_available` : programme avec 3 sessions restantes → tuple `(focal: not nil, teaser: not nil)`
    - `test_nextTwoSessions_returns_focal_only_when_last_of_week` : programme à 1 session restante → tuple `(focal: not nil, teaser: nil)`
    - `test_nextTwoSessions_respects_deadline_block` : programme `.planned + .deadlineFixed` avec semaine S2 incomplète et currentWeek=S3 → focal = première session pending S2, teaser = 2e session pending S2 (pas S3)
24. **AC24** — **Validation visuelle via ui-reviewer** (pas de snapshot tests Swift — dépendance `swift-snapshot-testing` non installée, l'ajouter coûterait +0.5j hors-scope) :
    - `DashboardView_mode_active_with_dormants_FR`
    - `DashboardView_mode_active_without_dormants_FR`
    - `DashboardView_mode_dormantOnly_FR`
    - `DashboardView_mode_empty_FR`
    - Idem EN (au minimum 1 par mode pour valider i18n FR↔EN, cf `epic3_story310_done.md` itération FR/EN ui-reviewer)

## Hors scope (déférés)

- **OAuth Strava** (toujours hors V1 — cf `decision_onboarding_apps_non_sync_sante.md`).
- **Filtre `selectTopN` excluant sports déjà couverts** : pour la V1 du bootstrap, on prend les 3 meilleurs templates tels que `selectTopN` les classe, sans filtrer. Risque d'avoir 2 templates Course différents si profil très run-centric — acceptable, l'user peut delete. Filtre déféré V2.
- **Regénération suggestions** quand l'user delete tous ses dormants : non, on respecte la décision "plus jamais de génération auto".
- **Animation transition dormant → started** au tap "Démarrer ce programme" : pas d'animation custom, push standard suffisant.
- **Drag & drop pour réordonner dormants** : non, tri auto par `lastUpdatedAt desc`.
- **Snapshot tests Swift** : non, validation 100% ui-reviewer (cf AC24).

## Pré-requis bloquants

- Aucun. Story 3.14 (avatar sport questionnaire) est la dernière mergée, branche principale stable.
- Build vert main 67ef20c (hotfix upsert target_date) confirmé 2026-05-20.

## Composants techniques touchés

### Fichiers modifiés
- `Coaching/Dashboard/SessionDashboardViewModel.swift` — split `startedSummaries` / `dormantSummaries`, refonte `mode` enum, suppression `compareSummariesForCarousel`, makeProgramSummaries retourne tuple
- `Coaching/Dashboard/NextSessionResolver.swift` — ajout méthode `nextTwoSessions(for:now:)` avec respect blocage doux deadline
- `Coaching/Factory/AutoProgramFactory.swift` — ajout méthode `previewGenerate(template:, sportProfile:, userId:)` qui skip la sélection interne (méthode existante préservée)
- `Views/Screens/Dashboard/ActiveDashboardView.swift` — refonte layout 3 zones, **suppression** `singleProgramLayout` + `adaptiveGridLayout`, carrousel unique snap iOS 17
- `Views/Screens/Dashboard/EmptyDashboardView.swift` — suppression section "SUGGESTIONS POUR TOI" + paramètre `suggestions` du constructeur
- `Views/Screens/SessionView.swift` — câblage nouveau mode `.dormantOnly`, retrait `vm.emptyModeSuggestions` du call-site `EmptyDashboardView`
- `Models/CoachingProfile.swift` — ajout `var bootstrappedDormants: Bool = false`
- `Services/DTOs/CoachingProfileDTO.swift` — ajout `bootstrappedDormants: Bool` avec default decoder
- `Repositories/Implementations/DefaultCoachingProfileRepository.swift` — encoder/decoder + upsert Supabase du nouveau flag
- `ViewModels/OnboardingViewModel.swift` — appel `DormantBootstrapService.bootstrapIfNeeded()` à la fin de `finalize() async` (ligne 306)
- `Localizable.xcstrings` — 8 keys nouvelles FR + EN
- `Supabase/migrations/008_add_bootstrapped_dormants_flag.sql` — nouveau (cible `coaching_profiles`)

### Fichiers créés
- `Coaching/Bootstrap/DormantBootstrapService.swift` — service bootstrap
- `Views/Screens/Dashboard/DormantProgramsList.swift` — composant section dormants
- `Views/Screens/Dashboard/DormantProgramCard.swift` (OU variante `compact: true` de `ProgramCard`)
- `Views/Screens/Dashboard/NextSessionTeaser.swift` — composant teaser N+1
- `CoachingSageTests/Coaching/Bootstrap/DormantBootstrapServiceTests.swift`
- `CoachingSageTests/Coaching/Dashboard/SessionDashboardViewModelSplitTests.swift` (tests AC21)
- `CoachingSageTests/Coaching/Dashboard/NextSessionResolverTwoSessionsTests.swift` (tests AC23 — OU extension fichier existant)

### Fichiers à supprimer (ou refactorer agressivement)
- `compareSummariesForCarousel()` dans `SessionDashboardViewModel`
- `singleProgramLayout` + `adaptiveGridLayout` dans `ActiveDashboardView`
- Section "SUGGESTIONS POUR TOI" dans `EmptyDashboardView` + paramètre `suggestions`
- `vm.emptyModeSuggestions` exposition publique du ViewModel (peut rester en interne pour tests, mais plus exposé à l'UI)

## Plan d'implémentation (suggéré)

**Phase 1 — Data & ViewModel (0.75j)**
- Migration SQL 008 sur `coaching_profiles`
- Ajout `bootstrappedDormants` à `CoachingProfile` + DTO + repository
- Refonte `SessionDashboardViewModel` : split listes + nouveau `mode` enum + tuple `makeProgramSummaries` + tests AC21
- Extension `NextSessionResolver.nextTwoSessions(for:now:)` + tests AC23

**Phase 2 — Bootstrap service + Factory extension (1j)**
- Ajout `AutoProgramFactory.previewGenerate(template:, sportProfile:, userId:)` (AC12bis)
- `DormantBootstrapService` + tests AC22 (in-memory)
- Hook dans `OnboardingViewModel.finalize()`

**Phase 3 — UI refonte + i18n (1.75j)**
- `NextSessionTeaser` composant
- `DormantProgramsList` + `DormantProgramCard` composants
- Refonte `ActiveDashboardView` en 3 zones (suppression 3 layouts adaptatifs)
- Mode `.dormantOnly` dans `SessionView` (header dédié)
- Simplification `EmptyDashboardView` (retrait `suggestions`)
- i18n FR + EN (8 keys), 0 interpolation `LocalizedStringKey`

**Phase 4 — Validation (0.75j)**
- `mcp__xcode__BuildProject` vert
- `RunSomeTests` sur classes touchées (SessionDashboardViewModel*, DormantBootstrap*, NextSessionResolver*, CoachingProfileRepository*)
- ui-reviewer 4 scénarios FR + 1 EN (cf AC24)
- Fix findings P0/P1 (max 2-3 tentatives par bug — règle SOPDDL)
- Commit + merge no-ff + push

**Buffer P0-2** : 0.25j déjà absorbé dans Phase 1 (extension NextSessionResolver).

## Risques identifiés

1. **Concurrence bootstrap** : si l'user complète l'onboarding ET ouvre le dashboard en parallèle, risque de double bootstrap. Mitigation AC12 : **set flag = true et persiste-le AVANT toute génération de dormant** (idempotent même en cas d'échec partiel — pas de retry au prochain launch).
2. **Cap dormants atteint au bootstrap** : cas pathologique. Mitigation AC18 : pré-check `fetchDormantCount` + catch `ProgramCapReached.dormant` silencieusement.
3. **Migration Supabase 008** : déployer manuellement via dashboard Supabase avant le merge (cf hotfix 2026-05-20 et story sœur 3.z — pattern habituel). Sinon les users qui ouvrent l'app après merge auront un decoder error sur `bootstrappedDormants` jusqu'à ce que la migration tourne — d'où le default `false` dans le DTO pour rétrocompat (AC17).
4. **`scrollPosition` carrousel iOS 17** : ne pointe que sur `startedSummaries`. Si l'user archive le programme sélectionné, le `selectedId` doit être réassigné au premier started restant (cas déjà géré par le ViewModel actuel — vérifier qu'il survit au refacto split).
5. **Suppression 3 layouts adaptatifs** : risque visuel pour l'user qui avait 1 ou 2 programmes (passe d'un full-width / grid à un carrousel à 1 ou 2 cards — peut paraître vide). Mitigation : largeur card carrousel élevée à ~85% du viewport quand `programs.count <= 2` (à valider en ui-reviewer).
6. **Hang test SwiftData in-memory** : suivre pattern `Schema(...) + ModelConfiguration(isStoredInMemoryOnly: true)` direct, **PAS** `TestContainer.shared`. Isoler par modèle si crash `FetchDescriptor`. Cf `lessons_swiftdata_inmemory_test_hang.md` + `dette_swiftdata_test_host_hang.md`.

## Métriques de succès

- Sophie peut créer 1 programme + voir ses dormants préservés en bas (test simu validation)
- Sophie peut switch entre 3 programmes via le carrousel et voir la séance focale changer en cohérence
- Au 1er launch sur un nouveau compte (post-onboarding), 3 dormants apparaissent automatiquement
- ui-reviewer 4/4 scénarios FR + 1/1 EN READY (pas P0 ouvert)
- BuildProject vert + tests verts sur classes touchées

## Validation Sophie

- [x] Cadrage produit OK (décisions 1-8 figées 2026-05-20)
- [x] AC reviewés par agent Plan + fixes P0+P1 appliqués 2026-05-20
- [ ] Cmd-go pour démarrage impl (création branche `epic-3/story-3.15-dashboard-hierarchical-refonte`)
