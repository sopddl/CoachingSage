# Adaptability : natation-expert-perfectionnement-12sem + p5-low-energy-week

## Rigidity score
**7/10**

Le template possède une structure de cutback intégrée (W4, W8) et des règles de surcharge explicites (safety_notes : "3+ signes = semaine allégée immédiate"). Cela crée une base flexible. Cependant, la progression linéaire ondulatoire est pensée comme un bloc — injecter une semaine allégée hors cutback prévu crée des décalages d'adaptation et demande une reconstruction partielle de la semaine.

## Patch approach

Réduire le volume de la semaine en cours de **-30%** (règle safety_notes existante pour surcharge), maintenir 1-2 séances d'intensité modérée pour préserver le signal d'adaptation, remplacer les séances longues par des blocs courts, et décaler légèrement la semaine suivante (+15% vs prévisionnel) pour compenser le manque d'accumulation.

## Concrete modifications

**Exemple appliqué : si la semaine fatigue survient en W7 (pic volume 13500 m):**

- **W7 J1** (VO2max 200 m × 10) : réduire à **5 répétitions** (vs 10). Repos allongé 75 sec (vs 60 sec). Récup allongée à 500 m (vs 300 m). Volume réduit de 3200 m → 2100 m.
- **W7 J2** (Papillon tech + séries) : **supprimer papillon** entièrement, remplacer par crawl simple. Réduire drills de 6 à 4 rép chacun. Crawl complet : 3 séries de 100 m au lieu de 6. Volume réduit de 2750 m → 1600 m.
- **W7 J4** (Seuil 800 m × 3) : réduire à **2 répétitions** (vs 3). Repos allongé 120 sec (vs 90 sec). Supprimer la série kick palmes. Volume réduit de 3250 m → 2100 m.
- **W7 J6** (Endurance longue 3000 m + sprint) : réduire endurance à **2000 m** continu Z2 (vs 3000 m). Supprimer sprints finaux. Volume réduit de 3300 m → 2100 m.

**W7 allégée résultat : ~7900 m (vs 13500 m prévisionnel = -41%, > -30% requis).**

**Rattrapage W8 :**
- W8 est déjà un cutback prévu (10000 m). **Ne pas augmenter au-delà de 10000 m** en W8 — respecter la structure cutback existante.
- Compenser plutôt en **W9** : augmenter de **+200 m** (W9 prévisionnel 12000 m → 12200 m) en ajoutant une 4e répétition de sprint 25 m J1 (+100 m) et 100 m crawl J2 (+100 m).

## Rigidity issues

- **Papillon W7 J2 très structuré** : le drill papillon est une nouveauté B3, sa suppression est facile mais crée un blanc dans la progression papillon. Récupération : en W8 J2 (tech cutback), réajouter les drills papillon à intensité modérée (4 rép au lieu de 6) pour ne pas perdre la motricité.

- **Progression linéaire cassée** : réduire W7 de -41% alors que W8 est déjà cutback (-26%) crée un profil **W7 allégée (7900 m) < W8 cutback (10000 m)**. C'est cohérent pour récupération mais décale l'accumulation de charge globale. Si la fatigue survient plus tôt (ex : W5 ou W6), la cassure est plus visible.

- **Allures seuil W7 recalibrées sur W6 TT** : si on réaffecte W7 allégée et qu'on saute W7 pour une autre semaine, les allures "recalibrées sur TT W6" deviennent obsolètes. Solution : noter les allures W6 avant W7, les réappliquer sans changement même en allégée.

## Contradictions

- **Contradiction seuil vs fatigue (W7 J4 seuil réduit)** : safety_notes stipule "Minimum 48h entre deux séances d'intensité élevée sur les mêmes filières". W7 J1 (VO2max réduit à 5 rép, reste Z4-Z5) et W7 J4 (seuil réduit) sont à 3 jours d'écart — **conforme**. Pas de conflit.

- **Contradiction avec progression_logic** : la règle "max +12% hors cutback" est respectée post-semaine fatigue (W7 allégée 7900 m → W8 cutback 10000 m = +26.6%, mais W8 est déjà cutback donc cette règle ne s'applique pas). Pas de conflit réel.

- **Safety_notes : "3+ signes de surcharge = semaine allégée immédiate"** → cette adaptation s'aligne exactement avec la règle existante. **Aucune contradiction**. Le template prévoit déjà cette flexibilité.

- **Pas de contradiction virage/culbute** : les techniques W7 (virages, papillon) peuvent être allégées sans casser la sécurité. Une culbute moins travaillée une semaine ne génère pas de risque immédiat.