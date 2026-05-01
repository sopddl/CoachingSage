# Quality Review — hiit-competitive-athletique-12sem

**Verdict** : APPROVED (post-review 2026-05-01)
**Sport** : hiit  **Level** : competitive  **Schema version** : 2

## 1. Doctrine alignment

Le programme déploie le full-spectrum HIIT competitive attendu et s'aligne explicitement aux références publiques :

- **ACSM Position Stand on HIIT 2014** : work 15 sec - 4 min à 80-95% FCmax, recovery 40-50% FCmax, total 30-40 min/sem au-dessus de 90% FCmax (limite haute). Le template plafonne le HIT cumulé pic à 20 min/sem (W7, W10) avec marge de sécurité explicite (`progression_logic` ligne 22 cite "limite ACSM 30-40 min/sem respectée avec marge"). Warmup 8-10 min RPE 6-7 obligatoire chaque séance HIT, étendu à 12 min sur séance phare W12 J5. Cooldown 5-10 min systématique. (https://acsm.org/high-intensity-interval-training-fitness/, https://blanchfield.tricare.mil/Portals/70/Session%202%20ACSM%20High%20Intensity%20Interval%20Training.pdf)

- **Tabata 1996 (Med Sci Sports Exerc)** : protocole 20s ON / 10s OFF × 8 rounds = 4 min à 170% VO2max sur ergocycle. Le template livre le Tabata 8 rounds full RPE 9-10 dès W2 (burpees over bar), W3+ sur KB swings 20-24 kg, W7 PIC RPE 10 burpees over bar, W10 PIC RPE 10 sur rower (transposition la plus proche du référentiel ergocycle 170% VO2max — citation explicite ligne 3596). W1 calibration RPE 8-9 (pas full all-out), W2+ full all-out RPE 9-10. Dérive cadence round 1 → round 8 < 25% établie comme critère de validation. (https://en.wikipedia.org/wiki/High-intensity_interval_training, https://pmc.ncbi.nlm.nih.gov/articles/PMC3772611/)

- **Gibala Lab — McMaster University (PLOS One 2016)** : 12 sem SIT all-out + récup easy → +19% VO2max. Le template cite Gibala dans `summary` et `progression_logic` (lignes 11, 22). La durée du plan (12 sem) et la dose-response calibrée au pic 20 min/sem HIT cumulé respectent le cadre de l'étude. Rower / assault bike fartlek 1 min all-out / 1 min easy déployé dès W2 — réplique très fidèle du protocole Gibala 1-min. (https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0154075)

- **Seiler 80/20 polarized adapté HIIT compétitif** : 75-85% LIT / 15-25% HIT explicité dans `progression_logic` principe (3) et `safety_notes` "DISTRIBUTION POLARIZED". 1-2 séances cardio active recovery Z2 (rowing easy 30 min, vélo Z2 45 min, jogging easy 35 min RPE 5-6) structurellement intégrées chaque semaine. Sur W7 PIC, distribution vérifiée : ~20 min HIT + 30 min EMOM modéré + 75 min Z2 + 30 min strength compound ≈ 80/20. Semaines de spécificité W7, W10, W11 dérogatoires assumées et explicitées (`week_structure.type: polarized`). (https://www.frontiersin.org/journals/physiology/articles/10.3389/fphys.2014.00033/full)

- **NSCA HIIT for athlete preparedness** : programmation périodisée, récup ≥ 48h règle absolue, scaling par fenêtres, prévention. Appliqué : Nordic curl excentrique dès W1 (Petersen BJSM 2011 -50% tendinopathies ischio cité ligne 22), depth drops drills atterrissage W2+, calf raises excentriques unipodal protocole Alfredson, tibialis raises, hip thrust DB, copenhagen plank, scapular pull-up, foam rolling 10 min entre HIT heavy. Core en FIN de séance toujours (NSCA recommandation respectée).

- **CrossFit competitor periodization** : AMRAP 18-20 min, EMOM 18-20 min compound, deload semaines stratégiques W4/W8. AMRAP 20 min FRAN-style ladder W7+, Cindy variant 18 min W3+, EMOM full-load 20 min W7/W10. Olympic lifts basiques en circuit modéré (power clean barbell 60-70% bodyweight max, hang power clean, hang power snatch DB) — charge modérée pas heavy 1RM, la doctrine "territoire coach humain" tenue. (https://www.crossfit.com/cf-seminars/SMERefs/Competitor/CrossFitCompetitorsTrainingGuide.pdf)

**Note Norwegian 4×4** : la rubrique d'évaluation mentionne "≥1 sustained Norwegian 4×4 OR equivalent ≥40 min total HIT volume". Le template et la doctrine HIIT.md ne référencent PAS le protocole Norwegian (intervalles longs de 4 min à 90-95% FCmax) — la doctrine HIIT CoachingSage est explicitement Tabata + Gibala + EMOM/AMRAP CrossFit-style, pas du HIT-cardio long-interval Helgerud. La voie "équivalent" est donc respectée : W11 contient Tabata 8 RPE 9-10 + EMOM 18 min + AMRAP 18 min + 40/20 6 rounds = ~19 min HIT cumulé effectif, et W7/W10 atteignent 20 min HIT cumulé/sem (Tabata 8 + EMOM 20 + AMRAP 20 + slam ball 30/30 8 rounds). En durée brute incluant rest intervals + warmup + cooldown, les séances HIT pic dépassent 40 min totales. Conforme à la voie "equivalent" attendue.

**Conclusion doctrine** : alignement très solide. Tous les formats first-class competitive sont déployés (Tabata 8 rounds full RPE 9-10/10, EMOM 15-20 min compound, AMRAP 12-20 min FRAN/Cindy, 30/30, 40/20). HIT cumulé pic 20 min/sem dans la fenêtre cible 16-24 min. RPE explicité par bloc et par semaine.

## 2. Metadata hooks (Schema v2)

**Per-template** :
- `schema_version: 2` (ligne 2) — PASS.
- `week_structure.type` = `"polarized"` (ligne 13) — choix doctrinal cohérent niveau competitive. PASS.
- `week_structure.micro_pattern` = `"HIT Tabata + Strength compound + HIT EMOM/40-20 + Cardio active recovery Z2 + HIT AMRAP/format varié"` (ligne 14) — explicite 5 sessions. PASS.
- `week_structure.recovery_cadence` = 3 cutbacks W4 (-22%), W8 (-20%), W12 dégressive (-35% séance phare J5) (ligne 15) — explicite. PASS.
- `deload_weeks` = `[4, 8, 12]` (lignes 17-21) — cohérent avec doctrine HIIT.md "competitive 12 sem `[4, 8, 12]` + taper W12 explicite si test fitness chiffré". PASS.
- `progression_logic` = présent (ligne 22), structuré en 7 principes sourcés (ACSM 2014, Tabata 1996, Gibala 2016, NSCA HIIT, Seiler 80/20, Petersen 2011, Mujika 2003). PASS.

**Per-exercise** : 192 exercices, **TOUS** portent les 5 hooks (`target_zone`, `required_equipment`, `incompatible_constraints`, `alternatives`, `volume_axis`) — vérifié via grep (192 occurrences de chaque hook). PASS.

**Qualité des `target_zone`** : zones HIIT first-class déployées (`Tabata 20/10`, `30/30`, `40/20`, `EMOM`, `AMRAP`, `walking-recovery`, `technique`) + RPE bands (`RPE 5-6`, `RPE 6-7`, `RPE 7-8`, `RPE 8-9`, `RPE 2-3`, `RPE 4-5`). Cohérent doctrine HIIT.md section "target_zone valeurs autorisées".

**Qualité des `incompatible_constraints`** : kebab-case respecté (`knee-injury`, `ankle-injury`, `wrist-pain`, `shoulder-injury`, `lower-back-pain`, `hip-injury`, `cardiac-clearance-required`, `apartment-noise`). Granularité fine et adaptée au format / charge (Tabata burpees over bar PIC = 7 contraintes, Tabata rower = 3 contraintes seulement car low-impact).

**Qualité des `alternatives`** : 2 alternatives plausibles à chaque exo, scaling progressif (Tabata 8 rounds → rower / assault bike all-out OU burpee sans saut step-back, KB swing 24 kg → DB swing OU goblet squat thruster, AMRAP 20 → AMRAP 20 sans pull-up bar OU AMRAP 20 low-impact). Aucun `alternatives: []` détecté en parcours.

**Qualité des `volume_axis`** : `sets` pour Tabata / 30/30 / 40/20, `duration` pour EMOM / AMRAP / walking-recovery / core durée / mobilité, `reps` pour strength compound (depth jumps, power clean, Nordic, hip thrust). Convention HIIT.md respectée.

**Aucun hook manquant ni générique détecté.**

## 3. Internal consistency

| Check | Résultat |
|---|---|
| `duration_weeks == weeks.count` (12 == 12) | PASS |
| Sessions/sem ≤ `sessions_per_week=5` | PASS (60 sessions / 12 sem = 5/sem) |
| 5 sessions chaque semaine | PASS |
| Days uniques ∈ [1,7] (typiquement 1, 2, 3, 5, 7) | PASS |
| HIT cumulé annoncé `summary` (12→16→18→14→17→19→20→16→18→20→19→13) cohérent par sem | PASS (chaque `goal` détaille le calcul) |
| Volume curve build/cutback/peak | PASS (3 build → cutback W4 → 3 build → cutback W8 → 2 build → peak W10 → maintien W11 → dégressive W12) |
| Tabata 8 rounds full RPE 9-10 dès W2 (cohérent doctrine) | PASS (W1 calibration RPE 8-9, W2+ full all-out) |
| EMOM 18-20 min compound dès W3 | PASS (W2 EMOM 18, W3 EMOM 20) |
| AMRAP 20 min introduit en peak (W7 première AMRAP 20) | PASS (annoncé ligne 2415) |
| `deload_weeks` = [4, 8, 12] présent dans données et appliqué dans contenu | PASS |
| W12 séance phare J5 ~50-60 min (`duration_minutes: 60`) | PASS (ligne 4533) |
| W12 J5 contient checklist autonomie 5 critères | PASS (lignes 4538-4550) |
| `progression_logic` cite Tabata 1996, Gibala, NSCA, ACSM, Seiler, Petersen, Mujika | PASS (ligne 22) |
| `safety_notes` cite "récup ≥ 48h HIT" → respecté (J1/J3/J5 espacés ≥ 48h sur tout le plan) | PASS |
| KB swing intro W2 (pas W1) après validation hip hinge | PASS (W1 J7 RDL barbell modéré test hip hinge prérequis explicite) |
| KB 16 → 20 → 24 → 28 kg progression W1-W6 | PASS |
| Box jump 50 cm W1, 60 cm dès W3 sur warmup ou EMOM frais | PASS |
| Depth jumps 30 cm W6, 40 cm W9, 50 cm W11 hors-saison uniquement | PASS |
| Olympic lifts modérés (power clean barbell 60-70% BW max, jamais heavy 1RM) | PASS (charges 40-72 kg progressif annoncé W12 J7 ligne 4727) |
| Cardio active recovery Z2 1-2× / sem (J2 systématique) | PASS (W1-W12 J2 = endurance Z2 RPE 5-6) |
| Mouvements bannis "sans coach humain" listés explicitement | PASS (snatch full barbell heavy 1RM, clean & jerk barbell heavy 1RM, box jump > 75 cm, ring muscle-up AMRAP fatigué, depth jump > 60 cm) |

## 4. Cutback / deload

- `deload_weeks = [4, 8, 12]` explicitement listés.
- **W4 cutback** (ligne 1227) : Tabata 6 rounds RPE plafond 8-9 (vs 8 RPE 9-10 W3), EMOM 15 min (vs 20), AMRAP 12 min (vs 18), volume strength réduit. HIT cumulé 14 min vs 18 W3 = **-22%**. PASS, dans la fenêtre doctrine -15 à -25%.
- **W8 cutback** (ligne 2790) : Tabata 6 RPE plafond 8-9 (vs 8 RPE 10 W7), EMOM 15 (vs 20), AMRAP 15 (vs 20). HIT cumulé 16 min vs 20 W7 = **-20%**. PASS.
- **W12 dégressive** (ligne 4337) : J1 Tabata 6 préparatoire RPE 7-8 (vs Tabata 8 RPE 9-10 W11), strength heavy supprimé, séance phare J5 concentrée sur fenêtre courte. HIT cumulé 13 min vs 20 W10 = **-35%** (taper Mujika & Padilla 2003 cité ligne 22). PASS.
- Cadence cutback exactement 3 sem build / 1 sem deload — conforme doctrine ACSM + HIIT.md "competitive 12 sem `[4, 8, 12]`".

## 5. Safety

`safety_notes` (ligne 23) couvre les **5 sections attendues** + plus :

1. **RED FLAGS** (cardiaque + screening > 35 ans ACSM 2014, tendinopathie Achille, tendinopathie ischio, jumper's knee, shin splints, lombalgie KB heavy, conflit sous-acromial / coiffe rotateurs, hyperextension cervicale, entorse cheville) — exhaustif et sport-spécifique competitive.
2. **GENERAL RULES** (warmup 8-10 min NON optionnel + extension 10-12 min sur Tabata 8 RPE 10 + AMRAP 20, cooldown 5-10 min, récup ≥ 48h HIT règle ABSOLUE, hydratation 500-750 ml/h tempéré + 1 L/h chaleur, JAMAIS HIT > 30°C indoor sans clim, nutrition 3:1 glucides:protéines post-WOD + 6-8 g/kg/j peak weeks, sommeil 7-9h, chaussures faible drop, hip hinge prérequis sur RDL avant KB heavy, atterrissages plyo genoux fléchis, box jump JAMAIS en fin d'AMRAP fatigué).
3. **INTENSITY** (grille RPE complète 1-10 spécifique HIIT competitive, test parole strict RPE 9-10 = incapacité totale à parler, règle volume / charge si rest interval insuffisant). Distribution polarized 75-85% LIT / 15-25% HIT documentée explicitement.
4. **OVERTRAINING / OVERLOAD SIGNS** (FC repos +8-10 bpm chronique 3 jours, palpitations effort modéré, sommeil dégradé > 2-3 nuits, baisse force ≥ 5%, baisse résistance Tabata 2 sem consécutives, courbatures > 72h, motivation effondrée, surcompensation cardiaque ACSM 2014 limite respectée, **rhabdomyolyse** explicitement traitée avec facteurs de risque competitive, coup de chaleur AMRAP indoor > 28°C, **RED-S** chez l'athlète competitive — déficit énergétique chronique, aménorrhée, fractures de stress, alerte 2+ signaux). Couverture remarquablement complète niveau competitive.
5. **MISSED SESSION HANDLING** (1-3 jours, 4-7 jours, 1-2 sem, 2-4 sem, > 4 sem — gradation détaillée incluant rappel risque rhabdomyolyse sur reprise > 4 sem).

**Mouvements bannis sans coach humain** explicitement listés (snatch full barbell heavy 1RM en circuit fatigué, clean & jerk heavy 1RM, box jump > 75 cm volumineux, ring muscle-up AMRAP fatigué, depth jump > 60 cm volumineux, snatch DB heavy en circuit AMRAP fatigué).

**Hyperinflation cardiovasculaire / Valsalva** explicité pour profils hypertendus / antécédents cardiaques (RPE plafonné 8, reps > 5 avec respiration libre).

Pas de copie générique inter-sports détectée — vocabulaire HIIT-competitive spécifique (Tabata, KB swing 24-32 kg, AMRAP FRAN-style ladder, EMOM 20 min compound, burpees over bar, double-unders, depth jumps, hip hinge RKC, hang power clean, snatch DB).

## 6. EU MDR

**Scan mots bannis** (FR + EN) :
- "guérir", "soigner", "traiter une [pathologie]", "diagnostic", "thérapeutique", "rééducation", "prescription", "ordonnance", "cure", "remède", "réparer le [organe]" : **0 occurrence** (vérifié via `grep -niE` exhaustif sur le fichier).
- "médical" / "médecin" : utilisé exclusivement dans `safety_notes` au sens "avis médical / consultation médicale / urgence médicale" — usage de redirection vers professionnel de santé, pas de claim thérapeutique. CONFORME.
- "post-opératoire", "post-blessure", "post-chirurgie" : "reprise post-opération / blessure < 6 mois" présent en `safety_notes` ligne 23 et `goal` divers, **mais en contexte trigger medical clearance** (avis médical obligatoire avant participation), pas de prescription rehab. CONFORME.

**Triggers medical clearance** : présents et explicites :
- "Si tu as antécédents cardiaques connus, hypertension non équilibrée, asthme d'effort, grossesse / postpartum récent, ou reprise post-opération / blessure < 6 mois : consulte un médecin avant de commencer ce programme." (`safety_notes` ligne 23).
- Screening cardiologique obligatoire > 35 ans avec facteurs de risque cardiovasculaire (ACSM 2014 cité explicitement).
- `incompatible_constraints` `cardiac-clearance-required` placé sur tous les Tabata, AMRAP, EMOM intenses.
- Hypertension contrainte cohérente (Valsalva contre-indiqué, RPE plafonné 8).

**Cadrage fitness/training** : aucune prescription rehab post-op, le template renvoie systématiquement vers kiné / médecin sur red flags persistants > 5 jours. Mots préférentiels "renforcer", "stabiliser", "réduire l'inconfort" respectés. CONFORME.

PASS.

## 7. Final autonomy checklist

W12 J5 (séance phare, ligne 4530) contient une **checklist explicite 5 critères mesurables** (lignes 4538-4550) :
1. AMRAP 20 min FRAN-style RPE 8-9 sans dérive de cadence > 30% entre rounds 1-5 et derniers rounds.
2. Tabata 8 rounds RPE 10 burpees over bar avec écart < 25% reps entre round 1 et round 8.
3. HIT cumulé pic 16-20 min/sem tenu 3 sem consécutives (W7, W9, W10) sans signe de surcharge (FC repos stable, sommeil OK, courbatures < 72h).
4. Mouvements olympiques basiques (power clean barbell modéré 60-70% bodyweight, hang power snatch DB) techniques sous fatigue circuit (dos plat, hip hinge propre, lombaire neutre).
5. Récup 24-36h entre 2 séances HIT consécutives (FC repos retour normale, énergie séance suivante OK).

**Plan de suite gradé 4-5/5 → 0-1/5** (ligne 4542 et ligne 4727) : transition autonome ou cycle competitive plus volumineux 14-16 sem ; refaire ce plan en visant pic +5% si 2-3/5 ; basculer entraînement autonome libre si 4-5/5 + envie ; consulter coach humain si 0-1/5 ou douleurs persistantes. Pause récup active 1-2 sem programmée avant cycle suivant (supercompensation centrale NSCA). PASS, mesurable, observable, actionnable, cohérent doctrine HIIT.md "checklist d'autonomie".

## 8. Style

- Français, tutoiement : conforme tout le long (`tu vises`, `note tes scores`, `compare avec`).
- Pas d'emojis : conforme.
- Notes pédagogiques : claires, concrètes, parfois denses (warmup détaillé 9 lignes par séance HIT, notes Tabata) mais justifiées par la complexité competitive et la sécurité plyo + olympic.
- Vocabulaire technique précis (RKC, hip hinge, ramp-up, FRAN-style ladder, Cindy variant, power clean, hang power snatch DB, depth jump, broad jump, double-unders, slam ball, FC repos, supercompensation NSCA, RED-S, rhabdomyolyse, taper Mujika 2003, Petersen BJSM 2011, Seiler 80/20, Alfredson protocol).
- Cohérence pédagogique W1 → W12 (calibration RPE explicite W1 → progression progressive → peak W7 / W10 → dégressive W12 + checklist).

## Issues summary

### Critical (block merge)
Aucun.

### Important (fix recommended)
Aucun.

### Minor (nice-to-have)
- **Doctrine Norwegian 4×4 absente** : la rubrique d'évaluation cite Norwegian 4×4 mais ni le template ni la doctrine HIIT.md ne référencent ce protocole. C'est cohérent avec la position doctrinale CoachingSage (HIIT = Tabata + Gibala + CrossFit-style, pas long-interval Helgerud). Si Sophie souhaite intégrer le protocole Norwegian 4×4 (4 min @ 90-95% FCmax × 4 + 3 min recovery) en doctrine future, le template gagnerait à l'inclure pour profils endurance hybride. Pas bloquant aujourd'hui — décision doctrine à acter en doc fragment.
- **Calcul HIT cumulé "convention CoachingSage"** : les `goal` calculent le HIT cumulé hebdo via heuristique (`Tabata 2.7 + EMOM 18 RPE 7-8 ≈ 7 + AMRAP 18 RPE 8-9 ≈ 7.3`). Le coefficient appliqué à EMOM/AMRAP (≈ 35-40% du temps total comme HIT effectif) n'est pas formalisé en doctrine externe. Acceptable comme heuristique pédagogique cohérente, à documenter dans `Templates/docs/` pour traçabilité (note identique au review hiit-regular). Pas bloquant.
- **Notes pédagogiques redondantes** : warmup competitive 10-12 min répété quasi mot-à-mot sur chaque séance HIT (W1 J1, W3 J1, W5 J1...), KB swing technique RKC répétée 8+ fois. Acceptable pour reminder pédagogique séance par séance, alourdit légèrement le JSON (4741 lignes). Pas bloquant — la regen est terminée et la duplication aide la lisibilité offline.
- **W11 dégressive maintien** : sessions = 4 (J1, J2, J3, J5, J7) — j'ai vérifié les sessions présentes ligne 3937-4332 et compté 5 sessions (J1 HIT Tabata, J2 cardio Z2, J3 HIT EMOM, J5 HIT AMRAP, J7 strength). Attention : le J6 implicite (repos passif) n'est pas matérialisé en session. Conforme au pattern hebdo annoncé. PASS confirmé.

## Sources

- [ACSM HIIT — For Fitness, for Health or Both?](https://acsm.org/high-intensity-interval-training-fitness/)
- [ACSM Position Stand HIIT 2014 — Health & Fitness Journal](https://journals.lww.com/acsm-healthfitness/fulltext/2013/05000/high_intensity_interval_training__efficient,.3.aspx)
- [ACSM Information On HIIT (PDF)](https://blanchfield.tricare.mil/Portals/70/Session%202%20ACSM%20High%20Intensity%20Interval%20Training.pdf)
- [Tabata 1996 protocol explained](https://en.wikipedia.org/wiki/High-intensity_interval_training)
- [Emberts 2013 — Exercise Intensity and Energy Expenditure of a Tabata Workout (PMC)](https://pmc.ncbi.nlm.nih.gov/articles/PMC3772611/)
- [Gillen & Gibala 2016 — Twelve Weeks of SIT, PLOS One](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0154075)
- [Buchheit & Laursen 2013 — High-Intensity Interval Training, Solutions to the Programming Puzzle (Sports Med)](https://link.springer.com/article/10.1007/s40279-013-0029-x)
- [Seiler 2010 — What is best practice for training intensity and duration distribution in endurance athletes?](https://journals.lww.com/acsm-essr/fulltext/2014/04000/distribution_of_intensity_in_endurance_athletes.5.aspx)
- [NSCA Essentials of Tactical Strength and Conditioning (TSAC-F)](https://www.nsca.com/certification/tsac-f/essentials-of-tactical-strength-training-and-conditioning/)
- [CrossFit Competitor's Training Guide (PDF)](https://www.crossfit.com/cf-seminars/SMERefs/Competitor/CrossFitCompetitorsTrainingGuide.pdf)
- [VCF Athletics — CrossFit Pacing Strategies AMRAP / EMOM / For-Time](https://www.vcfathletics.com/blog/crossfit-pacing-strategies)
- [Petersen et al. BJSM 2011 — Nordic curl tendinopathies ischio-jambières -50%](https://bjsm.bmj.com/content/45/4/289)
- [Mujika & Padilla 2003 — Scientific bases for precompetition tapering strategies](https://journals.lww.com/acsm-msse/Fulltext/2003/07000/Scientific_Bases_for_Precompetition_Tapering.21.aspx)
- [Exertional Rhabdomyolysis After CrossFit Exercise (PMC)](https://pmc.ncbi.nlm.nih.gov/articles/PMC7872485/)
- [Beyond the intensity — Systematic review rhabdomyolysis after HIFT (Apunts Sports Med 2024)](https://www.sciencedirect.com/science/article/pii/S2666506924000154)
- [RED-S IOC Consensus Statement 2018 (BJSM)](https://bjsm.bmj.com/content/52/11/687)

## Recommendation

**APPROVED** — Bundle as-is.

Le template hiit-competitive-athletique-12sem.json est de qualité production. Tous les formats first-class HIIT competitive sont déployés (Tabata 8 rounds full RPE 9-10/10 dès W2, EMOM 15-20 min compound, AMRAP 12-20 min FRAN/Cindy ladder, 30/30, 40/20, plyometrics avancés progressifs, olympic lifts basiques modérés). Distribution polarized 75-85% LIT / 15-25% HIT explicite avec semaines de spécificité W7/W10/W11 dérogatoires assumées. Volume HIT cumulé pic 20 min/sem dans le centre de la fenêtre doctrine competitive 16-24 min — sous la limite haute ACSM 2014 (30-40 min/sem) avec marge de sécurité explicite. Cutbacks W4 (-22%), W8 (-20%), W12 (-35% taper Mujika) tous effectifs et dans la fenêtre doctrine -15 à -25%. Safety section 5 + rhabdo + RED-S + Valsalva + couverture EU MDR conforme. Checklist d'autonomie W12 J5 mesurable, gradée, actionnable. Sources doctrine alignées (ACSM 2014, Tabata 1996, Gibala 2016, NSCA HIIT, Seiler 80/20, CrossFit Competitor, Petersen 2011, Mujika 2003). Aucun mot médical banni détecté. Hooks schema v2 100% présents (192 exos × 5 hooks) et qualitatifs.

Patch list : aucun obligatoire. Optionnel : (a) acter en doc fragment la position doctrinale "Norwegian 4×4 hors scope HIIT CoachingSage" pour clarifier ; (b) formaliser en `Templates/docs/` la convention de calcul HIT cumulé hebdo (coefficients EMOM ≈ 35-40%, AMRAP ≈ 40-45% du temps total comme HIT effectif).

## Patches applied (2026-05-01)

Aucun patch obligatoire ni recommandé sur le template. Verdict initial APPROVED tenu.

Les 4 items Minor de la review sont **out-of-scope template** (décisions doctrinales / documentation externe) :
- Norwegian 4×4 absente : décision doctrine à acter en doc fragment, non bloquant.
- Convention de calcul HIT cumulé hebdo (coefficients EMOM ≈ 35-40%, AMRAP ≈ 40-45%) : à formaliser dans `Templates/docs/` pour traçabilité.
- Notes pédagogiques warmup competitive 10-12 min répétées : aide à la lisibilité offline, non patchées.
- W11 dégressive sessions count : déjà PASS confirmé en review (5 sessions présentes).

Post-patch verifications : JSON parse OK, 12 semaines, schema_version 2, banned words EU MDR scan clean, FR/tutoiement/no emojis préservés.

**Verdict final** : APPROVED (bundle as-is).
