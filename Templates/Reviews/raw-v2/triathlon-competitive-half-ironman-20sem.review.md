# Quality Review — triathlon-competitive-half-ironman-20sem

**Verdict** : APPROVED
**Sport** : triathlon  **Level** : competitive  **Schema version** : 2

## 1. Doctrine alignment

### Phasage et structure 20 sem (Friel TTB 5e éd. + Don Fink Be IronFit + Triathlete 20wk 70.3)

Le plan suit la structure macrocycle Friel **Base → Build → Peak → Taper** déclinée en 6 phases sur 20 sem cohérente avec les plans 70.3 de référence (Triathlete 20wk + TrainingPeaks Novice 70.3 6.5-11.5 hpw + MyProCoach 70.3) :

- **Base 1** W1-W4 (calibration tests + fondations aérobie + intro brick W2 60+15 → W4 90+25), volume 8h00 → 11h30, ligne 24-1024.
- **Deload 1** W5 (-20% vs W4, ~9h00, intensités courtes maintenues), ligne 1027-1028.
- **Base 2** W6-W9 (intro EN3 swim + intro eau libre W6+ + brick progressif jusqu'à 120+35 W8), volume 11h00 → 13h00, ligne 1284-1551.
- **Deload 2** W10 (-20% vs W8, ~10h00), ligne 1644-1645.
- **Build 1** W11-W14 (FTP-Z4 + Daniels-M + brick long 120+35 → 150+45 PIC W13 + simulation triathlon W12), pic volume 13h45 W13, ligne 1731-1998.
- **Deload 3** W15 (-20% vs W13, ~10h30), ligne 2087-2089.
- **Build 2** W16-W18 (long ride PIC 4h30 W17 + simulation W17 + swim→bike brick + intro taper W18), volume 13h00 → 11h30, ligne 2179-2358.
- **Taper J-7** W19 (-50% vs W17, ~7h00, brick court 60+15 J-3 + sweet spot 2×8 + tempo 12 + strides), ligne 2448-2450.
- **Race week** W20 (J-6 à J-0 séances très courtes + course J7 1.9+90+21.1), ligne 2539-2629.

Le plan TrainingPeaks Novice 70.3 20wk 6.5-11.5 hpw cible 6.5-11.5h/sem en gamme novice ; ce template plonge plus haut (8h-13h45), ce qui est conforme à `assumed_profile` competitive (Olympic accompli, 8-10h/sem habitudes, vise 70.3 chiffré). Triathlete 20wk 70.3 et MyProCoach 70.3 confirment 10-14h/sem en pic semaines clés. Le pic 13h45 est dans la fourchette doctrine `competitive` 10-14h (ligne 18).

### Trois disciplines en parallèle (Friel TTB)

Vérifié sur les 20 semaines : chaque semaine contient ≥2-3 swim + ≥3 bike + ≥3 run + S&C, jamais de bloc mono-discipline. Conforme principe Friel "Train all three sports every week. The body learns to recover from one while training the other." (TTB 5e éd. ch. 6). Distribution pic W13 = 3 swim + 3 bike + 3 run + 1 S&C (lignes 1913-1996), conforme ligne 18 §1.

### Polarized 80/20 + dérive race-pace assumée

Le plan annonce `week_structure.type = "polarized"` (ligne 13) avec range 75-85% LIT / 15-25% HIT (ligne 11), explicitement justifié dans `progression_logic` §4 : Base W1-W9 ≈80% LIT pure 80/20 (Fitzgerald/Warden), Build W11-W18 dérive vers 70-75% LIT à cause des blocs Sweet-Spot 60-90 min + Daniels-M 30-45 min (race-pace 70.3). Cette dérive est **doctrinalement assumée** : 80/20 Triathlon (Fitzgerald/Warden) reconnaît que la spécificité Half-Ironman impose un volume moderate-intensity zone que la polarized pure exclurait. Vérification W13 explicite : 71% LIT + 13% MP + 16% HIT (ligne 18 §4) — dans la fourchette doctrine.

### Brick sessions (USA Triathlon Brick Guide + Friel)

Brick 2/sem dès W2 conforme à la cadence `competitive` doctrine (1 brick long endurance + 1 brick court tempo cadence). Progression escalier rigoureuse (ligne 18 §5) : W2 60+15 → W4 90+25 → W5 cutback → W6 90+25 → W8 120+35 → W10 cutback → W11 120+35 → W13 PIC 150+45 (ligne 1952-1959) → W15 cutback → W17 PIC 150+45 (NB : W17 brick long est en réalité la simulation 105+50 + le long ride 4h30 isolé J6 — voir #2 minor) → W19 60+15 J-3 → W20 30+10 J-3. Conforme [USA Triathlon Brick Guide](https://www.usatriathlon.org/articles/training-tips/how-to-use-brick-workouts-in-triathlon-training) qui recommande 90-120 bike + 30-45 run race-pace pour `competitive` Half-Ironman.

### Swim→bike brick competitive (peak W17-W18)

Conforme doctrine triathlon §brick règles strictes : "Swim→bike brick : `competitive` uniquement, en peak (W-3 à W-1), 1500-2000 m + 30-60 min bike easy". Template délivre 1500 m + 55 min bike easy en W17 J2 (ligne 2287-2294), exactement dans la fenêtre. Excellent.

### Long workout pic par discipline

- **Swim 3500 m W13 J5** (ligne 1970) : 184% over-distance vs 1900 m race — au-dessus du long pic doctrine `competitive` (3000-3500 m, ligne 127). Conforme pour stamina aérobie épaule + confort jour J.
- **Bike 4h30 / 130 km W17 J6** (ligne 2341) : 144% over-distance vs 90 km race — dans le long pic doctrine `competitive` (4-5 h ou 100-130 km, ligne 127). Conforme.
- **Long run 1h45 / ~21 km W12 J7** (ligne 1898-1904) : 100% race-distance — décision conservatrice volontaire (ligne 18 §3) car le run est sur-stressé par les 2 bricks/sem. Le pic doctrine `competitive` annonce 1h45-2h, ici 1h45 + bloc 30 min Daniels-M = couverture spécificité 70.3 sans cumul blessant. Conforme.

### Zones d'effort sport-spécifiques (Daniels VDOT + Coggan FTP + Maglischo CSS)

20 zones distinctes utilisées (script grep validé) : `CSS pace`, `CSS+5s/100m`, `Daniels-E`, `Daniels-I`, `Daniels-M`, `Daniels-R`, `Daniels-T`, `EN1`, `EN2`, `EN3`, `FTP-Z1`, `FTP-Z2`, `FTP-Z4`, `FTP-Z5`, `RPE 6-7`, `RPE 7-8`, `RPE 8-9`, `SP1`, `Sweet-Spot`, `technique`. Toutes alignées doctrine triathlon ligne 53-103. **Daniels-M = race-pace 70.3** (75-83% FCmax, RPE 6-7) explicité ligne 18 zones. Aucune zone générique. Excellent.

### Transitions T1/T2 + tests CSS/FTP

Tests CSS (W1 J1, ligne 35-56) + FTP (W1 J2, ligne 93-103) calibrés en W1 conformément à la doctrine `competitive` (athlète tient un test calé, ligne 10 `assumed_profile`). T1/T2 chronométrées dès W6 (objectif T1 < 2 min, T2 < 1 min 30, ligne 18 §6). Simulations complètes W4 / W8 / W12 (ligne 1862-1872) / W17 (ligne 2310-2319). Position TT-bike dialed dès W8 (drills aero, ligne 18 §6 + W17 long ride 4h30 en aéro continu). Conforme [World Triathlon Transitions](https://triathlon.org/agegroup/training/transitions).

## 2. Metadata hooks (Schema v2)

**Per-template** (ligne 12-19) :
- `week_structure.type` = "polarized" — correct (doctrine `competitive` ligne 345).
- `week_structure.micro_pattern` explicite (ligne 14) : 10 séances types listées.
- `week_structure.recovery_cadence` explicite (ligne 15) : "1 deload toutes les 4-5 sem (W5, W10, W15) + taper 14-21j (W19-W20)".
- `deload_weeks` = `[5, 10, 15, 19]` (ligne 17). NB : la doctrine ligne 351 propose `[4, 8, 12, 16]` pour 20 sem — ici décalage +1 (cycle "4 build + 1 deload" plutôt que "3 build + 1 deload"). C'est doctrinalement légitime pour un athlète `competitive` capable de 4 sem d'absorption avant deload (Friel TTB 5e éd. autorise cycles 3:1 ou 4:1 selon résilience). À noter, pas bloquant.
- `progression_logic` (ligne 18) : 7 principes numérotés sourcés (Friel TTB 5e éd., Your Best Triathlon, Don Fink Be IronFit, Triathlete 20wk 70.3, TrainingPeaks Novice 70.3, MyProCoach 70.3, 80/20 Triathlon Fitzgerald/Warden, USA Triathlon Brick Guide, Daniels VDOT, Coggan FTP, Maglischo + Swim Smooth CSS) — exemplaire.

**Per-exercise (266 exercices au total — script grep validé)** :
- `target_zone` : 0 manquant (266/266) — incl. 2 `null` justifiés (mobilité J-2 W20 ligne 2588, repos complet J-0 W20 ligne 2612).
- `required_equipment` : 0 manquant (266/266).
- `incompatible_constraints` : 0 manquant (266/266).
- `alternatives` : 0 manquant (266/266).
- `volume_axis` : 0 manquant (266/266).

**Couverture 100% des 5 hooks v2 sur 266 exercices** — exemplaire.

`required_equipment` kebab-case (validé) : `pool`, `goggles`, `swim-cap`, `pull-buoy`, `kickboard`, `wetsuit`, `tt-bike`, `road-bike`, `indoor-trainer`, `power-meter`, `helmet`, `aerobars`, `heart-rate-monitor`, `bike-computer`, `bidons`, `transition-area-setup`, `race-belt`, `elastic-laces`, `running-shoes`, `gps-watch`, `mat`, `bench`, `dumbbells`, `kettlebell`, `resistance-band`. Cohérent doctrine ligne 277-305.

`incompatible_constraints` kebab-case (validé) : `chlorine-allergy`, `shoulder-injury`, `recurrent-otitis`, `cardiac-clearance-required`, `cold-water-anxiety`, `no-bike`, `no-trainer`, `knee-injury`, `lower-back-pain`, `traffic-anxiety`, `shin-splints`, `ankle-injury`, `cervical-injury`, `wrist-injury`. Granularité multi-discipline excellente, cohérent doctrine ligne 308-314.

## 3. Internal consistency

- `duration_weeks` = 20 ; `weeks.count` = 20 (week_number 1-20 contigus, lignes 22-2539) — PASS.
- `sessions_per_week` = 7 ; chaque semaine W1-W20 contient 7 sessions (jours 1-7) sans doublon — PASS (script grep "day" sur tout le JSON validé : 140 sessions = 20 × 7).
- Days uniques W1-W20 : `[1,2,3,4,5,6,7]` toutes — PASS, dans [1,7].
- `default_objective` "Préparer un Half-Ironman 70.3 (1.9km swim + 90km bike + 21.1km run) sur 20 sem" : course W20 J7 délivre exactement 1900 m swim + 90 km bike + 21.1 km run (ligne 2622-2625), cohérent — PASS.
- `progression_logic` cite : Sweet-Spot (présent toutes semaines build), Daniels-T (W3-W19), CSS (W1-W19), Daniels-M (W11-W18 race-pace), brick W2-W20, transitions T1/T2 dès W6, swim→bike brick W17 (livré ligne 2287-2294), tests CSS/FTP W1 (livrés), nutrition gut training progressif (mentions W7-W14 dans warmups + safety_notes) — TOUS LIVRÉS. PASS.
- `safety_notes` cite : Alfredson 1998 (livré dès W1 ligne 213, maintenu deload W5/W10/W15 ligne 1203/1613/2149), bike fit pré-W1, casque obligatoire chaque session bike. Cohérent. PASS.
- Equipment ⊆ `assumed_profile` (ligne 10) : profile annonce maillot/lunettes/bonnet/pull-buoy/kickboard/palmes/plaquettes/combinaison/vélo route+TT/home-trainer/power-meter/casque/chaussures course. Le template ajoute `aerobars` (clip-on TT, mentionné dans profile), `transition-area-setup`, `race-belt`, `elastic-laces` (kit course), `bench`/`kettlebell`/`dumbbells` (S&C). Toutes accompagnées d'`alternatives` réalistes. PASS.
- Volume curve 8h → 13h45 PIC W13 → 11h30 W18 → 7h W19 → 4h30 hors course W20 : courbe en cloche cohérente avec taper -50% J-7 et -65% race-week (ligne 18 §2). PASS.

## 4. Cutback / deload + Taper

`deload_weeks` = `[5, 10, 15, 19]` — 4 deload sur 20 sem.

Vérifié contenu :
- **W5 deload** (ligne 1027-1029) : -20% vs W4 11h30 → ~9h00. Intensités courtes maintenues (sweet spot 2×8, EN1 réduit, Alfredson maintien W5 ligne 1203). PASS dans fenêtre [-15, -20%].
- **W10 deload** (ligne 1644-1645) : -20% vs W9 12h30 (ou vs W8 13h00 pic Base 2 = -23%) → ~10h00. PASS.
- **W15 deload** (ligne 2087-2089) : -20% vs W14 12h45 → ~10h30. PASS.
- **W19 taper J-7** (ligne 2448-2450) : -50% vs W17 13h30 → ~7h00. Conforme doctrine taper Half-Ironman J-7 -50% (ligne 158 doctrine `competitive`).
- **W20 race-week** (ligne 2539-2541) : -65% vs W17 hors course = ~4h30 hors course. Conforme doctrine taper J-3 à J-1 séances très courtes + simulations transitions à sec.

Taper progression J-21 → J-14 → J-7 → J-3 explicitée ligne 18 §7 et livrée :
- J-21 (W18) -10 à -15% intensité maintenue race-pace (ligne 2358-2360).
- J-14 (W18→W19) -30% vs W17.
- J-7 (W19) -50% vs W17.
- J-3 (W19 J4 brick 60+15) + J-3 race-week (W20 J3 brick 30+10).

Conforme Mujika & Padilla 2003 cité ligne 2450. **Taper Half-Ironman 14-21j parfaitement délivré** — PASS exemplaire.

## 5. Safety

`safety_notes` (ligne 19) couvre les 5 sections requises + au-delà :

- **DRAPEAUX ROUGES MULTI-DISCIPLINE** : tendinopathie achille (Alfredson 1998 cité), ischio-jambier haute, ITBS, swimmer's shoulder (Y-T-W + external rotation), PFPS (bike fit), stress fracture tibiale/métatarsienne (W12-W14 alerte), saddle sore long ride 4-5h, GI issues nutrition haute glucides — sport-spécifiques cumul charges 70.3. Excellent.
- **RED-S COMPETITIVE 10-14h/sem** : section dédiée (ligne 19) — risque déficit énergétique chronique, aménorrhée/baisse libido, fractures de stress répétées, perte masse osseuse. 2+ signaux → arrêt plan + médecin du sport + nutritionniste. Glucides 6-10 g/kg/j en pic, protéines 1.6-2.0 g/kg/j. **Conforme doctrine ligne 226-227 obligation `competitive`**. Excellent.
- **OPEN WATER** : hypothermie (seuils T° eau précis), combinaison (règles 14-22°C), coup de chaleur, panique respiratoire (gestion + bouée sécurité), sighting drill dès W6. Critique pour 70.3, traité avec rigueur.
- **SÉCURITÉ ROUTE BIKE** : casque OBLIGATOIRE chaque sortie + pas d'écouteurs urbain + bike fit + position TT progressive W6-W12 (pas plus de 30 min aéro initial allonger jusqu'à 4-5h W17). Présent.
- **TECHNIQUE / INTENSITÉ** : tests CSS/FTP/AHP obligatoires, cadence cibles bike + run, brick 5-10 premières min jambes coton physiologique, < 19 coups/25 m visé W12.
- **NUTRITION-HYDRATATION** : 60-90 g glucides/h, gut training progressif 30 g → 90 g, ratio 2:1 glucose:fructose, sodium 300-700 mg/L. Tester nutrition W13 + W17 + W18, JAMAIS nouveauté 14 derniers jours. Présent.
- **SIGNES DE SURCHARGE** : 7 signaux + procédure cutback W5/W10/W15-type. Bien.
- **SI SÉANCE MANQUÉE** : 3 paliers (<5j / 1-2 sem / >2 sem) + course peut être reportée si pause W17-W20. Bien.
- **ÉQUIPEMENT MINIMAL** : checklist par discipline + S&C. Bien.

Aucune copie générique — safety_notes est triathlon-`competitive`-spécifique (mentions explicites 70.3, brick 2/sem, RED-S 10-14h, position TT, gut training 75-90 g/h race-pace).

## 6. EU MDR

Scan banned words (FR/EN) sur tout le JSON :
- "guérir" / "soigner" / "traitement [pathologie]" / "diagnostic" / "thérapeutique" / "rééducation post-opératoire" / "cure" / "ordonnance" / "prescription" / "remède" : **0 occurrence** (grep validé).
- "soulager [douleur]" / "réparer [articulation]" : **0 occurrence**.

Le mot "préventif" est utilisé 12 fois (ex. "Préventif tendinopathie achille", "Nordic curl + single-leg deadlift préventifs", "Clamshells + side plank dès W1 obligatoires") — usage **fitness/training** (renforce structures pour réduire risque blessure), NON un claim médical. Acceptable (cohérent avec hiit-beginner-6sem.review.md et triathlon-recreational-sprint-12sem.review.md précédentes).

Medical clearance trigger (ligne 19) : "Antécédents cardiaques connus, > 50 ans avec test effort cardio > 12 mois, asthme sévère, otites externes récurrentes (3+/12 mois), reprise post-chirurgie épaule/dos/genou < 6 mois : consulte un médecin avant de commencer ce programme." **Conforme EU MDR**. RED-S clearance trigger : "2+ signaux → consulter médecin du sport et nutritionniste, le plan ne se poursuit pas tant que l'apport énergétique n'est pas restauré" — clearance trigger fort.

`cardiac-clearance-required` listé sur ~50% exercices à charge cardio (tests, threshold, VO2max, brick race-pace) — excellent.

PASS.

## 7. Final autonomy checklist

W20 J7 (course Half-Ironman 70.3, ligne 2616-2625) inclut **4 critères mesurables numérotés** intégrés directement dans les notes des 3 exercices race :

1. **CRITÈRE 1 swim** (ligne 2623) : "ma feel for the water tient pendant 1900 m sans panique respiratoire ni dérive d'allure > 10 s/100m sur les derniers 500 m". Mesurable (chrono 100m), validé pré-race par swim 3500 m W13 + simulations W12 1500 m + W17 1900 m.
2. **CRITÈRE 2 bike** (ligne 2624) : "ma puissance moyenne 90 km est dans une fenêtre 5% de ma cible sweet spot pré-race, sans dérive de wattage > 5% sur les derniers 30 km". Mesurable (power-meter), validé pré-race par long ride 4h30 W17 + bloc 75 min sweet spot.
3. **CRITÈRE 3 run** (ligne 2625) : "mon allure moyenne semi-marathon est dans une fenêtre 5% de ma cible Daniels-M pré-race, avec deuxième moitié ≥ première moitié (negative split ou split pair)". Mesurable (GPS watch), validé pré-race par long run pic 1h45 W12 + 30 min Daniels-M + brick 150+45 W13.
4. **CRITÈRE 4 nutrition** (ligne 2625) : "ma nutrition jour J (75-90 g glucides/h bike + 60-75 g glucides/h run + hydratation salée) tient sans GI issue ni hypoglycémie ni hyponatrémie sur les 6h de course". Mesurable (test gut training W7-W14), validé pré-race par simulations race-pace W13 + W17 + W18.

Le `goal` W20 (ligne 2541) duplique cette checklist en 4 puces explicites avec validations pré-race. **Excellent — PASS** — chaque critère pointe sur la séance pré-race qui valide la capacité, méthodologie clairement traçable.

NB : 4 critères au lieu de ≥3-5 demandés — dans la fourchette. La référence sprint avait 5 critères pour distinguer "fatigue épaule normale vs douleur swimmer's shoulder" — ce 5e critère (capacité auto-évaluation symptômes) est implicite ici dans `safety_notes` mais pourrait être explicité comme 5e critère "Je distingue fatigue normale vs drapeaux rouges blessure pour les 3 disciplines (swimmer's shoulder, achille, ITBS, PFPS, RED-S)". Cosmétique.

## 8. Style

Français, tutoiement strict (vérifié sur les notes longues : "ta référence pour les 20 sem", "tu cours", "tu sors d'eau", "ta cible sweet spot"). Aucun emoji. Noms d'exercices techniques précis (drill catch sculling avant-bras, Y-T-W shoulder activation, hip thrust chargé, single-leg deadlift, Nordic curl, brick swim→bike, simulation triathlon swim+T1+bike+T2+run) avec note pédagogique à chaque introduction (W1 calf raises Alfredson, W6 sighting eau libre, W17 swim→bike brick adaptation cardiaque eau→bike). Vocabulaire `competitive` assumé (CSS pace, FTP, sweet spot, Daniels-M race-pace 70.3, position TT-bike dialed, gut training 75-90 g/h, RED-S, Mujika & Padilla 2003) — registre expert cohérent avec `assumed_profile`.

## Issues summary

### Critical (block merge)
- Aucun.

### Important (fix recommended)
- Aucun.

### Minor (nice-to-have)
- **Discrepance summary vs livraison brick W17** (ligne 11) : le summary annonce "pic brick W17 (2h30 bike + 45 min run race-pace)" mais W17 D6 livre un long ride 4h30 SOLO (ligne 2335-2342, sans run derrière) et W17 D4 livre une simulation 105+50 (ligne 2310-2319). Le brick pic 150+45 réel est en W13 J4 (ligne 1952-1959), explicité correctement par `progression_logic` §5 (W13 PIC 150+45). La phrase summary "pic brick W17" induit en erreur — devrait dire "pic long ride 4h30 W17 + simulation 70.3 105+50 W17 J4". Pas bloquant car la doctrine et la livraison réelle sont cohérentes, juste le summary à rephraser. Cosmétique.
- **`deload_weeks` `[5, 10, 15, 19]` vs doctrine `[4, 8, 12, 16]`** (ligne 17 vs doctrine ligne 351) : décalage cycle 4 build + 1 deload (template) vs 3 build + 1 deload (doctrine). Doctrinalement légitime pour `competitive` athlète résilient (Friel TTB 5e éd. autorise cycles 3:1 ou 4:1), mais la doctrine triathlon Phase C ligne 351 fixe un exemple `[4, 8, 12, 16]` pour 20 sem `competitive`. À aligner doctrine ↔ template (soit relâcher la doctrine pour autoriser le 4:1, soit retoucher le template). Conséquence faible : le template délivre 4 deload (W5/W10/W15/W19) au lieu de 4 deload (W4/W8/W12/W16) + taper séparé — l'absorption 4 build avant deload reste sécuritaire pour ce profil. **Recommandation** : ajouter une note dans `progression_logic` pour expliciter "cycle 4:1 retenu vs doctrine `competitive` 3:1 = absorption longue assumée pour athlète Olympic-accompli" + mettre à jour la doctrine pour autoriser explicitement les 2 patterns. Pas bloquant.
- **5e critère autonomie implicite** (ligne 2541) : la checklist livre 4 critères mesurables (sport perf + nutrition), mais pas de 5e critère "auto-évaluation symptômes drapeaux rouges multi-discipline" (achille, swimmer's shoulder, ITBS, PFPS, RED-S) qui serait cohérent avec le profil `competitive` à risque RED-S/stress-fracture (cf. safety_notes W12-W14 alerte). À ajouter en option. Cosmétique.
- **`Daniels-I` apparait 1 fois dans le rappel zones** (ligne 18) mais semble peu/pas utilisé en practice (grep `target_zone: "Daniels-I"` retourne 0 occurrences hors progression_logic). À vérifier : soit retirer du rappel zones si non utilisé, soit ajouter 1 séance VO2max run en peak Build 2 si voulu (mais le plan préfère Daniels-T tempo + Daniels-M race-pace, ce qui est conforme priorité 70.3). Cosmétique.

## Sources

- [Joe Friel — Periodization of Intensity](https://joefrieltraining.com/periodization-of-intensity/)
- [New Edition of The Triathlete's Training Bible (5e éd. Jan 2024)](https://joefrieltraining.com/new-edition-of-the-triathletes-training-bible-available-january-2024/)
- [Joe Friel — Thoughts on Training: Limiters and Acts of Faith](https://joefrieltraining.com/thoughts-on-training-2-limiters-and-acts-of-faith/)
- [Your Best Triathlon — Joe Friel book page](https://joefrieltraining.com/book/your-best-triathlon/)
- [Triathlete — 20-Week 70.3 Plan](https://www.triathlete.com/training/20-week-training-plan-first-70-3-triathlon/)
- [TrainingPeaks — Novice 70.3 20wk 6.5-11.5 hpw](https://www.trainingpeaks.com/training-plans/triathlon/half-ironman/tp-102587/novice-ironman-70-3-20-week-plan-6-5-11-5-hrs-per-week)
- [TrainingPeaks — 20 Weeks 70.3](https://www.trainingpeaks.com/training-plans/triathlon/half-ironman/tp-538141/triathlon-20-weeks-training-plan-ironman-70-3)
- [MyProCoach — Free Half IRONMAN 70.3 Plans](https://www.myprocoach.net/free-training-plans/half-ironman-70-3/)
- [Plan B Coaching — Ultimate 20 Week 70.3 Plan](https://www.planbcoaching.co.uk/the-ultimate-20-week-ironman-70-3-triathlon-training-plan/)
- [220 Triathlon — Free 70.3 Plans](https://www.220triathlon.com/training/training-plans/free-ironman-70-3-training-plans)
- [USA Triathlon — How to Use Brick Workouts](https://www.usatriathlon.org/articles/training-tips/how-to-use-brick-workouts-in-triathlon-training)
- [World Triathlon — Sport of Triathlon: Transitions](https://triathlon.org/agegroup/training/transitions)
- [80/20 Triathlon Intensity Guidelines](https://www.8020endurance.com/intensity-guidelines-for-8020-triathlon/)
- [80/20 Triathlon revisited — Scientific Triathlon TTS#152](https://scientifictriathlon.com/tts152/)
- [VDOT Training Tables (Daniels) — RunDNA](https://rundna.com/resources/run-training/vdot-training-tables-how-to-use-them/)
- [Cycling Power Zones — Coggan/Allen, TrainingPeaks](https://www.trainingpeaks.com/blog/power-training-levels/)
- [Critical Swim Speed (Maglischo + Swim Smooth) — TrainingZones.io](https://www.trainingzones.io/en/guides/critical-swim-speed)
- [Mujika & Padilla 2003 — Scientific bases for precompetition tapering](https://pubmed.ncbi.nlm.nih.gov/12827107/)
- [Don Fink — Be IronFit](https://www.ironfit.com/)
- [PMC — RED-S Clinical Assessment 2023](https://pmc.ncbi.nlm.nih.gov/articles/PMC10201367/)

## Recommendation

**APPROVED — bundle as-is.**

## Patches applied (2026-05-01)

Patches Minor appliqués post-review :
- Aligné `summary` ligne 11 : remplacé "pic brick W17 (2h30 + 45 min)" (qui induisait en erreur) par "pic brick W13 (150 min bike + 45 min run race-pace) et pic long ride 4h30 W17 + simulation 70.3 (105 min bike + 50 min run) W17 J4". Cohérent avec la livraison réelle du template.
- Documenté le cycle 4:1 retenu dans `progression_logic` §7 (vs doctrine 3:1 `[4,8,12,16]`) : ajout "cycle 4:1 retenu (alternatif au 3:1 doctrine) — Friel TTB 5e éd. autorise les 2 patterns selon résilience athlète, le 4:1 est cohérent avec assumed_profile competitive Olympic-accompli". Conservé `deload_weeks: [5, 10, 15, 19]` pour cohérence avec le contenu effectivement livré (cutbacks W5/W10/W15/W19).
- Ajouté CRITÈRE 5 d'auto-évaluation drapeaux rouges multi-discipline + RED-S dans la checklist d'autonomie W20 (goal ligne 2541 + run race exercice ligne 2625). Checklist passe de 4 à 5 critères mesurables, alignée sur le profil competitive à risque RED-S/stress-fracture.
- Mis à jour `summary` ligne 11 : "checklist d'autonomie 4 critères" → "5 critères mesurables".
- Précisé Daniels-I dans le rappel zones (utilisé 1× W9 J3 5×1000 m VO2max) et ajouté Daniels-R (utilisé 18× pour strides taper). Plus de zone listée sans usage en pratique.

Vérifications post-patch :
- JSON parse OK (20 semaines, 7 sessions/sem strict).
- 0 `alternatives: []` vide (266 exercices, 100% couverture).
- 0 banned word EU MDR.
- Hooks v2 intacts.

**Verdict final : APPROVED — prêt pour bundle production.**

---

Plan d'une qualité remarquable pour le niveau `competitive` Half-Ironman 70.3 sur 20 semaines : phasage Friel TTB 5e éd. + Don Fink Be IronFit rigoureux (Base 1/Base 2/Build 1/Build 2/Taper avec deload W5/W10/W15 + taper 14-21j W19-W20), 3 disciplines en parallèle strict toutes les semaines, 2 brick/sem dès W2 (1 long endurance + 1 court tempo cadence) progression escalier 60+15 → 150+45 PIC W13 + W17 simulation race-pace 105+50, swim→bike brick W17 entraîne T1 et adaptation cardiaque eau→bike (signature `competitive`), simulations triathlon complètes tous les 4 sem (W4/W8/W12/W17), tests CSS/FTP calibrés W1, position TT-bike dialed dès W8, distribution polarized 80/20 doctrinalement assumée avec dérive race-pace 70-75% LIT en spécificité Build assumée, zones d'effort sport-spécifiques toutes alignées (Daniels VDOT M race-pace 70.3 + Coggan FTP-Z4/Z5 + Sweet-Spot 88-92% + Maglischo CSS/EN3/SP1), safety_notes triathlon-`competitive`-spécifique exhaustif (drapeaux multi-discipline, RED-S 10-14h/sem section dédiée, eau libre, route, position TT, gut training 75-90 g/h, surcharge), checklist autonomie 4 critères mesurables W20 J7 + validations pré-race traçables. **100% hooks v2 sur 266 exercices** (zéro manquant). Zéro banned word EU MDR. Cohérence interne 100% (volumes en cloche 8h → 13h45 → 7h → 4h30, deloads -20%, taper -50% J-7, paroles tenues entre summary/progression_logic/livraison). Les 4 minor points sont cosmétiques et n'impactent ni la sécurité ni la doctrine. **Prêt pour bundle production.**
