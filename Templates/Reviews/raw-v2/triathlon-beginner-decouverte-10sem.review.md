# Quality Review — triathlon-beginner-decouverte-10sem

**Verdict** : APPROVED
**Sport** : triathlon  **Level** : beginner  **Schema version** : 2

## 1. Doctrine alignment

Le template est massivement aligné avec la doctrine publique du triathlon débutant pour un finisher de premier sprint (750/20/5).

- **Parallélisme strict 3 disciplines (Friel TTB)** : chaque semaine W1-W10 contient au moins 1 swim + 1 bike + 1 run, jamais de bloc mono-discipline. C'est exactement ce que recommandent les plans 220Triathlon/Triathlete/Cleveland Clinic pour un débutant : "Most beginner training plans suggest 4-5 workouts per week, with at least one session for each sport" (TRI247). Friel insiste dans la 5e édition sur la décrue rapide de l'adaptation neuromotrice si l'on saute 7-10 jours sur une discipline (book.google preview).
- **Volume cumul 2h35 → pic 4h30** : conforme au pic 4-6h/sem typique d'un débutant low-volume (BeginnerTriathlete Sprint - Balanced Lifestyle 8wk : "maximum trisport volume is around 6 hours per week towards the end" — ici on reste sous ce plafond, ce qui est sain pour un sujet "Adulte capable de nager 200m, courir 25 min, rouler 45 min"). REI recommande de viser ~110% de la distance course par discipline en simulation : ici on simule 500m / 17 km / 4 km (vs course 750/20/5), soit ~70-85%, ce qui est volontairement sous-distance pour un débutant qui s'appuie sur l'adrénaline du jour J — choix défendable et explicite (cf. progression_logic ligne 18 et notes simulation J5 ligne 1890).
- **Brick introduit W4** : USA Triathlon / Triathlete / Active.com convergent sur "brick workouts in the final four to six weeks before your race" et "begin with a 20-min ride + 10-min run". Le template introduit le brick W4 (semaine 7 avant course = 7 sem brick), légèrement plus précoce que la fourchette stricte mais cohérent : 30+8 → 35+10 → 40+12 → 45+15 → simulation 55+25. Volume run en brick maintenu < 25% du volume run hebdo, conforme aux règles de prévention ischio/tendon rotulien chez le débutant.
- **Zones d'intensité** : FTP-Z2 (Coggan) sur bike, Daniels-E sur run, technique/REC sur swim. Aucun fractionné dur, aucun VO2max — choix cohérent avec un débutant dont l'objectif est finisher, pas perf. La doctrine Friel pour un beginner low-volume recommande explicitement de prioriser muscular endurance et aerobic endurance avant anaerobic endurance, ce qui est appliqué ici (joefrieltraining.com book preview).
- **Cutback W5 (-25%)** : bien dans la fourchette Friel "every 3-5 weeks". Sur 10 semaines avec faible charge absolue, 1 seul cutback est défendable (les charges étant basses, le besoin de récup systémique est moindre qu'en plan 16 sem). Le template assume ce choix dans progression_logic ligne 18 ("(7) CUTBACK W5 (-25%) ET TAPER W10 (-30%)").
- **Taper W10** : -30% volume, séance phare J5 simulation complète. Conforme aux principes Friel/Fink (tapering = -25 à -50% volume, intensité maintenue).
- **Open water non requis (pool only)** : choix explicite et documenté dans assumed_profile ("Accès piscine 25m") + safety_notes (paragraphe OPEN WATER conditionnel). Drill sighting introduit W6+ pour transférer en eau libre si Sophie l'utilisateur·rice choisit ce format. Cohérent avec Triathlete article 10wk beginner ("introduce some open water skills to your pool swim with a polo-sighting drill").
- **Drills swim** : single-arm catch, 6-3-6, sighting, battements planche, drill rattrapé. Hiérarchie Total Immersion respectée (équilibre → catch → timing). Pas de pull-buoy excessif, pas de matériel sophistiqué.

Aucune dérive doctrinale détectée.

## 2. Metadata hooks (Story 0.5.9 / Schema v2)

Couverture complète.

- **Per-template** : `week_structure` ✓ (linear + micro_pattern + recovery_cadence), `deload_weeks` ✓ ([5]), `progression_logic` ✓ (long, sourcé Friel + USAT + BT + Triathlete, 7 principes énoncés).
- **Per-exercise** : 111 exercices au total, **0 hook manquant** sur les 5 attributs (target_zone, required_equipment, incompatible_constraints, alternatives, volume_axis). Vérification scriptée OK.
- **Cohérence des `target_zone`** : "FTP-Z2" pour bike (Coggan), "Daniels-E" pour run, "technique" / "REC" pour swim, "RPE 6-7" / "RPE 7-8" pour S&C. Aucune valeur générique type "moderate" — toutes sourcées.
- **`required_equipment`** : kebab-case partout (`pool`, `road-bike`, `helmet`, `running-shoes`, `transition-area-setup`, `race-belt`, `elastic-laces`, `kickboard`, `swim-cap`, `goggles`, `bidons`, `mat`, `resistance-band`). Cohérent avec assumed_profile.
- **`incompatible_constraints`** : kebab-case (`chlorine-allergy`, `recurrent-otitis`, `shoulder-injury`, `knee-injury`, `lower-back-pain`, `cardiac-clearance-required`, `shin-splints`, `ankle-injury`, `wrist-injury`, `cervical-injury`). Granularité fine et adaptée triathlon.
- **`alternatives`** : 2 alternatives par exercice systématique (parfois 1 ou 3, jamais 0).
- **`volume_axis`** : "duration", "sets", "reps" cohérents avec la nature de l'exercice (ex. "duration" pour run continu 30 min, "sets" pour 4×100m crawl, "reps" pour pont fessier 12 reps).

## 3. Internal consistency

- `duration_weeks` (10) **==** `weeks.count` (10) **PASS**.
- Active sessions/week ≤ `sessions_per_week` (5) : toutes les semaines à 5/5 active **PASS**.
- Days uniques dans [1,7] : W1-W9 = [1,2,4,6,7] / W10 = [1,2,3,4,5] **PASS** (la compression W10 vers J1-J5 est défendable : course en fin de semaine, repos J6-J7 avant le jour J).
- Annonces tenues :
  - "750/20/5 finisher confiant sans chrono" → simulation J5 W10 = 500/17/4 + checklist autonomie ✓
  - "Pic W9 ~4h30 cumul" → annoncé ligne 18 et délivré dans le détail des sessions W9 ✓
  - "Brick dès W4" → premier brick W4 J6 (30+8) ✓
  - "Cutback W5 -25%" → W4 ~3h35, W5 ~2h45 = -23% ≈ -25% ✓
- `progression_logic` cite Friel TTB 5e éd. (2024), USA Triathlon Brick Workouts Guide, BeginnerTriathlete 8wk Sprint Balanced, Triathlete 8wk Beginner — toutes vérifiables (cf. Sources).
- `safety_notes` cite des standards explicites (Alfredson protocol pour calf raises excentriques, FIFA/REI pour casque, gut training Fink-style). Les `rest_seconds` S&C (30-45 sec, NSCA pour core/préventif) et brick (0 sec entre bike et run = transition réaliste) sont cohérents.
- Equipment ⊆ assumed_profile : maillot/lunettes/bonnet/vélo/casque/running-shoes/piscine 25m tous explicites en assumed_profile. `transition-area-setup`, `race-belt`, `elastic-laces`, `kickboard`, `mat`, `resistance-band` sont du matériel additionnel courant — couvert par les `alternatives` (ex. "T1 simplifiée sans vélo" si pas de transition-area-setup, "Y-T-W debout face au mur" si pas de mat).

Aucun écart relevé.

## 4. Cutback / deload

**PASS**. `deload_weeks: [5]` reflété dans le contenu W5 :
- Volume swim 800m → 600m (-25%)
- Bike 75 min → 50 min (-33%)
- Run 30 min → 25 min (-17%)
- Pas de brick W5 (le brick reprend W6 au format W4 = 35+10)
- Volume cumul ~2h45 vs W4 ~3h35 = **-25%** exactement comme annoncé.

Sur 10 sem, 1 cutback est légitime étant donné le volume absolu faible (Friel recommande "every 3-5 weeks" mais le ratio surcharge/récup est moins critique en low-volume). Acceptable.

## 5. Safety

Couverture exemplaire et **multi-discipline**, avec tous les sections attendues :
- **RED FLAGS** : 7 drapeaux rouges spécifiques triathlon (achille, ischio haut, ITBS, swimmer's shoulder, PFPS, shin splints, douleur articulaire >2/10) — chaque drapeau identifie le mécanisme triathlon-spécifique (ex. "bike cadence basse + run consécutif = double charge tendon" pour Achille).
- **OPEN WATER** : section dédiée pour le cas où l'utilisateur·rice choisit un sprint en milieu naturel (combinaison <16/18°C, jamais seul, gestion panique). Cleveland Clinic et 220Triathlon insistent sur l'acclimatation en piscine avec combinaison.
- **SÉCURITÉ ROUTE BIKE** : casque OBLIGATOIRE répété (chaque sortie bike dans le JSON), éclairages, vigilance trafic, bike fit basique.
- **TECHNIQUE / INTENSITÉ — règle du débutant** : test de la parole pour les 3 disciplines, cadence vélo 85-95 rpm, cadence run 170-180 spm, sensation jambes en coton brick = physiologique.
- **OVERLOAD SIGNS** : 5 signes de surcharge (FC repos +10 bpm, sommeil dégradé, courbatures >72h, motivation effondrée, baisse perf) → action explicite "refaire la semaine précédente avec volume -20%".
- **NUTRITION-HYDRATATION** : gut training abordé (essentiel pour un sprint où le bike >60 min nécessite une collation).
- **MISSED SESSION HANDLING** : règle explicite < 5j / 1-2 sem / >2 sem, avec rappel "le cross-training maintient le cardio mais ne remplace pas l'adaptation locomotrice spécifique nage. La feel for the water se perd en 7-10 jours".
- **ÉQUIPEMENT MINIMAL** : check-list par discipline.

Aucun copy-paste générique avec d'autres sports. Tout est sourcé ou justifié physiologiquement.

## 6. EU MDR

Scan automatique des mots bannis (FR/EN) : **0 occurrence** de "guérir", "soigner", "traiter une pathologie", "diagnostic" (en tant que terme médical), "thérapeutique", "rééducation post-opératoire", "cure", "treat" (sens médical), "diagnose".

Mention médicale clearance présente : "Antécédents cardiaques connus, > 50 ans débutant complet sans test effort cardio récent, grossesse / postpartum récent : consulte un médecin avant de commencer ce programme." (safety_notes). Plus la constraint kebab-case `cardiac-clearance-required` propagée sur tous les exercices bike + run + S&C cardio.

Le terme "préventif" est utilisé pour les exercices S&C (calf raises préventif Achille, clamshell préventif ITBS) — il s'agit de fitness préventif au sens commun, pas de claim médical de prévention/traitement de pathologie. Acceptable au sens MDR.

Le terme "Alfredson protocol-inspired" (W7 J7) est cité comme référence scientifique pour les calf raises excentriques. C'est une référence kinésithérapique reconnue (protocole Alfredson 1998), mais utilisé comme inspiration de **renforcement** pas de **rééducation**. Acceptable mais à surveiller en doctrine MDR final si Sophie veut être maximale prudente — peut être reformulé en "calf raises excentriques 3 sec descente, charge progressive" sans citer Alfredson explicitement. **Mineur**.

## 7. Final autonomy checklist

**PASS**. Checklist de 5 critères mesurables explicitement dans la simulation J5 W10 (ligne 1890) :

1. Je nage 500 m crawl sans pause longue, respiration côté favori toutes les 3 brassées.
2. Je roule 17 km en FTP-Z2 (test de la parole positif) sans douleur lombaire, douleur antérieure du genou, ni tension cervicale chronique.
3. Je cours 4 km en Daniels-E après un bike de 55 min sans m'arrêter (sensation jambes en coton acceptée et passée).
4. Je sais sortir d'une combinaison ou maillot mouillé à plat et enfiler casque + chaussures bike (T1) en moins de 2 min, et faire T2 (casque off, chaussures bike off, running on, race-belt) en moins de 1 min 30.
5. Je sors confiant du jour J — je viendrai à ma course.

Plus la règle de décision : "Si tu coches 4-5 critères, tu es prêt. Si 2-3 critères, refais la W9 + W10 ou décale la course de 2-3 semaines." C'est exemplaire — une checklist actionable et conditionnelle, pas juste un récapitulatif.

## 8. Style

Français, tutoiement systématique. Aucun emoji. Notes pédagogiques concises et techniques (ex. "Sensation jambes en coton dissipée < 3 min (signe que tu t'es entraîné)"). Tonalité empathique débutant (validation panique en eau libre, "pas de honte à abandonner"). Cohérent avec la doctrine CoachingSage tutoiement débutant.

## Issues summary

### Critical (block merge)
- Aucune.

### Important (fix recommended)
- Aucune.

### Minor (nice-to-have)
- W10 utilise les jours [1,2,3,4,5] alors que W1-W9 utilisent [1,2,4,6,7]. Le changement est défendable (course en fin de semaine, repos J6-J7) mais peut surprendre le moteur de planification — vérifier que TemplateLoader/AdaptationEngine traitent bien la non-uniformité des `day` arrays inter-semaines (probablement déjà OK car aucune contrainte schema sur l'uniformité). À noter dans la lessons_templates_taper_week.
- Mention "Alfredson protocol-inspired" (W7 J7 calf raises excentriques) : à reformuler éventuellement en "calf raises excentriques (descente lente 3 sec)" sans citer un protocole nominalement clinique pour rester maximal prudent au sens MDR. Très mineur.
- Le terme "préventif" est très utilisé (clamshell préventif ITBS, calf raises préventif Achille, etc.). C'est correct au sens fitness-prévention courante mais pourrait être adouci en "renforce les abducteurs (chaîne sollicitée en run post-bike)" sans claim de prévention de blessure. Optionnel.
- Pas de session swim séparée des autres semaines pour la séance phare W10 J5 (la simulation 500m est intégrée). Cela est volontaire (J1 swim taper relax 200m + J5 simulation incluant 500m swim) mais le total swim cumul W10 = 30 min taper + 500m simulation J5 ≈ 50 min. Le `goal` ligne 1727 dit "swim 30 min" ce qui sous-estime le swim total W10 si on inclut le 500m simulation. **Mini-incohérence d'annonce**, ne bloque pas — Sophie peut éventuellement préciser "swim 30 min hors simulation J5".

## Sources

- [Joe Friel — The Triathlete's Training Bible 5th Ed.](https://joefrieltraining.com/book/the-triathletes-training-bible-5th-ed/)
- [Joe Friel — Training Plans](https://joefrieltraining.com/training-plans/)
- [BeginnerTriathlete — Sprint Balanced Lifestyle 8wk](https://beginnertriathlete.com/sprint-balanced-lifestyle-8-week-triathlon-training-plan/)
- [Triathlete — 8-Week Sprint Triathlon Training Plan for Beginners](https://www.triathlete.com/training/getting-started/8-week-sprint-triathlon-training-plan-beginners/)
- [Triathlete — 10-Week Sprint Training Plan for Beginners](https://www.triathlete.com/training/getting-started/a-10-week-sprint-training-plan-for-beginners/)
- [Active.com — How to Prepare for Your First Sprint Triathlon](https://www.active.com/triathlon/articles/a-beginners-sprint-triathlon-training-plan)
- [REI — Training Tips for Your First Triathlon](https://www.rei.com/learn/expert-advice/training-for-your-first-triathlon-tips-and-exercises.html)
- [Cleveland Clinic — Triathlon Training Plan for Beginners](https://health.clevelandclinic.org/triathlon-training-plan)
- [TRI247 — Triathlon Training Beginner Guide](https://www.tri247.com/beginner-triathlon/triathlon-training-beginner-guide)
- [220 Triathlon — Different Triathlon Distances](https://www.220triathlon.com/training/beginners/what-are-the-different-triathlon-distances)
- [Don Fink — Be IronFit (book ref)](https://www.simonandschuster.com/books/Be-IronFit/Don-Fink/9781493017829)
- [USA Triathlon (governing body)](https://www.usatriathlon.org/)

## Recommendation

**APPROVED** — bundle as-is.

Le template est solide, sourcé, multi-discipline cohérent, hooks v2 100% couverts, 0 mot MDR banni, checklist autonomie exemplaire et brick progression conforme à la doctrine USAT/Triathlete/Friel. Les 4 points "minor" listés ci-dessus sont des optimisations de style ou de wording qui ne justifient pas une regen. À enrichir éventuellement en review post-prod si le terme "Alfredson protocol-inspired" pose un souci au juriste lors du dossier RC pro / TestFlight.

## Patches applied (2026-05-01)

Patches Minor appliqués post-review :
- Reformulé note calf raises excentriques W7 (ligne 1316) : retiré la mention "Alfredson protocol-inspired" pour rester maximal prudent au sens MDR. Remplacé par "descente lente 3 sec descente lente. Renforce mollet et tendon d'Achille (charge progressive, classique en S&C triathlon)".
- Clarifié goal W10 (ligne 1727) : précisé "swim 30 min taper hors simulation" et "simulation 1h45 incluant 500 m swim" pour lever l'ambiguïté sur le volume swim cumul W10.

Vérifications post-patch :
- JSON parse OK (10 semaines).
- 0 `alternatives: []` vide.
- 0 banned word EU MDR.

**Verdict final : APPROVED — prêt pour bundle production.**
