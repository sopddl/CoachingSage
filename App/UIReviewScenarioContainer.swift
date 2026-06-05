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
import TemplateLoader

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
        case "ui_review_dashboard_active_one_program":
            // **Story 3.27 Phase C** — carrousel à 1 seule card (1 démarré, 0
            // dormant). Vérifie qu'une card seule ne s'étire pas anormalement.
            DashboardActiveScenarioView(scenario: .oneStarted)
        case "ui_review_dashboard_active_three_programs":
            // **Story 3.27 Phase C** — carrousel plein (3 démarrés, 0 dormant).
            // Vérifie le scroll horizontal + sélection 1re card + truncation
            // titres composites (« Triathlon — ... »).
            DashboardActiveScenarioView(scenario: .threeStarted)
        case "ui_review_dashboard_empty":
            // **Story 3.15 v7 (Sophie 2026-05-21)** — mode `.empty` simplifié :
            // icone hero + titre + sous-titre + CTA "Crée mon premier programme".
            // **Story 3.22-F-bis** — variante `.noPrograms` (cas par défaut).
            EmptyDashboardView(
                state: .noPrograms,
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
        case "ui_review_routine_renewal_due":
            // **Story 3.31** — bannière renouvellement routine J−14 (semaine 11/12)
            // non-bloquante + pastille carrousel « Suite dispo ».
            DashboardActiveScenarioView(scenario: .routineRenewalDue)
        case "ui_review_routine_renewal_completed":
            // **Story 3.31** — bannière renouvellement routine cycle terminé
            // (proéminente dorée) — évite le dashboard vide.
            DashboardActiveScenarioView(scenario: .routineRenewalCompleted)
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
        case "ui_review_questionnaire_thread_edit":
            // **Story 3.30** — fil de chat questionnaire avec 3 réponses déjà
            // données (Q1/Q2/Q3) → bulles user éditables (crayon + tap "remonter
            // le fil"). Permet de screenshot la découvrabilité de l'affordance
            // d'édition sans dépendre des taps live (silent-drop simu).
            QuestionnaireThreadEditScenarioView()
        case "ui_review_questionnaire_empty":
            // **Story 3.30 polish #3** — état pré-démarrage du questionnaire en
            // .sheet + .alert recovery. Placeholder plein (avatar + spinner) →
            // fond uniforme propre derrière l'alerte (fix de la "barre au milieu"
            // photo 5 Sophie : avant, le VStack vide se rétractait → bande moche).
            QuestionnaireEmptyStateScenarioView()
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
        case "ui_review_session_detail_v3_illustrations":
            // **Story 3.19 Jalon 1+2a** — SessionDetailView avec séance strength
            // étendue couvrant les patterns pilotes (squat / hinge / pullVertical
            // / core plank) + patterns Jalon 2a (push H/V / pull H / lunge /
            // plyo / mobility). Cibles : strip illustrations dans la card exo.
            SessionDetailIllustrationsScenarioView()
        case "ui_review_session_detail_v3_running":
            // **Story 3.19 Jalon 2a** — SessionDetailView running pour valider
            // les illus running endurance + interval.
            SessionDetailRunningScenarioView()
        case "ui_review_session_detail_hub_yoga":
            // **Story 3.32 (HUB)** — SessionDetailView yoga : valide la grille 3
            // cellules AGNOSTIQUE sans case vide (pas de "Zone —") + Format
            // "N postures" + aperçu scannable. Cas AC11 "aucune cellule vide yoga".
            SessionDetailHubYogaScenarioView()
        case "ui_review_session_focus_strength":
            // **Story 3.33 (FOCUS)** — mode exécution plein écran strength : barre
            // top (fermer + "1/4" + points), warmup en 1ʳᵉ étape, card exo riche
            // (illustration + métriques + notes + "Comment l'exécuter ?"), bouton
            // "✓ Fait", nav bas Précédent/Passer/Suivant.
            SessionFocusView(
                session: SessionFocusStrengthFixture.session,
                week: SessionFocusStrengthFixture.week,
                program: SessionFocusStrengthFixture.program
            )
        case "ui_review_session_focus_single":
            // **Story 3.33 (AC11)** — cas séance à 1 seul exo : points/compteur/nav
            // se comportent bien (nav désactivée aux extrémités, pas de crash).
            SessionFocusView(
                session: SessionFocusSingleFixture.session,
                week: SessionFocusSingleFixture.week,
                program: SessionFocusSingleFixture.program
            )
        case "ui_review_session_focus_hiit":
            // **Story 3.34 (FOCUS Minuté)** — HIIT : gros compte à rebours, pré-annonce
            // « Prochain : … » (anti-Decathlon), progression « Tour T/R », Pause/Passer.
            SessionFocusView(
                session: SessionFocusHIITFixture.session,
                week: SessionFocusHIITFixture.week,
                program: SessionFocusHIITFixture.program
            )
        case "ui_review_session_focus_yoga":
            // **Story 3.34 (FOCUS Minuté)** — yoga : tenue par posture (avance auto),
            // progression « Posture p/P ».
            SessionFocusView(
                session: SessionFocusYogaFixture.session,
                week: SessionFocusYogaFixture.week,
                program: SessionFocusYogaFixture.program
            )
        case "ui_review_session_focus_runwalk":
            // **Story 3.35d** — run/walk décomposé : segments « Course 1 » / « Marche 1 »
            // alternés, gros temps mm:ss, toggle son haut-droite. Reproduit le cas
            // device de Sophie (Bloc run/walk sets=8).
            SessionFocusView(
                session: SessionFocusRunWalkFixture.session,
                week: SessionFocusRunWalkFixture.week,
                program: SessionFocusRunWalkFixture.program
            )
        case "ui_review_session_focus_audio":
            // **Story 3.35 (FOCUS Audio)** — running : écran glançable (gros compte à
            // rebours + bloc courant) + toggle son haut-droite (voix H/F = profil).
            // La voix/ducking sont validés sur device (hand-off).
            SessionFocusView(
                session: SessionFocusAudioFixture.session,
                week: SessionFocusAudioFixture.week,
                program: SessionFocusAudioFixture.program
            )
        case "ui_review_music_app_picker":
            // **Story 3.35c** — sélecteur d'appli musique (onboarding/profil) + la
            // section musique de la séance qui n'ouvre QUE l'app choisie. Préréglée
            // sur Deezer pour valider l'ajout Deezer + le rendu mono-app.
            MusicAppPickerScenarioView()
        case "ui_review_illustrations_showcase":
            // **Story 3.19 Jalon 2b** — showcase TOUTES les illustrations
            // (15 patterns) en grille pour screenshot HTML overview Sophie.
            IllustrationsShowcaseScenarioView()
        case "ui_review_illustrations_story_323":
            // **Story 3.23 Lot 0** — ne montre QUE les 9 nouveaux dessins
            // (refonte rigoureuse 2026-05-25). Permet screenshot sans scroll.
            IllustrationsStory323ScenarioView()
        case "ui_review_illustrations_story_323_lot1":
            // **Story 3.23 Lot 1** — 5 SUSPECT V1 à valider (Arbre, Enfant,
            // Bateau, Lunge, Mobility quad). Screenshot focalisé pour décider
            // OK / retouche sans scroll.
            IllustrationsStory323Lot1ScenarioView()
        case "ui_review_illustrations_story_323_lots123":
            // **Story 3.23 Lots 1+2+3** — 15 dessins (5 SUSPECT V1 refondus + 5
            // nouveaux yoga haute fréquence + 5 nouveaux strength haute fréquence).
            // Batch validation Sophie 2026-05-25.
            IllustrationsStory323Lots123ScenarioView()
        case "ui_review_illustrations_story_323_lot4":
            // **Story 3.23 Lot 4** — 10 nouvelles poses yoga moyenne fréquence.
            IllustrationsStory323Lot4ScenarioView()
        case "ui_review_illustrations_story_323_lot5":
            // **Story 3.23 Lot 5** — 6 nouveaux patterns strength moyenne fréquence.
            IllustrationsStory323Lot5ScenarioView()
        case "ui_review_illustrations_story_323_lot6":
            // **Story 3.23 Lot 6** — 10 nouvelles poses yoga reste catalogue.
            IllustrationsStory323Lot6ScenarioView()
        case "ui_review_illustrations_story_323_lot7":
            // **Story 3.23 Lot 7** — Triceps pushdown + Lateral raises (finition).
            IllustrationsStory323Lot7ScenarioView()
        case "ui_review_yoga_poc":
            // **POC yoga 2026-06-05 (party D1+D4)** — showcase statique : 3 postures
            // NON cataloguées (doivent prendre la bonne ORIENTATION fallback, plus
            // Warrior I debout systématique) + une posture connue à la taille FOCUS
            // (grossie + centrée). Pour review Sally/Inès sans souci de timing timer.
            YogaPOCScenarioView()
        case let s where s.hasPrefix("ui_review_session_hub_real_"):
            // Tour didactique multi-sports — charge le VRAI template bundlé du
            // sport (pipeline réel TemplateLoader → ProgramAdapter) et rend la
            // 1re séance dans SessionDetailView. Le sport est encodé en suffixe :
            //   ui_review_session_hub_real_<Sport.rawValue>
            //   ex: ..._running, ..._cycling, ..._strength_training, ..._yoga
            RealTemplateHubScenarioView(
                sportRawValue: String(s.dropFirst("ui_review_session_hub_real_".count))
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
        /// **Story 3.31** — routine en semaine 11/12 (J−14) : bannière de
        /// renouvellement « Léon prépare la suite » non-bloquante + pastille
        /// carrousel « Suite dispo ».
        case routineRenewalDue
        /// **Story 3.31** — routine cycle terminé : bannière proéminente dorée
        /// « Cycle terminé — prêt pour la suite ? ».
        case routineRenewalCompleted
        /// **Story 3.27 Phase C** — 1 seul programme démarré, 0 dormant : carrousel
        /// à 1 card (vérifie qu'une card seule reste centrée / pas étirée).
        case oneStarted
        /// **Story 3.27 Phase C** — 3 programmes démarrés, 0 dormant : carrousel
        /// plein (scroll horizontal, sélection sur le 1er).
        case threeStarted
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
                routineRenewalStates: renewalStatesFixture,
                leonTip: leonTipFixture,
                onSelectProgram: { _ in },
                onTapStartSession: { _ in },
                onTapProgram: { _ in },
                onDeleteProgram: { _ in },
                onTapReplanify: { _ in },
                onRenewRoutine: { _ in }
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
        case .oneStarted, .threeStarted:
            // **Story 3.27 Phase C** — séances running suivantes (programme
            // « Couch to 5k » sélectionné) pour démontrer la liste sous la focale.
            return [
                makeSession(name: "Sortie longue 45 min", week: 2, day: 5, dur: 45),
                makeSession(name: "Footing récup 25 min", week: 3, day: 1, dur: 25),
                makeSession(name: "Fractionné 6×400m", week: 3, day: 3, dur: 40),
                makeSession(name: "Sortie longue 50 min", week: 3, day: 5, dur: 50)
            ]
        case .lateWithReplanify:
            // **Story 3.27 Phase C** — séances running après la focale en retard.
            return [
                makeSession(name: "Footing endurance 35 min", week: 1, day: 5, dur: 35),
                makeSession(name: "Sortie longue 50 min", week: 2, day: 2, dur: 50),
                makeSession(name: "Fractionné 8×400m", week: 2, day: 4, dur: 45)
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

    /// **Story 3.29** — conseil Léon fixture pour démontrer la carte qui remplit
    /// la bande sous la liste séances (le VM n'est pas monté dans le scénario,
    /// on injecte un tip directement).
    private var leonTipFixture: LeonTip? {
        switch scenario {
        case .mixed:                    return .streak(days: 4, nextType: .endurance)
        case .oneStarted, .threeStarted: return .sessionsLeft(count: 3, nextType: .interval)
        case .lateWithReplanify:        return .late(nextType: .endurance)
        case .weekCompleted:            return .weekCompleted
        case .programCompleted:         return .programCompleted
        default:                        return .generic
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
        case .oneStarted:
            // **Story 3.27 Phase C** — 1 programme démarré seul. Carrousel à 1 card.
            return [
                makeProgram(
                    id: idRunning, sport: .running, templateName: "Couch to 5k — Semaine 2",
                    weekStartDate: Date().addingTimeInterval(-7 * 86_400),
                    currentWeek: 2, weekCompleted: 1, weekTotal: 3,
                    totalCompleted: 4, totalSessions: 12,
                    nextSession: makeSession(name: "Footing 30 min", week: 2, day: 3, dur: 30),
                    lastUpdated: Date().addingTimeInterval(-3600)
                )
            ]
        case .threeStarted:
            // **Story 3.27 Phase C** — 3 programmes démarrés, 0 dormant. Carrousel
            // plein (3 cards, scroll horizontal). Sélection par défaut = running.
            return [
                makeProgram(
                    id: idRunning, sport: .running, templateName: "Couch to 5k — Semaine 2",
                    weekStartDate: Date().addingTimeInterval(-7 * 86_400),
                    currentWeek: 2, weekCompleted: 1, weekTotal: 3,
                    totalCompleted: 4, totalSessions: 12,
                    nextSession: makeSession(name: "Footing 30 min", week: 2, day: 3, dur: 30),
                    lastUpdated: Date().addingTimeInterval(-1800)
                ),
                makeProgram(
                    id: idCycling, sport: .cycling, templateName: "Cycling Endurance",
                    weekStartDate: Date().addingTimeInterval(-14 * 86_400),
                    currentWeek: 3, weekCompleted: 2, weekTotal: 4,
                    totalCompleted: 8, totalSessions: 16,
                    nextSession: makeSession(name: "Sortie longue 90 min", week: 3, day: 5, dur: 90),
                    lastUpdated: Date().addingTimeInterval(-3600)
                ),
                makeProgram(
                    id: idTriathlon, sport: .triathlon, templateName: "Triathlon Sprint",
                    weekStartDate: Date().addingTimeInterval(-7 * 86_400),
                    currentWeek: 1, weekCompleted: 0, weekTotal: 3,
                    totalCompleted: 0, totalSessions: 12,
                    nextSession: makeSession(name: "Run Daniels-E — endurance", week: 1, day: 1, dur: 40),
                    lastUpdated: Date().addingTimeInterval(-7200)
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
        case .routineRenewalDue:
            // **Story 3.31** — routine en semaine 11/12 (J−14), encore des séances.
            return [
                makeProgram(
                    id: idRunning, sport: .running, templateName: "Routine running 3 mois",
                    weekStartDate: Date().addingTimeInterval(-70 * 86_400),
                    currentWeek: 11, weekCompleted: 1, weekTotal: 3,
                    totalCompleted: 30, totalSessions: 36,
                    nextSession: makeSession(name: "Footing 40 min", week: 11, day: 2, dur: 40),
                    lastUpdated: Date().addingTimeInterval(-3600),
                    durationMode: .routineCyclic
                )
            ]
        case .routineRenewalCompleted:
            // **Story 3.31** — routine cycle terminé : plus de séance dispo.
            return [
                makeProgram(
                    id: idRunning, sport: .running, templateName: "Routine running 3 mois",
                    weekStartDate: Date().addingTimeInterval(-84 * 86_400),
                    currentWeek: 12, weekCompleted: 3, weekTotal: 3,
                    totalCompleted: 36, totalSessions: 36,
                    nextSession: nil,
                    lastUpdated: Date().addingTimeInterval(-3600),
                    durationMode: .routineCyclic
                )
            ]
        }
    }

    /// **Story 3.31** — états de renouvellement de routine injectés pour les
    /// scénarios bannière (le VM n'est pas monté ici).
    private var renewalStatesFixture: [UUID: RoutineRenewalState] {
        switch scenario {
        case .routineRenewalDue:       return [idRunning: .due(cycleNumber: 1)]
        case .routineRenewalCompleted: return [idRunning: .cycleCompleted(cycleNumber: 2)]
        default:                       return [:]
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
            nextSessionIsLate: nextSessionIsLate,
            goalCode: nil,
            secondaryGoals: [],
            isUserRenamed: false
        )
    }

    private func makeSession(name: String, week: Int, day: Int, dur: Int) -> PersistedSession {
        PersistedSession(
            id: UUID(),
            weekNumber: week, weekTheme: LocalizedText(fr: "Sem \(week)"), weekGoal: "Endurance",
            day: day, name: LocalizedText(fr: name), durationMinutes: dur, type: .endurance,
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

// MARK: - Story 3.30 — QuestionnaireThreadEditScenarioView

/// Story 3.30 — fil de chat questionnaire running avec 3 réponses déjà données.
/// Les bulles user portent `onEdit` (crayon + tap "remonter le fil") → permet de
/// juger visuellement la découvrabilité de l'affordance d'édition + la locale
/// FR/EN, sans dépendre des taps live (silent-drop simu).
private struct QuestionnaireThreadEditScenarioView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ChatBubbleView(sender: .leon, textRaw: "questionnaire.universal.intro", avatarStyle: .sport(code: "running"))
                ChatBubbleView(sender: .leon, textRaw: "questionnaire.universal.q1.text", avatarStyle: .sport(code: "running"))
                ChatBubbleView(sender: .user, textRaw: "questionnaire.universal.q1.option.regular", onEdit: {})
                ChatBubbleView(sender: .leon, textRaw: "questionnaire.running.q2.text", avatarStyle: .sport(code: "running"))
                ChatBubbleView(sender: .user, textRaw: "questionnaire.running.q2.option.10k|questionnaire.running.q2.option.half_marathon", onEdit: {})
                ChatBubbleView(sender: .leon, textRaw: "questionnaire.universal.q3.text", avatarStyle: .sport(code: "running"))
                ChatBubbleView(sender: .user, textRaw: "questionnaire.universal.q3.option.3", onEdit: {})
                ChatBubbleView(sender: .leon, textRaw: "questionnaire.universal.q4.text", avatarStyle: .sport(code: "running"))
            }
            .padding(16)
        }
        .background(Color.coachingBackground.ignoresSafeArea())
    }
}

// MARK: - Story 3.30 polish #3 — QuestionnaireEmptyStateScenarioView

/// Reproduit FIDÈLEMENT le contexte réel : questionnaire présenté en `.sheet`
/// avec l'`.alert` de recovery par-dessus, dans son état pré-démarrage. Rend le
/// placeholder plein (avatar + spinner) = le fix #3 → fond uniforme derrière
/// l'alerte (vérifie l'absence de la "barre au milieu").
private struct QuestionnaireEmptyStateScenarioView: View {
    var body: some View {
        Color.coachingBackground.ignoresSafeArea()
            .sheet(isPresented: .constant(true)) {
                NavigationStack {
                    VStack(spacing: 12) {
                        SportAvatarView(sportCode: "running", size: 56)
                        ProgressView().tint(Color.coachingPrimary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.coachingBackground.ignoresSafeArea())
                    .navigationTitle(Text("questionnaire.title"))
                    .navigationBarTitleDisplayMode(.inline)
                    .alert(Text("questionnaire.recovery.prompt"), isPresented: .constant(true)) {
                        Button("questionnaire.recovery.resume") {}
                        Button("questionnaire.recovery.restart", role: .destructive) {}
                    }
                }
            }
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

// MARK: - Story 3.19 Jalon 1 — SessionDetailIllustrationsScenarioView

/// Container Story 3.19 Jalon 1 — séance strength avec 4 exos couvrant les
/// patterns pilotes (squat, hinge, pullVertical, core). Affiche le strip
/// d'illustrations dans la card exo pour validation visuelle Sophie #1.
private struct SessionDetailIllustrationsScenarioView: View {
    var body: some View {
        SessionDetailView(
            session: strengthSession,
            week: strengthWeek,
            program: strengthProgram
        )
    }

    private var strengthWeek: AdaptedWeek {
        AdaptedWeek(
            weekNumber: 2,
            theme: "Force générale — patterns fondamentaux",
            goal: "Travailler les 4 patterns biomécaniques majeurs",
            sessions: []
        )
    }

    private var strengthProgram: AdaptedProgram {
        AdaptedProgram(
            templateId: "strength-pilot-fixture",
            sport: .strengthTraining,
            level: .beginner,
            appliedAt: Date(),
            weeks: [strengthWeek],
            appliedRules: [],
            requiresAIAssist: false
        )
    }

    private var strengthSession: AdaptedSession {
        AdaptedSession(
            day: 1,
            name: "Full body fondamentaux",
            durationMinutes: 50,
            type: .strength,
            warmup: "5 min vélo facile + mobilité épaules + activation glutes (band)",
            exercises: [
                AdaptedExercise(
                    name: "Goblet squat (pattern squat)",
                    originalName: "Goblet squat",
                    sets: 4,
                    reps: "8",
                    restSeconds: 90,
                    notes: "Descente contrôlée 3 secondes, poussée par les talons. Genoux dans l'axe des pieds.",
                    targetZone: nil
                ),
                AdaptedExercise(
                    name: "Romanian Deadlift haltères (pattern hinge)",
                    originalName: "Romanian Deadlift haltères",
                    sets: 3,
                    reps: "10",
                    restSeconds: 90,
                    notes: "Le mouvement vient de la hanche, pas du dos. Bassin recule, ischio-jambiers s'étirent.",
                    targetZone: nil
                ),
                AdaptedExercise(
                    name: "Pull-up assisté (pattern pull vertical)",
                    originalName: "Pull-up assisté",
                    sets: 4,
                    reps: "6",
                    restSeconds: 120,
                    notes: "Engage les omoplates en premier. Menton au-dessus de la barre, descente contrôlée.",
                    targetZone: nil
                ),
                AdaptedExercise(
                    name: "Plank latéral",
                    originalName: "Plank latéral",
                    sets: 3,
                    duration: "30s",
                    restSeconds: 60,
                    notes: "Le side plank (planche latérale) renforce les obliques. Ligne droite épaules-bassin-talons, un seul avant-bras au sol. Pas de bassin qui tombe.",
                    targetZone: nil
                ),
                AdaptedExercise(
                    name: "Pompe diamant (pattern push horizontal)",
                    originalName: "Pompe diamant",
                    sets: 3,
                    reps: "10",
                    restSeconds: 60,
                    notes: "Mains rapprochées en triangle sous la poitrine. Coudes contre le corps. Descente contrôlée jusqu'à effleurer.",
                    targetZone: nil
                ),
                AdaptedExercise(
                    name: "Overhead press haltères (pattern push vertical)",
                    originalName: "Overhead press haltères",
                    sets: 4,
                    reps: "8",
                    restSeconds: 90,
                    notes: "Verrouille le gainage. Haltères des épaules au-dessus de la tête, bras tendus. Pas de cambrure lombaire.",
                    targetZone: nil
                ),
                AdaptedExercise(
                    name: "Bent-over row barre (pattern pull horizontal)",
                    originalName: "Bent-over row barre",
                    sets: 4,
                    reps: "10",
                    restSeconds: 90,
                    notes: "Tronc penché 45°, dos droit. Tire la barre vers le bas du sternum en serrant les omoplates. Coudes proches du corps.",
                    targetZone: nil
                ),
                AdaptedExercise(
                    name: "Fente avant alternée (pattern lunge)",
                    originalName: "Fente avant alternée",
                    sets: 3,
                    reps: "12 (6/jambe)",
                    restSeconds: 60,
                    notes: "Genou avant dans l'axe du pied. Genou arrière descend vers le sol sans toucher. Buste droit, regard horizon.",
                    targetZone: nil
                ),
                AdaptedExercise(
                    name: "Jump squat (pattern plyo)",
                    originalName: "Jump squat",
                    sets: 3,
                    reps: "8",
                    restSeconds: 90,
                    notes: "Squat puis saut explosif vertical. Atterrissage moelleux genoux fléchis — pas de bruit à la réception.",
                    targetZone: nil
                ),
                AdaptedExercise(
                    name: "Étirement quadriceps (pattern mobility)",
                    originalName: "Étirement quadriceps",
                    sets: 2,
                    duration: "30s/jambe",
                    restSeconds: 0,
                    notes: "Talon vers le fessier, main qui tient le pied. Bassin neutre, ne pas cambrer le dos. Respiration profonde.",
                    targetZone: nil
                ),
            ],
            cooldown: "Étirements quadriceps + ischios + dorsaux 5 min"
        )
    }
}

// MARK: - Story 3.19 Jalon 2a — SessionDetailRunningScenarioView

/// Container Story 3.19 Jalon 2a — séance running avec exos couvrant les
/// patterns running (endurance + interval). Validation visuelle drift Sophie #2.
private struct SessionDetailRunningScenarioView: View {
    var body: some View {
        SessionDetailView(
            session: runSession,
            week: runWeek,
            program: runProgram
        )
    }

    private var runWeek: AdaptedWeek {
        AdaptedWeek(
            weekNumber: 3,
            theme: "Endurance + qualité fractionné",
            goal: "Allure de course soutenue",
            sessions: []
        )
    }

    private var runProgram: AdaptedProgram {
        AdaptedProgram(
            templateId: "running-jalon2a-fixture",
            sport: .running,
            level: .regular,
            appliedAt: Date(),
            weeks: [runWeek],
            appliedRules: [],
            requiresAIAssist: false
        )
    }

    private var runSession: AdaptedSession {
        AdaptedSession(
            day: 2,
            name: "Endurance + fractionné court",
            durationMinutes: 50,
            type: .interval,
            warmup: "10 min footing très lent en Z2 puis 4 strides progressifs",
            exercises: [
                AdaptedExercise(
                    name: "Footing endurance",
                    originalName: "Footing endurance",
                    duration: "20 min",
                    notes: "Allure de conversation Z2, cadence souple ~175 ppm.",
                    targetZone: "Daniels-E"
                ),
                AdaptedExercise(
                    name: "Fractionné 8 × 400m",
                    originalName: "Fractionné 8 × 400m",
                    sets: 8,
                    reps: "400m",
                    restSeconds: 90,
                    notes: "Allure Daniels-I, cadence rapide. Récup trot relâché entre.",
                    targetZone: "Daniels-I"
                ),
            ],
            cooldown: "10 min footing très lent + étirements"
        )
    }
}

// MARK: - Story 3.32 (HUB) — SessionDetailHubYogaScenarioView

/// SessionDetailView yoga pour valider le HUB 3.32 : grille 3 cellules sans case
/// vide (le yoga n'a pas de zone d'intensité → l'ancienne grille affichait
/// "Zone —"), Format "N postures", aperçu scannable + phrase d'intention.
private struct SessionDetailHubYogaScenarioView: View {
    var body: some View {
        SessionDetailView(session: yogaSession, week: yogaWeek, program: yogaProgram)
    }

    private var yogaWeek: AdaptedWeek {
        AdaptedWeek(weekNumber: 1, theme: "Mobilité & respiration", goal: "Ancrage du souffle", sessions: [])
    }

    private var yogaProgram: AdaptedProgram {
        AdaptedProgram(
            templateId: "yoga-hub-fixture",
            sport: .yoga, level: .beginner, appliedAt: Date(),
            weeks: [yogaWeek], appliedRules: [], requiresAIAssist: false
        )
    }

    private var yogaSession: AdaptedSession {
        AdaptedSession(
            day: 1, name: "Flow doux du matin", durationMinutes: 45, type: .mobility,
            warmup: "5 min respiration Dirgha assise",
            exercises: [
                AdaptedExercise(name: "Chien tête en bas", originalName: "Chien tête en bas", duration: "1 min"),
                AdaptedExercise(name: "Guerrier I", originalName: "Guerrier I", duration: "45 s"),
                AdaptedExercise(name: "Arbre", originalName: "Arbre", duration: "30 s"),
                AdaptedExercise(name: "Posture de l'enfant", originalName: "Posture de l'enfant", duration: "2 min")
            ],
            cooldown: "5 min Savasana"
        )
    }
}

// MARK: - Tour didactique multi-sports — vrai template bundlé

/// Charge le VRAI template bundlé du sport demandé via le pipeline réel
/// (`TemplateLoader.loadAll` → `ProgramAdapter.adapt`) et rend la 1re séance
/// réelle dans `SessionDetailView`. Permet de tester le contenu didactique
/// authentique (titres, exercices, échauffement/récup, jargon) des 10 sports
/// sans dépendre de la navigation (taps de bord non fiables au bridge).
private struct RealTemplateHubScenarioView: View {
    let sportRawValue: String

    @State private var program: AdaptedProgram?
    @State private var session: AdaptedSession?
    @State private var week: AdaptedWeek?
    @State private var status: String = "Chargement…"

    var body: some View {
        Group {
            if let program, let session, let week {
                SessionDetailView(session: session, week: week, program: program)
            } else {
                VStack(spacing: 12) {
                    ProgressView()
                    Text(verbatim: status)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
            }
        }
        .task { await load() }
    }

    private func load() async {
        guard let sport = Sport(rawValue: sportRawValue) else {
            status = "Sport inconnu : \(sportRawValue)\nValides : \(Sport.allCases.map(\.rawValue).joined(separator: ", "))"
            return
        }
        do {
            let all = try await TemplateLoader.loadAll()
            let forSport = all.filter { $0.sport == sport }
            guard let template = forSport.first(where: { $0.level == .beginner }) ?? forSport.first else {
                status = "Aucun template bundlé pour \(sport.rawValue)"
                return
            }
            let adapted = ProgramAdapter().adapt(
                template: template,
                sportProfile: AdapterSportProfile(
                    constraints: [],
                    equipment: [],
                    frequencyPerWeek: 3,
                    sportCode: sport.rawValue,
                    durationMode: .routineCyclic
                ),
                coachingProfile: AdapterCoachingProfile(requiresMedicalClearance: false)
            )
            guard let w = adapted.weeks.first, let s = w.sessions.first else {
                status = "Template \(template.id) : aucune séance générée"
                return
            }
            self.program = adapted
            self.week = w
            self.session = s
        } catch {
            status = "Erreur chargement/adaptation \(sport.rawValue) : \(error)"
        }
    }
}

// MARK: - Story 3.33 (FOCUS) — fixtures mode exécution

enum SessionFocusStrengthFixture {
    static let week = AdaptedWeek(weekNumber: 2, theme: "Force générale", goal: "Patterns fondamentaux", sessions: [])
    static let program = AdaptedProgram(
        templateId: "focus-strength-fixture", sport: .strengthTraining, level: .beginner,
        appliedAt: Date(), weeks: [week], appliedRules: [], requiresAIAssist: false
    )
    static let session = AdaptedSession(
        day: 1, name: "Full body fondamentaux", durationMinutes: 50, type: .strength,
        warmup: "5 min vélo facile + mobilité épaules + activation glutes (band)",
        exercises: [
            AdaptedExercise(name: "Goblet squat (pattern squat)", originalName: "Goblet squat",
                            sets: 4, reps: "8", restSeconds: 90,
                            notes: "Descente contrôlée 3 secondes, poussée par les talons. Genoux dans l'axe des pieds."),
            AdaptedExercise(name: "Romanian Deadlift haltères (pattern hinge)", originalName: "Romanian Deadlift",
                            sets: 3, reps: "10", restSeconds: 90,
                            notes: "Le mouvement vient de la hanche, pas du dos. Bassin recule."),
            AdaptedExercise(name: "Plank latéral", originalName: "Plank latéral",
                            sets: 3, duration: "30s", restSeconds: 60,
                            notes: "Ligne droite épaules-bassin-talons. Pas de bassin qui tombe.")
        ],
        cooldown: "5 min étirements doux du bas du corps"
    )
}

enum SessionFocusSingleFixture {
    static let week = AdaptedWeek(weekNumber: 1, theme: "Découverte", goal: "—", sessions: [])
    static let program = AdaptedProgram(
        templateId: "focus-single-fixture", sport: .running, level: .beginner,
        appliedAt: Date(), weeks: [week], appliedRules: [], requiresAIAssist: false
    )
    static let session = AdaptedSession(
        day: 3, name: "Footing récup", durationMinutes: 30, type: .endurance,
        warmup: nil,
        exercises: [
            AdaptedExercise(name: "Footing facile", originalName: "Footing facile",
                            duration: "30 min", notes: "Allure de conversation, respiration nasale.",
                            targetZone: "Daniels-E")
        ],
        cooldown: nil
    )
}

// MARK: - Story 3.35c — sélecteur appli musique + section séance

private struct MusicAppPickerScenarioView: View {
    init() {
        // Préréglage Deezer pour valider le nouvel ajout + le rendu mono-app.
        UserDefaults.standard.set(MusicStreamingApp.deezer.rawValue, forKey: MusicStreamingApp.storageKey)
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(verbatim: "Sélecteur (onboarding + profil)")
                        .font(.caption).foregroundStyle(.secondary)
                    MusicStreamingSelectorView()
                }
                VStack(alignment: .leading, spacing: 8) {
                    Text(verbatim: "Section séance (ouvre l'app choisie)")
                        .font(.caption).foregroundStyle(.secondary)
                    SessionMusicSuggestions(sportCode: "running")
                }
            }
            .padding()
        }
    }
}

// MARK: - Story 3.35d — fixture run/walk (cas device Sophie)

enum SessionFocusRunWalkFixture {
    static let week = AdaptedWeek(weekNumber: 1, theme: "Découverte run/walk", goal: "Couch to 5K", sessions: [])
    static let program = AdaptedProgram(
        templateId: "running-debutant-5k-8sem", sport: .running, level: .beginner,
        appliedAt: Date(), weeks: [week], appliedRules: [], requiresAIAssist: false
    )
    // Reproduit la VRAIE séance (nom condensé du template bundlé + échauffement + récup).
    static let session = AdaptedSession(
        day: 1, name: "Run/walk découverte", durationMinutes: 35, type: .mixed,
        warmup: "5 min de marche progressive + 10 cercles de chevilles/côté + 10 balancements de jambe avant-arrière/côté + 10 demi-squats lents. Total : 8 min. Ne jamais sauter cette étape.",
        exercises: [
            AdaptedExercise(name: "Bloc run/walk 1 min / 1 min 30", originalName: "Bloc run/walk",
                            sets: 8, duration: "1 min course lente + 1 min 30 marche rapide", restSeconds: 0,
                            notes: "Allure de course TRÈS lente, test de la parole.")
        ],
        cooldown: "3 min marche lente. Étirements statiques : mollets 30 sec/jambe, quadriceps 30 sec/jambe. Hydratation."
    )
}

// MARK: - Story 3.35 (FOCUS Audio) — fixture

enum SessionFocusAudioFixture {
    static let week = AdaptedWeek(weekNumber: 3, theme: "Endurance + tempo", goal: "Allure soutenue", sessions: [])
    static let program = AdaptedProgram(
        templateId: "focus-audio-fixture", sport: .running, level: .regular,
        appliedAt: Date(), weeks: [week], appliedRules: [], requiresAIAssist: false
    )
    static let session = AdaptedSession(
        day: 2, name: "Sortie tempo", durationMinutes: 35, type: .endurance,
        warmup: nil,
        exercises: [
            AdaptedExercise(name: "Échauffement footing", originalName: "Échauffement footing",
                            duration: "10 min", notes: "Allure très facile, Z2.", targetZone: "Z2"),
            AdaptedExercise(name: "Bloc tempo", originalName: "Bloc tempo",
                            duration: "15 min", notes: "Allure seuil, soutenue mais maîtrisée.", targetZone: "Daniels-T"),
            AdaptedExercise(name: "Retour au calme", originalName: "Retour au calme",
                            duration: "10 min", notes: "Footing très lent.", targetZone: "Z1")
        ],
        cooldown: nil
    )
}

// MARK: - Story 3.34 (FOCUS Minuté) — fixtures

enum SessionFocusHIITFixture {
    static let week = AdaptedWeek(weekNumber: 2, theme: "HIIT métabolique", goal: "VO2", sessions: [])
    static let program = AdaptedProgram(
        templateId: "focus-hiit-fixture", sport: .hiit, level: .recreational,
        appliedAt: Date(), weeks: [week], appliedRules: [], requiresAIAssist: false
    )
    static let session = AdaptedSession(
        day: 1, name: "Tabata corps entier", durationMinutes: 20, type: .interval,
        warmup: nil,
        exercises: [
            AdaptedExercise(name: "Burpees", originalName: "Burpees", sets: 4, duration: "40/20",
                            notes: "Explosif, gainage serré.")
        ],
        cooldown: nil
    )
}

enum SessionFocusYogaFixture {
    static let week = AdaptedWeek(weekNumber: 1, theme: "Mobilité", goal: "Souffle", sessions: [])
    static let program = AdaptedProgram(
        templateId: "focus-yoga-fixture", sport: .yoga, level: .beginner,
        appliedAt: Date(), weeks: [week], appliedRules: [], requiresAIAssist: false
    )
    static let session = AdaptedSession(
        day: 1, name: "Flow doux", durationMinutes: 30, type: .mobility,
        warmup: nil,
        exercises: [
            AdaptedExercise(name: "Guerrier I", originalName: "Guerrier I", duration: "45 s"),
            AdaptedExercise(name: "Chien tête en bas", originalName: "Chien tête en bas", duration: "1 min"),
            AdaptedExercise(name: "Arbre", originalName: "Arbre", duration: "30 s")
        ],
        cooldown: nil
    )
}

// MARK: - POC yoga 2026-06-05 — fallback orientation (D1) + taille FOCUS (D4)

/// Showcase statique du POC yoga : valide que les postures NON cataloguées prennent
/// la bonne orientation (couché/assis/debout) au lieu de Warrior I debout, et que le
/// dessin grossit à la taille FOCUS. Voix (D3) = non visible (audio, device Sophie).
private struct YogaPOCScenarioView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text(verbatim: "POC yoga — D1 fallback orientation (postures NON cataloguées)")
                    .font(.caption.bold()).foregroundStyle(.secondary)
                ForEach([
                    ("Jathara Parivartanasana", "torsion COUCHÉE → silhouette couchée"),
                    ("Gomukhasana", "tête de vache ASSISE → silhouette assise"),
                    ("Natarajasana", "danseur DEBOUT → silhouette debout")
                ], id: \.0) { name, expect in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(verbatim: "\(name)").font(.caption2.bold())
                        Text(verbatim: expect).font(.caption2).foregroundStyle(.secondary)
                        ExercisePatternIllustration(pattern: .yoga, sportCode: "yoga", exerciseName: name, size: 110)
                            .frame(maxWidth: .infinity)
                            .padding(8)
                            .background(Color(uiColor: .secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }

                Divider().padding(.vertical, 4)

                Text(verbatim: "POC yoga — D4 taille FOCUS (avant : figé 80×48 « riquiqui »)")
                    .font(.caption.bold()).foregroundStyle(.secondary)
                ExercisePatternIllustration(pattern: .yoga, sportCode: "yoga", exerciseName: "Savasana", size: 200)
                    .frame(maxWidth: .infinity)
                    .padding(12)
                    .background(Color(uiColor: .secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(16)
        }
        .background(Color.coachingBackground.ignoresSafeArea())
    }
}

// MARK: - Story 3.23 Lot 0 — IllustrationsStory323ScenarioView

/// Showcase compact des 9 dessins refondus Story 3.23. **DB bench, Calf raise
/// et Hip Thrust placés en TÊTE** car les 3 strengths sont les plus prioritaires
/// à valider (Sophie ne comprend pas Calf raise + DB bench cité explicitement).
/// Les 7 yogas suivent.
private struct IllustrationsStory323ScenarioView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text(verbatim: "Story 3.23 — 9 dessins refondus 2026-05-25")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)

                // 3 strengths d'abord (priorité Sophie)
                story323Item(title: "Calf raise (3 frames) — REFONDU pivot pied", pattern: .calfRaise, exerciseName: nil)
                story323Item(title: "DB bench press (variante, 3 frames) — REFONDU bras", pattern: .pushHorizontal, exerciseName: "DB bench press")
                story323Item(title: "Hip Thrust (3 frames)", pattern: .hipThrust, exerciseName: nil)

                // 7 yogas ensuite
                story323Item(title: "Cat-cow (Marjaryasana-Bitilasana)", pattern: .yoga, exerciseName: "Cat-cow")
                story323Item(title: "Cat-cow sur les avant-bras", pattern: .yoga, exerciseName: "Cat-cow sur les avant-bras")
                story323Item(title: "Dirgha pranayama (3 parties)", pattern: .yoga, exerciseName: "Dirgha pranayama")
                story323Item(title: "Sarvangasana (Chandelle) — REFONDU flèche", pattern: .yoga, exerciseName: "Sarvangasana")
                story323Item(title: "Setu Bandha (Pont yoga)", pattern: .yoga, exerciseName: "Setu Bandha")
                story323Item(title: "Ujjayi (souffle océan)", pattern: .yoga, exerciseName: "Ujjayi")
                story323Item(title: "Surya Namaskar A — REFONDU 3 mini-poses", pattern: .yoga, exerciseName: "Surya Namaskar A")
            }
            .padding(16)
        }
        .background(Color.coachingBackground.ignoresSafeArea())
    }

    @ViewBuilder
    private func story323Item(title: String, pattern: ExercisePattern, exerciseName: String?) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(verbatim: title)
                .font(.caption2.bold())
                .foregroundStyle(.secondary)
            ExercisePatternIllustration(pattern: pattern, sportCode: pattern == .yoga ? "yoga" : "strengthTraining", exerciseName: exerciseName)
                .padding(6)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(uiColor: .tertiarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
    }
}

// MARK: - Story 3.23 Lot 1 — IllustrationsStory323Lot1ScenarioView

/// Showcase compact des 5 illustrations SUSPECT V1 à valider visuellement
/// (Arbre, Enfant, Bateau, Lunge frame 0, Mobility étirement quad).
private struct IllustrationsStory323Lot1ScenarioView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text(verbatim: "Story 3.23 Lot 1 — 5 SUSPECT V1 à valider")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)

                lot1Item(title: "Arbre (Vrksasana) — yoga", pattern: .yoga, exerciseName: "Arbre")
                lot1Item(title: "Enfant (Balasana) — yoga", pattern: .yoga, exerciseName: "Enfant")
                lot1Item(title: "Bateau (Navasana) — yoga", pattern: .yoga, exerciseName: "Bateau")
                lot1Item(title: "Lunge (3 frames, frame 0 ambigu ?) — strength", pattern: .lunge, exerciseName: nil)
                lot1Item(title: "Mobility étirement quadriceps — strength", pattern: .mobility, exerciseName: nil)
            }
            .padding(16)
        }
        .background(Color.coachingBackground.ignoresSafeArea())
    }

    @ViewBuilder
    private func lot1Item(title: String, pattern: ExercisePattern, exerciseName: String?) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(verbatim: title)
                .font(.caption2.bold())
                .foregroundStyle(.secondary)
            ExercisePatternIllustration(pattern: pattern, sportCode: pattern == .yoga ? "yoga" : "strengthTraining", exerciseName: exerciseName)
                .padding(6)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(uiColor: .tertiarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
    }
}

// MARK: - Story 3.23 Lots 1+2+3 — IllustrationsStory323Lots123ScenarioView

/// Showcase batch validation des 15 dessins Story 3.23 Lots 1+2+3 :
/// - Lot 1 (5 SUSPECT V1 refondus) : Arbre, Enfant, Bateau, Lunge, Mobility quad
/// - Lot 2 (5 yoga haute fréquence) : Padangusthasana, Surya B, Baddha Konasana,
///   Paschimottanasana, Supta Baddha Konasana
/// - Lot 3 (5 strength haute fréquence) : Forearm plank, Y-T-W, Pallof press,
///   Nordic curl, Bird-dog
private struct IllustrationsStory323Lots123ScenarioView: View {
    private struct Entry: Identifiable {
        let id = UUID()
        let title: String
        let pattern: ExercisePattern
        let exerciseName: String?
    }

    private let entries: [Entry] = [
        // Lot 1
        Entry(title: "Arbre", pattern: .yoga, exerciseName: "Arbre"),
        Entry(title: "Enfant", pattern: .yoga, exerciseName: "Enfant"),
        Entry(title: "Bateau", pattern: .yoga, exerciseName: "Bateau"),
        Entry(title: "Lunge", pattern: .lunge, exerciseName: nil),
        Entry(title: "Mobility quad", pattern: .mobility, exerciseName: nil),
        // Lot 2
        Entry(title: "Padangusthasana", pattern: .yoga, exerciseName: "Padangusthasana"),
        Entry(title: "Surya B", pattern: .yoga, exerciseName: "Surya Namaskar B"),
        Entry(title: "Baddha Konasana", pattern: .yoga, exerciseName: "Baddha Konasana"),
        Entry(title: "Paschimottanasana", pattern: .yoga, exerciseName: "Paschimottanasana"),
        Entry(title: "Supta Baddha", pattern: .yoga, exerciseName: "Supta Baddha Konasana"),
        // Lot 3
        Entry(title: "Forearm plank", pattern: .forearmPlank, exerciseName: nil),
        Entry(title: "Y-T-W", pattern: .ytwActivation, exerciseName: nil),
        Entry(title: "Pallof press", pattern: .pallofPress, exerciseName: nil),
        Entry(title: "Nordic curl", pattern: .nordicCurl, exerciseName: nil),
        Entry(title: "Bird-dog", pattern: .birdDog, exerciseName: nil)
    ]

    var body: some View {
        let cols = [GridItem(.flexible(), spacing: 4), GridItem(.flexible(), spacing: 4)]
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Text(verbatim: "Story 3.23 Lots 1+2+3 — 15 dessins")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                LazyVGrid(columns: cols, spacing: 6) {
                    ForEach(entries) { entry in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(verbatim: entry.title)
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                            ExercisePatternIllustration(
                                pattern: entry.pattern,
                                sportCode: entry.pattern == .yoga ? "yoga" : "strengthTraining",
                                exerciseName: entry.exerciseName,
                                size: 64
                            )
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(4)
                            .background(Color(uiColor: .tertiarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                    }
                }
            }
            .padding(8)
        }
        .background(Color.coachingBackground.ignoresSafeArea())
    }
}

// MARK: - Story 3.23 Lot 4 — IllustrationsStory323Lot4ScenarioView

/// Showcase batch validation des 10 nouvelles poses yoga moyenne fréquence
/// (Story 3.23 Lot 4 — 2026-05-25).
private struct IllustrationsStory323Lot4ScenarioView: View {
    private struct Entry: Identifiable {
        let id = UUID()
        let title: String
        let exerciseName: String
    }

    private let entries: [Entry] = [
        Entry(title: "Janu Sirsasana", exerciseName: "Janu Sirsasana"),
        Entry(title: "Tadasana", exerciseName: "Tadasana"),
        Entry(title: "Dandasana", exerciseName: "Dandasana"),
        Entry(title: "Marichyasana A", exerciseName: "Marichyasana A"),
        Entry(title: "Matsyasana", exerciseName: "Matsyasana"),
        Entry(title: "Parsvakonasana", exerciseName: "Utthita Parsvakonasana"),
        Entry(title: "Viparita Karani", exerciseName: "Viparita Karani"),
        Entry(title: "Parsvottanasana", exerciseName: "Parsvottanasana"),
        Entry(title: "Halasana", exerciseName: "Halasana"),
        Entry(title: "Kurmasana", exerciseName: "Kurmasana")
    ]

    var body: some View {
        let cols = [GridItem(.flexible(), spacing: 4), GridItem(.flexible(), spacing: 4)]
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Text(verbatim: "Story 3.23 Lot 4 — 10 yoga moyenne fréquence")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                LazyVGrid(columns: cols, spacing: 6) {
                    ForEach(entries) { entry in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(verbatim: entry.title)
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                            ExercisePatternIllustration(
                                pattern: .yoga,
                                sportCode: "yoga",
                                exerciseName: entry.exerciseName,
                                size: 64
                            )
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(4)
                            .background(Color(uiColor: .tertiarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                    }
                }
            }
            .padding(8)
        }
        .background(Color.coachingBackground.ignoresSafeArea())
    }
}

// MARK: - Story 3.23 Lot 5 — IllustrationsStory323Lot5ScenarioView

/// Showcase batch validation des 6 nouveaux patterns strength moyenne fréquence
/// (Story 3.23 Lot 5 — 2026-05-26).
private struct IllustrationsStory323Lot5ScenarioView: View {
    private struct Entry: Identifiable {
        let id = UUID()
        let title: String
        let pattern: ExercisePattern
    }

    private let entries: [Entry] = [
        Entry(title: "Dead-bug", pattern: .deadBug),
        Entry(title: "Clamshell", pattern: .clamshell),
        Entry(title: "KB Swing", pattern: .kbSwing),
        Entry(title: "Face pull", pattern: .facePull),
        Entry(title: "Foam rolling", pattern: .foamRolling),
        Entry(title: "Biceps curl", pattern: .bicepsCurl)
    ]

    var body: some View {
        let cols = [GridItem(.flexible(), spacing: 4), GridItem(.flexible(), spacing: 4)]
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Text(verbatim: "Story 3.23 Lot 5 — 6 strength moyenne fréquence")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                LazyVGrid(columns: cols, spacing: 6) {
                    ForEach(entries) { entry in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(verbatim: entry.title)
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                            ExercisePatternIllustration(
                                pattern: entry.pattern,
                                sportCode: "strengthTraining",
                                exerciseName: nil,
                                size: 64
                            )
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(4)
                            .background(Color(uiColor: .tertiarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                    }
                }
            }
            .padding(8)
        }
        .background(Color.coachingBackground.ignoresSafeArea())
    }
}

// MARK: - Story 3.23 Lot 6 — IllustrationsStory323Lot6ScenarioView

/// Showcase batch validation des 10 nouvelles poses yoga reste catalogue
/// (Story 3.23 Lot 6 — 2026-05-26).
private struct IllustrationsStory323Lot6ScenarioView: View {
    private struct Entry: Identifiable {
        let id = UUID()
        let title: String
        let exerciseName: String
    }

    private let entries: [Entry] = [
        Entry(title: "Anjaneyasana", exerciseName: "Anjaneyasana"),
        Entry(title: "Urdhva Dhanurasana", exerciseName: "Urdhva Dhanurasana"),
        Entry(title: "Dolphin pose", exerciseName: "Dolphin pose"),
        Entry(title: "Garudasana", exerciseName: "Garudasana"),
        Entry(title: "Utkatasana", exerciseName: "Utkatasana"),
        Entry(title: "Warrior 3", exerciseName: "Virabhadrasana III"),
        Entry(title: "Nadi Shodhana", exerciseName: "Nadi Shodhana"),
        Entry(title: "Ardha Chandrasana", exerciseName: "Ardha Chandrasana"),
        Entry(title: "Sukhasana", exerciseName: "Sukhasana"),
        Entry(title: "Sirsasana", exerciseName: "Sirsasana")
    ]

    var body: some View {
        let cols = [GridItem(.flexible(), spacing: 4), GridItem(.flexible(), spacing: 4)]
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Text(verbatim: "Story 3.23 Lot 6 — 10 yoga reste catalogue")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                LazyVGrid(columns: cols, spacing: 6) {
                    ForEach(entries) { entry in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(verbatim: entry.title)
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                            ExercisePatternIllustration(
                                pattern: .yoga,
                                sportCode: "yoga",
                                exerciseName: entry.exerciseName,
                                size: 64
                            )
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(4)
                            .background(Color(uiColor: .tertiarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                    }
                }
            }
            .padding(8)
        }
        .background(Color.coachingBackground.ignoresSafeArea())
    }
}

// MARK: - Story 3.23 Lot 7 — IllustrationsStory323Lot7ScenarioView

/// Showcase Lot 7 — 2 patterns strength finition catalogue.
private struct IllustrationsStory323Lot7ScenarioView: View {
    var body: some View {
        let cols = [GridItem(.flexible(), spacing: 4), GridItem(.flexible(), spacing: 4)]
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Text(verbatim: "Story 3.23 Lot 7 — 2 strength finition")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                LazyVGrid(columns: cols, spacing: 6) {
                    lot7Item(title: "Triceps pushdown", pattern: .tricepsPushdown)
                    lot7Item(title: "Lateral raises", pattern: .lateralRaises)
                }
            }
            .padding(8)
        }
        .background(Color.coachingBackground.ignoresSafeArea())
    }

    @ViewBuilder
    private func lot7Item(title: String, pattern: ExercisePattern) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(verbatim: title)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(.secondary)
                .lineLimit(1)
            ExercisePatternIllustration(
                pattern: pattern,
                sportCode: "strengthTraining",
                exerciseName: nil,
                size: 64
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(4)
            .background(Color(uiColor: .tertiarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 4))
        }
    }
}

// MARK: - Story 3.19 Jalon 2b — IllustrationsShowcaseScenarioView

/// Showcase 10 strength + 10 poses yoga (Sophie 2026-05-23). Décision produit :
/// on n'illustre QUE les gestes où l'image clarifie (positions techniques
/// strength + poses statiques yoga). Running / cycling / swim continu → pas de
/// dessin (gestes universels) → fallback SF Symbol sport + glossaire pour les
/// mots opaques (`drill`, `tempo`, `Daniels-T`...).
private struct IllustrationsShowcaseScenarioView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Group {
                    Text(verbatim: "STRENGTH").font(.headline)
                    showcaseSection(title: "Squat", pattern: .squat, sportCode: "strengthTraining")
                    showcaseSection(title: "Hinge (Romanian Deadlift)", pattern: .hinge, sportCode: "strengthTraining")
                    showcaseSection(title: "Push horizontal (pompe / bench)", pattern: .pushHorizontal, sportCode: "strengthTraining")
                    showcaseSection(title: "Push vertical (overhead press)", pattern: .pushVertical, sportCode: "strengthTraining")
                    showcaseSection(title: "Pull horizontal (row / rameur)", pattern: .pullHorizontal, sportCode: "strengthTraining")
                }
                Group {
                    showcaseSection(title: "Pull vertical (pull-up / chin-up)", pattern: .pullVertical, sportCode: "strengthTraining")
                    showcaseSection(title: "Lunge (fente avant)", pattern: .lunge, sportCode: "strengthTraining")
                    showcaseSection(title: "Plyo (jump squat / box jump)", pattern: .plyo, sportCode: "strengthTraining")
                    showcaseStatic(title: "Core — plank frontal (planche)", pattern: .core, sportCode: "strengthTraining", exerciseName: "Plank")
                    showcaseStatic(title: "Core — plank latéral (side plank)", pattern: .core, sportCode: "strengthTraining", exerciseName: "Plank latéral")
                    showcaseStatic(title: "Mobility (étirement quadriceps)", pattern: .mobility, sportCode: "strengthTraining", exerciseName: nil)
                }
                Group {
                    Text(verbatim: "YOGA").font(.headline).padding(.top, 8)
                    showcaseStatic(title: "Chien tête en bas (Adho Mukha Svanasana)", pattern: .yoga, sportCode: "yoga", exerciseName: "Chien tête en bas")
                    showcaseStatic(title: "Guerrier I (Virabhadrasana I)", pattern: .yoga, sportCode: "yoga", exerciseName: "Guerrier I")
                    showcaseStatic(title: "Guerrier II (Virabhadrasana II)", pattern: .yoga, sportCode: "yoga", exerciseName: "Guerrier II")
                    showcaseStatic(title: "Arbre (Vrksasana)", pattern: .yoga, sportCode: "yoga", exerciseName: "Arbre")
                    showcaseStatic(title: "Cobra (Bhujangasana)", pattern: .yoga, sportCode: "yoga", exerciseName: "Cobra")
                }
                Group {
                    showcaseStatic(title: "Enfant (Balasana)", pattern: .yoga, sportCode: "yoga", exerciseName: "Enfant")
                    showcaseStatic(title: "Pince debout (Uttanasana)", pattern: .yoga, sportCode: "yoga", exerciseName: "Pince debout")
                    showcaseStatic(title: "Triangle (Trikonasana)", pattern: .yoga, sportCode: "yoga", exerciseName: "Triangle")
                    showcaseStatic(title: "Bateau (Navasana)", pattern: .yoga, sportCode: "yoga", exerciseName: "Bateau")
                    showcaseStatic(title: "Savasana (cadavre / relaxation)", pattern: .yoga, sportCode: "yoga", exerciseName: "Savasana")
                }
                Group {
                    Text(verbatim: "STORY 3.23 — NOUVEAUX DESSINS (à refondre)").font(.headline).padding(.top, 8).foregroundStyle(.red)
                    showcaseStatic(title: "Dirgha pranayama (3 parties)", pattern: .yoga, sportCode: "yoga", exerciseName: "Dirgha pranayama")
                    showcaseStatic(title: "Cat-cow (Marjaryasana-Bitilasana)", pattern: .yoga, sportCode: "yoga", exerciseName: "Cat-cow")
                    showcaseStatic(title: "Cat-cow sur les avant-bras", pattern: .yoga, sportCode: "yoga", exerciseName: "Cat-cow sur les avant-bras")
                    showcaseStatic(title: "Sarvangasana (Chandelle)", pattern: .yoga, sportCode: "yoga", exerciseName: "Sarvangasana")
                    showcaseStatic(title: "Setu Bandha (Pont yoga)", pattern: .yoga, sportCode: "yoga", exerciseName: "Setu Bandha")
                }
                Group {
                    showcaseStatic(title: "Ujjayi (souffle océan)", pattern: .yoga, sportCode: "yoga", exerciseName: "Ujjayi")
                    showcaseStatic(title: "Surya Namaskar A", pattern: .yoga, sportCode: "yoga", exerciseName: "Surya Namaskar A")
                    showcaseSection(title: "Hip Thrust (3 frames)", pattern: .hipThrust, sportCode: "strengthTraining")
                    showcaseSection(title: "Calf raise (3 frames)", pattern: .calfRaise, sportCode: "strengthTraining")
                    showcaseDBBench()
                }
            }
            .padding(16)
        }
        .background(Color.coachingBackground.ignoresSafeArea())
    }

    @ViewBuilder
    private func showcaseSection(title: String, pattern: ExercisePattern, sportCode: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(verbatim: title)
                .font(.caption.bold())
                .foregroundStyle(.secondary)
            ExercisePatternIllustration(pattern: pattern, sportCode: sportCode)
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(uiColor: .tertiarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    /// Story 3.23 — DB bench variante (transmet exerciseName au dispatcher pour
    /// déclencher la branche `isDumbbellBench` dans PushHorizontalIllustration).
    @ViewBuilder
    private func showcaseDBBench() -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(verbatim: "DB bench press (variante PushHorizontal, 3 frames)")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
            ExercisePatternIllustration(pattern: .pushHorizontal, sportCode: "strengthTraining", exerciseName: "DB bench press")
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(uiColor: .tertiarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    @ViewBuilder
    private func showcaseStatic(title: String, pattern: ExercisePattern, sportCode: String, exerciseName: String?) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(verbatim: title)
                .font(.caption.bold())
                .foregroundStyle(.secondary)
            ExercisePatternIllustration(pattern: pattern, sportCode: sportCode, exerciseName: exerciseName)
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(uiColor: .tertiarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8))
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
