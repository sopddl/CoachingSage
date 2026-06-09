# Méthodo industrielle « Passe Sport » — standard de revue par sport

**Date** : 2026-06-07 — validée par Sophie (décisions ci-dessous).
**But** : arrêter le travail opportuniste sport-par-sport. Toute revue/refonte par sport
suit désormais ce processus. Premier emploi = chantier **dosage caméléon** (pilote muscu).

## Pourquoi
On réinventait à chaque sport : le panel de relecture, les critères, le suivi.
→ pas capitalisable. La méthode rend **3 assets partagés** + **1 pipeline figé** :
le sport N produit/affine les assets, le sport N+1 les réutilise.

---

## Asset 1 — Référentiel Dosage (sport-agnostique, fait UNE fois)
Le contrat de ce que l'écran FOCUS **doit** rendre. Deux matrices :

- **Matrice A — `dimension × mode`** : pour chaque dimension de dosage (charge, reps,
  séries, récup, allure/zone, RPE, respiration, côté, durée, distance, tempo), ce qui
  est **Affiché / Vocalisé / Masqué** en mode **Manuel / Minuté / Audio**.
  → c'est le « caméléon par mode ».
- **Matrice B — `sport × dimensions pertinentes`** : quelles dimensions s'appliquent à
  chaque sport (le foot n'a pas de « charge », la muscu pas d'« allure »).
  → c'est le « caméléon par sport ».

Source de vérité : `referentiel-dosage-cameleon-DECISIONS.html` (validé avant pilote).

## Asset 2 — Panel Personas standard (même casting à chaque sport)
- **Sally** — UX/design expert (skill `party`)
- **Expert métier du sport** — spécifique (coach running, prof yoga, prépa muscu…)
- **Maxime** (novice) + **Inès** (posé) — les 2 polarités de densité qui se contredisent
- **sophie-ux-challenger** — pre-screen avant Sophie

**Format** (décision Sophie) : **Combo** — party conversationnelle riche sur le **pilote**
pour caler la méthode ; **agents parallèles** sur les 9 sports de la série pour la vitesse.

## Asset 3 — Tracker unique
`chantier-dosage-cameleon-TRACKER.md` — matrice 10 sports × étapes du pipeline.
Source de vérité de l'avancement.

---

## Pipeline « Passe Sport » (identique à chaque sport)
1. **Capture réel** — scénario DEBUG `ui_review_session_hub_real_<sport>` (déjà codé) →
   screenshots FOCUS des patterns clés (Manuel/Minuté/Audio).
2. **Spec dosage** — remplir la grille pour ce sport (gaps vs référentiel).
3. **Revue comité** — panel standard (Asset 2) → findings P0/P1/P2.
4. **Décisions ouvertes → HTML décisions** (jamais d'arbitrage solo).
5. **Implem SOPDDL** — caméléon par mode.
6. **ui-reviewer READY** — obligatoire dès que `Views/**` touché.
7. **Device-test Sophie** — audio + dosage visuel.
8. **Merge + maj tracker + mémoire.**

## Déroulé du chantier dosage
- **Phase 0** — figer les 3 assets (référentiel validé HTML, panel, tracker). ← EN COURS
- **Phase 1 — pilote MUSCU** — sport entier pour roder la passe + valider la méthode.
- **Phase 2 — série** — les 9 autres ; parallélisable via workflow une fois la passe figée.
  Inclut explicitement les sports « co » (football) — aucun sport laissé de côté.

## Décisions Sophie 2026-06-07
- Sport pilote = **Muscu** (dosage le plus riche ET le plus manquant : charge/reps/séries/récup).
- Panel = **Combo** (party pilote + agents série).
- Référentiel = **validé avant le pilote** (HTML décisions).
