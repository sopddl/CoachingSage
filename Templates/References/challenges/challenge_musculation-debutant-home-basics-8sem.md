# Challenge Report : musculation-debutant-home-basics-8sem

## Verdict
Template de très bonne qualité, **bundlable en l'état avec corrections mineures**. La structure suit rigoureusement ACSM/NSCA, la double progression est bien documentée, et les drapeaux de sécurité sont détaillés. Trois ajustements mineurs suffisent pour la publication : clarifier un incohérence rest_seconds W2, confirmer l'absence de pull vertical strict (déjà justifiée mais vulnérable), et valider la cohérence mathématique volume W7. Aucun risque sécurité critique détecté.

---

## Issues critiques (bloquantes pour bundle)
Aucune issue critique détectée.

---

## Issues importantes (à corriger avant bundle idéal)

- **[W2 J1 + J3]** `rest_seconds: 90` sur composés chargés (Goblet Squat, Romanian Deadlift, Dumbbell Row) : la progression_logic annonce explicitement "W2 = 90 sec" puis "W3+ = 120 sec (2 min, aligné ACSM)" — cette distinction est juste, mais **les notes d'exercice devraient renforcer pourquoi 90 sec est transitoire**, sinon l'utilisateur peut ignorer l'augmentation à W3. → **Fix** : ajouter en note W2 composés : "Repos 90 sec cette semaine. Dès W3, passer à 120 sec pour respecter les recommandations ACSM sur les composés chargés."

- **[W5 J2]** Séance "Mobilité active" : aucun `warmup` défini, alors que `duration_minutes: 35` et 5 exercices distincts sont listés. **Or**, l'absence de warmup sur une séance de mobilité d'une demi-heure peut sembler absurde (mobilité EST le warmup), mais la structure JSON impose cohérence : si type = "mobility", remplir le champ warmup. → **Fix** : `"warmup": "Aucun warmup traditionnel requis. Les exercices de mobilité active servent de progression articulaire douce."` ou `"warmup": "5 min marche lente ou respiration diaphragmatique allongé au sol."` Actuellement laissé vide, ce qui casse la schéma.

- **[W7 J5]** Notes de exercice : "Dernière série en AMRAP propre (aussi de reps que possible avec forme correcte). Note ton total : référence pour l'autonomie post-plan." — **"aussi de reps" est un calque français maladroit** (should be "autant de reps"). Corriger pour clarté : "Dernière série en AMRAP propre (autant de reps que possible avec forme correcte)."

---

## Issues mineures (nice-to-have)

- **[W1 à W7 général]** Safety notes cite "ACSM/NSCA 2-3 min repos sur composés" et progression_logic confirme W3+ = 120 sec = 2 min minimum. **Or**, W3-W4 certains composés restent à 90 sec (Pompes, Pullover, Y-raise isolations). Cette cohérence est correcte (isolations ≠ composés lourds), **mais safety_notes serait plus fort s'il distinguait explicitement : "Composés lourds (squat, hinge, row, press) = 2-3 min. Isolations légères = 45-90 sec."** Actuellement, c'est un peu ambigu pour un débutant. → Amélioration (non-bloquante) : reformuler safety_notes section Repos.

- **[W3 à W8 général]** Progressive overload checklist pour l'utilisateur : la progression_logic expose en détail la DOUBLE PROGRESSION (3x8 → 3x10 → 3x12 → charge + reset à 8), mais **aucun exercice n'affiche explicitement "tu es ici dans la progression"** (e.g., notes comme "Goblet Squat : actuellement en phase 2 de double progression, vise 12 reps propres"). C'est du nice-to-have pédagogique — la progression existe, mais un utilisateur moins attentif peut zigzagger les charges. → Suggestion : ajouter une colonne ou un tag visual du statut double-progression par exercice clé (W1-W2 vs W3-W4, etc.).

- **[W5]** Hip Thrust haltère description en W5 J5 : "Haltère 10-12 kg. Cutback sur les fentes introduites en W4." — **C'est un copier-coller d'une autre ligne** ; je suppose qu'il aurait dû dire "Cutback sur le Hip Thrust introduit en W4" ou autre. Mineure (sens compris), mais indice d'édition inachevée. → Relire les notes W5 pour cohérence textuelle.

---

## Manques notables

- **Pull vertical validé mais fragile** : la progression_logic justifie "Dumbbell Pullover + Y-raise = substitut pull-up faute de barre". C'est défendable (grand dorsal travaillé), **mais un apprenant strict** comparant ce plan à Hal Higdon ou NSCA notera l'absence de **vrai pull vertical (tirade active)**. Le template reconnaît le problème (assumed_profile exclut la barre), donc pas un manque, c'est un **compromis conscient**. → Pas à corriger, mais à noter dans les release notes bundle : "Version home-gym : pull vertical via haltères, pas tirade active."

- **Variantes dégression / progression explicites pour pompes** : la progression_logic et notes W3-W8 disent "pompes complètes ou genoux, ou pieds surélevés", **mais nulle part n'est listée officiellement une progression-path** (e.g., "si tu fais < 6 reps complètes, reste aux genoux"). L'intelligence y est (contexte clair), mais un tableau de décision serait plus pédagogue. → Suggestion optionnelle : ajouter un encadré W3 "Décision pompes : si 3x12 genoux ✓ → complets. Si impossible → reste genoux jusqu'à 3x15."

- **Pas de renvoi explicite post-plan** : W8 propose une checklist autonomie excellente, mais aucune indication "si 4/5 critères ✓, voici tes options de suite : programme intermédiaire (lien), programme spécialisé haut/bas, hypertrophie 4j/semaine." C'est hors scope d'un template d'entraînement, mais ergonomiquement, un utilisateur fini ne sait pas où aller. → Suggestion : ajouter un champ "next_program_suggestions" ou épilogue W8.

---

## Scores (sur 10)

- **Cohérence interne** : 9/10  
  Duration_weeks (8) = weeks.count (8) ✓. Progression_logic prédite (+73% volume W1→W7) vérifiable in-situ ✓. Tous les éléments annoncés (5 patterns, double progression, cutback W5, rest_seconds progression) présents et appliqués. Mineure anomalie : W5 J2 manque warmup field, W7 J5 phrasing maladroit "aussi de reps".

- **Alignement référentiel** : 9/10  
  ACSM 2026 + NSCA Essentials : rest_seconds 120-180 sur composés W3+ respecté ✓. RPE grille complète W1-W8 ✓. Cutback W5 aligné fiziologie (Bompa supercompensation) ✓. Full-body 3x/semaine = fréquence optimal débutant NSCA ✓. Patterns 5 couverts via goblet squat, hinge, push horiz/vert, pull horiz/vert ✓. **Mineure** : pull vertical = haltères only, pas pull-up strict — justifié mais ne coche pas la case "pull vertical" de tous les référentiels orthodoxes.

- **Sécurité** : 9.5/10  
  Safety_notes exceptionnellement détaillé (5 drapeaux rouges discipline-spécifiques, signes surcharge, gestion courbatures vs douleur) ✓. Échauffement poignets obligatoire rappelé ✓. Progressioon RPE 5-6 → 7 → 7-8 prevents blessures débutant ✓. **Critique JAMAIS RPE 10** ✓. Cutback W5 justifié (tendinite risk) ✓. **Mineure** : safety_notes dit "repos composés 2 min minimum" mais ne répartit pas explicitement "haltère pushup = isolation légère = 60 sec" dès W1 (cause confusion).

- **Pédagogie** : 8.5/10  
  Progression par paliers ✓ (W1 RPE 5-6, W2 RPE 6-7, W3 RPE 7, W6-W7 RPE 7-8). Instructions d'exercices suffisantes + cibles musculaires citées ✓. RPE grille intégrée dès W1 J1 ✓. **Checklist autonomie W8 J5 excellente** (5 critères + décision "quoi faire après") ✓. **Manques** : pas de diagramme vidéo-référencée (hors scope JSON, OK), pas de progression-path décision explicite (e.g., "si RPE > 8 sur squat → réduire 2 kg"), notes d'exercice parfois redondantes (copier-coller W5).

- **Global : 9/10**  
  Template robust, sûr, cohérent et bien-documenté. Aligné strictement sur recommandations ACSM/NSCA. Trois corrections mineures suffisent (warmup W5 J2, clarifier rest_seconds W2→W3, relire copier-coller W5). Aucun risque sécurité bloquant. Bundlable maintenant avec notes de patch.