# Adaptability : triathlon-avance-distance-m-16sem + p5-low-energy-week

## Rigidity score
**6/10**

Le template offre une certaine flexibilité (structure périodisée, cutback weeks déjà intégrées) mais exige des retraitements structurels significatifs pour une semaine fatigue. Les invariants (progressions 10%, cutback logic, brick sessions obligatoires, safety notes sur surcharge) créent des points de friction.

---

## Patch approach

L'adaptation d'une semaine fatigue impose : (1) réduire le volume total de -25 à -40% vs la semaine planifiée, (2) abaisser les seuils d'intensité (Z3-Z4 → Z2-Z3), (3) préserver 1-2 séances de qualité courte (strides, activation) pour maintenir la tonicité neuromusculaire, (4) décaler ou fusionner les séances longues ou les bricks si nécessaire. Le plan n'a pas de "variante fatigue" prédéfinie : il faut donc patcher localement et anticiper un "bounce-back" la semaine suivante.

---

## Concrete modifications

**Exemple appliqué à W5 (semaine avec brick)** :

- **W5 J1 (natation 60 min)** : réduire de 1000 m CSS + drill → 700 m CSS (4×150 m au lieu de 5×200 m), repos +10 sec. Total séance : 45 min au lieu de 60 min. Allure Z2 uniquement, pas Z3.

- **W5 J2 (vélo 80 min)** : remplacer 5×5 min Z4 + 20 min Z2 → 3×3 min Z3 (baisse de la zone) + 30 min Z2. Repos 4 min au lieu de 3 min entre blocs. Total séance : 60 min au lieu de 80 min.

- **W5 J3 (run 60 min)** : supprimer les 3×10 min seuil + 4×400 m VO2max → 2×8 min Z3 (tempo allégé) + 8 min Z2 retour. Total séance : 45 min au lieu de 60 min. Pas de VO2max.

- **W5 J4 (renforcement 45 min)** : réduire à 2 sets par exercice au lieu de 3 (Nordic curl 6 reps au lieu de 8, poids identiques ou -10%). Total renforcement : 30 min au lieu de 45 min.

- **W5 J5 (natation 50 min)** : conserver telle quelle (séance courte de maintien, pas de stress supplémentaire). Option : réduire à 800 m continus Z2 + 200 m drill léger si sommeil vraiment en ruine.

- **W5 J6 (BRICK 110 min - vélo 45 km + run 5 km)** : **transformer en brick réduite** : vélo 35 km Z2 uniquement (pas Z3) + 2 min transition + run 3 km Z2 uniquement. Total : 75 min au lieu de 110 min. **Alternative critique** : si fatigue extrême (FC repos +8 bpm, sommeil < 5h), **supprimer la brick et remplacer par vélo 45 min Z2 seul + run 20 min Z2 seul**, avec 2-3 jours d'écart.

- **W5 J7 (run long 75 min)** : réduire à 50 min Z2 continu (~8 km au lieu de 11 km).

**Volume adapté semaine fatigue W5 : natation 2000 m (vs 2600 m planifié -23%), vélo 70 km (vs 85 km -18%), course 24 km (vs 28 km -14%).**

---

## Rigidity issues

- **Brick obligatoire mais fatigue incompatible** : le template pose les bricks comme non-négociables dès W5 (progression_logic, point 3 : "minimum 1 brick/semaine dès W5"). Une semaine fatigue risque de transformer la brick en trauma supplémentaire au lieu d'adaptation. Le patch exige de convertir la brick en deux séances séparées ou de la décaler — c'est un écart structurel du plan.

- **Cutback logic figée en W4, W8, W12** : si la semaine fatigue tombe **hors** d'une cutback week (ex : W6, W9, W10), il n'y a pas de précédent intégré pour baisser l'intensité en urgence sans désaligner le bloc. Le plan n'offre pas d'itération de "cutback ponctuel".

- **Progression 10% : accumul de semaines fatigue fragilise l'escalade** : si la fatigue force à rester à -30% de volume une semaine, la semaine suivante ne peut pas +12% vs W5 réelle (qui aura été aplanie) — elle doit +12% vs W5 planifiée, créant une dérive. Aucune directive du template sur comment recalibrer après une anomalie.

- **Safety notes : surcharge signes énumérés mais pas "plan B"** : le template liste les drapeaux rouges (FC repos +8 bpm, sommeil < 3 nuits, performance déclinante) mais n'offre pas de séquence d'adaptation automatique — juste "semaine allégée non planifiée". Comment l'appliquer si on est en W6 (bloc développement) et pas en W4 (cutback) ?

- **Renforcement : réduction agressive nuit à la prévention** : si tu allèges le renforcement à 2×3 semaines d'affilée (semaine fatigue + cutback suivante), le risque tendineux (Nordic curl absent → tendinite ischio) monte rapidement. Le plan présume que le renforcement est moins flexible que le cardio, mais le patch l'amincit pareil.

---

## Contradictions

- **Semaine fatigue + progression_logic (RÈGLE DES 10%)** : la rule énonce "jamais volume ET intensité la même semaine". Une semaine fatigue demande de baisser les deux. Cela **viole explicitement** le postulat du plan. Le correctif : appliquer la réduction comme une "semaine de rattrapage partiel" et accepter que W+1 devra remonter moins agressivement que prévu.

- **Brick obligatoire vs safety_notes (surcharge)** : si FC repos +8 bpm et performance déclinante (signes officiels de surcharge), maintenir une brick de 110 min contrairement aux 80 km + 8 km est un **risque de blessure directe**. Le template ne documente pas comment arbitrer : "semaine fatigue allégée" vs "brick obligatoire dès W5". Le patch tranche : brick → réduite ou reportée (quitte à réinjecter en W+2).

- **Tapering (W13-W16) vs semaine fatigue intra-bloc** : si la fatigue frappe W10 (bloc pic), la réduction proposée (-30% volume) est **identique à W13 (affûtage officiel) par le chiffre, mais pas la signification**. W13 maintient l'intensité Z3-Z4 ; W10 fatigue demande aussi des Z2-Z3. La ressemblance superficielle masque une logique contradictoire : en W13 tu es "reposé mais léger", en W10 tu es "épuisé et allégé". Le plan ne distingue pas les deux.

- **"4-7 jours de pause maladie/blessure légère : reprendre 1 semaine en arrière"** (safety_notes) : si une semaine fatigue n'est **pas** une blessure mais un signal de surcharge, l'appliquer littéralement => reculer d'une semaine entière. Mais le template n'offre pas de semaine "faible" autre que cutback. Cela crée un vide : une semaine fatigue est-elle traitée comme "pause" (reculer) ou comme "allègement" (continuer) ?

---

**Résumé exécutif** : le template est **moyennement rigide** pour une semaine fatigue. Il a les briques (cutback, seuils de surcharge) mais pas le mortier (protocole d'adaptation mid-bloc, arbitrage brick vs repos, rattrapage progressif). Un coach doit manuellement convertir les invariants (10% rule, brick obligatoire) en variantes locales — c'est possible mais pas élégant, et le retour à la normale demande une semaine de transition supplémentaire non documentée.