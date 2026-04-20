# Adaptability : hiit-avance-10sem + p2-short-sessions

## Rigidity score
**3/10**

Le template est **très rigide** pour cette contrainte. Il est construit entièrement autour de WODs longs (EMOM 30-35 min, AMRAP 20-30 min, For Time 25+ min). Réduire à 30 min max casse l'architecture fondamentale du plan : les progressions de volume (W1 EMOM 20 → W3 EMOM 30 → W7 AMRAP 30), les cutback weeks, et la philosophie ACSM de surcharge progressive linéaire deviennent inapplicables sans dénaturer le plan.

## Patch approach

Le seul approche viable est une **reconstruction partielle en 3 axes** : (1) Convertir les EMOM/AMRAP longs en format Tabata/40-20 denses (même densité métabolique, durée réduite) ; (2) Scinder les WODs longs sur deux jours (ex: thrusters W1 J3, pull-ups W1 J4) ; (3) Accepter que certaines semaines (W3-4, W7, W9) restent incompressibles — le pratiquant doit accepter une séance 35 min 1×/semaine minimum ou renoncer à ce template. Cette dernière option invalide le plan.

## Concrete modifications

- **W1-W2 : remplacer EMOM par Tabata dense** — W1 J1 (EMOM 20 min 2 exos) → Tabata 20/10 × 3 blocs complets (10 min) + Nordic curl (2 min) + 3 min échauff = 15 min structure → 30 min avec échauff propre. Format : min impair EMOM → 20 sec swings / min pair EMOM → 20 sec push-ups (même ratio work/rest, densité accrue).

- **W1 J3 (For Time 5 rounds) : découper sur 2 sessions** — J3 : 5 rounds pull-ups (10) + swings (15) en For Time < 10 min. J4 (nouveau créneau) : 5 rounds double-unders (20) + run (200 m) en For Time < 12 min. Chrono total des deux = chrono original W1 mais réparti.

- **W2 J2 (For Time chipper 5 exos) : incompressible à 30 min** — Durée effective 18-22 min + échauff 8-10 min = 26-32 min. Demande au pratiquant : accepter 1 séance/semaine à 35 min (W2, W4, W6-7, W9) OU réduire le nombre de reps/rounds (ex : 3 rounds au lieu de 5 sur chipper → écraser la progression).

- **W3-W4 EMOM 30-35 min : incompressibles** — Convertir W3 J1 (EMOM 30 min 5 stations) → EMOM 20 min 4 stations en rotation rapide (4×5 rotations). Sacrifie le volume : W3 passe de 30 minutes d'effort métabolique à 20 minutes, violant la progression linéaire W1(20) → W3(30) du plan.

- **W5-W8 cutback weeks : facile** — Déjà 20-25 min de WOD. Échauff 8 min + séance 15 min + retour 5 min = 28 min. Peu d'ajustement.

- **W6-W7 AMRAP 25-30 min : scinder sur 2 jours OU réduire durée** — W6 J3 (AMRAP 25 min format) → AMRAP 12 min (couper la moitié du volume, adapter les reps à la proportion : thrusters 5→3, box jumps 15→8, etc.). Progression W2(AMRAP 15 min) → W6(AMRAP 12 min) = régression en format.

- **W9-W10 (records et tapering) : possibles en 30 min** — W9 J2 (For Time 5 rounds benchmark) peut tenir en 30 min si le pratiquant optimise (échauff 8-10 min + WOD 15-18 min + étirements 5 min). W10 J5 demande 2 WODs en 70 min : scinder sur J5 (AMRAP 20 min) + J6 bonus (For Time benchmark) OU faire J5 uniquement (perte du benchmark W1 final).

## Rigidity issues

- **Architecture volume de base incompatible** : La progression linéaire ACSM du template (W1 volume modéré → W3 pic A → W5 cutback → W7 pic B → W9 retour au pic) repose sur des WODs 20-45 min. Réduire à 30 min max impose une réduction de volume systématique, cassant la courbe de surcharge progressive. La recommandation ACSM citée dans `progression_logic` devient non applicable.

- **For Time longs non réductibles sans perte de sens** : Un chipper 5 exercices (W2 J2, W7 J2, W9 J2) ne peut pas tenir en 30 min avec échauff/retour. Réduire à 3 exos crée un WOD différent, pas une adaptation du même WOD. L'athlète perd la comparaison de progression.

- **EMOM longue = densité métabolique unique** : EMOM 30-35 min engendre une densité spécifique (ratio travail/repos qui change chaque minute vs ratio fixe Tabata). Remplacer par Tabata 20/10 ou 40/20 change le stimulus physiologique : moins de lactate accumulation (20/10 = repos réguliers vs EMOM 30 min = repos décroissants sur les demandes élevées). Pas équivalent.

- **AMRAP 20-30 min impossible à remplacer** : L'AMRAP long développe une gestion pacing et une résistance mentale à 20-30 min. Réduire à AMRAP 12-15 min perd cette adaptation. Scinder sur 2 jours crée deux WODs indépendants, pas une seule séance adaptée.

- **Nordic curl en fin de EMOM long** : Si EMOM passe de 30 min à 20 min, la fenêtre de fatigue neuromusculaire diminue et le Nordic curl (exercice excentrique) n'arrive pas au même état de fatigue maîtrisée. Risque : ou trop frais (perte de stimulus préventif ischio-jambier) ou trop fatigué post-WOD court (fatigue accumulation). Protocole `safety_notes` délicat à respecter.

- **Cutback weeks W5 et W8 justifiées par accumulation de fatigue après pics de volume** : Si les pics sont comprimés à 30 min, la fatigue neuromusculaire n'accumule pas au même niveau. Garder les cutback weeks devient discutable. La structure 4-1-4 (4 semaines accumulation, 1 cutback, 4 semaines, 1 cutback) perd son fondement.

## Contradictions

- **`progression_logic` (1) PROGRESSION LINÉAIRE DU VOLUME : volume augmente W1(EMOM 20) → W3(30) → W7(35)** vs **contrainte 30 min max** : INCOMPATIBLE. La progression de durée = progression de volume ACSM. Adapter à 30 min max impose de réduire le volume chaque semaine (régression) ou de densifier (intensité augmentée sans volume → n'est pas la progression linéaire ACSM décrite).

- **`progression_logic` (2) CUTBACK WEEKS W5 (-15%) et W8 (-10%) obligatoires** : W5 doit être "-15% du pic W4 (EMOM 30 min vs 20 min)". À 30 min max, W4 EMOM = 30 min max compressé = ~20 min effectif. W5 cutback = -15% de 20 min = 17 min. Cela s'alignerait, **mais** le cutback de W8 (-10% vs W7 EMOM 35 min) est impossible : W7 EMOM comprimée = 25 min max, W8 cutback = 22.5 min, soit 2.5 min d'écart. Pas assez de différenciation physiologique pour justifier une cutback week (règle NSCA : cutback = -10 à -20% du pic pour amorcer la surcompensation).

- **`safety_notes` "jamais 2 séances intenses dos-à-dos"** : À 30 min par séance, si un athlète ajoute du volume perso ou rattrape une séance manquée, il peut facilement enchainer 2 séances en 60 min (30 + 30), violant la règle "espace 48h minimum entre sessions intenses". Augmente le risque tendinite ischio-jambière et conflit sous-acromial (surtout si Nordic curl réduit en W1-W2 du fait de la compression).

- **`progression_logic` (4) RENFORCEMENT PRÉVENTIF NON NÉGOCIABLE** : Nordic curl dès W1 J3 (réduction 50% tendinite ischio-jambière, Petersen et al.). À 30 min max, W1 J3 tient à peine (8 min échauff + For Time 15 min + Nordic 2 min = 25 min). Volume Nordic réduit à 3 sets au lieu de 3 sets complets → stimulus préventif diminue. Risk : tendinite ischio-jambière augmente, contredisant le design `safety_notes`.

- **WOD de référence W10 J5** : 70 min effectifs (AMRAP 20 min + For Time 5 rounds). À 30 min max, le pratiquant doit choisir : faire seulement l'AMRAP (perd le benchmark For Time W1 final) ou faire les deux sur 2 jours (W5-W6), perdant la structure de "WOD de référence final" et la checklist d'autonomie basée sur 2 tests simultanés.