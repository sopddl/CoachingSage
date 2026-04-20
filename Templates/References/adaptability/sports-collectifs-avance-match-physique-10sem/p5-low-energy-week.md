# Adaptability : sports-collectifs-avance-match-physique-10sem + p5-low-energy-week

## Rigidity score
**7/10**

Le template contient des cutback weeks explicites (W4, W8) et des principes de modulation reconnus (progressions 10-15%, règle RPE). Cependant, la structure périodisée en blocs crée des points durs : certaines semaines (W3, W7, W9) sont clairement identifiées comme « pic », et modifier drastiquement l'intensité d'une semaine d'intensification casse momentanément la logique d'accumulation-pic. Le template prévoit un protocole « SI SÉANCE MANQUÉE » mais pas d'adaptation graduelle dans la semaine en cours.

## Patch approach

Appliquer un **affûtage intra-semaine temporaire** : réduire de 40-50% le volume des séances d'intermittent (raccourcir les efforts, augmenter les récupérations), descendre les charges force à RPE 7 max, conserver les séances techniques (COD, mobilité) pour maintenir le tonus nerveux. Si la semaine est W3, W7, ou W9 (pics), repousser le pic à la semaine suivante (+1 semaine sur le cycle complet). Si la semaine est W1-W2 ou W5-W6 (progression régulière), la semaine allégée compte comme semi-cutback et la progression reprend immédiatement après.

## Concrete modifications

**Option A : Semaine de progression régulière (W2, W5, W6 exemple)**
- **J1 Intermittent** : réduire sets de moitié. Ex W2 : 30-30 ×18 sets → 30-30 ×9 sets. Repos 90 sec entre blocs pour récup plus complète. RPE cible 6 au lieu de 7-8.
- **J2 Force** : garder tous les exercices, réduire 1 série par composé (4 sets → 3 sets). Charge identique mais RPE 7 max (pas d'augmentation charge). Nordic curl maintenu (prévention obligatoire).
- **J3 COD** : réduire à 4 reps par drill (vs 6-8). Focus qualité mouvement, zéro intensité maximale. RPE 6-7.
- **J5 Intermittent** : couper 50% du volume. Ex W5 : 10 min 10-20 → 5 min 10-20 (10 sets au lieu de 20).
- **J7 Mobilité** : ajouter 5 min supplémentaires (25 min → 30 min). Pas de séance de mobilité "allégée" — au contraire, approfondir.

**Option B : Semaine pic (W3, W7, W9) en contexte fatigue**
- Reporter le pic à +1 semaine. Ex : si fatigue en W3, revenir à W2 (30-30 ×18 sets, force 4 sets, etc.) cette semaine. La semaine suivante devient la semaine pic reportée (W3 déplacée en "W3bis"). Impact : cycle total 10 sem → 11 sem, mais intégrité physiologique maintenue.
- Ou : appliquer directement la semaine W4 (cutback) à la place. Gain : zéro perte de structure, juste avancer d'une semaine dans le plan. Perte : on saute une intensification, mais on minimise les risques de surcharge neuromusculaire.

**Option C : Semaine cutback (W4, W8) en fatigue (moins critique)**
- Réduire encore les volumes de 30-40% additionnels. Ex W4 30-30 ×12 sets → 30-30 ×8 sets. RPE cible 5-6. Charge force réduite à 80% des 3 séries.
- Risque minimal : ces semaines sont déjà allégées par design.

## Rigidity issues

- **Pic semaines (W3, W7, W9)** : si la fatigue survient pendant un pic annoncé, réduire l'intensité casse le modèle d'accumulation-supercompensation de la progression_logic (points 2 et 3 cités). Pas de mention dans le template d'une stratégie "pic reporté" — l'approche proposée est _ad hoc_.
- **Progression force double** : la logique "augmenter reps → augmenter charge" (progression_logic point 4) suppose des séances successives à densité élevée. Une semaine allégée interrompt ce flux. Reprendre après demande de re-baseline en semaine +2.
- **Nordic curl obligatoire** : prévention ischio ne doit pas être compromise. Si fatigue extrême (malaise, douleur articulaire), suspendre, mais sinon le maintenir même réduit (3 sets → 2 sets) déstabilise le protocole de prévention (safety_notes : "ne jamais enlever ce travail").
- **Cutback logic implicite** : le template prévoit W4 et W8 comme uniques cutback. Une fatigue exogène créant un 3e cutback (W5 ou W6 ou W9) sort du schéma périodisé officiel — cela demande un jugement au cas par cas.

## Contradictions

- **Contradiction avec progression_logic point 1** : la "périodisation ondulatoire par blocs" suppose une montée progressive semaine à semaine dans Bloc 2 (W5 → W6 → W7). Injecter une semaine allégée W6 crée un creux non prévu. Mitigation : passer directement à W7 (pic) la semaine suivante pour "rattraper" la semaine allégée.
- **Contradiction avec progression_logic point 2 (règle 10-15%)** : une réduction intra-Bloc peut briser la continuité des deltas de charge. Ex : W5 (+15%) → W6 allégée (-40%) → W7 (reprendre le pic) = saut brutal. La supercompensation attendue post-W5 ne se produit pas, donc W7 part de zéro capacité-récupération. Risque d'échouer le pic W7.
- **Contradiction sécurité — surcharge neuromusculaire (safety_notes)** : les signes de surcharge listés (FC repos +8-10 bpm, performances régressées, sommeil perturbé) sont **exactement** les symptômes du profil "low-energy-week". Le template dit "semaine allégée type W4/W8 immédiatement" si 3+ signes présents. Donc une "semaine fatigue" doit ÊTRE traitée comme cutback imposé (protocole existant), pas comme adaptation patch.
- **Pas de contradiction majeure avec safety_notes sur douleurs** : réduire l'intensité et le volume N'augmente pas le risque de blessure aiguë. À l'inverse, elle le réduit. Safe.

## Recommandation finale

**La contrainte "semaine fatigue baisser intensité" n'est PAS une adaptation externe au template — c'est une **activation du protocole de surcharge neuromusculaire déjà prévu** (safety_notes, dernier paragraphe : "SI SIGNES SURCHARGE NEUROMUSCULAIRE → semaine allégée immédiatement").**

Le template est **flexible suffisamment** pour absorber cette contrainte en mode réactif, mais l'approche n'est pas optimale pour les pics de Bloc 2 (W7) et Bloc 3 (W9) :

1. **Si fatigue en W1-W2, W4, W5-W6, W8** : appliquer cutback inline (volumen -40-50%, RPE -1-2, charge force maintenue) sur la semaine, puis reprendre progression nominale W+1. Aucun décalage du plan.
2. **Si fatigue en W3 ou W7 ou W9** : deux options non idéales :
   - **A)** Reporter le pic à W+1 et décaler le cycle complet +1 sem. Coût : plan s'allonge, mais adaptation reste cohérente.
   - **B)** Descendre à la semaine -1 (ex W3 → W2), puis reprendre W3 le cycle suivant. Coût : perte d'une semaine d'intensification, mais plan tient 10 sem.

Le **score 7/10** reflète que le template a les briques (RPE, cutback, modulation) mais pas de procédure explicite pour déplacer des semaines-pic sans reconstruire le cycle.