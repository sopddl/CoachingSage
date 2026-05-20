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
    var onTapReplanify: ((ProgramSummary) -> Void)? = nil
    /// **Story 3.15 AC7** — tap sur le teaser N+1. Navigue vers le programme
    /// sélectionné (la session ciblée est traitée par le caller — coordonnée
    /// éventuellement passée à `AdaptedProgramView`). No-op si nil.
    var onTapTeaser: ((ProgramSummary, PersistedSession) -> Void)? = nil

    private var selectedSummary: ProgramSummary? {
        if let selectedId, let s = startedPrograms.first(where: { $0.id == selectedId }) { return s }
        return startedPrograms.first
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // **Story 3.15** — Zone 1 : carrousel "Programmes en cours" (started only).
            // Carrousel snap unique (suppression layouts adaptatifs 1/2/3 hérités
            // de Story 3.12 : le carrousel marche aussi bien à 1 card qu'à 5).
            if !startedPrograms.isEmpty {
                section(titleKey: "dashboard.section.in_progress.title") {
                    programCarousel
                }
            }

            // **Story 3.15** — Zone 2 : séance focale (NextSessionCard) +
            // teaser N+1 (NextSessionTeaser) — toujours visibles ensemble dès
            // qu'on a une sélection. Suppression du `shouldShowNextSessionCard`
            // hérité (seuils 1 ou ≥4) : la focale s'affiche désormais TOUJOURS
            // quand un programme est sélectionné.
            if let selectedSummary {
                section(titleKey: "dashboard.section.next_session.title") {
                    VStack(spacing: 12) {
                        NextSessionCard(
                            summary: selectedSummary,
                            onTapStart: { onTapStartSession(selectedSummary) },
                            onTapDetail: { onTapProgram(selectedSummary) },
                            onTapReplanify: onTapReplanify.map { handler in
                                { handler(selectedSummary) }
                            }
                        )
                        // Teaser N+1 toujours visible juste sous la focale
                        // (décision Sophie 2026-05-20 figée).
                        NextSessionTeaser(
                            teaserSession: teaserSession,
                            hasFocal: selectedSummary.nextSession != nil,
                            onTapTeaser: { session in
                                onTapTeaser?(selectedSummary, session)
                            }
                        )
                    }
                }
            }

            // **Story 3.15** — Zone 3 : liste "Préparés" (dormants en liste
            // verticale scrollable). Affichée uniquement si dormantPrograms ≠ ∅.
            if !dormantPrograms.isEmpty {
                DormantProgramsList(
                    dormants: dormantPrograms,
                    onTapProgram: onTapProgram,
                    onDeleteProgram: onDeleteProgram
                )
            }
        }
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
            LazyHStack(spacing: 12) {
                ForEach(startedPrograms) { summary in
                    SwipeToDeleteRow(onDelete: { onDeleteProgram(summary) }) {
                        ProgramCard(
                            summary: summary,
                            badge: regenBadges[summary.id],
                            isSelected: summary.id == effectiveSelectedId,
                            onTap: {
                                if summary.id == effectiveSelectedId {
                                    // 2e tap sur card déjà focalisée → push vers AdaptedProgramView
                                    onTapProgram(summary)
                                } else {
                                    // 1er tap sur card non-focalisée → la
                                    // sélectionne (séance focale + teaser
                                    // suivent). Plus fiable que le snap iOS 17
                                    // sur simu où la souris ne reconnaît pas
                                    // toujours les swipes courts.
                                    onSelectProgram(summary.id)
                                }
                            }
                        )
                    }
                    .frame(width: 200)
                    .id(summary.id)
                }
            }
            .scrollTargetLayout()
            .padding(.horizontal, 1)
        }
        .frame(height: 170)
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
}

// MARK: - Program card (Story 3.10 — carrousel horizontal)
//
// Anciennes vues `DominantNextSessionCard`, `RestDayCard` et `WeeklyStatsWidget`
// supprimées en Story 3.10 — la card dominante a été remplacée par le
// `ProgramCard` + `NextSessionCard` du carrousel.

private struct ProgramCard: View {
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
            VStack(alignment: .center, spacing: 10) {
                // **Story 3.12** — Header card en mode portrait : icône sport
                // agrandie centrée + titre + statut empilés verticalement, tous
                // alignés au centre pour un look "tile" cohérent.
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(Color.coachingSport(forCode: sportCode), lineWidth: 2)
                    Image(systemName: sfSymbol)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(Color.coachingSport(forCode: sportCode))
                }
                .frame(width: 48, height: 48)

                VStack(alignment: .center, spacing: 2) {
                    Text(verbatim: summary.templateName)
                        .font(.coachingBody.weight(.semibold))
                        .foregroundStyle(Color.coachingTextPrimary)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                    statusTextView
                        .font(.coachingCaption)
                        .foregroundStyle(summary.isDormant
                                         ? Color.coachingTextSecondary
                                         : Color.coachingTextPrimary)
                        .lineLimit(1)
                        .multilineTextAlignment(.center)
                }

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

                Spacer(minLength: 0)

                // Barre de progression (programme entier).
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.coachingRecord.opacity(0.15))
                            .frame(height: 4)
                        Capsule()
                            .fill(Color.coachingRecord)
                            .frame(width: max(4, geo.size.width * progress), height: 4)
                    }
                }
                .frame(height: 4)
            }
            .padding(14)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color.coachingCard)
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(
                        isSelected ? Color.coachingPrimary : Color.clear,
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
        VStack(alignment: .leading, spacing: 12) {
            content
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [Color(hex: 0x1E5090), Color(hex: 0x2B5F8A)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
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
        VStack(alignment: .leading, spacing: 12) {
            // **Story 3.11 AC7** — badge "En retard" en TÊTE de la card quand
            // la prochaine séance est late.
            if summary.nextSessionIsLate {
                lateBadge
            }
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(verbatim: session.name)
                    .font(.system(size: 19, weight: .semibold, design: .serif))
                    .foregroundStyle(Color.coachingOnPrimary)
                    .lineLimit(2)
                Spacer(minLength: 0)
            }
            // **Story 3.15 (raffinement Sophie 2026-05-20)** — pill intensité
            // (type de séance) à côté du metaLine pour enrichir visuellement la
            // card focale (avant : juste "Sem 2 · 30 min" → ressentait vide).
            HStack(spacing: 8) {
                sessionTypePill(session: session)
                Text(verbatim: metaLine(session: session))
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(Color.coachingOnPrimary.opacity(0.85))
            }
            // **Story 3.11 AC7** — sous-titre "Cette séance était prévue
            // semaine du {date}" — date = lundi de la semaine de la séance.
            if summary.nextSessionIsLate, let weekStartLabel = lateSessionWeekStartLabel(session: session) {
                Text(verbatim: String(
                    format: String.localized("dashboard.session.late.subtitle.format", locale: locale),
                    weekStartLabel
                ))
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(Color.coachingOnPrimary.opacity(0.85))
            }
            HStack(spacing: 10) {
                startButton
                // **Story 3.11 AC9** — bouton Replanifier secondaire à droite de
                // Démarrer. Visible UNIQUEMENT si late + callback fourni (qui n'est
                // câblé par SessionView que pour les modes deadline non-cyclic).
                if summary.nextSessionIsLate, let onTapReplanify {
                    replanifyButton(action: onTapReplanify)
                }
            }
        }
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

    /// **Story 3.11 AC9** — bouton secondaire "Replanifier" (style ghost on dark).
    private func replanifyButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: "calendar.badge.clock")
                    .font(.footnote.weight(.semibold))
                Text("replanify.button")
                    .font(.coachingBody.weight(.semibold))
            }
            .foregroundStyle(Color.coachingOnPrimary)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .overlay(
                Capsule()
                    .strokeBorder(Color.coachingOnPrimary.opacity(0.7), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("dashboard.active.next.replanify")
    }

    /// **Story 3.11 AC7** — date début de la semaine de la séance en retard,
    /// formatée selon la locale courante (FR "EEEE d MMMM" / EN "EEEE, MMMM d").
    /// Retourne `nil` si `weekStartDate` du programme est absent (cas dégénéré).
    private func lateSessionWeekStartLabel(session: PersistedSession) -> String? {
        guard let programStart = summary.weekStartDate else { return nil }
        let weekIndex = max(0, session.weekNumber - 1)
        let sessionWeekStart = Calendar.current.date(
            byAdding: .day,
            value: weekIndex * 7,
            to: programStart
        ) ?? programStart
        let formatter = DateFormatter()
        formatter.locale = locale
        let langCode = locale.language.languageCode?.identifier ?? "en"
        formatter.dateFormat = langCode == "fr" ? "EEEE d MMMM" : "EEEE, MMMM d"
        return formatter.string(from: sessionWeekStart)
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

    private var startButton: some View {
        Button(action: onTapStart) {
            HStack(spacing: 6) {
                Text("dashboard.program.start.button")
                    .font(.coachingBody.weight(.semibold))
                Image(systemName: "arrow.right")
                    .font(.footnote.weight(.semibold))
            }
            .foregroundStyle(Color.coachingPrimary)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.coachingOnPrimary)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("dashboard.active.next.cta")
    }

    private func metaLine(session: PersistedSession) -> String {
        // P0 #2 ui-reviewer — utilise locale courante (LanguageManager).
        String(
            format: String.localized("dashboard.active.next.meta", locale: locale),
            session.weekNumber,
            session.durationMinutes
        )
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
