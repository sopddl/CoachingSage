# Référentiel Dosage Caméléon — v2 FIGÉ (contrat d'implem)

**Date** : 2026-06-07 — figé après revue panel 5 agents (coach prépa, UX/Sally, novice Maxime,
architecte iOS, sophie-ux-challenger) + arbitrages Sophie. Supersède la v1 HTML décisions.
**SoT du « quoi afficher/dire ».** Pilote = muscu. Méthode = `methodo-passe-sport-industrielle-2026-06-07.md`.

## Décisions Sophie 2026-06-07
- **D1 charge = Sensation + note.** AUCUN kg prescrit, AUCUN jargon (pas « RIR 2 »).
  Consigne en français normal : « commence léger ; la dernière rép doit être dure mais
  faisable ; garde-en un peu sous le pied ». Champ « poids noté » **optionnel**, sert de
  mémoire (pas de tracking auto en V1). Conforme EU MDR (on guide une sensation, on
  n'ordonne pas une valeur).
- **D2 HIIT = les deux** (reps fixes / « le plus de reps possible en X » — jamais le mot AMRAP à l'écran).
- **D3 yoga = chrono + souffles** (« ≈ 5 respirations » dérivé du chrono, ratio ~5 s/souffle).
- **D4 côté = champ structuré** + guidage « Côté droit / Côté gauche » (affiché + vocalisé).
- **D5 allure/zone = bandeau permanent + voix à l'entrée** (donnée `targetZone` déjà là).
- **D6 échauffement = normaliser structure template** (`.warmup`, pas `.work`) — borner scope d'abord.
- **D7 densité = oui**, défaut par sport ; le **mode choisi (Manuel/Audio) sert déjà de réglage de densité** (pas de toggle V1).
- **Scope V1 = champs modèle maintenant** (non-breaking, zéro migration) + affichage charge/côté/souffles ;
  **seul le tracking auto de charge** (« comme la dernière fois ») → **V2**.
- **Périmètre = 10 sports, football INCLUS** dans la série.

## 3 règles transverses (P0 panel — prérequis avant tout code)
1. **Hiérarchie 1+1+0** : à l'écran d'effort = **1 info héros énorme + 1 ligne support + 0 reste**.
   Les autres dimensions passent en **consigne d'entrée de set** (affichée/dite 2-3 s avant), pas en bandeau permanent. La densité est dans le TEMPS (séquencée), pas dans l'ESPACE (empilée).
2. **Dégradation gracieuse** : dimension sans valeur = **masquée** (le layout se recompose à 1/2/3 dimensions). JAMAIS de « 0 kg » / « — » qui inquiète. Exception : charge muscu 1er passage → afficher la **consigne** (remplit le vide par du sens).
3. **Saisie jamais bloquante** : champ charge **pré-rempli**, modifiable au **stepper ±** (pas de clavier en plein effort), **skip trivial sans culpabilité**. Le dosage informe, il n'interrompt jamais le chrono.

## Matrice A — dimension × mode (labels en français normal, A=affiché / V=vocalisé)
| Dimension | Manuel | Minuté | Audio (affichage = filet glanceable, sous-ensemble réduit) |
|---|---|---|---|
| Séries | A chip | A « Série N/Y » (support) | A réduit + V |
| Reps | A chip | A héros « N reps » | A + V à l'entrée |
| Charge | A consigne+note | A ligne support (consigne, pas kg imposé) | V à l'entrée |
| Récup | A chip « repos » | A phase chronométrée | A + V « repos 30s » |
| Allure/Zone | A badge | A bandeau 1 ligne couleur (filet) | A réduit + V « cours tranquille / vite » |
| Effort ressenti | A note plain-FR | A consigne d'entrée | V à l'entrée |
| Respiration/souffles | A note | A « ≈ 5 respirations » sous chrono | V (yoga, chrono peut s'effacer) |
| Côté G/D | A | A alterné | V « change de côté » |
| Distance | A | A | V |
| Dénivelé (D+) + vitesse ascensionnelle | A (rando) | A (rando) | V (rando) |
| Tempo (« descends lentement 3s ») | A note | A consigne d'entrée | V |
| Variante facile/standard | A | A (proposable) | — |

## Matrice B — corrections coach intégrées
- **Récup typée** (pas un scalaire) : inter-séries (muscu) / **work:rest** (HIIT, 2 bornes) / départ-intervalle (natation) / récup active (running).
- **Cycling** : puissance/zone (W ou %FTP) = central ; cadence = secondaire.
- **Hiking** : D+ cumulé **+ vitesse ascensionnelle (m/h)** ; charge sac = optionnel.
- **Swimming** : couple **distance × départ** (send-off) = le vrai dosage.
- **Tennis** : RPE/densité monte en central ; côté = coup droit/revers.
- **Football** (inclus série) : séries d'ateliers + récup + RPE central.
- **Nouvel axe transverse = variante facile/standard** : LE mécanisme de progressivité sûre grand public (proposer plus facile/plus dur), absent de la v1.

## Modèle — champs à ajouter MAINTENANT (non-breaking, blob Codable tolérant, 0 migration)
Sur `AdaptedExercise` (`Coaching/Adapter/AdaptedProgram.swift:115-164`, init paramètres nommés à défaut) :
- `load: String?` (poids noté, optionnel) · `side: ExerciseSide?` (left/right/bilateral) ·
  `breaths: Int?` (dérivé chrono) · format HIIT « max-reps » (flag/enum) · récup typée.
- `volumeAxis` (orphelin) : trancher suppression/activation hors pilote.
- **V2** : tracking charge (persistance + auto-suggestion « comme la dernière fois », où stocker l'historique par exo — décision produit), Live Activity / écran verrouillé (nommée V2), toggle densité explicite.

## Jargon → français normal (Maxime + challenger)
RIR/RPE → « garde-en un peu sous le pied » / « effort sur 10 » · AMRAP → « le plus de reps possible en X » ·
zone 2 → « cours tranquille, tu peux parler » · tempo → « descends lentement (3s) » · récup → « repos ».
**Glossaire à compléter** (absents, P0) : **souffles/respiration** (yoga), **dénivelé** (rando) — clés FR/EN/ES.

## Contenu « est-ce que je le fais bien ? » (Maxime — la grille dit combien, jamais comment)
Par exo : 1-2 **consignes de forme** + dessin (déjà via « Comment l'exécuter » + seeds pédago) +
**« commence léger »** + repère **« ça brûle = normal, ça pique l'articulation = stop »**.
(S'appuie sur l'existant `ExerciseExplanationSeed` ; à remonter, pas à recréer.)

## i18n (challenger) — clés à créer AVANT l'implem
« Série N/Y », « N reps », « ≈ 5 respirations », « Côté droit/gauche », « repos 30s », labels bandeau allure :
définir les clés `Localizable.xcstrings` FR/EN/ES en amont (pas de hardcode, chantier B2 ES en cours).

## Reste à cadrer dans la passe pilote (AC ouverts identifiés)
- D4 : alternance côté **auto vs confirmée par l'user** (varie selon mode) — à trancher au pilote.
- D6 : **compter les templates running** affectés avant de patcher (amplitude).
- Accessibilité : Dynamic Type XXL (bandeau dense), VoiceOver (ordre des dimensions), cibles 44pt stepper.
- Unités localisées (kg/lb, min/km vs /mi) avant d'enrichir les templates.
