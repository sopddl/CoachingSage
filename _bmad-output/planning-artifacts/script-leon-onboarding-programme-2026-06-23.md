# Script de Léon — Onboarding PROGRAMME (mot-à-mot) — CoachingSage

**Date** : 2026-06-23
**Périmètre** : création d'un programme (≠ onboarding app, déjà scripté dans `script-leon-onboarding-app-2026-06-23.md`).
**Sources** : `party-onboarding-elargi-2026-06-22.md` (zones franches, restitution, log demandes) · `party-densite-integration-onboarding-2026-06-23.md` (densité = brique, D1→D5) · **maquette `maquette-onboarding-template-2026-06-22.html` (colonnes « Programme · au départ » + « Programme · la proposition »)** · voix réelle de Léon (code).

> ✅ **Statut** : mot-à-mot **révisé** (3 lentilles/modèles : UX-challenger Opus · personas Maxime/Nathalie/Inès **Sonnet** · MDR-RGPD), corrections appliquées, **2 décisions Sophie tranchées** (densité = reco D4 ; multi-sport = combiné). Reste à faire côté implem : faisabilité moteur multi-sport + filets MDR. Pas encore implémenté. Rendu final = device-test.

---

## Frontière & contexte

- **Atteint DANS l'app** → **garde la barre du bas** (3 onglets réels Accueil/Progrès/Profil + **FAB Léon**). On n'est jamais coincé : retour Accueil direct.
- **Démarre APRÈS l'onboarding app** : on sait déjà les sports, la lecture des séances, le PARQ. Léon **pré-remplit** le reste (rythme/durée) depuis ce qu'on sait → l'user corrige.
- **Le NL libre est la feature phare** (≠ app, qui ne demandait que sport+accord).
- **Zéro saisie corporelle** (rappel transversal). Les justifications de Léon ne citent **JAMAIS** une donnée corporelle (MDR) — au plus « vu ton activité récente ».

## Structure (maquette) — un écran, deux zones franches

**Header** : « Ton nouveau programme » · ‹ retour · barre du bas visible.
**① TA DEMANDE** (en haut) : champ libre multi-ligne + carrousel de TES sports.
**② CE QUE LÉON PROPOSE** (en bas, fond bleuté + avatar L) : restitution ✓/⏳/🚫 + récap éditable.
**Aperçu vivant** : on modifie la demande → la proposition **se recompose**. **Rien n'est figé avant le vert** (« Créer mon programme → »).

---

# ÉTAT A — AU DÉPART (champ vide, Léon attend)

### Zone ① — Ta demande
`[Champ libre, placeholder]` : **Tape un sport 👆 ou dis-moi ce que tu voudrais faire**
`[Carrousel]` : tes sports (swipeable) + tuile **＋ Autre**. Tuiles **même taille** qu'à l'accueil (`SportTileView`). **Le carrousel prime visuellement** : taper un sport suffit, le texte libre est optionnel — garde-fou page blanche (Nathalie) **et** évite qu'une débutante fragile tape « maigrir » et tombe direct sur un 🚫 (Inès). *(Le placeholder ne présuppose plus un brief d'expert « 2×/sem, 45 min » — findings Nathalie + UX.)*

### Zone ② — Ce que Léon propose (en attente)
**Avatar L · titre « Ce que je te propose »**
**L:** Dis-moi ce que tu veux, ou choisis un sport 👆 — je te prépare une proposition aussitôt.

`[UX]` Bouton vert **« Créer mon programme → » grisé** tant qu'il n'y a pas de proposition. Le carrousel = **la porte rassurante** : taper un sport suffit à amorcer (le texte libre n'est jamais obligatoire — garde-fou page blanche, Nathalie).

---

# ÉTAT B — LA PROPOSITION (demande remplie → Léon restitue)

### Zone ② — restitution : 3 réponses possibles

Léon ouvre toujours par une **ligne de restitution** (qui dit ce qu'il a compris), puis le **récap éditable**.

**✓ Ce que je fais** (demande dans mon périmètre) :
> **L:** ✓ Vélo + course, noté.

**⏳ Pas encore** (hors périmètre actuel → **loggé en backlog**, idée Sophie) :
> **L:** ⏳ Tes vacances, je ne sais pas encore les gérer sur une période précise — je note l'idée.

> *(« je note l'idée » remplace « pour bientôt » : les 2 personas le lisaient comme une promesse marketing creuse.)*

**🚫 Je ne fais pas ça** (refus sécurité MDR — **2 familles**) :
> **L (objectif risqué — famille 1) :** 🚫 Ça, je ne le promets à personne — même les meilleurs coachs ne le feraient pas honnêtement. Ce que je sais faire : te bâtir un rythme d'entraînement régulier et tenable. On part là-dessus ?
>
> **L (blessure / douleur / pathologie — famille 2) :** 🚫 Pour tout ce qui touche à une blessure, une douleur ou une santé fragile, je ne suis pas le bon interlocuteur — vois ça avec un pro de santé. Pour la forme générale, je peux te bâtir un rythme régulier si tu veux.

`[MDR]` Le 🚫 vaut pour **2 familles** : **(1)** objectif de résultat santé/poids chiffré et daté (« perdre 5 kg en 3 semaines »), intensité dangereuse (« le truc le plus dur »), promesse médicale ; **(2)** finalité de santé / pathologie / rééducation / douleur (« gérer mon diabète », « mal au dos », « post-opératoire »). Léon **mappe vers le sûr**, **n'invente pas**, **ne diagnostique pas**, **ne compose JAMAIS un programme à visée thérapeutique**, ne renvoie pas un mur d'avertissement — il reformule (famille 1) ou oriente vers un pro de santé (famille 2). **Jamais d'allégation de bénéfice santé** (« qui te fait du bien », « on progresse pour de vrai » = bannis : promesse de résultat). *(Famille 2 = CRITIQUE MDR ajouté post-revue : sans elle, le NL libre faisait composer un programme à finalité thérapeutique → risque de requalification en dispositif médical.)*
`[Backlog]` ✓/⏳/🚫 : chaque ⏳ et 🚫 → 1 ligne `leon_unmet_requests` avec **`category`** (`periodisation_temporelle`/`multi_sport_combine`/`nutrition`/`weight_loss`/`health_condition`/`unknown`) + `response` (`not_yet`/`refused_safety`). **Schéma RGPD strict (post-revue)** : **AUCUN champ texte libre** (pas de `raw_text`/`verbatim`/`note`) — uniquement enums fermés + timestamp ; mapping LLM raté → `category=unknown` **sans** verbatim de repli. Consentement explicite, **finalité nommée** (« priorisation produit »), **rétention bornée**, **pseudonymisation vs `program_id`** (sinon `weight_loss`+`program_id` ré-identifie un objectif santé — art. 9 RGPD). **Catégorie ≠ verbatim santé.**

### Récap éditable (chaque ligne ✎, avec justification « why »)
| Champ | Valeur (exemple) | ✎ | Why (affichée SEULEMENT si Léon pré-remplit en autonomie) |
|---|---|---|---|
| Semaine | 2 × 45 min | ✎ | *(rien — repris de ta demande)* |
| Week-end | 1 × 1h30 | ✎ | *(rien — repris de ta demande)* |
| Durée | Routine 3 mois | ✎ | par défaut, modifiable |

`[UX]` Tout éditable (crayon ✎), **rien figé** avant le vert. Modifier une ligne → la proposition se recompose. **La colonne « why » n'apparaît que sur les lignes pré-remplies par Léon** — pas sur celles reprises mot pour mot de la demande (« comme demandé » = bruit sans valeur, finding UX). La justif **ne cite jamais** une donnée corporelle (au plus « par défaut »).

### La densité, absorbée (brique D4 — PAS de carte/toggle, juste une phrase de Léon)
Quand le signal comportemental unique (`weeklyWorkoutsAverage4w`) indique un user déjà actif, Léon le **reconnaît dans sa restitution** (jamais un réglage) :
> **L (sans objectif explicite) :** ✓ Muscu, 4 fois. Je vois que tu fais déjà du sport — je te prépare des séances un peu plus complètes.
>
> **L (avec un objectif, ex. « je veux gagner en force ») :** ✓ Muscu 4×, orienté force comme tu veux. Et comme tu fais déjà du sport, je densifie un peu les séances.

`[PRINCIPE — Sophie 2026-06-23]` **Léon s'adapte à l'INTENTION, jamais à un bouton.** Pas de curseur « +/− » (ça réintroduirait le réglage manuel tué par la party, D1-D5) : on a **retiré** « tu peux m'en demander plus ou moins » ; l'ajustement se fait en **affinant l'intention** dans la zone demande → Léon **recompose** (aperçu vivant).
`[Réalité moteur — vérifiée 2026-06-23]` **2 mécanismes DISTINCTS, ne pas les conflater** : (1) l'**objectif** (`goals.primary`) **choisit le template** orienté (force / endurance…) — c'est réel, granularité = sélection ; (2) la **densité** vient du **signal comportemental** (`weeklyWorkoutsAverage4w`), **pas** de l'objectif. Donc Léon dit « orienté force » (vrai : template) **et** « je densifie car tu fais déjà du sport » (vrai : comportement) — **deux clauses séparées**. Léon **ne doit PAS** dire « je densifie pour ton objectif » (faux : la densité n'est pas calculée depuis le goal). Jamais d'appréciation physiologique.
`[MDR]` Signal = **les séances** (comportement), **jamais** poids/IMC. « Je vois que tu fais déjà du sport » = reco D4 ratifiée Sophie (prime sur le P0 UX-challenger : comportemental MDR-safe + besoin de reconnaissance Maxime). Jamais d'appréciation **physiologique** (« t'es en forme », « ton cardio est bon » = bannis). Validée **au vert**. **Aucune** carte densité, **aucun** toggle, **aucun** contrôle par séance (UI densité = jetée, cf. D2).

### Multi-sport via la bulle (conservé)
> **L (V1 — moteur mono-sport, le vrai comportement) :** ⏳ Vélo + course ensemble, je ne sais pas encore composer un vrai combiné — pour l'instant je gère **un sport à la fois**. On commence par lequel ? (Je note ta demande de combiné.)
>
> **L (V2 — cible, quand le moteur saura) :** ✓ Vélo + course : je combine les deux sur la semaine en gérant la récup, pour que ça serve ton objectif.

`[Réalité moteur — vérifiée 2026-06-23]` Le moteur est **strictement mono-sport** (1 `sportCode` par programme/profil ; triathlon = template figé pré-construit, pas une compo user). **Le combiné multi-sport n'est PAS générable en V1.** → **V1 = la réponse ⏳ honnête** ci-dessus (« un sport à la fois », log `multi_sport_combine` → backlog), **combiné = V2** (cible, priorisée par le log). **Jamais** présenter une alternance/juxtaposition comme un vrai combiné, **jamais** de fallback 1-prog/sport silencieux. **Comportement V1 = ⏳ tranché Sophie 2026-06-23.**

### Validation
→ bouton vert **« Créer mon programme → »** (actif dès qu'une proposition existe). **Seul moment ferme.**

---

# GALERIE D'EXEMPLES (demande → restitution) — pour caler le ton

**Ex.1 — simple, dans le périmètre**
> *Demande* : « yoga 3× par semaine le matin »
> **L:** ✓ Yoga, 3 fois par semaine. Je te cale des séances courtes pour le matin.

**Ex.2 — multi-sport + période non gérée (✓ + ⏳)**
> *Demande* : « vélo + course, 45 min × 2 en semaine, 1h30 le week-end. Vacances 1→22 août : 3×2h/sem »
> **L:** ✓ Vélo + course, noté. ⏳ Tes vacances, je ne sais pas encore les gérer sur une période précise — je note l'idée.

**Ex.3 — user actif + objectif (template orienté objectif + densité comportementale, 2 clauses)**
> *Demande* : « muscu 4× par semaine, je veux prendre de la force »
> **L:** ✓ Muscu 4×, orienté force comme tu veux. Et comme tu fais déjà du sport, je densifie un peu les séances.

**Ex.4 — objectif risqué (🚫 famille 1)**
> *Demande* : « fais-moi perdre 5 kg en 3 semaines »
> **L:** 🚫 Perdre 5 kg en 3 semaines, je ne le promets à personne — même les meilleurs coachs ne le feraient pas honnêtement. Ce que je sais faire : te bâtir un rythme d'entraînement régulier et tenable. On part là-dessus ?

**Ex.4-bis — blessure / santé (🚫 famille 2, ajouté post-revue MDR)**
> *Demande* : « je veux me remettre au sport mais j'ai mal au dos depuis 1 an »
> **L:** 🚫 Pour une douleur qui dure, je ne suis pas le bon interlocuteur — un pro de santé saura te guider là-dessus. Le jour où tu as le feu vert, je te bâtis un rythme tout en douceur avec plaisir.

**Ex.5 — page blanche (carrousel seul, sans texte)**
> *Action* : tape « Course » dans le carrousel, champ vide
> **L:** ✓ Course, c'est parti. Je te propose un point de départ tranquille — tu ajustes le rythme comme tu veux.

---

# Décisions Sophie — TRANCHÉES (2026-06-23)

1. **Densité = reco D4 ratifiée.** Léon **reconnaît** explicitement : « je vois que tu fais déjà du sport → séances un peu plus complètes », validée au vert, ajustable en langage naturel. Prime sur le P0 UX-challenger / le feedback générique pour ce cas (signal comportemental MDR-safe, besoin de reconnaissance Maxime).
2. **Multi-sport** : moteur vérifié 2026-06-23 = mono-sport strict → combiné NON générable en V1. **Comportement V1 tranché Sophie = ⏳ « un sport à la fois »** (« on commence par lequel ? » + log `multi_sport_combine`). **Combiné = cible V2**, priorisée par le log des demandes. Pas de fallback 1-prog/sport, pas d'alternance déguisée en combiné.

# Tranché par les revues (pas besoin de toi)

- **Registre du 🚫** : aligné sur le ton chaleureux + zéro allégation santé (Inès + MDR A1). 2 familles de déclencheur (objectif risqué / pathologie).
- **Frontière MDR pathologie** (famille 2) : ajoutée — non négociable (risque dispositif médical).
- **Log RGPD** : schéma sans verbatim, enums fermés, pseudonymisation.
- **Why récap** : affichée seulement sur les lignes pré-remplies par Léon.

# Parqué (D5-a)

- **Densité figée-compo vs vivante-sur-activité** : si l'activité change en cours de programme, Léon redensifie-t-il ? (réactif completion+RPE existe déjà ; variation explicite sur période = ⏳). Hors V1.

---

# i18n

FR mot-à-mot (référence). EN/ES = traduction mécanique à l'implémentation, registre tutoyé/chaleureux conservé.

---

# Journal de revue multi-agents/multi-modèles (2026-06-23)

3 lentilles, **agents ET modèles distincts** (règle Sophie).

### `sophie-ux-challenger` (Opus) — **NEEDS_FIX**
- **P0 densité expose la mécanique** (« vu que tu bouges déjà ») → **corrigé** (affirmer sans justifier) + flag décision.
- P1 « comme demandé » dans le why → **corrigé** (why seulement si pré-rempli). P1 placeholder trop expert → **corrigé**. P1 🚫 générique moralisant → **corrigé**.
- Q3 cas douleur/santé non couvert → recoupe le CRITIQUE MDR → **corrigé** (famille 2).

### Personas **Maxime/Nathalie/Inès** (Sonnet — modèle différent) — ton bon, 3 formules craquent sous pression
- **P0 Inès : 🚫 « pas mon rayon » froid/administratif** pour une fragile → **corrigé** (« même les meilleurs coachs… », retire la faute de l'user).
- P1 Maxime : « si c'est trop » condescendant → **corrigé** (« tu ajustes le volume »).
- P1 Nathalie : placeholder « 2×/sem 45 min » = brief d'expert → **corrigé**. ⏳ « pour bientôt » = promesse creuse → **corrigé** (« je note l'idée »). Enjeu UX : carrousel doit primer (évite le 🚫 direct) → noté dans le script.

### Lentille **MDR / RGPD** — **1 CRITIQUE**
- **C1 CRITIQUE : pas de 🚫 pour rééducation/pathologie** → risque requalification dispositif médical → **corrigé** (famille 2 + `category=health_condition`).
- A1 « qui te fait du bien » / « on progresse pour de vrai » = allégation santé → **corrigé** (ancré entraînement). A2 log sans verbatim → **corrigé**. A3 base légale/pseudonymisation → **corrigé**.
- OK : densité comportementale conforme (signal = séances, pas le corps) ; why récap conforme.
