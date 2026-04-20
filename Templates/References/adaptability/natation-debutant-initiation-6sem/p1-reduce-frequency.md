# Adaptability : natation-debutant-initiation-6sem + p1-reduce-frequency

## Rigidity score
**7/10**

## Patch approach

Le template est conçu pour 2 séances/semaine espacées de 72h (progression_logic point 2), donc la contrainte utilisateur ne demande pas une réduction de fréquence — elle la CONFIRME. Cependant, l'utilisateur formule l'adaptation comme s'il redoutait une fréquence plus élevée implicite. Le patch consiste à valider que 2 séances/semaine sont suffisantes ET à fusionner légèrement le contenu pédagogique pour garantir cohérence motrice sans surcharger une séance unique. La rigidité réside dans le nombre de drills distincts par semaine (W1-W4 introduisent chacun 4-5 drills spécialisés) — en 2 séances, il faut prioriser les drills critiques et reporter les secondaires.

## Concrete modifications

- **W1 J1** « Découverte équilibre » : GARDER INTACT (streamline, position poisson, battement bord, 25 m jambes, 4×25 m crawl = validation équilibre).
- **W1 J4** « Consolidation glisse + bras » : FUSIONNER avec J1 — SUPPRIMER catch-up drill J4, le déplacer en W2 J1. Remplacer par 25 m jambes seules (validation) + 4×25 m crawl complet. Durée J4 réduite à 35 min (au lieu de 45).
- **W2 J1** « Drill propulsion » : INTRODUIRE catch-up drill (reporté de W1 J4) + fist swim (programmé) + 6×25 m crawl → allonger J1 à 50 min pour absorber la charge drill. SUPPRIMER tentative 2×50 m W2 J4.
- **W2 J4** « Sculling + allongement » : RÉDUIRE sculling à 3 séries (au lieu de 4), SUPPRIMER 6-3-6 drill. GARDER 4×50 m crawl continu (cible de W2). Durée 40 min.
- **W3 J1** « Respiration latérale » : GARDER intact side kick with breath (4×25 m) + respiration latérale statique + 3×75 m (volume exact). Durée 50 min.
- **W3 J4** « Consolidation respiration » : SUPPRIMER side kick bilatéral (4×25 m redondant avec J1), RÉDUIRE 3×75 m à 2×75 m, GARDER 1×100 m premier essai (objectif W3). Durée 40 min.
- **W4 J1** « 100 m confirmé + drill bilatéral » : GARDER side kick bilatéral + catch-up bilatéral (timing + respiration) + 3×100 m. SUPPRIMER le 150 m (reporté en W4 J4 réduit à 1×100 m pour laisser volume à J4).
- **W4 J4** « Volume 150 m » : RÉDUIRE fist swim/crawl ouvert à 2 séries (au lieu de 4), SUPPRIMER 150 m premier essai (trop ambitieux en cutback W5). GARDER 2×100 m bilatéral confirmé. Durée 40 min.
- **W5 J1** « Cutback — rappel drills » : GARDER streamline + side kick bilatéral (4×25 m) + 3×100 m (volume cutback stable). SUPPRIMER 6-3-6 drill de J4 — intégrer en 10 min comme transition W4→W6. Durée 45 min.
- **W5 J4** « Cutback — 150 m » : RÉDUIRE 6-3-6 drill (si non supprimé J1) à 2 séries, RÉDUIRE 2×100 m à 1×100 m, GARDER 150 m confirmation. Durée 40 min. **Note critique** : le volume W5 cutback est 700 m vs 850 m W4 (progression_logic point 5). Avec 2 séances : J1 = 300 m (6×25 drill + 3×100), J4 = 175 m (1×100 + 1×75 = 175, ou 2×75 + 1×25) = **475 m total W5**. Cela viole le cutback minimum de 700 m (22% sous-cutback, vs 15% prescrit). **RISQUE MODÉRÉ** : consolidation insuffisante avant W6 phare.
- **W6 J1** « Activation pré-performance » : GARDER rappel drills (fist swim + side kick, 4×25 m) + 2×100 m allure cible (au lieu de 2), RÉDUIRE 175 m à 1×150 m (6 longueurs). Durée 40 min.
- **W6 J4** « Séance phare 200 m » : GARDER INTACT (1×200 m + récupération + optionnel 100 m libre). Durée 50 min.

## Rigidity issues

- **Point 5 de progression_logic (CUTBACK W5 OBLIGATOIRE)** : réduction drastique du volume W5 avec 2 séances seulement (475 m vs 700 m prescrit = 32% sous objectif). Le template prescrit une cutback de 15% (700 m). Avec fusion à 2 séances, la consolidation musculaire et motrice avant la séance phare est **compromise**. La progression_logic stipule « L'ordre est : drill de 25 m maîtrisé → application sur 50 m → extension à 75-100 m » — avec W5 dilué, le risque est une fatigue épaule ou une régression technique en W6 J4.
- **Progression_logic point 2 (72H ESPACEMENT)** : le template exige 3 jours entre séances. Avec 2 séances fixes J1 et J4, cet espacement est respecté (72h pile). **Pas de rigidité ici** — compatible.
- **Drills spécialisés non interchangeables (point 3)** : chaque drill cible un aspect (streamline, fist, catch-up, side kick, fingertip). Avec 2 séances, le 6-3-6 drill (timing/rotation, semaines 2-3-5) doit être priorisé ou reporté. Dans le patch proposé, 6-3-6 est **supprimé de W2 J4** (surcharge) et **réduit à 2 séries W5** (au lieu de 4-5). Si la rotation du corps reste mal maîtrisée, cela affecte la respiration bilatérale W4. **Risque modéré de dégradation technique**.
- **Point 4 (RESPIRATION BILATÉRALE W4 SEULEMENT)** : le patch respecte cette invariant. Mais W3 respiration unilatérale dépend fortement du 6-3-6 drill (timing). Sa réduction crée un risque : moins de sensibilité de timing → respiration bilatérale W4 plus chaotique. **Rigidité du lien drill-respiration non transparent**.

## Contradictions

- **W5 cutback vs volume total 2 séances** : progression_logic définit 700 m W5 (15% sous 850 m W4). Patch 2 séances produit ~475 m (32% sous W4). **Contradiction directe avec principe 5** : « La semaine n'est pas une semaine facile — c'est une semaine d'intégration ». Une sous-charge aussi forte (32%) n'intègre plus, elle stagne ou régresse. Safety_notes (SIGNES DE SURCHARGE) mentionne « sensation de nager dans du sirop (lourdeur inhabituelle) → revenir à la semaine précédente ». Un W5 trop léger crée l'inverse : légèreté artificielle masquant une consolidation insuffisante, puis choc en W6 phare.
- **Sécurité respiration W3-W4** : safety_notes (DRAPEAU ROUGE) cite « Douleur cervicale ou nuque raide après la séance : soulèvement de tête trop fréquent ». Avec réduction des drills side kick (W3 J4 réduit à 2×75 m sans drill prep), le nageur entre en W4 respiration bilatérale avec moins de maîtrise latérale. Risque accru de soulèvement de tête → douleur cervicale. **Contradiction avec sécurité**.
- **Progression distance discontinue** : progression_logic énonce « Delta hebdo maintenu entre 10 et 25% hors cutback ». W2 J4 supprime tentative 50 m → volume W2 = ~300 m (J1) + ~200 m (J4 réduit) = 500 m vs W1 ~400 m = +25%. W3 = ~350 m (J1) + ~200 m (J4 réduit) = 550 m vs 500 m = +10% ✓. W4 = ~500 m + ~200 m = 700 m vs 550 m = +27% (hors cutback ok). **W2-W3 delta OK**, mais la progression casse à W5 (475 m vs 700 m W4 = -32%, hors cutback donc inexplicable dans la progression_logic).

**Synthèse contradictions** :
1. W5 cutback volume insuffisant (475 m vs 700 m prescrit).
2. Risque technique W3-W4 respiration (drills side kick réduits → entrée bilatérale moins préparée).
3. Progression_logic « delta 10-25% » cassée au transition W4→W5.