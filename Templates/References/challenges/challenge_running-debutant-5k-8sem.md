# Challenge Report : running-debutant-5k-8sem

## Verdict
Template **bundlable en l'état avec remarques pédagogiques mineures**. La structure suit fidèlement NHS C25K, le dosage run/walk est sain, la progressivité respecte la règle des 10-20%, et le renforcement préventif est bien intégré dès W1. Les safety_notes sont exhaustives et les warnings spécifiques au débutant couvert. Trois points à adresser avant bundle idéal : clarification du statut du "5K" final (distance vs durée), absence totale de day 4 en W8 (trou de cohérence), et une redondance pédagogique W3-W4 à évaluer.

---

## Issues critiques (bloquantes pour bundle)

**[W8 Day 4]** Jour 4 absent : pattern de 3 séances/semaine depuis W1, mais W8 affiche jour 1, 3, 5 sans jour 4. Cela crée une asymétrie : 9 jours entre W7 J5 et W8 J1 (logique tapering), puis 2 jours seulement W8 J1→J3, puis 2 jours J3→J5. → **Fix proposé** : soit supprimer jour 4 explicitement pour clarifier (pattern W8 intentionnellement condensé), soit ajouter une séance mobile optionnelle "Day 4 : repos actif ou mobilité 20 min" pour maintenir régularité. Actuellement c'est ambigu.

---

## Issues importantes (à corriger avant bundle idéal)

**[default_objective vs W8]** Contradiction entre "30 min continu (équivalent 5K)" et la note W8 J5 : "Si tu couvres 5 km dans ce temps, super. Sinon tu continues [...] jusqu'à atteindre 5 km (max 45 min), ou tu t'arrêtes à 30 min et le 5K sera pour la semaine suivante". Cela affaiblit l'objectif stated. Un débutant sédentaire à 8-10 min/km couvrant ~3-4 km en 30 min ne "rate" pas son objectif. → **Fix proposé** : redéfinir `default_objective` en "Courir 30 min en continu sans interruption" (axe durée), avec note W8 : "À cette allure (6-10 min/km selon profil), tu couvriras 3-5 km. L'objectif est la continuité, pas le kilométrage." Ou accepter deux objectives : "Durée 30 min" (primaire) + "Distance 5K" (bonus selon profil).

**[W3 vs W4 progression clarity]** W3 introduit le bloc laddered 3 min (2×[1m30+1m30 marche + 3 min + 3 marche], total 4m30 course/cycle). W4 D1-D5 enchaîne sur blocs 3 min consolidé puis bloc 5 min neuf (+22% volume). Passage rapide et cohérent avec la règle 10-20%, MAIS pédagogiquement abrupt pour un débutant : jump de 3 min à 5 min en une semaine sans palier intermédiaire. W3 J5 = max 9 min de course/séance (2 cycles × 4m30), W4 J1 = 15 min (2×3 min + 1×5 min). → **Fix proposé** : insérer en W4 D1 une note "Si bloc 5 min trop ambitieux, rester 2 séries blocs 3 min — progression n'est pas linéaire". Ou ajouter palier W3.5 fictif (aucune semaine supplémentaire, mais justifier 3→5 par 5 minutes étape intermédiaire non écrite). Actuellement c'est valide mais demande confiance élevée du débutant.

---

## Issues mineures (nice-to-have)

- **[W1-W8 RPE/HR mentioning]** test_de_la_parole est excellent, mais absence totale de RPE ou bandes HR. Un débutant bénéficierait de "RPE 3-4/10" pour W1-W3 (très léger) et "RPE 4-5/10" W7-W8, aligné sur ACSM Beginners Guidelines. Safety_notes mentionne "respiration facile" mais pas la formule RPE chiffrée.

- **[Cadence notation]** W7 J5 mentionne "Cadence cible ~170-180 pas/min" mais c'est la seule occurrence. Aurait mérité d'être en W1 J1 déjà (référence pour tout le plan). Pas critique car mentionné en safety_notes, mais cohérence W-level manque.

- **[Cooldown variabilité]** Cooldowns W1-W6 : "5 min marche + X min étirements" avec X∈[2,5]. W7-W8 varient davantage (5-7 min marche, 5-10 min étirements). Aucune instruction sur durée d'étirements statiques (recommandation NHS : 30 sec/muscle). Notes W1 donnent "30 sec/jambe" mais étapes ultérieures juste "étirements 5 min" vagues. → Factuel : couverts en W1 et safety_notes, mais moins systématique ensuite.

- **[Bird-dog "hold 2 sec" en W3 manquée en W4]** W3 D3 : "Bird-dog : [...] Tenir 2 sec." W4 D3 omet la note "hold". C'est identique à W3 physiquement mais pédagogiquement une cible timing se perd. Mineure si le coureur fait la connexion W3→W4, mais notation incohérente.

---

## Manques notables

- **Aucun plan B / flexibilité documentée pour régression** : si un coureur patauge sur W4 bloc 5 min, le safety_notes dit "recule d'une semaine" mais ne précise pas quelle W et comment. → Clarifier : "Si bloc 5 min non tenable 2 séances d'affilée, reprendre W3 structure (laddered) 1 semaine puis W4 J5 seulement (bloc 5 min)", exemple concret bienvenu.

- **Absence de post-plan guidance** : après W8 J5 (30 min acquis), quoi faire ensuite ? Hausse progresssive à 45 min ? Introduction du tempo ? Fréquence long run ? Safety_notes et progression_logic couvrent le plan mais pas l'après. → Optional : footer "Pour progresser après W8 : semaine 9+ peut passer à 2 séances /sem run + 1 renforcement, avec 1 run long progressif (35, 40, 45 min) et 1 run facile 20-25 min. Consulter un coach pour plan spécialisé 5K performance (vitesse) si c'est l'objectif."

- **Absence de nutrition/hydration baseline pour séance > 20 min** : safety_notes couvre hydratation pré/post-séance (500 ml), mais aucune mention carburant pendant W7 J5 (20 min) et surtout W8 J5 (30 min). À 10 min/km c'est 30-45 min effort : au-delà de 45 min, glucides seraient pertinents. À 6 min/km c'est 18-30 min : à la limite. → Note W7-W8 : "Séances ≥ 20 min : hydrater légèrement si chaleur > 20°C, sucre/gel inutile < 45 min effort."

- **Exercice "Squats poids du corps" en W7 D3 jamais vu en W1-W6** : appel soudain à W7. Wall sit ≠ squat poids du corps. Cela dit, c'est une progression logique et sûre (wall sit est plus dur, squat poids du corps plus fonctionnel), donc cohérent, mais non progressif linéaire. → Minor pédagogie : justifier "Transition wall sit → squats pour force dynamique avant endurance 15-20 min" ou l'introduire plus tôt (W5 cutback par ex, pour tester).

---

## Scores (sur 10)

**Cohérence interne : 9/10**
- `duration_weeks` = 8 ✓, `sessions_per_week` = 3 ✓, weeks.count = 8 ✓
- Volume hebdo course : 16 (W1) → 18 (W2) → 18 (W3) → 22 (W4) → 23 (W5) → 28 (W6) → 35 (W7) → ~50 pic (W8) = progressivité validée (règle 10-25% hebdo)
- Cutback W5 présente et documentée (volume −9% vs W4)
- Renforcement intégré W1-W8 sans rupture
- **Défaut** : W8 day 4 absent (voir critique), confusion dur/distance objective

**Alignement référentiel : 9/10**
- NHS C25K mapping : W1-W3 run/walk, W4-W6 allongement blocs, W7-W8 continu = exact
- Renforcement préventif (mollets W1, clamshells W1 anti-ITBS, core W2) = best-practice ACSM Beginners
- Ladder progression (1m30→3m→5m→8m→10m→15m→20m→30m) = fluide, pas de saut > 5 min sauf W4 (3→5) qui est acceptable
- Safety_notes drapeaux (shin splints, ITBS, fasciite plantaire) = complets et spécifiques niveau débutant
- **Léger bémol** : aucune mention fréquence cardiaque cible (est-ce intentionnel pour éviter anxiety ?) ou zones ; test_de_la_parole compense bien mais plus précis aurait aidé

**Sécurité : 10/10**
- Échauffement obligatoire et détaillé W1 J1 (5 min marche + mobilité 3 min)
- Progression volume respecte loi d'adaptation os/tendon (6-8 sem avant adaptation tibia)
- Équipement : chaussures < 600 km, surfaces souples mentionnées
- Rest jours implicite (pattern J1 run / J2 repos / J3 strength / J4 repos / J5 run / J6-J7 repos) bien enraciné
- Récupération post-séance : cooldown systématique + étirements
- RPE implicite test_de_la_parole ≡ RPE 3-4/10 (prudent)
- Signaux surcharge documentés (FC repos, sommeil, motivation)
- **Aucun drapeau rouge manquant** pour débutant

**Pédagogie : 8/10**
- Instructions détaillées W1 : "Ne jamais sauter cette étape" (échauffement), "Si souffle coupe au bout de 30 sec, ralentis" (rassurance débutant) = excellent
- Notes ratios run/walk clairs (1m course + 1m30 marche)
- Progression par pallier logique et justifiée ("premier vrai cap", "transition vers endurance")
- **Faiblesses** : 
  - W3-W4 jump (3→5 min) peut perdre débutant nerveux sans palier intermédiaire visible
  - Absence de "Si tu fails cette séance" checklist (si J1 bloc 5 min échoue, retry J3 ou reprendre W3 ?)
  - Post-plan vide (quoi faire après W8 ?)
  - Squats poids du corps W7 soudain sans intro W1-W6

---

## Résumé final

Template très solide, aligné NHS C25K, dosage sain (règle 10-20% respect), renforcement préventif implanté correctement dès W1, safety_notes exhaustives. **Blocante unique** : W8 jour 4 manquant (clarifier intent). **Importantes** : objective "30 min + 5K" ambigu (prioriser durée), W3→W4 jump 3→5 min pédagogiquement abrupt (justifier ou palier). Reste = excellent pour un programme de grande audience (iOS app) — débutant sédentaire suivra confiant avec notes rassurants et progressivité respectée. Bundle possible après address W8 day 4 et objective refondu.