# Adaptability : remise-en-forme-debutant-reprise-6sem + p4-more-ambitious-goal

## Rigidity score
**3/10**

## Patch approach
Le template est fondamentalement rigide face à une escalade d'objectif : la progression_logic entière est construite sur l'axiome **"10-20% de progression max par semaine"** et la **cutback W4 obligatoire**, précisément parce que le profil cible est un sédentaire prolongé. Rehausser l'objectif final (ex : 45 min de marche au lieu de 30 min, ou ajouter un objectif coureur/cardio avancé) crée des contradictions insurmontables avec les safety_notes et les fondements physiologiques du plan. Une escalade modérée (30 → 35 min) est possible ; une escalade ambitieuse (30 → 45+ min, ou passage au running) exige une reconstruction du plan.

## Concrete modifications

**Scénario testable : escalade MODÉRÉE (30 min → 35 min de marche, sans changement de sport)**

- **W2 J1 marche** : passer de 20 min à 22 min (au lieu de 20 min)
- **W3 J1 marche** : passer de 25 min à 27 min (au lieu de 25 min)
- **W4 J1-J5 marche** : maintenir à 27 min (cutback appliqué au palier supérieur, pas de retour à 25 min)
- **W5 J1, J5 marche** : passer de 28 min à 30 min (au lieu de 28 min)
- **W6 J5 marche phare** : passer de 30 min à 35 min (au lieu de 30 min)
- **Tous les renforcements (squat, pompes, bird-dog, calf)** : +3 reps supplémentaires par semaine vs template (ex : W1 squat 13 reps au lieu de 10 ; W6 squat 18 reps au lieu de 15)
- **Planche durée** : W1 = 20 sec au lieu de 15 sec ; progression linéaire +5 sec/semaine jusqu'à W6 = 40 sec au lieu de 25 sec

---

**Scénario AMBITIEUX (30 min marche → 45 min marche OU introduction courte marche/trot) : IMPOSSIBLE dans le cadre du template**

- Atteindre 45 min de marche continue en 6 semaines depuis 15 min demanderait une progression moyenne de **+5 min/semaine**, soit +200% en volume sur le plan. C'est **3x la règle des 10-20%** et contredit explicitement la `progression_logic`.
- Ajouter une composante running (ex : 20 min marche + 10 min trot alterné) à partir de W4 dépasserait le ratio 40/40/20 cardio/renforcement/mobilité et surchargerait un sédentaire prolongé : risque d'impact repetitif sans adaptation progressive des tendons et articulations.

## Rigidity issues

- **Règle des 10-20% est structurelle** : elle fonde la justification physiologique ("le système musculo-squelettique d'un sédentaire prolongé présente une faiblesse globale qui nécessite une adaptation progressive"). Escalader au-delà viole ce principe fondateur et rend le plan indéfendable scientifiquement (c'est explicitement cité dans `progression_logic` avec la source ACSM).

- **Cutback W4 est obligatoire et non contournable** : la `progression_logic` stipule "CUTBACK WEEK OBLIGATOIRE (W4)" — c'est un invariant du plan. Si on accélère la progression, on ne peut pas sauter W4 (le risque de surcharge monte exponentiellement), donc on est coincé à une cutback qui "consomme" une semaine entière du plan.

- **Volumes chiffrés implicites dans safety_notes** : les "signes de surcharge" (courbatures > 72h, sommeil dégradé, FC de repos +10 bpm, irritabilité) sont calibrés pour une progression 10-20%. Une escalade exigerait des seuils de tolérance différents — mais le template ne les fournit pas.

- **Profil cible rigide** : "Adulte sédentaire depuis plusieurs mois, aucun sport récent, pas de pathologie majeure" — ce profil exclut par construction l'escalade ambitieuse. Rehausser l'objectif exige implicitement de changer de profil (ex : "ancien coureur revenant à la forme") — ce qui n'est pas le cas du template.

- **Planche latérale / bird-dog introductions figées** : W2 pour bird-dog, W3 pour planche latérale. Accélérer partout déphaserait les apprentissages — ces exercices demandent une maîtrise de l'équilibre et du gainage qui ne se fait pas en J1 si on augmente aussi la cardio en simultané.

## Contradictions

- **Escalade modérée (30→35 min) vs safety_notes "courbatures > 72h"** : à 35 min en W6 après 6 semaines depuis 15 min, le volume total sera +133%, très proche de la limite. Les courbatures pourraient persister > 72h chez un sédentaire. Le template dit "reprendre en W3 ou W4 selon comment tu te sens à la première séance de retour" si pause > 2 semaines — implicite : anticiper une dégradation de récupération. Pas de contradiction formelle, mais marge réduite.

- **Escalade ambitieuse (30→45 min) vs progression_logic "RÈGLE DES 10-20%"** : contradiction directe. 45 min depuis 15 min = +200%, incompatible avec "le volume total n'augmente pas de plus de 20% d'une semaine à l'autre" et "la progression est volontairement plus lente que les plans sportifs spécialisés". **Le template refuse cette escalade par construction.**

- **Introduction running/trot vs assumed_profile "aucun équipement requis"** : ajouter une composante courante exige des chaussures de running spécialisées (la `safety_notes` recommande "chaussures de marche avec bon maintien et amorti"), pas de tongs. Si on monte vers 45 min dont une portion trot, on sort du cadre du template et du profil "remise en forme douce".

- **Cutback W4 vs escalade W5-W6** : si on accélère de W1 à W4, la cutback W4 n'est pas un "retour" mais une stagnation sur un palier inférieur. Cela peut psychologiquement démotiver un profil "more ambitious" (risque : abandon ou prise de risque en fin W5-W6 pour "rattraper").