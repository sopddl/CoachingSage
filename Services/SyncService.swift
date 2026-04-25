// CoachingSage/Services/SyncService.swift
// Basé sur TailorSage SyncService — adapté pour le domaine coaching sportif.
// Utilise les abstractions SageCore (AppError, SyncServiceProtocol, NetworkMonitorProtocol,
// DefaultNetworkMonitor, ConflictResolvable) — pas de copie locale pour CoachingSage.
import Foundation
import SageCore
import SwiftData

// MARK: - SyncStatus

enum SyncStatus: Equatable, Sendable {
    case idle
    case syncing
    case completed
    case error
}

// MARK: - SyncService

@Observable
final class SyncService: SyncServiceProtocol {

    // MARK: - State
    private(set) var isConnected: Bool = false
    private(set) var hasReceivedFirstUpdate: Bool = false
    private(set) var syncStatus: SyncStatus = .idle

    // MARK: - Dependencies
    private let modelContext: ModelContext
    private var monitor: NetworkMonitorProtocol
    private let monitorQueue: DispatchQueue
    private let backoffDelays: [UInt64]
    /// When true, drainQueue becomes a no-op so a UI-test-forced `.error` state isn't cleared
    /// by the automatic drain that fires when the network monitor reports connectivity.
    private let isUITestingSyncStatusForced: Bool
    /// Test-only hook : si non-nil, remplace l'appel Supabase dans `execute`.
    /// Non utilisé en prod (default nil). Permet aux tests unitaires d'injecter succès/échec.
    private let executeOverride: ((PendingOperation) async throws -> Void)?

    // MARK: - Init

    init(
        modelContext: ModelContext,
        monitor: NetworkMonitorProtocol = DefaultNetworkMonitor(),
        monitorQueue: DispatchQueue = DispatchQueue(label: "com.sagesuite.coachingsage.syncservice", qos: .utility),
        backoffDelays: [UInt64] = [1_000_000_000, 2_000_000_000, 4_000_000_000],
        executeOverride: ((PendingOperation) async throws -> Void)? = nil
    ) {
        self.modelContext = modelContext
        self.monitor = monitor
        self.monitorQueue = monitorQueue
        self.backoffDelays = backoffDelays
        self.executeOverride = executeOverride

        // UI test override: UI_TEST_SYNC_STATUS env var lets tests force the initial sync state
        // so we can exercise the banner UI without a real backend.
        if let envStatus = ProcessInfo.processInfo.environment["UI_TEST_SYNC_STATUS"] {
            switch envStatus {
            case "syncing":   self.syncStatus = .syncing
            case "error":     self.syncStatus = .error
            case "completed": self.syncStatus = .completed
            default:          break // unknown value → keep .idle
            }
            self.isUITestingSyncStatusForced = envStatus != "idle"
        } else {
            self.isUITestingSyncStatusForced = false
        }
    }

    // MARK: - Lifecycle

    func start() {
        monitor.onConnectionChange = { [weak self] connected in
            Task { @MainActor [weak self] in
                guard let self else { return }
                let wasConnected = self.isConnected
                self.isConnected = connected
                self.hasReceivedFirstUpdate = true
                if connected && !wasConnected {
                    await self.drainQueue()
                }
            }
        }
        monitor.start(queue: monitorQueue)
    }

    func stop() {
        monitor.cancel()
    }

    // MARK: - Enqueue

    @MainActor
    func enqueueOperation(type: String, payload: Data) async {
        let operation = PendingOperation(operationType: type, payload: payload)
        modelContext.insert(operation)
        do {
            try modelContext.save()
        } catch {
            print("[SyncService] ❌ Failed to enqueue operation \(type): \(error.localizedDescription)")
        }
    }

    // MARK: - Drain

    func triggerSyncForTesting() async {
        await drainQueue()
    }

    // MARK: - Private

    @MainActor
    private func drainQueue() async {
        // Respect UI-test-forced sync status — do NOT drain or clear state when a test
        // has intentionally set syncStatus via UI_TEST_SYNC_STATUS, otherwise the banner
        // would be cleared immediately on network monitor startup.
        guard !isUITestingSyncStatusForced else { return }

        let descriptor = FetchDescriptor<PendingOperation>(
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )
        let operations: [PendingOperation]
        do {
            operations = try modelContext.fetch(descriptor)
        } catch {
            print("[SyncService] ❌ Failed to fetch pending operations: \(error.localizedDescription)")
            syncStatus = .error
            return
        }
        guard !operations.isEmpty else {
            // Empty queue → clear any stale error state so the banner doesn't stick
            // (e.g., if a previous drain hit a transient SwiftData fetch error).
            if syncStatus == .error {
                syncStatus = .idle
            }
            return
        }

        syncStatus = .syncing
        var hasDefinitiveFailure = false

        for operation in operations {
            let succeeded = await performWithBackoff(operation)
            if !succeeded {
                hasDefinitiveFailure = true
            }
        }

        syncStatus = hasDefinitiveFailure ? .error : .completed
    }

    @MainActor
    private func performWithBackoff(_ operation: PendingOperation) async -> Bool {
        while operation.retryCount < 3 {
            do {
                try await execute(operation)
                modelContext.delete(operation)
                do {
                    try modelContext.save()
                } catch {
                    print("[SyncService] ❌ Failed to delete completed operation \(operation.operationType): \(error.localizedDescription)")
                }
                return true
            } catch {
                operation.retryCount += 1
                print("[SyncService] ⚠️ Operation \(operation.operationType) failed (attempt \(operation.retryCount)/3): \(error.localizedDescription)")
                do {
                    try modelContext.save()
                } catch {
                    print("[SyncService] ❌ Failed to save retry state: \(error.localizedDescription)")
                }
                if operation.retryCount < 3 {
                    let delayIndex = operation.retryCount - 1
                    if delayIndex < backoffDelays.count {
                        try? await Task.sleep(nanoseconds: backoffDelays[delayIndex])
                    }
                }
            }
        }
        print("[SyncService] ❌ Operation \(operation.operationType) failed after 3 attempts")
        return false
    }

    private func execute(_ operation: PendingOperation) async throws {
        if let override = executeOverride {
            try await override(operation)
            return
        }
        switch operation.operationType {
        case PendingOperationType.updateCoreProfile:
            let dto = try JSONDecoder().decode(CoreProfileUpsertDTO.self, from: operation.payload)
            try await SupabaseService.shared.client
                .from("core_profiles")
                .upsert(dto)
                .execute()

        // Épics futurs CoachingSage (à décommenter quand les DTOs existent) :
        // case PendingOperationType.createSession: ...         // Epic 3 — Endurance
        // case PendingOperationType.updateSession: ...         // Epic 3 — Endurance
        // case PendingOperationType.createMuscleSession: ...   // Epic 4 — Muscu
        // case PendingOperationType.upsertProgram: ...         // Epic 5 — Programmes

        default:
            // Lessons learned: ne pas ignorer silencieusement les types inconnus
            print("[SyncService] ⚠️ Unknown operation type: \(operation.operationType)")
            throw AppError.sync("Unknown pending operation type: \(operation.operationType)")
        }
    }

    // MARK: - Conflict Resolution (last-write-wins)

    static func resolveConflict<T: ConflictResolvable>(local: T, remote: T) -> T {
        local.updatedAt >= remote.updatedAt ? local : remote
    }
}

// MARK: - PendingOperationType

enum PendingOperationType {
    static let updateCoreProfile = "update_core_profile"
    // Épics futurs CoachingSage :
    // static let createSession       = "create_session"        // Epic 3
    // static let updateSession       = "update_session"        // Epic 3
    // static let createMuscleSession = "create_muscle_session" // Epic 4
    // static let upsertProgram       = "upsert_program"        // Epic 5
}
