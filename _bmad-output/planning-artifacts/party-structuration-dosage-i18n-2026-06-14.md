# Party — Structuration i18n des champs dosage (`duration` / `reps` / `targetZone`)

**Date** : 2026-06-14 · **Étape pipeline** : design party (conception) — CLOSE.
**Déclencheur** : reliquat i18n — `duration`/`reps`/`targetZone` restés en texte libre FR
rendus verbatim → fuite FR en EN **et** ES (cas vu : yoga « 3 min (~10 cycles
respiratoires) »). Option **A — structurer le modèle** retenue par Sophie, scope **EN+ES**.

**Entrées (data figée ce jour, bundle prod)** :
- `duration` : 4653 champs, dont **1879 free-text** (478 distincts).
- `reps` : 2629 champs, dont **1422 free-text** (282 distincts).
- **~754 distincts combinés** ; **~600 irréductibles descriptifs**.
- Vocabulaire qualificateurs/unités relevé exhaustivement (cf. §Taxonomie).
- Précédent direct : party dosage muscu (`side: ExerciseSide`, `load: String?`,
  modèle non-breaking) — on a **déjà** structuré « par côté » → `side`.

---

## Casting
🏗️ Théo (architecte tech) · 🎨 Sally (UX) · 🏋️ Marc (prépa/coach) · 🌱 Maxime (novice FR/EN) · 🛡️ sophie-ux-challenger (pre-screen). PM/scope joué en synthèse.

## Problème (1 phrase)
On a localisé *quoi* faire (name/notes/alternatives en blob `{fr,en,es}`) mais pas
*combien* — le **dosage**, cœur métier, parle FR à un user EN/ES, et le **minuteur**
aussi (le parser extrait son label depuis la string FR).

## Cap fixé par Sophie
> « je veux quelque chose de **scalable et robuste** quitte à y passer un peu de temps. »

## Tour de table (résumé)
- **Théo** : 3 atomes (`value`/`unit`/`qualifier`) pour le régulier ; intervalle = 2ᵉ type ;
  reste = `freeText` localisé. Règle : **un champ structuré OU un blob, jamais à moitié**.
  Le formatter devient source unique (UI + label timer) ; le parser lit le modèle, plus la string.
  Seul bout non-réversible = le timer Minuté déjà livré → filet de test obligatoire.
- **Marc** : NE PAS fusionner par côté/jambe/bras/pied (sens d'entraînement ≠). `breaths` =
  unité à part entière (yoga), pas un commentaire. → **liste fermée explicite**, quitte à 10+ entrées.
- **Maxime** : veut du propre dans sa langue (« 5 breaths per pose ») ; le pire = le mix
  moitié-traduit. Pour les phrases que la machine traduit mal → **traduction humaine** plutôt que Lego cassé.
- **Sally** : formatter **jamais Frankenstein** ; régulier = composition par gabarit, sinon bascule
  **100% freeText**. Qualificateur **en toutes lettres** (« par côté », pas « /côté » = jargon).
  `targetZone` « respiration guidée » ≠ zone → blob ou sortir du champ zone.
- **Challenger** : NEEDS_FIX — (1) liste qualificateurs figée AVANT code, (2) clés i18n avant
  ré-encodage, (3) migration `PersistedSession` = décision produit (BLOCKING→tranchée T3),
  (4) anti-tunnel = pilote 1 sport, pas big-bang 40. + acter le workflow trad agent/sport.

## Tensions tranchées
| # | Tension | Décision Sophie |
|---|---|---|
| T1 | Granularité qualificateurs : liste fermée vs générique paramétré | **Liste fermée explicite** (sens coaching préservé) |
| T2 | Frontière structuré ⇄ blob | **Tout-ou-rien** : régulier 100% structuré, sinon 100% `freeText {fr,en,es}` |
| T3 | Migration `PersistedSession` | **On adapte, zéro dette** : re-render depuis template structuré au chargement |
| T4 | Découpage | **Pilote yoga end-to-end, puis série 9 sports** (méthodo « Passe Sport ») |

---

## Taxonomie figée (depuis vocabulaire réel)

Modèle conceptuel : un dosage = soit **structuré** (`StructuredDose`), soit **libre**
(`freeText: LocalizedText`). Jamais les deux.

### `StructuredDose` (cas régulier)
- **`value: String`** — nombre OU plage : `"12"`, `"8-10"`, `"30"`. (String pour garder les plages ; pas de calcul dessus côté affichage.)
- **`unit: DoseUnit`** (enum fermé, traduisible) :
  `reps` · `seconds` · `minutes` · `meters` · `kilometers` · `breaths` · `cycles` ·
  `holds` (tenues) · `serves` (services) · `passes` · `strikes` (frappes) ·
  `sequences` (séquences) · `points`.
- **`qualifier: DoseQualifier?`** (enum fermé, optionnel) :
  `perSide` · `perLeg` · `perArm` · `perFoot` · `perShoulder` · `perPose` (posture) ·
  `perVariation` (variante) · `perSet` (série) · `perRound` · `perLetter` (Y/T/W) ·
  `perAttempt` (essai) · `perPattern`.
- **`unitModifier: DoseModifier?`** (optionnel) : `effective` (effectif) · `free` (libre).
- **`breathStyle: BreathStyle?`** (optionnel, yoga) : `ujjayi`.

> Les enums sont **fermés mais extensibles par pilote-sport** : chaque sport peut ajouter
> une unité/qualificateur manquant (revue), sinon la valeur tombe en `freeText`. Aucune fuite
> possible : tout ce qui n'entre pas dans le gabarit est traduit à la main.

### `freeText: LocalizedText` (cas irréductible, ~600 distincts)
Composites multi-segments / parenthèses / conjonctions :
`"8 × (30s course tempo au seuil + 30s marche)"`, `"1 série de 11 points + 2 min récup"`,
`"45 sec ventrale + 30 sec latérale/côté"`, `"20 passes par pied (40 total)"`,
`"90 min (2 x 45 min)"`, `"20 min lecture + réflexion"`.
→ blob `{fr,en,es}` traduit (workflow agent/sport établi).

### Intervalle (`work+rest`, `ON/OFF`) — arbitrage pilote
2 sous-doses + séparateur OU `freeText`. **Tranché au pilote** : si le formatter intervalle
n'apporte pas de robustesse nette vs un `freeText` propre, on le met en `freeText` (HIIT/course
ont peu de variété → blob acceptable). Décision déléguée à l'implémentation pilote, documentée.

### Formatter (source unique de rendu, FR/EN/ES)
Table de gabarits par (`unit`,`qualifier`) :
`"%@ reps par côté"` / `"%@ reps per side"` / `"%@ reps por lado"`,
`"%@ respirations par posture"` / `"%@ breaths per pose"` / `"%@ respiraciones por postura"`, …
Qualificateur **en toutes lettres**. Le formatter rend l'UI (3 vues) **et** le label de phase du minuteur.

### `targetZone`
« respiration guidée » & co ≠ code zone → `freeText: LocalizedText` (ou retrait du champ zone).
Les vrais codes zone sont déjà gérés (passe zones → `DosageFormatting.sensationLabel`).

---

## Impact technique (pour la spec dev)

1. **Modèle** (`ProgramTemplate.Exercise`) : remplacer/doubler `duration: String?` + `reps: String?`
   par un `dose:` structuré + `freeText`. Décodeur **tolérant** : ancien `duration`/`reps` brut
   lu comme `freeText.fr` (back-compat lecture), mais les 40 templates sont ré-encodés.
2. **Parser timer** (`SessionDurationParser`) : aujourd'hui extrait `(label, seconds)` de la string.
   → consomme le modèle structuré ; le **label localisé** vient du formatter, les **secondes** de
   `value`+`unit`. C'est le seul morceau **non-réversible** (touche Minuté/Audio livré+device-testé).
3. **Migration `PersistedSession`** (T3 = zéro dette) : au chargement, re-render le dosage depuis
   le template structuré (mapping séance↔template). Blob plat JSON conservé, valeurs régénérées.
4. **i18n** : clés/gabarits formatter FR/EN/ES créés **avant** le ré-encodage (règle dosage muscu).
   `freeText` traduit par workflow agent/sport.
5. **Filet régression swift** (CLAUDE.md, dans le même chantier) :
   `NoFreeTextFRInDose` — charge le bundle prod, résout chaque dose en EN et ES, assert qu'aucun
   token FR (`par côté`, `respirations`, `récup`, `tenue`, …) ne subsiste dans le rendu.

---

## Plan de lots (T4)

- **Lot 0 — Spec dev + taxonomie figée** (cet artefact). Geler enums `DoseUnit`/`DoseQualifier`.
- **Lot 1 — Pilote yoga end-to-end** : modèle + formatter FR/EN/ES + parser rebranché + migration
  + ré-encodage des templates yoga + filet swift. Cas le plus dense (breaths/cycles/holds + le
  bug déclencheur). **Device-test Sophie** (Minuté/Audio + rendu EN/ES) avant série.
- **Lots 2-10 — Série 9 sports** : ré-encodage + extension enums au besoin (revue), filet étendu.
- Validation finale : test localisation EN/ES (rappel fin d'epic).

---

## Décisions produit ouvertes restantes
- **Intervalle structuré vs freeText** : tranché au pilote (cf. §Intervalle).
- **`targetZone`** : blob vs retrait du champ — à confirmer au pilote yoga (faible volume).

## Prochaines actions
1. (fait) Artefact spec + décisions.
2. NEXT = **implem SOPDDL Lot 1 (pilote yoga)** sur déclenchement Sophie — pas avant (party rule).
3. Workflow trad EN/ES des `freeText` = étape agent/sport, intégrée par lot.
