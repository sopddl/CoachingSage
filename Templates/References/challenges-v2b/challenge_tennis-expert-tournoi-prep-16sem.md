# Challenge Report : tennis-expert-tournoi-prep-16sem

## Verdict
Programme très bien conçu et rigoureux, aligné sur les standards NSCA/ACSM pour la préparation tennis haute niveau. Bundlable en l'état avec corrections mineures : quelques incohérences de chiffres (rest_seconds), clarifications sur la supervision des exercices à risque, et uniformisation des formats d'instruction. La progression_logic est exceptionnellement documentée et défend chaque choix — c'est un atout majeur.

## Issues critiques (bloquantes pour bundle)
Aucune issue critique détectée. Le template ne contient aucun risque de blessure majeur, aucune incohérence fondamentale et respecte les protocoles de sécurité.

## Issues importantes (à corriger avant bundle idéal)

- **[W7 J1]** Power clean en kettlebell swing : la note indique "Power clean uniquement si supervisé", mais en contexte d'app iOS grand public sans coaching présent, la mention du power clean ne doit pas créer d'ambiguïté. Recommendation : **supprimer complètement le power clean de cette séance ; garder *uniquement* kettlebell swing lourd (24-32 kg) comme option par défaut, avec lien verso vers tutoriel vidéo supervisé ou avertissement clair "Nécessite coaching en personne".**

- **[W5-W8, W13-W15]** Rest_seconds sur complexes PAP : la note en progression_logic dit "210 sec (3 min 30) ... Ne pas réduire ce repos", mais aucun exercice dans les weeks W5-W8 ne spécifie explicitement 210 sec pour les complexes PAP. **W5 J1 : "Back squat + box jump (complexe PAP)" doit afficher `"rest_seconds": 210` explicitement dans la structure JSON.** Même pour W6 J1 RDL + sprint. **W7 J1 squat + box jump doit aussi afficher 210.** Vérifier que tous les complexes PAP W5-W8 affichent 210 sec, pas 150-180 sec.

- **[W9-W11]** Protocole "si blessure en W9-W11" : la safety_notes mentionne "Ne pas forcer pour terminer la simulation" et "arrêter immédiatement", mais les sessions W9-W11 ne contiennent pas d'instruction explicite "Stop criteria". **Ajouter une ligne pré-match dans chaque session W9-W11 J3 et J5 : "Si douleur articulaire ≥ 4/10 ou sensation d'instabilité (cheville, genou, épaule), arrêter immédiatement et consulter un médecin du sport. Ne pas forcer pour terminer la simulation."**

- **[W16 J4]** Checklist d'autonomie : les critères de notation sont très bons, mais le score de "< 35/50" n'est pas accompagné de seuil GO/NOGO clair pour la compétition. **Ajouter : "Si score total < 25/50, reporter le tournoi et faire 2-3 semaines de renforcement des zones faibles avant la compétition suivante."**

## Issues importantes (suite)

- **[Zones FC]** La safety_notes cite "FCmax = 220 - âge" comme estimation par défaut, mais aucun exercice d'évaluation de FCmax réelle n'est proposé en W1. **W1 J3 "Test navettes" note correctement "noter également la FC maximale atteinte", mais les instructions ne disent pas *quoi faire si le joueur n'a pas de cardiofréquencemètre*. Ajouter : "Si pas de capteur cardiaque, utiliser l'échelle de Borg (RPE 1-10) : Zone 2 = RPE 3-4 (peut parler en phrases), Zone 4 = RPE 8-9 (parler difficile)."**

- **[W1-W3]** Exercices sans charge de référence précise : "Dumbbell bench press" et "Dumbbell row" en W1 J1 ne spécifient pas la charge initiale. **Ajouter note : "Choisir une charge permettant RPE 7 sur 10 reps. Si incertitude, commencer 2-3 kg en-dessous et augmenter si facile."** (Récurrent W2, W3.)

## Issues mineures (nice-to-have)

- **[W11 J3]** Format "Match 1 / Pause 20 min / Match 2" : les instructions disent "pause 20 min", mais l'exercice "Pause nutrition et récupération inter-match" compte pour une durée d'entraînement. Le total de la session W11 J3 est annoncé 120 min (70 + 20 + 50 = 140 min effectifs vs 120 noté). **Clarifier si les 120 min incluent les pauses de récupération ou seulement le jeu ; corriger la cohérence.**

- **[W3 J1]** "Box jump ou saut vertical — initiation" note "box 30-40 cm maximum" mais le pliométrie unilatérale ne figure pas jusqu'à W5-W8. **Clarifier : en W3, les box jumps sont bilatéraux ? Les bonds latéraux unilatéraux apparaissent-ils vraiment en W5 J1 ou plus tard ?** Progression claire bilatéral → unilatéral utile.

- **[W10 J4]** "Visualisation match de tournoi" note "5 min de visualisation post-séance (scénario pressure point 30-40)", mais W8 J7 introduit déjà 15 min de visualisation. **Unifier : soit 5 min (court, portatif), soit 15 min (approfondi). Choisir une durée standart et l'appliquer W9-W16.**

- **[W16 J1-J4]** Les protocoles "applicables chaque jour de match" et "inter-rounds" sont excellents, mais pas indexés (J1 = pré-match, J3 = post-match, J5 = match décisif). **Clarifier que W16 n'est pas à exécuter jour par jour linéairement, mais que chaque session est un *scénario adaptable* selon le tableau du tournoi.**

## Manques notables

- **Nutrition inter-matchs détaillée** : la safety_notes parle de "glucides rapides (banane, gel, fruits secs)" et "1 L/heure avec électrolytes", mais aucun exercice W9-W11 (matchs simulés) ne contient d'instruction de timing ou quantité spécifique. **Ajouter une checklist en W9 J3 ou W9 J5 : "Entre 2 matchs le même jour : hydratation 500 ml dans les 10 min post-match, alimentation légère (banane + barre protéinée) 15 min après, puis repos 30 min avant ré-activation."**

- **Équipement requis exact** : le profile cite "chronomètre, ceinture cardiaque optionnelle, vidéo smartphone", mais aucune liste de matériel nécessaire n'est fournie en en-tête. **Ajouter avant les weeks : "Équipement obligatoire : 1 raquette cordée, court tennis, haltères/kettlebell 8-32 kg, élastiques de résistance légère-lourde, cible coach ou partenaire régulier niveau 15-second série. Optionnel : ceinture cardiaque, caméra smartphone, chronomètre (téléphone suffisant)."**

- **Progression des charges dumbbell accessoires** : la progression_logic cite "double progression sur les accessoires : +1 rep/semaine jusqu'au top de la fourchette → +charge la semaine suivante", mais aucune session ne détaille explicitement ces paliers (ex : W1 J1 dumbbell bench 3×10 → W2 J1 3×10+1kg → ...). **Recommandation : ajouter une note en W2 J1 : "Si W1 était facile (RPE ≤ 6), ajouter 1-2 kg vs W1 ; sinon, garder la charge et ajouter 1 rep (vers 11 reps). Progression : +1 rep/semaine jusqu'à 15 reps, puis +charge +1 kg et retour à 10 reps."**

- **Diagnostic technique initial absent** : W1 J5 "Technique sur court — diagnostic" manque de structure d'observation. **Ajouter fiche post-W1 J5 : "Observations clés : 1) Service : prise ? Vitesse estimée ? Points faibles (double faute, 1re balle < 50%) ? 2) Revers : une main ou deux mains ? Aisance ? 3) Approche filet : fréquence par match ? Réussite ? 4) Gestion des points importants (break, 30-40) : confiance ou stress visible ? Imprimer cette fiche et la remplir W1 J5 pour comparer à W12 et W16."**

- **Gestion des blessures mineures en Bloc 2-3** : la safety_notes dit "si douleur 3-4/10 : consulter, retirer les mouvements problématiques", mais aucune semaine n'est explicitement marquée pour les checks articulaires réguliers. **Recommandation : ajouter un mini-bilan articulaire en J7 de chaque semaine W5-W12 (30 sec rotator cuff + ankle rotation + test split-step douleur).**

## Scores (sur 10)

- Cohérence interne : **9/10**
  - Blocs bien délimités, progression_logic exhaustive et défendue.
  - Minor : rest_seconds sur complexes PAP W5-W8 pas tous explicites en JSON (doivent tous afficher 210).
  - W11 J3 durée total incohérence (120 min annoncé vs 140 min réels).

- Alignement référentiel : **9/10**
  - NSCA Tennis Conditioning, ACSM resistance training, USTA, FFT bien appliqués.
  - Periodisation ondulée 4×4 semaines + cutback W4, W8 conforme Bompa/Issurin.
  - RSA progression (Bloc 1-2 ratio 1:2→1:4, Bloc 4 ratio 1:9→1:11) basée sur recherche (Stolen et al.).
  - Minor : power clean en W7 non recommandé en app sans coaching (à supprimer).

- Sécurité : **8/10**
  - Drapeaux rouges très détaillés et contextualisés (swimmer's shoulder, épicondylite, entorse, ischio claquage).
  - Protocoles maladie/absence bien décrits en safety_notes.
  - Minor : instruction "stop criteria" pas dans chaque session W9-W11 (mais en safety_notes).
  - Zones FC bien expliquées (FCmax 220-âge), alternative RPE fournie.

- Pédagogie : **8/10**
  - Chaque exercice annoté avec RPE et objectif clair.
  - Progression logique et paliers visibles (W1-W4 fondations → W5-W8 puissance → W9-W12 transfert → W13-W16 taper).
  - Checklist d'autonomie excellente en W16 J4.
  - Minor : nutrition inter-matchs W9-W11 pas détaillée (timing, quantité).
  - Minor : diagnositc technique initial W1 J5 pas structuré (fiche à remplir).

- **Global : 8.5/10**
  - Programme exceptionnellement pensé et défendu. Rare pour un template de 16 semaines de cette envergure.
  - Corrections requises sont minimes et ne remettent pas en cause la structure.
  - Prêt pour bundle avec les 3 fixes critiques ci-dessus.