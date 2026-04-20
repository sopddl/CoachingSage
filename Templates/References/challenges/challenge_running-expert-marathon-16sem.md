# Challenge Report : running-expert-marathon-16sem

## Verdict
Template de très haut niveau, aligné sur les référentiels (Higdon, Pfitzinger, Mujika & Padilla). Bundlable en l'état avec 1-2 correctifs mineurs (clarification calcul allures, cohérence long run W13). Excellente pédagogie et sécurité. Quelques incohérences d'ordre logistique sans impact physiologique.

## Issues critiques (bloquantes pour bundle)
**Aucune issue critique détectée.**

Les défauts présents sont correctibles en < 10 min et ne compromettent pas l'intégrité du plan.

## Issues importantes (à corriger avant bundle idéal)

- **[W1-W16] Calcul des allures de référence** : La progression_logic cite "AM calculée depuis ton record semi-marathon récent ou ton objectif 42,2 km" mais ne donne PAS de formule explicite (Jack Daniels VDOT, Riegel, tables de conversion). Un utilisateur expert mérite une formule, pas un renvoi vague vers un "calculateur". Proposé : "AM = (temps semi actuel en min) × 2 + (45-60 sec selon niveau) OU utiliser VDOT Jack Daniels avec le 10K récent le plus fiable." → à ajouter en début de safety_notes ou dans un encadré dédié.

- **[W13] Long run 28 km : incohérence avec la progression_logic** : La progression_logic clause (4) annonce "portion AM croissante... 20 km (W10 et W11)" et affirme que "le pic long run [est] 35 km (W11)". Or W13 ramène un long run à 28 km avec 14 km à AM, qui est supérieur aux 11 km de W6 et aux 8 km de W5. Techniquement juste (affûtage = maintien de la spécificité) mais la description linéaire "4 km → 8 → 11 → 16 → 18 → 20" en progression_logic est incomplète : elle n'explique pas la réintroduction post-cutback. Clarifier en progression_logic ou ajouter une note post-cutback : "W13 réintroduit 14 km AM après un affûtage aérobie (W12), c'est normal : c'est la mémoire musculaire AM maintenue pendant la réduction de volume."

- **[W10] Renforcement : progression manquante vs W9** : W10 annonce "step-ups explosifs" en remplacement du "bulgarian split squat". Or W9 introduit le Bulgarian split squat (10/jambe) et W10 était censé le progresser (+1 série = 4 séries). Au lieu de cela, W10 saute à Bulgarian 12 reps/jambe × 4 sets (+2 reps vs W9 description, mais changement d'exercice plutôt que progression linéaire). Cela casse la cohérence interne : soit on progresse le même exercice, soit on le remplace avec justification. Proposé : conserver le Bulgarian split squat en W10 (12 reps × 4 sets) et reporter les step-ups explosifs en W11, ou ajouter une note en W10 "Bulgarian split squat progression : 12 reps/jambe vs 10 en W9".

- **[W7] Séance J5 : conflit avec progression_logic** : La progression_logic clause (3) affirme "Séances tempo et VO2max toutes les semaines SANS EXCEPTION". W7 présente une séance J5 "VO2max 5x1200m" qui respecte cela. Cependant, W7 ne contient PAS de session tempo le même jour (bonne pratique : 48h min entre tempo et VO2max). Vérifier que la semaine ne crée pas un vide : W3 J3 (tempo), J5 (VO2max) = 48h OK. W7 J3 (tempo 35 min), J5 (VO2max 5x1200m) = 48h OK. Techniquement conforme, pas de correction nécessaire, mais note cette validation.

## Issues importantes (à corriger avant bundle idéal)

- **[W2] Long run 21 km : portion AM insuffisamment spécifiée** : "Km 14-21 : intégrer 4 km à allure marathon cible (AM)". Or la progression_logic stipule "progression de la portion AM : 4 km (W2)". Le calcul est correct, mais la localisation "km 14-21" sur 21 km signifie que les 4 km AM sont à la fin, quand les jambes sont fatiguées — c'est intentionnel et correct (entraîner sur jambes fatiguées). Cependant, une clarification serait utile : "Les 4 km à AM sont situés en km 17-21 (en fin de run, sur jambes fatiguées) pour simuler la phase finale du marathon" → ajouter cette note pédagogique.

- **[W6] Long run 27 km : notes de nutrition manquent** : "Km 14-25 : 11 km à AM. Km 25-27 : retour aérobie facile... les jambes le permettent". La note fitness finale ("terminer fort") est valide mais la nutrition n'est pas spécifiée. W5 (26 km) dit "Nutrition : gel à 45 min, 75 min, 110 min." W6 n'en mentionne rien malgré 27 km (quasi-identique distance). Probablement un oubli rédactionnel. → Ajouter en W6 J7 : "Nutrition : gel toutes les 35-40 min à partir du km 8, hydratation à chaque km pair pour les 27 km."

- **[W4-W8] Cutback sessions : absence cohérente de strides** : W4 J1 annule les strides (run facile seul, pas de strides). W8 J1 aussi (run facile seul). Pattern : semaines cutback = pas de strides. Cela viole implicitement la progression_logic qui ne mentionne jamais l'abandon des strides. Interprétation possible : cutback signifie réduire le volume, or les strides prennent du temps. Mais c'est une rupture pédagogique. → Clarifier : soit maintenir 4-5 strides en cutback (court = 55 min total), soit ajouter une note "En semaines cutback, les strides sont supprimées pour maximiser la récupération passive."

- **[W9-W11] Overlapping force/run : W9 J2 burden** : W9 J2 (renforcement) liste 6 exercices différents + jump squats + dead bug + side plank dynamique. Chaque exercice = 3-4 séries. Total : ~20 séries pour une séance de 45 min = ~2 min/exercice. C'est mécaniquement rapide mais pédagogiquement peu clair. Les notes "Progression douce" et "Transfère direct" sont légitimes mais le ratio volume/durée dépasse le confortable pour un expert solo sans coaching. Acceptable mais à mentionner en warmup : "Enchaînement rapide : repos 30-60 sec entre exercices pour optimiser le temps" → c'est déjà implicite dans rest_seconds, donc pas critique.

## Issues importantes (à corriger avant bundle idéal)

- **[W13-W15] Renforcement progressivement réduit** : La progression_logic annonce "volume de renforcement progressivement réduit pendant l'affûtage (W13-W15) pour ne pas induire de fatigue résiduelle le jour J." Or W13 J2 liste toujours 35 min de renforcement (calf + nordic + planche + bird-dog). W14 J2 réduit à "mobilité + gainage léger" (~30 min, ou 10 min si on compte juste le gainage). W15 J2 réduit à "mobilité et gainage léger" (description W14). Donc la réduction existe bien (35 → 30 → minimal), mais est peu spectaculaire entre W13 et W14. Vérifier que 35 min de renforcement en W13 (première semaine affûtage, -15% volume) n'est pas un surplus. Probablement correct (affûtage commence graduellement) mais à clarifier : "W13 = première réduction affûtage : renforcement maintenu à 35 min (75% des blocs précédents) pour éviter une chute trop brutale."

## Issues mineures (nice-to-have)

- **[W1-W16] FC de repos : pas de baseline mesure établie** : Safety_notes cite "FC de repos au réveil > 8 bpm au-dessus de ta normale pendant 3 jours consécutifs = surcharge". Mais le template n'explique pas comment établir "ta normale". Recommandé : "Mesure ta FC de repos en fin W1 sur 3 matins d'affilée et note la moyenne = ta baseline. Toute augmentation > 8 bpm au-dessus de ce chiffre sur 3 jours signale une surcharge." → ajouter en safety_notes (section "SIGNES DE SURCHARGE").

- **[W15] Visualisation course** : La séance J4 "Visualisation course" est excellente mais non-standard pour une app d'entraînement running. 10 min de visualisation guidée demande du contenu audio ou une description très détaillée (pas fournie). → C'est un nice-to-have : ajouter un lien optionnel vers une ressource de visualisation, ou une checklist de scènes mentales à visualiser (km 30, km 35, km 38, finish).

- **[W16] Bain froid omis post-marathon** : Safety_notes mentionne "bain froid optionnel" après W3 long run. Mais W16 dit "Marche 10 min... ne pas s'asseoir immédiatement" sans bain froid. Après 225 min de marathon, un bain froid (ou simplement eau fraîche mollets/jambes) accélère récupération. → Ajouter en cooldown W16 J5 : "Bain froid ou douche froide jambes 5 min (< 15°C, 15 min max) optionnel pour réduire l'inflammation musculaire."

- **[W4, W8, W12] Cutback week : pas de recommandation psychologique** : Les coureurs experts trouvent les semaines cutback frustrants ("c'est mon meilleur moment, pourquoi réduire ?"). Ajouter une note pédagogique en W4/W8/W12 : "Les semaines cutback peuvent sembler contre-intuitives : tu peux sembler 'meilleur' qu'en W3/W7/W11. C'est normal — c'est précisément pour ça qu'on les fait. Le repos est où se construisent les adaptations (mitochondries, glycogène). Respecte le plan."

- **[W6] Jumping squat introduction soudaine** : W6 J2 introduit "Jumping squat (saut squat contrôlé)" en Bloc 2, de manière soudaine. C'est un exercice plyométrique exigeant. Bien que la note dise "Terrain souple ou tapis impératif", il aurait été mieux de l'introduire progressivement dès W5, ou au moins de préciser un échauffement dédié avant les jump squats (ex : 2 séries de Bulgarian squat léger d'abord). → Ajouter une note en W6 J2 warmup : "Avant les jump squats : 2 × 10 Bulgarian split squat poids du corps comme échauffement plyométrique."

- **[W2] Strides en J7 (long run day) : pattern non-standard** : W2 J7 est le seul jour où les strides ne figurent pas — le long run est une séance d'endurance pure. C'est correct (éviter trop de stimulation le jour du long run), mais casse le pattern "J1 facile + strides" très régulier. Pas une erreur, mais un potentiel source de confusion. → Clarifier en W2 J7 : "Pas de strides ce jour (long run priorisé pour la récupération neuromusculaire)."

## Manques notables

- **Absence de checklist pré-course équipement** : Le template cite "chaussures de course < 200 km, vêtements testés, gels testés" mais ne liste pas une checklist matérielle concrète pour J-1 du marathon. Proposé : ajouter en W16 J3 (ros J-1) : "CHECKLIST ÉQUIPEMENT RACE DAY : ( ) Chaussures course préparées, lacets serrés, semelle ventilée. ( ) Gels testés (2-3 marques/saveurs au cas où, total 10-12 gels). ( ) Montre GPS chargée. ( ) Ceinture porte-gels (ou poche short testée). ( ) Vêtements complets testés (bra si applicable, pas de coutures irritantes). ( ) Vaseline sur zones de frottement (pieds, aisselles, intérieur cuisse). ( ) Bib numéro de course plastifiée. ( ) Autorisation médicale (si groupe d'âge réclamant certificat médical)."

- **Absence de protocole "course manquée"** : Safety_notes donne "si séance manquée" mais ne couvre pas "et si je manque la RACE le jour 5 de W16 ?". Probablement hors scope (cas rare), mais un expert apprécierait un paragraphe : "Si blessure ou maladie force l'abandon le jour du marathon après 16 sem de préparation : (1) ne pas culpabiliser, (2) consulter un médecin avant tout nouveau run, (3) attendre 5-7 jours avant un jogging ultra-facile, (4) le plan reste valide pour le prochain marathon dans 8-12 semaines (redémarrer au Bloc 2 W5, omettant le Bloc 1)."

- **Absence de plan B (objective alternatif)** : La progression_logic fixe un single objective "terminer en temps personnel / negative split". Rien sur "et si mon objectif devient 'finir frais' en W11 après une blessure légère ?". Ajouter : "Si une blessure mineure émerge en W9-W12 (ITBS léger, point de talon douloureux) : (1) consulter un kiné, (2) réduire de 30% le volume running et le renforcement, (3) maintenir la séance tempo (allure seuil à réduit légèrement), (4) cibler un objectif 'finir fort plutôt que PB' en W16 pour laisser marge de sécurité."

- **Absence de guide "comment tester les allures"** : Le template cite "AM allure marathon", "AS allure seuil = AM ± 10-30 s/km", "allure VO2max = allure 5K", mais n'explique pas comment un expert MESURE l'allure 5K ou 10K récente s'il n'a pas eu de race test récemment. Recommandé : ajouter en safety_notes une section "CALIBRATION ALLURES" : "Si tu n'as pas de race < 3 mois : (1) Fais un test 5 km tempo en W1 J3 (échauffe 15 min, puis 5 km tous out). Divise le temps par 5 = allure 5K. (2) Teste 10 km seuil en W5 J3 : divide le chrono par 10 = allure 10K. (3) Calcule AM depuis le 10K : AM = allure 10K + 10-20 s/km (conservateur) ou utilise VDOT. Ces tests calibrent tout le plan."

## Scores (sur 10)

- **Cohérence interne : 9.5/10**
  - Volumes hebdo respectent la règle 10-20% entre semaines (sauf cutbacks intentionnels). Aucun écart brutal.
  - Progressions tempo (20 → 25 → 30 → 35 → 40 min) et VO2max (600 → 1000 → 1200m) logiques et graduelles.
  - Cutbacks W4, W8, W12 bien situés (toutes les 4 sem comme annoncé).
  - Long runs progressifs cohérents avec la progression_logic.
  - **Déduit 0.5/10** : W13 long run 28 km AM portion (14 km) n'est pas explicitement présenté dans progression_logic comme "réintroduction post-cutback".

- **Alignement référentiel : 9/10**
  - Bloc 1 aérobie (W1-W4, ~55-66 km) = conforme Higdon base phase.
  - Bloc 2 seuil + VO2max (W5-W8, progression tempo 25-35 min + intervalles escaladés 600m→1200m) = conforme Pfitzinger Advanced Marathoning (focus seuil lactique semaines 5-8).
  - Bloc 3 spécificité (W9-W12, long runs 30-35 km, portion AM croissante 4→20 km) = conforme Pfitzinger spécific phase et Hal Higdon peak miles.
  - Bloc 4 affûtage (W13-W15, -15%, -35%, -50% volume, intensité maintenue) = conforme Mujika & Padilla tapering science et Pfitzinger final phase.
  - Nordic curls + calf raises excentriques + single-leg squat = prévention validée ACSM/NSCA marathon runner injuries.
  - **Déduit 1/10** : Pas de référence au-delà de 35 km long run (Higdon/Pfitzinger recommandent 18-22 mi = 29-35 km comme pic, template suit cela correctement). Cependant, absence de justification pourquoi ON NE PAS DÉPASSER 35 km (raison = diminishing returns risque/bénéfice, cartilage impact, glycogène depletion). C'est implicite mais non-expliqué.

- **Sécurité : 9.5/10**
  - Safety_notes exhaustive : 7 drapeaux rouges critiques (fracture stress, tendinite ischio, ITBS, Achille, PFPS, fasciite, CV).
  - Chaussures < 400 km + carbon plate < 200 km = conforme recommandations modernes.
  - Hydratation 500 ml pré-run + électrolytes > 90 min = ACSM standard.
  - Sommeil 7-9h + nutrition 6-8 g gluc/kg = fondation physiologique.
  - Signes surcharge énumérés (FC repos +8 bpm, douleurs > 72h, allures -10 sec, troubles sommeil, perte appétit, jambes lourdes) = cluster valide.
  - **Déduit 0.5/10** : Absent = seuil de FC pour l'arrêt immédiat. Safety_notes dit "douleur thoracique, palpitations, malaise" → appel 15. Mais ne dit pas "si FC > X bpm lors d'une séance facile" → arrêt. La tolérance cardio varie, donc difficile à spécifier, mais un expert apprécierait une référence (ex : "FC > 95% FCmax en run facile = signal d'arrêt"). Mineur.

- **Pédagogie : 9/10**
  - Chaque semaine a un goal clair.
  - Notes d'exercice détaillées : "tu dois pouvoir dire 4-5 mots" (tempo), "FC 85-90%" (seuil), "95-100%" (VO2max) = critères concrets.
  - Progression par paliers visible (600m → 800m → 1000m → 1200m VO2max).
  - Affûtage expliqué (Mujika & Padilla cité, principe "volume baisses ≠ intensité baisse").
  - Checklist race-day (5 critères post-marathon) = autoévaluation excellente.
  - **Déduit 1/10** : Pas de "comment perdre du poids intelligemment pour le marathon" (bon nombre d'experts cherchent à perdre 1-2 kg avant la course). Template silence là-dessus. Aussi, pas de guide "nutrition en cours d'entraînement vs nutrition race day" (gel types, eau quantité, électrolytes timing). Implicite dans les notes "testées à l'entraînement" mais non-structuré.

- **Global : 9.2/10**
  - Template très solide, prêt pour bundle majeur.
  - 3 corrections triviales suffisent (calcul allures, W13 clarification, W10 progression).
  - Sécurité et référentiels impeccables.
  - Pédagogie au-dessus de la moyenne (meilleure que Higdon, aussi bonne que Pfitzinger).
  - Seule faille : manque de outils concrets (baseline FC, checklist équipement, tests allure) pour un standalone app.

---

**Recommandations de patch prioritaire pour bundle :**

1. **[HAUTE PRIORITÉ]** Ajouter formule calcul AM explicite (Jack Daniels ou Riegel) en safety_notes début.
2. **[HAUTE PRIORITÉ]** Clarifier W13 long run 28 km : noter que la portion AM (14 km) est réintroduction post-cutback, cohérente avec progression_logic.
3. **[MOYENNE PRIORITÉ]** Corriger W10 progression renforcement (Bulgarian split squat 12 reps vs 10 en W9, cohérent).
4. **[BASSE PRIORITÉ]** Ajouter checklist FC repos baseline W1 et equipment J-1 W16.