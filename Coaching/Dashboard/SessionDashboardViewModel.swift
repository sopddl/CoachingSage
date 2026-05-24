// Coaching/Dashboard/SessionDashboardViewModel.swift
// Story 3.8 — VM lecture seule du dashboard Séances.
//
// **Story 3.10 (2026-05-17)** — Refonte `Mode` :
//   - `.empty`              : 0 programme actif → vue mode vide (hero + 3 templates).
//   - `.active(programs, selectedId)` : ≥ 1 programme actif → carrousel horizontal
//     façon Decathlon Coach + NextSessionCard pour le programme sélectionné.
//
// Avant 3.10, on avait `.singleProgram` et `.multiProgram` (avec card dominante).
// Le pattern carrousel unifie les deux : un seul card type = `ProgramCard`,
// sélection par défaut = première card.
//
// Le mode `.restDay` (gradient vert nature) est une **variante visuelle** du
// mode actif — il dépend de la prochaine session > J+0, pas d'un état VM distinct.
//
// **VM lecture** : pas d'écriture programme/routine. Sous-tâche 6 ajoute le
// chargement des suggestions `selectTopN` pour alimenter le mode vide.
//
// **Story 3.4 Phase B.4 — auto-trigger regen S+1** : si un
// `WeeklyRegenApplicationService` est injecté, `refresh()` l'invoque AVANT le
// `fetchActive`. La regen mute les sessions S+1 des records actifs en place
// (idempotent côté service : journal `(recordId, targetWeek)` + re-entrance
// guard par `userId`). Best-effort : un throw est silencé pour ne pas bloquer
// l'affichage du dashboard.
import Foundation
import os
import SwiftUI
import TemplateModel

@MainActor
@Observable
final class SessionDashboardViewModel {
    /// **Story 3.15** — 3 modes du dashboard Séances après refonte hiérarchique :
    ///   - `.empty`         : 0 lancé + 0 dormant → CTA central simple
    ///   - `.dormantOnly(dormants)` : 0 lancé + N dormants → liste "Préparés"
    ///                                 remontée en tête, pas de carrousel ni
    ///                                 séance focale
    ///   - `.active(started, dormants, selectedId)` : ≥ 1 lancé → carrousel +
    ///                                                 séance focale + teaser
    ///                                                 N+1 + (optionnel) liste
    ///                                                 "Préparés" dessous
    ///
    /// Le mode hérité Story 3.10 `.active(programs:, selectedId:)` est remplacé
    /// pour refléter la nouvelle hiérarchie 3 zones. `selectedId` ne référence
    /// QUE des `started` (jamais un dormant).
    enum Mode: Equatable {
        case empty
        case dormantOnly(dormants: [ProgramSummary])
        case active(started: [ProgramSummary], dormants: [ProgramSummary], selectedId: UUID?)

        static func == (lhs: Mode, rhs: Mode) -> Bool {
            switch (lhs, rhs) {
            case (.empty, .empty):
                return true
            case let (.dormantOnly(ld), .dormantOnly(rd)):
                return ld == rd
            case let (.active(ls, ld, lsel), .active(rs, rd, rsel)):
                return ls == rs && ld == rd && lsel == rsel
            default:
                return false
            }
        }
    }

    private(set) var mode: Mode = .empty
    private(set) var loading: Bool = true
    private(set) var error: String?

    /// **Story 3.10** — map interne `record.id → AdaptedProgramRecord` mise à jour
    /// à chaque `refresh`. Sert aux helpers (`modifiedSessionCoordinates`,
    /// `pushAdaptedProgram` côté View) qui ont besoin du `record` complet alors
    /// que `ProgramSummary` ne porte que les champs plats nécessaires à l'UI.
    private(set) var recordsByID: [UUID: AdaptedProgramRecord] = [:]

    /// Templates suggérés en mode vide (3 par défaut, calibrés sur autoprofil
    /// + sports onboarding). Vide tant que `mode != .empty`.
    /// **Story 3.15** : déprécié — Phase 3 supprime cette propriété et le call-site
    /// `SessionView.swift:242`. Les "suggestions" deviennent des dormants persistés
    /// via `DormantBootstrapService` au post-onboarding.
    private(set) var emptyModeSuggestions: [ProgramTemplate] = []

    /// Sports actifs déclarés à l'onboarding (passé au questionnaire universel
    /// quand l'utilisateur tape « Voir → » sur une suggestion). Cache de
    /// `CoachingProfile.activeSports` pour ne pas relancer un fetch côté Vue.
    private(set) var declaredSportCodes: [String] = []

    /// **Story 3.15 AC1** — programmes démarrés (`weekStartDate != nil`), triés
    /// par `lastUpdatedAt desc`. Source de vérité pour le carrousel Zone 1.
    private(set) var startedSummaries: [ProgramSummary] = []

    /// **Story 3.15 AC1** — programmes dormants (`weekStartDate == nil` ET
    /// `isActive == true`), triés par `lastUpdatedAt desc`. Source de vérité pour
    /// la liste "Préparés" Zone 3.
    private(set) var dormantSummaries: [ProgramSummary] = []

    /// **Story 3.15** — concaténation started + dormant (started en tête) pour
    /// les call-sites internes (regen badges, modifiedSessionCoordinates,
    /// tests rétrocompat). Le tri intra-liste suit `lastUpdatedAt desc`.
    /// Les sous-listes pures sont exposées via `startedSummaries` / `dormantSummaries`.
    var activeProgramSummaries: [ProgramSummary] {
        startedSummaries + dormantSummaries
    }

    /// Phase B.5 — badges regen S+1 indexés par `AdaptedProgramRecord.id`. Une
    /// entrée par record dont la regen a été appliquée cette semaine (semaine
    /// courante du calendrier, pas du programme). Vide en l'absence de
    /// `weeklyRegenRepository` ou si aucune regen n'a été appliquée cette semaine.
    private(set) var regenBadgesByRecord: [UUID: RegenBadge] = [:]

    /// Library bundlée chargée à la première `refresh` qui en a besoin
    /// (mode vide pour `selectTopN`, mode actif pour résoudre les `name` de templates).
    /// Cachée pour éviter un reload à chaque `onAppear`.
    private var cachedLibrary: ProgramTemplateLibrary?

    private static let logger = Logger(subsystem: "com.sopddl.coachingsage", category: "session-dashboard-vm")

    private let programRepository: any AdaptedProgramRepository
    private let coachingProfileRepository: any CoachingProfileRepository
    /// Phase B.4 — optionnel pour rester compatible avec les previews + tests
    /// qui n'ont pas besoin du wiring regen. Quand absent, `refresh()` skip
    /// silencieusement l'auto-trigger.
    private let weeklyRegenApplicationService: (any WeeklyRegenApplicationService)?
    /// Phase B.5 — optionnel. Lecture seule : utilisé pour charger les badges
    /// regen de la semaine courante (`fetchJournalForCurrentWeek`). Quand
    /// absent, `regenBadgesByRecord` reste vide.
    private let weeklyRegenRepository: (any WeeklyRegenRepository)?
    private let resolver: NextSessionResolver
    private let templateLibraryProvider: () async throws -> ProgramTemplateLibrary
    private let suggestionLevelProvider: (CoachingProfile?) -> String
    private let nowProvider: () -> Date
    /// **Story 3.15 v7 (Sophie 2026-05-21)** — bootstrap 3 dormants au load
    /// dashboard quand `bootstrappedDormants == false` ET aucun programme.
    /// Sophie : « si moi je veux mes 3 programmes au démarrage ». Le service
    /// est idempotent (set flag avant persistance) donc safe à appeler à
    /// chaque refresh. Avant : trigger uniquement depuis OnboardingViewModel.
    /// finalize(), donc users existants n'avaient jamais le bootstrap.
    private let dormantBootstrapService: DormantBootstrapService?

    /// **Story 3.22-F-bis** — snapshot du `CoachingProfile` chargé au dernier
    /// `refresh()`. Utilisé pour calculer `emptyState` (variante d'affichage
    /// d'`EmptyDashboardView` selon profil + flag bootstrap).
    private(set) var coachingProfileSnapshot: CoachingProfile?

    init(
        programRepository: any AdaptedProgramRepository,
        coachingProfileRepository: any CoachingProfileRepository,
        weeklyRegenApplicationService: (any WeeklyRegenApplicationService)? = nil,
        weeklyRegenRepository: (any WeeklyRegenRepository)? = nil,
        dormantBootstrapService: DormantBootstrapService? = nil,
        resolver: NextSessionResolver = NextSessionResolver(),
        templateLibraryProvider: @escaping () async throws -> ProgramTemplateLibrary = ProgramTemplateLibrary.bundled,
        suggestionLevelProvider: @escaping (CoachingProfile?) -> String = { _ in "beginner" },
        nowProvider: @escaping () -> Date = Date.init
    ) {
        self.programRepository = programRepository
        self.coachingProfileRepository = coachingProfileRepository
        self.weeklyRegenApplicationService = weeklyRegenApplicationService
        self.weeklyRegenRepository = weeklyRegenRepository
        self.dormantBootstrapService = dormantBootstrapService
        self.resolver = resolver
        self.templateLibraryProvider = templateLibraryProvider
        self.suggestionLevelProvider = suggestionLevelProvider
        self.nowProvider = nowProvider
    }

    /// Charge programmes + routines + profil coaching pour le user, calcule la
    /// bascule mode + la prochaine séance dominante + les suggestions mode vide.
    /// Idempotent : peut être rappelée à chaque `onAppear` ou changement utilisateur.
    ///
    /// Phase B.4 : appelle d'abord `weeklyRegenApplicationService.checkAndApplyIfDue`
    /// pour muter les sessions S+1 des records dont la semaine S est close. La
    /// mutation est faite EN PLACE sur les records, donc le `fetchActive` qui
    /// suit voit déjà les bonnes durées. Best-effort : un throw est silencé.
    func refresh(userId: UUID) async {
        loading = true
        error = nil
        // **Story 3.15 v7** — bootstrap idempotent. Si flag déjà true ou si
        // l'user a déjà des programmes, no-op. Sinon, génère jusqu'à 3 dormants
        // via selectTopN. Appelé AVANT fetchActive pour que les dormants frais
        // soient visibles au premier render.
        if let bootstrap = dormantBootstrapService {
            _ = await bootstrap.bootstrapIfNeeded()
        }
        await runAutoRegenIfNeeded(userId: userId)
        await loadRegenBadges(userId: userId)
        do {
            async let programsTask = programRepository.fetchActive(for: userId)
            async let profileTask: CoachingProfile? = try? coachingProfileRepository.fetchCurrentProfile()
            let programs = try await programsTask
            let profile = await profileTask
            coachingProfileSnapshot = profile
            declaredSportCodes = profile?.activeSports ?? []

            // Map records pour les helpers internes (regen, push detail view).
            recordsByID = Dictionary(uniqueKeysWithValues: programs.map { ($0.id, $0) })

            let now = nowProvider()
            if programs.isEmpty {
                mode = .empty
                startedSummaries = []
                dormantSummaries = []
                emptyModeSuggestions = []
            } else {
                emptyModeSuggestions = []
                await ensureLibraryCached()
                // **Story 3.15 AC1** — split started/dormant à la racine.
                let split = makeProgramSummaries(programs: programs, now: now)
                startedSummaries = split.started
                dormantSummaries = split.dormant
                // **Story 3.15 AC3** — bascule sur 3 modes :
                //   - 0 started + N dormants → `.dormantOnly`
                //   - ≥ 1 started → `.active`, selectedId ne référence QUE des started
                if startedSummaries.isEmpty {
                    mode = .dormantOnly(dormants: dormantSummaries)
                } else {
                    let defaultSelection = startedSummaries.first?.id
                    let previousSelection = currentSelectedId
                    let selectedId = previousSelection.flatMap { id in
                        startedSummaries.contains(where: { $0.id == id }) ? id : nil
                    } ?? defaultSelection
                    mode = .active(
                        started: startedSummaries,
                        dormants: dormantSummaries,
                        selectedId: selectedId
                    )
                }
            }
        } catch {
            self.error = error.localizedDescription
            mode = .empty
            startedSummaries = []
            dormantSummaries = []
            emptyModeSuggestions = []
            recordsByID = [:]
        }
        loading = false
    }

    /// **Story 3.22-F-bis** — variante d'`EmptyDashboardView` à afficher en
    /// `mode == .empty`. Calculé à partir de `coachingProfileSnapshot` +
    /// flag `bootstrappedDormants`. Cf `EmptyDashboardState` pour le détail
    /// des conditions.
    var emptyState: EmptyDashboardState {
        guard let profile = coachingProfileSnapshot else { return .noProfile }
        return profile.bootstrappedDormants ? .crossDeviceMissing : .noPrograms
    }

    /// **Story 3.15** — selectedId courant (extrait de `mode.active`).
    /// `nil` en `.empty` ou `.dormantOnly` (pas de notion de selection dans ces
    /// modes — le carrousel n'apparaît pas).
    var currentSelectedId: UUID? {
        if case let .active(_, _, selectedId) = mode { return selectedId }
        return nil
    }

    /// **Story 3.15** — ProgramSummary correspondant au selectedId courant.
    /// Source de vérité pour `NextSessionCard` + `NextSessionTeaser`. `nil` en
    /// `.empty`/`.dormantOnly` ou si la sélection a été flushée par un refresh.
    /// La sélection ne référence QUE des started (jamais un dormant).
    var currentSelectedSummary: ProgramSummary? {
        guard case let .active(started, _, selectedId) = mode else { return nil }
        return started.first { $0.id == selectedId }
    }

    /// **Story 3.15** — bascule la sélection sur une card du carrousel. No-op si :
    ///   - mode ≠ `.active` (notamment `.dormantOnly`)
    ///   - l'id ne référence pas un started (un dormant tap → push direct via
    ///     `DormantProgramsList`, pas via `selectProgram`)
    func selectProgram(id: UUID) {
        guard case let .active(started, dormants, _) = mode else { return }
        guard started.contains(where: { $0.id == id }) else { return }
        mode = .active(started: started, dormants: dormants, selectedId: id)
    }

    /// **Story 3.15 AC7** — session N+1 (teaser) du programme sélectionné,
    /// calculée via `NextSessionResolver.nextTwoSessions(for:now:).teaser`.
    /// `nil` quand pas de programme sélectionné, ou quand la blockingWeek
    /// deadline ne contient qu'1 seule pending. Recalculée à chaque accès.
    var currentTeaserSession: PersistedSession? {
        guard case let .active(_, _, selectedId) = mode,
              let id = selectedId,
              let record = recordsByID[id] else { return nil }
        return resolver.nextTwoSessions(for: record, now: nowProvider()).teaser?.session
    }

    /// **Story 3.15 v4 (Sophie 2026-05-21)** — toutes les sessions pending du
    /// programme sélectionné, APRÈS la séance focale (= drop first). Sert à
    /// la liste verticale "Séances" sous la card focale (avant : 1 seul
    /// teaser "PUIS : ..."). Permet le scroll vertical sur l'écran.
    /// Retourne `[]` quand pas de programme sélectionné ou que la focale est
    /// la dernière session pending.
    var upcomingSessionsAfterFocal: [PersistedSession] {
        guard case let .active(_, _, selectedId) = mode,
              let id = selectedId,
              let record = recordsByID[id] else { return [] }
        let upcoming = resolver.upcomingSessions(for: record, now: nowProvider())
        return Array(upcoming.dropFirst().map(\.session))
    }

    /// Phase B.4 — invoque `WeeklyRegenApplicationService.checkAndApplyIfDue`
    /// si un service est injecté. Best-effort : un throw est juste loggé. Le
    /// service est idempotent (journal + re-entrance guard), un appel à chaque
    /// `refresh()` est sûr et ne mute qu'une fois par `(record, weekS+1)`.
    private func runAutoRegenIfNeeded(userId: UUID) async {
        guard let service = weeklyRegenApplicationService else { return }
        do {
            try await service.checkAndApplyIfDue(userId: userId, now: nowProvider())
        } catch {
            Self.logger.debug("weeklyRegen.checkAndApplyIfDue failed: \(error.localizedDescription)")
        }
    }

    /// Phase B.6 — coordonnées `(weekNumber, day)` des sessions S+1 mutées par
    /// la regen pour ce record. Vide si pas de badge / pas de record actif
    /// correspondant. Utilisé côté `SessionView.pushAdaptedProgram` pour
    /// alimenter `AdaptedProgramView.modifiedSessionCoordinates`.
    func modifiedSessionCoordinates(forRecordId recordId: UUID) -> Set<SessionCoordinate> {
        guard let badge = regenBadgesByRecord[recordId] else { return [] }
        guard let record = recordsByID[recordId] else { return [] }
        let affectedIds = Set(badge.affectedSessionIds)
        return Set(
            record.sessions
                .filter { affectedIds.contains($0.id) }
                .map { SessionCoordinate(weekNumber: $0.weekNumber, day: $0.day) }
        )
    }

    /// Phase B.5 — peuple `regenBadgesByRecord` en lisant le journal des regens
    /// appliquées cette semaine (lundi 00:00 → lundi+7j). Best-effort : sur
    /// erreur ou repo absent, la map reste vide (pas de badge affiché).
    /// Si plusieurs entrées existent pour un même `recordId` (cas edge :
    /// regen appliquée 2 semaines de suite tombant dans la même fenêtre
    /// calendrier), on garde la plus récente (`appliedAt` desc).
    private func loadRegenBadges(userId: UUID) async {
        guard let repo = weeklyRegenRepository else {
            regenBadgesByRecord = [:]
            return
        }
        let now = nowProvider()
        let weekStart = Self.startOfCalendarWeek(for: now)
        do {
            let entries = try await repo.fetchJournalForCurrentWeek(
                userId: userId,
                weekStart: weekStart
            )
            // `entries` est déjà trié desc par `appliedAt`. On garde la 1re
            // occurrence par `recordId` (la plus récente).
            var map: [UUID: RegenBadge] = [:]
            for entry in entries where map[entry.recordId] == nil {
                map[entry.recordId] = RegenBadge.from(entry: entry)
            }
            regenBadgesByRecord = map
        } catch {
            Self.logger.debug("weeklyRegen.fetchJournalForCurrentWeek failed: \(error.localizedDescription)")
            regenBadgesByRecord = [:]
        }
    }

    /// Lundi 00:00 de la semaine calendrier contenant `date`.
    /// **Story 3.10 AC6** : harmonisé sur ISO firstWeekday=2 (cohérence avec
    /// `AdaptedProgramRecord.startOfCurrentWeek()`). Avant 3.10, utilisait
    /// `Calendar.current.dateInterval` qui dépend de la locale système et pouvait
    /// renvoyer dimanche dans certaines locales (en_US etc.).
    private static func startOfCalendarWeek(for date: Date) -> Date {
        var cal = Calendar.current
        cal.firstWeekday = 2
        let comps = cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return cal.date(from: comps) ?? date
    }

    /// Charge la library bundlée et calcule les 3 suggestions via
    /// `ProgramTemplateSelector.selectTopN`. Échec library → liste vide
    /// (la vue mode vide affichera son fallback générique).
    private func loadEmptyModeSuggestions(profile: CoachingProfile?) async {
        await ensureLibraryCached()
        guard let library = cachedLibrary else {
            emptyModeSuggestions = []
            return
        }
        let selector = ProgramTemplateSelector(library: library)
        let topNProfile = TopNSelectionProfile(
            level: suggestionLevelProvider(profile),
            sportCodes: profile?.activeSports ?? []
        )
        emptyModeSuggestions = selector.selectTopN(profile: topNProfile, n: 3)
    }

    /// Charge la library une seule fois et la garde en cache pour les usages
    /// suivants (`selectTopN` mode vide + résolution des `name` mode actif).
    private func ensureLibraryCached() async {
        guard cachedLibrary == nil else { return }
        cachedLibrary = try? await templateLibraryProvider()
    }

    /// **Story 3.15 AC1** — Construit les `ProgramSummary` plats + split en
    /// `(started, dormant)`. Chaque sous-liste triée par `lastUpdatedAt desc`
    /// (programme manipulé récemment en tête).
    ///
    /// **Tuple convention** :
    ///   - `started` : `weekStartDate != nil`
    ///   - `dormant` : `weekStartDate == nil` (et `isActive == true`, déjà
    ///     filtré par `programRepository.fetchActive`)
    ///
    /// Le tri intra-liste n'utilise plus `nextDate asc` (Story 3.10) : depuis
    /// Story 3.12 la refonte vue semaine fait que `effectiveDate` du resolver
    /// est toujours `now`. `lastUpdatedAt desc` met en tête le programme touché
    /// en dernier.
    private func makeProgramSummaries(
        programs: [AdaptedProgramRecord],
        now: Date
    ) -> (started: [ProgramSummary], dormant: [ProgramSummary]) {
        let summaries = programs.map { record -> ProgramSummary in
            let nextResult = resolver.nextSession(for: record, now: now)
            let resolvedName = cachedLibrary?.templates
                .first { $0.id == record.templateId }?.name ?? record.templateId
            let sport = Sport(sportCode: record.sportCode) ?? .running
            let total = record.sessions.count
            let completed = record.completionState.completedCount
            let currentWeek = currentWeekNumber(for: record, now: now)
            let weekTotalSessions = record.sessions.filter { $0.weekNumber == currentWeek }.count
            let weekCompletedSessions = record.sessions
                .filter { $0.weekNumber == currentWeek }
                .filter { record.completionState.sessionRecords[$0.id] != nil }
                .count
            // **Story 3.11 AC6** — late = blocage doux actif ET prochaine
            // séance pointe sur une semaine antérieure à `currentWeek`.
            let isLate: Bool
            switch record.durationMode {
            case .deadlineFixed, .deadlineEstimated:
                if let nextWeek = nextResult?.session.weekNumber {
                    isLate = nextWeek < currentWeek
                } else {
                    isLate = false
                }
            case .routineCyclic:
                isLate = false
            }
            // **Story 3.12** : titre affiché = `customTitle` édité par l'user
            // (priorité), sinon le `templateName` du template (fallback rétro-compat
            // records pré-Story 3.12 sans `customTitle`).
            let displayTitle: String = {
                if let title = record.customTitle, !title.isEmpty { return title }
                return resolvedName
            }()
            return ProgramSummary(
                id: record.id,
                templateName: displayTitle,
                sport: sport,
                weekStartDate: record.weekStartDate,
                durationMode: record.durationMode,
                mode: record.mode,
                nextSession: nextResult?.session,
                currentWeekNumber: currentWeek,
                weekCompletedSessions: weekCompletedSessions,
                weekTotalSessions: weekTotalSessions,
                totalSessionsCompleted: completed,
                totalSessions: total,
                lastUpdatedAt: record.lastUpdatedAt,
                nextSessionIsLate: isLate
            )
        }
        let started = summaries
            .filter { $0.weekStartDate != nil }
            .sorted { $0.lastUpdatedAt > $1.lastUpdatedAt }
        let dormant = summaries
            .filter { $0.weekStartDate == nil }
            .sorted { $0.lastUpdatedAt > $1.lastUpdatedAt }
        return (started: started, dormant: dormant)
    }

    /// Numéro de semaine courante du programme (1-indexed). 1 si dormant
    /// (`weekStartDate == nil`) — on considère qu'à l'instant du markStarted,
    /// l'utilisateur attaque la semaine 1.
    private func currentWeekNumber(for record: AdaptedProgramRecord, now: Date) -> Int {
        guard let start = record.weekStartDate else { return 1 }
        let days = Calendar.current.dateComponents([.day], from: start, to: now).day ?? 0
        return max(1, (days / 7) + 1)
    }
}

/// **Story 3.10** — Résumé plat d'un programme actif pour le carrousel et la
/// NextSessionCard. Découplage VM/Vue : la View consomme un type sans replonger
/// dans `AdaptedProgramRecord.sessions` ni dans la library à chaque render.
///
/// **Story 3.11** — ajoute `nextSessionIsLate: Bool` pour le badge "En retard"
/// (blocage doux des modes deadline) + `nextSessionWeekNumber: Int?` pour le
/// label "Cette séance était prévue semaine du ...".
struct ProgramSummary: Equatable, Identifiable {
    /// = `AdaptedProgramRecord.id`
    let id: UUID
    let templateName: String
    let sport: Sport
    /// `nil` = programme dormant (jamais démarré).
    let weekStartDate: Date?
    let durationMode: ProgramDurationMode
    let mode: ProgramMode
    /// La prochaine session à faire. `nil` = dormant ou programme tout complété.
    let nextSession: PersistedSession?
    /// Semaine en cours du programme (1-indexed). 1 si dormant.
    let currentWeekNumber: Int
    /// Sessions cochées dans la semaine courante.
    let weekCompletedSessions: Int
    /// Nombre total de sessions de la semaine courante.
    let weekTotalSessions: Int
    /// Sessions cochées sur l'ensemble du programme.
    let totalSessionsCompleted: Int
    /// Nombre total de sessions du programme.
    let totalSessions: Int
    /// Pour le tri AC22 niveau 3 (dormants).
    let lastUpdatedAt: Date
    /// **Story 3.11 AC6** — `true` quand la prochaine séance appartient à une
    /// semaine `N < currentWeekNumber` du programme ET durationMode est un mode
    /// deadline. Faux pour routineCyclic, dormant, ondemand pur, ou si la séance
    /// affichée est de la semaine courante / future.
    let nextSessionIsLate: Bool

    /// **Story 3.10 AC21** — `true` quand `weekStartDate == nil`.
    var isDormant: Bool { weekStartDate == nil }

    /// `true` quand toutes les sessions de la semaine courante sont cochées
    /// mais qu'il reste des semaines à venir. Sert au cas "Semaine X complétée"
    /// (placeholder en attente Story 3.11 — vrai blocage doux livré là).
    var isWeekCompleted: Bool {
        weekTotalSessions > 0 && weekCompletedSessions == weekTotalSessions
    }

    /// `true` quand toutes les sessions du programme sont cochées.
    /// L'auto-archive (AC14) flip `isActive` à false et le record disparaît du
    /// carrousel au prochain refresh — état transitoire.
    var isProgramCompleted: Bool {
        totalSessions > 0 && totalSessionsCompleted == totalSessions
    }
}
