# Story 2.1 : HealthKit Production Bridge

Status: ready-for-dev

<!-- Note: Validation est optionnelle. Lance `validate-create-story` pour un quality check avant `dev-story`. -->

## Story

**As a** utilisateur CoachingSage prêt à compléter l'onboarding,
**I want** que l'app puisse lire mes caractéristiques personnelles depuis Apple Santé (sexe, date de naissance, poids, taille),
**so that** Story 2.2 (Onboarding Core Minimal) puisse pré-remplir l'écran 2 sans que je tape ces infos à la main, avec fallback manuel si je refuse l'autorisation.

## Acceptance Criteria

1. **AC1 — Capability HealthKit activée** : `CoachingSage.entitlements` contient **uniquement** `com.apple.developer.healthkit = true`. ⚠️ **NE PAS ajouter `com.apple.developer.healthkit.access`** : cette clé n'a de sens que pour les Clinical Health Records (hors scope V1). La présence d'un array vide est inhabituelle côté Apple Review — préférer son absence complète (review P1.4 2026-04-26). Le profil Apple Developer Team `QLSTX2JJPF` doit avoir HealthKit activé pour le bundle ID `com.sopddl.coachingsage.app` (Sophie ajoute la capability via la console developer.apple.com si pas encore fait — voir Pièges).

2. **AC2 — Purpose strings FR + EN** : `project.yml` ajoute la clé `NSHealthShareUsageDescription` dans `targets.CoachingSage.info.properties`, avec une string localisée. Le texte doit être **précis et orienté usage onboarding** (Apple Review reject les purpose strings vagues type « pour mieux vous servir »). Recommandation testée sur GardenSage : « CoachingSage utilise Apple Santé pour pré-remplir votre profil sportif (sexe, âge, poids, taille). Vous pouvez aussi saisir ces infos manuellement. » + équivalent EN. ⚠️ La localisation se fait via `InfoPlist.xcstrings` (pas `Localizable.xcstrings`) : créer ce fichier si absent.

3. **AC3 — Service protocol-based + impl par défaut** : `Services/HealthKitService.swift` expose un protocol `HealthKitServiceProtocol: Sendable` (read-only V1) et une impl `DefaultHealthKitService`. Surface minimale :
   - `var isHealthDataAvailable: Bool { get }` — wrap `HKHealthStore.isHealthDataAvailable()` (false sur Mac, false sur iPad < iPadOS 17, true ailleurs). **Usage côté Story 2.2** : raccourci pour cacher la CTA HealthKit si le device ne supporte pas (cosmétique). Pas un prérequis fonctionnel — `requestProfileAuthorization()` et `fetchProfileData()` font leurs propres guards en interne.
   - `var hasRequestedAuthorization: Bool { get }` — true si `requestProfileAuthorization()` a déjà été appelé avec succès au moins une fois sur ce device. Backed par `UserDefaults` (clé `healthkit.authorization.requested`). Permet à Story 2.2 de différencier « première fois → afficher CTA "Importer depuis Apple Santé" » vs « déjà demandé → ne pas re-prompter, traiter nil comme "saisi manuellement" ».
   - `func requestProfileAuthorization() async throws` — demande l'autorisation pour 4 types READ uniquement : `HKCharacteristicType(.biologicalSex)`, `HKCharacteristicType(.dateOfBirth)`, `HKQuantityType(.bodyMass)`, `HKQuantityType(.height)`. **Aucun WRITE, aucun workout/HR/steps** (ces types restent dans le Spike, ressortiront en Epic 7 hub HealthKit universel — limite l'effort Apple Review V1). Marque `hasRequestedAuthorization = true` après succès du `try await healthStore.requestAuthorization(...)`.
   - `func fetchProfileData() async -> HealthKitProfileData` — retourne une struct avec 4 champs optionnels. Ne throw jamais : un champ nil = donnée non disponible / refusée silencieusement (Apple ne révèle pas le refus côté read).

4. **AC4 — Struct résultat** : `HealthKitProfileData` (struct dans le même fichier que le service) :
   ```swift
   struct HealthKitProfileData: Equatable, Sendable {
       let biologicalSex: HKBiologicalSex?  // .female/.male/.other/nil si non renseigné ou refusé
       let dateOfBirth: Date?                // nil si non renseigné ou refusé
       let bodyMassKg: Double?               // latest sample, nil si jamais saisi ou refusé
       let heightCm: Double?                 // latest sample, nil si jamais saisi ou refusé
   }
   ```
   ⚠️ **Sémantique nil = inconnu** sur les valeurs elles-mêmes : Apple ne permet pas de distinguer « refusé vs jamais saisi » côté types READ. La distinction « première fois vs auth déjà demandée » se fait via `hasRequestedAuthorization` (AC3) — c'est le seul signal que Story 2.2 a pour adapter la CTA.

5. **AC5 — Privacy semantic respectée** : pas d'erreur loggée ni d'exception levée si l'utilisateur refuse l'autorisation. `fetchProfileData()` retourne juste une struct avec des nils. Le seul cas où `requestProfileAuthorization()` throw c'est si HealthKit est indisponible (iPad incompatible / device cassé) ou en cas d'erreur HKError critique non liée à la décision utilisateur. **Le code appelant (Story 2.2) doit pouvoir continuer le flow normalement quoi qu'il arrive**.

6. **AC6 — Injection dans `AppDependencies`** : ajouter `let healthKitService: any HealthKitServiceProtocol` à la struct `AppDependencies` et instancier `DefaultHealthKitService()` dans `AppDependencies.live(modelContext:)`. Aucune dépendance injectée requise (le service est stateless côté init, juste un wrapper sur `HKHealthStore`).

7. **AC7 — Guard `IS_UI_TESTING`** : `DefaultHealthKitService.requestProfileAuthorization()` et `fetchProfileData()` no-op si l'env `IS_UI_TESTING` est true (return immédiat / struct toute nil). Pattern cohérent avec `DefaultCoreProfileRepository.save()` (Story 1.1a) et `softDelete()` (Story 1.4 AC7). Sinon les tests UI déclencheraient le dialog système HealthKit qui est non-scriptable.

8. **AC8 — Tests unitaires + Mock** : `MockHealthKitService` côté `CoachingSageTests/Mocks/` permet d'injecter une `HealthKitProfileData` arbitraire pour les tests Story 2.2. Aucun test sur la vraie impl (HealthKit n'est pas mockable côté unit — ça relève d'un test d'intégration manuel). Le seul test unit côté V1 = vérifier que la struct `HealthKitProfileData` compile et qu'elle est `Equatable`.

9. **AC9 — Pas de UI applicative livrée par cette story** : Story 2.1 = infra pure (entitlement + service + injection). Aucun écran utilisateur n'invoque le service à l'issue de 2.1. La validation visuelle se fait via Story 2.2 (écran 2 onboarding). Cmd+B + Cmd+U + non-régression Story 1.x suffisent pour clore 2.1. ⚠️ La capability HealthKit côté Apple Developer Console doit être activée AVANT Cmd+B (sinon erreur de signing).

## Tasks / Subtasks

- [ ] **Task 1** : Activer la capability HealthKit côté Apple Developer + signing local (AC: #1)
  - [ ] ⚠️ **STOP — ordre obligatoire** : 1.1 et 1.2 DOIVENT être faites avant 1.3. Sinon `Cmd+B` échoue avec une erreur de signing cryptique (`Provisioning profile doesn't include com.apple.developer.healthkit entitlement`). Cocher chaque sous-tâche dans l'ordre.
  - [ ] 1.1 Sophie : aller sur developer.apple.com → Identifiers → `com.sopddl.coachingsage.app` → cocher HealthKit (sans Background Delivery, sans Clinical Health Records — on garde minimal V1). Sauvegarder.
  - [ ] 1.2 Sophie : régénérer/télécharger le provisioning profile dev via Xcode (Cmd+, → Accounts → Download Manual Profiles) ou laisser Xcode "Automatically manage signing" le faire au prochain Cmd+B.
  - [ ] 1.3 ⚠️ **Une fois 1.1 + 1.2 confirmées**, modifier `CoachingSage/CoachingSage.entitlements` : ajouter **uniquement** `<key>com.apple.developer.healthkit</key><true/>`. **Ne PAS ajouter `com.apple.developer.healthkit.access`** (review P1.4). Ne pas toucher aux entrées existantes (`applesignin`, `application-groups`).
  - [ ] 1.4 Aucun changement requis dans `Config-Debug.xcconfig` / `Config-Release.xcconfig` / `Config-Staging.xcconfig` (la capability passe par les entitlements, pas par les xcconfig).

- [ ] **Task 2** : Purpose string `NSHealthShareUsageDescription` localisée (AC: #2)
  - [ ] 2.0 ⚠️ **POC bloquant InfoPlist.xcstrings** : créer un `CoachingSage/Resources/InfoPlist.xcstrings` minimal (juste `NSHealthShareUsageDescription` FR), rerun `xcodegen generate`, build, puis vérifier que la clé est résolue dans le bundle généré :
    ```bash
    plutil -p ~/Library/Developer/Xcode/DerivedData/CoachingSage-*/Build/Products/Debug-iphonesimulator/CoachingSage.app/Info.plist | grep NSHealthShareUsageDescription
    ```
    Doit retourner la string FR. **Si nil ou vide → fallback** Task 2.0bis (legacy `.lproj/InfoPlist.strings`).
  - [ ] 2.0bis (fallback si 2.0 KO) : créer `CoachingSage/Resources/fr.lproj/InfoPlist.strings` + `en.lproj/InfoPlist.strings` (format legacy `"NSHealthShareUsageDescription" = "...";`) + ajouter `INFOPLIST_KEY_NSHealthShareUsageDescription = "$(NSHealthShareUsageDescription)"` dans les 3 xcconfig. **À éviter** car format legacy, mais documenté Apple et fonctionne à coup sûr.
  - [ ] 2.1 Modifier `CoachingSage/project.yml` ligne 56-78 : ajouter sous `info.properties` la clé `NSHealthShareUsageDescription`. Si Task 2.0 OK → valeur arbitraire FR (le xcstrings la surchargera à la build). Si fallback Task 2.0bis → valeur `$(INFOPLIST_KEY_NSHealthShareUsageDescription)`.
  - [ ] 2.2 Contenu du `InfoPlist.xcstrings` (cas nominal Task 2.0) :
    - Clé `NSHealthShareUsageDescription`
    - FR (default) : « CoachingSage utilise Apple Santé pour pré-remplir votre profil sportif (sexe, âge, poids, taille) lors de l'onboarding. Vous pouvez aussi saisir ces informations manuellement à tout moment. »
    - EN : « CoachingSage uses Apple Health to pre-fill your sport profile (sex, age, weight, height) during onboarding. You can also enter this info manually at any time. »
  - [ ] 2.3 ⚠️ **Apple Review** : la string DOIT mentionner explicitement les types lus (sex/age/poids/taille). Les purpose strings vagues (« pour personnaliser votre expérience ») sont rejetées par Apple Review. Référence App Store Review Guidelines 5.1.3.
  - [ ] 2.4 Vérifier que `InfoPlist.xcstrings` est dans `Resources/` (listé dans `project.yml` ligne 67 `buildPhase: resources`). Sinon il ne sera pas embarqué.
  - [ ] 2.5 Rerun `xcodegen generate` après modif du project.yml (règle CS : XcodeGen regen safe — voir mémoire `xcodegen_regen_workflow`).

- [ ] **Task 3** : Créer `Services/HealthKitService.swift` (AC: #3, #4, #5, #7)
  - [ ] 3.1 Créer le fichier `CoachingSage/Services/HealthKitService.swift`. Header : `// PRIMARY HealthKit impl — synchroniser GardenSage/TailorSage si port futur (voir mémoire architecture_decisions.md). Read-only V1 : sex/DOB/poids/taille pour onboarding.` (Marqueur PRIMARY = signale aux futurs sister projects que c'est la source à porter.)
  - [ ] 3.2 Définir `protocol HealthKitServiceProtocol: Sendable` (4 membres : `isHealthDataAvailable: Bool`, `hasRequestedAuthorization: Bool`, `requestProfileAuthorization() async throws`, `fetchProfileData() async -> HealthKitProfileData`). ⚠️ `Sendable` est requis : le service est appelé depuis ViewModels `@MainActor` mais les `await` HealthKit basculent sur thread arbitraire (review P1.1).
  - [ ] 3.3 Définir `struct HealthKitProfileData: Equatable, Sendable` (4 fields optionnels — voir AC4).
  - [ ] 3.4 Définir `final class DefaultHealthKitService: HealthKitServiceProtocol, @unchecked Sendable`. Init sans paramètres (`init()`). Stocke `private let healthStore = HKHealthStore()` et `private let userDefaults: UserDefaults` (default `.standard`, injectable pour tests). `@unchecked` car `HKHealthStore` n'est pas formellement `Sendable` mais documenté thread-safe par Apple.
  - [ ] 3.5 ⚠️ **Guard `IS_UI_TESTING` au début de chaque méthode** : `requestProfileAuthorization()` no-op (return), `fetchProfileData()` retourne `HealthKitProfileData(biologicalSex: nil, dateOfBirth: nil, bodyMassKg: nil, heightCm: nil)`, `hasRequestedAuthorization` retourne false. Sinon Story 2.2 UI tests vont déclencher le dialog système non-scriptable.
  - [ ] 3.6 Impl `requestProfileAuthorization()` :
    - Guard `HKHealthStore.isHealthDataAvailable()` → throw `HealthKitError.notAvailable`.
    - Construire le `Set<HKObjectType>` à READ : `[.biologicalSex, .dateOfBirth, .bodyMass, .height]` via `HKCharacteristicType.characteristicType(forIdentifier:)` et `HKQuantityType.quantityType(forIdentifier:)`. Filtrer les optionals (robustesse).
    - `try await healthStore.requestAuthorization(toShare: [], read: typesToRead)`. **`toShare: []` car aucun WRITE V1**.
    - **Au succès** : `userDefaults.set(true, forKey: "healthkit.authorization.requested")` → permet à `hasRequestedAuthorization` de retourner true au prochain call.
    - Pas de tracking de status fin — Apple ne fournit pas de signal exploitable côté READ.
  - [ ] 3.7 Impl `fetchProfileData()` :
    - Guard availability → return struct toute nil.
    - **Caractéristiques** (sex, DOB) : ⚠️ **PAS de `try?`** (review P1.2 — masque les erreurs d'auth oubliée). Wrap explicite :
      ```swift
      let sex: HKBiologicalSex?
      do {
          let value = try healthStore.biologicalSex().biologicalSex
          sex = (value == .notSet) ? nil : value
      } catch {
          #if DEBUG
          Self.logger.debug("biologicalSex throw — auth requested? hasRequestedAuthorization=\(self.hasRequestedAuthorization)")
          #endif
          sex = nil
      }
      ```
      Idem pour `dateOfBirthComponents()`. La conversion `.notSet → nil` ne s'applique qu'au sexe biologique. ⚠️ Apple throw `HKError.errorAuthorizationDenied` côté caractéristiques uniquement, c'est la spec.
    - **bodyMass** (latest) : `HKSampleQuery` avec limit:1, sortDescriptor `endDate descending`. Convertir en kg via `HKUnit.gramUnit(with: .kilo)`. Si `nil` ou erreur → nil. Pas de log, sauf en `#if DEBUG`.
    - **height** (latest) : pareil, convertir en cm via `HKUnit.meterUnit(with: .centi)` puis `doubleValue`.
    - **Séquentiel** (pas de `withTaskGroup`) : 4× ~50ms IPC = 200ms transparent côté UX onboarding. Simplicité > parallélisme V1 (review P2.2).
    - **Logger** : `private static let logger = Logger(subsystem: "com.sopddl.coachingsage", category: "service")` (pattern Story 1.4). Logs uniquement en `#if DEBUG` pour les erreurs HK (pollution logs prod sinon).
  - [ ] 3.8 Définir `enum HealthKitError: LocalizedError` :
    - `case notAvailable` : `errorDescription` retourne directement `"HealthKit n'est pas disponible sur cet appareil."` (FR hardcodé V1, review P2.1 — l'erreur n'est jamais surfacée à l'utilisateur en V1, AC9. La localisation arrivera Epic 7 quand on aura un écran qui surface l'erreur).
    - 1 case unique pour V1, on étoffera Epic 7.

- [ ] **Task 4** : Injection dans `AppDependencies` (AC: #6)
  - [ ] 4.1 Modifier `CoachingSage/App/AppDependencies.swift` :
    - Ajouter `let healthKitService: any HealthKitServiceProtocol` dans la struct.
    - Dans `live(modelContext:)`, instancier `let healthKitService = DefaultHealthKitService()` puis l'inclure dans le return.
  - [ ] 4.2 Pas de modification dans `CoachingSageApp.swift` (la propagation env passe par `appDependencies` déjà câblée).

- [ ] **Task 5** : Mock + tests unitaires (AC: #8)
  - [ ] 5.1 Créer `CoachingSage/CoachingSageTests/Mocks/MockHealthKitService.swift` :
    ```swift
    final class MockHealthKitService: HealthKitServiceProtocol, @unchecked Sendable {
        var isHealthDataAvailable: Bool = true
        var hasRequestedAuthorization: Bool = false
        var stubbedProfile: HealthKitProfileData = HealthKitProfileData(
            biologicalSex: nil, dateOfBirth: nil, bodyMassKg: nil, heightCm: nil
        )
        var requestAuthorizationCallCount: Int = 0
        var requestAuthorizationShouldThrow: Error?

        func requestProfileAuthorization() async throws {
            requestAuthorizationCallCount += 1
            if let error = requestAuthorizationShouldThrow { throw error }
            hasRequestedAuthorization = true  // simule la persistance UserDefaults
        }
        func fetchProfileData() async -> HealthKitProfileData { stubbedProfile }
    }
    ```
  - [ ] 5.2 Créer `CoachingSage/CoachingSageTests/Services/HealthKitProfileDataTests.swift` (1 test — la struct doit être Equatable et tenir 4 champs optionnels). 5 lignes.
  - [ ] 5.3 Créer `CoachingSage/CoachingSageTests/Services/DefaultHealthKitServiceTests.swift` avec UN test couvrant le guard `IS_UI_TESTING` (review P1.3) :
    ```swift
    func testDefaultServiceReturnsEmptyProfileUnderUITesting() async {
        setenv("IS_UI_TESTING", "1", 1)
        defer { unsetenv("IS_UI_TESTING") }
        let service = DefaultHealthKitService()
        let profile = await service.fetchProfileData()
        XCTAssertEqual(profile, HealthKitProfileData(biologicalSex: nil, dateOfBirth: nil, bodyMassKg: nil, heightCm: nil))
        XCTAssertFalse(service.hasRequestedAuthorization)
    }
    ```
    Évite la régression silencieuse si le guard est retiré par mégarde.
  - [ ] 5.4 Pas d'autres tests sur `DefaultHealthKitService` (HealthKit non-mockable côté unit). ⚠️ Documenter dans `Dev Notes > Standards de tests` : volontaire, pas un trou de couverture.

- [ ] **Task 6** : Localisation purpose string (AC: #2)
  - [ ] 6.1 Cas nominal — `InfoPlist.xcstrings` (Task 2.0 OK) : créer `CoachingSage/Resources/InfoPlist.xcstrings`. Structure JSON minimale avec 1 clé `NSHealthShareUsageDescription`, 2 langues FR + EN (voir Task 2.2).
  - [ ] 6.2 Cas fallback — `*.lproj/InfoPlist.strings` (Task 2.0bis) : créer les 2 fichiers legacy `Resources/fr.lproj/InfoPlist.strings` + `Resources/en.lproj/InfoPlist.strings` (format `"NSHealthShareUsageDescription" = "...";` un par fichier). À utiliser SEULEMENT si Task 2.0 échoue.
  - [ ] 6.3 Vérifier que le fichier (xcstrings ou .strings) apparaît bien dans `Resources/` après `xcodegen generate` et qu'il est inclus en build phase resources.
  - [ ] 6.4 ⚠️ Ne PAS toucher `Localizable.xcstrings` pour cette story — `InfoPlist.xcstrings` (ou `InfoPlist.strings`) est un fichier séparé pour les chaînes Info.plist (convention Apple). Pas de clé `healthkit.error.*` non plus (review P2.1 — l'erreur reste hardcodée FR V1, l'utilisateur ne la voit pas).

- [ ] **Task 7** : Validation Sophie + non-régression (AC: #9)
  - [ ] 7.1 **Pré-requis Sophie** : capability HealthKit activée côté developer.apple.com (Task 1.1) AVANT Cmd+B, sinon erreur de signing.
  - [ ] 7.2 **Cmd+B** sur simu iPhone 17.x : doit compiler sans erreur ni warning HealthKit.
  - [ ] 7.3 **Cmd+U** : `HealthKitProfileDataTests` doit passer + non-régression sur tous les tests existants Epic 1.
  - [ ] 7.4 **Test manuel léger Cmd+R** : lancer l'app, faire le flow login existant Story 1.1b → onglet Profil → vérifier qu'aucun crash, aucune popup HealthKit (rien ne déclenche encore l'autorisation, c'est Story 2.2 qui l'utilisera). Aucun changement UX visible attendu pour cette story.
  - [ ] 7.5 **Validation device réel optionnelle** : pas requise pour clore 2.1 (le service n'est jamais appelé). Sera validée bout en bout en Story 2.2 sur simu (peut return nil pour tous les types) ET sur iPhone réel de Sophie (data réelle dans Apple Santé).
  - [ ] 7.6 Non-régression à valider :
    - Login email Story 1.1b OK
    - Bascule TabView Story 1.2 OK
    - SyncService banner Story 1.3 OK
    - DeleteAccount Story 1.4 OK

## Dev Notes

### Décision archi : scope minimal V1, hub universel reporté Epic 7

**Choix retenu (2026-04-26)** : Story 2.1 livre **uniquement** l'infra HealthKit pour le pré-fill onboarding (4 types READ : sex, DOB, bodyMass, height). Pas de WRITE, pas de workouts/HR/steps.

**Pourquoi ce découpage** :
- **Apple Review surface minimale** : un purpose string par usage. V1 dit « pré-fill profil sportif », c'est tout. Si on ajoutait workouts/HR maintenant, il faudrait justifier des usages qui ne sont pas encore implémentés côté UX (Léon Epic 3, programmes Epic 4+) → Apple Review rejette plus facilement.
- **Effort port plus court** : le Spike fait ~340 lignes (read+write+queries complexes). La V1 onboarding fait ~120 lignes (3 méthodes, 4 types, lectures simples).
- **Hub universel = Epic 7** : c'est là qu'on portera workouts/HR/steps + écriture des sessions CoachingSage dans Apple Santé + détection sources tierces (Strava/Garmin/Fitbit). Story 2.1 N'EST PAS le hub universel, c'est juste son fondement infra (entitlement + service skeleton).
- **Migration vers le hub** : quand Epic 7 arrivera, on étendra `HealthKitServiceProtocol` (méthodes additionnelles), on étendra `typesToRead` (workouts, HR, etc.), on ajoutera `typesToWrite`, on étendra le purpose string. Pas de breaking change attendu sur la surface V1 (`fetchProfileData()` restera).

**Pourquoi pas tout livrer maintenant ("on aura besoin de toute façon")** : YAGNI + risque Apple Review + chaque type read additionnel = un risque de purpose string vague. On livre juste ce que Story 2.2 consomme.

### Privacy semantic HealthKit (à comprendre avant de coder)

Apple Health a un modèle de privacy **asymétrique** read vs write :

| Côté | Ce que l'app sait après requestAuthorization |
|---|---|
| WRITE | L'app sait précisément si chaque type est autorisé (`authorizationStatus(for:)` retourne `.notDetermined` / `.sharingAuthorized` / `.sharingDenied`). |
| READ | L'app **ne sait pas** si l'utilisateur a refusé. `authorizationStatus(for:)` retourne `.notDetermined` même après un refus. **C'est volontaire** (privacy by design : empêcher l'app de pénaliser un utilisateur qui refuse). |

**Conséquence pour Story 2.2** : on tente de lire, et on traite « valeur reçue » (qu'on pré-remplit) vs « valeur nil » (qu'on laisse vide à saisir). Pas de message d'erreur du type « tu as refusé HealthKit », pas de re-prompt agressif. C'est pour ça qu'`AC5` insiste sur le "fallback gracieux".

**Implication pour le test** : sur simulateur, par défaut tous les champs HealthKit sont vides → on lit toujours nil. Pour valider la lecture réelle, soit injecter manuellement des données dans l'app Santé du simu (paramètres user), soit tester sur iPhone réel.

### Patterns architecture à suivre

- **Protocol + Default impl + Mock** : exactement comme `AuthService` Story 1.1b, `SyncService` Story 1.3, `AccountService` Story 1.4.
- **Pas de SageCore SPM côté CoachingSage** : `HealthKitService` vit dans `Services/` local, pas dans le SPM. Cohérent avec les autres services CS.
- **Pas de header `[COPIE IDENTIQUE]`** : aucun équivalent dans GardenSage/TailorSage à synchroniser. Si TailorSage ou GardenSage ajoutent HealthKit plus tard, à ce moment-là on évalue extraction SageCore. Pas avant.
- **Stateless service** : pas de `@Observable`, pas de `@Published`. Chaque appel est indépendant. Le ViewModel Story 2.2 stocke l'état UI, pas le service.

### Source tree à toucher

| Fichier | Action |
|---|---|
| `CoachingSage/CoachingSage.entitlements` | Modifier (ajout 2 keys HealthKit) |
| `CoachingSage/project.yml` | Modifier (ajout `NSHealthShareUsageDescription` dans info.properties) |
| `CoachingSage/Resources/InfoPlist.xcstrings` | Créer (purpose string FR+EN) |
| `CoachingSage/Services/HealthKitService.swift` | Créer (~120 lignes : protocol + struct + enum erreur + impl) |
| `CoachingSage/App/AppDependencies.swift` | Modifier (injection healthKitService) |
| `CoachingSage/Resources/Localizable.xcstrings` | Edit ciblé (1 clé `healthkit.error.notAvailable`) |
| `CoachingSage/CoachingSageTests/Mocks/MockHealthKitService.swift` | Créer |
| `CoachingSage/CoachingSageTests/Services/HealthKitProfileDataTests.swift` | Créer (1 test Equatable) |

**Total** : 5 nouveaux fichiers, 3 fichiers modifiés. **0 nouvelle dépendance SPM** (HealthKit est un framework Apple, pas un package).

### Pièges à éviter

- ⚠️ **Capability Apple Developer** : si la capability HealthKit n'est pas activée côté developer.apple.com pour le bundle ID, le build échoue avec une erreur de signing cryptique (`Provisioning profile doesn't include com.apple.developer.healthkit entitlement`). Sophie doit faire Task 1.1 AVANT Cmd+B, sinon perte de temps.
- ⚠️ **Simulator iPad < iPadOS 17** : `HKHealthStore.isHealthDataAvailable()` retourne false. Notre code gère ça (AC5 : pas de crash, struct toute nil). Mais les tests visuels Story 2.2 doivent se faire sur simu iPhone (jamais iPad pour CoachingSage en V1, on est portrait-only iPhone-only).
- ⚠️ **`requestAuthorization` sur simu = popup système** : la première fois qu'on appelle, le simu affiche le dialog HealthKit. Si l'utilisateur clique « Ne pas autoriser », il faut aller dans **Réglages > Confidentialité > Santé** pour réactiver (le re-prompt automatique ne fonctionne pas une fois refusé). À documenter pour Sophie quand elle testera 2.2.
- ⚠️ **Pas de Background Delivery** : V1 n'active pas `enableBackgroundDelivery` côté HealthKit. Pas de fond. Pas d'observers. Stories Epic 7 ajouteront ça si besoin.
- ⚠️ **`HKBiologicalSex.notSet` ≠ nil** : la spec Apple retourne `.notSet` (rawValue 0) si l'utilisateur n'a pas renseigné le champ dans Apple Santé. Notre conversion : `notSet → nil` côté `HealthKitProfileData.biologicalSex`. Sinon Story 2.2 ferait un "biologicalSex == .notSet" qui est confusant.
- ⚠️ **iOS 18+ : `HKHealthStore.statusForAuthorizationRequest`** existe maintenant (peut indiquer si une demande est nécessaire). Pas utilisé V1 (deployment target iOS 17). À évaluer Epic 7 quand on bumpera ou pas.
- ⚠️ **Logs Spike à NE PAS importer** : le Spike utilise `print("[HealthKit] ...")` partout. Notre prod doit utiliser `Logger(subsystem: "com.sopddl.coachingsage", category: "service")` côté warn, et **NE PAS LOG les refus utilisateur** (pollue les logs sans valeur).
- ⚠️ **`healthStore.biologicalSex()` et `dateOfBirthComponents()` sont des méthodes synchrones throwing** (différent des queries qui sont async). Wrap dans `do/catch` (PAS `try?` qui swallow trop largement, voir Task 3.7). Log uniquement en `#if DEBUG` pour aider à diagnostiquer un oubli d'appel à `requestProfileAuthorization()` — c'est la sémantique Apple normale d'un refus, mais aussi le symptôme d'un appel qui n'a jamais demandé l'auth.
- ⚠️ **`requestAuthorization` peut hang en théorie** : si le système est saturé, l'API Apple peut ne jamais résoudre. V1 : pas de timeout custom (Apple gère, et le cas est extrêmement rare). À ré-évaluer Epic 7 si on observe des freezes en prod (review P2.5).

### Hors scope V1 (à tracker pour Epic ultérieur)

- **Lecture workouts / HR / steps / energy / distance** → Epic 7 hub universel.
- **Écriture workouts** (CoachingSage exporte ses sessions vers Apple Santé) → Epic 7.
- **Background delivery** (observer pattern HealthKit) → Epic 7 ou jamais (la sync au foreground suffit pour un coach sportif).
- **Re-prompt agressif si refus** → contraire à la philosophie produit (« le user choisit »). Jamais.
- **Détection automatique de la source** (Watch vs Garmin vs Fitbit) → Epic 7, on lira juste `sourceRevision.source.name` à ce moment-là.
- **Clinical Health Records** (`com.apple.developer.healthkit.access` peuplé) → Hors scope app coach sportif. Ne jamais activer.
- **HKActivitySummary** (anneaux d'activité Apple) → Epic 7 si pertinent.

### Standards de tests

- Pas de test sur la vraie `DefaultHealthKitService` (volontaire, doc dans Task 5.3).
- 1 test sur `HealthKitProfileData` (Equatable) — sanity check du compile + structure.
- `MockHealthKitService` avec 3 stubs pratiques : `isHealthDataAvailable`, `stubbedProfile`, `requestAuthorizationShouldThrow` — couvre les 3 cas du flow Story 2.2 (HK indispo / fallback / chemin nominal).
- Pas d'UI test pour cette story (règle `feedback_tests_non_regression`).
- Locale EN dans le test runner (règle `feedback_test_localisation_anglais` — rappel à la fin de l'epic).

### Références

- **Spike source** : `CoachingSage/Spike/HealthKit/_source-files/HealthKitService.swift` (340 lignes — porter ~30% en V1, le reste = Epic 7).
- **Mémoire architecture** : `architecture_decisions.md` — « HealthKit hub universel » (décision validée 2026-04-06, scope minimal V1 acté ici).
- **Mémoire spike status** : `epic0_spikes_status.md` — Spike HealthKit PASS, valide l'hypothèse hub universel.
- **Spike artifacts** : `spike_artifacts_locations.md` — résultats validation Spike 0.2.
- **Apple docs** :
  - `HKHealthStore.requestAuthorization(toShare:read:)` : https://developer.apple.com/documentation/healthkit/hkhealthstore/1614152-requestauthorization
  - HealthKit privacy asymmetry read/write : https://developer.apple.com/documentation/healthkit/protecting_user_privacy
- **Apple Review Guidelines purpose strings** : https://developer.apple.com/app-store/review/guidelines/#5.1.3
- **Pattern `IS_UI_TESTING` guard** : `CoachingSage/Repositories/Implementations/DefaultCoreProfileRepository.swift:97` (save) + `:128` (softDelete, ajouté Story 1.4).
- **Pattern injection `AppDependencies`** : `CoachingSage/App/AppDependencies.swift` (4 services actuels, on en ajoute un 5ème).
- **Pattern Logger** : `Logger(subsystem: "com.sopddl.coachingsage", category: "service")` (utilisé dans `AccountService.swift` Story 1.4).

### Project Structure Notes

- Alignement avec la structure existante : `Services/` à la racine (pattern actuel), `CoachingSageTests/Mocks/` et `CoachingSageTests/Services/` (pattern actuel).
- **Variance volontaire vs Spike** : pas de `@MainActor` sur `DefaultHealthKitService` — le service est utilisable depuis n'importe quel actor (les `await` HealthKit gèrent le thread eux-mêmes). Le Spike avait `@MainActor` pour simplifier l'usage SwiftUI dans la vue spike, on n'a pas besoin de cette contrainte côté prod (le ViewModel Story 2.2 sera `@MainActor`, et fera `await healthKitService.fetchProfileData()` depuis main → fonctionne).
- **Variance volontaire vs Spike** : pas de `ObservableObject`, pas de `@Published`, pas d'enum `HealthKitStatus`. Stateless. Le Spike trackait l'état pour le visualiser dans une vue debug ; en prod on relit à chaque besoin.
- Aucune nouvelle dépendance SPM. HealthKit est un framework Apple natif, embarqué via `import HealthKit`.

## Review Tracking — 2026-04-26 (review pré-implem)

Review adversarial par sous-agent `Plan` sur le draft initial. **2 P0 + 5 P1 + 5 P2** identifiés.

**P0 (tous traités dans cette révision du spec)** :
- ✅ P0.1 : `InfoPlist.xcstrings` non-confirmé supporté par XcodeGen → Task 2.0 POC bloquant + Task 2.0bis fallback `.lproj/InfoPlist.strings` legacy. Garantit l'embarquement de la purpose string quoi qu'il arrive.
- ✅ P0.2 : Race ordre Task 1.1 (Apple Developer) vs 1.3 (entitlements local) → ajout d'un STOP visible en tête de Task 1 + ordre obligatoire 1.1 → 1.2 → 1.3.

**P1 (tous traités)** :
- ✅ P1.1 Concurrence Sendable : `protocol HealthKitServiceProtocol: Sendable` + `final class DefaultHealthKitService: ..., @unchecked Sendable` (AC3 + Task 3.2 + 3.4). `HealthKitProfileData: Equatable, Sendable` (AC4 + Task 3.3).
- ✅ P1.2 `try?` swallowing biologicalSex/dateOfBirth → Task 3.7 explicite `do/try/catch` avec assertion `#if DEBUG` qui log si auth pas demandée (aide diagnostic Story 2.2).
- ✅ P1.3 Test guard `IS_UI_TESTING` manquant → Task 5.3 ajoute `testDefaultServiceReturnsEmptyProfileUnderUITesting`.
- ✅ P1.4 `com.apple.developer.healthkit.access` array vide inhabituel → AC1 + Task 1.3 disent explicitement de NE PAS l'ajouter. Garde uniquement `com.apple.developer.healthkit = true`.
- ✅ P1.5 Sémantique nil ambiguë pour Story 2.2 UX → ajout `var hasRequestedAuthorization: Bool { get }` au protocol (backed UserDefaults) + signal côté 2.2 pour différencier « première fois » vs « déjà demandé » (AC3 + Task 3.6).

**P2 traités** :
- ✅ P2.1 Localisation `HealthKitError.notAvailable` retirée (FR hardcodé V1, l'erreur n'est jamais surfacée par AC9). Task 3.8 + 6.4 simplifiés.
- ✅ P2.2 `withTaskGroup` parallélisme retiré → séquentiel only (Task 3.7).
- ✅ P2.3 `isHealthDataAvailable` doc clarifiée (AC3) : raccourci UI conditionnelle, pas un prérequis fonctionnel.
- ✅ P2.4 Header `// PRIMARY HealthKit impl` ajouté (Task 3.1) — signale aux sister projects que CS est la source.
- 📌 P2.5 Timeout `requestAuthorization` non spécifié V1 → mention dans Pièges à éviter, ré-évaluation Epic 7.

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
