---
stepsCompleted: ['step-01', 'step-02', 'step-03', 'step-04']
status: partial-revision-2026-04-06
completedAt: '2026-03-22'
revisedOn: '2026-04-06'
inputDocuments:
  - "prd-CoachingSage.md"
  - "architecture-CoachingSage.md"
project_name: CoachingSage
---

# CoachingSage - Epic Breakdown

> ## ⚠️ RÉVISION MAJEURE 2026-04-06 — sections obsolètes
>
> Suite au spike 0.3 Léon (validation qualité OK, mais NFR1 < 5s irréaliste et coût intenable à scale), une **réécriture des Epics 0, 2 et 3** a été actée.
>
> **La source de vérité pour Epics 0 / 2 / 3 est maintenant** :
> 👉 [`epics-CoachingSage-v2-proposal.md`](epics-CoachingSage-v2-proposal.md)
>
> Le proposal v2 contient :
> - **Nouvel Epic 0.5** — Template Library Creation & Validation (38 templates pré-générés + Challenge Pipeline qualité)
> - **Epic 2 simplifié** : 2 stories au lieu de 3 (onboarding minimal 60s, détail par sport déporté en Epic 3)
> - **Epic 3 restructuré** : 6 stories autour de l'architecture 3 couches (SportQuestionnaire local + ProgramTemplateSelector + Adaptation patch Léon + Regen Léon+ + Génération Léon Pro + Chat ad-hoc)
> - **Story 1.5** à ajouter à Epic 1 (Analytics & Funnel measurement, garde-fou business)
> - **Story 3.3.1** soft paywall contextuel (garde-fou business)
> - **Challenge Pipeline qualité** à 3 niveaux (validation initiale templates / beta sample / monitoring prod continu)
> - **NFR1 révisée** : suppression de "< 5s", remplacée par NFR1a-e mesurés réalistes (< 20s adapt simple, < 45s adapt complexe, < 90s génération from-scratch)
> - **Pricing révisé** : Léon+ 4,99€ / Léon Pro 12,99€ / Pack 50 questions 1,99€ (au lieu de 2,99€ / 9,99€)
>
> **Sections de ce fichier qui restent valables sans modification** :
> - Epic 1 (Foundation & Auth) — sauf ajout Story 1.5 Analytics
> - Epic 4 (Tracking)
> - Epic 5 (Suivi de progression)
> - Epic 6 (Adaptation dynamique) — partiellement absorbé par Epic 3 v2, à dépolluer plus tard
> - Epic 7 (HealthKit)
> - Epic 8 (Notifications)
> - Epic 9 (Localisation)
>
> **Sections de ce fichier OBSOLÈTES — voir le proposal v2** :
> - ❌ Epic 0 (Spike Technique) → spike 0.3 terminé, voir `Spike/Leon/Results/spike-0.3-v2-findings.md`
> - ❌ Epic 2 (Onboarding & Profil Sportif)
> - ❌ Epic 3 (Léon IA & Génération de Programmes)
>
> **Date de propagation complète** : à faire en session dédiée (édition chirurgicale d'un fichier de 800 lignes, à isoler).

## Overview

This document provides the complete epic and story breakdown for CoachingSage, decomposing the requirements from the PRD and Architecture requirements into implementable stories.

## Requirements Inventory

### Functional Requirements

**1. Profil & Onboarding (8 FRs)**
- FR1: L'utilisateur peut créer un profil sportif avec ses données personnelles (âge, poids, taille, sexe)
- FR2: L'utilisateur peut sélectionner un ou plusieurs sports pratiqués parmi 10+ disciplines
- FR3: L'utilisateur peut déclarer son niveau par sport (débutant, intermédiaire, avancé, expert)
- FR4: L'utilisateur peut définir ses objectifs (perte de poids, prise de masse, performance, bien-être, préparation compétition)
- FR5: L'utilisateur peut déclarer son équipement disponible (salle, maison, extérieur, piscine, matériel spécifique)
- FR6: L'utilisateur peut déclarer ses contraintes physiques (blessures, douleurs, limitations)
- FR7: L'utilisateur peut définir sa fréquence d'entraînement souhaitée et ses disponibilités
- FR8: L'utilisateur peut modifier son profil à tout moment

**2. Léon IA Conversationnel (9 FRs)**
- FR9: L'utilisateur peut accéder à Léon via un bouton flottant global depuis n'importe quel écran
- FR10: L'utilisateur peut converser avec Léon en langage naturel (FR et EN)
- FR11: Léon peut générer un programme d'entraînement personnalisé à partir du profil utilisateur
- FR12: Léon peut adapter une séance en temps réel sur demande ("j'ai mal au genou", "je suis fatigué")
- FR13: Léon peut réorganiser le programme de la semaine quand des séances sont manquées
- FR14: Léon peut proposer un nouveau programme à la fin d'un cycle terminé
- FR15: Léon peut répondre à des questions sur les exercices, les techniques et la progression
- FR16: Léon conserve le contexte de l'historique utilisateur (profil, programmes passés, progression, blocages)
- FR17: Léon peut générer des programmes pour des publics tiers (élèves, équipe) sur description de l'utilisateur

**3. Génération de Programmes (7 FRs)**
- FR18: Le système peut générer des programmes pour 10+ sports
- FR19: Le système peut générer des programmes combinés multi-discipline (triathlon, biathlon)
- FR20: Le système peut générer des programmes ciblés sur une technique spécifique
- FR21: Le système peut générer des programmes ultra-progressifs pour débutants totaux
- FR22: Chaque programme généré inclut : exercices détaillés, séries/répétitions ou durée, temps de repos, progression sur N semaines
- FR23: Les programmes tiennent compte de l'équipement disponible déclaré
- FR24: Les programmes tiennent compte des contraintes physiques déclarées

**4. Tracking en Séance (6 FRs)**
- FR25: L'utilisateur peut lancer un tracking GPS pour les sports d'endurance
- FR26: L'utilisateur peut enregistrer ses séries, répétitions et poids pour la musculation
- FR27: L'utilisateur peut utiliser un chronomètre et des intervalles pour les séances temporisées
- FR28: L'utilisateur peut enregistrer son effort perçu (RPE) après chaque séance
- FR29: L'interface de tracking s'adapte au type de sport en cours
- FR30: Le tracking fonctionne en mode offline

**5. Suivi de Progression (6 FRs)**
- FR31: L'utilisateur peut consulter son historique complet de séances
- FR32: L'utilisateur peut visualiser sa progression via des graphiques
- FR33: L'utilisateur peut consulter ses records personnels par exercice et par sport
- FR34: L'utilisateur peut visualiser des tendances sur 4, 8 et 12 semaines
- FR35: Le système détecte et signale les progressions et les stagnations
- FR36: Le système calcule le taux de complétion du programme en cours

**6. Adaptation Dynamique (4 FRs)**
- FR37: Le système détecte les séances manquées et ajuste automatiquement le programme
- FR38: L'utilisateur peut signaler une fatigue ou une douleur et recevoir un programme adapté
- FR39: Le système ajuste la charge d'entraînement en fonction de la progression réelle
- FR40: Le système propose des exercices alternatifs en cas de contrainte nouvelle

**7. HealthKit & Données Externes (6 FRs)**
- FR41: Le système peut lire les données HealthKit de toutes les sources
- FR42: Le système utilise les données HealthKit pour enrichir le suivi
- FR43: L'iPhone seul (sans montre) fournit des données de base (podomètre, distance, escaliers)
- FR44: L'utilisateur peut exporter ses séances vers Strava
- FR45: Le système écrit les données d'entraînement dans Apple Health
- FR46: L'export Strava s'exécute automatiquement au retour en ligne si fait offline

**8. Notifications & Engagement (4 FRs)**
- FR47: L'utilisateur peut recevoir des rappels avant ses séances programmées
- FR48: Léon peut envoyer des notifications proactives après une période d'inactivité
- FR49: Le système notifie l'utilisateur quand un record personnel est battu
- FR50: L'utilisateur peut configurer ses préférences de notification

**9. Authentification & Données (5 FRs)**
- FR51: L'utilisateur peut se connecter via Sign in with Apple
- FR52: L'utilisateur peut se connecter via email/password
- FR53: Les données utilisateur sont synchronisées entre iPhone et cloud (Supabase)
- FR54: L'utilisateur peut supprimer son compte et toutes ses données (RGPD)
- FR55: L'utilisateur peut utiliser l'app en mode offline avec synchronisation au retour en ligne

**10. Localisation (2 FRs)**
- FR56: L'app est disponible en français et en anglais
- FR57: Léon communique dans la langue choisie par l'utilisateur

### NonFunctional Requirements

- NFR1: Génération programme par Léon < 5 secondes
- NFR2: Lancement tracking en séance < 1 seconde
- NFR3: Acquisition GPS (premier fix) < 10 secondes
- NFR4: Affichage graphiques progression < 2 secondes
- NFR5: Export Strava < 3 secondes
- NFR6: Écriture Apple Health en temps réel
- NFR7: Démarrage app (cold start) < 3 secondes
- NFR8: Données santé HealthKit — accès uniquement aux types déclarés, consentement explicite
- NFR9: HTTPS/TLS pour toutes les communications
- NFR10: SwiftData chiffré par défaut (iOS Data Protection)
- NFR11: RGPD — droit à l'oubli < 30 jours (pg_cron purge)
- NFR12: RGPD — consentement analytics explicite à l'onboarding
- NFR13: Tokens/secrets jamais dans le code — xcconfig + .gitignore
- NFR14: Disclaimer médical affiché à l'onboarding et accessible dans les paramètres
- NFR15: Tracking GPS sans crash 100%
- NFR16: Zéro perte de données de séance
- NFR17: Disponibilité Léon > 99% (dégradation gracieuse)
- NFR18: Sync offline → online sans aucune perte

### Additional Requirements

**Architecture — Setup & Infrastructure :**
- Sage App Blueprint : création projet Xcode manuelle, Bundle ID `com.sopddl.coachingsage.app`, ajout au CL3.xcworkspace
- SageCore local SPM dependency — fichiers COPIE IDENTIQUE : SageCoreProfile, PendingOperation, AuthService, AuthView, AuthViewModel, CoreProfileRepository, Color+Sage, SyncService
- Supabase projet dédié `sagecoach-dev` (EU Frankfurt) — tables core_profiles, coaching_profiles, programs, program_weeks, sessions, session_results, personal_records
- RLS sur toutes les tables : `auth.uid() = core_profile_id`
- Script check-copie-identique.sh : ajouter CoachingSage dans le tableau APPS
- App Group : `group.com.sopddl.coachingsage.shared`
- xcconfig Debug/Staging/Release + .gitignore

**Architecture — Léon IA :**
- Edge Function `sage-coaching-ai` pour Léon IA (Claude API)
- Un seul prompt système + sport/profil en paramètre dynamique (pas N prompts par sport)
- Contexte envoyé à Léon : profil complet, programme en cours, séance actuelle, historique progression, contraintes

**Architecture — Tracking :**
- TrackingEngine protocol (Strategy pattern) avec 4 implémentations : EnduranceTrackingEngine, StrengthTrackingEngine, IntervalTrackingEngine, SimpleTrackingEngine
- SessionResult.trackingData = JSON polymorphe selon le sport
- CoreLocation background mode — spike Epic 0 requis (prérequis bloquant)

**Architecture — Intégrations externes :**
- HealthKitService protocol : lecture toutes sources + écriture workouts
- StravaExportService protocol : OAuth2 + export activité, enqueue PendingOperation si offline
- HealthKit entitlements — review Apple spécifique
- Strava API — OAuth2, rate limits, format activité spécifique

**Architecture — Data Model :**
- Sport = enum Swift (offline-friendly, nouveau sport = maj app)
- Program → ProgramWeek → Session → SessionResult (hiérarchie)
- PersonalRecord entité séparée
- CoachingProfile 1:1 avec SageCoreProfile
- Toutes entités : soft delete + pg_cron purge 30j

**Architecture — UI :**
- TabView 4 onglets : Aujourd'hui, Séance, Progrès, Profil + bouton flottant Léon global
- Swift Charts framework pour graphiques progression
- Palette couleurs `Color+Coaching.swift` — à définir (ni vert/GardenSage, ni prune/TailorSage)
- Notifications locales (rappels séances) + push (APNs)

**Architecture — Spike Epic 0 (prérequis bloquant) :**
- CoreLocation GPS background : batterie, précision, crash-free
- HealthKit lecture toutes sources (Apple Watch, Garmin, iPhone seul)
- Qualité programmes Léon : générer 10 programmes pour 5 sports, faire valider

### FR Coverage Map

| FR | Epic | Description |
|---|---|---|
| FR1 | Epic 2 | Profil sportif — données personnelles |
| FR2 | Epic 2 | Sélection sports |
| FR3 | Epic 2 | Niveau par sport |
| FR4 | Epic 2 | Objectifs |
| FR5 | Epic 2 | Équipement disponible |
| FR6 | Epic 2 | Contraintes physiques |
| FR7 | Epic 2 | Fréquence et disponibilités |
| FR8 | Epic 2 | Modification profil |
| FR9 | Epic 3 | Bouton flottant Léon |
| FR10 | Epic 3 | Conversation langage naturel |
| FR11 | Epic 3 | Génération programme personnalisé |
| FR12 | Epic 6 | Adaptation séance temps réel |
| FR13 | Epic 6 | Réorganisation semaine (séances manquées) |
| FR14 | Epic 3 | Proposition nouveau programme fin de cycle |
| FR15 | Epic 3 | Questions exercices/techniques/progression |
| FR16 | Epic 3 | Contexte historique utilisateur |
| FR17 | Epic 3 | Programmes pour publics tiers |
| FR18 | Epic 3 | Programmes 10+ sports |
| FR19 | Epic 3 | Programmes combinés multi-discipline |
| FR20 | Epic 3 | Programmes ciblés technique |
| FR21 | Epic 3 | Programmes ultra-progressifs débutants |
| FR22 | Epic 3 | Exercices détaillés, séries, repos, progression |
| FR23 | Epic 3 | Prise en compte équipement |
| FR24 | Epic 3 | Prise en compte contraintes physiques |
| FR25 | Epic 4 | Tracking GPS endurance |
| FR26 | Epic 4 | Enregistrement séries/reps/poids |
| FR27 | Epic 4 | Chronomètre et intervalles |
| FR28 | Epic 4 | Effort perçu (RPE) |
| FR29 | Epic 4 | Interface adaptée au sport |
| FR30 | Epic 4 | Tracking offline |
| FR31 | Epic 5 | Historique complet séances |
| FR32 | Epic 5 | Graphiques progression |
| FR33 | Epic 5 | Records personnels |
| FR34 | Epic 5 | Tendances 4/8/12 semaines |
| FR35 | Epic 5 | Détection progressions/stagnations |
| FR36 | Epic 5 | Taux de complétion programme |
| FR37 | Epic 6 | Détection séances manquées + ajustement |
| FR38 | Epic 6 | Signalement fatigue/douleur → adaptation |
| FR39 | Epic 6 | Ajustement charge selon progression |
| FR40 | Epic 6 | Exercices alternatifs contrainte nouvelle |
| FR41 | Epic 7 | Lecture HealthKit toutes sources |
| FR42 | Epic 7 | HealthKit enrichit le suivi |
| FR43 | Epic 7 | iPhone seul (podomètre, distance) |
| FR44 | Epic 7 | Export séances vers Strava |
| FR45 | Epic 7 | Écriture Apple Health |
| FR46 | Epic 7 | Export Strava auto retour online |
| FR47 | Epic 8 | Rappels séances programmées |
| FR48 | Epic 8 | Notifications proactives Léon |
| FR49 | Epic 8 | Notification record personnel |
| FR50 | Epic 8 | Préférences notification |
| FR51 | Epic 1 | Sign in with Apple |
| FR52 | Epic 1 | Email/password |
| FR53 | Epic 1 | Sync iPhone ↔ cloud |
| FR54 | Epic 1 | Suppression compte RGPD |
| FR55 | Epic 1 | Mode offline + sync |
| FR56 | Epic 9 | App FR + EN |
| FR57 | Epic 3 | Léon bilingue |

**57/57 FRs couverts.**

## Epic List

### Epic 0 : Spike Technique
Valider les 3 risques techniques majeurs avant de s'engager sur le scope V1 : CoreLocation GPS background (batterie, précision, crash-free), HealthKit lecture/écriture (toutes sources), qualité programmes Léon (10 programmes × 5 sports).
**FRs couverts :** Aucun directement — validation de faisabilité

### Epic 1 : Foundation & Authentification
L'utilisateur peut installer l'app, créer un compte (Apple Sign In ou email) et se connecter. Ses données se synchronisent entre iPhone et cloud. Le squelette de l'app (TabView 4 onglets) est en place.
**FRs couverts :** FR51, FR52, FR53, FR54, FR55

### Epic 2 : Onboarding & Profil Sportif
L'utilisateur peut créer son profil sportif complet (sports, niveaux, objectifs, équipement, contraintes, fréquence) et le modifier à tout moment. Disclaimer médical et consentement RGPD inclus.
**FRs couverts :** FR1, FR2, FR3, FR4, FR5, FR6, FR7, FR8

### Epic 3 : Léon IA & Génération de Programmes
L'utilisateur peut parler à Léon via le bouton flottant et recevoir un programme d'entraînement personnalisé multi-sport. Léon connaît le profil, génère des programmes combinés, ciblés ou ultra-progressifs, et communique dans la langue de l'utilisateur.
**FRs couverts :** FR9, FR10, FR11, FR14, FR15, FR16, FR17, FR18, FR19, FR20, FR21, FR22, FR23, FR24, FR57

### Epic 4 : Tracking en Séance
L'utilisateur peut lancer un tracking adapté à son sport : GPS + chrono (endurance), reps/séries/poids (muscu), intervalles (HIIT), chrono simple (yoga). RPE post-séance. Fonctionne offline.
**FRs couverts :** FR25, FR26, FR27, FR28, FR29, FR30

### Epic 5 : Suivi de Progression
L'utilisateur peut consulter son historique, visualiser sa progression en graphiques (Swift Charts), voir ses records personnels et ses tendances. Le système détecte progressions et stagnations et calcule le taux de complétion.
**FRs couverts :** FR31, FR32, FR33, FR34, FR35, FR36

### Epic 6 : Adaptation Dynamique
Le programme s'adapte automatiquement : séances manquées → réorganisation, fatigue/douleur → charge réduite, progression → surcharge ajustée, contrainte nouvelle → exercices alternatifs. Léon adapte aussi les séances en temps réel sur demande.
**FRs couverts :** FR12, FR13, FR37, FR38, FR39, FR40

### Epic 7 : HealthKit & Intégrations Externes
L'utilisateur voit ses données de toutes ses montres/iPhone dans l'app. Ses séances s'exportent automatiquement vers Apple Health et Strava (avec retry offline).
**FRs couverts :** FR41, FR42, FR43, FR44, FR45, FR46

### Epic 8 : Notifications & Engagement
L'utilisateur reçoit des rappels de séances, des notifications de records battus, et Léon le relance en douceur après une période d'inactivité. Préférences configurables.
**FRs couverts :** FR47, FR48, FR49, FR50

### Epic 9 : Localisation & Finalisation
L'app est entièrement disponible en français et anglais. Polish final, tests E2E, préparation App Store.
**FRs couverts :** FR56

---

## Epic 0 : Spike Technique

> ⚠️ **OBSOLÈTE depuis 2026-04-06** — Spike 0.3 Léon TERMINÉ. Voir `CoachingSage/Spike/Leon/Results/spike-0.3-v2-findings.md` pour les résultats. Spikes 0.1 (GPS) et 0.2 (HealthKit) restent à faire selon le plan inchangé.

Valider les 3 risques techniques majeurs avant de s'engager sur le scope V1.

### Story 0.1 : Spike CoreLocation GPS Background

As a développeuse,
I want valider que le tracking GPS background fonctionne de manière fiable sur iOS,
So that je puisse m'engager sur le scope tracking endurance de la V1.

**Acceptance Criteria:**

**Given** un projet iOS test avec CoreLocation background mode activé
**When** l'utilisateur lance un tracking GPS et met l'app en arrière-plan
**Then** la trace GPS continue d'être enregistrée en background
**And** la précision est acceptable (< 10m en conditions urbaines)
**And** le premier fix GPS prend < 10 secondes
**And** la consommation batterie est documentée (% par heure de tracking)
**And** aucun crash après 1h de tracking continu

### Story 0.2 : Spike HealthKit Lecture & Écriture

As a développeuse,
I want valider que HealthKit peut lire les données de toutes les sources et écrire des workouts,
So that je puisse confirmer l'approche "hub universel" sans intégration par marque.

**Acceptance Criteria:**

**Given** un projet iOS test avec les entitlements HealthKit
**When** l'app demande l'autorisation HealthKit
**Then** les données de pas (iPhone seul) sont lisibles
**And** les données de fréquence cardiaque (Apple Watch) sont lisibles si disponibles
**And** les données de workouts tiers (Garmin, Fitbit via HealthKit) sont lisibles
**And** l'app peut écrire un workout de type running dans Apple Health
**And** le workout écrit apparaît dans l'app Santé

### Story 0.3 : Spike Qualité Programmes Léon

As a développeuse,
I want valider que Claude API génère des programmes d'entraînement de qualité suffisante,
So that je puisse confirmer l'approche "Léon = expert IA" sans catalogue statique.

**Acceptance Criteria:**

**Given** une Edge Function de test avec un prompt système Léon
**When** on génère 10 programmes pour 5 sports différents (running, muscu, natation, tennis, remise en forme)
**Then** chaque programme contient des exercices cohérents pour le sport
**And** les exercices respectent l'équipement et les contraintes du profil
**And** la progression est logique sur les semaines
**And** la génération prend < 5 secondes par programme
**And** les résultats sont documentés avec évaluation qualitative

## Epic 1 : Foundation & Authentification

L'utilisateur peut installer l'app, créer un compte (Apple Sign In ou email) et se connecter. Ses données se synchronisent entre iPhone et cloud. Le squelette de l'app (TabView 4 onglets) est en place.

### Story 1.1a : Setup Projet & Infrastructure

As a développeuse,
I want initialiser le projet CoachingSage selon le Sage App Blueprint,
So that la base technique soit en place pour développer les fonctionnalités.

**Acceptance Criteria:**

**Given** le workspace CL3.xcworkspace existant
**When** le projet CoachingSage est créé
**Then** le projet Xcode est configuré selon le Sage App Blueprint (Bundle ID `com.sopddl.coachingsage.app`, App Group, SageCore SPM)
**And** les fichiers xcconfig Debug/Staging/Release sont en place + .gitignore
**And** SageCore est ajouté comme dépendance locale SPM
**And** le projet Supabase `sagecoach-dev` (EU Frankfurt) est créé avec la table `core_profiles` + RLS
**And** les fichiers [COPIE IDENTIQUE] sont copiés depuis GardenSage/TailorSage
**And** le script check-copie-identique.sh inclut CoachingSage dans le tableau APPS
**And** Xcode Cloud est configuré pour le build et les tests automatiques

### Story 1.1b : Authentification

As a utilisateur,
I want créer un compte et me connecter via Apple Sign In ou email,
So that mes données soient sécurisées et liées à mon identité.

**Acceptance Criteria:**

**Given** l'app CoachingSage installée sur un iPhone iOS 17+
**When** l'utilisateur ouvre l'app pour la première fois
**Then** l'écran d'authentification s'affiche (AuthView COPIE IDENTIQUE)
**And** l'utilisateur peut s'inscrire via Sign in with Apple (FR51)
**And** l'utilisateur peut s'inscrire via email/password (FR52)
**And** après connexion, le SageCoreProfile est créé dans SwiftData et Supabase

### Story 1.2 : Navigation TabView & Design Tokens

As a utilisateur,
I want voir la structure de l'app avec ses onglets principaux,
So that je puisse naviguer entre les sections de l'app.

**Acceptance Criteria:**

**Given** un utilisateur connecté
**When** l'écran principal s'affiche
**Then** une TabView avec 4 onglets est visible : Aujourd'hui, Séance, Progrès, Profil
**And** chaque onglet affiche un placeholder (contenu à venir)
**And** la palette Color+Coaching est appliquée (ni vert/GardenSage, ni prune/TailorSage)
**And** le démarrage app (cold start) prend < 3 secondes (NFR7)

### Story 1.3 : Synchronisation & Mode Offline

As a utilisateur,
I want que mes données se synchronisent automatiquement entre mon iPhone et le cloud,
So that je ne perde jamais mes données même sans connexion.

**Acceptance Criteria:**

**Given** un utilisateur connecté avec des données locales
**When** l'appareil passe en ligne après une période offline
**Then** SyncService (COPIE IDENTIQUE adaptée) synchronise les PendingOperations (FR53, FR55)
**And** aucune donnée n'est perdue lors de la synchronisation (NFR18)
**And** l'utilisateur peut utiliser l'app en mode offline (consultation données locales)
**And** un indicateur de statut de connexion est visible

### Story 1.4 : Suppression de Compte & RGPD

As a utilisateur,
I want pouvoir supprimer mon compte et toutes mes données,
So that mon droit à l'oubli soit respecté conformément au RGPD.

**Acceptance Criteria:**

**Given** un utilisateur connecté dans l'onglet Profil
**When** l'utilisateur demande la suppression de son compte
**Then** une confirmation est demandée avant suppression
**And** le compte est marqué supprimé (soft delete) côté Supabase (FR54)
**And** les données locales SwiftData sont effacées
**And** l'utilisateur est redirigé vers l'écran d'authentification
**And** pg_cron purge les données sous 30 jours (NFR11)

## Epic 2 : Onboarding & Profil Sportif

> ⚠️ **OBSOLÈTE depuis 2026-04-06** — Voir `epics-CoachingSage-v2-proposal.md` section Epic 2 (réécrit en 2 stories au lieu de 3, drastiquement simplifié).

L'utilisateur peut créer son profil sportif complet (sports, niveaux, objectifs, équipement, contraintes, fréquence) et le modifier à tout moment. Disclaimer médical et consentement RGPD inclus.

### Story 2.1 : Onboarding — Données Personnelles & Sports

As a utilisateur nouvellement inscrit,
I want renseigner mes données personnelles et sélectionner mes sports,
So that Léon puisse personnaliser mes programmes selon mon profil.

**Acceptance Criteria:**

**Given** un utilisateur connecté qui n'a pas encore de CoachingProfile
**When** l'onboarding se lance automatiquement
**Then** l'utilisateur peut saisir ses données personnelles : âge, poids, taille, sexe (FR1)
**And** l'utilisateur peut sélectionner un ou plusieurs sports parmi 10+ disciplines (FR2)
**And** l'utilisateur peut déclarer son niveau par sport : débutant, intermédiaire, avancé, expert (FR3)
**And** le disclaimer médical est affiché et doit être accepté (NFR14)
**And** le consentement analytics RGPD est demandé (NFR12)
**And** le CoachingProfile est créé en SwiftData + enqueue sync Supabase
**And** la table `coaching_profiles` est créée dans Supabase avec RLS

### Story 2.2 : Onboarding — Objectifs, Équipement & Contraintes

As a utilisateur en cours d'onboarding,
I want définir mes objectifs, mon équipement et mes contraintes physiques,
So that Léon génère des programmes adaptés à ma situation réelle.

**Acceptance Criteria:**

**Given** un utilisateur ayant complété l'étape sports/données personnelles
**When** l'étape suivante de l'onboarding s'affiche
**Then** l'utilisateur peut définir ses objectifs : perte de poids, prise de masse, performance, bien-être, préparation compétition (FR4)
**And** l'utilisateur peut déclarer son équipement : salle, maison, extérieur, piscine, matériel spécifique (FR5)
**And** l'utilisateur peut déclarer ses contraintes physiques : blessures, douleurs, limitations (FR6)
**And** l'utilisateur peut définir sa fréquence d'entraînement et ses disponibilités (FR7)
**And** le CoachingProfile est mis à jour en SwiftData + sync Supabase

### Story 2.3 : Modification du Profil

As a utilisateur,
I want modifier mon profil sportif à tout moment,
So that Léon tienne compte de l'évolution de ma situation (nouveau sport, blessure, changement d'objectif).

**Acceptance Criteria:**

**Given** un utilisateur connecté avec un CoachingProfile existant
**When** l'utilisateur ouvre la section Profil (onglet 4)
**Then** toutes les données du profil sont affichées et modifiables (FR8)
**And** l'utilisateur peut ajouter/retirer des sports
**And** l'utilisateur peut modifier ses objectifs, équipement, contraintes, fréquence
**And** les modifications sont sauvegardées en SwiftData + enqueue sync Supabase
**And** le disclaimer médical reste accessible depuis les paramètres (NFR14)

## Epic 3 : Léon IA & Génération de Programmes

> ⚠️ **OBSOLÈTE depuis 2026-04-06** — Voir `epics-CoachingSage-v2-proposal.md` section Epic 3 (restructuré en 6 stories autour de l'architecture 3 couches : SportQuestionnaire local + ProgramTemplateSelector + Adaptation Léon + Regen + Génération + Chat).

L'utilisateur peut parler à Léon via le bouton flottant et recevoir un programme d'entraînement personnalisé multi-sport. Léon connaît le profil, génère des programmes combinés, ciblés ou ultra-progressifs, et communique dans la langue de l'utilisateur.

### Story 3.1 : Edge Function Léon & Conversation de Base

As a utilisateur,
I want parler à Léon en langage naturel via un bouton flottant,
So that je puisse poser des questions sur le sport et l'entraînement.

**Acceptance Criteria:**

**Given** un utilisateur connecté avec un CoachingProfile
**When** l'utilisateur appuie sur le bouton flottant Léon (visible sur tous les écrans)
**Then** une interface de conversation s'ouvre (FR9)
**And** l'utilisateur peut écrire en français ou en anglais (FR10)
**And** Léon répond dans la langue de l'utilisateur (FR57)
**And** Léon peut répondre à des questions sur les exercices, techniques et progression (FR15)
**And** l'Edge Function `sage-coaching-ai` est déployée sur Supabase
**And** le prompt système inclut le profil utilisateur en contexte
**And** en cas d'indisponibilité, un message "Léon indisponible" s'affiche (NFR17)

### Story 3.2 : Génération de Programme Personnalisé

As a utilisateur,
I want demander à Léon de me créer un programme d'entraînement,
So that j'aie un plan structuré adapté à mon profil, mes objectifs et mes contraintes.

**Acceptance Criteria:**

**Given** un utilisateur avec un CoachingProfile complet
**When** l'utilisateur demande un programme à Léon ("crée-moi un programme running")
**Then** Léon génère un programme personnalisé en < 5 secondes (FR11, NFR1)
**And** le programme inclut : exercices détaillés, séries/répétitions ou durée, temps de repos, progression sur N semaines (FR22)
**And** le programme tient compte de l'équipement déclaré (FR23)
**And** le programme tient compte des contraintes physiques (FR24)
**And** les models Program, ProgramWeek, Session sont créés en SwiftData
**And** les tables `programs`, `program_weeks`, `sessions` sont créées dans Supabase avec RLS
**And** le programme s'affiche dans l'onglet Aujourd'hui avec sa structure semaine par semaine

### Story 3.3 : Programmes Multi-Sport & Combinés

As a utilisateur multi-sport (triathlon, biathlon),
I want recevoir un programme combinant plusieurs disciplines,
So that mon entraînement soit cohérent et équilibré entre les sports.

**Acceptance Criteria:**

**Given** un utilisateur avec 2+ sports dans son profil
**When** l'utilisateur demande un programme combiné ("programme triathlon sprint 16 semaines")
**Then** Léon génère un programme couvrant toutes les disciplines demandées (FR19)
**And** les séances alternent entre les sports de manière cohérente
**And** Léon gère 10+ sports : running, muscu, natation, vélo, triathlon, tennis, yoga, athlétisme, sports co, remise en forme (FR18)
**And** le programme est visible dans l'onglet Aujourd'hui avec les sports identifiés par séance

### Story 3.4 : Programmes Ciblés & Ultra-Progressifs

As a utilisateur,
I want obtenir un programme ciblé sur une technique ou un programme ultra-progressif pour débutant,
So that je travaille exactement ce dont j'ai besoin, à mon rythme.

**Acceptance Criteria:**

**Given** un utilisateur avec un CoachingProfile
**When** l'utilisateur demande un programme ciblé ("améliorer mon revers tennis") ou ultra-progressif ("je pars de zéro")
**Then** Léon génère un programme ciblé sur la technique demandée (FR20)
**And** Léon peut générer un programme ultra-progressif pour débutant total (FR21)
**And** le programme ultra-progressif commence à un niveau très bas (ex: 10 min marche) avec montée très progressive
**And** le programme ciblé mixe technique spécifique + renforcement complémentaire

### Story 3.5 : Contexte & Mémoire Léon

As a utilisateur,
I want que Léon connaisse mon historique complet (programmes passés, progression, difficultés),
So that ses conseils et programmes soient de plus en plus pertinents.

**Acceptance Criteria:**

**Given** un utilisateur ayant déjà complété un ou plusieurs programmes
**When** l'utilisateur discute avec Léon
**Then** Léon a accès au profil complet, programmes passés, et historique de progression (FR16)
**And** à la fin d'un programme terminé, Léon propose un nouveau programme adapté (FR14)
**And** la proposition tient compte des résultats du programme précédent
**And** le contexte est envoyé à l'Edge Function : profil, programme en cours, historique progression, contraintes

### Story 3.6 : Programmes pour Publics Tiers

As a utilisateur (coach, prof de sport),
I want demander à Léon de générer des programmes pour d'autres personnes,
So that je puisse structurer l'entraînement de mes élèves ou de mon équipe.

**Acceptance Criteria:**

**Given** un utilisateur connecté
**When** l'utilisateur décrit un public tiers ("programme endurance pour des 14-15 ans, 2 séances de 50 min, terrain extérieur")
**Then** Léon génère un programme adapté au public décrit (FR17)
**And** le programme tient compte des contraintes du public (âge, niveau, équipement)
**And** le programme est enregistré dans la liste de programmes de l'utilisateur
**And** l'utilisateur peut générer plusieurs programmes pour différents publics

## Epic 4 : Tracking en Séance

L'utilisateur peut lancer un tracking adapté à son sport : GPS + chrono (endurance), reps/séries/poids (muscu), intervalles (HIIT), chrono simple (yoga). RPE post-séance. Fonctionne offline.

### Story 4.1 : Tracking Endurance (GPS + Chrono)

As a utilisateur pratiquant un sport d'endurance,
I want lancer un tracking GPS avec chronomètre pendant ma séance,
So that ma distance, mon allure et ma durée soient enregistrées automatiquement.

**Acceptance Criteria:**

**Given** un utilisateur qui lance une séance de type endurance (running, vélo, natation extérieure)
**When** l'utilisateur appuie sur "Démarrer"
**Then** le tracking démarre en < 1 seconde (NFR2)
**And** le GPS acquiert un fix en < 10 secondes (NFR3)
**And** l'EnduranceTrackingEngine enregistre : trace GPS, distance, durée, allure moyenne, splits par km
**And** le tracking fonctionne en background (CoreLocation background mode)
**And** l'utilisateur peut mettre en pause et reprendre
**And** aucun crash pendant toute la durée du tracking (NFR15)
**And** le SessionResult est créé en SwiftData avec trackingData JSON type "endurance"
**And** la table `session_results` est créée dans Supabase avec RLS
**And** zéro perte de données de séance (NFR16)

### Story 4.2 : Tracking Musculation (Reps/Séries/Poids)

As a utilisateur pratiquant la musculation,
I want enregistrer mes séries, répétitions et poids pendant ma séance,
So that ma progression soit trackée exercice par exercice.

**Acceptance Criteria:**

**Given** un utilisateur qui lance une séance de musculation
**When** l'utilisateur démarre le tracking
**Then** le StrengthTrackingEngine affiche la liste des exercices de la séance
**And** l'utilisateur peut saisir reps, poids (kg) et temps de repos par série (FR26)
**And** l'utilisateur peut ajouter des séries supplémentaires
**And** le chronomètre de repos démarre automatiquement entre les séries
**And** le SessionResult est créé avec trackingData JSON type "strength"
**And** la saisie est rapide (minimum de taps pour enregistrer une série)

### Story 4.3 : Tracking Intervalles & Chrono Simple

As a utilisateur pratiquant le HIIT, la natation piscine, le yoga ou le stretching,
I want utiliser un chronomètre adapté à ma séance (intervalles ou simple),
So that mes temps de travail et repos soient enregistrés.

**Acceptance Criteria:**

**Given** un utilisateur qui lance une séance temporisée
**When** l'utilisateur démarre le tracking
**Then** l'IntervalTrackingEngine gère les intervalles travail/repos pour HIIT et natation piscine (FR27)
**And** le SimpleTrackingEngine gère un chronomètre seul pour yoga, stretching, tennis drills
**And** l'interface affiche clairement le temps de travail vs repos
**And** les SessionResults sont créés avec trackingData JSON type "interval" ou "simple"

### Story 4.4 : Interface Adaptative & RPE Post-Séance

As a utilisateur,
I want que l'interface de tracking s'adapte automatiquement à mon sport et pouvoir noter mon effort après la séance,
So that le tracking soit toujours pertinent et que Léon connaisse mon ressenti.

**Acceptance Criteria:**

**Given** un utilisateur qui lance une séance depuis son programme
**When** le sport de la séance est identifié
**Then** l'interface de tracking sélectionne automatiquement le bon TrackingEngine (FR29)
**And** endurance → GPS + chrono + allure, muscu → reps/séries/poids, HIIT → intervalles, yoga → chrono simple
**And** après la fin de la séance, l'utilisateur peut noter son effort perçu RPE 1-10 (FR28)
**And** le RPE est enregistré dans le SessionResult
**And** tout le tracking fonctionne en mode offline (FR30)
**And** les données sont enqueue en PendingOperation pour sync au retour en ligne

## Epic 5 : Suivi de Progression

L'utilisateur peut consulter son historique, visualiser sa progression en graphiques (Swift Charts), voir ses records personnels et ses tendances. Le système détecte progressions et stagnations et calcule le taux de complétion.

### Story 5.1 : Historique des Séances

As a utilisateur,
I want consulter l'historique complet de mes séances,
So that je puisse revoir ce que j'ai fait et suivre ma régularité.

**Acceptance Criteria:**

**Given** un utilisateur ayant complété des séances
**When** l'utilisateur ouvre l'onglet Progrès
**Then** l'historique complet des séances est affiché, trié par date (FR31)
**And** chaque séance montre : sport, durée, date, métriques clés (distance/poids/intervalles selon le sport)
**And** l'utilisateur peut filtrer par sport
**And** le taux de complétion du programme en cours est visible (FR36)
**And** les données sont disponibles offline (SwiftData)

### Story 5.2 : Graphiques de Progression & Records

As a utilisateur,
I want voir mes progrès en graphiques et mes records personnels,
So that je sois motivé par ma progression concrète.

**Acceptance Criteria:**

**Given** un utilisateur ayant complété plusieurs séances
**When** l'utilisateur consulte la section graphiques
**Then** des graphiques Swift Charts montrent la progression : poids soulevés, allure, distance, temps (FR32)
**And** l'affichage des graphiques prend < 2 secondes (NFR4)
**And** les records personnels par exercice et par sport sont listés (FR33)
**And** la table `personal_records` est créée dans Supabase avec RLS
**And** le PersonalRecord model est créé en SwiftData
**And** quand un record est battu, il est mis à jour automatiquement

### Story 5.3 : Tendances & Détection Progression/Stagnation

As a utilisateur,
I want voir mes tendances sur plusieurs semaines et être alerté quand je stagne,
So that je puisse ajuster mon entraînement en connaissance de cause.

**Acceptance Criteria:**

**Given** un utilisateur avec un historique de 4+ semaines
**When** l'utilisateur consulte la section tendances
**Then** les tendances sont visualisées sur 4, 8 et 12 semaines (FR34)
**And** le système détecte et signale les progressions (courbe montante, records) (FR35)
**And** le système détecte et signale les stagnations (plateau sur N semaines) (FR35)
**And** les calculs sont locaux SwiftData (pas de dépendance réseau)

## Epic 6 : Adaptation Dynamique

Le programme s'adapte automatiquement : séances manquées → réorganisation, fatigue/douleur → charge réduite, progression → surcharge ajustée, contrainte nouvelle → exercices alternatifs. Léon adapte aussi les séances en temps réel sur demande.

### Story 6.1 : Détection Séances Manquées & Réorganisation

As a utilisateur qui a manqué des séances,
I want que mon programme se réorganise automatiquement,
So that je ne sois pas bloqué par un plan rigide.

**Acceptance Criteria:**

**Given** un utilisateur avec un programme actif et des séances manquées
**When** le système détecte des séances non complétées (FR37)
**Then** Léon réorganise le programme de la semaine (FR13)
**And** les séances manquées sont reportées ou adaptées (pas simplement supprimées)
**And** la réorganisation tient compte des séances restantes dans la semaine
**And** l'utilisateur voit les changements dans son planning avec une explication Léon

### Story 6.2 : Adaptation en Temps Réel sur Demande

As a utilisateur en cours de séance ou de programme,
I want signaler une fatigue, une douleur ou une contrainte et recevoir un programme adapté,
So that mon entraînement reste sûr et efficace malgré les aléas.

**Acceptance Criteria:**

**Given** un utilisateur qui parle à Léon
**When** l'utilisateur signale "j'ai mal au genou" ou "je suis très fatigué"
**Then** Léon adapte la séance en temps réel sur demande (FR12)
**And** l'utilisateur peut signaler une fatigue ou une douleur et recevoir un plan adapté (FR38)
**And** Léon propose des exercices alternatifs en cas de contrainte nouvelle (FR40)
**And** les modifications sont enregistrées dans le ProgramWeek (coachNotes)

### Story 6.3 : Ajustement de Charge Automatique

As a utilisateur qui progresse (ou stagne),
I want que la charge d'entraînement s'ajuste en fonction de mes résultats réels,
So that je continue à progresser sans surcharge ni sous-charge.

**Acceptance Criteria:**

**Given** un utilisateur avec un historique de séances et de progression
**When** Léon analyse les données de tracking et de progression
**Then** le système ajuste la charge d'entraînement (FR39)
**And** progression rapide → surcharge ajustée (ex: poids +2.5kg, distance +1km)
**And** stagnation → variation des exercices ou décharge programmée
**And** l'ajustement est visible dans les séances à venir avec une note Léon

## Epic 7 : HealthKit & Intégrations Externes

L'utilisateur voit ses données de toutes ses montres/iPhone dans l'app. Ses séances s'exportent automatiquement vers Apple Health et Strava (avec retry offline).

### Story 7.1 : Lecture HealthKit & Hub Universel

As a utilisateur avec une montre connectée ou un iPhone,
I want que l'app lise mes données de santé depuis toutes les sources,
So that mon suivi soit enrichi sans configuration par marque.

**Acceptance Criteria:**

**Given** un utilisateur avec des données HealthKit disponibles
**When** l'utilisateur autorise l'accès HealthKit (consentement explicite, NFR8)
**Then** le système lit les données de toutes les sources : Apple Watch, Garmin, Fitbit, Samsung, Polar, Suunto, iPhone (FR41)
**And** les données enrichissent le suivi : fréquence cardiaque, pas, distance, calories (FR42)
**And** l'iPhone seul (sans montre) fournit des données de base : podomètre, distance, escaliers (FR43)
**And** le HealthKitService implémente le protocol défini dans l'architecture

### Story 7.2 : Export Apple Health & Strava

As a utilisateur,
I want que mes séances s'exportent vers Apple Health et Strava,
So that mes données soient intégrées dans mon écosystème existant.

**Acceptance Criteria:**

**Given** un utilisateur ayant complété une séance
**When** la séance est terminée
**Then** le workout est écrit dans Apple Health en temps réel (FR45, NFR6)
**And** l'utilisateur peut connecter son compte Strava (OAuth2)
**And** la séance est exportée vers Strava (FR44) en < 3 secondes (NFR5)
**And** si l'utilisateur est offline, l'export Strava est enqueue en PendingOperation et s'exécute au retour en ligne (FR46)
**And** le StravaExportService implémente le protocol défini dans l'architecture

## Epic 8 : Notifications & Engagement

L'utilisateur reçoit des rappels de séances, des notifications de records battus, et Léon le relance en douceur après une période d'inactivité. Préférences configurables.

### Story 8.1 : Rappels de Séances & Notifications Records

As a utilisateur,
I want recevoir des rappels avant mes séances et être notifié quand je bats un record,
So that je ne rate pas mes séances et que je célèbre mes progrès.

**Acceptance Criteria:**

**Given** un utilisateur avec un programme actif et des séances planifiées
**When** une séance est programmée dans les prochaines heures
**Then** une notification locale rappelle la séance (FR47)
**And** quand un record personnel est battu, une notification est envoyée (FR49)
**And** le ton des notifications est bienveillant et motivant (jamais culpabilisant)

### Story 8.2 : Notifications Proactives Léon & Préférences

As a utilisateur,
I want que Léon me relance en douceur après une période d'inactivité et pouvoir configurer mes notifications,
So that je reste motivé sans me sentir harcelé.

**Acceptance Criteria:**

**Given** un utilisateur inactif depuis N jours
**When** le seuil d'inactivité est atteint
**Then** Léon envoie une notification proactive bienveillante (FR48)
**And** ex: "3 jours sans séance. On s'y remet doucement ?"
**And** l'utilisateur peut configurer ses préférences de notification dans les paramètres (FR50)
**And** l'utilisateur peut activer/désactiver : rappels séances, records, Léon proactif
**And** les notifications utilisent APNs push + notifications locales

## Epic 9 : Localisation & Finalisation

L'app est entièrement disponible en français et anglais. Polish final, tests E2E, préparation App Store.

### Story 9.1 : Localisation Complète FR/EN

As a utilisateur anglophone,
I want utiliser l'app entièrement en anglais,
So that l'app soit accessible au marché international.

**Acceptance Criteria:**

**Given** un utilisateur avec son iPhone configuré en anglais
**When** l'app se lance
**Then** toute l'interface est affichée en anglais (FR56)
**And** tous les écrans, boutons, messages d'erreur sont traduits via Localizable.xcstrings
**And** l'app fonctionne correctement en français et en anglais
**And** les tests EN sont exécutés (lesson learned GardenSage)

### Story 9.2 : Polish Final & Préparation App Store

As a développeuse,
I want finaliser l'app pour soumission App Store,
So that CoachingSage soit prêt pour le lancement public.

**Acceptance Criteria:**

**Given** toutes les fonctionnalités implémentées et testées
**When** la préparation App Store est lancée
**Then** les tests E2E sont passés sur tous les parcours utilisateur
**And** les screenshots App Store sont générés (FR + EN)
**And** la description App Store est rédigée (FR + EN)
**And** les justifications permissions sont prêtes (Location, HealthKit, Push, Motion & Fitness)
**And** le disclaimer médical est vérifié
**And** l'app démarre en < 3 secondes (NFR7)
