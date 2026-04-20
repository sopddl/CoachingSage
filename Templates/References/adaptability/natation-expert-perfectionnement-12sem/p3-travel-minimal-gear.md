# Adaptability: natation-expert-perfectionnement-12sem + p3-travel-minimal-gear

## Rigidity score
**2/10**

Le template est extrêmement rigide face à une contrainte de "voyage sans accès à la piscine". Il est construit sur une prémisse non-négociable : accès systématique à une piscine avec couloirs libres et équipement natation (pull-buoy, planche, palmes, paddles, élastique d'ancrage). Sans piscine, aucune séance n'est exécutable.

## Patch approach

Impossible d'adapter ce template à une semaine de voyage sans piscine. La totalité des 4 séances hebdomadaires sont des séances de natation en bassin. La contrainte "équipement minimal" (bande élastique, corde à sauter, baskets) est insuffisante pour simuler une nage ou maintenir la filière aérobie / VO2max / seuil spécifique natation sur terre. Le stimulus métabolique, la technique de nage et la progressivité du plan ne peuvent pas être transposés.

## Concrete modifications

Aucune modification possible au niveau des séances existantes. Les trois options réalistes sont :

1. **Reprogrammer la semaine de voyage à l'extérieur du plan** : si possible, interrompre le cycle et reprendre en W+1 post-voyage.
2. **Bifurquer vers un cycle de maintenance hors-eau** : remplacer la semaine par 4 séances de cross-training (cardio + renforcement) qui maintiennent la capacité aérobie sans nager, puis reprendre le plan à la semaine suivante à volume réduit (-20%).
3. **Chercher une piscine publique sur site de voyage** : même bassin 25 m non-idéal permet de réaliser une version allégée des séances (pas de couloir dédié, pas d'équipement, nage en partage = volume réduit de 40-50%).

Aucune de ces trois options ne constitue un "patch" du template — ce sont des contournements.

## Rigidity issues

- **Absence de séances hors-eau alternatives** : le template n'inclut aucune séance de cross-training natation ou équivalent métabolique (ex : aviron, ergomètre natation simulé, vélo seuil). Un nageur expert en voyage peut maintenir l'adaptation cardiovasculaire via du cardio de substitution, mais cela n'est pas documenté.
- **Matériel obligatoire listée en `assumed_profile`** : "Matériel disponible : pull-buoy, planche, palmes courtes, paddles" → pas de clause de flexibilité ou d'alternatives. La bande élastique (équipement disponible) ne figure nulle part.
- **Progressivité bassin-dépendante** : chaque semaine s'appuie sur les temps de référence chronométrés en piscine (W2 J2 baseline 100 m, W6 J3 TT 1500 m, W10 comparaisons W2↔W10). Un jour sans piscine = rupture de la chaîne de mesure.
- **Structure cutback prévue W4 et W8** : une semaine de voyage en W4 ou W8 (semaine allégée prévue) serait moins destructive qu'en W3, W5, W6 ou W7. Mais le template ne documente pas cette stratégie.

## Contradictions

- **safety_notes, règle repos 48h** : "Minimum 48h entre deux séances d'intensité élevée sur les mêmes filières." → Si la semaine de voyage survient en W3 (seuil + VO2max) ou W10 (VO2max + simulation 100-200 m), l'absence de nage empêche le repos actif conseillé (Z1-Z2 au bassin). Passer à du cardio hors-eau (vélo, course) change la filière et casse la cohérence du repos inter-séance documenté.
- **progression_logic, calibrage allure post-TT W6** : "POST-W6, recalibrer : allure seuil W7-W8 = (temps TT 1500 m en sec / 15) + 3-5 sec/100 m." → Si W6 se déroule entièrement en piscine mais que W7 ou W8 survient en voyage sans bassin, les allures seuil recalibrées ne peuvent pas être testées. La validité du calibrage est compromise.
- **Comparaisons inter-semaines** : "50 m sprints : W1 J6 (réf) → W2 J6 → W3 J6 → W8 J6 → W10 J6 → W12 bilan." → Si W8 J6 (sprint 50 m bilan) est manquée (voyage), le benchmark W8↔W10 disparaît, rendant W10 J1 (VO2max 300 m) non-interprétable ("objectif ≥ même allure W9, idéalement -2 à -3 sec/300 m par rapport à W9 grâce à la fraîcheur post-cutback W8").

---

**Conclusion** : Le template **natation-expert-perfectionnement-12sem** n'est **pas adaptable** à une absence de piscine. La rigidité est structurelle : c'est un plan de natation pour nageur en accès bassin régulier. Une semaine de voyage sans piscine doit être soit évitée en planification pré-plan, soit acceptée comme une semaine "perdue" du cycle (reprendre en W+1 post-voyage à volume réduit -20%).