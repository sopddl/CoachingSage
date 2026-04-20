# Adaptability : running-avance-semi-marathon-12sem + p3-travel-minimal-gear

## Rigidity score
**7/10** (flexible sur les séances de course, rigide sur le renforcement préventif spécifique)

## Patch approach
Le template est adaptable pour une semaine de voyage car 75% du volume hebdomadaire repose sur la course à pied (sortie longue, endurance, VO2max, tempo). Les séances de running ne nécessitent aucun équipement. La rigidité vient du renforcement préventif obligatoire (W1 à W12) : nordic curl, single-leg squat, calf raises excentriques, clamshells élastiques — éléments de sécurité critiques pour ce profil avancé. Solution : remplacer via substitutions isométriques/pliométriques poids de corps et utiliser la bande élastique disponible.

## Concrete modifications

**Semaine concernée : toute semaine de voyage (supposée W5, W6, W7, W10 ou autre semaine intermédiaire)**

### Séances de course (AUCUNE MODIFICATION)
- **J1 endurance**, **J3 VO2max**, **J5 tempo**, **J7 sortie longue** : 100% conservés. Courir en zone sans surface préférée (route, sentier, parc) est acceptable — adapter juste l'allure si terrain très inégal (montagneux).

### Renforcement préventif (J7 cooldown)
**AVANT voyage :** Nordic curl → **Eccentric step-down isométrique** (descentes lentes sur bordure/escalier, unilatéral 4 sec par jambe, 3×8 répétitions par jambe). Absence de partenaire ou de barre d'appui : simulator avec le poids du corps sur bordure.

**AVANT voyage :** Single-leg squat → **Single-leg squat assisté à poids de corps** (tenir un poteau/branche/paroi pour l'équilibre, descente contrôlée vers chaise, 3×6 par jambe). Stimulus identique, zero matériel dédié.

**AVANT voyage :** Calf raises excentriques → **Montée bilatérale, descente unilatérale sans escalier** (utiliser un escalier de chambre d'hôtel ou pierre surélevée 15-20 cm, même stimulus. Si zéro dénivellation disponible : **calf raises au poids de corps alternés rapides** (30 reps, 3×30 sec, RPE 7) = stimulus métabolique de remplacement, moins excentrique mais acceptable court-terme).

**AVANT voyage :** Clamshells élastique → **Clamshells avec bande élastique** (✓ disponible dans le kit minimal). **0 modification**, utiliser directement.

**AVANT voyage :** Planche ventrale → **Planche ventrale** (✓ poids de corps). **0 modification**.

**AVANT voyage :** Bird-dog → **Bird-dog** (✓ poids de corps). **0 modification**.

### Synthèse des patchs concrets
- **J3 J5 J7 course** : courir sur le terrain local (route, parc, piste si disponible). Pas de changement d'allure cible.
- **J7 cooldown, nordic curl** : remplacer par eccentric step-down 3×8 par jambe sur bordure/escalier (4 sec par rep).
- **J7 cooldown, single-leg squat** : single-leg squat à poids de corps, main sur poteau/paroi pour équilibre, 3×6 par jambe.
- **J7 cooldown, calf raises excentriques** : calf raises alternés rapides 3×30 sec (si escalier indisponible) OU montée bilatérale/descente unilatérale sur pierre 15 cm (si escalier dispo).
- **J7 cooldown, clamshells + planche + bird-dog** : 0 modification, exécuter au poids de corps avec bande élastique pour les clamshells.

## Rigidity issues

- **Nordic curl critère de sécurité majeur** (safety_notes, ligne "tendinite ischio-jambière") : le template explique que "Les nordic curls du plan sont préventifs — ne pas les sauter." L'absence de partenaire ou barre rend le vrai nordic curl techniquement impossible. La substitution (eccentric step-down) n'est **pas bioméchaniquement identique** : le step-down sollicite moins l'excentrique ischio-jambier que le nordic (Mjolsnes 2004 cité dans safety_notes). Risque : si cette semaine appartient à W3-W7 (avant cutback W8), maintenir le déficit excentrique ischio pend 7+ jours peut augmenter la vulnérabilité tendinite lors du retour à la salle.
  
- **Calf raises excentriques** (protection tendon d'Achille, safety_notes "douleur derrière le talon") : remplacer par calf raises rapides poids de corps = perte de stimulus excentrique spécifique. Acceptable court-terme (< 7 jours), risqué si voyage > 1 semaine.

- **Single-leg squat** : substitution poids de corps avec appui-poteau est **fonctionnellement équivalente** en terme de stabilisation hanche + détection asymétries. Faible risque d'adaptation.

## Contradictions

- **Safety_notes vs renforcement préventif disponible** : la section "Renforcement préventif spécifique avancé" énumère 4 exercices obligatoires W1-W12, dont 2 (nordic curl, calf raises excentriques) reposent sur une excentrique renforcée absent en déplacement. Si la semaine de voyage coïncide avec W7 (pic VO2max 6×1000 m + tempo 35 min = charge neuromusculaire haute), réduire les stimuli préventifs excentriques crée un **déséquilibre : charge de travail intense + protection diminuée = surcharge ischio-tendineuse + Achille accrue**. 
  - **Mitigation** : si voyage tombe en W7-W9 (pics intensité), imposer un jour de repos supplémentaire la semaine précédente ou augmenter les clamshells élastiques de 15 à 20 reps pour compenser.

- **Pattern hebdo "RÈGLE DES 10% HEBDOMADAIRE"** (progression_logic) : si séance de renforcement est dégradée (nordic curl → step-down de moindre qualité), le **volume total de renforcement baisse de ~15-20%** (perte d'excentrique), ce qui ne violate pas la règle des 10% km (course intacte) mais **viole l'invariant implicite : le renforcement ne doit pas se dégrader d'une semaine à l'autre**. Après le voyage, le redémarrage du vrai nordic curl nécessite une semaine de ré-adaptation.

## Verdict final
**L'adaptation est viable pour 1 semaine de voyage situées en W1-W6 ou W10-W12 (avant/après pics intensité).** Pour une semaine en W7-W9, soit reporter la course si possible, soit accepter une augmentation de risque tendinite ischio-jambière et Achille en substitution des preventifs, à surveiller étroitement (3+ signaux fatigue neuromusculaire = cutback hebdo suivante). **Recommandation** : si voyage inévitable en W7-W9, ajouter 2×3 min "strides allure semi" en fin de J5 (tempo) pour compenser la perte d'excentrique par activation neuromusculaire alternative.