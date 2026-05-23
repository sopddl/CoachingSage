# Story 3.19 — SessionDetail v2 didactique — Phase 3 : Illustrations exos + Jauge effort + Tip Léon

Status: **ready-for-dev** (scopée 2026-05-22, revue adversarial Plan v2 2026-05-22 — P0+P1+P2 intégrés)
Branche cible : `epic-3/story-3.19-session-detail-v2-illustrations-pictos`
Effort estimé : **~8-10j** (Phase 3 ; HK target HR live + matched-geometry reportés Story 3.20+)
Phase précédente : Story 3.18 (hero bandeau + Pourquoi + timeline stepper) — mergée main `202cc43` 2026-05-22.

## Historique review
- **2026-05-22 — Review adversarial Plan #1** : 1 P0 (regex mono-mot + palette en conflit avec design tokens existants), 5 P1 (EU MDR tips, enum trop pauvre push/pull H vs V, matched-geometry irréaliste, Jalon 2 monolithique, AC maths/critères flous), 4 P2. **Tous intégrés** dans révision intermédiaire.
- **2026-05-22 — Review adversarial Plan #2** : verdict NEEDS_MINOR_REVISION. P0 résiduel : corpus templates sous-estimé (32 variantes réelles incluant `Templates/References/`, vs 19 annoncées). P1 mineur : robustesse précédence pulse/tip avec VoiceOver / Reduce Motion / lifecycle. P2 : étiquetage Jalon 2b "coupable" explicite. **Tous intégrés** dans cette révision finale.

## Story

**As a** utilisatrice débutante qui ouvre une séance et voit "Romanian Deadlift haltères légers (pattern hinge)",
**I want** comprendre le geste demandé d'un coup d'œil — voir les phases du mouvement, sentir l'intensité attendue, recevoir un conseil court de Léon adapté à l'exo,
**so that** je puisse exécuter la séance correctement sans coach IRL, sans Googler, sans demander à un proche.

## Contexte produit

- **Chantier V2 #2** identifié au test simu Sophie 2026-05-11 (mémoire `v2_chantiers_pedagogie_simu_2026_05_11.md`). Très gros impact UX : Sophie a dit explicitement « perso je suis incapable de faire la séance sans quelqu'un qui m'explique ».
- **Maquette validée** : `_bmad-output/planning-artifacts/ux-design-CoachingSage-phase3-illustrations-exos-2026-05-22.html` (2026-05-22, validée Sophie). Décisions figées :
  - **Illustrations** = Option B picto monogram custom SVG **multi-frames** (2-3 frames pour gestes dynamiques + 1 frame statique avec annotations pour exos isométriques)
  - **Jauge effort** = Variante I bars 5 niveaux animée (remplace cellule "7/10" du hero)
  - **Tip Léon par bloc** = Variante A avatar inline (cohérence identité Léon)
  - **Source SVG** = Claude dessine en interne, style HTML mockup, bundle inline (pas d'asset externe)
  - **Palette multi-couleurs** : silhouette bordeaux (`#9B282E`), barre/équipement fixe bleu marine (`#2B5F8A`), charges/haltères or (`#D4A85A`), flèches mouvement orange (`#FF9800`), lignes sol/alignement bleu marine pointillé
- **État actuel SessionDetailView** (post Phase 2) :
  - Hero header (bandeau couleur sport · 4 stats · icône large)
  - Disclosure "Pourquoi cette séance ?" heuristique algo
  - Timeline stepper vertical (rail + pastilles ⓪🔥/n/ⓝ❄)
  - Cards exo `exerciseCard()` dans `SessionTimelineView` — texte seul, pas de visuel exo
- **Existant exploitable** :
  - Templates v2 (Story 0.5.10) ont déjà `(pattern squat)`, `(pattern hinge)`, `(pattern pull)`, `(pattern push)` etc. dans le `name` des exos → détection regex name-based triviale (top 4 patterns strength : pull 44× / push 25× / hinge 24× / squat 22× sur 40 templates)
  - `AdaptedExercise` (Coaching/Adapter/AdaptedProgram.swift:115) est une struct Codable — pas de migration SwiftData pour ajouter helpers/computed properties

## Décisions Sophie 2026-05-22 (figées)

1. **Illustrations multi-frames** : 2-3 frames par exo dynamique + 1 frame statique avec annotations pour isométriques. Strip horizontal dans card exo (à gauche du nom + chips).
2. **Jauge effort** = bars 5 niveaux (mapping RPE 1-10 → niveau 1-5) animée à l'apparition. Remplace OU complète la cellule "Intensité 7/10" du hero — choix retenu : **remplace** (gain de lisibilité, mais valeur numérique conservée en VoiceOver et au tap).
3. **Tip Léon par bloc** = avatar circulaire or "L" + texte court 1 phrase par pattern. Catalogue algo (pas IA), 1 tip par pattern × 2 langues.
4. **Animations légères** = matched-geometry hero card → SessionDetailView (transition fluide depuis dashboard) + pulse découvrabilité glossaire 1ère visite.
5. **Détection pattern** = parsing regex multi-mots `\(pattern ([^)]+)\)` du `name`, table de normalisation explicite vers enum (push V/vertical → `.pushVertical`, hinge hyp → `.hinge`, etc.) avec **filtre patterns hebdo** (`J\d` ou commencent par "recommandé" → ignorés, ce ne sont pas des patterns biomécaniques). Fallback keyword match sur lemmes name. Fallback ultime = `.generic` qui rend le **SF Symbol sport iOS 17 en `.palette` multi-couleurs** (cf P2-3 review Plan).
6. **Pas de migration schema** SwiftData. Tout dérive des champs existants `AdaptedExercise.name` / `.notes` / `.targetZone`.
7. **Couleurs** = réutilisation stricte des **design tokens existants** dans `Utilities/Color+Coaching.swift`. JAMAIS modifier `coachingPrimary` (`#1E5090` bleu Léon utilisé 20+ écrans) ni `coachingAccent` (`#7BC142` vert lime CTA). Tokens à utiliser :
   - **Silhouette** → `Color.coachingSport(forCode: effectiveSportCode)` (dynamique : strength brun rouille `#8C4A2E`, running bleu `#1E5090`, etc.) — cohérence avec hero header
   - **Barre / équipement fixe** (squat, pull-up) → `coachingEarth` (`#1B3A5C` bleu marine, existe déjà)
   - **Charges / haltères** (disques squat, haltères RDL) → `coachingRecord` (`#D4A85A` or, existe déjà)
   - **Flèches mouvement** (frames retour) → `coachingWarning` (`#E08A3A` orange, existe déjà)
   - **Sol pointillé / lignes alignement** (plank) → `coachingTextSecondary` (`#5A6577` gris) à 50% opacity
   - **Aucune nouvelle couleur à créer** — la maquette HTML utilisait `#9B282E` (bordeaux inventé), à remplacer par `coachingSport(forCode: "strengthTraining")` = `#8C4A2E` brun rouille dans l'app réelle

## Acceptance Criteria

### Partie (a) — Catalogue pictos multi-frames

1. **AC1** — Nouveau enum `Coaching/Session/ExercisePattern.swift` exposant les patterns supportés V1 (**17 cases** — split push/pull H/V suite review Plan P1-2, biomécanique trop différente pour partager une illu) :
   - Strength : `.squat`, `.hinge`, `.pushHorizontal`, `.pushVertical`, `.pullHorizontal`, `.pullVertical`, `.lunge`, `.core`, `.plyo`, `.mobility`
   - Running : `.runEndurance`, `.runInterval`, `.runDrills`
   - Swim : `.swimDrill`, `.swimEndurance`
   - Cycling : `.cycleEndurance`, `.cycleInterval`
   - Cas spécial : `.generic` (fallback) — pas d'illustration custom, rend le **SF Symbol sport iOS 17 en mode `.palette` multi-couleurs** (cf AC4-bis)
   - Chaque case expose `var frameCount: Int { get }` (1 pour `.core`/`.mobility`/`.runDrills`/`.cycleEndurance`/`.cycleInterval`/`.generic`, 3 pour les autres) et `var isStatic: Bool { get }` (true si frameCount == 1 ET pas `.generic`).

2. **AC2** — Nouveau `Coaching/Session/ExercisePatternResolver.swift` (struct, pure func) :
   - `static func resolve(_ exercise: AdaptedExercise, sportCode: String) -> ExercisePattern`
   - **Stratégie en cascade RÉVISÉE suite review Plan P0-1** :
     1. **Regex multi-mots** : `\(pattern ([^)]+)\)` capture tout le contenu entre parenthèses (peut être multi-mots, accents, tirets).
     2. **Filtre patterns hebdo / structure** (étendu corpus 32 variantes) : si la capture matche **l'une** des regex suivantes → ignored, on tombe en étape 3 :
        - Contient `J\d` (jour numéroté) : `J1 / J3 / J5`, `J1 cardio / J3 renforcement / J5 cardio`, `J1 run / J2 force / J3 tempo`, etc.
        - Commence par `recommandé`, `inchangé`, ou contient `condensé|cardio|renforcement` au niveau pattern complet (PAS au niveau biomécanique).
        - Match l'un de : `complexité croissante`, `in-in-out-out`, `3 touches`, `piège croisé`, `intentionnellement condensé`.
        - Ces patterns sont structurels/pédagogiques/programmation, pas biomécaniques.
     3. **Table de normalisation EXPLICITE** sur la capture (lowercased, trimmed) — **étendue au corpus 32 variantes** (bundle production + `Templates/References/` réserve) suite review Plan 2e passage :
        ```
        # Biomécaniques mono-mots
        "squat" | "squat unilatéral" | "squat + équilibre"     → .squat
        "lower"                                                 → .squat   (lower body squat-dominant)
        "hinge" | "hinge hyp"                                   → .hinge
        "moteur asymétrique"                                    → .core
        "push horizontal" | "push h"                            → .pushHorizontal
        "push vertical"   | "push v"                            → .pushVertical
        "pull horizontal" | "pull h"                            → .pullHorizontal
        "pull vertical"   | "pull v" | "pull v hyp"             → .pullVertical
        "pull vertical alternatif"                              → .pullVertical
        "pull vertical — maintenu en cutback"                   → .pullVertical
        "pull vertical — partie 1" | "pull vertical — partie 2 du combo" → .pullVertical
        ```
        + clause `contains` pour les longues variantes : split sur ` — ` et match sur la partie 1 (`"pull vertical — X"` → `.pullVertical`).
     3-bis. **Patterns non biomécaniques** (tactiques, structurels, programmation) → fallback (étape 4 keyword puis 5 sport puis 6 generic) :
        - "complexité croissante", "in-in-out-out", "en 3 touches, piège croisé-couloir" → pédagogie sportive (foot/tennis), pas biomécanique
        - "W8 intentionnellement condensé" → structure programme
     4. **Keyword match** sur lemmes `name.lowercased()` (si regex n'a rien matché ou capture inconnue) :
        - `squat` → `.squat`, `deadlift|rdl` → `.hinge`, `pull-up|chin-up|tirage` → `.pullVertical`, `row|rameur` → `.pullHorizontal`, `push-up|pompe|bench` → `.pushHorizontal`, `overhead|développé|épaule` → `.pushVertical`, `lunge|fente` → `.lunge`, `plank|gainage|crunch|abs` → `.core`, `jump|burpee|bondiss|saut` → `.plyo`, `étirement|stretch|mobility` → `.mobility`.
     5. **Sport fallback** : `sportCode == "running"` → distingue `interval|fractionné|vo2|série|400|800` → `.runInterval`, `drill|gammes|stride|montée` → `.runDrills`, sinon `.runEndurance`. Similaire `swimming` (`drill|technique|catch|6-3-6` → `.swimDrill`, sinon `.swimEndurance`) et `cycling` (`interval|fractionné|sfr` → `.cycleInterval`, sinon `.cycleEndurance`).
     6. **Fallback ultime** : `.generic` (qui rendra SF Symbol sport via AC4-bis).
   - Pure deterministic, 0 side effect.
   - **Test corpus obligatoire** (AC14) : auditer les **32 patterns** présents dans `Templates/Sources/.../Resources/Templates/` (bundle production = 19 variantes) **ET** `Templates/References/` (réserve = 13 variantes additionnelles dont certains pourraient être promus en production future). Garantir 100% de capture correcte des patterns biomécaniques (~14 variantes mappées sur 6 enum cases strength), et 100% de filtrage des patterns hebdo/structurels (~10 variantes → fallback gracieux). Commande corpus : `grep -rohE '\(pattern [^)]+\)' Templates/References Templates/Sources/TemplateLoader/Resources/Templates/ | sort -u`.

3. **AC3** — Nouveau dossier `Views/Components/Illustrations/` avec **un fichier SwiftUI Path par pattern** (17 patterns, dont 12 dynamiques 3-frames + 5 statiques 1-frame) :
   - **Strength dynamiques (3 frames)** : `SquatIllustration.swift`, `HingeIllustration.swift`, `PushHorizontalIllustration.swift` (pompe/bench), `PushVerticalIllustration.swift` (overhead press), `PullHorizontalIllustration.swift` (row/rameur), `PullVerticalIllustration.swift` (pull-up/chin-up), `LungeIllustration.swift`, `PlyoIllustration.swift`
   - **Strength statiques (1 frame + annotations)** : `CoreIllustration.swift` (plank), `MobilityIllustration.swift`
   - **Running** : `RunEnduranceIllustration.swift` (3 frames foulée), `RunIntervalIllustration.swift` (3 frames vite/lent/vite), `RunDrillsIllustration.swift` (1 frame + annotations)
   - **Swim** : `SwimDrillIllustration.swift` (3 frames), `SwimEnduranceIllustration.swift` (3 frames crawl)
   - **Cycle** : `CycleEnduranceIllustration.swift` (1 frame cycliste + annotation cadence), `CycleIntervalIllustration.swift` (1 frame + annotation effort/cadence)
   - Chacun : `struct XxxIllustration: View` qui prend `frame: Int` (0, 1, 2) pour dynamiques OU rien pour statiques, et retourne le picto SwiftUI. Tailles ViewBox 48×48 (ou 100×60 pour statiques avec annotations).
   - **Palette obligatoire** (utilise design tokens existants, P0-1 review Plan) :
     - **Silhouette** → `Color.coachingSport(forCode: sportCode)` (varie selon sport : strength brun rouille `#8C4A2E`, running bleu `#1E5090`, swim cyan `#4FB3D9`, cycle vert `#2D8A4E`, hiit rouge `#C43D3D`, etc.)
     - **Barre / équipement fixe** → `.coachingEarth` (`#1B3A5C`)
     - **Charges / haltères** → `.coachingRecord` (`#D4A85A`)
     - **Flèches mouvement** (frame retour) → `.coachingWarning` (`#E08A3A`)
     - **Sol pointillé / lignes alignement** → `.coachingTextSecondary` (`#5A6577`) `.opacity(0.5)`
     - **Stroke width** centralisé via `IllustrationStyle.strokeWidth = 2.5`, `strokeWidthHeavy = 4.0` (charges).
   - **AUCUNE création de nouvelle couleur** dans `Color+Coaching.swift` — tout existe déjà.

4. **AC4** — Nouveau composant `Views/Components/ExercisePatternIllustration.swift` :
   - `struct ExercisePatternIllustration: View { let pattern: ExercisePattern ; let sportCode: String ; var size: CGFloat = 64 }`
   - Body : strip horizontal de 1-3 frames + flèches mouvement entre, selon `pattern.frameCount`.
   - Frame layout : `HStack(spacing: 2) { Frame0 ; arrow ; Frame1 ; arrow ; Frame2 }` ou variante statique avec annotations à droite.
   - Si `pattern == .generic` → délègue à `ExercisePatternGenericFallback(sportCode:)` (cf AC4-bis), **pas** EmptyView().
   - **Accessibilité** : `accessibilityHidden(true)` sur les frames (décoratif) + `accessibilityLabel("Illustration : <pattern name>, <frameCount> phases du mouvement")` au niveau strip combiné via clé i18n `coaching.session.exercise.illustration.a11y`.
   - **Dynamic Type** (P2-4 review Plan) : encapsuler le strip dans `.dynamicTypeSize(.medium...(.accessibility2))` pour clamp — éviter explosion taille en `XXXL` accessibility.

4-bis. **AC4-bis** — Nouveau `Views/Components/ExercisePatternGenericFallback.swift` (P2-3 review Plan) :
   - `struct ExercisePatternGenericFallback: View { let sportCode: String }`
   - Body : SF Symbol sport iOS 17 en mode multi-couleurs natif via `.symbolRenderingMode(.palette)` + `.foregroundStyle(Color.coachingSport(...), .coachingRecord, .coachingEarth)`.
   - Mapping SF Symbol par sport : reuse logique existante `SportSymbol.symbol(forCode:)`.
   - Pas de frames, juste l'icône taille 48pt centrée.
   - Garantit qu'on a TOUJOURS un visuel même si pattern non résolu — pas de card "vide".

5. **AC5** — Modification `Views/Components/SessionTimelineView.swift` :
   - `exerciseCard(_ ex: AdaptedExercise)` : insérer `ExercisePatternIllustration` au-dessus ou à gauche du `ex.name`. **Layout retenu** : strip horizontal en haut de la card (sous le nom, avant les notes), full-width-ish, fond léger `Color(uiColor: .tertiarySystemBackground)`, corner radius 8, padding 8.
   - Si pattern résolu == `.generic` → pas d'illu rendue (card identique à Phase 2).

### Partie (b) — Jauge effort 5 niveaux

6. **AC6** — Nouveau composant `Views/Components/EffortGauge.swift` :
   - `struct EffortGauge: View { let level: Int (1...5) ; var animated: Bool = true }`
   - Body : `HStack(spacing: 3)` de 5 `RoundedRectangle` :
     - Largeur 8pt, hauteur progressive (8 / 12 / 16 / 20 / 24 pt).
     - `level` premiers remplis `.coachingPrimary`, restants `.coachingPrimary.opacity(0.18)`.
     - Animation `.spring(response: 0.4, dampingFraction: 0.7)` au premier `onAppear` (allumage cascadé 60ms de décalage par bar).
   - Hauteur totale fixe ~26pt pour intégrer en cellule stat hero.

7. **AC7** — Helper `SessionStatsCalculator` étendu :
   - `static func effortLevel(rpe: Int) -> Int` : mapping 1-2 → 1, 3-4 → 2, 5-6 → 3, 7-8 → 4, 9-10 → 5. Clampé.
   - `static func effortLabel(level: Int) -> LocalizedStringKey` : 1 → "coaching.effort.level.1" ("Doux" / "Easy"), 2 → "Modéré" / "Moderate", 3 → "Soutenu" / "Sustained", 4 → "Difficile" / "Hard", 5 → "Maximal" / "Maximal".

8. **AC8** — Modification `Views/Components/SessionHeroHeader.swift` :
   - La cellule stat #3 "Intensité 7/10" devient `EffortGauge(level: SessionStatsCalculator.effortLevel(rpe: estimatedRPE))` + label dérivé.
   - **VoiceOver** : accessibilityLabel composé "Intensité 4 sur 5, niveau Difficile, RPE 7 sur 10" (conserve la donnée numérique pour accessibilité).
   - Tap sur la cellule → affiche un sheet/popover court "Échelle d'intensité" avec les 5 niveaux et la définition RPE (réutilise `GlossaryTermBadge` style ou popover natif). **Optionnel** — si > 1j → reporter Story 3.20, prioriser le rendu visuel.

### Partie (c) — Tip Léon par bloc

9. **AC9** — Nouveau `Coaching/Session/SessionTipCatalog.swift` (struct sans état) :
   - `static func tip(for pattern: ExercisePattern, exerciseName: String) -> LocalizedStringKey?`
   - Catalogue : 1-2 tips courts (≤ 200 chars) par pattern, focus technique pratique. Exemples :
     - `.squat` → "coaching.tip.squat" ("Concentre-toi sur la descente contrôlée 3 secondes et la poussée par les talons. Genoux dans l'axe des pieds, dos droit.")
     - `.hinge` → "coaching.tip.hinge" ("Le mouvement vient de la hanche, pas du dos. Sens les ischio-jambiers s'étirer en descendant — c'est eux qui font le travail.")
     - `.pullVertical` → "coaching.tip.pull.vertical" ("Engage d'abord les omoplates (scapula) avant de plier les bras. Mouvement complet : menton au-dessus de la barre.")
     - `.pullHorizontal` → "coaching.tip.pull.horizontal" ("Tire les coudes vers l'arrière en serrant les omoplates. Le buste reste stable, le mouvement vient des bras et du haut du dos.")
     - `.pushHorizontal` → "coaching.tip.push.horizontal" ("Coudes proches du corps (45°), pas écartés. Descente contrôlée jusqu'à effleurer, poussée explosive.")
     - `.pushVertical` → "coaching.tip.push.vertical" ("Verrouille le gainage avant de pousser au-dessus de la tête. Pas de cambrure lombaire — abdos serrés pendant tout le mouvement.")
     - `.core` → "coaching.tip.core" ("Cherche la ligne droite épaules-bassin-talons. Si ton bassin descend, raccourcis le temps plutôt que casser la posture.")
     - `.plyo` → "coaching.tip.plyo" ("Atterrissage moelleux genoux fléchis — c'est lui qui protège tes articulations. Pas de bruit à l'arrivée.")
     - `.lunge` → "coaching.tip.lunge" ("Genou avant dans l'axe du pied, genou arrière qui descend vers le sol sans toucher. Buste droit.")
     - `.runEndurance` → "coaching.tip.run.endurance" ("Allure de conversation : si tu peux parler à un partenaire imaginaire sans haleter, le rythme est bon.") — **reformulé suite P1-1 review Plan** (interdit "tu dois" EU MDR)
     - `.runInterval` → "coaching.tip.run.interval" ("Sur la fraction rapide, vise un effort autour de 8/10 — l'objectif est de tenir l'intervalle entier sans craquer.") — **reformulé suite P1-1 review Plan**
     - `.swimEndurance` → "coaching.tip.swim.endurance" ("Glisse longue entre chaque coup de bras. Respire tous les 3 temps pour équilibrer gauche/droite.")
     - `.swimDrill` → "coaching.tip.swim.drill" ("Le drill technique n'est pas une course — fais lentement, sens chaque phase du geste.")
     - `.cycleEndurance` → "coaching.tip.cycle.endurance" ("Cadence 80-90 rpm, jambes qui tournent rond sans à-coups. Le souffle dicte l'effort, pas le braquet.")
     - `.cycleInterval` → "coaching.tip.cycle.interval" ("Reste assis sur les fractions, garde la cadence. La force vient de la régularité, pas du braquet lourd.")
     - `.mobility` → "coaching.tip.mobility" ("Maintiens chaque position 20-30 secondes sans rebondir. Respire profondément, relâche à chaque expiration.")
   - `.generic` → renvoie `nil` (pas de tip).

10. **AC10** — Nouveau composant `Views/Components/SessionTipBubble.swift` :
    - `struct SessionTipBubble: View { let tip: LocalizedStringKey }`
    - Layout horizontal compact `HStack(alignment: .top, spacing: 10)` :
      - Avatar Léon : cercle 28×28, gradient or `linearGradient(.coachingAccent → .coachingAccent.opacity(0.7))`, lettre "L" en blanc, font `.caption.bold()`.
      - Texte : `Text(tip)` font `.footnote`, color `.primary`, line spacing 2.
    - Background `Color(uiColor: .tertiarySystemBackground)`, corner radius 8, padding 10.
    - Padding-top 6 dans la card exo (entre chips et bas de card).

11. **AC11** — Modification `Views/Components/SessionTimelineView.swift` :
    - `exerciseCard(_ ex: AdaptedExercise)` : après `metricsChipsRow(ex)`, insérer `SessionTipBubble(tip: tipKey)` si `SessionTipCatalog.tip(for: pattern, exerciseName: ex.name)` non-nil.
    - Pattern déjà résolu une fois dans la card (réutiliser le résultat de l'illustration).

### Partie (d) — Animations légères

12. **AC12** — ~~Matched-geometry transition entre dashboard et SessionDetailView~~ **SORTIE DU SCOPE Story 3.19 suite P1-3 review Plan**. Justification : zéro usage `@Namespace` dans la codebase actuelle, NavigationStack ne préserve pas naturellement le namespace entre destinations → effort réaliste 1.5-2j minimum (pas 0.5j comme initialement estimé), nécessite un spike d'architecture navigation. **Reporté Story 3.20** avec un sous-AC dédié.

13. **AC13** — Pulse découvrabilité glossaire (1ère visite SessionDetailView) :
    - Premier terme glossaire détecté reçoit un pulse `.scale(1.05).opacity(0.8)` répété 3 fois sur 1.5s, puis disparaît.
    - Triggered par `UserDefaults` flag `coaching.session.glossary.firstVisitDone` (réutiliser pattern existant Phase 1).
    - **Précédence avec SessionTipBubble (AC10) — P1-6 review Plan** : le pulse glossaire s'exécute **AVANT** que le SessionTipBubble apparaisse. Séquence : (1) ouverture vue → pulse 1.5s sur 1er terme glossaire → (2) fade-in tip Léon avec délai 1.8s. Empêche la collision visuelle (deux animations + deux signaux "Léon" concurrents) — testé manuellement sur `Squat poids du corps (pattern squat)` qui contient le terme glossaire "squat" tappable.
    - **Robustesse (P1 mineur review Plan 2e passage)** :
      - **VoiceOver actif** (`UIAccessibility.isVoiceOverRunning == true`) → **skip pulse + afficher tip immédiatement** (statiquement, sans animation). Sinon l'utilisateur VoiceOver entend le tip avant que l'annonce du pulse arrive, ordre cassé.
      - **Reduce Motion actif** (`@Environment(\.accessibilityReduceMotion) == true`) → idem, skip pulse + tip statique. Respecter la préférence accessibility.
      - **Lifecycle** : utiliser `.task { ... }` avec sleep `try await Task.sleep(for: .seconds(1.8))` plutôt que `DispatchQueue.main.asyncAfter` — le `.task` est annulé automatiquement si la vue disparaît (back rapide) → pas de fuite Timer ni de tip qui apparaît sur un écran déjà parti.
      - **Hors viewport** : si le tip apparaît après scroll et qu'il est hors écran, c'est OK — il reste affiché statiquement après son fade-in, l'utilisateur le verra au prochain scroll back.
    - **Optionnel** — si > 0.5j → couper, reporter Story 3.20 (mais le délai d'apparition tip reste à câbler).
    - **À clarifier au début du Jalon 4** (trou résiduel review Plan #3, 30 min) : `GlossaryRichText` apparaît à plusieurs endroits dans le scroll de SessionDetailView (hero theme + warmup text + card exo notes + cooldown text). **Décision recommandée V1** : le pulse cible le **premier terme glossaire de la première card exo dynamique** (celle qui contient aussi le SessionTipBubble). Le hero theme et le warmup sont exclus pour éviter que le pulse soit déjà passé hors viewport au scroll. Implémenter via un `EnvironmentKey` `IsFirstExerciseInTimeline: Bool` propagé depuis `SessionTimelineView` ou un `preference key` qui signale "j'ai pulsé".

### Partie (d-bis) — Dynamic Type (P2-4 review Plan)

13-bis. **AC13-bis** — `ExercisePatternIllustration` et `EffortGauge` et `SessionTipBubble` doivent **respecter Dynamic Type** :
   - `ExercisePatternIllustration` : clampé `.dynamicTypeSize(.medium...(.accessibility2))`. Au-delà, la grille rail+illustration de la timeline exploserait.
   - `EffortGauge` : barres scale avec `@Environment(\.sizeCategory)` minimal — soit fix-size soit clampé `.medium...(.xxxLarge)`.
   - `SessionTipBubble` : avatar Léon fix 28pt, texte respecte Dynamic Type sans clamp (lisibilité prioritaire).
   - Test manuel : ouvrir SessionDetailView avec Settings > Accessibility > Display & Text Size > Larger Text au max → vérifier qu'on ne casse pas le layout timeline.

### Partie (e) — Tests

14. **AC14** — `ExercisePatternResolverTests.swift` (≥25 tests — étendu suite review Plan 2e passage corpus 32 variantes) :
    - **Corpus templates COMPLET** (`grep -rohE '\(pattern [^)]+\)' Templates/References Templates/Sources/TemplateLoader/Resources/Templates/ | sort -u` → 32 variantes) : chaque variante testée pour mapping correct OU rejet justifié vers fallback.
      - `(pattern squat)` → `.squat` ✓
      - `(pattern squat unilatéral)` → `.squat` ✓
      - `(pattern hinge)` → `.hinge` ✓
      - `(pattern hinge hyp)` → `.hinge` ✓
      - `(pattern moteur asymétrique)` → `.core` ✓
      - `(pattern push horizontal)` → `.pushHorizontal` ✓
      - `(pattern push V)` / `(pattern push vertical)` → `.pushVertical` ✓
      - `(pattern pull H)` / `(pattern pull horizontal)` → `.pullHorizontal` ✓
      - `(pattern pull V)` / `(pattern pull vertical)` / `(pattern pull V hyp)` → `.pullVertical` ✓
      - `(pattern pull vertical — maintenu en cutback)` → `.pullVertical` ✓
      - `(pattern pull vertical — partie 1)` / `(pattern pull vertical — partie 2 du combo)` → `.pullVertical` ✓
      - `(pattern J1 / J3 / J5)` → tombe en fallback keyword/sport (PAS `.squat` accidentellement) — patterns hebdo correctement filtrés
      - `(pattern recommandé : J1 run / J2 repos / J3 strength / J4 repos / J5 run / J6-J7 repos)` → fallback ✓
      - `(pattern J1 / J3 / J5 / J7 ou J1 / J4 / J5 / J7 selon semaine)` → fallback ✓
      - **Variantes corpus Templates/References/ (13 additionnelles)** :
        - `(pattern lower)` → `.squat` (via table)
        - `(pattern squat + équilibre)` → `.squat`
        - `(pattern pull vertical alternatif)` → `.pullVertical`
        - `(pattern de complexité croissante)` → fallback (tactique)
        - `(pattern 'in-in-out-out')` → fallback (footwork)
        - `(pattern en 3 touches, piège croisé-couloir)` → fallback (tactique)
        - `(pattern W8 intentionnellement condensé)` → fallback (structure)
        - `(pattern J1 cardio / J3 renforcement / J5 cardio = respecté dans ce plan)` → fallback hebdo ✓
        - `(pattern J1/J3/J5 inchangé)` / `(pattern J1/J3/J5 recommandé)` → fallback hebdo ✓
        - `(pattern : J1 run / J2 force / J3 tempo / J4 repos / J5 VO2max / J6 repos / J7 long run)` → fallback hebdo ✓
        - `(pattern : J1 run / J2 force ou mobilité / J3 tempo / ...)` → fallback hebdo ✓
    - **Keyword match** (name sans `(pattern X)`) : "Romanian Deadlift" → `.hinge`, "Pull-up assisted" → `.pullVertical`, "Bent-over row" → `.pullHorizontal`, "Pompe diamant" → `.pushHorizontal`, "Overhead press haltères" → `.pushVertical`, "Plank latéral" → `.core`.
    - **Sport fallback** : `sportCode == "running"` + "Fractionné 8 × 400" → `.runInterval` ; + "Footing Z2" → `.runEndurance` ; + "Drills skipping" → `.runDrills`. `sportCode == "swimming"` + "Drill 6-3-6" → `.swimDrill`.
    - **Fallback ultime** : "Exo bidon" + `sportCode == "tennis"` → `.generic`.

15. **AC15** — `SessionTipCatalogTests.swift` (≥10 tests) :
    - Tous les patterns enumères ont une `tip` non-nil sauf `.generic`.
    - Smoke `LocalizedStringKey` existante dans xcstrings pour chaque pattern.
    - Tip strength `.squat` ≠ tip strength `.hinge` (pas de dédoublonnage accidentel).

16. **AC16** — `EffortGaugeTests.swift` (≥4 tests, snapshot ou inspect) :
    - `level=1` → 1 bar filled.
    - `level=5` → 5 bars filled.
    - `level=3` → 3 bars filled, 2 muted.
    - Clamp `level=99` → 5 bars filled (defensive).

17. **AC17** — `ExercisePatternIllustrationTests.swift` (≥3 tests) :
    - `.squat` → strip avec 3 frames.
    - `.core` → 1 frame + annotations.
    - `.generic` → EmptyView() (pas de rendu).

18. **AC18** — Couverture finale (P1-5 review Plan, maths corrigées) : `xcodebuild test -only-testing:CoachingSageTests` PASS, **597 existants + ≥32 nouveaux = ≥629 PASS** (≥15 resolver + ≥10 catalog + ≥4 gauge + ≥3 illustration = 32 plancher).

### Partie (f) — i18n

19. **AC19** — Toutes les nouvelles strings FR + EN dans `Resources/Localizable.xcstrings` :
    - 5 keys labels effort gauge (`coaching.effort.level.1` à `.5`).
    - **17 keys tips par pattern** (révisé suite P1-2 split push/pull H/V) : `coaching.tip.squat`, `.hinge`, `.pull.vertical`, `.pull.horizontal`, `.push.horizontal`, `.push.vertical`, `.core`, `.plyo`, `.lunge`, `.mobility`, `.run.endurance`, `.run.interval`, `.run.drills`, `.swim.endurance`, `.swim.drill`, `.cycle.endurance`, `.cycle.interval`.
    - 1 key fallback `coaching.tip.generic` (vide ou nil).
    - 1 key accessibility composée illu strip `coaching.session.exercise.illustration.a11y \(name) \(frameCount)`.
    - **Total : ~24 keys × 2 langues = ~48 strings.**

### Partie (g) — Build & non-régression

20. **AC20** — `mcp__xcode__BuildProject` ou `xcodebuild build` PASS sur destination `generic/platform=iOS Simulator`.

21. **AC21** — Scenario `ui_review_session_detail_v2` (Story 3.18) **étendu** ou nouveau `ui_review_session_detail_v3_illustrations` pour couvrir illustrations + jauge + tips sur 1 séance strength + 1 séance running + 1 séance swim. Lance via `SIMCTL_CHILD_UI_TEST_SCENARIO=ui_review_session_detail_v3_illustrations`.

22. **AC22** — Verdict `ui-reviewer` Bash auto Claude : READY 0 P0 + 0 P1 critique attendu sur FR + EN, validation visuelle des 3 sports (strength + running + swim).
   - **Critère bypass P1 (P1-5 review Plan)** : un P1 sur un sport **hors V1** (yoga, tennis, hiking, football, hiit autre que interval) → acceptable car ces sports tomberont nécessairement sur `.generic` (fallback SF Symbol sport). Documenter dans le rapport ui-reviewer "P1 = report Story 3.20" plutôt que bloquer le merge.
   - **P1 sur un sport V1** (running / cycling / swimming / strength training) → bloquant, à fixer avant merge.

## Hypothèses / Risques

- **Volume SVG à dessiner** : ~15 patterns × 2-3 frames = ~35-40 SVG SwiftUI Path à coder. C'est du dessin vectoriel ligne par ligne en `Path { ... .move ; .addLine ; ... }` — long mais mécanique. Risque : tomber dans le "ratage d'esthétique" malgré le mockup HTML validé. **Mitigation** : dessiner d'abord 4 patterns (squat / hinge / pull / core), faire un Cmd+R rapide, faire valider à Sophie un check intermédiaire avant de continuer.
- **Cohérence stylistique** : 35-40 SVG codés sur 3-4j → risque de drift visuel entre les premiers et les derniers. **Mitigation** : extraire un `IllustrationStyle.swift` constants (stroke width, corner radius, palette) utilisé partout.
- **Performance** : 4 exos × 3 frames = 12 SwiftUI Paths à render par session. Sur iPhone 12 ça passe largement (Path c'est du Core Animation). À tester sur device si doute.
- **i18n tips** : 15 tips × 2 langues = 30 strings courtes à valider. Risque pédagogique : un tip mal formulé peut induire en erreur (ex : "tibias verticaux sur le squat" est une erreur classique). **Mitigation** : sourcer chaque tip sur la doctrine publique (Israetel pour strength, Daniels pour run, Maglischo pour swim). Pas de prescription médicale (cf `epic3_leon_legal_constraints.md` — ne pas dire "tu dois", "concentre-toi sur" OK).
- **Resolver brittleness** : table de mapping multi-mots couvre les 19 variantes templates v2 actuelles (P0-1 review Plan, validé corpus). Mitigation : test obligatoire sur corpus templates (AC14) garantit 100% capture des patterns biomécaniques (les patterns hebdo `J1 / J3 / J5` tombent correctement en fallback). Si nouveau template ajoute une variante non couverte → `.generic` fallback gracieux + SF Symbol sport (pas de card vide). Logguer en dev `print("[Resolver] .generic for: \(name)")` pour monitorer.
- **Alternative architecturale P2-1** : enrichir `template.schema.json` avec un champ optionnel `movement_pattern: "squat" | "hinge" | ...` directement dans les exercises. Migration 1 fois = robustesse permanente, plus de regex. **Décision V1** : on garde regex multi-mots (effort ~0j vs migration ~1j retest des 40 templates). Si V2 ajoute des sports ou complique les patterns, basculer sur schema enrichi.
- **Effort estimation** : 8-10j sur 1 dev solo est large. Risque dépassement si pictos pénibles à dessiner. **Mitigation** : prioriser 10 patterns critiques V1 dans cet ordre Jalon 1 → Jalon 2a → Jalon 2b. Si pression temps en cours d'impl → couper Jalon 2b (sports périphériques tombent en `.generic` fallback SF Symbol, dégradation gracieuse). Sophie a souligné "qualité templates > vitesse" (mémoire `quality_over_speed_templates.md`) — même principe ici, mieux vaut livrer 10 illus parfaites que 17 médiocres.

## Out of scope (Story 3.20+)

- **HK target HR live overlay** pendant séance en cours (lecture FC instantanée, comparaison à zone cible).
- **Matched-geometry transition** Dashboard → SessionDetailView (P1-3 review Plan : effort réaliste 1.5-2j minimum, nécessite spike namespace partagé cross-NavigationStack). À spiker en Story 3.20 ou plus tard.
- **Animation continue** des pictos (boucle 2s du mouvement vs storyboard 3 frames).
- **GIF / vidéo** asset Supabase Storage.
- **Tips personnalisés par autoprofil utilisateur** (V2 : tip qui change selon level débutant/avancé).
- **Catalogue extensible utilisateur** (Pro : créer ses propres tips).
- **Confetti complétion** séance (déjà différé Story 3.18).
- **Sheet/popover "Échelle d'intensité"** au tap jauge (AC8 optionnel, peut être Story 3.20).
- **Schema template enrichi avec `movement_pattern` field** (P2-1 review Plan, alternative architecturale gardée dormante).

## Fichiers touchés (preview)

**Nouveaux :**
- `Coaching/Session/ExercisePattern.swift` — enum patterns supportés
- `Coaching/Session/ExercisePatternResolver.swift` — résolution name → pattern
- `Coaching/Session/SessionTipCatalog.swift` — catalogue tips par pattern
- `Views/Components/ExercisePatternIllustration.swift` — strip multi-frames
- `Views/Components/EffortGauge.swift` — bars 5 niveaux animée
- `Views/Components/SessionTipBubble.swift` — avatar Léon + tip
- `Views/Components/IllustrationStyle.swift` — constants stroke / palette
- `Views/Components/ExercisePatternGenericFallback.swift` — SF Symbol sport iOS 17 `.palette` multi-couleurs (P2-3)
- `Views/Components/Illustrations/SquatIllustration.swift` (3 frames)
- `Views/Components/Illustrations/HingeIllustration.swift` (3 frames)
- `Views/Components/Illustrations/PullVerticalIllustration.swift` (3 frames — pull-up/chin-up)
- `Views/Components/Illustrations/PullHorizontalIllustration.swift` (3 frames — row/rameur, **nouveau split P1-2**)
- `Views/Components/Illustrations/PushHorizontalIllustration.swift` (3 frames — pompe/bench)
- `Views/Components/Illustrations/PushVerticalIllustration.swift` (3 frames — overhead press, **nouveau split P1-2**)
- `Views/Components/Illustrations/LungeIllustration.swift` (3 frames)
- `Views/Components/Illustrations/CoreIllustration.swift` (1 frame + annotations)
- `Views/Components/Illustrations/PlyoIllustration.swift` (3 frames)
- `Views/Components/Illustrations/MobilityIllustration.swift` (1 frame + annotations)
- `Views/Components/Illustrations/RunEnduranceIllustration.swift` (3 frames)
- `Views/Components/Illustrations/RunIntervalIllustration.swift` (3 frames)
- `Views/Components/Illustrations/RunDrillsIllustration.swift` (1 frame + annotations)
- `Views/Components/Illustrations/SwimDrillIllustration.swift` (3 frames)
- `Views/Components/Illustrations/SwimEnduranceIllustration.swift` (3 frames)
- `Views/Components/Illustrations/CycleEnduranceIllustration.swift` (1 frame)
- `Views/Components/Illustrations/CycleIntervalIllustration.swift` (1 frame)
- `CoachingSageTests/Coaching/Session/ExercisePatternResolverTests.swift`
- `CoachingSageTests/Coaching/Session/SessionTipCatalogTests.swift`
- `CoachingSageTests/Views/Components/EffortGaugeTests.swift`
- `CoachingSageTests/Views/Components/ExercisePatternIllustrationTests.swift`

**Modifiés :**
- `Views/Components/SessionTimelineView.swift` — `exerciseCard()` ajoute illustration + tip (avec précédence pulse/tip AC13)
- `Views/Components/SessionHeroHeader.swift` — cellule intensité utilise `EffortGauge`
- `Coaching/Session/SessionStatsCalculator.swift` — ajoute `effortLevel(rpe:)` + `effortLabel(level:)`
- `App/UIReviewScenarioContainer.swift` — scenario `ui_review_session_detail_v3_illustrations` enrichi (strength + running + swim)
- `Resources/Localizable.xcstrings` — +~24 keys (5 effort labels + 17 tips + 1 a11y illu + 1 fallback = ~24 × 2 langues = ~48 strings)

**NON modifiés (confirmé suite P0-1 review Plan)** :
- `Utilities/Color+Coaching.swift` — **AUCUNE modification**, tous les tokens nécessaires existent déjà (`coachingSport(forCode:)`, `coachingEarth`, `coachingRecord`, `coachingWarning`, `coachingTextSecondary`)
- `Resources/Assets.xcassets/` — **aucune couleur custom à ajouter** (la codebase n'utilise pas d'asset catalog pour les couleurs, tout est en `Color(hex:)`)
- `Views/Screens/Coaching/SessionDetailView.swift` — matched-geometry sorti du scope (P1-3 reporté Story 3.20)

## Découpage de mise en œuvre suggéré (chronologie)

**Jalon 1 — Catalogue pattern + 4 illus de référence (~1.5-2j)**
- ExercisePattern enum (17 cases) + Resolver multi-mots + tests sur corpus templates v2 réel (20 tests)
- IllustrationStyle constants (stroke widths, palette tokens existants)
- ExercisePatternGenericFallback (SF Symbol sport iOS 17 `.palette`)
- 4 illustrations pilotes : Squat / Hinge / PullVertical / Core (sport strength)
- ExercisePatternIllustration view (strip + dynamic type clamp)
- Intégration dans SessionTimelineView (1 séance strength visible)
- **CHECK INTERMÉDIAIRE Sophie #1 : Cmd+R, valide le style visuel + lisibilité + palette avant de continuer**

**Jalon 2a — Sports principaux : 6 illus strength + 2 running (~1.5-2j)**
- PushHorizontal, PushVertical, PullHorizontal, Lunge, Plyo, Mobility (6 illus strength restantes)
- RunEndurance, RunInterval (2 illus running)
- Resolver keywords enrichis sport-spécifiques
- Test simu : séance strength + séance running fractionné
- **CHECK INTERMÉDIAIRE Sophie #2 : Cmd+R, drift visuel ? cohérence stylistique ?**

**Jalon 2b — Sports périphériques : 5 illus restantes (~1-1.5j) — BEST-EFFORT, COUPABLE**
- RunDrills, SwimDrill, SwimEndurance, CycleEndurance, CycleInterval
- Test simu : séance swim + séance cycle
- Couverture totale 17 patterns
- **Si pression temps détectée au check #2 (Sophie demande des retouches stylistiques Jalon 2a) → ce jalon est coupable**. Les sports sans illu V1 tomberont gracieusement sur `.generic` fallback SF Symbol sport (`ExercisePatternGenericFallback`). Critère bypass AC22 documenté.

**Jalon 3 — Jauge effort + Tip Léon (~2j)**
- EffortGauge view + animation + tests
- SessionStatsCalculator étendu effortLevel/effortLabel
- SessionHeroHeader cellule remplacée
- SessionTipCatalog (17 tips × 2 langues = 34 strings, **2 tips reformulés EU MDR**) + tests
- SessionTipBubble view (avatar Léon "L" or)
- Intégration card exo avec précédence pulse glossaire/tip (AC13)

**Jalon 4 — Polish + animations (~0.5-1j, partiellement optionnel)**
- Pulse découvrabilité glossaire (AC13, best-effort)
- ~~Matched-geometry hero~~ **reporté Story 3.20** (cf P1-3)
- Dynamic type pass sur les 3 nouveaux composants (AC13-bis)
- ui-reviewer Bash auto FR + EN

**Jalon 5 — Tests finaux + i18n + non-régression (~0.5j)**
- ≥32 tests cumulés, suite complète ≥629 PASS
- Verdict `ui-reviewer` READY 0 P0 + 0 P1 sport V1 (P1 sport non-V1 = OK report Story 3.20)
- Build PASS
- Merge main + push

Total : **~8-10j** selon performance dessin SVG (révisé après split push/pull H/V + check intermédiaire #2). Jalon 4 partiellement reportable Story 3.20 sans pénaliser le verdict story. Matched-geometry sorti du scope (P1-3) → Story 3.20.
