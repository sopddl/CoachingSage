# Party — Comité revue PILOTE MUSCU (dosage caméléon)

**Date** : 2026-06-07 · **Étape pipeline** : 3 (revue comité) — CLOSE.
**Entrées** : `referentiel-dosage-cameleon-v2-FIGE.md`, `spec-dosage-muscu-PILOTE-2026-06-07.md`, captures `/tmp/dosage-muscu-capture/`.

## Casting
Sally (UX), Marc (prépa physique/coach muscu), Maxime (novice), Inès (posée), sophie-ux-challenger (pre-screen).

## Problème
L'écran d'effort muscu dit *combien de reps / combien de repos* mais reste **muet sur la charge** (cœur du dosage muscu) et **parle jargon** (« RPE 6-7 ») là où il en parle — alors qu'on ne peut pas (EU MDR) ni ne veut (D1) prescrire un poids. Faire ressentir le bon effort **sans chiffre imposé ni jargon**, écran lisible en plein effort.

## Tour de table (résumé)
- **Maxime** : « je prends quel poids ?? » → rien aujourd'hui ; la consigne « commence léger » sauve, mais au moment de saisir ; RPE = jargon angoissant ; chrono géant stresse (muscu ≠ course).
- **Inès** : incohérence « 30 sec »→« 15 sec » casse la confiance ; veut un champ pour noter le poids ; côté « par côté » ambigu → veut « Côté droit » puis « Côté gauche ».
- **Marc** : zéro kg = juste légalement ET pédagogiquement (sécurité = sensation + variante) ; garder l'INTENTION du RPE, jeter le MOT ; chrono n'a aucun sens en héros muscu (reps pilotent) ; récup typée inter-séries.
- **Sally** : 1 héros (reps) + 1 support (consigne charge OU repos) + reste séquencé (côté = annonce d'entrée) ; champ poids stepper ± pré-rempli jamais clavier ; cas vide = consigne jamais « 0 kg » ; retirer le badge RPE.
- **Challenger** : NEEDS_FIX (G6 = bug data hors scope ; i18n « effort sur 10 » avant code) + 2 BLOCKING (AC1, AC2) résolus par Sophie ci-dessous.

## Tensions tranchées
| # | Tension | Décision Sophie |
|---|---|---|
| T1 | Héros Minuté = reps vs chrono (touche 3.34) | **Reps en héros**, chrono en filet |
| T2 | Jargon RPE : affichage vs templates | **Hybride** : conversion au rendu + nettoyage prose des 4 notes |
| T3 | Pilote resserré vs complet | Resserré : variante = **afficher si présente** (pas de génération V1) |
| — | Côté : auto vs confirmé | **Confirmé par tap** (non-bloquant) |

## DÉCISIONS — scope figé

### ✅ V1 SOPDDL (à coder)
1. **Modèle** (`AdaptedExercise`, non-breaking, 0 migration) : ajouter `load: String?` + `side: ExerciseSide?` (left/right/bilateral). Récup typée = inter-séries (muscu).
2. **Charge (G1)** : consigne « commence léger ; dernière rép dure mais faisable ; garde-en sous le pied » **en entrée de set** + champ « poids noté » **stepper ± pré-rempli, optionnel, non-bloquant**. Cas vide = **consigne** (jamais « 0 kg »).
3. **Jargon (G2, AC1=Hybride)** : retirer le badge « RPE 6-7 » → afficher l'intention **« effort 6-7 sur 10 »** (conversion target_zone au rendu, règle valable tous sports) + **nettoyer la prose « GRILLE RPE/RIR »** des 4 notes templates muscu. Clés i18n FR/EN/ES créées AVANT le code.
4. **Héros Minuté (G3, AC2=Reps)** : **reps en héros** (gros chiffre), chrono rétrogradé en filet.
5. **Côté (G4, AC4=Confirmé)** : `side` structuré + guidage **« Côté droit » / « Côté gauche »** (affiché + vocalisé), passage **confirmé par tap**.
6. **Variante (G5, AC5=Afficher si présente)** : afficher la variante facile/standard **uniquement si le template la porte**.

### ⏭️ V2 (acté)
Tracking auto charge (« comme la dernière fois » + stockage historique par exo), génération auto de variantes, Live Activity / écran verrouillé, toggle densité explicite.

### 🗑️ Hors scope pilote
- **G6** « Planche 30 sec » → chip « 15 sec » = **bug data template** → loguer séparément (pas dans la passe dosage).
- **G7** tempo en prose = P2 différé.

### AC mineurs réglés en séance
- **AC3** : consigne charge = **entrée de set** + rappel près du champ poids.
- **AC6** : champ poids = **stepper ± pré-rempli**, unités localisées kg/lb, placé sous les reps en FOCUS.
- **AC7** : accessibilité V1 = Dynamic Type sur héros/support + VoiceOver ordre [reps → charge → côté → repos] + cibles 44pt stepper.

## Prochaines actions
1. Implem SOPDDL V1 (ordre : i18n keys → modèle → conversion RPE+nettoyage notes → FOCUS reps-héros + charge + côté → variante).
2. ui-reviewer (obligatoire, `Views/**` touché).
3. Device-test Sophie (charge stepper + côté vocalisé + reps-héros).
4. Merge + tracker + mémoire. Puis la passe muscu sert de patron à la série (9 sports).
