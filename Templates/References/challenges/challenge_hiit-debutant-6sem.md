# Challenge Report : hiit-debutant-6sem

## Verdict
Template de très haute qualité, prêt pour bundle en l'état. Cohérence interne exemplaire, progression scientifiquement fondée (ACSM + Tabata), sécurité exhaustive et pédagogie claire. Trois ajustements mineurs seulement pour perfection absolue.

## Issues critiques (bloquantes pour bundle)
Aucune issue critique détectée.

## Issues importantes (à corriger avant bundle idéal)

- **[W5 J3 — EMOM 16 min]** Instruction ambiguë sur le nombre de répétitions : "8 mountain climbers (par côté)" signifie 8 de chaque côté (16 total) ou 8 au total ? Clarifier : "8 mountain climbers alternés (16 mouvements total au sol)" pour éviter confusion lors de l'exécution autonome en W6.

- **[W6 J5 — Checklist d'autoévaluation]** La checklist est intégrée dans les notes de l'exercice plutôt que dans un champ structuré `checklist` ou `autonomy_validation`. Créer un champ dédié en JSON (`checklist_items: [...]`) pour extraction UI/affichage post-séance plus fluide.

## Issues mineures (nice-to-have)

- **[W1-W6 — Temps total par séance]** `duration_minutes` annoncé vs. calcul réel : W1 J1 annonce 30 min, calcul réel = 5 min échauffement + 16 min intervalles + 5-8 min cooldown ≈ 26-29 min. Acceptable (marge d'arrondi), mais cohérence stricte serait : recalculer tous les `duration_minutes` sur base échauffement+intervalle+cooldown précis.

- **[W3 J1 — Burpee modifié]** Instruction "Pas de saut, pas de pompe incluse" est bonne, mais pourrait préciser : "Si pompe impossible, omettre la phase pompe et revenir directement aux pieds" pour éviter arrêt mental ou saut involontaire en sprint.

- **[W5 J3 — Jump squat introduction]** Sous-titre dit "Introduction d'une séance EMOM" en W5, mais EMOM arrive en J5 (pas en J3). Titre de séance J3 "Renforcement — progression pompes..." ne mention­ne pas les jump squats en notes, créant léger décalage entre goal/titre et contenu.

## Manques notables

- **Adaptation pour profils avec blessures antérieures** : Safety notes couvre les red flags aigus, mais pas les contre-indications préalables (ex: genou antérieur fragile → adapter burpees; cheville instable → réduire jumping jacks amplitude). Suggérer : "Avant W1, autodiagnostic blessure antérieure — adapter W1 mouvements en conséquence" dans le préambule `assumed_profile`.

- **Hydratation chiffrée par séance** : Safety notes cite "400-500 ml avant, 500 ml après", mais ne propose pas de stratégie intra-séance pour séances W5-W6 (20-22 min intensité). Ajouter : "Bouteille d'eau accessible, 2-3 gorgées si sensation de soif pendant repos inter-bloc."

- **Progression optionnelle post-W6** : Checklist W6 valide l'autonomie, mais aucune suggestion de paliers suivants (ex: "Si checklist validée, progression vers HIIT intermédiaire : ratio 20/10 Tabata strict, box jump, kettlebell swing"). Opportunité de récurrence/upsell manquée.

- **Test de la parole — application pratique nuancée** : Règle générale de W1 safety notes ("durant bloc effort tu ne peux dire qu'un mot") est bonne, mais EMOM W5 J5 ne la mentionne pas explicitement. L'EMOM a une structure différente (repos = temps restant dans la minute) : clarifier que test de la parole s'applique différemment (pendant les reps intensives de la minute, pas pendant le repos).

## Scores (sur 10)

- **Cohérence interne : 9.5/10**
  - `duration_weeks` = 6 ✓, weeks.count = 6 ✓. Volume hebdomadaire cohérent (sessions_per_week = 3 constant).
  - Progression logic : 5 principes énoncés → 100% implémentés dans les weeks (ratio work/rest, volume effort, cutback W4, progressions mouvements, renforcement préventif).
  - Seul léger écart : temps exact par séance vs `duration_minutes` affiché (+1-2 min réalité).

- **Alignement référentiel : 9.5/10**
  - ACSM HIIT débutant : ratio 1:2 W1-W2 (standard), transition 1:1 W5-W6 ✓. Tabata strict 20/10 refusé pour débutants ✓ (correct, W5 = 20/20 = plus facile).
  - NSCA pliométrie : box jump/kettlebell exclus ✓, squat sauté introduction W5 après 4 sem base force ✓.
  - Cutback W4 obligatoire : appliqué, -15% volume ✓ (recommandation ACSM/Issurin tous les 3-5 sem, ici 3 sem active + cutback = pattern idéal).
  - Mouvements fondamentaux : squat (pattern lower), burpee (full body), mountain climber (core dynamic), pompes (push horizontal), jumping jack (pliométrie légère) = couverture adéquate débutant.
  - Drills techniques : calf raises excentriques (tendon Achille prophylaxie) ✓, side plank (stabilisateurs latéraux) ✓, dead bug (gainage lombaire) ✓.

- **Sécurité : 9/10**
  - Drapeaux rouges exhaustifs (thoracique, cheville, genou, Achille, lombaire) avec seuils clairs (douleur > 2/10 arrêt).
  - Règles générales couvrent échauffement obligatoire ✓, hydratation chiffrée ✓, récupération 48h inter-séances HIIT ✓, sol antidérapant ✓.
  - Test de la parole (RPE proxy) intégré ✓.
  - Signs de surcharge (3+ signes → cutback) = gestion proactive ✓.
  - Progressions pliométriques graduelles (jump squat W5 seulement) ✓.
  - Manque mineur : pas d'adaptation explicite pour profils antérieurement blessés (genou, cheville, dos).

- **Pédagogie : 9/10**
  - Progression par paliers : W1 (découverte RPE), W2 (+4e bloc, impact léger), W3 (ratio 20/30), W4 (cutback), W5 (ratio 1:1, EMOM), W6 (autonomie) = courbe logique sans saut brutal.
  - Instructions d'exercices : précision excellente (ex: squat "cuisses parallèles au sol, genoux dans l'axe", pompes "coudes à 45°, pas de cambrure"). RPE cible chiffré (8-9 effort, 2-3 récup) ✓.
  - Respiration/cadence : mentionnées (ex: "respiration nasale" W4 repos actif), mais pourrait être plus systématique (ex: pattern respiration burpee explicitée).
  - Checklist d'autonomie W6 excellente mais intégrée dans notes au lieu de champ distinct.
  - Progressions optionnelles post-W6 absentes.

- **Global : 9.2/10**
  - Force : cohérence exemplaire, sécurité exhaustive, progression scientifique irréprochable, pédagogie claire, durée et volume bien calibrés pour débutant HIIT.
  - Faibles : trois ajustements mineurs (clarté EMOM mountain climbers, champ checklist distinct, adaptation profils blessés antérieurs) empêchent 9.5/10.