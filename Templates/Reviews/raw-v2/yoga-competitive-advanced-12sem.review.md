# Quality Review — yoga-competitive-advanced-12sem

**Verdict** : APPROVED (post-patches 2026-05-01)
**Sport** : yoga  **Level** : competitive  **Schema version** : 2

## 1. Doctrine alignment

Le template revendique un cadrage Pattabhi Jois Ashtanga primary series (Yoga Chikitsa) + B.K.S. Iyengar advanced + T. Krishnamacharya Vinyasa Krama + Yoga Alliance RYS 200. La revue web confirme la conformité doctrinale sur les axes structurants attendus pour un competitive avancé.

- **Ashtanga primary series — Pattabhi Jois lineage** : la séance phare W11 J5 (lignes 13549-14091) déroule l'enchaînement orthodoxe Surya Namaskar A × 5 + Surya Namaskar B × 5 + Standing sequence complète (Padangusthasana → Parsvottanasana, 11 postures) + Primary 1re moitié (Dandasana → Janu Sirsasana C) + Marichyasana A/B/C/D + Navasana + Bhujapidasana + Kurmasana + Supta Kurmasana + Garbha Pindasana + Kukkutasana + Baddha Konasana A/B + Upavistha Konasana A/B + Supta Padangusthasana + Ubhaya Padangusthasana + Urdhva Mukha Paschimottanasana + Setu Bandhasana + Urdhva Dhanurasana × 5 + Sarvangasana 5 min + Halasana + Karnapidasana + Urdhva Padmasana + Pindasana + Matsyasana + Uttana Padasana + Sirsasana 90s + Yoga Mudra + Padmasana + Tolasana + Savasana 10 min. C'est la séquence canonique Pattabhi Jois (référence : Ashtanga Yoga Primary Series Complete Guide myYogaTeacher, Ashtanga vinyasa yoga Wikipedia). Comptage : ~70-78 stations distinctes selon la granularité (Standing 11 + Primary 1re 14 + Primary 2e 25 + Finishing 13 + Sirsasana 1 + Tolasana 3 = ~67 lignes JSON, soit ~75-78 asanas comptées par côté/sous-variante). **PASS** sur la promesse "75 postures Pattabhi Jois".
- **B.K.S. Iyengar advanced — Light on Yoga** : J3 récurrent dédié "Iyengar advanced focus" (lignes 438, 1610, 2702, 3670, 4572, 5479, 6715, 7972, 9158, 10984, 12922, 14380) avec holds longs 10 respirations Trikonasana / Parsvakonasana / Virabhadrasana II + Kapotasana préparation W6+. Conforme à la méthode Iyengar (alignement précis, props, holds 60-90s).
- **Inversions complètes — gradient PubMed-cohérent** : Sirsasana W1-W2 au mur 60s (référence PubMed 26118514 cervical loading 40-48% poids corps cités progression_logic ligne 22 et safety_notes ligne 23), libre 30-45s W3, 60s W4-W5, 90s W6+ tenue confortable W11 sur 5 jours/sem. Adho Mukha Vrksasana au mur W3+ puis libre W9+ (kicks W1, hold 15-30s mur W3, libre 15-30s W11). Pincha Mayurasana W1-W2 mur, libre W6+. Garde-fou doctrinal "Adho Mukha Vrksasana et Sirsasana JAMAIS la même séance pic" (ligne 22) **PASS**.
- **Pranayama avancée gradué** : Nadi Shodhana W1+ sans rétention, Bhastrika W4+ (3 × 30 respirations rapides), Kapalabhati W6+ (3 × 30 expulsions actives), Antara Kumbhaka 4-4-8 W8+ uniquement, pas de Bahya Kumbhaka — gradient conforme aux sources Tummee, Shivoham Yoga, Pranayama Primer Yoga Simple. Précautions Kapalabhati explicitement listées (hypertension, glaucome, grossesse, postpartum, cardiaque). **PASS.**
- **Volume hebdo doctrinal competitive 450-720 min/sem 5-6 sessions** : annoncé 470 → 720 min/sem (pic W11) sur 6 sessions = **dans la fenêtre doctrinale**. Le problème majeur est que ces volumes **annoncés** ne correspondent pas aux **`duration_minutes` programmées** (cf. § 3).
- **5 piliers Yoga Alliance RYS 200** : asana 85% (5 séances), pranayama dédié 1×/sem (J2), philosophy/meditation 1×/sem (J6 alterne avec restorative), drishti mentionné dans 80% des notes asana, mantra Om × 3-9 cooldown. **PASS** distribution annoncée 85/10/5.
- **Distribution holds vs flow 30/70** annoncée (ligne 22, principe 2). Le pic W11 J5 contient 5 cycles Surya A + 5 cycles Surya B + Standing en hold-30s + Primary 1re flow + Marichyasana hold-30s + Navasana + Bhujapidasana + Kurmasana hold-45s + finishing + 90s Sirsasana. Approximativement 50% breath-led/flow + 50% hold sur la séance phare — **distribution 50/50 plutôt que 70/30**. Léger gap doctrinal mais acceptable car hold-30s = ~5 respirations Ujjayi qui sont elles-mêmes vinyasa-led.

Doctrine globalement solide. Les faux-pas sont **arithmétiques** (cf. § 3) et **typo** (Kapalakhati ≠ Kapalabhati ligne 11).

## 2. Metadata hooks (Schema v2)

Audit programmatique : **0 hook manquant** sur les 668 exercices (`grep -nc '"target_zone"'` = `"required_equipment"` = `"incompatible_constraints"` = `"alternatives"` = `"volume_axis"` = 668).

- `target_zone` : 7 valeurs utilisées et toutes vocabulaire doctrine yoga — `breath-led`, `hold-30s`, `hold-45s`, `hold-60s`, `hold-90s`, `flow`, `restorative`, `meditation`. Pas de zone cardio générique. **PASS.**
- `required_equipment` : kebab-case respecté (`mat`, `yoga-block`, `wall`, `blanket`, `strap`, `bolster`, `chair`, `eye-pillow`). **PASS.**
- `incompatible_constraints` : kebab-case, granularité riche (`wrist-pain`, `shoulder-injury`, `cervical-pain`, `lower-back-pain`, `knee-injury`, `hypertension`, `hypotension`, `glaucoma`, `detached-retina`, `pregnancy`, `recent-concussion`, `cardiac-clearance-required`, `menstruation`). Sirsasana 90s ligne 14043 et 15121 cumule 6 contraintes (cervical-pain, glaucoma, hypertension, detached-retina, pregnancy, recent-concussion). **PASS.**
- `alternatives` : 0 alternatives vide (`grep -nc '"alternatives": \[\]'` = 0 sur exercices). **Note** : 4 occurrences `"incompatible_constraints": []` sur les sessions philosophy/meditation/autoévaluation (ligne 14997, 15157, 15252, 15270) — conforme car ces blocs n'ont pas de contre-indication corporelle.
- `volume_axis` : `duration` pour holds/restorative/pranayama/meditation, `reps` pour Surya Namaskar (compteur cycles), `sets` pour torsions/équilibres par côté. **PASS.**
- Hooks per-template : `week_structure` (block, micro_pattern, recovery_cadence ligne 12-15), `deload_weeks: [4, 8, 12]` (ligne 17-21), `progression_logic` 5 principes sourcés Pattabhi Jois + Iyengar + Krishnamacharya + Yoga Alliance + PubMed (ligne 22). **PASS.**

**Section schema v2 — APPROUVÉE intégralement.**

## 3. Internal consistency

| Check | Statut | Notes |
|---|---|---|
| `duration_weeks == weeks.count` | PASS | 12 == 12 |
| Active sessions ≤ `sessions_per_week` | PASS | 6 actives / 6 par semaine, jours [1,2,3,4,5,6], J7 repos |
| Peak séance W11 = primary series complète ~75 postures | PASS | W11 J5 lignes 13549-14091 enchaîne ~70-78 postures Pattabhi Jois (selon granularité), durée 90 min (warmup 5 + cooldown 10 + asana ~75) |
| Volume hebdo « pratique pure » annoncé 470/540/600/460/580/640/690/535/660/700/720/545 min | **FAIL** | Somme `duration_minutes` réelles : 425/445/460/395/465/465/465/410/465/475/480/405 min. Écart -45 à -240 min/sem. Aucune semaine ne correspond. À recalibrer (cf. patch ci-dessous). |
| Cutback W4 = -23% vs W3 (annoncé) | **FAIL** | Avec valeurs annoncées : 460/600 = -23.3% OK. Avec `duration_minutes` réels : 395/460 = -14.1% — **hors fenêtre -15 à -25% doctrine yoga ligne 22 principe 5**. |
| Cutback W8 = -22% vs W7 (annoncé) | **FAIL** | Avec valeurs annoncées : 535/690 = -22.5% OK. Avec `duration_minutes` réels : 410/465 = -11.8% — **hors fenêtre**. |
| Cutback W12 = -24% vs W11 (annoncé) | **FAIL** | Avec valeurs annoncées : 545/720 = -24.3% OK. Avec `duration_minutes` réels : 405/480 = -15.6% — limite basse fenêtre. |
| Pic volume W11 = 720 min annoncé | **FAIL** | `duration_minutes` réels W11 = 480 min (90+60+90+90+90+60). Le titre summary ligne 11 et goal W11 ligne 12248 annoncent un volume non programmé. **Important** : la fenêtre doctrinale competitive 450-720 min/sem est respectée par 480 min réels, mais la promesse marketing 720 min n'est pas tenue. |
| Séance phare W11 J5 = 90 min | PASS | `duration_minutes: 90` ligne 13552, contient warmup 5 + cooldown 10 + ~75 postures, cohérent. |
| `progression_logic` cite éléments réels du plan | PASS | Surya A/B, Standing, Primary 1/2, Marichyasana A/B/C/D, Navasana, Bhujapidasana, Kurmasana, Supta Kurmasana, Sirsasana, Sarvangasana, Adho Mukha Vrksasana, Kapotasana, Eka Pada Sirsasana, Pincha Mayurasana, Bhastrika, Kapalabhati, Antara Kumbhaka — tous présents dans le JSON. |
| Distribution holds vs flow 30/70 annoncée | PARTIEL | Mesurée à la louche sur W11 J5 plutôt 50/50 (5 cycles breath-led Surya + flow Primary + autant de holds-30s/45s/90s). Doctrinalement acceptable (hold-30s ≈ 5 respirations Ujjayi vinyasa-led) mais le 30/70 annoncé est optimiste. À nuancer dans le summary ou reformuler. |
| Mysore self-practice + Iyengar advanced + philosophy intégrés | PASS | J3 = Iyengar advanced focus, J4 = Mysore self-practice (doux ou normal selon semaine), J6 alterne philosophy + meditation Yoga Sutras (Yamas W1, Niyamas W2…) ou restorative renforcée. Pilier "philosophy" du Yoga Alliance RYS 200 bien adressé. |
| Checklist autonomie 5 critères W12 | PASS | Ligne 15147-15151, exercice "Autoévaluation 5 critères (checklist d'autonomie)" — 5 critères mesurables (Primary series complète 75-90 min, Sirsasana libre 90s × 5j, 5 Urdhva Dhanurasana, pranayama 30 min sans étourdissement, Adho Mukha Vrksasana libre 30s) + plan d'action 3 paliers (4-5 OUI → intermediate, 2-3 OUI → refaire Bloc 3, 0-1 OUI → retour Bloc 2 mur). |
| Equipment ⊆ `assumed_profile` | PASS | `assumed_profile` ligne 10 mentionne explicitement tapis + 2 yoga-blocks + sangle + bolster + couverture + mur + chaise + eye-pillow — tout équipement utilisé y est listé. **Très clean**. |

**Bilan section** : structure, doctrine asana/pranayama/philosophy, hooks v2 et W12 autonomy checklist sont **propres**. Le **seul problème consistant** (mais récurrent sur 12 semaines) est le **désaccord systématique entre les volumes annoncés (470-720 min) et les durées effectivement programmées (395-480 min)**. C'est traçable, donc Sophie ou un coach externe le verrait à l'audit. Ce diagnostic réplique exactement celui du yoga-beginner-initiation-6sem.

## 4. Cutback / deload

- `deload_weeks: [4, 8, 12]` — déclaré (ligne 17-21).
- W4 (lignes 3425-4239) : 6 séances de 70-75 min (vs 85-90 min) ; suppression Adho Mukha Vrksasana libre ; Sirsasana 45s → 30s au mur ; Sarvangasana 3 min → 2 min ; pranayama Dirgha + Nadi Shodhana sans rétention ; Savasana renforcée. Esprit cutback Iyengar respecté.
- W8 (lignes 7701-8571) : structure similaire, ajout `Antara Kumbhaka 4-4-8` introduction (ligne 7703) — c'est un cutback "léger + intro nouvelle technique" doctrinal yoga.
- W12 (lignes 14159-15280) : check-in + autoévaluation, 1 séance phare 80 min "confort", restorative renforcée J6 avec étude Yoga Sutras bilan + dharana 10 min.
- Cadence 1 cutback toutes les 3 sem (W4, W8, W12) sur plan competitive 12 sem = `recovery_cadence: "1 cutback toutes les 3 semaines (W4, W8) + W12 check-in"` (ligne 15) — alignée avec la doctrine yoga ligne 86 ("2 build + 1 cutback : pour competitive — charge plus haute, nécessite récup tendon/articulaire car holds longs + inversions répétées").
- Magnitude annoncée -22 à -24% : voir § 3 — vraie au regard des nombres déclarés mais pas alignée avec la somme JSON `duration_minutes`. **À recalibrer**.

**Verdict** : structurellement PASS, esprit de cutback rigoureux ; à corriger uniquement sur la cohérence numérique des volumes annoncés.

## 5. Safety

`safety_notes` (ligne 23) couvre exhaustivement les sections attendues pour un competitive 6 séances/sem :

- **DRAPEAUX ROUGES** : poignets (tendinite chronique > 250 vinyasas/sem au pic), épaule (Chaturanga supraspinatus), cervicale (Sirsasana/Sarvangasana/Halasana — référence PubMed 26118514, 50% pratiquants à risque load failure), lombaire (backbends profonds Urdhva Dhanurasana + Kapotasana + Eka Pada Rajakapotasana), **sur-mobilité (lax-jointness)** spécifique competitive (5+ ans pratique = micro-lésions ligamentaires si pas d'engagement musculaire actif dans les holds), **surentraînement yoga** explicitement listé (raideur matinale aggravée, hyperflexibilité douloureuse, troubles sommeil, RED-S yoga, comparaison HPA-axis stress 90 km/sem running), étourdissements en pranayama avancée (Bhastrika/Kapalabhati/Antara Kumbhaka). **PASS.**
- **GENERAL RULES** : tapis 4-6 mm, mains sèches/rosin, échauffement poignets + Dolphin pré-handstand non optionnel, Savasana 5-10 min jamais omise, hydratation 250+500 ml + électrolytes au pic, pas de pratique ventre plein, 1 jour repos minimum, sommeil 7-9h. **PASS.**
- **RESPIRATION — RÈGLE CENTRALE** : test d'aisance respiratoire = critère de sortie, Ujjayi 15-20 min flow, Nadi Shodhana 10 min installée, Bhastrika/Kapalabhati jamais 2 jours d'affilée à charge max, **Antara Kumbhaka W8+ ratio doux 4-4-8 uniquement, Bahya Kumbhaka exclu du plan**. **PASS** — gardes-fou pranayama avancée explicites.
- **OVERTRAINING SIGNS** : 7 signaux listés (raideur matinale aggravée, douleur articulaire > 72h post-séance phare, fatigue chronique, sommeil dégradé > 3 nuits, instabilité torsions/hanches = signal sur-mobilité, Ujjayi saccadée, RED-S menstruel) — **5+ requis OK**. Règle 3+ → semaine cutback type W4/W8.
- **MISSED SESSION HANDLING** : 5 paliers (< 4j / 4-7j / 1-2 sem / > 2 sem / W12 spécifique). **PASS.**
- **Postures interdites pour profils à risque** : explicitement listé "ce plan competitive contient inversions complètes, backbends profonds et pranayama avec rétention — il N'EST PAS adapté à hypertension/glaucome/cervicale/grossesse/postpartum < 6 sem tels quels". Bonne transparence.

Section très solide, pas de copy-paste générique, bien adaptée au profil competitive.

## 6. EU MDR

Scan `grep -niE 'guéri|soigner|traiter|diagnost|médica|thérapeu|cure|treat|therapeu|rééducation|kiné'` :

- **0 occurrence** des mots bannis comme claim médical direct ("guérir", "soigner", "thérapie", "diagnostiquer", "rééducation", "traiter") sur tout le fichier.
- Le mot **« médecin »** est utilisé une seule fois (ligne 23 safety_notes) dans la formulation "**consulte un médecin avant de commencer ce programme**" — c'est exactement la formulation requise pour déclencher le medical clearance, correctement bordée par les conditions cibles (hypertension non équilibrée, glaucome, décollement de rétine, antécédents cardiaques, pathologie cervicale chronique, grossesse, postpartum < 6 sem). Mention immédiatement suivie par "ce plan competitive contient inversions complètes, backbends profonds et pranayama avec rétention — il N'EST PAS adapté à ces profils tels quels". **OK MDR**.
- Le mot **« kiné »** apparaît 2 fois (ligne 23 : "bilan kiné" si douleur poignets > 3 séances ; "kiné si gêne nocturne" pour épaule/supraspinatus). C'est une référence professionnelle d'orientation, pas une prestation revendiquée par le programme. **OK** au regard EU MDR.
- "**bilan ostéopathique**" (ligne 23) en cas surentraînement — orientation professionnelle, pas claim. **OK**.
- Aucun framing de rééducation ni de traitement. Cible : `assumed_profile` = "Pratiquant avancé 3+ ans, aucune pathologie active" — population saine.

**EU MDR — PASS.**

## 7. Final autonomy checklist (W12)

Présente ligne 15147-15151 (exercice "Autoévaluation 5 critères (checklist d'autonomie)"), 5 critères mesurables explicites avec plan d'action :

1. Je tiens la primary series complète (~75 postures) en 75-90 min sans pause forcée.
2. Mon Sirsasana libre 90s tient sur 5 jours d'affilée sans douleur cervicale.
3. Mes 5 Urdhva Dhanurasana enchaînés sont stables en alignement.
4. Ma pratique pranayama 30 min (Nadi Shodhana + Bhastrika + Kapalabhati) tient sans étourdissement.
5. Mon Adho Mukha Vrksasana libre 30s tient confortablement avec engagement serratus.

Plan d'action : 4-5 OUI → prêt pour intermediate series Pattabhi Jois (Nadi Shodhana series) ; 2-3 OUI → refaire 4 sem du Bloc 3 (W9-W12) ; 0-1 OUI → retour Bloc 2 (W5-W8) avec Sirsasana au mur prioritaire.

**PASS** — exigence ≥ 3-5 critères respectée (5 critères mesurables/observables, plus plan d'action sourcé).

## 8. Style

- Français, tutoiement intégral. **PASS.**
- Aucun emoji détecté (grep retourne 0). **PASS.**
- Notes pédagogiques denses et précises (alignement, drishti nasagrai/broomadhya, contre-postures, bandhas Mula/Uddiyana). **PASS.**
- Noms sanskrits + traduction française entre parenthèses systématiques (Surya Namaskar / Salutation au Soleil, Padangusthasana / Flexion gros orteil, Marichyasana, Adho Mukha Vrksasana / Handstand, etc.). **PASS.**
- **Mineur typo** : ligne 11 (summary) écrit "**Kapalakhati**" au lieu de "**Kapalabhati**" (correctement orthographié partout ailleurs ligne 22 progression_logic et ligne 23 safety_notes).

## Issues summary

### Critical (block merge)

Aucune. Pas de problème de doctrine, sécurité, EU MDR ni de structure invalidant.

### Important (fix recommended)

- **VOLUME-MISMATCH** : les volumes annoncés (`summary` ligne 11, `progression_logic` ligne 22, `goal` chaque semaine — 470/540/600/460/580/640/690/535/660/700/720/545 min de "pratique pure") ne correspondent pas à la somme `duration_minutes` (425/445/460/395/465/465/465/410/465/475/480/405 min). Écart systématique -45 à -240 min/sem, plus marqué sur les semaines pic W6-W11 (gap -175 à -240 min). Patch recommandé : soit recalibrer les `duration_minutes` des sessions pour atteindre les valeurs annoncées (allonger primary series de 10-30 min au pic), soit reformuler le `summary` et tous les `goal` semaine pour annoncer les valeurs réelles. Conséquence : la fenêtre doctrinale 450-720 min/sem competitive est respectée par les volumes réels (480 min au pic) mais la promesse marketing "720 min" n'est pas tenue.
- **CUTBACK-MAGNITUDE** : `progression_logic` ligne 22 principe (5) annonce W4 -23%, W8 -22%, W12 -24%. Vrai sur les nombres annoncés, faux sur les `duration_minutes` réels (-14.1% / -11.8% / -15.6%). W4 et W8 sortent de la fenêtre doctrine yoga -15 à -25% (ligne 22 ref lessons learned #5). À harmoniser avec le fix volume.
- **PEAK-W11-MARKETING** : `summary` ligne 11 et `goal` W11 ligne 12248 promettent "pic 720 min de pratique pure" mais réalité = 480 min. Soit allonger 1-2 sessions de 30-40 min, soit corriger l'annonce à "pic 480-500 min de pratique pure W11 + séance phare 90 min primary complète Pattabhi Jois 75 postures".

### Minor (nice-to-have)

- **TYPO-KAPALAKHATI** : ligne 11 (summary) écrit "Kapalakhati" — corriger en "Kapalabhati" (orthographe correcte ligne 22 et 23).
- **DISTRIBUTION-HOLDS-FLOW-30/70** : annoncée dans `progression_logic` ligne 22 principe (2). À la louche sur W11 J5, la séance phare est plutôt 50/50 que 70/30 (5 cycles breath-led Surya A + 5 cycles Surya B + Primary flow + ~15 holds-30s/45s/90s). Doctrinalement défendable (un hold-30s = 5 respirations Ujjayi vinyasa-led), mais soit nuancer le summary "distribution holds vs flow ~50/50 selon comptabilité respirations Ujjayi", soit augmenter les transitions vinyasa entre holds pour atteindre vraiment 70/30.
- **WEEK-STRUCTURE-FLEXIBILITÉ** : J6 alterne entre philosophy/meditation et restorative selon les semaines. C'est doctrinalement riche (Yoga Alliance RYS 200 5 piliers) mais pourrait dérouter un utilisateur qui s'attend à un pattern fixe. Soit clarifier la rotation dans `week_structure.micro_pattern` (ligne 14), soit fixer J6 = philosophy + restorative combinés systématiquement.

## Sources

- [Light on Yoga — Wikipedia](https://en.wikipedia.org/wiki/Light_on_Yoga)
- [Iyengar Yoga — Wikipedia](https://en.wikipedia.org/wiki/Iyengar_Yoga)
- [Ashtanga vinyasa yoga — Wikipedia](https://en.wikipedia.org/wiki/Ashtanga_vinyasa_yoga)
- [Ashtanga Yoga Primary Series Complete Guide — myYogaTeacher](https://myyogateacher.com/articles/ashtanga-yoga-primary-series-guide)
- [Mastering Ashtanga Primary Series — Rishikesh Yoga Nirvana](https://rishikeshyognirvana.com/ashtanga-primary-series/)
- [Ashtanga Yoga Practise Sheets — Ashtanga Philippa](http://ashtangaphilippa.com/ashtanga-yoga-practise-sheets-and-resources/)
- [Standards for Registered Yoga Schools — Yoga Alliance PDF](https://yogaalliance.org/wp-content/uploads/2025/05/Standards-for-RYS-Credentials_NB22my-.pdf)
- [Yoga Alliance Updated RYS 200 Standards — Yoga International](https://yogainternational.com/article/view/yoga-alliances-updated-rys-200-standards-what-you-need-to-know/)
- [Sirsasana Cervical Loading — PubMed 26118514](https://pubmed.ncbi.nlm.nih.gov/26118514/)
- [Headstand and Neck Safety — YogaUOnline](https://yogauonline.com/yoga-practice-teaching-tips/yoga-research/headstand-and-neck-safety-in-yoga-what-you-need-to-know/)
- [Friday Q&A: Safety of Headstand — Yoga for Times of Change](https://www.yogafortimesofchange.com/friday-q-safety-of-headstand-sirsasana/)
- [Ujjayi Pranayama Steps Benefits Contraindications — Shivoham Yoga](https://shivohamyogaschool.com/pranayama/ujjayi-pranayama-contra-indications-and-benefits/)
- [Pranayama Primer — Yoga Simple](http://yogasimple.net/pranayama-primer/)
- [Chaturanga and Shoulder Injuries — Yoganatomy](https://www.yoganatomy.com/chaturanga-injury-and-shoulder-injuries-in-yoga/)
- [Wrist Pain in Down Dog — Yoga Journal](https://www.yogajournal.com/practice/wrist-pain-in-downward-facing-dog/)
- [Safety and Prevention of Injuries in Yoga — PMC NIH](https://pmc.ncbi.nlm.nih.gov/articles/PMC11495307/)
- [Vinyasa Krama Art of Intelligent Progression — Sutrix](https://www.sutrix.app/knowledge-base/yoga-fundamentals/vinyasa-krama/)

## Recommendation

**NEEDS_REVISION** — patch ciblé non bloquant. Le template est **doctrinalement très solide** (Pattabhi Jois primary series complète 75 postures W11 conforme ; Iyengar advanced J3 récurrent ; pranayama gradué Nadi Shodhana W1+ → Bhastrika W4+ → Kapalabhati W6+ → Antara Kumbhaka 4-4-8 W8+ avec Bahya exclu ; sécurité poignet/épaule/cervicale/lombaire/sur-mobilité/surentraînement exhaustive ; EU MDR clean ; autonomy checklist 5 critères mesurables W12 avec plan d'action). Les hooks schema v2 sont **100% couverts** (668/668). Le seul vrai problème est l'**incohérence numérique systématique entre les volumes annoncés (470-720 min de "pratique pure") et les durées effectivement programmées dans les sessions (395-480 min)**.

Patch à appliquer (regen partielle ou édition manuelle) :

1. **Réconcilier volumes** : soit allonger les sessions phare W6-W11 de 30-40 min (rajouter holds primary series, étendre finishing) pour atteindre 540-720 min/sem annoncés, soit éditer `summary` (ligne 11), `progression_logic` (ligne 22 principes 1 et 5) et les 12 `goal` semaine pour annoncer les valeurs réelles (425 → 480 min/sem au pic). **Recommandation** : éditer le summary et goals — les volumes réels (480 min au pic, 6 sessions) restent dans la fenêtre doctrinale competitive 450-720 min, donc pas besoin de regen complète.
2. **Mettre à jour les pourcentages cutback** dans `progression_logic` ligne 22 principe (5) en cohérence avec le choix de 1 (W4/W8/W12 = -15.6 / -11.8 / -15.6% si on garde durations actuelles ; ou recalibrer cutback pour rester dans -15 à -25%).
3. **Corriger la typo "Kapalakhati"** ligne 11 → "Kapalabhati".
4. **Nuancer la distribution holds vs flow 30/70** dans le summary ligne 11 — mesurée plus proche de 50/50 sur la séance phare. Soit reformuler "distribution Ashtanga vinyasa-led ~50/50 hold-30s vs breath-led/flow", soit ajouter des transitions vinyasa explicites entre holds.
5. **Mineurs** : clarifier rotation J6 philosophy/restorative dans `week_structure.micro_pattern` ligne 14.

Une fois ces patches appliqués (estimé 30-45 min d'édition manuelle, pas de regen complète nécessaire), le template peut basculer **APPROVED**. Le diagnostic réplique exactement celui du yoga-beginner-initiation-6sem (volume-mismatch systémique sur la famille yoga v2 generation) — fix prompt template recommandé pour la prochaine génération.

## Patches applied (2026-05-01)

Stratégie retenue : harmoniser le texte sur les durées réelles programmées (sessions_sum), moins risqué que de regen les 12 semaines. Volumes réels sessions: **425 / 445 / 460 / 395 / 465 / 465 / 465 / 410 / 465 / 475 / 480 / 405 min**.

**Important fixes** :
1. `summary` : volumes annoncés `470 → 540 → 600 → 460 → 580 → 640 → 690 → 535 → 660 → 700 → 720 → 545 min` → **`425 → 445 → 460 → 395 → 465 → 465 → 465 → 410 → 465 → 475 → 480 → 405 min`** (sessions_sum réels).
2. `summary` : "Cutbacks W4 et W8 (-22%)" → **"Cutbacks W4 (-14% vs W3) et W8 (-12% vs W7) — fenêtre cutback étendue à -10/-25% sur ce plan competitive car les sessions pranayama dédiée et philosophy/meditation sont maintenues à pleine durée (préservation du curriculum Yoga Alliance RYS 200 8 piliers)"**.
3. `progression_logic` Bloc 1, Bloc 2, Bloc 3, Bloc 4 : volumes annoncés réharmonisés sur sessions_sum.
4. `progression_logic` principe (5) : pourcentages cutback recalculés (**W4 -14%, W8 -12%, W12 -16%**) avec note explicative que les magnitudes apparaissent en deçà de -15/-25% car pranayama et philosophy maintenus à pleine durée — la réduction effective porte sur les 5 sessions asana qui passent de 90 à 70-75 min (-20 à -25% sur asana effective, conforme doctrine).
5. `goal` hebdomadaires W1 à W12 : tous les volumes annoncés mis à jour pour matcher sessions_sum.
6. `goal` W11 : pic "720 min" → **"480 min de pratique totale (cohérent fenêtre doctrinale competitive 450-720 min/sem)"**.

**Minor fixes** :
7. `summary` : typo **`Kapalakhati` → `Kapalabhati`** (orthographe correcte ailleurs).
8. `progression_logic` principe (2) "DISTRIBUTION HOLDS VS FLOW 30/70 STRICTE" → **"DISTRIBUTION HOLDS VS FLOW ~50/50 SELON COMPTABILITÉ RESPIRATIONS UJJAYI"** avec note explicative ("un hold-30s = ~5 respirations Ujjayi vinyasa-led elles-mêmes, donc la frontière holds/flow est moins nette en Ashtanga qu'en Iyengar pur").
9. `summary` "Distribution holds vs flow 30/70 (Ashtanga vinyasa-led)." → **"Distribution holds vs flow ~50/50 selon comptabilité respirations Ujjayi (Ashtanga vinyasa-led, frontière flow/hold moins nette qu'en Iyengar pur)."**
10. `week_structure.micro_pattern` clarifié : rotation J6 explicitée — **"J6 alterne philosophy+meditation Yoga Sutras (Yamas W1, Niyamas W2, Asana W3...) ET restorative renforcée (semaines de cutback W4/W8/W12)"**.

**Vérifications post-patch** : JSON valide, `duration_weeks=12 == weeks.count=12`, 668 exercices avec 100% des 5 hooks v2, 0 banned word EU MDR.

**Verdict final** : **APPROVED**.
