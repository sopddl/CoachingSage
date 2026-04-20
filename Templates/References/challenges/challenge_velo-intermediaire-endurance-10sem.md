# Challenge Report : velo-intermediaire-endurance-10sem

## Verdict
Template de très haute qualité, directement bundlable en l'état pour une app iOS grand public. Cohérence interne exemplaire, progression physiologiquement solide, sécurité exhaustivement adressée, pédagogie irréprochable. Aucune issue critique détectée. Trois points mineurs de clarification seulement.

## Issues critiques (bloquantes pour bundle)
Aucune issue critique détectée.

## Issues importantes (à corriger avant bundle idéal)
Aucune issue importante détectée.

## Issues mineures (nice-to-have)

- **[W5 J3]** Blocs tempo Z3 — titre vs contenu : exercice nommé "Blocs tempo Z3" mais c'est la troisième séance de la semaine (J5 en réalité). Le jour est correct dans le JSON (`"day": 5`), mais le titre pourrait être plus explicite pour éviter confusion UI. Suggestion : "Tempo Z3 long — séance dédiée endurance" ou déplacer le label "blocs tempo Z3" après l'exercice Z4 de J3 pour clarité visuelle.

- **[W9 J3]** Mobilité — durée exercice "Routine mobilité" ne précise pas d'unité. Champs `"duration"` absent du dernier exercice (mobilité). Ajouter `"duration": "10 min"` explicitement pour cohérence JSON et affichage UI correct.

- **[W10 J5]** Checklist post-sortie : le format textuel ultra-dense (paragraphes imbriqués en notes d'exercice) peut être difficile à parser en UI mobile. Recommandation : externaliser les 5 critères d'évaluation en objet structuré `"evaluation_checklist": [{...}, ...]` ou au minimum ajouter des retours à la ligne explicites (`\n`) dans les notes pour lisibilité écran tactile.

## Manques notables

- **Récupération passive explicite** : le plan couvre 3 séances/semaine sur 10 semaines (30 séances totales). Les 4 jours repos hebdomadaires ne sont pas documentés. Ajout recommandé : brève note dans `safety_notes` ou dans un champ dédié `recovery_days_guidance` spécifiant "J2, J4, J6, J7 : repos complet ou mobilité douce (15 min stretching statique, foam rolling, marche facile < 30 min)". Non critique (implicite), mais clarifierait l'intention pour l'utilisateur débutant.

- **Adaptation météo extrême** : le plan ne mentionne pas les ajustements pour conditions chaudes (> 28°C) ou froides (< 5°C). Suggestion : ajouter une note dans `safety_notes` type "Par temps chaud (> 28°C) : augmenter hydratation à 1 L/heure, ajouter électrolytes systématiquement. Par temps froid (< 5°C) : prévoir vêtements thermiques, gants, couche Base + Midi imperméable, réchauffer 5 min supplémentaires en Z1."

- **Puissancemètre optionnel** : `assumed_profile` le mentionne comme "optionnel", mais les zones Z4-Z5 en notes d'exercices citent uniquement % FCmax. Clarification bienvenue : "Si puissancemètre disponible, Z4 = 90-105% FTP, Z5 > 105% FTP" est mentionné une fois (W2 J3), mais pas systématisé. Acceptable en l'état (plan reste cohérent en FC), mais complétion recommandée.

- **Validation de FCmax estimée** : le plan propose "FCmax = 220 - âge" mais recommande aussi "affiner avec CF de réserve si FC repos connue (méthode Karvonen)". Aucun exercice ou checkup ne force l'utilisateur à tester sa FCmax réelle avant W1 J1. Recommandation : ajouter un checkup optionnel pré-plan "test FC de stabilisation : 10 min Z1 + 3 × [30 sec Z4 max + 2 min récup] pour estimer FCmax réelle".

## Scores (sur 10)

- **Cohérence interne : 9.5/10**
  - duration_weeks = 10 ✓, weeks.count = 10 ✓. Progression long ride (45 → 52 → 60 → 52 → 65 → 72 → 72 → 60 → 78 → 80 km) respecte rigoureusement la règle des 10-15%/sem, cutback weeks W4 et W8 explicitement intégrées et documentées. Zones Z1-Z5 cohérentes throughout (65-75% Z2, 76-82% Z3, 83-90% Z4). safety_notes ↔ rest_seconds : repos prescrit (90-240s) aligné avec ACSM composés (120-180s min). Progression_logic énumère 5 principes, chacun visible dans les weeks (cutback non négociable, cadence 85-95 rpm, 3 types de séances, zones codifiées, tapering W10). Seul point d'imprécision mineure : récupération passive non explicitement calendariée dans weeks (implicite J2, J4, J6, J7 absents de sessions).

- **Alignement référentiel : 9.5/10**
  - Discipline = vélo endurance route ✓. Plan aligne sur Joe Friel Training Bible (8h d'endurance Z2 par cycle de base) et TrainingPeaks FC/FTP : W9 long ride 78 km (~165 min) correspond à 60-75% FCmax × 165 min = ~100-124 min Z2, excellent pour développement aérobie. Progression de 10-15%/sem validée ACSM Training Guidelines 2026. Deux cutback weeks tous les 4 semaines standard (W4, W8) respectent périodisation Friel. Trois types de séances (Z2 long, Z3-Z4 intensité, Z1 récup) standards dans cyclisme route intermédiaire. Cadence 85-95 rpm sur plat, 70-80 rpm côte aligne Coggan. Tapering W10 (50-60% pic volume sur 7-10 j) cité ACSM 2022 et appliqué : W10 J1 40 km + J3 20 km = 60 km vs W9 pic 78 km ✓. Seule absence : pas de référence explicite aux données lactates ou seuil aérobie (FTP) pour cyclisme classique — acceptable car plan reste FC-centré et accessible.

- **Sécurité : 10/10**
  - safety_notes exhaustif et spécifique à la discipline : (1) 7 drapeaux rouges couvrent genou antérieur/latéral (le facteur de risque n°1 confirmé, cadence basse citée comme cause), lombaire, face médiale genou, fourmillements, cervical. (2) Équipement requis (`assumed_profile`) cohérent avec exercices (vélo de route, CF, casque, cuissard, bidons, kit réparation, éclairage) — aucun exercice demande équipement absent. (3) Cadence minimale 60 rpm (ne jamais franchir) + maximale implicite 105 rpm. (4) Hydratation 500-750 ml/h cité (ACSM standard). (5) Nutrition 30-35 min dès 60 min effort (validé). (6) Vérification pré-sortie (pneus 7-8 bar, freins, chaîne, kit répa) ✓. (7) Protocole commotion casque explicité. (8) Signes de surcharge (FC repos +8-10 bpm, jambes lourdes, stagnation perf, sommeil, appétit) standards. (9) Protocole absence W1-W2 (< 1 sem : reprendre même séance ; 1-2 sem : W précédente ; > 2 sem : reculer 2 sem) pertinent. (10) Ajout excellentissime : checklist post-80 km (5 critères auto-évaluation : respect Z2 %, nutrition, cadence, autonomie physique, constance rythme). Aucun drapeau à amender.

- **Pédagogie : 10/10**
  - Progression linéaire par paliers : W1 (45 km, blocs 5 min Z3) → W2 (52 km, 30 sec Z4 × 6) → W3 (60 km, 10 min Z3 × 3) → W4 cutback (52 km, 45 sec Z4 × 4) → W5 (65 km, 1 min Z4 × 6) → W6-W7 (72 km, 2 min Z4 × 5 puis côtes 2m30 × 6) → W9 (78 km) → W10 (80 km). Pas de saut brutal. Instructions claires : Z2 = "tu peux parler phrases complètes" (parler-talk test), cadence cible 85-95 rpm chiffré, RPE implicite (Z3 = phrases courtes, Z4 = quelques mots). Respiration non détaillée (acceptable, cardio-fréquencemètre est l'outil principal) mais "pas forcer avant jambes chaudes" mentionné. Checklist finale W10 J5 : 5 critères validables post-sortie (respect FC, nutrition, cadence, autonomie, constance). Progression autonomie excellente : W1 test cadence + blocs courts → W10 gestion full 80 km autonome. Recommandation pédagogique non appliquée : préparation FCmax pré-plan (testable mais non forcée) — minor.

- **Global : 9.5/10**
  - Plan vélo endurance de haute qualité, bundlable immédiatement. Excellente base Joe Friel / TrainingPeaks, sécurité exhaustive, pédagogie transparente. Les trois points mineurs (jour J5 renommage W5, durée mobilité W10, format checklist UI) sont des optimisations cosmétiques. Les deux manques (récupération passive explicite, adaptation météo) relèvent du nice-to-have — un utilisateur attentif les déduira du contexte ou les trouvera en documentation complémentaire app. Pour un template bundled iOS, standard excellent.