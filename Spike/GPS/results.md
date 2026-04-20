# Spike 0.1 — Résultats GPS background

**Date** : 2026-04-08 (validation finale, après data sale du 2026-04-07)
**Device** : iPhone de Sophie (iOS 17)
**Conditions** : trajet vélo bureau ↔ maison, urbain
**Météo** : à compléter si pertinent

## Mesures clés (session matinale propre, sans pause, sans charge)

| Métrique | Valeur | Cible | Verdict |
|---|---|---|---|
| Background autorisé | ✅ | requis | ✅ |
| **Passé en background** | ✅ | requis | ✅✅ |
| First fix | **0.0 s** (instantané) | < 10 s | ✅ |
| Distance trajet aller | 9.99 km | — | ✅ |
| Temps actif tracking | 35' 51" | — | ✅ |
| Points GPS capturés | 1454 | > 50 | ✅ (29× la cible) |
| Précision moyenne | **± 6.8 m** | < 10 m | ✅ |
| Au démarrage | 95% | — | ✅ |
| Au retour (arrivée bureau) | 90% | — | — |
| Drop session aller | 5.0 % | — | ✅ |
| **Drop estimé /h** | **8.3 % / h** | **< 15 %/h** | **✅** |
| Crash applicatif | 0 | 0 | ✅ |

## Verdict

✅ **SPIKE PASS COMPLET** — 5/5 critères critiques de Story 0.1 validés.

## Données du jour complet (informatif)

| Métrique | Valeur | Note |
|---|---|---|
| Temps actif total (matin + soir) | 1h 12'21" | aller + retour cumulés |
| Distance totale | 19.86 km | |
| Points GPS totaux | 2819 | |
| Précision moyenne globale | ± 9.4 m | toujours sous 10 m |
| Batterie début → fin de journée | 95% → 55% (-40%) | sur ~11h d'usage iPhone total |

## Observations qualitatives

- **Tracking GPS background fonctionne parfaitement** : le tracking a continué pendant que l'iPhone était verrouillé dans la poche pendant tout le trajet vélo. C'est LE résultat critique pour Epic 4.
- **First fix instantané** : sur la session matinale propre, le fix GPS a été acquis en moins d'une seconde (0.0 s mesuré). La cible "< 10 s" est largement battue.
- **Précision excellente** : ± 6.8 m de moyenne en conditions urbaines/péri-urbaines, c'est ce qu'on attend d'un iPhone moderne avec ciel relativement dégagé.
- **8.3 %/h de drop batterie** : ça signifie qu'une session de **2h coûte ~17%**, **4h coûte ~33%**, **6h coûte ~50%** — confortablement viable pour des sessions trail/marathon/longue rando.
- Yesterday's data (2026-04-07) was tainted by iPhone death + recharge during session, donc invalid pour la mesure batterie. La data du matin du 8 avril est le résultat de référence.

## Bugs identifiés dans le code spike (à corriger en prod Epic 4)

### Bug 1 — Drop estimé /h trompeur sur sessions avec pauses
La formule actuelle est `drop_total / temps_actif_tracking`. Sur la session du soir (data 19:33), elle donnait 33.2 %/h car le temps actif (1h12) ne représentait qu'une fraction du temps total (~11h) pendant lequel l'iPhone consommait sa batterie pour tout autre chose que le GPS. **Fix** : ne calculer le drop /h que sur des sessions sans interruption, ou mesurer le drop uniquement pendant les segments actifs (instrumentation au moment des resume).

### Bug 2 — Flag "App killée pendant tracking" persiste
Le @Published var `crashedOrKilled` reste à true toute la durée de vie de l'app. Devrait s'auto-clear après une session OK. **Fix** : reset à false à la fin d'un `stopTracking()` réussi.

### Bug 3 — First fix calculé depuis startDate au lieu de premier point
Sur une session avec pause/resume (data 2026-04-07), la valeur affichée était 16895.8 s, ce qui n'a aucun sens. **Fix** : recalculer firstFix au début de chaque "vraie session" (après stop, pas après pause), ou stocker firstFixDate plutôt qu'un offset.

## Décisions architecturales suite à ce spike

### Confirmées
- ✅ **CoreLocation + Background Modes "Location updates"** est viable pour Epic 4 EnduranceTrackingEngine
- ✅ **Always authorization requise** pour le background — pas de raccourci possible
- ✅ **Pas besoin de Workout Session HealthKit** pour avoir du GPS background (mais on l'utilisera pour intégrer dans Apple Health après — voir Spike 0.2)
- ✅ **iOS 17 minimum** comme deployment target (les async/await CL APIs)

### À ajouter au plan Epic 4
- **Story Epic 4.x** : EnduranceTrackingEngine basé sur le code de `LocationService.swift` du spike (structure clean, déjà 60% production-ready)
- **Story Epic 4.x** : protocole `LocationServiceProtocol` pour l'injection de dépendance et le mocking dans les tests
- **Story Epic 4.x** : persistance des points pendant la session (si l'app est killée par iOS pour mémoire pendant un long trail, on ne perd pas tout) — UserDefaults pour les stats, ou SwiftData pour les points
- **Story Epic 4.x** : règle de filtrage des points (déjà dans le spike : accuracy < 25m, age < 5s, speed jump < 50 m/s) — à porter
- **Story Epic 4.x** : calcul du drop batterie pendant les segments actifs uniquement
- **Story Epic 4.x** : detection de "tunnel/bâtiment" (chute brutale de précision) pour interpoler intelligemment

### Pas de blocker identifié
Aucun. Les bugs identifiés sont mineurs et seront corrigés naturellement en portant le code en prod.

## Code à réutiliser en production

Le fichier `LocationService.swift` du spike (~280 lignes) est à **60-70% production-ready**. Travail restant :
- Conformer à un protocole pour DI
- Persistance SwiftData (au lieu de in-memory uniquement)
- Fixer les 3 bugs ci-dessus
- Ajouter detection mode (running, cycling, walking) selon `CMMotionActivityManager`
- Ajouter export GPX si on veut compatibilité Strava manuelle (en fallback de l'export HealthKit auto)
