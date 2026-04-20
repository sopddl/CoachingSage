# Challenge Report : tennis-intermediaire-regularite-10sem

## Verdict
Template très solide, bundlable en l'état avec corrections mineures. La structure de progression est cohérente, l'alignement USTA/ITF/ACSM est démontré, et les drapeaux de sécurité tennis sont robustes. Trois ajustements mineurs suffisent pour éliminer des incohérences mineures de détail. Global excellent pour une app grand public.

## Issues critiques (bloquantes pour bundle)
Aucune issue critique détectée.

## Issues importantes (à corriger avant bundle idéal)

- **[W6 J2 / Drill approche filet]** : "Partenaire lobote depuis le fond" → énoncé ambigu. Clarifier : "Partenaire envoie une lobée haute depuis le fond de court. Toi : tu montes à la position T et tu bloques la vollée." Sinon ambiguïté sur qui monte et qui lobote.

- **[W7 J5 / Intervalles sprint navette Tabata]** : "10 sec repos" affiché deux fois (durée et rest_seconds). Pour un Tabata strict (20/10), il faudrait préciser : "Cycle 20 sec sprint / 10 sec repos, 8 répétitions = 4 min. Pas de repos supplémentaire entre cycles." Actuellement, rest_seconds=10 peut être mal interprété (repos après chaque sprint vs reste du cycle).

- **[W8 Scénario B]** : "L'un sert, l'autre retourne profond. Celui qui a servi est en difficulté..." → Pas clair qui gère le jeu après le retour. Clarifier : "Après le retour profond, continuer l'échange jusqu'au bout du point (3+ coups minimum). Le serveur doit défendre ou contre-attaquer selon l'occasion."

- **[W10 J5 / Checklist]** : "test : demander au partenaire de vérifier sur 10 échanges" → Instruction claire mais suppose un partenaire présent. Ajouter : "Ou auto-vérifier en vidéo si solo (enregistrer 10 échanges et vérifier en relecture)."

## Issues mineures (nice-to-have)

- **[W1-W10 / safety_notes]** : Hydratation mentionnée (500 ml + 200-300 ml toutes les 30 min). Excellent, mais pas d'instruction sur les conditions de température. Ajouter une ligne : "En conditions chaudes ou humidité >70%, augmenter à 300 ml toutes les 20 min."

- **[W2 J2 / Fente latérale alternée]** : "Reproduit le split-step / premier pas latéral" → Split-step n'est pas une fente latérale mais un saut sur place écartant les pieds. L'exercice reproduit plutôt le *premier pas latéral* post-split-step. Clarifier : "Premier pas latéral après split-step (l'exercice mimique le poussée latérale, pas le split-step lui-même)."

- **[W4 J2 / Cooldown]** : "Étirements fessiers, adducteurs, épaules" mais pas le coude. W4 inclut déjà un volume de service. Ajouter étirements coude/poignets pour cohérence avec safety_notes (obligatoires post-service).

- **[W5-W6 Progression]** : cutback_week W5 affiché clairement, mais volume W6 dit "+12% vs W6" au lieu de "+12% vs W5". C'est correct logiquement (rebond du cutback), mais la formulation est ambiguë. Clarifier dans le goal : "Volume +12% vs la semaine précédente W5 (cutback). Retour à la progression normale."

- **[W9 J2 / Travail de service]** : "60 balles" annoncé, mais sets=3 et reps=20, soit 60 au total. OK mathématiquement, mais rest_seconds=90 entre chaque set de 20 semble long pour une séance cutback (atténuation motion). Réduire à rest_seconds=60 pour W9 (affûtage dynamique, pas repos complet).

## Manques notables

- **Progression_logic vs. reality check** : La logique annonce "split-step introduit en W4, filet en W6, serve-and-volley en W7", mais :
  - Split-step : mentionné en W4 goal et warmup, mais le drill réel (balles alternées CD/Revers) ne spécifie pas de *comptage du timing* du split-step. Ajouter : "[W4 J2 Drill balles alternées] Note: demander au partenaire de crier 'split-step' au moment du bounce pour vérifier ton timing."
  - Filet W6 : exact ("première approche au filet après balle courte").
  - Serve-and-volley W7 : exact.

- **Absence de guidance vidéo ou repères vidéo** : Les drills complexes (split-step, hip hinge, nordic curl) n'ont pas de lien/QR ou description ultra-claire (ex: "nordic curl partiel : video : https://..."). Pour une app grand public, recommander : "Filmer ses nordics ou consulter Strongman wiki pour la forme." Mineur mais important pour autonomie.

- **Mesure objective de la progression technique** : Plusieurs drills reposent sur "compter les échanges" ou "objective : au moins 25 échanges". Manque un template de suivi : "Utilise la feuille de match joint pour noter : semaine, date, meilleur comptage croix, meilleur comptage long de ligne, nb points où tu as monté filet, taux 2e balle dans carré." Ou : "Filmer 1 set par semaine et auto-analyser."

- **Absence de clarté sur match hebdomadaire** : safety_notes dit "ce plan (2 séances) est délibérément dosé pour un joueur qui maintient son match hebdomadaire par ailleurs", mais le plan lui-même ne mentionne jamais ce match (repos Y/N jour avant ? jour après ? RPE autorisé ?). Ajouter dans safety_notes : "Si match hebdo le samedi : placer séance physique J5 mardi et séance technique J2 lundi (48h avant match). Éviter séance intense 24h avant le match."

## Scores (sur 10)

- **Cohérence interne : 9/10** — duration_weeks=10 ↔ weeks.count=10 ✓, progression_logic appliquée fidèlement (W1-3 intro, W4-6 deepening, W7-10 match context), cutback W5+W9 respectés, rest_seconds cohérents avec RPE annoncé (8-9 sur efforts, 60-90 sur force). Perte 1 point pour ambiguïtés W6 lobote et W7 Tabata rest_seconds.

- **Alignement référentiel : 9/10** — USTA/ITF/ACSM cités, 5 patterns fondamentaux présents (squat, hinge, push H avec rotation, push V implicite service, pull via rotation tronc), prévention intégrée dès W1 (nordic, étirements coude), progressions volume cohérentes (10→15→20→25→30 échanges). Élevé standard de plan de référence. Perte 1 point pour split-step W4 non détaillé en termes de repères temporels (timing du bounce).

- **Sécurité : 9.5/10** — Drapeaux rouges tennis complets (épicondylite, conflit sous-acromial, entorse cheville, genou, ischio, stress fracture), règles générales robustes (chaussures obligatoires, échauffement épaule NON NÉGOCIABLE, étirements coude post-service), signes de surcharge définis, hydratation chiffrée. Excellent. Perte 0.5 point pour : absence de guidance sur conditions de chaleur extrême (> 35°C, consulter médecin avant séance).

- **Pédagogie : 8.5/10** — Progression par paliers nette, instructions claires pour la majorité des exercices (reps, durée, RPE), respirations/cadences précisées où pertinentes (descente 3 sec squat, split-step timing). Checklist W10 excellente et autonome. Perte 1.5 points pour : (1) absence de lien vidéo ou repères vidéo pour forms complexes (nordic, hip hinge), (2) pas de template de suivi écrit/app, (3) "partenaire" souvent assumé sans option "solo avec mur".

- **Global : 9/10** — Template de très haut niveau, structure progression fiable, sécurité tennis démontrée, pédagogie solide. Trois corrections mineures (clarifications W6 lobote, W7 Tabata, W10 partenaire) et ajout de guidance vidéo/suivi élèverait à 9.5+. Bundlable immédiatement pour une app de qualité premium.