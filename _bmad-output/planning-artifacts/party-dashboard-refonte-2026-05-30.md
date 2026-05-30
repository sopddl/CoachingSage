# Party — Refonte UX du dashboard CoachingSage (vue Accueil)

**Date** : 2026-05-30
**Sujet** : refonte du dashboard principal (1er onglet TabView "Accueil") suite à test simu Sophie révélant clutter visuel + truncations + card Late agressive.
**Trigger** : screenshot `/Users/sophieslama/CL3/0.png` (mode EN) — Sophie : « j'aimerai qu'on revoie ensemble l'UX du dashboard ».
**Continuité** : 2ème party sur cette zone après [party-seances-dashboard-2026-05-07](party-seances-dashboard-2026-05-07.md). 3 semaines de code (Stories 3.8/3.10/3.11/3.12/3.15) ont révélé qu'on a empilé sans hiérarchiser.
**Statut** : décisions tranchées, prête pour implémentation Story 3.27.

---

## Casting

### User personas (`product-brief-CoachingSage-2026-03-21.md`)
- ⚖️ **Nathalie** — reprenante 52 ans, 0 programme, dashboard = onboarding déguisé.
- 🏃‍♂️ **Philippe** — runner du dimanche 48 ans, 1 programme structuré, veut action rapide.
- 🏊‍♀️ **Sophie-user** — triathlète 55 ans, 3 programmes parallèles, veut overview.
- 💪 **Maxime** — muscu 22 ans, 1 programme intensif, veut voir records monter.

### Voix produit/tech (continuité party 2026-05-07)
- 🎨 **Léna** — UX designer mobile (squelette + propositions de design).
- 📱 **Karim** — iOS engineer SwiftUI (faisabilité, coût, dépendances code).
- 📋 **Hugo** — PM CoachingSage (scope MVP, différenciateur produit, ranked-by-persona).

### Matos en main
- Screenshot mode EN état actuel
- party-seances-dashboard-2026-05-07.md (décisions précédentes sur cette zone)
- Mémoires `epic3_story310_done`, `epic3_story311_done`, `epic3_story312_done`, `epic3_story315_done`
- Backlog : `v2_chantier_seance_retard_moins_agressive`, `v2_chantier_i18n_contenu_programmes`

---

## Problème (cadrage v2)

> Le dashboard tente de remplir **3 fonctions concurrentes** (faire la prochaine séance + visualiser les programmes actifs + découvrir des suggestions) **sans hiérarchie claire** qui dit à l'utilisateur ce qu'il doit faire en premier. Résultat : clutter visuel, 6 truncations sur 1 écran, card Late dominante (4 lignes pleine largeur bleu marine), sensation « qu'est-ce que je fais là ? ».

### Vision Sophie (ajout cadrage v2)
Le dashboard = **vue centrale d'où on accède à tout ce qui compte**. Point d'entrée principal de l'app. Dense en valeur, pas en clutter.

### Pain points 1st-level constatés
- Mix FR/EN flagrant (titres FR figés en mode EN)
- 6 textes tronqués sur 1 écran (Triathlon — Distanc..., démarrer à l..., Load rebalan..., Prog..., ofile...)
- Card « Late » trop agressive (4 lignes pleine largeur bleu marine, multiplie par 4 la hauteur attendue)
- Wording regen cryptique (« Load rebalan... -25% »)
- FAB Léon occulte les labels tab bar (Programs/Profile)

---

## Tour de table — synthèse

### 🎨 Léna v1 — Proposition « séances 1-ligne + highlight »
Rejette card focal séparée au profit d'une 1ère ligne typo enrichie (highlight semibold + bg sur la prochaine séance, puis 1-ligne dense pour la suite). → **Rejetée Sophie** : « j'aime bien la card prochaine séance comme avant ».

### 🎨 Léna v2 — Card focal stable + spacing libéré
- Squelette : Carrousel programmes (agrandi) → Bandeau contextuel "PROGRAMME · SEMAINE N" → Card focal stable → Liste séances scrollable → Bottom sheet "Programmes préparés".
- Card focal **taille constante** (~140-160pt) peu importe l'état (Today / Late / Demain). État Late = badge couleur + pictogramme, pas expansion.
- → **Validée Sophie** avec amendements (terme « Programmes préparés », pas « Découvrir » ; carrousel agrandi).

### 🏃‍♂️ Philippe — 1 programme structuré
- Aime card focal compact stable.
- Demande différenciation typographique forte de la prochaine séance dans la liste.
- → Validé.

### 🏊‍♀️ Sophie-user — 3 programmes parallèles
- Aime carrousel + bandeau contextuel comme moteur d'interaction principal.
- Soulève question position initiale carrousel : **option B** retenue → ouvre sur le programme avec next session la plus proche.
- Cas « programme sans schedule » : la card focal = 1ère séance non-complétée du programme (cohérent Story 3.12 modèle S·J sans plannedDate).

### ⚖️ Nathalie — 0 programme
- Bottom sheet « Programmes préparés » = anti-pattern pour son cas.
- Demande mode dashboard différencié quand 0 actif : hero CTA + cards programmes préparés en avant.
- → **Validé Sophie** : option A (2 modes distincts). Mode `.empty` Story 3.15 préservé tel quel. Bottom sheet UNIQUEMENT en mode actif.

### 💪 Maxime — 1 programme intensif, motivation records
- Demande widget « Stats semaine » au-dessus card focal (3 stats : séances · temps · streak, tap → Progrès).
- → **Validé Sophie** (ferme T2 party 2026-05-07 si pas encore livré).
- Validation décision Replanifier : pas de bouton compact dans card focal, dans AdaptedProgramView uniquement.

### 📱 Karim — coût technique
- Inventaire impact code : Stories 3.8/3.10/3.11/3.12/3.15/3.22 touchées.
- Estimé Phase A : ~3j, Phase B : ~1.5j, Phase C : ~1.5j. **Total ~6j**.
- Soulève question architecturale : **option (a)** dashboard contient liste séances scrollable (cohérent « comme avant ») vs **option (b)** dashboard épuré, pousse vers AdaptedProgramView pour détails.
- → **Sophie tranche option (a)**. Conséquence : Story 3.12 partiellement défaite, +1.5j tech → estimé révisé ~6-7j.
- Note dépendance non-bloquante : i18n contenu programmes (titres FR figés en mode EN) = chantier indépendant ~1.5j.

### 📋 Hugo — scope MVP + priorisation par persona
- Validation différenciateur produit préservé (multi-sport visible, adaptatif, libre, grand public).
- Anti-pattern Runna UI bloated évité.
- Propose découpage 3 phases (A : structure principale / B : découverte + motivation / C : polish + non-régression).
- Wording « En retard » (factuel) défaut, possible évolution vers « À rattraper » (positif/encourageant) ultérieure.
- i18n contenu en Story 3.28 séparée juste après.
- → **3 propositions validées Sophie** en bloc (« ok tu peux traiter en mode sopddl ? »).

---

## Décisions finales (étape 5)

| # | Décision | Raison | Conséquence code |
|---|---|---|---|
| D1 | Carrousel programmes agrandi 180pt + ouvre sur next session la plus proche | Multi-sport visible | Story 3.10 étendue |
| D2 | Bandeau contextuel « PROGRAMME · SEMAINE N » entre carrousel et card focal | Liaison programme↔séances visible | Nouveau composant lié au binding programme sélectionné |
| D3 | Card focal séance STABLE ~140-160pt (badge + titre + meta + ▶) | Pain point #1 = expansion Late, pas la card | Refonte `NextSessionInlineCard` Story 3.22-G |
| D4 | Replanifier = AdaptedProgramView uniquement (pas sur dashboard) | Ne pas alourdir le hub | Suppression bouton Replanifier dans card focal |
| D5 | Liste séances scrollable sous card focal (option a) | « Comme avant avec scroll » Sophie | Rollback partiel Story 3.12, séances du prog sélectionné visible sur dashboard |
| D6 | Bottom sheet « Programmes préparés » (pas « Découvrir ») | Wording préservé Sophie | Pattern iOS `.presentationDetents`, label dynamique « (N) » ou « + Démarrer un nouveau » |
| D7 | Widget Stats semaine (séances · temps · streak) au-dessus card focal | Cas Maxime, ferme T2 party 2026-05-07 | Réutilise `WeeklyExecutionReport` Story 3.4 |
| D8 | 2 modes distincts : `.empty` (Story 3.15 préservé) vs `.actif` (refondu) | Nathalie ≠ Sophie-user | Bottom sheet uniquement en mode actif |
| D9 | Wording Late : « En retard » FR factuel défaut | Conserve actuel mais résout taille | Possible évolution V2 vers « À rattraper » plus encourageant |
| D10 | i18n contenu programmes Story 3.28 ~1.5j post-3.27 (hors scope cette story) | Refonte + i18n cumulés = blob trop gros | Séquence : 3.27 (refonte) → 3.28 (i18n) |

## Tensions résiduelles à clarifier en story

- **T-r1** : Sur dashboard option (a), affiche-t-on **toutes les semaines** du programme (scroll long) ou **seulement la semaine en cours** (+ bouton « voir suivantes ») ? **Défaut** : semaine en cours uniquement.
- **T-r2** : Affordance bottom sheet quand 0 programme préparé : transforme en « + Démarrer un nouveau programme » ? **Défaut** : oui (label dynamique).
- **T-r3** : Position widget Stats semaine : au-dessus card focal (visible immédiatement) vs entre carrousel et bandeau ? **Défaut** : au-dessus card focal.

---

## Découpage en phases — Story 3.27 ~6-7j

### Phase A — Refonte structure principale (~3-4j)
- Carrousel programmes agrandi 180pt + ouvre sur next session la plus proche
- Bandeau contextuel « PROGRAMME · SEMAINE N »
- Card focal séance stable taille constante (badge + titre + meta + ▶)
- Suppression bouton Replanifier sur dashboard
- Liste séances scrollable sous card focal (option a, scope semaine en cours)
- Wording « En retard » FR (« Late » EN reste tel quel)

### Phase B — Découverte + motivation (~1.5j)
- Bottom sheet « Programmes préparés » (`.presentationDetents` iOS 16.4+)
- Affordance dynamique : « Programmes préparés (N) » ou « + Démarrer un nouveau programme »
- Widget « Stats semaine » au-dessus card focal (3 stats inline → tap onglet Progrès)

### Phase C — Polish + non-régression (~1.5j)
- Tests unitaires (cards, view models)
- Snapshot tests FR + EN
- ui-reviewer 4 scenarios (mode `.empty`, mode actif 1 prog, mode actif 3 progs, état Late)
- Build + tests verts + merge main no-ff + push

### Hors scope cette story
- **Story 3.28** : i18n contenu programmes Phase A (~1.5j) — titres re-localisables au render via `AutoTitleBuilder` + `LanguageManager`. À planifier juste après pour ne pas ré-itérer sur l'i18n quand on aura refondu la card focal.
- Refonte card programme dans le carrousel (truncation « Triathlon — Distanc... ») → si encore problème post-Phase A, sous-tâche dans Phase C.
- Polish Léon FAB position (n'écrase plus tab bar) → V2 si besoin.

---

## Prochaines actions

1. ✅ Artifact party écrit (ce fichier).
2. ⏳ Update mémoire : créer `project_party_dashboard_refonte_2026_05_30.md` + entrée MEMORY.md.
3. ⏳ Créer branche `epic-3/story-3.27-dashboard-refonte`.
4. ⏳ Démarrer implémentation Phase A en mode SOPDDL pipeline auto.

---

## Risques / vigilance

- ⚠️ Option (a) défait partiellement Story 3.12. Vérifier qu'on ne casse pas un use case AdaptedProgramView important (replan dirigé, vue semaines passées).
- ⚠️ Wording « Late » vs « En retard » vs « À rattraper » : ton produit encourageant attendu, défaut factuel pour V1.
- ⚠️ Refactoring touche 6 stories récentes (3.8/3.10/3.11/3.12/3.15/3.22). Risque coût élevé, à scoper précisément en story dédiée avant de coder.
- ⚠️ Tests UI / snapshot tests à étendre fortement (regressions multi-prog, mode `.empty`, état Late, FR↔EN).
