# Challenge Report : tennis-expert-tournoi-prep-16sem

## Verdict
Template **bundlable avec réserves mineures**. Structure globale solide, alignement NSCA/ATP-préparateurs excellents, progressions cohérentes. Cependant : (1) incohérence entre le volume déclaré (4 séances/sem) et le volume réel de certaines semaines (W9-W11 réalistes, mais W15-W16 sont déficitaires) ; (2) rest_seconds sur composés lourds (W5-W7) ne respectent pas toujours les 2'30 ACSM annoncés en safety_notes ; (3) absence de seuil RPE critique avant cutback pour déclencher une réduction (safety_notes dit "4 signes", mais pas de logique dans le plan pour y répondre) ; (4) W15 volume est déjà affûtage, ce qui empiète sur W16 semaine de tournoi (redondance).

## Issues critiques (bloquantes pour bundle)
- **[W5 J1]** Complexe "RDL + sprint 10 m" : rest_seconds = 180 sec pour un complexe où le 2e élément est un sprint 10 m d'intensité maximale. Or ACSM/NSCA prescrit 3-5 min de repos complet après pliométrie/sprint maximal pour restaurer le système nerveux. 180 sec (3 min) est la limite basse. Formulation OK, mais la brièveté pourrait être dangereuse sur plusieurs semaines (accumulation fatigue neuromusculaire). **Fix proposé** : augmenter à 200-210 sec ou expliciter dans les notes que ce repos court n'est acceptable que si RPE du sprint reste ≤ 9.

- **[W7 J1]** Power clean "si technique solide, sinon kettlebell swing" : aucune indication de ce qui définit "technique solide". Un joueur expert en tennis n'a pas 90% de chance d'avoir la technique power clean au niveau olympique. **Fix proposé** : privilégier kettlebell swing comme défaut (plus sûr) et lister les critères précis du power clean (capture photo/vidéo ou supervision coaching).

- **[W15-W16]** Incohérence semaines de taper : W15 est déjà un "affûtage avancé" avec volume -35% (J1 = 40 min, J3 = 35 min, J5 = 55 min, J7 = 30 min, total ~ 160 min). W16 "semaine du tournoi" annonce "activation pré-tournoi — jour de match" sur J1, mais le format J1/J3/J5/J7 suggère 4 jours distincts (lundi/mercredi/vendredi/dimanche). **Fix proposé** : clarifier que W16 J1-J7 correspondent à des "matchs de tournoi" et non à des séances planifiées fixes. Proposer plutôt un protocole "jour de match" et "jour off" réitérable.

## Issues importantes (à corriger avant bundle idéal)

- **[W1-W4 globally]** Bloc 1 annonce "construction physique fondamentale" mais inclut déjà des box jump (W3 J1 : 5 reps 4 sets) et lateral bounds (W3 J1). Pour un "fondamental", c'est rapide. Référentiel NSCA training phases suggère pliométrie basse intensité (sauts < 50 cm) seulement en fin de Bloc 1. **Fix** : clarifier que W3 pliométrie = "initiation" (hauteur modérée) et que Bloc 2 = intensification.

- **[W2 J2]** RSA "8×10 sec/20 sec" : ratio 1:2 citée. Or progression_logic dit "Bloc 1-2 = 1:2 à 1:4 (endurance RSA)". W2 ne précise pas si c'est 1:2 constant ou progression 1:2 vers 1:4. **Fix proposé** : ajouter note explicit "progression vers ratio 1:3 semaines 2-4 pour augmenter le stress anaérobie".

- **[W4 J7]** Visualisation mentale annoncée dans title mais n'apparaît qu'à W15-W16. Pour un plan de 16 sem expert, la préparation mentale devrait débuter W8-W9 (Bloc 3, transfert compétitif). **Fix** : ajouter une routine de visualisation ou de reset mental dès W8-W9.

- **[W6 J3]** "Super tie-break sous pression (10 points) × 3" — 3 super tie-breaks = 30 points d'intensité maximale en ~40-50 min, sans clarification de récup inter-tie-break. Un match de tournoi réel ne demande jamais 3 tie-breaks consécutifs. **Fix** : réduire à 2 super tie-breaks ou rallonger les pauses à 3 min.

- **[W9 J3 et W11 J3/J5]** Format "2 matchs / jour" (W9 J3 = Match 1 + Match 2, W11 J3/J5 = Match 1/2/3 sur 3 jours) : aucune progression de la charge entre W9 et W11. En W9, c'est "simulation tour 1 + tour 2 en 48h" ; en W11, c'est "3 matchs en 4 jours". Arithmétiquement différent mais pas clairement positionné comme intensification. **Fix proposé** : renommer W11 comme "pic compétitif — semaine tournoi intégrale" et distinguer clairement la densité matchs (W9 = 2 matchs/48h ; W11 = 3 matchs/4 jours).

- **[W12 J1]** "Bilan charge max 3RM" : aucune indication de ce qu'on fait si la charge max n'augmente pas (cas normal après 11 semaines intenses). La fiche ne dit pas "réessayer" ou "garder la charge de W11". **Fix** : ajouter "si progression stagne, maintenir la charge W11 et arrêter l'accumulation ; l'entraînement en Bloc 3-4 vise la qualité, pas le gain de force".

- **[Safety notes vs rest_seconds]** Safety_notes cite "repos 2'30 minimum (ACSM)" pour composés lourds, mais W5 J1 RDL + sprint complexe = 180 sec (3 min exact, acceptable mais limite). W6 J1 idem. Pas problématique mais tension entre texte et exécution. **Fix** : mettre rest_seconds à 200 sec minimum sur tous les composés Bloc 2.

## Issues mineures (nice-to-have)

- **[W2 J2]** "Ratio 1:2" pour RSA 8×(10 sec effort / 20 sec récup) : formulation claire, mais l'appli ne dit pas si c'est "chronométré à la seconde" ou "estimation RPE". Ajouter "utiliser chronomètre" pour la rigueur.

- **[W3 J2]** "Interval pyramidal" : pas de durée total. 2 pyramides de 15/30/45/30/15 sec = ~4 min effort actif. C'est un petit volume pour une séance "cardio". Logique ? Oui (W3 = intensification progressive), mais confus pour un lecteur. Ajouter durée total estimée (15 min avec pauses).

- **[W6 J4]** Match avec "contrainte obligatoire : serveur-volleyeur" : tactiquement bonne, mais pas testé pour un joueur avec peur du filet. Risque de 40+ fautes directes volée = frustration et apprentissage négatif. **Fix mineures** : ajouter "si > 50% fautes volée, réduire la fréquence d'approche à 20% des points et augmenter progressivement".

- **[W12-W16]** "Checklist d'autonomie" promise en summary est livrée UNIQUEMENT en W16 J7. Idéalement, une checklist progressives devrait exister : W1 (bilan), W4/W8 (points clés Bloc 1-2), W12 (milieu plan), W16 (final). **Nice-to-have** : ajouter mini-checklist W4, W8, W12.

- **[General notation]** Pas de balise "estimated_energy_expenditure" (kcal/jour ou ratio de charge ATL/CTL). Pour un joueur classé qui suit ce plan, c'est utile pour l'alimentation. **Nice-to-have** : ajouter estimation globale volume hebdo (kcal ou TSS si utilisation de TrainingPeaks).

## Manques notables

- **Pas de protocol pour absence/maladie en Bloc 3-4** : safety_notes en W1 disent "2 semaines de pause → retour W1" mais si maladie en W10 ou W13, retour à W1 détruit l'affûtage. **Manque** : ajouter logique "si maladie W10-W12 : skip 1-2 matchs simulés mais maintenir force. Si maladie W13-W15 : couper 1 semaine, puis reprendre taper original en décalé".

- **Pas de plan B si blessure mineure (douleur persistante)** : safety_notes liste les drapeaux rouges (arrêt immédiat), mais pas les ajustements pour "douleur 3-4/10 en entraînement". Ex : douleur épaule modérée en W7, que faire ? Continue ou cutback ? **Manque** : ajouter règle "RPE ressenti douleur ≥ 4 et persistante > 2 jours → consultation médecin avant de continuer ; si OK : retirer les mouvements problématiques seulement (ex : pull-up si douleur épaule, garder squat)".

- **Pas de données de référence (baselines)** : le plan suppose que le joueur connaît ses zones FC (FCmax, FC seuil, FC VO2max) mais ne dit pas comment les mesurer au W1. Un novice en suivi physiologique ne sait pas quoi faire avec "zone 2 = 65-75% FCmax". **Manque** : ajouter "W1 J3, faire test navettes 20m max et estimer FCmax = FCmax atteint. Alternativement, FCmax = 220 - âge. Zones : Zone 2 = 60-75% FCmax, Zone 3 = 75-85%, Zone 4 = 85-95%".

- **Pas de guidance nutrition spécifique aux matchs simulés W9-W11** : safety_notes parle d'hydratation (500 ml/h, électrolytes) mais pas de nutrition inter-sets pendant un match de 3 sets sans cooling break officiel. **Manque** : ajouter protocole "entre les sets : 30 sec hydration + 15 sec repos. Entre les matchs (48h tournoi W9) : repas 3-4h avant match 2, alimentation légère (sandwich, barre) 45-60 min avant pour éviter fatigue digestive".

- **Pas de seuil d'arrêt des matchs simulés** : W11 J3 "3 matchs en 4 jours" — si le joueur se blesse au match 1 ou 2, plan dit rien. **Manque** : ajouter "si blessure ou douleur nette lors d'un match W9-W11, arrêter immédiatement et consulter médecin du sport. Ne pas forcer pour terminer la simulation".

- **Pas d'équipement de monitoring recommandé** : le plan parle de "temps de service, FC, RPE" mais ne dit pas si montre GPS/FC ou app simple suffisent. **Manque** : ajouter "équipement recommandé : chronomètre (smartphone), ceinture FC (Polar/Garmin) optionnelle, vidéo smartphone pour analyse technique, carnet écrit ou Google Sheets pour stats matches".

## Scores (sur 10)

- **Cohérence interne** : 8/10
  - Progressions force/puissance/endurance cohérentes et linéaires.
  - Cutback weeks bien placées (W4, W8).
  - MAIS : W15-W16 redondance (affûtage puis semaine tournoi = deux phases similaires). MAIS : rest_seconds W5-W7 limite basse (180 sec pour pliométrie max).

- **Alignement référentiel** : 9/10
  - Référence NSCA, ACSM, ATP-préparateurs explicites et appliquées rigoureusement.
  - Patterns fondamentaux couverts (squat, RDL, pull, push H/V, rotateurs).
  - Spécificité tennis excellente (PAP, chop rotatoires, simulation matchs).
  - SEUL bémol : pliométrie W3 un peu tôt pour un plan "fondations", mais acceptable pour un expert.

- **Sécurité** : 8/10
  - Drapeaux rouges excellents et exhaustifs (épaule, coude, cheville, ischio).
  - Safety_notes très détaillées, protocole RICE, hydratation, sommeil, équipement cité.
  - MAIS : pas de seuil automatisé pour "arrêter la simulation si blessure". MAIS : pas de logique adaptive si douleur modérée (3-4/10 persistent).

- **Pédagogie** : 8/10
  - Progressions claires par bloc (Bloc 1 construction → Bloc 2 puissance → Bloc 3 compétition → Bloc 4 affûtage).
  - Instructions d'exercices détaillées (RPE, tempo, alignement corps).
  - Respirations, cadences chiffrées quand pertinentes.
  - **MAIS** : checklist d'autonomie vient trop tard (W16 seulement). MAIS : pas de FAQs sur "que faire si absence" ou "si douleur modérée".

- **Global : 8/10**
  - Template très professionnelle, alignée sur les meilleures pratiques ATP/NSCA.
  - Bundlable en l'état (les issues ne sont pas des bugs critiques, juste des précisions / cas limites).
  - Après les fixes mineures (rest_seconds, protocole maladie/blessure modérée, clarification W15-W16), note passerait à 9/10.