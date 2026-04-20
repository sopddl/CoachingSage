# Adaptability : triathlon-avance-distance-m-16sem + p2-short-sessions

## Rigidity score
**2/10**

Le template est **très rigide** face à la contrainte "séances ≤ 30 min". La structure repose sur un volume accumulé hebdomadaire (16-17 km course, 60-110 km vélo, 2000-3600 m natation) et des principes non négociables (cutback weeks, brick sessions, progressions 10-12%/semaine). Scinder ces séances ou réduire le volume casse les invariants du plan. Une séance natation de 45-70 min devient impraticable ; les bricks vélo+run sont indivisibles dans leur logique ; les long runs Z2 (50-90 min) ne peuvent pas être compressés sans perdre l'adaptation aérobie fondamentale.

## Patch approach

Aucune compression "intelligente" ne préserve l'intégrité du plan. Le seul patch viable est une **reconstruction partielle** : découper chaque semaine en 8-9 mini-séances courtes (20-30 min) au lieu de 7. Cela augmente les fréquences d'entraînement (de 7 à 9-10 séances/semaine), réduit le volume par session, mais préserve le volume hebdo ET les zones d'intensité. Cependant, cela crée trois problèmes majeurs : (1) fatigue de système nerveux central (9-10 séances/semaine sur 16 sem = risque surmenage), (2) perte des adaptations d'endurance (un 45 min Z2 natation ne peut pas être remplacé par deux 22 min + récup), (3) bricks impossibles (70-90 min vélo + 25-40 min run ne tiennent pas en 30 min).

## Concrete modifications

**Impossible sans violation des safety_notes et progression_logic.**

Exemples des incompressibilités :

- **W1 J6** (Vélo sortie longue 95 min) : réduire à 30 min = ~12 km Z2 au lieu de 30-35 km. Volume hebdo vélo W1 passe de 60 km à 42 km (- 30%). Violation de la règle des 10% par discipline.
- **W1 J7** (Run long 65 min = 50 min séance) : réduire à 25 min = ~4 km au lieu de 8-9 km. Volume hebdo course W1 passe de 22 km à 16 km (- 27%).
- **W5 J6** (BRICK 110 min) : impossible de caser en 30 min. Un vélo course à allure efficace demande minimum 45 min ; la transition 2 min ; la course post-vélo minimum 15 min = 62 min minimum incompressible.
- **W9-W11** (Séances VO2max natation 65-70 min ; CSS vélo 90 min) : aucune compression possible sans perdre l'intensité seuil/VO2max (repos entre intervalles ne peut pas être réduit sans casser l'adaptation physiologique).

## Rigidity issues

- **Cutback weeks (W4, W8, W12)** reposent sur la supercompensation après 3 semaines de surcharge. Si tu passes de 7 à 10 séances/semaine, tu AUGMENTES la charge systémique chaque semaine : les cutback weeks ne serviraient plus à rien, et le risque de blessure de surcharge (stress fracture tibiale, swimmer's shoulder, ITBS) devient **très élevé** (cf. safety_notes W9-W11).

- **Brick sessions** (W5 onwards) sont non-divisibles. Elles exigent un enchaînement immédiat vélo→course pour l'adaptation neuromusculaire. Scinder en "vélo 15 min J6a + course 10 min J6b" détruit l'effet pédagogique. La safety_notes précise : "BRICK SESSIONS OBLIGATOIRES en W9-W12" ; c'est un invariant structurel.

- **Progressions hebdomadaires 10-12%** (progression_logic, point 1) : si tu découpes chaque séance en deux, les volumes partiels deviennent incohérents. Exemple W2→W3 : le volume natation passe de 2200 m à 2400 m (+9%, conforme). Mais si tu dois faire cela en 5 mini-séances au lieu de 3, chaque séance en W2 moyenne 440 m, en W3 moyenne 480 m. Le système n'est plus "progressif par semaine" mais "progressif par jour" → perte de planification.

- **Seuils cardiaque/lactaté** (safety_notes, section RPE et intensité) : une séance seuil "10 min Z4 + 3 min repos + 10 min Z4" (W2 J2) ne peut pas devenir "5 min Z4 + 3 min repos + 5 min Z4" sans perte massive de stimulus. La durée totale en zone doit être ≥ 15-20 min pour développer le seuil lactique. Réduire à 10 min total = quasi pas d'adaptation.

- **Sorties longues Z2** (W1-W7 course, W1-W11 vélo) : la fondation aérobie exige > 50 min continus en Z2. Deux fois 20 min Z2 + récup ne crée pas l'adaptation cardiaque fondamentale (mitochondries, angiogenèse). Le template précise : "sortie longue ≥ 120% de la distance cible" (W10 goal, exemple 65 min run pour 10K course). Impossible en 30 min.

## Contradictions

**Contradiction majeure avec safety_notes :**

- Safety_notes, section SIGNES DE SURCHARGE : "FC de repos +8 bpm au réveil vs habituelle" est un drapeau rouge. Passer à 9-10 séances/semaine sur 16 semaines augmente **dramatiquement** le risque de surcharge chronique. Les cutback weeks (W4, W8, W12, W15) deviennent insuffisantes.

- Safety_notes, point sur les bricks : "minimum 1 brick/semaine dès W5" (progression_logic point 3). Un brick 30 min = 20 min vélo + 10 min run, sans jambes déverrouillées. La qualité neuromusculaire spécifique vélo→course (capteurs musculaires, ajustement moteur) ne se développe pas sur un micro-brick 10 min. La séance perd son but pédagogique.

- Safety_notes, section Nordic curls et ischio-jambiers : "si douleur installée, arrêt des intervalles 1-2 semaines, maintien Z2 uniquement". Sur 9-10 séances/semaine, les intervalles VO2max (W6-W11) occupent 4 séances. Le volume d'intervalles devient deux fois plus dense. Le risque de tendinite ischio-jambiers proximale explose (signal commun chez triathlètes avancés sur fractionné long).

**Contradiction avec progression_logic :**

- Point (2) : "BLOCS PÉRIODISÉS 4 SEMAINES, cutback en W4, W8, W12". Logique : 3 semaines de surcharge + 1 semaine -15% = cycle adaptatif. Si tu ajoutes des séances partielles (10 séances/sem au lieu de 7), tu changes la structure : les cutback weeks ne décroissent plus à -15% du volume hebdo complet, tu les décroches de la logique 4-semaine.

- Point (5) : "TAPERING W13-W16 : réduction -30% W13, -50% W14-W15, activation W16". Ces % présument 7 séances/semaine. Avec 10 séances/semaine en W1-W12, le tapering initial doit re-calibrer (10 × -30% ≠ 7 × -30%), et les cumuls journaliers deviennent inégaux → perte de cohérence.

**Contradiction avec les ratios volumes :**

- progression_logic point (1) : "Volume vélo pic (110 km) = 2.75× les 40 km de course ; natation pic (3600 m) = 2.4× la distance course". Ces ratios présument 7 séances/semaine distribuées spécifiquement. Avec 10 séances/semaine, tu dois re-distribuer arbitrairement (ex : 6 natation, 3 vélo, ? course) = rupture du ratio équilibré.

- safety_notes, "80% volume Z2, 20% Z3-Z5" : précis pour une distribution sur 7 séances. Avec 10 séances, chaque jour a des impacts différents (jour natation peut être 1 séance courte = 20 min Z2 ; jour vélo 2 séances = 15 min Z3 + 15 min Z2) → impossible d'assurer le ratio global.

---

**Verdict final :** Le template est conçu autour de **séances longues (45-110 min) et principes de periodisation rigides**. Une contrainte "30 min max" demande une refonte complète du plan (fréquence +40%, volume redistribué, cutback weeks repensées, bricks remplacés). Ce n'est plus une "adaptation" : c'est un **nouveau plan**. Aucune compression ne préserve l'intégrité physio et pédagogique du design.