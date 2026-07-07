# Story 3.33 — Séance FOCUS : mode exécution plein écran + avance Manuel (EXÉCUTER)

Status: **ready-for-dev**
Branche cible : `epic-3/story-3.33-seance-focus-manuel`
Effort estimé : **~3-4j**
Source : Party 2026-06-02 + **absorbe/supersède `3-25-mode-workout-execution-guide.md`** (ready-for-review jamais buildée). Réutilise le pattern HUB+FOCUS TailorSage.
Dépendances : **3.32 (HUB) livrée AVANT** (bouton « ▶ Démarrer »). Consomme `ExerciseExplanationService` (3.24b, **DONE**) et `ExercisePatternIllustration` (3.19).

> **Note de réconciliation** : la Story 3.25 (« mode workout exécution guidé pas-à-pas », strength, style Decathlon) décrit exactement ce mode mais en strength-only. La party l'a généralisée en HUB+FOCUS multi-sport. **3.33 remplace 3.25** — archiver `3-25-*.md` après merge. Les décisions D1-D4 de 3.25 sont reprises ci-dessous.

## Historique review
- **2026-06-02** — Review persona Sophie : P0.3 (persistance non tranchée → risque migration SwiftData) → **Décision 6 figée (fichier JSON plat)** ; P1.6 (routage des modes non formalisé) → **AC0** ; P1.2 (triathlon) → **AC0 bis**.

## Story

**As a** utilisateur·rice qui exécute sa séance (téléphone posé à côté),
**I want** un mode plein écran qui me présente **un exo à la fois**, avec illustration, consigne, séries/reps, et que je valide d'un **tap « ✓ Fait »** pour passer au suivant,
**so that** j'exécute ma séance comme guidé par un coach, sans tout relire d'avance ni me perdre.

## Contexte produit

- **FOCUS = EXÉCUTER**, plein écran, **identique pour tous les sports** ; seule la *façon d'avancer* change selon le sport (Manuel ici ; Minuté/Audio/Montre en 3.34-3.36).
- **3.33 = l'avance Manuel** (swipe / tap « Fait ») → couvre **strength** + sert de **shell de base** réutilisé par les modes suivants.
- **Pattern porté de TailorSage** (`ProjectStepFocusView.swift` + `ProjectDetailViewModel.swift`) :
  - `TabView(.page)` paging entre étapes + **points de position** ●◐○ (rempli=fait, anneau=courant).
  - Bouton validation → **auto-avance** à l'étape suivante (`onChange(of: completedCount)`, délai ~350ms).
  - HUB → FOCUS via `.fullScreenCover(item: FocusStepContext)`.
  - Progression = `isCompleted` par étape (pas de currentIndex global) ; « Reprendre l'étape N » = `first(where: !isCompleted)`.
- **Verbatim Sophie (3.25)** : « une liste avec la possibilité d'avoir le détail pas à pas… un vrai flux utilisateur ». **Pain Decathlon** : on perd le début du 1ᵉʳ exo faute d'annonce préalable (la règle « anti-Decathlon » est livrée en 3.34, mode minuté ; ici l'écran d'exo est statique donc l'utilisateur lit avant de tap).

## Décisions (reprises de 3.25 D1-D4 + Party, figées)

1. **Additif, pas remplaçant** (3.25 D1) : FOCUS est lancé depuis le bouton « ▶ Démarrer » du HUB. Le HUB (lecture/scan) reste l'écran par défaut.
2. **Reprise persistée** (3.25 D2, via pattern TailorSage) : l'état « exo fait » est persisté par séance ; le HUB propose **« ▶ Reprendre l'étape N »** sur le premier exo non fait. Pas de currentIndex global — on coche par exo.
3. **Pas d'édition live des séries/reps en V1** (3.25 D3) : on exécute ce que Léon a planifié. Bouton **« Passer »** marque l'exo non fait. Édition live = V2.
4. **Warmup / cooldown = étapes du flux** (3.25 D4) : l'échauffement et la récup sont des étapes FOCUS au même titre que les exos (première et dernière), pas zappées.
5. **Marquage = complétion de séance** : quand tous les exos sont faits, la séance bascule « terminée » (réutilise `SessionCompletionViewModel` existant) + récap.
6. **Persistance « exo fait » = FICHIER JSON PLAT** (figé suite review, P0.3) : pas de bump de schema SwiftData (historique de crashes migration, cf `dette_regen_journal_entry_test_crash` → ils sont passés en JSON plat `regen_journal.json`). On stocke l'état de complétion par séance dans `<Documents>/session_progress.json` (map `sessionRecordId → [stepIndex: done]`). **Aucune nouvelle entité SwiftData, aucun champ ajouté à un model existant.**

## Acceptance Criteria

### (0) Routage de la façon d'avancer
0. **AC0** — Le HUB détermine la **façon d'avancer** par `SportCode`/`SessionType` : strength→Manuel (cette story) ; HIIT/yoga→Minuté (3.34) ; running/cycling/hiking→Audio (3.35) ; swim→Montre (3.36). **Tant que 3.34-3.36 ne sont pas livrées, tout sport non couvert tombe gracieusement sur le mode Manuel** (jamais de cul-de-sac) — la table de routage est centralisée dans un seul `SessionExecutionMode` (enum + résolution).
0b. **AC0 bis** — **Triathlon** : une séance triathlon = **une discipline à la fois** (swim/bike/run) → elle hérite du mode de sa discipline via la même résolution `SessionExecutionMode`. Pas de mode propre.

### (a) Shell FOCUS générique
1. **AC1** — Depuis le HUB, « ▶ Démarrer » ouvre un `.fullScreenCover` FOCUS sur la 1ʳᵉ étape (ou la 1ʳᵉ non faite si reprise).
2. **AC2** — FOCUS affiche : barre top (fermer + compteur « 3/11 » + **points ●◐○** masqués si >14), illustration grand format (`ExercisePatternIllustration`), nom + consigne + métriques (séries/reps/durée/repos), nav bas ‹ Précédent / Suivant ›, bouton **« ✓ Fait »**.
3. **AC3** — Swipe horizontal navigue (TabView `.page`) ; les points reflètent fait/courant/à-faire.
4. **AC4** — Tap « ✓ Fait » coche l'exo + **auto-avance** à l'exo suivant (anim ~0.3s, délai feedback). « Passer » avance sans cocher.

### (b) Étapes warmup/cooldown + explication
5. **AC5** — L'échauffement (`session.warmup`) et la récup (`session.cooldown`) apparaissent comme **première et dernière étapes** FOCUS, avec leur texte.
6. **AC6** — Chaque exo affiche son explication via `ExerciseExplanationService` (3.24b) si dispo ; fallback = tip pattern (`SessionTipCatalog`).

### (c) Reprise + complétion
7. **AC7** — Si on quitte le FOCUS en cours, le HUB affiche **« ▶ Reprendre l'étape N »** (premier exo non fait) ; les exos déjà faits restent cochés (persistance).
8. **AC8** — Quand toutes les étapes sont faites → séance marquée terminée (`SessionCompletionViewModel`) + récap (réutilise `SessionCompleteSheet` existant).

### (d) Tests
9. **AC9** — `SessionFocusViewModelTests.swift` (≥10) : avance/recul, cocher → auto-next, « Passer » n'a pas coché, reprise = 1ᵉʳ non fait, tous faits → terminée, warmup/cooldown présents en première/dernière position. **+ `SessionExecutionModeTests`** (routage par sport + fallback Manuel + triathlon hérite). **+ `SessionProgressStoreTests`** (écriture/relecture JSON plat, reprise après « quit »).
10. **AC10** — i18n FR/EN des libellés (Fait, Passer, Précédent, Suivant, Reprendre l'étape N, Terminée). Test localisation EN.
11. **AC11** — ui-reviewer : FOCUS strength FR + EN, cas reprise, cas séance 1 exo.

## Hypothèses / Risques
- **R1 — Modèle d'étape** : créer un `SessionStep` (warmup | exercise | cooldown) dérivé de `AdaptedSession`, façon `ProjectStep`. **Structure pure, zéro SwiftData.** La persistance de complétion = fichier JSON plat (Décision 6, P0.3 résolu) → pas de risque migration.
- **R2 — Réutiliser TailorSage** : porter `ProjectStepFocusView` en `SessionFocusView` (renommer, retirer le couplage couture). Logique swipe/dots/auto-next = copiable.

## Out of scope (3.34+)
- Avance Minuté (HIIT/yoga) + règle anti-Decathlon → 3.34.
- Avance Audio (TTS/ducking) → 3.35. Montre swim → 3.36.
- Édition live séries/reps (V2).

## Fichiers touchés (preview)
**Nouveaux :**
- `Coaching/Session/SessionStep.swift` — modèle d'étape (warmup/exercise/cooldown) + statut.
- `Coaching/Session/SessionExecutionMode.swift` — enum + résolution `SportCode`/`SessionType` → mode (Manuel/Minuté/Audio/Montre) + fallback gracieux Manuel.
- `Coaching/Session/SessionProgressStore.swift` — persistance JSON plat `session_progress.json` (état exo fait par séance).
- `Coaching/Session/SessionFocusViewModel.swift` — avance, cocher, progression, reprise (porté de `ProjectDetailViewModel`).
- `Views/Screens/Coaching/SessionFocusView.swift` — shell FOCUS (porté de `ProjectStepFocusView`).
- `Views/Components/Session/SessionStepDots.swift`, `SessionStepCheckmark.swift` — portés de TailorSage.
- Tests `SessionFocusViewModelTests.swift`.

**Modifiés :**
- `Views/Screens/Coaching/SessionDetailView.swift` (HUB) — câbler « Démarrer/Reprendre » → `.fullScreenCover`.
- Record/persistance séance — flag « exo fait » par étape (sans bump schema si possible).
- `Resources/Localizable.xcstrings` (FR/EN).

**NON modifiés** : adapter/algo, `SessionCompletionViewModel` (réutilisé).

## Jalons
- **J1 (~1j)** — `SessionStep` + `SessionFocusViewModel` portés + tests logique.
- **J2 (~1.5j)** — `SessionFocusView` shell (swipe/dots/illustration/Fait) + warmup/cooldown + explication exo.
- **J3 (~0.5j)** — Reprise + complétion + récap.
- **J4 (~0.5-1j)** — i18n FR/EN + ui-reviewer + non-régression HUB.

Total : **~3-4j** (vs 8-12j de 3.25 — économie via réutilisation TailorSage + scope strength d'abord). Garde-fou EU MDR identique.
