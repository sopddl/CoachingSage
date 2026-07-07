# Party — Modèle d'illustration des exercices par sport

**Date** : 2026-06-08 · **Lead** : Sally (UX Expert) · **Déclencheur** : Sophie « pourquoi des dessins de muscu dans foot/tennis/hiking/tennis/triathlon ? ça me semble stupide ».

## Casting
- 🎨 **Sally** — UX Expert (lead) : quand un dessin aide vs décore, valeur perçue.
- ⚽ **Tarek** — foot loisir (terrain).
- 🎾 **Léa** — tennis loisir (terrain).
- 🥾 **Marc** — randonneur (terrain).
- 🏊 **Sophie-tri** — triathlète (persona PRD).
- 🏗️ **Karim** — architecte tech (coût Canvas Swift, réversibilité).
- 📋 **Hugo** — PM (scope V1/V2, app pas publiée).

**Matos** : `ExercisePatternIllustration.swift` + `ExercisePatternResolver.swift` + `ExercisePattern.swift` lus ; dump mapping 6 sports `dump-mapping-figures-tous-sports-2026-06-08.txt` + `/tmp/per_sport_matchkeys.json` ; party yoga 06-05 ; PRD personas.

## Problème (recadré pendant la party)
Faux problème : « ces 5 sports n'ont pas de figures ». **Vrai problème** : chaque programme a **2 natures de contenu** —
- **① renfo / prépa / prévention** (Nordic curl, Pallof, planche, RDL, calf…) → rend une figure muscu = **CORRECT** (même geste = même dessin ; ce sont de vrais exos prescrits, ex. FIFA 11+). **Pas stupide.**
- **② geste signature du sport** (frappe, dribble, service, grip, marche/dénivelé, transition tri) → tombe sur l'**icône générique muette** = le seul vrai trou.

Question reformulée : *pour chaque sport, le geste signature mérite-t-il un visuel V1, V2, ou rien ?*

## Tour de table — saillants
- **Tarek (foot)** : 80% du contenu = jeu/tactique (`5v5`, `Toro 5v2`, `conduite slalom`) = **non-dessinable** (mise en place, pas geste). Technique (passe/frappe) → vidéo > dessin figé.
- **Léa (tennis)** : `grip eastern`, `split-step`, `footwork` = **le seul cas où le statique est didactique** (un grip se dessine, le texte ne suffit pas). Mais = **nouveau système** (diagramme main+manche, pas strip mouvement).
- **Marc (hiking)** : geste = marcher/dénivelé/sac = **universel** (icône OK) ; le ① (mollets, step-up, équilibre) **déjà couvert** par la biblio.
- **Sophie-tri** : pédaler/courir/nager = jamais eu besoin de dessin. Mais **transition T1/T2 / brick / sighting** (87 séances) = la vraie compétence tri à apprendre → mériterait un visuel, mais d'une **autre nature** (concept card 1×, pas figure par exo).
- **Sally** : HIIT n'a **pas** de geste signature (HIIT = circuit de patterns) ; mais révèle **3 patterns poids-du-corps manquants** à la biblio (`mountain climber`, `jumping/step-jack`, `high knees`) = trou de ①, pas d'identité.
- **Karim** : meilleur ratio = combler les patterns manquants (même système 3-frames, réutilisés multi-sports). Grips tennis + tactique foot + transition tri = chacun une **nouvelle nature** de dessin = coût + risque « dessin qui ne sert pas ».
- **Hugo** : app pas publiée, EU MDR (légal) + zones (P0) devant. Valeur perçue ≠ blocage.

## Tensions
1. **« Manque de figure » ≠ « manque d'identité »** : une partie du trou = juste 3 patterns poids-du-corps manquants (à combler quel que soit le débat).
2. **Tennis = seul vrai cas dessin statique didactique** mais ouvre un nouveau système (sport vitrine vs coût).
3. **Foot & hiking : le bon média = vidéo ou rien**, pas le dessin figé.

## Décisions (tranchées par Sophie)
| # | Sujet | Décision | Échéance |
|---|---|---|---|
| **D-MODÈLE** | Réutilisation biblio muscu pour le ① renfo | **Validée — pas stupide** : même geste = même dessin (les exos de prépa sont réels) | acquis |
| **D-TRI** | Triathlon transition/brick/sighting | Concept cards (pas figures par exo). Décision « geste continu = 0 figure » 2026-05-23 **maintenue** | **V2** |
| **D-TENNIS** | Tennis grips/split-step/footwork | Nouveau système diagramme statique | **V2** |
| **D-FOOT** | Foot tactique + technique | Vidéo > dessin figé | **V2/jamais** |
| **D-HIKING** | Hiking marche/dénivelé | Icône suffit, renfo déjà couvert | **jamais** |
| **D-V1** | Trous de la **bibliothèque partagée** (le ①) | **Combler en V1 MAINTENANT** (avant EU MDR/zones) : ~5 muscu (cable fly, leg extension, leg curl, reverse hyper, +?) + 3 poids-du-corps HIIT (mountain climber, jumping/step-jack, high knees). **Même système 3-frames**, 0 nouveau système. | **V1 now** |
| **D-YOGA** | Longue traîne yoga (12% sur fallback orientation) | Sur 51 : 22 = méditation/souffle (silhouette assise OK, rien à faire) ; **~17 asanas avancées réelles** (Bakasana, Dhanurasana, Kapotasana, Ustrasana, Ardha Matsyendrasana, Bhujapidasana, Phalakasana, Prasarita, Padahastasana, Purvottanasana, Garbha/Karnapidasana…) → **à dessiner en V1** avec les 8 autres (même système YogaIllustration). Yoga = déjà 46 poses bespoke, plus couvert que muscu. | **V1 now** |

## Conséquence clé
Une fois le geste-spécifique sorti en V2, le travail V1 n'est **plus « illustrer les sports »** mais **finir la bibliothèque partagée** (sert les 10 sports). Périmètre fermé et à coût maîtrisé.

## Prochaines actions
1. **Extraction empirique 10 sports** : confirmer la liste EXACTE des trous (`generic` only) à partir des templates bundlés `Templates/Sources/TemplateLoader/Resources/Templates/` + resolver répliqué. → fige le « +? ».
2. **Branche dédiée** dessins V1.
3. Créer les figures manquantes (même système `ExercisePatternIllustration` 3-frames) + brancher le resolver (keywords) + revue 2-persona (Sally + novice) sur RenderPreview (pas ui-reviewer, cf feedback Sophie).
4. Reprendre **EU MDR → zones** ensuite.

## Backlog V2 (issu de la party)
- Triathlon : concept cards transition T1/T2 + brick + sighting.
- Tennis : système diagramme grips (4-5) + split-step + footwork (court + flèches).
- Foot (si un jour) : vidéo/animation pour fondamentaux techniques.
- Question de fond ouverte : média vidéo/animation pour les gestes continus ? (sinon « icône + texte » assumé).
