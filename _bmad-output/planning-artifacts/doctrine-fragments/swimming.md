# Doctrine SWIMMING — fragment Story 0.5.10

Référentiel public sourcé pour la regen des templates swimming Story 0.5.10 et l'algo deterministic local Story 3.3a.

**Last revised** : 2026-04-30.

**Statut** : Phase C — fragment swimming complet, prêt à intégrer dans `leon-algo-doctrine-by-sport.md` puis à consommer par `master-swimming.md`.

**Vocabulaire de niveau** (aligné enums Sport + Level Story 0.5.8) :
- `beginner` : aucune expérience récente ou non-nageur capable de mettre la tête sous l'eau ; vise 25-50 m enchaînés avec respiration latérale.
- `recreational` : pratique 1 à 2× / sem, capable d'enchaîner 200-400 m crawl, vise endurance confortable type 800-1500 m continus.
- `regular` : pratique 2 à 3× / sem depuis ≥ 1 an, capable d'enchaîner 1500 m, sait poser un test CSS, vise amélioration technique + endurance.
- `competitive` : pratique 3 à 5× / sem incl. dryland shoulder, volume hebdo 8-15+ km, prépare des compétitions FFN / Masters / triathlon longue distance.

---

## Doctrine référente

| Référence | Auteur | Application |
|---|---|---|
| **Swimming Fastest** (2003, anciennement *Swimming Even Faster* 1993) | Ernest W. Maglischo | Zones EN1/EN2/EN3 + SP1/SP2/SP3, lactate-based, référentiel scientifique mondial USA Swimming. |
| **Training Zones Revisited** (Maglischo, ASCA Vol. 20) | Ernest W. Maglischo | Mise à jour des zones, courbes vélocité-lactate, applications coach. |
| **Total Immersion** | Terry Laughlin | Hiérarchie pédagogique débutant : Balance → Streamlining → Propulsion → Synchronisation. Drills *focal point* progressifs. |
| **Swim Smooth** | Paul Newsome, Adam Young | Test CSS standardisé (400 m + 200 m), 4 swim types (Bambino, Kicktastic, Arnie, Smooth, Overglider, Swinger), plans par CSS. |
| **80/20 Endurance — Swim** | Matt Fitzgerald, David Warden / Stephen Seiler | Distribution polarisée transposée swimming via test 400+200 (LT pace), 7 zones (1, 2, X, 3, Y, 4, 5). |
| **USA Swimming Energy Zones** | USA Swimming / ASCA | Système 7 zones (REC, EN1, EN2, EN3, SP1, SP2, SP3) basé Maglischo, standard ASCA. |
| **Swim England Learn to Swim Framework** | Swim England (ex-ASA) | Stages 1-10, référence absolue progression débutant adulte UK. |

Sources :
- [Training Zones Revisited — Maglischo PDF (ASCA)](https://cdn.ymaws.com/swimmingcoach.org/resource/resmgr/swimresearch/manuscript-maglischo-vol20.pdf)
- [Coaching Applications Training Zones Revisited — Maglischo PDF (ASCA)](https://cdn.ymaws.com/swimmingcoach.org/resource/resmgr/swimresearch/coaching-app-maglischo-vol20.pdf)
- [Energy Zones in Swimming — GoMotion PDF](https://www.gomotionapp.com/akwwsc/UserFiles/File/Energy%20Zones%20in%20Swimming.pdf)
- [Training zones in competitive swimming: a biophysical approach — PMC NIH](https://pmc.ncbi.nlm.nih.gov/articles/PMC10982397/)
- [Total Immersion Primer — Stroke Drills](https://www.totalimmersion.net/blog/total-immersion-primer-stroke-drills/)
- [Swim Optimization: Beyond Balance, Streamline, Propulsion — Total Immersion](https://www.totalimmersion.net/blog/swim-optimization-beyond-balance-streamline-propulsion/)
- [The CSS Test Explained — Swim Smooth](https://blog.swimsmooth.com/p/the-css-test-explained)
- [CSS Training — Swim Smooth Intermediate](https://www.swimsmooth.com/improve/intermediate/css-training)
- [Mastering Intensity Guidelines for 80/20 Triathlon Swim](https://www.8020endurance.com/intensity-guidelines-for-swimming/)
- [Swim England Learn to Swim Awards 1-7](https://www.swimming.org/learntoswim/swim-england-learn-to-swim-awards-1-7/)
- [Swim England Learn to Swim Awards 8-10](https://www.swimming.org/learntoswim/swim-england-learn-to-swim-awards-8-10/)

---

## Zones d'effort (target_zone)

Convention v2 swimming : ancrage **CSS (Critical Swim Speed)** pour `regular`+ (calculable via test 400 m + 200 m), **EN1/EN2/EN3 / SP1/SP2/SP3** par référence Maglischo, **technique** pour les drills purs sans cible cardio (focus moteur), **RPE 6-9** pour le renforcement préventif (dryland).

| Zone | Repère pace / FC | RPE | Description | Application |
|---|---|---|---|---|
| **REC** (Recovery) | CSS + 15-20 s/100m, FC < 65% FCmax | 1-2 | Récupération active, échauffement prolongé | Premier 200-400 m de chaque séance, retour au calme, jour de récup |
| **EN1** (Endurance 1, aérobie low) | CSS + 8-12 s/100m, FC 65-75% FCmax | 3-4 | Aérobie de base, conversational | Volume long, drills longs, récup entre intervalles longs |
| **EN2** (Endurance 2, aérobie threshold) | CSS ± 0-3 s/100m, FC 75-82% FCmax | 5-6 | Seuil aérobie, "comfortably hard" 30-50 min | Cœur de l'entraînement endurance, séries 200-400 m |
| **EN3** (Endurance 3, VO2max) | CSS - 5 à -10 s/100m, FC 85-92% FCmax | 7-8 | Proche VO2max, soutenable 6-12 min en série | Séries courtes 100-200 m, intensité haute |
| **SP1** (Sprint 1, lactate tolerance) | Allure 200 m race, FC > 90% FCmax | 8-9 | Tolérance lactique, max 1-2 min effort | 50-100 m × 4-8 reps, récup longue (3-4×) |
| **SP2** (Sprint 2, lactate production) | Allure 100 m race | 9 | Production lactique max | 25-50 m × 6-12 reps, récup quasi complète |
| **SP3** (Sprint 3, neuromusculaire / vitesse pure) | Vitesse max | 10 | Sprint anaérobie alactique | 12.5-25 m × 8-16 reps, récup complète |
| **CSS+5s/100m** | Pace cible explicite | — | Allure tempo / EN1-EN2 mid | Séries continues 400-1500 m |
| **CSS-2s/100m** | Pace cible explicite | — | EN2 haute / EN3 basse | Cruise intervals 4-8 × 200 m, récup courte |
| **CSS pace** | Pace cible explicite | — | Threshold pur, ~30-60 min sustained race effort | Tempo 800-1500 m continus, sets 6-10 × 100 m |
| **technique** | Pas de zone effort | 3-5 | Drills techniques, cognitive load > effort | Drills équilibre, catch, timing, respiration |
| **RPE 6-7** / **RPE 7-8** | Effort perçu | 6-8 | Renforcement musculaire dryland | Y-T-W, external rotation, scapular work |

**Choix de doctrine** : on pace en **CSS pour `regular` et `competitive`** (testable au pool, pas besoin de cardio en eau), et en **EN1/EN2 par feeling test-de-la-parole** + temps de longueur indicatif pour `recreational`. Pour `beginner`, **pas de zone effort** : seulement `technique` et REC, focus moteur (motor learning > volume aérobie) — la zone FC n'a pas de sens tant que le patron moteur n'est pas stabilisé.

Sources : [Simple CSS Calculator — MyProCoach](https://www.myprocoach.net/calculators/critical-swim-speed/), [Critical Swim Speed Calculator — Top End Sports](https://www.topendsports.com/testing/tests/critical-swim-speed.htm), [How To Find Your Critical Swim Speed — Liquid Tri](https://www.liquidtri.com/css-swim-pace-calculator), [Acadian Endurance — Set Types EN1/EN2/EN3 SP](http://acadianendurance.blogspot.com/2010/02/set-types.html), [Training Zones — Be Water Training](https://bewatertraining.com/en/c/critical-swim-speed-css/).

---

## Volume hebdo cible par niveau

**Convention volume swimming v2** : volume hebdo exprimé en **mètres de nage pure** (sport-pur, hors warmup/cooldown courts < 200 m chacun et hors dryland). Long set ou volume continu exprimé en mètres. Une séance débutant peut être exprimée en **durée** (`volume_axis: duration`) si le débutant ne sait pas encore enchaîner 25 m sans pause — le nombre de longueurs effectives est insuffisant pour un cible métrique fiable.

| Niveau | Vol pic (m/sem) | Fréquence | Long set max | Doctrine source |
|---|---|---|---|---|
| **beginner** | 600-1500 m/sem (≈ 30-50 min eau) | 2-3 sessions / sem (idéal 3 pour motor learning) | 200-400 m fractionnés (8 × 25 m → 4 × 50 m) | Swim England Stage 5-7 / Total Immersion progression drills |
| **recreational** | 2500-4500 m/sem | 2-3 sessions / sem | 800-1200 m continu | Swim Smooth Improver / 80/20 Triathlon Sprint |
| **regular** | 5000-9000 m/sem | 3-4 sessions / sem | 1500-2500 m continu | Swim Smooth CSS Development 10-week / 80/20 Triathlon Olympic |
| **competitive** | 10000-20000+ m/sem (jusqu'à 25-30 km en bloc base age-group adulte) | 4-6 sessions / sem + 2 dryland | 3000-5000 m continu | Maglischo Swimming Fastest / USA Swimming age-group |

Sources : [Swim Smooth 10 Week CSS Development Plan](https://blog.swimsmooth.com/p/challenge-yourself-with-our-2024), [Training volume for age groupers — USMS](https://community.usms.org/swimming/f/general/7095/training-volume-for-age-groupers), [How To Build A Yearly Training Plan — MySwimPro](https://blog.myswimpro.com/2016/02/12/how-to-build-a-yearly-training-plan/), [Periodization and Programming for Individual 400 m Medley Swimmers — PMC NIH](https://pmc.ncbi.nlm.nih.gov/articles/PMC8296310/).

---

## Périodisation

### Cycle de base (build / deload)
- **3 semaines build + 1 deload** : standard pour `recreational` et `regular`. Volume deload = -15 à -20% du pic précédent.
- **2 build + 1 deload** : pour `competitive` (charge plus haute, récupération plus fréquente).
- **5-6 build + 1 cutback** : pour `beginner`. Cutback `beginner` = -20 à -30% (cognitif autant que physique : moins de longueurs, plus de drills focal point).

### Phases swimming (transposition Friel/Maglischo)
- **Base** (4-8 sem) : 70-85% du temps en EN1-EN2, focus volume aérobie + technique. Drills 30-50% du volume `recreational`, 20-30% `regular`.
- **Build** (4-6 sem) : intro EN3 + SP1 par paliers 5-10% volume hebdo, threshold (CSS) prioritaire.
- **Peak / Race-pace** (2-3 sem) : SP2 + SP3 introduits, simulations distance compétition.
- **Taper** (1-2 sem) : volume -30 à -50% du pic, fréquence maintenue, intensités courtes conservées (12.5-25 m sprints), drills prioritaires.

### Tapering compétition (FFN, Masters, triathlon)
- **J-14** : volume à ~70% du pic.
- **J-7** : volume à ~50-60% du pic.
- **J-3 à J-1** : 1-2 séances courtes 1500-2000 m avec 4-6 × 25 m vitesse libre (réveil neuromusculaire).
- **Fréquence maintenue** ≥ 80% des sessions.

### Distribution d'intensité
**Choix de doctrine** :
- **`beginner`** : 100% REC + technique (pas de zone aérobie ciblée). Le but = stabiliser le patron moteur, pas développer le V̇O2.
- **`recreational`** : 70% EN1-EN2 / 20% technique drills / 10% EN3 max. Pas de SP. Volume insuffisant pour absorber 80/20 strict, mais l'esprit polarized est respecté.
- **`regular`** : **polarized 80/20** : 80% EN1-EN2 (CSS+5 à +12 s) / 20% EN3-SP1 (CSS-5 à CSS-10). Bloc tempo CSS accepté en base.
- **`competitive`** : **polarized 80/20**, mais semaines de spécificité (race-pace) peuvent dériver vers 70/10/20 (HIT élevé). Drills ≥ 10-15% du volume même en peak (économie de nage).

Justification : revue systématique 2024 (MDPI Sports) confirme polarized > threshold en endurance entraînée. En swimming, la composante technique reste majoritaire — un nageur amateur progresse plus en réduisant la traînée qu'en augmentant la VO2max.

Sources : [Polarized Training VO2max Systematic Review 2024 — PMC NIH](https://pmc.ncbi.nlm.nih.gov/articles/PMC11679080/), [80/20 Endurance Intensity Guidelines for Swimming](https://www.8020endurance.com/intensity-guidelines-for-swimming/), [Periodization 400 m Medley Swimmers — PMC NIH](https://pmc.ncbi.nlm.nih.gov/articles/PMC8296310/).

---

## Drills — hiérarchie pédagogique (Total Immersion + Maglischo)

Convention CoachingSage : les drills sont **par objectif** (équilibre / catch / timing / respiration / propulsion) et **séquencés par niveau**. Un débutant ne doit JAMAIS travailler un drill catch (haut elbow underwater) avant que le drill équilibre soit acquis — la chaîne pédagogique Total Immersion est strictement séquentielle.

### Hiérarchie séquentielle (à respecter par niveau)

1. **Équilibre** (priorité `beginner` W1-W3) :
   - *Superman glide* / planche de glisse 5-10 m apnée, bras tendus.
   - *Side kick* (côté favori d'abord, bilatéral W3+) : nage sur le côté, bras inférieur tendu, regard fond.
   - *Body roll* / 6-3-6 (nage 6 kicks sur côté → 3 strokes → 6 kicks autre côté).
   - Objectif : trouver la flottaison équilibrée, hanches hautes, tête neutre.

2. **Streamlining / glide** (priorité `beginner` W3-W5, maintenu tous niveaux) :
   - *Streamline push-off* après virage : main sur main, bras serrés contre tête.
   - Tenir 5 m glisse minimum après chaque push-off.

3. **Catch + propulsion** (priorité `recreational` W3+, `regular` permanent) :
   - *Fingertip drag* : doigts effleurent l'eau pendant le retour bras (high elbow recovery).
   - *Catch-up* : un bras devant, l'autre nage et "rattrape" — apprend la pleine extension et le rythme.
   - *Single arm* (bras non-dominant, avancé) : bras passif tendu, l'autre nage seul → renforce le côté faible.
   - *Sculling* (mains seules, propulsion par la prise d'appui sur l'eau, sans coup de bras complet).

4. **Timing / synchronisation** (priorité `recreational` → `competitive`) :
   - 6-3-6 (pivote vers timing après équilibre acquis).
   - *Pull-buoy isolation* : focus traction bras pure, jambes neutralisées par la bouée.
   - *Tempo trainer* (`competitive` uniquement) : drill avec métronome pour caler le tempo (Strokes Per Minute).

5. **Respiration** (intégrée à toutes les phases mais avec règle de timing critique) :
   - **`beginner` W1-W3** : respiration UNIQUEMENT du côté favori, 1 fois tous les 2 strokes (rythme stable). NE PAS introduire bilatérale avant W3-W4 minimum (cognitive overload : équilibre + propulsion + alternance respiration = 3 nouveautés simultanées = rejet).
   - **`beginner` W4-W6** : intro douce respiration bilatérale par drills isolés (kickboard breathing 3/3/3, body roll), pas en nage continue.
   - **`recreational`+** : bilatérale standard (1/3 ou 1/5) sur volume EN1-EN2.
   - *Drill bilateral* : 3-3-3 (3 strokes côté gauche, 3 strokes côté droit).
   - *CO2 tolerance* (`competitive` uniquement, encadré) : breathing 1/5, 1/7 sur séries courtes.

### Ratio drills / volume par niveau

| Niveau | % drills sur volume hebdo | Format type |
|---|---|---|
| **beginner** | 60-80% | Sessions composées à 70%+ de drills, 20-30% nage continue très courte (8-12 × 25 m) |
| **recreational** | 25-40% | Échauffement 400-600 m drills + nage 1500-2500 m + 200 m récup drills |
| **regular** | 15-25% | Échauffement 300-500 m drills + main set + récup drills |
| **competitive** | 10-15% (hors taper) → 25% en taper | Drills focalisés sur point faible + technique sets |

**Règle motor learning** : pour `beginner`, **fréquence ≥ 2×/sem (idéal 3)** est plus importante que la durée par session. Le moteur cognitif se stabilise par répétitions courtes et fréquentes (recommandation USA Swimming + Swim England Learn to Swim Framework Stage 5-7), pas par sessions longues isolées.

Sources : [A Total Immersion Primer: The Why and How of Stroke Drills](https://www.totalimmersion.net/blog/total-immersion-primer-stroke-drills/), [Lesson 6 – Synchronize The Whole Body — Total Immersion](https://www.totalimmersion.net/blog/total-immersion-propulsion/), [Total Immersion Self-Coaching: Balance](https://www.totalimmersion.net/blog/total-immersion-balance/), [How to Practice: Terry's Mini-Skill Focal Point Progression](https://www.totalimmersion.net/blog/practice-use-mini-skill-focal-points-progress-drills-whole-stroke/), [Bilateral Breathing: how to learn it — SwimGym](https://swimgym.com/fast-lane/bilateral-breathing-how-to-learn-it), [Freestyle Breathing — USMS](https://www.usms.org/fitness-and-training/guides/freestyle/breathing), [6 Proven Drills to Improve Freestyle — THEMAGIC5](https://themagic5.com/blogs/news/6-proven-drills-to-improve-your-freestyle-stroke), [Catch-Up Drill — Swimming World](https://www.swimmingworldmagazine.com/news/swim-drill-of-the-week-catch-up-drill/).

---

## Renforcement préventif (par niveau) — focus épaule

Hooks v2 : exercices marqués `volume_axis: reps` ou `sets`, à inclure dès W1 pour `recreational`+. Pour `beginner`, dryland intégré 1×/sem dès W3 (pas W1 — laisser le temps cognitif).

### Doctrine "swimmer's shoulder" — 40-91% des nageurs touchés au moins 1 fois

Causes principales : déséquilibres internes/externes (sur-développement rotateurs internes — pectoral, lat — vs sous-développement rotateurs externes), instabilité scapulaire, volume excessif, technique défaillante (entrée main droppée, traction épaule pure sans rotation tronc).

### Programme préventif obligatoire (toutes séances dryland)

- **Y-T-W shoulder activation** (3 × 10 reps par lettre) : activation manchette rotateurs + trapèze moyen/inférieur. Allongé ventre sur banc ou sol, lever bras en Y puis T puis W, pouces vers le haut.
- **External rotation band** (3 × 12-15 reps/côté) : élastique attaché à hauteur coude, coude à 90° collé au tronc, rotation externe lente. Cible infraspinatus + teres minor.
- **Scapula retraction / rétraction omoplates** (3 × 12 reps) : élastique horizontal ou rame haute, ramener omoplates ensemble sans hausser épaules.
- **Serratus push-up plus** (3 × 10 reps) : push-up classique, en haut pousser plus loin pour décoller les omoplates (serratus anterior).
- **Mobilité thoracique** : cat-cow 10 reps + thoracic extension foam roller 8-10 extensions. La cyphose dorsale = facteur n°1 d'impingement épaule.
- **Pas de bench press lourd / dips profonds** : compriment l'espace sous-acromial. À bannir hors-saison `competitive` strict.

### Par niveau

- **beginner** : Y-T-W + external rotation + cat-cow, 1×/sem dès W3, 12-15 min.
- **recreational** : ajout scapula retraction + serratus + pectoraux stretch (porte de cadre 30 s/côté), 1-2×/sem.
- **regular** : ajout face pulls élastique, prone trap raises, 2 séances dryland / sem, dont 1 avant entraînement (activation) et 1 après (renforcement).
- **competitive** : ajout pull-up + horizontal row poids du corps, deadlift léger hors-saison (chaîne postérieure), 2-3 séances dryland / sem, suivi par physio en cas de douleur naissante.

Sources : [Effect of Preventive Exercise Programs for Swimmer's Shoulder — PMC NIH 2024](https://pmc.ncbi.nlm.nih.gov/articles/PMC11899141/), [Prevention and Treatment of Swimmer's Shoulder — PMC NIH](https://pmc.ncbi.nlm.nih.gov/articles/PMC2953356/), [Best Swimmer's Shoulder Exercises — APM Rehab](https://www.apmrehab.com/best-swimmers-shoulder-exercises-for-strength-and-recovery), [5 Exercises to Prevent Swimmer's Shoulder — Vasa Trainer](https://vasatrainer.com/blog/5-exercises-to-strengthen-your-shoulders-and-prevent-swimmers-shoulder/), [Build Shoulders of Steel — SwimSwam](https://swimswam.com/build-shoulders-of-steel-how-to-prevent-swimmers-shoulder/), [Top 5 Shoulder Exercises for Young Swimmers — PT Evolve](https://ptevolve.com/top-5-shoulder-exercises-for-young-swimmers-performance-and-injury-prevention/).

---

## Substitutions classiques (alternatives v2)

Documenté au niveau `exercise.alternatives[]` dans le template. `alternatives: []` vide non-toléré.

| Exercice planifié | Substitution | Trigger |
|---|---|---|
| Drill avec pull-buoy | Drill équivalent sans pull-buoy + ceinture flottante OU jambes neutres ankle band | Pas de pull-buoy disponible |
| Drill avec kickboard | Side kick sans planche bras tendu OU planche maintenue par appui mural | Pas de kickboard |
| Drill avec fins/palmes | Drill sans palmes (allure réduite, focus position) | Pas de palmes ou contre-indication mollet |
| Drill avec paddles | Drill sans paddles ou *sculling* mains seules | Pas de paddles ou douleur épaule |
| Sortie longue continue | 2 × 750 m avec récup 1 min | Bassin 25 m bondé / pas la concentration |
| EN3 / SP1 (intensité haute) | Tempo continu CSS+5s/100m | Fatigue accumulée, sommeil dégradé |
| Respiration bilatérale | Respiration côté favori avec rotation tronc consciente | Inconfort respiratoire débutant W1-W3 |
| Séance piscine | Vélo Z2 1:1 ratio temps OU course Z1-Z2 OU rameur | Pas d'accès piscine, otite, allergie chlore |
| Bench press | Push-up genoux ou complet (selon niveau) | Toujours pour swimming — bench press banni |

---

## Drapeaux rouges (safety)

### Tous niveaux
- **Swimmer's shoulder** (impingement sous-acromial) : douleur antéro-latérale épaule, déclenchée par le retour bras hors de l'eau ou la phase de catch underwater. Stop nage 5-7 jours, glace 15 min × 2/jour, programme préventif strict W1+ obligatoire (jamais sauter Y-T-W). Cause : volume monté trop vite, déséquilibre interne/externe, technique entrée main droppée. Avis kinésithérapeute si > 7 jours.
- **Otite externe** (swimmer's ear) : douleur conduit auditif, sensation oreille bouchée. STOP eau 7-10 jours, gouttes blanches (vinaigre + alcool 50/50, 3-4 gouttes après chaque baignade en prévention). Vérifier que l'eau s'écoule bien après séance (incliner tête, sécher serviette propre).
- **Cervicalgie** : tension nuque sur respiration unilatérale soutenue. Travailler bilatérale + rotation tronc complète + relâchement nuque sur expir.
- **Crampe mollet / pied** : commune avec palmes ou eau froide. Stretch doux contre rebord, hydratation + sodium si > 60 min eau. Si récurrente : avis médical (carence Mg, K).

### Recreational et au-delà
- **Lombalgie** : sur ondulation papillon ou body position négligée (hanches basses → cambrure). Renforcement core (planche ventrale, dead bug) + drills équilibre.
- **Douleur poignet** : sur paddles trop grandes ou phase de catch agressive. Réduire taille paddles, vérifier alignement coude-main.

### Competitive
- **RED-S** (Relative Energy Deficiency in Sport) : déficit énergétique chronique, signaux : aménorrhée, baisse perf, fatigue chronique, immunité dégradée. Charge swimming `competitive` régulière à risque (sport esthétique avec pression poids).
- **Surentraînement** : FC repos +10 bpm chronique, sommeil dégradé, sensation "lourdeur" persistante en eau, baisse 2-3% sur test CSS consécutif.
- **Asthme bronchique chlore-induit** : nageur compétitif sur-exposé chlore (irritation chronique voies respiratoires). Si dyspnée d'effort répétée : avis pneumologue, switch piscine ozonée ou eau salée si possible.

Sources : [Swimmer's Ear (Otitis Externa) — Cleveland Clinic](https://my.clevelandclinic.org/health/diseases/8381-swimmers-ear-otitis-externa), [Chlorinated Water and Swimmer ENT Health — ENT Soc Canada](https://entsoc.ca/2025/08/chlorinated-water-and-swimmer-ent-health-effects-prevention/), [Swimmer's Ear — Mayo Clinic](https://www.mayoclinic.org/diseases-conditions/swimmers-ear/symptoms-causes/syc-20351682).

---

## Mots EU MDR à bannir (swimming spécifique)

Le master prompt exclut le vocabulaire qui constituerait un acte médical en UE (Med Device Regulation 2017/745).

**Bannis dans tout texte généré** :
- "soigner [pathologie]", "traitement [pathologie]", "guérir", "remède"
- "rééducation post-opératoire", "post-blessure"
- "cure", "thérapie", "diagnostic", "prescription", "ordonnance"
- "soulager [douleur]" (préférer : "réduire l'inconfort", "favoriser le confort")
- "réparer l'épaule" (préférer : "renforcer", "stabiliser")

**Triggers medical clearance obligatoire** (mention "Consulte un médecin avant de commencer ce programme") :
- Antécédents cardiaques connus (`cardiac-clearance-required`).
- Grossesse (`pregnancy`) — natation Z2 généralement bénéfique mais avis médical de principe.
- Pathologie chronique épaule connue (déchirure coiffe partielle, capsulite, instabilité gléno-humérale).
- Otite externe répétée (3+ épisodes / 12 mois) → avis ORL avant reprise volume.
- Insuffisance respiratoire / asthme sévère → avis pneumologue (effort continu apnée intermittente = stress respiratoire).
- Reprise post-chirurgie épaule, dos, genou (< 6 mois).
- Profil > 50 ans débutant complet ou > 60 ans tous niveaux sans test effort récent.

---

## Hooks metadata standards (swimming)

### `target_zone`
Valeurs autorisées :
- `REC`, `EN1`, `EN2`, `EN3`, `SP1`, `SP2`, `SP3` (zones Maglischo / USA Swimming)
- `CSS+5s/100m`, `CSS-2s/100m`, `CSS pace` (paces explicites Swim Smooth)
- `technique` (drills purs sans cible cardio)
- `RPE 6-7` / `RPE 7-8` (renforcement dryland)
- `walking-recovery` non applicable swimming — utiliser `REC` ou `technique`

### `required_equipment`
Vocabulaire kebab-case :
- `pool` : OBLIGATOIRE pour toute séance swimming — assumé partout. Préciser si bassin 25 m vs 50 m importe rarement (templates compatibles 25 m par défaut).
- `goggles` : assumé partout (omettre OK).
- `swim-cap` : recommandé `recreational`+ pour hygiène + hydrodynamisme.
- `pull-buoy` : drills isolation bras, fréquent `recreational`+.
- `kickboard` : drills jambes, `beginner`+.
- `fins` (palmes courtes type Zoomers) : drills body position, vitesse, soulage débutants. Optionnel `recreational`+.
- `swim-paddles` : drills traction, force-water, `regular`+ uniquement (risque épaule débutant).
- `snorkel` (snorkel central) : drills isolation respiration vs body position, optionnel `recreational`+.
- `chronometer-or-watch` (montre étanche ou pace clock) : recommandé `recreational`+, requis `regular`+ pour test CSS.
- `tempo-trainer` (Finis Tempo Trainer Pro) : optionnel `competitive` uniquement.
- `mat`, `resistance-band`, `bench` : pour dryland.

### `incompatible_constraints`
Vocabulaire kebab-case :
- `shoulder-injury` : impacte tous drills paddles, traction lourde, papillon.
- `lower-back-pain` : impacte papillon, ondulation, hanches négligées.
- `wrist-pain` / `wrist-injury` : impacte paddles, push-off mur agressif.
- `knee-injury` : impacte brasse principalement (rotation genou).
- `cardiac-clearance-required`, `pregnancy`, `postpartum-early`
- `no-pool-access` : flag de garde si profil mal renseigné — alternatives cross-training requis.
- `chlorine-allergy` ou `recurrent-otitis` : suggérer piscine eau salée ou plein air.

### `alternatives`
Liste de noms d'exercices substitutifs (cf. tableau Substitutions). Au minimum 1-2 alternatives réalistes par exercice. `alternatives: []` vide non-toléré.

### `volume_axis`
- `distance` (par défaut swimming : mètres nagés, "8 × 50 m EN2 récup 15 s")
- `duration` (séances `beginner` qui ne tiennent pas une métrique fiable, ou drills timés)
- `sets` (séries structurées : `sets: 4` × `distance: "200 m EN2"`)
- `reps` (renforcement dryland : Y-T-W, scapula retraction)

---

## `week_structure` typique par niveau

| Niveau | type | micro_pattern | recovery_cadence |
|---|---|---|---|
| **beginner** | `linear` | `technique drills + breath progression + dryland` (2-3 sessions, 1 dryland intégré W3+) | `1 cutback W4 ou W5 sur plan 6 sem` |
| **recreational** | `linear` | `endurance EN1-EN2 + drills + long swim continu` | `1 deload toutes les 4 semaines` |
| **regular** | `block` | `endurance EN1 + threshold CSS + drills + EN3 + long swim` | `1 deload toutes les 3-4 semaines` |
| **competitive** | `polarized` | `recovery REC + EN1 long + threshold CSS + EN3/SP1 + drills + race-pace + dryland` | `1 deload toutes les 2-3 semaines` |

`deload_weeks` exemples :
- Plan 6 sem `beginner` : `[4]` (cutback en milieu, dernière sem = consolidation 25 m enchaînés)
- Plan 8 sem `recreational` : `[4]` ou `[4, 7]` (taper avant séance phare)
- Plan 8 sem `regular` : `[4]`
- Plan 12 sem `competitive` : `[4, 8, 11]` (taper W11 avant compétition W12)

---

## Sources swimming complètes

### Doctrine Maglischo & USA Swimming
- [Training Zones Revisited — Maglischo PDF (ASCA)](https://cdn.ymaws.com/swimmingcoach.org/resource/resmgr/swimresearch/manuscript-maglischo-vol20.pdf)
- [Coaching Applications Training Zones — Maglischo PDF (ASCA)](https://cdn.ymaws.com/swimmingcoach.org/resource/resmgr/swimresearch/coaching-app-maglischo-vol20.pdf)
- [Energy Zones in Swimming — GoMotion PDF](https://www.gomotionapp.com/akwwsc/UserFiles/File/Energy%20Zones%20in%20Swimming.pdf)
- [Energy Zones, training workloads — Estonia Swimming Federation PDF](https://www.swimming.ee/failid/918.pdf)
- [Swimming World Coach's Guide to Energy Systems](https://www.swimmingworldmagazine.com/news/swimming-world-presents-a-coachs-guide-to-energy-systems/)
- [Training zones in competitive swimming biophysical — PMC NIH](https://pmc.ncbi.nlm.nih.gov/articles/PMC10982397/)
- [Acadian Endurance — Set Types EN1/EN2/EN3 SP](http://acadianendurance.blogspot.com/2010/02/set-types.html)

### Swim Smooth & CSS
- [The CSS Test Explained — Swim Smooth Blog](https://blog.swimsmooth.com/p/the-css-test-explained)
- [CSS Training — Swim Smooth Intermediate](https://www.swimsmooth.com/improve/intermediate/css-training)
- [Swim Smooth 10-Week CSS Development Plan 2024](https://blog.swimsmooth.com/p/challenge-yourself-with-our-2024)
- [Swim Smooth GURU CSS Calculator](https://www.swimsmooth.guru/css/calcsingle)
- [How to Use Critical Swim Speed Training — TrainingPeaks](https://www.trainingpeaks.com/blog/how-to-use-critical-swim-speed-training/)
- [Simple CSS Calculator — MyProCoach](https://www.myprocoach.net/calculators/critical-swim-speed/)
- [Critical Swim Speed Calculator — Top End Sports](https://www.topendsports.com/testing/tests/critical-swim-speed.htm)
- [How To Find Your Critical Swim Speed — Liquid Tri](https://www.liquidtri.com/css-swim-pace-calculator)
- [Be Water Training — CSS](https://bewatertraining.com/en/c/critical-swim-speed-css/)

### Total Immersion (drills + pédagogie débutant)
- [Total Immersion Primer: Why and How of Stroke Drills](https://www.totalimmersion.net/blog/total-immersion-primer-stroke-drills/)
- [Swim Optimization: Beyond Balance, Streamline, Propulsion](https://www.totalimmersion.net/blog/swim-optimization-beyond-balance-streamline-propulsion/)
- [Total Immersion Self-Coaching: Balance](https://www.totalimmersion.net/blog/total-immersion-balance/)
- [Lesson 6 – Synchronize The Whole Body](https://www.totalimmersion.net/blog/total-immersion-propulsion/)
- [How to Practice: Terry's Mini-Skill Focal Points Progression](https://www.totalimmersion.net/blog/practice-use-mini-skill-focal-points-progress-drills-whole-stroke/)

### Drills techniques + breathing
- [Freestyle Breathing — USMS](https://www.usms.org/fitness-and-training/guides/freestyle/breathing)
- [Bilateral Breathing: how to learn it — SwimGym](https://swimgym.com/fast-lane/bilateral-breathing-how-to-learn-it)
- [Drills That'll Help You Build Your Lung Strength — USMS](https://www.usms.org/fitness-and-training/articles-and-videos/articles/drills-thatll-help-you-build-your-lung-strength-and-improve-your-freestyle-breathing-pattern)
- [6 Proven Drills to Improve Your Freestyle Stroke — THEMAGIC5](https://themagic5.com/blogs/news/6-proven-drills-to-improve-your-freestyle-stroke)
- [Catch-Up Drill — Swimming World](https://www.swimmingworldmagazine.com/news/swim-drill-of-the-week-catch-up-drill/)
- [5 Freestyle Drills for Beginner Swimmers — MySwimPro](https://support.myswimpro.com/en/articles/6350502-5-freestyle-drills-for-beginner-swimmers)

### Swim England / British Swimming progression
- [Swim England Learn to Swim Awards 1-7](https://www.swimming.org/learntoswim/swim-england-learn-to-swim-awards-1-7/)
- [Swim England Learn to Swim Awards 8-10](https://www.swimming.org/learntoswim/swim-england-learn-to-swim-awards-8-10/)
- [Swim England Learn to Swim Framework — GoggleSquad](https://www.gogglesquad.co.uk/about-us/swim-programme/learn-to-swim-framework)

### Polarized 80/20 swimming
- [80/20 Endurance Intensity Guidelines for Swimming](https://www.8020endurance.com/intensity-guidelines-for-swimming/)
- [Mastering Intensity Guidelines for 80/20 Triathlon](https://www.8020endurance.com/intensity-guidelines-for-8020-triathlon/)
- [Polarized Training VO2max Systematic Review 2024 — PMC NIH](https://pmc.ncbi.nlm.nih.gov/articles/PMC11679080/)

### Périodisation + plans
- [Periodization and Programming for 400 m Medley Swimmers — PMC NIH](https://pmc.ncbi.nlm.nih.gov/articles/PMC8296310/)
- [Types of Training Periodization — Science of Swimming](https://www.e.swimsci.net/2023/01/types-of-training-periodization.html)
- [How To Build A Yearly Training Plan — MySwimPro Blog](https://blog.myswimpro.com/2016/02/12/how-to-build-a-yearly-training-plan/)
- [Jill Sterkel's Periodisation for Swimmers — Coach Ray](https://www.coachray.nz/2021/11/15/jill-sterkels-periodisation-for-swimmers/)
- [How to Build a Winning Swimming Training Plan — TritonWear](https://blog.tritonwear.com/how-to-build-a-winning-swim-training-plan)

### Prévention swimmer's shoulder + ENT
- [Effect of Preventive Exercise Programs for Swimmer's Shoulder — PMC NIH 2024](https://pmc.ncbi.nlm.nih.gov/articles/PMC11899141/)
- [Prevention and Treatment of Swimmer's Shoulder — PMC NIH](https://pmc.ncbi.nlm.nih.gov/articles/PMC2953356/)
- [Best Swimmer's Shoulder Exercises — APM Rehab](https://www.apmrehab.com/best-swimmers-shoulder-exercises-for-strength-and-recovery)
- [Build Shoulders of Steel: Prevent Swimmer's Shoulder — SwimSwam](https://swimswam.com/build-shoulders-of-steel-how-to-prevent-swimmers-shoulder/)
- [Top 5 Shoulder Exercises for Young Swimmers — PT Evolve](https://ptevolve.com/top-5-shoulder-exercises-for-young-swimmers-performance-and-injury-prevention/)
- [5 Exercises to Prevent Swimmer's Shoulder — Vasa Trainer](https://vasatrainer.com/blog/5-exercises-to-strengthen-your-shoulders-and-prevent-swimmers-shoulder/)
- [Swimmer's Ear (Otitis Externa) — Cleveland Clinic](https://my.clevelandclinic.org/health/diseases/8381-swimmers-ear-otitis-externa)
- [Chlorinated Water and Swimmer ENT Health — ENT Soc Canada](https://entsoc.ca/2025/08/chlorinated-water-and-swimmer-ent-health-effects-prevention/)
- [Swimmer's Ear — Mayo Clinic](https://www.mayoclinic.org/diseases-conditions/swimmers-ear/symptoms-causes/syc-20351682)

---
