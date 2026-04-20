# Adaptability : tennis-debutant-initiation-8sem + p5-low-energy-week

## Rigidity score
**7/10**

Le template tolère bien un allègement circonstanciel grâce à sa structure modulaire (séances techniques et physiques séparées) et surtout grâce à l'existence d'une cutback week (W5) qui sert de modèle de réduction. Cependant, quelques invariants créent des frictions : la progression_logic est stricte sur l'ordre des couches techniques, et les rotations externes (W6+) ne doivent pas être sautées. Le template n'est pas rigide pour cette contrainte, mais il demande des arbitrages clairs.

## Patch approach

La stratégie est d'appliquer un modèle « cutback local » sur la semaine en cours (quelle qu'elle soit) en s'inspirant du protocole W5, puis de rattraper progressivement la semaine suivante. On réduit de 20-25 % le volume physique, on abaisse les RPE cibles (8-9/10 → 6-7/10 sur les intervalles), et on consolide plutôt que de progresser techniquement. Les exercices de prévention (excentrique wrist curl, rotations externes si W6+) restent intouchables. Si la fatigue s'étend > 2 semaines, on bascule sur un plan d'adaptation long terme.

## Concrete modifications

Cibles spécifiques selon la semaine en cours :

**W1-W2 (avant cutback naturelle)** :
- **J1 Technique** : garder l'intégralité (grip et feeling = faible charge cognitive, non négociable).
- **J4 Prépa physique** : réduire les séries de 3-4 → 2-3. Exemple W1 J4 : shuffle latéral 4 séries → 2 séries ; squats 3 séries → 2 séries. RPE cible : 6/10 au lieu de 7/10. Maintenir excentrique wrist curl (non introduit encore).

**W3** :
- **J1 Technique** : garder échanges et drills, mais limiter à 3 séries au lieu de 5 (paniers alternance CD/revers).
- **J4 Prépa physique** : sprint 5m×10 (15/15) → réduire de 2 blocs (passer de 3 blocs de 6 min à 2 blocs de 6 min). RPE travail : 7/10 au lieu de 8/10. Excentrique wrist curl : maintenu (3 séries).

**W4** :
- **J1 Technique** : échanges coup droit croisé 5 séries → 3 séries ; échanges revers croisé 5 séries → 3 séries ; jeu libre 4 min réduit à 2 min.
- **J4 Prépa physique** : cardio 15/15 (3 blocs de 6 min) → 2 blocs de 6 min. Éliminer 1 bloc entier. Squat sauté 3 séries → 2 séries. Excentrique wrist curl : 3 séries maintenues.

**W5 (déjà cutback naturelle)** :
- Aucune modification supplémentaire. C'est la semaine parfaite pour cette contrainte. Si fatigue persiste, passer la semaine 6 en mode réduit également.

**W6** :
- **J1 Technique** : services 8 reps × 6 séries → 8 reps × 4 séries. Échanges dirigés CD : 4 min → 2 min 30 sec. Échanges dirigés revers : 3 min → 1 min 30 sec. Combiné service + retour : 5 points × 4 séries → 5 points × 2 séries.
- **J4 Prépa physique** : sprint en étoile 30/30 × 4 séries → 3 séries. Back-pedal + volte-face : 6 reps × 4 séries → 6 reps × 3 séries. **Rotation externe band : MAINTENIR 3 séries** (c'est la prévention conflit sous-acromial — non négociable dès W6). Excentrique wrist curl : 3 séries maintenues.

**W7** :
- **J1 Technique** : services 10 reps × 3 séries → 6 reps × 2 séries. Jeu de points (5 min × 5 séries) → 3 min × 3 séries. Micro-jeu 7 points : 1 jeu × 3 séries → 1 jeu × 2 séries.
- **J4 Prépa physique** : Tabata 20/10 (4 blocs) → 2 blocs. Sprint en T : 4 reps × 4 séries → 4 reps × 2 séries. Rotation externe : 3 séries maintenues. Excentrique : 3 séries maintenues.

**W8 (semaine finale, tapering)** :
- Aucune modification. W8 J1 est déjà allégée par design (activation léger). W8 J4 (séance phare) est non renégociable — c'est la séance test. Si fatigue extrême : repousser W8 d'une semaine, refaire W7 en mode fatigué.

## Rigidity issues

- **Progression technique stricte (progression_logic, point 1)** : « Ne pas avancer en technique si le geste précédent n'est pas reproductible à 6/10 ». Si l'énergie est basse (W4-W5-W6), la fatigue affecte la coordinateur neuromuscular et le score de maîtrise du geste peut baisser temporairement. Risque : le débutant perd confiance et demande si on recule d'une semaine. Solution : rappeler que la fatigue mentale ≠ progression bloquée. Continuer la semaine réduite, reprendre le volume W+1 la semaine suivante.

- **Cutback week W5 unique** : il existe une seule cutback semaine planifiée (W5). Si la fatigue survient en W3 ou W4, on doit improviser un cutback local sans modèle structurel explicite dans le template. Cela demande du jugement pédagogique (pas de rigidité absolue, mais une certaine improvisation).

- **Rotations externes (W6+) et excentrique wrist curl (W3+)** : ces deux exercices ont été catégorisés comme « obligatoires » et « non négociables » dans progression_logic points 3. Toute réduction y compris une fatigue modérée va créer une tension cognitive : « mais le template dit que c'est obligatoire ! ». Clarifier : maintenir 3 séries minimum ≠ sauter entièrement. C'est une acceptation du template.

## Contradictions

- **Safety_notes § SIGNES DE SURCHARGE** : « Douleur persistante au coude ou à l'épaule > 24h après séance, FC de repos +10 bpm au réveil, courbatures profondes > 72h, perte motivation, qualité sommeil dégradée > 3 nuits » → 3+ signes = réduire le volume « comme une cutback week ». Le profil p5 décrit justement cette surcharge (fatigue, sommeil dégradé, stress élevé). L'appliquer = passer en mode cutback. Pas de contradiction, mais **confirmation que la stratégie est cohérente avec les safety_notes existantes**. Le template prévoit déjà ce cas via le protocole de surcharge.

- **Tapering W8** : progression_logic point 5 énonce « J1 allégée, J4 phare frais ». Si la semaine en cours s'étend jusqu'à W8, il faut protéger W8 J4 particulièrement. Solution : si fatigue en W7, réduire W7 mais garantir W8 à ~90 % du volume normal (au minimum 2-3 jours de repos avant W8 J4). Pas de contradiction, mais une priorité.

- **Aucune contradiction majeure** : le template possède assez de flexibilité et de garde-fou (safety_notes surcharge, structure technique modulable) pour absorber une semaine fatigué sans casser l'intégrité du plan. Les exercices de prévention restent en place, la progression technique pause mais ne régresse pas, et le rattrapage est prévu sur W+1.