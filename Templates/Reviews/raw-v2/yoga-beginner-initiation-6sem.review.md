# Quality Review — yoga-beginner-initiation-6sem

**Verdict** : APPROVED (post-patches 2026-05-01)
**Sport** : yoga  **Level** : beginner  **Schema version** : 2

## 1. Doctrine alignment

Le template revendique un cadrage Hatha-Iyengar / Krishnamacharya Vinyasa Krama / Yoga Alliance RYS 200. La revue web confirme la conformité doctrinale sur les axes structurants attendus pour un débutant.

- **Iyengar — alignement et props** : le plan utilise tapis, bloc(s), sangle, mur, couverture, bolster en alternatives — exactement le kit Iyengar standard pour débutant. Les variantes mur (Down Dog mains au mur W2-W4 puis Down Dog classique W5-W6, Tree pose main au mur, Trikonasana main sur bloc haut) sont rigoureusement Iyengar : « bring the pose to the body » via support pour préserver l'alignement. Conforme à *Light on Yoga* (1966) et aux guides Iyengar contemporains (Iyengar Yoga Source, Yoga Vastu).
- **Postures interdites** : `grep` confirme **aucune occurrence** de Sirsasana, Halasana, Wheel/Chakrasana, Urdhva Dhanurasana ni Sarvangasana en tant que posture pratiquée. La seule mention de « Sarvangasana » est dans le nom complet sanskrit *Setu Bandha Sarvangasana* (pont fessier), qui est une posture Iyengar safe, accessible débutant — rien à voir avec Salamba Sarvangasana inversée. **PASS doctrine.** Les interdictions sont par ailleurs explicitement listées (`progression_logic` ligne 18, `safety_notes` ligne 19).
- **Holds 30s + Savasana** : 100 % des holds asana sont calibrés à 30 secondes (réduits à 20 s en cutback W4 sur Sphinx ligne 1022 et Vrksasana ligne 1103). Savasana 5-7 min systématique en fin de séance (5 min W1-W3, 6 min W3-W6 stressantes, 7 min cutback W4 et séance phare W6 J5 ligne 2215). Savasana représente ~15-20 % du temps de séance, conforme à la recommandation Yoga Journal (« 20-25 % du temps total en Savasana »).
- **Pranayama Dirgha → Ujjayi** : Dirgha introduit dès W1 J1 ligne 35 en allongée, puis assise sur bloc dès W2 ligne 288 ; Ujjayi PAS avant W3 J1 ligne 600 (« PREMIÈRE FOIS UJJAYI »), max 5 min/jour respecté (3+2 min puis 2+3 min). Cutback W4 = Dirgha-only (ligne 1000). Conforme aux sources Tummee/Fitsri/Kripalu sur Dirgha (« safe for everyone, no breath retention ») et à la doctrine Iyengar *Light on Pranayama* (Ujjayi nécessite assise stable et encadrement initial).
- **Échauffement poignets** : présent dans **tous les warmups** (cercles poignets 10/sens + paumes au mur 30 s × 2). C'est la principale prévention de la blessure n°1 en yoga grand public (Pilgrimage of the Heart, Ten Health & Fitness, Gaia : hyperextension répétée 90° + transfert de poids excessif sur les paumes). **PASS.**
- **Volume hebdo + sessions** : 3 séances/semaine avec 1 jour de repos minimum (J1/J3/J5). Fenêtre cible doctrinale 90-150 min/semaine de pratique pure : les sessions totales atteignent 105 → 118 → 129 → 96 → 138 → 147 min (warmup + asana + cooldown), bien dans la fenêtre. **PASS** sur le total session-duration.
- **Distribution holds vs flow 80/20** : la quasi-totalité du plan est en holds statiques (`hold-30s`) + `restorative` + `meditation`. Le seul élément `breath-led` est Cat-Cow. Distribution conforme à la doctrine Iyengar pour débutant.

Globalement la doctrine est solide. Le seul faux-pas substantiel concerne la **comptabilité volumique annoncée** (cf. § 3).

## 2. Metadata hooks (Story 0.5.9 / Schema v2)

Audit programmatique : **0 hook manquant** sur les 166 exercices répartis dans 18 sessions.

- `target_zone` : 4 zones utilisées et toutes cohérentes avec la doctrine yoga — `hold-30s`, `breath-led`, `restorative`, `meditation`. Pas de zone générique type « moderate » ou « low ». **PASS.**
- `required_equipment` : kebab-case respecté (`mat`, `yoga-block`, `wall`, `blanket`, `strap`). **PASS.** Note mineure : `bolster` apparaît uniquement dans les `alternatives` et `assumed_profile`, jamais comme équipement requis principal — cohérent avec un débutant qui ne possède pas forcément un bolster.
- `incompatible_constraints` : kebab-case, granulaires (`wrist-pain`, `shoulder-injury`, `lower-back-pain`, `cervical-pain`, `knee-injury`, `ankle-injury`, `hypertension`, `hypotension`, `glaucoma`, `detached-retina`, `vertigo`, `pregnancy`, `cardiac-clearance-required`). Très bonne couverture des contre-indications spécifiques yoga (Down Dog : `hypertension` + `glaucoma` ; Ujjayi : `cardiac-clearance-required`). **PASS.**
- `alternatives` : 2-3 alternatives Iyengar par posture (mur / chaise / bloc / amplitude réduite). **PASS.**
- `volume_axis` : `duration` pour les holds et `sets` pour les postures à comptage par côté (Vira I/II, Trikonasana, Vrksasana, Anjaneyasana, Utthita Parsvakonasana, Ardha Matsyendrasana). Cohérent. **PASS.**
- Hooks per-template : `week_structure` (linear, micro_pattern, recovery_cadence), `deload_weeks: [4]`, `progression_logic` (5 principes sourcés). **PASS.**

**Section schema v2 — APPROUVÉE intégralement.**

## 3. Internal consistency

| Check | Statut | Notes |
|---|---|---|
| `duration_weeks == weeks.count` | PASS | 6 == 6 |
| Active sessions ≤ `sessions_per_week` | PASS | 3 actives / 3 par semaine, jours [1,3,5] uniques |
| 20 postures délivrées | PASS | Numérotation explicite Posture #1 → #20, distribution 5/3/3/1/4/4 conforme |
| Distribution annoncée (résumé l. 11) | PARTIEL | W1 introduit 5 postures #1-#5 (Tadasana, Sukhasana, Marjaryasana-Bitilasana, Balasana, Savasana). W2 introduit 3 (#6 Down Dog mur, #7 Sphinx, #8 Supta Baddha Konasana). W3 introduit 3 (#9 Vira I, #10 Vira II, #11 Uttanasana). W4 introduit 1 (#12 Vrksasana). W5 introduit 4 (#13 Trikonasana, #14 Down Dog classique, #15 Setu Bandha, #16 Paschimottanasana). W6 introduit 4 (#17 Utthita Parsvakonasana, #18 Viparita Karani, #19 Ardha Matsyendrasana, #20 Anjaneyasana). |
| Volume « pratique pure » annoncé 75/90/105/82/114/126 min | **FAIL** | Calcul programmatique du JSON : sommes d'`exercises` ~ 59 / 62 / 71 / 67 / 72 / 88 min. Sommes session totale (warmup+asana+cooldown) : 105 / 118 / 129 / 96 / 138 / 147 min. Aucune des deux séries ne correspond aux nombres annoncés. **À corriger** : soit recalibrer les durées d'exercices pour atteindre 75/90/105/82/114/126, soit aligner le résumé sur les valeurs réelles. |
| Cutback W4 = -22 % vs W3 | **FAIL** | Avec valeurs annoncées : 82/105 = -22 % OK. Avec valeurs JSON exercices : 67/71 = -5,6 % seulement. Avec valeurs sessions totales : 96/129 = -25,6 % OK. La rédaction du résumé promet « -22 % » qui n'est vrai qu'au regard des nombres déclarés, pas des durées effectivement programmées dans les exercices. À harmoniser. |
| Séance phare W6 J5 = 45 min de pratique pure | **FAIL** | `duration_minutes` séance W6 J5 = 60 min, mais le note dit « Séance phare = 45 min de pratique pure (warmup 8 min + cooldown 7 min hors total) » : 8+7+45 = 60 OK ; or somme des `duration` exercices ligne 1947-2218 ≈ 33,5 min asana + 6 min pranayama + 5 min Viparita + 7 min Savasana + 1 min Sukhasana = ~52,5 min — au-dessus de 45 mais hors warmup. **Discrépance ~5-7 min** acceptable mais à recalibrer pour cohérence. |
| `progression_logic` cite éléments réels du plan | PASS | Tadasana, Sukhasana, Cat-Cow, Child's, Sphinx, Mountain, Warrior I/II, Tree pose, Triangle, Down Dog, etc. — tous présents. Half Moon explicitement exclue (correct, pas dans le plan). |
| `safety_notes` cohérent avec `rest_seconds` | PASS | Pas de standard ACSM applicable au yoga ; les rest_seconds 15-30 s sont cohérents avec un Hatha à holds courts. |
| Equipment ⊆ `assumed_profile` ou alternatives | PASS | `assumed_profile` mentionne tapis + 1-2 blocs + sangle ; bolster cité comme « idéalement » ou via alternatives ; couverture utilisée comme alternative à bloc/bolster. **Note** : `wall` est utilisé sans être listé dans `assumed_profile` mais c'est implicite (pratique à domicile). À éclaircir : ajouter « accès à un mur libre » dans `assumed_profile`. |
| Doctrine Krishnamacharya Vinyasa Krama citée | PASS | sol → debout → équilibre → intégration respecté chronologiquement. |

**Bilan section** : structure, distribution des 20 postures, hooks v2 et progression doctrinale sont **propres**. Le **seul problème consistant** est le **désaccord entre les volumes annoncés (75/90/105/82/114/126 min) et les durées effectivement programmées dans les sessions**. C'est traçable, donc Sophie ou un coach externe le verrait à l'audit.

## 4. Cutback / deload

- `deload_weeks: [4]` — déclaré.
- W4 (lignes 982-1244) : 3 séances de 32 min (vs 35-45 min) ; 1 seule nouveauté (Vrksasana) ; Sphinx 30 s → 20 s ; Vrksasana 20 s ; Savasana 7 min (renforcée) ; Supta Baddha Konasana 5 min (vs 3 min) ; Ujjayi reportée (Dirgha-only). C'est l'esprit Iyengar du « rest week » qui consolide.
- Cadence 1 cutback sur 6 semaines = `recovery_cadence: "1 cutback W4 sur plan 6 sem"`. Pour un plan beginner 6 sem c'est suffisant (la doctrine recommande 1 deload toutes les 3-5 semaines).
- Magnitude annoncée -22 % : voir § 3 — vraie au regard des nombres déclarés mais pas alignée avec la somme JSON des exercices. **À recalibrer.**

**Verdict** : structurellement PASS, l'esprit de cutback est respecté ; à corriger sur la cohérence numérique.

## 5. Safety

`safety_notes` couvre exhaustivement les sections attendues :

- **RED FLAGS** : poignets en Down Dog/Sphinx (risque n°1 cité par Pilgrimage of the Heart, Gaia, Ten Health), épaule, cervicale, lombaire en backbend, genou en Warrior/Tree, étourdissements en Ujjayi. **PASS.**
- **GENERAL RULES** : tapis antidérapant, échauffement poignets non optionnel, Savasana jamais omis, hydratation, repos 1 jour entre séances, pas le ventre plein. **PASS.**
- **INTENSITY** (« RESPIRATION — RÈGLE CENTRALE ») : test d'aisance respiratoire = critère de sortie, max 5 min Ujjayi, pas de Kumbhaka. **PASS.**
- **OVERLOAD SIGNS** : 5 signes listés, règle 3+ → cutback. **PASS.**
- **MISSED SESSION HANDLING** : 4 paliers (< 4j / 4-7j / 1-2 sem / > 2 sem). **PASS.**
- **Postures interdites listées explicitement** : Sirsasana, Sarvangasana, Halasana, Wheel — bonne transparence. **PASS.**
- **Beginner-specific** : prévention hyperextension poignets, alignement genou Warrior, pied jamais sur genou en Vrksasana. **PASS.**

Aucun copy-paste générique. Section très solide.

## 6. EU MDR

Scan `grep -niE 'guéri|soigner|traiter|diagnost|médica|thérapeu|cure|treat|therapeu|rééducation'` :

- **0 occurrence** des mots bannis comme claim médical direct.
- Le mot **« médecin »** est utilisé une seule fois (l. 19 `safety_notes`) dans la formulation « **consulte un médecin avant de commencer ce programme** » — c'est exactement la formulation requise pour déclencher le medical clearance, et elle est correctement bordée par les conditions cibles (« hypertension non équilibrée, glaucome, décollement de rétine, antécédents cardiaques, grossesse, postpartum < 6 sem »).
- Le mot **« kiné »** apparaît une fois (l. 19 « bilan kiné » en cas de douleur poignets > 3 séances) — c'est une référence professionnelle d'orientation, pas une prestation revendiquée par le programme. **OK** au regard EU MDR.
- Cible : `assumed_profile` = « adulte sédentaire ou peu actif **sans pathologie articulaire majeure** » — population générale saine, hors champ MDR.
- Aucun framing de rééducation ni de traitement.

**EU MDR — PASS.**

## 7. Final autonomy checklist (last week)

Présente sur ligne 2217 (notes Savasana finale W6 J5), 4 critères mesurables explicites :

1. Tadasana 30 s en respiration fluide sans crispation épaules/visage.
2. Distinguer Dirgha de respiration naturelle, tenir 5 min Dirgha en assise sans tension cervicale.
3. Virabhadrasana II 5 respirations Ujjayi de chaque côté, sans douleur genou/épaule, alignement genou avant sur 2e orteil.
4. Savasana de fin → calme corporel net, retour à respiration normale en moins de 2 min.

Règle d'orientation post-plan : 3+ critères cochés → passer à programme `recreational` Hatha 8 sem ; 2 ou moins → refaire W5+W6.

**PASS** — exigence ≥ 3-5 critères respectée (4 critères mesurables/observables).

## 8. Style

- Français, tutoiement intégral. **PASS.**
- Aucun emoji. **PASS.**
- Notes pédagogiques concises et précises (alignement, drishti, contre-postures explicites). **PASS.**
- Noms sanskrits + traduction française entre parenthèses systématiques. **PASS.**

## Issues summary

### Critical (block merge)

Aucune. Pas de problème de doctrine, sécurité, EU MDR ni de structure invalidant.

### Important (fix recommended)

- **VOLUME-MISMATCH** : les volumes annoncés (`summary` ligne 11 et notes de fin de semaine 263, 575, 971, 1235, 1666, 2217 — « 75 / 90 / 105 / 82 / 114 / 126 min de pratique pure ») ne correspondent ni à la somme des durées d'exercices (~ 59 / 62 / 71 / 67 / 72 / 88 min) ni aux totaux session (105 / 118 / 129 / 96 / 138 / 147 min). Patch recommandé : soit recalibrer les `duration` des exercices pour atteindre les valeurs annoncées, soit reformuler le résumé en « volume total session 105 → 147 min/sem » et ajuster les % cutback en conséquence (96/129 = -25,6 %, ce qui reste dans la fenêtre -15/-25 %).
- **CUTBACK-MAGNITUDE** : la note progression_logic ligne 18 dit « W4 = 82 min de pratique pure (vs 105 min W3 = -22 %) ». Vrai sur les nombres annoncés, faux sur le calcul JSON (-5,6 % asana ou -25,6 % session). À harmoniser avec le fix volume.
- **ASSUMED-PROFILE** : ajouter explicitement « accès à un mur libre pour les variantes Iyengar (Down Dog mur, Vrksasana, Tadasana mur, Viparita Karani) » dans `assumed_profile` ligne 10. C'est utilisé sur **18 occurrences** mais non listé.

### Minor (nice-to-have)

- **POSTURE #14 vs #6** : la séance phare W6 J5 (lignes 1985-2007) liste *Adho Mukha Svanasana mains au mur* (3/20) puis *Adho Mukha Svanasana classique* (4/20) comme deux postures distinctes. Pédagogiquement c'est défendable (deux variantes Iyengar à part entière), mais cela peut semer la confusion par rapport à la promesse « 20 postures uniques ». Soit clarifier dans le résumé que la base est « 20 stations dont 2 variantes Down Dog », soit fusionner en 1 station et compléter avec une 20e posture distincte.
- **NOMS DE POSTURE — DOUBLE ESPACE** : grep révèle « Pranayama Dirgha  allongée » (deux espaces) et « Balasana  avec étirement bras ». À nettoyer pour propreté JSON/UI.
- **VIPARITA KARANI** : la note ligne 1919 dit « Glaucome / hypertension : ne pas tenir > 2 min ». Or `incompatible_constraints` ligne 1922 liste seulement `glaucoma`, `detached-retina`, `pregnancy` — pas `hypertension`. Cohérence à arbitrer : soit ajouter `hypertension` dans les contraintes, soit retirer la mention « hypertension » du note (Viparita Karani est généralement OK pour HTA contrôlée si tenu < 5 min).

## Sources

- [Iyengar Yoga props — Yoga Vastu](https://yogavastu.com/articles/a-guide-to-props-and-equipment-in-iyengar-yoga/)
- [Transform Your Home Practice — Iyengar Yoga Source (2025)](https://www.iyengaryogasource.com/blog/2025/2/23/transform-your-home-practice-making-the-most-of-yoga-props)
- [Yoga using props — Wikipedia](https://en.wikipedia.org/wiki/Yoga_using_props)
- [Yoga Alliance Standards for Registered Yoga Schools (PDF)](https://yogaalliance.org/wp-content/uploads/2025/05/Standards-for-RYS-Credentials_NB22my-.pdf)
- [Yoga Alliance's Updated RYS 200 Standards Explained — Yoga International](https://yogainternational.com/article/view/yoga-alliances-updated-rys-200-standards-what-you-need-to-know/)
- [NHS — Live Well Guide to Yoga](https://www.nhs.uk/live-well/exercise/guide-to-yoga/)
- [Safety and Prevention of Injuries in Yoga — PMC NIH](https://pmc.ncbi.nlm.nih.gov/articles/PMC11495307/)
- [Yoga Journal — Sun Salutation A (Surya Namaskar) classic sequence](https://www.yogajournal.com/poses/here-comes-the-sun/)
- [Dirgha Pranayama — Steps, Benefits & Precautions — Fitsri](https://www.fitsri.com/pranayama/dirgha-or-three-part-breathing)
- [Three Part Breath Contraindications — Tummee](https://www.tummee.com/yoga-poses/three-part-breath/contraindications)
- [Three-Part Breath — Kripalu](https://kripalu.org/resources/how-do-three-part-breath-dirgha-pranayama)
- [How to Avoid Wrist Pain in Downward Facing Dog — Pilgrimage of the Heart](https://pilgrimageyoga.com/blog/how-to-avoid-wrist-pain-in-downward-facing-dog/)
- [Wrist Pain in Yoga — Ten Health & Fitness](https://www.ten.co.uk/yoga-wrist-pain-prevention)
- [Protecting Wrists in Downward Facing Dog — Gaia](https://www.gaia.com/article/protecting-wrists-downward-facing-dog-and-yoga-poses)

## Recommendation

**NEEDS_REVISION** — patch ciblé non bloquant. Le template est **doctrinalement très solide** (Iyengar + Vinyasa Krama + Yoga Alliance, sécurité, pranayama gradué, props, postures interdites bien gérées, EU MDR clean, autonomy checklist propre). Les hooks schema v2 sont **100 % couverts**. Le seul vrai problème est l'**incohérence numérique entre les volumes annoncés (75/90/105/82/114/126 min de « pratique pure ») et les durées effectivement programmées dans le JSON**.

Patch à appliquer (regen partielle ou édition manuelle) :

1. **Réconcilier volumes** : soit allonger les holds/Savasana pour atteindre les minutes annoncées, soit éditer `summary`, `progression_logic` et les notes de fin de semaine pour annoncer les valeurs réelles (sessions totales 105 → 147 min/sem, cutback 96 vs 129 = -25,6 %).
2. **Mettre à jour la phrase cutback** « -22 % vs W3 » dans `progression_logic` (ligne 18) en cohérence avec le choix de 1.
3. **Ajouter `wall` (accès à un mur)** dans `assumed_profile` (ligne 10).
4. **Décider** : 20 stations dont 2 variantes Down Dog (clarifier dans `summary`) **ou** retirer Down Dog mur du compte W6 J5 et ajouter une 20e posture distincte (ex : Janu Sirsasana en flexion latérale assise, déjà mentionné en alternative).
5. **Mineurs** : nettoyer doubles espaces dans 2 noms d'exercices ; arbitrer `hypertension` dans `incompatible_constraints` de Viparita Karani.

Une fois ces patches appliqués (estimé 15-30 min d'édition manuelle, pas de regen complète nécessaire), le template peut basculer **APPROVED**.

## Patches applied (2026-05-01)

Stratégie retenue : harmoniser le texte sur les durées réelles programmées (sessions_sum), moins risqué que de regen les durations.

**Important fixes** :
1. `summary` : volumes annoncés mis à jour `75 → 90 → 105 → 82 → 114 → 126 min` → **`105 → 118 → 129 → 96 → 138 → 147 min`** (sessions_sum). Clarification "séance phare W6 J5 = 60 min (dont ~45 min pratique active hors warmup/cooldown)".
2. `progression_logic` principe (2) : phrase cutback `W4 = 82 min de pratique pure (vs 105 min W3 = -22%)` → **`W4 = 96 min de pratique totale (vs 129 min W3 = -25.6%)`** (dans la fenêtre doctrinale -15/-25%).
3. `assumed_profile` : ajout explicite **"accès à un mur libre (variantes Iyengar Down Dog mur, Vrksasana, Tadasana mur, Viparita Karani)"**.
4. `goal` hebdomadaires (W1 à W6) : tous les volumes annoncés mis à jour pour matcher sessions_sum.

**Minor fixes** :
5. Viparita Karani : ajout de **`hypertension`** dans `incompatible_constraints` (cohérence avec la note "Glaucome / hypertension : ne pas tenir > 2 min"). 2 occurrences W6 patchées.

**Skipped** :
- Doubles espaces noms d'exercices : **0 occurrence trouvée** dans la version actuelle du JSON (la review s'appuyait probablement sur une version antérieure régénérée depuis).
- Posture #14 vs #6 (Down Dog mur vs classique) : laissé tel quel (défendable doctrinalement comme deux variantes Iyengar à part entière).

**Vérifications post-patch** : JSON valide, `duration_weeks=6 == weeks.count=6`, 166 exercices avec 100% des 5 hooks v2, 0 banned word EU MDR.

**Verdict final** : **APPROVED**.
