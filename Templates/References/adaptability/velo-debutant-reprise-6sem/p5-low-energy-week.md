# Adaptability : velo-debutant-reprise-6sem + p5-low-energy-week

## Rigidity score
**7/10**

Le template offre une flexibilité modérée face à une semaine fatigue. La structure hebdomadaire (2 séances espacées 48h) se laisse réduire, mais la **progression_logic** énumère des volumes précis (W1: 85 min, W2: 105 min, etc.) qui créent une attente figée. Le cutback W4 existe déjà comme soupape, ce qui aide. En revanche, les **blocs Z3 en W5** et la **séance phare W6** sont architecturalement rigides — modifier l'une d'elles impacte l'invariant "progression vers 1h30".

## Patch approach

Adapter une semaine fatigue consiste à : (1) réduire le volume de la séance longue hebdo de 20-25%, (2) maintenir la séance courte sous forme d'activation ultra-légère Z1 ou la sauter, (3) préserver le renforcement musculaire mais allégé (réduire les séries ou les durées de tenue), (4) reprogrammer les séances manquées ou allégées en fin de plan (W6 ou semaine 7 de suivi) pour rattraper le déficit sans compression. Cette approche évite une stagnation tout en respectant l'esprit du cutback W4.

## Concrete modifications

- **W<N> J2** (séance courte, quel que soit N sauf W4 cutback) : **Remplacer par "Sortie activation Z1 ultra-légère"** — 30 min vélo libre Z1 (~50-60% FCmax), cadence 80-85 rpm, terrain plat. Aucun travail d'intervalle ou Z3. Supprimer complètement le renforcement musculaire de cette séance (planche, pont, bird-dog) pour économiser l'énergie neuromusculaire.

- **W<N> J5** (séance longue) : **Réduire la durée cible de -20%** (ex: W2 passe de 60 min continu à 50 min, W3 de 75 min à 60 min, W5 de 80 min à 65 min). Conserver la zone Z2, maintenir cadence 85-90 rpm. Garder le renforcement musculaire mais **allégé** : planche -5 sec (ex: W3 passe de 30 sec à 25 sec), pont fessier -3 reps, bird-dog -2 reps, side plank conservé mais 2 séries au lieu de 3. Calf raises : 12 reps au lieu de 15.

- **Si W5 avec blocs Z3 tempo** : **Remplacer les 3 × (8 min Z3 + 5 min Z2) par 2 × (5 min Z3 + 7 min Z2)** — réduit le volume Z3 de 24 min actif à 10 min actif. Justification : préserver l'habituation à Z3 sans épuisement nerveux.

- **W6 séance phare (1h30 cible)** : **Reprogrammer à W7 ou semaine suivante si applicable**. Sinon, si W6 doit rester en programme : réduire à 70-80 min cible, pas 90 min, évaluer avec la checklist d'autonomie sur cette durée réduite. Revalider 1h30 en W7 si énergie rétablie.

- **Renforcement musculaire (toutes séances longues fatigue)** : **Réduire de 40% les volumes** — 2 séries au lieu de 3 pour planche/pont/bird-dog/side-plank, -3 reps pour calf raises. Durées : -5 sec pour tenues isométriques (planche 30 sec → 25 sec en semaine fatigue).

## Rigidity issues

- **Progression_logic énonce des volumes hebdo figés** (W1: 85 min, W2: 105 min, W3: 130 min, W4 cutback: 100 min, W5: 130 min, W6: 140 min) — ces chiffres sont présentés comme des repères ACSM non-négociables. Un coach strict interpréterait une réduction de 20% comme une rupture de la "règle des 10-20%". Le template **ne documente pas d'exemples de flexibilité intra-semaine** — il faudrait inventer un protocole d'ajustement absent du texte original.

- **Cutback W4 existe mais est unique et planifié** — on ne peut pas ajouter un deuxième cutback sans décaler tout le reste. Si la fatigue survient en W2, W3 ou W5, il n'y a pas de "cutback de remplacement" intégré au template.

- **Blocs Z3 en W5 et séance phare 1h30 en W6** sont présentés comme des jalons architecturaux clés pour "préparer le système cardiovasculaire à tenir 1h30". Réduire W5 risque d'affaiblir la préparation à W6 — le template ne propose pas d'alternative progressive (ex: "si W5 allégée, faire 2 blocs Z3 de 6 min au lieu de 3 blocs de 8 min").

- **Renforcement musculaire est décrit comme "obligatoire" et "progressif" sur 5 semaines** (planche 20 → 25 → 30 → 30 → 35 sec). Le template **ne dit pas quoi faire si on rate une séance ou allège le renforcement** — l'invariant "progression planche" devient cassé. Relancer la progression après une semaine allégée exige de réinterpréter la timeline, ce que le template ne couvre pas.

## Contradictions

- **Safety_notes : "SIGNES DE SURCHARGE (3+ signes simultanés → semaine allégée conseillée)"** — le template RECONNAÎT que des semaines allégées peuvent être nécessaires (fatigue jambes, FC repos +8-10 bpm, courbatures > 72h, motivation chutée, sommeil dégradé). Cependant, il **ne fournit pas de protocole détaillé d'allègement** — il dit "semaine allégée conseillée" mais ne précise pas par combien de % réduire, comment restructurer les séances, ni comment rattraper après. Cette contradiction crée une **ambiguïté adaptative** : on sait que réduire est recommandé, mais le template ne l'outille pas clairement.

- **Progression_logic (règle des 10-20%) vs adaptation low-energy** : la règle énonce "Aucun delta ne dépasse 25% entre deux semaines de charge pleine". Une réduction de 20% suivi d'une reprise à 100% crée un delta de ~25% à la limite. Si on fait cela deux fois (semaine 2 allégée, semaine 3 normale, semaine 4 allégée, semaine 5 normale), on accumule des micro-chocs que le template ne prévoit pas.

- **Renforcement musculaire progressif vs allègement** : progression_logic énonce "Progression planche : 20 → 25 → 30 → 30 → 35 sec sur 5 semaines, Bird-dog introduit en W3, Side plank en W4". Si on allège une semaine (ex: W3 planche 25 sec au lieu de 30 sec), la semaine suivante doit-elle faire 30 sec (reprendre la progression) ou 35 sec (continuer la progression) ? Le template **ne documente pas ce dilemme**, créant une ambiguïté exécutive.

- **Nutrition et hydratation vs fatigue mentale** : safety_notes n'aborde pas la gestion nutritionnelle en cas de semaine stress/fatigue (ex: "si sommeil dégradé, augmenter les glucides post-effort" ou "réduire les portions si digestion difficile"). Une semaine fatigue RH souvent s'accompagne de mauvaise récupération métabolique — le template ne le croise pas.