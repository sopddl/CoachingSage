# Challenge Report : natation-avance-technique-8sem

## Verdict
Template de très haute qualité, **bundlable en l'état sans modifications critiques**. Structure pédagogique exemplaire alignée sur les standards Swim England et USMS, progression rigoureuse et sécurité bien couverte. Trois mineures optimisations pourraient renforcer la clarté d'exécution autonome, mais aucune n'est bloquante.

## Issues critiques (bloquantes pour bundle)
Aucune issue critique détectée.

## Issues importantes (à corriger avant bundle idéal)

**[W1 J3]** Drill "6-3-6 crawl" : respiration en phase côté décrite comme "bulle basse, œil juste à la surface" — cette instruction contradictoire peut induire une tête qui se lève (cherchant l'œil à la surface) au lieu de rester immergée. → **Fix proposé** : remplacer par "Expiration continue sous l'eau pendant la phase côté (bulle). À la phase de transition (3 coups), une rotation légère de la tête suffit — bouche juste au-dessus de l'eau. L'oreille reste semi-immergée."

**[W4]** Drill "sous-marins dolphin kick (10 m)" : instruction "Corps gainé, ondulation depuis les hanches (pas les genoux)" risque d'être mal interprétée par un autonome non-formé (confusion dolphin kick ≠ battement flutter normal). Aucun contexte de progression vers ce drill qui demande une coordination non-triviale. → **Fix proposé** : ajouter en W3 J5 ou W4 J1 une séance préparatoire aux sous-marins : "Drill : 6×15 m streamline + dolphin kick (léger, ondulation légère hanche/bassin uniquement, chevilles relâchées). Cible : habituer le système nerveux à l'ondulation minimale."

**[W5 J1, notes]** Drill "brasse — traction en cœur" : "coudes hauts" + "insweep" sont contradictoires si l'autonome comprend "coudes hauts = écartement latéral large". La brasse demande une traction en forme de cœur (outsweep puis insweep rapide sous le sternum avec coudes rentrés, pas écartés). → **Fix proposé** : reformuler "Bras partent tendus devant. Phase 1 (outsweep) : mains s'écartent vers l'extérieur à largeur d'épaule (coudes restent rentrés, proches du corps, angles à ~90°). Phase 2 (insweep) : mains convergent rapidement sous le sternum en poussant vers l'arrière. Coudes jamais sortent au-delà de la ligne d'épaule."

## Issues mineures (nice-to-have)

- **[Progression logic, principe 3]** : "drills organisés en 4 familles séquencées" — la séquence annoncée est (1) équilibre, (2) catch/EVF, (3) timing, (4) propulsion. Cependant W7 introduit "drills rappel" post-fatigue sans que ce principe 4 (propulsion maximale sous pression) soit explicitement appliqué dans les séances avant W6-W7. La cohérence narrative est bonne, mais l'axe 4 pourrait être plus visible en W6 J3 avec une série étiquetée "Propulsion maximale — pull-push integration" plutôt que "Crawl intervalles seuil".

- **[W2 J5, series pyramidale]** : Repos 30 sec indiqué mais le format 50+100+150+100+50 m avec 30 sec entre chaque segment est très serré pour un autonome qui doit sortir/relever la tête entre chaque sprint. Instruction acceptable mais aurait mérité un commentaire : "30 sec = temps juste pour reprendre souffle au bord sans sortir du bassin. Si nécessaire, augmenter à 40 sec pour préserver la qualité technique sur le 150 m central."

- **[W6 J1, drill EVF post-fatigue]** : "4×25 m fingertip drag après la série intense" — le drill est pertinent (ancrage post-fatigue) mais l'ajout de 100 m supplémentaires (4 × 25 m) après 1000 m de crawl seuil crée un volume total de 1400+ m crawl sur cette séance. Cohérent avec l'objectif, mais aurait mérité un petit "⚠️ Note : total séance ≈ 2500-2600 m dont 1400 m crawl. Si fatigue persistante du pull > 72h après cette séance, réduire à 2×25 m fingertip au prochain cycle similaire."

- **[W8 J5, checklist autonomie]** : Critère 2 "EVF sous pression — je maintiens un coude haut... y compris dans les 3 dernières longueurs" est subjectif (comment un autonome mesure-t-il précisément un coude qui reste à 90°?). Conversion suggestion : "Critère 2 : lors du test 400 m, mon nombre de coups de bras ne dépasse pas +2 unités sur les 3 dernières longueurs comparées aux 2 premières (signe de fatigue technique minimale)."

## Manques notables

- **Nutrition/hydratation peri-séance** : safety_notes mentionne l'hydratation pré-séance (300-500 ml) mais aucune consigne post-séance. Pour un nageur avancé sur 60-75 min en piscine chaude (transpi masquée), l'hydratation post-séance est critique pour la récupération. → Suggestion : ajouter aux cooldown de toutes les séances "Boire 300-400 ml d'eau ou boisson légère (sucre + minéraux si séance > 60 min) dans l'heure suivante."

- **Indicateurs de fatigue cumulative/overtraining** : safety_notes cite 4 signes de surcharge. Aurait mérité un mini-tableau ou un jour d'observation recommandé (ex : "Tous les 2 jours, évaluer 3 métriques : FC repos (relevée au réveil), RPE général (1-10), sensation pump bras (1-10)"). Format idéal pour une app iOS : tracker optionnel en fin de séance.

- **Équipement palmes : clarification d'usage** : profil assumé mentionne "palmes courtes (optionnelles)" mais aucune séance ne prescrit explicitement leur utilisation. W1 J3 recommande "100 m avec palmes si disponibles" mais c'est la seule mention. Manque de cohérence : soit intégrer des drills palmes réguliers (toutes les 2 sem par ex.), soit supprimer du profil. → Suggestion : ajouter "W2 J1 : remplacer le drill 'kick on back' par 4×25 m kick back avec palmes (si disponibles) pour renforcer la proprioception chevilles-hanches sans épuiser les jambes."

- **Absence d'adaptation pour profil "nageur crawl fort mais brasse/dos faible"** : le plan suppose une transition facile brasse/dos à partir de W5 cutback. Or un profil crawl confirmé a souvent une brasse inefficace ou un dos asymétrique (habitude crawl). Aucune note de "priorité brasse/dos en W5-W6 si constat de déséquilibre en W1 J5". Aurait été prudent : ajouter à safety_notes "Si lors du bilan W1, le dos asymétrique ou brasse laborieuse, inverser la proportion W5-W7 (80% brasse 20% crawl en W5) pour corriger avant IM."

## Scores (sur 10)

- Cohérence interne : **9.5/10**
  - duration_weeks (8) ✓ = weeks.count (8). Progression volumétrique respecte les 10-15% : W1→W2 (+12%), W4→W5 (-15%), W5→W6 (+18%), W6→W7 (+4%), W7→W8 (-40% tapering). Cutback W5 ✓. Drills annoncés vs appliqués : match complet (streamline, EVF, timing, propulsion). Safety notes vs exercices : alignement fort (repos 30-60 sec respecte ACSM repos composés). Seules les 4 issues "importantes" ci-dessus introduisent des légères incohérences narratives ou instructionnelles mineures.

- Alignement référentiel : **9/10**
  - Volume hebdo (2000-2800 m) ✓ cohérent plans Swim England Adult Level 3-4. Séquence drills (équilibre → catch → timing → propulsion) ✓ conforme pédagogie Swim Smooth. Cutback W5 ✓ standard ACSM plans > 6 sem. Progression 3 nages ✓ respecte non-interférence motrice. Comptage coups de bras ✓ métrique robuste DPS. Seule légère faiblesse : absence de prescrition HC/FC spécifiques (la natation manque souvent de zones d'effort calibrées), mais "Z1-Z5" est une approche RPE-based acceptable et transparente pour autonome sans cardio-fréquencemètre en piscine.

- Sécurité : **9.5/10**
  - Drapeaux rouges (swimmer's shoulder, knee medial, crampes, panique resp., otite) ✓ couverts avec prévention et escalade. Règles générales (lunettes, hydratation, nunca solo, mobilité, 48h repos) ✓ complètes. Intensité adaptée profil (avancé, pas de Z5 avant W6) ✓. Équipement matching profil (pull-buoy, planche, palmes optionnelles) ✓. Seule amélioration : aucune mention "ne pas nager seul en sprint" explicite sur les séries Z4-Z5 (W6 J3, W7 J1, W8 J5 réclament maître-nageur vigilant).

- Pédagogie : **8.5/10**
  - Progression paliers ✓ évident (W1-W2 fondamentaux, W3-W4 consolidation, W5 cutback, W6-W7 application IM, W8 test). Clarté instructions : **très bonne** sur 80% des exercices (descriptifs détaillés, répétitions claires, objectifs explicites). Les 4 issues "importantes" révèlent des instructions ambiguës sur 3 drills techniques clés (6-3-6 respiration, dolphin kick, brasse traction). Checklist autonomie W8 ✓ excellent (5 critères d'autoévaluation). RPE / cadence / allure : Z1-Z5 ✓, coups de bras ✓, cycles ✓, mais aucun repère "cadence de bras idéale" (ex : "50 m crawl = 40-50 cycles/min", "brasse = 30-40 cycles/min") qui aiderait un autonome à se calibrer en temps réel sans compteur numérique.

- **Global : 9/10**
  - Template de référence haute qualité, exception faite de 4 clarifications instructionnelles et 3 petites lacunes pédagogiques (nutrition post-séance, overtraining tracking, équipement palmes cohérence). Aucun risque sécuritaire réel, aucun décalage physiologique. Bundlable tel quel; les améliorations suggérées sont du finissage (1-2h de révision pour un expert natation).