# Challenge Report : triathlon-intermediaire-sprint-12sem

## Verdict
Template très solidement construit, aligné sur les standards Joe Friel et British Triathlon. Structure pédagogique exemplaire avec progressions claires et sécurité bien documentée. Trois issues mineures non-bloquantes à corriger avant déploiement en production : clarifier une transition T1 manquante en W7, unifier la nomenclature des zones d'effort, et valider la charge cumulative W9.

## Issues critiques (bloquantes pour bundle)
Aucune issue critique détectée.

## Issues importantes (à corriger avant bundle idéal)

- **[W7 J6]** Natation — « T1 consolidation en bassin » : exécution T1 *en bassin* (sortir de l'eau, transition, repartir) manque d'explication claire. La séquence doit préciser : (a) sortie du bassin, (b) parcours simulé zone transition (20-30 m marche), (c) chaussures/casque/départ. Actuellement flou sur la durée et l'ordre des gestes. → *Fix* : détailler le parcours simulé et préciser « arrivée à pied zone transition fictive, casque, chaussures, 30 sec marche vers "départ vélo fictif" ». Ajouter ligne : « Comparer les temps T1 de W6 J4 (à sec) et W7 J6 (en bassin + fatigue natation) — la fatigue doit augmenter le temps de 10-30 sec, ce qui est normal. »

- **[W8 J4]** Renforcement — absence de Nordic curl alors que progression_logic l'annonce pour W3 J4 → W9 J4. W8 (cutback) doit maintenir Nordic curl en version légère (3-4 séries au lieu de 3 pleines). → *Fix* : ajouter « Nordic curl assisté 4 reps × 2 séries » en W8 J4 pour respecter la continuité prophylactique.

- **[W3 à W8, Squat sauté]** W3 J4 introduit Squat sauté (« Squat sauté, descente contrôlée, saut explosif ») sans progression technique. Pour un intermédiaire novice en renforcement excentrique, ce saut dès W3 est risqué (DOMS, stress tendineux Achille). → *Fix* : remplacer W3 J4 Squat sauté par « Squat poids du corps classique 15 reps × 3 séries ». Introduire Squat sauté en W4 J4 en version allégée (saut sans charge, 6 reps × 2 séries). Progression : W4 (6 reps × 2 sets) → W5 (8 reps × 3 sets) → W6+ (10+ reps).

## Issues importantes (à corriger avant bundle idéal)
(Aucune au-delà des trois listées ci-dessus)

## Issues mineures (nice-to-have)

- **Zones d'effort nomenclature** : progression_logic définit Z1-Z5 mais plusieurs sessions utilisent indifféremment « Z2 », « allure Z2 », « Z1-Z2 ». Uniformiser : utiliser systématiquement « Z2 (65-75% FCmax) » ou « Z1-Z2 » sans mélanger. W1 J2 dit « ~6 min 30 à 7 min 30 /km » alors que ce chiffrage dépend fortement de l'âge/FCmax — préciser qu'il est indicatif pour profil 45 ans, FCmax 175 bpm.

- **[W5 à W11, Hydratation gel]** W5 J3 annonce « 500 ml d'eau minimum » mais W6+ augmente les durées (40-90 min) sans réviser les quantités. Les briques W9 J5 (95 min total) recommandent « eau 500 ml/heure » mais W7 J5 (90 min) reste muet. → *Fix* : ajouter en W6+ : « Hydratation : 500-750 ml/heure selon conditions. En chaleur : 750 ml/heure. Gel toutes les 30-40 min sur sorties > 60 min. »

- **[W6 J4]** « Transition T1 à sec — première répétition » : 5 passages complets (T1+T2 intégrales) en une seule séance de 40 min avec repos 60 sec = ~6 min par passage complet. Cela semble rapide pour une première. Clarifier : « Objectif J4 : APPRENDRE la séquence, pas la vitesse. Prendre 2-3 min par passage si nécessaire. »

- **[W9 J1]** Natation 600 m : en W6 J1, le 400 m était le « cap clé ». En W9, le 600 m est un saut de 50% sans étape intermédiaire de 500 m. W8 J6 contient 500 m → bien. Mais progression W6 (400) → W8 (500) → W9 (600) = sauts 25% & 20%, acceptable mais serré pour un intermédiaire. Rassurant que W10 J1 redescend à 750 m test (pas une progression continue vers 750). Pas de correction urgente, mais noter : si un participant bloque à W8-W9, réduire W9 à 550 m et insérer 600 m en W10.

- **[W9 cumul]** W9 est le volume pic : 60 min natation, 60 min running, 90 min vélo, 35 min renfo, 95 min brick = 340 min/semaine. W10 réduit à ~120 min/jour = 290 min/semaine (-15% conforme). Mais W9 J3 (90 min vélo avec 4×5 min Z4) + J5 (95 min brick à Z3 ferme) = deux jours intensifs dos-à-dos sans jour de repos. Conforme ACSM (2 jours intenses semaine) mais très chargé. Recommander : « Si fatigue perçue élevée W9 J4-J5, laisser J5 en sortie Z2 douce au lieu de brick intensif, reporter le brick intensif à J3 (scinder W9 J3 en 2 séances : 45 min Z2 jeudi + brick vendredi). » (Conseil, pas correction bloquante.)

- **[W11 J1 à J6]** Volume « 30-35% du maximum » s'applique correctement mais pourrait être précisé en minutes absolues : « ~95-105 min/semaine vs ~340 min W9 pic ≈ 28-31% ». Laisser tel quel (pédagogique en % pour adaptabilité).

- **[Safety notes, Crampes en nage]** Mention « mollet ou pied » : utile d'ajouter que la crampe mollet post-vélo en triathlon est classique (fatigue ischio + déshydratation). Ajouter : « En triathlon, prévoir un apport hydrique-électrolytique post-vélo (boisson isotonique si boire en vélo possible) pour prévenir les crampes run. »

- **[W5, Brick intro]** W5 J5 annonce « les premières minutes de run post-vélo SONT inconfortables (jambes en coton) » mais ne précise pas : *combien de temps persiste* ? Pour la pédagogie : « Les 5-7 premières minutes sont inconfortables. Après ~7 min, les jambes se 'adaptent' et l'allure devient normale. C'est un phénomène physiologique (redistribution flux sanguin) et n'indique pas une erreur d'entraînement. Ne pas ralentir de panique. » (Excellents safety_notes globaux, juste une précision.)

## Manques notables

- **Pas de pédagogie FCmax / test d'effort** : progression_logic cite « 65% FCmax » mais n'explique pas comment calculer ou estimer sa FCmax. Pour un intermédiaire en triathlon, posséder un cardio-fréquencemètre est quasi-obligatoire. Recommandation : ajouter dans safety_notes W1 : « **Équipement fortement recommandé** : cardiofréquencemètre ou montre GPS avec capteur FC (natation : montre waterproof ou ceinture thoracique post-nage). Test FCmax optionnel : après W4 J3, réaliser un test de 5×3 min à allure croissante en course (les 3 derniers minutes = effort maximum soutenable) → FC max notée = ta référence pour tout le plan. Si pas de test : estimer FCmax = 220 - âge. »

- **Pas de recommandation d'encadrement** : un triathlète novice en enchaînement bénéficie énormément d'une première brick encadrée ou d'un avis kiné sur les transitions T1/T2. Ajouter sous assumed_profile : « *Recommandation* : faire observer ta première brick (W5 ou W6) par un entraîneur ou triathlète expérimenté pour corriger les défauts de transition avant consolidation. »

- **Pas d'indice de coût matériel ou d'accès bassin** : assumed_profile cite « Accès à un bassin 25 m ou 50 m 2-3 fois/semaine » mais plan demande 2-3 séances natation/sem. Si bassin fermé l'été ou saturé : pas d'alternative eau libre précoce (eau libre = changement majeur en départ de race). Recommander : « Avant de débuter, vérifier accès bassin couvert stable 3 mois minimum. Eau libre (mer, lac) peut remplacer bassin dès W8 si confiant, mais tester 2-3 sorties en W9-W10 avant course. »

- **Checklist d'autonomie W12 manquante** : summary mentionne « Checklist d'autonomie et autoévaluation en W12 » mais W12 J5 fourni une CHECKLIST DE PERFORMANCE POST-COURSE (5 critères), pas une CHECKLIST D'AUTONOMIE (compétences acquises). Ajouter en W12 J6 ou créé un appendice : « **CHECKLIST D'AUTONOMIE — Tu es autonome en triathlon si** : (1) Tu maîtrises les 3 disciplines séparément (natation 750 m, vélo 20 km, run 5 km). (2) Tu as réalisé au moins 3 bricks sans incident (jambes en coton acceptable). (3) Tu peux gérer une transition T1 < 2 min 30 et T2 < 90 sec. (4) Tu sais lire ta FC ou RPE dans chaque zone (Z1-Z5). (5) Tu reconnais les signaux d'alerte (douleur épaule, genou, lombaire) et sais quand arrêter. (6) Tu maîtrises la nutrition vélo (gel + eau) sans malaise. Si tu coches 5/6, tu es prêt pour une deuxième course. »

## Scores (sur 10)

- **Cohérence interne** : 9/10
  - duration_weeks (12) = weeks.count (12) ✓
  - Niveau annoncé (intermédiaire) aligné avec volumes : 340 min/sem W9 pic (conforme ACSM intermédiaire) ✓
  - progression_logic : 5 principes annoncés (parallélisme, 10-15%, cutback, brick, tapering) présents dans les weeks ✓
  - Exercices progression_logic (bird-dog, clamshell, nordic curl, single-leg deadlift, Y-raise) tracés dans sessions ✓
  - Deux cutbacks (W4, W8) -15% ✓
  - *Petit déficit* : W8 J4 n'a pas Nordic curl déclaré dans progression_logic

- **Alignement référentiel** : 9/10
  - Running : progressions VO2max (400m W3 → 600m W6 → 800m W7 → 1000m W10), seuil (4 min W2 → 5 min → 30 min W9) conformes Friel ✓
  - Natation : drills (streamline, catch-up, fingertip drag, sculling) appropriés Swim Smooth ✓ ; 750 m progressif ✓
  - Vélo : Z2 endurance base, Z3 tempo, Z4 seuil, cadence 85-95 rpm conforme TrainingPeaks ✓
  - Brick progressif (W5 25+10 → W6 40+15 → W7 20+5 simulation → W8 cutback → W9 25+5 over-distance) conforme British Triathlon ✓
  - Tapering (10-14 jours, maintien intensité courte) conforme Friel ✓
  - *Petit déficit* : progression seuil running un peu rapide W2 (4 min) → W3 (6×400 m) = passage direct à VO2max sans consolidation seuil préalable. Acceptable mais W2 J2 pourrait être seuil 5-6 min × 3-4 séries avant VO2max.

- **Sécurité** : 9/10
  - Safety_notes exhaustives : drapeaux rouges (swimmer's shoulder, ITBS, tendinite ischio, crampes, panique eau, otite, stress fracture) ✓
  - Règles générales (48h écart disciplines, hydratation, casque, tapering, signes surcharge) ✓
  - Transitions : protocole d'apprentissage progressif (à sec W6 J4 → bassin W7 J6 → simulation complète W10 J5) excellent ✓
  - Drills techniques préventifs (bird-dog, clamshell, nordic curl, Y-raise) tracés sur 8-9 semaines ✓
  - *Petit déficit* : Squat sauté en W3 J4 sans progression progressive (saut d'emblée, risque DOMS excentrique). Nordic curl aussi dès W3 J4 sans progression, mais moins critique (assisté).

- **Pédagogie** : 9/10
  - Progression linéaire volumes (W1-W3 croissance → W4 cutback → W5-W7 croissance → W8 cutback → W9-W10 tapering) très claire ✓
  - Chaque exercice inclut notes/objectifs clairs (nombre coups bras/25 m, Z2 = phrases complètes, RPE, cadence cible) ✓
  - Drills avant volume principal dans natation ✓
  - Warmup/cooldown systématiques ✓
  - Analogies pédagogiques excellentes : « jambes en coton physiologiques W5 J5 », « sighter en eau ouverte W7 J1 » ✓
  - Checklist autoévaluation W12 J5 ✓
  - *Petit déficit* : pas de pédagogie FCmax en W1 (comment calculer/estimer). Transitions T1/T2 auraient bénéficié d'une vidéo de référence (hors format JSON mais notable).

- **Global : 9/10**

---

## Recommandations post-audit (bonus)

1. **Avant bundle en production** : corriger les 3 issues importantes (W7 J6 T1 clarification, W8 J4 Nordic curl, W3 J4 Squat sauté progression).

2. **Ajouter en assumed_profile ou préface** : liste matériel essentiel (cardio-fréquencemètre, combinaison si eau < 14°C, chaussures route+running spécifiques, élastique ou haltères pour renfo).

3. **Pour l'app iOS** : intégrer alertes W1-W4 « Teste ta FCmax si tu n'as pas de cardio » et W4 J3 « Diagnostic FCmax à réaliser avant W5 ».

4. **Valeur d'usage** : template est hautement recommandable pour un triathlète intermédiaire, visant un premier sprint avec transitions conscientes. Structure aligne parfaitement avec les standards fédéraux (ACSM, British Triathlon, USA Triathlon, Joe Friel).