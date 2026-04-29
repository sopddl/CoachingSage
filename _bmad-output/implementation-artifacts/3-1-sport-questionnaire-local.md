# Story 3.1 : SportQuestionnaire local

Status: in-progress

<!-- Note: Validation est optionnelle. Lance `validate-create-story` pour un quality check avant `dev-story`. -->

## Story

**As a** utilisateur CoachingSage qui demande un programme dans un sport pour la première fois,
**I want** répondre rapidement à 4-5 questions ciblées par mon sport via une interface qui ressemble à une vraie conversation avec Léon,
**so that** Léon ait le contexte nécessaire pour adapter le programme (Story 3.3) sans que ce soit un formulaire pénible — et tout ça sans aucun appel réseau ni token consommé.

## Acceptance Criteria

1. **AC1 — Entry point « Demander un programme » sur l'onglet Séance** : pour chaque sport actif du `coachingProfile.activeSports`, afficher une **capsule cliquable** « Demander un programme [sport] » (cohérent palette Story 1.2). Au tap :
   - Si **aucun `CoachingSportProfile` n'existe** pour ce (user × sport) → ouvrir `SportQuestionnaireView` en sheet plein écran → flow questionnaire complet.
   - Si **un `CoachingSportProfile` existe déjà** → afficher placeholder « Programme déjà créé — Story 3.2 à venir » + bouton **« Refaire le questionnaire »** bien visible (force re-présentation, l'upsert gère l'écrasement).
   - Pour les **9 sports non livrés** V1 (cf. AC4) → capsule `.disabled(true)` + petit badge « Bientôt ».
   - ⚠️ **`SeanceView` observe `appState.coachingProfile` (`@Observable`)** — pas de copie locale (review P1-1, lesson `lessons_swiftdata #6`). À chaque `.onAppear`, refetch silencieux pour cohérence multi-device.
   - ⚠️ **Si `coachingProfile.created_at > 90 jours`** → afficher en plus une mention « Profil créé il y a plus de 3 mois — refaire le questionnaire ? » (review P1-13). V1 : juste un texte gris sous le bouton, pas de modal.

2. **AC2 — UI chat indistinguable d'une vraie conversation Léon** : `SportQuestionnaireView` affiche une `ScrollView` avec :
   - Avatar Léon (cercle 40pt). **Vérifier en début Task 6** si asset `LeonAvatar` ou `leon-sifflet-v4` existe dans `Assets.xcassets`. Sinon fallback : cercle `Color.accentColor` (bleu marine) + SF Symbol `figure.run.circle.fill` blanc en surimpression (review P2-4).
   - Bulles de chat : **gauche bleu clair pour Léon, droite accent bleu marine pour user** (palette Story 1.2 `Color+Sage`).
   - **Typing indicator** (3 dots animés opacity loop) affiché 600-1200ms aléatoire avant chaque question Léon → simule une réflexion. ⚠️ **Désactivable via `TypingDelayProvider` injecté** (review P1-5) — pas d'env var inline, abstraction propre pour tests.
   - Bouton retour iOS standard (haut gauche) avec `confirmationDialog` « Quitter le questionnaire ? Tes réponses seront perdues. ».
   - Auto-scroll vers le bas à chaque nouveau message. ⚠️ **Utiliser `VStack` (PAS `LazyVStack`)** (review P1-4) : la conversation fait ~13 bulles max, `LazyVStack` introduit un bug d'auto-scroll iOS classique (`scrollTo` cible un `id` non encore matérialisé).
   - **Pas d'input clavier** sauf Q6 (1 champ texte libre optionnel). Réponses via boutons capsule (single choice) ou checkboxes + bouton « Confirmer » (multi).
   - Q6 (`TextField` `lineLimit(2...4)`) : ⚠️ **`.scrollDismissesKeyboard(.interactively)` + `.safeAreaInset(edge: .bottom)`** (review P1-12) pour éviter le jump bug clavier iOS classique des chats SwiftUI.

3. **AC3 — `SportQuestionnaireEngine` 100% local, types brut-string pas LocalizedStringKey** :
   - Protocol Swift `SportQuestionnaire` :
     ```swift
     protocol SportQuestionnaire {
         var sportCode: String { get }              // "running", "musculation", etc.
         var version: String { get }                // "running_v1"
         var firstQuestion: QuestionnaireQuestion { get }
         func nextQuestion(
             after: QuestionId,
             answer: AnswerValue,
             accumulated: [QuestionId: AnswerValue]
         ) -> QuestionnaireQuestion?
         func buildProfile(
             answers: [QuestionId: AnswerValue],
             freeTextNotes: String?,
             history: [ConversationEntry],
             userId: UUID,
             medicalClearanceAcknowledged: Bool
         ) -> CoachingSportProfileDraft
     }
     ```
   - **`textKey: String` (PAS `LocalizedStringKey`)** dans `QuestionnaireQuestion` et `QuestionOption` (review P0-1). `LocalizedStringKey` n'est pas `Codable` et n'expose pas sa clé brute publiquement. Single source of truth = `String` raw, instancié `Text(LocalizedStringKey(question.textKey))` côté View.
   - Chaque sport a son propre fichier (`RunningQuestionnaire.swift`, etc.) implémentant le protocol.
   - **Branchements conditionnels supportés** : `nextQuestion` peut sauter une question selon les réponses précédentes (ex: si niveau = beginner, skip Q4 records/contraintes).
   - **Aucun appel réseau** : tout en mémoire, instantané au tap.
   - Engine `SportQuestionnaireEngine` = ViewModel `@Observable` qui orchestre l'état.

4. **AC4 — Sports livrés V1 : Running uniquement** ✅ TRANCHÉ
   - **Décision** : Running seul comme pilote complet (5 questions + branchement + tests E2E + traductions FR/EN).
   - **Justification** : valider d'abord (a) le format JSONB exploitable Story 3.3, (b) le pattern protocol, (c) la formulation EU MDR-safe, (d) l'UX chat. Les 9 autres sports = stories de suivi (~1-2j chacun) après validation Story 3.3.
   - Pour les 9 autres sports (Musculation, Natation, Triathlon, Tennis, Yoga, Vélo, Marche, Crossfit, Boxe) : capsule `.disabled(true)` + badge « Bientôt » sur SeanceView.

5. **AC5 — `RunningQuestionnaire` (sport pilote, 6 questions dont 1 conditionnelle + 1 optionnelle)** :
   - **Intro Léon (avant Q1)** : « Salut ! 5 questions rapides pour te proposer un programme qui te corresponde. » ⚠️ **Reformulé** (review P0-5) : éviter « adapté » qui peut s'enchaîner avec un terme médical.
   - **Bulle conditionnelle medical clearance** (entre intro et Q1) **si `coachingProfile.requiresMedicalClearance == true`** (review P0-6) : « Avant qu'on commence : tu m'as indiqué qu'une consultation médicale serait pertinente. Ton programme sera proposé en intensité douce. » Stocker `medical_clearance_acknowledged = true` dans le profil sport saved.
   - **Q1** « Quel est ton niveau actuel en course à pied ? » — single choice 4 options : `beginner`, `recreational`, `regular`, `competitive`.
   - **Q2** « Quel est ton objectif principal ? » — single choice 5 options : `5k`, `10k`, `half_marathon`, `marathon`, `wellness`.
   - **Q3** « Combien de fois par semaine peux-tu courir ? » — single choice 3 options : `2`, `3`, `4_or_more`. Mappé : `frequency_per_week = 2/3/4` + `frequency_label = "2"/"3"/"4_or_more"` (review P1-3 — préserve l'intention "ou plus").
   - **Q4 (conditionnelle)** « As-tu des contraintes physiques actuelles ? » — multi choice : `knee`, `back`, `ankle`, `shin`, `none`. ⚠️ **Skippée si Q1 = beginner** (cohérence Léon Story 3.3 : pas pertinent au démarrage). ⚠️ **Formulation neutre, pas de « souffres-tu de... »** (mémoire `epic3_leon_legal_constraints`). Si Q4 skippée, `conversation_history_json` enregistre `{ "question_id": "q4_constraints", "skipped": true, "skip_reason": "level_beginner" }` (review P2-6). Si l'user sélectionne `none` seul, stocker `["none"]` explicit en DB (PAS `[]` — review P1-10, préserve l'intention « pas de contrainte » vs « question pas posée »).
   - **Q5** « Quel équipement spécifique as-tu ? » — multi choice : `gps_watch`, `heart_rate_monitor`, `treadmill_access`, `none`. Même règle `["none"]` explicit que Q4.
   - **Q6 (texte libre, optionnelle)** « Y a-t-il quelque chose d'important à préciser à Léon ? » — `TextField`, max 200 chars (validé client + CHECK SQL côté DB), bouton « Continuer sans note » pour skip.
   - **Completion Léon** : « Merci ! J'ai tout ce qu'il faut. Voyons ton programme... »

6. **AC6 — Persistance `CoachingSportProfile` Supabase via migration 003** :
   - **Migration 003** déjà créée dans `supabase/migrations/003_coaching_sport_profiles.sql` (cohérent layout 001/002 lowercase `supabase`).
   - **Schéma table avec corrections review** :
     - Colonnes du SoT : `id`, `user_id`, `sport`, `level`, `goals_json`, `equipment_json`, `constraints_json`, `records_json` (nullable), `frequency_per_week`, `session_duration_minutes`, `free_text_notes`, `conversation_history_json`, `created_at`, `last_updated_at`.
     - **Colonnes ajoutées via review** :
       - `frequency_label TEXT NOT NULL` — préserve "4_or_more" (review P1-3).
       - `medical_clearance_acknowledged BOOLEAN NOT NULL DEFAULT FALSE` — snapshot au save (review P0-6, prépare Story 3.3).
       - `questionnaire_version TEXT NOT NULL DEFAULT 'v1'` — marker pour migrations futures (review P2-7).
     - **CHECK constraints** :
       - `sport IN ('running','cycling','swimming','triathlon','strengthTraining','yoga','hiit','hiking','tennis','football')` — codes alignés avec enum **`SportCode`** existant (`Models/CoachingProfile.swift` Story 2.2) pour cohérence cross-table avec `active_sports[]` (review P1-2).
       - `level IN ('beginner','recreational','regular','competitive')` (review P1-2).
       - `length(free_text_notes) <= 200` (cohérence Q6 client-side).
       - `frequency_per_week BETWEEN 1 AND 14` (sanity).
     - `UNIQUE (user_id, sport)` — 1 profil par sport par user, upsert ON CONFLICT.
   - **RLS avec cast UUID explicite** (review P0-3, lesson `lessons_supabase #8`) : `auth.uid()::uuid = user_id` dans toutes les policies (SELECT/INSERT/UPDATE/DELETE).
   - **Trigger auto-update `last_updated_at`** (review P1-9) : fonction `update_last_updated_at_column()` avec `SET search_path = public` (lesson `lessons_supabase #2`).
   - ⚠️ **Vérifier le nom des colonnes en base après déploiement** (lesson `lessons_supabase #5`) : `SELECT column_name FROM information_schema.columns WHERE table_name = 'coaching_sport_profiles'`.
   - **SwiftData @Model + Supabase upsert** ✏️ RÉVISÉ 2026-04-29 : pattern identique à `CoachingProfile` Story 2.2 — `@Model` SwiftData PLUS upsert Supabase, hydrate-on-miss au fetch. Nouveau `SchemaV3` (ajout du model, lightweight migration depuis V2). Cf. décision archi révisée Dev Notes.
   - **Repository** : protocol + `DefaultCoachingSportProfileRepository` (impl pattern `Default*` + hydrate-on-miss) + `MockCoachingSportProfileRepository`.
   - **DTOs typés Codable** (review P0-2) :
     - `GoalsPayload { primary: String }` → JSONB `{"primary":"5k"}`
     - `equipment_json` / `constraints_json` → `[String]` natif (Postgres JSONB array)
     - `records_json` → struct dédiée (V2)
     - `conversation_history_json` → `[ConversationEntry]` (struct typée Codable)
     - **Aucun `[String: Any]` ou `AnyCodable`** dans les DTOs (lesson `lessons_supabase #3`).
   - **Upsert** (review P0-7) : `try await client.from("coaching_sport_profiles").upsert(draft, onConflict: "user_id,sport", ignoreDuplicates: false).select().single().execute()`. Update-in-place pour préserver `id` stable (futures FK Story 3.3).
   - **UUID lowercase** (review P0-3, lesson `lessons_supabase #8`) : `userId.uuidString.lowercased()` avant insert/eq.

7. **AC7 — Multilangue extensible — règle absolue** :
   - **Toutes les questions, options et textes Léon** sont des clés `Localizable.xcstrings` :
     - Pattern : `questionnaire.{sport}.q{N}.text`, `questionnaire.{sport}.q{N}.option.{code}`, `questionnaire.{sport}.intro`.
     - Pour Running : `questionnaire.running.intro`, `questionnaire.running.q1.text`, `questionnaire.running.q1.option.beginner`, etc.
   - **Aucun switch FR/EN hardcodé** (mémoire `multilangue_extensible_regle`). Le `RunningQuestionnaire` manipule des `String` (les keys), c'est SwiftUI qui résout via `LocalizedStringKey(textKey)` + `\.locale` env injecté par `LanguageManager` (Story 2.3).
   - Ajouter une langue (allemand) → ajouter `case .german` dans `SupportedLanguage` (SageCore) + traductions xcstrings. Aucun code à toucher.
   - ⚠️ **Test localisation EN intégral obligatoire** avant `done` (lesson `lessons_localisation #3`).

8. **AC8 — Garde-fous légaux Epic 3 (préparation, pas activation V1)** :
   - Story 3.1 = **0 IA, 0 prompt système Léon** → les 4 garde-fous légaux (mémoire `epic3_leon_legal_constraints`) seront câblés Story 3.3.
   - **MAIS Story 3.1 doit déjà respecter** :
     - **Mots bannis EU MDR FR + EN** dans toutes les traductions (Task 9.4).
       - FR : `soin`, `thérapie`, `traitement`, `guérir`, `diagnostiquer`, `prévenir`, `pathologie`, `blessure`, `santé` (en positionnement principal).
       - EN (review P0-5) : `care`, `therapy`, `treatment`, `cure`, `diagnose`, `prevent`, `pathology`, `injury`, `condition`, `medical`, `health` (en positionnement principal).
     - **Formulation neutre Q4** : « As-tu des contraintes physiques actuelles ? » + zones du corps neutres (`knee`, `back`, etc.). Pas de « souffres-tu », pas de « pathologie ».
     - **Intro reformulée** (review P0-5) : « 5 questions rapides pour te proposer un programme **qui te corresponde** » (PAS « adapté »).
   - **Snapshot `medical_clearance_acknowledged`** dans le profil sport (AC6) → garantit que Story 3.3 a l'info même si l'user change `requires_medical_clearance` plus tard via Story 2.3.
   - **Note préparation Story 3.3** : Léon Story 3.3 fera **2 fetches** — `coachingProfile` (pour `parq_responses` + `requires_medical_clearance` actuels) + `coachingSportProfile` (pour sport context + snapshot acknowledged au moment du questionnaire). Le format `constraints_json = ["knee","back"]` est exploitable directement côté prompt sans transformation custom (review P1-11).

9. **AC9 — Performance, UX et résilience** :
   - Flow complet **< 60 secondes** (mesure : du tap « Demander programme » au save success Supabase). ⚠️ **Log `debugPrint("Questionnaire \(sport) duration: \(duration)s")`** dans `submit()` (review P2-5) pour monitorer en TestFlight.
   - Latence au tap option : **< 200ms** hors typing indicator simulé (transition à la question suivante).
   - **Idempotence tap option** (review P1-8) : `private var isAdvancing: Bool = false` dans le ViewModel. `answer()` abort si déjà en cours. Évite le double-tap qui sauterait Q2 visuellement.
   - **Recovery réponses si save échoue** (review P1-6) :
     - Au démarrage de `submit()` (et avant l'appel réseau), sérialiser `accumulatedAnswers` + `freeTextDraft` dans `UserDefaults` clé `pending_questionnaire_<userId>_<sport>`.
     - Au reopen du questionnaire pour le même sport sans profile saved : prompt « Reprendre ta saisie précédente ? » avec « Reprendre » / « Recommencer ».
     - Purger `UserDefaults` au save success.
   - Si save Supabase échoue (réseau, RLS) → bandeau rouge + bouton « Réessayer ». Ne PAS perdre le state local.
   - Typing indicator désactivable via `TypingDelayProvider` injecté (cf. AC2 + Task 5).

10. **AC10 — Sécurité cross-user race au `submit()`** ✨ NOUVEL AC (review P0-4) :
    - Le ViewModel capture `let capturedUserId = authService.currentUserId` au `start()`.
    - Après chaque `await` dans `submit()`, re-vérifier `authService.currentUserId == capturedUserId`. Si différent → abort save + state `.error(.userChanged)` + log incident + retour user.
    - **Test obligatoire** `testEngine_submit_abortsIfUserChanged` (mock auth qui change `currentUserId` au milieu du flow).

11. **AC11 — Tests** :
    - **Unit tests `RunningQuestionnaireTests`** (Swift Testing — `@Test`, `#expect`) :
      - `testFirstQuestion_returnsQ1Level`
      - `testNextQuestion_skipsQ4WhenBeginner` (branchement conditionnel — zone de risque #1)
      - `testNextQuestion_includesQ4WhenNotBeginner`
      - `testBuildProfile_serializesAllAnswersToTypedDTOs`
      - `testBuildProfile_freeTextNotesNilWhenEmpty`
      - `testBuildProfile_keepsExplicitNoneInArrays` (ne pas remplacer `["none"]` par `[]`)
      - `testBuildProfile_preservesFrequencyLabelFourOrMore`
      - `testConversationHistory_recordsSkippedQ4WithReason`
    - **Unit tests `SportQuestionnaireViewModelTests`** :
      - `testEngine_initialState_isFirstQuestion`
      - `testEngine_answer_advancesToNextQuestion`
      - `testEngine_completion_buildsValidProfile`
      - `testEngine_doubleTap_isIdempotent` (review P1-8)
      - `testEngine_submit_abortsIfUserChanged` (AC10 / review P0-4)
      - `testEngine_recoveryFromUserDefaults_restoresAnswers` (review P1-6)
    - **Unit tests `RunningQuestionnaireLocalizationTests`** :
      - `testAllRunningKeys_existInBothFRandEN` (lesson `lessons_localisation #4`)
      - `testRunningQuestionnaire_noBannedTerms_FR_and_EN` (review P0-5 — itère sur toutes les clés xcstrings, fail si mot banni)
    - **Repository test `CoachingSportProfileRepositoryTests`** (mock) :
      - `testSave_upsertOnConflictUserSport` (re-save même sport overwrite, pas duplicate, `last_updated_at` change, `id` stable)
      - `testFetch_returnsNilWhenNoProfile`
      - `testUUID_lowercasedBeforeInsert` (review P0-3, lesson `lessons_supabase #8`)
    - **Test integration RLS bout-en-bout** (review P1-14) — XCTSkip si pas de credentials CI :
      - `testRLS_otherUserCannotReadProfile` : 2 users via auth admin, save user1, signin user2, fetch → expect nil.
    - **Test UI optionnel** (1 happy path) : `testFlowRunning_endToEnd` avec `TypingDelayProvider` mock no-op → 5 taps + verify save success. ⚠️ Si flaky simu, **`@Test(.disabled("Validated manually Cmd+R"))`** (review P1-15 — pas `XCTSkip` qui est XCTest).

## Tasks / Subtasks

- [x] **Task 0** : Branche `epic-3/story-3.1-sport-questionnaire-local` créée depuis main à jour.

- [ ] **Task 1** : ✅ Migration Supabase 003 `coaching_sport_profiles` créée (AC: #6)
  - [x] 1.1 Fichier `supabase/migrations/003_coaching_sport_profiles.sql` créé avec :
    - Schéma table + colonnes review (medical_clearance_acknowledged, frequency_label, questionnaire_version)
    - CHECK constraints sport / level / free_text_notes / frequency_per_week
    - UNIQUE (user_id, sport)
    - RLS 4 policies avec cast `auth.uid()::uuid` explicite
    - Trigger `update_last_updated_at_column()` avec `SET search_path = public`
  - [ ] 1.2 **Sophie applique la migration** via Supabase Dashboard SQL Editor projet `coachingsage-dev` (mémoire `supabase_signup_rate_limit_fix` — pas de CLI).
  - [ ] 1.3 Vérifier le schéma : `SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'coaching_sport_profiles';` (lesson `lessons_supabase #5`).
  - [ ] 1.4 Vérifier RLS policies : `SELECT polname, polcmd FROM pg_policy WHERE polrelid = 'coaching_sport_profiles'::regclass;`.
  - [ ] 1.5 Tester RLS cross-user depuis SQL Editor avec un user secondaire (lesson `lessons_supabase #1`).

- [ ] **Task 2** : Modèles Swift `CoachingSportProfile` + DTOs typés + Repository (AC: #6)
  - [ ] 2.1 Créer `CoachingSage/Models/CoachingSportProfile.swift` (struct value type Codable, propriétés mappées 1-1 avec la table).
  - [ ] 2.2 Créer `CoachingSage/Models/CoachingSportProfileDraft.swift` (struct sans `id` ni `createdAt`).
  - [ ] 2.3 Créer `CoachingSage/Models/QuestionnaireDTOs.swift` (DTOs typés Codable — review P0-2) :
    ```swift
    struct GoalsPayload: Codable { let primary: String }
    struct ConversationEntry: Codable {
        let questionId: String
        let questionTextKey: String  // PAS LocalizedStringKey
        let answerValue: AnswerValueDTO
        let askedAt: Date
        let skipped: Bool?           // nullable
        let skipReason: String?      // nullable
    }
    enum AnswerValueDTO: Codable {
        case single(String)
        case multi([String])
        case text(String?)
    }
    ```
  - [ ] 2.4 Créer `CoachingSage/Repositories/CoachingSportProfileRepository.swift` (protocol).
  - [ ] 2.5 Créer `CoachingSage/Repositories/SupabaseCoachingSportProfileRepository.swift` (impl) :
    - `fetchProfile(for sport: String) async throws -> CoachingSportProfile?`
    - `save(_ draft: CoachingSportProfileDraft) async throws -> CoachingSportProfile` (upsert `onConflict: "user_id,sport", ignoreDuplicates: false`)
    - `delete(for sport: String) async throws` (cleanup orphelin si user retire un sport — Story 2.3 future)
    - ⚠️ **`userId.uuidString.lowercased()`** avant insert/eq (review P0-3).
  - [ ] 2.6 Créer `CoachingSage/Models/CoachingSportProfileDTO.swift` (DTO Supabase, snake_case, match exact migration 003 — lesson `lessons_supabase #3`). Mappings `to`/`from` `CoachingSportProfile` Swift.
  - [ ] 2.7 Ajouter `coachingSportProfileRepository` dans `AppDependencies` (cohérent pattern Story 2.1 healthKitService).
  - [ ] 2.8 Créer `CoachingSageTests/Mocks/MockCoachingSportProfileRepository.swift`.

- [ ] **Task 3** : Protocol `SportQuestionnaire` + types support (AC: #3)
  - [ ] 3.1 Créer `CoachingSage/Coaching/Questionnaires/SportQuestionnaire.swift` (protocol — cf. AC3 signature).
  - [ ] 3.2 Créer `CoachingSage/Coaching/Questionnaires/QuestionnaireTypes.swift` :
    ```swift
    typealias QuestionId = String
    
    struct QuestionnaireQuestion {
        let id: QuestionId
        let textKey: String              // PAS LocalizedStringKey (review P0-1)
        let answerType: AnswerType
        let options: [QuestionOption]    // vide si freeText
    }
    
    enum AnswerType { case singleChoice, multiChoice, freeText }
    
    struct QuestionOption {
        let code: String                 // "beginner", "knee", etc.
        let labelKey: String             // PAS LocalizedStringKey
    }
    
    enum AnswerValue {
        case single(String)
        case multi([String])
        case text(String?)
    }
    ```
  - [ ] 3.3 ⚠️ **Aucun switch FR/EN, aucun `LocalizedStringKey`** dans ces fichiers (mémoire `multilangue_extensible_regle` + review P0-1).

- [ ] **Task 4** : `RunningQuestionnaire` implémentation (AC: #5)
  - [ ] 4.1 Créer `CoachingSage/Coaching/Questionnaires/Running/RunningQuestionnaire.swift` implémentant le protocol.
  - [ ] 4.2 `version = "running_v1"` (review P2-7).
  - [ ] 4.3 Définir Q1 à Q6 avec `textKey` brut (`"questionnaire.running.q1.text"`, etc.) et `QuestionOption(code: "beginner", labelKey: "questionnaire.running.q1.option.beginner")`.
  - [ ] 4.4 `nextQuestion` :
    - Q1 → Q2 → Q3
    - Q3 → si `accumulated[q1] == .single("beginner")` → Q5 (skip Q4) ; sinon Q4
    - Q4 → Q5 → Q6 → nil (fin)
  - [ ] 4.5 `buildProfile` :
    - `level` ← Q1 (single)
    - `goals_json` ← `GoalsPayload(primary: Q2_value)`
    - `frequency_per_week` ← `Q3 == "4_or_more" ? 4 : Int(Q3_value) ?? 2`
    - `frequency_label` ← Q3 brut (review P1-3)
    - `constraints_json` ← Q4 multi (review P1-10 : garder `["none"]` explicit ; **default `[]` UNIQUEMENT si Q4 a été skippée** — distingué via `conversation_history`)
    - `equipment_json` ← Q5 multi, même règle `["none"]`
    - `free_text_notes` ← Q6 si non-vide après `.trimmingCharacters(.whitespacesAndNewlines)`, sinon `nil`
    - `conversation_history_json` ← liste ordonnée incluant Q4 skippée si applicable :
      ```json
      [{"question_id":"q1_level","question_text_key":"questionnaire.running.q1.text","answer_value":{"type":"single","value":"regular"},"asked_at":"..."},
       {"question_id":"q4_constraints","skipped":true,"skip_reason":"level_beginner"},
       ...]
      ```

- [ ] **Task 5** : `SportQuestionnaireViewModel` (AC: #3, #9, #10)
  - [ ] 5.1 Créer `CoachingSage/ViewModels/SportQuestionnaireViewModel.swift` (`@Observable`, `@MainActor`).
  - [ ] 5.2 Properties :
    - `let questionnaire: SportQuestionnaire`
    - `let typingDelay: TypingDelayProvider` (injecté — review P1-5)
    - `var messages: [ChatMessage]` — enum typé (review P1-7) :
      ```swift
      enum ChatMessage: Identifiable {
          case leonText(id: UUID, key: String)
          case userText(id: UUID, key: String)        // ou raw localized String pour réponse user
          case typingIndicator(id: UUID)
      }
      ```
    - `var currentQuestion: QuestionnaireQuestion?`
    - `var accumulatedAnswers: [QuestionId: AnswerValue]`
    - `var conversationHistory: [ConversationEntry]`
    - `var freeTextDraft: String`
    - `var state: ViewState<CoachingSportProfile>`
    - `private(set) var isAdvancing: Bool = false` (review P1-8 idempotence)
    - `private var capturedUserId: UUID?` (review P0-4 cross-user race)
    - `private let pendingKey: String` — `"pending_questionnaire_<userId>_<sport>"` (review P1-6 recovery)
    - `private let questionStartedAt: Date` (review P2-5 mesure perf)
  - [ ] 5.3 `func start()` :
    - `capturedUserId = authService.currentUserId`
    - Append intro Léon (clé `questionnaire.running.intro`)
    - Si `coachingProfile.requiresMedicalClearance == true` → append bulle medical clearance (clé dédiée — AC5)
    - Tenter recovery `UserDefaults` (review P1-6) — si pending pour ce sport, prompt « Reprendre ta saisie ? ». Au tap « Reprendre », charger `accumulatedAnswers` + jump à la prochaine question non répondue.
    - Sinon : append premier `currentQuestion`.
  - [ ] 5.4 `func answer(_ value: AnswerValue) async` :
    - Guard `!isAdvancing` (review P1-8) → abort si déjà en cours.
    - `isAdvancing = true` ; `defer { isAdvancing = false }`
    - Append bulle user (label des options sélectionnées résolu via i18n).
    - Append `ConversationEntry` à `conversationHistory`.
    - Stocker `accumulatedAnswers[currentQuestion.id] = value`.
    - **Persister `accumulatedAnswers` + `freeTextDraft` dans `UserDefaults[pendingKey]`** (review P1-6) avant chaque progression.
    - Calculer `nextQuestion`. Si nil → `await submit()`. Sinon :
      - Si Q4 skippée par le moteur → enregistrer entry `{skipped: true, skip_reason}` dans `conversationHistory`.
      - Append `typingIndicator` puis `await typingDelay.wait()` puis remplacer typing par bulle Léon + currentQuestion.
  - [ ] 5.5 `func submit() async` :
    - `guard let capturedUserId, capturedUserId == authService.currentUserId else { state = .error(.userChanged); return }` (review P0-4)
    - Build draft via `questionnaire.buildProfile(...)` avec `medicalClearanceAcknowledged = coachingProfile.requiresMedicalClearance`.
    - `try await repository.save(draft)`.
    - Re-vérifier `capturedUserId == authService.currentUserId` après l'await (cross-user race).
    - Purger `UserDefaults[pendingKey]` (review P1-6).
    - `state = .loaded(savedProfile)`.
    - Log perf : `debugPrint("Questionnaire running duration: \(Date().timeIntervalSince(questionStartedAt))s")` (review P2-5).
  - [ ] 5.6 `func reset()` : remet à zéro pour relancer le flow (et purge UserDefaults).
  - [ ] 5.7 Créer `CoachingSage/Coaching/TypingDelayProvider.swift` :
    ```swift
    protocol TypingDelayProvider: Sendable {
        func wait() async
    }
    struct RandomTypingDelay: TypingDelayProvider {
        func wait() async {
            let ms = UInt64.random(in: 600...1200) * 1_000_000
            try? await Task.sleep(nanoseconds: ms)
        }
    }
    struct NoTypingDelay: TypingDelayProvider {
        func wait() async {}
    }
    ```

- [ ] **Task 6** : Composants UI chat (AC: #2)
  - [ ] 6.1 Créer `CoachingSage/Views/Components/ChatBubbleView.swift` :
    - Param `message: ChatMessage` (cf. enum Task 5.2).
    - Bulle gauche bleu clair pour Léon, droite accent bleu marine pour user.
    - Padding adapté + max width 75% écran.
    - **Accessibility** (review P2-2) : `.accessibilityLabel` : « Léon dit : ... » / « Tu as répondu : ... » (clés `chat.a11y.leonSays` / `chat.a11y.userReplied`).
  - [ ] 6.2 Créer `CoachingSage/Views/Components/LeonAvatarView.swift` :
    - Vérifier d'abord asset `LeonAvatar` ou `leon-sifflet-v4` dans `Assets.xcassets` (review P2-4).
    - Si absent : `Circle().fill(Color.accentColor).frame(width:40,height:40).overlay(Image(systemName:"figure.run.circle.fill").foregroundStyle(.white).font(.system(size:24)))`.
  - [ ] 6.3 Créer `CoachingSage/Views/Components/TypingIndicatorView.swift` :
    - 3 dots animés opacity loop (0.3s/0.4s/0.5s).
    - `.accessibilityLabel("chat.a11y.leonTyping")`.
  - [ ] 6.4 Créer `CoachingSage/Views/Components/QuestionAnswerOptionsView.swift` :
    - Reçoit `currentQuestion: QuestionnaireQuestion`, callback `onAnswer: (AnswerValue) -> Void`.
    - Single choice : capsules cliquables.
    - Multi choice : checkboxes + bouton « Confirmer ».
    - FreeText : `TextField("questionnaire.running.q6.text", text: $freeTextDraft).lineLimit(2...4)` + bouton « Continuer » + bouton « Continuer sans note ».

- [ ] **Task 7** : `SportQuestionnaireView` écran principal (AC: #1, #2, #9)
  - [ ] 7.1 Créer `CoachingSage/Views/Screens/Coaching/SportQuestionnaireView.swift`.
  - [ ] 7.2 `ScrollViewReader` autour d'une **`VStack` (PAS `LazyVStack`** — review P1-4) de bulles + (en bas, fixed via `safeAreaInset`) `QuestionAnswerOptionsView`.
  - [ ] 7.3 Auto-scroll via `proxy.scrollTo(messages.last?.id, anchor: .bottom)` à chaque ajout, avec `withAnimation(.easeOut(duration: 0.2))`.
  - [ ] 7.4 Toolbar : bouton retour custom avec `confirmationDialog("questionnaire.exit.confirm.title", isPresented: $showExitConfirm) { ... }`.
  - [ ] 7.5 Si `state == .loaded` → `dismiss()` automatique avec callback parent.
  - [ ] 7.6 Si `state == .error` → bandeau rouge + bouton « Réessayer » (relance `submit()`).
  - [ ] 7.7 **`.scrollDismissesKeyboard(.interactively)`** sur la `ScrollView` (review P1-12).
  - [ ] 7.8 Recovery prompt au start (review P1-6) : `.alert("questionnaire.recovery.prompt", isPresented: $showRecoveryPrompt) { Button("questionnaire.recovery.resume"){...} ; Button("questionnaire.recovery.restart", role: .destructive){...} }`.

- [ ] **Task 8** : Entry point onglet Séance (AC: #1)
  - [ ] 8.1 Modifier `CoachingSage/Views/Screens/SeanceView.swift` (si placeholder Story 1.2 existe) :
    - **Observe `appState.coachingProfile` `@Observable`** (review P1-1) — pas de copie locale.
    - `.onAppear` → refetch silencieux pour cohérence multi-device.
  - [ ] 8.2 `VStack` de capsules : pour chaque sport dans `coachingProfile.activeSports` :
    - Si questionnaire dispo (V1 = Running) → `Button("seance.button.requestProgram", action: { openQuestionnaire(sport) })` style capsule.
    - Sinon → même capsule mais `.disabled(true)` + badge `.overlay(Text("seance.button.comingSoon"))` style petit en haut à droite.
  - [ ] 8.3 `func openQuestionnaire(_ sport: String) async`:
    - `let existing = try? await coachingSportProfileRepository.fetchProfile(for: sport)`
    - Si `existing == nil` → présent `SportQuestionnaireView(questionnaire: questionnaireFor(sport))` en sheet plein écran.
    - Sinon → présent placeholder « Programme déjà créé » + bouton « Refaire le questionnaire » qui force re-présentation.
    - Si `existing.createdAt > 90 jours` → texte gris « Profil créé il y a plus de 3 mois — refaire le questionnaire ? » sous le bouton (review P1-13).
  - [ ] 8.4 Helper `func questionnaireFor(_ sport: String) -> SportQuestionnaire?` :
    - V1 : `sport == "running" ? RunningQuestionnaire() : nil`.
    - Si `nil` → la capsule est `.disabled(true)` côté UI (cf. 8.2).

- [ ] **Task 9** : Localisation FR + EN (AC: #7, #8)
  - [ ] 9.1 ⚠️ **Edit ciblé `Localizable.xcstrings`** — JAMAIS lire en entier (> 20MB, règle CLAUDE.md global).
  - [ ] 9.2 Clés Running (~50 clés × 2 langues) :
    - `questionnaire.running.intro` (« Salut ! 5 questions rapides pour te proposer un programme qui te corresponde. » / EN « Hi! 5 quick questions to suggest a program that fits you. »)
    - `questionnaire.intro.medicalClearance` (« Avant qu'on commence : tu m'as indiqué qu'une consultation médicale serait pertinente. Ton programme sera proposé en intensité douce. » / EN équivalent)
    - `questionnaire.running.q1.text` + 4 options (`beginner` / `recreational` / `regular` / `competitive`)
    - `questionnaire.running.q2.text` + 5 options (`5k` / `10k` / `half_marathon` / `marathon` / `wellness`)
    - `questionnaire.running.q3.text` + 3 options (`2` / `3` / `4_or_more`)
    - `questionnaire.running.q4.text` + 5 options (`knee` / `back` / `ankle` / `shin` / `none`)
    - `questionnaire.running.q5.text` + 4 options (`gps_watch` / `heart_rate_monitor` / `treadmill_access` / `none`)
    - `questionnaire.running.q6.text` + `questionnaire.running.q6.action.continueWithoutNote` (review P2-3 — clé renommée explicite)
    - `questionnaire.running.completion`
  - [ ] 9.3 Clés UI génériques :
    - `questionnaire.exit.confirm.title`, `questionnaire.exit.confirm.message`, `questionnaire.exit.confirm.action`, `questionnaire.exit.cancel`
    - `questionnaire.error.save.title`, `questionnaire.error.save.retry`, `questionnaire.error.userChanged` (cross-user race AC10)
    - `questionnaire.options.confirm` (multi), `questionnaire.options.continue` (texte libre)
    - `questionnaire.recovery.prompt`, `questionnaire.recovery.resume`, `questionnaire.recovery.restart`
    - `chat.a11y.leonSays`, `chat.a11y.userReplied`, `chat.a11y.leonTyping`
    - `seance.button.requestProgram` (« Demander un programme %@ »)
    - `seance.button.programExists` (« Programme déjà créé »)
    - `seance.button.refaire` (« Refaire le questionnaire »)
    - `seance.button.comingSoon` (« Bientôt »)
    - `seance.profileOlderThan90Days` (« Profil créé il y a plus de 3 mois — refaire le questionnaire ? »)
  - [ ] 9.4 ⚠️ **Vérifier mots bannis EU MDR FR ET EN** (review P0-5) :
    - Grep dans toutes les nouvelles clés FR : `soin`, `thérapie`, `traitement`, `guérir`, `diagnostiquer`, `prévenir`, `pathologie`, `blessure`, `santé`.
    - Grep dans toutes les nouvelles clés EN : `care`, `therapy`, `treatment`, `cure`, `diagnose`, `prevent`, `pathology`, `injury`, `condition`, `medical`, `health`.
    - 0 occurrence requise. Si match → reformuler.

- [ ] **Task 10** : Tests unitaires (AC: #11)
  - [ ] 10.1 Créer `CoachingSageTests/Questionnaires/RunningQuestionnaireTests.swift` (8 tests AC11).
  - [ ] 10.2 Créer `CoachingSageTests/ViewModels/SportQuestionnaireViewModelTests.swift` (6 tests AC11 incl. cross-user race + idempotence + recovery).
  - [ ] 10.3 Créer `CoachingSageTests/Repositories/CoachingSportProfileRepositoryTests.swift` (3 tests mock).
  - [ ] 10.4 Créer `CoachingSageTests/Localization/RunningQuestionnaireLocalizationTests.swift` (2 tests : keys exist + noBannedTerms).
  - [ ] 10.5 (Optionnel) Test integration RLS — XCTSkip / `@Test(.disabled)` si pas de credentials CI.
  - [ ] 10.6 Vérifier non-régression Story 2.x + Story 1.x.

- [ ] **Task 11** : Validation Sophie + non-régression visuelle
  - [ ] 11.1 Sophie : `xcodegen generate` pour ajouter les nouveaux fichiers Swift au `.xcodeproj` (mémoire `xcodegen_regen_workflow`).
  - [ ] 11.2 **Cmd+B** : compile sans erreur ni warning bloquant.
  - [ ] 11.3 **Cmd+U** : tous les tests Epic 1 + 2.x + 3.1 passent.
  - [ ] 11.4 **Test manuel Cmd+R** :
    - Login user qui a fait l'onboarding (Story 2.2) avec `running` dans active sports.
    - Onglet Séance → capsule « Demander un programme Running » visible et active. Capsules autres sports `.disabled` + badge « Bientôt ».
    - Tap → questionnaire s'ouvre, intro Léon affichée, typing indicator visible.
    - **Si user avec `requiresMedicalClearance == true`** → bulle conditionnelle visible avant Q1.
    - Répondre Q1 = `beginner` → Q4 doit être SKIPPÉE (passage direct Q3→Q5).
    - Répondre Q1 = `regular` → Q4 doit être PRÉSENTÉE.
    - Répondre Q4 = `none` seul → vérifier en base que `constraints_json = ["none"]` (pas `[]`).
    - Compléter Q6 avec note → save → retour onglet Séance → bouton change pour « Programme déjà créé ».
    - **Test recovery** : refaire le flow, fermer l'app au milieu (sans atteindre save) → relancer le questionnaire → prompt « Reprendre ta saisie ? » apparaît.
    - **Test cross-user race** : difficile à reproduire manuel, vérifié unit test 10.2.
    - **Test double-tap idempotence** : taper rapidement 2 fois sur la même option → vérifier qu'on n'a pas sauté Q2.
    - Re-tap « Refaire le questionnaire » → flow reprend depuis le début, save écrase l'ancien profil (vérifier `last_updated_at` change en base via Supabase Dashboard).
    - Vérifier en base : `SELECT * FROM coaching_sport_profiles WHERE user_id = '...'` — toutes les colonnes peuplées correctement (frequency_label, medical_clearance_acknowledged, questionnaire_version = "v1", conversation_history_json complet).
  - [ ] 11.5 **Test localisation EN** (lesson `lessons_localisation #3`) : bascule app en EN via Profil → Identité → Edit → English. Re-ouvrir le questionnaire Running, vérifier toutes les questions/options/intro/completion en anglais. Lister les ~50 clés une par une.
  - [ ] 11.6 ⚠️ **Test clavier Q6** (review P1-12) : taper du texte dans Q6 sur simu réel → vérifier que le clavier ne fait PAS jumper la conversation, que la zone TextField reste accessible.

## Dev Notes

### Prérequis : Story 2.3 mergée ✅

État actuel : Story 2.3 mergée commit `ac411c7` (mémoire `epic2_story23_done`). OK pour démarrer.

Bénéfices acquis :
- `LanguageManager` porté → propagation `\.locale` aux `LocalizedStringKey(textKey)` du questionnaire (AC7).
- `coachingProfile.activeSports` → input AC1 (capsules sport sur Séance).
- Pattern Repository protocol + Supabase impl + Mock + sécurité cross-user → reproductible identique pour `CoachingSportProfileRepository`.

### Décisions de scope tranchées 2026-04-29 (review pré-implem)

1. ✅ **Sports livrés V1 : Running uniquement** (review reco). Justification : valider le pattern (format JSONB Story 3.3, formulation EU MDR-safe, UX chat) avant duplication. Les 9 autres sports = stories de suivi 1-2j chacun post-Story 3.3.

2. ✅ **Entry point onglet Séance : UI minimale capsules** (review reco). VStack de boutons capsules + state disabled+badge pour les 9 sports non livrés. Évite l'over-engineering avant Story 3.2.

3. ✅ **Asset Léon : check d'abord asset existant**, fallback `Circle().fill(Color.accentColor)` + SF Symbol blanc en surimpression. Pas de SF Symbol nu (rendu pauvre).

4. ✅ **`conversation_history_json` : historique complet typé Codable** (review reco). Bénéfices : audit, prompt Léon Story 3.3 peut citer la conversation, monitoring questions ambigües Story 3.7.

### Décision archi : `textKey: String` partout, pas `LocalizedStringKey` (review P0-1)

**Choix retenu** : `QuestionnaireQuestion.textKey: String`, `QuestionOption.labelKey: String`. La résolution UI = `Text(LocalizedStringKey(question.textKey))` côté View.

**Pourquoi** :
- `LocalizedStringKey` n'est pas `Codable` → impossible à sérialiser dans `conversation_history_json`.
- `LocalizedStringKey.key` est privé (accès via `Mirror` = fragile, casse à chaque iOS).
- Single source of truth = la clé `String` brute. Réutilisée pour : affichage UI, sérialisation audit, future requête analytics.

**Trade-off** : 1 ligne de code en plus côté View pour wrapper en `LocalizedStringKey`. Acceptable.

### Décision archi : DTOs typés Codable, jamais `[String: Any]` (review P0-2)

**Choix retenu** : structs Codable dédiées pour chaque champ JSONB.

**Pourquoi** :
- `[String: Any]` n'est pas `Codable` → cascade de hacks `AnyCodable` ou JSON manuel.
- Le client `supabase-swift` sérialise via `Codable` → DTO doit être strictement typé.
- Lesson `lessons_supabase #3` : DTO incomplet écrase NULL → typage strict évite l'oubli de champ.

**Application** :
- `goals_json` → `GoalsPayload`
- `equipment_json` / `constraints_json` → `[String]` natif
- `conversation_history_json` → `[ConversationEntry]`
- `records_json` → struct dédiée (V2)

### Décision archi : SwiftData @Model + Supabase upsert (cohérent CoachingProfile Story 2.2) ✏️ RÉVISÉ 2026-04-29

**Choix retenu (révisé après lecture pattern existant)** : `CoachingSportProfile` est un `@Model` SwiftData PLUS un upsert Supabase, pattern **strictement identique** à `CoachingProfile` (Story 2.2). Hydrate-on-miss côté fetch (SwiftData local → fallback Supabase si miss).

**Pourquoi** :
- **Cohérence** : `CoachingProfile`, `SageCoreProfile` sont tous SwiftData @Model + Supabase. Diverger casserait le pattern.
- **Offline support gratuit** : si l'user fait le questionnaire offline, le `@Model` est créé en SwiftData ; le `SyncService` (Story 1.3) drainera vers Supabase au retour réseau.
- **Pas besoin du recovery UserDefaults pour les réponses validées** : SwiftData persiste de toute façon. Le UserDefaults reste utile uniquement pour les réponses **en cours de saisie** (avant tap « Confirmer » sur la question, surtout Q6 texte libre — review P1-6).
- **SchemaV3** : nouvelle version VersionedSchema avec lightweight migration V2 → V3 (ajout du model, pas de rename ni transformation, comme V1 → V2).

**Pour les champs JSONB en SwiftData** :
- `[String]` (`equipmentJson`, `constraintsJson`) → stocké direct (pattern `CoachingProfile.activeSports: [String]` existant). Si crash random observé en prod, encoder en `Data` (lesson `lessons_swiftdata #1`).
- `GoalsPayload` (struct), `[ConversationEntry]` (struct list) → stockés en `Data` via computed property (`goalsJsonData: Data?` + `var goals: GoalsPayload`). Suit la lesson `lessons_swiftdata #1` strict pour les structs custom (plus risqué que `[String]` brut).

**Trade-off** : ajout SchemaV3 + migration plan. Effort ~+0.25j.

**Recovery UserDefaults révisé** (review P1-6) : sert uniquement à restaurer le `freeTextDraft` Q6 si l'app crash pendant la saisie. Les réponses validées des questions précédentes sont déjà en SwiftData via le draft incrémental.

### Décision archi : 1 fichier Swift par sport, dispatch via `questionnaireFor(sport:)`

**Choix retenu** : `RunningQuestionnaire`, `MusculationQuestionnaire`, etc.

**Pourquoi** : ajouter un sport = 1 fichier + 1 case dans le dispatch + traductions xcstrings. Aucun autre code à toucher.

**Trade-off** : duplication potentielle entre sports. Acceptable V1 — extraction de patterns communs en story dédiée si besoin émerge après 3-4 sports.

### Décision archi : `LocalizedStringKey` au point d'usage, pas dans le moteur

⚠️ **Règle absolue** (mémoire `multilangue_extensible_regle`) : aucun `if lang == "fr" else en` dans le code Swift des questionnaires.

**Application** : moteur manipule `String` (les clés brutes). View résout via `Text(LocalizedStringKey(textKey))`. SwiftUI résout via `\.locale` env injecté par `LanguageManager` (Story 2.3). Ajouter une langue = ajouter `case .german` dans `SupportedLanguage` (SageCore) + traductions xcstrings.

### Décision archi : `["none"]` explicit en DB, pas `[]` (review P1-10)

**Choix retenu** : si l'user sélectionne `none` (Q4 ou Q5), stocker `["none"]` explicit. Le `[]` est réservé au cas « question skippée par le moteur » (Q4 si Q1=beginner).

**Pourquoi** : sémantique préservée pour Léon Story 3.3 :
- `["none"]` → user a confirmé « pas de contrainte »
- `[]` → question pas posée, info absente
- `["knee","back"]` → contraintes spécifiques

**Trade-off** : Léon doit comprendre la sémantique. Documenté dans le prompt Story 3.3.

### Décision archi : `medical_clearance_acknowledged` snapshot au save (review P0-6)

**Choix retenu** : la colonne snapshote `coachingProfile.requiresMedicalClearance` au moment du save du questionnaire.

**Pourquoi** : si l'user fait le questionnaire avec `requiresMedicalClearance = true`, puis change ses réponses PARQ (Story 2.3) qui le passe à `false`, Léon Story 3.3 doit rester conscient que **au moment où le questionnaire a été fait**, l'user était flagged. Cohérence temporelle.

**Architecture Story 3.3** : Léon fera **2 fetches** :
- `coachingProfile` actuel pour `parq_responses` + `requires_medical_clearance` à jour.
- `coachingSportProfile` pour le contexte sport + le snapshot `medical_clearance_acknowledged`.

Le prompt système Léon arbitrera selon les 2 valeurs (cf. Story 3.3 design).

### Décision archi : `frequency_label TEXT` en plus de `frequency_per_week INTEGER` (review P1-3)

**Choix retenu** : 2 colonnes — `frequency_per_week` (entier exploitable directement) + `frequency_label` (string brute "4_or_more").

**Pourquoi** : `4_or_more` peut signifier 5 ou 6 selon l'user. Léon Story 3.3 doit pouvoir générer un programme à 4, 5 ou 6 séances selon le contexte. Sans `frequency_label`, on perd l'option « ou plus ».

**Trade-off** : 1 colonne supplémentaire. Négligeable.

### Décision archi : `TypingDelayProvider` injecté (review P1-5)

**Choix retenu** : protocol `TypingDelayProvider` + 2 impls (`RandomTypingDelay` prod, `NoTypingDelay` test).

**Pourquoi** : sans abstraction, `Task.sleep` est lu inline → tests unitaires attendent 600-1200ms × 5 = 3-6 sec par test, ou polluent les env vars. Avec injection, no-op en test = tests rapides et déterministes.

**Trade-off** : 1 fichier en plus. Trivial.

### Garde-fous légaux Epic 3 — préparation, pas activation V1

⚠️ Story 3.1 ne touche **pas** au prompt système Léon. Les 4 garde-fous légaux (mémoire `epic3_leon_legal_constraints`) sont câblés Story 3.3.

**Mais Story 3.1 doit déjà respecter** :
- **Mots bannis EU MDR FR ET EN** dans toutes les traductions (Task 9.4, review P0-5 — étendu à l'EN).
- **Formulation neutre** Q4 (« contraintes », pas « blessures » ni « pathologies »).
- **Intro reformulée** : éviter « adapté » seul (peut s'enchaîner médical) → « qui te corresponde ».
- **Snapshot `medical_clearance_acknowledged`** garantit que Story 3.3 a la cohérence temporelle.

### Source tree à toucher

**Nouveaux fichiers Swift** :
- `CoachingSage/Models/CoachingSportProfile.swift`
- `CoachingSage/Models/CoachingSportProfileDraft.swift`
- `CoachingSage/Models/CoachingSportProfileDTO.swift`
- `CoachingSage/Models/QuestionnaireDTOs.swift` (GoalsPayload, ConversationEntry, AnswerValueDTO)
- `CoachingSage/Repositories/CoachingSportProfileRepository.swift`
- `CoachingSage/Repositories/SupabaseCoachingSportProfileRepository.swift`
- `CoachingSage/Coaching/Questionnaires/SportQuestionnaire.swift`
- `CoachingSage/Coaching/Questionnaires/QuestionnaireTypes.swift`
- `CoachingSage/Coaching/Questionnaires/Running/RunningQuestionnaire.swift`
- `CoachingSage/Coaching/TypingDelayProvider.swift`
- `CoachingSage/ViewModels/SportQuestionnaireViewModel.swift`
- `CoachingSage/Views/Screens/Coaching/SportQuestionnaireView.swift`
- `CoachingSage/Views/Components/ChatBubbleView.swift`
- `CoachingSage/Views/Components/LeonAvatarView.swift`
- `CoachingSage/Views/Components/TypingIndicatorView.swift`
- `CoachingSage/Views/Components/QuestionAnswerOptionsView.swift`

**Fichiers Swift modifiés** :
- `CoachingSage/App/AppDependencies.swift` (ajouter `coachingSportProfileRepository`).
- `CoachingSage/Views/Screens/SeanceView.swift` (entry point AC1, créer si placeholder).

**Tests** :
- `CoachingSageTests/Questionnaires/RunningQuestionnaireTests.swift`
- `CoachingSageTests/ViewModels/SportQuestionnaireViewModelTests.swift`
- `CoachingSageTests/Repositories/CoachingSportProfileRepositoryTests.swift`
- `CoachingSageTests/Localization/RunningQuestionnaireLocalizationTests.swift`
- `CoachingSageTests/Mocks/MockCoachingSportProfileRepository.swift`

**Supabase** :
- `supabase/migrations/003_coaching_sport_profiles.sql` ✅ créé.

**Localisation** :
- `CoachingSage/Resources/Localizable.xcstrings` (~50 nouvelles clés Running + ~20 clés UI/a11y, edit ciblé jamais lecture entière).

### Pièges à éviter

1. **Lire `Localizable.xcstrings` en entier** → grep + Edit ciblé.
2. **Switch FR/EN hardcodé** → casse extensibilité.
3. **Mots bannis EU MDR FR ET EN** dans les traductions → risque réglementaire (review P0-5 — étendu EN).
4. **DTO `[String: Any]` ou `LocalizedStringKey`** dans les modèles persistés → review P0-1, P0-2.
5. **DTO Swift incomplet vs SQL** → NULL écrase données (lesson `lessons_supabase #3`).
6. **Noms de colonnes différents `.sql` vs base** → vérifier `information_schema` (lesson `lessons_supabase #5`).
7. **RLS pas testée + UUID casing oublié** → bug silencieux cross-user (lessons `lessons_supabase #1` et `#8`).
8. **`@State` au lieu de `@Observable`** pour le ViewModel → état stale (lesson `lessons_swiftdata #6`).
9. **`LazyVStack` pour le chat** → bug auto-scroll iOS (review P1-4).
10. **Typing indicator non injecté** → tests flaky (review P1-5).
11. **Pas de `isAdvancing` guard** → double-tap saute des questions (review P1-8).
12. **Pas de capture `currentUserId`** → cross-user race au save (review P0-4).
13. **Pas de `.scrollDismissesKeyboard`** → jump bug clavier Q6 (review P1-12).
14. **Pas de recovery UserDefaults** → 60 sec de saisie perdues si save fail + dismiss (review P1-6).
15. **`["none"]` remplacé par `[]`** → perte sémantique côté Léon (review P1-10).

### Hors scope V1 (à tracker pour stories ultérieures Epic 3)

- 9 sports autres que Running (`cycling`, `swimming`, `triathlon`, `strengthTraining`, `yoga`, `hiit`, `hiking`, `tennis`, `football` — codes `SportCode` enum) → 9 stories de suivi 1-2j chacun, post-Story 3.3.
- ProgramTemplateSelector (Story 3.2) → flow déclenché APRÈS le save du `CoachingSportProfile`. V1 = stub « Programme déjà créé ».
- Affichage récap du questionnaire dans le profil (Story 2.3 a documenté cette section comme cliquable post-3.1).
- Edition d'un `CoachingSportProfile` existant (autre que « refaire from scratch ») → V2.
- Cache offline du `CoachingSportProfile` en SwiftData → V2 si besoin émerge.
- Migration de cohérence `CoachingSportProfile` orphelin si user retire un sport via Story 2.3 → DELETE policy ajoutée à la migration 003 pour permettre le cleanup côté Swift, mais le hook automatique = story dédiée.
- ON DELETE CASCADE depuis `coaching_profiles` (P2-1) → si feature « supprimer son coaching_profile » émerge, ajouter cleanup explicit.
- Plurals FR/EN automatiques pour le compteur de sports.
- Test integration RLS en CI (P1-14) → infra credentials CI à mettre en place story dédiée.

### Standards de tests

- **Swift Testing** (`@Test`, `#expect`) — pas XCTest. Pour skip un test flaky : `@Test(.disabled("Flaky on simulator, validated manually Cmd+R"))` (review P1-15).
- Mocks via protocol injection (`MockCoachingSportProfileRepository` implémente le protocol).
- ⚠️ Tests UI : si flaky simu, **disabled annotation + test manuel Cmd+R** (max 2-3 tentatives, règle CLAUDE.md).

### Références

- `epics-CoachingSage-v2-proposal.md` (SoT Epic 3) : `GardenSage/_bmad-output/planning-artifacts/epics-CoachingSage-v2-proposal.md` lignes 257-296 (Story 3.1 spec officielle).
- `epic3_leon_legal_constraints` (mémoire) : 4 garde-fous + mots bannis MDR.
- `multilangue_extensible_regle` (mémoire) : règle absolue clés xcstrings, pas de switch.
- `epic2_story23_done` (mémoire) : pattern Repository + LanguageManager + sécurité cross-user.
- `lessons_supabase` (CL3) : RLS, search_path, DTO match, UUID lowercase, RLS tests.
- `lessons_localisation`, `lessons_swiftdata`, `lessons_data_integrity`, `lessons_concurrency` (CL3 global memory).

### Project Structure Notes

- Nouveau dossier `CoachingSage/Coaching/` introduit ici → 1er code « domaine coaching » de l'app. Contiendra futures `Templates/` (Story 3.2), `Adaptation/` (Story 3.3), etc.
- `CoachingSage/Coaching/Questionnaires/` : pattern à reproduire pour les futurs sports.
- `Localization/` nouveau dossier dans `CoachingSageTests/` pour tests dédiés clés xcstrings (cohérent : tests de safety net non-régression i18n).

## Review Tracking — 2026-04-29 (review pré-implem)

Review adversarial faite par sous-agent Plan le 2026-04-29 avant tout code. **30 findings** (7 P0 + 15 P1 + 8 P2). Toutes corrections critiques (P0 + P1 actionnables) intégrées dans cette version du draft.

### P0 (bloquants) — TOUS INTÉGRÉS ✅

| ID | Titre | Intégration |
|---|---|---|
| P0-1 | `LocalizedStringKey` non encodable côté DTO | AC3 : `textKey: String` + `Text(LocalizedStringKey(key))` côté View ; Task 3.2 ; Dev Notes décision dédiée |
| P0-2 | DTO `[String: Any]` non Codable | AC6 + Task 2.3 : structs Codable typées (GoalsPayload, ConversationEntry, AnswerValueDTO) ; Dev Notes décision dédiée |
| P0-3 | `auth.uid()` non recasté UUID | AC6 + migration 003 : RLS `auth.uid()::uuid = user_id` partout ; Task 2.5 : `userId.uuidString.lowercased()` |
| P0-4 | Cross-user race au submit non implémentée | **AC10 nouvel** + Task 5.2/5.3/5.5 : capture `capturedUserId` + re-vérif après chaque await + test `testEngine_submit_abortsIfUserChanged` |
| P0-5 | Mots bannis EU MDR EN oubliés + intro « adapté » | AC5 intro reformulée « qui te corresponde » ; AC8 + Task 9.4 : grep étendu EN (`care`, `therapy`, `treatment`, `cure`, `diagnose`, `prevent`, `pathology`, `injury`, `condition`, `medical`, `health`) ; test `testRunningQuestionnaire_noBannedTerms_FR_and_EN` |
| P0-6 | `requires_medical_clearance` ignoré | AC5 bulle conditionnelle medical clearance ; AC6 colonne `medical_clearance_acknowledged` snapshot ; migration 003 ; Dev Notes décision dédiée |
| P0-7 | UNIQUE + UPSERT non spécifié | AC6 + Task 2.5 : `.upsert(onConflict: "user_id,sport", ignoreDuplicates: false)` update-in-place |

### P1 (important) — TOUS INTÉGRÉS ✅

| ID | Titre | Intégration |
|---|---|---|
| P1-1 | `coachingProfile.activeSports` non rechargé SeanceView | AC1 + Task 8.1 : `SeanceView` observe `appState.coachingProfile @Observable` + refetch onAppear |
| P1-2 | `sport TEXT` sans CHECK | AC6 + migration 003 : CHECK constraints sport (10 valeurs) + level (4 valeurs) |
| P1-3 | `frequency_per_week` mapping lossy | AC6 colonne `frequency_label` ; Task 4.5 sérialise les 2 ; Dev Notes décision dédiée |
| P1-4 | `LazyVStack` + auto-scroll bug iOS | AC2 + Task 7.2 : `VStack` simple, pas LazyVStack |
| P1-5 | Typing indicator `Task.sleep` non testable | AC2 + AC9 + Task 5.7 : protocol `TypingDelayProvider` + RandomTypingDelay/NoTypingDelay |
| P1-6 | Perte de réponses si dismiss accidentel | AC9 + Task 5.4/5.5 + Task 7.8 : snapshot UserDefaults `pending_questionnaire_<userId>_<sport>` + recovery prompt |
| P1-7 | `ChatMessage` pas typé pour distinguer typing | Task 5.2 : enum `ChatMessage` typé incluant `typingIndicator(id:)` |
| P1-8 | Pas d'idempotence au tap répété | AC9 + Task 5.4 : `isAdvancing: Bool` guard + test `testEngine_doubleTap_isIdempotent` |
| P1-9 | `last_updated_at` pas auto-updated | Migration 003 : trigger `update_last_updated_at_column()` avec `SET search_path = public` |
| P1-10 | `["none"]` perdu vs `[]` | AC5 + Task 4.5 : préserver `["none"]` explicit, `[]` réservé question skippée ; test `testBuildProfile_keepsExplicitNoneInArrays` ; Dev Notes décision dédiée |
| P1-11 | Pas de lien `coaching_profiles` ↔ `coaching_sport_profiles` | AC8 + Dev Notes : Story 3.3 fera 2 fetches, snapshot `medical_clearance_acknowledged` garantit cohérence temporelle |
| P1-12 | Jump bug clavier Q6 | AC2 + Task 7.7 : `.scrollDismissesKeyboard(.interactively)` + `.safeAreaInset` ; Task 11.6 QA clavier |
| P1-13 | Sport disparu de active_sports comportement | AC1 : si `createdAt > 90 jours` mention « refaire le questionnaire ? » ; bouton « Refaire » toujours visible si profile existant |
| P1-14 | Pas de test integration RLS | Task 10.5 : test optionnel avec `@Test(.disabled)` si pas de credentials CI |
| P1-15 | `XCTSkip` mentionné mais Swift Testing | Standards de tests : `@Test(.disabled("..."))` |

### P2 (nice-to-have) — Intégrés ou trackés

| ID | Titre | Intégration |
|---|---|---|
| P2-1 | Pas de cascade depuis `core_profiles` | Hors scope V1 (tracké) |
| P2-2 | Accessibility bulles | Task 6.1 : `.accessibilityLabel` clés `chat.a11y.leonSays` / `chat.a11y.userReplied` |
| P2-3 | Clé `q6.skip` peu claire | Task 9.2 : `questionnaire.running.q6.action.continueWithoutNote` |
| P2-4 | Asset Léon SF Symbol monochrome | AC2 + Task 6.2 : check asset existant, fallback cercle bleu marine + symbol blanc |
| P2-5 | Mesure perf flow | AC9 + Task 5.5 : `debugPrint("Questionnaire \(sport) duration: ...s")` |
| P2-6 | Questions skippées non tracées dans history | Task 4.5 + AC5 + test `testConversationHistory_recordsSkippedQ4WithReason` |
| P2-7 | Pas de versioning questionnaire | AC6 colonne `questionnaire_version` ; Task 4.2 `version = "running_v1"` |
| P2-8 | Mock pas listé dans xcodegen | Task 11.1 standard xcodegen — vérifier en passant |

### Décisions de scope (4 ouvertes) — toutes tranchées ✅

Cf. section « Décisions de scope tranchées 2026-04-29 » ci-dessus.

## Dev Agent Record

### Agent Model Used

Claude Opus 4.7 (1M context).

### Debug Log References

(à compléter pendant l'implémentation)

### Completion Notes List

- 2026-04-29 — Branche `epic-3/story-3.1-sport-questionnaire-local` créée depuis main à jour.
- 2026-04-29 — Draft Story 3.1 rédigé en 1ère version puis patché après review adversarial sous-agent (30 findings : 7 P0 + 15 P1 + 8 P2 — tous intégrés au draft v2).
- 2026-04-29 — Migration `supabase/migrations/003_coaching_sport_profiles.sql` créée avec corrections review (RLS cast UUID, CHECK constraints sport alignés `SportCode` enum existant, trigger search_path, colonnes medical_clearance_acknowledged + frequency_label + questionnaire_version).
- 2026-04-29 — Décision archi révisée après lecture pattern existant : SwiftData @Model + Supabase upsert (cohérent CoachingProfile Story 2.2), pas Supabase only. SchemaV3 lightweight migration.
- 2026-04-29 — Tasks 2-10 implémentées en série :
  - Models (CoachingSportProfile @Model, QuestionnaireDTOs typés, DTO Supabase, Schema V3)
  - Repository protocol + Default impl + Mock + AppDependencies update
  - Protocol SportQuestionnaire + types support + RunningQuestionnaire complet
  - SportQuestionnaireViewModel @Observable avec garde-fous (cross-user race + idempotence + recovery UserDefaults + TypingDelayProvider injecté)
  - 4 composants UI (LeonAvatarView, TypingIndicatorView, ChatBubbleView, QuestionAnswerOptionsView)
  - SportQuestionnaireView écran principal (VStack pas LazyVStack, scrollDismissesKeyboard)
  - SessionView refondue : capsules par sport actif, dispatch questionnaire / placeholder Story 3.2 / Bientôt
  - 67 clés Localizable.xcstrings (FR + EN), 0 mot banni EU MDR vérifié grep
  - Tests unitaires Swift Testing : RunningQuestionnaireTests (8 tests), SportQuestionnaireViewModelTests (7 tests dont cross-user race + idempotence + recovery), RunningQuestionnaireLocalizationTests (3 tests dont noBannedTerms FR + EN)

### File List

**Migration Supabase :**
- `supabase/migrations/003_coaching_sport_profiles.sql`

**Modèles (Models/) :**
- `CoachingSportProfile.swift` (@Model SwiftData)
- `QuestionnaireDTOs.swift` (GoalsPayload, ConversationEntry, AnswerValueDTO)
- `Schema/SchemaV3.swift` (nouveau VersionedSchema)
- `Schema/CoachingSageMigrationPlan.swift` (modifié : ajout V2→V3)

**DTOs (Services/DTOs/) :**
- `CoachingSportProfileDTO.swift` (Decodable + UpsertDTO Codable)

**Repository (Repositories/) :**
- `Protocols/CoachingSportProfileRepository.swift`
- `Implementations/DefaultCoachingSportProfileRepository.swift`

**Domaine Coaching (Coaching/ — nouveau dossier) :**
- `Questionnaires/SportQuestionnaire.swift` (protocol)
- `Questionnaires/QuestionnaireTypes.swift` (types support, textKey: String)
- `Questionnaires/Running/RunningQuestionnaire.swift` (sport pilote complet)
- `TypingDelayProvider.swift` (Random/No prod/test)

**ViewModels (ViewModels/) :**
- `SportQuestionnaireViewModel.swift` (@Observable, garde-fous review intégrés)

**UI Composants (Views/Components/) :**
- `LeonAvatarView.swift`
- `TypingIndicatorView.swift`
- `ChatBubbleView.swift`
- `QuestionAnswerOptionsView.swift`

**UI Écrans (Views/Screens/) :**
- `Coaching/SportQuestionnaireView.swift` (nouveau)
- `SessionView.swift` (refondue : capsules + dispatch questionnaire/placeholder)

**App (App/) :**
- `AppDependencies.swift` (modifié : ajout coachingSportProfileRepository)
- `CoachingSageApp.swift` (modifié : SchemaV2 → SchemaV3)

**Localisation (Resources/) :**
- `Localizable.xcstrings` (modifié : +67 clés × 2 langues, 0 mot banni MDR)

**Tests (CoachingSageTests/) :**
- `Mocks/MockCoachingSportProfileRepository.swift`
- `Questionnaires/RunningQuestionnaireTests.swift` (8 tests)
- `ViewModels/SportQuestionnaireViewModelTests.swift` (7 tests, MutableMockAuthService inline)
- `Localization/RunningQuestionnaireLocalizationTests.swift` (3 tests)

### Reste à faire avant `done`

- [ ] Sophie applique migration 003 via Supabase Dashboard SQL Editor + vérifie schema/RLS (Task 1.2-1.5).
- [ ] Tasks 2-9 implémentées (modèles, repo, protocol, RunningQuestionnaire, ViewModel, UI components, SeanceView, localisation).
- [ ] Tous les tests Cmd+U passent (incl. Epic 1 + 2.x non-régression + nouveaux tests AC11).
- [ ] Test manuel Cmd+R : flow complet Running + branchement Q4 + medical clearance bulle conditionnelle + recovery UserDefaults + double-tap idempotence + save success + re-tap refait flow + 90 jours mention.
- [ ] Test localisation EN intégral des ~70 nouvelles clés.
- [ ] Test clavier Q6 sur simu réel (jump bug check).
- [ ] 0 mot banni EU MDR FR + EN dans les traductions.
- [ ] PR mergée + branche pushée.
