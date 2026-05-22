# Story 3.18 — SessionDetail v2 didactique — Phase 2 : Hero + Pourquoi + Timeline

Status: **ready-for-dev** (scopée 2026-05-22 sur branche `epic-3/story-3.18-session-detail-v2-hero-timeline`)
Branche cible : `epic-3/story-3.18-session-detail-v2-hero-timeline`
Effort estimé : **~3-4j** (Phase 2 ; Phase 3 = Story 3.19 illustrations/animations)
Phase précédente : Story 3.17 (fondations glossaire didactique) — mergée main `19a85e5` 2026-05-22.

## Story

**As a** utilisatrice qui ouvre une séance, parfois sans coach IRL ni expérience d'entraînement,
**I want** voir d'un coup d'œil de quoi parle la séance (sport, durée, intensité, nombre d'exos) ET comprendre pourquoi je fais cette séance précisément aujourd'hui,
**so that** je puisse arriver en confiance, motivée, et exécuter la séance comme un coach me l'expliquerait — sans Googler ni demander à Léon.

## Contexte produit

- **Chantier V2 #1** identifié au test simu Sophie 2026-05-11 (mémoire `v2_chantiers_pedagogie_simu_2026_05_11.md`). Phase 1 (glossaire inline) DONE 2026-05-22. Phase 2 = enrichissement visuel + pédagogique du SessionDetailView.
- **État actuel SessionDetailView** (post Phase 1) :
  - Header simple : caption "Semaine X — Jour Y", icône sport monochrome, nom, durée verbatim, thème
  - Layout linéaire vertical : header → (regen banner) → warmup phaseBlock → exercices liste → cooldown phaseBlock → completion → footer médical
  - Glossaire auto-detect inline déjà en place (Phase 1)
- **Manque** :
  - Pas d'identité visuelle sport (couleur, illustration) → toutes les séances se ressemblent visuellement
  - Pas de stats résumé "à quoi je m'attends" (RPE, zone, nb blocs)
  - Pas d'explication pédagogique du "pourquoi" de la séance dans le contexte du programme
  - Pas de visualisation séquentielle "warmup → main → cooldown" — l'ordre est implicite par la position dans le scroll

## Décisions Sophie 2026-05-22 (figées)

1. **Hero header** = **(A) Bande couleur sport + stats grille**. Bandeau full-width tinté `Color.coachingSport(forCode:)`, icône sport large à gauche, nom séance + sous-titre W/J, 4 stats en grille horizontale (⏱ durée · 📊 zone dominante · 🔥 RPE estimé · ☥ nb exercices).
2. **"Pourquoi cette séance ?"** = **(A) Heuristique locale algo**. Texte généré client-side via fonction Swift qui regarde `session.type` + zone dominante + position dans la semaine + objectif du programme. Pas d'IA, 100% offline, multi-langue via xcstrings. Panel **expandable** (collapsed par défaut, "Pourquoi cette séance ?" + chevron, tap pour déplier).
3. **Timeline visuelle** = **(A) Stepper vertical à gauche**. Rail vertical avec pastilles numérotées (⓪ warmup · ① ex1 · ② ex2 · … · ⓝ cooldown), chaque bloc card aligné à droite du rail. Premier pas = warmup tinté orange, derniers = cooldown tinté bleu, exos = tint sport.
4. **Pas de refactor structurel** des modèles `AdaptedSession` / `AdaptedExercise` : tout dérive des champs existants. Pas de nouveaux champs persisté.

## Acceptance Criteria

### Partie (a) — Hero header

1. **AC1** — Nouveau composant `SessionHeroHeader.swift` (Views/Components/) qui remplace le `header` actuel de `SessionDetailView` :
   - Bandeau full-width avec background `Color.coachingSport(forCode: sessionEffectiveSportCode).opacity(0.12)` + border-bottom subtil même couleur opacity 0.4.
   - Padding 16, corner radius 14, marges horizontales standards padding parent.
   - Icône sport SF Symbol `SportSymbol.symbol(forCode:)` taille `.title` (~28pt), foreground `Color.coachingSport(forCode:)`.
   - Caption uppercase `coaching.adapter.session.fullLabel \(weekNumber) \(day)` (réutilise key existante).
   - Nom séance en `.title2.bold()`.
   - Thème semaine (si non-vide) rendu via `GlossaryRichText` (réutilise Phase 1).

2. **AC2** — Grille stats horizontale dans le hero (sous le nom + thème) :
   - 4 cellules `HStack`, chacune `VStack` 2 lignes : valeur en `.callout.bold()` + label en `.caption2` `.foregroundStyle(.secondary)`.
   - Cellule 1 : **Durée** — `\(session.durationMinutes) min` + label `coaching.session.stats.duration` ("Durée" / "Duration"). Icône `clock.fill` à gauche optionnel.
   - Cellule 2 : **Zone dominante** — `SessionStatsCalculator.dominantZone(for: session)` → string courte ("Z2", "Daniels-T", "Tempo", "—" si pas de zone). Label `coaching.session.stats.zone` ("Zone" / "Zone").
   - Cellule 3 : **RPE estimé** — `SessionStatsCalculator.estimatedRPE(for: session)` → `Int 1-10` formaté `"\(rpe)/10"`. Label `coaching.session.stats.rpe` ("Intensité" / "Intensity"). Icône `flame.fill` colorée selon RPE (vert ≤4, orange 5-7, rouge ≥8).
   - Cellule 4 : **Nb blocs** — `session.exercises.count` formaté `"\(n)"`. Label `coaching.session.stats.blocks` ("Blocs" / "Blocks").
   - Layout : grille fit en largeur écran, ne dépasse pas (utiliser `LazyVGrid(columns: .init(repeating: GridItem(.flexible()), count: 4))` ou `HStack` avec `Spacer` entre).
   - **Accessibilité** : 4 cellules combinées `accessibilityElement(children: .combine)`, label "Durée 45 minutes, zone Daniels-T, intensité 7 sur 10, 8 blocs" (à composer).

### Partie (b) — Helper SessionStatsCalculator

3. **AC3** — Nouveau `Coaching/Session/SessionStatsCalculator.swift` (struct sans état, pure func) :
   - `static func dominantZone(for session: AdaptedSession) -> String?` :
     - Parcourt `session.exercises`, collecte les `targetZone` non-vides.
     - Renvoie la valeur la plus fréquente (ties → premier rencontré).
     - Renvoie `nil` si aucun `targetZone` non-vide.
   - `static func estimatedRPE(for session: AdaptedSession) -> Int` :
     - LUT par `SessionType` → range RPE :
       - `.endurance` → 4
       - `.interval` → 8
       - `.technique` → 4
       - `.strength` → 7
       - `.mixed` → 6
       - `.mobility` → 2
       - `.rest` → 1
       - `.other` → 5
     - Ajustement selon zone dominante (si présente) : si la zone matche `daniels.t` / `daniels.i` / `daniels.r` / `ftp.z4` / `ftp.z5` → +1. Si matche `daniels.e` / `ftp.z1` / `en1` → -1.
     - Clampe à `1...10`.
   - `static func rpeColor(_ rpe: Int) -> Color` :
     - 1-4 → `.coachingSuccess`
     - 5-7 → `.coachingWarning`
     - 8-10 → `.coachingError`

### Partie (c) — Panel "Pourquoi cette séance ?"

4. **AC4** — Nouveau composant `SessionWhyPanel.swift` (Views/Components/) :
   - Disclosure group SwiftUI natif (`DisclosureGroup`) :
     - Header : icône `lightbulb.fill` (foreground accent) + texte `coaching.session.why.title` ("Pourquoi cette séance ?" / "Why this session?") en `.callout.bold()`.
     - Body : texte rendu via `GlossaryRichText` (auto-detect glossaire dans la justification — ex: "Cette séance Daniels-T va ancrer ton seuil…" → "Daniels-T" et "seuil" tappables).
     - Collapsed par défaut. Tap header → expand.
     - Animation `.spring(response: 0.35, dampingFraction: 0.85)`.
   - Background `Color(uiColor: .secondarySystemBackground)`, corner radius 10, padding 12.
   - **Accessibilité** : header `accessibilityHint("Tap pour déplier")`, body `accessibilityLabel(whyText)`.
   - **Skip si** `whyText` retourne string vide (cas dégénéré → ne pas afficher du tout le panel).

5. **AC5** — Nouveau `Coaching/Session/SessionWhyExplainer.swift` (struct pure func) :
   - `static func explain(session: AdaptedSession, week: AdaptedWeek, program: AdaptedProgram) -> LocalizedStringKey?` :
     - Matrice clé i18n par `SessionType` × position semaine (early `weekNumber ≤ 2`, mid `< total - 2`, late) × phase taper (last 1-2 weeks de `deadlineFixed`/`deadlineEstimated`).
     - Retourne `nil` si pas de mapping pertinent (ex: type `.rest` → pas de panel).
     - Exemples de mapping :
       - `.interval` + early → `coaching.session.why.interval.early` ("Cette séance fractionnée installe les fondations VO2max. Les premières semaines, on apprend à courir vite sans dette d'oxygène — la qualité prime sur la quantité.")
       - `.interval` + mid → `coaching.session.why.interval.mid` ("Tu sais maintenant courir vite. Aujourd'hui, on densifie le travail de VO2max : plus de séries, récupération maîtrisée.")
       - `.interval` + late → `coaching.session.why.interval.late` ("Dernière phase intense avant l'affûtage : on cible la spécificité de l'épreuve avec des intervalles proches de l'allure objectif.")
       - `.endurance` + early → "Cette sortie en endurance va construire ton réservoir aérobie. C'est la fondation sur laquelle reposera toute la suite du programme."
       - `.endurance` + taper → "Endurance facile en phase d'affûtage : on entretient sans fatiguer. RPE bas, jambes fraîches en sortie."
       - `.strength` + early → "Renforcement de base : on ancre les patterns moteurs avant de monter en charge. Tempo lent, technique avant performance."
       - `.strength` + mid → "Le travail de force a posé ses bases — on cherche maintenant l'hypertrophie fonctionnelle. Charges plus ambitieuses, séries plus longues."
       - `.recovery`/`.mobility` → "Séance d'allègement : ton corps consolide les adaptations des séances dures. RPE 2-3 max."
       - `.technique` (swim) → "Travail technique : on isole un geste pour l'automatiser. Pas d'enjeu cardiovasculaire — on cherche la propreté."
       - Fallback générique : `coaching.session.why.generic` ("Cette séance s'inscrit dans la progression de ta semaine \(weekNumber). \(week.goal)")
   - **Multi-language** : tous les textes via xcstrings FR + EN.

### Partie (d) — Timeline visuelle stepper

6. **AC6** — Nouveau composant `SessionTimelineView.swift` (Views/Components/) qui REMPLACE l'enchaînement actuel `warmup phaseBlock → exercises ForEach → cooldown phaseBlock` :
   - Représentation :
     ```
     ⓪ 🔥 [card warmup tinté orange]
      │
     ① 💪 [card ex1 tinté sport color]
      │
     ② 💪 [card ex2 tinté sport color]
      │
     ⓝ ❄ [card cooldown tinté bleu]
     ```
   - **Rail vertical** : ligne verticale `Rectangle().frame(width: 2)` foreground `Color.coachingPrimary.opacity(0.25)`, alignée verticalement entre les pastilles.
   - **Pastilles** : `ZStack { Circle().frame(width: 28).foregroundStyle(tint) ; Text("\(index)") }` ou icône SF Symbol pour warmup/cooldown (`flame.fill` / `snowflake`).
   - **Indexation** : warmup = index `0` (ou symbole flamme), exos = `1..n`, cooldown = `n+1` (ou symbole flocon).
   - **Layout** : `HStack(alignment: .top, spacing: 12) { rail + pastille ; card content }`.
   - **Card content** : reuse le rendu actuel (`phaseBlock` pour warmup/cooldown, `exerciseRow` pour exos) mais sans icône externe (la pastille remplace).
   - **Cas dégénéré** : warmup `nil`/empty → pas de pastille warmup. Pareil cooldown. Tableau exercises vide → pas de pastilles ex.
   - **Accessibilité** : pastille `accessibilityHidden(true)` (décoratif), card hérite des labels existants.

7. **AC7** — Intégration dans `SessionDetailView` :
   - Remplace le `header` actuel par `SessionHeroHeader(...)`.
   - Insère `SessionWhyPanel(...)` entre header et `regenAdjustedBanner` (ou entre regen banner et timeline si banner présent → décision : **toujours sous le hero, avant le regen banner**).
   - Remplace le triplet warmup/exercises/cooldown par `SessionTimelineView(...)`.
   - Conserve `completionSection`, `medicalReminderFooter` inchangés.

### Partie (e) — Tests

8. **AC8** — `SessionStatsCalculatorTests.swift` (≥10 tests) :
   - `dominantZone` : 0 exos → nil ; 1 exo zone → cette zone ; 3 exos {Z2, Z2, T} → Z2 ; tie {Z2, T} → Z2 (premier rencontré) ; tous nil → nil.
   - `estimatedRPE` : chaque `SessionType` → valeur LUT attendue ; adjust zone dominante haute (Daniels-I) → +1 ; adjust zone basse (Daniels-E) → −1 ; clamp 1...10.
   - `rpeColor` : 1,4 → success ; 5,7 → warning ; 8,10 → error.

9. **AC9** — `SessionWhyExplainerTests.swift` (≥12 tests) :
   - Couvre chaque branche de la matrice (type × position × taper) au moins une fois.
   - `.rest` → nil (pas de panel).
   - Fallback générique appliqué quand pas de mapping spécifique.
   - Cas `program.durationMode == .routineCyclic` → pas de taper (jamais "phase d'affûtage").
   - Test que la `LocalizedStringKey` retournée existe bien dans xcstrings (smoke).

10. **AC10** — `SessionHeroHeaderTests` (≥3 tests, snapshot ou inspect) :
    - Cas happy path running : icône `figure.run` + couleur RUN + 4 stats peuplées.
    - Cas pas de targetZone → cellule zone affiche "—" (placeholder).
    - Cas sport sub-inféré (triathlon natation) → icône `figure.pool.swim`.

11. **AC11** — `SessionTimelineViewTests` (≥3 tests) :
    - Warmup + 2 exos + cooldown → 4 pastilles, 3 rails verticaux.
    - Pas de warmup → pas de pastille ⓪.
    - 0 exos → pas d'exo rows, juste warmup/cooldown si présents.

12. **AC12** — Couverture finale : `xcodebuild test -only-testing:CoachingSageTests` PASS, **549 existants + ~30 nouveaux = ~579 PASS**.

### Partie (f) — i18n

13. **AC13** — Toutes les nouvelles strings FR + EN dans `Resources/Localizable.xcstrings` :
    - 4 keys stats labels (duration, zone, rpe, blocks).
    - 1 key `coaching.session.why.title` ("Pourquoi cette séance ?" / "Why this session?").
    - ~12-15 keys justifications heuristique (matrice type × position).
    - 1 key fallback `coaching.session.why.generic`.
    - 1 key placeholder zone vide "—" (réutiliser éventuellement existante).

### Partie (g) — Build & non-régression

14. **AC14** — `mcp__xcode__BuildProject` ou `xcodebuild build` PASS sur destination `generic/platform=iOS Simulator`.

15. **AC15** — Scenario `ui_review_session_detail_glossary` (Phase 1) **renommé** ou **étendu** en `ui_review_session_detail_v2` pour couvrir hero + Why + timeline. Lance via `SIMCTL_CHILD_UI_TEST_SCENARIO=ui_review_session_detail_v2`.

16. **AC16** — Verdict `ui-reviewer` Bash auto Claude : READY 0 P0/P1 attendu sur FR + EN.

## Hypothèses / Risques

- **Performance grille stats** : recalcul `dominantZone` + `estimatedRPE` à chaque body re-eval → négligeable (≤8 exos, O(n)). Si profilage montre un coût → cacher dans `@State` avec `onAppear`.
- **Timeline rail visuel** : alignement vertical entre pastilles et milieu de card peut diverger selon hauteur de card. Mitigation : ancrer le rail sur la pastille (anchor preference) ou utiliser `GeometryReader` minimaliste. Démarrer simple, ajuster au test visuel.
- **Disclosure group SwiftUI** : sur iOS 17 le style par défaut a un chevron à droite — vérifier au test simu que le style est cohérent avec la palette CoachingSage. Possible custom style nécessaire.
- **Texte "Pourquoi" multilangue** : matrice ~15 entrées × 2 langues = 30 strings à rédiger. Doit être validé par audit doctrine (mémoire `template_review_methodology.md` ? non, ici c'est une vue produit, pas un template). Doctrine simplifiée : justifications généralistes, pas de prescription médicale (cf `epic3_leon_legal_constraints.md` — ne pas dire "tu dois", utiliser "cette séance vise à…").
- **RPE estimation** vs RPE réel : on affiche un RPE théorique ; ne pas confondre avec RPE saisi à la complétion. Label "Intensité" plus prudent que "RPE" — décision UI à valider mais "RPE estimé" mentionné dans Phase 1 mémoire, conserver pour cohérence avec glossaire.

## Out of scope (Phase 3 = Story 3.19)

- Illustrations exos enrichies (SF Symbols par exo type).
- Jauge effort 5 niveaux animée.
- Tip Léon par bloc (suggestion contextualisée par exercice).
- Animations confetti complétion, matched-geometry transition, pulse découvrabilité.
- HealthKit telemetry / target HR overlay.

## Fichiers touchés (preview)

**Nouveaux :**
- `Coaching/Session/SessionStatsCalculator.swift` — dominantZone + estimatedRPE + rpeColor
- `Coaching/Session/SessionWhyExplainer.swift` — matrice heuristique justifications
- `Views/Components/SessionHeroHeader.swift` — hero bandeau couleur + stats grille
- `Views/Components/SessionWhyPanel.swift` — disclosure group "Pourquoi cette séance ?"
- `Views/Components/SessionTimelineView.swift` — stepper vertical warmup → exos → cooldown
- `CoachingSageTests/Coaching/Session/SessionStatsCalculatorTests.swift`
- `CoachingSageTests/Coaching/Session/SessionWhyExplainerTests.swift`
- `CoachingSageTests/Views/Components/SessionHeroHeaderTests.swift` (light)
- `CoachingSageTests/Views/Components/SessionTimelineViewTests.swift` (light)

**Modifiés :**
- `Views/Screens/Coaching/SessionDetailView.swift` — utilise les 3 composants, supprime header/phaseBlock/exercisesSection inline
- `App/UIReviewScenarioContainer.swift` — scenario `ui_review_session_detail_v2` enrichi (couvre les 3 sujets)
- `Resources/Localizable.xcstrings` — +~20 keys (4 stats + 1 why title + ~15 why body)

## Décisions Sophie 2026-05-22 (figées)

1. Hero = bande couleur sport + stats grille 4 cellules (durée · zone · RPE estimé · nb blocs).
2. "Pourquoi" = heuristique locale algo, panel expandable (collapsed par défaut), texte multilingue via xcstrings.
3. Timeline = stepper vertical à gauche avec rail + pastilles numérotées (warmup ⓪ flamme · exos 1..n · cooldown ⓝ flocon).
4. Pas de refactor des modèles `AdaptedSession`/`AdaptedExercise` — tout dérive des champs existants.
