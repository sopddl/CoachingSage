# Challenge Report : musculation-intermediaire-upperlower-12sem

## Verdict
Template de très bonne qualité, bundlable en l'état. Alignement référentiel excellent (ACSM/NSCA), cohérence interne solide, pédagogie claire et progressions justifiées. Quelques incohérences mineures sur l'équipement et une ambiguïté sur Nordic Curl. Globalement production professionnelle prête pour distribution.

## Issues critiques (bloquantes pour bundle)
Aucune issue critique détectée.

## Issues importantes (à corriger avant bundle idéal)

- **[W3 J5]** Nordic Curl : la note "5-6 reps = très difficile" est contradictoire avec l'affirmation progression_logic que Nordic curl apparaît "effectivement dans le contenu des semaines". En W3, 5-6 est un départ qui sera maintenu W5-W11 sans progression = stagnation du stimulus. Recommandation : préciser en W3 "5 reps, progression d'1 rep/semaine max jusqu'à W11 (7-8 reps)" pour respecter la logique annoncée.

- **[W5-W7]** Incohérence repos sur Dips lestés : 120 sec repos annoncé, mais progression_logic cite ACSM 2-3 min (120-180s) sur composés lourds. Dips lestés est un composé lourd à RPE 7-8 (W5) puis 8-9 (W6-W7). Correction : passer à 150 sec (W5) puis 180 sec (W6-W7).

- **[Tous blocs]** Équipement requis vs assumed_profile : le profil assume "accès salle de sport complète" mais ne spécifie pas ceinture lombaire, bandes d'assistance, ou kettlebell lourd pour goblet squat. Safety_notes cite ceinture comme "optionnelle" mais W5+ demande Front Squat "ou Goblet Squat lourd" — si profil n'a pas kettlebell 40+ kg, goblet squat peut être impossible. Correction : ajouter à assumed_profile "équipement optionnel recommandé : ceinture lombaire, bandes d'assistance pull-up, kettlebell 32+ kg ou haltère ajustable pour goblet squat".

## Issues importantes (à corriger avant bundle idéal) — suite

- **[W11 J5]** Checklist d'autonomie W11 mal positionnée : listée dans le dernier exercice (Bird-dog) au lieu d'être une section distincte post-séance ou en callout visuel. Risque que l'utilisateur la rate en fin de séance fatiguée. Recommandation : déplacer en `cooldown` structuré ou section séparée "Autoévaluation W11" avec visibilité améliorée.

- **[W1, progression_logic]** Incohérence sur la double progression upper/lower : progression_logic énonce "2,5 kg (upper) ou 5 kg (lower)" mais W2 bench press notes disent "+2,5 kg" et W2 deadlift notes disent "+5 kg" — correct, mais W2 leg press notes disent "+10 kg" sans justification. Vérifier : leg press 10 kg ou 5 kg, pour cohérence. Hypothèse : leg press machine souvent calibrée différemment (poulies 1:1, donc +10 kg peut être justes). Clarifier dans W2 leg press ou en intro.

## Issues mineures (nice-to-have)

- **[W6-W7]** Back-off sets nomenclature : "3×6 à -15% de la charge lourde" est une notation non-standard. Mieux : "3 séries de 6 reps à 70% (back-off volume)". Cohérence terminologique 5/3/1 vs back-off : mélange légèrement les paradigmes (5/3/1 simplifié + back-off). Peut confondre. Clarifier W6 notes : "méthode back-off ou tempo-volume (3 séries légères après travail lourd)".

- **[W9, W10]** AMRaP notation : "AMRAP à 85%" est utilisé en W10 mais pas défini formellement avant W10. Bien que "As Many Reps as Possible" soit clair, une phrase en W10 introduction aurait aidé : "AMRaP = faire le max de reps en bonne forme (arrêter 1 rep avant défaillance technique). C'est ton meilleur indicateur de progrès réel." (Le plan le fait bien W10, mais W10 J1 notes font référence sans rappel).

- **[W1 J1, warmup]** "Calibration RPE (1ère séance uniquement)" : bien pensé, mais checklist post-warmup manque de temps d'application. Recommandation UX : ajouter "Durée calibration RPE : ~10 min" pour que l'utilisateur ne court pas.

- **[Ensemble du plan]** Absence de notation sur le suivi des courbatures (DOMS) en fonction des blocs. Bloc 1 annonce "DOMS attendu", mais pas de guidage clair si DOMS excessif (>72h) en W2-W3 → ajuster volume ou reprendre de zéro en W1. Minor : safety_notes couvre le sujet, mais intégration en W2-W3 goal serait pédagogiquement utile.

## Manques notables

- **Mobilité défaillante au-delà de W12** : le plan propose "5 min marche" et "foam roller" mais aucun programme de mobilité structuré post-plan pour maintenir les gains (flexibilité, santé articulaire). Nice-to-have : ajouter une section "Post-plan (W13+) : routine mobilité d'entretien 3×semaine" en note.

- **Absence de variantes pour déficit d'équipement** : plan assume rack, banc d'haltérophilie, poulie haute, machines. Si utilisateur a accès partiel (ex: pas de machine leg press), aucune substitution B n'est proposée. Recommandation : tableau de substitutions en annexe (ex: leg press → sissy squat ; lat pulldown → résistance band pull-down).

- **Progression alimentaire non mentionnée** : le plan cite "alimentation protéique ≥ 1,6g/kg/j" une fois en safety_notes mais pas en intro ou rappel hebdomadaire. Pour un intermédiaire qui intensifie, absence de guidage clair sur surplus calorique vs maintenance vs coupe peut saborder les résultats. Recommandation : ajouter à default_objective ou W1 goal : "Objectifs nutrition parallèles : surplus calorique modéré (+200-300 kcal) ou maintenance selon objectif (force vs hypertrophie) ; protéine ≥ 1,6 g/kg/j."

- **Absence de guidance sur déchargement intra-semaine** : si RPE systématiquement +1-2 points vs cible (safety_notes l'évoque), pas de procédure claire. Recommandation : ajouter en safety_notes ou W5+ "Si RPE moyenne de la semaine > cible + 2 points sur 2 semaines consécutives : réduire les charges de 10% lors de la semaine suivante sans sauter la deload W4/W8."

## Scores (sur 10)

- Cohérence interne : 8.5/10  
  *(Progressions double progression cohérentes, cutback/deload bien intégrés, mais minor incohérences sur repos [dips] et notation [back-off/AMRaP] tardivement introduite)*

- Alignement référentiel : 9/10  
  *(ACSM/NSCA appliqués rigoureusement, periodization linéaire par blocs justifiée par Rhea et al., Israetel cité, Wendler 5/3/1 intégré, Nordic curl étayé Petersen 2011, top sets + autoregulation excellents pour intermédiaire)*

- Sécurité : 8.5/10  
  *(Safety_notes très complets, drapeaux rouges précis, RPE grille claire, surcharge CNS bien documentée ; minor : Nordic Curl progression ambiguë, Front Squat / Goblet Squat équivalence non sécurisée pour tous les profils)*

- Pédagogie : 8/10  
  *(Progressions claires, exercices expliqués en détail, mais Checklist autonomie W11 mal positionnée, AMRaP défini tard, mobilité post-plan absente, nutrition non progressive)*

- **Global : 8.5/10**  
  *(Excellent produit, prêt pour bundle. Corrections mineures recommandées avant distribution grand public sur iOS, notamment sur nomenclature back-off, équipement requis, et pédagogie post-W11.)*