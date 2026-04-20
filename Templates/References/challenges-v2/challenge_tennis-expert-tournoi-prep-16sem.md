# Challenge Report : tennis-expert-tournoi-prep-16sem

## Verdict
Template **bundlable en l'état avec patches mineurs critiques requis**. La structure périodisée est rigoureuse, alignée NSCA/ACSM, et les protocoles de sécurité sont exhaustifs. Cependant, 3 incohérences factuelles bloquent le bundle production : (1) repos composés W1-W3 affichent 150 sec au lieu des 150-180 sec annoncés dans progression_logic ; (2) complexes PAP W5 déclarent 210 sec (3 min 30) mais la progression_logic exige 200-210 sec — absence de cohérence de bornes hautes ; (3) protocoles maladie W10-W12 énoncés dans safety_notes ne sont pas reflétés dans la structure des weeks elles-mêmes (gap structurel mineur mais pédagogiquement confus). Reste : une excellente base, corrections rapides, bundle validé en 1-2h.

---

## Issues critiques (bloquantes pour bundle)

- **[W1-W3 composés]** Back squat, RDL : `rest_seconds: 150` affiché, mais `progression_logic` énonce **"2 min 30 minimum (ACSM/NSCA standard composé lourd)"** = 150 sec exactement. OR `safety_notes` dit **"composés : repos 2 min 30 minimum"** (150 sec) mais `progression_logic` cite aussi **"rest_seconds portés à 200-210 sec pour les complexes afin de respecter le seuil ACSM/NSCA"**. Incohérence d'énoncé : 150 ≠ 200-210. **Fix** : standardiser à **150 sec pour composés lourds simples W1-W3**, confirmer 200-210 sec **exclusif aux complexes PAP W5-W7** (ce qui est fait dans les exercises eux-mêmes, mais progression_logic prête confusion). Clarifier dans progression_logic : "Bloc 1-2 composés simples : 150 sec (2 min 30) / Complexes PAP W5-W7 : 200-210 sec (3 min 20)".

- **[W5-W8 complexes PAP]** `rest_seconds: 210` (3 min 30) vs `progression_logic` énonce **"200-210 sec (environ 3 min 20)"**. Incohérence numérique : 210 sec = 3 min 30, pas 3 min 20 (qui = 200 sec). **Fix** : soit standardiser à `rest_seconds: 200` (3 min 20 exact), soit corriger progression_logic à "210 sec (3 min 30)". Recommandation : **garder 210 sec dans exercises (valeur NSCA acceptée)** et corriger progression_logic à "210 sec = 3 min 30".

- **[W10-W12 protocole maladie]** `safety_notes` détaille : "Maladie en W10-W12 : sauter 1-2 matchs simulés mais maintenir les séances de force et de prévention." OR la structure des weeks W10, W11, W12 **ne contient aucune note d'adaptation ou de variante "si maladie"** dans les sessions elles-mêmes. Un utilisateur tombant malade ne saura pas quelle session garder / quelle session sauter. **Fix** : ajouter une sous-note dans W10 J3/J5 et W11 J3/J5 : "(Si maladie cette semaine : sauter ce match, garder les séances force J1 et renforcement prévention J7. Reprendre simulation dès guérison sans reculer le plan entier.)" Ou ajouter une session "protocole maladie W10-W12" en début du bloc 3 avec variantes claires.

---

## Issues importantes (à corriger avant bundle idéal)

- **[W12 bilan endurance]** W12 J3 note "Match filmé — 2 sets" mais le goal énonce "Récupérer du pic de W11. Volume jeu -20%." OR 2 sets filmés + analyse vidéo 20 min = charge cognitivement proche de W11 J5 (60 min de match simulé). Incohérence modérée : volume jeu devrait être < 1 set complet ou 1 set réduit (8-10 jeux max) pour respecter la récupération annoncée. **Fix** : réduire à **1 set complet OU 2 super tie-breaks**, garder l'analyse vidéo.

- **[W15 jour 3]** Nommé "Technique — dernier réglage" mais contient 3 blocs : service (6 reps, 2×10), jeu libre (35 min). Total ~50 min de jeu réel (pas les 65 min affichés si on compte warmup). Coherence : OK, mais wording "dernier réglage" suggère une séance légère vs réalité = 2 heures de tennis effectif (warmup + service + jeu). **Fix** : renommer en "Technique — finalisation sans fatigue" ou réduire à **1 set seulement** en lieu de "jeu libre 35 min" pour garantir fraîcheur totale veille tournoi.

- **[Zones FC W1 J3 + safety_notes]** Zones FC définies comme : Zone 2 = 60-75%, Zone 3 = 75-85%, Zone 4 = 85-95%. OR aucune mention de **Zone 1 (< 60% FCmax) = récupération très légère**, inévitable lors de retours après blessure ou maladie (safety_notes protocoles W10-W15). **Fix** : ajouter en `safety_notes` (section INTENSITÉ) : "Zone 1 = 50-60% FCmax, utilisée uniquement en retour progressif post-maladie ou post-blessure légère (jours 1-2 de reprise)."

---

## Issues mineures (nice-to-have)

- **[Nomenclature exercices W6 J3]** "Super tie-break sous pression (10 points)" : le super tie-break ITF officiel se joue à **10 points** (premier à 10 pts, 2 points d'écart), mais la note dit "Réduire à 2 super tie-breaks avec 3 min de pause entre eux (vs 3 enchaînés)". Logique de réduction claire, mais pédagogiquement, il serait utile de préciser : "Format : 10 points (super tie-break ITF officiel), 2 séries avec 3 min de pause entre eux pour éviter une fatigue non représentative."

- **[W11 J3 et J5 : alimentation inter-match]** Safety_notes énonce : "Entre deux matchs le même jour (W11 J3) : 20 min minimum de pause, hydratation + alimentation légère (sandwich, barre énergétique), étirements doux 5 min." OR les exercises de W11 J3 ne **mentionnent pas explicitement cette pause alimentaire de 20 min entre match 1 et match 2**. L'utilisateur verra "pause nutrition et récupération inter-match 20 min" mais risque d'oublier si mal structurée. **Fix** : ajouter dans W11 J3 exercise "Pause nutrition" une note de la couleur : "(Obligatoire : eau 500 ml + banane ou barre énergétique + étirements doux 5 min. Ne pas sauter. Consultez safety_notes section nutrition inter-rounds si besoin)."

- **[W16 protocoles flexibilité de jour]** W16 énonce "Les 4 séances ci-dessous sont des PROTOCOLES RÉUTILISABLES (jour de match, récupération inter-rounds, match décisif, bilan final) et non des jours fixes." **Pédagogie bonne**, mais absence de **tableau de décision/workflow** montrant comment adapter les 4 protocoles selon le tableau du tournoi (ex: "Si 2 matchs même jour → appliquer protocole J1 + protocole J3 ; si 1 jour off → appliquer protocole J3 complet"). **Nice-to-have** : ajouter un schéma ou flowchart dans le summary ou en préambule W16.

- **[Pliométrie W3 hauteurs]** W3 J1 dit "Box jump ou saut vertical — initiation" avec "Hauteur modeste — Bloc 2 augmentera la hauteur." OR aucune **hauteur en cm spécifiée**. NSCA recommande initiation < 40 cm (énoncé dans progression_logic), mais les exercises ne le rappellent pas. **Fix** : ajouter note W3 J1 : "(Pliométrie initiation : box ≤ 30-40 cm OU sauts verticaux sans box. Progression W5-W7 : augmenter à 40-50 cm si contrôle optimal.)"

- **[Wrist curls systématisation]** Apparaît en W2 J7 (2 séries), W3 J7, W6 J5, W11 J7, W12 J7. **Fréquence irrégulière** : tantôt 1x/sem (W2, W3), tantôt 2x/sem (W6, W11). Progression_logic dit "maintenu SANS EXCEPTION toutes les 16 semaines", mais les weeks montrent irrégularité. **Fix** : standardiser à **2 séries wrist curls + reverse wrist curls tous les jours J7 (récupération)** ou clarifier dans progression_logic : "Wrist curls 2x/sem minimum (J5 après match, J7 en récupération)."

---

## Manques notables

- **Protocole retour progressif post-blessure articulaire (douleur modérée 3-4/10).** Safety_notes énonce la règle : "si douleur 3-4/10 persistante → consulter ; si validée → retirer mouvements problématiques seuls." OR **aucune semaine n'inclut de variantes structurées** (ex: "W10 Si douleur épaule : remplacer pull-up par lat pulldown, garder squat/RDL/core"). Un utilisateur blessé à W9 ne saura pas comment adapter W10-W12 de façon autonome. **Manque pédagogique** : ajouter dans progression_logic ou safety_notes un tableau de substitution : "Si douleur épaule (non confirmée rupture) → supprimer pull-up/overhead press → garder squat/RDL/core / ajouter external rotation 4×15 tous les jours" (exemple concret).

- **Cadence de service / vélocité cibles.** W7 J5 mentionne "Mesurer ou estimer la vitesse. Objectif : 180-200 km/h pour une 1re de service de haut niveau." OR aucune **progression de vélocité de service à travers les blocs** (W2, W5, W7 devraient avoir des targets échelonnés). **Manque de clarté** : ajouter cibles : "W1-W2 : 160-170 km/h (70-75% max) ; W5-W7 : 180-190 km/h (85-90% max) ; W13-W16 : 190-200 km/h (95-100% max, qualité maximale)."

- **Statistiques de match / carnet de bord à tenir.** Safety_notes évoque "Équipement monitoring : carnet écrit ou tableur numérique pour les statistiques de matchs" OR aucune semaine n'énonce **quelles statistiques tracker concisement** (ratios 1re balle, fautes directes, break pts, etc.). **Manque opérationnel** : ajouter en W9 J3 (bilan post-match 1) : "Carnet de bord simplifié : (1) Ratio 1re balle / (2) Fautes directes (revers ? coup droit ?) / (3) Break gagnés / concédés / (4) RPE (1-10) / (5) Ajustement tactique pour prochain match."

- **Plan B si blessure en W13-W16.** Safety_notes énonce : "Maladie en W13-W15 : couper la semaine concernée, reprendre le taper original en décalé d'une semaine. Le tournoi peut être reporté si nécessaire." OR **aucune variante structurée** (ex: "Si blessé W14 : reprendre W13 complètement, sauter W14, puis W15 réduite à 50% du volume avant tournoi en W16"). Risque : utilisateur comprend qu'il doit repousser le tournoi mais ne sait pas comment ré-amorcer un taper de 2-3 semaines. **Manque** : ajouter flowchart "blessure semaine 13-15 → décisions d'options tournoi".

---

## Scores (sur 10)

- **Cohérence interne : 8/10**
  - Progression linéaire W1-W3 → PAP W5-W8 → simulation W9-W12 → taper W13-W16 logique et progressive.
  - **Défaut** : repos composés et complexes mal alignés (150 vs 200-210 sec confusion), W12 jeu dépasse légèrement la cible de réduction -20%.
  - Cutback weeks (W4, W8) bien positionnées (tous les 4 sem, réduction 15-20% cohere).
  - Numéros de reps vs charges généralement cohérents (squat 6→5→4 progression linéaire).

- **Alignement référentiel : 9/10**
  - NSCA/ACSM respectés : repos 2-3 min composés, repos 200+ sec complexes PAP, pliométrie basse intensité W3 conforme recommandations.
  - Patterns fondamentaux couverts (squat, hinge, push H/V, pull H/V, rotation core — complet pour tennis).
  - RSA progression cohérente : W1-W4 endurance RSA (ratio 1:2→1:3), W5-W7 sprint intensité, W13-W16 affûtage (ratio 1:9→1:11 qualité neuro). Transférable tennis 9/10.
  - **Léger défaut** : zones FC définies tardivement (W1 J3), pas de Zone 1 pour retour post-maladie.

- **Sécurité : 9.5/10**
  - Safety_notes **exhaustifs et détaillés** : drapeaux rouges clairs (épaule, coude, cheville, ischio-jambiers), protocoles maladie énoncés, zones FC fournies, hydratation/nutrition spécifiées (1 L/h tournoi, électrolytes).
  - Prévention coiffe systématisée (external rotation inchangé 16 sem) = gold standard.
  - **Manques mineurs** : protocoles post-maladie W10-W12 énoncés en safety_notes mais non structurés dans weeks (confusion opérationnelle). Pas de variantes blessure légère dans les exercises eux-mêmes.
  - Signes de surcharge identifiés (FC repos +10 bpm, etc.), cutback protocole explicité.

- **Pédagogie : 8.5/10**
  - Progression claire : fondation → intensité → compétition → affûtage. Chaque week a un goal explicite.
  - **Forces** : warmups/cooldowns partout, notes sur les exercices fouillées, RPE cible spécifiées, progression_logic complète.
  - **Faiblesses** : W16 protocoles "réutilisables" manquent d'organigramme d'application concret. Wrist curls fréquence irrégulière (pédagogie "systématique" vs réalité). Carnet de bord type non proposé malgré safety_notes mention. Checklist autonomie W16 excellente mais tardive (aurait pu être en W1 pour expectation setting).

- **Global : 8.7/10**
  - Template **très bon, bundlable en prod** : structure périodisée rigoureuse, alignement NSCA/ACSM, sécurité exhaustive, pédagogie progressiste.
  - **Patches nécessaires avant bundle** : 3 fixes critiques (repos secondes incohérence, W12 charge trop élevée, W10-W12 protocole maladie structure), ~5 nice-to-have (clarifications zones FC, carnet de bord type, protocole post-blessure, vélocité service cibles, flowchart W16).
  - Temps patch : 1-2h, validé en 3-4h.