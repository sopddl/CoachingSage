# Adaptability : running-intermediaire-10k-8sem + p4-more-ambitious-goal

## Rigidity score
**3/10**

## Patch approach
Le template est **structurellement rigide** pour un objectif ambitieux. Son architecture 8 semaines, sa progression linéaire (6→7→8→9→7→10→11→12 km), et surtout sa **cutback W5 intégrée dans une logique d'adaptation tendineuse** rendent difficile une montée en charge supplémentaire sans casser les invariants de sécurité. Pour viser un objectif « au niveau au-dessus » (semi-marathon ~21 km, ou 10K sous 50 min vs. 55-70 min), il faudrait soit **étendre à 12-16 semaines**, soit accepter un **risque de blessure significatif** en W4-W6. Le template défend agressivement la progressions_logic ACSM/Higdon et les safety_notes ; les dépasser revient à ignorer les avertissements intégrés.

## Concrete modifications
Si l'objectif devient **semi-marathon 21 km** (upgrade majeur) :

- **W1 test 5K** : inchangé (calibrage d'allures identique).
- **W2 long run** : 7 km → **8 km** (+1 km anticipé).
- **W3 long run** : 8 km → **9 km**.
- **W4 long run** : 9 km → **11 km** (au lieu de 9 km) — **+2 km vs. original**, accélère vers la distance semi-marathon.
- **W5 cutback** : **NON SUPPRIMÉ** (risque n°1 si on le retire), mais **15% réduit vs. W4 (11 km)** = long run **9-10 km** au lieu de 7 km ; tempo 20 min vs 28 min ; intervalles 4×400 m maintenus.
- **W6 long run** : 10 km → **13 km** (saute plus loin).
- **W7 long run** : 11 km → **16 km** (approche semi-marathon).
- **W8 séance phare** : 10 km à allure cible → **16 km allure facile OU 13-14 km allure semi-marathon cible** (dépend du jour disponible ; si 16 km allure facile, ajouter J3 séance tempo court 15 min avant pour rappel intensité).

**Intervalles (si 10K rapide, ex < 50 min, est l'objectif à la place du semi) :**

- **W4-W7 intervalles** : passer de **800 m à 1000-1200 m** pour développer puissance à effort 10K cible.
- **W4 : 3×1000 m** allure 5K (ex : 6:00 min/km → 6 min par 1000 m).
- **W6-W7 : 5×1000 m** ou **4×1200 m** pour solidifier capacité VO2max sur durée proche du 10K réel.

**Renforcement (si montée en charge intensité) :**

- **Ajouter W4-W5** : single-leg deadlift 8 reps/côté, 2 séries (développement des ischio-jambiers et stabilité lombaire — crucial si on augmente intensité intervalles).
- **Nordic curls** : augmenter à **10 reps W6, 12 reps W7** (protection tendinite ischio-jambière face à charge accrue).

## Rigidity issues

- **Cutback W5 est architecturale** : elle est justifiée par la consolidation d'adaptation osseuse (remodelage tibial, tendons d'Achille/rotulien) décrite dans progression_logic (5). Supprimer ou fortement réduire la cutback crée un **risque direct de périostite tibiale ou tendinopathie chronique** à W6-W7 quand le volume repart. Citer : « *Les adaptations tendineuses et osseuses (remodelage osseux tibial, adaptation tendons d'Achille et rotulien) se consolident pendant les phases de décharge.* »
  
- **Progression linéaire du long run n'est pas élastique** : passer de « 6→7→8→9→7→10→11→12 km » à « accélérer vers 21 km » oblige à violer la règle « 10-20% par semaine » (progression_logic 2). Exemple W3→W4 : +1 km = 12.5% OK ; mais W4→W6 si on passe à 13 km = -22% (W5 cutback) puis +30% (W6) — acceptable mais limite. W6→W7 : 13→16 km = +23% — **franchit la limite supérieure de sécurité**.

- **Durée insuffisante : 8 semaines ne permet pas de préparer un semi-marathon à distance de sécurité**. La progression Higdon standard pour semi-marathon est **12-16 semaines** avec cutback stratégique. En 8 semaines, tu arrives à « 16 km en continu » mais pas nécessairement à « 21 km régulier et rapide ». Citer : « *Default objective : Courir 10 km en continu (objectif de temps libre, typiquement 55-70 min selon allure individuelle).* » — le template assume 10K comme plafond intentionnel.

- **Intensité VO2max : 800 m vs. 1000 m crée un saut métabolique**. Passer de 5×800 m à 4×1000 m = +25% de travail à allure 5K. Safety_notes dit : « *Ne jamais introduire deux nouveautés simultanément (nouveau terrain + nouveau volume OU nouvelle chaussure + nouvelle intensité).* » Or adapter à la fois long run (+2-3 km) ET intervales (+200 m de longueur) ET objectif rehaussé = **deux-trois nouveautés en une même adaptation**. Risque élevé.

- **Tapering W8 devient obsolète** : si l'objectif est semi-marathon, le tapering 5-7 jours (Mujika & Padilla) reste valide, mais la « séance phare 10 km » (J5 W8) devient sous-ciblée. Il faudrait soit changer le long run W8 à 16-17 km, soit modifier totalement le cycle W8.

## Contradictions

- **Assumption de profil vs. rehaussement d'objectif** : le profil assumed_profile dit « *Coureur régulier capable de courir 5 km en 30-35 min sans difficulté, pratique 2×/semaine depuis au moins 2 mois.* » Un coureur visant un **semi-marathon** demande typiquement 3-4 mois de base = **capacité 5K supposée en 25-28 min minimum** (pas 30-35 min). Si tu dépasses le profil assumed, tu dois aussi réviser le profil lui-même. **Contradiction implicite : l'objectif revu présume un coureur plus fort que l'assumed_profile ne le stipule.**

- **Safety_notes sur surcharge vs. progression accélérée** : safety_notes énumère les « *SIGNES DE SURCHARGE* » (FC +8-10 bpm, courbatures > 72h, perte d'allure, sommeil dégradé). Rehausser l'objectif ET garder 8 semaines = **risque accru de déclencher 3+ signes de surcharge simultanés** en W4-W6, date à laquelle le template prescrit « réduire volume de 30% et prendre 2 jours repos actif » — mais la W5 cutback est déjà la réduction planifiée. **Contradiction temporelle : si surcharge survient W4 avant la cutback programmée, le rattrapage devient impossible.**

- **Hydratation / nutrition long run** : safety_notes prescrit « *pour toute sortie > 60-70 min, planifier apport glucidique (30-60 g/heure).* » Un long run de 16 km à allure facile (RPE 4-5/10) = ~90-100 min. Cela sort des 60-90 min classiques ; exige plus de ravitaillement que le template ne le détaille (qui parle gel/dattes à km 5). **Pas de contradiction stricte, mais lacune de détail.**

---

## Verdict final

**Le template refuse l'upgrade d'objectif au-delà de ±10-15% sans restructuration majeure.** Une montée vers **semi-marathon (21 km)** nécessite :

1. **Extension à 12 semaines minimum** (ajouter W9-W12 avec progression long run 12→14→17→19 km et tapering décent).
2. **Ou réduction de la cible temps 10K** (viser 10K en 55 min au lieu de 55-70 min = intensité accrue, donc moins de volume ; incompatible avec semi ambition).
3. **Ou accepter risque de blessure** (sauter/compresser cutback, dépasser +20% /semaine) — **explicitement contre les safety_notes**.

Si l'objectif revu reste **10K mais plus rapide** (ex : < 50 min vs. 55-70 min), c'est **partiellement adaptable** : augmente intervalles 800→1000 m, densifie tempo W6-W7 à 35-40 min, allonge long run d'1-2 km (passant 11-12 km en W7) — mais risque dépasse toujours la tolérance safety.

**Score 3/10 car : flexibilité ultra-low sur la structure et durée ; progression_logic et safety_notes forment mur défensif ; cutback W5 non-négociable ; 8 semaines = limite absolue.**