# Adaptability : running-expert-marathon-16sem + p4-more-ambitious-goal

## Rigidity score
**3/10**

## Patch approach
Le template est structurellement **très rigide** pour une escalade d'objectif. Le plan est construit autour d'une allure marathon (AM) cible unique, dérivée du profil supposé (semi-marathon < 1h50 pour sub-4h). Rehausser l'objectif exige de remonter AM de 10-20 s/km, ce qui crée des cascades de contradictions : les allures seuil (AS = AM ± 10-30 s/km) deviennent irréalistes, les long runs à AM deviennent physiologiquement inaccessibles sans surcharge extrême, et le volume pic (75 km W11) devient dangereux pour un objectif plus ambitieux. Le template ne se "patche" pas élégamment — il faut reconstructurer.

## Concrete modifications
**Impossible de patcher proprement.** Voici pourquoi :

- **W1-W4 tempo** (allure = 10K + 15-30 s/km) : Si tu vises un objectif +10 s/km (ex : sub-3h30 au lieu de sub-4h), l'allure tempo augmente de ~10 s/km. Mais le template pose en hypothèse que tu peux soutenir 40 min continu au seuil en W10 — acceptable pour sub-4h, **impossible** pour sub-3h30 sans risque majeur de surcharge en W9-W11.

- **W11 long run = 35 km** : À allure marathon rehaussée, 35 km devient équivalent énergétiquement à 37-38 km à l'allure originale. Aucune semaine de cutback prévue après W11 avant W12 (W12 cutback vise 60 km mais reste 60 km) — la fatigue cumulée n'a pas d'exutoire.

- **W13-W15 affûtage** : Le principe "réduire volume, maintenir intensité" suppose que tu arrives à W13 frais. Avec un objectif +ambitieux, le risque de fatigue chronique en W12 est majeur — l'affûtage commence trop tard.

## Rigidity issues

1. **Progression_logic § 1 : Cutbacks fixes aux semaines 4, 8, 12**
   - Pour un objectif +10 s/km, ces cutbacks sont **insuffisants**. Un cutback toutes les 3-4 semaines (au lieu de 4) serait nécessaire pour contrôler la fatigue cumulée dans les blocs 2 et 3.
   - Patcher concretely : ajouter un **microcutback à W10** (réduction -10% du volume long run, passage de 35 km à 30-32 km), mais le template refuse cette inversion logique (W11 est explicitement le pic absolu, W10 est une montée).

2. **Progression_logic § 4 : Long run pic = 35 km à AM**
   - À AM rehaussée, 35 km à une allure 10-20 s/km plus rapide dépassse les 1h50-2h d'effort = fatigue cumulée extrême, surtout si W9 et W10 ont aussi des long runs long et des séances qualité quotidiennes.
   - Patcher : réduire le long run pic à 32 km, mais cela contredit la phrase "pic à 35 km (W11) représente 83% de la distance marathon — suffisant pour déclencher les adaptations sans les traumatismes excessifs". Réduire le pic tue la logique.

3. **Safety_notes : Drapeaux "fracture de stress" à W10-W11**
   - Le template note déjà que les fractures de stress surviennent "typiquement lors des pics de volume (W10-W11)". Augmenter l'intensité tout en maintenant le volume pic **double le risque de fracture de stress tibiale** chez un coureur qui augmente la cadence/l'allure simultanément.
   - Patcher : ajouter une semaine cutback microscopique à W10.5 (impossible, pas de demi-semaines), ou réduire le volume de W9-W11 de 5-10%.

4. **Progression_logic § 3 : Séances tempo et VO2max tous les jours — sans exception**
   - Texte exact : "Tempo seuil et VO2max toutes les semaines sans exception". Pour un objectif +ambitieux, maintenir 40 min tempo + 6x1000m VO2max dans la même semaine (W10) **crée une surcharge neurodégénérative** : deux jours de haute intensité (W10 J3 et J5 sont temps tempo et VO2max) séparés par 48h seulement, puis long run 35 km le J7.
   - W10 structure exact : J1 run facile, J2 force, J3 tempo 40 min, J5 6x1000m, J7 long run 35 km. **Aucun jour de récupération complète entre J3 et J5.**
   - Patcher : supprimer W10 J5 VO2max (le remplacer par un run facile), mais le template dit "jamais absent" — contradiction directe.

5. **Volumes chiffrés W9-W12 : délais de récupération insuffisants**
   - W9 : 64 km, long run 30 km + tempo 2x20 + 5x1000m. FC totale estimée : 9-10h d'effort sur la semaine.
   - W10 : 69 km, long run 32 km + tempo 40 min + 6x1000m. FC totale : 11h d'effort.
   - W11 : 75 km (pic), long run 35 km + tempo 2x20 + 4x1000m. FC totale : 12h d'effort.
   - W12 cutback : 60 km, long run 23 km. Réduction de 15 km seulement (20%) vs W11 — insuffisant après un pic de 75 km.
   - Pour objectif +ambitieux, réduire W11 de 75 à 70 km ET ajouter un cutback W10.5, mais structurellement impossible sans restructurer.

## Contradictions

1. **Safety_notes § Signes de surcharge vs progression_logic § intensité maintenue en affûtage (W13-W15)**
   - Safety note : "FC de repos > 8 bpm au-dessus de la normale pendant 3 jours consécutifs → cutback ou consulter."
   - Objectif +ambitieux crée un risque majeur que la FC de repos reste élevée en W12-W13 (fatigue chronique cumulée).
   - W13 impose "tempo 25 min seuil" (intensité maintenue) **malgré possiblement une FC de repos élevée** — contradiction directe avec la note de sécurité.
   - Patcher : ajouter une note "si FC repos > +8 bpm en W13, réduire tempo à 15 min et allonger l'affûtage à 4 semaines", mais le template refuse tout affûtage > 3 semaines (texte Mujika & Padilla).

2. **Contrainte utilisateur (objectif +ambitieux) vs progression_logic § 10-20% rule**
   - Texte : "La règle des 10-20% est respectée semaine après semaine... Aucun delta entre semaines consécutives ne dépasse 15% en dehors des cutbacks."
   - Pour escalader vers un objectif +10-15 s/km, il faudrait augmenter l'allure des séances qualité immédiatement (W1 tempo passant de AM-10/+10 s/km à AM-5/+15 s/km = saut de complexité), mais les volumes restent les mêmes. **Intensité ↑ + volume constant = surcharge neurodégénérative**, qui viole la règle de progressivité du template.
   - Impossible de patcher : la règle 10-20% vise le **volume**, pas l'intensité. Augmenter les deux en tandem exige une refonte complète du plan.

3. **Assumed_profile vs objectif revu**
   - Template suppose : "Coureur expérimenté ayant couru au moins un semi-marathon (idéalement sous 1h50 pour marathon sub-4h, ou sous 1h35 pour marathon sub-3h30)."
   - Si ton profil est réellement sub-1h35 demi, pourquoi vises-tu sub-3h30 comme "objectif plus ambitieux" ? Le template suppose déjà que tu es capable de sub-3h30 si tu visais sub-4h avec un semi à 1h50.
   - **Possible interprétation** : tu vises sub-3h15 (nettement plus ambitieux) ?
   - Si oui : impossible à patcher. Sub-3h15 exige un demi-marathon < 1h30 = allure marathon ~3min/km = saut de ~15 s/km. Les cascades de contradiction s'amplifient.

4. **Long run progression vs allure rehaussée : contradiction dans la spécificité**
   - W11 long run : "Km 12-32 : 20 km à allure AM." À l'allure AM originale, c'est 1h20-1h30. À AM -15 s/km, c'est 1h15-1h20.
   - Le template suppose que 35 km à AM originale = adaptation fiable. À AM rehaussée, 35 km = 1h45-1h50 (si AM original ~3h = 4m16/km, AM rehaussé ~3h15 = 4m02/km, 35 km = ~2h23).
   - **Problème** : à W11, tu aurais déjà couru 30 km (W9) + 32 km (W10) + long run 35 km en 3 semaines à AM rehaussée = **~97 km à haute spécificité** sans cutback intermédiaire. Risque de tendinite ischio-jambière (déjà flagged safety_notes pour fractionné) est **extrêmement élevé**.
   - Patcher : ajouter cutback W10 (réduction long run de 32 à 26 km, passage de 69 km W10 à 63 km), mais refond le bloc entier.

## Conclusion : verdict d'adaptabilité

**Le template NE SE PATCHE PAS pour un objectif materiel +ambitieux sans risque majeur.**

- **Si "+ambitieux" = sub-4h → sub-3h45** (une réduction de 15 min globale, soit ~5 s/km sur AM) : **possible mais précaire**. Ajouter un **microcutback ou réduction d'une séance W10-W11** stabiliserait le risque.

- **Si "+ambitieux" = sub-4h → sub-3h30** (réduction de 30 min, soit ~12-15 s/km sur AM) : **impossible sans restructuration majeure**. Il faudrait :
  1. Réduire W11 long run pic de 35 à 32 km.
  2. Ajouter un **cutback W10** (réduction W10 de 69 à 62 km, long run 32 → 26 km).
  3. Allonger l'affûtage à **4 semaines** (W13-W16 au lieu de 3) pour compenser la fatigue cumulée W9-W12.
  4. Réduire VO2max à 4x1000m (au lieu de 6) en W11 pour économiser l'énergie.
  5. **Restructurer le bloc 4** : W13 = 48 km, W14 = 36 km, W15 = 25 km, W16 = 12 km, W17 = race (nécessite 17 semaines, pas 16).

**Recommandation finale** : Le template est **optimisé pour un objectif sub-4h strict**. Toute escalade requiert une **reconstruction du plan de zéro**, idéalement avec 18-20 semaines plutôt que 16, et un ajout de cutbacks stratégiques. La rigidité est **non-négociable** sur les cutbacks fixes W4, W8, W12 et la structure des blocs — ces invariants sont le fondement de la sécurité du plan.