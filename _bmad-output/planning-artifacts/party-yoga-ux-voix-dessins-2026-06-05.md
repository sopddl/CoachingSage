# Party — POC yoga UX : voix + dessins

**Date** : 2026-06-05
**Sujet** : challenger l'approche UX du POC yoga AVANT de coder — 3 demandes Sophie : (1) voix TTS qui explicite la posture, (2) bug orientation dessin (couché affiché debout), (3) layout dessin riquiqui à grossir/recentrer + texte dessous.
**Statut** : ✅ décisions D1–D4 tranchées. **Pas de code lancé** (règle party). Prêt pour implem POC SOPDDL si Sophie le déclenche.
**Persona lead** : Sally (UX Expert designer, BMAD).

---

## Casting

- 🎨 **Sally** — UX Expert / designer (lead, demandée par Sophie) : verdict affordance dessins + voix comme modalité + hiérarchie visuelle.
- 🧘 **Inès** — yoga 38 ans, pratique sans coach (user persona terrain, source `product-brief` + party 06-02) : juge « dessin juste + voix qui place le corps = je tiens la posture sans coach ? ».
- 📱 **Karim** — iOS SwiftUI : coût / réversibilité / risques tech.
- 📋 **Hugo** — PM : scope POC minimal.

**Matos** : mémoire `v2_chantier_yoga_ux_voix_dessins.md` (carte de code), party `seance-presentation-2026-06-02` (HUB+FOCUS, yoga = « flow », règle anti-Decathlon), brief illustrations `2026-05-22` (style monogram SVG, lisible 48pt).

---

## Problème (cadrage validé)

Le yoga est le seul sport **non-chiffré et postural** de l'app — la compréhension repose entièrement sur « montrer la bonne posture » + « guider à la voix ». Or aujourd'hui le dessin **ment** (couché affiché debout, fallback `drawWarrior1` sur `.unknown`) et est **illisible** (riquiqui, viewbox plat 80×48), donc Inès ne peut pas pratiquer sans coach — ce qui est précisément la promesse de l'app.

---

## Tour de table — points saillants

- **Inès** : sur le tapis on ne lit pas (yeux mi-clos). Le dessin doit être juste au 1ᵉʳ regard ; la voix doit **placer le corps** (« allonge-toi, bras le long du corps, relâche les épaules »), pas décrire les bienfaits. « Guide l'entrée, accompagne le souffle, tais-toi sur le reste. »
- **Sally** : (1) bug orientation = **P0 non négociable** (silhouette debout sur posture couchée détruit la confiance, pire que pas de dessin). Le fallback générique = pansement accepté **comme filet** au POC, mais la vraie cible = 1 dessin par posture. (2) Voix + dessin = **redondance volontaire** (forme + séquence d'entrée) = ce qui remplace le coach. (3) Layout : viewbox **portrait/carré** pour yoga (sinon on grossit du vide), **un seul grand dessin centré**, pas de strip multi-frames façon muscu (yoga = pose tenue, pas geste storyboardé).
- **Karim** : fallback orientation-aware = ½ j, local, réversible — **détection keyword doit matcher le sanskrit** (`originalName` = match_key), pas le nom vulgarisé affiché (sinon compile OK mais rate à l'exécution). Viewbox 80×48 est **partagé tous sports** → override yoga local, pas de refacto global. Texte voix = table statique sanskrit→script en dur au POC (zéro réseau).
- **Hugo** : le POC valide **UNE question** — « dessin juste + voix qui place le corps = Inès tient la posture sans coach ? ». Si oui → industrialiser la couverture. Si non → industrialisation économisée.

---

## Recadrage clé Sophie — timing de la voix (yoga ≠ course)

La pré-annonce « anti-Decathlon » vient du **cardio/HIIT** (effort qui défile). Le yoga n'a pas ce problème : la posture est **tenue**. Deux moments distincts :
1. **Entrée** → script de placement lu **pendant qu'on s'installe** (pas une pré-annonce sèche).
2. **Maintien** → silence, ou 1-2 rappels souffle espacés. Trop parler pendant le hold = décrochage.

---

## Décisions (tranchées par Sophie)

| # | Sujet | Décision | Conséquence |
|---|-------|----------|-------------|
| **D1** | Couverture dessin | **Filet anti-absurde au POC** : 3 familles d'orientation (lying / seated / standing) inférées par keyword sanskrit → silhouette générique de la bonne orientation. Couverture posture-par-posture → **V2**. | Plus jamais d'orientation absurde. Pas encore LE dessin de chaque posture (savasana ≠ pont ≠ poisson). |
| **D2** | Où vit le texte voix | **Table statique sanskrit→script en dur, 4-5 postures témoins, FR seul** (POC). Industrialisation (champ template / service) → V2. | POC sans dépendance réseau. Dette i18n + couverture assumée pour la V2. |
| **D3** | Timing & mode voix | **Pas de pré-annonce cardio.** Voix déclenchée **à l'entrée dans la posture** (script de placement), puis **silence ou 1-2 rappels souffle espacés** au maintien. Branché sur le **mode FOCUS existant**, pas de nouveau mode. | Respecte le « flow » yoga (party 06-02). Pas de re-litige mode. |
| **D4** | Viewbox dessin | **Override yoga local** (viewbox portrait/carré, dessin grossi + centré, texte dessous). Pas de refacto profil-par-sport global. | Yoga lisible sans régresser muscu/course. |

---

## Scope POC (Hugo)

**IN** :
1. Fix orientation = filet anti-absurde (3 familles, détection **sanskrit**).
2. Viewbox yoga grossi / centré / portrait, texte dessous.
3. Voix = script d'entrée ad-hoc sur **4-5 postures témoins** dont : une **couchée** (savasana), une **assise** (sukhasana), une **debout** (guerrier). Déclenchée à l'entrée, FR seul.

**OUT (V2)** : couverture dessin posture-par-posture exhaustive ; génération du script par service/IA ; multi-langue des scripts ; refacto viewbox profil-par-sport.

**Le POC valide** : « dessin juste + voix qui place le corps = pratique sans coach ? »

---

## Prochaines actions

1. **Implem POC SOPDDL** (si Sophie déclenche) — fichiers cartographiés :
   - `YogaIllustration.swift` : familles d'orientation + détection sanskrit + fallback orientation-aware (remplace `drawWarrior1` systématique sur `.unknown`).
   - `IllustrationStyle.swift` + `SessionFocusView.swift:278/680` + `ExerciseTimelineCard.swift:98` : override viewbox yoga (taille / centrage / portrait).
   - `SessionFocusView.swift` (~399 setupVoice, ~427-498 announces) : brancher `voiceGuide.announce(script)` à l'entrée de l'exo yoga + table statique sanskrit→script.
2. **Vérifier** que les match_key sanskrit du catalogue yoga couvrent bien les 3 familles d'orientation (sinon la détection rate).
3. **ui-reviewer obligatoire** avant tout commit `Views/**` (verrou CLAUDE.md) : screenshots multi-postures dont une couchée (savasana).
4. **Re-party / review Sally** sur la couverture posture-par-posture (V2) une fois le POC validé au simu.
