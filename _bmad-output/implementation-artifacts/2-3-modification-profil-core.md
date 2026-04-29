# Story 2.3 : Modification Profil Core

Status: done

<!-- Note: Validation est optionnelle. Lance `validate-create-story` pour un quality check avant `dev-story`. -->

## Story

**As a** utilisateur CoachingSage qui a complété l'onboarding (Story 2.2),
**I want** modifier mes infos depuis l'onglet Profil (prénom, langue, données perso, sports actifs, réponses santé, consentement analytics),
**so that** mon profil reste à jour quand ma situation évolue (changement de poids, nouveau sport, condition médicale qui change), sans avoir à supprimer/recréer mon compte.

## Acceptance Criteria

1. **AC1 — `ProfileView` enrichie en hub de modification** : remplace le placeholder Story 1.2/1.4 par un écran structuré en sections, chacune ouvrant un sous-écran d'édition via `NavigationLink`. Sections (de haut en bas) :
   - **Identité** : prénom, langue
   - **Données personnelles** : sexe, date de naissance, poids, taille
   - **Sports actifs** : N sports affichés (badge count)
   - **Santé** : « Mettre à jour mes réponses santé » + bandeau jaune si `requiresMedicalClearance == true`
   - **Confidentialité** : toggle analytics inline (pas de sub-screen)
   - **À propos** : « Disclaimer médical » (consultable read-only)
   - **Compte** : Déconnexion (existant Story 1.2) + Zone dangereuse Suppression (existant Story 1.4)

   ⚠️ **`ProfileViewModel` expose `state: ViewState<(SageCoreProfile, CoachingProfile)>`** (review P1-4 — défensif contre nil race au premier render). La vue switch sur le state : `idle/loading` → skeleton placeholder, `loaded` → sections affichées, `error` → message + retry. Pas de force-unwrap.

   ⚠️ **Sécurité cross-user** (review P0-4) : `ProfileViewModel.fetch()` capture `let capturedUserId = authService.currentUserId` au début, et après chaque `await`, re-vérifie `authService.currentUserId == capturedUserId`. Si différent → discard le résultat (l'auth a basculé pendant le fetch). Évite la fuite de données entre comptes.

2. **AC2 — Pattern save-per-screen** : chaque sous-écran a son propre bouton « Enregistrer » qui save uniquement ses fields et navigue back automatiquement. Si l'utilisateur quitte sans save (back arrow iOS), les modifs sont perdues. **Pas de modal de confirmation « Quitter sans enregistrer ? »** V1 — pattern Réglages iOS standard. Reco si Sophie veut le mettre en V1 : +0.25j.

3. **AC3 — `EditIdentityView`** :
   - 2 fields : `firstName` (TextField, requis 1-50), `language` (Picker FR/EN).
   - Bouton « Enregistrer » désactivé si `firstName.isEmpty`.
   - Save → `coreProfileRepository.save(...)` (mise à jour `core_profiles.first_name` + `core_profiles.language`) **ET** `languageManager.switchLanguage(to: ...)` (UserDefaults + propagation `.environment(\.locale, ...)`).
   - ⚠️ **Bascule langue live** (review P1-5) — pattern aligné GS/TS via `LanguageManager` `[COPIE IDENTIQUE]` (validé Sophie 2026-04-26 : « sur les autres appli c'est live »). Port direct depuis `GardenSage/Utilities/LanguageManager.swift` ou `TailorSage/TailorSage/Utilities/LanguageManager.swift`. Le `LanguageManager` (`@Observable`) :
     - Stocke `currentLanguage: SupportedLanguage` (enum `.french/.english`) dans `UserDefaults` clé `"preferredLanguage"`.
     - Expose `currentLocale: Locale` calculé.
     - Override env var `PREFERRED_LANGUAGE` pour tests UI (cohérent pattern GS/TS).
     - Injecté à la racine de `CoachingSageApp` via `.environment(\.locale, languageManager.currentLocale)` + `.environment(\.languageManager, languageManager)`.
     - Au switch → SwiftUI re-render automatiquement (l'`Observable` propage le changement).
   - ⚠️ **`core_profiles.language` reste sync en parallèle** : la SoT UI = `LanguageManager` (UserDefaults), la valeur Supabase sert juste de trace pour analytics/multi-device. Pas de drift fonctionnel V1.
   - **Effort réel** : ~+0.5j (port LanguageManager + tests + intégration), pas +0.25j comme initialement annoncé. Cohérent mode sopddl.

4. **AC4 — `EditPersonalDataView`** :
   - 4 fields identiques à Story 2.2 écran 2 (sex Picker / DOB DatePicker / weight / height).
   - **CTA « Importer depuis Apple Santé »** affichée toujours (différent de l'onboarding qui se cache après 1ère demande) — le user peut vouloir refaire l'import si ses données ont changé. Au tap, même flow Story 2.1 (`requestProfileAuthorization` + `fetchProfileData`).
   - Bouton « Enregistrer » désactivé si l'un des 4 fields est nil/invalide. Save → `coachingProfileRepository.save(...)`.

5. **AC5 — `EditActiveSportsView`** :
   - Grille 2×5 (10 sports) identique à Story 2.2 écran 3, mais pré-cochée selon `coachingProfile.activeSports` actuel.
   - Tap toggle sélection. Au moins 1 sport requis pour pouvoir enregistrer.
   - Save → UPDATE `coaching_profiles.active_sports`.
   - ⚠️ **Pas de gestion `CoachingSportProfile` lié** (Epic 3) : si l'user retire un sport, V1 supprime juste le code de `active_sports`. Quand Epic 3 arrive, prévoir une migration data « si CoachingSportProfile orphelin (code n'est plus dans active_sports) → soft-delete ». **Note Epic 3** : ne PAS coder de hard-delete CoachingSportProfile dans Story 2.3.
   - Si l'user ajoute un sport non présent : V1, juste l'ajout au tableau. Le questionnaire détaillé (Epic 3) sera demandé la prochaine fois qu'il rentre dans l'onglet Séance pour ce sport.

6. **AC6 — `EditHealthQuestionsView` (PARQ-light éditable)** :
   - 5 toggles oui/non pré-cochés selon `coachingProfile.parqResponses` actuel (5 keys figées Story 2.2 — `q1_chest_pain`, `q2_dizziness`, `q3_joint_aggravated`, `q4_heart_medication`, `q5_other_reason`).
   - Bandeau jaune affiché en temps réel si au moins une réponse à `true`.
   - Save → UPDATE `coaching_profiles.parq_responses` + recalcul `requires_medical_clearance = parqResponses.values.contains(true)`. ⚠️ **Le recalcul est obligatoire** : si l'user dégrade ses réponses (ajoute un oui), `requires_medical_clearance` doit passer à true, et inversement.
   - ⚠️ **Sérialisation des saves** (review P0-3) : bouton « Enregistrer » désactivé pendant `saveState == .loading`. Stockage de la `Task` courante dans `EditHealthQuestionsViewModel`, annulation de la `Task` précédente si retap rapide. Évite que 2 saves rapides écrasent l'un l'autre avec un calcul `requiresMedicalClearance` stale (sécurité Léon Epic 3 critique).
   - Naming clés i18n : réutiliser `onboarding.parq.q1` etc. de Story 2.2 (pas de duplication). Bouton Save = nouvelle clé `profile.health.save`.

7. **AC7 — Toggle analytics inline + `EditPrivacyView` consultable** :
   - **Toggle inline directement dans `ProfileView`** sous la section Confidentialité — pas de sub-screen, l'action est immédiate.
   - Au toggle → save direct via `coreProfileRepository.save(...)` (UPDATE `core_profiles.analytics_consent`). Feedback visuel : `ProgressView` mini si en cours, sinon état idle.
   - ⚠️ **Idempotence** : si l'utilisateur toggle on/off rapidement, debouncer 500ms côté VM (un seul UPDATE Supabase au lieu de N).

8. **AC8 — `MedicalDisclaimerView` read-only** :
   - Affiche le texte du disclaimer (clé `onboarding.disclaimer.body` de Story 2.2 — pas de duplication) + footer « Version 1.0 acceptée le \(disclaimerAcceptedAt) ».
   - Pas d'édition, pas de re-acceptation V1. Si on bumpe la version dans le futur (Epic 7+), un mécanisme de re-prompt sera ajouté.
   - Accessible via `NavigationLink` depuis `ProfileView`.

9. **AC9 — Logique du bandeau "Consultation médicale recommandée"** :
   - Affiché en haut de `ProfileView` (section Santé) si `coachingProfile.requiresMedicalClearance == true`.
   - Texte localisé (`profile.health.warning.banner`).
   - Pas d'action attachée — c'est juste un rappel visuel. Le respect du flag par Léon Epic 3 = autre histoire (voir Story 2.2 Dev Notes "Léon doit honorer requires_medical_clearance").

10. **AC10 — Tests unitaires** : 1 ViewModel par sous-écran, tests sur les transitions save (idle/loading/success/error) + recalcul `requiresMedicalClearance` + idempotence du toggle analytics. ~10-12 tests au total. Pas d'UI test (règle).

## Tasks / Subtasks

- [ ] **Task 1** : Refonte `ProfileView` en hub de modification (AC: #1, #7, #9)
  - [ ] 1.1 Modifier `CoachingSage/Views/Screens/ProfileView.swift` : remplacer le placeholder par un `Form` (ou `List` style `.insetGrouped`) avec sections.
  - [ ] 1.2 Section « Identité » : 2 rows `Text(label)` + `Text(value)` chevron, NavigationLink → `EditIdentityView()`.
  - [ ] 1.3 Section « Données personnelles » : 1 row `Text("profile.section.personalData")` + résumé `"\(sex), \(age) ans, \(weightKg) kg, \(heightCm) cm"`, NavigationLink → `EditPersonalDataView()`.
  - [ ] 1.4 Section « Sports actifs » : NavigationLink → `EditActiveSportsView()`. Affiche `\(activeSports.count) sports` en preview.
  - [ ] 1.5 Section « Santé » : si `requiresMedicalClearance == true` → bandeau jaune `Text("profile.health.warning.banner")` + `Image(systemName: "exclamationmark.triangle.fill")` couleur orange. NavigationLink « Mettre à jour mes réponses » → `EditHealthQuestionsView()`. NavigationLink « Disclaimer médical » → `MedicalDisclaimerView()`.
  - [ ] 1.6 Section « Confidentialité » : `Toggle("profile.privacy.analyticsConsent", isOn: $vm.analyticsConsent)` inline, debouncé via `AnalyticsConsentViewModel`.
  - [ ] 1.7 Section « Compte » : conserver bouton « Déconnexion » + Zone dangereuse Suppression (existants Stories 1.2 + 1.4). **Ne pas régresser** ces fonctionnalités. ⚠️ **Adapter le label `NavigationLink` DeleteAccount** (review P1-3) : la `ProfileView` actuelle utilise un `HStack` custom avec chevron manuel, parce qu'elle est en `VStack`. La refonte en `Form/List` ajoute son propre chevron natif → **double chevron visible**. Solution : retirer l'`HStack` custom + `Image("chevron.right")` autour de `DeleteAccountView`, laisser `Form` styler le `NavigationLink` naturellement. Garder l'icône triangle d'alerte + couleur error sur le label texte.
  - [ ] 1.8 Le `ProfileView` lit le profil via un `ProfileViewModel` (`@Observable`, `@MainActor`) :
    - Property `state: ViewState<(SageCoreProfile, CoachingProfile)>` (review P1-4).
    - `func refresh() async` : capture `let capturedUserId = authService.currentUserId` (review P0-4 sécurité), fetch `coreProfileRepository.fetchCurrentProfile()` + `coachingProfileRepository.fetchCurrentProfile()`, après chaque `await` re-vérifie `authService.currentUserId == capturedUserId` → si différent, discard.
    - Appelée depuis `.onAppear` du `ProfileView` (review P0-2 — **PAS `.task`** car `.task` ne se re-déclenche pas au pop de NavigationLink, alors que `.onAppear` oui — c'est le mécanisme de refresh après save sous-écran).
    - Pas de callback explicite des sous-VMs vers le parent : c'est le `.onAppear` au pop qui rafraîchit. **Mécanisme de refresh** = idiomatique SwiftUI, pas de coupling parent-enfant.
  - [ ] 1.9 ⚠️ **Lazy-fetch côté `onAppear`** : ne PAS bloquer l'UI au load, afficher placeholders skeleton (`Text("—")` greyed) tant que `state` est `.idle / .loading`. Bascule sur les vraies valeurs quand `.loaded`.

- [ ] **Task 2** : Port `LanguageManager` + `EditIdentityView` + `EditIdentityViewModel` (AC: #3)
  - [ ] 2.0 ⚠️ **Port `LanguageManager` `[COPIE IDENTIQUE]`** depuis GardenSage/TailorSage :
    - Créer `CoachingSage/Utilities/LanguageManager.swift` (port direct de `GardenSage/Utilities/LanguageManager.swift`, ~80 lignes). Header `// [COPIE IDENTIQUE] — synchroniser avec GardenSage et TailorSage.`
    - Créer `CoachingSage/Utilities/SupportedLanguage.swift` (enum `.french/.english` raw "fr"/"en") si pas déjà porté avec le manager.
    - Inclure les extensions `Locale.localizedBundle` + `String.localized(_:locale:)`.
    - Inclure `LanguageManagerKey: EnvironmentKey` + extension `EnvironmentValues.languageManager`.
  - [ ] 2.0bis Modifier `CoachingSage/App/CoachingSageApp.swift` :
    - Ajouter `private let languageManager = LanguageManager()` au top de la struct.
    - À la racine du body, ajouter `.environment(\.locale, languageManager.currentLocale)` + `.environment(\.languageManager, languageManager)` après `.environment(\.appDependencies, deps)`.
  - [ ] 2.1 Créer `CoachingSage/ViewModels/EditIdentityViewModel.swift` (`@Observable`, `@MainActor`). Init reçoit `coreProfile: SageCoreProfile`, `coreProfileRepository`, `languageManager`.
  - [ ] 2.2 Properties : `firstName: String`, `selectedLanguage: SupportedLanguage`, `saveState: ViewState<Void>`. Init pré-rempli depuis `coreProfile` + `languageManager.currentLanguage`.
  - [ ] 2.3 `func save() async` :
    1. Guard valid → update `SageCoreProfile.firstName` + `SageCoreProfile.language = selectedLanguage.rawValue`.
    2. `try await coreProfileRepository.save(updatedProfile)`.
    3. `languageManager.switchLanguage(to: selectedLanguage)` — propagation UI live.
    4. `.success(())` → SwiftUI dismiss.
  - [ ] 2.4 Créer `CoachingSage/Views/Screens/Profile/EditIdentityView.swift` : `Form` avec 2 fields + bouton « Enregistrer ». Picker langue : `Picker("profile.identity.language", selection: $vm.selectedLanguage) { Text("FR").tag(SupportedLanguage.french); Text("EN").tag(SupportedLanguage.english) }`.
  - [ ] 2.5 Au save success, `dismiss()` automatique. Le `ProfileView` parent re-render au pop via `.onAppear` (Task 1.8). La langue change immédiatement dans toute l'app grâce au `LanguageManager` `@Observable`.

- [ ] **Task 3** : `EditPersonalDataView` + `EditPersonalDataViewModel` (AC: #4)
  - [ ] 3.1 Créer `CoachingSage/ViewModels/EditPersonalDataViewModel.swift`. Properties identiques à Story 2.2 écran 2 + `saveState: ViewState<Void>`.
  - [ ] 3.2 `func importFromHealthKit() async` : ⚠️ **différence vs Story 2.2** — pas de `hasUserEdited` flag, l'import écrase TOUJOURS les fields actuels avec les valeurs HK non-nil retournées. Justifié : l'user a explicitement tap la CTA, il sait qu'il va overwrite.
    - ⚠️ **CTA adaptative selon authStatus** (review P2-1) : avant d'appeler `requestProfileAuthorization`, check si l'utilisateur a déjà refusé via Réglages. Si `healthKitService.hasRequestedAuthorization && tous_les_fields_HK_retournent_nil` (signal probable de refus passé) → label CTA passe à `"profile.personalData.healthKit.openSettings"` qui ouvre `UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)`. Évite le tap silencieux frustrant.
  - [ ] 3.3 `func save() async` : `coachingProfileRepository.save(updatedProfile)`.
  - [ ] 3.4 Créer `CoachingSage/Views/Screens/Profile/EditPersonalDataView.swift` : `Form` + CTA HealthKit + 4 fields. **CTA toujours visible** (différent de Story 2.2 écran 2 qui la cache après 1ère demande).

- [ ] **Task 4** : `EditActiveSportsView` + `EditActiveSportsViewModel` (AC: #5)
  - [ ] 4.1 Créer `CoachingSage/ViewModels/EditActiveSportsViewModel.swift`. Properties : `selectedSports: Set<String>`, `saveState: ViewState<Void>`.
  - [ ] 4.2 Init pré-rempli depuis `coachingProfile.activeSports`.
  - [ ] 4.3 `func save() async` : guard `!selectedSports.isEmpty` → save. Si vide → bouton désactivé côté UI, mais double-check côté VM pour défense en profondeur.
  - [ ] 4.4 Créer `CoachingSage/Views/Screens/Profile/EditActiveSportsView.swift` : grille 2×5 identique à Story 2.2 écran 3, cellules pré-cochées.
  - [ ] 4.5 ⚠️ **Pas de hard-delete `CoachingSportProfile`** V1 (Epic 3) — juste UPDATE `active_sports`. Documenter dans le code que la cohérence orpheline sera gérée Epic 3.

- [ ] **Task 5** : `EditHealthQuestionsView` + `EditHealthQuestionsViewModel` (AC: #6)
  - [ ] 5.1 Créer `CoachingSage/ViewModels/EditHealthQuestionsViewModel.swift`. Properties : `parqResponses: [String: Bool]`, computed `requiresMedicalClearance: Bool`, `saveState`.
  - [ ] 5.2 Init pré-rempli depuis `coachingProfile.parqResponses`.
  - [ ] 5.3 `func save() async` : recalcule `requires_medical_clearance` côté Swift avant save (pas un computed côté DB) → `coachingProfileRepository.save(updatedProfile with updatedParq + updatedClearance)`.
  - [ ] 5.4 Créer `CoachingSage/Views/Screens/Profile/EditHealthQuestionsView.swift` : 5 `Toggle` + bandeau jaune temps réel si computed `requiresMedicalClearance == true`.
  - [ ] 5.5 Naming i18n : réutiliser `onboarding.parq.q1`-`q5`, `onboarding.parq.warning` (pas de duplication clés). Nouveau : `profile.health.save`.

- [ ] **Task 6** : Toggle analytics inline + `AnalyticsConsentViewModel` (AC: #7)
  - [ ] 6.1 Intégrer dans `ProfileViewModel` (pas de sub-screen, donc pas besoin d'un VM dédié).
  - [ ] 6.2 Property `analyticsConsent: Bool` synchronisée via `Bindable`. Sur `didSet`, déclencher le debounce save.
  - [ ] 6.3 `debouncedSave()` (review P1-1) :
    ```swift
    private var debounceTask: Task<Void, Never>?
    private var pendingValue: Bool?

    private func scheduleSave(value: Bool) {
        debounceTask?.cancel()
        pendingValue = value
        debounceTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(500))
            guard !Task.isCancelled, let self else { return }
            await self.performSave(value: value)
        }
    }
    ```
    ⚠️ `[weak self]` obligatoire malgré `@Observable` (qui reste une classe — risque retain cycle si `Task` détenu par closure).
  - [ ] 6.4 Erreur + revert : si `performSave` throw, **ne revert que si la valeur courante == valueAttemptedAtSave** (review P1-2 — évite d'écraser un toggle correct par un état stale). Pseudo-code :
    ```swift
    private func performSave(value: Bool) async {
        do { try await coreProfileRepository.save(profileWithConsent: value) }
        catch {
            // Revert seulement si l'utilisateur n'a pas re-toggled depuis
            if self.analyticsConsent == value {
                self.analyticsConsent = !value  // back to previous
                self.privacyErrorVisible = true
                Task { try? await Task.sleep(for: .seconds(3)); self.privacyErrorVisible = false }
            }
        }
    }
    ```
    Pas critique RGPD : le toggle est déjà OFF par défaut, donc un échec save laisse le state OFF côté serveur (cohérent avec l'intention).

- [ ] **Task 7** : `MedicalDisclaimerView` read-only (AC: #8)
  - [ ] 7.1 Créer `CoachingSage/Views/Screens/Profile/MedicalDisclaimerView.swift` : `ScrollView` avec `Text("onboarding.disclaimer.body")` + footer « Version 1.0 acceptée le \(disclaimerAcceptedAt.formatted(...)) ».
  - [ ] 7.2 Pas de ViewModel — vue stateless qui prend la `Date` et la version `String` en paramètres.
  - [ ] 7.3 Localisation : 1 nouvelle clé `profile.disclaimer.acceptedOn` (FR « Version %@ acceptée le %@ », EN « Version %@ accepted on %@ »).

- [ ] **Task 8** : Localisation FR + EN (~25 nouvelles clés)
  - [ ] 8.1 Edit ciblé `Localizable.xcstrings` (grep + Edit, JAMAIS lire en entier).
  - [ ] 8.2 Clés à ajouter (préfixe `profile.*`) :
    - `profile.section.identity`, `profile.section.personalData`, `profile.section.sports`, `profile.section.health`, `profile.section.privacy`, `profile.section.about`, `profile.section.account`
    - `profile.identity.edit`, `profile.identity.languageNote`
    - `profile.personalData.edit`, `profile.personalData.summary` (« %@, %d ans, %.1f kg, %.0f cm »)
    - `profile.sports.edit`, `profile.sports.count` (« %d sports »)
    - `profile.health.edit`, `profile.health.warning.banner`, `profile.health.save`
    - `profile.privacy.analyticsConsent`, `profile.privacy.error.save`
    - `profile.disclaimer.title`, `profile.disclaimer.acceptedOn`
    - `profile.identity.save`, `profile.personalData.save`, `profile.sports.save`
    - `profile.error.generic`
  - [ ] 8.3 Vérifier `String(localized:)` partout (pas de hardcoded).

- [ ] **Task 9** : Tests unitaires (AC: #10)
  - [ ] 9.1 Créer `CoachingSageTests/ViewModels/EditIdentityViewModelTests.swift` (3 tests : valid save, empty firstName disable, error propagation).
  - [ ] 9.2 Créer `CoachingSageTests/ViewModels/EditPersonalDataViewModelTests.swift` (3 tests : import HK overwrites, save success, validation).
  - [ ] 9.3 Créer `CoachingSageTests/ViewModels/EditActiveSportsViewModelTests.swift` (2 tests : empty selection blocks save, normal save updates DB).
  - [ ] 9.4 Créer `CoachingSageTests/ViewModels/EditHealthQuestionsViewModelTests.swift` (3 tests : computed clearance recalculé, save updates `requires_medical_clearance`, regression case "tout à non").
  - [ ] 9.5 Tests pour le toggle analytics debounced : `testAnalyticsConsentDebounced500ms` (rapid toggle on/off → 1 seul save), `testAnalyticsConsentRevertsOnError` (mock save throws → toggle revient à OFF).
  - [ ] 9.6 Lancer la non-régression :
    - Onboarding Story 2.2 toujours OK : ⚠️ **utiliser un user dédié** `2-3-test-onboarding@coachingsage.dev` (review P2-4 — différent de Story 2.2 cascade test). OU supprimer le user 2.2 via Zone Dangereuse Story 1.4 et re-login.
    - DeleteAccount Story 1.4 toujours OK (le bouton est toujours là, pas de double chevron — voir Task 1.7).
    - SignOut Story 1.2 toujours OK.
    - Migration SchemaV2 (rien de nouveau côté schéma SwiftData / Supabase pour 2.3, donc transparent).

- [ ] **Task 10** : Validation Sophie + non-régression visuelle
  - [ ] 10.1 Sophie : ajouter les nouveaux fichiers Swift au `.xcodeproj` (rerun `xcodegen generate`).
  - [ ] 10.2 **Cmd+B** : compile sans erreur.
  - [ ] 10.3 **Cmd+U** : tous les tests Epic 1 + 2.x passent.
  - [ ] 10.4 **Test manuel Cmd+R** :
    - Login user qui a fait l'onboarding (créé Story 2.2).
    - Onglet Profil → vérifier les 7 sections affichées correctement avec les valeurs réelles.
    - Tap « Identité » → modifier prénom → Enregistrer → retour ProfileView, le prénom est à jour.
    - Tap « Sports actifs » → ajouter 1 sport, retirer 1 → Enregistrer → retour, count à jour.
    - Tap « Santé » → mettre 1 PARQ à oui → bandeau jaune apparaît temps réel → Enregistrer → retour, bandeau Santé jaune dans ProfileView.
    - Toggle analytics OFF → toggle ON rapidement (5x en 1s) → vérifier que 1 seul appel UPDATE Supabase est fait (Network Inspector ou logs Xcode console).
    - Tap « Disclaimer médical » → texte affiché + footer version/date.
    - Vérifier non-régression : Déconnexion + Zone dangereuse Suppression toujours fonctionnels.
  - [ ] 10.5 **Test localisation EN** (review P2-5 renforcé) : Identité → bascule EN → vérifier que **sans reboot** les clés `profile.*` ET `onboarding.*` réutilisées s'affichent en anglais (grâce à l'override `\.locale` de Task 2/AC3). Lister les ~25 nouvelles clés `profile.*` une par une, vérifier la traduction EN — un oubli côté `Localizable.xcstrings` se traduit par un fallback FR visible.

## Dev Notes

### Prérequis : Story 2.2 mergée

⚠️ **Story 2.3 dépend de Story 2.2** (review P2-2) : `MockCoachingProfileRepository` est créé Task 8.1 de Story 2.2. Si Story 2.3 est commencée avant Story 2.2 mergée, les tests Task 9.x cassent à la compile (référence non-résolue). Ordre obligatoire : 2.2 → 2.3.

### Décision archi : 1 ViewModel par sous-écran, pas un global

**Choix retenu (2026-04-26)** : `EditIdentityViewModel`, `EditPersonalDataViewModel`, etc. — 1 par écran, pas un VM global `ProfileEditViewModel`.

**Pourquoi** :
- Tests unitaires plus simples (chaque VM teste une concern).
- Pas de cycle dépendances entre sections (l'identité ne sait rien des sports).
- État local par sous-écran : si l'user quitte sans save, ses changements sont perdus → comportement standard iOS.

**Trade-off** : `ProfileView` (le hub) garde son propre `ProfileViewModel` qui fetch le profil global et l'expose en read-only aux sous-écrans (qui le copient localement pour édition).

### Décision archi : save-per-screen, pas de "annuler les modifs"

**Choix retenu** : chaque sous-écran a son bouton Enregistrer. Pas de modal "Quitter sans enregistrer ?" V1.

**Pourquoi** : pattern iOS Réglages standard. La complexité d'un modal de confirmation (un par sous-écran × dirty detection) ne vaut pas la peine V1 — l'user comprend qu'il faut Save pour valider.

**Quand reconsidérer** : si feedback users beta « j'ai perdu mes modifs ». Epic 7+.

### Décision : pas de gestion `CoachingSportProfile` orphelin V1

**Choix retenu** : Story 2.3 modifie juste `coaching_profiles.active_sports`. Si Epic 3 a créé des `CoachingSportProfile` détaillés et que l'user retire un sport, V1 ne nettoie PAS le `CoachingSportProfile`.

**Pourquoi** : Epic 3 (`CoachingSportProfile`) n'est pas livré au moment de Story 2.3. Anticiper le cleanup serait du code mort.

**Action Epic 3** : ajouter un test d'intégration qui vérifie qu'à la modification de `active_sports`, les `CoachingSportProfile` orphelins sont soft-delete. À tracker dans Epic 3.

### Logique recalcul `requiresMedicalClearance`

Côté Swift avant save (Task 5.3) :
```swift
let updatedClearance = parqResponses.values.contains(true)
```

Pas un trigger Supabase ni un computed column. Pourquoi : le calcul est trivial et 100% côté Swift, pas besoin de complexifier la DB. Si on bouge la logique vers la DB plus tard (Epic 7+), une migration peut le faire.

### Source tree à toucher

| Fichier | Action |
|---|---|
| `CoachingSage/Utilities/LanguageManager.swift` | Créer (port `[COPIE IDENTIQUE]` GS/TS) |
| `CoachingSage/Utilities/SupportedLanguage.swift` | Créer (enum raw "fr"/"en") si pas inclus dans LanguageManager.swift |
| `CoachingSage/App/CoachingSageApp.swift` | Modifier (init `LanguageManager` + injection `\.locale` + `\.languageManager`) |
| `CoachingSage/Views/Screens/ProfileView.swift` | Modifier (refonte complète en hub) |
| `CoachingSage/ViewModels/ProfileViewModel.swift` | Créer (fetch + bind sections) |
| `CoachingSage/ViewModels/EditIdentityViewModel.swift` | Créer |
| `CoachingSage/ViewModels/EditPersonalDataViewModel.swift` | Créer |
| `CoachingSage/ViewModels/EditActiveSportsViewModel.swift` | Créer |
| `CoachingSage/ViewModels/EditHealthQuestionsViewModel.swift` | Créer |
| `CoachingSage/Views/Screens/Profile/EditIdentityView.swift` | Créer |
| `CoachingSage/Views/Screens/Profile/EditPersonalDataView.swift` | Créer |
| `CoachingSage/Views/Screens/Profile/EditActiveSportsView.swift` | Créer |
| `CoachingSage/Views/Screens/Profile/EditHealthQuestionsView.swift` | Créer |
| `CoachingSage/Views/Screens/Profile/MedicalDisclaimerView.swift` | Créer |
| `CoachingSage/Resources/Localizable.xcstrings` | Edit ciblé (~25 clés `profile.*`) |
| `CoachingSage/CoachingSageTests/ViewModels/EditIdentityViewModelTests.swift` | Créer |
| `CoachingSage/CoachingSageTests/ViewModels/EditPersonalDataViewModelTests.swift` | Créer |
| `CoachingSage/CoachingSageTests/ViewModels/EditActiveSportsViewModelTests.swift` | Créer |
| `CoachingSage/CoachingSageTests/ViewModels/EditHealthQuestionsViewModelTests.swift` | Créer |

**Total** : ~14 nouveaux fichiers, 1 modifié. **0 nouvelle dépendance SPM**, **0 nouvelle migration DB** (réutilise schema Story 2.2).

### Pièges à éviter

- ⚠️ **`LanguageManager` doit être ajouté à la mémoire `sage_copie_identique_drift`** — c'est un nouveau fichier `[COPIE IDENTIQUE]` synchronisé GS/TS/CS. Au moindre fix dans GS ou TS, vérifier qu'on porte la modif dans CS. À documenter au moment de la complétion de Story 2.3.
- ⚠️ **Recalcul `requiresMedicalClearance` à omettre** : si l'user dégrade ses réponses (1 oui en plus), il faut RECALCULER, pas seulement updater `parq_responses`. Test 9.4 dédié.
- ⚠️ **Toggle analytics burst** : sans le debounce 500ms, un user qui hésite peut envoyer 10 UPDATE Supabase en 2s → coût rate-limit et data churn. Debounce obligatoire.
- ⚠️ **Sous-écrans `Profile/`** : créer le sous-dossier `Views/Screens/Profile/` (n'existe pas encore). DeleteAccountView Story 1.4 est à plat dans `Screens/` — laisser à plat (ne pas la déplacer pour ne pas régresser le NavigationLink existant).
- ⚠️ **Lazy fetch dans ProfileView** : ne pas bloquer l'UI au load. `task` SwiftUI + skeleton placeholders.
- ⚠️ **Préserver Déconnexion + Zone dangereuse** : le bouton signOut Story 1.2 + section Suppression Story 1.4 doivent rester dans la nouvelle ProfileView. Si on les casse en refactorant, non-régression Story 1.4 KO.

### Hors scope V1 (à tracker pour Epic ultérieur)

- **Modification email/password** : passe par Apple Sign-In côté Apple, pas par CoachingSage. Hors scope.
- **Avatar / photo de profil** : pas dans le PRD V1.
- **Modification disclaimer (re-acceptation)** : Epic 7+ avec mécanisme version bump.
- **Reset HealthKit autorisation** : V1, l'user passe par Réglages > Confidentialité > Santé. Pas de bouton dans l'app.
- **Bascule langue live** : Epic 7+ (override `\.locale`).
- **Audit log RGPD modifications profil** : Epic 7+ (cohérent Story 1.4 hors-scope audit RGPD).
- **Export RGPD du profil (Art. 20 portabilité)** : Epic 7+ (cohérent Story 1.4 hors-scope).
- **Modal confirmation "Quitter sans enregistrer ?"** : Epic 7+ si feedback beta.

### Standards de tests

- XCTest unit, mocks via protocol. Pas de UI test (règle).
- ~10-12 tests au total (5 ViewModels × 2-3 tests).
- Locale EN dans le runner (règle `feedback_test_localisation_anglais`).

### Références

- **Story 2.2** (PARQ schema, CoachingProfile model, codes sports) : `_bmad-output/implementation-artifacts/2-2-onboarding-core-minimal.md`
- **Story 2.1** (HealthKit re-import) : `_bmad-output/implementation-artifacts/2-1-healthkit-production-bridge.md`
- **Story 1.4** (DeleteAccountView, NavigationStack autour ProfileView, Section "Zone dangereuse") : `_bmad-output/implementation-artifacts/1-4-suppression-de-compte-rgpd.md`
- **ProfileView actuelle** : `CoachingSage/Views/Screens/ProfileView.swift` (placeholder Story 1.2 + ajout Story 1.4)
- **Pattern CoreProfileRepository.save** : `CoachingSage/Repositories/Implementations/DefaultCoreProfileRepository.swift`

### Project Structure Notes

- Nouveau sous-dossier `Views/Screens/Profile/` créé pour grouper les 5 sous-écrans + MedicalDisclaimerView. Cohérent avec le pattern Story 2.2 `Views/Screens/Onboarding/`. **Ne pas y déplacer `DeleteAccountView`** (Story 1.4) — risque de régression sur le NavigationLink existant. Convention (review P2-3) : sous-dossier `Profile/` pour vues d'édition profil ; vues account/RGPD (DeleteAccountView, futurs ExportRGPD…) restent à plat dans `Screens/`.
- ViewModels à plat dans `ViewModels/` (pas de sous-dossier `Profile/`) — cohérent avec le pattern existant.
- Aucune nouvelle dépendance SPM. Aucune migration DB.

## Review Tracking — 2026-04-26 (review pré-implem)

Review adversarial par sous-agent `Plan` sur le draft initial. **4 P0 + 5 P1 + 5 P2** identifiés.

**P0 (tous traités)** :
- ✅ P0-1 + P0-2 : Mécanisme refresh `ProfileView` après save sous-écran non spécifié + `.task` ne re-fire pas au pop NavigationLink → Task 1.8 corrigée : `.onAppear` au lieu de `.task`, pas de coupling parent-enfant explicite, refresh idiomatique SwiftUI.
- ✅ P0-3 : Race condition recalcul `requiresMedicalClearance` → AC6 + Task 5.x : bouton désactivé pendant `saveState == .loading`, sérialisation Task avec annulation. Sécurité Léon Epic 3 préservée.
- ✅ P0-4 : Cross-user leak (auth state change pendant fetch) → AC1 + Task 1.8 : `ProfileViewModel.refresh()` capture `userId` au début, re-vérifie après chaque `await`, discard si auth a basculé. RGPD critique fixé.

**P1 (tous traités)** :
- ✅ P1-1 : Retain cycle Task debounce → Task 6.3 explicite `[weak self]` + stockage `private var debounceTask: Task<Void, Never>?` + check `Task.isCancelled`.
- ✅ P1-2 : Burst toggle revert écrasant état correct → Task 6.4 : ne revert que si `analyticsConsent == valueAttemptedAtSave`.
- ✅ P1-3 : Form double chevron sur DeleteAccount NavigationLink → Task 1.7 : retirer `HStack` custom + chevron manuel, laisser Form styler le NavigationLink natif. Garder icône triangle d'alerte + couleur error.
- ✅ P1-4 : `coachingProfile` nil race au premier render → AC1 + Task 1.8 : `state: ViewState<(SageCoreProfile, CoachingProfile)>`, switch sur idle/loading/loaded/error, skeleton placeholder pendant loading, pas de force-unwrap.
- ✅ P1-5 : Footer "reboot" UX bizarre → AC3 retravaillé : injection `.environment(\.locale, ...)` à la racine de `CoachingSageApp` lue depuis `coreProfile.language`. Bascule live sans reboot. +0.25j accepté en mode sopddl pour éviter UX apologetic.

**P2 traités** :
- ✅ P2-1 : CTA HealthKit denied → silencieux Task 3.4 enrichi : si déjà demandé + tous fields nil → label CTA passe à "Activer dans Réglages > Santé" qui ouvre `UIApplication.openSettingsURLString`.
- ✅ P2-2 : Prérequis Story 2.2 mergée → ajout section Dev Notes "Prérequis".
- ✅ P2-3 : Asymétrie sous-dossier `Profile/` vs `DeleteAccountView` à plat → Project Structure Notes explicite la convention (édition profil → sous-dossier, RGPD → flat).
- ✅ P2-4 : Conflit user dev avec test 2.2 → Task 9.6 utilise un user dédié `2-3-test-onboarding@coachingsage.dev` distinct de 2.2.
- ✅ P2-5 : Test bascule EN renforcé → Task 10.5 demande de lister les ~25 clés `profile.*` une par une.

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
