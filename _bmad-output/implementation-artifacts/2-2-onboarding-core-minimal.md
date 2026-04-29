# Story 2.2 : Onboarding Core Minimal (4 écrans)

Status: ready-for-dev

<!-- Note: Validation est optionnelle. Lance `validate-create-story` pour un quality check avant `dev-story`. -->

## Story

**As a** nouvel utilisateur CoachingSage qui vient de s'authentifier (Story 1.1b),
**I want** un onboarding court et clair qui me demande l'essentiel (prénom, langue, données perso, sports pratiqués, validation médicale),
**so that** mon profil sportif core soit créé avant d'arriver sur l'app, et que Léon (Epic 3) puisse personnaliser son premier programme dès la première vraie session.

## Acceptance Criteria

1. **AC1 — Gating onboarding dans `CoachingSageApp`** : la racine de l'app affiche maintenant 4 états (au lieu de 2) :
   - `!isAuthenticated` → `AuthView` (Story 1.1b — inchangé)
   - `isAuthenticated && isLoadingOnboardingState` → splash `ProgressView` plein écran pendant ~200-500ms le temps de hydrater le `coachingProfileRepository` (review P0-2 — évite le flash onboarding parasite quand un user a un profil Supabase mais pas encore SwiftData après réinstall).
   - `isAuthenticated && !hasCompletedOnboarding` → `OnboardingView` (cette story)
   - `isAuthenticated && hasCompletedOnboarding` → `MainTabView` (Story 1.2)
   La source de truth de `hasCompletedOnboarding` est `coachingProfile.onboardingCompletedAt != nil` (champ persisté SwiftData + Supabase, **pas UserDefaults**) — permet la sync inter-device et l'idempotence après reinstall.

   ⚠️ **`fetchCurrentProfile()` doit hydrate-on-miss** (review P0-2) : si SwiftData local nil → fetch Supabase `coaching_profiles` ; si la row existe avec `onboarding_completed_at != nil`, hydrate SwiftData et bypass onboarding. Sinon (vrai nouveau user) → onboarding. Évite l'écrasement de la row Supabase au `finalize()` quand un user revient sur un nouveau device.

2. **AC2 — `OnboardingView` à 4 écrans linéaires** : navigation forward-only via un `OnboardingViewModel @Observable` qui pilote l'index courant. Chaque écran a un bouton « Continuer » désactivé tant que les champs requis ne sont pas valides. **Pas de back arrow vers l'écran précédent** dans la TopBar (volontaire — réduit l'erreur utilisateur, simplifie la state machine V1). Si Sophie veut un back en cours d'implem, on l'ajoute en Task additionnelle.

3. **AC3 — Écran 1 : Prénom + Langue** :
   - Champ texte prénom (requis, 1-50 chars, trim côté save).
   - Sélecteur langue (FR/EN) — pré-rempli sur la `Locale.current.language.languageCode?.identifier` au moment de l'apparition de l'écran. ⚠️ La langue Apple Sign-In **n'est PAS** automatiquement la préférence app (un user peut être sur App Store EN avec préférence FR, validé Sophie 2026-04-26). L'utilisateur peut surcharger.
   - Bouton « Continuer » → sauvegarde `core_profiles.first_name` + `core_profiles.language` via `coreProfileRepository.save(...)`.

4. **AC4 — Écran 2 : Données perso (sexe, âge, poids, taille)** :
   - 4 champs : `biologicalSex` (Picker : Femme / Homme / Autre / Préfère ne pas dire), `dateOfBirth` (DatePicker `.date`, max = aujourd'hui), `weightKg` (TextField numérique, 30-250), `heightCm` (TextField numérique, 100-230).
   - **CTA « Importer depuis Apple Santé »** affiché en haut de l'écran SI `healthKitService.isHealthDataAvailable && !healthKitService.hasRequestedAuthorization`. Au tap → `requestProfileAuthorization()` puis `fetchProfileData()` → pré-remplit les 4 champs à partir des valeurs non-nil retournées. Champs nil = restent vides à saisir.
   - Si l'utilisateur a **déjà** demandé l'auth (`hasRequestedAuthorization == true`) la CTA disparaît (ne pas re-prompter, Apple décourage).
   - Si HealthKit indisponible (Mac, iPad < iPadOS 17) : CTA cachée, mais les 4 champs restent saisissables manuellement.
   - Bouton « Continuer » désactivé tant que les 4 champs ne sont pas remplis (validators de range).

5. **AC5 — Écran 3 : Sélection sports (grille 10 sports)** :
   - Grille 2 colonnes × 5 lignes, chaque cellule = icône SF Symbol + label localisé. Tap toggle la sélection.
   - **Liste V1** : `running`, `cycling`, `swimming`, `triathlon`, `strengthTraining`, `yoga`, `hiit`, `hiking`, `tennis`, `football`. Stockés comme codes string dans un enum `SportCode` côté Swift, sérialisés en `TEXT[]` Postgres.
   - **Tooltip HIIT** (validé Sophie 2026-04-26) : la cellule HIIT affiche une icône `info.circle` à côté du label. Tap sur l'icône → `.alert(...)` avec définition courte. Évite l'effet « jargon » pour les utilisatrices novices. ⚠️ **Tooltip uniquement sur HIIT** — les 9 autres sports sont jugés assez explicites (running/cycling/...). Si retours beta utilisateurs disent l'inverse, on étend Epic 7.
   - Bouton « Continuer » désactivé si 0 sport sélectionné. Aucune limite haute.
   - **Pas de questionnaire détaillé par sport** — c'est Epic 3 (`CoachingSportProfile` arrive plus tard). V1 stocke juste `coaching_profiles.active_sports: TEXT[]` = liste de codes.

6. **AC6 — Écran 4 : Disclaimer + PARQ-light + Consentement RGPD** :
   - Bloc 1 — Texte du disclaimer médical (~120 mots FR/EN, validé Sophie). Affiche un numéro de version (ex: « 1.0 ») pour pouvoir re-prompter en cas de mise à jour future.
   - Bloc 2 — **PARQ-light** (5 toggles oui/non, défaut non) :
     - q1 : « Ressentez-vous des douleurs à la poitrine ou à l'effort ? »
     - q2 : « Avez-vous des étourdissements ou perdez-vous l'équilibre ? »
     - q3 : « Souffrez-vous d'un problème articulaire aggravé par l'activité physique ? »
     - q4 : « Prenez-vous des médicaments pour la tension artérielle ou le cœur ? »
     - q5 : « Connaissez-vous une autre raison pour laquelle vous ne devriez pas faire d'exercice ? »
     Si **au moins une réponse est oui** → bandeau jaune avertissement « Consultez un médecin avant de pratiquer une activité physique intense » + flag `requires_medical_clearance = true` côté DB.
   - Bloc 3 — Toggle « J'autorise CoachingSage à collecter des données analytics anonymisées » → maps à `core_profiles.analytics_consent`. ⚠️ Toggle off par défaut (RGPD opt-in explicite).
   - Bouton final « Démarrer » → sauvegarde `coaching_profiles` complet (avec les valeurs des 3 écrans précédents accumulées dans le ViewModel) + UPDATE `core_profiles.analytics_consent` + set `coaching_profiles.onboarding_completed_at = now()` → bascule sur `MainTabView`.

7. **AC7 — Migration `002_coaching_profiles.sql`** : crée la table `coaching_profiles` côté Supabase :
   ```sql
   CREATE TABLE coaching_profiles (
     id UUID PRIMARY KEY REFERENCES core_profiles(id) ON DELETE CASCADE,
     biological_sex TEXT,                          -- "female"|"male"|"other"|"prefer_not_to_say"|null
     date_of_birth DATE,
     weight_kg DECIMAL(5,2),                       -- 30.00-250.00
     height_cm DECIMAL(5,2),                       -- 100.00-230.00
     active_sports TEXT[] NOT NULL DEFAULT '{}',   -- {"running","cycling",...}  (review P1-2 : array natif Postgres)
     parq_responses JSONB NOT NULL DEFAULT '{}',   -- 5 keys figées (voir Dev Notes "PARQ schema")
     requires_medical_clearance BOOLEAN NOT NULL DEFAULT FALSE,
     disclaimer_version_accepted TEXT,             -- "1.0"
     disclaimer_accepted_at TIMESTAMPTZ,
     onboarding_completed_at TIMESTAMPTZ,
     created_at TIMESTAMPTZ DEFAULT NOW(),
     updated_at TIMESTAMPTZ DEFAULT NOW(),
     is_soft_deleted BOOLEAN DEFAULT FALSE,
     deleted_at TIMESTAMPTZ
   );
   ```
   - **`active_sports TEXT[]`** (Postgres array natif) au lieu de `JSONB` (review P1-2) : permet à Léon Epic 3 de faire `WHERE 'running' = ANY(active_sports)` avec index GIN, plus performant que JSONB.
   - RLS : **3 policies** (SELECT/INSERT/UPDATE) — pas de policy DELETE (review P0-3) car la suppression passe par l'edge function `delete-account` Story 1.4 en `service_role` (qui bypasse RLS) + le CASCADE depuis `core_profiles`. Cohérent avec migration 001 `core_profiles` qui n'a pas non plus de policy DELETE.
   - Trigger `updated_at` : réutiliser `update_updated_at_column()` déjà défini en migration 001.
   - **`ON DELETE CASCADE`** : quand `core_profiles` est hard-delete par l'edge function `delete-account` (Story 1.4), `coaching_profiles` disparaît automatiquement. **Pas de modification AccountService nécessaire**.
   - pg_cron purge 30j : ajouter `coaching_profiles` au job `purge-rgpd-coaching-profiles` (nouveau job, même pattern que `purge-rgpd-core-profiles` migration 001:71-79).

8. **AC8 — `CoachingProfile` SwiftData model + SchemaV2** :
   - Créer `Models/CoachingProfile.swift` (`@Model final class CoachingProfile`).
   - Créer `Models/Schema/SchemaV2.swift` qui contient `SageCoreProfile + PendingOperation + CoachingProfile`.
   - Créer `Models/Schema/CoachingSageMigrationPlan.swift` (`SchemaMigrationPlan`) avec migration `SchemaV1 → SchemaV2` (lightweight — ajout d'un nouveau model, pas de field rename → migration auto SwiftData).
   - Modifier `CoachingSageApp.swift` pour utiliser `SchemaV2.self` dans le `Schema(...)` du modelContainer + passer `migrationPlan: CoachingSageMigrationPlan.self`.

9. **AC9 — `CoachingProfileRepository` protocol + Default impl + DTO** :
   - Pattern identique à `CoreProfileRepository` (Story 1.1a) :
     - `func fetchCurrentProfile() async throws -> CoachingProfile?`
     - `func save(_ profile: CoachingProfile) async throws` — UPSERT SwiftData + UPSERT Supabase (`coaching_profiles`).
     - Pas de `softDelete` ni `cleanupOrphan` V1 (cascade DB suffit).
   - DTO `CoachingProfileDTO` côté `Services/DTOs/` pour mapping JSON ↔ SwiftData.
   - Guard `IS_UI_TESTING` côté `save()` (cohérent CoreProfileRepository).
   - Injection dans `AppDependencies`.

10. **AC10 — Localisation FR + EN** : ~30 clés `Localizable.xcstrings` :
   - `onboarding.welcome.title` / `onboarding.continue` / `onboarding.start` / `onboarding.firstName.label` / `onboarding.firstName.placeholder` / `onboarding.language.label` / `onboarding.personalData.title` / `onboarding.personalData.healthKit.cta` / `onboarding.personalData.sex.female` / `.male` / `.other` / `.preferNotToSay` / `onboarding.personalData.dob.label` / `.weight.label` / `.height.label` / `onboarding.sports.title` / `onboarding.sports.helper` / `onboarding.sport.running` / `.cycling` / `.swimming` / `.triathlon` / `.strengthTraining` / `.yoga` / `.hiit` / `.hiking` / `.tennis` / `.football` / `onboarding.sport.hiit.tooltip.title` / `onboarding.sport.hiit.tooltip.body` / `onboarding.disclaimer.title` / `onboarding.disclaimer.body` / `onboarding.parq.title` / `onboarding.parq.q1` … `q5` / `onboarding.parq.warning` / `onboarding.analytics.toggle.label` / `onboarding.analytics.toggle.helper`.
   - **Tooltip HIIT** :
     - FR title : « C'est quoi le HIIT ? »
     - FR body : « HIIT (High Intensity Interval Training) : entraînement par intervalles courts et intenses, alternant efforts maximums et récupération courte. Sessions typiques de 15 à 30 minutes. »
     - EN title : « What is HIIT? »
     - EN body : « HIIT (High Intensity Interval Training): short, high-intensity intervals alternating with brief recovery. Typical sessions last 15-30 minutes. »
   - Naming `onboarding.*` standardisé. Pas de `String(localized:)` hardcodé non-localisé.

11. **AC11 — Pas d'UI test pour cette story** : règle `feedback_tests_non_regression` (test manuel Cmd+R + unit tests suffisent). Le flow onboarding sera UI-testé en bloc à la fin d'Epic 2 si on en écrit, ou pas du tout (auto mode unit-only).

## Tasks / Subtasks

- [ ] **Task 1** : Migration `002_coaching_profiles.sql` (AC: #7)
  - [ ] 1.1 Créer `CoachingSage/supabase/migrations/002_coaching_profiles.sql`. Header copier le style de migration 001.
  - [ ] 1.2 `CREATE TABLE coaching_profiles` avec FK `id REFERENCES core_profiles(id) ON DELETE CASCADE`. ⚠️ **Le CASCADE est crucial** : il évite d'avoir à toucher `AccountService` Story 1.4 quand un user demande la suppression.
  - [ ] 1.3 **3 policies RLS** (SELECT, INSERT, UPDATE) — copier le pattern `core_profiles_select_own`/`_insert_own`/`_update_own` de la migration 001:38-48. **Pas de policy DELETE** (review P0-3) : la suppression passe par l'edge function `delete-account` en `service_role` (Story 1.4) + CASCADE FK. Cohérent migration 001.
  - [ ] 1.4 Trigger `update_coaching_profiles_updated_at` réutilisant `update_updated_at_column()` (déjà défini migration 001:55-65).
  - [ ] 1.5 Index sur `is_soft_deleted` partial (cohérent migration 001:32-33).
  - [ ] 1.6 pg_cron job `purge-rgpd-coaching-profiles` (nouveau, même pattern migration 001:71-79). ⚠️ Vérifier que `pg_cron` est activé dans `Database > Extensions` du projet `coachingsage-dev` (devrait l'être depuis Story 1.1a).
  - [ ] 1.7 Sophie : déployer la migration via Supabase Dashboard SQL Editor (pas de CLI auto). Copier-coller le fichier complet, exécuter, vérifier `SELECT * FROM coaching_profiles LIMIT 1;` retourne 0 rows sans erreur.
  - [ ] 1.8 Vérifier que la suppression d'un user (DeleteAccount Story 1.4) cascade bien sur `coaching_profiles` : test manuel après implem.

- [ ] **Task 2** : `CoachingProfile` SwiftData + SchemaV2 + Migration plan (AC: #8)
  - [ ] 2.1 Créer `CoachingSage/Models/CoachingProfile.swift` :
    ```swift
    @Model final class CoachingProfile {
        @Attribute(.unique) var id: UUID                       // = SageCoreProfile.id
        var biologicalSex: String?                             // raw "female"/"male"/"other"/"prefer_not_to_say"/nil
        var dateOfBirth: Date?
        var weightKg: Double?
        var heightCm: Double?
        var activeSports: [String]                             // ["running",...] — sérialisé Postgres TEXT[]
        var parqResponses: [String: Bool]                      // 5 keys figées (voir Dev Notes "PARQ schema")
        var requiresMedicalClearance: Bool
        var disclaimerVersionAccepted: String?
        var disclaimerAcceptedAt: Date?
        var onboardingCompletedAt: Date?
        var createdAt: Date
        var updatedAt: Date
        var isSoftDeleted: Bool
        var deletedAt: Date?
        // init...
    }
    ```
    ⚠️ **Pas de relation `@Relationship` avec `SageCoreProfile`** — on linke par UUID seulement (cohérent avec le découpage SageCoreProfile = SageCore SPM partagé / CoachingProfile = local CS).
  - [ ] 2.2 Créer `CoachingSage/Models/Schema/SchemaV2.swift` :
    ```swift
    enum SchemaV2: VersionedSchema {
        static var versionIdentifier = Schema.Version(2, 0, 0)
        static var models: [any PersistentModel.Type] {
            [SageCoreProfile.self, PendingOperation.self, CoachingProfile.self]
        }
    }
    ```
  - [ ] 2.3 Créer `CoachingSage/Models/Schema/CoachingSageMigrationPlan.swift` :
    ```swift
    enum CoachingSageMigrationPlan: SchemaMigrationPlan {
        static var schemas: [any VersionedSchema.Type] { [SchemaV1.self, SchemaV2.self] }
        static var stages: [MigrationStage] {
            [.lightweight(fromVersion: SchemaV1.self, toVersion: SchemaV2.self)]
        }
    }
    ```
    Lightweight car on ajoute juste un nouveau model, pas de rename ni de transformation.
  - [ ] 2.4 ⚠️ **CRITIQUE — supprimer le bloc wipe legacy `CoachingSageApp.swift:36-51`** (review P0-1) : le code actuel utilise `swiftdata_schema_version` UserDefaults + `fm.removeItem(at: fileURL)` pour wiper le store à chaque bump. Cette stratégie est **incompatible** avec les `SchemaMigrationPlan` SwiftData. Action : retirer entièrement les lignes 35-51 (`let schemaVersion = 1` jusqu'à la fermeture du `if !isUITesting`). Retirer aussi les 2 `UserDefaults.set(schemaVersion, ...)`. Conséquence : on perd le filet « wipe de secours » mais on gagne la vraie migration.
  - [ ] 2.4bis Modifier l'init du `ModelContainer` ligne 53-57 :
    ```swift
    let container = try ModelContainer(
        for: SchemaV2.self,                              // remplace [SageCoreProfile.self, PendingOperation.self]
        migrationPlan: CoachingSageMigrationPlan.self,   // nouveau
        configurations: config
    )
    ```
    ⚠️ **Tester avec data Story 1.x existante** : avant push, lancer l'app sur un user qui a déjà un `SageCoreProfile` SwiftData (issu de Story 1.x), vérifier qu'au reboot la data est toujours là (la migration est transparente). Si wipe constaté → la migration plan est mal câblée, ne PAS commit.

- [ ] **Task 3** : `CoachingProfileRepository` protocol + impl + DTO (AC: #9)
  - [ ] 3.1 Créer `CoachingSage/Repositories/Protocols/CoachingProfileRepository.swift` :
    ```swift
    protocol CoachingProfileRepository {
        func fetchCurrentProfile() async throws -> CoachingProfile?
        func save(_ profile: CoachingProfile) async throws
    }
    ```
    Pas de `softDelete` ni `cleanupOrphan` V1 — le CASCADE Supabase + le `cleanupOrphanProfiles()` côté `CoreProfileRepository` couvrent les cas.
  - [ ] 3.2 Créer `CoachingSage/Repositories/Implementations/DefaultCoachingProfileRepository.swift`. Pattern identique à `DefaultCoreProfileRepository` :
    - `init(modelContext: ModelContext)`.
    - `fetchCurrentProfile()` : ⚠️ **Hydrate-on-miss** (review P0-2) — query SwiftData filtré sur `id == authService.currentUserId && !isSoftDeleted`. **Si nil local** : fetch Supabase `from("coaching_profiles").select().eq("id", userId).maybeSingle()`, et SI une row existe côté Supabase → l'hydrate dans SwiftData (insert + save) puis return. Sinon → return nil (vrai nouveau user, onboarding va s'afficher). Le hydrate-on-miss évite l'écrasement de la row Supabase au `finalize()` quand un user revient sur un nouveau device après réinstall.
    - `save(_ profile:)` : guard `IS_UI_TESTING` → return ; sinon UPSERT SwiftData (PersistentIdentifier) + UPSERT Supabase via `SupabaseService.shared.client.from("coaching_profiles").upsert(dto)`. ⚠️ Le UPSERT Supabase est `ON CONFLICT (id) DO UPDATE` natif — pas besoin de check préalable.
    - Pas de mention `[COPIE IDENTIQUE]` — c'est un nouveau repo CS-only.
  - [ ] 3.3 Créer `CoachingSage/Services/DTOs/CoachingProfileDTO.swift` :
    - Codable struct avec snake_case keys (`biological_sex`, `date_of_birth`, `weight_kg`, etc.) via `CodingKeys`.
    - Helpers `init(from: CoachingProfile)` et `toModel() -> CoachingProfile`.
    - ⚠️ `parqResponses: [String: Bool]` se sérialise tel quel en JSONB Supabase (Codable maps natifs).
  - [ ] 3.4 Modifier `CoachingSage/App/AppDependencies.swift` : ajouter `let coachingProfileRepository: any CoachingProfileRepository` + instanciation dans `live(modelContext:)`.

- [ ] **Task 4** : `OnboardingViewModel` + state machine (AC: #2-#6)
  - [ ] 4.1 Créer `CoachingSage/ViewModels/OnboardingViewModel.swift` (`@Observable`, `@MainActor`).
  - [ ] 4.2 Properties :
    - `var currentScreen: OnboardingScreen = .firstNameLanguage` (enum 4 cas).
    - `var firstName: String = ""`
    - `var language: String = Locale.current.language.languageCode?.identifier ?? "fr"`
    - `var biologicalSex: String? = nil`
    - `var dateOfBirth: Date? = nil`
    - `var weightKg: Double? = nil`
    - `var heightCm: Double? = nil`
    - `var activeSports: Set<String> = []`
    - `var parqResponses: [String: Bool] = PARQQuestion.defaultResponses` — 5 keys figées via enum (voir Dev Notes "PARQ schema").
    - `var analyticsConsent: Bool = false`
    - `var saveState: ViewState<Void> = .idle`
    - `private(set) var hasUserEditedScreen2: Bool = false` ⚠️ **Set à `true`** dès qu'`onChange` détecte que l'un des 4 fields écran 2 (`biologicalSex`, `dateOfBirth`, `weightKg`, `heightCm`) **a une valeur différente de sa valeur init (nil)** (review P1-1). Implémentation : helper `markScreen2Edited()` appelé depuis chaque setter de field écran 2 si la nouvelle valeur ≠ nil.
  - [ ] 4.3 Validators (computed `var canContinueScreen1: Bool`, `canContinueScreen2: Bool`, etc.).
  - [ ] 4.4 `func goNext()` : avance `currentScreen` via map enum. Si `.disclaimer` → appelle `finalize()`.
  - [ ] 4.5 `func finalize() async` :
    - Save `core_profiles` (first_name + language + analytics_consent) via `coreProfileRepository`.
    - Save `coaching_profiles` complet via `coachingProfileRepository` (incluant `onboarding_completed_at = Date()`, `disclaimer_version_accepted = "1.0"`, `disclaimer_accepted_at = Date()`, calc `requires_medical_clearance = parqResponses.values.contains(true)`).
    - Transitions `.loading` → `.success(())` ou `.error(AppError)`.
  - [ ] 4.6 `func importFromHealthKit() async` (écran 2) :
    - Appel `healthKitService.requestProfileAuthorization()` → catch silencieux (cohérent privacy semantic Story 2.1).
    - Appel `await healthKitService.fetchProfileData()`.
    - Pour chaque field non-nil retourné, **écraser le field local du VM uniquement si `hasUserEditedScreen2 == false`** (sinon préserve la saisie utilisateur — review P1-1).
    - **Mapping `HKBiologicalSex` → string** (review P1-3) : `.female → "female"`, `.male → "male"`, `.other → "other"`, `.notSet → nil` (déjà géré côté Story 2.1). Mismatch impossible avec les 4 options écran 2 (`female/male/other/preferNotToSay`) car `preferNotToSay` est uniquement saisi manuellement.
  - [ ] 4.7 `init(coreProfileRepository:, coachingProfileRepository:, healthKitService:)` — DI pour testabilité.

- [ ] **Task 5** : `OnboardingView` + 4 sub-views (AC: #2-#6)
  - [ ] 5.1 Créer `CoachingSage/Views/Screens/Onboarding/OnboardingView.swift` (conteneur + switch sur `viewModel.currentScreen`). Background `Color.coachingBackground`. Indicateur de progression (4 dots ou `ProgressView`).
  - [ ] 5.2 Créer `CoachingSage/Views/Screens/Onboarding/FirstNameLanguageView.swift` (écran 1).
  - [ ] 5.3 Créer `CoachingSage/Views/Screens/Onboarding/PersonalDataView.swift` (écran 2 — CTA HealthKit + 4 fields).
  - [ ] 5.4 Créer `CoachingSage/Views/Screens/Onboarding/SportsSelectionView.swift` (écran 3 — `LazyVGrid 2 columns`). ⚠️ **Cellule HIIT spécifique** : ajouter un `Image(systemName: "info.circle")` à côté du label (ou en overlay top-right de la cellule), tap → `.alert("onboarding.sport.hiit.tooltip.title", isPresented: $showHIITTooltip) { Button("OK", role: .cancel) {} } message: { Text("onboarding.sport.hiit.tooltip.body") }`. Tap sur l'icône info **NE doit PAS** déclencher le toggle de sélection — `Button` distinct ou `.simultaneousGesture(TapGesture().onEnded { ... })` à câbler proprement pour ne pas conflicter avec le tap principal de la cellule.
  - [ ] 5.5 Créer `CoachingSage/Views/Screens/Onboarding/DisclaimerPARQView.swift` (écran 4 — disclaimer + 5 toggles + analytics + bouton final). ⚠️ **3 sections visuellement séparées** (review P2-1) avec `Divider().padding(.vertical, 12)` épais entre chaque bloc, chaque section dans un `Section` ou `VStack` séparé avec un titre `Text` H2 — l'utilisateur doit voir distinctement les 3 zones (disclaimer / PARQ-light / consentement analytics) et ne PAS pouvoir toggler analytics sans avoir scrollé sur le disclaimer.
  - [ ] 5.6 Chaque sub-view = `struct` qui prend le ViewModel en `@Bindable`. Bouton « Continuer » désactivé si `!viewModel.canContinueScreen<N>`. Ne PAS gérer la nav state ailleurs que dans le ViewModel.
  - [ ] 5.7 Accessibility identifiers (`onboarding.firstName.field`, `onboarding.continue.button`, etc.) — utiles si on écrit des UI tests Epic 2 plus tard.

- [ ] **Task 6** : Gating `CoachingSageApp` + injection deps (AC: #1)
  - [ ] 6.1 Modifier `CoachingSage/App/CoachingSageApp.swift` : ajouter `@State private var hasCompletedOnboarding: Bool = false`.
  - [ ] 6.2 À l'init : computed depuis `coachingProfileRepository.fetchCurrentProfile()?.onboardingCompletedAt != nil` (async, donc passe par un `.task` SwiftUI au début du body, pas dans l'init).
  - [ ] 6.3 Body : 3 branches `if !isAuthenticated { AuthView } else if !hasCompletedOnboarding { OnboardingView } else { MainTabView }`.
  - [ ] 6.4 Quand `OnboardingView` se termine (success), `OnboardingViewModel.finalize()` poste un signal → `hasCompletedOnboarding = true` → SwiftUI bascule sur `MainTabView`.
  - [ ] 6.5 Quand un user signOut + signIn avec un autre compte, l'`isAuthenticated` repasse à false puis re-true → reload du `coachingProfileRepository.fetchCurrentProfile()` qui peut retourner nil (nouveau user) → `hasCompletedOnboarding = false` → onboarding affiché.
  - [ ] 6.6 Pattern : transmettre `appDependencies` via `@Environment` à `OnboardingView` (déjà câblé Story 1.4 pour `MainTabView`).

- [ ] **Task 7** : Localisation FR + EN (AC: #10)
  - [ ] 7.1 Edit ciblé `Localizable.xcstrings` (grep + Edit, JAMAIS lire en entier — règle CLAUDE.md global). Ajouter ~30 clés `onboarding.*` avec FR (default) + EN.
  - [ ] 7.2 Texte du disclaimer (`onboarding.disclaimer.body`) — **wording confirmé par review web LIVE 2026-04-26**. Sources verbatim consultées :
    - Strava ToS §21 DISCLAIMER OF WARRANTIES (https://www.strava.com/legal/terms) : "DESIGNED FOR EDUCATIONAL AND ENTERTAINMENT PURPOSES ONLY... SHOULD NOT BE USED IN PLACE OF THE ADVICE OF YOUR PHYSICIAN... YOU SHOULD NEVER DISREGARD MEDICAL ADVICE..."
    - Nike Run Club / Training Club Terms of Use (`agreementservice.svs.nike.com`) : "informational purposes only and are not intended as medical advice... consult with their medical professional before engaging in any physical activity..."
    - Garmin Connect Health Disclaimer : "This is not a medical device and is not intended for use in the diagnosis or monitoring of any medical condition."
    - PAR-Q+ ACSM 2024 official (https://eparmedx.com) : red flags pré-exercice (chest pain, dizziness, loss of consciousness).
    - 6/6 phrases du wording validées 1-pour-1 par ces sources verbatim. Pattern « stop immediately if pain/dizziness/symptom » repris du PAR-Q+ ACSM.
    - **FR (118 mots)** :
      « CoachingSage est une application de coaching sportif à visée éducative et de bien-être. Elle ne constitue pas un dispositif médical et ne remplace en aucun cas l'avis d'un professionnel de santé.
      Avant de démarrer un programme, en particulier si vous reprenez le sport après une longue pause, êtes enceinte, ou présentez une condition préexistante (cardiaque, articulaire, métabolique...), consultez votre médecin. Ne négligez jamais un avis médical en raison d'une information lue dans l'application.
      Vous suivez les programmes proposés sous votre propre responsabilité. En cas de douleur, malaise ou symptôme inhabituel pendant l'effort, arrêtez immédiatement et consultez un professionnel de santé. »
    - **EN (115 mots)** :
      « CoachingSage is a sports coaching app intended for educational and general wellness purposes. It is not a medical device and does not replace professional medical advice, diagnosis, or treatment.
      Before starting any program — especially if you are returning to exercise after a long break, are pregnant, or have a pre-existing condition (cardiac, joint, metabolic...) — consult your physician. Never disregard or delay medical advice because of something you have read in this app.
      You follow the programs at your own risk. If you experience pain, dizziness, or any unusual symptom during exercise, stop immediately and seek medical attention. »
    - ⚠️ Le titre `onboarding.disclaimer.title` = « Avant de commencer » / « Before you start ».
    - ⚠️ Pas d'objet "case à cocher" séparée — le bouton « Démarrer » de l'écran 4 vaut acceptation (déjà couvert par le UPDATE de `disclaimer_accepted_at` au `finalize()`).
  - [ ] 7.3 Vérifier que toutes les chaînes sont en `String(localized:)` ou `Text("key")` (jamais hardcodé).

- [ ] **Task 8** : Tests unitaires + Mock (AC: #11)
  - [ ] 8.1 Créer `CoachingSage/CoachingSageTests/Mocks/MockCoachingProfileRepository.swift` (pattern `MockCoreProfileRepository`, hooks `fetchHook`, `saveHook`, `saveShouldThrow`).
  - [ ] 8.2 Créer `CoachingSage/CoachingSageTests/ViewModels/OnboardingViewModelTests.swift` :
    - `testCanContinueScreen1RequiresFirstName` : firstName vide → false ; rempli → true.
    - `testCanContinueScreen2RequiresAllFields` : si un des 4 fields nil → false.
    - `testCanContinueScreen3RequiresAtLeastOneSport` : Set vide → false ; ≥ 1 → true.
    - `testFinalizeSetsOnboardingCompletedAt` : après `finalize()`, le mock repo a reçu un `CoachingProfile` avec `onboardingCompletedAt != nil`.
    - `testFinalizeSetsRequiresMedicalClearanceIfAnyParqYes` : 1 réponse oui → flag true ; toutes non → flag false.
    - `testImportFromHealthKitPrefillsFieldsWhenUserHasntEdited` : mock retourne sex+DOB+poids → VM les a après import.
    - `testImportFromHealthKitDoesNotOverrideEditedFields` : si `hasUserEditedScreen2 == true`, l'import ne change rien (à débattre review : doit-on overwrite ou pas ?).
  - [ ] 8.3 Créer `CoachingSage/CoachingSageTests/Repositories/DefaultCoachingProfileRepositoryTests.swift` (1-2 tests sur `save()` avec `IS_UI_TESTING` guard, et fetch returning nil quand pas de profil).
  - [ ] 8.4 Lancer la non-régression (règle `feedback_tests_non_regression`) :
    - login email Story 1.1b OK
    - SyncService Story 1.3 OK
    - DeleteAccount Story 1.4 OK + cascade `coaching_profiles` (test manuel : créer un profil onboarding, supprimer le compte, vérifier dans Supabase que `coaching_profiles` est bien vide pour cet user).
    - Migration SchemaV1 → SchemaV2 transparente (lancer l'app avec un user déjà loggé qui n'a PAS encore fait l'onboarding → flow onboarding s'affiche bien, pas de crash).

- [ ] **Task 9** : Validation Sophie + non-régression visuelle (AC: #1, #11)
  - [ ] 9.1 Sophie déploie migration 002 sur `coachingsage-dev` (Task 1.7).
  - [ ] 9.2 Sophie : ajouter les nouveaux fichiers Swift au `.xcodeproj` (rerun `xcodegen generate`).
  - [ ] 9.3 **Cmd+B** : compile sans erreur.
  - [ ] 9.4 **Cmd+U** : tous les tests existants Epic 1 + nouveaux tests Story 2.2 passent.
  - [ ] 9.5 **Test manuel Cmd+R** :
    - Créer un nouveau user via Dashboard Supabase (admin Add user, Confirm email OFF — voir mémoire `supabase_signup_rate_limit_fix`).
    - Login dans l'app → onboarding s'affiche.
    - Écran 1 : taper un prénom, laisser FR par défaut, Continuer.
    - Écran 2 : tap CTA HealthKit → autoriser → vérifier qu'au moins le sexe (si renseigné dans Apple Santé du simu) se pré-remplit. Compléter manuellement les champs nil. Continuer.
    - Écran 3 : sélectionner 2-3 sports. Continuer.
    - Écran 4 : laisser tous les PARQ à non, toggle analytics, taper « Démarrer ».
    - Vérifier qu'on arrive sur `MainTabView` (onglet Aujourd'hui placeholder, pas de CTA Léon car flag off).
    - Killer l'app, relancer → on arrive direct sur `MainTabView` (pas re-prompt onboarding).
    - Vérifier dans Supabase Dashboard que `coaching_profiles` a bien la ligne avec tous les champs.
  - [ ] 9.6 **Test régression PARQ-light** : refaire un nouveau user, mettre 1 réponse PARQ à oui → vérifier que le bandeau jaune s'affiche, et que `coaching_profiles.requires_medical_clearance = true` côté DB.
  - [ ] 9.7 **Test cascade DeleteAccount** : ⚠️ **utiliser un user dédié** `2-2-test-cascade@coachingsage.dev` (review P2-4 — ne PAS utiliser le user principal de dev pour ne pas le perdre). Faire l'onboarding complet sur ce user, vérifier la row `coaching_profiles`, puis aller en onglet Profil → Supprimer mon compte → vérifier dans Supabase Dashboard que `coaching_profiles` est bien vide pour cet user (CASCADE confirmé).

## Dev Notes

### Décision archi : `coaching_profiles` séparé de `core_profiles`

**Choix retenu (2026-04-26)** : 1 ligne dans `coaching_profiles` par user, FK vers `core_profiles(id)` avec CASCADE. 1-1 strict.

**Pourquoi pas tout dans `core_profiles`** :
- `core_profiles` est partagé entre les 3 apps Sage (Garden/Tailor/Coaching). Y mettre `weight_kg`, `dateOfBirth`, `parq_responses` polluerait la table partagée avec des champs CS-only.
- Découplage permet d'évoluer le schéma CS (Epic 3+ ajoutera `coaching_sport_profiles`) sans toucher à `core_profiles`.
- CASCADE depuis `core_profiles` = la suppression Story 1.4 reste atomique sans modifier `AccountService`.

**Pourquoi 1-1 strict (pas plusieurs `coaching_profiles` par user)** : V1, simple. Si on permettait plusieurs profils (ex: « profil sport » + « profil bien-être »), on aurait besoin d'un sélecteur UI partout. Out of scope.

### Décision archi : `hasCompletedOnboarding` = champ DB, pas UserDefaults

**Choix retenu** : `coaching_profiles.onboarding_completed_at TIMESTAMPTZ` est la source de truth.

**Pourquoi pas UserDefaults** :
- UserDefaults n'est PAS synchronisé entre devices d'un même user. Si Sophie installe sur un 2ème iPhone (ou réinstalle), elle referait l'onboarding alors qu'elle l'a déjà fait → mauvaise UX.
- UserDefaults n'est PAS propre : reste après désinstallation dans certains cas (CloudKit).
- Le champ DB est synchrone-after-save : `coachingProfileRepository.fetchCurrentProfile()?.onboardingCompletedAt` est la vérité sur tout device dès que la première sync est faite.

**Trade-off** : la première fois après login, on doit faire un fetch async (Supabase + SwiftData) avant de savoir s'il faut afficher onboarding ou MainTabView. **Solution** : afficher un splash / loader pendant ~200ms le temps du fetch (SwiftUI `.task` au top-level). Acceptable.

### PARQ schema (5 keys figées)

Pour éviter tout typo qui causerait un mismatch entre le mapping DTO et la DB, les 5 keys PARQ sont figées via une enum côté Swift et copiées telles quelles côté JSONB Supabase :

```swift
enum PARQQuestion: String, CaseIterable {
    case q1ChestPain = "q1_chest_pain"
    case q2Dizziness = "q2_dizziness"
    case q3JointAggravated = "q3_joint_aggravated"
    case q4HeartMedication = "q4_heart_medication"
    case q5OtherReason = "q5_other_reason"

    static var defaultResponses: [String: Bool] {
        Dictionary(uniqueKeysWithValues: allCases.map { ($0.rawValue, false) })
    }
}
```

**Côté DB** : `parq_responses` JSONB attendu strictement `{"q1_chest_pain": false, "q2_dizziness": false, "q3_joint_aggravated": false, "q4_heart_medication": false, "q5_other_reason": false}`. Tout autre format = bug.

**Évolution** : si on ajoute un PARQ q6 plus tard, bumper `disclaimerVersionAccepted` (ex `1.1`) et re-prompter les users. Schéma DB JSONB tolère l'ajout de keys sans migration.

### Léon (Epic 3) doit honorer `requires_medical_clearance`

⚠️ **À tracker explicitement dans Epic 3** (review P1-5) : V1 onboarding bandeau jaune **non bloquant**, l'user passe quand même. Conséquence : un user avec `requires_medical_clearance = true` a quand même accès à l'app. **Léon doit lire ce flag** avant de proposer une session HIIT/intense :
- Si `requires_medical_clearance == true` → Léon ne propose JAMAIS de zone 4-5 / HIIT, downgrade auto en zone 1-2 / endurance fondamentale.
- Affichage UI dans le programme généré : badge « Programme adapté — consultation médicale recommandée ».
- Test critique Epic 3 : `testLeonProposalRespectsMedicalClearance` doit échouer si Léon génère un HIIT pour un profil flaggé.

Sans ce respect, responsabilité de l'app engagée (NFR14 disclaimer médical PRD).

### Dépendance Story 1.5 Analytics

Story 2.2 stocke `analytics_consent` dans `core_profiles` (champ déjà présent migration 001). **Mais aucun tracker analytics n'est encore câblé côté app** — c'est l'objet de Story 1.5 (à drafter hors Epic 2, dans Epic 1).

**Conséquence pratique** : à la fin de Story 2.2, le toggle analytics du user est bien stocké en DB, mais aucun event n'est envoyé nulle part (pas d'AppsFlyer/PostHog/Mixpanel câblé). C'est OK : le consentement est tracé pour le jour où Story 1.5 sera faite et que le tracker honorera ce flag.

**Si Story 1.5 n'est pas faite avant Story 2.2** : l'onboarding fonctionne quand même. Le funnel onboarding ne sera juste pas mesurable rétroactivement.

⚠️ **Risque RGPD à tracer dans Story 1.5** (review P2-2) : si Story 1.5 est implémentée plus tard avec un tracker qui ignore `analytics_consent` par bug, on est en infraction. Story 1.5 doit inclure un test unit type `testTrackerDisabledWhenConsentFalse` qui vérifie qu'aucun event n'est envoyé quand `core_profiles.analytics_consent == false`.

### Patterns architecture à suivre

- **Pas de SageCore SPM côté CoachingSage** : `CoachingProfile` vit en local CS, pas dans le SPM partagé. Cohérent avec le découpage actuel (`SageCoreProfile` partagé, `CoachingProfile` spécifique).
- **DTO snake_case ↔ camelCase** : pattern repris de `CoreProfileDTO.swift` (Story 1.1a).
- **Repository pattern** : protocol + Default impl + Mock, injection `AppDependencies`.
- **`@Observable` ViewModel** + `@Bindable` côté View : pattern Story 1.4 `AccountViewModel`.
- **`OnboardingScreen` enum 4 cas** : state machine simple, switch dans la View.

### Liste sports V1 (à valider Sophie)

Codes : `running`, `cycling`, `swimming`, `triathlon`, `strengthTraining`, `yoga`, `hiit`, `hiking`, `tennis`, `football`.

Couvre les 10 sports cibles initiaux du templates library Epic 0.5 (cohérence avec ce qu'on peut servir Léon Epic 3).

**Si Sophie veut une autre liste** : la story est bloquée le temps de trancher. Reco : valider la liste avant de commencer Task 5 / Task 7 (les codes sont utilisés dans Localizable + dans l'enum SportCode + dans la grille UI).

### Source tree à toucher

| Fichier | Action |
|---|---|
| `CoachingSage/supabase/migrations/002_coaching_profiles.sql` | Créer |
| `CoachingSage/Models/CoachingProfile.swift` | Créer |
| `CoachingSage/Models/Schema/SchemaV2.swift` | Créer |
| `CoachingSage/Models/Schema/CoachingSageMigrationPlan.swift` | Créer |
| `CoachingSage/Repositories/Protocols/CoachingProfileRepository.swift` | Créer |
| `CoachingSage/Repositories/Implementations/DefaultCoachingProfileRepository.swift` | Créer |
| `CoachingSage/Services/DTOs/CoachingProfileDTO.swift` | Créer |
| `CoachingSage/ViewModels/OnboardingViewModel.swift` | Créer |
| `CoachingSage/Views/Screens/Onboarding/OnboardingView.swift` | Créer |
| `CoachingSage/Views/Screens/Onboarding/FirstNameLanguageView.swift` | Créer |
| `CoachingSage/Views/Screens/Onboarding/PersonalDataView.swift` | Créer |
| `CoachingSage/Views/Screens/Onboarding/SportsSelectionView.swift` | Créer |
| `CoachingSage/Views/Screens/Onboarding/DisclaimerPARQView.swift` | Créer |
| `CoachingSage/App/CoachingSageApp.swift` | Modifier (gating onboarding) |
| `CoachingSage/App/AppDependencies.swift` | Modifier (injection coachingProfileRepository) |
| `CoachingSage/Resources/Localizable.xcstrings` | Edit ciblé (~30 clés `onboarding.*`) |
| `CoachingSage/CoachingSageTests/Mocks/MockCoachingProfileRepository.swift` | Créer |
| `CoachingSage/CoachingSageTests/ViewModels/OnboardingViewModelTests.swift` | Créer |
| `CoachingSage/CoachingSageTests/Repositories/DefaultCoachingProfileRepositoryTests.swift` | Créer |

**Total** : ~16 nouveaux fichiers, 3 modifiés. **0 nouvelle dépendance SPM**.

### Pièges à éviter (lessons learned applicables)

- ⚠️ **Migration SwiftData V1 → V2** : si la migration plan n'est pas correctement attachée au `ModelConfiguration`, SwiftData wipe le store local au premier launch (data Story 1.x perdue). Tester systématiquement après modif du Schema (lancer l'app sur un user Story 1.4 existant, vérifier qu'il est encore là). Voir mémoire SwiftData (à créer si pertinent).
- ⚠️ **`coaching_profiles` row absent au moment du gating** : un user Story 1.x existant n'a PAS de ligne dans `coaching_profiles` — donc `fetchCurrentProfile()` retourne nil → onboarding s'affiche. **C'est le comportement voulu** : tous les users existants doivent passer par l'onboarding. À valider avec Sophie : « ok pour que les users testeurs Story 1.x refassent l'onboarding ? » (probablement oui car testeurs).
- ⚠️ **Race condition fetch async vs UI** : `CoachingSageApp` body lit `hasCompletedOnboarding`. La première render est `false` (init default) → flash de l'onboarding pendant ~200ms le temps que le fetch revienne. Mitigation : afficher un `ProgressView` plein écran pendant `isLoadingOnboardingState`. À implémenter Task 6.2.
- ⚠️ **HealthKit `hasRequestedAuthorization` cleared par signOut/signIn** : la prop est backed UserDefaults global (`healthkit.authorization.requested`). Si le user signOut puis signIn avec un autre compte, l'auth HK reste « déjà demandée » côté UserDefaults. **Acceptable V1** : on ne re-prompte pas, l'user nouveau peut quand même cliquer un bouton « Réinitialiser HealthKit » dans Story 2.3 si besoin (à voir si on l'ajoute là). Sinon la 2ème fois, l'auth HK est gérée via Réglages > Confidentialité > Santé.
- ⚠️ **Disclaimer version `1.0` codé en dur** : si on en change le wording plus tard (Epic 7+), il faudra bumper à `1.1` ET re-prompter les users. Pas de mécanisme automatique V1. À tracker.
- ⚠️ **Locale Apple Sign-In ≠ préférence app** : NE PAS écraser `core_profiles.language` automatiquement avec la locale Apple. Story 1.1b a déjà câblé un default à `Locale.current` mais le user PEUT surcharger écran 1 (validé Sophie 2026-04-26).
- ⚠️ **Pas de UI test pour cette story** : règle `feedback_tests_non_regression`.
- ⚠️ **Pré-fill HealthKit overwrite vs préserve** : Task 8.2 pose la question (test 7). Reco : si l'user a édité un champ manuellement avant de cliquer la CTA, ne PAS overwriter (sinon il perd sa saisie). Plus complexe à coder mais meilleure UX.

### Hors scope V1 (à tracker pour Epic ultérieur)

- **Edit nav back arrow dans onboarding** : si Sophie le veut, +0.5j. Pas par défaut.
- **Skip onboarding en dev** : pas de bouton « Skip » V1. Pour les tests, modifier directement `coaching_profiles.onboarding_completed_at` côté Supabase Dashboard.
- **Re-prompter disclaimer si version bump** : pas de mécanisme V1, à ajouter Epic 7+ avec un check `disclaimerVersionAccepted < currentVersion`.
- **Multi-profil par user** : 1-1 strict V1, pas de plan d'évolution.
- **Détail par sport** (`CoachingSportProfile`) : Epic 3 questionnaire détaillé.
- **Audit log Supabase** des décisions onboarding : pas V1 (cohérent avec Story 1.4 hors-scope audit RGPD).
- **Email de bienvenue post-onboarding** : standard du secteur, pas V1.
- **Reminder push si abandon onboarding** : pas V1.
- **Gating mineurs (<18 ans)** : pas de check d'âge V1 (CNIL stricte sur <15 ans). Le PARQ-light + le contexte "coaching sportif" sont jugés suffisants pour V1 testeurs internes. À ré-évaluer avant TestFlight public — soit ajouter case « J'ai 18 ans ou plus » à l'écran 4, soit gating via `dateOfBirth` calculé depuis l'écran 2 (refus si <18). Tracker dans memory `rc_pro_avant_app_store.md`.
- **Mots à bannir EU MDR** : aucun message UI, prompt Léon, ou template ne doit utiliser « soin », « thérapie », « traitement », « guérir », « diagnostiquer » sous peine de bascule en dispositif médical (marquage CE classe IIa). Voir mémoire `rc_pro_avant_app_store.md` pour la liste complète.

### Standards de tests

- XCTest unit, pas de `sleep()`, mocks via protocol.
- 6-7 tests `OnboardingViewModelTests`, 1-2 tests `DefaultCoachingProfileRepositoryTests`.
- Pas d'UI test (règle).
- Locale EN dans le runner (règle `feedback_test_localisation_anglais`).

### Références

- **Epic source v2** : `GardenSage/_bmad-output/planning-artifacts/epics-CoachingSage-v2-proposal.md` (Epic 2 — proposal 2 stories du 2026-04-08, retravaillé en 3 stories le 2026-04-26).
- **Mémoire réalignement Epic 2** : `epic2_realigned_story21_ready.md` (les 4 décisions de scope actées).
- **Story 2.1** (dépendance HealthKit) : `_bmad-output/implementation-artifacts/2-1-healthkit-production-bridge.md`.
- **Story 1.1a** (pattern repository CoreProfile) : `GardenSage/_bmad-output/implementation-artifacts/1-1a-bootstrap-foundation.md` ou équivalent + le code dans `CoachingSage/Repositories/`.
- **Story 1.4** (DeleteAccount + soft-delete pattern) : `_bmad-output/implementation-artifacts/1-4-suppression-de-compte-rgpd.md` — le CASCADE FK depuis `coaching_profiles` évite de retoucher `AccountService`.
- **Migration 001** : `CoachingSage/supabase/migrations/001_initial_schema.sql` (référence pattern RLS / trigger / pg_cron).
- **PARQ-Q form de référence** : ACSM (American College of Sports Medicine) — version 7-questions complète. V1 prend 5 items, version simplifiée. À justifier à Apple Review si question.

### Project Structure Notes

- Sous-dossier `Views/Screens/Onboarding/` créé pour grouper les 5 vues onboarding (containerView + 4 sub-views). Cohérent avec le pattern `Views/Screens/Profile/` qu'on aurait pu introduire pour Story 1.4 mais qu'on a aplati. Ici 5 fichiers justifient le sous-dossier.
- `Models/Schema/CoachingSageMigrationPlan.swift` à côté de `SchemaV1.swift` et `SchemaV2.swift`.
- DTO Coaching* dans `Services/DTOs/` (pattern existant).
- Aucune nouvelle dépendance SPM. Uses `Foundation`, `SwiftUI`, `SwiftData`, `Supabase` (déjà présent).

## Review Tracking — 2026-04-26 (review pré-implem)

Review adversarial par sous-agent `Plan` sur le draft initial. **3 P0 + 5 P1 + 6 P2** identifiés.

**P0 (tous traités)** :
- ✅ P0-1 : `CoachingSageApp.swift:36-51` wipe legacy incompatible avec `SchemaMigrationPlan` → Task 2.4 retravaillée + Task 2.4bis ajoutée. Suppression du bloc `swiftdata_schema_version`/`fm.removeItem`, init container avec `migrationPlan: CoachingSageMigrationPlan.self`. Test obligatoire : data Story 1.x conservée.
- ✅ P0-2 : Race condition réinstall multi-device → AC1 détaille 4 états (avec splash loader) + Task 3.2 ajoute le hydrate-on-miss côté `fetchCurrentProfile()` (fetch Supabase si SwiftData nil, hydrate si row existe). Évite l'écrasement de la row Supabase au `finalize()`.
- ✅ P0-3 : Policy DELETE manquante non documentée → AC7 + Task 1.3 explicitent **3 policies** (SELECT/INSERT/UPDATE), suppression via service_role uniquement. Cohérent avec migration 001.

**P1 (tous traités)** :
- ✅ P1-1 : `hasUserEditedScreen2` flag non spec → Task 4.2 + 4.6 précisent : set à `true` dès qu'un field écran 2 a une valeur ≠ nil (helper `markScreen2Edited()`). Override HK seulement si false.
- ✅ P1-2 : `active_sports JSONB` → `TEXT[]` Postgres natif (AC7 + Task 1.2). Permet `WHERE 'running' = ANY(active_sports)` + index GIN pour Léon Epic 3.
- ✅ P1-3 : Mapping `HKBiologicalSex` → string explicité (Task 4.6) : `.female→"female"`, `.male→"male"`, `.other→"other"`, `.notSet→nil`. `preferNotToSay` saisi manuellement seulement.
- ✅ P1-4 : Format `parq_responses` figé → Dev Notes section "PARQ schema" + enum `PARQQuestion` Swift, 5 keys exactes (`q1_chest_pain`, `q2_dizziness`, `q3_joint_aggravated`, `q4_heart_medication`, `q5_other_reason`).
- ✅ P1-5 : PARQ-light non bloquant + risque légal → Dev Notes section "Léon doit honorer requires_medical_clearance" tracker Epic 3 obligatoire. V1 reste non-bloquant (correct si Léon respecte le flag downstream).

**P2 traités** :
- ✅ P2-1 : Écran 4 lourd → Task 5.5 explicite 3 sections séparées avec `Divider` épais (pas split en 2 écrans, juste hiérarchie visuelle).
- ✅ P2-2 : Story 1.5 risque RGPD → Dev Notes "Dépendance Story 1.5 Analytics" trace explicitement le test unit `testTrackerDisabledWhenConsentFalse` à inclure dans Story 1.5.
- 📌 P2-3 : Sub-folder `Views/Screens/Onboarding/` accepté (5 fichiers justifient).
- ✅ P2-4 : User test cascade → Task 9.7 utilise un user dédié `2-2-test-cascade@coachingsage.dev`.
- 📌 P2-5 : Seed `sports_catalog` → tracker Epic 3 si Léon a besoin de metadata par sport (zones FC etc.). V1 OK enum Swift only.
- 📌 P2-6 : Disclaimer version `1.0` hardcodé sans mécanisme re-prompt → tracker Epic 7+. Hors scope V1.

## Dev Agent Record

### Agent Model Used

_(à remplir lors de l'implem)_

### Debug Log References

_(à remplir lors de l'implem)_

### Completion Notes List

_(à remplir lors de l'implem)_

### File List

_(à remplir lors de l'implem)_

### Reste à faire avant `done`

_(à remplir après implem)_
