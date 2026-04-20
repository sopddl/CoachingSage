# Adaptability : musculation-debutant-home-basics-8sem + p5-low-energy-week

## Rigidity score
**7/10**

Le template se laisse adapter avec clarté grâce à sa structure explicite (progression_logic, safety_notes, volumes chiffrés) et ses règles de gestion des séances manquées. Cependant, la semaine de cutback W5 est déclarée « NON NÉGOCIABLE » dans safety_notes, et certaines transitions de progression (double progression entre semaines) risquent de créer des micro-contradictions si l'adaptation n'est pas appliquée symétriquement.

## Patch approach

Réduire la semaine courante (peu importe laquelle) en appliquant le modèle W5 cutback : volume -15%, RPE cible 5-6, tempo contrôlé, zéro tentative de PR. Adapter les séances à la semaine suivante en DOUBLANT le repos avant de relancer la progression (sauter 3-4 jours supplémentaires si possible). Cette approche réutilise le cadre cutback existant plutôt que d'inventer une nouvelle logique.

## Concrete modifications

**Semaine courante (N) — Application cutback modèle W5** :
- **J1 composés (squat/hinge/row/press/pull)** : réduire charges de 15-20% vs semaine précédente. Reps cibles = bas de fourchette (ex : si habitude 3x10, faire 3x8).
- **J3 mobilité active** : remplacer J3 force par une séance mobilité (modèle J3 W5) si énergie très basse. Sinon force réduite (3 séries seulement vs 4).
- **J5 révision technique** : maintenir 3 séries légères (charges -20%), focuser sur mécanique parfaite et RPE 5-6.
- **Core en fin de séance** : réduire volume (2 séries vs 3, durée -25%) mais garder présence obligatoire (règle : core en fin JAMAIS en début, même en fatigue).
- **Repos inter-séries** : garder les 90-120 sec prévus (ne pas réduire = prévention tendinite sur poignets/épaules fatiguées).

**Semaine suivante (N+1) — Re-progression sécurisée** :
- **J1** : retour charges W(N-1), mais 1 série de moins vs normal (ex : si habitude 4x8 squat, faire 3x8). RPE cible 6-7 (pas 7-8 d'emblée).
- **J3-J5** : montée progressive : tu regagnes la 4ème série d'ici J5 si RPE < 6.5.
- **Semaine N+2** : retour 100% du volume planifié si énergie revenue. Sinon prolonger le schéma N+1 une semaine supplémentaire.

## Rigidity issues

- **Cutback W5 non-négociable vs. besoin réel d'allègement hors-semaine** : safety_notes déclare W5 « NON NÉGOCIABLE » pour supercompensation. Adapter une semaine quelconque avec logique cutback crée un décalage : si on applique cutback à W3 (par exemple), le corps n'a pas eu les 2 semaines de vol d'accumulation nécessaires. Risque : la « supercompensation » attendue en W5 se produit pas car la charge cumulée est déjà cassée. *Mitigation* : traiter l'allègement comme une semaine ad-hoc SANS l'appeler cutback officiellement. C'est une « semaine de récupération tactique » distincte de W5. Prolonger W5 et W6 d'une journée si nécessaire pour rattraper le cycle.

- **Double progression bloquée mid-semaine** : si la semaine courante est W3/W4 (progression charge), une réduction de volume et intensité peut empêcher d'atteindre la cible « 3x12 avant charge supérieure ». Exemple : W3 J1 prévu = Goblet Squat 4x8 chargé. Adaptation allège à 3x8 légère → on ne progresse pas vers le haut de fourchette. *Résultat* : W4 doit compenser en relançant les 4 séries, mais tu restes à la même charge. Progression globale retardée d'une semaine. *Acceptable si* la fréquence d'apprentissage 3x/semaine est maintenue (ce qui est le cas).

- **Core « toujours en fin » vs. fatigue générale** : safety_notes insiste : core en FIN obligatoire pour la stabilité lombaire. Une semaine très fatiguée pourrait tenter de « passer le core pour gagner du temps ». Le template ne laisse aucune flexibilité ici. *Réalité* : skippa le core est dangereux (lumbar instability sur les composés). L'adapter = réduire volume/durée, pas éliminer. Template résiste correctement ici.

## Contradictions

- **RPE cible vs. energy state** : safety_notes fixe RPE par semaine (W1-2 = RPE 5-6, W3-4 = RPE 7, W6-7 = RPE 7-8). Une adaptation « baisse d'énergie » demande RPE 5-6 peu importe la semaine. *Contradiction* : si on baisse à RPE 5-6 en W7 (prévu RPE 7-8), on viole la progression_logic d'intensification. *Résolution* : traiter comme une semaine « hors-cycle », non-comptée dans la progression linéaire. Prolonger le cycle d'1 semaine à droite si nécessaire (W8 bilan repoussé).

- **Safety_notes : signes de surcharge (courbatures > 72h, dégradation perf, sommeil) → réduire volume 30% OU prendre 2 jours repos** : l'adaptation proposée (cutback -15%, pas -30%) contredit légèrement cette règle. *Clarification* : la fatigue/stress (profil p5) est une prévention = cutback anticipé avant surcharge. Si surcharge est DÉCLARÉ (3+ signes observés), appliquer -30% et +2 jours repos en plus.

- **Repos composés 120 sec vs. fatigue** : adaptation propose garder 90-120 sec. Avec fatigue élevée, réduire le tempo de travail mais garder repos long = conforme (fatigue neuro ≠ accumulation acide lactique). *Pas de contradiction*.

- **« Ne pas retenir respiration » + fatigue** : avec fatigue, ventilation devient laborieuse. Template dit « expirer sur effort » — c'est correct même fatigué. Pas de contradiction.

## Résumé patch appliqué

Si la semaine courante est **W4 (ou N quelconque)** et profil fatigue activé :

```
W4 adapté (low-energy) :
  J1 : Goblet Squat 3x8 @ -20% charge vs W4, RPE 5-6
       Romanian Deadlift 3x8 @ -20%, RPE 5-6
       Pompes 3x8, RPE 5-6
       Row 3x8/côté, RPE 5-6
       Pullover 3x10, RPE 5
       Planche 2x30 sec
  
  J3 : Mobilité active (modèle W5 J3) OU séance force ultra-réduite (Fentes 2x6, Hip Thrust 2x10, Press 2x8, Row 2x8, Y-raise 2x12)
  
  J5 : Goblet Squat 3x8 @ -20%, Hinge 3x8 @ -20%, Pompes 3x8, Row 3x8/côté, Pullover 3x10, Planche 2x35 sec
  
  → Semaine N+1 : retour charges W4 originale, 3 séries seulement jusqu'à J5 si énergie < 6/10. 
  → W(N+2) : retour 100% du cycle si vert light.
```

**Aucune autre contradiction identifiée.**