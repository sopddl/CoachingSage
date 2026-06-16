# Re-scope thème #3 — vulgarisation jargon (2026-06-16)

Passe qualité 10 sports, thème #3. Décision 2026-06-10 = « vulgariser TOUT, zéro
terme conservé » (estimée ~EU-MDR ×3). Ce re-scope la **révise sur preuve code** :
le périmètre réel est petit.

## Constat décisif : la prose doctrinale n'est jamais affichée

`ProgramAdapter` (`Coaching/Adapter/ProgramAdapter.swift:84-102`) met à `empty`
les champs `defaultObjective`, `assumedProfile`, `summary`, `safetyNotes`,
`progressionLogic` (+ week `theme`/`goal`) au moment de construire le programme.
Grep Views confirme : **aucun de ces champs n'est rendu**. Le `safetyNotes`
affiché (`AdaptedProgramView.swift:582`) vient **exclusivement du patch IA Léon**
(`PatchApplier.swift:92`), pas du template.

→ Toute la prose de justification (« Progression construite sur 5 principes
ACSM/Gibala/Iyengar… », signes de surcharge, rationale) est de la **doc
d'authoring / certification jamais montrée à l'user**.

## Inventaire jargon : affiché vs non-affiché (FR, vocab volontaire RPE/RIR/FTP/TM/tempo exclu)

| Terme | Affiché | Non-affiché (prose) | Verdict |
|---|---|---|---|
| myélinisation / gut training / EVF / catch-up / negative split | ~0 | 26 | **HORS scope** (caché) |
| Tabata | 0 | 95 | **HORS scope** (caché) |
| EMOM | 0 | 58 | **HORS scope** (caché) |
| polarisé / SIT | ~1 | 23 | **HORS scope** (caché) |
| sanskrit (asana, Ujjayi…) | 4024 | 504 | **KEEP** — noms de poses canoniques, déjà glosés FR |
| cutback / deload | 275 | 371 | **CIBLE #3** (surtout exercise.notes) |
| ratio xx/yy (30/60, 40/20) | 393 | 221 | décision — labels de séance |
| VO2max | 180 | 81 | décision — labels de séance |
| AMRAP | 42 | 83 | décision — dans `dose.free_text` |
| Down Dog | 34 | 14 | naming #2 — anglais isolé (warmup) |

(« sanskrit 4024 » = faux positif de comptage : ce sont les noms de poses, type
« Posture de la montagne (tadasana) », déjà FR-primary → aucun travail.)

## Périmètre #3 réel (révisé)

Le gros du jargon effrayant (physio, formats HIIT théoriques, refs sportives)
est **dans la prose non-affichée → on le DROP du scope**. Ça tue l'estimation
~EU-MDR×3. Reste une **shortlist en champs affichés** :

1. **cutback / deload → « semaine allégée »** (~275 occ., surtout `exercise.notes`).
   Gain net, zéro ambiguïté. = le vrai morceau.
2. **AMRAP** (~42, `dose.free_text`, ex. « 5, 5, 5, 5+ AMRAP ») → décision : vulgariser
   (« max de reps ») vs garder (notation compacte type Wendler).
3. **ratio 30/60, 40/20** dans **noms de séance** (« HIIT 30/60 ») → décision :
   garder (concis, informatif) vs expliciter (« 30 s effort / 60 s récup »).
4. **VO2max** dans **noms de séance** (« VO2max — 5×3 min ») → décision : garder
   (terme reconnu) vs gloser.
5. **Down Dog** (anglais isolé en warmup yoga) → relève de #2 naming : traduire
   (« Chien tête en bas ») ou homogénéiser en sanskrit.

## Livrable si exécution

Passe contenu ciblée sur la shortlist (substring sur token JSON échappé, méthode
EU MDR) + **filet régression swift** (`NoRawJargonInDisplayedTextTests` :
charge bundle prod, assert absence des termes tranchés dans les champs affichés).
PAS de party/regen — single-source, édition directe. Ordre de grandeur : 1 petite
passe (cutback dominant) ≪ EU-MDR.

## Décisions ouvertes pour Sophie

A. Confirmer le **drop de la prose non-affichée** du scope #3.
B. cutback/deload → « semaine allégée » : OK ?
C. AMRAP / ratio xx/yy / VO2max dans noms+dose : vulgariser ou garder ?
D. Down Dog : traiter ici (avec #3) ou laisser à #2 naming ?
