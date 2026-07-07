# Story 3.32 — Séance HUB : refonte de l'écran détail en vue d'ensemble (PRÉPARER)

Status: **ready-for-dev**
Branche cible : `epic-3/story-3.32-seance-hub`

## Historique review
- **2026-06-02** — Review persona Sophie (sophie-ux-challenger) : P0.2 (libellés effort non spécifiés) → AC5 corrigé ; P1.1 (cycling absent) → AC4/AC10 corrigés ; P1.4 (ancrage non testé) → AC11 ; P1.5 (bouton « Bientôt ») → AC9 corrigé.
Effort estimé : **~2-3j**
Source : Party 2026-06-02 (`_bmad-output/planning-artifacts/party-seance-presentation-2026-06-02.md`), décisions T1/D3 + bug troncature.
Stories antécédentes : 3.17/3.18/3.19 (SessionDetail V2/V3 didactique, mergées). **Socle du chantier HUB+FOCUS** : débloque 3.33→3.36.

## Story

**As a** utilisateur·rice qui ouvre une séance (n'importe quel sport),
**I want** voir d'un coup d'œil ce que je vais faire — durée, intensité, format, le « pourquoi », et la liste scannable des blocs — sans cases vides ni chiffres tronqués,
**so that** je comprends ma séance en 5 secondes et je peux la lancer ou sauter directement à un bloc.

## Contexte produit

- **Trigger** : test simu Sophie 2026-06-02 — « la présentation des séances est encore peu ergonomique ». Party → modèle **HUB + FOCUS** (réutilisé du rework TailorSage « je cuisine »).
- **HUB = PRÉPARER** : le **présent écran détail devient la vue d'ensemble** universelle, data-driven, **zéro exception par sport**. Le mode EXÉCUTER (FOCUS plein écran) arrive en 3.33+.
- **Frictions catchées** (captures `/tmp/sess_*`) :
  - **Bug troncature** « Durée 50… / 55… » sur les 3 sports — `SessionHeroHeader.swift:152` `.lineLimit(1)`.
  - **Grille de stats cardio déguisée en universelle** : « Zone — » vide en strength, absurde en yoga, « Blocs » ambigu en HIIT.
  - **« Pourquoi cette séance ? » caché** derrière un tap (la chose qui rassure).
- **État existant** :
  - `Views/Screens/Coaching/SessionDetailView.swift` : ScrollView (hero + WhyPanel + Timeline + completion + footer médical).
  - `Views/Components/SessionHeroHeader.swift:8-85` : grille 4 stats (Durée · Zone · Effort jauge 5 · Blocs).
  - `Views/Components/SessionWhyPanel.swift` : DisclosureGroup « Pourquoi ? ».
  - `Views/Components/SessionTimelineView.swift` : rail stepper warmup→exos→cooldown.
  - Données dispo par séance : `AdaptedSession{durationMinutes, type, warmup, exercises[], cooldown}` + `AdaptedExercise{sets, reps, duration, restSeconds, targetZone, notes…}` (`Coaching/Adapter/AdaptedProgram.swift:87-162`). Effort estimé : `SessionStatsCalculator.estimatedRPE(for:)`.

## Décisions (Party 2026-06-02, figées)

1. **Le HUB remplace le scroll actuel** (pas un écran en plus) : il sert *à la fois* la lecture rapide (scannable) et le détail à la demande. Le mode guidé (FOCUS) sera lancé via un bouton « ▶ Démarrer », livré en 3.33.
2. **3 stats agnostiques, jamais de case vide** : **Durée · Intensité (effort 1-5 commun, D3) · Format** (case caméléon). La « Zone » disparaît comme slot fixe → la zone reste *dans l'exo* (timeline), là où elle a un sens.
3. **Case « Format » caméléon** pilotée par la donnée : strength → « N blocs » ; HIIT → « N tours · work/rest » ; yoga → « N postures » ; cardio → la séance-clé (« 4×800 ») si détectable, sinon « N blocs ». Fallback générique = nb d'exercices.
4. **« Pourquoi » en 1 ligne visible** (résumé), détail dépliable conservé.
5. **Hero slimmé** (~−50 % de hauteur), info utile (sport + S/J + **durée totale lisible**).

## Acceptance Criteria

### (a) Hero slimmé + fix bug
1. **AC1** — Le hero affiche icône sport + « Semaine N · Jour J » + nom séance + **durée totale non tronquée**. Fix `SessionHeroHeader.swift:152` : retirer `.lineLimit(1)` (→ `.lineLimit(2)` + `minimumScaleFactor(0.7)` conservé), vérifié sur « 120 min ».
2. **AC2** — Hauteur du hero réduite vs actuel (densité : icône + textes sur moins de lignes, pas de grosse zone déco vide).

### (b) Stats agnostiques (Durée · Intensité · Format)
3. **AC3** — La grille passe de 4 à **3 cellules** : Durée, **Intensité (effort 1-5)**, **Format**. **Aucune cellule vide ni « — »**, quel que soit le sport.
4. **AC4** — `Format` est calculé par un helper `SessionFormatDescriptor` (nouveau) : mapping par `SessionType`/`SportCode` → libellé court i18n. Strength=« N blocs », HIIT=« N tours · 40/20 » si dispo sinon « N intervalles », yoga=« N postures », **cardio (running/cycling/hiking)=séance-clé (ex. « 4×800 ») ou « N blocs »**, swim=« N séries », **fallback générique=« N exercices »**. **Le vélo n'a pas de case dédiée → famille cardio (fallback « N blocs » assumé, documenté).**
5. **AC5** — `Intensité` réutilise `SessionStatsCalculator.estimatedRPE` ramené sur une échelle **1-5 commune**, affichée identiquement pour tous les sports avec **libellés figés** (i18n) : **1 Très facile · 2 Facile · 3 Modéré · 4 Soutenu · 5 Intense** (FR) / **1 Very easy · 2 Easy · 3 Moderate · 4 Hard · 5 Intense** (EN). ES via chantier C1. Pas de « RPE N » brut côté user.

### (c) « Pourquoi » visible + aperçu scannable
6. **AC6** — Une **phrase d'intention** (1 ligne, tronquée proprement) est visible en permanence au-dessus du DisclosureGroup ; tap = déplie le détail existant.
7. **AC7** — Sous le « pourquoi », un **aperçu scannable des blocs** : liste compacte (échauffement · exos numérotés · récup) avec, par ligne, le nom + métrique-clé (ex. « 4×8 », « 20 min », « 2 min ») ; **tap sur une ligne scrolle/ancre** vers le bloc dans la timeline détaillée en dessous. Pas de duplication de la timeline riche — l'aperçu est un index.
8. **AC8** — La timeline détaillée actuelle (`SessionTimelineView`) reste en dessous, inchangée fonctionnellement.

### (d) Bouton Démarrer (livré avec 3.33)
9. **AC9** — L'emplacement du bouton **« ▶ Démarrer la séance »** est prévu (sticky bas / sous l'aperçu) mais **n'est PAS affiché en 3.32** (pas de bouton mort ni de libellé « Bientôt » — signal « app non finie » pour Nathalie). Il apparaît, actif et câblé, **avec la livraison de 3.33**. En 3.32, l'écran HUB se suffit (lecture/scan).

### (e) Tests
10. **AC10** — `SessionFormatDescriptorTests.swift` (≥9 tests) : un cas par sport (strength/HIIT/yoga/running/**cycling**/hiking/swim/triathlon) + fallback générique + séance vide → libellé non vide, jamais « — ».
11. **AC11** — `SessionHeroHeaderTests` ou snapshot : « 120 min » non tronqué ; grille = 3 cellules ; aucune cellule vide pour une séance yoga (pas de zone). **+ test de l'ancrage AC7** : tap sur une ligne d'aperçu déclenche bien le scroll/ancre vers le bloc ciblé (via `ScrollViewReader`/id, vérifiable en logique).
12. **AC12** — i18n : toutes les nouvelles clés (Format, Intensité libellés, « Démarrer ») présentes **FR + EN** (ES différé au chantier localisation). Test localisation EN avant merge.

## Hypothèses / Risques
- **R1 — Format cardio « séance-clé »** : détecter « 4×800 » depuis `exercises` peut être imparfait → **mitigation** : fallback « N blocs » si pas de set répété évident. Ne pas bloquer.
- **R2 — Effort 1-5 commun** : `estimatedRPE` est aujourd'hui sur 5 niveaux (jauge) → mapping direct probable, à confirmer. Pas de nouvelle heuristique.

## Out of scope (3.33+)
- Le mode FOCUS / exécution guidée (bouton Démarrer câblé) → 3.33.
- Tout comportement audio/timer/montre.
- Localisation ES (chantier séparé).

## Fichiers touchés (preview)
**Nouveaux :**
- `Coaching/Session/SessionFormatDescriptor.swift` — calcul du libellé « Format » par sport.
- `Views/Components/SessionOverviewList.swift` — aperçu scannable + ancrage timeline.
- `CoachingSageTests/Coaching/Session/SessionFormatDescriptorTests.swift`

**Modifiés :**
- `Views/Components/SessionHeroHeader.swift` — fix `lineLimit`, slim, grille 3 cellules, retrait Zone.
- `Views/Screens/Coaching/SessionDetailView.swift` — insertion aperçu + phrase intention visible + bouton Démarrer.
- `Views/Components/SessionWhyPanel.swift` — exposer la 1ʳᵉ ligne d'intention hors disclosure.
- `Resources/Localizable.xcstrings` — clés Format/Intensité/Démarrer (FR/EN).

**NON modifiés (confirmé)** : `SessionTimelineView.swift` (réutilisé tel quel), `AdaptedProgram.swift` (données suffisantes), adapter/algo.

## Jalons
- **J1 (~0.5j)** — Fix bug troncature + hero slim + grille 3 cellules (retrait Zone). **CHECK Sophie** : screenshot 3 sports, plus de « 50… » ni case vide.
- **J2 (~1j)** — `SessionFormatDescriptor` + Intensité 1-5 + tests.
- **J3 (~1j)** — Aperçu scannable + ancrage timeline + phrase intention visible + bouton Démarrer (disabled) + i18n + ui-reviewer FR/EN.

Total : **~2-3j**. Garde-fou EU MDR : « meilleure allure » et estimations restent indicatives.
