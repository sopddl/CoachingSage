# Adaptability : tennis-expert-tournoi-prep-16sem + p1-reduce-frequency

## Rigidity score
**4/10**

Le template est **modérément rigide** face à la réduction de 4 à 2 séances/semaine. Les blocs logiques (progression force, RSA, simulation compétitive) restent intacts structurellement, mais la **densité compétitive W9-W11 devient incompatible** avec 2 séances seulement. De plus, les **contraintes de repos entre composés (150-210 sec)** et l'architecture des complexes PAP (Bloc 2) exigent des séances complètes de 70+ min, ce qui crée un **goulot d'étranglement volumétrique** : fusionner séances = durées totales > 90-100 min, risquant la qualité d'exécution sur les efforts d'intensité élevée.

---

## Patch approach

**Stratégie d'adaptation :** Regrouper les 4 séances hebdomadaires en 2 séances "mixtes" par ordre de priorité : **(1) Séance A = force composée + RSA court (75 min)** pour préserver la progression neuromusculaire et la puissance de déplacement ; **(2) Séance B = jeu compétitif + renforcement préventif (70 min)**. Supprimer les séances technique isolées (J5 classique), les intégrant dans le jeu compétitif de Séance B. Réduire le volume de simulation en Bloc 3 (W9-W11) : passer de 2-3 matchs/semaine à **1 match complet / semaine + 1 match express (8 jeux)**. Cutbacks W4 et W8 restent à 1 session/jour mais comprimés à 40 min. **Compromis accepté :** perte de volume technique isolé (diagnositc en W1 J5, service spécialisé en W5 J5, etc.), mais volume force + jeu préservé.

---

## Concrete modifications

- **W1 J1 + J3 fusionnés → Séance A (75 min)** : back squat 6×4 (W1 structure) + RDL 8×4 + pull-up 8×3 + overhead press (supprimé J2, remplacé par J1 compact) + planche core 3×30 sec. Repos 150 sec composés, zéro perte. Sprint RSA 8×10s/20s (sec, qui est normalement J3) en fin de séance au lieu de J3 isolé. Durée totale 75 min.
- **W1 J5 (technique sur court diagnostic) + J7 (jeu mixte) fusionnés → Séance B (70 min)** : 10 min rallyes fond (diagnoistc allégé) + 15 min services placement (au lieu de 12 services × 4 en J5 isolé) + 35 min jeu de points 4-4 ou 8 jeux express (au lieu de W1 J7 avec 2 sets complets) + external rotation + wrist curls 2 min. Aucun jeu match complet en W1 (acceptable : W1 est diagnostic, jeu complet repoussé en W2).

- **W2 J1 + J3 → Séance A (75 min)** : Back squat +2.5-5 kg (progression W1→W2, inchangée) 6×4 + RDL idem + overhead press 10×3 (push vertical supprimé J2, ici conservé) + lateral lunge 10×3 + planche 40 sec. RSA 6×30s/60s (progression ratio vs W1, cf. progression_logic ligne RSA) en fin = sprint latéraux + T-drill au lieu de J3 isolé. **Durée 75 min.**

- **W2 J5 + J7 → Séance B (75 min)** : Service cinématique trophée 12×4 + service 1re balle 15×3 + rallyes croisés 5 min + jeu de points 8 jeux express (au lieu de 2 sets complets J7). External rotation post-jeu + wrist curls. **Durée 75 min (comprend le jeu compétitif réduit).**

- **W3 J1 + J3 → Séance A (80 min)** : Back squat 5×4 + RDL 6×4 + lateral lunge 10×3 + **box jump initiation 5×4 (pliométrie basse intensité, cf. W3 J1 progressif ; reste d'abord en J1 pour intégration force)** + bird-dog 10×3 + planche 40 sec. **RSA pyramidal W3 (15-30-45-30-15 sec)** + lateral sprint avec freinage 6×8s (fin de séance). **Durée 80 min.**

- **W3 J5 + J7 → Séance B (80 min)** : Approche-volée-smash 12×4 + jeu en situation construction/finition 8 min + drop shot 15×3 + **Match simulé full score 50 min** (au lieu de J7 seul 85 min avec jeu complet + renforcement). Renforcement préventif 5 min (post-match, allégé). **Durée 80 min.** Compromis : W3 J7 normalement 85 min (match + renforcement), ici 80 min avec match complet mais renforcement réduit post-séance.

- **W4 J1 + J3 + J5 + J7 → 1 séance courte (55 min) jour 3 ou 4** : Back squat 5×3 (allégé) + RDL 6×3 + pull-up 8×2 + planche 30 sec × 2 (force cutback standard) + trot zone 2 20 min + mobilité 10 min + épaule, avant-bras, hanche (prévention en J7 ramassée ici). Aucune séance J2, J5, J7 en W4 — jour entier off pour récupération active (W4 J7 j'était déjà mobilité, ici consolidé dans séance unique). **Cutback W4 ramassé en 1 séance courte 55 min, conforme au cutback objective (volume -15%).**

- **W5 J1 + J3 → Séance A (80 min)** : Back squat + box jump (complexe PAP) 4 reps chaque / 4 séries × 210 sec repos. **RDL + sprint 10m (PAP) 4 reps / 4 séries × 210 sec repos.** Lateral band walk + bound 10/5 × 3 + overhead press 8×3 + pallof press 12×3. **Sprint résisté élastique 8×8s/52s** (fin de séance, normalement J3) + T-drill ×6. **Durée 80 min.** Risque d'allongement : repos 210 sec pour PAP non négociable (NSCA) → durée totale monte à ~85 min si tout enchaîné. **Compromis accepté : réduire overhead press de 10 à 8 reps et pallof de 12 à 10 reps pour rester < 80 min.**

- **W5 J5 + J7 → Séance B (80 min)** : Inside-out forehand 20×3 + service + 1 + 2 schéma 15×4 + slice revers attaque 15×3 + **Match avec contrainte serveur-volleyeur obligatoire 30 min** (au lieu de W5 J7 avec 30+35 min = 2 matchs). Renforcement épaule-poignet 5 min. **Durée 80 min.** Accepte loss d'un match complet W5 : la semaine W5 est avant Bloc 3 simulation, donc tolérable.

- **W6 J1 + J3 → Séance A (85 min)** : Back squat + box jump (3 + 5 reps) × 4 / 210 sec. **Bulgarian split squat 8×3.** RDL unilatéral 8×3. Cable chop diagonal 12×3. Pull-up 8×3. Planche + tap 40 sec × 3. **Simulation endurance échange 35 min** (normalement J3 isolé) : 8 sec effort + 20 sec récup = points répétés (4 pts = 1 jeu, 6 jeux = 1 set, 2-3 sets simulés). **Durée ~85 min.** Repos 210 sec PAP non compressible → montée en durée acceptée.

- **W6 J5 + J7 → Séance B (90 min)** : Retour variation 20×4 + jeu volée 3-balles 15×3 + super tie-break 2×10 pts avec 3 min pause entre eux (au lieu de W6 J7 avec match 3 sets 70 min + analyse). **Durée ~65 min jeu.** Ajouter analyse post-Super TB 15 min + renforcement préventif 10 min. **Durée totale ~90 min.**

- **W7 (et W8 cutback) J1 + J3 → Séance A (80 min, W7 ; 60 min W8)** : Back squat 5×3 (W7 dans progression linéaire de Bloc 2) + kettlebell swing 5×4 + plyometric push-up 8×3 + pull-up 8×3 + single-leg squat 6×3 + chop médecine ball 10×3 + **RSA court 6s/24s : 12 sprints + pause 3 min + 10 sprints** (normalement J3 en W7). **W8 : réduire à back squat 3×3 + kettlebell 5×2 + ply push-up 8×2 + RSA 6×6s/24s seulement.** **Durée W7 : 80 min ; W8 : 60 min.**

- **W7 J5 + J7 → Séance B (85 min, W7 ; 50 min W8)** : Service 10×5 + inside-in 20×3 + jeu libre domination offensive 25 min + jeu 8 (filet) 20 min (au lieu de W7 J5 80 min + J7 85 min = 165 min) → fusionné en **85 min W7**. **W8 : réduire à service placement 10×2 + rallyes croisés 20 min + mobilité 15 min, visualisation 5 min. Durée W8 : 50 min.**

---

## Rigidity issues

- **Impossibilité W9-W11 simulation compétitive réelle** : template prévoit 2 matchs/48h (W9), 3 matchs/4j (W11). En 2 séances/sem = 1 jour de jeu compétitif max par semaine. Réduction forcée à 1 match complet + 1 match express (8 jeux) par semaine. **Densité compétitive ne peut pas être répliquée** — c'est une faiblesse majeure du patch. Le joueur arrivera au tournoi (W16) **moins habitué à l'enchaînement de matchs** que prévu.

- **Contrainte repos 210 sec sur complexes PAP (W5-W7)** : Fusion J1+J3 force+cardio crée une durée minimale ~85-90 min dès que les PAP sont intégrés. Réduire les reps accessoires est le seul levier, mais coûte du volume secondaire.

- **Pliométrie W3 initiée en J1 au lieu de fin-Bloc-1** : W3 est normalement la dernière semaine avant cutback W4, donc pliométrie bas vol « en fin de Bloc 1 » selon progression_logic. Ici, box jump 5×4 est intégré J1 (séance force), non isolé. Reste acceptable si atterrissage de qualité et repos 90 sec préservé (90 sec < 150 sec entre composés ≠ compromis technique grave).

- **Suppression diagnostic technique W1 J5 isolé** : W1 rallyes fond, service, retour étaient diagnostiques (identify level). Ici fusionné en 10 min rallyes + 15 min services placement dans Séance B (réduction 75 min → 15 min services). **Diagnostic de base moins approfondi**, mais le jeu de points 4-4 (35 min) offre une lecture qualitative suffisante pour W1.

- **Suppression technique isolée J5 W2-W7** : Service placement, coup droit inside-in, approaches, drop shots normalement en séances J5 dédiées. Ici comprimés dans Séance B jeu compétitif. **Risque : moins de reps techniques pures** (ex : W2 15 returns × 3 séries en J5 isolé devient 5 min dans Séance B). Compensation partielle : reps augmentent en match réel (plus de returns dans 8 jeux que dans 15 reps d'exercice).

---

## Contradictions

- **Contradiction volume simulation W9-W11 vs 2 séances/sem** : safety_notes stipule W11 = « pic de volume compétitif — 3 matchs en 4 jours ». Avec 2 séances/sem (soit 1 jour de jeu), impossible de faire 3 matchs. Solution proposée : 1 match complet + 1 match express (8 jeux = ~30 min, peut se jouer après une séance de force débutée le même jour). Résultat : W9-W11 → densité 1 match complet + 1 express/sem (vs 2-3 matchs/sem attendus). **Ce patch viole l'invariant « simulation compétitive graduelle »** du progression_logic point (5). Le joueur arrivera moins préparé à l'enchaînement dense de W15-W16.

- **Contradiction intensité-repos sur PAP W5-W7** : progression_logic déclare repos 210 sec « assure la récupération neuromusculaire complète » et « Ne pas réduire à 180 sec ». Fusion J1+J3 force+RSA impose des durées > 80 min *si* tous les composés + complexes PAP + RSA sont enchaînés avec repos 210 sec strict. **Patch contraint à réduire quelques séries accessoires (overhead press 10→8 reps, pallof 12→10 reps)** pour rester < 85 min. **Mineure : les exercices réduits sont accessoires (pull, push, core), pas les composés lourds (squat, RDL, box jump PAP).** Repos 210 sec sur PAP primaires = respecté.

- **Contradiction cutback W4 vs structure prescrite** : W4 est normalement 4 séances (J1 force allégée, J3 cardio, J5 technique léger, J7 mobilité). Ici patch la ramasse en **1 séance courte unique 55 min** jour 3 ou 4, avec 3 jours off avant la séance et 3 jours off après. **Écart vs template : W4 prescrit un espacement J1-J3-J5-J7 d'une séance tous les 2 jours (récupération distribuée).** Ici, 1 jour intensité + 6