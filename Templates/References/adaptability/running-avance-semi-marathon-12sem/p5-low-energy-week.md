# Adaptability : running-avance-semi-marathon-12sem + p5-low-energy-week

## Rigidity score
**7/10**

Le template propose des cutback (W4, W8) et une structure modulable (blocs tempo vs tempo continu, format intervalles variables). La logique de réduction d'intensité est documentée dans safety_notes. Cependant, la progression_logic énonce une "RÈGLE DES 10% HEBDOMADAIRE" rigide et les deux qualités obligatoires (VO2max + tempo) créent une tension avec une adaptation "baisser intensité" en semaine aléatoire.

## Patch approach

Adapter une semaine de fatigue sans désorganiser le plan : identifier la semaine actuelle en cours, réduire les volumes VO2max et tempo de 40-50% (maintenir la structure mais allégger), repousser les + gros efforts à la semaine suivante (W+1), et compenser par un cutback-like sur W (réduction mimée) tout en préservant une progression nette W → W+1. Le plan tolère ce patch car les cutback existants (W4, W8) fournissent un modèle pré-validé.

## Concrete modifications

**Exemple appliqué à W5 (semaine aléatoire en cours) :**

- **W5 J3 (VO2max)** Fractionné VO2max — 5×1000 m : **réduire à 4×1000 m** (au lieu de 5×1000 m). Repos 2 min 30 inchangé. Justification : -20% du volume VO2max, qualité maintenue (allure 4:30-4:40 inchangée).

- **W5 J5 (Tempo)** Séance seuil — 2×15 min : **réduire à 1×15 min continu + 1×10 min** (total 25 min vs 30 min en W5 standard). Allure seuil 5:00-5:10 inchangée. Justification : -17% volume tempo, structure tempo conservée.

- **W5 J1 (Endurance)** Sortie endurance — 12 km : **maintenir 12 km, allure facile**. Pas de coupe car séance de récupération (Z2).

- **W5 J7 (Sortie longue)** Sortie longue avec allure semi — 19 km : **réduire à 17 km** (10 km endurance Z2 + 7 km allure semi au lieu de 10 + 8). Allures inchangées. Justification : -11% volume, conserve la spécificité allure semi.

**Volume W5 adapté :** ~47 km → ~42 km (-11% vs standard W5, aligné au profil de cutback).

**W6 (semaine suivante, rattrapage) :** ne pas sauter la progression. Appliquer le plan standard W6 (~50 km, pas d'ajustement). Le léger déficit W5 (-5 km) sera compensé par la progression naturelle W6 (+8 km vs W5 adapté).

## Rigidity issues

- **DOUBLE QUALITÉ OBLIGATOIRE (progression_logic point 2)** : "chaque semaine hors cutback et taper contient IMPÉRATIVEMENT une séance VO2max ET une séance tempo". Si on adapte en semaine de fatigue, on conserve les deux qualités (4×1000 m + 1×15 min 1×10 min) mais allégées. Ce patch respecte formellement l'obligation tout en la modérant. Acceptable, mais demande une clarification : est-ce que "obligatoire" signifie absolue ou souhaitable ? Le patch suppose qu'allégée = conservée.

- **RÈGLE DES 10% HEBDOMADAIRE** : W5 standard +6% vs W4, W5 adapté +8% vs W4 adapté (42 km vs 39 km). La règle du +10% maximal est respectée, mais l'adaptation rend la semaine plus légère = moins de contrainte progressive. W6 vs W5 adapté aura une hausse de +19% (~50 km vs ~42 km), dépassant le +10% non cutback. **Contradiction mineure** : si on veut éviter le delta > +25%, faut lisser W6 à ~46 km au lieu de ~50 km, puis reprendre le standard en W7. Coûteux en souplesse.

- **ABSENCE DE CUTBACK PRÉ-DÉFINI EN COURS DE PLAN** : l'adaptation suppose une flexibilité intra-semaine (modifier J3, J5, J7 d'une W quelconque) que le template ne pré-planifie pas. Cela sort du cadre "couper une semaine entière comme W4 ou W8". Le template est rigide sur la structure du cutback (full-week, aux W4 et W8 fixes), moins sur l'ajustement micro (un j3 allégé au cœur d'une W standard).

## Contradictions

- **Safety_notes « SIGNES DE SURCHARGE NEUROMUSCULAIRE »** : "3+ signes simultanés → semaine allégée type cutback". Le profil d'adaptation décrit fatigue (sommeil dégradé, stress, grosse semaine boulot). Safety reconnaît implicitement qu'une réduction peut être nécessaire en cours de plan, ce qui valide le patch. **Pas de contradiction directe.**

- **PROGRESSION_LOGIC RÈGLE DES 10%** : si fatigue W5 et rattrapage W6 =  +19% delta, cela viole le principe déclaré. **Solution** : modifier W6 à ~46 km (au lieu de ~50 km) pour absorber le delta progressivement : W5 adapté 42 km → W6 réduit 46 km (+10%), W7 standard 52 km (+13%, acceptable car suivi d'un cutback W8 historique). Coûte 4 km en finesse, gagne la conformité progressive_logic.

- **MAINTAINED STRENGTH EN CUTBACK W4 ET W8** : le template cutback (W4, W8) conserve des renforcement préventif (cités explicitement en W4 et W8). L'adaptation W5 ne modifie pas le J7 renforcement (non prévu en W5 du template, car structure 4 séances/sem), donc pas de risque d'interruption préventive.