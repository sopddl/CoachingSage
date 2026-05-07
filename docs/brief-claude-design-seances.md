# Brief Claude Design — Mockups écran « Séances » CoachingSage

## Contexte produit

**CoachingSage** est une application iOS (SwiftUI, iOS 17+) de coaching sportif personnalisé multi-sport, conçue pour permettre à n'importe qui — du débutant total au triathlète intermédiaire — d'obtenir des programmes d'entraînement adaptés sans payer un abonnement coach.

L'app propose :
- Un **catalogue de 40 templates de programmes** (running, cycling, swimming, triathlon, strength, hyrox, yoga, crossfit, climbing, trail) calibrés par niveau (beginner / intermediate / advanced)
- Un **adapteur algorithmique local** qui personnalise chaque programme depuis le profil utilisateur (autoprofil HealthKit + onboarding + équipement disponible + contraintes santé)
- Un **assistant IA « Léon »** qui adapte les programmes au fil des semaines (mode chat avec quota 10/j sur le free tier)
- Un **suivi multi-programmes simultanés** (différenciateur clé vs Nike Training Club qui force 1 prog à la fois)
- Un **support multilingue** FR/EN (extensible)

Cible utilisateur : multi-personas — Sophie (triathlète autonome 55 ans), Maxime (jeune muscu 22 ans), Philippe (runner du dimanche 48 ans), Nathalie (reprenante 52 ans, 0 expérience), Clara (tenniswoman intermédiaire). Documentés dans `_bmad-output/planning-artifacts/product-brief-CoachingSage-2026-03-21.md`.

## Besoin immédiat

Réaliser **3 mockups d'écran iPhone** pour le 1er onglet de l'app, l'écran « **Séances** » (refonte en cours, anciennement SessionView qui affichait juste une grille de 10 sports). Les 3 mockups correspondent aux 3 états du même écran selon l'état utilisateur :

1. **Mode vide / première mise en route** — utilisatrice qui vient d'onboarder, 0 programme actif (Nathalie)
2. **Mode actif multi-programmes** — utilisatrice avec 3 programmes en parallèle, prochaine séance dominante (Sophie triathlon)
3. **Mode rest day / jour de récup** — utilisatrice avec 1 programme actif mais journée off, valorisation positive de la récup

Ces mockups serviront de **référence visuelle pour le développement SwiftUI** et de **moodboard pitch / story Insta**.

## Identité visuelle (référence)

L'app a une identité visuelle déjà définie (cf `_bmad-output/planning-artifacts/ux-design-CoachingSage-direction-finale.html`).

### Palette de couleurs (à respecter au pixel)

| Token | Hex | Usage |
|---|---|---|
| Bleu marine profond | `#141E2B` | Texte principal, status bar, ambiance dark des assets de présentation |
| Doré chaleureux | `#D4A85A` | Accent principal, CTA, pourcentages, section labels en majuscules |
| Ivoire / écru | `#F5F2EE` | Background de l'écran (warm white, pas du blanc pur) |
| Bleu coach Léon | `#1E5090` | Cards spéciales (prochaine séance, hint Léon italique), FAB Léon |
| Vert nature | `#7BC142` | État rest day / récup, success states |
| Gris ardoise | `#5A6577` | Texte secondaire, méta, labels gris |
| Blanc pur cards | `#FFFFFF` | Fond des cards programmes / templates |
| Border très clair | `#EDE9E3` | Séparateurs, barres de progression vides |

### Typographie

- **Titres / nom programmes / greetings** : **Lora** (serif artisanal, italique pour greetings, regular pour titres)
- **Corps de texte / labels / méta** : **DM Sans** (sans-serif moderne, weights 400/500/600/700)
- **Section labels** : DM Sans 700, MAJUSCULES, 10pt, letter-spacing 1.2px, couleur dorée `#D4A85A`

### Style recherché

- **Flat UI moderne épurée** — vraie app fitness publiée App Store, pas une illustration créative
- **Pas de skeuomorphism**, pas de gradient mesh artistique, pas de néon
- Cards blanches avec **shadow très douce** (`rgba(0,0,0,0.05)`, blur 4)
- Border-radius : **14px** pour cards standards, **18px** pour cards dominantes (prochaine séance / rest day / hero)
- **Légèreté graphique** — densité d'info maîtrisée, pas de bloat (anti-pattern Runna récent où les users critiquent l'UI surchargée)
- Ambiance **chaleureuse et bienveillante**, pas clinique ni « salle de sport hardcore »
- **Inspiration** : Runna (Today tab, rest day narratif), TrainingPeaks (multi-day peek), Hevy (cards routines)

### Composants signature

- **FAB Léon** circulaire 54×54 bleu coach `#1E5090` blanc, à cheval sur la tab bar (offset y -32), ombre soft `0 8px 18px rgba(30,80,144,0.35)`. Pattern repris de GardenSage (`FloreFloatingButton.swift`).
- **Tab bar** 3 onglets (Séances · Progrès · Profil) + slot FAB Léon. Onglet actif en doré.
- **Hint Léon italique** : citation Lora italique 12pt bleu coach sur fond bleu coach très transparent, border-left 3px bleu coach plein, padding 9×12, border-radius 8. **Pas une bulle de chat** — juste une ligne contextuelle calculée par l'algo.
- **Cards programmes compactes** : icône 36×36 fond doré transparent + nom + méta + barre progression 4px + % à droite.
- **Card prochaine séance dominante** : gradient bleu coach `#1E5090 → #2B5F8A`, texte blanc, CTA pill blanche.
- **Card rest day** : gradient vert nature `#7BC142 → #5A9A30`, texte blanc, ligne info séparateur.

## Spécifications techniques des images

**Format** :
- Mockup iPhone portrait — ratio **9:19.5** (iPhone 15 Pro et plus récents)
- Résolution : **1170×2532 px** (mockup pleine définition) ou **390×844 pt** logique
- PNG, fond inclus dans le mockup (pas de transparence)
- Poids : optimisé pour partage web / pitch deck

**Style graphique** :
- **Vraisemblance UI** maximale — l'image doit ressembler à un screenshot d'app réelle, pas à une illustration
- **Tous les textes en français** (pas d'anglais, pas de lorem ipsum)
- **Status bar iOS native simulée** : 9:41 à gauche, indicateurs réseau/batterie simplifiés à droite, couleur `#141E2B` sur fond ivoire
- **Pas d'icônes ou logos d'autres apps** (Strava, Nike, etc.)
- **Pas d'avatar photo de personne** — initiales ou silhouette neutre uniquement si nécessaire
- **Pas de publicités, banderoles Apple Watch / wearables, illustrations 3D**

**Proportions** :
- Nav bar haut : ~80px de haut
- Tab bar bas : 64px de haut
- FAB Léon : 54×54 à cheval (déborde de 32px au-dessus de la tab bar)
- Cards programmes compactes : 60-70px de haut
- Card dominante (prochaine séance / rest day / hero vide) : ~150-180px de haut

## Les 3 mockups à produire

Le contenu détaillé de chaque écran est fourni dans le **fichier de référence HTML** (cf section « Fichiers de référence »). Voici le résumé exécutif :

### Mockup 1 — Mode vide / Première mise en route

**Persona** : Nathalie, 52 ans, 0 programme, vient d'onboarder, autoprofil HealthKit indique « reprise progressive ».

**Contenu** :
- Greeting « Bienvenue, » + titre « Séances » (nav bar)
- 1 icône 📅 calendrier à droite (pas de "+" en mode vide)
- Hint italique Léon : « tu m'as dit reprise progressive — voici 3 pistes adaptées à ton profil HealthKit. »
- Hero card gradient doré « 🌱 Prêt·e à commencer ? — Léon a préparé 3 programmes calibrés sur ton onboarding et tes données santé. »
- Section « SUGGESTIONS POUR TOI » avec 3 cards templates suggérés :
  1. 🚶‍♀️ « Reprise douce » (8 sem) — 3 séances marche + renfo léger / sem · 20-30 min · pour redémarrer en douceur
  2. 💪 « Renfo débutant » (6 sem) — bodyweight maison · 3×/sem · poste tonification + base musculaire
  3. 🧘‍♀️ « Yoga & mobilité » (4 sem) — sessions 15-20 min · sans équipement · respiration + souplesse
- Lien dashed « Tu veux autre chose ? **Crée un programme sur mesure →** »
- Tab bar : Séances actif (doré) · Progrès · Profil + FAB Léon bleu coach

### Mockup 2 — Mode actif multi-programmes

**Persona** : Sophie, 55 ans, triathlète, 3 programmes parallèles (running + cycling + swimming) + 1 routine perso.

**Contenu** :
- Greeting « Bonjour Sophie, » + titre « Séances »
- Nav bar actions : 📅 + bouton "+" doré plein
- Section « PROCHAINE SÉANCE »
- Card dominante gradient bleu coach :
  - Label MAJ « AUJOURD'HUI · 18:30 »
  - Titre « 🏊‍♀️ Endurance — 1500 m »
  - Méta « 5×300 m allure aérobie · récup 30 s · cooldown 200 m »
  - CTA pill blanche « Démarrer la séance → »
- Section « MES PROGRAMMES »
- 3 cards programmes compactes empilées :
  1. 🏊‍♀️ Triathlon — Natation · Sem 4 · prochaine : aujourd'hui · 38%
  2. 🚴‍♀️ Triathlon — Vélo · Sem 4 · prochaine : mer. 8h · 42%
  3. 🏃‍♀️ Triathlon — Course · Sem 4 · prochaine : ven. 7h · 35%
- Section « MES ROUTINES »
- 1 card routine en pointillé : 🧘‍♀️ Stretching d'après-séance · 10 min · sans équipement
- Card dashed CTA bottom : « + Créer une routine ou un programme »
- Tab bar : Séances actif · Progrès · Profil + FAB Léon

### Mockup 3 — Mode rest day / Jour de récup

**Persona** : Sophie, 1 programme actif Cycling, journée off avant prochaine séance jeudi.

**Contenu** :
- Greeting « Bonjour Sophie, » + titre « Séances »
- Nav bar actions : 📅 + "+" doré
- Section « AUJOURD'HUI »
- Card dominante gradient vert nature :
  - Label MAJ « RÉCUPÉRATION »
  - Titre « 🌿 Jour de récup »
  - Méta « Hydrate-toi, marche tranquille, dors bien. Ton corps consolide. »
  - Séparateur 1px blanc opacity 0.25
  - Ligne info bas : « ↗︎ Prochaine séance · jeudi 8h — Vélo, sortie longue 90 min »
- Hint italique Léon : « tu as enchaîné 3 séances cette semaine, le repos est aussi important que l'effort. »
- Section « MES PROGRAMMES »
- 1 card programme : 🚴‍♀️ Cycling — Endurance 12 sem · Sem 5 · prochaine : jeu. 8h · 48%
- Section « MES ROUTINES »
- 1 card routine pointillée : 🧘‍♀️ Stretching d'après-séance · 10 min · sans équipement
- Lien CTA discret bas : « ↻ Réorganiser ma semaine → » (fond doré transparent, texte doré)
- Tab bar : Séances actif · Progrès · Profil + FAB Léon

## Livrable attendu

- **3 fichiers PNG** nommés :
  - `seances-mode-vide.png`
  - `seances-mode-actif.png`
  - `seances-mode-rest-day.png`
- **1 planche récapitulative** (PNG ou PDF) montrant les 3 mockups côte à côte pour validation cohérence
- Format mockup iPhone propre, pas de cadre Mac d'éditeur ou annotations parasites
- Idéalement aussi : versions sans status bar / sans tab bar pour intégration story Insta avec autre frame

## Contraintes produit

- **Toutes les chaînes de texte en français** (l'app est bilingue FR/EN mais cette version pour pitch FR uniquement)
- **Cohérence visuelle stricte** entre les 3 mockups — même grammaire de cards, même tab bar, même FAB, même hint Léon
- **Lisibilité** sur petit écran (le mockup peut être affiché en 300px de large sur un deck) — éviter les fontes trop fines
- **Accessibilité** : contrastes WCAG AA minimum, pas de texte gris très clair sur fond blanc
- **Pas de mots bannis EU MDR** — éviter « rééducation », « thérapie », « médical », « soigne », « guérit » dans les textes des cards
- **Pas de dramatisation marketing** (« BRÛLE DU GRAS ! », « ABS EN 30 JOURS ! ») — ton calme, sage, bienveillant

## Fichiers de référence fournis

- **`_bmad-output/planning-artifacts/ux-design-CoachingSage-seances-dashboard-2026-05-07.html`** — **maquette HTML interactive des 3 mockups**, source de vérité visuelle. À ouvrir dans Safari pour voir exactement ce qui est attendu (palette, espacements, hiérarchie). C'est cette maquette HTML qui doit être reproduite fidèlement en image.
- `_bmad-output/planning-artifacts/ux-design-CoachingSage-direction-finale.html` — charte graphique CoachingSage (palette, typo, composants signature)
- `_bmad-output/planning-artifacts/product-brief-CoachingSage-2026-03-21.md` — 5 personas utilisateurs détaillées (Sophie / Maxime / Philippe / Clara / Nathalie)
- `_bmad-output/planning-artifacts/epics-CoachingSage-v2-proposal.md` — proposition d'epic v2 (SoT planning)
- `/Users/sophieslama/CL3/GardenSage/Views/Components/FloreFloatingButton.swift` — référence du pattern FAB (`Circle 56×56`, ombre `0.35` radius 8 offset y 4) à transposer pour Léon

## Suite prévue

Après validation des 3 mockups Séances :
- Mockups onglet **Profil** (settings, modif données coaching)
- Mockups onglet **Progrès** (charts par sport, agrégat global) — à scoper
- Mockups écran **zoom programme** (push depuis card programme : calendrier hebdo, historique séances, graphes progression)
- Mockups **bottom sheet création** (programme vs routine, choix sport)
- Mockups **chat Léon** (Phase 2 #6, à scoper)

## Contact

**Sophie** — designer solo, dev iOS solo (Swift/SwiftUI), passionnée sport multi-discipline.
Projet : **CoachingSage** (famille d'apps « Sage » : GardenSage jardinage / TailorSage couture / CoachingSage coaching sportif).
