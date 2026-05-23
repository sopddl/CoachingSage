# Brief Claude Design — Illustrations exercices CoachingSage Story 3.19

## Contexte produit

**App** : CoachingSage (iOS, SwiftUI, iOS 17+) — app de coaching multi-sport (running, strength, swimming, cycling, yoga, etc.). Affiche des programmes adaptés algo-deterministic et des séances détaillées.

**Story 3.19 — Phase 3 didactique** : refonte de la vue Détail d'une séance pour rendre la pratique compréhensible sans coach IRL. Sophie a dit explicitement « perso je suis incapable de faire la séance sans quelqu'un qui m'explique » au test simu.

**Élément concerné** : strip d'illustrations multi-frames de l'exercice, affiché en haut de chaque card exo dans la timeline verticale de la séance. Sous le nom de l'exo, avant les notes et les chips métriques (sets, reps, repos).

## Maquette HTML validée (référence visuelle)

Voir `_bmad-output/planning-artifacts/ux-design-CoachingSage-phase3-illustrations-exos-2026-05-22.html` (style monogram custom SVG multi-frames).

**Caractéristiques validées par Sophie 2026-05-22** :
- Picto monogram custom SVG (silhouette stylisée + équipement + flèches mouvement)
- **2-3 frames** pour gestes dynamiques (storyboard storyboarded mouvement), **1 frame statique avec annotations** pour exos isométriques (plank, hold, etc.)
- Strip horizontal compact : `[frame0] → [frame1] → [frame2]` (flèches mouvement entre frames)
- Style sobre, ligne claire, reconnaissable d'un coup d'œil à 48pt

## Spec technique stricte

### Format de sortie attendu

**Préférence #1 — SwiftUI `Canvas`** :

```swift
import SwiftUI

struct SquatIllustration: View {
    let sportCode: String
    let frame: Int  // 0, 1, 2

    var body: some View {
        Canvas { ctx, size in
            let s = size.width / 48  // viewbox 48×48 dynamiques
            // ... dessine avec ctx.stroke / ctx.fill / Path
        }
        .frame(width: 48, height: 48)
    }
}
```

**Préférence #2 — SVG inline** (que je convertirai ensuite en SwiftUI Path) :

```xml
<svg viewBox="0 0 48 48" xmlns="http://www.w3.org/2000/svg">
  <!-- ... -->
</svg>
```

### ViewBox

- **Dynamiques (3 frames)** : 48 × 48 points chacune.
- **Statiques (1 frame + annotations à droite)** : 80 × 48 points.

### Palette OBLIGATOIRE (tokens design existants, ne PAS inventer de couleurs)

Variables (à utiliser textuellement dans le code Swift) :

| Élément | Token Swift | Hex (référence) |
|---|---|---|
| Silhouette / corps | `Color.coachingSport(forCode: sportCode)` | dynamique selon sport — strength = `#8C4A2E` brun rouille ; running = `#1E5090` bleu ; swim = `#4FB3D9` cyan ; cycle = `#2D8A4E` vert ; hiit = `#C43D3D` rouge |
| Barre / équipement fixe (barre squat, barre traction) | `Color.coachingEarth` | `#1B3A5C` bleu marine |
| Charges / haltères (disques, haltères) | `Color.coachingRecord` | `#D4A85A` or |
| Flèches mouvement (entre frames, ou indication direction) | `Color.coachingWarning` | `#E08A3A` orange |
| Sol pointillé / lignes alignement (plank) | `Color.coachingTextSecondary.opacity(0.5)` | `#5A6577` gris à 50% |

### Stroke widths (à scaler par `s = size.width / viewbox.width`)

```swift
let strokeStandard = 2.5 * s       // silhouette + équipement
let strokeHeavy = 4.0 * s          // charges / haltères (poids visuel)
let strokeThin = 1.5 * s           // annotations isométriques + flèches mouvement
```

`StrokeStyle(lineWidth: ..., lineCap: .round, lineJoin: .round)` partout pour cohérence.

### Anatomie typique (référence)

Échelle 48×48 pour un humain debout face caméra ou de profil :
- Tête (cercle) : diamètre ~6pt, centre vertical ~12pt en haut
- Tronc (ligne) : tête bottom → hanche ~12pt de long
- Hanche → genou : ~10pt
- Genou → cheville : ~10pt
- Bras : épaule → main ~12pt

Sol au bottom à y=44-46 (ligne pointillée 2-2pt gap).

## 4 exos à dessiner pour le test (mêmes que mes essais)

J'ai déjà dessiné une V1 de chaque. Sophie veut comparer ta production à la mienne pour voir si tu fais mieux sur l'esthétique / la lisibilité. **Tu pars de zéro, tu n'as pas besoin de regarder ma version.**

### 1. SquatIllustration (3 frames)

**Geste** : squat poids du corps OU avec barre sur épaules.
**Frame 0** : silhouette debout, barre olympique sur les épaules (trapèzes), disques (2 de chaque côté de la barre).
**Frame 1** : mi-squat (descente à 90° hanche).
**Frame 2** : squat profond (cuisses parallèles au sol).
**Caractéristiques clés à montrer** :
- Barre reste horizontale tout le mouvement (sur les trapèzes, ne descend pas devant)
- Descente verticale du bassin, dos qui s'incline légèrement vers l'avant
- Genoux dans l'axe des pieds, pas en valgus

### 2. HingeIllustration — Romanian Deadlift haltères (3 frames)

**Geste** : Romanian Deadlift avec 2 haltères (1 dans chaque main).
**Frame 0** : debout, haltères pendants le long des cuisses.
**Frame 1** : tronc penché à 45°, haltères glissent le long des cuisses.
**Frame 2** : tronc penché ~80° (presque horizontal), haltères au niveau des genoux/tibias.
**Caractéristiques clés** :
- Le mouvement vient de la HANCHE (bassin recule), pas du dos (dos reste droit)
- Genoux quasi tendus (léger fléchissement)
- Haltères glissent verticalement le long des jambes
- Tête suit l'angle du tronc (nuque alignée)

### 3. PullVerticalIllustration — Pull-up / chin-up (3 frames)

**Geste** : pull-up (traction) à la barre fixe.
**Frame 0** : suspendu bras tendus, corps allongé pendant.
**Frame 1** : mi-traction, coudes pliés à ~90°.
**Frame 2** : menton au-dessus de la barre, coudes très fléchis collés au corps.
**Caractéristiques clés** :
- Barre fixe horizontale en haut de la frame
- 2 mains qui agrippent la barre (poings)
- Corps remonte verticalement, jambes pendantes (légèrement fléchies)
- Épaules engagées (scapula serrées) en haut

### 4. CoreIllustration — Plank (2 variantes : frontal + latéral)

**4a. Frontal (plank classique)** — 1 frame statique 80×48 :
- Vue de PROFIL (lecteur regarde le côté du corps)
- Silhouette horizontale en planche : tête à droite, pieds à gauche
- 2 avant-bras d'appui sous les épaules (perpendiculaires au sol)
- Pointes de pieds au sol (côté gauche)
- Ligne d'alignement pointillée orange épaules-bassin-talons (au-dessus du corps)
- Sol pointillé en bas

**4b. Latéral (side plank)** — 1 frame statique 80×48 :
- Vue de FACE (lecteur regarde de profil le corps couché sur le côté)
- Corps en diagonale : tête en haut-droite, pieds empilés en bas-gauche
- **UN SEUL avant-bras d'appui** (côté gauche, descendant vers le sol)
- **Bras libre opposé tendu vers le HAUT** (signature visuelle du side plank)
- Pieds empilés (un seul visible de côté)
- Ligne d'alignement pointillée orange tête-bassin-pieds (en diagonale)
- Sol pointillé en bas

## Critères qualité (Sophie comparera)

1. **Reconnaissable immédiatement** à 48pt sans légende. Un débutant doit comprendre quel exo c'est en 1-2 secondes.
2. **Anatomie correcte** : pas de proportions absurdes (tête énorme, jambes minuscules).
3. **Différenciation frames** : entre frame 0 et frame 2 le changement de position doit être très visible (pas seulement 5° de différence).
4. **Cohérence stylistique** entre les 4 illus (mêmes stroke widths, même style silhouette).
5. **Palette respectée** : silhouette = couleur sport, équipement = bleu marine, charges = or, flèches = orange. Pas de couleur en dehors de la palette.
6. **Pas de surcharge** : si tu hésites entre ajouter un détail ou pas, n'ajoute pas. Le picto doit rester sobre.

## Out of scope

- Pas d'animation continue (juste des frames statiques discrètes).
- Pas de texte/label dans le picto.
- Pas de couleurs en dehors de la palette listée.
- Pas de fond / background dans le SVG (la card parent fournit le fond `tertiarySystemBackground`).

## Livrable attendu

Pour chacune des 5 illustrations (Squat × 3 frames, Hinge × 3 frames, PullVertical × 3 frames, Core frontal × 1, Core latéral × 1) :

- Code SwiftUI `Canvas`-based OU SVG inline 48×48 / 80×48.
- Un commentaire `//` rapide expliquant le choix de pose si non-évident.

Si tu fournis du SVG, je le convertirai en SwiftUI `Path` côté CoachingSage. Si tu fournis du SwiftUI direct, mieux encore.

**Bonus apprécié** : preview SwiftUI à la fin du fichier (`#Preview`) qui affiche les 3 frames en HStack pour validation visuelle directe.

---

**Question retour à Sophie après livraison** : « Voici 5 illustrations test. Tu compares au strip déjà visible dans le simu CoachingSage et tu me dis : version A (Claude Code) ou version B (Claude Design) ? »
