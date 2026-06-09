# Chantier — Refonte des dessins de musculation (FOCUS)

**Date d'ouverture** : 2026-06-06 (décision Sophie après POC taille + comité Sally/Maxime)
**Statut** : DRAFT à scoper (pas démarré).
**Origine** : POC agrandissement des dessins muscu → en les grossissant, le comité (Sally designer + Maxime user) a relevé un **P0 unanime** : les dessins eux-mêmes sont faibles. « Faire mieux » = refaire les dessins, pas juste les agrandir.

## Problème (P0 comité)
- **Dessin ≠ mouvement nommé** : « Goblet squat » affiche une silhouette tenant une **barre sur les épaules** (squat barre/overhead), pas un haltère/kettlebell devant la poitrine (goblet). Induit en erreur un débutant (« je prends la barre ou l'haltère ? »).
- **Geste-clé invisible** : sur le storyboard 3-frames, la **descente du squat ne progresse pas** (frame 2 ≈ frame 1). On ne lit pas prépa → descente → remontée.
- **Cause racine** : **1 seul dessin générique par *pattern*** (`.squat` → `SquatIllustration` barre), réutilisé pour TOUTES les variantes (goblet, front, gobelet…). Cf `ExercisePatternResolver` → pattern ombrelle. Le dessin ne peut pas être juste pour chaque variante.

## Pistes (à arbitrer au scoping)
1. **Dessins par mouvement, geste-clé lisible** : refaire chaque storyboard pour que la phase clé soit nette (descente squat, charnière hinge, tirage…), méthode validée yoga **Story 3.23** (liste exhaustive + sources web + structure agent + 2 passes review novice/expert + max 2 itérations).
2. **Granularité variante** : soit un dessin par variante d'équipement (goblet KB/DB devant vs barre dos vs front), soit neutraliser l'équipement (silhouette + mouvement, sans barre trompeuse) quand la variante n'est pas garantie. Décision produit ouverte.
3. **Cohérence avec le POC taille** : les dessins seront affichés plus grands (boîte au ratio) → la qualité du trait/mouvement compte davantage.

## Inventaire concerné
~20 illustrations triplet strength (cf `Views/Components/Illustrations/` : Squat, Hinge, PullVertical/Horizontal, PushVertical/Horizontal, Lunge, Plyo, HipThrust, CalfRaise, YTW, Pallof, Nordic, DeadBug, Clamshell, KBSwing, FacePull, BicepsCurl, Triceps, LateralRaises). Prioriser les plus fréquents (squat, hinge, push, pull, hipThrust, calfRaise).
+ **Burpee (Plyo)** incomplet (P1 Sally) : manque la phase sol/planche/pompe → on lit « petit saut » pas « burpee ».

## Lien
- POC taille livré séparément (boîte au ratio + agrandissement ~1,6× via scaleEffect dans `tripletStrip`) — cf commit POC muscu.
- Méthode de référence : [[epic3_story323_catalogue_complet_done]] (refonte dessins yoga).
- Dosage muscu (charge + compteur de reps vs chrono) = [[chantier-focus-dosage-cameleon-2026-06-06]] (Maxime l'a re-remonté).

## NEXT
Scoper la story (granularité variante = décision produit), puis SOPDDL avec la méthode Story 3.23 (agent expert + 2 passes review + validation simu).
