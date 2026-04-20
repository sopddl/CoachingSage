# Adaptability : triathlon-intermediaire-sprint-12sem + p4-more-ambitious-goal

## Rigidity score
**3/10**

Le template est **très rigide** pour cette adaptation. Il est construit autour d'une architecture de 12 semaines avec 5 invariants non-négociables (parallélisme 3 disciplines, règle 10-15%, cutbacks W4-W8, bricks progressives, tapering W11-W12) et des volumes chiffrés à chaque semaine. Monter l'objectif final (ex : passer de sprint 750m/20km/5km à olympic 1500m/40km/10km ou à un niveau « avancé intermédiaire ») exige une restructuration quasi-complète, pas un patch élégant.

## Patch approach

Une adaptation de type « ambition accrue » demande de redéfinir :
1. Les distances cibles (ex : olympic = 1500m natation + 40km vélo + 10km run)
2. Les volumes semaine-à-semaine (multiplication globale par ~1,5–1,7x pour olympic)
3. Les seuils d'intensité (passer de Z4 « seuil 10K » à Z4 « seuil 5K » ou « tempo marathon »)
4. La durée du plan (12 semaines suffisent-elles pour la charge supplémentaire ?)

Le template refuse cette adaptation proprement : ses cutbacks W4 et W8, ses bricks de 25 min max, ses volumes natation (750m cap) sont tous **architecturés pour le sprint**. Les augmenter naïvement de +50% en gardant 12 semaines viole la recommandation ACSM de progression 10-15% hebdomadaire et crée un risque de surcharge.

## Concrete modifications

**IMPOSSIBLE SANS RESTRUCTURATION COMPLÈTE.**

Exemple si on tente le patch naïf (Olympic 1500m/40km/10km en 12 semaines) :

- **W1 natation** : escalader de ~800m (vs 700m) → W2 ~1100m (vs 900m) → violation règle 10-15% (saut de +37% W1→W2).
- **W5 brick** : passer à 50km vélo + 20km run → risque dramatique de surcharge sur jambes novices en transitions.
- **W10-W11 simulation** : tenter 1500m natation + 40km + 10km avec tapering = impossible physiologiquement en 3 semaines avant jour J.

**Modifications concrètes qu'on POURRAIT tenter (mais fragilité haute) :**

- **Convertir plan en 16-18 semaines** (accepter l'allongement) → **W1-W6 Bloc 1 étendu**, volumes natation +30% progressifs (W1 ~900m, W2 ~1100m, W3 ~1300m, W4 cutback ~900m, W5 ~1450m, W6 ~1650m).
- **W7-W12 Bloc 2** : bricks allongées (W7 vélo 45km + run 12km, W8 cutback, W9 simulation 40km + 10km).
- **W13-W16** : tapering 4 semaines (vs 2 en sprint) → W13 -15%, W14 cutback, W15 -20%, W16 jour J.
- **Intensité running** : passer des seuils 10K actuels à seuils marathon-tempo (~allure 15km cible, Z3 plutôt que Z4).

**OU**, si on refuse l'allongement et on force 12 semaines :
- **W1-W3** : augmenter natation à 1000, 1200, 1400m (violation -30% règle 10-15%).
- **W5 brick** : 35km vélo + 15km run (vs 25km + 10km) → risque tendinite ischio-jambiers MAJEUR sur jambes novices post-transitions.
- **W10** : simulation olympic = stress cardiovasculaire et mécanique extrême 72 heures avant la course.

## Rigidity issues

- **Architecture volumes natation gravée** : W1 ~700m, escalade linéaire vers W9 ~2000m, puis cutback pour W12 ~20m. **Toute la progression est pré-calculée pour le sprint.** La formule estimée (temps en min × ~1,5 = mètres) implique que doubler la distance cible = allonger la durée par 2, ce qui déstabilise les semaines précédentes (W6 natation passe à ~1800m-2000m au lieu de ~1500m).

- **Bricks construits pour le sprint** : W5 (25+10), W6 (40+15), W7 (20km+5km simulation), W8 cutback (20+10), W9 (25km+5km over-distance), W10 (simulation 400m+20km+5km). **Aucune brick olympic (1500m+40km+10km) n'est programmée dans le plan.** Le jour J, le triathlète inexpérimenté en transitions n'aura jamais simulé la distance réelle.

- **Cutbacks W4 et W8 incompressibles** : ACSM impose cutbacks toutes les 3-4 semaines en triathlon pour multi-sport. Les garder = limiter la capacité de progression. Les supprimer = augmenter dramatiquement le risque de surcharge (safety_notes cite « combinaison 3 sports = risque cumulatif »). **On ne peut pas patcher les cutbacks sans violer le fondement du plan.**

- **Tapering W11-W12 trop court pour olympic** : le tapering actuel (W11 -20%, W12 -30% + jour J) est calibré pour 1h30 sprint. Un olympic = 2h30-3h30 → demande tapering 2-3 semaines, pas 1 semaine. W11 et W12 du plan sont incompatibles avec une charge olympic.

- **Progression logic cite explicitement « sprint »** : *« Tapering terminal W11-W12 : réduction du volume de 20-25% (W11) puis 30-40% (W12 hors course), avec maintien d'intensité courte (intervalles 400 m, rappels Z4 de 3 min) pour préserver les adaptations neuromusculaires et éviter la 'mollesse' du tapering total. Ce protocole est aligné sur les recommandations Joe Friel pour les **courses de distance sprint (tapering 10-14 jours, pas plus).** »* → olympic demande 14-21 jours de tapering. **Impossible de garder W11-W12 tels quels.**

- **Safety_notes contradictoires** : la note sur les **brick sessions** dit *« Ne jamais tester de nouveau matériel (chaussures, combinaison néoprène) le jour de la course »* et présume un triathlon SPRINT. Pour olympic, cette recommandation s'inverse : tester à l'entraînement la combinaison sur 1500m en eau froide est OBLIGATOIRE (W9-W10), car omettre cette préparation en olympic = fréquence cardiaque incontrôlable et déperdition thermique. Le template ne mentionne pas olympic eau froide comme cas.

## Contradictions

- **Contradiction: progression_logic vs. volumes olympic.**
  - *progression_logic* : « RÈGLE 10-15% DE PROGRESSION : le volume total hebdomadaire augmente de 10 à 15% maximum d'une semaine à l'autre. »
  - **Tentative olympic sur 12 semaines** : natation seule passe de ~700m W1 à ~1500m W10 = +114% en 9 semaines = **+12.7% médian/semaine, techniquement juste**. Mais vélo passe de 45 min W1 à 120-150 min (W10 simulation) = +167% sur même durée = **+18.8% médian = VIOLATION clara.**
  - **Risk** : semaines W8-W9 seraient explosives si on force la progression olympic. Cutback W8 n'est pas assez agressif.

- **Contradiction: brick novice vs. olympic distance.**
  - *safety_notes* : « Brick sessions : les premières minutes de run post-vélo SONT inconfortables (jambes en coton) — c'est physiologique. »
  - **Olympic reality** : après 40km à cadence soutenue, les jambes ne sont pas « en coton », elles sont **semi-épuisées (lactate, glycogène bas).** Un novice en transitions sur olympic risque dysphorie massive, abandon, ou blessure (rupture tendinite ischio après 40km fatigue + 1-2km run). Les 7 bricks du plan (du W5 au W11) n'escaladent que jusqu'à 25km + 5km en W9 over-distance. **Aucune brick ne monte à 40km + 10km avant le jour J.** Cela viole la recommandation British Triathlon : *« tester la distance avant la course ».*

- **Contradiction: seuil intensité running.**
  - *progression_logic* : « Allure seuil = allure 10K + 15-30 sec/km, soit ~5 min à 5 min 30/km. »
  - **Olympic run (10km)** : la stratégie d'un 10km après 1500m + 40km demande un effort Z3-Z4 **marathon-tempo** (allure 15km cible + 30-60 sec/km), **pas** 10K seuil. Le plan force un seuil 10K court sur les intervalles (W7 600m, W9-W10 1000m), ce qui est trop rapide pour un 10km post-olympic fatiguée. **Recalibrage d'intensité obligatoire : reclasser les seuils en Z3 marathon plutôt que Z4 5K.**

- **Contradiction: natation eau froide et combinaison.**
  - *safety_notes* : « Si tu utilises une combinaison le jour J, effectue AU MOINS 2-3 sorties en bassin avec ta combinaison avant la course pour t'habituer aux sensations. Idéalement, tester en W9-W10. »
  - **Olympic distance** : 1500m en eau froide avec combinaison = 25-35 min d'effort continu, durée **3-4× le sprint 750m.** Les 2-3 sorties bassin du plan (W9-W10) sont **insuffisantes** pour adapter un novice à une demi-heure en combinaison serrant. Faudrait 4-5 sessions min (W8-W10). Le tapering W11 n'en prévoit aucune. **Risque de panique respiratoire en course augmente.**

- **Contradiction: jour J réalisme.**
  - *W12 J5* (jour J) : la simulation W10 (natation 400m + vélo 20km + run 5km) est prévue comme « simulation complète », or elle fait **50%** de la charge olympic. Un triathlète inexpérimenté qui peine sur 400m+20km+5km en semaine 10 n'est **pas prêt** pour 1500m+40km+10km en semaine 12 malgré le tapering. Le template sous-estime la fatigue musculaire et neuromusculaire nécessaire pour progresser du sprint à l'olympic.

---

## Conclusion adaptabilité

**Adapter ce template à une ambition olympic est IMPOSSIBLE proprement en 12 semaines.** Le plan doit être **allongé à 16-18 semaines minimum** pour respecter la règle 10-15% et construire les bricks progressives. Une tentative de forcer olympic sur 12 semaines casse :
1. La progression ACSM (violation W8-W9 surcharge).
2. Les transitions (pas de brick 40km+10km avant jour J).
3. L'intensité running (seuil 10K trop rapide, falloir Z3 marathon).
4. Le tapering (2 semaines insuffisant pour olympic).

**Recommandation claire au profil p4** : revoir l'ambition à **olympic-distance sur 16-18 semaines**, ou **rester sprint en 12 semaines** et viser un 10K novice plutôt qu'un olympic. Monter en distance ET garder 12 semaines = risque blessure MAJEUR.