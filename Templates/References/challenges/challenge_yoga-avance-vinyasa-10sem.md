# Challenge Report : yoga-avance-vinyasa-10sem

## Verdict
Template de qualité supérieure, prêt pour bundle en l'état. Seules 2-3 corrections mineures requises (clarifications d'équipement et cohérence J3 W2). La structure de progression, la sécurité et la pédagogie alignent les standards yoga avancé (Iyengar Institute, Yoga Journal, normes Ashtanga/Vinyasa). L'audit détaillé révèle un plan exceptionnellement documenté.

## Issues critiques (bloquantes pour bundle)
Aucune issue critique détectée.

## Issues importantes (à corriger avant bundle idéal)

- **[W2 J3]** Cooldown section : `"Viparita Karani (jambes au mur) 3 min + Savasana."` manque de clarté (Savasana n'est jamais listée dans les exercices finaux). Fixer : ajouter `duration_minutes: 7` et structure explicite pour Savasana comme exercice de fin en W2 J3 (cohérence avec les autres sessions). L'exercice existe dans les autres jours mais pas dans les `exercises[]` ici.

- **[Assumed Profile & Équipement]** Section `assumed_profile` mentionne "tapis antidérapant, 2 briques yoga, 1 sangle yoga, mur libre" mais ne précise pas si l'utilisateur doit avoir accès à un *espace suffisant* (minimum 2m x 2m pour Pincha/Sirsasana sans mur). Recommendation : ajouter "Espace libre min 2m² pour Pincha sans mur (W6+)." La sécurité des tentatives sans mur (W6 J1) repose sur cet espace.

- **[W3 J3 inconsistency]** Exercice "Sirsasana II (Tripod) au mur" utilise le terme "Tripod headstand" mais dans W3 J5 et W4, c'est renommé "Sirsasana I (classique)" au mur. Clarification nécessaire : Sirsasana II = Tripod (tête + 2 mains, genoux sur triceps), Sirsasana I = classique (tête + avant-bras jointe). Les deux coexistent dans le plan. Le passage W3 J5 "Ardha Sirsasana" suivi de "Sirsasana II (Tripod)" est correct, mais ajouter un encadré explicatif en W1 safety_notes pour distinguer les deux inversions (et éviter confusion utilisateur).

## Issues importantes (à corriger avant bundle idéal)

Aucune autre issue importante à corriger.

## Issues mineures (nice-to-have)

- **[W8-W9 Sirsasana durée]** W8 J3 annonce "Sirsasana I libre — 60 sec" comme objectif. W9 J3 annonce "Sirsasana I libre — 90 sec" comme objectif W9. La progression est claire mais pas de transition progressive (W8 60→90 sec serait plus réaliste). Ajouter mention : "Si 60 sec se tient confortablement, avancer vers 90 sec en W9. Sinon, rester à 60 sec stabilisé et consolider."

- **[W7 J5 Kapotasana intro]** "Kapotasana préparatoire avancé" en W6 J5 et W7 J5 utilise le terme "King Pigeon" mais n'apparaît jamais en tant que posture nommée complètement. Clarifier : Kapotasana complète (bras liés derrière la tête) n'est pas introduite dans ce plan (conscient et sûr). Rester sur "Eka Pada Rajakapotasana préparatoire" pour éviter promesse non tenue.

- **[Default objective vs. reality]** L'objectif annonce "Enchaîner des séquences Vinyasa fluides de 60 min" mais les séquences de 60 min n'apparaissent qu'à partir de W8. Les W1-W7 utilisent des durées de session plus courtes (55-70 min) ou des postures partielles. C'est conforme à la progression logique mais la description "60 min" pourrait tromper un utilisateur cherchant un plan "60 min depuis J1". Ajouter clarification : "Capacité à enchaîner 60 min fluides acquise à W8. W1-W7 : construire les fondations."

- **[W10 J5 Checklist format]** La checklist d'autonomie est rédigée comme texte long (excellente pédagogie) mais pas formatée comme exercice structuré (pas de `duration`, `sets`, `reps`). Ajouter un format cohérent : `"type": "evaluation"`, `duration: 5 min`, ou sous-section séparée post-Savasana pour clarté JSON.

- **[Safety notes — Douleur distinction]** Section "sensation intense vs. douleur vive" est excellente pédagogiquement mais pourrait ajouter 1-2 exemples : ex. "Sensation intense = chaleur/étirement dans la hanche en Pigeon (OK) vs. douleur médiale du genou (stop)." Améliore l'autonomie.

- **[Rest times non uniformes]** `rest_seconds` varie considérablement (0 sec en Savasana ✓, 15 sec pour Navasana, 90 sec après inversions ✓). C'est approprié mais pas documenté dans la logique de progression. Ajouter note en haut : "Rest_seconds varient par risque et récupération neuromusculaire : 0-30s cardio-core, 45-60s équilibres, 90-120s inversions."

## Manques notables

- **Progression d'ujjayi objective** : Le programme insiste sur "ujjayi continu" dès W1 mais ne propose pas de méthode auto-évaluée. Suggestion : ajouter en W1 J1 un "Ujjayi benchmark" (ex : 3 SNA en ujjayi, noter durée respiration : cible W1 = 5-6 sec inspir/expir). Permet auto-suivi concret.

- **Contre-indications du profil asumé** : Le profil suppose "base solide" et "pas de blessure aiguë à l'épaule/poignet/cou" mais ne précise pas : épilepsie photosensible (Ashtanga rythme rapide), glaucome (inversions), grossesse, hernie discale ancienne. Clarification recommandée : "Ce programme ne convient pas à : [liste médico-légale standard yoga avancé]."

- **Scaling pour régression forcée** : Si l'utilisateur échoue à atteindre la checklist W10, le protocole de redémarrage est cité ("recommence W8-W9") mais pas détaillé. Ajouter framework de régression (ex : si <3/5 critères = pratiquer 2 sem supplémentaires en cycles W8→W9→test W10 J5).

- **Équivalences de postures alternatives** : Pour utilisateurs avec limitations (ex : douleur poignet récurrente), pas de liste d'équivalences (ex : Chaturanga → Knees-Chest-Chin, Pincha → Shoulder Stand inversée). Mention en safety_notes ou adaptatif par jour recommandé.

- **Savasana ujjayi W10 J5** : Le J5 W10 note "pas de guide, pas de compte, juste ta respiration comme métronome" mais ne précise pas : ujjayi continue ou respiration naturelle en Savasana ? Standard yoga = respiration naturelle post-effort. Clarifier.

## Scores (sur 10)

- **Cohérence interne : 9/10**  
  Progression linéaire rigoureuse (W1-W5 fondations → W6-W7 inversions/équilibres → W8-W9 pic → W10 autonomie). Duration_weeks = 10 cohérent avec weeks.count = 10. Sessions_per_week = 4 respecté. Progression_logic couvre TOUS les éléments annoncés (5 couches, cutback W5, vinyasa vol, séquençage inversions, tapering W10). Seule faille mineure : Sirsasana II vs Sirsasana I nomenclature à clarifier.

- **Alignement référentiel : 9/10**  
  Respecte Ashtanga Vinyasa progressions (Surya Namaskar → Standing → Peak → Inversions → Finalization). Yin yoga (W2 J3, W5 J3, etc.) aligné avec Yin Yoga Institute standards (3-5 min holds, fascial release). ACSM guidelines appliquées (cutback week, progression 10%, tapering). Progressions inversions conformes : 6-8 sem minimum pour adaptation scapulaire (programme : W1-W7 pour Sirsasana I, W1-W6 pour Pincha = correct). Seul bémol : Kapotasana "avancée" ne figure pas en séquence complète (choix consciencieux).

- **Sécurité : 9.5/10**  
  Safety_notes exceptionnellement détaillés (12 drapeaux rouges spécifiques, 6 règles générales, 5 signes surcharge). Couverture complète des zones à risque (poignets, cou cervical, épaule impingement, genou, lombaires). Protocoles clairs : "STOPPER immédiatement" vs. modulations acceptables. POINT FORT : avant-bras/mains portent le poids en inversions (jamais le cou) = standard OR. Bémol mineur : aucune mention d'assurance ou consultation médicale pré-plan pour un programme d'intensité maximale ; recommandation standard manquante.

- **Pédagogie : 9/10**  
  Progression par paliers évidents (W1 diag → W2 transitions → W3-W4 inversions → W5 recovery → W6 sans mur → W7-W9 pic → W10 autonomie). Instructions précises (ex : "Coudes à 90°, épaules pas en dessous des coudes" en Chaturanga). Respiration ujjayi intégrée dès W1 (niveau avancé, acceptable). RPE non numérique mais descriptions de sensations (ujjayi break = trop intensif). Checklist autonomie W10 J5 excellente (5 critères concrets). Manque minor : aucun guide audio ou vidéo proposé pour les utilisateurs auditifs/visuels (JSON seul).

- **Global : 9/10**  
  Template de programme Vinyasa avancé de référence qualité. Progression rigoureuse, sécurité exemplaire, cohérence interne forte. Prêt bundle sans blocages. Les 3 corrections demandées sont mineures (nomenclature Sirsasana, espace minimum, Savasana J3 W2). Seuls manques : évaluation ujjayi objective et scaling de régression détaillé pour utilisateurs en difficulté W10.