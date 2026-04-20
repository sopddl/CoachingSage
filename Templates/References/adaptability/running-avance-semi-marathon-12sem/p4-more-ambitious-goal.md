# Adaptability : running-avance-semi-marathon-12sem + p4-more-ambitious-goal

## Rigidity score
**3/10**

## Patch approach
L'adaptation "objectif revu à la hausse" pose un problème structurel majeur au template. Le plan est **conçu pour un semi-marathon (21,1 km)** avec allures et volumes calibrés sur cette distance. Viser "le niveau au-dessus" sur 12 semaines interprète comme : passer du semi-marathon à un **marathon (42,2 km)** ou viser un **semi à allure nettement plus rapide** (sub-1h45 au lieu de 1h45-2h00). Aucune des deux options n'est compatible sans reconstruction complète du plan. L'augmentation naïve des volumes hebdomadaires casse le ratio de progression (règle des 10%), et les allures cibles deviennent physiologiquement intenables en 12 semaines partant du même profil de base.

## Concrete modifications

**Option 1 (Semi-marathon + 10-15 min plus rapide, cible 1h30-1h45) — déconseillé :**
- **W1-W3** : augmenter les volumes de +15% (W1 → 46 km au lieu de 40 km). Immédiatement **risque de surcharge précoce** (règle des 10% : delta max +12% par semaine sauf sortie de cutback).
- **W3 J5** Tempo 30 min : rehausser à allure 4:50-5:00 min/km (vs 5:00-5:10). **Contradiction directe** : safety_notes indique que l'allure seuil pour ce profil est 5:00-5:10 min/km ; descendre sous 5:00 exige un VO2max > 55 ml/kg/min, non documenté dans le profil assumed_profile.
- **W7 J3** 6×1000 m : passer à 5×1200 m à allure 4:20-4:30 min/km. **Dérape complètement** : la progression_logic stipule 400→600→800→1000 m pour gérer le stress neuromusculaire ; sauter à 1200 m ignore l'apprentissage moteur.

**Option 2 (Marathon 42,2 km en 12 semaines partant de ce profil) — impraticable :**
- **W1 Sortie longue** : déjà à 14 km (ciblée demi). Pour un marathon, il faudrait commencer à 25-27 km.
- **W9 Pic** : template pic W9 à 23 km (109% demi). Marathon requiert 35-38 km en W9 (90% marathon).
- **Delta W8→W9** : template +25% (44→55 km). Marathon demande +35-40% pour atteindre 35 km de sortie longue → **risque majeur de blessure** (ischio-jambier, stress fracture tibiale, ITBS listé en safety_notes).

## Rigidity issues

- **Progression_logic imbriquée profondément** : la règle des 10% hebdomadaire est un pilier ; les volumes chiffrés (W1 40→W9 55 km) sont préalculés pour cette contrainte spécifique. Toute augmentation > 12%/semaine casse le ratio et rend impossible la gestion de la fatigue cumulée.
- **Allures cibles mono-profil** : le template calibre **toutes les zones d'intensité** sur "10K en 55 min" (allure 5:30/km). Pour un objectif plus rapide, il faudrait recalculer depuis un profil de 10K en 50 min ou moins → new profile, nouveau plan.
- **Sortie longue distance-dépendante** : semi = max 23 km (W9), marathon = min 35 km en pic. Il n'existe **pas d'intermédiaire adaptable** dans 12 semaines ; c'est une mutation de distance.
- **Safety_notes très liés au profil avancé semi** : drapeaux rouges (tendinite ischio, ITBS, stress fracture tibiale) sont **amplifiés** si on augmente le volume ; le renforcement préventif (nordic curl, clamshells) reste le même → déséquilibre risque/prévention.

## Contradictions

- **"Progression avancée" vs "objectif plus exigeant en 12 sem"** : Le template assume déjà un coureur "confirmé pratique 3×/sem depuis 6 mois". La marge de progression de ce profil est faible. Augmenter l'intensité **sans augmenter la durée du plan** place le coureur en position de jamais atteindre la supercompensation entre pics (W9 pic → taper court W11-W12 → course W12). Ajouter 10-15% de volume + intensité renforcée = cumul dangereux.
- **Safety_notes "Aucun delta W→W+1 ne dépasse +25%"** vs "Objectif marathon en W1-W9" : passer de W8 (44 km) à W9 (35-38 km pour marathon) requiert un delta de 35-40%, **violation explicite de la sécurité**.
- **Allure semi cible (5:05-5:20 min/km) vs allure marathonienne** : marathon demande une allure plus lente (~5:20-5:40 min/km pour 1h50-2h10 marathon) que le semi cible du template. Reverser la hiérarchie d'intensité casse la cohérence des zones (Zone 2, Zone 3 redéfinie).
- **Critère d'arrêt manquant** : if "objectif rehaussé" = semi sub-1h45 (allure moyenne 4:58 min/km) : c'est au seuil anaérobie du profil assumed (Zone 4 = 85-90% FCmax, allure 4:45-5:00 min/km). Tenir 1h45 à 4:58 min/km exige un VO2max + seuil anaérobie très élevés ; template ne fournit **pas d'évaluation préalable** de capacité du coureur à cette allure (test 10K nécessaire ; as-tu 50 min de 10K capability ?).

---

## Conclusion / Recommandation

**Verdict : Template NON ADAPTABLE pour un objectif "rehaussé à la hausse" sans reconstruction.**

**Solutions recommandées :**

1. **Si objectif = Semi sub-1h45** : Refuse cette demande. Le plan ne peut pas la supporter en 12 sem. Propose un **cycle 16-18 semaines** avec un 2e bloc d'accumulation (W5-W8 rehaussé) avant taper. Ou : teste ton 10K réel avant d'accepter (besoin > 50 min de 10K viable).

2. **Si objectif = Marathon en 12 sem** : À ranger aux dossiers — **pas praticable**. Propose un plan marathon spécifique de **20 semaines** (accumulation plus longue) ou un plan semi "performance" de 12 sem suivi d'un bloc marathon de 12 sem ultérieur.

3. **Si "rehaussé" veut dire "semi à meilleure allure dans les paramètres du plan"** (ex : 1h50 au lieu de 2h00, soit 5:20 min/km au lieu de 5:40 min/km) : Cela **rentre dans la fourchette du template** (1h45-2h00 → cible basse 1h45). **Pas d'adaptation nécessaire** ; respecte déjà le plan et vise son seuil haut.