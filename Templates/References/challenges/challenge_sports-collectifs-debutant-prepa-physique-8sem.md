# Challenge Report : sports-collectifs-debutant-prepa-physique-8sem

## Verdict
Template bundlable avec corrections mineures. La structure générale est solide, alignée sur les bonnes références (ACSM, Bompa), la progression respecte la règle des 10-15%, et le cutback W5 est justifié. Cependant, trois incohérences factuelles et deux manques pédagogiques doivent être corrigés avant bundle final : réduction de volume W5 insuffisante, absence de spécification du terrain pour agility ladder, et test d'évaluation en W8 trop qualitatif.

---

## Issues critiques (bloquantes pour bundle)

- **[W5]** Déclaration "volume cardio -15% vs W4" vs réalité : W4 = 7 sets de 20 m sprints (140 m totaux) + agility (4 sets) + T-drill (5 sets) + cross-over (4 sets). W5 = 5 sets de 20 m sprints (100 m) + réactivité (5 sets × 5 m = 25 m) + shuffle (3 sets). La réduction est ~40% sur les sprints longs mais la réactivité sur 5 m est incompatible avec une véritable "cutback" neuro-musculaire. **Fix** : supprimer les réactivités en W5 J1 et J5, ou réduire à 3-4 sets. Le cutback doit casser le volume global, pas le redistribuer.

- **[W6-W7]** Nordic curl : aucune mention des conditions de sécurité critiques en W6 J3 (notes). L'exercice demande explicitement "pieds bloqués sous un meuble lourd ou par un partenaire". Or 95% des utilisateurs solitaires n'auront ni meuble stable ni partenaire. **Fix** : ajouter en sécurité "Variante solo acceptable : nordic curl assisté par bande élastique (partenaire optionnel)" ou donner une option dégradée (contraction ischio-jambière isométrique en planche dorsale 20 sec/côté).

- **[W8 J5]** Checklist d'autoévaluation : critère n°3 ("ta vitesse de sprint en séquence 4 était-elle ≥ 70% de ta vitesse de séquence 1") est non mesurable sans chronomètre ou perception visuelle externe. Un débutant autonome ne peut pas évaluer un ratio de vitesse à 5% près. **Fix** : remplacer par critère qualitatif vérifiable : "Sur la 4e séquence, as-tu réussi à maintenir une accélération visible (et non un simple trot) sur au moins 3 sprints de 30 m ?" OUI/NON.

---

## Issues importantes (à corriger avant bundle idéal)

- **[W4 J1]** Agility ladder : "si tu n'as pas d'échelle d'agilité, trace 8 cases de 50 cm au sol avec de la craie". Surface non spécifiée. Une craie sur herbe mouillée = glissement dangereux. Le safety_notes parle des sols glissants, mais l'instruction J4 ne dit pas "sol sec et antidérapant obligatoire". **Fix** : ajouter "Uniquement sur sol sec et antidérapant (béton, tapis, parquet sec). Pas sur herbe, parquet humide, ou sol lisse."

- **[W7 J1 et W7 J5]** Séquence sport co A et B : "Répéter le cycle sans pause pendant 4/5 min" est ambigu. Faut-il :
  - (a) continuer le même pattern de 20 m trot → change direction → sprint en boucle pendant 4 min sans marche, ou
  - (b) exécuter la séquence une fois (durée = ?) puis s'arrêter ?
  
  Notes indiquent "Récup de 2 min marche entre les sets" mais set = 1 cycle ou plusieurs cycles ? **Fix** : clarifier avec exemple temporel : "Exemple : cycle 1 (0-4 min) → marche 2 min → cycle 2 (6-10 min) → marche 2 min → cycle 3 (12-16 min). Chaque cycle = 4 min continues de déplacement/sprint/changement de direction sans marche."

- **[W3 J3]** Pont fessier unilatéral : "Passage du pont bilatéral au pont unilatéral" (notes) indique que c'est une intro. Mais en W3 J3, le pont unilatéral demande 10 reps. Or aucun set bilatéral en W2 J3 pour servir de transition. La progression W2 ponte bilatéral (15 reps) → W3 unilatéral (10 reps) crée une ambiguïté : 10 reps par côté (20 totales) ou 10 totales ? **Fix** : clarifier "10 reps par jambe (20 totales)" et ajouter set 1 en W2 : "Pont fessier bilatéral à 12 reps, puis W3 passer au unilatéral à 10/jambe".

- **[W1-W8 global]** Progression des squats et fentes : aucune augmentation de tempo ou reps attendue entre W1 (10 reps squat) et W8 (pas de squat spécifié en W8 J3). W8 doit avoir un dégagement des jambes car c'est le tapering, mais l'exercice "squat sauté" en W8 J1 (2 sets à 6 reps) crée confusion. Les utilisateurs hésiteront : "dois-je faire mes squats normaux en W8 ?" **Fix** : en W8 J3, ajouter ligne explicite : "Pas de séance renforcement J3 en W8 (tapering complet). La séance J1 (activation légère) suffit. Rest et mobilité avant le test J5."

---

## Issues mineures (nice-to-have)

- **[W2-W4]** Rest_seconds nuls sur les shuffles et sprints (rest_seconds : 0) mais notes décrivent un pattern "effort + marche". Les rest_seconds devraient être 40 sec ou le timing "effort + récup" devrait être en duration, pas rest. Format JSON = confusion possible entre durée d'effort et repos. **Clarification** : ajouter note globale "rest_seconds = 0 car le repos est intégré dans la duration ('effort + repos'). Ne pas ajouter de repos supplémentaire."

- **[Progression_logic]** Point (1) RÈGLE DES 10-15% : cite "Distance des sprints progressent de 10 m (W2) à 20 m (W3-W4) puis 30 m (W6-W8)". Mais W2 J3 n'a pas de sprint 10 m — J1 et J5 oui. W4 J3 a "agility ladder" pas de sprints. La progression annoncée n'est pas strictement dans les "exercises" — elle est distribuée sur les days 1 et 5, pas day 3. **Clarification** : ajuster la formulation en "Distance des sprints W1-W2 : 10 m (J1 et J5 seulement). W3-W4 : 20 m. W6-W8 : 30 m" pour éviter la confusion.

- **[Safety_notes]** "Palpitations, douleur thoracique ou vertiges pendant l'effort : arrêt immédiat, position assise, consulter sans délai" est la seule mention des signes cardiaques aigus. Bon, mais absent des "SIGNES DE SURCHARGE (3+)". Un utilisateur pourrait croire que palpitations isolées (1 signe) ne méritent pas arrêt si les 3 autres signes manquent. **Amélioration** : spécifier "Les signes cardiaques (palpitations, douleur thoracique, vertiges) sont ARRÊT IMMÉDIAT indépendamment du nombre d'autres signes."

- **[W1 J3, W5 J3, W8 J3]** Cooldown : "Marche 2 min" sauf W5 J3 ("Prendre le temps de noter ses sensations"). W1 et W5 ne demandent pas de ressenti — W5 devrait explicitement demander un check de courbatures/douleurs pour détecter les surcharges. **Ajout** : en W5 J3 cooldown, ajouter "Vérifie les zones de courbatures (cuisses, mollets, épaules) et toute douleur articulaire. Cela aide à détecter précocement une surcharge." (déjà implicite mais pas explicite).

- **[W8 J5]** Après la simulation, "collation protéinée dans les 30 min" est recommandée (bonne pratique). Mais aucune mention de l'hydratation pendant les 20 min de la simulation. Même pour un débutant à intensité 7-8, 20 min de mouvement continu nécessite de la réhydratation. **Amélioration** : ajouter en warmup W8 J5 "Bouteille d'eau disponible. Boire 150-200 ml après chaque séquence (pendant la marche de 2 min)."

---

## Manques notables

- **Absence de métriques de suivi hebdomadaire** : aucun point de repère objectif chaque semaine (ex: "nombre de squats sautés sans perte d'équilibre", "temps de T-drill", "distance max sprint sans essoufflement excessif"). Les utilisateurs autonomes ont besoin de KPI pour valider la progression. **Suggestion** : ajouter en fin de chaque semaine une ligne "Métriques observables cette semaine" (ex: W2 = "peux-tu tenir 6 sprints 10 m sans essoufflement excessif ?").

- **Pas de plan B en cas de douleur légère persistante (3-5 jours, non-critique)** : safety_notes cite "arrêter et consulter si persistant > 5 jours" (exemple genou du coureur). Mais entre "continuer" et "arrêter tout", il y a une zone grise. Qu'en est-il si la douleur est tolérable mais présente en W4-W5 ? **Suggestion** : ajouter "Règle de la douleur progressive : si douleur ≤ RPE 2/10 en début de séance et disparat à l'effort, tu peux continuer. Si elle augmente au-delà de RPE 4/10 ou persiste 48h après, passe à la modification suggérée ou coupe cette séance."

- **Équipement alternatif pour nordic curl** : le template assume "partenaire ou meuble lourd". Aucune mention de bandes élastiques, TRX, ou autres solutions low-cost. Or la bande élastique est un équipement courant et plus sûr pour solo. **Suggestion** : en W6 J3 notes du nordic curl, ajouter "Variante solo avec bande : passer bande autour des pieds, se tenir des deux mains, même mouvement de chute contrôlée."

- **Absence de lien explicite entre la structure hebdomadaire et les contraintes physiologiques citées** : progression_logic parle de "adaptation tendineuse plus lente que adaptation cardiovasculaire" (justifiant le cutback W5). C'est vrai, mais aucun exercice renforcement-tendons n'est présent avant W3 (calf raises surélevés). Pourquoi attendre W3 pour la prévention tendineuse cheville si c'est "lent à adapter" ? **Clarification** : ajouter "Les calf raises dès W3 (pas W1) car la charge cardiaque W1-W2 est insuffisante pour créer une adaptation tendineuse positive. La tendance débute à partir du sprint 20 m en W3."

- **Pas de lien verso post-W8** : la checklist W8 dit "Si 4 OUI : prêt pour sport co loisir. Si < 4 OUI : prolonger 2 semaines en ciblant ce point." Mais aucun plan de 2 semaines n'est fourni. **Suggestion** : ajouter brief "Plan de 2 semaines bonus (optionnel) pour critère faible" selon le critère échoué (ex: si cardio échoue → augmenter durée des séquences de 4 à 5 min en W7 pattern).

---

## Scores (sur 10)

- **Cohérence interne : 8/10**
  - Bonnes progressions volumétriques W1→W7.
  - Cutback W5 bien justifié en logic, mais exécution insuffisante (réactivité ne doit pas remplacer sprints longs).
  - Chiffres globalement tenus (8 semaines = 3 séances/sem = 24 séances), 5 patterns de mouvement couverts (squat, fente, push, sprint, saut).
  - Malus : ambiguïtés duration vs rest_seconds, progression squat non explicite, W8 manque clarity.

- **Alignement référentiel : 8.5/10**
  - ACSM guidelines respectées (cutback, progression modérée, drapeaux rouges pertinents).
  - Bompa/Issurin périodisation appliquée (progression → pic W7 → tapering W8).
  - Exercices fondamentaux présents : squats, fentes, gainage, sprints, changements de direction, sauts.
  - Prévention sports co bien couverte : nordic curl W6 (ischio-jambier), calf raises W3+ (cheville), side plank W2+ (core), saut + réception squat W4+ (LCA).
  - Malus : agility ladder W4 sans variante solo robuste, aucune simulation match avant W7.

- **Sécurité : 7.5/10**
  - Safety_notes très complets (drapeaux rouges, intensités RPE, hydratation, surfaces).
  - Échauffement obligatoire systématique (bon).
  - Malus critiques : nordic curl W6 demande partenaire non garanti (3 options alternatives manquent), agility ladder W4 sur sol indéterminé, absence de douleur légère persistante (3-5 jours) = lacune zone grise.
  - Bonus : drapeau "entorse cheville sur changements de direction" pertinent et détaillé.

- **Pédagogie : 8/10**
  - Progression simple → complexe respectée (shuffle → back-pedal → cross-over → ladder).
  - Instructions claires avec détails techniques (posture dos, genoux dans l'axe, test parole).
  - RPE et tempo spécifiés (bon).
  - Malus : W8 checklist trop qualitative (critère vitesse relative non mesurable), pas de KPI hebdo, pas de plan B post-W8.
  - Bonus : warmup obligatoire justifié ("chevilles vulnérables"), progression progressive des intensités.

- **Global : 8/10**
  - **Bundlable en l'état**, mais les 3 issues critiques (W5 volume, W6 nordic curl, W8 test) doivent être patchées.
  - Solidité générale : structure Bompa, sécurité ACSM, progressions réalistes.
  - Manques : clarté W8, alternatives équipement, suivi objectif.