# Adaptability : sports-collectifs-debutant-prepa-physique-8sem + p5-low-energy-week

## Rigidity score
**7/10**

Le template offre une structure claire et itérative qui tolère bien les réductions de volume. La présence explicite d'une semaine cutback (W5) et les détails de progression_logic facilitent l'identification des variables malléables (sets, reps, vitesse, distance). Cependant, le template n'intègre pas de protocole formel pour un "tapering intra-plan" (baisse d'intensité mid-cycle en cas de fatigue/stress), ce qui oblige à improviser en consultant les progressions et les safety_notes plutôt que d'avoir une directive intégrée.

## Patch approach

La stratégie consiste à traiter la semaine fatigue comme une **semi-cutback partielle** alignée sur le principe de W5 (réduction ~20% du volume cardio-intermittent et renforcement), mais en préservant la **qualité des appuis et la sécurité** (pas de sacrifice sur l'échauffement ou les fondamentaux). On réduit sets, reps et vitesse de sprint selon la semaine actuelle, on maintient la fréquence (3 séances) pour éviter de casser le pattern J1/J3/J5, et on ajoute une note explicite sur la récupération/sommeil. Rattrapage : la semaine suivante reprend la progression prévue sans décaler, car une semaine allégée n'invalide pas les adaptations précédentes.

## Concrete modifications

- **W<N> J1 (Cardio-intermittent)** : réduire les **sets de sprints de -25%** (arrondir à la baisse). Exemple : W2 J1 a 6 sets 10 m → passer à 4-5 sets. W4 J1 a 7 sets 20 m → passer à 5 sets. W6 J1 a 6 sets 30 m → passer à 4-5 sets. **Réduire la vitesse cible de 85-90% à 70-75%** pour chaque sprint. **Supprimer ou réduire à 2 un des exercices accessoires** (shuffle latéral ou T-drill selon la semaine) pour économiser le temps total et mental. Exemple W3 J1 : garder sprints 20 m + sauts cloche-pied, supprimer "Changements de direction en T". **Garder l'échauffement complet** (8 min), non négociable.

- **W<N> J3 (Renforcement)** : réduire **reps de -2 à -3 par exercice** (ex. squat 15 reps → 12 reps) et **sets de -1** si N ≥ 4 (ex. W4 squat avec charge 3 sets → 2 sets). **Supprimer un exercice non-fondamental** selon la semaine : ex. W6 J3 supprimer superman (conserve squat sauté + fentes + nordic curl + planche + side plank + pompes) pour économiser 10 min. **Garder les exercices de prévention blessure** (nordic curl W6+, calf raises surélevés, side plank) intacts en volume réduit.

- **W<N> J5 (Cardio-coordination finale)** : réduire **sets de sprint ou réactivité de -20%**. Exemple W6 J5 : garder sprints 30 m 6 sets, réduire réactivité signal de 8 sets à 6 sets. **Réduire vitesse à 70-75%** (au lieu de 85%). **Raccourcir les séquences continues si W7-W8** : W7 J5 passer de 3 séquences 5 min à 2 séquences 5 min (ou 3 séquences 4 min), W8 J5 maintenir 4 séquences 5 min intégrales (c'est le test, ne pas réduire).

- **Récupération inter-séances** : **ajouter 1 jour de repos optionnel** (ex. J2 ou J4) si la semaine fatigue coincide avec W5-W8 (semaines à haute charge). Exemple : au lieu de J1-J3-J5, faire J1-J3-J6 (avancer le J5 d'un jour). Cela augmente le repos de 48h à 72h avant la prochaine séance sans décaler le plan global.

- **Rattrapage W<N+1>** : **reprendre le plan nominal de W<N+1>** sans "rattraper" le volume manqué de W<N>. L'adaptation neuromusculaire ne se compense pas en resurchargement la semaine suivante — c'est contreproductif. W<N+1> est l'occasion de consolider les acquis sous une charge normale.

## Rigidity issues

- **Absence de protocole formel "low-energy week"** : le template décrit W5 (cutback planifié) mais n'offre pas de directive générique pour adapter n'importe quelle semaine N à une fatigue externe. L'utilisateur doit manuellement identifier quels sets/reps/vitesses réduire en se fiant aux progressions — risque de subjectivité.

- **Safety notes ne couvrent pas les seuils de fatigue systémique** : la section "Signes de surcharge" énumère 4 drapeaux (FC repos +10, courbatures, baisse perf, sommeil perturbé) mais ne dit pas quand réduire précisément (réduire de combien ?). Une basse d'énergie due au travail/stress n'est pas un "signe de surcharge" classique, donc pas couvert formellement.

- **Structure W7-W8 moins flexible** : si la semaine fatigue tombe en W7 J5 (séquences 4 min) ou W8 (test phare), réduire les séquences risque de casser la logique de "simulation progressive" — on perd la donnée du test. Le template ne propose pas d'alternative pour ces semaines critiques.

- **Cutback W5 déjà existant** : si la semaine fatigue est W5 elle-même, elle est déjà un cutback ~20%. Le patch risque de doubler le cutback (W5 coupable + réduction fatigue = baisse ~35%), ce qui devient du repos quasi-complet — à limiter.

## Contradictions

- **Progression_logic vs réduction ad-hoc** : le template énonce "RÈGLE DES 10-15%" (augmentation progressive) et énumère des distances de sprint cibles (10 → 20 → 30 m) par semaine. Si on réduit J1 de -25% sets en W3, on rompt le pattern de 6 sets W2 → 6 sets W3 annoncé. Cependant, cette contradiction est **acceptable** : réduire le **nombre de sets**, pas la **distance**, respecte la progression distance tout en baissant charge totale. ✓ Cohérent.

- **Safety_notes "jamais de surcharge" vs baisse de sommeil** : safety_notes dit "sommeil perturbé > 3 nuits = signe de surcharge → cutback". Si la fatigue utilisateur est due au travail (sommeil mauvais > 3 nuits), un cutback est formellement recommandé. Donc pas de contradiction, juste une application stricte des safety_notes. ✓ Cohérent.

- **Réactivité signal W5-W6** : progression_logic dit "réactivité sur signal intro W5 à 3-4 sets, augmente à 8 sets W6". Si on réduit W6 (fatigue) à 6 sets, on reste entre W5 et W6 nominal. Logique et sûr. ✓ Cohérent.

- **Nordic curl W6+ comme prévention obligatoire** : progression_logic stipule "ces exercices ne sont pas optionnels". Si on supprime nordic curl en W6 J3 pour économiser du temps (fatigue), on viole cette directive. **SOLUTION** : garder nordic curl en volume réduit (ex. 5 reps 3 sets → 4 reps 2 sets) plutôt que le supprimer. Cela s'applique aussi au saut réception squat W4+. ⚠️ **À clarifie dans le patch** : les exercices de prévention blessure ne se suppriment pas, seulement se réduisent.

- **W8 J3 = mobilité only** : W8 J3 n'a déjà pas de renforcement (mobilité + récup active), donc la réduction proposée ne s'applique pas. ✓ Aucun conflit.

---

**Note finale sur adaptation W5 (cutback) vs fatigue utilisateur** :
Si la semaine fatigue **coïncide avec W5**, ajouter explicitement : "W5 est déjà un cutback de -20%. Ne pas dédoubler. Garder le plan W5 nominal (5 sets 20 m, 3-4 sets réactivité, volumes réduits renforcement). Ajouter simplement +1 jour de repos J2 ou J4 pour gérer la fatigue externe. Reprendre W6 nominal la semaine suivante."