# Quality Review — football-regular-club-12sem

**Verdict** : APPROVED WITH CHANGES
**Sport** : football  **Level** : regular  **Schema version** : 2

## 1. Doctrine alignment

Template aligné sur les standards publics football amateur club D1-D2 département (FFF BMF, FA Step 5-7, UEFA Grassroots → C), périodisation Verheijen 4 jours, FIFA 11+ + NHE + CAE en piliers prévention :

- **FIFA 11+ obligatoire 2× / sem dès W1** : vérifié — chaque MD-3 (jour 2) et MD-2 (jour 3) embarque "FIFA 11+ complet — échauffement WX" 15 min en exercice 1 (lignes 39, 160, 545, 666, 1050, 1172, …, 5460, 6033, 6155). MD-1 (vendredi) embarque "FIFA 11+ raccourci — parties 1 + 3" 10 min (lignes 303, 786, 1316, 6275). Conforme F-MARC : avant match parties 1 et 3 seulement, pas de force au sol. Couverture exhaustive sur 12 semaines incluant cutbacks W4/W8/W12.
- **Périodisation Verheijen MD-3 / MD-2 / MD-1** : vérifié — pattern stable dès W1, explicité W5+ avec "Micro-cycle Verheijen complet" en `theme` (W5 ligne 2076, W9 ligne 4302). MD-3 force-tactique terrain, MD-2 résistance-RSA terrain, MD-1 activation tactique-stratégie. Cohérent doctrine fragment lignes 134-141. Mardi/Mercredi/Vendredi/Samedi match weekend = pattern référent doctrine.
- **NHE installé W3 (1×5) → progression W6+ (3×8-10)** : vérifié — W3 "Nordic Hamstring Exercise (NHE) — W3 intro" 1 set × 5 reps (ligne 1434), W4 cutback maintien 1 set × 6-8 reps (ligne 1961), W5 2 sets × 6-8 reps (ligne 2472), W6 3 sets × 8-10 reps stabilisé (ligne 3045), W7-W11 maintien 3 sets × 8-10 reps. Conforme doctrine fragment lignes 192-194 (méta-analyse Petersen et al. -51% HSI).
- **CAE installé W3 (1×5/jambe) → progression W6+ (3×10-15/jambe)** : vérifié — W3 1 set × 5 reps par jambe (ligne 1456), W6 3 sets × 10-15 reps stabilisé (ligne 3067), W12 test autonomie 3 sets × 12-15 reps par jambe (ligne 6416). Conforme méta-analyse Thorborg -33% pubalgie (doctrine ligne 195).
- **RSA hebdomadaire dès W3** : vérifié — W3 "RSA Repeated Sprint Ability" 6 × 30 m × 1 série (ligne 1219), W6+ progression 2-3 séries × 6-8 sprints, W11 pic 3 séries × 10 sprints (ligne 5449), W12 test autonomie 6 × 30 m chronométré rep 1 vs rep 6 (ligne 6202). Cible doctrine "perte vitesse < 5%" explicitée — Buchheit RSA conforme.
- **Jeu réduit progressif** : 5v5 espace large W1 calme Z3 (ligne 109), 4v4 espace réduit W2-W3 (ligne 252, 1265), petits jeux 4v4 RPE 8 W6+ (sourcé doctrine fragment ligne 87 "30×20 m, 4 × 3 min ON / 2 min OFF").
- **Micro-cycle 4 actives + 3 rest** : vérifié sur les 12 semaines (cf. section 3) — exactement 4 séances `duration_minutes > 0` et 3 sessions `type: "rest"` (jour repos + match + MD+1) chaque semaine.
- **Match weekend + amicaux** : `day: 6` "Match weekend (championnat district)" inclus comme `type: rest` chaque semaine (lignes 513, 1014, …, 6488). W12 explicitement renommé "Match weekend (championnat district) — bilan tenue match (critère 4)" (ligne 6489) — match comptabilisé hors volume entraînement (conforme doctrine ligne 97 "Hors matchs de championnat").
- **Volume pic 7h terrain + 75 min S&C W11** : ANNONCÉ mais NON LIVRÉ. W11 actual = 270 min terrain (4.5h) + 75 min S&C. La goal W11 ligne 5449 "Volume cible : ~7 h terrain + 75 min S&C" est incohérente avec les `duration_minutes` réels. Cf. Issue Important #1.
- **Doctrine fragment volume cible `regular` 5-8 h terrain** : NON ATTEINT. Pic réel terrain W11 = 4.5h, sous la fourchette 5-8h doctrine ligne 103. Cf. Issue Important #1.

## 2. Metadata hooks (Schema v2)

**Coverage : 258/258 exercices = 100%** sur les 5 hooks (`target_zone`, `required_equipment`, `incompatible_constraints`, `alternatives`, `volume_axis`). Aucun hook manquant. Aucun `alternatives: []` vide (interdit par doctrine ligne 353).

**Per-template hooks** :
- `week_structure` (lignes 12-16) : type=`block`, micro_pattern Verheijen 4 jours explicite, recovery_cadence "1 deload toutes les 4 semaines (-15 à -20% volume terrain et S&C)". Conforme doctrine ligne 370.
- `deload_weeks` (lignes 17-21) : `[4, 8, 12]`. Conforme doctrine ligne 376.
- `progression_logic` (ligne 22) : 5 principes sourcés (Verheijen 2014, FFF BMF, FA Step 5-7, UEFA Grassroots → C, Bompa, méta-analyses NHE/CAE). Cite W1-W12, exercices effectivement présents.

**Distribution `target_zone`** :
| target_zone | count | doctrine alignment |
|---|---|---|
| RPE 7-8 | 50 | S&C off-pitch (Bulgarian split, hip thrust, NHE, CAE, plyo) |
| technique | 39 | passes, conduite, frappe placée, finition légère |
| Z2 | 37 | FIFA 11+ échauffement, footing base aérobie |
| cool-down | 36 | étirements + marche fin séance (1 par session active) |
| tactique | 34 | sortie de balle 4v2, drills coups de pied arrêtés, schémas 11v11 |
| Z3 | 23 | jeu réduit espace large, conduite slalom, toro 5v2 |
| RPE 6-7 | 12 | Pallof press core anti-rotation |
| RPE 7-8 intermittent | 11 | 30s/30s Buchheit capacity |
| Z4 | 8 | jeu réduit 4v4 espace réduit haute intensité |
| RPE 8-9 sprint | 8 | RSA 30 m départ arrêté ALL OUT |

Toutes les zones sont sport-spécifiques football. Pas de `Daniels-T` ni `FTP` parasite (doctrine ligne 67 "Pas de zone d'effort soutenue type Daniels-T ou FTP"). Conforme.

**`incompatible_constraints` kebab-case + sport-spécifiques** : `acl-history`, `ankle-injury`, `knee-injury`, `hamstring-injury`, `groin-injury`, `lower-back-pain`, `concussion-history`, `cardiac-clearance-required`. Aligné doctrine fragment lignes 337-345. `concussion-history` correctement positionné sur "Coups de pied arrêtés" (ligne 1352, jeu de tête potentiel) et drills jeu de tête.

**`required_equipment` vocabulaire** : `cleats`, `ball`, `field`, `cones`, `mini-goals`, `training-bibs`, `mannequins`, `partner`, `team`, `agility-ladder`, `mat`, `bench`, `resistance-band`. Coverage doctrine fragment lignes 318-331 quasi-complète. **Note** : `bench` n'est pas listé dans le vocabulaire doctrine (utilisé pour split squat bulgare et hip thrust). Acceptable de fait, mais à ajouter au glossaire central. Cf. Minor #1.

## 3. Internal consistency

| Check | Statut |
|---|---|
| `duration_weeks == weeks.count` (12 == 12) | PASS |
| `sessions_per_week == 4` actifs + 3 rest = 7 entrées chaque semaine | PASS (vérifié W1-W12 via `duration_minutes`) |
| Days uniques [1,7] dans chaque semaine | PASS (1=repos, 2=MD-3, 3=MD-2, 4=S&C, 5=MD-1, 6=match, 7=MD+1) |
| Volume pic W11 annoncé 7h terrain | **FAIL** — réel 270 min terrain = 4.5h (cf. ligne 5449 vs lignes 5455+5577+5721) |
| Volume pic W11 S&C 75 min annoncé | PASS (ligne 5839 = 75 min) |
| Volumes cutback dans la fenêtre -15 à -20% | **FAIL** : W4 -22%, W8 -26%, W12 -28% (cf. section 4) |
| `progression_logic` cite NHE W3, CAE W3, RSA W3, Verheijen W5+ | PASS |
| `safety_notes` cite FIFA 11+ + NHE + CAE + crampons FG/SG/TF/IC | PASS |
| Equipment ⊆ assumed_profile (mat, bande élastique, dumbbells optionnels, ballon, crampons) | PASS |
| Autonomy checklist W12 = 5 critères chiffrés/observables | PASS (ligne 6022) |

**Volumes effectifs** : W1=260, W2=280, W3=295, W4=230 (-22%), W5=310, W6=325, W7=340, W8=250 (-26%), W9=330, W10=325, W11=345 (pic), W12=250 (-28%). Courbe progressive cohérente sauf magnitude des cutbacks.

## 4. Cutback / deload

PARTIAL PASS. Trois semaines de cutback livrées comme annoncé `deload_weeks: [4, 8, 12]`, mais les **magnitudes excèdent la doctrine -15 à -20%** :

- **W4** (295 → 230 min, **-22%**) : NHE/CAE 1 set × 6-8 reps maintien (ligne 1961), pas de RSA, jeu réduit allégé. Structure cutback conforme (volume terrain réduit + S&C activation), mais magnitude -22% au-dessus des -20% doctrine ligne 131.
- **W8** (340 → 250 min, **-26%**) : NHE/CAE 2 sets × 6-8 reps maintien (ligne 4167), pas de RSA volume, pas de match-simulation. Magnitude -26% nettement au-dessus de la fenêtre.
- **W12** (345 → 250 min, **-28%**) : cutback final + tests autonomie. Magnitude -28% justifiable car semaine de **bilan** (autonomy week ≠ deload pur), mais pas étiquetée comme telle dans la doctrine.

Cf. Issue Important #2.

## 5. Safety

Couverture risques sport+level **très complète et bien sourcée** dans `safety_notes` (ligne 23) :

- **RED FLAGS** : HSI (#1 football, 15-25%), pubalgie/adducteurs (#2), entorse cheville, LCA/LCP (cite -50% ACL féminin FIFA 11+), tendinite rotulienne, commotion cérébrale (cite protocole HIA + IFAB), tendinite Achille, lombalgie. Drapeaux spécifiques football amateur compétitif.
- **PRÉVENTION FIFA 11+** : routine F-MARC complète détaillée (3 parties), avant-match parties 1+3, claim chiffré -30 à -70% blessures globales + -50% ACL féminin. Aligné doctrine fragment lignes 21, 169-191.
- **PRÉVENTION NHE** : progression chiffrée W3 1×5 → W7+ 3×8-10, fréquence pré-saison 2-3× / sem → in-season 1× / sem, exécution détaillée (3-5 sec excentrique), claim -51% (Petersen et al.). Conforme doctrine ligne 194.
- **PRÉVENTION CAE** : progression chiffrée W3 1×5/jambe → W6+ 3×10-15/jambe, exécution détaillée, claim -33% (Thorborg). Conforme doctrine ligne 195.
- **MATÉRIEL** : crampons FG/SG/TF/IC adaptés au terrain (mention "JAMAIS de running shoe sur gazon"), protège-tibias en match (obligation FIFA / FFF / IFAB). Conforme doctrine fragment lignes 232, 391.
- **OVERTRAINING** : 5 signes (FC repos +10 bpm, sommeil dégradé, douleur ischio/adducteurs/cheville > 2 séances, motivation, baisse perf en match), seuil 3+ signes → cutback -15 à -20%. Protocole actionnable, conforme doctrine fragment lignes 248-249.
- **MISSED SESSION** : 4 niveaux gradués (< 1 sem, 1-2 sem, > 2 sem, terrain indispo), explicite "précipitation après coupure = première cause de récidive HSI / pubalgie".
- **CARDIAC / GROSSESSE** : trigger medical clearance pour > 35 ans sans test effort + RSA, antécédents cardiaques, postpartum < 6 mois.

Pas de copy-paste générique. Tout est football-spécifique club amateur regular.

## 6. EU MDR

**Banned medical claim words scan** (script Python sur le JSON brut) : 0 occurrence de "guérir", "soigner [pathologie]", "traiter", "traitement [pathologie]", "rééducation", "thérapie", "thérapeutique", "remède", "cure", "prescription", "ordonnance", "soulager", "réparer le ligament/muscle/tendon", "diagnostic". Conforme doctrine fragment lignes 285-291.

**Medical clearance trigger** : présent et explicite dans `safety_notes` (4 occurrences "consulte un médecin avant de commencer ce programme") sur :
- HSI passé < 8 sem → "consulter un kiné avant de reprendre les RSA" (ligne 23 paragraphe HSI).
- Reprise post-entorse < 3 mois → "consulte un médecin".
- Reprise post-LCA < 12 mois → "consulte un médecin + protocole spécifique kiné".
- Antécédents cardiaques / > 35 ans + RSA / grossesse / postpartum < 6 mois → "consulte un médecin".
- Antécédent commotion < 6 mois → "consulte un médecin", pas de jeu de tête.

Wording conforme MDR : pas de claim thérapeutique, redirige vers professionnel de santé. "Professionnel de santé" 1 occurrence en paragraphe RED FLAGS (sécurisé, non prescriptif).

PASS EU MDR.

## 7. Final autonomy checklist

PASS. W12 (ligne 6022) livre 5 critères mesurables/observables :

1. **RSA test** : 6 × 30 m départ arrêté avec récup 25 sec, perte vitesse < 5% entre rep 1 et rep 6 (capacité RSA football). Test instrumenté en MD-2 W12 J3 sous le nom "RSA TEST AUTONOMIE" (ligne 6202), avec exemple chiffré "rep 1 = 4.50 sec, rep 6 doit être < 4.73 sec".
2. **NHE test** : 3 sets × 8-10 reps avec contrôle excentrique sans douleur ischio. Test instrumenté en S&C W12 J4 sous le nom "NHE TEST AUTONOMIE" (ligne 6395). Pilier prévention HSI -51% acquis.
3. **CAE test** : 3 sets × 12-15 reps par jambe sans inconfort adducteurs. Test instrumenté W12 J4 sous le nom "CAE TEST AUTONOMIE" (ligne 6416). Pilier prévention pubalgie -33% acquis.
4. **Match-simulation tenu** : 11v11 30-40 min avec écart < 10% qualité technique entre 1ère et dernière minute. Mesure observable in-match jour 6 (ligne 6489 "bilan tenue match (critère 4)").
5. **S&C maintenu** : force unilatérale + agilité en progression, sans inconfort. Mesure auto-observée semaine glissante.

5 critères chiffrés (durées, reps, %, sec), observables (douleur ischio/adducteurs, qualité technique en match), spécifiques aux objectifs annoncés (RSA + prévention HSI/pubalgie + match-simulation + S&C). Conforme spec doctrine "≥5 critères".

## 8. Style

Français + tutoiement constant ("tu valides si tu tiens", "ton NHE hebdo tient", "tu tiens 6 × RSA", "consulte un médecin"). Aucun emoji détecté. Notes pédagogiques claires avec RPE / FCmax / cible chiffrée par exercice. Vocabulaire football authentique (MD-3, MD-2, MD-1, RSA, FIFA 11+, NHE, CAE, jeu réduit, sortie de balle, transition off→déf, coups de pied arrêtés, FG/SG/TF/IC). Excellent.

## Issues summary

### Critical (block merge)
- Aucun.

### Important (fix recommended)
1. **Volume pic W11 annoncé "~7h terrain + 75 min S&C" non livré — réel 4.5h terrain** : la `goal` W11 ligne 5449 indique "Volume cible : ~7 h terrain + 75 min S&C", mais les sessions effectives donnent 105+95+70 = 270 min terrain (4.5h) + 75 S&C. Idem `summary` ligne 11 "Volume pic ~5.5-7 h terrain + 1-1.25 h S&C / sem" → réel pic 4.5h en dessous de la fourchette annoncée. Ce gap touche aussi la conformité doctrine fragment ligne 103 (`regular` 5-8h terrain). Deux options :
   - **Option A (préférée)** : ajouter 60-90 min de volume terrain réparti W6-W11 (par ex. allonger MD-3 de 105 → 120 min sur W7-W11, allonger MD-2 de 95 → 110 min, soit pic théorique 5.5h terrain + 75 S&C). Régen ciblée week 7-11.
   - **Option B** : aligner les `summary` + `goal` W7/W9/W10/W11 sur les volumes réels (~4.4-4.5h terrain pic). Patch texte uniquement, pas de regen — mais accepter que le template tombe en bas de la fourchette doctrine `regular` (5-8h).
2. **Magnitudes cutback W4/W8/W12 hors fenêtre doctrine -15/-20%** : W4 -22%, W8 -26%, W12 -28%. La doctrine fragment ligne 131 demande "-15 à -20%" pour `regular`. W12 est étiquetée "cutback final + checklist d'autonomie", justifiable comme "test week" plutôt que pure deload, donc -28% acceptable. Mais W4 et W8 sont des deloads classiques et leurs -22% / -26% sont au-dessus de la fenêtre. Patch suggéré : remonter MD-3 W4 65 → 70 min, MD-2 W4 70 → 75 min (cutback ramené à -18%), idem W8. Édition ciblée `duration_minutes` + ajustement micro contenu drills.

### Minor (nice-to-have)
1. **Vocabulaire equipment `bench` non listé doctrine** : ligne 329 doctrine fragment cite `mat`, `resistance-band`, `medicine-ball`, `dumbbells`, `foam-roller`. Le template utilise `bench` (split squat bulgare, hip thrust). À ajouter au glossaire central équipment kebab-case ou substituer par `step` / `box`.
2. **`assumed_profile` ligne 10 mentionne "dumbbells optionnels" mais aucun exercice ne liste `dumbbells` comme `required_equipment`** — incohérence cosmétique : si optionnel, retirer de l'assumed_profile, ou ajouter en alternative à split squat bulgare.
3. **W11 goal ligne 5449 dit "RSA 3 séries × 10 sprints"** — vérifié au W11 MD-2 mais doctrine fragment ligne 219 plafonne à "6-10 × 30 m × 2-3 séries". 10 sprints × 3 séries = 30 sprints, en haut de la fourchette acceptable mais à surveiller pour éviter HSI fin de programme. Acceptable car pic pré-cutback final.
4. **Distribution 4 piliers `progression_logic` ligne 22 annonce "Technique 20-30% / Tactique 30-40% / Physique 25-30% / Mental 10-15%"** — non recompté dans la review (pas de mesure automatique aisée), mais cohérent avec doctrine ligne 153-156 pour `regular`. À vérifier en audit prod si décalage signalé.

## Sources

- [FIFA — Injury prevention and health promotion (FIFA 11+)](https://inside.fifa.com/health-and-medical/injury-prevention)
- [FIFA 11+: an effective programme to prevent football injuries — narrative review (PMC)](https://pmc.ncbi.nlm.nih.gov/articles/PMC4413741/)
- [The FIFA 11+ injury prevention program for soccer players: a systematic review (BMC)](https://link.springer.com/article/10.1186/s13102-017-0083-z)
- [Impact of FIFA 11+ on Injury Prevention (PMC systematic review)](https://pmc.ncbi.nlm.nih.gov/articles/PMC4245655/)
- [The Original Guide to Football Periodisation Part 1 — Verheijen (Amazon)](https://www.amazon.com/Original-Guide-Football-Periodisation-Part/dp/949174500X)
- [Periodization Training for Sports — Bompa & Buzzichelli (Human Kinetics)](https://us.humankinetics.com/products/periodization-of-strength-training-for-sports-4th-edition)
- [UEFA Coaching Licences — UEFA.com](https://www.uefa.com/development/coaches/uefa-coaching-licences/)
- [FFF Brevet d'Entraîneur de Football (BEF)](https://www.fff.fr/articles/details-articles/143913-552411-brevet-dentraineur-de-football)
- [Effect of NHE Programs on Hamstring Injury Rates in Soccer — meta-analysis (PubMed)](https://pubmed.ncbi.nlm.nih.gov/27752982/)
- [Combining CAE and NHE Improves Dynamic Balance — RCT (PMC)](https://pmc.ncbi.nlm.nih.gov/articles/PMC8558994/)
- [Copenhagen Adduction Exercise meta-analysis on Sport Performance and Injury Prevention (PMC)](https://pmc.ncbi.nlm.nih.gov/articles/PMC12363431/)
- [ACL Injuries in Soccer Players: Prevention and Return to Play (PMC)](https://pmc.ncbi.nlm.nih.gov/articles/PMC10743334/)
- [Training intensity distribution in elite football, polarised or not? (TopSportsLab)](https://www.topsportslab.com/training-intensity-distribution-in-elite-football/)
- [Training Zones for Football Fitness (Professional Soccer Coaching)](https://www.professionalsoccercoaching.com/aerobic-fitness-science/training-zones-for-football-fitness)
- [Pre-season planning in football — complete guide (Zone14)](https://zone14.ai/en/blog/pre-season-planning-in-football/)

## Recommendation

**APPROVED WITH CHANGES** — bundle après correction Important #1 et #2.

Le template est doctrinalement solide (FIFA 11+ obligatoire 2× / sem dès W1, NHE/CAE installés W3 et progressés W6+, RSA hebdo W3+, micro-cycle Verheijen 4 jours, autonomy checklist 5 critères chiffrés et instrumentés W12), conforme schema v2 (258/258 hooks, aucun `alternatives` vide), conforme EU MDR (0 mot banni, 4 medical clearance triggers explicites), structure 4 actives + 3 rest stable sur 12 sem, sources publiques solides.

Les deux issues "Important" sont des incohérences chiffrées **internes au template** :
- **#1 (volume pic W11)** : gap entre annonce "~7h terrain" et réel 4.5h. Préférer Option A (regen ciblée W7-W11 pour atteindre 5.5-6h terrain pic) afin d'aligner sur le bas de la fourchette doctrine `regular` 5-8h.
- **#2 (magnitudes cutback)** : -22% / -26% / -28% au-dessus du couloir doctrine -15/-20%. Patch ciblé `duration_minutes` W4 et W8 pour ramener à -18% suffit. W12 garde son -28% au titre de "test/bilan week".

Aucune issue n'invalide la qualité du programme ni la sécurité utilisateur. Le pilier prévention (FIFA 11+ + NHE + CAE) est exemplairement instrumenté.

## Patches applied (2026-05-01)

### Important #1 — Volume pic W11 aligne avec doctrine 5-8 h terrain (Option A : regen ciblee duree W5-W11)

Augmentation des `duration_minutes` W5-W11 pour atteindre fenetre doctrine `regular` 5-8 h terrain au pic W11 :

| Semaine | Avant total / terrain | Apres total / terrain | Variation |
|---|---|---|---|
| W5 | 310 / 245 | 315 / 250 | +1.6% |
| W6 | 325 / 255 | 340 / 270 | +4.6% |
| W7 | 340 / 265 | 355 / 280 | +4.4% |
| W9 | 330 / 260 | 355 / 280 | +7.6% |
| W10 | 325 / 255 | 370 / 295 | +13.8% |
| W11 (PIC) | 345 / 270 | **400 / 320 (5.33 h)** | +15.9% |

Pic W11 terrain = 320 min = 5.33 h, dans la fenetre doctrine `regular` 5-8 h. S&C pic = 80 min.

Goals W7, W9, W10, W11 mis a jour avec volumes reels. Summary l. 11 : "Volume pic ~5-5.5 h terrain + 75-80 min S&C / sem (W11)".

### Important #2 — Magnitudes cutback W4/W8 ramenees dans la fenetre -15-20%

- **W4** : 230 min -> 245 min (+15 min en augmentant MD-3 65->70, MD-2 70->75, S&C 40->45). Cutback -16.9% vs W3 = 295 min. Goal reformule "(-17% volume)".
- **W8** : 250 min -> 285 min (cutback recalibre par rapport au nouveau W7=355). Sessions ajustees a 85/85/65/50. Cutback -19.7% vs W7. Goal reformule "(-20%)".
- **W12** : conserve a 250 min (-37.5% vs W11 = 400 min) etiquette explicitement "test-week / bilan d'autonomie" dans `progression_logic` (4) : volume marque pour fraicheur maximale lors des tests RSA / NHE / CAE / match-simulation chronometres ; ce n'est pas un deload pur.

### Minor patches

- **`assumed_profile`** : "dumbbells optionnels" remplace par "banc step ou box bas" (coherent avec exo split squat bulgare et hip thrust qui utilisent `bench`).
- **W11 RSA goal** : "3 series x 10 sprints" -> "3 series x 8-10 sprints" (formulation flexible dans la fourchette doctrine 6-10 x 30 m x 2-3 series).
- **`bench` glossaire equipment** : maintenu tel quel (utile fonctionnellement, alternative `step` / `box` mentionnee assumed_profile). A remonter au glossaire central equipment kebab-case si normalisation.

### Volume curve apres patches

W1=260 -> W2=280 (+8%) -> W3=295 (+5%) -> W4=245 (-17%, cutback)
-> W5=315 (+29%, sortie cutback) -> W6=340 (+8%) -> W7=355 (+4%) -> W8=285 (-20%, cutback)
-> W9=355 (+25%, sortie cutback) -> W10=370 (+4%) -> W11=400 (+8%, **PIC**) -> W12=250 (-37.5%, test-week)

Toutes les hausses hors sortie de cutback sont dans la regle ACSM 10-20%.

**Validation post-patch** : JSON parse OK, weeks.count=12=duration_weeks, hooks v2 100% couverts, EU MDR banned words = 0, courbe de volume coherente (progression + cutbacks + pic + test-week).

**Verdict final : APPROVED — bundle.**
