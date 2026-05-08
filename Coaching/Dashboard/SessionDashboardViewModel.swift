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
import Foundation
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

    /// Library bundlée chargée à la première `refresh` qui en a besoin
    /// (mode vide pour `selectTopN`, mode actif pour résoudre les `name` de templates).
    /// Cachée pour éviter un reload à chaque `onAppear`.
    private var cachedLibrary: ProgramTemplateLibrary?

    private let programRepository: any AdaptedProgramRepository
    private let routineRepository: any RoutineRepository
    private let coachingProfileRepository: any CoachingProfileRepository
    private let resolver: NextSessionResolver
    private let templateLibraryProvider: () async throws -> ProgramTemplateLibrary
    private let suggestionLevelProvider: (CoachingProfile?) -> String
    private let nowProvider: () -> Date

    init(
        programRepository: any AdaptedProgramRepository,
        routineRepository: any RoutineRepository,
        coachingProfileRepository: any CoachingProfileRepository,
        resolver: NextSessionResolver = NextSessionResolver(),
        templateLibraryProvider: @escaping () async throws -> ProgramTemplateLibrary = ProgramTemplateLibrary.bundled,
        suggestionLevelProvider: @escaping (CoachingProfile?) -> String = { _ in "beginner" },
        nowProvider: @escaping () -> Date = Date.init
    ) {
        self.programRepository = programRepository
        self.routineRepository = routineRepository
        self.coachingProfileRepository = coachingProfileRepository
        self.resolver = resolver
        self.templateLibraryProvider = templateLibraryProvider
        self.suggestionLevelProvider = suggestionLevelProvider
        self.nowProvider = nowProvider
    }

    /// Charge programmes + routines + profil coaching pour le user, calcule la
    /// bascule mode + la prochaine séance dominante + les suggestions mode vide.
    /// Idempotent : peut être rappelée à chaque `onAppear` ou changement utilisateur.
    func refresh(userId: UUID) async {
        loading = true
        error = nil
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
                await loadEmptyModeSuggestions(profile: profile)
            case 1:
                let only = programs[0]
                mode = .singleProgram(only, next: resolver.nextSession(for: only, now: now))
                emptyModeSuggestions = []
                await ensureLibraryCached()
                activeProgramSummaries = makeSummaries(programs: programs, now: now)
            default:
                mode = .multiProgram(
                    programs: programs,
                    dominant: resolver.nextSession(across: programs, now: now)
                )
                emptyModeSuggestions = []
                await ensureLibraryCached()
                activeProgramSummaries = makeSummaries(programs: programs, now: now)
            }
        } catch {
            self.error = error.localizedDescription
            mode = .empty
            routines = []
            emptyModeSuggestions = []
            activeProgramSummaries = []
        }
        loading = false
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
