# Essai Claude Design — dessins yoga (2026-07-07)

## Cadre de l'essai
**Test scopé, pas un changement de pipeline.** On vérifie si prototyper en HTML/SVG via
Claude Design (claude.ai/design) va plus vite / plus loin que l'itération directe en
Swift pour corriger un dessin cassé. Si oui → on adopte pour les cas difficiles. Si non
(ou traduction Swift trop coûteuse) → on repart sur le pattern habituel (référence web +
itération directe du code + galerie HTML + revue 2 personas + œil Sophie), qui a déjà
fait ses preuves (bird-dog, side plank, panel bakasana/karnapidasana).

Le code prod (`YogaIllustration.swift`) n'est **pas touché** pendant l'essai — seulement
en sortie, si le résultat convainc.

## Cibles : les 2 dessins au défaut identifié (revue 2026-06-17)
Les seuls dessins avec un **bug de lecture confirmé** (pas une question de goût) :

- **Dhanurasana (l'arc)** — se lit comme une jambe levée allongée. Devrait se lire comme
  un arc : ventre au sol, mains qui attrapent les chevilles, buste ET cuisses relevés en
  cambrure.
- **Phalakasana (la planche)** — se lit comme un V / un chien tête en bas. Devrait se lire
  comme une ligne droite gainée épaules-talons.

## Contraintes techniques à respecter (pour rester traduisible en Swift)
- **Viewbox 80×48** (système yoga, `YogaIllustration`), coordonnées `p(x, y)`.
- **Style fil-de-fer minimaliste** : tête = cercle (`yHead`), membres = segments droits
  (`yLimb`), tronc/dos = courbe (`yCurve`). Pas de remplissage, pas de détails anatomiques.
- **Trait fin** : ces 2 poses sont déjà dans le set `compactPoses` (stroke × 0.7) — corps
  replié/compact, éviter la fusion en aplat.
- Référence de départ = les coordonnées actuelles (cassées), pour ancrer les proportions :

```swift
// Dhanurasana (actuel, cassé)
yLimb([p(30,44), p(42,44)])                    // ventre au sol
yCurve(p(34,44), p(25,37), p(28,40))            // buste relevé
yHead(p(21,35))
yCurve(p(42,44), p(52,31), p(51,40))            // cuisse → tibia relevés
yLimb([p(26,38), p(51,31)])                     // bras tendu (corde de l'arc)

// Phalakasana (actuel, cassé)
yLimb([p(20,46), p(20,33)])                     // bras tendu vertical
yLimb([p(20,33), p(60,44)])                     // corps gainé épaule→talons
yHead(p(16,32))
yLimb([p(58,44), p(62,46)])                     // pied
```

## Ce que je fais dans l'essai
1. Créer/utiliser un projet Claude Design (`DesignSync`), un fichier HTML/SVG par pose,
   viewbox 80×48, même style trait fin/silhouette que ci-dessus.
2. Chercher des références visuelles (photos/pictos pro) pour les 2 poses avant de dessiner
   — même méthode que le pattern Swift habituel.
3. Itérer dans le pane Design (rendu instantané, pas de recompilation Xcode) jusqu'à ce que
   la silhouette se lise correctement à l'œil nu (arc reconnaissable / planche droite).
4. Te montrer le résultat (rendu + comparaison avant/après) pour validation visuelle.

## Critère de succès de l'essai
- La pose se lit juste **à l'œil, sans légende** (toi ou un œil neuf).
- Les points clés de la silhouette sont **transcriptibles à la main** en appels
  `yLimb`/`yCurve`/`yHead` sans reprendre le style (pas de nouvelle primitive de dessin
  à créer côté Swift).
- Bonus si c'est **plus rapide** que l'itération Swift directe (pas de rebuild/snapshot à
  chaque essai).

## Après l'essai
Si concluant : je traduis les coordonnées en Swift, je passe par le pipeline habituel de
validation (re-record snapshot, galerie HTML OK/KO, revue avant merge) — Claude Design
sert de brouillon plus rapide, pas de raccourci sur la validation.
