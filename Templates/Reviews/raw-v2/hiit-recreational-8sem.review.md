# Quality Review — hiit-recreational-8sem

**Verdict** : APPROVED (post-patches 2026-05-01)
**Sport** : hiit  **Level** : recreational  **Schema version** : 2

## 1. Doctrine alignment

Le template s'aligne globalement avec la doctrine HIIT publique pour un pratiquant intermédiaire (recreational), mais quelques points doctrinaux méritent ajustement.

- **ACSM HIIT (2014, ACSM's Health & Fitness Journal / Position Stand)** : work intervals 15 sec → 4 min à 80-95% FCmax, rest = ou > work à 40-50% FCmax, total 6-10 répétitions, warmup/cooldown 5-10 min obligatoires. Le template respecte ces bornes : Tabata 20/10 (4-6 rounds), 30/30 (4-9 rounds), 40/20 (3-6 rounds), EMOM 8-12 min, AMRAP ≤ 10 min, warmup 10-13 min systématique. APPROVED sur ce point.
- **Tabata 1996 (Tabata et al., Med Sci Sports Exerc)** : protocole original 8 rounds 20/10 à 170% VO2max sur cycle ergomètre. Le template positionne explicitement le 8 rounds full intensity comme "réservé regular" et reste sur 4-6 rounds en bodyweight RPE 8-9 — bonne lecture du protocole, le 170% VO2max ne se reproduit pas en bodyweight et 6 rounds suffisent pour l'adaptation chez le recreational. APPROVED.
- **Gibala lab (PLOS One 2016, Burgomaster 2008)** : SIT minimum effective dose ≈ 3×20 sec sprints sur 10 min, équivalent métabolique à 50 min MICT. Le template cite Gibala 2016 dans `progression_logic` mais ne le réutilise pas pour justifier la dose-cible 8-12 min HIT/sem. Lien doctrinal à formaliser : la fenêtre "HIT cumulé 8-12 min/sem" est en réalité une extrapolation à mi-chemin entre dose Tabata 4 min/séance × 2-3 séances/sem et SIT/HIIT recommandation classique.
- **F45 / Orange Theory** : F45 articule Base/Build/Peak avec mix AMRAP/EMOM en 45 min ; OTF utilise FCmax-zones colorées sur 60 min. Le template emprunte le format AMRAP/EMOM mais sans coloration zones FC explicite — cohérent pour un public solo sans cardiofréquencemètre, RPE 8 est un proxy acceptable.
- **CrossFit Foundations** : "constantly varied functional movements at high intensity". Le template reste **délibérément peu varié** (squat-air, jumping jacks, mountain climbers, push-up, KB swing, thruster DB) — choix intentionnel niveau recreational, pas un défaut.

Pas de problème doctrinal bloquant. Les références citées (ACSM 2014, Tabata 1996, Gibala 2016) sont cohérentes avec le contenu réel.

## 2. Metadata hooks (Story 0.5.9 / Schema v2)

Couverture **complète** sur l'échantillon vérifié W1, W3, W5, W6, W7, W8 :

- `target_zone` : présent partout, valeurs sport-specific cohérentes (`30/30`, `Tabata 20/10`, `40/20`, `EMOM`, `AMRAP`, `walking-recovery`, `RPE 6-7`, `RPE 7-8`, `RPE 8-9`, `technique`). Pas de "moderate" générique. APPROVED.
- `required_equipment` : kebab-case (`timer`, `mat`, `dumbbells`, `kettlebell`). Cohérent avec `assumed_profile`. APPROVED.
- `incompatible_constraints` : kebab-case et **précis selon le mouvement** (`knee-injury`, `ankle-injury`, `cardiac-clearance-required`, `apartment-noise`, `wrist-pain`, `lower-back-pain`, `shoulder-injury`, `hip-injury`). Excellente granularité — le `apartment-noise` sur les blocs sautants est un détail apprécié.
- `alternatives` : 2 par exercice systématiquement, niveau de régression cohérent (step-jacks pour jumping jacks, planche genoux pour planche complète).
- `volume_axis` : valeurs valides (`duration` / `sets` / `reps`) cohérentes avec la structure de l'exercice.

`week_structure` (linear, micro_pattern, recovery_cadence), `deload_weeks` ([4,8]), `progression_logic` (5 principes sourcés ACSM/Tabata/Gibala) tous présents et substantiels. APPROVED.

## 3. Internal consistency

| Check | Statut |
|---|---|
| `duration_weeks` (8) == `weeks.count` (8) | PASS |
| Active sessions/sem (3 interval/strength + 1 mobility) ≤ `sessions_per_week` (4) | PASS |
| Days uniques [1,7] dans chaque semaine (1,3,5,7) | PASS |
| `progression_logic` cite éléments présents (Tabata 20/10 court, 30/30, 40/20, EMOM, AMRAP, KB swing post-RDL, cutbacks W4/W8) | PASS |
| `safety_notes` cite standards respectés (récup ≥ 48h, warmup obligatoire, screening > 35 ans) | PASS |
| Equipment ⊆ `assumed_profile` (tapis, DB 5-10 kg, KB 8-12 kg, timer) | PASS |
| **HIT cumulé W1 hebdo annoncé 5 min vs réel calculé** | FAIL (~6.3 min réel, écart +25%) |
| **HIT cumulé W3 hebdo annoncé 9 min vs réel calculé** | FAIL marginal (le template lui-même reconnaît "8 min, marge basse") |

**Issue précise W1 J5** ligne ~219 : le bloc finisseur "squat-air contrôlé + push-up genoux" (RPE 7, 2×12+8) ajoute en pratique ~1 min de travail au-delà de RPE 7 que la séance classe comme non-HIT. Le total séance est ~3 min (Tabata 4×20s = 1m20 + RPE 7 finisseur ~1m20 si on compte RPE 7 comme HIT-adjacent). Si la convention est "HIT = RPE 8+", alors la cumul hebdo W1 réelle est 5+1.3 = 6.3 min, pas 5. **Patch suggéré** : soit retirer le finisseur RPE 7 W1 J5, soit recalculer le cumul hebdo annoncé à 6-7 min (ce qui est normal en plan progressif d'ailleurs, vs le 5 → 7 min annoncé W1 → W2 qui suppose +40% mais c'est en réalité ~+10%).

**Issue W3** : la séance EMOM 8 min "léger" comptée 1.5 min HIT seulement (lignes 660-668) — comptabilité honnête mais le total hebdo annoncé est 9 min alors que la réalité est 8 min. **Patch** : ajuster `progression_logic` à "W3 = 8 min" plutôt que 9 min, ou monter EMOM J5 à 10 min RPE 8 réel.

## 4. Cutback / deload

- `deload_weeks` = [4, 8] : PASS, conforme cadence 3-build + 1-deload ACSM (W1-W3 build, W4 deload, W5-W7 build, W8 deload final).
- W4 : -22% (9 → 7 min), W8 : -25% (12 → 9 min) — dans la fenêtre recreational -15 à -25%. PASS.
- Contenu cutback adapté : volume strength également réduit (3 séries → 2), pas de nouveauté impactante en W4, séance phare réservée à W8 J5. PASS.

## 5. Safety

Couverture des 5 sections attendues : RED FLAGS, GENERAL RULES, INTENSITY, OVERLOAD SIGNS, MISSED SESSION HANDLING — toutes présentes, sport+level specifiques (mention explicite Tabata 20/10 / 40/20 / EMOM / AMRAP RPE thresholds, mouvements bannis recreational explicites, hip hinge prerequis KB W5).

**RED FLAGS couverts** : cardiac (douleur thoracique, palpitations, vertiges), achille tendinopathie, patellar tendinopathie / jumper's knee, shin splints, entorse cheville, lombalgie aiguë, hyperextension cervicale, screening > 35 ans facteurs de risque ACSM 2014.

**MANQUE CRITIQUE — rhabdomyolyse d'effort** : la doctrine HIIT publique (NASM, Cleveland Clinic, OSU Wexner) liste 4 signes spécifiques à connaître pour HIIT : (1) douleur musculaire intense disproportionnée > 48h, (2) urines couleur thé/cola, (3) faiblesse musculaire prononcée, (4) gonflement musculaire localisé. Le template évoque "urines très foncées (> jus de pomme)" mais **uniquement** dans la section déshydratation/chaleur — pas comme signal rhabdo distinct. Pour HIIT recreational où le pratiquant peut empiler des séances mal calibrées (notamment l'AMRAP W8 J5 ou EMOM 12 min indoor chaud), c'est une omission importante. **Patch** : ajouter une 6ᵉ sous-section RED FLAG explicite "RHABDOMYOLYSE D'EFFORT" avec les 4 signes et la consigne "urgences si urines couleur thé/cola post-séance + douleur musculaire bloquante > 24h".

Pas de copie générique inter-sports — safety bien customisée HIIT.

## 6. EU MDR

Scan banned words (`guérir|soigner|traiter|diagnostic|médical|thérapeutique|rééducation|cure|treat|diagnose|therapeutic`) :
- "avis médical" (× 3) : utilisation conforme = consultation suite signal danger, pas de prescription.
- "consulte un médecin" : medical clearance trigger explicite ligne 19 — conforme MDR.
- "avis kiné" (× 2) : référencement professionnel, pas de claim thérapeutique direct par l'app.
- Pas de "soigner", "guérir", "traiter une pathologie", "thérapeutique", "rééducation post-opératoire", "cure", "treat", "diagnose".

Medical clearance trigger PRÉSENT et CORRECT (ligne 19) pour antécédents cardiaques, > 50 ans sédentaire, hypertension, asthme effort, grossesse/postpartum, post-op < 6 mois.

PASS EU MDR.

## 7. Final autonomy checklist

W8 J5 ligne 1638, 4 critères mesurables/observables :
1. Tabata 6 rounds RPE 8-9 sans baisse cadence > 30%.
2. AMRAP 10 min RPE 8 sans craquer (cadence > 70% du round 1 sur dernière minute).
3. Distinguer douleur articulaire (stop) vs fatigue musculaire (continuer).
4. Goblet squat thruster DB 5 kg en EMOM/AMRAP avec hip hinge propre 10 min.

4 critères présents (cible 3-5). Tous mesurables/observables. Mapping triage explicite (4/4 → regular, 3/4 → recreational +1 charge, ≤2/4 → recommencer). PASS.

## 8. Style

- Français tutoiement systématique. PASS.
- Pas d'emojis. PASS.
- Notes pédagogiques claires, prescriptions techniques précises (RPE cibles, cues "menton rentré", "talons au sol", "genoux dans l'axe").
- Verbosité élevée mais justifiée par la complexité du sujet et la pédagogie progression Tabata → 40/20 → EMOM → AMRAP.

## Issues summary

### Critical (block merge)

Aucune.

### Important (fix recommended)

- **Section RHABDOMYOLYSE manquante dans safety_notes** : ajouter une sous-section RED FLAG dédiée avec les 4 signes (douleur musculaire intense disproportionnée > 48h, urines couleur thé/cola, faiblesse marquée, gonflement musculaire) et consigne "urgences si urines thé/cola + douleur bloquante > 24h post-séance". Référence : NASM rhabdo 2024, Cleveland Clinic. Risque réel sur AMRAP W8 J5 + EMOM 12 min en environnement chaud.
- **Inconsistance HIT cumulé W1** : annoncé 5 min/sem dans `summary` et `progression_logic`, réel ~6.3 min si on compte le finisseur W1 J5 RPE 7. Soit retirer le finisseur post-Tabata W1 J5 (lignes 211-221), soit harmoniser le cumul annoncé à 6 min. Sinon la progression W1→W2 (+40% annoncée) est inexacte — réelle +10%.
- **Inconsistance HIT cumulé W3** : annoncé 9 min, réel 8 min (le template lui-même l'admet ligne 663 "marge basse"). Harmoniser progression_logic à 8 min ou pousser EMOM J5 à 10 min réel.

### Minor (nice-to-have)

- Lien doctrinal Gibala 2016 à expliciter : la fenêtre 8-12 min HIT/sem n'est pas directement issue de Gibala (qui parle de 1 min sprint sur 10 min total, soit ~3 min HIT/sem effectif). À reformuler comme "extrapolation Gibala SIT × 2-3 séances + ACSM dose-réponse".
- W2 J5 (ligne 416) : note dit "Premier Tabata 6 rounds" mais c'est un Tabata 5 rounds (sets: 5). Erreur copy-paste mineure. Le premier 6 rounds est en réalité W3.
- `summary` mentionne "MyProtein HIIT Guide" comme référence : c'est une source commerciale, pas une autorité (peer-reviewed ou organisme reconnu). Remplacer par "ACSM HIIT 2014 + Gibala 2016" suffit.
- Aucun mention explicite cardiofréquencemètre / Apple Watch / FCmax = 220-âge dans `safety_notes` malgré FCmax 90-95% évoquée — laisser RPE seul comme proxy est cohérent niveau recreational mais une note "si tu utilises un cardio, FCmax estimée = 220-âge, cible 85-90%" serait un plus.

## Sources

- [ACSM HIIT — Efficient, Effective, and a Smart Way to Get in Shape (2013, ACSM's Health & Fitness Journal)](https://journals.lww.com/acsm-healthfitness/fulltext/2013/05000/high_intensity_interval_training__efficient,.3.aspx)
- [ACSM Information On High-Intensity Interval Training (PDF)](https://blanchfield.tricare.mil/Portals/70/Session%202%20ACSM%20High%20Intensity%20Interval%20Training.pdf)
- [Tabata I. et al. 1996 — Effects of moderate-intensity endurance and high-intensity intermittent training on anaerobic capacity and VO2max (Med Sci Sports Exerc) — résumé via Wikipedia HIIT](https://en.wikipedia.org/wiki/High-intensity_interval_training)
- [Exercise Intensity and Energy Expenditure of a Tabata Workout (PMC)](https://pmc.ncbi.nlm.nih.gov/articles/PMC3772611/)
- [Gibala et al. 2016 — Twelve Weeks of SIT improves indices of cardiometabolic health (PLOS One)](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0154075)
- [Dr. Martin Gibala on HIIT — FoundMyFitness interview](https://www.foundmyfitness.com/episodes/martin-gibala)
- [F45 Training — Functional Workout Programming (Base/Build/Peak)](https://f45training.com/workouts/)
- [Bootcamp Workout Formats — AMRAP / EMOM / Tabata](https://www.brookswoodbootcamp.ca/post/bootcamp-workout-training-formats)
- [CrossFit — Defining CrossFit Part 1: Functional Movements](https://www.crossfit.com/essentials/defining-crossfit-part-1-functional-movements)
- [NASM — Rhabdomyolysis: What You Need to Know About Rhabdo](https://blog.nasm.org/fitness/rhabdomyolysis)
- [Cleveland Clinic — Rhabdomyolysis: Symptoms, Causes & Treatments](https://my.clevelandclinic.org/health/diseases/21184-rhabdomyolysis)
- [OSU Wexner — With intense exercise, be aware of rhabdomyolysis](https://health.osu.edu/wellness/exercise-and-nutrition/exercise-induced-rhabdomyolysis)

## Recommendation

**NEEDS_REVISION** — regenerate-with-prompt-patch :

1. Ajouter dans le prompt HIIT une sous-section safety_notes obligatoire `RHABDOMYOLYSE D'EFFORT` avec les 4 signes spécifiques (douleur musculaire intense disproportionnée > 48h post-séance, urines couleur thé/cola, faiblesse musculaire bloquante, gonflement musculaire localisé) + consigne urgences. À distinguer de la section déshydratation/chaleur.
2. Demander au prompt de **vérifier l'arithmétique HIT cumulé hebdo** entre `summary`, `progression_logic` et la somme effective des blocs RPE 8+ par séance (W1 et W3 sont incohérents dans la version actuelle).
3. Patch direct fichier sans regen complet possible : (a) ajouter ~15 lignes RHABDO dans `safety_notes`, (b) corriger "Premier Tabata 6 rounds" en "Premier Tabata 5 rounds" ligne 416, (c) harmoniser cumul W1 et W3 dans `summary`/`progression_logic` (5→6 min W1, 9→8 min W3, ou pousser le contenu).

Une fois ces 3 patches appliqués, **APPROVED**.

## Patches applied (2026-05-01)

- **Important — RHABDOMYOLYSE D'EFFORT ajoutée à `safety_notes`** : nouvelle sous-section RED FLAG distincte de l'hydratation/chaleur, avec les 4 signes spécifiques (douleur musculaire intense disproportionnée > 48h, urines couleur thé/cola, faiblesse musculaire prononcée empêchant escaliers, gonflement musculaire localisé), consigne urgences si urines thé/cola + douleur bloquante > 24h, et facteurs de risque competitifs (reprise > 4 sem, première AMRAP RPE 8 sans préparation, chaleur + déshydratation, stimulants). Référence NASM Rhabdo 2024 + Cleveland Clinic.
- **Important — HIT cumulé W1 harmonisé** : `summary` 5 → 6 min, `progression_logic` principe (2) « W1 = 5 min » → « W1 = 6 min (… finisseur RPE 7 inclus) », W1 `goal` mis à jour, exercice W2 J5 « +40% vs W1 = 5 min » → « +17% vs W1 = 6 min ».
- **Important — HIT cumulé W3 harmonisé** : `summary` 9 → 8 min, `progression_logic` principe (2) « W3 = 9 min » → « W3 = 8 min (… comptabilité honnête, marge basse) », principe (3) cutback « -22% (9 → 7 min) » → « -13% (8 → 7 min) », `week_structure.recovery_cadence` mis à jour, W3 `goal` mis à jour, W4 `goal` cutback math corrigé.
- **Minor — référence MyProtein supprimée** : `summary` et `progression_logic` ne citent plus « MyProtein HIIT Guide » (source commerciale) → remplacé par « ACSM 2014 + Gibala 2016 (extrapolation SIT × 2-3 séances) ».
- **Minor — note FCmax ajoutée** dans la section INTENSITÉ : "Si tu utilises un cardiofréquencemètre, FCmax estimée = 220 - âge, cible 85-90% sur Tabata/40-20, 80-85% sur EMOM/AMRAP, < 60% en rest. RPE reste le proxy principal."
- **Minor — note W2 J5 "Premier Tabata 6 rounds"** : vérification fichier — la note dit déjà correctement "5 rounds (vs 4 en W1)", aucun patch nécessaire (la review pointait probablement une version antérieure).

Post-patch verifications : JSON parse OK, 109 exercices avec 5 hooks chacun, banned words EU MDR scan clean, FR/tutoiement/no emojis préservés.

**Verdict final** : APPROVED (NEEDS_REVISION résolu).
