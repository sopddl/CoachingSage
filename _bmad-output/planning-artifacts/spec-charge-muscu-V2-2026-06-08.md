# Spec — Charge muscu V2 (poids prescrit + adaptation + apprentissage)

**Date** : 2026-06-08
**Branche** : `chantier/dosage-cameleon-muscu`
**Statut** : DRAFT pour party comité (étape 3 pipeline Passe Sport)
**Demande Sophie (verbatim)** : « sur la charge pour la muscu donnons une indication de poids et
proposons lui de l'adapter, trouvons un moyen de apprendre de l'expérience, mais soyons force de
proposition avec précaution »

---

## 0. ⚠️ DÉCISION FIGÉE RÉOUVERTE — à porter en connaissance de cause

Le référentiel figé (`referentiel-dosage-cameleon-v2-FIGE.md`, D1) et la contrainte EU MDR disaient :
**« charge = sensation + note, AUCUN kg prescrit, on guide on n'ordonne pas »** (garde-fou statut
dispositif médical — cf. `epic3_leon_legal_constraints.md`, RC pro, mots bannis).

**Sophie décide explicitement (2026-06-08) d'OUTREPASSER ce point** : on **prescrit un poids
indicatif**. Cette spec acte le revirement ET fait de la précaution légale une **exigence dure**
(pas optionnelle). La party doit valider QUE c'est faisable proprement, pas SI on le fait.

---

## 1. État actuel (audit code 2026-06-08)

- `AdaptedProgram.load: String?` existe sur le modèle mais **n'est affiché nulle part** (donnée morte ;
  seuls usages de `.load` = couleur de dessin + assignation).
- Seule UI charge = une caption grise `coaching.dosage.charge.hint` (« commence léger… »),
  **uniquement** en FOCUS Minuté, phase work, muscu, reps résolues. **Rien en mode Manuel.**
- **Aucun stepper de charge.** L'effort 1-5 existe (post-RPE). Autorégulation déjà présente dans
  `RoutineCycleService` (completion + ressenti, scopée semaines écoulées).
- ⇒ En pratique, l'utilisateur ne voit **rien** de la charge. C'est le déclencheur de cette spec.

## 2. Objectif V2

Donner un **poids indicatif par exercice**, **modifiable** par l'utilisateur, et **qui apprend de
son expérience** (ressenti + poids réellement utilisé → suggestion d'ajustement la fois suivante).
Force de proposition **avec précaution** (jamais un ordre, jamais bloquant, cadre EU MDR préservé
malgré la prescription).

## 3. Exigences DURES (non négociables, même avec prescription)

- **EU-1** : tout poids affiché est **« à titre indicatif »** + **toujours modifiable** (l'user reprend la main en 1 geste).
- **EU-2** : respect de `requires_medical_clearance` — pas de prescription si profil non clear.
- **EU-3** : aucun mot banni / claim médical ; garder un rappel « écoute ton corps, ne force pas sur la douleur ».
- **EU-4** : garde-fou de plafonnement (sanity bounds) — jamais une suggestion d'augmentation absurde.
- **P0 transverses (référentiel)** : hiérarchie 1 héros + 1 support ; cas vide masqué (jamais « 0 kg ») ;
  saisie non-bloquante.

## 4. Gaps / questions ouvertes pour la party (G1–G7)

- **G1 — D'où vient le poids initial ?** Pas de 1RM connu. Tables % poids de corps ? Par niveau
  (débutant/inter/avancé) ? Par famille d'exo (squat lourd vs élévations latérales légères) ?
  Estimation conservatrice ? → cœur du sujet, et cœur du risque légal.
- **G2 — Unité / forme.** kg absolu ? « par côté » pour haltères ? Cas non-kg (élastique : faible/moyen/fort ;
  poids du corps ; machine sans repère) ? Comment éviter de prescrire un kg sur un exo au poids du corps ?
- **G3 — Où s'affiche-t-il ?** Manuel ET Minuté ? Dans le HUB (aperçu) ? Sur l'écran d'effort ?
- **G4 — Boucle d'apprentissage.** Réutilise-t-on `RoutineCycleService` ? Signal = poids saisi + effort 1-5 ?
  Règle d'ajustement (ressenti facile → +X ; dur → maintien ; échec → -X) ? Granularité (par exo ? par séance ?).
- **G5 — Première fois / zéro historique.** Quel comportement quand on n'a encore rien logué ?
- **G6 — Saisie.** Stepper ? TextField + Stepper (cf. SessionCompleteSheet) ? Quand confirme-t-on le poids réellement fait ?
- **G7 — Précaution UX.** Comment formuler la prescription pour rester « proposition » et pas « ordre »
  (wording, ton, disclaimer discret mais présent) ? Inès (user cadrée) + expert prépa = voix clés.

## 5. Sortie attendue de la party

(1) Cadre légal validé (comment prescrire SANS sortir du raisonnable EU MDR).
(2) Réponses/arbitrages G1–G7 → « V1 SOPDDL » vs « HTML décisions Sophie » vs « V2 ».
(3) Liste claire de ce qui se code en premier.
