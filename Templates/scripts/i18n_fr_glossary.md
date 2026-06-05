# Glossaire FR canonique — noms d'exercices, formats, zones (chantier i18n CoachingSage)

> **Statut** : référentiel de consigne pour agents de traduction/correction. Ne modifie aucun template à la lecture ; sert de source de vérité pour aligner les `name.fr` affichés sur TOUS les sports.
>
> **Source** : extraite des templates gold standard déjà traduits — running-beginner-5k, running-recreational-10k, yoga-beginner-initiation, strength-training-beginner-home-basics, strength-training-regular-ppl, hiit-regular, swimming-beginner-initiation.

---

## RÈGLE D'OR

> **Le titre = nom FR concret orienté action. Le jargon vit dans la note, PAS dans le titre.**

Pattern gold standard validé (yoga + running débutant) :

> **« Nom FR concret (terme technique en référence) »**

1. **Titre affiché** (`name.fr`) = un nom français concret, descriptif, qu'un débutant comprend sans glossaire.
2. **Terme technique / anglais / acronyme** = entre parenthèses **en référence**, uniquement s'il est utile à reconnaître l'exercice (ex. nom propre sanskrit, acronyme de format reconnu). Sinon → dans la note.
3. **JAMAIS de code d'intensité nu** (Daniels-T, Z2, EN2, RPE 8, RIR 2, FTP, CSS…) dans un titre. Le code va dans la **note** ou dans le champ `target_zone` (non affiché comme titre).
4. Cohérence inter-sports : un même geste a **un seul** libellé FR partout. Squat = « Squat » dans muscu, HIIT, running préventif. Pas « back squat » ici et « Squat » là.

**Constat de la revue** : les niveaux *regular* / *competitive* (notamment `strength-training-regular-ppl` et `running-recreational-10k`) ont laissé du jargon anglais et des codes à nu dans les titres (`Bench press barre`, `Deadlift conventionnel`, `Pull-up strict`, `Bloc tempo Daniels-T`, `Footing easy`…). Les tableaux ci-dessous donnent le libellé cible pour les corriger.

---

## 1. Exercices muscu / renforcement (transverses tous sports)

Libellé FR canonique à utiliser dans `name.fr`. Réutilise tel quel quel que soit le sport (muscu, HIIT strength préventif, running renfo, etc.).

| Geste / `match_key` jargon constaté | `name.fr` canonique recommandé |
|---|---|
| squat / back squat / squat poids du corps | **Squat** (au poids du corps : **Squat au poids du corps** ; barre : **Squat barre nuque (back squat)**) |
| goblet squat | **Squat gobelet (goblet squat)** |
| front squat | **Squat barre devant (front squat)** |
| bulgarian split squat | **Fente bulgare (bulgarian split squat)** |
| single-leg squat / pistol | **Squat sur une jambe** (assisté : **Squat sur une jambe (pistol assisté)**) |
| deadlift / deadlift conventionnel | **Soulevé de terre (deadlift)** |
| romanian deadlift / RDL | **Soulevé de terre roumain (RDL)** |
| bench press / bench press barre | **Développé couché (bench press)** |
| incline DB bench press 30° | **Développé incliné haltères 30° (incline bench)** |
| overhead press / OHP / overhead press barre | **Développé militaire (overhead press)** |
| arnold press | **Développé Arnold (arnold press)** |
| seated DB shoulder press | **Développé épaules haltères assis** |
| row — dumbbell row / single-arm DB row | **Tirage horizontal haltère (dumbbell row)** |
| row — cable row | **Tirage horizontal poulie (cable row)** |
| row — barbell row pendlay | **Rowing barre Pendlay (pendlay row)** |
| lunge / walking lunge / fentes | **Fentes** (marchées : **Fentes marchées (walking lunge)** ; haltères : **Fentes haltères**) |
| hip thrust / hip thrust barre | **Pont fessier lesté (hip thrust)** (au sol PdC : **Pont fessier au sol**) |
| glute bridge / pont fessier | **Pont fessier** (une jambe : **Pont fessier sur une jambe**) |
| calf raises bipodal / standing calf raise | **Mollets debout (deux pieds)** |
| calf raises unipodal / single-leg calf raise | **Mollets debout sur une jambe** |
| calf raises excentriques | **Mollets excentriques** (sur une jambe : **Mollets excentriques sur une jambe**) |
| seated calf raise | **Mollets assis (soléaire)** |
| face pull | **Tirage poulie visage (face pull)** |
| lateral raises | **Élévations latérales (lateral raises)** |
| triceps pushdown | **Extension triceps à la poulie (triceps pushdown)** |
| overhead DB triceps extension | **Extension triceps au-dessus de la tête** |
| pullover / dumbbell pullover | **Pull-over haltère (pullover)** |
| hammer curl | **Curl marteau (hammer curl)** |
| barbell / DB / incline curl | **Curl biceps barre** / **Curl biceps haltères** / **Curl incliné haltères** |
| leg extension | **Extension des jambes (leg extension)** |
| leg curl | **Flexion des jambes (leg curl)** |
| leg press | **Presse à cuisses (leg press)** |
| lat pulldown | **Tirage vertical poulie haute (lat pulldown)** |
| pull-up / pull-up strict | **Traction (pull-up)** (stricte : **Traction stricte**) |
| pompes / push-up | **Pompes** (genoux : **Pompes sur les genoux**) |
| side plank | **Planche latérale** |
| plank ventral / planche ventrale | **Planche ventrale** |
| dead bug | **Dead bug** *(terme conservé : exercice référencé tel quel, gloser en note « bug mort, anti-cambrure »)* |
| bird-dog | **Bird-dog** *(idem : « pointer de chien », gloser en note)* |
| pallof press | **Anti-rotation à la poulie (pallof press)** |
| cable woodchopper | **Bûcheron à la poulie (woodchopper)** |
| hanging leg raise | **Relevé de jambes suspendu (hanging leg raise)** |
| box jump | **Saut sur boîte (box jump)** |
| box step-up / step-ups | **Montées sur step** |
| nordic curl | **Nordic curl (ischios excentriques)** *(terme reconnu, glose en parenthèse)* |
| clamshell | **Coquillage (clamshell)** |
| wall sit | **Chaise contre le mur** (partielle : **Chaise contre le mur partielle**) |
| hip hinge (pattern) | **Charnière de hanche (hip hinge)** |
| scapular push-up | **Pompe des omoplates (scapulaire)** |
| scapular pull-up | **Traction des omoplates (scapulaire)** |
| reverse hyperextension | **Hyperextension inversée (lombaires)** |
| Y-raise / Y-T-W | **Élévations en Y** / **Élévations Y-T-W (épaules)** |
| tibialis raises | **Relevés de pointes (tibial antérieur)** |
| turkish get-up | **Relevé turc (turkish get-up)** |

**Déjà canoniques dans running-beginner — à réutiliser tels quels** : `Pont fessier`, `Pont fessier sur une jambe`, `Coquillage (clamshell)`, `Mollets debout (deux pieds)`, `Mollets excentriques`, `Planche latérale`, `Planche ventrale`, `Fentes statiques`, `Fentes dynamiques`, `Chaise contre le mur`, `Bird-dog`, `Dead bug`, `Squats au poids du corps`, `Montées sur step`.

> **Note pattern conservé** : dans strength-training les `(pattern push V)`, `(core — EN FIN DE SÉANCE)`, `(quad hyp)`, `(isolation)` sont des annotations de doctrine **internes** ; elles ne devraient PAS rester dans `name.fr` affiché. Cible : titre propre + annotation déplacée en note/`tags`.

---

## 2. Formats HIIT / CrossFit

**Règle** : garder l'acronyme reconnu (EMOM, AMRAP, Tabata…) MAIS lui adjoindre un descriptif FR dans le titre, pour qu'un novice comprenne la mécanique sans glossaire.

| Format / jargon | `name.fr` recommandé (motif) |
|---|---|
| EMOM 12 min | **EMOM 12 min (1 série chaque minute)** |
| AMRAP 12 min | **AMRAP 12 min (max de tours)** |
| Tabata 20/10 (n rounds) | **Tabata 20/10 — squats sautés (8 rounds)** — *toujours : Tabata 20/10 — `<exo FR>` (`<n>` rounds)* |
| WOD | **Circuit du jour (WOD)** |
| double-unders | **Double tours de corde (double-unders)** |
| KB swing / kettlebell swing (russe) | **Swing kettlebell russe** |
| Turkish get-up | **Relevé turc (turkish get-up)** |
| wall ball | **Lancer de medecine-ball au mur (wall ball)** |
| box step-up | **Montée sur boîte (box step-up)** |
| burpees | **Burpees** *(terme conservé, universel)* |
| mountain climbers | **Montées de genoux planche (mountain climbers)** |
| squat-jumps / squat-air | **Squats sautés** / **Squats à l'air (sans charge)** |
| jumping jacks | **Jumping jacks (sauts en étoile)** |
| thruster (DB) | **Thruster haltères (squat + développé)** |
| 30/30, 40/20 (blocs) | **Bloc 30/30 — `<exos FR>` (`<n>` rounds)** — format temps conservé, exos en FR |

> Bornes de temps (`20/10`, `30/30`, `40/20`) = se lisent intuitivement (effort/repos en secondes), on peut les conserver dans le titre. Le détail va en note si ambigu.

---

## 3. Zones / codes d'intensité (running, cyclisme, natation)

**Règle stricte** : ces codes ne doivent **JAMAIS** apparaître à nu dans un titre de séance / exo / thème. Le titre porte la **description FR**. Le code reste **en note** OU dans `target_zone` (champ non affiché comme titre).

| Code | Traduction descriptive FR à mettre dans le titre | Code reste où |
|---|---|---|
| Daniels-E (Easy) | **allure facile** / **footing facile** | note ou `target_zone` |
| Daniels-T (Threshold) | **allure tempo** / **au seuil** | note ou `target_zone` |
| Daniels-I (Interval) | **allure intervalle (VMA)** | note ou `target_zone` |
| Daniels-R (Repetition) | **allure rapide (répétitions courtes)** | note ou `target_zone` |
| Z1 / Z2 / Z3… (vélo, course) | **zone facile** / **zone d'endurance** / **zone tempo** (selon la zone) | note ou `target_zone` |
| EN1 | **endurance fondamentale (très facile)** | note ou `target_zone` |
| EN2 | **endurance active (modérée)** | note ou `target_zone` |
| EN3 | **endurance soutenue (au seuil)** | note ou `target_zone` |
| RPE (échelle 1-10) | dans le titre → **effort « facile / modéré / dur / très dur »** ; jamais « RPE 8 » | note (« RPE 8/10 ») |
| RIR (reps in reserve) | dans le titre → **« en gardant 2 reps en réserve »** si utile, sinon rien | note (« RIR 2 ») |
| FTP (cyclisme) | **% de ta puissance seuil** → titre = **« tempo à vélo »**, **« zone facile à vélo »** | note (« ~85 % FTP ») |
| CSS (natation) | **allure seuil natation** → titre = **« crawl au seuil »** | note (« allure CSS ») |
| MAV / MEV / MRV (volume) | n'apparaissent jamais dans un titre user | note / interne doctrine |

**À corriger en priorité** (titres fautifs constatés dans running-recreational-10k) :
`Bloc tempo Daniels-T` → **Bloc tempo (au seuil)** ; `Cooldown extended Daniels-E` → **Retour au calme prolongé (allure facile)** ; `Footing recovery post-fartlek Daniels-E` → **Footing de récupération (allure facile)** ; `Course continue Daniels-E` → **Course continue (allure facile)** ; `Footing easy` → **Footing facile** ; `Footing easy taper` → **Footing facile d'affûtage** ; `Tempo … Daniels-T` (titres de séance) → **Tempo … (au seuil)**. Le code Daniels va en note ou `target_zone`.

---

## 4. Abréviations / anglicismes à bannir des titres

| À bannir dans le titre | Remplacer par |
|---|---|
| DB (dumbbell) | **haltère(s)** |
| KB (kettlebell) | **kettlebell** (mot complet) |
| OHP | **développé militaire** |
| RDL | **soulevé de terre roumain** *(RDL en référence entre parenthèses si utile)* |
| hip hinge | **charnière de hanche (hip hinge)** |
| scapular | **des omoplates** / **scapulaire (glosé)** |
| ramp-up | **séries d'activation progressives** |
| bracing | **gainage actif** |
| strides | **accélérations** / **lignes (strides)** |
| fartlek | **jeu d'allures (fartlek)** |
| cutback / deload | **semaine allégée** |
| taper / tapering | **affûtage** |
| cooldown | **retour au calme** |
| warmup | **échauffement** |
| easy (allure) | **facile** |
| recovery | **récupération** |
| top sets / working set | **séries lourdes** / **série de travail** |
| compound | **mouvements polyarticulaires** |
| bodyweight | **poids du corps** |
| dryland (natation) | **renforcement à sec** |
| streamline | **position profilée (streamline)** |
| catch-up / sculling / fist swim / fingertip drag (drills nat.) | conserver le nom de drill + glose FR : **Rattrapé (catch-up)**, **Godille (sculling)**, **Nage poing fermé (fist swim)**, **Effleurement du bout des doigts (fingertip drag)** |
| SNC | **système nerveux** (jamais dans un titre — en note uniquement) |
| foam roller | **rouleau de massage** |

> `strength préventif`, `core`, `dryland`, `main set` constatés dans les **noms de thème/séance** : à franciser pareil (« Renforcement préventif », « Gainage », « Renforcement à sec », « Série principale »).

---

## 5. Postures yoga

**Pattern confirmé (gold standard yoga-beginner)** :

> **« Nom FR de la posture (sanskrit en minuscules entre parenthèses) »**

Le sanskrit vit en référence ; le nom FR concret porte le sens. Variantes / consignes après un tiret (`— alignement progressif`, `— mains au mur`).

### Postures déjà traduites (référentiel à réutiliser tel quel)

| Sanskrit | `name.fr` canonique |
|---|---|
| tadasana | **Posture de la montagne (tadasana)** |
| sukhasana | **Posture facile assise (sukhasana)** |
| marjaryasana-bitilasana | **Chat-vache (marjaryasana-bitilasana)** |
| balasana | **Posture de l'enfant (balasana)** |
| savasana | **Posture du cadavre (savasana)** |
| adho mukha svanasana | **Chien tête en bas (adho mukha svanasana)** |
| salamba bhujangasana / sphinx | **Sphinx, cobra modifié sur les avant-bras (salamba bhujangasana)** |
| supta baddha konasana | **Papillon allongé (supta baddha konasana)** |
| virabhadrasana I | **Guerrier I (virabhadrasana I)** |
| virabhadrasana II | **Guerrier II (virabhadrasana II)** |
| uttanasana | **Flexion avant debout (uttanasana)** |
| vrksasana | **Posture de l'arbre (vrksasana)** |
| trikonasana | **Posture du triangle (trikonasana)** |
| setu bandha sarvangasana | **Posture du pont (setu bandha sarvangasana)** |
| paschimottanasana | **Flexion avant assise (paschimottanasana)** |
| anjaneyasana | **Fente basse (anjaneyasana)** |
| utthita parsvakonasana | **Angle latéral étendu (utthita parsvakonasana)** |
| ardha matsyendrasana | **Demi-torsion assise (ardha matsyendrasana)** |
| viparita karani | **Jambes contre le mur (viparita karani)** |

### Respiration / pranayama / regard

| Terme | Comment le rendre dans le titre |
|---|---|
| pranayama dirgha | **Respiration complète en 3 temps (pranayama dirgha)** — abrégé : **Respiration en 3 temps (dirgha)** |
| ujjayi | **Respiration océanique (ujjayi)** — au niveau débutant introduire comme « respiration ujjayi » glosée ; jargon avancé (« souffle victorieux ») réservé aux niveaux avancés |
| drishti | **Point de regard fixe (drishti)** — réservé niveaux intermédiaire/avancé ; chez le débutant : « pose ton regard » sans le mot |
| bandha (mula/uddiyana) | réservé **avancé** ; ne pas exposer en titre débutant |
| vinyasa | **Enchaînement fluide (vinyasa)** |

> **Niveau-dépendance** : le débutant reçoit la version glosée (`Respiration océanique (ujjayi)`). Les niveaux *advanced/competitive* peuvent employer le sanskrit seul une fois le terme acquis — mais le `name.fr` reste **toujours** au minimum « FR (sanskrit) » pour rester scannable.

---

## Récapitulatif de la consigne (pour agent correcteur)

1. Ouvre le template, parcours chaque `name.fr` de séance et d'exo.
2. Si le titre contient un acronyme/anglicisme/code nu → remplace par le libellé canonique des tableaux 1-5.
3. Déplace tout code d'intensité (Daniels/Z/EN/RPE/RIR/FTP/CSS) et toute annotation doctrine (`(pattern push V)`, `(hyp)`, `(core — EN FIN)`) **hors du titre** → note / `target_zone` / `tags`.
4. Vérifie la cohérence inter-sports : le même geste = le même libellé partout.
5. Conserve les variantes/consignes après un tiret (`— mains au mur`, `— consolidation`).
6. Ne touche ni `match_key` (clé de matching technique) ni `name.en`/`name.es` dans cette passe FR.
