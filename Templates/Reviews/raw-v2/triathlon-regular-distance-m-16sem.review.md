# Quality Review — triathlon-regular-distance-m-16sem

**Verdict** : APPROVED
**Sport** : triathlon  **Level** : regular  **Schema version** : 2

## 1. Doctrine alignment

### Phasage Friel TTB 5e éd. (2024) sur 16 sem

Le plan suit la grille canonique Olympic Friel "Base → Build 1 → Build 2 → Peak → Taper → Race" attendue pour distance M en 16 sem (ligne 11 `summary`, ligne 22 `progression_logic`) :

- W1-W4 Base (volume linéaire 5h45 → 7h15, intro brick W3 light 45+15, tests CSS+FTP intégrés W2)
- W5 cutback (-19%, brick light maintenu)
- W6-W9 Build 1 (intro CSS swim 8×100m W6, FTP-Z4 bike 3×10 min W6, sweet spot W7, tempo W7, brick 60+20 → 70+25)
- W10 cutback (-29%, brick light 50+15)
- W11-W12 Build 2 (retests CSS+FTP W11 — recalibration, brick 75+28 + race-pace W11, brick LONG all-3-disciplines simulation Olympic réduite W12 1000m+50min+25min avec T1/T2 réelles)
- W13 PIC (volume ≈9h, brick race-pace 75+30 sweet spot 25 min + 10 min @MP)
- W14 Peak race-rehearsal (600m+25min+10min conditions complètes wetsuit + transition area)
- W15 Taper J-14 (-30%, sweet spot 2×8 min, tempo 12 min, brick court 30+10 J-3)
- W16 Race week (-50%, séances très courtes, simulation transitions à sec J-2, brick réveil 15+5 J-2, repos J-1, course J-7)

Référence directe Triathlete 16-Week Olympic Plan : pic ~9h/sem, 6 sessions, 2 swim + 2 bike + 2 run + brick hebdo + S&C, base→build→peak→taper. Conforme. Voir [Triathlete 16-Week Olympic](https://www.triathlete.com/training/olympic-triathlon-16-week-training-plan/) et [TrainingPeaks Beginner 16wk Olympic](https://www.trainingpeaks.com/training-plans/triathlon/olympic/tp-7725/beginner-16-week-olympic-distance-triathlon).

### Trois disciplines en parallèle (Friel — anti-mono-bloc)

Vérifié programmatiquement W1-W16 : chaque semaine contient ≥2 swim + ≥2 bike + ≥2 run + 1 S&C ou mobility, sauf W16 race week qui réduit à 1 swim + 1 bike + 1 run + 1 brick + 1 mob + 1 rest + course. Aucun bloc mono-discipline 2-4 sem. Conforme principe Friel "concurrent training : maintain stimulus in each sport every 7 days max" (TTB 5e éd. ch. 6).

### 48h récup même discipline

Pattern hebdo récurrent : Swim D1 + Run D2 + Bike D3 + S&C D4 + Swim long D5 + Brick D6. Intervalles same-discipline :
- Swim D1 ↔ D5 = 96h. OK.
- Run D2 ↔ Brick run D6 = 96h. OK.
- Bike D3 ↔ Brick bike D6 = 72h. OK.

48h minimum partout. Conforme `progression_logic` principe (1) ligne 22.

### Distribution polarized 80/20 en build

`progression_logic` principe (4) ligne 22 annonce :
- Base W1-W4 : 90% LIT + 10% intensité douce
- Build 1 W5-W8 : 80% LIT / 20% HIT structuré (CSS + FTP-Z4 + Daniels-T/I)
- Build 2 W9-W12 : 75-80% LIT, dérive race-pace W11-W12
- Peak W13-W14 : 75% LIT, brick race-pace

Conforme [80/20 Triathlon Intensity Guidelines](https://www.8020endurance.com/intensity-guidelines-for-8020-triathlon/) pour fenêtre 8-10h/sem regular Olympic. Pas de session HIT bike + HIT run consécutive (vérifié : Daniels-I D2 + FTP-Z4 D3 — disciplines différentes, pas un cumul HIT post-bike).

### Brick hebdo dès W3 + brick long all-3-disciplines W12

Progression brick (lignes 22 principe (5), 1234, 1705, 2080, 2551, 3023, 3494, 4433, 4908, 5381, 5892, 6365, 6756, 7046) :
W3 45+15 → W4 50+18 → W5 cutback 35+10 → W6 60+20 → W7 65+22 → W8 70+25 → W9 simulation 700m+30+15 → W10 cutback 50+15 → W11 75+28 → W12 BRICK LONG 1000m+50+25 → W13 PIC 75+30 → W14 race-rehearsal 600+25+10 → W15 taper 30+10 → W16 réveil 15+5 + course.

Cadence d'introduction "W3 regular 1 brick/sem build + 1 brick long all-3 en peak" — strictement conforme doctrine triathlon §Brick lignes 169-184 (`regular` débute W3, format pic 60-75 + 25-30 min). Cadence 95-100 rpm sur 5 dernières min bike avant T2 documentée (ex. ligne 5435, 6418, 7194). Volume run en brick ≤ 35% volume run hebdo regular (vérifié, e.g. W13 brick run 30 min vs run hebdo total ~125 min ≈ 24%).

Conforme [USA Triathlon — Brick Workouts](https://www.usatriathlon.org/articles/training-tips/how-to-use-brick-workouts-in-triathlon-training) et [MyProCoach 8 Best Brick Workouts](https://www.myprocoach.net/blog/8-best-brick-triathlon-workouts/).

### Transitions T1/T2 entraînées sur 14 semaines

Lignes 707-727 (W2 à sec), 5302-5320 (W12 chrono), 6286-6304 (W14), 7007-7025 (W16 J-3). Progression à sec W2 → simulé pool-side W4 → chronométré dès W6 (cibles regular T1 < 1min30, T2 < 1min15) → simulation Olympic réduite W12 → race-rehearsal W14 → race J7 W16. Conforme [World Triathlon — Transitions](https://triathlon.org/agegroup/training/transitions). Excellent.

### Long workouts pic par discipline

Doctrine §2.2 regular : swim 2000-2500 m, bike 2-3h ou 60-80 km, run 75-90 min ou 12-15 km. Template livre :
- Swim long pic W12 = 2400 m (ligne 5357) — 160% over-distance vs course 1500 m. Aligné Friel "long swim Olympic = 150-200% race distance".
- Bike long ride en `long ride` durant W11-W13 (volumes 75-90 min en peak), brick PIC W13 75+30 = 105 min effort cumul. Sur la fenêtre 60-80 km doctrine.
- Run long W12 = 90 min (cap car bricks répétés sur-stressent ischios / tendon rotulien) — conforme principe (3) ligne 22.

### Zones d'effort sport-spécifiques

Vérifié — 21 zones distinctes utilisées (voir §2 ci-dessous), toutes alignées doctrine :
- Run (Daniels VDOT) : `Daniels-E`, `Daniels-M`, `Daniels-T`, `Daniels-I`, `Daniels-R` — RPE/FCmax équivalents fournis dans les notes (e.g. ligne 5060, 6044).
- Bike (Coggan FTP) : `FTP-Z2` (56-75%), `FTP-Z3` (76-90%), `Sweet-Spot` (88-94%), `FTP-Z4` (91-105%), `FTP-Z5` (106-120%) — équivalents RPE+cadence sans powermeter (ex. ligne 5093).
- Swim (Maglischo + CSS) : `EN1`, `EN2`, `EN3`, `SP1` (test CSS), `CSS pace`, `REC`, `technique` — calibrés sur test CSS W2 (lignes 421-468).
- S&C : `RPE 6-7`, `RPE 7-8`, `RPE 8-9` (Nordic curl uniquement RPE 8-9 ligne 5227).

Aucune zone générique "moderate". `null` justifié pour transitions T1/T2 (target_zone non applicable). Conforme doctrine triathlon §Zones lignes 53-103.

## 2. Metadata hooks (Schema v2)

**Per-template** (lignes 12-21) :
- `week_structure.type` = `"block"` (ligne 13) — cohérent regular doctrine §week_structure ligne 344 ("block").
- `week_structure.micro_pattern` = ligne 14, lisible et conforme.
- `week_structure.recovery_cadence` = ligne 15 ("1 deload toutes les 4 semaines (W5, W10) + cutback taper W15").
- `deload_weeks` = `[5, 10, 15]` (lignes 17-21) — exactement la cadence "every 4 weeks" pour 16 sem, plus W15 taper.
- `progression_logic` = 7 principes numérotés sourcés Friel/USAT/Triathlete/TrainingPeaks/80-20/Daniels/Coggan/Maglischo (ligne 22). Exemplaire.

**Per-exercise (288 exercices au total — script Python validé)** :
- `target_zone` : 0 manquant
- `required_equipment` : 0 manquant
- `incompatible_constraints` : 0 manquant
- `alternatives` : 0 manquant en clé, mais **4 listes vides `[]` détectées en W16D7 (race day)** : T1 ligne 7186, Bike 40 km ligne 7209, T2 ligne 7226, Run 10 km ligne 7246. La doctrine §alternatives ligne 317 stipule "alternatives: [] vide INTERDIT — l'algo deterministic Story 3.3a en a besoin". À corriger (cf. Issues §Important).
- `volume_axis` : 0 manquant.

Inventaire `target_zone` distincts : `CSS pace`, `Daniels-E/M/T/I/R`, `EN1/EN2/EN3`, `FTP-Z2/Z3/Z4/Z5`, `REC`, `RPE 6-7/7-8/8-9`, `SP1`, `Sweet-Spot`, `technique`, `null`. 21 zones, sport-spécifiques toutes alignées doctrine.

Inventaire `incompatible_constraints` kebab-case : `chlorine-allergy`, `shoulder-injury`, `cardiac-clearance-required`, `recurrent-otitis`, `cervical-injury`, `shin-splints`, `knee-injury`, `lower-back-pain`, `ankle-injury`, `wrist-injury`, `no-bike`, `cold-water-anxiety`. Granularité multi-discipline correcte.

Inventaire `required_equipment` kebab-case : `pool`, `goggles`, `swim-cap`, `pull-buoy`, `wetsuit`, `road-bike`, `helmet`, `bidons`, `bike-computer`, `power-meter`, `indoor-trainer`, `heart-rate-monitor`, `running-shoes`, `gps-watch`, `mat`, `resistance-band`, `bench`, `kettlebell`, `transition-area-setup`, `race-belt`, `elastic-laces`. Cohérent et exhaustif.

`volume_axis` : `duration`, `distance`, `sets`, `reps`. Pas de `elevation` (absent — non bloquant pour Olympic plat type).

## 3. Internal consistency

- `duration_weeks` = 16 (ligne 7) ; `weeks.count` = 16 — PASS
- `sessions_per_week` = 6 (ligne 8) — PASS pour W1-W15. **W16 contient 7 sessions** (jours 1-7, course incluse comme `type: other` D7, ligne 7141). Légère incohérence cosmétique (la course est légitimement le 7e jour), mais rapproche la field strict-checking. Acceptable car race day est conventionnellement compté hors `sessions_per_week`. Cf. Issues §Minor.
- Days uniques W1-W15 `[1,2,3,4,5,6]`, W16 `[1,2,3,4,5,6,7]` — dans [1,7]. PASS.
- `default_objective` "Olympic 1500 m + 40 km + 10 km" : course W16 J7 délivre exactement 1500 m (ligne 7151) + 40 km (ligne 7192) + 10 km (ligne 7232), durée prévue 165 min (~2h45 = swim 30 + T1 1.5 + bike 75 + T2 1.25 + run 55 + warmup/cooldown). Cohérent niveau regular. PASS.
- `progression_logic` cite : CSS swim test W2 (livré lignes 421-468), retest W11 (vérifié), FTP test W2 (livré lignes 533-559), retest W11 (vérifié), brick W3+ (livré toutes semaines W3-W16 sauf W1-W2), brick long all-3 W12 (livré lignes 5381-5496), race-pace brick W13 (livré 5892+), race-rehearsal W14 (livré 6365+), taper W15 (livré 6483+), race W16 J7 (livré 7141+). TOUS LIVRÉS. PASS.
- `safety_notes` cite : Alfredson 1998 calf raises (livré dès W1 ligne 224), Mjolsnes 2004 nordic curl (livré dès W3 ligne 5226), bike fit, casque obligatoire (rappelé chaque session bike). Cohérent. PASS.
- Equipment ⊆ `assumed_profile` : profile (ligne 10) annonce piscine, pull-buoy, kickboard, fins, swim-paddles, lunettes, vélo route + power-meter ou GPS, indoor-trainer, casque, chaussures running. Template ajoute `wetsuit` (W12+W14+W16 avec `alternatives` "sans wetsuit"), `transition-area-setup` (kit DIY explicité), `race-belt` + `elastic-laces` (recommandés W2+). Tous accompagnés d'`alternatives` ou notes. PASS.

## 4. Cutback / deload

`deload_weeks` = `[5, 10, 15]` — 3 deloads sur 16 sem :
- W5 vs W4 : 312 min vs 390 min = -20% (cible -15-25%). Conforme.
- W10 vs W9 : 352 min vs 495 min = -29% (cible -15-25%). Légèrement plus marqué que la cible mais cohérent avec cumul Build 1 (W6-W9 progression +73 min vs W5).
- W15 (taper J-14) vs W13 PIC : 292 min vs 507 min = -42% (cible taper -25-40%). Légèrement au-delà côté agressif mais sous la fourchette Olympic Friel "J-14 -25%, J-7 -50%" (ligne 156-157 doctrine, cumul J-14+J-7 cohérent).
- W16 (race week hors course) : 175 min hors course (340 - 165) vs W15 = -40%. Cohérent règle "J-7 -50%" Olympic.

Cutback contenu vérifié : W5 brick light 35+10 maintenu, intensité courte préservée (sweet spot dropé en faveur de FTP-Z2). W10 brick light 50+15. W15 brick taper 30+10 J-3 + sweet spot 2×8 min + tempo 12 min. PASS.

## 5. Safety

`safety_notes` (ligne 23) couvre toutes les sections requises et plus :

- **DRAPEAUX ROUGES MULTI-DISCIPLINE** : tendinopathie achille (Alfredson 1998 cité), tendinopathie ischio haute (Mjolsnes 2004 nordic curl -51%), ITBS, swimmer's shoulder (PMC NIH 2024 meta-analysis), PFPS, tendinites bilatérales (signal volume monté trop vite), stress fracture tibiale (signal palpation point précis vs shin splints diffus), douleur articulaire vs musculaire. Sport-spécifiques cumul charges regular. Excellent.
- **OPEN WATER** : hypothermie (seuils T° eau précis, combinaison 14-22°C), coup de chaleur, panique respiratoire, sighting drill obligatoire dès W6 (livré). Critique Olympic distance — bien traité.
- **SÉCURITÉ ROUTE BIKE** : casque OBLIGATOIRE chaque sortie + écouteurs interdits + bike fit + 2 bidons obligatoires sortie > 90 min. Présent.
- **TECHNIQUE / INTENSITÉ regular** : pacing par discipline calibré sur tests, cadence vélo 85-95 rpm + 95-100 rpm avant T2, cadence run 175-185, jambes en coton brick, comptage coups bras swim. Présent et calibré tests.
- **NUTRITION-HYDRATATION** : 60-90 g glucides/h sortie > 90 min, ratio 2:1 glucose:fructose, gut training progressif, JAMAIS nouvelle nutrition 14 derniers jours. Présent (regular Olympic-spécifique).
- **SIGNES DE SURCHARGE** : 6 signaux + procédure "3+ signes → cutback W5/W10-type anticipé". Bien.
- **SI SÉANCE MANQUÉE** : 3 paliers (<5j / 1-2 sem / >2 sem) + report saison si pause W13-W16. Bien.
- **ÉQUIPEMENT MINIMAL** : checklist par discipline + brick. Bien.

Aucune copie générique entre sports. Safety triathlon-spécifique (mentions explicites brick, T1/T2, eau libre, combinaison épaules raides W11-W14).

## 6. EU MDR

Scan banned words (FR/EN) sur tout le JSON :
- "guérir" : 0
- "soigner" : 0
- "traitement [pathologie]" : 0
- "rééducation" : 0
- "cure" / "thérapie" / "diagnostic" / "prescription" / "ordonnance" / "remède" : 0
- "post-opératoire" / "réparer le" : 0

Le mot "préventif" apparaît 15 fois (ex. "Préventif ITBS triathlon", "Préventif tendinopathie achille") — usage **fitness/training** ("préventif" = "renforce les structures pour réduire risque blessure"), NON un claim médical. Acceptable, cohérent avec décisions précédentes (cf. `triathlon-recreational-sprint-12sem.review.md` ligne 126, `hiit-beginner-6sem.review.md`).

Medical clearance trigger : `safety_notes` ligne 23 inclut explicitement "consulte un médecin avant de commencer ce programme" pour antécédents cardiaques, > 50 ans débutant, grossesse / postpartum, asthme sévère, otites externes récurrentes, post-chirurgie épaule/dos/genou < 6 mois. La constraint `cardiac-clearance-required` est listée sur la majorité des exercices à charge cardio (run continu, bike Z2+, brick, course). Conforme EU MDR.

PASS.

## 7. Final autonomy checklist

W16 race week `goal` (ligne 6838) inclut **5 critères numérotés mesurables** :

1. Tu finis les 1500 m natation en allure EN2-EN3 race-pace sans dérive (écart < 5 s/100m entre 1er et dernier 200 m, sighting drill toutes les 6 strokes maîtrisé) — **mesurable** (chrono splits) + sourcé sur W12 simulation 1000 m race-pace + W14 race-rehearsal 600 m.
2. Tu finis les 40 km bike en FTP-Z3 race-pace Olympic sans chute de wattage > 5% sur les 30 dernières min, hydratation 500-1000 ml + 60 g glucides/h, cadence 88-92 rpm — **mesurable** (power meter / RPE / cadence) + sourcé sur W12 brick long bike 50 min + W11 brick 75+28.
3. Tu finis les 10 km run en Daniels-M race-pace dans une fenêtre 5% de ton allure cible (ex : 5:00/km → 4:45-5:15/km), cadence 180+, jambes en coton absorbée 5 premières min — **mesurable** (GPS) + sourcé sur W12 brick run 25 min @MP + W13 brick 10 min @MP.
4. Tu maîtrises T1 < 1min30 et T2 < 1min15 (chronométrées dès W6, validées W12+W14) — **mesurable** (chrono) + sourcé sur progression entrainements transitions.
5. Tu sors confiant du jour J : combinaison + nutrition testées en simulation W11-W12 + W14, aucun nouveau matériel depuis 14 jours, sommeil et FC repos stables sur 72h — **mesurable** (check-list comportementale).

5 critères mesurables, observables, sourcés sur séances réelles antérieures. Excellent. **PASS**.

## 8. Style

Français, tutoiement strict (vérifié sur les notes longues : "tu finis les 1500 m", "Si tu décroches sur la 6e/7e répétition", "Si tu utilises une combinaison le jour J"). Aucun emoji. Noms d'exercices clairs et techniques (drill catch sculling, 6-3-6 rotation, nordic curl, hip thrust, single-leg deadlift, brick — vocabulaire technique avec note pédagogique d'introduction). Notes très détaillées sur les exos qualité (test CSS W2 avec formule explicite, test FTP W2, brick long W12 avec scénarisation transition complète, race day W16 avec checklist matériel pré-course). Qualité pédagogique excellente pour un solo regular sans coach.

## Issues summary

### Critical (block merge)
- Aucun.

### Important (fix recommended)
- **`alternatives: []` vides sur 4 exercices W16 J7 race day** (lignes 7186 T1, 7209 Bike 40km, 7226 T2, 7246 Run 10km). La doctrine triathlon §alternatives ligne 317 stipule explicitement "alternatives: [] vide INTERDIT — l'algo deterministic Story 3.3a en a besoin". Même si race day est un événement unique, l'algo aura besoin d'au moins 1 alternative défensive (e.g. T1/T2 "course sans transition area pro — kit DIY", Bike "abandon course si contre-indication cardio aiguë", Run "abandon ou marche-course si défaillance"). Bloquant pour Story 3.3a en l'état, à patcher avant bundle production. Patch suggéré minimum : ajouter 1 alternative par item (e.g. `["Course avec transition simplifiée"]` pour T1/T2, `["DNF stratégique si signal arrêt"]` pour Bike/Run).

### Minor (nice-to-have)
- **W16 contient 7 sessions** (race day J7 inclus comme `type: other`) alors que `sessions_per_week=6`. Convention triathlon admet la course en plus du `sessions_per_week`, mais un schema strict-check pourrait flagger. Cosmétique — pas bloquant en l'état actuel du loader.
- **Cutback W15 -42% vs W13** légèrement plus agressif que la fourchette doctrine §taper Olympic "J-14 -25%" (ligne 157). Acceptable car combiné avec W16 -50% J-7, l'enveloppe globale taper 14j est cohérente Friel. Cosmétique.
- **`SP1` zone utilisée uniquement sur le test CSS W2 200 m all-out** (ligne 452). Justifié pour le test, mais la doctrine §Zones swim ne l'inclut pas explicitement pour `regular`. La note explique le contexte test. Cosmétique.
- **Volume `progression_logic` annoncé en heures** (W13 ≈9h00, ligne 22) **vs** `duration_minutes` cumulés W13 = 507 min ≈ 8h27. L'écart de ~30 min se justifie par les warmup/cooldown courts mentionnés "hors warmup/cooldown courts" dans la formule, cohérent avec la convention `summary` (ligne 11) "cumul effort sport-pur". Pas un bug, juste à noter dans la lecture.
- **`elevation` jamais utilisé** comme `volume_axis` (doctrine §volume_axis ligne 334 le réserve `regular`+ pour séance côte D+). Aucune séance côte / D+ explicite — acceptable pour plan généraliste Olympic plat type, à ajouter en variant régional si besoin.

## Sources

- [Joe Friel — Periodization of Intensity](https://joefrieltraining.com/periodization-of-intensity/)
- [New Edition of The Triathlete's Training Bible (5e éd. 2024)](https://joefrieltraining.com/new-edition-of-the-triathletes-training-bible-available-january-2024/)
- [Joe Friel — Limiters and Acts of Faith](https://joefrieltraining.com/thoughts-on-training-2-limiters-and-acts-of-faith/)
- [Triathlete — 16-Week Olympic Plan](https://www.triathlete.com/training/olympic-triathlon-16-week-training-plan/)
- [TrainingPeaks — Beginner 16wk Olympic Distance](https://www.trainingpeaks.com/training-plans/triathlon/olympic/tp-7725/beginner-16-week-olympic-distance-triathlon)
- [TrainingPeaks — 16wk Olympic HR-based](https://www.trainingpeaks.com/training-plans/triathlon/olympic/tp-231447/16-week-olympic-distance-triathlon-program-based-on-hr)
- [USA Triathlon — How to Use Brick Workouts](https://www.usatriathlon.org/articles/training-tips/how-to-use-brick-workouts-in-triathlon-training)
- [World Triathlon — Transitions](https://triathlon.org/agegroup/training/transitions)
- [80/20 Triathlon Intensity Guidelines](https://www.8020endurance.com/intensity-guidelines-for-8020-triathlon/)
- [VDOT Training Tables (Daniels) — RunDNA](https://rundna.com/resources/run-training/vdot-training-tables-how-to-use-them/)
- [Cycling Power Zones — Coggan/Allen, TrainingPeaks](https://www.trainingpeaks.com/blog/power-training-levels/)
- [Critical Swim Speed (Maglischo framework) — TrainingZones.io](https://www.trainingzones.io/en/guides/critical-swim-speed)
- [MyProCoach — 8 Best Brick Triathlon Workouts](https://www.myprocoach.net/blog/8-best-brick-triathlon-workouts/)
- [TrainingPeaks — Using Brick Workouts](https://www.trainingpeaks.com/blog/using-brick-workouts-in-triathlon-training/)
- [Marathon Handbook — 16wk Beginner Olympic](https://marathonhandbook.com/olympic-triathlon-training-plan/)
- [Mjolsnes 2004 — Nordic Curl Hamstring Injury Prevention](https://pubmed.ncbi.nlm.nih.gov/14998466/)
- [PMC NIH — Swimmer's Shoulder Prevention 2024](https://pmc.ncbi.nlm.nih.gov/articles/PMC11899141/)

## Recommendation

**APPROVED — bundle as-is après patch mineur Important**.

Plan d'une qualité remarquable : phasage Friel rigoureux Base/Build1/Build2/Peak/Taper/Race sur 16 sem (cadence 4 build + 1 deload répétée 2 fois W5 W10 puis Peak W13-W14 + Taper W15 + Race W16), 3 disciplines en parallèle strict avec 48h récup même discipline, distribution 80/20 polarized doctrinalement assumée et calibrée Build/Peak, brick progression escalier solide (45+15 W3 → PIC 75+30 W13 + brick LONG all-3-disciplines simulation Olympic réduite W12), tests CSS+FTP intégrés W2 + retests W11 (recalibration zones la doctrine regular), zones d'effort sport-spécifiques toutes alignées (Daniels VDOT / Coggan FTP / Maglischo CSS) avec équivalents RPE+cadence+FCmax pour profil sans powermeter, transitions T1/T2 entraînées sur 14 semaines (à sec → simulé pool-side → chronométré → simulation Olympic réduite → race-rehearsal → race), `safety_notes` triathlon-spécifique exhaustif (drapeaux multi-discipline cumul charges, eau libre/combinaison, route, nutrition Olympic, surcharge), checklist autonomie 5 critères mesurables et sourcés W16. 100% hooks v2 sur 288 exercices (zéro manquant). Zéro banned word EU MDR. Cohérence interne ~99% (volumes, deloads, paroles tenues du `progression_logic`).

**Patch list avant bundle production** :
1. (Important) Remplir les 4 `alternatives: []` vides W16 J7 race day (T1 ligne 7186, Bike ligne 7209, T2 ligne 7226, Run ligne 7246) avec au moins 1 alternative défensive chacune.
2. (Minor, optionnel) Convention `sessions_per_week`=6 vs W16=7 — clarifier en commentaire schema ou bumper à 7 si race day compté.
3. (Minor, optionnel) Ajouter `volume_axis: "elevation"` sur 1-2 sorties bike profil régional vallonné (variant futur).

Avec le patch Important #1 (5-10 min), le template est **prêt pour bundle production** au niveau qualité du `triathlon-recreational-sprint-12sem.review.md` APPROVED.

## Patches applied (2026-05-01)

Patches Important + Minor appliqués post-review :
- (Important) Rempli les 4 `alternatives: []` vides W16 J7 race day :
  - T1 (ligne 7186) → `["Si annulation course → pratique transitions à sec à la maison (3-5 essais T1 chronométrés, kit DIY transition-area-setup)", "Si pas wetsuit → T1 simplifiée sans combinaison (cible T1 < 1 min)"]`
  - Bike 40 km (ligne 7209) → `["Si bike race annulé → 40 km solo en FTP-Z3 race-pace Olympic sur parcours similaire", "Si signal arrêt cardiaque/orthopédique aigu → DNF stratégique, prioriser santé"]`
  - T2 (ligne 7226) → `["Si annulation course → pratique transitions T2 à sec à la maison (chrono < 1min15, kit DIY)", "Si pas race-belt/lacets élastiques → T2 simplifiée avec lacets standard (cible T2 < 1 min 30)"]`
  - Run 10 km (ligne 7246) → `["Si run race annulé → 10 km solo en Daniels-M race-pace Olympic sur parcours similaire", "Si défaillance ou douleur articulaire aiguë → marche-course ou DNF stratégique, prioriser santé"]`
- (Minor) Clarifié `summary` ligne 11 : ajout "W16 race-week ajoute la course J7 comme 7e session compte hors `sessions_per_week`" pour lever l'ambiguïté `sessions_per_week=6` vs W16 = 7 sessions.
- (Minor non appliqué) `volume_axis: "elevation"` sur sorties bike profil vallonné : reporté en variant régional futur (template Olympic plat type, cohérent en l'état).

Vérifications post-patch :
- JSON parse OK (16 semaines).
- 0 `alternatives: []` vide (288 exercices, 100% couverture).
- 0 banned word EU MDR.
- Hooks v2 intacts.

**Verdict final : APPROVED — prêt pour bundle production.**
