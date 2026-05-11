// Views/Screens/Onboarding/HowItWorksView.swift
// Story sœur post-3.3b — écran pédagogique inséré entre PersonalData et SportsSelection.
// Story 3.4 prélude (2026-05-11) — enrichi pour annoncer adaptation HK + pause/reprise,
// et exposé aussi depuis ProfileView via API closure dual-mode (onboarding vs profil).
//
// 4 cartes :
//   1. Deadline (date cible)
//   2. Routine cyclique (3 mois renouvelable)
//   3. Adaptation continue (Léon ajuste le programme depuis Apple Santé + apps tierces)
//   4. Pause & reprise (doctrine ACSM — re-déconditionnement après pause)
//
// API : `onContinue` closure permet de réutiliser la vue depuis le profil sans
// dépendre d'OnboardingViewModel. Si nil → pas de bouton (push nav, retour back).
import SwiftUI

struct HowItWorksView: View {
    /// Callback du bouton du bas. `nil` masque le bouton (ex: push nav depuis Profil
    /// où l'utilisateur revient via le back button standard).
    var onContinue: (() -> Void)?

    /// Label du bouton du bas. Default = "C'est parti" (onboarding).
    var continueLabelKey: LocalizedStringKey = "onboarding.howItWorks.continue"

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

                modeCard(
                    icon: "pause.circle",
                    titleKey: "onboarding.howItWorks.pauseRecovery.title",
                    bodyKey: "onboarding.howItWorks.pauseRecovery.body"
                )

                Spacer(minLength: 24)
            }
            .padding(.horizontal, 24)
        }
        .safeAreaInset(edge: .bottom) {
            if let onContinue {
                Button(action: onContinue) {
                    Text(continueLabelKey)
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
