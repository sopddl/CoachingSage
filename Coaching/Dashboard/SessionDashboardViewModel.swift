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
                await loadEmptyModeSuggestions(profile: profile)
            case 1:
                let only = programs[0]
                mode = .singleProgram(only, next: resolver.nextSession(for: only, now: now))
                emptyModeSuggestions = []
            default:
                mode = .multiProgram(
                    programs: programs,
                    dominant: resolver.nextSession(across: programs, now: now)
                )
                emptyModeSuggestions = []
            }
        } catch {
            self.error = error.localizedDescription
            mode = .empty
            routines = []
            emptyModeSuggestions = []
        }
        loading = false
    }

    /// Charge la library bundlée et calcule les 3 suggestions via
    /// `ProgramTemplateSelector.selectTopN`. Échec library → liste vide
    /// (la vue mode vide affichera son fallback générique).
    private func loadEmptyModeSuggestions(profile: CoachingProfile?) async {
        do {
            let library = try await templateLibraryProvider()
            let selector = ProgramTemplateSelector(library: library)
            let topNProfile = TopNSelectionProfile(
                level: suggestionLevelProvider(profile),
                sportCodes: profile?.activeSports ?? []
            )
            emptyModeSuggestions = selector.selectTopN(profile: topNProfile, n: 3)
        } catch {
            emptyModeSuggestions = []
        }
    }
}
