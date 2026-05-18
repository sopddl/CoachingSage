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
    /// **Story 3.10** — modes du dashboard Séances.
    ///   - `.empty`  : aucun programme actif → placeholder + suggestions.
    ///   - `.active(programs, selectedId)` : carrousel + NextSessionCard.
    ///
    /// `selectedId` est le `record.id` de la card sélectionnée dans le carrousel.
    /// `nil` = première card par défaut (cf `currentSelectedSummary`).
    enum Mode: Equatable {
        case empty
        case active(programs: [ProgramSummary], selectedId: UUID?)

        static func == (lhs: Mode, rhs: Mode) -> Bool {
            switch (lhs, rhs) {
            case (.empty, .empty):
                return true
            case let (.active(lp, lsel), .active(rp, rsel)):
                return lp == rp && lsel == rsel
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
    private(set) var emptyModeSuggestions: [ProgramTemplate] = []

    /// Sports actifs déclarés à l'onboarding (passé au questionnaire universel
    /// quand l'utilisateur tape « Voir → » sur une suggestion). Cache de
    /// `CoachingProfile.activeSports` pour ne pas relancer un fetch côté Vue.
    private(set) var declaredSportCodes: [String] = []

    /// **Story 3.10** — programmes actifs triés selon AC22 : démarrés AVANT
    /// dormants, puis nextDate asc entre démarrés, puis lastUpdatedAt desc entre
    /// dormants. Mirror de `mode.active.programs` pour les call-sites internes
    /// (regen badges, modifiedSessionCoordinates).
    var activeProgramSummaries: [ProgramSummary] {
        switch mode {
        case .empty: return []
        case let .active(programs, _): return programs
        }
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

    init(
        programRepository: any AdaptedProgramRepository,
        coachingProfileRepository: any CoachingProfileRepository,
        weeklyRegenApplicationService: (any WeeklyRegenApplicationService)? = nil,
        weeklyRegenRepository: (any WeeklyRegenRepository)? = nil,
        resolver: NextSessionResolver = NextSessionResolver(),
        templateLibraryProvider: @escaping () async throws -> ProgramTemplateLibrary = ProgramTemplateLibrary.bundled,
        suggestionLevelProvider: @escaping (CoachingProfile?) -> String = { _ in "beginner" },
        nowProvider: @escaping () -> Date = Date.init
    ) {
        self.programRepository = programRepository
        self.coachingProfileRepository = coachingProfileRepository
        self.weeklyRegenApplicationService = weeklyRegenApplicationService
        self.weeklyRegenRepository = weeklyRegenRepository
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
        await runAutoRegenIfNeeded(userId: userId)
        await loadRegenBadges(userId: userId)
        do {
            async let programsTask = programRepository.fetchActive(for: userId)
            async let profileTask: CoachingProfile? = try? coachingProfileRepository.fetchCurrentProfile()
            let programs = try await programsTask
            let profile = await profileTask
            declaredSportCodes = profile?.activeSports ?? []

            // Map records pour les helpers internes (regen, push detail view).
            recordsByID = Dictionary(uniqueKeysWithValues: programs.map { ($0.id, $0) })

            let now = nowProvider()
            if programs.isEmpty {
                mode = .empty
                await loadEmptyModeSuggestions(profile: profile)
            } else {
                emptyModeSuggestions = []
                await ensureLibraryCached()
                let summaries = makeProgramSummaries(programs: programs, now: now)
                // Sélection par défaut = première card du carrousel (= démarré
                // avec next session la plus proche, sinon dormant le plus récent).
                let defaultSelection = summaries.first?.id
                let previousSelection = currentSelectedId
                let selectedId = previousSelection.flatMap { id in
                    summaries.contains(where: { $0.id == id }) ? id : nil
                } ?? defaultSelection
                mode = .active(programs: summaries, selectedId: selectedId)
            }
        } catch {
            self.error = error.localizedDescription
            mode = .empty
            emptyModeSuggestions = []
            recordsByID = [:]
        }
        loading = false
    }

    /// **Story 3.10** — selectedId courant (extrait de `mode.active`).
    /// `nil` en mode empty.
    var currentSelectedId: UUID? {
        if case let .active(_, selectedId) = mode { return selectedId }
        return nil
    }

    /// **Story 3.10** — ProgramSummary correspondant au selectedId courant.
    /// Source de vérité pour `NextSessionCard`. `nil` en mode empty ou si la
    /// sélection a été flushée par un refresh (cas dégénéré).
    var currentSelectedSummary: ProgramSummary? {
        guard case let .active(programs, selectedId) = mode else { return nil }
        return programs.first { $0.id == selectedId }
    }

    /// **Story 3.10** — bascule la sélection sur une card du carrousel. No-op
    /// si l'id n'existe pas dans `mode.active.programs`.
    func selectProgram(id: UUID) {
        guard case let .active(programs, _) = mode else { return }
        guard programs.contains(where: { $0.id == id }) else { return }
        mode = .active(programs: programs, selectedId: id)
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

    /// **Story 3.10** — Construit les `ProgramSummary` plats pour le carrousel.
    /// Tri 3 niveaux (AC22) :
    ///   1. démarrés (`weekStartDate != nil`) AVANT dormants
    ///   2. entre démarrés : nextDate ascending
    ///   3. entre dormants : `lastUpdatedAt` desc (le dernier créé en tête)
    private func makeProgramSummaries(programs: [AdaptedProgramRecord], now: Date) -> [ProgramSummary] {
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
        return summaries.sorted(by: Self.compareSummariesForCarousel)
    }

    /// **Story 3.10 AC22 — refondue Story 3.12** : tri 2 niveaux.
    ///   1. démarrés (`weekStartDate != nil`) AVANT dormants
    ///   2. `lastUpdatedAt` desc (programme manipulé récemment en tête)
    ///
    /// Avant Story 3.12 le tri secondaire entre démarrés était `nextDate asc`,
    /// mais depuis la refonte vue semaine l'`effectiveDate` du resolver est
    /// toujours `now` (les séances n'ont plus de date individuelle).
    /// `lastUpdatedAt desc` met en tête le programme touché en dernier, qui est
    /// le candidat le plus probable pour le focus utilisateur.
    static func compareSummariesForCarousel(_ lhs: ProgramSummary, _ rhs: ProgramSummary) -> Bool {
        let lhsStarted = lhs.weekStartDate != nil
        let rhsStarted = rhs.weekStartDate != nil
        if lhsStarted != rhsStarted { return lhsStarted } // démarrés AVANT dormants
        return lhs.lastUpdatedAt > rhs.lastUpdatedAt
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
