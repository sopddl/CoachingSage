# Challenge Report : sports-collectifs-expert-elite-prep-12sem

## Verdict
Template de qualité exceptionnelle aligné avec les standards NSCA/ACSM. Périodisation rigoureuse, sécurité intégrée à chaque niveau, pédagogie transparente. Bundlable en l'état ; aucune issue critique ne bloque le déploiement. Quelques incohérences mineures et lacunes de contrôle logistique à corriger avant production finale.

## Issues critiques (bloquantes pour bundle)
Aucune issue critique détectée.

## Issues importantes (à corriger avant bundle idéal)

- **[W4 J2]** "Run continu Z2" n'est pas un vrai remplacement de 30-15 en cutback pédagogiquement : la note dit "Récupère la capacité aérobie sans surcharger le SNC" mais un athlète élite risque de sous-interpréter Z2 comme "repos passif" au lieu de "Z2 actif = ~65-75% FCmax". Ajouter une note explicite : "Z2 signifie : phrases fluides possible, FC 65-75% FCmax estimée (~110-130 bpm pour élite sport co). Ne pas faire de trot léger torpide — Z2 = activité contrôlée, pas récupération passive."

- **[W9 J5]** "Small-sided game simulation (SSG)" propose une alternative "drill technique spécifique au sport" pour les cas sans terrain/partenaires. Or, l'objectif de la séance est "match-intensity" (90-95% FCmax, RPE 8-9). Un drill technique isolé (dribble + tir, réception + passe + COD) ne reproduit **pas** cette intensité physiologique. Résultat : un athlète solo risque une séance sous-dosée. **Fix proposé** : spécifier "Si SSG 3v3 impossible, obligation minimum = circuit intermittent 4×4 min (30 sec sprint + COD + 30 sec marche active) pour simuler la FC 90-95%FCmax. Drill technique ne suffit pas."

- **[W10 J5]** "Match simulation complète 45 min" liste un protocole très précis : "5 min Z2 + bloc 1-2-3 de 10-10-8 min à 90%FCmax avec récup 3 min". Or, **la durée totale annoncée est ~45 min mais le décompte réel = 5 + (10+3) + (10+3) + 8 = 39 min**. Imprécision sur le timing. **Fix** : clarifier "Durée nette de travail 39 min, durée totale séance 45 min avec échauffement/cooldown."

- **[W11 & W12 dans progression_logic]** Le taper est décrit théoriquement comme "réduire le volume de 30-50%, maintenir intensité 90%+". Le plan respecte cela : W10 vs W7 = -15% (W10 vs W9 = -25%), W11 vs W10 = -30%, W12 vs W11 = -60%. **Mais cumulatif W12 vs W7 = -85% du volume** — c'est au-delà du "30-50% recommandé par Mujika". Cela peut être juste (cutback élite = plus agressif) mais doit être expliqué explicitement dans le safety_notes : "Taper élite W11-W12 : réduction cumulative 80%+ vs pic Bloc 3 est intentionnelle et fondée sur les données de Mujika (2012) pour athlètes entraînés. Surveiller l'absence de anxiété pré-compétition ; si stress élevé, augmenter légèrement le volume J2-J3 W12."

## Issues importantes (nice-to-have avant bundle)

- **[W5-W6 introduction power clean]** La note W5 J1 dit "Si power clean non maîtrisé : kettlebell swing lourd (40-48 kg)". Or, l'introduction du power clean sur un athlète élite en Bloc 2 suppose une base solide. Aucun test de compétence n'est noté en W1-W2. **Suggestion** : ajouter en W1 un test de screening : "Test W1 J1 post-séance : tenter 3 reps power clean à barre vide. Si technique cassée ou instabilité du front rack : utiliser kettlebell swing pour le plan complet (option plus sûre). Valider avec un coach avant W5."

- **[W7-W9 absence de données de base pour athlètes déjà blessés]** Le assumed_profile dit "Aucune pathologie aigüe en cours" mais ne mentionne pas les antécédents de blessure. Un joueur avec historique d'entorse cheville G ou déchirure ischio antérieure doit avoir des cibles de prévention individualisées. **Suggestion** : ajouter en W1 "Profiling médical : déclarer au préparateur physique tout antécédent de blessure. Les charges de pliométrie W5-W6 seront réduites de 30-50% pour les articulations à risque identifiées."

- **[W6 et W10 sprint chronométrage]** W6 J2 et W10 J2 demandent de chronométrer les sprints 10m/20m/30m. Or, aucune référence élite n'est donnée en W1 pour que l'athlète comprenne son profil d'accélération vs vitesse max. **Suggestion** : ajouter en W1 J2 "Baseline sprint W1 : chronométrer les 20m split à 5m, 10m, 15m, 20m pour identifier ton profil d'accélération (phases 0-10m rapide = type sprinter) vs vitesse max (20m+ rapide = type vélocité). Ce profil guide les priorités tactiques en match."

- **[W12 J5 checklist]** La checklist est excellente mais repose sur une **auto-mesure du vertical jump et une comparaison subjective W1 vs W12**. Or, W1 n'inclut **pas** de test vertical jump formalisé. Le comparatif W12 vs W1 ne peut pas fonctionner. **Fix** : soit ajouter un test vertical jump en W1 J6, soit remplacer W12 par une comparaison sur des tests réellement documentés (20m sprint baseline W3 vs W12, T-drill W1 vs W12 qui existent).

## Issues mineures (nice-to-have)

- **[Séances Force W1-W3]** Tous les rest_seconds sur les composés lourds sont 150-180s (ACSM-compliant). Or, la note dit "ACSM 2-3 min repos sur composés" (120-180s) mais certaines séances listent rest_seconds 150 au lieu de 180 minimum. Exemple : RDL W1 J1 = 150s alors que le squat 180s. Par cohérence, les composés > 5 reps doivent avoir 150-180s min. **Minor** : uniformiser à 150s pour les composés 6-8 reps (acceptable) et 180s pour les 4-5 reps (lourd).

- **[W2-W3 Bulgarian split squat]** Notes disent "+1 rep vs W1" (W1 = 8 reps → W2 = 10 reps) et "+1 rep vs W2" (W2 = 10 reps → W3 = 8 reps). **Incohérence logique** : on progresse W1→W2 puis on recule W2→W3. Vérifier l'intention : soit c'est une erreur, soit W3 doit noter explicitement "diminution reps pour augmenter charge" (ce n'est pas précisé). **Fix** : clarifier "W3 J1 : Bulgarian split squat 8 reps × 4 (vs 10 reps W2) car charge augmentée pour pic Bloc 1."

- **[W4-W8 absence de notation "matchs en semaine"]** Le safety_notes dit "En semaine de match, réduire les séances force à 1×/sem et les séances intermittent à une seule session légère." Or, le plan n'intègre **pas** de scénario de semaine de match — il suppose un calendrier "entraînement pur". Pour une app iOS grand public, ajouter des templates de "match week override" (W avec match officiel mercredi = adapter J2, J3, J5) améliorerait l'utilité en contexte saisonnier réel. **Minor** : optionnel si le produit est marketed comme "bloc précompétition de 12 semaines isolé" vs "intégré en saison."

- **[W1-W3 notation asymétrie test]** W2 J1 dit "Noter asymétrie si > 10% de charge entre jambes". Mais aucune action recommandée n'est explicite : continuer le plan, réduire côté faible, signaler au staff ? **Fix** : "Si asymétrie > 10% : augmenter le volume du côté faible de +2 reps et signaler au staff médical (risque accru de blessure selon ACSM)."

- **[W12 J5 "Sens des aiguilles d'une montre"]** Dans "Multi-directional sprint circuit", la note dit "sens des aiguilles d'une montre puis contre". La description n'est pas explicite : quelle est la géométrie exacte (carré 5×5m ? L ?) ? **Minor** : le coach peut inférer, mais clarifier "Carré 5m × 5m : départ angle 1 → sprint 5m angle 2 → pivot → sprint 5m angle 3 → pivot → sprint 5m angle 4 → retour angle 1 = ~20m total par direction."

## Manques notables

- **Absence de protocole échauffement standardisé spécifique au Bloc d'affûtage (W9-W12).** Les W1-W4 décrivent l'échauffement en détail ("activation fessiers monster walk, clamshells"). Les W9-W12 disent "12 min complet avec activation pliométrique" ou "10 min épaule complet" — vague. **Suggestion** : créer un protocole échauffement affûtage standardisé en annexe (10 min Z2 trot + FIFA 11+ ou activation spécifique, + 2 séries montées à 50-70% charge) et le référencer par semaine.

- **Absence de tableau de suivi "carnet d'entraînement numérique" suggéré.** Le plan recommande systématiquement de "noter charges, RPE, asymétries, douleurs articulaires" mais ne fournit pas de template ou structure de données à remplir (ex. : "Semaine 1 : Back squat W1J1 = 120 kg 4×6 RPE 7, asymétrie 0%, douleur genou 0/10"). Une app iOS idéale proposerait un formulaire post-séance pré-rempli. **Nice-to-have** : template carnet JSON ou lien vers app de suivi (Strava, TrainHeroic, etc.).

- **Absence d'intégration avec le calendrier de compétition officiel.** Le plan suppose un pic W12 "compétition régionale+" mais ne demande pas la date de la compétition cible. Idéalement, un paramètre "target_competition_date" permettrait une rétro-planification (si compétition = 15 janvier, calculer W1 automatiquement). **Nice-to-have** pour le bundle.

- **Absence de protocole nutrition/hydratation quantifié par séance.** Safety_notes cite "5-7 ml/kg/h d'exercice intense" et "1.6-2.0 g protéines/kg/jour" globalement, mais pas de guide par séance (ex. "W7 J2 circuit intermittent 70 min = 350-490 ml fluide estimé"). Pour un athlète élite opérant en contexte de charge d'équipe, cela aurait aidé. **Minor** : les chiffres IOC 2016 sont dans safety_notes, app peut les afficher per séance.

- **Absence de critère d'abandon ou de redirection du plan.** Qu'arrive-t-il si un athlète se blesse en W5 (déchirure ischio grade 1, repos 2 semaines médical) ? Safety_notes dit "1-2 semaines de pause : reprendre 2 semaines en arrière" mais ne précise pas si c'est recommandé de terminer le plan avec un déficit de capacité ou de basculer vers maintenance. **Suggestion** : matrice de décision "Si blessure X, protocole retour Y, timeline Z."

## Scores (sur 10)

- **Cohérence interne : 9/10**
  - duration_weeks (12) cohérent avec weeks.count (12 entités) ✓
  - Niveau "expert" = 5 séances/sem + blocs Bloc 1-4 périodisés : oui, ≥ débutant ✓
  - progression_logic explicite, toutes les séquences annoncées (4 blocs, 2 cutbacks, transitions) sont dans weeks ✓
  - Chiffres tenus : default_objective "pic W10-W12" = Bloc 4 en W9-W12 (minor décalage W10→peak mais acceptable)
  - **Pénalité** : W2 Bulgarian split squat progression incohérente (8→10→8), W12 vertical jump test non basé sur W1 baseline existant.

- **Alignement référentiel : 9/10**
  - Périodisation Bompa/Mujika (4 blocs, 2 cutbacks, affûtage progressif) ✓
  - NSCA patterns (squat, hinge, push, pull unilatéral) couverts W1 ✓
  - ACSM rest_seconds 150-180s composés ✓
  - FIFA 11+ Nordic curl excentrique prévention + proper cadence ✓
  - Buchheit 30-15 et Billat 3-3 / 1-1 intermittent ✓
  - Gabbett match-play simulation W7 ✓
  - Mujika affûtage W9-W12 volume -30 à -60% vs pic ✓
  - **Pénalité** : Z2 W4 J2 insuffisamment défini (65-75% FCmax non explicite), power clean introduction sans test préalable de maîtrise.

- **Sécurité : 9/10**
  - Drapeaux rouges exhaustifs par discipline (ischio-jambiers, genou, cheville, épaule, lombaire, commotion) ✓
  - Overtraining indicators (FC repos +8 bpm, motivation, douleur articulaire) ✓
  - Progression Nordic curl progressive (5→6→7 reps) = adaptation tendineuse prudente ✓
  - Proprioception cheville Bloc 1-4 systematique ✓
  - Thrower's 10 rotation épaule en Bloc 3-4 avant augmentation charge jeu ✓
  - **Pénalité** : asymétrie détection (W2 > 10%) sans action recommandée explicite, absence de profiling blessures antérieures à W1.

- **Pédagogie : 8/10**
  - Progression par paliers (W1 RPE 6-7 → W3 RPE 8-9 → W9 RPE 7-8 affûtage) ✓
  - Instructions claires avec RPE, cadence, amplitude (squat "profondeur parallèle", RDL "hinge 90°") ✓
  - Progression_logic explicite et narrative (explique le **pourquoi** de chaque bloc) ✓
  - Checklist d'autonomie W12 excellente (5 critères mesurables) ✓
  - **Pénalité** : Z2 "phrases fluides" pas défini en bpm, échauffement affûtage (W9-W12) vague, absence de template carnet suivi, vertical jump test W12 sans baseline W1.

- **Global : 8.75/10**
  - Template bien structuré, théoriquement robuste, sécurité exemplaire.
  - Prêt pour bundle avec corrections mineures sur clarifications Z2, test baseline W1, et actions post-detection asymétrie.