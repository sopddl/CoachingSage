# Revue qualité 10 sports — PLAN de traitement (pour reprise post-/clear)

**Date** : 2026-06-08 · **Source** : passe qualité 40 agents (Sally+user+arbitrage).
**Données** : `passe-qualite-10-sports-RAW-2026-06-08.json` (57 décisions produit structurées),
`decisions-qualite-sports-2026-06-08.html` (vue), `rapport-qualite-10-sports-2026-06-08.md`.

## Les 57 décisions produit se regroupent en 6 thèmes

### 🚨 Thème 4 — EU MDR / médical (4 déc., URGENT, 1ER À TRAITER — décidé Sophie)
Contenu médical user-facing à bannir/reformuler :
- running : pathologies nommées + protocoles de soin + orientation médicale.
- hiit : safety_notes citent rhabdomyolyse, tendinite 10×, shin splints 25×, patellar tendonitis ; + citations académiques denses.
- football/hiit : pubalgie, LCA, commotion, RED-S + stats réduction blessure.
→ **Conformité, pas préférence** : bannir noms de pathologies + protocoles de soin, reformuler en signaux génériques (« si une gêne persiste, lève le pied »), via `template-quality-reviewer` (crible EU MDR). ⚠️ Édite des templates → voir séquencement i18n-b2 ci-dessous.

### ✅ Thème 1 — Affichage zones/intensité (DONE 2026-06-09, branche `chantier/zones-sensation`, commit `46b5edf`)
Code coach brut = libellé principal en séance partout : running (Daniels-E/@HMP/RPE), swimming (EN1/SP1/CSS), triathlon (3 systèmes FTP/Daniels/CSS mélangés), cycling (FTP/Sweet-Spot), muscu (RPE).
→ Décision = **politique d'affichage = sensation d'abord + code secondaire tappable** (= principe dosage caméléon étendu à tous les sports). Glossaire B2 tappable déjà en place (GlossaryTermBadge, SessionFocusView ~l.321). À VALIDER par Sophie.

### Thème 2 — Nommage / langue FR-EN (22 déc.)
Mélange FR/EN non tranché : cycling (Pont fessier FR vs Bird-dog/Dead bug/superman EN), swimming (DRYLAND/Y-T-W/serratus), béquille « (traduction anglaise) » dans titres FR partout.
→ UNE politique multisport (FR + terme EN consacré tappable ? FR seul + glossaire ?).

### Thème 3 — Vulgarisation jargon (7 déc.)
hiking summary saturé (LIT/ME/FKT/polarized), swimming (EVF/SPL/FCmax/mitochondrial), triathlon (T1/T2).
→ Niveau de vulgarisation + glossariser vs enseigner.

### Thème 5 — Titres / format champ (3 déc.)
cycling (rpm non défini), hiit (benchmarks FRAN/Cindy bruts), tennis (reps/duration = longue phrase → troncature UI).

### Thème 6 — Autres (4 déc.)
tennis (1 « exercice » = 3 mouvements concaténés), yoga (champ duration mélange unités ; liste 15-20 postures sans sections phase).

## Ordre décidé (Sophie 2026-06-08) : #4 EU MDR → #1 zones → puis #2/#3/#5/#6.

## ⚠️ Séquencement (rappel critique)
60/65 « bugs nets » de la passe + la plupart de ces décisions = **éditions de templates JSON**, or
ces fichiers sont **déjà retraduits sur `i18n-b2-templates` (pushée, NON mergée)**. → **merger i18n-b2
AVANT** d'éditer le contenu, sinon conflits massifs. (Le thème #1 zones peut se faire côté AFFICHAGE
sans toucher les templates = découplé.) Cf [[passe_qualite_10_sports_2026_06_08]].

## Prompt de reprise post-/clear
« On reprend la revue qualité 10 sports. Plan = `revue-qualite-10-sports-PLAN-2026-06-08.md`.
On commence par le thème 4 EU MDR (le plus urgent), puis thème 1 zones. »
