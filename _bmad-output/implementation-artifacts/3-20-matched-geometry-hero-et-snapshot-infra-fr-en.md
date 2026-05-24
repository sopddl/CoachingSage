# Story 3.20 — Matched-geometry hero Dashboard→SessionDetail + Snapshot infra FR/EN

Status: **ready-for-dev** (scopée 2026-05-24, décisions D1/D2/D3 figées par Sophie même jour suite à review critique)
Branche cible : `epic-3/story-3.20-matched-geometry-snapshot-infra`
Effort estimé : **~2j** (Partie A ~0.5j iOS 18 natif + Partie B ~1-1.5j snapshot infra Option B)
Phase précédente : Story 3.19 (illustrations + jauge + tip Léon) — mergée main `c10c2a8` 2026-05-24.

## Décisions figées Sophie 2026-05-24 (suite review critique)

- **D1 = Option B** — `.navigationTransition(.zoom)` iOS 18 natif. **Bumpe `IPHONEOS_DEPLOYMENT_TARGET` de 17.0 → 18.0** dans `project.yml` (6 occurrences lignes 5/6/50/117/140/210). Justification : Sophie pré-TestFlight, pas d'utilisateurs prod à protéger ; économise 1-1.5j vs Option A custom et évite le spike NavigationStack iOS 17 fragile. Override mémoire `architecture_decisions` ("iOS 17 min") à acter.
- **D2** — Non applicable (auto avec D1=B : `.matchedTransitionSource(id:in:)` prend l'élément entier).
- **D3 = Option B** — Snapshot infra étendue aux composants V1 critiques (`SessionHeroHeader`, `EffortGauge`, `SessionTipBubble`) en plus des 3 snapshots existants. Total ~20 snapshots FR/EN.
- **D4** — Pas de split (Partie A + B livrées en une seule story 3.20).

## Story

**As a** utilisatrice qui tape sur une séance dans le dashboard programme,
**I want** voir une transition fluide qui "zoome" depuis la card vers le hero détail (continuité visuelle), et **as a** dev qui ajoute une nouvelle vue sensible à la régression visuelle, **I want** un filet snapshot qui couvre FR ET EN sans dépendre du bundle Localizable runtime,
**so that** l'app paraisse premium au tap session et que je détecte un drift i18n (key non traduite, layout cassé sur string longue EN) sans relancer le simu en `-AppleLanguages '(en)'`.

## Contexte produit

Deux chantiers techniques indépendants reportés de Story 3.19, regroupés ici par cohérence "polish + filet régression" :

### Partie A — Matched-geometry transition Dashboard → SessionDetailView

- **Sorti scope Story 3.19** (AC12, mémoire `epic3_story319_done.md`). Justification P1-3 review Plan 3.19 : `@Namespace` n'est pas utilisé dans la codebase, `NavigationStack` ne préserve pas naturellement le namespace entre destinations sur iOS 17 → spike d'archi nav requis.
- **Maquette validée Sophie 2026-05-22** : `ux-design-CoachingSage-phase3-illustrations-exos-2026-05-22.html` mentionne explicitement une transition fluide depuis card → hero pour effet "premium card-to-detail".
- **Entrée actuelle nav** : `AdaptedProgramView.sessionRow:686-733` utilise `NavigationLink { SessionDetailView(...) } label: { card }`. Card contient `Image(systemName: sessionSymbol)` + texte + chevron, encapsulée dans `RoundedRectangle(cornerRadius: 10)` fond `.secondarySystemBackground`.
- **Cible hero** : `SessionHeroHeader.swift:45-80` rend un `Image(systemName: sportSymbol)` 30pt dans cercle `sportColor.opacity(0.18)` à gauche, nom séance à droite, fond `RoundedRectangle(cornerRadius: 14)` `sportColor.opacity(0.10)`.

### Partie B — Snapshot infra dédiée FR/EN

- **Limite documentée Story 3.19 Jalon 4** : `ExerciseTimelineCardSnapshotTests.swift:12-16` :
  > LocalizedStringKey n'est PAS résolue à FR dans le contexte UIHostingController de SnapshotTesting (Bundle.main locale non swizzlée). Les .strings keys apparaissent en raw dans les .png. […] Couverture traduction FR/EN visuelle = story snapshot-infra dédiée à venir.
- **Conséquence aujourd'hui** : les 3 snapshots existants (`runningInterval`, `runningInterval_first`, `substituted_strength`) capturent les keys raw `coaching.tip.run.interval` au lieu du texte traduit. Le filet régression layout/illustration/chips fonctionne, mais **un drift i18n** (clé renommée, traduction tronquée, EN plus long que FR qui casse une cellule) **n'est pas détecté**.
- **Pattern existant CL3** : aucun. À inventer côté CoachingSage. Peut servir de référence cross-app (GardenSage/TailorSage ont les mêmes limites).

## Pré-requis bump iOS — à faire en Jalon 0 (15min)

- Modifier `project.yml` lignes 5/6/50/117/140/210 : `iOS: "17.0"` / `deploymentTarget: "17.0"` / `IPHONEOS_DEPLOYMENT_TARGET: "17.0"` → `"18.0"`.
- `xcodegen generate`.
- BuildProject sanity check (aucun symbol iOS 18-only utilisé ailleurs → la suite existante doit compiler à l'identique).
- Mettre à jour mémoire `architecture_decisions` : "iOS 18 min depuis Story 3.20" (override "iOS 17 min" initial).
- **Note** : ce bump bénéficie à TOUTE la codebase — `.matchedTransitionSource` n'est qu'un cas d'usage. Sophie pourra utiliser autres APIs iOS 18 dans les stories suivantes (`@Observable` improvements, SwiftData @Default, etc.).

## Acceptance Criteria

### Partie A — Matched-geometry transition iOS 18 natif (D1=B figée)

1. **AC1** — `AdaptedProgramView.sessionRow:686-733` : ajouter `@Namespace private var heroNamespace` sur la vue parent (`AdaptedProgramView`). Sur la card (le `HStack` interne du label `NavigationLink`), ajouter `.matchedTransitionSource(id: "session-\(session.id)", in: heroNamespace)`. Aucun changement structurel (NavigationLink conservé), juste 2 lignes ajoutées.

2. **AC2** — `Views/Screens/Coaching/SessionDetailView.swift` : ajouter modificateur `.navigationTransition(.zoom(sourceID: "session-\(session.id)", in: heroNamespace))` sur la racine de la vue. Le `heroNamespace` est propagé depuis `AdaptedProgramView` via init param (`let heroNamespace: Namespace.ID`).

3. **AC3** — Propagation namespace dans la chaîne : `AdaptedProgramView.sessionRow` passe `heroNamespace` au `SessionDetailView(...)` instancié dans le `NavigationLink {}`. Aucun `Environment` custom, propagation explicite via init (plus simple à tracer).

4. **AC4** — **Fallback gracieux** : `SessionDetailView` accepte `heroNamespace: Namespace.ID?` (Optional). Si nil (Preview, scenario UI test, autre entry point) → pas de `.navigationTransition` appliqué, transition stock NavigationStack push. Implémenté via `.modifier(ConditionalZoomTransition(sourceID: ..., namespace: heroNamespace))` ou `if let ns = heroNamespace { view.navigationTransition(.zoom(...)) } else { view }`. Aucune régression sur les autres entry points.

5. **AC5** — **Accessibilité** : `.accessibilityElement(children: .combine)` sur la card source pour que VoiceOver annonce "Séance N de la semaine M, durée X min, double-tap pour ouvrir le détail". Pas d'annonce custom de l'animation (réservé visuel — `.navigationTransition(.zoom)` est compatible Reduce Motion nativement, Apple bascule sur cross-dissolve si Reduce Motion actif).

### Partie B — Snapshot infra bundle swizzle

6. **AC6** — Nouveau `CoachingSageTests/TestSupport/LocalizedSnapshotting.swift` :
   - `enum SnapshotLocale: String { case fr, en }`
   - `func withLocale<T>(_ locale: SnapshotLocale, _ body: () throws -> T) rethrows -> T` : pendant l'exécution du closure, swizzle `Bundle.main.localizations` ET la résolution `String(localized:)` via :
     - Approche 1 (recommandée) : injecter un `Bundle` custom dont le `path(forResource:ofType:inDirectory:)` retourne le chemin `.lproj/fr` ou `.lproj/en` du test bundle. Mécanisme : objc_setAssociatedObject + method_exchangeImplementations sur `Bundle.localizedString(forKey:value:table:)` (pattern éprouvé Pointfree / KIF).
     - Approche 2 (fallback) : passer `bundle: Bundle.module` (ou bundle explicite) à toutes les `Text("key")` via `LocalizedStringResource(_:locale:bundle:)` iOS 17+. Plus propre mais nécessite refactor de **chaque** appel `Text` dans les composants snapshottés. Décision : approche 1 sauf si Sophie veut éviter swizzling.

7. **AC7** — Helper test :
   ```swift
   func assertSnapshotLocalized<V: View>(
       of view: V,
       as snapshotting: Snapshotting<V, UIImage>,
       locales: [SnapshotLocale] = [.fr, .en],
       file: StaticString = #file, testName: String = #function, line: UInt = #line
   )
   ```
   Pour chaque locale, switch bundle + appelle `assertSnapshot` avec suffixe `_fr` ou `_en` dans `testName`. Cleanup garantie via `defer` même si assert échoue.

8. **AC8** — Migration des 3 snapshots existants `ExerciseTimelineCardSnapshotTests.swift` vers `assertSnapshotLocalized` :
   - `testCardStableState_running` → génère `testCardStableState_running.1_fr.png` + `testCardStableState_running.2_en.png` (ou suffixe pointfree natif si dispo).
   - Idem `testCardFirstExercise_postPulseDone_running` + `testCardSubstituted_strength`.
   - **Suppression des anciens .png FR-only** sous `__Snapshots__/ExerciseTimelineCardSnapshotTests/`, regénération en mode record sur première run.

9. **AC9** — **D3=B figée** : nouveaux fichiers snapshot pour composants critiques :
   - `SessionHeroHeaderSnapshotTests.swift` (fixture 1 séance strength + 1 running, 2 locales × 2 fixtures = 4 snapshots)
   - `EffortGaugeSnapshotTests.swift` (level 1, 3, 5 × 2 locales = 6 snapshots — locale impacte le `accessibilityLabel` seulement, mais ça reste un sanity check)
   - `SessionTipBubbleSnapshotTests.swift` (tip squat + tip run.interval × 2 locales = 4 snapshots)

### Partie C — Build, tests, non-régression

10. **AC10** — `xcodebuild test -only-testing:CoachingSageTests` PASS. Suite cumulée : **702 existants** (Story 3.19) **+ snapshots Story 3.20** (3 anciens × 2 locales = 6 + nouveaux AC9 = +14) = **712 PASS** minimum.

11. **AC11** — `mcp__xcode__BuildProject` PASS destination `generic/platform=iOS Simulator`. Aucun warning matched-geometry runtime ("ambiguous namespace") ni snapshot record laissé actif en CI.

12. **AC12** — Test manuel simu Partie A (Cmd+R) :
    - Ouvrir dashboard → tap session → vérifier zoom icône fluide (vs jump instantané actuel).
    - Back → vérifier reverse animation symétrique.
    - 3 sports : strength + running + triathlon (pour valider que `effectiveSportCode` ne casse pas le namespace cross-sport).
    - VoiceOver actif → vérifier annonce card correcte sans interférence anim.

13. **AC13** — Verdict `ui-reviewer` Bash auto : READY 0 P0 + 0 P1 sur le scenario `ui_review_adapter_preview` (scenario existant Story 3.15 qui couvre dashboard → SessionDetailView).

## Out of scope (Story 3.21+)

- **HK target HR live overlay** pendant séance en cours (lecture FC instantanée, comparaison à zone cible) — sorti scope Story 3.19, toujours pertinent pour 3.21+.
- **Sheet/popover "Échelle d'intensité"** au tap EffortGauge hero (AC8 optionnel 3.19) — décision report : pas critique, EffortGauge déjà self-explicative + accessibilityLabel détaillé. Reprendre seulement si feedback user.
- **Snapshot infra extensive (option D3-C)** : 20+ snapshots dashboards + carrousel. À considérer Story 3.22+ si la suite minimale Option B révèle des régressions cachées.
- **Animation hero confettis complétion séance** (différé depuis Story 3.18) — toujours backlog.
- **Schema template enrichi avec `movement_pattern` field** (P2-1 review Plan 3.19) — décision V1 maintenue (regex multi-mots couvre 32 variantes corpus).

## Hypothèses / Risques

- **Risque #1 (Partie A) — résolu par D1=B** : bump iOS 18 supprime le besoin de spike NavigationStack iOS 17. `.navigationTransition(.zoom)` est Apple-natif, robuste, supporte Reduce Motion. Risque résiduel limité : vérifier que `heroNamespace` se propage proprement entre `AdaptedProgramView` et `SessionDetailView` (1 paramètre init, traçable).
- **Risque #2 (Partie B) — Method swizzling Bundle fragile** : `method_exchangeImplementations` sur `Bundle.localizedString` est connu pour casser entre versions iOS (a fonctionné iOS 13→16, à valider iOS 17/18). Si approche 1 échoue → bascule approche 2 (refactor `LocalizedStringResource(_:bundle:)`) qui touche plus de fichiers mais est garantie. Mitigation : valider swizzling en POC 30min avant de coder l'API publique helper.
- **Risque #3 — Drift snapshot CI vs local** : sub-pixel antialiasing varie entre Mac dev et runner CI (Xcode Cloud). Mitigation déjà appliquée Story 3.19 (`perceptualPrecision: 0.97`) — étendre à tous les nouveaux snapshots.
- **Risque #4 — `withLocale` non thread-safe** : si XCTest tourne en parallèle et 2 tests touchent le bundle simultanément → corruption locale. Mitigation : forcer `parallelizable = false` sur la suite snapshot tests (cohérent avec règle globale UI tests OFF — mémoire CLAUDE.md), ou wrapper dans un actor/dispatch queue serial. Vérifier `CoachingSageTests.xcscheme` `parallelizable` setting.
- **Risque #5 — bump iOS 17→18** : aucun symbol iOS 17-only ne devrait être affecté (codebase déjà en SwiftUI moderne), mais une compile-time check post-bump est obligatoire (Jalon 0). Si une feature iOS 17-only se révèle utilisée → fix au cas par cas. Vérifier aussi que les libs externes (Supabase, swift-snapshot-testing 1.17.0) supportent iOS 18 (oui, à jour 2026).

## Fichiers touchés (preview)

**Pré-requis bump iOS :**
- `project.yml` lignes 5/6/50/117/140/210 — `17.0` → `18.0`
- Régénération `xcodegen generate`

**Partie A — Matched-geometry iOS 18 natif :**

Nouveaux : aucun (API Apple native, pas d'infra custom à créer).

Modifiés :
- `Views/Screens/Coaching/AdaptedProgramView.swift:686-733` — `@Namespace var heroNamespace` + `.matchedTransitionSource` sur card session, propagation namespace vers `SessionDetailView` via init
- `Views/Screens/Coaching/SessionDetailView.swift` — accepte `heroNamespace: Namespace.ID?` en init, applique `.navigationTransition(.zoom(sourceID:in:))` sur racine si non-nil

**Partie B — Snapshot infra :**

Nouveaux :
- `CoachingSageTests/TestSupport/LocalizedSnapshotting.swift` — `SnapshotLocale` + `withLocale` + `assertSnapshotLocalized`
- (Si AC9) `CoachingSageTests/Views/Components/SessionHeroHeaderSnapshotTests.swift`
- (Si AC9) `CoachingSageTests/Views/Components/EffortGaugeSnapshotTests.swift`
- (Si AC9) `CoachingSageTests/Views/Components/SessionTipBubbleSnapshotTests.swift`

Modifiés :
- `CoachingSageTests/Views/Components/ExerciseTimelineCardSnapshotTests.swift` — migration `assertSnapshot` → `assertSnapshotLocalized`, suppression commentaires "limite locale"
- `CoachingSageTests/Views/Components/__Snapshots__/ExerciseTimelineCardSnapshotTests/*.png` — regénération en mode record (PR review : visuel diff FR vs EN attendu)

**Modif scheme (si Risque #4 confirmé) :**
- `project.yml` ou `CoachingSageTests.xcscheme` — `parallelizable = false` sur suite snapshot

## Découpage de mise en œuvre suggéré (chronologie)

**Jalon 0 — Bump iOS 17→18 (~15min)**
- Edit project.yml 6 occurrences + `xcodegen generate`
- BuildProject PASS sanity check (suite existante doit compiler à l'identique)
- Update mémoire `architecture_decisions` ("iOS 18 min depuis Story 3.20")

**Jalon 1 — Implémentation Partie A iOS 18 natif (~0.5j)**
- `@Namespace var heroNamespace` dans `AdaptedProgramView`
- `.matchedTransitionSource` sur card session (sessionRow)
- Propagation namespace `SessionDetailView` via init param
- `.navigationTransition(.zoom)` sur racine SessionDetailView (conditionnel sur heroNamespace non-nil)
- Test manuel Cmd+R 3 sports (strength / running / triathlon) + Reduce Motion ON (fallback cross-dissolve attendu)
- ui-reviewer scenario `ui_review_adapter_preview`

**Jalon 2 — Snapshot infra Partie B (~1-1.5j)**
- POC swizzling Bundle 30min (approche 1 method_exchangeImplementations) → décider approche 1 vs 2
- `LocalizedSnapshotting.swift` + helper `assertSnapshotLocalized`
- Migration 3 snapshots existants vers FR + EN
- 3 nouveaux fichiers snapshot composants V1 (D3=B) : SessionHeroHeader + EffortGauge + SessionTipBubble
- Vérif `parallelizable=false` sur suite snapshot (Risque #4)
- Régénération .png en record, validation visuelle PR diff

**Jalon 3 — Build + tests + push (~0.3j)**
- Suite test cumulée ≥712 PASS
- BuildProject PASS
- Verdict ui-reviewer READY 0 P0
- Merge main + push

Total : **~2j** sur 1 dev solo (économie 1j vs scope initial grâce à D1=B iOS 18 natif).

## Suivi attendu Sophie

- Validation post-Jalon 0 : confirmer que le bump iOS 18 n'a rien cassé dans la suite existante (BuildProject sanity).
- Check intermédiaire post-Jalon 1 : Cmd+R test manuel transition zoom (validation visuelle subjective, c'est du polish).
- Validation finale : test simu Cmd+R global + ui-reviewer READY avant merge main.
