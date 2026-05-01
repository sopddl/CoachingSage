## CYCLING

Fragment doctrine sourcé pour la regen Story 0.5.10 et l'algo deterministic local Story 3.3a.

**Last revised** : 2026-04-30.

**Vocabulaire de niveau** (aligné enums Sport + Level Story 0.5.8) :
- `beginner` : aucune expérience récente, < 6 mois de pratique, vise une sortie 60-90 min en confort.
- `recreational` : pratique 1 à 2× / sem, capable de rouler 90 min en continu, vise une sportive courte 60-100 km.
- `regular` : pratique 3 à 4× / sem depuis ≥ 1 an, capable de rouler 2-3 h, vise sportive longue / gran fondo / course route débutante.
- `competitive` : pratique 5 à 6× / sem, volume hebdo soutenu, vise course route, gran fondo A-event ou cyclo-sportive 200+ km.

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

Convention v2 : préfixe `FTP-` pour zones puissance (référentiel Coggan), `Sweet-Spot` first-class, `RPE` en fallback (renforcement / cyclistes sans powermeter).

| Zone | % FTP | % FCmax | RPE | Description | Application |
|---|---|---|---|---|---|
| **FTP-Z1** (Recovery) | < 55% | < 68% | 1-2 | Active recovery, conversational facile | Récup post-intervalle, échauffement, cooldown |
| **FTP-Z2** (Endurance) | 56-75% | 69-83% | 2-3 | Conversational, base aérobie | Sortie longue, fond, endurance fondamentale |
| **FTP-Z3** (Tempo) | 76-90% | 84-94% | 3-4 | Comfortably hard | Tempo continu, sweet spot bas |
| **Sweet-Spot** | 88-94% | 92-97% | 3-4 | Optimum charge / temps | Bloc FasCat 30-90 min, intervalles longs |
| **FTP-Z4** (Threshold) | 91-105% | 95-105% | 4-5 | Lactate threshold, ~1h race effort | Intervalles 8-30 min × 2-4 reps |
| **FTP-Z5** (VO2max) | 106-120% | > 106% (peak court) | 6-7 | VO2max | 3-8 min × 4-6 reps, récup 1:1 |
| **FTP-Z6** (Anaerobic) | 121-150% | n/a | 8-10 | Anaérobie lactique | 30 sec - 2 min × 4-8 reps, récup 2-4× durée |
| **FTP-Z7** (Neuromuscular) | > 150% | n/a | 10 | Sprint | 5-15 sec, récup complète |

**Choix de doctrine** : on pace en **% FTP** par défaut (Coggan référentiel le plus établi en 2026). Pour cyclistes sans powermeter (`beginner`, `recreational` majorité), fournir équivalents `% FCmax` ET `RPE` dans `notes`. Sweet Spot promu en zone first-class car central en `recreational` / phase base `regular` (FasCat / TrainerRoad).

### Volume hebdo cible par niveau

**Convention volume cycling v2** : volume hebdo exprimé en **heures de pédalage pur** (effort sport-pur, hors warmup/cooldown courts < 10 min hors maison). Long ride exprimé en heures pour `beginner`/`recreational` (avec km cible indicatif), en heures **et** km pour `regular`/`competitive`.

| Niveau | Vol pic (h/sem pédalage) | Fréquence | Long ride max | Doctrine source |
|---|---|---|---|---|
| **beginner** | 3-5 h/sem | 2-3 sessions / sem | 60-90 min ou 25-35 km | British Cycling Beginner 6-8 hpw (avec marges débutant), TrainerRoad Low Volume |
| **recreational** | 6-8 h/sem | 3-4 sessions / sem | 2-3 h ou 60-80 km | British Cycling Sportive Beginner-Intermediate, FasCat Sweet Spot Basic 4-8 hpw |
| **regular** | 9-12 h/sem | 4-5 sessions / sem | 3-4 h ou 100-120 km | Friel 12wk Build-Peak 12 hpw, FasCat Sweet Spot Advanced 10-16 hpw |
| **competitive** | 13-16+ h/sem | 5-6 sessions / sem | 5-6 h ou 150-200 km | Friel Cyclist Training Bible Race phase, British Cycling Advanced |

### Périodisation cycling

#### Cycle de base (build / deload)
- **3 build + 1 deload** : standard pour `recreational` et `regular`. Volume deload = -15 à -20% du pic précédent.
- **2 build + 1 deload** : pour `competitive` (charge plus haute, récupération plus fréquente).
- **5-6 build + 1 cutback** : pour `beginner` (charge faible, adaptation lente, 1 cutback en milieu de plan suffit). Volume cutback `beginner` low-volume : -25 à -30% accepté car la charge absolue est faible.

#### Phases Friel
- **Base** : 12 sem, 80-90% du temps en Z1-Z2, sortie longue progressive, sweet spot introduit en Base 2-3.
- **Build** : 8-10 sem, 70% Z1-Z2 / 30% intensités spécifiques (Z3-Z4-Z5).
- **Peak** : 2-3 sem, simulations course / pré-A-event, volume -20% du Build pic.
- **Taper** (compétition) : 1-2 sem, volume -30 à -50% du Build pic, fréquence maintenue, intensités courtes conservées.

#### Tapering compétition (sportive longue, course route, gran fondo)
- **J-14** : volume à ~70% du pic.
- **J-7** : volume à ~50-60% du pic.
- **J-3 à J-1** : 2 sorties courtes 45-60 min en `FTP-Z2` + 2-3 sprints courts (5-10 sec) à J-2 (réveil neuromusculaire).
- **Fréquence maintenue** ≥ 80% des sessions habituelles (raccourcir, pas supprimer).

#### Distribution d'intensité (sweet spot vs polarized)

**Choix de doctrine motivé** :
- **`beginner`** : 100% Z1-Z2 (`FTP-Z2` majoritaire), pas d'intensité dure jusqu'à ce qu'une sortie 60 min en continu confortable soit acquise.
- **`recreational`** : **sweet-spot dominant** en bloc base (40-50% du volume sur sweet spot 88-94% FTP), 50-60% Z2. Pas de polarized strict (volume insuffisant pour absorber 80% LIT).
- **`regular`** : **polarized 80/20** en phase build (80% Z1-Z2, 20% Z4-Z5). Bloc sweet spot accepté en base seulement.
- **`competitive`** : **polarized 80/20** dominant. Semaines de spécificité (@FTP, blocs montagne, simulations course, gros bloc sweet spot pré-A-event) peuvent dériver vers 70-75% LIT / 25-30% HIT (polarized "souple"). **Annoncer un range 75-85% LIT** dans `progression_logic` et expliciter les semaines dérogatoires (sweet spot weeks, taper).

Justification : revue systématique 2024 (MDPI Sports) confirme polarized > threshold sur VO2max et économie cycliste entraîné. Étude Neal et al. 2013 (12 cyclistes) : polarized +8% peak power output vs +3% threshold sur 6 semaines. Mais sweet spot reste validé pour temps-limité (FasCat / TrainerRoad), où volume LIT total impossible à atteindre (`recreational` 6-8 hpw).

### Cadence cible

| Contexte | Cadence cible (rpm) | Application |
|---|---|---|
| Plat / endurance Z2 | 85-95 rpm | Sortie longue, fond, conversational |
| Sweet spot / FTP-Z3-Z4 | 85-95 rpm | Intervalles tempo, bloc sweet spot |
| Côte modérée (3-7%) | 75-85 rpm | Côtes longues, FTP-Z3-Z4 sur pente |
| Côte raide (> 8%) | 70-80 rpm | Préserver le genou, ne pas grinder < 65 rpm |
| Intervalles haute cadence | 100-110+ rpm | Drills réactivité, sprint train, neuromusculaire |
| Force / SFR (force-vitesse-réduite) | 50-60 rpm sur gros braquet | Hors-saison `regular`+ uniquement, à dose modérée (genou) |

**Règle débutant** : ne jamais grinder < 65 rpm, surtout en montée. Cadence basse + force élevée = risque genou. Cadence > 90 préservera le système musculaire au profit du cardio.

### Substitutions classiques (alternatives v2)

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

- **beginner** : core (planche ventrale, bird-dog), gainage dorsal, pont fessier bipodal, calf raises bipodal, étirements quadriceps + ischios + psoas (cycliste = hanches courtes) — 1 séance dédiée 1×/sem dès W1, 15-20 min.
- **recreational** : ajout single-leg squat, hip thrust léger, gainage latéral, étirements quadriceps + ischios + psoas approfondis, 1 séance strength + 1 mobilité / sem.
- **regular** : ajout deadlift roumain léger, step-up, drills proprio (single-leg balance), 1-2 séances strength / sem en hors-saison, 1 séance maintien en saison.
- **competitive** : pliométrie modérée hors-saison (box jumps, bondissements), squat / deadlift chargé hors-saison, 2 séances strength / sem hors-saison, 1 séance maintien en saison + drills techniques (sprint start, accélération out-of-saddle).

### Drapeaux rouges (safety)

#### Tous niveaux
- **Lombalgie cycliste** : 40-60% des cyclistes touchés. Cause n°1 = position de selle / cintre (reach trop long, selle trop haute / nez trop bas, hanches désalignées). Si douleur > 2 sorties consécutives → bike fit professionnel.
- **Douleur antérieure du genou** (genou cycliste) : selle trop basse / trop avancée, cale mal positionnée, cadence trop basse sur gros braquet. Vérifier hauteur selle (genou flexion 25-30° en bas du pédalage).
- **Douleur postérieure du genou** : selle trop haute. Diminuer 5-10 mm.
- **Hot foot / engourdissement avant-pied** : chaussures trop serrées, cales trop avancées, longue exposition sur grosse pente. Aérer aux arrêts, vérifier réglage cale.
- **Cervicalgie / shoulder strain** : reach trop long, cintre trop bas. Réduire stack ou allonger potence.
- **Sécurité trafic** : casque OBLIGATOIRE à chaque sortie, éclairages avant/arrière obligatoires en faible visibilité, fluo/réflexe en hiver. Ne jamais rouler sans casque (mention `safety_notes`).

#### Recreational et au-delà
- **Tendinite achille** sur SFR / cadence basse répétée, calf raises excentriques en prévention.
- **Syndrome compartimental** sur sortie chaleur intense + hydratation insuffisante (rare).
- **Saddle sores / chamois pressure** : crème chamois sortie > 90 min, cuissard quality, hygiène stricte.

#### Competitive
- **RED-S** (Relative Energy Deficiency in Sport) : déficit énergétique chronique, signaux : aménorrhée, baisse perf, fatigue chronique, immunité dégradée.
- **Surentraînement** : FC repos +10 bpm chronique, sommeil dégradé, motivation effondrée 3+ semaines, baisse FTP test consécutive.
- **Coup de chaleur** sur événement long été : hydratation salée 500-750 ml/h chaleur > 25°C, écouter signaux (céphalée, frissons, désorientation = STOP immédiat).

### Nutrition longue sortie (> 90 min)

- **60-90 g glucides/h** pour sortie > 90 min (ratio 2:1 glucose:fructose au-delà de 60 g/h).
- **Hydratation** : 500-750 ml/h en conditions tempérées, 750-1000 ml/h chaleur > 25°C, sodium 300-700 mg/L.
- **Avant** : 1-2 h avant départ, 30-60 g glucides + caféine optionnelle.
- **Après** : fenêtre 30 min, ratio glucides:protéines 3:1 ou 4:1, 1.0-1.2 g glucides/kg + 0.3 g protéines/kg.
- **Gut training** : si profil non habitué à 90 g/h, démarrer 30 g/h en sortie longue d'entraînement et progresser sur 4-6 semaines.

### Mots EU MDR à bannir (cycling spécifique)

Vocabulaire qui constituerait un acte médical en UE (Med Device Regulation 2017/745).

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
- `FTP-Z1`, `FTP-Z2`, `FTP-Z3`, `FTP-Z4`, `FTP-Z5`, `FTP-Z6`, `FTP-Z7`
- `Sweet-Spot` (zone first-class, 88-94% FTP)
- `RPE 4-5`, `RPE 6-7`, `RPE 7-8`, `RPE 8-9` (sans powermeter ou renforcement)
- `cadence-90rpm`, `cadence-100rpm`, `cadence-low-50-60rpm` (drills cadence dédiés)
- `walking-recovery` non applicable cycling — utiliser `FTP-Z1` pour récup active

#### `required_equipment`
Vocabulaire kebab-case :
- `helmet` : OBLIGATOIRE à toute sortie route / VTT / gravel — jamais omis.
- `road-bike`, `mtb`, `gravel-bike` : choisir selon contexte template (cycling route = `road-bike` par défaut).
- `indoor-trainer` ou `smart-trainer` : alternative météo / hiver / contrôle wattage (sweet spot, intervalles ERG).
- `power-meter` : optionnel `recreational`, recommandé `regular`+, attendu `competitive` pour pacing FTP.
- `heart-rate-monitor` : alternative ou complément power.
- `gps-watch` ou `bike-computer` : recommandé `recreational`+ pour structuration séances.
- `cycling-shoes`, `cleats` : assumé `recreational`+, optionnel `beginner` (plats acceptés).
- `bidons` (× 2 sortie > 90 min), `front-light`, `rear-light`, `reflective-vest` (sécurité).
- `mat`, `resistance-band`, `dumbbells` (renforcement à domicile).

#### `incompatible_constraints`
Vocabulaire kebab-case :
- `lower-back-pain`, `knee-injury`, `cervical-injury`, `shoulder-injury`, `wrist-injury` (carpal tunnel)
- `cardiac-clearance-required`, `pregnancy`, `postpartum-early`
- `no-bike` (flag de garde si profil mal renseigné — assomption faux pour template cycling)
- `no-trainer` (impacte alternative indoor)
- `no-power-meter` (impacte précision pacing FTP, fallback FC ou RPE requis)
- `outdoor-only` ou `indoor-only` (préférence trainer)
- `apartment-noise` (trainer indoor en immeuble — proposer alternative spinning silencieuse)
- `traffic-anxiety` (privilégier indoor / pistes cyclables / heures creuses)

#### `alternatives`
Liste de noms d'exercices substitutifs (cf. tableau Substitutions ci-dessus). Au minimum 1-2 alternatives réalistes par exercice. **`alternatives: []` vide non-toléré** (l'algo deterministic Story 3.3a en a besoin).

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

### Sources

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
