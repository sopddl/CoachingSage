# Adaptability : triathlon-avance-distance-m-16sem + p4-more-ambitious-goal

## Rigidity score
**4/10**

Le template est globalement **rigide** sur son architecture d'intensité (progression linéaire W1-W11, cutbacks W4/W8/W12 fixes, tapering W13-W16 immuable). Monter l'objectif exige de restructurer les zones d'effort et les volumes pic, ce qui casse plusieurs invariants du plan. La progression_logic elle-même (10% par semaine, règle des 4 blocs) devient incohérente si on vise une distance ou une performance significativement plus haute.

## Patch approach

L'objectif "plus ambitieux" interprété comme viser une **Distance L (Half-Ironman : 1.9 km natation + 90 km vélo + 21 km course)** sur les mêmes 16 semaines crée une **incompatibilité structurelle majeure** : les volumes pic et les intensités du template sont calibrés pour Distance M. Pour Distance L, il faudrait allonger les sorties longues de 40-60% (W11 passerait de 75 min vélo → 120 min ; W7 run de 70 min → 100+ min). Cela casse la règle des 10% par semaine et force une restructuration entière des blocs.

**Stratégie réaliste d'adaptation** : rehausser l'objectif **sur la même distance M (1500 m + 40 km + 10 km)** mais visant une **performance top-tier** :
- Nage : 26-28 min (vs 28-35 min prévu)
- Vélo : 1h00-1h10 (vs 1h05-1h20)
- Course : 45-52 min (vs 50-60 min)
- Temps total : ~2h30-2h50 (vs ~3h00-3h15 prévu)

Cela demande une **augmentation sélective des zones Z4/Z5** (seuil et VO2max) sans réduire la base aérobie Z2, et un **renforcement des densités d'intervalle** en W9-W11.

## Concrete modifications

- **W1-W4 (Base — inchangé)** : Les 4 premières semaines restent identiques. La base aérobie est non-négociable même pour l'objectif top-tier.

- **W5-W8 (Développement — intensification sélective)** :
  - **W5 J2** (Vélo) : augmenter les intervalles Z4 de 4×5 min à **5×6 min** (repos 3 min inchangé). Avancer légèrement le seuil vélo.
  - **W5 J3** (Course) : **3 blocs tempo seuil au lieu de 2** (2×10 min + 1×8 min). Introduction VO2max à **5×400 m au lieu de 4×400 m**.
  - **W6 J2** (Vélo) : **4×15 min Z3 au lieu de 3×15 min**. Augmente la durée totale Z3 de 45 min → 60 min.
  - **W6 J3** (Course) : VO2max passer de **3×600 m à 4×600 m**.
  - **W7-W8** : maintenir la progression mais augmenter de **+1 répétition par séance d'intervalle** (ex : W7 J2 devient **4×8 min Z4** au lieu de 4×8 min).

- **W9-W12 (Spécificité — densification VO2max)** :
  - **W9 J3** (Course) : **4×1000 m VO2max au lieu de 4×1000 m** (inchangé en nombre, mais augmenter la densité : réduire repos de 3 min à **2 min 30 sec** pour augmenter la contrainte lactique).
  - **W10 J3** (Course) : **4×1200 m VO2max au lieu de 4×1200 m** (idem, repos 2 min 30 sec au lieu de 3 min).
  - **W11 J3** (Course) : **5×1200 m VO2max au lieu de 4×1200 m** (ajout d'une répétition, repos 2 min 30 sec). **C'est la séance la plus dure du plan — elle doit casser les jambes en Z5 pur.**
  - **W11 J6** (Brick) : augmenter la portion Z3 vélo de 65 km total à **70 km** (65 → 70 min Z3). Run post-brick : **9 km au lieu de 8 km** à allure race-pace.
  - **W12** : brick passe de 40 km + 4 km à **45 km + 5 km**.

- **W13-W15 (Affûtage — maintien agressif de l'intensité)** :
  - **W13 J3** (Course) : **4×800 m VO2max au lieu de 3×800 m** (maintien plus fort du pic en affûtage).
  - **W14 J2** (Vélo) : **5×5 min Z4 au lieu de 4×5 min**.
  - **W14 J3** (Course) : **3×10 min seuil (au lieu de 2×10 min) + 3×600 m VO2max (au lieu de VO2max allégé)**. Affûtage agressif.
  - **W15 J2** (Vélo) : **4×6 min Z3 au lieu de 3×6 min**.

- **W16 (Race week)** : inchangé. La performance dépend de l'exécution des W1-W15, pas du jour J.

## Rigidity issues

- **Incompatibilité règle des 10%** : les modifications ci-dessus (ajouter des répétitions en W7-W12) créent des augmentations de volume > 10% sur certaines semaines. Exemple : W10 J3 passe de 4×1200 m à 4×1200 m (inchangé) mais repos réduit = volume maintenu mais intensité augmentée. Ce patch crée une **augmentation implicite de 5-8%** en tant que "densité" sans respecter formellement la progression linéaire.

- **Cutback weeks (W4, W8, W12) non reconditionnées** : la règle -15% reste applicable, mais elle s'applique maintenant sur des bases plus élevées de W1-W3, W5-W7, W9-W11. Les cutbacks absolus restent plus durs qu'à l'objectif original → risque accru de fatigue chronique sur W12.

- **Tapering W13-W15 agressif** : le template prescrit une réduction de -30% à W13, -50% à W14-W15. Avec l'objectif rehaussé, les valeurs absolues du tapering restent "molles" (ex : W14 à 80% du pic vs W13 à 70% du pic de l'original). Cela peut **sous-estimer le repos nécessaire** pour un athlète visé plus haut.

- **Progression_logic du template** énonce : "*jamais volume ET intensité la même semaine*". Or les modifications ajoutent intensité (densité, répétitions) ET volume certaines semaines (ex : W11). Cette **violation directe** du principe fondamental est problématique pour la prévention des blessures.

## Contradictions

- **SÉCURITÉ W11 tendinite ischio-jambiers** (safety_notes ligne "tendinite ischio-jambiers proximale") : la séance W11 J3 originale est **déjà aux limites** (4×1200 m Z5 + tempo 30 min). Ajouter une 5e répétition de 1200 m (W11 J3 modifiée : 5×1200 m) crée un risque **prohibitif** de tendinite proximale ischio en fin de bloc spécificité. Le drapeau rouge "arrêt des intervalles 1-2 semaines" ne peut pas s'appliquer à W11 (trop tard dans le plan). **Risque de blessure compétitive**.

- **CONTRADICTION progression_logic vs brick W11** : la progression_logic énonce "*jamais volume ET intensité la même semaine*". W11 original respecte cela : même volume vélo (110 km) qu'un bloc précédent mais intensité augmentée (Z3 longue). La modification W11 J6 (passer 65 km Z3 → 70 km Z3 = +8% volume) + modification J3 (5×1200 m au lieu de 4) = **augmentation simultanée volume ET intensité**. Cela **viole la règle fondamentale du plan**.

- **INCOMPATIBILITÉ affûtage W13-W15** : la progression_logic prescrit "*l'intensité est MAINTENUE (pas réduite) pendant l'affûtage*". Mais les volumes pic rehaussés de W11 (5×1200 m, 70 km Z3, run 9 km brick) créent un pic absolu PLUS HAUT. Pour appliquer un affûtage à -30%-50%, les séances W13-W15 deviendraient disproportionnément légères (ex : 3×1000 m VO2max serait < 75% de W11). Or la durée du plan (16 semaines) reste inchangée → **l'affûtage se contracte en 3 semaines pour un athlète visé plus haut**, ce qui risque de laisser trop peu de temps de récupération avant la course.

- **CONTRADICTION sécurité : 48h minimum discipline** (safety_notes). Les modifications W11 cumulent :
  - J1 natation CSS série (65 min)
  - **J2 vélo Z3 (95 min)**
  - J3 course VO2max (70 min) — 5×1200 m cumulé
  - **J6 brick (110 min vélo + 40 min run)**
  
  Entre J3 course et J6 brick, il y a ~72h. Mais si la course J3 laisse les jambes fatiguées (normal pour 5×1200 m Z5), les enchaîner avec un vélo intense J6 viole l'esprit de la règle 48h. Cela n'est pas formellement une contradiction mais un **borderline de sécurité**.

- **INCOMPATIBILITÉ volumes natation** : les modifications de course et vélo ne sont pas accompagnées de modifications natation. La natation pic reste 3600 m (W11), ce qui ne progresse pas avec l'objectif rehaussé. Pour viser 26-28 min sur 1500 m (vs 28-35 min), il faudrait augmenter le volume CSS ou la densité (réduire repos entre 200/300 m). Cela n'a pas été adressé → **natation pas assez poussée pour l'objectif course/vélo remonté**.

---

## Résumé : Adaptabilité faible pour rehaussement ambitieux

**Le template ne peut pas être patché simplement pour un objectif "plus ambitieux" sans casser sa structure fondamentale.** Les violations principales :

1. Règle des 10% non respectée en W7-W12 (modifications suggestives d'augmentations > 10%).
2. Principe "*jamais volume ET intensité la même semaine*" violé en W11.
3. Affûtage W13-W16 sous-dimensionné pour un athlète visé plus haut → repos insuffisant.
4. Risque tendinite ischio W11 rehaussée (drapeau rouge safety non gérable).

**Recommandation : changer de template.** Pour viser une **Distance L (Half-Ironman)** ou un **top-10% en Distance M** de façon sûre, il faudrait un **plan 18-20 semaines** avec :
- W1-W6 : base étendue et développement moins agressif.
- W7-W13 : spécificité longue (volumes vélo 120+ km, run 18+ km en sortie longue).
- W14-W18 : affûtage étendu (4-5 semaines) pour absorber le pic plus haut.

Avec 16 semaines et un rehaussement objectif, le plan devient **trop agressif pour rester safe**. Le choix est : *garder l'objectif original (3h00-3h15 Distance M) ou allonger le plan*.