# Challenge Report : tennis-avance-match-prep-12sem

## Verdict
Template bundlable en l'état avec très mineures clarifications. Structure cohérente, progressions linéaires justifiées, sécurité couverte exhaustivement. Alignement USTA/FFT solide. Quelques imprécisions pédagogiques sur les métriques de performance (% rentrée service, RPE subjectif) qui méritent des scripts d'autoévaluation explicites, mais aucune faille dangeureuse détectée.

## Issues critiques (bloquantes pour bundle)
Aucune issue critique détectée.

## Issues importantes (à corriger avant bundle idéal)

- **[W12 J5]** Checklist d'autonomie — critère 1 (SERVICE, taux de rentrée 60%) : L'expression « mon taux de rentrée 1er service a-t-il atteint 60% » dépend fortement du niveau adversaire et nécessite une métrique objective. → **Fix** : Ajouter "Compter objectivement : nombre de premiers services gagnants / nombre de premiers services tentés = ratio. Si ratio ≥ 60%, critère validé." Idem pour les double fautes : "Noter sur papier pendant le match : double fautes totales / (jeux gagnés + jeux perdus). Cible < 1 par set = 1 double faute max sur 6 jeux."

- **[W5 J1]** Pattern CD croisé → CD couloir (piège latéral) : Les instructions « envoyer 2 balles croisées identiques pour fixer l'adversaire » sont qualitatives. → **Fix** : Ajouter « Les 2 balles croisées doivent être à vitesse modérée (RPE 6), identiques en longueur (balle longue, > 1m du fond). Le contre-pied en couloir doit être + 20% plus rapide (accélération nette). » Rendre mesurable la différence de rythme.

- **[W1 à W12]** External rotation épaule avec élastique — tension d'élastique non spécifiée : Les instructions disent « élastique » sans indiquer la résistance. → **Fix** : Ajouter « Utiliser un élastique de résistance légère (couleur verte ou bleue typique). Si douleur > 2/10 en rotation externe, réduire l'élastique à une bande plus claire ou ajouter 5 cm de mou. La résistance doit permettre 15 reps sans compensation du tronc. »

- **[W6-W7]** Squat bulgare « charge progressive » : Les instructions W6 disent « augmenter de 2 kg vs W3 si RPE < 7 » mais W3 J3 n'indique pas la charge initiale. → **Fix** : Ajouter dans W3 J3 : « Poids du corps uniquement ou haltère 3-5 kg (cible RPE 7-8). Notation base pour progression : [charge initiale] kg par jambe. »

- **[W9-W11]** Match simulé officiel — durée et format vs objectif 2h : W7 J5 annonce « match simulé officiel 2h » et W9 J5 « match simulé officiel 2h avec gestion d'effort » mais W10 J5 réduit à « 2 sets complets (max 40 min par set) ». Incohérence d'affûtage : en W10, 2 sets de 40 min = 80 min max, très loin des 120 min objectif. → **Fix** : Clarifier « W10 = 2 sets complets ou jeu libre jusqu'à épuisement de 60-70 min (affûtage = durée réduite mais pas densité). W11 = 1 set complet + 3 tie-breaks (90 min total). » Justifier chaque réduction par la logique d'affûtage (intensité maintenue, volume réduit, fraîcheur musculaire).

## Issues mineures (nice-to-have)

- **[W2-W7]** Spider drill format 20/40 : La description rappelle le ratio match (1:3 de repos) mais ne précise pas la taille du court ou le placement des cônes. → **Amélioration** : Ajouter « Cônes placés : centres des 4 coins (baseline) + milieu des 2 lignes de fond (service line). Distance totale par circuit ≈ 30-35 m. »

- **[W1-W12]** Nordic curl « partenaire ou sous meuble lourd » : La stabilisation par « meuble lourd » est vague. → **Amélioration** : Ajouter « Meuble stable (table lourde) ou câble de sécurité enroulé autour des chevilles. Risque de blessure si le point de fixation cède. »

- **[W4-W8 cutback]** « Volume -20% » vs « durée session réduite » : Le calcul de -20% n'est pas explicité (reps, sets, ou durée ?). → **Amélioration** : Ajouter « Réduction de 20% = réduire le nombre de sets ou la durée totale de la séance de 20%. Exemple W3 J3 = 65 min → W4 J3 = 52 min (65 × 0.8). »

- **[W9-W11]** « Points faibles identifiés en W9 » mais pas de template de bilan structuré post-W9 : La consigne « personnaliser selon le bilan W9 » suppose un bilan écrit qui n'existe pas. → **Amélioration** : Ajouter en W9 J3 cooldown : « Écrire 3 lignes : (1) Quel pattern a échoué ? (2) Était-ce technique ou tactique ? (3) Drill prioritaire pour W10. »

- **[W5-W7]** « Compter le ratio de points gagnés par accumulation (3+ échanges) » : Cible « > 40% » est mentionnée en W1 J1 mais pas répétée après. Les KPIs disparaissent en W2+. → **Amélioration** : Rappeler les 3 KPIs service en W5 J1 (% rentrée 1er service, % rentrée 2e service, double fautes par jeu) et 3 KPIs d'échange (winners/fautes directes ratio, points par accumulation %, fautes directes non forcées).

- **[All weeks]** RPE cible mentionné en safety_notes (RPE 4-6 technique, 8-9 fractionné effort, etc.) mais pas systématiquement intégré dans chaque exercice. → **Amélioration** : Ajouter RPE cible dans chaque exercice de fractionné (ex. W2 J3 spider drill : « RPE 8-9 effort, RPE 2-3 récup »).

## Manques notables

- **Nutrition et hydratation intra-séance** : Safety_notes couvre hydratation match (150-200 ml par changement de côté) mais aucune directive pour l'hydratation des séances d'entraînement longues (W6 J1 = 60 min, W9 J5 = 2h). → **À ajouter** : « Hydratation séance physique : 250-500 ml eau avant, 150 ml toutes les 15 min si > 45 min, 500 ml après avec glucides (1.2 g/kg poids dans les 30 min post-séance pour les séances > 60 min). »

- **Progression de charge service** : La progression du service en vitesse n'est pas chiffrée. W3 J1 « service avec plan de jeu » ne précise pas la vitesse relative (% du maximum). W12 J1 « 70-75% » break avec le reste du plan. → **À ajouter** : « W1-W2 service : 60-70% max, focus placement. W3-W4 : 70-80%, focus régularité. W5-W7 : 80-90%, mix vitesse + placement. W9-W11 : 90-95%, vitesse compétition. W12 : 70-75%, activation légère. »

- **Ratio RI/RI épaule** : W9 J3 ajoute la rotation interne mais ne donne pas les reps/séries initiales ni le dosage vs rotation externe. → **À ajouter** : « Rotation interne : commencer W9 avec élastique léger, 15 reps × 3 sets, repos 45 sec (identique à rotation externe). Ne jamais dépasser 20 reps RI pour éviter la dominance RI/RE > 1 (ratio normal 3:2 RI:RE, ratio dangereux > 1:1 chez les serveurs). »

- **Feedback de technique pendant jeu sous fatigue** : W3 J1 demande de « travailler sous pression physique » (jeu après sprint) mais aucune rubrique « diagnostic fatigue » (quels coups se dégradent d'abord ?). → **À ajouter** : « Checklist dégradation technique sous fatigue (noter tout match longs) : (1) Premiers services plus courts / plus lents ? (2) Revers slice devient plus mou ? (3) Volée moins rapide ? (4) Footwork delayed (retard sur split step) ? Priorité de travail : corriger ce qui se dégrade en premier. »

- **Retour en cas de maladie / contagion inter-semaines** : Safety_notes couvre reprise après manque de séances mais pas gestion de maladie légère (rhume, migraine passagère). → **À ajouter** : « Maladie légère (rhume sans fièvre) : réduire volume de 50% la séance suivante. Maladie modérée (fièvre, fatigue extrême) : skippes la semaine entière, reprendre à la semaine -1. Ne jamais forcer sous infection active (risque de myocardite). »

## Scores (sur 10)

- **Cohérence interne : 9/10**
  - duration_weeks (12) = 12 weeks présentes ✓
  - progression_logic matérialisée dans tous les blocs ✓
  - Cutback à W4 et W8 présents comme annoncé ✓
  - Nordic curl et external rotation présents toutes les semaines ✓
  - Seule faiblesse : charges initiales non chiffrées (squat bulgare W3), progression de service en vitesse non linéarisée.

- **Alignement référentiel : 9/10**
  - Patterns USTA (service-volée W2, points construction W5-W7) couverts ✓
  - Fractionné tennis (ratio 1:2-1:4) appliqué (spider 20/40) ✓
  - Cutback every 3 weeks (W4, W8) aligné ACSM ✓
  - Tapering W12 (10 jours) conforme ✓
  - Progression ischio-jambiers (nordic curl W1-W12) justifiée NSCA ✓
  - Seule faiblesse : aucun test de FTP / seuil aérobie / V̇O₂max (spider drill estim VO2max mais pas quantifié).

- **Sécurité : 10/10**
  - Drapeaux rouges tennis complets (tennis elbow, conflit sous-acromial, tendinite ischio, entorse, stress fracture) ✓
  - Règles générales (chaussures, corde, hydratation, échauffement coude/poignet) détaillées ✓
  - Signes de surcharge (3+ signes → cutback immédiat) ✓
  - Rotation interne/externe équilibrage inclus W9 ✓
  - Corde tension 24-27 kg cité ✓
  - Glace préventive coude W2-W3 après services intensifs ✓
  - Aucun déficit détecté.

- **Pédagogie : 8/10**
  - Progression par paliers linéaire (W1 < W2 < W3) ✓
  - Instructions exercices claires (split step tenu, Nordic curl avec partenaire/meuble) ✓
  - RPE souvent cité mais pas systématiquement ✓
  - Respiration implicite (« respiration expiratoire » W9 J1 routine) mais pas explicite chaque exercice ✓
  - Cadence running / allure données pour tennis ? (N/A pour raquette) ✓
  - Checklist d'autonomie présente (W12 J5) mais 5 critères sont qualitatifs / nécessitent calibrage (« 60% rentrée service » sans contexte) ✗
  - Seule faiblesse : métriques de performance imprécises (% rentrée sans adversaire benchmark, RPE "7-8" sans échelle validée pour tennis).

- **Global : 9/10**
  Bien structuré, sûr, pédagogiquement solide. Les issues importantes sont des clarifications évidentes (charges, vitesses, métriques) qui ne bloquent pas le bundle mais optimisent sa précision. Checklist d'autonomie W12 est un point fort rare dans les templates commerciaux. Alignement USTA/FFT/ACSM démontre un travail d'expert.