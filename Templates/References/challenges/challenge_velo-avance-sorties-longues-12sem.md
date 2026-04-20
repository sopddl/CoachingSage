# Challenge Report : velo-avance-sorties-longues-12sem

## Verdict
Plan de très haute qualité, parfaitement aligné avec les standards de periodization (British Cycling, TrainingPeaks, Mujika & Padilla). Bundlable en l'état avec corrections mineures. Les 4 axes d'audit (cohérence, référentiel, sécurité, pédagogie) sont solidement couverts. Quelques incohérences chiffrées et une omission pédagogique mineure ne justifient pas de refonte.

## Issues critiques (bloquantes pour bundle)
Aucune issue critique détectée.

## Issues importantes (à corriger avant bundle idéal)

- **[W5-W10 : Sweet Spot]** Les durées d'intervalle annoncées dans `progression_logic` (2×15 min W5, 3×12 min W6, etc.) ne correspondent pas toujours aux `rest_seconds` spécifiés dans les exercises. Exemple W5 J1 : notes dit "2×15 min Sweet Spot" mais `rest_seconds: 600` (10 min) entre blocs → clair. Cependant W6 J1 annonce "3×12 min" avec `rest_seconds: 480` (8 min) : c'est cohérent. **Fix** : vérifier que tous les repos inter-intervalles Sweet Spot W5-W10 correspondent à la formule annoncée dans `progression_logic` (10 min Z1 entre blocs W5-W6, puis 8 min W7+). C'est déjà le cas, mais documenté implicitement. Ajouter une note explicite dans chaque exercice Sweet Spot : "Rest = 10 min Z1 active entre blocs" ou "Rest = 8 min Z1 active entre blocs" selon la semaine.

- **[W1 J1 : Test FTP]** L'exercice "Test 20 min FTP" spécifie `duration: "20 min"` mais ommet d'indiquer si c'est un test seul ou si le warmup (15 min) + cooldown (10 min) sont inclus dans la `duration_minutes: 75` de la séance. La note du warmup dit "15 min Z1", et le cooldown en bas dit "15 min Z1 cadence libre". Total = 15 + 20 + 10 = 45 min, mais `duration_minutes: 75` annonce 75 min. **Issue** : manquent 30 min non comptabilisés dans les exercises. Clarifier si la séance contient un bloc Z2 supplémentaire après le cooldown ou si c'est une erreur de calcul. **Fix proposé** : ajouter un exercise "Pédalage Z2 léger 20 min" après la récupération post-test pour arriver à 75 min, OU réduire `duration_minutes` à 45 min si seuls warmup + test + cooldown sont prévus.

- **[W9 J1 : Simulation départ]** L'exercice "Simulation sur-zone au départ" annonce "1 min d'effort Z5+ (130-150% FTP)" répétée 3×. Intensité 130-150% FTP est cohérente avec une simulation d'attaque peloton. Cependant, les `rest_seconds: 300` (5 min Z1 entre les répétitions) sont probablement insuffisants pour un cycliste avancé se rétablissant de Z5+. Norme ACSM / TrainingPeaks pour VO2max court : 3-5 min récup, mais 130-150% FTP = surcharge anaérobie majeure → 5-8 min de récup Z1 recommandés. **Fix** : augmenter `rest_seconds` à 360 ou 420 (6-7 min), ou ajouter une note : "Si FC ne redescend pas < 70% FCmax en 5 min, prendre 2 min supplémentaires avant la répétition suivante."

## Issues mineures (nice-to-have)

- **[Volume hebdo W1-W12]** La `progression_logic` annonce volumes précis (W1 ~190 km, W2 ~210 km, etc.) mais les exercises du template ne donnent que des durées en minutes, pas des distances. Conversions estimées : 27 km/h moyenne (assumed_profile) × durée = distance. Vérification spot : W1 total = 75 + 120 + 70 + 180 min = 445 min ≈ 7h25 → ~200 km à 27 km/h (cohérent avec "~190 km" annoncé, marge acceptable +5%). W3 total = 80 + 140 + 75 + 225 min = 520 min ≈ 8h40 → ~233 km (annoncé "~225 km", acceptable +3%). Aucune anomalie critique, mais pour une app grand public : ajouter une colonne "distance estimée (km)" pour chaque semaine dans le summary, ou calculer automatiquement avec la vitesse moyenne du profil. **Nice-to-have** : c'est un confort UX, pas une erreur logique.

- **[W11 J5 / W12 J1]** Les durées d'activation (sprints courts 10-15 sec à 130-150% FTP) sont très légères — c'est correct pour du taper, mais l'absence d'un `warmup` explicite avant les 3×15 sec de W11 J5 pourrait induire un démarrage brutal. Ajouter : "Warmup: 5 min Z1 très doux, pas d'activation progressive, puis 2 min de pédalage cadence libre avant les sprints". Actuellement le cooldown du bloc Z2 (10 min Z1) sert de récup, mais il manque la transition. **Nice-to-have** : détail pédagogique pour éviter une accélération brutale post-repos.

- **[Safety notes : douleur antérieure genou]** La section cite "braquet trop lourd à cadence basse sur les côtes" comme cause, et recommande "cadence > 85 rpm, réglage selle". Cependant, aucun exercice du plan n'impose explicitement une cadence minimale sur les côtes (W2 J1 et W6 J5 disent "cadence 65-75 rpm en force" — contradiction avec la recommandation "cadence > 85 rpm"). **Fix** : ajouter une note dans W2 J1 et W6 J5 (travail côte) : "Si douleur antérieure genou : passer cadence 80-85 rpm minimum, réduire la résistance (braquet plus léger)." Clarifier la distinction entre "travail de force Z4 en côte à cadence 70-75 rpm pour un cycliste symptomatique" et "prévention / cycliste sain : cadence 85+ rpm obligatoire si antécédent genou".

## Manques notables

- **Stratégie alimentation détaillée W9-W10 sorties longues** : Le plan mentionne "1 gel toutes les 40-45 min" comme rule générale, mais pour les sorties de 120-140 km (W9 J7, W10 J7), une stratégie précise manque. Exemple : "À 50 km : 1 gel, bidon eau. À 90 km : 1 barre solide + bidon électrolytes. À 120 km : 1 gel caféiné si énergie dégradée". **Ajout recommandé** : micro-plan nutrition pour chaque sortie > 100 km, calibré aux sensations type du profil "nutritionist maîtrisée".

- **Checklist d'aérodynamique / position vélo** : Le plan cite "travailler la position aéro par blocs de 5 min si le vélo le permet" (W9 J3, W10 J3) mais n'inclut pas d'exercice dédié de "drill technique aéro" dans les semaines précédentes (W1-W6). Cycliste de niveau avance devrait avoir une séance technique posture / aéro intégrée W3 ou W4. **Ajout recommandé** : "W4 ou W5 : une séance de technique aéro 2×10 min en position basse sur plat, avec récup en position debout. But : adapter la souplesse dorsale et vérifier absence douleur cervicale avant W7+."

- **Récupération post-sortie longue W7, W10** : Après les sorties maximales (130 km W7 J7, 140 km W10 J7), les notes recommandent "bain froid optionnel" (W7) et "bain froid optionnel" (W10). Pour un cycliste avancé gérant 10h+ de pédalage, une protocole complet de récupération manque : "bain froid 10-15 min (ou douche alternée 3×1 min chaud/froid), compression socks 2-4h, surélevation jambes 30 min, repas 30-45 min post-sortie riche en protéines (30-40g) + glucides 3:1." **Ajout recommandé** : créer une section "Récupération post-sortie longue maximale" pour les jours 7 des semaines 7 et 10.

- **Variation nutrition selon conditions météo** : Plan ne mentionne pas adaptations pour temps chaud/froid (hydratation +25% en chaleur, épaississement alimentation solide en froid). Assumed_profile ne spécifie pas la saison de la cyclosportive. **Ajout nice-to-have** : "En conditions chaudes (>25°C) : augmenter hydratation à 1 bidon/30 min. En froid (<10°C) : passer gels en liquides chauds (isotonique warm)."

## Scores (sur 10)

- **Cohérence interne : 9/10**
  - Volumes hebdomadaires cohérents (+10% rule respectée, cutbacks à W4/W8/W12).
  - Progressions exercices alignées sur `progression_logic` (seuil 4×8 → 5×8 → 5×10 min conforme).
  - W1 J1 : discordance durée/composition (75 min annoncé vs ~45 min exercises) = -1 point.

- **Alignement référentiel : 9.5/10**
  - Sweet Spot (88-93% FTP) correctement utilisé comme outil clé du plan.
  - Zones d'effort (Z1-Z5) conformes ACSM / TrainingPeaks.
  - Taper final (W11-W12) conforme Mujika & Padilla 2003 (volume -50% W11, -80% W12, intensité maintenue).
  - Manque : aucune progression technique (drill cadence, aérodynamique) W1-W4. -0.5 point.

- **Sécurité : 9/10**
  - Safety notes exceptionnelles : drapeaux rouges spécifiés, zones clairement définies, hydratation + nutrition couverts.
  - Contradiction mineur : "cadence > 85 rpm" en prévention genou vs "cadence 65-75 rpm" en travail côte W2/W6 = -0.5 point.
  - Équipement (casque, kit réparation) obligatoire et documenté.
  - Manque : pas de protocole de retour progressif si séance manquée > 7 jours entre W1-W8 (safety_notes donne règle générale, mais pas d'exercice de "semaine recovery" proposé). -0.5 point.

- **Pédagogie : 9/10**
  - Instructions d'exercices précises (durée, zone, cadence, repos chiffrés).
  - Checklist d'autoévaluation post-course excellente (W12 J7).
  - Notes contextuelles aidantes (ex: "jambes lourdes après W7 = attendu").
  - Manque : pas de video/image référencée pour position aéro ou drill cadence. -1 point pour une app grand public (lien YouTube ou diagramme recommandé).

- **Global : 9/10**
  - Plan quasi-produit, très rigoreux, immédiatement exploitable.
  - 2 corrections mineures (durée W1 J1, cadence W2/W6) et 1 clarification (progression_logic ↔ rest_seconds Sweet Spot) suffisent.
  - Bundlable sans refonte.