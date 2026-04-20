# Challenge Report : running-avance-semi-marathon-12sem

## Verdict
Template d'excellente qualité, bundlable en l'état avec recommandation de 2 corrections mineures sur les étirements post-effort. Progression théorique exceptionnelle, alignement référentiel (Hal Higdon, ACSM) impeccable, sécurité proactive. Pédagogie claire et autonomisante.

## Issues critiques (bloquantes pour bundle)
Aucune issue critique détectée.

## Issues importantes (à corriger avant bundle idéal)

- **[W1-W12, toutes les séances]** Étirements statiques post-effort : les safety_notes stipulent « échauffement NON optionnel » mais ne mentionnent jamais de contre-indication à l'étirement statique immédiat post-séance. Or, l'ACSM running position statement (2007) et Yarrow et al. (2015) recommandent d'éviter l'étirement statique prolongé dans les 10 min suivant un effort intense (intervalles/tempo). Les étirements static de 40 sec/muscle présentés en cooldown post-VO2max et post-tempo (W1 J3, W1 J5, etc.) risquent de réduire l'effet EPOC et la supercompensation neuromusculaire. → **Fix** : remplacer étirements statiques immédiatement post-séances intenses par 2-3 min de footing ultra-léger Z1, puis étirement statique passif seulement après 10-15 min ou en routine du soir séparé.

- **[W6 J5, W10 J5]** Segments allure semi (3×5 min en W6, 4×2 min en W10) : les sessions mixtes tempo + segments ne précisent pas le repos total recommandé. Tempo 15 min + 3×5 min segments à 5:05-5:20 = ~30 min effort continu (ou quasi) mais segmenté. En W6 la notation "Récupération 90 sec trot entre segments" est claire, mais en W10 elle ne mentionne que "90 sec" sans préciser si c'est entre quels éléments (entre les 4 strides de 2 min). → **Fix** : ajouter ligne explicite « Récupération 90 sec trot ENTRE CHAQUE segment de 2 min. Durée totale session taper : 20 min seuil continu + 8 min segments (4×2 + 4×90 sec repos) = 28 min effort, 55 min séance ».

## Issues mineures (nice-to-have)

- **[W11-W12 intitulé]** Séances d'activation nommées « Strides et activation neuromusculaire » (W12 J3) mais aussi « Jogging d'activation » (W12 J1) : terminologie non stabilisée. Minor car sémantique, mais standardiser à « Activation » ou « Strides taper » pour cohérence UI/UX.

- **[Progression_logic, point 4]** La phrase « Cette session longue à allure spécifique est le stimulus d'entraînement le plus prédictif de la performance sur demi-marathon (Billat, 2001) » cite Billat 2001 sur VO2max, pas explicitement sur spécificité allure semi sur sortie longue. La référence est valide (Billat est autorité en running) mais la citation est légèrement extrapolée. Cosmétique. → Suggérer : « Cette session longue à allure spécifique simule les conditions glycolytiques de course (similaire à Billat, 2001) ».

- **[W9 J7 et W6 J7]** Sortie longue 23 km et 19 km : aucune mention du terrain. Les plans Hal Higdon précisent souvent « terrain plat si possible » pour les longues sorties. Devrait être précisé pour éviter un profil accidenté qui pénalise le taper plan.

## Manques notables

- **Gestion des conditions météorologiques en taper** : W11-W12 ne mentionne pas ajustement d'allure si chaleur ou froid extrême le jour J. Safety_notes couvre hydratation générale mais pas adaptation spécifique taper en canicule (réduire l'objectif de temps, augmenter hydratation passim). Pas critique (le coureur avancé le sait) mais notable pour un plan public.

- **Variabilité de l'indice de forme physique basale** : assumed_profile mentionne « 10 km en 50-60 min » (allure 5:00-6:00 min/km), fourchette large. Les zones d'intensité supposent un 10K en 5:30 min/km (FCmax 185 bpm). Si le coureur est réellement à 6:00/km (50 min × 10 km), les allures proposées sont 10% trop ambitieuses. Recommandation : ajouter note en semaine 0 recommandant un test 10K réel avant J1 pour calibrer FCmax et zones.

- **Absence de scenario d'injury par tendinite d'Achille post-taper** : safety_notes couvre l'Achille en général, mais pas le pattern particulier du taper où la réduction volume + accumulation psychologique peut révéler une blessure silencieuse 48h avant la course. Pas critique, mais devrait dire « Si douleur Achille > 3 jours avant le départ, envisager l'abandon ou départ prudent à allure réduite ».

## Scores (sur 10)

- Cohérence interne : 9/10
  - Volume hebdo 40→43→46→39→47→50→52→44→55→52→38→20 suit la logique +7-12% hors cutback déclarée. Toutes les qualités annoncées (VO2max + tempo, double intensité) sont présentes chaque semaine. Progression_logic et semaines alignées. Seule déduction : étirement statique immédiat post-intensité désaligne légèrement du dogme ACSM.

- Alignement référentiel : 9/10
  - ACSM running position statement (2007) : tempos 20-40 min ✓ (W1 2×10, W2 3×8, W3 30, W7-W9 35 min), VO2max 400-1000 m ✓, double qualité hebdo ✓, cutback tous les 3-5 sem ✓ (W4, W8). Hal Higdon Half Marathon Advanced : pattern endurance/seuil/VO2max/long ✓. Nordic curl et single-leg squat (Mjølsnes, Crossfit prevention) : explicites. Seule note : allure semi 5:05-5:20 vs un 10K présumé 5:30 est conservateur, bon call.

- Sécurité : 8/10
  - Drapeaux rouges exhaustifs et specifiques au coureur avancé (tendinite ischio, ITBS, stress fracture tibiale, tendinite Achille, PFPS). Nordic curl et clamshell explicitement préventifs et intégrés. Pattern hebdo 48h entre intenses ✓. Hydratation et récupération post-longue chiffrées. Signes de surcharge neuromusculaire listés (FC repos, allure dégradée, etc.). Déduction : étirement statique post-intensité non optimal, et absence de scenario injury en dernier week avant course.

- Pédagogie : 9/10
  - Chaque exercice a instruction, reps/durée, notes RPE/sensation, rest_seconds. Progression par paliers (400→600→800→1000 m en VO2max, 2×10→3×8→30 min seuil). Strides et échauffement systématiques pré-intensité. Checklist d'autonomie finale en W12 J7 → apprentissage de l'autodiagnostic. Allures chiffrées basées sur 10K. Seule faiblesse : pas de video link ou image anatomie nordic curl pour le novice dans sa tête, mais texte est clair.

- **Global : 8.5/10**
  - Un template avancé, cohérent, sûr et pédagogique. Deux corrections mineures (étirement post-intensité, précision repos W10) et un manque cosmétique (météo taper) le ramènent de 9.5 à 8.5. Bundlable immédiatement avec note de patch.