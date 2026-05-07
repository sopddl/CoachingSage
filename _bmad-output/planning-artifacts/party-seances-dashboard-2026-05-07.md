# Party — Refonte SessionView en dashboard « Séances »

**Date** : 2026-05-07
**Sujet** : refonte de l'écran SessionView (1er onglet TabView) en dashboard d'usage quotidien orienté « prochaine séance », mêlant programmes en cours et séances libres préparées.
**Trigger** : test simu Phase 2 #5 par Sophie (commit 17defa7) → constat « SessionView affiche 10 sports en grille avec “demande un programme” ×10, c'est moche, ça sert pas à grand-chose ».
**Statut** : décisions tranchées user-first, prête pour rédaction de story.

---

## Casting

### User personas (extraits `product-brief-CoachingSage-2026-03-21.md`)

- 🏊‍♀️ **Sophie** — triathlète intermédiaire 55 ans, 3 programmes parallèles (running + cycling + swimming), cas « N programmes simultanés ».
- ⚖️ **Nathalie** — reprenante 52 ans, 0 programme, peur de se blesser, cas « état vide bienveillant ».
- 🏃‍♂️ **Philippe** — runner du dimanche 48 ans, plan semi-marathon, cas « séance ratée → replan ».
- 💪 **Maxime** — jeune muscu 22 ans, 1 programme intensif, cas « suivi de progression visible ».

### Voix produit/tech

- 🎨 **Léna** — UX designer mobile (synthèse patterns concurrents + iOS HIG).
- 📱 **Karim** — iOS engineer SwiftUI (faisabilité, cache offline SwiftData).
- 📋 **Hugo** — PM CoachingSage (scope MVP / priorisation).

### Matos en main

- `product-brief-CoachingSage-2026-03-21.md` (5 personas)
- `epics-CoachingSage-v2-proposal.md` (ligne 317 onglet Aujourd'hui, FR36 % completion, FR12 adapt-session)
- `prd-CoachingSage.md` (FR11/12/36, cache offline)
- 5 décisions produit Sophie 2026-05-03/04 (`epic3_flow_choice_AB`)
- Mémoires Phase 2 #1→#5 livrées, équipement global ✓, autoprofil HK ✓, 40 templates v2 ✓
- Léon chat (Phase 2 #6) pas encore livré

---

## Problème (cadrage v2 après recadrage Sophie)

> L'utilisateur a besoin d'un écran « Séances » qui répond à **« qu'est-ce que je peux/dois faire à ma prochaine session ? »** — en mêlant ses programmes en cours (avec leur prochaine séance prévue) et ses séances libres préparées, avec **liberté de timing** (pas bloqué sur « aujourd'hui ») et **accès secondaire au calendrier** pour qui veut planifier.

### Recadrages clés Sophie pendant la party

- **Nom = Séances** (pas Aujourd'hui — laisse la liberté du rythme x/semaine)
- **Centre de gravité = prochaine séance** (pas la date du jour)
- **Progression triathlon = écran zoom séparé** (push depuis card programme), pas dans le dashboard
- **Calendrier = accès secondaire** (icône nav bar)

---

## Tour de table — synthèse

### ⚖️ Nathalie (challenge cadrage v2)

> « Centre = prochaine séance » ne marche pas pour moi qui ai 0 programme. Mon écran d'arrivée est un onboarding déguisé, pas un dashboard. La « liberté x/semaine » me décourage — j'ai besoin qu'on me dise « ta séance de marche c'est aujourd'hui, vas-y » sinon je procrastine.

### 🎨 Léna — réponse à Nathalie

Proposition : **2 modes du même squelette** (pas 2 écrans).
- **Mode première mise en route** (0 programme + onboarding récent) : hero CTA + 2-3 templates suggérés depuis autoprofil HK + onboarding ; lien secondaire « sur mesure » vers questionnaire universel.
- **Mode actif** (≥1 programme) : card prochaine séance dominante + cards programmes compactes + cards routines + « + » nav bar + icône calendrier.

Setting profil « Rappels de séances » (push notifs) en parallèle pour Nathalie — ne contamine pas la hiérarchie de l'écran.

### 🏊‍♀️ Sophie-user (benchmark concurrents)

J'ai utilisé TrainingPeaks 6 mois. Pattern Home tab : **Today + Tomorrow côte à côte**, event A-priority en haut, Calendar et Dashboard sont des tabs séparés. Runna (1 sport) : **rest day comme état narratif positif** (« récupère, hydrate-toi »).

### 🎨 Léna — synthèse 3 patterns marché

| Pattern | Apps | Pour CoachingSage |
|---|---|---|
| Today curated | Runna, Centr | Trop directif vs ta valeur « liberté x/sem » |
| Multi-day peek + sub-tabs | TrainingPeaks | ✅ Match cadrage |
| Routines + ad-hoc | Hevy | Le pattern « séances libres préparées » = Hevy "routines" |

5 principes retenus :
1. Rest day comme état explicite (Runna)
2. Show prochaine séance + une 2e (TrainingPeaks Today+Tomorrow)
3. CTA « Réorganiser ma semaine » visible (Runna réalignement)
4. Adopter le mot Hevy « Routine » plutôt qu'une invention
5. Calendrier = icône nav bar (pas un mode)

### 📋 Hugo — positionnement

Différenciateur CoachingSage **documenté noir sur blanc** :
- Nike Training Club critiqué : « no way to follow multiple programs simultaneously »
- Runna : 1 seul sport
- Centr : curated, tu suis ce qu'on te dit
- TrainingPeaks : multi-sport mais payant + overwhelming pour Nathalie

**Trou** : multi-sport + adaptatif + grand public + libre.
- L'écran Séances doit **rendre visible le multi-program comme une force**, pas le subir comme du clutter.
- **Anti-pattern à éviter** : « UI bloated » Runna récent. Ne pas réserver de place à Léon avant Phase 2 #6 livré.

---

## Tensions ouvertes (5) — toutes tranchées user-first

### 1. Onglet « Progrès »

**Options** :
- A. Agrégé multi-sport (HK + volume par sport + PRs)
- B. Liste de zooms par programme
- C. Hybride (widget léger + chart 4 sem + liste programmes)
- D. Placeholder Phase 3

**Reco initiale Léna** : C (hybride raisonnable Phase 2)
**🎯 Décision finale Sophie (user-first)** : **A — Agrégé multi-sport complet**

**Justification user-first** : le brief des 4 personas est explicite — tous demandent du visuel motivant (Sophie « progression 3 disciplines un seul écran », Maxime « courbe monter », Philippe « VMA et allure sur graphiques », Nathalie « kilos baisser et forme monter »). C sous-livre. A est ce qui marque le différenciateur « la seule app gratuite qui te montre ta progression sur tous tes sports ».

**Coût** : charts HK (RHR/HRV/Sleep), volume par sport, section PR/records → +3-5 jours d'impl vs C.

---

### 2. Mode actif Séances avec 1 programme

**Options** :
- A. Garder tel quel (1 prog + 1 routine + bouton + → maigre)
- B. Mini-widget « cette semaine » (3 stats sem)
- C. Card secondaire « Et après : mer. 8h » (TrainingPeaks Today+Tomorrow)
- D. Layout adaptatif (mini-aperçu hebdo)

**Reco initiale Léna** : B
**🎯 Décision finale Sophie (user-first)** : **B + C combinés**

**Justification** : combo réutilise composants existants. Sous la card prochaine séance : mini-widget stats sem (volume / séances / streak) **+** card secondaire compacte « Et après : mer. 8h Vélo endurance ». Le user voit ses stats **et** anticipe.

**Coût** : faible (composants déjà spec).

---

### 3. Tri des cards programmes dans Séances

**Options** :
- A. Par date prochaine séance (actionnable)
- B. Par sport favori (legacy `activeSports`)

**Reco initiale Léna** : B
**🎯 Décision finale Sophie (user-first)** : **A — Par date prochaine séance**

**Justification** : actionnable > sentimental. Sophie regarde l'écran le matin, voit en premier le programme qui réclame son attention aujourd'hui/demain.

---

### 4. Routines en mode vide (Nathalie)

**Options** :
- A. Jamais en mode vide
- B. Après 1ère séance complétée
- C. Dès l'onboarding
- D. Routines = Phase 3

**🎯 Décision finale Sophie (user-first)** : **A — Jamais en mode vide**

**Justification** : test des 4 personas en mode arrivée — Nathalie surchargée si on parle de routines, Maxime/Sophie/Philippe arrivent avec un programme en tête. Personne ne réclame de routine en arrivée.

---

### 5. « Réorganiser ma semaine »

**Options** :
- A. Phase 2 — drag & drop calendrier hebdo
- B. Phase 2 — version light (bottom sheet picker date)
- C. Phase 3 — CTA visible mais sheet « bientôt »
- D. Phase 3 — virer le CTA

**Reco initiale Léna** : D (laisser Léon adapt-week gérer)
**🎯 Décision finale Sophie (user-first)** : **A — Drag & drop calendrier hebdo, Phase 2**

**Justification** : complémentaire Léon, pas redondant.
- Drag & drop manuel = adaptation **timing** (« je pars en voyage mardi »)
- Léon = adaptation **contenu** (« j'ai mal au genou, change la séance »)

**Bonus** : composant calendrier hebdo réutilisable dans l'écran zoom programme + calendrier global (icône 📅).

**Coût** : +2-3 jours d'impl mais composant amorti sur 3 usages.

---

## Décisions

| # | Décision | Choix | Conséquence |
|---|---|---|---|
| 1 | Onglet Progrès | **A — Agrégé multi-sport complet** | Charts HK lourds Phase 2, +3-5j |
| 2 | Mode actif 1 prog | **B + C combinés** | Composants existants, faible coût |
| 3 | Tri programmes | **A — Par date prochaine séance** | Logique actionnable, simple |
| 4 | Routines mode vide | **A — Jamais** | Mode vide focus 100% démarrage |
| 5 | Réorganiser semaine | **A — Drag & drop hebdo Phase 2** | Composant réutilisable 3 usages |

**Coût total estimé refonte Séances + Progrès** : ~10-12j (vs 5j si on était resté sur recos initiales). Sophie : « je veux le mieux pour le user tant pis si plus de boulot ».

### Décisions structurelles tranchées en cours de party

- **Nom de l'écran** : « Séances » (pas « Aujourd'hui »)
- **Centre de gravité** : prochaine séance (pas la date du jour)
- **Tab bar** : 3 onglets (Séances · Progrès · Profil) + FAB Léon bleu coach `#1E5090` à cheval (pattern `FloreFloatingButton.swift` GardenSage transposé)
- **Léon visibilité** : pas d'entrée chat sur Séances tant que Phase 2 #6 pas livré (anti-pattern « UI bloated » Runna)
- **Multi-program assumé** : afficher plusieurs cards programmes empilées comme une force, pas un clutter (différenciateur vs Nike Training Club)
- **Progression triathlon détaillée** : écran zoom programme séparé (push depuis card), pas dans le dashboard
- **Calendrier** : icône nav bar = accès secondaire (drag & drop hebdo accessible aussi depuis « Réorganiser ma semaine »)

---

## Prochaines actions

1. **Rédiger la story** « Refonte SessionView → dashboard Séances + onglet Progrès » avec scope précis incluant les 5 décisions user-first.
2. **Mettre à jour les 2 maquettes HTML** :
   - `ux-design-CoachingSage-seances-dashboard-2026-05-07.html` — ajouter mini-widget cette sem + card "Et après" sur mode actif (avec n=1 prog), tri par date sur les 3 progs Sophie, garder le CTA « Réorganiser ma semaine ».
   - `ux-design-CoachingSage-progres-options-2026-05-07.html` — confirmer Option A comme reco finale (banner mis à jour).
3. **Décider du scoping** : 1 grosse story vs 2 stories (refonte Séances + Progrès séparément) pour pouvoir merger par incréments.
4. **Coût Phase 2 réajusté** : ~10-12j d'impl, à intégrer dans la roadmap Phase 2 #6 ou nouveau # à créer.
5. **Pas de code maintenant** — Sophie est en jump (Italie via Jump Desktop simu), latence pénible pour édition Swift volumineuse. Le code attend retour Mac local.

## Fichiers de référence

- `_bmad-output/planning-artifacts/ux-design-CoachingSage-seances-dashboard-2026-05-07.html` — maquette 3 modes Séances
- `_bmad-output/planning-artifacts/ux-design-CoachingSage-progres-options-2026-05-07.html` — 4 options Progrès
- `docs/brief-claude-design-seances.md` — brief image-gen Claude pour mockups Séances
- `_bmad-output/planning-artifacts/product-brief-CoachingSage-2026-03-21.md` — 5 personas
- `_bmad-output/planning-artifacts/epics-CoachingSage-v2-proposal.md` — SoT planning
