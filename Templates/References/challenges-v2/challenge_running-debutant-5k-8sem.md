# Challenge Report : running-debutant-5k-8sem

## Verdict
Template **bundlable en l'état** avec correction de 2 incohérences mineures. La structure suit fidèlement NHS C25K et les recommandations ACSM. Les progressions sont conservatrices et sécurisées. Renforcement préventif intégré dès W1 (meilleure pratique). Les 2 points faibles sont des imprécisions pédagogiques, pas des failles physiologiques.

---

## Issues critiques (bloquantes pour bundle)
Aucune issue critique détectée.

---

## Issues importantes (à corriger avant bundle idéal)

- **[W7 J3]** Exercice "Squats poids du corps" : **aucune note, aucune indication RPE ou sécurité**. Pour un débutant W7, ajouter : "Pieds largeur bassin, flexion à 60-70° (genoux ne dépassent pas les orteils), fessiers engagés. Si douleur articulaire, revenir à wall sit. 15 reps modérées, pas jusqu'à épuisement." → **Fix** : ajouter une note d'exécution sécurisée.

- **[W8 J5]** Exercice "30 min course continue" : la note est confuse. Elle dit "max 45 min" puis "le 5K sera pour la semaine suivante", ce qui contredit l'objectif du template (30 min = l'objectif final). → **Fix** : clarifier : "Courir 30 min sans marcher. La distance importe moins que la durée continue. Si tu tiens 30 min à 8 min/km tu atteindras ~3,7 km (acceptable débutant). Si tu tiens à 6 min/km tu atteindras ~5 km. Les deux sont des réussites."

---

## Issues mineures (nice-to-have)

- **[W1 J1 warmup]** "10 demi-squats lents" sans précision : clarifier "genou à ~60°, contrôlé, pas de rebond". Mineur mais utile pour autonomie.

- **[W2-W8 Partout]** Pattern de repos hebdo mentionné dans safety_notes (J1 run / J2 repos / J3 strength / J4 repos / J5 run / J6-J7 repos) mais **jamais explicité dans les semaines**. Un utilisateur lambda ne voit que les sessions des jours 1, 3, 5 et suppose peut-être que les jours 2, 4, 6, 7 sont à improviser. → Ajouter en début du template : "Jours de repos obligatoires : J2, J4, J6, J7. Ne pas cumuler 2 séances identiques (running ou strength) le même jour."

- **[W5 J3]** Side plank 20 sec par côté : débutant W5 peut trouver cela difficile. Ajouter option de progression : "Si 20 sec est trop difficile, tenir 10 sec ou poser le genou du bas. Progresser de 5 sec par semaine."

- **[W6 J3]** Calf raises excentriques : technique avancée pour W6. Bien décrite mais pas d'option regression. Ajouter : "Si trop difficile, revenir à calf raises classiques bipodal 20 reps."

---

## Manques notables

- **Checklist post-plan (W8+)** : qu'est-ce que le coureur fait après W8 ? Passer à un 10K ? Maintenir les 30 min 2×/sem ? Ajouter une section "APRÈS CE PLAN" recommandant soit un plan 10K (4-6 sem), soit un maintien 3 séances/sem (30 min + 20 min + 15 min) avec renforcement 1×/sem.

- **Variabilité surfaces** : safety_notes mentionne "surfaces souples privilégiées" mais aucune séance n'indique où courir. Ajouter une note générale : "Privilégier chemins ou pistes les 6 premières semaines. À partir de W7, bitume lisse OK si surface stable."

- **Nutrition post-run** : aucune mention. Pour débutant sédentaire, ajouter ligne dans cooldown W7-W8 : "Collation 30-60 min post-séance : banane + yaourt ou toast + oeuf. Hydratation 500 ml minimum."

- **Communication sur "allure conversationnelle"** : excellent concept, mais jamais chiffré en min/km. Ajouter en W1 : "Allure conversationnelle ≈ 6-8 min/km pour débutant. Test : si tu ne peux pas dire une phrase, tu es trop rapide."

---

## Scores (sur 10)

- **Cohérence interne : 9/10**
  - Volumes hebdo cohérents (+10-25% sauf W5 cutback). Duration_weeks (8) = weeks.count (8) ✓.
  - Progression logic déclarée respectée dans les 8 semaines.
  - Léger flou W8 J5 sur l'objectif réel (30 min vs 5 km).

- **Alignement référentiel : 9/10**
  - Structure fidèle NHS C25K semaines 1-9 (template adapte W9 à W8).
  - Renforcement préventif ACSM conforme (mollets W1, core W1, clamshells ITBS W1 ✓).
  - Progression run/walk → continu alignée.
  - Pas de défaut physiologique observable.

- **Sécurité : 9/10**
  - Safety_notes exhaustives et alignées sur drapeaux réels (shin splints, ITBS, tendinite Achille).
  - Échauffement obligatoire explicite, cool-down systématique.
  - Profil assumed_profile très clair (< 600 km chaussures, sédentaire, sans pathologie).
  - Cutback week W5 bien justifié.
  - Deux exercices (squats W7, calf excentriques W6) manquent de notes de sécurité mineur.

- **Pédagogie : 8/10**
  - Notes très claires sur intention (test parole, allure lente, RPE implicite conversationnel).
  - Progression paliers logique et bien signalée ("premier bloc 10 min", "première course sans marche").
  - Manque : pas de checklist autonomie post-W8, confusion mineure W8 J5 sur l'objectif.
  - Pas de référence à un log ou app pour tracker (mineur).

- **Global : 8,75/10** → **Arrondi 9/10 (bundlable)**