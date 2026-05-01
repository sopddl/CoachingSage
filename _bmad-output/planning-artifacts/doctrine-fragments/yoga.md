# YOGA

Fragment doctrine yoga pour CoachingSage Story 0.5.10. À fusionner dans `leon-algo-doctrine-by-sport.md` Phase C.

**Last revised** : 2026-04-30.

**Statut** : ready-for-prompt — sourcé web, intègre les 7 lessons learned du pilote running.

**Vocabulaire de niveau** (aligné enums Sport + Level Story 0.5.8) :
- `beginner` : aucune expérience récente, < 6 mois ou jamais pratiqué, vise la familiarité avec le tapis, la respiration et les postures fondamentales au sol et debout.
- `recreational` : pratique 1 à 2× / sem, capable de tenir 30 min Hatha doux, vise une séance complète Hatha-Vinyasa accessible (45-60 min).
- `regular` : pratique 3 à 4× / sem depuis ≥ 1 an, capable de tenir un Vinyasa flow 60 min, vise des séquences Sun Salutation A+B fluides + équilibres + premières inversions au mur.
- `competitive` : pratique 5 à 6× / sem (ou daily Mysore-style), tient l'Ashtanga primary series ~75 postures en 75-90 min OU pratique Iyengar avancée avec inversions complètes (Sirsasana libre, Sarvangasana, Kapotasana).

---

## Doctrine référente

| Référence | Auteur | Application |
|---|---|---|
| **Light on Yoga** (1966) | B.K.S. Iyengar | Référence absolue alignement / précision postures, 200+ asanas illustrées, usage des props (briques, sangles, bolsters), méthode Iyengar = référence pour `beginner` et `recreational`. |
| **Light on Pranayama** | B.K.S. Iyengar | Doctrine respiration : Dirgha (3-part) accessible débutant, Ujjayi avec précautions (pas avant 3 mois de pratique régulière non-supervisée). |
| **Ashtanga Yoga: The Definitive Primary Series Practice Manual** | Petri Räisänen / Pattabhi Jois lineage | Structure Ashtanga vinyasa : 4 séries (primary "Yoga Chikitsa" 60-90 min ~75 postures, intermediate "Nadi Shodhana", advanced A+B), référence `regular` et `competitive`. |
| **Yoga Sutras of Patanjali** + **Yoga Yajnavalkya** | Patanjali | Base philosophique des 8 membres (yamas, niyamas, asana, pranayama, pratyahara, dharana, dhyana, samadhi) — invoqué dans `progression_logic` et `notes` pour donner profondeur. |
| **Vinyasa Krama** | T. Krishnamacharya / TKV Desikachar | Méthode "step-by-step adapted to individual capacity" — racine commune Iyengar / Pattabhi Jois / Indra Devi. Justifie la progression par paliers (Cat-Cow → Mountain → Warrior → équilibre → inversion). |
| **Yoga Alliance RYS 200-hour Standards (2024 update)** | Yoga Alliance | Curriculum 13 catégories (asana, pranayama, meditation, anatomy, philosophy, ethics, teaching methodology, etc.) — référence pour la structure 5-piliers de nos templates. |

**Choix de doctrine CoachingSage** :
- `beginner` + `recreational` : **Iyengar/Hatha** dominant (alignement, props, hold static 30-60s), respiration Dirgha first, Ujjayi en W3+ supervisé.
- `regular` : **Hatha-Vinyasa hybride** (séquences fluides Surya Namaskar A+B, holds modérés 5 respirations).
- `competitive` : **Ashtanga primary series** (Mysore self-practice possible, vinyasa count Pattabhi Jois) OU **Iyengar advanced** (inversions complètes, postures nuancées avec props).

Justification : Iyengar = méthode la plus sûre pour le grand public (alignement explicite, props), Ashtanga = structure encyclopédique reproductible (75 postures fixes), les deux dérivent de Krishnamacharya. Vinyasa "flow" générique sans référentiel structuré écarté pour `competitive` (trop hétérogène d'un studio à l'autre).

---

## Zones d'effort yoga (target_zone)

Pas de zone cardio (% FCmax ou VDOT) en yoga : l'effort est mesuré par **durée du hold**, **rythme du flow**, **qualité de la respiration**, et **RPE perçu** sur les postures actives (Warrior, équilibre, inversion). Convention v2 :

| Zone | Description | Application |
|---|---|---|
| `breath-led` | Mouvement guidé par la respiration, 1 respiration = 1 transition | Surya Namaskar A/B, Cat-Cow, Sun Salutation, vinyasa transitions |
| `hold-30s` | Tenue statique courte (~5 respirations Ujjayi lentes) | Postures fondamentales beginner+recreational : Mountain, Warrior I/II, Tree pose |
| `hold-45s` | Tenue moyenne (~8 respirations) | Recreational+ : Warrior III, Triangle, Half Moon |
| `hold-60s` | Tenue longue (~10 respirations) | Iyengar standard regular+ : Trikonasana, Parsvakonasana, headstand au mur |
| `hold-90s` | Tenue prolongée (~15 respirations) | Inversions competitive : Sirsasana libre, Sarvangasana, postures avancées |
| `flow` | Séquence dynamique multi-postures sans pause | Vinyasa flow regular+, primary series competitive |
| `restorative` | Posture longue avec props, respiration calme | Savasana, Supta Baddha Konasana sur bolster, Yin holds 3-5 min |
| `RPE 4-5` | Effort modéré perçu | Hatha doux beginner, séquences au sol |
| `RPE 6-7` | Effort soutenu perçu | Vinyasa regular, équilibres tenus, primary series sections |
| `meditation` | Assise, pranayama, dhyana | Pratiques 3+ piliers (pranayama, meditation, philosophy), pas d'asana |

**Choix de doctrine** : on pace en **durée de hold + RPE** plutôt que cardio. Compatible Iyengar (holds longs) et Ashtanga (flow + 5 respirations par posture). Les profils sans expérience pranayama démarrent **Dirgha** (3-part breath, aucune contre-indication) avant Ujjayi (constriction glottique → contraindiquée hypotension, grossesse, migraine, crise cardiaque, voir Pranayama Primer Yoga Simple).

---

## Volume hebdo cible par niveau

**Convention volume yoga v2** : volume hebdo exprimé en **minutes de pratique pure** (asana + pranayama + meditation hors warmup/cooldown courts < 5 min). Volume comptabilisé aussi en **nombre de postures uniques** dans la séance phare hebdo (axe complémentaire utile pour scaler la séance par l'algo).

| Niveau | Vol pic (min/sem pratique pure) | Fréquence | Séance pic (durée) | Nb postures séance pic | Doctrine source |
|---|---|---|---|---|---|
| **beginner** | 90-150 min/sem | 2-3 sessions / sem | 30-45 min | 8-12 postures | Yoga Alliance RYS 200 + Iyengar fundamentals |
| **recreational** | 180-300 min/sem | 3-4 sessions / sem | 45-60 min | 12-18 postures | Iyengar standard class structure / Hatha 60 min |
| **regular** | 360-540 min/sem | 4-5 sessions / sem | 60-75 min | 18-25 postures | Vinyasa flow + Sun Salutation A+B + équilibres |
| **competitive** | 450-720 min/sem | 5-6 sessions / sem | 75-90 min | 60-75 postures (primary series) | Ashtanga primary series Pattabhi Jois (~75 asanas en 75-90 min) |

**Lesson learned #1 (Vol pic en pratique pure)** : Les minutes hors warmup mantra/intention courts (Om, sankalpa, body scan d'ouverture) ne comptent PAS dans le vol hebdo. Seuls comptent : asana, pranayama tenu, meditation tenue, transitions vinyasa. Cooldown Savasana 3-7 min final = COMPTÉ (c'est de la pratique restorative).

**Lesson learned #2 (Conventions volumes harmonisées)** : `summary` ↔ `goal` hebdo ↔ `progression_logic` doivent annoncer EXACTEMENT le même chiffre. Si `summary` dit "vol pic 60 min séance pic 25 postures", `goal` W6 doit dire "60 min, 25 postures" — pas 26 ni 24. **Lesson learned #6 (vérification arithmétique)** : compter les postures dans `weeks[i].sessions[j].exercises[]` qui ont `target_zone` ∈ {`hold-*`, `flow`, `breath-led`} avant de finaliser le `goal` et le `summary`.

**Lesson learned #4 (distribution intensités nuancée yoga)** : pas de % FCmax en yoga. La distribution se mesure sur 4 axes :
1. **Ratio holds vs flow** : beginner 80% hold + 20% flow ; recreational 60/40 ; regular 50/50 ; competitive 30% hold + 70% flow (Ashtanga vinyasa-led).
2. **Ratio respiration / asana / meditation** : beginner 20/70/10 ; competitive 10/85/5 (Ashtanga = quasi-tout asana + 5 min Savasana).
3. **Ratio postures actives (debout, équilibre) vs passives (sol, restorative)** : beginner 50/50 ; competitive 80/20.
4. **Présence inversions** : beginner = 0% ; recreational = inversions au mur seulement (Down Dog, Legs-up-the-wall) ; regular = intro Sirsasana au mur W6+ ; competitive = Sirsasana libre + Sarvangasana + Kapotasana.

---

## Périodisation

### Cycle de base (build / cutback)

- **3 build + 1 cutback** : standard pour `recreational` et `regular`. Volume cutback = -15 à -25% du pic précédent (lesson learned #5).
- **2 build + 1 cutback** : pour `competitive` (charge plus haute, nécessite récup tendon/articulaire car holds longs + inversions répétées).
- **5-6 build + 1 cutback** : pour `beginner` (charge faible, adaptation lente, 1 cutback mid-plan suffit).

**Lesson learned #5 (cutbacks doctrine yoga -15 à -25%)** : Le cutback yoga ne réduit pas le NOMBRE de séances mais :
- Volume hebdo total -15 à -25% (séances raccourcies de 60→45 min ou 75→60 min).
- Suppression des inversions tenues longues (Sirsasana 60s → wall-supported 30s, Sarvangasana → Legs-up-the-wall).
- Plus de Savasana et restorative (12 min au lieu de 5 min).
- Holds réduits d'une étape (60s → 45s, 90s → 60s).
- Pranayama Dirgha-only en cutback (pas d'Ujjayi prolongée si charge cumulée).

### Phases progression (style Iyengar fundamentals → Vinyasa → Ashtanga)

- **Foundation phase** (W1-W3 beginner / W1-W2 recreational+) : postures au sol (Cat-Cow, Child's pose, Cobra), Mountain, intro respiration Dirgha, Savasana 5-7 min.
- **Build phase** (W3-W6 recreational / W3-W8 regular) : intro Surya Namaskar A, Warrior series, équilibres simples (Tree pose), Ujjayi introduit W3+ supervisé, holds 30-45s.
- **Specificity phase** (W6-W10 regular / W4-W12 competitive) : flow continu, Sun Salutation A+B, équilibres complexes (Warrior III, Half Moon), inversions au mur, holds 60-90s.
- **Mastery phase** (`competitive` only) : primary series complète (75 postures), intermediate transition optionnelle, Mysore self-practice possible, holds 90s+ sur postures clés.

### Pas de tapering au sens compétitif

Le yoga n'a pas de "compétition" au sens running/cycling. La dernière semaine d'un plan = **séance phare** + **rétrospective** (auto-évaluation 8-piliers Yoga Alliance). Pour un `competitive` qui prépare un workshop ou retreat, prévoir une semaine -20% volume avant l'événement (récupération articulaire + mental clarté).

---

## Les 5 piliers (Yoga Alliance RYS 200 — extrait curriculum)

Tout template yoga DOIT toucher au minimum 3 des 5 piliers par session, avec une distribution :
- **Asana** (postures) : pilier dominant 60-85% du temps selon niveau (competitive).
- **Pranayama** (respiration) : 5-15% du temps. Dirgha first, Ujjayi W3+ supervisé.
- **Meditation/Dhyana** : 3-10% du temps. Body scan, breath awareness, mantra court (Om).
- **Philosophy** : 2-5% du temps. Notes pédagogiques courtes intégrées dans les `notes` exercice (yamas, niyamas, dhrishti).
- **Drishti** (point de fixation visuelle) : transversal, mentionner dans `notes` à chaque posture d'équilibre (nasagrai = nez, broomadhya = entre les sourcils, parshva = côté).

---

## Renforcement préventif yoga (poignets, cou, lombaires)

Hooks v2 : exercices marqués `volume_axis: reps` ou `sets`, intégrés en warmup OU en séance dédiée 1×/sem `mobility`.

- **beginner** : échauffement poignets obligatoire AVANT toute séance avec Down Dog / Plank / Chaturanga (cercles poignets 10/sens, paumes au mur 30s × 2, étirement fléchisseurs paume vers haut 30s). Cou : pas de Sirsasana, pas de Sarvangasana. Lombaires : Cobra mini-amplitude (sphynx avec coudes au sol).
- **recreational** : ajout poignets — Down Dog "fingers-spread" + paume bien plaquée (heels of hands sous épaules), modifications Chaturanga genoux au sol jusqu'à W6, Setu Bandha (pont) supervisé.
- **regular** : intro Pincha Mayurasana (forearm balance) au mur W8+, Sirsasana au mur uniquement, alignement scapulaire avant tout backbend (Wheel = Urdhva Dhanurasana au mur d'abord).
- **competitive** : pliométrie absente (yoga = static + flow), mais isométriques avancées (handstand hold 60s, Bakasana 30s), travail proprio chevilles/poignets daily.

Sources : [Wrist Pain in Downward Dog — Yoga Journal](https://www.yogajournal.com/practice/wrist-pain-in-downward-facing-dog/), [Chaturanga and Shoulder Injuries — Yoganatomy](https://www.yoganatomy.com/chaturanga-injury-and-shoulder-injuries-in-yoga/), [Strengthen Your Shoulders — Yoga Journal](https://www.yogajournal.com/practice/shoulder-saver-2).

---

## Drapeaux rouges (safety)

### Tous niveaux

- **Douleur poignet en Down Dog / Plank / Chaturanga** : risque n°1 du yogi grand public. Cause : hyperextension répétée 90°. Contre-mesure : tapis pliée sous la paume (réduit angle), Forearm Plank substitution, "fingers-spread" Down Dog, repartir poids vers index + pouce. Si douleur > 3 séances : pause 1 sem + bilan. Source : [Wrist Pain Yoga Journal](https://www.yogajournal.com/practice/wrist-pain-in-downward-facing-dog/).
- **Douleur épaule en Chaturanga** : misalignment fréquent (coudes flare, épaules qui s'effondrent vers le sol). Contre-mesure : "stop at 90° elbow", "shoulder tips lifted", knees-down version jusqu'à 6 mois pratique régulière. Source : [Yoganatomy Chaturanga](https://www.yoganatomy.com/chaturanga-injury-and-shoulder-injuries-in-yoga/).
- **Douleur cervicale en Sirsasana / Sarvangasana** : 40-48% du poids du corps sur la couronne de la tête, 50% des pratiquants à risque de "load failure" cervical. Sirsasana INTERDIT `beginner` + `recreational` sans encadrement direct. Au mur W8+ pour `regular` only. Source : [Sirsasana cervical loading — PubMed](https://pubmed.ncbi.nlm.nih.gov/26118514/).
- **Douleur lombaire en backbends** (Cobra, Wheel, Camel) : hyperextension lombaire compensatoire si fessiers/quadriceps faibles. Contre-mesure : engager fessiers, longueur tirée vers le haut avant cambre, Sphynx (mini-Cobra) en alternative. Si > 2 séances avec douleur : pause backbends 1 sem.
- **Étourdissements en pranayama** : Ujjayi prolongée chez débutant non-supervisé → vasoconstriction. Contre-mesure : limiter Ujjayi 5 min/jour pour beginner (Tummee), Dirgha sans rétention en alternative. Source : [Ujjayi contraindications Tummee](https://www.tummee.com/yoga-poses/ujjayi-pranayama/contraindications).

### Recreational et au-delà

- **Tendinite poignets répétée** sur Surya Namaskar A intensif (vinyasa quotidien) → réduire fréquence 2×/sem, intégrer Forearm Plank.
- **Sciatique** sur torsions profondes (Marichyasana C/D, Ardha Matsyendrasana) : variantes douces (jambe étendue), pas de torsion fermée si grossesse.

### Competitive

- **Sur-mobilité (lax-jointness)** : risque sur 5+ ans de pratique avancée si stretch sans engagement musculaire. Travailler isométriques, contractions actives dans les holds (engager quadriceps en Down Dog).
- **Surentraînement** (oui, ça existe en yoga) : fatigue chronique, baisse motivation, hyperflexibilité douloureuse. Réduire fréquence + augmenter restorative + bilan ostéopathique.

---

## EU MDR — mots bannis et triggers medical clearance

### Mots bannis (texte généré)

- "soigner [pathologie]", "traitement [pathologie]", "guérir", "remède"
- "yoga thérapeutique pour [pathologie]" (dériver vers "yoga adapté", "approche douce")
- "yoga thérapie", "rééducation", "post-blessure", "post-opératoire"
- "diagnostic", "prescription", "ordonnance"
- "soulager [douleur]" → préférer "réduire l'inconfort", "favoriser le confort"
- "désintoxiquer", "détox" (pas d'effet médical prouvé, terme vague non-MDR friendly)
- "guérir le dos / les genoux / les hanches" → "renforcer", "stabiliser", "mobiliser"

### Triggers medical clearance obligatoire

Inclure mention "Consulte un médecin avant de commencer ce programme" dans `safety_notes` si :

- **Hypertension non équilibrée** → "consulte un médecin avant les inversions" (interdire Sirsasana, Sarvangasana, Down Dog tenu > 30s tant que TA non stabilisée).
- **Glaucome / pression intraoculaire** → "pas d'inversions tête en bas" (Sirsasana, Sarvangasana, Down Dog tenu > 30s, Halasana, Adho Mukha Vrksasana).
- **Grossesse** → variantes obligatoires : pas de torsions fermées (Marichyasana C+), pas de ventre au sol (Cobra → Sphynx ou Cat-Cow), pas de pranayama avec rétention, pas d'Ujjayi prolongée. Avis médical de principe au T1.
- **Pathologie cervicale chronique** ou hernie discale C-spine → "pas de Sirsasana, pas de Sarvangasana, pas de Halasana".
- **Antécédents cardiaques** ou décollement de rétine → avis médical avant pranayama avancée + interdiction inversions complètes.
- **Postpartum < 6 semaines** → repos pelvien obligatoire avant reprise asana, Dirgha pranayama allongée OK, pas d'asana actif.
- **Profil > 65 ans débutant complet** → prudence pour postures au sol (lever/coucher) et inversions (interdites).

Sources : [Sirsasana Contraindications PubMed](https://pubmed.ncbi.nlm.nih.gov/26118514/), [Ujjayi Contraindications](https://www.tummee.com/yoga-poses/ujjayi-pranayama/contraindications), [Headstand and Neck Safety — YogaUOnline](https://yogauonline.com/yoga-practice-teaching-tips/yoga-research/headstand-and-neck-safety-in-yoga-what-you-need-to-know/).

---

## Substitutions classiques (alternatives v2 — lesson learned #7 alternatives non vides)

`alternatives: []` vide INTERDIT en yoga. Toujours min 2 alternatives par posture (variante débutant + variante blessé/contrainte).

| Posture planifiée | Alternatives obligatoires | Trigger |
|---|---|---|
| Adho Mukha Svanasana (Down Dog) | Down Dog genoux fléchis ; Down Dog mains au mur (heart-opener) ; Child's pose | Wrist-pain, débutant raideur ischios |
| Chaturanga Dandasana | Chaturanga genoux au sol ; Forearm Plank ; transition directe Cobra sans push-up | Wrist-pain, shoulder-injury, beginner W1-W6 |
| Sirsasana (Headstand) | Adho Mukha Svanasana hold 30s (semi-inversion) ; Legs-up-the-wall (Viparita Karani) ; Dolphin pose (Ardha Pincha) | Cervical-pain, glaucoma, hypertension, beginner+recreational TOUJOURS |
| Sarvangasana (Shoulderstand) | Legs-up-the-wall ; Setu Bandha (pont) avec props | Cervical-pain, hypertension, glaucoma |
| Urdhva Dhanurasana (Wheel) | Setu Bandha (pont fessier) ; Salabhasana (Sauterelle) | Lower-back-pain, débutant, wrist-pain |
| Marichyasana C (torsion fermée) | Ardha Matsyendrasana ouverte ; Bharadvajasana variante | Pregnancy, lower-back-pain |
| Padmasana (Lotus) | Sukhasana (Easy Pose) ; Ardha Padmasana ; Virasana sur bolster | Knee-injury, hanches raides, postpartum |
| Bakasana (Crow) | Bakasana avec briques sous pieds ; Malasana (Garland) ; Squat | Wrist-pain, shoulder-injury |
| Ujjayi pranayama prolongée | Dirgha (3-part breath) ; respiration naturelle observée 5 min | Hypertension, pregnancy, débutant W1-W2, anxiety/panic |
| Vinyasa flow Surya Namaskar A | Sun Salutation modifié (sans Chaturanga, knees-down) ; Cat-Cow flow | Beginner, wrist-pain, fatigue cumulée |

---

## Hooks metadata standards (yoga)

### `target_zone`
Valeurs autorisées :
- `breath-led` : flow guidé respiration (Surya Namaskar, Cat-Cow)
- `hold-30s`, `hold-45s`, `hold-60s`, `hold-90s` : tenue statique selon durée
- `flow` : séquence dynamique multi-postures
- `restorative` : posture longue avec props
- `RPE 4-5`, `RPE 6-7` : effort perçu pour postures actives sans cardio référence
- `meditation` : assise pranayama / dhyana

### `required_equipment`
Vocabulaire kebab-case :
- `mat` : OBLIGATOIRE à toute séance — mentionner explicitement dans la première posture, ne jamais omettre.
- `yoga-block` ou `block` : briques (1-2 selon usage), recommandé `beginner` + `recreational` pour Triangle, Half Moon, Padmasana modifié.
- `strap` : sangle, recommandé `beginner` + `recreational` pour étirements ischios, Paschimottanasana, Gomukhasana bras.
- `bolster` : restorative, prenatal, Supta Baddha Konasana, Savasana renforcé.
- `blanket` : tampon cervical Sirsasana/Sarvangasana, support Savasana hiver.
- `wall` : référence alignement Iyengar (Down Dog mains au mur, Sirsasana au mur, Vrksasana support).
- `chair` : optionnel `beginner` âgé / mobilité réduite (Iyengar chair-yoga).
- `eye-pillow` : optionnel Savasana approfondi.

### `incompatible_constraints`
Vocabulaire kebab-case :
- `wrist-pain`, `cervical-pain`, `lower-back-pain`, `shoulder-injury`, `knee-injury`, `ankle-injury`
- `pregnancy`, `postpartum-early` (< 6 sem)
- `cardiac-clearance-required`, `hypertension`, `hypotension`
- `glaucoma`, `detached-retina`
- `osteoporosis`, `osteopenia`
- `recent-concussion`, `frequent-headaches`, `vertigo`
- `ear-infection`, `sinus-infection`
- `menstruation` (mention optionnelle Iyengar tradition pour inversions, à laisser au choix utilisateur)

### `alternatives`
Liste de noms d'exercices substitutifs (cf. tableau Substitutions ci-dessus). **Lesson learned #7 : `alternatives: []` vide INTERDIT** — toujours min 2 alternatives par posture (variante débutant accessible + variante constraint-friendly).

### `volume_axis`
- `duration` (par défaut pour holds, restorative, pranayama, meditation, Savasana)
- `reps` (pour cycles Surya Namaskar A/B compteur — ex: "5 cycles Surya Namaskar A")
- `sets` (séquence Warrior I→II→III × 3 côté)
- Pas de `distance` en yoga.

---

## `week_structure` typique par niveau

| Niveau | type | micro_pattern | recovery_cadence |
|---|---|---|---|
| **beginner** | `linear` | `foundation au sol + foundation debout + integration` (2-3 sessions) | `1 cutback W4 ou W5 sur plan 8 sem` |
| **recreational** | `linear` | `Hatha doux + Sun Salutation intro + restorative` | `1 deload toutes les 4 semaines` |
| **regular** | `block` | `Vinyasa flow + équilibres + intro inversions wall + restorative` | `1 deload toutes les 3-4 semaines` |
| **competitive** | `block` | `primary series 1/2 + primary series complète + Mysore self-practice + restorative + meditation` | `1 deload toutes les 3 semaines` |

`deload_weeks` exemples :
- Plan 8 sem `beginner` : `[5]`
- Plan 12 sem `recreational` : `[4, 8]`
- Plan 12 sem `regular` : `[4, 8]`
- Plan 16 sem `competitive` : `[4, 8, 12]`

---

## Sources yoga

### Doctrine et lineage
- [Light on Yoga — Wikipedia](https://en.wikipedia.org/wiki/Light_on_Yoga)
- [Iyengar Yoga — Wikipedia](https://en.wikipedia.org/wiki/Iyengar_Yoga)
- [Light on Yoga — Yoga Education Institute PDF](https://yogaeducation.org/wp-content/uploads/2019/05/Iyengar-yoga.pdf)
- [Light on Pranayama — Mantra Yoga School PDF](https://mantrayogameditation.org/wp-content/uploads/2019/12/Iyengar-BKS-Light-on-Pranayama-OCR.pdf)
- [Tirumalai Krishnamacharya — Wikipedia](https://en.wikipedia.org/wiki/Tirumalai_Krishnamacharya)
- [Vinyasa Krama: Art of Intelligent Progression — Sutrix](https://www.sutrix.app/knowledge-base/yoga-fundamentals/vinyasa-krama/)
- [Common Yoga Styles in Krishnamacharya Lineage — Yogateket](https://www.yogateket.com/blog/the-common-yoga-styles-in-krishnamacharya-lineage)

### Ashtanga primary series
- [Ashtanga vinyasa yoga — Wikipedia](https://en.wikipedia.org/wiki/Ashtanga_vinyasa_yoga)
- [Ashtanga Yoga Primary Series Complete Guide — myYogaTeacher](https://myyogateacher.com/articles/ashtanga-yoga-primary-series-guide)
- [Mastering Ashtanga Primary Series — Rishikesh Yoga Nirvana](https://rishikeshyognirvana.com/ashtanga-primary-series/)
- [Ashtanga Yoga Practise Sheets Primary/Intermediate/Advanced — Ashtanga Philippa](http://ashtangaphilippa.com/ashtanga-yoga-practise-sheets-and-resources/)

### Yoga Alliance standards
- [Standards for Registered Yoga Schools — Yoga Alliance PDF](https://yogaalliance.org/wp-content/uploads/2025/05/Standards-for-RYS-Credentials_NB22my-.pdf)
- [Yoga Alliance Tests in 200-Hour Training — Yoga Journal](https://www.yogajournal.com/teach/200-hour-standards/)
- [New Yoga Alliance Standards — Siddhi Yoga](https://www.siddhiyoga.com/yoga/teach/new-yoga-alliance-standards)

### Pranayama
- [Three-Part Breath Dirgha Pranayama — Prana Sutra](https://www.prana-sutra.com/post/three-part-breath-dirgha-pranayama-yoga-technique)
- [Dirgha Pranayama Three Part Breath — Babymed](https://www.babymed.com/prenatal-yoga/breathing-practice-dirgha-pranayama-or-three-part-breath)
- [Ujjayi Pranayama Steps Benefits Contraindications — Shivoham Yoga](https://shivohamyogaschool.com/pranayama/ujjayi-pranayama-contra-indications-and-benefits/)
- [Ujjayi Contraindications — Tummee](https://www.tummee.com/yoga-poses/ujjayi-pranayama/contraindications)
- [Pranayama Primer — Yoga Simple](http://yogasimple.net/pranayama-primer/)
- [Ujjayi Breath Blessing or Curse — Himalayan Yoga Institute](https://www.himalayanyogainstitute.com/ujjayi-breath-blessing-curse/)

### Sécurité poignets / épaules / cou
- [Wrist Pain in Down Dog — Yoga Journal](https://www.yogajournal.com/practice/wrist-pain-in-downward-facing-dog/)
- [Next-Level Wrist Protection — Yoga Journal](https://www.yogajournal.com/practice-section/protecting-your-wrists/)
- [How to Avoid Wrist Pain Down Dog — Pilgrimage of the Heart](https://pilgrimageyoga.com/blog/how-to-avoid-wrist-pain-in-downward-facing-dog/)
- [Chaturanga and Shoulder Injuries — Yoganatomy](https://www.yoganatomy.com/chaturanga-injury-and-shoulder-injuries-in-yoga/)
- [Shoulder Saver Rotator Cuff — Yoga Journal](https://www.yogajournal.com/practice/shoulder-saver-2)
- [How to Avoid Injury in Chaturanga — Bayou Yoga](https://dobayouyoga.com/how-to-avoid-injury-in-chaturanga-by-creating-stability/)
- [Sirsasana Cervical Loading PubMed](https://pubmed.ncbi.nlm.nih.gov/26118514/)
- [Headstand and Neck Safety — YogaUOnline](https://yogauonline.com/yoga-practice-teaching-tips/yoga-research/headstand-and-neck-safety-in-yoga-what-you-need-to-know/)
- [Friday Q&A: The Safety of Headstand — Yoga for Times of Change](https://www.yogafortimesofchange.com/friday-q-safety-of-headstand-sirsasana/)
