# Challenge Report : triathlon-intermediaire-sprint-12sem

## Verdict

Template **bundlable avec corrections mineures**. Structure pédagogique solide, alignement référentiel (Joe Friel, ACSM, British Triathlon) conforme, progression physiologiquement cohérente. Trois issues critiques identifiées (T1 répétition tardive, calcul volume W4, VO2max running) et une dizaine d'améliorations pour robustesse. Les bricks progressifs et tapering terminal sont exemplaires. Plan executable par un autonome motivé après ces patches.

---

## Issues critiques (bloquantes pour bundle)

- **[W7 J6]** Intro T1 : trop tardif. « Simulation sortie de l'eau et T1 » débute W7 alors que brick W5-W6 ne travaillent que T2 → risque d'arriver à la course sans T1 maîtrisée. **Fix** : déplacer une session T1 sèche en W6 J4 (mobilité → transition T1/T2 répétée à sec 5 fois, puis mobilité 10 min).

- **[W4]** Contradiction volume/progression_logic : énoncé stipule « volume -15% vs W3 » (cutback conforme). Or progression_logic annonce « W4 cutback : -15% vs W3 », mais W3 affiche 50 min natation (W1 J1 + J5 = 45+50=95 min) et W4 affiche 40+40=80 min natation → -15% correct, MAIS progression_logic cite « volume natation 700 m (W1) → 1000 m → 1400 m → cutback → 1600 m » qui projette 1400 m en W3. Calcul réel W3 : J1=50 min (≈600 m Z2), J5=50 min (≈550 m) = ~1150 m, pas 1400 m comme annoncé. **Fix** : recalculer les projections de progression_logic en fonction des minutes réelles, ou harmoniser les minutes/semaine pour matcher les volumes projetés. La règle 10-15% s'applique aux minutes, pas aux mètres estimés.

- **[W9 J2 et W10 J2]** Running VO2max : intervalles 400 m (W11) puis 1000 m (W10) sur 12 semaines intermédiaire. Progression acceptable MAIS manque de transition progressive 5K → 800m. Sauts d'intensité abruptes. **Fix** : W4 J2 → seuil court 4 min blocs (conformes), W5 J2 → 800 m (AJOUTER une séance 800 m de transition entre J2 W5 et J2 W9 qui saute à 800 m alors que W6 J2 fait 5×800 m directement sans progression 600 m intermédiaire. Correction : W6 J2 → 3×800 m au lieu de 5×800 m, W9 J2 → 4×1000 m progressif.

---

## Issues importantes (à corriger avant bundle idéal)

- **[W1-W12 général]** Cadence natation : progression_logic mentionne « efficacité coups de bras/longueur » (W1 catch-up drill) mais jamais de chiffres cibles (ex : "viser 18 coups de bras pour 25 m"). Pour un intermédiaire 750 m, cible devrait être ~18-20 coups/25 m à allure Z2. **Fix** : ajouter aux drills W1-W4 une ligne : « Objectif : < 20 coups de bras/25 m à allure Z2 d'ici W4 ». Sans repère, autonome ne sait pas si sa technique s'améliore.

- **[W5-W10 général]** BRICK sessions et nutrition : seules J5 mentionnent explicitement gel/barre ("Nutrition : gel à 15 min" W10 J5). Or, toutes les bricks > 40 min exigent ravito. **Fix** : standardiser notation : « Nutrition : gel ou barre à mi-parcours + eau 500 ml/heure » sur J5 W5-W9.

- **[W10 J4]** « Vérification sac de transition » : excellent contenu pédagogique MAIS format bizarre (liste mentale, pas un exercice physique). Classe en "mobilité" est maladroit. **Fix** : transformer en "Logistique et visualisation" ou créer section spéciale "Préparation course" ; clarifier durée réelle (10 min c'est vérification + visualisation mentale, pas mobilité).

- **[W2 J4 et W3 J4]** "Nordic curl assisté" : décrit « retenir avec les mains au sol, descendre en 4-5 sec ». Risque blessure ischio si exécution incorrecte en autonome (flexion lombaire au lieu de hinge). **Fix** : ajouter « À genoux, positionner les genoux sous les hanches (hips over knees), engage les fessiers pour éviter la flexion du bas du dos. Si tu sens une douleur lombaire (pas musculaire) : arrêter et consulter. » Clarifier que cet exercice est PRÉVENTIF, pas thérapeutique.

- **[W11 J4]** Checklist est excellente MAIS rangée dans "Mobilité et préparation logistique" alors que c'est pure pédagogie/mental. **Fix** : créer section "Préparation mentale et logistique" ou la placer en W11 J4 mais avec titre "Mental/Transitions/Logistique" séparé du cooldown.

- **[W6 J1 "400 m continu test"]** : marqué comme "test" mais pas de baseline pré-plan ni d'objectif chiffré post-W6. Autonome ne sait pas si son 400 m en W6 est un succès ou un échec. **Fix** : ajouter « Chronomètre ton 400 m. Objectif cible pour triathlète intermédiaire : 7-9 min. Note le temps et ta sensation respiratoire (aisée, inconfortable, panique ?). Compare avec une tentative ultérieure en W10 J1 pour valider la progression. »

---

## Issues mineures (nice-to-have)

- **[W1 général]** « 2 séances natation/sem » annoncé mais W1 en a 2 (J1, J5), W2 en a 2 (J1, J5), etc. Correct. Cependant, progression_logic dit « jamais de bloc mono-discipline > 4 semaines » — c'est vérifié (bricks à partir W5), mais pourrait être PLUS explicite : « Vous ne ferez jamais plus de 1 jour d'écart sans changer de discipline » (exemple vérifier : W1 J1 natation, J2 run, J3 vélo, J4 mobilité, J5 natation, J6 run = ok).

- **[W7 J3]** « Simulation 20 km à allure course » : pas de split intermédiaire ou checklist de sensations. Pour un autonome, naviguer 20 km sans repère de cadence/effort toutes les 5 km c'est flou. **Fix** : ajouter « Tous les 5 km, vérifie : cadence 85-95 ? Effort 7/10 ? Jambes légères ? ». Optionnel mais aide l'autonome.

- **[W12 J5]** Jour J instructions natation/vélo/run incluent stratégies (ex : « départ modéré »), très bien. Mais pas d'info eau : « Trajet natation : parcours rectangle ? Boucle ? Repères visuels ? » Tri sprint = 750 m, généralement 1-2 boucles. Autonome découvrira le plan d'eau jour J. Peut ajouter en warmup : « Demander le plan d'eau aux organisateurs le jour J et repérer les bouées visuellement. »

- **[W1-W12 général]** RPE et FC target largement utilisés mais jamais de tableau résum. Ajouter après progression_logic un encadré : « ZONES D'EFFORT RÉSUMÉ : Z1 < 65% FC (marche/récup), Z2 65-75% (conversation), Z3 75-85% (phrases courtes), Z4 85-95% (très difficile), Z5 > 95% (max). »

- **[W5-W7]** Brick sessions : progression de 25+10 → 40+15 → 20+5 est bizarre (W7 recule à 20 km). Je vois en texte que c'est « simulation complète 750+20+5 » = pas une vraie brick mais une course blanche. Clarifier : « W5 = adaptation à la transition. W6 = augmentation durée. W7 = distance de COURSE (pas une progression de durée, mais une simulation intégrale). »

---

## Manques notables

- **Équipement spécifique natation** : safety_notes mentionne « lunettes natation, bonnet de bain, combinaison néoprène » mais template n'explicite jamais si combinaison est optionnelle ou obligatoire par température d'eau. En sprint eau froide (< 14°C), combinaison est quasi-obligatoire. **À ajouter en safety_notes** : « Combinaison néoprène : vérifiée selon température water de la course. En eau froide (< 14°C), port obligatoire et à tester à l'entraînement. »

- **Gestion de l'nervosité course** : progression_logic cite « panique respiratoire en eau ouverte » en safety, excellente prévention. Mais aucune séance ne simule l'eau ouverte (bassin 25/50 m partout). **Suggestion W9-W10** : au moins 1 session en eau libre si accès, ou drill « respiration rapide volontaire » en bassin pour gérer tachycardie.

- **Auto-massage / foam roll** : zero mention. Pour triathlon et volume W9, quelques lignes sur auto-massage mollets/quadriceps pré-séance aideraient (prévention tendinite). Optional mais cohérent avec « renforcement préventif ».

- **Stratégie ravito course** : W12 J5 mentionne « ravitaillement eau si dispo » mais aucune info sur timing (gel à quelle minute ?), quantité (1 gel de 30-40g ?), type (isoto vs hydrate ?). ACSM recommande pour sprint : 1 gel à 15-20 min vélo ou eau toutes les 15 min. **Fix** : ajouter en W12 J5 vélo : « Ravito course : porta-bidon eau 500 ml et 1 gel de 35 g à ingérer à 15 min. Tester ce gel exactement à l'entraînement W10 J5 pour éviter malaise gastrique jour J. »

- **Récupération entre les 3 disciplines dans la même séance** : W7 J5, W9 J5, W10 J5 enchaînent natation → T1 → vélo → T2 → run. Parfois < 3 min rest entre disciplines. Aucune note sur hydroélectrolytes / glycémie entre transitions. **Minor** mais autonome devrait savoir : « Boire 200 ml eau + 1 pincée sel après T1 si possible (transition zone) pour maintenir glycémie. »

- **Téléchargement plan d'entraînement alternatif** : Si autonome est malade W4 → reculer 3 semaines suggéré en safety, mais aucun plan B fourni. Pour un bundle iOS, un onglet "Rescheduler" ou "Plan B" serait bienvenu (exemple : "Si vous raterez W4, voici la semaine de reprise : (option A) reprendre W3, (option B) commencer W4 5 jours après retour, etc.").

---

## Scores (sur 10)

- **Cohérence interne** : 8,5/10
  - ✓ Duration_weeks = 12, weeks.count = 12 (ok).
  - ✓ Sessions_per_week = 6 partout (W1-W12).
  - ✓ Progression_logic exercises (bird-dog, clamshell, nordic curl, single-leg deadlift, Y-raise) présents dans plans.
  - ✓ Cutback W4 et W8 appliqués.
  - ✗ Volume natation déclaré vs réalisé désalignement mineur (1150 m vs 1400 m annoncé W3).
  - ✗ VO2max running sauts d'intensité abruptes (400 m W11 → 800 m W5 → 1000 m W10 : progression non-linéaire).

- **Alignement référentiel** : 9/10
  - ✓ Joe Friel taper 10-14j respecté (W11-W12).
  - ✓ ACSM cutback tous les 3-5 semaines (W4, W8).
  - ✓ British Triathlon brick à partir W5.
  - ✓ Zones FC correctes (Z1-Z5).
  - ✓ Running seuil 25-30 min en W7 (conforme NSCA intermédiaire).
  - ✓ Bricks progressifs 7 séances totales (plan Friel).
  - ✗ Natation manque forage open-water explicite (simulation eau libre absente).

- **Sécurité** : 8/10
  - ✓ Drapeaux rouges détaillés (swimmer's shoulder, ITBS, tendinite ischio, crampes, otite, stress fracture).
  - ✓ Nordic curl includes prévention tendinite avec instructions claires.
  - ✓ Casque obligatoire rappelé.
  - ✓ Hydratation vélo 500-750 ml/h mentionné.
  - ✓ Safety notes complets, adaptés intermédiaire.
  - ✗ Combinaison néoprène eau froide non explicité (température eau < 14°C = obligatoire, plan ne le dit pas).
  - ✗ Panique respiratoire citée mais aucune séance eau ouverte de prévention (bassin 25 m partout).
  - ⚠ Nordic curl risk mineur : pas de warning en cas douleur lombaire vs ischio différenciation.

- **Pédagogie** : 8/10
  - ✓ Progression par paliers clairs (W1 foundations → W5-10 bricks croissants → W11-12 tapering).
  - ✓ Instructions exercices détaillées (bird-dog, clamshell, pigeon, etc.).
  - ✓ RPE/cadence/allure chiffrées quasi-partout (Z2 = 65-75%, cadence 85-95 rpm).
  - ✓ Checkpoints mentaux W6 J1 (400 m test) et W10 (simulation complète).
  - ✓ Checklist autonomie W12 J5 (bien structuré).
  - ✗ Pas de tableau résumé zones effort (Z1-Z5 éparpillées dans safety).
  - ✗ Repos running entre W2 et W3 : zéro mention de fréquence minimale 48h entre courantes (W1 J2 & J6 = 4 jours, ok ; mais W2 J2 & J6 = 4 jours, ok ; jamais explicité).
  - ⚠ Split intermediates (ex : 400 m W6 → 500 m W8 → 600 m W9 → 750 m W10) clairs MAIS pas de target chrono (autonome ne sait pas si 10 min pour 500 m c'est bon).

---

## Synthèse patches prioritaires

1. **CRITIQUE** : T1 en W6 J4 (30 min séance) au lieu de W7 J6.
2. **CRITIQUE** : Recalculer volumes natation progression_logic pour matcher minutes réelles (1150 m W3 ≠ 1400 m).
3. **CRITIQUE** : Progression VO2max running : ajouter 600 m intermédiaire W6, ajuster effectifs.
4. **Important** : Ajouter « Combinaison néoprène eau froide < 14°C » en safety.
5. **Important** : Clarifier « gel 35 g à 15 min W10/W12 J5 vélo » ravito.
6. **Important** : Ajouter tableau résumé zones FC/RPE/cadence début du plan.
7. **Nice** : 1 séance eau ouverte W9-W10 si possible, ou drill respiration stressée W8.

**Global bundlable après ces 7 corrections (3 critiques + 4 importantes).**