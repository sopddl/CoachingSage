# Adaptability : velo-debutant-reprise-6sem + p1-reduce-frequency

## Rigidity score
**6/10**

Le template est construit pour 2 séances/semaine (sessions_per_week : 2), donc la contrainte utilisateur coïncide avec la structure de base. Cependant, la rigidité vient de trois points : (1) le volume hebdomadaire chiffré est calibré sur 2 sorties distinctes (courte + longue) avec une progression précise, (2) les exercices de renforcement en fin de séance longue forment une progression spécifique (planche 20→25→30→30→35 sec) incontournable selon la progression_logic, (3) la cutback W4 est déclarée "obligatoire" et non négociable. L'adaptation est donc possible mais demande une fusion intelligente des objectifs séance-à-séance, pas une simple suppression.

## Patch approach

L'utilisateur dispose déjà de 2 séances/semaine (le template en propose 2). L'adaptation consiste à : (1) conserver les deux séances hebdomadaires telles que structurées, (2) valider que le volume total (W1 : 85 min, W2 : 105 min, etc.) demeure cohérent avec les deux séances fusionnées, (3) absorber les blocs techniques ou travail de cadence dans la séance longue plutôt que comme séance dédiée. La structure est donc déjà adaptée, mais clarifier ce qui se passe si l'utilisateur ne pouvait gérer que **1 séance par semaine** (cas plus extrême : voir risques).

## Concrete modifications

**Contexte** : le template propose déjà 2 séances/semaine. Si l'utilisateur confirme pouvoir maintenir 2 séances/semaine, **AUCUNE modification requise** — la progression et les volumes sont alignés. Cependant, si réduction à **1 seule séance/semaine** était envisagée, voici le patch :

- **W1 J2** *Sortie découverte 40 min Z1* : fusionner avec J5 → créer une sortie unique de 60-70 min (40 min Z1 + 20-30 min Z2 progressif) + échauffement-cooldown étendus. Renforcement minimal (planche 20 sec × 2 séries au lieu de 3, pas de pont fessier ni calf raises). Volume heb : ~75 min au lieu de 85 min (DEFICIT -12%, acceptable pour W1 introductif).

- **W2 J2** *Sortie technique cadence 50 min* : incorporer les blocs cadence (3 min 95-100 rpm + 3 min 85 rpm, 4 × 6 min = 24 min total) dans les 20 premières minutes de la séance longue. **W2 J5** *Sortie longue 1h Z2* : devenir unique séance de 1h10 continu Z2 (absorbe les blocs cadence en échauffement, puis maintien Z2). Renforcement allégé : planche 25 sec × 2, pont fessier 12 reps × 2, pas de calf raises. Volume heb : ~85 min (au lieu de 105 min, DEFICIT -19%, risqué — voir contradictions).

- **W3 J2** *Sortie vallonnée 55 min* : fusionner avec J5 → séance unique 1h20 Z2 vallonné avec 2-3 petites côtes intégrées. Renforcement complet (planche 30 sec × 3, pont fessier unilatéral 10 reps × 3, bird-dog 8 reps × 3). Volume heb : ~100 min (au lieu de 130 min, DEFICIT -23%, risqué).

- **W4 J2** *Sortie Z1 récupération 45 min* : **CONSERVER OBLIGATOIREMENT** — cutback semaine ne peut pas être comprimée ou fusionnée sans casser la logique de surcompensation. Maintenir 2 séances (J2 + J5) à allure réduite. **W4 J5** *Sortie cutback 55 min + renforcement* : gardienne inchangée. Volume heb : ~100 min (cutback légitime, -23% vs W3 chiffré à 130 min, OK).

- **W5 J2** *Sortie tempo 1h avec blocs Z3* : conserver telle que structurée (blocs Z3 tempo = élément clé de préparation à W6). **W5 J5** *Sortie longue 1h20* : inchangée. Volume heb : ~130 min (CONSERVATION). Si fusion nécessaire : créer sortie unique 2h avec 3 blocs Z3 tempo (8 min chacun espacés de 5 min Z2) intégrés dans les 30 premières min, puis Z2 continu — volumineux et dangereux pour débutant (repos insuffisant intra-session).

- **W6 J2** *Activation 50 min Z1-Z2* : conserver (tapering pré-phare, séance critique 48-72h avant épreuve). **W6 J5** *Séance phare 1h30* : inchangée (l'objectif ultime du plan).

## Rigidity issues

- **Contradiction cutback-fusion (W4)** : la cutback W4 est explicitement déclarée "obligatoire" et "essentielle pour la surcompensation cardiovasculaire". Elle ne peut pas être fusionnée en une seule sortie sans perdre l'essentiel : deux séances légères espacées de 3 jours = récupération. Une seule sortie de 100 min en Z1-Z2 sur 7 jours = pas de stimulus de surcompensation. **Si réduction à 1 séance/semaine pour W4** : RISQUE MAJEUR d'absence de phase de récupération structurée.

- **Progression technique en cadence (W2)** : les blocs cadence sont décrits comme "introduction technique" à respecter en W2 via jour J2 dédié (24 min de blocs structurés). Si fusionné dans la sortie longue, le risque est la dilution : la fatigue de fin de séance longue (min 50-60) dégrade la qualité technique. Les blocs cadence perdent leur effet pédagogique.

- **Volume hebdo et progression_logic (W2-W3 réduction à 1 séance)** : la "RÈGLE DES 10-20%" établit W1 85 min, W2 105 min (+24%), W3 130 min (+24%). Si réduction à 1 séance/semaine, les volumes deviennent ~60-80 min (au lieu de 105-130 min), ce qui viole le delta progressif énoncé. La progression devient chaotique : W1 80 min → W2 85 min → W3 100 min, au lieu du scénario 85 → 105 → 130. **La progression_logic énonce "AUCUN delta ne dépasse 25% entre deux semaines de charge pleine"** — réduction à 1 séance crée une sous-progression intolérable.

- **Renforcement préventif (W3-W5)** : la progression_logic impose "planche : 20 → 25 → 30 → 30 → 35 sec" + bird-dog W3, side-plank W4. Si une seule séance de renforcement par semaine (fusionnée), les séries diminuent (de 3 × Xsec à 2 × Xsec) et la progression ralentit. Bird-dog et side-plank en W3-W4 n'apparaîtraient qu'une fois par semaine au lieu de deux (perte de stimulus).

## Contradictions

- **Safety_notes : "48h minimum entre les deux séances"** vs fusion à 1 séance/semaine = non applicable mais non-problème (pas deux séances, donc pas besoin de délai). Cependant, si utilisateur essaie de **compresser 2 séances en 1 jour** (ex : W2 J2 + J5 le même jour = 1h10 continu dans la même séance), cela crée une dose unique très élevée en débutant. Safety_notes ne couvre pas ce scénario et la progression_logic suppose une répartition sur 3 jours (W2 J2 et J5 = distance 3 jours). **Risque de surcharge mécanique** (genou, tendons quadriceps) si fusion journalière.

- **Cutback W4 obligatoire** vs contrainte "réduire à 1 séance/semaine" : si utilisateur ne peut faire que 1 séance/semaine dès W1, le cutback W4 perd son statut de "phase de récupération structurée". W4 devient indistinguible du reste du plan en termes de stimulus. Safety_notes dit "SIGNES DE SURCHARGE (3+ signes simultanés → semaine allégée conseillée)" — cela suggère une alternative au cutback structuré, mais c'est réactif, pas préventif. Contradiction implicite.

- **Blocs Z3 tempo (W5)** vs réduction à 1 séance/semaine (cas extrême) : W5 J2 = blocs Z3 tempo (24 min actifs sur 1h). Si fusionné dans une séance longue unique, le placement des blocs devient critique. Temps de récupération intra-séance réduit (5 min Z2 entre blocs) → accumulation de fatigue → risque de dérive en Z4 (non prescrit pour débutant) → violation de "ZONES D'EFFORT RESPECTÉES".