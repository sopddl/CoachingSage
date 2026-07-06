# Table doctrine — Durée de séance réglable, pilote cycling (Coach Daniel)

**Date** : 2026-07-04
**Origine** : [[gap_moteur_duree_seances]] · party [[party-duree-seance-reglable-2026-06-26]] (décisions D1-D8, D-T2/T4/T5, **TRANCHÉES**).
**Gate** : « pas de code avant table doctrine + découpage en increments » — ce document couvre les deux.
**Statut** : ✅ **VALIDÉE par Sophie 2026-07-04** (les 4 points de la section 9 tranchés). Annotation + implém autorisées.

---

## 0. Ce qui est déjà tranché (rappel, ne pas rouvrir)

- V1 = 1 sport (cycling), édition **manuelle in-program** d'**une** séance existante, pas de NL, pas de « ajouter une séance ».
- Remodelage = **rogner ET étendre** vers une cible.
- Invariants : **échauffement + cooldown intouchables**, **accessoire sacrifié en premier**, cœur scalé selon `scalingUnit` du type.
- Bornes plancher **et** plafond par type, hors fourchette → on **borne et on le dit** (chiffre affiché = chiffre réel, jamais cible vs obtenu).
- « Ajuster » = **persistant** (remplace la séance dans `PersistedSession`, id préservé pour ne pas casser `ProgramCompletionState.sessionRecords[UUID]`).
- Scaling sur la **variante active** (indoor/outdoor) uniquement.
- Message de borne = **système doux**, pas de dépendance Léon en V1.
- `rest` **exclu du scope moteur** (placeholder jour off, jamais réglable) — tranché 2026-07-03.

---

## 1. Constat data réel (les 4 templates cycling prod)

Types réellement présents (`rest` exclu) et leur poids :

| Type | Occurrences (4 templates) | Durée observée | Rôle constaté |
|---|---|---|---|
| **endurance** | 79 | 50–480 min | Sortie continue Z1/Z2 (long ride, récup active, activation) — un seul bloc |
| **interval** | 56 | 55–130 min | 1-2 blocs structurés (Z3/Z4/Z5/Z6) — bloc principal + parfois tempo secondaire |
| **mixed** | 4 | 40–75 min | Sortie Z2 continue **+ renforcement préventif accessoire** (planche, pont fessier, calf raises — cf doctrine « Renforcement préventif ») |
| **technique** | 2 | 60–100 min | Base Z2 + bloc technique spécifique (cadence, force basse cadence, peloton simulé) |
| **mobility** | 1 | 60 min | Sortie courte + routine mobilité (le vrai cœur = la routine, pas la sortie) |
| **other** | 1 | 60 min | Sortie bilan fin de cycle (Z1, réflexion) — assimilable endurance |

`rest` (17 occurrences, 0-60 min, jour off) confirmé hors scope.

**Conséquence** : `endurance` et `interval` sont 90% du volume réel → traitement doctrine complet. `mixed`/`technique`/`mobility`/`other` sont rares (échantillon 1-4) → traitement **conservateur générique** plutôt que table bespoke peu fiable sur si peu de cas (section 4.3).

---

## 2. Taxonomie des blocs (nouveau vocabulaire moteur)

Chaque **exercice** d'une séance cycling reçoit 4 nouvelles annotations (V1 = cycling seulement, D4) :

- **`role`** : `core` (le pourquoi de la séance — jamais retiré, seulement scalé) vs `accessory` (renforcement préventif, sprint d'activation, drill secondaire — sacrifié en premier, peut tomber à zéro).
- **`scalingUnit`** : comment ce bloc se scale.
  - `continuous` : minutes continues (sortie Z1/Z2/Z3 en un seul tenant). On change les **minutes**.
  - `roundsReps` : nombre de répétitions d'un bloc structuré (`sets`). On change les **reps**, la durée par rep ne bouge pas (le "goût" de l'effort — durée + récup d'un rep Z4 — reste fixe, doctrine Coggan/Allen).
  - `fixed` : intouchable même si `role == accessory` niveau structure (aucun cas identifié en cycling V1 — gardé pour extension future, ex. test FTP).
- **`priority`** : ordre de sacrifice parmi les blocs `accessory` d'une même séance (1 = sacrifié en premier). Seul `mixed` a aujourd'hui plusieurs accessoires (ex. planche puis pont fessier puis calf raises).
- **`estimatedMinutes`** : minutes réellement annotées pour CE bloc à sa cardinalité actuelle dans le template (ex. 6 reps Z4 de 1 min + 2 min récup = 18 min). C'est la valeur qui remplace le calcul impossible depuis le texte libre (`duration: "1 min"`, `sets: 6`, `rest_seconds: 120` ne suffisent pas seuls : le format texte varie trop pour un parsing fiable — cf constat party).

`warmup`/`cooldown` restent des champs texte libre à la racine de `TemplateSession` (jamais dans `exercises[]`) → **structurellement déjà intouchables**, pas de rôle à leur assigner. Ils reçoivent seulement une annotation `estimatedMinutes` (nouveau champ session-level) pour permettre le calcul de la fourchette.

---

## 3. Modèle de données — diff proposé

### `TemplateExercise` (`Templates/Sources/TemplateModel/ProgramTemplate.swift`)

```swift
public let role: BlockRole?           // .core / .accessory — nil = non annoté (sports hors V1)
public let scalingUnit: ScalingUnit?  // .continuous / .roundsReps / .fixed
public let priority: Int?             // ordre de sacrifice parmi les accessoires, nil si core
public let estimatedMinutes: Int?     // minutes réelles de CE bloc à cardinalité template
```

Nouveaux enums (`Enums.swift`), sport-agnostiques (comme `VolumeAxis`) :

```swift
public enum BlockRole: String, Codable, CaseIterable, Sendable { case core, accessory }
public enum ScalingUnit: String, Codable, CaseIterable, Sendable { case continuous, roundsReps, fixed }
```

Tous optionnels, décodage tolérant (`decodeIfPresent`, comme `matchKey`/`dose`) → **zéro régression** sur les templates non annotés (9 autres sports, hors V1).

### `TemplateSession`

```swift
public let warmupMinutes: Int?    // annotation, estimation minutes de warmup
public let cooldownMinutes: Int?  // idem cooldown
```

`AdaptedExercise`/`AdaptedSession`/`PersistedSession` : ajout des mêmes 4 (+2) champs en lecture seule, copiés tel quel depuis le template (même pattern que `volumeAxis`/`dose` aujourd'hui — cf `AdaptedExercise.passthrough`). Nécessaires pour que le moteur de scaling (qui opère sur une `PersistedSession` déjà persistée, pas sur le `ProgramTemplate` brut) ait les annotations sous la main sans revenir chercher le template via `findExercise`.

**Coût réel** : annoter ~140 exercices + ~140 sessions (4 templates cycling, warmup/cooldown minutes) via script (précédent : `scripts/densite_b/generate_deload_weeks.py`, `scripts/notes_sweep/`) — pas d'édition JSON manuelle exercice par exercice.

---

## 4. Table doctrine — plancher / plafond par type

Principe général : `plancher = warmupMinutes + cooldownMinutes + coreFloor` · `plafond = warmupMinutes + cooldownMinutes + min(coreCeilingAbsolu, coreCeilingRelatif)`.

Le **plafond relatif** (`coreCeilingRelatif = 2 × coreMinutesOriginal`) est un garde-fou que j'ajoute (pas dans la party) : sans lui, une sortie courte pourrait légalement grimper au plafond absolu du niveau (ex. 180 min pour un `recreational`) sur une seule demande, ce qui trahit le rôle périodisé de la séance (Sophie/Sally : « jamais 2e séance intensive à la place de la récup »). **✅ Validé (2×)** — note : dans les 4 templates prod, aucune séance `endurance` ne descend sous 50 min réels (le floor 20 min core est un vrai plancher de sécurité, jamais atteint aujourd'hui) → le cap 2× ne se déclenchera quasi jamais sur le contenu existant, il protège un cas extrême hypothétique.

### 4.1 `endurance` (scalingUnit = `continuous`, bloc unique)

| Niveau | `coreFloor` | `coreCeilingAbsolu` | Source |
|---|---|---|---|
| beginner | 20 min | 90 min | Floor = seuil minimal de stimulus aérobie continu (consensus sport-science) ; ceiling = long ride max doctrine (British Cycling Beginner). |
| recreational | 20 min | 180 min | Ceiling = long ride max doctrine (FasCat Basic / British Cycling Sportive). |
| regular | 20 min | 240 min | Ceiling = long ride max doctrine (Friel Build-Peak). |
| competitive | 20 min | 360 min | Ceiling = long ride max doctrine (Friel Race phase). |

Le floor est volontairement **universel** (pas par niveau) : en dessous de 20 min continues, l'effet d'entraînement aérobie devient négligeable quel que soit le niveau (Coach Daniel).

### 4.2 `interval` (scalingUnit = `roundsReps` sur le bloc `core`)

Le plancher/plafond porte sur le **nombre de reps** du bloc `core`, dérivé de la zone (`targetZone`) déjà présente sur l'exercice — réutilise la table de zones existante (`leon-algo-doctrine-by-sport.md`), aucune nouvelle borne inventée :

| Zone (`targetZone`) | Reps plancher | Reps plafond | Source |
|---|---|---|---|
| FTP-Z3 / Sweet-Spot (tempo) | 1 | pas de cap reps — cap en minutes : +90 min max cumulé (doctrine FasCat « bloc 30-90 min ») | Table zones existante |
| FTP-Z4 (Threshold) | 2 | 4 | Table zones existante (« 2-4 reps ») |
| FTP-Z5 (VO2max) | 3 | 6 | Table zones existante (« 4-6 reps »), floor -1 accepté (dose réduite mais non nulle) |
| FTP-Z6 (Anaerobic) | 3 | 8 | Table zones existante (« 4-8 reps »), floor -1 |
| Zone absente/texte libre (ex. « Bloc cadence élevée ») | −1 rep vs original, min 2 | +2 reps vs original | Fallback générique (échantillon insuffisant pour table dédiée) |

Bloc `accessory` d'une séance interval (ex. tempo Z3 en fin de séance Z4) : floor = **0** (peut disparaître entièrement, D5), plafond = pas d'extension (les accessoires ne s'étendent jamais — extension va toujours au `core` en priorité, section 6).

### 4.3 `mixed` / `technique` / `mobility` / `other` — traitement conservateur générique

Échantillon trop faible (1-4 séances) pour une table bespoke fiable. Règle universelle proposée :

- Le **premier bloc `core`** (toujours le bloc Z2/technique principal, confirmé sur les 6 séances inspectées) suit la règle `endurance` ou `interval` selon son propre `scalingUnit`.
- Tout bloc `accessory` (renforcement préventif `mixed`, drills secondaires) : floor = 0, jamais étendu — cohérent avec la doctrine « renforcement préventif » qui est un ajout de sécurité, pas le cœur de la séance.
- Pas de plafond relatif spécifique au-delà de la règle 4.1/4.2 déjà appliquée au bloc core.

`mobility` est un cas particulier notable : le bloc `core` au sens moteur (celui qu'on ne veut PAS sacrifier) est la **routine de mobilité**, pas la sortie vélo qui l'accompagne — à annoter `role: core` sur la routine et `role: accessory` sur le pédalage court qui la précède, à l'inverse du réflexe naturel. **✅ Confirmé.**

---

## 5. Invariants (précisions D5)

1. `warmup`/`cooldown` (texte racine) : jamais modifiés, jamais comptés dans le rognage/extension au-delà de leur `estimatedMinutes` fixe.
2. Parmi les blocs `accessory` d'une séance, sacrifice dans l'ordre `priority` croissant (1 en premier) jusqu'à cible atteinte ou tous accessoires à 0.
3. Le bloc `core` n'est JAMAIS retiré entièrement — seulement scalé dans sa fourchette (section 4). S'il ne reste que le core au floor et que la cible est encore en dessous → **borné** (message doux), on ne descend pas sous le floor core.
4. Extension : d'abord le bloc `core` monte vers son plafond ; les accessoires ne remontent JAMAIS au-dessus de leur dose originale (pas de sur-dosage accessoire pour combler une cible haute — évite un bloc renforcement qui gonfle artificiellement au lieu du vrai contenu).
5. S'il y a plusieurs blocs `core` dans une même séance (aucun cas identifié en V1 cycling, mais le modèle le permet) : répartition proportionnelle à leur poids `estimatedMinutes` original.

---

## 6. Algorithme de scaling (par séance, à la demande)

```
input: session (PersistedSession), targetMinutes: Int

floor = warmupMinutes + cooldownMinutes + coreFloor(type, level, zone)
ceiling = warmupMinutes + cooldownMinutes + min(coreCeilingAbsolu(type, level, zone),
                                                  2 × coreMinutesOriginal)

clamped = clamp(targetMinutes, floor, ceiling)
wasBounded = (clamped != targetMinutes)

si clamped < durationMinutes actuel (rognage) :
    1. retirer/réduire les blocs accessory par priority croissante jusqu'à cible
       ou accessoires épuisés
    2. si insuffisant, réduire le(s) bloc(s) core vers coreFloor (jamais en dessous)

si clamped > durationMinutes actuel (extension) :
    1. étendre le(s) bloc(s) core vers coreCeilingAbsolu (jamais au-dessus)
    2. les accessoires ne sont jamais étendus au-delà de leur dose originale

output: nouvelle PersistedSession (même id), durationMinutes = clamped (RÉEL, jamais le target brut),
        wasBounded (→ message système doux si true), log ⏳ periodisationTemporelle
```

`continuous` : les minutes du bloc se lisent/s'écrivent directement (`estimatedMinutes` + regénération du texte `duration`/`dose` affiché, cf pattern `bumpingHold`/`addingOneSet` déjà existant sur `AdaptedExercise`).
`roundsReps` : on change `sets`, `estimatedMinutes` recalculé = `(estimatedMinutes original / sets original) × nouveaux sets`.

---

## 7. Découpage en increments (proposition)

| # | Contenu | Sort de la boucle avec |
|---|---|---|
| **Inc. 1 — Data + doctrine** | Ajout des 6 champs au modèle (`TemplateModel`), script d'annotation des 4 templates cycling (role/scalingUnit/priority/estimatedMinutes/warmupMinutes/cooldownMinutes), validation doctrine figée (ce document, section 4 tranchée) | Templates annotés, décodables, **aucun comportement changé** (champs non consommés) |
| **Inc. 2 — Moteur** | `SessionDurationScaler` (service isolé, PAS dans `ProgramAdapter` cascade — appelé à la demande sur une `PersistedSession`), implémente section 6, remplace la session en place (id préservé) | Service testable unitairement sans UI, filet swift complet (section 8) |
| **Inc. 3 — UX** | Entrée in-program « ajuster la durée » sur une séance, résultat = chiffre réel affiché, message doux si `wasBounded`, log `periodisationTemporelle` | Feature livrable, `ui-reviewer` obligatoire (touche `Views/**`) |

Découpage volontairement séquentiel (chaque increment testable et mergeable seul), cohérent avec le rythme SOPDDL habituel. Inc. 1 ne touche aucun code de production consommé → mergeable sans risque dès la doctrine validée.

---

## 8. Filet swift (obligatoire, par increment)

- **Inc. 1** : `CyclingBudgetedBlocksTests` — pour chaque session cycling annotée : (a) somme `warmupMinutes + cooldownMinutes + Σ estimatedMinutes(exercises)` ≈ `durationMinutes` (tolérance ±10%) ; (b) tout exercice a `role` non-nil ; (c) exactement un bloc `role: core` par session (sauf cas multi-core documenté) ; (d) `scalingUnit` cohérent avec le type (`continuous` pour bloc unique endurance, `roundsReps` si `sets > 1` structuré).
- **Inc. 2** : `SessionDurationScalerTests` — invariants section 5 (warmup/cooldown jamais touchés, core jamais à zéro, accessoire jamais étendu au-dessus de l'original, `wasBounded` correct aux bornes exactes, chiffre retourné = chiffre réellement appliqué).
- **Inc. 3** : test de non-régression `ProgramCompletionState` (id de session préservé après ajustement → pas de perte de streak/historique sur une séance déjà complétée avant ajustement — cas à trancher : peut-on ajuster une séance déjà faite ? proposition section 9).

---

## 9. Décisions VALIDÉES (Sophie, 2026-07-04)

1. **Plafond relatif = 2× `coreMinutesOriginal`** — confirmé. Dans les faits ne se déclenchera quasi jamais sur le contenu prod actuel (aucune séance sous 50 min réels), c'est un garde-fou pour l'édition user, pas une contrainte sur les templates existants.
2. **`mobility` : le cœur est la routine, pas la sortie** — confirmé, à annoter tel quel.
3. **Séance déjà complétée → ajustement de durée BLOQUÉ** (proposition d'UI Inc. 3 : action grisée/absente si `SessionCompletionRecord` existe pour cette séance).
4. **Fallback zone absente pour `interval` = `-1/+2 reps`** — confirmé.

**Gate levée : Increment 1 (data model + annotation) peut démarrer.**
