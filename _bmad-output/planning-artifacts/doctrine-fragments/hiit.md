# Doctrine — HIIT (High-Intensity Interval Training)

Référentiel public sourcé pour la regen des templates HIIT (Story 0.5.10) et l'algo deterministic local Story 3.3a.

**Last revised** : 2026-04-30.

**Vocabulaire de niveau** (aligné enums Sport + Level Story 0.5.8) :
- `beginner` : aucune ou très peu d'expérience (< 6 mois) en cardio structuré, pas de pratique force, intolérance possible à l'effort soutenu, vise mise en route progressive avec ratios doux et mouvements bodyweight low-impact.
- `recreational` : pratique 1-2× / sem depuis 3-6 mois, capable d'enchaîner 20 min cardio modéré, hip hinge basique acquis (ou apprenable), vise format Tabata simple + EMOM 10-15 min sur jumping jacks / mountain climbers / squat-air.
- `regular` : pratique 3-4× / sem depuis ≥ 1 an, hip hinge maîtrisé, squat profond OK, capable de Tabata complet 8 rounds + EMOM 15-20 min, kettlebell swings et box jumps low intégrables, vise condition métabolique et conditioning circuit.
- `competitive` : pratique 5-6× / sem depuis ≥ 2 ans, polyvalent (force + endurance), maîtrise mouvements olympiques basiques (clean, snatch power), capable d'AMRAP exigeants 20 min, vise peak condition CrossFit-style ou athlète sport co / combat.

---

## Doctrine référente

| Référence | Auteur(s) / Source | Application |
|---|---|---|
| **ACSM Position Stand sur HIIT** (2014, ACSM's Health & Fitness Journal) | Kravitz, Wingo, ACSM | Définition formelle HIIT : work 15 sec - 4 min à 80-95% FCmax, recovery 40-50% FCmax, 6-10 répétitions, 10-40 min total. Warmup/cooldown 5-10 min obligatoires. |
| **Tabata 1996 original** (Med Sci Sports Exerc) | Izumi Tabata, Nishimura, Kouzaki et al. | Protocole 20s ON / 10s OFF × 8 rounds = 4 min à 170% VO2max sur ergocycle. +28% capacité anaérobie + +14% VO2max en 6 sem. Doit être réellement "all-out" ou perd l'effet. |
| **Gibala Lab — McMaster University** (PLOS One 2016, Gibala et al.) | Martin Gibala, Jonathan Little | SIT format 1 min HIT cumulé : 3×20 sec all-out à ~500W + 2 min récup à 50W, total 10 min séance. +19% VO2max sur 12 sem comparable à 45 min MICT. |
| **Joint ACSM/ESSA Consensus Statement on Exercise Intensity Terminology** (2024, Journal of Science and Medicine in Sport) | ACSM + Exercise and Sport Science Australia | Convention vocabulaire HIIT vs SIT vs MICT, intensités par RPE et %HRmax/%HRR, prescription par populations. |
| **NSCA — Time-Efficient Training Approach** | NSCA Personal Trainer Quarterly | Frequency 2-3 séances HIIT / sem, 48 h récup minimum entre sessions, balance avec MICT. |
| **MyProtein HIIT Guide** | MyProtein editorial team | Référence grand public pour ratios (1:2 débutant, 1:1 intermédiaire, 2:1 avancé), formats Tabata / 30/30 / 40/20, exemples mouvements. |
| **NCSF Guidelines on HIIT** | National Council on Strength & Fitness | Programmation HIIT pour clientèle générale, screening obligatoire (PAR-Q), précautions populations à risque cardiaque. |

---

## Zones d'effort (target_zone)

Convention v2 : `Tabata 20/10`, `30/30`, `40/20`, `EMOM`, `AMRAP` (formats first-class), `RPE` (effort perçu pour work / rest), `RPE 6-7` (warmup), `walking-recovery` (cooldown).

| Zone | %FCmax | RPE | Description | Application |
|---|---|---|---|---|
| `RPE 6-7` | 65-75% | 6-7 | Warmup actif progressif, low-impact | Échauffement 5-10 min obligatoire avant tout work HIT |
| `RPE 8-9` | 85-95% | 8-9 | All-out / near-all-out, **work intervals** | Phase work Tabata, 30/30, 40/20, EMOM, AMRAP |
| `RPE 9-10` | > 95% (peak court) | 10 | All-out supramaximal Tabata strict | Tabata strict 20/10 × 8 (`competitive`, `regular` validé) |
| `RPE 2-3` | 40-55% | 2-3 | **Rest interval actif** (marche sur place, easy step, mobilité légère) | Phase rest entre work intervals, recovery EMOM |
| `walking-recovery` | < 50% | 1-2 | Marche active, mobilité douce | Cooldown 5-10 min, transitions inter-blocks |
| `Tabata 20/10` | n/a | 9-10 work / 2-3 rest | Format first-class : 20 sec work / 10 sec rest × 8 rounds = 4 min | Bloc Tabata pur (`regular`+) |
| `30/30` | n/a | 8-9 work / 2-3 rest | 30 sec work / 30 sec rest, ratio 1:1 | Format intermédiaire (`recreational`+) |
| `40/20` | n/a | 8-9 work / 2-3 rest | 40 sec work / 20 sec rest, ratio 2:1 | Format intermédiaire-avancé (`regular`+) |
| `EMOM` | n/a | 7-8 work | Every Minute On the Minute : reps fixes au top de chaque minute, repos = temps restant | Conditioning structuré 10-20 min (`recreational`+) |
| `AMRAP` | n/a | 7-9 work | As Many Rounds As Possible : circuit en boucle pendant durée fixée | Conditioning open 10-20 min (`regular`+) |

**Choix de doctrine motivé** :
- On combine **Tabata strict** (référentiel 1996) ET **Gibala 1-min protocol** (référentiel moderne McMaster). Tabata reste pertinent pour `regular`/`competitive` qui peuvent réellement atteindre 170% VO2max sur ergocycle ou rower. Gibala 1-min (3×20 sec all-out + 2 min récup) plus accessible et applicable bodyweight.
- **`beginner` n'utilise JAMAIS Tabata strict** : ratio 1:0.5 trop agressif. Démarrer ratios doux 1:2 (30/60) ou 1:1 (30/30 RPE 7-8).
- **`recreational`** introduit Tabata 20/10 simple sur mouvements low-skill (jumping jacks, mountain climbers, squat-air), **4-6 rounds maximum** (pas 8 rounds tout de suite).
- **`regular`** Tabata complet 8 rounds + EMOM 10-15 min + AMRAP 12 min OK.
- **`competitive`** : tous formats, AMRAP 20 min OK, blocs métaboliques 16-20 min HIT cumulé, mouvements olympiques basiques OK.
- **RPE en convention principale** : pas de %HRmax strict tant qu'un test FC max n'a pas été fait, RPE 8-9 work / RPE 2-3 rest universellement applicable.

**RPE expliqué en W1 J1 obligatoire** : la première séance définit la grille (RPE 7 = essoufflé mais peut sortir 1 phrase, RPE 8-9 = parler 2-3 mots max, RPE 10 = incapacité à parler) dans `notes` du premier exercice ou warmup block.

---

## Volume hebdo cible — HIT cumulé par niveau

**Convention CoachingSage** : volume hebdo HIT = **temps cumulé en RPE 8+ effectif** (work intervals seuls, hors warmup/cooldown/rest intervals/transitions). Référence ACSM : limiter HIT à 20-40 min/sem au-dessus de 90% FCmax.

| Niveau | HIT cumulé (min/sem) | Fréquence séances HIT | Récup inter-séances | Doctrine source |
|---|---|---|---|---|
| **beginner** | **4-8 min/sem** (1-2 séances de 4 min HIT, ratios 1:2, blocs 30/60) | 2× / sem max | **≥ 48 h** (jamais 2 jours consécutifs) | ACSM 2014 minimum dose, NCSF beginner screening |
| **recreational** | **8-12 min/sem** (2 séances de 4-6 min HIT, format Tabata simple 4-6 rounds + EMOM court) | 2× / sem | ≥ 48 h | ACSM 2014 conservatif, NSCA time-efficient |
| **regular** | **12-18 min/sem** (2-3 séances avec Tabata complet 8 rounds, EMOM 15 min, AMRAP 12 min) | 2-3× / sem | ≥ 48 h sur même type / 24 h sur format différent | ACSM 2014 cible standard, Gibala SIT 12 sem |
| **competitive** | **16-24 min/sem** (3 séances HIT, peak weeks jusqu'à 20-24 min HIT cumulé, AMRAP 20 min + blocs métaboliques) | 3× / sem max | ≥ 48 h sur même type | ACSM 2014 limite haute (30-40 min/sem au-dessus 90% FCmax), conditioning CrossFit-style |

**Convention CoachingSage** : on annonce dans `summary` le **HIT cumulé hebdo cible** + nombre de séances HIT/sem. Exemple `regular` 8 sem : "12 min HIT cumulé/sem en pic, 2-3 séances HIT/sem (Tabata 8 rounds + EMOM 15 min)". `progression_logic` détaille la dose-response ACSM + référence Tabata 1996 / Gibala 2016.

**Pas de double-HIT consécutif** : règle absolue, jamais 2 séances HIT sur 2 jours consécutifs (sauf `competitive` peak avec coach humain — exclu CoachingSage). Repos actif (mobilité, marche) ou MICT léger possible le lendemain.

---

## Périodisation HIT

### Cycle de base (build / cutback)

- **`beginner`** : 5-6 build + 1 cutback (-25 à -30% durée HIT cumulée, peut sauter 1 séance HIT). Plan 8 sem → cutback W4-W5.
- **`recreational`** : 3 build + 1 deload (-15 à -20% durée HIT). Plan 8-12 sem → deload W4, W8.
- **`regular`** : 3 build + 1 deload (-15 à -25% durée HIT). Plan 12 sem → deload W4, W8.
- **`competitive`** : 3 build + 1 deload (-15 à -25% durée HIT). Plan 12 sem → deload W4, W8, W12.

**Cutback W4/W8 doctrine -15 à -25% durée HIT cumulée** : stricter que running (-15 à -20%), plus souple que strength (-40 à -50%). Justification : la charge cardiaque + métabolique HIT est forte mais moins articulaire que strength heavy, l'adaptation neuro-cardiaque demande des cutbacks mais pas une suppression complète.

### Cycle de fond (modèle Gibala / ACSM)

- **Phase 1 — Acclimatation** (W1-W2) : ratios doux (1:2, 1:1), 1 séance HIT/sem, mouvements bodyweight low-impact, 4 min HIT cumulé maximum.
- **Phase 2 — Build** (W3-W6) : introduction Tabata 4-6 rounds (`recreational`+), Tabata 8 rounds (`regular`+), EMOM 10-15 min, 2 séances HIT/sem.
- **Phase 3 — Specialization** (W7-W10 selon plan) : AMRAP exigeants, formats variés, peak weeks 16-20 min HIT cumulé (`regular`/`competitive`).
- **Phase 4 — Test & Consolidation** (dernière sem) : checklist d'autonomie, séance phare, validation de la grille RPE acquise.

### Tapering (plans avec objectif test fitness ou compétition CrossFit-style)

Si plan vise un test chiffré (Tabata 8 rounds tenu, AMRAP 12 min total reps, FRAN time, etc.) :
- J-7 : volume HIT à ~60% du pic, garder 1 séance qualité courte (4 min HIT).
- J-3 à J-1 : warmup léger + 1 série courte de réveil neuromusculaire (5-10 sec sprints), pas de séance HIT max.
- Fréquence ≥ 80% des sessions habituelles (raccourcir, pas supprimer).

---

## Mouvements adaptés au niveau

Référence : Tabata 1996, Gibala 2016, MyProtein HIIT Guide, NSCA HIIT for military deployments.

### `beginner` — bodyweight low-impact uniquement

| Catégorie | Mouvements OK |
|---|---|
| Cardio low-impact | Marche rapide, marche genoux haut, squat-air partial ROM, step-up bas (15-20 cm) |
| Core | Planche ventrale (genoux OK), bird-dog, dead bug |
| Activation | Squat-air, fente avant alternée (sans saut), pont fessier |
| **À BANNIR** | Box jumps, kettlebell swings (hinge non maîtrisé), burpees full, sauts plyo, mouvements olympiques |

### `recreational` — bodyweight + intro low-impact dynamique

| Catégorie | Mouvements OK |
|---|---|
| Cardio dynamique | Jumping jacks, mountain climbers, high knees, skater jumps low, butt kicks |
| Force | Squat-air, fente, push-up (genoux OK), pike push-up |
| Core | Planche, side plank, dead bug, Russian twist (sans charge) |
| Intro charge | Goblet squat DB léger, KB swing **uniquement après validation hip hinge en strength**, dumbbell thruster léger |
| **À BANNIR** | Box jumps haut, snatch, clean & jerk, burpees over bar, double-unders complexes |

### `regular` — full repertoire bodyweight + KB + DB + box low

| Catégorie | Mouvements OK |
|---|---|
| Cardio plyo | Jumping jacks, mountain climbers, burpees full, skater jumps, lateral hops, low box jumps (30-45 cm) |
| Force compound | Goblet squat, KB swing (hip hinge maîtrisé prérequis), thrusters DB, push-press DB, deadlift DB/KB |
| Core dynamique | Plank to push-up, V-ups, hollow rocks, ab roller |
| Conditioning | Wall balls medicine-ball, slam ball, jump rope simple, rowing machine, assault bike |
| **À BANNIR sans coach** | Snatch full barbell, clean barbell heavy, box jump > 60 cm répétés volumineux, muscle-up |

### `competitive` — full HIIT + mouvements olympiques basiques

| Catégorie | Mouvements OK |
|---|---|
| Cardio plyo intense | Burpees over bar, double-unders, broad jumps, depth jumps modérés, box jumps 60 cm |
| Force compound chargé | Thrusters barbell modéré, push-press barbell, KB swing 24-32 kg, deadlift modéré |
| Olympic lifts basiques | Power clean, hang power clean, hang power snatch (technique propre exigée), snatch grip push-press |
| Conditioning métabolique | Wall balls 9 kg, rowing erg fartlek, assault bike 1 min all-out, sled push, farmer carry |
| **À BANNIR sans coach humain** | Snatch full barbell heavy 1RM en circuit fatigué, box jump > 75 cm volumineux, ring muscle-up en AMRAP fatigué |

**Règle CoachingSage absolue** : pour TOUS niveaux, **prérequis technique obligatoires** documentés explicitement dans `notes` :
- KB swing → hip hinge maîtrisé (test : RDL barre/dowel propre 8 reps avant intégration KB).
- Box jump → squat profond contrôlé + atterrissage genoux fléchis (jamais jambes raides) + box low avant box mid.
- Burpee plyo → push-up technique + saut vertical contrôlé.
- Thrusters → front squat technique + push-press technique séparés avant combo.
- Wall ball → squat profond + lancer overhead contrôlé.

---

## Renforcement préventif (cheville, genou, hanche, core)

Hooks v2 : exercices marqués `volume_axis: reps` ou `sets`, `target_zone: technique` ou `RPE 5-6`, à inclure systématiquement en `warmup` ou en début de séance HIT.

### Warmup obligatoire (toutes séances HIT)

- **General warmup** 5-8 min : marche rapide, jumping jacks lents, rope skipping easy, vélo Z2 (élève T° corporelle, 65-75% FCmax).
- **Specific warmup** : mobilité cheville (calf stretch, ankle CARs), hanche (90/90, deep squat hold), épaule si push (band pull-apart, scapular CARs), poignet si appui sol (push-up grip warm).
- **Activation neuromusculaire** : 1-2 sets ramp-up sur le pattern dominant de la séance (squat-air × 10, push-up × 5, mountain climber slow × 10) avant le premier work interval.

Source : [ACSM HIIT Guidelines](https://blanchfield.tricare.mil/Portals/70/Session%202%20ACSM%20High%20Intensity%20Interval%20Training.pdf), [True Sports PT Plyometric Progression](https://www.truesportsphysicaltherapy.com/blogs/plyometric-training-that-builds-power-without-breaking-down-your-body).

### Renforcement préventif par niveau

- **`beginner`** : focus mobilité hanche/cheville (5-10 min en warmup), patterns bodyweight technique pure, pas de plyo, calf raises bipodal en début + fin de séance, planche 30 sec en fin.
- **`recreational`** : ajout calf raises excentriques (descente lente 3 sec, prévention tendinite achille avant intro plyo léger), single-leg balance, glute bridge unilatéral, dead bug.
- **`regular`** : ajout nordic curl (ischios prévention sur plyo + sprint), copenhagen plank (adducteurs), tibialis raise (cheville antérieure), scapular pull-up.
- **`competitive`** : ajout pliométrie progressive structurée hors-saison (low → mid box jumps en build), drills atterrissage (depth drop 30 cm puis amorti contrôlé), foam rolling 10 min entre séances HIT heavy.

**Règle CoachingSage** : **tibialis raises + calf raises excentriques systématiques en warmup dès `recreational`** (prévention shin splints + tendinite achille — risque n°1 sur HIIT plyo).

---

## Substitutions classiques (alternatives v2)

Documenté au niveau `exercise.alternatives[]` dans le template. **`alternatives: []` vide non-toléré.**

| Exercice planifié | Substitution low-impact / no-equipment | Trigger |
|---|---|---|
| Box jump | Step-up alterné rapide / saut vertical bas / squat-air explosif | `knee-injury`, `ankle-injury`, débutant, `apartment-noise` |
| Burpee full | Burpee sans saut (step-back) / squat thrust / mountain climber | `knee-injury`, `apartment-noise`, débutant |
| Kettlebell swing | Goblet squat dynamique / RDL élastique / hip thrust dynamique | `lower-back-pain`, hip hinge non maîtrisé, `no-kettlebell` |
| Jumping jacks | Step-jacks (un pied après l'autre) / heel taps | `knee-injury`, `apartment-noise`, surcharge cheville |
| Mountain climbers | Slow mountain climbers / dead bug | `wrist-pain`, `lower-back-pain` aigu |
| Double-unders | Single-unders / jumping rope simulé sans corde | Pas de jump rope, débutant skill |
| Wall balls | Goblet squat + thruster DB / squat-air + push-press DB | Pas de medicine-ball, plafond bas |
| Rowing erg | Mountain climbers + push-up combo / jumping jacks soutenus | Pas de rower, indoor only |
| Snatch barbell | DB snatch léger / KB swing high pull / power clean DB | Technique olympic non maîtrisée, no-barbell |
| Tabata 8 rounds full intensity | Tabata 4-6 rounds OU 30/30 même mouvement | Fatigue cumulée 2 sem, `recreational`, débutant |

---

## Drapeaux rouges (safety)

### Tous niveaux

- **Tendinite Achille** sur volume plyo / box jumps / double-unders répétés sans préparation : douleur localisée tendon achille pendant ou après séance, raideur matinale chronique. Action : stop plyo, calf raises excentriques + repos actif, avis kiné si > 5 jours.
- **Patellar tendonitis (jumper's knee)** sur box jumps + squats répétés : douleur sous rotule pendant jumps. Action : réduire foot contacts -50%, atterrissages genoux fléchis (jamais jambes raides), terminal knee extension renforcement.
- **Shin splints** sur jumping jacks + running sur place répétés sans tibialis raises préventifs : douleur tibia antérieur. Action : stop jumping jacks, tibialis raises excentriques, vérifier amortie chaussures.
- **Entorse cheville** sur mouvements changements direction (skater jumps, lateral hops) sur sol glissant ou chaussures inadaptées : douleur immédiate, gonflement. Action : RICE, avis médical si gonflement > 24 h.
- **Lombalgie aiguë** sur KB swing / deadlift dynamique avec hip hinge déficient : douleur lombaire pendant ou après set, > 2 jours post-séance. Action : stop hinge dynamique, swap goblet squat / hip thrust, avis kiné si > 5 jours.
- **Hyperextension cervicale** sur sit-ups intensifs en fatigue, ou OHP en finissant en hyperextension cervicale : signal posture à corriger immédiatement (menton rentré, yeux à l'horizon).

### Recreational et au-delà

- **Surcompensation cardiaque** sur HIIT excessif (> 30-40 min/sem au-dessus de 90% FCmax) : FC repos +10 bpm chronique, palpitations, sommeil dégradé. Action : deload immédiat (-50% durée HIT), 1 sem MICT only.
- **Hydratation extrême** sur séances longues chaleur > 25°C : crampes, vertiges, urines très foncées. Action : hydratation 500-750 ml/h tempéré, sodium 300-700 mg/L, jamais HIT chaleur > 30°C indoor sans clim.
- **Coup de chaleur** sur AMRAP long en environnement chaud : céphalée, frissons, désorientation = STOP IMMÉDIAT, reflux thermique (eau froide cou/aines), avis médical si symptômes > 30 min.

### Competitive

- **Surentraînement HIT** : baisse de force ≥ 5% sur compounds + baisse de résistance HIT sur Tabata test 2 sem consécutives, sommeil dégradé, motivation effondrée, FC repos +8-10 bpm. Action : deload immédiat (-50% HIT) + 1 sem récup active.
- **Rhabdomyolyse** sur HIT extrême non préparé (CrossFit kipping AMRAP en débutant, "FRAN" pre-acclimatation) : urines noires-cola, douleurs musculaires extrêmes 24-48 h post-séance. URGENCE MÉDICALE → consultation immédiate.
- **Hyperinflation cardiovasculaire / Valsalva** sur compounds heavy intégrés en circuit (thrusters lourds, deadlifts en AMRAP fatigué) : risque hypertension transitoire extrême. Profils hypertendus / antécédents cardiaques → avis médical obligatoire avant participation HIIT, préférer reps > 5 avec respiration libre.

Sources : [Kineon HIIT Common Injuries](https://kineon.io/blogs/news/common-hiit-injuries-and-how-to-prevent-them), [Dr. Shiple HIIT Injuries](https://drshiple.com/preventing-and-treating-hiit-injuries/), [NY Bone & Joint HIIT Injuries](https://nyboneandjoint.com/5-common-hiit-injuries-and-how-to-avoid-them/), [Range of Motion Box Jump Achilles](https://rangeofmotion.net.au/keeping-the-achilles-healthy-in-box-jumps/).

---

## EU MDR — Mots bannis et triggers medical clearance

### Mots bannis dans tout texte généré

- "soigner [pathologie]", "traitement [pathologie]", "guérir", "remède"
- "rééducation post-opératoire", "post-blessure", "post-chirurgie"
- "cure", "thérapie", "diagnostic", "prescription", "ordonnance"
- "soulager [douleur]" (préférer : "réduire l'inconfort", "favoriser le confort")
- "réparer le genou / le dos / la cheville" (préférer : "renforcer", "stabiliser", "protéger")

Med Device Regulation 2017/745. Vérifier zéro occurrence dans `summary`, `progression_logic`, `safety_notes`, `notes` exercices.

### Triggers medical clearance obligatoire

Inclure mention "Consulte un médecin avant de commencer ce programme" dans `safety_notes` si :

- **Antécédents cardiaques connus** (`cardiac-clearance-required`) : IDM, arythmie, valvulopathie, hypertension non contrôlée. HIIT contre-indiqué sans avis cardiologue + test effort récent. Référence ACSM 2014 : screening obligatoire pour > 35 ans avec facteurs de risque.
- **Hypertension** non équilibrée → mention Valsalva, formats AMRAP en fatigue à éviter, RPE plafonné 8.
- **Asthme d'effort** : warmup étendu à 10-15 min, bronchodilatateur disponible, environnement non poussiéreux, pas d'AMRAP > 15 min.
- **Grossesse** (`pregnancy`) → HIIT classique contre-indiqué T2-T3 (Valsalva, plyo, déséquilibre), programmes adaptés (marche dynamique, squat-air, gainage modéré) seulement avec avis sage-femme / médecin.
- **Reprise post-opératoire / post-blessure** (< 6 mois sur cheville, genou, lombaire, épaule) : avis kiné obligatoire avant intégration plyo / KB swings.
- **Profil > 50 ans débutant complet** sans test effort récent.
- **Profil sédentaire > 6 mois** : recommandation ACSM / NCSF de 6 mois MICT régulier avant introduction HIIT structuré (pour `beginner` strict, démarrage progressif intégré au plan).

---

## Hooks metadata standards (HIIT)

### `target_zone` — valeurs autorisées

- `Tabata 20/10` (format first-class, 20 sec work / 10 sec rest × 8 rounds = 4 min)
- `30/30` (format first-class, 30 sec work / 30 sec rest, ratio 1:1)
- `40/20` (format first-class, 40 sec work / 20 sec rest, ratio 2:1)
- `EMOM` (format first-class, Every Minute On the Minute)
- `AMRAP` (format first-class, As Many Rounds As Possible sur durée fixée)
- `RPE 6-7` (warmup, conversational, low-impact)
- `RPE 8-9` (work interval standard)
- `RPE 9-10` (work interval all-out Tabata strict)
- `RPE 2-3` (rest interval actif, walking-recovery)
- `walking-recovery` (cooldown ou récup totale)
- `technique` (drills, mobilité spécifique, ramp-up bas)

**Convention CoachingSage** : pour les blocs structurés (Tabata / EMOM / AMRAP), utiliser le format first-class comme `target_zone` du bloc (ex `target_zone: "Tabata 20/10"`) et préciser RPE work / rest dans `notes`. Pour exercices isolés non structurés (warmup, cooldown, renforcement), utiliser `RPE *` direct.

### `required_equipment` — vocabulaire kebab-case

- `bodyweight` (assumé `[]` si vide, ou `["bodyweight"]` explicite)
- `mat` (sol, gainage, mobilité)
- `jump-rope` (rope skipping, double-unders)
- `kettlebell` (swings, goblet squats, halos) — préciser charge dans `notes`
- `dumbbells` (paire, thrusters, snatches DB)
- `medicine-ball` (wall balls, slams)
- `box` (box jumps low/mid/high, step-ups dynamiques)
- `pullup-bar` (pull-ups dynamiques en circuit, toes-to-bar)
- `barbell` (thrusters, deadlifts, cleans — `regular`+ uniquement)
- `rower` ou `assault-bike` (cardio machine alternative)
- `resistance-band` (warmup activation, alternatives plyo low-impact)
- `timer` (`interval-timer` ou app dédiée — toujours mentionné dans `notes` Tabata)

**Convention** : pour `beginner` home, équipement minimal `["mat"]` ou `[]`. Toujours documenter alternative bodyweight si possible.

### `incompatible_constraints` — vocabulaire kebab-case

- `knee-injury`, `ankle-injury`, `lower-back-pain`, `wrist-pain`, `shoulder-injury`, `hip-injury`, `cervical-pain`
- `cardiac-clearance-required` (HIIT contre-indiqué sans avis cardiologue)
- `hypertension` (Valsalva contre-indiqué, AMRAP en fatigue à éviter, RPE plafonné 8)
- `asthma-exercise-induced` (warmup étendu, bronchodilatateur, AMRAP < 15 min)
- `pregnancy`, `postpartum-early`
- `osteoarthritis-knee`, `osteoarthritis-hip` (plyo contre-indiqué)
- `apartment-noise` (jumps / drops barbell impossible — proposer alternatives low-impact)
- `home-only` (impacte choix équipement, prioriser bodyweight + DB léger + KB léger)
- `no-jump-rope`, `no-kettlebell`, `no-box`, `no-barbell` (impacte alternatives par exercice)
- `outdoor-only`, `indoor-only`

### `alternatives` — règle minimale

**Au minimum 1-2 alternatives réalistes par exercice.** `alternatives: []` vide non-toléré. Documenter :
- **Substitut low-impact** : pas de saut (knee/ankle/apartment-noise) — ex burpee → squat thrust sans saut.
- **Substitut équipement** : no-kettlebell → DB ou élastique ; no-box → step-up ; no-barbell → DB.
- **Substitut format** : Tabata 8 rounds → Tabata 4-6 rounds OU 30/30 sur même mouvement (fatigue cumulée).

### `volume_axis`

- `sets` (**principal pour HIIT structuré** : `sets: 8` × `duration: "20 sec work + 10 sec rest"` pour Tabata) — utilisé pour la majorité des blocs work/rest
- `duration` (bloc continu : EMOM 15 min, AMRAP 12 min, warmup 5 min) — pivot quand le set count est implicite (1 bloc unique)
- `reps` (renforcement isolé sans set fixe : "AMRAP push-ups en 60 sec")
- `rounds` (alternative à `sets` pour AMRAP : "10 rounds : 5 burpees + 10 squat-air + 15 sit-ups")

**Convention CoachingSage** : `volume_axis: sets` est la valeur par défaut pour blocs Tabata / 30/30 / 40/20 (le set count est le pivot scalable). `duration` pour EMOM / AMRAP / warmup / cooldown (la durée totale est le pivot). `reps` rare, pour renforcement isolé.

---

## `week_structure` typique par niveau

| Niveau | type | micro_pattern | recovery_cadence |
|---|---|---|---|
| **beginner** | `linear` | `HIT court 4 min + rest + mobilité + rest + HIT court 4 min + rest + rest` (2 sessions HIT/sem 30/60 ratios doux + 1 mobilité) | `1 cutback W4-W5 sur plan 8 sem (-25 à -30% durée HIT)` |
| **recreational** | `linear` | `HIT Tabata 4-6 rounds + rest + EMOM 12 min + rest + mobilité + rest + rest` (2 HIT/sem + mobilité) | `1 deload toutes les 4 sem (-15 à -20% HIT)` |
| **regular** | `block` | `HIT Tabata 8 rounds + rest + EMOM 15 min + rest + AMRAP 12 min + mobilité + rest` (2-3 HIT/sem + 1 mobilité) | `1 deload toutes les 3-4 sem (-15 à -25% HIT)` |
| **competitive** | `polarized` | `HIT Tabata 8 + rest + EMOM 18 + rest + AMRAP 20 + mobilité + rest active` (3 HIT/sem max, peak weeks 16-20 min HIT cumulé) | `1 deload toutes les 3 sem (-15 à -25% HIT)` |

`deload_weeks` exemples :
- Plan 8 sem `beginner` : `[5]`
- Plan 8 sem `recreational` : `[4, 8]` (W8 = test/checklist semaine + cutback léger)
- Plan 12 sem `regular` : `[4, 8]` ou `[4, 8, 12]` selon volume pic
- Plan 12 sem `competitive` : `[4, 8, 12]` + taper W12 explicite si test fitness chiffré

---

## Sources

### Doctrine ACSM / définition formelle HIIT
- [ACSM Position Stand HIIT 2014 — Health & Fitness Journal](https://journals.lww.com/acsm-healthfitness/fulltext/2013/05000/high_intensity_interval_training__efficient,.3.aspx)
- [ACSM HIIT Information PDF — Tricare Blanchfield](https://blanchfield.tricare.mil/Portals/70/Session%202%20ACSM%20High%20Intensity%20Interval%20Training.pdf)
- [ACSM HIIT For Fitness, For Health or Both](https://acsm.org/high-intensity-interval-training-fitness/)
- [ACSM Physical Activity Guidelines](https://acsm.org/education-resources/trending-topics-resources/physical-activity-guidelines/)
- [ACSM/ESSA Joint Consensus Exercise Intensity Terminology 2024 — JSAMS](https://www.jsams.org/article/S1440-2440(24)00559-0/fulltext)
- [Evidence-Based Effects HIIT Review — PMC](https://pmc.ncbi.nlm.nih.gov/articles/PMC8294064/)
- [HIT Program for Clinical Populations — ACE Fitness](https://www.acefitness.org/certifiednewsarticle/2589/high-intensity-interval-training-for-clinical-populations/)

### Tabata 1996 — original protocol
- [Tabata Wikipedia HIIT](https://en.wikipedia.org/wiki/High-intensity_interval_training)
- [Original Tabata Protocol PDF — Scribd](https://www.scribd.com/document/299162685/The-Original-Tabata-Protocol-OBAVEZNO-PRO%C4%8CITATI)
- [Exercise Intensity and Energy Expenditure Tabata — PMC](https://pmc.ncbi.nlm.nih.gov/articles/PMC3772611/)
- [Concept2 Revisiting Tabata](https://www.concept2.com/blog/short-workouts-revisiting-the-tabata)
- [Tabata Protocol Drummond Education](https://drummondeducation.com/tabata-protocol/)
- [TRAINFITNESS Tabata HIIT Protocol](https://train.fitness/personal-trainer-blogs/tabata-hiits-most-well-known-training-protocol)
- [BodySpec Tabata 4-Minute Protocol](https://www.bodyspec.com/blog/post/tabata_training_the_4minute_workout_protocol)
- [SET FOR SET Tabata Workouts Science](https://www.setforset.com/blogs/news/tabata-workouts)

### Gibala Lab — McMaster University SIT
- [Gibala 12 Weeks SIT Cardiometabolic — PLOS One](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0154075)
- [Gibala 12 Weeks SIT — PMC](https://pmc.ncbi.nlm.nih.gov/articles/PMC4846072/)
- [No Time to Get Fit ScienceDaily 2016](https://www.sciencedaily.com/releases/2016/04/160427095204.htm)
- [Dr. Martin Gibala FoundMyFitness Episode](https://www.foundmyfitness.com/episodes/martin-gibala)
- [Short-term SIT vs Endurance Adaptations — PMC](https://pmc.ncbi.nlm.nih.gov/articles/PMC1995688/)
- [Gibala Exercise Intensity Slides 2023 — UWO PDF](https://www.uwo.ca/ccaa/conferences_events/conferences/pdf/2023_r2a_gibalam_sat.pdf)
- [BioSpace 1-Minute Workout McMaster Study](https://www.biospace.com/get-fit-in-60-seconds-1-minute-workout-may-be-good-enough-mcmaster-university-study)

### Ratios work/rest (30/30, 40/20, EMOM, AMRAP)
- [INSCYD 40-20 Interval Workout Work Rest Ratios](https://inscyd.com/article/40-20-interval-workout/)
- [SET FOR SET EMOM Workouts Beginner Guide](https://www.setforset.com/blogs/news/emom-workouts)
- [Healing Motion PT — EMOMs AMRAP Tabata Time-Based](https://healingmotionpt.com/2021/05/08/emoms-amrap-aqaps-and-tabatas-oh-my-time-based-workouts-overview/)
- [Medichecks — AMRAP EMOM WOD Tabata](https://www.medichecks.com/blogs/sports-performance/amrap-emom-wod-tabata-what-does-it-all-mean)
- [FightCamp — HIIT Tabata AMRAP EMOM Boxing](https://blog.joinfightcamp.com/training/how-to-use-hiit-tabata-amrap-emom-for-boxing-training/)
- [Wellfit Insider — 15 Best HIIT Workouts](https://wellfitinsider.com/workout-tips/best-hiit-exercises-workout/)
- [Mens Fit Club — 20 Min EMOM Full Body](https://www.mensfitclub.com/mens-fitness/20-minute-emom-workout-a-guide-to-full-body-strength/)

### Volume hebdo / fréquence / récupération
- [HIIT Science How Much HIIT Per Week 2025 Guide](https://hiitscience.com/how-much-hiit-training-per-week-guide/)
- [Les Mills How Much HIIT Per Week](https://www.lesmills.com/fit-planet/fitness/how-much-hiit/)
- [NSCA Time-Efficient Training PTQ](https://www.nsca.com/education/articles/ptq/time-efficient-training/)
- [NSCA Implementation HIIT Military Deployments](https://www.nsca.com/education/articles/nsca-coach/implementation-of-hiit-sessions-to-maintain-physical-preparedness-during-military-deployments/)
- [NSCA Determination Training Frequency](https://www.nsca.com/education/articles/kinetic-select/determination-of-resistance-training-frequency/)
- [NSCA Basics Strength Conditioning PDF](https://www.nsca.com/contentassets/de9aebfe7a7340b69217b99bb13862a7/basics_of_strength_and_conditioning_manual.pdf)

### Prévention blessures / red flags
- [Kineon — 14 HIIT Injuries Prevention](https://kineon.io/blogs/news/common-hiit-injuries-and-how-to-prevent-them)
- [Dr. Shiple — HIIT Injuries Prevention Treatment](https://drshiple.com/preventing-and-treating-hiit-injuries/)
- [NY Bone Joint — 5 HIIT Injuries Avoid](https://nyboneandjoint.com/5-common-hiit-injuries-and-how-to-avoid-them/)
- [True Sports PT — Plyometric Training Build Power](https://www.truesportsphysicaltherapy.com/blogs/plyometric-training-that-builds-power-without-breaking-down-your-body)
- [Range Of Motion — Achilles Healthy Box Jumps](https://rangeofmotion.net.au/keeping-the-achilles-healthy-in-box-jumps/)
- [Wheeler Sports — Plyometric Achilles Tendon Prevention](https://www.wheelersportstech.com/2025/11/21/how-plyometric-training-helps-prevent-achilles-tendon-injuries/)
- [TrainingPeaks — Plyometric Leg Injury Reduction](https://www.trainingpeaks.com/blog/plyometric-leg-exercises-injury-reduction/)
- [Treat My Achilles — Plyometric Tendon Rehab](https://www.treatmyachilles.com/post/plyometric-exercises-for-achilles-tendon-rehab)
- [ScienceDirect — Plyometric ACL Injury Prevention](https://www.sciencedirect.com/science/article/pii/S1836955322000807)

### Kettlebell swing / hip hinge prerequisite
- [Kettlebell Kings — Master Hip Hinge KB Swing](https://www.kettlebellkings.com/blogs/default-blog/master-the-hip-hinge-to-optimize-your-kettlebell-swing)
- [Guilford Athletic — Mastering KB Swing Timing Hinge](https://guilfordathleticcenter.com/mastering-the-kettlebell-swing/)
- [StrongFirst — Athletic Hip Hinge Explanation](https://www.strongfirst.com/explanation-athletic-hip-hinge/)
- [Caveman Training — Beginners NOT KB Swing First](https://www.cavemantraining.com/kettlebells/beginners-its-not-the-kettlebell-swing-or-hip-hinge-you-should-learn-first/)
- [Kettlebells Workouts — Hip Hinge KB Strong Hips](https://kettlebellsworkouts.com/hip-hinge-exercises/)
- [Fitness Kettlebells — Mastering Hip Hinge Form Tips](https://fitnesskettlebells.com/form-tips/mastering-the-hip-hinge-technique)

### Référence grand public (style guide HIIT)
- [MyProtein HIIT Guide ratios formats](https://www.myprotein.com/) (référence éditoriale générique HIIT, ratios 1:2 / 1:1 / 2:1, formats Tabata / EMOM / AMRAP cf. articles HIIT du blog)
- [NCSF HIIT Guidelines](https://www.ncsf.org/) (référence certifications, screening PAR-Q, populations à risque)
