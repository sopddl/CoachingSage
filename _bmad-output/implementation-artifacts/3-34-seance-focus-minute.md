# Story 3.34 — Séance FOCUS : avance Minuté (HIIT / yoga) + règle anti-Decathlon

Status: **ready-for-dev**
Branche cible : `epic-3/story-3.34-seance-focus-minute`
Effort estimé : **~2-3j**
Source : Party 2026-06-02. Dépendances : **3.33 (shell FOCUS) livrée AVANT**.

## Story

**As a** utilisateur·rice en HIIT (circuits work/rest) ou en yoga (postures tenues),
**I want** que le FOCUS **avance tout seul au chrono** et m'**annonce l'étape suivante avant qu'elle démarre**,
**so that** je n'ai pas à toucher l'écran les mains occupées/en sueur, et je ne perds jamais le début d'un exo.

## Contexte produit

- **2ᵉ façon d'avancer** du shell FOCUS (3.33) : **Minuté auto**. L'étape avance sur un compte à rebours (work/rest pour HIIT, tenue de pose pour yoga), sans tap.
- **Règle « anti-Decathlon »** (pain Sophie) : sur Decathlon Coach elle « perd les premières secondes du 1ᵉʳ exo » car rien ne l'annonce. → FOCUS **pré-annonce** l'étape suivante : « Prochain : Goblet squat · 4×8. Prêt ? 3·2·1 » (visuel + bips ; voix en 3.35).
- **Mapping** : `SessionType.interval`/HIIT → work/rest répété en tours ; yoga (`SportCode.yoga`) → tenue par posture (secondes/respirations). Les deux = même moteur de timer, paramètres différents.
- **Format** (case HUB 3.32) « N tours · 40/20 » / « N postures · 2 min » alimente directement ce mode.

## Décisions (Party, figées)

1. **Même shell que 3.33**, on ajoute un **moteur de timer** + un état « avance = minuté » porté par l'étape (pas un écran séparé).
2. **Pré-annonce systématique** avant chaque étape minutée (countdown 3·2·1) + bips ; **surtout le 1ᵉʳ exo**.
3. **HIIT = tours** : un circuit de K exos répété R fois → la progression compte les tours (« Tour 2/3 ») ; les points/compteur reflètent tours × exos.
4. **Pause/skip** possible : l'utilisateur peut **mettre en pause** le timer et **passer** une étape (mains-libres mais pas prisonnier).
5. **Mains-libres** : gros compte à rebours lisible à distance ; l'écran ne se verrouille pas pendant le mode minuté (`isIdleTimerDisabled`).

## Acceptance Criteria

### (a) Moteur de timer
1. **AC1** — Un `SessionTimerEngine` (nouveau) gère : durée d'étape, compte à rebours, transition auto, pause/reprise, état work/rest. Logique pure et testable (injection d'une horloge).
2. **AC2** — En HIIT, alternance **work → rest → work…** avec libellés et durées issus de la séance ; à la fin d'un tour, passage au tour suivant jusqu'à R tours.
3. **AC3** — En yoga, chaque posture a une **tenue** (secondes/respirations) ; avance auto à la fin de la tenue.

### (b) Anti-Decathlon + feedback
4. **AC4** — Avant chaque étape minutée, **pré-annonce** : encart « Prochain : <nom> · <format> » + **countdown 3·2·1** + bips audio (`AVAudioSession` lecture courte). Le 1ᵉʳ exo en bénéficie aussi (pas de démarrage à froid).
5. **AC5** — Bips de transition (début/fin work, fin rest) ; volume respectant le mode silencieux iOS (catégorie audio adaptée).

### (c) Contrôles + écran
6. **AC6** — Gros **compte à rebours central** lisible à distance + nom étape courante + « ensuite : … ». Boutons **Pause / Reprendre** et **Passer**.
7. **AC7** — Écran maintenu allumé pendant le mode minuté ; restauré à la sortie.
8. **AC8** — Progression : HIIT affiche « Tour T/R · exo k/K » ; yoga « Posture p/P ».

### (d) Tests
9. **AC9** — `SessionTimerEngineTests.swift` (≥12) : countdown, transition work/rest, fin de tour → tour suivant, dernier tour → terminé, pause gèle le temps, passer saute l'étape, pré-annonce déclenchée avant chaque étape (incl. 1ʳᵉ).
10. **AC10** — i18n FR/EN (Prochain, Prêt, Pause, Reprendre, Passer, Tour, Posture, Work/Rest libellés). Test localisation EN.
11. **AC11** — ui-reviewer : déroulé HIIT (work/rest + countdown) et yoga (tenue) FR + EN.

## Hypothèses / Risques
- **R1 — Données work/rest** : les durées HIIT (40/20) et tenues yoga doivent exister dans le template/`AdaptedExercise` (`duration`, `restSeconds`). **Mitigation** : si absentes, défauts raisonnables + flag « format-aware templates » (chantier séparé) ; ne pas bloquer 3.34, dégrader proprement (timer = `duration` exo, sinon avance manuelle).
- **R2 — Audio bips** : configuration `AVAudioSession` à faire proprement (catégorie `.ambient`/`.playback` + ducking préparé pour 3.35). Réutilisé par le mode audio. **`SessionAudioCues` doit exposer dès 3.34 une interface extensible (config session + `.duckOthers`) que 3.35 branchera pour la voix — ne pas la coder en dur « bips only ».** (review P1.3)

## Out of scope (3.35+)
- **Voix** (TTS) : ici uniquement countdown visuel + bips. La voix qui dit « Prochain : … » = 3.35.
- Mode audio-mené run/vélo/rando ; montre swim.

## Fichiers touchés (preview)
**Nouveaux :**
- `Coaching/Session/SessionTimerEngine.swift` — moteur timer pur (work/rest/tenue/tours).
- `Coaching/Session/SessionAudioCues.swift` — bips + config `AVAudioSession` (socle réutilisé par 3.35).
- `Views/Screens/Coaching/SessionFocusView.swift` (extension) — UI mode minuté (countdown, pré-annonce, contrôles).
- Tests `SessionTimerEngineTests.swift`.

**Modifiés :**
- `Coaching/Session/SessionFocusViewModel.swift` — brancher le moteur timer selon la façon d'avancer.
- `Coaching/Session/SessionStep.swift` — porter durées work/rest/tenue + R tours.
- `Resources/Localizable.xcstrings` (FR/EN).

## Jalons
- **J1 (~1j)** — `SessionTimerEngine` + tests (work/rest, tours, tenue, pause).
- **J2 (~1j)** — UI mode minuté + pré-annonce anti-Decathlon + bips (`SessionAudioCues`).
- **J3 (~0.5j)** — i18n FR/EN + ui-reviewer HIIT/yoga + écran allumé.

Total : **~2-3j**. Garde-fou EU MDR : pas d'injonction médicale dans les cues ; effort indicatif.
