# Adaptability : musculation-expert-strength-5x5-cycle + p5-low-energy-week

## Rigidity score
**7/10**

## Patch approach
Le template offre une flexibilité structurelle via les cutback weeks (W4, W8) et la gestion de la fatigue (safety_notes), mais l'application naïve d'une réduction ad-hoc sur une semaine non-cutback risque de fragmenter la progression double (charges + volume). La stratégie : identifier la semaine actuelle dans le cycle, appliquer un "mini-cutback" ciblé (charges -10%, séries réduites de 5x5 → 3x5), puis compenser progressivement les 2-3 semaines suivantes sans sauter une week entière ou réinitialiser les charges.

## Concrete modifications
- **W<N> (semaine actuelle, peu importe laquelle) — Tous les composés** : réduire les charges de -10% (non -15% comme W4/W8, pour maintenir le stimulus) et passer de 5x5 à 3x5. Ex : si semaine courante = W6 à 85% 1RM, abaisser à 76% et faire 3x5 uniquement.
- **W<N> J1, J3, J5 — Accessoires** : supprimer dips lestés et pull-ups lestés cette semaine. Core réduit à 2 séries au lieu de 3.
- **W<N> — Deadlift uniquement** : réduire le volume de 5 reps → 3 reps (série unique 3x1 au lieu de 1x5), garder les 4 min de repos pour ne pas entamer la capacité neuromusculaire.
- **W<N+1> (semaine suivante)** : revenir aux charges nominales de la semaine, mais maintenir le volume réduit (3x5) pour permettre une transition en douceur. Puis en W<N+2>, revenir au 5x5 complet.
- **W<N+2> (rattrapage chiffré)** : ajouter +2,5 kg à chaque composé (palier réduit vs +5 kg habituel) pour compenser la semaine allégée sans créer un saut explosif.

## Rigidity issues
- **Progression_logic et double progression** : le template bâtit sa cohérence sur la progression **chaque semaine** (+5 kg squat/deadlift, +2,5 kg bench/OHP/rowing). Sauter une semaine ou appliquer -10% casse l'invariant "paliers réguliers" — la semaine suivante, faire un retour à la semaine précédente crée une "semaine fantôme" que le template ne prévoit pas explicitement.
- **Cutback weeks obligatoires en W4 et W8** : le template stipule "OBLIGATOIRES" et énonce qu'elles sont "la fondation de la super-compensation". Appliquer une réduction en W2 ou W5 (non-cutback) contredit implicitement cette logique, même si c'est pragmatiquement justifié.
- **RPE cible et intensité progressive par bloc** : en Bloc 1 (W1-W4), la cible est RPE 6-8 ; en Bloc 2 (W5-W8), RPE 8-9 ; en Bloc 3 (W9-W12), RPE 8,5-9 à 9. Une réduction de -10% peut ramener un Bloc 2 (RPE 8,5-9) à RPE 6-7, ce qui dévalorise la cohérence intra-bloc. À identifier selon la semaine actuelle.

## Contradictions
- **Safety_notes — Surcharge neuromusculaire** : le template énonce explicitement (section "SIGNES DE SURCHARGE") que "FC de repos +10 bpm au réveil pendant 3+ jours" ou "Qualité du sommeil dégradée > 3 nuits" = "semaine cutback immédiate ou repos 3 jours". La contrainte (sommeil dégradé + stress élevé) justifie donc techniquement une réduction, mais le template ne propose que deux options : cutback W4/W8 ou repos 3 jours hors-séance. Une "mini-cutback ad-hoc" sort du cadre écrit — il faut l'assumer comme extension pragmatique autorisée par les safety_notes.
- **Sessions_per_week = 3 immuable** : le template est structuré sur 3 séances/semaine (lundi/mercredi/vendredi). Si la fatigue impose une réduction à 2 séances, il faut décider : sauter J5 ? Ou espacer les séances (lundi/jeudi/dimanche) ? Le template ne le spécifie pas — adaptation ad-hoc nécessaire.
- **Deadlift à 1 rep max en W11 J5 (safety documentée)** : si la semaine fatigue coïncide avec W10-W11, la réduction de charges et volume peut affecter la préparation du PR attempt. À évaluer selon la semaine actuelle.

---

## Résumé appliqué (exemple concret)

**Cas : vous êtes en W6 (Bloc 2 intense, charges ~85% 1RM à RPE 8,5) et vous subissez une semaine fatigue.**

**Adaptation W6 modifiée :**
- Back squat : 85% → 76%, 5x5 → 3x5
- Bench press : 85% → 76%, 5x5 → 3x5
- OHP : 82% → 74%, 5x5 → 3x5
- Deadlift : 85% → 76%, 1x5 → 1x3 (série unique 3 reps)
- Rowing : 85% → 76%, 5x5 → 3x5
- Dips/pull-ups : supprimer cette semaine
- Core : 3 séries → 2 séries

**W7 (rattrapage doux) :**
- Charges = charges nominales de W6 inchangées (85%)
- Volume = 3x5 (ne pas revenir à 5x5 tout de suite)
- RPE cible : 7-8 (vs 8,5 nominal)
- Dips/pull-ups : réintroduire à 75% du lest W6

**W8 (retour normal + avance) :**
- Charges = W6 nominal +2,5 kg (au lieu de W6 +5 kg) — microloading pour rattraper progressivement
- Volume = 5x5 complet
- RPE cible : 8-8,5 (nominal)
- Cutback W8 CONFIRMÉ après cette semaine (obligatoire, non annulé)