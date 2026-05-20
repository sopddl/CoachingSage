# Story 3.14 — Avatar sport contextuel dans le questionnaire (Epic 3)

Status: **ready-for-dev** (scopée 2026-05-19, en attente validation Sophie)
Branche cible : `epic-3/story-3.14-avatar-sport-questionnaire`
Effort estimé : **~0.5j** (dev solo)
Pré-requis : Story 3.13 (mergée main `17cd4ce` 2026-05-19)

## Story

**As a** utilisateur CoachingSage qui démarre un programme sur un sport donné,
**I want** voir l'icône de mon sport (et pas Léon) à gauche des questions du questionnaire de génération,
**so that** je comprends visuellement et immédiatement que ces questions concernent CE sport — surtout quand j'ai plusieurs programmes actifs ou que je relance un questionnaire depuis le dashboard.

## Contexte produit

- **Constat user** (Sophie, test simu V2 2026-05-11) : "Dans le questionnaire, à gauche on devrait mettre l'icône de Léon ou l'icône du sport ?" Sophie penchait pour le sport puis a relativisé (Léon = identité produit). Décision figée 2026-05-19 : **icône du sport dans le questionnaire uniquement**.
- **Aujourd'hui** : `ChatBubbleView` affiche `LeonAvatarView` (cercle `Color.coachingLeon` + SF Symbol `figure.run.circle.fill`) pour toutes les bulles sender `.leon`. Le sport est inconnu de ChatBubbleView. `SportQuestionnaireView` connaît `viewModel.questionnaire.sportCode` mais ne le transmet pas.
- **Identité produit** : Léon reste l'incarnation du coach IA partout HORS questionnaire (FAB, AdaptedProgramView Léon notes, regen badges, dashboard). Le questionnaire = moment de contextualisation sport, c'est l'exception.
- **Mapping sport→symbol déjà fait** : `Coaching/Selector/SportCodeMapping.swift:66-79` expose `Sport.sfSymbol` (10 sports). On le réutilise.

## Décisions Sophie 2026-05-19 (figées)

1. **Avatar de remplacement** : icône SF du sport (figure.run, figure.pool.swim, etc.). Pas de badge Léon + sport (option 2 abandonnée — moins lisible, plus complexe).
2. **Couleur de fond** : `Color.coachingSport(forCode: sportCode)` (mapping sport-specific déjà défini dans `Utilities/Color+Coaching.swift:62-76`). Chaque sport a sa couleur signature (running bleu marine, cycling vert, swimming bleu clair, triathlon or, etc.). Fallback intégré `Color.coachingTextSecondary` pour sportCode inconnu.
3. **Triathlon** : icône fixe `figure.mixed.cardio` (déjà mappée). Le questionnaire universel ne séquence pas les sub-sports natation/vélo/course, donc pas de switch d'avatar par question.
4. **Multi-objectifs (Story 3.13)** : sport est fixe au niveau questionnaire (`UniversalQuestionnaire.sportCode`) → fonctionne nativement sans logique additionnelle.
5. **Hors scope strict** : tous les autres écrans (FAB, AdaptedProgramView notes Léon, regen badges, dashboard cards, `LeonChatPlaceholderSheet`) restent en Léon.

## Acceptance Criteria

### Partie (a) — Nouveau composant SportAvatarView

1. **AC1** — Créer `Views/Components/SportAvatarView.swift` (analog `LeonAvatarView`) :
   - Params : `sportCode: String, size: CGFloat = 40`
   - Mapping : `Sport(sportCode: sportCode)?.sfSymbol` (cf `SportCodeMapping.swift`)
   - Cercle fond : `Color.coachingSport(forCode: sportCode)` (sport-specific, mapping déjà défini)
   - Symbol blanc, padding identique LeonAvatarView (`size * 0.22`)
   - Fallback sportCode inconnu : SF Symbol `"questionmark.circle.fill"` (couleur fond fallback `coachingTextSecondary` géré par `Color.coachingSport`) + `print` warning console (pas crash, pas log analytics V1)
   - Accessibility : `accessibilityLabel(Text("chat.a11y.questionnaireSportAvatar"))` (label générique sport-agnostic V1)
2. **AC2** — `#Preview` couvre les 10 sports (running, cycling, swimming, triathlon, strengthTraining, yoga, hiit, hiking, tennis, football) en grille 2×5 + fallback sport inconnu.

### Partie (b) — ChatBubbleView refactor (rétro-compatible)

3. **AC3** — Ajouter `enum AvatarStyle: Equatable` dans `ChatBubbleView` :
   ```swift
   enum AvatarStyle: Equatable {
       case leon                  // statu quo (default)
       case sport(code: String)   // affiche SportAvatarView(sportCode:)
   }
   ```
4. **AC4** — Nouveau param `avatarStyle: AvatarStyle = .leon` (default préserve la rétro-compat 100% sur les call sites existants).
5. **AC5** — Quand `sender == .leon` :
   - `avatarStyle == .leon` → affiche `LeonAvatarView(size: 32)` (inchangé)
   - `avatarStyle == .sport(let code)` → affiche `SportAvatarView(sportCode: code, size: 32)`
6. **AC6** — Quand `sender == .user` → `avatarStyle` ignoré (bulle user n'a pas d'avatar à gauche, pattern inchangé).
7. **AC7** — Tous les call sites EXISTANTS qui n'utilisent pas `avatarStyle` continuent de fonctionner inchangé (default `.leon`). Aucune régression côté `LeonChatPlaceholderSheet`, etc.

### Partie (c) — Wire dans SportQuestionnaireView

8. **AC8** — `SportQuestionnaireView.bubble(for: message)` :
   - Pour `.leonText` : passer `avatarStyle: .sport(code: viewModel.questionnaire.sportCode)`
   - Pour `.userText` : inchangé (pas d'avatar)
9. **AC9** — `SportQuestionnaireView.bubble(for: .typingIndicator)` : remplacer `LeonAvatarView(size: 32)` par `SportAvatarView(sportCode: viewModel.questionnaire.sportCode, size: 32)`.
10. **AC10** — `AutoProfileReviewView` (preview HK, écran qui précède le questionnaire chat) : audit + swap au sport si `LeonAvatarView` y est affiché (décision Sophie 2026-05-19 : cohérence — tout ce qui précède la génération du programme = avatar sport). Si pas de Léon présent : noop documenté dans la story Phase C.

### Partie (d) — Tests

11. **AC11** — `ChatBubbleViewTests` (nouveau ou étendu) :
    - Rendu Leon par default (sans `avatarStyle`)
    - Rendu Sport quand `avatarStyle: .sport(code: "running")`
    - User bubble inchangée quoi qu'il arrive sur `avatarStyle`
    - Test rétro-compat : call site existant `ChatBubbleView(sender: .leon, textRaw: ...)` compile et rend Léon
12. **AC12** — `SportAvatarViewTests` (snapshot ou pure unit) :
    - 10 sports → SF Symbol correct
    - Sport inconnu → fallback `"questionmark.circle.fill"`
13. **AC13** — `SportQuestionnaireViewModelTests` existants restent verts (zéro modif engine).
14. **AC14** — `UniversalQuestionnaireLocalizationTests` existants restent verts.

### Partie (e) — i18n + ui-reviewer

15. **AC15** — Nouvelle key xcstrings FR/EN :
    - `chat.a11y.questionnaireSportAvatar` :
      - FR : "Avatar du sport"
      - EN : "Sport avatar"
16. **AC16** — ui-reviewer scenario : screenshots questionnaire `ui_review_sport_avatar` sur ≥3 sports (running, swimming, triathlon) en FR + EN. Vérifier :
    - Avatar sport correct sur bulles Léon
    - Typing indicator : avatar sport (pas Léon)
    - Léon toujours visible sur écrans hors questionnaire (dashboard, FAB) — pas de régression
    - Couleur cercle (`coachingPrimary`) ne crée pas de confusion avec d'autres CTA primary à l'écran

## Découpage en sous-tâches

| Phase | Scope | Effort |
|---|---|---|
| **A** | `SportAvatarView` + RenderPreview (AC1-2) | ~1h |
| **B** | `ChatBubbleView` refactor + tests (AC3-7, AC11) | ~2h |
| **C** | Wire `SportQuestionnaireView` (AC8-10) | ~1h |
| **D** | i18n key (AC15) + tests SportAvatarView (AC12) + ui-reviewer (AC16) | ~1h |

Total : **~5h soit 0.5j**.

## Risques + mitigations

- **Régression call sites existants** : default `.leon` sur `AvatarStyle` → 100% rétro-compat. AC7 explicite + test inclus. Grep `LeonAvatarView` post-implem pour confirmer hors questionnaire intact.
- **Sport inconnu (legacy data ou bug)** : fallback `questionmark.circle.fill` + warning console. Pas de crash. AC12 testé.
- **a11y pauvre** : label générique V1 "Avatar du sport" ne dit pas QUEL sport (`chat.a11y.questionnaireSportAvatar.running` plus riche). Si remontée VoiceOver → V2 keys par sport. Acceptable V1 car contexte de navigation (titre de l'écran + bulle texte juste à côté) donne déjà le sport.
- **Cohérence visuelle** : couleurs sport déjà éprouvées sur le dashboard calendrier hebdo (mapping `Color.coachingSport` existant). Risque mineur : si trop saturé sur fond `coachingCard` ivoire → ui-reviewer fera remonter, ajustement opacity possible.
- **Symbole `figure.mixed.cardio` triathlon ambigu** : déjà utilisé partout dans l'app (cf `SportCodeMapping.swift:71`, `ActiveDashboardView.swift:328`), cohérence assurée. Si futur SF Symbol meilleur identifié → swap centralisé sur `Sport.sfSymbol`.

## Hors scope (reporté V2)

- Avatar dynamique par question dans le triathlon (sub-sports natation/vélo/course). Question pas séquencée aujourd'hui, ne mérite pas l'effort V1.
- Label a11y enrichi par sport (V2 si remontée).
<!-- Couleur de fond par sport — DÉJÀ DANS LE SCOPE V1 via Color.coachingSport(forCode:) -->
- Animation transition Léon → sport au démarrage du questionnaire. V1 = swap statique au mount.
- Application aux autres écrans (`LeonChatPlaceholderSheet`, AdaptedProgramView Léon notes). Léon reste l'identité produit hors questionnaire.

## Notes pour le dev

- **Cmd+B obligatoire** après refactor `ChatBubbleView` (paramètre default → check call sites compile).
- **ui-reviewer combo `UI_TEST_LANG=fr`/`UI_TEST_LANG=en`** documenté dans `.claude/agents/ui-reviewer.md`.
- **Mapping `Sport.sfSymbol`** est centralisé — ne PAS dupliquer le switch dans SportAvatarView, juste appeler `Sport(sportCode:)?.sfSymbol ?? "questionmark.circle.fill"`.
- **Couleur** : `Color.coachingSport(forCode:)` est centralisée dans `Utilities/Color+Coaching.swift`. Ne pas dupliquer le switch ailleurs. Fallback `coachingTextSecondary` géré nativement par cette helper pour sportCode inconnu.
