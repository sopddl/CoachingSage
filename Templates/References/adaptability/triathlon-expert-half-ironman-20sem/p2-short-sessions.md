# Adaptability : triathlon-expert-half-ironman-20sem + p2-short-sessions

## Rigidity score
**2/10**

Le template est **extrêmement rigide** sur cette contrainte. Il est construit sur des principes architecturaux (parallélisme des 3 disciplines, cutback weeks, pic de volume W11, affûtage progressif) qui sont **incompatibles** avec des séances de 30 min max.

## Patch approach

Aucun patch local ne rend ce plan viable. Le template repose sur une progression de volumes qui **nécessite** des séances longues : W6 nage 1900 m continu (75 min), W10 run 105 min, W11 brick 180+ min. Réduire ces séances à 30 min **casse l'invariant fondamental** du plan (progression 10-15%/sem, cutback weeks, affûtage). Il faudrait **reconstruire un plan de 20 semaines de zéro** pour triathlètes à temps limité (≤ 5 h/sem max vs 10-15 h/sem attendu).

## Concrete modifications

**Impossible à exécuter par patch local.**

Tentative de compression illustrative (démontre la rigidité) :
- **W1 J2** (90 min vélo Z2) → 25 min Z2 + 5 min Z3 : perte de 80% du travail aérobien fondamental. W2 progression 10% devient invalide (on régresse).
- **W6 J1** (75 min nage 1900 m continu) → 30 min = 800 m : distance race non testée en continu. W9 J1 (2100 m) devient inatteignable (progression brisée).
- **W10 J3** (120 min run 105 min) → 30 min = ~5 km Z2 : impossibilité de tester le run long post-vélo (brick). La préparation mentale/métabolique pour 21 km post-90 km vélo disparaît.
- **W11 J6** (240 min brick pic) → 30 min = scénario irréaliste. Ne peut pas simuler 4h30 de course.

## Rigidity issues

- **Principe (1) PARALLÉLISME DES DISCIPLINES** : exige 7 séances/sem chacune d'une durée significative pour progresser 10-15%/sem en parallèle. Avec 30 min/séance max, le volume total devient ~3,5 h/sem (incompressible), **insuffisant** pour atteindre le pic de 14-15 h/sem en W11. Impasse mathématique.

- **Principe (2) PROGRESSION 10-15%/SEMAINE** : mesurée en volume absolu (km nage, km vélo, km course). Compression à 30 min/séance → réduction du volume hebdomadaire total à ~3,5-4 h/sem (vs 10 h cible W1). Pour garder 10% progression/sem sur un socle de 3,5 h, faut atteindre 14-15 h/sem **en résumé de volume**, impossible à distribuer en séances de 30 min.

- **Principe (3) CUTBACK WEEKS** : W4, W8, W12, W16 réduisent le volume de 15-20%. Avec séances de 30 min, la réduction devient négligeable (de 4 h à 3,5 h/sem). Pas d'effet de **supercompensation** observable. L'invariant cutback = réduction volume significative **disparaît**.

- **Principe (5) AFFÛTAGE W17-W19** : conçu sur une réduction **progressive et mesurable** (25% → 40% → 60% vs pic W11). Si W11 = 4 h (compressé 30 min/séance), affûtage W17 = 3 h. Imperceptible pour l'athlète. La **recherche (Bosquet et al., 2007)** citée s'applique à des réductions de 40-60% sur 10-15 h → 6-9 h. Ici : 3,5 h → 2,5 h/sem. Structure mathématique différente, résultats incertains.

- **Séances longues incompressibles** :
  - W6 J1 : 1900 m continu nage = **75 min minimum** (même à allure rapide 1 min/100 m). Pas de forme courte viable sans fragmenter l'effort en séries avec repos (casse la spécificité "continu").
  - W10 J3 : 105 min run = **minumum 15-20 km selon allure**. 30 min = 4-5 km max. Écart infranchissable.
  - W11 J6 : 240 min brick (simulation race 180 min vélo + 55 min run). **Incompressible** : le scénario pédagogique disparaît entièrement.

- **Spécificité du triathlon** : le sport exige des séances longues pour habituer le corps à l'effort > 4h. Protocole de 30 min/séance entraîne un **déconditionnement endurance**. Risk : abandons ou DNF en course.

## Contradictions

- **safety_notes (règle générale) vs contrainte** :
  - "Doubles séances AM/PM : minimum 4 heures entre 2 séances. Nutrition post-première séance dans les 30 min."
  - Adaptation implique 7 séances × 30 min = 210 min/sem. Pour tenir 10 h/sem attendu, faudrait **14-20 séances/sem** (doubles quotidiennes). **Contradiction directe** : 4 h repos entre doubles incompatible avec logistique de 14-20 séances/sem.

- **progression_logic (règle 10-15%/sem) vs contrainte** :
  - W1 volume total : ~10 h réels → comprimé 30 min/séance = 3,5 h/sem.
  - W2 cible : 10 h × 1,10 = 11 h. Comprimé : 3,85 h/sem (réalisable en 7 × 33 min, impossible < 30 min).
  - La progression **10-15% linéaire ne peut pas être respectée**. Ou le template accepte une progression différente (20-30%/sem impossible à justifier par ACSM), ou échoue.

- **Invariant "pas de Z5 durant brick long"** (safety_notes Z3 max en brick) :
  - W13 J6 brick 180 min ne peut pas être reproduit en 30 min. La **règle de sécurité disparaît** car la séance n'existe plus.

- **Bilan W20** (checklist d'autonomie) :
  - "Je nage 1900 m continu à allure Z3 (oui/non)." → Avec ce plan, impossible d'avoir validé cette compétence (jamais testé en continu, seulement en séries < 500 m).
  - "Je cours 21 km post-vélo en gestion d'allure." → Jamais testé un run > 10 km après un vélo long (W11 réduit à 30 min). **Checklist invalide**.

---

## Recommandation

**Ce template ne peut pas être adapté pour p2-short-sessions par patch local.**

**Alternative** : reconstruire un plan de 12-16 semaines à 5-6 h/sem max, basé sur :
- **3 séances/sem seulement** (nage 30 min, vélo 30 min, course 30 min) sans brick.
- **Objectif révisé** : Olympic Distance (1,5 km nage + 40 km vélo + 10 km course) au lieu de Half Ironman.
- **Progression sur cadence/intensité** au lieu de volume absolu (impossible à augmenter).
- **Acceptation du compromis** : aucun test long continu, aucun brick, aucun pic de volume = préparation moins optimale, risque DNF accru sur 70.3.

Si l'athlète **doit absolument** faire un 70.3 avec ≤ 5 h/sem, la réalité est : **ce plan ne s'adapte pas. Lui recommander un coach triathlon pour construire un plan réaliste** (meilleur taux de réussite que d'appliquer 20 semaines compressées à 30 min/séance).