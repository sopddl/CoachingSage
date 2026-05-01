# Quality Review — hiit-beginner-6sem

**Verdict** : APPROVED (post-patches 2026-05-01)
**Sport** : hiit  **Level** : beginner  **Schema version** : 2

## 1. Doctrine alignment

Le template s'aligne avec rigueur sur la doctrine HIIT débutant publique. Les choix sont sourcés et explicables :

- **Ratios work/rest doux d'abord (30/60 ratio 1:2 puis 30/30 ratio 1:1, JAMAIS 20/10)**. La position ACSM 2014 décrit des intervalles de 15 sec à 4 min entre 80-95% FCmax, avec récupération typiquement « égale ou plus longue que le work ». Le ratio 1:2 (W1-W3) puis 1:1 (W5-W6) RPE 7-8 puis RPE 8 respecte exactement cette enveloppe sans s'aventurer dans le Tabata strict (ratio 1:0.5, 170% VO2max), explicitement réservé aux niveaux supérieurs dans le `safety_notes`. Cohérent avec l'étude Tabata 1996 (sujets entraînés, vélo ergomètre, pas grand public débutant).
- **Volume hebdo 4 → 8 min HIT cumulé**. Cible alignée avec le « one-minute workout » de Gibala (3 × 20 s à très haute intensité dans une session 10 min), et avec le Gibala Practical-HIT (10 × 60 s à 90% FCmax = 10 min de HIT cumulé) destiné aux sédentaires. La fenêtre 4-8 min/sem du template est volontairement plus douce que Gibala — cohérent pour un public « sédentaire ou peu actif sans antécédent cardiaque ».
- **3 séances/semaine, 25-35 min, J1/J3/J5**. Conforme à la guidance NHS HIIT (« 20-30 min, 3 fois/sem, au moins 4 sem ») et à la règle 48h inter-séances HIT.
- **Échauffement 10-13 min (5 min cardio + mobilité dynamique) et cooldown 5-10 min systématiques sur toutes les sessions**. Largement au-delà du minimum « 5 min warm-up » NHS, et exigence ACSM/NSCA pour HIIT débutant.
- **Mouvements bodyweight low-impact uniquement, pliométrie BANNIE explicitement** (box jumps, KB swings, burpees full plyo, sauts, double-unders, mouvements olympiques). Cohérent avec la doctrine pliométrie : pour des novices avec peu/pas d'expérience PT, programme PT plus simple à intensité plus basse, et pré-requis force + mécanique d'atterrissage avant intensités moyennes/hautes (Schoenfeld preprint 2025, Plyometric Training current concepts PMC4637913). La règle NSCA des « 6 mois de base de force avant pliométrie volumineuse » est explicitement citée dans `progression_logic` principe (4).
- **Renforcement préventif chevilles (calf raises bipodal puis excentriques W3, tibialis raises) intégré dès W1** pour prévenir tendinopathie Achille et shin splints — alignement direct avec la doctrine « baseline calf strength + ankle mobility + landing control before high-volume jumping » (Wheeler Sports Tech 2025, Mayo Clinic Achilles tendinitis : la cause #1 = augmenter la charge tendineuse trop vite ou mollets faibles).
- **Cutback W4 obligatoire (-38% volume HIT, 8 → 5 min)**. Cohérent avec la doctrine « persistent Achilles discomfort = reduce volume by 50% » et avec la règle NSCA cutback toutes les 3-5 semaines. Le `progression_logic` principe (3) rappelle que sans cutback, surcompensation cardiaque + tendinopathie sont les risques typiques 3-4 semaines HIIT chez le débutant.
- **RPE plafonné à 8 (jamais 9-10) en débutant**. Conforme à la guidance NHS « gentle exercise, build up gradually » et à l'ACSM HIIT 2014 (80-95% FCmax mais avec screening obligatoire >35 ans avec facteurs de risque).

Doctrine alignment : SOLIDE.

## 2. Metadata hooks (Story 0.5.9 / Schema v2)

**Per-template** : présents et bien renseignés.
- `week_structure.type` = "linear" : cohérent avec progression linéaire annoncée (W1→W3 build, W4 cutback, W5→W6 transition + pic).
- `week_structure.micro_pattern` : explicite J1 HIT / J3 mobi-renfo / J5 HIT — fidèle au pattern réel des semaines.
- `week_structure.recovery_cadence` : "1 cutback W4 sur plan 6 sem" — cohérent avec `deload_weeks: [4]`.
- `deload_weeks: [4]` : présent, cohérent avec contenu W4.
- `progression_logic` : long, sourcé (ACSM 2014, NSCA), explicite les 5 principes — exemplaire.

**Per-exercise** : `target_zone`, `required_equipment`, `incompatible_constraints`, `alternatives`, `volume_axis` présents sur 100% des exercices vérifiés (échantillon W1, W2, W3, W4, W5, W6).

Quelques nuances sur `target_zone` :
- `"30/30"` est utilisé comme zone fourre-tout pour TOUS les blocs HIT, y compris les blocs en 30/60 ratio 1:2 (W1-W4). Strictement parlant, un bloc 30/60 W1-W4 a une zone-cible différente (work + rest plus long, sollicitation plus aérobie). **Improvement possible** : introduire un second target_zone HIIT genre `"30/60"` ou `"work-rest-1-2"` pour les blocs W1-W4. **Non bloquant** : la sémantique reste lisible, le `notes` indique toujours explicitement le ratio.
- `"walking-recovery"` pour les repos actifs inter-blocs : OK, sémantique claire.
- `"technique"` pour la calibration RPE et les routines mobilité : cohérent.
- `"RPE 6-7"` / `"RPE 7-8"` pour le renforcement : OK, exprime bien l'intensité cible non-HIIT.

Hooks coverage : COMPLET. Une suggestion mineure (target_zone "30/60" séparée) listée dans Issues mineures.

## 3. Internal consistency

| Check | Résultat |
|---|---|
| `duration_weeks == weeks.count` (6 == 6) | PASS |
| Sessions actives ≤ 3/sem partout | PASS (3 sessions × 6 weeks) |
| Days uniques ∈ [1,7] dans chaque week | PASS (J1, J3, J5 partout) |
| Pattern J1/J3/J5 = 48h inter-séance HIT respecté | PASS |
| `default_objective` = "séance HIIT 20 min ratio work/rest 20/40 puis 20/20" vs contenu | INCOHÉRENCE MINEURE — le default_objective annonce **20/40 puis 20/20** alors que le plan livre **30/60 puis 30/30**. Le `summary` corrige (« ratios work/rest 30/60 puis 30/30 »), `progression_logic` aussi. À harmoniser dans le default_objective. |
| Séance phare W6 J5 : 20 min annoncées, 20 min livrées (8 min warmup + 4 min bloc1 + 2 min récup + 4 min bloc2 + ~2 min cooldown ≈ 20 min) | PASS |
| `progression_logic` cite des éléments réellement présents (ratio 1:2 W1-W3, 1:1 W5-W6, cutback W4 -38%, 4 → 6 → 8 → 5 → 7 → 8 min HIT cumulé) | PASS — calcul HIT hebdo recalculé : W1=4, W2=6, W3=8, W4=5, W5=7, W6=8 — exact |
| Calf raises excentriques W3 cite Alfredson protocol → standard tendinopathie | PASS |
| `safety_notes` cite ACSM 2014 et NSCA (rest 2-3 min compounds non applicable HIIT mais intervalles work/rest bien justifiés) | PASS |
| Equipment `mat` partout où mountain climbers/planche/dead bug : cohérent avec `assumed_profile` ("équipement minimal tapis, espace 2x2 m") | PASS |
| `incompatible_constraints` cohérents (knee-injury, ankle-injury, wrist-pain, shoulder-injury, lower-back-pain, cardiac-clearance-required, apartment-noise, hip-injury) | PASS — bien différencié par mouvement (mountain climbers a wrist+shoulder+lower-back, step-jacks a ankle+apartment-noise) |
| Alternatives fournies pour tous les exercices avec contraintes | PASS |

Une seule incohérence : `default_objective` "20/40 puis 20/20" → devrait être "30/60 puis 30/30" pour cohérence avec le contenu réel. Issue mineure non bloquante (cosmétique éditoriale, pas un défaut programmatique).

## 4. Cutback / deload

`deload_weeks: [4]` : PASS.

Vérification contenu W4 :
- Volume HIT cumulé W3 = 8 min, W4 = 5 min → -38% (annoncé -25 à -30%, légèrement plus que la fourchette mais cohérent avec la doctrine cutback 25-50%).
- W4 J1 « Cutback HIT 30/60 allégé » avec viseur RPE 7 (au lieu de 8) — explicite.
- W4 J3 mobilité + maintien renforcement (pas progression) — explicite.
- W4 J5 « Réveil neuromusculaire » 1 min HIT seulement, premier essai 30/30 préparant W5 — pédagogiquement excellent (test à faible dose avant transition complète).

Cadence : 1 cutback sur 6 semaines (semaine 4) = un cycle 3:1 build:deload. Conforme à la doctrine NSCA / Israetel (3-5 sem avant deload pour débutants).

Cutback : SOLIDE.

## 5. Safety

`safety_notes` couvre toutes les sections attendues du brief reviewer :
- **RED FLAGS** : douleur thoracique/palpitations/vertiges (arrêt + médecin), tendinite Achille, patellar tendinitis (jumper's knee), shin splints, entorse cheville, lombalgie aiguë, hyperextension cervicale. Couverture exhaustive des risques typiques HIIT débutant.
- **GENERAL RULES** : warmup non-optionnel (cite ACSM 2014), cooldown systématique, 48h inter-séance HIT règle absolue, hydratation 500-750 ml/h, sol antidérapant, hip hinge prérequis avant KB swings (exclus du plan), atterrissages plyo genoux fléchis.
- **INTENSITY** : test de la parole adapté HIIT (RPE 7 = 1 phrase, RPE 8-9 = 2-3 mots, RPE 10 = pas de parole), cible RPE 7-8 work, RPE 2-3 rest, mouvements bannis listés explicitement.
- **OVERLOAD SIGNS** : 6 signes (FC repos +10 bpm, jambes lourdes, sommeil dégradé, motivation effondrée, courbatures > 72h, baisse résistance bloc HIT phare 2 sem) → cutback +1 ou pause 48-72 h.
- **MISSED SESSION HANDLING** : 4 paliers (1-3j / 4-7j / 1-2sem / >2sem) clairs.

Spécificités sport+level couvertes :
- Achille : prévention dès W1 (calf raises, escentriques W3 protocole Alfredson cité), drapeau rouge explicite, alignement avec la doctrine « cause #1 = volume tendineux trop rapide + mollets faibles ».
- Shoulder/wrist : adressé via incompatible_constraints sur mountain climbers et planche, avec alternatives avant-bras.
- Lower back : dead bug + planche dès W1, drapeau rouge lombaire aigu.
- Cardio : screening >50 ans / antécédents / hypertension / asthme d'effort / postpartum / chirurgie <6 mois → consultation médicale explicite, ACSM 2014 cité (screening obligatoire >35 ans avec facteurs de risque, 6 mois cardio régulier avant HIIT structuré pour profil sédentaire prolongé).

Pas de copy-paste générique, langage spécifique HIIT débutant. Sécurité : EXEMPLAIRE.

## 6. EU MDR

Scan mots bannis (FR/EN) : "guérir" 0, "soigner" 0, "traiter une pathologie" 0, "diagnostic" 0, "thérapeutique" 0, "rééducation post-opératoire" 0, "cure" 0, "treat" 0 (le mot "treat" n'apparaît pas), "diagnose" 0.

Mots à risque détectés et statut :
- "tendinite Achille" / "shin splints" / "patellar tendonitis" / "lombalgie aiguë" / "entorse cheville" / "hyperextension cervicale" : utilisés comme descriptions de symptômes/risques, pas comme claims de traitement. **OK MDR**.
- "consulte un médecin avant de commencer ce programme" pour antécédents cardiaques/>50 ans sédentaire/hypertension/asthme d'effort/grossesse-postpartum/post-op <6 mois : medical clearance explicite. **OK MDR**.
- "avis kiné si > 5 jours" pour tendinites/shin splints/lombalgies : trigger référent santé sans claim de soin. **OK MDR**.
- "calf raises excentriques (protocole Alfredson)" cité comme protection tendineuse. Alfredson est un protocole publié pour tendinopathie Achille — c'est un terme scientifique, pas un claim médical. **OK MDR mais limite** — à surveiller en audit prod, idéalement reformuler "approche excentrique inspirée de la littérature tendineuse" pour neutraliser.

Pas de framing prescriptif rééducation/physiothérapie. Pas de claim disease-treatment.

EU MDR : PASS (1 limite cosmétique « Alfredson » à noter en backlog audits prod, non bloquante).

## 7. Final autonomy checklist

Présent dans W6 J5 dernière session (`Bloc 2 — 30/30 mixte 4 min HIT`, notes en fin), 4 critères mesurables/observables :

1. Tenue 2 blocs 4 min HIT 30/30 RPE 8 + 2 min récup sans pause forcée intra-bloc.
2. Récup FC < 100 bpm en moins de 3 min après bloc 2 (proxy : conversation normale sous 3 min).
3. Mollets/cuisses fatigués mais sans douleur tibiale ni Achille.
4. 48h récup respectées entre J1 et J5.

Critères observables (sans matériel cardio externe pour le 2 grâce au proxy conversation), seuils chiffrés, route d'évolution donnée (3+/4 = passage `recreational`, 2/4 = refaire W5+W6).

Brief demande 3-5 critères : **4 critères = PASS**. Idéalement on pourrait ajouter un 5e critère sur la récupération inter-séance (par exemple « pas de courbatures > 48h après J1 ») pour atteindre 5 — mineur.

Autonomy checklist : PASS.

## 8. Style

Français, tutoiement (« tu vises », « si tu n'arrives pas »), aucun emoji, exercise names clairs en français avec descriptions techniques. Notes pédagogiques bien dosées (ni trop courtes ni trop verbeuses), avec rappel ratio/RPE systématique. Cohérence terminologique (« step-jacks », « squat-air partial ROM », « mountain climbers slow ») préservée sur les 6 semaines.

Style : EXEMPLAIRE.

## Issues summary

### Critical (block merge)

Aucun.

### Important (fix recommended)

- **`default_objective` ligne 9** : annonce « ratio work/rest 20/40 puis 20/20 » alors que le plan livre 30/60 puis 30/30. Cohérent ailleurs (`summary`, `progression_logic`, contenu) — c'est une coquille rédactionnelle dans le default_objective. **Fix proposé** : remplacer « 20-30 s d'effort, ratio work/rest 20/40 puis 20/20 » par « 30 s d'effort, ratio work/rest 30/60 puis 30/30 ».

### Minor (nice-to-have)

- **target_zone unique "30/30" pour blocs 30/60 et 30/30** : sémantique légèrement imprécise pour les blocs W1-W4 qui sont en 30/60. Le `notes` corrige systématiquement, mais ajouter un target_zone "30/60" séparé clarifierait pour un futur dashboard. Non bloquant.
- **« protocole Alfredson » mentionné W3 J3 calf raises excentriques** : terme scientifique correct mais à surveiller en audit prod EU MDR. Reformulation possible : « approche excentrique inspirée de la littérature tendineuse ».
- **5e critère autonomy checklist** : possibilité d'ajouter « pas de courbatures > 48h après J1 » pour atteindre 5/5 critères au lieu de 4 (brief reviewer demande 3-5, donc 4 suffit).

## Sources

- [American College of Sports Medicine — Physical Activity Guidelines](https://acsm.org/education-resources/trending-topics-resources/physical-activity-guidelines/)
- [ACSM — High-Intensity Interval Training: For Fitness, for Health or Both?](https://acsm.org/high-intensity-interval-training-fitness/)
- [ACSM Information On… High-Intensity Interval Training (PDF)](https://blanchfield.tricare.mil/Portals/70/Session%202%20ACSM%20High%20Intensity%20Interval%20Training.pdf)
- [Tabata I. et al. (1996) — Effects of moderate-intensity endurance and high-intensity intermittent training on anaerobic capacity and VO2max — PubMed 8897392](https://pubmed.ncbi.nlm.nih.gov/8897392/)
- [Tabata training — one of the most energetically effective high-intensity intermittent training methods (J Physiol Sci, 2019)](https://link.springer.com/article/10.1007/s12576-019-00676-7)
- [Gibala M. — Physiological adaptations to low-volume, high-intensity interval training in health and disease (J Physiol, PMC3381816)](https://pmc.ncbi.nlm.nih.gov/articles/PMC3381816/)
- [Gibala M. — The Science of Vigorous Exercise (FoundMyFitness episode summary)](https://www.foundmyfitness.com/episodes/martin-gibala)
- [NHS — HIIT (High Intensity Interval Training) — Service Directory](https://www.nhs.uk/services/service-directory/hiit-high-intensity-interval-training/N10441435)
- [NHS Sheffield Children's HIIT programme 1](https://library.sheffieldchildrens.nhs.uk/hitt-programme-1/)
- [Schoenfeld et al. (preprint 2025) — The Role of HIIT in Neuromuscular Adaptations: Implications for Strength and Power Development](https://www.preprints.org/manuscript/202503.1163)
- [Current Concepts of Plyometric Exercise (PMC4637913)](https://pmc.ncbi.nlm.nih.gov/articles/PMC4637913/)
- [Effects of plyometric training on health-related physical fitness in untrained participants — systematic review and meta-analysis (Sci Rep, 2024)](https://www.nature.com/articles/s41598-024-61905-7)
- [Conservative Management of Achilles Tendinopathy (PMC7249277)](https://pmc.ncbi.nlm.nih.gov/articles/PMC7249277/)
- [Mayo Clinic — Achilles tendinitis — Symptoms & causes](https://www.mayoclinic.org/diseases-conditions/achilles-tendinitis/symptoms-causes/syc-20369020)
- [Wheeler Sports Tech — How Plyometric Training Helps Prevent Achilles Tendon Injuries (2025)](https://www.wheelersportstech.com/2025/11/21/how-plyometric-training-helps-prevent-achilles-tendon-injuries/)

## Recommendation

**APPROVED** — bundle as-is.

Patch éditorial recommandé mais non bloquant : harmoniser le `default_objective` (« 30/60 puis 30/30 » au lieu de « 20/40 puis 20/20 ») au prochain pass de regen ou via Edit ciblé. Le template est par ailleurs exemplaire en doctrine, sécurité, structure et hooks v2 — référence pour les autres templates HIIT à venir.

## Patches applied (2026-05-01)

- **Important — `default_objective` harmonisé** : remplacé "20-30 s d'effort, ratio work/rest 20/40 puis 20/20" → "30 s d'effort, ratio work/rest 30/60 puis 30/30" + RPE corrigé "8-9" → "7-8" (cohérent avec `summary` et `progression_logic`).
- **Minor — target_zone "30/60" séparé pour W1-W4** : 12 occurrences `target_zone` patchées de "30/30" → "30/60" sur tous les exercices nommés "Bloc 30/60 — …" (W1 à W4), pour clarifier la sémantique des dashboards futurs vs les vrais blocs 30/30 W5-W6.
- **Minor — formulation EU MDR neutralisée** : "Protocole inspiré Alfredson" → "Approche excentrique inspirée de la littérature tendineuse" (W3 J3 calf raises excentriques, élimine référence nominative médicale).
- **Minor — 5e critère autonomy checklist** : ajout "Pas de courbatures bloquantes > 48h après J1" en W6 J5, seuil de validation passe de 3+/4 à 4+/5 (et 2/4 → 3/5). `summary` et W6 `goal` mis à jour ("4 critères" → "5 critères").

Post-patch verifications : JSON parse OK, 61 exercices avec 5 hooks chacun, banned words EU MDR scan clean, FR/tutoiement/no emojis préservés.

**Verdict final** : APPROVED.
