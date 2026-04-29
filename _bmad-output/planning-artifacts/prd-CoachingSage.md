---
stepsCompleted: ['step-01-init', 'step-02-discovery', 'step-02b-vision', 'step-02c-executive-summary', 'step-03-success', 'step-04-journeys', 'step-05-domain-skipped', 'step-06-innovation', 'step-07-project-type', 'step-08-scoping', 'step-09-functional', 'step-10-nonfunctional', 'step-11-polish', 'step-12-complete']
status: complete
completedAt: '2026-03-21'
inputDocuments:
  - "product-brief-CoachingSage-2026-03-21.md"
  - "product-brief-CL3-2026-03-04.md"
  - "product-brief-TailorSage-2026-03-08.md"
  - "sage-app-blueprint.md"
workflowType: 'prd'
productName: CoachingSage
documentCounts:
  briefs: 3
  research: 0
  brainstorming: 0
  projectDocs: 0
  projectContext: 0
classification:
  projectType: mobile_app
  domain: general
  complexity: medium
  projectContext: greenfield
---

# Product Requirements Document - CoachingSage

**Author:** Sophie
**Date:** 2026-03-21

## Executive Summary

**CoachingSage** est une application iOS de coaching sportif personnalise, gratuite et multi-sport. 3e app de la plateforme Sage (apres GardenSage pour le jardinage et TailorSage pour la couture), elle s'adresse au marche le plus large de la suite : toute personne qui fait du sport ou veut s'y mettre.

L'app genere des programmes d'entrainement adaptes au profil reel de l'utilisateur (age, poids, niveau, objectifs, contraintes, equipement) via **Coach**, un assistant IA conversationnel. Elle couvre 10+ sports individuels et collectifs (running, musculation, natation, velo, triathlon, tennis, yoga, athletisme, sports co, remise en forme). Le tracking en seance (GPS, chronometre, reps/series) et le suivi de progression (graphiques, records personnels, tendances) sont integres nativement — au niveau des meilleures applis payantes, mais gratuit. L'export vers Strava et Apple Health permet l'integration dans l'ecosysteme existant de l'utilisateur.

**Probleme :** Le coaching sportif personnalise de qualite est systematiquement payant. Les applis gratuites sont generiques, mono-sport, et sans suivi reel. Certains sports (natation, triathlon combine) sont des deserts applicatifs.

**Solution :** Coach genere des programmes vivants qui s'adaptent en continu — seances manquees, fatigue, blessures, progression reelle. Un seul outil pour tous les sports, tous les niveaux, tous les objectifs.

### What Makes This Special

- **Gratuit + complet** : le niveau de personnalisation des applis premium (TrainingPeaks, Freeletics, JEFIT), sans le paywall
- **Multi-sport dans une seule app** : un triathlonien gere ses 3 disciplines, un prof de sport structure tous ses programmes — personne ne fait ca gratuitement
- **Coach conversationnel** : assistant IA a bouton flottant (meme pattern que Flore/Coco), adapte les seances en temps reel sur demande
- **Programmes vivants** : pas de plan PDF rigide — le programme s'adapte aux aleas de la vie reelle
- **Export, pas enfermement** : CoachingSage produit le coaching, Strava/Apple Health gere le social et la sante
- **Plateforme Sage** : SageCore, Supabase, Swift/SwiftUI — architecture eprouvee sur 2 apps, demarrage rapide

## Project Classification

| | |
|---|---|
| **Type** | Application mobile iOS native (Swift/SwiftUI) |
| **Domaine** | General (coaching sportif — pas de contrainte reglementaire specifique) |
| **Complexite** | Medium (multi-sport + tracking + export, mais architecture Sage eprouvee) |
| **Contexte** | Greenfield — nouvelle app de la plateforme Sage |

## Success Criteria

### User Success

| Profil | Critere de succes | Mesure |
|---|---|---|
| Triathlonien (Sophie) | Programme combine suivi regulierement | > 80% des seances completees sur 4 semaines |
| Jeune muscu (Maxime) | Progression visible et motivante | Consulte graphiques de progression 1x/semaine minimum |
| Runner (Philippe) | Objectif course atteint | Valide son objectif (10km, semi, marathon) dans l'app |
| Tennis (Clara) | Progres sur un coup cible | Termine un programme cible de 3+ semaines |
| Perte de poids (Nathalie) | Tient dans la duree | Active 30 jours consecutifs, 3+ seances/semaine |
| Tous | Revient pour un 2e programme | Cree un nouveau programme dans les 30 jours apres fin du 1er |

**Moments "aha!" cles :**
- 1er programme genere adapte a son profil exact (vs programmes generiques)
- Coach qui reorganise la semaine apres une seance manquee (vs plan rigide casse)
- 1ere progression concrete visible dans les graphiques

### Business Success

| Horizon | Objectif | Metrique cible |
|---|---|---|
| 3 mois | Valider l'engagement | 3 000 MAU, retention 30j > 35% |
| 6 mois | Croissance organique | 10 000 MAU, retention 30j > 40%, 5+ sports activement utilises |
| 12 mois | Reference gratuite | 50 000 MAU, retention 30j > 50%, App Store > 4.5 |

Strategie Phase 1 : **croissance pure, 0 revenu**. La valeur = la base utilisateurs. Monetisation Phase 2 a definir selon taille de la base.

### Technical Success

- Tracking GPS valide par spike Epic 0 (prerequis bloquant)
- HealthKit hub unique : toutes les sources via un seul lecteur
- Sync offline/online sans perte (SageCore SyncService)
- Multi-sport extensible par prompts, pas par code
- Cibles de performance detaillees dans la section Non-Functional Requirements

### Measurable Outcomes

- Taux de completion de programme > 50% (vs ~30% sur les applis sport gratuites)
- > 30% des utilisateurs actifs exportent vers Strava ou Apple Health (preuve d'integration routine)
- > 25% des utilisateurs creent 2+ programmes (preuve de valeur recurrente)
- Note App Store >= 4.3 a 6 mois, >= 4.5 a 12 mois

## User Journeys

### 🏊‍♀️ Journey 1 — Sophie, la triathloniene qui cherche UN outil

**Opening Scene :**
Sophie, 55 ans, dev iOS. Dimanche matin, elle ouvre Strava pour tracker son velo, puis Training Peaks pour voir son plan natation (payant), puis ses notes iPhone pour les seances piscine. 3 applis, rien n'est connecte. Son plan triathlon est un Google Sheet qu'elle met a jour manuellement. Elle rate sa seance natation du mardi — tout le plan est decale et elle ne sait pas comment reorganiser.

**Rising Action :**
Elle decouvre CoachingSage sur l'App Store ("triathlon programme gratuit"). Onboarding : 3 sports, niveau intermediaire, objectif triathlon sprint dans 4 mois, 5 seances/semaine, genou fragile. Coach genere un programme 16 semaines combinant natation/velo/course, avec des seances adaptees a son genou.

**Climax :**
Mercredi, elle dit "Coach, j'ai pas pu nager mardi". Coach reorganise la semaine : la natation passe a jeudi, le run leger de jeudi passe a vendredi. Rien n'est perdu. Le vendredi soir, elle ouvre ses graphiques : sa VMA running a progresse de 5% en 3 semaines, son allure natation est stable. Tout est sur UN ecran. Elle exporte sa sortie velo du dimanche sur Strava — ses amis voient l'activite normalement.

**Resolution :**
4 mois plus tard, Sophie termine son triathlon sprint. Coach lui dit "Programme termine ! Tu as complete 84% des seances. Pret pour un Olympic ?" Elle cree un nouveau programme. Elle n'ouvre plus Training Peaks.

**Capabilities revelees :** onboarding multi-sport, generation programme combine, adaptation dynamique, suivi multi-discipline, export Strava, gestion contraintes physiques

---

### 💪 Journey 2 — Maxime, le jeune muscu qui stagne

**Opening Scene :**
Maxime, 22 ans, etudiant. En salle 4 fois par semaine. Il note ses seances dans Notes : "Developpe couche 70kg x 8 x 3". Ca fait 2 mois qu'il souleve les memes poids. Il regarde des videos YouTube pour changer de programme mais ne sait pas lequel choisir. JEFIT est a 10€/mois — hors budget.

**Rising Action :**
Un pote en salle lui montre CoachingSage. Onboarding : muscu, intermediaire, objectif prise de masse, equipement salle complete, 4 jours/semaine. Coach genere un split push/pull/legs/upper sur 8 semaines avec surcharge progressive programmee.

**Climax :**
Semaine 4 : Maxime ouvre ses graphiques. Sa courbe de developpe couche monte : 70kg → 75kg → 77.5kg. Coach lui dit "Tu as progresse de 11% sur 4 semaines, on passe au cycle force la semaine prochaine". Il fait un screenshot et l'envoie a ses potes. Le lundi suivant, il est a 80kg. Le mur est casse.

**Resolution :**
Apres le cycle de 8 semaines, Coach propose "Cycle seche de 6 semaines ?" Maxime enchaine. 3 de ses potes en salle ont telecharge l'appli. Il n'utilise plus Notes pour tracker.

**Capabilities revelees :** generation programme muscu, tracking reps/series/poids, graphiques progression par exercice, surcharge progressive automatique, cycles d'entrainement, saisie rapide en seance

---

### 🏃‍♂️ Journey 3 — Philippe, le runner qui rate des seances

**Opening Scene :**
Philippe, 48 ans, cadre. Il s'est inscrit au semi-marathon de sa ville dans 6 mois. Il a telecharge un plan PDF "semi en 20 semaines" sur un blog running. Semaine 3 : il rate 2 seances a cause d'une reunion qui s'eternise. Le plan PDF ne dit pas quoi faire. Il court le week-end "a la sensation" et se demande s'il progresse.

**Rising Action :**
Un collegue runner lui recommande CoachingSage. Onboarding : running, debutant-intermediaire, objectif semi-marathon, 3 seances/semaine, pas de blessure. Coach genere un plan 20 semaines avec sortie longue week-end + 2 seances qualite en semaine.

**Climax :**
Semaine 5, il rate le mardi et le jeudi. Vendredi matin, il ouvre l'appli anxieux. Coach lui dit "Semaine ajustee : ta sortie longue de dimanche passe de 14km a 12km, et j'ai ajoute une seance de 30 min samedi matin pour compenser. Tu es toujours dans les clous." Il respire. Le dimanche, il lance le tracking GPS, court ses 12km. En rentrant, Coach affiche : "Allure moyenne 5:42/km — 8% plus rapide qu'il y a un mois. Semi en 2h00 est jouable." Il exporte sur Strava.

**Resolution :**
Jour J : Philippe termine son semi en 1h58. Il ouvre CoachingSage et valide "Objectif atteint". Coach : "Bravo ! 92% du plan complete malgre 6 seances manquees. Pret pour un marathon ?" Philippe sourit. Il cree un nouveau programme.

**Capabilities revelees :** plan flexible, tracking GPS, allure, estimation temps de course, gestion objectif, export Strava

---

### 🎾 Journey 4 — Clara, la tenniswoman qui veut un meilleur revers

**Opening Scene :**
Clara, 35 ans. En club, elle perd regulierement contre des joueuses qui attaquent son revers. Son prof de club lui dit "travaille ton revers" mais n'a pas le temps de lui faire un programme. Elle cherche "exercices revers tennis" sur YouTube — 50 videos differentes, elle ne sait pas par ou commencer.

**Rising Action :**
Elle voit CoachingSage sur Instagram. Onboarding : tennis, intermediaire, objectif "ameliorer mon revers a deux mains". Coach lui demande des precisions : frequence de jeu, acces a un mur d'entrainement, disponibilite pour du renforcement a la maison. Coach genere un programme 4 semaines : 2 seances drills revers (mur + terrain), 2 seances renforcement epaule/poignet/tronc a la maison.

**Climax :**
Semaine 3 : en match de club, Clara joue un revers long de ligne qui passe. Sa partenaire dit "c'est nouveau ca !". Elle rentre chez elle et dit a Coach "Mon revers passe mieux en match". Coach : "Normal, tu as fait 12 seances de drills en 3 semaines. On continue avec des drills en deplacement ?"

**Resolution :**
2 mois plus tard, son revers n'est plus son point faible. Elle dit a Coach "Maintenant je veux travailler ma volee". Nouveau programme cible. Son prof de club remarque les progres et lui demande quelle appli elle utilise.

**Capabilities revelees :** programmes cibles par technique, mix technique + renforcement, adaptation au sport specifique, suivi qualitatif, enchainement de programmes

---

### ⚖️ Journey 5 — Nathalie, la sedentaire qui part de zero

**Opening Scene :**
Nathalie, 52 ans, secretaire. Son medecin lui a dit "il faut bouger, vous avez 15 kilos a perdre". Elle a essaye un programme YouTube "HIIT 30 jours". Au jour 3, elle a mal partout. Au jour 5, elle abandonne. Elle se sent nulle.

**Rising Action :**
Sa fille lui installe CoachingSage. Onboarding : remise en forme, debutant total, objectif perte de poids, pas d'equipement, 15-20 min par jour maximum, douleur aux genoux. Coach genere un programme ultra-progressif semaine 1 : 10 min de marche active + 5 min d'etirements. Coach : "On commence doucement. L'important c'est de le faire, pas d'en faire trop."

**Climax :**
Semaine 3 : Nathalie monte les 3 etages de son bureau sans s'arreter. Coach affiche : "Semaine 1 tu faisais 10 minutes, aujourd'hui tu tiens 25 minutes. +150% en 3 semaines." Son iPhone (via HealthKit) montre 6 000 pas/jour au lieu de 2 000. Pas de montre — juste l'iPhone dans la poche — et ca suffit.

**Resolution :**
3 mois plus tard, 4 kilos perdus. Coach propose d'integrer de la natation douce. Elle dit a ses collegues "j'ai une appli qui m'a pas jugee". 2 collegues la telecharge.

**Capabilities revelees :** programmes ultra-progressifs debutants, zero equipement, iPhone seul (HealthKit), ton bienveillant Coach, progression motivante, transition entre sports

---

### 🏫 Journey 6 — Marc, le prof de sport en college

**Opening Scene :**
Marc, 42 ans, prof d'EPS. Il prepare des cycles d'athletisme, renforcement et endurance pour 4 niveaux (6e a 3e). Il fait ses programmes sur Excel — un tableau par classe. C'est long et repetitif.

**Rising Action :**
Onboarding : multi-sport, expert, objectif "structurer des programmes". Il demande a Coach un programme endurance 14-15 ans, 2 seances de 50 min/semaine, terrain exterieur, pas de materiel. Coach genere un cycle de 8 seances progressives.

**Climax :**
Marc genere 4 programmes (6e, 5e, 4e, 3e) pour son cycle athletisme en 20 minutes au lieu de quelques heures sur Excel. "Coach, le terrain est mouille, propose une seance en salle" — Coach reorganise.

**Resolution :**
Marc utilise CoachingSage pour sa preparation de cours. En V2, il pourra partager les programmes avec ses eleves. Il recommande l'appli a 3 collegues.

**Capabilities revelees :** generation programmes pour differents publics/niveaux, adaptation contraintes, usage generateur sans tracking, preparation partage V2

---

### 🔧 Journey 7 — Sophie (Admin), gestion solo de la plateforme

**Opening Scene :**
Sophie, dev solo. CoachingSage en production depuis 2 mois. Avis App Store : "Le programme musculation propose des exercices avec des machines que je n'ai pas".

**Rising Action :**
Via Supabase : 3 200 MAU, 62% retention, running et muscu = 75% des programmes. Natation sous-utilisee. Le probleme n'est pas un catalogue manquant — Coach connait les exercices — c'est que les prompts systeme ne filtrent pas assez sur l'equipement declare a l'onboarding.

**Climax :**
Sophie ajuste les prompts systeme de Coach : meilleur filtrage equipement, meilleure prise en compte du contexte (chez soi vs salle vs exterieur). Elle enrichit les instructions Coach pour la natation. Pas de catalogue a remplir — Coach est l'expert, il faut juste mieux orienter ses reponses. En 1 semaine, retours negatifs en baisse, programmes natation +40%.

**Resolution :**
Cycle mensuel : metriques Supabase, retours App Store, tuning prompts Coach, monitoring qualite. Le vrai asset = la qualite de l'IA Coach, pas un catalogue statique.

**Capabilities revelees :** monitoring Supabase, tuning prompts IA, analytics par sport, gestion qualite IA, ajout sports par enrichissement instructions

---

### Journey Requirements Summary

| Capability | Journeys |
|---|---|
| Onboarding multi-profil (sport, niveau, objectif, equipement, contraintes) | Tous |
| Coach IA expert multi-sport (generateur autonome, pas catalogue statique) | Tous sauf Admin |
| Generation programmes personnalises | Tous sauf Admin |
| Programmes combines multi-discipline | Sophie, Marc |
| Adaptation dynamique (seances manquees, fatigue, blessures) | Sophie, Philippe, Nathalie |
| Tracking en seance (GPS, chrono, reps/series) | Sophie, Maxime, Philippe |
| Suivi progression (graphiques, records, tendances) | Sophie, Maxime, Philippe, Nathalie |
| HealthKit hub (toutes montres + iPhone seul) | Sophie, Philippe, Nathalie |
| Export Strava | Sophie, Philippe |
| Programmes cibles par technique | Clara |
| Programmes ultra-progressifs (debutant total) | Nathalie |
| Generation programmes pour tiers | Marc |
| Prompts systeme Coach par sport (Track B) | Admin |
| Monitoring & analytics | Admin |

## Innovation & Novel Patterns

### Detected Innovation Areas

**1. Coach = IA experte, pas assembleur de catalogue**
Contrairement a GardenSage (plants.json) et TailorSage (catalogue patrons), Coach n'a pas besoin d'une base de donnees statique d'exercices. L'IA est l'expert — elle connait les exercices, les techniques, les progressions pour chaque sport. Le "Track B" est un jeu de prompts systeme par sport, pas un catalogue a remplir manuellement. C'est un changement de paradigme dans la plateforme Sage : de "IA qui assemble des donnees" a "IA qui est l'expert".

**2. Multi-sport gratuit + IA conversationnelle**
Aucune appli gratuite ne combine programme personnalise multi-sport + suivi de progression + assistant IA conversationnel. Les applis payantes sont mono-sport (TrainingPeaks = endurance, JEFIT = muscu). CoachingSage est la premiere a couvrir 10+ sports dans une seule app gratuite avec un coach IA.

**3. HealthKit comme hub universel zero-integration**
Au lieu de developper des integrations specifiques par marque de montre (Garmin API, Fitbit API...), CoachingSage utilise HealthKit comme hub unique. Une seule implementation lit les donnees de toutes les sources. L'iPhone seul (sans montre) suffit pour le suivi de base.

**4. Programmes adaptatifs vivants**
Les programmes ne sont pas des plans PDF statiques. Ils s'adaptent en continu : seances manquees → reorganisation automatique, fatigue → charge reduite, blessure → exercices alternatifs, progression → surcharge ajustee. Le programme vit avec l'utilisateur.

### Validation Approach

| Innovation | Validation | Spike/POC |
|---|---|---|
| Coach IA experte | Qualite des programmes generes vs programmes humains | Epic 0 : generer 10 programmes pour 5 sports, faire valider par des sportifs |
| Multi-sport gratuit | Adoption et retention par sport | Metriques post-lancement : quels sports sont utilises ? |
| HealthKit hub | Lecture donnees toutes sources | Epic 0 : spike GPS + lecture HealthKit (Apple Watch, Garmin, iPhone seul) |
| Programmes adaptatifs | Retention apres seance manquee | Metriques : taux d'abandon apres seance manquee vs applis concurrentes |

### Risk Mitigation

| Risque | Impact | Mitigation |
|---|---|---|
| Qualite des programmes IA insuffisante | Utilisateurs decoivent, mauvais avis | Prompts systeme par sport tres detailles + cycle de tuning mensuel |
| Tracking GPS consomme trop de batterie | UX degradee, abandon | Spike Epic 0 obligatoire avant engagement V1 |
| HealthKit pas alimente par certaines montres | Fonctionnalite incomplete | Fallback saisie manuelle toujours disponible |
| Responsabilite blessures (programme inadapte) | Risque legal | Disclaimer medical + Coach demande toujours les contraintes physiques |

## Mobile App Specific Requirements

### Project-Type Overview

Application iOS native Swift/SwiftUI, 3e app de la plateforme Sage. Capitalise sur SageCore (auth, sync, erreurs, reseau) et l'architecture eprouvee de GardenSage et TailorSage. Architecture identique : SwiftData local + Supabase cloud + SyncService offline-first.

### Platform Requirements

| Requirement | Detail |
|---|---|
| Plateforme | iOS 17+ (comme GardenSage/TailorSage) |
| Langage | Swift 5.9+, SwiftUI |
| Package partage | SageCore (local Swift package) |
| Persistence locale | SwiftData |
| Backend | Supabase (projet dedie `sagecoach-dev`, EU Frankfurt) |
| IA Coach | Claude API (generation programmes, conversation) |
| Workspace | CL3.xcworkspace (avec GardenSage, TailorSage, SageCore) |

### Device Permissions

| Permission | Usage | Justification App Store |
|---|---|---|
| Location (Always + When In Use) | Tracking GPS running/velo/triathlon | "Track your outdoor workouts with GPS" |
| HealthKit (Read + Write) | Lecture donnees montres/iPhone, ecriture seances | "Sync your workouts with Health" |
| Push Notifications | Rappels seances + Coach proactif | "Get workout reminders and coaching tips" |
| Motion & Fitness | Podometre, escaliers (iPhone sans montre) | "Track your daily activity" |

### Offline Mode

| Scenario | Comportement | Sync |
|---|---|---|
| Consultation programme | Programme en cours disponible offline (cache SwiftData) | Pull au retour en ligne |
| Tracking en seance | GPS, chrono, reps, RPE — tout fonctionne offline | Seance enqueue en PendingOperation, sync au retour |
| Generation programme (Coach) | Necessite connexion (appel IA) | Message "Connexion requise pour generer un programme" |
| Conversation Coach | Necessite connexion | Message "Connexion requise pour parler a Coach" |
| Export Strava | Necessite connexion | Enqueue et export automatique au retour en ligne |
| Export Apple Health | Fonctionne offline (API locale) | Ecriture immediate |

Pattern identique a GardenSage/TailorSage : SageCore SyncService + PendingOperation + last-write-wins.

### Push Strategy

| Type | Declencheur | Exemple |
|---|---|---|
| Rappel seance | Seance programmee dans X heures | "Ta seance running est prevue a 18h — pret ?" |
| Coach proactif | Pas de seance depuis N jours | "3 jours sans seance. On s'y remet doucement ?" |
| Progression | Record personnel battu | "Nouveau record ! 5:38/km sur 10km" |
| Programme termine | Derniere seance completee | "Programme termine ! Coach a une proposition pour la suite" |

Ton bienveillant et motivant — jamais culpabilisant. Meme philosophie que Flore (jardinage) et Coco (couture).

### Store Compliance

| Contrainte | Detail |
|---|---|
| App Store Review 4.8 | Sign in with Apple obligatoire (deja dans SageCore) |
| Background Location | Justification requise : tracking workout GPS. Usage uniquement pendant les seances actives |
| HealthKit | Review specifique Apple : justifier chaque type de donnee lu/ecrit |
| Disclaimer medical | "CoachingSage ne fournit pas de conseils medicaux. Consultez un professionnel de sante avant de commencer un programme sportif." |
| RGPD | Consentement analytics, droit a l'oubli (pg_cron purge 30j — meme pattern SageCore) |

### Implementation Considerations

- **Sage App Blueprint** : suivre la checklist de demarrage (Etapes 1-10 du blueprint)
- **Fichiers COPIE IDENTIQUE** : SageCoreProfile, PendingOperation, AuthService, AuthView, SyncService — copier depuis GardenSage/TailorSage
- **Script check-copie-identique.sh** : ajouter CoachingSage dans le tableau APPS
- **Bundle ID** : `com.sopddl.coachingsage.app`
- **App Group** : `group.com.sopddl.coachingsage.shared`
- **Supabase** : projet `sagecoach-dev` (EU Frankfurt), tables `core_profiles` + `coaching_profiles` + `programs` + `sessions` + `exercises`
- **Design tokens** : `Color+COACHING.swift` — palette a definir (ni vert/GardenSage, ni prune/TailorSage)

## Project Scoping & Phased Development

### MVP Strategy & Philosophy

**MVP Approach :** Experience MVP — livrer l'experience complete du coaching sportif personnalise gratuit. Pas de MVP reduit a 1 sport : le multi-sport EST le differenciateur.

**Resource Requirements :** Dev solo (Sophie) + Claude Code + SageCore. Meme setup que GardenSage et TailorSage. Le spike GPS (Epic 0) de-risque le point technique le plus incertain avant engagement sur le scope complet.

### MVP Feature Set (Phase 1)

**Core User Journeys Supported :**
- Sophie (triathlon) — programme combine, tracking GPS, export Strava
- Maxime (muscu) — programme personnalise, tracking reps/series, progression
- Philippe (runner) — plan flexible, tracking GPS, adaptation seances manquees
- Clara (tennis) — programme cible par technique
- Nathalie (perte poids) — programme ultra-progressif, iPhone seul
- Marc (prof sport) — generation programmes pour differents publics

**Must-Have Capabilities :**

| # | Capability | Justification |
|---|---|---|
| 1 | Profil sportif complet | Sans profil, Coach ne peut pas personnaliser |
| 2 | Coach IA conversationnel | Differenciateur core — c'est le produit |
| 3 | Generation programmes multi-sport (10+) | Differenciateur — multi-sport gratuit |
| 4 | Programmes combines | Use case triathlon = persona primaire |
| 5 | Tracking en seance (GPS + reps/series) | Suivi "niveau premium gratuit" |
| 6 | Suivi progression (graphiques, records) | Retention — voir sa progression |
| 7 | Adaptation dynamique | Differenciateur — programmes vivants |
| 8 | HealthKit hub (lecture toutes sources) | Toutes montres + iPhone seul |
| 9 | Export Strava & Apple Health | Integration ecosysteme, pas enfermement |
| 10 | FR + EN | Marche international des le lancement |

### Post-MVP Features

**Phase 2 (Growth) :**

| Feature | Raison du report | Dependance |
|---|---|---|
| Partage programme coach → equipe | Necessite infra multi-utilisateurs | Base utilisateurs etablie |
| App Apple Watch native | Tracking live au poignet | V1 valide HealthKit en lecture |
| Import Strava/Garmin | Recuperer l'historique existant | API tierces a integrer |
| Nutrition / plans alimentaires | Domaine a part entiere | Expertise IA a etendre |
| Video exercices integree | Production contenu lourde | Catalogue video a creer |
| Android | 2e plateforme | iOS valide en V1 |

**Phase 3 (Expansion) :**

| Feature | Vision |
|---|---|
| Marketplace programmes | Les coachs publient et vendent des programmes |
| Partenariats federations/salles | Distribution B2B |
| Dizaines de sports | Couverture quasi-universelle |
| IA Coach specialisee par sport | Prompts expert-level par discipline |

### Risk Mitigation Strategy

**Technical Risks :**

| Risque | Probabilite | Mitigation |
|---|---|---|
| GPS tracking batterie/precision | Moyenne | Spike Epic 0 avant tout dev |
| Qualite programmes IA | Moyenne | Spike Epic 0 : generer + faire valider par sportifs reels |
| Performance generation programme | Faible | Cible < 5s, Claude API deja eprouvee sur Flore/Coco |
| Sync offline complexe | Faible | SageCore SyncService identique GardenSage/TailorSage |

**Market Risks :**

| Risque | Mitigation |
|---|---|
| Marche sature d'applis sport | Positionnement unique : gratuit + multi-sport + IA |
| Adoption lente sans budget marketing | ASO + bouche a oreille + communautes sport |
| Retention insuffisante | Programmes adaptatifs + Coach proactif (push) |

**Resource Risks :**

| Risque | Mitigation |
|---|---|
| Dev solo = bottleneck | SageCore + Blueprint = demarrage rapide |
| Scope V1 trop ambitieux | Spike Epic 0 valide les 2 risques majeurs avant engagement |
| Burnout | Multi-sport extensible par prompts, pas par code |

## Functional Requirements

### 1. Profil & Onboarding

- **FR1:** L'utilisateur peut creer un profil sportif avec ses donnees personnelles (age, poids, taille, sexe)
- **FR2:** L'utilisateur peut selectionner un ou plusieurs sports pratiques parmi 10+ disciplines
- **FR3:** L'utilisateur peut declarer son niveau par sport (debutant, intermediaire, avance, expert)
- **FR4:** L'utilisateur peut definir ses objectifs (perte de poids, prise de masse, performance, bien-etre, preparation competition)
- **FR5:** L'utilisateur peut declarer son equipement disponible (salle, maison, exterieur, piscine, materiel specifique)
- **FR6:** L'utilisateur peut declarer ses contraintes physiques (blessures, douleurs, limitations)
- **FR7:** L'utilisateur peut definir sa frequence d'entrainement souhaitee et ses disponibilites
- **FR8:** L'utilisateur peut modifier son profil a tout moment

### 2. Coach IA Conversationnel

- **FR9:** L'utilisateur peut acceder a Coach via un bouton flottant global depuis n'importe quel ecran
- **FR10:** L'utilisateur peut converser avec Coach en langage naturel (FR et EN)
- **FR11:** Coach peut generer un programme d'entrainement personnalise a partir du profil utilisateur
- **FR12:** Coach peut adapter une seance en temps reel sur demande ("j'ai mal au genou", "je suis fatigue")
- **FR13:** Coach peut reorganiser le programme de la semaine quand des seances sont manquees
- **FR14:** Coach peut proposer un nouveau programme a la fin d'un cycle termine
- **FR15:** Coach peut repondre a des questions sur les exercices, les techniques et la progression
- **FR16:** Coach conserve le contexte de l'historique utilisateur (profil, programmes passes, progression, blocages)
- **FR17:** Coach peut generer des programmes pour des publics tiers (eleves, equipe) sur description de l'utilisateur

### 3. Generation de Programmes

- **FR18:** Le systeme peut generer des programmes pour 10+ sports : running, musculation, natation, velo, triathlon, tennis, yoga, athletisme, sports co (prepa physique), remise en forme
- **FR19:** Le systeme peut generer des programmes combines multi-discipline (triathlon, biathlon)
- **FR20:** Le systeme peut generer des programmes cibles sur une technique specifique (revers tennis, sprint, nage papillon)
- **FR21:** Le systeme peut generer des programmes ultra-progressifs pour debutants totaux
- **FR22:** Chaque programme genere inclut : exercices detailles, nombre de series/repetitions ou duree, temps de repos, progression sur N semaines
- **FR23:** Les programmes tiennent compte de l'equipement disponible declare par l'utilisateur
- **FR24:** Les programmes tiennent compte des contraintes physiques declarees

### 4. Tracking en Seance

- **FR25:** L'utilisateur peut lancer un tracking GPS pour les sports d'endurance (running, velo, natation exterieure)
- **FR26:** L'utilisateur peut enregistrer ses series, repetitions et poids pour les exercices de musculation
- **FR27:** L'utilisateur peut utiliser un chronometre et des intervalles pour les seances temporisees
- **FR28:** L'utilisateur peut enregistrer son effort percu (RPE) apres chaque seance
- **FR29:** L'interface de tracking s'adapte au type de sport en cours
- **FR30:** Le tracking fonctionne en mode offline (pas de connexion requise)

### 5. Suivi de Progression

- **FR31:** L'utilisateur peut consulter son historique complet de seances
- **FR32:** L'utilisateur peut visualiser sa progression via des graphiques (poids souleves, allure, distance, temps, VMA)
- **FR33:** L'utilisateur peut consulter ses records personnels par exercice et par sport
- **FR34:** L'utilisateur peut visualiser des tendances sur 4, 8 et 12 semaines
- **FR35:** Le systeme detecte et signale les progressions et les stagnations
- **FR36:** Le systeme calcule le taux de completion du programme en cours

### 6. Adaptation Dynamique

- **FR37:** Le systeme detecte les seances manquees et ajuste automatiquement le programme
- **FR38:** L'utilisateur peut signaler une fatigue ou une douleur et recevoir un programme adapte
- **FR39:** Le systeme ajuste la charge d'entrainement en fonction de la progression reelle
- **FR40:** Le systeme propose des exercices alternatifs en cas de contrainte nouvelle

### 7. HealthKit & Donnees Externes

- **FR41:** Le systeme peut lire les donnees HealthKit de toutes les sources (Apple Watch, Garmin, Fitbit, Samsung, Polar, Suunto, iPhone)
- **FR42:** Le systeme utilise les donnees HealthKit pour enrichir le suivi (frequence cardiaque, pas, distance, calories)
- **FR43:** L'iPhone seul (sans montre) fournit des donnees de base (podometre, distance, escaliers)
- **FR44:** L'utilisateur peut exporter ses seances vers Strava
- **FR45:** Le systeme ecrit les donnees d'entrainement dans Apple Health
- **FR46:** L'export Strava s'execute automatiquement au retour en ligne si fait offline

### 8. Notifications & Engagement

- **FR47:** L'utilisateur peut recevoir des rappels avant ses seances programmees
- **FR48:** Coach peut envoyer des notifications proactives apres une periode d'inactivite
- **FR49:** Le systeme notifie l'utilisateur quand un record personnel est battu
- **FR50:** L'utilisateur peut configurer ses preferences de notification

### 9. Authentification & Donnees

- **FR51:** L'utilisateur peut se connecter via Sign in with Apple
- **FR52:** L'utilisateur peut se connecter via email/password
- **FR53:** Les donnees utilisateur sont synchronisees entre iPhone et cloud (Supabase)
- **FR54:** L'utilisateur peut supprimer son compte et toutes ses donnees (RGPD)
- **FR55:** L'utilisateur peut utiliser l'app en mode offline avec synchronisation au retour en ligne

### 10. Localisation

- **FR56:** L'app est disponible en francais et en anglais
- **FR57:** Coach communique dans la langue choisie par l'utilisateur

## Non-Functional Requirements

### Performance

| Critere | Cible | Contexte |
|---|---|---|
| Generation programme par Coach | < 5 secondes | Appel Claude API — l'utilisateur attend le resultat |
| Lancement tracking en seance | < 1 seconde | L'utilisateur est pret a courir, ca doit etre instantane |
| Acquisition GPS (premier fix) | < 10 secondes | Standard iOS, CoreLocation |
| Affichage graphiques progression | < 2 secondes | Calcul local SwiftData |
| Export Strava | < 3 secondes | Appel API Strava |
| Ecriture Apple Health | Temps reel | API locale, pas de latence reseau |
| Demarrage app (cold start) | < 3 secondes | Standard plateforme Sage |

### Securite & Confidentialite

| Critere | Detail |
|---|---|
| Donnees sante HealthKit | Acces uniquement aux types declares, consentement explicite utilisateur |
| Donnees en transit | HTTPS/TLS pour toutes les communications (Supabase, Claude API, Strava API) |
| Donnees au repos | SwiftData chiffre par defaut (iOS Data Protection) |
| Authentification | Sign in with Apple + email/password via Supabase Auth (meme pattern SageCore) |
| RGPD — droit a l'oubli | Suppression complete compte + donnees en < 30 jours (pg_cron purge) |
| RGPD — consentement | Consentement analytics explicite a l'onboarding |
| Tokens/secrets | Jamais dans le code — xcconfig + .gitignore (meme pattern Sage) |
| Disclaimer medical | Affiche a l'onboarding et accessible dans les parametres |

### Integration

| Systeme | Type | Fiabilite requise |
|---|---|---|
| HealthKit (lecture) | API locale iOS | Haute — source de donnees primaire |
| HealthKit (ecriture) | API locale iOS | Haute — chaque seance doit etre enregistree |
| Strava (export) | API REST externe | Moyenne — retry automatique si echec, enqueue offline |
| Claude API (Coach) | API REST externe | Haute — sans Coach, pas de generation. Fallback : "Coach indisponible" |
| Supabase | API REST + Realtime | Haute — sync. Fallback : mode offline (SageCore SyncService) |

### Fiabilite

| Critere | Cible | Contexte |
|---|---|---|
| Tracking GPS sans crash | 100% | Une seance perdue = un utilisateur perdu |
| Zero perte de donnees de seance | 100% | SwiftData local + PendingOperation sync |
| Disponibilite Coach | > 99% (hors maintenance Claude API) | Degradation gracieuse |
| Sync offline → online | Aucune perte | SageCore last-write-wins |
