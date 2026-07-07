# Party — Refonte de l'icône app CoachingSage (2026-07-01)

**Sujet** : refondre l'icône (« trop remplie ») pour l'aligner sur la famille Sage
(TailorSage / FloreSage).

## Casting
- 🏃 **Manon** — utilisatrice cible multisport (lecture springboard)
- 🦁 **Léon** — voix de la marque (le coach de l'app)
- 🎨 **Iris** — Sage-Designer (système visuel famille, glyphe, lisibilité)
- 🧭 **Théo** — archi / brand-tech (pipeline asset, réversibilité, App Store)

## Problème (1 phrase)
L'app est multisport mais l'icône doit tenir en 1 signe sur un springboard à ~56 px ;
le pendule a déjà oscillé entre « un coureur » (biais mono-sport) et « les 6 sports »
(trop rempli). Vraie question : **quel signe unique dit "coaching sportif" sans mentir
sur le multisport ni surcharger.**

## Tour de table (résumé)
- **Manon** : le collage 6-emojis = tache illisible ; un signe simple se retrouve vite.
- **Léon** : le disque bleu marine = « l'univers de Léon » (`coachingPrimary`/`coachingLeon`
  = `#1E5090`) ; le multisport est le rôle de l'app, pas de l'icône.
- **Iris** : structure famille = **un objet** (bobine, feuille). Le glyphe Material `directions_run`
  est trop « panneau routier » ; à humaniser. Vert accent `#7BC142` à doser, pas dans le disque.
  Risque de collision springboard sur le bleu (générique).
- **Théo** : pipeline SVG → `rsvg-convert` → PNG, 3 variantes, **100 % réversible**, coût nul
  tant qu'on n'est pas sur l'App Store → c'est le moment de trancher.

## Exploration (maquettes /tmp, testées à 56 px)
Coureur Material (A) → coureur humanisé maison (B) ; alternatives progression ↗ (D),
chronomètre (E), cœur+pouls (F), flamme (C, écartée = collision Tinder) ;
idée Sophie « athlète + haltère + vélo + lunette + tapis » (G) → **bouillie à 56 px**,
= collage redessiné. Puis affinage traits fins et focus chronomètre (4 variantes).

## Tension centrale surfacée
« Montrer tous les sports » est un réflexe **récurrent** (c'est lui qui a produit le collage).
L'icône ne peut porter qu'**un** signe. Arbitrage : soit un sport-figure de proue, soit un
signe **non-sport** qui dit « coaching ».

## Décisions
1. **Glyphe = chronomètre** — l'objet universel du coach (10 sports), et un *objet* comme
   la bobine/feuille des sœurs (le plus « famille »). Écarte le biais mono-sport ET le « trop rempli ».
2. **Variante = « dynamique »** — cadran gradué (12/3/6/9) + aiguille **verte** `#7BC142`
   inclinée à ~1h (mouvement). Vert = accent marque.
3. **Cadre famille conservé** — fond crème `#F3EDE2`, anneau or `#D4A85A`, disque bleu marine
   `#1E5090`, boussole bas-droite.
4. **Idée « scène multisport » écartée** — illisible à taille réelle.
5. **Photo bureau non exploitée** — convergence sur le chrono avant de l'avoir reçue (inaccessible
   au terminal via ~/Desktop de toute façon). Piste rouvrable.

**Tension résiduelle (non bloquante)** : le bleu marine reste la couleur la plus générique d'un
springboard ; assumé car c'est la couleur de Léon.

## Implémenté (dans l'app, ce jour)
- Sources : `Resources/Brand/coachingsage-icon-{light,dark,tinted}.svg` (chronomètre dynamique)
- PNG 1024² : `Resources/Assets.xcassets/AppIcon.appiconset/AppIcon-{Light,Dark,Tinted}.png` (+ SVG copiés)
- 3 variantes vérifiées au screenshot. Générateur : `/tmp/iconlab/gen_final.py`.

## Prochaines actions
- [ ] Validation visuelle Sophie sur device (springboard réel) + build simu si souhaité.
- [ ] Merge main (à Sophie) ; commit à faire (CoachingSage seul, pas mélanger GS/TS).
- [ ] Nettoyer obsolètes : `gen-icon.py` mosaïque + `coachingsage-mosaic-source.png` + `_archive-coureur`.
