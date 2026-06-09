# Spec Dosage — Pilote MUSCU (Passe Sport)

**Date** : 2026-06-07 · **Étape pipeline** : 2 (spec dosage, après capture réel)
**Contrat** : `referentiel-dosage-cameleon-v2-FIGE.md` (SoT) · **Méthode** : `methodo-passe-sport-industrielle-2026-06-07.md`
**Captures réelles** : `/tmp/dosage-muscu-capture/` (HUB, FOCUS Minuté, FOCUS échauffement)

But de la spec : pour la muscu, confronter **ce qui est rendu aujourd'hui** au **référentiel figé**, lister
les **gaps** (candidats P0/P1/P2) et les **AC ouverts** que le comité doit trancher. La grille dit *combien*,
jamais *comment* (le « comment » = seeds pédago existantes).

---

## 1. État réel capturé (2026-06-07, simu iPhone 17 Pro Max)

| Écran | Ce qui s'affiche aujourd'hui |
|---|---|
| **HUB** (liste séance, template *beginner home basics*) | Chips `3×10`, `3×8`, `3×10 par côté`, `15 sec`. Stats grille Durée/Intensité(Soutenu)/Format(6 blocs). **Aucune charge, aucun « commence léger ».** |
| **FOCUS Minuté** (Goblet squat) | Support « Série 1 sur 4 · exo 1 sur 2 ». Héros = **chrono `0:31`** (énorme). Reps en 2e niveau « Objectif : 8 ». Hint « Prends le temps qu'il faut · Pause si besoin ». « Ensuite : Récup ». Dessin + « Comment l'exécuter ». |
| **FOCUS Échauffement** | Chrono `4:58` + bullets « 5 min vélo facile / mobilité épaules / activation glutes (band) », glossaire tappable. |

**Templates muscu** (4) : `beginner-home-basics`, `recreational-upperlower`, `regular-ppl`, `competitive-5x5`.
Encodage dosage par exo : `sets:Int`, `reps:String` (« 8 », « 12-15 », « 10/côté »), `rest_seconds:Int`,
`notes:LocalizedText` (texte technique), `target_zone:String` (souvent **« RPE 6-7 »**), `volume_axis:"sets"`.

---

## 2. Dimensions muscu pertinentes (Matrice B) × état

| Dimension | Réf. attendu (muscu) | Rendu actuel | Gap |
|---|---|---|---|
| **Séries** | A chip (Manuel) / « Série N/Y » support (Minuté) | ✅ `4 ×` / « Série 1 sur 4 » | OK |
| **Reps** | A chip / **héros « N reps »** en Minuté | ⚠️ chip OK, mais en Minuté reps = 2e niveau (héros = chrono) | **P1 hiérarchie** |
| **Charge** | A **consigne + note** (« commence léger… »), champ poids optionnel, JAMAIS de kg imposé | ❌ **rien** | **P0 — finding n°1** |
| **Récup (inter-séries)** | A chip « repos » / phase chronométrée | ✅ chip `Repos 90s` + phase « Récup » | OK (vérifier typage récup = inter-séries) |
| **Effort ressenti** | A note **plain-FR** (« effort sur 10 » / « garde-en sous le pied ») | ❌ encodé **« RPE 6-7 »** en badge (3 templates) | **P0 — viole D1 jargon** |
| **Côté G/D** | **champ structuré** + « Côté droit/gauche » (affiché+vocalisé), alternance | ⚠️ texte « par côté » / « 10/côté » noyé dans reps | **P1 — D4** |
| **Tempo** (« descends lentement 3s ») | A note / consigne d'entrée | ❌ seulement en prose dans `notes` | P2 |
| **Variante facile/standard** | A (proposable) — mécanisme progressivité sûre | ❌ absent | **P1 — axe transverse réf.** |

Dimensions **non pertinentes muscu** (à NE PAS afficher) : allure/zone, distance, dénivelé, respiration/souffles.

---

## 3. Gaps → candidats findings (à confirmer/prioriser par le comité)

- **G1 (P0) — Charge absente.** Aucune consigne de charge ni « commence léger » sur aucun écran muscu.
  Réf. D1 : afficher la **consigne** (1er passage muscu = exception « cas vide » → on remplit par du sens) +
  champ « poids noté » optionnel (mémoire, pas de tracking auto V1). EU MDR : on guide une sensation.
  → Modèle : ajouter `load: String?` sur `AdaptedExercise` (non-breaking).
- **G2 (P0) — Jargon RPE à l'écran.** `target_zone: "RPE 6-7"` rendu en badge glossaire ; `notes` contiennent
  « GRILLE RPE / RIR … RPE 6-7 (RIR 3-4) ». Viole D1 (« AUCUN jargon »).
  → Décision : **convertir** RPE → français normal (« effort 6-7 sur 10 » ou « garde-en un peu sous le pied »)
  à l'affichage, et **nettoyer les notes templates**. (AC : conversion au rendu vs ré-encodage templates ?)
- **G3 (P1) — Hiérarchie Minuté.** En muscu minutée, le héros visuel est le **chrono**, pas les reps.
  Réf. Matrice A : héros Minuté = « N reps ». Règle transverse 1 (1 héros + 1 support).
  → AC : pour la muscu, le héros est-il les **reps** ou le **chrono** ? (muscu = reps-driven, pas temps-driven).
- **G4 (P1) — Côté non structuré.** « par côté » / « 10/côté » en texte libre. D4 = champ `side: ExerciseSide?`
  structuré + guidage « Côté droit / Côté gauche » (affiché + vocalisé), alternance auto/confirmée.
- **G5 (P1) — Variante facile/standard absente.** Mécanisme de progressivité sûre grand public, absent partout.
  → AC : V1 (juste l'afficher si présent en template) ou V2 (génération) ?
- **G6 (P2) — Bug nom-vs-schéma.** « Planche genoux au sol **30 sec** » → chip **`15 sec`** (incohérence
  nom/durée). À traiter comme bug data template (probablement hors scope dosage mais à logger).
- **G7 (P2) — Tempo en prose.** Tempo vit dans `notes`. Optionnel V1 (consigne d'entrée).

---

## 4. Champs modèle à ajouter (rappel réf. — non-breaking, blob Codable, 0 migration)
Sur `AdaptedExercise` (`Coaching/Adapter/AdaptedProgram.swift:115-164`) :
`load: String?` · `side: ExerciseSide?` (left/right/bilateral) · (HIIT/yoga `breaths` hors muscu) ·
récup typée (muscu = inter-séries). `volumeAxis` orphelin = trancher hors pilote.

---

## 5. Règles transverses P0 à respecter (rappel réf.)
1. **Hiérarchie 1+1+0** à l'écran d'effort (héros + support + reste séquencé en consigne d'entrée).
2. **Dégradation gracieuse** : dimension sans valeur = masquée (jamais « 0 kg »). Exception charge 1er passage = consigne.
3. **Saisie jamais bloquante** : champ charge pré-rempli, stepper ±, skip trivial, jamais d'interruption du chrono.

---

## 6. AC OUVERTS — à trancher au comité (décisions produit, pas d'arbitrage solo)
- **AC1 (G2)** : jargon RPE → **conversion à l'affichage** (mapping RPE→FR) **ou** ré-encodage des notes/target_zone des 4 templates ? (impacte i18n + EU MDR).
- **AC2 (G3)** : héros Minuté muscu = **reps** (« 8 ») ou **chrono** ? La muscu est reps-driven ; mais le timer existe (auto-chaînage `.timed`). Repenser quoi mettre en énorme.
- **AC3 (G1)** : la consigne charge « commence léger… » s'affiche-t-elle **à chaque set** (consigne d'entrée) ou **1× par exo** ? Et où exactement (HUB liste vs FOCUS) ?
- **AC4 (G4)** : alternance côté **auto** (l'app avance G→D) **vs confirmée** par l'user ? (varie selon mode Manuel/Minuté).
- **AC5 (G5)** : variante facile/standard en **V1** (afficher si template la porte) ou **V2** (génération auto) ?
- **AC6** : champ « poids noté » — UI exacte (stepper ± unités kg/lb localisées) et placement (FOCUS sous les reps ?). Tracking = V2 acté.
- **AC7** : accessibilité (Dynamic Type XXL sur écran d'effort, VoiceOver ordre des dimensions, cibles 44pt stepper) — niveau d'exigence V1.

---

## 7. Sortie attendue du comité
Findings P0/P1/P2 confirmés + tranche des AC1-7 → ce qui se code en SOPDDL (champs modèle + rendu caméléon
+ glossaire souffles/dénivelé N/A muscu mais effort-FR à créer + i18n) et ce qui part en HTML décisions.
