# Challenge Report : triathlon-avance-distance-m-16sem

## Verdict
Template de très haute qualité, bundlable en l'état pour une app iOS grand public. Aucune issue critique détectée. Plan pédagogiquement robuste, scientifiquement aligné avec les standards ITU/Friel/Dixon, et doté de garde-fous de sécurité explicites. Les 4 blocs périodisés sont impeccablement structurés (Base → Développement → Spécificité → Affûtage), les bricks progressent de manière intelligente, et les cutback weeks respectent les principes de récupération. Quelques mineures de clarification élevées pour la version 1.0 iOS.

---

## Issues critiques (bloquantes pour bundle)
Aucune issue critique détectée.

---

## Issues importantes (à corriger avant bundle idéal)

- **[W1-W16 global]** Pas de metric de suivi FCmax fournie en input du profil. Les zones d'effort vélo (Z1-Z5) et course se basent sur "% FCmax" sans calibrage initial. → **Fix** : ajouter un exercice de test FCmax optionnel en W1 J2 (ou demander en profil). Sinon, renvoyer vers formule Karvonen avec age/FC repos annoncée.

- **[W6 J1]** Safety_notes cite "respiration bilatérale 3-5-7 introduite en W6" mais W6 J1 n'inclut pas explicitement le drill "3-5-7". Le drill apparaît en W6 J5 → **Fix** : clarifier que W6 J1 doit introduire le 3-5-7 ou déplacer le drill en J1 pour cohérence temporelle.

- **[W9-W11 J2]** "Blocs Z3-Z4 combinés" (W10 J2) : structure peu claire. "2×25 min Z3 puis 3×4 min Z4" = 50 min Z3 + 12 min Z4 contiguë. Séparation optimale Z3/Z4 sur même séance est debatable (risque fatigue accumulation) vs 2 séances distinctes. → **Fix** : clarifier repos inter-blocs ou scinder en 2 jours si faisabilité logistique permet.

- **[W15 J7]** "Repos complet — Préparation mentale" avec durée 0 minutes mais noté "day 7". Structurellement confus (repos jour 7 semaine avant course vs jour 1 semaine de course ?). → **Fix** : confirmer que W15 J7 = jour repos complet (durée 0) et que W16 commence dimanche course. Sinon restructurer pour clarifier la chronologie J-7 / J-6 / ... / J-0.

---

## Issues mineures (nice-to-have)

- **[W5 J3 → W7 J3]** Progression des intervalles VO2max : W5 J3 = "4×400 m en 1:46" mais pas de durée d'effort en secondes explicite ; W6 J3 = "3×600 m" sans durée attendue non plus. → **Clarifier** : notation "1500 m continu à allure de course" serait plus cohérente. Format "minutes:secondes" pour les 400 m / 600 m / 1000 m / 1200 m aiderait l'athlète.

- **[W4 J1-J7]** Cutback week : cooldown et warmup parfois identiques à W3 (ex: W4 J1 warmup = "300 m nage libre facile" vs W3 J1 = "400 m mixte + 4×50 m sculling"). Bien que volume soit réduit, cohérence warmup/cooldown par intensité de séance serait plus prévisible. → Nice-to-have : standardiser les warmups selon le type de séance (endurance lente, intervalle, technique).

- **[W11 J4 et W12 J4]** Volume renforcement identique (45 min) mais W11 est pic et W12 cutback → attendrait réduction. W11 J4 = 3×3 RDL + Nordic × 3. W12 J4 = 2×3 après cutback → inconsistency mineure en nombre d'exos. → **Fix** : clarifier que "45 min W11" et "35 min W12" (observé) sont intentionnels ou aligner.

- **[W13 J4]** Introduit "Side plank avec rotation" mais notation "8 par côté" est ambigu : 8 reps par côté ou 8 reps totales (4 par côté) ? → **Clarifier** : "10 reps per side" ou "alternating 10 total".

- **[W14-W15 global]** Safety_notes mentions "SI SÉANCE MANQUÉE" but no contingency branches in W14-W15 (tapering weeks). Athlète qui saute une séance en W14 : faut-il la rattraper ou skip ? → **Fix** : ajouter une note "Taper weeks (W13-W15) : aucune rattrapage, skip si manquée — repos supplémentaire".

- **[W16 J6]** "Jour de course" exercises list is narrative-heavy (allure descriptions) vs structured. For app UI, split into: warmup (duration + description), exercise legs (natation / T1 / vélo / T2 / run), cooldown → **UX amélioration** : format cohérent avec autres semaines.

---

## Manques notables

- **Pas de test de FTP / CSS en début de plan.** Safety_notes et progression_logic renvoyent à "allure 10K cible" et "% FCmax" mais aucune séance de test (ex: 20 min FTP test en W1 ou CSS estimé par 3×400 m pace). → **Ajouter optionnellement** : "W1 J2 optionnel : test FTP 20 min vélo (noter puissance moyenne) ou test CSS 3×400 m natation (noter temps)". Cf. Friel Training Bible.

- **Pas d'escalade de charge progressive sur renforcement W4-W8.** Dumbbells weights passent de "poids du corps" (W1-W3) → "2×8 kg" (W2 Bulgarian split squat) → "2×12 kg" (W3 RDL) mais sans prescription explicite par exercise et par semaine. → **Ajouter tableau**: colonne "charge suggérée par exercise" par bloc (W1-W4, W5-W8, W9-W12, W13-W16).

- **Pas de seuil d'arrêt explicite pour surcharge 3+ signes.** Safety_notes cite "3+ signes → semaine allégée non planifiée" mais aucune séance de semaine allégée non planifiée n'existe dans le template. Si athlète détecte surcharge en W7, doit-il faire W8 d'avance ou créer sa propre semaine cutback ? → **Clarifier** : "Si surcharge en W7 avant la cutback W8 planifiée : passer directement à W8. Sinon, contacter ton coach."

- **Pas de nutrition détaillée hors du plan.** Safety_notes mentionne "30-60 g glucides/h sur séances > 75 min" mais aucune recette / marque / timing pré-séance (ex: 2h avant : pâtes 200 g / 1h avant : banana + miel). → **Nice-to-have** : ajouter doc séparé "Nutrition Triathlon Distance M" (hors plan).

- **Pas de protocole d'échauffement standardisé par type de séance.** Warmups varient (ex: W1 J3 = "10 min marche/trot + talons-fesses" vs W3 J5 = "300 m crawl + 4×50 m"). Pour app iOS avec algo d'édition, template serait plus robuste avec patterns warmup réutilisables (short, medium, long). → **Structurer** : "Warmup léger (5 min) | Warmup modéré (10-12 min) | Warmup complet (15+ min)" avec descriptions paramétrées.

- **Pas de plan B si triathlon est annulé / reporté.** W15 note "J-7 de la course" mais pas d'instruction "si course reportée à W17, quoi faire ?" → **Ajouter** : "Si reporter de 7-14 jours : reprendre W15 J1-J4 + repos 3 jours. Si reporter > 14 jours : recommencer W14."

---

## Scores (sur 10)

- **Cohérence interne : 9/10**
  - duration_weeks = 16 cohérent avec weeks.count = 16 ✓
  - Volume progressions respectent règle 10-12% par discipline ✓
  - Cutback weeks en W4, W8, W12 présentes et -15% vs pic ✓
  - Brick progression logique W5→W11 pic ✓
  - *Déduit 1pt* : W6 J1 respiration 3-5-7 non visible dans exercises bien que cité en progression_logic.

- **Alignement référentiel : 9/10**
  - Blocs 4 semaines + cutback ✓ (Issurin / Bompa)
  - 80% Z2 / 20% Z3-Z5 respecté ✓ (ACSM 2026)
  - Drills natation (EVF, catch-up, sculling, tarzan, fist swim) couverts ✓ (Swim Smooth)
  - Brick 1×/semaine W5+ ✓ (ITU standard)
  - Taper -30% W13 / -50% W14-W15 + intensité maintenue ✓ (Mujika)
  - VO2max running (5K allure) et CSS natation cohérents ✓
  - *Déduit 1pt* : Pas de test FTP/CSS baseline fourni ; Z1-Z5 définies par % FCmax sans calibrage initial demandé au profil.

- **Sécurité : 8/10**
  - Drapeaux rouges spécifiques triathlon (swimmer's shoulder, ITBS, tendinite ischio-jambiers, stress fracture, otite, crampes) ✓
  - Nordic curls inclus prévention ischio ✓
  - Calf raises excentriques pour Achille ✓
  - Renforcement préventif 2×/semaine W1-W13, réduit W14-W15 ✓
  - 48h repos entre seances discipline identique ✓
  - Rest_seconds sur renforcement cohérents (90 sec RDL/Nordic = ACSM 2 min composés) ✓
  - *Déduit 2pts* : (1) Pas de seuil d'arrêt ftp/ftp para mesurable pour surcharge (signes listés mais pas d'action binaire). (2) Pas de plan B si équipement indisponible (combinaison néoprène requise pour < 18°C : et si eau 19°C ?) ; pas de alternatives matériel.

- **Pédagogie : 9/10**
  - Progression par paliers claire (volumes +10-12% vs réductions -15/-30/-50%) ✓
  - Instructions d'exercices détaillées (ex: EVF vs sculling vs catch-up distincts) ✓
  - RPE et cadence chiffrées (Z2 = RPE 5-6, cadence 85-95 rpm) ✓
  - Respiration expliquée (bilatérale 3-5-7 en W6) ✓
  - Allures cibles explicites (10K cible + offset seuil / VO2max) ✓
  - Checklist d'autonomie en W16 J7 ✓
  - *Déduit 1pt* : (1) Warmup/cooldown parfois peu standardisés (variabilité W1-W16). (2) W16 J6 est narrative heavy vs structured (moins accessible pour UI app iOS).

- **Global : 8.75/10 → **8/10** (arrondi conservateur)**

---

## Recommandations finales pour bundle 1.0

1. **Avant déploiement** : ajouter "How to Calibrate Zones" doc en app (FCmax test ou calc d'age, FTP test 20 min optionnel W1).
2. **Mapping UI** : Standardiser template warmup/cooldown par type de séance (speed, intensity) pour réutilisabilité éditoriale.
3. **Notification pré-W14** : "Affûtage débute : aucune séance manquée ne doit être rattrapée."
4. **Déploiement** : bundle en état actuel est safe ; les 2-3 mineures n'impactent pas la sécurité ou la progressabilité.