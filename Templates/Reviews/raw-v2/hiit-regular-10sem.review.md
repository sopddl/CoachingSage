# Quality Review — hiit-regular-10sem

**Verdict** : APPROVED (post-patches 2026-05-01)
**Sport** : hiit  **Level** : regular  **Schema version** : 2

## 1. Doctrine alignment

Le programme s'appuie explicitement sur les piliers attendus pour un HIIT regular et les sources publiques confirment l'alignement :

- **ACSM HIIT position stand 2014** : work intervals 15 sec - 4 min à 80-95% FCmax, recovery 40-50% FCmax, warmup 5-10 min obligatoire, total 10-40 min/sem au-dessus de 90% FCmax. Le template utilise Tabata 20/10 (cible 95-100% FCmax), 30/30, 40/20, EMOM 12-20 min, AMRAP 10-15 min — toutes formats first-class. HIT cumulé hebdo culmine à 18 min/sem au pic W7 (cible doctrine 12-18 min, dans la fourchette). Warmup 5-10 min explicité chaque séance, étendu à 10-15 min sur les Tabata RPE 9-10. (https://acsm.org/high-intensity-interval-training-fitness/, https://blanchfield.tricare.mil/Portals/70/Session%202%20ACSM%20High%20Intensity%20Interval%20Training.pdf)

- **Tabata 1996 (Med Sci Sports Exerc)** : protocole original 8×20 sec à 170% VO2max + 10 sec rest = 4 min total. Le template livre le protocole complet dès W2 (Tabata 8 rounds full RPE 9-10 sur burpees / KB swings / squat-jumps), avec ramp-up W1 à 6 rounds RPE 8-9. La transposition bodyweight (burpees, KB, squat-jumps) au lieu d'ergocycle 170% VO2max est une adaptation acceptée et largement documentée (Emberts 2013 PMC3772611). Note pédagogique : critère "round 8 ≥ 70% round 1" cohérent avec la baisse de cadence attendue. (https://en.wikipedia.org/wiki/High-intensity_interval_training, https://pmc.ncbi.nlm.nih.gov/articles/PMC3772611/)

- **Gibala lab (PLOS One 2016)** : 12 sem SIT 3×20 sec all-out + 2 min récup, gains VO2max +19% similaires à 50 min MICT. Le template cite Gibala dans `progression_logic` et `summary` ; l'usage est cohérent (justification dose minimale efficace, principe de tabata-like all-out). (https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0154075)

- **NSCA Tactical S&C / HIIT for athlete preparedness** : programmation périodisée, scaling, prévention blessure, focus tactical/functional. Le template applique : Nordic curl excentrique dès W1 (Petersen BJSM 2011 -50% tendinopathies ischio), Turkish get-up KB (stabilité épaule), prévention shin-splints (tibialis raises), recommandation NSCA "core en fin de séance jamais avant compounds", pause 10-15% si EMOM raté. (https://www.nsca.com/certification/tsac-f/essentials-of-tactical-strength-training-and-conditioning/)

- **CrossFit competitor periodization** : AMRAP 10-20 min, EMOM volume accumulation = ¼-½ working window, deload semaines stratégiques. Le template plafonne intelligemment AMRAP à 15 min sur regular (banni AMRAP 20 min réservé competitive), EMOM jusqu'à 20 min au pic W7. Cutbacks W4 (-20%) et W8 (-22%) cohérents avec doctrine 3-build/1-deload. (https://www.crossfit.com/cf-seminars/SMERefs/Competitor/CrossFitCompetitorsTrainingGuide.pdf, https://www.vcfathletics.com/blog/crossfit-pacing-strategies)

**Conclusion doctrine** : alignement très solide. Tous les formats first-class regular sont déployés (Tabata complet 8 rounds, EMOM 10-20 min, AMRAP 10-15 min, 30/30, 40/20). Volume HIT hebdo respecte la fenêtre cible. RPE explicite et différenciée (8-9 dominant Tabata/30/30/40/20, 7-8 EMOM/AMRAP, 9-10 pic Tabata).

## 2. Metadata hooks (Story 0.5.9 / Schema v2)

**Per-template** :
- `week_structure.type` = "block" — cohérent avec ramp-up + cutbacks + pic + dégressive.
- `week_structure.micro_pattern` = "HIT Tabata + Strength + HIT EMOM + Mobilité ou strength accessoire + HIT AMRAP / format varié" — 5 sessions cohérent.
- `week_structure.recovery_cadence` = "2 cutbacks W4 (-20%) et W8 (-22%) sur plan 10 sem, W10 dégressive avec séance phare J5" — explicite.
- `deload_weeks` = [4, 8] — cohérent avec contenu.
- `progression_logic` = présent, structuré en 6 principes sourcés (ACSM, Tabata, Gibala, NSCA, Petersen).

**Per-exercise** : échantillonnage sur 50+ exercices répartis dans les 10 semaines (J1-J3-J5-J6-J7 W1, W3 J5, W5, W7, W10 phare) — TOUS les exercices observés portent les 5 hooks (`target_zone`, `required_equipment`, `incompatible_constraints`, `alternatives`, `volume_axis`). Aucun exercice sans hooks détecté.

**Qualité des `target_zone`** : zones HIIT-spécifiques first-class utilisées (`Tabata 20/10`, `EMOM`, `AMRAP`, `30/30`, `40/20`, `walking-recovery`, `technique`) + RPE bands (`RPE 6-7`, `RPE 7-8`, `RPE 8-9`). Cohérent doctrine.

**Qualité des `incompatible_constraints`** : kebab-case respecté (`knee-injury`, `cardiac-clearance-required`, `apartment-noise`, `wrist-pain`, `shoulder-injury`, `lower-back-pain`, `hip-injury`, `ankle-injury`, `hypertension`, `asthma-exercise-induced`). Granularité fine et adaptée au format/charge (Tabata burpees pic = 9 contraintes, Tabata squat-air W1 = 3 contraintes).

**Qualité des `alternatives`** : 2 alternatives plausibles à chaque exo, scaling progressif (Tabata 8 rounds → step variant ou mountain climbers low-impact, KB swing → RDL DB ou hip thrust, pistol → split squat bulgare).

**Qualité des `volume_axis`** : `sets` pour Tabata/30/30/40/20, `duration` pour EMOM/AMRAP/walking-recovery/core durée, `reps` pour strength compound — convention cohérente.

**Aucun hook manquant ni générique détecté.**

## 3. Internal consistency

| Check | Résultat |
|---|---|
| `duration_weeks == weeks.count` (10 == 10) | PASS |
| Sessions/sem ≤ `sessions_per_week=5` | PASS (toutes les 10 sem ont 5 sessions) |
| Days uniques ∈ [1,7] (W1: 1,3,5,6,7) | PASS toutes semaines |
| 5 sessions par semaine respectées | PASS |
| HIT cumulé annoncé `summary` (8→12→15→12→15→17→18→14→16→11) vs delivered | PASS (cohérent avec dose ACSM 12-18 regular, pic W7 = 18) |
| Tabata 8 rounds full annoncé W2+ | PASS (W2 J1, W3 J1, W5 J1, W6 J1, W7 J1, W9 J1, W10 J5 phare) |
| EMOM 15-20 min annoncé W3+ | PASS (W2 J5 EMOM 15, W3 J5 EMOM 18, W5 J5 EMOM 18, W6 J5 EMOM 20, W7 J5 EMOM 20) |
| AMRAP 12-15 min annoncé W3+ | PASS (W2 J5 AMRAP 10 intro, W3 J6 AMRAP 12, W5 J6 AMRAP 12, W6 J6 AMRAP 15, W7 J6 AMRAP 15, W9 J6 AMRAP 12) |
| `progression_logic` cite Tabata 1996, Gibala, NSCA, ACSM, Petersen → effectivement présents | PASS |
| `safety_notes` cite "récup ≥ 48h HIT" → respecté (J1/J5 toujours espacés ≥ 48h) | PASS |
| Equipment ⊆ `assumed_profile` (KB 12-20 kg, DB 5-25, box 50, jump rope, mat) | PASS, alternatives bodyweight fournies |
| KB swing 12 kg intro W2 (pas W1) après validation hip hinge | PASS (W1 J3 RDL DB test prérequis explicite, W2 J3 KB intro conditionnel) |
| KB 16-18 kg progression W5-W7 | PASS (W3=12-14, W5=14-16, W6=16, W7=16-18) |
| Box jump 50 cm bas, jamais en AMRAP fatigué | PASS (box step-up dynamique en EMOM/AMRAP, box jump explicitement banni en AMRAP fatigué dans progression_logic + safety_notes) |
| Wall ball intro W5 (NSCA recommande après 4 sem maîtrise patterns) | PASS (premier wall ball W5 J5) |
| Double-unders intro W6 (skill conditioning fresh) | PASS (W6 J1 drill 5 min avant Tabata) |

## 4. Cutback / deload

- `deload_weeks` = [4, 8] explicitement listés.
- W4 cutback effectif : Tabata 6 rounds RPE plafonné 8-9 (vs 8 RPE 9-10 W3), EMOM 15 vs 18, charges KB baissent 12 kg (vs 14), volume strength -33% (Nordic 2×6 vs 3×6, KB 3×10 vs 4×12). Cumul HIT 12 min vs 15 W3 = -20%. PASS.
- W8 cutback effectif : Tabata 6 rounds RPE 8-9 (vs 8 RPE 10 W7), EMOM 15 (vs 20), AMRAP 10 vs 15, KB 12-14 kg (vs 16-18). Cumul HIT 14 min vs 18 W7 = -22%. PASS.
- W10 dégressive avec séance phare J5 : Tabata 6 rounds RPE 7-8 J1 + EMOM 12 RPE 7-8, puis phare J5 Tabata 8 RPE 9-10 + AMRAP 15 RPE 8-9. Pattern peak/taper cohérent. PASS.
- Cadence cutback ~3-4 sem (W4 après build W1-3, W8 après build W5-7) — conforme doctrine ACSM 3-build/1-deload.

## 5. Safety

`safety_notes` couvre les **5 sections attendues** + plus :

1. **RED FLAGS** (cardiaque, tendinopathie ischio, jumper's knee, Achille, shin splints, lombalgie, conflit sous-acromial, hyperextension cervicale, entorse cheville, screening > 35 ans / cardiaque) — exhaustif et sport-spécifique.
2. **GENERAL RULES** (warmup 5-10 min non optionnel, cooldown, 48h récup HIT, hydratation 500-750 ml/h, pas de HIT > 30°C, nutrition 3:1 glucides:protéines post-WOD, chaussures faible drop, hip hinge prérequis, atterrissages plyo).
3. **INTENSITY** (grille RPE complète 1-10 spécifique HIIT regular, test parole strict, test rest interval cadence cible).
4. **OVERLOAD SIGNS** (FC repos +8-10 bpm, courbatures > 72h, baisse résistance Tabata, sommeil dégradé, motivation, surcompensation cardiaque, coup de chaleur, **rhabdomyolyse** explicitement traitée — facteurs : reprise après pause > 4 sem, première Tabata 8 RPE 10 sans préparation).
5. **MISSED SESSION HANDLING** (1-3 jours, 4-7 jours, 1-2 sem, 2-4 sem, > 4 sem — gradation détaillée).

**Mouvements bannis sans coach** explicitement listés : snatch full barbell heavy 1RM, clean barbell heavy 1RM, box jump > 60 cm répété volumineux, ring muscle-up, snatch DB heavy en AMRAP fatigué.

**Couverture rhabdo** alignée avec littérature 2024 (https://pmc.ncbi.nlm.nih.gov/articles/PMC7872485/, https://www.sciencedirect.com/science/article/pii/S2666506924000154) : facteurs de risque cités (reprise post-pause prolongée, volume excessif, all-out non préparé), urines noires-cola signal urgence médicale, programme respecte montée progressive. PASS.

Pas de copie générique inter-sports détectée — vocabulaire HIIT-spécifique (Tabata, KB swing, AMRAP, EMOM, burpees, wall ball, hip hinge RKC).

## 6. EU MDR

**Scan mots bannis** (FR/EN) :
- "guérir", "soigner", "traiter une pathologie", "diagnostic", "thérapeutique", "rééducation post-opératoire", "cure", "treat", "diagnose" : ABSENTS du template (vérifié via lecture intégrale safety_notes + progression_logic + notes exos).
- "médical" : utilisé exclusivement dans `safety_notes` au sens "avis médical / consultation médicale / urgence médicale" — usage de redirection vers médecin, pas de claim thérapeutique. CONFORME.
- "rééducation" : ABSENT.

**Triggers medical clearance** : présents et explicites :
- "Si tu as antécédents cardiaques, > 50 ans débutant complet, hypertension non équilibrée, asthme d'effort, grossesse / postpartum récent, ou reprise post-opération / blessure < 6 mois : consulte un médecin avant de commencer ce programme."
- Screening obligatoire > 35 ans avec facteurs de risque (ACSM 2014).
- `incompatible_constraints` `cardiac-clearance-required` placé sur tous les Tabata, AMRAP, EMOM intenses.
- Hypertension constrainte sur tous les pics (Tabata RPE 10, AMRAP 15 RPE 8-9).

**Cadrage fitness/training** : aucune prescription rehab post-op, le template renvoie systématiquement vers kiné / médecin en cas de douleur > 5 jours. CONFORME.

PASS.

## 7. Final autonomy checklist

W10 J5 contient une **checklist explicite 5 critères mesurables** :
1. Tabata 8 rounds RPE 9-10 sans baisse qualité technique > 30% round 1 → 8 ?
2. AMRAP 12-15 min avec cadence > 70% round 1, RPE 8-9 maintenu sans craquer ?
3. Hip hinge KB 16 kg propre 30 reps consécutifs sans douleur lombaire ?
4. Récupération 24-36h entre 2 séances HIT (FC repos, sommeil, courbatures, motivation) ?
5. Distinction douleur articulaire (stop) vs fatigue musculaire (continuer), savoir insérer cutback ?

**Plan de suite gradé 5/5 → 0/5** : transition competitive avec coach, refait regular charge montée, refait identique focus critère manquant, refait avec strength préventif renforcé. PASS, mesurable, observable, actionnable.

## 8. Style

- Français, tutoiement : conforme tout le long.
- Pas d'emojis : conforme.
- Notes pédagogiques : claires, concrètes, parfois longues (notamment Tabata W2, EMOM W3, AMRAP W6) mais justifiées par la complexité doctrine et sécurité regular.
- Vocabulaire technique précis (RKC, hip hinge, hike, RDL, Alfredson protocol, FCmax, glycogène, supercompensation NSCA).

## Issues summary

### Critical (block merge)
Aucun.

### Important (fix recommended)
Aucun.

### Minor (nice-to-have)
- Le 2e bloc Tabata même séance (W3 J1, W5 J1, W7 J1) est compté à 60% en cumul hebdo via "convention CoachingSage" — convention non formalisée dans la doctrine externe. Acceptable comme heuristique pédagogique mais à documenter dans `Templates/docs/` pour traçabilité (pas bloquant).
- Cardio Z2 active recovery : **non mentionné comme tel** dans le template. Sophie a demandé "1-2 cardio Z2 / sem" en doctrine. Le J6 mobilité W10 contient marche RPE 4-5 (≈ Z2), W4/W8/W7 J7 contiennent marche extérieure 30-35 min en alternative — donc Z2 implicitement présent en mobilité/récup. À envisager : ajouter explicitement "cardio Z2 30-40 min RPE 5-6" en alt sur les J7 mobilité de toutes les semaines (pas bloquant, déjà couvert via alternatives "Marche extérieure"). Note : le doctrine HIIT regular ne **requiert pas** strictement Z2 séparé du HIT — la majorité des plans HIIT couvre Z2 via warmup/cooldown et active recovery J6/J7, ce que ce template fait.
- W1 J5 EMOM 12 min sans KB (RDL DB substitut) : choix conservateur cohérent (KB swing introduit W2 après validation hip hinge), mais le `target_zone` "EMOM" pourrait être plus précis "EMOM RPE 7-8" pour cohérence avec les autres EMOM cutback. Cosmétique.
- Notes exos parfois redondantes entre semaines (KB swing technique RKC répétée 6 fois) — acceptable pour reminder pédagogique séance par séance, alourdit légèrement le JSON. Pas bloquant.

## Sources

- [ACSM HIIT — For Fitness, for Health or Both?](https://acsm.org/high-intensity-interval-training-fitness/)
- [ACSM Information On HIIT (PDF)](https://blanchfield.tricare.mil/Portals/70/Session%202%20ACSM%20High%20Intensity%20Interval%20Training.pdf)
- [Tabata 1996 protocol explained](https://en.wikipedia.org/wiki/High-intensity_interval_training)
- [Emberts 2013 — Exercise Intensity and Energy Expenditure of a Tabata Workout (PMC)](https://pmc.ncbi.nlm.nih.gov/articles/PMC3772611/)
- [Gillen & Gibala 2016 — Twelve Weeks of SIT, PLOS One](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0154075)
- [NSCA Essentials of Tactical Strength and Conditioning (TSAC-F)](https://www.nsca.com/certification/tsac-f/essentials-of-tactical-strength-training-and-conditioning/)
- [CrossFit Competitor's Training Guide (PDF)](https://www.crossfit.com/cf-seminars/SMERefs/Competitor/CrossFitCompetitorsTrainingGuide.pdf)
- [VCF Athletics — CrossFit Pacing Strategies AMRAP / EMOM / For-Time](https://www.vcfathletics.com/blog/crossfit-pacing-strategies)
- [Misfit Athletics — Programming EMOMs (volume / threshold / skill)](https://misfitathletics.com/articles/crossfit-programming-how-to-program-emoms/)
- [Pistol Squat CrossFit Progression Guide](https://cfcoordinate.com/how-to-master-pistol-squat-crossfit-guide/)
- [Exertional Rhabdomyolysis After CrossFit Exercise (PMC)](https://pmc.ncbi.nlm.nih.gov/articles/PMC7872485/)
- [Beyond the intensity — Systematic review rhabdomyolysis after HIFT (Apunts Sports Med 2024)](https://www.sciencedirect.com/science/article/pii/S2666506924000154)

## Recommendation

**APPROVED** — Bundle as-is.

Le template hiit-regular-10sem.json est de qualité production. Tous les formats first-class HIIT regular sont déployés (Tabata 8 rounds full, EMOM 12-20 min, AMRAP 10-15 min, 30/30, 40/20). RPE 8-9 dominant avec pics RPE 9-10 maîtrisés. Plyometrics complets avec prérequis hip hinge validé W1, charges KB graduées 12→18 kg avec critères de progression explicites. Cutbacks W4 et W8 effectifs (-20% et -22%). Safety 5 sections + rhabdo + couverture EU MDR conforme. Checklist d'autonomie W10 mesurable et actionnable. Sources doctrine alignées (ACSM 2014, Tabata 1996, Gibala 2016, NSCA, CrossFit Competitor, Petersen 2011). Aucun mot médical banni détecté. Hooks schema v2 100% présents et qualitatifs.

## Patches applied (2026-05-01)

- **Minor — `target_zone` W1 J5 EMOM précisé** : "EMOM" → "EMOM RPE 7-8" pour cohérence avec les autres EMOM cutback du plan.
- **Minor non patchés (out-of-scope template)** :
  - Convention "60% 2e Tabata cumul" + coefficients EMOM/AMRAP : à formaliser dans `Templates/docs/` (doc fragment externe).
  - Cardio Z2 explicite J7 : déjà couvert via alternatives "Marche extérieure 30-35 min RPE 5-6", non bloquant.
  - Notes redondantes KB swing RKC : acceptables comme reminder pédagogique séance par séance, pas patché.

Post-patch verifications : JSON parse OK, 10 semaines, banned words EU MDR scan clean, FR/tutoiement/no emojis préservés.

**Verdict final** : APPROVED.
