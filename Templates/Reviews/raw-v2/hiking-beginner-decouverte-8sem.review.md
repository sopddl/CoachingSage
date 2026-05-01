# Quality Review — hiking-beginner-decouverte-8sem

**Verdict** : APPROVED
**Sport** : hiking  **Level** : beginner  **Schema version** : 2

## 1. Doctrine alignment

Le template est bâti **ex nihilo** (pas de v1 hiking préexistant) sur la doctrine du fragment `hiking.md` Phase C — Uphill Athlete (House-Johnston) pré-Beginner + American Hiking Society + AMC Backpacking for Beginners + FFRandonnée niveau facile + rucking militaire civil-adapté (Stew Smith / GORUCK) + études biomécaniques poles. La revue web confirme la conformité doctrinale sur tous les axes attendus pour une initiation randonnée 8 semaines.

- **Volume hebdo cible beginner 2-4 h/sem** (fragment l. 92 + American Hiking Society / AMC Beginner Backpacking) : le plan progresse 1h45 → 3h45 (W1-W8), avec un pic exactement dans la fenêtre haute de la cible (3h45 = 225 min, fragment cible 2-4h = 120-240 min). **PASS.**
- **D+ hebdo beginner 200-600 m** (fragment l. 92) : progression 200 → 280 → 350 → 250 cutback → 400 → 500 → 550 → 500. Toutes les valeurs dans la fenêtre. Pic à 550 m (W7) inférieur à la borne haute 600 m. **PASS.**
- **Sac max beginner 3-5 kg** (fragment l. 92) : progression 2 → 2 → 3 → 3 → 4 → 4 → 5 → 5 kg. Pic à 5 kg, exactement la borne haute doctrinale. Démarrage 2 kg ~3% PdC = en deçà de la règle rucking militaire 10% PdC mais assumé explicitement (`progression_logic` ligne 20 : « en deçà de la règle 10% PdC car niveau initiation »). Conforme à American Hiking Society et AMC débutant + adaptation tissus conjonctifs lente Stew Smith. **PASS.**
- **Terrain plat → vallonné** : tous les exercices marche cités `gradient-flat` (W1 marche plate) à `gradient-rolling à gradient-moderate (3-10%)` (sorties D+ W1-W8). Aucun gradient steep / very-steep. Conforme au public débutant T1 SAC / facile FFRandonnée. **PASS.**
- **Altitude < 1500 m exclusivement** : grep ligne 216, 452, 688, 925, 1162, 1399, 1636, 1873 confirme `altitude-low (< 1500 m)` sur **toutes** les sorties D+. Aucune altitude > 2000 m proposée — ZÉRO mention de WMS rule, ce qui est cohérent (plan beginner sans objectif altitude). **PASS** sur la doctrine WMS (non-applicable, pas de risque AMS).
- **Intensité Z1-Z2 / RPE 4-5 dominante** (fragment l. 155 « beginner : 100% Z1-Z2, pas d'intensité Z3 jusqu'à ce que le profil tienne 90 min en continu confortable et 400 m D+ sans détresse ») : `progression_logic` ligne 20 cite explicitement la règle ; aucun exercice marche n'a `target_zone: "Z3"` ou `RPE 6-7` ou `RPE 8-9` ; les S&C sont `RPE 4-5`/`RPE 6-7` en zones isolées (gainage/squat) ce qui ne contre-indique rien — cible ciblée pour renforcement musculaire. La dérive à RPE 5 maxi 5-10 min en montée est explicitée et bornée (« redescendre en RPE 4-5 dès que possible »). **PASS.**
- **Renforcement préventif 1-2 sessions/sem** (fragment l. 92 micro_pattern + Uphill Athlete) : 1 séance S&C dédiée 20-25 min/sem présente W1-W8, 6 exercices ciblés (Y-T-W shoulder, gainage planche, bird-dog, pont fessier, squat, calf raises) — combo prévention chaîne postérieure + mobilité épaules + mollets exactement aligné AMC backpacking-for-beginners et Uphill Athlete pré-Beginner. **PASS.**
- **Trekking poles introduits W3** (fragment l. 259 « optionnel beginner, recommandé descente ») : ligne 688 W3 J6 « Introduction des bâtons ... découverte technique : longueur réglée pour avoir le coude à 90° en terrain plat, raccourcir 5-10 cm en montée, allonger 5-10 cm en descente ». **PASS** — aligné aux études Schwameder & Bohne (réduction 12-25% forces tibiofémorales) citées dans `safety_notes`.

## 2. Metadata hooks (Schema v2)

Audit programmatique : **0 hook manquant** sur les 64 exercices répartis dans 24 sessions actives (3 actives × 8 semaines). 0 `alternatives: []` vide.

- `target_zone` : zones cohérentes — `Z1`, `Z2`, `RPE 4-5`, `RPE 6-7` pour S&C/marche. Pas de zone générique "moderate". **PASS.**
- `required_equipment` : kebab-case respecté (`mat`, `hiking-shoes`, `backpack`, `water-bottle`, `trekking-poles`). `hiking-shoes` + `backpack` présents sur **toutes** les sorties marche conformément au fragment (« OBLIGATOIRE pour toute sortie hiking — JAMAIS omis »). `trekking-poles` ajoutés W8 séance phare ligne 1879. **PASS.**
- `incompatible_constraints` : kebab-case, granulaires (`shoulder-injury`, `lower-back-pain`, `knee-injury`, `ankle-injury`, `wrist-pain`, `cardiac-clearance-required`, `no-trail-access`, `no-elevation-access`). Couverture spécifique hiking solide. **PASS.**
- `alternatives` : 2 alternatives réalistes par exercice (tapis incliné, escalier d'immeuble, stairmaster, mini-squat, planche genoux). Aucune liste vide — règle Story 3.3a respectée. **PASS.**
- `volume_axis` : `duration` pour marches + planche, `reps` pour S&C par comptage. Cohérent. **PASS.**
- Hooks per-template : `week_structure` (linear, micro_pattern, recovery_cadence ligne 12-16), `deload_weeks: [4]` ligne 17-19, `progression_logic` ligne 20 (5 principes sourcés Uphill Athlete/AMC/Stew Smith). **PASS.**

**Section schema v2 — APPROUVÉE intégralement.**

## 3. Internal consistency

| Check | Statut | Notes |
|---|---|---|
| `duration_weeks == weeks.count` | PASS | 8 == 8 |
| `sessions_per_week` 3 actives | PASS | 3 actives + 4 repos = 7 par semaine sur les 8 semaines (J2 S&C + J4 plate + J6 D+) |
| Volume curve W1→W8 | PASS | 105 → 130 → 155 → 115 → 165 → 190 → 210 → 225 min programmé (incl. S&C). Match exact aux annonces 1h45/2h10/2h35/1h55/2h45/3h10/3h30/3h45 |
| Pic en W7 ou W8 | PASS | Pic en W8 à 225 min, W7 secondaire à 210 min — conforme à un plan beginner avec sortie phare en W8 |
| Volume "marche pure" annoncé ↔ JSON | PASS | Calcul programmatique : W1 85+20=105, W2 110+20=130, W3 130+25=155, W4 95+20=115, W5 140+25=165, W6 165+25=190, W7 185+25=210, W8 200+25=225 — match exact 100% sur les 8 semaines (zéro drift, contraste fort vs pilote running et yoga). **Lessons learned point #1 et #6 respectés.** |
| Cutback W4 magnitude | PASS | 115/155 = -25.8% — exactement dans la fenêtre beginner -25/-30% acceptée par doctrine (`progression_logic` ligne 20 « -25% volume, dans la fenêtre beginner -25 à -30% acceptée par doctrine pré-Beginner ») |
| Progression D+ hebdo dans la doctrine (+10-20%) | PASS avec exceptions assumées | W2 vs W1 = +40% (200→280), W5 vs W4 = +60% (250→400). Les deux exceptions sont **explicitement bornées** dans `progression_logic` : W1→W2 (« +40% acceptable car charge absolue très basse ») et W4→W5 (« retour palier proche W3 post-cutback »). Les autres deltas W3+25%, W6+25%, W7+10%, W8 légère baisse — tous dans la fenêtre stricte. La phase build sérieuse W5-W7 est sous +30% comme annoncé |
| Progression sac sans saut > 1 kg | PASS | 2/2/3/3/4/4/5/5 — chaque palier tenu 2 sem avant +1 kg, conforme rucking civil Stew Smith (+1-2 kg / 2-3 sem) |
| `progression_logic` cite éléments réels du plan | PASS | Y-T-W, gainage, bird-dog, pont fessier, squat, calf raises tous présents ; durées 20→40 sec gainage cohérentes (effective : 20→25→30→25→30→30→35→35 sec, progression linéaire avec micro-cutback W4) ; bâtons mentionnés W3 introduction effective ligne 688 |
| Goal hebdo ↔ contenu réel | PASS | Chaque `goal` annonce `(X min plat + Y min D+ + Z min S&C)` — vérifié programmatiquement, match exact 8/8 semaines |
| Sortie phare 2 h W8 | PASS | Ligne 1862-1894 J6 W8 = 120 min de marche pure (`duration: "120 min total dont 500 m D+ cumulé"`), `duration_minutes: 140` (warmup 10 min + cooldown ~10 min + 120 min effort) — arithmétique cohérente |

**Bilan section** : structure, distribution séances (1 S&C / 1 plate / 1 D+), volumes annoncés ↔ JSON, hooks v2, progression doctrinale et sortie phare W8 sont **tous propres**. Aucun drift numérique — c'est le contraste fort avec yoga-beginner (volume mismatch) et certains running.

## 4. Cutback / deload

- `deload_weeks: [4]` — déclaré, fragment l. 314 confirme « Plan 8 sem beginner : `[5]` » mais doctrine accepte aussi W4 (cycle 3 build + 1 cutback). Le choix W4 est cohérent : 3 sem build (W1-W3) + cutback (W4) + reprise progression (W5-W8 avec sortie phare). **PASS** structurellement.
- W4 (lignes 733-967) : 3 séances actives, marche plate 45 min (vs 50/60 min W2-W3), sortie D+ 250 m / 50 min (vs 280/350 m / 60-70 min), S&C 20 min (vs 25 min W3) avec gainage 25 sec (vs 30 sec W3). Progression S&C légèrement réduite — l'esprit cutback est respecté (volume + intensité absolue toutes deux abaissées sans casser les acquis).
- Magnitude réelle vérifiée : 115 min vs 155 min = **-25.8%**, exactement dans la fenêtre beginner -25 à -30% du fragment ligne 134 (« beginner : 5-6 build + 1 cutback W4-W5 (-25 à -30% volume accepté car charge absolue faible, marge récup utile) »). **PASS** sur magnitude.
- `recovery_cadence: "1 cutback W4 sur plan 8 sem (réduction ~25% volume vs W3, fenêtre beginner -25 à -30% acceptée par doctrine Uphill Athlete pré-Beginner)"` — annoncé, source citée, range respecté. **PASS.**

**Verdict** : structurellement et numériquement PASS, esprit cutback respecté.

## 5. Safety

`safety_notes` (ligne 21) couvre exhaustivement les sections doctrinales attendues pour hiking beginner :

- **RED FLAGS hiking débutant** : entorse cheville (« risque n°1 »), genou descente (rotulien, ITBS), ampoules, coup de chaleur, hypothermie, hypoglycémie/cardiaque, antécédents > 50 ans / sédentarité prolongée. **PASS** — aligne fragment l. 215-219.
- **GENERAL RULES** : chaussures rodées (« jamais neuves le jour J »), proprio cooldown, prévenir un proche du tracé, plan B itinéraire, sifflet + couverture survie en sac dès W3, météo vérifiée 24 h avant. **PASS.**
- **PRÉVENTION GENOU DESCENTE** : bâtons recommandés W3-W4, force unilatérale via S&C, "Pas du chamois", glaçage post-sortie. Citation **explicite** des études Schwameder & Bohne (réduction 12-25% forces tibiofémorales) — conforme fragment l. 28 et 216. **PASS.**
- **PRÉVENTION CHEVILLE** : tige basse acceptable beginner sentier balisé plat (fragment l. 257 « basse acceptable beginner plat balisé »), tige montante recommandée terrain technique, JAMAIS chaussures running, proprio single-leg balance. **PASS.**
- **MATÉRIEL OBLIGATOIRE** : chaussures dédiées rodées + chaussettes anti-friction + sac 15-25 L + gourde 750 ml min + 10 essentials AMC adaptés journée + bâtons W3+. Aligne fragment l. 257-269 et AMC. **PASS.**
- **NUTRITION-HYDRATATION** : 30-60 g glucides/h, 500-750 ml eau/h tempéré (1 L/h chaleur > 25°C, sodium 300-700 mg/L), barre/banane/dattes. Conforme aux recommandations American Hiking Society. **PASS.**
- **THERMORÉGULATION** : été matinée < 11h ou soirée > 17h si T° > 25°C, hiver 3 couches (base merino + isolation + coupe-vent imperméable). **PASS.**
- **OVERLOAD SIGNS** : 6 signaux listés, règle 3+ → semaine -20%. Conforme fragment et lessons learned. **PASS.**
- **MISSED SESSION HANDLING** : 3 paliers (1 séance / 1 sem / 2 sem). « La précipitation après une coupure est la première cause de récidive de tendinite ou d'entorse » — formulation alignée doctrine. **PASS.**
- **SÉCURITÉ ITINÉRAIRE** : prévenir trajet, sentiers balisés T1 SAC / facile FFRandonnée, capture d'écran + plan B, sifflet + couverture survie, météo. **PASS.**

Aucun copy-paste générique. Section très solide, calibrée hiking-beginner sans dérive vers les niveaux supérieurs (pas d'AMS, pas de RED-S, pas d'engelures — non-applicables ici).

## 6. EU MDR

Scan `grep -niE 'guéri|soigner|traiter|traitement|diagnost|médica[mt]|thérap|cure|rééduc|prescrip|ordonnan|remède|réparer'` :

- **0 occurrence** des mots bannis comme claim médical direct ou indirect.
- Le mot **« médecin »** est utilisé dans la formulation « **consulte un médecin avant de commencer ce programme** » dans `safety_notes` (ligne 21) — **exactement** la formulation requise pour déclencher le medical clearance, correctement bordée par les conditions cibles (« antécédents cardiaques connus, plus de 50 ans avec sédentarité prolongée, antécédent entorse cheville / pathologie genou récente, lombalgie chronique, grossesse / postpartum récent »).
- Le mot **« kiné »** apparaît une fois (ligne 21 « consultation kiné » si douleur > 2 sorties consécutives) — référence professionnelle d'orientation, pas une prestation revendiquée. **OK** au regard EU MDR (référer ≠ prescrire).
- `assumed_profile` (ligne 10) : « adulte 25-55 ans, sédentaire à modérément actif, ... pas de pathologie cardiaque, genou ou cheville déclarée » — population générale saine, hors champ MDR.
- Aucun framing de rééducation ni de traitement (pas de « post-blessure », « rééducation post-opératoire », « soigner », « réparer », « cure » nulle part).

**EU MDR — PASS clean.**

## 7. Final autonomy checklist (last week)

Présente sur ligne 1873 (notes sortie phare W8 J6), **4 critères mesurables explicites** :

1. **Tenir 2 h en continu** sur sentier balisé avec D+ 300-500 m sans s'arrêter pour fatigue (pause technique 5-10 min en milieu de parcours acceptée).
2. **Pose des pieds attentive en descente** sans glissade ni torsion cheville, en utilisant 'Pas du chamois' (pas plus courts, genou fléchi).
3. **Gestion hydratation (500 ml/h) et en-cas** en marchant ou aux pauses brèves, sans baisse marquée d'énergie en fin de sortie.
4. **Identifier les 10 essentials AMC** dans le sac (eau, en-cas, coupe-vent, carte simple, sifflet, couverture survie, lampe frontale, premier secours basique, téléphone chargé, vêtement chaud) et savoir les utiliser.

Règle d'orientation post-plan : 3+ critères cochés → passer à programme `recreational` hiking (day hikes 4-6 h, D+ 800-1000 m, sac 6-8 kg) ; 2 ou moins → refaire W7+W8 avant de progresser.

**PASS** — exigence ≥ 3-5 critères respectée (4 critères mesurables/observables, alignés sur la cible doctrinale beginner « 5h en autonomie, D+ 500-700m, sac 8kg, gestion ravitaillement, lecture carte basique » — adapté à 2h/500m/5kg pour rester dans la fenêtre beginner-strict). La cible "lecture carte basique" est couverte par le critère #4 (carte simple dans 10 essentials).

## 8. Style

- Français, tutoiement intégral. **PASS.**
- Aucun emoji. **PASS.**
- Vocabulaire technique : `D+`, `D-`, `sac`, `gradient-rolling`, `gradient-moderate`, `pack-light`, `altitude-low`, `Pas du chamois`, `Marche du métronome`, `T1 SAC`, `facile FFRandonnée`, `10 essentials AMC` — tous présents et corrects. **PASS.**
- Sources citées dans `progression_logic` et `safety_notes` (Uphill Athlete House-Johnston, AMC, American Hiking Society, FFRandonnée, Schwameder, Bohne, Stew Smith / GORUCK). Transparence doctrinale solide. **PASS.**
- Notes pédagogiques concises et précises (longueur bâtons, cadence métronome, hydratation chiffrée, ratio glucides:protéines post-sortie). **PASS.**

## Issues summary

### Critical (block merge)

Aucun.

### Important (fix recommended)

Aucun. Le template est solide sur tous les axes vérifiés (doctrine, hooks v2, consistency numérique, cutback, safety, EU MDR, autonomy checklist, style).

### Minor (nice-to-have)

- **DELOAD CHOICE W4 vs W5** : le fragment ligne 314 cite `[5]` comme exemple pour plan 8 sem beginner, mais la doctrine ligne 134 accepte aussi 5-6 build + 1 cutback W4-W5. Le choix W4 (3 build + cutback + 4 progression) est défendable mais pourrait être mentionné dans `progression_logic` comme un choix doctrinal explicite (« cutback positionné W4 plutôt que W5 pour permettre 4 sem de progression post-cutback avec sortie phare W8 »).
- **EXCEPTIONS D+ W1→W2 (+40%) et W4→W5 (+60%)** : déjà bornées et justifiées dans `progression_logic` (« charge absolue très basse », « retour palier proche W3 post-cutback »), donc défendables doctrinalement, mais un coach externe pourrait questionner W4→W5 en particulier (+60% est élevé en valeur relative même si valeur absolue 250→400 m reste accessible). Suggestion mineure : reformuler en « palier de retour à la phase build, équivalent ~115% du pic build pré-cutback W3 (350 m) » pour expliciter l'absence de saut absolu.
- **MENTION WMS NON-APPLICABLE** : le plan ne dépasse jamais 1500 m et n'a pas d'objectif altitude — `safety_notes` ne mentionne donc pas la règle WMS 500 m sleeping/jour > 3000 m, ce qui est correct doctrinalement (fragment l. 337 « WMS altitude rule mention si plan vise un objectif > 2500 m sleeping altitude »). On pourrait ajouter une phrase « Ce plan reste exclusivement en altitude < 1500 m, pas d'enjeu AMS — consulter la doctrine si tu vises un trek > 2500 m post-plan » pour cadrer la transition vers `recreational`. Pas bloquant.
- **PROPRIO CHEVILLE** : `safety_notes` mentionne « single-leg balance » 30 sec/jambe en cooldown dès W3 mais ce drill n'est pas listé dans les S&C dédiés (uniquement dans le texte safety). Soit l'ajouter explicitement dans le S&C de W3+ (ex. en exercice #7 cooldown), soit conserver en safety only — actuellement mention safety only est défendable.

## Sources

- [Uphill Athlete — Training Plans](https://uphillathlete.com/training-plans/)
- [Uphill Athlete — Alpinism Beginner with Steve House (TrainingPeaks)](https://www.trainingpeaks.com/training-plans/other/tp-113525/alpinism-beginner-with-steve-house)
- [American Hiking Society — Planning Your Hike](https://americanhiking.org/planning-your-hike/)
- [AMC — Backpacking for Beginners](https://www.outdoors.org/resources/amc-outdoors/outdoor-resources/backpacking-for-beginners/)
- [AMC — The 10 Essentials Backcountry Hike](https://www.outdoors.org/resources/amc-outdoors/outdoor-resources/the-10-essentials-what-to-pack-for-a-backcountry-hike/)
- [CAF Moselle — Niveaux des sorties en randonnée pédestre](https://cafmoselle.ffcam.fr/niveaux-des-sorties-rando.html)
- [CAF Chambéry — Cotations Randonnée Pédestre](https://www.cafchambery.com/pages/cotations-randonnee-pedestre.html)
- [Stew Smith — Rucking Progression RULES of Rucking](https://www.stewsmithfitness.com/blogs/news/rucking-progression-rules-of-rucking)
- [GORUCK — How To Train for Army Ruck Marches](https://www.goruck.com/blogs/news-stories/ruck-march-standards)
- [Knee joint forces during downhill walking with hiking poles — PubMed (Schwameder)](https://pubmed.ncbi.nlm.nih.gov/10622357/)
- [Effects of hiking downhill using trekking poles while carrying external loads — PubMed (Bohne)](https://pubmed.ncbi.nlm.nih.gov/17218900/)
- [Trekking poles reduce downhill walking-induced muscle damage — PMC](https://pmc.ncbi.nlm.nih.gov/articles/PMC4905913/)
- [WMS Clinical Practice Guidelines Acute Altitude Illness 2024 Update — PubMed](https://pubmed.ncbi.nlm.nih.gov/37833187/) (non-applicable au plan, cité pour cadre doctrinal)
- [Summit Strength — Train For Elevation Gain Without Mountains](https://www.summitstrength.com.au/blog/tft33-how-to-train-for-elevation-gain-hiking-without-any-mountains)

## Recommendation

**APPROVED** — le template est bâti ex nihilo proprement et applique fidèlement la doctrine `hiking.md` Phase C. Tous les axes critiques sont propres :

- **Doctrine** : Uphill Athlete pré-Beginner + AMC + American Hiking Society + Stew Smith rucking civil cités explicitement, volumes/D+/sac dans les fenêtres beginner strictes, altitude < 1500 m exclusivement, intensité Z2 / RPE 4-5 dominante respectée (zéro Z3, zéro hill repeats prématurés).
- **Hooks schema v2** : 100% couverture sur 64 exercices (target_zone, required_equipment, incompatible_constraints, alternatives, volume_axis), 0 alternative vide.
- **Consistency numérique** : volumes annoncés `summary` ↔ `goal` hebdo ↔ JSON exercices match exact 8/8 semaines (105/130/155/115/165/190/210/225 min). Cutback W4 -25.8% dans la fenêtre. Progression sac +1 kg / 2 sem stricte. Lessons learned points #1, #2, #3, #5, #6, #7 du fragment Phase C tous respectés.
- **Safety** : RED FLAGS hiking-beginner exhaustifs (entorse, genou descente, ampoules, hyperthermie/hypothermie), équipement obligatoire, bâtons W3+ avec citation études biomécaniques, MISSED SESSION + OVERLOAD bien cadrés.
- **EU MDR** : 0 mot banni, formulation `consulte un médecin` correcte, profil cible bien borné, 0 framing rééducation.
- **Autonomy checklist W8** : 4 critères mesurables alignés cible doctrinale.
- **Style** : FR / tutoiement / vocabulaire technique D+/D-/sac / 0 emoji.

Patches optionnels (pas bloquants, suggestions de polish post-merge si Sophie veut affiner) :

1. Mentionner explicitement le choix doctrinal cutback W4 vs W5 dans `progression_logic` (1 phrase).
2. Reformuler la justification du saut D+ W4→W5 en valeur absolue (« ~115% du pic pré-cutback ») plutôt qu'en delta % qui paraît élevé.
3. Ajouter une phrase de transition dans `safety_notes` sur l'absence d'enjeu altitude / WMS pour ce plan beginner < 1500 m, et le renvoi à la doctrine si trek > 2500 m post-plan.
4. (optionnel) Ajouter `single-leg balance` 30 sec/jambe en exercice cooldown S&C dès W3 plutôt qu'en safety_notes uniquement.

Le template peut **basculer en bundlable production** en l'état, sans regen ni édition obligatoire.

## Patches applied (2026-05-01)

Les 4 patches Minor optionnels ont été appliqués :

1. **DELOAD CHOICE W4 vs W5 explicite** (`progression_logic` principe 1) : ajouté la phrase « Le cutback est positionné W4 plutôt que W5 (choix doctrinal explicite : cycle 3 build + 1 cutback + 4 sem progression post-cutback avec sortie phare W8, vs alternative 4-5 build + 1 cutback W5-W6 + 2-3 sem progression — le choix W4 maximise la fenêtre de progression post-cutback pour atteindre le pic en W8). »

2. **EXCEPTION D+ W4→W5 reformulée en valeur absolue** (`progression_logic` principe 1) : remplacé « 400 (retour palier proche W3 post-cutback) » par « 400 (palier de retour à la phase build, équivalent ~115% du pic build pré-cutback W3 = 350 m, valeur absolue progressive sans saut au-delà de la fenêtre beginner) ».

3. **Mention WMS non-applicable** (`safety_notes`) : nouvelle section ALTITUDE intercalée entre PROGRESSION D+ HEBDO et INTENSITÉ, précisant que le plan reste exclusivement < 1500 m, pas d'enjeu AMS/HACE/HAPE, et renvoi à la doctrine altitude WMS 2024 si trek > 2500 m post-plan.

4. **Single-leg balance ajouté en cooldown S&C** : applique replace_all sur les 8 cooldowns S&C dédiés, ajoutant « Drill proprio cheville (dès W3) : single-leg balance 30 sec/jambe yeux ouverts puis yeux fermés (prévention entorse, complément du S&C). » L'instruction « dès W3 » est mentionnée dans le texte pour rester aligné à la doctrine et au safety_notes.

**Validation post-patch** :
- JSON parse OK, `duration_weeks == weeks.count` (8 == 8)
- 0 mot banni EU MDR, 0 hook manquant sur 64 exercices, 0 alternative vide
- Hooks intacts, vocabulaire FR/tutoiement/no emojis préservé

**Verdict final** : APPROVED — bundlable production.
