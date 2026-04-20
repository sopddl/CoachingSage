# Challenge Report : musculation-expert-strength-5x5-cycle

## Verdict
Template de très haute qualité, bundlable en l'état avec corrections mineures uniquement. La structure est rigoureuse, alignée aux standards NSCA/ACSM, et les notes de sécurité sont exemplaires. Trois ajustements cosmétiques avant production : préciser le protocole d'échauffement W11 J5, clarifier la tolérance de fractionnement OHP, et ajouter un schéma visuel des paliers de progression.

## Issues critiques (bloquantes pour bundle)
Aucune issue critique détectée.

## Issues importantes (à corriger avant bundle idéal)

- **[W11 J5 — Échauffement Séance PR]** La section `warmup` cite des paliers spécifiques ("Squat : barre x8, +30 x5, +55 x3, +75 x2, +90 x1, +PR-5kg x1") mais le reste ne précise pas si +PR-5kg veut dire "5 kg de moins que le PR annoncé" ou "5 kg de moins que le 1RM initial". Pour un expert tentant un PR, cette ambiguïté est dangereuse. → **Fix** : clarifier "PR-5kg = 5 kg sous votre meilleur 1RM atteint jusqu'à présent (ou W10 si PR non encore confirmé)". Ajouter une ligne de sécurité : "Ne pas dépasser 3 séries d'échauffement après +PR-5kg ; arrêter si la barre ralentit."

- **[W9-W10 — Microloading OHP non explicite]** La progression_logic annonce "paliers de +1,25 kg si blocage" mais ne précise pas le seuil d'activation de cette réduction (nombre de séries non complétées ?). W10 J1 note "(ou +1,25 kg sur OHP si blocage en W9)" mais sans critère clair. → **Fix** : standardiser : "Si tu ne complètes pas 3/5 séries de 5 reps en W9 sur OHP, réduire à W10 +1,25 kg sur OHP (au lieu de +2,5 kg). Si 4/5 ou 5/5 complétées, maintenir +2,5 kg."

## Issues importantes (à corriger avant bundle idéal)

- **[W4, W8 — Paused bench ambigu]** Les notes indiquent "pause 1-2 sec sur la poitrine" mais ne précisent pas : pause avant le contact complet (1-2 mm du sternum) ou pause après contact complet ? Pour la sécurité épaule et la cohérence neuromusculaire, il doit y avoir contact barre-poitrine avant la pause. → **Fix** : clarifier "Paused bench : barre descend jusqu'à toucher légèrement la poitrine basse, pause 1-2 sec complète au contact, puis push explosif — pas de rebond. La pause commence au contact, pas avant."

- **[W3-W10 — Dips lestés et Pull-ups lestés introduction abrupte]** W3 J1 introduit les dips avec "Lest de départ : 5 kg si tu es à l'aise sur dips au poids du corps, 10 kg si tu les réalises couramment avec facilité. Si cette première semaine semble trop chargée sur les composés, réduis à 2x3 reps cette semaine et monte à 3x8 la semaine suivante." Cette option "2x3 → 3x8" n'est jamais revisitée et crée une ambiguïté sur le volume cible (8 reps vs autre palier ?). Le même problème existe pour pull-ups lestés en W3 J3. → **Fix** : spécifier "Volume accessoire cible Bloc 1-2 : 3x8 sur dips et pull-ups lestés. Si débutant sur lestés, commencer W3 à 2x5 reps et progresser vers 3x8 en W5 — ne pas tenter 3x8 si tu n'as jamais fait de lestés." Clarifier aussi les progressions W5-W10 : "À chaque progression de charges (W5, W6, W7, etc.), tu peux soit augmenter le lest de 2,5 kg (maintenir les 8 reps), soit augmenter les reps à 10 si le lest est maintenu. Priorité : maintenir 3 séries au-delà de 5 reps."

- **[W11 J5 — Placement du rowing PR]** La séance PR place le rowing avant le deadlift ("Bent-over barbell row — Attempt PR" puis "Deadlift — Attempt PR"). La justification donnée est "le rowing sollicite moins le SNC et les lombaires". Techniquement juste, mais la fatigue cumulée des 4 mouvements précédents (squat, bench, OHP, rowing) sur le SNC peut altérer la tentative deadlift final. Aucun template de référence (Madcow, Texas Method) n'isole le deadlift en dernier sur PR day. → **Fix recommandé (non bloquant)** : inverser l'ordre — deadlift avant rowing (deadlift 2ème ou 3ème mouvement, à distance du squat pour éviter la fatigue lombaire cumulée). Ou ajouter une note : "Si fatigue SNC perçue au moment du deadlift PR, réduire l'objectif PR deadlift de 5 kg (vs 10 kg initial) pour viser 5-8 reps au lieu de 1 rep maximum."

## Issues mineures (nice-to-have)

- **[Général — Absence de protocole échec en séries de travail]** La progression_logic énonce RPE 6-10 mais jamais "qu'est-ce qui se passe si tu échoues une série avant la 5ème rep ?" En W9-W10, RPE 9 = 1 rep en réserve, donc l'échec n'est pas prévu, mais des chutes de 1-2 reps (5-5-5-4-4) peuvent survenir. Ajouter une ligne simple : "Séries incomplètes (ex: 5-5-5-4-4) : si ≥ 3/5 séries atteintes, maintenir la charge semaine suivante. Si ≤ 2/5 séries, réduire de 5 kg (composés lourds) ou 2,5 kg (accessoires) et rejouer la semaine."

- **[W1-W3 — Absence de test 1RM formel]** Le `assumed_profile` mentionne "force maximale connue (1RM établi sur les 5 mouvements — si non disponible, effectuer un test 1RM 2-3 jours avant W1)". Aucune séance de test n'est incluse (pré-W1). Pour un expert, un test W0 calibré est critique. → **Ajout suggéré** : créer une "Week 0 — Baseline 1RM Testing" (3 séances sur 5-7 jours) avec protocoles d'échauffement normalisés et gestion de la fatigue. Ou clarifier en safety_notes : "Si tu n'as pas de 1RM établi : semaine avant W1, test chaque mouvement selon le protocole : 60% x5, 70% x3, 80% x2, 90% x1, puis attempts PR à +2,5 kg jusqu'à échec. Repos 5-7 jours après testing avant de débuter W1."

- **[W12 Checklist — Format peu numérique pour app]** La checklist "Bilan cycle" est en texte long (15 min pour répondre). Pour une app grand public, fragmente-la en champs numériques clairs : input 1RM PR squat [____], input 1RM PR bench [____], toggle "Suis-je satisfait de la progression ?" OUI/NON, etc. Format actuel est trop littéraire pour une saisie tactile iOS.

- **[Général — Absence d'icône "spotter obligatoire"]** À W7+, plusieurs séances marquent "Spotter obligatoire ou cage avec barres de sécurité" mais ce flag n'est pas unifié. Ajouter un champ `requires_spotter: true` dans le JSON de chaque exercise pour que l'app affiche une alerte visuelle ou badge "⚠️ Spotter".

## Manques notables

- **Protocole ajustement si équipement incomplet** : le `assumed_profile` exige "plaques fractionnées (1,25 kg disponibles)" mais ne donne pas de fallback si absence. Une simple note : "Sans plaques 1,25 kg, utiliser paliers de +2,5 kg constants — la progression sera légèrement plus lente mais viable."

- **Absence de notation de séances (tracking)** : aucun champ pour que l'utilisateur note "séance complétée (5-5-5-5-5 ✓)" vs "incomplète (5-5-5-5-4)" vs "RPE perçu différent". Le bilan W12 repose sur l'autosouvenance sur 12 semaines — risqué. Suggérer un journal de 1-2 lignes par séance : jour + poids + max reps complétées + RPE perçu + notes (ex: "fatigue genou après 3ème série").

- **Gestion de la fatigue — Pas de signal d'arrêt explicite** : les "signes de surcharge neuromusculaire" en safety_notes sont listés (FC +10 bpm, ralentissement barre, etc.) mais sans directive claire : "Si ≥ 3 signes pendant 3+ jours, prendre 3 jours off complets et reprendre au niveau de la semaine précédente." Actuellement c'est vague ("cutback immédiate ou repos 3 jours").

- **Absence d'hydratation/nutrition intra-séance** : les séances dure 75-90 min mais aucune mention de boisson, timing repas, sucres rapides pré/intra. Pour un expert, c'est un détail, mais pour bundling app grand public = matière pour checklist.

## Scores (sur 10)

- **Cohérence interne** : 9.5/10
  - duration_weeks = 12, weeks.count = 12 ✓
  - Niveau expert cohérent (3+ ans, 1RM établi, accès équipement complet) ✓
  - progression_logic vs exercises : tous les 5 éléments (5 patterns, cutbacks, RPE taper, microloading) sont appliqués ✓
  - Décalage mineur : règle "ne jamais réduire les 2 variables simultanément" non explicitement validée dans chaque semaine de stagnation (hypothétique seulement)
  - rest_seconds alignés : 180s composés, 240s deadlift ✓

- **Alignement référentiel** : 9/10
  - Structure 3 blocs Madcow/Texas Method classique ✓
  - Dosage 70-100% 1RM bien calibré expert ✓
  - Cutback W4, W8 conforme NSCA active recovery ✓
  - 5 patterns présents (squat, hinge, push H, push V, pull H, pull V via pull-ups) ✓
  - **Moins** : pull-ups lestés ne remplacent pas un vrai pull vertical pondéré (cela dit, on peut arguer que pull-ups = pull V), et "pull vertical" ne figure pas explicitement dans les 5 patterns énoncés — mais implicitement couvert via pull-ups lestés et dips
  - Progressions légèrement conservatrices (+5 kg squat/DL, +2,5 kg bench/OHP) = safer than faster ✓

- **Sécurité** : 9/10
  - Drapeaux rouges excellents (douleur lombaire, épaule, genou, cervicale, engourdissements) ✓
  - Ceinture recommandée à bon seuil (80%+) ✓
  - Repos inter-séries justifiés (3 min min, 4 min deadlift) ✓
  - RPE 9-10 limité à W10-W11 ✓
  - **Moins** : limite deadlift à 1 rep W11 est basée sur risque lombaire documenté (Plisk & Stone) mais la formulation reste un peu verbose pour une app — simplifier à "1 rep max uniquement pour réduire risque lombaire sub-max lourd"
  - Absence d'échappement si douleur aiguë mid-séance (procédure simplifiée aidée : "arrêt immédiat, repos 48h, puis reprendre à W-1")

- **Pédagogie** : 8.5/10
  - Progression par paliers claire (5 kg → 2,5 kg → 1,25 kg) ✓
  - Instructions d'exercices détaillées (foot position, bar path, ROM) ✓
  - RPE expliquées dès W1 warmup ✓
  - **Moins** : checklist W12 en texte plutôt que formulaire structuré (non idéal pour app)
  - Absence de vidéos ou liens référents (attendu pour JSON, mais une URL optionnelle serait utile)
  - Paused squat/bench en W4/W8 bien expliqué mais technique peut être nouvelle pour certains "experts" → ajouter "vidéo de référence : [URL paused squat]" en notes

- **Global : 9/10**

Template solide, pédagogiquement riche, sécurité élevée, très peu d'incohérences. Prêt pour bundle iOS moyennant trois ajustements (échauffement W11 PR, critère microloading OHP, clarté paused bench). Les issues mineures sont du polish, non des vices de design.