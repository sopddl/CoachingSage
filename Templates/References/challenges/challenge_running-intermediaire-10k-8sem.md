# Challenge Report : running-intermediaire-10k-8sem

## Verdict
Template de qualité très élevée, prêt pour bundle avec corrections mineures. La structure, la progression et l'alignement référentiel sont solides et conformes aux standards ACSM/Hal Higdon. Quelques incohérences pédagogiques et une lacune sur la vérification de l'autonomie requièrent des ajustements avant lancement en production.

## Issues critiques (bloquantes pour bundle)
Aucune issue critique détectée.

## Issues importantes (à corriger avant bundle idéal)

- **[W1 J1]** Test 5K : La note indique « Exemple : 30 min → allure 5K = 6:00 min/km » mais 5 km en 30 min = 6:00 min/km exactement, non « allure 5K + X s/km ». Clarifier : l'allure 5K mesurée en W1 J1 EST l'allure de référence, elle ne s'ajoute pas à elle-même. → **Fix** : reformuler « Exemple : si tu chronos 5 km en 30 min, ton allure 5K = 6:00 min/km. Ensuite, allure seuil = 6:30-6:45 min/km (= 6:00 + 30-45 s/km), allure facile/long run = 7:30-8:00 min/km (= 6:00 + 90-120 s/km). »

- **[W3-W7]** Progression des finisseurs manquante : W3 J1 introduit 2×200 m finisseurs (2×2 min= 4 min), mais aucun plan de progression ou disparition claire de cet élément dans W4-W7. Les finisseurs disparaissent soudain en W4 sans justification. → **Fix** : ou les maintenir en W4-W5 (cutback w/ allègement à 1×200 m), ou expliquer explicitement « suppression en W4 : maintenance du pic VO2max via les 800 m ».

- **[W5 cutback]** Incohérence : le cutback annonce « volume total réduit d'environ 15% » mais les 4×400 m (4 × 2:24 ≈ 9:36 min) vs W4 3×800 m (3 × 4:48 ≈ 14:24 min) = réduction de 33% en intervalles seuls, non 15% global. Les temps de repos déclarés (120 sec vs 180 sec en W4) réduisent aussi la charge. → **Fix** : recalculer et déclarer « volume intervalles -30%, tempo -28%, long run -22% → volume course total -15 à -18% », ou ajuster les volumes pour confirmer -15% promis.

- **[W8 J5]** Checklist d'autonomie : listée dans les notes (5 points) mais elle n'est pas formellement structurée en tant qu'élément de sortie. Un coureur autonome doit pouvoir l'imprimer/accéder. → **Fix** : créer un champ `autonomy_checklist` dans l'exercice W8 J5, ou ajouter un élément séparé après la séance.

## Issues importantes (à corriger avant bundle idéal)

- **[W2 J3]** Clamshells annoncés pour la première fois, mais safety_notes cite « clamshells du plan » dès W1. Décalage temporel. → **Fix** : soit introduire clamshells en W1 J3 (minimal : 2×12), soit corriger safety_notes pour renvoyer à W2.

- **[W1-W8]** Manque de repère RPE spécifique pour les phases de récupération (J2, J4, J6 de repos complet). Bien que la structure soit claire, un coureur novice en autonomie pourrait se demander s'il doit marcher, faire du yoga léger ou rester inactif. → **Fix** : ajouter en safety_notes ou en guidance générale : « Jours de repos (J2, J4, J6) : repos complet ou activités légères < RPE 3/10 (marche 20 min, étirements, mobilité douce, yoga restauratif). Pas de fractionné, pas de tempo. »

- **[W6-W8]** Décalage nutrition : long run de 10 km (W6 J5) demande nutrition à km 5 (45-50 min d'effort), mais aucune note sur le type exact (gel 30g sucres, dattes, banane). Pour un coureur intermédiaire qui n'a jamais fait 10 km, tester un gel est crucial. → **Fix** : ajouter « À tester en entraînement : 1 gel 30-40g glucides OU 3-4 dattes OU demi-banane. Ne jamais tester en W6 J5 pour la 1re fois. Si nausées : réduire à eau + électrolytes seuls. »

- **[W8 J3]** Visualisation mentale citée en cooldown, mais pas de guidage précis. Pour un autonome, une visualisation peut être anxiogène ou inefficace sans structure. → **Fix** : clarifier « Visualise : départ km 0-2 contrôlé (respire lentement), km 3-5 régulier (suis le plan de course), km 5-7 creux (tu ralentis légèrement si besoin, c'est normal), km 8-10 finish (tu accélères ou maintiens selon réserves). Durée : 3-5 min. »

## Issues mineures (nice-to-have)

- **[W1-W8]** Pas de mention de « test de parole » quantifié pour long run (contrôle RPE 5-6/10). W1 J3 et notes du plan citent « conversation complète » et « RPE 5-6 », mais pas de checklist rapide type « Si tu ne peux pas chanter, tu vas trop vite ». → **Amélioration** : ajouter « Test de parole rapide : long run = tu peux chanter quelques notes ou parler 10 secondes sans essoufflement. Si non, ralentis de 20-30 sec/km. »

- **[W2-W7]** Pas de notation explicite d'« effort perçu vs. montre GPS » (ex: « Si GPS affiche 6:45 min/km mais tu te sens à RPE 5/10, c'est OK »). Utile pour un autonome sans capteur de FC. → **Amélioration** : ajouter en guidance W2+ : « La montre peut laguer ou mesurer mal. Priorité 1 : RPE et test de parole. Priorité 2 : allure GPS. Si désaccord, fais confiance au ressenti. »

- **[W1 J1]** Nordic curl « assisté » mentionné 5 fois avec descriptions quasi identiques. Dépliage pédagogique : une image ou lien video serait utile (« cf. ressource : lien Nordic curl protocol »). Template JSON ne supporte pas les liens, mais un champ `video_reference` ou `technique_key` serait utile. → **Amélioration** : ajouter champ optionnel `technique_reference` pour renvoyer à une vidéo ou guide (non critique).

- **[W5-W8]** Pas de mention explicite sur le timing optimal de la séance de renforcement. Toutes les sessions mixtes placent renforcement après la course, mais pas de clarification sur « pourquoi pas avant ». → **Amélioration** : ajouter en safety_notes : « Renforcement toujours après le travail cardio (tempo, intervalles) : les jambes chauds récupèrent mieux, et tu n'affatigues pas les muscles avant la qualité. »

## Manques notables

- **Absence de guidance sur chaussures de remplacement** : le profil assume « chaussures en bon état < 600 km », mais aucune note sur quand (avant ou pendant le plan) faire une analyse de fouler ou essayer une paire. Plan de 8 sem + 17-30 km/sem = ~144-240 km → une paire peut être usée en fin de plan. → **Ajout recommandé** : « Avant W1 J1, fais analyser ta fouler dans un magasin spécialisé. Si tes chaussures atteignent 550-600 km pendant le plan, prévois une nouvelle paire 2 semaines avant, pour adapter la transition progressivement (50/50 avec l'ancienne paire sur 7-10 jours). »

- **Absence de protocole "reprise après interruption W1-W8"** : W1 assume « pratique 2×/semaine depuis au moins 2 mois », mais pas de dépannage si l'utilisateur a eu une pause inattendue (maladie, voyage) avant de commencer W1. → **Ajout recommandé** : ajouter en pré-amble ou guidance : « Si tu as eu > 2 sem de pause avant W1 : reprends 2 semaines avant le plan (footing 30 min 3×/sem). Si < 2 sem : tu peux commencer W1 directement. »

- **Absence de post-plan (W9+)** : W8 conclut le plan sans guidance sur « what's next ». Courir 10 km en 55-70 min, c'est achever l'objectif, mais pas changer de sport. → **Ajout recommandé** : ajouter post-script ou `post_plan_guidance` : « Après W8 : maintiens 1-2 séances/sem de 30-40 min d'endurance (long run réduit à 8-9 km + 1 tempo court ou fractionné léger). Si tu vises la compétition 10K, ajoute un 2e fractionné léger. Sinon, réduis à 2 séances/sem et laisse la flexibilité. »

- **Absence de tableau allures individualisé** : Les allures sont calculées selon un système Jack Daniels/VDOT adapté, mais pas de tableau pré-rempli (ex: « Si test 5K = X min, allure seuil = Y, allure 10K = Z »). Utile pour validation utilisateur. → **Ajout recommandé** : créer un tableau référence `pace_reference_table` avec 4-5 temps 5K types (24, 26, 28, 30, 32 min) et les allures dérivées.

- **Absence de plan B pour conditions météo** : Aucun dépannage sur « que faire si route gelée / 35°C » (changer allure ? distance ?). Risque surtout en W6-W8 long run 10-12 km. → **Ajout recommandé** : « Conditions extrêmes (< -5°C, > 30°C, neige, verglas) : réduire allure de 30-45 sec/km et réduire distance de 10-20%. Respecte ton corps avant le plan. »

## Scores (sur 10)

- Cohérence interne : 8.5/10
  - Durée déclarée (8 sem) ↔ weeks.count (8) ✓
  - Volume long run progression (6 → 7 → 8 → 9 → 7 → 10 → 11 → 12) cohérent avec annonce ✓
  - Cutback W5 effectif (intervalles -30%, tempo -28%, long run -22%) mais décalage vs. déclaration « -15% » ✗
  - Renforcement annoncé (nordic curl, single-leg squat, calf raises, clamshells) présent mais timing d'introduction (clamshells W2 vs. safety_notes W1) décalé ✗

- Alignement référentiel : 9/10
  - Structure 3 séances/sem (1 intervalles VO2max + 1 tempo/seuil + 1 long run) conforme ACSM/Hal Higdon ✓
  - Progression long run 6 → 12 km respecte règle « cible × 120% » (Higdon) ✓
  - Repo 75-90 sec (nordic, single-leg squat) aligné NSCA pour excentrique ✓
  - Tempo 20-32 min dans zone ACSM 20-40 min ✓
  - Intervalles 400 m-800 m à allure 5K conforme Jack Daniels ✓
  - Tapering W8 (réduction 40-60% volume, maintien intensité) conforme Mujika & Padilla ✓
  - Récupération 3 min entre 800 m (vs. 90 sec entre 400 m) physiologiquement juste ✓
  - Seul point faible : pas de décharge spécifique entre W7 et W8 (W7 est maintien volume, pas cutback avant tapering) — Hal Higdon le fait souvent ✗

- Sécurité : 8.5/10
  - Drapeaux rouges détaillés et précis (tendinopathie ischio, périostite tibiale, ITBS, PFPS, tendinopathie achilléenne, fasciite plantaire, cardio) ✓
  - Renforcement préventif justifié et placé (nordic curl W1 = ischio, single-leg squat W2 = PFPS/équilibre, clamshells = ITBS, calf raises = tendinopathie achilléenne) — excellente couverture ✓
  - 48h entre séances de même nature respecté (J1 intervalles, J3 tempo, J5 long run) ✓
  - Hydratation guidée (400-600 ml pré-séance, eau > 7 km) ✓
  - Nutrition long run détaillée (30-60 g/heure > 60-70 min) ✓
  - RPE spécifiées (long run 5-6, tempo 7, intervalles 8-9) ✓
  - Cadence cible mentionnée (170-180 pas/min) ✓
  - Signes surcharge bien listés (FC repos, courbatures, allure perte, sommeil, humeur, douleurs multiples) ✓
  - Points faibles : pas de guidance expérience chaussures (nouveau modèle → transition progressive), pas de plan météo extrême ✗

- Pédagogie : 8/10
  - Progression paliers réguliers (not brutale) : long run +1 km/sem (sauf cutback), tempo +2-3 min/sem, intervalles 400m → 5×400 → 3×800 → 4×800 → 5×800 = escalier clair ✓
  - Instructions claires (warmup détaillé, cooldown complet, notes par exercice) ✓
  - RPE/respiration/cadence chiffrées ✓
  - Checklist d'autonomie W8 présente mais mal formalisée (liste cachée en notes, pas de champ dédiée) ✗
  - Test de parole mention rapide (W1 J3 « phrases courtes 4-5 mots ») mais pas systématisé pour tout le plan ✗
  - Visualisation W8 mentionnée mais pas guidée précisément ✗
  - Absence de tableau allures de référence pré-calculé (utilisateur doit dériver seul) — possible erreur ✗
  - Absence de post-plan (W9+) guidance ✗

- **Global : 8.5/10**

---

**Synthèse d'implémentation** : Ce template est solide et prêt pour 95% de la production. Les corrections suggérées sont des affinage pédagogique (clarté allures, checklist formalisée, guidance post-plan) et une correction mineure sur le calcul de cutback (-15% déclaré vs. -30% réel). Aucun blocage médical ou physiologique.