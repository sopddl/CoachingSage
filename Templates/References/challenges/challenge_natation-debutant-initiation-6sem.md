# Challenge Report : natation-debutant-initiation-6sem

## Verdict
Template solide et bien structuré, aligné sur les recommandations ACSM et les pratiques fédérales (Swim England, FFN). La progression pédagogique est logique, la sécurité bien couverte. **Bundlable en l'état avec très mineures clarifications** sur deux points : cohérence chiffre de volume hebdo annoncé vs. réalisé, et précision d'une instruction d'exercice. Aucun drapeau rouge bloquant.

## Issues critiques (bloquantes pour bundle)
Aucune issue critique détectée.

## Issues importantes (à corriger avant bundle idéal)

- **[W1 J1 - W6 J4]** Cohérence volume annoncé vs. réalisé : la progression_logic énonce « Volume distances continues : 400 m (W1) → 550 m (W2) → 700 m (W3) → 850 m (W4) → 700 m W5 cutback → 825 m + 200 m phare (W6) ». Audit détaillé du calcul cumulé par semaine :
  - **W1** : 4 × 25 m (J1) + 4 × 25 m (J4) = 200 m (annoncé 400 m) ❌
  - **W2** : 4 × 25 m + 4 × 25 m + 2 × 50 m (J1) + 4 × 25 m + 4 × 50 m (J4) = 600 m (annoncé 550 m) ✓ approx.
  - **W3** : 4 × 25 m + 4 × 25 m + 3 × 75 m (J1) + 4 × 25 m + 3 × 75 m + 1 × 100 m (J4) = 900 m (annoncé 700 m) ❌
  - **W4** : 4 × 25 m + 4 × 25 m + 3 × 100 m (J1) + 4 × 25 m + 2 × 100 m + 1 × 150 m (J4) = 1050 m (annoncé 850 m) ❌

→ **Fix proposé** : Recalculer et clarifier les volumes réels par semaine dans progression_logic, ou ajuster les répétitions/distances dans les exercices pour matcher les chiffres annoncés. Actuellement, la progression est PLUS volumineux que l'annoncé, ce qui n'est pas un défaut per se, mais crée une incohérence documentaire. Recommandation : **augmenter les chiffres annoncés** (W1 : 400→600 m, W3 : 700→900 m, W4 : 850→1050 m) pour que la progression_logic soit fidèle aux sessions réelles.

- **[W3 J1 - Respiration latérale statique au mur]** Ambiguïté sur la respiration unilatérale vs. bilatérale : la safety_notes et progression_logic affirment que « respiration bilatérale n'est PAS introduite avant W4 ». Cependant, l'exercice « respiration latérale statique » ne précise pas explicitement si c'est un côté unique (W3) ou alternant les deux côtés (W4). Le drill « side kick bilatéral » en W4 J1 dit explicitement « deux côtés ». 
→ **Fix proposé** : Ajouter une note explicite dans W3 J1 « respiration latérale statique au mur » : *« Choisir le côté dominant (gauche OU droit). S'y tenir pour toute la W3. La bilatéralité (alterner les deux côtés) ne commence qu'en W4. »* pour éviter qu'un utilisateur n'alterne les côtés trop tôt.

## Issues mineures (nice-to-have)

- **[W1 J4 - Pull-buoy bras seuls]** Note propose « ou jambes croisées sans matériel ». La phrase « jambes légèrement croisées à la cheville » est une bonne alternative, mais les novices pourraient trouver ça inconfortable (jambes croisées = instabilité). Suggestion : ajouter une variante supplémentaire explicite : *« SANS pull-buoy ni croisement : tenir une planche légère avec les mains jointes devant pour réduire passivement le battement. »*

- **[W2 J4 - 6-3-6 drill]** Note dit « Lent, contrôlé, respiration libre ». Pour un débutant W2, « respiration libre » pendant un drill moyen peut créer de la panique s'il ne maîtrise pas encore la respiration latérale (qui arrive en W3). Préciser : *« Respiration libre au rythme naturel — ne pas forcer le cycle. Tu peux tourner la tête quand tu en as besoin, même si ce n'est pas au bon moment du drill. »*

- **[W6 J4 - Checklist d'autoévaluation]** La checklist en notes du 200 m est excellente pour l'autonomie. Suggestion cosmétique : proposer une version visuelle simplifiée (emoji ou icône ✓) que l'utilisateur puisse cocher dans l'app pour tracker sa maîtrise. Actuellement c'est un texte long — un toggle pourrait améliorer l'UX.

- **[W5 - Semaine cutback]** Progressive_logic annonce « volume réduit de 15% par rapport à W4 ». Calcul réel W5 : 4 × 25 + 4 × 25 + 3 × 100 (J1) + 4 × 25 + 2 × 100 + 1 × 150 (J4) = 850 m. W4 réel : ~1050 m. Réduction ≈ 19% ✓, acceptable (légèrement au-delà des 15% annoncés, mais cohérent pédagogiquement). Pas de fix obligatoire, mais note à documenter si précision marketing requise.

## Manques notables

- **Progression_logic - détail manquant** : Aucune mention de la **fenêtre d'intensité (RPE ou % FCmax)**. Pour un nageur débutant, la natation peut être confuse (est-ce un exercice « mou » ou « intensif » ?). Suggestion : ajouter une ligne type « Toutes les séances W1-W5 sont en RPE 4-6/10 (effort conversationnel). W6 J4 est une tentative maximale contrôlée (RPE 7-8/10 sur le 200 m). » La sécurité_notes couvre les drapeaux, mais pas le calibrage global d'intensité.

- **Équipement** : Assumed_profile dit « pull-buoy et planche... en prêt piscine avec alternative sans matériel ». Les alternatives sont présentes, mais aucun exercice ne propose une **liste consolidée d'équipement optionnel recommandé**. Pour une app, un icône ou toggle « équipement non disponible » faciliterait les substitutions. Mineure, car alternatives sont inline.

- **Respiration bilatérale - démystification** : Le plan dit clairement que la bilatérale n'arrive qu'en W4, ce qui est juste pédagogiquement. Cependant, aucun exercice ne **détaille les erreurs courantes** lors de la transition (ex: « panique au premier cycle bilatéral, sensation d'étranglement »). Suggestion : ajouter en W4 J1 une ligne de sécurité type : *« Si la respiration bilatérale te crée du stress : revenir à la respiration unilatérale, pas de forçage. La bilatérale viendra après 1-2 semaines de nage régulière supplémentaire. »*

- **Checklist post-objectif (W6)** : La séance phare inclut une excellente checklist de 5 critères. Suggestion : ajouter un **6e critère sur la joie/plaisir** (« J'ai trouvé ça difficile mais gratifiant »), car une app dédié à l'initiation devrait aussi cultiver l'amour de la nage, pas juste la performance.

## Scores (sur 10)

- **Cohérence interne** : 7/10
  - Duration_weeks cohérent (6 semaines, 2×6 sessions = 12 sessions).
  - Progression_logic énoncée clairement et appliquée fidèlement dans les semaines.
  - **Détraction majeure** : volumes annoncés ≠ volumes réalisés (incohérence documentaire, pas un défaut de sécurité).
  - Tous les drills énoncés dans progression_logic (équilibre W1, propulsion W2, respiration W3, bilatérale W4, cutback W5) sont présents.

- **Alignement référentiel** : 9/10
  - Très bien aligné sur Swim England Adult Framework et FFN (drills techniques = sculling, catch-up, side kick, fist swim, fingertip drag = tous des classiques).
  - Espacement des séances 72h (J1 et J4) respecte la recommandation ACSM motor learning.
  - Progression distance très progressive (25 m → 200 m) et réaliste pour 6 semaines.
  - Cutback W5 obligatoire ✓ (applicable pour ≥6 sem, présent ici).
  - **Petit bémol** : pas de mention explicite d'une progression d'intensité (RPE) — seule la distance est programmée.

- **Sécurité** : 9/10
  - Safety_notes exceptionnels : drapeaux rouges spécifiques natation bien couverts (swimmer's shoulder, crampes, vertiges, otite).
  - Protocole d'arrêt clair (douleur épaule = stop).
  - Échauffement et mobilité épaules systématiques (coiffe des rotateurs bien protégée).
  - **Seul manque** : aucune mention d'un protocole si l'utilisateur perd pied ou entre en panique totale (réflexe d'appel maître-nageur bien cité, mais pas de « 1er secours » simple type « gonfleur piscine »). Mineure, car piscine surveillée est supposée.

- **Pédagogie** : 8/10
  - Instructions claires et détaillées pour chaque exercice (notes pédagogiques très utiles).
  - Progression par paliers régulière (pas de saut brutal).
  - Respiration/cadence chiffrées quand pertinentes (cycle 2 coups, cycle 3 coups, côté préférentiel).
  - Autonomie cultivée (checklist auto-évaluation en W6, visualisation mentale citée).
  - **Détraction** : RPE non chiffré (« allure confortable » vs. « RPE 5/10 »). Pédagogie tactile excellente, mais mesure objective manque pour auto-calibrage débutant.

- **Global : 8.3/10**
  - **Verdict final** : Template de très bonne qualité, prêt pour bundle avec corrections mineures de cohérence documentaire (volumes annoncés) et clarifications pédagogiques (RPE, unilatéral W3-only). Aucun risque sécurité. Structure et progression exemplaires pour une initiation 6 semaines en natation.