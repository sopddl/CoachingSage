# Doctrine TENNIS — fragment Story 0.5.10

Référentiel public sourcé pour la regen des templates tennis Story 0.5.10 et l'algo deterministic local Story 3.3a.

**Last revised** : 2026-04-30.

**Statut** : Phase C — fragment tennis complet, prêt à intégrer dans `leon-algo-doctrine-by-sport.md` puis à consommer par `master-tennis.md`.

**Vocabulaire de niveau** (aligné enums Sport + Level Story 0.5.8) :
- `beginner` : aucune ou très faible expérience ; vise la prise en main du grip, du timing et des déplacements de base ; capable d'enchaîner 5-10 échanges réguliers depuis le fond, sans engagement compétitif. Équivalent NTRP 1.5-2.0 / FFT NC à 40 / ITF Play-Tennis ou Level 1 starter player.
- `recreational` : pratique 1 à 2× / sem, capable de tenir un échange de 10-15 coups en cross, premier service en jeu, vise la régularité technique en match amical ou interclub bas. Équivalent NTRP 2.5-3.0 / FFT 30 à 30/2 / ITF "intermediate".
- `regular` : pratique 2 à 4× / sem depuis ≥ 1 an, joue des matchs réguliers (interclubs, tournois loisirs), travaille des combinaisons tactiques et un service efficace, vise progression classement. Équivalent NTRP 3.5-4.5 / FFT 30/1 à 15/4 / ITF "advanced intermediate".
- `competitive` : pratique 4 à 6× / sem incl. dryland S&C, prépare un calendrier de tournois (FFT, ITF amateur, USTA leagues niveau 4.0+) avec périodisation et tapering. Équivalent NTRP 5.0+ / FFT 15/3 et au-dessus / ITF "advanced / high performance".

---

## Doctrine référente

| Référence | Auteur / institution | Application |
|---|---|---|
| **Tennis Anatomy** (2nd ed., 2020) | E. Paul Roetert, Mark Kovacs | Anatomie spécifique tennis, exercices ciblés (75+) pour épaule, core, jambes, transferts mécaniques forehand / backhand / volée / service. |
| **Complete Conditioning for Tennis** (2nd ed., 2016) | Mark Kovacs, E. Paul Roetert, Todd S. Ellenbecker (USTA) | Référentiel S&C tennis officiel USTA : speed-agility-footwork, core, force, puissance, plyométrie, prévention blessures. |
| **USTA NTRP** (National Tennis Rating Program) | USTA | Échelle 1.5 → 7.0 par 0.5, descripteurs comportementaux par niveau, base du leveling US (et calibration `recreational`/`regular`/`competitive` CoachingSage). |
| **ITF Coach Education Programme** (Play-Tennis / Level 1 Beginner & Intermediate / Level 2 Advanced) | International Tennis Federation | Curriculum coach 4 niveaux (Gold/Silver/Bronze/White), structure pédagogique technique-tactique-physique-mental, cadre international pour `beginner`/`recreational`. |
| **Système de classement FFT** (4 séries + 5e série 40/2-40/1 depuis 2025) | Fédération Française de Tennis | Échelle française NC → 1ère série, calibration locale pour publics francophones. |
| **Kovacs Institute — Adult Tennis Fitness L1** | Mark Kovacs | Programmation tennis fitness pour adulte récréatif, structure 6-10 hpw 40% drills / 40% match play / 20% physique. |
| **Regional Interdependence model** (rotator cuff ↔ tennis elbow) | Ellenbecker et al. (review PMC) | Force scapulaire et coiffe = facteur protecteur tennis elbow ; programme prévention 6-12 sem en parallèle technique. |

Sources :
- [USTA — Understanding NTRP Ratings](https://www.usta.com/en/home/coach-organize/tennis-tool-center/run-usta-programs/national/understanding-ntrp-ratings.html)
- [USTA — NTRP Ratings: FAQs](https://www.usta.com/en/home/play/adult-tennis/programs/national/usta-ntrp-ratings-faqs.html)
- [2026 Tennis Pathways: UTR vs USTA and ITF Juniors plus NTRP](https://tennisacademy.app/blog/2026-tennis-pathways-utr-vs-usta-and-itf-juniors-plus-ntrp)
- [ITF Coach Education Programme](https://www.itftennis.com/en/news-and-media/articles/itf-coach-education-programme-educating-and-certifying-coaches/)
- [ITF Recognition of Coach Education Systems brochure 2025 (PDF)](https://www.itftennis.com/media/2237/appendix-8-recognition-brochure-2025-1.pdf)
- [ITF Coaching Beginner & Intermediate Players Course (Level 1 PDF)](https://tennis.lt/wp-content/uploads/2021/07/Coaching-Beg.-Intermediate-Tennis-Players-General-characteristics-of-course.pdf)
- [FFT — Découvrez votre classement tennis](https://www.fft.fr/actualites/decouvrez-votre-classement-tennis)
- [Système de classement du tennis français — Wikipédia](https://fr.wikipedia.org/wiki/Syst%C3%A8me_de_classement_du_tennis_fran%C3%A7ais)
- [Tennis Anatomy — Roetert & Kovacs (Human Kinetics)](https://www.amazon.com/Tennis-Anatomy-Paul-Roetert/dp/1492590584)
- [Complete Conditioning for Tennis 2E — Kovacs, Roetert, Ellenbecker (Human Kinetics)](https://us.humankinetics.com/products/complete-conditioning-for-tennis-2nd-edition-with-hkpropel-online-video)
- [Kovacs Institute — Adult Tennis Fitness L1](https://kovacsinstitute.com/adulttennisfitnessl1.html)
- [Building an Effective Weekly Tennis Training Plan — Jinji Tennis](https://www.jinjitennis.org/post/building-an-effective-weekly-tennis-training-plan)

**Choix de doctrine** : on ancre sur **USTA / Kovacs-Roetert-Ellenbecker** comme référentiel principal (S&C tennis-spécifique le plus complet en 2026, endossé USTA, transposable mondialement). On utilise **NTRP** comme calibration des 4 niveaux (mapping clair, descripteurs comportementaux disponibles), avec mention FFT et **ITF Coach Education** pour repères francophones et internationaux. Pas d'exclusivité FFT car le système de classement FFT est calculé sur résultats de matchs (rétrospectif), pas sur compétences pédagogiques (prospectif).

---

## Zones d'effort (target_zone)

Convention v2 tennis : **RPE intermittent + zones FC** comme repère cardio (le tennis est un sport intermittent à dominante anaérobie alactique répétée — pas de zone d'effort soutenue style endurance). Pour les drills techniques et le S&C off-court, vocabulaire dédié.

| Zone | %FCmax indicatif | RPE | Description | Application tennis |
|---|---|---|---|---|
| **Z1** (récup) | < 65% | 1-2 | Récupération active, marche, mobilité | Échauffement marche, retour au calme, jour entre 2 séances dures |
| **Z2** (aérobie low) | 65-75% | 3-4 | Aérobie de base, conversational | Footing 20-30 min, mini-tennis, échauffement court 10-15 min |
| **Z3** (tempo) | 75-85% | 5-6 | "Comfortably hard" | Drill panier de balles continu (régularité fond de court 8-15 min), shadow rallye |
| **Z4** (intermittent / threshold) | 85-92% | 7-8 | Effort soutenu intermittent | Sets entraînement, drills tactiques 3-6 coups, séries d'échanges chronométrés |
| **RPE 5-6** (rallye contrôle) | n/a | 5-6 | Contrôle technique sous fatigue modérée | Drills cross régularité, drills variés vitesse contrôlée |
| **RPE 7-8** (rallye match) | n/a | 7-8 | Cadence match | Sets entraînement, exercice rallye 6-10 coups, panier intensité match |
| **RPE 8-9** (sprint / matchplay) | n/a | 8-9 | Sprint répété, point de pression | Drills "11 points game", side-to-side panier explosif, sprint matchplay |
| **technique** | n/a | 3-5 | Drills purs cognitive load > effort | Mini-tennis grip + plate, drills mur, ghost-stroking, panier prise correcte |
| **cool-down** | n/a | 1-2 | Étirements / mobilité passive fin de séance | 5-10 min stretching post-séance |
| **RPE 6-7** / **RPE 7-8** off-court | n/a | 6-8 | Renforcement musculaire dryland | Y-T-W, external rotation, planches anti-rotation Pallof, plyo modérée |

**Choix de doctrine** : on **n'utilise pas de zones d'effort soutenu type Daniels-T / FTP-Sweet-Spot** en tennis car le sport est intrinsèquement intermittent. On combine **RPE intermittent** (cadre Kovacs) + **% FCmax** (repère grand public optionnel) + une catégorie `technique` first-class pour les drills moteurs purs. Pour `beginner`, **éviter Z3-Z4 et RPE > 6** : focus sur `technique` et Z2 (échauffement, mini-tennis), pas de point compétitif chronométré.

---

## Volume hebdo cible par niveau

**Convention volume tennis v2** : volume hebdo exprimé en **heures court + heures S&C off-court** (effort sport-pur, hors trajets et hors warmup individuel < 10 min). Une séance court = 60-90 min typique. Une séance S&C off-court = 30-60 min typique.

| Niveau | Vol pic (h court / sem) | Vol S&C off-court | Fréquence totale | Doctrine source |
|---|---|---|---|---|
| **beginner** | 1.5-2.5 h court | 0.5-1 h | 2 séances / sem (1 court + 1 S&C OU 2 court courtes) | ITF Play-Tennis, USTA NTRP 1.5-2.0, Kovacs Adult Tennis Fitness L1 |
| **recreational** | 3-4.5 h court (2-3 séances 60-90 min) | 0.5-1 h | 3-4 séances / sem | Kovacs Adult Fitness L1 (6-10 hpw avec marges débutant), Voyager Tennis recreational |
| **regular** | 4.5-7 h court (3 séances + 1 set match) | 1-1.5 h S&C dédié | 4-5 séances / sem | Jinji Tennis "competitive amateur", Aubone training week pré-tournoi amateur |
| **competitive** | 8-12+ h court (4-5 séances + 1-2 sets / matchs) | 2-3 h S&C dédié | 5-6 séances / sem (parfois doubles court+S&C même jour) | Aubone high performance week, Mattspoint General Preparation, Kovacs Institute Performance |

**Long set ou point fort par niveau** :
- `beginner` : séance phare W8-W9 = 45-60 min court avec 20 min de drills techniques + 15-20 min échanges réguliers + cool-down.
- `recreational` : séance phare = 75-90 min court avec drills techniques + sets partiels / tie-breaks (sans pression compétitive forte).
- `regular` : séance phare = 90 min court avec drills tactiques + 1 set d'entraînement complet + S&C 45-60 min en jour dédié.
- `competitive` : séance phare = 2 h court (drills + 2 sets) + S&C dédié 60-90 min jour différent + 1 séance match-simulation tournoi.

---

## Périodisation tennis

Le tennis n'a pas de "saison" universelle (compétition continue toute l'année en intérieur + extérieur). On structure autour d'un objectif tournoi A-event (champion de club, interclubs, tournoi régional, ITF Masters amateur).

#### Phases (modèle Kovacs-USTA adapté)
- **Intersaison / pré-saison** (4-8 sem) : volume S&C élevé (force, puissance, plyo), volume court modéré, technique en focus. Pas de match compétitif.
- **Saison / phase compétitive** (6-12 sem) : volume court élevé, S&C maintien (1×/sem), drills tactiques + matchs entraînement, A-events programmés.
- **Compétition / pic** (1-2 sem A-event) : taper, fréquence maintenue, intensités courtes conservées, S&C léger.
- **Récupération active / off** (1-2 sem post A-event) : volume -50%, mobilité, sortie cardio croisé (vélo Z2, natation easy), pas de match.

#### Cycle de base (build / cutback)
- `beginner` : 5-6 build + 1 cutback W4-W5 (-25 à -30% volume accepté car charge absolue faible).
- `recreational` : 3 build + 1 cutback (-15 à -20%).
- `regular` : 3 build + 1 deload (-15 à -20%).
- `competitive` : 2-3 build + 1 deload (-15 à -20%).

Pour tout plan ≥ 6 semaines : prévoir au moins 1 semaine cutback. Renseigne `deload_weeks: [W]` au niveau template. **Préfère un range** (ex : "réduction ~15-20%") qu'un chiffre faux.

#### Tapering (plans avec objectif tournoi A-event)
- **J-14** : volume ~70% du pic (drills techniques conservés, S&C -30%).
- **J-7** : volume ~50-60% du pic (sets entraînement remplacés par drills techniques + 1 match-test léger).
- **J-3 à J-1** : 2 séances courtes 45-60 min court (drills techniques + service / retour) + 0 S&C lourd, S&C neuromusculaire léger autorisé J-2.
- **Fréquence ≥ 80% des sessions habituelles** (raccourcir, pas supprimer).

---

## 4 piliers tennis (technique / tactique / physique / mental)

Modèle Kovacs-Roetert-Ellenbecker (Complete Conditioning for Tennis) + ITF Coach Education syllabus.

| Pilier | Composantes | Application par niveau |
|---|---|---|
| **Technique** | Grip (eastern, semi-western, continental), prise correcte forehand / backhand / service, footwork (split-step, recovery step), timing, prise de balle haute / basse | Dominant `beginner` (60-70% du temps court), important `recreational` (40-50%), maintien `regular`/`competitive` (20-30%) |
| **Tactique** | Schémas (cross régulier, long de ligne décisif, service-volée), patterns 1-2-3 coups, gestion du score, lecture adversaire | Introduit `recreational` (10-20%), dominant `regular` (30-40%), critique `competitive` (40-50%) |
| **Physique** | S&C off-court : mobilité épaule, agilité 6 directions, force unilatérale, puissance rotationnelle, plyo, cardio intermittent | `beginner` 15-20% (préventif), `recreational` 20-25%, `regular` 25-30%, `competitive` 30-35% |
| **Mental** | Routines pré-service, gestion entre les points (16-20 sec), respiration, focus, gestion erreurs, rituels avant match | Sensibilisé `recreational` (5-10%), travaillé `regular` (10-15%), critique `competitive` (15-20%) |

**Règle d'équilibre** : sur une semaine type, viser un mix (technique + tactique) = ~60-70% temps court, S&C off-court = 15-30% volume total selon niveau, mental intégré aux drills (pas une séance isolée sauf `competitive`).

---

## S&C tennis (mobilité épaule + agilité 6 directions + force unilatérale + cardio intermittent)

Référentiel : **Complete Conditioning for Tennis 2e éd.** (Kovacs, Roetert, Ellenbecker / USTA).

#### Mobilité épaule + prévention coiffe rotateurs (TOUS niveaux, dès W1)

- **Y-T-W** (élévations bras dans les 3 plans), 2-3 sets × 10-15 reps.
- **External rotation à la bande** (rotation externe coude au corps / coude à 90°), 2-3 sets × 12-15 reps par bras.
- **Prone row + scaption** (renforcement scapulaire), 2-3 sets × 10-12 reps.
- **Sleeper stretch** + cross-body stretch (mobilité postérieure capsule), 2-3 sets × 30 sec par bras.
- **Foam rolling** thoracique + grand dorsal, 5 min en cool-down.

#### Agilité 6 directions (footwork tennis-spécifique)

- **Split-step** au signal, 3 sets × 6-8 reps (intégré dans drills technique).
- **Side shuffle** (déplacement latéral), 3 sets × 10-15 m aller-retour, base couverture latérale baseline.
- **Cross-over step** (pas chassé croisé, couverture wide-ball), 3 sets × 10 m × 4-6 reps par côté.
- **Back-pedal** (recul lob défense), 3 sets × 6-8 m × 4-6 reps.
- **Carioca / grapevine** (footwork latéral coordination), 3 sets × 10 m × 2-4 reps.
- **Sprint avant 5-10 m** (accélération filet), 3 sets × 6-8 reps.
- **Échelle d'agilité** (agility-ladder) : in-out, lateral icky shuffle, 3 sets × 4-6 patterns.

#### Force unilatérale + core anti-rotation

- **Single-leg squat** ou **split squat bulgare**, 3 sets × 6-10 reps par jambe (`recreational`+).
- **Hip thrust unilatéral**, 3 sets × 8-12 reps par jambe.
- **Walking lunge** + rotation buste avec medecine ball, 3 sets × 10 reps total.
- **Pallof press / anti-rotation** (core anti-rotation tennis-spécifique), 3 sets × 10-15 reps par côté.
- **Side plank with rotation**, 3 sets × 30-45 sec par côté.
- **Bird-dog**, 3 sets × 10 reps par côté.
- **Deadlift roumain unilatéral léger** (`regular`+), 3 sets × 8-10 reps par jambe.

#### Puissance / plyométrie

- **Med ball rotational throws** (mur / partenaire), 3 sets × 6-8 reps par côté (`recreational`+).
- **Med ball overhead slam** (puissance descendante service), 3 sets × 6-8 reps (`regular`+).
- **Box jump bas** (40-50 cm), 3 sets × 5-8 reps (`regular`+).
- **Lateral bound** (saut latéral unilatéral), 3 sets × 4-6 reps par côté (`regular`+).
- **Plyo push-up + drop catch** (puissance haut du corps service), 3 sets × 5-8 reps (`competitive` uniquement).

#### Cardio intermittent (style tennis)

- **Sprint 10-20 m + récup 30-60 sec** (ratio effort:récup 1:2 à 1:3), 8-12 reps (`recreational`+).
- **Footing intermittent** : 30 sec Z3 + 30 sec Z1, 8-15 cycles (`recreational`+ hors-saison).
- **Conditioning circuit Kovacs** : 6 stations × 30 sec (sprint, agility ladder, med ball, push-up, lunge, plank), 3-4 tours, 15-20 sec récup entre stations (`regular`+).

**Règle volume S&C** : `beginner` 1×/sem 30 min, `recreational` 1×/sem 45-60 min, `regular` 2×/sem 45-60 min en hors-saison + 1×/sem en saison, `competitive` 2-3×/sem 60 min hors-saison + 1-2×/sem en saison.

---

## Drapeaux rouges (safety)

Référence : Tennis Anatomy + Complete Conditioning + revue PMC sur regional interdependence.

#### Tous niveaux

- **Tennis elbow / épicondylite latérale** : douleur épicondyle externe coude, déclenchée backhand mal exécuté (notamment slice ou backhand 1 main), grip inadapté, raquette trop tendue (cordage > 25 kg), forearm faible. **Prévention** : programme **rotator cuff + scapular work 2-3×/sem** dès W1 (Y-T-W, external rotation, prone row), check grip + cordage, exercices forearm excentriques (Tyler Twist, wrist extensor 3-5 kg). Si douleur > 2 séances consécutives → consultation kiné. **Indication MDR** : exclure tendinopathie chronique > 6 sem avant volume haute.
- **Pathologie épaule (coiffe rotateurs)** : douleur antérieure ou latérale épaule au service ou smash, signaux : tendinite supra-épineux, conflit sous-acromial, SLAP. **Prévention** : 3 piliers (mobilité postérieure capsule + force coiffe + force scapulaire) dès W1, jamais omettre Y-T-W et external rotation. Réduire volume service si sensible (max 30-40 services / séance).
- **Poignet** : douleur radiale (TFCC / ECU / De Quervain) sur grip mal adapté ou raquette trop lourde. Vérifier grip size, poids raquette (<300 g pour `beginner`/`recreational`), cordage souple.
- **Entorse cheville** : sport à fort risque (changements direction). **Prévention** : chaussures tennis dédiées (pas de running shoe), proprio (single-leg balance, BOSU) 2×/sem, agilité progressive. Reprise progressive après entorse, jamais de matchplay direct sur cheville encore instable.
- **Genou** : tendinite rotulienne sur volume sprint répété, syndrome rotulo-fémoral, entorse LCA sur changement direction brutal. **Prévention** : force unilatérale (split squat, hip thrust unilatéral), proprio, agilité progressive, ne pas multiplier les pivots brusques sur surface dure (béton > terre battue en charge articulaire).

#### Recreational et au-delà

- **Lombalgie service** : sur extension répétée + rotation au service, dos sensible. Renforcement core anti-rotation (Pallof, bird-dog, side plank) + mobilité hanche.
- **Tendinite Achille** : sur volume sprint répété. Calf raises excentriques préventifs, surface mixte (alterner dur / terre battue).

#### Competitive

- **Surentraînement** : FC repos +10 bpm chronique, sommeil dégradé, perte motivation 3+ semaines, baisse perf en match.
- **RED-S** (Relative Energy Deficiency in Sport) : déficit énergétique sur volume haute intensité + déficit calorique. Sentinelles : aménorrhée (femmes), fatigue chronique, immunité dégradée.
- **Coup de chaleur** sur tournoi été extérieur : hydratation 500-750 ml/h chaleur > 25°C + sodium 300-700 mg/L, écouter signaux (céphalée, frissons, désorientation = STOP immédiat, sortie du court).

---

## Substitutions classiques (alternatives v2)

Liste de remplacements réalistes pour l'algo deterministic Story 3.3a.

| Exercice planifié | Substitution | Trigger |
|---|---|---|
| Drill panier de balles avec coach | Drill mur (1 m de distance, focus régularité 50 frappes contre mur) | Pas d'accès coach / pas de panier |
| Drill 2 joueurs cross régulier | Drill mur cross side-to-side | Pas de partenaire |
| Set d'entraînement | Drill panier match-simulation 11 points | Pas de partenaire |
| Service sur court | Ghost-stroking service + service contre mur (focus geste) | Court fermé, drill technique pure |
| Match indoor | Match outdoor terre battue ou dur | Selon dispo |
| Séance court annulée (météo) | S&C off-court complet 60 min (mobilité + force + agilité ladder + cardio intermittent) | Pluie, court inutilisable |
| Plyo chargée (`competitive`) | Plyo bodyweight (lateral bound, box jump bas) | Fatigue cumulée 3 sem, sommeil dégradé |
| Sprint répété fond de court | Sprint sur court intermittent intermittent footing | Surface court sensible (genou) |
| Drill side-to-side panier intensif | Drill cross régularité contrôle | Knee-flare aigu, ankle-injury récent |

---

## EU MDR — Mots à bannir + medical clearance

Vocabulaire qui constituerait un acte médical en UE (Med Device Regulation 2017/745).

#### Bannis dans tout texte généré

- "soigner [pathologie]", "traitement [pathologie]", "guérir", "remède"
- "rééducation post-opératoire", "post-blessure"
- "cure", "thérapie", "diagnostic", "prescription", "ordonnance"
- "soulager [douleur]" → préférer "réduire l'inconfort", "favoriser le confort"
- "réparer le coude / l'épaule / le poignet" → préférer "renforcer", "stabiliser"

#### Triggers medical clearance obligatoire

Inclure mention "Consulte un médecin avant de commencer ce programme" dans `safety_notes` si :
- **Tennis elbow chronique** (épicondylite > 6 semaines symptômes) → consultation kiné avant programme.
- **Pathologie épaule connue** (tendinite coiffe diagnostiquée, SLAP, conflit sous-acromial) → réduction volume service + variantes, avis kiné.
- **Antécédents cardiaques** sur sprint intermittent (cardio à RPE 8-9) → `cardiac-clearance-required`.
- **Reprise post-entorse cheville / genou** récente (< 3 mois) → consultation et reprise progressive.
- **Grossesse** ou postpartum (`pregnancy`, `postpartum-early`).
- Profil `beginner` > 50 ans débutant complet sans test effort récent.

---

## Hooks metadata standards (tennis)

#### `target_zone`
- `Z1`, `Z2`, `Z3`, `Z4` (zones FC, repère cardio)
- `RPE 5-6` (rallye contrôle), `RPE 7-8` (rallye match), `RPE 8-9` (sprint / matchplay)
- `RPE 6-7`, `RPE 7-8` (renforcement off-court)
- `technique` (drills moteurs purs, focus cognitive load)
- `cool-down` (étirements / mobilité fin séance)

#### `required_equipment`

Vocabulaire kebab-case :
- `racket` : OBLIGATOIRE pour toute séance court — jamais omis.
- `balls` : OBLIGATOIRE pour toute séance court (panier `recreational`+, tube de balles `beginner`).
- `court` : court tennis dur / terre battue / synthétique. **Toute séance court le requiert sauf `wall` substitution.**
- `wall` : mur d'entraînement (drill solo).
- `cones` : marquage déplacements / drills agilité.
- `agility-ladder` : échelle d'agilité (S&C off-court).
- `tennis-shoes` : chaussures tennis dédiées (pas running shoe — semelle latérale + non-marking).
- `coach` ou `partner` : optionnel `beginner` (panier coach recommandé), recommandé `recreational`+ (partenaire ou coach), attendu `regular`/`competitive`.
- `ball-machine` : panier balles mécanique (alternative coach panier).
- `mat`, `resistance-band`, `medicine-ball`, `dumbbells`, `foam-roller` (S&C off-court).

#### `incompatible_constraints`

Vocabulaire kebab-case :
- `tennis-elbow` (épicondylite latérale active)
- `shoulder-injury` (coiffe rotateurs, SLAP, conflit)
- `wrist-pain` (TFCC, ECU, De Quervain)
- `lower-back-pain`
- `knee-injury` (rotulien, ligamentaire)
- `ankle-injury` (entorse récente < 3 mois)
- `cardiac-clearance-required`
- `pregnancy`, `postpartum-early`
- `no-court-access` (impacte alternatives mur / S&C complet)
- `no-partner` (impacte alternatives mur / panier ball-machine / ghost-stroking)
- `no-coach`
- `outdoor-only`, `indoor-only` (préférence court)
- `clay-only`, `hard-only` (préférence surface)

#### `alternatives`

Liste de noms d'exercices substitutifs (cf. tableau Substitutions ci-dessus). **Minimum 1-2 alternatives réalistes par exercice. `alternatives: []` vide INTERDIT — l'algo deterministic Story 3.3a en a besoin.**

#### `volume_axis`
- `duration` (drills minutés, séries d'échanges chronométrés, échauffement, cool-down)
- `sets` (séance structurée : `sets: 4` × `duration: "5 min cross régularité + 2 min récup"`)
- `reps` (renforcement musculaire, services chiffrés "20 services slice + 20 services kické")

`distance` non applicable tennis (pas de distance pure pertinente). `elevation` non applicable.

---

## `week_structure` typique par niveau

| Niveau | type | micro_pattern | recovery_cadence |
|---|---|---|---|
| **beginner** | `linear` | `technique court court + S&C off-court mobilité-prévention` (2 séances) | `1 cutback W4-W5 sur plan 8 sem` |
| **recreational** | `linear` | `technique court + drills + S&C off-court + match amical optionnel` | `1 deload toutes les 4 semaines` |
| **regular** | `block` | `technique + drills tactiques + S&C dédié + set entraînement + court récup` | `1 deload toutes les 3-4 semaines` |
| **competitive** | `polarized` | `technique + drills + S&C 2× + set match + simulation tournoi + récup active` | `1 deload toutes les 3 semaines + taper avant A-event` |

`deload_weeks` exemples :
- Plan 8 sem `beginner` : `[5]`
- Plan 12 sem `recreational` : `[4, 8]`
- Plan 14 sem `regular` : `[4, 8, 12]`
- Plan 16 sem `competitive` : `[4, 8, 12]` + taper W15-W16 distinct

---

## Sources

#### Doctrine et leveling
- [USTA — Understanding NTRP Ratings](https://www.usta.com/en/home/coach-organize/tennis-tool-center/run-usta-programs/national/understanding-ntrp-ratings.html)
- [USTA NTRP Ratings: FAQs](https://www.usta.com/en/home/play/adult-tennis/programs/national/usta-ntrp-ratings-faqs.html)
- [2026 Tennis Pathways: UTR vs USTA and ITF Juniors plus NTRP — Tennis Academy App](https://tennisacademy.app/blog/2026-tennis-pathways-utr-vs-usta-and-itf-juniors-plus-ntrp)
- [USTA Tennis Ratings vs Rankings](https://www.usta.com/en/home/play/youth-tennis/programs/national/junior-and-adult-ratings-vs-rankings.html)
- [ITF Coach Education Programme](https://www.itftennis.com/en/news-and-media/articles/itf-coach-education-programme-educating-and-certifying-coaches/)
- [ITF Recognition of Coach Education Systems brochure 2025 PDF](https://www.itftennis.com/media/2237/appendix-8-recognition-brochure-2025-1.pdf)
- [ITF Coaching Beginner & Intermediate Players Course Level 1 PDF](https://tennis.lt/wp-content/uploads/2021/07/Coaching-Beg.-Intermediate-Tennis-Players-General-characteristics-of-course.pdf)
- [FFT — Découvrez votre classement tennis](https://www.fft.fr/actualites/decouvrez-votre-classement-tennis)
- [Système de classement du tennis français — Wikipédia](https://fr.wikipedia.org/wiki/Syst%C3%A8me_de_classement_du_tennis_fran%C3%A7ais)
- [FFT — Règles et classement du tennis](https://www.fft.fr/nos-sports/tennis/les-regles-tennis)

#### S&C et anatomie tennis
- [Tennis Anatomy 2e éd. — Roetert & Kovacs (Amazon)](https://www.amazon.com/Tennis-Anatomy-Paul-Roetert/dp/1492590584)
- [Tennis Anatomy — Roetert & Kovacs (Barnes & Noble)](https://www.barnesandnoble.com/w/tennis-anatomy-e-paul-roetert/1101099988)
- [Complete Conditioning for Tennis 2E — Kovacs, Roetert, Ellenbecker (Human Kinetics)](https://us.humankinetics.com/products/complete-conditioning-for-tennis-2nd-edition-with-hkpropel-online-video)
- [Complete Conditioning for Tennis (Internet Archive)](https://archive.org/details/completeconditio0000kova_2ed)
- [Kovacs Institute — Adult Tennis Fitness L1](https://kovacsinstitute.com/adulttennisfitnessl1.html)
- [Strength and conditioning in tennis: Current research and practice — ResearchGate](https://www.researchgate.net/publication/6240542_Strength_and_conditioning_in_tennis_Current_research_and_practice)
- [Effects of A 6-Week Junior Tennis Conditioning Program on Service Velocity — PMC](https://pmc.ncbi.nlm.nih.gov/articles/PMC3761833/)

#### Volume hebdo et structure semaine
- [Building an Effective Weekly Tennis Training Plan — Jinji Tennis](https://www.jinjitennis.org/post/building-an-effective-weekly-tennis-training-plan)
- [How I Would Structure a High Performance Player's Training Week — Aubone Tennis](https://www.aubonetennis.com/blog/trainingweekleadingintoatournament)
- [The Time Commitment: How Many Hours to Train — Silicon Valley Tennis Academy](https://siliconvalleytennis.com/the-time-commitment-how-many-hours-do-you-need-to-train-to-be-good-at-tennis/)
- [How to choose the right training volume based on your goals — Voyager Tennis](https://www.voyagertennis.com/featured/how-to-choose-the-right-training-volume-based-on-your-tennis-goals/)
- [General Preparation for Tennis — Mattspoint](https://www.mattspoint.com/blog/off-season-training-for-tennis-part-2)

#### Prévention blessures (tennis elbow / coiffe rotateurs)
- [Comprehensive rehabilitation for lateral elbow tendinopathy — PMC](https://pmc.ncbi.nlm.nih.gov/articles/PMC6769266/)
- [To Study the Effect of Rotator Cuff Exercises on Tennis Elbow — IJPHRD PDF](https://medicopublication.com/index.php/ijphrd/article/download/1353/1244/2451)
- [Therapeutic Exercise for Epicondylitis — Denver Shoulder Surgeon](https://www.denvershouldersurgeon.com/therapeutic-exercise-for-epicondylitis.html)
- [Shoulder Strengthening Exercises for Elbow Pain — BSR Physical Therapy](https://www.bsrphysicaltherapy.com/2018/01/29/strengthen-shoulder-elbow-pain/)
- [Exercises To Help Prevent Tennis Elbow — Evolution PT](https://www.evolutionphysicaltherapy.com/post/exercises-to-help-prevent-tennis-elbow/)
- [Exercises and Stretches for Tennis Elbow — Airrosti](https://www.airrosti.com/blog/exercises-and-stretches-for-tennis-elbow-lateral-epicondylitis/)
