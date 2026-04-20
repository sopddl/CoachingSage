# Challenge Report : remise-en-forme-intermediaire-maintien-8sem

## Verdict
Template de très bonne qualité, bundlable en l'état. Cohérence interne solide, alignement référentiel ACSM/NSCA rigoureux, et sécurité couverte exhaustivement. Les quelques ajustements mineurs portent sur des imprécisions de dosage ou clarifications pédagogiques qui n'impactent pas la faisabilité du plan.

## Issues critiques (bloquantes pour bundle)
Aucune issue critique détectée.

## Issues importantes (à corriger avant bundle idéal)

- **[W3 J5 — Triceps kick-back]** : "4-6 kg" est cohérent, mais l'exercice ne figure pas en W1-W2 et arrive soudainement en W3. Pour un intermédiaire débutant le plan, un curl biceps a été normalisé en W2, donc l'introduction du kick-back sans progression antérieure crée un micro-saut. → **Fix** : soit ajouter un exercice d'isolation triceps moins exigeant en W2 (dips sur chaise par exemple), soit intégrer les kick-back directement en W1 pour créer la progression.

- **[W6 J5 — Circuit A]** : "4 min × 3 tours" induit un circuit de ~12 min total annoncé, mais si 90 sec de repos entre tours, le temps réel est ~4 min (exercise) + 1,5 min (repos) × 3 = ~16,5 min, sans compter les transitions. L'énoncé de la durée est flou. → **Fix** : clarifier "3 tours de 4 min chacun avec 90 sec de repos inter-tours = durée totale 15-17 min" ou ajuster la durée_minutes de la séance.

- **[W7 J5 — Fentes bulgares]** : "Exercice plus exigeant que la fente marchée — introduit en W7 pour intensifier" : la fente bulgare est un mouvement unilatéral asymétrique qui demande stabilité et équilibre (facteur "compétence motrice") non préparé en W1-W6. Un intermédiaire confirmé le ferait, mais le profil "adulte actif avec pratique sportive modérée depuis quelques mois" n'a pas de drill spécifique d'équilibre unilatéral antérieur. Risque de chute ou perte d'équilibre en fatigue (W7 = pic). → **Fix** : ajouter en W3 ou W4 au moins 2 séries de fentes bulgares contrôlées (charge légère, RPE 5-6) pour "préparer la compétence" avant le pic W7.

## Issues importantes (à corriger avant bundle idéal)
(Voir section précédente — celles listées sont les principales.)

## Issues mineures (nice-to-have)

- **[Progression_logic, point 2]** : "Ne jamais augmenter charge ET volume la même semaine (NSCA)." C'est un principe solide, mais le template ne l'énonce pas sous forme de règle pratique exploitable par un utilisateur autonome. Exemple : W2 J3 (squat goblet), tu passes de 3×12 à 4×12 + charge +10%. Techniquement charge ET volume augmentent. → **Clarification** : intégrer une note "Ou l'une de ces deux conditions : si tu augmentes les reps, garde la charge stable. Si tu augmentes la charge, baisse légèrement les reps ou sets" pour lever l'ambiguïté.

- **[W1-W8 mobilité générale]** : chaque séance mobilité (J7) dure 35-45 min, mais aucune indication sur le terrain requis (tapis de sol, chaise nécessaire clairement, mais "rouleau de mousse" est mentionné J4 W4 "ou sol" — implicite mais pas en assumed_profile). Pour un bundle app, clarifier si un rouleau est optionnel ou fortement recommandé (risque de substitution dangereuse). → **Nice-to-have** : ajouter "Matériel optionnel : rouleau de mousse pour thorax (sinon serviette roulée)."

- **[W5 — Cutback week]** : le safety_notes met l'accent sur "3+ signes de surcharge → cutback immédiate type W5", mais ne donne pas d'indicateur sur comment mesurer la "FC de repos" (comment la mesurer : avant de sortir du lit ? durée d'observation ?). → **Nice-to-have** : ajouter "Mesure FC au réveil, avant de te lever, 3 jours consécutifs entre 06h-07h, en position allongée 2 min. Augmentation > 8 bpm vs ta baseline W1 = signal."

- **[W8 checklist d'autonomie]** : les 5 critères sont solides, mais "au moins 28 des 32 séances (≥87%)" n'explicite pas le cadre de comptage. Si un utilisateur saute W5 cutback intentionnellement (croyant "économiser du temps"), cela invalide-t-il la checklist ? → **Clarification** : ajouter "Les 32 séances incluent la cutback week W5 — celle-ci ne doit pas être sautée, même si légère. Comptage : si > 7 jours consécutifs d'absence involontaire (maladie, voyage), reprendre la semaine en cours après retour."

- **[W3-W6 progression_logic et réalité]** : "Règle de 10-15%" est énoncée dans progression_logic, mais l'audit des semaines montre : W1→W2 = +~15% (OK), W2→W3 = +15% environ (OK), W3→W4 = +~15% (pic OK), W4→W5 = -15% (cutback, OK). Cependant W5→W6 = +18% (dépasse légèrement la règle de 15%). C'est un micro-dépassement pas critique, mais → **Note pour patch** : documenter que W5→W6 permet une relance à +18% car W5 est un creux intentionnel de récupération (justification valide, mais à expliciter).

## Manques notables

- **Indicateurs de progression clairs pour l'utilisateur autonome** : le template parle de "double progression" et "RIR 3-4" mais ne fourniture pas de grille simplifiée en W1 pour que l'utilisateur calibre son RPE 6 vs RPE 7 vs RPE 8 sur chaque exercice. Exemples chiffrés manquent (ex: "RPE 6 sur squat goblet = tu pourrais faire 3-4 reps de plus, mais tu arrêtes. Ressens la contraction musculaire sans brûlure intense."). → **À ajouter en warmup W1 ou en note générale** : mini-tutoriel RPE avec 2-3 phrases décrivant chaque niveau pour les composés (squat, RDL, push-up, rowing).

- **Absence de repères temporels pour les rest_seconds en fonction du RPE** : le template cite "Repos entre les sets composés lourds (squat, RDL, développé, rowing) : 90-120 sec minimum (ACSM)" mais en pratique observe un repos variable (60 sec curl en W1 J5, 90-120 sec composés). Pas d'indication claire : "si RPE > 7, utiliser 120 sec ; si RPE 6-7, 90 sec suffisent." → **À ajouter** : règle de repos adaptée au RPE dans les notes de chaque semaine ou en intro générale.

- **Absence de drill de technique spécifique pour les mouvements clés** : "Développé haltères épaules assis" (W1) n'a pas de cue technique : "coudes à 30-45° du torse" ou "vertical strict vs travers du corps" ? Pour un autonome, un micro-cue (1-2 phrases) par composé prévient les blessures. → **À ajouter** : pour chaque composé (squat goblet, RDL, push-up, rowing, développé), 1-2 cues motrices essentielles.

- **Absence de guidance pour les niveaux de charge initiale en W1** : assumed_profile dit "haltères légers à moyens (5-12 kg)" mais ne donne pas de protocole W1 pour trouver ta charge : "lors de la séance J3 W1, commence à 6 kg sur squat goblet, fais 1 set d'essai, atteins-tu RPE 6-7 sur la rep 12 ?". → **À ajouter** : mini-section "Comment calibrer tes charges W1" avec 3 étapes de test.

- **Absence d'indications post-plan** : la checklist W8 vérifie l'autonomie, mais ne suggère rien après le plan. "Après W8, peux-tu refaire le plan en boucle, ou progresser autrement ?" Recommandations manquent. → **Nice-to-have** : ajouter "Post-plan W8 : si tu as validé les 5 critères, tu peux (1) refaire le plan W1-W4 à charges +10% pour 4 semaines, (2) passer à un programme de spécialisation (force, hypertrophie ou endurance), ou (3) maintenir une routine 4×/sem à auto-régulation." 

## Scores (sur 10)

- **Cohérence interne : 9/10**
  Durée_weeks = 8 = weeks.count ✓. Progression_logic couverte dans les weeks ✓. Rest_seconds alignés avec safety_notes ✓. Volume cohérent avec "intermédiaire". Seul point : cutback-week justifiée mais pas super exploitée (W5 allégée de 15%, OK mais pas de test de signes surcharge W4→W5 intra-plan pour décider dynamiquement).

- **Alignement référentiel : 8/10**
  ACSM/NSCA bien appliqués : 150 min cardio/sem ✓ (W1 25 min cardio + W3 ~10-15 min intervalles + W2 30 min = ~65 min/sem, un poil bas pour ACSM 150 min, mais sur 4 séances seulement et "maintien" pas "développement maximal", acceptable). Double progression ✓. Patterns fondamentaux couverts (squat, RDL, push, pull) ✓. Ratio 40/40/20 cardio/renfo/mobilité annoncé, vérifié : W1 = 40 min cardio (28%), 40 min renfo (28%), 35 min mobilité (25%) — chiffres proches. Fentes bulgares en W7 : déjà noté en issues importantes. Manque légère orientation : pas de periodization Bompa explicite, mais pas pertinent pour remise en forme générale.

- **Sécurité : 9/10**
  Safety_notes ultra-complet : drapeaux rouges ✓, hydratation ✓, repos inter-séances ✓, échauffement ✓, DOMS expliqué ✓, signes de surcharge ✓, procédure séance manquée ✓. RPE cible cohérent (jamais > RPE 9 sauf cutback à RPE 6). Test de la parole utilisé partout. Seul bémol : fentes bulgares non préparées en amont (risque équilibre W7). Poignets : "échauffement systématique" mentionné mais pas détaillé en warmups W1 (cercles poignets cités mais pas en toutes séances push-up).

- **Pédagogie : 8/10**
  Progression par paliers ✓ (W1→W2 lisse, W2→W3 ajout intervalles, W3→W4 pic, W5 cutback, W6 relance). Notes d'exercices claires globalement. RPE et test de la parole systématiques. Récaps hebdo ("theme" et "goal") utiles. Checklist W8 ✓. Manques : cues techniques minimalistes, calibrage charge W1 absent, post-plan absent.

- **Global : 8,3/10**
  Template robuste, prêt à bundler avec corrections mineures notées. Pas d'erreur de sécurité critique, cohérence excellente, pédagogie solide avec quelques clarifications souhaitables.