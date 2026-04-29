---
stepsCompleted: [1, 2, 3, 4, 5, 6]
lastStep: 6
status: complete
completedAt: '2026-03-21'
inputDocuments:
  - "product-brief-CL3-2026-03-04.md"
  - "product-brief-TailorSage-2026-03-08.md"
  - "sage-app-blueprint.md"
date: 2026-03-21
author: Sophie
project: CoachingSage
---

# Product Brief: CoachingSage

<!-- Content will be appended sequentially through collaborative workflow steps -->

## Executive Summary

**CoachingSage** est le coach sportif personnel gratuit que tout le monde merite. Application mobile iOS, elle accompagne chaque sportif — du debutant qui reprend la course a pied au triathlonien qui prepare sa saison, du jeune qui debute la musculation au prof de sport qui structure ses programmes — avec des plans d'entrainement 100% personnalises, un suivi de progression digne des meilleures applis payantes, et un expert toujours disponible dans sa poche : **Coach**. CoachingSage est la plus grand public des apps Sage : tout le monde fait du sport, personne ne devrait payer pour etre bien accompagne.

---

## Core Vision

### Problem Statement

Des millions de sportifs motives n'ont pas acces a un accompagnement personnalise. Les programmes generiques en ligne ne tiennent pas compte de l'age, du poids, de l'endurance, des objectifs ni du sport pratique. Le vrai coaching adapte est systematiquement derriere un paywall — et meme les applis payantes sont souvent mono-sport. Resultat : les sportifs improvisent, stagnent, se blessent ou abandonnent.

### Problem Impact

- Programmes inadaptes qui menent a la stagnation ou aux blessures
- Abandon par manque de suivi et de progression visible
- Certains sports sont des deserts (natation, triathlon combine) — aucune appli ne propose de programme structure
- Les coachs et profs de sport n'ont pas d'outil gratuit pour creer des programmes personnalises pour eux-memes
- Le suivi de progression de qualite est reserve aux abonnes premium (Strava, TrainingPeaks...)

### Why Existing Solutions Fall Short

Les applis sport payantes (TrainingPeaks, Freeletics, JEFIT, Zwift) offrent de la personnalisation mais derriere un abonnement. Les gratuites (version free de Strava, Nike Run Club) sont soit mono-sport, soit generiques sans vrai programme adapte. **Aucune solution gratuite ne combine programme personnalise multi-sport + suivi de progression + assistant IA conversationnel.** Chaque sportif doit jongler entre 2 ou 3 applis selon ses activites.

### Proposed Solution

CoachingSage repose sur **4 piliers** :

1. **Coach, l'expert IA personnel** — disponible a chaque instant, il connait l'age, le poids, le niveau, les objectifs et l'historique de l'utilisateur. Il adapte les programmes en temps reel ("Coach, j'ai mal au genou" → seance adaptee immediatement).
2. **Programmes d'entrainement personnalises multi-sport** — triathlon, musculation, natation, running, velo, yoga, sports co... Coach genere un programme complet calibre sur le profil reel de l'utilisateur, pas un template generique.
3. **Suivi de progression niveau premium** — tracking des performances, historique, graphiques d'evolution, le tout gratuit. Export natif vers Strava, Apple Health et autres applis sociales.
4. **Multi-sport dans une seule app** — fini de jongler entre 3 applis. Un triathlonien gere natation + velo + course au meme endroit. Un prof de sport structure tous ses programmes dans un seul outil.

### Key Differentiators

| Ce que les autres font | Ce que CoachingSage fait |
|---|---|
| Coaching personnalise payant | Coaching personnalise **gratuit** |
| Une appli par sport | **Multi-sport** dans une seule app |
| Programmes generiques gratuits | Programme genere sur mesure par Coach (age, poids, niveau, objectif) |
| Suivi premium derriere un paywall | Suivi de progression complet **gratuit** |
| L'utilisateur cherche seul | Coach repond et adapte en temps reel |
| Appli fermee | Export vers Strava, Apple Health — CoachingSage produit, les applis sociales partagent |
| Mono-usage : sportif OU coach | Sportif individuel ET prof de sport dans la meme app |

### Value Proposition

> *"CoachingSage, c'est Coach dans votre poche — il connait votre corps, votre sport, vos objectifs, et vous accompagne seance apres seance vers votre meilleure version. Gratuitement."*

---

## Target Users

### Utilisateurs Primaires

#### 🏊‍♀️ Persona 1 — Sophie, "La Triathloniene Autonome"

**Profil**
- 55 ans, dev solo iOS, vie active et chargee
- Triathloniene intermediaire — nage, roule et court regulierement
- Connectee, smartphone en permanence, habituee aux outils numeriques

**Sa situation**
- Utilise Strava pour tracker ses sorties mais les programmes adaptes sont payants
- Doit jongler entre 3 disciplines sans outil qui les combine
- Ne trouve rien de satisfaisant pour la natation

**Ses frustrations**
- Aucune appli gratuite ne propose de programme triathlon combine adapte a son age et son niveau
- Le suivi de progression entre les 3 disciplines est fragmente
- Les programmes generiques ne tiennent pas compte de ses contraintes (emploi du temps, fatigue, douleurs)

**Ce qu'elle veut**
- Un programme combine natation+velo+course calibre sur son profil reel
- Pouvoir dire "Coach, j'ai mal au genou" et recevoir une seance adaptee
- Exporter ses seances sur Strava pour garder son historique social

**Son moment "aha!"**
> Coach lui genere un programme 12 semaines triathlon adapte a son niveau et son emploi du temps. Elle voit sa progression sur les 3 disciplines dans un seul ecran.

---

#### 💪 Persona 2 — Maxime, "Le Jeune Muscu"

**Profil**
- 22 ans, etudiant, va en salle 4-5 fois par semaine
- Objectif prise de masse, regarde beaucoup de videos YouTube pour ses programmes
- Budget serre — ne veut pas payer un abonnement appli

**Sa situation**
- Copie des programmes trouves en ligne sans savoir s'ils sont adaptes a son niveau
- Progresse mais stagne depuis quelques mois
- Note ses seances dans les Notes de son telephone — pas de vrai suivi

**Ses frustrations**
- Les bonnes applis muscu (JEFIT, Strong, Hevy) sont toutes payantes pour les programmes personnalises
- Les programmes gratuits sont generiques : meme programme pour tout le monde
- Pas de suivi de progression qui lui montre concretement ou il en est

**Ce qu'il veut**
- Un programme adapte a ses objectifs (masse, force, esthetique), son experience et son equipement
- Un suivi visuel de ses progres (poids souleves, volume, progression par groupe musculaire)
- Coach qui adapte le programme quand il stagne

**Son moment "aha!"**
> Apres 4 semaines, Coach lui dit "tu as progresse de 15% au developpe couche, on passe au cycle suivant". Il voit la courbe monter.

---

#### 🏃‍♂️ Persona 3 — Philippe, "Le Runner du Dimanche"

**Profil**
- 48 ans, cadre, court le week-end et parfois en semaine le soir
- Objectif : courir un semi-marathon dans 6 mois
- A deja couru quelques 10km mais sans structure

**Sa situation**
- Court toujours a la meme allure, ne sait pas comment progresser
- A essaye des plans d'entrainement PDF trouves sur internet — trop rigides, il decroche
- Pas de feedback sur son evolution

**Ses frustrations**
- Les plans sont fixes : s'il rate une seance, tout le plan est decale
- Ne sait pas s'il progresse vraiment ou s'il tourne en rond
- Nike Run Club est sympa mais ne genere pas de vrai programme adapte

**Ce qu'il veut**
- Un plan semi-marathon adapte a son niveau et flexible si une seance saute
- Coach qui ajuste le programme semaine apres semaine selon ses retours
- Voir sa VMA et son allure progresser sur des graphiques clairs

**Son moment "aha!"**
> Il rate 2 seances en semaine. Au lieu de tout decaler, Coach reorganise la semaine restante. Il finit son semi sans se blesser.

---

#### 🎾 Persona 4 — Clara, "La Tenniswoman qui Veut Progresser"

**Profil**
- 35 ans, joue au tennis 2 fois par semaine en club
- Veut ameliorer son revers a deux mains qui est son point faible
- N'a pas les moyens de prendre un coach particulier regulierement

**Sa situation**
- Les applis tennis existantes sont des videos generiques
- Son prof en club n'a pas le temps de lui faire un programme individuel
- Elle ne sait pas quels exercices faire seule pour progresser sur un coup specifique

**Ce qu'elle veut**
- Un programme cible sur son revers : exercices specifiques, drills, renforcement musculaire associe
- Coach qui comprend le tennis et propose un mix technique + physique
- Pouvoir suivre sa progression sur ce point faible precis

**Son moment "aha!"**
> Coach lui propose 3 semaines de drills revers + renforcement epaule/poignet. En match, elle sent la difference.

---

#### ⚖️ Persona 5 — Nathalie, "La Reprenante qui Veut Perdre du Poids"

**Profil**
- 52 ans, secretaire, sedentaire depuis 10 ans
- Veut perdre 15 kilos, son medecin lui a dit de bouger
- N'est pas sportive du tout, a peur de se blesser

**Sa situation**
- A essaye des programmes YouTube "30 jours pour maigrir" — trop intense, elle a abandonne au jour 5
- Se sent jugee dans les salles de sport
- Ne sait pas par ou commencer sans se faire mal

**Ses frustrations**
- Les programmes gratuits supposent un minimum de condition physique qu'elle n'a pas
- Aucune appli ne s'adapte a quelqu'un qui part de zero
- Pas de progression visible rapidement → decouragement

**Ce qu'elle veut**
- Un programme tres progressif qui part de son niveau reel (quasi zero)
- Coach bienveillant qui ne la juge pas et qui celebre chaque progres
- Des seances courtes (15-20 min) qu'elle peut faire chez elle
- Voir les kilos baisser et la forme monter sur des graphiques motivants

**Son moment "aha!"**
> Apres 3 semaines, elle monte les escaliers sans etre essoufflee. Coach lui dit "tu faisais 10 minutes, maintenant tu tiens 25. Bravo."

---

### Utilisateurs Secondaires

#### 🏫 Le Prof de Sport en College
- 30-50 ans, gere plusieurs classes et niveaux
- Veut structurer ses programmes d'athletisme, musculation, endurance par classe
- V1 : utilise l'appli pour lui-meme. V2 : partage les programmes avec ses eleves/equipes

#### 🏅 Le Competiteur d'Athletisme
- Toutes tranches d'age, sprint/demi-fond/fond/lancers/sauts
- Cherche des programmes specifiques a sa discipline
- Suivi de performances precis (temps, distances, records personnels)

#### 🏊 Le Nageur Loisir
- Nage en piscine 2-3 fois par semaine pour rester en forme
- Aucune appli ne propose de programme natation structure gratuit
- Veut varier ses seances et progresser en technique

---

### Parcours Utilisateur — Synthese

| Etape | Sophie (Triathlon) | Maxime (Muscu) | Philippe (Runner) | Clara (Tennis) | Nathalie (Perte poids) |
|---|---|---|---|---|---|
| **Decouverte** | Recherche "triathlon programme gratuit" | Recommandation salle de sport | Bouche a oreille runners | Club de tennis | Conseil du medecin |
| **Onboarding** | Profil multi-sport, 3 disciplines, niveau | Profil muscu, objectif masse, equipement salle | Profil running, objectif semi, niveau | Profil tennis, coup a travailler | Profil debutant, objectif poids, pas de materiel |
| **1er usage** | Programme 12 semaines triathlon genere | Programme split 4 jours genere | Plan semi-marathon 6 mois genere | Programme revers 3 semaines genere | Programme marche+renforcement 15 min/jour |
| **Moment aha!** | 3 disciplines sur 1 ecran | Courbe de progression qui monte | Seance ratee → Coach reorganise | Difference en match apres 3 semaines | Escaliers sans essoufflement |
| **Export** | Strava pour chaque sortie | Apple Health pour le suivi | Strava pour les courses | — | Apple Health pour le poids |
| **Long terme** | Saisons, objectifs courses | Cycles force/masse/seche | Du semi au marathon | Tous les coups, preparation physique | Autonome, passe a des sports |

---

## Success Metrics

### Succes Utilisateur

| Utilisateur | Signe de succes | Comportement mesurable |
|---|---|---|
| Sophie (Triathlon) | Suit son programme combine regulierement | Complete 80% des seances sur 4 semaines |
| Maxime (Muscu) | Voit sa progression concretement | Consulte ses graphiques de progression au moins 1x/semaine |
| Philippe (Runner) | Finit sa course objectif | Valide son objectif (semi, 10km...) dans l'app |
| Clara (Tennis) | Progresse sur son coup faible | Termine un programme cible de 3+ semaines |
| Nathalie (Perte poids) | Tient dans la duree | Active depuis 30 jours avec 3+ seances/semaine |

**Indicateurs cles de valeur reelle :**
- Taux de completion de programme > 50% (vs abandon typique ~70% sur les applis sport gratuites)
- Utilisateur revient sur un 2eme programme dans les 30 jours suivant la fin du 1er
- Au moins 1 export Strava/Apple Health par utilisateur actif (signe d'integration dans sa routine)

---

### Business Objectives

- **Phase 1 (0–12 mois)** : Croissance maximale, 100% gratuit, acquisition utilisateurs et retention. La valeur c'est la base utilisateurs, pas le revenu.
- **Phase 2 (12–24 mois)** : A definir selon la taille de la base. Options possibles : freemium (programmes avances, coaching IA illimite), partenariats (salles, marques sport), ou levee de fonds si la base est suffisante.
- **Marches cibles** : France en priorite + anglophone (UK, USA, Canada, Australie) simultanement — le sport est universel, pas de barriere culturelle
- **Notoriete** : App Store + communautes sport (Strava, Reddit r/running, r/fitness, Instagram fitness)

---

### Key Performance Indicators

| KPI | Cible 6 mois | Cible 12 mois | Ref GardenSage / TailorSage |
|---|---|---|---|
| Utilisateurs actifs mensuels (MAU) | 15 000 | 75 000 | 5K-3K / 25K-15K |
| Taux de retention a 30 jours | > 40% | > 50% | 35%-40% / 45%-50% |
| Programmes generes par Coach | 30 000 | 200 000 | N/A |
| Taux de completion de programme | > 40% | > 50% | N/A |
| Utilisateurs avec 2+ programmes | > 25% | > 40% | N/A (30%-45% TailorSage) |
| Exports Strava/Apple Health | > 30% des actifs | > 50% des actifs | N/A |
| Sports couverts utilises | 10+ | 20+ | N/A |
| Note App Store | > 4,3 | > 4,5 | idem |
| Langues | FR + EN | FR + EN | idem |

> **Pourquoi des cibles beaucoup plus hautes que GardenSage/TailorSage ?** Le marche sport est 10-50x plus large que jardinage ou couture. "Gratuit + multi-sport + IA" est un positionnement unique qui peut generer du bouche a oreille viral. La retention cible est haute car le sport est une activite reguliere (quotidienne/hebdomadaire) contrairement au jardinage (saisonnier).

### MVP Success Criteria

L'MVP est valide et pret a scaler quand :
- 15 000 utilisateurs actifs mensuels atteints
- Taux de retention a 30 jours > 40%
- Taux de completion de programme > 40%
- Au moins 5 sports differents activement utilises
- Note App Store >= 4,3

---

## MVP Scope

### Core Features — V1

| # | Fonctionnalite | Detail |
|---|---|---|
| 1 | **Profil sportif** | Onboarding guide : age, poids, taille, niveau, sport(s) pratique(s), objectifs, equipement disponible, frequence souhaitee, contraintes (blessures, temps), langue |
| 2 | **Coach, l'assistant IA** | Bouton flottant global (comme Flore/Coco). Conversationnel, personnalise, adapte en temps reel. "Coach, j'ai mal au genou" → seance modifiee. 3 modes : Generation / Suivi / Urgence |
| 3 | **Generation de programmes multi-sport** | Coach genere des programmes complets personnalises. 10+ sports au lancement : running, musculation, natation, velo, triathlon, tennis, yoga, athletisme (sprint/fond/lancers), sports co (prepa physique), remise en forme/perte de poids |
| 4 | **Programmes combines** | Pour le triathlonien ou le sportif multi-discipline : un seul programme qui equilibre les disciplines sur la semaine |
| 5 | **Tracking en seance** | Chronometre, compteur de reps/series, GPS pour les sports d'endurance, temps de repos, RPE (effort percu). Interface adaptee au sport en cours |
| 6 | **Suivi de progression** | Historique complet, graphiques d'evolution (poids souleves, allure, distances, temps, VMA...), records personnels, tendances sur 4/8/12 semaines |
| 7 | **Adaptation dynamique** | Coach ajuste le programme selon : seances manquees, fatigue declaree, progression reelle, blessures. Pas de plan rigide — le programme vit avec l'utilisateur |
| 8 | **Export Strava & Apple Health** | Export natif des seances vers Strava (activites) et Apple Health (donnees sante/fitness). CoachingSage produit, les applis sociales partagent |
| 9 | **Langues** | Francais + Anglais des le lancement |

---

### Out of Scope pour V1 — Roadmap V2+

| Fonctionnalite | Version cible | Raison du report |
|---|---|---|
| Partage programme coach → equipe | V2 | Le prof de sport utilise l'app pour lui en V1, partage avec ses eleves/joueurs en V2 |
| Nutrition / plans alimentaires | V2 | Domaine a part entiere, necessite expertise specifique |
| Video des exercices integree | V2 | Production de contenu lourde — V1 se concentre sur les descriptions texte + illustrations |
| Apple Watch app native | V2 | Le tracking V1 se fait sur iPhone, l'Apple Watch enrichira l'experience en V2 |
| Import depuis Strava/Garmin | V2 | V1 = export seulement. Import pour recuperer l'historique existant en V2 |
| Communaute / social | V3 | Pas dans la vision produit — CoachingSage reste un outil personnel |
| Marketplace de programmes | V3 | Necessite masse critique de coachs et utilisateurs |
| Android | V2 | iOS first comme GardenSage et TailorSage |
| App Web | V2 | Mobile first |

---

### Future Vision

> **CoachingSage V2** : Coach voit l'equipe — le prof de sport partage ses programmes, l'Apple Watch track en temps reel, l'import Strava/Garmin recupere l'historique. La nutrition complete l'accompagnement.

> **CoachingSage V3** : La reference mondiale du coaching sportif gratuit. Des dizaines de sports, des millions d'utilisateurs, des partenariats avec des federations et des salles de sport.
