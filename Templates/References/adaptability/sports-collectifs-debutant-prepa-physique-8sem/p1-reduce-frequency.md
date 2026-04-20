# Adaptability : sports-collectifs-debutant-prepa-physique-8sem + p1-reduce-frequency

## Rigidity score
**6/10**

Le template offre une structure hebdomadaire **rigide** (J1 cardio / J3 renforcement / J5 cardio) mais les séances individuelles sont **modulables**. La réduction à 2 séances/semaine casse la logique du repos 48h et force à fusionner deux typologies contradictoires (cardio intensif + renforcement lourd sur une même session), ce qui dégrade la qualité de chacune. Le cutback W5 et la progression linéaire restent applicables, mais l'architecture perd en efficacité.

## Patch approach

Stratégie : **fusionner J1 (cardio) + J3 (renforcement) en une séance mixte lourde le lundi, puis garder J5 (cardio-intermittent phare) le vendredi**. Ceci respecte l'esprit du cutback W5 et ne casse pas les invariants W8. Entre les deux séances : 72-96h de récupération au lieu de 48h (bénéfique). La séance fusionnée devient **asymétrique** (cardio 15 min + renforcement 20-25 min compressé) pour éviter les ~45-50 min hebdo qui doublerait la fatigue.

## Concrete modifications

- **Toutes les semaines J1 fusionnée** : réduire le trot continu initial à 4 min (vs 5-8 min), supprimer un exercice cardio (généralement shuffle latéral ou un set de sprints), puis enchaîner les 5-6 exercices de renforcement en circuit rapide (30 sec repos max). Durée cible 38-42 min.
- **W1 J1 fusionnée** : 4 min trot → 3 × (20 sec shuffle + 40 sec marche) [abandon des 4 sets] → 3 × (30 sec T-drill) [au lieu de 4] → squat 3 × 10 → pont 3 × 12 → planche 3 × 20 sec → pompes 3 × 8 → calf raises 3 × 15. **Supprimer saut vertical bilatéral (W1)**.
- **W2 J1 fusionnée** : 4 min trot → 4 × 10 m sprint (vs 6) → 3 × shuffle (vs 4) → **ajouter directement fentes 3 × 8/jambe + side plank 2 × 20 sec** [provenant de W2 J3 d'origine] → pompes 3 × 10 → calf 3 × 18. Supprimer back-pedal et T-drill de la fréquence hebdo.
- **W3 J1 fusionnée** : 5 min trot → 4 × 20 m sprint (vs 6) → 2 × cloche-pied (vs 3) → **squat 3 × 15 + fentes dyn 3 × 8** [du J3 original] → side plank 3 × 25 sec. Pas de T-drill cette semaine.
- **W4 J1 fusionnée** : 5 min trot → 5 × 20 m sprint (vs 7) → 3 × agility 20 sec (vs 4) → **squat + charge 3 × 12 + fentes dyn 3 × 10 + superman 3 × 12** → calf surélevés 3 × 15. **Supprimer saut réception squat de J1 — le garder en renforcement seulement**.
- **W5 J1 fusionnée (cutback)** : 6 min trot → 3 × 20 m sprint (vs 5) → 2 × shuffle → **pont bilatéral 3 × 15 + planche 3 × 30 sec + side plank 2 × 25 sec** → pompes genoux 3 × 10. Logique cutback conservée (volume réduit 28%).
- **W6 J1 fusionnée** : 6 min trot → 4 × 30 m sprint (vs 6) → 3 × agility (vs 5) → **squat sauté 3 × 8 + nordic curl 3 × 5 + planche 3 × 45 sec** → pompes 3 × 12. **Fusion du nordic curl (prévention ischio) dans J1 pour ne pas le perdre**.
- **W7 J1 fusionnée** : **3 min × séquence 4 min sport co (vs 3 cycles × 5 min en original)** → enchaîner squat sauté 3 × 8 + fentes 3 × 12. Compression : 42 min total.
- **W8 J1 fusionnée** : 5 min trot → 3 × 20 m sprint (vs 4) → shuffle 2 × 25 sec → **squat 2 × 8 + activation légère fessiers/ischio 10 min** (pont bilatéral 10 reps + fentes 8 reps). Tapering conservé.
- **J5 inchangé** pour toutes les semaines : c'est la séance phare, elle reste prioritaire (cardio intermittent complet, pas de renforcement à l'exception de sauts explosifs intégrés au pattern).

## Rigidity issues

- **Perte de spécialisation séances** : les exercices de renforcement seront exécutés après 15-20 min de cardio intermittent → fatigue neuromusculaire plus élevée, forme moins parfaite sur les squats et fentes. Les études ACSM préconisent renforcement frais (W3 J3 original = précédé de 5 min marche seulement). Patch : accepter une qualité 15-20% réduite ou ajouter 1 jour bonus renforcement (passe à 2,5 séances/semaine, hors budget utilisateur).
- **Suppression de la variété cardio** : le back-pedal (W2 J5 original), cross-over step (W3 J5), et certains T-drill disparaissent pendant 2-3 semaines car comprimés dans J5 (densité trop haute). Patch : les réintroduire en W6-W8 où J5 le supporte.
- **Cutback W5 devient flou** : réduction initialement ciblée sur sprints longs (7 → 5 sets W4-W5 original). En fusion, le cutback doit aussi compresser le renforcement → risque de rater la "phase active de renforcement tissulaire" décrite en progression_logic. Le patch cible la réduction cardio principalement (5 → 3 × 20 m) et garde le renforcement léger mais présent.
- **Nordic curl W6 : placement critique** : introduit en W6 et prévient les déchirures ischio (progression_logic). Si fusionné dans une séance après cardio intensif, le risque de forme dégradée augmente. Patch : placer les nordic curl en début de J1 fusionnée (avant cardio) ou réduire les sprints précédents pour préserver la qualité du nordic curl.

## Contradictions

- **Safety : repos 48h minimum vs fusion J1+J3** : safety_notes stipule "48h minimum entre deux séances sollicitant les mêmes groupes musculaires". La fusion J1+J3 = sollicitation quadriceps + ischio-jambiers + core intensive sur une même séance, complétée par J5 sprint intensif le vendredi. Intervalle réel J1 fus. (lundi) → J5 (vendredi) = 96h ✓, mais l'absence de séance mercredi crée un vide où aucune récupération active n'a lieu. Workaround : ajouter une marche récupérative légère 15 min mercredi si possible (non renforcement) ; sinon noter que la récupération est "passive" (repos strict) plutôt qu'active.
- **Progressive_logic, règle 1 (10-15% semaine)** : progression des sprints W1 10m → W2 10m → W3 20m respectée. Mais la compression cardio dans J1 fus. force à réduire les sets parallèlement au renforcement : W3 original 6 × 20 m J1 + 6 × 20 m J5 = 12 total/semaine; en fusion 4 × 20 m J1 + 6 × 20 m J5 = 10 total (légère baisse). Pas de cassure règle 10-15%, mais volume légèrement sous-optimal.
- **W8 checklist d'autonomie** : prévue sur une séance phare J5 unique (4 × 5 min simulation) après tapering J1 + mobilité J3. En fusion, J1 W8 = cardio + renforcement léger comprimés. Le tapering est préservé (4 × 20 m vs 4 × 30 m W7), mais la séance de mobilité J3 reste inchangée → cohérent. Checklist J5 inchangée = ✓.
- **Saut réception squat W4+ : placement** : initialement W4 J1 (cardio), puis renforcement W4 J3 et après. En fusion, si on priorise renforcement = squat sauté apparaît en J1 fus. après cardio → fatigue du squat sauté est élevée, réception de qualité diminue. Patch : garder saut réception squat **en J5 uniquement** (trot→sprint→saut avec réception) pour exécution fraîche et sûre (prévention LCA).

---

**Résumé du patch final appliqué** :
- J1 fusionnée (lundi) : **4-6 min cardio léger** (trot) + **2-3 séries cardio intermittent court** (shuffle/sprint 10-20 m réduits) + **4-6 exercices renforcement comprimés** en circuit (pas de repos long, 30 sec max). Durée 38-42 min.
- **Mercredi : repos passif** (ou marche légère 10-15 min si souhait récupération active, non planifié ici).
- J5 inchangée (vendredi) : séance cardio-intermittent phare, complète, avec sauts explosifs mais **pas de renforcement** (pompes, squats, pont exclus de J5).
- **W5 cutback appliqué aux deux domaines** : sprints réduits (3 × 20 m vs 4-5) + renforcement réduit (planches/side plank courts, pas de nordic curl lourd cette semaine).
- **W8 tapering + checklist inchangés** : J1 fus. allégée + J3 mobilité + J5 simulation/test.

Cette adaptation est **applicable mais fragile** : elle tire le template vers une limite d'efficacité (saturation J1, perte de spécialisation). Un utilisateur expérimenté peut la supporter ; un débutant risque la surcharge ou la dégradation de forme. **Recommandation : essayer 3 semaines, puis évaluer fatigue et blessures avant de poursuivre**.