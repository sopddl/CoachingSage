# Adaptability : natation-avance-technique-8sem + p2-short-sessions

## Rigidity score
**3/10**

## Patch approach
Le template est TRÈS rigide sur le volume et les durées de séance. Les 60-75 min actuelles sont incompressibles dans la logique du plan car :
1. La progression de 2000→2800 m suppose des séances longues (40-50 min de nage utile)
2. Les drills multiples (4-6 séries par séance) exigent du temps transitions+repos
3. L'introduction séquentielle de 3 nages sur 8 semaines se déploie sur la durée

Adapter à 30 min max exige de **sacrifier soit le volume, soit la variété des drills, soit la fréquence des séances**. Une compression naïve (même nage, même drills, mais plus court) *casse* la progression théorisée dans `progression_logic` (règle des 10-15% hebdo). Il faut passer à **4 séances/semaine à 30 min** ou **3 séances/semaine à 35-40 min si negotiable**.

## Concrete modifications

**Si strictement 30 min max, 3 séances/semaine :**

- **W1-W2 : réduire à 1 drill ciblé par séance au lieu de 3-4**
  - W1 J1 : garder streamline 4×25m + comptage bilan sur 4×50m crawl (drill d'équilibre uniquement). Supprimer 6-3-6 et poisson. Nager ~1200-1400 m au lieu de 2000 m.
  - W1 J3 : fingertip drag 6×25m + crawl pull-buoy 8×50m. Supprimer catch-up et sculling. ~1400 m.
  - W1 J5 : 4×100m crawl Z2 + 4×25m breath control (1 drill respiratoire uniquement). Supprimer side kick et pyramidale. ~700 m.
  - **Volume hebdo W1 : ~3500 m au lieu de 6000 m (-42%)** ⚠️ Casse la base de la progression 10-15%.

- **W3-W4 : fusionner dos et crawl en micro-blocs**
  - W3 J1 : 4×50m streamline/équilibre crawl + 4×50m dos planche (pas un drill dos complet). ~600 m. Écraser temps transitions.
  - W3 J3 : 6×100m crawl intervalles Z3 (supprimer drill complet, aller droit au bloc crawl) + 2×50m dos un bras. ~900 m.
  - W3 J5 : 3×100m crawl/dos alterné + test 200m crawl comptage. ~650 m.
  - **Volume hebdo W3 : ~2150 m** (moins 50% vs W3 actuel ~2300).

- **W5 cutback : inévitable, déjà réduit, reste compressible à 30 min**
  - W5 J1 : 3×25m drill brasse pull isolé + 4×100m crawl allure douce. ~650 m.
  - W5 J3 : 4×50m fist swim + 4×100m crawl Z2. ~600 m.
  - W5 J5 : 4×100m mixte crawl/dos + test 200m crawl. ~650 m.
  - **Volume hebdo W5 : ~1900 m** (légal pour cutback, mais reste réduit).

- **W6-W8 : IM compressé à 30 min = impossible sans scinder**
  - W6 J1 : 5×200m crawl seuil → réduire à 3×200m (600m) + supprimer drill rappel + supprimer descente 50m. Tenir en 30 min.
  - W6 J3 : 6×200m IM → réduire à 3×200m IM (600m). Supprimer drills rappel. ~900 m total.
  - W6 J5 : 4×300m IM → réduire à 2×300m IM (600m). ~800 m total.
  - **Volume hebdo W6 : ~2300 m** (cible W6 actuelle ~2400, donc acceptable).

- **W8 test : incompressible, mais peut se faire en 30 min**
  - W8 J1 : alleger à 3×100m crawl (activité légère). ~400 m (vs 500 m actuel).
  - W8 J3 : 2×100m crawl + 1×100m dos + 1×100m brasse (activité très légère). ~400 m.
  - W8 J5 : TEST 400m crawl (17 min) + TEST 100m dos (5 min) + TEST 100m brasse (5 min) + 200m récupération (7 min) = **30 min pile**. Volume test inchangé (600 m test + 200 m récup = 800 m).

## Rigidity issues

- **Incompressibilité théorique du volume 2000-2800 m en 60-75 min** :
  - 2000 m en 60 min = 2 min pour 150 m brut (nage + repos) = cadence très serrée
  - 2000 m en 30 min = **4 min pour 150 m** = IMPOSSIBLE sans sauter transitions/repos
  - Drills + repos demandent 40-60% du temps total en séance technique → supprimer des drills = perdre le fil pédagogique

- **Progression des 10-15% hebdo devient non-linéaire si volume divisé par 2** :
  - W1 template : 6000 m hebdo → adaptée 30 min : 3500 m hebdo = -42% → W2 doit remonter à 4000 m pour respecter +15%, ce qui crée des sauts discontinus
  - La règle des 10-15% suppose une accumulation progressive (2000→2200→2400→2600→2800) ; passé à 50% elle devient (1200→1400→1550→1700→1850) = granularité trop fine et risque de non-progression

- **Séquence pédagogique comprimée = risque de fusion drills** :
  - W1-W2 : drills Équilibre/Streamline → Catch/EVF → Timing (3 familles en 2 semaines au lieu de progressif)
  - Si on réduit à 1 drill/séance : W1 J1 streamline seulement, W1 J3 fingertip seulement, W1 J5 breath control seulement = les familles ne se consolident pas → W2 Catch arrive avant la consolidation équilibre
  - Contradiction directe avec `progression_logic` point (3) : "chaque famille introduite avant d'être maintenue en rappel"

- **Introduction des nages liée à la semaine, pas au nombre de séances** :
  - Dos en W3 (après 2 semaines = 6 séances crawl, bonne base)
  - Si 30 min = 3 séances/semaine sur 2 semaines = 6 séances, OK pour timing
  - Mais si ces 6 séances ne totalisent que 2500 m au lieu de 6000 m, la base crawl n'est pas assez consolidée → risque de confusion motrice "non-interférence" (point 4 `progression_logic`) est violé
  
- **Safety_notes : 48h minimum entre séances** :
  - Respecté avec J1/J3/J5 (4 jours minimum entre J1 semaine n et J1 semaine n+1)
  - ✅ Pas de conflit si on garde ce pattern

- **Comptage coups de bras = marqueur d'objectif, mais volume réduit** :
  - Objectif : réduction -10 à -15% coups/50 m en 8 semaines
  - Avec volume réduit (3500 m/semaine vs 6000 m cible), la densité relative de travail EVF/catch diminue → la réduction de coups sera probablement inférieure à -10% même si la technique s'améliore
  - Exemple : 100 m EVF par séance (template W1) vs 50 m EVF par séance (adapté 30 min) = 50% moins de temps de renforcement EVF → moins de "mémoire motrice" → moins de gain mesurable
  - **Expectation d'objectif devient non-tenue : le marqueur -10-15% est réaliste à 2000 m/semaine, pas à 1200 m/semaine**

- **Cutback W5 obligation** :
  - Template : W5 = -15% volume pour "consolidation neuromusculaire"
  - Adapté 30 min : W5 déjà réduit à 1900 m (vs W4 2300 m = -17% OK)
  - Mais si on récupère avec -15% en W5 sur un pool de 3500 m, cutback = 2975 m, pas assez repos neuronal → risque de non-intégration brasse (point 4 logic : brasse introduite EN W5 cutback pour "contexte faible pression")

## Contradictions

- **Contradiction progression_logic (1) vs réduction volume 50%** :
  - Logique 10-15% suppose accumulation progressive : 2000 → 2200 → 2400 → ... → 2800 m/séance
  - Réduction à 30 min force : ~1200-1300 m/séance stables ou légère montée à 1700 m pic
  - Taux progression réel : -40% vs cible, annule l'effet de surcharge progressive → délai de 4-8 semaines supplémentaires pour même amélioration technique
  - **Gain d'efficience (-10-15% coups) cible W8 devient irréaliste**, probable réalisation partielle (-5-8%) seulement

- **Contradiction progression_logic (3) : Drills par famille distincts vs compression à 1 drill/séance** :
  - Template W1-W2 : Équilibre (streamline, poisson, 6-3-6) → Catch (fingertip, sculling, catch-up)
  - 30 min adapté : W1 J1 streamline seul, W1 J3 fingertip seul, W1 J5 breath control seul = 3 familles différentes en 3 séances
  - Pas de "consolidation" d'une famille avant passage à la suivante (principle "introduced before being maintained in recall") → risque d'automatismes superficiels

- **Contradiction progress_logic (4) : Non-interférence motrice vs base insuffisante** :
  - Dos introduit W3 après "2 semaines crawl consolidation" (logic)
  - 30 min adapté W1-W2 : 6 séances de 1200-1400 m chacune = 7800 m crawl total vs 6000 m template
  - **Suffisant temporellement (6 séances) mais VOLUME 30% inférieur** → base crawl moins encodée neurologiquement → risque d'interférence si dos introduit à W3 en parallèle (les patterns crawl pas assez automatisés pour fonctionner "en arrière-plan" pendant apprentissage dos)

- **Contradiction safety_notes : volume insuffisant pour développer les drills en toute sécurité** :
  - Safety note : "mobilisation épaules AVANT chaque séance : 2 min... reduce conflit sous-acromial"
  - Mais EVF (early vertical forearm) = position antépulsion maximale, doit être travaillée 200-300 m/semaine minimum pour développer les stabilisateurs
  - 30 min adapté : W1-W2 EVF seulement 100-150 m/semaine → risque d'incompétence musculaire (coiffe rotateurs pas assez renforcée) → le "drapeau rouge" douleur antéro-latérale épaule devient PLUS probable (pas moins) en W3-W4 quand intensité monte
  - Paradoxe : réduction volume = augmentation risque swimmer's shoulder

- **Contradiction cutback W5 + introduction brasse** :
  - Logic point (2) : "W5 cutback car sans semaine allégée... automatismes acquis se fragilisent. W5 utilisée pour introduire brasse pendant crawl consolidation"
  - Template W5 : 2000 m cutback + brasse 25-50 m par séance = LOW VOLUME brasse donc OK
  - 30 min adapté W5 : 1900 m cutback + brasse toujours ~50 m par séance = PROPORTION brasse PLUS élevée (50/1900 = 2.6% vs 50/2000 = 2.5% template) = pas vraiment différent
  - MAIS si brasse est faiblement intégrée en W4 (volume réduit 30 min), W5 tentative de consolidation brasse DANS une semaine cutback = double surcharge neuromotrice (nouveau pattern + fatigue) → risque d'erreur form brasse → risque genou (drapeau rouge "douleur ligament médial brasse")

- **Safety note 48h minimum entre séances** :
  - ✅ J1/J3/J5 pattern respecté, pas de conflit

- **Marqueur objectif "coups de bras -10-15%" devient NON-ATTEINT** :
  - Summary & progression_logic : "Marqueur : réduction -10 à -15% coups/50 m en 8 semaines"
  - À 30 min = volume 50% réduit = densité EVF/catch-up réduite = moins d'encodage moteur = réduction estimée -5-8% seulement
  - Template dit "objectif réaliste" à 2000 m/semaine → ce n'est plus vrai à 1200 m/semaine
  - **L'objectif du plan ne peut plus être tenu avec l'adaptation**