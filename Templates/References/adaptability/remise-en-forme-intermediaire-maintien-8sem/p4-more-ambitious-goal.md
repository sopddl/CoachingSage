# Adaptability : remise-en-forme-intermediaire-maintien-8sem + p4-more-ambitious-goal

## Rigidity score
**4/10**

## Patch approach
Le template est conçu pour le maintien et l'ancrage d'une routine mixte chez un intermédiaire. Rehausser l'objectif final exige une augmentation progressive et maîtrisée de l'intensité et du volume dès W1, une accélération des progressions de charge, et un repositionnement de W5 pour éviter le décalage entre pics de progression et capacité d'adaptation. Le plan actuel repose sur une cutback W5 obligatoire : l'adapter pour un objectif plus ambitieux demande de réduire cette semaine ou de la décaler, ce qui crée des tensions avec la progression_logic (RÈGLE 10-15%). Le circuit W8 devient insuffisant : il faudrait ajouter une dimension d'endurance plus longue ou de puissance.

## Concrete modifications

- **W1 J1 (Cardio continu)** : augmenter à 30 min (vs 25 min) à RPE 6, établir une baseline plus élevée pour supporter 35+ min en W4.
- **W1 J3, J5 (Renfo)** : ajouter +1 set aux composés (squat : 4 sets au lieu de 3, rowing/développé : 4 sets au lieu de 3), augmenter les reps de +2 (squat : 14 reps au lieu de 12) pour orienter vers l'hypertrophie + endurance musculaire dès W1.
- **W2 J1 (Cardio)** : passer à 35 min (vs 30 min) — progression linéaire plus agressive.
- **W3 J1 (Cardio intervalles 40/20)** : maintenir le format mais passer à 6 sets × 2 blocs = 12 sets au lieu de 8 total. Viser RPE 8-9 sur les efforts.
- **W4 J1 (Cardio endurance)** : augmenter à 38 min (vs 35 min proposés en W4 actuel). C'est le pic pré-cutback, justifier cette charge plus élevée.
- **W5 (Cutback)** : réduire le volume de seulement -10% au lieu de -15% (vs safety_notes qui demande -15%). **Contradiction majeure** : la progression_logic stipule -15%, mais l'objectif ambitieux exige une récupération moins profonde pour ne pas perdre les adaptations.
  - W5 J1 : cardio 28 min au lieu de 25 min (vs -15% qui donnerait 21 min).
  - W5 J3, J5 : garder 3 sets mais augmenter reps de +2 (vs baisse de reps).
- **W6 J1 (Cardio 30/30)** : augmenter à 8 sets au lieu de 10 (déjà élevé). Maintenir intensité RPE 8-9.
- **W6 J5 (Circuit mixte)** : ajouter +1 tour (4 tours au lieu de 3) ou ajouter un exercice de puissance (jump squat modifié ou burpee allégé).
- **W7 J1 (Cardio endurance 38 min)** : augmenter à 40 min — "pic cardio" du plan.
- **W7 J3, J5 (Renfo pic)** : ajouter +1 set sur les composés (squat : 5 sets au lieu de 4 ; rowing/développé : 5 sets au lieu de 4), maintenir la charge W7 (RPE 8) mais viser +1 kg vs W6 de manière systématique sur au moins 2 composés.
- **W8 J3 (Renfo bas + haut séance complète)** : restructurer pour intégrer un test de puissance (ex : squat jump ×5 à la fin de la séance squat, ou tempo développé 2-1-1 pour tester la stabilité à charge plus élevée).
- **W8 J5 (Circuit final)** : augmenter à 5 tours au lieu de 4 (durée totale ~55 min vs 50 min). Ou ajouter 1 exercice de finition (Turkish get-up unilatéral ×5 par côté avec charge légère pour pattern complexe).

## Rigidity issues

- **Cutback W5 non-négociable dans progression_logic** : la RÈGLE DE 10-15% et le CUTBACK WEEK obligatoire sont présentés comme des invariants pour prévenir les tendinopathies sur 4 séances/sem. Réduire le cutback à -10% au lieu de -15% crée une tension avec la section "SIGNES DE SURCHARGE" (safety_notes) — si le pratiquant n'est pas frais à W6, le pic W7 devient dangereux. Solution : accepter un risque calculé si l'utilisateur reconnaît que la récupération W5 sera moins profonde.
- **Durée du plan (8 semaines) insuffisante pour un saut de niveau majeur** : si "niveau au-dessus" = passer d'intermédiaire à avancé (ex : 10K de course après un plan de "remise en forme maintien"), 8 semaines ne suffisent pas. Les recommandations NSCA pour une progression à "avancé" demandent 12-16 semaines minimum. Le template ne peut pas être patchable pour cet objectif sans **étendre le plan à 12 semaines** (ex : ajouter 2 semaines de consolidation W9-W10 post-W8).
- **Circuit W8 reste hybride, pas spécialisé** : W8 J5 reste un circuit mixte "génériste". Pour un objectif ambitieux (ex : performance cardio 10K ou puissance musculaire), ce circuit n'est pas optimal. Il faudrait choisir une spécialisation W7-W8 (cardio ou force) — le template ne le permet pas sans récrire W7-W8 entièrement.
- **Safety_notes vs augmentation agressive W1** : ajouter +1 set et +2 reps dès W1 dégrade le "priorité à la qualité d'exécution" stipulée dans le goal W1. Si le pratiquant saute l'échauffement (risque doublé chez intermédiaire selon safety_notes), cette progression dès W1 élève le risque de blessure posturale.

## Contradictions

- **progression_logic : RÈGLE DE 10-15% vs augmentation W1 agressive** : ajouter +1 set et +2 reps dès W1 peut représenter +15% de volume immédiatement. Ensuite, W2 demande encore +12%, créant un cumul de +27% sur 2 semaines — dépassant la règle des 15%/sem. **Solution** : étaler l'augmentation W1 sur W1-W2 (W1 : +1 set séances renfo uniquement, W2 : +2 reps).
- **safety_notes : "Repos entre séances identiques ≥ 48h" vs circuit W8 augmenté à 5 tours** : dans W8 J5, le circuit comprend squat goblet + RDL qui sont tous deux des patterns bas du corps intensifs (RPE 7-8 global du circuit). Cinq tours x ~2 min par tour = ~10 min de travail bas du corps non-stop. Cela viole implicitement la charge totale hebdomadaire si W8 J3 vient 2 jours avant et charge aussi le bas du corps (squat goblet 3×12 + RDL 3×12). **Entre W8 J3 et J5, seul 2 jours de repos** → risque de surcharge du bas du corps. **Solution** : décaler J5 à J6 (créer un 5e jour) ou alléger J3 bas du corps (garder 2 sets de squat/RDL au lieu de 3) si l'objectif exige le circuit 5-tours W8 J5.
- **Objectif "plus ambitieux" non-défini : champ de tension entre cardio et force** : le profil dit "passer au niveau au-dessus", mais ne précise pas si c'est endurance (10K), force (25 reps à RPE 7), ou puissance (sauts, explosivité). Le template W1-W8 équilibre 40% cardio / 40% renfo / 20% mobilité. Un objectif ambitieux unilatéral (ex : 10K route) demanderait 60% cardio / 25% renfo / 15% mobilité. **Le patch ne peut pas couvrir tous les objectifs : il faut une clarification du profil**.
- **W5 cutback allégé (-10% vs -15%) crée divergence avec safety_notes "SIGNES DE SURCHARGE"** : si W1-W4 → W5 réduit seulement -10%, le pratiquant ne reposera pas suffisamment. Les signes de surcharge (FC repos +8-10 bpm, sommeil perturbé, courbatures > 72h) risquent d'apparaître W5 ou W6 → forage une cutback immédiate type W5 (recommendation safety_notes). Le plan perd alors la structure prévue. **Solution acceptée** : accepter que W5 -10% convient si le pratiquant monitore activement FC de repos chaque matin et arrête si seuil atteint.