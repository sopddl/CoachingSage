// Views/Screens/Onboarding/ThirdPartyAppsSyncView.swift
// Story 3.z — écran inséré entre FirstNameLanguage et PersonalData. Préviens
// l'utilisateur que les apps sport tierces (Strava, Decathlon Coach, Runkeeper,
// Garmin Connect…) doivent être synchronisées avec Apple Santé pour que
// CoachingSage voie les séances. Pas bloquant.
//
// Flow :
//   1. Question initiale : "Tu utilises d'autres apps sport non synchronisées ?"
//      Boutons Oui / Non, suivant.
//   2. Si Oui → checklist 4 apps + "Autre app" texte libre + mini-tutos expandables.
//   3. Bouton de bas : "J'ai activé la sync, continuer" / "Activer plus tard".
import SwiftUI

struct ThirdPartyAppsSyncView: View {
    @Bindable var viewModel: OnboardingViewModel
    @State private var expandedApps: Set<String> = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("onboarding.thirdparty.title")
                    .font(.coachingDisplay)
                    .foregroundStyle(Color.coachingTextPrimary)
                    .padding(.top, 16)

                Text("onboarding.thirdparty.subtitle")
                    .font(.coachingBody)
                    .foregroundStyle(Color.coachingTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                if viewModel.usesUnsyncedApps == nil {
                    initialChoiceButtons
                } else if viewModel.usesUnsyncedApps == true {
                    checklist
                    otherAppField
                }

                Spacer(minLength: 24)
            }
            .padding(.horizontal, 24)
        }
        .safeAreaInset(edge: .bottom) {
            if viewModel.usesUnsyncedApps == true {
                bottomActions
            }
        }
    }

    // MARK: - Mode initial : Oui / Non

    private var initialChoiceButtons: some View {
        VStack(spacing: 12) {
            Button {
                viewModel.usesUnsyncedApps = true
            } label: {
                Text("onboarding.thirdparty.yes")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryButtonStyle())
            .accessibilityIdentifier("onboarding.thirdparty.yes")

            Button {
                viewModel.usesUnsyncedApps = false
                viewModel.goNext()
            } label: {
                Text("onboarding.thirdparty.no")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(SecondaryButtonStyle())
            .accessibilityIdentifier("onboarding.thirdparty.no")
        }
        .padding(.top, 8)
    }

    // MARK: - Mode Oui : checklist

    private var checklist: some View {
        VStack(spacing: 12) {
            ForEach(ThirdPartyApp.allCases, id: \.rawValue) { app in
                appRow(app: app)
            }
        }
    }

    @ViewBuilder
    private func appRow(app: ThirdPartyApp) -> some View {
        let isSelected = viewModel.declaredThirdPartyApps.contains(app.rawValue)
        let isExpanded = expandedApps.contains(app.rawValue)

        VStack(alignment: .leading, spacing: 0) {
            Button {
                viewModel.toggleThirdPartyApp(app)
                if isSelected {
                    expandedApps.remove(app.rawValue)
                } else {
                    expandedApps.insert(app.rawValue)
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundStyle(isSelected ? Color.coachingPrimary : Color.coachingDisabled)
                    Text(app.displayNameKey)
                        .font(.coachingBody)
                        .foregroundStyle(Color.coachingTextPrimary)
                    Spacer()
                    if isSelected {
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.footnote)
                            .foregroundStyle(Color.coachingTextSecondary)
                    }
                }
                .padding(14)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("onboarding.thirdparty.app.\(app.rawValue)")

            if isSelected && isExpanded {
                tutorialSteps(for: app)
                    .padding(.horizontal, 14)
                    .padding(.bottom, 14)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: CoachingRadius.md)
                .fill(Color.coachingCard)
        )
    }

    private func tutorialSteps(for app: ThirdPartyApp) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(1...3, id: \.self) { idx in
                HStack(alignment: .top, spacing: 8) {
                    Text(verbatim: "\(idx).")
                        .font(.caption.bold())
                        .foregroundStyle(Color.coachingPrimary)
                    Text(app.tutorialStepKey(idx))
                        .font(.coachingCaption)
                        .foregroundStyle(Color.coachingTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(.leading, 32)
    }

    // MARK: - Champ "Autre app"

    private var otherAppField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("onboarding.thirdparty.other.label")
                .font(.coachingCaption)
                .foregroundStyle(Color.coachingTextSecondary)
            TextField(
                "onboarding.thirdparty.other.placeholder",
                text: $viewModel.otherAppText
            )
            .textInputAutocapitalization(.words)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: CoachingRadius.md)
                    .fill(Color.coachingCard)
            )
            .onChange(of: viewModel.otherAppText) { _, newValue in
                if newValue.count > 60 {
                    viewModel.otherAppText = String(newValue.prefix(60))
                }
            }
            .accessibilityIdentifier("onboarding.thirdparty.other.field")
        }
        .padding(.top, 8)
    }

    // MARK: - Boutons du bas

    private var bottomActions: some View {
        VStack(spacing: 8) {
            Button {
                viewModel.goNext()
            } label: {
                Text("onboarding.thirdparty.activated.continue")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryButtonStyle())
            .accessibilityIdentifier("onboarding.thirdparty.activated.continue")

            Button {
                viewModel.goNext()
            } label: {
                Text("onboarding.thirdparty.later")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(SecondaryButtonStyle())
            .accessibilityIdentifier("onboarding.thirdparty.later")
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
        .padding(.bottom, 16)
        .background(Color.coachingBackground.ignoresSafeArea(edges: .bottom))
    }
}

// MARK: - ThirdPartyApp affichage
//
// Clés i18n hardcodées en switch (anti-pattern interpolation `LocalizedStringKey("foo.\(bar)")`
// cf hotfix 2026-05-12 AdaptedProgramView : casse l'extraction xcstrings).

private extension ThirdPartyApp {
    /// Nom affiché à l'utilisateur (clé i18n).
    var displayNameKey: LocalizedStringKey {
        switch self {
        case .strava:     return "onboarding.thirdparty.app.strava.name"
        case .decathlon:  return "onboarding.thirdparty.app.decathlon.name"
        case .runkeeper:  return "onboarding.thirdparty.app.runkeeper.name"
        case .garmin:     return "onboarding.thirdparty.app.garmin.name"
        }
    }

    /// Étape 1, 2 ou 3 du mini-tuto (clé i18n statique pour extraction xcstrings).
    func tutorialStepKey(_ index: Int) -> LocalizedStringKey {
        switch (self, index) {
        case (.strava, 1):    return "onboarding.thirdparty.app.strava.step1"
        case (.strava, 2):    return "onboarding.thirdparty.app.strava.step2"
        case (.strava, 3):    return "onboarding.thirdparty.app.strava.step3"
        case (.decathlon, 1): return "onboarding.thirdparty.app.decathlon.step1"
        case (.decathlon, 2): return "onboarding.thirdparty.app.decathlon.step2"
        case (.decathlon, 3): return "onboarding.thirdparty.app.decathlon.step3"
        case (.runkeeper, 1): return "onboarding.thirdparty.app.runkeeper.step1"
        case (.runkeeper, 2): return "onboarding.thirdparty.app.runkeeper.step2"
        case (.runkeeper, 3): return "onboarding.thirdparty.app.runkeeper.step3"
        case (.garmin, 1):    return "onboarding.thirdparty.app.garmin.step1"
        case (.garmin, 2):    return "onboarding.thirdparty.app.garmin.step2"
        case (.garmin, 3):    return "onboarding.thirdparty.app.garmin.step3"
        default:              return "" // Unreachable — index toujours 1...3.
        }
    }
}
