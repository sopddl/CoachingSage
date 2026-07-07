# Party — CHARGE MUSCU V2 (chantier dosage caméléon)

**Date** : 2026-06-08 · **Branche** : `chantier/dosage-cameleon-muscu`
**Spec** : `spec-charge-muscu-V2-2026-06-08.md` · **Statut** : DÉCISIONS FIGÉES, prêt pour implem SOPDDL (sur déclenchement Sophie)

## Casting
- 🎨 **Sally** — UX/design : affordance, où afficher sans surcharger, « proposition » vs « ordre » visuel.
- 🏋️ **Marc** — expert prépa physique / coach muscu : origine d'un poids crédible sans 1RM, sécurité.
- 🙋 **Maxime** — user novice : test de compréhension brut.
- 🧭 **Inès** — user posée/cadrée : précaution, ton, confiance.

## Problème (1 phrase)
Donner un **point de départ chiffré utile** sur la charge (vs l'aveugle actuel) tout en restant une **app qui propose et apprend**, pas un **coach qui prescrit** — sans claim médical.

## Pivot légal majeur (discussion Sophie)
- Clarification : **parler kg n'est PAS en soi un risque MDR** (le risque = finalité/claim médical, pas le chiffre — cf. Fitbod/Freeletics/Strong qui prescrivent des poids sans être dispositifs médicaux). Le « aucun kg » de D1 était une prudence auto-imposée, pas un mur légal.
- **Décision Sophie malgré ça : on reste SANS parler de kg.** L'indication de charge est **qualitative / relative** (ressenti reps-en-réserve + type de résistance), jamais un nombre en kilos. ⇒ exposition légale au plancher, et le problème « pas de 1RM » disparaît.

## Décisions figées
- **D-A — Langage** : consigne **reps-en-réserve** (« assez lourd pour que les 2 dernières reps soient dures, sans tricher ») + **badge résistance** (élastique faible/moyen/fort) quand il existe. Jamais de kg.
- **D-B — Tracking** : **niveau relatif interne par exo** (échelle cachée), jamais un kg. L'user voit « un peu plus / pareil / un peu moins ».
- **D-C — Poids du corps** : pas de bloc charge → consigne de **progression reps/variante** (genoux→complet→lesté).
- **D-D — Feedback ressenti** : **par exo, optionnel/skippable + filet en fin de séance** (le filet ne re-demande QUE les exos non notés). 3 choix : facile / juste / trop dur.
- **D-E — Apprentissage** (via `RoutineCycleService`) : **2× « facile » → +1 cran** ; **« trop dur » → −1 cran dès la 1ʳᵉ fois** (asymétrie sécurité, cf V-2) ; **max 1 cran/fois**.
- **D-F — Où** : affiché en **Manuel ET Minuté**, même wording ; le feedback s'adapte au canevas de chaque mode.

## Points de vigilance party à intégrer en V1 (validés Sophie « on intègre »)
- **V-1 (Maxime)** : « +1 cran » se mappe sur l'**équipement réel** de l'user (paliers concrets : ses haltères dispo, crans d'élastique), pas un cran abstrait.
- **V-2 (Marc)** : asymétrie sécurité (« trop dur » baisse tout de suite, « facile » attend 2×) + **échelle de variantes poids-du-corps réellement définie par exo** (sinon D-C = coquille vide).
- **V-3 (Sally)** : filet fin de séance ne re-demande que les non-notés ; contrôle ± **discret** en Manuel (au tap sur l'exo, pas permanent).
- **V-4 (Inès)** : suggestion **explicable** (« tu avais trouvé ça facile ») + **annulable** en 1 geste ; `requiresMedicalClearance` **bride les hausses silencieusement** (pas de message stigmatisant).

## Exigences dures conservées (EU MDR / référentiel)
Indication TOUJOURS modifiable en 1 geste ; respect `requiresMedicalClearance` ; aucun mot banni / claim médical + rappel « écoute ton corps, ne force pas sur la douleur » ; plafond de sécurité ; P0 transverses (1 héros+1 support / cas vide masqué jamais « 0 kg » / saisie non-bloquante).

## Réécriture du référentiel figé
**D1 amendée** : de « charge = sensation, aucune prescription » → « charge = **indication relative non-kg (reps-en-réserve + résistance), prescrite mais modifiable et apprenante** ». Zéro kg maintenu.

## Découpage livraison
- **V1 SOPDDL** : D-A → D-F + V-1 → V-4.
- **HTML décisions Sophie** (validation contenu, non bloquant design) : wording exact des consignes FR/EN/ES, vocabulaire badges résistance, phrase « écoute ton corps ».
- **V2** : échelle lestée fine poids-du-corps ; généralisation cross-sport (course/vélo ont déjà leurs zones).

## Prochaines actions
1. (Optionnel) HTML décisions wording → validation Sophie des textes.
2. Implem SOPDDL V1 **sur déclenchement Sophie** (pas avant).
3. Mettre à jour `referentiel-dosage-cameleon-v2-FIGE.md` (D1 amendée) au moment de l'implem.
