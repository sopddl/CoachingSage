---
stepsCompleted: [1, 2, 3, 4, 5, 6, 7, 8]
lastStep: 8
status: 'complete'
completedAt: '2026-03-22'
inputDocuments:
  - "prd-CoachingSage.md"
  - "architecture.md"
  - "architecture-TailorSage.md"
  - "sage-app-blueprint.md"
  - "product-brief-CoachingSage-2026-03-21.md"
workflowType: 'architecture'
project_name: 'CoachingSage'
user_name: 'Sophie'
date: '2026-03-21'
---

# Architecture Decision Document — CoachingSage

_This document builds collaboratively through step-by-step discovery. Sections are appended as we work through each architectural decision together._

## Project Context Analysis

### Requirements Overview

**57 FRs organisees en 10 domaines :**

| Domaine | FRs | Implication architecturale |
|---|---|---|
| Profil & Onboarding (FR1-8) | 8 | Profil multi-sport riche → modele de donnees extensible par sport |
| Coach IA Conversationnel (FR9-17) | 9 | Claude API via Edge Function, memoire conversationnelle, contexte utilisateur complet |
| Generation Programmes (FR18-24) | 7 | Coach = expert autonome (pas de catalogue statique). Prompts systeme par sport |
| Tracking en Seance (FR25-30) | 6 | CoreLocation GPS background, chronometre, compteur reps — interfaces multiples par sport. Offline obligatoire |
| Suivi Progression (FR31-36) | 6 | Graphiques, records, tendances — calculs locaux SwiftData |
| Adaptation Dynamique (FR37-40) | 4 | Coach reorganise les programmes — logique IA |
| HealthKit & Donnees Externes (FR41-46) | 6 | HealthKit read/write, Strava API export. Hub universel toutes montres |
| Notifications (FR47-50) | 4 | APNs push + notifications locales (rappels seances) |
| Auth & Donnees (FR51-55) | 5 | Herite de SageCore — Apple Sign In, Supabase, offline sync |
| Localisation (FR56-57) | 2 | FR + EN, Coach bilingue |

**NFRs critiques :**

| NFR | Impact architectural |
|---|---|
| Generation programme < 5s | Edge Function Claude API — latence reseau + generation |
| Tracking GPS sans crash 100% | CoreLocation background mode robuste, gestion batterie |
| Zero perte donnees seance | SwiftData offline-first + PendingOperation sync |
| HealthKit lecture toutes sources | Un seul lecteur HealthKit, pas d'API par marque |
| Export Strava auto au retour online | PendingOperation enqueue + retry |
| Disclaimer medical | Affichage obligatoire onboarding + parametres |

### Scale & Complexity

- **Complexite : HIGH** — GPS tracking, multi-sport, interfaces tracking multiples, APIs externes
- **Domaine primaire : Mobile iOS natif** (SwiftUI + SwiftData + Supabase + Claude API + HealthKit + CoreLocation + Strava API)
- **Composants architecturaux estimes : ~18**
- **Contexte dev : Solo (Sophie + Claude Code)**

### Technical Constraints & Dependencies

| Contrainte | Source |
|---|---|
| iOS 17+ obligatoire | SwiftData + @Observable (plateforme Sage) |
| SageCore = package partage, pas de @Model dedans | Sage Architecture D5 |
| Fichiers [COPIE IDENTIQUE] depuis GardenSage/TaylorSage | Sage App Blueprint |
| Supabase EU Frankfurt | RGPD donnees sante |
| Cles Claude API uniquement en Edge Function | Sage Architecture D7 |
| CoreLocation background mode | Spike Epic 0 requis |
| HealthKit entitlements | Review Apple specifique |
| Strava API | OAuth2, rate limits, format activite specifique |

### Orientations Architecturales Fondamentales

1. **Offline-first complet** — SwiftData = source de verite. Tracking offline. Coach necessite connexion.
2. **Coach = Edge Function Claude API** — meme pattern Flore/Coco. Persona + prompts sport en env var.
3. **Pas de catalogue statique** — Coach est l'expert. Programmes generes par IA, pas assembles depuis une base.
4. **HealthKit comme hub unique** — zero integration par marque. Un seul lecteur.
5. **Tracking multi-interface** — interface adaptee au sport : GPS+chrono (endurance), reps/series/poids (muscu), intervalles (autres). Pattern Strategy.
6. **Export > Import** — V1 exporte vers Strava et Apple Health. Pas d'import.

### Cross-Cutting Concerns Identifiees

| Concern | Impact |
|---|---|
| **Offline-first** | Toutes les couches sauf Coach (generation) |
| **Multi-sport** | Data model, UI tracking, Coach prompts, progression |
| **Coach IA** | Transversal — generation, adaptation, conversation, engagement |
| **HealthKit** | Tracking, progression, export Apple Health |
| **Authentification** | Herite SageCore |
| **Localisation** | UI + Coach bilingue FR/EN |
| **Testabilite** | Repository Pattern, mocks, separation ViewModel/Services |

### Differences architecturales vs GardenSage et TaylorSage

| Aspect | GardenSage | TaylorSage | CoachingSage |
|---|---|---|---|
| Entite centrale | Plant (catalogue) | Pattern (base + options) | Program (genere par IA) |
| User → Projets | 1 User → 1 Garden | 1 User → N SewingProjects | 1 User → N Programs |
| Catalogue statique | plants.json (150) | Patterns + Options | **Aucun** — Coach est l'expert |
| Output physique | Aucun | PDF patron | Aucun |
| Tracking temps reel | Non | Non | **Oui — GPS, chrono, reps** |
| APIs externes | Aucune | Aucune | **Strava + HealthKit** |
| IA conversationnelle | Flore | Coco | Coach |

## Starter Template Evaluation

### Approche : Sage App Blueprint + GardenSage/TaylorSage Clone

Pas de starter CLI — projet cree manuellement via Xcode en suivant le `sage-app-blueprint.md`. Stack defini par la plateforme Sage. 3e app, processus rode.

**Initialisation :**
```
Xcode → File → New Project → iOS → App
Product Name: CoachingSage
Bundle ID: com.sopddl.coachingsage.app
+ SageCore local SPM dependency
+ Ajout au Sage.xcworkspace
```

### Decisions heritees de la plateforme Sage

| Decision | Valeur | Source |
|---|---|---|
| Langage | Swift 5.9+ | Sage Platform |
| UI | SwiftUI + @Observable | iOS 17+ |
| Persistance | SwiftData (offline-first) | Sage Architecture D2 |
| Backend | Supabase (PostgreSQL + RLS + Auth + Edge Functions) | Sage Architecture D3 |
| Auth | Apple Sign In + Email | App Store 4.8 |
| Package partage | SageCore (SPM local) | Sage Architecture D5 |
| CI/CD | Xcode Cloud | Sage Platform |
| IA | Claude API via Edge Function | Sage Architecture D7 |
| Tests | XCTest + XCUITest | GardenSage pattern |
| Config | xcconfig (Debug/Staging/Release) + .gitignore | Sage Architecture D6 |

**Fichiers [COPIE IDENTIQUE] depuis GardenSage/TaylorSage :**
SageCoreProfile, PendingOperation, AuthService, AuthView, AuthViewModel, CoreProfileRepository, Color+Sage, SyncService

### Nouveautes techniques CoachingSage

| Technologie | Usage | Nouveau ? |
|---|---|---|
| CoreLocation (background) | Tracking GPS endurance | **Oui** — jamais fait dans les apps Sage |
| HealthKit (read + write) | Hub donnees montres/iPhone | **Oui** — nouveau framework |
| Strava API (OAuth2 + REST) | Export activites | **Oui** — premiere API externe |
| Charts framework (Swift Charts) | Graphiques progression | **Oui** — nouveau framework |
| Timer/Stopwatch | Chronometre seances | Nouveau pattern mais standard iOS |

## Core Architectural Decisions

### Decisions heritees de la plateforme Sage

Auth, Supabase, SwiftData, offline-first, SageCore, CI/CD, Edge Functions, RLS, RGPD — tout herite.

### Data Architecture — Modele de donnees CoachingSage

**Entites et relations :**

```
SageCoreProfile [COPIE IDENTIQUE]
  └── CoachingProfile (sports[], niveauGlobal, poids, taille, objectifs[], equipement[], contraintes[], frequence)

Program (genere par Coach)
  ├── id, coreProfileId (owner)
  ├── sports: [String] (multi-sport si combine)
  ├── name, objective, durationWeeks
  ├── status: ProgramStatus (active/paused/completed)
  ├── generatedPrompt: Data (JSON — pour regeneration)
  └── sync + soft delete

ProgramWeek
  ├── id, programId (FK)
  ├── weekNumber: Int
  └── coachNotes: String? (ajustements dynamiques Coach)

Session (seance planifiee)
  ├── id, programWeekId (FK)
  ├── sport: String, dayOfWeek: Int
  ├── exercises: Data (JSON — generes par Coach)
  ├── status: SessionStatus (planned/completed/skipped/adapted)
  └── plannedDurationMinutes: Int

SessionResult (seance realisee — tracking)
  ├── id, sessionId (FK)
  ├── startedAt, completedAt, durationSeconds
  ├── trackingData: Data (JSON — GPS trace, reps/sets, chrono selon sport)
  ├── rpe: Int? (effort percu 1-10)
  ├── healthKitWorkoutId: String?
  └── stravaActivityId: String?

PersonalRecord
  ├── id, coreProfileId
  ├── sport, exerciseName, metric, value, unit
  └── achievedAt
```

**Decisions cles data model :**
- Session.exercises = JSON (genere par Coach, pas de catalogue)
- ProgramWeek = entite separee (Coach modifie une semaine sans regenerer le programme)
- Sport = enum Swift (offline-friendly, nouveau sport = maj app)
- SessionResult.trackingData = JSON polymorphe selon le sport
- Toutes entites : soft delete + pg_cron purge 30j

### Authentication & Security

Herite SageCore. Ajout : disclaimer medical (consentement stocke dans CoachingProfile).
- RLS sur toutes les tables : `auth.uid() = core_profile_id`
- Donnees sante (HealthKit) : acces uniquement aux types declares, consentement explicite
- Cles Claude API : uniquement en Edge Function, jamais cote client

### API & Communication — Edge Function Coach

- Edge function : `sage-coaching-ai`
- **Un seul prompt systeme** + sport/profil en parametre dynamique (pas N prompts par sport)
- Contexte envoye a Coach : profil complet, programme en cours, seance actuelle, historique progression, contraintes
- Memoire : historique programmes passes cote client (SwiftData)

### Frontend Architecture — Navigation

```
TabView (4 onglets)
├── Tab 1 : Programmes (hub — liste programmes actifs/termines)
│   └── Detail programme → semaines, seances, progression
├── Tab 2 : Tracking (lancer une seance — interface adaptee au sport)
├── Tab 3 : Progression (graphiques, records, tendances)
├── Tab 4 : Profil (compte, sports, objectifs, HealthKit, preferences)
└── Bouton flottant Coach (global, contextuel)
    → Dans un programme : Coach connait le contexte
    → Dans le tracking : Coach peut adapter la seance en cours
    → Dans la progression : Coach analyse et propose
```

### Tracking Engine — Pattern Strategy

```swift
protocol TrackingEngine {
    var sport: Sport { get }
    func start()
    func pause()
    func resume()
    func stop() -> SessionResult
    func currentMetrics() -> TrackingMetrics
}
```

4 implementations :
- `EnduranceTrackingEngine` — GPS + chrono + allure + distance (running, velo, natation ext.)
- `StrengthTrackingEngine` — Reps + series + poids + repos (musculation)
- `IntervalTrackingEngine` — Chrono + intervalles travail/repos (HIIT, natation piscine)
- `SimpleTrackingEngine` — Chrono seul (yoga, stretching, tennis drills)

Selection automatique selon le sport de la seance.

### HealthKit Service

Un seul lecteur/ecriteur HealthKit. Toutes sources confondues (Apple Watch, Garmin, Fitbit, iPhone).

```swift
protocol HealthKitServiceProtocol {
    func requestAuthorization() async throws
    func readWorkouts(since: Date) async throws -> [HKWorkout]
    func readSteps(for date: Date) async throws -> Int
    func readHeartRate(for workout: HKWorkout) async throws -> [HeartRateSample]
    func writeWorkout(_ result: SessionResult) async throws
}
```

### Strava Export Service

OAuth2 + export activite. Enqueue en PendingOperation si offline.

```swift
protocol StravaExportServiceProtocol {
    func authenticate() async throws
    func exportActivity(_ result: SessionResult) async throws -> String
    func isConnected() -> Bool
}
```

### Decisions reportees (Post-MVP)

| Decision | Version |
|---|---|
| StoreKit 2 (achats in-app, freemium) | Phase 2 |
| WatchKit (Apple Watch native) | V2 |
| Strava/Garmin import | V2 |
| Push notifications serveur (partage equipe) | V2 |
| WidgetKit (widget iOS) | V2 |

## Implementation Patterns & Consistency Rules

### Naming Patterns

**Database (Supabase PostgreSQL) :**
- Tables : `snake_case` pluriel → `core_profiles`, `coaching_profiles`, `programs`, `program_weeks`, `sessions`, `session_results`, `personal_records`
- Colonnes : `snake_case` → `core_profile_id`, `created_at`, `is_deleted`, `week_number`
- FK : `{table_singulier}_id` → `program_id`, `session_id`
- Index : `idx_{table}_{colonne}` → `idx_programs_core_profile_id`

**Swift (code) :**
- Types : `PascalCase` → `Program`, `ProgramWeek`, `SessionResult`, `PersonalRecord`
- Proprietes : `camelCase` → `coreProfileId`, `weekNumber`, `trackingData`
- Fichiers : nom du type → `Program.swift`, `SessionResultDTO.swift`
- Protocols : suffixe descriptif → `TrackingEngine`, `HealthKitServiceProtocol`, `StravaExportServiceProtocol`
- Implementations : prefixe `Default` → `DefaultHealthKitService`, `DefaultStravaExportService`
- Mocks : prefixe `Mock` → `MockHealthKitService`, `MockTrackingEngine`
- Tracking engines : suffixe `TrackingEngine` → `EnduranceTrackingEngine`, `StrengthTrackingEngine`

**JSON (donnees dynamiques) :**
- Cles : `camelCase` → `exerciseName`, `restSeconds`, `targetReps`
- Coherent avec Swift pour eviter le mapping

### Structure Patterns

```
CoachingSage/
├── App/                          # CoachingSageApp, AppDependencies, AppConstants
├── Models/                       # @Model SwiftData
│   ├── Schema/                   # SchemaV1, MigrationPlan
│   ├── SageCoreProfile.swift     # [COPIE IDENTIQUE]
│   ├── PendingOperation.swift    # [COPIE IDENTIQUE]
│   ├── CoachingProfile.swift
│   ├── Program.swift
│   ├── ProgramWeek.swift
│   ├── Session.swift
│   ├── SessionResult.swift
│   └── PersonalRecord.swift
├── ViewModels/                   # @Observable, @MainActor
│   ├── ProgramListViewModel.swift
│   ├── TrackingViewModel.swift
│   ├── ProgressionViewModel.swift
│   └── CoachViewModel.swift
├── Views/
│   ├── Screens/                  # Programs/, Tracking/, Progression/, Profile/, Coach/
│   └── Components/               # Auth/ [COPIE], Coach/, Tracking/, Charts/
├── Repositories/
│   ├── Protocols/                # 1 protocol par entite
│   └── Implementations/         # Default* implementations
├── Services/
│   ├── DTOs/                    # Objets transfert Supabase
│   ├── Protocols/               # TrackingEngine, HealthKitServiceProtocol, etc.
│   ├── SupabaseService.swift    # [COPIE adaptee]
│   ├── SyncService.swift        # [COPIE adaptee PendingOperationType]
│   ├── AuthService.swift        # [COPIE IDENTIQUE]
│   ├── CoachService.swift       # Edge Function Claude API
│   ├── HealthKitService.swift   # Lecture/ecriture HealthKit
│   ├── StravaExportService.swift # OAuth2 + export
│   └── Tracking/                # Implementations TrackingEngine
│       ├── EnduranceTrackingEngine.swift
│       ├── StrengthTrackingEngine.swift
│       ├── IntervalTrackingEngine.swift
│       └── SimpleTrackingEngine.swift
├── Resources/
│   ├── Assets.xcassets
│   └── Localizable.xcstrings
└── Utilities/
    ├── Color+Sage.swift          # [COPIE IDENTIQUE]
    ├── Color+Coaching.swift      # Tokens couleur CoachingSage
    ├── Sport.swift               # Enum Sport
    └── PreviewHelpers.swift
```

### Format Patterns

**SessionResult.trackingData (JSON polymorphe par sport) :**

Endurance :
```json
{
  "type": "endurance",
  "gpsTrace": [{"lat": 48.85, "lng": 2.35, "alt": 35, "timestamp": "..."}],
  "distanceMeters": 10230,
  "durationSeconds": 3120,
  "averagePaceSecondsPerKm": 305,
  "splits": [{"km": 1, "paceSeconds": 310}]
}
```

Musculation :
```json
{
  "type": "strength",
  "exercises": [
    {"name": "Developpe couche", "sets": [
      {"reps": 8, "weightKg": 70, "restSeconds": 90},
      {"reps": 8, "weightKg": 75, "restSeconds": 90}
    ]}
  ]
}
```

### Process Patterns

**Error Handling :**
- `AppError` (SageCore) : `.network`, `.auth`, `.sync`, `.validation`, `.notFound`
- Ajout CoachingSage : `.coachUnavailable`, `.trackingFailed`, `.healthKitDenied`, `.stravaExportFailed`
- Tous ViewModels : `ViewState<T>` (SageCore) : `.idle`, `.loading`, `.success(T)`, `.error(AppError)`

**Offline Handling :**
- Consultation programme/historique : toujours disponible (SwiftData)
- Tracking : toujours fonctionnel (donnees locales)
- Coach/generation : message "Connexion requise" avec retry
- Export Strava : enqueue automatique, export au retour en ligne

### Enforcement Guidelines

**Tous les agents IA DOIVENT :**
- Utiliser les conventions de nommage ci-dessus sans exception
- Creer Protocol + Default Implementation + Mock pour chaque service
- Utiliser `ViewState<T>` pour tous les etats de chargement
- Utiliser `AppError` pour toutes les erreurs
- Stocker les donnees dynamiques en JSON `camelCase`
- Tester chaque repository et service avec mocks

## Project Structure & Boundaries

### Architectural Boundaries

**Couche UI (Views/) :**
- SwiftUI views uniquement — aucune logique metier
- Communique UNIQUEMENT avec les ViewModels via @Observable
- Pas d'acces direct aux Repositories ou Services

**Couche ViewModel (ViewModels/) :**
- @Observable + @MainActor
- Orchestre la logique de presentation
- Appelle les Repositories et Services via protocols (injectes par AppDependencies)
- Gere les ViewState<T>

**Couche Repository (Repositories/) :**
- CRUD SwiftData + enqueue PendingOperation pour sync
- 1 protocol + 1 implementation + 1 mock par entite
- Pas de logique metier — juste persistence

**Couche Service (Services/) :**
- Logique metier et integrations externes
- CoachService, HealthKitService, StravaExportService, TrackingEngines
- Chaque service = protocol + implementation + mock

**Couche Model (Models/) :**
- @Model SwiftData — source de verite offline
- DTOs pour transfert Supabase (snake_case ↔ camelCase)
- Aucune logique — data only

### Requirements to Structure Mapping

| FR Domaine | Views | ViewModels | Repositories | Services |
|---|---|---|---|---|
| Profil & Onboarding (FR1-8) | Screens/Profile/ | ProfileViewModel | CoachingProfileRepository | — |
| Coach IA (FR9-17) | Components/Coach/ | CoachViewModel | — | CoachService |
| Generation Programmes (FR18-24) | Screens/Programs/ | ProgramListViewModel | ProgramRepository, ProgramWeekRepository | CoachService |
| Tracking (FR25-30) | Screens/Tracking/ | TrackingViewModel | SessionRepository, SessionResultRepository | Tracking/*Engine |
| Progression (FR31-36) | Screens/Progression/ | ProgressionViewModel | PersonalRecordRepository, SessionResultRepository | — |
| Adaptation (FR37-40) | — (via Coach) | CoachViewModel | ProgramWeekRepository, SessionRepository | CoachService |
| HealthKit (FR41-43) | — (background) | — | — | HealthKitService |
| Export (FR44-46) | Components/Export/ | — | — | StravaExportService |
| Notifications (FR47-50) | — (system) | — | — | NotificationService (local) |
| Auth (FR51-55) | Components/Auth/ [COPIE] | AuthViewModel [COPIE] | CoreProfileRepository [COPIE] | AuthService [COPIE] |
| Localisation (FR56-57) | Localizable.xcstrings | — | — | CoachService (langue en param) |

### Integration Points

**Internes :**
- ViewModel → Repository : via protocol inject (AppDependencies)
- ViewModel → Service : via protocol inject
- TrackingViewModel → TrackingEngine : factory par sport
- CoachService → Edge Function : HTTPS POST

**Externes :**
- CoachService → `sage-coaching-ai` Edge Function → Claude API
- HealthKitService → HealthKit framework (read/write)
- StravaExportService → Strava API (OAuth2 + REST)
- SyncService → Supabase REST API
- AuthService → Supabase Auth + Apple Sign In

### Data Flow

```
[User] → SwiftUI View → ViewModel → Repository → SwiftData (local)
                                                      ↓
                                              PendingOperation
                                                      ↓
                                              SyncService → Supabase (cloud)

[User] → Coach (bouton flottant) → CoachViewModel → CoachService → Edge Function → Claude API
                                                                          ↓
                                                                   Programme genere
                                                                          ↓
                                                              ProgramRepository → SwiftData

[User] → Tracking (seance) → TrackingViewModel → TrackingEngine (GPS/Reps/Chrono)
                                                          ↓
                                                    SessionResult
                                                          ↓
                                              SessionResultRepository → SwiftData
                                                          ↓
                                              HealthKitService → Apple Health
                                              StravaExportService → Strava
```

### Supabase Tables

```sql
-- Tables CoachingSage (en plus de core_profiles heritee)
coaching_profiles    -- profil sport (1:1 avec core_profiles)
programs            -- programmes generes par Coach
program_weeks       -- semaines d'un programme
sessions            -- seances planifiees
session_results     -- seances realisees (tracking data)
personal_records    -- records personnels

-- RLS sur toutes les tables : auth.uid() = core_profile_id
-- pg_cron purge 30j sur toutes les tables (soft delete)
```

## Architecture Validation Results

### Coherence Validation ✅

- Swift 5.9 + SwiftUI + SwiftData + @Observable — coherent, iOS 17+
- Supabase EU + RLS + Edge Functions — stack eprouve sur 2 apps
- Claude API via Edge Function — cles jamais cote client
- CoreLocation + HealthKit + Strava API — services isoles, pas de conflit
- SageCore + COPIE IDENTIQUE — 3e app, processus rode

### Requirements Coverage ✅

57/57 FRs couverts architecturalement. Tous les NFRs adresses.

| Domaine | FRs | Couvert |
|---|---|---|
| Profil & Onboarding | 8 | ✅ CoachingProfile + onboarding views |
| Coach IA | 9 | ✅ CoachService + Edge Function |
| Generation Programmes | 7 | ✅ Coach genere → ProgramRepository |
| Tracking | 6 | ✅ 4 TrackingEngines |
| Progression | 6 | ✅ ProgressionViewModel + Swift Charts |
| Adaptation | 4 | ✅ CoachService → ProgramWeekRepository |
| HealthKit | 3 | ✅ HealthKitService |
| Export | 3 | ✅ StravaExportService + PendingOperation |
| Notifications | 4 | ✅ Notifications locales + push |
| Auth | 5 | ✅ SageCore COPIE IDENTIQUE |
| Localisation | 2 | ✅ xcstrings + Coach bilingue |

### Implementation Readiness ✅

- Toutes decisions critiques documentees
- Arborescence complete, chaque FR mappe
- Patterns complets (nommage, structure, format, errors, offline)

### Gaps mineurs (a adresser pendant implementation)

- Palette couleurs `Color+Coaching.swift` — session design avec Vivienne
- Format exact prompt systeme Coach — spike Epic 0
- Schema Strava API export — spike Epic 0
- Gestion batterie tracking GPS prolonge — spike Epic 0

### Architecture Readiness Assessment

**Status : READY FOR IMPLEMENTATION — Confidence : HIGH**

**First Implementation Priority :**
1. Spike Epic 0 : CoreLocation GPS + HealthKit + qualite programmes Coach
2. Setup projet Xcode (Sage App Blueprint)
3. Supabase `sagecoach-dev` (tables + RLS)
