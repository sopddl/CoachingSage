# Party — Onboarding élargi (app + programmes) — CoachingSage

**Date** : 2026-06-22
**Format** : party multi-personas, Sophie dans la boucle. Pivot depuis le chantier densité
(recoupements détection/onboarding). Densité **parkée** (voir fin de doc).

## Casting
- 💪 **Maxime** — débutant qui fait déjà du sport (cas central de la détection).
- ⚖️ **Nathalie** — débutante non-sportive / reprise (garde-fou faux-positif + friction).
- 🎨 **Sally** — UX Expert (affordance, structure, transparence).
- 🤖 **Léon** — coach IA (présence à l'onboarding, nord génératif D2-c = V2).
- 🏗️ **Archi / MDR** — coût & risque du signal, frontière MDR.
- 🧭 **PM** — scope V1 vs V2.

Matos : `product-brief` (5 personas user), party densité d'origine (`party-densite-seances-adaptation-2026-06-21`, nord D2-c renvoyé ici), cartographie du flux onboarding réel (7 écrans app + questionnaire par sport), code (`AutoProfileInference`, `OnboardingViewModel`, `HealthSummaryBuilder`).

## Le vrai problème
L'onboarding **collecte (formulaire) avant d'écouter et de donner** — à l'opposé de la promesse « tu me parles, je te comprends, je te propose ». Trop de taps/confirmations, données corporelles inutiles, zéro langage naturel, détection **dédoublée** (onboarding ⇄ densité), Léon absent.

## Critique (faits saillants)
- 7 écrans app linéaires, **poids+taille+date de naissance dès l'écran 2** (comme un dossier médical) avant toute valeur.
- **Vérifié dans le code** : **poids + taille = collectés mais JAMAIS utilisés** (ni adaptation, ni IA, ni regen). **Âge** = un seul usage faible (FC max `220−âge` en *fallback* regen, déjà couvert par `defaultHRMax`).
- ~95 % de cases pré-définies, quasi zéro texte libre.
- Jargon non glossarisé (cyclosportive, vinyasa, PPL, 5×5, fastpacking).
- Double détection comportementale : `AutoProfileInference` (onboarding) **+** signal densité, deux seuils/fenêtres. (NB : `HealthSummary` a déjà un `weeklyWorkoutsAverage4w`.)

## DÉCISIONS FIGÉES (Sophie, 2026-06-22)

### Scope onboarding app
L'onboarding **app** sert juste à : **(1) connaître le sport + l'activité sportive** (lecture des données d'activité), **(2) obtenir l'accord** sur la lecture des données, **(3) donner les billes** sur le fonctionnement. **Rien d'autre.**

| # | Décision | Détail |
|---|----------|--------|
| **A** | **Zéro saisie corporelle** dans l'onboarding app | Poids/taille **supprimés** (jamais lus). Âge : pris en silence si Santé le fournit, sinon `defaultHRMax`. Si un calcul en a besoin un jour → on demande **en contexte**, à ce moment-là. |
| **B** | **« Te connaître » = sport + activité** | Le sport (combo box) + accord lecture des séances de sport. Pas de phrase NL libre à l'app (le NL libre = nord génératif, côté programme/Léon, V2). |
| **C** | **Frontière nette** | L'onboarding app **s'arrête avant** le questionnaire par sport. Niveau/objectif/fréquence/durée = **création de programme** (party suivante). |
| **D** | **Écran d'accord données dédié & transparent** | Wording ancré MDR : *« je regarde tes séances de sport, jamais ton poids ni ta santé »*. |

### Template UX réutilisable (app ET programmes) — « le fil de Léon »
Maquette : `maquette-onboarding-template-2026-06-22.html`. **3 règles** (demandes Sophie) :
peu de **taps** (toucher une option = on avance), peu de **confirmations** (1 seule validation),
**tout réversible** (« jamais joli du premier coup » → bulles/lignes éditables, retour libre).

Squelette figé :
- **Fil conversationnel Léon** : il parle (donc **explique le fonctionnement en demandant** — pas d'écran tuto séparé), toucher = avancer (zéro bouton « Suivant/Confirmer » par étape).
- **Bulles / lignes éditables** : crayon ✎ visible, on corrige n'importe quoi à tout moment.
- **Le sport = un combo box** (10 sports), **choix délibéré jamais pré-rempli** (un programme est *pour* un sport). **Les deux écrans ouvrent sur ce combo.** Le **logo du sport vit dans la case du combo** (pas dans le header).
- **Header = un titre** (« Bienvenue sur CoachingSage » / « Ton nouveau programme »), **pas de barre d'étapes** (il n'y a pas d'étapes fixes). Bouton **‹ retour** conservé.
- **Vert = validation** → **règle transversale app** : tous les boutons de confirmation passent au vert « GO » (cohérent avec le token `coachingAccent #7BC142`). Vert **semibold**, pas bold.
- **Deux points de départ, même fil** : **App** = on demande (sport + accord), on s'arrête. **Programme** = sport choisi → on **pré-remplit le reste** (niveau, rythme, objectif, durée) depuis ce qu'on sait → l'user corrige (carte récap éditable = fin de fil).

### Vigilances (portées en implémentation, pas des blocages)
1. **Crayon d'édition visible** (sinon « réversible » reste théorique).
2. **Un seul signal comportemental** (unifier `AutoProfileInference` ⇄ signal densité ; `weeklyWorkoutsAverage4w` existe déjà). Les justifications de pré-remplissage (« vu ton activité récente ») ne citent **jamais** une donnée corporelle (MDR).
3. **Combo 10 sports non écrasant** (recherche / ordre malin, les plus courants d'abord).
4. **Cold-start** : défauts pré-remplis toujours **sains**, jamais absurdes (données minces).

## ONBOARDING PROGRAMME — décisions figées (intégré à cette party, 2026-06-23)
Maquette de référence (structure/flux, PAS le rendu final) : `maquette-onboarding-template-2026-06-22.html`.
**Rappel (Sophie) : une maquette HTML valide le SQUELETTE, jamais les pixels — le rendu réel
(vraies icônes SF Symbols + composants app) se valide en DEVICE-TEST à l'implémentation.**

- **Atteint DANS l'app** → garde la **barre du bas** (3 onglets réels : Accueil `figure.run` ·
  Progrès `chart.bar.fill` · Profil `person.fill` + **FAB Léon** à droite). On n'est jamais coincé
  dans la création, retour Accueil direct. (La Bienvenue, elle = pré-app, **sans** barre.)
- **Deux zones franches** (demande S/ Sophie : « distinguer la demande de l'user de la restitution
  de Léon ») : **① TA DEMANDE** (champ libre + carrousel sport) · **② CE QUE LÉON PROPOSE** (carte
  bleutée distincte + avatar Léon : sa restitution ✓/⏳ + récap éditable).
- **Demande libre = la feature phare**, en haut. **Multi-sport via la bulle CONSERVÉ** (« vélo +
  course ») — Léon dit dans SA zone comment il gère. Le champ = **multi-ligne auto-extensible**.
- **Sport sur le programme = CARROUSEL** de TES sports (swipeable, + « Autre ») — ≠ la **grille**
  multi-select de Bienvenue (où on voit les 10 pour choisir). Tuiles **taille standard partout**.
- **Aperçu vivant / flux** (Sophie : « le user peut commencer et changer d'avis ») : zone ② =
  fonction de zone ①. On modifie la demande → la proposition **se recompose**. **Rien n'est figé**
  avant le bouton **vert** (seul moment ferme).
- **2 états montrés** : *au départ* (champ vide, sports en carrousel, Léon attend, GO grisé) et
  *la proposition* (demande remplie → restitution).
- **Léon ✓ / ⏳** : ✓ il fait · ⏳ pas encore → **loggé**. **🔥 Log de TOUTES les demandes →
  backlog priorisé par la demande réelle** (idée Sophie : la roadmap vient des users).

### Mécanisme de récolte des demandes non satisfaites (⏳/🚫)
Backend déjà là (**Supabase** + consentement analytics onboarding). À chaque ⏳/🚫 → 1 ligne table
**`leon_unmet_requests`** : `created_at` · `user_id` (hash anonymisé) · **`category`** (= LE champ
clé : `periodisation_temporelle`, `multi_sport_combine`, `nutrition`, `weight_loss`, `unknown`…) ·
`response` (`not_yet`/`refused_safety`) · `raw` (extrait, gated) · `locale`/`app_version`.
**Sophie récupère** via dashboard Supabase ou SQL : `select category, count(*) … group by category
order by count desc` → roadmap priorisée par fréquence, en une requête.
**Garde-fous (Inès/MDR)** : consentement requis · anonymisé · **catégorie ≠ verbatim** pour les
demandes santé (« perdre 5 kg » → `category=weight_loss`, PAS le texte en clair). Léon **doit
tagger** la `category` (sinon texte brut intriable) ; non catégorisable → `unknown` (lu à la main).

### Backlog identifié (issu de la party)
- **Volume variable dans le temps / périodisation demandée** (« plus en août, moins en sept »,
  « allège-moi 2 sem ») — même famille que l'exemple « vacances ». L'**autorégulation**
  (completion+RPE) existe déjà côté réactif ; la variation **demandée explicitement sur une
  période** = ⏳ pas encore, candidate prioritaire (le log la fera remonter).

### Tensions ouvertes (notées, à trancher à l'implémentation — pas bloquantes)
1. **3ᵉ réponse de Léon 🚫** (Inès) : ✓ je fais / ⏳ pas encore (→ log) / **🚫 je ne fais pas**
   (refus sécurité MDR : « perdre 5 kg en 3 sem », « mets-moi un truc dur »). Le binaire ✓/⏳ est
   incomplet — « pas encore » ≠ refus. Léon reste **borné** (mappe vers le sûr, n'invente pas).
2. **Multi-sport sur Bienvenue → produit quoi ?** (Maxime) : un programme par sport ? combiné ?
   Léon le précise dans sa restitution. **Faisabilité moteur multi-sport combiné à vérifier** (PM).
3. **Page blanche** (Nathalie) : le texte libre n'est JAMAIS le passage obligé (le carrousel sport
   = la porte rassurante) ; placeholder avec exemples dans le champ.
4. **NLP borné serré** (PM) : définir le set que Léon sait parser (sports, durées, jours), logger
   tout le reste — ne pas laisser « Léon comprend tout » enfler.

## EN COURS / NEXT
- **Onboarding app — contenu mot-à-mot** (script de Léon écran par écran) = reste à écrire/valider.
- **Implémentation** (quand Sophie déclenche, SOPDDL) : composants `SportTileView` réutilisés,
  vraies icônes, device-test pour le rendu final. Penser au **signal comportemental unique**
  (fusion `AutoProfileInference` ⇄ densité).
- **Chantier transverse** « vert = validation » app-wide (petit lot UI).
- **Densité** : à reprendre à la lumière de ces décisions (son signal = le signal unifié).

## Densité — PARKÉE
Branche `chantier/densite-adaptation-seance-yoga`. Commits inc1/inc2/inc3a figés (`1e80e07`).
**Étape « step 1 » non commitée** (détection 4 sem / seuil 1,5 + carte « Séances plus denses » +
(i) + message « je vois que tu fais du sport »), tests verts. **À revoir à la lumière de la party
programme** (la densité = program-level, pas figée ; son signal sera le signal unifié décidé ici).
Pas de code densité tant que la party programme n'a pas tranché.
