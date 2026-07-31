// CoachingSageTests/Mocks/MockAccountDataPurger.swift
// Story 1.4 follow-up (RGPD) — mock pour AccountServiceTests.
import Foundation

final class MockAccountDataPurger: AccountDataPurging {
    private(set) var purgedUserIds: [UUID] = []

    @MainActor
    func purgeLocalData(for userId: UUID) {
        purgedUserIds.append(userId)
    }
}
