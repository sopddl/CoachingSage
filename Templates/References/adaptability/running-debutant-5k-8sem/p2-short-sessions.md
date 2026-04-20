# Adaptability : running-debutant-5k-8sem + p2-short-sessions

## Rigidity score
**3/10**

## Patch approach
Le template est **rigide sur la structure temporelle globale** : chaque séance affiche 35-55 min de durée totale (échauffement + corps + retour au calme), et cette enveloppe est peu compressible sans compromettre l'échauffement obligatoire (8 min) ou les étirements (4-5 min), qui sont explicitement non-optionnels ("Ne jamais sauter cette étape", safety_notes). La compression viable se limite à : (i) réduire le corps de séance en volume/sets, (ii) fusionner certaines semaines en alternance court/long, (iii) supprimer une séance hebdo pour ne garder que 2 run + 1 renforcement alterné (ce qui casse la structure 3-séances/semaine). Les semaines W1-W5 sont les plus compressibles (blocs courts) ; W6-W8 deviennent incompressibles car le long run phare (20-30 min) + échauffement + retour = >30 min inévitablement.

## Concrete modifications

- **W1-W2 (toutes séances)** : Garder échauffement 8 min + cooldown 3-4 min = 11-12 min fixes. Réduire le bloc run/walk à **12-15 min maximum** (vs 20 min actuels) en gardant la même alternance 1min/1m30 ou 1m30/2min. Ex. W1 J1 : 6 séries de "1 min course + 1 min 30 marche" = 15 min au lieu de 20 min, total séance 26-27 min.
- **W1-W2 (renforcement J3)** : Supprimer "Cooldown 5 min" complet ; étirements réduits à 2-3 min maximum. Garder 5 exercices au lieu de 5 (actuellement tous inclus) en réduisant sets/reps : ex. W1 : wall sit 2×20 sec (vs 3×20), caf raises 2×15 (vs 3×15). Total renforcement ~25 min.
- **W3-W4** : Bloc laddered W3 compressible à **16 min** (1 cycle laddered au lieu de 2). W4 bloc 5 min : réduire les "blocs courts 3 min" de 2 à **1 seul** avant le bloc long, total course ~10 min au lieu de 15 min. Séance totale ~28 min.
- **W5 (cutback)** : **Séance idéale pour 30 min**. W5 J1 "Cutback blocs 5 min" déjà à 35 min → compresser à 2 séries "5 min course + 1 min 30 marche" = ~13 min bloc. W5 J3 renforcement : garder la structure (+ side plank nouvelle), réduire à 2 sets par exo. W5 J5 bloc 8 min : **scinder en 2 séances** (J5a : 5 min lundi soir OU samedi, J5b : 8 min mercredi) pour respecter 30 min/séance = NON faisable en 30 min avec échauffement/retour → voir contradiction ci-dessous.
- **W6 onwards (W6-W8)** : **INCOMPRESSIBLE.** Bloc 10 min (W6) + échauffement 8 min + cooldown 5 min = 23 min minimum, sans marge. Bloc 15-20 min (W7) = 28-33 min, dépasse 30 min. Bloc 30 min (W8) = **impossible** en 30 min total.

## Rigidity issues

- **Échauffement obligatoire non-négociable** : "Ne jamais sauter cette étape" (W1 J1 notes) → 8 min incompressible. Retrait signifierait augmenter x3 le risque de blessure (safety_notes).
- **Cutback week incompressible en structure** : W5 J5 "Premier bloc 8 min" (13 min course) + échauffement 8 min + marche récupération 3 min + étirements 5 min = **29-30 min min.**, aucune marge pour erreur.
- **W6-W8 dérivent du cap 30 min** : Le bloc 10 min (W6 J5) introduit un noyau incompressible de 10 min course qui absorbe déjà 1/3 du budget temps. Ajout obligation "allure lente" (safety_notes : test de la parole) allonge l'exécution vs intensité modérée.
- **Séances de renforcement conçues pour 35-37 min** : 5-6 exercices × 3 sets chacun, avec repos 30-45 sec entre sets, exigent ~22-24 min de travail + échauffement 7 min = 29-31 min. Réduction drastique sets/reps casse la progression prévue ("progression_logic : +10-20% hebdo").

## Contradictions

- **Safety_notes vs compression** : "Échauffement NON optionnel : sauter l'échauffement triple le risque de blessure chez le débutant" → on ne peut pas réduire les 8 min d'échauffement sans violer la sécurité explicite. Même chose pour "Courbatures 24-72h après séance = normal. Douleur PENDANT la séance = anormale" : réduire trop le volume risque inversement de maintenir inadaptation (W1 "Ne pas forcer l'augmentation" vs réduction extrême = stagnation).
- **Progression_logic vs scission des séances** : "Structure hebdo : 2 séances running + 1 renforcement, 4-5 jours de repos entre les sollicitations identiques." → Scinder W5 J5 (bloc 8 min) en 2 petites séances réduit les 4-5 jours de repos entre blocs cours, crée fatigue accumulée (violation du pattern de repos structurel).
- **W7-W8 cap non franchissable** : "Objectif : 30 min sans marcher, à TON allure" (W8 J5) + échauffement 5 min + cooldown 7 min + étirements 10 min = **52-55 min minimum**. Aucune marge de compression sans retirer étirements ou échauffement (à nouveau, contradictoire avec safety_notes).
- **Volumes hebdo incohérents post-compression** : Si W1 cours réduit de 20→15 min/séance × 2 = 30 min hebdo vs planifié ~16 min (vs 18 min W2), la progression relative devient chaotique et l'invariant "progression_logic : 16→18→18→22→23→28→35→50" ne tient plus.