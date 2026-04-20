# Adaptability : running-expert-marathon-16sem + p5-low-energy-week

## Rigidity score
**6/10**

Le template offre une structure de cutback toutes les 4 semaines (W4, W8, W12) qui permet une adaptation relativement propre pour une semaine de fatigue. Cependant, les blocs 2 et 3 (W5-W11) sont densément articulés autour de progressions linéaires d'intensité (tempo 25→30→35→40 min, VO2max 600m→1000m→1200m, long run portion AM croissante) qui ne tolèrent pas facilement une "pause" sans casser le rythme. Bloc 4 (affûtage) est rigide par essence — toute déviation risque de désaligner le tapering.

## Patch approach

Traiter la semaine de fatigue comme un "cutback non-planifié" : réduire le volume de -20% vs la semaine cible, **maintenir les allures d'intensité exactes** (pas d'érosion qualitative), et compenser sur la semaine suivante non pas par du volume ajouté (risque de surcharge), mais par un retour à la progression normale sans "rattrapage" du volume perdu (accepter que cette semaine soit une semaine de consolidation plutôt que de progression). Cette approche respecte le principe Mujika & Padilla du template : la qualité prime, le volume s'adapte.

## Concrete modifications

- **W<N> J1** (Run facile + strides) : réduire le run facile de -5 à -8 min (ex : W5 = 45 min au lieu de 48 min). Strides conservées intégralement (stimulation neurale = priorité). Durée session : -5 min.
- **W<N> J2** (Renforcement) : supprimer 1 série sur chaque exercice (ex : calf raises 3 séries au lieu de 4, Nordic 2 séries au lieu de 3, etc.). Reps inchangées. Durée session : -8 à -10 min.
- **W<N> J3** (Tempo) : réduire le volume tempo de -20% en maintenant l'allure seuil exacte. Exemple : W5 (30 min continu) → 24 min continu. W3 (2x16 min) → 2x13 min. Format inchangé (continu vs fractionné). Durée session : -6 min.
- **W<N> J5** (VO2max) : réduire de -1 répétition et/ou réduire la durée de récupération de -30 sec. Exemple : W6 (6x1000m) → 5x1000m, W7 (5x1200m) → 4x1200m. Allure 5K inchangée. Durée session : -8 à -12 min.
- **W<N> J7** (Long run) : réduire de -15% vs semaine cible. Exemple : W5 (26 km) → 22 km. Proportion portion AM conservée (= ratio km AM / total identique). Exemple : W6 (27 km, 11 km AM) → 23 km avec 9,3 km AM. Durée session : -30 à -35 min.

**Volume total semaine** : réduction cumulée ~-20% vs semaine cible (ex : W5 ~63 km → ~50 km).

**Semaine suivante (rattrapage)** : retour à la progression normale du template sans "compenser" en hausse. La semaine de fatigue reste un point de consolidation ; on continue le plan comme prévu. Seule exception : si la fatigue persiste (signes dans safety_notes : FC repos +8 bpm, jambes lourdes > 72h), passer à une semaine de cutback formelle (W4, W8, W12) plutôt que de forcer la progression suivante.

## Rigidity issues

- **Blocs 2 et 3 (W5-W11)** : progressions linéaires strictes d'intensité (tempo 25→30→35→40, VO2max 600→1000→1200m). Une semaine de "pause" crée un trou dans le scénario de développement capacité seuil / VO2max. Patch : accepter que cette semaine = consolidation du palier actuel plutôt que progression. Semaine suivante : ne pas "doubler" la progression (ex : ne pas sauter de W5 à W7 template pour compenser) — cela violant la règle des 10-15% semaine-à-semaine.

- **Blocs 3 W9-W12** : long run portion AM progressive (18→20 km). Une réduction du long run jour J réduit aussi la spécificité AM simulée. Exemple : W9 (30 km, 18 km AM) réduit à 25 km avec 15 km AM = moins de stimulus haute-intensité en fin de long run. Risque : perte de confiance en fin de marathon si l'entraînement des 20 km AM consécutifs n'est pas complété dans ce cycle. Patch : si la semaine de fatigue tombe en W9-W12, accepter la réduction de spécificité ; compenser en rallongeant légèrement le long run de la semaine suivante (W10 : 32 km devient 34 km pour rattraper les km AM perdus).

- **Bloc 4 (W13-W16, affûtage)** : structure rigide par essence. Une semaine de fatigue pendant l'affûtage crée une ambiguïté : réduire davantage le volume (risque = sous-stimulus avant la course) ou maintenir (risque = fatigue résiduelle le jour J) ? Patch (si fatigue en W13-W15) : traiter comme semaine "cutback spéciale" de l'affûtage — maintenir les allures exactes, réduire volume de -10% seulement (vs -20% en bloc normal) pour ne pas creuser davantage le trou pré-race. Si fatigue en W16 (race week) : déconseillé d'adapter le plan. Si les signes de surcharge surgissent en W16, réduire le marathon même n'est pas une solution acceptable — plutôt reporter la course si possible, ou accepter une performance réduite.

## Contradictions

- **Contradiction 1 : Maintenance de l'intensité vs fatigue neurologique**. Le template stipule (progression_logic 2) : "le tapering réduit le VOLUME, jamais l'INTENSITÉ... Les séances tempo et VO2max [...] maintiennent les allures exactes des blocs 2 et 3." Une semaine de fatigue (sommeil dégradé, stress) réduit la disponibilité neurologique. Maintenir l'allure seuil à 85-90% FCmax et l'allure 5K à 95-100% FCmax sur des jambes/système nerveux fatigués risque : (a) une dégradation silencieuse de l'allure nominale (tu crois courir à AS mais tu tournes à AS - 5 s/km), ou (b) une fatigue psychologique majorée. **Résolution** : si fatigue confirmée (FC repos +8 bpm, sommeil < 6h/nuit 3 jours, appétit baissé), réduire l'intensité d'une entaille : allure seuil = AS - 10 s/km (vs AS nominale), allure VO2max = allure 5K - 5 s/km. Cela viole techniquement le principe "intensité non réduite" du template, mais c'est un moindre mal vs casser une séance en milieu d'exécution ou induire une blessure de surcharge.

- **Contradiction 2 : Règle "1 jour de repos entre séances" vs compression de volume**. Le template (safety_notes) stipule : "1 jour de repos ou mobilité entre les séances running (pattern : J1 run / J2 force / J3 tempo / J4 repos / J5 VO2max / J6 repos / J7 long run)". Réduire le volume via compression (ex : supprimer J4 repos, cumuler J3 tempo + J4 VO2max) viole cette règle à cause des 48h minimums entre qualités. **Patch** : ne pas compresser ; au lieu de cela, réduire chaque séance individuellement (durée -10 à -15%). Garde l'architecture hebdomadaire (J1 J2 J3 repos J5 J6 J7) intacte.

- **Contradiction 3 : Cutback W4/W8/W12 déjà planifiés vs semaine fatigue non-prévue en bloc normal**. Si la semaine de fatigue tombe, ex., en W6 (bloc 2, après le cutback W4), l'appliquer crée un second mini-cutback à J4 après W4 à J28. Le template ne prévoit pas deux cutbacks rapprochés. Risque minimal (volume total semaine < déficit), mais psychologiquement frustrant. **Patch** : si fatigue en W5-W7, documenter la raison (travail, maladie légère, etc.) ; si raison "temporaire" (travail chaotique cette semaine), appliquer la réduction et reprendre W7 normal. Si raison chronique (syndrome surcharge précoce), envisager repousser le marathon de quelques semaines et reprendre le plan à W1 en décalé.

- **Contradiction 4 : Aucune contradiction explicite avec safety_notes** sauf la note sur surcharge (3+ signes → passer à cutback). Appliquer cette adaptation revient à appliquer la règle de surcharge du template — cela l'approche **sans** contradiction.