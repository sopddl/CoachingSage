// Views/Screens/Coaching/AutoProfileReviewView.swift
// Story Autoprofil HealthKit (Epic 3 Phase 2 #4)
// Carte de validation/override pour les valeurs Q1 (level) et Q3 (frequency)
// inférées depuis HealthKit, avant le démarrage du SportQuestionnaire.
import SwiftUI

struct AutoProfileReviewView: View {
    let suggestion: AutoProfileSuggestion
    let onContinue: (LevelEstimate, FrequencyEstimate) -> Void
    let onSkip: () -> Void

    @State private var selectedLevel: LevelEstimate
    @State private var selectedFrequency: FrequencyEstimate

    init(
        suggestion: AutoProfileSuggestion,
        onContinue: @escaping (LevelEstimate, FrequencyEstimate) -> Void,
        onSkip: @escaping () -> Void
    ) {
        self.suggestion = suggestion
        self.onContinue = onContinue
        self.onSkip = onSkip
        _selectedLevel = State(initialValue: suggestion.level)
        _selectedFrequency = State(initialValue: suggestion.frequency)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header

                section(title: "questionnaire.autoprofile.review.section.level") {
                    ForEach(allLevels, id: \.self) { level in
                        choiceRow(
                            title: levelLabelKey(level),
                            isSelected: selectedLevel == level,
                            onTap: { selectedLevel = level }
                        )
                    }
                    levelSourceHint
                }

                section(title: "questionnaire.autoprofile.review.section.frequency") {
                    ForEach(allFrequencies, id: \.self) { freq in
                        choiceRow(
                            title: frequencyLabelKey(freq),
                            isSelected: selectedFrequency == freq,
                            onTap: { selectedFrequency = freq }
                        )
                    }
                }

                Spacer(minLength: 24)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
        .background(Color.coachingBackground.ignoresSafeArea())
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 8) {
                Button {
                    onContinue(selectedLevel, selectedFrequency)
                } label: {
                    Text("questionnaire.autoprofile.review.continue")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())
                .accessibilityIdentifier("autoprofile.review.continue")

                Button {
                    onSkip()
                } label: {
                    Text("questionnaire.autoprofile.review.skip")
                        .font(.coachingBody)
                }
                .accessibilityIdentifier("autoprofile.review.skip")
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 16)
            .background(Color.coachingBackground.ignoresSafeArea(edges: .bottom))
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "heart.text.square.fill")
                .font(.system(size: 28))
                .foregroundStyle(Color.coachingPrimary)
            VStack(alignment: .leading, spacing: 4) {
                Text("questionnaire.autoprofile.review.title")
                    .font(.coachingDisplay)
                    .foregroundStyle(Color.coachingTextPrimary)
                Text("questionnaire.autoprofile.review.subtitle")
                    .font(.coachingBody)
                    .foregroundStyle(Color.coachingTextSecondary)
            }
        }
    }

    @ViewBuilder
    private func section<Content: View>(
        title: LocalizedStringKey,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.coachingH2)
                .foregroundStyle(Color.coachingTextPrimary)
            VStack(spacing: 8) {
                content()
            }
        }
    }

    private func choiceRow(
        title: String,
        isSelected: Bool,
        onTap: @escaping () -> Void
    ) -> some View {
        Button(action: onTap) {
            HStack {
                Text(LocalizedStringKey(title))
                    .font(.coachingBody)
                    .foregroundStyle(isSelected ? Color.coachingOnPrimary : Color.coachingTextPrimary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(Color.coachingOnPrimary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: CoachingRadius.md)
                    .fill(isSelected ? Color.coachingPrimary : Color.coachingCard)
            )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("autoprofile.review.option.\(title)")
    }

    @ViewBuilder
    private var levelSourceHint: some View {
        let key: LocalizedStringKey = (suggestion.levelSource == .vo2Max)
            ? "questionnaire.autoprofile.review.source.vo2max"
            : "questionnaire.autoprofile.review.source.frequency"
        Text(key)
            .font(.coachingCaption)
            .foregroundStyle(Color.coachingTextSecondary)
            .padding(.top, 2)
    }

    private var allLevels: [LevelEstimate] {
        [.beginner, .recreational, .regular, .competitive]
    }

    private var allFrequencies: [FrequencyEstimate] {
        [.two, .three, .fourOrMore]
    }

    private func levelLabelKey(_ level: LevelEstimate) -> String {
        "questionnaire.universal.q1.option.\(level.rawValue)"
    }

    private func frequencyLabelKey(_ freq: FrequencyEstimate) -> String {
        "questionnaire.universal.q3.option.\(freq.rawValue)"
    }
}
