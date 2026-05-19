# Story 3.13 — Multi-objectifs simultanés dans le questionnaire (Epic 3)

Status: **ready-for-dev** (doctrine validée 2026-05-19, en attente validation Sophie)
Branche cible : `epic-3/story-3.13-multi-objectifs`
Effort estimé : **~5j** (dev solo) — révisé vs 3-4j initial après scoping sport-specifique

## Story

**As a** utilisateur CoachingSage qui pratique un sport où plusieurs objectifs cohabitent (course endurance + vitesse, muscu force + hypertrophie, natation endurance + technique, vélo endurance + puissance, etc.),
**I want** pouvoir cocher plusieurs objectifs compatibles à la Q2 du questionnaire au lieu d'un seul,
**so that** le programme adapté me parle vraiment et combine intelligemment ce sur quoi je veux travailler — sans me forcer à choisir entre "endurance OU technique" alors que je veux les deux.

## Contexte produit

- **Constat user** (Sophie, V2 chantiers post-test simu 2026-05-11) : "Pour natation on peut avoir plusieurs objectifs : technique, endurance par ex." Généralisé : course endurance+vitesse, muscu force+hypertrophie, vélo endurance+puissance.
- **Pré-requis ouvert** : Story 3.13 #5 swim strokes scopée juste après dépend de cette refonte pour pouvoir suggérer plusieurs goals depuis l'autoprofil HK.
- **Aujourd'hui** : `UniversalQuestionnaire.Q2 = .singleChoice` partout, `GoalsPayload { primary: String }`, `ProgramTemplateSelector` matche 1 template via `template.id.contains(goal.lowercased())`, `ProgramAdapter` applique des règles depuis `goals.primary`.
- **DB** : `coaching_sport_profiles.goals_json` est un JSONB → extensible sans migration SQL si decoder rétrocompat.

## Décisions Sophie 2026-05-18 (figées)

1. **Limite** : illimité (tous goals compatibles).
2. **Sports** : tous les 10 sports passent en multi-choice, avec **matrice de paires incompatibles par sport**.
3. **Strategie overlay** : modulation overlay (template primary + overlay secondary), **par sport** (certains sports permettent travailler plusieurs choses en 1 session, d'autres non).
4. **Primary** : pas de primary explicite côté user. L'algo choisit primary = goal le plus spécifique avec template v2 dispo. Les autres deviennent overlay.
5. **Process** : story doc + `template-quality-reviewer` (sources web) pour valider doctrine compatibilité + overlay AVANT code.
6. **Pré-requis ordre** : 3.13 multi-objectifs AVANT 3.14 swim strokes.

## Acceptance Criteria

### Partie (a) — Refonte Q2 multi-choice

1. **AC1** — `UniversalQuestionnaire.q2Goal` passe en `.multiChoice`. Conserve les `goalOptions(for:)` actuelles par sport (10 sports × 3-5 options).
2. **AC2** — `SportQuestionnaireViewModel` stocke la réponse Q2 comme `AnswerValue.multi([code])`. Compat ascendante : decoder tolérant des `.single` historiques en DB → migré au load en `.multi([primary])`.
3. **AC3** — UI `QuestionAnswerOptionsView` détecte `.multiChoice` → affiche checkboxes (ou pills tappables) au lieu de single radio. Compteur "tu peux choisir 1 ou plusieurs objectifs". Min 1 sélectionné requis pour activer "Suivant".

### Partie (b) — Matrice compatibilité par sport

4. **AC4** — Nouveau service `GoalCompatibilityMatrix` (file: `Coaching/Questionnaires/GoalCompatibilityMatrix.swift`) :
   - `func incompatiblePairs(sportCode: String) -> Set<Pair<String>>`
   - `func isCompatible(_ goalA: String, _ goalB: String, sportCode: String) -> Bool`
   - `func isExclusive(_ goal: String, sportCode: String) -> Bool` (goal qui ne peut être combiné avec aucun autre — ex: wellness, initiation, reprise)
5. **AC5** — UI : quand user coche un goal, l'app **grise** les goals incompatibles (paires interdites + goals exclusifs). User comprend visuellement les contraintes sans message d'erreur.
6. **AC6** — Si user coche un goal exclusif → désélectionne automatiquement tous les autres. Toast léger "Cet objectif est pratiqué seul" (ou similar, à raffiner).

**Matrice DRAFT à valider par `template-quality-reviewer`** :

| Sport | Goals exclusifs | Paires incompatibles |
|---|---|---|
| running | wellness | (5k, marathon), (10k, marathon), (5k, half_marathon) |
| cycling | reprise | aucune |
| swimming | initiation | aucune |
| triathlon | decouverte | (sprint, distance-m), (distance-m, half-ironman), (sprint, half-ironman) → de facto single |
| strengthTraining | home-basics, strength-5x5 | (upperlower, ppl) → exclusif **par design catalogue** (templates structurellement différents : Upper/Lower vs Push/Pull/Legs). NB : PPLUL combiné est doctrinal-valide en pratique (cf reviewer), c'est notre catalogue qui force l'exclusivité, pas la doctrine. |
| yoga | initiation, advanced | aucune |
| hiit | wellness | aucune |
| hiking | decouverte | (day-hikes, fastpacking) → splits cardio incompatibles (marche pure vs course+pack). Source : American Hiking Society + AdventureAlan. NB : `fastpacking + mountain-trek` reste compatible. |
| tennis | initiation | aucune |
| football | initiation | (loisir, club), (loisir, saison-regional) |

### Partie (c) — GoalsPayload + decoder rétrocompat

7. **AC7** — `GoalsPayload` évolue :
   ```swift
   struct GoalsPayload: Codable, Equatable {
       let primary: String
       let secondary: [String]    // nouveau, défaut []
   }
   ```
   - Encoder écrit toujours les 2 fields.
   - Decoder accepte les anciens rows (sans `secondary`) → `secondary = []`.
   - DB JSONB : aucune migration SQL.

### Partie (d) — Selection primary algo

8. **AC8** — `UniversalQuestionnaire.buildProfile()` reçoit la `[String]` multi Q2 → décide primary via :
   - Si 1 seul goal → primary = ce goal, secondary = [].
   - Si ≥2 goals → primary = celui qui a la **doctrine la plus spécifique** dans les templates v2. Règle : ordre canonique sport-specifique défini dans `GoalCompatibilityMatrix.primaryPriority(for: sportCode) -> [String]`. Le premier de cette liste qui est dans la sélection user devient primary.
9. **AC9** — Ordre canonique DRAFT par sport (à valider reviewer) :
   - running : `[marathon, half_marathon, 10k, 5k, wellness]` (le plus long = plus structurant)
   - cycling : `[cyclosportive, sorties-longues, endurance, reprise]`
   - swimming : `[endurance, perfectionnement, technique, initiation]` (endurance = backbone volume hebdo, doctrine Maglischo — corrigé post-review reviewer)
   - strengthTraining : `[strength-5x5, ppl, upperlower, home-basics]`
   - yoga : `[advanced, vinyasa, hatha, initiation]`
   - hiit : `[performance, conditioning, wellness]`
   - hiking : `[fastpacking, mountain-trek, day-hikes, decouverte]`
   - tennis : `[tournoi-prep, match-prep, regularite, initiation]`
   - football : `[saison-regional, club, loisir, initiation]`
   - triathlon : single de facto (pas de ranking).

### Partie (e) — Stratégie overlay par sport

10. **AC10** — Nouveau enum `OverlayStrategy` :
    ```swift
    enum OverlayStrategy {
        case dedicatedSession    // 1 session/sem dédiée au secondary (si freq ≥2)
        case mixInSession        // ajout drills/exos secondary dans sessions existantes
        case hybrid              // dedicated si freq permet, sinon mixInSession
        case notApplicable       // sport single de facto (triathlon, strength)
    }
    ```
11. **AC11** — `GoalCompatibilityMatrix.overlayStrategy(for: sportCode) -> OverlayStrategy` :

**Matrice DRAFT à valider** :
| Sport | Stratégie | Justification |
|---|---|---|
| running | dedicatedSession | séances vitesse/seuil ≠ endurance long, mélange en 1 séance non-doctrinal |
| cycling | dedicatedSession | endurance/sorties-longues = séances dédiées |
| swimming | mixInSession | drills technique + main set endurance dans 1 séance = standard natation |
| strengthTraining | notApplicable | splits exclusifs |
| yoga | mixInSession | hatha + vinyasa peuvent alterner postures dans 1 séance |
| hiit | dedicatedSession | séances très spécifiques |
| hiking | dedicatedSession | day-hikes ≠ mountain-trek (durée/dénivelé différents) |
| tennis | hybrid | fitness drills + match practice combinables, ou dédié |
| football | dedicatedSession | physique vs tactique = séances dédiées |
| triathlon | notApplicable | distance unique |

### Partie (f) — ProgramTemplateSelector multi-goal

12. **AC12** — `ProgramTemplateSelector.select(profile:)` inchangé sur le tie-breaker : match sur `goals.primary` uniquement. Le selector ne voit pas le secondary.
13. **AC13** — Le selector retourne un seul template (comme aujourd'hui).

### Partie (g) — ProgramAdapter overlay

14. **AC14** — Nouveau service `SecondaryGoalOverlay` (`Coaching/Adapter/SecondaryGoalOverlay.swift`) :
    - Input : `template: ProgramTemplate`, `primary: String`, `secondary: [String]`, `frequency: Int`, `sportCode: String`, `strategy: OverlayStrategy`
    - Output : `[Session]` modifié (overlay appliqué)
15. **AC15** — Implémentation par stratégie :
    - **dedicatedSession** : si `frequency ≥ 2` et `secondary.count ≥ 1` → remplacer N sessions du bloc par sessions thématiques secondary (1 session par secondary goal, par bloc). Source : templates secondary minimal.
    - **mixInSession** : injecter des drills/exos secondary en début de chaque session. Ratio = **10-15% du volume séance, plancher 5min, plafond 15min**. Override possible par template pour yoga (où la composition est définie par template, pas par ratio fixe). Constant tunable `OverlayConfig.mixInRatio: Double = 0.15`. Source drills : pool secondary par sport.
    - **hybrid** : dedicatedSession si `frequency ≥ 3`, sinon mixInSession.
    - **notApplicable** : noop (secondary devrait être bloqué en amont).
16. **AC16** — `ProgramAdapterService.adapt()` appelle `SecondaryGoalOverlay.apply()` après le selector et avant la persistence.
17. **AC17** — Garde-fou EU MDR : aucun cumul de blocs intensifs si secondary = "performance"-like et primary = "performance"-like. Vérifier qu'on ne dépasse pas le `intensityCap` du template primary (cf `epic3_leon_legal_constraints`).

### Partie (h) — AutoTitleBuilder + AutoProgramFactory

18. **AC18** — `AutoTitleBuilder.title(for: profile)` produit un titre composite si `secondary.nonEmpty` :
    - FR : "Course 10k + Endurance" (primary localizedName + " + " + secondary[0] localizedName)
    - EN : "10k Run + Endurance"
    - Si ≥2 secondary : "Course 10k + Endurance + Vitesse"
    - Si trop long (>40 chars) : tronquer secondary à "+1 autre".
19. **AC19** — `AutoProgramFactory.previewGenerate()` et `.commit(preview:)` propagent `goals.secondary` correctement.

### Partie (i) — Tests

20. **AC20** — `GoalCompatibilityMatrixTests` (15+ tests) couvre chaque sport × paires incompatibles + exclusifs.
21. **AC21** — `SecondaryGoalOverlayTests` (10+ tests) :
    - dedicatedSession freq=3 + secondary=[technique] → 1 session technique substituée
    - mixInSession swimming endurance + secondary=[technique] → drills technique en début
    - hybrid freq=2 → fallback mixInSession
    - notApplicable → output identique au template
22. **AC22** — `UniversalQuestionnaireTests` étendu : Q2 multi-choice flow, primary algo, exclusif désélectionne, paire incompatible grisée.
23. **AC23** — `GoalsPayloadTests` (decoder rétrocompat row v1 sans secondary).
24. **AC24** — Snapshot Q2 (à porter via `swift-snapshot-testing` si disponible) ou ui-reviewer scenario nouveau.

### Partie (j) — i18n + ui-reviewer

25. **AC25** — Nouvelles keys xcstrings FR/EN :
    - `questionnaire.universal.q2.text.multi` ("Quel(s) objectif(s) ?" / "Which goal(s)?")
    - `questionnaire.universal.q2.hint.multi` ("Tu peux en choisir plusieurs compatibles." / "You can pick several compatible ones.")
    - `goal.exclusive.toast` ("Cet objectif se pratique seul." / "This goal is practiced solo.")
    - `program.title.and` (" + " — séparateur, mais peut être traduit "&" si EN compact)
    - `program.title.others_count` ("+%d autre(s)" / "+%d more")
26. **AC26** — ui-reviewer scenario `ui_review_q2_multichoice` : screenshot questionnaire Q2 chaque sport (10 sports), FR + EN, paires incompatibles grisées, exclusif désélectionne.

## Découpage en sous-tâches

| Phase | Scope | Effort | Branche locale |
|---|---|---|---|
| **A** | Q2 multi-choice (AC1-3) + GoalsPayload (AC7) + tests basiques (AC23) | ~1j | `epic-3/story-3.13-multi-objectifs` |
| **B** | GoalCompatibilityMatrix (AC4-6, AC8-9, AC20) + UI grisage (AC5) | ~1j | idem |
| **C** | SecondaryGoalOverlay (AC10-11, AC14-17, AC21) | ~1.5j | idem |
| **D** | AutoTitleBuilder composite (AC18-19) + AutoProgramFactory propagation | ~0.5j | idem |
| **E** | i18n keys (AC25) + ui-reviewer (AC26) + tests intégration | ~1j | idem |

Total : **~5j**.

## Risques + mitigations

- **Doctrine compatibilité fausse** : `template-quality-reviewer` validation avec sources web AVANT code phase B.
- **Overlay non-doctrinal** : limiter V1 aux 5 sports les plus utilisés (running, cycling, swimming, strength, yoga). Hiit/hiking/tennis/football → `notApplicable` V1, V2 plus tard.
- **UI surchargée** : si plus de 4 options + grisage = confus → tester ui-reviewer, simplifier si besoin.
- **Régression Q2 single existant** : decoder tolérant + tests rétrocompat AC23. Tests existants `UniversalQuestionnaireTests` doivent rester verts.
- **Combinatoire ingérable** : matrice paires incompatibles limite l'explosion. Max effectif observé = 3 goals par sport ; pas illimité dans les faits.

## Hors scope (reporté V2)

- Auto-suggestion de goals depuis HK (= Story 3.14 swim strokes, juste après).
- UI Q2 réorderable par drag (priorité user). Si besoin remonté à l'usage.
- Templates "hybrides" pré-construits (ex: template "5k + endurance"). Aujourd'hui overlay programmatique.
- Cycling overlay `hybrid` (sweet spot injectable dans sortie longue) — V1 reste `dedicatedSession` pour simplicité (cf reviewer minor).

## Pivot doctrine Phase E 2026-05-19 (post-ui-reviewer P1)

L'agent `ui-reviewer` a remonté en Phase E (AC26) un finding P1 : les goals exclusifs (`wellness` running, `home-basics`/`strength-5x5` strength) n'étaient pas grisés visuellement quand un autre goal était sélectionné, créant une dissonance UX (l'user voit l'exclusif tappable alors que tapper déclenche un swap auto AC6 → perd sa sélection).

Diagnostic Sophie : la matrice est **sur-contrainte**. Un user qui vise marathon entraîne déjà sa forme générale par construction ; classer `wellness` "exclusif" mélange "objectif" et "mode" — sans bénéfice doctrinal (le primary canonique tranche déjà).

**Décisions Sophie 2026-05-19** :

1. **Vider les exclusifs de la matrice pour tous les sports.** `GoalCompatibilityMatrix.exclusiveGoals(for:)` retourne `[]` partout. L'API + code swap + toast restent (filet sécurité, ré-introduction ciblée si besoin V2). Tous les "modes" (wellness, initiation, reprise, home-basics, etc.) deviennent simplement des goals comme les autres, soumis aux paires incompat uniquement.

2. **Forcer `.singleChoice` pour `strengthTraining` + `triathlon`.** Catalogue structurellement exclusif (1 split = 1 programme strength ; 1 distance = 1 cycle triathlon). Multi-choice masquerait silencieusement le secondary (overlay `notApplicable`). Single + hint pédagogique "Choisis ton cycle actuel. Tu pourras en enchaîner d'autres ensuite." (FR) / "Pick your current cycle. You can chain others afterward." (EN) = honnête sans frustrer.

3. **`UniversalQuestionnaire.isCycleExclusiveSport(_:)`** centralise cette décision. La View (`QuestionAnswerOptionsView.singleOptions`) affiche la hint cycle uniquement si Q2 + sport ∈ {strengthTraining, triathlon}.

**Tests adaptés** :
- `GoalCompatibilityMatrixTests` : 4 tests réécrits (exclusifs returns [], wellness compat, strength pair-only, swimming all free).
- `UniversalQuestionnaireTests` : nouveau `q2Goal_isSingleChoiceForCycleExclusiveSports`.
- Net : 83 tests verts couvrant les 3 suites Story 3.13.

**Hint i18n key ajoutée** : `questionnaire.universal.q2.hint.cycle` FR/EN. La key `goal.exclusive.toast` reste dans le bundle (code dormant cas V2).

## Verdict reviewer doctrine 2026-05-19

`template-quality-reviewer` : **APPROVED après 4 patches appliqués** :

1. Swimming AC9 — ordre canonique permuté `[endurance, perfectionnement, technique, initiation]` (endurance = backbone volume hebdo Maglischo). ✅
2. Hiking AC4 — paire `(day-hikes, fastpacking)` ajoutée comme incompatible (splits cardio différents). ✅
3. StrengthTraining AC4 — justif `(upperlower, ppl)` reformulée "exclusif par design catalogue" (PPLUL doctrinal-valide en pratique). ✅
4. AC15 ratio mixInSession — "10-15min" remplacé par "10-15% volume, min 5/max 15, override yoga par template". ✅

**Sources doctrine principales** : Daniels Running Formula, Joe Friel Cyclist's Training Bible, Maglischo Swimming Fastest, Israetel Scientific Principles, USTA Tennis Periodization, ACSM HIIT review (PMC11218030), American Hiking Society. EU MDR clean (aucun mot banni).

Architecture matrice + overlay strategy par sport validée. Pas de blocage merge.

