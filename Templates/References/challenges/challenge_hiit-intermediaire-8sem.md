# Challenge Report : hiit-intermediaire-8sem

## Verdict
Template solidement construit, aligné avec les références ACSM HIIT 2022 et Tabata. La progression est logique (30/30 → 40/20 → 20/10 pur), la cutback W4 est bien placée et argumentée, et la pédagogie est détaillée. **Bundlable en l'état avec corrections mineures** : trois petits ajustements sur les rest_seconds, une clarification d'intensité sur EMOM W5, et une validation des équipements par rapport au profil assumé suffiront.

---

## Issues critiques (bloquantes pour bundle)
Aucune issue critique détectée.

---

## Issues importantes (à corriger avant bundle idéal)

- **[W3 J1]** Tabata — Burpee complet : `rest_seconds: 10` dans les rounds, mais le cooldown indique "ne pas s'asseoir immédiatement" post-Tabata. **Clarification nécessaire** : le repos de 10 sec entre les rounds est correct (intra-Tabata), mais ajouter un rappel que les 2 min de repos inter-exercices doivent incluire une marche lente (actuellement implicite). → *Fix* : notes du repos inter-exercices doivent expliciter "marche lente" pour éviter que l'utilisateur s'assoie et provoque une stagnation FC.

- **[W5 J5]** EMOM finisher "12 high knees/côté + 5 burpees" : le volume-reps est très élevé pour 1 minute post-Tabata (qui a déjà vidé les réserves énergétiques 8 min avant). Calculé naïvement : 24 high knees + 5 burpees ≈ 60-80 sec chez un intermédiaire, laissant < 10 sec de repos. **Risque : dégradation technique ou RPE dépassant 9** sur le finisher. → *Fix* : réduire à "10 high knees/côté + 4 burpees" ou spécifier "si les 12+5 dépassent 45 sec, réduire à 8+3 sans culpabilité".

- **[W6 J3]** Thruster KB 10 reps sur 4 séries à RPE 8-9, **directement après** 4 séries de rangée 14 reps (14 par côté = 28 répétitions pull total). Total : ~70 reps composées en 15-20 min, + 8 min EMOM finisher sur le même pattern (pompes + thrusters). **Accumulation d'effort pull + push trop rapprochée pour intermédiaire en semaine pic.** → *Fix* : ajouter 2 min de repos actif entre rangées (set 4) et thrusters (set 1) pour permettre une micro-récupération du système nerveux.

---

## Issues mineures (nice-to-have)

- **[W1 J2]** Kettlebell swing : la note indique "alternative : deadlift roumain unilatéral (poids du corps)" mais un deadlift roumain à poids du corps avec 10 reps/côté est **moins exigeant** qu'une kettlebell swing 12 reps. Asymétrie de charge mentale. → *Suggestion* : harmoniser à "12 hip thrusts poids du corps avec pause 1 sec en haut, ou deadlift roumain 10 reps/côté si KB non disponible".

- **[W2 J3]** Rangée unilatérale KB : la note dit "Alternative sans KB : band pull-apart avec élastique, ou dumbbell row si disponible" mais le profil assumé ne garantit ni elastique ni dumbbell — seulement "kettlebell (8-16 kg selon niveau)". → *Suggestion* : ajouter une alternative sans équipement crédible : "rangée horizontale poids du corps (un bras ancré sur le sol, l'autre tire le tronc vers le haut en position de pompe asymétrique)" pour rester cohérent avec le profil.

- **[W4 J1 & W4 J3]** Burpee réduit en modification ("sans saut à la réception") réintroduit en W1 uniquement. En W4 cutback, le burpee revient en format normal (W4 J1 indique "Tabata — Burpee complet"). → *Clarification* : le retour au burpee complet en W4 après cutback simplifié est contre-intuitif (cutback typiquement = simplification). Vérifier que c'est volontaire ou revenir à "burpee modifié" en W4 J1 pour consolider l'adaptation.

- **[W7 J3]** EMOM 10 min avec planche latérale dynamique (dips) en finisher : cette combinaison core late-session en semaine de consolidation est appropriée, mais les "8 reps par côté" sur dips latéraux (16 total) est **lourd après 4 séries de force + EMOM**. → *Suggestion* : réduire à "5 reps par côté" ou spécifier "ou 30-40 sec de planche latérale statique si les dips sont trop exigeants".

- **[W8 J5]** Checklist d'autonomie intégrée au cooldown de J5 : position inhabituelle (critères d'atteinte dedans le cooldown plutôt qu'en conclusion séparée). → *Format* : extraire la checklist en section JSON dédiée ou la mettre en note finale post-cooldown, pas dedans le cooldown.

---

## Manques notables

- **Hydratation chiffrée manquante sur séances > 30 min.** Les safety_notes rappellent "500 ml avant, 250-500 ml pendant, 500 ml après", mais aucune session (W1-W8) ne fait mention de points de pause hydratation. Problème : sur les AMRAP 15 min et EMOM 10 min en W6-W7, l'utilisateur ne sait pas **quand boire**. → *Suggestion* : ajouter une note sur J1-J5 chaque semaine : "Hydratation : gourde accessible post-bloc Tabata (2 min rest) et post-EMOM avant AMRAP si séance > 35 min."

- **Critères de sélection de la kettlebell au sein de la gamme 8-16 kg.** Le profil dit "selon niveau" mais n'offre aucun test ou directive pour choisir 8 vs 12 vs 16 kg en semaine 1. Cela expose l'utilisateur à un choix arbitraire. → *Fix* : ajouter en W1 warmup : "Test de kettlebell : faire 3 sets de 5 swings bilatéraux à poids du corps. Si > 90 sec de pause nécessaire, réduire à 8 kg. Si vous complétez sans essoufflement, utiliser 12 kg. Si trop facile après J2, passer à 16 kg en W2."

- **Pas de guidance sur l'escalade des reps en AMRAP** (comment savoir si on progresse ?). Les sessions W1-W8 disent "compter les rounds" mais ne proposent pas un template de suivi (ex : "semaine 1 = X rounds baseline, semaine 4 cutback = X-1 rounds attendus, semaine 8 = X+2 rounds cible"). → *Suggestion* : ajouter une colonne de suivi ou un tableau de tracking en fin de template.

- **Manque de guidance sur les variantes scaling par joint douloureux.** Les safety_notes couvrent les drapeaux rouges (tendinite rotuliennes, achilléenne, épaule) mais ne donnent **pas d'alternatives exercice-par-exercice** pour une session si genou ou épaule commence à gêner. Ex : "Si genou gêne : remplacer squat sauté par squat lent (W1 J1 exercice 1), remplacer fente sautée par fente statique lente." → *Suggestion* : table de substitution en safety_notes ou annexe.

- **Post-W8 : aucune orientation pour la suite.** W8 J6 propose "Bilan personnel" mais pas de template de progression (avancé HIIT, transition force, or maintenance cycle). → *Nice-to-have* : ajouter 3 scénarios post-plan : "Si Tabata 8/8 rounds maintenu = transition avancé" / "Si EMOM réduit à 7/10 rounds = répéter W6-W8" / "Si douleur naissante persistante = passer à cycling cardio+force 50/50".

---

## Scores (sur 10)

- **Cohérence interne : 9/10**
  - duration_weeks = 8 ✓ weeks.count = 8 ✓ 
  - Progression logique 30/30 → 40/20 → 20/10 ✓
  - Cutback W4 bien placé et argumenté ✓
  - Volume hebdo respecte la géométrie attendue ✓
  - Manque mineur : rest_seconds cohérents mais une clarification sur EMOM W5 reps trop hautes pour la minute.

- **Alignement référentiel : 9/10**
  - ACSM HIIT Guidelines 2022 respectées (ratios, RPE, fréquence) ✓
  - Tabata (Tabata et al. 1996) 20/10 pur en W5+ ✓
  - Patterns fondamentaux 5 : hinge (KB swing) ✓, squat (goblet/thruster) ✓, push H (pompes) ✓, push V (thruster press) ✓, pull H (KB row) ✓, pull V (implicite via rotations). Pull vertical est faible (rotations thoraciques ≠ pull réel → légèrement insatisfaisant mais acceptable en HIIT).
  - Progression volume et intensité séparées (RPE constant, volume variable) ✓
  - Pédagogie Tabata solide (reps par round, attente de dégradation). 
  - Manque : pas de guidance on-ramp KB weight sélection.

- **Sécurité : 9/10**
  - Safety_notes très complets : drapeaux rouges tendinite rotuliennes, achilléenne, épaule ✓
  - Échauffement non négociable ✓
  - Hydratation chiffrée ✓
  - Signaux de surcharge neuro (FC repos, coordination) ✓
  - RPE 10 flag ✓
  - Surfaces molles recommandées ✓
  - Manque : pas de table substitution exercice/articulation douleur.
  - Manque : hydratation **intra-séance** non mentionnée sur les AMRAP 15 min (risque déshydratation).

- **Pédagogie : 8/10**
  - Instructions exercise-par-exercise claires (forme, RPE, alternatives) ✓
  - Grille RPE rappelée W1 puis implicite (bon mais pourrait être plus fréquent) ✓
  - Progression par paliers linéaire (pas de sauts brutaux) ✓
  - Checklist d'autonomie W8 présente ✓
  - Manque : pas de template suivi/tracking des reps AMRAP.
  - Manque : post-W8 orientations pour prochains cycles.
  - Visualisation mentale W8 J3 est un plus pédagogique fort.

- **Global : 8.75/10 → arrondi 9/10**
  - Bundlable. Trois corrections mineures (rest W5 J5, clarification W4 burpee, hydratation séances longues) et bonuses (table scaling, post-plan orientation) suffisent à atteindre 9.5/10.