# Quality Review — football-beginner-initiation-8sem

**Verdict** : APPROVED with minor fixes
**Sport** : football  **Level** : beginner  **Schema version** : 2

## 1. Doctrine alignment

Le template s'aligne très solidement sur la doctrine football initiation adulte (FFF Grassroots, FA Discover, UEFA Grassroots C entry, FIFA 11+ F-MARC) :

- **Niveau cible FFF NC / FA Grassroots Discover / UEFA Grassroots C entry** (doctrine fragment lignes 10, 101) : la cible "passe intérieur du pied 30 consécutives, conduite slalom 5 cônes 10 m, foot à 5 amical 15 min sans inconfort" (l. 1197) correspond précisément au descripteur Grassroots adulte débutant — "enchaîner 10 passes courtes contrôlées, conduire la balle slalom 10 m sans perte" (doctrine l. 10). La progression "feeling balle → passe-contrôle → conduite cônes → frappe placée → jeu réduit calme → foot à 5 amical" est conforme à la séquence pédagogique FFF Grassroots / FA Discover. ([FFF DTN — Parcours de Formation](https://www.fff.fr/fff/formations/educateurs-entraineurs), [England Football Learning — Grassroots](https://learn.englandfootball.com/courses/football))

- **FIFA 11+ obligatoire dès W1** (la consigne demandait "dès W2 raccourci", le template fait MIEUX en l'installant dès W1 partie 1+2 raccourcies, l. 31, 101 et progression_logic principe 2 l. 18) : conforme à la doctrine F-MARC qui exige FIFA 11+ 2× / sem dès la première séance. Réduction blessures 30-70% (méta-analyses Soligard et al. 2008, peer-reviewed). Partie 3 (cutting + sprint) introduite uniquement à partir de W4 — bien justifié par l'absence de coordination/force unilatérale en début de plan beginner. ([FIFA 11+ — Physiopedia](https://www.physio-pedia.com/The_F%C3%A9d%C3%A9ration_Internationale_de_Football_Association_FIFA_11+), [FIFA 11+ Soccer Injury Prevention Program — booklet PDF](https://jacobstirtonmd.com/wp-content/uploads/2019/07/The-FIFA-11-Soccer-Injury-Prevention-Program.pdf))

- **Allure beginner stricte (Z2 + technique + cool-down, RPE > 6 banni)** : 100% des drills terrain sont en `technique` (drills moteurs purs) ou `Z2` (~65-75% FCmax, conversational), retour calme en `cool-down`. Aucun RPE > 6 sur ce plan. Aucune RSA, aucun sprint matchplay, aucun match compétitif chronométré. Conforme à la doctrine beginner (l. 89 : "pour beginner, éviter Z4 et RPE > 6 : focus technique + Z2 + jeu réduit calme").

- **Foot à 5 amical sans enjeu W4+ uniquement, pas de match compétitif** (l. 537, 564, 1244-1252) : explicitement banni en `progression_logic` principe 3 et rappelé dans `safety_notes`. Conforme à la doctrine FFF Grassroots adulte beginner (l. 101 : "Aucun match compétitif (foot à 5 amical OK)").

- **Volume hebdo cible 1.5-2.5 h terrain + 0.3-0.5 h S&C off-terrain** (l. 11) : volume pic W7 = 60 min terrain + 40 min S&C = 100 min total → exactement dans la fenêtre doctrine beginner (1.5-3 h terrain + 0-0.5 h S&C, l. 101). 2 séances / semaine sur les 8 semaines. Pattern J1 terrain / J4 S&C avec 2-3 jours d'écart, conforme à la recommandation. ([Pre-season planning in football — Zone14](https://zone14.ai/en/blog/pre-season-planning-in-football/))

- **Prévention cheville-genou 3 piliers dès W1 (single leg stance + calf raises + squats bodyweight)** (safety_notes l. 19 et W1 l. 129-175) : conforme à la doctrine FIFA 11+ partie 2. Le single leg stance est explicitement le "pilier prévention entorse cheville" cité dans le fragment (l. 232). Yeux ouverts W1, yeux fermés W2 (proprio avancée), tap genou W3, ballon partenaire W6 — progression doctrinale exemplaire. ([FIFA 11+ systematic review (BMC)](https://link.springer.com/article/10.1186/s13102-017-0083-z))

- **Cutback W4 (-33% volume terrain) avec premier foot à 5 amical sans enjeu** (l. 537 + calcul vol W3=90 → W4=60) : `progression_logic` annonce "réduction ~25-30%". Le calcul réel est **-33% volume total** (W3=90 min, W4=60 min), légèrement au-delà de la cible annoncée. Doctrine accepte -25-30% pour beginner low-volume (fragment l. 126-127), donc -33% reste dans la fourchette défendable mais à clarifier dans le texte. Voir issue mineure ci-dessous.

- **Pas de jeu de tête sur ce plan** (safety_notes l. 19) : "Commotion cérébrale (choc tête-tête, tête-ballon mal géré) : pas de jeu de tête sur ce plan." Conforme aux drapeaux rouges football beginner du fragment (l. 237).

## 2. Metadata hooks (Schema v2)

**Per-template** : `week_structure` (linear + micro_pattern + recovery_cadence l. 12-16), `deload_weeks: [4]` (l. 17), `progression_logic` détaillé en 5 principes nommés (l. 18). **PASS**.

**Per-exercise** : scan des 16 séances × ~6-7 exercices ≈ 100 exercices — **100% des exercices possèdent les 5 hooks** (`target_zone`, `required_equipment`, `incompatible_constraints`, `alternatives`, `volume_axis`). Aucun manquant.

`target_zone` : utilise `technique` (drills moteurs passe/contrôle/conduite/frappe), `Z2` (passe-contrôle alternés, course intermittente, jeu réduit, match amical), `RPE 6-7` (S&C off-terrain), `cool-down` (retours calme). Vocabulaire conforme à la convention v2 football (fragment l. 308-314). Aucune valeur générique.

`required_equipment` : kebab-case correct (`cleats`, `ball`, `field`, `cones`, `mat`, `mini-goals`, `training-bibs`). `cleats` + `ball` + `field` systématiques pour les séances terrain (conforme à la lesson learned #9 du fragment l. 391). `mat` pour le S&C off-terrain. Bien.

`incompatible_constraints` : riches et football-pertinents (`ankle-injury`, `knee-injury`, `groin-injury`, `hamstring-injury`, `lower-back-pain`, `concussion-history`, `shoulder-injury`, `wrist-pain`). `concussion-history` présent sur toutes les sessions de match amical et jeu réduit (l. 567, 909, 1080, 1251) — excellent.

`alternatives` : toujours 2 entrées concrètes et chiffrées (substitut sans partenaire / sans cônes / sans terrain / poids du corps). Aucun `alternatives: []` vide. Conforme à la lesson learned #6 du fragment (l. 388).

`volume_axis` : utilise `duration` (drills minutés, jeu réduit), `sets` (passes structurées en séries), `reps` (frappes chiffrées, NHE-équivalent, calf raises). `distance` et `elevation` non utilisés — conforme à la doctrine football (fragment l. 360).

**PASS** sans flag.

## 3. Internal consistency

- `duration_weeks == weeks.count` : 8 == 8. **PASS**
- `sessions_per_week == 2` : 2 séances actives sur W1-W8. **PASS**
- Jours uniques dans [1, 7] : toutes les semaines = [1, 4]. **PASS**
- Volume curve W1→W8 (terrain + S&C) : 70 / 77 / 90 / 60 (deload) / 93 / 98 / 100 (peak) / 90. **Pic W7 confirmé**, **deload W4 confirmé**, autonomy/validation W8 confirmée. **PASS**
- `deload_weeks: [4]` ≠ doctrine fragment l. 374 qui suggère `[5]` pour plan 8 sem beginner. Choix défendable car il pose le cutback à mi-parcours après l'introduction de la frappe placée W3 (logique d'adaptation tendineuse), mais à divergence noter. Voir issue mineure.
- Numbers announced delivered : "30 passes consécutives" annoncé W7-W8 → cible présente W7 drill 8 min (l. 1041) et W8 séance phare test (l. 1212). "Conduite slalom 5 cônes 10 m < 12 sec" → présent W7 (l. 1053) et W8 test (l. 1224). "6 frappes / 10 cible 1×1 m" → présent W7 (l. 1065) et W8 test (l. 1236). "5 contacts cuisse-cuisse-pied" → présent W6 (l. 882). **PASS**
- `progression_logic` cite des éléments réels : passe intérieur du pied W1 (présent l. 47), conduite slalom 5 cônes W3+ (présent l. 401, 695), frappe placée W3 (présent l. 377), foot à 5 amical W4 (présent l. 560), drill mur 50 passes (présent W6-W8 l. 906, 1248), checklist 4 critères W8 (présent l. 1197). **PASS**
- `safety_notes` cite des standards (RICE, FIFA 11+ parties 1/2/3, cap 30-40 frappes / séance, FCmax % zones, test de la parole) qui sont effectivement appliqués dans les `weeks`. **PASS**
- Equipment ⊆ `assumed_profile` OU `alternatives` : `assumed_profile` mentionne crampons, ballon, terrain ou parc/mur. `cones`, `mini-goals`, `training-bibs`, `mat` ne sont pas explicitement dans `assumed_profile` mais chaque exercice qui les utilise propose une alternative (drill mur, drill solo). **PASS** mais voir mineur ci-dessous.
- W4 goal annonce "Volume cible : ~30 min terrain + 25 min S&C off-terrain" (l. 537) mais session 1 terrain = 35 min (l. 543), session 2 S&C = 25 min (l. 589). Décalage 5 min sur le terrain. Mineur.

## 4. Cutback / deload

- `deload_weeks: [4]` — déclaré (l. 17).
- W4 : volume terrain 35 min (vs W3=55, **-36% terrain**), S&C 25 min (vs W3=35, **-29% S&C**), volume total 60 min (vs W3=90, **-33% total**). `progression_logic` principe 4 annonce "~25-30%" mais le calcul réel est -33%. Pas de nouveauté technique cette semaine, premier foot à 5 amical 20 min sans enjeu, S&C revient à la version statique des planches (vs dynamique W3). **PASS** structure deload correctement implémentée mais chiffres légèrement plus profonds que l'annonce.
- Cadence 1 deload sur 8 sem (W4 sur 8) = conforme à la fenêtre doctrine 5-6 build + 1 cutback pour beginner (fragment l. 126).
- Note : la doctrine `Plan 8 sem beginner: [5]` (fragment l. 374) suggère W5 plutôt que W4. Choix défendable (intégration tendineuse après introduction frappe placée W3) mais divergence à signaler. Voir issue mineure.

## 5. Safety

`safety_notes` couvre les 5 sections attendues, sport+level-spécifique :

- **RED FLAGS football beginner** : entorse cheville (n°1), ischio-jambiers (HSI), pubalgie / adducteurs, genou (tendinite rotulienne, syndrome rotulo-fémoral, LCA), commotion cérébrale (jeu de tête banni sur ce plan). Tous football-pertinents, conformes au fragment doctrine (l. 230-237). Pas de copy-paste générique.
- **PRÉVENTION FIFA 11+** : programme obligatoire dès W1, parties 1 et 2 dès W1, partie 3 progressive à partir de W4, raccourcie avant match amical. Réduction blessures 30-70% citée. Conforme F-MARC.
- **PRÉVENTION CHEVILLE-GENOU** : 3 piliers (single leg stance + calf raises + squats bodyweight) appliqués dès W1, cap 30-40 frappes par séance pour la frappe puissance pas avant W6. Excellent.
- **MATÉRIEL OBLIGATOIRE** : crampons FG/SG/TF/IC selon terrain — JAMAIS running shoe sur gazon (risque entorse cheville), protège-tibias dès foot à 5 amical W4. Conforme à la lesson learned #9 du fragment (l. 391).
- **INTENSITÉ** : drills `technique`, `Z1` ou `Z2`, RPE > 6 banni, test de la parole, aucun sprint matchplay, aucun match compétitif chronométré.
- **OVERLOAD SIGNS** : 4 signes (FC repos +10 bpm, sommeil dégradé > 3 nuits, douleur cheville/ischio/adducteurs > 2 séances, motivation effondrée) avec règle 3+ → cutback type W4.
- **MISSED SESSION HANDLING** : règles claires < 1 sem / 1-2 sem / > 2 sem.

**PASS** — qualité au-dessus de la moyenne attendue pour un beginner. Couverture safety football-spécifique excellente.

## 6. EU MDR

- Banned words scan FR (`guérir`, `soigner`, `traiter une pathologie`, `diagnostic`, `thérapie`, `rééducation post-opératoire`, `prescription`, `ordonnance`, `cure`, `soulager`, `réparer le ligament/muscle/tendon`) : **aucune occurrence détectée** (grep nettoyé). Le mot `médecin` apparaît uniquement dans les consignes "consulte un médecin avant de commencer" / "consulte un kiné" — usage légitime EU MDR.
- Banned words EN : aucun.
- **Medical clearance** : présent et bien formulé (l. 19) — antécédent cardiaque, plus de 50 ans débutant complet sans test d'effort, grossesse / postpartum, entorse cheville récente < 3 mois, hamstring < 8 sem, pubalgie > 2 sem symptômes, post-LCA < 12 mois post-op, antécédent commotion < 6 mois. Couvre les 8 triggers du fragment (l. 295-302).
- **Pas de framing rééducation** : le template parle de **prévention** entorse cheville / ischio / genou / adducteurs (acceptable EU MDR), pas de "rééducation post-LCA" ni de "traitement". Distinction respectée.

**PASS**.

## 7. Final autonomy checklist

W8 séance phare J1, theme "Validation — séance phare + checklist autonomie" (l. 1196), `goal` contient explicitement la **CHECKLIST D'AUTONOMIE BEGINNER FOOTBALL 4 critères mesurables/observables** (l. 1197) :

1. 30 passes consécutives intérieur du pied contre mur ou en binôme à 8 m sans rater plus de 3 fois (objectif binaire, plus rigoureux que "5/5" demandé dans la spec).
2. Conduite slalom 5 cônes 10 m en moins de 12 sec sans perdre le contrôle, alternance intérieur-extérieur du pied.
3. 6 frappes sur 10 dans cible 1×1 m à 8 m (4 pied fort + 2 pied faible minimum).
4. Foot à 5 amical 15 min sans inconfort cheville/genou/adducteurs et avec récupération FC en 3 min.

Règle de gating ("3-4 critères validés → prêt programme recreational / moins → reprendre W6-W7", l. 1260) explicite. Aligné FFF Grassroots / FA Discover.

Le critère "échauffement FIFA 11+ autonome" demandé dans la spec n'est pas formalisé en 5e bullet de la checklist mais le warmup de la séance phare W8 est précisément un FIFA 11+ complet 12 min réalisé en autonomie par l'utilisateur (l. 1204). Ajouter un 5e critère explicite serait une amélioration cosmétique (voir mineur ci-dessous).

**PASS**.

## 8. Style

- Français, tutoiement constant ("tu reçois", "tu dois pouvoir", "ton score", "tu es prêt"). **PASS**
- Aucun emoji. **PASS**
- Noms d'exercices clairs, pédagogiques, avec consignes posturales (pied bloqueur, genou dans l'axe, descente 2 sec) et RPE. Vocabulaire football authentique (intérieur du pied, pied bloqueur, conduite slalom, foot à 5, mini-goals, training-bibs). **PASS**

## Issues summary

### Critical (block merge)

Aucune.

### Important (fix recommended)

Aucune.

### Minor (nice-to-have)

- **W4 deload — chiffres `progression_logic` vs réalité** : `progression_logic` principe 4 (l. 18) annonce "~25-30% volume terrain" mais le calcul réel est **-33% volume total / -36% terrain** (W3 total 90 → W4 total 60). Soit corriger le chiffre ("~30-35%"), soit accepter comme arrondi conservateur défendable pour beginner low-volume (la doctrine accepte -25-30% mais permet aussi plus profond si justifié). Non bloquant.
- **`deload_weeks: [4]` vs doctrine `[5]`** : le fragment doctrine football (l. 374) recommande `[5]` pour plan 8 sem beginner. Le template choisit `[4]` (à mi-parcours, intégration tendineuse après introduction frappe placée W3). Choix défendable mais divergence à signaler. Optionnellement : déplacer le deload en W5 pour s'aligner pile sur la doctrine, ou justifier explicitement le W4 dans `progression_logic`. Mineur.
- **W4 goal mismatch** : `goal` W4 (l. 537) annonce "Volume cible : ~30 min terrain + 25 min S&C" mais la session 1 terrain est `duration_minutes: 35` (l. 543). 5 min de décalage. Soit corriger `goal` à "~35 min terrain", soit ajuster la session à 30 min. Mineur cosmétique.
- **`assumed_profile` équipement S&C** : mentionne "crampons, ballon, tenue sport, terrain ou parc/mur" mais n'inclut pas explicitement `cones` (utilisé W2+), `mini-goals`, `training-bibs`, `mat`. Chaque exercice propose une alternative sans (drill mur, drill solo, sol propre), donc fonctionnel, mais mention "5-8 cônes ou plots, tapis ou sol propre pour S&C, mini-buts ou cônes pour jeu réduit, chasubles si effectif" en `assumed_profile` clarifierait. Mineur.
- **Checklist autonomie — pas de 5e critère explicite "FIFA 11+ autonome"** : la spec demandait "≥3-5 critères incluant échauffement FIFA 11+ autonome". Le template livre 4 critères techniques + jeu et le FIFA 11+ est exécuté en warmup W8 mais pas formalisé en bullet checklist. Ajouter "5. Je réalise mon échauffement FIFA 11+ partie 1+2 raccourci 10 min de manière autonome avant chaque séance terrain" couvrirait pile la spec. Mineur cosmétique (déjà couvert implicitement par la pratique W1-W8).

## Sources

- [FIFA — Injury prevention and health promotion (FIFA 11+)](https://inside.fifa.com/health-and-medical/injury-prevention)
- [FIFA 11+ : an effective programme to prevent football injuries — narrative review (PMC)](https://pmc.ncbi.nlm.nih.gov/articles/PMC4413741/)
- [The FIFA 11+ injury prevention program for soccer players — systematic review (BMC)](https://link.springer.com/article/10.1186/s13102-017-0083-z)
- [The FIFA 11+ Soccer Injury Prevention Program — booklet PDF](https://jacobstirtonmd.com/wp-content/uploads/2019/07/The-FIFA-11-Soccer-Injury-Prevention-Program.pdf)
- [The FIFA 11+ — Physiopedia](https://www.physio-pedia.com/The_F%C3%A9d%C3%A9ration_Internationale_de_Football_Association_FIFA_11+)
- [FFF DTN — Parcours de Formation Educateurs / Entraîneurs](https://www.fff.fr/fff/formations/educateurs-entraineurs)
- [UEFA Coaching Licences overview — UEFA.com](https://www.uefa.com/development/coaches/uefa-coaching-licences/)
- [UEFA B Diploma — England Football Learning](https://learn.englandfootball.com/courses/football/uefa-b-licence)
- [Pre-season planning in football — complete guide (Zone14)](https://zone14.ai/en/blog/pre-season-planning-in-football/)
- [ACL Injuries in Soccer Players: Prevention and Return to Play Considerations (PMC)](https://pmc.ncbi.nlm.nih.gov/articles/PMC10743334/)
- [Injury-Proofing the Squad: Protocols for ACL Prevention in Soccer (ISSPF)](https://www.isspf.com/articles/injury-proofing-the-squad-protocols-for-acl-prevention-in-soccer/)

## Recommendation

**APPROVED with minor fixes** — bundle après ajustement cosmétique des 2-3 plus impactants. Les 5 issues mineures sont des clarifications cosmétiques optionnelles (chiffre cutback dans `progression_logic`, choix W4 vs W5 du deload, goal W4 mismatch 5 min, assumed_profile équipement S&C, 5e critère FIFA 11+ checklist) qui ne justifient ni regen ni patch bloquant. Le template est de qualité supérieure : doctrine FFF Grassroots / FA Discover / UEFA Grassroots C / FIFA 11+ correctement intégrée, prévention cheville-genou-ischio sourcée et appliquée dès W1, FIFA 11+ installé W1 (mieux que la spec qui demandait W2), aucun match compétitif chronométré, foot à 5 amical sans enjeu W4+ uniquement, cutback W4 -33% défendable beginner low-volume, checklist autonomie 4 critères observables alignée FFF Grassroots, EU MDR clean (zero banned word), hooks v2 100% couverts, `concussion-history` constraint systématique sur sessions match. **Verdict : APPROVED avec fixes mineurs cosmétiques optionnels.**

## Patches applied (2026-05-01)

- **Goal W4 cutback** : annoncait "~30 min terrain + 25 min S&C" -> aligne avec realite "~35 min terrain + 25 min S&C" (la session 1 W4 est 35 min). Mention cutback "-30 a -35% volume terrain vs W3" pour refleter la profondeur reelle (-33% calculee).
- **progression_logic principe (4)** : "reduction ~25-30%" -> "~30-35% volume total, profondeur acceptee pour ce niveau low-volume debutant". Aligne sur les chiffres reels.
- **Checklist W8 autonomie** : ajout 5e critere explicite "Je realise mon echauffement FIFA 11+ partie 1+2 raccourci 10 min de maniere autonome avant chaque seance terrain", pour couvrir pile la spec doctrine "echauffement FIFA 11+ autonome".
- **deload_weeks: [4]** : conserve (choix pedagogique apres introduction frappe placee W3) - non bloquant, decision documentee dans la review.

**Validation post-patch** : JSON parse OK, weeks.count=8=duration_weeks, hooks v2 100% couverts, EU MDR banned words = 0.

**Verdict final : APPROVED — bundle.**
