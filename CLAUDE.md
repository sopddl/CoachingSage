# CoachingSage — Instructions Claude

## Process livraison UI (obligatoire — instauré 2026-05-06)

**Avant tout commit qui touche `Views/**` (ou claim "feature UI livrée") :**

1. **Lancer l'agent `ui-reviewer`** (`.claude/agents/ui-reviewer.md`) avec en input :
   - liste des fichiers modifiés
   - contexte court (ce qui change, pourquoi)
   - scénarios manuels à tester (chemin user complet depuis launch)

2. L'agent build + install + lance l'app simu avec `SHOW_DEBUG_GRID=1` (overlay
   `DebugGridOverlay.swift` à porter sur CoachingSage si pas encore présent —
   voir pattern dans
   `~/.claude/projects/-Users-sophieslama-CL3/memory/reference_debug_grid_overlay.md`),
   screenshote la nouvelle UI + écrans impactés + cas vide + locale FR/EN,
   applique la checklist 8 points (header surchargé, jargon, copyright,
   découvrabilité, filtres persistants, locale, data vide, layout).

3. Si verdict `BUGS` : fixer findings P0/P1 puis relancer l'agent. Ne JAMAIS
   commiter avec un P0 ouvert.

**Pourquoi cette règle** : 5 bugs UX 1st-level remontés par Sophie au test simu
GardenSage chantier 5 V2 (2026-05-05) — tous catchables en 5 min de test simu
naïf. Cf mémoire CL3 parent `feedback_first_level_ux_checklist.md`.

**Filet régression** : `swift-snapshot-testing` à étendre aux nouvelles vues
critiques (à mettre en place côté CoachingSage si pas déjà fait).

## Agents disponibles

- `template-quality-reviewer` — review JSON program templates contre doctrine
  sportive + EU MDR (déjà en place).
- `ui-reviewer` — review 1st-level UX (instauré 2026-05-06).

## Passes qualité contenu (templates) — filet de régression swift obligatoire

**Pour toute passe qualité sur le contenu des templates** (traduction /
localisation FR/EN/ES, vulgarisation jargon, nettoyage EU MDR, codes zone →
sensation, etc.) : **créer un filet de régression swift** qui charge le bundle
prod via `TemplateLoader.loadAll()` et assert l'invariant de la passe sur les
champs user-facing. Le test est livré DANS le même chantier que la correction.

Filets en place (`Templates/Tests/TemplateLoaderTests/`) :
- `NoRawZoneCodesTests` — aucun code coach brut (Z1-7, FTP-Z, Daniels, EN/SP/CSS…)
  dans le texte affiché (passe #1bis).
- `NoUntranslatedSpanishNamesTests` — aucun nom d'exo/alternative `es == en`
  (anglais non traduit) hors anglicismes dominants whitelistés (passe #2c).

**Pourquoi** : le contenu des 40 templates n'est pas couvert par les tests de
logique ; une régression (édition future, nouveau template) repasserait
inaperçue. Le filet remplace le device-test manuel comme garde-fou permanent
(Sophie device-teste une fois, le filet protège ensuite). Vaut mieux qu'un
check Python jetable — il tourne dans `swift test` à chaque build.

**Politique localisation** (validée Sophie, passe #2c) : on localise dans la
langue cible (pas de langue étrangère résiduelle), **espagnol/français naturel**,
anglicisme gardé UNIQUEMENT s'il est le terme dominant en salle. **Pas de
parenthèses de glose** (cohérent passe #2a). `RPE/RIR/FTP/TM/tempo` = vocabulaire
volontaire conservé tel quel dans les 3 langues (≠ anglais résiduel).

**Politique nommage exos FR/EN** (ratifiée Sophie 2026-06-17, décision B chantier
vulgarisation) : (1) **anglicismes dominants gardés** dans les 3 langues = noms
canoniques de salle / protocoles (burpees, deadlift, kettlebell/KB, wall ball,
box jump, Nordic, push-ups, pull-ups, Pallof, scaption, inside-out, catch-up,
Turkish get-up, FIFA 11+, Tabata/AMRAP/EMOM, Cindy/Fran) ; (2) **génériques &
anatomiques traduits** (pompes, tractions, planche, fessiers, mollets, chaise,
montées de genoux…) ; (3) **sanskrit gardé partout + glose FR** entre parenthèses
(« Posture de l'enfant (balasana) ») ; (4) **codes de zone vulgarisés en
sensation dans les titres** affichés (« (zone 2) » → « (allure facile) »,
« au tempo (zone 3) » → « à allure modérée soutenue ») — le code reste tappable
via glossaire. Filet : `NoForeignLanguageInDisplayedTextTests` (anglais/espagnol
hors-liste interdit en FR affiché). Le champ `duration`/`reps` = clé d'injection
dose (non rendu, le dose localisé prime) → exclu des filets langue.

## Constants build / simu pour l'agent

- **Project** : `/Users/sophieslama/CL3/CoachingSage/CoachingSage.xcodeproj`
- **Scheme** : `CoachingSage`
- **Bundle ID** : `com.sopddl.coachingsage.app`

## Commits

- Ne jamais mélanger CoachingSage et GardenSage (ou TailorSage) dans un même commit.

## Simulateur attitré (règle 2026-07-06 — anti-collision entre sessions)

Ce projet utilise EXCLUSIVEMENT son simulateur dédié pour builds/tests/screenshots simu :
- **CoachingSage-iPhone** — UDID `CF1378C2-D933-4E5C-BDE2-471CF724DA88` (iPhone 17 Pro, iOS 26.5)
- xcodebuild : `-destination 'platform=iOS Simulator,id=CF1378C2-D933-4E5C-BDE2-471CF724DA88'`
- Ne JAMAIS utiliser le simulateur d'un autre projet (état pollué, installations concurrentes).
- iPads partagés (tests layout uniquement) : iPad Pro 11 M5 / iPad mini (26.5) ; « iPad Pro 11 snapshot 26.4 » réservé aux snapshot tests.
- S'il est cassé : `xcrun simctl erase CF1378C2-D933-4E5C-BDE2-471CF724DA88` (reset), ou le recréer avec le même nom et mettre à jour l'UDID ici.

## ⚖️ Barème de vérification par risque (2026-07-06 — PRIME sur les process ci-dessus)

Constat Sophie : « on code 5 min, on fait 2h de test ». Les process lourds de ce fichier datent
d'AVANT les filets automatiques (CI nightly, snapshots, golden files, verrous). Ils restent
valables mais ne s'appliquent plus systématiquement — ils suivent ce barème :

| Classe | Exemples | Vérification requise | On saute |
|---|---|---|---|
| **S** — wording, layout, one-liner UI, i18n | polish UX, libellés, centrage | review inline rapide + snapshot test si la vue en a un + build | ui-reviewer complet, qa-flow, passe simu dédiée → **le nightly attrape** |
| **M** — fix de logique ciblé | bug filtre, compteur | review agent + **test de verrou (non négociable)** + tests unit ciblés | qa-flow complet (sauf zone sync/data) |
| **L** — sync, migrations, data, achats, onboarding, auth | tout ce qui a causé les vrais incidents | pipeline complet (ui-reviewer + qa-flow + verrou + non-régression) | rien |

Règles d'efficacité :
1. **Batcher les gates** : un lot de N fixes S/M = UNE seule passe ui-reviewer/qa pour le lot, jamais N passes.
2. **Batcher les validations device de Sophie** : une séance pour N stories.
3. En cas de doute sur la classe → prendre la classe au-dessus, pas en dessous.
4. Le ratio cible : S ≈ 10 min de garde, M ≈ le temps du code, L = ce qu'il faut.
