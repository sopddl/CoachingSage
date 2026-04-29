# Story 1.4 : Suppression de Compte & RGPD

Status: done

<!-- Note: Validation est optionnelle. Lance `validate-create-story` pour un quality check avant `dev-story`. -->

## Story

**As a** utilisateur connecté à CoachingSage,
**I want** pouvoir supprimer mon compte et toutes mes données depuis l'écran Profil,
**so that** mon droit à l'oubli (RGPD Art. 17) soit respecté et toutes mes traces disparaissent en moins de 30 jours.

## Acceptance Criteria

1. **AC1** — Depuis l'onglet Profil (4ème tab), une section « Zone dangereuse » expose un bouton « Supprimer mon compte » accessible visuellement (icône triangle d'alerte + couleur erreur). **Prérequis : `ProfileView` doit être encapsulée dans un `NavigationStack` côté `MainTabView`** (sinon le `NavigationLink` vers `DeleteAccountView` ne pousse rien — voir Task 5.0).
2. **AC2** — Au tap sur le bouton, un `confirmationDialog` natif iOS demande une confirmation explicite (action destructive `.destructive`, action `.cancel` par défaut, message qui rappelle l'irréversibilité et le délai 30j).
3. **AC3** — Sur confirmation, `AccountService.deleteAccount()` orchestre dans cet ordre (pattern **ceinture-bretelles**, voir Dev Notes « Décision archi soft+hard ») :
   1. **Soft-delete** `SageCoreProfile` (SwiftData + Supabase `core_profiles.is_soft_deleted=true`, `deleted_at=now`) — utilise la méthode `softDelete()` existante du repository. **But : laisser une trace sûre si l'edge function échoue ensuite.**
   2. **Edge function** `delete-account` (POST avec JWT) qui fait **hard-delete** atomique côté Supabase : `delete from core_profiles where id=user.id` + `auth.admin.deleteUser(user.id)`. **Si l'edge function réussit, le soft-delete de l'étape 1 est écrasé immédiatement (pas un bug, c'est le filet de sécu).**
   3. `authService.signOut()` côté client (clear session locale).
4. **AC4** — `CoachingSageApp` réagit aux events `.signedOut` ET `.userDeleted` du flux `authStateChanges` (déjà câblé `CoachingSageApp.swift:104-117`) et bascule l'UI sur `AuthView`. Vérifier la non-régression, ne pas dupliquer.
5. **AC5** — Pendant la suppression, l'UI affiche un état `loading` (ProgressView + texte localisé), bouton désactivé. En cas d'erreur (edge function HTTP≠200, signOut throw, softDelete throw), message d'erreur affiché, bouton réactivé pour permettre un retry. **Le retry doit être idempotent** : `softDelete` rejoue sans erreur (cible `is_soft_deleted=true` déjà), `deleteAuthUser` rejoue (le user n'existe plus en `auth.users` → `auth.admin.deleteUser` doit retourner OK ou être trappé comme tel côté edge function).
6. **AC6** — RGPD Art. 17 garanti par **deux mécanismes complémentaires** :
   - **Voie nominale** : edge function = hard-delete immédiat de `core_profiles` + `auth.users` (le user ne peut plus se reconnecter dès l'instant T).
   - **Filet de sécurité** : si l'edge function échoue (réseau, 500, etc.), le `is_soft_deleted=true` de l'étape AC3.1 est purgé par le job `pg_cron` `purge-rgpd-core-profiles` (migration `001_initial_schema.sql:71-79`, DELETE après 30 jours). Aucune nouvelle migration nécessaire.
7. **AC7** — Aucun appel Supabase n'est tenté en environnement UI testing (`IS_UI_TESTING` env). **Action requise** : ajouter le guard `IS_UI_TESTING` au début de `DefaultCoreProfileRepository.softDelete()` (actuellement absent — seul `save()` l'a, ligne 97). Sinon les tests UI tenteraient un UPDATE Supabase via le placeholder client.
8. **AC8** — Localisation FR + EN complète pour toutes les chaînes (titre, message confirmation, bouton, états loading/error). Naming cohérent avec le pattern existant `auth.signOut`/`tab.profile` — les nouvelles clés vivent dans le namespace `account.delete.*` + `profile.section.*`.
9. **AC9** — Tests unitaires : `AccountService` (séquence + erreurs **incluant HTTP 500 edge function**), `AccountViewModel` (transitions `ViewState`), idempotence (retry après softDelete réussi mais signOut KO). Pas d'UI tests pour cette story (règle perso : unit + Cmd+R suffit).

## Tasks / Subtasks

- [ ] **Task 1** : Edge function `delete-account` côté Supabase CoachingSage (AC: #3, #6)
  - [ ] 1.1 Créer `CoachingSage/supabase/functions/delete-account/index.ts` — port **adapté au scope V1 CS** de `GardenSage/supabase/functions/delete-account/index.ts`
  - [ ] 1.2 ⚠️ **DROP toutes les opérations sur les tables garden** (qui n'existent pas en CoachingSage) : `garden_tasks`, `plants`, `garden_collaborators`, `gardens`, `user_garden_plants`, `user_flore_conversations`, `ai_usage_logs`, `garden_profiles`. **Garder uniquement** : vérification JWT (lignes 13-43 du précédent), création `adminClient` avec `service_role` (ligne 46), `delete from core_profiles where id=user.id`, `auth.admin.deleteUser(user.id)`, gestion CORS et erreurs.
  - [ ] 1.3 Pattern de sécurité : extraction du `user.id` via `userClient.auth.getUser()` qui valide le JWT (PAS de `userId` reçu dans le body — éviter qu'un user puisse supprimer le compte d'un autre).
  - [ ] 1.4 ⚠️ **L'edge function doit retourner 200 si succès, 4xx/5xx avec body `{error}` sinon.** Le client `AccountService.deleteAuthUser()` doit throw si HTTP≠200 (voir Task 2.5) — ne PAS swallow l'erreur sinon l'user voit "compte supprimé" alors que `auth.users` est intact.
  - [ ] 1.5 Idempotence : si `auth.admin.deleteUser` retourne « user not found » (cas retry après succès partiel), retourner 200 quand même (on est déjà dans l'état cible).
  - [ ] 1.6 Déployer sur le projet `coachingsage-dev` via Dashboard Supabase (Sophie déploie elle-même, pas de CLI auto). Vérifier que les secrets `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY` sont présents en env de l'edge function.
  - [ ] 1.7 Tester l'edge function avec curl + JWT valide → vérifier 200 + suppression effective dans `auth.users` ET `core_profiles`. Tester aussi avec un JWT d'un user différent → s'assurer qu'il supprime SON compte, pas un autre.

- [ ] **Task 2** : `AccountService` côté Swift (AC: #3, #5, #7)
  - [ ] 2.1 Créer `CoachingSage/Services/AccountService.swift` (protocol + impl) — port **simplifié** de `GardenSage/Services/AccountService.swift`. Header `// [COPIE IDENTIQUE — synchroniser avec GardenSage]` (pattern actuel CS).
  - [ ] 2.2 Surface protocol minimale : `func deleteAccount() async throws` — pas de `updatePrivacyConsent` (sera ajouté en Story Epic 2.x quand le toggle analytics arrivera dans les paramètres).
  - [ ] 2.3 Dépendances injectées : `coreProfileRepository`, `authService`. **Pas** d'autres repositories à injecter (pas encore de Programs / Sessions / etc. — Epic 3+).
  - [ ] 2.4 Séquence (3 étapes ceinture-bretelles) :
    - `softDelete(coreProfile)` (throw → propagé : empêche d'aller plus loin si la trace de sécu rate, voie nominale + filet inutilisable)
    - `try await deleteAuthUser()` (⚠️ **throws** sur HTTP≠200, **pas** swallow comme GardenSage actuellement)
    - `try await authService.signOut()` (clear local)
  - [ ] 2.5 ⚠️ **`deleteAuthUser()` doit throw** : remplace le pattern actuel GardenSage qui swallow l'erreur en log (`Self.logger.warning("delete-account failed: \(error)")`). Sinon AC5 + AC9 cassés. Lever `AppError.sync("delete-account HTTP \(statusCode): \(body)")` en cas d'échec. Bonus : `request.timeoutInterval = 15` (sinon URLSession default = 60s, UX bloquée si réseau down).
  - [ ] 2.6 Cas profil local manquant : `fetchCurrentProfile() == nil` → skip step 1 (pas de softDelete possible) → tenter quand même `deleteAuthUser()` + `signOut()` (le user a un JWT valide, il a le droit de demander la suppression côté serveur).
  - [ ] 2.7 Helper privé `deleteAuthUser()` :
    - Guard `IS_UI_TESTING` env → return immédiat sans erreur (préserve les tests UI)
    - Lecture `SUPABASE_HOST` et `SUPABASE_ANON_KEY` depuis `Bundle.main` (déjà configurés via `.xcconfig`)
    - Pas de body JSON (l'edge function ignore le body) → ne pas envoyer `DeleteAccountRequest` inutile (cf. P2.14 review)
    - ⚠️ **Logs en `#if DEBUG`** pour le body de réponse HTTP (peut leaker user.id ou email en prod si l'edge function loggue)
  - [ ] 2.8 Logger : `Logger(subsystem: "com.sopddl.coachingsage", category: "service")`.

- [ ] **Task 3** : `AccountViewModel` (AC: #5)
  - [ ] 3.1 Créer `CoachingSage/ViewModels/AccountViewModel.swift` — port direct de `GardenSage/Views/ViewModels/AccountViewModel.swift`
  - [ ] 3.2 `@Observable`, `var deleteAccountState: ViewState<Void> = .idle`
  - [ ] 3.3 `@MainActor func deleteAccount() async` : transitions `.loading` → `.success(())` ou `.error(AppError)`
  - [ ] 3.4 Pas de propriété `privacyState` pour l'instant (couplé Epic 2 onboarding)

- [ ] **Task 4** : `DeleteAccountView` SwiftUI (AC: #1, #2, #5)
  - [ ] 4.1 Créer `CoachingSage/Views/Screens/DeleteAccountView.swift` — port adapté palette de `GardenSage/Views/Screens/Profile/DeleteAccountView.swift`
  - [ ] 4.2 Remplacer les couleurs `gardenError` par `coachingError` (créer la couleur dans `Color+Tokens` si absente — vérifier d'abord) ; `gardenH1`/`gardenBody` par `coachingDisplay`/`coachingBody`
  - [ ] 4.3 Utiliser `confirmationDialog` natif iOS avec rôles `.destructive` / `.cancel`
  - [ ] 4.4 Style bouton : créer `DangerButtonStyle` dans `Utilities/ViewModifiers/` (ou réutiliser `PrimaryButtonStyle` avec une teinte rouge si la simplicité prime — proposer la version la plus minimale)
  - [ ] 4.5 Gérer les 3 états visuels : `.idle` (bouton actif), `.loading` (ProgressView + bouton disabled), `.error` (message + bouton actif pour retry)

- [ ] **Task 5** : Intégration dans `MainTabView` + `ProfileView` + `AppDependencies` (AC: #1)
  - [ ] 5.0 ⚠️ **P0 du review** : actuellement `ProfileView` n'est PAS dans un `NavigationStack` (vérifié). Modifier `Views/Screens/MainTabView.swift` : wrapper l'instance de `ProfileView` (4ème onglet) dans un `NavigationStack { ProfileView() }`. **Tester non-régression** sur les 3 autres onglets pour vérifier qu'aucun ne perd sa nav (les 3 autres restent sans NavigationStack pour l'instant — règle Apple : un onglet peut avoir sa propre stack indépendante).
  - [ ] 5.1 Étendre `AppDependencies` avec `let accountService: any AccountServiceProtocol` + `AppDependencies.live()` qui le construit avec `coreProfileRepository` et `authService` injectés.
  - [ ] 5.2 Modifier `Views/Screens/ProfileView.swift` : ajouter une section « Zone dangereuse » sous le bouton Déconnexion existant (séparateur visuel + titre `profile.section.dangerZone` + `NavigationLink(destination: DeleteAccountView())`).
  - [ ] 5.3 Vérifier au lancement (Cmd+R) que la nav vers `DeleteAccountView` fonctionne, que le bouton retour iOS marche, que le titre de la nav est bien localisé.

- [ ] **Task 6** : Localisation FR + EN (AC: #8)
  - [ ] 6.1 Ajouter dans `CoachingSage/Resources/Localizable.xcstrings` (⚠️ grep + Edit ciblé, ne PAS lire le fichier en entier) :
    - `account.delete.title` — FR : « Supprimer mon compte » / EN : « Delete my account »
    - `account.delete.heading` — FR : « Action irréversible » / EN : « Irreversible action »
    - `account.delete.description` — FR : « Cette action supprimera définitivement votre compte et toutes vos données. La purge définitive est effectuée sous 30 jours conformément au RGPD. » / EN : « This permanently deletes your account and all your data. Final purge happens within 30 days as required by GDPR. »
    - `account.delete.button` — FR : « Supprimer mon compte » / EN : « Delete my account »
    - `account.delete.confirm.title` — FR : « Confirmer la suppression ? » / EN : « Confirm deletion? »
    - `account.delete.confirm.message` — FR : « Cette action est irréversible. Toutes vos données seront supprimées sous 30 jours. » / EN : « This cannot be undone. All your data will be deleted within 30 days. »
    - `account.delete.confirm.action` — FR : « Supprimer définitivement » / EN : « Delete permanently »
    - `account.delete.confirm.cancel` — FR : « Annuler » / EN : « Cancel »
    - `account.delete.inProgress` — FR : « Suppression en cours… » / EN : « Deleting… »
    - `account.delete.error.unavailable.title` — FR : « Service indisponible » / EN : « Service unavailable »
    - `account.delete.error.unavailable.description` — FR : « Réessayez dans quelques instants. » / EN : « Try again in a moment. »
    - `profile.section.dangerZone` — FR : « Zone dangereuse » / EN : « Danger zone »
  - [ ] 6.2 Vérifier que toutes les clés sont en `String(localized:)` ou `Text("key")` (jamais hardcodé) — règle `lessons_localisation`

- [ ] **Task 7** : Tests unitaires (AC: #5, #9)
  - [ ] 7.1 `CoachingSageTests/Mocks/MockAccountService.swift` — port de `GardenSage/GardenSageTests/Mocks/MockAccountService.swift`.
  - [ ] 7.2 `CoachingSageTests/Services/AccountServiceTests.swift` :
    - `deleteAccount_orchestrates_softDelete_then_deleteAuthUser_then_signOut` (vérifie l'ordre via call counters sur les mocks)
    - `deleteAccount_when_no_localProfile_skips_softDelete_but_still_calls_deleteAuthUser_and_signOut`
    - `deleteAccount_propagates_signOut_error` (suppression Supabase OK mais signOut KO → user voit l'erreur, pas de redirection silencieuse)
    - ⚠️ **`deleteAccount_throws_on_edgeFunction_HTTP500`** : si `deleteAuthUser` reçoit 500, throw → ViewModel passe en `.error` → AC5 respecté. **C'est le test critique du review** (P1.9).
    - `deleteAccount_throws_on_softDelete_failure` (si softDelete remote échoue, ne PAS appeler deleteAuthUser : on perd la trace de sécu)
    - `deleteAccount_idempotent_on_retry` : appel 1 = success ; après reset des mocks (sauf marquer le profil déjà soft-deleted), appel 2 = success aussi (ne throw pas sur is_soft_deleted=true qui était déjà la cible).
  - [ ] 7.3 `CoachingSageTests/ViewModels/AccountViewModelTests.swift` :
    - `deleteAccount_success_transitions_idle_loading_success`
    - `deleteAccount_failure_transitions_idle_loading_error_AppError`
  - [ ] 7.4 Lancer la non-régression (règle `feedback_tests_non_regression`) :
    - login email existant fonctionne toujours (Story 1.1b)
    - signOut existant fonctionne toujours (Story 1.2 placeholder)
    - sync banner fonctionne toujours (Story 1.3)
    - le toggle `isAuthenticated` réagit bien sur `.userDeleted` (test manuel sur simu via Cmd+R suffit, pas d'UI test)
    - les 3 autres onglets de `MainTabView` n'ont pas régressé après l'ajout du `NavigationStack` autour de Profil (Task 5.0)

## Dev Notes

### Décision archi : soft + hard delete (pattern ceinture-bretelles)

**Choix retenu (2026-04-25)** : même pattern que GardenSage, adapté au scope V1 CS.

| Étape | Acteur | Effet |
|---|---|---|
| 1 | Client `AccountService.deleteAccount()` | `softDelete()` profile → `core_profiles.is_soft_deleted=true` côté Supabase **+ trace SwiftData locale** |
| 2 | Edge function `delete-account` (`service_role`) | **Hard-delete** atomique : `delete from core_profiles` + `auth.admin.deleteUser` |
| 3 | Client | `signOut()` → `authStateChanges` reçoit `.userDeleted` → `CoachingSageApp` bascule sur `AuthView` |
| 4 (filet) | `pg_cron` j+30 | Si étape 2 a échoué, purge les `core_profiles.is_soft_deleted=true` qui traînent |

**Pourquoi pas du soft-delete pur** : un user qui s'est supprimé pourrait se reconnecter pendant 30j et voir un profil vide / état UX incohérent. Le hard-delete `auth.users` immédiat coupe cette voie. RGPD Art. 17 garanti par le hard immédiat (mieux que les 30j légaux), avec le filet 30j en cas d'échec.

**Pourquoi pas du hard-delete pur** (sans softDelete client) : si l'edge function plante, on a aucune trace côté Supabase → user fantôme dans `auth.users` que personne ne sait où purger. Le softDelete préalable garantit que le pg_cron 30j prendra le relais.

### Patterns architecture à suivre

- **Pas de SageCore SPM côté CoachingSage** — copies locales uniquement, même pattern que `AuthService.swift` qui a la mention `[COPIE IDENTIQUE]` en haut. Marquer le nouveau `AccountService.swift` avec ce header pour signaler la synchronisation manuelle avec GardenSage/TailorSage.
- **Soft-delete déjà infra-ready** : la migration `001_initial_schema.sql` ligne 28-33 déclare `is_soft_deleted` + `deleted_at` + index, lignes 71-79 le job `pg_cron` purge 30j. **Rien à toucher côté DB** pour cette story.
- **Redirect après suppression** : le `for await stateChange in authStateChanges` dans `CoachingSageApp.swift:107` capture `.signedOut` ET `.userDeleted` → bascule `isAuthenticated = false` → SwiftUI affiche `AuthView`. Pas de code de redirection à écrire.
- **Edge function** : besoin du `service_role` Supabase pour `admin.deleteUser`. Le client envoie son JWT en header `Authorization: Bearer <jwt>`, l'edge function vérifie le JWT pour extraire le `userId`, puis utilise `service_role` pour la suppression. Voir le code existant `GardenSage/supabase/functions/delete-account/index.ts` (à lire comme référence avant de porter).

### Source tree à toucher

| Fichier | Action |
|---|---|
| `CoachingSage/Services/AccountService.swift` | Créer (port simplifié GardenSage) |
| `CoachingSage/ViewModels/AccountViewModel.swift` | Créer (port direct GardenSage) |
| `CoachingSage/Views/Screens/DeleteAccountView.swift` | Créer (port adapté palette) |
| `CoachingSage/Views/Screens/ProfileView.swift` | Modifier (ajout NavigationLink) |
| `CoachingSage/App/AppDependencies.swift` | Modifier (injection accountService) |
| `CoachingSage/Resources/Localizable.xcstrings` | ⚠️ Edit ciblé (grep + Edit, jamais lire entier) |
| `CoachingSage/Utilities/ViewModifiers/DangerButtonStyle.swift` | Créer si nécessaire (ou inliner dans DeleteAccountView) |
| `CoachingSage/supabase/functions/delete-account/index.ts` | Créer (port GardenSage) |
| `CoachingSageTests/Mocks/MockAccountService.swift` | Créer |
| `CoachingSageTests/Services/AccountServiceTests.swift` | Créer |
| `CoachingSageTests/ViewModels/AccountViewModelTests.swift` | Créer |

### Pièges à éviter (lessons learned applicables)

- ⚠️ **`lessons_auth_purge_clean_install`** : ne PAS appeler `purgeUserData()` côté CoachingSage (pas d'équivalent existant, et le code GardenSage avait causé un wipe involontaire au premier login). Notre flux est différent : on soft-delete le profil distant, le user signOut, puis sur le prochain login d'un autre user le store SwiftData est filtré par `cleanupOrphanProfiles()` qui existe déjà dans `DefaultCoreProfileRepository.swift:37`.
- ⚠️ **Idempotence** : si l'utilisateur lance la suppression, perd le réseau au milieu, et retap → `softDelete` doit pouvoir être rejoué (le profil est déjà flagué, l'UPDATE Supabase est idempotent grâce à `is_soft_deleted=true` qui est déjà la valeur cible). L'edge function doit retourner 200 même si `auth.admin.deleteUser` retourne « not found » (Task 1.5). Couvrir par test 7.2 dédié.
- ⚠️ **Race condition `authStateChanges` vs UI** : le `CoachingSageApp.swift:104-117` peut bascule `isAuthenticated=false` AVANT que l'`AccountViewModel` ait fini son `await`. Si erreur, le VM est dealloc → message d'erreur jamais montré. **Mitigation** : trigger redirect uniquement après `.success(())` côté VM ; en cas d'`.error`, le VM reste vivant car l'`authStateChanges` n'a pas encore reçu `.userDeleted` (signOut n'a pas été appelé). Comportement OK donc, mais à valider en non-régression manuelle.
- ⚠️ **Pas de UI test pour cette story** — règle `feedback_tests_non_regression` : test manuel ciblé Cmd+R + unit tests, pas de cérémonie.
- ⚠️ **Dépendance `coachingError`** : si la couleur n'existe pas dans la palette, l'ajouter dans `Color+Tokens` mais SANS modifier la palette globale (juste un alias `coachingError` qui pointe vers `Color.red` ou un rouge tokenisé conforme au design Léon).
- ⚠️ **Logs JWT** : ne pas logger le body de réponse de l'edge function en prod (peut leaker user.id ou email si l'edge function les inclut). Wrap les `Logger.warning("delete-account HTTP \(code): \(body)")` dans `#if DEBUG`.

### Hors scope V1 (à tracker pour Epic ultérieur)

- **Audit log RGPD** : aucune trace côté Supabase de l'event « user X a demandé suppression à T ». Pour les litiges RGPD réels, recommandé. À ajouter avant ouverture beta publique.
- **Email de confirmation post-suppression** : standard du secteur (Apple, Google envoient un mail). Hors scope V1, à tracker.
- **Export RGPD préalable (Art. 20 portabilité)** : si user veut récupérer ses données avant suppression, impossible. À tracker pour Epic 2+.
- **Notification système iOS de fin de suppression** : pas demandé par l'AC, hors scope.

### Standards de tests

- XCTest unit tests, pas de `sleep()` (utiliser `await` natif)
- Mocks via protocol — `MockAccountService`, déjà des `MockAuthService` et `MockCoreProfileRepository` réutilisables (`CoachingSageTests/Mocks/`)
- Pas d'appel réseau réel : guard `IS_UI_TESTING` côté impl (déjà géré par le pattern `DefaultCoreProfileRepository.save()`)
- Locale EN dans le test runner (règle perso `feedback_test_localisation_anglais` — rappel à la fin de l'epic)

### Références

- **Epic source** : `GardenSage/_bmad-output/planning-artifacts/epics-CoachingSage.md` lignes 427-441 (Story 1.4)
- **PRD FR54** : `GardenSage/_bmad-output/planning-artifacts/prd-CoachingSage.md:516`
- **PRD NFR RGPD** : `GardenSage/_bmad-output/planning-artifacts/prd-CoachingSage.md:546-547`
- **Architecture soft-delete** : `GardenSage/_bmad-output/planning-artifacts/architecture-CoachingSage.md:201` (« Toutes entites : soft delete + pg_cron purge 30j »)
- **Architecture pg_cron** : `GardenSage/_bmad-output/planning-artifacts/architecture-CoachingSage.md:512`
- **Migration soft-delete CoachingSage** : `CoachingSage/supabase/migrations/001_initial_schema.sql:28-33` (colonnes) + `:71-79` (job pg_cron)
- **Repository soft-delete existant** : `CoachingSage/Repositories/Implementations/DefaultCoreProfileRepository.swift:123-145` (méthode `softDelete()`)
- **Auth signOut existant** : `CoachingSage/Services/AuthService.swift:58-64`
- **Trigger redirect post-signOut** : `CoachingSage/App/CoachingSageApp.swift:104-117` (boucle `authStateChanges`)
- **Précédent GardenSage à porter** :
  - `GardenSage/Services/AccountService.swift` (137 lignes — simplifier en retirant les repos plants/tasks/garden)
  - `GardenSage/Views/ViewModels/AccountViewModel.swift` (42 lignes — port direct sans `privacyState`)
  - `GardenSage/Views/Screens/Profile/DeleteAccountView.swift` (94 lignes — adapter palette)
  - `GardenSage/supabase/functions/delete-account/index.ts` (port direct côté CS)
  - `GardenSage/GardenSageTests/Mocks/MockAccountService.swift` (22 lignes)
  - `GardenSage/GardenSageTests/ViewModels/AccountViewModelTests.swift` (105 lignes)

### Project Structure Notes

- Alignement avec la structure existante : `Services/` pour `AccountService`, `ViewModels/` pour `AccountViewModel` (à la racine, comme `AuthViewModel.swift` actuellement), `Views/Screens/` pour `DeleteAccountView` (à plat, pas de sous-dossier `Profile/` comme GardenSage car la vue Profil n'a qu'un seul écran ici).
- ⚠️ **Variance volontaire vs GardenSage** : pas de sous-dossier `Profile/`, pas de `privacyState` dans le ViewModel (Story Epic 2.x ajoutera le toggle analytics consent). À documenter dans le commit message.
- Aucune nouvelle dépendance SPM. Aucun nouveau modèle SwiftData.

## Review Tracking — 2026-04-26 (review post-implem)

Review adversarial par sous-agent sur le code implémenté. **1 P0 + 4 P1 + 5 P2** identifiés, P0 + P1 traités le 2026-04-26 (mêmes commits).

**P0 traité** :
- ✅ P0.1 : edge function ne checkait pas l'erreur de `delete from core_profiles` → ajout du check + return 500 si KO. Plus de risque "auth.users purgé / core_profiles orphelin".

**P1 traités** :
- ✅ P1.1 : test `testDeleteAccountRetryAfterSignOutFailureSucceeds` ajouté côté `AccountViewModelTests` (scénario spec Task 7.2 ligne 101).
- ✅ P1.2 : `testDeleteAccountThrowsOnSoftDeleteFailure` valide maintenant le type `AppError.network` propagé tel quel.
- ✅ P1.3 : split signOut hors du service. `AccountService.deleteAccount()` fait softDelete + deleteAuthUser uniquement. `AccountViewModel` met `.success(())` puis appelle `authService.signOut()` best-effort (`try?`). Tests `testDeleteAccountSetsSuccessBeforeCallingSignOut` + `testDeleteAccountSucceedsEvenIfSignOutFails` ajoutés.
- ✅ P1.4 : `MockCoreProfileRepository.softDelete()` mute `profile.isSoftDeleted = true` + `deletedAt` + invalide `stubbedProfile` pour refléter la réalité métier.

**P2 (acceptés, hors scope V1)** :
- 📌 P2.1 `ProfileView.navigationTitle` manquant (cosmétique iOS).
- 📌 P2.2 bouton signOut existant swallow l'erreur (pré-existant Story 1.2, à tracker Epic 2+).
- 📌 P2.3 `confirmationDialog` race tap-spam (négligeable).
- 📌 P2.4 `MockAccountService` sans compteur Int.
- 📌 P2.5 wording 12 vs 13 clés dans completion notes (corrigé : 13 = 12 `account.delete.*` + 1 `profile.section.dangerZone`).

## Review Tracking — 2026-04-25 (review pré-implem)

Review adversarial par sous-agent `Plan` sur le spec initial. **3 P0 + 7 P1 + 6 P2** identifiés.

**P0 (tous traités dans cette révision du spec)** :
- ✅ P0.1 : `ProfileView` pas dans `NavigationStack` → Task 5.0 ajoutée (wrap côté `MainTabView`)
- ✅ P0.2 : Edge function GardenSage cascade-delete 9 tables qui n'existent pas en CS → Task 1.2 précise les drops + scope minimal core_profiles + auth.users
- ✅ P0.3 : Contradiction soft vs hard delete → Section « Décision archi » clarifie le pattern ceinture-bretelles, AC6 reformulé en deux mécanismes complémentaires

**P1 traités** :
- ✅ P1.4 Idempotence si signOut échoue → couvert AC5 + Task 7.2 dédié
- ✅ P1.5 Race condition authStateChanges vs UI → Note explicative dans « Pièges à éviter »
- ✅ P1.7 Fuite JWT en logs → Task 2.7 logs en `#if DEBUG`
- ✅ P1.9 ⚠️ critique : `deleteAuthUser` doit throw sur HTTP≠200 → Task 2.5 + test 7.2 dédié `deleteAccount_throws_on_edgeFunction_HTTP500`
- ✅ P1.10 Guard `IS_UI_TESTING` absent dans `softDelete` repo → AC7 + Task 7.4 (action requise dans la repo, pas dans `AccountService`)
- 📌 P1.6 `cleanupOrphanProfiles` ignore les soft-deleted (storage local) → assumé, risque mineur, non bloquant V1
- 📌 P1.8 Naming i18n incohérent (4 niveaux vs 2) → assumé `account.delete.*` standardisé V1+ (cohérent avec dev futur)

**P2 (assumés hors scope V1, trackés en Dev Notes section « Hors scope V1 »)** :
- 📌 P2.11 audit log Supabase, P2.12 email confirmation, P2.13 export RGPD préalable, P2.16 lessons SwiftData schema reset
- ✅ P2.14 body `DeleteAccountRequest` inutile → Task 2.7 « pas de body JSON »
- ✅ P2.15 timeout HTTP par défaut 60s → Task 2.5 `request.timeoutInterval = 15`

## Dev Agent Record

### Agent Model Used

Claude Opus 4.7 (1M context)

### Debug Log References

- 2026-04-25 : implem branche `epic-1/story-1.4-account-deletion` après merge story 1.3 sur main. Aucun build lancé par l'agent (règle Sophie : Cmd+B/Cmd+U manuel).
- 2026-04-26 : review adversarial post-implem (sous-agent général) → 1 P0 + 4 P1 + 5 P2. P0 + P1 fixés en 30 min sur la même branche.

### Completion Notes List

- ✅ Edge function `delete-account` portée et simplifiée (drop des opérations garden_*) — scope minimal `core_profiles` + `auth.users`. Idempotence "user_not_found" ⇒ 200.
- ✅ `AccountService.swift` : ceinture-bretelles softDelete → deleteAuthUser (throws sur HTTP≠200) → signOut. Closure `deleteAuthUser` injectable pour testabilité (override en tests, default = call HTTP). Timeout 15s. Logs body en `#if DEBUG` uniquement.
- ✅ `AccountViewModel.swift` : `@Observable`, `deleteAccountState: ViewState<Void>`, transitions idle→loading→success/error.
- ✅ `DeleteAccountView.swift` : `confirmationDialog` natif, palette CoachingSage (`coachingError`, `coachingTextPrimary`), 3 états visuels (idle/loading/error). `accessibilityIdentifier("delete_account_button")`.
- ✅ `DangerButtonStyle.swift` créé dans `Utilities/ViewModifiers/` (variant rouge de PrimaryButtonStyle, hauteur 52pt).
- ✅ `MainTabView` : `ProfileView` wrappée dans `NavigationStack` (P0 du review). 3 autres onglets inchangés (chacun a sa stack indépendante).
- ✅ `ProfileView` : section "Zone dangereuse" + `NavigationLink → DeleteAccountView` + `accessibilityIdentifier("delete_account_link")`.
- ✅ `AppDependencies` : injection `accountService: AccountServiceProtocol` (live = `AccountService` avec deps déjà construites).
- ✅ `DefaultCoreProfileRepository.softDelete()` : ajout du guard `IS_UI_TESTING` avant l'appel Supabase (AC7).
- ✅ Localizable.xcstrings : 12 clés `account.delete.*` + 1 clé `profile.section.dangerZone` (FR + EN). Edit ciblé via grep, jamais lu en entier.
- ✅ `MockAccountService.swift`, `MockCoreProfileRepository.softDeleteHook` + `softDeleteShouldThrow`, `MockAuthService.signOutHook` ajoutés.
- ✅ `AccountServiceTests` (6 tests) : orchestration ordre softDelete→deleteAuthUser→signOut, no-localProfile, HTTP500 throws, signOutError propagation, softDeleteFailure ne déclenche PAS deleteAuthUser, idempotence retry.
- ✅ `AccountViewModelTests` (2 tests) : transitions success / error AppError.

### File List

**Créés :**
- `CoachingSage/supabase/functions/delete-account/index.ts`
- `CoachingSage/Services/AccountService.swift`
- `CoachingSage/ViewModels/AccountViewModel.swift`
- `CoachingSage/Views/Screens/DeleteAccountView.swift`
- `CoachingSage/Utilities/ViewModifiers/DangerButtonStyle.swift`
- `CoachingSage/CoachingSageTests/Mocks/MockAccountService.swift`
- `CoachingSage/CoachingSageTests/Services/AccountServiceTests.swift`
- `CoachingSage/CoachingSageTests/ViewModels/AccountViewModelTests.swift`

**Modifiés :**
- `CoachingSage/App/AppDependencies.swift` — injection `accountService`
- `CoachingSage/Repositories/Implementations/DefaultCoreProfileRepository.swift` — guard `IS_UI_TESTING` dans `softDelete()`
- `CoachingSage/Views/Screens/MainTabView.swift` — `NavigationStack` autour de `ProfileView`
- `CoachingSage/Views/Screens/ProfileView.swift` — section "Zone dangereuse" + `NavigationLink`
- `CoachingSage/Resources/Localizable.xcstrings` — 13 clés (account.delete.* + profile.section.dangerZone, FR+EN)
- `CoachingSage/CoachingSageTests/Mocks/MockCoreProfileRepository.swift` — hooks softDelete pour tests
- `CoachingSage/CoachingSageTests/Mocks/MockAuthService.swift` — hook signOut pour tests

### Reste à faire avant `done`

1. **Sophie : ajouter les 8 nouveaux fichiers Swift au `.xcodeproj`** (Xcode > Add Files, ou rerun `xcodegen generate` si project.yml). Idem pour `index.ts` côté Supabase.
2. **Sophie : Cmd+B** — vérifier que ça compile sans erreur (les diagnostics SourceKit "No such module 'SageCore'" ne se résolvent qu'après ajout au target).
3. **Sophie : Cmd+U** — lancer les tests unitaires CoachingSageTests (6 + 2 nouveaux).
4. **Sophie : déploiement edge function** sur projet `coachingsage-dev` via Dashboard Supabase (pas de CLI auto). Vérifier secrets `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY`.
5. **Test manuel Cmd+R** :
    - Login `test@test.com` (Story 1.1b.6 dev login).
    - Onglet Profil → tap "Zone dangereuse" → tap "Supprimer mon compte" → confirm dialog → "Supprimer définitivement".
    - Vérifier loading, puis bascule sur AuthView, puis tenter une reconnexion → 401 attendu (`auth.users` purgé).
    - Tester aussi le retry après une coupure réseau simulée (avion OFF/ON).
    - Vérifier non-régression : 3 autres onglets de MainTabView, login existant, signOut, sync banner Story 1.3.
6. **Test localisation EN** (à faire en fin d'epic 1, règle `feedback_test_localisation_anglais`).
7. **Review adversarial sous-agent** sur le code avant `done` (règle `feedback_review_obligatoire_sous_agent`).
