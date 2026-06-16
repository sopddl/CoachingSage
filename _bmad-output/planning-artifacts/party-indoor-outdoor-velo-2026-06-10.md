# Party — Indoor/outdoor vélo + positionnement « walk découverte » (2026-06-10)

Facilitée avec Sophie. Personas joués (pas d'`.agent.yaml` dans le projet) : Maxime (user novice), Sally (UX), Archi (modèle/adaptateur), PM (scope).

## Problème (1 phrase)
L'app n'a aucune notion structurée de **lieu de pratique** : indoor/outdoor est noyé dans du texte libre incohérent (« Home-trainer 50 min » vs « 1h Z2 » sans lieu) → l'user ne sait pas où se passe une séance et ne peut pas basculer simplement quand sa réalité change (il pleut → je rentre).

## Cadrage user (clarif Sophie)
« Il veut faire du vélo, il pleut : pouvoir **modifier sa séance vers l'intérieur** et vice-versa. Clair **avant de commencer** (zéro ambiguïté) + **bascule simple**. » → l'EXPÉRIENCE doit être triviale (1 tap), même si le contenu derrière est juste.

## Décisions figées

**Scope V1 = VÉLO uniquement** (course/natation/rando = V2).

- **D1 — 2 vraies variantes de prescription** (PAS une note adaptative). Une séance porte une variante **indoor (home-trainer)** ET une variante **outdoor (route)** = contenus distincts (intervalles trainer propres vs vallonné/parcours). La bascule UX reste **1 tap**, mais swappe vers la vraie variante du lieu. *Raison Sophie : indoor et dehors ne sont pas le même entraînement ; on ne bricole pas une note, on donne la bonne séance.*
- **D2 — Question au lancement** du programme vélo : « Tu roules plutôt → 🏠 Home-trainer / 🛣️ Dehors / Les deux ». Pose le **défaut** de toutes les séances.
- **D3 — Puce lieu (🏠/🛣️) en tête de séance, visible AVANT Démarrer**, flippable en 1 tap. La **persistance retient le lieu choisi par séance** (override du défaut). Pas de surprise en cours de route.
- **D4 — « Les deux »** : chaque séance affiche sa **variante d'origine** (celle pour laquelle elle est le plus naturellement écrite) ; l'user flippe librement.
- **Coupé V1** : autres sports, historique « combien en indoor vs outdoor », stats par lieu. → V2.
- **Conséquence contenu** : les **noms de séance ne baquent plus le lieu** (« Home-trainer 50 min » → « Endurance 50 min ») ; le lieu vit dans la puce + la variante. À faire sur les **4 templates vélo**.

**walk découverte (« course/marche découverte » + rando découverte)** :
- **D5 — renommer ET remonter le niveau** (les DEUX). Le mot « découverte » infantilise (Maxime : « comme si je sortais du canapé depuis 10 ans ») ET le niveau vise trop bas (trop de marche). Concerne `running-beginner-5k-8sem` + `hiking-beginner-decouverte-8sem`. Traité dans la passe contenu mais **avec revue de niveau**, pas qu'un rename.

## Design technique FIGÉ (session design 2026-06-10)
`TemplateModel`/`Templates` = **CoachingSage-LOCAL** (vérifié, pas partagé GS/TS → faible risque ; ma note initiale « partagé » était fausse). Choix de schéma = **invisible pour l'user** (même toggle dans tous les cas), enjeu purement interne (risque/effort/évolutivité).
1. **Schéma = OPTION B `variants: {indoor, outdoor}`** (Sophie) — symétrique, extensible à N variantes/sports (elle se projette vers d'autres sports/contextes). Rétro-compatible : `variants` optionnel, absent = séance mono (39 templates non-vélo intacts), contenu racine = défaut. `SessionVariantContent` = prescription complète par lieu (name/durée/warmup/exos/cooldown, peut différer). Cf design détaillé dans la mémoire [[v2_chantier_indoor_outdoor_velo]].
2. **Adaptateur + persistance** : l'algo doit porter le lieu choisi par séance (mirroir léger type `exerciseWeights`/`exerciseLevels`), préservé au renouvellement de cycle.
3. **Coût contenu réel** : écrire la 2ᵉ variante manquante (indoor sur séances outdoor et inversement) sur les 4 templates vélo = vrai travail rédactionnel, à faire APRÈS les passes contenu #2/#3 (sinon double édition).

## Prochaines actions
1. **Étape design modèle 2-variantes** (tension #1) avant tout code — schéma rétro-compatible.
2. Implem SOPDDL V1 vélo (question lancement + puce + persistance lieu + 2 variantes) après le design.
3. walk découverte (D5) → intégré à la passe contenu (rename + niveau).
4. Indépendant : passes contenu #2 (noms FR) / #3 (vulgariser) / #1bis (sensation dans texte) déjà tranchées (cf [[passe_qualite_10_sports_2026_06_08]]).
