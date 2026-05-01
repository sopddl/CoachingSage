# Doctrine — Strength Training

Référentiel public sourcé pour la regen des templates strengthTraining (Story 0.5.10) et l'algo deterministic local Story 3.3a.

**Last revised** : 2026-04-30.

**Vocabulaire de niveau** (aligné enums Sport + Level Story 0.5.8) :
- `beginner` : aucune ou très peu d'expérience (< 6 mois) en musculation, équipement minimal (home), maîtrise des patterns fondamentaux à acquérir, vise tonification générale + apprentissage technique.
- `recreational` : pratique 2-3×/sem depuis 6-12 mois, équipement minimal à modéré (dumbbells + bench), capable d'exécuter squat/RDL/push-up technique propre, vise hypertrophie générale + force fonctionnelle.
- `regular` : pratique 4-5×/sem depuis ≥ 1 an, accès salle complète (barbell + rack + bench + cables), maîtrise des 5-6 patterns fondamentaux, vise hypertrophie ciblée + intermédiaire en force (1RM squat/bench/dead connus ou estimés).
- `competitive` : pratique 5-6×/sem depuis ≥ 2 ans, athlète force pure ou powerbuilder, accès salle complète, vise PR force (1RM cycliques), périodisation block / Texas Method / 5-3-1 / linéaire pré-meet.

---

## Doctrine référente

| Référence | Auteur(s) | Application |
|---|---|---|
| **Scientific Principles of Hypertrophy / Strength Training** (RP Strength) | Mike Israetel, James Hoffmann, Chad Wesley Smith | Volume landmarks MV / MEV / MAV / MRV par muscle group, périodisation hypertrophie, RIR-based loading. |
| **The Muscle and Strength Pyramid v2.0** | Eric Helms, Andy Morgan, Andrea Valdez | Hiérarchie : Adherence > Volume > Intensity > Frequency > Periodization > Exercise selection > Tempo > Rest periods. RIR 2-4 pour hypertrophie. |
| **Essentials of Strength Training and Conditioning** (5e éd.) | NSCA / Haff & Triplett | Standards rest intervals, prescription beginner (1-3 sets initial, 2-3×/sem), ratios sets/reps/charge par objectif. |
| **Hypertrophy Meta-analysis Schoenfeld 2017** | Brad Schoenfeld, Grgic, Krieger | Dose-response volume hypertrophie : 10+ sets/muscle/sem > 5-9 > <5. Sets effectifs = proches échec (RIR 1-3). |
| **StrongLifts 5x5** | Mehdi Hadim | Linéaire débutant 3×/sem, 5 compounds (squat / bench / row / OHP / deadlift), progression +2.5 kg/séance. |
| **5/3/1** | Jim Wendler | Cycle 4 sem, % du Training Max (90% 1RM), AMRAP last set, deload W4 (40/50/60% TM). |
| **Texas Method** | Mark Rippetoe, Glenn Pendlay | Intermédiaire, 3×/sem (Volume Day 5x5 / Recovery Day 80% / Intensity Day 1x5 PR), progression hebdo. |
| **6-Day PPL Hypertrophy** | Borge Fagerli / Jeff Nippard | Push/Pull/Legs ×2/sem, 12-18 sets/muscle/sem, RPE 6-9 selon compound vs isolation. |

---

## Zones d'effort (target_zone)

Convention v2 : préfixe `RPE` (Rate of Perceived Exertion 1-10), `RIR` (Reps In Reserve, 0-5), `%1RM`, ou `technique` (warmup, drills, mobilité).

| Zone | RIR équivalent | %1RM approx (sets de 5) | Description | Application typique |
|---|---|---|---|---|
| `technique` | n/a | < 50% | Warmup, drills, ramp-up bas | Échauffement, mobilité spécifique, pattern grooving |
| `RPE 5-6` | 4-5 | 65-70% | Submaximal, technique focus | Warmup ramping bas, tempo training, recovery day |
| `RPE 6-7` | 3-4 | 70-75% | Volume hypertrophie léger | Sets accessoires light, deload primaire |
| `RPE 7-8` | 2-3 | 75-85% | Hypertrophie / strength général | **Working sets standard** (compound + isolation) |
| `RPE 8-9` | 1-2 | 85-92% | Strength / heavy hypertrophie | Top sets compounds, AMRAP intermédiaire |
| `RPE 9-10` | 0-1 | 92-100% | Max effort | PR attempts, AMRAP last set 5/3/1 |
| `%1RM 65-75%` | 3-4 | n/a | Volume day Texas / 5x5 StrongLifts | Linéaire débutant compound, volume programs |
| `%1RM 75-85%` | 2-3 | n/a | Working strength | Top sets 5x3, 4x4, intensity day |
| `%1RM 85-95%` | 0-2 | n/a | Heavy strength | PR sets 5/3/1 W2-W3, peak cycle |

Sources : [BarBend RPE Scale](https://barbend.com/how-to-use-rpe-scale-strength-training/), [Ripped Body RPE/RIR Guide](https://rippedbody.com/rpe/), [Reshape — Warmup vs Working Sets](https://www.reshapeapp.ai/blog/warm-up-sets-vs-working-sets-structure-strength-sessions), [Israetel MV/MEV/MAV/MRV](https://drmikeisraetel.com/dr-mike-israetel-wikipedia/dr-mike-israetel-mv-mev-mav-mrv-explained/).

**Choix de doctrine** : on pace en **RPE/RIR par défaut** (universel, ne nécessite pas un 1RM testé), %1RM en complément pour `competitive` qui a un Training Max calibré. Le warmup ramping est documenté en zone `technique` ou `RPE 5-6`. Les working sets compounds vivent à `RPE 7-8` (`RIR 2-3`) pour hypertrophie / strength général ; `RPE 8-9` pour top sets force.

**RPE/RIR défini en W1 J1 obligatoire** : la première séance explique la grille (RPE 7 = 3 reps en réserve, RPE 8 = 2 reps en réserve, etc.) dans `notes` du premier exercice ou dans le `warmup` block. Cible par séance ensuite.

---

## Volume hebdo cible (sets par muscle group)

**Convention** : 1 set effectif = série de 6-15 reps proche échec (RIR 0-3). Warmup ramping ne compte PAS dans le total. Compound exercises comptent **partiellement** : un squat back compte 1 set "quads" + ~0.5 set "glutes" + ~0.3 set "lower back" (méthodologie RP Strength).

Sources : [Schoenfeld Meta-analysis dose-response — PMC](https://pmc.ncbi.nlm.nih.gov/articles/PMC6303131/), [RP Volume Landmarks — RP Strength](https://rpstrength.com/blogs/articles/training-volume-landmarks-muscle-growth), [Israetel MV/MEV/MAV/MRV explained](https://drmikeisraetel.com/dr-mike-israetel-wikipedia/dr-mike-israetel-mv-mev-mav-mrv-explained/), [Helms Pyramid Vol/Int — studylib](https://studylib.net/doc/25756029/the-muscle-and-strength-pyramid-training-v2.0).

| Niveau | Volume hebdo cible (sets/muscle/sem) | Fréquence/muscle | Doctrine source |
|---|---|---|---|
| **beginner** | **MEV ~6-10 sets/muscle/sem** (full-body 3×/sem, 1-3 working sets/exercice) | 2-3× / sem | NSCA beginner 1-3 sets, StrongLifts 5x5 (5 sets compound 3×/sem), Helms Pyramid (volume bas suffit pour novice) |
| **recreational** | **MEV-MAV ~10-14 sets/muscle/sem** (upper/lower 4×/sem, 2-4 working sets/exercice) | 2× / sem | Schoenfeld dose-response (10+ sets > 5-9), Helms Intermediate, RP MEV upper bound |
| **regular** | **MAV ~14-20 sets/muscle/sem** (PPL 6×/sem ou upper/lower 4×/sem, 3-4 working sets) | 2× / sem | RP MAV range, 6-Day PPL Weightology 12-18 sets/muscle/sem, Schoenfeld 10+ optimum |
| **competitive** | **MAV-MRV ~16-22 sets/muscle/sem** principaux + accessoires sub-MEV maintenu | 2-3× / sem | RP MAV-MRV range pour intermédiaire-avancé, 5/3/1 BBB, Texas Method volume day 5x5 |

**Convention CoachingSage** : on annonce dans `summary` le **volume hebdo cible par muscle group principal** (quads, posterior chain, chest/push, back/pull). Exemple `regular` PPL 12 sem : "Vol pic ~16-18 sets/muscle/sem (chest, back, quads, posterior chain)". `progression_logic` détaille la dose-response Schoenfeld + landmarks Israetel.

**Pas de calculs % faux** : si tu écris "70% × 5", ça doit être effectivement 70% du Training Max (90% 1RM), pas un pseudo-RPE déguisé. Vérifie l'arithmétique avant rendu.

---

## Périodisation

### Cycle de base (build / deload)

- **`beginner`** : 5-6 build + 1 cutback (-30 à -40% volume sur 1 sem). Plan 8 sem → cutback W5. Charge faible, adaptation lente, pas besoin de deload fréquent.
- **`recreational`** : 3 build + 1 deload (-40% volume). Plan 12 sem → deload W4, W8. Standard upper/lower hypertrophie.
- **`regular`** : 3 build + 1 deload (-40 à -50% volume). Plan 12 sem → deload W4, W8. Si PPL 6× / sem, deload toutes les 4 semaines obligatoire.
- **`competitive`** : 3 build + 1 deload OU 4 build + 1 deload selon programme (5/3/1 = 3+1 strict). Plan 12 sem cycle 5x5 → deload W4, W8 ; plan 5/3/1 = chaque cycle de 4 sem inclut son deload W4 (40/50/60% TM).

**Cutback / deload doctrine -40 à -50% sets** : c'est la convention strength validée. À ne pas confondre avec running (-15 à -20%). Justification : la charge nerveuse + articulaire des compounds heavy nécessite un déload marqué pour permettre la supercompensation.

Sources : [Wendler 5/3/1 Deload — Arvo](https://arvo.guru/resources/methods/wendler-531), [BiteKit 5/3/1 Calculator](https://bitekit.app/tools/531-program-calculator/), [Texas Method recovery — PowerliftingToWin](https://www.powerliftingtowin.com/texas-method/).

### Modèles de périodisation

#### Linéaire (`beginner`, certaines phases `recreational`)
Charge augmente linéairement séance après séance ou semaine après semaine, reps stables.
- StrongLifts 5x5 : +2.5 kg compound /séance jusqu'à plateau.
- Linéaire 8-12 sem : 70% × 5 → 72.5% × 5 → 75% × 5 → ... → 85% × 5.

#### DUP — Daily Undulating Periodization (`recreational`, `regular`)
Reps/intensité varient au sein de la semaine.
- Exemple PPL : Push A heavy (4×4 RPE 8), Push B hypertrophie (4×8-10 RPE 7-8).
- Validé par méta-analyse pour intermédiaires (Helms / Schoenfeld).

#### Block periodization (`regular`, `competitive`)
Phases séquentielles : Accumulation (volume haut, intensité modérée) → Transmutation (volume modéré, intensité haute) → Realization (volume bas, intensité max, peak).
- Texas Method = block ondulé hebdo (Volume / Recovery / Intensity).
- Préparation meet powerlifting : 8 sem accumulation → 4 sem intensification → 2 sem peak.

#### 5/3/1 (`competitive` exclusivement, optionnel)
Cycle 4 sem :
- W1 (5s) : 65% × 5, 75% × 5, 85% × 5+ (AMRAP)
- W2 (3s) : 70% × 3, 80% × 3, 90% × 3+ (AMRAP)
- W3 (5/3/1) : 75% × 5, 85% × 3, 95% × 1+ (AMRAP)
- W4 (deload) : 40% × 5, 50% × 5, 60% × 5

Progression entre cycles : +2.5 kg upper / +5 kg lower au TM.

Sources : [StrongLifts 5x5 Progression](https://stronglifts.com/stronglifts-5x5/progress/), [Wendler 5/3/1 Calculator](https://strengthtrainingtools.com/wendler-531-calculator), [Texas Method Volume Day — SetForSet](https://www.setforset.com/blogs/news/the-texas-method-strength-program), [PPL Hypertrophy Weightology](https://weightology.net/muscle-gain/6-day-per-week-push-pull-legs-hypertrophy-split/).

---

## 5 (+1) patterns fondamentaux à couvrir CHAQUE semaine

Doctrine : les 6 patterns fonctionnels structurent toute prog strength. **Chaque semaine** doit toucher chaque pattern au moins 1× (sauf split très spécifique justifié). Référence Dan John / Gray Cook / Mike Boyle.

| Pattern | Plan principal | Variantes | Substitut sans équipement / home |
|---|---|---|---|
| **Squat** (quad dominant) | Back squat barbell | Front squat, Bulgarian split squat, Goblet squat, Leg press | Goblet squat dumbbell / KB, split squat, sissy squat, wall sit |
| **Hinge** (hip dominant) | Deadlift conventional | RDL, Trap bar deadlift, Hip thrust, Kettlebell swing, Good morning | Single-leg RDL DB, hip thrust bodyweight + KB, glute bridge, kettlebell swing |
| **Push horizontal** | Bench press barbell | DB bench, Dumbbell incline, Push-up lesté | Push-up classique + variations (decline, archer, deficit), DB floor press |
| **Push vertical** | Overhead press (OHP) barbell | DB shoulder press, Landmine press, Z-press | Pike push-up, handstand push-up wall, DB shoulder press, band OHP |
| **Pull horizontal** | Barbell row Pendlay/yates | DB row, Cable row, Inverted row TRX/anneaux, Chest-supported row | Inverted row sous table, DB row, band row, suspension row |
| **Pull vertical** | Pull-up / Chin-up | Lat pulldown, Assisted pull-up | **Substituts si pas d'équipement** : Y-raise + DB pullover combo, band pull-down, doorframe row, lat pulldown élastique |

**Règle CoachingSage** : pour les templates `beginner` home / no-equipment, **toujours** prévoir une alternative pull vertical (Y-raise + dumbbell pullover OU band pull-down OU doorframe pull-up si disponible). Ne jamais omettre le pattern parce que "pas de barre".

**Core en fin de séance, jamais en début** : le core fatigué en début compromet le bracing sur compounds heavy. Convention CoachingSage : core (planche, dead bug, anti-rotation) en fin, jamais avant squat / deadlift / OHP.

Sources : [Muscle & Strength Beginner Fundamentals](https://www.muscleandstrength.com/articles/beginner-strength-training-program-fundamentals), [NSCA Foundations of Fitness Programming](https://www.nsca.com/contentassets/8323553f698a466a98220b21d9eb9a65/foundationsoffitnessprogramming_201508.pdf).

---

## Repos inter-séries

Standards NSCA / Schoenfeld appliqués CoachingSage :

| Type d'exercice | Repos cible | Contexte |
|---|---|---|
| **Compounds heavy** (squat, deadlift, bench top sets) | **2-3 min minimum, jusqu'à 5 min** | RPE 8-9, %1RM 80%+, sets de 1-5 reps |
| **Compounds modérés** (squat 5x5 RPE 7, bench RPE 7) | 90 sec à 2 min | Volume day, programmes 5x5 |
| **Compounds isolation moyen-volume** (DB press, row) | 60-90 sec | Hypertrophie, sets 8-12 reps RPE 7-8 |
| **Isolation léger / accessoire** (curls, lat raises, calf raises) | 45-75 sec | Sets 10-15 reps RPE 7-9 |
| **Core / mobilité fin de séance** | 30-60 sec | Planche, dead bug, hanche mobility |

**Règle CoachingSage** : pas de repos < 60 sec sur compound. La récupération neuromusculaire incomplète compromet la qualité technique → risque de blessure et perte de stimulus de force. Si l'utilisateur est pressé, raccourcir le nombre de sets, pas le repos compounds.

Source : [NSCA Rest Intervals — PTPioneer Chapter 15](https://www.ptpioneer.com/personal-training/certifications/nsca-cpt/nsca-cpt-chapter-15/), [NSCA Manipulating Rest Intervals PDF](https://www.nsca.com/contentassets/fb8a7be6eb174934bb8844703c4de4cc/ptq-10.1.3-how-to-manipulate-rest-intervals-to-maixmize-strength-training-effectiveness.pdf).

---

## Renforcement préventif (warmups, mobilité, accessoires)

Hooks v2 : exercices marqués `volume_axis: reps` ou `sets`, `target_zone: technique` ou `RPE 5-6`, à inclure systématiquement en `warmup` ou en début/fin de séance compound.

### Warmup obligatoire (toutes séances compound)

- **General warmup** 5-8 min : rower / vélo Z2 ou jumping jacks + skip rope (élève la T° corporelle).
- **Specific warmup** : mobilité hanche (90/90, deep squat hold, hip CARs), épaule (band pull-apart, scapular CARs, dead-bug), thoracique (T-spine rotation, cat-cow).
- **Ramp-up sets** : 3-5 sets sur le compound principal, charge croissante, reps décroissants. Ex squat 100 kg working : 20 kg × 8, 40 kg × 5, 60 kg × 3, 80 kg × 1, puis working 100 kg × 5. Total warmup ramping 10-25 reps (pas plus).

Source : [BarBend Ramp-Up Sets](https://barbend.com/ramp-up-sets/), [Rehab2Perform Ramp-up](https://rehab2perform.com/news/ramp-it-right-way/), [Reshape Warmup Strategy](https://www.reshapeapp.ai/blog/warm-up-sets-vs-working-sets-structure-strength-sessions).

### Renforcement préventif par niveau

- **`beginner`** : focus technique pure, mobilité hanche/épaule (5-10 min en warmup), patterns bodyweight avant ajout charge. Core en fin de séance (planche 30 sec, dead bug 8/côté, bird-dog 8/côté).
- **`recreational`** : ajout face pulls (épaule postérieure, prévention impingement), Pallof press (anti-rotation core), single-leg work (bulgarian split squat = prévention asymétries).
- **`regular`** : ajout copenhagen plank (adducteurs / hernies inguinales), nordic curl (ischios prévention), reverse hyperextension léger (lower back). Mobilité thoracique 5 min entre warmup et working sets.
- **`competitive`** : ajout pliométrie modérée hors-saison (box jumps low, broad jumps), maintien intra-saison drills techniques (paused squat, deadlift à pause au genou). Soft tissue work (foam rolling 10 min) recommandé entre séances heavy.

---

## Drapeaux rouges (safety)

### Tous niveaux

- **Lombalgie aiguë (lumbar flare)** sur deadlift / squat : douleur localisée lombaire pendant ou après set, douleur > 2 jours post-séance. Cause n°1 : flexion lombaire sous charge (rounding), bracing déficient, fatigue, charge trop élevée. Action : stop deadlift / squat heavy, swap variante moins exigeante (goblet squat, trap bar deadlift, hip thrust), avis kiné si symptômes > 5 jours.
- **Sciatique / sciatalgie** (douleur irradiante jambe, fourmillements, faiblesse) : DRAPEAU ROUGE → stop tout compound lombaire-loaded, avis médical immédiat. Ne pas pousser à travers.
- **Knee pain antérieur** (PFPS, tendinite rotulienne) : sur squat profond ou step-up. Réduire amplitude (box squat hauteur supérieure), renforcer VMO (terminal knee extension), single-leg work modéré.
- **Shoulder impingement** (douleur épaule en élévation OHP / bench) : limiter ROM, swap landmine press, neutre grip DB press, face pulls + scapular work. Si douleur > 5 jours : arrêt pressing vertical.
- **Wrist pain** (front squat, OHP, push-up) : straps poignets, wrap, neutre grip DB substitute.
- **Hyperextension cervicale** (front squat rack position, OHP en finissant en hyperextension) : signal posture à corriger immédiatement.

Sources : [HSS Lower Back Pain Deadlifts](https://www.hss.edu/article_lower-back-pain-after-deadlift.asp), [Korba Spine Clinic Deadlift Form](https://korbaspineclinic.com/deadlift-and-lower-back-pain-form-fixes/), [BenchMark PT Deadlifting and Back Pain](https://www.benchmarkpt.com/blog/deadlifting-and-back-pain-can-it-help-or-make-pain-worse/).

### Recreational et au-delà

- **Tendinopathie rotulienne** (jumper's knee) sur volume jambes haut + pliométrie : calf raises excentriques + decline squats préventifs.
- **Tendinopathie épicondylienne** (golfer's elbow / tennis elbow) sur volume tirage haut : grip work, neutre grip pulls, reverse curls.

### Competitive

- **Surentraînement strength** : baisse de force ≥ 5% sur compounds principaux 2 sem consécutives, sommeil dégradé, motivation effondrée, FC repos +8-10 bpm. Action : deload immédiat (-50% volume) + 1 sem de récup active.
- **Hyperinflation cardiovasculaire / Valsalva** sur compounds heavy : la manœuvre de Valsalva (apnée bracing) augmente TA jusqu'à 350/250 mmHg sur PR squat/dead. Pour profils hypertendus / antécédents cardiaques → avis médical obligatoire avant 1RM, préférer reps > 3 avec respiration libre, ceinture lifting recommandée à partir de 80% 1RM.

---

## EU MDR — Mots bannis et triggers medical clearance

### Mots bannis dans tout texte généré (running spec étendue strength)

- "soigner [pathologie]", "traitement [pathologie]", "guérir", "remède"
- "rééducation post-opératoire", "post-blessure", "post-chirurgie"
- "cure", "thérapie", "diagnostic", "prescription", "ordonnance"
- "soulager [douleur]" (préférer : "réduire l'inconfort", "favoriser le confort")
- "réparer le dos / le genou / l'épaule" (préférer : "renforcer", "stabiliser", "protéger")

Med Device Regulation 2017/745. Vérifier zéro occurrence dans `summary`, `progression_logic`, `safety_notes`, `notes` exercices.

### Triggers medical clearance obligatoire

Inclure mention "Consulte un médecin avant de commencer ce programme" dans `safety_notes` si :

- **Pathologie lombaire chronique** (hernie discale, lombalgie chronique, spondylose) → "consulte un médecin/kiné avant tout deadlift et squat lourds, et préfère les variantes goblet squat / trap bar deadlift en démarrage".
- **Antécédents cardiovasculaires** (hypertension non contrôlée, antécédent IDM, arythmie) → mention Valsalva, %1RM > 80% à éviter sans avis médical.
- **Grossesse** (`pregnancy`) → squat / deadlift lourds contre-indiqués sans avis sage-femme / médecin ; programmes adaptés (DB squat partial ROM, glute bridge, push-up modifié) seulement.
- **Reprise post-opératoire / post-blessure** (< 6 mois sur épaule, genou, lombaire, hanche).
- **Profil > 50 ans débutant complet** sans test effort récent.

---

## Substitutions classiques (alternatives v2)

Documenté au niveau `exercise.alternatives[]` dans le template. **`alternatives: []` vide non-toléré.**

| Exercice planifié | Substitution | Trigger |
|---|---|---|
| Back squat barbell | Goblet squat DB/KB / Front squat / Bulgarian split squat | `lower-back-pain`, pas de rack, débutant |
| Conventional deadlift | Trap bar deadlift / RDL / Hip thrust / KB swing | `lower-back-pain`, pas de barbell |
| Bench press barbell | DB bench / Push-up lesté / Floor press DB | Pas de bench solo, `shoulder-injury` (pause grip neutre) |
| Overhead press barbell | DB shoulder press / Landmine press / Push-press | `shoulder-injury`, hyperextension cervicale, pas de barre |
| Barbell row | DB row / Cable row / Inverted row TRX | `lower-back-pain` (substitut chest-supported), pas de barbell |
| Pull-up / Chin-up | Lat pulldown / Y-raise + DB pullover combo / Band pull-down / Doorframe row | Pas de pullup-bar (home), faiblesse pull-up |
| Sortie heavy single 1RM | Top set 5RM ou 3RM AMRAP | Fatigue cumulée 2 sem, signal sommeil dégradé |
| Volume day Texas 5x5 | 4x5 ou 3x5 (réduction sets) | Charge récupération limitée, `competitive` early build |

---

## Hooks metadata standards (strengthTraining)

### `target_zone` — valeurs autorisées

- `RPE 5-6`, `RPE 6-7`, `RPE 7-8`, `RPE 8-9`, `RPE 9-10`
- `RIR 0-1`, `RIR 1-2`, `RIR 2-3`, `RIR 3-4`
- `%1RM 65-75%`, `%1RM 75-85%`, `%1RM 85-95%`
- `technique` (warmup, mobilité, drills, ramp-up bas)

Pour cardio léger d'échauffement / cooldown : utiliser `RPE 4-5` (conversational, équivalent walking-recovery).

### `required_equipment` — vocabulaire kebab-case

- `barbell` : barre olympique standard
- `dumbbells` : haltères (paire)
- `kettlebell` : kettlebell unique ou paire
- `rack` : squat rack ou power rack (sécurité compounds)
- `bench` : banc plat / inclinable
- `pullup-bar` : barre de traction (porte ou fixe)
- `cable-machine` : machine à câbles (cable row, lat pulldown, face pulls)
- `resistance-band` : élastique de résistance (long ou loop)
- `box` : box plyo ou plinth (step-up, box squat, box jump)
- `mat` : tapis sol (core, mobilité)
- `trap-bar` : barre trap / hex bar (deadlift alternative)
- `dipping-bars` : barres parallèles dips
- `landmine` : landmine attachment (rotational, press)
- `foam-roller` : rouleau soft tissue
- `lifting-belt` : ceinture (`competitive` >80% 1RM)

**Convention** : pour `beginner` home, équipement minimal `[]` (bodyweight) ou `["dumbbells", "mat"]`. Toujours documenter alternative bodyweight pure si possible.

### `incompatible_constraints` — vocabulaire kebab-case

- `lower-back-pain`, `shoulder-injury`, `knee-injury`, `wrist-pain`, `cervical-pain`, `hip-injury`
- `no-equipment`, `home-only`, `apartment-noise` (saut / dropping plates impossible)
- `no-rack` (squat back / OHP rackés impossible — propose front squat / Z-press)
- `no-bench` (bench press impossible — propose floor press DB, push-up lesté)
- `no-pullup-bar` (pull-up impossible — propose lat pulldown élastique, doorframe row)
- `cardiac-clearance-required` (Valsalva interdit, %1RM > 80% à éviter)
- `pregnancy`, `postpartum-early`
- `hypertension` (Valsalva contre-indiqué, ceinture lifting recommandée, reps > 3)
- `osteoarthritis-knee`, `osteoarthritis-hip` (amplitude réduite, charges modérées)

### `alternatives` — règle minimale

**Au minimum 1-2 alternatives réalistes par exercice.** `alternatives: []` vide non-toléré. Documenter substitut équipement (no-barbell → DB, no-rack → goblet, no-bench → floor) ET substitut blessure (lower-back-pain sur deadlift → hip thrust).

### `volume_axis`

- `sets` (**principal pour strength** : `sets: 5` × `reps: "5"` standard) — utilisé pour la majorité des compounds + isolation
- `reps` (renforcement isolé sans set fixe : "AMRAP last set", "10-15 reps")
- `duration` (gainage, planches, hold isométrique : "Planche 45 sec")
- `distance` (rare, conditionning / farmer carry : "Farmer carry 30 m × 3")

Convention CoachingSage : `volume_axis: sets` est la valeur par défaut compounds. `reps` quand le set count est singleton (1 set top RPE 9 AMRAP). `duration` pour core / hold.

---

## `week_structure` typique par niveau

| Niveau | type | micro_pattern | recovery_cadence |
|---|---|---|---|
| **beginner** | `linear` | `full-body A + rest + full-body B + rest + full-body A + rest + rest` (3 sessions full-body alternées A/B/A puis B/A/B) | `1 cutback W5 sur plan 8 sem (-30 à -40% sets)` |
| **recreational** | `linear` | `upper + lower + rest + upper + lower + rest + rest` (4 sessions upper/lower split) | `1 deload toutes les 4 sem (-40% sets)` |
| **regular** | `undulating` (DUP) | `push + pull + legs + push + pull + legs + rest` (PPL 6×) OU `upper heavy + lower heavy + upper hyp + lower hyp + rest + active + rest` (4 sessions DUP) | `1 deload toutes les 4 sem (-40 à -50% sets)` |
| **competitive** | `block` (5/3/1 ou Texas Method) | Texas : `Volume day Mon + Recovery Wed + Intensity day Fri` ; 5/3/1 : `Squat W1 / Bench W1 / Deadlift W1 / OHP W1 + accessoires BBB` 4 jours | `Texas : deload W4, W8, W12 ; 5/3/1 : W4 deload intra-cycle de 4 sem` |

`deload_weeks` exemples :
- Plan 8 sem `beginner` home-basics : `[5]`
- Plan 12 sem `recreational` upper/lower : `[4, 8]`
- Plan 12 sem `regular` PPL : `[4, 8]` ou `[4, 8, 12]` selon volume pic
- Plan 12 sem `competitive` 5/3/1 strength cycle : `[4, 8, 12]` (deload intra-cycle)
- Plan 12 sem `competitive` Texas Method : `[4, 8, 12]`

---

## Sources

### Doctrine et volume landmarks
- [Training Volume Landmarks for Muscle Growth — RP Strength](https://rpstrength.com/blogs/articles/training-volume-landmarks-muscle-growth)
- [Dr. Mike Israetel MV, MEV, MAV, MRV Explained](https://drmikeisraetel.com/dr-mike-israetel-wikipedia/dr-mike-israetel-mv-mev-mav-mrv-explained/)
- [RP Training Volume Landmarks — Arvo](https://arvo.guru/resources/methods/rp-training)
- [Volume Landmarks Tool RP](https://volume-landmarks-rp-rals.vercel.app/)
- [Training Volume How Many Sets — Tailored Coaching Method](https://tailoredcoachingmethod.com/training-volume-how-many-sets-per-week/)

### Hiérarchie pyramide Helms
- [Muscle and Strength Training Pyramid v2.0 — studylib](https://studylib.net/doc/25756029/the-muscle-and-strength-pyramid-training-v2.0)
- [Muscle and Strength Pyramids official site](https://muscleandstrengthpyramids.com/)
- [Helms Pyramid Goodreads](https://www.goodreads.com/book/show/28431633-the-muscle-strength-pyramid---training)

### Méta-analyses Schoenfeld
- [Dose-response weekly volume meta-analysis 2017 — PubMed](https://pubmed.ncbi.nlm.nih.gov/27433992/)
- [Resistance Training Volume Enhances Hypertrophy — PMC](https://pmc.ncbi.nlm.nih.gov/articles/PMC6303131/)
- [Effects of Frequency on Hypertrophy — PubMed](https://pubmed.ncbi.nlm.nih.gov/30558493/)
- [Systematic Review Different Volumes — PMC](https://pmc.ncbi.nlm.nih.gov/articles/PMC8884877/)
- [Resistance Training Dose-Response Meta-Regressions — SportRxiv](https://sportrxiv.org/index.php/server/preprint/view/460)

### NSCA standards
- [NSCA CSCS Chapter 17 Program Design — PTPioneer](https://www.ptpioneer.com/personal-training/certifications/nsca-cscs/cscs-chapter-17/)
- [NSCA CPT Chapter 15 Resistance Programs — PTPioneer](https://www.ptpioneer.com/personal-training/certifications/nsca-cpt/nsca-cpt-chapter-15/)
- [NSCA Manipulating Rest Intervals PDF](https://www.nsca.com/contentassets/fb8a7be6eb174934bb8844703c4de4cc/ptq-10.1.3-how-to-manipulate-rest-intervals-to-maixmize-strength-training-effectiveness.pdf)
- [NSCA Foundations of Fitness Programming PDF](https://www.nsca.com/contentassets/8323553f698a466a98220b21d9eb9a65/foundationsoffitnessprogramming_201508.pdf)
- [NSCA Basics of Strength and Conditioning PDF](https://www.nsca.com/contentassets/de9aebfe7a7340b69217b99bb13862a7/basics_of_strength_and_conditioning_manual.pdf)

### Programmes structurés
- [StrongLifts 5x5 Complete Guide](https://stronglifts.com/stronglifts-5x5/)
- [StrongLifts 5x5 Progression](https://stronglifts.com/stronglifts-5x5/progress/)
- [Wendler 5/3/1 Complete Guide — Arvo](https://arvo.guru/resources/methods/wendler-531)
- [5/3/1 Program Calculator — BiteKit](https://bitekit.app/tools/531-program-calculator/)
- [Texas Method Explained — PowerliftingToWin](https://www.powerliftingtowin.com/texas-method/)
- [Texas Method Strength Program — SetForSet](https://www.setforset.com/blogs/news/the-texas-method-strength-program)
- [6 Day Push/Pull/Legs Hypertrophy — Weightology](https://weightology.net/muscle-gain/6-day-per-week-push-pull-legs-hypertrophy-split/)
- [PPL 6 Day Split — Hevy](https://www.hevyapp.com/6-day-split-workout-complete-guide/)

### RPE / RIR / warmup
- [BarBend RPE Scale Strength Training](https://barbend.com/how-to-use-rpe-scale-strength-training/)
- [BarBend Ramp-Up Sets](https://barbend.com/ramp-up-sets/)
- [Ripped Body RPE/RIR Guide](https://rippedbody.com/rpe/)
- [Reshape Warmup vs Working Sets](https://www.reshapeapp.ai/blog/warm-up-sets-vs-working-sets-structure-strength-sessions)
- [Reshape RPE Strength Training Explained](https://www.reshapeapp.ai/blog/strength-training-rpe-explained)
- [Rehab2Perform Ramp-Up Right Way](https://rehab2perform.com/news/ramp-it-right-way/)
- [Evolved Training Systems Ramp-up RIR](https://evolvedtrainingsystems.com/ramp-up-sets-rpe-and-proper-loading-procedure/)

### Prévention blessures / red flags
- [HSS Lower Back Pain After Deadlift](https://www.hss.edu/article_lower-back-pain-after-deadlift.asp)
- [Korba Spine Clinic — Deadlift Form Fixes](https://korbaspineclinic.com/deadlift-and-lower-back-pain-form-fixes/)
- [BenchMark PT — Deadlifting and Back Pain](https://www.benchmarkpt.com/blog/deadlifting-and-back-pain-can-it-help-or-make-pain-worse/)
- [Glackin PT — Deadlifts and Low Back Pain](https://www.glackinpt.com/blog/deadlifts-low-back-pain-causes-solutions)
- [Mitchell Holistic Health — Squats Deadlifts Causes](https://mitchellholistichealth.com/back-pain-squats-deadlifts-causes-solutions/)
- [Fitbod — Sore Back After Squats Deadlifts](https://fitbod.me/blog/sore-back-after-squats-and-deadlifts/)
- [Woodroof Chiro — Squats RDLs Low Back Pain](https://woodroofchiro.com/blog/why-squats-and-rdls-can-trigger-low-back-pain-in-some-lifters)

### Programmation beginner / fundamentals
- [Muscle & Strength Beginner Fundamentals](https://www.muscleandstrength.com/articles/beginner-strength-training-program-fundamentals)
- [Back Nine PT — Reps Sets Guide Strength Size Endurance](https://www.back9rehab.com/blog/the-science-of-strength-choosing-the-right-reps-and-sets-for-your-goals)
