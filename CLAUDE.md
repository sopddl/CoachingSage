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

## Constants build / simu pour l'agent

- **Project** : `/Users/sophieslama/CL3/CoachingSage/CoachingSage.xcodeproj`
- **Scheme** : `CoachingSage`
- **Bundle ID** : `com.sopddl.coachingsage.app`

## Commits

- Ne jamais mélanger CoachingSage et GardenSage (ou TailorSage) dans un même commit.
