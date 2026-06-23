# Party — Densité « Séances plus denses » × onboarding « fil de Léon » (2026-06-23)

Sophie dans la boucle. Suite directe de [party-onboarding-elargi-2026-06-22] (qui avait
parqué la densité « à revoir à la lumière de ces décisions ») et de
[party-densite-seances-adaptation-2026-06-21] / [party-densite-offre-seances-plus-longues-2026-06-21].

## Casting
- 🏃 Maxime — user sportif/actif (le cas qui déclenche la densité).
- 🌱 Inès — vraie débutante inactive (garde-fou sécurité/MDR).
- 🤷‍♀️ Nathalie — user page-blanche (cold-start, ne sait pas ce qu'est « densité »).
- 🎨 Sally — UX Designer.
- 🛠️ Tom — Archi / MDR.
- 📐 Paul — PM / Produit.

## Problème (1 phrase)
La densité a été construite comme une **surcouche de réglages** (carte toggle + contrôle par
séance) posée par-dessus un programme figé — alors que l'onboarding « fil de Léon » dit que
**c'est Léon qui compose**. Donc la densité devrait être une **conséquence de ce que Léon
comprend de toi**, pas un bouton qu'on va chercher. On a fait un *réglage*, il fallait un
*comportement de Léon*.

## Contexte technique (état codé, branche `chantier/densite-adaptation-seance-yoga`, 7 inc, PAS mergé)
- Moteur D2-b `SessionDensityAdapter` : leviers volume bornés (allonger tenues ×1.5≤45s,
  +1 tour bloc actif), trimRest INTERDIT, jamais la technique. Recalcul durée. Doctrine validée.
- Signal comportemental workouts HealthKit (seuil 1,5/4 sem), MDR-safe (jamais poids/IMC).
- Persistance `densityEnriched` + `sessionDensityOverrides` + re-adapt id-preserving (complétion intacte).
- UI : carte toggle `DensityCard`, contrôle par séance `SessionDensityControl` (inc3b), helper
  estimation 2 durées, badge « + longue ». Tests verts (47). **Invisible sur l'existant** (gating
  yoga+beginner + flag posé à la création) → device-test Sophie 23/06 : « je ne vois rien ».

## Tour de table (résumé)
- **Users (Maxime/Inès/Nathalie)** : convergence nette vers **« absorbé par Léon »**. Maxime veut
  être *reconnu*, pas configuré (toggle = méfiance). Inès : « dense » fait fuir, le réglage manuel
  exposé = corde pour se pendre ; Léon qui *ne propose jamais* à un vrai débutant = sûr par défaut.
  Nathalie : un choix Standard/Plus dense d'entrée = blocage ; un choix de moins, pitié.
- **Sally** : un toggle à côté de l'IA = aveu d'échec de l'IA. Densité = **une phrase de Léon dans
  le fil** + vert = validation ; ajustement via **la bulle NL** (feature phare déjà figée). **Tuer
  le contrôle par séance dédié** (réintroduit la mécanique qu'on refuse d'exposer). Vigilance :
  l'user doit quand même *voir* qu'on l'a reconnu = la phrase de Léon, pas un badge permanent.
- **Tom (archi/MDR)** : moteur + re-adapt id-preserving = actifs ; le reste = surface. « Absorbé »
  n'est pas « enlever du code » mais « attendre un gros morceau pas commencé » (Léon ne *compose*
  pas encore, il adapte un template figé → c'est un chantier moteur D2-c, pas UI). Moins de surface
  manuelle = moins de surface de risque MDR. Branche non mergée → tuer l'UI = zéro dette ; merger le
  moteur dormant (isolé, testé) pour qu'il soit prêt.
- **Paul (PM)** : **A (stopgap manuel) n'a pas de valeur produit** — option orpheline que personne
  ne découvre (device-test le prouve), jetée dans 1 mois, coût > valeur. → **C** = merger moteur
  dormant + parquer l'UI + faire de la densité une **ligne du chantier onboarding-programme**. La
  densité cesse d'être un chantier séparé, devient un comportement de Léon.

## Verdict valeur de ce qui a été codé (demandé par Sophie)
- **Garde (vraie valeur)** : le MOTEUR `SessionDensityAdapter` (Léon en aura besoin pour composer
  plus dense) + le re-adapt id-preserving + le wording MDR validé + les leviers doctrine.
- **À fusionner** : le signal → dans le signal comportemental unique.
- **Jetable dans cette direction** : la couche UI (carte toggle, **inc3b contrôle par séance**,
  helper estimation, badge) = le travail le plus récent. Construit contre une cible (réglage manuel)
  que la party abandonne. Apprentissage gardé (leviers + wording), code livré largement à la poubelle.

## Tensions résiduelles (parquées)
1. Extraction propre moteur vs UI (la branche mêle les deux à travers les commits → cherry-pick).
2. Signal unique sans régression de l'inférence de niveau (`AutoProfileInference` utilise déjà
   `weeklyWorkoutsAverage4w` ; changer le seuil densité ne doit pas bouger le niveau).
3. Densité figée-compo vs vivante-sur-activité (si l'activité change en cours de programme).
4. Découvrabilité otage du **script Léon** (pas écrit) : Maxime doit *sentir* la reconnaissance.
5. 9 sports = **construire le pool par sport** (les leviers actuels sont yoga-spécifiques). V2.

## Décisions gravées (ratifiées Sophie 2026-06-23)
- **D1** — Densité cesse d'être un chantier autonome → **brique du chantier onboarding-programme**
  (« Léon compose à la bonne densité »). Plus de branche densité vivante ; le sujet repart dans la
  spec onboarding-programme.
- **D2** — **Moteur mergé DORMANT, UI non mergée.** `SessionDensityAdapter` + re-adapt id-preserving
  → extraits et mergés sur main (isolés, testés, non câblés UI). `DensityCard`,
  `SessionDensityControl` (inc3b), helper estimation, badge, toggle-service-UI → **non mergés** ; la
  branche reste en **archive de référence** (pas supprimée). Zéro dette UI sur main.
- **D3** — **Signal unique.** Détection densité = signal comportemental unique
  (`weeklyWorkoutsAverage4w` / `AutoProfileInference`), pas de 2ᵉ source. Fusion dans le chantier
  onboarding-programme, vérifier non-régression inférence niveau.
- **D4** — **Surface = une phrase de Léon + la bulle NL.** Annonce à la compo (« je vois que tu fais
  déjà du sport → séances un peu plus complètes »), validée au **vert**, ajustable en langage
  naturel. PAS de carte toggle, PAS de contrôle par séance, PAS de mécanique exposée.
- **D5 (ouvertes, parquées pour la spec onboarding-programme)** : (a) densité figée-compo vs
  vivante-sur-activité ; (b) généralisation = construire le pool par sport (V2, hors V1 yoga).

## Prochaines actions
1. (Quand Sophie déclenche l'implem) Extraire le moteur `SessionDensityAdapter` + re-adapt
   id-preserving de la branche → merger DORMANT sur main (cherry-pick ciblé, tests moteur verts).
2. Reporter D1→D5 dans la **spec du chantier onboarding-programme** (densité = ligne « Léon compose
   à la bonne densité » + phrase de Léon dans le script + signal unique).
3. Branche `chantier/densite-adaptation-seance-yoga` = archive de référence (ne pas supprimer, ne pas
   merger l'UI).
4. NE PAS généraliser 9 sports comme chantier densité (devient « construire le pool », V2).
