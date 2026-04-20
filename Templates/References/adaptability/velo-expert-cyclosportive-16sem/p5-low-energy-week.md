# Adaptability : velo-expert-cyclosportive-16sem + p5-low-energy-week

## Rigidity score
**7/10**

Le template propose des cutback weeks (W4, W9, W13) structurés, ce qui offre un précédent pour réduire le volume sans déstructurer le plan. Cependant, la logique de progression W-à-W est tight : chaque semaine construit sur la précédente. Une insertion ad-hoc de "récupération surprise" au milieu d'un bloc intensif (ex. W6 ou W11) crée des frictions avec la progression_logic déclarée.

## Patch approach

Injecter une semaine "low-energy recovery" en conservant la structure minimale : réduire le volume de 30-40% vs la semaine prévue, remplacer tout travail Z4-Z5 par Z2-Z3 doux, maintenir 1-2 touches très courtes de qualité pour éviter la rupture d'adaptation, puis décaler la semaine suivante de 1 semaine (reporter la progression de +1W) ou accélérer la récupération post-low-energy en W+1 avec cutback léger implicite.

## Concrete modifications

Exemple d'application sur **W6** (semaine prévue : développement seuil longs 310 km / 12h30) :

- **W6 J1** (Seuil développé 130 min) → **Z2 pur 90 min** : remplacer les 2x20 min Z4 par 80 min Z2 continu, cadence libre. Pas d'intervalles. Cooldown inchangé.
- **W6 J2** (Récupération Z1 60 min) → inchangé (déjà Z1 pur).
- **W6 J3** (Seuil longs + VO2max combiné 120 min) → **Technique basse cadence allégée 90 min** : remplacer les 2x20 min Z4 + 5x4 min Z5 par 5x5 min Z3-Z4 force basse cadence (50-60 rpm) avec repos 6 min Z1, cadence très volontairement ralentie (≈ 60-70 % du stimulus seuil habituel). Maintient la neuro, zéro accumulation lactique.
- **W6 J5** (Endurance Z2 + force basse cadence 120 min) → **Z2 pur 100 min** : enlever les 5x5 min force. Z2 strict 85 min + 10 min Z1 final.
- **W6 J7** (Sortie longue 300 min, 150-170 km) → **Sortie longue réduite 200 min, 80-100 km** : garder Z2 dominant et Z3 sur cols, mais pas d'effort "pacing race" ni "segment tempo". Réduire le dénivelé cible de 50% (1200-1800 m D+ au lieu de 2500-3200 m D+).

**Volume W6 réduit** : ≈ 60-70 km / 5h30 (vs 310 km / 12h30 prévu). Réduction = **-50%** nécessaire pour récupération réelle en contexte de stress/sommeil dégradé.

- **W7 (semaine suivante)** : débuter W7 à 85% du volume prévu (vs 100% normal). Exemple : W7 J1 3x10 min Z4 au lieu de 5x4 min Z5 ( = stimulus plus aérobie, moins explosif). Ramener progressivement vers la cible de W8 sur les 3-4 séances suivantes.

## Rigidity issues

- **Cutback weeks fixes (W4, W9, W13)** : Le template ancre les récupérations à des semaines pré-définies, ce qui suppose une charge de travail "nominale" en amont. Une fatigue surprise en W6 ou W11 force un écart au calendrier. Solution : traiter la low-energy comme un cutback *opportuniste* qui repousse le bloc suivant de +1W, sans casser la logique des 3 cutback obligatoires (ils restent W5, W10, W14 dans la timeline réelle).

- **Progression_logic verrouille la cohérence bloc-à-bloc** (Bloc 2 W5-W9 doit accumuler seuil/VO2max précisément) : insérer une low-energy en W7 interrompt la courbe VO2max (W5 intro 8x2 min → W6 5x4 min → W7 *low-energy* = rupture → W8 doit-elle être W7 ou W8 nominal ?). Le template ne décrit pas explicitement comment gérer une semaine "hors-séquence".

- **Safety_notes — signes de surcharge** (FC repos +10 bpm, puissance RPE déconnectée, sommeil perturbé) : mentionnent d'ajouter 1-2 jours de repos et réduire volume 20%. La low-energy week ici réduit de 50% — c'est une intervention plus agressive, mais justifiée si les 3+ signes sont présents.

## Contradictions

- **Pas de contradiction flagrante Z-par-Z** : réduire Z4-Z5 en Z2-Z3 ne viole aucune règle de safety (règle 48h entre séances identiques = respectée ; si pas de Z4 intensif, pas besoin de 48h après).

- **Contradiction implicite avec progression_logic point (1) — blocs progressifs** : la progression_logic affirme "Bloc 2 (W5-W9) développement seuil et VO2max — intervalles Z4 et Z5 croissants". Une low-energy en W7 ou W8 réduit les Z4-Z5 accumulés à cette étape, risquant de laisser un "gap" dans le stimulus adaptatif seuil/VO2max pour le reste du bloc (W9 cutback est censé consolidé W5-W8, or W7-8 réduites = consolidation sur base plus mince).

  **Mitigation** : reporter W9 test FTP à W10 (test après 1W récup) pour laisser 1 semaine de surcompensation avant évaluation. OU maintenir W9 test FTP nominal mais réduire les cibles de zones de 5-10% (si FTP-W9 < FTP attendu, justifié par la semaine fatigue) → pas d'alarme, juste adaptation.

- **Nutrition et hydratation en low-energy** : safety_notes n'adresse pas spécifiquement comment adapter ravitaillement si volume chute de 50%. Solution implicite : portions réduites proportionnellement (ex. si sortie longue passe de 300 min à 200 min, réduire glucides de 70-90 g/h à 60 g/h pour éviter surcharge digestive à bas débit).

- **Volume W-à-W dépasse +10% règle si on "rattrape" en W7** : progression_logic affirme "Augmentation hebdomadaire du volume ≤ 10-15% maximum". Si W6 = 60 km et W7 = 150 km (reprise normal), c'est **+150% > +15% interdit**. Solution : W7 = 80-85% du nominal (progressif) au lieu de 100% d'emblée.