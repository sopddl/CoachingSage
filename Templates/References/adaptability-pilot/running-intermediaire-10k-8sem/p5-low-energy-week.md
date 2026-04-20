# Adaptability : running-intermediaire-10k-8sem + p5-low-energy-week

## Rigidity score
**7/10**

Le template offre une structure suffisamment modulaire pour absorber une semaine allégée (cutback W5 existe déjà comme modèle), mais l'absence de directives explicites sur comment réduire intensité ET volume simultanément, et comment rattraper sans casser la progression, rend l'adaptation partiellement ad hoc.

## Patch approach

Appliquer une stratégie hybride cutback + réduction d'intensité : réduire le volume d'environ 20-25% vs la semaine en cours (plus que le cutback W5 à -15%, car fatigue accumulative), maintenir la cadence des séances (3/semaine préservée) mais abaisser RPE et allures cibles de 1-2 points, et reporter la séance phare J5 à la semaine suivante si elle était prévue. Rattrapage sur W+1 : reprendre la semaine allégée à volume normal + long run à sa progression naturelle.

## Concrete modifications

**Contexte préalable** : adapter en fonction de la semaine en cours du plan (W2-W7 ; W1 et W8 non adaptables sans risque). Exemple sur **W4** (pic de volume avant cutback W5).

- **W[current] J1 (Intervalles)** : Réduire de 33-50% les répétitions. Ex : W4 J1 = `3×800 m` → adapter à `2×800 m` OU `3×400 m à allure 5K`. RPE cible : 7/10 au lieu de 8-9/10 (effort moyen, pas dur).
- **W[current] J3 (Tempo + renforcement)** : Réduire bloc tempo de 20-25%. Ex : W4 J3 = `28 min` → `20-22 min` à allure seuil. Réduire renforcement : 2 séries au lieu de 3 sur tous les exercices. Ou sauter renforcement entièrement si fatigue neuromusculaire sévère (marqueur : impossibilité de tenir RPE 7 sur le tempo).
- **W[current] J5 (Long run)** : Réduire distance de 15-20%. Ex : W4 J5 = `9 km` → `7-8 km` à allure très facile (RPE 4-5/10, conversationnelle complète, sans effort perçu).

**Rattrapage W+1** :
- **W[+1] J1** : Revenir à volume normal de W[current]. Ex : si W[current] adapt = `2×800 m`, then W[+1] J1 = `3×800 m` nominal (pas de surcompensation, juste normalisation).
- **W[+1] J5** : Long run à sa progression prévue naturellement. Ex : si W4 → W5 cutback → W6 (10 km), et tu as adapté W4 J5 en `7 km`, then W6 J5 revient à `10 km` (pas `11 km` ou rattrapage punitif).

## Rigidity issues

- **Absence de protocole explicite d'adaptation intensité + volume** : le template décrit le cutback W5 mais ne fournit pas de formule générale pour réduire RPE ET distance simultanément sur une semaine fatigue arbitraire. Cela force l'entraîneur/athlète à improviser.
- **Renforcement non flexible** : la section `progression_logic` point (4) stipule "renforcement en fin de session, jamais avant", ce qui implique qu'on ne peut pas simplement sauter le renforcement en fatigue sans rupture structurelle. Le patch l'autorise (sauter si besoin extrême), mais c'est une extrapolation du template.
- **Allures dérivées du test W1** : si on baisse RPE (ex : RPE 7/10 au lieu de 8-9/10 sur les intervalles), l'allure réelle baisse aussi, ce qui crée une incertitude : le courant à allure 5K – 5 s/km, c'est quoi en RPE? Le template n'offre pas de table de conversion RPE ↔ allure directe.
- **Rattrapage flou pour W+1** : le template ne spécifie pas si rattraper une séance manquée/adaptée doit être immédiate (J suivant) ou progressive (ajouter +10-15% vs nominal). Le patch propose "normalisation simple", mais un athlète faible en autonomie pourrait mal interpréter.

## Contradictions

- **safety_notes vs réduction RPE** : la section "SIGNES DE SURCHARGE" liste "perte d'allure inexpliquée sur des séances pourtant bien dosées" comme marqueur de surcharge. Baisser l'intensité volontairement (RPE 7 au lieu de 8-9) n'est PAS la même chose, mais le template ne le différencie pas explicitement. Risque : confusion entre "adaptation consciente" et "symptôme de fatigue à traiter".
- **Progression_logic point (3) — cutback W5 immuable** : le template déclare "CUTBACK WEEK EN W5" comme structurel (voir `"week_number" : 5`). Si l'athlète demande une réduction semaine 4, 6 ou 7, c'est une dérogation au design. Le template s'attend à un cutback W5 unique ; deux cutbacks rapprochés (adaptation + W5 nominal) créent un sous-volume excessif non prévu dans la progression globale.
- **Allures cibles interprétables différemment en RPE réduit** : la note `progression_logic` dit "allures cibles sont dérivées du test 5K de W1 (système Jack Daniels VDOT adapté)". Réduire RPE ne change pas la distance cible, mais change l'allure — cela viole implicitement le principe de régularité VDOT. Exemple : W4 J1 `3×800 m allure 5K` est calibré pour VO2max. Faire `3×800 m allure 5K – 30 sec/km` (RPE 7) n'entraîne plus VO2max, mais endurance aérobie — c'est un stimulus différent, et le template ne le valide pas.

---

**Recommandation pour cas d'utilisation réel** :
Si athlète applique ce patch sur W2-W4, progression vers W5-W6 reste viable (W5 cutback nominal permet récupération).
Si athlète applique sur W6-W7 (proches de la séance phare W8), risque de déconditionnement VO2max : préférer repousser la semaine fatigue à W7 (J1-J3 adapté) et maintenir W8 intact.
Si fatigue > 3 signes de surcharge simultanés (voir safety_notes), recommandation template = "réduire 30% et 2 jours repos actif" — c'est plus agressif qu'une semaine adaptée ; considérer un jour de repos ajouté (J2, J4 ou J6 repos complet au lieu d'actif).