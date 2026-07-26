// Services/StoreKitService.swift
// Léon+ — StoreKit 2 integration (portage du pattern GardenSage Epic 17 Story 17.4,
// Flore+ en prod). Un seul produit V1 : abonnement mensuel "leon.plus.monthly" →
// quota illimité (checkQuota() côté edge function lit déjà subscription_tier,
// rien à changer côté backend Léon pour consommer ce tier).

import Foundation
import os
import StoreKit
import Supabase

// MARK: - Product IDs

enum LeonProductID: String, CaseIterable {
    case plusMonthly = "leon.plus.monthly"

    var isSubscription: Bool { true }

    var tier: String {
        switch self {
        case .plusMonthly: return "plus"
        }
    }
}

// MARK: - Purchase Result

enum LeonPurchaseResult {
    case success(productId: String)
    case userCancelled
    case pending
}

// MARK: - Protocol

@MainActor
protocol StoreKitServiceProtocol: AnyObject {
    var products: [Product] { get }
    var currentTier: String { get }
    var subscriptionExpiresAt: Date? { get }

    func loadProducts() async
    func purchase(_ product: Product) async throws -> LeonPurchaseResult
    func restorePurchases() async throws
    func refreshSubscriptionStatus() async
    func applyQuotaTier(_ tier: String)
    func resetForSignOut()
}

// MARK: - Implementation

@MainActor
@Observable
final class StoreKitService: StoreKitServiceProtocol {
    private static let logger = Logger(subsystem: "com.sopddl.coachingsage", category: "storekit")
    static let shared = StoreKitService()

    private(set) var products: [Product] = []
    private(set) var currentTier: String = "free"
    private(set) var subscriptionExpiresAt: Date?

    private var transactionListener: Task<Void, Error>?

    private init() {
        // Load cached tier from UserDefaults for fast launch.
        currentTier = UserDefaults.standard.string(forKey: "leon_subscription_tier") ?? "free"
        transactionListener = listenForTransactions()
    }

    // transactionListener Task is cancelled when StoreKitService is deallocated (singleton, never deallocated).

    // MARK: - Load Products

    func loadProducts() async {
        let ids = LeonProductID.allCases.map(\.rawValue)
        do {
            let loaded = try await Product.products(for: Set(ids))
            products = loaded
            Self.logger.info("Loaded \(self.products.count)/\(ids.count) products: \(self.products.map(\.id))")
            if products.isEmpty {
                Self.logger.warning("0 products returned — check App Store Connect configuration for IDs: \(ids)")
            }
        } catch {
            Self.logger.error("Failed to load products: \(error.localizedDescription)")
        }
    }

    // MARK: - Purchase

    func purchase(_ product: Product) async throws -> LeonPurchaseResult {
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)

            let jwsString = verification.jwsRepresentation
            await validateOnServer(jwsString: jwsString, transaction: transaction)

            await transaction.finish()

            return .success(productId: product.id)

        case .userCancelled:
            return .userCancelled

        case .pending:
            return .pending

        @unknown default:
            return .userCancelled
        }
    }

    // MARK: - Restore

    func restorePurchases() async throws {
        try await AppStore.sync()
        await refreshSubscriptionStatus()
    }

    // MARK: - Refresh Status

    func refreshSubscriptionStatus() async {
        var foundTier = "free"
        var foundExpiry: Date?

        for await result in Transaction.currentEntitlements {
            guard let transaction = try? checkVerified(result) else { continue }

            if let productId = LeonProductID(rawValue: transaction.productID), productId.isSubscription {
                foundTier = productId.tier
                foundExpiry = transaction.expirationDate
            }
        }

        // Ne pas downgrader à "free" si `Transaction.currentEntitlements` est vide
        // ALORS que la validation serveur précédente avait stocké un tier non-free
        // dans UserDefaults. La source de vérité est la validation serveur
        // (`validate-receipt` edge function + `applyQuotaTier`), pas seulement
        // StoreKit local. Sans ce garde-fou : "Gratuit" affiché pour un user payant
        // en simulateur (sans entitlements StoreKit) ou si `currentEntitlements`
        // est temporairement vide (bug rencontré côté GardenSage 2026-04-08).
        if foundTier == "free" {
            let cachedTier = UserDefaults.standard.string(forKey: "leon_subscription_tier") ?? "free"
            if cachedTier != "free" {
                currentTier = cachedTier
                return
            }
        }

        currentTier = foundTier
        subscriptionExpiresAt = foundExpiry
        persistTierLocally(foundTier)
    }

    /// Mise à jour du tier depuis la réponse API (quota Léon). Doit être appelé
    /// après CHAQUE réponse Léon réussie qui renvoie un tier, pas seulement après
    /// achat — sinon une expiration/remboursement côté serveur ne se reflète
    /// qu'au prochain boot de l'app (prochain `refreshSubscriptionStatus`).
    func applyQuotaTier(_ tier: String) {
        currentTier = tier
        persistTierLocally(tier)
    }

    // MARK: - Transaction Listener

    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }
                if let transaction = try? await self.checkVerified(result) {
                    let jwsString = result.jwsRepresentation
                    await self.validateOnServer(jwsString: jwsString, transaction: transaction)
                    await transaction.finish()
                    await self.refreshSubscriptionStatus()
                }
            }
        }
    }

    // MARK: - Server Validation

    private func validateOnServer(jwsString: String, transaction: Transaction) async {
        do {
            // Refresh session to avoid 403 JWT expired.
            _ = try await SupabaseService.shared.client.auth.session
            let body: [String: String] = [
                "signed_transaction": jwsString,
                "product_id": transaction.productID,
            ]
            try await SupabaseService.shared.client.functions.invoke(
                "validate-receipt",
                options: FunctionInvokeOptions(body: body)
            )

            if let productId = LeonProductID(rawValue: transaction.productID), productId.isSubscription {
                currentTier = productId.tier
                subscriptionExpiresAt = transaction.expirationDate
                persistTierLocally(productId.tier)
            }
        } catch {
            Self.logger.error("Server validation failed: \(error)")
        }
    }

    // MARK: - Helpers

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let value):
            return value
        }
    }

    private func persistTierLocally(_ tier: String) {
        if tier == "free" {
            UserDefaults.standard.removeObject(forKey: "leon_subscription_tier")
        } else {
            UserDefaults.standard.set(tier, forKey: "leon_subscription_tier")
        }
    }

    // MARK: - Sign Out

    /// Réinitialise l'état abonnement à "free". Doit être appelé au sign-out
    /// pour éviter une fuite de tier entre comptes sur le même device.
    func resetForSignOut() {
        currentTier = "free"
        subscriptionExpiresAt = nil
        UserDefaults.standard.removeObject(forKey: "leon_subscription_tier")
    }
}
