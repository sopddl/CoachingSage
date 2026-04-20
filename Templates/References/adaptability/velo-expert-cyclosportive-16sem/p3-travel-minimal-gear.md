# Adaptability : velo-expert-cyclosportive-16sem + p3-travel-minimal-gear

## Rigidity score
**2/10**

## Patch approach
Ce template est **extrêmement rigide** pour une contrainte de voyage sans vélo. Le sport fondamental est le cyclisme sur route (capteur de puissance, braquets, cadence, cols, distance kilométrique). Sans accès au vélo, les séances ne peuvent **pas** être substituées par du cross-training efficace — aucune modalité (course à pied, musculation légère, corde à sauter) ne reproduit les adaptations aérobies spécifiques Z2-Z4 en puissance développées depuis 9 semaines. La contrainte crée une **rupture physiologique irréversible** du plan dans la majorité des cas.

## Concrete modifications
- **W10 J1** (Simulation montée longue allure race, 120 min, Z4) : **IMPOSSIBLE** à adapter. Proposition de remplacement : repos complet + étirements (perte de stimulus inévitable). Alternativement, si accès à un terrain vallonné : sortie à pied 90 min Z3-Z4 perçu (6-7/10 RPE) avec accélérations en montée (3 x 2 min efforts soutenant, repos 3 min marche lente). Inadéquat mais mieux que repos total.
- **W10 J2** (Récupération Z1, 60 min) : **REMPLAÇABLE** → Marche lente 50 min ou repos complet (pas d'équipement requis).
- **W10 J3** (Séquence de cols simulée, 130 min, Z4) : **IMPOSSIBLE**. Proposition : si accès à escaliers publics ou étage d'hôtel : répétitions d'escaliers (3 x 5 min montée rapide RPE 8/10, repos 5 min à pied). Stimulus neuromusculaire très faible par rapport au protocole original. Volume perdu : ~60 min d'intensité Z4.
- **W10 J5** (Endurance Z2 + cols basse cadence, 150 min) : **IMPOSSIBLE** (dépend vélo + terrain montagneux). Proposition : marche rapide 120 min sur terrain vallonné si disponible (Z2-Z3 perçu RPE 5-6/10), ou corso à pied en terrain plat (très affaibli, seulement 50% de la charge aérobie cible).
- **W10 J7** (Sortie longue simulation de course partielle, 300 min, 160-180 km) : **IMPOSSIBLE**. Proposition : course à pied longue 120 min RPE 6-7/10 en Z3-Z4 perçu. Distance équivalente : ~20-24 km selon vitesse. Stimulus cardiorespiratoire maintenu partiellement, mais force musculaire spécifique col (**cadence basse, traction sur manivelle**) perdue.

## Rigidity issues
- **Dépendance absolue au vélo** : 95% des séances reposent sur la puissance vélo, la cadence (50-120 rpm), le terrain montagneux, et le capteur de puissance pour le pacing Z2-Z4. Aucune séance n'est conçue pour s'adapter à une absence de vélo.
- **Spécificité course** : le bloc 3 (W10-W13) est entièrement dédié à la **simulation de cols et de séquences tactiques** (progression_logic section 5). Une semaine sans vélo efface ces adaptations neuromusculaires spécifiques.
- **Progression_logic incompatible** : la règle des 10% hebdo (point 2, progression_logic) est basée sur des volumes mesurés en **kilomètres et durée de selle**. Sans vélo, la notion de "10% d'augmentation de volume" s'effondre (un équivalent course à pied de 150 km à vélo n'existe pas).
- **Zones de puissance et seuil** : toutes les prescriptions d'intensité (Z1-Z6, cadence, seuil lactique) sont calibrées pour le **capteur de puissance vélo**. RPE seule est un proxy très imprécis (écart ±15% possible).
- **Cutback weeks invalides** : si W10 est manquée/dégradée, la cohérence des cutbacks en W9 (test FTP pour recalibrage) et la progression W10-W13 sont **cassées**. Le test FTP de W9 J3 a d'ailleurs déjà été fait — impossible de recalibrer les zones sans puissance de référence post-W9.

## Contradictions
- **Contradiction avec safety_notes — intensité sans puissancemètre** : safety_notes prescrit une mesure **stricte des zones** : "Si FC : 65-75% FCmax". Mais FC seule en montée/descente est **hautement instable** (décalage 3-5 min, variation thermorégulation). Le pacing course (85-92% FTP sur cols) devient du pacing RPE estimé — erreur margin ±10 W possibles sur un seuil à 260-295 W.
- **Règle des 48h entre intensités** : impossible à respecter rigoureusement. Sans puissancemètre, comment confirmer qu'une sortie à pied de "Z3-Z4 perçu" (RPE 7/10) est bien en Z4 (91-105% FTP estimée) et non en Z3 (76-90% FTP) ? Risque : enchaîner deux vrais Z4 avec 24h d'intervalle au lieu de 48h.
- **Cassure de progression W9 → W10** : W9 J3 = test FTP (déjà exécuté en semaine 9 historique du plan). W10 utilise les **nouvelles zones post-test**. Si W10 est manquée/dégradée, le recalibrage de W9 est invalide pour le reste du plan (W10-W16 prescriptions nulles).
- **Affûtage W14-W16 compromis** : si une semaine critique (W10-W13) est perdue, l'affûtage ne peut pas compenser la perte de stimulus spécifique. Notes d'affûtage (progression_logic section 4) : "préserver les adaptations physiologiques acquises avec 50-60% du volume si l'intensité est maintenue". Sans volume de base Z2 et simulation de cols, les adaptations de base W1-W9 s'érodent rapidement.