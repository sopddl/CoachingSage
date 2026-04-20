# Adaptability : velo-intermediaire-endurance-10sem + p5-low-energy-week

## Rigidity score
**7/10**

Le template offre une flexibilité correcte sur les volumes (structure hebdomadaire claire, zones définies) mais impose des contraintes structurelles fortes (cutback weeks W4 et W8 "non négociables", progression_logic stricte 10-15%/sem, invariants physiologiques). Une semaine de fatigue peut être allégée sans casser le plan, mais le reschedule demande de la discipline pour ne pas "perdre" la progression.

## Patch approach

Identifier la semaine en cours (supposons W5-W9, hors cutback). Réduire le volume long ride de 20-25% (au lieu de 10-15% croissance nominale), ramener les blocs d'intensité à des durées courtes (halver sets ou durée par bloc), maintenir Z2-Z3 uniquement (supprimer Z4), et décaler la semaine originale de +1 vers la semaine suivante sans modifier les cutback W4/W8 qui restent obligatoires.

## Concrete modifications

**Exemple appliqué : W5 (semaine nominale reprise post-cutback W4, supposée être "65 km + Z4 1 min")**

- **W5 J1** Sortie endurance Z2 : réduire de 65 km → **52 km** (volume cutback W4 réutilisé), rester Z2 pur (65-75% FCmax), supprimer toute variante vallonnée, cadence libre 85-90 rpm, récupération maximale. Durée passée de 155 min → ~125 min.

- **W5 J3** Intervalles Z4 : **supprimer la séance Z4 intégralement**, remplacer par tempo Z3 allégé : **2 blocs de 8 min Z3** (au lieu de 6 × 1 min Z4), récupération 4 min Z1, pas de blocs supplémentaires. Durée passée de 70 min → ~50 min.

- **W5 J5** Sortie récupération Z1-Z2 : maintenir **30 km Z1-Z2** inchangé (60-70 min), c'est le socle de récupération à ne jamais réduire.

**Rattrapage post-W5 allégée (W6 nominale) :**

- Ne pas ajouter le volume perdu de W5 à W6 (piège courant).
- **Décaler W5 originale (65 km + Z4) vers W6** : W6 becomes "52 km (nominal W5 allégé) + 65 km long ride + Z4 1 min allégé → maintenir 65 km Z2 + Z4 structure 5 × 1 min 30 (compromis entre W5 original et charge basse)" = W6 conserve sa charge Z4 mais sans aggravation.
- **Avancer W6 originale (72 km + Z4 2 min) vers W7** si nécessaire pour étaler la charge.

## Rigidity issues

- **Cutback weeks W4 et W8 immobiles** : la progression_logic impose "deux cutback weeks obligatoires — non négociables". Si la semaine de fatigue basse-énergie tombe en W4 ou W8, le template offre déjà un cutback préconçu, donc pas de conflit (tu roules simplement la semaine prévue). Mais si elle tombe en W5-W7 ou W9, il faut créer manuellement une semaine allégée *sans* casser l'enchaînement des deux cutbacks.

- **Progression 10-15%/sem codifiée** : le volume long ride suit une courbe fixe (45 → 52 → 60 → 52 → 65 → 72 → 72 → 60 → 78 → 80). Réduire une semaine de charge "normalement" progressante (ex : W5 de 65 km) retire ~15% du volume, ce qui repousse les semaines suivantes. Rattraper sans créer deux progressions consécutives > 15% demande une renégociation des W6-W7.

- **Z4 obligatoire pour développer la puissance de seuil** : la progression_logic stipule "trois types de séances distincts chaque semaine : (a) Long ride Z2, (b) Séance intensité Z3 tempo ou Z4 seuil/intervalles, (c) Récupération active". Supprimer Z4 sur une semaine élimine la variété prescrite, mais sur une seule semaine basse-énergie c'est acceptable (récupération > progression temporaire).

## Contradictions

- **Pas de contradiction directe avec safety_notes**, mais deux points de vigilance :
  - Safety mentionne "3+ signes de surcharge = semaine allégée supplémentaire". Une semaine basse-énergie volontaire (fatigue exogène : boulot, sommeil) est **différente** d'une surcharge endogène (jambes lourdes, FC repos +8-10 bpm). Si tu combines les deux, il faut ajouter une 2e cutback (non prévu dans le plan 10-sem original) → restructuration lourde.
  - Safety : "Ne jamais remplacer la séance récup par une 2e séance intensive". Pendant la semaine basse-énergie, garder J5 récup intacte (30 km Z1-Z2) respecte cette règle. ✓

- **Progression_logic vs rattrapage** : si W5 est allégée (52 km vs 65 km attendu), et W6 nominale était 72 km (+8% vs W5 original 65 km), mais tu pars de 52 km réel en W5, l'augmentation W5 → W6 devient +38% (52 → 72), **dépassant le plafond 10-15%**. Il faut créer une W6 intermédiaire de ~58-62 km pour respecter la règle des 10-15%.

- **Cutback W8 timing** : si la fatigue basse-énergie s'enchaîne avec un allègement volontaire sur W6, et que W8 cutback approche, trois semaines consécutives partiellement allégées (W6 réduite, W7 normale, W8 cutback prévu) risquent de fracturer la surcompensation attendue post-W7. À surveiller mais pas rupture majeure.