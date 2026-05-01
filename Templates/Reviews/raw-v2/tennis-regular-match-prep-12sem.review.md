# Quality Review — tennis-regular-match-prep-12sem

**Verdict** : APPROVED
**Sport** : tennis  **Level** : regular  **Schema version** : 2

## 1. Doctrine alignment

### Niveau ciblé NTRP 3.5-4.5 / FFT 30/1-15/4

`assumed_profile` (ligne 10) cible explicitement NTRP 3.5-4.5 / FFT 30/1-15/4, joueur 2+ ans interclubs / tournois loisirs, échange fond de court 15+ coups, premier service en jeu 55-65%, maîtrise grip continental + eastern + semi-western. C'est exactement la bande "advanced intermediate" du fragment doctrine tennis.md (ligne 12). Les descripteurs USTA NTRP 4.0 ("dependable strokes... uses lobs, overheads, approach shots, volleys with success") et 4.5 ("aggressive net play, has good anticipation, frequently has a strong serve with first and second serve placement") sont les ancres correctes pour un programme de **préparation match**. [USTA NTRP](https://www.usta.com/en/home/coach-organize/tennis-tool-center/run-usta-programs/national/understanding-ntrp-ratings.html), [FFT classement](https://www.fft.fr/actualites/decouvrez-votre-classement-tennis)

### Volume hebdo 4.5-7 h court + 1-1.5 h S&C — CONFORME doctrine regular

Doctrine tennis.md ligne 76 : `regular` 4.5-7 h court + 1-1.5 h S&C dédié, 4-5 séances / sem. Template tient 4 séances strictes (3 court + 1 S&C). Volume pic W7-W10 = 100 min set + 90+90 = 280 min court + 60 min S&C ≈ **5.7 h court / sem** au pic, conforme cible. W6-W7 monte à 95-100 min set entraînement, ce qui correspond à la "séance phare 90 min court avec drills tactiques + 1 set d'entraînement complet" du fragment ligne 82.

### Mix 4 piliers regular (Technique 20-30% / Tactique 30-40% / Physique 25-30% / Mental 10-15%)

`progression_logic` (ligne 22) déclare explicitement la distribution. Estimation par phase :
- W1-W4 (foundation) : Technique 40% / Tactique 25% / Physique 25% / Mental 10% — focus régularité fond de court + service-retour patterns 1-2 coups + S&C foundation. **Léger sur-poids technique en phase 1, défendable** (cohérent "PHASE 1 TECHNIQUE" du progression_logic ligne 22).
- W5-W8 (tactique) : Technique 25% / Tactique 35% / Physique 25-30% / Mental 10% — drills 3-coups + sprint matchplay + sets 4-5 jeux. ✓
- W9-W12 (match play) : Technique 20% / Tactique 40% / Physique 25% / Mental 15% (rituels pré-service + scénarios pression + simulation interclubs). ✓

Mix conforme cible Kovacs/Roetert/Ellenbecker [Complete Conditioning for Tennis 2E](https://us.humankinetics.com/products/complete-conditioning-for-tennis-2nd-edition-with-hkpropel-online-video).

### Drills / match-play ratio + endurance + lateral agility + serve power

- **Drills tactiques 3-coups** (cross-cross-long de ligne, service+1er+2e coup) : présents W5-W11 systématiquement (ex. W5 D1 ligne 1990, W11 D1 ligne 4940). ✓
- **Sets entraînement** : intro W2 set partiel 4 jeux (ligne 784), W3 set 5 jeux (ligne 1277), W7 set complet 6 jeux + 2e set partiel (ligne 3191 = 100 min), W11 set 6 jeux + set partiel (ligne 5151). Cadre **"2 sets / sem en pré-match"** du progression_logic ligne 22 respecté W9-W11.
- **On-court endurance** : drill panier match-simulation 11 points + drill side-to-side panier explosif RPE 8-9 (ligne 2094 W5 intro, maintenu W6/W7/W9/W10/W11). Cardio intermittent S&C (sprint 15-25 m + récup 30-60 sec). Ratio effort:récup 1:1 à 1:3 cohérent USTA Kovacs.
- **Lateral agility** : agility ladder (in-out, lateral icky shuffle, cross-over step, back-pedal) W1-W11 + lateral bound dès W3 (ligne 1429) + box jump 40-50 cm. Parfaitement aligné "Agilité 6 directions" doctrine ligne 140-148.
- **Serve power** : med ball overhead slam intro W5 + med ball rotational throws W3+ (ligne 5328 W11 maintien). Aligné "Puissance / plyométrie" doctrine ligne 161-166.

### Cutbacks W4 + W8 + W12 = 3 deload sur 12 sem

Doctrine ligne 100 + 311 : `regular` 3 build + 1 deload (-15 à -20%), plan 12 sem `[4, 8, 12]` typique. Template `deload_weeks: [4, 8, 12]` (ligne 17-21). **CONFORME**. W12 fonctionne comme match week (taper J-7 → J-1). Pattern 3-1-3-1-3-1 = **textbook block periodization tennis**.

### Tapering W12 (J-14 / J-7 / J-3 / J-1)

Doctrine ligne 105-109 : J-14 ~70% pic, J-7 ~50-60% pic, J-3 à J-1 séances 45-60 min court drills techniques + 0 S&C lourd. Template W12 : J-7 (D1) 60 min court (ligne 5390), J-5 (D3) 60 min match-test set 6 jeux (ligne 5493), J-3 (D5) 50 min court taper (ligne 5573), J-1 (D7) 40 min court light (ligne 5652). **Pattern correct**. Volume W12 ~210 min vs pic ~340 min = **-38%**. Cohérent doctrine "≥80% des sessions habituelles, raccourcir pas supprimer" (ligne 109) : 4 sessions court vs 4 court + 1 S&C habituel = -1 séance S&C, fréquence court préservée à 100%.

### Préventif coiffe rotateurs + scapulaire dès W1

Y-T-W + external rotation à la bande + Pallof + split squat bulgare + hip thrust unilatéral présents dès W1 D6 (lignes 366-460). Maintenus toutes les semaines, prone scaption ajouté W3+ (ligne 1352), med ball rotational throws W3+, lateral bound + box jump dès W3. **PASS catégorique** sur le pilier "regional interdependence" rotator-cuff ↔ tennis elbow (PMC review).

## 2. Metadata hooks (Schema v2)

### Per-template
- `week_structure` (ligne 12-16) : ✓ type `block`, micro_pattern explicite, recovery_cadence cite W4/W8/W12 et match week.
- `deload_weeks: [4, 8, 12]` (ligne 17-21) : ✓
- `progression_logic` (ligne 22) : ✓ 5 principes sourcés ITF + USTA NTRP + FFT + Kovacs-Roetert-Ellenbecker + Aubone.

### Per-exercise — audit 12 semaines

Comptage automatique : `target_zone`, `required_equipment`, `incompatible_constraints`, `alternatives`, `volume_axis` apparaissent **217 fois chacun** (symétrie parfaite). Tous les exercices ont les 5 hooks v2.

- `target_zone` : valeurs cohérentes (`Z2`, `Z3`, `RPE 5-6`, `RPE 6-7`, `RPE 7-8`, `RPE 8-9`, `technique`). Pas de "moderate" générique.
- `required_equipment` : kebab-case respecté (`racket`, `balls`, `tennis-shoes`, `court`, `wall`, `cones`, `agility-ladder`, `mat`, `resistance-band`, `dumbbells`, `medicine-ball`).
- `incompatible_constraints` : kebab-case (`shoulder-injury`, `tennis-elbow`, `wrist-pain`, `lower-back-pain`, `knee-injury`, `ankle-injury`, `cardiac-clearance-required`).
- `alternatives` : 2 alternatives par exo, formulations terrain (drill mur / ball-machine / ghost-stroking / variantes bodyweight ou dumbbell léger). Aucun `alternatives: []` vide.
- `volume_axis` : `duration` / `sets` / `reps` cohérent avec spec exo.

### Issue mineure — `box` non listé dans le vocabulaire doctrine

7 occurrences de `"box"` (lignes 1456, 2402, 2923, 3423, 4354, 4855, 5355) sur exos box jump 40-50 cm. La doctrine ligne 256-266 liste `agility-ladder`, `cones`, `mat`, `resistance-band`, `medicine-ball`, `dumbbells`, `foam-roller` mais **pas `box`** (ni `box-jump-platform`). À harmoniser : soit ajouter `box` au vocabulaire doctrine, soit utiliser `bench` ou `step` (terme générique). Pas bloquant pour l'algo Story 3.3a tant que la convention reste cohérente intra-template, mais **à clarifier** dans le master prompt regen.

## 3. Internal consistency

| Check | Result |
|---|---|
| `duration_weeks == weeks.count` | ✓ 12 == 12 |
| `sessions_per_week == 4` respecté | ✓ W1-W11 : 4 sessions actives (3 court + 1 S&C) ; **W12 : 4 court + 0 S&C** (-1 S&C par taper, OK doctrine) |
| Days uniques [1,7] dans chaque semaine | ✓ pattern J1/J3/J5/J6 standard, W12 = J1/J3/J5/J7 |
| Volume curve W1→W3 build, W4 cutback, W5→W7 build, W8 cutback, W9→W11 pic, W12 taper | ✓ 320→325→330 / **250 cutback** / 330→335→340 / **285 cutback** / 340→340→315 / **210 taper** |
| Cutback W4 magnitude | -24% vs W3 (250 vs 330 min) — **conforme range -15 à -25%** |
| Cutback W8 magnitude | -22% vs W7 (285 vs 365 min — W7 D5 set 100 min) — **conforme** |
| Peak session W11 = match-simulation set 6 jeux + set partiel 4 jeux | ✓ ligne 5151 set complet 35 min + ligne 5176 set partiel 20 min ; total D5 = 90 min |
| Match-test simulation interclubs W12 D3 | ✓ ligne 5521 (set 6 jeux conditions match, scénarios pression) |
| Autonomie checklist W12 | ✓ 5 critères dans `goal` ligne 5384 |
| Equipment ⊆ assumed_profile + alternatives | ✓ raquette / balles / chaussures / court annoncés + cônes / agility-ladder / dumbbells / medicine-ball / mat / resistance-band dans S&C |
| Sprint matchplay RPE 8-9 max 1×/sem dès W5 | ✓ W5 D3 (ligne 2094), W6 D3, W7 D3, W9 D3, W10 D3, W11 D3 (volume modéré 4 séries pré-match), pas plus de 1 par semaine |

**Inconsistance mineure** : `goal` W12 ligne 5384 annonce "30 min S&C" mais aucune session S&C dédiée n'est définie en W12 (seulement 4 sessions court + 3 rest days). Le `progression_logic` ligne 22 mentionne pourtant "J-7 séance court drills techniques 60 min + S&C neuromusculaire léger 30 min". À choisir : soit ajouter une mini-séance S&C neuromusculaire W12 D2 ou D4 (Y-T-W + ER + Pallof + mobility, 30 min, RPE 5-6), soit retirer la mention "30 min S&C" du goal pour cohérence. Non bloquant — pratique réelle d'un joueur en match week reste valide en pure récup S&C light auto-administré.

## 4. Cutback / deload

Plan 12 sem, `deload_weeks: [4, 8, 12]`. **PASS catégorique**.
- W4 : -24% vs W3, durées court 70 min × 3 + S&C 40 min, target_zone abaissée (RPE 7-8 retiré, focus Z3 / RPE 5-6), 0 nouveauté technique. ✓
- W8 : -22% vs W7, sprint matchplay maintenu mais en RPE 7-8 max (pas RPE 8-9 ligne 3474), volume sets réduit. ✓
- W12 = match week distincte avec taper progressif J-7 → J-1, -38% vs pic. ✓

Magnitudes dans la fourchette -15 à -25% pour W4/W8 (textbook block periodization). W12 plus profond (-38%) car taper plein avant compétition simulée — **conforme tapering Kovacs-USTA** (volume ~50-60% pic à J-7).

## 5. Safety

`safety_notes` (ligne 23) couvre **8 sections** :
1. **DRAPEAUX ROUGES** : épicondylite latérale + médiale, douleur épaule (coiffe / conflit / SLAP), poignet (TFCC / ECU / De Quervain), lombalgie service, tendinite Achille, entorse cheville, douleur articulaire genou, antécédents cardiaques / grossesse → consultation
2. **PRÉVENTION TENNIS ELBOW** : rotator cuff + grip size + cordage < 25-27 kg + pression grip 5-7/10 + sweet spot + Tyler Twist excentrique
3. **PRÉVENTION ÉPAULE** : 3 piliers (mobilité postérieure capsule + force coiffe + force scapulaire) + cap 50-60 services / séance + max 15-20 smashs
4. **MATÉRIEL OBLIGATOIRE** : chaussures tennis dédiées (red flag absolu pour entorse), raquette 290-320 g, cordage souple, medicine ball 3-5 kg, dumbbells 5-10 kg
5. **INTENSITÉ** : table RPE / Z / FCmax avec 5 paliers
6. **NUTRITION-HYDRATATION** : 500 ml/h tempéré, 1 L/h chaleur, sodium 300-700 mg/L, collation glucides 30-60 g/h
7. **SIGNES DE SURCHARGE** : 5 signes + protocole (3+ → semaine allégée -15 à -20%)
8. **SI SÉANCE MANQUÉE** : protocole < 1 sem / 1-2 sem / > 2 sem + substitution court → S&C off-court 60 min

Sport+level specific risks tennis regular :
- Tennis elbow n°1 risque → traitement biomécanique + équipement + Tyler Twist excentrique. ✓
- Épaule (overhead service + smash + sprint matchplay W5+) → cap 50-60 services / séance vs 30-40 du recreational, **proportionné regular** ; Y-T-W + ER + sleeper stretch dans CHAQUE séance S&C. ✓
- Lombaire service (extension + rotation) → Pallof + bird-dog + side plank intégrés. ✓
- Genou / cheville (drills latéraux + sprint matchplay W5+) → chaussures dédiées explicites + agility progressive + reprise post-entorse < 3 mois → consultation. ✓
- Wrist (smashes) → grip size + raquette < 320 g. ✓
- Cardiac clearance câblé sur tous les exercices RPE 8-9 (sprint matchplay, drill side-to-side, drill panier match-simulation, sets entraînement) — **bonne hygiène constraint engine**. ✓

Seuils chiffrés (5-7 jours pour consultation, 50-60 services / séance, 15-20 smashs, cordage < 25-27 kg, raquette 290-320 g) alignés AAOS / Cleveland Clinic / Kovacs-Roetert-Ellenbecker. Aucun copy-paste générique d'autre sport. **PASS catégorique**.

## 6. EU MDR

### Banned words scan

`grep` FR sur "soigner|guérir|remède|prescription|ordonnance|diagnostic|thérapie|cure|traitement|soulager|réparer le |rééducation post-|thérapeutique" → **0 occurrence**.

Usages descriptifs légitimes :
- "consulte un médecin avant de commencer ce programme" : redirection médicale standard, pas une claim. ✓
- "consulter un professionnel de santé" : redirection. ✓
- "tendinite coiffe diagnostiquée" : descriptif d'antécédent utilisateur, pas une claim que le programme diagnostique. ✓
- "préventif" / "prévention" : usage acceptable pour exercices de renforcement (≠ "curatif" / "thérapeutique"). ✓

Aucun mot banni utilisé comme **claim**. Pas de framing "le programme soigne / traite / guérit". **PASS**.

### Medical clearance triggers câblés

`safety_notes` inclut explicitement les triggers de clearance médicale :
- Antécédents cardiaques sur sprint intermittent RPE 8-9 → `cardiac-clearance-required` + consultation médecin ✓
- Grossesse / postpartum < 6 mois → consulte un médecin ✓
- Pathologie épaule connue (tendinite coiffe diagnostiquée, SLAP, conflit) → consulte un médecin ✓
- Reprise post-entorse récente < 3 mois → consulte un médecin ✓
- Épicondylite chronique > 6 sem symptômes → consulte un médecin avant de poursuivre ✓
- Lombalgie > 2 séances consécutives → consulte un médecin ✓

Constraint `cardiac-clearance-required` propagé sur **tous les exos RPE 8-9 + RPE 7-8 sets entraînement**. Conformité EU MDR catégorique. **PASS**.

## 7. Final autonomy checklist

W12 `goal` ligne 5384 — 5 critères mesurables :
1. **Set d'entraînement 6 jeux complet avec écart < 10% de qualité technique entre 1er et dernier jeu** (mesurable, observable + branchement match-test W12 D3).
2. **Premier service en jeu à 60-70% sur 30 services en simulation match** (mesurable, ratio quantitatif).
3. **5 × drill side-to-side 90 sec à RPE 8-9 avec récup 60 sec sans perte de précision** (mesurable, sets × durée × RPE × récup).
4. **Récupération en 24-36 h entre 2 séances qualité court hebdo** (observable, monitoring corporel sur fenêtre temporelle précise).
5. **S&C dédié hebdo tenu sans inconfort, force et agilité en progression** (observable, monitoring articulaire + auto-évaluation progression).

5 critères, **mesurables / observables**, calibrés NTRP 4.0+ (60-70% premier service en jeu, set 6 jeux complet sans dérive technique, récup 24-36 h = capacité regular consolidée). Branchement décisionnel implicite : la match-test simulation interclubs W12 D3 est l'épreuve réelle qui valide le critère 1+2 + intuition critère 4. **PASS** — checklist complète et calibrée niveau regular.

Note mineure — pas de branchement décisionnel **explicite** type "4+ critères = enchaîner programme competitive / 3 ou moins = refaire W9-W10 cycle 2 sem". À ajouter en regen incrémentale (1 phrase). Pas bloquant.

## 8. Style

- Français, tutoiement maintenu partout (`tu dois`, `tu maîtrises`, `Évalue : tu tiens le set sans dérive technique`) ✓
- Aucun emoji (grep `[😀-🙏🌀-🗿✂-➰Ⓜ-🉑]` = 0 occurrence) ✓
- Aucun `vous` (grep ` vous |Vous ` = 0 occurrence) ✓
- Noms d'exercices clairs et terrain-oriented (`Drill 3-coups : cross-cross-long de ligne`, `Drill side-to-side panier explosif`, `Match-test simulation interclubs — 1 set 6 jeux`, `Pattern service-volée enchaîné`)
- `notes` pédagogiques concises, citent biomécanique et tactique (`3e coup décisif long de ligne`, `Tactique : viser le coup décisif au 3e échange`, `Concentration entre les points (rituels 16-20 sec)`, `relâcher grip 5-7/10`) ✓
- Vocabulaire FFT/USTA/ITF correct (cross, long de ligne, mi-court, fond de court, panier, ghost-stroking, set partiel, tie-break, set d'entraînement, simulation interclubs, service-volée, retour, neutralisation, coup décisif)

## Issues summary

### Critical (block merge)
Aucune.

### Important (fix recommended)
Aucune.

### Minor (nice-to-have)
- **`box` non listé dans le vocabulaire doctrine `required_equipment`** (lignes 1456, 2402, 2923, 3423, 4354, 4855, 5355). Soit harmoniser doctrine pour ajouter `box`, soit remplacer par `bench` ou `step`. Cohérence intra-template OK, mais à clarifier pour algo Story 3.3a multi-templates.
- **W12 `goal` annonce "30 min S&C"** (ligne 5384) **mais aucune session S&C dédiée délivrée** (seulement 4 sessions court). Choisir : ajouter mini-séance S&C neuromusculaire W12 D2 ou D4 (30 min Y-T-W + ER + Pallof + mobility), ou retirer la mention du goal. Non bloquant.
- **Pas de branchement décisionnel explicite** sur la checklist W12 (4+ critères = competitive / 3 ou moins = refaire W9-W10). À ajouter en regen incrémentale (1 phrase).

## Sources

- [USTA — Understanding NTRP Ratings](https://www.usta.com/en/home/coach-organize/tennis-tool-center/run-usta-programs/national/understanding-ntrp-ratings.html)
- [USTA NTRP Ratings: FAQs](https://www.usta.com/en/home/play/adult-tennis/programs/national/usta-ntrp-ratings-faqs.html)
- [ITF Coach Education Programme](https://www.itftennis.com/en/news-and-media/articles/itf-coach-education-programme-educating-and-certifying-coaches/)
- [FFT — Découvrez votre classement tennis](https://www.fft.fr/actualites/decouvrez-votre-classement-tennis)
- [Complete Conditioning for Tennis 2E — Kovacs, Roetert, Ellenbecker (Human Kinetics)](https://us.humankinetics.com/products/complete-conditioning-for-tennis-2nd-edition-with-hkpropel-online-video)
- [Tennis Anatomy — Roetert & Kovacs](https://us.humankinetics.com/products/tennis-anatomy-2nd-edition)
- [How I Would Structure a High Performance Player's Training Week — Aubone Tennis](https://www.aubonetennis.com/blog/trainingweekleadingintoatournament)
- [Building an Effective Weekly Tennis Training Plan — Jinji Tennis](https://www.jinjitennis.org/post/building-an-effective-weekly-tennis-training-plan)
- [Kovacs Institute — Adult Tennis Fitness L1](https://kovacsinstitute.com/adulttennisfitnessl1.html)
- [Comprehensive rehabilitation for lateral elbow tendinopathy — PMC](https://pmc.ncbi.nlm.nih.gov/articles/PMC6769266/)
- [AAOS Therapeutic Exercise Program for Epicondylitis](https://orthoinfo.aaos.org/globalassets/pdfs/2022-therapeutic-exercise-program-for-epicondylitis.pdf)
- [Effects of A 6-Week Junior Tennis Conditioning Program on Service Velocity — PMC](https://pmc.ncbi.nlm.nih.gov/articles/PMC3761833/)

## Recommendation

**APPROVED** — bundle as-is.

Le template est exemplairement sourcé (5 piliers progression cite ITF Level 1 advanced + Level 2 intermediate + USTA NTRP 3.5-4.5 + FFT 30/1-15/4 + Kovacs/Roetert/Ellenbecker + Aubone Tennis pré-tournoi amateur explicitement), structurellement cohérent (12/12 weeks, 4 sessions strictes 3 court + 1 S&C, hooks v2 complets et symétriques 217×5), et **catégoriquement conforme EU MDR** (0 mot banni, redirections médicales propres, cardiac-clearance câblé sur RPE 8-9). La doctrine tennis regular est respectée à la lettre (volume 5-7 h court + 1-1.5 h S&C, mix 4 piliers progressivement match-play oriented, 3 cutbacks W4/W8/W12 avec magnitudes -22 à -38%, peak session W11 set 6 jeux + set partiel, sprint matchplay RPE 8-9 max 1×/sem dès W5, prévention tennis elbow piliers maintenus W1→W12, taper W12 textbook J-7 → J-1, checklist autonomie 5 critères mesurables NTRP 4.0+).

Aucune issue critique ou importante. 3 minor (vocabulaire `box`, W12 S&C mention vs delivery, branchement décisionnel checklist) à traiter en regen incrémentale ou cycle d'audit ultérieur — ne bloquent pas le bundle prod ni l'algo Story 3.3a.

Patch list optionnel pour itération future :
- Ajouter `box` au vocabulaire doctrine `required_equipment` OU renommer `box` → `bench` dans les 7 occurrences.
- Soit ajouter mini-S&C 30 min W12 D2/D4, soit retirer mention "30 min S&C" du goal W12.
- Ajouter branchement décisionnel explicite checklist W12 (4+ → competitive / 3- → refaire W9-W10).

## Patches applied (2026-05-01)

3 minor patches appliqués en édition ciblée :
1. **`box` → `bench` (7 occurrences)** : harmonisation vocabulaire `required_equipment` — `box` n'était pas dans la whitelist doctrine, remplacé par `bench` (plus générique et cohérent avec le reste du template + alternative `step-up sur banc` déjà présente). Narrative texte ("Box jump", "Box ou banc 40 cm") préservée.
2. **W12 D2 — mini-séance S&C neuromusculaire ajoutée** : conversion du jour de repos D2 en séance S&C light 30 min (Y-T-W + ER bande + Pallof press + mobilité hanches/chevilles) à RPE 5-6, activation pré-match J-6. Honore la mention "30 min S&C léger" du goal et du `progression_logic`. Goal W12 reformulé : "J-7 court 60 min + J-6 S&C neuromusculaire léger 30 min, J-5 match-test, J-3 à J-1 court court 45-60 min".
3. **Branchement décisionnel checklist W12 ajouté** : "4+ critères validés → enchaîner programme tennis competitive 16 sem (préparation tournoi A-event) ou cycle regular 12-14 sem maintenance ; 3 critères ou moins → refaire W9-W10 (cycle 2 sem build + match play) avant de viser le palier supérieur."

JSON validé (parse OK, hooks v2 symétrie 221×5, 0 banned word EU MDR). **Verdict final : APPROVED.**
