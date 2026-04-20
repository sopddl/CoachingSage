# Adaptability : running-intermediaire-10k-8sem + p4-more-ambitious-goal

## Rigidity score
**3/10**

## Patch approach
Le template est **structurellement rigide** pour une escalade d'objectif ambitieuse. L'architecture W1-W8 (progression linéaire 6→12 km, cutback W5, tapering W8) est calibrée pour UN objectif : courir 10 km en 55-70 min. Passer à un objectif supérieur (ex : 10K en sous-55 min, ou semi-marathon 21 km, ou marathon) exige non seulement d'allonger les semaines, mais de **reconfigurer radicalement** la progression_logic, les volumes, et la logique de cutback. On ne peut pas simplement "augmenter les km" ou "accélérer les allures" sans casser les invariants du plan (règle 10-20%, protection tendineuse, ratio intensité/volume).

## Concrete modifications
**Scénario testé : passer de "10K en 55-70 min facile" à "10K en sous-48 min / capacité semi-marathon 21 km"**

### Si objectif = 10K en sous-48 min (niveau avancé sur la distance)
- **W1 J1** (Test 5K) : **pas de modification** — le test reste la référence VDOT.
- **W1 J3, W2 J3, W3 J3, W4 J3** (Tempo) : **intensité inchangée** (allure 5K + 30-45 s/km reste juste), mais **ajouter 1 min/semaine** : 20→22→24→26 min (vs plan 20→22→25→28 min). À W8, tempo = 35-38 min au lieu de 32 min pour préparer un effort 10K soutenu (RPE 7.5/10).
- **W1 J1, W2 J1, W3 J1, W4 J1, W6 J1, W7 J1** (Intervalles 400-800 m) : **ajouter des répétitions ou réduire les récupérations** dès W3 : passer de 5×400 m à 6×400 m (W2), puis 3×800 m à 4×800 m plus tôt (W3 au lieu de W4). W7 : 6×800 m au lieu de 5×800 m.
- **W5 long run cutback** : garder 7 km (cutback obligatoire pour tendons), mais **rajouter une W5 bis ou prolonger W6** : faire 2 semaines pré-cutback (W4, W4bis) avant cutback W5, pour accumuler plus de volume aérobie avant la décharge.
- **W6 long run (10 km) → W6 long run 11 km** : avancer la distance 11 km dès W6, puis W7 = 12 km, puis W8 J1 = 13 km. Objectif : habituer le corps à courir 11-13 km, rendant 10 km "très facile" pour la course finale.
- **W8 J5 (Séance phare 10 km)** : **allure cible inchangée** mais **ajouter 2×1000 m en "finisseur" après 8 km**: les 2 derniers km doivent être courus à RPE 8/10 (sous-48 min nécessite des 2 derniers km agressifs, pas relaxation). Ou remplacer la séance phare par **3×3.33 km à allure cible avec 90 sec récup**, simulant la gestion d'efforts répétés sur 10 km.

### Si objectif = semi-marathon 21 km (escalade majeure)
**Le template ne peut PASÊTRE patchable simplement : il faudrait 10-12 semaines minimum, pas 8.**
- **Structure : repousser W8 à W10-W12.**
- **W1-W4** : inchangé (fondations).
- **W5** : cutback (consolidation).
- **W6-W7** : long run 10→11→12 km (allure facile).
- **W8** : long run 14 km, tempo 35 min, intervalles 5×1000 m (nouvelle distance de travail).
- **W9** : long run 16 km, tempo 40 min, intervalles 6×800 m.
- **W10** : cutback bis (volume -15%), long run 13 km.
- **W11** : long run 18 km, tempo 40 min, intervalles 4×1200 m.
- **W12 (tapering)** : long run 21 km allure très facile (J1), activation 15 min + strides (J3), séance phare 21 km à allure semi-marathon cible (J5).

**Verdict : semi-marathon = **reconstruction du plan, pas patch**. Coût d'adaptation : haut. Risque de blessure : haut (durée 12 sem exige suivi médical + nutrition optimisée).**

## Rigidity issues

1. **Durée fixe 8 semaines** : Le template suppose une adaptation physiologique maximale en 8 semaines. Passer à un objectif ambitieux exige 10-12 semaines. Allonger simplement en dupliquant W7-W8 casse la logique de tapering (tapering doit être court : 5-7 jours avant l'objectif, pas 2 semaines).

2. **Progression long run verrouillée (6→7→8→9→7→10→11→12)** : Cette séquence est alignée sur la règle 10-20% et la défatigue W5. Pour un objectif ambition au-delà (21 km), il faudrait décaler tout : 6→7→8→9→10→11→12→14→16→18→21. Ajouter des semaines = reconcevoir l'interpolation.

3. **Intervalle VO2max limité à 800 m max** : Pour sous-48 min sur 10K (rythme ~4:45 min/km), les répétitions à allure 5K seule ne suffisent pas. Il faudrait des **800 m à allure 5K, puis des finisseurs 200 m à allure 10K rapide** (ex : W7 : 4×800 m + 4×200 m en allure 10K sous-50 min). C'est un mélange d'efforts qui n'est pas dans le template original.

4. **Tempo plafond 32 min** : Pour un 10K très rapide, le tempo doit monter à 35-40 min à allure seuil. Mais si le plan ne dure que 8 semaines, on ne peut monter à 40 min sans **compromis sur les intervalles** (tu ne peux pas faire 40 min tempo + 5×800 m + 12 km long run en même semaine sans surcharge).

5. **Cutback W5 non renégociable** : La cutback est justifiée physiologiquement pour la consolidation tendineuse. Essayer de la "sauter" ou la réduire à -10% au lieu de -15% pour gagner du volume = augmente le risque de périostite tibiale ou tendinopathie (surtout si intensité ↑ en même temps).

6. **Safety notes vs escalade d'intensité** : Le plan cite Nordic curls, single-leg squats et calf raises comme protection contre tendinopathie ischio-jambière, PFPS et tendinopathie achilléenne. Augmenter l'intensité (allures plus rapides, plus d'intervalles) **aggrave ces risques** si le renforcement ne monte pas proportionnellement. Le template ne donne pas de progression du renforcement pour niveaux avancés (ex : nordic curls "sans assistance" dès W5, single-leg squat pistol complet dès W6).

## Contradictions

1. **progression_logic §1 (Tripartite structure) vs escalade d'allure** : La progression_logic affirme "les deux types d'intensité (seuil + VO2max) sont obligatoires et **complémentaires**". Pour un 10K sous-48 min, tu dois ajouter un **troisième type** : "seuil rapide" (allure 10K rapide maintenue 15-20 min), qui n'est pas dans le plan. Ou alors tu augmentes la fréquence (4 séances/sem au lieu de 3), ce qui casse la règle "48h minimum entre deux séances de même nature".

2. **progression_logic §2 (Règle 10-20% long run) vs semi-marathon** : La progression 6→7→8→9→7→10→11→12 km respecte +10-20% par étape. Pour semi-marathon (21 km en 12 semaines), la séquence serait ~6→7→8→9→10→11→12→13→14→16→18→21 km. Entre W11 (18 km) et W12 (21 km) = +17%, acceptable. Mais W10 (cutback = 13 km) vers W11 (18 km) = +38%, **viole la règle "pas plus de 10-20% par semaine**. Risque : tendinopathie et surcharge.

3. **safety_notes "Douleur face postérieure cuisse pendant intervalles" vs augmentation de volume fractionné** : Pour escalader à 10K rapide ou semi-marathon, tu ajoutes des intervalles (5→6→6 répétitions de 800-1000 m, ou ajout de finisseurs 200 m). Mais la safety_notes cite déjà "tendinopathie ou déchirure ischio-jambière" comme "risque n°1 du coureur intermédiaire qui augmente le volume fractionné". **Augmenter le fractionné sans augmenter proportionnellement la fréquence de Nordic curls = risque accru.** Le plan propose Nordic curls 3×6-10 reps en W1-W7. Pour semi-marathon + escalade, il faudrait Nordic curls 3-4× par semaine (pas just 1× par semaine en W3 J3), ce qui exigerait une restructuration complète (4 séances/sem).

4. **Tapering W8 vs objectif ambitieux** : Le tapering W8 du plan (J1: 12 km très facile, J3: 15 min activation, J5: 10 km cible) est calibré pour un coureur ayant atteint 12 km = 120% de 10 km. Pour 10K sous-48 min, la séance phare J5 doit être + exigeante (strides à allure 10K rapide, pas juste allure cible "facile"). Pour semi-marathon, J5 ne peut pas être 21 km à vitesse race (c'est fatigant) — il faut plutôt 3×7 km ou 2×10 km + 1×5 km à allure semi-marathon, pas homogène. **Le template ne prévoit pas cette flexibilité de tapering.**

5. **Progression_logic §5 (Tapering) contradiction de durée** : "Le tapering de 5-7 jours pour un plan 10K". Si tu allonges à 10-12 semaines (semi-marathon), le tapering change : 7-10 jours est plus recommandé pour les distances plus longues (Mujika & Padilla, 2003). Mais le template n'adapte pas ; il laisse tapering fixe à 1 semaine.

6. **Niveau déclaré vs réalité d'escalade** : Le template dit "level : intermediaire" et "Coureur régulier capable de courir 5 km en 30-35 min sans difficulté". Passer à 10K sous-48 min (allure 4:48 min/km) = **saut de niveau vers avancé** (nécessite V̇O₂max ~60 ml/kg/min, temps 5K ~18-19 min au test W1 pour que l'extrapolation marche). Si le coureur réel teste 5K à 30 min (V̇O₂max ~53 ml/kg/min), **l'objectif sous-48 min est **non réaliste en 8 semaines**. Le template n'inclut pas de "checklist réaliste d'escalade" (ex : "si ton test W1 5K > 25 min, objectif semi-marathon en 8 sem = trop risqué").