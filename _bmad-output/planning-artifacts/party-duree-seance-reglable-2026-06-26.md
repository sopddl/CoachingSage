# Party — Moteur « durée de séance réglable » (décision B gap moteur) — CoachingSage

**Date** : 2026-06-26
**Format** : party multi-personas, Sophie dans la boucle.
**Origine** : [[gap_moteur_duree_seances]] — device-test 2026-06-24, Sophie demande « 40 min
semaine / 1h15 week-end » → obtient 55/60 (durées intrinsèques du template). Décision A
(backlog) vs B (chantier moteur durée) → **Sophie tranche B**.

---

## Casting

- 💪 **Maxime** — débutant qui fait déjà du sport (persona central, vit la demande de durée).
- 🏃 **Coach Daniel** — voix doctrine sportive (esprit `template-quality-reviewer` +
  `leon-algo-doctrine-by-sport`). Plancher/plafond par type, invariants MDR.
- 🤖 **Léon** — coach IA, borné + honnête.
- 🎨 **Sally** — UX Expert (affordance, ne pas exposer la mécanique).
- 🏗️ **Archi** — coût/risque technique, réversibilité.
- 📋 **PM** — scope V1 minimum, ce qu'on coupe.

**Matos** : explo moteur (champ `duration_minutes` affiché ≠ calculé ; exos en durée texte
libre ; hook `CoachingSportProfile.sessionDurationMinutes: Int?` jamais consommé ; pipeline
5 règles d'adapter) · `leon-algo-doctrine-by-sport.md` · party onboarding élargi (fil de Léon,
log ⏳, NLP borné serré) · mémoire du gap.

---

## Le vrai problème

Le moteur ne sait produire que la durée **intrinsèque** du template ; pour livrer la promesse
de Léon (« tu me parles, je m'adapte »), il faut qu'il sache **remodeler le contenu d'une
séance vers une durée-cible** sans casser la justesse sportive — alors qu'aujourd'hui **rien
ne relie le contenu (exos en texte libre) aux minutes affichées**.

### Correction de scope (Sophie)

- ❌ Pas de gestion de jours (pas de semaine/week-end calendaire). Les séances n'ont déjà
  aucun jour (juste un ordre 1..N).
- ✅ Le levier = **durée-cible par séance**. L'user peut exprimer un mix (« 2× 30 min + 1× 2h »)
  = N séances avec N durées-cibles, le moteur adapte le contenu de chacune.

---

## Tour de table (résumé)

- **Maxime** : « j'ai 30 min ce soir » doit donner 30, pas 50 (douleur du 24/06). Mais une
  borne honnête (« ta plus courte ici c'est 35 ») rassure **plus** qu'un faux 30 bâclé.
- **Coach Daniel** : une séance = 4 strates. **Échauffement + cooldown quasi-fixes** (plancher
  MDR). **Cœur scalable mais l'unité change par type** (endurance = durée continue ; interval/
  HIIT = nombre de tours/reps ; strength = séries/accessoires, jamais les primaires).
  **Accessoire = première variable sacrifiable.** La cible n'est atteignable que dans une
  **fourchette [plancher … plafond]**, différente par sport ET par type.
- **Léon** : reste borné/honnête. Restitue ce qu'il fait vraiment. **Le chiffre affiché = le
  chiffre réel** (jamais 30 affiché pour 38 dedans). Hors portée → phrase douce + log ⏳.
- **Sally** : entrée en **durée naturelle** (pas de curseur %, ne pas exposer la mécanique —
  verrou [[feedback_ne_pas_exposer_mecanique_interne]]). **Jamais cible vs obtenu côte à côte**
  (anxiété du « pas tenu »). On montre le réel.
- **Archi** : « choisir la variante la plus proche » = quasi-gratuit mais **inutile** (pas de
  variantes à 30/120 min). Vraie cible ⇒ **structurer le contenu en blocs budgétés**
  (`estimatedMinutes` + `role` + `priority` + `scalingUnit`). **Le coût = la donnée à annoter,
  pas l'algo.** Règle isolée, réversible, `sessionDurationMinutes` déjà au modèle.
- **PM** : isoler le moteur du NL. V1 = moteur sur 1 sport pilote, entrée = cible déjà
  interprétée. NL + 9 autres sports = increments.

### Pivot Sophie (mid-party)

> « peut-être qu'en V1 on pourrait juste la possibilité dans un programme de rajouter/ajuster
> une séance sur une durée particulière ? »

Déplace le centre de gravité : **édition manuelle in-program** (≠ compo NL par Léon).
Réduit la **surface** (1 séance, manuel, in-app) mais **pas le cœur** (il faut toujours savoir
transformer un contenu vers une durée). → Cadré en **lean+**.

---

## Tensions surfacées

1. **Étendre vers le haut a besoin de matière** → plafond par type, comme le plancher (Daniel
   donne les DEUX bornes).
2. **« Ajuster » persistant ou one-shot ?** → tranché persistant (D-T2).
3. **Coût réel = annoter les templates cycling en blocs** (~3 templates, 158 variantes). Là où
   est le travail, doit passer la doctrine. Risque de débordement du « petit pilote ».
4. **Scaling × variantes indoor/outdoor** → s'applique sur la variante active (D-T4).
5. **Léon nécessaire en V1 ?** → non, message système doux suffit (D-T5).

---

## DÉCISIONS FIGÉES (Sophie, 2026-06-26)

| # | Décision | Conséquence |
|---|----------|-------------|
| **D1** | Mécanisme V1 = **lean+** : moteur de scaling de durée **par séance**, à la demande, **édition in-program manuelle** (pas de NL) | Découple le moteur du fil de Léon ; livrable sans inc2 NL. |
| **D2** | Sport pilote = **cycling** | Là où est née la douleur (55/60 vs 40/75) ; scaling endurance le plus propre ; variantes indoor/outdoor en place. |
| **D3** | Remodelage = **rogner ET étendre** vers une cible | Couvre « 30 min ce soir » ET « 2h le week-end ». |
| **D4** | Donnée = **blocs budgétés** (`role` / `estimatedMinutes` / `scalingUnit` / `priority`) posés sur les templates **cycling uniquement** | Le gros du travail, borné à 1 sport. Annotation à valider doctrine. |
| **D5** | Invariants : **échauffement + cooldown intouchables**, **accessoire sacrifié en premier**, cœur scalé selon `scalingUnit` du type | Garde-fou MDR + justesse. Exos primaires strength jamais retirés (transverse). |
| **D6** | Bornes **plancher ET plafond par type de séance** (table doctrine Coach Daniel, **validée avant code**) | Hors fourchette → on borne, on ne ment pas. |
| **D7** | Léon **borne honnête** : montre le **chiffre réel** (jamais cible vs obtenu), une phrase douce si borné, log ⏳ `periodisationTemporelle` | Cohérent « la réalité moteur borne les promesses de Léon ». |
| **D8** | **Hors V1** : NL/fil de Léon · 9 autres sports · **« ajouter une séance »** (→ increments suivants) | Pilote serré sur « ajuster une séance existante ». |
| **D-T2** | « Ajuster » = **persistant** (remplace la séance dans le programme) | L'user façonne durablement son programme. Impact `PersistedSession`/complétion à gérer (id-preserving). |
| **D-T4** | Scaling s'applique sur la **variante active** (indoor/outdoor) | Pas de télescopage avec le chantier indoor/outdoor. |
| **D-T5** | Phrase de borne = **message système doux** (pas de dépendance avatar Léon en V1) | V1 ne dépend pas du fil de Léon. |

---

## Forme concrète V1 (lean+ cycling)

1. **Blocs budgétés** : chaque séance cycling décomposée en blocs `{role, estimatedMinutes,
   scalingUnit, priority}`. `scalingUnit ∈ {continuous, rounds/reps, sets, fixed}`.
2. **Règle de scaling** (isolée, à la demande, 1 séance) :
   - calcule la fourchette `[min = warmup+cooldown+dose mini cœur … max = pleine+accessoires]`
   - cible dans la fourchette → rogne accessoire d'abord, puis ajuste cœur selon `scalingUnit`
   - cible hors fourchette → **borne au plus proche atteignable**, renvoie le vrai chiffre
3. **Bornes par type** = table doctrine (plancher + plafond), auteur Coach Daniel, validée.
4. **Entrée UX** in-program, sur une séance : « ajuster la durée » → cible → résultat réel
   (un seul chiffre). Si borné : message doux + log ⏳.
5. **Articulation moteur** : règle isolée, ≠ `VolumeModulationRule` (fréquence, supprime des
   séances) ≠ duration-resize (semaines). Cible = `sessionDurationMinutes: Int?` (déjà au modèle).

---

## Prochaines actions (NEXT)

1. **Spec story** (ready-for-dev) : modèle de blocs budgétés + règle de scaling + bornes par
   type + persistance id-preserving + entrée UX. Découpage en increments à confirmer (Sophie :
   « on verra si on découpe »).
2. **Table doctrine Coach Daniel** : plancher + plafond par type de séance cycling
   (endurance / interval / mixed / récup…), validée avant code.
3. **Annotation des templates cycling** en blocs budgétés (le gros du travail).
4. **Filet de régression swift** obligatoire (politique CLAUDE.md) : invariants
   échauffement/cooldown intouchables, plancher respecté, chiffre affiché = chiffre réel.
5. **Implem SOPDDL** : implem → review agent → tests `swift test` → `ui-reviewer` (touche
   Views/**) → device-test Sophie.

**Pas de code tant que la table doctrine + le découpage en increments ne sont pas calés.**
