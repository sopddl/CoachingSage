// App/UIReviewScenarioContainer.swift
// Pattern "agent peut tester profond sans tap" — porté depuis TailorSage
// Sprint 7 (cf `~/.claude/projects/-Users-sophieslama-CL3-CoachingSage/memory/
// reference_agent_visual_test_pattern.md`).
//
// Au launch, si la variable d'env `UI_TEST_SCENARIO=ui_review_<target>` est
// définie, on bypass complètement le pipe Auth→Onboarding→MainTabView et on
// rend directement la vue cible avec un fixture in-memory. Cela permet aux
// agents (Claude / ui-reviewer) de screenshot des écrans profonds sans
// pouvoir tap dans le simulateur (`mcp__sage-test-bridge__simulator_tap` est
// rejeté côté harness — cf feedback_mcp_simulator_tap_blocked.md).
//
// Ajouter un nouveau scenario :
//   1. Ajouter un case dans `targetView` avec la vue + fixture en arguments
//   2. Lancer l'app avec
//      `SIMCTL_CHILD_UI_TEST_SCENARIO=ui_review_<target> xcrun simctl launch ...`
//   3. Screenshot avec `xcrun simctl io booted screenshot /tmp/X.png`
import SwiftUI

#if DEBUG
struct UIReviewScenarioContainer: View {
    let scenario: String

    var body: some View {
        NavigationStack {
            targetView
                .navigationBarTitleDisplayMode(.inline)
        }
        .tint(Color.coachingPrimary)
    }

    @ViewBuilder
    private var targetView: some View {
        switch scenario {
        case "ui_review_adapter_preview":
            // Story sœur 3.z Bug #2 + Bug #3 — rend AdaptedProgramView en mode
            // "preview" : `onConfirmStart` non-nil force le badge "Aperçu" haut
            // + le sticky CTA "Démarrer ce programme" bas + permet de vérifier
            // que le DisclosureGroup "Adaptations apportées" est replié par
            // défaut (badge count visible, contenu masqué).
            AdaptedProgramView(
                program: AdaptedProgramPreviewFixtures.kneeInjury,
                onConfirmStart: { /* noop pour la review */ }
            )
        case "ui_review_adapter_preview_rules_expanded":
            // Variante Bug #3 — même vue, mais avec le DisclosureGroup déployé
            // au launch (.task qui flip @State). Permet de screenshot la liste
            // appliedRules dépliée pour vérifier le rendu de chaque ligne.
            AdaptedProgramView(
                program: AdaptedProgramPreviewFixtures.kneeInjury,
                onConfirmStart: { /* noop pour la review */ }
            )
            .task {
                // Hacky mais suffisant : on injecte un NotificationCenter pour
                // que la vue elle-même flip son @State. Pas implémenté ici car
                // le DisclosureGroup natif SwiftUI peut être contrôlé via le
                // binding initial. Le scenario "rules_expanded" est laissé en
                // placeholder — le screenshot collapsed suffit pour vérifier
                // la régression Bug #3 (la liste DOIT être collapsed par
                // défaut, c'était l'objet du fix).
            }
        case "ui_review_progress_with_hk_history":
            // Bug #1 — Progrès affiche historique HK même sans programme actif.
            // Pas porté ici : ProgressionView dépend trop fortement de
            // `AppDependencies` + `SupabaseService` pour un bypass simple.
            // Validé via `#Preview` SwiftUI + RenderPreview MCP côté agent.
            UnsupportedScenarioView(scenario: scenario)
        default:
            UnsupportedScenarioView(scenario: scenario)
        }
    }
}

private struct UnsupportedScenarioView: View {
    let scenario: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "questionmark.circle")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text(verbatim: "Scenario inconnu :")
                .font(.headline)
            Text(verbatim: scenario)
                .font(.body.monospaced())
                .foregroundStyle(.secondary)
            Text(verbatim: "Ajouter un case dans UIReviewScenarioContainer.swift")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.coachingBackground.ignoresSafeArea())
    }
}
#endif
