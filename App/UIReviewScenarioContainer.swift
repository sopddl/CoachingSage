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
        case "ui_review_dashboard_empty":
            // **Story 3.15 v7 (Sophie 2026-05-21)** — mode `.empty` simplifié :
            // icone hero + titre + sous-titre + CTA "Crée mon premier programme".
            EmptyDashboardView(
                hintKey: "dashboard.empty.hint.default",
                onTapCustom: { /* noop scenario */ }
            )
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.coachingBackground.ignoresSafeArea())
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
        case "ui_review_q2_multichoice_running":
            // **Story 3.13 Phase E (AC26)** — Q2 multi-choice running. Pré-sélectionne
            // `5k` pour montrer les paires incompatibles grisées (`marathon`, `half_marathon`).
            // Test du grisage matrice + bouton Confirmer désactivé tant qu'aucune sélection.
            Q2MultiChoiceScenarioView(sportCode: "running", preselected: ["5k"])
        case "ui_review_q2_singlecycle_strength":
            // **Story 3.13 Phase E (AC26)** — strengthTraining a un catalogue
            // structurellement exclusif (split ≠ programme combinable). Q2 forcée en
            // `.singleChoice` + hint pédagogique "Choisis ton cycle actuel. Tu pourras
            // en enchaîner d'autres ensuite." pour ne pas frustrer l'user.
            Q2SingleCycleScenarioView(sportCode: "strengthTraining")
        case "ui_review_q2_singlecycle_triathlon":
            // **Story 3.13 Phase E (AC26)** — triathlon : 1 distance cible = 1 cycle.
            // Même logique single-choice + hint cycle que strengthTraining.
            Q2SingleCycleScenarioView(sportCode: "triathlon")
        case "ui_review_q2_multichoice_swimming":
            // **Story 3.13 Phase E (AC26)** — Q2 swimming aucune incompatible matrice.
            // Pré-sélectionne `endurance` + `technique` (combinaison la plus fréquente,
            // doctrine Maglischo). Aucun grisage attendu = baseline visuelle.
            Q2MultiChoiceScenarioView(sportCode: "swimming", preselected: ["endurance", "technique"])
        case "ui_review_sport_avatar_running":
            // **Story 3.14 (AC16)** — questionnaire running : avatar sport
            // (figure.run sur cercle bleu marine) sur bulles Léon + typing.
            SportAvatarScenarioView(sportCode: "running")
        case "ui_review_sport_avatar_swimming":
            // **Story 3.14 (AC16)** — questionnaire swimming : avatar sport
            // (figure.pool.swim sur cercle bleu clair) sur bulles Léon + typing.
            SportAvatarScenarioView(sportCode: "swimming")
        case "ui_review_sport_avatar_triathlon":
            // **Story 3.14 (AC16)** — questionnaire triathlon : avatar sport
            // (figure.mixed.cardio sur cercle or) sur bulles Léon + typing.
            SportAvatarScenarioView(sportCode: "triathlon")
        case "ui_review_replanify_sheet_pickdate":
            // **Story 3.11** — ReplanifySheet step `.pickDate` : DatePicker
            // graphical + bouton Valider + bouton Retour. Step initial forcé
            // via le param `initialStep: .pickDate`.
            ReplanifySheet(
                initialStep: .pickDate,
                onSelect: { _ in },
                onCancel: { }
            )
        case "ui_review_session_detail_glossary",
             "ui_review_session_detail_v2":
            // **Story 3.17 Phase 1 + Story 3.18 Phase 2** — SessionDetailView
            // avec une séance running riche couvrant :
            // - Story 3.17 : termes glossaire inline (tempo, threshold, cadence,
            //   Daniels-T, EN1, push-off, strides, intervals, plyometric...) →
            //   underline pointillé primary, tap popover définition, toast
            //   découvrabilité.
            // - Story 3.18 : hero bandeau couleur sport + stats grille (durée,
            //   zone dominante, RPE estimé, nb blocs) ; panel "Pourquoi cette
            //   séance ?" expandable avec justification heuristique ; timeline
            //   stepper vertical (rail + pastilles warmup ⓪ flamme · exos
            //   numérotés · cooldown ⓝ flocon).
            SessionDetailGlossaryScenarioView()
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
            // **Story 3.15** — split started/dormant pour la nouvelle signature
            // 3 zones d'`ActiveDashboardView`. Teaser + upcomingSessions fournis
            // en fixture pour démontrer visuellement la section "Séances"
            // (raffinement Sophie 2026-05-21 v4).
            let allPrograms = programs
            let started = allPrograms.filter { $0.weekStartDate != nil }
            let dormants = allPrograms.filter { $0.weekStartDate == nil }
            ActiveDashboardView(
                startedPrograms: started,
                dormantPrograms: dormants,
                selectedId: selectedId,
                teaserSession: teaserSessionFixture,
                upcomingSessions: upcomingSessionsFixture,
                regenBadges: [:],
                onSelectProgram: { _ in },
                onTapStartSession: { _ in },
                onTapProgram: { _ in },
                onDeleteProgram: { _ in },
                onTapReplanify: { _ in }
            )
            .padding(16)
        }
        .background(Color.coachingBackground.ignoresSafeArea())
    }

    /// **Story 3.15 v4 (Sophie 2026-05-21)** — fixture liste des séances
    /// suivantes affichée sous la card focale. Démontre la section "Séances"
    /// avec plusieurs items + le badge sport déduit pour Triathlon.
    private var upcomingSessionsFixture: [PersistedSession] {
        switch scenario {
        case .mixed:
            // **Story 3.15 v6** — sessions multi-sport pour le programme
            // Triathlon focal. Vérifie visuellement l'heuristique :
            //   - Bike FTP-Z2 → cycling (vert) — bug v5 fix : "z2" retiré des
            //     keywords running
            //   - Swim — endurance EN1 → swimming (cyan)
            //   - Run Daniels-E → running (bleu)
            return [
                makeSession(name: "Bike FTP-Z2 — sortie endurance", week: 1, day: 2, dur: 70),
                makeSession(name: "Swim — endurance EN1 + respiration", week: 1, day: 3, dur: 50),
                makeSession(name: "Run Daniels-E — endurance", week: 2, day: 1, dur: 45),
                makeSession(name: "Bike FTP-Z2 — sortie endurance", week: 2, day: 3, dur: 85),
                makeSession(name: "Swim — drills technique", week: 2, day: 5, dur: 45),
                makeSession(name: "Run Daniels-E — fractionné", week: 3, day: 1, dur: 50)
            ]
        default:
            return []
        }
    }

    /// **Story 3.15 raffinement 2026-05-21** — fixture teaser N+1 du programme
    /// sélectionné. Démontre l'affichage de la séance suivante sous la card
    /// focale. Nil pour les scenarios où ce n'est pas pertinent.
    private var teaserSessionFixture: PersistedSession? {
        switch scenario {
        case .mixed:
            return makeSession(name: "Sortie longue 1h", week: 2, day: 5, dur: 60)
        case .lateWithReplanify:
            return makeSession(name: "Footing récup 30 min", week: 1, day: 5, dur: 30)
        default:
            return nil
        }
    }

    private var programs: [ProgramSummary] {
        switch scenario {
        case .mixed:
            return [
                // **Story 3.15 v6 (Sophie 2026-05-21)** — Triathlon en focal pour
                // valider visuellement l'heuristique multi-sport
                // (`SessionSportInference`). La card focale prendra la couleur
                // running car la nextSession est "Run Daniels-E".
                makeProgram(
                    id: idTriathlon, sport: .triathlon, templateName: "Triathlon Sprint",
                    weekStartDate: Date().addingTimeInterval(-7 * 86_400),
                    currentWeek: 1, weekCompleted: 0, weekTotal: 3,
                    totalCompleted: 0, totalSessions: 12,
                    nextSession: makeSession(name: "Run Daniels-E — sortie endurance", week: 1, day: 1, dur: 40),
                    lastUpdated: Date().addingTimeInterval(-1800)
                ),
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

    /// **Story 3.15 v6 (Sophie 2026-05-21)** — selectedId par défaut sur
    /// Triathlon pour le scenario `.mixed` (démontre l'heuristique multi-sport).
    /// Pour les autres scénarios qui n'ont pas de Triathlon, fallback idRunning.
    private var selectedId: UUID {
        scenario == .mixed ? idTriathlon : idRunning
    }

    // IDs fixes pour reproductibilité (le carrousel sélectionne toujours le running).
    private var idRunning: UUID { UUID(uuidString: "11111111-1111-1111-1111-111111111111")! }
    private var idCycling: UUID { UUID(uuidString: "22222222-2222-2222-2222-222222222222")! }
    private var idTriathlon: UUID { UUID(uuidString: "33333333-3333-3333-3333-333333333333")! }

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
            warmup: "10 min échauffement", exercises: [], cooldown: "5 min retour au calme"
        )
    }
}

// MARK: - Story 3.13 Phase E — Q2 multi-choice scenarios

/// Container minimaliste rendant la `QuestionAnswerOptionsView` sur la Q2 du
/// `UniversalQuestionnaire(sportCode:)` avec une pré-sélection injectée
/// directement (le `@State` privé de `QuestionAnswerOptionsView` n'est pas
/// accessible donc on reproduit ici la même logique via un wrapper qui force
/// l'état initial via `selection`). Permet à l'agent ui-reviewer de screenshot
/// le grisage matrice + paires incompatibles + exclusif sans avoir à taper.
private struct Q2MultiChoiceScenarioView: View {
    let sportCode: String
    let preselected: [String]

    var body: some View {
        let q = UniversalQuestionnaire(sportCode: sportCode).q2Goal
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(LocalizedStringKey(q.textKey))
                    .font(.title3.weight(.semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                Q2MultiChoiceFixtureBody(
                    question: q,
                    sportCode: sportCode,
                    preselected: Set(preselected)
                )
            }
            .padding(16)
        }
        .background(Color.coachingBackground.ignoresSafeArea())
    }
}

/// Phase E — Container pour les sports à catalogue structurellement exclusif
/// (`strengthTraining`, `triathlon`). Rend la Q2 avec `QuestionAnswerOptionsView`
/// directement (qui détecte `isCycleExclusiveSport` et affiche la hint pédagogique
/// "Choisis ton cycle actuel..." sous les options single-choice).
private struct Q2SingleCycleScenarioView: View {
    let sportCode: String
    @State private var freeTextDraft: String = ""

    var body: some View {
        let q = UniversalQuestionnaire(sportCode: sportCode).q2Goal
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(LocalizedStringKey(q.textKey))
                    .font(.title3.weight(.semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                QuestionAnswerOptionsView(
                    question: q,
                    onAnswer: { _ in /* noop ui-review */ },
                    freeTextDraft: $freeTextDraft,
                    isLocked: false,
                    sportCode: sportCode
                )
            }
            .padding(16)
        }
        .background(Color.coachingBackground.ignoresSafeArea())
    }
}

/// Reproduit le rendu visuel de `QuestionAnswerOptionsView` (cases à cocher +
/// grisage matrice + bouton Confirmer) pour un set pré-sélectionné. NE PAS
/// utiliser en prod : c'est un fixture pour ui-reviewer uniquement.
private struct Q2MultiChoiceFixtureBody: View {
    let question: QuestionnaireQuestion
    let sportCode: String
    @State var preselected: Set<String>

    var body: some View {
        VStack(spacing: 8) {
            Text("questionnaire.universal.q2.hint.multi")
                .font(.footnote)
                .foregroundStyle(Color.coachingTextSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 4)

            ForEach(question.options) { option in
                let isSelected = preselected.contains(option.code)
                let isDisabledByMatrix = GoalCompatibilityMatrix.isDisabled(
                    option: option.code,
                    given: preselected,
                    sportCode: sportCode
                )
                HStack {
                    Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                        .foregroundStyle(isSelected ? Color.coachingPrimary : Color.coachingTextSecondary)
                    Text(LocalizedStringKey(option.labelKey))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(Color.coachingCard)
                .foregroundStyle(Color.coachingTextPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .opacity(isDisabledByMatrix ? 0.35 : 1.0)
            }

            Text("questionnaire.options.confirm")
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(preselected.isEmpty ? Color.coachingDisabled : Color.coachingPrimary)
                .foregroundStyle(Color.coachingOnPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }
}

// MARK: - Story 3.14 — SportAvatarScenarioView

/// Story 3.14 — Rend un échantillon de bulles Léon avec l'avatar sport contextuel
/// + typing indicator + bulle user. Permet à l'agent ui-reviewer de vérifier que
/// l'icône sport est correctement mappée (running, swimming, triathlon, etc.) et
/// que la couleur de fond `Color.coachingSport(forCode:)` matche le sport.
private struct SportAvatarScenarioView: View {
    let sportCode: String

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ChatBubbleView(
                    sender: .leon,
                    textRaw: "questionnaire.universal.intro",
                    avatarStyle: .sport(code: sportCode)
                )
                ChatBubbleView(
                    sender: .leon,
                    textRaw: "questionnaire.universal.q1.text",
                    avatarStyle: .sport(code: sportCode)
                )
                ChatBubbleView(
                    sender: .user,
                    textRaw: "questionnaire.universal.q1.option.beginner"
                )
                ChatBubbleView(
                    sender: .leon,
                    textRaw: "questionnaire.\(sportCode).q2.text",
                    avatarStyle: .sport(code: sportCode)
                )
                HStack(alignment: .top, spacing: 8) {
                    SportAvatarView(sportCode: sportCode, size: 32)
                    TypingIndicatorView()
                    Spacer(minLength: 40)
                }
            }
            .padding(16)
        }
        .background(Color.coachingBackground.ignoresSafeArea())
    }
}

// MARK: - Story 3.17 Phase 1 — SessionDetailGlossaryScenarioView

/// Container pour Story 3.17 — affiche `SessionDetailView` avec une séance
/// running enrichie en termes glossaire pour vérifier visuellement le rendu
/// inline (underline pointillé + couleur primary + tap popover définition) +
/// le toast de découvrabilité.
private struct SessionDetailGlossaryScenarioView: View {
    init() {
        // Reset le flag tooltip pour garantir qu'il s'affiche à chaque ouverture
        // du scenario (capture visuelle reproductible). `shouldPresent` autorise
        // le scenario "ui_review_session_detail_glossary" en exception du skip
        // général UI_TEST_SCENARIO.
        GlossaryDiscoveryTooltip.resetForTesting()
    }

    var body: some View {
        SessionDetailView(
            session: glossaryRichSession,
            week: glossaryRichWeek,
            program: AdaptedProgramPreviewFixtures.happyPath
        )
    }

    private var glossaryRichWeek: AdaptedWeek {
        AdaptedWeek(
            weekNumber: 3,
            theme: "Semaine de tempo et intervals — focus threshold et cadence",
            goal: "Travailler le seuil lactique",
            sessions: []
        )
    }

    private var glossaryRichSession: AdaptedSession {
        AdaptedSession(
            day: 2,
            name: "Tempo continu + strides",
            durationMinutes: 55,
            type: .endurance,
            warmup: "15 min footing très lent en Z2 (cadence souple ~175 ppm) puis 6×80m strides progressifs avec récupération marche complète. Travail technique pour préparer le tempo.",
            exercises: [
                AdaptedExercise(
                    name: "Tempo continu",
                    originalName: "Tempo continu",
                    sets: 1,
                    reps: nil,
                    duration: "25 min",
                    restSeconds: 0,
                    notes: "Tiens un effort soutenu mais conversationnel court — c'est l'allure tempo (RPE 6-7). En dessous du threshold mais juste sous l'inconfort. Tu dois sentir le lactate monter doucement vers la fin sans saturation.",
                    targetZone: "Daniels-T",
                    volumeAxis: .duration,
                    wasSubstituted: false,
                    substitutionReason: nil
                ),
                AdaptedExercise(
                    name: "Récupération active",
                    originalName: "Récupération active",
                    sets: 1,
                    reps: nil,
                    duration: "5 min",
                    restSeconds: 0,
                    notes: "Footing très facile Z1-Z2 pour évacuer le lactate avant les intervals suivants. La cadence reste haute, l'allure très lente.",
                    targetZone: "Z2",
                    volumeAxis: .duration,
                    wasSubstituted: false,
                    substitutionReason: nil
                ),
                AdaptedExercise(
                    name: "Intervals courts VO2max",
                    originalName: "Intervals VO2max 6×400m",
                    sets: 6,
                    reps: "400m",
                    duration: nil,
                    restSeconds: 90,
                    notes: "Effort intense type Daniels-I pour cibler le VO2max. Cadence rapide, foulée explosive proche du plyometric. Si trop dur en série 5-6, raccourcis plutôt que ralentir.",
                    targetZone: "Daniels-I",
                    volumeAxis: .reps,
                    wasSubstituted: false,
                    substitutionReason: nil
                ),
            ],
            cooldown: "10 min footing très lent + étirements doux. Idéal pour évacuer le lactate accumulé pendant les intervals et préparer la récupération."
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
