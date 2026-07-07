# Chantiers transverses — préalables/alimentation du chantier Séance HUB+FOCUS

Date : 2026-06-02. Source : Party `party-seance-presentation-2026-06-02.md`.
Ce ne sont PAS des stories de présentation — ce sont des préalables/alimentations. À scoper en stories dédiées.

---

## C1 — Localisation espagnole complète (Story 3.37 — **engagement V1 ferme**)

> **Sophie 2026-06-02 : « v1 objectif réel »** → l'ES est un **objectif V1 ENGAGÉ** (pas « prêt-à-brancher »). C1 devient une **story bloquante pour la sortie V1** : `epic-3/story-3.37-localisation-es`. Les stories design 3.32→3.35 se font en FR/EN (clés posées), **l'ES DOIT être livré via 3.37 avant la sortie V1**.

**Décision party D1 (confirmée ferme)** : V1 FR / EN / **ES**. Or le code dit aujourd'hui « V1 = fr + en uniquement »
(`Coaching/Session/ExerciseExplanation.swift:41`, `LanguageManager`).

**Portée réelle (plus grosse que le design séance)** :
- `Resources/Localizable.xcstrings` — ajouter ES à **toutes** les clés.
- **40 templates de contenu** JSON (`Templates/References/**`) — titres/notes/exos en ES.
- Onboarding, questionnaire, glossaire (31+ entrées), explications exo (3.24b), cues vocaux (3.35).
- `SupportedLanguage` + sélecteur (déjà extensible via `LanguageSelectorView`, cf mémoire `multilangue_extensible_regle`).
- Voix TTS ES (3.35) : dispo nativement iOS, à brancher.

**Plan** : **Story 3.37 dédiée**, bloquante pour la sortie V1. Les stories 3.32→3.35 se construisent en **FR/EN d'abord** (clés posées, zéro refactor) ; 3.37 branche l'ES (xcstrings + 40 templates + onboarding + glossaire + voix TTS ES) avant la sortie.

**⚠️ Réalité produit (assumée)** : engagement de traduction/qualité de TOUT le contenu (coûteux, qualité à tenir, cf `quality_over_speed_templates`). Effort à estimer dans la story 3.37 — probablement le plus gros poste du lot. Décision Sophie 2026-06-02 : **on l'assume comme objectif V1.**

---

## C2 — Format-aware templates (alimente la case « Format » 3.32 + l'avance Minuté 3.34)

**Besoin** : la case « Format » du HUB (3.32) et le moteur de timer (3.34) ont besoin de métadonnées structurantes par séance/exo qui n'existent pas toujours :
- HIIT : **nombre de tours** + **work/rest** (ex. 3 tours · 40/20).
- Yoga : **tenue** par posture (secondes/respirations).
- Cardio : la **séance-clé** repérable (« 4×800 »).

**État actuel** : `AdaptedExercise` a `sets/reps/duration/restSeconds` (`Coaching/Adapter/AdaptedProgram.swift:115`) mais
PAS de notion explicite de « tours de circuit » ni de « tenue de pose ».

**Recommandation** : story dédiée d'enrichissement des templates + du modèle (`SessionFormatDescriptor` consomme ça).
**Dégradé sans ce chantier** (déjà prévu dans 3.32/3.34) : Format = « N blocs » fallback ; timer = `duration` exo sinon avance manuelle. **Ne bloque pas** 3.32/3.34, mais les rend meilleurs.

---

## C3 — App Apple Watch → **devenue Story 3.36** (spec dédiée)

Voir `3-36-seance-focus-watch-swim.md`. Chantier infra (nouvelle cible watchOS). À faire **en dernier** du chantier séance.

---

## Ordre recommandé global

1. **3.32** HUB (socle, FR/EN) — *indépendant.*
2. **3.33** FOCUS Manuel (strength) — *absorbe/supersède 3.25.*
3. **3.34** FOCUS Minuté (HIIT/yoga) + anti-Decathlon.
4. **3.35** FOCUS Audio (run/vélo/rando) — *chantier.*
5. **C2** format-aware templates — *en parallèle, améliore 3.32/3.34.*
6. **3.36 / C3** Apple Watch swim — *dernier, le plus lourd.*
7. **3.37 / C1** localisation ES — **bloquant sortie V1** (engagement ferme Sophie 2026-06-02), à caler avant release après que 3.32→3.35 aient posé les clés.
