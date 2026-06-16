# Rapport qualité — 10 sports (passe Sally + user + arbitrage)

**Date** : 2026-06-08 (nuit) · **Méthode** : workflow 40 agents (digest contenu réel → Sally UX + Maxime novice en parallèle → arbitrage).

**Totaux** : 65 bugs nets · 57 décisions produit.


## ⚠️ Lecture critique (à lire avant de corriger)

- **47/65 bugs nets = éditions de contenu template JSON** ; **13 = i18n template (FR-only)**. Or ces fichiers `Templates/.../*.json` ont **déjà été retraduits FR/EN/ES sur la branche `i18n-b2-templates` (pushée, NON mergée)**. Les corriger sur `chantier/dosage-cameleon-muscu` créerait des **conflits de merge massifs**.
- **Recommandation de séquencement** : (1) **merger `i18n-b2-templates`** d'abord ; (2) faire UNE passe de nettoyage contenu sur cette base (absorbe la grande majorité des 65) ; (3) les 57 décisions produit (politique d'affichage zones, nommage FR/EN, vulgarisation) → **étape HTML décisions** (`decisions-qualite-sports-2026-06-08.html`).
- **Je n'ai édité AUCUN template cette nuit** (conflits + arbitrages produit interdits en autonomie).

## 🚨 P0 à regarder en priorité

- **[Running]** Contrairement aux autres zones, « walking-recovery » n'est PAS résolu par Glossary.entry(forZone:) (vérifié : aucune règle de match, retombe sur return nil ligne 230) : il s'affiche donc en chaîne mac
- **[Swimming]** Vérifié littéralement. Titre 100% code/jargon (« LACTIQUE » physio + SP1/SP3 non décodés), unique outlier : les séances soeurs du même template font déjà l'effort français (« Allure de course SP1 — 8 
- **[Musculation]** Le sport muscu n'a jamais reçu le nettoyage RPE→« effort N sur 10 » déjà appliqué aux autres sports de l'app. Une grille RPE/RIR entière est collée en intro de note d'exercice, et les sigles RPE/RIR a
- **[Musculation]** Mot « douleur » et vocabulaire médical (lombalgie, sciatique, douleur irradiante, avis médical immédiat) très présents dans des champs vus par l'utilisateur. Risque EU MDR / mots bannis déjà identifié
- **[Hiit]** « Format first-class » est une mistranslation systématique de « format de base/principal/socle ». L'expression ne veut rien dire en FR (ni en EN dans ce contexte) et apparaît dans ~18+ notes sur les 4
- **[Hiit]** Faute de conjugaison « tu pose » → « tu poses » en plein milieu d'une consigne user-facing. Très visible, nuit à la crédibilité, surtout en séance débutant.
- **[Hiit]** Typo « doce » → « douce » dans le résumé de programme (champ très visible, premier contact). Confirmé Sally+Maxime, vérifié dans le fichier.
- **[Hiit]** Ces 6 champs sont des dicts FR-only (vérifié : keys=['fr']) alors que tous les exercises (name/notes/alternatives) ET les warmups/cooldowns sont trilingues fr/en/es. En app EN/ES, le titre du programm
- **[Hiking]** « HIT » au lieu de « HIIT » dans un texte résumé user-facing. Vérifié dans les templates : 3 occurrences de « HIT », zéro « HIIT ». Bug récurrent déjà repéré sur d'autres sports (cf audit didactique 1
- **[Hiking]** Deux bugs cumulés. (1) Doublon « endurance endurance » : confirmé 9 occurrences dans le template, et UNIQUEMENT en FR (la version ES « Caminata suave (zona 2) » est propre) → c'est bien la composition
- **[Hiking]** Le dénivelé « 200 m » est répété deux fois dans le même titre (une fois en clair avec le sigle D+, une fois dans le segment de dosage). Redondance générée par la concaténation libellé manuel + fragmen
- **[Hiking]** Tags techniques anglais bruts collés dans une note FR user-facing. Confirmé au grep : « sustained climbing », « gradient-moderate », « pack-day » présents en masse sur tous les templates hiking. « gra
- **[Tennis]** Anglais brut non traduit injecté en plein milieu d'un texte FR user-facing (forehand, backhand, cross, feeling balle) alors que le corpus beginner traduit correctement les mêmes notions (coup droit/re
- **[Football]** Tout le bloc de tête du niveau competitive a perdu ses accents (« Preparer », « Saison regionale », « pre-saison », « structuree », « alignes », « PREPARATION », « medical »...), alors que le CORPS du
- **[Football]** Jargon de conception interne (« Charge cognitive 3-4 », « cognitive load 3-4 ») exposé dans les notes lues par l'utilisateur. Confirmé présent ~10 fois dans le beginner, en FR et EN. Aucun sens pour u
- **[Football]** Codes de planification encodés dans des titres/noms affichés : « W2 » (semaine 2), « MD-1/MD-3 » (match day minus), « J-3 », « tapering match week », et « — semaine N (allégée) » collé dans les noms d
- **[Running]** Le champ d'allure le plus consulté pendant la séance affiche le CODE COACH brut comme libellé principal (« Daniels-E », « @HMP », « RPE 6-7 »). VÉRIF ARBITRE : ce n'est PAS un texte mort — il existe u
- **[Running]** Frontière EU MDR : nommage de pathologies + protocoles de soin + orientation médicale dans du contenu user-facing. VÉRIF ARBITRE : ces termes ne sont PAS dans le système glossaire (donc pas encadrés),
- **[Swimming]** Vérifié dans les 4 templates shipés : le champ target_zone surface des codes techniques non décodés (beginner = EN1 + REC ; regular/competitive ajoutent CSS, EN3, SP1-3). Un nageur ne peut pas savoir 
- **[Triathlon]** Mélange de 3 systèmes de zones (Friel/cyclisme FTP-Z, Daniels/course E-M-T-I-R, CSS/natation) affichés en codes bruts. Sans glossaire ni vulgarisation, c'est opaque pour un utilisateur non-coach, y co

## Synthèse par sport

### Running (11 findings)
Qualité running = correcte sur le fond technique (zones Daniels justes, structure cohérente) mais 3 P0 sérieux côté UX/contenu user-facing. (1) Le dosage affiche les codes coach bruts (« Daniels-E », « @HMP », « RPE 6-7 ») — atténué par un vrai glossaire tappable localisé déjà en place (donc product_decision sur la politique de libellé, pas bug mort), SAUF « walking-recovery » qui est un vrai clear_bug (string machine anglaise non résolue par le matcher, fuit verbatim alors qu'une entrée glossaire 'recovery' existe non branchée). (2) Frontière EU MDR franchie : pathologies nommées (ITBS, shin splints, tendinopathie, RED-S, fracture de stress) + protocoles de soin (Alfredson, glace, kiné, appel au 15) hors glossaire → arbitrage produit + juridique. (3) i18n incomplet : tous les headers des 4 templates sont FR-only (blob à clé 'fr' unique) + duration FR libre → en EN/ES l'écran est bilingue cassé ; clear_bug car la cible {fr,en,es} est déjà actée. Côté nommage exercices (Bird-dog, Bulgarian split squat, miles, hard/easy) = product_decision (politique FR/EN à fixer). 2 faux positifs corrigés : « HIT » n'est PAS « HIIT » mal écrit (triade polarisée LIT/MP/HIT intentionnelle, mais reste à glosser), et match_key ne fuit nulle part en UI (garde-fou préventif seulement). Bilan : aucun bug fonctionnel bloquant, mais le contenu user-facing running n'est pas livrable en l'état pour un public débutant (P0 EU MDR + P0 i18n + P0 lisibilité dosage à arbitrer).

### Cycling (16 findings)
Qualite cycling : contenu sportif solide et conforme a la doctrine (modele Coggan 7 zones FTP intentionnel, beginner 100% Z1-Z2 avec equivalents RPE/%FCmax fournis), mais finition i18n et coherence de modele insuffisantes. Verifie en code+JSON : 18 findings personas reconcilies en 17 confirmes (1 quasi-resolu par la doctrine). Aucun P0 retenu : le 'P0 target_zone brut' des deux personas est descendu en P1 car la verif code montre que FTP/Sweet-Spot sont glossarises + tappables (GlossaryTermBadge dans SessionFocusView l.321-328) et que RPE est deja mappe en clair (DosageFormatting.plainEffort) ; le code brut reste neanmoins le libelle primaire, ce qui releve d'un arbitrage produit (referentiel dosage cameleon). clear_bugs nets a traiter avant commit : 'flush lactate' + anglicismes FR (Hot foot/Saddle sores/chamois pressure/shoulder strain), meta-champs FR-only sur LES 4 niveaux (et non 2 comme dit les personas), champ duration composite (rpm/km/zone empiles), convention jour 'J7' vs 'JOUR J', hip thrust vs pont fessier (3 noms = 1 concept, mistag deja connu), orthographe Sweet-Spot non figee, 'PR personnel' redondant. product_decisions transverses pour Sophie : politique nommage FR/EN exos renfort, garder/releguer 'Sweet-Spot', niveau de vulgarisation du jargon (myelinisation/gut training/ERG/derive cardiaque), exposition FTP en primaire pour beginner, terme EN canonique pour 'sprints d'activation'. A grouper dans le chantier dosage cameleon. Le modele Coggan 7 zones est valide par la doctrine = juste a verrouiller.

### Swimming (13 findings)
Qualité natation = la plus faible des sports audités côté lisibilité utilisateur : sport à plus forte densité de jargon (codes de zone CSS/EN1-3/SP1-3/REC affichés bruts, anglais de plan de nage omniprésent). 2 P0 confirmés : codes d'intensité illisibles affichés bruts (product_decision car exige une politique d'affichage), et 1 titre 100% jargon « BLOC LACTIQUE SP1 + sprint SP3 » (clear_bug, un meilleur pattern de titre existe déjà dans le même fichier). 7 P1 : i18n racine FR-only sur les 4 templates (bug net vérifié dans le JSON), champ duration contenant des distances + double-protocole « OU » (modélisation fausse — mais natation N'EST PAS routée timed via SessionFocusView, donc le « timer cassé » est surestimé par les reviewers), doublon « External rotation band » dont la valeur fr est elle-même en anglais, titres en MAJUSCULES incohérents + « checklist », warmup competitive saturé d'anglais + tag « (competitive) » qui fuit, redondance « test + introduction au seuil », « Comfortably hard » non traduit. 4 P2 (vulgarisation notes savantes, politique nommage FR/EN, périmètre glossaire, doublons blockName/exerciseName). Faux positif écarté : le « mismatch VO2max vs EN3 » — la doctrine du template définit elle-même EN3 comme « proche VO2max », le nom est donc cohérent ; ne reste que l'aspect jargon du terme, fondu dans la vulgarisation. Répartition : 6 clear_bug (i18n et duplicate sont les plus nets) et 7 product_decision (toutes les politiques FR/EN, glossaire et densité jargon, cohérentes avec le chantier dosage caméléon en cours). Fichiers : Templates/Sources/TemplateLoader/Resources/Templates/swimming-{beginner-initiation-6sem,regular-technique-8sem,recreational-endurance-8sem,competitive-perfectionnement-12sem}.json ; affichage zone/duration dans Views/Screens/Coaching/SessionFocusView.swift (chip duration ligne ~315, pas de routage timed natation).

### Triathlon (11 findings)
Triathlon est le corpus le plus chargé en jargon de tout l'app, et le plus risqué car le jargon touche le DOSAGE. Qualité moyenne avec un défaut systémique : superposition de 3 systèmes de zones (FTP/Daniels/CSS) affichés en codes bruts (P0, validé à l'unanimité des deux personas) — totalement opaque pour un débutant/intermédiaire et incohérent avec la décision \"charge=sensation sans jargon\" du chantier dosage caméléon en cours. À côté : forte densité d'anglicismes non systématisée (disciplines swim/bike/run trivialement traduisibles, S&C jamais explicité, jargon natation EVF/sculling/sighting, exos muscu EN), labels de niveau \"competitive/regular\" restés EN dans des titres sinon FR, un trou i18n sur le template beginner, et 2 artefacts objectifs (orthographe \"periodization\", annotation de brouillon \"[du seuil, sous-entendu]\"). 12 findings confirmés : 1 P0 + 5 P1 + 6 P2. Répartition 6 clear_bug (traductions directes, fautes, trous i18n, cohérence de convention déjà adoptée) / 6 product_decision (politique de zones, référentiel de nommage transverse aligné muscu, politique jargon natation+matériel, vocabulaire à enseigner T1/T2/70.3/danseuse, structure des titres). Aucun faux positif éliminé : les deux personas sont alignés, le novice n'a fait que confirmer et durcir la sévérité sur les zones et les abréviations. Recommandation : étape HTML décisions pour la politique de zones (P0) + le référentiel de nommage transverse (P1) AVANT de toucher au contenu, sinon risque de drift avec le chantier muscu.

### Musculation (8 findings)
Qualité muscu nettement en dessous du reste de l'app : c'est le seul sport qui n'a pas reçu le nettoyage RPE→« effort N sur 10 » ni la passe de trad FR des notes/warmups. 2 P0 bloquants (grille RPE/RIR + jargon collés en note d'exo ; vocabulaire médical EU MDR « douleur/lombalgie/sciatique »), 3 P1 (anglais brut massif dans notes & étirements, tag technique `recreational` qui fuit, contradiction de doctrine competitive kg/%1RM vs référentiel v2) et 3 P2. Les deux personas convergent fortement ; aucun faux positif éliminé. Verdict : BUGS — ne pas merger tant que les 2 P0 ne sont pas corrigés (le P0 EU MDR doit repasser par le garde-fou existant). 6 clear_bug à corriger directement, 3 product_decision à porter en HTML décisions (politique nommage FR/EN, exception charge competitive, vulgarisation titres de méthode).

### Yoga (10 findings)
Qualité yoga : solide sur le FOND (contenu sourcé Iyengar/Pattabhi Jois, exercices déjà trilingues FR/EN/ES avec gloss sanskrit entre parenthèses sur les NOMS — pattern validé par les deux personas), mais entachée de fuites de langue/jargon en SURFACE. 3 bugs objectifs nets : (1) 'RPE 6-7' dans target_zone du regular (seule occurrence du set, vs doctrine dosage caméléon), (2) anglais non traduit incohérent (Cat-Cow vs chat-vache, Down Dog vs chien tête en bas, + 'Cutback' jargon surf parasite) alors que les équivalents FR existent dans les mêmes fichiers, (3) anglicismes 'hold/finishing/breath-led' dans duration. 4 décisions produit à arbitrer par Sophie : politique de glossaire sanskrit/technique du tier competitive, i18n top-level SYSTÉMIQUE (les 4 templates ont name/summary/safety_notes/progression_logic FR-only et 'objective' absent — pas juste le beginner), normalisation des unités de duration pour le FOCUS minuté, et nettoyage des titres de programme exposant les codes de tier 'regular'/'competitive' + 'inversions wall'. 10 findings confirmés (3 clear_bug, 7 product_decision), aucun P0, aucun faux positif majeur — j'ai requalifié l'i18n beginner en dette systémique et scindé les anglicismes de duration des unités hétérogènes.

### Hiit (13 findings)
Contenu HIIT riche et sérieux côté doctrine (4 templates débutant→competitive, périodisation/cutbacks/cibles HIIT cumulé crédibles, exercices + warmups correctement trilingues fr/en/es), MAIS plombé par 3 défauts objectifs très visibles et un gros chantier de vulgarisation. Clear bugs : « Format first-class » (mistranslation récurrente ~18+ occurrences sur les 4 templates pour dire « format principal »), faute « tu pose » → « tu poses » dans une consigne, typo « doce » → « douce » dans le summary débutant, calque « Dead bug (bug mort) » (3 occurrences), nom d'exo qui embarque une justif de programmation, et surtout les 6 champs top-level (name/summary/progression_logic/safety_notes/assumed_profile/default_objective) sont FR-only alors que tout le reste est trilingue → UI EN/ES affichera ces méta en français. À part ça, fort niveau de jargon HIIT/CrossFit non glossarié, benchmarks FRAN/Cindy bruts, safety_notes à la frontière EU MDR (pathologies nommées + protocoles RICE/prise de sang CK/rhabdomyolyse), citations scientifiques et recalculs HIIT cumulé verbeux dans les notes user-facing : autant de décisions produit pour Sophie. Faux positif écarté : le P0 de Maxime « noms et warmups en anglais » — vérifié, tous les noms d'exos ET warmups ont bien des blocs fr/en/es ; il a lu un dump brut, le resolver sert le FR. Seul l'i18n des champs top-level manque réellement.

### Hiking (17 findings)
Qualité médiocre / non shippable en l'état pour le sport hiking. Au moins 1 typo dure (HIT au lieu de HIIT, confirmée 3 occurrences) et plusieurs bugs de composition de titres (doublon « endurance endurance » FR-only, dénivelé répété, fragments collés dans le désordre avec minuscule en tête) qui trahissent un caméléon de format qui concatène libellé manuel + fragment généré sans dédup ni capitalisation. Surtout, fuite massive et systématique de jargon coach anglais (sustained climbing, gradient-moderate, pack-day, Uphill Athlete/House-Johnston, FKT, LIT, ME, polarized, S&C, core, Drills, Cooldown) dans titres, summary et notes user-facing — le contenu lu en premier (summary programme) est écrit pour un coach pro, pas pour un randonneur débutant. 5 bugs nets corrigeables sans Sophie, mais le gros du chantier (politique de vulgarisation FR/EN, gloses transverses S&C/core/zone 2, niveau de langue du summary) relève de décisions produit transverses à cadrer une fois pour tous les sports. Les deux personas convergent fortement ; Maxime (novice) a surclassé en P0 plusieurs items que Sally voyait P1 — j'ai tranché en gardant P0 sur ce qui casse la compréhension de base du débutant (HIT, jargon summary, anglais brut en pleine phrase).

### Tennis (12 findings)
Qualité tennis correcte sur le fond sportif mais entachée d'un défaut de finition de contenu transverse, surtout sur les niveaux avancés (recreational/regular/competitive) qui n'ont pas reçu le même soin de vulgarisation/traduction que le beginner. 1 P0 net : franglais non traduit (forehand/backhand/cross/feeling balle) alors que le beginner prouve qu'on sait traduire. Les clear_bugs restants sont objectifs et alignables sur le beginner : cooldown EN brut, nom propre Kovacs qui fuit, calque \"squat gobelet\", orthographe medecine-ball, et le risque EU MDR/ton anxiogène (épicondylite, \"non négociables\"). Le reste relève d'arbitrages produit déjà cadrés par des chantiers ouverts : politique de nommage/glossaire du jargon muscu-physio, harmonisation du dosage (RPE/Z2-Z3 vs effort 1-5), vulgarisation des titres (affûtage/tapering), parité i18n ES sur les templates avancés, gestion des champs reps verbeux, et découpage d'un exo composite à 3 mouvements. Aucun bug bloquant le fonctionnement ; chantier de fond de cohérence FR + EU MDR à mener avant ship.

### Football (11 findings)
Football: 4 templates (beginner 8sem, recreational 10sem, regular 12sem, competitive 16sem). Contenu sportif riche et bien sourcé (FIFA 11+, Bompa, Verheijen, NHE/CAE), mais qualité d'exposition utilisateur insuffisante. 12 findings confirmés (3 P0, 5 P1, 4 P2). 2 P0 bloquants nets : (1) bug d'encodage UTF-8 sur TOUT le bloc niveau-programme du fichier competitive (name/summary/objectif/progression_logic/safety_notes dé-accentés, corps du fichier sain) ; (2) jargon de conception « charge cognitive 3-4 » qui fuit dans les notes user (beginner, ~10x FR+EN). 3e P0 = codes de planif (W12, MD-1, J-3, « semaine N ») dans les titres affichés. Côté décisions produit : politique de nommage FR/EN des exos (jargon anglais inégal + acronymes nus RDL/NHE/CAE/RSA), vulgarisation des résumés (Bompa, R3-N3, tapering), mapping dosage caméléon (target_zone et reps hétérogènes, % FCmax/Z sans sensation), et un audit EU MDR sur les termes pathologiques + stats de réduction de blessure + impératifs « obligatoire/non négociable ». Correction de périmètre vs personas : le trou i18n program-level en/es concerne les 4 niveaux (pas seulement le beginner), alors que les exercices sont déjà trilingues — incohérence visible en EN/ES. À prioriser avant prod : les 3 P0, puis l'audit EU MDR (légal).


## Bugs nets (65) — détail


### Running
- [P0] **target_zone == « walking-recovery » (3 occurrences** — Contrairement aux autres zones, « walking-recovery » n'est PAS résolu par Glossary.entry(forZone:) (vérifié : aucune règle de match, retombe sur return nil lign
  - fix: Remplacer la valeur « walking-recovery » par une chaîne user-facing localisée « Récupération en marchant » (FR) / « Recovery walk » (EN) / « Recuperación camina
- [P1] **Headers FR-only sur les 4 running-*.json : name, s** — Régression i18n objective : les champs header sont des blobs MAIS ne contiennent que la clé 'fr', alors que le pattern produit acté est {fr,en,es} (LocalizedTex
  - fix: Compléter les blobs {fr,en,es} sur name/summary/default_objective/assumed_profile/progression_logic/safety_notes des 4 templates running (chantier i18n B2 conte
- [P1] **duration : chaîne FR libre non traduite (« 1 min c** — Le champ duration est une string FR libre (pas un blob), affichée telle quelle ; en locale EN/ES elle reste en français. Cohérent avec le finding header : aucun
  - fix: Fournir duration en blob {fr,en,es} (ou la structurer en données valeur+unité+type traduisibles). Minimum : garantir qu'aucune duration FR ne s'affiche en EN/ES
- [P1] **notes / progression_logic : acronymes « HIT » (uti** — VÉRIF ARBITRE — contredit partiellement Sally/Maxime : « HIT » n'est PAS « HIIT » mal orthographié. Le contexte montre une triade d'entraînement polarisé LIT/MP
  - fix: Ne PAS « corriger HIT→HIIT » (faux positif). À la place : expliciter la triade à sa 1re occurrence (« faible / modérée / haute intensité ») ou la glossariser. G
- [P2] **notes : expressions de coaching anglophones brutes** — Expressions anglaises laissées brutes dans des notes au contexte FR, non glossées et non traduites. Bruit anglais objectif (différent des termes techniques glos
  - fix: Traduire dans les notes : « negative split » → « finir plus vite qu'au départ », « cumulative fatigue » → « fatigue accumulée », « moderate-intensity rut » → « 
- [P1] **match_key : « Bloc run/walk 1 min / 1 min 30 », « ** — VÉRIF ARBITRE — quasi faux positif : match_key est un champ d'appariement INTERNE. Recherche Swift : aucune vue ne rend match_key à l'écran (seule occurrence Vi
  - fix: Aucune correction de contenu requise (champ interne). Action préventive : ajouter/vérifier un test ou une assertion garantissant que tout affichage exercice uti

### Cycling
- [P1] **cycling-recreational-endurance-10sem.json cooldown** — VERIFIE : anglicisme brut 'flush lactate' dans un texte FR utilisateur (et la version EN existe deja correctement). Traduction manquante, aucune decision produi
  - fix: Remplacer le segment FR par 'pour favoriser la recuperation' ou 'pour eliminer la fatigue des jambes'. Verifier coherence EN/ES.
- [P1] **safety_notes / alternatives FR des 4 templates cyc** — VERIFIE dans les 4 JSON : termes anglais bruts dans des champs FR. 'Hot foot', 'Saddle sores', 'chamois pressure', 'shoulder strain' n'ont pas de raison d'etre 
  - fix: Traduire : Hot foot->'pieds qui chauffent', Saddle sores->'irritations de selle', chamois pressure->'pression du fond de cuissard', shoulder strain->'tension au
- [P1] **Meta-champs racine (name, summary, default_objecti** — VERIFIE en parsant les JSON : ces 6 meta-champs sont des dicts a cle 'fr' uniquement sur LES QUATRE niveaux (beginner, recreational, regular, competitive), alor
  - fix: Completer les blocs EN/ES sur les 6 meta-champs des 4 templates, a l'identique du contenu des sessions.
- [P1] **Champ duration utilise comme consigne composite : ** — VERIFIE : duration porte tantot une duree, tantot une distance ('45 km / ~95 min'), tantot une alternance cadence+zone. Incoherence de modele qui fragilise tout
  - fix: Normaliser : duration=duree pure, distance=champ dedie, zone=target_zone, cadence/alternance->notes ou champ structure. Retirer Sweet-Spot du texte duration qua
- [P1] **competitive : exos renfort 'Hip thrust au sol', 'P** — VERIFIE : hip thrust (43 occ) ET pont fessier (23 occ) coexistent dans le meme template. Pour l'usager, pont fessier = hip thrust nommes differemment, on ne sai
  - fix: Une seule terminologie de base (pont fessier) declinee : 'Pont fessier (2 jambes)', 'Pont fessier (1 jambe)', 'Pont fessier leste'. Ne pas faire coexister hip t
- [P1] **Convention jour-de-course : 'CYCLOSPORTIVE J7' (co** — VERIFIE : 'CYCLOSPORTIVE J7' (3 occ) vs 'jour J/JOUR J' + J-2/J-1 ailleurs. 'J7' est ambigu (jour 7 ? J+7 ?) et diverge de la convention J-/JOUR J. Notation inc
  - fix: Uniformiser : JOUR J / J-1 / J-2 partout en FR, RACE DAY / D-1 / D-2 en EN. Bannir 'J7'.
- [P2] **Orthographe Sweet-Spot non figee : 'Sweet-Spot', '** — VERIFIE : 6+ variantes orthographiques du meme terme par template. Independamment de la decision de garder ou non le terme, l'orthographe doit etre figee (sinon
  - fix: Figer une seule graphie ('Sweet-Spot') partout dans les 4 JSON.
- [P2] **Objectif competitive : 'PR personnel'** — VERIFIE conceptuellement (Sally) : 'PR' = Personal Record, donc 'PR personnel' = 'record personnel personnel', redondant + melange sigle EN/mot FR.
  - fix: FR : 'record personnel'. EN : 'PR' ou 'personal best'.

### Swimming
- [P0] **Titre de séance (competitive) : « BLOC LACTIQUE SP** — Vérifié littéralement. Titre 100% code/jargon (« LACTIQUE » physio + SP1/SP3 non décodés), unique outlier : les séances soeurs du même template font déjà l'effo
  - fix: Réécrire sur le modèle des soeurs déjà présentes : « Allure de course soutenue + sprints courts ». Retirer « LACTIQUE »/SP1/SP3 du titre visible.
- [P1] **dosageSamples — champ « duration » contenant des d** — Vérifié : duration = « 25 m », « 5 m », « 400 m continu », et un cas « 3500 m continu OU 30 × 100 m @CSS récup 10 s (3000 m qualité) ». L'axe réel est la distan
  - fix: Normaliser : champ distance dédié quand l'axe est la distance, scinder le double-protocole en option A / option B, décoder @CSS, sortir « (3000 m qualité) » du 
- [P1] **exerciseNames — entrée « External rotation band — ** — Vérifié : dans swimming-beginner le champ « fr » vaut littéralement « External rotation band — manchette rotateurs » (anglais en tête) répété 3×, alors qu'une v
  - fix: Remplacer la valeur fr par « Rotation externe à l'élastique (coiffe des rotateurs) » partout, fusionner le doublon. Auditer les autres noms fr commençant par de
- [P1] **Titres en MAJUSCULES + anglicisme « checklist » : ** — Vérifié : plusieurs titres crient en capitales tandis que la majorité du catalogue est en casse de phrase — ton typographique incohérent. « checklist » est un a
  - fix: Uniformiser en capitale d'attaque seulement (« Séance phare — nage longue + bilan autonomie », « Retest de seuil 400+200 m »). Remplacer « checklist » → « bilan
- [P1] **i18n — racine FR-only : name / objective / summary** — Vérifié programmatiquement sur swimming-beginner : name/summary/progression_logic/safety_notes n'ont qu'une clé « fr » (objective = null), alors que goals/theme
  - fix: Compléter les blocs EN/ES de name/objective/summary/progression_logic/safety_notes sur les 4 templates natation. Ajouter un test de complétude i18n (tout champ 
- [P1] **sessionTitle — « Test de seuil + introduction au s** — Vérifié littéralement. Le titre dit à la fois « Test de seuil » ET « introduction au seuil » — on teste et on introduit la même chose, redondance confuse, plus 
  - fix: Supprimer la redondance : « Test de seuil + renforcement à sec des épaules ». Traiter (CSS) via la politique de décodage zone.
- [P1] **Notes — anglais non traduit gratuit : « 'Comfortab** — Vérifié dans les notes : le repère d'effort « Comfortably hard » est laissé en anglais entre guillemets alors que l'explication qui suit est en FR. Anglicisme g
  - fix: Traduire : « Effort confortablement difficile — tu peux dire 4-5 mots mais pas une phrase entière. »
- [P2] **exerciseNames / blockNames — doublon de bloc « Blo** — Vérifié : certains libellés de bloc se retrouvent dupliqués en nom d'exercice, créant une redite dans l'arborescence séance. Signalé par les deux personas en ma
  - fix: Auditer les chevauchements blockName/exerciseName et dédupliquer (le nom de bloc ne doit pas réapparaître comme exercice).

### Triathlon
- [P1] **Titres de programmes : "Triathlon competitive — Ha** — "competitive" et "regular" sont des labels de NIVEAU en anglais restés dans le titre FR user-facing, alors que "découverte" est en FR — incohérence flagrante da
  - fix: Traduire les labels de niveau en cohérence avec "découverte" : "competitive"→"confirmé", "regular"→"régulier"/"intermédiaire".
- [P1] **Goals hebdo / notes : disciplines en anglais brut ** — Disciplines de base en anglais dans des champs FR user-facing. swim/bike/run ont des équivalents FR triviaux (natation/vélo/course). "S&C" et "S&C/mob" (Strengt
  - fix: swim→natation, bike→vélo, run→course (traductions directes). "brick"→"enchaînement (brick)" 1re occurrence puis glossarié. "S&C"→"renforcement", "S&C/mob"→"renf
- [P1] **Template beginner ("Triathlon découverte — 10 sema** — Couverture i18n incohérente : les goals hebdo de ce template SONT traduits en/es mais les champs racine restent fr-only, alors que les templates des autres nive
  - fix: Compléter les traductions en/es des champs racine du template beginner (name, summary, objective, safety_notes, progression_logic) pour aligner sur les autres n
- [P2] **progression_logic / champs FR : "periodization Joe** — "periodization" (orthographe EN) dans des champs rédigés en français. Le terme FR est "périodisation".
  - fix: Remplacer "periodization"→"périodisation" dans tous les champs FR.
- [P2] **dosageSamples : annotation de brouillon laissée da** — Le fragment "[du seuil, sous-entendu]" ressemble à une note interne/annotation de rédaction laissée dans un champ user-facing. Ça fait brouillon et le "%" n'est
  - fix: Retirer le "[... sous-entendu]". Expliciter "88-94 % de ton allure seuil" une fois.
- [P2] **Noms d'alternatives en franglais : "Vélo trainer i** — Noms d'alternatives mélangeant FR et EN dans une même expression ("Vélo trainer indoor", "Bridge isométrique", "step-ups bas") — mélange FR/EN non systématisé à
  - fix: Harmoniser sur la convention FR-en-tête + EN entre parenthèses : "Vélo sur home-trainer (intérieur)", "Élévation latérale jambe (side-lying leg raise)", "Rotati

### Musculation
- [P0] **Notes d'exercice + dosageSamples — toutes séances ** — Le sport muscu n'a jamais reçu le nettoyage RPE→« effort N sur 10 » déjà appliqué aux autres sports de l'app. Une grille RPE/RIR entière est collée en intro de 
  - fix: Appliquer la conversion RPE→« effort N sur 10 » aux templates muscu (dosageSamples, notes, warmups). Remplacer RIR par « reps en réserve » / sensation. Retirer 
- [P0] **safety_notes & notes RDL/Hip Thrust : « DRAPEAUX R** — Mot « douleur » et vocabulaire médical (lombalgie, sciatique, douleur irradiante, avis médical immédiat) très présents dans des champs vus par l'utilisateur. Ri
  - fix: Auditer ces notes contre la liste de mots bannis EU MDR (« douleur », « lombalgie », « sciatique ») et passer par le garde-fou EU MDR existant avant merge. Refo
- [P1] **Warmups, cooldowns et notes : « world's greatest s** — Anglais brut laissé dans des champs FR, en contradiction directe avec la traduction FR/EN/ES propre des name/warmup/cooldown faite ailleurs. Le nom d'exercice e
  - fix: Traduire/vulgariser ces termes dans les champs FR : « world's greatest stretch »→« étirement complet en fente », « chest stretch doorway »→« ouverture de poitri
- [P1] **notesSamples (« Séance bilan ») : « la suite natur** — Fuite d'un id technique de niveau machine (`recreational`) dans une note vue par l'utilisateur, écrit en anglais entre backticks. Incompréhensible et non-profes
  - fix: Remplacer `recreational` par le libellé user FR du niveau (« un programme loisir/intermédiaire upper/lower 12 semaines ») ou retirer la référence au code intern
- [P2] **dosageSamples : « 1 x AMRAP 1 set | %1RM 85-90% | ** — Abréviations cryptiques et anglaises dans le schéma de dosage affiché : « AMRAP », « test 1RM », « 3 attempts max ». « 1 x AMRAP 1 set » est aussi redondant/mal
  - fix: Remplacer « AMRAP »→« max de reps », « test 1RM »→« test de charge max (1 répétition) », « 3 attempts max »→« 3 essais max ». Reformuler « 1 x AMRAP 1 set »→« 1

### Yoga
- [P1] **target_zone — yoga-regular-vinyasa-10sem.json (tem** — La valeur target_zone 'RPE 6-7' fuit du jargon brut dans un champ dont toutes les autres valeurs sont vulgarisées ('maintien 30/45/60 s', 'respiration guidée', 
  - fix: Remplacer 'RPE 6-7' par une valeur d'effort vulgarisée cohérente avec le reste du champ (ex. 'effort soutenu' ou 'effort 6-7/10' si l'échelle 1-10 est exposée a
- [P1] **Titres de séance + notes + warmups, surtout yoga-b** — Anglais brut mélangé au FR dans des titres/consignes pour débutants FR, alors que les équivalents FR EXISTENT déjà dans les mêmes fichiers (vérifié : 'Chat-vach
  - fix: Normaliser sur les termes FR déjà présents : Cat-Cow→chat-vache, Down Dog→chien tête en bas, Child's pose→posture de l'enfant, restorative→réparateur, hold→main
- [P1] **Champ duration competitive/beginner : anglicismes ** — Sous-cas distinct isolé car situé dans le champ duration (affiché tel quel). 'hold', 'finishing', 'breath-led' sont des anglicismes qui fuient dans un champ use
  - fix: Remplacer dans duration : 'hold'→'maintien', 'finishing'→'clôture', 'breath-led'→'au rythme de la respiration'. La question des UNITÉS hétérogènes est traitée s

### Hiit
- [P0] **Notes FR récurrentes (les 4 templates HIIT) — « Fo** — « Format first-class » est une mistranslation systématique de « format de base/principal/socle ». L'expression ne veut rien dire en FR (ni en EN dans ce context
  - fix: Remplacer partout « Format first-class » par « Format principal » (ou « Format socle de la séance »). Audit grep sur les 4 templates HIIT (FR et EN, car la faut
- [P0] **hiit-beginner-6sem.json:183 — note step-jacks FR «** — Faute de conjugaison « tu pose » → « tu poses » en plein milieu d'une consigne user-facing. Très visible, nuit à la crédibilité, surtout en séance débutant.
  - fix: Corriger « tu pose » → « tu poses » et relire la phrase complète.
- [P0] **hiit-beginner-6sem.json:24 — summary débutant « Pr** — Typo « doce » → « douce » dans le résumé de programme (champ très visible, premier contact). Confirmé Sally+Maxime, vérifié dans le fichier.
  - fix: Corriger « doce » → « douce ».
- [P0] **Top-level des 4 templates HIIT — name / summary / ** — Ces 6 champs sont des dicts FR-only (vérifié : keys=['fr']) alors que tous les exercises (name/notes/alternatives) ET les warmups/cooldowns sont trilingues fr/e
  - fix: Compléter les blocs {fr,en,es} sur ces 6 champs top-level pour les 4 templates HIIT (même pipeline IA + relecture agent que la dette B2). Cohérent avec le chant
- [P1] **hiit-beginner-6sem.json:381/820, hiit-recreational** — Glose parenthétique en calque littéral absurde : « bug mort ». Le terme consacré FR est « dead bug » tel quel ; « bug » évoque un insecte ou un bug informatique
  - fix: Remplacer par « Dead bug (gainage anti-cambrure) » : garder le terme consacré, expliquer la FONCTION, pas la traduction mot-à-mot du nom.
- [P1] **Nom d'exo « Soulevé de terre roumain haltères (RDL** — Le champ NOM embarque une justification de programmation (« prépare le swing kettlebell de la semaine 5 »). C'est du contenu de note qui pollue le nom et casse 
  - fix: Nom = « Soulevé de terre roumain aux haltères (RDL) ». Déplacer « prépare le swing kettlebell de la semaine 5 » dans la note de l'exercice.

### Hiking
- [P0] **Summary programme fastpacking (default_objective c** — « HIT » au lieu de « HIIT » dans un texte résumé user-facing. Vérifié dans les templates : 3 occurrences de « HIT », zéro « HIIT ». Bug récurrent déjà repéré su
  - fix: Remplacer « HIT » par « HIIT » partout. La glose (« HIIT — entraînement fractionné de haute intensité ») relève de la politique de glossaire transverse (voir fi
- [P0] **sessionTitle « Marche endurance endurance facile (** — Deux bugs cumulés. (1) Doublon « endurance endurance » : confirmé 9 occurrences dans le template, et UNIQUEMENT en FR (la version ES « Caminata suave (zona 2) »
  - fix: Dédupliquer le mot répété à la composition (« Marche d'endurance facile (zone 2) — 75 min, plat à vallonné ») et traduire « rolling » → « vallonné ». Comme le d
- [P0] **sessionTitle « Sortie en montée douce 200 m de dén** — Le dénivelé « 200 m » est répété deux fois dans le même titre (une fois en clair avec le sigle D+, une fois dans le segment de dosage). Redondance générée par l
  - fix: Ne garder qu'une occurrence : « Sortie en montée douce — 45 min, 200 m de dénivelé (D+) ».
- [P1] **sessionTitle « endurance facile (zone 2) base — Ma** — Titre qui commence par une minuscule (« endurance »), inverse l'ordre attendu (fragment de dosage avant le libellé) et a une syntaxe télégraphique cassée (« tec
  - fix: Recomposer : « Marche plate — endurance facile (zone 2), technique de pose des pieds ». Majuscule en tête, libellé d'abord, dosage ensuite, ajouter les liaisons
- [P0] **note hill repeats (« Répétitions en côte (hill rep** — Tags techniques anglais bruts collés dans une note FR user-facing. Confirmé au grep : « sustained climbing », « gradient-moderate », « pack-day » présents en ma
  - fix: Traduire/nettoyer : « sustained climbing » → « montée soutenue », « gradient-moderate » → « pente modérée », « pack-day » → « sac de la journée ». Supprimer les
- [P1] **note marche endurance Z2 — « Allure Z2-cardiac (Ae** — Jargon coach anglais brut dans une note lue par l'utilisateur : « Z2-cardiac », « Aerobic Threshold », « Conversational soutenu », et la référence de méthode « 
  - fix: Reformuler en clair : « Allure d'endurance fondamentale (seuil aérobie) = 65-78% de la FC max, RPE 3-5. Tu dois pouvoir tenir une conversation par phrases entiè
- [P2] **Notes/warmup/cooldown divers — « single-leg balanc** — Anglicismes bruts qui fuient dans les notes/échauffement/retour-au-calme alors que les NOMS d'exercices, eux, sont bien glossés. Incohérence de traitement : « b
  - fix: Harmoniser sur les notes : « foam roller » → « rouleau de massage », « leg swings » → « balanciers de jambe », « single-leg balance » → « équilibre sur une jamb
- [P2] **sessionTitle « Repos ou récup active » + summary** — « récup » est une abréviation familière non glossée dans un titre user-facing alors que le reste des titres est plutôt soigné. Registre incohérent.
  - fix: Écrire en toutes lettres : « Repos ou récupération active ».
- [P2] **exerciseName « Bird-dog » (vs autres exos glossés ** — « Bird-dog » est laissé en anglais brut sans glose ni traduction FR, alors que la quasi-totalité des autres noms d'exos suivent bien le pattern « nom FR (terme 
  - fix: Aligner sur le pattern existant : « Bird-dog (bras-jambe opposés à quatre pattes) ».
- [P1] **Champ name top-level du programme (FR-only) vs ses** — Vérifié dans les templates : le champ `name` est bien un blob mais ne contient QUE la clé `fr` (pas en/es), alors que sessions, exercices et notes ont {fr,en,es
  - fix: Étendre `name` au blob {fr,en,es} comme les autres champs (ou décider explicitement un fallback FR assumé). À cadrer avec le chantier i18n B2 en cours.
- [P1] **warmup vide (chaîne « ») dans hiking-regular-mount** — Présence d'un warmup à chaîne vide et de cooldown « Aucun. » (jours de repos). Risque que l'UI affiche un bloc Échauffement vide / titre orphelin → le user croi
  - fix: Soit masquer la section quand le contenu est vide/« Aucun. », soit afficher un fallback explicite (« Pas d'échauffement spécifique, démarre tranquillement »). V

### Tennis
- [P0] **Notes recreational/competitive FR — "Forehand cros** — Anglais brut non traduit injecté en plein milieu d'un texte FR user-facing (forehand, backhand, cross, feeling balle) alors que le corpus beginner traduit corre
  - fix: Traduire systématiquement dans les notes FR : forehand→coup droit, backhand→revers, cross→croisé, long de ligne→le long de la ligne, feeling balle→toucher de ba
- [P1] **Cooldown competitive FR — "sleeper stretch épaule ** — Le cooldown des niveaux avancés garde les noms d'étirement en anglais brut (sleeper stretch, cross-body stretch) alors que le cooldown beginner les traduit/décr
  - fix: Reprendre les libellés du beginner : "étirement de l'épaule allongé sur le côté (sleeper)" et "bras croisé devant la poitrine (cross-body)". Décrire le geste, g
- [P1] **Exercice — "Cardio intermittent — circuit Kovacs 6** — Nom propre d'auteur scientifique (Kovacs) qui fuit dans un nom d'exercice user-facing. N'apporte rien à l'utilisateur, ressemble à une référence de sourcing int
  - fix: Retirer le nom propre du libellé : "Cardio intermittent — circuit 6 stations". Conserver la source Kovacs en métadonnée/note de sourcing interne.
- [P1] **Exercice — "Squat barre ou gobelet — force max"** — "Gobelet" = calque littéral de goblet squat (jargon muscu). Dans un plan tennis, "squat gobelet" est incompréhensible — Maxime pense littéralement à un gobelet 
  - fix: Renommer en langage clair : "Squat (barre, ou haltère tenu contre la poitrine)". Si goblet/gobelet est conservé, l'expliciter (haltère/kettlebell tenu verticale
- [P2] **Corpus — orthographe incohérente "medecine-ball" v** — Le mot coexiste sous deux graphies dans le même corpus : "medecine-ball" (sans accent) et "médecine-ball". Petit défaut de soin visible.
  - fix: Normaliser sur "médecine-ball" (accentué) partout.
- [P2] **Notes anatomie/médical — "épicondylite (tennis elb** — Risque EU MDR + ton anxiogène. "Épicondylite" est un terme de diagnostic médical, "prévention du tennis elbow" frôle la claim thérapeutique, et "ne sont pas nég
  - fix: Déclinicaliser : remplacer "prévention du tennis elbow / épicondylite" par "confort de l'épaule et du poignet" ; reformuler "ne sont pas négociables" en "on te 

### Football
- [P0] **football-competitive-saison-regional-16sem.json — ** — Tout le bloc de tête du niveau competitive a perdu ses accents (« Preparer », « Saison regionale », « pre-saison », « structuree », « alignes », « PREPARATION »
  - fix: Re-générer ou patcher en UTF-8 correct l'intégralité des champs name/summary/default_objective/progression_logic/safety_notes du niveau competitive (« Saison ré
- [P0] **football-beginner-initiation-8sem.json — notes d'e** — Jargon de conception interne (« Charge cognitive 3-4 », « cognitive load 3-4 ») exposé dans les notes lues par l'utilisateur. Confirmé présent ~10 fois dans le 
  - fix: Supprimer toute mention « charge cognitive » / « cognitive load X » des champs notes exposés (FR+EN+ES). Si l'algo a besoin de l'info, la déplacer dans un champ
- [P0] **football-competitive-saison-regional-16sem.json — ** — Codes de planification encodés dans des titres/noms affichés : « W2 » (semaine 2), « MD-1/MD-3 » (match day minus), « J-3 », « tapering match week », et « — sem
  - fix: Retirer « W{N} », « — semaine N », « MD-X », « J-X » des champs name/match_key/title affichés ; laisser la structure week/theme porter la phase. Si « allégée » 
- [P1] **4 fichiers football — champ target_zone : « RPE 6-** — Le champ target_zone mélange des typages hétérogènes exposés crus : échelle RPE (RPE 6-7/7-8/8-9, 1404+947+165 occurrences), zones cardio (Z2/Z3), labels FR (te
  - fix: Mapper target_zone vers le référentiel dosage caméléon (RPE/Z → libellé sensation : « effort très dur », « allure facile ») et traduire « cool-down » → « retour
- [P1] **4 fichiers football — exercise names redondants av** — Le dosage (6×30 m, 3 séries × 8-10) est dupliqué dans le name de l'exercice alors qu'il est déjà porté par le champ dosage/reps/volume_axis. Redondance qui alou
  - fix: Garder le dosage uniquement dans le champ structuré ; name = « Sprints répétés » / « Ischios nordiques excentriques ». Supprimer le schéma chiffré du name.
- [P1] **Bloc niveau-programme (name, summary, default_obje** — Vérif fichier : les EXERCICES sont bien trilingues (beginner 93 noms en+es+fr, recreational 133), mais le bloc niveau-programme (name/summary/objectif/progressi
  - fix: Compléter les clés en/es sur name/summary/default_objective/progression_logic/safety_notes des 4 niveaux football, par parité avec le contenu exercices déjà tra