# Quality Review — tennis-recreational-regularite-10sem

**Verdict** : APPROVED
**Sport** : tennis  **Level** : recreational  **Schema version** : 2

## 1. Doctrine alignment

### Niveau ciblé NTRP 2.5-3.0 / FFT 30-30/2

Le template positionne explicitement l'`assumed_profile` à NTRP 2.0-2.5 / FFT 40-30/5 entrant et la cible à NTRP 2.5-3.0 / FFT 30-30/2 sortant. C'est cohérent avec les descripteurs USTA :
- **NTRP 2.5** : "learning to judge where the ball is going... can sustain a backcourt rally of slow pace... beginning to develop strokes". Le programme attaque exactement ces lacunes (régularité fond de court, judgement balle, échanges Z2).
- **NTRP 3.0** : "fairly consistent when hitting medium-paced shots... lacks accuracy when trying for directional control... can be uncomfortable at the net". Le programme cible la consistance medium-pace en RPE 5-6 W3+, introduit la directionnalité (cross / long-de-ligne / pattern 1-2 coups), et adresse l'inconfort au filet via progression W6→W10 (ghost-stroking → drill panier 5-10 volées → service-volée). [USTA NTRP Ratings FAQ](https://www.usta.com/en/home/play/adult-tennis/programs/national/usta-ntrp-ratings-faqs.html)

Cible de "fairly consistent medium-pace" parfaitement traduite par les compteurs progressifs de frappes consécutives (15-20 W1 → 30+ W10).

### Échanges 10-15 coups en cross — DEPASSE la cible

Le doctrine check demande 10-15 coups consécutifs. Le programme vise plus haut (15-20 W1, 25-30 W3-4, 30+ W9-10) : c'est un choix volontaire de "régularité-progression" qui place le sortant en haut de NTRP 3.0 / FFT 30-30/2. Cohérent avec le `default_objective` qui annonce "30+ échanges consécutifs" et la checklist autonomie W10 critère 1. Pas un over-shoot — c'est aligné sur le claim explicite du programme.

### Premier service en jeu (60% in-play)

La consigne doctrine "60% premier service en jeu" est traduite en **50-60% W4** puis **6/10 ≈ 60% W4-W6** puis **50-60% en match-simu W10 critère 2**. La progression est mesurée et conservatrice (NTRP 3.0 réaliste). L'assumed_profile parle de "service 50-60% en jeu" en entrée — la sortie cible 50-60% in-play sur 20 services en match-simulation, ce qui est **cohérent NTRP 3.0** (USTA "lacks accuracy when trying for directional control"). Pas de promesse irréaliste type 70%+.

### Volume 10 sem 3-4 sessions/sem, séance 60-75 min — ADAPTATION VOLONTAIRE 2 sessions

Le doctrine indique 3-4 sessions/sem comme cible. Le template choisit explicitement **2 sessions/sem** :
- Une séance court technique pure (75-90 min)
- Une séance court + bloc S&C intégré (60-75 min court + 25-30 min S&C)

Volume hebdo court ~140-175 min + S&C 25-40 min, soit **~165-215 min par semaine**. C'est **dans la plage WHO** (150-300 min modéré ou 75-150 vigoureux) et reste réaliste pour un pratiquant recreational adulte solo. Le choix 2× au lieu de 3-4× est **explicitement défendu** dans le `progression_logic` (récup tendineuse, fenêtre 48h compatible). [Tennis Fitness — Tennis Training Volume](https://www.tennisfitness.com/blog/tennis-training-volume-what-is-the-right-amount), [Voyager Tennis — Training Volume](https://www.voyagertennis.com/featured/how-to-choose-the-right-training-volume-based-on-your-tennis-goals/)

Note : le `progression_logic` mentionne "Voyager Tennis recreational programming" en référence — cohérent. La structure 2 sessions est défendable doctrinalement pour un programme **régularité** centré qualité technique, à condition que le S&C soit intégré (ce qui est le cas).

### Mix court drilling 50% + match play 30% + S&C tennis 20%

Estimation par exercices :
- W1-W2 : ~85% court drilling, 0% match play, 15% S&C ✓ (foundation)
- W4 : ~55% drilling, 25% match play (drill panier 11pts + tie-break 4pts), 20% S&C ✓
- W6-W8 : ~50% drilling, 30% match play (set partiel 4 jeux + drill panier), 20% S&C ✓
- W9-W10 : ~45% drilling, 35% match play, 20% S&C ✓

Cible 50/30/20 atteinte progressivement à partir de W4. Bonne progressivité.

### S&C tennis 20% (Kovacs/Roetert/Ellenbecker)

Bloc S&C présent à chaque W2/séance day 4 :
- Y-T-W shoulder (scapular work)
- External rotation à la bande (rotator cuff infra-épineux + petit rond)
- Pallof anti-rotation (core anti-rotation)
- Single-leg squat / split squat bulgare / hip thrust unilatéral (force unilatérale jambes)
- Med ball rotational throws W7+ (transfert force-vitesse rotation)
- Agility ladder (footwork)
- Cardio intermittent 6→12 sprints 15-20 m (tennis-spécifique intermittent)

C'est **exactement** le canon Kovacs/Roetert/Ellenbecker *Complete Conditioning for Tennis* (USTA-endorsé) : rotator cuff + scapular + core anti-rotation + force unilatérale + intermittent. [Complete Conditioning for Tennis 2E — Google Books](https://books.google.com/books/about/Complete_Conditioning_for_Tennis_2E.html?id=992MDAAAQBAJ)

### Tennis-elbow prevention exercises consistent

Présents dans CHAQUE semaine W1→W10, avec rampe de progression appropriée :
- W1-W2 : Y-T-W + ER bande (foundation)
- W3-W4 : ajout prone scaption + Pallof
- W6+ : maintien complet
- W10 : taper mais maintenu

L'AAOS Therapeutic Exercise Program for Epicondylitis recommande exactement ce type d'approche (eccentric forearm + scapular + cuff). Le programme cite Tyler Twist et exercices forearm excentriques 1-3 kg dans `safety_notes`. [AAOS Therapeutic Exercise Program for Epicondylitis](https://orthoinfo.aaos.org/globalassets/pdfs/2022-therapeutic-exercise-program-for-epicondylitis.pdf), [PMC — Lateral epicondylitis update aetiology biomechanics treatment](https://pmc.ncbi.nlm.nih.gov/articles/PMC2465303/)

### Cutback toutes 4 sem

`deload_weeks: [5]` sur un plan 10 sem. Une seule cutback à mi-parcours, **conforme** à la règle 3-5 sem (W5 = exactement à mi-parcours). Pas de deuxième cutback avant W10, mais W10 elle-même est tapérisée (J1 court allégé 80 min, S&C activation), et W9 est annoncée "taper léger -15%". C'est défendable pour un plan court de 10 sem où la dernière semaine est la séance phare. **PASS**.

## 2. Metadata hooks (Story 0.5.9 / Schema v2)

### Per-template
- `week_structure` : ✓ (type linear, micro_pattern explicite, recovery_cadence)
- `deload_weeks` : ✓ [5]
- `progression_logic` : ✓ (5 principes sourcés ITF/USTA/Kovacs)

### Per-exercise — audit des 10 semaines

J'ai contrôlé chaque exercice de chaque semaine. Tous les exercices ont les 5 hooks :
- `target_zone` : valeurs cohérentes ("Z2", "Z3", "RPE 5-6", "RPE 6-7", "RPE 7-8", "technique", "cool-down"). Pas de "moderate" générique.
- `required_equipment` : kebab-case respecté (`racket`, `balls`, `tennis-shoes`, `court`, `wall`, `mat`, `resistance-band`, `agility-ladder`, `dumbbells`, `medicine-ball`, `foam-roller`, `partner`)
- `incompatible_constraints` : kebab-case (`shoulder-injury`, `tennis-elbow`, `wrist-pain`, `ankle-injury`, `knee-injury`, `lower-back-pain`, `cardiac-clearance-required`)
- `alternatives` : 2 alternatives par exo, formulations terrain (drill mur / ball-machine / ghost-stroking / dumbbell light)
- `volume_axis` : duration/sets/reps cohérent avec la spec exo

Note mineure W5 day 4 exo "External rotation à la bande" (lignes 693-702) : pas de champ `notes` (absent). Tous les autres exos ont `notes`. Pas bloquant — le schema v2 ne rend pas `notes` obligatoire — mais c'est la seule omission stylistique du template. À combler en regen incrémentale ou sur prochaine itération.

### Cohérence target_zone vs sport-doctrine
- `Z2` (~65-75% FCmax conversationnel) : aligné Hudson/Pfitzinger — équivalent tennis "drill technique conversationnel"
- `Z3` (~75-83% FCmax phrase courte) : aligné FFT zone 3 — équivalent "rallye contrôle moyenne intensité"
- `RPE 5-6` : aligné Borg / Foster session-RPE
- `RPE 7-8` : aligné match-play simulé (Kovacs intermittent)
- `RPE 6-7` S&C : aligné NSCA volume modéré
- Pas de zone Z4/Z5 ni RPE 8-9 — choix doctrinaire défendu : pas de side-to-side panier explosif sur recreational.

## 3. Internal consistency

| Check | Result |
|---|---|
| `duration_weeks == weeks.count` | ✓ 10 == 10 |
| Active sessions/week ≤ `sessions_per_week` (2) | ✓ 2 sessions partout |
| Days unique [1,7] dans chaque semaine | ✓ (W1-W9 jours 1+4 ; W10 jours 1+5 — cohérent annonce "J1 + J4-J5" du `progression_logic`) |
| Volume cible annoncé W10 "30+ échanges" délivré | ✓ checklist autonomie critère 1 |
| Service 50-60% in-play délivré | ✓ checklist autonomie critère 2 |
| `progression_logic` cite réalité plan | ✓ (drills cross W1-W2, RPE 5-6 W3-W4, cutback W5, montée filet W6+ — tout vérifié dans weeks) |
| Equipment ⊆ assumed_profile + alternatives | ✓ (raquette/balles/chaussures/court annoncés ; mat/bande/agility-ladder/dumbbells dans S&C avec alternatives sans-charge ou variantes mur) |
| `safety_notes` rest standards respectés | ✓ (rest 60-75 sec sur services et patterns techniques, 30-60 sec S&C — cohérent recreational) |
| Volume hebdo monotone progressif W1→W4, cutback W5, build W6→W8, taper W9-W10 | ✓ pattern undulating-linear correct |

Spot-check spécifique : W4 volume pic annoncé 170 min court + 35 S&C ; W8 volume pic 175 min + 40 S&C ; W10 court phare 105 min + pré-séance 80 min = 185 min mais activation S&C légère (taper). Pic réel = W8 cohérent.

## 4. Cutback / deload

Plan 10 sem, `deload_weeks: [5]`. **PASS** — règle minimum (≥1 cutback pour plan ≥6 sem) respectée. W5 explicitement -15 à -20% volume hebdo (60+60 = 120 min court vs 170 min W4 = -29% ; côté conservateur). Maintien fréquence (2 sessions), réduction volume + intensité (pas de RPE 7-8 W5), pas de nouveauté technique. C'est un cutback **textbook**.

W9 "taper léger -15%" annoncé mais c'est pre-validation, pas un deload formel. Acceptable pour plan court 10 sem.

## 5. Safety

`safety_notes` couvre **6 sections** (au-dessus de la cible 5) :
1. **DRAPEAUX ROUGES** : épicondylite latérale + médiale, douleur épaule (coiffe/conflit/SLAP), poignet (TFCC/ECU/De Quervain), entorse cheville, douleur articulaire genou, antécédents cardiaques/grossesse → consultation
2. **PRÉVENTION TENNIS ELBOW** : rotator cuff + grip size + cordage + pression grip + sweet spot + Tyler Twist
3. **PRÉVENTION ÉPAULE** : 3 piliers (mobilité capsule postérieure, force coiffe, force scapulaire) + cap volume service 30-40/séance
4. **MATÉRIEL OBLIGATOIRE** : chaussures tennis dédiées (red flag absolu pour entorse), raquette < 300 g, cordage souple
5. **INTENSITÉ** : table RPE/Z/FCmax avec 5 paliers
6. **NUTRITION-HYDRATATION** : 500 ml/h tempéré, 1 L/h chaleur, sodium 300-700 mg/L, collation glucides 30-60 g/h
7. **SIGNES DE SURCHARGE** : 5 signes + protocole (3+ → semaine allégée)
8. **SI SÉANCE MANQUÉE** : protocole < 1 sem / 1-2 sem / > 2 sem + substitution court → S&C off-court

Sport+level specific risks :
- Tennis recreational n°1 = épicondylite latérale (tennis elbow) → **traitée explicitement** avec biomécanique (frappe en avant du corps, sweet spot, grip relâché 5-7/10), équipement (poids raquette, cordage souple) et exercices préventifs (Tyler Twist eccentric).
- Risque épaule (overhead service) → cap 30-40 services/séance + Y-T-W + ER + sleeper stretch dans CHAQUE séance.
- Risque cheville (déplacements latéraux drills + agility) → chaussures dédiées rappelées comme matériel **obligatoire**.

Les seuils chiffrés (durée 5-7 jours pour consultation, 30-40 services/séance, 10-15 smashs/séance) sont **alignés sur AAOS / Cleveland Clinic / OrthoInfo**. [AAOS Tennis Elbow / Lateral Epicondylitis](https://orthoinfo.aaos.org/en/diseases--conditions/tennis-elbow-lateral-epicondylitis/), [PMC — Lateral epicondylitis](https://pmc.ncbi.nlm.nih.gov/articles/PMC2465303/)

Aucun copy-paste générique d'autre sport. **PASS catégorique**.

## 6. EU MDR

### Banned words scan

Recherche FR : "guérir", "soigner", "traiter une pathologie", "diagnostic", "médical", "thérapeutique", "rééducation post-opératoire", "cure".

Trouvé :
- "consulte un médecin avant de commencer ce programme" : usage légitime de **redirection médicale**, pas une claim. ✓ Conforme EU MDR.
- "consulter un professionnel de santé" : redirection. ✓
- "consulte un kiné" : redirection. ✓
- "diagnostiquée" (dans "tendinite coiffe diagnostiquée") : usage descriptif d'antécédent, pas une claim que le programme diagnostique. ✓
- "préventif" : usage acceptable pour des exercices de renforcement (≠ "curatif" / "thérapeutique"). ✓
- "Pathologie épaule connue" : descriptif d'antécédent utilisateur, pas une claim du programme. ✓

Recherche EN : "treat", "diagnose", "therapeutic", "cure" → aucune occurrence en EN dans le template.

Aucun mot banni utilisé comme **claim**. Pas de framing "le programme soigne X" ou "traite Y".

### Medical clearance triggers

Le programme cible des **adultes en bonne santé** (NTRP 2.0-2.5 in, NTRP 2.5-3.0 out, profil "pratiquant tennis ayant suivi 8-12 sem d'initiation"). C'est une population générale fitness, pas une population cardiaque/MSK/métabolique spécifique.

Cependant, `safety_notes` inclut explicitement les triggers de clearance médicale pour les sous-populations à risque :
- Antécédents cardiaques connus → consulte un médecin
- Grossesse / postpartum < 6 mois → consulte un médecin
- Pathologie épaule connue (tendinite coiffe diagnostiquée, SLAP, conflit sous-acromial) → consulte un médecin
- Reprise post-entorse récente < 3 mois → consulte un médecin

Le constraint `cardiac-clearance-required` est aussi câblé sur les exercices cardio intermittent (sprints) en `incompatible_constraints` — bonne hygiène de constraint engine.

**PASS**. Conformité EU MDR catégorique.

## 7. Final autonomy checklist

W10 day 5 (Séance phare) — exercice "Set partiel 4 jeux — match-simulation finale" notes lignes 1359 :

5 critères mesurables/observables :
1. **Drill cross 30+ frappes** consécutives forehand RPE 5-6 / Z3 80-85% FCmax (mesurable, compteur)
2. **Premier service 50-60% en jeu** sur 20 services en match-simu (mesurable, ratio)
3. **Set partiel 4 jeux complet sans baisse régularité** (différence qualité 1er-4e jeu < 20%, sensation subjective + observation)
4. **S&C off-court hebdo tenu sans inconfort articulaire** coude/épaule/genou/cheville (observable, monitoring corporel)
5. **Distinguer douleur articulaire vs fatigue musculaire normale** + interpréter signes surcharge (FC repos, sommeil, motivation) (compétence d'autoévaluation)

Branchement décisionnel explicite : 4+ critères → enchaîner programme tennis regular 12-14 sem ; 3 ou moins → refaire W7-W8 (cycle 2 sem) avant progression. Mention "match amical de tournoi club avec confiance, sans pression de résultat" = excellente fenêtre d'autonomie réaliste recreational.

**PASS** — 5 critères, mesurables, observables, avec branchement décisionnel.

## 8. Style

- Français, tutoiement maintenu partout ✓
- Aucun emoji ✓
- Noms d'exercices clairs et terrain-oriented ("Drill cross forehand — rallye contrôle", "Y-T-W + external rotation + Pallof anti-rotation", "Set partiel 4 jeux — montée filet libre")
- `notes` pédagogiques concises, citent biomécanique (relâcher grip 5-7/10, frapper en avant du corps, contact volée devant le corps grip continental) ✓
- Vocabulaire FFT/USTA correct (cross, long de ligne, mi-court, fond de court, panier, ghost-stroking, set partiel, tie-break)

## Issues summary

### Critical (block merge)
Aucune.

### Important (fix recommended)
Aucune.

### Minor (nice-to-have)
- W5 day 4 exo "External rotation à la bande" (lignes 693-702) : pas de champ `notes`. Tous les autres exos ont `notes`. À combler en regen incrémentale (1 ligne).
- `assumed_profile` mentionne "accès court 2-3×/sem" alors que le plan utilise 2×/sem strictement. Cohérent (2-3 = 2 minimum, marge utilisateur), mais pourrait être précisé "2× minimum / 3× possible si récup OK".

## Sources

- [USTA NTRP Ratings FAQs](https://www.usta.com/en/home/play/adult-tennis/programs/national/usta-ntrp-ratings-faqs.html)
- [USTA Understanding NTRP Ratings](https://www.usta.com/en/home/coach-organize/tennis-tool-center/run-usta-programs/national/understanding-ntrp-ratings.html)
- [ITF Coaching Beginner & Intermediate Players Course (Level 1)](https://en.coaching.itftennis.com/courses/beginnerintermediate/overview.aspx)
- [ITF Coach Education Programme](https://www.itftennis.com/en/news-and-media/articles/itf-coach-education-programme-educating-and-certifying-coaches/)
- [Complete Conditioning for Tennis 2E — Kovacs, Roetert, Ellenbecker, USTA](https://books.google.com/books/about/Complete_Conditioning_for_Tennis_2E.html?id=992MDAAAQBAJ)
- [AAOS Therapeutic Exercise Program for Epicondylitis (Tennis Elbow)](https://orthoinfo.aaos.org/globalassets/pdfs/2022-therapeutic-exercise-program-for-epicondylitis.pdf)
- [PMC — Lateral Epicondylitis in Tennis: aetiology, biomechanics, treatment](https://pmc.ncbi.nlm.nih.gov/articles/PMC2465303/)
- [AAOS OrthoInfo — Tennis Elbow / Lateral Epicondylitis](https://orthoinfo.aaos.org/en/diseases--conditions/tennis-elbow-lateral-epicondylitis/)
- [Tennis Fitness — Tennis Training Volume](https://www.tennisfitness.com/blog/tennis-training-volume-what-is-the-right-amount)
- [Voyager Tennis — Choose Right Training Volume](https://www.voyagertennis.com/featured/how-to-choose-the-right-training-volume-based-on-your-tennis-goals/)

## Recommendation

**APPROVED** — bundle as-is.

Le template est exemplairement sourcé (5 piliers progression cite ITF + USTA NTRP + FFT + Kovacs/Roetert/Ellenbecker explicitement), structurellement cohérent (10/10 weeks, 2 sessions strictes, hooks v2 complets sauf 1 `notes` mineur), et **catégoriquement conforme EU MDR**. La doctrine tennis recreational est respectée à la lettre (régularité fond de court > puissance, pas de RPE 8-9, prévention tennis elbow piliers maintenus W1→W10, cap volume service 30-40/séance, cutback W5 mi-parcours, checklist autonomie 5 critères avec branchement décisionnel). Le choix de 2 sessions/sem au lieu de 3-4 est défendu doctrinalement et adapté au target adulte recreational solo. Aucune issue critique ou importante. Une seule omission `notes` mineure (W5/D4/ER) pouvant être corrigée en regen incrémentale ou laissée telle quelle pour bundle prod.

## Patches applied (2026-05-01)

2 minor patches appliqués en édition ciblée :
1. **W5/D4 External rotation à la bande — `notes` ajouté** : "Coude à 90° collé au flanc, rotation externe lente sur 3 sec, retour 2 sec. Maintien coiffe rotateurs en activation préventive. Volume taper cutback — pas de surcharge. RPE 6-7." Comble la seule omission stylistique identifiée.
2. **assumed_profile précisé** : "accès court 2-3×/sem" → "accès court 2× minimum / 3× possible si récup OK" — clarifie l'écart avec le plan strict 2×/sem.

JSON validé (parse OK, hooks v2 symétrie 91×5, 0 banned word EU MDR). **Verdict final : APPROVED.**
