# Spec — Densité B : vrai levier moteur multi-sport (2026-07-02)

## Contexte et décisions ratifiées

Sophie 2026-07-02 : la densité ne sera pas une phrase Léon (mensonge) → **option B =
vrai levier moteur**. Un user qui s'entraîne déjà régulièrement obtient un programme
**réellement** plus consistant dès la création.

**Forks tranchés Sophie (session 2026-07-02, AskUser)** :
1. **Périmètre = multi-sport tout de suite** (pas de pilote yoga-seul).
2. **Cold-start (HK muet/refusé) = question de calibrage** au questionnaire (D5 party d'origine).
3. **Surface = phrase Léon au fil, vraie** — dite uniquement quand le moteur a réellement agi.

**Critère d'honnêteté (non négociable)** : contenu ET durée affichée cohérents.
Le multiplicateur `SessionVolumeScaler` seul (mute `durationMinutes` sans toucher les
exos, comme l'autoreg `WeeklyRegenApplicationService.swift:164`) est ÉCARTÉ.

## Héritage réutilisé (branche archive `chantier/densite-adaptation-seance-yoga`, tip `42f996d`)

- `SessionDensityAdapter` : pattern « transformations du contenu DÉJÀ présent » —
  bump de nombres + duplication de blocs existants, **zéro texte neuf** → filets
  i18n/dose verts par construction. Bornes injectables (`Bounds`). Durée affichée
  recalculée = base autorée + secondes réellement ajoutées.
- Leviers yoga doctrine-validés (template-quality-reviewer 2026-06-21) :
  extendHold ×1.5 ≤45 s (actives brèves) · +1 tour bloc actif avec repos intercalé ·
  sacro-saintes (savasana/pranayama/balasana) intouchables · trimRest INTERDIT.
- Persistance id-preserving (complétion jamais orpheline), seuil signal 1,5 séance/sem,
  fenêtre 4 sem.
- L'UI carte/toggle/contrôle par séance = JETÉE (pivot 23/06), ne pas ressusciter.

## État moteur vérifié (explo 2026-07-02, main)

- Exercice template = `{name, sets: Int?, reps: String?, duration: String?, rest_seconds: Int?, notes}`
  (`Templates/schema/template.schema.json:85-96`). `duration` = texte parseable
  (`SessionDurationParser`, segments « + »).
- `durationMinutes` séance = nombre autoré, passthrough adapter (`ProgramAdapter.swift:134`).
- Pipeline règles (ordre figé) : Constraint → Equipment → VolumeModulation →
  LevelPacing(stub) → MedicalClearance. **DensityRule s'insère en 4ᵉ position**
  (post-VolumeModulation, pré-LevelPacing).
- `MedicalClearanceRule` downgrade les intensités si `coachingProfile.requiresMedicalClearance`.
- Signal HK **non fetché à la création** dans main (AutoProfileInference = onboarding app ;
  HealthSummaryBuilder = AdaptRare Léon uniquement) → à câbler.
- Questionnaire : mécanique conditionnelle existante (Q4/Q4Date), insertion d'une
  question calibrage conditionnelle faisable (`UniversalQuestionnaire.swift:272-297`).
- Fil de Léon inc1 = stub (`StubLeonIntentService`) → restitution densité = ligne
  déterministe locale i18n, PAS LLM.

## Design du levier

### Principe unique multi-sport

Densifier = **ajouter du volume de ce que la séance contient déjà**, jamais de
l'intensité, jamais de technique neuve, jamais de texte neuf. Trois transformations :

- **L1 « +1 set »** (transversal, cœur du multi-sport) : sur un exercice éligible avec
  `sets ≥ 2` et dose parseable, `sets += 1`. Bump d'un entier — aucun texte touché.
- **L2 « extendHold »** (yoga) : tenue active brève ×1.5, plafond 45 s (existant).
- **L3 « repeatActiveBlock »** (yoga) : +1 tour du bloc actif, repos intercalé (existant).

`durationMinutes` recalculé : base autorée + Σ secondes ajoutées
(L1 : `seconds(duration) + rest_seconds` par set ajouté ; L2/L3 : existant).

### Garde-fous MDR (invariants, tous sports)

- **G1** `requiresMedicalClearance == true` → no-op total (aucune densification).
- **G2** Échauffement et retour au calme **jamais densifiés** (même invariant que
  durée-réglable D5).
- **G3** (reformulé WHITELIST, revue doctrine 07-02) : un exo n'est éligible que si sa
  zone appartient à la **whitelist du sport** (voir table) — toute zone inconnue ou
  absente = **inéligible par défaut**. La densité ajoute du volume FACILE/MODÉRÉ
  uniquement ; sprints, pliométrie, intervalles, efforts max jamais touchés.
- **G4** Plafond séance : « un cran » = **≤ +20 % de durée totale**, **max +1 set par
  exercice**, **N = 2 exos par séance (3 max)**. Le cap +20 % se calcule **après**
  `VolumeModulationRule` (pas de cumul de deux hausses) — invariant testé.
- **G5** La boucle autoreg existante (RPE/complétion, `RoutineCyclePlanning`) reste la
  redescente : si le user encaisse mal, le cycle suivant réduit. La densité ne désactive
  aucun mécanisme réactif.
- **G6** Signal = comportement (workouts réalisés) ou déclaration explicite. JAMAIS
  poids/IMC/données santé (D3 d'origine, MDR).
- **G7** Wording : jamais « pour ton objectif », jamais d'allégation bénéfice santé,
  jamais de jugement corps/santé. **G7bis** : phrase Léon et question calibrage
  restent **purement comportementales** — jamais « ton corps peut encaisser plus »,
  « ton niveau de forme », ni toute évaluation de capacité physiologique (glissement
  MDR vers finalité d'évaluation d'état).
- **G8** (nouveau, revue doctrine 07-02) : **aucune densification des semaines de
  décharge/taper**. Prérequis structurel : ce marqueur n'existe PAS dans le bundle prod
  (ni `deload_weeks` ni `week.role` — l'info n'est que dans `theme`/`goal` localisés) →
  passe build-time one-off qui régénère `deload_weeks: [Int]` par template, revue une
  fois, + filet swift (« toute semaine au theme EN allégé/taper est dans deload_weeks »).
  Sans G8 le moteur contredirait les `safety_notes` des templates (upperlower W5/W9/W12,
  taper marathon/half-ironman).

### Table d'éligibilité par sport — VALIDÉE DOCTRINE (template-quality-reviewer 07-02, NEEDS_REVISION intégrée)

Constat transversal de la revue (audit programmatique des 40 templates, 6 236 exos) :
le vrai gisement multi-sport = les **exos de renforcement/gainage de support**
(`type: strength`, RPE 6-7, sets 2-4) — le levier canonique « +1 série » (RP/Israetel).
Éligibilité = **whitelist de zones par sport** (G3), `sets ≥ 2`, hors zones/types listés.

| Sport | Whitelist zones (L1 +1 set) | Notes revue |
|---|---|---|
| running | `Daniels-E` (blocs run/walk sets≥2) + `RPE 4-5/5-6/6-7` en type strength | sorties longues = sets 1 → inéligibles par construction. Sur rec/regular/comp, quasi seul le renfo support est éligible. |
| cycling | `FTP-Z1`, `FTP-Z2` + `RPE ≤ 6-7` en type strength | souvent **no-op** (0-4 candidats selon niveau) — acceptable, la phrase Léon n'est dite que si le moteur a agi. Étirements `RPE 4-5` exclus (incohérents avec « un cran au-dessus »). |
| swimming | `technique`, `EN1`, `REC` + `RPE ≤ 6-7` à sec | éducatifs sets 4-6 (+1×25 m de drill = progression classique), renfo épaules Y-T-W = protecteur. |
| hiking | `RPE 4-5/5-6/6-7` type strength | A-skip taggé RPE 6-7 = faux positif → couvert par la passe de retag. |
| strength | `RPE 4-5/5-6/6-7` (accessoires 2-4 sets, RIR ≥ 2) | axiaux lourds déjà exclus par whitelist (RPE 7-8 / %1RM) SAUF en semaine allégée → couvert par **G8**, vérifié : avec G3+G8, 0 axial lourd éligible sur les 4 templates. |
| hiit | `RPE ≤ 6-7` **uniquement en séances `strength`/`mobility`** | **tout `interval` intouchable** (+1 tour = +volume haute intensité + prérequis plio non vérifiés). Pas no-op sport : 10-16 candidats support/template. |
| yoga | **L1 OFF — L2+L3 exclusivement** | sinon double densification des mêmes postures sur vinyasa (46 candidats L1 = les postures ciblées par extendHold). Sacro-saintes intactes. |
| tennis | `technique`, `Z2`, `tactique` + `RPE ≤ 6-7` renfo | drills au mur/coiffe Y-T-W sûrs et abondants. Sprints 15-20 m taggés RPE 6-7 = faux positif → passe de retag. |
| football | `technique`, `Z2`, `tactique` + `RPE ≤ 6-7` renfo | **`FIFA 11+ — ` = protocole figé, jamais densifié** — exception name-matching documentée (préfixe stable dans les 3 langues, politique nommage 06-17). « Bond latéral bas » → passe de retag. |
| triathlon | union des whitelists running/cycling/swimming selon la discipline de la séance | gros gisement renfo support (75 instances regular-16sem). Pas de séance ajoutée → règle Friel 48 h non touchée. |

**Prérequis données (AVANT le code moteur, increment 1)** :
1. **Passe de retag** ~20 exos plio/sprint mal zonés (sprints tennis-recreational
   `RPE 6-7` → `RPE 8-9`, sauts sur boîte PPL `technique` → zone haute, A-skip hiking,
   bonds football-beginner) + **filet swift** « aucun exo saut/sprint/bond en zone facile ».
2. **Marqueur décharge** `deload_weeks` régénéré build-time (cf G8) + **filet swift**.

### Signal et calibrage

- Fetch à la création (`fetchWorkoutSummary(weeksBack: 4)`, pattern branche archive) :
  `weeklyAverage ≥ 1,5` → densifie.
- Signal absent (HK muet, refus, `totalCount == 0`) → **question de calibrage**
  conditionnelle dans le questionnaire (« Tu fais déjà du sport régulièrement ? »,
  singleChoice oui/non), insérée seulement si signal HK indisponible. Réponse oui →
  densifie. PAS de densification par défaut sans signal ni réponse.
- Le signal est lu UNE fois à la création (calibration proactive). Densité
  vivante-sur-activité = parkée (D5a pivot 23/06, spec onboarding-programme).

### Surface user

- **Phrase Léon au fil** (restitution création), déterministe, 3 langues, dite
  UNIQUEMENT si densification réellement appliquée : registre « tu t'entraînes déjà
  régulièrement → je démarre un cran au-dessus » (wording exact à écrire, G7).
- Durées affichées recalculées dans la liste = le visuel qui ne ment pas.
- AUCUN réglage exposé (pas de carte, pas de toggle, pas de contrôle par séance).
- Audit : `AppliedRule` par séance densifiée (traçabilité interne existante).

## Design technique (vérifié sur main, 2026-07-02)

### Plomberie du signal → règle

- **Porteur du signal = `AdapterCoachingProfile`** (`AdaptationRule.swift:114`, aujourd'hui
  un seul champ `requiresMedicalClearance`). Ajouts additifs :
  `weeklyWorkoutsAverage4w: Double?` (HK) et `declaredRegularActivity: Bool?` (réponse
  calibrage). Sémantique cross-sport → coaching profile, pas sport profile. La signature
  du protocole `AdaptationRule` reste INCHANGÉE — `DensityRule` est une règle standard.
- **Fetch à la création** : `SessionView.presentAdaptedProgram` (`SessionView.swift:938-976`)
  fetch `fetchWorkoutSummary(weeksBack: 4)` avant `adapterService.adapt(...)` (pattern
  branche archive). `ProgramAdapterService.adapt` gagne un paramètre signal optionnel
  (défaut nil = comportement actuel, non-régression par construction).
- **`AutoProgramFactory` (3 sites, programmes dormants)** : signal **nil** en V1 → dormants
  jamais densifiés. Honnête (pas de signal explicite au bootstrap) et cohérent cold-start :
  pas de signal → pas de bump. Pas de phrase Léon non plus (rien n'a été fait).
- **Décision de design — gating par niveau** : densité appliquée aux templates
  **beginner + recreational uniquement**. Raison : le signal générique (workouts toutes
  activités) raconte « actif mais prudent sur CE sport » ; sur regular/competitive le
  volume est déjà élevé et le signal n'apporte rien (un compétiteur a trivialement
  ≥1,5 séance/sem) → +20 % serait du doctrine-risk gratuit. NB : `AutoProfileInference`
  pré-remplit déjà Q1 niveau depuis la même donnée — le gating évite le double-comptage
  (niveau bumpé ET volume bumpé). À confirmer en revue doctrine.

### Cohérence regen / cycles

- `RoutineCycleService` re-planifie les cycles depuis **les sessions du record** (il ne
  re-passe PAS par l'adapter, cf `RoutineCycleService.swift:14-17`) → la densification
  appliquée à la création **persiste naturellement** dans les cycles suivants, et
  l'autoreg ×0.9/1.0/1.1 s'applique PAR-DESSUS (redescente garantie, G5). Aucun
  branchement regen nécessaire.
- **Persistance** : `AdaptedProgramRecord.densityApplied: Bool` additif défaut `false`
  (pattern `environmentDefaultRaw`, pas de bump schéma). Sert : phrase Léon (affichage
  conditionnel), audit, future intégration onboarding. Densité **figée à la création**
  (vivante-sur-activité = parkée, D5a pivot 23/06).

### Sélection déterministe des exos densifiés (G4)

- Quand > N exos éligibles : prendre les **N premiers dans l'ordre de la séance**
  (hors échauffement/cooldown). Déterministe, testable, pas d'aléa.
- **Recalcul durée** : secondes ajoutées par set = `seconds(duration) + rest_seconds` si
  `duration` parseable ; pour les exos reps-only (strength : `reps:"10"`, pas de duration),
  constante nominale documentée par famille (ex. set strength ≈ 40 s + rest). Le
  `durationMinutes` autoré est de toute façon une granularité minute — l'estimation
  nominale reste honnête à cette échelle. `durationMinutes += round(Σsecondes/60)`.

### Question de calibrage (cold-start)

- Insertion conditionnelle dans `UniversalQuestionnaire` (mécanique Q4/Q4Date existante,
  `nextQuestion` `UniversalQuestionnaire.swift:272-297`) : posée **uniquement si**
  signal HK indisponible (refus, muet, `totalCount == 0`). Position : après Q1 niveau.
- singleChoice binaire, wording MDR-safe centré comportement (« Tu fais déjà du sport
  régulièrement (au moins 1-2 fois par semaine) ? » oui/non — wording final G7, 3 langues).
- Réponse NON persistée sur les profils : elle alimente `declaredRegularActivity` de la
  façade au moment de l'adapt, et seul `densityApplied` est persisté sur le record.

### Phrase Léon (surface unique)

- Affichée quand `record.densityApplied == true` : ligne dans la zone bannières Léon
  existante d'`AdaptedProgramView` (déterministe, locale, 3 clés i18n FR/EN/ES).
  Registre : « Tu t'entraînes déjà régulièrement, alors je démarre un cran au-dessus :
  des séances un peu plus complètes. » (base wording validé pré-screen 06-21, à refaire
  passer au challenger). Jamais affichée si rien n'a été fait. Fil de Léon inc2 (NL) :
  la même info passera dans la restitution quand le backend intent sera branché — hors V1.

### Filets swift (livrés avec l'implem, même chantier)

1. `DensityRuleTests` par famille : éligibilité (+1 set posé/refusé selon rôle), caps G4,
   no-op G1 (clearance), no-op sans signal, no-op hors gating niveau, warmup/cooldown
   intouchés (G2), exclusions intensité (G3).
2. Invariant durée : `durationMinutes` densifié == autoré + round(Σ secondes ajoutées/60).
3. Yoga : non-régression des 13+ tests adapter portés de la branche archive.
4. Questionnaire : question calibrage posée ssi signal absent ; chaîne `nextQuestion`
   non cassée (Q4/Q4Date inchangés).
5. i18n : clés phrase Léon + question calibrage présentes FR/EN/ES (filets existants
   restent verts par construction — aucun texte de contenu généré).
6. Suite adapter complète + `swift test` + build avant tout commit.

## Increments

1. **Données (prérequis)** : passe retag ~20 exos plio/sprint + régénération
   `deload_weeks` + les 2 filets swift associés.
2. **Moteur** : port `SessionDensityAdapter` → `DensityRule` multi-sport (règle 4),
   whitelists par sport, caps G4, recalcul durée, filets swift (par famille + invariants).
3. **Signal création** : fetch HK dans `presentAdaptedProgram` + question calibrage
   conditionnelle + `densityApplied` sur le record.
4. **Phrase Léon** : ligne bannière i18n FR/EN/ES (pré-screen challenger) + preuve
   visuelle snapshot.
5. **Non-régression** : suite adapter complète + `swift test` + build.

## Statut

- [x] Forks produit tranchés (Sophie, 2026-07-02)
- [x] Revue doctrine/MDR (template-quality-reviewer 07-02) : **NEEDS_REVISION intégrée**
  → G3 whitelist, G4 N=2/3 + cap post-VolumeModulation, G7bis, G8 décharge/taper,
  HIIT support-only, yoga L2/L3 only, prérequis données (retag + deload_weeks).
  **Feu vert code après increment 1.** Sources : RP/Israetel (volume landmarks),
  Bell et al. (deload), JOSPT/BJSM (progression course), ACE/ACSM (HIIT), NSCA (plio),
  BMC (FIFA 11+), MDCG 2019-11 rév. 2025 (frontière MDR lifestyle).
- [ ] Increments 1-5
