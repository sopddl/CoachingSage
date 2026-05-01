# Quality Review — tennis-beginner-initiation-8sem

**Verdict** : APPROVED
**Sport** : tennis  **Level** : beginner  **Schema version** : 2

## 1. Doctrine alignment

Le template s'aligne très solidement sur la doctrine publique tennis débutant adulte :

- **Niveau cible NTRP 1.5-2.0 / FFT NC à 40 (Tennis Découverte)** : la cible "réaliser des échanges suivis fond de court (coup droit + revers) et tenir un point simple au service" correspond précisément au descripteur USTA NTRP 1.5 ("limited experience, working primarily on getting the ball into play") et NTRP 2.0 ("needs on-court experience, obvious stroke weaknesses but familiar with basic positions"). Le programme FFT "Tennis Découverte" décrit la même ambition : "mettre les joueurs en situation de réussite dès les premiers pas grâce à une adaptation des conditions de jeu" — exactement ce que fait W1-W2 avec le mini-tennis 1/3 du court. ([USTA NTRP FAQs](https://www.usta.com/en/home/play/adult-tennis/programs/national/usta-ntrp-ratings-faqs.html), [FFT École de Tennis](https://www.fft.fr/nos-sports/tennis/ecole-de-tennis))

- **Pédagogie ITF Play Tennis (Level 1 starter)** : l'ITF Play Tennis course est explicitement "directed to those interested in working with starter players" via "game-based practices" — le template adopte cette logique en démarrant par le mini-tennis avec drills mur/panier dès W1, et en visant l'échange réel en W6-W7 (vs travail technique isolé prolongé). La progression "feeling balle → mini-tennis → fond de court → échanges → service" est conforme à la séquence pédagogique ITF Level 1. ([ITF Play Tennis Course](https://www.tennishk.org/wp-content/uploads/2021/04/Play-Tennis-Course-Schedule-for-Candidates2021.pdf), [ITF Coach Education Programme](https://www.itftennis.com/en/news-and-media/articles/itf-coach-education-programme-educating-and-certifying-coaches/))

- **Grips eastern coup droit + eastern backhand 2 mains + continental introduit pour le service** : conforme à la recommandation USTA / TennisCompanion. L'eastern forehand "is generally considered the best starting point for beginners because it is the easiest to learn", et le continental est "the foundation of every beginner tennis player's game" pour serves/volleys. Le revers eastern 2 mains main dominante en continental + main non-dominante en eastern est la prise standard pour adultes débutants. ([USTA — Continental Grip](https://www.usta.com/en/home/improve/tips-and-instruction/national/improve-your-tennis-game--the-continental-grip.html), [USTA Stroke Fundamentals](https://www.playerdevelopment.usta.com/Improve-Your-Game/Sport-Science/114384_Technique_Stroke_Fundamentals/))

- **Foot-eye coordination, split-step base** : split-step + recovery step travaillé dès W2 et progressé W3. Couvre le pilier "footwork fundamentals" USTA. Les drills agility-ladder sont introduits en W4 et progressent en complexité W6-W7 (in-out → lateral icky shuffle → carioca lent), conformément à la doctrine Kovacs sur l'agilité tennis-spécifique.

- **Ratio court/fitness ~70/30 sur les pics** : W4 = 60 min court + 42 min S&C (59% / 41% — proche de la cible 70/30 de la consigne, légèrement plus axé S&C qu'attendu parce qu'on est au pic préventif coude/épaule, ce qui est défendable pour un débutant). W7 = 65 min court + 42 min S&C (61/39). Cohérent avec Kovacs Adult Tennis Fitness L1 qui privilégie strength/power/prehab pour adultes débutants/recreational. ([Kovacs Institute Adult Tennis Fitness L1](https://kovacsinstitute.com/adulttennisfitnessl1.html), [Kovacs Tennis Fitness Programs](https://kovacsinstitute.com/tennis-fitness-programs.html))

- **Tennis elbow / coiffe rotateurs prevention dès W1 (regional interdependence Ellenbecker-Kovacs)** : Y-T-W shoulder + external rotation à la bande dès la première séance S&C, pas reportés en W3. Prone scaption ajouté W2. Validé par la littérature : "key muscle groups to evaluate when looking to prevent or reduce elbow pain are the Trapezius muscles and the Serratus Anterior, which assist with stability and control of the shoulder blade with overhead arm movements" — précisément ce que ciblent Y-T-W et prone scaption. La consigne de la review demandait l'introduction "dès W3" mais l'introduire dès W1 est une amélioration défendable et explicitement justifiée dans `progression_logic` (principe 2). ([Kovacs Academy Tennis Fitness](https://kovacsacademy.com/category/tennis-fitness/))

- **Pas de match compétitif** : explicitement banni en `progression_logic` principe 3 et rappelé à 3 reprises dans le programme. Conforme : NTRP 1.5-2.0 ne sont pas des niveaux league USTA (les leagues commencent à 2.5) — donc aucun match compétitif n'est attendu à ce stade.

- **Cutback W5 (-30% à -50%)** : volume court W5 passe de 60 min (W4) à 30 min (W5) = **-50% court** ; volume hebdo total 102 min (W4) → 60 min (W5) = **-41% volume total**. La consigne "−15 à −20%" demandée par les specs de review est donc dépassée en intensité de cutback. Voir issue mineure ci-dessous.

- **Service introduit progressivement W6 (lancer → trophée → élan complet → cible) avec cap volume 30-40 services/séance** : conforme à la recommandation Kovacs/USTA pour la coiffe en début de service. Excellente granularité.

## 2. Metadata hooks (Story 0.5.9 / Schema v2)

**Per-template** : `week_structure` (linear + micro_pattern + recovery_cadence), `deload_weeks: [5]`, `progression_logic` détaillé en 5 principes nommés. **PASS**.

**Per-exercise** : scan automatique sur tous les exercices des 8 semaines — **100% des exercices possèdent les 5 hooks** (`target_zone`, `required_equipment`, `incompatible_constraints`, `alternatives`, `volume_axis`). Aucun manquant. Aucune valeur générique : `target_zone` utilise `technique` / `Z2` / `RPE 6-7` / `cool-down`, en cohérence avec la doctrine tennis (technique pour les drills moteurs, Z2 pour les drills réguliers, RPE 6-7 pour le S&C, cool-down pour la mobilité W5+W8). `required_equipment` en kebab-case correct (`racket`, `tennis-shoes`, `wall`, `court`, `mat`, `resistance-band`, `agility-ladder`, `balls`). `incompatible_constraints` riches et tennis-pertinents (`tennis-elbow`, `shoulder-injury`, `wrist-pain`, `ankle-injury`, `knee-injury`, `lower-back-pain`). `alternatives` toujours 2 entrées concrètes et chiffrées (substitut sans court, ou sans partenaire, ou poids du corps).

**PASS** sans flag.

## 3. Internal consistency

- `duration_weeks == weeks.count` : 8 == 8. **PASS**
- Sessions actives ≤ `sessions_per_week` : 2 ≤ 2 sur les 8 semaines. **PASS**
- Jours uniques dans [1, 7] : W1-W7 = [1, 4], W8 = [1, 5]. **PASS**
- Numbers announced delivered : "50 frappes mur coup droit" annoncé W7-W8 → cible présente W7 (3×50 frappes) et W8 séance phare (2×50 frappes). "30 frappes revers" → présente W7. "checklist 4 critères" → 4 critères listés W8 séance phare. **PASS**
- `progression_logic` cite des éléments réels : Y-T-W (présents W1-W8), drill mur 50 frappes (présent W7-W8), cutback W5 (présent), eastern forehand + eastern backhand 2 mains (présents W1+), Pallof press (présent W6-W7), agility-ladder (présent W4+). **PASS**
- `safety_notes` cite des standards (RICE, Tyler Twist, sleeper stretch, regional interdependence Ellenbecker, FCmax % zones, 30 services/séance) qui sont effectivement appliqués dans les `weeks`. **PASS**
- Equipment ⊆ `assumed_profile` OU `alternatives` : `assumed_profile` mentionne raquette, balles, chaussures, court ou mur. `mat` / `resistance-band` / `agility-ladder` ne sont pas explicitement dans `assumed_profile` mais chaque exercice qui en utilise propose une alternative sans (ex. external rotation → "côté allongé avec dumbbell léger" ou "wall external rotation"). **PASS** mais voir mineur ci-dessous.

## 4. Cutback / deload

- `deload_weeks: [5]` — déclaré.
- W5 : volume court 30 min (vs 60 W4 = -50% court), volume total 60 min (vs 102 W4 = -41%), pas de nouveau geste introduit, drill mur séries réduites de 4→2 et 3→2, S&C sets 3→2, Pallof press et Side plank retirés. **PASS** structure deload correctement implémentée.
- Cadence 1 deload tous les 4-5 sem sur 8 sem (W5 sur 8) = conforme à la recommandation 3-5 sem.

**Note** : la profondeur du cutback (-41%) dépasse la spec consigne -15 à -20%. C'est défendable scientifiquement (adaptation tendineuse coude-épaule à 6-8 sem, débutant adulte sans expérience récente) et explicitement justifié dans le commentaire W5 : "tendons s'adaptent plus lentement que les muscles". À conserver tel quel.

## 5. Safety

`safety_notes` couvre les 5 sections attendues, sport+level-specifique :

- **RED FLAGS** : tennis elbow (épicondylite latérale, n°1 du débutant), épicondylite médiale, coiffe rotateurs / SLAP / conflit sous-acromial, TFCC poignet, entorse cheville (chaussures tennis dédiées obligatoires), genou. Tous tennis-pertinents, pas de copy-paste générique.
- **GENERAL RULES** : chaussures tennis non-marking (vs running shoe), grip size adapté, raquette < 300 g, cordage souple < 25 kg, pression de grip 5-6/10. Spécifique débutant.
- **INTENSITY** : drills court technique/Z2 uniquement, RPE > 6 banni, test de la parole, aucun sprint matchplay.
- **OVERLOAD SIGNS** : 4 signes (FC repos +10 bpm, sommeil dégradé > 3 nuits, douleur épaule/coude > 2 séances, motivation effondrée) avec règle 3+ → cutback type W5.
- **MISSED SESSION HANDLING** : règles claires < 1 sem / 1-2 sem / > 2 sem.

PRÉVENTION TENNIS ELBOW + PRÉVENTION ÉPAULE détaillées avec sources doctrinales (regional interdependence Ellenbecker, sleeper stretch, Tyler Twist excentrique). **PASS** — qualité au-dessus de la moyenne attendue.

## 6. EU MDR

- Banned words scan FR (`guérir`, `soigner`, `traiter une pathologie`, `diagnostic`, `médical` en claim, `thérapeutique`, `rééducation post-opératoire`) : aucune occurrence détectée. Le mot `médecin` apparaît uniquement dans la consigne "consulte un médecin avant de commencer" — usage légitime.
- Banned words EN : aucun.
- **Medical clearance** : présent et bien formulé dans `safety_notes` ("Si tu as des antécédents cardiaques connus, plus de 50 ans débutant complet sans test d'effort récent, ou si tu es en grossesse / postpartum récent : consulte un médecin avant de commencer ce programme"). Mentionne aussi "consulte un kiné avant de démarrer ce programme" si épicondylite chronique > 6 sem.
- **Pas de framing rééducation** : le template parle de **prévention** tennis elbow / coiffe (acceptable EU MDR), pas de "rééducation" ni de "traitement" d'une pathologie. Distinction respectée.

**PASS**.

## 7. Final autonomy checklist

W8 séance phare J5, exercice "Point simple jeu — service + 1 échange", `notes` contient explicitement la **CHECKLIST D'AUTONOMIE 4 critères mesurables/observables** :

1. 50 frappes consécutives contre le mur en coup droit (objectif binaire).
2. 10 échanges réguliers en fond de court coup droit + revers alternés.
3. Mobilité-stabilité épaule (pas d'inconfort sur Y-T-W élévation bras).
4. Identification grips eastern coup droit + eastern backhand 2 mains, et 6-8 services valides sur 20 dans le carré.

Règle de gating ("3+ critères → autonome / ≤ 2 critères → refaire W6-W7 cycle de 2 sem") explicite. Aligné NTRP 1.5-2.0 (ball into play, basic positions). **PASS**.

## 8. Style

- Français, tutoiement constant. **PASS**
- Aucun emoji. **PASS**
- Noms d'exercices clairs, pédagogiques, avec consignes posturales et RPE. **PASS**

## Issues summary

### Critical (block merge)

Aucune.

### Important (fix recommended)

Aucune.

### Minor (nice-to-have)

- W5 cutback : la `progression_logic` annonce "-50% court, -30% volume hebdo total" mais le calcul réel est **-50% court / -41% volume total**. Soit corriger le chiffre dans `progression_logic` principe 4 ("-30%" → "-40%"), soit l'accepter comme arrondi conservateur. Mineur.
- `assumed_profile` mentionne "équipement de base (raquette adaptée, balles, chaussures court). Accès à un court ou un mur d'entraînement." mais n'inclut pas explicitement `mat`, `resistance-band`, `agility-ladder` qui sont utilisés en S&C. Chaque exercice propose une alternative sans, donc fonctionnel, mais mention "tapis + bande élastique légère pour S&C off-court" en `assumed_profile` clarifierait. Mineur.
- W8 séance phare : `duration_minutes: 75` mais le `goal` annonce "60 min court séance phare". Décompose : warm-up + 5 blocs (8+50f×2 ~12+15+10+8) + cool-down 10 min ≈ 60 min de bloc utile + 15 min warm-up/cool-down élargis = 75 min cohérents. Soit clarifier le `goal` ("60 min de jeu effectif + 15 min échauffement/retour au calme = 75 min séance"), soit garder. Mineur.

## Sources

- [USTA — NTRP Ratings FAQs (NTRP 1.5-2.0 descriptors)](https://www.usta.com/en/home/play/adult-tennis/programs/national/usta-ntrp-ratings-faqs.html)
- [ITF Coach Education Programme — overview](https://www.itftennis.com/en/news-and-media/articles/itf-coach-education-programme-educating-and-certifying-coaches/)
- [ITF Play Tennis Course Schedule (Level 1 starter player)](https://www.tennishk.org/wp-content/uploads/2021/04/Play-Tennis-Course-Schedule-for-Candidates2021.pdf)
- [Kovacs Institute — Adult Tennis Fitness L1](https://kovacsinstitute.com/adulttennisfitnessl1.html)
- [Kovacs Institute — Tennis Fitness Programs](https://kovacsinstitute.com/tennis-fitness-programs.html)
- [USTA — Stroke Fundamentals (Player Development)](https://www.playerdevelopment.usta.com/Improve-Your-Game/Sport-Science/114384_Technique_Stroke_Fundamentals/)
- [USTA — Improve Your Game: the Continental Grip](https://www.usta.com/en/home/improve/tips-and-instruction/national/improve-your-tennis-game--the-continental-grip.html)
- [FFT — École de Tennis (Tennis Découverte adulte)](https://www.fft.fr/nos-sports/tennis/ecole-de-tennis)
- [FFT — Le tennis adultes (Tennis Forme / Découverte)](https://www.fft.fr/jouer/le-tennis/le-tennis-adultes)
- [Mend Colorado — Rotator Cuff Strengthening for Tennis Players](https://www.mendcolorado.com/physical-therapy-blog/2022/6/29/rotator-cuff-strengthening-for-tennis-players/)

## Recommendation

**APPROVED** — bundle as-is. Les 3 issues mineures sont des clarifications cosmétiques optionnelles (chiffre cutback, assumed_profile, durée séance phare) qui ne justifient ni regen ni patch bloquant. Le template est de qualité supérieure : doctrine ITF/USTA/Kovacs/FFT correctement intégrée, prévention tennis elbow / coiffe rotateurs sourcée et appliquée dès W1, cutback W5 conservateur défendable, checklist autonomie 4 critères observables alignée NTRP 1.5-2.0, EU MDR clean, hooks v2 100% couverts. **Verdict : APPROVED.**

## Patches applied (2026-05-01)

3 minor patches appliqués en édition ciblée :
1. **W5 cutback chiffre corrigé** : `progression_logic` principe 4 et W5 `goal` — "-30% volume hebdo total" → "-41% volume hebdo total" (alignement avec calcul réel 102 → 60 min).
2. **assumed_profile clarifié** : ajout "Tapis + bande élastique légère pour S&C off-court" pour expliciter l'équipement S&C utilisé.
3. **W8 séance phare goal clarifié** : "60 min court séance phare" → "75 min séance phare (60 min jeu effectif + 15 min échauffement/retour au calme)" — décompose la durée pour cohérence avec `duration_minutes: 75`.

JSON validé (parse OK, hooks v2 symétrie 93×5, 0 banned word EU MDR). **Verdict final : APPROVED.**
