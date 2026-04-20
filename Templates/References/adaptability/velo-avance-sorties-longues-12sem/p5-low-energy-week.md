# Adaptability : velo-avance-sorties-longues-12sem + p5-low-energy-week

## Rigidity score
**7/10**

Le template offre une structure claire pour les cutbacks (W4, W8, W12) avec réduction de 15-20%, mais l'adaptation à une semaine de fatigue **ad hoc** exige de naviguer plusieurs invariants (progression_logic pilotée par les blocs, seuils chiffrés précis, volumes hebdomadaires encadrés par la règle des 10%). Le patch est **faisable mais précis**, pas une simple réduction linéaire.

## Patch approach

L'adaptation consiste à **identifier la semaine d'occurrence de la fatigue** et à appliquer un protocole d'allègement ciblé : réduction 30-40% du volume total (vs cutback standard 15-20%), suppression des intervalles d'intensité (Z4-Z5), maintien du Z2-Z3 en endurance courte, et **compensation** par décalage de 1-2 semaines suivantes. La progression_logic reste valide car les cutbacks structurels (W4, W8, W12) ne changent pas ; seule une semaine non-planifiée est modifiée.

## Concrete modifications

- **Semaine de fatigue (à identifier : ex W5, W7, W9, W10)** : appliquer ce patch universel :
  - **J1 (intervalle prévu)** → Remplacer par 45 min Z1-Z2 (80% du volume nominal, aucun intervalle Z4-Z5). Ex : si W5 J1 = 2×15 min Sweet Spot (90 min), → 45 min Z2 léger cadence 90 rpm.
  - **J3 (sortie endurance standard)** → Réduire durée de 30% (ex W5 J3 = 135 min → 95 min Z2 strict, 0 sprint de cadence).
  - **J5 (intervalle secondaire)** → Supprimer ou remplacer par 8 min Z3 simple (1 bloc, 0 récupération active, juste Z1 doux avant/après). Ex : si W5 J5 = 5×4 min Z5, → 1×8 min Z3 (76-90% FTP) avec 15 min warmup + 10 min cooldown.
  - **J7 (sortie longue)** → Réduire distance de 20-30% (ex W5 J7 = 110 km → 75 km Z2 strict, 0 bloc Z3/Z4 planifié).
  - **Volume hebdomadaire cible réduit** : application règle des 10% en sens inverse. Ex si W5 planifiée ~230 km → cible ~160 km (−30% = 160 km). Respecte l'interstice de fatigue sans créer chute > 30% qui viole le principe de "progression douce".

- **Exemple concret — Semaine 7 affectée par fatigue** :
  - W7 J1 (90 min : 2×15 min Sweet Spot + 4×2 min Z5) → **60 min Z2 léger** (cadence 90 rpm, puissance 60-70% FTP, pas d'intervalle).
  - W7 J3 (110 min : 90 min Z3 tempo) → **75 min Z2** (rester conversationnel facile).
  - W7 J5 (85 min : 5×10 min Z4) → **50 min : 1×12 min Z3 tempo uniquement**, récup Z1 avant/après.
  - W7 J7 (285 min : 130 km Z2-Z3 pic) → **180 min : 75 km Z2 strict**, 0 blocs Z3.
  - **W7 volume : ~270 km nominale → ~160 km exécutée** (−40%).

- **Semaine suivante (W8 si W7 fatigué)** : W8 est cutback planifiée (~215 km) → **maintenir le cutback W8 inchangé** (pas de surcompensation). La fatigue "compte" comme une micro-cutback additionnelle.

- **Semaine N+2 (W9 si W7 fatigué)** : reprendre le plan nominal W9 (~230 km) **sans ajustement** ; les adaptations physiologiques ne rattraperont pas 110 km en 1 semaine et c'est OK pour un plan de 12 semaines (flexibilité de 10-15% tolérée par la progressio_logic).

## Rigidity issues

- **Invariant de progression hebdomadaire cassé** : la règle des 10% (point 2 dans progression_logic) stipule "aucun delta hebdomadaire en bloc de progression ne dépasse 13%". Une réduction de 40% sur une semaine de fatigue **viole temporairement cet invariant** (ex W6→W7 nominallement +8%, mais W6→W7-fatigué = −30% = −38 delta). **Patch** : considérer la semaine de fatigue comme une micro-cutback non-planifiée ; elle "interrompt" temporairement la progression linéaire mais ne casse pas le bloc car W4, W8, W12 structurels restent intacts.

- **Progression des sorties longues déstabilisée** : progression_logic point 3 liste 70→85→100→80→110→120→130→90→120→140→80→course. Réduire une sortie longue en semaine de fatigue (ex W7 J7 : 130→75 km) **sort de la progression nominale**. **Patch** : accepter la déviation comme temporaire. La sortie maxim de W10 (140 km) reste inchangée et elle est 115% de la cible 120 km—largement suffisante pour compenser la perte de 55 km en W7-fatigué.

- **Cutback W4, W8, W12 immobiles** : si fatigue survient pendant une cutback (ex W4 ou W8 affectée), appliquer −15% additionnel vs le cutback existant (ex W4 nominale 190 km → 155 km). Pas de paradoxe car cutbacks existent déjà pour récupérer.

- **Progression des intervalles (point 4) partiellement brisée** : si semaine de fatigue tombe en W6-W7 (pic Sweet Spot / seuil), la séance manquée rompt une montée progressive (2×15 → 3×12 → 3×15). **Patch** : considérer la semaine de fatigue comme un "push-back" de la progression. Exemple : W6-W7 nominale sont pic de Sweet Spot. Si W7 fatigué : reprendre la vraie W7 intensité en W9 post-cutback W8 (permutation acceptable car W9 commence bloc 3 = "reset" des objectifs).

## Contradictions

- **Safety_notes vs fatigue — surcharge neuromusculaire** : safety_notes énumère "Signes de surcharge" incluant "FC de repos matinale > 10 bpm au-dessus de la normale" et "Fatigue musculaire persistante > 72h". La condition p5-low-energy-week (grosse semaine boulot / sommeil dégradé) **remplit exactement ces drapeaux**. Appliquer une réduction 30-40% respecte la recommandation "réduire le volume 20-30% si 3 signes simultanés". Pas de contradiction ; la réduction proposée est **justifiée par safety_notes**.

- **Jamais doubler deux séances intenses (safety_notes)** vs rattrapage post-fatigue : la contrainte stipule "ne jamais doubler deux séances pour rattraper". Le patch proposé **ne rattrape pas** (W8 cutback inchangée, W9 nominale sans ajustement) ; il accepte la perte de 110 km sur 1200 km totaux (~9%). Pas de compensation, pas de double-séance. Conforme.

- **Volumes et zone FTP constantes** : réduire Z4-Z5 et maintenir Z2-Z3 en semaine de fatigue **n'invalide pas les zones FTP** (le FTP lui-même ne change pas en 1 semaine). Les pourcentages (76-90% pour Z3, 88-93% pour Sweet Spot) restent identiques ; seule la dose est réduite. Aucune contradiction.

- **Progression_logic point 5 (taper final W11-W12)** : inchangée. Si fatigue survient avant W11, elle compte comme récupération bonus. Si elle survient en W11-W12, appliquer le patch au-dessus de la taper nominale (ex W11 nominale 195 km → −30% → ~135 km, soit plus aggressif que la taper standard mais justifié). Pas de contradiction, mais synergique.