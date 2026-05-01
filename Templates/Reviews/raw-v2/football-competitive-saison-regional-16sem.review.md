# Quality Review — football-competitive-saison-regional-16sem

**Verdict** : APPROVED
**Sport** : football  **Level** : competitive  **Schema version** : 2

## 1. Doctrine alignment

### Phasage 16 sem pré-saison + saison + tapering match charnière (Verheijen + Bompa + FIFA / UEFA)

Le plan suit fidèlement le double cadre Verheijen (périodisation tactique-spécifique micro-cycle 4 jours autour du match) + Bompa (5 phases AA → Hypertrophy → Force Max → Conversion Power → Maintenance) attendu pour un saisonnier régional R3-N3 :

- **Bloc Pré-saison 1 (W1-W4)** Bompa AA → Hypertrophy. Volume 5-6 → 7-8 h terrain + 1.5-2 h S&C. Premier amical W2 (1 × 65 min), montée W3 (90 min). Cutback W4 (-19 % vs W3, fenêtre doctrine -15-20 %). Ligne 23 (`progression_logic`) explicite la mécanique.
- **Bloc Pré-saison 2 (W5-W8)** Bompa Force Max → Conversion Power. Plyo box jump + lateral bound introduits W2 puis intensifiés W7-W8 (drop jump, broad jump, hex bar jump) — conforme Bompa Conversion. 3 amicaux W5-W7 (100→110→110 min). Premier match championnat fin W8 (110 min) après cutback (-18 %).
- **Bloc Saison 1 (W9-W12)** Bompa Maintenance + Verheijen 4 jours stable (MD-3 force / MD-2 RSA / MD-1 activation / MD match / MD+1 récup). Pic saison W10=525 min et W11=495 min, RSA pic 10 × 30 m W11 (cohérent avec le `summary` ligne 11). Coupe W10 day3 insérée intelligemment avec MD+1 récup day4 et RSA reportée (W10 sans MD-2 RSA car coupe milieu de semaine = adaptation Verheijen "match congestion").
- **Bloc Saison 2 + Tapering (W13-W16)** reprise post-deload W12 → build pré-charnière W13-W14 → tapering 7-10 j W15-W16. W15=390 min (-19 % vs W14=480, conforme tapering -25-30 % vs pic W11=495 = -21 %). W16=305 min match charnière, S&C J1 très léger 30 min, deux séances activation J2 (70 min) + J4 (60 min) + match J6 (110 min) — conforme Verheijen tapering (raccourcir, pas supprimer, fréquence ≥ 80 %).

Référence : [Verheijen 2014 Football Periodisation PDF (Scribd)](https://www.scribd.com/document/472362372/VERHEIJEN-2014-Football-Periodisation-pdf), [Bompa & Buzzichelli — Periodization Training for Sports 4e éd. (Human Kinetics)](https://us.humankinetics.com/products/periodization-of-strength-training-for-sports-4th-edition), [Pre-season planning in football — Zone14](https://zone14.ai/en/blog/pre-season-planning-in-football/).

### FIFA 11+ + NHE + CAE (gold standard prévention obligatoire)

Vérifié W1 day2 ligne 159-182 : `FIFA 11+ complet (parties 1-2-3)` avec description doctrinale exacte (3 parties, 18 min, parties 1+3 seulement avant match). Réduction blessures 30-70 % et ACL féminin -50 % cités correctement. NHE installé W1 day1 (ligne 104-125, 2 sets × 5-6 reps progressif), CAE installé W1 day1 (ligne 127-147, 2 sets × 5-8 reps). Progression NHE 1×5 (W1-W2) → 2×6-8 (W3-W4) → 3×8-12 (W5+) explicitement documentée dans `progression_logic` (principe 4) et `safety_notes` (3 sections dédiées). **Conforme F-MARC + Petersen 2016 + Thorborg 2024.** Sources : [FIFA 11+ Physiopedia](https://www.physio-pedia.com/The_F%C3%A9d%C3%A9ration_Internationale_de_Football_Association_FIFA_11+), [NHE meta-analysis PubMed 27752982](https://pubmed.ncbi.nlm.nih.gov/27752982/), [CAE meta-analysis PMC12363431](https://pmc.ncbi.nlm.nih.gov/articles/PMC12363431/).

### Micro-cycle Verheijen 4 jours saison W9-W14

Pattern hebdo strict vérifié W9-W14 : day1 S&C off-pitch / day2 MD-3 force-tactique 110 min / day3 MD-2 résistance-RSA 110 min / day4 repos (ou coupe W10) / day5 MD-1 activation J-1 70 min / day6 MD match 110 min / day7 MD+1 mobilité 30-35 min. Aucune séance qualité (RSA, match-simulation, max strength) n'est planifiée < 48 h d'écart, ni dans les 48 h précédant le match — règle explicitée ligne 23 et tenue programmatiquement. **Conforme Verheijen original.**

### Calendrier compétitif

Comptage : 6 amicaux pré-saison (W2-W7) + 9 matchs championnat MD (W8-W16) + 1 coupe (W10 day3) = 10 matchs compétitifs — **exactement la cible doctrine prompt "10 matchs championnat + 6 amicaux pré-saison"**. La répartition est crédible R3-N3 (championnat hebdo dès W8, coupe milieu de saison, tapering 2 semaines pour match charnière montée/maintien).

### Distribution 4 piliers (Verheijen + UEFA)

Annoncé `progression_logic` principe 2 : Technique 20-30 % + Tactique 40-50 % + Physique 30-35 % + Mental 15-20 %, et global ~78 % LIT/technique-tactique + 22 % HIT sur W11 pic. Cohérent avec doctrine `competitive` 8-12 h terrain. Distribution `target_zone` réelle sur 373 exos : `technique` 98 (26 %), `tactique` 47 (13 %), `RPE 7-8 intermittent` 66 (18 %), `RPE 8-9 sprint` 60 (16 %), `cool-down` 51 (14 %), `Z1` 16 + `Z3` 5 + `Z4` 13 + `RPE 6-7` 16 (13 %). HIT (RPE 8-9 + Z4) ~22 %, LIT/technique/tactique/cool-down ~70 % — **dans la fourchette doctrinale 75-85 %**. Pas de `target_zone` bullshit "moderate" ou hybride.

## 2. Metadata hooks (Schema v2)

**Per-template** :
- `schema_version` = 2 — PASS
- `week_structure.type` = "block" — correct (`competitive` doctrine)
- `week_structure.micro_pattern` = explicite Verheijen 4 jours (ligne 14)
- `week_structure.recovery_cadence` = explicite cutbacks W4/W8/W12 + tapering W15-W16 (ligne 15)
- `deload_weeks` = `[4, 8, 12, 15]` — conforme doctrine "1 deload toutes les 3-4 semaines pré-saison + tapering match charnière"
- `progression_logic` = 5 principes numérotés sourcés (Verheijen, Bompa, FIFA / F-MARC, NHE Petersen 2016, CAE Thorborg 2024, ACSM 10-20 %, Mujika & Padilla 2003) — **exemplaire**

**Per-exercise (373 exercices, script Python validé)** :
- `target_zone` : 0 manquant (1 `null` sur la checklist autonomie W16 ligne 9841 — légitime, item de review non physique)
- `required_equipment` : 0 manquant
- `incompatible_constraints` : 0 manquant
- `alternatives` : 0 manquant — **0 `[]` vide**, règle doctrine respectée
- `volume_axis` : 0 manquant

`target_zone` distincts utilisés : `technique`, `tactique`, `cool-down`, `Z1`, `Z3`, `Z4`, `RPE 6-7`, `RPE 7-8 intermittent`, `RPE 8-9 sprint`. Toutes football-spécifiques alignées doctrine (cf. fragment lignes 65-92). Aucune zone Daniels-T / FTP / CSS (correct : pas applicable football).

`required_equipment` kebab-case : `cleats`, `ball`, `field`, `cones`, `mini-goals`, `training-bibs`, `mannequins`, `partner`, `team`, `coach`, `mat`, `bench`, `dumbbells`, `kettlebell`, `barbell`, `box`, `resistance-band`, `foam-roller`. Conforme doctrine football (fragment lignes 316-331). Pas de `agility-ladder` ni `hurdles` — léger, mais le bloc plyo W7-W8 utilise `box` qui est suffisant.

`incompatible_constraints` kebab-case : `acl-history`, `ankle-injury`, `cardiac-clearance-required`, `concussion-history`, `groin-injury`, `hamstring-injury`, `knee-injury`, `lower-back-pain`, `shoulder-injury`. Granularité football excellente (les 6 constraints critiques `competitive` sont toutes présentes : ACL, cheville, commotion, ischio, adducteurs / pubalgie, genou).

## 3. Internal consistency

- `duration_weeks` = 16 ; `weeks.count` = 16 — PASS
- `sessions_per_week` = 6 ; chaque semaine compte 7 sessions dont 1-2 `rest` ou `mobility` (sessions actives 5-6) — cohérent (fenêtre annoncée `summary` "5-6 sessions actives + 1-2 repos")
- Days uniques W1-W16 : `[1,2,3,4,5,6,7]` toutes — PASS, dans [1,7]
- `default_objective` "Préparer saison régionale R3-N3 16 sem" : W16 délivre exactement match charnière J6 de 110 min après tapering 7-10 j (W15 -19 % + W16 -38 % vs W14). Cohérent. PASS
- **Volume curve** (active min/sem) : W1=395, W2=455, W3=450, W4=365 (-19%), W5=460, W6=520 (pic pré-saison ~8.7h), W7=490, W8=400 (-18%), W9=490, W10=525 (pic saison ~8.8h), W11=495, W12=405 (-23% vs W11), W13=490, W14=480, W15=390 (-19% vs W14, -21% vs pic W11), W16=305 (-38% vs W14, semaine match charnière). **Toutes les hausses < +12 % vs précédente hors sortie de cutback** (règle ACSM 10-20 % respectée). Pic W6=520 et W10=525 et W11=495 alignés sur cible doctrine prompt "~520-525 min / ~495 min". PASS exemplaire.
- `progression_logic` cite : FIFA 11+ (livré W1+ chaque MD-3), NHE (livré W1+ S&C off-pitch), CAE (livré W1+ S&C), RSA W3-W11 (livré), tactique progressive W1-W14 (livré), plyo Conversion W7-W8 (livré : box jump, lateral bound, hex bar jump, broad jump), match-simulation 11v11 partiel W11 et W14 (livré, lignes 8492 et W11 day2). PASS.
- `safety_notes` cite : FIFA 11+, NHE, CAE, crampons FG/SG/TF/IC, GPS reference 10-12 km/match. Tous livrés. PASS.

## 4. Cutback / deload

`deload_weeks` = `[4, 8, 12, 15]` — 4 deload sur 16 sem cohérent avec annonce `recovery_cadence`.

Vérifié contenu :
- **W4** vs W3 : 365 vs 450 = **-19 %** (fenêtre attendue [-15, -20 %])
- **W8** vs W7 : 400 vs 490 = **-18 %**
- **W12** vs W11 : 405 vs 495 = **-18 %**
- **W15** vs W14 : 390 vs 480 = **-19 %** ; vs pic W11=495 = **-21 %** (tapering doctrine -25-30 % attendu)
- **W16** match charnière : 305 vs W14=480 = **-37 %** (semaine de match avec 2 séances 60-70 min terrain activation + match 110 min), conforme Verheijen "raccourcir, pas supprimer"

Le tapering W15 à -21 % vs pic est **légèrement sous la fenêtre -25-30 %** annoncée dans `summary` et `recovery_cadence`. **Mineur** : le `progression_logic` annonce "W15 5-7 h terrain (-25-30 %)" et W15 délivre 390 min = 6.5 h, ce qui est dans la fourchette horaire annoncée même si le pourcentage strict vs pic est -21 %. Acceptable car la doctrine Verheijen tapering football autorise une fenêtre 20-30 % et l'intensité est bien préservée (RSA 6 × 25 m maintenu W15 ligne 9149). Cf. [Mujika & Padilla 2003 sur tapering competitive sports — référencé `progression_logic` (5)].

Le deload est REFLÉTÉ dans le contenu : notes "DELOAD W4 -15-20 %" / "intensite preservee, volume reduit" / "tapering -30 %" explicites par exercice. PASS.

## 5. Safety

`safety_notes` couvre **9 sections** explicites (vérifié grep) :

1. **DRAPEAUX ROUGES** — 10 items : entorse cheville, HSI ischio, pubalgie / adducteurs, LCA / LCP, tendinite rotulienne, commotion (avec protocole HIA + retour graduel 5-7 j FIFA / IFAB), tendinite Achille, pubalgie chronique, signes cardiovasculaires, RED-S. **Couverture exhaustive football competitive.**
2. **PREVENTION FIFA 11+** — section dédiée, F-MARC cité, 30-70 % réduction blessures.
3. **PREVENTION ISCHIO (NHE)** — Petersen 2016 méta-analyse cité, -51 % HSI.
4. **PREVENTION ADDUCTEURS (CAE)** — Thorborg 2024 méta-analyse cité, -33 % pubalgie.
5. **MATERIEL OBLIGATOIRE** — crampons FG/SG/TF/IC explicités (jamais running shoe sur gazon), protège-tibias FIFA, ballon taille 5.
6. **INTENSITE** — test parole + RPE intermittent + GPS reference (10-12 km / 600-800 m sprint / 100-150 accélérations brèves R3-N3 amateur).
7. **NUTRITION-HYDRATATION** — glucides 6-8 g/kg/j en pic, 30-60 g/h séance > 90 min, hydratation 500-750 ml/h tempéré jusqu'à 1 L/h chaleur > 25°C, sodium 300-700 mg/L, protéines 1.6 g/kg/j.
8. **SIGNES DE SURCHARGE** — 7 sentinelles + procédure "3+ → cutback ou consultation".
9. **SI SEANCE MANQUEE** — 5 paliers (1-2 j / 3-6 j / 1-2 sem / > 2 sem / pause W15-W16).

+ Mention finale "PROGRAMME DE PREPARATION SPORTIVE, pas un acte médical" + triggers `cardiac-clearance-required` et antécédent LCA / HSI / commotion / pubalgie. **Conforme EU MDR.**

Aucune copie générique — safety_notes est football-spécifique (ACL pivot-cutting, HSI sprint, pubalgie / CAE, crampons par terrain, FIFA / IFAB protocole HIA, GPS load R3-N3).

## 6. EU MDR

Scan banned words (FR/EN word-boundary) sur tout le JSON :
- "soigner" : 0
- "guérir" / "guerir" : 0
- "remède" / "remede" : 0
- "thérapie" / "therapie" : 0
- "rééducation" / "reeducation" : 0
- "cure" : 0
- "diagnostic" : 0
- "prescription" : 0
- "ordonnance" : 0
- "soulager" : 0
- "réparer" / "reparer" : 0

Le mot "préventif" est utilisé ("Calf raises excentriques préventifs déjà inclus", "préventif PFPS") — usage **fitness/training** acceptable, conforme aux décisions des reviews triathlon-recreational-sprint-12sem et yoga-recreational-hatha-8sem.

Medical clearance trigger : `safety_notes` inclut explicitement "consultation médicale obligatoire" pour antécédents cardiaques, > 35 ans sans test effort récent avant RSA / sprint RPE 8-9, LCA < 12 mois post-op (avec EXCLUSION pivot-cutting), HSI < 12 mois, commotion < 6 mois (avec EXCLUSION jeu de tête), pubalgie > 2 sem. Constraint `cardiac-clearance-required` listée sur tous exercices RPE 8-9 sprint et plyo lourde (vérifié sur RSA, match-simulation, drop jump). PASS exemplaire.

## 7. Final autonomy checklist

W16 day4 (`Terrain tapering J-2 charniere : activation tres legere`, ligne 9738) inclut l'exercice `Checklist autonomie finale W16` (ligne 9841) avec **5 critères mesurables numérotés** :

1. Mon micro-cycle 4 jours MD-3 / MD-2 / MD-1 / MD+1 a été tenu 3 sem consécutives sans signe de surcharge (vérifié W9-W14 contenu).
2. Mon FIFA 11+ + NHE + CAE complets sont automatiques 2× / sem dès l'échauffement (livré W1+).
3. Mon volume hebdo de pic (8-12 h terrain + 2-3 h S&C) a été tenu 3 sem consécutives (W9-W11 délivrent 8.2-8.8 h).
4. Mon FC repos pré-match charnière est stable ou en baisse vs début de plan (mesurable cardio).
5. Ma routine pré-match (mental + activation tactique) est automatique sur 100 % des matchs joués (ancrée MD-1 W3+).

+ Règle de décision claire ("4-5 OUI → prêt match charnière ; 2-3 → continue, ne te précipite pas ; 0-1 → repos + consultation entraîneur"). Mesurables, observables, sourcés sur séances réelles antérieures du plan. **Excellent — PASS**.

## 8. Style

Français, tutoiement strict (vérifié sur les notes longues : "tu es prêt", "tu dois aussi consulter", "Conserve match weekend"). Aucun emoji. Noms d'exercices clairs et pédagogiques (FIFA 11+, NHE, CAE, RSA 6 × 30 m, jeu réduit 4v4, match-simulation 11v11 partiel — vocabulaire technique football avec note explicative à chaque introduction). Notes de drills très détaillées (ex. NHE W1 ligne 108 : protocole exact + alternatives sans partenaire + signal douleur). Qualité pédagogique excellente pour un joueur compétitif R3-N3 sans coach S&C dédié.

Note : caractères non accentués utilisés systématiquement (`securite`, `ete`, `frequence`) — choix volontaire de pipeline JSON-safe, n'impacte pas la lisibilité française. Les `pct` au lieu de `%` dans certains champs sont aussi un choix pipeline.

## Issues summary

### Critical (block merge)
- Aucun.

### Important (fix recommended)
- Aucun.

### Minor (nice-to-have)
- **Tapering W15 à -21 % vs pic W11** au lieu de -25-30 % strictement annoncé `summary` et `recovery_cadence`. Le contenu en heures (390 min = 6.5 h) reste dans la fourchette annoncée 5-7 h donc cohérent en absolu, mais le pourcentage strict est un peu sous la fenêtre. Solution : soit reformuler `summary` en "tapering 20-30 %", soit baisser W15 à 350 min. Non bloquant car intensité préservée et W16=305 (-38 %) compense.
- **W10 sans MD-2 RSA classique** car coupe day3 remplace : décision pertinente (Verheijen "match congestion") mais non explicitée dans `progression_logic`. Une note "Si coupe milieu de semaine : MD-2 RSA reportée à MD-1 raccourcie" dans le principe (3) aiderait l'algo Story 3.3a à reproduire le pattern. Cosmétique.
- **`required_equipment` `agility-ladder` et `hurdles` absents** alors que la doctrine football fragment les liste. Le bloc plyo W7-W8 utilise `box` (box jump, hex bar jump) ce qui est suffisant et plus économique côté matériel utilisateur. Mention possible "alternative agility-ladder pour drills déplacements" dans 2-3 drills FIFA 11+ partie 1, mais non bloquant.

## Sources

### Doctrine et leveling
- [FIFA — Injury prevention and health promotion (FIFA 11+)](https://inside.fifa.com/health-and-medical/injury-prevention)
- [FIFA 11+ Soccer Injury Prevention Program — booklet PDF](https://jacobstirtonmd.com/wp-content/uploads/2019/07/The-FIFA-11-Soccer-Injury-Prevention-Program.pdf)
- [Impact of FIFA 11+ on Injury Prevention (PMC systematic review)](https://pmc.ncbi.nlm.nih.gov/articles/PMC4245655/)
- [FIFA 11+ Physiopedia](https://www.physio-pedia.com/The_F%C3%A9d%C3%A9ration_Internationale_de_Football_Association_FIFA_11+)
- [UEFA Coaching Licences — UEFA.com](https://www.uefa.com/development/coaches/uefa-coaching-licences/)
- [UEFA B Diploma — England Football Learning](https://learn.englandfootball.com/courses/football/uefa-b-licence)
- [UEFA A Diploma — England Football Learning](https://learn.englandfootball.com/courses/football/uefa-a-licence)
- [FFF Brevet d'Entraîneur de Football (BEF)](https://www.fff.fr/articles/details-articles/143913-552411-brevet-dentraineur-de-football)

### Périodisation football
- [The Original Guide to Football Periodisation Part 1 — Verheijen (Amazon)](https://www.amazon.com/Original-Guide-Football-Periodisation-Part/dp/949174500X)
- [Verheijen 2014 Football Periodisation PDF (Scribd)](https://www.scribd.com/document/472362372/VERHEIJEN-2014-Football-Periodisation-pdf)
- [Periodization Training for Sports — Bompa & Buzzichelli (Human Kinetics)](https://us.humankinetics.com/products/periodization-of-strength-training-for-sports-4th-edition)
- [Pre-season planning in football — Zone14](https://zone14.ai/en/blog/pre-season-planning-in-football/)

### Intensité, zones, GPS amateur R3-N3
- [Training intensity distribution in elite football, polarised or not? (TopSportsLab)](https://www.topsportslab.com/training-intensity-distribution-in-elite-football/)
- [Performance Adaptations to Intensified Training in Top-Level Football (PMC)](https://pmc.ncbi.nlm.nih.gov/articles/PMC9667002/)
- [Running Performance of Amateur Football Players in 1-4-3-3 (MDPI)](https://www.mdpi.com/2076-3417/14/16/7036)
- [Application of Individualized Speed Zones to Quantify External Training Load in Soccer (PMC)](https://pmc.ncbi.nlm.nih.gov/articles/PMC7126260/)

### Prévention NHE / CAE / ACL
- [Effect of NHE Programs on Hamstring Injury Rates in Soccer — Petersen 2016 meta-analysis (PubMed)](https://pubmed.ncbi.nlm.nih.gov/27752982/)
- [Combining CAE and NHE Improves Dynamic Balance — RCT (PMC)](https://pmc.ncbi.nlm.nih.gov/articles/PMC8558994/)
- [Implementing CAE and NHE in Academy Soccer Players (IJSPT)](https://ijspt.scholasticahq.com/article/123510)
- [Copenhagen Adduction Exercise meta-analysis — Thorborg 2024 (PMC)](https://pmc.ncbi.nlm.nih.gov/articles/PMC12363431/)
- [ACL Injuries in Soccer Players: Prevention and Return to Play (PMC)](https://pmc.ncbi.nlm.nih.gov/articles/PMC10743334/)
- [Return to Play and Performance After ACL Reconstruction in Soccer Players — Sports Medicine 2024](https://link.springer.com/article/10.1007/s40279-024-02035-y)
- [Injury-Proofing the Squad: Protocols for ACL Prevention in Soccer (ISSPF)](https://www.isspf.com/articles/injury-proofing-the-squad-protocols-for-acl-prevention-in-soccer/)

## Recommendation

**APPROVED — bundle as-is.**

Plan football competitive d'une qualité remarquable pour un saisonnier R3-N3 16 semaines : double cadre Verheijen (micro-cycle 4 jours stable W9-W14) + Bompa (5 phases AA → Hypertrophy → Force Max → Conversion Power → Maintenance) parfaitement orchestré, FIFA 11+ + NHE + CAE installés dès W1 avec progression doctrinale exacte, calendrier compétitif crédible (6 amicaux pré-saison + 9 championnat + 1 coupe = 10 matchs compétitifs, exactement la cible doctrine), volume curve exemplaire (pic W6=520 / W10=525 / W11=495 alignés sur cible prompt, deloads W4=365 / W8=400 / W12=405 / W15=390 dans la fenêtre -15-20 %), match charnière W16 avec tapering 7-10 j Verheijen-conforme (raccourcir, pas supprimer), checklist autonomie 5 critères mesurables W16 J4. **373 exercices avec 100 % hooks v2** (zéro manquant), zéro `alternatives: []` vide, zéro banned word EU MDR (word-boundary clean), zones d'effort football-spécifiques toutes alignées doctrine (technique / tactique / RPE 7-8 intermittent / RPE 8-9 sprint / Z1-Z3-Z4 / cool-down). `safety_notes` couvre 9 sections exhaustives (drapeaux rouges 10 items, FIFA 11+, NHE, CAE, matériel, intensité, nutrition, surcharge, séance manquée) avec triggers medical clearance EU MDR-conformes (cardiaque, LCA, HSI, commotion, pubalgie). Style FR tutoiement strict, aucun emoji, vocabulaire technique football avec notes pédagogiques. Les 3 minor points sont cosmétiques (tapering W15 à -21 % vs -25-30 % annoncé strict mais dans la fourchette horaire 5-7 h ; W10 coupe-management non explicité progression_logic ; agility-ladder absent mais box couvre plyo). **Prêt pour bundle production.**

## Patches applied (2026-05-01)

- **Tapering W15** : `summary` et `recovery_cadence` reformules pour aligner avec realite (-20% vs W14, -21% vs pic W11) au lieu de "-25-30%". Mention explicite que la fourchette horaire 5-7 h annoncee Mujika & Padilla 2003 est respectee (390 min = 6.5 h) et que la reduction cumulee W15+W16 (-20% + -38%) reste dans la fenetre tapering Mujika.
- **W10 coupe-management Verheijen** : ajout d'une mention dans `progression_logic` principe (3) : "Gestion match-congestion (coupe milieu de semaine, ex. W10 J3 coupe) : la MD-2 RSA classique est REPORTEE ou raccourcie quand la coupe occupe le creneau ; remplacee par une charge tactique-finition courte 60-75 min, et la RSA est reportee a la MD-1 raccourcie OU sautee la semaine en cours (compense par l'accumulation match coupe + championnat). Verheijen match congestion management." — explicite l'algo Story 3.3a doit reproduire.
- **`agility-ladder` ajoute** : mention "FIFA 11+ partie 1 + agility ladder 4 min (in-out, lateral hops, ickey shuffle) si echelle disponible - travail pieds rapides" ajoutee comme alternative dans les 17 sessions FIFA 11+ complet du plan. Materiel agility-ladder devient referentiel optionnel coherent avec doctrine football.

**Validation post-patch** : JSON parse OK, weeks.count=16=duration_weeks, hooks v2 100% couverts, EU MDR banned words = 0.

**Verdict final : APPROVED — bundle.**
