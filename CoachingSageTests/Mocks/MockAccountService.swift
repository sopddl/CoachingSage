// CoachingSageTests/Mocks/MockAccountService.swift
// Mock pour AccountViewModel tests.
import Foundation
@testable import CoachingSage
import SageCore

final class MockAccountService: AccountServiceProtocol {
    var shouldThrow: Bool = false
    var deleteAccountCalled: Bool = false
    var thrownError: Error = AppError.sync("mock delete-account error")

    func deleteAccount() async throws {
        deleteAccountCalled = true
        if shouldThrow { throw thrownError }
    }
}
