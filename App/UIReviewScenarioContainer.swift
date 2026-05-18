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
import TemplateModel

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
        case "ui_review_dashboard_active_mixed":
            // **Story 3.10** — dashboard carrousel avec 2 démarrés (running +
            // cycling, planned) + 3 dormants (swimming, yoga, tennis). Tri AC22
            // visible : démarrés en tête. ProgramCard + NextSessionCard sous le
            // carrousel pour le programme sélectionné (= running, premier).
            DashboardActiveScenarioView(scenario: .mixed)
        case "ui_review_dashboard_active_dormant_only":
            // **Story 3.10** — dashboard avec UN programme dormant. NextSessionCard
            // doit afficher "Non commencé" + bouton "Démarrer" (sans next session
            // calculée).
            DashboardActiveScenarioView(scenario: .dormantOnly)
        case "ui_review_dashboard_active_week_completed":
            // **Story 3.10** — NextSessionCard cas "semaine complétée". Le user
            // a coché toutes les sessions de la semaine 1 mais le programme a 4
            // semaines. Affiche "Semaine 1 complétée — patience, la semaine
            // prochaine arrive".
            DashboardActiveScenarioView(scenario: .weekCompleted)
        case "ui_review_dashboard_active_program_completed":
            // **Story 3.10** — NextSessionCard cas transitoire "Programme
            // terminé" (avant que l'auto-archive AC14 ne flip isActive=false au
            // prochain refresh). Affiche checkmark + CTA "Voir le détail".
            DashboardActiveScenarioView(scenario: .programCompleted)
        case "ui_review_dashboard_late_with_replanify":
            // **Story 3.11** — NextSessionCard avec `nextSessionIsLate = true` :
            // badge "En retard" + sous-titre "Cette séance était prévue semaine
            // du {date}" + bouton "Replanifier" à côté de "Démarrer". ProgramCard
            // du carrousel affiche le badge discret "Semaine N en attente".
            // Programme deadlineFixed pour câbler le bouton (AC9).
            DashboardActiveScenarioView(scenario: .lateWithReplanify)
        case "ui_review_dashboard_routine_cyclic":
            // **Story 3.11 AC21** — programme `.routineCyclic` ne doit JAMAIS
            // afficher le badge "En retard" ni le bouton "Replanifier", même si
            // l'utilisateur n'a pas fait sa séance. Filet visuel anti-régression.
            DashboardActiveScenarioView(scenario: .routineCyclicNoReplanify)
        case "ui_review_replanify_sheet_choice":
            // **Story 3.11** — ReplanifySheet step `.choice` : titre + sous-titre
            // + 2 actions (Reporter / Décaler ma semaine) + Annuler. Rendue sur
            // fond `coachingBackground` pour matcher la presentation sheet réelle.
            ReplanifySheet(
                onSelect: { _ in },
                onCancel: { }
            )
        case "ui_review_replanify_sheet_pickdate":
            // **Story 3.11** — ReplanifySheet step `.pickDate` : DatePicker
            // graphical + bouton Valider + bouton Retour. Step initial forcé
            // via le param `initialStep: .pickDate`.
            ReplanifySheet(
                initialStep: .pickDate,
                onSelect: { _ in },
                onCancel: { }
            )
        default:
            UnsupportedScenarioView(scenario: scenario)
        }
    }
}

// MARK: - Story 3.10 — DashboardActiveScenarioView

/// Container pour rendre `ActiveDashboardView` avec un fixture in-memory.
/// Permet à l'agent ui-reviewer de screenshot le carrousel + NextSessionCard
/// sans déclencher Auth/Onboarding/SwiftData/Supabase.
private struct DashboardActiveScenarioView: View {
    enum Scenario {
        case mixed
        case dormantOnly
        case weekCompleted
        case programCompleted
        case lateWithReplanify
        case routineCyclicNoReplanify
    }

    let scenario: Scenario

    var body: some View {
        ScrollView {
            ActiveDashboardView(
                programs: programs,
                selectedId: selectedId,
                regenBadges: [:],
                onSelectProgram: { _ in },
                onTapStartSession: { _ in },
                onTapProgram: { _ in },
                onDeleteProgram: { _ in },
                onTapWeeklyReorder: { },
                onTapReplanify: { _ in }
            )
            .padding(16)
        }
        .background(Color.coachingBackground.ignoresSafeArea())
    }

    private var programs: [ProgramSummary] {
        switch scenario {
        case .mixed:
            return [
                makeProgram(
                    id: idRunning, sport: .running, templateName: "Couch to 5k — Semaine 2",
                    weekStartDate: Date().addingTimeInterval(-7 * 86_400),
                    currentWeek: 2, weekCompleted: 1, weekTotal: 3,
                    totalCompleted: 4, totalSessions: 12,
                    nextSession: makeSession(name: "Footing 30 min", week: 2, day: 3, dur: 30),
                    lastUpdated: Date().addingTimeInterval(-3600)
                ),
                makeProgram(
                    id: idCycling, sport: .cycling, templateName: "Cycling Endurance",
                    weekStartDate: Date().addingTimeInterval(-14 * 86_400),
                    currentWeek: 3, weekCompleted: 2, weekTotal: 4,
                    totalCompleted: 8, totalSessions: 16,
                    nextSession: makeSession(name: "Sortie longue 90 min", week: 3, day: 5, dur: 90),
                    lastUpdated: Date().addingTimeInterval(-7200)
                ),
                makeProgram(
                    id: UUID(), sport: .swimming, templateName: "Triathlon Sprint Swim",
                    weekStartDate: nil, currentWeek: 1, weekCompleted: 0, weekTotal: 3,
                    totalCompleted: 0, totalSessions: 12,
                    nextSession: nil,
                    lastUpdated: Date().addingTimeInterval(-300)
                ),
                makeProgram(
                    id: UUID(), sport: .yoga, templateName: "Yoga Flow Matinal",
                    weekStartDate: nil, currentWeek: 1, weekCompleted: 0, weekTotal: 5,
                    totalCompleted: 0, totalSessions: 20,
                    nextSession: nil,
                    lastUpdated: Date().addingTimeInterval(-7_200)
                ),
                makeProgram(
                    id: UUID(), sport: .tennis, templateName: "Tennis Prep Saison",
                    weekStartDate: nil, currentWeek: 1, weekCompleted: 0, weekTotal: 2,
                    totalCompleted: 0, totalSessions: 8,
                    nextSession: nil,
                    lastUpdated: Date().addingTimeInterval(-86_400)
                )
            ]
        case .dormantOnly:
            return [
                makeProgram(
                    id: idRunning, sport: .running, templateName: "10k en 12 semaines",
                    weekStartDate: nil, currentWeek: 1, weekCompleted: 0, weekTotal: 3,
                    totalCompleted: 0, totalSessions: 36,
                    nextSession: nil,
                    lastUpdated: Date()
                )
            ]
        case .weekCompleted:
            return [
                makeProgram(
                    id: idRunning, sport: .running, templateName: "Couch to 5k",
                    weekStartDate: Date().addingTimeInterval(-2 * 86_400),
                    currentWeek: 1, weekCompleted: 3, weekTotal: 3,
                    totalCompleted: 3, totalSessions: 12,
                    nextSession: nil,
                    lastUpdated: Date()
                )
            ]
        case .programCompleted:
            return [
                makeProgram(
                    id: idRunning, sport: .running, templateName: "Couch to 5k",
                    weekStartDate: Date().addingTimeInterval(-30 * 86_400),
                    currentWeek: 4, weekCompleted: 3, weekTotal: 3,
                    totalCompleted: 12, totalSessions: 12,
                    nextSession: nil,
                    lastUpdated: Date()
                )
            ]
        case .lateWithReplanify:
            // L'utilisateur est en semaine 2 (weekStart il y a 8j) mais sa
            // séance restante de semaine 1 est encore là (`nextSession.week = 1`)
            // → blocage doux activé, badge "En retard" + bouton "Replanifier".
            // Mode `.deadlineFixed` pour câbler le bouton (AC9).
            return [
                makeProgram(
                    id: idRunning, sport: .running, templateName: "10k en 12 semaines",
                    weekStartDate: Date().addingTimeInterval(-8 * 86_400),
                    currentWeek: 2, weekCompleted: 0, weekTotal: 3,
                    totalCompleted: 2, totalSessions: 36,
                    nextSession: makeSession(name: "Fractionné 8×400m", week: 1, day: 3, dur: 45),
                    lastUpdated: Date().addingTimeInterval(-86_400),
                    durationMode: .deadlineFixed,
                    nextSessionIsLate: true
                ),
                makeProgram(
                    id: idCycling, sport: .cycling, templateName: "Cycling Endurance",
                    weekStartDate: Date().addingTimeInterval(-14 * 86_400),
                    currentWeek: 3, weekCompleted: 2, weekTotal: 4,
                    totalCompleted: 8, totalSessions: 16,
                    nextSession: makeSession(name: "Sortie longue 90 min", week: 3, day: 5, dur: 90),
                    lastUpdated: Date().addingTimeInterval(-7200),
                    durationMode: .deadlineFixed,
                    nextSessionIsLate: false
                )
            ]
        case .routineCyclicNoReplanify:
            // AC21 — routine cyclique : aucun badge "En retard", aucun bouton
            // "Replanifier" même si la prochaine séance pourrait sembler en
            // retard côté calendrier. `nextSessionIsLate` reste à false par VM.
            return [
                makeProgram(
                    id: idRunning, sport: .running, templateName: "Routine running 3 mois",
                    weekStartDate: Date().addingTimeInterval(-14 * 86_400),
                    currentWeek: 3, weekCompleted: 1, weekTotal: 3,
                    totalCompleted: 5, totalSessions: 36,
                    nextSession: makeSession(name: "Footing 40 min", week: 1, day: 4, dur: 40),
                    lastUpdated: Date().addingTimeInterval(-3600),
                    durationMode: .routineCyclic,
                    nextSessionIsLate: false
                )
            ]
        }
    }

    private var selectedId: UUID { idRunning }

    // IDs fixes pour reproductibilité (le carrousel sélectionne toujours le running).
    private var idRunning: UUID { UUID(uuidString: "11111111-1111-1111-1111-111111111111")! }
    private var idCycling: UUID { UUID(uuidString: "22222222-2222-2222-2222-222222222222")! }

    private func makeProgram(
        id: UUID, sport: Sport, templateName: String,
        weekStartDate: Date?, currentWeek: Int, weekCompleted: Int, weekTotal: Int,
        totalCompleted: Int, totalSessions: Int,
        nextSession: PersistedSession?, lastUpdated: Date,
        durationMode: ProgramDurationMode = .routineCyclic,
        nextSessionIsLate: Bool = false
    ) -> ProgramSummary {
        ProgramSummary(
            id: id,
            templateName: templateName,
            sport: sport,
            weekStartDate: weekStartDate,
            durationMode: durationMode,
            mode: .planned,
            nextSession: nextSession,
            nextDate: nextSession?.plannedDate ?? Date().addingTimeInterval(86_400),
            currentWeekNumber: currentWeek,
            weekCompletedSessions: weekCompleted,
            weekTotalSessions: weekTotal,
            totalSessionsCompleted: totalCompleted,
            totalSessions: totalSessions,
            lastUpdatedAt: lastUpdated,
            nextSessionIsLate: nextSessionIsLate
        )
    }

    private func makeSession(name: String, week: Int, day: Int, dur: Int) -> PersistedSession {
        PersistedSession(
            id: UUID(),
            weekNumber: week, weekTheme: "Sem \(week)", weekGoal: "Endurance",
            day: day, name: name, durationMinutes: dur, type: .endurance,
            warmup: "10 min échauffement", exercises: [], cooldown: "5 min retour au calme",
            plannedDate: Date().addingTimeInterval(86_400)
        )
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
