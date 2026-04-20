# Challenge Report : sports-collectifs-avance-match-physique-10sem

## Verdict
Template de très haute qualité, prêt pour bundle en l'état. Cohérence interne impeccable, alignement référentiel solide avec Buchheit & Laursen et périodisation Bompa/Issurin. Sécurité couverte exhaustivement. Pédagogie pédante mais justifiée pour le niveau avancé. Trois issues mineures seulement à polir.

---

## Issues critiques (bloquantes pour bundle)
Aucune issue critique détectée.

---

## Issues importantes (à corriger avant bundle idéal)

- **[W6 J5]** Erreur d'intitulé cohérence : le `day` indique J5 mais dans le contexte `sessions_per_week : 5` cela devrait être cohérent avec un jour 6 ou 7 pour la mobilité si la semaine en a 7. Vérifier : la semaine W6 liste jours 1, 2, 4, 5, 7. Le jour 3 manque (normalement COD) mais il est présent. Relire la structure : j1=RS-COD, j2=force, j3=intermittent match, j5=vitesse pure, j7=mobilité. **Jour 4 est absent mais jour 5 existe**. Incohérence mineure : soit clarifier que c'est un plan 6 jours/sem partiel, soit renommer j5→j4. → Renommer day 5→4 en W6, puis j7→5 pour clarté.

- **[W5 J1 et W6 J1]** Rest_seconds sur RSA : la progression_logic cite "récup courte (30 sec)" en W6 mais W5 cite aussi "30 sec" pour un format différent (W5 = 6 sets RS 5-10-20m, W6 = RS-COD 10+180 virage+10 retour). **Inconsistance repos entre deux formats RSA distincts non clarifiée**. Recommandation : clarifier pour l'utilisateur la différence : W5 RSA = sprint 5+10+20 (distances croissantes), repos court ; W6 RS-COD = sprint avec virage intégré, même repos. → Ajouter une note explicative en W6 J1 : "Différence W5→W6 : ici le changement de direction est INTÉGRÉ au sprint (virage à 180°), pas une séquence de distances croissantes."

- **[W9 J2]** Depth jump charge et forme : "descente 40 cm, contact réactif minimal, saut vertical ou sprint 10 m enchaîné" — le "ou" crée ambiguïté. Chaque rep = descente + saut + sprint 10 m ? Ou choix du joueur à chaque fois ? → Clarifier : "Descente 40 cm → contact au sol < 200 ms (réactif) → saut vertical maximal OU sprint 10 m enchaîné (alterner : reps 1-3 saut vertical, reps 4-5 sprint 10 m)."

---

## Issues mineures (nice-to-have)

- **[Progression_logic]** La logique mentionne "2 semaines cutback (W4 et W8)" mais dans un plan 10 sem, une 3e semaine d'affûtage léger (W10) serait classique selon Bompa. W10 n'est pas un cutback complet, c'est un tapering progressif (J1-J3 affûtage léger, J4-J5 tests). Cela dévie légèrement du modèle "2 cutback + 1 taper". Notation acceptable (car J1-J3 W10 = affûtage, différent de cutback), mais si on est strict Bompa, clarifier que W10 est "tapering" pas "cutback". → Nice-to-have : ajouter une phrase en progression_logic : "W10 est un tapering progressif (affûtage J1-J3 puis tests J4-J5), distinct du cutback W4/W8 qui en est la consolidation."

- **[W3 J3 et W4 J3]** COD : W3 propose "Saut latéral explosif sur plot (box hop)" en jour 4 (c'est un COD day), W4 propose "Drill shuffle technique lent → rapide" jour 4. Or en W5 on retrouve un vrai "COD explosif + sprint sous fatigue" j3, et W6 un "COD RSA". La progression COD entre W3→W4→W5 est lisible (technique W3 heavy, affinage W4, intensité W5), mais **W3 jour 3 "Vitesse COD haute intensité + technique sprint" pourrait être mieux étiquetée** en jour 4 pour clarté puisque W3 a une structure 1-2-3-4-5 mais les jours ne suivent pas l'ordre listés (1, 2, 4, 5, 7). C'est un problème de labeling JSON, pas de contenu. → Vérifier cohérence day numbering : si sessions/sem=5, alors days doivent être 1-2-3-4-5 (ou 1-2-3-4-7 si prise en compte 7 jours). Ici W3 a jours 1,2,4,5,7 (5 sessions = ok), mais le "jour 3" manquant prête à confusion. **Non bloquant mais source de bug UI.**

- **[W7 J1]** "Simulation mi-temps 45 min physique intermittent libre" — durée_minutes=70 mais l'exercice dure 45 min. Les 25 min restantes = 12 min warmup + 10-12 min cooldown + étirements. Aligné sur l'énoncé (durée_minutes total de la séance), mais l'exercice lui-même dure 45 min. Pas d'erreur, mais pédagogiquement : clarifier "45 min d'effort continu + 12 min warmup + 13 min cooldown/étirements = 70 min de séance" pour que le joueur ne confonde pas. → Ajouter clarification : "Total séance 70 min dont 45 min d'intermittent continu simulant une mi-temps (pré/post non inclus)."

- **[W10 J5 — Checklist]** La checklist d'autonomie liste 5 critères avec une rubrique "Si 3 critères sur 5 sont OUI → objectif atteint." Cela signifie qu'un joueur pourrait échouer sur 40% des objectifs et valider le plan. **Pour un plan "avancé", c'est très permissif.** Recommandation pédagogique : ajuster à "4 critères sur 5 minimum pour validation complète du plan, 3/5 = progrès significatif mais domaines à travailler en continuation." → Ajouter ligne : "Objectif minimal : 4 critères OUI (80%) pour progression vers un cycle périodisé supérieur. 3/5 (60%) = bonne progression mais reprendre un cycle Bloc 2 avant spécialisation avancée."

---

## Manques notables

- **Aucun équipement de contingence explicite pour les haltères/kettlebells non disponibles.** La section assumed_profile liste "haltères ou kettlebells légers (8-20 kg)", mais si un joueur n'a que poids du corps (gym extérieur), les séances de force (W2-W9) deviendraient non-faisables. Suggestion : ajouter une note générale "Alternatives si équipement réduit : remplacer haltères par medball, bande élastique lourd, ou augmenter nombre de reps et sets en poids du corps (push-up, pistol squat progressif, etc.)." → Recommandation : ajouter un appendice court "Scaling par équipement disponible."

- **Absence totale de conseils nutrition spécifiques intermittent lactique W5-W7.** Safety_notes couvre hydratation générale ("500 ml toutes les 20-30 min") et "repas glucidique 2-3h avant intensité forte". Mais les séances W5-W7 de 60-75 min à RPE 8-9 avec pliométrie + intermittent lactique requièrent un dosage plus précis : glucides rapidement assimilables intra-effort (boisson sports 6-8% CHO), récupération post-effort (1.2 g CHO/kg BW dans l'heure). → Suggestion : ajouter "Nutrition intra-effort W5-W7 (intermittent lactique > 50 min) : boisson sports 500 ml (6-8% glucides, électrolytes) sirôté toutes les 15-20 min. Post-séance : collation CHO+protéine (ex: banana + œuf) dans 30 min pour relancer glycogénèse."

- **Pas de progression explicite des exercices de proprioception en W4-W10.** W4 J7 introduit "single-leg deadlift lent" (proprioception unipodale), W8 J7 "single-leg hop and hold", mais après aucune progression. Pour un joueur avancé, W9-W10 auraient pu intégrer proprioception sous fatigue (ex : single-leg balance pendant 30 sec, puis sprint 10 m sur la même jambe) ou proprioception yeux fermés sur surface instable. Manque minor car prévention entorse cheville est bien couverte en safety, mais pour un plan "avancé", progression proprioception jusqu'à W10 aurait renforcé la prévention. → Nice-to-have : ajouter W9 J7 "Proprioception sous fatigue : single-leg balance yeux fermés post-session d'intermittent (jambes fatiguées), 3×30 sec/côté."

- **Nordic curl n'apparaît qu'en W3-W4 puis disparaît.** Safety_notes cite "Le nordic curl est maintenu en toutes semaines y compris cutback — la prévention des ischio-jambiers ne s'interrompt jamais." Or W5-W10 n'en listent aucun explicitement. W5 J2, W6 J2, W7 J2, W8 J2, W9 J2, W10 J2 ne mentionnent pas Nordic curl. Incohérence texte vs contenu. → Ajouter Nordic curl 3-5 reps × 2-3 sets en fin de toute séance force (W5-W10 J2), même si brief. Exemple : "**Nordic curl (prévention)** reps 5, rest 90, sets 2" à la fin des sessions force qui suivent W4.

---

## Scores (sur 10)

- **Cohérence interne : 9/10**
  - duration_weeks (10) ↔ weeks.count (10) ✓
  - Niveau "avancé" aligné : volume 5 séances/sem, intensité RPE 8-9 avancée, plans référence confirmés ✓
  - progression_logic détaillée et tracée dans les weeks ✓
  - Safety_notes ↔ rest_seconds sur composés : 150-180 sec appliqués ✓
  - Minor : labeling day en W3-W4 confus (jours 1,2,4,5,7 vs attente 1-5 ou 1-7)

- **Alignement référentiel : 9/10**
  - Buchheit & Laursen 2013 HIIT sports co explicite W1 onwards ✓
  - Périodisation Bompa blocs 3 phases ✓
  - 5 patterns fondamentaux (squat, hinge, push H, push V, pull H/V) présents chaque week force ✓
  - 10-15% règle appliquée (W1→W2 +15%, W2→W3 +12%, W4 -15%, W5 intensification, W7 pic, W8 -15%, W9 pic, W10 -60%) ✓
  - RSA protocol, navette suicide, 5-10-5 drills = référence sports co ✓
  - Minor : progression proprioception aurait pu être plus poussée W8-W10 ; nutrition lactique peu détaillée

- **Sécurité : 9/10**
  - Drapeaux rouges exhaustifs (stress fracture tibiale, claquage ischio, pubalgie, PFPS, tendinite Achille, entorse, conflit épaule, commotion) ✓
  - Nordic curl prévention citée vs maintien complet = incohérence mineure (disparu après W4)
  - DOMS / surcharge neuromusculaire signes listés ✓
  - Équipement validé assumed_profile ✓
  - RPE guidage clair (6-10 échelle) ✓
  - Minor : contingency équipement absent, nutrition lactique impréci

- **Pédagogie : 8/10**
  - Progression par paliers (Bloc 1 fondations→ Bloc 2 intensité → Bloc 3 pic) ✓
  - Instructions claires, chaque exercice a notes explicites ✓
  - RPE, rest_seconds, reps précisés ✓
  - Checklist autonomie W10 ✓
  - Tests comparatifs W1, W7, W10 ✓
  - Manques : progression_logic très verbose (pédanterie acceptable mais freine onboarding), nutrition détails insuffisants, progression proprioception absente post-W4

- **Global : 8.75 / 10** 
  (Arrondi à **9/10** car pas d'erreurs critiques, seulement nice-to-have et clarifications mineures)