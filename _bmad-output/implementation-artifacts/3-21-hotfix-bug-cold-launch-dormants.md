# Story 3.21 — Hotfix Bug F (cold launch sans programme)

> **✅ DONE 2026-05-25** : différé levé sur décision Sophie « finalement traitons sinon on cumule une dette ». Hypothèse (C) confirmée par lecture statique, fix livré via flag local SwiftData-only `bootstrappedDormantsLocal`. 723/723 tests PASS dont 2 nouveaux AC4.
>
> **🔄 RÉDUCTION POST-REVUE 2026-05-24** : Le Bug A (illustration yoga ambiguë Dirgha/Cat-cow) initialement scopé ici a été **fusionné dans Story 3.23** (qualité illustrations) — seul endroit où ces ajouts vivent désormais. Cette story reste avec **Bug F seulement**.

Status: **done**
Branche cible : `epic-3/hotfix-3.21-cold-launch-dormants` — branchée depuis `main` (commit `c10c2a8`)
Effort estimé : **0.25-0.5j** (hotfix ciblé Bug F seul)
Story précédente : Story 3.15 v7 (bootstrap dormants, mémoire `epic3_story315_done`) ; Story 3.19 (mergée main `c10c2a8` 2026-05-23/24).

## Story

**As an** utilisatrice qui re-cold-launche l'app après changement de device (sans refaire d'onboarding),
**I want** retrouver mes programmes "Préparés" automatiquement,
**so that** le bootstrap dormants Story 3.15 tienne sa promesse cross-device au lieu de me laisser face à un dashboard vide.

## Contexte produit

Test simu Sophie 2026-05-24 : sur iPhone 17 Pro iOS 26.4 (après avoir testé sur iPhone 16 Pro 18.3), dashboard affiche mode vide "pas encore de programme", alors que le bootstrap 3 dormants Story 3.15 est censé garantir 3 programmes "Préparés".

## Investigation préalable Plan (AVANT le fix)

### Root cause hypothesis matrix

- `OnboardingViewModel.finalize()` ligne 372-378 : appelle `dormantBootstrapService.bootstrapIfNeeded()` en best-effort.
- `SessionDashboardViewModel.refresh()` ligne 172-178 : appelle aussi `bootstrapIfNeeded()` au load dashboard (rattrapage Sophie v7 2026-05-21).
- `DormantBootstrapService.bootstrapIfNeeded()` ligne 80 : **skip si `profile.bootstrappedDormants == true`** (idempotent par design).
- `DefaultAdaptedProgramRepository` : *« local-first, pas de Supabase V1 »* — `AdaptedProgramRecord` est SwiftData-only, NON synchronisé entre devices.
- `Services/DTOs/CoachingProfileDTO.swift` ligne 21 : `bootstrappedDormants` EST dans le DTO → CoachingProfile **est sync Supabase**.

**Hypothèses ordonnées** :

- **(C) — Le plus probable** : Sophie a fait onboarding sur iPhone 16 Pro → `coachingProfile.bootstrappedDormants = true` côté Supabase. Au cold launch iPhone 17 Pro, SyncService pull le `CoachingProfile` (flag=true) mais `AdaptedProgramRecord` est local-first donc PAS sync. `bootstrapIfNeeded()` voit `bootstrappedDormants=true` → skip → dashboard vide. **Faux bug "code" mais VRAI bug produit cross-device.**
- (A) Le bootstrap ne s'exécute pas (régression câblage). À vérifier via Console logs.
- (B) Race condition `bootstrapIfNeeded()` vs `fetchActive()`. Peu probable (séquentiel `await`).

### Plan d'action investigation (Jalon 1)

Reproduire le cold launch en test simu : fresh install onboarding (vérifier bootstrap OK), Reset Content & Settings (= cross-device simulation), relancer l'app. Si dashboard reste vide → **hypothèse (C) confirmée**.

## Acceptance Criteria

1. **AC1 — Diagnostic confirmé par reproduction** : à l'issue du Jalon 1, le doc EST mis à jour avec la cause root.
2. **AC2** — Selon le diagnostic :
   - **Si (C) confirmé** (hypothèse principale) : ajouter un 2e trigger bootstrap qui s'active quand `bootstrappedDormants=true` MAIS `startedCount + dormantCount == 0`. Créer flag complémentaire `bootstrappedDormantsLocal: Bool` (SwiftData-only, jamais sync) pour distinguer flag global Supabase vs présence locale. **Idempotence préservée** : si user a delete tous ses dormants intentionnellement, on ne les regénère pas (à arbitrer Sophie — semble incompatible avec promesse Story 3.15 *« L'user delete → ne revient pas »*).
   - **Si (A)** : restaurer wiring DI.
   - **Si (B)** : sérialiser `bootstrapIfNeeded()` puis `fetchActive()` explicitement.
   - **Si faux bug** : documenter "edge case clarifié, no-op code" (Sophie doit décider : forcer onboarding sur nouveau device OU edge case accepté).
3. **AC3 — Cohérence avec Story 3.22-F-bis** : si 3.22-F-bis (empty state CTA) est livré avant ce hotfix, vérifier que le CTA "Commencer mon premier programme" affiche **seulement si `coachingProfile == nil || bootstrappedDormants == false`**. Sinon pire UX que l'écran muet (user voit CTA "premier programme" alors qu'il en a déjà cross-device).
4. **AC4 — Test unitaire** reproduisant le scénario cross-device : profil avec `bootstrappedDormants=true` + store local sans dormant + `refresh()` → asserter comportement attendu (selon AC2).

## Fichiers touchés (preview, selon diagnostic)

- `Coaching/Bootstrap/DormantBootstrapService.swift` — garde « localStore vierge ET globalFlag=true ».
- `Models/CoachingProfile.swift` — flag `bootstrappedDormantsLocal` (SwiftData-only).
- `Coaching/Dashboard/SessionDashboardViewModel.swift` — modification trigger bootstrap.
- `CoachingSageTests/Coaching/Bootstrap/DormantBootstrapServiceTests.swift` — test cross-device.

## Risques

- **R1** — Bouger la sémantique du flag `bootstrappedDormants` casse l'idempotence Story 3.15. Mitigation : flag local supplémentaire (`bootstrappedDormantsLocal`) plutôt que toucher la sémantique du flag global Supabase.
- **R2** — Faux bug : reproduire AVANT toute modif code, Jalon 2 conditionnel au diagnostic.
- **R3** — Sync ordering : SyncService pull du CoachingProfile peut arriver APRÈS le 1er `refresh()`. À investiguer Jalon 1.
- **R4** — Coordination avec 3.22-F-bis (AC3) : si livré en désynchro, conflit UX.

## Découpage Jalons

**Jalon 1 — Investigation / diagnostic (0.15j)**
- Reproduction Bug F en simu : fresh install onboarding + Reset Content + relancer.
- Output : doc mis à jour avec verdict + AC2 spécialisé.
- **Gate** : validation Sophie sur verdict + stratégie.

**Jalon 2 — Fix (0-0.25j, conditionnel)**
- Si faux bug : documentation seule.
- Si bug code : fix selon AC2 + test cross-device.
- Test simu Sophie sur 2 devices.

**Jalon 3 — Merge main + push (0.05j)**
- Merge no-ff "hotfix Story 3.21 Bug F".
- Mémoire `epic3_story321_hotfix_done.md` posée.

## Hors scope

- **Bug A (illustrations yoga ambiguës)** : déménagé Story 3.23 (qualité illustrations) — seule maison désormais.
- Stories 3.22 / 3.23 / 3.24 / 3.25 : scopées en parallèle, indépendantes.
- Story 3.20 (matched-geometry) : pause WIP commit `5a81cd8`.

## Notes techniques

- Branche dédiée depuis main : `git checkout main && git pull && git checkout -b epic-3/hotfix-3.21-cold-launch-dormants`.
- Pas de re-déploiement Supabase (préférer flag SwiftData-only).
- Tests : 0 régression sur 702+ tests existants.
