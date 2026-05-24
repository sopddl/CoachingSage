// Views/Screens/Dashboard/EmptyDashboardView.swift
// Story 3.8 — vue mode vide « Accueil » simplifiée Story 3.15.
//
// **Story 3.15 v7 (Sophie 2026-05-21)** : refonte complète. La version
// précédente avait LeonHintView (qui s'étirait), HeroCard doré au texte
// obsolète ("Léon a préparé 3 programmes" alors que rien n'est créé) +
// CustomProgramLink. Sophie : « pas de bouton, c'est horrible ».
//
// **Story 3.22-F-bis (Sophie 2026-05-24)** : 3 variantes selon `EmptyDashboardState` :
//   - .noProfile          → "termine ton profil" (pas de CTA, edge case)
//   - .noPrograms         → CTA "Crée mon premier programme" (cas normal)
//   - .crossDeviceMissing → CTA "Créer ici" + message dédié cross-device
// Sophie a remonté au test simu 2026-05-24 : message "0 programmes" ambigu
// si bootstrap déjà fait sur un autre device.
import SwiftUI

struct EmptyDashboardView: View {
    let state: EmptyDashboardState
    let onTapCustom: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 20)

            // Icône hero
            ZStack {
                Circle()
                    .fill(Color.coachingPrimary.opacity(0.12))
                Image(systemName: iconSystemName)
                    .font(.system(size: 38, weight: .semibold))
                    .foregroundStyle(Color.coachingPrimary)
            }
            .frame(width: 96, height: 96)

            VStack(spacing: 8) {
                Text(titleKey)
                    .font(.system(size: 22, weight: .semibold, design: .serif))
                    .foregroundStyle(Color.coachingTextPrimary)
                    .multilineTextAlignment(.center)
                Text(hintKey)
                    .font(.coachingBody)
                    .foregroundStyle(Color.coachingTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            if state != .noProfile {
                Button(action: onTapCustom) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.headline)
                        Text(ctaKey)
                            .font(.headline)
                    }
                    .foregroundStyle(Color.coachingOnPrimary)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 14)
                    .background(Color.coachingPrimary)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier(accessibilityCTAId)
            } else {
                // Cas noProfile : pas de CTA action (edge case onboarding
                // non finalisé). Hint discret vers le bon endroit.
                Text("dashboard.empty.noProfile.actionHint")
                    .font(.coachingCaption)
                    .foregroundStyle(Color.coachingTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer(minLength: 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - State-driven content

    private var iconSystemName: String {
        switch state {
        case .noProfile:          return "person.crop.circle.badge.exclamationmark"
        case .noPrograms:         return "figure.run"
        case .crossDeviceMissing: return "iphone.gen3"
        }
    }

    private var titleKey: LocalizedStringKey {
        switch state {
        case .noProfile:          return "dashboard.empty.noProfile.title"
        case .noPrograms:         return "dashboard.empty.title"
        case .crossDeviceMissing: return "dashboard.empty.crossDevice.title"
        }
    }

    private var hintKey: LocalizedStringKey {
        switch state {
        case .noProfile:          return "dashboard.empty.noProfile.hint"
        case .noPrograms:         return "dashboard.empty.noPrograms.hint"
        case .crossDeviceMissing: return "dashboard.empty.crossDevice.hint"
        }
    }

    private var ctaKey: LocalizedStringKey {
        switch state {
        case .noProfile:          return "" // pas de CTA
        case .noPrograms:         return "dashboard.empty.cta.create"
        case .crossDeviceMissing: return "dashboard.empty.crossDevice.cta"
        }
    }

    private var accessibilityCTAId: String {
        switch state {
        case .noProfile:          return "dashboard.empty.noProfile.hint"
        case .noPrograms:         return "dashboard.empty.cta.create"
        case .crossDeviceMissing: return "dashboard.empty.crossDevice.cta"
        }
    }
}

#Preview("noPrograms (cas normal)") {
    EmptyDashboardView(state: .noPrograms, onTapCustom: {})
        .background(Color.coachingBackground)
}

#Preview("noProfile (edge)") {
    EmptyDashboardView(state: .noProfile, onTapCustom: {})
        .background(Color.coachingBackground)
}

#Preview("crossDeviceMissing") {
    EmptyDashboardView(state: .crossDeviceMissing, onTapCustom: {})
        .background(Color.coachingBackground)
}
