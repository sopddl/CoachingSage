# Adaptability : running-avance-semi-marathon-12sem + p1-reduce-frequency

## Rigidity score
**4/10**

## Patch approach
Le template est construit rigidement autour de 4 séances/semaine avec une logique de double qualité hebdomadaire obligatoire (VO2max + seuil toujours séparées par 48h minimum). Passer à 2 séances/semaine exige de fusionner ou supprimer une qualité par semaine, ce qui **viole directement la progression_logic (principe 2 : "DOUBLE QUALITÉ HEBDOMADAIRE OBLIGATOIRE")** et démonte l'équilibre neuromusculaire du plan. Le renforcement préventif ne peut plus être maintenu en routine — il doit basculer en séance autonome ou disparaître. La sortie longue + une seule qualité (seuil OU VO2max) reste possible, mais produit un plan hybride très différent du template original.

## Concrete modifications

### Stratégie générale
Garder les 2 séances prioritaires par semaine : **(1) sortie longue progressive** (anchor de spécificité semi) et **(2) une séance qualité alternée ou fusionnée** (seuil ET VO2max compressés en une seule séance par alternance ou blocs mixtes). Supprimer la sortie endurance "facile" J1 (perte de charge aérobie de base). Renforcement préventif déporté en routine 2×/semaine autonome hors plan (15 min, 3×/sem minimum si possible).

### Modifications semaine-par-semaine

**W1 (40 km → ~28 km estimés)**
- **Supprimer** : J1 endurance 10 km
- **Conserver/fusionner** : J3 VO2max 6×400 m + J5 seuil 2×10 min → **J3 séance mixte VO2max-seuil** : 6×400 m (VO2max) + 2×8 min seuil après récupération 5 min (fusionner sur une même séance, durée totale ~60 min). Récupération 48h entre J3 mixte et J7 sortie longue OK.
- **J7** : sortie longue 14 km inchangée
- **Renforcement** : À faire autonome 2×/sem (jeudi/dimanche, 15 min : nordic curl 3×5, single-leg squat 3×6, calf raises 3×12, clamshell 3×15, planche 3×45 sec). **Contradiction possible** : safety_notes insiste "obligatoire en début de plan", mais logistiquement impossibilisé en routine de 4 séances fusionnées.

**W2 (43 km → ~30 km)**
- **Supprimer** : J1 endurance 11 km
- **J3** : VO2max 6×600 m (30 min)
- **J5** : seuil 3×8 min seul (25 min) — garder la qualité seuil seule cette semaine (alternance vs W1)
- **J7** : sortie longue 16 km inchangée
- **Renforcement autonome** 2×/sem

**W3 (46 km → ~32 km)**
- **Supprimer** : J1 endurance 12 km
- **J3** : VO2max 8×400 m seul (45 min)
- **J5** : seuil tempo continu 30 min seul (W3 affiche déjà le pic d'introduction du tempo continu)
- **J7** : sortie longue 17 km inchangée
- **Renforcement autonome** 2×/sem

**W4 cutback (39 km → ~26 km)**
- **Supprimer** : J1 endurance légère 9 km
- **J3** : VO2max réduit 5×400 m seul (30 min, cutback logique)
- **J5** : seuil tempo réduit 20 min seul
- **J7** : sortie longue 14 km inchangée
- **Renforcement autonome** 2×/sem (lighter : 2×5 nordic, 2×6 single-leg, 2×10 calf, 2×12 clamshell)

**W5 (47 km → ~32 km)**
- **Supprimer** : J1 endurance 12 km
- **J3** : VO2max 5×1000 m seul (50 min) — introduction du 1000 m sans seuil cette semaine
- **J5** : seuil 2×15 min seul (35 min au total, repos 3 min) — **RISQUE** : seuil s'intensifie mais sans prior VO2max en même semaine pour acclimater
- **J7** : sortie longue 18 km inchangée
- **Renforcement autonome** 2×/sem

**W6 (50 km → ~34 km, introduction allure semi)**
- **Supprimer** : J1 endurance 12 km
- **J3** : VO2max 6×800 m seul (45 min)
- **J5** : seuil 15 min + segments allure semi 3×5 min (fusionné, durée ~40 min) — **COMPRESSION** : la session W6 d'origine contient déjà cette fusion (exercises multiples jour 5), donc patch minimal
- **J7** : sortie longue 19 km avec 8 km allure semi (inchangée, c'est l'élément clé de W6)
- **Renforcement autonome** 2×/sem

**W7 (52 km → ~36 km, pic seuil)**
- **Supprimer** : J1 endurance 13 km
- **J3** : VO2max 6×1000 m seul (60 min)
- **J5** : seuil tempo continu 35 min seul (pic du plan) — **CONTRADICTION INTERNE** : W7 affiche déjà tempo 35 min sans compétition VO2max, donc pas de double qualité en vrai. Patch maintient W7 tel quel.
- **J7** : sortie longue 21 km inchangée
- **Renforcement autonome** 2×/sem

**W8 cutback (44 km → ~29 km)**
- **Supprimer** : J1 endurance légère 10 km
- **J3** : VO2max réduit 5×800 m seul (35 min)
- **J5** : seuil réduit 20 min + renforcement intégré (nordic curl, single-leg squat) dans cooldown (originalement W8 fusionne déjà seuil + renforcement dans type "mixed")
- **J7** : sortie longue 16 km inchangée
- **Renforcement autonome** 2×/sem léger

**W9 pic (55 km → ~38 km)**
- **Supprimer** : J1 endurance 13 km
- **J3** : VO2max 6×1000 m seul (60 min)
- **J5** : seuil tempo continu 35 min seul
- **J7** : sortie longue pic 23 km inchangée (c'est le stimulus majeur du pic)
- **Renforcement autonome** 2×/sem

**W10 (52 km → ~36 km, spécificité semi longue)**
- **Supprimer** : J1 endurance 12 km
- **J3** : VO2max 5×1000 m seul (50 min)
- **J5** : seuil 25 min + strides allure semi 4×2 min (fusionné, durée ~40 min, originalement W10 contient déjà cette fusion)
- **J7** : sortie longue 21 km avec 10 km allure semi (inchangée, c'est l'élément clé)
- **Renforcement autonome** 2×/sem

**W11 taper (38 km → ~25 km)**
- **Supprimer** : J1 endurance légère 9 km
- **J3** : VO2max réduit 4×800 m seul (35 min)
- **J5** : seuil réduit 20 min + segments semi 3×3 min (fusionné, ~35 min)
- **J7** : sortie longue taper 16 km inchangée
- **Renforcement autonome** 1×/sem léger ou none (taper = repos)

**W12 race week (20 km + course → ~15 km + course)**
- **Supprimer** : J1 activation 6 km (déjà marginal)
- **J3** : strides/activation 15 min + 4×90 sec semi (inchangée, déjà ultra-réduite)
- **J5** : mobilité + checklist inchangée
- **J7** : course 21,1 km inchangée
- **Renforcement autonome** : none, semaine de repos

---

## Rigidity issues

1. **Violation du principe 2 (double qualité obligatoire)** : Le template stipule "IMPÉRATIVEMENT une séance VO2max ET une séance tempo/seuil (…) ces deux qualités ne sont jamais le même jour ni consécutives (récupération minimale 48h)." Adapter à 2 séances/semaine force soit à supprimer l'une des deux qualités chaque semaine (W1, W3, W4, W5, W7, W8, W9, W11 deviennent mono-qualité), soit à les fusionner sur une seule séance (violant le "jamais le même jour"). **Le template est rigidement construit autour de cette dualité**, donc réduire de 4 à 2 séances la démonte structurellement.

2. **Renforcement préventif "obligatoire" devient impossible à intégrer** : Safety_notes et progression_logic insistent "ces exercices apparaissent explicitement en W1 et se maintiennent tout au long du plan" et "OBLIGATOIRE en début de plan". Avec 2 séances/semaine, il n'y a plus de créneaux autonomes pour renforcement sans cannibaliser les séances de course. **Le patch déporte le renforcement en routine autonome 2×/semaine (~15 min hors plan)**, ce qui n'est pas dans le scope du template original.

3. **Sortie endurance "facile" (J1) supprimée** : La régénération aérobie passive du J1 est perdue. Cela réduit la charge aérobie totale de ~15-20 km/sem, soit un écart plus important que les cutbacks intégrés du plan (W4, W8 : -15%). **Risque** : moins de développement de la base aérobie (Zone 2), même si la sortie longue la pallie partiellement.

4. **Alternance VO2max ↔ seuil par semaine crée une rupture de progression** : Le template affiche une progression linéaire de chaque qualité (VO2max : 400 m → 600 m → 400 m → 600 m → 1000 m → 800 m → 1000 m / seuil : 2×10 → 3×8 → 30 min → 20 min → 2×15 → 15 min → 35 min). En alternant semaine-par-semaine, W2 n'a que du seuil (pas de VO2max), ce qui brise la cohésion. **L'adaptabilité est possible mais au prix d'une progression moins fluide.**

5. **Compression VO2max + seuil sur une même séance (W1, W6, W10)** : Le patch propose des mélanges comme "6×400 m + 2×8 min seuil" sur J3. Bien que techniquement possible, le template n'offre aucun exemple d'exercice mixte préparé. Le coureur doit improviser l'ordre, les repos, les transitions — ce qui requiert une autonomie décisionnelle non anticipée par le template.

---

## Contradictions

1. **Safety_notes ← → Renforcement préventif déporté** : La note "RÈGLES GÉNÉRALES : Pattern hebdo : J1 endurance / J2 repos / J3 intervalles / J4 repos / J5 tempo / J6 repos ou mobilité / J7 sortie longue" suppose 7 jours d'espace et routines de renforcement. Avec 2 séances/semaine, ce pattern s'effondre. Si le coureur ne peut pas faire le renforcement préventif (nordic curl, single-leg squat), il court un **risque majeur de tendinite ischio-jambière**, explicitement listée en safety_notes comme "risque majeur du coureur avancé qui intensifie le fractionné" et "Cause fréquente : (…) nordic curls absents de la routine."

2. **Progression_logic (règle 10%) ← → volume réel réduit** : La progression_logic affiche "W1 40 → W2 43 → W3 46 km" avec delta hebdo de +7-12%. En réduisant à 2 séances, le volume passe à ~28 → 30 → 32 km (delta +7%). Formellement conforme à la règle 10%, **mais le contexte de "charge avancée sur demi-marathon" supposait 40+ km/sem pour éprouver les adaptations aérobie-anaérobie simultanées**. À 28-38 km/sem, le coureur n'atteint jamais le pic de 55 km (W9), ce qui diminue l'effet d'entraînement.

3. **Double qualité ← → Pas de repos minimum 48h si fusionné** : Safety_notes insiste "Récupération minimale 48h entre séances intenses (intervalles et tempo ne doivent pas être consécutifs)." Si on fusionne VO2max (J3) + seuil (J5) sur une même journée (ex. : J3 mixte), cela viole directement cette règle pour cette séance du jour. **Pour respecter les 48h minimum, il faudrait que J3 mixte soit suivi d'un repos minimum jusqu'à J7 sortie longue**, ce qui est vrai (4 jours), mais la fusion elle-même sur une même séance mélange deux intensités différentes sans transition, augmentant le risque de décompensation.

4. **Taper W11-W12 logic ← → Double qualité impossible** : Safety_notes affirme "TAPER W11-W12 : volume réduit de 30-40% mais maintien des stimuli de vitesse (strides, segments allure semi) pour éviter la désentraînement des fibres rapides". Avec 2 séances/semaine en taper, il n'y a de place que pour 1 qualité (VO2max court OU seuil court) + sortie longue réduite. La perte simultanée des deux stimuli de vitesse (même si réduits) en W11 est plus sévère que prévue, risquant un **désentraînement partiel des fibres rapides** contrairement à l'intention du template.