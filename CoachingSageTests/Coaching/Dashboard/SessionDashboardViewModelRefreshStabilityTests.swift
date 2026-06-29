// CoachingSageTests/Coaching/Dashboard/SessionDashboardViewModelRefreshStabilityTests.swift
// Findings UX 2026-06-29 (#3) — filet de régression anti-flicker « sapin de Noël ».
//
// Cause racine du flicker : `@Observable` réassignait `mode`/summaries/`recordsByID`
// à CHAQUE `refresh` (donc à chaque `onAppear` / retour sur l'onglet Séances), même
// quand RIEN n'avait changé → mutation Observation → invalidation du body de
// SessionView → re-render du carrousel = clignotement.
//
// Fix : `loading` ne bascule plus après le 1ᵉʳ chargement + toutes les assignations
// de `refresh` sont gardées par égalité. On ne peut pas observer « l'absence de
// mutation » en test, mais on verrouille les invariants OBSERVABLES qui en
// découlent : un 2ᵉ refresh identique laisse `mode` Equatable-égal, préserve la
// sélection, et ne rebascule pas `loading` à true.
import XCTest
import TemplateModel

@MainActor
final class SessionDashboardViewModelRefreshStabilityTests: XCTestCase {

    private let userId = UUID()
    private let now = Date(timeIntervalSince1970: 1_700_000_000)

    /// Deux refresh consécutifs avec les MÊMES données → `mode` identique
    /// (Equatable) et `selectedId` préservé. Verrouille l'idempotence qui évite
    /// le re-render parasite du dashboard au retour sur l'onglet.
    func testRefresh_Idempotent_SameModeAcrossTwoRefreshes() async {
        let started = makeRecord(sportCode: "running", weekStartDate: now,
                                 lastUpdatedAt: Date(timeIntervalSince1970: 9_000))
        let dormant = makeRecord(sportCode: "cycling", weekStartDate: nil,
                                 lastUpdatedAt: Date(timeIntervalSince1970: 3_000))
        let vm = makeVM(programs: [started, dormant])

        await vm.refresh(userId: userId)
        let modeAfterFirst = vm.mode
        let selectedAfterFirst = vm.currentSelectedId

        await vm.refresh(userId: userId)

        XCTAssertEqual(vm.mode, modeAfterFirst, "Un 2ᵉ refresh identique ne doit pas changer le mode (sinon re-render = flicker).")
        XCTAssertEqual(vm.currentSelectedId, selectedAfterFirst, "La sélection doit être stable entre 2 refresh identiques.")
    }

    /// `loading` ne rebascule PAS à `true` sur les refresh suivants (spinner initial
    /// uniquement). C'est le maillon clé du fix : la bascule loop true→false
    /// invalidait le body à chaque retour onglet.
    func testRefresh_LoadingStaysFalseAfterInitialLoad() async {
        let started = makeRecord(sportCode: "running", weekStartDate: now,
                                 lastUpdatedAt: Date(timeIntervalSince1970: 9_000))
        let vm = makeVM(programs: [started])

        await vm.refresh(userId: userId)
        XCTAssertFalse(vm.loading, "Après le 1ᵉʳ chargement, loading doit être false.")

        await vm.refresh(userId: userId)
        XCTAssertFalse(vm.loading, "Un refresh ultérieur ne doit pas rebasculer loading à true.")
    }

    /// La sélection explicite d'une card du carrousel survit à un refresh
    /// (logique de préservation réécrite avec le fix #3).
    func testRefresh_PreservesExplicitSelection() async {
        let first = makeRecord(sportCode: "running", weekStartDate: now,
                               lastUpdatedAt: Date(timeIntervalSince1970: 9_000))
        let second = makeRecord(sportCode: "cycling", weekStartDate: now,
                                lastUpdatedAt: Date(timeIntervalSince1970: 8_000))
        let vm = makeVM(programs: [first, second])

        await vm.refresh(userId: userId)
        // Sélectionne explicitement le 2ᵉ programme (≠ sélection par défaut = 1ᵉʳ).
        let secondId = vm.startedSummaries.first(where: { $0.sport.appSportCode == "cycling" })!.id
        vm.selectProgram(id: secondId)
        XCTAssertEqual(vm.currentSelectedId, secondId)

        await vm.refresh(userId: userId)
        XCTAssertEqual(vm.currentSelectedId, secondId, "Le refresh doit préserver la sélection courante, pas la réinitialiser au 1ᵉʳ.")
    }

    // MARK: - Helpers (mirroir de SessionDashboardViewModelSplitTests)

    private func makeVM(programs: [AdaptedProgramRecord]) -> SessionDashboardViewModel {
        let programRepo = MockAdaptedProgramRepository()
        programRepo.stubbedActive = programs
        return SessionDashboardViewModel(
            programRepository: programRepo,
            coachingProfileRepository: MockCoachingProfileRepository(),
            templateLibraryProvider: { ProgramTemplateLibrary(templates: [Self.placeholderTemplate]) },
            nowProvider: { self.now }
        )
    }

    private static let placeholderTemplate: ProgramTemplate = ProgramTemplate(
        id: "placeholder", schemaVersion: 1, sport: .running, level: .beginner,
        name: "ph", durationWeeks: 4, sessionsPerWeek: 1,
        defaultObjective: "n/a", assumedProfile: "n/a", summary: "n/a",
        weeks: [], safetyNotes: "n/a", progressionLogic: "n/a"
    )

    private func makeRecord(
        sportCode: String,
        weekStartDate: Date?,
        lastUpdatedAt: Date
    ) -> AdaptedProgramRecord {
        let session = PersistedSession(
            id: UUID(),
            weekNumber: 1,
            weekTheme: "W1",
            weekGoal: "G1",
            day: 1,
            name: "S1",
            durationMinutes: 30,
            type: .endurance,
            warmup: nil,
            exercises: [],
            cooldown: nil
        )
        return AdaptedProgramRecord(
            userId: userId,
            sportCode: sportCode,
            level: "beginner",
            templateId: "test-\(sportCode)",
            adaptedAt: Date(timeIntervalSince1970: 1_699_000_000),
            weekStartDate: weekStartDate,
            mode: .ondemand,
            sessions: [session],
            lastUpdatedAt: lastUpdatedAt
        )
    }
}
