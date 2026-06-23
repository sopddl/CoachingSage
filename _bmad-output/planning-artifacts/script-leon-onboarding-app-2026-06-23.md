# Script de Léon — Onboarding APP (mot-à-mot) — CoachingSage

**Date** : 2026-06-23
**Périmètre** : onboarding **APP** uniquement (≠ onboarding programme = party suivante).
**Sources** : décisions figées `party-onboarding-elargi-2026-06-22.md` (scope A/B/C/D + template « fil de Léon ») · `project_party_onboarding_elargi.md` · **maquette `maquette-onboarding-template-2026-06-22.html` (Bienvenue · App = UN SEUL écran)** · voix réelle de Léon extraite du code.

> ⚠️ **Statut** : contenu **mot-à-mot** révisé par 3 agents (UX / personas / MDR) + **reformé sur la maquette « un seul écran »** et les arbitrages Sophie (2026-06-23). Pas encore implémenté. Le rendu final (icônes SF Symbols, layout, vert `coachingAccent`) se valide en device-test — une maquette/un script valide le contenu et le flux, jamais les pixels.

---

## Frontière du script (rappel décisions figées)

L'onboarding **app** fait **3 choses, rien d'autre** (décisions A→D, Sophie 2026-06-22) :
1. **Connaître le sport** (quels sports tu pratiques / veux faire).
2. **Obtenir l'accord** sur la lecture des séances de sport.
3. **Donner les billes** sur le fonctionnement (Léon explique **en une phrase**, pas d'écran tuto).

**S'arrête AVANT** le questionnaire par sport (niveau / objectif / rythme / durée = **création de programme**, party suivante).
**ZÉRO saisie corporelle** : poids / taille **supprimés** (jamais lus dans le code). Âge pris en silence si Apple Santé le fournit, sinon `defaultHRMax`.

## Structure (arbitrée Sophie 2026-06-23, sur la maquette)

L'onboarding app = **UN SEUL écran** : un fil qui défile (le « fil de Léon »), **pas** une pagination en 6 écrans. Bulle Léon courte + grille de sports + bloc accord, **un seul** bouton vert « C'est parti → » en bas.
**Exception** : le **PARQ-light** (sécurité MDR) **reste dans l'app** (décision Sophie) sous forme d'**un écran bref qui suit le fil** — c'est le seul moment hors du « un écran », assumé comme exception MDR documentée.

## Conventions de voix (verrouillées par le code + la maquette)

- **Tutoiement** systématique. **Phrases ultra-courtes**, chaleureuses (la maquette = ~1 ligne par bulle ; ne PAS empiler 3 bulles).
- **Emojis discrets et rares** (👋 🎉), jamais en rafale. **Pas de jargon**. **Pas de promesse santé/poids** (MDR). Léon **ne se signe pas**.

## Conventions UX (template « fil de Léon » figé)

- **Header = un titre** (« Bienvenue 👋 »), **pas de barre d'étapes**. **‹ retour** conservé.
- **Toucher = avancer / sélectionner** ; **une seule validation ferme** en **vert** (`coachingAccent #7BC142`, semibold) = « C'est parti ».
- **Tout réversible** : bulles/champs éditables (crayon ✎), retour libre.
- **Pré-app** : pas de barre du bas (on n'est pas encore dans l'app). La barre (3 onglets + FAB Léon) apparaît après « C'est parti ».

---

# LE FIL (un seul écran) — mot-à-mot

Notation : **L:** = bulle de Léon (verbatim FR). `[UX]` = comportement. `[Collecte]` = donnée. `[MDR]` = garde-fou.

**Header** : « Bienvenue 👋 » · pré-app, sans barre du bas. **Pastille langue discrète** (FR ▾) dans le coin du header, pré-réglée sur la langue système, tappable (→ FR / EN / ES). *(Sélecteur léger à la Bienvenue — arbitrage Sophie : règle le cas « système EN mais je veux FR » dès le 1er lancement.)*

### ① Léon + prénom
**L:** Salut ! Moi c'est Léon, ton coach ici. Comment je t'appelle ?

→ `[champ prénom]` (1 ligne, éditable ✎)
`[Collecte]` `firstName` (1–50 car.). **Aucune** date de naissance, **aucun** poids, **aucune** taille.

### ② Sports (+ la « bille » de fonctionnement, en une phrase)
**L:** Enchanté, [prénom] 👋 Dis-moi ce que tu pratiques — je te préparerai des séances qui te ressemblent. Choisis-en autant que tu veux, tu pourras changer.

→ `[grille 10 sports]`
`[UX]` **Grille multi-sélection** (`SportTileView` : tuile carrée, couleur signature + icône SF Symbol, libellé). Toucher = sélectionne/désélectionne (multi). Le vert « C'est parti » s'active dès **≥ 1 sport**, grisé sinon (cas vide géré).
`[Collecte]` `activeSports` (≥ 1 requis).

Les 10 sports (libellés FR exacts) : **Course · Vélo · Natation · Triathlon · Musculation · Yoga · HIIT · Randonnée · Tennis · Football.**

> Note ton (personas) : « ce que tu pratiques » flatte l'actif (Maxime) mais pouvait exclure la débutante (Nathalie). La maquette dit « Tu pratiques quoi ? » ; on garde court mais l'**ouverture sur l'envie** vit dans la grille (« ce que tu aimerais faire » est un choix légitime) + le filet « tu pourras changer ». Si device-test montre que Nathalie cale ici, repli wording : « Qu'est-ce qui te tente ? ».

### ③ Accord données (bloc compact inline) `[MDR]`
**L (bloc accord, 🔒):** Je regarde **tes séances de sport** — durée, distance, fréquence — pour mieux te proposer. **Jamais ton poids, jamais ta santé.**

→ bouton **« Autoriser »** (déclenche la permission Apple Santé). Refus possible (mode dégradé), ne bloque pas « C'est parti ».

☐ **(toggle séparé, non pré-coché)** Partager des statistiques d'usage **anonymes** pour aider à améliorer l'app. *(Modifiable dans le Profil.)*

`[MDR]` Ancre « jamais ton poids, jamais ta santé » **en clair**, pas en petits caractères (les 2 personas la citent comme le moment qui les retient). Wording « tes séances de sport » (et **pas** « ce que tu fais bouger » : métaphore corporelle bannie post-revue MDR). Aucune donnée corporelle lue.
`[MDR/RGPD]` Le consentement analytics est **séparé** de l'accord Apple Santé (2 finalités distinctes), **non pré-coché**, refusable **sans dégrader le service**. Co-localisé dans le bloc accord du même écran (réponse Sophie « on n'a qu'un écran ») mais **action distincte** du bouton « Autoriser ».
`[Collecte]` Autorisation HealthKit (lecture séances) ; `analyticsConsent`. *(Déclaration d'apps tierces Strava/Garmin = retirée de l'onboarding app — pas dans la maquette « un écran » — reportée au Profil si utile.)*

### ✅ Validation
→ bouton vert **« C'est parti → »** (actif dès ≥ 1 sport).

---

# ÉCRAN BREF QUI SUIT — Pour ta sécurité (PARQ-light) `[MDR — exception]`

> **Gardé dans l'app** (arbitrage Sophie) comme **exception MDR documentée** à la frontière C : on ne crée pas un programme sans cette qualification, et l'app est la 1ʳᵉ porte. C'est le seul écran hors du « un écran ».

**L:** Dernière chose, pour ta sécurité : 5 questions rapides, les mêmes pour tout le monde. Ça sert juste à bien régler tes séances.

*(les 5 questions PARQ-light existantes s'enchaînent — une réponse = on avance)*

**L (si une réponse signale un risque)** : Noté. Par prudence, je partirai sur une intensité douce — on ajustera ensemble. Un avis médical avant de pousser, c'est toujours une bonne idée.

`[MDR]` **Non médical, non alarmiste** : Léon **n'oriente jamais** vers un diagnostic ; propose seulement une intensité douce + suggère (sans imposer) un avis médical (réutilise le ton `questionnaire.intro.medicalClearance`). **« Les mêmes pour tout le monde »** désamorce le sentiment d'être pris pour un cardiaque fragile (Maxime). **« Ça reste entre nous » retiré** (RGPD : pas de promesse de confidentialité non verrouillée).
`[MDR — invariant implem]` Les `parqResponses` **exclues de tout payload analytics**, pas de transit LLM/cloud sans base légale.
`[Collecte]` `parqResponses`.

---

# Clôture
**L:** Voilà, on est bons 🎉 Ravi de t'avoir avec moi, [prénom].

**L:** Quand tu veux un programme, appuie sur mon icône — je ne suis jamais loin — et on le construit ensemble.

`[UX]` → finalize() → dashboard, **barre du bas + FAB Léon** apparaissent. La dernière bulle **prépare l'onboarding programme** (party suivante) sans le commencer (frontière C). **Pas de direction cardinale** (« en bas à droite » banni : casse en RTL / si le FAB bouge) — on désigne l'icône, pas sa position.

---

# Ce qui DISPARAÎT par rapport à l'onboarding actuel (7 écrans → 1 écran + PARQ)

- ❌ **Écran « Données personnelles »** (poids / taille / date de naissance) — supprimé (décision A : jamais lus).
- ❌ **Toute saisie corporelle**.
- ❌ **Écran apps tierces** (Strava/Garmin déclarés) — pas dans la maquette ; l'activité = lue via Apple Santé, la déclaration d'apps → Profil si besoin.
- ❌ **Écran « Comment ça marche »** séparé — fondu en **une phrase** dans la bulle ②.
- ❌ **Écran équipement générique** — spécifique au sport → onboarding programme.
- ❌ **La pagination 6 écrans** → tout dans **un seul fil** + le PARQ bref.

# Mapping écrans actuels → nouveau fil (indicatif implem)

| Actuel (`OnboardingScreen`) | Devient |
|---|---|
| `.firstNameLanguage` | Bloc ① (prénom inline) + pastille langue dans le header |
| `.sportsSelection` | Bloc ② (grille sports) |
| `.personalData` | **SUPPRIMÉ** (corps) ; l'accord HealthKit → bloc ③ |
| `.howItWorks` | Fondu en 1 phrase (bulle ②) |
| `.thirdPartyAppsSync` | **Retiré de l'app** (→ Profil si utile) |
| `.equipment` | **Retiré de l'app** → onboarding programme (par sport) |
| `.disclaimerPARQ` | Écran bref PARQ qui suit le fil + `analyticsConsent` dans le bloc ③ |

---

# Arbitrages Sophie (2026-06-23) — tranchés

1. **Prénom : gardé** (écran/bloc léger, exception relationnelle). Léon t'appelle par ton prénom dans tout le fil.
2. **PARQ-light : reste dans l'app** (exception MDR documentée à la frontière C) — écran bref après le fil.
3. **Analytics : on n'a qu'un écran** → toggle co-localisé dans le bloc accord ③ (mais action RGPD distincte, non pré-cochée).
4. **Langue : sélecteur léger à la Bienvenue** (pastille header), pré-réglé système, modifiable.
5. **Équipement : retiré de l'app** (→ onboarding programme). Confirmé.

# Reste ouvert (mineur, non bloquant)

- **Ton bulle ② « ce que tu pratiques »** : gardé court (maquette) ; repli « Qu'est-ce qui te tente ? » si device-test montre que la débutante cale. À trancher **au device-test**, pas avant.

---

# i18n

Script écrit en **FR mot-à-mot** (référence). **EN / ES** = traduction mécanique à l'implémentation (V1 FR/EN/ES), test de localisation anglaise en fin d'epic. Garder le **registre tutoyé/chaleureux** — ne pas vouvoyer en EN/ES.

---

# Journal de revue multi-agents (2026-06-23)

3 lentilles distinctes, agents différents (règle Sophie « jamais valider sur un seul agent »). **Puis** reformage sur la maquette « un seul écran » + arbitrages Sophie.

### `sophie-ux-challenger` — **NEEDS_FIX**
- P0 PARQ hors scope (frontière C) → **arbitré** : reste dans l'app, exception MDR documentée.
- P0 écran 0 « 1 bouton vert » vs « toucher = avancer » → **résolu par le reformage** : tout est un fil unique, un seul GO final (plus de bouton par écran).
- P1 « Decathlon » → moot (écran apps retiré). P1 prénom hors décision → **arbitré (gardé)**. P1 analytics flou → **corrigé** (forme RGPD) + **arbitré** (bloc ③).
- P2 « en bas à droite » → **corrigé**. P2 « ça reste entre nous » → **corrigé**.

### Personas **Maxime** (actif) + **Nathalie** (débutante) — ton **globalement juste**
- Écran « Tu pratiques quoi » : flatte Maxime / risque Nathalie → gardé court (maquette) + ouverture via la grille + filet « tu pourras changer » ; repli wording flaggé pour le device-test.
- Écran activité/apps « jeter un œil » + jargon Strava/Garmin → **moot** (écran retiré du fil ; lecture = Apple Santé, accord en clair).
- Ancre ③ « jamais ton poids ni ta santé » saluée par les deux (méfiance data / peur du corps). PARQ infantilisant (Maxime) → **corrigé** (« les mêmes pour tout le monde »).

### Lentille **MDR / RGPD** — aucun **CRITIQUE**
- « ce que tu fais bouger » (métaphore corporelle) → **corrigé** (« tes séances de sport »).
- Analytics non granulaire → **corrigé** (consentement séparé, non pré-coché, finalité nommée).
- « ça reste entre nous » → **corrigé** + **invariant implem** (PARQ exclu de l'analytics).
