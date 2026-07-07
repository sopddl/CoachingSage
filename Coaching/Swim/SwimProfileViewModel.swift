// Coaching/Swim/SwimProfileViewModel.swift
// Story 3.16 Phase 2.D2 — VM de l'écran profil natation (SportProfileView).
// Charge sa PROPRE fenêtre HK 1 an (indépendante du picker de période de
// l'onglet Progrès) : records + tendances + styles. Pas de persistance V1 —
// tout est dérivé à la volée du SwimSummaryBuilder.
import Foundation

@MainActor
@Observable
final class SwimProfileViewModel {
    enum State: Equatable {
        case idle
        case loading
        case loaded(SwimSummary)
        case empty
    }

    private(set) var state: State = .idle
    private(set) var trend: SwimTrend?

    private let healthKit: HealthKitServiceProtocol
    let windowWeeks: Int

    init(healthKit: HealthKitServiceProtocol, windowWeeks: Int = SwimSummaryBuilder.profileLookbackWeeks) {
        self.healthKit = healthKit
        self.windowWeeks = windowWeeks
    }

    func load() async {
        state = .loading
        // Limite large : 1 an de nage régulière (3-4×/sem) ≈ 150-200 séances —
        // ne pas tronquer, sinon records/total biaisés vers le récent.
        let details = await healthKit.fetchRecentSwimWorkoutDetails(limit: 300, weeksBack: windowWeeks)
        let summary = SwimSummaryBuilder.build(from: details, windowWeeks: windowWeeks)
        guard summary.sessionCount > 0 else {
            trend = nil
            state = .empty
            return
        }
        trend = SwimSummaryBuilder.computeTrend(sessions: summary.sessions)
        state = .loaded(summary)
    }
}
