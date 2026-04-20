# Challenge Report : velo-expert-cyclosportive-16sem

## Verdict
Template **bundlable avec réserves mineures**. Structure générale solide, alignement référentiel excellent, progression cohérente avec les standards ACSM/Coggan/WorldTour. Trois points critiques à adresser avant livraison : (1) incohérence mineure W12-W13 sur durée sortie longue, (2) absence de récapitulatif des zones recalculées post-FTP lisible en JSON, (3) manque d'une séance de repos complet explicite avant test FTP W9.

---

## Issues critiques (bloquantes pour bundle)

**Aucune issue critique bloquante détectée** au sens strict (pas d'erreur de sécurité immédiate, pas d'inversion de zones, pas de violation de la règle 48h).

---

## Issues importantes (à corriger avant bundle idéal)

- **[W9 J3 — Test FTP]** Protocole alternatif (3x5 min) cité dans les notes mais pas intégré en tant que variante structurelle du template. Si l'utilisateur échoue le 20 min standard (maladie, jambes bloquées), il n'y a pas de fallback clair en JSON. → **Fix proposé** : ajouter un champ optionnel `ftp_test_alternative: { protocol: "3x5min", ftp_calculation: "avg_power * 0.90" }` pour clarifier la route de secours.

- **[W9 J2]** La séance "Repos complet J-1 test FTP" indique "repos complet recommandé" mais laisse la porte ouverte à "marche optionnelle". Un jour avant un test FTP calibrant tout le bloc spécifique, il faudrait être plus directif : **repos absolument complet (< 2000 pas), pas de marche légère**. → **Fix proposé** : remplacer "optionnelle" par **"fortement déconseillée"** et ajouter une note : `"Repos complet strictement obligatoire. Toute activité (y compris marche) peut impacter la baseline cardiovasculaire et biaiser le test. Lire et relire le plan de course à la place."`

- **[W12 J7 — "Sortie longue pacing race intégral"]** Annonce "150-170 km, 2500-3200 m D+" mais duration_minutes = 300 (5h). Pour un cycliste expert, 150-170 km en montagne demande 7h-8h40 selon la route. 300 min = 5h semble optimiste et potentiellement dangereux (incite à un pacing trop agressif pour tenir le temps). → **Fix proposé** : remplacer `duration_minutes: 300` par `duration_minutes: 480` (8h réalistes) et noter dans les exercises : `"Durée estimée : 7h-8h selon terrain. Si tu ne peux pas tenir 7h+ : réduire à 130-150 km (5h)."` → clarifier aussi que le volume de 290 km hebdo est atteint avec des sorties plus courtes, pas en gonflant une séance.

---

## Issues mineures (nice-to-have)

- **[W1 J5 — "Technique et force basse cadence"]** Cadence annoncée "50-60 rpm" dans "Force basse cadence" mais notes précisent "700-75 rpm" sur bloc Z4. Confusion potentielle. → Clarifier : force = 50-60 rpm strictement, intervalle Z4 = 85-90 rpm, puis retour en force 70-75 rpm en montée réelle.

- **[W5 J1 — warmup]** "3 x 20 sec efforts Z5" cités en warmup immédiatement avant une séance Z4 de 45 min. Cela peut épuiser les reserves neuromusculaires avant le stimulus principal. → Meilleure pratique : limiter à "3 x 15 sec Z4" (pas Z5) ou espacer plus l'échauffement.

- **[Progression_logic — Zones Coggan]** Les trois exemples de zones fournies (260 W, 275 W, 295 W) sont utiles mais aucun n'est **interactif** ou **auto-calculable** dans l'app. Un utilisateur avec FTP=268 W devra faire le calcul manuel (réduit prise d'erreur). → Nice-to-have : ajouter une note : `"Pour tout FTP non listé, utiliser la formule générale à la fin du paragraphe (6) et vérifier votre calcul 2x avant W10."` (Note : c'est déjà dans le texte, validé).

- **[W14-W16 — Affûtage]** La note "sensation de jambes lourdes en W14 est normale" est excellente pour la compliance psychologique. Cependant, le template n'offre **aucune checklist** de warning signs qui devraient déclencher un repos supplémentaire (ex: FC de repos > +10 bpm vs baseline, fatigue persistante). → Suggestion : ajouter un encadré "SIGNAUX DE FATIGUE ANORMALE EN AFFÛTAGE" avec critères objectifs arrêt/repos supplémentaire.

---

## Manques notables

- **Tableau récapitulatif JSON des zones post-FTP** : le template fournit les formules et exemples en texte, mais pas de structure de données JSON post-test pour que l'app puisse **auto-afficher les zones converties dès W10**. Suggestion : ajouter un champ `recalibrated_zones` (calculé ou rempli par l'utilisateur) : `{ "z1": {"low": XX, "high": YY}, "z2": {...}, ... }`.

- **Tracking nutrition globale** : le plan cite "60-80 g glucides/h" ou "70-90 g glucides/h" selon la semaine mais ne fournit **pas de feuille de calcul ou de checklist nutrition simplifiée** (ex: "si tu pèses 75 kg et travailles à 280 W, consommer 75 g/h glucides"). Un utilisateur de 65 kg aurait peut-être besoin de 65 g/h. → Nice-to-have : ajouter une formule rapide ou une note `"Ajuster 60-80 g/h selon ton poids : ratio 1.0 g glucides / kg de poids corporel / heure est un bon départ."`.

- **Checklist pré-programme (semaine 0)** : le plan débute directement W1 sans "checklist de démarrage" type (vélo ajusté ? capteur calibré ? équipement de sécurité complet ?). Le safety_notes couvre `ÉQUIPEMENT CHECKLIST DÉBUT DE PLAN` en fin, mais elle devrait être **référencée dès le summary ou le week_number: 1**. → Suggestion : ajouter un `pre_week_checklist` avant W1.

- **Plan B météo complet** : safety_notes cite "privilégier un parcours alternatif" en pluie, mais ne propose **pas d'équivalent de sortie indoor/home trainer pour les séances Z4-Z5 longues** (ex: "si conditions > 60 km trop dangereuses en pluie : remplacer par une séance home trainer équivalente : 2x20 min Z4 vs sortie longue réduite"). → Suggestion pour affûtage (W14-W16) : ajouter alternative home trainer.

- **Articulation repos/surcharge en affûtage (W14-W16)** : les instructions disent "ne pas ajouter de volume par anxiété", très bon. Cependant, **aucune directive si l'athlète se sent *réellement* frais dès W14** (peut arriver). Faut-il alors rester au plan, ou autoriser une sortie supplémentaire légère ? → Ajouter : `"Si sensation de fraîcheur extrême en W14-J4 : une sortie Z1 supplémentaire de 40 min est acceptable, pas plus. Priorité : ne pas dépasser le total de 7h30 (W14) et 6h (W15)."`.

---

## Scores (sur 10)

- **Cohérence interne : 9/10**
  - ✓ duration_weeks (16) = weeks.count (16)
  - ✓ Progression_logic détaillée et vérifiable dans chaque week
  - ✓ Cutback weeks (W4, W9, W13) effectivement -15% à -20% vs précédent
  - ✓ RÈGLE 48H systématiquement rappelée et respectée
  - ✗ Léger : W12 duration_minutes de la sortie longue (300 min pour 150-170 km montagne) semble optimiste vs réalité terrain
  - ✗ Mineure : Pas de JSON post-FTP auto-calculé pour zones (mais formules fournies en texte)

- **Alignement référentiel : 9.5/10**
  - ✓ Polarisation 80/20 (Z1-Z2 vs Z3-Z5) conforme ACSM/Joe Friel
  - ✓ Zones Coggan correctement définies et appliquées
  - ✓ Progression seuil (2x10 → 3x15 → 2x20 → 2x25 split négatif) suit les standards NSCA/Stronger by Science
  - ✓ VO2max : 2x2 min → 5x4 min → 6x3 min → rappel 4x2 min → finale 4x2 min logique et complète
  - ✓ Force basse cadence (50-60 rpm) introduite W1 et maintenue = spécifique cyclosportive 3000+ m D+
  - ✓ Simulation de cols multiples (W10-W13) cohérente avec réalité
  - ✗ Mineure : Blocs VO2max pourraient inclure "cadence 95-100 rpm naturelle" plutôt que "libre" (plus prescriptif)

- **Sécurité : 9/10**
  - ✓ Drapeaux rouges couverts : douleurs lombaire, genou, tendon, paresthésies, palpitations, tendon d'Achille avec protocole cale
  - ✓ Règles position vélo (selle, reach, taquets) détaillées
  - ✓ Hydratation 500-1000 ml/h avec zones de température
  - ✓ Nutrition 60-90 g glucides/h avec exemple détaillé 8h
  - ✓ Géométrie descente (position aéro, cadence 100-110, poids pédales, freinage)
  - ✓ Signaux de surcharge (FC repos, RPE, sommeil, DOMS, maladies ORL)
  - ✓ Contingences météo adressées
  - ✗ Manque : pas de warning si athlète affûté début W14 mais stresse (risque d'excès)
  - ✗ Mineure : "repos complet J-1 test FTP" devrait être **absolument obligatoire** (actuellement "recommandé")

- **Pédagogie : 8.5/10**
  - ✓ Progression par paliers clairs (W1 base Z2 → W2 premiers seuils courts → W3-W4 consolidation → W5-W7 VO2max/seuil pic → W10-W13 spécifique race → W14-W16 affûtage)
  - ✓ Instructions exercices précises (cadence, RPE, puissance, repos)
  - ✓ Explications physiologiques (mitochondries, lipides, oscillations décrites)
  - ✓ Checklist autoévaluation post-course excellente (5 critères objectifs)
  - ✓ Notes de rupture de pattern claires ("ne pas partir trop vite W1-W2" vs "attaque finale W16")
  - ✗ Nutrition : formule "1.0 g glucides/kg/h" absente (utilisateur doit calculer)
  - ✗ Manque : feuille de calcul rapide zones post-FTP (formules fournies, pas d'outil)
  - ✗ Mineure : pas de "nutrition test protocol" détaillé avant W10 (cité mais pas formaté)

- **Global : 9/10**
  - **Verdict pour bundle** : template expert de très haute qualité, respecte les standards WorldTour adaptés amateur, sécurité exhaustive, progression incontestable.
  - **À corriger avant livraison** : (1) clarifier duration_minutes W12 J7, (2) rendre "repos J-1 FTP" obligatoire, (3) ajouter fallback FTP alternatif en JSON.
  - **À améliorer post-launch (v1.1)** : zones auto-calculées post-FTP en JSON, checklist nutrition par poids, warning affûtage paradoxe fraîcheur excessive.

---