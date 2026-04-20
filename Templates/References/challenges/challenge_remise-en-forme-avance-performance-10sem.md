# Challenge Report : remise-en-forme-avance-performance-10sem

## Verdict
Template **bundlable avec patchs légers**. C'est un programme bien structuré, fondé sur des principes périodisés validés (NSCA, ACSM), avec une progressivité claire et une pédagogie enrichie. Les drapeaux rouges et la cohérence interne sont solides. Trois points à corriger avant bundle : (1) incohérence rest_seconds sur composés W1-W3 vs sécurité notes ACSM, (2) progression HIIT non linéaire en W2, (3) chiffrage flou du 1RM estimé pour W4-W6. Le template gagne à clarifier ces trois points mineurs sans refonte structurelle.

---

## Issues critiques (bloquantes pour bundle)

Aucune issue critique détectée. Le programme ne présente pas de risque de sécurité majeur, de contradiction interne manifeste ou d'incohérence pédagogique qui bloquerait le déploiement en app iOS grand public.

---

## Issues importantes (à corriger avant bundle idéal)

- **[W1-W3, tous les jours]** Repos sur composés lourds (squat, deadlift, traction, OHP) : safety_notes cite "ACSM/NSCA 150-180 sec minimum", mais rest_seconds = 150 sec exactement en W1-W2, et 120-150 sec sur certains accessoires (Dips W1 J1 = 120 sec). En W3, le tempo 3-1-X excentrique rallonge la durée de la série sans compenser par un repos supplémentaire. **Fix** : harmoniser en 180 sec sur tous les composés (squat, deadlift, traction, OHP) en W1-W3. Accessoires 120 sec OK (prise complète [5] patterns = 6 patterns : le template annonce 5 en summary mais cite 6 en progression_logic. Pull vertical + pull horizontal doivent être séparés conceptuellement).

- **[W2 J5]** HIIT progression incohérente : W1 J5 = 8 × (2 min Z4 + 2 min récup) = méthode aérobie modérée. W2 J5 = 4 × Tabata (20/10). Or Tabata est anaérobie max (Z5), pas une progression linéaire de W1 — c'est un saut qualitatif brutal. **Fix** : W2 J5 doit progresser vers Tabata de façon graduée. Proposer : W2 J5 = 10 × (90 sec Z4 + 90 sec Z1) pour une transition linéaire avant W3 J5 VO2max 3×3 min, et Tabata en W4 uniquement.

- **[W4 J1, W5 J1, W6 J1, W9 J1]** Charge estimée non définie : progression_logic cite "charge ~85% 1RM estimé (W4), ~90% 1RM (W5-W6)" mais n'explique pas comment l'utilisateur estime son 1RM sans test maximal (le plan dit explicitement "pas de test maximal" en W1). Risque : utilisateur surcharge ou sous-charge par défaut. **Fix** : ajouter en safety_notes ou W1 goal une méthode d'estimation 1RM (ex : "si tu soulèves 5 reps propres à RPE 8, ton 1RM ~= charge × 1.15"). Ou expliciter que les charges de W1 servent de référence 0RM pour projection.

---

## Issues importantes (non-bloquantes mais à améliorer)

- **[W3 J6 + W7 J6]** Bilan mobilité cité comme "retester" (W3) et "retesting" (W7) mais les critères ne sont pas formalisés en W1 J6. Ajouter en W1 J6 une section "établir les baselines : overhead squat (noter profondeur et verticalité), shoulder flexion (mesurer ROM), forward fold (distance mains-pieds)". Sans baseline, les retests de W3/W7 sont incomparables.

- **[W9 J3 + W10 J1-J3]** Tapering décrit en W10 J1-J3 mais la réduction reste floue. "Maintien charge W8" — mais W8 J1 = cluster 3×(3+2+2) et W10 J1 = 3×5 squat. Clarifie : la charge brute est-elle identique (même poids levé) ou la charge relative (même % 1RM) ? Proposer : "volume -40% (3 séries vs 5), charge identique au poids absolu de W8 J1".

- **[W6 J5 + W9 J5]** Formatage HIIT non aligné : W6 J5 = "4 blocs Tabata" (4 min chaque) + "AMRAP 10 min", durée totale implicite ~26-30 min avec récup. W9 J5 = "6 blocs Tabata" + "AMRAP 10 min", durée ~36-40 min. Mais duration_minutes = 60 pour W9 J5 et 50 pour W6 J5 — incohérence 10 min. **Fix** : clarifier durée réelle du warmup (12 min annoncé) + blocs + AMRAP + cooldown pour justifier 60 min W9 ou réduire à 55 min.

---

## Issues mineures (nice-to-have)

- **[W7 goal]** "supercompensation (Platonov, 1988)" : Platonov est un coach russe renommé, mais la référence 1988 est imprécise. Plutôt citer "principe de surcompensation adaptative" (générique, vraisemblable) ou une source ACSM/NSCA si le souci est académique.

- **[W4-W9, tous les jours J5]** HIIT warmup = "12 min progressif" mais détail varie (W4 = "8 min", W5 = "10 min", W8-W9 = "12 min"). Harmoniser en "10-12 min progressif" ou clarifier la variabilité intentionnelle.

- **[W10 J5, bloc force]** "Squat à charge maximale du plan" — oui, mais la cible reps = "3 reps chaque exercice". En W6 J1, squat pic = 5×3 (charge 90%+). En W9 J1, squat jump ~30% 1RM léger. Clarifier que W10 J5 cible la charge brute de W6 J1 (les 5×3) pour une comparaison valide.

- **[Summary vs progression_logic]** Summary cite "5 patterns fondamentaux" (squat, deadlift, push H, push V, pull H, pull V), mais "5 patterns" sont en réalité 6. Corriger à "6 patterns fondamentaux" ou unifier le terminology (ex : "5 patterns + core" ou lister les 5).

---

## Manques notables

- **Référence 1RM estimation claire** : Le plan évite les tests maximaux (bon call en débutant/avancé sans pathologie), mais n'offre pas de méthode d'estimation de 1RM chiffrée (ex : Brzycki, Lander, Epley). L'utilisateur doit inventer. **Recommandation** : ajouter en W1 ou safety_notes une ligne : "Estimation 1RM (sans test maximal) : charge de travail × (36 / (37 - nombre de reps complètes)) — utilisée pour calibrer les charges %1RM des semaines ultérieures."

- **Progressions HIIT non-linéaires justifiées** : W2 J5 saute de "2 min Z4" à "Tabata Z5" sans justifier ce saut comme intentionnel. Les raisons pédagogiques (stimulus anaérobie nouveau) ne sont pas explicitées pour l'utilisateur. Ajouter brièvement : "W2 introduit la méthode Tabata pour développer la puissance anaérobie, distincte de l'endurance aérobie de W1."

- **Indicateurs de surcharge semaine par semaine** : Safety_notes cite "signes de surcharge (3+ = retour cutback)" mais n'explicite pas pour chaque semaine ce qui constitue "progression normale" vs "surcharge manifeste". Ex : combien de reps de squat perde en W4 (vs W3) avant d'alarmer ? Proposer une grille W par W (ou dire "observe la performance : ±2 reps normal, >3 reps baisse = alarm").

- **Récupération inter-séance** : Le plan cite hydratation et nutrition post-séance (safety_notes) mais ne conseille pas de durée minimale de sommeil, de fenêtre post-séance idéale (ex : "au moins 6-8h avant la séance suivante" si double séance J5) ou de jours off optionnels entre W3 et W4. Pour un "avancé", c'est pédagogiquement faible — un avancé gère sa récup.

---

## Scores (sur 10)

- **Cohérence interne : 8.5/10**
  - ✅ duration_weeks = 10 ↔ weeks.count = 10 OK.
  - ✅ Progression double progression → progression linéaire → cluster → plyométrie → tapering logique et progressive.
  - ✅ Cutback W7 bien placé (après pic W6, avant relance W8).
  - ❌ Rest_seconds W1-W3 = 150 vs "ACSM 180 min" stated en safety — mineure mais visible.
  - ❌ HIIT W2 saute de niveau sans justification linéaire.
  
- **Alignement référentiel : 8/10**
  - ✅ Principes NSCA/ACSM cohérents (double progression, zones FC, periodization Platonov-style).
  - ✅ Pattern coverage complète (squat, hinge, push H/V, pull H/V + core).
  - ✅ Volume progression lissée, cutback obligatoire respecté.
  - ✅ Cardio : Z2 aérobie, Z4-Z5 VO2max, Tabata anaérobie — spectre complet.
  - ❌ Pas de référence à Billat (30/30) en W4 J2 — méthode puissante mais non expliquée scientifiquement.
  - ❌ Nordic curl introduction W7 (tardive) — aurait pu entrer W1 comme prévention.

- **Sécurité : 8.5/10**
  - ✅ Safety_notes très complets : drapeaux rouges spécifiques (ITBS, conflit sous-acromial, ischio), grille RPE, hydratation, nutrition.
  - ✅ Progression force cohérente avec recommendation ACSM (double progression).
  - ✅ Tests de la parole pour cardio Z2 (bon marqueur pratique).
  - ✅ Spotter/cage obligatoire pour charges lourdes.
  - ❌ Rest_seconds incohérent vs ACSM statement (150 ≠ 180).
  - ❌ Pas d'avertissement explicite sur forme/technique avant charges lourdes W4+ (dire "filmer ta forme ou consulter un coach avant première séance W4" aurait aidé).

- **Pédagogie : 8/10**
  - ✅ Instructions claires par exercice (tempo 3-1-X expliqué, RPE défini, notes contextuelles riches).
  - ✅ Progression par blocs compréhensible (B1 activation, B2 développement, B3 puissance).
  - ✅ Checklist d'autonomie W10 J5 excellente (5 critères auto-évaluation).
  - ✅ Bilan mobilité itéré en W3 et W7 (rétroaction continue).
  - ❌ Estimation 1RM non formalisée (utilisateur doit inventer).
  - ❌ Progressions HIIT justifiées pour l'expert, pas pour l'utilisateur lambda.
  - ⚠️ Mobilité W1 J6 ne définit pas baseline pour les retests — risque de non-comparabilité.

- **Global : 8.25/10**

Template solide, **bundlable après correction des 3 issues importantes** (rest_seconds harmonisé, HIIT W2 progressif, 1RM estimation claire). Les issues mineures sont d'amélioration UX, non bloquantes. Le program offre une structure périodisée robuste, pédagogie enrichie, et sécurité exemplaire pour une app iOS grand public ciblant l'avancé polyvalent.