# Bug #2 — Warmups muscu : jargon anglais → FR didactique (PROPOSAL à valider)

**Contexte** : device-test Sophie 2026-06-08 — « échauffement : texte en anglais peu didactique ».
Les `warmup` FR des 4 templates muscu sont remplis de jargon coach EN/franglais. Ce doc est une
**proposition de vocabulaire** (PAS une édition) — à valider par Sophie + `template-quality-reviewer`
(EU MDR) avant réécriture des templates. NE PAS éditer les templates à l'aveugle.

## A. Glossaire jargon → FR débutant (briques réutilisables)
| Terme actuel (warmups) | Proposition FR didactique |
|---|---|
| scapular CARs / hip CARs / Shoulder CARs | rotations lentes et contrôlées de l'épaule / de la hanche |
| world's greatest stretch | grand étirement fente + rotation du buste |
| band pull-apart | écartés des bras à l'élastique |
| band dislocate / dislocations élastique | passages d'épaules à l'élastique (bras tendus par-dessus la tête) |
| ramp-up / ramping (4 paliers) | montée en charge progressive (séries de + en + lourdes) |
| rower / rameur Z2 | rameur à allure facile |
| knee-to-wall | genou vers le mur (mobilité cheville) |
| hip flexor lunge | fente d'étirement de l'avant de la hanche |
| 90/90 (hip switch) | position assise jambes en 90/90, passage d'un côté à l'autre |
| scapular push-up / pull-up | pompe / traction « omoplates seules » (sans plier les bras) |
| wall slides | glissements des bras le long du mur |
| thoracic rotation / T-spine | rotation du haut du dos |
| sleeper stretch | étirement d'épaule allongé sur le côté |
| deep squat hold | squat profond tenu quelques secondes |
| band lateral walks | pas latéraux avec élastique aux genoux |
| face pulls bande légère | tirage élastique vers le visage |
| Y-T-W | bras qui dessinent les lettres Y, T, W (épaules) |
| cat-cow / chat-vache | dos rond / dos creux à quatre pattes (déjà FR ✓) |

## B. Problème de fond (au-delà du vocabulaire)
1. **Placeholders vides** : « Échauffement standard 7 min. » / « Étirements 5 min standards. »
   n'expliquent RIEN (déjà mitigé par le fallback guidé code, mais le contenu reste à enrichir).
2. **Listes d'exos juxtaposées sans verbe** : un débutant ne sait pas DOIT-il faire 2×15, combien
   de temps, à quoi ça sert. Proposition de structure : *« 5 min de cardio doux + 2-3 mouvements
   de mobilité (épaules, hanches) + montée en charge progressive »* en langage simple.
3. **Densité variable** : les warmups `competitive` (« 12 min. Squat : barre x8, +30 kg x5… »)
   mélangent échauffement et prescription de charge en kg — contraire à D1 (zéro kg prescrit).

## C. Reco de traitement (à arbitrer)
- **Option 1 (légère)** : juste remplacer le jargon EN par le glossaire A (warmups gardent leur structure).
- **Option 2 (didactique)** : réécrire les warmups en 1 phrase simple + 2-3 puces, par PALIER de
  template (débutant ≠ confirmé), via `template-quality-reviewer`. Plus de travail mais c'est le
  « niveau acceptable » visé.
- **Option 3 (radical)** : warmup générique didactique par sport, injecté côté code, ignorant le
  texte template (comme le fallback actuel) — découple contenu et qualité, mais perd la spécificité.

→ **Décision produit Sophie requise** avant toute édition.
