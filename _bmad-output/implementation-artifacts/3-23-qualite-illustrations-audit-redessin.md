# Story 3.23 — Audit qualité illustrations + redessin (yoga + strength)

Status: **ready-for-review**
Branche cible : `epic-3/story-3.23-illustrations-audit-redessin`
Effort estimé : **4-6j** (1j audit + 3-5j redessin — révisé hausse suite revue agent : 60-120 lignes Path × ≥8 redessins probables = ~800 lignes SwiftUI Path + Preview check + simu validation)
Story précédente liée : 3.19 (mergée main `c10c2a8` 2026-05-24) — livraison initiale des 21 illustrations (10 yoga + 10 strength + cardio fallback)
Stories parallèles : 3.21 différé backlog (Bug F seul), 3.22 (flux UX réduit E/G/F-bis), 3.24 réduite (pédagogie 3.24a+b), 3.25 nouvelle (mode workout guidé)

> **🔄 ABSORPTION POST-REVUE 2026-05-24** : Cette story est désormais la **maison unique des poses yoga manquantes Dirgha + Cat-cow** (+ variante avant-bras) — ex-Bug A de Story 3.21 fusionné ici suite recommandation revue agent (overlap massif détecté). Story 3.21 reste avec Bug F (cold launch dormants) seul. AC2 ci-dessous est la fusion : 3.23 owne le redessin et l'ajout au catalogue `YogaPose`, 3.21 n'y touche plus jamais.

## Story

**As a** utilisatrice qui ouvre une séance et voit une illustration d'exo,
**I want** reconnaître immédiatement (en < 1 seconde, sans lire la légende) la pose ou le geste demandé,
**so that** l'illustration remplit son rôle didactique au lieu d'ajouter de la confusion ("c'est quoi cette silhouette ?").

## Contexte produit

Story 3.19 (mergée main hier `c10c2a8` 2026-05-24) a livré le système d'illustrations exo : 10 poses yoga (`YogaIllustration.swift` Canvas single-file), 10 patterns strength (un fichier `Illustration.swift` par pattern, 3 frames dynamiques ou 1 frame statique) + fallback SF Symbol sport pour running/cycling/swim.

**Test simu Sophie 2026-05-24 (yoga + strength)** : verdict global = **illustrations PAS reconnaissables**. Citations verbatim :

- **Yoga "Dirgha allongée"** : *"je comprends pas les mains les bras sont où ? on a une jambe pliée ? pas clair du tout"*. Cause technique probable : "Dirgha" est un exercice de **respiration pranayama**, pas une posture asana. L'enum `YogaPose` dans `YogaIllustration.swift:58-77` ne contient pas `.dirgha` ni `.pranayama` → tombe sur `.unknown` → fallback `drawWarrior1()` (ligne 49). Sophie voit un Guerrier I au lieu d'une silhouette allongée respirant.

- **Yoga "Cat-cow sur les avant-bras"** : *"j'ai le même dessin que pour le dirgha debout"*. Cause confirmée : `cat-cow` / `marjaryasana` / `bitilasana` ne sont pas dans `poseKind` → fallback Warrior I également → deux exos différents partagent le même dessin. Bug A traité dans Story 3.21 hotfix (différé), mais l'**absence de la pose canonique cat-cow** dans le catalogue est un chantier produit qualité (cette Story 3.23).

- **Strength "DB bench press"** : *"le dessin ne correspond pas"*. Cause confirmée : `PushHorizontalIllustration.swift` partage le rendu entre pompe-au-sol et bench press. Inspection code (lignes 27-108) : **aucune barre, aucun haltère, aucun banc dessinés** — seuls le corps en planche + un bras unique sont tracés. `grep IllustrationStyle.load` sur le fichier retourne 0 hit (vs Hinge=3, Squat=3, PullHorizontal=3). L'utilisatrice voit une pompe poids du corps pour un exo aux haltères couché sur banc.

- **Demande explicite Sophie** : *"inspire-toi de dessins que tu trouves sur internet"* — autorisation produit d'utiliser références web canoniques (Wikipedia anatomy, Yoga Journal, Stronger by Science, etc.) pour fixer les contours.

**Standard qualité produit attendu** (formalisé dans cette story) : **la pose ou le geste doit être identifiable en 1 seconde sans légende texte**. Aujourd'hui ce critère n'est pas tenu pour au moins 3 cas connus ; l'audit visuel exhaustif Sophie révélera les autres.

**Référence mémoire** : `feedback_illustration_didactic_grid` (pieds ancrés sol fixe + pas de rétrécissement entre frames + référentiel observateur cohérent).

## Audit visuel — tableau exhaustif des 21+ illustrations livrées Story 3.19

À valider visuellement par Sophie au prochain Cmd+R (3 verdicts : **OK** / **À redessiner** / **Suspect**).

### Yoga (10 poses dans `YogaIllustration.swift` + 2+ poses manquantes du catalogue)

| Pose | Fichier / fonction | Verdict pré-audit | Référence web pour redessin (si KO) |
|---|---|---|---|
| Chien tête en bas (Adho Mukha) | `drawDownwardDog` ligne 85 | Suspect | https://en.wikipedia.org/wiki/Adho_Mukha_Svanasana |
| Guerrier I (Virabhadrasana I) | `drawWarrior1` ligne 130 | OK probable | — |
| Guerrier II (Virabhadrasana II) | `drawWarrior2` ligne 183 | OK probable | — |
| Arbre (Vrksasana) | `drawTree` ligne 224 | Suspect | https://en.wikipedia.org/wiki/Vrikshasana |
| Cobra (Bhujangasana) | `drawCobra` ligne 271 | Suspect | https://en.wikipedia.org/wiki/Bhujangasana |
| Enfant (Balasana) | `drawChild` ligne 311 | Suspect | https://en.wikipedia.org/wiki/Balasana |
| Pince debout (Uttanasana) | `drawForwardFold` ligne 356 | OK probable | — |
| Triangle (Trikonasana) | `drawTriangle` ligne 395 | Suspect | https://en.wikipedia.org/wiki/Trikonasana |
| Bateau (Navasana) | `drawBoat` ligne 445 | Suspect | https://en.wikipedia.org/wiki/Navasana |
| Savasana | `drawSavasana` ligne 482 | OK probable | — |
| **Dirgha pranayama** (allongée / assise) | **MANQUE** → fallback drawWarrior1 | **À AJOUTER** | search: "dirgha pranayama three part breath illustration". Silhouette allongée sur le dos, 3 flèches concentriques ventre/thorax/clavicules. |
| **Cat-cow** (Marjaryasana-Bitilasana) | **MANQUE** → fallback drawWarrior1 | **À AJOUTER** (1 frame 4-pattes annotations OU 2 frames cat/cow) | https://en.wikipedia.org/wiki/Marjariasana |
| **Cat-cow sur les avant-bras** (variante) | **MANQUE** | **À AJOUTER** (variante drawCatCow coudes au sol) | Variante drawCatCow. |

### Strength (10 patterns)

| Pattern | Fichier | Verdict pré-audit | Référence web pour redessin (si KO) |
|---|---|---|---|
| Squat | `SquatIllustration.swift` (3f) | OK probable (3 load) | — |
| Hinge (Romanian Deadlift) | `HingeIllustration.swift` (3f) | OK probable (3 load) | — |
| Push horizontal — pompe poids du corps | `PushHorizontalIllustration.swift` (3f, sans équipement) | OK pour pompe | — |
| Push horizontal — **DB bench press** | mêmes fichier (0 load, 0 equipment) | **À REDESSINER** | https://en.wikipedia.org/wiki/Bench_press#Dumbbell_bench_press — banc horizontal en marron, allongé sur le dos, 2 haltères tenus bras tendus. Créer un sous-variant `.dumbbellBench` détecté par `exerciseName.contains("db bench"\|"haltères couché"\|"dumbbell bench")`. |
| Push vertical (overhead press) | `PushVerticalIllustration.swift` (3f, 2 loads) | Suspect | https://en.wikipedia.org/wiki/Overhead_press |
| Pull horizontal (row/rameur) | `PullHorizontalIllustration.swift` (3f, 3 loads) | OK probable | — |
| Pull vertical (pull-up/chin-up) | `PullVerticalIllustration.swift` (3f, 1 equipment barre) | Suspect | https://en.wikipedia.org/wiki/Pull-up_(exercise) |
| Lunge | `LungeIllustration.swift` (3f, 0 load) | Suspect | https://en.wikipedia.org/wiki/Lunge_(exercise) |
| Core (plank frontal + latéral) | `CoreIllustration.swift` (1f, 2 variantes) | OK probable | — |
| Plyo | `PlyoIllustration.swift` (3f) | Suspect | https://en.wikipedia.org/wiki/Plyometrics |
| Mobility | `MobilityIllustration.swift` (1f + annotations) | Suspect (générique = lisible ?) | — |

### Cardio (running / cycling / swim — fallback SF Symbol)

| Sport | Rendu | Verdict |
|---|---|---|
| Running endurance / interval / drills | SF Symbol `figure.run` palette | OK — hors scope redessin |
| Cycling endurance / interval | SF Symbol `figure.outdoor.cycle` palette | OK — hors scope |
| Swim drill / endurance | SF Symbol `figure.pool.swim` palette | OK — hors scope |

**Total verdict pré-audit** : 3 cas connus "À redessiner" (Dirgha, Cat-cow + variante, DB bench press) + 9 cas "Suspect à valider" + 3 cas "À AJOUTER". Chiffre final figé à l'issue du Jalon 1 par Sophie.

## Standards qualité produit (à formaliser)

À documenter dans un commentaire de tête de `IllustrationStyle.swift` (modification minime, hors palette qui reste figée Story 3.19) :

1. **Identification en < 1 seconde sans légende texte**. Test fait par Sophie au Cmd+R sur SessionDetailView réelle.
2. **Grille didactique** (mémoire `feedback_illustration_didactic_grid`) :
   - Pieds ancrés au sol : sol pointillé `IllustrationStyle.groundLine` toujours présent (sauf yoga inversées et savasana).
   - Pas de rétrécissement entre frames : taille silhouette constante (descente squat = épaule descend, PAS tronc qui rétrécit).
   - Référentiel observateur cohérent : profil OU face OU 3/4 mais pas mix dans un strip 3 frames.
3. **Palette tokens existants UNIQUEMENT** : `IllustrationStyle.silhouette(sportCode:)`, `.equipment`, `.load`, `.movementArrow`, `.groundLine`. AUCUNE nouvelle couleur.
4. **Équipement matérialisé quand mentionné dans le nom** : si exo mentionne `haltères / barre / banc / kettlebell` → équipement DOIT apparaître. Sinon `.generic` fallback SF Symbol.
5. **Max 3 frames pour gestes dynamiques, 1 frame + annotations pour gestes statiques**.
6. **Pour le yoga** : 1 frame avec annotation `.movementArrow` ligne pointillée d'alignement.
7. **Cas "exercice non couvert"** : si pose/geste manque au catalogue → AJOUTER un case enum + dessin, ne PAS laisser tomber sur un fallback visuel d'une autre pose.

## Acceptance Criteria

1. **AC1 — Audit visuel complet** : Sophie passe en revue les 21+ illustrations sur device (Cmd+R simu) et remplit le tableau avec verdict définitif. Output : tableau mis à jour committé dans ce même `.md` à la fin du Jalon 1.

2. **AC2 — Poses yoga manquantes ajoutées** : minimum **Dirgha pranayama** (allongée + assise) et **Cat-cow** (+ variante avant-bras) ajoutées au catalogue. Nouveaux cases enum `YogaPose`, nouvelles branches `poseKind`, nouvelles fonctions `drawDirgha` / `drawCatCow`.

3. **AC3 — DB bench press distingué de la pompe** : `PushHorizontalIllustration` accepte param optionnel `exerciseName: String? = nil`. Si `name.contains("bench"\|"haltères couché"\|"dumbbell bench"\|"db bench")` → rendu variante avec banc horizontal `.equipment` + 2 haltères `.load`. Sinon rendu pompe inchangé.

4. **AC4 — Toutes les "À redessiner" issues de AC1 sont effectivement redessinées** : commits Jalon 2 montrent modifications Path. Source web documentée en commentaire de tête de chaque fonction `drawXxx` retouchée.

5. **AC5 — Standards qualité formalisés en commentaire** : `IllustrationStyle.swift` reçoit commentaire de tête (7 règles).

6. **AC6 — Documentation sources web utilisées** : `Views/Components/Illustrations/REFERENCES.md` listant les URLs utilisées (ou commentaire bloc en tête de `IllustrationStyle.swift`).

7. **AC7 — Review visuelle Sophie post-redessin OK** : second Cmd+R après Jalon 2. Tableau audit final mis à jour en "OK". Itération courte Jalon 3 si rejet ponctuel.

8. **AC8 — Pas de régression palette / build** : `BuildProject` PASS, suite tests 702+ PASS inchangée. `ui-reviewer` READY sur SessionDetailView FR + EN.

## Fichiers touchés (preview)

**Modifiés (selon résultat audit Sophie)** :
- `Views/Components/Illustrations/YogaIllustration.swift` — ajout `.dirgha`, `.catCow` (et variante avant-bras) dans enum + détections + fonctions ; retouche éventuelle poses suspectes selon audit
- `Views/Components/Illustrations/PushHorizontalIllustration.swift` — ajout paramètre `exerciseName` + branche `isDumbbellBench`
- `Views/Components/ExercisePatternIllustration.swift` — propager `exerciseName` au case `.pushHorizontal`
- `Views/Components/IllustrationStyle.swift` — commentaire de tête formalisant standards
- Autres `Views/Components/Illustrations/*Illustration.swift` selon verdict audit

**Nouveaux (optionnel)** :
- `Views/Components/Illustrations/REFERENCES.md` — sources web utilisées

**NON touchés** :
- `Coaching/Session/ExercisePattern.swift` (enum reste à 17 cases)
- `Coaching/Session/ExercisePatternResolver.swift`
- `Utilities/Color+Coaching.swift` (palette figée)
- Templates JSON

## Risques

- **Drift stylistique cross-illustrations** : redessiner 3-10 illustrations sur 2-4j → risque drift. Mitigation : conserver `IllustrationStyle` invariants. Side-by-side gallery check après chaque retouche.
- **Temps de dessin SwiftUI Path manuel** : chaque pose yoga = ~60-120 lignes de Path. 3 nouvelles poses + 1 variante bench = ~400 lignes. Si audit identifie >10 redessins, splitter en Story 3.23a (yoga critique) + 3.23b (strength suspects).
- **Audit visuel Sophie consomme temps utilisateur** : 21+ illustrations × 30sec = 10-15min de simu. Mitigation : préparer `IllustrationGalleryPreviewView` Debug en 1 écran scrollable.
- **Référence web non-libre de droits** : s'inspirer **uniquement de la pose**, pas du dessin. Le résultat SwiftUI Path est original.
- **Coordination avec Story 3.21 hotfix** (différé) : si 3.21 reprise plus tard touche `YogaIllustration`, coordonner les commits.

## Découpage Jalons

**Jalon 1 — Audit + identification (~0.5-1j)**
- Construire (ou réutiliser le Preview existant) une galerie SwiftUI Preview affichant les 21+ illustrations en 1 vue scrollable
- Cmd+R simu, Sophie passe en revue, remplit tableau audit
- Identifier précisément liste "À redessiner" + "À ajouter"
- Commit `.md` mis à jour avec verdict figé

**Jalon 2 — Recherche web refs + redessin priorisé (~1-2.5j)**
- Pour chaque illustration "À redessiner" / "À ajouter" : consulter référence web listée
- Documenter URL choisie en commentaire de tête de la fonction `drawXxx`
- Coder le SwiftUI Path (ou retoucher)
- Vérifier en Preview SwiftUI individuel
- **Priorité de redessin** :
  1. **Yoga manquantes** : Dirgha + Cat-cow + Cat-cow avant-bras
  2. **DB bench press** : variante distincte de la pompe
  3. **Suspects yoga** confirmés "À redessiner" par audit
  4. **Suspects strength** confirmés "À redessiner"
- Side-by-side gallery check après chaque batch de 3-4 retouches

**Jalon 3 — Review visuelle Sophie + itération (~0.5j)**
- Second Cmd+R complet
- Sophie valide chaque redessin sur SessionDetailView réelle
- Itérer sur rejets ponctuels (max 1-2 illustrations, sinon réviser story)
- Update `REFERENCES.md`
- `ui-reviewer` agent verdict READY FR + EN
- Build PASS, suite tests PASS
- Merge main

**Total : 4-6j (révisé hausse).** Si audit > 10 redessins, splitter 3.23a (yoga) + 3.23b (strength).

## Accessibilité (trou comblé revue)

- **Dynamic Type** : `ExercisePatternIllustration` doit déjà clamper `.dynamicTypeSize(.medium...(.accessibility2))` (AC13-bis Story 3.19). Vérifier que les nouveaux dessins Dirgha / Cat-cow / DB bench respectent le même clamp pour éviter explosion taille en `XXXL` accessibility.
- **Alt-text VoiceOver** : chaque nouveau dessin doit avoir `accessibilityLabel("Illustration : <nom pose>, <description courte exécution>")` via clé i18n `coaching.session.exercise.illustration.a11y.<poseId>`. Exemple : `coaching.session.exercise.illustration.a11y.dirgha` = "Illustration : Pranayama Dirgha, respiration en trois temps allongée sur le dos." `coaching.session.exercise.illustration.a11y.catCow` = "Illustration : Cat-cow, alternance dos creux / dos rond à quatre pattes."
- **Strip multi-frames** : `accessibilityHidden(true)` sur les frames individuelles (décoratif), label combiné au niveau strip (déjà pattern Story 3.19).
- **Test manuel obligatoire** : ouvrir SessionDetailView avec Settings > Accessibility > Display & Text Size > Larger Text au max + VoiceOver ON sur 1 séance yoga + 1 séance strength → vérifier annonces correctes et pas de layout cassé.

## Métriques de succès produit (trou comblé revue)

- **Qualitatif** : tableau audit AC1 entièrement basculé en "OK" à l'issue Jalon 3 (verdict Sophie sur device).
- **Quantitatif** (V2 si analytics activé) : taux d'utilisateurs qui restent sur une card exo > 3s (signal d'engagement vs scroll rapide qui suggère illustration ignorée). Logger event `exercise.illustration.viewed` avec `pattern` et `duration`.
