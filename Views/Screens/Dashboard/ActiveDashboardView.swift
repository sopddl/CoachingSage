// Views/Screens/Dashboard/ActiveDashboardView.swift
// Story 3.8 sous-tâches 7-8 — vue mode actif (single + multi programmes).
//
// Composition (Story 3.10 carrousel + Story 3.12 refonte vue semaine) :
//   - PROGRAMMES ACTIFS     : carrousel horizontal `ProgramCard` × N
//                              (snap, scrollPosition bind selectedId)
//   - PROCHAINE SÉANCE      : `NextSessionCard` du programme sélectionné
//                              (cas : dormant / dispo / semaine complétée / programme complété)
//
// **Story 3.10 (2026-05-17)** : section "Mes routines" supprimée (aucun row
// jamais créé en base, pas d'UI de création, code mort). Le `@Model
// RoutineRecord` est drop du Schema V8.
// **Story 3.12 (2026-05-18)** : suppression `WeeklyReorderLink` ("Réorganiser
// ma semaine") + drag&drop par jour. Modèle "semaine atomique" : l'utilisateur
// fait ses séances dans l'ordre qu'il veut au cours de la semaine.
//
// 2026-05-10 — Sophie : suppression `CreateProgramOrRoutineCard` du bas
// (déplacé en toolbar « + » de SessionView pour découvrabilité). La distinction
// routine vs programme est désormais cachée au user — pivot via la question
// fréquence Q3 du questionnaire (voir mémoire `routine_via_freq_onboarding...`).
//
// Source design : `ux-design-CoachingSage-seances-dashboard-2026-05-07.html`.
import SwiftUI
import TemplateModel

struct ActiveDashboardView: View {
    /// **Story 3.15** — programmes lancés (`weekStartDate != nil`) affichés dans
    /// le carrousel horizontal Zone 1. Tri `lastUpdatedAt desc` appliqué côté VM.
    let startedPrograms: [ProgramSummary]
    /// **Story 3.15** — programmes dormants (`weekStartDate == nil`) affichés
    /// dans la Zone 3 (liste verticale "Préparés"). Vide → zone 3 absente.
    let dormantPrograms: [ProgramSummary]
    /// `record.id` de la card sélectionnée dans le carrousel. Toujours un
    /// `startedPrograms` (jamais un dormant). `nil` (cas dégénéré) = première card.
    let selectedId: UUID?
    /// **Story 3.15 AC7** — session N+1 du programme sélectionné (teaser sous
    /// la séance focale). `nil` = pas de N+1, on affiche "Dernière séance de
    /// la semaine" si focal existe.
    let teaserSession: PersistedSession?
    /// **Story 3.15 v4 (Sophie 2026-05-21)** — sessions pending APRÈS la
    /// focale, listées verticalement sous la card focale ("Séances"). Vide
    /// pour le scenario `_mixed` du UIReviewScenarioContainer (peuplé par
    /// `SessionDashboardViewModel.upcomingSessionsAfterFocal`).
    var upcomingSessions: [PersistedSession] = []
    /// Phase B.5 — map `record.id → RegenBadge` peuplée pour les programmes
    /// dont la regen S+1 a été appliquée cette semaine.
    var regenBadges: [UUID: RegenBadge] = [:]
    let onSelectProgram: (UUID) -> Void
    let onTapStartSession: (ProgramSummary) -> Void
    let onTapProgram: (ProgramSummary) -> Void
    /// Story 3.3b cleanup 2026-05-10 — swipe-to-delete sur la liste des programmes.
    /// L'action concrète = `adaptedRepo.archive(record)` côté caller (SessionView).
    let onDeleteProgram: (ProgramSummary) -> Void
    /// **Story 3.11** — tap "Replanifier" (visible uniquement quand la prochaine
    /// séance affichée est `late` ET le programme est en mode deadline).
    /// **Story 3.27 D4** : conservé pour rétrocompat caller (`SessionView`)
    /// mais ignoré dans `NextSessionCard` (Replanifier accessible uniquement
    /// dans `AdaptedProgramView` désormais). À supprimer en cleanup ultérieur.
    var onTapReplanify: ((ProgramSummary) -> Void)? = nil

    /// **Story 3.27 Phase B** — handler pour ouvrir le bouton « + Démarrer un
    /// nouveau programme » quand 0 programme préparé. Push vers le questionnaire
    /// universel via le caller (`SessionView`).
    /// **Hotfix2 2026-05-31** : trigger + sheet déplacés à SessionView via
    /// `safeAreaInset(.bottom)`. Le rendu dans le VStack ActiveDashboardView
    /// était toujours pushed hors écran par la liste séances scrollable.
    /// Ce param reste pour cohérence d'API mais n'est plus utilisé localement.
    var onTapStartNewProgram: (() -> Void)? = nil

    private var selectedSummary: ProgramSummary? {
        if let selectedId, let s = startedPrograms.first(where: { $0.id == selectedId }) { return s }
        return startedPrograms.first
    }

    var body: some View {
        // **Story 3.15 v6 (Sophie 2026-05-21)** — 3 sections rigides via VStack
        // sans ScrollView global. Sophie : « pas de scroll global mais un
        // autre scroll pour les programmes préparés ». Section Séances et
        // Programmes préparés ont chacune leur ScrollView interne avec flex
        // height pour se partager l'espace restant.
        //
        // **v7.3 (Sophie 2026-05-21)** — fond solide sur chaque section +
        // `scrollClipDisabled()` retiré : les rows du scroll Séances étaient
        // visibles sous le titre "Programmes préparés" et inversement. Chaque
        // section a maintenant son `Color.coachingBackground` + le scroll est
        // clip-natif, donc tout reste à sa place visuellement.
        VStack(alignment: .leading, spacing: 16) {
            // Zone 1 : carrousel "Programmes en cours" — hauteur fixe.
            if !startedPrograms.isEmpty {
                section(titleKey: "dashboard.section.in_progress.title") {
                    programCarousel
                }
                .background(Color.coachingBackground)
            }

            // Zone 2 : bandeau contextuel "[SPORT] · SEMAINE N" + focal + liste.
            // **Story 3.27 Phase A (party 2026-05-30 D2)** — le titre statique
            // « Séances » est remplacé par un bandeau dynamique du programme
            // sélectionné dans le carrousel. Rend visible la liaison
            // programme↔séances quand l'user swipe le carrousel (vœu Sophie-user).
            if let selectedSummary {
                sectionWithTitle(contextualSessionTitle(for: selectedSummary)) {
                    VStack(spacing: 10) {
                        // **Story 3.27 Phase B (D7)** — widget "Stats semaine"
                        // au-dessus de la card focal. Agrégation cumulative sur
                        // l'ensemble des programmes actifs (cas Maxime motivation).
                        // V1 minimal : « X / Y séances cette semaine ». Évolution
                        // V2 possible avec streak + temps cumulé.
                        weeklyStatsWidget
                        NextSessionCard(
                            summary: selectedSummary,
                            onTapStart: { onTapStartSession(selectedSummary) },
                            onTapDetail: { onTapProgram(selectedSummary) },
                            onTapReplanify: onTapReplanify.map { handler in
                                { handler(selectedSummary) }
                            }
                        )
                        // ScrollView interne pour la liste des séances
                        // suivantes du programme courant. Hauteur flex : prend
                        // l'espace restant après la focal + sections fixes.
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(spacing: 6) {
                                ForEach(Array(upcomingSessions.enumerated()), id: \.element.id) { index, session in
                                    let prevWeek: Int = index == 0
                                        ? (selectedSummary.nextSession?.weekNumber ?? session.weekNumber)
                                        : upcomingSessions[index - 1].weekNumber
                                    if session.weekNumber != prevWeek {
                                        weekSeparatorHeader(weekNumber: session.weekNumber)
                                    }
                                    UpcomingSessionRow(
                                        session: session,
                                        sportCode: selectedSummary.sport.appSportCode
                                    )
                                }
                                if upcomingSessions.isEmpty, selectedSummary.nextSession != nil {
                                    NextSessionTeaser(
                                        teaserSession: nil,
                                        hasFocal: true
                                    )
                                }
                            }
                            .padding(.bottom, 8)
                        }
                    }
                }
                .frame(maxHeight: .infinity, alignment: .top)
                .background(Color.coachingBackground)
            }

            // **Hotfix2 Story 3.27 2026-05-31** — trigger « Programmes préparés »
            // placé directement comme DERNIER child du VStack (le carrousel
            // précédant + Zone 2 .frame(maxHeight: .infinity) le poussent en
            // bas). safeAreaInset et overlay du VStack ne marchaient pas dans
            // le contexte SessionView. Le trigger fait sa hauteur naturelle
            // ~40pt, le VStack s'ajuste, Zone 2 prend l'espace restant.
        }
    }

    /// **Story 3.27 Phase B (D7)** — widget compact « X / Y séances cette
    /// semaine » agrégé sur tous les programmes actifs. Affiché au-dessus de la
    /// card focal (cas Maxime motivation). V1 minimal sans streak ni temps :
    /// les données minutes ne sont pas exposées sur `ProgramSummary`. Évolution
    /// V2 possible si Sophie veut plus riche.
    @ViewBuilder
    private var weeklyStatsWidget: some View {
        let completed = startedPrograms.reduce(0) { $0 + $1.weekCompletedSessions }
        let total = startedPrograms.reduce(0) { $0 + $1.weekTotalSessions }
        if total > 0 {
            HStack(spacing: 8) {
                Image(systemName: "calendar.badge.checkmark")
                    .font(.caption)
                    .foregroundStyle(Color.coachingPrimary)
                Text(verbatim: String(
                    format: String.localized("dashboard.stats.thisweek.format", locale: locale),
                    completed, total
                ))
                    .font(.coachingCaption.weight(.medium))
                    .foregroundStyle(Color.coachingTextPrimary)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.coachingCard)
            .clipShape(Capsule())
            .accessibilityIdentifier("dashboard.stats.thisweek")
        }
    }

    /// **Story 3.15 v5 (Sophie 2026-05-21)** — header séparateur de semaine
    /// dans la liste "Séances". Affiché entre les sessions quand la semaine
    /// change. Évite la répétition du pill semaine sur chaque row.
    @ViewBuilder
    private func weekSeparatorHeader(weekNumber: Int) -> some View {
        Text(verbatim: String(
            format: NSLocalizedString("dashboard.active.next.coordinate.format", comment: ""),
            weekNumber
        ))
        .font(.coachingCaption.weight(.semibold))
        .foregroundStyle(Color.coachingTextSecondary)
        .textCase(.uppercase)
        .tracking(0.6)
        .padding(.top, 6)
        .padding(.leading, 4)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// **Story 3.15** — carrousel horizontal swipable unique pour les started.
    /// Snap natif iOS 17, `.scrollPosition(id:)` bind à la sélection.
    ///
    /// **Sophie 2026-05-20 (test simu)** — bug "je n'arrive pas à sélectionner
    /// le second" : à 2 cards le snap iOS 17 ne switche pas toujours (le
    /// pointeur souris simu reconnaît mal le swipe court). Solution :
    /// **double-clic / double-tap pour push, simple tap pour sélectionner**.
    /// L'user tap une fois pour focaliser le programme (séance focale + teaser
    /// mis à jour), puis tap à nouveau pour ouvrir `AdaptedProgramView`.
    @ViewBuilder
    private var programCarousel: some View {
        let effectiveSelectedId = selectedId ?? startedPrograms.first?.id
        ScrollView(.horizontal, showsIndicators: false) {
            // **Story 3.15 v3 (Sophie 2026-05-21)** — SwipeToDeleteRow retiré du
            // carrousel : le swipe ne déclenchait pas le snap iOS 17 proprement
            // et la border de la card sélectionnée était masquée. Suppression
            // du programme désormais accessible depuis `AdaptedProgramView` (en
            // bas, bouton "Supprimer le programme").
            // Padding vertical 4pt pour laisser respirer la border 2pt selected.
            LazyHStack(spacing: 12) {
                ForEach(startedPrograms) { summary in
                    ProgramCard(
                        summary: summary,
                        badge: regenBadges[summary.id],
                        isSelected: summary.id == effectiveSelectedId,
                        onTap: {
                            if summary.id == effectiveSelectedId {
                                onTapProgram(summary)
                            } else {
                                onSelectProgram(summary.id)
                            }
                        }
                    )
                    .frame(width: 200)
                    .id(summary.id)
                }
            }
            .scrollTargetLayout()
            .padding(.horizontal, 2)
            .padding(.vertical, 4)
        }
        // **Story 3.27 Phase A (D1)** — carrousel agrandi de 180→200pt (width
        // card) pour réduire les truncations sur les titres composites
        // (« Triathlon — Distanc... »). Sophie : « un tout petit peu plus
        // grand ». Hauteur fixe inchangée (le contenu reste calé sur le même
        // gabarit, c'est la respiration horizontale qui gagne).
        .frame(height: 130) // 118pt contenu + 8 padding vert + 4 marge border (Story 3.27)
        .scrollTargetBehavior(.viewAligned)
        .scrollPosition(
            id: Binding(
                get: { effectiveSelectedId },
                set: { newID in
                    if let newID, newID != selectedId {
                        onSelectProgram(newID)
                    }
                }
            )
        )
        .accessibilityIdentifier("dashboard.active.carousel")
    }

    @ViewBuilder
    private func section(titleKey: LocalizedStringKey, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(titleKey)
                .font(.coachingCaption.weight(.semibold))
                .foregroundStyle(Color.coachingTextSecondary)
                .textCase(.uppercase)
                .tracking(0.8)
            content()
        }
    }

    /// **Story 3.27 Phase A** — variante avec titre String dynamique, pour le
    /// bandeau contextuel zone 2 (« [SPORT] · SEMAINE N »).
    @ViewBuilder
    private func sectionWithTitle(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(verbatim: title)
                .font(.coachingCaption.weight(.semibold))
                .foregroundStyle(Color.coachingTextSecondary)
                .textCase(.uppercase)
                .tracking(0.8)
                .accessibilityIdentifier("dashboard.section.contextual.title")
            content()
        }
    }

    /// **Story 3.27 Phase A (party 2026-05-30 D2)** — titre contextuel
    /// « [SPORT] · SEMAINE N » du programme sélectionné. Sport localisé via
    /// `String.localized` + format static i18n « dashboard.section.contextual.format ».
    private func contextualSessionTitle(for summary: ProgramSummary) -> String {
        let sportName = sportLocalizedName(summary.sport)
        return String(
            format: String.localized("dashboard.section.contextual.format", locale: locale),
            sportName,
            summary.currentWeekNumber
        )
    }

    /// Nom localisé du sport pour interpolation dans titre dynamique. Switch
    /// statique pour rester i18n-safe (pattern hotfix 2026-05-12 sur
    /// `LocalizedStringKey("foo.\(bar)")` qui casse les xcstrings).
    private func sportLocalizedName(_ sport: Sport) -> String {
        switch sport {
        case .running:          return String.localized("onboarding.sport.running", locale: locale)
        case .cycling:          return String.localized("onboarding.sport.cycling", locale: locale)
        case .swimming:         return String.localized("onboarding.sport.swimming", locale: locale)
        case .triathlon:        return String.localized("onboarding.sport.triathlon", locale: locale)
        case .strengthTraining: return String.localized("onboarding.sport.strengthTraining", locale: locale)
        case .yoga:             return String.localized("onboarding.sport.yoga", locale: locale)
        case .hiit:             return String.localized("onboarding.sport.hiit", locale: locale)
        case .hiking:           return String.localized("onboarding.sport.hiking", locale: locale)
        case .tennis:           return String.localized("onboarding.sport.tennis", locale: locale)
        case .football:         return String.localized("onboarding.sport.football", locale: locale)
        }
    }

    @Environment(\.locale) private var locale
}

// MARK: - Program card (Story 3.10 — carrousel horizontal)
//
// Anciennes vues `DominantNextSessionCard`, `RestDayCard` et `WeeklyStatsWidget`
// supprimées en Story 3.10 — la card dominante a été remplacée par le
// `ProgramCard` + `NextSessionCard` du carrousel.

// **Story 3.27 Phase C** — `internal` (et non `private`) pour permettre les
// snapshot tests FR de la card carrousel (`ProgramCardSnapshotTests`). C'est la
// card la plus refondue par 3.27 + le point de vigilance truncation titre.
struct ProgramCard: View {
    let summary: ProgramSummary
    /// Phase B.5 — badge regen S+1 si la regen a été appliquée cette semaine
    /// pour ce record. `nil` sinon. Style varie selon `requiresRebuild`.
    var badge: RegenBadge?
    /// **Story 3.10** — card sélectionnée dans le carrousel : border accentuée.
    let isSelected: Bool
    let onTap: () -> Void

    /// **P0 #2 fix ui-reviewer** — locale courante pour resolve les strings
    /// interpolées via `String.localized(_:locale:)`.
    @Environment(\.locale) private var locale

    private var sportCode: String { summary.sport.appSportCode }

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .center, spacing: 6) {
                // **Story 3.12** — Header card en mode portrait : icône sport
                // agrandie centrée + titre + statut empilés verticalement.
                // **Story 3.15 v3 (Sophie 2026-05-21)** : compact (padding 10,
                // spacing 6, progression remontée sous le statut sans Spacer)
                // pour que tout le contenu rentre dans une card 140pt sans
                // que la border soit masquée par overflow.
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(Color.coachingSport(forCode: sportCode), lineWidth: 2)
                    Image(systemName: sfSymbol)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(Color.coachingSport(forCode: sportCode))
                }
                .frame(width: 42, height: 42)

                VStack(alignment: .center, spacing: 2) {
                    // **Story 3.28 Phase A** — titre re-localisé selon locale
                    // courante (recalc via AutoTitleBuilder sauf si user rename).
                    Text(verbatim: summary.displayTitle(locale: locale))
                        .font(.coachingBody.weight(.semibold))
                        .foregroundStyle(Color.coachingTextPrimary)
                        .lineLimit(1)
                        // **Story 3.27 Phase C** — les titres composites
                        // (« Couch to 5k — Semaine 2 », « Triathlon — Distance… »)
                        // tronquaient sec à width 200pt. minimumScaleFactor laisse
                        // le titre rétrécir jusqu'à 80% avant de tronquer → plus de
                        // texte lisible sans casser la hauteur de card (130pt) tunée
                        // en Phase A/B (un lineLimit(2) déborderait).
                        .minimumScaleFactor(0.8)
                        .multilineTextAlignment(.center)
                    statusTextView
                        .font(.coachingCaption)
                        .foregroundStyle(summary.isDormant
                                         ? Color.coachingTextSecondary
                                         : Color.coachingTextPrimary)
                        .lineLimit(1)
                        .multilineTextAlignment(.center)
                }

                // **Story 3.15 v3 (Sophie 2026-05-21)** — barre progression
                // remontée juste sous le statut, gain place vs Spacer + bas.
                // **Story 3.15 v5 (Sophie 2026-05-21)** — couleur barre progress
                // = sport (avant doré coachingRecord). Identité visuelle sport
                // cohérente avec border isSelected + icone.
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.coachingSport(forCode: sportCode).opacity(0.18))
                            .frame(height: 4)
                        Capsule()
                            .fill(Color.coachingSport(forCode: sportCode))
                            .frame(width: max(4, geo.size.width * progress), height: 4)
                    }
                }
                .frame(height: 4)

                if let badge {
                    RegenBadgePill(badge: badge)
                }

                // **Story 3.11 AC8** — indicateur discret quand la prochaine
                // séance de ce programme est late (semaine en attente).
                if summary.nextSessionIsLate, let weekN = summary.nextSession?.weekNumber {
                    Text(verbatim: String(
                        format: String.localized("dashboard.program.weekLate.format", locale: locale),
                        weekN
                    ))
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(Color.coachingWarning)
                    .lineLimit(1)
                    .accessibilityIdentifier("dashboard.active.program.weekLate")
                }
                // **Story 3.15 v6 (Sophie 2026-05-21)** — fix vide bas card :
                // retiré le `maxHeight: .infinity, alignment: .top` qui étirait
                // la card sur toute la hauteur du carrousel (152pt) en laissant
                // ~50pt de vide sous la barre progression. Maintenant : hauteur
                // intrinsèque, frame ScrollView descendue à 118pt pour fit
                // pile le contenu.
            }
            .padding(.horizontal, 10)
            .padding(.top, 10)
            .padding(.bottom, 8)
            .frame(maxWidth: .infinity)
            .background(Color.coachingCard)
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(
                        isSelected ? Color.coachingSport(forCode: sportCode) : Color.clear,
                        lineWidth: 2
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("dashboard.active.program.\(sportCode)")
    }

    private var progress: Double {
        guard summary.totalSessions > 0 else { return 0 }
        return min(max(Double(summary.totalSessionsCompleted) / Double(summary.totalSessions), 0), 1)
    }

    /// **Story 3.10 AC21** — texte de statut affiché sous le `templateName`.
    ///   - dormant             → "Non commencé"
    ///   - programme complété  → "Programme terminé" (P1 #4 ui-reviewer)
    ///   - démarré, semaine X  → "Semaine X — Y/Z séances"
    ///
    /// Pour la branche interpolée, on passe par `String.localized(_:locale:)`
    /// qui utilise le bundle de la langue applicative (P0 #2 ui-reviewer fix).
    @ViewBuilder
    private var statusTextView: some View {
        if summary.isDormant {
            Text("dashboard.program.notStarted")
        } else if summary.isProgramCompleted {
            Text("dashboard.program.completed")
        } else {
            Text(verbatim: String(
                format: String.localized("dashboard.program.weekStatus.format", locale: locale),
                summary.currentWeekNumber,
                summary.weekCompletedSessions,
                summary.weekTotalSessions
            ))
        }
    }

    private var sfSymbol: String {
        switch sportCode {
        case "running": return "figure.run"
        case "cycling": return "figure.outdoor.cycle"
        case "swimming": return "figure.pool.swim"
        case "triathlon": return "figure.mixed.cardio"
        case "strengthTraining": return "dumbbell.fill"
        case "yoga": return "figure.yoga"
        case "hiit": return "bolt.heart.fill"
        case "hiking": return "figure.hiking"
        case "tennis": return "figure.tennis"
        case "football": return "soccerball"
        default: return "questionmark.circle"
        }
    }
}

// MARK: - Next session card (Story 3.10 — sous le carrousel)

/// **Story 3.10 AC24** — card de la prochaine séance du programme sélectionné.
/// Cas couverts (AC24) :
///   - **Dormant** → "Non commencé" + bouton "Démarrer".
///   - **Démarré, séance dispo** → titre + meta + bouton "Démarrer".
///   - **Semaine complétée** → placeholder "Semaine X complétée — patience"
///     (vrai blocage doux livré Story 3.11).
///   - **Programme complété** → "Programme terminé" (transitoire avant
///     auto-archive AC14).
private struct NextSessionCard: View {
    let summary: ProgramSummary
    let onTapStart: () -> Void
    let onTapDetail: () -> Void
    /// **Story 3.11** — handler du bouton "Replanifier". nil = bouton caché
    /// (cas non-late ou routine cyclique). Ouvert par le parent qui détient
    /// l'état de la sheet.
    var onTapReplanify: (() -> Void)? = nil

    /// **Story 3.10 P0 #2 fix ui-reviewer** — locale courante pour résoudre les
    /// `String.localizedStringWithFormat` via le bundle de la langue applicative
    /// (cf `LanguageManager` → `String.localized(_:locale:)`). Sinon les strings
    /// interpolées restent dans la locale système iOS et créent un mix FR/EN
    /// quand l'user a sélectionné EN dans le picker langue mais que iOS est FR.
    @Environment(\.locale) private var locale

    var body: some View {
        let focalSportCode: String = {
            if let session = summary.nextSession {
                return SessionSportInference.sportCode(
                    for: session,
                    programSportCode: summary.sport.appSportCode
                )
            }
            return summary.sport.appSportCode
        }()
        VStack(alignment: .leading, spacing: 10) {
            content
        }
        // **Story 3.15 raffinement 2026-05-21** — padding réduit (16→12) pour
        // alléger visuellement la card focale (retour Sophie : "un peu moins
        // grosse").
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        // **Story 3.15 v4 (Sophie 2026-05-21)** — fond gradient couleur du sport
        // DE LA SÉANCE (déduit via heuristique pour Triathlon). Avant : sport
        // du programme → "Run Daniels-E" dans Triathlon avait fond doré
        // triathlon. Maintenant : fond bleu running car la séance est running.
        .background(
            LinearGradient(
                colors: [
                    Color.coachingSport(forCode: focalSportCode),
                    Color.coachingSport(forCode: focalSportCode).opacity(0.82)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        // **Story 3.15 raffinement 2026-05-21** — tap sur la card focal (n'importe
        // où sauf le bouton Démarrer) → push SessionDetailView. Avant : seul le
        // bouton agissait, le reste de la card était inerte.
        .contentShape(Rectangle())
        .onTapGesture { onTapDetail() }
        .accessibilityIdentifier("dashboard.active.next")
    }

    @ViewBuilder
    private var content: some View {
        // **Story 3.10 P0 #1 fix ui-reviewer** — programmes dormants en TÊTE
        // de la cascade. Sans ce check, la chaîne tombe sur `nextSession == nil`
        // (logique : pas démarré = pas de next) puis fallback à
        // `programCompletedState`, ce qui montre "Programme terminé" sur un
        // programme jamais démarré. Bug fonctionnel rendu par ui-reviewer.
        if summary.isDormant {
            dormantState
        } else if summary.isProgramCompleted {
            programCompletedState
        } else if summary.isWeekCompleted {
            weekCompletedState
        } else if let session = summary.nextSession {
            sessionState(session: session)
        } else {
            // Programme démarré sans next session disponible (cas dégénéré).
            programCompletedState
        }
    }

    /// **Story 3.10 P0 #1** — état dormant : titre "Non commencé" + CTA pill
    /// "Démarrer" (qui appelle `markStarted` + push AdaptedProgramView via
    /// le caller).
    private var dormantState: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "hourglass.bottomhalf.filled")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(Color.coachingOnPrimary)
                Text("dashboard.program.notStarted")
                    .font(.system(size: 19, weight: .semibold, design: .serif))
                    .foregroundStyle(Color.coachingOnPrimary)
            }
            Text("dashboard.program.notStarted.subtitle")
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(Color.coachingOnPrimary.opacity(0.85))
            startButton
        }
    }

    private func sessionState(session: PersistedSession) -> some View {
        // **Story 3.27 Phase A (party 2026-05-30 décisions D3+D4)** — card focal
        // STABLE : taille constante peu importe l'état (Today / Late / Demain).
        // Le pain point n°1 du dashboard pré-3.27 était l'expansion verticale
        // de cette card en mode Late (badge + texte explicatif "Cette séance
        // était prévue semaine du..." + bouton Replanifier = +4 lignes vs
        // état normal). Sophie : « card prochaine séance comme avant mais
        // qui ne soit pas 4 fois plus grande si je suis en retard ».
        //
        // Conservé : badge `lateBadge` en tête (signal état, taille fixe).
        // Retiré : sous-titre explicatif Late + bouton Replanifier (cf D4 :
        // Replanifier accessible désormais uniquement dans AdaptedProgramView,
        // ne plus alourdir le hub central).
        VStack(alignment: .leading, spacing: 10) {
            if summary.nextSessionIsLate {
                lateBadge
            }
            HStack(alignment: .center, spacing: 10) {
                Text(verbatim: session.name)
                    .font(.system(size: 17, weight: .semibold, design: .serif))
                    .foregroundStyle(Color.coachingOnPrimary)
                    .lineLimit(2)
                Spacer(minLength: 0)
                startButton
            }
            HStack(spacing: 8) {
                sessionCoordinatePill(session: session)
                sessionTypePill(session: session)
                Text(verbatim: durationLine(session: session))
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(Color.coachingOnPrimary.opacity(0.85))
            }
        }
    }

    /// **Story 3.15 v4 (Sophie 2026-05-21)** — pill "S2" (semaine seule). Avant
    /// : "S2 · J3" mais Sophie a confirmé qu'on ne gère plus la sémantique du
    /// jour calendaire (cf refonte vue semaine Story 3.12). Localisation
    /// `dashboard.active.next.coordinate.format` ne prend qu'un argument.
    private func sessionCoordinatePill(session: PersistedSession) -> some View {
        Text(verbatim: String(
            format: String.localized("dashboard.active.next.coordinate.format", locale: locale),
            session.weekNumber
        ))
        .font(.system(size: 11, weight: .semibold))
        .foregroundStyle(Color.coachingOnPrimary)
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(Color.coachingOnPrimary.opacity(0.18))
        .clipShape(Capsule())
        .accessibilityIdentifier("dashboard.active.next.coordinate")
    }

    /// **Story 3.15 v3** — extrait "30 min" depuis le metaLine (sem · durée
    /// avant). La semaine est désormais portée par le pill coordinate, donc
    /// la durée seule reste ici.
    private func durationLine(session: PersistedSession) -> String {
        String(
            format: String.localized("dashboard.active.next.duration.format", locale: locale),
            session.durationMinutes
        )
    }

    /// **Story 3.15** — pill intensité (type de séance) inscrit dans la card
    /// focale. Mapping i18n statique via `SessionType.localizedKey` (cf
    /// `SportCodeMapping.swift`). Style : capsule pâle sur fond bleu coach.
    private func sessionTypePill(session: PersistedSession) -> some View {
        Text(session.type.localizedKey)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(Color.coachingOnPrimary)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Color.coachingOnPrimary.opacity(0.18))
            .clipShape(Capsule())
            .accessibilityIdentifier("dashboard.active.next.sessionType")
    }

    /// **Story 3.11 AC7** — pill "En retard" avec icône `clock.badge.exclamationmark`.
    private var lateBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: "clock.badge.exclamationmark")
                .font(.system(size: 11, weight: .semibold))
            Text("dashboard.session.late.badge")
                .font(.system(size: 11, weight: .semibold))
        }
        .foregroundStyle(Color.coachingWarning)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.coachingWarning.opacity(0.18))
        .clipShape(Capsule())
        .accessibilityIdentifier("dashboard.active.next.lateBadge")
    }

    private var programCompletedState: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(Color.coachingOnPrimary)
                Text("dashboard.program.completed")
                    .font(.system(size: 18, weight: .semibold, design: .serif))
                    .foregroundStyle(Color.coachingOnPrimary)
            }
            Button(action: onTapDetail) {
                Text("dashboard.program.viewDetail")
                    .font(.coachingBody.weight(.semibold))
                    .foregroundStyle(Color.coachingPrimary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.coachingOnPrimary)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
    }

    private var weekCompletedState: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "calendar.badge.checkmark")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(Color.coachingOnPrimary)
                // P0 #2 ui-reviewer — pass via `String.localized(_:locale:)` qui
                // utilise le bundle de la langue applicative, pas la locale
                // système iOS.
                Text(verbatim: String(
                    format: String.localized("dashboard.program.weekCompleted.format", locale: locale),
                    summary.currentWeekNumber
                ))
                .font(.system(size: 18, weight: .semibold, design: .serif))
                .foregroundStyle(Color.coachingOnPrimary)
            }
            Text("dashboard.program.weekCompleted.subtitle")
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(Color.coachingOnPrimary.opacity(0.85))
        }
    }

    /// **Story 3.15 v3 (Sophie 2026-05-21)** — bouton Démarrer compact en
    /// icône circulaire (avant : pill texte + flèche prenait toute la largeur).
    /// `play.fill` symbole universel (cf Apple Fitness, Strava, Nike TC).
    /// AccessibilityLabel pour VoiceOver + long-press iOS = tooltip natif.
    private var startButton: some View {
        Button(action: onTapStart) {
            Image(systemName: "play.fill")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Color.coachingPrimary)
                .frame(width: 40, height: 40)
                .background(Color.coachingOnPrimary)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text("dashboard.program.start.button"))
        .accessibilityIdentifier("dashboard.active.next.cta")
    }
}

// MARK: - Regen badge pill (Phase B.5)

/// Pill discrète affichée sous la `metaLine` du `ProgramCard` quand une regen
/// S+1 a été appliquée cette semaine. Couleur change selon `requiresRebuild`
/// (orange/alerte en cas de restart, bleu/info sinon). i18n FR/EN différée à
/// la B.7 — pour l'instant `reasonKey` se résoud sur la clé brute si absente
/// du `Localizable.xcstrings`.
private struct RegenBadgePill: View {
    let badge: RegenBadge

    private var tint: Color {
        badge.requiresRebuild ? Color.coachingError : Color.coachingPrimary
    }

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "sparkles")
                .font(.system(size: 10, weight: .semibold))
            Text(badge.reasonKey)
                .font(.system(size: 11, weight: .medium))
                .lineLimit(1)
            Spacer(minLength: 4)
            Text(verbatim: badge.percentLabel)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .monospacedDigit()
        }
        .foregroundStyle(tint)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(tint.opacity(0.10))
        .clipShape(Capsule())
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("dashboard.active.program.regenBadge")
    }
}

// MARK: - Swipe to delete row

/// Wrapper qui ajoute un swipe-to-delete (gesture vers la gauche, bouton trash
/// dévoilé à droite) à n'importe quelle row. Pattern iOS classique. On
/// n'utilise pas `.swipeActions` natif car il requiert un `List`, ce qui
/// casserait le design custom des cards (background `coachingCard`, padding,
/// shadows). Implementation custom DragGesture + offset.
private struct SwipeToDeleteRow<Content: View>: View {
    let onDelete: () -> Void
    @ViewBuilder let content: () -> Content

    @State private var revealed: Bool = false
    @State private var dragOffset: CGFloat = 0
    /// Sophie 2026-05-10 : confirmation avant suppression (action destructive +
    /// archive seulement = pas critique mais on évite les false-positifs swipe).
    @State private var showDeleteConfirmation: Bool = false

    private static var trashWidth: CGFloat { 80 }
    private static var revealThreshold: CGFloat { 40 }

    var body: some View {
        ZStack(alignment: .trailing) {
            Button {
                showDeleteConfirmation = true
            } label: {
                Image(systemName: "trash.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: Self.trashWidth)
                    .frame(maxHeight: .infinity)
                    .background(Color.coachingError)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .accessibilityLabel(Text("dashboard.active.program.delete.label"))
            }
            .opacity((revealed || dragOffset < 0) ? 1 : 0)
            .sheet(isPresented: $showDeleteConfirmation) {
                DeleteConfirmationSheet(
                    onConfirm: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            revealed = false
                            dragOffset = 0
                        }
                        onDelete()
                    },
                    onCancel: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            revealed = false
                            dragOffset = 0
                        }
                    }
                )
                .presentationDetents([.height(320)])
                .presentationBackground(Color.coachingBackground)
                .presentationDragIndicator(.visible)
            }

            content()
                .offset(x: revealed ? -Self.trashWidth + dragOffset : dragOffset)
                // simultaneousGesture + minimumDistance 25 : permet au DragGesture de
                // coexister avec le Button(onTap) du ProgramCard wrappé. Sans ça
                // le Button consomme l'event avant le drag (Sophie 2026-05-10
                // "je n'arrive pas à swipper, j'ouvre systématiquement le programme").
                // Le seuil 25pt évite les faux positifs de drag sur un tap maladroit.
                .simultaneousGesture(
                    DragGesture(minimumDistance: 25, coordinateSpace: .local)
                        .onChanged { value in
                            // On ne réagit qu'aux mouvements horizontaux dominants
                            // (sinon scroll vertical dans la liste = aussi déclenché).
                            guard abs(value.translation.width) > abs(value.translation.height) else {
                                return
                            }
                            let raw = value.translation.width
                            if revealed {
                                dragOffset = max(0, min(Self.trashWidth, raw))
                            } else {
                                dragOffset = max(-Self.trashWidth, min(0, raw))
                            }
                        }
                        .onEnded { _ in
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                if revealed {
                                    if dragOffset > Self.revealThreshold {
                                        revealed = false
                                    }
                                    dragOffset = 0
                                } else {
                                    if dragOffset < -Self.revealThreshold {
                                        revealed = true
                                    }
                                    dragOffset = 0
                                }
                            }
                        }
                )
        }
    }
}

// MARK: - Delete confirmation sheet (cohérence couleurs CoachingSage)

/// Sheet custom utilisé en remplacement du `confirmationDialog` système (fond
/// blanc qui jurait avec coachingBackground). Pattern alert iOS-like avec
/// hero icon trash + titre + message + boutons. Sophie 2026-05-10.
private struct DeleteConfirmationSheet: View {
    let onConfirm: () -> Void
    let onCancel: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle().fill(Color.coachingError.opacity(0.12))
                Image(systemName: "trash.fill")
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(Color.coachingError)
            }
            .frame(width: 56, height: 56)
            .padding(.top, 24)

            Text("dashboard.active.program.delete.confirm.title")
                .font(.title3.weight(.bold))
                .foregroundStyle(Color.coachingTextPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Text("dashboard.active.program.delete.confirm.message")
                .font(.coachingBody)
                .foregroundStyle(Color.coachingTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Spacer(minLength: 0)

            VStack(spacing: 10) {
                Button(role: .destructive) {
                    onConfirm()
                    dismiss()
                } label: {
                    Text("dashboard.active.program.delete.confirm.action")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.coachingError)

                Button {
                    onCancel()
                    dismiss()
                } label: {
                    Text("common.cancel")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)
                }
                .foregroundStyle(Color.coachingTextSecondary)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 18)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.coachingBackground)
    }
}

// MARK: - Color hex helper

private extension Color {
    init(hex: UInt32, opacity: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: opacity)
    }
}
