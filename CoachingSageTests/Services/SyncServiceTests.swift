// CoachingSageTests/Services/SyncServiceTests.swift
// Story 1.3 — tests unitaires SyncService (enqueue + drainQueue).
import XCTest
import SwiftData
import SageCore
@testable import CoachingSage

@MainActor
final class SyncServiceTests: XCTestCase {

    // MARK: - enqueue

    func test_enqueue_persistsPendingOperation() async throws {
        let context = try Self.makeInMemoryContext()
        let service = SyncService(modelContext: context, monitor: NoOpNetworkMonitor())

        let payload = "hello".data(using: .utf8)!
        await service.enqueueOperation(type: PendingOperationType.updateCoreProfile, payload: payload)

        let ops = try context.fetch(FetchDescriptor<PendingOperation>())
        XCTAssertEqual(ops.count, 1)
        XCTAssertEqual(ops[0].operationType, PendingOperationType.updateCoreProfile)
        XCTAssertEqual(ops[0].payload, payload)
        XCTAssertEqual(ops[0].retryCount, 0)
    }

    // MARK: - drainQueue

    func test_drainQueue_successDeletesOperation() async throws {
        let context = try Self.makeInMemoryContext()
        let service = SyncService(
            modelContext: context,
            monitor: NoOpNetworkMonitor(),
            backoffDelays: [0, 0, 0],
            executeOverride: { _ in /* success */ }
        )

        await service.enqueueOperation(type: PendingOperationType.updateCoreProfile, payload: Data())
        await service.triggerSyncForTesting()

        let ops = try context.fetch(FetchDescriptor<PendingOperation>())
        XCTAssertTrue(ops.isEmpty, "Operation doit être supprimée après succès")
        XCTAssertEqual(service.syncStatus, .completed)
    }

    func test_drainQueue_definitiveFailureSetsErrorStatus() async throws {
        let context = try Self.makeInMemoryContext()
        let service = SyncService(
            modelContext: context,
            monitor: NoOpNetworkMonitor(),
            backoffDelays: [0, 0, 0],
            executeOverride: { _ in throw AppError.sync("forced failure") }
        )

        await service.enqueueOperation(type: PendingOperationType.updateCoreProfile, payload: Data())
        await service.triggerSyncForTesting()

        XCTAssertEqual(service.syncStatus, .error)
        let ops = try context.fetch(FetchDescriptor<PendingOperation>())
        XCTAssertEqual(ops.count, 1, "Operation préservée après 3 échecs (retry futur possible)")
        XCTAssertEqual(ops[0].retryCount, 3)
    }

    func test_drainQueue_retryThenSuccess() async throws {
        let context = try Self.makeInMemoryContext()
        let counter = CallCounter()
        let service = SyncService(
            modelContext: context,
            monitor: NoOpNetworkMonitor(),
            backoffDelays: [0, 0, 0],
            executeOverride: { _ in
                let n = counter.increment()
                if n == 1 { throw AppError.sync("transient") }
            }
        )

        await service.enqueueOperation(type: PendingOperationType.updateCoreProfile, payload: Data())
        await service.triggerSyncForTesting()

        XCTAssertEqual(service.syncStatus, .completed)
        let ops = try context.fetch(FetchDescriptor<PendingOperation>())
        XCTAssertTrue(ops.isEmpty)
        XCTAssertEqual(counter.value, 2, "2 appels attendus : 1 échec + 1 succès")
    }

    // MARK: - Helpers

    private static func makeInMemoryContext() throws -> ModelContext {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: PendingOperation.self, configurations: config)
        return ModelContext(container)
    }
}

// MARK: - Test doubles

private final class NoOpNetworkMonitor: NetworkMonitorProtocol {
    var onConnectionChange: ((Bool) -> Void)?
    func start(queue: DispatchQueue) {}
    func cancel() {}
}

private final class CallCounter: @unchecked Sendable {
    private let lock = NSLock()
    private var count = 0

    func increment() -> Int {
        lock.lock(); defer { lock.unlock() }
        count += 1
        return count
    }

    var value: Int {
        lock.lock(); defer { lock.unlock() }
        return count
    }
}
