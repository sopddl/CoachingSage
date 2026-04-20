# Adaptability : remise-en-forme-intermediaire-maintien-8sem + p5-low-energy-week

## Rigidity score
**7/10**

Le template offre une structure explicite de cutback week (W5) qui fournit un précédent direct pour adapter une semaine basse énergie. Cependant, l'adaptation exige de patcher plusieurs semaines non-cutback selon le moment du plan où survient la fatigue, et certains éléments (progression_logic rule #3 : 10-15% max increase/week) risquent de créer une rupture de cohérence si appliqués naïvement.

## Patch approach

Créer une **"semaine fatigue adaptée"** en répliquant le modèle W5 (cutback -15% volume/intensité, RPE 6 max, fréquence 4 séances maintenue). Si la semaine fatigue tombe avant W5, décaler le cutback officiel vers la semaine suivante. Si elle tombe après W5 (W6-W7), appliquer le cutback modifié à la semaine en cours, puis recommencer la progression normale la semaine suivante en respectant la règle de 10-15% (comparer à la version non-fatigue, pas à la cutback modifiée).

## Concrete modifications

- **Semaine fatigue (quel que soit Wn)** : Appliquer immédiatement le template exact de W5 (volume -15%, RPE cible 6, sets/reps réduits, durées cardio réduites).
  - **Séance Cardio** : réduire de 5 min vs la semaine précédente (ex : si W3 prévoyait 30 min intervalles, passer à 25 min; si W7 prévoyait 38 min, passer à 30 min).
  - **Séances Renfo bas/haut** : retour à 3 sets au lieu de 4, reps : -2 à -3 par rapport à la semaine précédente, charge identique (NSCA : allèger le volume avant la charge).
  - **Séance Mobilité** : allonger à 45 min (comme W5) pour maximiser la récupération parasympathique vs le renfo.

- **W5 officiel si fatigue avant W5** : décaler W5 d'une semaine. Recommencer progression normale la semaine suivante en comparant à la semaine fatigue, pas à W4 (ex : si fatigue semaine 3 → fatigue W3 appliquée → W4 normal (progression vs W2) → W5 cutback normal → W6 relance).

- **Semaine suivant la fatigue** : reprendre la progression du plan original SAUF si la fatigue était W6 ou W7. Appliquer la règle 10-15% : volume = volume(semaine-fatigue-adaptée) + 12% max, pas volume(semaine-prévue-originale).

## Rigidity issues

- **Progression_logic rule #3 (10-15% max)** : si on applique naïvement la progression normale après une semaine fatigue, on peut dépasser 15% vs la semaine fatigue (ex : W3 → fatigue → W4 original = saut de 20% possiblement). Fix : comparer toujours la progression à la semaine immédiatement précédente (semaine fatigue), pas au plan original.

- **Cutback week immobile** : W5 est labellisé "obligatoire" et "à mi-plan". Si fatigue tombe en W5, on remplace le cutback standard par une version "fatigue + cutback" (volume encore réduit). Pas de choix structurel — on ne peut pas supprimer W5 sans risque décrit en progression_logic rule #4 (surcharge W6-W8).

- **Circuits mixtes W6 et W8** : si fatigue tombe W6 ou W8, les circuits 3-4 tours deviennent problématiques (enchaînement sans pause = intensité intrinsèque élevée). Solution : réduire à 2 tours maxi en semaine fatigue, risque d'atrophie du bénéfice métabolique du circuit. Le template n'offre pas d'alternative structurelle simple (le circuit est "la" séance mixte du plan).

## Contradictions

- **Safety_notes vs semaine fatigue tardive (W6-W7)** : la rule "Signes de surcharge (3+ simultanés → semaine cutback immédiate)" s'applique, mais le plan prévoit déjà W5 cutback et W6-W7 pic charge. Si fatigue (symptômes surcharge) détectée en W6, appliquer la semaine fatigue immédiatement → **casse la cohérence de W6 pic de charge et W7 pic de charge**. Le template ne prévoit pas deux cutbacks ou une réduction tardive. Risque : perte du pic de progression W7 initialement prévu.

- **Règle "48h minimum entre séances même groupe musculaire"** (safety_notes) : la structure 4 séances/sem (J1 cardio, J3 bas, J5 haut, J7 mobilité) respecte cette règle. En semaine fatigue, maintenir la fréquence 4 séances ne crée pas de violation, mais la qualité d'exécution peut se dégrader → augmente le risque de technique compromise (mentionné en safety_notes : "risque de blessure double sans échauffement intermédiaire"). Pas de contradiction explicite, mais tension sur la sécurité.

- **Hydratation et alimentation pré-séance** (safety_notes) : si fatigue = sommeil dégradé + stress élevé, l'alimentation peri-entraînement (collation 1-2h avant) peut être impactée. Le template n'adapte pas les recommandations nutrition pour une semaine basse énergie (p.ex., renforcer la protéine/glucides peri-entraînement pour compenser la fatigue CNS). Pas une contradiction directe, mais un point aveugle.