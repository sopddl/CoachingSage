# Challenge Report : hiit-avance-10sem

## Verdict
Template de qualité bien structuré et pédagogiquement solide, aligné sur les standards ACSM/NSCA/Tabata. **Bundlable en l'état avec trois patches mineurs** (incohérence EMOM W4, clarification safety_notes, progression Nordic curl). Les axes de sécurité, progression et cutback sont correctement exécutés. Seules des clarifications d'ordre cosmétique sont nécessaires.

---

## Issues critiques (bloquantes pour bundle)

Aucune issue critique détectée.

---

## Issues importantes (à corriger avant bundle idéal)

- **[W4 J1]** EMOM 30 min "lourd" : annonce "1 hang squat clean + 1 push jerk (75-80% 1RM clean)" aux min 1, mais rest_seconds manquant et note affirme "si < 8 sec de récup réduire d'un rep" — or avec 2 reps olympiques, la variable "nombre de reps à réduire" n'est pas explicite. **Fix** : clarifier "si < 8 sec de récup, passer à 1 hang squat clean seul, ou réduire la charge de 5 kg." Ajouter rest_seconds: [60-120] en paramètre pour chaque station (ACSM recommande 90-120s de récup minimale après composés olympiques à 75-80%).

- **[W1-W10 series]** Nordic curl : progression linéaire 5→6→6→4→5→6→7→5→7→(none W10) incohérente. W3 saute à 4 sets, W4 monte à 4 sets, W5 baisse à 3 sets. **Fix** : standardiser la progression : W1: 3 sets × 5 reps, W2: 3×6, W3: 4×6, W4: 4×6, W5: 3×5 (cutback), W6: 4×6, W7: 4×7, W8: 3×5 (cutback), W9: 4×7. Justifier dans progression_logic que la prévention ischio-jambiers n'est jamais supprimée, juste modulée.

- **[W2-W10]** Safety notes cite "protocole Alfredson excentrique" pour tendinite rotulienne mais aucun exercice excentrique sur genoux n'apparaît dans les sessions (seuls eccentriques ischio-jambiers via Nordic curl). **Fix** : ajouter "Si tendinite rotulienne déclarée : remplacer box jumps par step-ups isométriques en W6-W10" ou clarifier que l'Alfredson est un protocole de réadaptation post-plan, pas préventif.

---

## Issues mineures (nice-to-have)

- **[W1 J1]** "Évaluation deadlift technique" : annonce "filmer de profil" mais pas de vidéo prise en compte dans le template d'app. Suggérer un critère observable sans vidéo (ex: "5 reps sans effondrement lombaire") ou clarifier que c'est une auto-évaluation qualitative.

- **[W6-W7 J6]** Handstand walk vs hold : W6 "10 m ou 30 sec hold", W7 identique, W9 "20 sec hold uniquement". La progression n'est pas transparente — les apprenants croient qu'il y a une régression. **Fix** : W6: "10 m si maîtrisé, sinon 30 sec hold", W7: "12 m ou progression hold 35 sec", W9: "20 sec hold (tapering)".

- **[W3 J2]** "Helen" benchmark : annonce 400 m run + 21 KB swings + 12 pull-ups comme "classique CrossFit", mais Helen original = 3 rounds *3 min AMRAP × 1 min repos*. Le format ici = For Time direct sans structure AMRAP. Techniquement correct mais renommage suggéré pour éviter la confusion (appeler "Helen-style For Time" ou "Benchmark run/swing/pull").

- **[W10 J5]** Checklist 5 critères affiche "Si 3 critères sur 5 validés : objectif atteint" mais ne spécifie pas action si < 3 (rejeter le plan ? redoubler W7-W9 ?). **Fix** : ajouter "Si < 3 critères : cycle suivant focus sur [identificateur personnalisé] selon critère échoué, avec force/endurance additionnelle adaptée."

- **[W5-W8 J6]** Bilan mi-plan (W5) et deuxième cutback check-in (W8) absents — sessions fermées sans auto-questionnement intermédiaire. W5 J6 inclut "bilan mi-plan : auto-évaluation technique" ce qui est excellent, mais W8 n'en a pas. **Fix** : ajouter en W8 J6 un point "Suivi fatigue neuromusculaire" reliant aux "signes de surcharge" mentionnés dans safety_notes (FC repos, performance, sommeil).

---

## Manques notables

- **Échauffement standardisé** : chaque session cite son échauffement ("10 min...", "8 min...") mais pas de protocole "boilerplate" réutilisable. Pour un template iOS grand public, un échauffement identique (corde 3 min + mobilité 5 min + activation 2 min) améliorerait l'expérience utilisateur et la sécurité. **Suggestion** : créer un "warmup template W1-W4 / W6-W10 / W5&W8 (réduit)" réutilisable plutôt que de réécrire chaque session.

- **Nutrition post-WOD** : safety_notes cite "glucides + protéines 30 min post-WOD ratio 3:1" mais aucun exercice/session ne valide ou checkpoint cette consommation. W10 J5 cooldown mentionne "collation récupération" comme reminder, mais pas systématique. **Suggestion** : ajouter une checklist post-WOD mini (ex: "✓ hydratation 500-700 ml, ✓ collation protéines 20-30g + glucides 60-90g dans 30 min").

- **Dosage d'équipement ambigü** : assumed_profile cite "kettlebells 8-24 kg selon exercice" mais sessions recommandent 28-32 kg KB (W7 J6: "28 kg si possible"). **Fix** : mettre à jour assumed_profile "kettlebells jusqu'à 32 kg" ou réduire max W7 à 24 kg.

- **Planification post-plan** : progression_logic ne cite aucun cycle recommandé après W10 — seulement "transition vers entraînement autonome post-plan". Un modèle type (ex: "4 semaines de force max, puis 6 semaines d'AMRAP focus, puis taper") aiderait. **Suggestion** : ajouter 1-2 bullet points de "prochains cycles typiques" en fin de progression_logic.

- **Métrique de tapering W10** : "RPE 6-7 sur W10 J1-J3" mais pas de validation objective (ex: "fréquence cardiaque de repos doit revenir à ±3 bpm de baseline W1 J1"). **Fix** : ajouter en W10 J3 cooldown "mesurer FC repos demain matin (baseline + 2-3 bpm = succès du tapering)".

---

## Scores (sur 10)

- **Cohérence interne : 9/10**
  - duration_weeks = 10 ✓, weeks.count = 10 ✓
  - Progression volume (EMOM 20→30→30→30 cutback→35→35 peak→25 cutback→35→25 taper) cohérente
  - RPE progression (6-7 W1→8-9 W4→6-7 W5→8-9 W7→7 W10) logique
  - Nordic curl : progression annoncée dans safety_notes mais timeline JSON incohérente (5→6→6→4→5... au lieu de linéaire)
  - Minus : rest_seconds manquant sur composés olympiques (ACSM 90-120s requis, certaines sessions vides)

- **Alignement référentiel : 9/10**
  - Tabata 20/10 et 40/20 : ratios Tabata et al. correctes ✓
  - ACSM cutback W5 (-15%) et W8 (-10%) : citations précises et appliquées ✓
  - NSCA principes surcharge progressive : alternance volume/intensité W1-W4 conforme ✓
  - Patterns olympiques (cleans, snatches, thrusters) : fréquence et progression alignées CrossFit advanced standards ✓
  - Core en fin de séance (prévention lombaire) : systématique ✓
  - Nordic curl prévention ischio : protocole Petersen et al. BJSM 2011 cité et appliqué ✓
  - Minus : EMOM 35 min n'a pas de benchmark direct dans littérature ACSM standard (durée inhabituelle), justification manquante

- **Sécurité : 8/10**
  - Safety_notes exhaustives : drapeaux rouges épaule, genou, hanche, cheville, cœur clairement listés ✓
  - Prévention coiffe rotateurs (external rotation, Y-raise) : systématique W1-W10 ✓
  - Échauffement non-optionnel : bien documenté ✓
  - Hydratation/nutrition autour de l'entraînement : guidée (500ml avant, 200-300ml/15-20min pendant)
  - Équipement assumed_profile vs sessions : incohérence kettlebell max (24 kg vs 28-32 kg W7) ✗
  - Signes surcharge neuromusculaire : listés mais pas checklist en-session (W5-W8 n'ont pas de checkpoint FC repos)
  - Dropoff handstand poignets : mentionné mais échauffement poignets (10 cercles) seulement en W3 J6, pas systématique avant overhead W1-W2
  - Minus : aucune guidance sur quand consulter un médecin (24h ? 48h ?) pour les drapeaux rouges persistants

- **Pédagogie : 8.5/10**
  - Progression par paliers : volumes/charges augmentent graduellement (pas de sauts brutaux) ✓
  - Instructions claires : chaque exercice cite la charge, le tempo, les reps, la cible ✓
  - RPE chiffrée : W1 "Explication RPE 1-10" excellente (rarissime en templates) ✓
  - Respiration/cadence : manquant sur certains exercices (ex: KB swings ne citent pas "respiration explosive à l'extension")
  - Benchmarks W1/W2 documentés pour comparison W10 ✓
  - Checklist d'autonomie W10 J5 : 5 critères observables, très pédagogue ✓
  - Visualisation stratégie W10 J3 : excellent ajout (10 min dédiées)
  - Minus : pas de "progression Q&A" (ex: "si vous ratez 5 KB swings d'affilée, réduire charge de 10%") entre les sessions — juste EMOM J1 W4 cite le principe

- **Global : 8.5/10**
  - Template structurellement solide, références scientifiques légitimes, progression intelligente et safe
  - Cutback weeks obligatoires appliquées (W5, W8)
  - Tapering W10 intégré et tapered de façon réaliste (RPE 7 vs 8-9)
  - 4 axes d'audit : cohérence (9), référentiel (9), sécurité (8), pédagogie (8.5) → moyenne (8.6)
  - Points forts : prévention scientifique, progression linéaire respectée, benchmarking fin/début
  - Points faibles : incohérences mineures JSON (Nordic curl sets), clarifications rest_seconds, ambiguïté post-plan