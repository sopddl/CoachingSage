// Views/Screens/Onboarding/DisclaimerPARQView.swift
// Story 2.2 — écran 4 : disclaimer médical + PARQ-light + consentement analytics.
// 3 sections visuellement séparées (review P2-1).
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
            VStack(alignment: .leading, spacing: 0) {

                // BLOC 1 — Disclaimer médical
                VStack(alignment: .leading, spacing: 8) {
                    Text("onboarding.disclaimer.title")
                        .font(.coachingH1)
                        .foregroundStyle(Color.coachingTextPrimary)
                    Text("onboarding.disclaimer.body")
                        .font(.coachingBody)
                        .foregroundStyle(Color.coachingTextPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    HStack(spacing: 4) {
                        Text("onboarding.disclaimer.version")
                        Text(verbatim: OnboardingViewModel.disclaimerCurrentVersion)
                    }
                    .font(.coachingCaption)
                    .foregroundStyle(Color.coachingTextSecondary)
                }
                .padding(.top, 8)

                Divider().padding(.vertical, 12)

                // BLOC 2 — Consentement analytics (Sophie 2026-05-11 : remonté avant PARQ
                // sinon caché tout en bas → l'user ne voit jamais le toggle et on n'a jamais
                // de oui. Mieux placé juste après le disclaimer médical avant les questions
                // santé qui demandent de la concentration).
                VStack(alignment: .leading, spacing: 8) {
                    Toggle(isOn: $viewModel.analyticsConsent) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("onboarding.analytics.toggle.label")
                                .font(.coachingBody)
                                .foregroundStyle(Color.coachingTextPrimary)
                            Text("onboarding.analytics.toggle.helper")
                                .font(.coachingCaption)
                                .foregroundStyle(Color.coachingTextSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .tint(Color.coachingPrimary)
                    .accessibilityIdentifier("onboarding.analytics.toggle")
                }

                Divider().padding(.vertical, 12)

                // BLOC 3 — PARQ-light (en dernier — questions santé requièrent
                // de bien lire avant de tap Démarrer).
                VStack(alignment: .leading, spacing: 10) {
                    Text("onboarding.parq.title")
                        .font(.coachingH1)
                        .foregroundStyle(Color.coachingTextPrimary)

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

                    if viewModel.anyParqYes {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(Color.coachingWarning)
                            Text("onboarding.parq.warning")
                                .font(.coachingCaption)
                                .foregroundStyle(Color.coachingTextPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.coachingWarning.opacity(0.15), in: RoundedRectangle(cornerRadius: CoachingRadius.md))
                        .accessibilityIdentifier("onboarding.parq.warning.banner")
                    }
                }

                if let errorMessage = viewModel.saveErrorMessage {
                    Text(verbatim: errorMessage)
                        .font(.coachingCaption)
                        .foregroundStyle(Color.coachingError)
                        .padding(.top, 12)
                        .accessibilityIdentifier("onboarding.save.error")
                }

                Spacer(minLength: 16)
            }
            .padding(.horizontal, 24)
        }
        .scrollIndicators(.visible)
        .safeAreaInset(edge: .bottom) {
            Button(action: { viewModel.goNext() }) {
                HStack(spacing: 8) {
                    if viewModel.isSaving {
                        ProgressView().tint(Color.coachingOnPrimary)
                    }
                    Text("onboarding.start")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(viewModel.isSaving)
            .padding(.horizontal, 24)
            .padding(.top, 8)
            .padding(.bottom, 16)
            .background(Color.coachingBackground.ignoresSafeArea(edges: .bottom))
            .accessibilityIdentifier("onboarding.start.button")
        }
    }

    private func bindingFor(_ question: PARQQuestion) -> Binding<Bool> {
        Binding(
            get: { viewModel.parqResponses[question.rawValue] ?? false },
            set: { viewModel.parqResponses[question.rawValue] = $0 }
        )
    }
}
