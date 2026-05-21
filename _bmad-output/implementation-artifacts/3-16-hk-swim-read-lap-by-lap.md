# Story 3.16 — Lecture HealthKit natation lap-by-lap + écran d'inspection DEBUG

Status: **draft** (rédigée 2026-05-21, review Sonnet 2026-05-21 → 3 P0 + 5 P1 + 3 AC manquants patchés, en attente Cmd-go Sophie)
Branche cible : `epic-3/story-3.16-hk-swim-read`
Effort estimé : **~2j** (Phase 1 read-only + UI inspection). Phase 2 wiring (autoprofile / records / calibration adapter / SportProfileView) = story séparée à scoper après analyse de la donnée réelle.

## Story

**As a** utilisatrice qui pratique la natation et porte une Apple Watch en piscine,
**I want** que l'app lise mes workouts swim Apple Watch en détail (laps, stroke par lap, pace, distance, HR) et me montre ce qu'elle voit,
**so that** je puisse vérifier la qualité des signaux Apple Watch sur mes vraies séances avant qu'on décide ensemble lesquels exploiter pour enrichir le profil natation (level, CSS, T400, style dominant, etc.).

## Contexte produit

- **Chantier V2 #5** identifié au test simu Sophie 2026-05-11 (mémoire `v2_chantiers_pedagogie_simu_2026_05_11.md` §5) : *"Pour swimming normalement avec apple watch tu as les coups de bras au 50m"* — donnée HK pas exploitée aujourd'hui.
- **État existant** :
  - `Services/HealthKitService.swift:198-227` — `workoutType()` déjà autorisé → on lit déjà les `HKWorkout.swimming` génériques (durée + HR) via `fetchRecentWorkoutDetails` et `fetchWorkoutSummary`.
  - **PAS** autorisé / **PAS** lu : `HKQuantityTypeIdentifier.distanceSwimming`, `.swimmingStrokeCount`, ni les `HKWorkoutActivity` (iOS 16+, watchOS 9+) ni les `HKWorkoutEvent.lap` avec `swimStrokeStyle` (HKMetadataKeySwimmingStrokeStyle).
  - `Coaching/AI/HealthSummaryBuilder.swift:61-72` mappe `.swimming` vers un `WorkoutSnapshot` générique pour Léon — aucune métrique nage spécifique.
  - `Coaching/AutoProfile/AutoProfileInference.swift` raisonne sur VO2max + freq workouts — aucun signal natation.
  - `Models/CoachingSportProfile.swift` : champ `recordsJsonData: Data?` déjà déclaré et **nullable** dans le @Model SwiftData mais **non typé ni exploité** → réservé pour Phase 2.
- **Templates swimming bundlés** (`Templates/Sources/TemplateLoader/Resources/Templates/swimming-*-*.json`) calibrent toutes leurs allures sur le **CSS pace** mesuré au test 400+200 m W1 J3. Doctrine `_bmad-output/planning-artifacts/doctrine-fragments/swimming.md` confirme : `CSS = (400 - 200) / (T400 - T200)` en m/s, EN1 = CSS+8-12 s/100m, etc. **Hypothèse Phase 2** : si Apple Watch fournit assez de laps qualité, on pourrait estimer un T400 sans demander à l'user le test piscine — mais on doit voir la donnée d'abord.

## Décision Sophie 2026-05-21 (figée)

1. **Phase 1 = read-only + écran d'inspection**, pas de wiring algo, pas de persistance SwiftData. On lit, on affiche, on regarde la qualité ensemble.
2. **Lecture full lap-by-lap** : `HKWorkout.swimming` → `HKWorkoutActivity` (iOS 17+) → `HKWorkoutEvent.lap` avec `swimStrokeStyle` + pace + HR par lap + distance/stroke.
3. **Trigger refresh** : onboarding swim **+** best-effort silencieux au dashboard refresh (pattern `WeeklyRegenApplicationService` Story 3.4 Phase B.4).
4. **UI** : bouton **DEBUG-only** dans `ProfileView` qui push une vue d'inspection. Aucun changement UX production user.
5. **Phase 2 (wiring) scopée après** que Sophie ait vu la donnée brute — on arbitre alors entre : autoprofil swim, records persistés, calibration ProgramAdapter (skip test CSS W1), affichage SportProfileView.

## Acceptance Criteria

### Partie (a) — Extension HealthKit authorization

1. **AC1** — Nouvelle méthode `HealthKitServiceProtocol.requestSwimAuthorizationIfNeeded()` miroir de `requestProgressAuthorizationIfNeeded()` (Services/HealthKitService.swift:229) :
   - Demande à HealthKit l'accès en lecture aux types `HKQuantityType.quantityType(forIdentifier: .distanceSwimming)` et `.swimmingStrokeCount`.
   - Idempotent : flag UserDefaults clé **exacte** `"healthkit.swim.authorization.requested.at"` stockant un `Date` (cf pattern `progressAuthorizationRequestedAtKey` ligne 169). Si déjà demandé une fois, no-op (HKit gère lui-même la persistance de la réponse user — on ne re-prompt jamais sans raison).
   - Skip en UI testing (cf `Self.isUITesting`).
2. **AC2** — Computed property `hasRequestedSwimAuthorization: Bool` (cf `hasRequestedProgressAuthorization` ligne 187). **Pattern impératif** : tester `userDefaults.object(forKey: swimAuthorizationRequestedAtKey) is Date` (et NON `.bool(forKey:)` qui est utilisé par `hasRequestedAuthorization` ligne 184 — copier-coller incorrect = bug silencieux).
3. **AC3** — **PAS d'injection dans le batch initial.** `requestProfileAuthorization()` (ligne 192) reste **inchangée** : ne pas ajouter `swimReadTypes` au batch pour éviter qu'un user "running only" reçoive une popup HK swim au onboarding (privacy UX). L'autorisation swim est **toujours** demandée via AC1 (`requestSwimAuthorizationIfNeeded`), déclenchée par AC13/AC14 **conditionnellement** à la présence d'un `CoachingSportProfile` natation actif. Pour les nouveaux comptes : l'hook AC14 dans `OnboardingViewModel.finalize()` détecte si swimming est dans les sports actifs et appelle AC1 juste après. Pour les comptes pré-existants : re-prompt silencieux via AC13 au dashboard refresh.

### Partie (b) — Service lecture lap-by-lap

4. **AC4** — Nouvelle méthode `HealthKitServiceProtocol.fetchRecentSwimWorkoutDetails(limit: Int, weeksBack: Int) async -> [HealthKitSwimWorkoutDetail]` :
   - Défaut via extension : `limit: 12, weeksBack: 12` (visibilité raisonnable des 3 derniers mois).
   - Filtre `HKWorkoutActivityType.swimming` côté predicate (`HKQuery.predicateForWorkouts(with: .swimming)`).
   - Ordre antichronologique par `endDate`.
   - Tableau vide si refus / pas autorisé / pas de données — jamais throw.
5. **AC5** — Struct `HealthKitSwimWorkoutDetail` (nouveau fichier `Services/DTOs/HealthKitSwimWorkoutDetail.swift`) :
   - `id: UUID` (HKWorkout.uuid)
   - `startDate: Date`, `endDate: Date`, `durationSeconds: TimeInterval`
   - `totalDistanceMeters: Double?` — lu depuis `workout.allStatistics[HKQuantityType.quantityType(forIdentifier: .distanceSwimming)!]?.sumQuantity()?.doubleValue(for: .meter())` (PAS depuis `workout.totalDistance` deprecated iOS 18).
   - `totalStrokes: Int?` — lu depuis `workout.allStatistics[HKQuantityType.quantityType(forIdentifier: .swimmingStrokeCount)!]?.sumQuantity()?.doubleValue(for: HKUnit.count())` cast `Int` (PAS depuis `workout.totalSwimmingStrokeCount` deprecated iOS 18).
   - `averageHeartRateBpm: Int?`, `maxHeartRateBpm: Int?` (lus via `HKStatisticsQuery` HR existant pattern `readHeartRateStats` ligne 563).
   - `poolLengthMeters: Double?` — extraction stricte : `(workout.metadata?[HKMetadataKeyLapLength] as? HKQuantity)?.doubleValue(for: .meter())`.
   - `swimLocationType: SwimLocationType?` — extraction stricte : `(workout.metadata?[HKMetadataKeySwimmingLocationType] as? Int).flatMap { HKWorkoutSwimmingLocationType(rawValue: $0) }` mappé sur l'enum custom (pool / openWater / unknown).
   - `sourceProductType: String?` (ex: "Watch10,1") + `appleWatchDetected: Bool` (préfixe "watch")
   - `laps: [HealthKitSwimLap]` — vide si le tracking n'a pas découpé en laps. **Borne max** : `prefix(200)` côté impl pour éviter UI ingérable sur 3000 m × 25 m = 120 laps × 12 séances.
6. **AC6** — Struct `HealthKitSwimLap` :
   - `index: Int` (1-based, ordre temporel)
   - `startDate: Date`, `durationSeconds: TimeInterval`
   - `distanceMeters: Double?` — **dérivée**, pas requêtée par lap. Si `workout.metadata[HKMetadataKeyLapLength]` est présent → `distanceMeters = poolLengthMeters` (un lap = une longueur de bassin par convention Apple Pool Swim). Si absent (open water, app tierce) → `nil`.
   - `strokeStyle: SwimStrokeStyle?` (enum custom : `unknown=0, mixed=1, freestyle=2, backstroke=3, breaststroke=4, butterfly=5, kickboard=6` — miroir EXACT des rawValues de `HKSwimmingStrokeStyle` iOS 16+, **PAS** 1-7).
   - `paceSecondsPer100m: Double?` (calculé : `durationSeconds / distanceMeters * 100`, nil si distance nil ou == 0).
   - `averageHeartRateBpm: Int?` (HR moyenne sur la fenêtre temporelle du lap via `HKStatisticsQuery` ciblée — 1 query par lap acceptable car distance/strokes ne sont PAS query async par lap).
   - **`strokesCount` retiré du DTO Phase 1** : pas de metadata key documentée sur les lap events pour le compte par lap, et la corrélation temporelle avec les samples cumulatifs `swimmingStrokeCount` est complexe + imprécise. Le `totalStrokes` au niveau workout (AC5) suffit pour l'inspection Phase 1. À reconsidérer Phase 2 si signal pertinent.
7. **AC7** — Extraction lap-by-lap (iOS 16+) :
   - **Cible iOS 17 min** (cf `architecture_decisions.md`) → `HKWorkoutActivity` (iOS 16+) toujours disponible API-wise. **MAIS** workouts générés par Watch pré-watchOS 9 (Series ≤ 4) peuvent avoir `workout.workoutActivities` **vide** même avec lap events présents → fallback obligatoire.
   - **Path 1 (cas nominal, Watch watchOS 9+)** : itérer `workout.workoutActivities`. Pour chaque activity, lire `activity.allStatistics` (pré-agrégée, **aucune query async** au niveau activity). Pour les laps : itérer `workout.workoutEvents` filtrés `.lap` ET dont `dateInterval` est inclus dans `activity.startDate...activity.endDate`. Stroke style depuis `event.metadata?[HKMetadataKeySwimmingStrokeStyle] as? Int`. Distance par lap = `poolLengthMeters` (AC6). HR par lap = 1 `HKStatisticsQuery` ciblée sur la fenêtre `event.dateInterval`.
   - **Path 2 (fallback, `workoutActivities.isEmpty`)** : itérer directement `workout.workoutEvents` filtrés `.lap` sur tout le workout. Même logique stroke style + distance dérivée. Logger en debug "fallback legacy workout sans activities".
   - **Path 3 (échec total — apps tierces, workout corrompu)** : retourner `laps: []`, JAMAIS bloquer la lecture du workout entier.
   - **Note pragmatique** : on découvrira à l'exécution si Sophie a effectivement des laps. Beaucoup d'Apple Watch en pool tracking n'écrivent que des évènements segment et pas forcément un lap par longueur — l'écran d'inspection nous dira la vérité.

### Partie (c) — Mock + tests

8. **AC8** — `MockHealthKitService` (`CoachingSageTests/Mocks/MockHealthKitService.swift`) gagne :
   - Stockage `var swimWorkoutDetailsToReturn: [HealthKitSwimWorkoutDetail] = []`
   - Compteur `var requestSwimAuthorizationCallCount: Int = 0`
   - Implémentation `requestSwimAuthorizationIfNeeded()` qui incrémente le compteur (no-op fonctionnel)
   - Implémentation `fetchRecentSwimWorkoutDetails` qui retourne le stockage
9. **AC9** — Test unitaire `HealthKitSwimWorkoutDetailTests` qui valide :
   - Calcul `paceSecondsPer100m` à partir de `durationSeconds + distanceMeters`
   - Cas distance nil → pace nil (pas de division par 0)
   - Cas distance = 0 → pace nil (garde-fou)
   - Décodage enum `SwimStrokeStyle` depuis les rawValues `HKSwimmingStrokeStyle` **0..6** (0 unknown, 1 mixed, 2 freestyle, 3 backstroke, 4 breaststroke, 5 butterfly, 6 kickboard iOS 16+) + cas rawValue inconnu → `.unknown`.
   - 6 cas minimum (1 pace + 2 garde-fous + 3 enum décodage).
10. **AC10** — **Aucun test live HealthKit** (pas faisable en simu / CI). Validation manuelle Sophie sur iPhone réel via écran DEBUG (AC11).

### Partie (d) — Écran d'inspection DEBUG

11. **AC11** — Nouvel écran `SwimHealthKitInspectorView` (`Views/Screens/Profile/SwimHealthKitInspectorView.swift`) :
    - Push depuis un bouton dans `ProfileView` **encadré `#if DEBUG`** (jamais visible en release).
    - Header avec compteur "N séances natation lues sur X semaines" + bouton "Rafraîchir" qui re-trigger AC4.
    - **État loading initial** : `enum LoadState { case idle, loading, loaded, refused, empty(reason: EmptyReason) }`. Spinner `ProgressView` pendant `.loading`. Pas d'état "vide" ambigu pendant que le fetch tourne.
    - Au `.task` initial : `state = .loading` → AC1 (`requestSwimAuthorizationIfNeeded`) → AC4 (`fetchRecentSwimWorkoutDetails`) → transition vers `.loaded` / `.empty` / `.refused`.
    - Liste verticale `ForEach` chaque `HealthKitSwimWorkoutDetail` :
      - Header card : date relative ("il y a 3 j"), durée, distance totale, total strokes, badge "Apple Watch" si détectée, **`swimLocationType` affiché** ("Bassin" ou "Eau libre" ou "—"), pool length si dispo.
      - DisclosureGroup expand → liste verticale des `laps` (max 200, AC5) : `#index – stroke – distance – pace (s/100m) – HR avg`.
      - **Différenciation Open Water vs Pool sans laps** : si `laps.isEmpty` ET `swimLocationType == .openWater` → ligne grise "Eau libre — pas de découpage lap (normal sur ce type de workout)". Si `laps.isEmpty` ET `swimLocationType == .pool` → ligne grise "Bassin — aucun lap détecté par la Watch (vérifie que tu as démarré l'activité 'Natation en bassin' sur la Watch)". Si `swimLocationType == nil` → "Pas de découpage lap disponible".
    - Cas `.empty(.noWorkouts)` (aucun workout swim) : message clair "Aucune séance natation Apple Watch détectée sur les 12 dernières semaines. Vérifie : (1) tu portes la Watch en piscine, (2) tu démarres le workout `Natation en bassin` sur la Watch, (3) **la Watch est bien synchronisée avec l'iPhone** (ouvre l'app Santé sur l'iPhone et tire pour rafraîchir)."
    - Cas `.refused` (refus HK) : message clair "Accès Apple Santé natation refusé. Réglages > Confidentialité > Santé > CoachingSage."
    - **Pas d'i18n** (écran DEBUG-only — strings en dur FR acceptées, pas de pollution xcstrings).
12. **AC12** — Bouton d'accès dans `ProfileView` (`Views/Screens/ProfileView.swift`) :
    - Section `#if DEBUG` ajoutée en bas de la vue (sous `privacySection`)
    - 1 `NavigationLink` "🐞 Inspecter HK natation (DEBUG)" → `SwimHealthKitInspectorView`
    - Jamais compilé en Release (preprocessor `#if DEBUG ... #endif`).

### Partie (e) — Hook trigger best-effort au dashboard refresh

13. **AC13** — **Hook dans la View, PAS dans le ViewModel.** `SessionDashboardViewModel` ne dépend pas de `HealthKitService` aujourd'hui (deps : programRepository, regen, dormantBootstrap…) — ajouter cette dépendance crée du couplage et casse les previews/tests existants. À la place : dans le `.task` body de `SessionView` (ou la view racine qui héberge le dashboard), récupérer `healthKitService` depuis `@Environment(\.appDependencies)` et appeler `healthKitService.requestSwimAuthorizationIfNeeded()` **best-effort silencieux** **uniquement si** le user a au moins un `CoachingSportProfile.sportCode == "swimming"` actif (lecture via le VM existant ou via `coachingProfileRepository.fetchSportProfiles()`).
    - Pas d'appel `fetchRecentSwimWorkoutDetails` ici (Phase 1 n'utilise pas la donnée hors écran DEBUG — éviter coût HK query inutile).
    - **Pattern** : try await, catch et log.debug en cas d'erreur, jamais surface UI.
    - **Race condition acceptée** : si AC11/AC13/AC14 s'exécutent quasi-simultanément avant que le flag UserDefaults soit persisté, HK déduplique côté système (pas de double popup utilisateur). Pas de protection additionnelle nécessaire — pattern identique à `progressAuthorizationRequestedAtKey` Story 3.9.0.
14. **AC14** — Hook équivalent dans `OnboardingViewModel.finalize()` (ou au moment où on persiste un `CoachingSportProfile` swimming) : best-effort `requestSwimAuthorizationIfNeeded()` pour les nouveaux comptes qui choisissent natation à l'onboarding.

## Architecture & fichiers touchés

### Fichiers neufs
- `Services/DTOs/HealthKitSwimWorkoutDetail.swift` (struct AC5+AC6 + enum `SwimStrokeStyle`, `SwimLocationType`)
- `Views/Screens/Profile/SwimHealthKitInspectorView.swift` (AC11)
- `CoachingSageTests/Services/HealthKitSwimWorkoutDetailTests.swift` (AC9)

### Fichiers modifiés
- `Services/HealthKitService.swift` — AC1 (`requestSwimAuthorizationIfNeeded` + clé `"healthkit.swim.authorization.requested.at"`), AC2 (`hasRequestedSwimAuthorization` via `object(forKey:) is Date`), AC4+AC7 (`fetchRecentSwimWorkoutDetails` impl avec `allStatistics` + Path 1/2/3). **AC3 ne touche PAS `requestProfileAuthorization()`** (volontaire — privacy UX, cf AC3 révisé).
- `CoachingSageTests/Mocks/MockHealthKitService.swift` — AC8
- `Views/Screens/ProfileView.swift` — AC12 (section #if DEBUG)
- `Views/Screens/SessionView.swift` (ou la vue qui héberge le dashboard) — AC13 (hook `.task` best-effort)
- `ViewModels/OnboardingViewModel.swift` — AC14

### Fichiers à NE PAS toucher en Phase 1
- `Models/CoachingSportProfile.swift` (Phase 2 : typer `recordsJsonData`)
- `Models/Schema/SchemaV*.swift` (Phase 2 : ajouter records swim si on décide de persister)
- `Coaching/AutoProfile/AutoProfileInference.swift` (Phase 2 : extension swim)
- `Coaching/Adapter/ProgramAdapter.swift` (Phase 2 : calibration CSS)
- `Coaching/AI/HealthSummaryBuilder.swift` (Phase 2 : enrichir le snapshot Léon si pertinent)

## Plan d'implémentation

**Phase 1A — Service + DTO (0.5j)**
- Créer struct `HealthKitSwimWorkoutDetail` + `HealthKitSwimLap` + enums (AC5, AC6)
- Étendre `HealthKitServiceProtocol` (AC1, AC2, AC4)
- Implémenter `requestSwimAuthorizationIfNeeded` + `swimReadTypes` (AC1, AC3)
- Implémenter `fetchRecentSwimWorkoutDetails` avec extraction lap-by-lap iOS 17+ (AC4, AC7)
- Mock complet (AC8)

**Phase 1B — Tests + écran DEBUG (0.75j)**
- Tests unitaires `HealthKitSwimWorkoutDetailTests` (AC9)
- `SwimHealthKitInspectorView` (AC11) + bouton ProfileView (AC12)
- `BuildProject` vert + tests verts

**Phase 1C — Hooks + validation (0.5j)**
- Hook dashboard refresh (AC13)
- Hook onboarding finalize (AC14)
- Test manuel iPhone réel Sophie : ouvrir l'écran DEBUG → vérifier qu'on récupère les workouts swim avec laps + paces + strokes
- Capture d'écran de la donnée brute → discussion Phase 2

## Risques identifiés

1. **Apple Watch en pool tracking ne segmente pas toujours par lap** — selon le mode (Pool Swim vs Open Water vs activité custom), `HKWorkoutEvent.lap` peut être absent ou approximatif. **Mitigation** : afficher message différencié Pool vs Open Water (AC11) et continuer à exploiter durée/distance/strokes du workout entier.
2. **Workouts Watch pré-watchOS 9 avec `workoutActivities: []`** — Series ≤ 4 ou data historique synchronisée depuis une vieille Watch peuvent retourner activities vides même avec lap events présents. **Mitigation** : Path 2 fallback AC7 itère directement `workoutEvents` du workout entier.
3. **`HKWorkoutActivity` iOS 16+** (pas 17+) — si certains workouts Sophie viennent d'apps tierces qui n'écrivent pas d'activities, fallback Path 2 AC7.
4. **Deprecation iOS 18 `totalDistance` / `totalSwimmingStrokeCount`** — pré-empté en utilisant `workout.allStatistics` (iOS 16+) dans AC5 → 0 warning Xcode 16.
5. **Re-prompt HK silencieux peut surprendre un user existant** — au prochain launch post-merge, l'iPhone affichera le sheet HK pour les 2 nouveaux types. **Mitigation** : pattern Story 3.9.0 (RHR/HRV/Sleep), Sophie l'a déjà accepté. Si pénible : on rajoute un onboarding pédagogique en Phase 2.
6. **Sync Watch-iPhone défectueuse** — la donnée HK peut être absente même avec une Watch active si l'iPhone n'a pas reçu la dernière sync. **Mitigation** : message AC11 case `.empty(.noWorkouts)` explicite ("tire pour rafraîchir l'app Santé").
7. **Calcul pace s/100m sur laps courts (25 m)** — division `durationSeconds / distanceMeters * 100` peut donner des valeurs aberrantes sur très petits laps (start/turn inclus). On l'expose quand même brut dans l'écran DEBUG, c'est ce qu'on veut voir.
8. **HKMetadataKeySwimmingStrokeStyle non écrit par certaines sources** — fallback `.unknown`. Pas bloquant.
9. **Distance par lap dérivée du `poolLengthMeters` est approximative** — si Sophie nage à un mur intermédiaire ou interrompt en milieu de longueur, la distance lap réelle ≠ poolLength. Acceptable Phase 1 (inspection, pas de calibration algo).
10. **Mac qui rame** : règle CLAUDE.md → fermer Simulator.app entre runs Xcode, kill iPhone Mirroring si CPU. Pas spécifique à cette story.

## Métriques de succès Phase 1

- Sur iPhone réel Sophie, l'écran DEBUG affiche **≥ 3 séances natation** des 12 dernières semaines (Sophie nage régulièrement → la donnée doit être présente).
- Pour chaque séance avec laps Apple Watch : on voit le stroke style par lap + pace s/100m calculée + HR moyenne par lap.
- Pour les séances sans laps : message clair, jamais crash.
- BuildProject vert + tests `HealthKitSwimWorkoutDetailTests` verts.
- Sophie peut faire un screenshot de la donnée brute → on arbitre Phase 2 (autoprofile / records / adapter / SportProfileView).

## Phase 2 (NON dans cette story — à scoper après)

Hypothèses à valider avec la donnée Sophie :
- **Autoprofil swim** : volume m/sem moyen (corrélation directe doctrine : recreational 2500-4500 m/sem, regular 5000-9000 m/sem) → inférer un `LevelEstimate` swim. **Signal le plus fiable** — étendre `AutoProfileInference` (équivalent du running existant).
- **⚠️ T400 estimé depuis HK = piège à éviter sans précautions strictes.** Aucun lap Apple Watch n'est un effort de compétition calibré (pauses mur, virages lents, push-off). Un T400 extrait des laps HK sera biaisé vers le bas → CSS sous-estimé → zones d'entraînement trop faciles → progression user freinée. Pour utiliser ce signal il faudrait au minimum : (1) filtrer par stroke style cohérent (freestyle only pour nageur crawl), (2) éliminer les laps courts (25 m avec push-off qui gonflent la pace), (3) identifier explicitement une "sortie best effort" dans l'historique (impossible sans marquage user). **Conclusion** : ne pas skipper le test CSS W1 J3 sur la base HK. Au mieux, **pré-remplir** un champ T400 dans le SportProfileView comme "estimation indicative" avec un disclaimer fort, et garder le test CSS du template W1 comme source de vérité.
- **Records persistés** : typer `CoachingSportProfile.recordsJsonData` avec une struct `SwimRecords { lastVolumeMetersWeekly: Double?, dominantStrokeStyle: SwimStrokeStyle?, estimatedT400FromHKSeconds: Int?, computedAt: Date }`. Bump Schema V10. **Pas de `cssPaceSecondsPer100m`** persisté tant qu'on n'a pas un vrai test CSS user.
- **Calibration ProgramAdapter** : **NE PAS** pré-injecter les paces EN1/EN2/EN3/CSS depuis HK seule (cf piège T400 ci-dessus). Garder le test CSS W1 J3 du template comme source de vérité. Phase 2 alternative : si user a déjà fait un test CSS sur une session précédente → re-utiliser le record persisté pour les nouveaux programmes.
- **UI SportProfileView natation** : bloc "Ce que je sais de toi en natation" (volume hebdo HK, stroke dominant, dernière séance, T400 estimé HK avec disclaimer "indicatif — confirme avec un test CSS").

Estimation Phase 2 : **~3j** si on prend les 5 items. À découper et prioriser après donnée vue.

## Validation Sophie

- [ ] Cadrage produit OK (décisions 1-5 figées 2026-05-21)
- [x] Review Sonnet 2026-05-21 → 3 P0 + 5 P1 + 3 AC manquants patchés (AC3 privacy UX, AC5/AC6/AC7 allStatistics + iOS 16+, AC11 loading + différenciation Open Water, AC13 hook View pas VM, Phase 2 caveat T400)
- [ ] Cmd-go pour démarrage impl (création branche `epic-3/story-3.16-hk-swim-read`)
