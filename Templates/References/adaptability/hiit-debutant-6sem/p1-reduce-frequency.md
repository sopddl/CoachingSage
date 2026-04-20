# Adaptability : hiit-debutant-6sem + p1-reduce-frequency

## Rigidity score
**6/10**

Le template offre une flexibilité modérée. Les progressions (ratio, volume, mouvements) sont bien documentées et peuvent être préservées en 2 séances/semaine via fusion intelligente. Cependant, la **cutback W4 perd sa logique structurelle** (elle suppose 3 séances denses) et la **séparation strength/interval** devient contraignante à 2 séances — il faut choisir entre sacrifice articulaire (pas de renforcement préventif) ou sacrifice cardio (ratio/volume limité).

---

## Patch approach

Fusionner chaque semaine en 2 sessions mixtes (strength + interval enchaîné) plutôt que trois sessions spécialisées. Préserver les progressions clés (ratio work/rest, volume d'effort, mouvements) en acceptant une réduction du renforcement préventif. La cutback W4 devient déplacement des séances les plus denses (W3 → relâcher 1 jour via jour off) plutôt qu'allègement volumétrique classique.

---

## Concrete modifications

**W1** 
- Supprimer J5. Fusionner J1 (interval) + J3 (strength) en 35–40 min : échauffement → 2 blocs Tabata 20/40 (squat + step touch) + 1 bloc marche rapide sur place → repos 90s → renforcement fondation (planche 20s/3×, pont 12/3×, superman 10/3×, dead bug 6/3×, calf 15/3×). Cela préserve la découverte RPE et 3 mouvements HIIT essentiels.
- Jour 3 (ancien J3) devient session **autonome optionnelle** si récupération bonne (cible : planche, pont, dead bug uniquement = 20 min).

**W2**
- Supprimer J5. Fusionner J1 (4 blocs 20/40) + J3 (renforcement étendu) : échauffement → 4 blocs Tabata 20/40 (squat, fente, pompe, jumping jack) → 90s repos → renforcement (planche 20s, pont 15, superman 12, dead bug 8, calf 20, pompe 8/3×). Durée : 42 min.
- Jour 3 optionnel : calf + mobility.

**W3**
- Supprimer J5. Fusionner J1 (4 blocs 20/30) + J3 (renforcement) : échauffement → 4 blocs 20/30 (squat, fente, mountain climber, burpee) → repos 90s → renforcement (planche 30s, side plank 20s/côté, pont uni 10, dead bug 10, calf surélevé 12/3×). Durée : 42 min.
- **Avertissement** : volume d'effort W3 = 4 min, identique au template W3. Pas d'allègement — W4 assurera la consolidation.

**W4 (Cutback)**
- Supprimer J5. **Reconfigurer cutback non comme allègement 15% mais comme substitution d'une séance complexe par une séance légère allongée**.
  - J1 : échauffement → 3 blocs 20/40 (squat, fente, squat) + renforcement léger (planche 25s, pont 10, dead bug 8/3×). Durée 28 min.
  - J3 : **ajout optionnel mobilité + respiration contrôlée** 20 min (yoga flows légers, tai-chi style) — simule le repos cognitif d'une vraie cutback week sans exiger équipement/technique.

**W5**
- Supprimer J3 renforcement initial. Conserver J1 (Tabata 20/20 × 4 blocs) + J5 (EMOM 16 min).
  - J1 : échauffement → 4 blocs Tabata 20/20 (squat, jumping jack, mountain climber, pompe) + cooldown 4 min. Durée : 35 min. **Renforcement écourtée après cooldown : planche 30s/3×, pont 10/3×, calf 12/3× = 8 min**. Total 43 min.
  - J5 : échauffement + EMOM 16 min (4 cycles × 4 mouvements) + cooldown. Durée : 35 min. **Pas de séance J3** — l'EMOM remplace le renforcement dédié.

**W6**
- Conserver J1 (Tabata 20/20 × 4 blocs, 38 min) + réduire J3 en **raccourci 25 min** (planche 40s, pompe 6/3×, side plank 20s, pont 10, EMOM 8 min allégé = 3 mouvements × 2 cycles). Supprimer J5 autonome.
- Alternative : conserver J5 (la séance phare autonome 20 min) et supprimer J3.

---

## Rigidity issues

- **Cutback W4 logique détruite** : le template décrit W4 comme semaine allégée 15% après 3 semaines de progression. Passer à 2 séances détruit ce timing — tu fais déjà 3 semaines condensées (W1-W3 en 2 séances chacune). La cutback perd son rôle de "soufflante" et devient un jour off déguisé.
  - **Fix** : traiter W4 comme semaine où tu ajoutes un jour off complet (total 2 séances à RPE réduite) plutôt que 2 séances au régime W4. Exemple : J1 + J3 uniquement, pas de EMOM.

- **Renforcement préventif comprimé** : le template insiste sur "RENFORCEMENT PRÉVENTIF INTÉGRÉ" (calf raises, planche, dead bug pour protection cheville/genou/lombaire avant sauts W5). En 2 séances, il y a un conflit direct — soit tu gardes l'interval à plein volume, soit tu sacrifies le renforcement prophylactique. Si tu passes à squat sauté W5 sans 4 semaines d'un pont fessier/planche/calf proper, le risque de tendinite d'Achille ou genou en valgus monte significativement.
  - **Fix** : ajouter un J3 optionnel en W4-W5 (15–20 min) où tu fais **seulement** pont fessier unilatéral, side plank, calf excentriques. Pas de séance d'interval chargée — juste les exercices "boucliers".

- **Sessions_per_week = 3 codifiée** : le template annonce `"sessions_per_week" : 3` et découpe chaque semaine en 3 jours J1/J3/J5 fixes. Il n'y a pas de flexibilité syntaxique — chaque semaine suppose l'existence de 3 sessions distinctes. Passer à 2 exige de modifier **chaque semaine**.

- **Progressions 20-25% par semaine** : le template annonce `PROGRESSION VOLUME EFFORT PAR SÉANCE : W1 = 2 min 40 s, W2 = 3 min 12 s (+20%), W3 = 4 min (+25%)...`. Ces chiffres décrivent un cumul sur 3 séances/semaine. Fusionner J1 + J3 signifie que 2 sessions devront contenir tous les éléments, donc chaque séance individuelle sera plus dense. Risk : tu atteins 4 min 40s d'effort d'interval + 20 min de renforcement en une seule session W3 = 42 min sans repos inter-séances — tu demandes au corps de traiter W3 entièrement en un jour au lieu de l'étaler.

---

## Contradictions

- **Safety_notes : "Récupération entre séances HIIT : minimum 48h entre deux séances à haute intensité"** — ton J1 + J5 (4 jours d'écart) respectent cette règle. **Mais le renforcement comprimé en J1 ajoute 20 min de travail après l'interval cardio, ce qui aggrave la fatigue neuromusculaire et retire le repos cognitif que le débutant attend entre séances.**

- **Safety_notes : "DOMS (courbatures retardées) 24-48h après = normal et attendu, surtout en W1-W2"** — si tu fais J1 (2 blocs 20/40 + renforcement complet) et J5 (squat + step-touch + marche rapide), tu auras DOMS à J2-J3. À J5 (4 jours après J1), les DOMS peuvent persister en début de séance → test de la parole adapté (section "Test de la parole") échoue souvent à J5. Le template dit "Si après 2 min de repos inter-bloc tu ne récupères pas, le volume est trop élevé — retirer un bloc." En réalité, c'est les courbatures du J1 qui empêchent la récupération cardio à J5, pas l'interval lui-même.

- **Progression_logic point (2) : "Hors cutback, progression +20-25% maximum entre semaines actives"** — en fusionnant sessions, tu passes de W2 (3 min 12s effort × 3 séances) à W3 (4 min effort × 2 séances). Cela respecte le +25% volumétrique global, mais **chaque séance W3 inclut 4 mouvements différents en 42 min**, ce qui ressemble à une accumulation plutôt qu'une progression progressive. Le template suppose que W2-J1, W2-J3, W2-J5 sont trois "dégustations" du même ratio/volume sur 5 jours. À 2 séances, tu concentres tout en 4 jours — le risque d'overtraining monte.

- **Progression_logic point (5) : "Introduction squat sauté W5 uniquement après 4 semaines de ces prérequis" (pont fessier, planche, calf raises)** — en W1-W4 à 2 séances, le renforcement est limité à 15-20 min par semaine au lieu de ~30 min idéalement (3 séances × 10 min). Les 4 semaines de "prérequis" sont respectées temporellement mais pas volumétriquement. Risque : squat sauté W5 sans assez de renforcement fessier/cheville.

---