# Adaptability : velo-intermediaire-endurance-10sem + p2-short-sessions

## Rigidity score
**2/10**

## Patch approach

Le template est **fondamentalement rigide** pour cette contrainte. L'architecture du plan repose sur trois piliers non négociables : (1) un long ride progressif de 45→80 km (colonnes vertébrales de la progression), (2) des séances d'intensité structurées (Z3/Z4) avec durées croissantes, (3) une récupération active de 25-32 km. Réduire toutes les séances à 30 min maximum casse irrémédiablement la logique physiologique du plan : la progression volumétrique disparaît, les adaptations cardiovasculaires ciblées (endurance aérobie longue) ne peuvent pas émerger, et les deux cutback weeks perdent leur sens.

Une adaptation "intelligente" nécessiterait de **reconstruire le plan de zéro** autour de séances courtes (probablement des blocs de micro-intervalles ou du fartlek sur 20-25 min utiles). Ce n'est plus du patching : c'est une refonte.

## Concrete modifications

**Approche tentée (non recommandée) :**

- **W1-W10 J1** (Long ride Z2 actuelle : 45→80 km / 80-190 min) → **Impossible de compresser**. Un 80 km ne peut pas se faire en 30 min (véhicule motorisé). Remplacement obligatoire : scinder en deux micro-sessions (ex : lundi 20 km + jeudi 20 km en semaines 1-2, puis augmentation parallèle). Casse complètement la structure de "un long ride par semaine".

- **W1 J3** (Cadence + Z3 : 60 min) → 30 min avec coupes : retirer les 4 séries cadence haute (3 min × 4), garder 2 blocs Z3 au lieu de 3. Résultat : 15 min échauff. + 10 min contenu + 5 min retour = 30 min. **Perte volumétrique critique** : volume Z3 divisé par 1.5.

- **W3 J3** (Tempo Z3 : 70 min) → Scénario 30 min : 10 min échauff. + 2 blocs Z3 de 6 min au lieu de 3 blocs de 10 min + cadence haute + 5 min retour. **Contradiction majeure** : la durée des blocs tempo chute de 10 min à 6 min, cassant la progression W3 → W5 (10→15 min planifiée) qui est inscrite en dur dans `progression_logic`.

- **W6-W9 J1** (Long rides 72 km / 175 min) → **Impossible à adapter**. Aucune compression viable.

## Rigidity issues

- **Long ride structure non fracturable** : le plan définit explicitement "un long ride par semaine" (W1 J1, W2 J1, etc.) et la progression 45→80 km suppose des efforts continus de 80-190 min. Scinder en deux sessions/semaine viole la structure hebdomadaire des 3 séances et perd le bénéfice physiologique du long ride continu (économie aérobie, résistance mentale, simulation du 80 km).

- **Progression des durées Z3/Z4 incompressible** : `progression_logic` prescrit "blocs tempo 5 min (W1) → 10 min (W3) → 12 min (W5) → 15 min (W7)". En 30 min total, la durée maximale des blocs devient 6-8 min. La progression linéaire disparaît ; on ne peut pas passer de 6 min à 12 min en 4 semaines sans casser le principe ACSM "10-15% augmentation par semaine".

- **Cutback weeks (W4, W8) perdent leur fonction** : une cutback week n'a de sens que si les semaines précédentes ont accumulé une charge volumétrique. Si toutes les séances de W1-W3 sont compressées à 30 min, W4 à 30 min n'apporte aucune récupération nouvelle — elle est déjà "en déficit" depuis le début.

- **Zones d'effort et durées minimales** : la `safety_notes` rappelle que Z3 (76-82% FCmax) nécessite 30-40 min en continu "chez un intermédiaire". En 30 min total de séance, on ne peut dédier que 8-10 min au contenu Z3 après échauff./retour. Cela viole les standards de développement de la capacité de seuil (Coggan & Allen).

## Contradictions

- **Contradiction W5 J1 / W6 J1 (long ride 65→72 km)** : la progression linéaire 65 km (W5) vs 72 km (W6) suppose un ratio effort/durée cohérent. Réduire les deux à 30 min détruit ce ratio. On ne peut pas faire un 65 km "résumé" en 20 min de pédalage réel.

- **Contradiction safety_notes vs. cutback logic** : `safety_notes` énonce "3+ signes de surcharge = semaine allégée supplémentaire". Si le cycliste manque la composante long ride (réduite à 20 km × 2 semaines au lieu de 45-80 km × 1), il ne gagnera pas les adaptations mitochondriales attendues. Le risque est inverse : **sous-entraînement**, pas surcharge. Les cutback weeks deviennent inutiles.

- **Contradiction W9 / W10 tapering** : `progression_logic` prescrit un tapering "50-60% du volume pic sur 7-10 jours" pour un 80 km cible. Si W9 est déjà en 30 min (soit ~20 km), le tapering W10 (40+20 km en J1+J3) est impossible sans augmenter le volume — l'inverse du tapering.

- **Contradiction assumed_profile** : le profil cible est "cycliste régulier tenant 40 km à 25-28 km/h, pratique 1-2×/sem". Un cycliste capable de faire 40 km implique une accumulation de volume long ride (pas possible en 30 min/séance). Le plan présume que ce cycliste a déjà une base aérobie ; scinder les longs rides casse cette base.