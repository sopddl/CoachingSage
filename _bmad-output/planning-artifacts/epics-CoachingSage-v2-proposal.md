---
status: proposal-for-review
date: 2026-04-06
last-revised: 2026-04-29
supersedes: epics-CoachingSage.md (Epics 0, 2, 3 uniquement)
inputs:
  - epics-CoachingSage.md
  - Spike 0.3 v1 et v2 results
  - Décisions d'architecture 2026-04-06
  - Pivot algo-first 2026-04-29 (cf. section dédiée ci-dessous)
  - Décisions Story 0.5.8 / 0.5.10 du 2026-04-29 (découpage renaming pur + regen qualité, 10 SportCode confirmés, sports_collectifs et remise_en_forme tous archivés)
---

# CoachingSage — Proposition de réécriture Epics 0 / 2 / 3

## Contexte du pivot

Le spike 0.3 a révélé deux choses :

1. **Léon produit des programmes de qualité professionnelle** (validé sur 4 cas v1 + 2 adaptations v2 de niveau "coach clinicien")
2. **L'architecture "Léon génère tout from-scratch" n'est pas viable** à cause de NFR1, max_tokens, rate limits, et surtout coût à l'échelle

Nous pivotons vers une **architecture à 3 couches** :

```
┌──────────────────────────────────────────────────────┐
│  COUCHE A — ALGO LOCAL (offline, gratuit, instant)   │
│  SportQuestionnaire / RPE logging / Journal séances  │
│  Tous les formulaires, toutes les collectes struct.  │
└─────────────────────┬────────────────────────────────┘
                      │
┌─────────────────────▼────────────────────────────────┐
│  COUCHE B — ProgramTemplateLibrary                    │
│  40 templates validés (10 sports × 4 niveaux)        │
│  Bundled dans l'app, offline, garantit un plancher   │
└─────────────────────┬────────────────────────────────┘
                      │
┌─────────────────────▼────────────────────────────────┐
│  COUCHE C — LÉON (moteur créatif)                    │
│  Adaptation via JSON patch (hot path, haiku-4-5)     │
│  Regen hebdo (Léon+ uniquement)                      │
│  Génération from-scratch (cas edge, Léon Pro)        │
│  Questions ad-hoc, explications, adaptation RT       │
└──────────────────────────────────────────────────────┘
```

**Règle structurelle** : Léon n'est JAMAIS un formulaire, JAMAIS un parseur. Il raisonne, explique, adapte. Tout le reste est local.

## Pivot 2026-04-29 — Algo-first adaptation

Après livraison Story 3.1 (SportQuestionnaire local), constat : la plupart des sports V1 sont **suffisamment mathématisables** pour que l'adaptation des templates soit faite **par un algo deterministic local**, sans aucun appel IA. La doctrine sportive existante (Daniels VDOT pour course, Coggan FTP pour vélo, Maglischo CSS pour natation, Israetel %1RM pour muscu, Friel pour triathlon, etc.) couvre 95-99% des cas réels.

**Conséquence** :
- Le hot path adaptation (Story 3.3 d'origine) **ne consomme plus d'IA** par défaut
- L'IA reste mobilisée uniquement sur :
  1. Cas atypiques (combinaisons rares de contraintes, free_text qui sort du cadre algo)
  2. Questions ad-hoc / explications pédagogiques (Story 3.6)
  3. Adaptation séance temps réel (FR12)
  4. Public tiers FR17 (prof/coach décrivant un public spécifique)
  5. Génération from-scratch Pro (Story 3.5)
- Le quota free tier 10/jour (miroir Flore) ne consomme **plus que ces cas IA résiduels**, partagé entre eux. Free tier perçu comme **illimité sur le hot path**.
- Story 3.2 (selector) : **plus jamais de retour `nil`** — la library est étendue pour couvrir les 10 SportCode iOS (alignement nécessaire entre `Sport` package templates et `SportCode` enum app).

Cette refonte impose :
- Story 0.5.8 (renaming structurel pur — enum + JSON filenames + manifest, **sans regen contenu**)
- Story 0.5.9 (absorbée dans 0.5.10 — les hooks metadata sont injectés dans le prompt master de regen, pas en passe séparée)
- Story 0.5.10 *(nouveau, ajouté 2026-04-29)* : regen qualité sport-spécifique des 40 templates (10 sports × 4 levels), un prompt master par sport intégrant les hooks Story 0.5.9, revue par agent dédié `template-quality-reviewer`
- Doctrine doc `leon-algo-doctrine-by-sport.md` (formules + règles substitution + périodisation par sport, sources publiques citées)
- Refonte Story 3.3 → 3.3a (algo deterministic, free illimité) + 3.3b (IA fallback rate-limité)

**SportCode 10 sports confirmés** *(décidé 2026-04-29 ; reconfirmé 2026-04-30 après aller-retour generalFitness)* : pas d'ajout de `generalFitness` — Sophie tranche : pas de catégorie "sport générique" en V1. Les 4 templates `sports_collectifs` ET les 3 templates `remise_en_forme` sont **tous archivés** (Story 0.5.8) : génériques non convertibles en sport-spécifique sans regen. 10 sports finaux iOS : `running, cycling, swimming, triathlon, strengthTraining, yoga, hiit, hiking, tennis, football`. Cible library = 40 templates (10×4) après Story 0.5.10.

## Les 7 décisions qui sous-tendent cette réécriture

1. Architecture 3 couches (local / templates / Léon adaptation)
2. **40 templates pré-générés (10 sports × 4 niveaux), aligné sur enum `SportCode` iOS** (révisé 2026-04-29)
3. Léon = moteur d'adaptation par défaut (JSON patch, pas génération complète)
4. Progressive disclosure pour les cas edge (skeleton + S1, puis semaines à la demande)
5. Freemium Léon+ (4,99€/mois) / Léon Pro (12,99€/mois) / Pack 50 questions (1,99€) miroir Flore
6. Model tiering : sonnet pour création (one-shot templates + cas complexes), haiku pour volume
7. **Adaptation = algo deterministic local first, IA fallback uniquement sur cas atypiques + chat/temps-réel** (ajout 2026-04-29). Le quota 10/j est désormais cumulé entre 3.3b + 3.6, le hot path est gratuit illimité.

Chiffrage révisé 2026-04-29 : ~**$0.02-0.05 / user actif / mois** (vs $0.10-0.15 avant pivot algo-first, vs $0.55 plan initial). Le quota 10/j devient un confort UX plutôt qu'une vraie contrainte économique.

---

# Story 1.5 — Analytics & Funnel Measurement *(à ajouter à Epic 1, garde-fou business)*

As Sophie (product owner),
I want mesurer dès le jour 1 le funnel onboarding → première utilisation Léon → conversion premium,
So que je puisse piloter la rentabilité en temps réel sans naviguer à l'aveugle.

**Acceptance Criteria** :

**Given** la mise en place d'Epic 1 (Foundation)
**When** un utilisateur effectue n'importe quelle action significative
**Then** un événement anonymisé est tracké côté client puis pushé vers Supabase (table `analytics_events`)
**And** les événements minimums trackés sont :
- `app_install`, `signup_started`, `signup_completed`
- `onboarding_started`, `onboarding_step_X_completed`, `onboarding_completed`
- `first_program_requested`, `first_program_displayed`, `first_program_started`
- `first_session_logged`, `first_week_completed`
- `leon_call_made` (avec mode = adapt/regen/chat/generate)
- `paywall_shown` (avec trigger : soft_7_8 / soft_9_10 / hard / pricing_page)
- `paywall_dismissed`, `paywall_converted`
- `subscription_started` (avec tier : leon+ / leon-pro / pack-50)
- `churn_signal` (cancel)
**And** chaque événement contient : event_name, user_id (UUID anonyme), timestamp, properties_json (data event-specific)
**And** la table `analytics_events` existe en Supabase avec RLS, pas d'index sur user_id pour préserver l'anonymat
**And** un cron Supabase agrège chaque nuit les métriques clés dans `analytics_daily_summary` :
  - DAU / MAU
  - Funnel install → signup → onboarding → first_program → first_paywall → conversion
  - Coût Anthropic moyen par MAU (joint avec `ai_usage_logs`)
  - Conversion par cohorte d'install (week N)
**And** une vue admin (web simple, hors-app) affiche le dashboard pour Sophie
**And** alertes email/Slack si :
  - Coût Anthropic / MAU dépasse 0,15 € pendant 3 jours consécutifs
  - Conversion hebdomadaire chute de > 30% vs semaine précédente
  - Erreurs API Anthropic > 5% sur 24h

**Note** : cette story est **critique** parce qu'elle est la seule qui te permette de **piloter** ta rentabilité au lieu d'attendre la facture Anthropic en fin de mois pour découvrir que tu as 30% de marge en moins. À implémenter dans Epic 1, pas plus tard.

# Epic 0.5 — Template Library Creation & Validation *(nouveau, pre-Epic 1)*

**Pourquoi un nouvel epic** : la bibliothèque de 40 templates est un asset critique qui doit être prêt et validé **avant** de démarrer Story 3.2 (selector). C'est un travail éditorial qui se déroule maintenant en 2 phases (révisé 2026-04-29) :
- **Phase 1** (Stories 0.5.1→0.5.7) : structure, premiers templates, loader, manifest — **livrée 2026-04-20**
- **Phase 2** (Stories 0.5.8 + 0.5.10) : alignement enums + regen qualité sport-spécifique — **en cours post-Story 3.1**

**Scope final** : 40 templates de programmes spécifiques sport-par-sport (1 prompt master par sport, doctrine publique sourcée), bundled comme resources dans l'app.

## Structure du data model template

```swift
struct ProgramTemplate: Codable {
    let id: String                   // ex: "running-debutant-5k-8sem"
    let sport: Sport                 // enum
    let level: Level                 // débutant | intermédiaire | avancé | expert
    let name: String                 // nom affiché
    let durationWeeks: Int
    let sessionsPerWeek: Int
    let defaultObjective: String     // ex: "Terminer un 5km en course continue"
    let assumedProfile: String       // profil générique pour qui ce template est conçu
    let weeks: [TemplateWeek]        // détail semaine par semaine
    let safetyNotes: String
    let progressionLogic: String
    let validatedAt: Date            // date de validation humaine
    let validatedBy: String          // "sophie" | "coach-<name>" | "auto-claude-critic"
    let schemaVersion: Int           // pour migration future
}
```

## Les 40 templates — matrice sport × niveau *(révisé 2026-04-29 : 10 sports SportCode)*

Alignement strict sur l'enum `SportCode` iOS (10 codes : `running, cycling, swimming, triathlon, strengthTraining, yoga, hiit, hiking, tennis, football`). Les enums `Sport` et `Level` du package Templates **sont renommés en EN** Story 0.5.8 (pas de mapping interne FR→EN — élimination de la dette tech à chaud).

| SportCode | Beginner | Recreational | Regular | Competitive |
|---|---|---|---|---|
| running | Couch to 5K 8sem | 10K 8sem | Semi-marathon 12sem | Marathon 16sem |
| cycling | Reprise route 6sem | Endurance 10sem | Sorties longues 12sem | Cyclosportive prep 16sem |
| swimming | Initiation 6sem | Endurance 8sem | Technique 8sem | Perfectionnement 12sem |
| triathlon | Découverte multi 8sem (intro nat+vélo+course) | Sprint 12sem | Distance M 16sem | Half-Ironman 20sem |
| strengthTraining | Home Basics 8sem | Upper/Lower Split 12sem | PPL 12sem | Strength 5×5 cycle |
| yoga | Initiation 6sem | Hatha régulier 8sem | Vinyasa dynamique 10sem | Advanced practice 12sem |
| hiit | Débutant 6sem | Intermédiaire 8sem | Avancé 10sem | Athlétique 12sem |
| hiking | Marche reprise 6sem (plat 5-10km) | Randonnée moyenne 8sem (D+ 500m) | Trek 12sem (D+ 1000m + portage) | GR longue distance 16sem (multi-jours auto-suffisance) |
| tennis | Initiation 8sem | Régularité 10sem | Match prep 12sem | Tournoi prep 16sem |
| football | Prépa physique base 6sem | Saison amateur 8sem (intervalles + force + agilité) | Match physique 10sem | Elite prep 12sem (préparation pré-saison structurée) |

**Note 1 — Niveaux** : enum `Level` package Templates renommé EN Story 0.5.8 (`beginner | recreational | regular | competitive`) — alignement strict iOS, plus aucun mapping. Les fichiers JSON existants sont renommés (`-debutant-` → `-beginner-`, etc.) avec champ `level` mis à jour dans le contenu.

**Note 2 — Triathlon-débutant** : généré comme programme d'**introduction multidiscipline** (un peu de chaque) plutôt que vraie distance compétitive. Sécurise la couverture algo (jamais de `nil` dans Story 3.2).

**Note 3 — Couverture pleine** : **40 templates** (10 sports × 4 niveaux), tous remplis post-Story 0.5.10. `sports_collectifs` (4 templates) et `remise_en_forme` (3 templates) tous archivés Story 0.5.8 (génériques non convertibles en sport-spécifique).

## Stories

### Story 0.5.1 : Design du data model et du format de stockage
Définir `ProgramTemplate`, `TemplateWeek`, `TemplateSession`, `TemplateExercise` en Swift. Format de stockage : JSON dans le bundle app (`Resources/Templates/`). Chaque template = 1 fichier `.json` nommé par son id. Schéma JSON documenté dans `docs/template-schema.md`.

**Critères** :
- Structure Codable testée par round-trip encode/decode
- Documentation schéma `.md`
- Script Swift pour valider la conformité d'un fichier JSON

### Story 0.5.2 : Génération automatisée des ~38 templates (one-shot)
Réutiliser l'infrastructure de `Spike/Leon/` mais avec un nouveau prompt dédié ("génère un template de programme générique pour [sport] [niveau] assumant un profil standard"). Appel sonnet-4-6 pour chaque template (qualité prioritaire, coût acceptable ~$0.30 total).

**Critères** :
- Script Swift CLI `GenerateTemplates` dans `CoachingSage/Scripts/`
- Les ~38 templates générés en JSON stricts, sauvegardés dans `CoachingSage/Resources/Templates/raw/`
- Log de génération (tokens, coût, timestamps)
- Coût total < $5

### Story 0.5.3 : Challenge Claude (auto-critique) de chaque template
Pour chaque template généré, appel Claude en **mode "critic rigoureux"** : second prompt qui demande "liste tous les problèmes potentiels, incohérences, volumes inadaptés, exercices dangereux, progression illogique". Si problèmes critiques → marquer pour révision.

**Critères** :
- Script `ChallengeTemplates` génère un rapport par template (`Results/challenge_<id>.md`)
- Critères challenge : cohérence scientifique, sécurité, progression, ambiguïtés, volumes hebdo, équipements implicites
- Rapport agrégé `_challenge_summary.md` liste les templates qui passent / à revoir
- Aucun template `status: approved` tant qu'il n'a pas passé le challenge

### Story 0.5.4 : Révision par Léon (correction post-challenge)
Pour chaque template ayant des problèmes détectés, appel Léon avec le feedback du critic + demande de correction. Nouvelle passe challenge.

**Critères** :
- Script `ReviseTemplates` applique les corrections
- Max 3 itérations par template (si toujours KO → escalade manuelle à Sophie)
- Templates révisés stockés dans `Resources/Templates/revised/`

### Story 0.5.5 : Test d'adaptabilité (round-trip)
Pour chaque template, lancer 5 adaptations sur des profils fictifs variés (contraintes, équipement, objectifs décalés) et vérifier que le JSON patch produit est cohérent et ne contredit pas le template. Objectif : détecter les templates "trop rigides" qui ne se laissent pas adapter.

**Critères** :
- Script `TestTemplateAdaptations` génère 5 adaptations × 38 templates = 190 calls haiku (~$1)
- Chaque adaptation évaluée qualitativement (manuelle sur échantillon)
- Rapport agrégé `_adaptability_report.md`
- Templates trop rigides → retour en 0.5.4 pour assouplissement

### Story 0.5.6 : Review humaine finale
Sophie lit chaque template final, marque `validated_by: "sophie"` + date. Sur les sports où elle connaît un coach référent (Clément ?), demander une relecture experte.

**Critères** :
- 100% des templates relus par Sophie
- Au moins 3 templates relus par un coach expert (bonus)
- Liste des templates avec status `approved` stockée dans `Resources/Templates/approved.json`

### Story 0.5.7 : Intégration bundle app
Les templates validés sont copiés dans le bundle final de l'app. Chargement au démarrage dans une `ProgramTemplateLibrary` en mémoire. Checksum de chaque template calculé pour permettre les mises à jour OTA (future).

**Critères** :
- Loader Swift qui parse tous les templates au démarrage (< 100ms)
- Fichier `templates-manifest.json` avec checksums
- Tests unitaires sur le chargement

### Story 0.5.8 : Renaming structurel enum + JSON + manifest *(révisé 2026-04-29 — découpage)*

**Objectif** : alignement strict des enums `Sport` et `Level` du package Templates sur les contrats iOS (`SportCode` 11 cases EN, levels 4 cases EN), renommer les fichiers JSON existants, archiver les sports non-couverts, **sans toucher au contenu pédagogique**. Pré-requis structurel pour Story 3.2 (selector) et débloque Story 0.5.10.

**Critères** :
- Refactor `Templates/Sources/TemplateModel/Enums.swift` :
  - `enum Sport` → 10 cases EN : `running, cycling, swimming, triathlon, strengthTraining, yoga, hiit, hiking, tennis, football`
  - `velo` → `cycling`, `natation` → `swimming`, `musculation` → `strengthTraining`
  - `remise_en_forme` et `sports_collectifs` → **supprimés** (7 templates archivés vers `References/archived/`)
  - `sports_collectifs` → **supprimé** (4 templates archivés vers `References/archived/`)
  - `enum Level` → 4 cases EN : `beginner, recreational, regular, competitive` (renaming complet, plus de mapping FR/EN)
- Refactor `Models/CoachingProfile.swift` (iOS) :
- Renommer 34 JSON existants dans `Templates/Sources/TemplateLoader/Resources/Templates/` :
  - filename : sport+level FR → EN (ex: `musculation-debutant-...` → `strength-training-beginner-...`)
  - contenu : champs `sport` et `level` mis à jour
- Déplacer 4 templates `sports-collectifs-*` vers `Templates/References/archived/`
- Régénérer `templates-manifest.json` via `swift run GenerateManifest` (34 entrées attendues post-renaming, 44 cible après Story 0.5.10)
- Pas de regen contenu, pas de génération nouveaux templates → réservé Story 0.5.10
- Test `testProductionBundleLoads38TemplatesIfPopulated` ajusté en `testProductionBundleLoadsAtLeast30Templates` (déjà tolérant `>= 30`, OK)

**Effort** : ~1 jour (renaming pur, pas de génération AI).

### Story 0.5.9 : Audit metadata templates pour algo deterministic *(absorbée par Story 0.5.10 — 2026-04-29)*

**Status** : **MERGED INTO Story 0.5.10**. Les hooks metadata par exercice (`targetZone, requiredEquipment, incompatibleConstraints, alternatives, volumeAxis`) et par template (`weekStructure, progressionLogic, deloadWeeks`) sont injectés directement dans le **prompt master** de la Story 0.5.10 — pas de passe d'audit séparée. Aucun bénéfice à regen 2 fois la library : on intègre les exigences metadata dans la regen qualité.

### Story 0.5.10 : Regen qualité sport-spécifique des 40 templates *(nouveau, ajouté 2026-04-29 — absorbe 0.5.9, pré-requis Story 3.3a)*

**Objectif** : produire 40 templates **vraiment spécifiques au sport** (1 prompt master par sport, doctrine publique sourcée), avec hooks metadata complets pour l'algo Story 3.3a, revue par agent dédié `template-quality-reviewer`. **Refus explicite du générique** — stratégie qualité > vitesse (Sophie 2026-04-18).

**Pré-requis** : Story 0.5.8 livrée (enums alignés, library renommée, structure stable).

**Critères** :
- 1 prompt master par sport (11 fichiers `Templates/Prompts/master-{sportCode}.md`) intégrant :
  - Doctrine publique référente (Daniels VDOT pour running, Coggan FTP pour cycling, Maglischo CSS pour swimming, Israetel %1RM pour strengthTraining, Friel pour triathlon, etc.)
  - Périodisation et progressions sport-spécifiques (intersaison/saison foot, deload running, blocs cycling)
  - Schéma JSON exigé incluant les hooks metadata (Story 0.5.9 absorbée)
  - Contraintes EU MDR (mots bannis, requires_medical_clearance trigger)
- Génération sonnet-4-6 (qualité prioritaire sur coût) — coût estimé $5-10 total
- Revue par agent `template-quality-reviewer` (Claude SDK custom agent) sur checklist sport-spécifique :
  - Cohérence des zones d'effort avec la doctrine
  - Présence de tous les hooks metadata
  - Réalisme des volumes / récup
  - Détection de phrases génériques / boilerplate
- Itération prompt + regen jusqu'à validation agent (pattern `quality_over_speed_templates`)
- 40 templates `status: approved` finaux
- Manifest mis à jour (44 entrées)
- Test `testProductionBundleLoads44Templates()` ajouté
- Audit récurrent en prod prévu (memory `template_audits_recurring_prod`)

**Effort** : 1-2 semaines (regen + revue + itérations qualité).

**Scope total Epic 0.5** : ~3-4 semaines de travail (incluant 0.5.8 + 0.5.10). Coût Claude total ~$15-25 (regen sonnet sport-spécifique). 0.5.8 livrable rapide, 0.5.10 plus lourd mais débloque Stories 3.2 + 3.3a avec une library qualitative.

---

# Epic 2 — Onboarding Core & Profil *(réécrit, simplifié)*

**Avant** : 3 stories (données perso/sports, objectifs/équipement/contraintes, modification profil).
**Après** : 2 stories. La collecte du profil détaillé par sport est **déportée** vers Epic 3 (SportQuestionnaire local).

## Principe
L'onboarding initial est **strictement minimal** : 3-4 écrans, 60 secondes, zéro friction. Juste ce qui est nécessaire pour que l'app soit légalement utilisable et que le profil core existe. Tout le détail par sport est collecté **plus tard**, uniquement quand l'utilisateur veut un programme spécifique.

### Story 2.1 : Onboarding Core Minimal

As a nouvel utilisateur,
I want créer mon profil en moins d'une minute,
So that je puisse commencer à explorer l'app immédiatement sans formulaire pénible.

**Acceptance Criteria** :

**Given** un utilisateur qui vient de créer son compte (Story 1.1b)
**When** l'onboarding se lance automatiquement
**Then** l'écran 1 demande prénom + langue (pré-rempli si détectable depuis le compte Apple)
**And** l'écran 2 demande âge, poids, taille, sexe → **pré-remplis via HealthKit si autorisation accordée** (FR1)
**And** l'écran 3 affiche les sports disponibles (grille visuelle avec icônes), user tape 1+ sport qu'il pratique ou veut commencer (FR2)
**And** l'écran 4 affiche le **disclaimer médical** obligatoire (checkbox requise, NFR14)
**And** l'écran 4 pose **une seule question de contrainte majeure** : "As-tu une pathologie qui nécessite un avis médical avant l'effort ? (cardiopathie, grossesse, opération récente)" (oui/non + si oui → message recommandant de consulter avant usage)
**And** l'écran 4 demande le consentement RGPD analytics (NFR12)
**And** à la fin, le `CoachingProfile` core est créé en SwiftData + enqueue sync Supabase
**And** l'utilisateur arrive directement sur l'onglet **Aujourd'hui** qui affiche un état "Prêt à commencer ? Demande à Léon ton premier programme" avec un gros bouton CTA
**And** la table `coaching_profiles` est créée avec RLS `auth.uid() = core_profile_id`
**And** la table stocke **uniquement** les champs core : prénom, langue, âge, poids, taille, sexe, sports_selected (array), disclaimer_accepted, has_critical_pathology, rgpd_analytics_consent
**And** **aucun** champ d'objectif, d'équipement, de contrainte non-critique, ou de fréquence n'est demandé à ce stade
**And** l'ensemble de l'onboarding prend < 60 secondes chronométré sur un utilisateur moyen

**Déplacé vers Epic 3** : niveau par sport, objectifs, équipement, contraintes physiques détaillées, fréquence, records — tout ça sera collecté par le `SportQuestionnaire` quand l'utilisateur demande un programme.

### Story 2.2 : Modification du Profil Core

As a utilisateur,
I want pouvoir mettre à jour mon profil core à tout moment,
So that les infos reflètent ma situation actuelle.

**Acceptance Criteria** :

**Given** un utilisateur connecté
**When** l'utilisateur ouvre l'onglet Profil
**Then** toutes les données core sont affichées et modifiables (FR8)
**And** l'utilisateur peut ajouter/retirer des sports de sa liste (les `CoachingSportProfile` associés sont conservés ou soft-supprimés, pas détruits)
**And** les modifications sont enregistrées en SwiftData + enqueue sync Supabase
**And** le disclaimer médical reste consultable dans les paramètres (NFR14)
**And** la section "Sports" de l'onglet Profil liste chaque sport actif avec un résumé des infos collectées par le SportQuestionnaire (cliquable pour modifier via Epic 3)

**Scope total Epic 2** : 2 stories au lieu de 3. Simplification drastique et conforme aux retours UX (onboarding court = meilleure conversion).

---

# Epic 3 — Léon, Templates & Adaptation *(réécrit, restructuré)*

**Avant** : 6 stories centrées sur Léon comme générateur from-scratch.
**Après** : 6 stories reflétant l'architecture à 3 couches. Le hot path passe par templates + adaptation, Léon from-scratch devient un cas edge premium.

### Story 3.1 : SportQuestionnaire local *(nouveau, remplace "conversation Léon onboarding")*

As a utilisateur qui demande un programme dans un sport pour la première fois,
I want répondre rapidement à 4-5 questions ciblées par mon sport,
So that Léon ait le contexte nécessaire pour adapter le programme, sans que ce soit un formulaire pénible.

**Acceptance Criteria** :

**Given** un utilisateur avec un CoachingProfile core (Epic 2)
**When** l'utilisateur tape le bouton "Demander un programme [sport]" pour la première fois sur ce sport
**Then** un écran de type conversation (bulles chat, avatar Léon, typing indicator) s'ouvre
**And** le moteur **local** `SportQuestionnaireEngine` navigue dans les questions définies pour ce sport
**And** les questions sont présentées **une par une**, réponses par taps sur des options (pas de saisie libre sauf 1 champ final optionnel)
**And** le moteur gère le branchement conditionnel (ex: si niveau = débutant, skip la question sur les records)
**And** chaque sport a son propre fichier Swift `RunningQuestionnaire`, `MusculationQuestionnaire`, etc. implémentant `SportQuestionnaire`
**And** l'expérience utilisateur est visuellement **indistinguable d'une vraie conversation avec Léon** (même UI chat que la Story 3.3)
**And** chaque interaction est **instantanée** (zéro appel réseau, zéro latence, zéro token consommé)
**And** à la fin, un `CoachingSportProfile` est créé (ou mis à jour) pour ce (user × sport) avec toutes les réponses structurées
**And** la table `coaching_sport_profiles` est créée avec colonnes : user_id, sport (enum), level, goals_json, equipment_json, constraints_json, frequency_per_week, session_duration_minutes, free_text_notes (nullable), records_json (nullable), last_updated_at, conversation_history_json
**And** la table a RLS strict
**And** les questions par sport sont localisées (xcstrings)
**And** **5 questions maximum** pour les sports standards, **7 maximum** pour triathlon / multi-discipline
**And** **le flow complet prend < 60 secondes**

**Taxonomie des questions par sport (à spécifier dans un doc à part)** :

| Sport | Questions principales |
|---|---|
| Running | Niveau (4 options), objectif (5 options : 5k/10k/semi/marathon/bien-être), fréquence (3 options), contraintes genou/dos (multi-select), équipement spécifique (multi-select) |
| Musculation | Niveau, objectif (masse/tonif/force/bien-être), lieu (salle/maison), équipement (multi-select), contraintes dos/épaules/genoux |
| Natation | Niveau, distance max actuelle, nages maîtrisées (multi), objectif, piscine dispo |
| Triathlon | Niveau course / niveau vélo / niveau natation (3 questions), distance cible, équipement (multi) |
| Tennis | Niveau, objectif (technique/régularité/match), fréquence, type d'accès (court/mur) |
| etc. |

### Story 3.2 : ProgramTemplateSelector *(nouveau, cœur du free tier — révisé 2026-04-29)*

As a utilisateur qui vient de compléter un SportQuestionnaire,
I want que l'app sélectionne automatiquement le template de base le plus adapté à mon profil,
So que j'aie immédiatement quelque chose à regarder avant même que Léon intervienne.

**Acceptance Criteria** :

**Given** un utilisateur ayant un `CoachingSportProfile` complet pour un sport
**When** l'algo `ProgramTemplateSelector.select(profile:)` est invoqué
**Then** l'algo parcourt la `ProgramTemplateLibrary` (Epic 0.5, post-Story 0.5.10 = 40 templates pleins ; couverture structurelle dès Story 0.5.8 = 34 templates renommés)
**And** sélectionne le template qui match : sport + niveau + objectif le plus proche
**And** l'algo est **100% local**, **0 appel réseau**, **0 token**
**And** **retourne TOUJOURS un `ProgramTemplate` non-optionnel** (signature `select(profile:) -> ProgramTemplate`) — révisé 2026-04-29 : la library couvre les 10 SportCode × 4 levels après Story 0.5.10, donc le cas `nil` n'existe plus
**And** un test paramétrique vérifie que **toute combinaison `(SportCode, Level, GoalsPayload représentatif)` retourne un template valide**
**And** l'algo passe ensuite **immédiatement** la main à Story 3.3a (algo adaptation deterministic) — pas de bandeau "Léon réfléchit", l'utilisateur reçoit son programme adapté **instantané** dans le hot path par défaut
**And** la Story 3.5 (from-scratch Pro) reste accessible en option utilisateur explicite, mais n'est **plus déclenchée par un fail Story 3.2**

**Pré-requis bloquants** : Story 0.5.8 (alignement enum + complétion library) doit être livrée avant Story 3.2.

### Story 3.3a : Adaptation algo deterministic *(nouveau, hot path free tier — révisé 2026-04-29)*

As a utilisateur gratuit qui vient de recevoir un template de base,
I want que l'app adapte ce template à mon profil spécifique (contraintes, équipement, fréquence, level confirmé) **instantanément et sans appel réseau**,
So que mon programme soit personnalisé sans attendre Léon ni consommer mon quota.

**Acceptance Criteria** :

**Given** un `ProgramTemplate` sélectionné par Story 3.2 + un `CoachingSportProfile` complet
**When** le moteur `ProgramAdapter.adapt(template:profile:)` est invoqué (100% local, sync, 0 token)
**Then** l'adapter applique les règles deterministic suivantes en cascade :
1. **Substitutions par contrainte** : pour chaque exercice du template avec un `incompatibleConstraints` qui matche `profile.constraints`, remplacer par la première `alternative` compatible. Si aucune alternative → marquer "à remplacer manuellement" + log warning interne.
2. **Substitutions par équipement** : exercices nécessitant un `requiredEquipment` non présent dans `profile.equipment` → alternative ou suppression de la séance.
3. **Modulation volume** : ajuster nombre de séances/semaine selon `profile.frequencyPerWeek` (table de mapping doctrine sportive : si template = 4 sessions, profil = 3 → quel pruning ?).
4. **Pacing par level** : si Story 3.1.5 livrée (HK pre-fill) → ajuster intensité cible / allures via VMA / FTP / CSS estimé. Sinon → utiliser défaut level générique du template.
5. **Garde-fous EU MDR** : appliquer localement les règles de la mémoire `epic3_leon_legal_constraints` (refus volumes inadaptés, mini-rappel programme, mots bannis, requires_medical_clearance respecté).

**And** l'adapter retourne un `AdaptedProgram` (programme + log des règles appliquées + flag `requiresAIAssist: Bool` si l'algo n'a pas trouvé de solution propre)
**And** si `requiresAIAssist == true` → proposition utilisateur "Léon peut affiner ce programme pour ton cas particulier (1 appel sur ton quota)" → flow Story 3.3b
**And** sinon → programme affiché directement, **0 attente, 0 quota consommé**
**And** la doctrine algo par sport est documentée dans `_bmad-output/planning-artifacts/leon-algo-doctrine-by-sport.md` (Daniels VDOT pour course, Coggan FTP pour vélo, Maglischo CSS pour natation, Israetel %1RM pour muscu, Friel pour triathlon, etc.)
**And** chaque règle deterministic est testée par un cas concret (ex: `running` + `constraints=["knee"]` → exercice plyo remplacé par exercice à faible impact prédéfini)
**And** **aucun** appel réseau n'est fait dans ce flow

**Pré-requis bloquants** : Story 0.5.9 (audit metadata templates) — sans hooks `incompatibleConstraints` / `alternatives` / `requiredEquipment` / `targetZone` sur les exercices, l'algo ne peut pas patcher.

**Effort estimé** : 4-5 jours (cœur algo + doctrine doc 4 sports prioritaires running/cycling/swimming/strengthTraining + tests + UI hand-off).

---

### Story 3.3b : Adaptation IA fallback *(rate-limité, cas atypiques)*

As a utilisateur gratuit avec un cas vraiment particulier (combinaison rare de contraintes ou demande free_text spécifique),
I want que Léon retravaille mon programme si l'algo deterministic ne suffit pas,
So que mon cas atypique soit traité quand même.

**Acceptance Criteria** :

**Given** un `AdaptedProgram` issu de Story 3.3a avec `requiresAIAssist == true`, OU un user qui tape explicitement le bouton "Léon, retravaille ce programme"
**When** l'app invoque l'Edge Function `sage-coaching-ai?mode=adapt-rare`
**Then** l'Edge Function envoie à Claude (haiku-4-5 par défaut) : prompt système "adaptation patch raffinée" + template JSON + profil JSON + `AdaptedProgram` post-3.3a + raison du fallback (constraints atypiques détectées / free_text non vide / demande explicite)
**And** Claude renvoie un **JSON patch** au-dessus du programme déjà adapté par l'algo (exercise_substitutions, volume_adjustments, progression_pacing, safety_notes, personalization_note) — structure `AdaptationPatch`
**And** l'Edge Function valide le JSON côté serveur, et en cas de JSON invalide, retry avec sonnet-4-6 (fallback qualité)
**And** l'Edge Function applique le **rate limit cumulé** : `10 calls/jour free tier` partagé avec Story 3.6 (questions ad-hoc Léon) et tout autre mode IA non-Pro
**And** si quota dépassé → erreur `quota_exceeded`, l'app affiche "Tu as utilisé tes 10 questions gratuites aujourd'hui. Passe Léon+ pour l'illimité ou achète un pack de 50 questions." (le programme algo-only reste utilisable)
**And** le client Swift reçoit le patch, l'applique localement par-dessus l'`AdaptedProgram`, et affiche le programme final
**And** le programme final est sauvegardé en SwiftData avec référence au template source + patch deterministic + patch IA appliqués (pour audit et re-application)
**And** le temps total perçu (call + apply + render) est < 30 secondes dans 90% des cas (**NFR1b**)
**And** pendant l'attente, l'UI affiche "Léon affine ton programme pour ton cas particulier..." (libellé honnête : ce n'est pas l'adaptation principale, c'est un raffinement)
**And** la table `ai_usage_logs` enregistre chaque appel : user_id, mode=`adapt-rare`, model, tokens_in, tokens_out, cost_usd, duration_ms, `triggered_reason: "atypical_constraints" | "freetext_request" | "user_explicit"`
**And** le prompt caching Anthropic est activé sur le system prompt
**And** en cas d'indisponibilité Anthropic → message "Léon indisponible, programme algo-only utilisable" et l'app continue avec le résultat de Story 3.3a (dégradation gracieuse, NFR17)

**Volume attendu** : 5-15% des adaptations selon les retours UX (cf. Story 3.7 N2/N3 monitoring). Si > 25% → revoir la richesse de l'algo 3.3a et / ou les hooks metadata.

### Story 3.4 : Regen Hebdomadaire *(Léon+ uniquement)*

As a utilisateur Léon+ en cours de programme,
I want que chaque semaine, Léon ajuste la semaine à venir en fonction de ce que j'ai réellement fait la semaine précédente,
So que mon programme reste vivant et s'adapte à ma progression réelle.

**Acceptance Criteria** :

**Given** un utilisateur Léon+ avec un programme en cours (adapté depuis un template)
**When** l'utilisateur approche de la semaine N+1 (à J-1 ou quand il l'ouvre explicitement)
**Then** l'app vérifie le statut de l'abonnement (Léon+ ou Léon Pro requis)
**And** si autorisé, l'app appelle `sage-coaching-ai?mode=regen-week` avec : programme en cours + template source + sessions réellement complétées en S(N) + RPE déclarés + douleurs/fatigue rapportées
**And** Léon renvoie un patch mis à jour pour la semaine N+1 (peut ajuster volume, supprimer un exercice, proposer un remplacement)
**And** le patch est appliqué et l'utilisateur voit une note "Léon a ajusté la semaine N+1 en fonction de ta dernière semaine" avec les changements mis en évidence
**And** le nombre de regen hebdo est illimité pour Léon+
**And** si un utilisateur free tier tente une regen, message "La regen hebdomadaire fait partie de Léon+. Passe Pro pour débloquer."
**And** la regen est **lazy** : si l'utilisateur n'ouvre jamais la semaine N+1, aucune regen n'est appelée
**And** les regens sont loggées en `ai_usage_logs` avec mode=regen-week
**And** temps cible < 30 secondes (NFR1 révisée)

### Story 3.5 : Génération from-scratch *(cas edge, Léon Pro uniquement — révisé 2026-04-29)*

As a utilisateur Léon Pro avec un cas particulier,
I want demander à Léon de créer un programme complet sans partir d'un template (rééducation spécifique, sport rare, mode "coach pour autrui"),
So que même mon cas atypique soit traité.

**Acceptance Criteria** :

**Given** un utilisateur Léon Pro
**When** l'utilisateur demande **explicitement** "programme from scratch" (entrée FR17 : prof/coach décrivant un public tiers) — la Story 3.2 ne pouvant plus retourner `nil` après pivot 2026-04-29, ce mode n'est **plus** déclenché par un fail selector
**Then** l'app vérifie l'abonnement Léon Pro
**And** l'app appelle `sage-coaching-ai?mode=generate` avec prompt système "progressive disclosure skeleton + week 1"
**And** Léon renvoie **skeleton + semaine 1 détaillée** (pas le programme entier, cf. décision 4)
**And** les semaines 2+ sont regen à la demande (même flow que Story 3.4)
**And** le mode generate utilise sonnet-4-6 (qualité prioritaire, coût acceptable pour Pro)
**And** temps cible < 90 secondes (NFR1 révisée pour cas edge)
**And** ce mode débloque aussi **FR17 (programmes pour publics tiers)** : prof de sport, entraîneur — Léon comprend la description du public cible et génère en conséquence
**And** les calls sont loggés en `ai_usage_logs` avec mode=generate et flag `pro_only=true`

### Story 3.3.1 : Soft Paywall Contextuel *(garde-fou business)*

As a utilisateur gratuit qui approche de mon quota quotidien de questions/adaptations Léon,
I want être informé de manière non-intrusive de l'existence de Léon+,
So que je puisse choisir de passer premium plutôt que d'être bloqué brutalement.

**Acceptance Criteria** :

**Given** un utilisateur gratuit avec un quota quotidien de 10 calls Léon
**When** l'utilisateur atteint 7-8/10 dans la journée
**Then** une bannière douce non-bloquante apparaît en haut de l'écran chat Léon : "Tu utilises beaucoup Léon ! Léon+ te donne l'illimité pour 4,99€/mois." avec un CTA "En savoir plus" et une croix de fermeture (mémorisée 24h)
**And** à 9-10/10 utilisations, un modal informatif s'affiche après la réponse : "Plus que 1 question gratuite aujourd'hui. Léon+ pour l'illimité ?" avec CTA Pro / "Plus tard"
**And** au quota dépassé (11ème call), message clair : "Tu as utilisé tes 10 questions gratuites aujourd'hui. Reviens demain ou passe Léon+ (4,99€/mois) pour l'illimité." avec CTA d'achat
**And** les bannières/modaux n'apparaissent JAMAIS pendant que l'utilisateur attend une réponse Léon (ne pas casser le flow d'usage)
**And** la conversion via soft paywall est trackée dans `ai_usage_logs` (champ `triggered_by` : "natural" / "soft_paywall_7_8" / "soft_paywall_9_10" / "hard_paywall")

### Story 3.6 : Questions ad-hoc à Léon (chat conversationnel)

As a utilisateur pendant mon entraînement ou ma séance,
I want poser des questions à Léon via un bouton flottant (technique, douleur, modification de séance, etc.),
So que j'aie un vrai coach à disposition.

**Acceptance Criteria** :

**Given** un utilisateur avec un programme en cours
**When** l'utilisateur appuie sur le bouton flottant Léon (visible sur tous les écrans, FR9)
**Then** une interface de conversation s'ouvre (FR10)
**And** l'utilisateur peut poser une question en texte libre (FR15)
**And** Léon répond via `sage-coaching-ai?mode=chat`, avec haiku-4-5 par défaut
**And** le contexte envoyé à Léon inclut : profil core, sport profile en cours, programme actuel, dernière séance faite, RPE récents (FR16)
**And** les réponses sont streamées si possible pour une UX réactive
**And** free tier : **10 questions par jour cumulées** entre `mode=chat` (Story 3.6), `mode=adapt-rare` (Story 3.3b), `mode=adapt-session` (FR12 ci-dessous), tout autre mode IA non-Pro — même quota partagé (révisé 2026-04-29 : aligne avec décision 7 algo-first, le cap 10/j est un cap "appels Léon IA" global et non par mode)
**And** **FR12** (adapter une séance en temps réel : "j'ai mal au genou aujourd'hui") : si Léon détecte une demande d'adaptation de séance actuelle, il génère un patch séance (mode=adapt-session) — décompte du même quota
**And** la conversation est persistée localement (SwiftData) et synchronisée (Supabase `conversations` table)
**And** chaque question décompte du quota quotidien, les packs de 50 (1,99€) alimentent un compteur `pack_questions_remaining`
**And** history limité pour éviter la dérive des tokens en entrée (summarization après 10+ messages)

### Story 3.8 : Refonte SessionView en dashboard « Séances » *(nouveau, ajouté 2026-05-07 — issu du party design)*

As a utilisateur qui ouvre l'app au quotidien,
I want que le 1er onglet me dise immédiatement « qu'est-ce que je fais à ma prochaine séance ? » — pas un catalogue de 10 sports « Demander un programme »,
So that l'écran d'usage quotidien soit actionnable, et que mon ou mes programmes en cours soient le centre de gravité.

**Contexte** : refonte issue du party design 2026-05-07 (`_bmad-output/planning-artifacts/party-seances-dashboard-2026-05-07.md`) — 5 décisions tranchées user-first par Sophie. Maquettes de référence : `ux-design-CoachingSage-seances-dashboard-2026-05-07.html`. Annule et remplace la décision #6 « dashboard simple » de la mémoire `epic3_flow_choice_AB.md` (2026-05-04).

**Acceptance Criteria — Tab bar refondue** :

**Given** l'app actuelle a 4 onglets (Séance · Programmes · Progrès placeholder · Profil)
**When** Story 3.8 est livrée
**Then** la tab bar est réduite à **3 onglets** : `Séances` (SF Symbol `figure.run`) · `Progrès` (SF Symbol `chart.bar.fill`) · `Profil` (SF Symbol `person.fill`)
**And** un **FAB Léon** circulaire (54×54, fond `#1E5090` bleu coach, icône chat blanche) est ajouté à cheval sur la tab bar — pattern transposé depuis `~/CL3/GardenSage/Views/Components/FloreFloatingButton.swift` (Circle 56×56, ombre `0.35` radius 8 offset y 4 → adapté en 54×54 offset y -32)
**And** le FAB ouvre une bottom sheet placeholder « Léon arrive bientôt » tant que Story 3.6 n'est pas livrée — pas d'entrée chat fonctionnelle (anti-pattern « UI bloated » Runna)
**And** le FAB est visible sur les 3 onglets (Séances / Progrès / Profil) — accessible depuis tous les écrans (FR9 amorcé)
**And** l'onglet `Progrès` reçoit un placeholder léger « Bientôt — Léon te montrera tes progrès ici » (remplacé par Story 3.9)

**Acceptance Criteria — Mode vide (Nathalie, 0 programme)** :

**Given** un utilisateur authentifié sans aucun `AdaptedProgramRecord`
**When** il ouvre l'onglet Séances
**Then** la nav bar affiche `Bienvenue, [prénom]` (greeting Lora italique 11pt) + titre `Séances` (Lora 26pt)
**And** une seule action nav bar à droite : icône 📅 (calendrier — push `WeeklyCalendarView` placeholder en mode vide)
**And** une **hint italique Léon** (composant existant, fond `rgba(30,80,144,0.08)`, border-left 3px `#1E5090`) affiche un texte calibré sur l'autoprofil HK : *« Tu m'as dit reprise progressive — voici 3 pistes adaptées à ton profil HealthKit. »* — texte dérivé deterministically du `CoachingProfile.healthAutofill` (pas d'appel IA)
**And** une **hero card** gradient doré (`#D4A85A → #C09548`, border-radius 18px, padding 22×18) affiche : icône 🌱 + titre Lora « Prêt·e à commencer ? » + sous-titre DM Sans « Léon a préparé 3 programmes calibrés sur ton onboarding et tes données santé. »
**And** une section `SUGGESTIONS POUR TOI` affiche **exactement 3 templates** suggérés en **réutilisant le `ProgramTemplateSelector` (Story 3.2)** avec une nouvelle entrée `selectTopN(profile:n:) -> [ProgramTemplate]` : sélection deterministic des `n` meilleurs matches `level` autoprofil + sports déclarés onboarding, tie-break alphabétique sur `templateId`. **Pas de nouveau composant** — extension de Story 3.2.
**And** chaque card template a : icône sport + nom + tag durée (« 8 sem ») + 1 ligne descriptif + CTA « Voir → »
**And** un lien dashed bottom (« Tu veux autre chose ? **Crée un programme sur mesure →** ») ouvre la `RequestProgramSheet` (questionnaire universel Phase 2 #5)
**And** **aucune** section « Mes routines » ni « + ajouter routine » n'apparaît en mode vide (décision party #4 — A : jamais en mode vide)

**Acceptance Criteria — Mode actif multi-programmes (Sophie 3 progs triathlon)** :

**Given** un utilisateur avec ≥ 1 `AdaptedProgramRecord` actif
**When** il ouvre l'onglet Séances
**Then** la nav bar affiche `Bonjour [prénom],` + titre `Séances` + 2 icônes droite : 📅 + bouton primary `+` doré (`#D4A85A`)
**And** une section `PROCHAINE SÉANCE` affiche une **card dominante** gradient bleu coach (`#1E5090 → #2B5F8A`, border-radius 18px, padding 16px) calculée comme suit :
  - parcourir tous les `AdaptedProgramRecord` actifs
  - pour chaque, calculer la prochaine session non complétée (en mode `planned` = date posée ; en mode `ondemand` = la première session du pool)
  - retenir celle dont la date est la plus proche dans le futur (ou aujourd'hui)
  - en cas d'égalité (2 séances même jour) : retenir celle avec heure la plus proche, sinon ordre alphabétique sport
**And** la card affiche : label MAJ when/heure (« AUJOURD'HUI · 18:30 ») + titre Lora 19pt avec emoji sport + meta DM Sans 12pt (description séance) + CTA pill blanche « Démarrer la séance → »
**And** une section `MES PROGRAMMES` affiche **toutes** les cards programmes actifs, **triées par date de prochaine séance** (la plus proche en haut — décision party #3 — A)
**And** chaque card programme : icône sport (36×36 fond doré transparent) + nom + meta « Sem N · prochaine : [date courte] » + barre progression 4px doré + % à droite
**And** tap sur une card programme push vers `AdaptedProgramView` (master existant — réutilisé tel quel)
**And** si l'utilisateur a **exactement 1 programme actif**, le mode actif affiche en plus (décision party #2 — B+C combinés) :
  - un **mini-widget « Cette semaine »** (3 stats inline : volume, séances complétées, streak) dérivées de `WeeklyStatsService.computeCurrentWeek()` — composant nouveau, sync local, < 50ms
  - une **card secondaire « Et après »** sous la card prochaine séance (gradient plus pâle ou border simple), affichant la **2e** séance dans le futur (`Today + Tomorrow` style TrainingPeaks) — utilise le même composant que la card dominante, avec variante visuelle `compact: true`
**And** une section `MES ROUTINES` (si l'utilisateur a ≥ 1 `RoutineRecord`) liste les routines en pointillé (border dashed `#D4A85A`)
**And** une card dashed bottom `+ Créer une routine ou un programme` ouvre une bottom sheet « Programme / Routine »
**And** un lien CTA discret bas (`↻ Réorganiser ma semaine →`, fond `rgba(212,168,90,0.08)`, texte doré) ouvre la vue `WeeklyCalendarView` avec drag & drop hebdo (décision party #5 — A)

**Acceptance Criteria — Mode rest day (jour de récup)** :

**Given** un utilisateur avec ≥ 1 programme actif, et la prochaine session calculée tombe à `> J+0` (pas aujourd'hui)
**When** il ouvre l'onglet Séances
**Then** la card dominante est en variante **rest day** : gradient vert nature (`#7BC142 → #5A9A30`) au lieu de bleu coach
**And** label MAJ « RÉCUPÉRATION » + titre Lora « 🌿 Jour de récup » + meta « Hydrate-toi, marche tranquille, dors bien. Ton corps consolide. »
**And** un séparateur 1px blanc opacity 0.25 + ligne info bas : « ↗︎ Prochaine séance · [jour court] [heure] — [sport], [nom séance] »
**And** une hint italique Léon contextuelle (texte tiré de `CoachLineEngine.restDayHint(sessions: lastWeek)`) — pas un appel IA, calcul deterministic depuis l'historique séances locales
**And** sections `MES PROGRAMMES` et `MES ROUTINES` rendues à l'identique du mode actif
**And** le lien `↻ Réorganiser ma semaine →` reste visible

**Acceptance Criteria — Persistance & data model** :

**Given** la couche data CoachingSage actuelle (CoreProfileRepository + `AdaptedProgram` retourné par Story 3.3a, **uniquement en mémoire** — non persisté avant cette story)
**When** Story 3.8 est livrée
**Then** un nouveau `@Model AdaptedProgramRecord` SwiftData est **créé from-scratch** (pas de migration de données existantes — l'app pré-3.8 ne persistait pas les programmes adaptés). Champs : `id UUID, sportCode, level, templateId, adaptedAt Date, weekStartDate Date, mode: ProgramMode (.ondemand par défaut, .planned si l'utilisateur réorganise via drag&drop), sessionsJSON, completionStateJSON, isActive Bool, archivedAt Date?`
**And** un **bridge** est ajouté en sortie de Story 3.3a : après `ProgramAdapter.adapt(...)`, on convertit `AdaptedProgram` (struct mémoire) → `AdaptedProgramRecord` (SwiftData) et on persiste avec `isActive = true`. Les programmes pré-existants pré-3.8 sont perdus (acceptable : pas encore d'utilisateurs réels)
**And** un nouveau `@Model RoutineRecord` SwiftData persiste les routines (champs : id, name, durationMinutes, equipmentRequired array, createdAt, lastUsedAt) — composant **nouveau**
**And** un nouveau composant `SessionDashboardViewModel` (composant **nouveau**) charge les `AdaptedProgramRecord.isActive == true` + `RoutineRecord` au `onAppear` et observe les changements via `@Query`
**And** un nouveau composant `NextSessionResolver` (composant **nouveau**, sync local) implémente la sélection prochaine séance + tri (cf AC mode actif multi-prog)
**And** un nouveau composant `WeeklyStatsService` (composant **nouveau**) calcule volume / séances / streak sur la semaine courante (réutilisé par Story 3.9 avec extension period `month`/`quarter`)
**And** un nouveau composant `CoachLineEngine.restDayHint(sessions: [AdaptedProgramRecord]) -> String` (composant **nouveau**) calcule deterministically la phrase italique Léon en mode rest day depuis l'historique séances locales — pas d'appel IA
**And** un test paramétrique vérifie le tri prochaine séance (3 cas : toutes futures, 1 aujourd'hui + 1 demain, égalité même jour)
**And** un test vérifie le bascule mode-vide ↔ mode-actif quand `AdaptedProgramRecord.isActive` change
**And** un test vérifie la card rest day quand la prochaine séance est à J+1 ou plus

**Acceptance Criteria — Drag & drop calendrier hebdo** :

**Given** un utilisateur sur l'écran Séances en mode actif, qui tape `↻ Réorganiser ma semaine` ou l'icône 📅
**When** la `WeeklyCalendarView` s'ouvre
**Then** elle affiche une grille 7 jours × N programmes avec les sessions positionnées par date
**And** l'utilisateur peut **glisser une session** d'un jour à un autre (drag & drop natif SwiftUI iOS 17+ via `.draggable()` / `.dropDestination()`)
**And** le drop met à jour `AdaptedProgramRecord.sessionsJSON[i].plannedDate` + persiste en SwiftData
**And** **règle data model** : un programme nouvellement créé naît en `mode = .ondemand` (pool de séances non datées). Le **premier drop drag&drop** sur une session fait basculer le programme correspondant en `mode = .planned` + assigne `plannedDate` à la session déplacée (les autres sessions restent sans date jusqu'à ce qu'elles soient elles aussi déplacées). Pas de modal de confirmation — l'action de réorganiser EST la conversion. Le mode global `planned` (calendrier généré automatiquement par l'app) reste hors-scope, déféré au flux A/B.
**And** la vue est réutilisable depuis 3 entrées (décision party #5 amortissement) :
  1. Lien `Réorganiser ma semaine` depuis Séances
  2. Push depuis card programme dans `AdaptedProgramView`
  3. Icône 📅 nav bar Séances (mode global, agrège tous les progs)
**And** le composant est packagé dans `Views/Common/WeeklyCalendarView.swift` avec un `WeeklyCalendarMode` enum (`.singleProgram(id:)` / `.allActivePrograms`)
**And** **risque connu iOS 17** : `.dropDestination()` callback peut double-fire sur certaines versions early 17.x — vérifier sur iOS 17.4+, ajouter debounce 100ms si reproduit

**Pré-requis bloquants** :
- Phase 2 #5 mergée (questionnaire universel `epic-3/universal-questionnaire`, commit 17defa7) — nécessaire pour la `RequestProgramSheet`
- Décision data model `AdaptedProgramRecord` + `RoutineRecord` validée (cf flow A/B mémoire `epic3_flow_choice_AB.md`) — la story commence en mode `ondemand` par défaut, mode `planned` géré par story future « Flux A/B »

**Hors scope (déférés)** :
- Implémentation chat Léon dans le FAB (Story 3.6)
- Calculs perf complets HK pour widget « cette semaine » au-delà de volume/séances/streak (Story 3.9)
- Notif push « rappels de séances » paramètre profil (Story future, pattern Nathalie procrastination)
- Mode `planned` **global** (calendrier généré automatiquement à la création du programme) — déféré au flux A/B Story future. Story 3.8 ne livre que le **mode `planned` per-session** activé par drag&drop manuel.
- Synchronisation `AdaptedProgramRecord` ↔ Supabase (V1 = local-first)

**Effort estimé** : **7-8 jours** (révisé après review — 6-7j initial était optimiste, marge requise pour drag&drop iOS 17 et tests bascule modes) :
- Tab bar 3 onglets + FAB Léon (transposition `FloreFloatingButton`) : 0.5j
- Data model `AdaptedProgramRecord` + `RoutineRecord` SwiftData + bridge sortie 3.3a : 1j
- `SessionDashboardViewModel` + `NextSessionResolver` + tests paramétriques + tests bascule modes : 1.5j
- Extension `ProgramTemplateSelector.selectTopN()` + AC test : 0.25j
- Vue mode vide (hero + 3 templates suggérés + lien sur mesure) : 1j
- Vue mode actif multi-prog (cards dominante + programmes empilés + routines + replan) : 1.5j
- Variante rest day + `CoachLineEngine.restDayHint` + `WeeklyStatsService` + mini-widget + card « Et après » mode 1-prog : 1.25j
- `WeeklyCalendarView` drag & drop (3 entry points + bascule mode `.ondemand`→`.planned` per-session + risque dropDestination iOS 17) : 2-2.5j
- Tests unit + UI snapshot critiques + ui-reviewer (process livraison UI) : 0.5j

**Mitigation si dépassement effort** : virer le mini-widget « Cette semaine » du mode 1-prog (réinjecté via Story 3.9 qui le réutilise déjà) — économise ~0.5j.

### Story 3.9 : Onglet Progrès — agrégé multi-sport complet *(nouveau, ajouté 2026-05-07)*

As a utilisateur qui suit ≥ 1 programme,
I want voir un onglet Progrès qui me montre ma forme physique (HealthKit), mon volume par sport et mes records sur **un seul écran**,
So that je sois motivé visuellement par ma progression cross-disciplines (différenciateur vs Nike Training Club / Runna mono-sport).

**Contexte** : décision party 2026-05-07 #1 — Sophie tranche **Option A « Agrégé multi-sport complet »** plutôt que Option C hybride (reco initiale Léna). Justification user-first : les 4 personas demandent du visuel motivant (Sophie « progression 3 disciplines un seul écran », Maxime « courbe monter », Philippe « VMA et allure », Nathalie « kilos baisser et forme monter »). Maquette de référence : `ux-design-CoachingSage-progres-options-2026-05-07.html` (Option A + reco finale).

**Acceptance Criteria — Structure de l'écran** :

**Given** un utilisateur authentifié avec ≥ 1 `AdaptedProgramRecord` actif et permissions HK accordées (Story 2.1)
**When** il ouvre l'onglet Progrès
**Then** la nav bar affiche `Tes données` + titre `Progrès` + icône ⏱ à droite (sélecteur période)
**And** l'icône ⏱ ouvre une bottom sheet picker `Période` : `Cette semaine` (par défaut) · `Ce mois` · `3 derniers mois`
**And** le contenu est sectionné en 4 blocs verticaux dans cet ordre : `Cette semaine` (widget stats) · `Forme physique (HealthKit)` · `Volume par sport` · `Performances récentes`

**Acceptance Criteria — Bloc 1 : widget stats** :

**Given** la période sélectionnée
**When** l'écran charge
**Then** un widget 3 colonnes affiche : **Volume** (h/min calculé via `HKWorkoutType` agrégé sur la période) · **Séances** (count completion `AdaptedProgramRecord.completionStateJSON`) · **Streak** (jours consécutifs avec ≥ 1 séance, depuis le début) — chaque stat en chiffre Lora 22pt doré
**And** les unités sont localisées (« 3h12 » FR / « 3h12m » EN minimal — fallback sur `MeasurementFormatter`)
**And** le calcul est fait via `WeeklyStatsService` (composant Story 3.8) étendu pour gérer la période `month` / `quarter`

**Acceptance Criteria — Bloc 2 : Forme physique HealthKit** :

**Given** la story upstream `Story 3.9.0 — Extension HK auth` livrée (cf bloc dédié ci-dessous), donc lecture autorisée pour `HKQuantityType.restingHeartRate`, `HKQuantityType.heartRateVariabilitySDNN`, `HKCategoryType.sleepAnalysis`
**When** l'écran charge
**Then** une card blanche affiche 3 lignes (Fréquence cardiaque repos · Variabilité HRV · Sommeil), avec :
  - icône (❤️ / 📈 / 😴) + nom + meta « Moy. 7 derniers j »
  - valeur courante (e.g. `52`, `68`, `7h21`) en couleur bleu coach `#1E5090`
  - flèche delta vs période précédente (↑ vert `#7BC142` / ↓ rouge `#C0584F`) — calcul via `HKStatisticsCollectionQuery` sur deux fenêtres (J-7→J0 vs J-14→J-7)
**And** si une métrique HK est indisponible (permission refusée OU 0 sample sur la période — Apple ne distingue pas les deux côté READ), la ligne affiche état vide « — » + tooltip « Active dans Réglages > Santé » (pas d'erreur bloquante)
**And** **garde-fou EU MDR** : aucune valeur HK n'est interprétée en termes médicaux (pas de label « Fatigue », « Récupération mauvaise », etc.) — affichage neutre des chiffres uniquement
**And** un test unitaire vérifie le fallback complet HK indisponible (3 lignes en `—`)

**Acceptance Criteria — Story 3.9.0 (sous-story extraite, à livrer AVANT 3.9 pour débloquer le bloc 2)** :

**Given** l'app actuelle dont `HealthKitService.requestProfileAuthorization()` ne demande **PAS** `restingHeartRate`, `heartRateVariabilitySDNN`, `sleepAnalysis` (vérifié dans `Services/HealthKitService.swift` post-Story 2.1)
**When** Story 3.9.0 est livrée
**Then** `HealthKitService.requestProfileAuthorization()` étend la liste des `readTypes` HK avec les 3 nouveaux `HKObjectType` (RHR, HRV SDNN, Sleep Analysis)
**And** un nouveau flow `HealthKitService.requestProgressAuthorizationIfNeeded()` est ajouté : invoqué au premier `onAppear` de l'onglet Progrès, vérifie si l'extension a été demandée, sinon prompt iOS natif HK (HK ne distinguant pas refus historique vs jamais demandé, on stocke en `UserDefaults` un flag `progressHKRequestedAt: Date?` pour ne pas re-prompt en boucle)
**And** si l'utilisateur refuse → onglet Progrès s'affiche normalement avec les 3 lignes en `—` + bouton CTA « Active HealthKit dans Réglages » (deep link `UIApplication.openSettingsURLString`)
**And** test : utilisateur post-Story 2.1 sans permissions étendues → onglet Progrès propose le re-prompt → après acceptation, données chargent
**And** **effort 3.9.0 = 0.5j** (extension `readTypes` + flag UserDefaults + bouton deep-link Settings)

**Acceptance Criteria — Bloc 3 : Volume par sport** :

**Given** ≥ 1 sport pratiqué dans la période
**When** l'écran charge
**Then** une liste de `vol-row` (1 par sport actif dans la période, triées par volume desc) affiche : icône sport + nom + amount (h/min) + barre 6px gradient doré (largeur = ratio volume sport / volume max)
**And** seuls les sports avec ≥ 1 séance complétée dans la période sont affichés (pas de ligne « 0 min » polluante)
**And** le calcul agrège `HKWorkout` matchés sur le code sport mappé via un nouveau composant `SportCodeMapper.toHKWorkoutActivityType(SportCode) -> HKWorkoutActivityType` (composant **nouveau**, table de mapping pour les 10 SportCode iOS)
**And** un test paramétrique sur 3 cas : 1 sport, 3 sports, 0 sport (état vide → bloc masqué)

**Acceptance Criteria — Bloc 4 : Performances récentes** :

**Given** ≥ 1 PR (personal record) détecté sur la période
**When** l'écran charge
**Then** une `pr-card` (gradient doré + vert très transparent) affiche : emoji 🏅 + tag MAJ « RECORD » + texte description « Tu as battu ton allure 5K natation cette semaine — 1:48/100m. »
**And** la détection PR est faite par un nouveau composant `PersonalRecordsEngine.detectRecent(period:) -> [PRRecord]` (composant **nouveau**) qui compare contre l'historique `AdaptedProgramRecord.completionStateJSON.metrics`
**And** **maximum 3 PR cards** affichées (les 3 plus récents) — pas de liste infinie
**And** si aucun PR détecté → bloc masqué (pas de message « Pas de records » qui démotive)
**And** un test vérifie : utilisateur sans historique → bloc absent ; utilisateur avec 5 PR → 3 cards affichées

**Acceptance Criteria — État vide global (Nathalie 0 prog)** :

**Given** un utilisateur sans aucun `AdaptedProgramRecord`
**When** il ouvre l'onglet Progrès
**Then** l'écran affiche un état vide bienveillant : icône 📊 + titre Lora « Bientôt tes progrès » + sous-titre « Démarre un programme depuis l'onglet Séances et Léon te montrera tes statistiques ici. »
**And** un CTA discret « ← Retour aux Séances » re-bascule sur l'onglet Séances

**Acceptance Criteria — Performance & permissions** :

**Given** l'écran Progrès en mode actif
**When** il charge
**Then** le rendu initial < 200ms (chargement des SwiftData locaux)
**And** les charts HK chargent en différé (loader Skeleton jusqu'à `HKStatisticsCollectionQuery` complète, < 2s P90)
**And** si HK non autorisé : bouton « Activer HealthKit » ouvre `Settings.app` ou bottom sheet onboarding HK
**And** un test perf snapshot vérifie le scroll fluide (60fps) sur un user avec 50 séances historiques

**Pré-requis bloquants** :
- Story 3.8 livrée (tab bar 3 onglets + FAB Léon + persistance `AdaptedProgramRecord`)
- **Story 3.9.0 livrée** (extension HK auth RHR/HRV/Sleep — cf bloc dédié dans cette story) — **trou P0 corrigé 2026-05-07** : `HealthKitService.requestProfileAuthorization()` post-Story 2.1 ne couvre PAS ces 3 types, il faut étendre AVANT 3.9 sinon `HKStatisticsCollectionQuery` retournera 0 sample silencieusement
- `HealthKitService` (AppDependencies, ajouté Story 2.1) étendu avec **3 nouveaux composants** : `fetchRestingHR(period:)`, `fetchHRV(period:)`, `fetchSleep(period:)` (composants **nouveaux**)
- Composants **nouveaux** créés dans cette story : `SportCodeMapper`, `PersonalRecordsEngine`, `ProgressViewModel`, extension `WeeklyStatsService` (period `month`/`quarter`)

**Hors scope (déférés Phase 3)** :
- Charts détaillés par sport (courbe VMA running, FTP cycling, CSS natation) → Story future
- Comparaison cross-users / leaderboards → jamais (positionnement CoachingSage)
- Export PDF/CSV des progrès → Story future
- Sync HK depuis Apple Watch en temps réel pendant séance → géré par Epic 4 tracking

**Effort estimé** : **4.5-5.5 jours** détaillés (révisé après review — +0.5j Story 3.9.0 extension auth) :
- **Story 3.9.0 — Extension HK auth RHR/HRV/Sleep + flow re-prompt** : 0.5j
- `HealthKitService` extensions RHR/HRV/Sleep + `HKStatisticsCollectionQuery` deux-fenêtres : 1.5j
- `PersonalRecordsEngine` + `SportCodeMapper` (detect + tests sur historique completion) : 1j
- `ProgressView` (4 blocs + sélecteur période + état vide + extension `WeeklyStatsService`) : 1.5j
- Tests + ui-reviewer (process livraison UI) + perf snapshot : 0.5j

## Couverture des FRs avec le nouveau découpage

| FR original | Couvert par |
|---|---|
| FR9 bouton Léon flottant | Story 3.6 |
| FR10 conversation naturelle | Story 3.6 |
| FR11 génération programme | Stories 3.2 + 3.3a (template + algo adapt, hot path gratuit) ; 3.3b si raffinement IA ; 3.5 (cas edge Pro) |
| FR12 adaptation temps réel | Story 3.6 (mode adapt-session, IA, quota partagé) |
| FR13 réorganisation séances manquées | Story 3.4 (regen hebdo, Léon+) |
| FR14 nouveau programme fin de cycle | Story 3.4 (regen étendue) ou Story 3.3a (re-adapt algo) |
| FR15 questions exercices/techniques | Story 3.6 |
| FR16 contexte historique | Toutes les stories Léon IA (inclus dans chaque appel 3.3b/3.4/3.5/3.6) |
| FR17 programmes publics tiers | Story 3.5 (Léon Pro uniquement) |
| FR18 10+ sports | Epic 0.5 (templates 10 sports post-Story 0.5.10) + Story 3.1 (SportQuestionnaires) |
| FR19 multi-discipline | Epic 0.5 (templates triathlon/combinés) |
| FR20 programmes ciblés | Story 3.5 (cas edge généralisé) |
| FR21 ultra-progressif débutant | Epic 0.5 (templates débutant) + Story 3.3a (adaptation algo) |
| FR22 détail exercices | Epic 0.5 (templates avec hooks metadata Story 0.5.9) + Story 3.3a (patch deterministic) |
| FR23 équipement pris en compte | Story 3.1 (collecté) + Story 3.3a (appliqué via algo) |
| FR24 contraintes physiques | Story 3.1 (collecté) + Story 3.3a (substitutions deterministic) ; 3.3b en fallback |
| FR57 Léon bilingue | Stories 3.1, 3.3b, 3.4, 3.5, 3.6 (xcstrings + system prompt i18n) |

**→ 100% des FRs de l'ancien Epic 3 sont couverts par la nouvelle version.**

---

# Challenge Pipeline — Validation qualité à 3 niveaux *(nouveau)*

**Problème** : on ne peut pas valider la qualité des programmes par des tests unitaires classiques. Sophie n'est pas experte sport à 100%. Les templates et adaptations peuvent contenir des erreurs subtiles (volumes, sécurité, cohérence) invisibles sans œil expert.

**Solution** : un pipeline de validation qui utilise Claude lui-même comme critic, à **3 moments distincts**.

## Niveau 1 — Validation initiale des templates (Epic 0.5)

**Quand** : Avant que le bundle app final inclue un template.
**Moment** : Stories 0.5.3 (auto-critique) et 0.5.4 (révision).

**Process** :
1. Template généré par Léon (mode generate)
2. Re-prompt Claude : "Tu es un coach sportif rigoureux. Voici un programme pour [sport] [niveau]. Liste TOUS les problèmes : volumes inadaptés, incohérences physiologiques, exercices risqués, progression illogique, ambiguïtés, équipements implicites non déclarés. Sois impitoyable."
3. Si critique = vide ou uniquement cosmétique → template PASS
4. Si problèmes critiques → Léon révise (avec le feedback), nouvelle passe
5. Max 3 itérations, puis escalade manuelle
6. Sophie relit tous les templates finaux (Story 0.5.6)

**Outputs** :
- `Results/challenge_<template-id>.md` par template
- `_challenge_summary.md` agrégé (pass / fail / escalated)

## Niveau 2 — Challenge périodique en beta (avant release V1)

**Quand** : Pendant la phase beta (TestFlight interne/externe), avant la release publique.
**Fréquence** : Hebdomadaire, échantillonnage aléatoire.

**Process** :
1. Échantillonner 10-20% des adaptations produites dans la semaine écoulée (via `ai_usage_logs`)
2. Pour chaque : re-prompter Claude avec le template original + le profil + le patch produit + "Ce patch est-il cohérent et sécurisé ? Identifie tout problème."
3. Score de 1 à 5 + problèmes détectés
4. Dashboard Sophie : liste des adaptations problématiques avec sport / template / user (anonymisé)
5. Si pattern identifié (ex: "les adaptations running sur contrainte genou oublient systématiquement X") → amélioration du system prompt de Léon ou du template source

**Outputs** :
- Script Python/Swift dans `coachingsage/scripts/challenge-adaptations.py`
- Rapport hebdo automatique envoyé par email
- Issues Linear / GitHub créées automatiquement pour les cas `score < 3`

## Niveau 3 — Monitoring continu en production

**Quand** : Post-release V1, en continu.
**Fréquence** : Échantillonnage 1-5% en prod.

**Process** :
1. L'Edge Function `sage-coaching-ai` tire au sort 1-5% des adaptations, les met en queue `adaptation_reviews`
2. Un job cron Supabase exécute le re-challenge toutes les heures
3. Les résultats alimentent un dashboard de qualité continue (vue Supabase)
4. Alertes automatiques si score moyen < 3.5 ou taux d'erreurs > 5% sur une fenêtre 24h

**Outputs** :
- Edge Function `challenge-adaptation` (Supabase)
- Table `adaptation_reviews` avec colonnes : adaptation_id, score, issues, created_at
- Vue materialized `quality_metrics_weekly` (Postgres)
- Alertes email / Slack

## Budget coût du challenge pipeline

| Niveau | Fréquence | Volume annuel | Coût annuel estimé |
|---|---|---|---|
| N1 templates (one-shot) | 1× | ~150 calls | ~$3 |
| N2 beta hebdo | 52 semaines | ~5 000 calls | ~$25 |
| N3 prod continu (1% sample à 100k users) | 365 jours | ~365 000 calls | ~$1 800 |

**Total : ~$1 830/an** pour un pipeline qualité sur 100k users. Très rentable.

## Story dédiée pour la build du pipeline

### Story de support 0.5.X : Challenge Pipeline N1 (dans Epic 0.5)
Déjà couverte par 0.5.3, 0.5.4, 0.5.5.

### Nouvelle story dans Epic 3 : Story 3.7 — Challenge Pipeline N2 + N3

As Sophie (product owner),
I want un pipeline de validation qualité continue sur les adaptations Léon,
So que je détecte rapidement les dérives et améliore les prompts/templates en conséquence.

**Acceptance Criteria** :

- Script local `challenge-adaptations-beta.swift` pour phase beta (N2)
- Edge Function Supabase `challenge-adaptation` + table `adaptation_reviews` pour prod (N3)
- Job cron horaire qui vide la queue
- Dashboard simple (vue Postgres + page statique dans l'admin) affichant : score moyen, taux d'erreur, top issues
- Alertes email/Slack sur seuils dégradés

**Note** : cette story est **non bloquante** pour Epic 1 → Epic 2. Elle peut être livrée pendant Epic 3 lui-même ou juste après.

---

# NFRs révisées suite au spike 0.3

| ID | Ancienne cible | **Nouvelle cible réaliste** | Mesuré | Statut |
|---|---|---|---|---|
| NFR1 (génération programme) | < 5s | **Supprimée** (remplacée par NFR1a-f ci-dessous) | — | Révisé |
| NFR1a — **Adaptation algo deterministic** (Story 3.3a, hot path gratuit) | — | **< 200ms** (P95, sync local) | (à mesurer) | nouveau 2026-04-29 |
| NFR1b — Adaptation IA fallback (Story 3.3b, cas atypiques) | — | **< 30s** (P90) | 12.5-30s (cf. spike 0.3) | ✅ |
| NFR1c — Adaptation template complexe IA | — | **< 45s** (P95) | 30.5s | ✅ |
| NFR1d — Génération from-scratch skeleton (Léon Pro) | — | **< 90s** | 45-74s | ✅ |
| NFR1e — Regen hebdo | — | **< 30s** | (non mesuré, estimé < 30s) | à valider |
| NFR1f — Question ad-hoc Léon | — | **< 10s** (P90) | (non mesuré) | à valider |

**Règle UX associée** : toute opération Léon de plus de 3 secondes DOIT afficher un indicateur visuel ("Léon réfléchit...", "Léon personnalise ton programme...") avec une estimation de durée si possible.

---

# Impact sur les autres Epics (mineur)

- **Epic 1** : inchangé (foundation + auth)
- **Epic 4** (tracking) : inchangé
- **Epic 5** (progression) : inchangé
- **Epic 6** (adaptation dynamique) : **partiellement absorbé par Epic 3** (regen hebdo = story 3.4, adaptation temps réel = story 3.6). À réécrire légèrement pour retirer les redondances.
- **Epic 7** (HealthKit) : inchangé (pré-remplissage Story 2.1 mentionné)
- **Epic 8** (notifications) : inchangé
- **Epic 9** (localisation) : inchangé
- **Nouvel Epic à créer** : **Epic 10 — Monétisation Léon Pro** (miroir Epic 17 Flore, à planifier parallèlement à Epic 3 ou juste après)

---

# Ordre d'exécution recommandé

**Ordre original (avant pivot 2026-04-29)** :
1. Review et validation de cette proposition par Sophie ← validé partiellement
2. Mise à jour officielle de `epics-CoachingSage.md` avec Epic 0.5, Epic 2 réécrit, Epic 3 réécrit
3. Mise à jour du PRD (NFRs révisées, FR17/FR19/FR20/FR21 reliés à la nouvelle architecture)
4. Mise à jour de `architecture-CoachingSage.md` (schéma 3 couches, AdaptationPatch, ProgramTemplate data model)
5. Spike 0.2 HealthKit *(en parallèle d'Epic 0.5)*
6. Spike 0.1 GPS *(en parallèle d'Epic 0.5)*
7. Epic 0.5 — création + challenge + validation des templates (asset critique prêt avant Epic 1 code)
8. Epic 1 — Foundation & Auth
9. Epic 2 — Onboarding Core
10. Epic 3 — SportQuestionnaire + Templates + Adaptation + Chat
11. Epic 10 — Monétisation Léon Pro
12. Epics 4-9 (ordre inchangé)

**État au 2026-04-29** : Epic 0 (spikes), Epic 0.5 (0.5.1→0.5.7), Epic 1, Epic 2, Story 3.1 sont **livrés et mergés sur main**. La suite à dérouler avec le pivot algo-first :

1. **Story 0.5.8** — Renaming structurel pur (enum Sport+Level EN, JSON files renommés, manifest, archive sports_collectifs ET remise_en_forme) → 31 templates renommés, 1 jour
2. **Story 0.5.10** *(absorbe 0.5.9)* — Regen qualité sport-spécifique 40 templates avec hooks metadata Story 0.5.9 inclus, prompt master par sport, revue agent — pré-requis algo deterministic
3. **Doctrine doc** : `_bmad-output/planning-artifacts/leon-algo-doctrine-by-sport.md` (formules + règles substitution + périodisation par sport, sources publiques citées) — démarré en parallèle de 0.5.10 (les prompts master en sont l'extraction)
4. **Story 3.2** — ProgramTemplateSelector (jamais nil après 0.5.10 ; couverture structurelle dès 0.5.8)
5. **Story 3.3a** — Adaptation algo deterministic (cœur free tier illimité)
6. **Story 3.3b** — Adaptation IA fallback (rate-limité 10/j cumulé)
7. **Story 3.8** — Refonte SessionView dashboard Séances *(ajouté 2026-05-07, party design)* — 7-8j (révisé après review : marge requise drag&drop iOS 17 et tests bascule modes), débloque le différenciateur multi-prog visible et la nav 3 onglets + FAB Léon
8. **Story 3.9.0** — Extension HK auth RHR/HRV/Sleep *(ajouté 2026-05-07 review)* — 0.5j, débloque Story 3.9
9. **Story 3.9** — Onglet Progrès Option A *(ajouté 2026-05-07)* — 4-5j, dépend Story 3.8 + 3.9.0
10. **Story 3.6** — Questions ad-hoc + adapt-session (FR12, IA, même quota) — débloquée par FAB Léon Story 3.8
11. **Story 3.7** — Challenge Pipeline N2/N3
12. **Story 3.4** — Regen hebdo Léon+
13. **Story 3.5** — From-scratch Pro (FR17)
14. **Story 3.1.5** — HealthKit pre-fill Q1 niveau (idée Sophie 2026-04-29, +0.5j) — peut être glissée entre 3.3a et 3.3b si HK estimation level débloque pacing 3.3a
15. **Epic 10** — Monétisation Léon Pro
16. **Epics 4-9** (ordre inchangé)

---

# Questions ouvertes pour Sophie

**Tranchées 2026-04-29** :
1. ✅ Architecture 3 couches + Epic 0.5/2/3 (validé, livré pour 0/0.5/1/2/3.1)
2. ✅ Challenge Pipeline 3 niveaux (validé)
3. ✅ Tarifs Léon+ / Pro / Pack 50 (validés, miroir Flore)
5. ✅ Ordre 0.5 → 1 → 2 → 3 (validé, suivi)
6. ✅ Taxonomie questions sport story-par-story (suivi sur Story 3.1 Running)

**Ouvertes** :
4. **Coach référent humain** pour relire templates (Story 0.5.6, et 0.5.8 nouveaux templates) ? Sophie a flagué "Clément ?" sur certains sports — décision toujours pendante.
7. *(nouveau)* **Doctrine algo deterministic** : on rédige les 4 sports prioritaires (running / cycling / swimming / strengthTraining) en un seul doc avant de commencer le code 3.3a, ou on déroule sport-par-sport (running first, autres au fil) ?
8. *(nouveau)* **`Sport` enum interne** : on renomme aussi en `SportCode` aligné iOS (anglais) **OU** on garde les noms français internes (`velo`, `natation`, `musculation`) avec un mapping ? Mon avis : **renommer** pour éliminer toute classe de bug de mapping.
9. *(nouveau)* **`triathlon-beginner`** : on génère un template "Découverte multidiscipline" (8 sem, 1 séance par discipline alternées + 1 session brick) **OU** on accepte qu'un débutant en triathlon parte sur 3 templates beginner indépendants (running + cycling + swimming) ? Mon avis : **template Découverte** pour offrir une expérience triathlon-native dès débutant.

---

**Pivot 2026-04-29 validé. Prochaine action côté code = Story 0.5.8 (alignement enum + complétion library) avant Story 3.2.**
