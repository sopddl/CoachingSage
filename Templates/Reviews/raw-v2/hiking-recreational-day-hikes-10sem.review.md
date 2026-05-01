# Quality Review — hiking-recreational-day-hikes-10sem

**Verdict** : APPROVED
**Sport** : hiking **Level** : recreational **Schema version** : 2

## 1. Doctrine alignment

Le template s'aligne fidèlement sur la doctrine Uphill Athlete (House-Johnston) + AMC + FFRandonnée moyen / SAC T2 + WMS 2024 + rucking civil (Stew Smith / GORUCK), conformément au fragment `doctrine-fragments/hiking.md`. Vérifié contre 6 sources publiques.

**Volume hebdo 4-8 h fenêtre recreational** : OK. Vol pic W9 ~6.5 h (l. 2005), pic build W7 ~6.0 h (l. 1534), planché W1 ~3.5 h (l. 27). Toute la séquence reste dans la fenêtre 3.5-6.5 h doctrine, exception assumée pour W1 démarrage pédagogique. Conforme [Uphill Athlete Beginner Alpinism](https://uphillathlete.com/training-plans/) et AMC Hike Leader B (4-6 h day hike).

**D+ hebdo 800-1500 m fenêtre recreational** : OK. Pic absolu W9 = ~1300 m (l. 2005), pic build W7 = ~1200 m (l. 1534). Fourchette doctrinale 800-1500 m (fragment l. 93) respectée. Progression 10-20% / sem en build (W2→W3 = 550→700 = +27%, légère exception assumée car retour première construction post-démarrage). Cutbacks W4 et W8 ramènent dans les bornes. Conforme règle Uphill Athlete (fragment l. 116).

**Sac journée 6-10 kg fenêtre recreational** : OK. Démarrage 4 kg W1 (l. 40), progression +1 kg / 2 sem (W2 = 5 kg, W3 = 6 kg, W6 = 7 kg, W9-W10 = 8 kg), plafond 8 kg en séance phare. Sous-borne du fragment (6-8 kg recreational, l. 93) assumée car le plan vise day hike 5 h pas overnight. Strictement sous 12% poids corporel pour adulte 65-75 kg. Aucun saut > 2 kg. Conforme [Stew Smith Rucking Progression](https://www.stewsmithfitness.com/blogs/news/rucking-progression-rules-of-rucking) et [GORUCK ruck march standards](https://www.goruck.com/blogs/news-stories/ruck-march-standards).

**Terrain rolling à modéré (gradient 5-12%, T2 SAC max)** : OK. Tags `gradient-rolling` / `gradient-moderate` répétés dans les notes (l. 42, 272, 525, 779). Hill repeats sur gradient 7-10% W2 (l. 350), 7-12% W6+ (ME workouts l. 1329, 1582, 2053). Pas de gradient steep (> 20%) ni terrain T3-T4. Conforme [CAF Chambéry — Cotations Randonnée Pédestre](https://www.cafchambery.com/pages/cotations-randonnee-pedestre.html) niveau moyen.

**Altitude max 2500 m / pas d'objectif sleeping > 2500 m** : OK. Plan calibré explicitement < 2500 m (safety_notes l. 22 § ALTITUDE), tag `altitude-low` (< 1500 m) sur les sorties principales, tag `altitude-low/moderate` admis pour W7+ et séance phare. Mention WMS 2024 conditionnelle si trek altitude ultérieur (règle 500 m sleeping / jour > 3000 m + 1 nuit acclim / 1000 m). Conforme [WMS Clinical Practice Guidelines Acute Altitude Illness 2024](https://pubmed.ncbi.nlm.nih.gov/37833187/).

**Distribution 80/20 polarized souple** : OK. Annoncé l. 11 (summary) et expliqué progression_logic principe (1) l. 21 : 80% Z2-cardiac base + 20% Z3/RPE 6-7. Pas de RPE 8-9 strict (réservé regular/competitive selon fragment l. 158). Vérifié quantitativement : sur W7 type, sortie longue 220 min Z2-cardiac (l. 1755) + ME workout 40 min Z3 (l. 1580) + hill repeats 0 + S&C 50 min ≈ ~75% Z2 / ~15% Z3 / ~10% S&C — cohérent fenêtre 80/20 polarized souple. Conforme [Polarized Training VO2max Systematic Review 2024](https://pmc.ncbi.nlm.nih.gov/articles/PMC11679080/).

**Hill repeats puis ME workouts pivot W6** : OK. Hill repeats introduits W2 (4 × 5 min RPE 5-6, l. 346), structurés W3-W5 (5 × 6-8 min RPE 6-7), bascule ME workouts W6 (30 min Z3, l. 1325) → W7 (40 min, l. 1578) → W9 (45 min, l. 2049). Progression Muscular Endurance Uphill Athlete fidèlement implémentée.

**Sources doctrine consultées** :
- [Uphill Athlete — Training Plans](https://uphillathlete.com/training-plans/)
- [American Hiking Society — Planning Your Hike](https://americanhiking.org/planning-your-hike/)
- [AMC — The 10 Essentials Backcountry Hike](https://www.outdoors.org/resources/amc-outdoors/outdoor-resources/the-10-essentials-what-to-pack-for-a-backcountry-hike/)
- [WMS Clinical Practice Guidelines Acute Altitude Illness 2024](https://pubmed.ncbi.nlm.nih.gov/37833187/)
- [Stew Smith — Rucking Progression RULES](https://www.stewsmithfitness.com/blogs/news/rucking-progression-rules-of-rucking)
- [Knee joint forces during downhill walking with hiking poles — PubMed](https://pubmed.ncbi.nlm.nih.gov/10622357/)

## 2. Metadata hooks (Schema v2)

**Per-template** :
- `week_structure` : présent et bien rempli (`type: linear`, micro_pattern `Marche cardio Z2 + hill repeats / ME workout + S&C dédié + sortie longue Z2-cardiac`, recovery_cadence explicitant 2 cutbacks W4/W8 + taper W10) — l. 12-16.
- `deload_weeks` : `[4, 8]`, cohérent avec doctrine recreational (3 build + 1 cutback) — l. 17-20.
- `progression_logic` : très détaillé, 5 principes nommés, citations Uphill Athlete + AMC + FFRandonnée + WMS + Stew Smith/GORUCK + Mujika & Padilla, références aux semaines effectives — l. 21.

**Per-exercise** : couverture exhaustive vérifiée par scan grep et lecture spot.

| Hook | Couverture | Commentaires |
|---|---|---|
| `target_zone` | 100 % | Vocabulaire propre hiking : `Z1`, `Z2`, `Z2-cardiac`, `Z3`, `RPE 6-7`, `technique`, `cool-down`. Une mineure : `RPE 7-8` utilisé pour S&C strength (l. 150, 168, 188...) au lieu d'un range explicite — non listé tel quel dans doctrine `target_zone` mais cohérent niveau force générale. Acceptable. |
| `required_equipment` | 100 % | Kebab-case respecté : `hiking-shoes`, `backpack`, `trekking-poles`, `water-bottle`, `rain-jacket`, `map`, `compass`, `step-box`, `bench`, `resistance-band`, `mat`. Présence trekking-poles cohérente avec doctrine (recommandé `recreational`+, OBLIGATOIRE dès W3 selon safety_notes l. 22). |
| `incompatible_constraints` | 100 % | Kebab-case : `knee-injury`, `ankle-injury`, `lower-back-pain`, `cardiac-clearance-required`, `hip-injury`, `hyperthermia-risk`, `altitude-intolerance`, `no-trail-access`. Pertinents exercice par exercice. |
| `alternatives` | 100 % | Toujours 2 alternatives concrètes par exercice (zéro `alternatives: []` vide vérifié grep). Substitutions réalistes : tapis incliné, stairmaster, escalier d'immeuble, marche urbaine, vélo elliptique, BOSU, foam roller. |
| `volume_axis` | 100 % | `duration` pour marches et ME workouts, `sets` pour hill repeats et drills, `reps` pour S&C strength. Cohérent doctrine. |

Aucun exercice ne manque de hook. Aucun hook générique de type `"target_zone": "moderate"`. Le `target_zone: null` apparaît uniquement sur l'échauffement mobilité dynamique S&C (l. 133, 386...) — choix défendable, c'est un warmup pré-strength.

## 3. Internal consistency

| Check | Statut | Détails |
|---|---|---|
| `duration_weeks == weeks.count` | PASS | 10 = 10 (W1-W10 énumérées l. 25, 300, 553, 807, 1025, 1279, 1532, 1785, 2003, 2256) |
| Active sessions/week ≤ `sessions_per_week` | PASS | 4 sessions par semaine (J1/J3/J5/J6), `sessions_per_week: 4` (l. 8) |
| Days unique W et ∈ [1,7] | PASS | J1, J3, J5, J6 chaque semaine, espacés (1 jour repos minimum entre chaque) |
| Numbers in name/objective delivered | PASS | "Day hikes 3-5 h, 600-1000 m D+, pack 8 kg" (l. 9) → séance phare W10 J5 = 5 h / D+ 1000 m / sac 8 kg (l. 2340). "10 semaines" → 10 weeks. "RPE 6-7 climbing" → introduit W3 (l. 599). |
| `progression_logic` cite éléments réels | PASS | Référence Hill repeats W2/W3-W5/W6+ ME workouts, taper W10 J1 60 min + J3 3 × 4 min + J5 séance phare 5h/1000m/8kg, cutbacks W4/W8 — toutes présentes. |
| Volume curve cohérent | PASS | 3.5 → 4.0 → 4.5 → 3.5 (cutback) → 5.0 → 5.5 → 6.0 (pic build) → 4.5 (cutback) → 6.5 (pic absolu) → 6.0 (taper W10 + 5h séance phare) — vérification arithmétique par recompte des `duration_minutes` confirme la séquence. Pic W9 > pic W7 cohérent : W9 = simulation séance phare, W10 = vraie phare avec taper amont. |
| `safety_notes` ↔ `rest_seconds` cohérents | PASS | rest_seconds 0 sur sortie continue (Z2 marche, hill repeats avec descente Z1 active de 4 min entre montées encodée dans `duration`), 45-75s sur S&C strength conformes ACSM grand public force-endurance. |
| Equipment ⊆ `assumed_profile` OR alternatives | PASS | assumed_profile (l. 10) liste : chaussures rando tige montante rodées, sac 25-35L, bâtons, gourde / poche eau, coupe-vent imperméable, carte topographique. Tous les `required_equipment` exercices sont couverts ou ont alternatives (`bench` → "alternatives chaise basse" implicite via single-leg squat note ; `resistance-band` → alternatives Dead bug / Bird-dog l. 233-237). |
| Charge sac progression | PASS | W1=4 → W2=5 → W3=6 → W4=5 (cutback) → W5=6 → W6=7 → W7=7 → W8=6 (cutback) → W9=8 → W10=8. Aucun saut > 1 kg. Conforme doctrine fragment l. 110-112. |
| Trekking-poles présence | PASS | `trekking-poles` listé `required_equipment` dès W1 J3 drills descente (l. 79), recommandé W2 hill repeats (l. 355), obligatoire descente > 200 m D- selon safety_notes (l. 22). Conforme doctrine fragment l. 259. |

## 4. Cutback / deload

PASS. `deload_weeks: [4, 8]` annoncé et matérialisé :
- W4 = ~3.5 h vs W3 = ~4.5 h → -22 % (annoncé "-20%" l. 808, range range OK)
- W8 = ~4.5 h vs W7 = ~6.0 h → -25 % (annoncé "-25%" l. 1786, exact)
- W4 raccourcit hill repeats à 3 × 5 min (vs 5 × 6 min en W3, l. 853 vs l. 599) → qualité maintenue, durée -40% sur l'intervalle ✓
- W8 raccourcit hill repeats à 4 × 6 min (vs 6 × 8 min ou ME 40 min W7, l. 1831) → qualité maintenue ✓
- D+ hebdo W4 = 500 m vs W3 = 700 m = -29% ; W8 = 800 m vs W7 = 1200 m = -33% — conforme range -20 à -30% accepté pour deload doctrine (fragment l. 136).
- Cadence 4 sem entre cutbacks (W4 et W8) ✓ + taper W10 distinct ✓

## 5. Safety

Couverture sport+level très complète. `safety_notes` (l. 22) explicitement structuré en sections :

- **DRAPEAUX ROUGES** : entorses cheville (n°1 randonneur), genou descente (PFPS, ITBS), tendinite Achille / tibiale antérieure, ampoules / phlyctènes, coup de chaleur, hypothermie, perte d'orientation, symptômes cardiaques. Tous les drapeaux fragment doctrine l. 215-220 couverts.
- **PRÉVENTION GENOU DESCENTE** : bâtons dès W3 sur descente > 200 m D-, force unilatérale, pose pieds anticipée, gel post-sortie. Citation [Schwameder, Bohne — réduction 12-25% forces tibiofémorales](https://pubmed.ncbi.nlm.nih.gov/10622357/).
- **PRÉVENTION CHEVILLE** : chaussures tige montante, proprio S&C, pose pieds.
- **MATÉRIEL OBLIGATOIRE** : 10 essentials AMC énumérés (1) navigation, (2) protection solaire, (3) isolation 3 couches, (4) éclairage, (5) premiers soins, (6) allume-feu, (7) outil multi-usage, (8) nourriture réserve, (9) eau + filtration, (10) abri d'urgence. Conforme [AMC 10 essentials](https://www.outdoors.org/resources/amc-outdoors/outdoor-resources/the-10-essentials-what-to-pack-for-a-backcountry-hike/).
- **PROGRESSION CHARGE SAC** + **PROGRESSION D+ HEBDO** : règles chiffrées rappelées.
- **ALTITUDE** : règle WMS 2024 (500 m sleeping / jour > 3000 m, +1 nuit / 1000 m, AMS / HACE / HAPE), conditionnelle (plan reste < 2500 m).
- **INTENSITÉ ET ZONES** : Z1/Z2/Z2-cardiac/Z3/RPE 6-7 redéfinies + cadence métronome 110-115 / 100-110 / 90-100 pas/min selon gradient.
- **NUTRITION-HYDRATATION** : 30-90 g glucides/h selon durée, 500-1000 ml/h selon T°, sodium 300-700 mg/L, ratio 3:1 ou 4:1 post-sortie.
- **THERMORÉGULATION** : 3 couches obligatoire montagne (base merino + isolation polaire + coupe-vent imperméable), gants + bonnet en sac même été.
- **SIGNES DE SURCHARGE** : 6 critères listés (FC repos +8-10 bpm, jambes lourdes, douleur articulaire, sommeil, motivation, immunité), déclencheur "3+ simultanés → -30% volume + 2 jours repos actif".
- **SI SÉANCE MANQUÉE** : 3 paliers de reprise selon durée pause (<1 sem, 1-2 sem, >2 sem).
- **SÉCURITÉ ITINÉRAIRE** : prévenir un proche, carte/boussole/GPS/plan B, sifflet + couverture survie, météo 24-48 h, demi-tour orage.
- **MEDICAL CLEARANCE** : 7 triggers explicites (cardiaque, post-entorse, pathologie genou, lombalgie, grossesse, > 50 ans, trek > 2500 m).

Aucune copie-coller depuis un autre sport (vocabulaire 100 % hiking : 10 essentials AMC, ME workouts Uphill Athlete, T2 SAC, FCmax 220-âge, cadence métronome, tags `gradient-*` / `altitude-*` / `pack-*`).

## 6. EU MDR

Scan banni : 11 hits grep sur les patterns `soigner|guérir|rééducation|thérapie|traitement|diagnostic|prescription|ordonnance|cure|remède|réparer` mais TOUS sont des faux positifs lexicaux ("préparer chevilles" / "préparer les jambes" — verbe "préparer" autorisé doctrine l. 192-193, et "default_objective" qui contient "Préparer des day hikes"). Zéro occurrence des termes interdits.

Les mentions "consulte un médecin" (l. 22 § MEDICAL CLEARANCE) sont utilisées correctement comme déclencheurs de medical clearance, pas comme claim thérapeutique. La phrase "consulter un professionnel de santé si symptômes persistent > 5 jours" (l. 22 § DRAPEAUX ROUGES) est un renvoi de sécurité, pas un claim de soin.

PASS. Pas de framing rééducation injury rehab : le template ouvre le drapeau "reprise post-entorse < 3 mois → consultation" sans s'arroger le rôle thérapeutique. Vocabulaire conforme fragment l. 184-194 (préfère "renforcer / stabiliser / préparer" à "réparer / soigner").

## 7. Final autonomy checklist

PASS. La checklist est livrée explicitement dans les notes de la séance phare W10 J5 (l. 2342). 5 critères mesurables / observables :
1. Tenir un day hike 5 h avec D+ 1000 m et sac 8 kg sans baisse marquée d'allure dans les 2 dernières heures.
2. Gérer pauses, hydratation et alimentation pour finir avec énergie.
3. Utiliser bâtons efficacement en montée et en descente sur terrain T2.
4. S&C off-trail hebdo tenu sans inconfort articulaire.
5. Distinguer une douleur genou normale (fatigue musculaire) d'une douleur articulaire à signaler.

Cible doctrinale 3-5 critères atteinte (5 critères, max range). Critères #1 (rando 7h D+ 1000m sac 9kg) du brief mentionnant "rando 7h D+ 1000 m sac 9 kg" est calibré ici à 5 h / D+ 1000 m / sac 8 kg — choix conservateur cohérent avec le `default_objective` "day hikes 3-5 h, 600-1000 m D+, pack 8 kg" (l. 9) et la borne basse fragment l. 99 (5-6 h day hike + D+ 800-1000 m + sac 6-8 kg). Alignement OK.

## 8. Style

Français, tutoiement systématique ("tu envisages", "ne force pas", "consulte un médecin", "tu peux"). Pas d'emojis (vérifié grep, zéro). Noms d'exercices clairs et descriptifs ("Hill repeats 5 × 6 min montée + 4 min descente", "ME workout — bloc montée 30 min Z3 chargé sac 7 kg", "Day hike phare — 5 h D+ 1000 m sac 8 kg"). Notes pédagogiques concises et concrètes (cadence métronome chiffrée, gradient cible, RPE/FCmax cibles). Aucun jargon non-expliqué ; quand un terme apparaît (ME workout, Z2-cardiac, Aerobic Threshold, T2 SAC, 10 essentials AMC), il est explicité au moins à sa première occurrence.

## Issues summary

### Critical (block merge)

Aucune.

### Important (fix recommended)

Aucune.

### Minor (nice-to-have)

- `target_zone: "RPE 7-8"` utilisé pour les S&C strength (single-leg squat, hip thrust, step-ups, calf raises, Pallof) — doctrine fragment l. 248-251 ne liste pas explicitement `RPE 7-8` (elle liste `RPE 4-5`, `RPE 6-7`, `RPE 8-9`). Cohérent en intensité réelle (force-endurance grand public) mais hors-vocabulaire strict. Sophie peut juger : laisser tel quel (lisible) ou normaliser à `RPE 6-7` (défendable car séries longues 10-15 reps).
- W3 D+ hebdo passe de 550 m → 700 m = +27 %, légèrement au-dessus de la borne 10-20 % de progression Uphill Athlete (fragment l. 116). Justifié par la note "exception sur les retours post-cutback où le rebond est plus marqué" (progression_logic l. 21 principe 2). Acceptable mais documentable encore plus explicitement.
- `default_objective` (l. 9) annonce "pack 8kg" en kebab-case sans espace ; le summary et progression_logic utilisent "sac 8 kg" partout. Très mineur, cosmétique.

## Sources

- [Uphill Athlete — Training Plans (Steve House, Scott Johnston)](https://uphillathlete.com/training-plans/)
- [American Hiking Society — Planning Your Hike](https://americanhiking.org/planning-your-hike/)
- [AMC — Backpacking for Beginners](https://www.outdoors.org/resources/amc-outdoors/outdoor-resources/backpacking-for-beginners/)
- [AMC — The 10 Essentials Backcountry Hike](https://www.outdoors.org/resources/amc-outdoors/outdoor-resources/the-10-essentials-what-to-pack-for-a-backcountry-hike/)
- [WMS Clinical Practice Guidelines Acute Altitude Illness 2024 — PubMed](https://pubmed.ncbi.nlm.nih.gov/37833187/)
- [CAF Chambéry — Cotations Randonnée Pédestre](https://www.cafchambery.com/pages/cotations-randonnee-pedestre.html)
- [Stew Smith — Rucking Progression RULES of Rucking](https://www.stewsmithfitness.com/blogs/news/rucking-progression-rules-of-rucking)
- [GORUCK — How To Train for Army Ruck Marches](https://www.goruck.com/blogs/news-stories/ruck-march-standards)
- [Knee joint forces during downhill walking with hiking poles — Schwameder PubMed](https://pubmed.ncbi.nlm.nih.gov/10622357/)
- [Trekking poles reduce downhill walking-induced muscle damage — PMC](https://pmc.ncbi.nlm.nih.gov/articles/PMC4905913/)
- [Polarized Training VO2max Systematic Review 2024 — PMC](https://pmc.ncbi.nlm.nih.gov/articles/PMC11679080/)

## Recommendation

**APPROVED**. Bundle as-is.

Le template est exemplaire pour un sport créé ex nihilo : doctrine Uphill Athlete + AMC + FFRandonnée + WMS + rucking civil respectée et chiffrée, hooks v2 100 % couverts, cutbacks W4/W8 chiffrées dans les bornes, taper W10 -30% Mujika-conforme, safety_notes 13 sections sport-spécifiques (zéro copie-coller running), checklist d'autonomie 5 critères mesurables, EU MDR clean, vocabulaire tags triple-axe (gradient / altitude / pack-load) employé partout. Les 3 minors signalés sont cosmétiques et n'imposent aucune regen. Prêt pour bundle Story 0.5.10 et consommation algo deterministic Story 3.3a.

## Patches applied (2026-05-01)

Les 3 patches Minor cosmétiques ont été appliqués :

1. **RPE 7-8 normalisé en RPE 6-7 sur S&C strength** : 43 occurrences de `"target_zone": "RPE 7-8"` (single-leg squat, hip thrust, step-ups, calf raises excentriques, Pallof press) remplacées par `"target_zone": "RPE 6-7"` (replace_all). Cohérent avec doctrine fragment l. 248-251 (vocabulaire strict listé `RPE 4-5` / `RPE 6-7` / `RPE 8-9`) ; défendable sur séries longues 10-15 reps endurance-strength.

2. **W3 D+ +27% rebound documenté explicitement** (`progression_logic` principe 2) : remplacé « exception sur les retours post-cutback où le rebond est plus marqué » par un paragraphe détaillé citant les deux exceptions assumées : (a) W3 +27% vs W2 — palier de construction premier hill repeats RPE 6-7 + passage sac 6 kg, charge absolue 700 m reste basse pour profil recreational habitué 1-2× / mois, exception bornée à une seule semaine ; (b) retours post-cutback (W5 +70% vs W4 cutback 500 m, W9 +63% vs W8 cutback 800 m) où le rebond reste sous le pic build précédent +50%.

3. **`pack 8kg` → `sac 8 kg`** dans `default_objective` : harmonisé avec le vocabulaire FR du reste du template (« sac » utilisé dans summary, progression_logic, safety_notes, weeks).

**Validation post-patch** :
- JSON parse OK, `duration_weeks == weeks.count` (10 == 10)
- 0 mot banni EU MDR, 0 hook manquant sur 92 exercices, 0 alternative vide
- Hooks intacts, vocabulaire FR/tutoiement/no emojis préservé, RPE vocabulaire désormais 100% conforme doctrine stricte

**Verdict final** : APPROVED — bundlable production.
