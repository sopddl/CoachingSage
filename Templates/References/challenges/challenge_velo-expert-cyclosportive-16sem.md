# Challenge Report : velo-expert-cyclosportive-16sem

## Verdict
Template bundlable en l'état avec correction d'une incohérence critique sur W9 (test FTP vs séance manquante) et clarification d'une ambiguïté pédagogique mineur sur les calculs de zones. Le plan est solide, bien étayé théoriquement, et respecte les standards WorldTour/Coggan pour un cycliste expert. Trois points importants à patcher avant release.

## Issues critiques (bloquantes pour bundle)

- **[W9 J3]** Test FTP 20 min : énoncé présente "90 min de séance totale" mais le test FTP lui-même (20 min) + échauffement (20 min) + refroidissement (20 min) = 60 min minimum. Or la durée_minutes affichée est 90, ce qui est incohérent avec les exercices listés. Le repos post-test (20 min Z1) est noté en cooldown, mais pas compté dans duration_minutes. → **Fix** : clarifier que duration_minutes = 90 min inclut échauffement (20 min) + test (20 min) + cooldown (20 min) + 30 min récupération active Z1 additionnelle pour consolidation post-test FTP. Ou réduire duration_minutes à 60 si seul le strict test.

- **[W2-W16, générique]** Zones de puissance définies en safety_notes mais aucun exercice n'affiche la FTP de référence. Un cycliste expert dispose d'une FTP estimée > 280 W (profil), mais toutes les zones sont en % FTP relatif. Au test W9, si la FTP réelle diffère de l'estimation (ex: 270 W au lieu de 280), les cibles de puissance pour W10-W16 changent. Le template indique "recalculer les zones pour W10-W16" mais ne donne pas un exemple de recalcul ni d'outil/formule explicite. → **Fix** : ajouter en W9 un encadré post-test listant le nouvel FTP mesuré et fournir une table de conversion rapide (ex: "Si FTP mesurée = 275 W, alors Z4 = 250-289 W"). Sinon risque que l'utilisateur navigue à vue.

- **[W9 J2]** Repos complet ou marche 30 min noté comme "30 min / repos", type "rest", duration_minutes = 30. Mais aucun exercice associé ne précise si c'est repos complet (0 min de vélo) ou marche (30 min). Ambiguïté pédagogique : un expert peut interpréter "marche 30 min" comme substitut acceptable à la sortie Z1. → **Fix** : clarifier que J2 W9 = repos complet (0 activité), marche 30 min est optionnelle pour bien-être, non entraînement. Ou séparer : "Repos complet recommandé. Option : marche 20 min jambes légères."

## Issues importantes (à corriger avant bundle idéal)

- **[W1-W4, générique]** Séances d'intensité (W1 J5 force basse cadence, W2 J3 intervalles Z4) sont programmées après une endurance Z2. Or safety_notes indique "48h entre deux séances d'intensité identiques". W2 J1 (seuil Z4 court) → J3 (seuil Z4 6x4 min) = 48h entre deux Z4. ✓ Cohérent. Mais aucune note dans les séances ne rappelle cette règle aux utilisateurs. Un cycliste novice-expert peut ignorer ce délai et effectuer 2 Z4 à 36h d'intervalle. → **Fix** : ajouter note dans W1-W4 "Attendre minimum 48h après cette séance avant de répéter une séance Z4 / VO2max similaire".

- **[W11 J1 et W12 J1]** Seuil "sur jambes pré-fatiguées" (W11) et "split négatif" (W12) sont des techniques avancées. Aucune instruction sur cadence spécifique en pré-fatigue. W11 J1 indique "20 min de pré-fatigue Z3" (dans warmup), puis "3x15 min seuil". Une cadence basse en pré-fatigue (50-60 rpm) rend le Z4 qui suit extrêmement difficile ; une cadence haute (95+ rpm) ne fatigue pas les jambes de la même façon. → **Fix** : préciser cadence pendant la pré-fatigue Z3 (ex: "20 min Z3 à cadence 85-90 rpm pour activer sans brûler les jambes, puis Z4 en 70-75 rpm").

- **[W7 et W11, VO2max]** Intensité Z5 (106-120% FTP) programmée en W5 (8x2 min), W7 (5x4 min), W11 (6x3 min), W14 (4x2 min). Format W7 5x4 min = 20 min de travail VO2max brut est cohérent avec la littérature (Coggan/TrainingPeaks max 20-30 min/semaine en Z5). Mais W11 6x3 min = 18 min, puis W12 absence de Z5 (uniquement seuil + transitions). Cette interruption de 2 semaines dans la progression VO2max en bloc spécifique (W10-W13) risque de perdre les adaptations VO2max acquises. → **Fix** : réintégrer une séance VO2max court (4x2 ou 3x3 min) en W12 pour maintien, ou justifier dans la progression_logic pourquoi VO2max n'apparaît plus en bloc spécifique.

- **[W11, grand fond]** Sortie longue W11 J7 : "170-200 km, 2800-3500 m D+" = répétition générale avant les 4 dernières semaines. Durée estimée : 7-8h40 (moyenne 20-23 km/h sur terrain avec 3500 m D+). Mais aucune note sur le ravitaillement critique : 70-90 g glucides/h sur 8+ heures = 560-720 g glucides totaux. Un cycliste de 75 kg ne peut pas absorber 720 g via gels seuls (digestibilité limitée). Le template cite "protocole nutrition testée en entraînement" mais ne donne pas un exemple de répartition (gels vs barres vs boisson énergétique). → **Fix** : ajouter exemple : "Sortie 200 km / 8h : 50 g gels (X 4) + 3 barres (200 kcal/pièce) + boisson énergétique (600 ml = 80 g glucides) = 720 g glucides ≈ 88 g/h".

- **[W16 J1, checklist]** Checklist d'autoévaluation post-course cite 5 questions, mais notes de la séance ne structurent pas l'enregistrement de ces réponses. Un utilisateur peut compléter la sortie sans remplir la checklist. → **Fix** : créer un champ structuré post-W16 (ex: "Remplir la checklist ci-dessous dans ton journal d'entraînement") avec 5 cases oui/non et un espace pour notes.

## Issues mineures (nice-to-have)

- **[W1-W7, générique]** Cadence en descente non spécifiée. Safety_notes couvre position (aéro basse) et freinage (ne pas freiner en virage), mais pas cadence. Sur descente : cadence libre ou maintien 85-95 rpm ? Un expert maintiendra naturellement 95+ rpm ; un autonome peut freiner/accélérer de façon inefficace. → Suggestion : "Descentes : cadence libre (naturelle = 100-110 rpm), position aéro basse, poids sur les pédales, jamais sur la selle".

- **[W15 J1-J5 et W16 J1-J3]** Affûtage (W15-W16) prévoit repos complet J2 W15, mais aucune note psychologique. Un cycliste expert arrivant en affûtage peut vivre une sensation de "jambes lourdes" (vidange glycogène) interprétée à tort comme "perte de forme". → Suggestion : ajouter en W14 cooldown ou W15 warmup : "Affûtage W14-W16 : sensation possible de jambes lourdes en W14-W15 (normal = surcompensation). Ne pas ajouter de volume par anxiété — maintenir le plan tel quel."

- **[W4, W9, W13 cutback weeks]** Volume réduit de "-15% à -20%" est noté dans goal, mais aucun tableau comparatif semaine précédente vs cutback. Un utilisateur doit calculer : W3 (270 km) → W4 (-15%) = 229 km. Risque d'imprécision. → Nice-to-have : afficher le volume cible en km/h de chaque cutback.

## Manques notables

- **Test FTP alternatif** : W9 propose test 20 min standard, mais aucun protocole alternatif pour cycliste en difficulté respiratoire ou cardio-respiratoire. Référentiel Coggan cite aussi test 1h ou protocole "field test 8 min". → Suggestion : ajouter note "Si 20 min semble insurmontable : test alternatif 3x5 min Z5 max + calcul [puissance moy x 0.90 = FTP]".

- **Contingence météo** : Plan ne mentionne pas adaptations en cas de pluie / froid extrême / vent violent. W11 grand fond prévoit 2800-3500 m D+ en terrain montagneux sans note sur sécurité descente en pluie (freinage réduit, risque de crevaison). → Suggestion : ajouter safety note "Pluie / mauvaise météo : sur sorties > 4h, préférer plat/parcours maîtrisé. En montagne : ralentir descentes de 10-15% vitesse nominale, freins testés avant. Voir équipement pluie en début de plan."

- **Équipement de sécurité détaillé** : Safety_notes couvre casque, pneus, lubrification, taquets. Manquent : feux avant/arrière si heures creuses, sonnette/avertisseur, gilet jaune visibilité ? Cycliste expert roulant 200-300 km/sem doit avoir équipement adéquat. → Suggestion : ajouter checklist équipement en début (casque ✓, feux ✓, répub kit ✓, bottier puissance chargé ✓).

- **Protocole d'échauffement standardisé** : Chaque séance propose un warmup différent. W1 J1 : "15 min Z1", W5 J1 : "20 min Z1-Z2 + 3 x 20 sec Z5", W11 J1 : "10 min Z1 + 20 min Z3 de pré-fatigue". Manque un échauffement type avant course (W16 J1). → Suggestion : créer un encadré "Échauffement course standard : 20 min Z1-Z2, puis 3x20 sec accélérations Z4, repos 3 min Z1, puis 10 min Z1 pur avant départ officiel."

- **Récupération inter-séance spécifiée** : Repos entre W1 J2 et W1 J3 n'est pas explicite (Y a-t-il 1 jour ou > 1 jour entre chaque ?) → Suggestion : ajouter jour précis (ex: "Repos complet le 4 avril", ou au minimum "J1, J2 repos, J3, J4 repos, J5...").

## Scores (sur 10)

- Cohérence interne : **8/10** (FTP W9 non recalculée précisément pour W10-W16, séances pré-fatigue manquent cadence spécifique, W11-W12 rupture VO2max non justifiée)
- Alignement référentiel : **9/10** (structure 4 blocs Coggan stricte, polarisation 80/20 respectée, cutback weeks positionnées correctement, seule question : VO2max en spécifique aurait mérité 1 séance de maintien)
- Sécurité : **8/10** (safety_notes exhaustives, mais manque contingences météo, équipement détaillé, alternances échauffement course finalisée)
- Pédagogie : **8/10** (progression paliers clairs, instructions exercices précises avec RPE/puissance, checklist post-course excellente, mais manquent : tableaux comparatifs cutback, exemple nutrition détaillé, note psychologique affûtage, test FTP alternatif)
- **Global : 8.25/10**