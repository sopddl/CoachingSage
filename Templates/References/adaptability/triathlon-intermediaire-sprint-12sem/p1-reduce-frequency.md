# Adaptability : triathlon-intermediaire-sprint-12sem + p1-reduce-frequency

## Rigidity score
**4/10**

Le template est **rigide** sur le parallélisme des 3 disciplines (progression_logic principes 1 et 4) et sur la règle 48h entre sollicitations identiques (safety_notes). Réduire à 2 séances/sem force à casser la structure "chaque semaine 2 natation + 2 vélo + 2 running" et crée des conflits directs avec les bricks progressives (W5-W10 obligatoires selon progression_logic).

## Patch approach

Passer de 6 à 2 séances/sem exige de **fusionner les disciplines** plutôt que de simplement réduire le volume. Stratégie : (1) garder UNE brick obligatoire/sem (W5+) comme colonne vertébrale du plan, (2) alterner natation vs renforcement sur la 2e séance, (3) abandonner les séances pures de chaque discipline au profit de sessions hybrides, (4) décaler le tapering (W11-W12 conservent les 2 séances pour fraîcheur). Les cutback W4 et W8 deviennent des semaines normales (pas assez d'espace pour réduire à 2 séances). Volume total -40% vs baseline pour respecter la progression 10-15%/sem avec moins de séances.

## Concrete modifications

**W1-W3 (Fondations)**
- **W1 J1** Natation technique : conservé (~45 min)
- **W1 J3** FUSION : Vélo (45 min) + Course (28 min) = sortie vélo + décathlon rapidement après (transitionner sans repos, simuler pré-brick). Total ~75 min. Mobilité J4 éliminée → transférer 10 min de mobilité en fin de chaque séance.
- **W2 J1** Natation technique : conservé (~50 min)
- **W2 J3** FUSION : Vélo endurance (60 min) + Course Z2 progressive (32 min, au lieu de 45). Total ~95 min.
- **W3 J1** Natation 100 m continu : conservé (~50 min)
- **W3 J3** FUSION : Vélo 80 min + Course 35 min = ~115 min. Renforcement J4 supprimé → intégrer 3-4 exercices clés (squat, single-leg DL, planche) en fin de J3 sur 15 min.

**W4 (Cutback — devient normal car 2 séances)**
- **W4 J1** Natation technique réduite : 40 min (vs 45 baseline)
- **W4 J3** FUSION : Vélo 45 min + Course 25 min (vs 35 min en W3 pour simuler cutback). Total ~70 min + 10 min mobilité. Volume total -15% vs W3 ✓

**W5-W8 (Bricks — CRITIQUE)**
- **W5 J1** Natation 200 m séries : conservé (~55 min, vs 55 baseline)
- **W5 J5** BRICK 1 : Vélo 25 min + Course 10 min = **35 min**. Remplace la séance vélo + renforcement + séance natation supplémentaire. C'est le point chaud : on perd une natation et tout le renforcement J4, mais on garde la brick développementale.
  - **Risque** : seule 1 séance natation/sem en W5-W8. Volume natation W5 chute à ~250 m (vs 550 m baseline). **CONTRADICTION** avec progression_logic qui dit "au minimum 2 séances natation/sem".

**W6 J1** Natation 400 m continu : conservé (~55 min)
- **W6 J5** BRICK 2 : Vélo 40 min + Course 15 min = **55 min**. Renforcement J4 + transitions T1/T2 à sec supprimés → **reporter T1 apprentissage à sec à J1 natation (5 min avant la séance, sans impacter natation) OU sacrifier T1 à sec et débuter T1 en bassin W7 J6 uniquement**.

**W7 J1** Natation simulation départ + T1 bassin = **60 min** (intègre la transition consolidation)
- **W7 J5** BRICK 3 : Vélo 20 km + Course 5 km simulation = **90 min** (conservé, c'est le pic brick)

**W8 J1** Natation technique réduite : 40 min
- **W8 J5** BRICK courte : Vélo 20 min + Course 10 min = **30 min**. Cutback brick respecté.

**W9-W10 (Spécificité — volume maximum, mais adapté 2 séances)**
- **W9 J1** Natation 600 m continu : conservé (~60 min)
- **W9 J5** BRICK 4 : Vélo 25 km + Course 5 km over-distance = **95 min**

**W10 J1** Natation 750 m test : conservé (~55 min)
- **W10 J5** BRICK 5 (simulation complète natation 400 m + T1 + Vélo 20 km + T2 + Course 5 km) = **120 min**. Sessions de running intervalles pures (W9 J2, W10 J2) **SUPPRIMÉES**. Risque VO2max running non travaillé = **perte de 5-10% capacité 5K finale**.

**W11 J1** Natation activation : 35 min (idem baseline)
- **W11 J5** BRICK courte tapering : Vélo 15 min + Course 10 min = **25 min**

**W12 J1** Natation activation : 25 min
- **W12 J5** Jour J : triathlon complet = **120 min**

## Rigidity issues

1. **Perte de discipline natation (seule 1 séance/sem W5-W8)** : progression_logic énonce "au minimum 2 séances natation/sem". Adapter en 2 séances/sem casse cet invariant. Volume natation W5 chute à ~250 m vs 550 m baseline — **risque au cap 750 m de W10** (trop tard pour corriger).

2. **Renforcement préventif éliminé W1-W10** : Les exercices structurels (bird-dog, clamshell, nordic curl) listés en progression_logic sont tous supprimés. Prévention ITBS et swimmer's shoulder **dépend** de ces séances (cités dans safety_notes comme critiques). Sans renforcement, le risque de blessure en W9-W10 augmente.

3. **Transitions T1 et T2** : progression_logic dit "T1 introduite à sec W6 J4 → bassin W7 J6 → consolidée W10 J4 et J5". Adapter réduit le temps d'apprentissage à sec et d'automatisation. Si T1 est réduite à 5 min avant J1 natation, c'est loin d'être suffisant (progression_logic prévoit au moins 5×5 passages à sec en W6 J4).

4. **Intervalles running VO2max** : W9 J2 (30 min seuil) et W10 J2 (4×1000 m) **supprimés**. Le run final en W12 dépend de cette capacité aérobie. Risque : chute de 1-2 min/km sur les 5 km finaux.

5. **Cutback W4 et W8 deviennent identiques à W3 et W7** : pas assez de marge pour réduire à 2 séances/sem. Volume W4 et W8 ne sera que -10% vs semaine précédente (au lieu de -15% requis).

## Contradictions

- **safety_notes : "Minimum 48h entre deux sollicitations identiques"** vs fusion J3 (vélo+course sans repos) : techniquement pas une violation (c'est 1 séance hybride, pas 2 séances), MAIS l'intention est de reposer les jambes 48h entre efforts identiques. Vélo (W3 J3) suivi course dans la même séance viole l'esprit de la règle.

- **progression_logic principes 1 et 4** : "Parallélisme des 3 disciplines chaque semaine, 2 natation + 2 vélo + 2 running minimum" vs plan à 2 séances/sem (1 natation/sem W5-W8, 1 brick/sem). Structure casse l'invariant multi-discipline.

- **Brick session W5-W10** : progression_logic énonce W5 (25+10), W6 (40+15), W7 (20 km+5 km), W8 cutback (20+10), W9 (25 km+5 km), W10 (simulation 400 m+20 km+5 km). Adapter à 2 séances/sem force à réduire natation à 1 séance/sem pendant ces 6 semaines = **natation total W5-W10 ≈1,800 m vs 4,000 m baseline** = progression natation écrasée.

- **safety_notes : "Signes surcharge (FC repos +10 bpm, sommeil perturbé, courbatures >72h, perte appétit)"** : passer de 6 à 2 séances/sem → charge réduite, mais les 2 séances restantes sont longues (75-120 min). Risque de fatigue excessive si adaptation graduelle insuffisante. Notamment, W9 J5 (95 min brick) + W10 J5 (120 min simulation) consécutifs sans jour repos ni autre séance de récupération entre = fatigue cumulative.

---

# Synthèse adaptation

**Faisabilité : 7/10 (techniquement faisable, mais compromis importants)**

| Aspect | Baseline | Adapté | Impact |
|--------|----------|--------|--------|
| Natation (W1-W4) | 2 séances/sem | 1 séance/sem | Volume OK, technique maintenue |
| Natation (W5-W8) | 2 séances/sem | 1 séance/sem | **CRITIQUE : -60% volume** |
| Brick (W5-W10) | Progressives 7× | Progressives 6× | Conservé (1 brick/sem obligatoire) |
| Renforcement | 1 séance/sem (J4) | 0 séance pure | Intégré en fin J3 (10 min seulement) → risque prévention insuffisante |
| Intervalles running | Chaque sem (W2-W10) | Supprimés W9-W10 | VO2max running non entraîné → perte 5-10% capacité 5K |
| Transitions | 5 répétitions à sec (W6) | 1 répétition à sec (réduit) | T1/T2 moins automatisées |
| Volume total | 330+ min/sem (baseline) | ~180 min/sem (adapt) | -45% |

**Recommandation pour l'utilisateur** :
- **Acceptable si priorité = finir la course (< 1h30 pas requis)**, natation 750 m sans panique, transitions maîtrisées basiquement.
- **Pas acceptable si objectif = performance** (finir < 1h30, 5K < 25 min, transitions < 2 min).
- **Alternative** : accepter 3-4 séances/sem au lieu de 2, quitte à fusionner natation+vélo une semaine sur deux seulement.