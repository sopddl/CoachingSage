# Doctrine HIKING — fragment Story 0.5.10

Référentiel public sourcé pour la création **ex nihilo** des templates hiking CoachingSage Story 0.5.10 et l'algo deterministic local Story 3.3a. Sport sans templates v1 préexistants : doctrine et master prompt construits depuis sources publiques.

**Last revised** : 2026-05-01.

**Statut** : Phase C — fragment hiking complet, prêt à intégrer dans `leon-algo-doctrine-by-sport.md` puis à consommer par `master-hiking.md`.

**Vocabulaire de niveau** (aligné enums Sport + Level Story 0.5.8) :
- `beginner` : aucune ou très faible pratique randonnée régulière, sédentaire à modérément actif. Vise la prise en main de la marche en nature, des chaussures de randonnée, du sac léger et de l'orientation balisée. Capable de tenir 1.5-2 h de marche sur sentier plat ou faiblement vallonné (D+ < 200 m), sans portage significatif (sac journée 3-5 kg). Équivalent SAC/CAS T1 (sentier balisé, terrain plat à peu pentu, pas de risque de chute) / FFRandonnée niveau "facile".
- `recreational` : pratique 1-2× / mois, capable d'enchaîner des journées de 4-6 h avec D+ 600-1000 m, sac journée 6-8 kg, sur sentier balisé en moyenne montagne. Vise des randonnées à la journée régulières (calanques, Vosges, Massif Central, sentiers Pyrénées orientales basses). Équivalent SAC/CAS T2 (sentier de montagne balisé, peut être pentu, exige bonnes chaussures, prise de conscience risque de chute) / FFRandonnée "moyen".
- `regular` : pratique 2-4× / mois depuis ≥ 1 an, capable de tenir des journées 6-8 h avec D+ 1200-1800 m, sac à dos 10-15 kg, sur terrain mixte balisé et hors-sentier débonnaire. Vise grande randonnée multi-jours (GR20 par tronçons, Tour des Aiguilles Rouges, Tour du Mont Blanc tronçons), refuges en autonomie. Équivalent SAC/CAS T3 (sentier de montagne exigeant, parfois mal visible, passages exposés possibles avec mains pour équilibre) / FFRandonnée "soutenu".
- `competitive` : pratique > 1×/sem incl. dénivelé soutenu, profil fastpacking / ultra-trail / trekking alpin engagé. Capable de tenir 8-12 h avec D+ 2000-2500 m+, sac 18-25 kg en autonomie, multi-jours en bivouac. Vise FKT (Fastest Known Time), traversées alpines (Haute Route Chamonix-Zermatt), thru-hiking long-distance (Sentier des Cathares en autonomie, GR20 intégral en 7 jours, GTA segments). Équivalent SAC/CAS T4-T5 (randonnée alpine, terrain raide non balisé, exposition réelle) / FFRandonnée "difficile" + alpinisme F (facile).

---

## Doctrine référente

| Référence | Auteur / institution | Application |
|---|---|---|
| **Training for the Uphill Athlete** (2019) | Steve House, Scott Johnston, Kilian Jornet | Référentiel S&C montagne moderne : périodisation aérobie de base (Z1-Z2 dominant), force-endurance dénivelé, progression volume hebdo en heures, transition → base → spécifique → pic, Muscular Endurance "ME" workouts (D+ chargé). Base Uphill Athlete (Steve House). |
| **Plans Uphill Athlete (Beginner / Intermediate / Advanced Mountaineering)** | Uphill Athlete (Steve House, Scott Johnston) | Plans 8-24 semaines par niveau, volume aérobie 3-6 h/sem (beginner) à 12-20 h/sem (advanced), structure périodisée transition → base → spécifique. |
| **American Hiking Society — Planning Your Hike** | American Hiking Society | Référentiel grand public US : conditioning progressive day-hikes → overnight, règle augmenter volume + charge progressivement, "10 essentials" packing, prep mentale et logistique. |
| **AMC (Appalachian Mountain Club) — Backpacking for Beginners + Hike Leader Requirements** | AMC | Curriculum hiker éducation 5 sessions (clothing, footwear, nutrition, gear, navigation), niveaux de leader (A, B, C, D), calibration grand public east-coast US. |
| **Wilderness Medical Society Clinical Practice Guidelines for Acute Altitude Illness (2024 Update)** | WMS / Luks, Hackett et al. | Règles ascension altitude > 2750 m : pas plus de 500 m de gain de sleeping altitude / jour au-dessus de 3000 m, jour de repos toutes les 3-4 jours, +1 nuit acclimatation / 1000 m gain. Référentiel mondial AMS / HACE / HAPE. |
| **SAC/CAS T-scale + FFRandonnée cotation** | Schweizer Alpen-Club / FFRandonnée / FFCAM | Cotation T1-T6 (SAC) et facile/moyen/soutenu/difficile (FFRandonnée), descripteurs comportementaux par niveau, base calibration `beginner`/`recreational`/`regular`/`competitive`. |
| **Rucking progression militaire (US Army / SF / Stew Smith)** | Stew Smith, US Army FM 21-18 (Foot Marches), GORUCK | Règles progression charge sac : démarrer 10% poids corporel, +5 lbs (2-3 kg) toutes les 2-3 sem, plafond 25-30% poids corporel pour usage civil, jamais > 50-60 lbs (23-27 kg) hors profil militaire. Adaptation tissus conjonctifs. |
| **Knee joint forces during downhill walking with hiking poles** (PMC, ResearchGate) | Schwameder et al., Bohne & Abendroth-Smith | Études biomécaniques : trekking poles réduisent forces tibiofémorales 12-25% en descente 25° pente, et patellofémorales en charge. Justification équipement obligatoire `regular`+ pour descentes > 800 m D-. |

Sources principales :
- [Uphill Athlete — Training Plans](https://uphillathlete.com/training-plans/)
- [Uphill Athlete — Alpinism Beginner with Steve House (TrainingPeaks)](https://www.trainingpeaks.com/training-plans/other/tp-113525/alpinism-beginner-with-steve-house)
- [Uphill Athlete 24-Week Mountaineering Training Plan — Shashi Shanbhag](https://shashishanbhag.com/train/uphill-athlete-24-week-mountaineering-training-plan/)
- [Training for the Uphill Athlete book — Amazon](https://www.amazon.com/Training-Uphill-Athlete-Mountain-Mountaineers/dp/1938340841)
- [American Hiking Society — Planning Your Hike](https://americanhiking.org/planning-your-hike/)
- [AMC — Backpacking for Beginners](https://www.outdoors.org/resources/amc-outdoors/outdoor-resources/backpacking-for-beginners/)
- [AMC — The 10 Essentials Backcountry Hike](https://www.outdoors.org/resources/amc-outdoors/outdoor-resources/the-10-essentials-what-to-pack-for-a-backcountry-hike/)
- [Wilderness Medical Society Clinical Practice Guidelines Acute Altitude Illness 2024 Update — PubMed](https://pubmed.ncbi.nlm.nih.gov/37833187/)
- [WMS Practice Guidelines Altitude PDF — Mountain Guides](https://www.mountainguides.com/pdf/WMS-Altitude-Guidelines.pdf)
- [CDC Yellow Book — High-Altitude Travel and Altitude Illness](https://www.cdc.gov/yellow-book/hcp/environmental-hazards-risks/high-altitude-travel-and-altitude-illness.html)
- [CAF Moselle — Niveaux des sorties en randonnée pédestre](https://cafmoselle.ffcam.fr/niveaux-des-sorties-rando.html)
- [CAF Chambéry — Cotations Randonnée Pédestre](https://www.cafchambery.com/pages/cotations-randonnee-pedestre.html)
- [CAF Grenoble — Activité Randonnée pédestre](https://www.cafgrenoble.com/activites/randonnee-pedestre-isere)
- [Stew Smith — Rucking Progression RULES of Rucking](https://www.stewsmithfitness.com/blogs/news/rucking-progression-rules-of-rucking)
- [GORUCK — How To Train for Army Ruck Marches](https://www.goruck.com/blogs/news-stories/ruck-march-standards)
- [Building the Elite — Rucking 101 Special Operations Selection](https://www.buildingtheelite.com/rucking/)
- [Knee joint forces during downhill walking with hiking poles — PubMed](https://pubmed.ncbi.nlm.nih.gov/10622357/)
- [Effects of hiking downhill using trekking poles while carrying external loads — PubMed](https://pubmed.ncbi.nlm.nih.gov/17218900/)
- [Trekking poles reduce downhill walking-induced muscle damage — PMC](https://pmc.ncbi.nlm.nih.gov/articles/PMC4905913/)
- [Are Trekking Poles Helping or Hindering — Hawke & Jensen 2020 review](https://journals.sagepub.com/doi/10.1016/j.wem.2020.06.009)
- [Summit Strength — Train For Elevation Gain Without Mountains](https://www.summitstrength.com.au/blog/tft33-how-to-train-for-elevation-gain-hiking-without-any-mountains)
- [Wildland Trekking — Training for Extreme Elevation Gain](https://wildlandtrekking.com/blog/training-for-extreme-elevation-gain/)

**Choix de doctrine** : on ancre sur **Uphill Athlete (House-Johnston)** comme référentiel principal de périodisation montagne (volume aérobie Z1-Z2 dominant, force-endurance dénivelé spécifique, progression hebdo lente). On utilise **WMS 2024** comme cadre médical altitude (règle 500 m sleeping / jour > 3000 m, +1 nuit / 1000 m). On utilise **rucking militaire (Stew Smith / GORUCK)** pour les règles de progression de charge (+5 lbs / 2-3 sem, plafond 25-30% PdC). On utilise **AMS + AMC + FFRandonnée/SAC T-scale** pour la calibration grand public et le vocabulaire francophone (D+, D-, cotation T1-T6). Pas d'exclusivité Uphill Athlete car le public CoachingSage majoritaire est randonneur grand public, pas alpiniste — on adapte volumes vers le bas et on garde Uphill Athlete pour `competitive` / multi-jours engagé.

---

## Zones d'effort (target_zone)

Convention v2 hiking : **RPE + zones FC + tags d'environnement** (gradient pente, altitude, charge sac). La randonnée est un sport d'endurance long-format à charge variable (gravité + portage + altitude) — pas de zone de puissance type FTP cycling, mais une logique 3-axes (effort cardio + dénivelé + charge sac).

| Zone | %FCmax indicatif | RPE | Description | Application hiking |
|---|---|---|---|---|
| **Z1** (récup) | < 65% | 1-2 | Récupération active, marche plate respiration nasale | Échauffement marche 10-15 min, retour au calme, jour entre 2 sorties dénivelé |
| **Z2** (cardiac base) | 65-75% | 3-4 | Aérobie de base, conversational complet | Marche plate longue durée, montée douce (gradient < 5%), descente technique non-soutenue |
| **Z2-cardiac** (Uphill Athlete) | 65-78% | 3-5 | "Aerobic Threshold" House-Johnston, conversational soutenu | Sortie longue Z2 fondamentale, base aérobie 80% du volume hiking |
| **Z3** (tempo / sustained climb) | 75-85% | 5-6 | "Comfortably hard" en montée | Bloc montée 30-90 min sur gradient 7-12% avec charge modérée, "ME workouts" |
| **RPE 4-5** (conversational) | 65-75% | 4-5 | Marche tranquille respiration libre | Plat à faible D+, sac journée léger, sortie initiation |
| **RPE 6-7** (sustained climbing) | 75-85% | 6-7 | Montée soutenue, phrases courtes possibles | Bloc montée 500-1000 m D+ avec sac 8-15 kg, ascension régulière |
| **RPE 8-9** (steep gradient / heavy load) | 85-92% | 8-9 | Effort proche threshold, mots seulement | Montée raide > 15% avec charge 15-25 kg, fastpacking simulé, ascension finale |
| **technique** | n/a | 3-5 | Drills moteurs purs (pose pieds, descente technique, usage poles) | Sortie technique balisage, descente exposée, pose pieds rocher humide |
| **cool-down** | n/a | 1-2 | Étirements / mobilité fin sortie | 10 min stretching post-sortie (mollets, ischios, fléchisseurs hanche) |

#### Tags additionnels triple-axe hiking

À combiner avec le `target_zone` ci-dessus quand pertinent (mention dans `notes` plutôt que dans le champ `target_zone` strict) :

- **gradient** : `gradient-flat` (0-3%), `gradient-rolling` (3-7%), `gradient-moderate` (7-12%), `gradient-steep` (12-20%), `gradient-very-steep` (> 20%, hors-sentier engagé).
- **altitude** : `altitude-low` (< 1500 m, sans effet physiologique), `altitude-moderate` (1500-2500 m, légère perte performance), `altitude-high` (2500-3500 m, AMS possible, règles WMS s'appliquent), `altitude-very-high` (> 3500 m, acclimatation obligatoire).
- **pack-load** : `pack-light` (< 5 kg, journée), `pack-day` (5-10 kg, journée chargée + 10 essentials), `pack-multi-day` (10-15 kg, refuge non autonome), `pack-autonomy` (15-25 kg, bivouac autonome), `pack-heavy` (> 25 kg, expé alpine, militaire).

**Choix de doctrine** : on **n'utilise pas de zones d'effort de type Daniels-T / FTP-Sweet-Spot** en hiking car la charge externe (gravité du dénivelé + masse du sac) varie fortement et un même `RPE 7` correspond à des intensités cardiaques différentes selon la pente et la charge. On combine **RPE intermittent** (cadre Uphill Athlete) + **% FCmax** (repère grand public optionnel) + une catégorie `Z2-cardiac` first-class qui correspond à l'Aerobic Threshold de House-Johnston et concentre 70-80% du volume hebdo `recreational`+. Pour `beginner`, **éviter Z3 et RPE > 6** sauf en montée brève ; focus `RPE 4-5` et `Z2`.

---

## Volume hebdo cible par niveau

**Convention volume hiking v2** : volume hebdo exprimé en **heures de marche pure** (effort sport-pur, hors trajets et hors warmup individuel < 10 min) + dénivelé positif cumulé hebdo (D+ en mètres) + masse sac maximum (kg) sur la séance phare.

| Niveau | Vol pic (h/sem marche) | D+ hebdo cumulé (pic) | Masse sac max | Fréquence | Doctrine source |
|---|---|---|---|---|---|
| **beginner** | 2-4 h / sem | 200-600 m D+ | 3-5 kg (sac journée léger) | 2-3 sorties / sem (1 plate Z2 + 1 D+ douce + 1 S&C optionnel) | American Hiking Society, AMC Beginner Backpacking, Uphill Athlete pré-Beginner |
| **recreational** | 4-8 h / sem | 800-1500 m D+ | 6-8 kg (sac journée + 10 essentials) | 3-4 sorties / sem (2 marches Z2 + 1 sortie D+ + 1 S&C) | AMC Day Hiker / Hike Leader B, FFRandonnée niveau moyen, Uphill Athlete Beginner Alpinism |
| **regular** | 8-15 h / sem | 1500-3000 m D+ | 10-15 kg (sac multi-jours) | 4 sorties / sem (1 long hike weekend + 1 hill repeat / ME workout + 1 Z2 + 1 S&C dédié) | Uphill Athlete Intermediate Mountaineering, AMC Hike Leader C, FFRandonnée soutenu |
| **competitive** | 15-25 h / sem | 3000-5000+ m D+ | 18-25 kg (autonomie bivouac) | 5-6 sorties / sem (incl. fastpacking simulé, multi-day prep, ME workouts chargés) | Uphill Athlete Advanced Mountaineering / 24-Week Expedition, FFRandonnée difficile + alpinisme F |

**Long hike ou point fort par niveau** :
- `beginner` : sortie phare W7-W8 = 2 h marche sur sentier balisé moyen, D+ 300-500 m, sac 3-5 kg, allure conversational, repos en milieu de parcours.
- `recreational` : sortie phare = 5-6 h day hike avec D+ 800-1000 m, sac journée 6-8 kg, allure soutenue avec pauses, exposition modérée.
- `regular` : sortie phare = 7-8 h day hike OU mini multi-jours 2 jours avec D+ 1500-2000 m cumulé, sac 12-15 kg, refuges, terrain T2-T3.
- `competitive` : sortie phare = 10-12 h day OU multi-jours 3-5 jours en autonomie, D+ 2000-3000 m, sac 20-25 kg, terrain T3-T4, parfois bivouac.

#### Progression de charge sac (rucking adapté)

**Règle militaire adaptée civil** (Stew Smith / GORUCK) : démarrer 10% poids corporel, ajouter +1-2 kg toutes les 2-3 sem, plafonner à 25-30% poids corporel pour `regular` (15-20 kg sur 70 kg corps), 30-35% pour `competitive` (22-25 kg sur 70 kg). Adaptation tissus conjonctifs lente (6-12 sem). **Jamais > 50% poids corporel** en pratique civile.

| Niveau | Charge initiale | Charge pic | Progression |
|---|---|---|---|
| `beginner` | 0-3 kg (sac quasi vide W1) | 3-5 kg (W6-W8) | +1 kg / 2 sem |
| `recreational` | 4 kg | 8 kg | +1-2 kg / 2-3 sem |
| `regular` | 6 kg | 15 kg | +1-2 kg / 2 sem |
| `competitive` | 10 kg | 25 kg | +2 kg / 2 sem, plateaux à 15 / 18 / 22 kg pour adaptation |

#### Progression D+ hebdo

Règle Uphill Athlete : **augmenter D+ hebdo de 10-20% par semaine** sur 3 semaines build, suivi d'un cutback W4 (-25 à -30% du pic précédent). Volume D+ et durée co-progressent, ne jamais sauter les deux la même semaine.

---

## Périodisation hiking

Le hiking n'a pas de "saison de course" universelle, mais s'organise généralement autour d'un **objectif trek** (TMB, GR20 segment, traversée alpine, multi-day backpacking specifique).

#### Phases (modèle Uphill Athlete adapté grand public)

- **Transition / pré-base** (2-4 sem) : volume cardio modéré Z2, marches plates et faibles D+, premier contact équipement. Pas de sortie engagée.
- **Base aérobie** (6-12 sem) : volume Z2 dominant 80% (sorties longues, marches faibles à moyens D+), introduction progressive D+ et charge sac, force générale 1-2×/sem.
- **Spécifique / pré-trek** (4-8 sem) : volume D+ chargé augmenté, simulation conditions trek (sac à charge cible, gradient cible, durée cible), ME workouts (Muscular Endurance) hebdo, technique descente avec poles.
- **Pic / trek** (1-2 sem A-event = trek) : taper -30% volume sur la semaine pré-trek, puis trek réel = volume sortie absolue, après quoi récupération.
- **Récupération active / off** (1-2 sem post-trek) : volume -50%, marches plates Z1-Z2, mobilité, hydratation, soin pieds.

#### Cycle de base (build / cutback)

- `beginner` : 5-6 build + 1 cutback W4-W5 (-25 à -30% volume accepté car charge absolue faible, marge récup utile).
- `recreational` : 3 build + 1 cutback (-15 à -20%).
- `regular` : 3 build + 1 deload (-15 à -20%).
- `competitive` : 2-3 build + 1 deload (-15 à -20%) pendant build, 3 build + 1 deload pendant base.

Pour tout plan ≥ 6 semaines : prévoir au moins 1 semaine cutback. Renseigne `deload_weeks: [W]` au niveau template. **Préfère un range** ("réduction ~15-20%") qu'un chiffre faux.

#### Pas de tapering classique, mais semaine pré-trek -30% volume

Hiking n'a pas de tapering style course (pas d'optimisation glycogène / VO2max pic). Mais la **semaine pré-trek réduit le volume de 30%** par rapport au pic build :
- **J-7 à J-1** : volume -30 à -40%, marches courtes Z2, D+ modéré, sac vide ou journée. Préserver les jambes, hydratation augmentée 48 h avant.
- **J-2 à J-1** : 1 marche plate 30-45 min Z1-Z2 avec poids sac que tu vas porter (rappel proprio), check matériel complet.
- **J-1** : repos relatif, étirements légers, sommeil.

L'objectif est d'arriver **frais physiquement et acclimaté équipement**, pas optimisé peak. Différent du marathon ou tournoi.

---

## Distribution intensités (80/20 polarized)

**Choix de doctrine** :
- **`beginner`** : 100% Z1-Z2 (RPE ≤ 5), pas d'intensité Z3 jusqu'à ce que le profil tienne 90 min en continu confortable et 400 m D+ sans détresse. Focus motor learning (pose pieds, gestion respiration en montée, hydratation, alimentation en marche).
- **`recreational`** : **80/20 polarized "souple"** — 80% volume en Z2 base (marches longues confortables) + 20% intensité Z3-RPE 6-7 (hill repeats, ME workouts modérés). Pas encore de RPE 8-9 strict.
- **`regular`** : **80/20 polarized** strict en build, 70/30 en spécifique pré-trek (intensité D+ chargé augmente). RPE 8-9 introduit en hill repeats finaux (ascension 100-200 m all-out) et ME workouts chargés.
- **`competitive`** : **75-85% LIT (Z1-Z2 + technique) / 15-25% HIT** (hill repeats, ME chargé, fastpacking simulé). Polarized "souple" pendant phase spécifique pré-expé, peut dériver vers 70/30 en simulation conditions extrêmes.

Justification : Uphill Athlete (House-Johnston) ancre la base aérobie Z2 comme prérequis non-négociable montagne (tissue adaptation lente, mitochondrie, économie). Ajouter du HIT trop tôt dégrade la base et augmente blessures. Validé par revue systématique 2024 (MDPI) sur polarized > threshold endurance entraîné.

---

## Substitutions classiques (alternatives v2)

Liste de remplacements réalistes pour l'algo deterministic Story 3.3a.

| Exercice planifié | Substitution | Trigger |
|---|---|---|
| Sortie longue extérieure Z2 | Marche tapis incliné 2-5% en intérieur, durée -10% | Météo extrême (orage, canicule > 32°C, brouillard épais), pollution, blessure légère cheville |
| Hill repeats extérieur | Stairmaster / escalier d'immeuble (10-20 étages × reps), avec sac | Pas d'accès à dénivelé < 1 h |
| ME workout chargé (D+ + sac) | Vélo elliptique inclinaison max + sac léger | Knee-flare aigu, ankle-injury récente |
| Sortie multi-jours en autonomie | Day hike 8-10 h avec sac plein de la charge cible | Pas de fenêtre weekend / contrainte familiale |
| Trek altitude (sleeping > 3000 m) | Trek altitude modérée (< 2500 m) avec D+ équivalent | `altitude-intolerance`, AMS antécédent, pas d'acclimatation possible |
| Descente engagée terrain T3 | Descente sentier balisé T2 avec poles | `knee-injury`, débutant qui découvre, sortie de groupe mixte |
| Sortie plein soleil été | Sortie matinale 5h-10h ou soirée 17h-21h | Canicule, `hyperthermia-risk` |
| S&C dédié force-endurance | Step-up chargé domicile (banc 30-40 cm) + lunges chargés | Pas de salle, week chargée |
| Trekking poles obligatoire | Bâton de marche unique + main libre | Pas d'accès paire complete, urgence |

---

## EU MDR — Mots à bannir + medical clearance

Vocabulaire qui constituerait un acte médical en UE (Med Device Regulation 2017/745).

#### Bannis dans tout texte généré

- "soigner [pathologie]", "traitement [pathologie]", "guérir", "remède"
- "rééducation post-opératoire", "post-blessure"
- "cure", "thérapie", "diagnostic", "prescription", "ordonnance"
- "soulager [douleur]" → préférer "réduire l'inconfort", "favoriser le confort"
- "soigner mal aux genoux", "thérapie marche" → préférer "renforcer la stabilité du genou", "préparer les jambes pour la descente"
- "réparer le dos / les genoux / les chevilles" → préférer "renforcer", "stabiliser", "préparer"

#### Triggers medical clearance obligatoire

Inclure mention "Consulte un médecin avant de commencer ce programme" dans `safety_notes` si :
- **Antécédents cardiaques** sur effort soutenu en montée (`cardiac-clearance-required`).
- **Trek altitude > 2500 m** prévu : avis médical de principe, surtout > 3500 m (AMS / HACE / HAPE).
- **Reprise post-entorse cheville / genou** récente (< 3 mois) → consultation et reprise progressive.
- **Pathologie genou connue** (gonarthrose débutante, méniscectomie, LCA réparé) → consultation kiné avant programme avec D+ engagé, focus descente.
- **Lombalgie chronique** : sac > 10 kg compromis, avis médical de principe + bike fit sac (réglage hanches).
- **Grossesse** ou postpartum (`pregnancy`, `postpartum-early`).
- Profil `competitive` ultra-distance > 8 h ou trek altitude > 2500 m ou sac > 20 kg → cardiac clearance + bilan effort.
- Profil `beginner` > 50 ans débutant complet sans test effort récent.

---

## Drapeaux rouges (safety)

Référence : American Hiking Society + AMC + Uphill Athlete + WMS + études biomécaniques poles.

#### Tous niveaux

- **Entorses cheville** : risque n°1 du randonneur (terrain irrégulier, racines, pierres mobiles). **Prévention** : chaussures de randonnée tige montante adaptées (pas de chaussure de running), proprio (single-leg balance, BOSU) 1-2×/sem, attention pose de pieds en descente. Reprise progressive après entorse, jamais de hike multi-jours direct sur cheville encore instable.
- **Genou descente** : tendinite rotulienne, syndrome rotulo-fémoral, syndrome de la bandelette ilio-tibiale (ITBS). **Prévention** : trekking poles obligatoires en descente > 800 m D-, force unilatérale (split squat, step-down lent), reduce vitesse descente, gel après sortie longue.
- **Ampoules / phlyctènes** : friction chaussette/chaussure, pied humide, kilométrage soudain. **Prévention** : double chaussette anti-friction OU chaussette technique merino, chaussures rodées avant trek (jamais neuves le jour J), tape préventif points de friction connus.
- **Coup de chaleur** sur sortie chaude exposée : hydratation 500-750 ml/h tempéré (jusqu'à 1 L/h chaleur > 25°C, sodium 300-700 mg/L), couvre-chef obligatoire, écouter signaux (céphalée, frissons, désorientation = STOP, ombre, hydratation, demi-tour).
- **Hypothermie** : risque dès 10°C avec vent + humidité, encore plus en altitude + bivouac. **Prévention** : système 3 couches (base merino + isolation + coupe-vent imperméable), gants + bonnet en sac même en été, réserve calorique sucrée accessible.
- **Perte d'orientation** : carte + boussole + GPS + topo + plan B itinéraire toujours. AMC "10 essentials" obligatoire à partir de `recreational`.

#### Recreational et au-delà

- **Tendinite Achille** sur volume D+ répété. Calf raises excentriques préventifs, rotation chaussures (2 paires si volume haut).
- **Lombalgie sac** : sac mal réglé (charge pas portée par hanches), réglage ceinture lombaire, force core (gainage anti-rotation).
- **Tendinite tibiale antérieure** : sur volume soudain de descente. Toe raises, étirements gastrocnémien.

#### Regular et au-delà (multi-jours)

- **AMS (Mal Aigu des Montagnes)** : céphalée + fatigue + nausée + sommeil dégradé > 2500-3000 m. **Règle WMS 2024** : pas plus de 500 m sleeping altitude / jour > 3000 m, +1 nuit acclimatation / 1000 m gain, jour de repos toutes les 3-4 jours. Si symptômes : NE PAS monter plus haut, redescendre si aggravation. **HACE / HAPE** = urgences absolues, descente immédiate.
- **Saddle sores / chafing** sac multi-jours : crème anti-frottement zones de contact (hanches sous ceinture sac, intérieur cuisses, dos), changer base layer humide rapidement.
- **Intoxication eau (giardia / E. coli)** : filtration ou ébullition obligatoire eau de source / rivière (filtre type Sawyer Squeeze, pastilles purifiantes, MSR Trail Shot).

#### Competitive (fastpacking / ultra / alpine)

- **RED-S** (Relative Energy Deficiency in Sport) : déficit énergétique sur volume haut + déficit calorique trek long. Sentinelles : aménorrhée (femmes), fatigue chronique, immunité dégradée.
- **Surentraînement** : FC repos +10 bpm chronique, sommeil dégradé, perte motivation 3+ semaines.
- **Hyponatrémie** : sur ultra-trek + sur-hydratation eau pure sans sodium. Apport sodium 300-700 mg/L hydratation, ajouter snacks salés.
- **Engelures** sur extrémités altitude / froid : protection mains + pieds + visage rigoureuse, reconnaissance précoce (pâleur, perte sensation, blanchiment).

---

## Hooks metadata standards (hiking)

#### `target_zone`
- `Z1`, `Z2`, `Z3` (zones FC, repère cardio)
- `Z2-cardiac` (Aerobic Threshold Uphill Athlete, conversational soutenu)
- `RPE 4-5` (conversational pace), `RPE 6-7` (sustained climbing), `RPE 8-9` (steep gradient / heavy load)
- `technique` (drills moteurs purs : pose pieds, descente technique, usage poles)
- `cool-down` (étirements / mobilité fin sortie)

Tags additionnels en `notes` (pas dans `target_zone` strict) : `gradient-flat/rolling/moderate/steep/very-steep`, `altitude-low/moderate/high/very-high`, `pack-light/day/multi-day/autonomy/heavy`.

#### `required_equipment`

Vocabulaire kebab-case :
- `hiking-shoes` : OBLIGATOIRE pour toute sortie hiking — JAMAIS omis. Tige montante recommandée `recreational`+ pour terrain technique, basse acceptable `beginner` plat balisé.
- `backpack` : OBLIGATOIRE — taille adaptée au niveau (15-25 L `beginner`, 25-35 L `recreational` jour, 40-60 L `regular` multi-jours, 50-70 L `competitive` autonomie).
- `trekking-poles` : optionnel `beginner` (recommandé descente), recommandé `recreational`+ (descente > 500 m D-), OBLIGATOIRE `regular`/`competitive` descentes > 1000 m D- (réduction 12-25% forces tibiofémorales — études biomécaniques).
- `gaiters` : optionnel mais recommandé sur terrain humide / boueux / neige.
- `gps` : optionnel `beginner` (téléphone OK), recommandé `recreational`+, OBLIGATOIRE `regular`/`competitive` hors-sentier (montre GPS ou GPS dédié).
- `map` : OBLIGATOIRE `recreational`+ (carte topographique IGN 1:25000 ou équivalent), conseillé `beginner`.
- `compass` : OBLIGATOIRE `regular`/`competitive`, recommandé `recreational`.
- `headlamp` : OBLIGATOIRE `regular`/`competitive` (multi-jours, départs avant aube), recommandé `recreational` (sortie longue d'automne).
- `water-filter` : OBLIGATOIRE `regular`/`competitive` multi-jours en autonomie (filtre type Sawyer ou pastilles MicroPur), optionnel sortie journée avec ravitaillement.
- `hat-cap` : OBLIGATOIRE soleil expose, et bonnet `regular`/`competitive` montagne / hiver.
- `gloves` : recommandé `recreational`+ saisons fraîches, OBLIGATOIRE `competitive` altitude.
- `rain-jacket`, `insulation-layer`, `base-layer-merino` : système 3 couches, OBLIGATOIRE `recreational`+ en montagne.
- `first-aid-kit`, `whistle`, `emergency-blanket` : OBLIGATOIRE `regular`/`competitive`, conseillé `recreational`.
- `mat`, `resistance-band`, `dumbbells`, `step-box` (S&C off-trail).

#### `incompatible_constraints`

Vocabulaire kebab-case :
- `knee-injury` (rotulien, ligamentaire, méniscale)
- `ankle-injury` (entorse récente < 3 mois)
- `lower-back-pain` (compromis charge sac > 10 kg)
- `hip-injury`
- `cardiac-clearance-required`
- `altitude-intolerance` (AMS antécédent récurrent, contre-indication trek > 2500 m)
- `hyperthermia-risk` (fragilité chaleur, pathologie cardiovasculaire, antécédent coup de chaleur)
- `hypothermia-risk` (fragilité froid, Raynaud, pathologie cardiovasculaire)
- `pregnancy`, `postpartum-early`
- `no-trail-access` (urbain dense, sortie tapis incliné en alternative)
- `no-elevation-access` (plaine, sortie escalier / stairmaster en alternative)
- `solo-only` (impacte sécurité multi-jours)
- `weather-extreme` (canicule active, gel, orage)
- `outdoor-only`, `indoor-only` (préférence sortie)

#### `alternatives`

Liste de noms d'exercices substitutifs (cf. tableau Substitutions ci-dessus). **Minimum 1-2 alternatives réalistes par exercice. `alternatives: []` vide INTERDIT — l'algo deterministic Story 3.3a en a besoin.**

#### `volume_axis`
- `duration` (sortie chronométrée, hill repeats minutés, ME workouts)
- `distance` (sortie chiffrée en km, traversée linéaire)
- `elevation` (séance D+ ciblée : "1500 m D+ en bloc Z3 sustained climbing")
- `sets` (séance structurée : `sets: 5` × `duration: "20 min montée Z3 + 10 min récup descente Z1"`)
- `reps` (renforcement musculaire S&C : step-ups, lunges chargés, calf raises)

---

## `week_structure` typique par niveau

| Niveau | type | micro_pattern | recovery_cadence |
|---|---|---|---|
| **beginner** | `linear` | `Z2 marche plate + S&C mobilité-prévention + Z2 D+ douce` (2-3 séances) | `1 cutback W4-W5 sur plan 8 sem` |
| **recreational** | `linear` | `Z2 marche + hill repeats + S&C dédié + sortie longue Z2` | `1 deload toutes les 4 semaines` |
| **regular** | `block` | `Z2 base + ME workout chargé + S&C dédié + Z1 récup + sortie longue D+ chargé` | `1 deload toutes les 3-4 semaines` |
| **competitive** | `polarized` | `Z2 base + intervals D+ steep + Z2 + ME chargé + Z1 récup + fastpacking simulé / sortie longue` | `1 deload toutes les 3 semaines + semaine pré-trek -30%` |

`deload_weeks` exemples :
- Plan 8 sem `beginner` : `[5]`
- Plan 10 sem `recreational` : `[4, 8]`
- Plan 12 sem `regular` : `[4, 8, 12]`
- Plan 16 sem `competitive` : `[4, 8, 12]` + semaine pré-trek W15 ou W16 distincte

---

## Lessons learned (héritées du pilote running et stories template précédentes)

Issues du pilote running Phase B (Story 0.5.10) et reprises ici en garde-fous obligatoires :

1. **Convention volume harmonisée** : `summary` ↔ chaque `weeks[i].goal` ↔ `progression_logic` doivent utiliser la **même unité** (heures de marche + D+ hebdo cumulé + masse sac) cohérente partout. Pas de mélange "h/sem" dans summary et "km/sem" dans goal.
2. **Pas de calcul % faux** : si on donne un chiffre de réduction deload / pré-trek (-15%, -25%, -30%), recompter mentalement contre le volume du pic. Sinon préférer un range ("réduction ~15-20%", "~75-85% LIT/technique").
3. **Vol pic en EFFORT PUR** (heures de marche, hors warmup individuel < 10 min, hors trajets) — vérifier par recompte des durées de la semaine pic.
4. **Distribution intensités nuancée** : si `competitive`, range 75-85% LIT/technique annoncé et semaines de spécificité explicitées. Si `beginner`, focus Z1-Z2 et pas de RPE > 5-6.
5. **Cutbacks dans la fenêtre doctrine** : -15 à -20% standard, -25 à -30% accepté pour `beginner` low-volume seulement.
6. **Vérification arithmétique pré-rendu** : recompter le volume hebdo pic (heures + D+ + sac), le volume deload, les durées des hill repeats / ME workouts dans la session phare, le total temps Z2 vs RPE 8-9 sur une semaine type. Match `summary` ↔ `goal` ↔ contenu réel ?
7. **`alternatives: []` vide INTERDIT** : chaque exercice a au moins 1-2 alternatives réalistes (l'algo deterministic Story 3.3a en a besoin).

Garde-fous spécifiques hiking ajoutés Phase C :

8. **Charge sac progressive obligatoire** : ne JAMAIS sauter de palier de charge (+1-2 kg / 2-3 sem). Toute progression > 2 kg en 1 sem est une erreur de design.
9. **D+ progressif obligatoire** : +10-20% D+ hebdo / sem, jamais > 30% (risque tendinite tibiale, rotulienne, ITBS).
10. **Trekking poles mention explicite** dans `required_equipment` dès `regular` et en alternatives `recreational` pour descentes > 500 m D-.
11. **WMS altitude rule mention** dans `safety_notes` si plan vise un objectif > 2500 m sleeping altitude.
12. **Pas de "post-blessure", "soigner [genou]", "rééducation"** — préférer "renforcer", "stabiliser", "préparer".

---

## Sources

#### Doctrine et leveling
- [Uphill Athlete — Training Plans](https://uphillathlete.com/training-plans/)
- [Uphill Athlete — Alpinism Beginner with Steve House (TrainingPeaks)](https://www.trainingpeaks.com/training-plans/other/tp-113525/alpinism-beginner-with-steve-house)
- [Uphill Athlete — Adventure Consultants 8 week Basic Mountaineering Plan (TrainingPeaks)](https://www.trainingpeaks.com/training-plans/other/tp-91779/adventure-consultants-uphill-athlete-8-week-basic-mountaineering-plan)
- [Uphill Athlete — Alpinism Intermediate with Steve House](https://uphillathlete.com/training-plans/steve-houses-8-week-advanced-rock-alpinist-training-plan/)
- [Uphill Athlete — 5-Week Foundation Rock Alpinist](https://uphillathlete.com/training-plans/steve-houses-5-week-foundation-rock-alpinists-training-plan/)
- [Uphill Athlete 24-Week Mountaineering Training Plan — Shashi Shanbhag](https://shashishanbhag.com/train/uphill-athlete-24-week-mountaineering-training-plan/)
- [Steve House — How to Train for Mount Everest (Alan Arnette)](https://www.alanarnette.com/blog/2024/08/05/guest-post-by-steve-house-how-to-train-for-mount-everest/)
- [Training for the Uphill Athlete book — Amazon](https://www.amazon.com/Training-Uphill-Athlete-Mountain-Mountaineers/dp/1938340841)
- [Mountain Sport Training Advice from Uphill Athlete — alpsinsight](https://alpsinsight.com/stories/mountain-sport-training-advice-from-uphill-athlete/)

#### Référentiels grand public US et France
- [American Hiking Society — Planning Your Hike](https://americanhiking.org/planning-your-hike/)
- [AMC — Backpacking for Beginners](https://www.outdoors.org/resources/amc-outdoors/outdoor-resources/backpacking-for-beginners/)
- [AMC — The 10 Essentials Backcountry Hike](https://www.outdoors.org/resources/amc-outdoors/outdoor-resources/the-10-essentials-what-to-pack-for-a-backcountry-hike/)
- [AMC Boston Chapter — Instructional Programs](https://hb.amcboston.org/instructional-programs)
- [AMC Western MA — Beginner Resources](https://www.amc-wma.org/beginner-resources.cgi)
- [AMC SE Mass — New Hiker FAQ PDF](https://amcsem.org/hiking_new_hiker_faq.pdf)
- [AMC Connecticut — Hike Leader Requirements](https://ct-amc.org/hiking/hike-leader-requirements/)
- [CAF Moselle — Niveaux des sorties en randonnée pédestre](https://cafmoselle.ffcam.fr/niveaux-des-sorties-rando.html)
- [CAF Chambéry — Cotations Randonnée Pédestre](https://www.cafchambery.com/pages/cotations-randonnee-pedestre.html)
- [CAF Grenoble — Activité Randonnée pédestre](https://www.cafgrenoble.com/activites/randonnee-pedestre-isere)
- [Club Alpin Île-de-France — Randonnée pédestre](https://www.clubalpin-idf.com/randonnee)
- [CAF Meythet — Condition physique et compétences techniques](https://www.cafmeythet.org/wp/2023/01/27/condition-physique-et-technique/)
- [FFCAM — Recherchez une formation](https://www.ffcam.fr/les-formations.html)

#### Altitude et médecine montagne
- [WMS Clinical Practice Guidelines Acute Altitude Illness 2024 Update — PubMed](https://pubmed.ncbi.nlm.nih.gov/37833187/)
- [WMS Practice Guidelines Altitude PDF — Mountain Guides](https://www.mountainguides.com/pdf/WMS-Altitude-Guidelines.pdf)
- [WMS Consensus Guidelines Altitude PDF — Wild Med Center](https://www.wildmedcenter.com/uploads/5/9/8/2/5982510/wms_altitude.pdf)
- [WMS 2024 Altitude Summary](https://wms.org/magazine/magazine/1463/2024-Altitude-Summary/default.aspx)
- [WMS 2019 Altitude CPG Update](https://wms.org/magazine/magazine/1252/2019altitude-cpg/default.aspx)
- [WMS Sage Journals — Acute Altitude Illness 2024](https://journals.sagepub.com/doi/10.1016/j.wem.2023.05.013)
- [CDC Yellow Book — High-Altitude Travel and Altitude Illness](https://www.cdc.gov/yellow-book/hcp/environmental-hazards-risks/high-altitude-travel-and-altitude-illness.html)
- [AAFP — Acute Altitude Illness Updated Prevention and Treatment](https://www.aafp.org/pubs/afp/issues/2020/0415/p505.html)

#### Rucking et progression de charge sac
- [Stew Smith — Rucking Progression RULES of Rucking](https://www.stewsmithfitness.com/blogs/news/rucking-progression-rules-of-rucking)
- [Ruck For Miles — Army Ruck March Standards Complete Guide](https://www.ruckformiles.com/guides/army-ruck-march-standards/)
- [GORUCK — How To Train for Army Ruck Marches](https://www.goruck.com/blogs/news-stories/ruck-march-standards)
- [GORUCK — The 12 Mile Ruck Standards Time and Prep](https://www.goruck.com/blogs/news-stories/12-mile-ruck)
- [Military.com — 7 Basics of Rucking](https://www.military.com/military-fitness/7-basics-of-rucking-anyone-who-wants-ruck-fun)
- [Military.com — Everything You Should Know to Become Better at Rucking](https://www.military.com/military-fitness/everything-you-should-know-become-better-rucking)
- [Building the Elite — Rucking 101 Special Operations Selection](https://www.buildingtheelite.com/rucking/)
- [TheRuckCalculator — Military Ruck Standards 2026](https://theruckcalculator.com/guides/training/military-ruck-standards.html)
- [Force Fitness — Military Rucking Weights From Around the World](https://force-fit.co.uk/blogs/training-guides/challenge-yourself-with-military-rucking-weights-from-the-world-s-armed-forces)

#### Trekking poles biomécanique
- [Knee joint forces during downhill walking with hiking poles — PubMed](https://pubmed.ncbi.nlm.nih.gov/10622357/)
- [Effects of hiking downhill using trekking poles while carrying external loads — PubMed](https://pubmed.ncbi.nlm.nih.gov/17218900/)
- [Trekking poles reduce downhill walking-induced muscle and cartilage damage — PMC](https://pmc.ncbi.nlm.nih.gov/articles/PMC4905913/)
- [Are Trekking Poles Helping or Hindering Your Hiking Experience — Hawke & Jensen 2020](https://journals.sagepub.com/doi/10.1016/j.wem.2020.06.009)
- [A Review of Biomechanical and Physiological Effects of Using Poles in Sports — PMC](https://pmc.ncbi.nlm.nih.gov/articles/PMC10135831/)
- [The Science Behind Trekking Poles — Hobnail Trekking](https://hobnailtrekkingco.com/the-science-behind-trekking-poles-how-they-make-every-step-smarter/)

#### Progression D+ et entraînement vertical
- [Summit Strength — How To Train For Elevation Gain Hiking Without Mountains](https://www.summitstrength.com.au/blog/tft33-how-to-train-for-elevation-gain-hiking-without-any-mountains)
- [Wildland Trekking — Training for Extreme Elevation Gain](https://wildlandtrekking.com/blog/training-for-extreme-elevation-gain/)
- [Run Infinite — Going Vertical How Much Vert is Enough in Training](https://runinfinite.com/training-for-vertical-gain/)
- [Vert.run — How to Train for the Hills Without Mountains](https://vert.run/how-to-train-for-the-hills-without-having-access-to-the-mountains/)
- [Trail Runner Magazine — Chasing Vert](https://www.trailrunnermag.com/training/trail-tips-training/chasing-vert-2/)
- [Mont Blanc Experience — Vertical Gain and Loss Distance and Hiking Time](https://www.montblanc-experience.com/1392-vertical-gain-and-loss--distance--and-hiking-time)
- [Ultra Training App — Training Strategies for Huge Vert](https://www.ultratrainingapp.com/ultra-running-blog/training-strategies-for-elevation-gain)

#### Distribution polarized (validé endurance)
- [Polarized Training VO2max Systematic Review 2024 — PMC](https://pmc.ncbi.nlm.nih.gov/articles/PMC11679080/)
- [Comparison Polarized vs Other Training Meta-analysis — PMC](https://pmc.ncbi.nlm.nih.gov/articles/PMC11329428/)
- [What is best practice for training intensity and duration distribution — PubMed](https://pubmed.ncbi.nlm.nih.gov/20861519/)
