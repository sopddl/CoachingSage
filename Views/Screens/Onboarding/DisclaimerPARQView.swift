// Views/Screens/Onboarding/DisclaimerPARQView.swift
// Onboarding app « fil de Léon » — écran ② : PARQ-light bref (exception MDR documentée).
// Léon introduit les 5 questions sécurité (« les mêmes pour tout le monde »). Non médical,
// non alarmiste : si un risque est signalé, Léon propose une intensité douce + suggère (sans
// imposer) un avis médical. L'analytics a été déplacé dans le bloc accord du fil (écran ①).
import SwiftUI
import SageCore

struct DisclaimerPARQView: View {
    @Bindable var viewModel: OnboardingViewModel

    private let questions: [(PARQQuestion, LocalizedStringKey)] = [
        (.q1ChestPain, "onboarding.parq.q1"),
        (.q2Dizziness, "onboarding.parq.q2"),
        (.q3JointAggravated, "onboarding.parq.q3"),
        (.q4HeartMedication, "onboarding.parq.q4"),
        (.q5OtherReason, "onboarding.parq.q5")
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                Text("onboarding.parq.header.title")
                    .font(.coachingDisplay)
                    .foregroundStyle(Color.coachingTextPrimary)
                    .padding(.top, 8)

                // Léon introduit le PARQ — désamorce le sentiment d'être pris pour un cardiaque fragile.
                OnboardingLeonBubble("onboarding.parq.leon.intro")

                VStack(alignment: .leading, spacing: 10) {
                    ForEach(questions, id: \.0) { question, labelKey in
                        Toggle(isOn: bindingFor(question)) {
                            Text(labelKey)
                                .font(.coachingBody)
                                .foregroundStyle(Color.coachingTextPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .tint(Color.coachingPrimary)
                        .accessibilityIdentifier("onboarding.parq.\(question.rawValue).toggle")
                    }
                }

                // Si un risque est signalé → bulle de Léon rassurante (intensité douce + avis médical
                // suggéré, jamais imposé). Non médical, non alarmiste (réutilise le ton du disclaimer).
                if viewModel.anyParqYes {
                    OnboardingLeonBubble("onboarding.parq.leon.risk")
                        .accessibilityIdentifier("onboarding.parq.warning.banner")
                }

                // Disclaimer médical compact + version acceptée (enregistrée au finalize).
                VStack(alignment: .leading, spacing: 4) {
                    Text("onboarding.disclaimer.body")
                        .font(.coachingCaption)
                        .foregroundStyle(Color.coachingTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                    HStack(spacing: 4) {
                        Text("onboarding.disclaimer.version")
                        Text(verbatim: OnboardingViewModel.disclaimerCurrentVersion)
                    }
                    .font(.coachingCaption)
                    .foregroundStyle(Color.coachingTextSecondary)
                }
                .padding(.top, 4)

                if let errorMessage = viewModel.saveErrorMessage {
                    Text(verbatim: errorMessage)
                        .font(.coachingCaption)
                        .foregroundStyle(Color.coachingError)
                        .accessibilityIdentifier("onboarding.save.error")
                }

                Spacer(minLength: 16)
            }
            .padding(.horizontal, 24)
        }
        .scrollIndicators(.visible)
        .safeAreaInset(edge: .bottom) {
            Button(action: { viewModel.goNext() }) {
                Text("onboarding.continue")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.horizontal, 24)
            .padding(.top, 8)
            .padding(.bottom, 16)
            .background(Color.coachingBackground.ignoresSafeArea(edges: .bottom))
            .accessibilityIdentifier("onboarding.parq.continue.button")
        }
    }

    private func bindingFor(_ question: PARQQuestion) -> Binding<Bool> {
        Binding(
            get: { viewModel.parqResponses[question.rawValue] ?? false },
            set: { viewModel.parqResponses[question.rawValue] = $0 }
        )
    }
}
