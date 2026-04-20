# Adaptability : hiit-debutant-6sem + p5-low-energy-week

## Rigidity score
**7/10**

Le template contient des mécanismes intégrés pour gérer la baisse d'énergie (section "SIGNES DE SURCHARGE" dans safety_notes, cutback W4 obligatoire), ce qui facilite l'adaptation. Cependant, la progression linéaire est verrouillée semaine-à-semaine : chaque week a un ratio, un volume, des mouvements spécifiques. Une adaptation "baisse d'énergie" en W3 ou W5 exige de naviguer les contraintes logiques sans déstabiliser l'invariant cutback_W4.

## Patch approach

Appliquer un cutback **immédiat et temporaire** : réduire le volume d'effort de 25-30% (vs 15% en cutback W4), revenir au ratio confortable de la semaine précédente (ex : 20/30 → 20/40 si tu es en W3), réduire les sets d'intervalles de 1-2 blocs, maintenir le renforcement à 70% du volume normal. Cela traite la semaine fatiguée comme un "micro-cutback" sans casser la séquence de progression post-récupération.

## Concrete modifications

**Approche semaine-agnostique** (applicable n'importe quelle semaine W2-W6) :

- **Toute séance HIIT intervalle cette semaine** : réduire nombre de blocs de 4 → 3, revenir à ratio W-1 (ex : W3 qui utilise 20/30 → revenir 20/40 ; W5 20/20 → revenir 20/30), réduire sets par bloc de 5-8 → 4-6, viser RPE 7-8 au lieu de 8-9.
  
- **Exemple concret W3 J1** (« Passage ratio 20/30 »)
  - Original : 4 blocs × 5 sets × 20/30 = 4 min d'effort pur
  - Patch baisse énergie : 3 blocs × 4 sets × 20/40 = 2 min 40 s d'effort pur (retour W2 quasi-complet)
  - Mouvements conservés : squat, fente, mountain climber (pas burpee)
  - Repos inter-blocs : 90 s maintenu (essentiel)

- **Exemple concret W5 J1** (« Tabata 20/20 »)
  - Original : 4 blocs × 8 sets × 20/20 = 5 min 20 s
  - Patch baisse énergie : 3 blocs × 6 sets × 20/30 = 3 min d'effort pur (chute volontaire vers W3 density)
  - Ordre : squat → jumping jack → mountain climber (pas pompes en J1)
  - RPE cible : 7-8 (pas 8-9)

- **Séances renforcement (J3 de toute semaine)** : maintenir structure mais réduire 10-15%
  - Exemple W3 J3 : pompes complètes 5 reps → 4 reps, side plank 20 s → 15 s, sets × 3 → sets × 2 sur Dead bug & Calf raises

- **Semaine suivante (post-baisse énergie)** : reprendre la semaine prévue MAIS commencer par J1 de la semaine prévue à intensité 80% (tempo plus lent, RPE cible 7-8), puis J3-J5 à 100%.

## Rigidity issues

- **Cutback W4 est verrouillée sémantiquement** : le template dit « W4 OBLIGATOIRE » pour consolidation. Si baisse énergie tombe en W3, le cutback W4 planifié arrive 5 jours après. **Pas de contradiction logique**, mais **perte de timing adaptatif** : tu auras 2 microcuts rapprochées (custom W3-baisse + W4-plannifiée), ce qui pourrait surcharger le repos. **Recommandation** : si baisse énergie en W3, décaler W4 cutback → reporter d'une semaine à W5 et raccourcir W6. Cela dépasse le scope du template (réorganisation de structure).

- **RPE dans progression_logic est attaché au ratio**, pas à la fatigue externe : la grille RPE est binaire (8-9 en effort, 2-3 en repos). Le template ne propose pas de scaling RPE pour stress/sommeil dégradé. **Adaptation pragmatique** : tu dois reinterpreter RPE 8 comme « effort ferme mais tenant le RPE 7-8 réel » = mental override, pas error du template.

- **Ratio 20/20 en W5-W6 n'a pas d'escalade vers le bas** : si tu es en W5 et fatigue, ton seul recours est retomber à W3-W4 ratios. Sauter W5 → W3 crée une régression perçue. Le template ne nomme pas explicitement ce scenario.

## Contradictions

- **safety_notes : "SIGNES DE SURCHARGE (3+ signes)"** vs baisse énergie contractée cette semaine : le template dit « insérer une cutback week OU pause 48h ». Ton patch l'interprète comme « micro-cutback immédiat = solution intermédiaire entre pause et w4-cutback ». **Pas contradiction directe**, mais **flou normatif** : le template clarifie pas si un micro-cutback ad-hoc (baisse ratio + volume) est équivalent à W4 cutback légal. Disons que c'est un **gap de nommage**, pas une faille logique.

- **Progression_logic : "Pas de box jump ni kettlebell"** N/A pour cette contrainte.

- **Pas de contradictions médicales** : réduire volume/RPE ne contredit aucune safety flag (douleur, FC extrême, tendinite). C'est même préventif.