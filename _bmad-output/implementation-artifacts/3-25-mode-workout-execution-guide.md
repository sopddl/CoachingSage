# Story 3.25 — Mode workout exécution guidé (pas-à-pas plein écran)

> **🆕 STORY CRÉÉE 2026-05-24 SUITE REVUE AGENT** : Sortie du Sujet D de Story 3.22 (sur-scope + sous-estimation effort + non-respect règle `quality_over_speed_templates`). Story dédiée pour livraison sérieuse sur 8-12j.

Status: **ready-for-review** (en attente de Sophie sur décisions produit ci-dessous)
Branche cible : `epic-3/story-3.25-mode-workout-execution-guide`
Effort estimé : **8-12j** (révisé hausse revue agent vs 5-7j initial sous-estimé)
Découpable en 2 cycles dev (4-6j chacun) si besoin
Stories antécédentes : 3.17/3.18/3.19 (didactique séance V2 mergées). **Dépendance bloquante : Story 3.24b livrée AVANT** (consomme `ExerciseExplanationService`). Fallback gracieux sinon mais expérience dégradée.
Stories parallèles : 3.21 différé, 3.22 (flux UX E/G/F-bis), 3.23 (illustrations), 3.24 (pédagogie a+b).
Story 3.20 (matched-geometry WIP) : compatible, indépendante.

## Story

**As an** utilisatrice débutante qui ouvre une séance strength fraîchement adaptée,
**I want** pouvoir lancer un mode **exécution guidé pas-à-pas plein écran** avec chrono séries/repos pour faire la séance comme avec un coach IRL,
**so that** je peux exécuter la séance sans Googler chaque exo, sans demander à un proche, sans abandonner.

## Contexte produit + preuves test simu Sophie 2026-05-24

Sophie verbatim : *"il faut que tu expliques chaque exo... je pense qu'il faut qu'on fasse un truc où on ait une liste avec la possibilité d'avoir le détail pas à pas ou pas avec un vrai flux utilisateur qu'est-ce que tu en penses ?"*

Le mode **scroll actuel** (`SessionDetailView`) demande de tout lire d'un coup avant la séance. Pour une débutante qui exécute en parallèle (téléphone posé sur le banc), il faut :
- 1 exo à la fois plein écran
- Illustration grosse (consomme `ExercisePatternIllustration` Story 3.19)
- Description exécution précise (consomme `ExerciseExplanationService` Story 3.24b)
- Chrono séries (ascendant) + chrono repos (descendant)
- Transitions exo → exo avec récap mini progression
- Bouton skip repos pour les power-users

**État existant** :
- `SessionDetailView` (`Views/Screens/Coaching/SessionDetailView.swift`) : ScrollView vertical avec hero + WhyPanel + TimelineView + completion + medical footer.
- `ExercisePatternIllustration` (Story 3.19) : composant strip multi-frames réutilisable.
- `SessionCompleteSheet` (existant) : sheet complétion réutilisable pour récap final.
- `SessionCompletionViewModel` (existant) : déjà branché à `recordId` + complétion.
- `ExerciseExplanationService` (Story 3.24b à livrer avant) : explication par exo.

## Modèle mental référence

- **Decathlon Coach** : 1 exo plein écran, chrono séries, bouton "j'ai fini" → bascule auto sur écran repos.
- **Strong App** : table sets/reps modifiable en live, chrono auto-démarré après tap.
- **Fitbod** : illustration grande + sheet "How to" expandable.

Notre approche = mix Decathlon Coach (chrono + transitions auto) + Fitbod (illustration grande).

## Décisions produit à valider Sophie

### D1. Option additive vs remplacement
- **Option A (recommandée)** : **option additive** — bouton "Lancer en mode guidé" CTA secondaire dans `SessionDetailView`. Le scroll classique reste pour power-users qui veulent juste lire avant.
- **Option B** : remplacement complet (risqué, perd les users qui veulent juste lire).

### D2. Persistance partielle reprise
- **Option A (recommandée)** : persiste l'état (currentExerciseIndex, currentSet) en `@AppStorage` si user quitte. Banner reprise dans `SessionDetailView` : "Reprendre la séance en cours" (max 1× par séance).
- **Option B** : pas de persistance, si on quitte on recommence.

### D3. Édition live sets/reps (comme Strong)
- **Option A (recommandée V1)** : pas d'édition — l'utilisatrice exécute ce que Léon a planifié. Bouton "Skip exo" si vraiment incapable, qui marque l'exo comme non fait.
- **Option B** : édition live (tap pour modifier reps réelles) — plus puissant mais plus complexe. Report V2.

### D4. Mode warmup/cooldown
- **Option A (recommandée)** : 1 écran combiné warmup + 1 écran combiné cooldown (texte large + GlossaryRichText) avec bouton "Échauffement terminé" / "Récup terminée".
- **Option B** : chaque exo warmup → un écran dédié comme les exos. Plus uniforme mais plus de taps.

### D5. Yoga / running endurance (exos sans sets/reps discrets, juste `duration`)
- **Recommandation** : footer adapté = chrono direct sur `duration` (ex : "Maintiens la pose 30s"). Bouton "Suivant" après écoulement OU tap manuel.

## Acceptance Criteria

1. **AC1** — Nouveau `Views/Screens/Coaching/GuidedWorkoutView.swift` plein écran (présenté `.fullScreenCover` depuis `SessionDetailView`).
2. **AC2** — Header : barre progression (X/N exos) + chrono séance global ascendant + bouton X close (confirmation si pas terminé).
3. **AC3** — Body par exo : nom large + illustration pattern grande (réutilise `ExercisePatternIllustration` × 2 taille) + description exécution (réutilise `ExerciseExplanationService` Story 3.24b) + metricsChipsRow (sets × reps, RIR, zone).
4. **AC4** — Footer dynamique selon état :
   - **ready** : bouton large « Commencer cette série »
   - **executing** : chrono ascendant + bouton « Série terminée »
   - **resting** : chrono descendant (countdown `restSeconds`) + bouton « Skip repos »
   - **all-sets-done** : bouton « Exo suivant » → animation transition
5. **AC5** — Vue récap finale : exos complétés, durée totale réelle, RPE final (réutilise `SessionCompleteSheet` existante). Bouton "Marquer terminée" branche `SessionCompletionViewModel`.
6. **AC6** — Glossaire actif : description exécution reste tappable (`GlossaryRichText`) même en mode guidé.
7. **AC7** — Mode warmup/cooldown (D4=A) : 1 écran combiné + bouton "Échauffement terminé" / "Récup terminée".
8. **AC8** — Persistance partielle (D2=A) : état mémorisé en `@AppStorage` (currentExerciseIndex, currentSet). Banner reprise dans `SessionDetailView` : « Reprendre la séance en cours » (1× max). **Invalidation** : si séance change via `WeeklyRegenApplicationService`, banner disparaît + état effacé.
9. **AC9** — Accessibilité COMPLÈTE :
   - VoiceOver annonces chrono ("3 secondes restantes") + transitions exo ("Exo 5 sur 8 : DB bench press").
   - Reduce Motion → pas d'animation transition (cross-fade instantané).
   - Dynamic Type : illustration clampe `.medium...(.accessibility2)`. Texte description respecte Dynamic Type sans clamp.
   - `accessibilityLabel` composé sur chaque bouton ("Commencer la série 2 sur 4. Double-tap pour démarrer le chrono.")
10. **AC10** — Tests viewmodel state machine : ready → executing → resting → next ; skip repos ; back-out persistence ; complétion vue récap ; transitions automatiques.
11. **AC11** — i18n : ~30 keys nouvelles FR + EN.
12. **AC12** — Bouton lancement « Lancer en mode guidé » CTA secondaire dans `SessionDetailView` (en dessous du completion button existant).
13. **AC13** — Edge case yoga / running endurance (D5) : footer chrono direct sur `duration` + bouton "Suivant" après écoulement.
14. **AC14** — **Dépendance Story 3.24b** : si `ExerciseExplanationService` non livré au merge → fallback gracieux sur `SessionTipCatalog` actuel. Logger warning en dev `print("[GuidedWorkout] Using fallback tip catalog — 3.24b not deployed")`.
15. **AC15** — `mcp__xcode__BuildProject` PASS, suite tests existants 720+ PASS (3.24a+b livrés), nouveaux tests viewmodel state machine ~20 tests.
16. **AC16** — ui-reviewer agent verdict READY sur scenario `ui_review_guided_workout` (à créer) : 1 séance strength + 1 séance running endurance + 1 séance yoga.

## Fichiers touchés (preview)

**Nouveaux** :
- `Views/Screens/Coaching/GuidedWorkoutView.swift` (~400 lignes)
- `Views/Screens/Coaching/GuidedWorkoutViewModel.swift` (~250 lignes, `@Observable`)
- `Views/Components/GuidedWorkoutTimer.swift` (chrono asc + desc)
- `Views/Components/GuidedWorkoutProgressBar.swift` (X/N exos)
- `Views/Components/GuidedWorkoutHeader.swift` (header avec close + chrono séance)
- `App/UIReviewScenarioContainer.swift` — ajout scenario `ui_review_guided_workout`
- `CoachingSageTests/Views/Screens/Coaching/GuidedWorkoutViewModelTests.swift`

**Modifiés** :
- `Views/Screens/Coaching/SessionDetailView.swift` — ajout bouton « Lancer en mode guidé » + sheet présentation + banner reprise (AC8)
- `Resources/Localizable.xcstrings` — +30 keys FR/EN

## Risques

- **R1 — Dépendance 3.24b mal séquencée** : si dev parallèle réel sur branches séparées depuis main, 3.25 va merger avec un fallback jamais testé. **Mitigation** : soit séquencer strict (3.24b puis 3.25), soit dev 3.25 sur branche basée sur le merge de 3.24b (recommandé).
- **R2 — Persistance partielle vs regen S+1** : si séance change pendant qu'utilisatrice est en pause, l'état mémorisé devient corrompu. Mitigation AC8 : invalidation via `WeeklyRegenApplicationService`.
- **R3 — Yoga / running endurance** : exos sans sets/reps discrets. Footer chrono direct (AC13). Risque sous-estimation si beaucoup de cas edge.
- **R4 — Effort 8-12j sous-estimé encore ?** : state machine complexe + 4 états × edge cases yoga/endurance + persistance + i18n + accessibilité COMPLÈTE + tests + ui-reviewer rigoureux. Si dépassement, **arrêter à 12j et splitter** (3.25a state machine + UI + chrono → 6j, 3.25b persistance + accessibilité + ui-reviewer → 4j).
- **R5 — Cache `ExerciseExplanationService` vide au 1er user** : 1-2s latence affichage description. Mitigation : seed catalogue 10 exos universels (Story 3.24b AC-b2) garantit hit immédiat sur le plus joué.
- **R6 — UI plein écran iPad** : SafeArea + landscape à valider. Story V1 = iPhone portrait only (pas dans le scope iPad maintenant).

## Métriques de succès produit (trou comblé revue)

- **Adoption** : taux d'utilisateurs qui lancent le mode guidé (≥1× par semaine). Logger event `guidedWorkout.launched`.
- **Complétion** : taux de séances complétées en mode guidé vs scroll classique. Hypothèse : mode guidé > scroll de +20pp pour les débutantes.
- **Engagement intra-séance** : taux d'exos skippés en mode guidé. Hypothèse : ≤ 5% sinon UX à revoir.
- **Reprise** : taux d'utilisation du banner "Reprendre la séance en cours". Hypothèse : 20-30% (si l'utilisatrice quitte pour aller chercher de l'eau, elle veut reprendre, pas recommencer).

## Découpage Jalons

**Jalon 1 — ViewModel state machine + tests (1.5j)**
- `GuidedWorkoutViewModel` `@Observable` avec enum `State { ready, executing, resting, allSetsDone, exerciseComplete, sessionComplete }`
- Transitions : ready → executing (tap) → resting (auto après "série terminée") → ready (countdown fini) → ... → allSetsDone → exerciseComplete → next exo OU sessionComplete
- Persistance `@AppStorage` (AC8)
- 20+ tests state machine + edge cases skip repos / back-out persistence / fin

**Jalon 2 — UI vue principale exo + composants chrono (2j)**
- `GuidedWorkoutView` body avec illustration grande + description (réutilise 3.24b) + metricsChipsRow
- `GuidedWorkoutTimer` chrono asc + desc
- `GuidedWorkoutProgressBar` X/N exos
- `GuidedWorkoutHeader` close + chrono séance global
- Layout iPhone portrait validé

**Jalon 3 — Warmup/cooldown + récap + transitions auto (1.5j)**
- Écrans warmup + cooldown combinés (AC7)
- Récap final via `SessionCompleteSheet` réutilisée
- Animations transitions exo → exo (cross-fade, respecte Reduce Motion)
- Edge case yoga / endurance (AC13) : footer chrono direct

**Jalon 4 — Persistance + reprise + banner (1j)**
- `@AppStorage` integration
- Banner "Reprendre la séance en cours" dans `SessionDetailView` (AC8)
- Invalidation via `WeeklyRegenApplicationService` notif

**Jalon 5 — i18n + accessibilité complète + tests (1.5j)**
- 30 keys FR + EN
- AC9 accessibilité complète (VoiceOver + Reduce Motion + Dynamic Type)
- Tests UI accessibility

**Jalon 6 — ui-reviewer scenario + polish + merge (1-2j)**
- Création scenario `ui_review_guided_workout`
- ui-reviewer agent FR + EN sur 3 sports (strength + running + yoga)
- Polish itératif sur findings P0/P1
- Merge main + push

**Total réaliste : 8-12j sur 1 dev solo. Splittable 3.25a (J1-J3 = 5j) + 3.25b (J4-J6 = 3-4j) si pression temps.**

## Hypothèses bloquantes (figer avant kickoff)

- ✅ **Story 3.24b option (c) hybride figée** (cf doc 3.24)
- ⏳ **Story 3.24b livrée AVANT 3.25** (sinon fallback dégradé)
- ⏳ **Sophie tranche D1-D5** (recommandations : A partout)

## Références

- Mémoires : `epic3_story317_phase1_code_complete`, `epic3_story319_done`, `quality_over_speed_templates`, `feedback_first_level_ux_checklist`.
- Story 3.24 réduite : 3.24b livre `ExerciseExplanationService` consommé ici.
- Story 3.20 (pause WIP) : compatible, indépendante.
- Test simu Sophie 2026-05-24 : conversation source.
- Modèles mentaux référence : Decathlon Coach, Strong App, Fitbod.
