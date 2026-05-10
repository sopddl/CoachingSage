// Views/Screens/Onboarding/HowItWorksView.swift
// Story sœur post-3.3b — écran pédagogique inséré entre PersonalData et SportsSelection.
// Explique en 3 cartes les modes de programme générés par Léon (deadline / routine
// cyclique / adaptation continue). Visible une seule fois pendant l'onboarding.
import SwiftUI

struct HowItWorksView: View {
    @Bindable var viewModel: OnboardingViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("onboarding.howItWorks.title")
                    .font(.coachingDisplay)
                    .foregroundStyle(Color.coachingTextPrimary)
                    .padding(.top, 16)

                Text("onboarding.howItWorks.subtitle")
                    .font(.coachingBody)
                    .foregroundStyle(Color.coachingTextSecondary)
                    .padding(.bottom, 4)

                modeCard(
                    icon: "flag.checkered",
                    titleKey: "onboarding.howItWorks.deadline.title",
                    bodyKey: "onboarding.howItWorks.deadline.body"
                )

                modeCard(
                    icon: "arrow.triangle.2.circlepath",
                    titleKey: "onboarding.howItWorks.routine.title",
                    bodyKey: "onboarding.howItWorks.routine.body"
                )

                modeCard(
                    icon: "wand.and.stars",
                    titleKey: "onboarding.howItWorks.adaptation.title",
                    bodyKey: "onboarding.howItWorks.adaptation.body"
                )

                Spacer(minLength: 24)
            }
            .padding(.horizontal, 24)
        }
        .safeAreaInset(edge: .bottom) {
            Button(action: { viewModel.goNext() }) {
                Text("onboarding.howItWorks.continue")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.horizontal, 24)
            .padding(.top, 8)
            .padding(.bottom, 16)
            .background(Color.coachingBackground.ignoresSafeArea(edges: .bottom))
            .accessibilityIdentifier("onboarding.howItWorks.continue.button")
        }
    }

    @ViewBuilder
    private func modeCard(icon: String, titleKey: LocalizedStringKey, bodyKey: LocalizedStringKey) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(Color.coachingPrimary)
                .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 6) {
                Text(titleKey)
                    .font(.coachingH2)
                    .foregroundStyle(Color.coachingTextPrimary)

                Text(bodyKey)
                    .font(.coachingBody)
                    .foregroundStyle(Color.coachingTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.coachingCard, in: RoundedRectangle(cornerRadius: CoachingRadius.md))
    }
}
