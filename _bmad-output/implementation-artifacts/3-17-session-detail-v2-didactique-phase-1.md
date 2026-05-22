# Story 3.17 — SessionDetail v2 didactique — Phase 1 : Fondations glossaire

Status: **code-complete, pending test visuel Sophie** (livré 2026-05-22 sur branche `epic-3/story-3.17-glossary-foundations` commit `1df30b3`)
Branche cible : `epic-3/story-3.17-glossary-foundations`
Effort estimé : **~3-4j** (Phase 1 seule ; Phases 2 et 3 stories suivantes)

## Story

**As a** utilisatrice qui découvre l'app et tombe sur des termes techniques (RPE, Daniels-T, FTP-Z2, Cadence, Tempo, Intervals, Threshold, VO2max…) sans savoir ce qu'ils veulent dire,
**I want** comprendre chaque terme directement depuis la séance, sans quitter l'écran ni googler,
**so that** je puisse exécuter la séance en confiance et apprendre le vocabulaire progressivement.

## Contexte produit

- **Chantier V2 #1** identifié au test simu Sophie 2026-05-11 (mémoire `v2_chantiers_pedagogie_simu_2026_05_11.md`) : *"glossaire termes (RPE/Z2/Daniels…)"*. Test simu story sœur post-onboarding révèle que le jargon technique des séances est opaque pour un débutant.
- **État existant** :
  - `Coaching/Glossary/Glossary.swift` : 18 entrées glossaire (RPE, Daniels E/M/T/I/R, VDOT, Zones FC, EN1-3, CSS, FTP, Sweet-Spot, AMRAP, EMOM, Tabata, HMP, %1RM, race.pace). API `Glossary.entry(forZone: String?)` matche **un** terme complet passé en argument.
  - `Views/Components/GlossaryTermBadge.swift` : chip tappable rendant **un** terme avec icône info.circle, popover définition. Fallback texte plat si terme inconnu.
  - `Views/Screens/Coaching/SessionDetailView.swift:385-392` : `glossaryChip(zone)` câblé **uniquement** sur `AdaptedExercise.targetZone`. Les `notes`, `warmup`, `cooldown`, `week.theme` sont rendus en `Text(verbatim:)` plat — aucun terme tappable.
  - 36 keys i18n `glossary.*.title` / `glossary.*.definition` FR + EN dans `Resources/Localizable.xcstrings`.
- **Audit templates** (90 templates actifs `Templates/References/{revised,raw-v2}/*.json`) — top termes opaques NON couverts par le glossaire actuel : **cadence** (1033 occ), **interval/intervals** générique (836), **tempo** générique (441), **strides** (343), **VO2/VO2max** (304), **threshold** générique (182), **plyo/plyometric** (189), **fartlek** (93), **hypertrophy** (54), **lactate** (26), **push-off** (12), **negative split** (5).

## Décision Sophie 2026-05-22 (à figer)

1. **Phase 1 = fondations didactiques uniquement.** Pas de refonte visuelle SessionDetailView (header, timeline, hero) — Phase 2. Pas d'illustrations / jauges / animations — Phase 3.
2. **Couverture étendue** : auto-detect glossaire **partout** dans SessionDetailView (notes exercices, warmup, cooldown, thème semaine), pas que sur `targetZone`.
3. **Découvrabilité** : tooltip d'onboarding 1ère ouverture SessionDetailView pour signaler que les mots soulignés sont tappables. Auto-dismiss, persisté en UserDefaults.
4. **+11 nouveaux termes glossaire** sourcés depuis l'audit templates (cf §AC6).
5. **Pas de refactor structurel** de l'API existante (`Glossary.entry(forZone:)` + `GlossaryTermBadge` conservés tels quels pour rétrocompat — chip targetZone continue d'utiliser le pattern actuel).

## Acceptance Criteria

### Partie (a) — Moteur matching multi-occurrences

1. **AC1** — Nouvelle API `Glossary.matches(in text: String) -> [GlossaryMatch]` :
   - Struct `GlossaryMatch { range: Range<String.Index>, entry: GlossaryEntry, matchedSubstring: String }`.
   - Détection **case-insensitive** mais préserve la casse originale dans `matchedSubstring`.
   - Non-overlapping : si "Daniels-Tempo" matche `daniels.t` ET `tempo`, ne renvoie qu'un seul match (priorité longest-first, puis order-of-appearance).
   - Word-boundary aware : "rpe" matche dans "RPE 7-8" et "rpe:" mais PAS dans "scrapped" ou "supercrepe".
   - Performance < 1ms pour un texte de 500 chars (mesuré par test perf).

2. **AC2** — Priorité matching :
   - Sport-specific avant générique : "Daniels-T" matche `daniels.t`, pas `tempo` ni `threshold`.
   - Acronymes 2-letters (`Z2`, `EN1`) matchent seulement comme tokens (entourés de boundaries non-alphanum).
   - L'API existante `Glossary.entry(forZone:)` reste **inchangée** (utilisée par GlossaryTermBadge legacy).

### Partie (b) — Rendu inline

3. **AC3** — Nouveau composant `GlossaryRichText(text: String, font: Font = .footnote)` rendant un texte avec termes soulignés tappables :
   - Termes matchés rendus avec `.underline(pattern: .dot, color: Color.coachingPrimary)` + couleur primary.
   - Tap sur un terme → popover (iOS) ou sheet (compact) avec définition (réutilise `GlossaryDefinitionPopover` interne, à promouvoir public ou extraire).
   - Implémentation : `AttributedString` avec `.link(URL)` custom scheme `coaching-glossary://term/{id}` + handler `OpenURLAction` qui présente le popover en interceptant l'URL (ne pas ouvrir Safari).
   - Pas de match = `Text(verbatim:)` plat identique à avant (zéro régression visuelle).
   - Multilinéaire : termes peuvent wrapper sur plusieurs lignes sans casser le tap (responsabilité SwiftUI native AttributedString).

4. **AC4** — Accessibilité :
   - Termes tappables annoncés VoiceOver comme "RPE, bouton, double-tap pour définition".
   - Tooltip découvrabilité (AC7) accessible via `accessibilityLabel`.

### Partie (c) — Intégration SessionDetailView

5. **AC5** — `Views/Screens/Coaching/SessionDetailView.swift` modifié :
   - `exerciseRow(_:)` → `notes` rendu via `GlossaryRichText` au lieu de `Text(verbatim: notes)`.
   - `phaseBlock` (warmup, cooldown) → `text` rendu via `GlossaryRichText`.
   - `header` → `week.theme` rendu via `GlossaryRichText`.
   - `regenAdjustedBanner` body : pas changé (textes i18n contrôlés, pas de terme tech).
   - `targetZone` chip continue d'utiliser `GlossaryTermBadge` (rétrocompat).

### Partie (d) — Couverture glossaire étendue

6. **AC6** — 11 nouveaux termes ajoutés à `Glossary.entries` avec keys i18n FR + EN sourcées :
   - `cadence` — fréquence pas (run) / pédales (cycle) / cycles bras (swim). Définition contextuelle multi-sport.
   - `tempo` (générique) — allure soutenue, "comfortable but firm", entre endurance et seuil.
   - `threshold` (générique) — seuil lactique, intensité à la limite du soutenable longtemps.
   - `vo2max` — capacité aérobie maximale, ciblée par Daniels-I / Tabata / FTP-Z5.
   - `intervals` (générique) — méthode d'entraînement par blocs effort/récupération alternés.
   - `strides` — accélérations courtes 80-100m post-warmup, technique de course.
   - `fartlek` — "jeu d'allures" suédois, variation libre de l'intensité.
   - `plyometric` — exercices d'explosivité (sauts, bondissements) développant la puissance.
   - `hypertrophy` — entraînement orienté volume musculaire (8-12 reps, ~60-75% 1RM).
   - `lactate` — substance produite à effort intense, accumulation = fatigue (lié threshold/seuil).
   - `push-off` — poussée du mur en natation (~5-8m gratuits), fausse les pace lap-by-lap.
   - **+ keys détecteur** dans `Glossary.matches`: matche "cadence", "tempo", "threshold", "vo2 max" / "vo2max", "intervals", "strides", "stride", "fartlek", "plyo", "plyometric", "plyometrics", "hypertrophy", "hypertrophic", "lactate", "lactic", "push-off", "push off".
   - Définitions courtes (1-2 phrases) sourcées sur doctrine validée (run: Daniels ; cycle: TrainingPeaks ; swim: Maglischo/Sweetwater ; strength: Schoenfeld).

### Partie (e) — Onboarding découvrabilité

7. **AC7** — Tooltip 1ère ouverture SessionDetailView :
   - Composant `GlossaryDiscoveryTooltip` overlay non-bloquant, ancré sur le 1er terme glossaire visible OR en bas d'écran si aucun visible (fallback safe area bottom).
   - Texte i18n FR : *"💡 Astuce : tape les mots soulignés pour leur définition"*. EN : *"💡 Tip: tap underlined words for their definition"*.
   - Auto-dismiss après : 1er tap utilisateur OR scroll OR 6 secondes OR background app.
   - `UserDefaults` key `glossary.discovery.tooltip.shown` (Bool). Une fois `true`, ne ré-affiche jamais.
   - Animation : fade-in 0.3s avec slide-up subtil. Pas de blur backdrop ni full overlay.
   - Skip en UI testing (`UI_TEST_SCENARIO != nil`) pour ne pas casser snapshots/tests.

### Partie (f) — Tests

8. **AC8** — `CoachingSageTests/Coaching/Glossary/GlossaryMatcherTests.swift` (≥15 tests) :
   - Cas vide / nil → `[]`.
   - Match unique simple : "RPE 7-8" → 1 match `rpe`.
   - Match multiple ordonnés : "Tempo en Z2 puis intervals" → 3 matches dans l'ordre.
   - Case-insensitive : "RPE", "rpe", "Rpe" → tous matchent `rpe`.
   - Word boundary respect : "scrappy" ne matche pas `rpe`.
   - Overlap longest-first : "Daniels-T pace" matche `daniels.t`, PAS `tempo` ni `threshold`.
   - Préserve casse originale dans `matchedSubstring`.
   - Acronymes Z1-Z5 : "Z2-cardiac" matche `zones`, "ZZ" ne matche pas.
   - Termes Phase 1 (8 nouveaux) chacun testé au moins 1 fois.
   - Performance smoke test : 500 chars < 1ms.

9. **AC9** — `GlossaryRichTextTests` : pas de snapshot (fragile attributed string). Test logique simple :
   - Compose AttributedString attendu pour input connu → check via inspect (Compose AttributedString test, vérifier `runs` count et attributs).

10. **AC10** — `GlossaryDiscoveryTooltipTests` (≥3 tests) :
    - 1ère ouverture : UserDefaults absent → tooltip présenté.
    - 2ème ouverture : UserDefaults `true` → tooltip absent.
    - Auto-dismiss timer 6s → tooltip masqué + UserDefaults persisté.
    - Skip UI test scenario : `UI_TEST_SCENARIO=foo` → tooltip absent.

11. **AC11** — Couverture finale : `xcodebuild test -only-testing:CoachingSageTests` PASS, **528 tests existants + ~20 nouveaux = ~548 PASS**.

### Partie (g) — i18n

12. **AC12** — Toutes les nouvelles strings FR + EN dans `Resources/Localizable.xcstrings` :
    - 16 keys glossaire (8 termes × 2 keys title/definition).
    - 1 key tooltip découvrabilité.
    - `LanguageManager` switch FR↔EN re-rend les définitions correctement.

### Partie (h) — Build & non-régression

13. **AC13** — `mcp__xcode__BuildProject` ou `xcodebuild build` PASS sur destination `generic/platform=iOS Simulator`.

14. **AC14** — `SessionDetailView` simu : ouvrir une séance running W1 J1 → notes contiennent "tempo" → souligné pointillé → tap → popover définition tempo en FR. Switch EN → re-tap → définition EN.

15. **AC15** — Rétrocompat : chip `targetZone` continue d'afficher l'icône info.circle + popover comme avant (zero régression sur GlossaryTermBadge).

## Hypothèses / Risques

- **Performance AttributedString tappable** : iOS 17 supporte `AttributedString` avec `.link` interceptable via `OpenURLAction`. Smoke test à mesurer (un long warmup pédagogique = ~500 chars max).
- **Découvrabilité tooltip "intrusif"** : on mitigate avec auto-dismiss multiple triggers + animation subtile + une seule fois.
- **Conflit naming "tempo" vs "Daniels-T"** : décision = priorité longest-first dans le matcher (Daniels-T avant tempo). Les templates running utilisant "Daniels-T pace" matchent Daniels-T ; ceux utilisant "tempo continu 30 min" matchent tempo générique. ✓
- **Termes apparaissant dans plusieurs sports avec sens différents** (cadence = pas vs rpm vs cycles bras) : 1 entrée glossaire avec définition multi-sport mentionnant les 3 contextes. Pas de variant sport-specific en Phase 1.

## Out of scope (Phase 2 / Phase 3)

- **Phase 2** (~3-4j) : Hero header riche (couleur sport + illustration + stats grille), "Pourquoi cette séance ?" panel expandable, timeline visuelle warmup→exos→cooldown.
- **Phase 3** (~3j) : Illustrations exos (SF Symbols enrichis V1), jauge effort 5 niveaux, tip Léon par bloc, animations (pulse découvrabilité, spring tap, confetti complétion, matched geometry transition).

## Fichiers touchés (preview)

**Nouveaux :**
- `Coaching/Glossary/GlossaryMatcher.swift` — moteur `Glossary.matches(in:)`
- `Views/Components/GlossaryRichText.swift` — rendu AttributedString tappable
- `Views/Components/GlossaryDiscoveryTooltip.swift` — tooltip 1ère ouverture
- `CoachingSageTests/Coaching/Glossary/GlossaryMatcherTests.swift`
- `CoachingSageTests/Views/Components/GlossaryDiscoveryTooltipTests.swift` (optionnel si UserDefaults injectable)

**Modifiés :**
- `Coaching/Glossary/Glossary.swift` — +8 entrées
- `Views/Screens/Coaching/SessionDetailView.swift` — remplace Text par GlossaryRichText sur notes/warmup/cooldown/theme + intègre tooltip
- `Resources/Localizable.xcstrings` — +23 keys (11×2 glossaire + 1 tooltip)

## Dette ouverte — test visuel ui-reviewer

**Skippé côté Claude 2026-05-22** (Sophie en WE, MCP prompts invisibles cf
`feedback_mcp_prompts_invisible.md`). À valider par Sophie au retour :

1. Lancer scenario `ui_review_session_detail_glossary` sur simu en FR puis EN :
   ```
   SIMCTL_CHILD_UI_TEST_SCENARIO=ui_review_session_detail_glossary \
     xcrun simctl launch <udid> com.sopddl.coachingsage.app \
     -AppleLanguages '(fr)' -AppleLocale fr_FR
   ```
2. Vérifications :
   - Tooltip toast bottom visible 1ère ouverture (texte i18n FR/EN).
   - Tap tooltip → dismiss + persistance UserDefaults.
   - Termes soulignés pointillés couleur primary visibles dans warmup +
     notes exos + cooldown + thème semaine (≥ 8 termes distincts).
   - Tap sur un terme → sheet popover avec titre + définition correctes.
   - Switch FR↔EN → re-rend les définitions dans la bonne langue.
   - `targetZone` chip continue d'afficher l'info.circle (rétrocompat AC15).
   - Pas de régression visuelle ailleurs (header, regen banner, complétion).
3. Si findings P0/P1 : fix sur la branche, recommit, relancer le test.

## Décisions Sophie 2026-05-22 (figées)

1. **Style visuel** : (A) Underline pointillé + couleur primary `.coachingPrimary` (`.underline(pattern: .dot)`).
2. **Tooltip découvrabilité** : (A) Toast bottom subtil non-modal, auto-dismiss multiple triggers.
3. **Liste +11 termes** : `cadence`, `tempo`, `threshold`, `vo2max`, `intervals`, `strides`, `fartlek`, `plyometric` + bonus `hypertrophy`, `lactate`, `push-off`.
4. **Numéro story** : 3.17 standalone (Phase 2 = Story 3.18, Phase 3 = Story 3.19 ensuite).
