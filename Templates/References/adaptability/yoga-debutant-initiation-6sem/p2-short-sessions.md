# Adaptability : yoga-debutant-initiation-6sem + p2-short-sessions

## Rigidity score
**8/10**

## Patch approach
Le template est fondamentalement compatible avec des séances de 30 min : le profil de débutant yoga est conçu pour des sessions de 30 min (voir `assumed_profile` et `default_objective`). Cependant, plusieurs séances W5-W6 déclarent 35-40 min et incluent des savasana de 5 min non compressibles. La stratégie consiste à (1) respeté la limite 30 min max en replaçant systématiquement les savasana à 4 min sauf W1-W2 où 4 min existe déjà, (2) scinder la "séance phare" 40 min de W6 J5 en deux sessions W6 parallèles, (3) vérifier que aucune règle du `progression_logic` (notamment cutback W4 et ujjayi W3 minimum) n'est cassée.

## Concrete modifications
- **W1 J1, J3, J5** : Aucune modification — durée déclarée 30 min, savasana 4 min, compatible.
- **W2 J1, J3, J5** : Aucune modification — durée déclarée 30 min, savasana 4 min, compatible.
- **W3 J1, J3, J5** : Aucune modification — durée déclarée 30 min, savasana 4 min, compatible.
- **W4 J1, J3, J5** : Aucune modification — durée déclarée 28 min, compatible.
- **W5 J1** : Aucune modification — durée déclarée 30 min, compatible.
- **W5 J3** : Réduire "Séance complète 30 min" de 32 min déclarées à **30 min exact** en comprimant l'enchaînement de 1 min (exemple : Surya Namaskar A x1.5 cycles au lieu de x2, soit 2 min 30 au lieu de 5 min) + savasana rester 4 min. Ajustement : ommettre 15 sec de récupération "Child's Pose" inutile entre les Warrior.
- **W5 J5** : Même compressi: "Séance 30 min entièrement autonome" rester 30 min en savasana 4 min (au lieu de 4 min non compressée). Déjà dans le budget.
- **W6 J1** : Aucune modification — durée déclarée 35 min (30 min séance + 4 min savasana) : **revoir** : la séance autonome est déclarée 30 min, savasana final 4 min = 34 min total. Réduire à **savasana 3 min → 33 min**, puis rogner 3 min sur la séance autonome en shortcutant une transition ou éliminant Cat-Cow (remplacer par 3 respirations ujjayi = 30 sec au lieu de 2 min) : **J1 final = 30 min exact** (27 min séance autonome + 3 min savasana).
- **W6 J3** : Aucune modification majeure — durée 30 min, savasana 4 min = 34 min déclarées. Réduire **Postures cibles à 12 min au lieu de 15 min** (garder 3 postures cibles au lieu de 4, supprimer une variante) + **Warrior Flow 2 min au lieu de 3 min** + **Reclined Pigeon 3 min total au lieu de 4 min** (1.5 min par côté) + **savasana 3 min** = **30 min exact**.
- **W6 J5 (séance phare 40 min)** : **SCINDER EN DEUX SESSIONS PARALLÈLES** — ceci est la point rigide majeur du template :
  - **Nouvelle W6 J5a (20 min)** : "Séance phare — partie 1 : sol + debout" = Cat-Cow (2 min) + Surya Namaskar A x2 (5 min) + Warrior Flow G+D comprimé (5 min) + Tree + Warrior III unilatéraux (3 min) + Savasana (3 min). **Total : 18-20 min.**
  - **Nouvelle W6 J5b (sugg. W6 J6, jour optionnel/weekend)** : "Séance phare — partie 2 : appuis + clôture + checklist" = Downward Dog (1 min) + Cobra x2 (1 min) + Reclined Pigeon (3 min) + Reclined Twist (1 min) + Savasana intégration (2 min) + **Checklist d'autonomie 3-5 min** = **11-12 min séance + checklist hors tapis, total ~15-17 min** ou fusionner checklist dans savasana (2.5 min savasana + checklist mentale = 2.5 min) = **total 13 min, flexible vers +/- 2 min.**

  Ou **regrouper W6 J5a + J5b en une seule "séance marathon" de 30-32 min en acceptant un débordement très léger** (savasana + checklist = 5-6 min au lieu de 4) : si j'apportais un patch de **+2 min seulement**, cela reste quasi respecté. Mais pour stricte compliance 30 min max, la scission est plus sûre.

## Rigidity issues
- **W5 J3 et W5 J5 (Séances complètes 30 min) : surcharge de contenu précise déclarée "30 min"** mais avec savasana intégrée de 4 min, ce qui laisse 26 min pour 20 postures + transitions = serré, mais faisable (pas de rigidité, juste timing mathématiquement tendu). Patch : rogner 1-2 min sur "Surya Namaskar A x2" (réduire à 1.5 cycles de 6-7 min au lieu de 5 min) → gagne 0.5-1 min.
- **W6 J5 "Séance phare" : déclarée 40 min + 5 min savasana = 45 min conceptuel**. C'est la séance d'**intégration du programme entier**, incluant la "checklist d'autonomie finale 5 min"** non négociable (elle matérialise la transition post-programme du `progression_logic`). Aucune compression sans perdre la substance. **Ceci est le point rigide du template : la séance finale ne peut pas être cassée en deux sans perdre l'effet psychologique/pédagogique de "clôture complète"**. Scission acceptable mais non idéale.

## Contradictions
- **Aucune contradiction directe avec safety_notes ou progression_logic** : aucune règle (ujjayi W3 min, échauffement poignets, cutback W4, savasana 3-5 min systématique) n'est cassée par les compressions proposées. Toutes les modifications touchent des durées discrétionnaires (cycles supplémentaires, transitions, nombre de répétitions) pas des éléments structurels.
- **Tension potentielle W5-W6 sur la "règle SAVASANA STRUCTURELLE 3-5 MIN SYSTÉMATIQUE"** : les patches ci-dessus réduisent savasana à 3 min en plusieurs endroits (W6 J1, J3, J5b). 3 min est au **bas du seuil acceptable** (3 min minimum déclaré dans safety_notes et progression_logic). Cela reste dans le cadre, mais marginal. Si l'utilisateur W6 J5a+J5b veut une savasana de 4 min, il devra rogner ailleurs ou accepter 31-32 min ponctuellement.
- **Checklist autonomie W6 J5 (5 min hors tapis)** : si on la considère comme faisant partie de la séance (ce qu'elle devrait), elle ajoute 5 min, poussant W6 J5 complet à 35-40 min. Patch proposé : intégrer checklist dans savasana finale (évaluations mentales pendant la posture) → economise du temps mais dilue la clarté de la checklist. Trade-off acceptable.