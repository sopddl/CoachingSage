# Story 3.30 — Questionnaire : remonter le fil

**Branche** : `epic-3/story-3.30-questionnaire-remonter-fil`
**Trigger** : Sophie 2026-05-25 (test simu post-3.22-G) — « quand je crée un programme je veux
pouvoir changer mes réponses et ne pas avoir à confirmer ma réponse, uniformise le flux ».
Cf mémoire `v2_chantier_questionnaire_edit_uniform`.

## Constat avant dev

- **« Ne pas confirmer »** : déjà majoritairement livré par la **Story 3.25** (auto-advance
  singleChoice, postérieure au feedback du 25/05). Toutes les questions à choix unique avancent
  au tap. Ne restent que 2 confirmations **structurelles** (multi-objectifs Q2 + date Q4Date) —
  on les **garde** (impossible d'auto-avancer une sélection multiple ou un date picker).
- **« Changer mes réponses »** : il existe un bouton « Retour » (Story 3.16) qui dépile question
  par question (`goBack()`), mais **pas de navigation directe**. C'est le cœur de cette story.

## Décisions produit (Sophie, cette session)

1. **Édition = remonter le fil** : tap sur n'importe quelle réponse passée dans le chat → la
   question se rouvre en place. (vs récap final / bulles seules — voir mémoire.)
2. **Branchement conditionnel = garder ce qui reste valide** : modifier une réponse amont ne
   réinitialise PAS les réponses aval encore cohérentes ; seules les réponses devenues hors-parcours
   sont laissées dormantes (ignorées au build) et ré-utilisées si leur question revient dans le parcours.
3. **Confirmations** : on garde « Confirmer » (multi) + « Continuer » (date), harmonisés. Le multi
   est le cas fréquent assumé (Sophie prend souvent plusieurs objectifs) — pas de revert mono-objectif.

## Architecture livrée

### Source de vérité = `accumulatedAnswers` + parcours

Le moteur `UniversalQuestionnaire.nextQuestion` est déterministe et linéaire. On dérive l'état
visible (`messages`, `questionHistory`, `conversationHistory`, `currentQuestion`) en **marchant le
parcours** depuis `firstQuestion` en suivant les réponses accumulées.

### `rebuildFromAnswers(editing:)` (ViewModel)

Reconstruit le fil en marchant le parcours :
- pour chaque question répondue + atteignable → rejoue bulle Léon + bulle user, push history/convo ;
- s'arrête à `editing:` (question à ré-poser) **ou** à la 1re question non répondue → `currentQuestion`.
- **Pas de pruning destructeur** : les réponses aval non atteignables restent dans `accumulatedAnswers`
  (dormantes), ce qui réalise « garder ce qui reste valide » + réutilisation si la question revient.
  `buildProfile` est défensif (résout durationMode via Q3 prioritaire) → dormantes inoffensives.

### `beginEditing(questionId:)`

`guard !isAdvancing` + réponse existante → `isEditingInPlace = true` + `rebuildFromAnswers(editing: id)`.
Ne dépend PAS de `questionHistory` (vide après autoprofil) → édite aussi les réponses pré-remplies HK.

### Commit d'édition (`answer()`)

Branche dédiée si `isEditingInPlace` : pose la nouvelle réponse + `rebuildFromAnswers(editing: nil)`
(rejoue en aval en réutilisant les dormantes encore valides) → `submit()` si parcours complet.
Le chemin forward normal (et l'autoprofil pré-rempli) restent **inchangés** (risque contenu).

### View

- `ChatMessage.userText` porte désormais `questionId` → mapping tap → question.
- Bulles user **éditables** (pencil + tap → `beginEditing`) dans `SportQuestionnaireView`.
- Bouton « Retour » toolbar conservé (affordance explicite complémentaire).

## Tests VM (logic)

1. Éditer Q1 niveau garde Q2/Q3/Q4 → re-submit avec downstream préservé.
2. Éditer Q3 → `dont_know` sort Q4/date du parcours → durationMode = routineCyclic (dormantes ignorées).
3. Éditer Q2 goal eligible→non-eligible retire Q4.
4. Éditer Q2 goal non-eligible→eligible ré-pose Q4 (jamais répondu).
5. `beginEditing` no-op si `isAdvancing` / id inconnu / réponse absente.
6. Édition d'une réponse pré-remplie autoprofil (questionHistory vide).
7. conversationHistory cohérente (longueur = parcours répondu) après édition.
8. Non-régression : idempotence double-tap, cross-user race, full flow, goBack.

## Livraison

ui-reviewer (FR+EN, découvrabilité du tap-pour-éditer) + test simu Sophie. Hors scope : « séance en
retard moins agressive » (story cosmétique séparée).
