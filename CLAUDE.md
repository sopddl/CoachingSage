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

## Constants build / simu pour l'agent

- **Project** : `/Users/sophieslama/CL3/CoachingSage/CoachingSage.xcodeproj`
- **Scheme** : `CoachingSage`
- **Bundle ID** : `com.sopddl.coachingsage.app`

## Commits

- Ne jamais mélanger CoachingSage et GardenSage (ou TailorSage) dans un même commit.
