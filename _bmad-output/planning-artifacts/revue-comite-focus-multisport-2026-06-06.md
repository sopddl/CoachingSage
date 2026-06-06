# Revue comité — écran FOCUS multi-sport (image / texte / layout)

**Date** : 2026-06-06
**Déclencheur** : Sophie — « faire une passe par sport et faire revoir par un comité d'agents user/designer », après la passe yoga (description « Comment l'exécuter » dépliée d'emblée pour le yoga).
**Méthode** : 5 captures réelles simu (FR) des patterns FOCUS + 3 agents en parallèle (Sally designer / comité 4 users / sophie-ux-challenger).
**Captures** : `/tmp/yoga_focus_desc_fr.png` (yoga tenue, desc dépliée), `/tmp/focus_hiit.png` (HIIT effort, desc repliée), `/tmp/focus_audio.png` (running audio minimal), `/tmp/focus_runwalk.png` + `/tmp/focus_strength.png` (échauffements guidés à puces). NB : écran de SÉRIE muscu non atteint (échauffement 5 min non skippable au tap « Avancer » — bug comportemental à logger).

---

## Convergence des 3 agents

| Thème | Sally (design) | Comité users | Challenger |
|-------|----------------|--------------|------------|
| **Dosage manquant** (combien/intensité) | — | **#1 — trou structurel 3/4 modes** | — |
| **Déplié yoga vs replié autres** | exception OK mais reformuler « statique/long → déplié » | Inès : OK déplié, mais surchargé | **BLOCKING** : règle scope ? |
| **Couleur titre incohérente** | P1-a (phase vs sport) | — | P1 |
| **Vide écran audio** | P1-c | Philippe : anxiogène si voix coupe | P1 |
| **Jargon non glossarié** | — | Maxime : « band/glutes » | **P0** : glutes/band/mobilité/Récup/Bloc tempo |
| **Scroll yoga / étape 4 tronquée** | P1-b | — | suggestion (vérifier) |

## Findings détaillés

### Décisions produit (Sophie requise)
- **D-EXPAND (BLOCKING challenger)** : « Comment l'exécuter » déplié par défaut = yoga uniquement, OU règle « phase statique/longue → déplié, effort court → replié » (reco Sally, cohérente cross-sport), OU flag `autoExpand` par template (plus fin). Sally : l'argument « yoga postural » n'extrapole pas (un burpee est postural aussi) ; la vraie règle = **statique/long vs dynamique/court**.
- **D-DOSAGE (finding #1 comité)** : l'écran dit toujours QUOI + COMBIEN DE TEMPS, presque jamais le DOSAGE exécutable sans coach : Maxime→**charge** + « Série N/total » ; Dorian→**reps/AMRAP** + **durée récup** ; Philippe→**allure/zone/distance** (filet si la voix coupe) ; Inès→**respirations** (tenue en souffles, pas en s) + **quel côté**. Désaccord densité (Maxime +chiffres) ⟷ calme (Inès −texte, didactique à la voix) → assumer le **caméléon par mode jusqu'au dosage**, pas seulement jusqu'à l'illustration.
- **D-COULEUR** : `phaseTint` déterministe par `phase.kind` (warmup→orange, work→bleu, hold→vert). Mais « Échauffement » running est une phase `.work` (bleu) alors qu'ailleurs c'est `.warmup` (orange) → même mot, 2 couleurs. Trancher : la couleur encode la PHASE (humaine) ou le KIND technique ?

### Quick wins non bloquants
- **Vide audio** : 1 ligne de consigne sous la barre (« Allure facile, laisse la voix te guider ») — cohérent cross-sport.
- **Jargon** : entrées glossaire `glutes`, `band`, `mobilité`, `Récup`, `Bloc tempo` (Story 3.24a en avait déjà flaggé — ont glissé).
- **Scroll yoga** : fade/indicateur de scroll (étape 4 coupée sans indice) — c'est du scroll, pas une troncature de rendu (virgule = suite plus bas).
- **Style puce active** divergent runwalk (gras noir) vs strength (orange+gras) → unifier.
- **Hors persona** : puce « Ne jamais sauter cette étape » = consigne mélangée aux items d'échauffement (strength).

## Verdicts agents
- **Sally** : NEEDS_FIX (P1 only, proche READY). Reco : 2 règles déterministes (couleur=phase ; déplié=statique/long).
- **Comité users** : trou n°1 = dosage ; désaccord densité/calme → caméléon par mode.
- **Challenger** : NEEDS_FIX + **BLOCKING_SOPHIE_REQUIRED** sur la règle de déploiement.

## Reste
Test EN non fait (CLAUDE.md demande FR+EN avant livraison). Écran série muscu non atteint. Voix yoga D3 = device Sophie.
