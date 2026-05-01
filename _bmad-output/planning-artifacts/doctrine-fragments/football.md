# Doctrine FOOTBALL — fragment Story 0.5.10

Référentiel public sourcé pour la création **ex nihilo** des templates football (soccer) Story 0.5.10 et l'algo deterministic local Story 3.3a.

**Last revised** : 2026-05-01.

**Statut** : Phase C — fragment football complet, créé sans v1 préexistante. Prêt à intégrer dans `leon-algo-doctrine-by-sport.md` puis à consommer par `master-football.md`.

**Vocabulaire de niveau** (aligné enums Sport + Level Story 0.5.8) :
- `beginner` : pratique loisir occasionnelle, foot à 5 / 7 amical, base de contrôle de balle non maîtrisée. < 1 an de pratique structurée. Aucun match compétitif. Vise : enchaîner 10 passes courtes contrôlées, conduire la balle slalom 10 m sans perte. FFF NC, FA Grassroots Discover, UEFA Grassroots C entry.
- `recreational` : pratique 1-2 × / sem en équipe amicale ou foot à 7-11 loisir, vise condition physique générale et plaisir de jeu. Capable de tenir un match 2 × 30 min. Pas d'objectif compétitif chronique. FFF Loisir / vétéran, FA Recreational Adult.
- `regular` : pratique 2-4 × / sem en équipe district / amateur, niveau **D1-D2 départemental** en France ou équivalent FA Step 5-7 / Sunday League serious. 1 match / weekend. Entraînement structuré tactique-technique-physique, FIFA 11+ obligatoire. Vise progression collective et résultats de poule.
- `competitive` : pratique 4-6 × / sem en équipe régionale / national amateur (FR : R3-N3, FA Step 1-4 ou top of Step 5, semi-pro), périodisation pré-saison / saison / inter-saison structurée, FIFA 11+ + Nordic hamstring + Copenhagen adduction obligatoires. Volume hebdo 8-12 h. Match de championnat tous les weekends + coupes.

---

## Doctrine référente

| Référence | Auteur / institution | Application |
|---|---|---|
| **FIFA 11+ Injury Prevention Programme** (F-MARC, 2006-2009) | FIFA Medical Assessment and Research Centre | **GOLD STANDARD prévention blessures football amateur et sub-élite.** 10 exercices, 10-15 min en échauffement, 2× / sem minimum. Réduction blessures 30-70%, ACL féminin -50%. Aucun équipement hors ballon. Avant match : parties 1 et 3 (running) seulement. |
| **The Original Guide to Football Periodisation** (Verheijen, 2014) | Raymond Verheijen | Périodisation tactique en langage football (pas en langage athlétisme). 4 piliers : tactique / game insight / technique / fitness football-spécifique. Micro-cycle 4 jours autour du match (-3, -2, -1, MD = match day). Cutback in-season -20 à -30%. |
| **Periodization Training for Sports** (Bompa & Buzzichelli, 4e éd. 2015) | Tudor Bompa, Carlo Buzzichelli | 6 phases : adaptation anatomique, hypertrophie, force max, conversion en force spécifique, maintenance, peaking. Pré-saison football = AA + hypertrophie + force max ; in-season = maintenance + peaking par bloc tactique (GBL Game By Layer). |
| **UEFA Coaching Convention** (B / A / Pro Diploma) | UEFA / fédérations nationales | Curriculum coach 4 niveaux (C / B / A / Pro). UEFA B 95 h, 50/50 on-pitch / off-pitch, focus tactique 11v11 et drills techniques. UEFA A : 11v11 stratégies, principes en/hors possession, modern trends. Cadre international du coaching football amateur sérieux à pro. |
| **FFF DTN — Brevet d'Entraîneur de Football (BEF / BMF)** | Direction Technique Nationale, FFF | Référentiel formation entraîneurs amateur français : BMF coach jusqu'à Senior R3, BEF coach Senior régional. Calibration `regular` / `competitive` en France métropolitaine. |
| **Nordic Hamstring + Copenhagen Adduction** (méta-analyses 2016-2024) | Petersen, Thorborg et al. | Réduction blessures ischio -51% (NHE) et adducteurs / pubalgie -33% (CAE). À ajouter au FIFA 11+ pour `regular` / `competitive` dès W3. 3× / sem progressif sur 4-10 sem. |

Sources :
- [FIFA — Injury prevention and health promotion (FIFA 11+)](https://inside.fifa.com/health-and-medical/injury-prevention)
- [FIFA 11+: an effective programme to prevent football injuries — narrative review (PMC)](https://pmc.ncbi.nlm.nih.gov/articles/PMC4413741/)
- [The FIFA 11+ injury prevention program for soccer players: a systematic review (BMC)](https://link.springer.com/article/10.1186/s13102-017-0083-z)
- [The FIFA 11+ Soccer Injury Prevention Program — booklet PDF](https://jacobstirtonmd.com/wp-content/uploads/2019/07/The-FIFA-11-Soccer-Injury-Prevention-Program.pdf)
- [The Impact of the FIFA 11+ Training Program on Injury Prevention (PMC systematic review)](https://pmc.ncbi.nlm.nih.gov/articles/PMC4245655/)
- [Effects of the FIFA 11+ on performance, biomechanical and physiological responses (PMC)](https://pmc.ncbi.nlm.nih.gov/articles/PMC10105015/)
- [The FIFA 11+ — Physiopedia](https://www.physio-pedia.com/The_F%C3%A9d%C3%A9ration_Internationale_de_Football_Association_FIFA_11+)
- [The Original Guide to Football Periodisation Part 1 — Verheijen (Amazon)](https://www.amazon.com/Original-Guide-Football-Periodisation-Part/dp/949174500X)
- [Verheijen 2014 Football Periodisation PDF (Scribd)](https://www.scribd.com/document/472362372/VERHEIJEN-2014-Football-Periodisation-pdf)
- [Periodization Training for Sports — Bompa & Buzzichelli (Human Kinetics)](https://us.humankinetics.com/products/periodization-of-strength-training-for-sports-4th-edition)
- [UEFA Coaching Licences overview — UEFA.com](https://www.uefa.com/development/coaches/uefa-coaching-licences/)
- [UEFA B Diploma — England Football Learning](https://learn.englandfootball.com/courses/football/uefa-b-licence)
- [UEFA A Diploma — England Football Learning](https://learn.englandfootball.com/courses/football/uefa-a-licence)
- [FFF DTN — Parcours de Formation Educateurs / Entraîneurs](https://www.fff.fr/fff/formations/educateurs-entraineurs)
- [FFF Brevet d'Entraîneur de Football (BEF)](https://www.fff.fr/articles/details-articles/143913-552411-brevet-dentraineur-de-football)
- [Effect of Injury Prevention Programs that Include the Nordic Hamstring Exercise on Hamstring Injury Rates in Soccer Players — meta-analysis (PubMed)](https://pubmed.ncbi.nlm.nih.gov/27752982/)
- [Combining the Copenhagen Adduction and Nordic Hamstring Exercises Improves Dynamic Balance — RCT (PMC)](https://pmc.ncbi.nlm.nih.gov/articles/PMC8558994/)
- [Implementing the Copenhagen Adductor and Nordic Hamstring Exercises in Academy Soccer Players (IJSPT)](https://ijspt.scholasticahq.com/article/123510)
- [The Copenhagen Adduction Exercise Effect on Sport Performance and Injury Prevention — meta-analysis (PMC)](https://pmc.ncbi.nlm.nih.gov/articles/PMC12363431/)
- [Pre-season planning in football — complete guide (Zone14)](https://zone14.ai/en/blog/pre-season-planning-in-football/)
- [6 week pre-season fitness plan for amateur players (121 Personal Training)](https://121personaltraining.com/pre-season-training/)
- [Training intensity distribution in elite football, polarised or not? (TopSportsLab)](https://www.topsportslab.com/training-intensity-distribution-in-elite-football/)
- [Performance Adaptations to Intensified Training in Top-Level Football (Springer / PMC)](https://pmc.ncbi.nlm.nih.gov/articles/PMC9667002/)
- [Training Zones for Football Fitness — Aerobic Fitness Science (Professional Soccer Coaching)](https://www.professionalsoccercoaching.com/aerobic-fitness-science/training-zones-for-football-fitness)
- [Exploring the Physiological and Physical Basis of RPE Responses in Soccer (PMC)](https://pmc.ncbi.nlm.nih.gov/articles/PMC12590205/)
- [The Running Performance of Amateur Football Players in 1-4-3-3 (MDPI)](https://www.mdpi.com/2076-3417/14/16/7036)
- [I wore a GPS vest and compared my data to Premier League footballers (Planet Football)](https://www.planetfootball.com/in-depth/i-wore-a-gps-vest-and-compared-my-data-to-premier-league-footballers)
- [ACL Injuries in Soccer Players: Prevention and Return to Play Considerations (PMC)](https://pmc.ncbi.nlm.nih.gov/articles/PMC10743334/)
- [Return to Play and Performance After ACL Reconstruction in Soccer Players — systematic review (Sports Medicine)](https://link.springer.com/article/10.1007/s40279-024-02035-y)
- [Return to Play Guidelines for Soccer Athletes after ACL Surgery (Shepard MD PDF)](https://www.michaelshepardmd.com/pdfs/return-to-play-guidelines-for-soccer-athletes-after-acl-surgery.pdf)
- [Injury-Proofing the Squad: Protocols for ACL Prevention in Soccer (ISSPF)](https://www.isspf.com/articles/injury-proofing-the-squad-protocols-for-acl-prevention-in-soccer/)

**Choix de doctrine** : on ancre sur **FIFA 11+** comme socle prévention universel (validé scientifiquement, gratuit, sans matériel) + **Verheijen** comme cadre de périodisation tactique-spécifique (langage football, micro-cycle 4 jours autour du match) + **Bompa** comme cadre force / S&C off-pitch (phases AA → max strength → maintenance). On utilise **NHE + CAE** comme add-on prévention obligatoire dès `regular`. **UEFA Coaching Convention** + **FFF DTN** servent de référence pédagogique pour la structuration des séances tactique-technique. Pas de référentiel "Daniels-équivalent" en football car le sport est intermittent : on combine **% FCmax + RPE + ratios travail / repos** (cadre topsportslab + Buchheit).

---

## Zones d'effort (target_zone)

Convention v2 football : **% FCmax + RPE intermittent + ratios travail / repos**. Le football est un sport **intermittent à dominante alactique répétée + base aérobie** (8-12 km couvert / match en amateur, 200+ accélérations brèves, 580-630 m de sprint). **Pas de zone d'effort soutenue type Daniels-T ou FTP** car incohérent avec la nature intermittente du jeu. Catégorie `technique` first-class pour drills moteurs purs (passe, contrôle, conduite, frappe).

| Zone | %FCmax indicatif | RPE | Description | Application football |
|---|---|---|---|---|
| **Z1** (récup) | < 65% | 1-2 | Récup active, marche, mobilité | Échauffement marche, retour au calme, recovery J+1 post-match |
| **Z2** (aérobie low) | 65-75% | 3-4 | Aérobie de base, conversational | Footing 20-30 min, jeu de conservation 2 touches calme, échauffement 10-15 min |
| **Z3** (tempo) | 75-85% | 5-6 | "Comfortably hard" | Jeu réduit 4v4 / 5v5 espace large, conduite slalom continue, drill possession 6v6 |
| **Z4** (intermittent / threshold) | 85-92% | 7-8 | Effort soutenu intermittent | Intermittent 30s/30s, 20s/20s, jeu 3v3 espace réduit, séries d'attaque-défense |
| **RPE 7-8 intermittent** | n/a | 7-8 | Cadence match alactique répété | Drills 30s ON / 30s OFF, 4-6 séries × 4-6 reps, jeu réduit haute intensité |
| **RPE 8-9 sprint** | n/a | 8-9 | Sprint répété, accélération max | RSA (Repeated Sprint Ability) : 6-10 × 30 m départ arrêté, récup 20-30 s, 2-3 séries |
| **technique** | n/a | 3-5 | Drills moteurs purs cognitive load > effort | Passes courtes-longues, contrôle orienté, conduite cônes, frappe placée, jeu de tête sans opposition |
| **tactique** | n/a | 4-7 | Drills tactiques avec opposition modulée | Schémas attaque placée, sortie de balle, transition, animation défensive, coups de pied arrêtés |
| **cool-down** | n/a | 1-2 | Étirements / mobilité passive fin séance | 5-10 min stretching post-séance, mousse foam roller |
| **RPE 6-7 / RPE 7-8 off-pitch** | n/a | 6-8 | Renforcement musculaire dryland | NHE, CAE, hip thrust, plyo modérée, core anti-rotation |

**Ratios travail / repos football-spécifiques (Buchheit / Verheijen)** :
- **Capacité aérobie** : 30s ON / 30s OFF × 8-12 reps × 2-3 séries (Z3-Z4).
- **Puissance aérobie** : 15s ON / 15s OFF × 8-12 reps × 2-3 séries (Z4).
- **RSA (Repeated Sprint Ability)** : 4-6 s ALL OUT / 20-30 s récup × 6-10 reps × 2-3 séries (RPE 9-10, recovery complète entre séries).
- **Speed endurance** : 10-40 s effort / 1-3 min récup × 4-8 reps (RPE 8-9).
- **Petits jeux haute intensité** : 3v3 ou 4v4 sur 30×20 m, 4 × 3 min ON / 2 min OFF (Z4-RPE 8).

**Choix de doctrine** : pour `beginner`, **éviter Z4 et RPE > 6** : focus `technique` + Z2 + jeu réduit calme. Pour `recreational`, ajouter Z3 + RPE 5-6 (jeu réduit). Pour `regular`, toutes zones autorisées dont RPE 8-9 en RSA hebdo. Pour `competitive`, RSA + speed endurance + 30s/30s structurés en bloc.

**Mention explicite équivalent `% FCmax` dans `notes`** quand `target_zone` = `RPE *` pour utilisateurs avec cardiofréquencemètre. Mention `RPE` quand `target_zone` = `Z*`.

---

## Volume hebdo cible par niveau

**Convention volume football v2** : volume hebdo exprimé en **heures terrain (entraînement collectif + jeu réduit + matchs amicaux)** + **heures S&C off-pitch** (gym / domicile, 30-60 min). Hors matchs de championnat (le match est un événement à part, pas du volume d'entraînement). Hors trajets et hors warmup individuel < 10 min.

| Niveau | Vol pic (h terrain / sem) | Vol S&C off-pitch | Fréquence totale | Match competitif | Doctrine source |
|---|---|---|---|---|---|
| **beginner** | 1.5-3 h terrain | 0-0.5 h | 2 séances / sem (1 terrain + 1 mobilité-renfo OU 2 terrain courtes) | **Aucun** (foot à 5 amical OK) | FFF Grassroots, FA Discover, UEFA Grassroots C |
| **recreational** | 3-5 h terrain | 0.5-1 h | 2-3 séances / sem | Match amical hebdo OPTIONNEL (foot à 7-11 loisir) | FFF Loisir, FA Recreational, UEFA Grassroots |
| **regular** | 5-8 h terrain (2-3 entraînements 75-90 min + 1 match amical pré-match) | 1-1.5 h S&C dédié | 3-4 séances / sem + 1 match weekend | Championnat district D1-D2 hebdo | FFF BMF, FA Sunday League / Step 5-7, Verheijen amateur |
| **competitive** | 8-12 h terrain (4-5 entraînements 90-120 min + tactique vidéo + match-test) | 2-3 h S&C dédié | 5-6 séances / sem + 1-2 matchs (championnat + coupe) | R3-N3 / FA Step 1-4 hebdo + coupe | FFF BEF, UEFA B / A, Verheijen pro / semi-pro, Bompa GBL |

**Séance phare par niveau** :
- `beginner` : 60 min terrain avec 25 min de drills techniques (passe, contrôle, conduite) + 15-20 min jeu réduit 4v4 espace large calme + 10 min mobilité-prévention + cool-down. **Aucun match compétitif chronométré.**
- `recreational` : 75-90 min terrain avec FIFA 11+ raccourci 10 min + 25 min technique-tactique simple + 25 min jeu réduit / opposition / match amical 7v7 + cool-down.
- `regular` : 90 min terrain avec FIFA 11+ complet 15 min + 25-30 min tactique avec opposition + 20 min intermittent ou RSA + 15-20 min jeu réduit haute intensité + cool-down. 1 séance S&C dédié 45-60 min en jour différent (NHE + CAE + force unilatérale + plyo modérée).
- `competitive` : 120 min terrain avec FIFA 11+ + Nordic + Copenhagen 20 min + 30-40 min tactique-stratégie selon micro-cycle (-3 force, -2 RSA, -1 activation) + 20-30 min jeu réduit ou match-simulation + cool-down. 1-2 séances S&C dédié 60 min jour différent (force max ou maintenance selon phase).

---

## Périodisation football

Le football a une **saison structurée** avec délineation claire pré-saison / saison / inter-saison. On structure autour du calendrier compétitif (championnat 8-10 mois + coupe + amicaux pré-saison).

#### Phases (modèle Verheijen + Bompa adapté)

- **Pré-saison** (4-8 sem selon niveau, juillet-août en saison européenne) : volume terrain progressif (50% → 100% pic), volume S&C élevé (force max + hypertrophie Bompa AA puis Max Strength), drills techniques + tactique en focus, matchs amicaux progressifs (premier amical vers W3-W4). FIFA 11+ + NHE + CAE installés dès W1.
- **Saison / phase compétitive** (32-36 sem, septembre-mai) : volume terrain élevé maintenu, S&C maintenance (1× / sem `regular`, 2× / sem `competitive`), micro-cycle Verheijen 4 jours autour du match. Match weekend.
- **Compétition / pic** (mini-pics autour de coupes ou matchs charnière, ou mois de mai pour montée / maintien) : taper court 5-7 j avant match charnière, volume -25%, intensités courtes conservées.
- **Inter-saison / off** (4-6 sem, juin-juillet partiel) : volume -50 à -70%, mobilité, sortie cardio croisé (vélo Z2, natation easy), 1-2 sem complètement off, puis reprise progressive vers pré-saison.

#### Cycle de base (build / cutback)
- `beginner` : 5-6 build + 1 cutback (-25 à -30% volume accepté car charge absolue faible).
- `recreational` : 3 build + 1 cutback (-15 à -20%).
- `regular` : 3 build + 1 deload (-15 à -20%) en pré-saison ; in-season cutback "naturel" via volume -20 à -30% (Verheijen tactique-périodisation : in-season le focus passe à la récupération entre matchs).
- `competitive` : 2-3 build + 1 deload (-15 à -20%) en pré-saison ; in-season micro-cycle 4 jours stable, deload uniquement sur trêves internationales ou trêve hivernale.

Pour tout plan ≥ 6 semaines : prévoir au moins 1 semaine cutback. Renseigne `deload_weeks: [W]` au niveau template. **Préfère un range** (ex : "réduction ~15-20%") qu'un chiffre faux.

#### Micro-cycle 4 jours Verheijen (in-season, `regular` / `competitive`)

Si plan vise un championnat hebdomadaire :
- **MD-3 (Mardi si match Samedi)** : focus **force** football-spécifique. Jeu réduit 5v5 / 6v6, drills puissance, force off-pitch S&C (squat, hip thrust, NHE eccentric). Volume élevé, RPE 7-8.
- **MD-2 (Mercredi)** : focus **résistance** / capacité tactique. Petits jeux 3v3-4v4 haute intensité, RSA, Z4 30s/30s, séries 4-6 × 3-4 min. Volume élevé, RPE 8-9.
- **MD-1 (Vendredi, J-1 du match)** : **activation** : tactique-stratégie spécifique adversaire, coups de pied arrêtés, finition légère, FIFA 11+ raccourci. Volume bas-modéré, RPE 5-6.
- **MD (Samedi)** : **match**.
- **MD+1 (Dimanche)** : récup active 30 min Z1-Z2 + mobilité OU repos complet. Pour `competitive` uniquement.

#### Tapering (plans avec objectif match charnière, montée / maintien, coupe finale)
- **J-7** : volume ~70% du pic (drills tactiques conservés, S&C -30%).
- **J-3 à J-1** : 2 séances courtes 60-75 min terrain (activation + tactique-stratégie + finition légère) + 0 S&C lourd, FIFA 11+ raccourci.
- **Fréquence ≥ 80% des sessions habituelles** (raccourcir, pas supprimer).

---

## 4 piliers football (technique / tactique / physique / mental) — modèle Verheijen + UEFA

| Pilier | Composantes | Application par niveau |
|---|---|---|
| **Technique** | Passe (courte, longue, intérieur, extérieur, latéral), contrôle (orienté, amorti, poitrine, cuisse), conduite (intérieur, extérieur, slalom), dribble (élimination 1v1), frappe (placée, puissance, demi-volée, volée), jeu de tête (offensif, défensif), tacle | Dominant `beginner` (60-70% du temps terrain), important `recreational` (40-50%), maintien `regular` / `competitive` (20-30%) |
| **Tactique** | Animation offensive (sortie de balle, possession, transition off→déf, attaque placée), animation défensive (bloc, pressing, repli, marquage), schémas (1-4-3-3, 1-4-4-2, 1-3-5-2), coups de pied arrêtés, lecture du jeu, hors-jeu | Sensibilisé `recreational` (10-20%), dominant `regular` (30-40%), critique `competitive` (40-50%) |
| **Physique** | Endurance aérobie intermittente (Z2-Z3), capacité / puissance aérobie (Z4 30s/30s, 15s/15s), RSA (sprint répété), speed (sprint linéaire 5-30 m), agilité multi-directionnelle, force unilatérale, plyo, prévention (FIFA 11+ + NHE + CAE) | `beginner` 15-20% (préventif), `recreational` 20-25%, `regular` 25-30%, `competitive` 30-35% |
| **Mental** | Gestion erreurs (passe ratée, but encaissé), routines pré-match, focus collectif, communication tactique, gestion pression match charnière | Sensibilisé `recreational` (5%), travaillé `regular` (10-15%), critique `competitive` (15-20%) |

**Règle d'équilibre** : sur une semaine type, viser un mix (technique + tactique) = ~60-70% temps terrain, S&C off-pitch = 15-30% volume total selon niveau, mental intégré aux drills (pas une séance isolée sauf `competitive`).

---

## S&C football off-pitch (FIFA 11+ + NHE + CAE + force unilatérale + cardio intermittent)

Référentiel : **FIFA 11+ / F-MARC** + **Bompa Periodization** + **méta-analyses NHE / CAE 2016-2024**.

#### FIFA 11+ — TOUS niveaux, 2× / sem minimum, dès W1

Trois parties, 10-15 min, sans équipement (hors ballon).

**Partie 1 — Running (course lente + activation)** :
- Course en ligne droite vers l'avant et retour, 6-8 reps × 40 m (30 sec aller-retour).
- Course en ligne droite avec changement de hanches (ouverture / fermeture), 6 reps × 40 m.
- Course en zigzag (épaule épaule), 6 reps × 40 m.
- Course avec saut d'obstacle imaginaire, 6 reps × 40 m.
- Course rapide vers l'avant + retour à reculons, 6 reps × 40 m.

**Partie 2 — Force, Plyo, Equilibre (au sol)** :
- The Bench (planche statique), 3 sets × 20-30 sec → progression Bench dynamique 1 jambe levée.
- Sideways Bench (planche latérale), 3 sets × 20-30 sec par côté → progression dynamique.
- Hamstring (Nordic Hamstring Exercise) : 1 set × 3-5 reps W1-W3, → 3 sets × 8-10 reps W4+.
- Single Leg Stance (équilibre sur 1 jambe les yeux ouverts puis fermés), 2 sets × 30 sec par jambe → progression avec ballon partenaire.
- Squats : 2 sets × 10 reps → progression 1 jambe.
- Vertical Jumps : 2 sets × 10 reps → progression sauts latéraux ou box jumps.

**Partie 3 — Running (vitesse + cutting)** :
- Course rapide à travers le terrain, 6-8 reps × 40 m (RPE 7-8).
- Course shuttle (allers-retours 5-10 m), 6 reps.
- Course avec bonds de plant + cutting (changement de direction 90°), 6 reps × 40 m.

**Avant match** : parties 1 et 3 seulement (running, pas de force au sol).

#### Add-ons obligatoires `regular` / `competitive` (dès W3)

- **Nordic Hamstring Exercise (NHE)** : 1 → 3 sets × 5 → 8-12 reps progressifs sur 4 sem, 2-3 × / sem en pré-saison, 1× / sem en saison. Réduction blessures ischio -51%.
- **Copenhagen Adduction Exercise (CAE)** : 1 → 3 sets × 5 → 10-15 reps par jambe progressifs, 2-3 × / sem en pré-saison, 1-2× / sem en saison. Réduction pubalgie / adducteurs -33%.

#### Force unilatérale + core anti-rotation (off-pitch S&C)

- **Single-leg squat** ou **split squat bulgare**, 3 sets × 6-10 reps par jambe (`recreational`+).
- **Hip thrust** bipodal puis unilatéral, 3 sets × 8-12 reps.
- **Squat goblet** ou **squat barre** (`regular`+), 3 sets × 6-10 reps.
- **Soulevé de terre roumain** unilatéral léger (`regular`+), 3 sets × 8-10 reps par jambe.
- **Pallof press / anti-rotation**, 3 sets × 10-15 reps par côté.
- **Side plank with rotation**, 3 sets × 30-45 sec par côté.
- **Bird-dog**, 3 sets × 10 reps par côté.

#### Puissance / plyométrie

- **Box jump bas** (40-50 cm), 3 sets × 5-8 reps (`recreational`+).
- **Lateral bound** (saut latéral unilatéral), 3 sets × 4-6 reps par côté (`regular`+).
- **Med ball rotational throws**, 3 sets × 6-8 reps par côté (`regular`+).
- **Drop jump** (40-60 cm), 3 sets × 5-6 reps (`competitive` uniquement, après acquisition technique).
- **Bondissements horizontaux successifs**, 3 sets × 6-8 reps (`competitive`).

#### Cardio intermittent football-spécifique

- **30s/30s** : 30 sec course Z3-Z4 + 30 sec marche, 8-12 cycles × 2-3 séries, récup 3 min (`recreational`+).
- **15s/15s Buchheit** : 15 sec course Z4 + 15 sec marche, 12-15 cycles × 2-3 séries, récup 3 min (`regular`+).
- **RSA (Repeated Sprint Ability)** : 6-10 × 30 m départ arrêté ALL OUT, récup 20-30 sec, 2-3 séries, récup 4-5 min (`regular`+).
- **Petits jeux 3v3 / 4v4** sur 30×20 m, 4 × 3 min ON / 2 min OFF, RPE 8-9 (`regular`+).

**Règle volume S&C off-pitch** : `beginner` 0-1× / sem 30 min, `recreational` 1× / sem 45-60 min, `regular` 2× / sem 45-60 min en pré-saison + 1× / sem en saison, `competitive` 2-3× / sem 60 min pré-saison + 1-2× / sem en saison.

---

## Drapeaux rouges (safety)

Référence : FIFA 11+ + ACL Prevention reviews + Bahr & Holme (UEFA injury surveillance).

#### Tous niveaux

- **Entorse de cheville** : sport à très fort risque (changements direction, contact, surface variable). **Prévention** : crampons adaptés au terrain (FG terrain ferme / SG terrain souple / TF synthétique / IC indoor), proprio (single-leg balance, BOSU) 2× / sem, agilité progressive, FIFA 11+ partie 2 (single leg stance) dès W1. Reprise progressive après entorse, jamais de match direct sur cheville encore instable.
- **Blessure ischio-jambiers (HSI - Hamstring Strain Injury)** : LA blessure musculaire #1 en football (15-25% des blessures musculaires). Prévention : **NHE obligatoire dès W3 pour `regular` / `competitive`**, échauffement complet FIFA 11+ avant tout effort intense, hydratation, pas de sprint à froid. Si HSI passé < 12 mois → reprise progressive + NHE 3× / sem + éviter sprint max les 4 premières semaines.
- **Pubalgie / blessure adducteurs** : surcharge progressive, asymétrie force adducteurs. **Prévention CAE obligatoire dès W3 pour `regular` / `competitive`**. Si douleur pubienne > 2 semaines → consultation kiné avant reprise sprint et frappe puissance.
- **Genou — entorse LCA / LCP** : 4-8× plus fréquent chez femmes en pivot-cutting. **Prévention** : FIFA 11+ complet 2× / sem (réduction risque ACL -50%), proprio, force unilatérale, agilité progressive, éducation au cutting (genou dans l'axe). Si reprise post-LCA < 12 mois post-op → consultation médicale + protocole spécifique avant reprise compétition.
- **Genou — tendinite rotulienne / syndrome rotulo-fémoral** : sur volume sprint répété et plyo. Force quadriceps / fessier moyen, proprio, gestion charge.
- **Commotion cérébrale (concussion)** : choc tête-tête, tête-poteau, tête-genou. **Sortie immédiate du jeu** au moindre signe (céphalée, nausée, désorientation, perte connaissance même brève). Pas de retour au jeu le jour même. Protocole HIA + retour graduel sur 5-7 jours minimum (recommandation FIFA / IFAB).
- **Crampons inadaptés** : FG sur terrain souple → genou / cheville / surcharge ; SG sur synthétique → blocage et entorse cheville. Adapter aux conditions.

#### Recreational et au-delà

- **Tendinite Achille** : sur volume sprint répété + crampons trop rigides. Calf raises excentriques préventifs, mollets souples, gestion de charge progressive.
- **Lombalgie** : sur frappe puissance asymétrique, jeu de tête mal géré, gainage faible. Renforcement core anti-rotation, mobilité hanche, technique de frappe progressive.

#### Regular / Competitive

- **Pubalgie chronique** (> 4 sem) : signal d'alerte fort. Stop matchs, consultation kiné, CAE intensifié + repos sprint et frappe.
- **Surentraînement** : FC repos +10 bpm chronique, sommeil dégradé, perte motivation 3+ semaines, baisse perf en match.
- **Coup de chaleur** sur match été extérieur : hydratation 500-750 ml / h en chaleur > 25°C + sodium 300-700 mg/L, écouter signaux (céphalée, frissons, désorientation = STOP immédiat).

#### Competitive uniquement

- **RED-S** (Relative Energy Deficiency in Sport) : déficit énergétique sur volume haute intensité + déficit calorique. Sentinelles : aménorrhée (femmes), fatigue chronique, immunité dégradée.
- **Blessures musculaires de surcharge in-season** : fatigue cumulée micro-cycle 4 jours mal géré, sprint à froid en MD-1, manque de récupération MD+1.

---

## Substitutions classiques (alternatives v2)

Liste de remplacements réalistes pour l'algo deterministic Story 3.3a.

| Exercice planifié | Substitution | Trigger |
|---|---|---|
| Drill collectif avec opposition | Drill technique solo (passes contre mur, conduite cônes 30 m × 6 reps, frappe placée sur cible) | Pas de partenaire / pas de coéquipiers |
| Match amical 11v11 | Foot à 5 / 7 amical OU drill match-simulation 4v4 | Effectif insuffisant |
| Jeu réduit espace réduit (3v3 / 4v4) | Jeu réduit espace large (5v5 / 6v6) calme | Knee-flare / ankle-injury récent |
| RSA 30 m sprint | 15s/15s Buchheit Z4 footing intermittent | Surface dure (béton), fatigue, hamstring sensible |
| Frappe puissance répétée | Frappe placée précision (cible filet) | Hip flexor / lombaire sensible |
| Jeu de tête offensif / défensif | Drill volée pied / contrôle aérien sans tête | Antécédent commotion < 6 mois |
| FIFA 11+ partie 3 (cutting + sprint) | FIFA 11+ partie 1 + 2 + footing Z2 20 min | Reprise post-entorse cheville < 3 mois |
| Plyo plantain / drop jump | Squat unilatéral + lateral bound bas | Fatigue cumulée 3 sem, sommeil dégradé |
| NHE eccentric (`regular` / `competitive`) | Romanian deadlift unilatéral léger + glute bridge | Hamstring sensible W1-W2 (progression) |
| Séance terrain annulée (météo) | S&C off-pitch 60 min (FIFA 11+ + force unilatérale + cardio intermittent vélo / corde à sauter) | Pluie, terrain inutilisable |
| Stade / club fermé | Drill solo parc public + jeu de mur passes courtes | Pas d'accès terrain / club |
| Sprint répété | Vélo HIIT 30s/30s | ACL post-op < 12 mois ou hamstring HSI < 8 sem |

---

## EU MDR — Mots à bannir + medical clearance

Vocabulaire qui constituerait un acte médical en UE (Med Device Regulation 2017/745).

#### Bannis dans tout texte généré

- "soigner [pathologie]", "traitement [pathologie]", "guérir", "remède"
- "rééducation post-opératoire", "rééducation post-LCA", "post-blessure"
- "thérapie ACL", "cure", "diagnostic", "prescription", "ordonnance"
- "soulager [douleur]" → préférer "réduire l'inconfort", "favoriser le confort"
- "réparer le ligament / le muscle / le tendon" → préférer "renforcer", "stabiliser"
- "soigner la cheville", "soigner l'ischio" → préférer "renforcer la cheville", "préparer l'ischio à l'effort"

#### Triggers medical clearance obligatoire

Inclure mention "Consulte un médecin avant de commencer ce programme" dans `safety_notes` si :
- **Antécédents cardiaques** ou **profil débutant > 35 ans sans test effort récent** sur sprint intermittent / RSA (RPE 8-9) → `cardiac-clearance-required`.
- **Reprise post-LCA** récente (< 12 mois post-op) → consultation médicale + protocole spécifique kiné, pas de pivot-cutting tant que non validé.
- **Reprise post-entorse cheville / genou** récente (< 3 mois) → reprise progressive et consultation.
- **Antécédent HSI** (Hamstring Strain Injury) récent (< 8 sem) → reprise progressive, NHE intensifié, pas de sprint max les 4 premières semaines.
- **Pubalgie ou douleur adducteurs persistante** (> 2 sem symptômes) → consultation kiné avant reprise sprint et frappe puissance.
- **Antécédent commotion cérébrale** (< 6 mois) → consultation médicale, pas de jeu de tête.
- **Grossesse** ou postpartum (`pregnancy`, `postpartum-early`).
- Profil `beginner` > 50 ans débutant complet sans test effort récent.

---

## Hooks metadata standards (football)

#### `target_zone`
- `Z1`, `Z2`, `Z3`, `Z4` (zones FC, repère cardio)
- `RPE 5-6` (jeu réduit calme), `RPE 7-8 intermittent` (30s/30s, Z4 intermittent), `RPE 8-9 sprint` (RSA, sprint matchplay)
- `RPE 6-7`, `RPE 7-8` (renforcement off-pitch S&C)
- `technique` (drills moteurs purs : passe, contrôle, conduite, frappe)
- `tactique` (drills tactiques avec opposition modulée)
- `cool-down` (étirements / mobilité fin séance)

#### `required_equipment`

Vocabulaire kebab-case :
- `cleats` : crampons football OBLIGATOIRES pour toute séance terrain extérieur (FG / SG selon terrain).
- `indoor-shoes` : chaussures indoor / futsal pour séance gymnase ou foot à 5 indoor.
- `ball` : ballon football OBLIGATOIRE pour toute séance terrain.
- `field` : terrain football (gazon naturel / synthétique). Toute séance collective le requiert sauf substitution park / mur.
- `cones` : plots de marquage (drills agilité, conduite, slalom, délimitation).
- `agility-ladder` : échelle d'agilité (footwork off-pitch et drills déplacements).
- `mini-goals` : mini-buts (jeu réduit, drills finition).
- `training-bibs` : chasubles d'entraînement (jeu réduit avec opposition).
- `mannequins` : plots-mannequins (drills tactiques, schémas attaque, coups de pied arrêtés).
- `hurdles` : haies basses (plyo, agilité).
- `mat`, `resistance-band`, `medicine-ball`, `dumbbells`, `foam-roller` (S&C off-pitch).
- `partner` ou `team` : optionnel `beginner` (drills solo + mur OK), recommandé `recreational`+ (partenaire ou coéquipiers), attendu `regular` / `competitive` (collectif requis pour tactique).
- `coach` : optionnel `beginner` / `recreational`, recommandé `regular`, attendu `competitive`.

#### `incompatible_constraints`

Vocabulaire kebab-case :
- `knee-injury` (générique : tendinite rotulienne, syndrome rotulo-fémoral, ménisque)
- `acl-history` (antécédent rupture LCA, < 12 mois post-op = clearance obligatoire)
- `ankle-injury` (entorse récente < 3 mois)
- `hamstring-injury` (HSI Hamstring Strain Injury récent < 8 sem)
- `groin-injury` (pubalgie, blessure adducteurs)
- `lower-back-pain`
- `concussion-history` (antécédent commotion < 6 mois)
- `cardiac-clearance-required`
- `pregnancy`, `postpartum-early`
- `no-team-access` (impacte tactique collective, alternative drill solo / mur / partenaire)
- `no-field-access` (impacte tout, alternative parc / S&C off-pitch / mur)
- `no-coach`
- `outdoor-only`, `indoor-only` (préférence terrain)
- `synthetic-only`, `natural-grass-only` (préférence surface)

#### `alternatives`

Liste de noms d'exercices substitutifs (cf. tableau Substitutions ci-dessus). **Minimum 2 alternatives réalistes par exercice. `alternatives: []` vide INTERDIT — l'algo deterministic Story 3.3a en a besoin.**

#### `volume_axis`
- `duration` (drills minutés, séries d'intermittent chronométrés, échauffement, cool-down, jeu réduit)
- `sets` (séance structurée : `sets: 3` × `duration: "12 × 30s ON / 30s OFF"`, séries RSA, séries 15s/15s)
- `reps` (technique pure : `reps: "20 passes courtes par pied + 20 passes longues"`, frappes chiffrées, NHE / CAE chiffrés)

`distance` non applicable football (pas de distance pure pertinente — la distance couverte en match est un output, pas un input). `elevation` non applicable.

---

## `week_structure` typique par niveau

| Niveau | type | micro_pattern | recovery_cadence |
|---|---|---|---|
| **beginner** | `linear` | `terrain-technique + mobilité-renfo OU 2 terrain courtes` (2 séances) | `1 cutback W4-W5 sur plan 8 sem` |
| **recreational** | `linear` | `terrain-technique + terrain-jeu réduit + S&C off-pitch + match amical optionnel` | `1 deload toutes les 4 semaines` |
| **regular** | `block` | `MD-3 force + MD-2 résistance + MD-1 activation + match weekend + S&C off-pitch dédié` (Verheijen 4 jours) | `1 deload toutes les 3-4 semaines pré-saison ; in-season cutback naturel via récupération entre matchs` |
| **competitive** | `block` | `MD-3 force + MD-2 résistance + MD-1 activation + match + MD+1 récup + S&C off-pitch 2× + tactique vidéo` | `1 deload toutes les 3 semaines pré-saison + tapering match charnière` |

`deload_weeks` exemples :
- Plan 8 sem `beginner` : `[5]`
- Plan 10 sem `recreational` : `[4, 8]`
- Plan 12 sem `regular` (pré-saison + reprise saison) : `[4, 8]`
- Plan 16 sem `competitive` (pré-saison + 1er bloc saison) : `[4, 8, 12]` + taper match charnière distinct

---

## Lessons learned (issues du pilote running Phase B + spécifiques football)

1. **Convention volume harmonisée** : utiliser **heures terrain** + **heures S&C off-pitch** systématiquement dans `summary`, `weeks[i].goal`, `progression_logic`. Ne jamais mélanger avec "minutes match" (le match est un output, pas du volume).
2. **Ranges plutôt que chiffres faux** : "réduction ~15-20%", "75-85% LIT/technique", "8-12 km couvert / match" — préfère un range qu'un chiffre faux.
3. **Vérification arithmétique pré-rendu** : recompte volume hebdo pic (terrain + S&C), volume deload, durées des drills dans la séance phare. `summary` ↔ `goal` ↔ contenu réel cohérents ?
4. **Distribution 4 piliers nuancée** : si `competitive`, range 75-85% LIT/technique annoncé et phases pré-saison / saison explicitées. Si `beginner`, focus technique 60-70% et pas de RPE > 6.
5. **Cutbacks dans la fenêtre doctrine** : -15 à -20% standard, -25 à -30% accepté pour `beginner` low-volume seulement.
6. **`alternatives: []` vide INTERDIT** : chaque exercice a au moins 2 alternatives réalistes (substitution drill → mur ou solo, équipement → bodyweight équivalent, intensité → option plus douce).
7. **Mention FIFA 11+ obligatoire dans `safety_notes` à TOUS les niveaux dès W1.** NHE + CAE obligatoires `regular` / `competitive` dès W3.
8. **Pas de match compétitif chronométré pour `beginner`** — uniquement foot à 5 / 7 amical sans enjeu.
9. **Crampons et terrain** : toujours mentionner `cleats` + `field` (ou substitution `indoor-shoes` + indoor) dans `required_equipment` séance terrain. Adapter type de crampons (FG / SG / TF / IC) selon surface dans `notes`.
10. **EU MDR** : éviter "thérapie ACL", "soigner cheville", "rééducation post-LCA". Préférer "renforcer", "stabiliser", "préparer à l'effort".

---

## Sources

#### Doctrine et leveling
- [FIFA — Injury prevention and health promotion (FIFA 11+)](https://inside.fifa.com/health-and-medical/injury-prevention)
- [FIFA 11+: an effective programme to prevent football injuries (PMC narrative review)](https://pmc.ncbi.nlm.nih.gov/articles/PMC4413741/)
- [FIFA 11+ systematic review (BMC Sports Sci Med Rehabil)](https://link.springer.com/article/10.1186/s13102-017-0083-z)
- [FIFA 11+ Soccer Injury Prevention Program — booklet PDF](https://jacobstirtonmd.com/wp-content/uploads/2019/07/The-FIFA-11-Soccer-Injury-Prevention-Program.pdf)
- [Impact of FIFA 11+ on Injury Prevention (PMC systematic review)](https://pmc.ncbi.nlm.nih.gov/articles/PMC4245655/)
- [FIFA 11+ — Physiopedia](https://www.physio-pedia.com/The_F%C3%A9d%C3%A9ration_Internationale_de_Football_Association_FIFA_11+)
- [UEFA Coaching Licences — UEFA.com](https://www.uefa.com/development/coaches/uefa-coaching-licences/)
- [UEFA B Diploma — England Football Learning](https://learn.englandfootball.com/courses/football/uefa-b-licence)
- [UEFA A Diploma — England Football Learning](https://learn.englandfootball.com/courses/football/uefa-a-licence)
- [FFF DTN — Parcours de Formation Educateurs / Entraîneurs](https://www.fff.fr/fff/formations/educateurs-entraineurs)
- [FFF Brevet d'Entraîneur de Football (BEF)](https://www.fff.fr/articles/details-articles/143913-552411-brevet-dentraineur-de-football)
- [FFF Brevet de Moniteur de Football (BMF)](https://www.fff.fr/articles/details-articles/143914-552412-brevet-de-moniteur-de-football)

#### Périodisation football
- [The Original Guide to Football Periodisation Part 1 — Verheijen (Amazon)](https://www.amazon.com/Original-Guide-Football-Periodisation-Part/dp/949174500X)
- [Verheijen 2014 Football Periodisation PDF (Scribd)](https://www.scribd.com/document/472362372/VERHEIJEN-2014-Football-Periodisation-pdf)
- [Periodization Training for Sports — Bompa & Buzzichelli (Human Kinetics)](https://us.humankinetics.com/products/periodization-of-strength-training-for-sports-4th-edition)
- [Pre-season planning in football — complete guide (Zone14)](https://zone14.ai/en/blog/pre-season-planning-in-football/)
- [6 week pre-season fitness plan for amateur players (121 Personal Training)](https://121personaltraining.com/pre-season-training/)
- [Pre-season football training guide (KPI)](https://www.kingperformanceideology.com/advice-insights/the-complete-pre-season-football-training-guide)

#### Intensité, zones, RPE football
- [Training intensity distribution in elite football, polarised or not? (TopSportsLab)](https://www.topsportslab.com/training-intensity-distribution-in-elite-football/)
- [Performance Adaptations to Intensified Training in Top-Level Football (PMC / Springer)](https://pmc.ncbi.nlm.nih.gov/articles/PMC9667002/)
- [Training Zones for Football Fitness (Professional Soccer Coaching)](https://www.professionalsoccercoaching.com/aerobic-fitness-science/training-zones-for-football-fitness)
- [Exploring RPE Responses in Soccer (PMC)](https://pmc.ncbi.nlm.nih.gov/articles/PMC12590205/)
- [Application of Individualized Speed Zones to Quantify External Training Load in Soccer (PMC)](https://pmc.ncbi.nlm.nih.gov/articles/PMC7126260/)
- [Running Performance of Amateur Football Players in 1-4-3-3 (MDPI)](https://www.mdpi.com/2076-3417/14/16/7036)
- [I wore a GPS vest and compared my data to Premier League footballers (Planet Football)](https://www.planetfootball.com/in-depth/i-wore-a-gps-vest-and-compared-my-data-to-premier-league-footballers)

#### Prévention NHE / CAE / ACL
- [Effect of NHE Programs on Hamstring Injury Rates in Soccer — meta-analysis (PubMed)](https://pubmed.ncbi.nlm.nih.gov/27752982/)
- [Including the Nordic hamstring exercise in injury prevention (PubMed)](https://pubmed.ncbi.nlm.nih.gov/30808663/)
- [Combining CAE and NHE Improves Dynamic Balance — RCT (PMC)](https://pmc.ncbi.nlm.nih.gov/articles/PMC8558994/)
- [Implementing CAE and NHE in Academy Soccer Players (IJSPT)](https://ijspt.scholasticahq.com/article/123510)
- [Copenhagen Adduction Exercise meta-analysis on Sport Performance and Injury Prevention (PMC)](https://pmc.ncbi.nlm.nih.gov/articles/PMC12363431/)
- [ACL Injuries in Soccer Players: Prevention and Return to Play (PMC)](https://pmc.ncbi.nlm.nih.gov/articles/PMC10743334/)
- [Return to Play and Performance After ACL Reconstruction in Soccer Players — systematic review 2024 (Sports Medicine)](https://link.springer.com/article/10.1007/s40279-024-02035-y)
- [Return to Play Guidelines for Soccer Athletes after ACL Surgery (Shepard MD PDF)](https://www.michaelshepardmd.com/pdfs/return-to-play-guidelines-for-soccer-athletes-after-acl-surgery.pdf)
- [Injury-Proofing the Squad: Protocols for ACL Prevention in Soccer (ISSPF)](https://www.isspf.com/articles/injury-proofing-the-squad-protocols-for-acl-prevention-in-soccer/)
- [ACL Injury Prevention — Recognize to Recover (US Soccer)](http://www.recognizetorecover.org/acl-injury-prevention)
- [Sport-specific differences in ACL injury, treatment and return to sports: Football (PMC)](https://pmc.ncbi.nlm.nih.gov/articles/PMC12582233/)
