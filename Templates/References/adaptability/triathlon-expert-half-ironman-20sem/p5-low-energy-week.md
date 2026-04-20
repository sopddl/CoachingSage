# Adaptability : triathlon-expert-half-ironman-20sem + p5-low-energy-week

## Rigidity score
**7/10**

Le template est suffisamment modulable pour absorber une semaine de fatigue sans reconstruire entièrement la semaine. Les cutback weeks (W4, W8, W12, W16) servent de modèle de réduction. Cependant, si la fatigue tombe sur une semaine clé (W11 pic, W13-W15 intensification), le patch exige de reportal stratégique plutôt que simplement réduire sur place.

## Patch approach

Identifier la semaine concernée dans le plan (W1-W20), puis appliquer un protocole de réduction en trois étapes : (1) réduire le volume de chaque séance de 30-40%, (2) transformer toute intensité Z4-Z5 en Z2-Z3, (3) augmenter les jours de repos (7 → 5-6 séances/semaine), (4) repousser les brick long et les évaluations à la semaine suivante ou décaler le plan global de 1 semaine si l'intensification W13-W16 est compromise.

## Concrete modifications

Exemple appliqué à **W9** (construction avancée, volume ~14 h) :

- **W9 J1 (Natation 80 min)** : réduire séries 700 m Z2 de 3 × 700 = 2100 m → 2 × 500 m = 1000 m Z2. Cooldown inchangé. **Durée : 80 min → 50 min.**
- **W9 J2 (Vélo 160 min)** : réduire sortie 140 min Z2-Z3 → 90 min Z2 strict (aucun Z3). **Durée : 160 min → 105 min.**
- **W9 J3 (Course 70 min)** : réduire intervalles 800 m × 6 (4800 m travail) → 400 m × 4 (1600 m travail). Garder nordic curl × 3 sets sinon reprendre force. **Durée : 70 min → 45 min.**
- **W9 J4 (Natation 65 min)** : réduire drill départ vague × 6 → × 4, pull-buoy 200 m × 4 → × 2. **Durée : 65 min → 45 min.**
- **W9 J5 (Vélo 90 min)** : réduire intervalles Z4 longs (3 × 12 min Z4) → 2 × 8 min Z4 + 5 min Z2 entre. **Durée : 90 min → 70 min.**
- **W9 J6 (Brick 180 min)** : **REPOUSSER à W10 ou la semaine suivante**. Remplacer par : vélo Z2 60 min + run Z2 20 min (80 min total). Éliminer transition simulée et nutrition complexe. **Durée : 180 min → 80 min.**
- **W9 J7 (Mobilité)** : garder inchangé (priorité récupération).

**Volume hebdo W9 normal ≈ 14 h → W9 adapté ≈ 8,5 h (39% réduction).**

## Rigidity issues

- **Brick long (W3, W6, W10, W11 surtout)** : le plan les estime essentiels pour la spécificité. Les repousser casse le timeline. Si fatigue coïncide avec W11 (brick simulation complète 240 min), il faut **choisir** : soit réduire drastiquement le brick (70 min vélo + 20 min run au lieu de 160 + 55), soit reporter la simulation à W13 ou W14. Cela crée un trou dans la validation du plan race 2-4 semaines avant la compétition.

- **Cutback weeks rigides (W4, W8, W12, W16)** : s'il y a fatigue EN cutback week, le patch devient trivial (cutback strict = repos presque total). Mais si fatigue tombe en W5-W7 ou W9-W11, la semaine suivante de cutback n'efface pas le déficit de la semaine précédente. Le template assume une récupération "à temps", pas un décalage chronique.

- **Progression_logic de 10-15%/semaine** : une réduction de 40% une semaine, puis retour à 100% la semaine suivante, crée un écart violent de charge. Le template n'adresse pas comment réintégrer le volume progressivement post-fatigue (ex : retour en 2 étapes W+1, W+2 avant de reprendre la progression nominale).

- **Séances de qualité (W13-W16)** : si fatigue basse-énergie tombe en bloc intensification (W13, W14, W15), transformer Z4-Z5 en Z2 tue la logique du bloc : les 4 semaines W13-W16 visent explicitement la **spécificité métabolique race-pace**. Réduire l'intensité pendant ce bloc = perdre 3-4 semaines de préparation spécifique. Le template ne propose pas d'alternative (ex : intensification raccourcie W13-W14.5 au lieu de W13-W16, puis cutback W15 pull forward).

## Contradictions

- **Safety_notes vs réduction d'intensité en overreaching** : les drapeaux rouges (FC repos +8-10 bpm, dégradation perfs, sommeil non-réparateur) sont exact¹s signaux d'une semaine basse-énergie. Le template dit "si 3+ signes → retour cutback immédiat". Cela implique que la semaine de fatigue DOIT être traitée comme cutback (W4/W8/W12/W16 clones), pas une réduction partielle. Une réduction de 40% (comme proposé ci-dessus) n'est pas assez pour un vrai overreach : la sécurité demande 50-60% réduction ou repos complet.

- **Progression_logic + chaînage brick** : le plan ancre les brick à chaque semaine (W1 J6, W2 J6, W3 J6, etc.). Si on saute le brick de W9, les séances solo de W10 J2 (sortie longue Z2 155 min) arrivent sans avoir intégré les sensations du dernier long-brick transition. C'est un risque mineur mais le template assume une continuité brick chaque semaine (sauf les cutback où ils sont déjà réduits).

- **Affûtage W17-W19 et fenêtre de fraîcheur** : si fatigue W14-W15 force un report du bloc intensification (W13-W16 → W14-W17), l'affûtage W17-W19 chevauchera la nouvelle semaine W17, compressant la fenêtre optimale (Bosquet et al. : 40-60% réduction sur 2-3 semaines avant la course). Un décalage de 1 semaine ne rentre plus dans la fenêtre → gain potentiel perdu.

- **Nutrition cutback vs fatigue basse-énergie** : safety_notes indiquent "perte d'appétit + perte poids inexpliquée" comme signe d'overreach. Si c'est le cas, réduire juste les séances ne suffit pas : il faut aussi **augmenter la nutrition globale** (200-300 kcal/jour surplus) et les glucides de récupération. Le template d'entraînement ne couvre pas cette dimension.