# Challenge Report : natation-intermediaire-endurance-8sem

## Verdict
Template de très haute qualité, bundlable en l'état. Cohérence interne exemplaire, alignement fort avec les référentiels ACSM/Swim England, sécurité exhaustive et pédagogie progressive méthodique. Quelques points de clarification mineurs sur les allures numériques et un point de redondance sur les drills, mais aucun défaut bloquant.

## Issues critiques (bloquantes pour bundle)
Aucune issue critique détectée.

## Issues importantes (à corriger avant bundle idéal)

- **[W1-W4] Allure cible manquante en chiffres absolus** : Le template mentionne "allure conversationnelle" et des repères relatifs ("+10-15 sec/100 m plus lent que le test"), mais ne fournit pas d'allure cible réelle en mm:ss/100 m pour l'user intermédiaire. Un nageur n'ayant jamais testé son 400 m ou ayant une perception faussée de l'effort sera désorienté. → **Fix** : ajouter une allure endurance cible estimée (ex : "allure endurance cible W2-W3 : 2:20-2:30/100 m pour profil 400 m en 9-10 min ; ajuster ±10 sec selon tes sensations"). Inclure un mini-tableau : "Si ton 400 m de W1 = X min, alors allure endurance ≈ X + 15 sec par 100 m."

- **[W6] Allure seuil sans référent numérique** : "Allure seuil : environ 10-15 sec/100 m plus rapide que endurance" est correct mais peu actionnable si l'endurance n'est pas chiffrée. Le nageur qui a coché 2:25/100 m en endurance ne saura pas si 2:10/100 m ou 2:15/100 m est le seuil. → **Fix** : expliciter "seuil = allure légèrement inconfortable mais tenable pendant 150 m, respiration accrue mais non paniquée" + ajouter un RPE cible : "RPE 6-7/10 (allure conversationnelle devenant difficile)".

- **[W3 J2] Drill "Fist swim" : manque de restriction temporelle** : Le fist swim sur 25 m est un drill valide mais l'exercice "reps: 25 m, sets: 4" = 100 m au total est court pour consolider la sensation. Or, W3 J2 cumule déjà 4 drills (fist swim + catch-up + dry catch implicite dans "nage technique lente"). La charge drill est élevée pour un intermédiaire préférant la quantité qualité. → **Fix** : clarifier que le fist swim W3 J2 est court (100 m) volontairement pour préserver la fraîcheur avant le 600 m ; ou le déplacer en J2 W6 où l'allure seuil remplace le volume long.

- **[W2] Nage 400 m continu : ambiguïté "sans s'arrêter"** : L'exercice dit "400 m sans pause" mais le cooldown et rest_seconds suggèrent une pause possible. La sécurité note autorise "si tu t'arrêtes, tu prends 30 sec et tu reprends" (W2 J5 500 m). Contradiction possible. → **Fix** : harmoniser en W2 J2 : "Nager 400 m à allure confortable, sans s'arrêter volontairement. Si tu dois t'arrêter (essoufflement réel), noter à quel mètre et prendre 30 sec."

## Issues mineures (nice-to-have)

- **[W2 J5] Drill redondance : "Fingertip drag" déjà en W1 J5** : W2 J5 réintroduit fingertip drag pour "ancrer la sensation avant le bloc long". C'est pédagogiquement valide (répétition utile) mais peut être confus avec un oubli. → **Fix optionnel** : renommer en W2 J5 : "Drill Fingertip drag (rappel) — cette fois-ci, compter combien de cycles avant de sentir l'eau" pour justifier la répétition.

- **[W5 cutback] Note sur la "priorité technique absolue"** : La semaine de cutback insiste sur "priorité à la qualité technique" mais le volume 500 m continu reste substantiel et absorbe 75% de la séance. Pour une vraie cutback ACSM (réduction 40-50% du volume principal), envisager de réduire le 500 m à 400 m. Cependant, le template est volontairement conservateur (cutback moins agressif, privilégiant la sécurité du nageur intermédiaire). C'est une choice design, pas un défaut. → **Status** : acceptable, noter dans les release notes.

- **[W3 J2] Decompte cycles : unité manquante** : "Compter les cycles de bras sur 25 m (référence : intermédiaire ~17-20 cycles/25 m)." C'est clair, mais manque une explication rapide : 1 cycle = 1 rotation complète des 2 bras. → **Fix optionnel** : clarifier en note : "1 cycle complet = 1 coup du bras droit + 1 coup du bras gauche."

- **[W4 recommandation "3e séance"]** : La progression_logic évoque "recommandation 3e séance dès W4" mais le template schedule ne l'inclut pas explicitement. C'est volontaire (recommandation libre, non obligatoire), mais un user peut ignorer cette suggestion. → **Status** : acceptable, intention claire en progression_logic. Ajouter optionnellement en goal de W4 : "(Optionnel : ajouter 1×400-500 m nage facile jeudi ou dimanche pour accélérer l'apprentissage moteur)".

## Manques notables

- **Format auto-évaluation finale W8 trop court** : La checklist de 5 items en W8 goal est excellente, mais elle n'est jamais codifiée en exercice ou note structurée. Un user peut oublier de la remplir. → **Suggestion** : ajouter un exercice final factice (ou un "completion_checklist" champ) : "✓ Checklist d'autonomie : cocher les 5 items avant de clôturer le plan."

- **Absence d'estimation RPE sur les drills W1-W5** : Les drills ne portent pas d'indication RPE (ex : "Streamline glissé = RPE 1-2" ou "Séries seuil 4×150 m = RPE 7-8"). Pour un intermédiaire autonome, ce repère est utile. → **Suggestion** : ajouter en notes des drills lents (Streamline, Poisson sur le dos) : "RPE 1-3 (très facile, contrôle pur)". Pour intervalles (W4 pyramide, W6 seuil) : "RPE 6-7 (allure soutenue, respiration accrue, mais discours possible en récup)".

- **Hydratation post-séance peu précisée** : Safety notes couvre pré-séance et post-séance brièvement, mais ne détaille pas la fenêtre de réhydratation active (immédiate vs 1h après). ACSM recommande 500-750 ml dans les 2h post-effort aquatique si sueurs abondantes. → **Suggestion** : renforcer en safety_notes ligne hydratation : "Dans l'heure suivant la séance : 300-500 ml eau + électrolytes légers si séance > 45 min."

- **Absence de guidance sur la 3e séance W4+ libre** : Le template évoque "3e séance libre (400-500 m easy, pas de drills complexes)" mais ne fournit jamais un template exact pour cette séance. Un user devra l'inventer. → **Suggestion** : ajouter en W4 goal ou annexe : "Exemple de 3e séance libre : échauffement 200 m / crawl 300 m à allure très facile (RPE 2-3) / retour 100 m dos / total 600 m, durée 35-40 min."

- **Pas de guidance sur l'équipement palmes** : Safety note mentionne "palmes longues non adaptées" comme risque de genoux, mais ne précise jamais si des palmes courtes sont recommandées en W1-W3. Swim England recommande palmes courtes (25-35 cm) pour le travail de jambes technique chez intermédiaire. → **Suggestion** : ajouter en safety_notes : "Palmes optionnelles : si utilisées, privilégier les palmes courtes (25-35 cm) pour préserver la technique du battement naturel. Éviter les palmes longues de apnée qui fatiguentles genoux."

## Scores (sur 10)

- Cohérence interne : 9/10
  - duration_weeks (8) ↔ weeks.count (8) ✓
  - Progression 200m → 500m → 600m → 700m → 500m (cutback) → 800m → 900m → 1000m strictement linéaire et justifiée ✓
  - Drills introduits dans l'ordre logique (équilibre → catch → timing/rotation → respiration → propulsion) ✓
  - Cutback W5 correctement appliqué (15% réduction volume, priorité technique) ✓
  - Un détail : "progression_logic" très détaillée mais W2 J2 exercise "nage continue crawl 400 m" n'indique pas si c'est un test ou une nage libre. Vérification fine : c'est un test (c'est dans "exercises", pas "warmup"), ce qui colle à la logique. ✓
  - **Léger point faible** : les allures numériques en absolute (mm:ss/100m) ne sont jamais explicitées → -1pt

- Alignement référentiel : 9/10
  - ACSM 10-15% weekly volume progression ✓ (100-200m par semaine respecté)
  - Cutback toutes les 4 semaines ACSM ✓
  - Swim England drills ordering (equilibrium → catch → rotation → breathing) ✓
  - Tapering W8 sur 2-4 jours (correct pour plan 8 sem) ✓
  - Respiration bilatérale dès W3 (timing logique post-consolidation unilatérale) ✓
  - Seuil (threshold) work W6+ (Joe Friel / Swim Smooth) ✓
  - Motor learning spacing (72h max entre expositions, justifie 2 séances/sem + 3e optionnelle) ✓
  - **Point faible** : absence de fréquence cardiaque ou allure FC cible. Swim England recommande zones 60-70% FCmax (endurance) et 80-85% FCmax (seuil). Le template privilégie RPE/sensation, ce qui est pédagogiquement valide mais moins quantifiable. → -1pt

- Sécurité : 10/10
  - Drapeaux rouges exhaustifs : swimmer's shoulder (conflit acromial), otite externe, crampes, panique respiratoire, genou (rare) ✓
  - Prévention otite (sécher oreilles, bouchons optionnels) ✓
  - Lunettes obligatoires ✓
  - Hydratation pré/post ✓
  - Progressivité max 200m/sem inter-séances ✓
  - Repos 48h min entre 2 crawl ✓
  - Safety notes: fatigue épaule post-W5 ("si persistant 48h, réduire 20%") ✓
  - Recommandation eau libre = jamais seul + gilet ✓
  - Signes de surcharge (4 marqueurs pour cutback supplémentaire) ✓
  - Procédure manquée séance (< 1 sem / 1-2 sem / > 2 sem) ✓
  - Rien manque.

- Pédagogie : 9/10
  - Progression par paliers nets (100 m / 100 m par semaine, sauf cutback et relance post-cutback) ✓
  - Instructions exercices très claires ("doigts à la surface", "index en premier", "coude haut") ✓
  - Respiration chiffrée (tous les 3 temps en W3) ✓
  - Cadence cycles comptée (17-20 cycles/25m comme référence) ✓
  - Allure guidance (conversationnelle, soutenue, légèrement inconfortable) ✓
  - Tapering et timing mental préparé (découpage 10 × 100m, stratégie d'accélération) ✓
  - Checklist d'autonomie finale excellente ✓
  - **Point faible** : W1 test 400m n'inclut pas de guidance RPE post-test ("après le test, tu dois être légèrement essoufflé mais pas au maximum"). Les users débutants peuvent mal calibrer. → -1pt
  - Notes de carnet de bord recommandées en W6-W7 mais peu systématisées en structure.

- **Global : 9/10**
  - Template professionnel, pensé en détail, aligné référentiels robustes.
  - Issues reportées = clarifications numériques sur allures + ajouts optionnels (RPE drills, 3e séance template, palmes).
  - Aucun défaut de sécurité ni incohérence majeure.
  - Bundlable immédiatement ; suggestions mineures pour version 1.1.