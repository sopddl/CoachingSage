# Adaptability : triathlon-intermediaire-sprint-12sem + p5-low-energy-week

## Rigidity score
**7/10**

Le template se laisse adapter à une semaine de fatigue, mais certains éléments structurels résistent : les cutback W4 et W8 sont déjà prévus, ce qui limite la flexibilité pour les semaines intermédiaires ; la progression_logic impose un parallélisme strict des 3 disciplines chaque semaine ; les brick sessions à partir de W5 sont non-négociables pour l'apprentissage moteur. Cependant, la réduction d'intensité sans casser le volume global est techniquement réalisable sur les semaines non-cutback.

## Patch approach

Identifier la semaine de fatigue (ex : W6, W7, W9 ou W10). Réduire les zones d'effort cible (Z4/Z5 → Z2/Z3), maintenir le volume brut mais en intensité basse, préserver les brick sessions court format pour conserver la neuromotricité transition. Reporter les intervalles VO2max intensifs à la semaine suivante via une montée progressive étalée sur 2 semaines (au lieu de 1).

## Concrete modifications

**Exemple applicatif : semaine fatigue = W6**

- **W6 J1 (natation)** : conserver 400 m continus (vs 550 m prévus), simplifier en 4×100 m Z2 au lieu de séries de 150 m. Supprimer la mention "400 m test" — juste nager facile.
- **W6 J2 (running)** : réduire de 5×8 min seuil à 3×6 min seuil (12 min de travail vs 24 min). Zone Z3 tempo (7/10) au lieu de seuil (7.5/10). Allonger les récupérations de 4 min à 6 min.
- **W6 J3 (vélo)** : supprimer les 3×8 min Z3 tempo. Garder 50 min Z2 pur (65-75% FCmax, cadence 85 rpm). Distance réduite ~18 km au lieu de 25-30 km.
- **W6 J4 (mobilité)** : conserver les transitions T1/T2 à sec (apprentissage moteur, pas coûteux énergétiquement). Réduire le renforcement : only 2 sets per exercise au lieu de 3.
- **W6 J5 (brick)** : **BRICK RÉDUITE OBLIGATOIRE** : vélo 20 min Z2 (au lieu de 40 min Z3) + course 8 min Z2 facile (au lieu de 15 min mixte). Total énergie ~50% de la brick prévue. Les gestes de transition restent identiques pour consolidation neuromotrice.
- **W6 J6 (natation)** : réduire 600 m → 400 m, format 4×100 m Z2 régulier.

## Rigidity issues

- **Brick obligatoire dès W5** : la progression_logic stipule "Brick obligatoire dès W5 comme préconisé British Triathlon Level 2". Une suppression totale de la brick casse l'invariant du plan. Adapter plutôt que supprimer : brick réduite acceptable (pédagogie transition maintenue, volume low).
- **Cutback W4 et W8 déjà prévu** : si la semaine de fatigue tombe sur W4 ou W8, le template est déjà allégé. Une réduction supplémentaire bascule sous le seuil minimum de consolidation (risque de déconditionnement multi-sport).
- **Parallélisme 3 disciplines chaque semaine** : progression_logic impose "au minimum 2 séances natation, 2 séances vélo, 2 séances running". Adapter l'intensité oui, supprimer une discipline non (brisure du parallélisme = rupture pédagogique).

## Contradictions

- **Safety notes vs intensité réduite** : Les safety_notes alertent sur les "SIGNES DE SURCHARGE (3+ signes → semaine cutback ou consulter)". Si l'utilisateur rapporte fatigue+sommeil dégradé+stress, il a déjà 2+ signes. Une réduction d'intensité dès la semaine en cours est ALIGNÉE avec les recommandations safety, pas en contradiction. ✓
- **Volume cutback vs progression_logic** : La progression_logic exige "RÈGLE 10-15% DE PROGRESSION". Si W6 normal = 225 min total, réduire à 140 min (semaine fatigue) = -38% vs W6. Puis W7 revient à 250 min = +78% vs W6 réduit. Cela casse la règle 10-15%. **Solution** : recaler W7 à 180-190 min (progression modérée +28-35% depuis W6 réduit) et laisser la vraie progression se faire W7→W8 en reversant le surplus. Étale la progression sur 2 semaines au lieu de 1.
- **Intervalles VO2max W7 J2** : Le plan W7 prévoit "3×800 m allure 5K, RPE 8.5". Si W6 J2 est adapté à 3×6 min tempo (zone Z3, RPE 7), alors W7 J2 à intensité complète risk une montée trop abrupte (+2 points RPE en 6 jours). **Adapter W7** : augmenter progressivement : W6 réduit = 3×6 min Z3, W7 = 4×6 min Z3, W8 cutback normal, W9 = 3×800 m VO2max. Lisse la courbe d'intensité.
- **Natation coups de bras tracking (progression_logic)** : La progression suppose "compter les coups de bras par 25 m, objectif < 20 coups/25 m à allure Z2 d'ici W4". Une réduction d'intensité en W6-W9 n'impacte pas la technique, mais ralentit l'évaluation du progès technique (les 300 m Z2 de W6 J5 ne suffisent pas pour tester la technique complète). Acceptable si l'utilisateur a déjà validé le seuil 18-20 coups/25 m en W4.

---

## Détails d'exécution pour W6 fatigue (exemple complet)

| Jour | Session prévue | Modification W6 fatigue | Logique |
|------|----------------|--------------------------|---------|
| J1 | Natation 55 min : 400 m + 3×100 m | 400 m en 4×100 m Z2 (45 min total) | Même distance nage, intensité Z2 pur, repos complet |
| J2 | Running 50 min : 5×8 min seuil | 3×6 min Z3 tempo (35 min total) | ↓50% volume seuil, ↓1 RPE (7 vs 7.5), récup +2 min |
| J3 | Vélo 75 min : 20 min Z2 + 3×8 min Z3 | 50 min Z2 pur, cadence 85 rpm (60 min total) | Supprimer Z3 tempo, Z2 endurance de base |
| J4 | Transitions + renforcement 40 min | Transitions T1/T2 × 5 (15 min) + 2 sets force légère (20 min) | Transitions conservées, renforcement allégé |
| J5 | **BRICK 40+15** | **Vélo 20 min Z2 + run 8 min Z2** (35 min total) | Réduire brick ~50%, maintenir transitions |
| J6 | Natation 55 min : 4×150 m | 4×100 m Z2 (45 min total) | ↓volume, même format série |

**Total W6 fatigue : ~235 min (vs 330 min normal) = -29%.**

**W7 progression (anticipée) :**
- J1 natation : 4×150 m Z2 + 2×50 m allure course = rampe vers W7 normal
- J2 running : 4×6 min Z3 (vs 3×800 m VO2max) = intermédiaire avant full VO2max
- J3 vélo : 50 min Z2 + 2×5 min Z3 = introduction progressive de Z3
- J5 brick : 30 min vélo Z2-Z3 + 12 min run Z2 = augmentation progressive
- **Total W7 tampon : ~280 min**, rampe vers le pic W9 (290 min)

## Rattrapage post-fatigue

Si l'utilisateur rapporte à W7+2 qu'il a bien récupéré et veut rattraper le volume manquant :
- **NE PAS rajouter 95 min de travail en W7** (risque surcharge immédiate).
- **Étaler sur W7, W8, W9** : chaque semaine +10-15 min vs plan adapté = progression naturelle vers le pic W9.
- **Exemple** : W7 tampon (280 min) → W8 cutback normal (200 min, légal) → W9 pic (300 min, vs 290 normal) = rattrapage + progression conforme.

---

**Conclusion d'adaptabilité**

Le template s'adapte **élégamment** à une semaine de fatigue si on réduit l'intensité (Z4/Z5 → Z2/Z3) et le volume sans casser les invariants pédagogiques (brick, transitions, parallélisme 3 disciplines). Les points rigides sont l'introduction des brick en W5 (adaptable mais pas supprimable) et les cutback W4/W8 (déjà prévus). La réduction d'une semaine exige de **lisser la progression sur 2 semaines** pour rester conforme à la règle 10-15% et aux safety_notes. Aucune contradiction majeure si l'utilisateur accepte un plateau semaine N+1 avant reprise progressive N+2.