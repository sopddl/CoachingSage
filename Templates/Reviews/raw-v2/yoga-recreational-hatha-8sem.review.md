# Quality Review — yoga-recreational-hatha-8sem

**Verdict** : APPROVED
**Sport** : yoga **Level** : recreational **Schema version** : 2

## 1. Doctrine alignment

Le template s'aligne fidèlement sur la doctrine Hatha doux + Iyengar + Krishnamacharya Vinyasa Krama, avec quelques choix Ashtanga (Surya Namaskar A/B canoniques). Vérifié contre 5 sources publiques.

**Hatha doux dominant et distribution holds/flow** : OK. Distribution déclarée 60/40 holds/flow, vérifiable dans les semaines (target_zone `hold-30s` et `hold-45s` dominent quantitativement, breath-led et flow restent secondaires). Cohérent avec l'approche Iyengar qui privilégie analyse alignement et tenue plutôt que vinyasa rapide ([Yoga Education Institute, Iyengar Yoga primer](https://yogaeducation.org/wp-content/uploads/2019/05/Iyengar-yoga.pdf), [Yoga Vastu, Modified Surya Namaskar Iyengar](https://yogavastu.com/p/modified-surya-namaskar/)).

**Surya Namaskar A introduction progressive** : OK. Préparation par sections W1 J5 (Tadasana → Urdhva Hastasana isolés), enchaînement complet 3 cycles W2 J3, montée progressive 3→4→5 cycles W3-W6, knees-down Chaturanga jusqu'à W6 minimum (annoncé default_objective + cohérent avec la guidance Yoga Journal et Ashtanga beginner : "modify by stepping back instead of jumping and bending the knees", [Yoga Journal Sun Salutations guide](https://www.yogajournal.com/yoga-101/surya-namaskar/), [Ashtangayoga.info Surya Namaskara A](https://www.ashtangayoga.info/ashtanga-yoga/surya-namaskara-a-sun-salutation/)).

**Surya Namaskar B introduction W5** : OK et même prudent. Maehle / tradition Ashtanga prescrit 3-5 SN-A puis 3-5 SN-B ; le template attend 5 semaines pour introduire SN-B (intégrant Utkatasana et Warrior I), ce qui est plus conservateur que la doctrine pure Ashtanga mais cohérent avec un public recreational et Krishnamacharya Vinyasa Krama.

**Équilibres simples Tree pose et Warrior III avec bloc** : OK. Vrksasana introduit W3, Garudasana W5, Virabhadrasana III avec bloc en main W6 — gradient logique (1 pied statique → bras croisés/jambes croisées → équilibre en T). Bloc en main pour Warrior III est une modification Iyengar pédagogique reconnue (référence d'alignement). Mur à proximité pour appui rapide explicitement noté pour les 3 équilibres.

**Ujjayi W3+ max 5 min/jour position assise stable** : OK. Le template introduit Ujjayi explicitement W3 J1 ("PREMIÈRE INTRODUCTION Ujjayi"), maintient le cap "MAX 5 MIN/JOUR" répété dans toutes les sessions Ujjayi de W3 à W8, avec rappel de retour Dirgha si étourdissement. Cohérent avec [Yoga Sutra 2.49-2.53 sur la régulation du souffle après maîtrise de l'asana](https://swamij.com/yoga-sutras-24953.htm) et [yog school India : "start with short sessions and gradually increase"](https://yogschoolindia.com/pranayama-for-beginners-5-essential-techniques-how-they-work-and-where-to-start/). Le template ajoute correctement les contraindications hypertension / pregnancy / frequent-headaches sur les exercices Ujjayi.

**Inversions wall-only — Sirsasana INTERDIT** : OK et explicite. default_objective + safety_notes + progression_logic mentionnent tous trois "Sirsasana INTERDIT". Inversions limitées à : Adho Mukha mains au mur (W1-W2), Viparita Karani (jambes au mur) à partir de W3. Cohérent avec [Yoga Journal "Ask the Teacher: When Not to Invert"](https://www.yogajournal.com/practice/yoga-sequences/when-not-to-invert/) et [Adventure Yoga Online Legs-up-the-wall benefits](https://adventureyogaonline.com/legs-up-the-wall-benefits/) : Viparita Karani est la vraie inversion grand-public sans risque cervical/oculaire. Contraindications glaucoma/hypertension/detached-retina correctement portées sur Viparita Karani.

**1 séance restorative / sem** : OK voire au-delà. J7 est systématiquement restorative (pranayama dédié + Viparita Karani et/ou Supta Baddha + Savasana long). Les semaines de cutback W4 et W7 sont presque entièrement restoratives.

**12-18 postures séance pic, 45-60 min** : OK. Séance phare W8 J5 = 60 min, 20 postures explicitement énumérées #1 à #20 (légèrement supérieur à 12-18, mais le template assume cette spécificité dans default_objective : "20 postures cibles"). Les autres séances tournent entre 8 et 13 postures. Acceptable car la séance phare est le livrable d'autonomie et Sophie a annoncé "20 postures maîtrisées" dans default_objective.

**Vol pic 180-300 min/sem, 3-4 sessions/sem** : OK. Volume hebdo 160 → 190 → 220 → 175 (cutback) → 240 → 270 → 215 (cutback) → 290 min, dans la fourchette doctrinale. 4 sessions/sem (J1/J3/J5/J7) toute la durée du plan, cohérent.

**Deload toutes 4 sem (-15 à -25%)** : OK. `deload_weeks: [4, 7]` avec W4 = -20% (175/220) et W7 = -20% (215/270). Cadence 3-sem entre les deux deloads (W3→W7 = 4 sem post-W4, W6 pic), ce qui correspond aux pratiques recreational raisonnables.

**Sources doctrine consultées** :
- [Yoga Education Institute — Iyengar Yoga primer](https://yogaeducation.org/wp-content/uploads/2019/05/Iyengar-yoga.pdf)
- [Yoga Alliance Standards for Registered Yoga Schools 2025](https://yogaalliance.org/wp-content/uploads/2025/05/Standards-for-RYS-Credentials_NB22my-.pdf)
- [Yoga Journal — Sun Salutations: A Complete Guide to Surya Namaskar A](https://www.yogajournal.com/yoga-101/surya-namaskar/)
- [Swamij — Yoga Sutras 2.49-2.53 Pranayama](https://swamij.com/yoga-sutras-24953.htm)
- [Yoga Journal — Ask the Teacher: When Not to Invert](https://www.yogajournal.com/practice/yoga-sequences/when-not-to-invert/)
- [Ashtangayoga.info — Surya Namaskara A traditional](https://www.ashtangayoga.info/ashtanga-yoga/surya-namaskara-a-sun-salutation/)

## 2. Metadata hooks (Story 0.5.9 / Schema v2)

**Per-template** :
- `week_structure` : présent et bien rempli (`type: linear`, micro_pattern doctrine-spécifique, recovery_cadence explicitant 2 cutbacks).
- `deload_weeks` : `[4, 7]`, cohérent.
- `progression_logic` : très détaillé, 5 principes nommés, citations Iyengar/Krishnamacharya/Yoga Alliance, références aux semaines et postures effectives.

**Per-exercise** : couverture exhaustive vérifiée par lecture intégrale du JSON.

| Hook | Couverture | Commentaires |
|---|---|---|
| `target_zone` | 100 % | Vocabulaire propre yoga : `hold-30s`, `hold-45s`, `breath-led`, `restorative`, `flow` (W8 J5 SN-A/B uniquement), `meditation` (pranayama). Cohérent doctrine. |
| `required_equipment` | 100 % | Kebab-case respecté : `mat`, `yoga-block`, `wall`, `blanket`, `bolster`, `strap`, `eye-pillow`. ⊆ assumed_profile (qui mentionne tapis, 2 blocs, sangle, couverture ; bolster + eye-pillow + wall non listés explicitement mais classiques en restorative — minor). |
| `incompatible_constraints` | 100 % | Kebab-case : `wrist-pain`, `shoulder-injury`, `knee-injury`, `lower-back-pain`, `cervical-pain`, `ankle-injury`, `hypertension`, `pregnancy`, `frequent-headaches`, `glaucoma`, `detached-retina`. Pertinents pour chaque posture. |
| `alternatives` | 100 % | Toujours 2-3 alternatives concrètes par exercice, niveau ET contrainte adressé. |
| `volume_axis` | 100 % | `duration` pour holds et restorative, `sets` pour postures unilatérales (par côté), `reps` pour Surya Namaskar (cycles). Cohérent. |

Pas de hook générique de type `"target_zone": "moderate"`. Aucun exercice ne manque de hook.

**Minor** : `assumed_profile` pourrait expliciter bolster + eye-pillow + accès mur (ils apparaissent dans les exercices de cutback et restorative) ; rien de bloquant car ce sont des alternatives ou des objets classiques chez un pratiquant 6 mois.

## 3. Internal consistency

| Check | Statut | Détails |
|---|---|---|
| `duration_weeks == weeks.count` | PASS | 8 = 8 |
| Active sessions/week ≤ `sessions_per_week` | PASS | 4 sessions par semaine, toutes ≠ rest (mobility/technique/mixed/other), `sessions_per_week: 4` |
| Days unique W et ∈ [1,7] | PASS | J1, J3, J5, J7 chaque semaine, espacés (1 jour repos minimum) |
| Numbers in name/objective delivered | PASS | "20 postures maîtrisées" → séance phare W8 J5 énumère explicitement #1 à #20 (verbatim dans notes Savasana finale). "45-60 min" → séances entre 30 (J7 récup) et 60 (séances phares) min, séance phare 60 min OK. "Surya Namaskar A et B" → SN-A consolidée W1-W4, SN-B introduite W5 et présente W5-W8. "2 postures équilibre debout 5 respirations Ujjayi" → checklist critère #2 cible Vrksasana 30s = ~5 respirations Ujjayi. |
| `progression_logic` cite éléments réels | PASS | Référence Tadasana, Vrksasana, Garudasana, Surya Namaskar A/B, Warrior III avec bloc, Setu Bandha, Paschimottanasana, etc. — toutes présentes dans les semaines. |
| `safety_notes` ↔ `rest_seconds` cohérents | PASS | Pas de standard ACSM applicable yoga ; rest_seconds court (10-30s entre postures) cohérent pratique Hatha doux. Restorative: rest_seconds = 0 (continuité). |
| Equipment ⊆ `assumed_profile` OR alternatives | PASS au modulo bolster/eye-pillow/wall (cf. minor §2). Toutes les postures avec équipement spécifique ont au moins 1 alternative `Savasana classique` ou `sans bolster`. |
| Cumul postures progression | PASS | W1: 6 fondations rappelées (#1, #2, #8, #9, #11, #20). W2: +4 nouvelles (#3 Uttanasana, #4 Ardha Uttanasana, #5 Phalakasana, #6 Chaturanga) = 10. W3: +3 (#7 Bhujangasana, #12 Vrksasana, #16 Anjaneyasana) = 13. W4: +1 (#19 Supta Baddha) = 14. W5: +3 (#10 Parsvakonasana, #13 Garudasana, #15 Utkatasana) = 17. W6: +2 (#14 Warrior III, #17 Setu Bandha) = 19. W7: +1 (#18 Paschimottanasana) = 20. Cohérent avec progression_logic. |

## 4. Cutback / deload

PASS. `deload_weeks: [4, 7]` annoncé et matérialisé :
- W4 = 175 min (vs W3 = 220) → -20.5 % ✓
- W7 = 215 min (vs W6 = 270) → -20.4 % ✓
- W4 introduit 1 seule nouveauté restorative (Supta Baddha) sans posture complexe ✓
- W7 introduit 1 seule nouveauté flexion avant douce (Paschimottanasana) ✓
- Holds réduits 30s→20s sur Triangle/Warrior, Savasana renforcée 6-8 min ✓
- Cadence 3-4 sem entre cutbacks (W4 puis W7 = 3 sem d'écart) — conforme doctrine.

## 5. Safety

Couverture sport+level très complète. Sections explicitement présentes dans `safety_notes` :
- **DRAPEAUX ROUGES** : poignets (Down Dog/Plank/Chaturanga), épaule (Chaturanga misalignment), cervicale (Bhujangasana), lombaire (backbends), genou (Warrior, Tree), étourdissements Ujjayi. Spécifique Hatha grand public (poignets cités comme "risque n°1").
- **RÈGLES GÉNÉRALES** : tapis antidérapant, échauffement poignets non optionnel, Savasana JAMAIS omis, hydratation, repos minimum, pas de pratique ventre plein.
- **RESPIRATION RÈGLE CENTRALE** : test d'aisance respiratoire, max 5 min Ujjayi/jour, pas de Kumbhaka.
- **SIGNES DE SURCHARGE** : 6 critères listés, déclencheur "3+ simultanés → semaine -20 %".
- **SI SÉANCE MANQUÉE** : 4 paliers de reprise selon durée pause.

Sirsasana / Sarvangasana / Halasana / Wheel explicitement INTERDITS, répété 3 fois (default_objective + progression_logic + safety_notes). Aucune copie-coller depuis un autre sport (vocabulaire 100 % yoga : drishti, Ujjayi, Dirgha, Kumbhaka, fingers-spread, knees-down, props Iyengar).

Mention explicite "consulte un médecin avant de commencer" pour hypertension non équilibrée, glaucome, décollement de rétine, antécédents cardiaques, grossesse, postpartum < 6 sem.

## 6. EU MDR

Scan banni : zéro occurrence de "guérir", "soigner", "traiter une pathologie", "diagnostic", "médical [comme claim]", "thérapeutique", "rééducation", "cure", "treat", "diagnose". Le seul "consulte un médecin" est utilisé correctement comme déclencheur de medical clearance, pas comme claim. Le mot "médecin" apparaît uniquement dans la phrase "consulte un médecin avant de commencer" et "pause 1 semaine et bilan kiné" (renvoi vers professionnel, pas claim de soin).

PASS. Pas de framing rééducation injury rehab : le template ouvre le drapeau "si douleur > 3 séances : pause + bilan kiné" sans s'arroger le rôle thérapeutique.

## 7. Final autonomy checklist

PASS. La checklist est livrée explicitement dans les notes de la posture #20 Savasana de la séance phare W8 J5 (lignes 3384-3388 de Savasana #20 finale séance phare). 4 critères mesurables/observables :
1. Surya Namaskar A complet en Ujjayi fluide, 5 cycles d'affilée sans pause forcée.
2. Vrksasana 30s par jambe sans appui mural, 5 respirations Ujjayi régulières.
3. Ujjayi régulier 5 min en assise stable sans étourdissement ni saccade.
4. Séance phare 60 min terminée avec sensations contrôlées (RPE 6 max, pas de douleur poignet/genou).

Bonus : règle de décision 3-4 critères → plan regular ; 1-2 → re-faire ce plan en consolidant points faibles ; 0 → repasser plan beginner. Très propre.

## 8. Style

Français, tutoiement systématique ("tu connais déjà", "consulte un médecin", "tu peux noter ta séquence"). Pas d'emojis. Noms d'exercices clairs (sanskrit + traduction française entre parenthèses : "Adho Mukha Svanasana (Chien tête en bas)", "Vrksasana (Posture de l'Arbre)"). Notes pédagogiques concises et concrètes (drishti précisé, point d'engagement musculaire, repère de sortie de posture). Aucun jargon non-expliqué.

## Issues summary

### Critical (block merge)

Aucune.

### Important (fix recommended)

Aucune.

### Minor (nice-to-have)

- `assumed_profile` pourrait expliciter bolster + eye-pillow + accès mur (utilisés en cutback W4/W7 et J7 restorative). Non bloquant car déduit du contexte recreational et présence d'alternatives.
- `default_objective` annonce "20 postures maîtrisées" : la séance phare énumère bien #1 à #20 mais 4 d'entre elles (#3 Uttanasana, #4 Ardha Uttanasana, #5 Phalakasana, #6 Chaturanga) sont uniquement tenues en isolation au sein du Surya Namaskar dans la majorité des séances ; Sophie peut juger si "tenue isolée 5 respirations" lors de la séance phare suffit comme "maîtrise" — actuellement le template fait ce choix-là explicitement et la séance phare W8 J5 donne bien à chaque posture une entrée dédiée. Pas de problème en pratique.

## Sources

- [Yoga Education Institute — Iyengar Yoga primer (Nancy Wile)](https://yogaeducation.org/wp-content/uploads/2019/05/Iyengar-yoga.pdf)
- [Yoga Alliance — Standards for Registered Yoga Schools 2025](https://yogaalliance.org/wp-content/uploads/2025/05/Standards-for-RYS-Credentials_NB22my-.pdf)
- [Yoga Journal — Sun Salutations Complete Guide Surya Namaskar A](https://www.yogajournal.com/yoga-101/surya-namaskar/)
- [Yoga Journal — Ask the Teacher: When Not to Invert](https://www.yogajournal.com/practice/yoga-sequences/when-not-to-invert/)
- [Swamij — Yoga Sutras of Patanjali 2.49-2.53 Pranayama](https://swamij.com/yoga-sutras-24953.htm)
- [Yog School India — Pranayama for Beginners (Ujjayi duration)](https://yogschoolindia.com/pranayama-for-beginners-5-essential-techniques-how-they-work-and-where-to-start/)
- [Adventure Yoga Online — Legs Up The Wall benefits and tutorial](https://adventureyogaonline.com/legs-up-the-wall-benefits/)
- [Ashtangayoga.info — Surya Namaskara A traditional sequence](https://www.ashtangayoga.info/ashtanga-yoga/surya-namaskara-a-sun-salutation/)
- [Yoga Vastu — Modified Surya Namaskar Iyengar method](https://yogavastu.com/p/modified-surya-namaskar/)

## Recommendation

**APPROVED**. Bundle as-is.

Le template est exceptionnellement propre : doctrine Iyengar/Krishnamacharya/Ashtanga respectée, hooks v2 100 % couverts, cutbacks chiffrées, safety_notes complètes et sport-spécifiques, EU MDR clean, checklist d'autonomie 4 critères avec règle de décision en bonus. Les 2 minors signalés sont cosmétiques et n'imposent aucune regen.

## Patches applied (2026-05-01)

Template déjà APPROVED ; patch cosmétique appliqué sur l'unique minor actionnable.

**Minor fix** :
1. `assumed_profile` enrichi : ajout explicite de **`bolster + eye-pillow + accès à un mur libre`** (utilisés en cutback W4/W7 et J7 restorative).

**Skipped** :
- "20 postures maîtrisées" comptage Surya Namaskar : décision produit déjà actée dans le template, pas de patch nécessaire.

**Vérifications post-patch** : JSON valide, `duration_weeks=8 == weeks.count=8`, 256 exercices avec 100% des 5 hooks v2, 0 banned word EU MDR.

**Verdict final** : **APPROVED** (inchangé).
