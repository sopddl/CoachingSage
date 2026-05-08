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
// **VM 100% lecture pour cet incrément** : pas d'écriture. Le wire-up persist
// (sortie de `ProgramAdapter.adapt`) est livré dans le commit suivant.
import Foundation

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

    private let programRepository: any AdaptedProgramRepository
    private let routineRepository: any RoutineRepository
    private let resolver: NextSessionResolver
    private let nowProvider: () -> Date

    init(
        programRepository: any AdaptedProgramRepository,
        routineRepository: any RoutineRepository,
        resolver: NextSessionResolver = NextSessionResolver(),
        nowProvider: @escaping () -> Date = Date.init
    ) {
        self.programRepository = programRepository
        self.routineRepository = routineRepository
        self.resolver = resolver
        self.nowProvider = nowProvider
    }

    /// Charge programmes + routines pour le user, calcule la bascule mode et
    /// la prochaine séance dominante. Idempotent : peut être rappelée à chaque
    /// `onAppear` ou changement utilisateur.
    func refresh(userId: UUID) async {
        loading = true
        error = nil
        do {
            async let programsTask = programRepository.fetchActive(for: userId)
            async let routinesTask = routineRepository.fetchAll(for: userId)
            let programs = try await programsTask
            routines = try await routinesTask

            let now = nowProvider()
            switch programs.count {
            case 0:
                mode = .empty
            case 1:
                let only = programs[0]
                mode = .singleProgram(only, next: resolver.nextSession(for: only, now: now))
            default:
                mode = .multiProgram(
                    programs: programs,
                    dominant: resolver.nextSession(across: programs, now: now)
                )
            }
        } catch {
            self.error = error.localizedDescription
            mode = .empty
            routines = []
        }
        loading = false
    }
}
