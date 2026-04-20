# Adaptability : remise-en-forme-debutant-reprise-6sem + p5-low-energy-week

## Rigidity score
**8/10**

## Patch approach

Le template intègre déjà une semaine cutback obligatoire (W4) conçue explicitement pour gérer la surcharge et la récupération. Cette structure de base rend l'adaptation à une semaine de fatigue très fluide : il s'agit d'appliquer une logique de cutback anticipée ou de réduire les volumes à mi-semaine selon le moment d'apparition de la fatigue. Les progressions ACSM (règle 10-20%, ratio cardio/renfo/mobilité) restent respectées même en réduction puisqu'elles s'ajustent sur les durées, pas sur une formule rigide. Aucune reconstruction nécessaire.

## Concrete modifications

- **W[N] J1 (toute semaine de fatigue)** — Marche rapide : réduire de 20% la durée cible (ex : si W2 prévoit 20 min, faire 16 min ; si W5 prévoit 28 min, faire 22 min). Garder le test de la parole : si impossible en réduit, c'est signe que la fatigue nerveuse est réelle.

- **W[N] J1 renforcement** : supprimer 1 set complet sur CHAQUE exercice (ex : 3 sets → 2 sets). Garder les mêmes reps/durées pour maintenir la qualité du mouvement et ne pas introduire de dégradation technique. Repos entre séries inchangé.

- **W[N] J3 mobilité** : maintenir la séance à durée complète (35-40 min selon semaine). La mobilité active favorise la récupération parasympathique et l'adaptation sans surcharge. C'est une semaine faible — c'est le moment idéal pour reprendre le contrôle respiratoire et la qualité des mouvements lents.

- **W[N] J5 (fin de semaine fatigue)** : appliquer la même réduction que J1 (marche -20%, renforcement -1 set). Ne pas essayer de "rattraper" ou de "tester" en fin de semaine — c'est le piège classique qui prolonge la fatigue.

- **Semaine suivante W[N+1]** : reprendre les volumes normaux de W[N] (pas de saut direct au volume progressé prévu). Exemple : si tu as allégé W3 à cause de la fatigue, W4 reprend les volumes de W3 normal, puis W5 reprend son cutback. Sinon tu risques un rebond de surcharge.

- **Signes de surchage (safety_notes, section SIGNES)** : si 3+ signes cumulés (FC repos ↑10 bpm, courbatures >72h, sommeil dégradé, irritabilité, lourdeur jambes), trigger automatiquement une W[N] allégée même si non planifiée. Le template le dit explicitement : « prendre 1 jour de repos supplémentaire et alléger la semaine suivante ».

## Rigidity issues

- **Aucun majeur.** Le template prévoit déjà les cutback weeks et les drapeaux de surcharge. L'adaptation fatigué est structurellement supportée.

- **Mineure** : le progression_logic met l'accent sur la « règle 10-20% » semaine-à-semaine, ce qui implique une remont progressive après allègement. Si l'allègement dure 2+ semaines consécutives (ex : W3 et W4 fatiguées), il faut expliciter qu'on reprend de W2, pas de "progresser à -20%". Mais c'est une clarification, pas une rigidité.

## Contradictions

- **Aucune.** 

La cutback week W4 est un précédent dans le plan lui-même (progression_logic, point 2 : « Sans cutback, l'appareil locomoteur et le système nerveux central se surchargent progressivement »). Une semaine de fatigue déclenchée suit la même logique. Les safety_notes cautionnent explicitement la réduction : « Si 3+ signes simultanés : prendre 1 jour de repos supplémentaire et alléger la semaine suivante ». 

L'adaptation ne casse aucun invariant du plan :
- **Ratio cardio/renfo/mobilité** reste ~40/40/20 même en réduit (marche -20% reste ~40%, renforcement -2 sets sur ~6 = ~33%, mobilité inchangée = ~27% → toujours équilibré).
- **Récupération 48h+** entre séances : maintenue (J1, J3, J5 inchangés).
- **Progression globale 6-semaines** : retardée d'une semaine si allègement mi-plan, mais séquence pédagogique (squats → fentes → planche classique) préservée.