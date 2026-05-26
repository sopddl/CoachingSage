# Story 3.24 — Pédagogie pas-à-pas (glossaire complet + explication par exo)

> **🔄 RÉDUCTION POST-SCOPING Sophie 2026-05-24** : La sous-story 3.24c (mode workout exécution guidé) initialement scopée ici a été **absorbée dans Story 3.22 (Sujet D)** car elle relève du flux séance complet. Cette story reste avec **3.24a (glossaire) + 3.24b (explication par exo)** uniquement. La section 3.24c est conservée en référence croisée mais ne sera PAS livrée ici.

Status: **ready-for-review**
Branche cible suggérée : 2 branches indépendantes — `epic-3/story-3.24a-glossary-strength-completion`, `epic-3/story-3.24b-exercise-per-exo-explanation`
Effort estimé total réduit : **~3-4.5j** (2 sous-stories ; 3.24a quick win ~1-1.5j, 3.24b ~2-3j)
Stories antécédentes : 3.17 (glossaire fondations, mergée) · 3.18 (hero + timeline, mergée) · 3.19 (illustrations + tip Léon, mergée `c10c2a8`)
Stories parallèles : 3.21 différé backlog, 3.22 (flux UX complet inc. mode guidé absorbé 3.24c), 3.23 (qualité illustrations)

**Cross-ref importante** : la sous-story **3.24b (explication par exo) DOIT être livrée AVANT le Sujet D de Story 3.22 (mode guidé)** car le mode guidé consomme `ExerciseExplanationService` créé en 3.24b. Fallback gracieux sinon (tip pattern).

## Story

**As a** utilisatrice débutante qui ouvre une séance strength fraîchement adaptée et tombe sur "Band pull apart × 10 reps", "Scapular CARs", "Cat-cow 8 reps", "Ramp up bench RIR 3, barre vide" sans savoir ce que la moitié des mots veulent dire,
**I want** (a) avoir TOUS les termes techniques de la séance compris en 1 tap glossaire, (b) avoir une explication "comment exécuter" précise pour CHAQUE exo (pas juste un tip générique par pattern),
**so that** je peux préparer mentalement la séance sans Googler, sans demander à un proche.

## Contexte produit + preuves test simu 2026-05-24

Test simu Sophie 2026-05-24 sur une séance strength → **la promesse pédagogique des Stories 3.17/3.18/3.19 ne tient pas en exécution réelle**.

Sophie verbatim : *"il faut que tu expliques chaque exo... je pense qu'il faut qu'on fasse un truc où on ait une liste avec la possibilité d'avoir le détail pas à pas ou pas avec un vrai flux utilisateur"*

**Termes jargon non glossariés remontés sur 1 seule séance (échauffement + 1er exo)** :
- `band pull apart` · `dislocations élastique` · `scapular CARs` · `mobilité thoracique`
- `cat-cow` (version strength, différent du cat-cow yoga !)
- `10 reps` (Sophie ne sait pas que reps = répétitions)
- `ramp up bench` · `barre vide` · `RIR` (Reps In Reserve)

**Validation corpus** (audit `grep -rohE` sur `Templates/References/**/*.json`) :
- `RIR` apparaît **massivement** dans `safety_notes` et `notes` exos
- `CARs` documentés dans templates tennis et hiit
- `cat-cow X reps` présent dans templates triathlon-beginner et recreational
- `band pull apart`, `scapular`, `mobilité thoracique` présents corpus strength

→ Le contenu produit lui-même emploie ces termes — les ajouter au glossaire n'est pas optionnel.

**État existant (post Story 3.19 mergée)** :
- `Coaching/Glossary/Glossary.swift` : **31 entrées** (RPE, 1RM, Daniels E-R, VDOT, Z1-5, EN1-3, CSS, FTP, etc.)
- `Coaching/Glossary/GlossaryMatcher.swift` : moteur multi-occurrences `matches(in:)`, table `detectionPatterns` longest-first, word-boundary-aware. **Extensible : ajouter une ligne au tableau pour matcher un nouveau terme.**
- `Coaching/Session/SessionTipCatalog.swift` : **1 tip × 18 patterns biomécaniques**. Pas par exo — DB bench press et bench barre partagent le même tip "pushHorizontal".
- `Coaching/Adapter/AdaptedProgram.swift:115` : `AdaptedExercise { name, originalName, sets, reps, duration, restSeconds, notes, targetZone, volumeAxis, wasSubstituted }` — **PAS de champ `executionSteps`/`equipment`/`alternatives`.**
- `Views/Components/ExerciseTimelineCard.swift` (251 lignes) : card par exo avec name + illustration + notes (GlossaryRichText) + metricsChipsRow + SessionTipBubble.

---

## Sous-story 3.24a — Audit + complétion glossaire strength (~1-1.5j)

**Scope** : étendre `Glossary.entries` avec les ~10 termes strength manquants + ajouter règles `detectionPatterns` correspondantes + 20 keys i18n FR + EN. Aucune refonte UI.

**AC 3.24a** :
- **AC-a1** : `Glossary.swift` étendu avec entrées : `rir`, `cars`, `scapular`, `mobilite-thoracique` (alias `thoracic-mobility`), `bandpullapart`, `dislocation` (alias `shoulder-dislocations`), `catcow`, `rampup`, `barrevide`, `reps`. ID format kebab/dot cohérent.
- **AC-a2** : `GlossaryMatcher.detectionPatterns` étendu : `"rir"`, `"reps in reserve"`, `"cars"`, `"scapular cars"`, `"ankle cars"`, `"hip cars"`, `"scapular"`, `"mobilité thoracique"`, `"thoracic mobility"`, `"thoracic extension"`, `"band pull apart"`, `"pull apart"`, `"dislocations"`, `"shoulder dislocations"`, `"cat-cow"`, `"cat cow"`, `"ramp up"`, `"ramp-up"`, `"barre vide"`, `"empty bar"`, `"reps"`, `"répétitions"`. Vérifier non-overlap (ex : `"reps"` ne doit pas matcher dans `"Reps in Reserve"` car `rir` est plus long).
- **AC-a3** : Définitions débutant-friendly (≤ 2 phrases) — **focus action concrète**. Exemple `rir` : *"Reps en réserve = combien de reps tu pourrais encore faire avant l'échec. RIR 2 = arrête-toi à 2 reps de l'échec."*
- **AC-a4** : 20 nouvelles keys i18n FR + EN dans `Resources/Localizable.xcstrings`.
- **AC-a5** : Tests `GlossaryMatcherTests` étendus : ≥ 1 test par nouveau terme + 1 test non-overlap.
- **AC-a6** : Vérification rétrocompat : suite tests existante (~702 PASS post-3.19) reste verte.
- **AC-a7** : Test simu : ouvrir séance strength → notes échauffement contiennent `band pull apart`, `RIR`, `cat-cow` → tous soulignés pointillés cliquables.

**Fichiers 3.24a** :
- Modifiés : `Coaching/Glossary/Glossary.swift`, `Coaching/Glossary/GlossaryMatcher.swift`, `Resources/Localizable.xcstrings`, `CoachingSageTests/Coaching/Glossary/GlossaryMatcherTests.swift`, `CoachingSageTests/Coaching/Glossary/GlossaryTests.swift`.

**Jalons 3.24a** : J1 (0.5j) ajout entries + patterns + i18n FR. J2 (0.5j) i18n EN + tests. J3 (0.5j) validation simu + commit.

---

## Sous-story 3.24b — Explication PAR EXO (~3-4j — révisé hausse revue agent)

**Scope** : remplacer le tip générique pattern actuel (`SessionTipCatalog`) par une **description exécution précise par exo** ("tu prends un haltère dans chaque main, tu t'allonges sur le banc, …").

### ✅ DÉCISION FIGÉE Sophie 2026-05-24 — Option (c) hybride

**Option retenue** : **IA on-demand cachée + seed catalogue manuel top 10 exos universels** (= option c hybride).

**Pourquoi** :
- Option (a) catalogue manuel pur : volume i18n trop lourd (~900 strings), effort 3-4j juste pour rédiger.
- Option (b) générateur algo : phrases plates, ne capte pas CARs / dislocations / spécificités.
- Option (c) hybride : qualité Claude excellente + seed pour les exos canoniques garantit hit immédiat zéro latence + scalable sans rédaction massive.

**Contrat technique figé** (consommé par Story 3.25 mode workout guidé) :
- Service async `func explanation(for: AdaptedExercise, language: String) async throws -> ExerciseExplanation`
- Struct `ExerciseExplanation { steps: [LocalizedStringKey], equipment: [LocalizedStringKey], commonMistakes: [LocalizedStringKey]?, alternatives: [String]? }`
- Cache disque `Application Support/ExerciseExplanations/<lang>/<exoNameSHA256>.json`, TTL infini
- Fallback offline / API down → `SessionTipCatalog` actuel (zéro régression)

**AC 3.24b** :
- **AC-b1** : Nouveau service `Coaching/Session/ExerciseExplanationService.swift` async `func explanation(for: AdaptedExercise, language: String) async throws -> ExerciseExplanation`. Implémentation : (1) check catalogue manuel seed ; (2) check disk cache ; (3) appel Léon API ; (4) cache disque + retour.
- **AC-b2** : Catalogue manuel seed `Coaching/Session/ExerciseExplanationSeed.swift` : top 10 exos universels strength rédigés à la main FR + EN.
- **AC-b3** : Cache disque dans `Application Support/ExerciseExplanations/<lang>/<exoNameSHA256>.json`. TTL infini (les exos ne changent pas).
- **AC-b4** : Prompt Léon respect garde-fous EU MDR : aucun "tu dois" / "il faut" prescriptif ; pas de prescription médicale ; format strict 3-5 steps + équipement + 1 erreur courante.
- **AC-b5** : Mode offline / API down → fallback gracieux sur `SessionTipCatalog` (zéro régression).
- **AC-b6** : UI : dans `ExerciseTimelineCard`, le `SessionTipBubble` actuel devient un disclosure "Comment l'exécuter ?" expandable. Au tap, expansion + spinner si fetch IA, puis liste étapes numérotées + chips équipement.
- **AC-b7** : Tests : (1) catalogue seed retourne explanation pour "bench press". (2) Cache hit court-circuite l'API. (3) Mode offline tombe sur tip pattern. (4) Prompt audit : aucun mot banni EU MDR (smoke test corpus).
- **AC-b8** : i18n bouton disclosure : "coaching.exercise.howto.disclose" FR + EN.

**Fichiers 3.24b** :
- Nouveaux : `Coaching/Session/ExerciseExplanationService.swift`, `Coaching/Session/ExerciseExplanationSeed.swift`, `Coaching/Session/ExerciseExplanation.swift` (struct), `CoachingSageTests/Coaching/Session/ExerciseExplanationServiceTests.swift`.
- Modifiés : `Views/Components/ExerciseTimelineCard.swift` (tip bubble → disclosure), `Resources/Localizable.xcstrings`.

**Jalons 3.24b** : J1 (1j) struct + seed catalogue + cache disque. J2 (1j) service IA + prompt + tests garde-fous. J3 (1j) UI disclosure + intégration card + simu.

---

## ~~Sous-story 3.24c — Mode workout exécution guidé~~ → **ABSORBÉE STORY 3.22 SUJET D**

Cette section est **conservée en référence croisée** mais NE sera PAS livrée dans cette story 3.24. Voir `_bmad-output/implementation-artifacts/3-22-flux-utilisateur-complet.md` section "Sujet D — Mode workout exécution guidé" pour le détail.

**Résumé pour mémoire** : nouvelle vue `GuidedWorkoutView` plein écran avec flux pas-à-pas (1 exo à la fois + chrono séries/repos + bouton "Exo suivant" + récap final). Lancée depuis `SessionDetailView` via bouton secondaire en parallèle du scroll classique (option additive, pas remplacement). Effort 5-7j, dépendance souhaitable Story 3.24b livrée avant pour enrichir mode guidé.

---

## Décisions produit à valider Sophie (figer avant dev)

1. **Explication par exo : option (a) catalogue manuel, (b) algo, (c) IA cachée, hybride (a+c) ?**
   Recommandation : **hybride (c) IA on-demand cachée + seed (a) catalogue manuel top 10 exos universels**.
2. **Glossaire 3.24a : ajout direct au catalog existant ou refonte structurelle ?**
   Recommandation : **ajout direct** — l'architecture `detectionPatterns` longest-first est extensible par ligne, pas de refonte.
3. **Ordre de livraison ?**
   Recommandation : **3.24a → 3.24b → puis Sujet D de Story 3.22**. 3.24a quick win immédiat. 3.24b enrichit la fondation par-exo nécessaire au mode guidé.
4. **Gestion du terme `reps`** (Sophie ne sait pas que = répétitions) : ajout en 3.24a ou refactor pour parler "répétitions" partout en FR dans les metric chips ?
   Recommandation : ajout glossaire 3.24a + dans `ExerciseTimelineCard.metricsChipsRow`, changer `"\(sets) × \(reps)"` → `"\(sets) séries × \(reps) reps"` (terme `reps` reste mais glossarié au tap).

---

## Acceptance Criteria globaux Story 3.24

- **AC-G1** — Sophie peut ouvrir la même séance strength que le test simu 2026-05-24 et **tous** les 10 termes jargon listés sont soulignés et expliqués au tap.
- **AC-G2** — Pour chaque exo strength de cette même séance, le disclosure "Comment l'exécuter ?" affiche une description précise propre à cet exo.
- **AC-G3** — Zéro régression sur l'expérience scroll existante (`SessionDetailView` continue de marcher).
- **AC-G4** — Suite tests existante (~702 PASS post-3.19) + nouveaux tests passent (~720+ total estimé).
- **AC-G5** — Build PASS, ui-reviewer READY sur 2 scénarios : (1) scroll classique avec disclosure, (2) glossaire enrichi cliquable.

## Fichiers touchés (preview)

**3.24a — Glossaire** :
- `Coaching/Glossary/Glossary.swift` (M)
- `Coaching/Glossary/GlossaryMatcher.swift` (M)
- `Resources/Localizable.xcstrings` (M, +20 keys)
- `CoachingSageTests/Coaching/Glossary/GlossaryMatcherTests.swift` (M)
- `CoachingSageTests/Coaching/Glossary/GlossaryTests.swift` (M)

**3.24b — Explication par exo** :
- `Coaching/Session/ExerciseExplanation.swift` (N)
- `Coaching/Session/ExerciseExplanationService.swift` (N)
- `Coaching/Session/ExerciseExplanationSeed.swift` (N)
- `Views/Components/ExerciseTimelineCard.swift` (M — tip bubble → disclosure)
- `Resources/Localizable.xcstrings` (M, +bouton + seed catalogue)
- `CoachingSageTests/Coaching/Session/ExerciseExplanationServiceTests.swift` (N)

## Risques

- **Effort 3-4.5j** : décomposable en 2 sous-stories indépendantes, 3.24a déjà énorme valeur immédiate.
- **Drift template-first si on enrichit chaque exo** : option (c) IA cachée évite ce risque (100% côté app, zéro modif templates JSON).
- **EU MDR pour 3.24b IA** : prompt Léon respecte garde-fous existants (`epic3_leon_legal_constraints`). Audit prompt + test smoke mots bannis = AC-b4 + AC-b7.
- **Latence IA 1er fetch 3.24b** : ~1-2s — mitiger par spinner UI + seed catalogue pour top exos = hit immédiat.
- **Cache disque 3.24b non bornable** : ~90 exos × 2 langues × 1KB ≈ 180KB → négligeable.
- **Risque dépendance 3.22 Sujet D** : si 3.24b n'est pas livrée avant Sujet D, fallback gracieux sur tip pattern → expérience dégradée mais pas régression. Ordre recommandé respecté.

## Découpage par sous-story (rappel)

| Sous-story | Effort | Branche cible | Livrable indépendant ? | Valeur isolée |
|---|---|---|---|---|
| **3.24a** Glossaire strength | 1-1.5j | `epic-3/story-3.24a-glossary-strength-completion` | Oui | Sophie comprend tous les termes — quick win |
| **3.24b** Explication par exo | 2-3j | `epic-3/story-3.24b-exercise-per-exo-explanation` | Oui (sans 3.24a OK, mais 3.24a recommandé d'abord) | Description précise par exo |
| ~~3.24c~~ Mode workout guidé | ~~5-7j~~ → **basculé Story 3.22 Sujet D** | — | — | Voir Story 3.22 |

**Stratégie recommandée** : livrer 3.24a en 1 cycle dev (déblocage immédiat), 3.24b cycle suivant après décision produit option a/b/c. Sujet D de 3.22 ensuite (consomme 3.24b).
