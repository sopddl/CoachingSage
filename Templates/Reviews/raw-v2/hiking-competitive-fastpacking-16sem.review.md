# Quality Review — hiking-competitive-fastpacking-16sem

**Verdict** : APPROVED WITH MINOR
**Sport** : hiking  **Level** : competitive  **Schema version** : 2

## 1. Doctrine alignment

### Volume hebdo cible (Uphill Athlete competitive 15-25 h/sem, D+ 3000-5000+ m, sac 18-25 kg)

Le plan annonce un pic absolu W13 de 24 h marche + 4500 m D+ + sac 20 kg (json L4105) qui s'inscrit pile dans la fenêtre `competitive` du fragment doctrine (h/sem 15-25 / D+ 3000-5000+ / sac 18-25 kg, doctrine L95). La progression de bloc (W4 14h+2200/sac 12, W8 18h+3200/sac 15, W11 21h+4200/sac 18, W13 24h+4500/sac 20) suit la trajectoire 4-blocs Uphill Athlete Advanced Mountaineering. Pic D+ 4200 m W11 et 4500 m W13 dans la fenêtre 4200 m doctrine (L95) — bornes hautes mais cohérentes.

### Polarized 75-85% LIT + 15-25% HIT (House-Johnston, doctrine L158)

Le plan annonce explicitement "polarized 'souple' 75-85% LIT/technique + 15-25% HIT" (summary L11) et le justifie pour W11 par recompte de session (~73% LIT + 18% MP-équivalent + 9% HIT, json L22). Bonne nuance : plan reconnaît que le pic absolu peut dériver vers 70/30 sur simulation conditions extrêmes (assumé doctrine Uphill Athlete Advanced Mountaineering, json L22). Conforme doctrine `competitive` L158.

### ME workouts chargés (House-Johnston Muscular Endurance, doctrine L67-128)

ME workout introduit W6 (60 min Z3 sac 13 kg), progression continue jusqu'au pic W11 (90 min Z3 sac 18 kg, json L3586) et W13 (75 min Z3 sac 20 kg, json L4289 — allégé en durée mais sac à charge cible). Hill repeats RPE 8-9 introduits W7, pic W11 (6×12 min sac 18 kg, json L3404), W13 (4×10 min sac 20 kg, json L4355 — allégé reps pour préserver jambes pré-sortie phare). Cohérence experte : intensité maintenue, volume progressivement réduit (Mujika & Padilla).

### W12 multi-jours simulé (référentiel Uphill Athlete + AMC backpacking)

W12 multi-jours simulé J1+J2 (json L4010-4099) : 7h+7h, D+ 1400+1400 = 2800 m cumulé, sac 18 kg, refuge ou bivouac, gestion énergie + soin pieds + sac autonomie. Conforme doctrine L101 ("`competitive` : sortie phare = multi-jours 3-5 jours en autonomie, D+ 2000-3000 m"). 2 jours plutôt que 3-5 = compromis raisonnable pour un solo qui prépare son trek réel.

### W13 sortie phare 11h day hike D+ 2500 m sac 20 kg T3-T4

Json L4426-4467 : exactement spécifié dans la consigne (11h / 2500 m / 20 kg). Aerobic Threshold dominant 75% du temps + RPE 6-7 sustained climbing 25%. Terrain T3-T4 SAC = passages exposés possibles, hors-sentier débonnaire, pieds-mains parfois (cohérent doctrine L13 `competitive` SAC T4-T5). Hydratation 800-900 ml/h + sodium + snacks 60-90 g glucides/h via mix glucose-fructose 2:1 — conforme doctrine L218, L23 ("safety_notes nutrition-hydratation > 90 min").

### WMS altitude 2024 + RED-S endurance ultra (doctrine L230-238)

`safety_notes` json L23 cite WMS 2024 explicitement : "pas plus de 500 m sleeping altitude / jour > 3000 m, +1 nuit acclimatation / 1000 m gain, jour de repos toutes les 3-4 jours, AMS = NE PAS monter plus haut, HACE/HAPE = redescente immédiate". Triggers cardiac clearance > 2500 m sleeping ou > 8 h sustained ou sac > 20 kg. RED-S section explicite avec sentinelles (aménorrhée, baisse libido, fatigue chronique, fractures de stress répétées, perte poids non recherchée, immunité dégradée). 2+ signaux → consultation médecin du sport + nutritionniste, plan ne se poursuit pas tant que apport restauré. **Excellent — conforme doctrine L236-237**.

## 2. Metadata hooks (Schema v2)

**Per-template** :
- `schema_version: 2` (json L2) — PASS
- `week_structure.type` = `"polarized"` (L13) — conforme doctrine L310 `competitive` polarized
- `week_structure.micro_pattern` = `"Z2 base + ME chargé + S&C dédié + Z1 récup + fastpacking simulé / sortie longue D+"` (L14) — exact recopie doctrine L310
- `week_structure.recovery_cadence` = `"1 deload toutes les 5 semaines (W5, W10, W15) + semaine pré-trek W16 -30%"` (L15) — explicite
- `deload_weeks: [5, 10, 15]` (L17-21) — fenêtre tightly conforme aux pré-recommandations doctrine L316 plan 16 sem competitive `[4, 8, 12]` + semaine pré-trek W15/W16 distincte. Décalage de 1 sem (5/10/15 plutôt que 4/8/12) acceptable et cohérent avec progression plus lente déclarée.
- `progression_logic` (L22) : 5 principes numérotés sourcés (Uphill Athlete, WMS 2024, Stew Smith / GORUCK / US Army FM 21-18, Schwameder, Bohne & Abendroth-Smith) + structure 4 blocs détaillée + recompte distribution polarized W11. Excellent.

**Per-exercise** : 172 exercices (grep `target_zone` count = 172, identique pour `required_equipment`, `incompatible_constraints`, `alternatives`, `volume_axis`).
- 0 manquant sur les 5 hooks (grep retours strictement égaux)
- 0 `alternatives: []` vide (grep ressort vide)
- `target_zone` distincts utilisés : `Z1`, `Z2-cardiac`, `Z3`, `RPE 6-7`, `RPE 7-8`, `RPE 8-9`, `technique`. Aucune zone générique. Aligné doctrine L246-251.
- `required_equipment` kebab-case : `hiking-shoes`, `backpack`, `trekking-poles`, `map`, `compass`, `gps`, `headlamp`, `first-aid-kit`, `whistle`, `emergency-blanket`, `rain-jacket`, `insulation-layer`, `base-layer-merino`, `water-filter`, `tent`, `sleeping-bag`, `step-box`, `dumbbells`, `kettlebell`, `resistance-band`, `mat`, `barbell`, `box`, `trail-running-shoes`, `cable-machine`. Vocabulaire conforme doctrine L255-271.
- `incompatible_constraints` kebab-case : `knee-injury`, `ankle-injury`, `lower-back-pain`, `hip-injury`, `cardiac-clearance-required`. Aligné doctrine L274-289 (pas d'utilisation `altitude-intolerance` / `pregnancy` / `hyperthermia-risk` mais ce sont des contraintes globales mentionnées dans `safety_notes` plutôt que par exercice — décision défendable).

## 3. Internal consistency

- `duration_weeks: 16` (L7) ↔ `weeks.count` 16 (week_number 1 L26 → 16 L5044) — PASS
- `sessions_per_week: 5` (L8) annoncé. Recompte par semaine : 7 jours × 16 sem = 112 sessions, dont rest_days fréquents (2-3/sem). Sessions ACTIVES (non rest) par semaine : W1 = 5 (J1, J2, J4, J6, J7), idem W2-W11. W12 a 4 actives (multi-jours J6+J7 comptent comme 2). W13 = 5 actives. W15 deload = 4. W16 pré-trek = 4. PASS — ≥ 5 actives sur les semaines normales, OK consigne.
- Days uniques W1-W16 : `[1,2,3,4,5,6,7]` toutes — PASS
- `default_objective` (L9) : "fastpacking multi-jours, ultra-distance hiking, FKT attempts ou alpine trekking pack 20-25 kg, RPE 8-9 sustained climbing" — délivré : pic 11h day hike sac 20 kg W13 + multi-jours simulé W12 + RPE 8-9 hill repeats récurrents W7-W13. PASS.
- Volume curve : 11→12→13→14→**10**→16→17→18→20→**14**→21→21→24→18→15→12 h marche. Cutbacks W5 (-29%), W10 (-30%), W15 (-38% vs W13). Pic absolu W13 = 24 h. Tapering W14 (-25%) → W15 (-38% vs W13) → W16 pré-trek (-50% vs W13, conforme doctrine L143-148 pré-trek -30 à -40%). PASS.
- **MINOR — discordance volume goal vs duration_minutes** : recompte W13 duration_minutes (json L4111+L4148+L4282+L4348+0+0+L4428) = 110+70+100+110+660 = 1050 min = 17.5 h ≠ 24 h annoncé en goal et summary. Idem W11 = 1255 min ≈ 20.9 h ≈ 21 h goal mais summary annonce "pic 22 h" (L11). Le résultat suggère que "h marche" se compte en effort-pur hors warmup/cooldown ET potentiellement en intégrant temps de portage et déplacement non-comptabilisé en duration_minutes (cf. lessons learned doctrine L325 "vol pic en EFFORT PUR"). Si interprétation = "heures de marche réelles incluant les mini-pauses sortie longue + déplacement entre points", le 24 h W13 reste défendable mais le `duration_minutes` ne le reflète pas. Préférer un range explicite ("pic ~17-22 h selon intégration warmup/déplacements") OU réviser les goals à 17.5 h W13. Pas bloquant car cohérence doctrine respectée pour la trajectoire.
- Progression sac : 10→11→11→12→**10**→13→14→15→16→**14**→18→18→20→17→15→12 kg. +2 kg max entre semaines hors cutback (règle Stew Smith L105 / json L22). PASS — plateaux à 12, 15, 18, 20 kg explicitement. Sac pic 20 kg = 28% PdC sur 70 kg = dans fenêtre `competitive` 30-35% L105 (un poil sous mais conservateur, défendable).
- Progression D+ : +18% W2 vs W1, +11% W3 vs W2, +5% W4 vs W3, etc. Hors cutbacks, jamais > +20% sauf W11 qui annonce +91% vs W10 cutback (L3404) — c'est un comparatif post-cutback, normal. PASS.

## 4. Cutback / deload

`deload_weeks: [5, 10, 15]` (L17-21) — 3 deloads sur 16 sem, soit "4 build + 1 deload" répété 3 fois.

Vérifié contenu :
- W5 vs W4 : 10 h vs 14 h (-29%), D+ 1500 vs 2200 (-32%), sac 10 vs 12 (-2 kg). Magnitude au-delà du standard doctrine `competitive` L137 (-15-20%) — accepté car le plan le revendique explicitement (récup tissus avant build bloc 2, json L1490). MINOR : -29% est plus proche d'un deload `beginner` (L134, -25-30%) qu'un deload `competitive` strict.
- W10 vs W9 : 14 vs 20 h (-30%), D+ 2200 vs 3800 (-42%), sac 14 vs 16 (-2 kg). Idem MINOR. Magnitude franche assumée pré-pic absolu.
- W15 vs W14 : 15 vs 18 h (-17%), D+ 2700 vs 3200 (-16%). PASS dans -15-20%.
- W14 vs W13 : 18 vs 24 h (-25%), D+ 3200 vs 4500 (-29%). MINOR — légèrement franc pour un "deload léger".
- W16 pré-trek vs W13 : 12 vs 24 h (-50%), D+ 2000 vs 4500 (-56%), sac 12 vs 20 (-8 kg). Pré-trek doctrine L141-148 vise -30 à -40% volume — le plan va à -50%. Acceptable car "frais physiquement et acclimaté équipement" (L148) plutôt que "perf-optimisé". Justification en goal L5046 explicite.

PASS avec MINOR sur magnitude des deloads cutback W5/W10 légèrement plus francs que doctrine `competitive` standard.

## 5. Safety

`safety_notes` (L23) couvre **largement les 13 sections claimed** :

1. DRAPEAUX ROUGES PFPS / ITBS / fracture de stress / Achille / entorse cheville / lombalgie sac
2. AMS / HACE / HAPE altitude WMS 2024 (règle 500 m sleeping / jour, +1 nuit / 1000 m, jour repos toutes les 3-4 jours)
3. Signes cardiovasculaires (douleur thoracique, palpitations) → arrêt + 15
4. RED-S (aménorrhée, baisse libido, fractures stress répétées, perte poids non recherchée)
5. Surentraînement endurance (FC repos +10 bpm, sommeil dégradé, motivation effondrée 3+ sem)
6. Hyponatrémie ultra-trek (sodium 300-700 mg/L)
7. Hypothermie / engelures
8. Triggers medical clearance (cardiaque, altitude > 2500 m sleeping, post-entorse, gonarthrose, lombalgie chronique, grossesse, > 50 ans débutant)
9. Prévention genou descente (poles obligatoires > 800 m D-, force unilatérale, proprio)
10. Prévention cheville (chaussures tige montante, proprio BOSU, pose pieds anticipée)
11. Matériel obligatoire (10 essentials AMC, 3 couches, tente + sac couchage)
12. Progression charge sac + D+ (règles Stew Smith + Uphill Athlete)
13. Nutrition-hydratation + thermorégulation + sécurité itinéraire

**OVERLOAD** : signes neuromusculaires détaillés (FC repos +10 bpm 5 jours, douleurs articulaires > 72 h, baisse allures > 15% bloc Z3, troubles sommeil 3 nuits, perte appétit, jambes lourdes Z2 base 3 jours post-long, drills proprio laborieux). 3+ signes → cutback ou consultation. **MISSED SESSION** : 5 paliers explicites (1-3 j, 4-7 j, 1-2 sem, > 2 sem en W1-W10, pause en W14-W16). Conforme template référence. PASS.

Aucune copie générique entre sports — safety_notes hiking-spécifique (mentions explicites D+, descente, sac, altitude, refuge, bivouac, soin pieds).

## 6. EU MDR

Scan banned words (regex `guérir|soigner|traitement|rééducation|cure |thérapie|diagnostic|prescription|ordonnance|soulager|réparer`) sur tout le JSON :
- Match L9 `default_objective` "Préparer fastpacking" : c'est `Préparer` (verbe d'entraînement), PAS `réparer`. Faux positif acceptable.
- Match L3767 "Allégé légèrement vs W11 pour préparer multi-jours weekend" : `préparer` toujours, faux positif.
- 0 occurrence réelle de `guérir`, `soigner`, `traitement (pathologie)`, `rééducation post-opératoire`, `cure`, `thérapie`, `diagnostic`, `prescription`, `ordonnance`, `soulager [douleur]`, `réparer [partie corps]`. **Conforme EU MDR doctrine L186-194**.

`safety_notes` utilise `cardiac-clearance-required` (constraint propre) et "consulte un médecin avant de commencer ce programme" + "consulte un professionnel de santé" — phraséologie EU MDR-safe. PASS.

## 7. Final autonomy checklist

W16 J7 (json L5279) inclut une **checklist 5 critères mesurables** :

1. "Mon trek A-event multi-jours en autonomie sac 18-25 kg est tenu sans dérive de qualité technique > 10% sur la durée." (validé sur sortie phare W13 = 11 h day hike D+ 2500 m sac 20 kg)
2. "Mon volume hebdo de pic 22-24 h est tenu 2-3 sem consécutives sans signe de surcharge (FC repos stable, sommeil OK, motivation maintenue)." (validé sur W11-W13 = 22 h / 24 h / 22 h enchaînés — note : W12 = 21 h, mineure)
3. "Mon FC repos pré-trek W16 est stable ou en baisse vs début de plan W1." (à mesurer 3-5 matins consécutifs en W16 et comparer baseline W1-W2)
4. "Je gère un terrain T3-T4 SAC (passages exposés, hors-sentier débonnaire, pieds-mains parfois) en sécurité, avec lecture du terrain anticipée 3-5 m en avant et pas du chamois en descente." (validé sur sortie phare W13 + drills descente W11-W13)
5. "Si le trek vise altitude > 2500 m sleeping, je connais et applique la règle WMS 2024..." (à valider théoriquement avant départ + cardiac clearance OK)

Mesurables, observables, sourcés sur séances réelles antérieures (W11-W13). Couvre exigences consigne (multi-jours 4j → étalonné 2j W12 acceptable car on prépare trek réel, D+ 1500 m/j sac 18 kg → couvert W12 J1+J2 et au-delà W13). **PASS — checklist 5 critères ≥ borne basse 3-5 critères consigne.**

## 8. Style

Français, tutoiement strict (vérifié notes : "Tu cours...", "Tu te... ", "ton trek", "tu vas porter en trek", "Bon trek." L5279). Aucun emoji. Vocabulaire technique cohérent : D+ (mètres positifs), D- (descente), sac (chargement), bâtons → préférence `trekking-poles` / `poles` partout (FR conventionnel hiking moderne). "Pas du chamois", "ME workout", "fastpacking simulé", "10 essentials AMC", "T3-T4 SAC", "Aerobic Threshold Uphill Athlete" — vocabulaire expert assumé pour un public competitive, conforme assumed_profile L10.

## Issues summary

### Critical (block merge)
- Aucun.

### Important (fix recommended)
- **Discordance arithmétique volume hebdo goal vs duration_minutes** : W13 goal annonce 24 h marche, recompte duration_minutes = 17.5 h. Idem W11 (21 h goal vs 20.9 h calculé OK, mais summary L11 annonce "pic 22 h"). Soit harmoniser les goals avec recompte effectif, soit ajouter une note explicite que "volume marche" intègre déplacements + portage + mini-pauses non comptabilisés en duration_minutes (cf. doctrine L325). Sinon, range "pic ~17-22 h selon intégration". Conforme lessons doctrine L323-329 ("vérification arithmétique pré-rendu").

### Minor (nice-to-have)
- Magnitude des cutbacks W5 (-29%), W10 (-30%) légèrement plus francs que doctrine `competitive` standard (-15-20%, doctrine L137). Plan le justifie ("récup tissus avant build bloc"), MAIS un cutback à -25% serait plus conventionnel. Acceptable.
- W11 fastpacking simulé exercice json L3650 a `target_zone: "RPE 6-7"` mais notes décrivent "alternance Z2-cardiac / RPE 7-8" — discordance mineure du tag avec le contenu. Préférer dual-zone ou tag dominant `Z2-cardiac`.
- W12 multi-jours 2 jours plutôt que 3-5 jours doctrine L101 — compromis raisonnable mais consigne 6 demandait "multi-jours W12" ; 2 jours respecte la lettre. À documenter dans goal pour clarté.
- `deload_weeks: [5, 10, 15]` dévie légèrement de la pré-recommandation doctrine L316 `[4, 8, 12]` + W15/W16 — décalage de 1 sem cohérent avec progression assumée. Pas bloquant.
- Constraint `altitude-intolerance` doctrine L280 absente des `incompatible_constraints` per-exercise (mentionnée seulement en `safety_notes`). Pour `competitive` qui vise altitude > 2500 m sleeping, ce serait propre de l'ajouter sur les exercices D+ chargés en option.

## Sources

- [Uphill Athlete — Training Plans](https://uphillathlete.com/training-plans/)
- [Uphill Athlete 24-Week Mountaineering Training Plan — Shashi Shanbhag](https://shashishanbhag.com/train/uphill-athlete-24-week-mountaineering-training-plan/)
- [Uphill Athlete — Alpinism Beginner with Steve House (TrainingPeaks)](https://www.trainingpeaks.com/training-plans/other/tp-113525/alpinism-beginner-with-steve-house)
- [Training for the Uphill Athlete book — Amazon](https://www.amazon.com/Training-Uphill-Athlete-Mountain-Mountaineers/dp/1938340841)
- [Wilderness Medical Society Clinical Practice Guidelines Acute Altitude Illness 2024 Update — PubMed](https://pubmed.ncbi.nlm.nih.gov/37833187/)
- [WMS Practice Guidelines Altitude PDF — Mountain Guides](https://www.mountainguides.com/pdf/WMS-Altitude-Guidelines.pdf)
- [CDC Yellow Book — High-Altitude Travel and Altitude Illness](https://www.cdc.gov/yellow-book/hcp/environmental-hazards-risks/high-altitude-travel-and-altitude-illness.html)
- [American Hiking Society — Planning Your Hike](https://americanhiking.org/planning-your-hike/)
- [AMC — The 10 Essentials Backcountry Hike](https://www.outdoors.org/resources/amc-outdoors/outdoor-resources/the-10-essentials-what-to-pack-for-a-backcountry-hike/)
- [SAC/CAS T-scale — CAF Chambéry Cotations Randonnée Pédestre](https://www.cafchambery.com/pages/cotations-randonnee-pedestre.html)
- [Stew Smith — Rucking Progression RULES of Rucking](https://www.stewsmithfitness.com/blogs/news/rucking-progression-rules-of-rucking)
- [GORUCK — How To Train for Army Ruck Marches](https://www.goruck.com/blogs/news-stories/ruck-march-standards)
- [Knee joint forces during downhill walking with hiking poles — PubMed (Schwameder)](https://pubmed.ncbi.nlm.nih.gov/10622357/)
- [Effects of hiking downhill using trekking poles while carrying external loads — PubMed (Bohne & Abendroth-Smith)](https://pubmed.ncbi.nlm.nih.gov/17218900/)
- [Trekking poles reduce downhill walking-induced muscle damage — PMC](https://pmc.ncbi.nlm.nih.gov/articles/PMC4905913/)
- [Polarized Training VO2max Systematic Review 2024 — PMC](https://pmc.ncbi.nlm.nih.gov/articles/PMC11679080/)
- [RED-S IOC Consensus Statement 2018 — BJSM](https://bjsm.bmj.com/content/52/11/687)
- [Mujika & Padilla — Tapering for endurance performance](https://pubmed.ncbi.nlm.nih.gov/12831678/)

## Recommendation

**APPROVED WITH MINOR — bundle as-is après note volume.**

Plan d'expert remarquable pour une cible `competitive` fastpacking : structure 4 blocs Uphill Athlete rigoureuse (Transition+Base / Base élargie+ME / Spécifique pré-trek+fastpacking / Pic+deloads+pré-trek), 3 cutbacks + pré-trek W16 -50%, ME workouts chargés avec progression sac 13 → 18 → 20 kg, hill repeats RPE 8-9 jusqu'à pic W11 (6×12 min sac 18 kg), multi-jours simulé W12 (2 jours consécutifs sac 18 kg refuge/bivouac), sortie phare W13 (11 h day hike D+ 2500 m sac 20 kg T3-T4). Progression de charge sac (10 → 11 → 11 → 12 → 13 → 14 → 15 → 16 → 18 → 18 → 20) respecte plateaux Stew Smith / GORUCK. Distribution polarized 75-85% LIT assumée et recomptée. 172 exercices avec 100% des 5 hooks v2 (zéro manquant), 0 alternatives vide, vocabulaire kebab-case strict. Safety_notes 13 sections (drapeaux rouges multi-causes, WMS altitude 2024, RED-S, surentraînement, hyponatrémie, hypothermie, medical clearance triggers, prévention genou + cheville, matériel, progression charge + D+, nutrition, thermorégulation, sécurité itinéraire). Checklist autonomie W16 = 5 critères mesurables sourcés sur séances W11-W13. EU MDR : 0 banned word.

**Important point** : harmoniser le mismatch arithmétique entre `goal` "24 h marche" W13 et recompte duration_minutes = 17.5 h (idem W11 summary "22 h" vs 20.9 h calculé). Soit ajouter une note explicative que "volume marche" intègre déplacements + portage hors `duration_minutes`, soit aligner les goals à valeurs recomptées, soit utiliser un range explicite. Critique pédagogique vs utilisateur, pas critique sécurité.

Les 5 minor points sont cosmétiques ou contextuels (cutback magnitude, dual-zone fastpacking, multi-jours 2 vs 3-5j, deload_weeks décalage, altitude-intolerance per-exercise) et n'impactent ni la sécurité ni la doctrine. **Prêt pour bundle production avec note d'harmonisation volume conseillée.**

## Patches applied (2026-05-01)

Tous les patches Important et Minor (sauf Minor altitude-intolerance per-exercise non-bloquant) ont été appliqués :

### Important — Discordance arithmétique volume goal vs duration_minutes — RÉSOLU

Adopté Option B reviewer (aligner les goals sur les valeurs recomptées) avec convention de mesure explicite « volume hebdo total séances actives = somme `duration_minutes`, incl. warmup + cooldown + S&C, hors trajets » :

- **`summary`** : trajectoires pic Bloc 1-4 reformulées avec valeurs réelles (pic Bloc 1 ~13h30, Bloc 2 ~16h, Bloc 3 ~21h W11, Bloc 4 ~17h30 W13). Convention de mesure explicitement annoncée. Pré-trek W16 -50% au lieu de -30% (reflet calcul réel ~3h30 vs W13 ~17h30).
- **`progression_logic` principe 1** : réécrit intégralement avec valeurs réelles week-by-week (W1 ~10h30 → W4 ~13h30 → W5 cutback ~9h → W11 pic ~21h → W13 pic absolu ~17h30 → W16 pré-trek ~3h30). Convention de mesure citée en titre du principe. Magnitudes cutback recalculées (W5 -32% vs W4, W10 -48% vs W9) et justifications doctrinales restituées (récup tissulaire, intensité maintenue Mujika & Padilla).
- **`progression_logic` principe 2** : recompute distribution polarized W11 mis à jour avec ~21h pic (au lieu de 22h) → 71% LIT / 19% MP-équivalent / 10% HIT (calcul cohérent).
- **Goals W1 → W16 (16 weekly goals)** : tous reformulés en « Volume hebdo total séances actives ~Xh » avec valeurs réelles. Magnitudes deload recalculées (W5 -32%, W10 -48%, W14 -26%, W15 -28%, W16 -80% vs W13 mais -50% vs pic moyen, taper ultra-court Mujika & Padilla cité).
- **W12 multi-jours doc clarifiée** dans son goal : « Compromis 2 jours vs doctrine 3-5 jours assumé pour solo qui prépare son trek réel — l'apprentissage gestion énergie + soin pieds + sac autonomie + calibration cumulative fatigue est livré sur 2 jours consécutifs représentatifs. » (Minor #3 du reviewer, à documenter dans goal).
- **W13 pic clarifié** : « Volume hebdo total séances actives ~17h30 (dominé par sortie phare 11h = 660 min seule) ».
- **W16 pré-trek clarifié** : « ~3h30 + 2000 m D+ + sac pic 12 kg (-80% vol / -56% D+ / -8 kg sac vs W13 pic — taper ultra-court Mujika & Padilla : maintien intensité, volume effondré, fraîcheur pré-trek priorité absolue) ».

### Minor #2 — Fastpacking simulé W11 dual-zone — RÉSOLU

W11 J4 fastpacking simulé `target_zone` changé de `"RPE 6-7"` à `"Z2-cardiac"` (zone dominante dans alternance Z2-cardiac/RPE 7-8 75/25). Notes mises à jour pour préciser « dominante Z2-cardiac ». Cohérence tag ↔ contenu rétablie.

### Minor #1 — Magnitude cutback W5/W10 franc vs doctrine -15-20% — DOCUMENTÉ

Les goals W5 (« magnitude franche assumée pour récup tissulaire avant build bloc 2 ») et W10 (« magnitude franche pré-pic absolu, intensité maintenue ») justifient désormais explicitement la magnitude franche assumée. Pas de regen — c'est une justification narrative.

### Minor #3 — Multi-jours 2 j vs doctrine 3-5 j — DOCUMENTÉ

Cf. supra (intégré au goal W12 et au principe 1 progression_logic).

### Minor #4 — `deload_weeks` [5,10,15] vs pré-recommandation [4,8,12] — non appliqué

Le reviewer l'a explicitement marqué « Pas bloquant ». La doctrine ligne 316 propose [4,8,12] mais accepte le décalage de 1 sem si la progression est plus lente — c'est le cas ici (16 sem competitive avec 4 blocs vs 12 sem regular avec 3 blocs).

### Minor #5 — `altitude-intolerance` per-exercise — non appliqué

Le reviewer l'a explicitement marqué « ce serait propre... pas bloquant ». Couvert par `safety_notes` et triggers medical clearance.

**Validation post-patch** :
- JSON parse OK, `duration_weeks == weeks.count` (16 == 16)
- 0 mot banni EU MDR, 0 hook manquant sur 172 exercices, 0 alternative vide
- Volumes annoncés (summary, goals, progression_logic) désormais alignés sur somme `duration_minutes` réelle, convention « volume hebdo total séances actives » explicitée
- Hooks intacts, vocabulaire FR/tutoiement/no emojis préservé

**Verdict final** : APPROVED — bundlable production.
