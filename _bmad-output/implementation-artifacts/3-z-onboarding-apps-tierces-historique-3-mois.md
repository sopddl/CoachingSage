# Story 3.z — Onboarding apps tierces + premier topo 3 mois (Epic 3)

Status: ready-for-dev
Branche cible : `epic-3/story-3.z-apps-tierces-historique`
Effort estimé : **~1.5-2j** (dev solo)

## Story

**As a** utilisateur CoachingSage qui s'inscrit en utilisant Strava / Decathlon Coach / Runkeeper / Garmin Connect comme app sport principale,
**I want** être prévenu·e à l'onboarding que ces apps doivent être synchronisées avec Apple Santé pour que CoachingSage voie mes séances, ET que mon premier lancement de l'onglet Progrès m'affiche l'historique des 3 derniers mois,
**so that** je ne tombe pas sur un dashboard vide alors que j'ai déjà 3 mois d'activité, et que l'autoprofil onboarding ait une base solide (3 mois de workouts).

## Contexte produit

- Constat Sophie 2026-05-14 (test iPhone réel post-Story 3.9 push) : sur un compte qui utilise Strava sans avoir activé Strava→Santé, l'app paraît vide.
- Vision Sophie 2026-05-15 (cf. mémoire `decision_onboarding_apps_non_sync_sante`) : **pas de re-demande au login** (redondant avec onboarding qui demande déjà HK + fait l'autoprofil) ; à la place, **3 leviers** dans l'onboarding existant + Progrès.
- 3 leviers :
  - **(a)** Élargir la fenêtre d'autoprofil 8 sem → 12 sem pour aligner sur la promesse "3 mois".
  - **(b)** **Premier launch** de l'onglet Progrès = `.quarter` (90j) au lieu de `.week` (effet wow), puis `.week` les fois suivantes.
  - **(c)** Nouvel écran onboarding *"Tu utilises d'autres apps sport non synchronisées avec Santé ?"* + checklist + mini-tuto sync, **avant** la pop-up système HealthKit.
- Hors scope V1 (Epic 7+) : OAuth Strava direct (token mgmt, accord commercial, RC pro éditeur).

## Acceptance Criteria

### Partie (a) — Fenêtre autoprofil 12 semaines

1. **AC1** — Dans `OnboardingViewModel.importFromHealthKit()` (actuellement ligne ~204), `fetchWorkoutSummary(weeksBack: 8)` devient `fetchWorkoutSummary(weeksBack: 12)`. Aucune autre modification du flow autoprofil.
2. **AC2** — Idem pour les autres call-sites onboarding qui s'appuient sur la fenêtre 8 sem si présents (vérifier `SportQuestionnaireView.swift` ligne 76 : `fetchWorkoutSummary()` — laisser le défaut générique à 8 sem côté `HealthKitService:140` car utilisé aussi par `HealthSummaryBuilder` Léon ; à confirmer après grep).
3. **AC3** — Aucune nouvelle permission HK demandée (déjà toutes accordées à l'onboarding personalData + extension 3.9.0).

### Partie (b) — Premier launch Progrès = `.quarter`

4. **AC4** — `ProgressionView` (ou son ViewModel) lit un flag `UserDefaults` `progress_first_launch_seen` (clé scopée user si multi-account, sinon globale acceptable V1).
5. **AC5** — Si flag `false` au load → période sélectionnée = `.quarter` au lieu du `.week` par défaut, puis le flag bascule à `true` dès que la View apparaît (pas seulement au switch de période, sinon l'effet wow ne s'enregistre pas).
6. **AC6** — Si flag `true` → comportement actuel inchangé (`.week` par défaut).
7. **AC7** — Un user qui se déconnecte / reconnecte ne re-voit pas le wow (flag UserDefaults persiste sur device, c'est OK V1).

### Partie (c) — Écran onboarding apps tierces

8. **AC8** — Nouvel écran SwiftUI `ThirdPartyAppsSyncView` inséré dans `OnboardingScreen` enum **à la position 2** (entre `firstNameLanguage` rawValue 0 et `personalData` rawValue 1) → renumérotation des autres écrans.
   - **Justification** : la pop-up système HK est déclenchée à `personalData.importFromHealthKit()`. Le panneau doit venir AVANT pour que l'user ait pu activer Strava→Santé.
9. **AC9** — Contenu écran (formulation Sophie strict) :
   - Titre : *"Tu utilises d'autres apps sport non synchronisées avec Santé ?"*
   - Sous-titre court : *"CoachingSage lit tes séances depuis Apple Santé. Si tes apps n'y envoient rien, on ne pourra pas les voir."*
   - 2 boutons : **Oui** / **Non, suivant**
10. **AC10** — Si **Oui** → checklist de 4 apps + "Autre" :
    - Strava (icône)
    - Decathlon Coach (icône)
    - Runkeeper (icône)
    - Garmin Connect (icône)
    - Autre app (texte libre optionnel, max 60 char, non bloquant)
    - Chaque app sélectionnée → carte expandable avec mini-tuto FR/EN ≤ 3 étapes (ex. Strava : "Profil → Apps → Santé → Activer toutes les catégories").
11. **AC11** — Bouton de bas d'écran : *"J'ai activé la sync, continuer"* (primary) + *"Activer plus tard"* (secondary, mêmes conséquences côté flow).
    - Aucune obligation : l'user qui clique "Activer plus tard" passe à `personalData` quand même. On ne bloque pas.
12. **AC12** — Persistance : on stocke en `core_profiles` (champ JSONB existant ou nouveau `onboarding_third_party_apps`) la liste des apps déclarées, pour pouvoir réafficher un rappel doux dans l'onglet Progrès si vide (story future, V1 = juste stocker).
    - Si pas de champ disponible → stocker en UserDefaults V1 (`onboarding_declared_apps`). Pas bloquant.
13. **AC13** — Si l'user a répondu **Non** → on n'affiche jamais ce hint plus tard. Si **Oui** → on peut en V2 ajouter un rappel.

### Tests

14. **AC14** — `OnboardingViewModelTests` : couvre la nouvelle séquence d'écrans (firstNameLanguage → thirdPartyAppsSync → personalData → howItWorks → …), `goNext()` sur chaque transition, et le cas "Oui" + "Non" ne bloque pas.
15. **AC15** — `ProgressionViewTests` (ou ViewModel) : couvre le flag UserDefaults — first launch = `.quarter`, second launch = `.week`. Cleanup du flag dans `setUp`/`tearDown`.
16. **AC16** — Snapshot `ThirdPartyAppsSyncView` (light/dark FR/EN) si on a `swift-snapshot-testing` câblé.

### i18n

17. **AC17** — Toutes les clés FR/EN ajoutées dans `Localizable.xcstrings` (titre, sous-titre, noms d'apps, étapes des mini-tutos, bouton CTA). Grep `onboarding.thirdparty.*` après extraction.

### Non-régression

18. **AC18** — Si user **Non** → onboarding ressemble à aujourd'hui (juste +1 écran rapide).
19. **AC19** — Le flag premier launch Progrès, une fois consommé, ne réapparaît pas (pas de boucle).
20. **AC20** — Tests existants `OnboardingViewModelTests` + `ProgressionViewModelTests` PASS après renumérotation `OnboardingScreen.rawValue`.

## Hors scope

- **OAuth Strava direct** : Epic 7+ avec RC pro éditeur. Confirmé Sophie 2026-05-15.
- **Deep-links vers les apps** (`strava://open` etc.) : V2 si demandé. V1 = juste le mini-tuto texte.
- **Détection automatique "Strava est-il sync ?"** : iOS n'offre pas d'API pour ça. On reste sur déclaratif.
- **Rappel récurrent dans Progrès si vide** : V2 (la donnée déclarée sera dispo grâce à AC12).

## Tasks

### Partie (a) — fenêtre 12 sem
- [ ] `OnboardingViewModel:204` — passer `weeksBack: 12`.
- [ ] Vérifier par grep si autres call-sites onboarding utilisent 8 sem, ajuster.
- [ ] MAJ `OnboardingViewModelTests` qui asserterait sur 8.

### Partie (b) — premier launch Progrès = .quarter
- [ ] Localiser le ViewModel / la View qui set la période initiale (probablement `ProgressionView` ou `ProgressViewModel`).
- [ ] Ajouter constante `UserDefaultsKey.progressFirstLaunchSeen`.
- [ ] Lire le flag à l'init → si false, set `.quarter` + bascule flag à true au `.onAppear`.
- [ ] Tests unitaires VM.

### Partie (c) — écran onboarding apps tierces
- [ ] Renuméroter `OnboardingScreen` enum (insertion à rawValue 1, shift des suivants).
- [ ] Créer `ThirdPartyAppsSyncView.swift` dans `Views/Screens/Onboarding/`.
- [ ] Câbler la View dans `OnboardingView.swift` (switch sur currentScreen).
- [ ] Ajouter état `declaredThirdPartyApps: Set<String>` + `usesUnsyncedApps: Bool?` dans `OnboardingViewModel`.
- [ ] Câbler persistance V1 (UserDefaults si pas de champ JSONB dispo immédiatement).
- [ ] Extraire les keys i18n FR/EN (4 apps × 3 étapes ≈ 12-16 keys).
- [ ] Tests unitaires + (si snapshot dispo) snapshot light/dark FR/EN.

### Build / valid
- [ ] `mcp__xcode__BuildProject` PASS.
- [ ] Cmd+U PASS (Sophie côté Xcode).
- [ ] Cmd+R test simu flow complet en FR + en EN.
- [ ] **Agent `ui-reviewer` obligatoire** (cf `CLAUDE.md` Process livraison UI) avant claim "feature UI livrée" — scénarios : (1) onboarding réponse Oui → checklist Strava+Decathlon, (2) onboarding réponse Non → skip rapide, (3) premier launch Progrès = .quarter wow, (4) second launch Progrès = .week.

## Definition of Done

- [ ] AC1-AC20 tous validés.
- [ ] `mcp__xcode__BuildProject` + Cmd+U PASS.
- [ ] Test simu manuel : flow onboarding Oui + Non, premier launch Progrès, FR+EN.
- [ ] Agent `ui-reviewer` verdict READY (P0/P1 fixés).
- [ ] Merge `--no-ff` sur `main` + push origin.
- [ ] Mémoire `epic3_story_3z_done.md` créée + index MEMORY.md MAJ.
- [ ] Mémoire `backlog_strava_thirdparty_apps_sync.md` supprimée (résolue par cette story sauf OAuth long-terme).

## Notes / risques

- **Renumérotation `OnboardingScreen.rawValue`** : risque de casser des tests qui hardcodent `0/1/2/…`. Vérifier `OnboardingViewModelTests` grep `rawValue` + recompiler.
- **i18n** : si on bundle des icônes d'apps (Strava etc.) → vérifier les droits d'usage des logos. Alternative safe = pictogramme générique + nom texte.
- **AC12 persistance** : si pas de champ JSONB déjà dispo, on tape UserDefaults V1 et on note la dette pour migration BDD propre plus tard (mais lien à la session iPhone-only = OK V1).
