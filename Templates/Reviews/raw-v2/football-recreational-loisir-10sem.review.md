# Quality Review — football-recreational-loisir-10sem

**Verdict** : APPROVED
**Sport** : football  **Level** : recreational  **Schema version** : 2

## 1. Doctrine alignment

### Niveau ciblé FFF Loisir / FA Recreational Adult / UEFA Grassroots

Le template positionne `assumed_profile` (l. 10) explicitement sur "FFF Loisir / FA Recreational Adult / UEFA Grassroots, capable de tenir un match 2 × 30 min sans bagage de débutant, base de contrôle de balle / passe / conduite acquise. 1-2 séances / sem en équipe amicale ou entre amis, foot à 7-11 sans enjoi compétitif". C'est exactement le descripteur doctrine football fragment ligne 11 : "pratique 1-2 × / sem en équipe amicale ou foot à 7-11 loisir, vise condition physique générale et plaisir de jeu. Capable de tenir un match 2 × 30 min". Calibration nominale recreational. [FFF DTN — Parcours de Formation Educateurs](https://www.fff.fr/fff/formations/educateurs-entraineurs), [UEFA Coaching Licences](https://www.uefa.com/development/coaches/uefa-coaching-licences/)

### FIFA 11+ raccourci dès W2

Doctrine demande l'introduction FIFA 11+ raccourci dès W2. Verifié l. 233-236 (W2 J1 warmup) : "10 min FIFA 11+ raccourci : 4 min running progressif (course en ligne droite + ouvertures hanches + zigzag léger + course rapide-retour reculons, 30 sec chaque) + 4 min force au sol (bench 20 sec × 2, side bench 20 sec / côté × 2, single leg stance 30 sec / jambe × 2, squats 10 reps × 2)". W1 ne contient pas FIFA 11+ (l. 31 warmup générique 8 min) — choix volontaire d'une W1 reprise pure technique avant introduction protocole W2, parfaitement aligné doctrine. Maintenu W2 → W10 (vérifié l. 294, 441, 499, 646, 704, 839, 1044, 1101, 1237, 1295, 1430, 1488, 1623, 1681, 1816, 1874). [FIFA — Injury prevention (FIFA 11+)](https://inside.fifa.com/health-and-medical/injury-prevention)

### Volume hebdo 3-4.5 h terrain + 0.5-1 h S&C

Doctrine cible 3-5 h terrain + 0.5-1 h S&C / sem (l. 102 fragment). Le programme annonce dans `summary` (l. 11) "Volume pic ~3-4.5 h terrain + 0.5-1 h S&C par semaine". Vérification chiffrée semaine pic (W7) : 80 min technique + 95 min jeu = 175 min terrain (~2h55) + 65 min S&C (~1h05). C'est dans la fenêtre basse-moyenne doctrine recreational (3-5 h terrain). Cohérent et conservateur — adapté au pratiquant solo qui doit compenser l'absence de 3e séance terrain par S&C dédié. PASS.

### Foot à 7 W5+, foot à 9 W9, intermittents 30/30 W6+

Trois jalons doctrine spécifiques :
- **Foot à 7 W5** : vérifié l. 894 ("Terrain match amical foot à 7 — premier match du plan") — 7v7 sur demi-terrain 50×35 m, 2 × 25 min mi-temps (l. 913-947). PASS.
- **Foot à 9 W9** : vérifié l. 1678 ("Terrain match amical foot à 9 — mi-temps 30 min × 2") — 9v9 sur 70×50 m, 2 × 30 min (l. 1697-1731). PASS.
- **Intermittents 30s/30s W6** : vérifié l. 1212-1222 (W6 J5 "Intermittents 30s/30s — cardio intermittent football", 10 cycles, "Premier vrai bloc intermittent du plan"). Progression W7 → 2 × 8 cycles (l. 1405-1414), W9 → 8 cycles taper (l. 1791). PASS.

### Distribution 4 piliers recreational

Doctrine `progression_logic` annonce "Technique 40-50% / Tactique 10-20% / Physique 20-25% / Mental 5-10%" (l. 18). Estimation par exercices (audit weeks) :
- W1-W2 : ~70% technique pure + 0-10% tactique + 20% physique S&C + jeu réduit calme — phase foundation, technique dominante.
- W3-W6 : ~45% technique (drills passes-conduite-frappe) + 15% tactique (patterns 1-2, sortie de balle simple) + 25% physique (S&C + intermittents intro) + jeu réduit progressif.
- W7-W9 : ~40% technique + 20% tactique (sortie de balle 4 joueurs, coups de pied arrêtés) + 30% physique (intermittents pic + match) + jeu collectif RPE 7-8.
- W10 : taper avec validation match phare.

Distribution conforme cible recreational. PASS.

## 2. Metadata hooks (Schema v2)

### Per-template (l. 12-19)
- `week_structure.type` : ✓ "linear"
- `week_structure.micro_pattern` : ✓ "terrain technique + terrain jeu réduit ou match amical + S&C off-pitch ou conditioning terrain"
- `week_structure.recovery_cadence` : ✓ "1 cutback W4 et W8 sur plan 10 sem (-15 à -20% volume hebdo)"
- `deload_weeks` : ✓ [4, 8]
- `progression_logic` : ✓ 5 principes sourcés FFF Loisir / FA Recreational / UEFA Grassroots / FIFA 11+ F-MARC / Verheijen amateur (l. 18)

### Per-exercise — audit hooks v2

Spot-check W1 (l. 33-220), W5 match (l. 911-947), W7 jeu réduit pic (l. 1322-1332), W10 séance phare (l. 1889-1924). Tous les exercices (~135 au total) ont les 5 hooks :
- `target_zone` : valeurs cohérentes (`Z1`, `Z2`, `Z3`, `RPE 5-6`, `RPE 6-7`, `RPE 7-8 intermittent`, `technique`, `cool-down`). Aucune occurrence de `RPE 8-9 sprint` (cohérent doctrine recreational).
- `required_equipment` : kebab-case respecté (`cleats`, `ball`, `field`, `cones`, `mini-goals`, `training-bibs`, `mannequins`, `agility-ladder`, `mat`, `dumbbells`, `foam-roller`). Vocabulaire conforme doctrine l. 318-330.
- `incompatible_constraints` : kebab-case (`ankle-injury`, `knee-injury`, `hamstring-injury`, `groin-injury`, `concussion-history`, `lower-back-pain`, `cardiac-clearance-required`, `shoulder-injury`). Vocabulaire conforme l. 335-348.
- `alternatives` : 2 alternatives par exercice, formulations terrain (drill mur / passes binôme / vélo / corde à sauter). Aucun `alternatives: []` vide détecté. Conforme règle doctrine l. 388.
- `volume_axis` : `duration` (drills minutés, jeux réduits, matchs), `sets` (séries d'intermittents, drills répétés), `reps` (frappes chiffrées, passes par pied) — distribution cohérente avec spec exo.

### Cohérence target_zone vs sport-doctrine

- `Z1` (récup) cool-down : aligné l. 71 doctrine
- `Z2` (~65-75% FCmax conversationnel) footing + jeu de conservation : aligné l. 72
- `Z3` (~75-85% FCmax tempo) jeu réduit calme : aligné l. 73
- `RPE 5-6` jeu réduit modéré : aligné l. 89 doctrine
- `RPE 6-7` S&C off-pitch : aligné l. 80 doctrine
- `RPE 7-8 intermittent` intermittents 30s/30s + jeu réduit espace réduit + matchs amicaux : aligné l. 75
- `cool-down` : conforme

Pas de `RPE 8-9 sprint` (RSA), conforme doctrine recreational l. 89.

## 3. Internal consistency

| Check | Result |
|---|---|
| `duration_weeks == weeks.count` | ✓ 10 == 10 (l. 7, 22-1986) |
| `sessions_per_week == 3` (l. 8) | ✓ 3 sessions actives J1+J3+J5 partout (l. 27/85/143, 232/290/348, etc.) |
| Days unique [1,7] dans chaque semaine | ✓ J1 + J3 + J5 cohérent |
| Pattern J1 technique / J3 jeu réduit ou match / J5 S&C off-pitch | ✓ vérifié W1-W10 (l. 28, 86, 144 ; 233, 291, 349 ; etc.) |
| Volume curve progressive W1→W3, cutback W4, build W5→W7, cutback W8, build W9, taper W10 | ✓ undulating-linear correct |
| Pic W7 (175 min terrain + 65 S&C) | ✓ confirmé l. 1230 |
| Cutback W4 [-15 à -20%] vs W3 | ✓ W3 ~215 min total, W4 ~170 min total = -21% (l. 639) |
| Cutback W8 [-15 à -20%] vs W7 | ✓ W7 ~240 min total, W8 ~185 min total = -23% (l. 1423) |
| Volume autonomy match phare W10 | ✓ 90 min match foot à 7/9 (l. 1873) |
| FIFA 11+ tenu W2-W10 sans interruption | ✓ vérifié dans warmup chaque séance terrain |
| Equipment ⊆ assumed_profile + alternatives | ✓ (cleats, ball, field, cones, mini-goals, training-bibs annoncés ; mat/dumbbells/foam-roller dans S&C avec alternatives bodyweight) |

Spot-check `progression_logic` (l. 18) ↔ `weeks` : "(3) FIFA 11+ INTRODUIT W2" → vérifié W2 l. 236. "(5) JEU RÉDUIT ET MATCH AMICAL PROGRESSIFS W5 → W10 : foot à 7 amical en W5" → vérifié l. 894. "intermittents 30s/30s W6+" → vérifié l. 1212. Tous les claims du `progression_logic` sont délivrés dans les semaines.

## 4. Cutback / deload

Plan 10 sem, `deload_weeks: [4, 8]`. Conforme règle doctrine l. 376 ("Plan 10 sem `recreational` : `[4, 8]`"). Magnitudes vérifiées :
- W4 cutback (l. 639) : volume terrain 130 min + S&C 40 min = 170 min total (vs W3 ~215 min) = **-21%** — légèrement plus marqué que la fenêtre -15 à -20% standard, mais reste dans la zone cutback acceptable doctrine recreational. Maintien fréquence 3 sessions, intensité réduite (Z2-Z3 calme), pas de nouveauté technique.
- W8 cutback (l. 1423) : volume terrain 140 min + S&C 45 min = 185 min total (vs W7 ~240 min) = **-23%** — même remarque, légèrement au-dessus de la cible -20% mais cohérent comme cutback post-pic intensif. Acceptable.

Mention "économie hanche / adducteurs" en frappe placée W4 (l. 690) et W8 (l. 1474) — pédagogie cutback bien expliquée. PASS.

## 5. Safety

`safety_notes` (l. 19) couvre **9 sections** au-dessus de la cible doctrine 5+ :
1. **DRAPEAUX ROUGES** : 6 drapeaux (entorse cheville, HSI ischio, pubalgie / adducteurs, genou LCA / tendinite rotulienne, commotion cérébrale, antécédents cardiaques / > 35 ans / grossesse).
2. **PRÉVENTION ACL** : protocole FIFA 11+ + neuromusculaire (FIFA 11+ 2× / sem dès W2, single leg stance, force unilatérale dès W3, éducation cutting genou dans l'axe, vertical jumps + lateral bound progressifs, citation -50% LCA femmes méta-analyse FIFA 11+ 2014-2017).
3. **PRÉVENTION ISCHIO-JAMBIERS (HSI)** : échauffement complet, glute bridge dès W1, RDL unilatéral dès W3 (substitut accessible NHE), hydratation 500-750 ml/h, pas de sprint max, gestion symptômes.
4. **PRÉVENTION ADDUCTEURS / PUBALGIE** : étirements adducteurs cool-down, side plank dès W1, frappe alternée pied droit / gauche (≥30% non-dominant), single-leg / split squat dès W3, escalade vers consultation kiné si > 2 sem.
5. **PRÉVENTION ENTORSE CHEVILLE** : crampons FG / SG / TF / IC adaptés, single leg stance dès W1, calf raises bipodal puis unilatéral, agility ladder progressive, gestion reprise post-entorse < 3 mois.
6. **PRÉVENTION COMMOTION CÉRÉBRALE** : jeu de tête introduit W4+ progressif, technique frontal os, ballon léger, max 5-10 têtes / séance, sortie immédiate au moindre signe, protocole HIA, retour graduel 5-7 jours, antécédent commotion < 6 mois → pas de jeu de tête (alternative volée pied).
7. **MATÉRIEL OBLIGATOIRE** : crampons adaptés (jamais running shoe sur gazon), ballon T5, protège-tibias en match W5+, mat / bande / agility / mini-buts / chasubles / cônes 8-12.
8. **INTENSITÉ** : table cohérente Z2 / Z3 / RPE 5-6 / RPE 7-8 intermittent / S&C RPE 6-7. Affirme explicitement "Aucun RPE 8-9 sprint sur ce plan".
9. **NUTRITION-HYDRATATION** : 500 ml pré-séance, 500-750 ml/h tempéré, 1 L/h chaleur > 25°C, sodium 300-700 mg/L, collation glucidique avant matchs, récup post-effort. Mention coup de chaleur match été.
10. **SIGNES DE SURCHARGE** : 5 signes (FC repos +10 bpm, sommeil dégradé, douleur cheville / ischio / adducteurs, motivation, perf en baisse) + protocole 3+ → cutback.
11. **SI SÉANCE MANQUÉE** : protocole < 1 sem / 1-2 sem / > 2 sem + substitution terrain → S&C off-pitch.

Sport-specific risks football traités : ACL ✓, hamstring ✓, groin/pubalgie ✓, ankle ✓, commotion ✓ — c'est le full set FIFA 11+ + UEFA injury surveillance + ACL Prevention reviews. La doctrine demandait 5 sections prévention claimed + drapeaux + matériel + intensité + nutrition + surcharge + missed session : **toutes présentes, 11 au total. DEPASSE la cible. PASS catégorique.**

## 6. EU MDR

### Banned words scan

Recherche FR de mots bannis doctrine l. 285-291 : "soigner", "guérir", "cure", "traitement", "rééducation", "thérapie", "diagnostic", "prescription", "ordonnance", "réparer le ligament", "soulager [douleur]". **Aucune occurrence** détectée dans le template (grep clean ligne par ligne, voir verification commande).

Recherche `EN` "treat", "therapy", "cure", "diagnose" : **aucune occurrence en EN** dans le template (texte 100% FR).

Le template utilise correctement :
- "consulte un médecin avant de commencer ce programme" (redirection médicale) ✓
- "consulter un professionnel de santé" (redirection) ✓
- "consulte un kiné" (redirection) ✓
- "consultation kiné" (escalade) ✓
- "préventif" / "prévention" pour les exercices (acceptable, ≠ "curatif") ✓
- "préparer l'ischio à l'effort" / "renforcer la cheville" (formulations doctrine-conformes) ✓
- "post-LCA / post-op" : usage descriptif d'antécédent utilisateur, pas une claim ✓

### Medical clearance triggers

Triggers explicites bien câblés `safety_notes` :
- Antécédents cardiaques connus / > 35 ans débutant / grossesse / postpartum < 6 mois → consulte un médecin
- Reprise post-LCA < 12 mois post-op → consulte un médecin + protocole spécifique
- Reprise post-entorse cheville < 3 mois → consulte un médecin
- HSI passé < 8 sem → consulte un médecin
- Antécédent commotion < 6 mois → consulte un médecin

`cardiac-clearance-required` câblé sur exercices cardio intermittent (footing Z2, intermittents 30s/30s, matchs amicaux W5+ / W9 / W10), conforme à `incompatible_constraints` doctrine l. 343. PASS.

## 7. Final autonomy checklist

W10 J3 séance phare — exercice "Match amical foot à 7 ou 9 — mi-temps 2 (30 min)" notes (l. 1918) :

5 critères mesurables / observables :
1. **Tenir match amical foot à 7 ou 9 sur 2 × 30 min** sans baisse marquée d'engagement (différence qualité 1ère / dernière minute < 25%). Mesurable / sensation subjective. Conforme doctrine "foot à 9 60min" (l. 11 user spec).
2. **6/10 passes courtes propres en jeu collectif** intérieur du pied alternées droit / gauche, même sous pression défensive modérée. Mesurable, ratio.
3. **Conduire ballon en slalom 6 cônes (12 m) en moins de 12 sec** sans perdre contrôle, alternant pied dominant / non-dominant. Chronométré, mesurable.
4. **FIFA 11+ hebdo (10 min échauffement) tenu 2-3× / sem sans inconfort articulaire** cheville / genou / ischio / adducteurs. Observable, monitoring corporel. Conforme cible doctrine "FIFA 11+ autonome" (l. 11 user spec).
5. **S&C off-pitch hebdo** (single leg stance + glute bridge + plank + RDL unilatéral + cardio 30s/30s) tenu 1× / sem sans inconfort. Observable.

Branchement décisionnel explicite : 4+ critères → enchaîner programme football regular 10-12 sem (préparation championnat district D1-D2 + FIFA 11+ complet + intro NHE / CAE) ; 3 ou moins → refaire W6 et W7 (cycle 2 sem) avant progression. Mention "tournoi loisir club avec confiance, sans pression de résultat" = excellente fenêtre autonomie réaliste recreational.

Doctrine demandait "≥3-5 critères mesurables (foot à 9 60min, intermittents, FIFA 11+ autonome, passes courtes/longues)" : 5 critères, tous présents (foot à 7-9 60 min ✓, FIFA 11+ ✓, passes courtes ✓, conduite + dribble ✓ ; intermittents implicite via S&C critère 5). Note : la cible "passes courtes/longues" n'est testée qu'en passes courtes (critère 2) — passes longues vues en W2 l. 252-262, W7 l. 1241, mais pas testées en checklist W10. **Mineure** acceptable car le profil recreational vise d'abord régularité passes courtes (jeu collectif). PASS.

## 8. Style

- Français, tutoiement maintenu partout ✓ ("tu coches", "tu peux", "tu enchaînes")
- Aucun emoji ✓
- Noms d'exercices clairs et terrain-oriented ("Passes courtes en binôme — intérieur du pied", "Conduite slalom 5 cônes", "Foot à 7 amical — match loisir mi-temps 1", "Romanian deadlift unilatéral léger — intro")
- `notes` pédagogiques concises, citent biomécanique et critères qualité (genou dans l'axe pied, dos plat RDL, frappe pied alterné, cible chiffrée 4/6 ou 6/8 dans la cible)
- Vocabulaire FFF / UEFA / FIFA 11+ correct (foot à 7, foot à 9, FG / SG / TF / IC crampons, FIFA 11+ partie 1+2+3, single leg stance, sortie de balle, jeu de conservation, drill panier, mini-but, mannequin, training-bibs, ickey shuffle)

## Issues summary

### Critical (block merge)
Aucune.

### Important (fix recommended)
Aucune.

### Minor (nice-to-have)
- Faute de frappe `assumed_profile` (l. 10) : "sans bagage de débutant" — interprétation ambiguë, suggérer "sans bagage de blessures de débutant" ou "sans appréhension de débutant". Pas bloquant — le sens reste compréhensible.
- Cutbacks W4 (-21%) et W8 (-23%) légèrement au-dessus de la fenêtre doctrine -15 à -20%. Reste dans la zone acceptable (la doctrine football l. 387 autorise -25 à -30% pour beginner low-volume seulement, donc -23% pour recreational est limite haute mais pas hors-doctrine). Pourrait être réduit à -18% en remontant W4 à 175 min total et W8 à 195 min total dans une regen incrémentale.
- Critère autonomie W10 ne teste pas explicitement les passes longues (passe verticale 20-25 m vue en W2 et W7 mais pas testée en checklist). À combler en regen optionnelle si jugé nécessaire — la cible recreational privilégie les passes courtes en jeu collectif, donc défendable tel quel.

## Sources

- [FIFA — Injury prevention and health promotion (FIFA 11+)](https://inside.fifa.com/health-and-medical/injury-prevention)
- [FIFA 11+: an effective programme to prevent football injuries — narrative review (PMC)](https://pmc.ncbi.nlm.nih.gov/articles/PMC4413741/)
- [The FIFA 11+ injury prevention program for soccer players: systematic review (BMC)](https://link.springer.com/article/10.1186/s13102-017-0083-z)
- [The FIFA 11+ Soccer Injury Prevention Program — booklet PDF](https://jacobstirtonmd.com/wp-content/uploads/2019/07/The-FIFA-11-Soccer-Injury-Prevention-Program.pdf)
- [Impact of FIFA 11+ on Injury Prevention — systematic review (PMC)](https://pmc.ncbi.nlm.nih.gov/articles/PMC4245655/)
- [The FIFA 11+ — Physiopedia](https://www.physio-pedia.com/The_F%C3%A9d%C3%A9ration_Internationale_de_Football_Association_FIFA_11+)
- [UEFA Coaching Licences — UEFA.com](https://www.uefa.com/development/coaches/uefa-coaching-licences/)
- [FFF DTN — Parcours de Formation Educateurs / Entraîneurs](https://www.fff.fr/fff/formations/educateurs-entraineurs)
- [Verheijen — Original Guide to Football Periodisation Part 1](https://www.amazon.com/Original-Guide-Football-Periodisation-Part/dp/949174500X)
- [ACL Injuries in Soccer Players: Prevention and Return to Play (PMC)](https://pmc.ncbi.nlm.nih.gov/articles/PMC10743334/)
- [Effect of NHE Programs on Hamstring Injury Rates in Soccer — meta-analysis (PubMed)](https://pubmed.ncbi.nlm.nih.gov/27752982/)
- [Training Zones for Football Fitness (Professional Soccer Coaching)](https://www.professionalsoccercoaching.com/aerobic-fitness-science/training-zones-for-football-fitness)

## Recommendation

**APPROVED** — bundle as-is.

Le template est exemplairement sourcé (5 piliers progression cite FFF Loisir + FA Recreational + UEFA Grassroots + FIFA 11+ F-MARC + Verheijen amateur explicitement), structurellement cohérent (10/10 weeks, 3 sessions strictes J1+J3+J5, hooks v2 complets sur ~135 exercices), et **catégoriquement conforme EU MDR** (zéro mot banni, redirection médicale propre sur 5 triggers de clearance). La doctrine football recreational est respectée précisément : FIFA 11+ raccourci dès W2 maintenu jusqu'à W10, foot à 7 W5, foot à 9 W9, intermittents 30s/30s W6 → 2 séries W7 → taper W9, prévention ACL / HSI / pubalgie / cheville / commotion exhaustive dès W1, cutbacks W4 et W8 (légèrement marqués à -21/-23% mais acceptables), checklist autonomie 5 critères mesurables avec branchement décisionnel. La séance phare W10 valide la cible "tenir foot à 7 ou 9 sur 2 × 30 min" doctrine-aligned. Aucune issue critique ou importante. 3 issues minor cosmétiques (typo "bagage", cutbacks légèrement plus marqués que cible, critère autonomie passes longues implicite) pouvant être corrigées en regen incrémentale ou laissées telles quelles pour bundle prod.

## Patches applied (2026-05-01)

- **assumed_profile typo** : "sans bagage de debutant" -> "sans apprehension de debutant" (formulation claire, sens preserve).
- **Cutback W4** : magnitude reduite de -21% a -19% en augmentant la session J5 S&C de 40 -> 45 min (+ warmup/cooldown legerement allonges). Goal W4 reformule "Cutback hebdo (-19% volume vs W3)" + volumes cibles mis a jour (175 min total vs 215 min W3).
- **Cutback W8** : magnitude reduite de -23% a -19% en augmentant la session J3 jeu allege 75 -> 80 min et J5 S&C 45 -> 50 min. Goal W8 reformule "Cutback hebdo (-19% volume vs W7)" + volumes cibles mis a jour (195 min total vs 240 min W7).
- **Critere autonomie W10** : critere 2 enrichi pour tester aussi les passes longues : "Je place 6/10 passes courtes propres en jeu collectif... ET 4/6 passes longues 20-25 m sur cible large (couloir 5 m) sans rupture du jeu". Couvre la spec doctrine "passes courtes/longues".

**Validation post-patch** : JSON parse OK, weeks.count=10=duration_weeks, hooks v2 100% couverts, EU MDR banned words = 0.

**Verdict final : APPROVED — bundle.**
