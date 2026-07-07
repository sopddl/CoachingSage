# Passe Sport — Synthèse A (dosage) + B (dessins) sur 9 sports — 2026-06-08

Issu du workflow parallèle (1 agent/sport) après le pilote muscu. **A** = brouillon spec dosage
(dimensions Matrice B + gaps FOCUS). **B** = dessins (fixes resolver appliqués vs à dessiner vs
icône sport acceptable). Référentiel = `referentiel-dosage-cameleon-v2-FIGE.md`.

## B — DESSINS : conclusion transverse
`.generic` rend l'**icône du SPORT** (coureur/cycliste/ballon/raquette), PAS un haltère → pour les
drills spécifiques (passes foot, échanges tennis, longueurs nat, sorties vélo) c'est **honnête et
acceptable**. Pas de catastrophe. Running/cycling/swimming/yoga = **0 .generic** (sport-fallback +
61 poses yoga). 

### Fixes resolver SÛRS appliqués cette nuit (pattern existait, keyword manquait)
- **wall sit → squat** (running, triathlon, hiking) · **external rotation → ytwActivation** (tennis, nat) · **lateral bound → plyo** (tennis).
- + clôture muscu : **overhead triceps → générique** (≠ pushdown) · **woodchopper → générique** (≠ pallof).

### À DESSINER (décision produit Sophie — par fréquence)
- **step-up** (montée sur banc) — TRÈS fréquent (running, triathlon, hiking, foot) — candidat #1 pattern dédié `.stepUp`.
- **hiking** : pas de sport-fallback → 2 patterns `.hikeWalk` (marche/montée + bâtons) + `.hikeDescent` couvriraient ~50 drills cardio (sinon icône sport, acceptable).
- **tibialis raises** (HIIT, ~86 occ) — ⚠️ NE PAS mapper sur calfRaise (antagoniste). Dessin dédié ou générique.
- **mountain climbers, jumping jacks** (HIIT mains nues) — pas de pattern (ne pas forcer plyo/core).
- **yoga** (~10 vraies postures sans dessin) : Ustrasana, Dhanurasana, Salabhasana, Bakasana/Bhujapidasana (arm balances), Purvottanasana, Kapotasana, Upavistha Konasana, Phalakasana, Ardha Matsyendrasana — orientations parfois fausses (debout au lieu d'assis/à genoux).
- **transitions T1/T2** (triathlon, ~80 occ) — dessin « transition » nice-to-have.
- swimming dryland (external rotation band, scapula retraction) · med ball throw (tennis) · reverse hyper (muscu) — basse priorité.

## 🐛 BUGS FONCTIONNELS découverts (hors dessins)
- **HIIT work:rest CASSÉ (P0)** : les blocs sont écrits « NN sec work + NN sec rest » mais `workRest()` (`SessionTimerPhase.swift:280`) ne parse que le séparateur « / » → la phase REST est rendue comme du WORK, pas de pré-annonce « 20s repos », `circuitPhases()` jamais atteint. **Le cœur du HIIT (2-bornes) est mort.** À corriger.
- **cycling : `targetZone` VIDE** dans les 4 templates (zone FTP + cadence en texte libre) → le badge zone / bandeau allure ne se déclenche jamais. Pré-requis DONNÉES avant FOCUS.
- **triathlon brick** : `SessionSportInference` prend le 1er mot-clé du nom de session → la partie Run d'un brick « Bike + Run » hérite du dosage/dessin cycling (fuite cross-discipline).

## A — DOSAGE par sport (brouillons de spec pour comités/implem)
| Sport | Dimension héros | Gaps FOCUS clés | Prérequis |
|---|---|---|---|
| **Running** | Allure/zone (bandeau couleur + voix) | allure en chip pas bandeau ; zones Daniels/pace non vulgarisées (plainEffort=RPE only) ; récup active non typée ; distance dans `duration` | étendre `DosageFormatting` aux zones (réutiliser glossaire Daniels) ; **0 enrichissement template** (données déjà là) |
| **Cycling** | Puissance/zone (+cadence) | **targetZone vide** ; chrono héros au lieu de zone ; cadence absente ; Audio (mains guidon) le + dégradé | **peupler targetZone + champ cadence** (données) AVANT FOCUS ; variante=déjà via `alternatives` |
| **Swimming** | Distance × départ (send-off) | distance en texte `duration` ; send-off inexistant ; EN1/EN2/CSS en jargon ; Minuté/Audio reps-driven non pertinents | ajouter champs `distance`/`sendOff` (non-breaking) ; glossaire EN1-3/CSS |
| **Triathlon** | = agrégat run+bike+swim | distance/cadence/send-off non modélisés ; brick leak ; zones en badge | réutiliser les 3 profils ; fix inférence par-exercice |
| **Yoga** | Chrono (+ souffles) | **pas de champ `breaths`** ni affichage « ≈ 5 respirations » ; glossaire souffles absent (P0) ; variante props non structurée ; côté G/D non câblé | ajouter `breaths:Int?` (référentiel le liste) + glossaire |
| **HIIT** | work:rest (2 bornes) | **bug parsing work:rest (P0)** ; format « max reps en X » non géré ; round counter mort ; couple work:rest illisible en Manuel | fix parsing `workRest()` + champ format HIIT |
| **Hiking** | D+ / dénivelé (+ vitesse asc.) | **0 dimension hiking rendue** ; sport absent resolver+voix ; D+ en texte ; sac via `load` non pré-rempli ; glossaire « dénivelé » P0 | champ/parse D+ + bandeau allure + glossaire ; (données dans les noms) |
| **Tennis** | RPE/densité (+ côté coup droit/revers) | RPE chip OK ✓ ; **côté coup droit/revers non rendu** (isUnilateral ne capte que « par côté ») ; densité absente ; héros reps muscu-only | détecter forehand/backhand → side ; densité = chantier |
| **Football** | RPE central (+ work:rest jeux + ateliers) | RPE en chip pas héros ; work:rest jeux réduits non typé ; ateliers absents ; côté pied fort/faible hors-muscu non câblé | chemin « RPE héros » + phases ON/OFF + côté hors-muscu ; volet S&C déjà OK (chemin muscu) |

## Ordre suggéré pour la série (effort croissant)
1. **Running** (gros impact, 0 enrichissement données — pur rendu) + **Tennis** (côté coup droit/revers, quick win).
2. **HIIT** (fix bug work:rest P0) + **Yoga** (champ breaths + glossaire).
3. **Hiking** (D+ + bandeau) + **Cycling** (prérequis données targetZone).
4. **Swimming** (champs distance/send-off) + **Triathlon** (agrégat, après les 3 disciplines) + **Football** (RPE héros + ON/OFF).
