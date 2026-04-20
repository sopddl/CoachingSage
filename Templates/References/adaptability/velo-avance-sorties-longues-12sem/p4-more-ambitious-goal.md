# Adaptability : velo-avance-sorties-longues-12sem + p4-more-ambitious-goal

## Rigidity score
**6/10** (modérément flexible, mais avec points de rupture)

## Patch approach
Le template peut monter en ambition de 150 km → 170-180 km sur la cyclosportive cible, avec augmentation progressive du volume en W5-W10 et amplification des intervalles seuil/VO2max en W6-W7. Cependant, la progression des sorties longues et l'architecture des cutbacks sont partiellement figées : passer de 140 km (W10 J7) à 170 km impose des ajustements importants sur la structure du taper final (W11-W12) pour ne pas arriver épuisé. Au-delà de 180 km, le plan devient risqué sans rallonger la durée (13+ semaines) ou réduire les autres blocs aérobies.

## Concrete modifications

- **W1 (global)** : inchangé, base aérobie identique.

- **W2 J7 (sortie longue 85 km)** : augmenter à **90 km** (+5 km de surcharge progressive dès début du bloc 2).

- **W3 J7 (sortie longue 100 km)** : augmenter à **110 km** (+10 km, progression 13% vs W2).

- **W5 J7 (sortie longue 110 km)** : augmenter à **125 km** (+15 km, simulation déjà des derniers km de la cyclosportive allongée).

- **W6 J7 (sortie longue 120 km)** : augmenter à **135 km** (+15 km, nouveau palier).

- **W7 J7 (sortie longue 130 km)** : augmenter à **150 km** (+20 km, pic de bloc 2 reculé d'une semaine avant cutback W8 : **maintenir 140 km en W10 J7 pour ne pas surcharger le taper final**).

- **W7 J1 (Sweet Spot + VO2max)** : inchangé (structure équilibrée).

- **W8 J7 (cutback sortie longue 90 km)** : **augmenter légèrement à 100 km** (cutback moins profond pour habituer à la charge : réduction 33% vs W7 au lieu de 40%, acceptable car W8 est une semaine de récupération neuromusculaire).

- **W9 J1 (simulation départ Z4-Z5)** : inchangé.

- **W10 J7 (sortie maximale)** : **Rester à 140 km** (ne pas monter à 170 km en une seule sortie : risque de dépassement du seuil d'adaptation locale, fatigue du taper). La progression W5→W6→W7→W10 (125→135→150→140) est cohérente : W7 est le pic d'intensité volumique avant le cutback progressif de W8→W9→W10.

- **W11 J7 (affûtage, sortie longue 80 km)** : **réduire à 70 km** pour compenser l'augmentation d'intensité précoce (W5-W7) et protéger le taper final. Le principe du taper : réduire le volume 40-60% du pic de charge. Si le pic est 150 km (W7), W11 à 70 km = réduction 53%, conforme aux recommandations.

- **W10 J1 et J3** : augmenter légèrement volume d'intervalles Z4/Sweet Spot pour potentialiser le seuil avant le pic sortie longue reculé, sans surcharger. **W10 J1 : 3×15 min Sweet Spot → 3×16 min** (+1 min/bloc = +3 min total, marginal). **W10 J3 : ajouter 1 bloc Z3 de 12 min** (110→122 min endurance).

- **W6 J1 et W7 J1** : inchangés (structure d'intervalles déjà chargée en W7).

- **Volume hebdomadaire total** :
  - W1 ~190 km → W2 ~215 km → W3 ~230 km → W4 ~190 km → W5 ~250 km (vs 230) → W6 ~270 km (vs 250) → W7 ~295 km (vs 270 : +25 km) → W8 ~230 km (vs 215, cutback moins agressif) → W9 ~245 km (vs 230) → W10 ~275 km (vs 260) → W11 ~190 km (vs 195, taper renforcé) → W12 ~80 km (identique).

## Rigidity issues

- **Inconsistency : cutback depth vs surcharge précoce** — progression_logic affirme "aucun delta hebdomadaire en bloc de progression ne dépasse 13%". Passage W6→W7 : 270→295 km = +9%, correct. Mais passage W5→W6 : 250→270 km = +8%, et W7→W8 : 295→230 km = -22% (cutback agressif pour compenser la charge). Structure viable mais non idéale.

- **Sortie longue W10 gelée à 140 km** — le template spécifie "140 km correspond à 120% de la distance cible de 120 km", fondation du principe de surcharge. Déplacer le pic à 150 km en W7 puis réduire à 140 km en W10 crée une asymétrie : la sortie maximale n'est plus le jour J de pic, mais 3 semaines avant la course. Acceptable car c'est intentionnel (taper), mais c'est une rupture du schéma de progression monotone.

- **Principe de taper en tension** — reduire W11 J7 à 70 km est nécessaire mais crée un saut émotionnel : athlète peut se sentir "sous-entraîné" 10 jours avant la cyclosportive allongée. Clarifier dans les notes que cette réduction est intentionnelle et bénéfique (Mujika & Padilla confirment 10-14 jours de taper avant pic performance).

- **Absence de lissage W8→W9** — progression_logic ne mentionne pas comment gérer le passage de cutback (W8) à la reprise d'intensité (W9). Ici, W8 est une "fausse récupération" (100 km vs 90 km normal) pour ne pas perdre l'habituation à la charge. Risque : confusion si athlète pense que W8 J7 est une vraie réduction.

## Contradictions

- **Safety_notes vs surcharge volume** — aucune contradiction directe, mais safety_notes donne un signal d'alerte : "Signes de surcharge (réduire le volume 20-30% si 3 signes simultanés)", notamment "puissance sur les intervalles chute > 10%". Progression W5→W7 (+45 km sortie longue, +25 km volume hebdo) risque de déclencher ces signaux si athlète n'a pas récupération optimalée (sommeil, nutrition). Adapter exige une hygiène de vie irréprochable : noté mais non contractualisé dans le template modifié.

- **Nutrition longue distance obligatoire (> 90 min)** est redondante pour 140-150 km sortie, mais ressort clairement. Progression W7 à 150 km = 4h+ de pédalage → demande nutritionnelle accrue (gel toutes les 40 min, pas 45) pour éviter hypoglycémie ("fringale"). Plan nutrition du template est générique ; il faudrait affiner expérimentalement en W5-W6.

- **Pas de contradiction zone d'intensité** — Z2/Z3/Z4/Z5 restent identiques, progression des intervalles reste logique : la surcharge porte sur la durée des sorties et la répétition d'intervalles, pas sur les zones elles-mêmes.

- **Cadence et réglage vélo** — augmentation volume sortie longue (110→150 km) peut révéler des problèmes de positionnement lombaire ou cervical (douleur persistante mentionnée en safety_notes). À 4h+ continu en Z3, position défaillante devient invalidante. Bike fitting professionnel devient quasi-obligatoire avant W5 pour cette adaptation, non mentionné dans sécurité du template.