# Adaptability : musculation-expert-strength-5x5-cycle + p4-more-ambitious-goal

## Rigidity score
**3/10**

## Patch approach
Le template est **structurellement rigide** sur l'objectif ambitieux car il repose sur une progression linéaire à double étage (paliers hebdomadaires fixes : +5 kg squat/DL, +2,5 kg bench/OHP/rowing) calibrée pour atteindre ~90-92% 1RM en W10 avant les PR de W11. Rehausser l'objectif exigerait d'atteindre 95%+ 1RM, ce qui casse le découpage des blocs et crée un risque lombaire non documenté. Le template ne se *patch* pas élégamment — il faudrait reconstruire partiellement les Bloc 2 et 3.

## Concrete modifications
Si l'objectif est "PR maximaux en W11 à 95-98% 1RM au lieu de 88-92%", les modifications concrètes seraient :

- **W5 J1 (A7) — Back squat** : au lieu de W3 +2,5 kg, commencer à W3 +5 kg (+5 kg supplémentaire) pour repartir plus haut du Bloc 2. Cela crée une montée plus agressive.
- **W6 J1 (B8) — All movements** : +5 kg squat/DL, +3,75 kg (1,25 × 3 plaques) bench/OHP/rowing au lieu de +2,5 kg. Palier de W6 devient 82% → 84% vs 85% initial.
- **W7 J1 (A10) — All movements** : +5 kg squat/DL, +3,75 kg bench/OHP/rowing (même rythme accéléré). Pic de W7 passe de ~87-88% → ~89-90%.
- **W9 J1 (A13) — All movements** : au lieu de W7 +2,5 kg, passer à W7 +5 kg pour tous les mouvements (montée accélérée du Bloc 3). Cela crée ~92-93% 1RM en W9.
- **W10 J1 (B14) — All movements** : +5 kg squat/DL, +3,75 kg bench/OHP/rowing (au lieu de +2,5 kg). Cela crée ~94-95% 1RM en W10.
- **W11 J5 (PR séance)** : structure identique, mais cibles révisées : squat +10 kg PR, bench/OHP +5 kg, deadlift +7,5 kg (au lieu de +5 kg standard).

## Rigidity issues
- **Progression_logic contradiction majeure** : la progression_logic (point 2) énonce explicitement que "la double progression par paliers fractionnés" progresse de +5/+2,5 kg hebdomadaires POUR ATTEINDRE les blocs d'intensité planifiés (70-80%, 80-90%, 88-100% sur 3 blocs). Accélérer les paliers casse cette architecture et déplace le pic vers une semaine non prévue (le pic était W10, les PR W11 ; si on accélère, le pic pourrait être W9-W10, laissant peu de réserve).
- **Cutback weeks W4 et W8 non ajustables** : les cutback de -15% et réduction à 3x5 sont *obligatoires* selon la progression_logic (point 3, "CUTBACK WEEKS OBLIGATOIRES"). Elles sont positionnées à W4 et W8 pour permettre la super-compensation avant les blocs suivants. Si on accélère la montée, la super-compensation de W4 ne suffit pas à supporter une Bloc 2 plus intense dès W5.
- **Risque lombaire spécifique au deadlift** : le template limite le deadlift à 1 rep maximum en W11 J5 (progression_logic pt.5) pour des raisons documentées : "le risque lombaire augmente exponentiellement sur les séries sub-maximales répétées au-delà de 95% 1RM". Si on vise des PR à 95-98%, on **ne peut pas augmenter le volume de deadlift** — il faudrait rester à 1x1 en W10 aussi, ce qui crée une désynchro avec squat/bench/OHP qui font 5x5.
- **Gestion de la fatigue neuromusculaire** : safety_notes énumère les signes de surcharge (FC repos +10 bpm, vitesse de barre ralentie, irritabilité, sommeil dégradé, force -15%). Accélérer la progression augmente le risque de ces symptômes. La structure actuelle prévoit 3 blocs de 4 semaines pour que la fatigue se « drainne » via les cutbacks. Une progression accélérée rend les cutbacks de W4 et W8 insuffisants.

## Contradictions
- **safety_notes vs deadlift lourd répété** : les notes énumèrent "douleur lombaire aiguë pendant ou après deadlift" comme drapeau rouge d'arrêt immédiat. Or, viser 95-98% 1RM deadlift cumulé sur W9-W10 (3 séances de 5 reps chacune à ~94-95% 1RM) contredit directement cette prudence. Le template limite à W11 J5 = 1x1 uniquement pour cette raison. Rehausser casse ce contrôle.
- **progression_logic pt.2 vs montée accélérée** : "Si un mouvement stagne (impossibilité de compléter 5x5 sur 2 séances consécutives), réduire le palier de moitié." La progression accélérée (paliers +3,75 kg au lieu de +2,5 kg) augmente la probabilité de stagnation dès W6-W7. Le template n'a pas de plan B intégré pour adapter les paliers *à la hausse* — il prévoit only reduction logic.
- **Intensité RPE vs nombre de séances** : le template prévoit RPE 8-8,5 en W5-6, 8,5-9 en W7, 9 en W10. Une montée accélérée forcerait RPE > 9 dès W7-W8, ce que safety_notes interdit explicitement : "RPE 9-10 réservé aux W10-W11 uniquement. Travailler à RPE > 9 chaque semaine provoque une fatigue neuromusculaire cumulative qui annule les gains en force."
- **Cutback W8 insuffisant** : si le pic de W10 passe de 88-90% → 94-95%, le cutback de W8 à -15% (= ~72% vs 88% = référence) laisse 22 points de pourcentage à rattraper en 2 semaines (W9-W10). C'est trop : la super-compensation ne suffit pas, et la fatigue s'accumule.

---

## Conclusion synthétique
**Le template refuse l'adaptation ambitieuse sans risque démontré.** Trois raisons :

1. **Deadlift : limitation de sécurité inégale** — bench/squat/OHP peuvent théoriquement atteindre 95-98% en séries répétées (5x5 est plus sûr que 5x1 au-delà de 95% sur ces mouvements). Le deadlift doit rester à 1x1 en W11 (et donc aussi en W10 pour cohérence). Cela crée une situation où squat/bench/OHP progressent agressivement, deadlift non — ce déséquilibre n'est pas adressé dans le template.

2. **Fatigue neuromusculaire non gérée** — accélérer les paliers (+3,75 kg vs +2,5 kg) augmente drastiquement le risque de surcharge avant W11. Les cutbacks W4 et W8 sont trop loin pour drainer la fatigue d'une montée accélérée.

3. **Safety notes vs RPE** — aller au-delà de RPE 9 avant W10 est explicitement interdit. Une progression accélérée le force dès W7-W8.

**Recommandation** : pour "rehausser l'objectif", il faudrait soit *allonger le cycle à 16 semaines* (4 blocs au lieu de 3, avec cutbacks intermédiaires), soit *accepter une cible PR plus modeste* (92-93% au lieu de 95-98%). Le template dans sa forme actuelle ne supporte pas une ambition "maximale PR" sans sacrifier la sécurité lombaire ou la gestion de la fatigue SNC.