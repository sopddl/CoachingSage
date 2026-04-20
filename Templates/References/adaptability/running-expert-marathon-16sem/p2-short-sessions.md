# Adaptability : running-expert-marathon-16sem + p2-short-sessions

## Rigidity score
**3/10**

## Patch approach
Le template est **fortement rigide** sur la structure temporelle. Les séances de longue durée (long runs 18-35 km, tempos 30-40 min, intervalles multiples) sont **intrinsèquement incompressibles** sans perdre leur effet physiologique. La contrainte 30 min max crée une contradiction directe avec la progression_logic (points 1, 4, 5) et l'objectif default_objective (terminer un marathon en stable). Une adaptation "intelligente" exigerait une reconstruction quasi-totale du plan, pas un simple patch.

## Concrete modifications

**Impossibilité structurelle identifiée :**
- **Long runs (W1-W11)** : 18-35 km en 30 min = impossible (vitesse moyenne 36-70 km/h). Ces séances sont le cœur du plan (progression_logic point 4). Pas de "compression intelligente" possible.
- **Tempos W5+ (25-40 min continu)** : 25 min de tempo seul dépasse déjà 30 min avec échauffement/retour. W10 (40 min tempo) est incompressible.
- **Intervalles multiples (5-6x1000m, 6x1200m)** : 6 répétitions de 1000m = 6 min de course + 15 min de récup = 21 min minimum, soit 36 min avec échauffement.

**Adaptations possibles UNIQUEMENT sur les séances courtes :**
- **W1-W4 Runs faciles (40-45 min)** → **Compresser à 25-28 min** : réduire durée facile à 20 min + 4 strides (OK, < 30 min total).
- **W1-W4 Renforcement (40 min)** → **Compresser à 28-30 min** : réduire à 2-3 séries par exercice (vs 3-4), supprimer clamshells/side planks optionnels. Maintenir Nordic curl + calf raises (priorité safety_notes). Cela réduit le volume préventif de 40%.
- **W5-W15 Tempos jusqu'à 25 min** → **Fractionner en 2 blocs courts** : ex W5 (30 min continu) → 2x12 min allure seuil + 3 min récup. Temps total ≤ 28 min (échauffement court 10 min + 2x12 + 3 min récup + 5 min cool). **Perte : cohésion aérobie d'une séance longue d'un bloc**.
- **W10-W11 Tempos 40 min** → **IMPOSSIBLE à compresser** en respectant la durée d'effort seuil requise. Doit être **supprimé ou déplacé** (voir ci-dessous).

**Scission des long runs (incompressible directement) :**
- **W1-W4 Long runs (18-24 km)** → **Scinder en 2 séances sur 2 jours** : ex W2 (21 km) = J3 (12 km aérobie) + J5 (10 km aérobie) en semaine suivante, mais cela décale le pattern hebdomadaire (progression_logic point 2 : "1 jour de repos entre séances"). Violation de la règle 48h minimum.
- **Ou supprimer** la portion marathon (AM) et réduire à un run aérobie unique : W2 (21 km) → W2 (12 km aérobie) + W3 (12 km aérobie). Perte : simulation spécificité marathon (progression_logic point 4).

## Rigidity issues

- **Incompressibilité physiologique des long runs** : Un long run de 32 km (W11) est une adaptation centrale du plan Pfitzinger Advanced. Le décaler ou le scinder sur plusieurs jours rompt la cohésion métabolique (glycogène, mitochondries) et la spécificité neuromusculaire ("courir vite sur des jambes fatiguées"). Il n'existe pas d'équivalent physiologique en durée < 20 km.

- **Tempos W10-W11 (40 min continu)** : Le progression_logic point 2 stipule "INTENSITÉ maintenue pendant l'affûtage". Un tempo fractionné en 2x15 min au lieu de 40 min continu crée une dérive d'allure entre les blocs et réduit le stimulus seuil (Billat et al., 1999 : seules les durées > 20 min continus à seuil produisent des adaptations lactiques optimales).

- **Renforcement obligatoire** : Nordic curls et calf raises excentriques sont notés dans safety_notes comme "prévention tendinite ischio-jambière proximale" et "prévention tendinopathie d'Achille" sur charge cumulative marathon. Les réduire < 15 min/sem = risque blessure augmenté (études cités Achilles). Une séance force réduite à 20-25 min force à supprimer 40% des exercices (dead bug, planche 60 sec, etc.).

- **Strides maintien neuromusculaire** : En affûtage (W13-W16), les strides sont explicitement "jamais absentes" (progression_logic point 2). Les supprimer = fibres rapides non-stimulées jour J. Les garder + run facile + échauffement = difficilement < 30 min.

- **Interval volume incompressible** : 6x1000m (W6, W10) = 40+ min minimum. Réduction à 3x1000m (15 min effort) maintient stimulus VO2max mais réduit le volume d'entraînement à haute intensité de 50% — détectable en W6-W7 si comparaison à W5 (5x1000m).

## Contradictions

- **Contradiction principale : progression_logic vs contrainte 30 min.**
  - **Point 1** (cutback W4/W8/W12 : réduction 15-20% en volume structurel) : impossible si chaque semaine limite < 30 min/séance. Les week-ends (long runs) deviendraient plus court que les semaines = inversion de la logique.
  - **Point 4** (long run progressif, portion AM croissante : 4 km W2 → 20 km W10) : inatteignable si long runs scindés en 2x12 km max. La "portion AM croissante" s'étire sur 2 jours = perte de spécificité (fatigue neuromusculaire locale aux km 15-25 du long run est critique pour adaptations).
  - **Point 2** (intensité maintenue affûtage) : un tempo de 25-40 min continu réduit à 2x12 min crée un "reset" métabolique aux 3 min de récup = perte de régularité FC seuil (85-90% FCmax driftée à 75-80% en début bloc 2).

- **Contradiction safety_notes vs réduction force** :
  - Nordic curls W1-W11 : progression 5-6 reps → 8 reps sur 4 séries. Réduire à 2 séries en 20-min session = 50% réduction volume. Safety_notes note "risque n°1 tendinite ischio chez expert" — risque augmenté si volume réduit.
  - Calf raises excentriques : progression 12 → 18 reps. Compresser séance force réduit volume calf, mais safety_notes note "prévention tendinopathie d'Achille sous charge cumulative > 700 km" (plan monte à 75 km/sem W11, soit cumul ~900 km W1-W11). Absence de stimulation excentrique augmente risque.

- **Contradiction sessional spacing** :
  - Safety_notes : "1 jour de repos ou mobilité entre séances running". Si long runs scindés en 2 jours (W2 J3 + J5), pattern = J1 run facile / J2 force / J3 run 12 km / J4 repos / J5 run 12 km / J6 repos / J7 (reste vide). Jour J6 devient repos involontaire → 8 jours sans stimulus long run = décalage W2→W3 incohérent.
  - Tempos et VO2max "jamais < 48h d'écart" (progression_logic point 3) : si chaque séance est 28-30 min max, il est tentant de rapprocher les jours pour compresser la semaine = violation directe.

- **Attrition de la qualité cumulée** :
  - **W6** : "Tempo 2x16 min (format fractionné) + VO2max 5x1000m + Long run 24 km" = 3 stimuli qualité hauts la même semaine. En format 30 min, c'est impossible :
    - Tempo 2x16 min = 28 min min (avec échauffement court 8 min + cool 4 min) → juste possible.
    - VO2max 5x1000m = 40 min → impossible.
    - Long run 24 km → impossible.
  - Choix forcé : supprimer 1 stimulus chaque semaine. Progression_logic point 3 dit "TOUTES LES SEMAINES SANS EXCEPTION" pour tempo ET VO2max. Impossible d'honorer.

- **Niveau "expert" supposé** : Template assume "volume habituel ≥ 40 km/sem" et "entraînement marathon 16 semaines". Réduire à 5x 30 min/sem = ~35-40 km/sem max (incompressible running) = perte de 20-30% volume vs expected. Profil p2 n'est **pas compatible** avec "expert".