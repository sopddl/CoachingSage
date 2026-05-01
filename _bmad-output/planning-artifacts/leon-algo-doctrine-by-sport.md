# Léon Algo — Doctrine par sport

Référentiel public sourcé pour la regen des templates Story 0.5.10 et l'algo deterministic local Story 3.3a.

**Last revised** : 2026-04-30.

**Statut** : section RUNNING complète (sport pilote). Les 9 autres sports seront ajoutés en cascade Phase C.

**Vocabulaire de niveau** (aligné enums Sport + Level Story 0.5.8) :
- `beginner` : aucune expérience récente, < 6 mois d'activité régulière, vise la complétion d'un objectif modeste.
- `recreational` : pratique 1 à 2× / sem, capable de courir 30 min en continu, vise un 5K-10K confortable.
- `regular` : pratique 3 à 4× / sem depuis ≥ 1 an, capable de courir > 1h, vise une perf 10K ou un semi.
- `competitive` : pratique 5 à 6× / sem (incl. doubles selon plan), volume hebdo soutenu, vise marathon ou perf 10K.

---

## RUNNING

### Doctrine référente

| Référence | Auteur | Application |
|---|---|---|
| **Daniels' Running Formula** (3e éd.) | Jack Daniels | Zones VDOT E/M/T/I/R, formules de calcul d'allure, plans 5K → marathon. |
| **Advanced Marathoning** (4e éd.) / **Faster Road Racing** | Pete Pfitzinger & Scott Douglas | Plans 5K-marathon par paliers de mileage 55 / 55-70 / 70-85 / 85+ mpw, lactate threshold pivot. |
| **NHS Couch to 5K** | Public Health England / NHS | Référence absolue débutant, run/walk progressif sur 9 sem (3 sessions / sem). |
| **Hansons Marathon Method** | Keith & Kevin Hanson, Luke Humphrey | Cumulative fatigue, long run plafonné 16 mi (~26 km), 6 sessions / sem. |
| **80/20 Polarized Training** | Stephen Seiler / Matt Fitzgerald | Distribution intensités : ~80% LIT (Z1-Z2) + ~20% HIT (Z4-Z5), validé par revue systématique 2024 (MDPI). |
| **ACSM Guidelines for Exercise Testing** (11e éd.) | American College of Sports Medicine | Règle des 10% sur volume, prévention shin splints, cadence ~170-180 spm. |

### Zones d'effort (target_zone)

Convention v2 : préfixe `Daniels-` ou allure de race comme repère (`@10K-pace`, `@MP-10s/km`).

| Zone | % VDOT | Allure typique | Description | Application typique |
|---|---|---|---|---|
| **Daniels-E** (Easy) | 59-74% | MP + 1:00 à 1:30 / km | Aérobie de base, conversational | Sortie longue lente, recovery, échauffement, cooldown |
| **Daniels-M** (Marathon) | 75-84% | Marathon Pace | Comfortably hard sustainable | Bloc spécifique pré-marathon (8-16 km au tempo cible MP) |
| **Daniels-T** (Threshold) | 83-88% | 10K + 15-30 s / km | Lactate threshold (1 hr race effort) | Tempo continu 20-40 min OU cruise intervals 4-8 × 1 mi |
| **Daniels-I** (Interval) | 95-100% | Allure 3K-5K | VO2max | 3-5 min × 4-6 reps, récup 1:1 |
| **Daniels-R** (Repetition) | 105-110% | Allure 800m-1500m | Vitesse pure / économie | 200-400 m × 8-12 reps, récup 2-4× durée effort |

Sources : [VDOT Training Tables — RunDNA](https://rundna.com/resources/run-training/vdot-training-tables-how-to-use-them/), [Coaches Education — Daniels](https://www.coacheseducation.com/endur/jack-daniels-nov-00.php), [VDOT Calculator STAS](https://stas.run/en/tools/vdot-calculator).

**Choix de doctrine** : on pace par **race-pace + offset** plutôt que par FCmax. Plus universel (pas besoin de cardio), plus aligné Daniels, et compatible avec un débutant sans GPS (test de la parole comme proxy Z1-Z2).

### Volume hebdo cible par niveau

| Niveau | Vol pic | Fréquence | Long run max | Doctrine source |
|---|---|---|---|---|
| **beginner** | 15-25 km/sem (≈ 60-90 min de course) | 2-3 sessions / sem | 30-45 min ou 5K | NHS Couch to 5K (3 sessions/sem) |
| **recreational** | 30-50 km/sem | 3-4 sessions / sem | 10-15 km ou 90 min | Hal Higdon Novice 2 / Daniels 2Q |
| **regular** | 50-80 km/sem | 4-5 sessions / sem | 18-25 km | Pfitzinger 55 mpw (≈ 88 km) / Hansons Just Finish |
| **competitive** | 80-120+ km/sem (doubles possibles) | 5-6 sessions / sem + cross-training | 30-35 km | Pfitzinger 70-85+ mpw / Daniels 4-week marathon |

Sources : [Pfitzinger's Advanced Marathoning — Fellrnr](https://fellrnr.com/wiki/Pfitzinger), [Pfitzinger Plan Pros & Cons — Running with Rock](https://runningwithrock.com/pfitzinger-marathon-plan/), [Couch to 5K Plan — NHS](https://www.nhs.uk/better-health/get-active/get-running-with-couch-to-5k/couch-to-5k-running-plan/), [Hansons Marathon Method — Marathon Handbook](https://marathonhandbook.com/hansons-marathon-method/).

### Périodisation

#### Cycle de base (build / deload)
- **3 semaines build + 1 deload** : volume deload = -20% du pic précédent. Standard pour `recreational` et `regular`.
- **2 build + 1 deload** : pour `competitive` (charge plus haute, récupération plus fréquente).
- **5-6 build + 1 deload** : pour `beginner` (charge faible, adaptation lente, semaine cutback en milieu de plan suffit).

#### Tapering compétition (long run > 25 km / objectif marathon ou semi)
- **J-14** : volume à ~60% du pic (réduction -40%).
- **J-7** : volume à ~50-60% du pic (réduction -40 à -50%).
- **J-3 à J-1** : 2-3 footings courts (20-30 min) en Z1-Z2 + quelques strides.
- **Fréquence maintenue** ≥ 80% des sessions habituelles (recommandation : raccourcir, pas supprimer).

Sources : [Marathon Taper Guide — Marathon Handbook](https://marathonhandbook.com/marathon-taper/), [Taper Science — Precision Hydration](https://www.precisionhydration.com/performance-advice/performance/how-to-taper-before-a-race/), [Longer Disciplined Tapers — PMC NIH](https://pmc.ncbi.nlm.nih.gov/articles/PMC8506252/).

#### Distribution d'intensité (polarized vs threshold)
**Choix de doctrine** : **polarized 80/20** par défaut pour `recreational`, `regular`, `competitive`. Justification : revue systématique 2024 (MDPI Sports) confirme polarized > threshold sur VO2max et économie de course chez l'endurant entraîné. Pour `beginner`, distribution simplifiée : 100% Z1-Z2 (pas d'intensité dure jusqu'à ce que la course continue 30 min soit acquise).

Sources : [80/20 Endurance — Seiler hierarchy](https://www.8020endurance.com/seilers-hierarchy-of-endurance-training-needs/), [Polarized Training Systematic Review — PMC NIH](https://pmc.ncbi.nlm.nih.gov/articles/PMC11679080/), [What is best practice for training intensity? — PubMed](https://pubmed.ncbi.nlm.nih.gov/20861519/).

#### Contradiction Daniels vs Hansons sur le long run
- **Daniels / Pfitzinger** : long run jusqu'à 32-35 km en pic marathon (≥ 25% du volume hebdo).
- **Hansons** : long run plafonné à 26 km, fait sur jambes fatiguées (cumulative fatigue).

**Choix de doctrine CoachingSage** : approche **Daniels/Pfitzinger** pour `regular` et `competitive` (long run absolu jusqu'à 30-35 km en pic marathon). Justification : public app majoritairement amateur, repère psychologique du long run important, cumulative fatigue Hansons exigeante (6 sessions/sem) et difficile à respecter sur un plan grand public. Mention Hansons comme alternative dans `safety_notes` du template marathon avancé.

### Substitutions classiques (alternatives v2)

Documenté au niveau `exercise.alternatives[]` dans le template :

| Exercice planifié | Substitution | Trigger |
|---|---|---|
| Sortie longue extérieure | Tempo continu sur tapis | Conditions extrêmes (canicule > 30°C, verglas) |
| VO2max (Daniels-I) | Tempo continu (Daniels-T) | Fatigue accumulée 3 sem, sommeil dégradé |
| Tempo route | Fartlek sur sentier | Terrain hostile, montagne, neige fraîche |
| Repetitions track (Daniels-R) | Strides 6-8 × 100m sur herbe | Pas d'accès piste, débutant intermédiaire |
| Course pied | Vélo elliptique 1:1.3 ratio temps | Knee-injury / shin-splints flare |

### Renforcement préventif (par niveau)

Hooks v2 : exercices marqués `volume_axis: reps` ou `sets`, à inclure dès W1.

- **beginner** : mollets (calf raises bipodal), core (planche, bird-dog), abducteurs hanche (clamshells pour ITBS) — DÈS W1, séance dédiée 1×/sem.
- **recreational** : ajout single-leg squat, pont fessier unilatéral, calf raises excentriques (protection Achille), 1-2 séances strength / sem.
- **regular** : nordic curl, hip thrust léger, drills neuromusculaires (skipping A-march, talons-fesses), 2 séances strength / sem.
- **competitive** : pliométrie modérée (box jumps low, bondissements), hip thrust chargé, deadlift léger, drills techniques 2-3×/sem.

Sources : [Shin Splint Review — PMC NIH](https://pmc.ncbi.nlm.nih.gov/articles/PMC9937638/), [Top 3 Runner Injuries — AdventHealth](https://www.adventhealth.com/hospital/adventhealth-orlando/blog/top-3-runner-injuries-prevention-and-treatment), [Strength Running — Injury Prevention](https://strengthrunning.com/running-injuries/).

### Drapeaux rouges (safety)

#### Tous niveaux
- **Shin splints (périostite tibiale)** : risque n°1 du débutant (6-16% des blessures running, jusqu'à 50% des blessures lower-leg). Stop séance, glace 15 min, repos 3+ jours. Cause : volume excessif, chaussures > 800 km, sol dur.
- **Fasciite plantaire** : douleur talon/arche au lever, étirements gastrocs + soléaire 2×/jour.
- **Tendinite Achille** : douleur derrière talon, calf raises excentriques, réduire volume -30%.
- **ITBS (syndrome bandelette ilio-tibiale)** : douleur face externe du genou. Clamshells préventifs, hip strength.
- **PFPS (genou du coureur)** : douleur antérieure rotule, single-leg squat technique.

#### Recreational et au-delà
- Tendinites ischio-jambiers sur fractionné mal échauffé.
- Stress fractures tibiales (volume + intensité combinés).

#### Competitive
- **RED-S** (Relative Energy Deficiency in Sport) : déficit énergétique chronique, signaux : aménorrhée, baisse perf, fatigue chronique.
- Surentraînement (FC repos +10 bpm chronique, sommeil dégradé, motivation effondrée 3+ semaines).

### Mots EU MDR à bannir (running spécifique)

Le master prompt exclut le vocabulaire qui constituerait un acte médical en UE (Med Device Regulation 2017/745).

**Bannis dans tout texte généré** :
- "soigner [pathologie]", "traitement [pathologie]", "guérir", "remède"
- "rééducation post-opératoire", "post-blessure"
- "cure", "thérapie", "diagnostic"
- "prescription", "ordonnance"
- "soulager [douleur]" (préférer : "réduire l'inconfort", "favoriser le confort")

**Triggers medical clearance obligatoire** (mention "Consulte un médecin avant de commencer ce programme") :
- Antécédents cardiaques connus (`cardiac-clearance-required` dans `incompatible_constraints`).
- Grossesse (`pregnancy`).
- Reprise post-blessure récente (< 6 mois sur knee/ankle/lower-back).
- Profil > 50 ans débutant complet.

### Hooks metadata standards (running)

Convention pour les 4 templates running.

#### `target_zone`
Valeurs autorisées :
- `Daniels-E`, `Daniels-M`, `Daniels-T`, `Daniels-I`, `Daniels-R`
- `@10K-pace`, `@5K-pace`, `@MP-10s/km`, `@HMP` (half-marathon pace)
- Pour marche / récup : `walking-recovery`
- Pour strength : pas de target_zone running, utiliser `RPE 6-7` ou `RPE 7-8`

#### `required_equipment`
Vocabulaire kebab-case :
- `running-shoes` : assumé partout, peut être omis
- `gps-watch` : optionnel mais recommandé `recreational`+, requis `regular`+ pour pacing
- `track` : optionnel pour Daniels-I et Daniels-R (alternatives : route plate calibrée, parc, tapis)
- `treadmill` : alternative tempo / récup en conditions extrêmes
- `heart-rate-monitor` : optionnel, secondaire au pacing
- `mat` : pour exercices renforcement au sol
- `resistance-band` : optionnel renforcement (clamshells avec bande, monster walks)

#### `incompatible_constraints`
Vocabulaire kebab-case (extrait du schéma v2) :
- `knee-injury`, `lower-back-pain`, `ankle-injury`, `shin-splints`
- `cardiac-clearance-required`, `pregnancy`, `postpartum-early`
- `no-track-access` (pour exercices Daniels-I / Daniels-R), `treadmill-only`

#### `alternatives`
Liste de noms d'exercices substitutifs (cf. tableau Substitutions ci-dessus). Format : noms tels qu'ils apparaissent dans `name` d'autres exercices du template ou nom standard reconnu.

#### `volume_axis`
- `duration` (par défaut pour blocs running, échauffement, cooldown)
- `distance` (sortie longue chiffrée en km, séance race-pace)
- `reps` (renforcement : clamshells, bird-dog, calf raises)
- `sets` (séances structurées : `sets: 6` × `duration: "1 min run + 1:30 walk"`)

### `week_structure` typique par niveau

| Niveau | type | micro_pattern | recovery_cadence |
|---|---|---|---|
| **beginner** | `linear` | `run/walk + strength + run/walk` (3 sessions, 1 strength) | `1 cutback W5 sur plan 8 sem` |
| **recreational** | `linear` | `easy + tempo + long` | `1 deload toutes les 4 semaines` |
| **regular** | `block` | `easy + intervals + tempo + easy + long` | `1 deload toutes les 3-4 semaines` |
| **competitive** | `polarized` | `easy + intervals + easy + tempo + easy + long` (+ double easy) | `1 deload toutes les 3 semaines` |

`deload_weeks` exemples :
- Plan 8 sem `beginner` : `[5]`
- Plan 12 sem `recreational` : `[4, 8]`
- Plan 16 sem `regular` : `[4, 8, 12]`
- Plan 18 sem `competitive` : `[4, 8, 12, 16]` + taper W17-W18 distinct

### Sources running

#### Doctrine et zones
- [VDOT Training Tables & How to Use Them — RunDNA](https://rundna.com/resources/run-training/vdot-training-tables-how-to-use-them/)
- [What Is a VDOT Score? Jack Daniels Running Formula Fully Explained — TheFastCalculator](https://thefastcalculator.com/what-is-a-vdot-score-jack-daniels-running-formula-fully-explained/)
- [Coaches Education — Determining your current level of fitness (Daniels)](https://www.coacheseducation.com/endur/jack-daniels-nov-00.php)
- [VDOT Calculator — STAS](https://stas.run/en/tools/vdot-calculator)
- [VDOTo2 Running Calculator](https://vdoto2.com/calculator)

#### Plans par niveau
- [Couch to 5K running plan — NHS Better Health](https://www.nhs.uk/better-health/get-active/get-running-with-couch-to-5k/couch-to-5k-running-plan/)
- [Couch to 5K week by week PDF — PITA](https://www.pita.org.uk/images/Couch_to_5k_29_July_2020.pdf)
- [Pfitzinger's Advanced Marathoning — Fellrnr](https://fellrnr.com/wiki/Pfitzinger)
- [Pfitzinger Marathon Plan: Pros and Cons — Running with Rock](https://runningwithrock.com/pfitzinger-marathon-plan/)
- [Hansons Marathon Method Pros and Cons — Marathon Handbook](https://marathonhandbook.com/hansons-marathon-method/)
- [Hansons Philosophy — Luke Humphrey Running](https://lukehumphreyrunning.com/hansons-philosophy/)

#### Distribution d'intensité (80/20 polarized)
- [Seiler's Hierarchy of Endurance Training Needs — 80/20 Endurance](https://www.8020endurance.com/seilers-hierarchy-of-endurance-training-needs/)
- [The Effect of Polarized Training on VO2max — Systematic Review 2024 PMC](https://pmc.ncbi.nlm.nih.gov/articles/PMC11679080/)
- [What is best practice for training intensity and duration distribution — PubMed](https://pubmed.ncbi.nlm.nih.gov/20861519/)

#### Tapering
- [Marathon Taper Complete Plan — Marathon Handbook](https://marathonhandbook.com/marathon-taper/)
- [Marathon Taper How Long Should You Taper — Marathon Handbook](https://marathonhandbook.com/optimal-marathon-taper-length/)
- [Longer Disciplined Tapers Improve Marathon Performance — PMC NIH](https://pmc.ncbi.nlm.nih.gov/articles/PMC8506252/)
- [The Science of Tapering — Precision Hydration](https://www.precisionhydration.com/performance-advice/performance/how-to-taper-before-a-race/)

#### Prévention blessures
- [Shin Splint: A Review — PMC NIH](https://pmc.ncbi.nlm.nih.gov/articles/PMC9937638/)
- [Top 3 Runner Injuries: Prevention and Treatment — AdventHealth](https://www.adventhealth.com/hospital/adventhealth-orlando/blog/top-3-runner-injuries-prevention-and-treatment)
- [Running Injuries Ultimate Guide — Strength Running](https://strengthrunning.com/running-injuries/)
- [5 Common Running Injuries and How to Prevent Them — Fleet Feet](https://www.fleetfeet.com/blog/5-common-running-injuries-and-how-to-prevent-them)

---

## CYCLING

### Doctrine référente

| Référence | Auteur | Application |
|---|---|---|
| **Training and Racing with a Power Meter** (3e éd.) | Hunter Allen, Andrew Coggan, Stephen McGregor | Zones FTP Z1-Z7, profil de puissance, périodisation FTP-based, sweet spot. |
| **The Cyclist's Training Bible** (5e éd.) | Joe Friel | Périodisation annuelle (Prep / Base / Build / Peak / Race), planification A-priority races, profils âge. |
| **British Cycling Sportive Plans** | British Cycling Federation / TrainingPeaks | Plans sportif 6-8h / 8-10h / 10+h selon expérience, base 8 sem. |
| **FasCat Sweet Spot Base** | Frank Overton (FasCat Coaching) | Bloc base 4-8h ou 10-16h hebdo selon plan, sweet spot 84-97% FTP. |
| **TrainerRoad Plan Builder** | TrainerRoad | Plans Low / Mid / High volume, polarized vs sweet spot selon profil. |
| **80/20 Cycling** | Matt Fitzgerald, David Warden / Stephen Seiler | Polarized adapté cycling, 80% LIT / 20% HIT validé en cyclisme (Neal et al. 2013, MDPI 2024). |

### Zones d'effort (target_zone)

Convention v2 : préfixe `FTP-` pour zones puissance (référentiel Coggan), `FC-` pour zones FC alternative (% FCmax), `RPE` pour effort perçu (renforcement / sans capteur).

| Zone | % FTP | % FCmax | RPE | Description | Application |
|---|---|---|---|---|---|
| **FTP-Z1** (Recovery) | < 55% | < 68% | 1-2 | Active recovery, conversational facile | Récup post-intervalle, récup post-bloc, échauffement |
| **FTP-Z2** (Endurance) | 56-75% | 69-83% | 2-3 | Conversational, base aérobie | Sortie longue, fond, endurance fondamentale |
| **FTP-Z3** (Tempo) | 76-90% | 84-94% | 3-4 | Comfortably hard | Tempo continu, sweet spot bas |
| **Sweet-Spot** | 88-94% (sous-bande Z3 haute / Z4 basse) | 92-97% | 3-4 | Optimum charge / temps | Bloc FasCat 30-90 min, intervalles longs |
| **FTP-Z4** (Threshold) | 91-105% | 95-105% | 4-5 | Lactate threshold, ~1h race effort | Intervalles 8-30 min × 2-4 reps |
| **FTP-Z5** (VO2max) | 106-120% | > 106% (max ou peak court) | 6-7 | VO2max | 3-8 min × 4-6 reps, récup 1:1 |
| **FTP-Z6** (Anaerobic) | 121-150% | non applicable | 8-10 | Anaérobie lactique | 30 sec - 2 min × 4-8 reps, récup 2-4× durée |
| **FTP-Z7** (Neuromuscular) | > 150% | non applicable | 10 | Sprint | 5-15 sec, récup complète |

Sources : [Hunter Allen Power Blog — Power Training Zones 101](https://www.hunterallenpowerblog.com/2015/05/power-training-zones-101.html), [Coggan Power Training Zone Calculator — Endurance Path](https://www.endurancepath.com/resources/coggan-power-training-zone-calculator/), [TrainingPeaks Zones Calculator Overview](https://help.trainingpeaks.com/hc/en-us/articles/360017420092-Zones-Calculator-Overview), [Coggan Power Meter PDF — IPMultisport](https://www.ipmultisport.com/ref_lib/Coggan_Power_Meter.pdf).

**Choix de doctrine** : on pace en **% FTP** par défaut (Coggan référentiel le plus établi en 2026). Pour cyclistes sans powermeter (`beginner`, `recreational` majorité), fournir équivalents `% FCmax` ET `RPE` dans `notes`. Sweet Spot promu en zone first-class car central dans `recreational`/`regular` (FasCat / TrainerRoad).

### Volume hebdo cible par niveau

**Convention volume cycling v2** : volume hebdo exprimé en **heures de pédalage pur** (effort sport-pur, hors warmup/cooldown courts < 10 min hors maison). Long ride exprimé en heures OU en km selon le contexte (longues sorties extérieures = km, blocs trainer = durée).

| Niveau | Vol pic (h/sem pédalage) | Fréquence | Long ride max | Doctrine source |
|---|---|---|---|---|
| **beginner** | 3-5 h/sem | 2-3 sessions / sem | 60-90 min ou 25-35 km | British Cycling Beginner 6-8 hpw (avec marges débutant), TrainerRoad Low Volume |
| **recreational** | 6-8 h/sem | 3-4 sessions / sem | 2-3 h ou 60-80 km | British Cycling Sportive Beginner-Intermediate, FasCat Sweet Spot Basic 4-8 hpw |
| **regular** | 9-12 h/sem | 4-5 sessions / sem | 3-4 h ou 100-120 km | Friel 12wk Build-Peak 12 hpw, FasCat Sweet Spot Advanced 10-16 hpw |
| **competitive** | 13-16+ h/sem | 5-6 sessions / sem | 5-6 h ou 150-200 km | Friel Cyclist Training Bible Race phase, British Cycling Advanced |

Sources : [British Cycling Sportive Training Plans](https://www.britishcycling.org.uk/membership/article/mem-trainingplans), [British Cycling 8-Week Base Beginner — TrainingPeaks](https://www.trainingpeaks.com/training-plans/cycling/tp-345613/british-cycling-8-week-base-training-plan-beginner-6-8-hours-per-week), [Sweet Spot Part 1 Basic — TrainingPeaks](https://www.trainingpeaks.com/training-plans/cycling/tp-105310/six-weeks-to-sweet-spot-part-1-basic), [Sweet Spot Part 1 Advanced — TrainingPeaks](https://www.trainingpeaks.com/training-plans/cycling/tp-105332/six-weeks-to-sweet-spot-advanced), [Friel 3-month Base Period — TrainingPeaks](https://www.trainingpeaks.com/training-plans/cycling/tp-67237/training-bible-3-month-cycling-base-period-program-6-to-10-5-hours-per-week).

### Périodisation

#### Cycle de base (build / deload)
- **3 build + 1 deload** : standard pour `recreational` et `regular`. Volume deload = -15 à -20% du pic précédent.
- **2 build + 1 deload** : pour `competitive` (charge plus haute, récupération plus fréquente).
- **5-6 build + 1 cutback** : pour `beginner` (charge faible, adaptation lente, 1 cutback en milieu de plan suffit).

Volume cutback `beginner` low-volume : -25 à -30% accepté (la charge absolue est faible, marge de récup utile).

#### Phases Friel
- **Base** : 12 sem, 80-90% du temps en Z1-Z2, sortie longue progressive, sweet spot introduit en Base 2-3.
- **Build** : 8-10 sem, 70% Z1-Z2 / 30% intensités spécifiques (Z3-Z4-Z5).
- **Peak** : 2-3 sem, simulations course / pré-A-event, volume -20% du Build pic.
- **Taper** (compétition) : 1-2 sem, volume -30 à -50% du Build pic, fréquence maintenue, intensités courtes conservées.

#### Tapering compétition (sportive longue, course route, gran fondo)
- **J-14** : volume à ~70% du pic.
- **J-7** : volume à ~50-60% du pic.
- **J-3 à J-1** : 2 sorties courtes 45-60 min en Z2 + 2-3 sprints courts (5-10 sec) à J-2 (réveil neuromusculaire).
- **Fréquence maintenue** ≥ 80% des sessions (raccourcir, pas supprimer).

Sources : [Joe Friel Build Period Overview](https://joefrieltraining.com/build-period-overview/), [Joe Friel's Cycling Training Plan Structure — Roadman Cycling](https://roadmancycling.com/podcast/ep-40-how-joe-friel-structures-the-ideal-cycling-training-week), [Joe Friel's Bible for Periodisation — Coach Ray](https://www.coachray.nz/2021/10/18/joe-friels-bible-for-periodisation/).

#### Distribution d'intensité (polarized vs sweet spot)
**Choix de doctrine** :
- **`beginner`** : 100% Z1-Z2 (FTP-Z2 majoritaire), pas d'intensité dure jusqu'à ce que le profil tienne 60 min en continu confortable.
- **`recreational`** : **sweet-spot dominant** en bloc base (40-50% du volume sur sweet spot 88-94% FTP), 50-60% Z2. Pas de polarized strict (volume insuffisant pour absorber 80% LIT).
- **`regular`** : **polarized 80/20** en phase build (80% Z1-Z2, 20% Z4-Z5). Bloc sweet spot accepté en base seulement.
- **`competitive`** : **polarized 80/20** dominant, mais semaines de spécificité (@FTP, blocs montagne, simulations course) peuvent dériver vers 70/10/20 (polarized "souple"). Annoncer un range 75-85% LIT et expliciter dans `progression_logic`.

Justification : revue systématique 2024 (MDPI Sports) confirme polarized > threshold sur VO2max et économie cycliste entraîné. Étude Neal et al. 2013 (12 cyclistes) : polarized +8% peak power output vs +3% threshold sur 6 semaines. Mais sweet spot reste validé pour temps-limité (FasCat / TrainerRoad), où volume LIT total impossible à atteindre.

Sources : [Polarized Training VO2max Systematic Review 2024 — PMC](https://pmc.ncbi.nlm.nih.gov/articles/PMC11679080/), [Comparison Polarized vs Other Training — PMC](https://pmc.ncbi.nlm.nih.gov/articles/PMC11329428/), [Recent advances training intensity distribution — PMC](https://pmc.ncbi.nlm.nih.gov/articles/PMC12568352/), [Complete Guide to Polarized Training — Fast Talk Labs](https://www.fasttalklabs.com/pathways/polarized-training/), [Sweet Spot Training Plan Design — FasCat](https://shopify-proxy.fascatcoaching.com/blogs/training-tips/sweet-spot-training-plan-design-the-fascat-way), [Sweet Spot vs Zone 2 — FasCat](https://fascatcoaching.com/blogs/training-tips/sweet-spot-versus-zone-2-training-plan-design), [Base Training for Cycling — TrainerRoad](https://www.trainerroad.com/training-base-phase).

### Cadence cible

| Contexte | Cadence cible (rpm) | Application |
|---|---|---|
| Plat / endurance Z2 | 85-95 rpm | Sortie longue, fond, conversational |
| Sweet spot / FTP-Z3-Z4 | 85-95 rpm | Intervalles tempo, bloc sweet spot |
| Côte modérée (3-7%) | 75-85 rpm | Côtes longues, FTP-Z3-Z4 sur pente |
| Côte raide (> 8%) | 70-80 rpm | Préserver le genou, ne pas grinder < 65 rpm |
| Intervalles haute cadence | 100-110+ rpm | Drills réactivité, sprint train, neurom. |
| Force / SFR (force-vitesse-réduite) | 50-60 rpm sur gros braquet | Hors-saison régulier+ uniquement, à dose modérée (genou) |

**Règle débutant** : ne pas grinder < 65 rpm, surtout en montée. Cadence basse + force élevée = risque genou. Cadence > 90 préservera le système musculaire au profit du cardio.

Sources : [What's the Best Cycling Cadence — ROUVY](https://rouvy.com/blog/cycling-cadence-optimal-rpm-guide), [Cycling Cadence: Optimal RPM — TrainerRoad](https://www.trainerroad.com/blog/whats-the-most-efficient-cycling-cadence-and-how-cadence-drills-can-make-you-faster/), [The Optimal Cadence — 2PEAK](https://blog.2peak.com/en/the-optimal-cadence/).

### Substitutions classiques (alternatives v2)

Documenté au niveau `exercise.alternatives[]` dans le template :

| Exercice planifié | Substitution | Trigger |
|---|---|---|
| Sortie longue extérieure | Bloc trainer indoor (durée -15 à -20% pour équivalence) | Météo (pluie, verglas, > 35°C, < 0°C), pollution, trafic anxiogène |
| Intervalles route | Intervalles trainer (ERG mode) | Pas de route plate calibrée, sécurité, contrôle wattage strict |
| Bloc sweet spot 90 min | 2 × 45 min sweet spot (split AM/PM) | Contrainte horaire / fenêtres courtes |
| VO2max FTP-Z5 | Tempo continu FTP-Z3 ou sweet spot | Fatigue 3 sem, sommeil dégradé, charge cumulée élevée |
| Vélo de route | VTT / gravel sur sentier roulant | Pas d'accès route sécurisée, envie variation |
| Cyclisme | Vélo elliptique / rameur 1:1 ratio temps en Z2 | Knee-flare aigu, lower-back-pain aigu, accident vélo récent |
| Gros braquet basse cadence (SFR) | Bloc sweet spot cadence libre | Knee-injury, débutant, manque de muscu pré-saison |

### Renforcement préventif (par niveau)

Hooks v2 : exercices marqués `volume_axis: reps` ou `sets`, à inclure dès W1.

- **beginner** : core (planche ventrale, bird-dog), gainage gainage dorsal, pont fessier bipodal, calf raises bipodal — 1 séance dédiée 1×/sem dès W1, 15-20 min.
- **recreational** : ajout single-leg squat, hip thrust léger, gainage latéral, étirements quadriceps + ischios + psoas (cycliste = hanches courtes), 1 séance strength + 1 mobilité / sem.
- **regular** : ajout deadlift roumain léger, step-up, drills proprio (single-leg balance), 1-2 séances strength / sem en hors-saison, 1 séance maintien en saison.
- **competitive** : pliométrie modérée hors-saison (box jumps, bondissements), squat / deadlift chargé hors-saison, 2 séances strength / sem hors-saison, 1 séance maintien en saison + drills techniques (sprint start, accélération out-of-saddle).

Sources : [Cycling Pain & Injury Prevention with Bike Fit — MyVeloFit](https://www.myvelofit.com/insights/pain-and-injury-prevention/), [Knee Pain Bike Fit Basics — Bike Fit Adviser](https://www.bikefitadviser.com/blog/knee-pain-bike-fit-basics-jh), [Riding With Relief: Cycling-Related Low Back Pain — MyWhoosh](https://mywhoosh.com/riding-with-relief-understanding-and-addressing-cycling-related-low-back-pain/).

### Drapeaux rouges (safety)

#### Tous niveaux
- **Lombalgie cycliste** : 40-60% des cyclistes. Cause n°1 = position de selle / cintre (reach trop long, selle trop haute / nez trop bas, hanches désalignées). Si douleur > 2 sorties consécutives → bike fit professionnel.
- **Douleur antérieure du genou** (genou cycliste) : selle trop basse / trop avancée, cale mal positionnée, cadence trop basse sur gros braquet. Vérifier hauteur selle (genou flexion 25-30° en bas du pédalage).
- **Douleur postérieure du genou** : selle trop haute. Diminuer 5-10 mm.
- **Hot foot / engourdissement avant-pied** : chaussures trop serrées, cales trop avancées, longue exposition sur grosse pente. Aérer aux arrêts, vérifier réglage cale.
- **Cervicalgie / shoulder strain** : reach trop long, cintre trop bas. Réduire stack ou allonger potence.
- **Sécurité trafic** : casque obligatoire à chaque sortie, éclairages avant/arrière obligatoires en faible visibilité, fluo/réflexe en hiver. Ne jamais rouler sans casque (mention `safety_notes`).

#### Recreational et au-delà
- **Tendinite achille** sur SFR / cadence basse répétée, calf raises excentriques en remède préventif.
- **Syndrome compartimental** sur sortie chaleur intense + hydratation insuffisante (rare).
- **Saddle sores / chamois pressure** : crème chamois sortie > 90 min, cuissard quality, hygiène stricte.

#### Competitive
- **RED-S** (Relative Energy Deficiency in Sport) : déficit énergétique chronique, signaux : aménorrhée, baisse perf, fatigue chronique, immunité dégradée.
- **Surentraînement** : FC repos +10 bpm chronique, sommeil dégradé, motivation effondrée 3+ semaines, baisse FTP test consécutive.
- **Coup de chaleur** sur événement long été : hydratation salée 500-750 ml/h chaleur > 25°C, écouter signaux (céphalée, frissons, désorientation = STOP immédiat).

Sources : [Cycling knee pain explained — BikeRadar](https://www.bikeradar.com/advice/fitness-and-training/cycling-knee-pain-the-problem-areas), [How the Wrong Bike Seat Height — BraceAbility](https://www.braceability.com/blogs/articles/cycling-knee-pain-seat-height), [Bike seat height adjustment — UF Med PDF](https://pmr.med.ufl.edu/wordpress/files/2022/09/Bike-seat-height-adjustment-to-reduce-pain-onset.pdf).

### Nutrition longue sortie (> 90 min)

- **60-90 g glucides/h** pour sortie > 90 min (ratio 2:1 glucose:fructose au-delà de 60 g/h).
- **Hydratation** : 500-750 ml/h en conditions tempérées, 750-1000 ml/h chaleur > 25°C, sodium 300-700 mg/L (chamois compris si grosse transpiration).
- **Avant** : 1-2 h avant départ, 30-60 g glucides + caféine optionnelle.
- **Après** : fenêtre 30 min, ratio glucides:protéines 3:1 ou 4:1, 1.0-1.2 g glucides/kg + 0.3 g protéines/kg.
- **Gut training** : si profil non habitué à 90 g/h, démarrer 30 g/h en sortie longue d'entraînement et progresser sur 4-6 semaines.

Sources : [How Many Carbs for Cycling — Road Cycling Academy](https://roadcyclingacademy.com/how-many-carbs-for-cycling-performance/), [How Many Carbs Per Hour on the Bike — CTS](https://trainright.com/how-many-carbohydrates-per-hour-on-the-bike/), [Cycling Nutrition Everything You Need — TrainerRoad](https://www.trainerroad.com/blog/cycling-nutrition-everything-you-need-to-know/), [Precision Hydration — Carbs per Hour](https://www.precisionhydration.com/performance-advice/nutrition/how-much-carbohydrate-carbs-athletes-per-hour/).

### Mots EU MDR à bannir (cycling spécifique)

Le master prompt exclut le vocabulaire qui constituerait un acte médical en UE (Med Device Regulation 2017/745).

**Bannis dans tout texte généré** :
- "soigner [pathologie]", "traitement [pathologie]", "guérir", "remède"
- "rééducation post-opératoire", "post-blessure", "post-accident"
- "cure", "thérapie", "diagnostic", "prescription", "ordonnance"
- "soulager [douleur]" (préférer : "réduire l'inconfort", "favoriser le confort")
- "réparer le genou / le dos" (préférer : "renforcer", "stabiliser")

**Triggers medical clearance obligatoire** (mention "Consulte un médecin avant de commencer ce programme") :
- Antécédents cardiaques connus (`cardiac-clearance-required`).
- Grossesse (`pregnancy`) — cycling Z2 reste accessible mais avis médical de principe.
- Reprise post-accident ou post-chirurgie (< 6 mois sur lower-back, knee, shoulder, clavicule).
- Profil > 50 ans débutant complet sans test effort récent.

### Hooks metadata standards (cycling)

#### `target_zone`
Valeurs autorisées :
- `FTP-Z1`, `FTP-Z2`, `FTP-Z3`, `FTP-Z4`, `FTP-Z5`, `FTP-Z6`, `FTP-Z7`
- `Sweet-Spot` (zone first-class, 88-94% FTP)
- `RPE 4-5`, `RPE 6-7`, `RPE 7-8`, `RPE 8-9` (cyclistes sans powermeter ou renforcement)
- `walking-recovery` non applicable cycling — utiliser `FTP-Z1` pour récup active

#### `required_equipment`
Vocabulaire kebab-case :
- `helmet` : OBLIGATOIRE à toute sortie route / VTT / gravel — mentionner explicitement, ne JAMAIS omettre.
- `road-bike`, `mtb`, `gravel-bike` : choisir selon contexte template (template cycling = `road-bike` par défaut).
- `indoor-trainer` ou `smart-trainer` : alternative météo / hiver / contrôle wattage (sweet spot, intervalles).
- `power-meter` : optionnel `recreational`, recommandé `regular`+, indispensable `competitive` pour pacing FTP.
- `heart-rate-monitor` : alternative ou complément power.
- `gps-watch` ou `bike-computer` : recommandé `recreational`+ pour segmentation séances.
- `cycling-shoes`, `cleats` : assumé `recreational`+, optionnel `beginner` (plats acceptés).
- `bidons` (× 2 pour sortie > 90 min), `front-light`, `rear-light`, `reflective-vest` (sécurité).
- `mat`, `resistance-band`, `dumbbells` (renforcement à domicile).

#### `incompatible_constraints`
Vocabulaire kebab-case :
- `lower-back-pain`, `knee-injury`, `cervical-injury`, `shoulder-injury`, `wrist-injury` (carpal tunnel)
- `cardiac-clearance-required`, `pregnancy`, `postpartum-early`
- `no-bike` (assomption faux pour template cycling — flag de garde si profil mal renseigné)
- `no-trainer` (impacte alternative indoor)
- `no-power-meter` (impacte précision pacing FTP, fallback FC ou RPE requis)
- `outdoor-only` ou `indoor-only` (préférence trainer)
- `apartment-noise` (trainer indoor en immeuble — proposer alternative spinning rolling silencieuse)
- `traffic-anxiety` (privilégier indoor / pistes cyclables / heures creuses)

#### `alternatives`
Liste de noms d'exercices substitutifs (cf. tableau Substitutions ci-dessus). Au minimum 1-2 alternatives réalistes par exercice. `alternatives: []` vide non-toléré.

#### `volume_axis`
- `duration` (par défaut pour intervalles, blocs sweet spot, échauffement, cooldown, sortie longue trainer)
- `distance` (sortie longue extérieure km cible, séance test FTP 20 min équivalent)
- `reps` (renforcement musculaire : squat, hip thrust, calf raises)
- `sets` (séance structurée : `sets: 5` × `duration: "5 min FTP-Z5 + 5 min FTP-Z1"`)
- `elevation` (séance côte chiffrée en D+ : "1000 m D+ en bloc Z3-Sweet-Spot") — usage `regular`+ uniquement

### `week_structure` typique par niveau

| Niveau | type | micro_pattern | recovery_cadence |
|---|---|---|---|
| **beginner** | `linear` | `endurance Z2 court + strength + endurance Z2 long` (2-3 sessions, 1 strength) | `1 cutback W4-W5 sur plan 8 sem` |
| **recreational** | `linear` | `endurance Z2 + sweet spot bloc + long ride` | `1 deload toutes les 4 semaines` |
| **regular** | `block` | `recovery Z1 + intervals Z4-Z5 + sweet spot + endurance + long ride` | `1 deload toutes les 3-4 semaines` |
| **competitive** | `polarized` | `recovery Z1 + intervals Z5 + endurance Z2 + threshold Z4 + endurance Z2 + long ride` | `1 deload toutes les 3 semaines` |

`deload_weeks` exemples :
- Plan 8 sem `beginner` : `[5]`
- Plan 12 sem `recreational` : `[4, 8]`
- Plan 16 sem `regular` : `[4, 8, 12]`
- Plan 18 sem `competitive` : `[4, 8, 12, 16]` + taper W17-W18 distinct

### Sources cycling

#### Doctrine et zones FTP
- [Hunter Allen Power Blog — Power Training Zones 101](https://www.hunterallenpowerblog.com/2015/05/power-training-zones-101.html)
- [Coggan Power Training Zone Calculator — Endurance Path](https://www.endurancepath.com/resources/coggan-power-training-zone-calculator/)
- [Power Zone Calculator (Coggan Z1-Z7) — Cycling Regimen](https://cyclingregimen.com/tools/power-zones)
- [TrainingPeaks Zones Calculator Overview](https://help.trainingpeaks.com/hc/en-us/articles/360017420092-Zones-Calculator-Overview)
- [Coggan Power Meter PDF — IPMultisport](https://www.ipmultisport.com/ref_lib/Coggan_Power_Meter.pdf)
- [Joe Friel's Quick Guide to Setting Zones — TrainingPeaks](https://www.trainingpeaks.com/learn/articles/joe-friel-s-quick-guide-to-setting-zones/)

#### Plans par niveau / volume
- [British Cycling Sportive Training Plans](https://www.britishcycling.org.uk/membership/article/mem-trainingplans)
- [British Cycling 8-Week Base Beginner — TrainingPeaks](https://www.trainingpeaks.com/training-plans/cycling/tp-345613/british-cycling-8-week-base-training-plan-beginner-6-8-hours-per-week)
- [Sweet Spot Part 1 Basic — TrainingPeaks](https://www.trainingpeaks.com/training-plans/cycling/tp-105310/six-weeks-to-sweet-spot-part-1-basic)
- [Sweet Spot Part 1 Advanced — TrainingPeaks](https://www.trainingpeaks.com/training-plans/cycling/tp-105332/six-weeks-to-sweet-spot-advanced)
- [Friel 3-month Base Period — TrainingPeaks](https://www.trainingpeaks.com/training-plans/cycling/tp-67237/training-bible-3-month-cycling-base-period-program-6-to-10-5-hours-per-week)
- [Bike Road Racing Build-Peak Advanced 12hpw Power — TrainingPeaks](https://www.trainingpeaks.com/training-plans/cycling/road-cycling/tp-140977/new-bike-road-racing-build-peak-plan-advanced-12hpw-power-meter-11-weeks)

#### Périodisation Friel
- [Joe Friel Build Period Overview](https://joefrieltraining.com/build-period-overview/)
- [Joe Friel's Cycling Training Plan Structure — Roadman Cycling](https://roadmancycling.com/podcast/ep-40-how-joe-friel-structures-the-ideal-cycling-training-week)
- [Joe Friel's Bible for Periodisation — Coach Ray](https://www.coachray.nz/2021/10/18/joe-friels-bible-for-periodisation/)

#### Sweet Spot (FasCat / TrainerRoad)
- [Sweet Spot Training Plan Design the FasCat Way](https://shopify-proxy.fascatcoaching.com/blogs/training-tips/sweet-spot-training-plan-design-the-fascat-way)
- [Sweet Spot vs Zone 2 Training Plan Design — FasCat](https://fascatcoaching.com/blogs/training-tips/sweet-spot-versus-zone-2-training-plan-design)
- [How Much Sweet Spot Training Should You Do — FasCat](https://fascatcoaching.com/blogs/training-tips/how-much-sweet-spot-training/)
- [Base Training for Cycling and Triathlon — TrainerRoad](https://www.trainerroad.com/training-base-phase)
- [The Basics of Base Training — TrainerRoad](https://support.trainerroad.com/hc/en-us/articles/115005927463-The-Basics-of-Base-Training)

#### Distribution polarized 80/20
- [Polarized Training VO2max Systematic Review 2024 — PMC](https://pmc.ncbi.nlm.nih.gov/articles/PMC11679080/)
- [Comparison Polarized vs Other Training Meta-analysis — PMC](https://pmc.ncbi.nlm.nih.gov/articles/PMC11329428/)
- [Recent advances training intensity distribution — PMC](https://pmc.ncbi.nlm.nih.gov/articles/PMC12568352/)
- [Complete Guide to Polarized Training with Dr. Stephen Seiler — Fast Talk Labs](https://www.fasttalklabs.com/pathways/polarized-training/)
- [Low Risk High Reward Polarized Method for Cyclists — Strava](https://stories.strava.com/articles/low-risk-high-reward-the-polarized-training-method-for-cyclists)

#### Cadence
- [What's the Best Cycling Cadence — ROUVY](https://rouvy.com/blog/cycling-cadence-optimal-rpm-guide)
- [Cycling Cadence: Optimal RPM and Drills — TrainerRoad](https://www.trainerroad.com/blog/whats-the-most-efficient-cycling-cadence-and-how-cadence-drills-can-make-you-faster/)
- [The Optimal Cadence — 2PEAK](https://blog.2peak.com/en/the-optimal-cadence/)

#### Prévention blessures et bike fit
- [Cycling Pain & Injury Prevention with Bike Fit — MyVeloFit](https://www.myvelofit.com/insights/pain-and-injury-prevention/)
- [Knee Pain Bike Fit Basics — Bike Fit Adviser](https://www.bikefitadviser.com/blog/knee-pain-bike-fit-basics-jh)
- [Cycling knee pain explained — BikeRadar](https://www.bikeradar.com/advice/fitness-and-training/cycling-knee-pain-the-problem-areas)
- [How the Wrong Bike Seat Height Causes Knee Pain — BraceAbility](https://www.braceability.com/blogs/articles/cycling-knee-pain-seat-height)
- [Bike seat height adjustment reduces injury risk — UF PDF](https://pmr.med.ufl.edu/wordpress/files/2022/09/Bike-seat-height-adjustment-to-reduce-pain-onset.pdf)
- [Riding With Relief: Cycling-Related Low Back Pain — MyWhoosh](https://mywhoosh.com/riding-with-relief-understanding-and-addressing-cycling-related-low-back-pain/)

#### Nutrition longue sortie
- [How Many Carbs for Cycling Performance — Road Cycling Academy](https://roadcyclingacademy.com/how-many-carbs-for-cycling-performance/)
- [How Many Carbohydrates Per Hour on the Bike — CTS](https://trainright.com/how-many-carbohydrates-per-hour-on-the-bike/)
- [Cycling Nutrition Everything You Need to Know — TrainerRoad](https://www.trainerroad.com/blog/cycling-nutrition-everything-you-need-to-know/)
- [How much carbohydrate per hour — Precision Hydration](https://www.precisionhydration.com/performance-advice/nutrition/how-much-carbohydrate-carbs-athletes-per-hour/)
- [The Science of Gut Training — EF Pro Cycling](https://www.efprocycling.com/tips-recipes/tour-de-france-tips-gut-training/)

## SWIMMING

_Sera ajoutée Phase C — doctrine Maglischo CSS / EN1-EN3-SP1-SP3 / Sheila Taormina freestyle._

## STRENGTH

_Sera ajoutée Phase C — doctrine Israetel RP / Helms Muscle & Strength / NSCA / 5/3/1 Wendler._

## YOGA

_Sera ajoutée Phase C — doctrine Hatha Vinyasa / Iyengar alignment / Krishnamacharya._

## HIIT

_Sera ajoutée Phase C — doctrine Tabata / Gibala / EMOM CrossFit framework._

## HIKING

_Sera ajoutée Phase C — doctrine Uphill Athlete (Steve House) / progression dénivelé hebdo._

## TENNIS

_Sera ajoutée Phase C — doctrine Saviano / USPTA / cardio intermittent + drills._

## FOOTBALL

_Sera ajoutée Phase C — doctrine FFF préparation physique / agilité, plyo, intermittent runs._

## TRIATHLON

_Sera ajoutée Phase C — doctrine Friel Triathlete's Training Bible / brick sessions / 3-discipline parallèle._
