# Adaptability : natation-debutant-initiation-6sem + p3-travel-minimal-gear

## Rigidity score
**1/10**

## Patch approach
Le template est fondamentalement non-adaptable à cette contrainte car le sport lui-même (natation) ne peut pas être substitué par du matériel de salle (élastique, corde à sauter, baskets). Une semaine de natation requiert une piscine — absence non-négociable. Le profil d'adaptation demande implicitement de remplacer la natation par un entraînement terrestre, ce qui contredit le cœur du programme. Il n'existe pas de substitution équivalente en stimulus pour les drills de natation (équilibre aquatique, propulsion, respiration) avec une bande élastique ou une corde.

## Concrete modifications
Aucune modification possible du template natation sans le détruire entièrement.

## Rigidity issues
- **Dépendance absolue à la piscine 25 m** : mentionnée explicitement dans `assumed_profile` ("accès à une piscine 25 m"). Chaque séance (W1-J1, W1-J4, ... W6-J4) présume une piscine. L'absence d'eau invalide 100% du contenu.
- **Drills spécifiques au milieu aquatique** : streamline mural, side kick, catch-up drill, sculling, fist swim, fingertip drag, position poisson, battement de jambes. Aucun équivalent en salle avec élastique ou corde.
- **Progressions basées sur la distance continue en piscine** : W1 4×25 m, W2 6×25 m + 2×50 m, W3 3×75 m, W4 3×100 m, W5 3×100 m + 1×150 m, W6 200 m continu. Ces distances sont des longueurs de bassin — intraduisibles hors eau.
- **Safety_notes ancrées à l'eau** : otite externe, sécurité couloir, maîtrise-nageur, équilibre vestibulaire après submersion. Aucune pertinence terrestre.
- **Respiration latérale et expiration sous-marine** : cœur technique du programme à partir de W3. Aucun analogue sans eau.

## Contradictions
- **Contradiction fondamentale** : le profil d'adaptation impose "pas d'accès à une piscine" (voyage minimal) vs. le template suppose "accès garanti à une piscine 25 m" (ligne 1 de `assumed_profile`). Ces deux conditions sont mutuellement exclusives.
- **Incompatibilité du sport** : natation ≠ entraînement musculaire ou cardio terrestre. Les niveaux de contrôle moteur, les zones d'adaptation, la thermorégulation et le stimulus neuromusculaire sont fondamentalement différents.
- **Impossibilité de maintenir progression_logic** : les 5 principes de progression (technique avant distance, règle 72h, drills différenciés, respiration bilatérale W4+, cutback W5) reposent entièrement sur la séquence pédagogique aquatique. Sans eau, la logique s'effondre.

---

### Recommandation
**Ce template ne peut pas être adapté à cette contrainte.** 

Si l'utilisateur se trouve en situation de voyage sans accès à piscine :
- **Option A** : reporter la semaine à son retour (reprendre le jour suivant en même semaine).
- **Option B** : si > 2 semaines sans piscine, reprendre en W3 à son retour (protocole mentionné dans safety_notes : "> 2 semaines de pause : reprendre en W3").
- **Option C** : consulter un template d'entraînement terrestre alternatif (ex : HIIT, musculation, VO2 max) qui n'est pas un substitut de natation mais qui maintient la condition physique générale.

**Le template est rigide par nature, pas par mauvaise conception** — c'est la bonne conception pour un sport monodisciplinaire. La natation ne se fait pas en voyage sans eau.