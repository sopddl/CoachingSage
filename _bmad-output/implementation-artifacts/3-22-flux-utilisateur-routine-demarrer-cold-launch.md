# Story 3.22 — Flux utilisateur (routine sans semaine + flux Démarrer + cohérence dashboard cold launch)

> **🔄 RÉDUCTION POST-REVUE 2026-05-24** : Le Sujet D (mode workout exécution guidé) initialement scopé ici a été **sorti en Story 3.25 dédiée** suite à recommandation revue agent (sur-scope, qualité > vitesse, sous-estimation effort). Cette story reste avec **3 sujets E + G + F-bis** uniquement.

Status: **ready-for-review** (en attente de Sophie sur les décisions produit ci-dessous)
Branche cible suggérée : `epic-3/story-3.22-flux-utilisateur-routine-demarrer-coldlaunch`
Effort estimé global : **~3 j** (décomposable en 3 sous-stories indépendantes E / G / F-bis)
Stories en parallèle : 3.21 différé backlog, 3.23 (qualité illustrations), 3.24 réduite (pédagogie 3.24a+b), 3.25 nouvelle (mode workout guidé).
Story 3.20 (matched-geometry) reste WIP commit `5a81cd8`. **⚠️ Risque merge enfer : 3.22-E réécrit `AdaptedProgramView.sessionRow` containers (DisclosureGroup→LazyVStack), 3.20 fait matched-geo sur ces mêmes session rows. Coordonner avant reprise 3.20 ou rebase 3.20 sur main post-3.22-E.**

Cette story regroupe **3 sujets de flux UX** indépendants remontés par Sophie au test simu 2026-05-24.

---

## Story (×3 sujets)

### Sujet E — Mode routine ≠ mode programme (vue sans semaines)
**As an** utilisatrice qui génère une « routine » (ex : *yoga régulier 3×/semaine sans date cible*),
**I want** voir mes séances comme une liste continue sans découpage en S1/S2/S3,
**so that** je comprends que cette routine n'a pas de fin programmée et que je peux la prolonger naturellement.

### Sujet G — Flux « Démarrer ce programme » qui mène nulle part
**As an** utilisatrice qui vient de générer un programme avec Léon et tape « Démarrer »,
**I want** être amenée naturellement à ma première séance,
**so that** je sais quoi faire ensuite — au lieu de voir le bouton disparaître et me retrouver sur le dashboard sans repère.

### Sujet F-bis — Cohérence dashboard quand vraiment 0 programmes
**As an** utilisatrice qui ouvre l'onglet Séances sur un compte fraîchement créé,
**I want** voir un état vide explicite avec un CTA clair pour démarrer,
**so that** je ne reste pas devant un écran muet.

---

## Contexte produit + preuves test simu Sophie 2026-05-24

> **Sujet E** : *« quand je génère ma routine yoga, je vois W1/W2/W3 mais il ne devrait pas y avoir de notion de semaine, juste des séances qui se suivent »*
>
> **Sujet G** : *« quand je lance un programme (bouton play) ... est-ce que je ne devrais pas me positionner sur la première séance ? Là il ne se passe rien à part le bouton qui disparaît »*
>
> **Sujet F-bis** : Cold launch dev → bannière « 0 programmes » alors que la Story 3.15 v7 a posé un bootstrap dormants.

### État du code aujourd'hui

- **`AdaptedProgram.durationMode`** (`Coaching/Adapter/AdaptedProgram.swift:17-21`) distingue 3 modes : `deadlineFixed`, `deadlineEstimated`, `routineCyclic`. Le discriminant existe et est fiable.
- **⚠️ Risque silencieux** : `AdaptedProgram.swift:57` confirme `durationMode: ProgramDurationMode = .routineCyclic` par défaut. **Tous les records SwiftData sans `durationMode` explicite vont basculer en vue linéaire** (perte des semaines). Voir AC-E0 bloquant ci-dessous.
- **`AdaptedProgramView`** (`Views/Screens/Coaching/AdaptedProgramView.swift:631-684`) affiche un `DisclosureGroup` par semaine indépendamment du `durationMode`.
- **Bouton « Démarrer » preview** : `AdaptedProgramView.previewBottomCTA` + `confirmStartClosure` dans `SessionView.swift:533-578`. Flux actuel : commit record → markStarted → refreshDashboard → `adaptedRoute = nil` → pop nav.
- **`SessionDashboardViewModel.refresh(userId:)`** : si `programs.isEmpty` → `mode = .empty`. Faille bootstrap connue (cf Story 3.21).

### Lien avec Stories voisines

- **Story 3.21** (différé backlog) : bug cold launch dormants — **F-bis doit gérer le cas correctement** sans pré-supposer le fix 3.21 (cf AC-F1 condition `coachingProfile == nil || bootstrappedDormants == false`).
- **Story 3.25** (nouvelle) : mode workout guidé, à livrer après 3.22-G et 3.24b.

---

## Décisions produit à valider Sophie

### D1. Mode routine — quelle vue alternative ?
- **Option A (recommandée)** : vue **liste linéaire** — pas de DisclosureGroup, `LazyVStack` flatten « Séance 1, 2, 3, … ». Pas de notion de semaine.
- **Option B** : un seul DisclosureGroup (toujours déplié) renommé « Mes séances ».
- **Option C** : conserver semaines mais renommer « Bloc 1 / Bloc 2 ».

### D2. Comment marquer la progression en mode routine ?
- **Option A** : badge « En cours » sur la prochaine session pending.
- **Option B** : afficher uniquement N-2 prochaines + collapse passées.
- **Option C** : compteur header global suffit.

### D3. Flux « Démarrer » — où va-t-on après le tap ?
- **Option A (recommandée)** : rester sur `AdaptedProgramView`, ne plus pop nav. Bouton « Démarrer » remplacé par `NextSessionCard` inline.
- **Option B** : auto-navigation vers `SessionDetailView` 1ère séance.
- **Option C** : pop nav + toast « Touche ta prochaine séance ↓ ».

### D4. État vide vraiment vide — que montre-t-on ?
- **Option A (recommandée)** : `EmptyDashboardView` avec CTA « Commencer mon premier programme » ouvrant `SportPickerSheet`.
- **Option B** : auto-redirection vers questionnaire (bloquant, risqué).
- **Option C** : illustré + 3 sports d'essai tap direct.

### D5. Découpage de la story
- **Option A (recommandée)** : 3 sous-stories indépendantes 3.22-E, 3.22-G, 3.22-F-bis.
- **Option B** : 1 seule story livrée d'un bloc (risqué).

---

## Acceptance Criteria

### Sujet E — Routine sans semaines (Hypothèse D1=A)

0. **🚨 AC-E0 BLOQUANT** — **Audit `durationMode` des records SwiftData existants AVANT déploiement** : script de check `fetchActive` qui log le `durationMode` de chaque record. Cible : 0 record avec `durationMode == .routineCyclic` ET sport non-yoga. Si records legacy non-routine ont défaut `.routineCyclic`, **migration silencieuse obligatoire** vers `.deadlineEstimated` selon heuristique (ex : `frequencyPerWeek != nil && targetDate == nil` → `.routineCyclic` confirmé, sinon migrer).
1. **AC-E1** — `AdaptedProgramView` détecte mode routine via `program.durationMode == .routineCyclic` et bascule sur `routineLinearView`.
2. **AC-E2** — En mode routine, **aucun `DisclosureGroup`**. Séances en `LazyVStack` flatten « Séance 1, 2, 3, … ».
3. **AC-E3** — Chaque row utilise `sessionRow(_:week:)` existant. Numéro affiché = index global linéaire 1-indexed.
4. **AC-E4** — `progressHeader` libellé adapté : `coaching.adapter.progress.label.routine`.
5. **AC-E5** — Mode `.deadlineFixed` / `.deadlineEstimated` **inchangé** (DisclosureGroup). Non-régression critique.
6. **AC-E6** — Marker « en cours » sur 1ère session pending (cf D2).
7. **AC-E7** — Auto-scroll à la session courante au mount.
8. **AC-E8** — Tap session row → push `SessionDetailView` inchangé.
9. **AC-E9** — Fixture preview `routineYoga` (12 semaines × 3 sessions = 36 séances aplaties).
10. **AC-E10** — **Coordination Story 3.20** : avant merge 3.22-E, vérifier que la branche 3.20 (matched-geometry WIP) sera rebasée sur main post-3.22-E. Documenter conflit prévisible sur `AdaptedProgramView.sessionRow` containers dans le commit message.

### Sujet G — Démarrer ce programme (Hypothèse D3=A)

11. **AC-G1** — `SessionView.confirmStartClosure(for:deps:)` : après `markStarted`, **ne plus poser `adaptedRoute = nil`**. Mise à jour route en mode actif.
12. **AC-G2** — `AdaptedProgramView` détecte transition preview → actif. Sticky `previewBottomCTA` disparaît.
13. **AC-G3** — En mode actif fraîchement démarré, ajout `NextSessionInlineCard` en haut : « Prochaine séance : {session.name} » + CTA.
14. **AC-G4** — Tap CTA → push `SessionDetailView` 1ère séance pending.
15. **AC-G5** — `NextSessionInlineCard` reste affichée tant qu'au moins 1 session pending.
16. **AC-G6-G7** — Edge cases cap dormant + cap démarré atteints conservés.

### Sujet F-bis — Cohérence dashboard 0 programmes (Hypothèse D4=A)

17. **AC-F1** — `EmptyDashboardView` ajoute CTA primary « Commencer mon premier programme » → ouvre `SportPickerSheet`. **Condition stricte d'affichage** : `coachingProfile == nil || bootstrappedDormants == false`. Si `bootstrappedDormants == true` mais 0 record local (cas Story 3.21 Bug F cross-device non résolu), afficher message dédié "Tes programmes sont sur un autre appareil — synchronise ou recrée".
18. **AC-F2** — Sous-titre explicite « Tu n'as pas encore de programme — choisis un sport pour commencer ».
19. **AC-F3** — Si `coachingProfile == nil` : message dédié « Termine d'abord la création de ton profil » + CTA.
20. **AC-F4** — Aucun impact sur `DormantBootstrapService`.
21. **AC-F5** — Test simu : compte créé sans onboarding → écran vide explicite avec CTA actionnable.

---

## Fichiers touchés (preview)

### Sujet E
- `Views/Screens/Coaching/AdaptedProgramView.swift` — branchement `durationMode == .routineCyclic` → `routineLinearView`.
- `Coaching/Adapter/AdaptedProgram.swift` — helper `flatSessions` éventuel.
- **Script audit migration** (AC-E0) : `Scripts/audit_duration_mode.swift` ou test unitaire dédié.
- `Resources/Localizable.xcstrings` — keys `coaching.adapter.progress.label.routine`, etc.

### Sujet G
- `Views/Screens/SessionView.swift` — `confirmStartClosure(for:deps:)` ne pop plus.
- `Models/AdaptedProgramRoute.swift` — champs `recordId` / `hasStarted` en `var`.
- `Views/Screens/Coaching/AdaptedProgramView.swift` — composant `nextSessionInlineCard`.
- Nouveau `Views/Components/NextSessionInlineCard.swift`.

### Sujet F-bis
- `Views/Screens/Dashboard/EmptyDashboardView.swift` — CTA primary + sous-titre + branchement `SportPickerSheet`.
- `Views/Screens/SessionView.swift` — passage flags `hasCoachingProfile` + `bootstrappedDormants`.
- `Resources/Localizable.xcstrings` — keys empty state.

---

## Risques

- **R1 (E) RÉSOLU par AC-E0** — Templates legacy sans `durationMode` posé → default `.routineCyclic` → migration silencieuse obligatoire bloquante.
- **R2 (G)** — Ne plus pop la nav peut interférer avec `confirmStartClosure` async qui flag `isConfirmingStart`. Mitigation : conserver guard jusqu'à fin re-render.
- **R3 (G)** — Cas commit OK + markStarted KO → état intermédiaire à gérer.
- **R5 (E)** — Routine `routineCyclic` 12 semaines = 36 séances. `LazyVStack` perf OK normalement.
- **R6 (E)** — Fin de cycle routine sans `RoutineRegenService` → afficher « toutes les séances complétées » proprement.
- **R7 (F-bis)** — Race `coachingProfile` chargé après 1er render `EmptyDashboardView`. Mitigation : loading state.
- **R8 (E vs 3.20)** — Merge enfer prévisible si 3.20 (matched-geo) reprend sans rebase post-3.22-E. Cf AC-E10.
- **R9 (F-bis vs 3.21)** — Si 3.21 Bug F non résolu, message AC-F1 cross-device est la mitigation produit.

---

## Décomposition Jalons / sous-stories

### Sous-story 3.22-F-bis — Empty dashboard
- **Effort** : ~0.5 j
- **Acceptance** : AC-F1 à AC-F5.
- **Critère done** : compte sans onboarding → écran avec CTA actionnable, condition F-bis sur `bootstrappedDormants` validée.

### Sous-story 3.22-G — Flux Démarrer
- **Effort** : ~1.5 j
- **Acceptance** : AC-G1 à AC-G7.
- **Critère done** : tap play → reste sur AdaptedProgramView avec card inline.

### Sous-story 3.22-E — Mode routine sans semaines
- **Effort** : ~1 j (+ 0.25j audit AC-E0)
- **Acceptance** : AC-E0 à AC-E10.
- **Critère done** : routine yoga → liste linéaire, programmes legacy non impactés, coordination 3.20 documentée.

### Effort cumulé : 3 j

**Ordre de livraison recommandé** :
1. **3.22-F-bis d'abord** (0.5j — débloque le pain « écran muet »).
2. **3.22-G ensuite** (1.5j — impact UX très visible).
3. **3.22-E** (1.25j — gating sur audit `durationMode` legacy).

Chaque sous-story mergeable indépendamment.

---

## Métriques de succès produit (trou comblé revue)

- **F-bis** : taux d'utilisateurs créant un premier programme via le CTA (vs taux d'abandon sur l'écran vide actuel). Logger event `dashboard.empty.cta.tap`.
- **G** : taux d'utilisateurs qui ouvrent la 1ère session dans les 5 min suivant le tap "Démarrer" (vs aujourd'hui = 0% par construction puisqu'on pop la nav). Logger event `nextSession.inlineCard.tap`.
- **E** : taux de complétion en mode routine (sessions complétées / sessions totales sur 28 jours) — comparable à mode programme.

## Accessibilité (trou comblé revue)

- **Sujet E** : `LazyVStack` rows accessibilityElement combine, Dynamic Type respecté pour les labels « Séance N ».
- **Sujet G** : `NextSessionInlineCard` accessibilityLabel composé "Prochaine séance : {nom}. Double-tap pour ouvrir."
- **Sujet F-bis** : CTA primary VoiceOver-trait `.isButton`, accessibilityHint "Ouvre le sélecteur de sport pour créer ton premier programme."

## Références

- Mémoires : `routine_via_freq_onboarding_comment_ca_marche`, `epic3_story315_done`, `epic3_story_soeur_3z_done`, `epic3_story310_done`, `quality_over_speed_templates`.
- Story 3.21 : bug cold launch dormants (différé) — AC-F1 prévoit le cas.
- Story 3.25 (nouvelle) : mode workout guidé — découplé de cette story.
- Story 3.20 (pause WIP) : risque merge `sessionRow` containers, cf AC-E10.
- Test simu Sophie 2026-05-24 : conversation source.
