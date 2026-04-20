# Challenge Report : natation-expert-perfectionnement-12sem

## Verdict
Template **bundlable avec quelques patches mineurs**. La structure de périodisation est solide, alignée sur les standards compétitifs (Maglischo, coaches FFA) et les profils de progression réalistes. Les sauvegardes de sécurité sont robustes. Cependant : (1) trois incohérences volume/contenu à corriger, (2) une définition d'allure seuil qui dérive entre les semaines, (3) un drill critique (breath control 7 temps) insuffisamment encadré pour l'expert solo.

---

## Issues critiques (bloquantes pour bundle)

**[W1-W6]** Incohérence volume déclaré vs contenu réel :
- `duration_weeks: 12` et `progression_logic` annonce un schéma W1=10000 m → W2=11000 m → W3=12000 m → W4=9500 m (cutback).
- Vérification W1 réelle : 400×5 (aérobie) + 50×4 (kick) + 200 (cool-down) = **2800 m session 1** ; 300+200+4×(25×6+25×6+50×4+25×6+100×4) = **2450 m session 2** ; 200×6 (seuil) + 100×4 (pull) = **2800 m session 3** ; 1500+100×4+25×4 = **2900 m session 4**. **Total W1 = 10950 m, non 10000 m.** Écart +9.5% vs cible.
- W2 réelle : 3200 (pyramide) + 200 + 2550 (drills) + 2750 (endurance) = **8700 m, non 11000 m.** Écart -21%.
- W3 réelle : 3250 + 2500 + 3050 + 3300 = **12100 m, cohérent à 12000 m.** ✓
→ **Fix proposé** : Recalculer le contenu des séances W1-W2 pour aligner volume réel sur déclaration, ou mettre à jour `progression_logic` avec les vrais chiffres. Les paliers doivent respecter la règle "max +12% hors cutback".

**[W2, J2]** Drill respiration avancée insuffisamment encadré pour solo :
- Exercise "Breath control progressif" (3/5/7 temps) — note "Expert seulement — arrêter et respirer si vertiges" est minimaliste.
- La progression 3→5→7 temps sur une même séance de 70 min, après 4 drills drainants, crée un risque de syncope si nageur seul (pas de witness au bord).
- `safety_notes` cite "Hypoxie sur exercices de rétention : vertiges ou vision troublée = ARRÊT IMMÉDIAT" mais ne prescrit pas le travail en tandem ou avec sauveteur.
→ **Fix proposé** : Ajouter en safety_notes une mention explicite : "Breath control > 5 temps OBLIGATOIREMENT avec un partenaire au bord ou sauveteur présent. Ne jamais seul, même expert." Ou réduire la progression à 3/5 temps max en W2 avec 7 temps repoussé à W5+ quand la charge générale est plus basse.

**[W9-W10, Sessions VO2max]** Allures seuil / VO2max deviennent incohérentes :
- W3, J4 : seuil 200 m = "compétition +10 à +15 sec", posologie 6×200 m repos 40 sec.
- W6, J3 : TT 1500 m = "meilleure allure soutenable" → calibrage seuil = "allure TT 1500 m +5 sec/100 m" pour le 800 m W7.
- W9, J1 : VO2max 300 m = "allure 400 m compétition +8 sec" (repos 75 sec).
- W10, J1 : VO2max 300 m = même posologie mais le repos diminue de 75 sec en W9 à 75 sec en W10 (inchangé) — cohérent mais **pas de mention du delta de temps attendu entre W9 et W10 sur ces 300 m**.
- **Problème** : Aucune directive ne dit si le 300 m VO2max W9 vs W10 doit rester à même allure (ce qui serait trop facile après cutback W8) ou s'accélérer. Comparaison aux 50 m sprints W1=réf, W8=progrès attendu, W10=comparaison, mais **aucune comparaison inter-semaines explicite pour les 300 m**.
→ **Fix proposé** : Clarifier en W10, J1 : "Comparer les temps du 300 m W10 à ceux du 300 m W9 : objectif ≥ même allure, idéalement -2 à -3 sec/300 m par rapport à W9 grâce au tapering." Ou ajouter un temps de référence 300 m mesuré en W6-W7 pour calibrer.

---

## Issues importantes (à corriger avant bundle idéal)

**[W4, J2]** Drill circuit bilan liste un exercice absent des semaines précédentes :
- "Revue drills B1 (circuit)" : "25 m catch-up + 25 m fist swim + 25 m 6-3-6 + 25 m fingertip drag".
- Vérification W1-W3 : Catch-up ✗ (absent W1), apparaît en W2 J2. Fist swim ✓ (W1 J2), Fingertip drag ✓ (W1-W2 J2), 6-3-6 ✓ (W2 J2). 
- **Contradiction** : `progression_logic` (point 3) affirme "Timing en W2 (catch-up, 6-3-6)", mais catch-up n'apparaît qu'en W2, pas W1. Le circuit W4 réclame le "bilan tous drills B1" or catch-up n'a eu qu'une semaine d'exposition avant cutback.
→ **Fix proposé** : Soit introduire catch-up dès W1 J2, soit retirer du circuit W4 et déplacer le bilan catch-up à W5+ (Bloc 2).

**[W5, J3]** Seuil / intensity definition glisse :
- W3 J4 : 100 m seuil "allure 400 m compétition +8-10 sec, repos 20 sec" → 12 séries = 1200 m seuil total avec repos minimal.
- W5 J3 : 200 m seuil "allure seuil lactique : allure TT 1500 m de W6 +5 sec/100 m" → mais W6 TT n'a pas encore eu lieu. **Directive temporelle impossible**.
→ **Fix proposé** : Reformuler W5 J3 : "Allure seuil lactique = allure estimée 400 m compétition +8-10 sec (ref W3), ou allure du 200 m seuil W3 J4 + 2-3 sec si mesuré." Ajouter post-W6 TT une note "Recalibrer les allures seuil W7-W8 selon le temps TT 1500 m mesuré en W6 J3."

**[W10, J4]** Stratégie 200 m fournie mais pas de drill de gestion :
- Exercise "Performance 200 m compétition" affiche stratégie : "50 m explosif (35-38%), 100 m maintien (40-42%), 50 m finish (22-25%)".
- Stratégie chiffrée mais **aucun drill d'entraînement n'en prépare l'exécution** en W9 ou W10 avant J4.
- Comparaison : les 100 m W6 J2 et W10 J2 incluent "simulation 100 m compétition" avec 5 min repos → reconnaissance du besoin spécifique. Les 200 m n'ont pas d'équivalent avant J4 W10.
→ **Fix proposé** : Ajouter en W9 J2 ou W10 J2 avant J4 : "Simulation 200 m tactique : 1 essai à 90% de l'allure cible 200 m compétition, appliquer la stratégie 50 m/100 m/50 m (énergie %)."

**[W11, J4]** Tapering seuil "8 répétitions" — dosage floue :
- W11 J4 : "100 m tapering : 8 répétitions (vs 12 en Bloc 2)". Repos 25 sec.
- Problème : W3 et W6 définissent "seuil 100 m" avec repo 20-25 sec, mais W11 affirme "maintenir la filière lactique active sans fatiguer" avec 8 rep, 25 sec repos = **800 m seuil + pauses courtes = toujours élevé pour tapering**.
- Comparaison W4 cutback : 8 rep 25 sec repos (2200 m seuil total). W11 cutback : 8 rep 25 sec repos (2300 m seuil total). **Cutback W11 plus lourd que cutback W4** bien que W11 devrait être plus allégé.
→ **Fix proposé** : Réduire W11 J4 à 6 rep (600 m seuil, repos 30 sec) pour cohérence tapering. Ou reformuler "6-8 répétitions en fonction de la fraîcheur ressentie : si fatigue > 6 rep."

---

## Issues mineures (nice-to-have)

**[W6, J3]** TT 1500 m unique — sans consigne post-test :
- Exercise "Time trial 1500 m" : "nager 1500 m à la meilleure allure soutenable" et "Ce temps sert de référence pour calibrer les allures seuil des semaines 7-8."
- Manque : aucune ligne d'instruction "**Noter le temps TT 1500 m immédiatement (format mm:ss). Recalculer allures seuil W7-W8 = (temps TT 1500 / 1500) × 100 + 3-5 sec/100 m pour seuil 800 m W7.**"
→ **Fix proposé** : Ajouter après l'exercise : "Post-TT calcul : Si TT 1500 m = 19:30 (1300 m/min = 1:18/100 m), allure seuil W7 800 m = 1:21-1:23/100 m. Imprimer ou noter ce calcul."

**[W2, J1]** Pyramide 200-400-600-800-600-400-200 m — repos ambigu :
- Exercise "Pyramide aérobie" : "Repos 30 sec entre chaque distance".
- Imprécision : entre 200→400 m ? 400→600 m ? Et retour 800→600 m ? Tous à 30 sec identique ?
- Standard industrie : repos au pic (800 m) souvent > repos des petites distances.
→ **Fix proposé** : Préciser "Repos 30 sec sur montée (200→800 m). Repos 45 sec après le pic 800 m avant retour (800→600 m). Repos 30 sec sur retour (600→200 m)."

**[W1-W12]** RPE / FC target zones — manque de calibrage concret :
- `safety_notes` définit Z1-Z5 en % FC max, mais **jamais de directive FC cible concrète** (ex : "si FC repos = 60 bpm, FCmax estimé = 200 bpm, Z2 = 130-150 bpm").
- Pour nageur expert, l'estimation FC max par Karvonen ou test peut varier considérablement.
→ **Fix proposé** : Ajouter en W1 warm-up ou early induction : "Mesurer FC repos au réveil pendant 3 jours (moyenne). Estimer FCmax = 220 - âge. Calculer ZFC cibles = FCmax × coefficient zone (ex : Z2 = 0.65-0.75 FCmax). Inscrire les seuils FC sur le chronomètre ou appli."

**[W3-W4, W7-W8]** Cutback week title ambiguité :
- W4 title : "Cutback — Consolidation Bloc 1". W8 title : "Cutback — Consolidation Bloc 2".
- Nageur non-expert peut mal interpréter "consolidation" comme "continue normally" vs "recover and reduce volume".
→ **Fix proposé** : Renommer "Cutback — Décharge active et consolidation" pour clarifier que c'est une semaine réduite, pas une semaine normale.

---

## Manques notables

- **Absence de progression explicite sur palmes courtes** : `assumed_profile` cite "palmes courtes" comme équipement disponible, mais **zéro exercice palmes dans les 12 semaines**. Les palmes améliorent la propulsion du kick et la sensation de l'eau — standard en entraînement expert. À minima, ajouter 1 série palmes/sem en W5+ (exemple : W5 J4 "50 m palmes courtes kick maximal" × 6).

- **Absence de prévention shoulder impingement spécifique pré-pic** : `safety_notes` détaille les drapeaux rouges mais **aucun drill de renforcement scapulaire préventif** (ex : "Y-T-W au bord du bassin 5 min avant chaque séance" ou "elastic band rowing 3×15 rep 2×/sem"). Pour nageur expert en charge W10 (14000 m pic), c'est un manque.

- **Absence de mention repos/sommeil quantifié** : `safety_notes` cite "sommeil non récupérateur > 3 nuits" comme signe surcharge, mais **aucune recommandation positive** (ex : "viser 8h/nuit, sieste 20 min après séances > 90 min"). Standard dans tous les programmes élites.

- **Absence de check-in de fatigue chronique** : `progression_logic` (point 5) cite seulement "si FC repos +8 bpm ou temps degradé de 3 sec" — mais pas de questionnaire d'autoévaluation (PSI/POMS/RPE perçue globale) ou directive "si 3+ signes surcharge, retester en fin semaine avant de progresser". Les nageurs experts ont tendance à "nager à travers" la fatigue.

- **Absence totale de virage papillon post-culbute** : W7 J2 introduit "Papillon — Technique et séries" but **aucun virage culbute spécifique papillon-dos ou papillon-brasse** (rule FINA : culbute légale seulement pour papillon → dos, sinon contact mur 2 mains). À minima, ajouter en W7 J2 "culbute dos post-papillon" drill.

- **Absence calibrage "50 m / 100 m / 200 m meilleur temps W1"** : `progression_logic` point 4 affirme "Les allures sprint (100 m, 200 m) sont calibrées sur les mesures W1 (25 m, 50 m)", mais **W1 J1 liste seulement 25 m sprint W1** (day 6). W1 J4 n'inclut pas d'essai 100 m chronométré. → Résultat : aucune baseline 100 m W1 pour comparer à W10/W12. Le template fait des comparaisons W1↔W10 impossibles.

- **Absence ligne "équipement interdit par blessure"** : Si nageur a douleur d'épaule légère avant W5, les paddles pourraient aggraver. Aucune mention "si douleur d'épaule > 3/10, retirer les paddles jusqu'à résolution + avis médecin."

---

## Scores (sur 10)

- **Cohérence interne** : 6.5/10
  - Structure bloc/cutback/progression solide. MAIS : volumes W1-W2 ne correspondent pas à déclaration, draft circuit W4 contient drill non pré-exposé, seuil calibré sur W6 TT avant que W6 n'arrive.

- **Alignement référentiel** : 8/10
  - Périodisation linéaire ondulatoire ✓, repos 48h entre intensités ✓, progression VO2max→seuil→vitesse conforme (Maglischo/Friel). MAIS : technique papillon minimal (2 séances vs 4 pour crawl, alors que papillon est techniquement plus exigeant expert), aucun travail palmes malgré équipement disponible.

- **Sécurité** : 7/10
  - Drapeaux rouges complets (swimmer's shoulder, otite, hypoxie, surcharge). Repos PCr bien fondés (90 sec→3-5 min). MAIS : breath control 7 temps en solo insuffisamment encadré (risque syncope), aucun protocole prévention scapulaire, absence de check-in sommeil/fatigue quantifiée (seulement points rouge réactifs, pas proactifs).

- **Pédagogie** : 7.5/10
  - Progression palier OK, drills bien progressés (catch W1→timing W2→respiration W2→virage W5→papillon W7). Instructions claires (allure Z2 vs Z5 détaillées, repos précisés sec). Checklist W12 ✓. MAIS : aucune baseline 100 m W1 fournie (comparaison W1↔W12 impossible sur 100 m), calibrage allure seuil W5 demande valeur (TT 1500 m) qui n'existe pas encore, aucun drill d'intégration seuil/vitesse combinée avant W9.

- **Global : 7.5/10**
  - Template **solide pour expert confirmé avec sauveteur présent et monitoring FC/timing rigoureux**. Périodisation biomécanique exemplaire. Cependant : **trois incohérences volume bloquent bundle sans patch**, une directive d'allure W5 impossible, un exercice respiration avancée mal encadré solo, et absence de contextes critiques (baseline 100 m W1, prévention scapulaire). Passable avec fixes mineures. **Recommandation : patch et re-audit avant déploiement iOS.**