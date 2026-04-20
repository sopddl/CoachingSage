# Challenge Report : musculation-expert-strength-5x5-cycle

## Verdict
Template de très bonne qualité, bundlable en l'état avec des corrections mineures. La structure en 3 blocs, les cutbacks obligatoires et la progression sont alignés sur les protocoles de référence (Madcow, Texas Method, NSCA/ACSM). Les safety_notes sont exceptionnellement détaillées. Quelques incohérences techniques et une issue critique requièrent correction avant bundle.

## Issues critiques (bloquantes pour bundle)

- **[W11 J5]** Deadlift — Attempt PR : la note "1 rep maximum uniquement" contredit le protocole annoncé en progression_logic qui ne limite PAS le DL à 1 rep en attempt PR. Le reste du template autorise 5 reps DL partout. Cela crée une confusion : soit c'est 1 rep DL max en W11 uniquement (à justifier par sécurité et mentionner dans les notes W9-W10), soit c'est 1-5 reps comme les autres. → **Harmoniser : clarifier si DL attempt = 1 rep seulement ou si c'est 1-5 reps comme le reste. Si 1 rep uniquement, ajouter dans progression_logic et dans les W10 notes une justification sécurité spécifique au DL.**

- **[W1-W12]** Incohérence rest_seconds sur deadlift vs bench/squat/rowing : le deadlift a systématiquement 240 sec (4 min) de repos, alors que la safety_notes dit "Repos 3 min minimum entre séries de composés lourds (ACSM/NSCA)". 240 sec = 4 min > 3 min minimum, donc c'est OK. Mais la safety_notes dit aussi "Ne pas sacrifier ce temps au profit de la durée de séance". Or les autres composés n'ont que 180 sec (3 min). → **Clarifier : si 3 min est le minimum ACSM, pourquoi bench/squat/rowing n'ont que 180 sec ? Soit les 5 composés ont 180 sec (acceptable pour ACSM), soit tous ont 240 sec. Recommandation : vérifier la source ACSM citée — les guidelines ACSM 2026 préconisent 2-3 min pour la force (6-15 RM) et 3-5 min pour la force maximale (1-6 RM). Un 5x5 à 80%+ 1RM est en limite, 3 min est minimal, 4 min est optimal. Laisser 240 sec DL et passer les autres à 180 sec est défendable, mais documenter.**

## Issues importantes (à corriger avant bundle idéal)

- **[W4 et W8 cutbacks]** Variantes paused non systématisées : la progression_logic annonce "variantes paused squat et paused bench pour renforcer les zones de transition" mais le contenu de W4/W8 mentionne paused squat et paused bench sporadiquement (J3 de W4 et W8). J1 et J5 de W4/W8 ne spécifient pas paused. → **Ajouter explicitement "paused squat (pause 1-2 sec en bas) et paused bench (pause 1-2 sec poitrine)" dans les notes de TOUS les squat/bench des W4 et W8, pas seulement J3, ou justifier pourquoi J1 et J5 ne sont pas paused.**

- **[W10 J1 et J3]** Squats 5x5 : volume annoncé comme "pic de volume 5x5 du cycle" en W10, mais les notes parlent de "avant-dernière semaine 5x5" et "pic de volume". W11 est PR attempts (non-5x5), donc techniquement W10 est le dernier 5x5 complet, ce qui est correct. Cependant, la clarté est faible : les notes ne disent pas explicitement "c'est le dernier 5x5 complet avant les attempts". → **Renommer W10 goal ou ajouter en début de séance : "Dernière semaine de volume 5x5 complet avant la semaine PR."**

- **[W11 Séance PR J5]** Timing attempts : le template liste les 5 mouvements dans l'ordre (squat → bench → OHP → DL → rowing). Pas de repos post-PR mentionné entre la tentative et le suivant. Les notes disent "5 min de repos complet" avant bench et OHP, mais ne mentionnent rien après le PR squat avant cette pause, et rien après DL/rowing qui sont les derniers. Le deadlift PR peut être neuralement très exigeant — sans repos post-DL avant rowing, le rowing sera sous-optimal. → **Clarifier le timing exact : squat PR → [5 min] → bench PR → [5 min] → OHP PR → [5 min] → DL PR (1 rep) → [repos ?] → rowing attempt. Si rowing suit directement DL, c'est risqué pour la qualité rowing. Recommandation : ajouter 3-5 min post-DL ou déplacer rowing avant DL.**

- **[W3 J1 et J3]** Dips lestés introduction : les dips sont annoncés en progression_logic comme renforçant les chaînes push verticales "négligées dans un protocole 5x5 pur". Or, le template ajoute les dips pour la PREMIÈRE FOIS en W3 J1 sans transition progressive. Un expert peut gérer l'ajout, mais les notes ne disent pas si c'est un nouveau mouvement (à décharger mentalement des autres composés ce jour-là) ou s'il faut réduire les composés. → **Clarifier W3 : ajouter note "Les dips sont nouveaux cette semaine — si tu sens une surcharge additionnelle, tu peux réduire les dips à 2x3 cette première semaine et monter ensuite."**

- **[W11 Bilan checklist]** Exercice 4 "Gestion de la fatigue" : "as-tu réussi à compléter les 3 séances/semaine sans manquer plus d'une séance par bloc" — ce critère est peu spécifique. 1 séance manquée sur 12 blocs = 1/12 = 8%, ce qui est très bon, mais la phrase pourrait décourage un pratiquant qui a manqué 1 séance en un seul bloc (ce qui reste acceptable). → **Reformuler : "as-tu complété ≥ 11/12 séances prévues ou ≥ 8/12 séances/bloc? Moins de 60% de complétude = reprendre le cycle précédent de W1."**

## Issues mineures (nice-to-have)

- **[W1-W3 warmup]** Échauffements différents par séance : les échauffements sont bien documentés en W1-W3, mais à partir de W4, ils deviennent génériques ("Identique A1", "Identique B2"). Les échauffements doivent s'adapter à l'intensité croissante (W4 cutback 72% ≠ W5+ intensification 82%+). → **Ajouter pour W4 cutback : "Échauffement allégé : barre x10, +20 x8, +50 x5 (90% est suffisant à 72%)." Pour W5+ : "Échauffement renforcé pour 82%+."**

- **[W12 J5 Bilan checklist]** Durée de l'exercice : "15 min" pour une checklist écrite est ambitieux mais faisable. Aucun problème, mais noter que si un pratiquant est fatigué post-cycle, 15 min de réflexion + écriture peut être rebutant. → **Optional : proposer un template de réponse de 30 sec par question (ex : "PR squat : [____] — nouveau record ? OUI/NON") pour accélérer.**

- **[Assumed_profile]** "Aucune blessure articulaire active" : cela exclut implicitement les personnes en réadaptation post-lésion légère (ex : légère douleur genou stabilisée). Un disclaimer type "Ce programme n'est pas adapté aux blessés en phase aiguë" serait plus inclusif. Mineure car la safety_notes couvre bien les cas d'arrêt.

- **[W4 et W8]** Duration_minutes non ajustée : W4 et W8 (cutbacks) durent 60 min contre 75-90 min en semaines régulières. C'est correct (moins de volume = moins de temps). Aucun problème, juste une note : les séances deload J3 (mobilité pure) durent 40 min, ce qui est cohérent. OK.

## Manques notables

- **Progression accessoires et conditionnement accessoire multi-articulaire** : le template se concentre sur les 5 composés + core + dips/pull-ups. Manquent des accessoires unilatéraux (lunges, step-up, single-leg RDL) ou des mouvements d'hypertrophie (leg press, hack squat, etc.). Pour un "expert 3+ ans", ces accessoires seraient attendus pour adresser asymétries et déficits mineurs. → **Option : ajouter une section "Accessoires recommandés en W1-W10" (2-3 mouvements complémentaires) ou clarifier que le focus volontaire du protocole est les 5 composés purs.**

- **Intensité globale des accessoires (dips, pull-ups, core)** : les dips et pull-ups ont des reps (8 et 6) mais pas de progressions claires en termes de lest. W3 ajoute "+2,5 kg de lest vs Bloc 1", mais Bloc 1 ne définit pas explicitement si c'est 5 kg, 7,5 kg, 10 kg de lest initial. → **Clarifier W3 dips : "W1-W2 : 10 kg de lest. W3 : +2,5 kg = 12,5 kg."**

- **Temps totaux de séance réalistes pour expert** : les durées varient (50-100 min) mais jamais d'explication de ce qui est dedans/dehors des 75-90 min annoncés en safety_notes. W5-W10 atteignent 85-90 min, ce qui respecte la plage. W1-W3 atteignent 75-80 min. Correct. Aucun manque critique.

- **Recommandation nutritionnelle post-PR W11** : la safety_notes parle de "collation protéines + glucides dans les 45 min post-séance" en général, mais W11 PR mérite un protocole spécifique (ex : repas complet post-PR pour maximiser la fenêtre anabolique). → **Minor : ajouter en W11 J5 cooldown : "Repas complet (protéines + glucides + graisses) dans les 2h post-PR attempts pour optimiser la synthèse protéique."**

- **Test de 1RM de baseline absent** : le template assume un "1RM établi" mais ne propose pas de semaine 0 ou de protocole de test du 1RM. Si un pratiquant commence sans 1RM exact, le cycle entier est mal calibré. → **Recommandation facultative : ajouter un préambule "Avant W1, faire tester tes 1RM sur les 5 mouvements (session courte, repos 2-3 jours avant W1)."**

- **Détail sur le microloading W11** : la progression_logic mentionne "+1,25 kg sur OHP/bench en fin de Bloc 2 et Bloc 3" mais les notes de W9-W10 sur OHP ne mentionnent jamais +1,25 kg. Les notes disent "+2,5 kg" systématiquement. → **Vérifier cohérence : si OHP stagne en W10 et passe à +1,25 kg seulement en W11, l'ajouter en note W10 "si blocage sur +2,5 kg, utiliser +1,25 kg". Sinon, déclarer que +1,25 kg ne s'applique que si RE-tenter (manqué le précédent) une semaine.**

## Scores (sur 10)

- **Cohérence interne : 8,5/10**
  - durée_weeks=12 ✓, progression +5/2,5 kg cohérente ✓, cutbacks W4/W8 ✓, RPE échelonnée cohéremment ✓.
  - Défaut : rest_seconds DL vs bench (240 vs 180) non justifié clairement (mineure mais source de confusion).
  - Défaut : paused variantes non appliquées systématiquement à W4/W8.
  - Défaut : DL W11 limité à 1 rep vs autres 1-5 reps (contradiction interne majeure).

- **Alignement référentiel : 9/10**
  - Madcow, Texas Method, NSCA/ACSM bien appliqués. ✓
  - 5 patterns fondamentaux couverts chaque semaine (squat, hinge, push H, push V, pull H, pull V). ✓
  - Cutback weeks OBLIGATOIRES documentées (active recovery week, super-compensation). ✓
  - Micro-progression sur 12 semaines alignée sur protocoles établis. ✓
  - Mineure : pas de suggestion d'accessoires unilatéraux ou d'hypertrophie secondaire (attendus expert).

- **Sécurité : 9,5/10**
  - Safety_notes exceptionnellement détaillées (drapeaux rouges ACSM, DOMS vs douleur, surcharge neuromusculaire). ✓
  - RPE 10 limité à W11 uniquement. ✓
  - Repos composés 3-4 min documentés. ✓
  - Ceinture recommandée à 80%+. ✓
  - Spotters mentionnés pour W10-W11 (squat, bench). ✓
  - Mineure : pas de protocole d'échauffement systématique ajusté à l'intensité en W5+.

- **Pédagogie : 8/10**
  - Instructions exercices claires + RPE/cadence/respiration spécifiées. ✓
  - Progression par paliers (jamais de saut >5kg squat, >2,5kg bench). ✓
  - Checklist autonomie complète en W12 (excellente). ✓
  - Notes disent "si RPE > 9, réduire" (auto-évaluation). ✓
  - Défauts : échauffements génériques après W3, durée checklist un peu ambitieuse (15 min), microloading OHP non clairement documenté en W9-W10.

- **Global : 8,5/10**
  - Bundlable en l'état après correction de la deadlift W11 (critical issue).
  - Excellente structure, documentation de sécurité de haut niveau, alignement NSCA/ACSM solide.
  - Améliorations nécessaires : clarifier rest_seconds rationale, systématiser paused variantes, harmoniser DL attempts.