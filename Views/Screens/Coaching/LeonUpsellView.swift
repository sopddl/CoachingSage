// Views/Screens/Coaching/LeonUpsellView.swift
// Léon+ — écran upsell (sheet). Portage du pattern GardenSage
// (`Views/Screens/Flore/FloreUpsellView.swift`, Epic 17 Story 17.7), réduit à un
// seul produit (pas de packs consommables en V1).
import SwiftUI
import os
import StoreKit

struct LeonUpsellView: View {
    private static let logger = Logger(subsystem: "com.sopddl.coachingsage", category: "LeonUpsellView")
    @Environment(\.dismiss) private var dismiss
    @Environment(\.languageManager) private var languageManager

    let storeKitService: StoreKitService

    @State private var isPurchasing = false
    @State private var purchaseError: String?
    @State private var isRestoring = false
    @State private var isLoadingProducts = false
    @State private var showTerms = false
    @State private var showPrivacy = false

    private var appLocale: Locale { languageManager.currentLocale }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    header

                    if isLoadingProducts {
                        ProgressView()
                            .padding(.vertical, 32)
                    } else if storeKitService.products.isEmpty {
                        loadErrorState
                    } else {
                        VStack(spacing: 12) {
                            ForEach(storeKitService.products, id: \.id) { product in
                                upsellCard(for: product)
                            }
                        }
                    }

                    Button {
                        Task { await restore() }
                    } label: {
                        Text("coaching.leonPlus.upsell.restore")
                            .font(.coachingCaption)
                            .foregroundStyle(Color.coachingPrimary)
                    }
                    .disabled(isRestoring)
                    .accessibilityIdentifier("leonPlus.upsell.restore")

                    if let error = purchaseError {
                        Text(error)
                            .font(.coachingCaption)
                            .foregroundStyle(Color.coachingError)
                            .multilineTextAlignment(.center)
                    }

                    legalLinks

                    Spacer(minLength: 16)
                }
                .padding(.horizontal, 20)
            }
            .navigationTitle(String.localized("coaching.leonPlus.upsell.navTitle", locale: appLocale))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(Color.coachingPrimary)
                    }
                    .accessibilityLabel(String.localized("coaching.leonPlus.upsell.close", locale: appLocale))
                    .accessibilityIdentifier("leonPlus.upsell.close")
                }
            }
        }
        .accessibilityIdentifier("leonPlus.upsellView")
        .task {
            if storeKitService.products.isEmpty {
                isLoadingProducts = true
                await storeKitService.loadProducts()
                isLoadingProducts = false
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 8) {
            Image(systemName: "sparkles")
                .font(.system(size: 56))
                .foregroundStyle(Color.coachingPrimary)

            Text("coaching.leonPlus.upsell.header.title")
                .font(.coachingH2)
                .multilineTextAlignment(.center)

            Text("coaching.leonPlus.upsell.header.subtitle")
                .font(.coachingBody)
                .foregroundStyle(Color.coachingTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
    }

    private var loadErrorState: some View {
        VStack(spacing: 12) {
            Text("coaching.leonPlus.upsell.loadError")
                .font(.coachingBody)
                .foregroundStyle(Color.coachingTextSecondary)
                .multilineTextAlignment(.center)

            Button {
                Task {
                    isLoadingProducts = true
                    await storeKitService.loadProducts()
                    isLoadingProducts = false
                }
            } label: {
                Label(
                    String.localized("coaching.leonPlus.upsell.retry", locale: appLocale),
                    systemImage: "arrow.clockwise"
                )
                .font(.coachingBody.weight(.semibold))
                .foregroundStyle(Color.coachingPrimary)
            }
            .accessibilityIdentifier("leonPlus.upsell.retry")
        }
        .padding(.vertical, 16)
    }

    // MARK: - Legal links (Guideline App Store 3.1.2(c))

    private var privacyURL: URL {
        languageManager.currentLanguage == .french
            ? AppConstants.privacyPolicyFRURL
            : AppConstants.privacyPolicyENURL
    }

    private var legalLinks: some View {
        HStack(spacing: 12) {
            // `Link(destination:)` dans une sheet ouvre Safari sur page blanche
            // (régression iOS 18) — SFSafariViewController in-app à la place.
            Button {
                showTerms = true
            } label: {
                Text("coaching.leonPlus.upsell.terms")
                    .font(.coachingCaption)
                    .foregroundStyle(Color.coachingPrimary)
            }
            .accessibilityIdentifier("leonPlus.upsell.terms")

            Text("·")
                .font(.coachingCaption)
                .foregroundStyle(Color.coachingTextSecondary)

            Button {
                showPrivacy = true
            } label: {
                Text("coaching.leonPlus.upsell.privacy")
                    .font(.coachingCaption)
                    .foregroundStyle(Color.coachingPrimary)
            }
            .accessibilityIdentifier("leonPlus.upsell.privacy")
        }
        .padding(.top, 8)
        .sheet(isPresented: $showTerms) {
            SafariView(url: AppConstants.termsOfUseURL)
        }
        .sheet(isPresented: $showPrivacy) {
            SafariView(url: privacyURL)
        }
    }

    // MARK: - Card

    @ViewBuilder
    private func upsellCard(for product: Product) -> some View {
        let productId = LeonProductID(rawValue: product.id)
        let isCurrentPlan = productId?.tier == storeKitService.currentTier && storeKitService.currentTier != "free"

        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Text(displayName(for: product))
                            .font(.coachingH2)

                        if isCurrentPlan {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color.coachingPrimary)
                        }
                    }

                    Text(displayDescription(for: product))
                        .font(.coachingCaption)
                        .foregroundStyle(Color.coachingTextSecondary)
                }

                Spacer()

                Text(product.displayPrice)
                    .font(.coachingH2.weight(.bold))
                    .foregroundStyle(Color.coachingPrimary)
            }

            if isCurrentPlan {
                Text("coaching.leonPlus.upsell.active")
                    .font(.coachingCaption.weight(.semibold))
                    .foregroundStyle(Color.coachingPrimary)
            } else {
                Button {
                    Task { await purchase(product) }
                } label: {
                    Text("coaching.leonPlus.upsell.subscribe")
                        .font(.coachingBody.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.coachingPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: CoachingRadius.md))
                }
                .disabled(isPurchasing)
                .accessibilityIdentifier("leonPlus.upsell.buy.\(product.id)")
            }
        }
        .padding(16)
        .background(Color.coachingCard)
        .clipShape(RoundedRectangle(cornerRadius: CoachingRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: CoachingRadius.lg)
                .stroke(isCurrentPlan ? Color.coachingPrimary : Color.clear, lineWidth: 2)
        )
        .accessibilityElement(children: .combine)
    }

    // MARK: - Actions

    private func purchase(_ product: Product) async {
        isPurchasing = true
        purchaseError = nil

        do {
            let result = try await storeKitService.purchase(product)
            switch result {
            case .success:
                dismiss()
            case .userCancelled:
                break
            case .pending:
                purchaseError = String.localized("coaching.leonPlus.upsell.purchasePending", locale: appLocale)
            }
        } catch {
            Self.logger.error("purchase failed: \(error)")
            purchaseError = String.localized("coaching.leonPlus.upsell.purchaseFailed", locale: appLocale)
        }

        isPurchasing = false
    }

    private func restore() async {
        isRestoring = true
        purchaseError = nil

        do {
            try await storeKitService.restorePurchases()
            if storeKitService.currentTier != "free" {
                dismiss()
            } else {
                purchaseError = String.localized("coaching.leonPlus.upsell.noSubscription", locale: appLocale)
            }
        } catch {
            Self.logger.error("restore failed: \(error)")
            purchaseError = String.localized("coaching.leonPlus.upsell.restoreFailed", locale: appLocale)
        }

        isRestoring = false
    }

    // MARK: - Localized product fields
    // StoreKit's `product.displayName`/`.description` lit la langue SYSTÈME, pas
    // la langue interne de l'app (`LanguageManager`) — override avec des clés
    // internes pour rester cohérent si l'utilisateur a basculé la langue de l'app.

    private func displayName(for product: Product) -> String {
        guard LeonProductID(rawValue: product.id) != nil else { return product.displayName }
        return String.localized("coaching.leonPlus.product.name", locale: appLocale)
    }

    private func displayDescription(for product: Product) -> String {
        guard LeonProductID(rawValue: product.id) != nil else { return product.description }
        return String.localized("coaching.leonPlus.product.description", locale: appLocale)
    }
}
