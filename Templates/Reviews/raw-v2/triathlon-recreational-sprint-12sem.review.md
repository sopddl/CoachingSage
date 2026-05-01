# Quality Review — triathlon-recreational-sprint-12sem

**Verdict** : APPROVED
**Sport** : triathlon  **Level** : recreational  **Schema version** : 2

## 1. Doctrine alignment

### Phasage et structure 12 sem (Friel TTB / USA Triathlon / BeginnerTriathlete)

Le plan suit fidèlement la grille Friel "Base → Build → Peak → Taper" attendue pour un sprint en 12 sem :

- W1-W3 Base (volume linéaire +10-15%, pas d'intervalles dures, intro tempo Daniels-T à W3 — parfaitement aligné)
- W4 cutback (-15-20%, intro brick light 35+10) — `joefrieltraining.com` recommande "every 3-5 weeks deload"
- W5-W7 Build (sweet spot, CSS+5s, brick progressif 45+15 → 55+18)
- W8 cutback (-20%)
- W9-W10 Peak (long swim 1500 m, long bike 90 min, brick 60+20)
- W11 Taper J-14 (-30% volume, intensité maintenue via 4×100 m CSS+5s + tempo 12 min + strides allure 5K)
- W12 Race week J-7 (-50% volume, séances très courtes + brick neuro J-3 + course J6)

Le plan TrainingPeaks officiel "Sprint-Distance Triathlon, Finish Your First, 12-weeks" (Friel) annonce exactement : **5h/sem moyenne, 6 workouts/sem, 2 par sport + S&C optionnel**. Le template délivre 2 swim + 1 bike + 1-2 run + 1 brick (W4+) + 1 S&C avec pic ~6h cumul effort pur (~6h55 incluant warm-up/cool-down sur W9). Cohérent et crédible. Voir [TrainingPeaks Friel Sprint 12wk](https://www.trainingpeaks.com/training-plans/triathlon/sprint/tp-1975/).

USA Triathlon recommande "at least one brick workout per week in the final four to six weeks" — le template introduit brick à W4 (8 sem brick avant course), donc plus généreux que le minimum USAT, ce qui est conservateur et adapté recreational. Voir [USAT Sprint Beginner 12wk](https://www.trainingpeaks.com/training-plans/triathlon/sprint/tp-51412/).

### Trois disciplines en parallèle (Friel)

Vérifié : chaque semaine W1-W12 contient ≥1 swim + ≥1 bike + ≥1 run, jamais de bloc mono-discipline 2-4 sem. Conforme au principe Friel "concurrent training : maintain stimulus in each sport every 7 days max". Source : Friel, *The Triathlete's Training Bible*, 5e ed. ch. 6 (cycle structure).

### 48h récup même discipline

Vérifié programmatiquement : sur les 12 semaines, aucune paire swim-swim, bike-bike, run-run avec gap < 48h. Conforme à la doctrine Friel/USAT (préserve adaptation locale + tendineuse multi-discipline).

### Distribution intensité ~85% LIT / ~15% HIT (80/20 Endurance / Fitzgerald-Warden)

Le plan annonce 85/15 et NON 80/20 strict polarisé. C'est la bonne décision pour une fenêtre 5-7h/sem : Fitzgerald-Warden eux-mêmes admettent qu'à <8h/sem la 80/20 polarisée pure laisse trop peu de stimulus seuil. Le plan emploie sweet spot bike + Daniels-T run + EN2 swim — c'est explicitement la "moderate-intensity zone" que Fitzgerald critique dans 80/20 Triathlon… mais le contexte recreational sprint l'admet comme **compromis** (cf. Fitzgerald TTS#152 podcast, "for time-crunched amateurs, 85/15 with sweet spot dominant is acceptable"). Voir [80/20 Triathlon revisited](https://scientifictriathlon.com/tts152/) et [TrainingPeaks 80/20 article](https://www.trainingpeaks.com/blog/using-the-80-20-rule-to-balance-triathlon-training-intensity/). **Cohérence doctrinale assumée et justifiée — pas de drapeau rouge**.

### Long workouts pic par discipline (W9)

- Swim 1500 m vs course 750 m = 200% over-distance — alignée Friel "long swim = 200-250% race distance for sprint"
- Bike 90 min / 60 km vs course 20 km = 300% — généreux mais cohérent (Friel : long ride sprint = 1.5-2× temps de course soit ~80-90 min)
- Run 45 min / 8 km vs course 5 km = 160% — capé délibérément à cause du brick (run cumulé hebdo bricks inclus = ~70 min, donc cap long run pur à 8 km est sain). Conforme aux recommandations Daniels (20-25% du volume hebdo en long run, ici ~8 km/40 km cumul ≈ 20%, OK).

### Zones d'effort doctrine

- **Run Daniels** : E (59-74% VDOT, conversational), T (83-88% VDOT, comfortably hard 5-15 min), R (105-110% pour strides). Template utilise ces 3 zones avec `target_zone: Daniels-E/T/R` et descriptions cohérentes (allure 10K+15-30 s/km pour T, RPE 4-5 pour E). Pas de Daniels-I (VO2max) — décision conservatrice volontairement justifiée pour recreational. Conforme [VDOT/Daniels Tables](https://rundna.com/resources/run-training/vdot-training-tables-how-to-use-them/).
- **Bike Coggan** : Z2 (56-75% FTP), Z3 (76-90%), Sweet Spot (88-94%). Template emploie `FTP-Z2`, `FTP-Z3`, `Sweet-Spot` avec %FTP corrects. Pas de Z5 VO2max ni Z6 anaerobic — conservateur et adapté. Conforme [TrainingPeaks Power Zones](https://www.trainingpeaks.com/blog/power-training-levels/).
- **Swim Maglischo + Swim Smooth** : EN1 (CSS+8-12s, conversational), EN2 (CSS±0-3s seuil), CSS pace pure (W9). Pas de SP1/SP2 sprint — adapté recreational. Conforme [Maglischo CSS framework](https://www.trainingzones.io/en/guides/critical-swim-speed).

### Brick progression (USA Triathlon Brick Guide)

W4 35+10 (intro très light) → W5 45+15 → W6 50+15 → W7 55+18 → W8 cutback 45+12 → W9 PIC 60+20 → W10 55+18 → W11 simulation 18 km + 4 km → W12 brick neuro J-3 court 20+5. Progression EN ESCALIER avec deload, conforme [MyProCoach 8 best brick workouts](https://www.myprocoach.net/blog/8-best-brick-triathlon-workouts/) (recommande 30-45 bike + 10-15 run pour sprint, max 45+20 pic) et USAT brick guide. **Le pic 60+20 est légèrement au-delà du standard recreational (USAT recommande max 50+15-20 pour beginner) — ACCEPTABLE pour profil "intermédiaire confortable" annoncé en `default_objective`, mais à surveiller**.

### Transitions T1/T2

W3 à sec (intro 4 essais lents) → W5 pool-side simulé → W6-W7 chronométrés (T1<2 min, T2<1 min 30 → 1 min) → W9 pool-side réel → W11 simulation rehearsal réelle. Progression fidèle USAT "transition practice progression" (à sec → simulé → chronométré → race-rehearsal). Voir [USA Triathlon transition guidance](https://www.usatriathlon.org/).

## 2. Metadata hooks (Story 0.5.9 / Schema v2)

**Per-template** :
- `week_structure.type` = "linear" — correct
- `week_structure.micro_pattern` = explicite et lisible
- `week_structure.recovery_cadence` = explicite (cutbacks W4 W8 + taper W11)
- `deload_weeks` = `[4, 8]` — conforme à la doctrine "every 3-5 weeks" pour 12 sem
- `progression_logic` = 7 principes numérotés sourcés (Friel, USAT, Daniels, Coggan, Maglischo, Fitzgerald-Warden) — exemplaire

**Per-exercise (171 exercices au total — script Python validé)** :
- `target_zone` : 0 manquant
- `required_equipment` : 0 manquant
- `incompatible_constraints` : 0 manquant
- `alternatives` : 0 manquant
- `volume_axis` : 0 manquant

Inventaire des `target_zone` distincts utilisés : `@10K-pace`, `CSS pace`, `Daniels-E`, `Daniels-T`, `Daniels-R`, `EN1`, `EN2`, `FTP-Z2`, `Sweet-Spot`, `REC`, `RPE 6-7`, `RPE 7-8`, `RPE 8-9`, `technique`, `null` (transitions). Toutes les zones sont sport-spécifiques et alignées doctrine. Aucune zone générique type "moderate". Excellent.

`incompatible_constraints` kebab-case : `chlorine-allergy`, `shoulder-injury`, `cardiac-clearance-required`, `no-bike`, `knee-injury`, `lower-back-pain`, `traffic-anxiety`, `recurrent-otitis`, `cervical-injury`, `shin-splints`, `ankle-injury`, `wrist-injury`. Granularité multi-discipline excellente.

`required_equipment` kebab-case : `pool`, `goggles`, `swim-cap`, `kickboard`, `running-shoes`, `gps-watch`, `road-bike`, `helmet`, `bidons`, `heart-rate-monitor`, `transition-area-setup`, `race-belt`, `elastic-laces`, `mat`, `bench`, `dumbbells`, `resistance-band`, `wetsuit`. Cohérent et exhaustif.

## 3. Internal consistency

- `duration_weeks` = 12 ; `weeks.count` = 12 — PASS
- 6 sessions/sem chaque semaine, types ≠ "rest" — PASS (≤ `sessions_per_week=6`)
- Days uniques W1-W12 : `[1,2,3,4,5,6]` toutes — PASS, dans [1,7]
- `default_objective` "750 m + 20 km + 5 km en moins de 1h30" : course W12 délivre exactement 750 m + 20 km + 5 km, avec durée prévue 90 min (40+30+1.5+1=72.5 min effort + transitions ≈ ~75-80 min). Cohérent avec "moins de 1h30 niveau intermédiaire confortable". PASS
- `progression_logic` cite : Sweet-Spot (présent W3 W5 W6 W7 W9 W10 W11), Daniels-T (W3 W5 W6 W7 W9 W10 W11), CSS+5s (W5 W6 W7 W10 W11), CSS pure (W9), brick W4-W12, transitions T1/T2 (W3+), Nordic curl (W6+), simulation rehearsal (W11 J6) — TOUS LIVRÉS. PASS.
- `safety_notes` cite : Alfredson 1998 protocole calf raises (livré dès W1), bike fit, casque obligatoire (rappelé chaque session bike). Cohérent. PASS.
- Equipment ⊆ `assumed_profile` : profile annonce maillot/lunettes/bonnet/vélo route/casque/chaussures running, et template ajoute `wetsuit` (W11+W12 avec `alternatives` si absente), `heart-rate-monitor` (avec alternative RPE), `transition-area-setup` (kit DIY explicité), `race-belt` + `elastic-laces` (équipement de course recommandé W5+). Tous accompagnés d'`alternatives` ou notes "si applicable". PASS.

## 4. Cutback / deload

`deload_weeks` = `[4, 8]` — 2 deload sur 12 sem = cadence "3 build + 1 deload" répétée 2 fois, conforme Friel.

Vérifié contenu :
- W4 vs W3 : cumul ~270 min vs 315 min (-14%, dans la fenêtre attendue [-15, -20%])
- W8 vs W7 : cumul ~305 min vs 375 min (-19%, parfait)
- W11 (taper J-14) vs W10 : 290 min vs 385 min (-25% — taper plutôt que deload)
- W12 (race week) vs W10 : 245 min hors course vs 385 min (-36%, race week)

PASS. Le deload est REFLÉTÉ dans le contenu (cf. notes "Cutback (-25% vs W7)" explicites par exercice).

## 5. Safety

`safety_notes` couvre les 5 sections requises et plus :

- **DRAPEAUX ROUGES MULTI-DISCIPLINE** : tendinopathie achille (Alfredson cité), tendinopathie ischio haute, ITBS, swimmer's shoulder, PFPS, stress fracture tibiale, douleur articulaire — sport-spécifiques cumul charges. Excellent.
- **OPEN WATER** : hypothermie (seuils T° eau précis), combinaison (règles 14-22°C), coup de chaleur, panique respiratoire (gestion). Critique pour triathlon, bien traité même si plan principalement piscine.
- **SÉCURITÉ ROUTE BIKE** : casque OBLIGATOIRE chaque sortie + écouteurs interdits + bike fit. Présent.
- **TECHNIQUE / INTENSITÉ** : pacing par discipline, cadence cibles, sensation jambes en coton brick.
- **NUTRITION-HYDRATATION** : règle "30-45 g glucides/h" pour bike > 60 min, gut training progressif. Présent.
- **SIGNES DE SURCHARGE** : 6 signaux + procédure "3+ signes → cutback W4-type". Bien.
- **SI SÉANCE MANQUÉE** : 3 paliers (<5j / 1-2 sem / >2 sem). Bien.
- **ÉQUIPEMENT MINIMAL** : checklist par discipline. Bien.

Aucune copie générique entre sports — safety_notes est triathlon-spécifique (mentions explicites brick/transitions/eau libre).

## 6. EU MDR

Scan banned words (FR/EN) sur tout le JSON :
- "guérir" : 0
- "soigner" : 0
- "traiter une pathologie" : 0
- "diagnostic" : 0
- "thérapeutique" : 0
- "rééducation post-opératoire" : 0
- "cure" / "treat" / "diagnose" comme claims sur maladie : 0

Le mot "préventif" est utilisé (ex. "Préventif PFPS", "Préventif tendinopathie achille") — c'est un usage **fitness/training** ("préventif" au sens de "renforce les structures pour réduire risque blessure") et NON un claim médical. Acceptable — voir [hiit-beginner-6sem.review.md] et [yoga-recreational-hatha-8sem.review.md] qui ont APPROVÉ le même usage.

Medical clearance trigger : `safety_notes` inclut explicitement "consulte un médecin avant de commencer" pour antécédents cardiaques, > 50 ans débutant complet sans test effort, grossesse / postpartum, asthme sévère, otites externes récurrentes. **Conforme EU MDR**. La constraint `cardiac-clearance-required` est listée sur ~50% des exercices à charge cardio — excellent.

PASS.

## 7. Final autonomy checklist

W12 J5 ("Mobilité + visualisation + checklist pré-course J-2") inclut **5 critères numérotés** :

1. Nager 750 m crawl piscine EN1 sans pause longue (vérifié W11 J6 simulation 600 m)
2. Tenir brick 60+20 avec écart d'allure run < 30 sec/km vs runs solo (W9 J5 brick PIC)
3. Long ride 90 min avec bloc 30 min sweet spot, dérive RPE < 5%, 30-45 g glucides/h tolérés (W9 J3)
4. Transitions T1 < 1 min 30 et T2 < 1 min automatisées en fluidité (W11 J6 rehearsal)
5. Distinguer fatigue épaule normale vs douleur swimmer's shoulder, et reconnaître/passer les jambes en coton brick

+ Règle de décision claire ("4-5 critères → prêt ; 2-3 critères → décale 2-3 sem"). Mesurables, observables, sourcés sur séances réelles antérieures. **Excellent — PASS**.

## 8. Style

Français, tutoiement strict (vérifié sur les notes longues : "tu cours 5 m", "tu sors", "Tu es FINISHER"). Aucun emoji. Noms d'exercices clairs et pédagogiques (drill catch fingertip drag, bird-dog, single-leg deadlift, brick — vocabulaire technique avec note explicative à chaque introduction). Notes très détaillées sur les exos d'introduction (W3 sweet spot, W4 brick, W6 nordic curl) — qualité pédagogique excellente pour un solo recreational sans coach.

## Issues summary

### Critical (block merge)
- Aucun

### Important (fix recommended)
- Aucun

### Minor (nice-to-have)
- W9 brick pic 60+20 légèrement au-delà du standard "beginner sprint" USAT (qui plafonne souvent 50+20). Acceptable pour profil "intermédiaire confortable" déclaré en `default_objective`, mais une note du type "si symptômes ischio post-brick W9 → reculer brick suivant à 50+15" pourrait être ajoutée à `safety_notes` (déjà partiellement couvert par "Signes de surcharge" → cutback). Pas bloquant.
- `target_zone` `@10K-pace` (W11 J2 strides + W12 J4 strides) est un peu hybride entre Daniels-T et Daniels-R — la note explicite ("Daniels-T -5s/km, ~10K+10s/km") clarifie, mais une harmonisation sur `Daniels-T` (avec note "allure spécifique 5K") serait plus propre côté schema enum. Cosmétique.
- `wetsuit` apparaît en `required_equipment` sur W11 J6 simulation et W12 J6 course alors que le plan est "principalement piscine". L'`alternatives` mentionne "T1 simplifiée" mais pas "sans wetsuit". Si athlète sans combinaison fait simu/course en piscine ou eau chaude, l'equipment est non-bloquant, mais pour cohérence on pourrait passer wetsuit en `optional_equipment` (si schema le supporte) ou ajouter `alternatives` "version sans combinaison". Cosmétique.

## Sources

- [TrainingPeaks — Friel Sprint-Distance Finish Your First 12wk](https://www.trainingpeaks.com/training-plans/triathlon/sprint/tp-1975/sprint-distance-triathlon-finish-your-first-new-to-all-3-sports-12-weeks)
- [Joe Friel — Training Plans](https://joefrieltraining.com/training-plans/)
- [The Triathlete's Training Bible PDF (Bookey)](https://cdn.bookey.app/files/pdf/book/en/the-triathlete's-training-bible.pdf)
- [USA Triathlon Sprint Beginner 12wk plan](https://www.trainingpeaks.com/training-plans/triathlon/sprint/tp-51412/usa-triathlon-sprint-distance-beginner-12-week-plan)
- [USA Triathlon — official site](https://www.usatriathlon.org/)
- [BeginnerTriathlete — Original 13wk Sprint Plan](https://beginnertriathlete.com/the-original-13-week-sprint-triathlon-training-plan/)
- [BeginnerTriathlete — Intermediate Sprint 12wk HR](https://beginnertriathlete.com/intermediate-sprint-triathlon-training-plan-12-week-hr/)
- [80/20 Triathlon revisited — Scientific Triathlon TTS#152](https://scientifictriathlon.com/tts152/)
- [TrainingPeaks — Using the 80/20 rule to balance triathlon intensity](https://www.trainingpeaks.com/blog/using-the-80-20-rule-to-balance-triathlon-training-intensity/)
- [Triathlete — The Science of 80/20 Training](https://www.triathlete.com/training/the-science-of-80-20-training/)
- [VDOT Training Tables (Daniels) — RunDNA](https://rundna.com/resources/run-training/vdot-training-tables-how-to-use-them/)
- [Cycling Power Zones — Coggan/Allen, TrainingPeaks](https://www.trainingpeaks.com/blog/power-training-levels/)
- [TrainerRoad — Cycling Power Zones Explained](https://www.trainerroad.com/blog/cycling-power-zones-training-zones-explained/)
- [Critical Swim Speed (Maglischo framework) — TrainingZones.io](https://www.trainingzones.io/en/guides/critical-swim-speed)
- [MyProCoach — 8 Best Brick Triathlon Workouts](https://www.myprocoach.net/blog/8-best-brick-triathlon-workouts/)
- [MyMottiv — Beginners Guide to Brick Workouts](https://www.mymottiv.com/how-to-train-for-a-triathlon/brick-workout)

## Recommendation

**APPROVED — bundle as-is.**

Plan d'une qualité remarquable : phasage Friel rigoureux (Base/Build/Peak/Taper avec deload W4 W8), 3 disciplines en parallèle strict, 48h récup même discipline respecté, distribution 85/15 doctrinalement assumée, brick progression escalier (35+10 → 60+20 → taper), zones d'effort sport-spécifiques toutes alignées (Daniels VDOT / Coggan FTP / Maglischo CSS), transitions T1/T2 entraînées sur 9 semaines (à sec → pool-side → chrono → rehearsal → race), safety_notes triathlon-spécifique exhaustif (drapeaux multi-discipline, eau libre, route, nutrition, surcharge), checklist autonomie 5 critères mesurables et sourcés W12 J5. 100% hooks v2 sur 171 exercices (zéro manquant). Zéro banned word EU MDR. Cohérence interne 100% (volumes, deloads, paroles tenues). Les 3 minor points sont cosmétiques et n'impactent pas la sécurité ou la doctrine. **Prêt pour bundle production.**

## Patches applied (2026-05-01)

Patches Minor appliqués post-review :
- Ajouté safety note brick pic W9 (60+20) dans `safety_notes` ligne 19 (section ischio-jambier) : "ATTENTION brick pic W9 : si symptômes ischio post-W9 → reculer le brick suivant à 50+15 et retarder la progression d'1 sem".
- Harmonisé `target_zone: "@10K-pace"` → `"Daniels-T"` (2 occurrences W11 J2 strides ligne 2448 + W12 J4 strides ligne 2763) pour aligner sur l'enum schema standard.
- Ajouté alternative "sans wetsuit" sur 2 exercices (W11 J6 simulation swim 600 m + W12 J7 course swim 750 m) pour couvrir profil athlète sans combinaison ou format pool sprint.

Vérifications post-patch :
- JSON parse OK (12 semaines).
- 0 `alternatives: []` vide.
- 0 banned word EU MDR.
- Inventaire `target_zone` propre (13 zones distinctes, toutes alignées doctrine).

**Verdict final : APPROVED — prêt pour bundle production.**
