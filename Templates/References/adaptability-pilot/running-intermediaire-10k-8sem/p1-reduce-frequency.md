# Adaptability : running-intermediaire-10k-8sem + p1-reduce-frequency

## Rigidity score
**6/10**

Le template est modérément flexible. La structure tripartite (intervalles + tempo + long run) est le fondement du plan, et supprimer 1 séance/semaine crée un conflit direct avec la `progression_logic` (principe 1 : "chaque semaine contient 1 séance intervalles + 1 tempo + 1 long run"). Cependant, les sessions peuvent être fusionnées (mixed sessions) et les volumes peuvent se réorganiser sans casser les invariants fondamentaux (progression long run, cutback W5, tapering W8).

## Patch approach

Stratégie : **fuser tempo + renforcement en priorité**, maintenir les **intervalles une fois/semaine** (stimulus VO2max non négociable), préserver le **long run progressif intact** (endurance aérobie = socle). Le coût : réduire légèrement les volumes de tempo/renforcement et sacrifier une séance de qualité certaines semaines pour tenir 2 séances. Adapter semaine par semaine pour respecter l'invariant "48h minimum entre deux séances de même nature".

## Concrete modifications

- **W1 J1** Test 5K + renforcement → **FUSIONNER avec J5 long run** : J1 = Test 5K unique (55 min seul), J5 = Long run 6 km + renforcement complet post-séance (lieu de fusion du renforcement). **Suppression J3 tempo découverte**.
- **W1 J5** Long run 6 km → **DEVENIR** : Long run 6 km (55 min) + renforcement post-course : nordic curl 3×6, single-leg calf 3×12, clamshell 3×15, planche 3×40 sec (économiser du renforcement J1).

- **W2 J1** Intervalles 5×400 → **MAINTENIR intégralement** (40 min).
- **W2 J3** Tempo 22 min + single-leg squat/nordic → **DÉPLACER** : fusionner dans une **J4 optionnel "renforcement légèrement plus tôt"** OU **J5 post-long-run**. Recommandation : **supprimer J3 tempo**, faire J1 intervalles + J5 long run 7 km + renforcement (3×80 min).

- **W3 J1** Intervalles 5×400 m + 2×200 m finisseurs → **MAINTENIR intégralement** (50 min).
- **W3 J3** Tempo 25 min + renforcement → **SUPPRIMER J3**. **J5 long run 8 km** devient **J5 = long run 8 km + tempo "raccourci" 15 min en fin de journée OU fusion préalable** : **J1 = intervalles 5×400 m + 2×200 m + 5 min footing récup**, **J5 = footing très lent 5 min + tempo 20 min (allure seuil, RPE 7) intégré avant le long run 8 km** → totalement impossible sans créer répétition jour même. **Option réelle : J1 intervalles 50 min**, **J4 ou J5 tempo 20 min standalone court** (40 min total courte séance). **Ou J5 = long run 8 km uniquement, tempo déplacé à J2 très facile 20 min** (violant "jours de repos"). **Décision : J1 intervalles + finisseurs 50 min, J5 long run 8 km 70 min, abandonner tempo W3** (coût acceptable : 1 semaine sans seuil sur 8).

- **W4 J1** Intervalles 3×800 m → **MAINTENIR** (55 min).
- **W4 J3** Tempo 28 min + renforcement → **SUPPRIMER**. **J5 long run 9 km 80 min seul**.

- **W5 (Cutback) J1** Intervalles 4×400 m → **MAINTENIR allégé** (42 min).
- **W5 J3** Tempo 20 min + renforcement réduit → **SUPPRIMER J3 entièrement** (cutback justifie réduction supplémentaire). **J5 long run 7 km 62 min seul** (pas de renforcement post, jour repos complet J2-J4-J6-J7 maintenu).

- **W6 J1** Intervalles 4×800 m → **MAINTENIR** (60 min).
- **W6 J3** Tempo 30 min + renforcement → **SUPPRIMER J3**. **J5 long run 10 km premier 10K** (90 min seul, pas de renforcement post pour fraîcheur).

- **W7 J1** Intervalles 5×800 m → **MAINTENIR** (65 min).
- **W7 J3** Tempo 32 min + renforcement → **SUPPRIMER J3**. **J5 long run 11 km** (100 min seul).

- **W8 (Tapering) J1** Long run 12 km → **MAINTENIR** (105 min seul).
- **W8 J3** Activation 15 min + strides → **MAINTENIR** (35 min léger J3, intégralement compatible 2-séances).
- **W8 J5** Séance phare 10 km à allure cible → **MAINTENIR** (90 min).

## Rigidity issues

- **Principe 1 violé (tripartite hebdo) en W3, W4, W6, W7** : suppression totale des séances tempo ces semaines. Tempo/seuil est décrit comme "obligatoire et complémentaire" aux intervalles — cela crée un écart par rapport à la méthodologie Hal Higdon / Jack Daniels. **Compromise : accepter que 50% des semaines (~4 sur 8) perdent le stimulus seuil ; concentrer tempo sur W2, W5, W7 (alternance irrégulière).**

- **Renforcement réduit drastiquement** : Nordic curl 3×6 et clamshell 3×15 ne peuvent se caler qu'en fin de long run (jamais avant). W3-W4-W6-W7 perdent complètement single-leg squat et side plank. La `progression_logic` section (4) stipule renforcement "en fin de session", et le template construit un protocole excentrique (Alfredson, NSCA) sur 8 semaines — l'adapter à 2 séances/semaine perd cette progression progressive (reps nominales impossible à honorer).

- **48h minimum entre séances similaires respecté partiellement** : J1 + J5 = 4 jours écart (acceptable). Mais absence de tempo 4 semaines pose risque "oubli stimulus seuil" — même si volument réduit, deux stimuli (VO2max + endurance) sans seuil ne couvrent pas la physiologie 10K optimale (ACSM recommande 20-40 min seuil/semaine).

- **Cutback W5 devient trop allégé** : abandon total du tempo (au-delà du cutback logique). Section `progression_logic` (3) stipule "intervalles réduits à 5×400 m au lieu de 3×800 m" + "tempo 20 min au lieu de 28" — la suppression J3 cutback + absence W6 tempo + absence W7 tempo créent un vide de consolidation osseuse/tendineuse non compensé.

## Contradictions

- **safety_notes vs suppression tempo W3-W4-W6-W7** : La section `progression_logic` (1) affirme "les deux types d'intensité (seuil + VO2max) sont obligatoires et complémentaires". Réduire à 2 séances/semaine et choisir J1 intervalles + J5 long run = **abandon du stimulus seuil alternativement**. Cela crée un déséquilibre vis-à-vis de la physiologie ACSM recommandée (lactate threshold training couplé à VO2max). **Risque non bloquant mais non optimal** : le coureur gagnera en endurance (long run) et puissance aérobie (intervalles), mais perdra efficacité économique (seuil). Bénéfice final : probablement 10K possible en 60-75 min (objectif maintenu), mais sans le "polish" tempo.

- **Renforcement "jamais avant" vs fusion post-long-run** : `safety_notes` section intensité stipule "le renforcement est en fin de session (jamais avant), pour ne pas compromettre la qualité de course". Fusionner nordic curl / clamshell + 6-11 km long run : les coureurs feront 60-100 min de course continue avant renforcement → fatigue neuromusculaire extrême pour exercices excentriques (nordic curl, calf raises). **Risque mitigation** : faire renforcement en **tant que séance ultra-légère séparée (J2 ou J4 repos actif, 15-20 min uniquement)** plutôt que post-course. Mais cela ajoute une 3e séance légale "repos actif" — solution en demi-teinte.

- **Volumes renforcement régressent vs plan original** : W1 = 3 séries 6 nordic ; W7 original = 3×10 nordic. Adapter en post-long-run réel W7 (après 100 km de volume courte) rend le 3×10 nordic irréaliste. **Solution concrète** : limiter renforcement post-long-run à **1-2 séries récupération mentale** (renforcement seuil d'adaptation minimum), abandonner progression linéaire W1→W8 des reps (coût d'adaptabilité accepté).

- **Tapering W8 inchangé mais moins de volume précédent** : W8 prévoit "réduction volume 40-60%" par rapport à W7. Original W7 = 65 + 60 + 100 = 225 min, W8 = 105 + 35 + 90 = 230 min (légère hausse, tapering appliqué par intensité réduite). **Adapter W7→W8 en 2 séances** : W7 = 65 + 100 = 165 min, W8 = 105 + 35 + 90 = 230 min (hausse 39%, contraire tapering idéal). **Mitigation** : réduire W8 J1 de 12 km à 10-11 km (économiser 10-15 min) → W8 = 105-115 min, soit réduction ~30% vs W7 (acceptable).

---

## Résumé adaptation concrète semaine-à-semaine

| Semaine | J1 (min) | J5 (min) | Changement clé | Coût |
|---------|----------|----------|---|---|
| **W1** | Test 5K (55) | Long run 6 km + renforcement court (60) | Fusion renforcement dans J5 | Pas de J3 tempo |
| **W2** | Intervalles 5×400 (40) | Long run 7 km + renforcement (70) | Fusion renforcement dans J5 | Pas de J3 tempo |
| **W3** | Intervalles + finisseurs (50) | Long run 8 km (70) | **Suppression J3 tempo** | Perte stimulus seuil W3 |
| **W4** | Intervalles 3×800 (55) | Long run 9 km (80) | Suppression J3 tempo | Perte stimulus seuil W4 |
| **W5 (cutback)** | Intervalles 4×400 (42) | Long run 7 km (62) | Suppression J3 tempo + renforcement allégé | Cutback accentué (accepté) |
| **W6** | Intervalles 4×800 (60) | Long run 10 km premier 10K (90) | Suppression J3 tempo | Perte stimulus seuil W6 |
| **W7** | Intervalles 5×800 (65) | Long run 11 km (100) | Suppression J3 tempo | Perte stimulus seuil W7 |
| **W8 (tapering)** | Long run 10-11 km (105 → réduit à 100) | Activation (35) | Séance phare J5 (90) | W8 J1 réduit pour tapering réel |