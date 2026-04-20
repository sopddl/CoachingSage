# Adaptability : velo-intermediaire-endurance-10sem + p3-travel-minimal-gear

## Rigidity score
**2/10**

## Patch approach

Ce template de cyclisme sur route est **fortement rigide** face à une contrainte de voyage sans équipement. Le plan repose intégralement sur des sorties longues à vélo (long ride Z2 = pilier hebdomadaire représentant 50-60% du volume total) et des séances d'intensité en extérieur ou home trainer. L'absence totale de vélo rend le template non-adaptable par patchage : il faudrait reconstruire entièrement la semaine autour d'activités alternatives (course à pied, bodyweight, corde à sauter) qui ne reproduisent **pas** les adaptations spécifiques au vélo (efficacité aérobie sur longue durée en Z2, cadence élevée, économie du coup de pédale). Une semaine complète de substitution = rupture du plan, non patch.

## Concrete modifications

**Impossible à patcher proprement — reconstruction requise.**

Les trois séances de la semaine dépendent chacune du vélo :

- **W<N> J1** (Sortie endurance Z2 long ride) : **[IRREMPLAÇABLE]** Cette séance de 40-80 km en zone 2 sur 1h30-3h développe spécifiquement l'adaptation mitochondriale et l'économie aérobie du cycliste. Aucun substitut avec bande élastique/corde à sauter ne peut reproduire la durée Z2 (pour des raisons physiologiques : la corde à sauter force une cadence très élevée 140-160 rpm et des impacts articulaires, incompatible avec Z2 prolongé ; la bande élastique offre une résistance isométrique sans composante cardiovasculaire continue).

- **W<N> J3** (Séances intensité Z3/Z4) : Intervalles à vélo pourraient théoriquement être remplacées par sprints corde à sauter + circuits bodyweight (burpees, mountain climbers, jump squats), **mais** les zones d'effort % FCmax ne correspondent pas : l'absence de pédalage régulier et le stress articulaire des sauts génèrent une réponse FC différente et plus explosive (VO2max courts vs endurance de seuil visée).

- **W<N> J5** (Récupération Z1-Z2 active) : Marche rapide ou jogging très léger possible, mais ne restaure **pas** les adaptations neuromusculaires spécifiques au pédalage (engagement du grand glutéal, stabilité lombaire en position aérienne).

## Rigidity issues

- **Dépendance monolithe au vélo** : Le template est construit sur 3 types de séances, **tous à vélo**. Aucune séance alternative (musculation, mobilité, travail de core) ne figure dans la structure du plan — tous les exercices sont prescrits **en sortie de route ou sur home trainer**. Cela contraste avec les normes de coaching (qui intègrent traditionnellement du renforcement longitudinal).

- **Absence de protocole "séance manquée"** : La section `safety_notes` couvre bien le cas "pause > 2 semaines", mais **pas** le cas "équipement indisponible". La règle "reprendre la même séance planifiée, décaler la semaine" suppose que la séance elle-même est faisable.

- **Progression irrévocable** : La règle (1) "PROGRESSION 10-15% LONG RIDE" est **mathématiquement incontournable**. Si W<N> J1 = 45 km et W<N+1> doit = 50-52 km pour respecter la progression, et qu'aucun km n'est parcouru cette semaine, la semaine suivante devrait partir d'une base de 0 km adaptée — ce qui casse le continuum de charge du plan et les cutback weeks W4, W8.

- **Cutback weeks non négociables** : `progression_logic` stipule explicitement : "Les deux cutback weeks (W4 et W8) sont **non négociables**" pour la supercompensation. Une semaine de voyage sans vélo **pendant** une cutback week (ex: W4 ou W8) peut être tolérée si rattrapage, mais **pendant** une semaine de charge (ex: W5, W6, W7) = perte irrémédiable du stimulus de progression.

- **Cadence codifiée** : La prescription "85-95 rpm sur plat" est **spécifique au vélo**. La corde à sauter force 140-160 rpm (fréquence de sauts), la course à pied 160-180 pas/min — des cadences incomparables. Le template ne sait pas absorber une métrique de cadence différente.

## Contradictions

- **Contradiction avec safety_notes — durée Z2 et impacts** : Le plan prescrit "Zone 2 : 65-75% FCmax. Tu peux parler librement en phrases complètes" pour 60-80 min. Une substitution corde à sauter de 60 min = **impossibilité physique** : la corde à sauter maintient une FC > 85% FCmax (VO2max) et génère un stress articulaire (cheville, genou, hanche) incompatible avec une récupération active Z1-Z2. Safety_notes mention "douleur genou" = flag rouge si > 3/10 — la corde à sauter prolongée **crée systématiquement** un risque de tendinite achilléenne et syndrome rotulien sur voyage sans préparation.

- **Contradiction avec progression_logic — continuité de charge** : Si W5 suppose une base Z2 de 65 km acquise en W1-W4, et que W-voyage = rupture complète (0 km), la semaine suivante (W6) est prescrite 72 km. Reprendre immédiatement à 72 km après une semaine d'arrêt **viole** la règle (1) "augmentation limitée à 10-15%" — c'est une saute de -30% puis +30% ou pire : rupture du continuum d'adaptation collagène/tendineux.

- **Contradiction avec volumes de zone** : `progression_logic` détaille "Volume long ride (km) : 45 → 52 → 60 → 52 (cutback W4) → 65 → 72 → 72 → 60 (cutback W8) → 78 → 80." Cette progression est **implicitement assimilée au volume horaire en Z2 (adaptations mitochondriales)**. Une semaine de corde à sauter peut générer un volume kcal/min équivalent, **mais** pas une charge tissulaire (collagène, tendon d'Achille, ménisque) comparable → le repos relatif prédispose à re-blessure à la reprise du vélo.

- **Contradiction avec assumed_profile** : "Cycliste régulier tenant 40 km à 25-28 km/h, pratique 1-2×/sem, vélo de route avec cardio-fréquencemètre conseillé." Une semaine sans vélo pendant un plan de 10 semaines = **perte d'auto-efficacité psychologique** : le cycliste intermédiaire qui casse la routine semaine en cours risque une démotivation (biais "je vais perdre mes gains") même si techniquement une semaine de pause n'est pas critique pour un plan de 10 sem.