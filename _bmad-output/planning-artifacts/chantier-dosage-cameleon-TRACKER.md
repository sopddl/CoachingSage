# Tracker — Chantier Dosage Caméléon (10 sports)

**Méthode** : `methodo-passe-sport-industrielle-2026-06-07.md` (pipeline « Passe Sport »).
**Référentiel** : `referentiel-dosage-cameleon-DECISIONS.html`.
**Légende étapes** : ⬜ à faire · 🟡 en cours · ✅ fait · ⏸️ bloqué.

## Phase 0 — Assets (fait une fois)
| Asset | Statut |
|-------|--------|
| Méthodo « Passe Sport » | ✅ 2026-06-07 |
| Référentiel dosage | ✅ **v2 FIGÉ 2026-06-07** (`referentiel-dosage-cameleon-v2-FIGE.md`) après revue panel 5 agents + arbitrages Sophie |
| Panel personas standard | ✅ défini (combo) |
| Tracker | ✅ ce fichier |

**Décisions figées** : D1 charge = sensation+note (pas de kg, pas de jargon) · D2 reps/max · D3 chrono+souffles · D4 côté structuré · D5 bandeau allure+voix · D6 normaliser `.warmup` · D7 densité par sport (mode=proxy). Scope V1 = champs modèle now (non-breaking) + affichage ; tracking charge=V2. Football inclus. 3 règles transverses P0 (hiérarchie 1+1+0 · cas vide masqué · saisie non-bloquante).

## Phase 1 — Pilote
| Sport | Capture | Spec | Revue | Décisions | Implem | ui-reviewer | Device | Merge |
|-------|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **Muscu** (pilote) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | 🟡 | ⬜ |

> Capture ✅ + Spec ✅ (`spec-dosage-muscu-PILOTE-2026-06-07.md`, 7 gaps). Revue+Décisions ✅ `party-dosage-muscu-pilote-2026-06-07.md`.
> **Implem V1 ✅ 2026-06-07** (branche `chantier/dosage-cameleon-muscu`, non pushée) : reps-héros+chrono filet (AC2) · consigne charge « commence léger » (G1) · conversion « RPE 6-7 »→« effort 6-7 sur 10 » + retrait badge (G2) · côté affiché « Côté droit · Côté gauche » (G4) · modèle `load`+`side` non-breaking · variante=déjà via notes · 7 clés i18n FR/EN/ES. Build vert, 5/5 tests dosage + 0 régression (focus/timer/phase). Reps-héros + consigne **validés simu**.
> **NEXT = device-test Sophie** puis ui-reviewer/merge.

## Follow-ups dosage muscu (décidés en pilote, hors V1)
- **F1 — Stepper « noter mon poids »** → **V2** (sans persistance = creux ; persistance = tracking V2 ; évite de charger l'écran d'effort 1+1+0).
- **F2 — Côté tap-gaté** (split per-side dans le timer, « Côté droit → tap → Côté gauche ») → story dédiée timer (touche 3.34, risque régression). V1 = guidage affiché.
- **F3 — Scrub prose RPE/RIR** des 4 notes doctrinales templates muscu (FR/EN/ES) → passage `template-quality-reviewer` (doctrine EU MDR, ne pas éditer à l'aveugle). V1 = badge converti au rendu.
- **F4 — Bug data G6** : « Planche genoux au sol 30 sec » → chip « 15 sec » (incohérence nom/durée template) — hors dosage.

## ui-reviewer 2026-06-07 (flow muscu complet) → commit `a7392dc`
3 findings device-test Sophie confirmés + corrigés (aucun issu du diff dosage) :
- **#1 échauffement placeholder vide** → fallback guidé utile (jamais d'écran vide), robuste tous sports.
- **#2 retour arrière absent en minuté** → `SessionTimerEngine.back()` + bouton « Précédent » (parité Manuel). **Validé simu.**
- **#3 « Band pull-down assis » → dessin debout** → `resolveVariant` élargi aux variantes assises → `.pulldown`. Validé test.
- **#6 (P2)** clé `timed.work` sans ES → « Esfuerzo ».
Backlog non-bloquant : **#4** titre séance dupliqué sur le HUB (pré-existant) · **#5** « reps » anglicisme FR (décision wording).

## 2e device-test Sophie 2026-06-08 (nuit) → commit `4ddd1c8`
- **BLOQUANT — impossible de sortir de l'écran « terminé »** : la célébration de fin (stopgap pendant que la feuille récap ASYNC monte) n'avait aucun bouton → si la feuille ne monte pas (recordId, save offline/échec/edge), user piégé (juste le ✕). **Fix : bouton « Terminer » explicite (dismiss garanti) + image `checkmark.seal`→`trophy.fill`** (médaille/coupe demandée). Non reproductible via fixture (auto-dismiss 1.6s sans recordId) → **device-test = fin de VRAIE séance**.
- Validé au simu cette nuit (taps bridge, CoachingSage 1er plan) : reps-héros exo 1 (Goblet) **et** exo 2 (Romanian Deadlift), consigne charge, bouton Précédent, illustrations. Multi-app simu flaky (TailorSage resurgit) → pas de capture de l'écran fin lui-même.
**NEXT device-test Sophie** : (1) **fin de vraie séance = sortie OK + trophée**, (2) bouton Précédent, (3) dessin band pull assis, (4) fallback warmup placeholder, (5) côté G/D. Branche `chantier/dosage-cameleon-muscu` prête (commits `9578258`→`4ddd1c8`), **PAS mergée** (gate device-test).

## Verdict suite de tests (nuit 2026-06-08)
Suite unitaire complète : **1006 tests, 2 échecs — les DEUX hors de mon diff** :
- `GlossaryMatcherTests` (perf 90ms>50ms) = **flaky sous charge** → repasse vert isolé (69/69). Non-régression.
- `ExerciseTimelineCardSnapshotTests.testCardSubstituted_strength` = snapshot **98.36% < 99%** (precision couleur) = **dérive de rendu OS/simu iOS 26.5**, reproductible isolé, sur un composant que mon diff NE TOUCHE PAS (`SessionTimelineView`, zones Daniels pas RPE). **Dette : re-record la référence snapshot** (housekeeping, hors dosage). Base-check sur `main` non concluant (build module error sur pbxproj de main).
Mes suites directes 100% vertes : `DosageFormattingTests` (5), `FocusReviewFixesTests` (4), `SessionTimerEngineTests` (+3 back), `SessionFocusViewModelTests`, `SessionPhaseTextTests`.

## Phase 2 — Série
| Sport | Capture | Spec | Revue | Décisions | Implem | ui-reviewer | Device | Merge |
|-------|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| Running | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ |
| Cycling | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ |
| Swimming | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ |
| Triathlon | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ |
| Yoga | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ |
| HIIT | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ |
| Hiking | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ |
| Tennis | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ |
| Football (co) | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ |

## Carte technique (Explore 2026-06-07)
Modèle dosage = `Coaching/Adapter/AdaptedProgram.swift` :
`sets:Int?` (l.126) · `reps:String?` (l.127) · `duration:String?` (l.128) ·
`restSeconds:Int?` (l.129) · `notes:LocalizedText?` (l.130) · `targetZone:String?` (l.131) ·
`volumeAxis:VolumeAxis?` (l.132, **orphelin, jamais rendu**).
Rendu : `Coaching/Session/SessionFocusView.swift` (Manuel l.107-176 chips dosage l.301-328 ;
Minuté/Audio l.393-836). Voix : `SessionVoiceGuide.swift`. Phases : `SessionTimerPhase.swift`.

**ABSENTS du modèle** (à décider si on les ajoute) : charge/load, côté/latéralité structuré,
respiration/souffles, RPE/effort, tempo/cadence.
