# Challenge Report : velo-debutant-reprise-6sem

## Verdict
Template de très bonne qualité, bundlable en l'état. Structure pédagogique solide, progression cohérente avec les principes d'endurance fondamentale ACSM, sécurité bien documentée. Trois ajustements mineurs seulement (cohérence numérique, clarification Z3, précision cadence) — aucun blocage critique.

## Issues critiques (bloquantes pour bundle)
Aucune issue critique détectée.

## Issues importantes (à corriger avant bundle idéal)

- **[W5 J5 — Planche ventrale]** Contradiction timing : exercice situé EN FIN DE SÉANCE (après 80 min de vélo continu) avec progression à 35 sec. Pour un débutant en fin de sortie longue, 35 sec de planche après 1h20 d'effort est physiologiquement exigeant et contredit la logique de "renforcement préventif en FIN de séance longue" énoncée dans progression_logic. → **Fix** : réduire à 30 sec en W5 (maintenir, pas progresser après cutback), ou déplacer la progression à W6 J5 (mais J5 W6 est déjà maximal à 90 min vélo). Recommandation : limiter planche W5 à 30 sec, maintenir 35 sec pour W6 si effectivement programmé, ou accepter 30 sec comme plafond.

- **[W3 J2 — Calf raises surélevés]** Exercice introduit en W2 J5 sous le nom "Calf raises surélevés" avec "12 par côté", puis réapparaît en W3 J2 avec "12 par côté" identique — pas de progression visible entre W2 et W3. → **Fix** : clarifier si progression est en nombre de reps (12 → 15 en W3) ou en amplitude (variation ROM), ou reconnaître que cet exercice se stabilise. Vérifier cohérence avec la logique "progression planche : 20 → 25 → 30 → 30 → 35 sec" qui elle est explicite.

## Issues mineures (nice-to-have)

- **[W5 J2 — Blocs Z3 tempo]** Description dit "8 min à Z3" dans progression_logic, mais exercice détaillé spécifie "8 min à Z3 + 5 min Z2 récupération". Confirmé dans notes, mais le libellé progression_logic aurait dû préciser "8 min blocs courtes" plutôt que "8 min" seul pour éviter confusion. → Clarifier : "blocs de 8 min Z3 entrecoupés de 5 min Z2 récupération" dès la progression_logic.

- **[W2 J2 — Bloc cadence élevée]** Exercice "3 min à 95-100 rpm + 3 min à 85 rpm" répété 4 fois = 24 min annoncé, "complété jusqu'à 50 min total en Z2 libre". Reste non structuré : "Z2 libre" ne dit pas si c'est continu Z2 ou alternance cadence. → Clarifier : "après les 4 blocs de 6 min (24 min), rouler 26 min restantes en Z2 cadence libre (85-90 rpm)".

- **[W4 J5 — Side plank]** Introduit seulement en W4 cutback (après W3 déjà intense). Physiologiquement correct pour débutant, mais timing de cutback + nouveauté peut créer confusion pédagogique. → Vérifier acceptabilité : un débutant en cutback peut-il intégrer un exercice nouveau sans surcharge ? Réponse : oui (cut = volume vélo ↓, renforcement stable), mais documenter cette rationale.

- **[Safety_notes — Cadence minimale]** Section énonce "ne jamais descendre sous 65 rpm de façon prolongée", mais W3 J2 en côtes recommande "70-80 rpm". Pas contradiction (70-80 est > 65), mais formulation "prolongée" est vague pour un débutant. → Préciser : "sur plat ou petit dénivelé : minimum 80 rpm ; en côte prolongée (> 2 min) : minimum 70 rpm ; jamais < 65 rpm".

- **[W6 J5 — Checklist d'autonomie]** Checklist 4/5 oui ou 2/3 oui établit deux seuils ("prêt" vs "refaire"), mais pas de consigne si 1 oui ou 0 oui. → Ajouter ligne : "0-1 oui : consulter un coach ou allonger le plan de 2-3 semaines avant de progresser vers 2h".

## Manques notables

- **Progression spécifique "calf raises"** : introduit en W1 comme "calf raises bipodal" (15 reps), puis W2 "surélevés" (12 par côté). Pas de clarification si "surélevés" remplace bipodal ou s'ajoute. → Recommandation : spécifier "W1-W3 : calf raises surélevés 12-15 reps, W4-W6 : calf raises surélevés 15 reps" ou décrire progression d'amplitude/déséquilibre.

- **Récupération inter-séances** : safety_notes annonce "48h minimum entre deux séances", mais W1-W6 espacent J2 et J5 (3 jours en semaine de 7 jours). Implicitement OK (72h > 48h), mais expliciter le timing hebdo: "séance mardi + séance vendredi = 3 jours repos, conforme aux 48h minimums". Pertinent pour un débutant qui pourrait ajuster.

- **Équipement FC monitor "optionnel"** : progressive_logic et safety_notes référencent "si moniteur dispo" ou "FC cible", mais aucun plan B clair pour un débutant sans moniteur. → Ajouter ligne type : "Sans moniteur FC : utiliser le test de la parole comme seul indicateur — Z2 = phrases complètes possibles, Z3 = courtes phrases uniquement".

- **Téléchargement/sauvegarde du plan** : aucune mention de comment tracker les reps de renforcement ou les durées sortie. Pour une app iOS, clarifier : "chaque semaine, cocher les séances complétées dans l'app ou noter sur papier le temps réel et les sensations (RPE, cadence observée)" → aide l'utilisateur à gérer le suivi.

## Scores (sur 10)

- **Cohérence interne : 9/10**
  (progression volumes cohérente 85→105→130→100→130→140 min, cutback logique W4, renforcement progressif et bien intégré; seule contradiction mineure sur planche W5 J5 timing)

- **Alignement référentiel : 9/10**
  (90% du temps Z2 conforme ACSM endurance fondamentale, introduction Z3 en W5 mesurée et ciblée, cadence 85-90 rpm standard route, cutback week obligatoire appliquée; absence de référence explicite à Joe Friel ou TrainingPeaks periodization, mais contenu aligné; pas de Z4-Z5 approprié pour cible)

- **Sécurité : 9/10**
  (drapeaux rouges complets et détaillés par zone doleur, nutrition/hydratation couverts, signes surcharge listés, checklist vérification vélo intégrée; manque minor : plan B sans moniteur FC, clarification "48h minimum" vs timing réel semaine)

- **Pédagogie : 9/10**
  (progression paliers respectée, instructions claires, RPE/test parole/cadence chiffrés, checklist autonomie W6 excellente; manques : articulation cadence-blocs W2 J2 légèrement floue, progression calf raises non explicite, pas de suivi app suggéré)

- **Global : 9/10**
  
  Template solide, pédagogiquement cohérent, sûr, prêt pour bundle. Trois ajustements cosmétiques seulement pour polish.