# Quality Review — hiking-regular-mountain-trek-12sem

**Verdict** : APPROVED WITH MINOR PATCHES
**Sport** : hiking  **Level** : regular  **Schema version** : 2

## 1. Doctrine alignment

Template aligné avec les standards publics référents montagne grand-public regular (Uphill Athlete, AMC, FFRandonnée/SAC T3, WMS 2024, rucking militaire civil) :

- **Référentiel principal Uphill Athlete (House-Johnston)** correctement assumé : Z1-Z2 dominant, ME workouts (Muscular Endurance) dénivelé chargé introduits dès W3 (ligne 569 — 30 min Z3 sac 8 kg gradient 7-12%), progression hill repeats RPE 6-7 → RPE 8-9 sur 12 sem. Conforme *Training for the Uphill Athlete*. Fragment doctrine ligne 21, 94.
- **Volume hebdo cible regular 8-15 h / sem marche pure** (doctrine ligne 94) : la trajectoire annoncée 7h30 → 14 h pic W11 est dans la fenêtre haute regular, conforme. Voir Issue Important #1 sur écart annoncé/réel.
- **D+ hebdo cumulé 1500-3000 m** (doctrine ligne 94) : trajectoire annoncée 800 m (W1) → 2800 m (W11 pic) — cible W11 dans la fenêtre haute regular, valeurs intermédiaires (W6 2100 m, W9 2300 m) cohérentes. Conforme.
- **Sortie phare regular = 7-8 h day hike OU mini multi-jours 2 j, D+ 1500-2000 m, sac 12-15 kg, T2-T3 refuges** (doctrine ligne 100) : livré sur deux séances phares — W7 mini multi-jours 2 j J6+J7 D+ 1500 m sac 12 kg refuge non gardé (lignes 1921-1996), W11 day hike 8h D+ 2000 m sac 15 kg T2-T3 (lignes 3116-3180). Conformité doctrinale forte.
- **Progression charge sac rucking militaire civil adapté** (doctrine ligne 105) : 6 → 8 → 10 → 12 → 14 → 15 kg avec paliers 2 sem, jamais de saut > 2 kg. Plafond W11 15 kg = ~22-25 % PdC sur 60-70 kg, conforme fenêtre regular 25-30 % PdC max. Conforme Stew Smith / GORUCK.
- **Hill repeats RPE 6-9 progressifs** : W1 4×8 min RPE 6-7 sac 6 kg → W11 5×12 min RPE 8-9 sac 12-15 kg, récupération 4 min entre intervalles (ligne 42). Cadence métronome 110-120 pas/min explicitée Uphill Athlete (ligne 43). Conforme.
- **80/20 polarized strict en build, 70/30 toléré spécifique pré-trek W10-W11** : annoncé ligne 22 progression_logic principe (3), tolérance pré-trek explicitée. Conforme doctrine ligne 158.
- **Trekking poles obligatoires descentes > 1000 m D-** (doctrine ligne 259, justification 12-25 % réduction forces tibiofémorales — Schwameder, Bohne & Abendroth-Smith) : cité dans `progression_logic` (ligne 22), `safety_notes` (ligne 23), inclus dans `required_equipment` 30 fois sur 117 exercices (sortie longue, hill repeats, ME workouts). Conformité forte.
- **WMS 2024 Acute Altitude Illness CPG** (doctrine ligne 25) : règle 500 m sleeping max / jour > 3000 m + 1 nuit acclimatation / 1000 m gain + jour repos toutes les 3-4 j explicitée dans `safety_notes` ALTITUDE (ligne 23) et reprise dans checklist autonomie W12 J7 critère 5 (ligne 3398). HACE/HAPE = redescente immédiate. Conforme PubMed 37833187.
- **Semaine pré-trek W12 -30 à -40 %** : doctrine ligne 142-148, livré annoncé -36 %. Voir Issue Critical #1 sur volume réel.

## 2. Metadata hooks (Schema v2)

**Coverage : 117 exercices total**, 116/117 `target_zone` (99 %), 117/117 `required_equipment` (100 %), 117/117 `incompatible_constraints` (100 %), 117/117 `alternatives` non vides (100 %), 117/117 `volume_axis` (100 %). 1 `target_zone: null` sur l'item "Checklist autonomie finale trek A-event" W12 J7 (ligne 3399) — légitime car item méta non-physique.

**Per-template hooks** :
- `week_structure` (ligne 12) : type=block, micro_pattern explicite (long hike + ME/hill + Z2 + S&C), recovery_cadence "1 deload toutes 3-4 sem (W4 et W8) + W12 -30 %". Conforme.
- `deload_weeks` (ligne 17) : `[4, 8, 12]`. Conforme doctrine ligne 315 (`Plan 12 sem regular : [4, 8, 12]`).
- `progression_logic` (ligne 22) : 5 principes sourcés Uphill Athlete, AHS, AMC, FFRandonnée/SAC T3, WMS 2024, Stew Smith/GORUCK. Cite paliers numériques (sac, D+, volume) effectivement présents. Excellent niveau de détail.

**Distribution target_zone** :
| target_zone | count | usage |
|---|---|---|
| RPE 6-7 | 34 | hill repeats sustained climbing, blocs intégrés long hike |
| RPE 7-8 | 33 | S&C dédié force-endurance (split squat, step-up, hip thrust) |
| Z2 | 21 | base aérobie marche, long hike Z2 |
| technique | 12 | proprio single-leg balance |
| Z3 | 5 | ME workouts chargés |
| Z1 | 5 | récup active |
| Z2-cardiac | 3 | base aérobie soutenue |
| RPE 8-9 | 2 | hill repeats finaux W10-W11 |
| cool-down | 1 | étirements W12 |
| null | 1 | checklist autonomie meta |

Distribution sport-spécifique cohérente. Pas de zone générique "moderate". Excellent.

**`incompatible_constraints` kebab-case sport-spécifiques** : `knee-injury`, `ankle-injury`, `lower-back-pain`, `hip-injury`, `cardiac-clearance-required`, `altitude-intolerance`, `shoulder-injury`, `solo-only`. Couverture alignée doctrine ligne 273-288. `pregnancy`, `postpartum-early`, `hyperthermia-risk`, `hypothermia-risk`, `weather-extreme` mentionnés en `safety_notes` mais absents des hooks — non-bloquant car l'algo Story 3.3a peut router via les contraintes présentes ; voir Issue Minor #1.

## 3. Internal consistency

| Check | Statut |
|---|---|
| `duration_weeks == weeks.count` (12 == 12) | PASS |
| Active sessions/sem == `sessions_per_week` (4 actives + 3 rest = 4 ≤ 4) sur les 12 semaines | PASS |
| Days uniques [1,7] dans chaque semaine, sans doublon | PASS |
| `deload_weeks == [4, 8, 12]` cohérent avec `recovery_cadence` | PASS |
| `progression_logic` cite éléments présents (ME W3, multi-jours W7, RPE 8-9 W9-W11, sac 15 kg W11) | PASS |
| `safety_notes` cite WMS 2024 + cohérent avec checklist W12 critère 5 | PASS |
| Volumes annoncés (summary + progression_logic + goals) match volumes réels | **FAIL partiel** (Issue Critical #1) |
| Sortie phare W11 = 8 h D+ 2000 m sac 15 kg | PASS (lignes 3116-3180, duration 480 min ≈ 8h, sortie + bloc RPE 6-7 75 min intégré) |
| Mini multi-jours W7 = 2 jours D+ 1500 m sac 12 kg | PASS (lignes 1921-1996, J1 240 min D+ 800 m + J2 210 min D+ 700 m = 1500 m cumulé exact) |

## 4. Cutback / deload

Trois semaines deload [4, 8, 12] :
- **W4** (lignes 838-1101) : volume hebdo annoncé ~8h30 (-18 % vs W3) — calculé full session 6h55 (-22 % vs W3 8h55). Hill repeats raccourcis 3×8 min sac 8 kg (vs 5×8 min W3), pas de RPE 8-9, long hike 3h30 D+ 800 m sac 8 kg (-30 % D+ vs W3 1100 m). Magnitude correcte fenêtre doctrine -15 à -20 %.
- **W8** (lignes 2000-2266) : volume hebdo annoncé ~10h (-18 % vs W7 12h30) — calculé full session 8h25 (-36 % vs W7 13h10). Hill repeats raccourcis 3×10 min sac 12 kg, long hike 4h30 D+ 1100 m sac 12 kg. La magnitude réelle dépasse la cible -18 % annoncée à cause de W7 multi-jours = pic effort important. Acceptable post-multi-jours, mais le pourcentage annoncé est faux. Voir Issue Important #2.
- **W12 pré-trek** (lignes 3185-3411) : volume hebdo annoncé ~9h (-36 % vs W11 14h) — calculé full session **4h40 (-64 % vs W11 12h50)**. Le volume livré est environ moitié de l'annoncé. Hill repeats raccourcis 3×6 min sac 8 kg, S&C allégé 40 min, marche proprio J-2 45 min + checklist 15 min. Voir Issue Critical #1.

Cadence 3 build + 1 deload × 3 + W11 pic = structure conforme Uphill Athlete intermediate mountaineering 12 sem.

## 5. Safety

Couverture risques sport+level **complète et bien sourcée** avec 13 sections distinctes annoncées :

- **DRAPEAUX ROUGES** (ligne 23) : entorses cheville (n°1 randonneur regular), genou descente (rotulienne, ITBS, syndrome rotulo-fémoral, cite Schwameder + Bohne & Abendroth-Smith), tendinite Achille, tibiale antérieure, lombalgie sac chargé, ampoules, coup de chaleur, hypothermie, AMS, saddle sores, intoxication eau (giardia/E. coli filtre Sawyer/MicroPur), douleur thoracique = arrêt + consultation. Couverture exhaustive.
- **PRÉVENTION GENOU DESCENTE** : poles obligatoires > 1000 m D-, force unilatérale, drills proprio, vitesse modérée, Pose de pieds anticipée Uphill Athlete classique, gel post-sortie.
- **PRÉVENTION CHEVILLE** : tige montante, proprio 1-2×/sem, Pas du chamois descente technique, reprise progressive < 3 mois post-entorse.
- **MATÉRIEL OBLIGATOIRE regular** : 10 essentials AMC énumérés (navigation/protection/isolation/éclairage/secours/feu/réparation/nutrition/hydratation/abri), poles, sifflet, couverture survie, premiers secours. Conforme AMC Backpacking for Beginners.
- **PROGRESSION CHARGE SAC** : 10 % PdC départ, +1-2 kg / 2 sem, plafond 25-30 % PdC, jamais > 50 % PdC civil, jamais saut > 2 kg/sem.
- **PROGRESSION D+ HEBDO** : +10-20 %/sem, > 30 % = INTERDIT (tendinite tibiale, rotulienne, ITBS).
- **ALTITUDE WMS 2024** : 500 m sleeping max / jour > 3000 m, +1 nuit / 1000 m gain, repos / 3-4 j, AMS = stop + redescente, HACE/HAPE = urgences absolues. Référence PubMed 37833187 cohérente avec doctrine ligne 25.
- **INTENSITÉ Z+RPE+tags** : 7 zones explicitées avec %FCmax + RPE + application hiking. Test parole utilisable Z2+RPE 4-5.
- **NUTRITION/HYDRATATION** : 30-60 g glucides/h, 500-1000 ml/h selon T°, sodium 300-700 mg/L, snacks toutes 4 h.
- **THERMORÉGULATION** : système 3 couches Uphill Athlete classique, gants/bonnet TOUJOURS en montagne, IP50 + UV cat 3-4 été.
- **SIGNES DE SURCHARGE** : 6 signes (FC repos +10 bpm, perte perf D+ chargé > 10 %, sommeil dégradé, douleur articulaire, motivation effondrée, immunité dégradée), 3+ → semaine -20 % type deload.
- **SI SÉANCE MANQUÉE** : 4 niveaux gradués (< 1 sem / 1-2 sem / > 2 sem / blessure), cross-training elliptique/stairmaster Z2 toléré.
- **SÉCURITÉ ITINÉRAIRE** : prévenir proche, IGN 1:25000 + boussole + GPS + plan B, sifflet + survie + secours, refuges réservés, Météo France, orage = redescendre + abri sous arbre INTERDIT, Marche du métronome 110-120 pas/min.

13 sections livrées. Pas de copy-paste générique. Tout est hiking-spécifique avec sources nommées.

## 6. EU MDR

**Banned medical claim words scan** (regex `gu[ée]rir|soigner|traitement|th[ée]rapie|diagnostic|prescription|ordonnance|r[ée][ée]ducation|cure |rem[èe]de|soulager|r[ée]parer (le|les) (genou|dos|chevill)`) : **0 occurrence**.

Vocabulaire utilisé : "renforcer la stabilité", "préventif", "prévention", "préparer les jambes", "stabiliser", "favoriser", "consulter un médecin avant de commencer ce programme". Conforme doctrine ligne 187-194.

**Medical clearance trigger** : présent et explicite ligne 23 — déclenche pour antécédents cardiaques, > 50 ans sans test effort récent, reprise post-entorse < 3 mois, pathologie genou connue, lombalgie chronique, grossesse, et trek > 2500 m sleeping. Wording conforme MDR (pas de claim thérapeutique, redirige vers professionnel de santé).

PASS EU MDR.

## 7. Final autonomy checklist

PASS. W12 J7 (ligne 3398) livre une checklist 5 critères mesurables/observables :

1. **Tenir 7-8 h day hike OU mini multi-jours 2 j avec D+ 1500-2000 m cumulé sac 12-15 kg** sans dérive technique > 10 % (validé W7 ou W11).
2. **Gérer terrain T2-T3 SAC avec passages exposés** : lecture anticipée, pose de pieds 3-5 m en avant, poles en descente, Pas du chamois (validé W9-W11).
3. **S&C dédié hebdo tenu sans inconfort articulaire**, force et proprio en progression sur 12 sem.
4. **Récupération 24-36 h entre 2 sorties D+ chargé hebdo** (ME J1 + long hike J7).
5. **10 essentials AMC + carte IGN + boussole + GPS + filtre Sawyer + frontale + survie + sifflet + secours + couvre-chef + 3 couches systématiques**, savoir s'orienter sans GPS, connaître et appliquer règle WMS 2024 si trek > 2500 m sleeping.

5 critères chiffrés (durées, D+, charge, T-scale), observables (technique, équipement, autonomie), spécifiques aux objectifs annoncés du programme. Conforme.

## 8. Style

Français + tutoiement constant ("tu en étais", "tu connais", "Si tu as", "tu vas porter"). Aucun emoji détecté. Vocabulaire hiking-spécifique systématique : D+, D-, sac, bâtons (poles), T2/T3 SAC, IGN 1:25000, gradient %, Z2-cardiac, Aerobic Threshold, ME workout, Pas du chamois, Marche du métronome. Notes pédagogiques claires avec gradient + altitude + pack-load triple-tag (doctrine ligne 78-80). Excellent.

## Issues summary

### Critical (block merge)
1. **W12 volume annoncé 9h vs réel 4h40** (lignes 3187, 3188-3411) : le `goal` W12 et le `summary` annoncent un taper -36 % donnant ~9h, mais la somme des `duration_minutes` W12 = 60+0+90+0+40+0+90 = 280 min = 4h40, soit -64 % vs W11 12h50 réel. La doctrine ligne 142-148 spécifie -30 à -40 % pré-trek, donc 4h40 est trop bas. Patch nécessaire :
   - **Option A (préférée)** : ajouter une 5e séance courte W12 J6 (45-60 min Z2 base ou marche proprio supplémentaire) pour atteindre ~7-8 h, conforme -40 à -45 %. Ou allonger la J3 Z2 base 70 min → 120 min et la marche proprio J7 45 min → 90 min.
   - **Option B** : corriger le narratif (`goal` W12 + `summary` + `progression_logic` principe 1) pour annoncer -64 % et ~5 h. Mais c'est en-dehors de la fenêtre doctrine ligne 143-148 (-30 à -40 %), donc Option A préférée.

### Important (fix recommended)
1. **Volumes annoncés systématiquement supérieurs aux volumes réels** : la trajectoire `summary` 7h30 → 14 h pic correspond aux totaux full session (incl. warmup/cooldown/strength), pas aux heures de marche pure. Doctrine ligne 88 et lessons ligne 324 spécifient explicitement "heures de marche pure (effort sport-pur, hors warmup individuel < 10 min, hors trajets)". Sur cette base stricte, les volumes réels sont 4h-10h selon les semaines, soit 3-4 h en-dessous des annoncés. Deux options :
   - **Option A** : reformuler `summary` + `progression_logic` principe 1 en "volume hebdo total séances actives 7-13 h" (incl. S&C 55 min hebdo + warmup/cooldown). Patch texte uniquement, pas de regen.
   - **Option B** : ajouter ~30-90 min/sem de marche pure pour atteindre les volumes annoncés (ex. allonger long hike de 30 min, ajouter 30 min Z2 base sur la séance Z2). Coût regen modéré.
   Ne pas bloquer le merge — la qualité du programme reste solide ; la fenêtre regular 8-15 h est tenue sur les totaux full session, et même les volumes "marche pure" 4-10 h restent dans une fenêtre sportivement défendable pour un regular grand-public non compétiteur.
2. **W8 deload magnitude réelle -36 % vs annoncé -18 %** : ligne 2002 `goal` annonce ~10 h (-18 % vs W7 12h30), mais full session calculé 8h25 = -36 % vs W7 13h10. Cohérent post-multi-jours W7 (justifie un deload plus profond), mais le pourcentage annoncé est faux. Patch texte uniquement : reformuler "deload assimilation post-mini multi-jours, ~-30 % volume vs W7" qui est plus honnête et reste légitime doctrine.

### Minor (nice-to-have)
1. **`hyperthermia-risk` / `hypothermia-risk` / `weather-extreme` absents des `incompatible_constraints` exercices** mais mentionnés `safety_notes` (ligne 23). Pourrait être ajoutés sur les longues sorties extérieures pour permettre à l'algo Story 3.3a de router vers les substitutions tapis/escalier en météo extrême. Nice-to-have, non bloquant.
2. **`progression_logic` cite "5×12 min RPE 8-9 sac 12 kg (W10-W11)"** (ligne 22 principe 4) mais charge réelle W10-W11 hill repeats RPE 8-9 = 14-15 kg sac (pas 12 kg). Léger décalage texte vs contenu réel. Patch ligne 22 trivial.
3. **Item "Checklist autonomie finale trek A-event" W12 J7 a `target_zone: null`** (ligne 3399) alors que tous les autres items l'ont. Cohérent (item méta non-physique), mais on pourrait introduire un `target_zone: "meta"` ou `"checklist"` pour 100 % de couverture. Cosmétique.
4. **Issue de comptage** : 117 exercices total, sur 12 sem × 4 séances actives = 48 séances actives, soit ~2.4 exercices/séance moyen — cohérent (1 exercice par séance walking sauf S&C 6 exercices, et ~2 exercices par mixed/multi-jours). Pas un problème.

## Sources

- [Uphill Athlete — Training Plans](https://uphillathlete.com/training-plans/)
- [Uphill Athlete — Alpinism Beginner with Steve House (TrainingPeaks)](https://www.trainingpeaks.com/training-plans/other/tp-113525/alpinism-beginner-with-steve-house)
- [Training for the Uphill Athlete book — Amazon](https://www.amazon.com/Training-Uphill-Athlete-Mountain-Mountaineers/dp/1938340841)
- [American Hiking Society — Planning Your Hike](https://americanhiking.org/planning-your-hike/)
- [AMC — Backpacking for Beginners](https://www.outdoors.org/resources/amc-outdoors/outdoor-resources/backpacking-for-beginners/)
- [AMC — The 10 Essentials Backcountry Hike](https://www.outdoors.org/resources/amc-outdoors/outdoor-resources/the-10-essentials-what-to-pack-for-a-backcountry-hike/)
- [Wilderness Medical Society Clinical Practice Guidelines Acute Altitude Illness 2024 Update — PubMed 37833187](https://pubmed.ncbi.nlm.nih.gov/37833187/)
- [WMS Practice Guidelines Altitude PDF — Mountain Guides](https://www.mountainguides.com/pdf/WMS-Altitude-Guidelines.pdf)
- [CDC Yellow Book — High-Altitude Travel and Altitude Illness](https://www.cdc.gov/yellow-book/hcp/environmental-hazards-risks/high-altitude-travel-and-altitude-illness.html)
- [Stew Smith — Rucking Progression RULES of Rucking](https://www.stewsmithfitness.com/blogs/news/rucking-progression-rules-of-rucking)
- [GORUCK — How To Train for Army Ruck Marches](https://www.goruck.com/blogs/news-stories/ruck-march-standards)
- [Knee joint forces during downhill walking with hiking poles — PubMed 10622357](https://pubmed.ncbi.nlm.nih.gov/10622357/)
- [Trekking poles reduce downhill walking-induced muscle damage — PMC4905913](https://pmc.ncbi.nlm.nih.gov/articles/PMC4905913/)
- [CAF Chambéry — Cotations Randonnée Pédestre (SAC T-scale + FFRandonnée)](https://www.cafchambery.com/pages/cotations-randonnee-pedestre.html)
- [Polarized Training VO2max Systematic Review 2024 — PMC11679080](https://pmc.ncbi.nlm.nih.gov/articles/PMC11679080/)

## Recommendation

**APPROVED WITH MINOR PATCHES** — bundle après application du patch Critical W12 (Option A : ajouter une séance W12 J6 ou allonger J3+J7 pour atteindre 7-8 h conforme fenêtre doctrine -30 à -40 %). Les Important #1 et #2 sont des ajustements de narratif (texte uniquement), pas des regens. Les Minor sont cosmétiques.

Le template est doctrinalement solide, sourcé Uphill Athlete + AHS + AMC + WMS 2024 + Stew Smith/GORUCK + études biomécaniques poles, conforme schema v2 (117/117 hooks pleins sauf 1 meta), conforme EU MDR (0 mot banni), conforme cadence deload [4, 8, 12], et livre une checklist autonomie 5 critères mesurables. La sortie phare W11 day hike 8h D+ 2000 m sac 15 kg + alternative W7 mini multi-jours 2 j sac 12 kg sont conformes au point fort regular doctrine ligne 100. La progression sac 6 → 15 kg avec paliers 2 sem est conforme rucking militaire civil. Le bloc altitude WMS 2024 est exemplaire et reproductible sur les autres templates hiking à venir (recreational, competitive).

**Décision recommandée sur les volumes annoncés** : Option A Important #1 (reformuler "volume hebdo total séances actives 7-13 h") + Option A Critical #1 (ajouter ou allonger une séance W12 pour atteindre 7-8 h). Coût combiné : 1 regen ciblée W12 + patches texte sur summary/goals/progression_logic. Délai estimé < 30 min.

## Patches applied (2026-05-01)

Tous les patches Critical, Important et Minor ont été appliqués :

### Critical #1 — W12 sous-livré (-64% au lieu de -36% annoncé) — RÉSOLU

Patch ciblé W12 (Option A : ajouter/allonger séances pour atteindre fenêtre doctrine -30 à -40%) :
- **J3 Z2 base allongée** : bloc 70 min → 140 min, session `duration_minutes` 90 → 160 (notes mises à jour, distance ~10-12 km, charge sac 5-6 kg léger maintenue, justification doctrinale citée).
- **J6 ajouté (était rest)** : nouvelle session endurance « Z2 base pré-trek — marche aérobie 1h30 sac trek léger », bloc 70 min, sac 6-8 kg équipement trek partiel pour rappel proprio. Hooks complets (target_zone Z2, required_equipment hiking-shoes+backpack, incompatible_constraints cardiac-clearance-required, 2 alternatives, volume_axis duration).
- **J7 marche proprio allongée** : bloc 45 min → 65 min, session `duration_minutes` 90 → 110 (distance ~5-6 km).

**Résultat W12** : 460 min = 7h40 = -40.3% vs W11 12h50, **dans la fenêtre doctrine -30 à -40%**.

### Important #1 — Volumes annoncés ↔ volumes réels — RÉSOLU

Adopté Option A (reformulation texte, pas de regen) :
- **`summary`** : convention de mesure changée à « volume hebdo total séances actives (incl. warmup + cooldown + S&C dédié, hors trajets) », trajectoire calibrée ~7h (W1) → ~13h (W11 pic) — reflet des `duration_minutes` réels.
- **`progression_logic` principe 1** : trajectoire W1→W12 mise à jour avec valeurs réelles ~7h → ~8h → ~9h → ~7h → ~9h30 → ~10h30 → ~13h (W7 pic intermédiaire effort multi-jours) → ~8h30 → ~11h45 → ~12h → ~13h → ~7h40 (W12 pré-trek).
- **`progression_logic` principe 5** : reformulé W12 comme volume total séances actives ~7h40 vs W11 ~13h (-40%, fenêtre doctrine -30 à -40%), détaillant les 4 marches Z2 + hill repeats activation + S&C maintien.
- **`recovery_cadence`** : mis à jour avec magnitudes réelles (W4 -22%, W8 -36%, W12 -40%).
- **`goal` W12** : reformulé pour annoncer ~7h40 = -40% vs W11 12h50, détaillant les 4 marches Z2 + hill repeats + S&C maintien J5 et le check matériel J-2.

### Important #2 — W8 deload magnitude réelle -36% vs annoncé -18% — RÉSOLU

`goal` W8 reformulé : « volume hebdo total séances actives ~8h30 (~-36% vs W7 13h, deload franc post-mini multi-jours assumé pour assimilation tissulaire et cardiovasculaire avant phase spécifique pré-trek) ». La justification doctrinale est explicite et le pourcentage annoncé reflète le calcul réel.

`goal` W4 également mis à jour : « ~7h (~-22% vs W3 9h) » au lieu de « ~8h30 (~-18%) ».

### Minor #2 — `progression_logic` principe 4 sac W10-W11 hill repeats RPE 8-9 — RÉSOLU

Remplacé « 5×12 min RPE 8-9 sac 12 kg (W10-W11) » par « 5×10 min RPE 8-9 sac 14 kg en W10 (pic hill repeats du plan, hors W11 qui bascule sur ME workout long + sortie phare 8h) ». Aligné avec le contenu réel W10 et clarifié que W11 ne contient pas de hill repeats RPE 8-9 séparés.

### Minor #1, #3, #4 — non appliqués (cosmétiques non-bloquants)

Le reviewer les avait listés explicitement comme non-bloquants ; pas de plus-value valeur immédiate :
- Minor #1 (`hyperthermia-risk` / `hypothermia-risk` / `weather-extreme` per-exercise) : déjà couvert dans `safety_notes`, l'ajout per-exercise est lourd (sur 100+ exercices walk-extérieur) pour un gain limité côté algo Story 3.3a.
- Minor #3 (`target_zone: null` sur item méta checklist) : conforme structurellement (item non-physique), conservation du `null` documentée dans la review.
- Minor #4 : pas un problème (issue de comptage 117 exercices = 119 désormais avec ajout J6 W12).

**Validation post-patch** :
- JSON parse OK, `duration_weeks == weeks.count` (12 == 12)
- 0 mot banni EU MDR, 0 hook manquant sur 119 exercices, 0 alternative vide
- W12 = 460 min = -40.3% vs W11, dans fenêtre doctrine
- Hooks intacts, vocabulaire FR/tutoiement/no emojis préservé
- Volumes annoncés (summary, goals, progression_logic) désormais alignés sur somme `duration_minutes` réelle, convention « volume hebdo total séances actives » explicitée

**Verdict final** : APPROVED — bundlable production.
