# Doctrine TRIATHLON — fragment Story 0.5.10

Référentiel public sourcé pour la regen des templates triathlon Story 0.5.10 et l'algo deterministic local Story 3.3a.

**Last revised** : 2026-04-30.

**Statut** : Phase C — fragment triathlon complet, prêt à intégrer dans `leon-algo-doctrine-by-sport.md` puis à consommer par `master-triathlon.md`.

**Vocabulaire de niveau** (aligné enums Sport + Level Story 0.5.8) :
- `beginner` : 1ère expérience triathlon, sait nager 200-400 m crawl sans pause, courir 20-30 min sans marche, rouler 60 min en confort. Aucune expérience d'enchaînement ni de transition. Vise un sprint sans chrono, finir = victoire.
- `recreational` : a déjà fini ≥ 1 sprint, capable d'enchaîner les 3 disciplines, vise un sprint complet 750 m / 20 km / 5 km en performance personnelle.
- `regular` : pratique 4-5×/sem depuis ≥ 1 saison, sait poser un test CSS / FTP, vise un Olympic / distance M (1500 / 40 / 10).
- `competitive` : pratique 5-6×/sem incl. dryland + S&C, vise un Half-Ironman 70.3 (1900 / 90 / 21) avec objectif chiffré.

**Triathlon-beginner — spec inventée plausible (templates v1 ne couvraient pas ce niveau)** :
- Sprint sans chrono / 1ère expérience triathlon, finisher pur.
- Plan 8-10 semaines, 4 sessions/sem (≈ 2 swim + 1 bike + 1 run + 1 brick W4+ à partir de la mi-plan).
- Volume hebdo cible : 4-5 h/sem (pic), pédalage pur cumul + nage pur cumul + course pur cumul.
- Focus : aisance dans l'eau, pédalage 60-90 min en confort, course 20-30 min en confort, premières transitions T1/T2 à sec puis simulées.

---

## Doctrine référente

| Référence | Auteur | Application |
|---|---|---|
| **The Triathlete's Training Bible** (5e éd. 2024) | Joe Friel | Référentiel mondial de la programmation triathlon : périodisation Bompa-style (Prep / Base / Build / Peak / Race), zones FC + power + pace par discipline, concept de **limiter** (point faible = priorité). |
| **Your Best Triathlon: Advanced Training for Serious Triathletes** | Joe Friel | Plans triathlon avancés Olympic / Half / Ironman, mention explicite "devote a lot of training to your limiters". |
| **USA Triathlon — Brick Workouts Guide** | USA Triathlon | Définition brick session, cadence d'introduction (4-6 dernières semaines pré-course), progression durée brick. |
| **World Triathlon (ITU) — Age Group Training** | World Triathlon | Volume cible age-group adulte standard distance : 6-10 h/sem (médiane 9 h/sem), 3 swim + 3 bike + 3 run / sem. |
| **BeginnerTriathlete — Sprint Plans 8-13 sem** | BeginnerTriathlete community + Triathlete.com | Plans débutant absolu sprint, 4-5 h/sem, base→build→race phasing. |
| **80/20 Triathlon** | Matt Fitzgerald, David Warden | Distribution polarisée 80/20 transposée triathlon, Z2 dominante en base, intervalles ciblés en build. |

Sources :
- [Joe Friel — Periodization of Intensity](https://joefrieltraining.com/periodization-of-intensity/)
- [New Edition of The Triathlete's Training Bible (5e éd. Jan 2024)](https://joefrieltraining.com/new-edition-of-the-triathletes-training-bible-available-january-2024/)
- [Joe Friel — Thoughts on Training: Limiters](https://joefrieltraining.com/thoughts-on-training-2-limiters-and-acts-of-faith/)
- [Joe Friel's Bible for Periodisation — Coach Ray](https://www.coachray.nz/2021/10/18/joe-friels-bible-for-periodisation/)
- [Your Best Triathlon — Joe Friel book page](https://joefrieltraining.com/book/your-best-triathlon/)
- [USA Triathlon — How to Use Brick Workouts](https://www.usatriathlon.org/articles/training-tips/how-to-use-brick-workouts-in-triathlon-training)
- [Triathlete — 8-Week Sprint Plan for Beginners](https://www.triathlete.com/training/getting-started/8-week-sprint-triathlon-training-plan-beginners/)
- [Triathlete — 16-Week Olympic Plan](https://www.triathlete.com/training/olympic-triathlon-16-week-training-plan/)
- [Triathlete — 20-Week 70.3 Plan](https://www.triathlete.com/training/20-week-training-plan-first-70-3-triathlon/)
- [Beginner Triathlete — Sprint Balanced Lifestyle 8wk](https://beginnertriathlete.com/sprint-balanced-lifestyle-8-week-triathlon-training-plan/)
- [Beginner Triathlete — Original 13-Week Sprint Plan](https://beginnertriathlete.com/the-original-13-week-sprint-triathlon-training-plan/)
- [TrainingPeaks — Beginner 16wk Olympic Plan](https://www.trainingpeaks.com/training-plans/triathlon/olympic/tp-7725/beginner-16-week-olympic-distance-triathlon)
- [TrainingPeaks — 20wk Novice 70.3 Plan 6.5-11.5 hpw](https://www.trainingpeaks.com/training-plans/triathlon/half-ironman/tp-102587/novice-ironman-70-3-20-week-plan-6-5-11-5-hrs-per-week)
- [80/20 Triathlon Intensity Guidelines](https://www.8020endurance.com/intensity-guidelines-for-8020-triathlon/)
- [World Triathlon — Sport of Triathlon: Transitions](https://triathlon.org/agegroup/training/transitions)

---

## Zones d'effort (target_zone)

Convention triathlon v2 : **chaque discipline garde son référentiel de zones natif** (running Daniels, cycling Coggan FTP, swimming Maglischo + CSS), plus `RPE` pour S&C. C'est le choix de doctrine Friel — un athlète multi-sport pace chaque discipline avec son test spécifique (VDOT pour run, FTP pour bike, CSS pour swim), pas un % FCmax universel qui efface la spécificité.

### Running (Daniels)
| Zone | Allure | Application |
|---|---|---|
| `Daniels-E` | MP + 1:00 à 1:30 / km, conversational | Sortie longue, recovery, échauffement |
| `Daniels-M` | Marathon Pace | Bloc spécifique distance Half+ |
| `Daniels-T` | 10K + 15-30 s / km | Tempo continu 20-40 min |
| `Daniels-I` | Allure 3K-5K | VO2max 3-5 min × 4-6 reps |
| `Daniels-R` | Allure 800m-1500m | Vitesse 200-400 m × 8-12 reps |
| `walking-recovery` | Marche active | Récup intervalle, transitions T1/T2 simulées |

Pour `beginner` triathlon : `Daniels-E` uniquement + `walking-recovery` en transition (le run post-bike est nouveau et challengeant — pas d'intensité dure tant que la sensation "jambes en coton" n'est pas absorbée).

### Cycling (Coggan FTP)
| Zone | % FTP | Application |
|---|---|---|
| `FTP-Z1` | < 55% | Recovery, échauffement, cooldown |
| `FTP-Z2` | 56-75% | Endurance, sortie longue, transitions T1 |
| `FTP-Z3` | 76-90% | Tempo, sweet spot bas |
| `Sweet-Spot` | 88-94% | Bloc base, intervalles longs |
| `FTP-Z4` | 91-105% | Threshold, intervalles 8-30 min |
| `FTP-Z5` | 106-120% | VO2max, 3-8 min × 4-6 reps |
| `RPE 4-5` à `RPE 8-9` | Effort perçu | Sans powermeter (majorité `beginner`/`recreational`) |

Pour `beginner` triathlon : `FTP-Z1`, `FTP-Z2`, `RPE 3-4` uniquement.

### Swimming (Maglischo + Swim Smooth CSS)
| Zone | Repère | Application |
|---|---|---|
| `EN1` | CSS + 8-12 s/100m | Aérobie de base, conversational |
| `EN2` | CSS ± 0-3 s/100m | Seuil aérobie |
| `EN3` | CSS - 5 à -10 s/100m | Proche VO2max, séries 100-200 m |
| `SP1` | Allure 200 m race | Tolérance lactique 1-2 min |
| `CSS pace` | Pace explicite | Threshold sustained |
| `technique` | Pas de cible cardio | Drills purs |
| `REC` | CSS + 15-20 s/100m | Récup active, échauffement |

Pour `beginner` triathlon : `technique` + `REC` + sensation conversationnelle uniquement (pas de pacing CSS — un test 400+200 demande déjà un patron moteur stable, prématuré au 1er triathlon).

### S&C (RPE)
| Zone | RPE | Application |
|---|---|---|
| `RPE 6-7` | 6-7 | Renforcement préventif, mobility, dryland |
| `RPE 7-8` | 7-8 | Force-endurance hors-saison `regular`+ |
| `RPE 8-9` | 8-9 | Pliométrie modérée `competitive` hors-saison |

**Règle de notation triathlon v2** : un exercice triathlon dans le JSON est zoné selon la discipline qu'il représente. Une session brick a 2 exercices (vélo + course) chacun avec son `target_zone` propre.

---

## Volume hebdo cible par niveau

**Convention volume triathlon v2** : volume hebdo = **somme des trois disciplines en effort sport-pur** (heures de pédalage pur + heures de course pure + mètres ou minutes de nage pure), exprimé en **heures cumul total** dans `summary` et `progression_logic`. Détail par discipline obligatoire dans `progression_logic` (h swim / h bike / h run + min S&C).

| Niveau | Vol pic total (h/sem) | Distribution typique pic | Fréquence | Doctrine source |
|---|---|---|---|---|
| **beginner** | 4-5 h/sem (sprint sans chrono) | ~1 h swim + 1.5 h bike + 1.5 h run + 0.5 h S&C/mob | 4 sessions/sem (W1-W4) → 5 sessions/sem (W5+) | BeginnerTriathlete 8wk Sprint Balanced, Triathlete 8wk Beginner |
| **recreational** | 5-7 h/sem (sprint complet) | ~1.5 h swim + 2 h bike + 1.5 h run + 0.5-1 h S&C | 4-5 sessions/sem | Triathlete 12wk Sprint, BeginnerTriathlete 13wk Sprint |
| **regular** | 8-10 h/sem (Olympic) | ~2 h swim + 3.5 h bike + 2 h run + 0.5-1 h S&C | 5-6 sessions/sem (2 par discipline + S&C) | World Triathlon Age-group Standard, Triathlete 16wk Olympic |
| **competitive** | 10-14 h/sem (Half-Ironman 70.3) | ~3 h swim + 5-6 h bike + 3-3.5 h run + 1 h S&C | 6-7 sessions/sem (2-3 par discipline + S&C) | Triathlete 20wk 70.3, MyProCoach 70.3, TrainingPeaks Novice 70.3 6.5-11.5 hpw |

**Distance cibles** :
- `beginner` : sprint 750 m / 20 km / 5 km **sans chrono** (objectif = finir, pas perf).
- `recreational` : sprint 750 / 20 / 5 **avec objectif chrono personnel**.
- `regular` : Olympic / distance M 1500 / 40 / 10.
- `competitive` : Half-Ironman 70.3 (1900 / 90 / 21).

**Long workout pic par discipline** :
- `beginner` : swim 400-600 m, bike 60-90 min ou 25-30 km, run 25-35 min ou 4-5 km.
- `recreational` : swim 1000-1500 m, bike 90 min ou 35-45 km, run 45 min ou 7-8 km.
- `regular` : swim 2000-2500 m, bike 2-3 h ou 60-80 km, run 75-90 min ou 12-15 km.
- `competitive` : swim 3000-3500 m, bike 4-5 h ou 100-130 km, run 1h45-2h ou 18-21 km.

Sources : [Triathlete 8wk Beginner Sprint](https://www.triathlete.com/training/getting-started/8-week-sprint-triathlon-training-plan-beginners/), [Triathlete 16wk Olympic](https://www.triathlete.com/training/olympic-triathlon-16-week-training-plan/), [Triathlete 20wk 70.3](https://www.triathlete.com/training/20-week-training-plan-first-70-3-triathlon/), [TrainingPeaks Novice 70.3 6.5-11.5hpw](https://www.trainingpeaks.com/training-plans/triathlon/half-ironman/tp-102587/novice-ironman-70-3-20-week-plan-6-5-11-5-hrs-per-week).

---

## Périodisation triathlon (3 disciplines parallèles)

### Principe Friel — parallélisme strict
Les 3 disciplines progressent **EN PARALLÈLE** chaque semaine. **Jamais de bloc mono-discipline** (4 sem natation pure → 4 sem vélo pure = anti-pattern). Chaque semaine contient au minimum 1 séance de chaque discipline (sauf `beginner` W1-W3 où run peut être 1×/sem si le profil d'origine est faible en course).

Justification : l'adaptation neuromotrice spécifique à chaque sport décline en 7-10 jours sans stimulus. Un triathlète qui fait 4 sem sans nager perd sa "feel for the water" et doit la reconquérir. Friel TTB 5e éd. : "Train all three sports every week. The body learns to recover from one while training the other."

### Phases Friel triathlon
- **Base** (4-12 sem selon plan) : 70-85% du volume en Z1-Z2 / EN1-EN2, focus aérobie + technique. Drills swim 25-40% volume swim. Sweet spot bike accepté en `recreational`+ phase base.
- **Build** (4-8 sem) : intro intensités spécifiques par discipline (Daniels-T pour run, FTP-Z4 / sweet spot pour bike, CSS / EN3 pour swim). Brick sessions deviennent obligatoires dès Build W1.
- **Peak / Race-pace** (2-3 sem) : simulations distance (race-pace bike, race-pace run, swim broken pace), brick complet swim+bike+run en `competitive`.
- **Taper** (1-3 sem selon distance cible) : volume -30 à -50%, fréquence ≥ 80% maintenue, intensités courtes conservées.

### Cycle de base (build / deload)
- `beginner` : 5-6 build + 1 cutback (-20 à -30% accepté car charge absolue faible).
- `recreational` : 3 build + 1 deload (-15 à -20%).
- `regular` : 3 build + 1 deload (-15 à -20%).
- `competitive` : 2-3 build + 1 deload (-15 à -20%).

Pour tout plan ≥ 6 semaines : prévoir au moins 1 semaine cutback. Renseigne `deload_weeks: [W]` au niveau template. Préfère un range ("réduction ~15-20%") qu'un chiffre faux dans `progression_logic`.

### Tapering par distance cible
- **Sprint sans chrono (`beginner`)** : J-7 volume -25 à -30%, J-3 à J-1 sortie courte 30 min Z2 + reconnaissance parcours. Pas de taper "long".
- **Sprint chrono (`recreational`)** : J-14 volume -20%, J-7 -40%, J-3 à J-1 brick court 20 min bike + 5 min run + 200-300 m swim + drills.
- **Olympic (`regular`)** : taper 14 jours, J-14 -25%, J-7 -50%. J-3 à J-1 séances courtes par discipline + 1 brick court réveil neuromusculaire J-2.
- **Half-Ironman (`competitive`)** : taper 14-21 jours, J-21 -15%, J-14 -30%, J-7 -50%. J-3 à J-1 séances très courtes + simulations transitions à sec.

Sources : [Joe Friel — Periodization of Intensity](https://joefrieltraining.com/periodization-of-intensity/), [Joe Friel's Bible for Periodisation — Coach Ray](https://www.coachray.nz/2021/10/18/joe-friels-bible-for-periodisation/), [Triathlete 20wk 70.3](https://www.triathlete.com/training/20-week-training-plan-first-70-3-triathlon/).

---

## Brick sessions (transitions vélo→course)

### Définition (USA Triathlon)
Une **brick session** est un enchaînement de 2 disciplines sans pause significative (transition courte 1-3 min). En triathlon, "brick" = bike→run (le plus courant), occasionnellement swim→bike (`competitive` uniquement). L'objectif est d'entraîner l'adaptation neuromotrice de transition (sensation "jambes en coton" sur les premières 5-10 min de course post-vélo).

### Cadence d'introduction obligatoire (par niveau)
| Niveau | Brick débute en | Fréquence en build | Format type pic |
|---|---|---|---|
| **beginner** | W4-W5 (mi-plan) | 1 brick/sem | 30 min bike Z2 + 10 min run Z2 |
| **recreational** | W4 | 1 brick/sem | 45 min bike + 15 min run |
| **regular** | W3 | 1 brick/sem build + 1 brick "long" all-3-disciplines en peak | 60-75 min bike + 25-30 min run |
| **competitive** | W2 | 2 bricks/sem (1 long endurance + 1 court tempo / cadence) | 90-120 min bike + 30-45 min run race-pace |

### Règles strictes brick
- **Premier brick** : run TRÈS court (5-10 min) à allure Z2 pour focus sensation, pas perf.
- **Transition T1/T2** : à sec en S&C dès W3-W4 (`beginner`), simulée pool-side en `recreational`+ dès Build W2.
- **Brick course pure post-bike** : jamais > 25% du volume run hebdo en `beginner` (la jambe répétée post-pédalage stresse les ischios + tendon rotulien).
- **Swim→bike brick** : `competitive` uniquement, en peak (W-3 à W-1), 1500-2000 m + 30-60 min bike easy.
- **Brick + intensité** : haute intensité sur le bike, run en Z2 (`beginner`/`recreational`) ou Z3 max (`regular`+). Jamais HIT bike + HIT run consécutifs (= surcharge neuromusculaire).

Sources : [USA Triathlon — Brick Workouts](https://www.usatriathlon.org/articles/training-tips/how-to-use-brick-workouts-in-triathlon-training), [ROUVY Brick Workouts Guide](https://rouvy.com/blog/brick-workouts-triathlon), [MyProCoach 8 Best Brick Workouts](https://www.myprocoach.net/blog/8-best-brick-triathlon-workouts/), [TrainingPeaks Using Brick Workouts](https://www.trainingpeaks.com/blog/using-brick-workouts-in-triathlon-training/).

---

## Priorisation point faible (limiter — Friel)

### Concept clé Friel TTB
> "You can't be good at everything—which is your weakest sport? Devote a lot of training to your limiters."
> — Joe Friel, *Your Best Triathlon*

En triathlon, le **point faible** est la discipline qui pénalise le plus le chrono final ou la finishability. Pour un débutant français adulte type, c'est presque toujours la **natation** (aucune base technique vs run/bike accessibles).

### Lecture de `assumed_profile.weakest_discipline`
Le profil utilisateur déclare son point faible déclaré (`weakest_discipline: "swim" | "bike" | "run"` ou `null` si équilibré). L'algo Story 3.3a doit pondérer le volume :

| `weakest_discipline` déclaré | Effet sur volume hebdo type |
|---|---|
| `swim` (le plus fréquent débutant) | +1 séance swim/sem si possible (3 swim au lieu de 2 dès W1 `beginner`/`recreational`) |
| `bike` | +1 sortie endurance Z2 / sem (longue ride priorisée) |
| `run` | Volume run +15-20%, mais cap à 4 séances/sem max pour éviter blessure |
| `null` | Distribution standard du template |

**Garde-fous** :
- Ne JAMAIS doubler la dose sur le point faible si signe de fatigue (FC repos +10 bpm, sommeil dégradé).
- Maintenir AU MINIMUM 1 séance / discipline / sem même hors point faible (anti-déskill).

Sources : [Joe Friel — Limiters and Acts of Faith](https://joefrieltraining.com/thoughts-on-training-2-limiters-and-acts-of-faith/), [Your Best Triathlon — Joe Friel](https://joefrieltraining.com/book/your-best-triathlon/).

---

## Drapeaux rouges multi-discipline

### Spécificité triathlon : cumul des charges
Le triathlète multiplie les surfaces locomotrices sollicitées (eau / vélo / asphalte). Le risque blessure n'est pas l'addition des risques de chaque sport, c'est leur **interaction** (chaîne postérieure surchargée par bike + run, épaule par swim répétée + position vélo).

### Tendinopathies multi-discipline (cumul charges)
- **Tendinopathie achille** : bike SFR / cadence basse + run rapide consécutif = charge cumulative tendon. Calf raises excentriques en prévention 2×/sem.
- **Tendinopathie ischio-jambier** (haute, sous-fessière) : run post-bike répété, position aéro vélo en raccourcissement chronique des ischios. Nordic curl assisté + single-leg deadlift préventifs.
- **ITBS** (syndrome bandelette ilio-tibiale) : run post-bike prolongé, faiblesse abducteurs hanche. Clamshells dès W1.
- **Swimmer's shoulder** : volume swim + position aéro vélo (épaules en avant) = double impingement. Y-T-W + external rotation band 1-2×/sem `recreational`+.
- **PFPS** (syndrome fémoro-patellaire) : selle vélo trop basse + run intensité = douleur antérieure genou. Bike fit + step-up + pont fessier.

### RED-S endurance long course (`competitive`)
Charge entraînement Half-Ironman = 10-14 h/sem + S&C = besoin énergétique 2500-3500 kcal/jour + fuel séances longues. Risque déficit énergétique chronique : aménorrhée, baisse perf, fatigue chronique, immunité dégradée, fractures de stress. Mention obligatoire dans `safety_notes` `competitive`.

### Hypothermie / coup de chaleur en open water
- **Hypothermie** : eau < 16°C sans combinaison = risque vital sur sortie > 20 min. Combinaison néoprène quasi-obligatoire < 14°C, recommandée < 16°C, optionnelle 14-22°C, interdite > 24°C (risque hyperthermie).
- **Coup de chaleur** : swim eau > 28°C ou bike été chaleur > 30°C + déshydratation = signaux céphalée, frissons paradoxaux, désorientation = STOP immédiat.
- **Panique respiratoire eau libre** : prévisualiser plan d'eau, s'acclimater bassin avec combinaison W-2 à W-1, repère visuel. En cas de panique : roulé sur le dos, respiration calmée, lever bras pour assistance.

### Erreurs nutrition long course (`regular`+ et surtout `competitive`)
- Sortie > 90 min : 60-90 g glucides/h (ratio 2:1 glucose:fructose au-delà de 60 g/h).
- Hydratation 500-1000 ml/h selon T° + sodium 300-700 mg/L.
- Gut training progressif si profil non habitué (démarrer 30 g/h, progresser sur 4-6 sem).
- Tester nutrition jour J en simulation race-pace W-3 à W-2, JAMAIS de nouvelle nutrition le jour J.

Sources : [Cleveland Clinic — Swimmer's Ear](https://my.clevelandclinic.org/health/diseases/8381-swimmers-ear-otitis-externa), [PMC — Effect of Preventive Exercise Programs for Swimmer's Shoulder 2024](https://pmc.ncbi.nlm.nih.gov/articles/PMC11899141/), [MyProCoach — 70.3 Plans](https://www.myprocoach.net/free-training-plans/half-ironman-70-3/).

---

## Mots EU MDR à bannir (triathlon spécifique)

Vocabulaire qui constituerait un acte médical en UE (Med Device Regulation 2017/745).

**Bannis dans tout texte généré** :
- "soigner [pathologie]", "traitement [pathologie]", "guérir", "remède"
- "rééducation post-opératoire", "post-blessure", "post-accident"
- "cure", "thérapie", "diagnostic", "prescription", "ordonnance"
- "soulager [douleur]" → préférer "réduire l'inconfort", "favoriser le confort"
- "réparer le genou / l'épaule / le dos" → préférer "renforcer", "stabiliser"

**Triggers medical clearance obligatoire** (mention "Consulte un médecin avant de commencer ce programme") :
- Antécédents cardiaques connus (`cardiac-clearance-required`).
- Grossesse (`pregnancy`) — triathlon Z2 reste accessible mais avis médical de principe, brick déconseillé T2/T3.
- Pathologie chronique épaule (déchirure coiffe, capsulite) — incompatible volume swim soutenu.
- Reprise post-chirurgie épaule, dos, genou (< 6 mois).
- Asthme sévère / insuffisance respiratoire — eau libre + apnée intermittente swim = stress respiratoire.
- Profil > 50 ans débutant complet sans test effort cardio récent.

---

## Hooks metadata standards (triathlon)

### `target_zone`
Vocabulaire **par discipline** (l'algo Story 3.3a doit lire le contexte session pour interpréter la zone) :

- **Running** : `Daniels-E`, `Daniels-M`, `Daniels-T`, `Daniels-I`, `Daniels-R`, `walking-recovery`, `@10K-pace`, `@5K-pace`, `@MP-10s/km`, `@HMP`.
- **Cycling** : `FTP-Z1`, `FTP-Z2`, `FTP-Z3`, `Sweet-Spot`, `FTP-Z4`, `FTP-Z5`, `FTP-Z6`, `FTP-Z7`, `RPE 4-5`, `RPE 6-7`, `RPE 7-8`, `RPE 8-9` (sans powermeter), `cadence-90rpm`, `cadence-100rpm`.
- **Swimming** : `REC`, `EN1`, `EN2`, `EN3`, `SP1`, `SP2`, `SP3`, `CSS+5s/100m`, `CSS-2s/100m`, `CSS pace`, `technique`.
- **S&C / mobility** : `RPE 6-7`, `RPE 7-8`, `RPE 8-9`.
- `null` justifié pour échauffement libre / cooldown étirements.

### `required_equipment`
Vocabulaire kebab-case unifié triathlon :

**Swim** :
- `pool` (assumé pour toute session swim — ne JAMAIS omettre, distinctif swimming).
- `goggles`, `swim-cap` (peuvent être omis, assumés).
- `pull-buoy`, `kickboard`, `fins`, `swim-paddles` (`regular`+ uniquement, risque épaule débutant), `snorkel`.
- `wetsuit` : OPTIONNEL `beginner` (eau > 20°C en piscine → pas besoin), recommandé `recreational`+ open water, OBLIGATOIRE eau libre < 16°C.
- `tempo-trainer` (`competitive` uniquement).

**Bike** :
- `helmet` : OBLIGATOIRE à toute sortie route — ne JAMAIS l'omettre.
- `road-bike` (par défaut), alternativement `mtb`, `gravel-bike`, `tt-bike` (`competitive`).
- `indoor-trainer` ou `smart-trainer` (alternatives météo, brick contrôlé, ERG).
- `power-meter` : optionnel `recreational`, recommandé `regular`+, attendu `competitive`.
- `heart-rate-monitor`, `bike-computer`, `gps-watch`.
- `cycling-shoes`, `cleats` (assumé `recreational`+).
- `bidons` (× 2 sortie > 90 min), `front-light`, `rear-light`, `reflective-vest`.
- `aerobars` (`competitive` Half-Ironman position).

**Run** :
- `running-shoes` (assumé, peut être omis).
- `gps-watch` (recommandé `recreational`+).

**Brick / transition** :
- `transition-area-setup` : kit transition (sac transition, tapis, chaussures bike + run prêtes côte-à-côte). À utiliser dans les sessions brick W3+ pour `recreational`+, W5+ pour `beginner`.
- `race-belt` (porte-dossard), `elastic-laces` (lacets élastiques pour T2 rapide).

**S&C** :
- `mat`, `resistance-band`, `dumbbells`, `kettlebell` (`regular`+), `bench` (dryland swim).

### `incompatible_constraints`
Vocabulaire kebab-case combinant les 3 disciplines + S&C :

- **Articulations** : `knee-injury`, `lower-back-pain`, `shoulder-injury`, `wrist-injury`, `ankle-injury`, `cervical-injury`, `shin-splints`.
- **Cardio / médical** : `cardiac-clearance-required`, `pregnancy`, `postpartum-early`, `asthma-severe`, `recurrent-otitis`, `chlorine-allergy`.
- **Accès / matériel** : `no-pool-access`, `no-bike`, `no-trainer`, `no-power-meter`, `no-open-water-access`.
- **Environnement** : `outdoor-only`, `indoor-only`, `apartment-noise`, `traffic-anxiety`, `cold-water-anxiety`.
- **Physiologique débutant** : `cant-swim-25m-continuous` (flag de garde — hors-cible triathlon `beginner`, suggérer plan natation pré-requis).

### `alternatives`
Liste de noms d'exercices substitutifs. **Minimum 1-2 alternatives réalistes par exercice. `alternatives: []` vide INTERDIT** — l'algo deterministic Story 3.3a en a besoin.

| Exercice planifié | Substitution | Trigger |
|---|---|---|
| Sortie open water | Séance pool équivalente avec combinaison + drill sighting (lever tête tous les 6 strokes) | Pas d'accès eau libre, météo, sécurité |
| Brick bike→run extérieur | Brick bike trainer indoor + tapis run | Météo, traffic anxiety |
| Long ride bike | Bloc trainer sweet spot (-15 à -20% durée pour équivalence) | Pluie, verglas, < 0°C, > 35°C |
| Run post-bike (brick) | Vélo elliptique 1:1 ratio temps en Z2 | Knee-flare aigu, shin splints |
| Swim continu | 2 × demi-distance avec récup 1 min | Bassin bondé, pas la concentration |
| Drill swim avec paddles | Drill sans paddles ou *sculling* mains seules | Douleur épaule, pas de paddles |
| Séance swim | Vélo Z2 1:1 ratio temps OU course Z1-Z2 | Otite, pas d'accès piscine |

### `volume_axis`
- `duration` (par défaut bike, run, drills timés, échauffement, brick complet)
- `distance` (long run extérieur, long bike avec km cible, swim en mètres `regular`+)
- `sets` (séries structurées intervalles, brick multi-blocs)
- `reps` (S&C : Y-T-W, hip thrust, calf raises)
- `elevation` (`regular`+ uniquement, séance côte D+)

---

## `week_structure` typique par niveau

| Niveau | type | micro_pattern | recovery_cadence |
|---|---|---|---|
| **beginner** | `linear` | `swim technique + bike Z2 + run Z2 + S&C/mob + brick (W4+)` (4-5 sessions) | `1 cutback W4 ou W5 sur plan 8-10 sem` |
| **recreational** | `linear` | `swim drills + swim endurance + bike Z2 + bike sweet spot + run Z2 + brick (W4+)` (4-5 sessions) | `1 deload toutes les 4 semaines` |
| **regular** | `block` | `swim CSS + swim long + bike intervals Z4 + bike long + run intervals + run long + brick + S&C` (5-6 sessions) | `1 deload toutes les 3-4 semaines` |
| **competitive** | `polarized` | `swim threshold + swim long + bike VO2max + bike long + run threshold + run long + brick × 2 + S&C × 1-2` (6-7 sessions) | `1 deload toutes les 2-3 semaines + taper 14-21j` |

`deload_weeks` exemples :
- Plan 8 sem `beginner` : `[5]`
- Plan 12 sem `recreational` : `[4, 8]`
- Plan 16 sem `regular` : `[4, 8, 12]`
- Plan 20 sem `competitive` : `[4, 8, 12, 16]` + taper W19-W20 distinct

---

## Sources triathlon complètes

### Doctrine Friel (référentiel principal)
- [Joe Friel — Periodization of Intensity](https://joefrieltraining.com/periodization-of-intensity/)
- [Joe Friel — Thoughts on Training: Limiters and Acts of Faith](https://joefrieltraining.com/thoughts-on-training-2-limiters-and-acts-of-faith/)
- [New Edition of The Triathlete's Training Bible (5e éd. 2024)](https://joefrieltraining.com/new-edition-of-the-triathletes-training-bible-available-january-2024/)
- [Your Best Triathlon — Joe Friel](https://joefrieltraining.com/book/your-best-triathlon/)
- [Joe Friel's Bible for Periodisation — Coach Ray](https://www.coachray.nz/2021/10/18/joe-friels-bible-for-periodisation/)
- [Joe Friel Training Plans](https://joefrieltraining.com/training-plans/)

### USA Triathlon / World Triathlon
- [USA Triathlon — How to Use Brick Workouts](https://www.usatriathlon.org/articles/training-tips/how-to-use-brick-workouts-in-triathlon-training)
- [World Triathlon — Sport of Triathlon: Transitions](https://triathlon.org/agegroup/training/transitions)
- [World Triathlon Competition Rules](https://triathlon.org/documents/rules)
- [Triathlon Distances — DIN Calculator](https://www.dincalculator.com/triathlon/distances)

### Plans sprint débutant (`beginner` / `recreational`)
- [Triathlete — 8-Week Sprint Plan for Beginners](https://www.triathlete.com/training/getting-started/8-week-sprint-triathlon-training-plan-beginners/)
- [Beginner Triathlete — Sprint Balanced Lifestyle 8wk](https://beginnertriathlete.com/sprint-balanced-lifestyle-8-week-triathlon-training-plan/)
- [Beginner Triathlete — Original 13-Week Sprint Plan](https://beginnertriathlete.com/the-original-13-week-sprint-triathlon-training-plan/)
- [TrainingPeaks — 8wk Absolute Beginner Sprint](https://www.trainingpeaks.com/training-plans/triathlon/sprint/tp-139500/8-week-absolute-beginner-sprint-triathlon-plan)
- [Marathon Handbook — 8-Week Beginner Sprint Plan](https://marathonhandbook.com/sprint-triathlon-training-plan/)
- [CTS — 8 Week Sprint First-Timers](https://trainright.com/8-week-triathlon-training-plan-sprint-distance-first-timers/)
- [First Time Triathlete — FTT 8 Week Sprint](https://firsttimetriathlete.com/ftt-8-week-sprint-training-plan/)
- [Steel City Endurance — 12wk Beginner Sprint](https://steelcityendurance.com/sprint-triathlon-training-plan-for-beginners-12-weeks/)
- [ROUVY — Sprint Triathlon Training Plan](https://rouvy.com/blog/sprint-triathlon-training-plan)
- [Active.com — Beginner's Sprint Triathlon Training Plan](https://www.active.com/triathlon/articles/a-beginners-sprint-triathlon-training-plan)
- [Grand Rapids Tri — 14wk Beginner Sprint Plan PDF](https://grandrapidstri.com/wp-content/uploads/2019/06/Sprint-Training-Plan_GRTRI.pdf)

### Plans Olympic (`regular`)
- [Triathlete — 16-Week Olympic Plan](https://www.triathlete.com/training/olympic-triathlon-16-week-training-plan/)
- [TrainingPeaks — Beginner 16wk Olympic Distance](https://www.trainingpeaks.com/training-plans/triathlon/olympic/tp-7725/beginner-16-week-olympic-distance-triathlon)
- [TrainingPeaks — 16wk Olympic HR-based](https://www.trainingpeaks.com/training-plans/triathlon/olympic/tp-231447/16-week-olympic-distance-triathlon-program-based-on-hr)
- [Marathon Handbook — 16wk Beginner Olympic](https://marathonhandbook.com/olympic-triathlon-training-plan/)
- [Grand Rapids Tri — 16wk Olympic Plan PDF](https://grandrapidstri.com/wp-content/uploads/2019/06/Olympic-Training-Plan_GRTRI.pdf)
- [TrainingPeaks — ITU World Tri Leeds 8wk Intermediate Standard](https://www.trainingpeaks.com/training-plans/triathlon/tp-74155/itu-world-triathlon-leeds-8-week-intermediate-standard-distance-training-plan)
- [220 Triathlon — Free Olympic-distance Plans](https://www.220triathlon.com/training/training-plans/free-olympic-distance-triathlon-training-plans)
- [Snacking In Sneakers — 16wk Beginner Olympic](https://www.snackinginsneakers.com/16-week-olympic-triathlon-training-plan/)

### Plans Half-Ironman 70.3 (`competitive`)
- [Triathlete — 20-Week 70.3 Plan](https://www.triathlete.com/training/20-week-training-plan-first-70-3-triathlon/)
- [TrainingPeaks — Novice 70.3 20wk 6.5-11.5 hpw](https://www.trainingpeaks.com/training-plans/triathlon/half-ironman/tp-102587/novice-ironman-70-3-20-week-plan-6-5-11-5-hrs-per-week)
- [TrainingPeaks — 20 Weeks 70.3](https://www.trainingpeaks.com/training-plans/triathlon/half-ironman/tp-538141/triathlon-20-weeks-training-plan-ironman-70-3)
- [MyProCoach — Free Half IRONMAN 70.3 Plans](https://www.myprocoach.net/free-training-plans/half-ironman-70-3/)
- [220 Triathlon — Free 70.3 Plans](https://www.220triathlon.com/training/training-plans/free-ironman-70-3-training-plans)
- [Plan B Coaching — Ultimate 20 Week 70.3 Plan](https://www.planbcoaching.co.uk/the-ultimate-20-week-ironman-70-3-triathlon-training-plan/)
- [ROUVY — Half-IRONMAN Beginner's Guide](https://rouvy.com/blog/half-ironman-training-plan)
- [SUMARPO — Ultimate Ironman Training Plan Guide](https://www.sumarpo.com/blogs/triathlon/the-ultimate-ironman-training-plan-guide-from-70-3-to-140-6-miles)

### Brick sessions (référence absolue)
- [USA Triathlon — Brick Workouts](https://www.usatriathlon.org/articles/training-tips/how-to-use-brick-workouts-in-triathlon-training)
- [ROUVY — Ultimate Guide to Brick Workouts](https://rouvy.com/blog/brick-workouts-triathlon)
- [MyProCoach — 8 Best Brick Triathlon Workouts](https://www.myprocoach.net/blog/8-best-brick-triathlon-workouts/)
- [TrainingPeaks — Using Brick Workouts](https://www.trainingpeaks.com/blog/using-brick-workouts-in-triathlon-training/)
- [Triathlete — Get to Know the Brick Workout](https://www.triathlete.com/training/get-to-know-the-brick-workout/)
- [80/20 Endurance Forum — Brick Training](https://www.forum.8020endurance.com/topic/brick-training/)
- [Sport Coaching — Best Brick Workouts](https://sportcoaching.com.au/best-brick-workouts-for-triathletes/)
- [Triathlon Magazine Canada — Three Brick Workouts](https://triathlonmagazine.ca/workouts/three-triathlon-brick-workouts/)
- [MyMottiv — Beginners Guide to Brick Workouts](https://www.mymottiv.com/how-to-train-for-a-triathlon/brick-workout)
- [OSB Multisport — Brick Training for Beginners](http://www.osbmultisport.com/articles/bricktrainingforbeginners.html)

### Distribution polarized 80/20 triathlon
- [80/20 Triathlon Intensity Guidelines](https://www.8020endurance.com/intensity-guidelines-for-8020-triathlon/)
- [80/20 Endurance Intensity Guidelines for Swimming](https://www.8020endurance.com/intensity-guidelines-for-swimming/)
- [Polarized Training VO2max Systematic Review 2024 — PMC NIH](https://pmc.ncbi.nlm.nih.gov/articles/PMC11679080/)

### Cross-références (doctrines mono-discipline déjà sourcées)
- Voir [doctrine-fragments/running.md](./running.md) pour zones Daniels VDOT, sources NHS C25K, Pfitzinger, Hansons.
- Voir [doctrine-fragments/cycling.md](./cycling.md) pour zones FTP Coggan, FasCat Sweet Spot, British Cycling, bike fit.
- Voir [doctrine-fragments/swimming.md](./swimming.md) pour zones Maglischo, CSS Swim Smooth, Total Immersion drills, swimmer's shoulder prevention.
- Voir [doctrine-fragments/strength-training.md](./strength-training.md) pour S&C dryland, Y-T-W, nordic curl, hip thrust.

---
