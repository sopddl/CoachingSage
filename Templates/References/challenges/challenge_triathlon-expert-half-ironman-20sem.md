# Challenge Report : triathlon-expert-half-ironman-20sem

## Verdict
Plan extrêmement bien conçu, aligné avec les standards World Triathlon, ACSM et Joe Friel. Structure progressive irréprochable, sécurité très documentée, pédagogie claire. **Bundlable en l'état avec remarques mineures uniquement.** Ce template est une référence de qualité pour un triathlon expert.

---

## Issues critiques (bloquantes pour bundle)
Aucune issue critique détectée.

---

## Issues importantes (à corriger avant bundle idéal)

- **[W6 J1 — Test 1900 m continu]** : L'exercice annonce "premier test de la distance course" mais la note dit "une pause courte (appui couloir) est autorisée". Contradiction : un "test continu" ne doit pas autoriser les pauses. → **Fix** : Soit confirmer "continu strictement sans pause" et retirer la clause, soit renommer en "1900 m avec pauses optionnelles autorisées" si c'est l'intention réelle.

- **[W10 J3 — Run long 105 min vs safety_notes]** : Les safety_notes citent "stress fracture tibiale sur volume expert" et "courantes sur les longues semaines". W10 = 105 min run > 1h40, qui ne repose que sur 3 semaines de progression (85 → 90 → 105 min en W7-W10). La sécurité ACSM préconise max +10% volume/semaine. Progression réelle : W9 (90 min) → W10 (105 min) = +16,7%, dépassant le seuil. → **Fix** : Réduire W10 à 100 min run (+ 11%), ou ajouter en safety une note spécifique : "Si douleur tibiale antérieure > 2/10 en W9-W10, réduire le run long de 20 min et compenser par nage/vélo."

- **[W11 Brick 160 min vélo + 55 min run]** : Durée totale 215 min après transition = ~3h35. L'allure annoncée est "allure race (Z3 soutenu)" pour le vélo = 75-85% FTP. Pour un expert visant 4-4h30 sur 70.3, cela simule bien les 3h30 de vélo réel (hors transitions en course). MAIS : la note dit "simulation la plus proche du jour J" alors que c'est 30 min de plus que la durée réelle attendue. → **Fix** : Clarifier dans la note : "Volume 160 min vélo est intentionnellement 70 min supérieur à la distance race (90 km ≈ 90 min pour expert) pour entraîner la capacité à tenir l'allure sous fatigue accumulée."

- **[W19 J7 — Jour de course, section "Vélo 90 km"]** : La note dit "Cadence 88-92 rpm" mais "Ne pas attendre la faim" sur nutrition. Or, les données ACSM pour 70.3 chez l'expert préconisent 60-90 g glucides/h, et la note dit "60-80 g". À 90 km avec départ conservateur (20 km à Z2 plus lent), l'athlète risque un apport insuffisant si dépense augmente en fin de sortie. → **Nice-to-have** : ajouter "si conditions chaudes ou montées, augmenter à 80-90 g glucides/h et eau à 900 ml/h."

---

## Issues mineures (nice-to-have)

- **[W1-W4 — Absence de test FTP/VMA baseline]** : Le plan mentionne "FTP cycliste connu ou estimé" dans assumed_profile, mais ne propose pas de test FTP ou VMA semaine 0 pour caler les zones avant W1. → Fix : Ajouter une "semaine 0" optionnelle : "Si FTP inconnu, faire un test 20 min (Zwift, vélo de route) semaine avant W1 ou utiliser une allure 5K réelle pour calculer la VMA course."

- **[W3 J2 — "Blocs tempo Z3-Z4"]** : La durée est "12 min à Z3-Z4 (76-95% FTP) + 5 min Z2", mais la note dit "Z3 les premières minutes pour entrer dans le bloc, Z4 sur les 8 dernières min" = non cohérent. 12 min annoncé, mais 4 min Z3 + 8 min Z4 = total cohérent? Manque de clarté. → Fix : Préciser "Bloc 1 : 4 min Z3 progressif → 8 min Z4 continu. Répéter 3 fois."

- **[W4 & W8 & W12 & W16 — Cutback weeks]** : Très bien identifiés selon Bosquet et ACSM. Cependant, la note W4 dit "Réduire le volume de 15-20%" mais les chiffres réels montrent : W3 ≈ 11 h, W4 ≈ 9 h = -18%, correct. W7 ≈ 13,5 h, W8 ≈ 8,5 h = -37% (non conforme annoncé 15-20%). → **Minor fix** : Clarifier dans progression_logic ou safety_notes : "Cutback W4/W8/W12/W16 : réduction volume de 15-25% selon la fatigue perçue. Si FC repos stable et récupération complète en W4, W8 cutback peut être jusqu'à 30%."

- **[W6 J6 — Transition T2 simulée]** : Note dit "Chronométrer. Viser < 90 sec." Cette cible (< 90 sec) est cohérente avec la note W14 J6 ("viser < 90 sec"). Mais en W19 J7 (race réelle), elle devient "< 90 sec" pour T2. Logique, mais un expert visera typiquement 60-75 sec. → Nice-to-have : ajouter "Experts : viser 60-75 sec, acceptables jusqu'à 90 sec."

- **[W14 J4 — Nage 800 m optionnel]** : La note dit "si accès plan d'eau ou piscine : nager 800 m...sinon, démarrer directement sur vélo". Contradiction : W14 est une séance de renforcement avec simulation T1, mais sans nage il n'y a pas de T1 réel. → Fix : Soit ajouter "**Recommandé** : accès à un plan d'eau ou piscine 50 m pour cette semaine critique", soit proposer une alternative : "Si sans plan d'eau : utiliser 5 min vélo très facile Z1 comme simulation T1."

- **[W5-W11 et W17-W19 — Nutrition pendant séance]** : Le plan cite "Nutrition : gel toutes les X min" mais ne spécifie jamais la **quantité** de gel recommandée (1 gel = 20 g glucides généralement, donc 3 gels/h = 60 g/h). Pour un expert, Precision Nutrition et ACSM 2026 suggèrent 1,0-1,2 g glucides/kg/h pour efforts > 2h. → Nice-to-have : ajouter une note en safety_notes ou progression_logic : "Nutrition = 1 gel (~20 g) toutes les 30 min, ou équivalent barres/boisson. Pour expert 75 kg : 75 g glucides/h = 3,75 gels, soit 1 gel tous les 20-25 min + 1 boisson glucosée toutes les 30 min."

- **[W15 J3 — Hill repeats 60 sec]** : Annonce "10 répétitions" de "montée 60 sec Z4-Z5 + descente trot". Durée totale estimée : 10 × (60 sec montée + 60 sec descente) = 20 min travail + échauffement 12 min + récup = 35-40 min, mais la séance annonce 70 min totales. → Fix : Clarifier "10 repeats = 10 montées de 60 sec (non 10 allers-retours). Durée réelle incluant échauff/récup : ~50-60 min." Ou réduire à 6-7 repeats pour tenir 70 min.

- **[W19 J7 — Cooldown post-race]** : La note dit "10 min marche lente après la ligne d'arrivée. Hydratation et alimentation dans les 30 min. Étirements légers 5 min." ACSM position stand sur la récupération immédiate recommande : 15-20 min décélération légère (trot ou marche), puis 0,8-1,2 g glucides/kg **dans les 15-30 min** (fenêtre critique). → Nice-to-have : corriger "Hydratation **immédiate** et alimentation (0,8 g glucides/kg) dans les 15 min, puis protéines 0,3 g/kg dans les 30 min."

- **[Absence de plan B météo]** : Le plan ne mentionne jamais l'impact des conditions météo extrêmes (forte chaleur, tempête, eau froide imprévue). → Nice-to-have : ajouter avant W19 J7 : "**Plan météo** : Chaleur extrême (>30°C eau) : augmenter hydratation à 900 ml/h, glaçage du cou en transitions. Eau froide (< 14°C) : tester la combinaison en W18, vérifier les bouchons d'oreilles. Pluie/vent : réduire les vitesses de descente en vélo, augmenter les temps de freinage."

---

## Manques notables

- **Absence de checklist d'équipement race day** : Le plan mentionne "casque OBLIGATOIRE", "pneus à vérifier", "chaussures > 600-800 km à renouveler", mais ne donne pas une liste complète pour W19 J7. → Suggestion : Ajouter en W18 J6 un exercice "Équipement checklist" : combinaison (lavée, ajustement revisité), vélo (changement 3e chaîne, pneus/pression, dérailleurs réglés), chaussures (neuves ou testées), numéro de dossard, timing chip, etc.

- **Pas de protocole de tapering spécifique pour sommeil/mentalité** : W17-W19 réduit l'entraînement mais ne propose pas de conseils sur la qualité du sommeil (ACSM recommande 7-9 h), hydratation pré-race (16-20 ml/kg les 2-4h avant), ou gestion du stress pré-compétition. → Suggestion : Ajouter en W19 J6 ou W20 J6 : "**Préparation mentale et sommeil** : Nuits W17-W19 = 8+ heures obligatoires. Visualisation 5 min 3x par jour W18-W19. Hydratation : 500 ml 3h avant la course, puis 250 ml 15 min avant."

- **Pas de plan pour athlètes avec antécédents de blessure** : Safety_notes cite les blessures courantes (stress fracture, tendinite ischio) mais ne propose pas de **modifications du plan** si l'athlète rentre avec une historique. → Suggestion : Ajouter une section "**Si antécédent de [blessure spécifique]**" (ex: "Si antécédent de stress fracture tibiale : réduire tous les runs longs de 20%, ajouter 1 séance nage supplémentaire W5-W11").

- **Absence de protocole de récupération entre double séances** : Progression_logic cite "Doubles séances AM/PM possibles selon le planning individuel" et safety dit "minimum 4 heures entre 2 séances. Nutrition post-première séance dans les 30 min". Mais aucune séance du plan n'est explicitement structurée en double séance (toutes les séances sont listées jour par jour). → Clarification : Est-ce que le plan assume 1 séance/jour ou permet des doubles séances optionnelles ? Si oui, donner un exemple W9 ou W11 en double séance optimisée.

- **Pas de test post-plan ou évaluation de progression** : Le plan W1 propose des tests (400 m nage, FTP) mais W20 propose une "checklist d'autonomie" sans **métriques objectives** mesurables. → Suggestion : Ajouter en W20 J6 : "**Tests de validation**. Comparer vs W1 : (1) Nage 400 m : chrono (ex: W1 5:10 → W20 4:50 = -12 sec, progrès). (2) VMA/allure 5K : (ex: W1 3:55/km → W20 3:45/km). (3) FTP (si home-trainer) : test 20 min W1 vs W20."

---

## Scores (sur 10)

- **Cohérence interne : 9/10**  
  ✓ duration_weeks = 20 cohérent avec 20 semaines listées.  
  ✓ Niveau "expert" correspond au volume (10+ h semaine, capable 2 km nage, semi-marathon).  
  ✓ Cutback weeks W4/W8/W12/W16 bien placées.  
  ✓ Brick sessions progressent : 15 min W1 → 55 min W11 (conforme à progression_logic).  
  ✗ Progression W10 run +16.7% (mineur, voir issue importante).

- **Alignement référentiel : 9/10**  
  ✓ Volumes hebdomadaires (W1-W4 ~10h, W9-W11 ~14-15h, W17-W19 affûtage) alignés Matt Dixon/Joe Friel.  
  ✓ Zones FC/FTP cohérentes avec ACSM 2026.  
  ✓ Progression parallèle 3 disciplines (pas séquentiel) = best practice World Triathlon.  
  ✓ Test 1900 m en W6, brick simulation en W11, transitions chronométrées en W14 = pédagogie race-specific excellente.  
  ✗ Absence de protocole tapering détaillé pour sommeil/nutrition pré-course (mineur).

- **Sécurité : 9/10**  
  ✓ Safety_notes extrêmement documentées (drapeaux rouges cardiaques, tibiales, épaules).  
  ✓ Nordic curl + single-leg squat pour prévention des blessures spécifiques run.  
  ✓ Récupération active J7 systématique chaque semaine.  
  ✓ Overreaching = 3+ signes monitoring.  
  ✗ Progression W10 run dépasse 10% recommandé par ACSM (mineur, voir issue importante).  
  ✗ Pas de protocole pour athlètes avec antécédents de blessure.

- **Pédagogie : 9/10**  
  ✓ Progressions claires : drills spécifiques eau libre (sighting, catch-up, EVF) → séries → allure race.  
  ✓ Briques bien construites : T2 temps fixés, observations de sensations notées mentalement.  
  ✓ Respiration/RPE/cadence systématiquement donnés (ex: "respiration bilatérale", "RPE 7/10", "cadence 88-92 rpm").  
  ✓ Checklist d'autonomie W20 J6 couvre 5 axes majeurs.  
  ✗ Pas de test objectif post-plan pour valider la progression.  
  ✗ W19 J7 note vélo "ne pas attendre la faim" mais nutrition très sommaire pour 90 km.

- **Global : 9/10**  
  Template de référence pour triathlon expert 70.3. Structure irréprochable, sécurité exceptionnelle, pédagogie progressive. **Corrections suggérées** : (1) Clarifier W6 test 1900 m "continu sans pause". (2) Réduire W10 run à 100 min ou ajouter alerte stress fracture. (3) Expliquer volume W11 brick comme surcharge intentionnelle. (4) Ajouter protocole tapering sommeil/nutrition pré-race. (5) Fournir équipement checklist W18-W19. Ces ajustements font passer le score de 9/10 à **9.5/10** et rendent le bundle "exemplaire pour toute app triathlon grand public".