// Coaching/Dashboard/SessionDashboardViewModel.swift
// Story 3.8 — VM lecture seule du dashboard Séances.
//
// **Bascule modes** (`Mode` enum) :
//   - `.empty`        : 0 programme actif → vue mode vide (hero + 3 templates).
//   - `.singleProgram`: 1 programme actif → cards + mini-widget « Cette semaine ».
//   - `.multiProgram` : ≥ 2 programmes actifs → card dominante + cards programmes.
//
// Le mode `.restDay` (gradient vert nature) est une **variante visuelle** du
// mode actif (mono ou multi) — il dépend de la prochaine session > J+0, pas
// d'un état VM distinct. On le calcule au render, pas ici (cf sous-tâche 5).
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
    enum Mode: Equatable {
        case empty
        case singleProgram(AdaptedProgramRecord, next: NextSessionResolver.Result?)
        case multiProgram(programs: [AdaptedProgramRecord], dominant: NextSessionResolver.Result?)

        static func == (lhs: Mode, rhs: Mode) -> Bool {
            switch (lhs, rhs) {
            case (.empty, .empty):
                return true
            case let (.singleProgram(la, ln), .singleProgram(ra, rn)):
                return la.id == ra.id && ln == rn
            case let (.multiProgram(lp, ld), .multiProgram(rp, rd)):
                return lp.map(\.id) == rp.map(\.id) && ld == rd
            default:
                return false
            }
        }
    }

    private(set) var mode: Mode = .empty
    private(set) var routines: [RoutineRecord] = []
    private(set) var loading: Bool = true
    private(set) var error: String?

    /// Templates suggérés en mode vide (3 par défaut, calibrés sur autoprofil
    /// + sports onboarding). Vide tant que `mode != .empty`.
    private(set) var emptyModeSuggestions: [ProgramTemplate] = []

    /// Sports actifs déclarés à l'onboarding (passé au questionnaire universel
    /// quand l'utilisateur tape « Voir → » sur une suggestion). Cache de
    /// `CoachingProfile.activeSports` pour ne pas relancer un fetch côté Vue.
    private(set) var declaredSportCodes: [String] = []

    /// Programmes actifs enrichis (name template résolu + progression + prochaine date),
    /// triés par date de prochaine séance ascendante (la plus proche en haut, décision
    /// party #3 — A). Vide tant que `mode == .empty`. Source de vérité de la section
    /// `MES PROGRAMMES` du mode actif.
    private(set) var activeProgramSummaries: [ActiveProgramSummary] = []

    /// Stats inline du mini-widget « Cette semaine » (3 metrics). Set uniquement
    /// quand `mode == .singleProgram` (décision party #2 — B+C combinés en mode 1-prog).
    /// `nil` en mode vide / multi-prog.
    private(set) var weeklyStats: WeeklyStats?

    /// Card secondaire « Et après » sous la card dominante (style TrainingPeaks).
    /// Set uniquement quand `mode == .singleProgram` ET le programme a ≥ 2 sessions
    /// non complétées à venir. `nil` sinon.
    private(set) var nextAfterDominant: NextSessionResolver.Result?

    /// Hint italique Léon affichée en mode rest day, dérivée du compteur de séances
    /// complétées cette semaine via `CoachLineEngine`. `nil` quand la prochaine
    /// session est aujourd'hui (pas un jour de récup).
    private(set) var restDayHintKey: LocalizedStringKey?

    /// Phase B.5 — badges regen S+1 indexés par `AdaptedProgramRecord.id`. Une
    /// entrée par record dont la regen a été appliquée cette semaine (semaine
    /// courante du calendrier, pas du programme). Vide en l'absence de
    /// `weeklyRegenRepository` ou si aucune regen n'a été appliquée cette semaine.
    private(set) var regenBadgesByRecord: [UUID: RegenBadge] = [:]

    /// Library bundlée chargée à la première `refresh` qui en a besoin
    /// (mode vide pour `selectTopN`, mode actif pour résoudre les `name` de templates).
    /// Cachée pour éviter un reload à chaque `onAppear`.
    private var cachedLibrary: ProgramTemplateLibrary?

    private let weeklyStatsService = WeeklyStatsService()
    private let coachLineEngine = CoachLineEngine()
    private static let logger = Logger(subsystem: "com.sopddl.coachingsage", category: "session-dashboard-vm")

    private let programRepository: any AdaptedProgramRepository
    private let routineRepository: any RoutineRepository
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
        routineRepository: any RoutineRepository,
        coachingProfileRepository: any CoachingProfileRepository,
        weeklyRegenApplicationService: (any WeeklyRegenApplicationService)? = nil,
        weeklyRegenRepository: (any WeeklyRegenRepository)? = nil,
        resolver: NextSessionResolver = NextSessionResolver(),
        templateLibraryProvider: @escaping () async throws -> ProgramTemplateLibrary = ProgramTemplateLibrary.bundled,
        suggestionLevelProvider: @escaping (CoachingProfile?) -> String = { _ in "beginner" },
        nowProvider: @escaping () -> Date = Date.init
    ) {
        self.programRepository = programRepository
        self.routineRepository = routineRepository
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
            async let routinesTask = routineRepository.fetchAll(for: userId)
            async let profileTask: CoachingProfile? = try? coachingProfileRepository.fetchCurrentProfile()
            let programs = try await programsTask
            routines = try await routinesTask
            let profile = await profileTask
            declaredSportCodes = profile?.activeSports ?? []

            let now = nowProvider()
            switch programs.count {
            case 0:
                mode = .empty
                activeProgramSummaries = []
                weeklyStats = nil
                nextAfterDominant = nil
                restDayHintKey = nil
                await loadEmptyModeSuggestions(profile: profile)
            case 1:
                let only = programs[0]
                let upcoming = resolver.upcomingSessions(for: only, now: now)
                let next = upcoming.first
                mode = .singleProgram(only, next: next)
                emptyModeSuggestions = []
                await ensureLibraryCached()
                activeProgramSummaries = makeSummaries(programs: programs, now: now)
                let stats = weeklyStatsService.computeCurrentWeek(programs: programs, now: now)
                weeklyStats = stats
                nextAfterDominant = upcoming.dropFirst().first
                restDayHintKey = restDayHint(dominant: next, weeklyStats: stats, now: now)
            default:
                let dominant = resolver.nextSession(across: programs, now: now)
                mode = .multiProgram(programs: programs, dominant: dominant)
                emptyModeSuggestions = []
                await ensureLibraryCached()
                activeProgramSummaries = makeSummaries(programs: programs, now: now)
                weeklyStats = nil
                nextAfterDominant = nil
                let stats = weeklyStatsService.computeCurrentWeek(programs: programs, now: now)
                restDayHintKey = restDayHint(dominant: dominant, weeklyStats: stats, now: now)
            }
        } catch {
            self.error = error.localizedDescription
            mode = .empty
            routines = []
            emptyModeSuggestions = []
            activeProgramSummaries = []
            weeklyStats = nil
            nextAfterDominant = nil
            restDayHintKey = nil
        }
        loading = false
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

    /// Lundi 00:00 de la semaine calendrier contenant `date`. Utilise la
    /// `Calendar.current` (locale fr-FR → lundi = 1er jour). Fallback `date`
    /// brut si `dateInterval` retourne nil (extrêmement improbable).
    private static func startOfCalendarWeek(for date: Date) -> Date {
        Calendar.current.dateInterval(of: .weekOfYear, for: date)?.start ?? date
    }

    /// Renvoie la hint Léon pour la card rest day quand la prochaine séance
    /// dominante n'est PAS aujourd'hui. `nil` quand la séance est aujourd'hui
    /// (mode actif normal) ou absente (programmes complétés).
    private func restDayHint(
        dominant: NextSessionResolver.Result?,
        weeklyStats: WeeklyStats,
        now: Date
    ) -> LocalizedStringKey? {
        guard let dominant else { return nil }
        let calendar = Calendar.current
        let isToday = calendar.isDate(dominant.effectiveDate, inSameDayAs: now)
        guard !isToday else { return nil }
        return coachLineEngine.restDayHint(weeklyCompletedCount: weeklyStats.completedCount)
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

    /// Construit les `ActiveProgramSummary` triés par date de prochaine séance
    /// ascendante. Programmes sans next session (tout complété) repoussés en
    /// bas — ils restent visibles mais n'occupent pas le créneau prioritaire.
    private func makeSummaries(programs: [AdaptedProgramRecord], now: Date) -> [ActiveProgramSummary] {
        let summaries = programs.map { record -> ActiveProgramSummary in
            let next = resolver.nextSession(for: record, now: now)
            let total = max(record.sessions.count, 1)
            let completed = record.completionState.completedCount
            let progress = min(max(Double(completed) / Double(total), 0), 1)
            let resolvedName = cachedLibrary?.templates
                .first { $0.id == record.templateId }?.name
            return ActiveProgramSummary(
                record: record,
                nextDate: next?.effectiveDate,
                progress: progress,
                templateName: resolvedName
            )
        }
        return summaries.sorted { lhs, rhs in
            switch (lhs.nextDate, rhs.nextDate) {
            case let (l?, r?): return l < r
            case (_?, nil):    return true
            case (nil, _?):    return false
            case (nil, nil):   return lhs.record.sportCode < rhs.record.sportCode
            }
        }
    }
}

/// Résumé enrichi d'un programme actif pour la section MES PROGRAMMES du mode actif.
/// Découplage VM/Vue : la View consomme un type plat sans replonger dans
/// `AdaptedProgramRecord.sessions` ni dans la library à chaque render.
struct ActiveProgramSummary: Equatable {
    let record: AdaptedProgramRecord
    let nextDate: Date?
    /// 0...1
    let progress: Double
    /// `nil` quand la library n'a pas pu résoudre le templateId (fallback côté Vue).
    let templateName: String?

    static func == (lhs: ActiveProgramSummary, rhs: ActiveProgramSummary) -> Bool {
        lhs.record.id == rhs.record.id
            && lhs.nextDate == rhs.nextDate
            && lhs.progress == rhs.progress
            && lhs.templateName == rhs.templateName
    }
}
