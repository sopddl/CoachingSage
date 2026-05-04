# Story Autoprofil HealthKit (Epic 3 Phase 2 #4)

Status: in-progress

## Story

**As a** utilisateur CoachingSage qui ouvre un questionnaire sport,
**I want** que mes réponses « niveau » et « fréquence » soient pré-remplies depuis Apple Santé (workouts récents, VO2max si disponible) et présentées en validation,
**so that** je n'aie pas à m'auto-évaluer dans le vide quand HealthKit a déjà l'info — avec fallback au questionnaire actuel si HK est vide ou refusé.

## Contexte produit

- Décisions Sophie 2026-05-03/04 (cf. mémoire `epic3_flow_choice_AB.md` #3 + roadmap Phase 2 #4).
- Pré-requis livrés : Story 2.1 (HealthKit profile read), Story 2.2 (onboarding 5 steps), équipement onboarding global mergé `48ea74c` (5 codes équipement multi-sport).
- Le RunningQuestionnaire actuel demande `level` (Q1, 4 buckets) et `frequencyPerWeek` (Q3, 3 buckets) — c'est exactement ce qu'on peut inférer de HealthKit.

## Acceptance Criteria

1. **AC1 — Permissions HealthKit étendues** : `DefaultHealthKitService` demande, en plus des 4 types existants (sex/DOB/weight/height), les types READ : `HKObjectType.workoutType()`, `HKQuantityType(.vo2Max)`, `HKQuantityType(.heartRate)`. Une seule pop-up système groupée. Aucun WRITE. Les purpose strings `NSHealthShareUsageDescription` (FR/EN) sont mises à jour pour mentionner « activité physique récente » sans utiliser de termes médicaux (EU MDR safe).

2. **AC2 — `fetchVO2MaxRecent()`** : retourne le sample VO2max le plus récent dans la fenêtre **6 mois** (`mL/(kg·min)`, `Date`, `source` = nom appareil) ou `nil`. Ne throw jamais ; nil sur refus/absence. Mockable via protocol.

3. **AC3 — `fetchWorkoutSummary(timeWindow:)`** : sur les 8 dernières semaines par défaut, retourne un résumé : `totalCount`, `weeklyAverage` (Double), `dominantSport: HKWorkoutActivityType?`, `appleWatchDetected: Bool` (true si ≥1 workout sourcé par appareil watchOS). Ne throw jamais ; struct vide sur refus/absence.

4. **AC4 — `AutoProfileInference` service pur** :
   - `inferLevel(vo2Max: Double?, weeklyWorkouts: Double, sportCode: String) -> LevelEstimate` :
     - VO2max présent + sport `running` → 4 buckets (<35 beginner, 35-43 recreational, 43-52 regular, ≥52 competitive — tables H/F neutralisées V1 par approximation, à raffiner si Sophie veut).
     - VO2max absent → fallback fréquence : 0/sem → beginner, <2/sem → recreational, 2-3.5/sem → regular, ≥3.5/sem → competitive.
   - `inferFrequencyBucket(weeklyAverage: Double) -> FrequencyEstimate` : <1.5 → `2`, 1.5-3 → `3`, ≥3 → `4_or_more`.
   - `equipmentSuggestions(appleWatchDetected: Bool) -> [EquipmentCode]` : `[gps_watch, heart_rate_monitor]` si watch détectée, `[]` sinon.
   - Tous purs, deterministic, testables sans HealthKit.

5. **AC5 — `AutoProfileReviewView`** : nouvel écran SwiftUI poussé en remplacement de Q1+Q3 du SportQuestionnaire **uniquement si** `inferLevel` ET `inferFrequencyBucket` ont produit une suggestion non-trivial (vo2Max présent OU ≥1 workout détecté). Sinon → fallback au questionnaire actuel (Q1 et Q3 affichées).
   - UI : carte « D'après Apple Santé » (icône cœur) avec 2 lignes éditables :
     - « Niveau : **Régulier** » + 4 radio buttons préchargés (override).
     - « Fréquence : **3×/sem** » + 3 radio buttons préchargés (override).
   - Bouton « Continuer » → injecte les valeurs choisies dans `SportQuestionnaireEngine.accumulated` aux clés `q1_level`/`q3_frequency` et avance la conversation à Q4 (ou Q5 si Q4 skippée par règle beginner).
   - L'écran s'inscrit dans la conversation chat : message Léon « J'ai jeté un œil à ton historique sportif — voilà ce que je vois, dis-moi si c'est bon. » + bulle review.

6. **AC6 — Onboarding equipment pré-coché Apple Watch** : `EquipmentSelectionView` (commit `48ea74c`) reçoit un input `prefilledFromWatch: Bool`. Si true au load (= `fetchWorkoutSummary().appleWatchDetected`), `gps_watch` et `heart_rate_monitor` sont pré-cochés. Une discrète mention « Détecté depuis Apple Santé » sous les capsules concernées. L'utilisateur peut décocher.

7. **AC7 — Tests** :
   - `AutoProfileInferenceTests` : couvre les buckets level (avec/sans VO2max, par sport) et frequency, ainsi que `equipmentSuggestions`. ≥10 cas.
   - `MockHealthKitService` étendu : permet d'injecter `vo2Max?`, `workoutSummary` arbitraires.
   - Pas de test sur la vraie impl HK (relève d'intégration manuelle).

8. **AC8 — Non-régression** : si HealthKit refusé, indisponible ou vide → flow questionnaire identique à aujourd'hui (Q1 puis Q3 affichées comme avant). Onboarding equipment fonctionne sans pré-cochage si `appleWatchDetected = false`.

## Hors scope

- Strava (OAuth + sync externe, dette ultérieure).
- Refonte Q4 contraintes (Phase 2 #5 questionnaire universel).
- Tables VO2max H/F séparées (V2 si demande).
- Pré-fill HK pour les 9 autres sports (Story 3.3a Running pilote uniquement, mais l'API `inferLevel(sportCode:)` accepte n'importe quel code → trivial à étendre).

## Tasks

- [ ] Étendre `DefaultHealthKitService` (permissions + 2 méthodes), updater purpose string FR/EN.
- [ ] Étendre `HealthKitServiceProtocol` + `MockHealthKitService`.
- [ ] Créer `AutoProfileInference` service + tests unitaires.
- [ ] Câbler `fetchWorkoutSummary` au load `EquipmentSelectionView` (input `prefilledFromWatch`).
- [ ] Créer `AutoProfileReviewView` + intégration dans `SportQuestionnaireView` (saut Q1+Q3 si inférence dispo).
- [ ] Cmd+B + tests + commit + merge `--no-ff` main.
