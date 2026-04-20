# Challenge Report : natation-expert-perfectionnement-12sem

## Verdict
Template de très bonne qualité globale, bundlable en l'état avec application de 3 patchs mineurs. Structure périodisée rigoureuse, références expertises solides (Swim Smooth, ACSM, clubs compétitifs), sécurité correctement adressée. Les 3 issues identifiées sont cosmétiques et ne bloquent pas le déploiement.

## Issues critiques (bloquantes pour bundle)
Aucune issue critique détectée.

## Issues importantes (à corriger avant bundle idéal)

- **[W3 J2 — Breath control 7 temps]** Instruction ambiguë : "ne jamais enchaîner 2 longueurs en 7 temps sans pause" vs "Breath control 7 temps (avec partenaire)" implique qu'1 seule longueur est possible avant repos obligatoire. Clarifier : "1 longueur 7 temps max, puis repos 40 sec minimum avant répétition suivante" → **fix** : remplacer "Alterner : 1 longueur en 5 temps, 1 longueur en 7 temps" par "4 longueurs en cycle (2× longueur 5 temps, 2× longueur 7 temps avec 40 sec repos entre chaque)". Cohérence avec sécurité absolue affirmée en safety_notes.

- **[W6 J4 — Post-TT 1500 m]** Note indique "recalibrer les allures seuil W7-W8 (800 m × 3)" mais W7 J3 contient uniquement 3 séries 800 m — pas mentionné en W8. W8 est un cutback sans séries 800 m. **Fix** : clarifier que le recalibrage post-W6 TT s'applique aux allures Z3-Z4 de W7, et que le cutback W8 maintient les mêmes allures réduites en volume. Ajouter en W8 J4 une note : "Allures seuil W7 maintenues (= post-TT 1500 m W6) mais volume réduit".

- **[W10 J1 — Comparaison W9 vs W10 300 m]** Note cible "idéalement -2 à -3 sec/300 m par rapport à W9". Or, W9 J1 première exposition = pas de temps de référence préexistant pour critiquer. **Fix** : reformuler "Comparer au temps mesuré W9 J1 : objectif ≥ même allure ou mieux, grâce à la fraîcheur post-cutback W8. Gain attendu : -2 à -3 sec/300 m si récupération optimale".

## Issues mineures (nice-to-have)

- **[Progression_logic, section (4) COHÉRENCE SEUIL/VITESSE]** Phrase "Avant W6, les allures seuil sont estimées sur la base du meilleur 400 m compétition récent +8-10 sec/100 m". Implémentation W1-W5 ne vérifie pas explicitement la possession de ce temps compétition antérieur. Risk : nageur arrive sans baseline 400 m compétition récent. **Sugg** : ajouter en W1 J4 une note "Si meilleur 400 m compétition récent inconnu : réaliser 1 essai 400 m maximal en W1 J4 récup post-série pour établir la baseline d'allure seuil".

- **[W7 J2 — Culbute dos post-papillon]** Note affirme "le virage papillon→dos de l'IM utilise la culbute" mais ajoute "Règle clé : pour papillon seul (course papillon), le virage est mur 2 mains simultanées". Cette distinction IM vs papillon solo est correcte (FINA) mais peut confondre un nageur non familier avec le 200 m IM. **Sugg** : simplifier pour un contexte nageur "expert" : "Papillon seul en compétition = 2 mains au mur. Papillon en IM = culbute autorisée après virage. Ici, drill IM : culbute correcte".

- **[W11-W12 — Rest_seconds anomalies]** W11 J1 "cooldown" inclut "bien dormir (8h minimum)" qui est une instruction hors-piscine, placée dans cooldown d'une séance aquatique. **Sugg** : déplacer en safety_notes global ("Sommeil : 8h minimum les semaines de charge W10-W11") ou en W11 "goal" plutôt qu'en cooldown technique.

## Manques notables

- **Absence de check-in médical pré-plan** : La sécurité cite "Swimmer's shoulder, tendinite biceps" comme drapeaux majeurs chez "nageur expert en charge élevée". Aucune instruction de "screening pré-W1" n'est présente (ex: test douleur d'épaule de Neer, O'Brien). **Sugg** : ajouter en W1 goal "AVANT W1 J1 : effectuer un screening rapide épaule (bras en elevation 90°, test rotation externe / interne contre résistance légère). Si douleur > 2/10 sur l'une de ces 3 actions = avis médecin avant de débuter. Nageurs avec antécédent shoulder impingement doivent pratiquer 5 min de renforcement scapulaire PRÉ-séance dès W1 (non W5 comme écrit), notamment sur les séances VO2max (W5+)".

- **Absence d'équipement calibrage chrono ou appli FC** : Progression_logic cible FCmax et zones FC avec exemples numériques, mais aucune instruction de "vérifier son matériel avant W1" (chronomètre, montre de natation avec FC, appli cadence). **Sugg** : ajouter en assumed_profile ou W1 warmup "Avant W1 J1 : calibrer FCmax (220 - âge ou test progressif). Noter les seuils des 5 zones sur le chrono ou appli pour consultation rapide en piscine".

- **Manque de protocole dégradation progressive si surcharge** : Safety_notes cite 6 signes de surcharge et dit "réduire de -30% dès que 3 signes présents". Aucune instruction claire "semaine suivante : reprendre le plan normal ou rester sur la semaine réduite ?" **Sugg** : clarifier "Si surcharge détectée mi-semaine : réduire immédiatement le volume reste de la semaine de -30%, puis reevaluate en fin de semaine. Si 3+ signes persistent en fin de semaine : reprendre la semaine réduite (identique à cutback W4/W8) avant de progresser".

- **Absence critères « femme » ou variations hormonales** : Nageur expert de 12 sem haute intensité — démographie probable inclut femmes. Cycle menstruel impact sur Fe, fatigue, capacité lactique. **Sugg** : ajouter en safety_notes "Pour les nageuses : variations de rendement énergétique et de tolérance à la fatigue de ±8-12% selon phase du cycle (phase lutéale = capacité VO2max légèrement réduite). Si performance inattendue dégradée plusieurs séances consécutives, corréler au cycle et ajuster intensité légèrement (-5% allure) sans alarme — normal, transitoire".

## Scores (sur 10)

- Cohérence interne : 9/10
  *(Volumes déclarés vs contenus séances : très cohérent. Progression_logic clairement livrée dans weeks. Minor : clarifications nécessaires sur TT 1500 m recalibrage W7-W8 et W10 référence W9).*

- Alignement référentiel : 9/10
  *(Périodisation Swim Smooth / Maglischo conforme. Zones FC, tempos, repos PCr corrects. Drills technique et progressif alignés sur Swim Smooth « Technical progressions ». Minor : absence screening pré-plan et protocole FC calibrage initial).*

- Sécurité : 8/10
  *(Drapeaux rouges exhaustifs : shoulder impingement, otite, crampe, hypoxie breath control. Règle partenaire obligatoire Z5-breath control clairement affirmée. Protocole surcharge détecté. Minor : screening médical pré-plan manquant, variations hormonales non adressées, renforcement scapulaire préventif recommandé dès W1 pas W5).*

- Pédagogie : 9/10
  *(Progression par palier claire. Instructions exercices détaillées avec notes RPE/FC/respiration. Baseline mesures comparatives (W2 → W6 → W10 → W12) excellentes. Checklist autoévaluation W12 robuste. Minor : clarification breath control cycles longueur, placement sommeil/nutrition hors cooldown technique).*

- **Global : 8.5/10**