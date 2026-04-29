// Views/Components/QuestionAnswerOptionsView.swift
// Story 3.1 — zone d'options en bas de l'écran questionnaire.
// Single choice : capsules cliquables → callback immédiat.
// Multi choice : checkboxes + bouton « Confirmer » (au moins 1 sélection requise).
// Free text : TextField + bouton « Continuer » + bouton « Continuer sans note ».
import SwiftUI

struct QuestionAnswerOptionsView: View {
    let question: QuestionnaireQuestion
    let onAnswer: (AnswerValue) -> Void
    @Binding var freeTextDraft: String
    /// Désactive les contrôles pendant l'avancement (review P1-8 idempotence — feedback visuel).
    let isLocked: Bool

    @State private var multiSelection: Set<String> = []

    var body: some View {
        VStack(spacing: 12) {
            switch question.answerType {
            case .singleChoice:
                singleOptions
            case .multiChoice:
                multiOptions
            case .freeText:
                freeTextEntry
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color.coachingBackground)
        .onChange(of: question.id) { _, _ in
            multiSelection.removeAll()  // reset à chaque nouvelle question
        }
    }

    // MARK: - Single

    private var singleOptions: some View {
        VStack(spacing: 8) {
            ForEach(question.options) { option in
                Button {
                    guard !isLocked else { return }
                    onAnswer(.single(option.code))
                } label: {
                    HStack {
                        Text(LocalizedStringKey(option.labelKey))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Image(systemName: "chevron.right")
                            .font(.footnote)
                            .opacity(0.6)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color.coachingCard)
                    .foregroundStyle(Color.coachingTextPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(isLocked)
            }
        }
    }

    // MARK: - Multi

    private var multiOptions: some View {
        VStack(spacing: 8) {
            ForEach(question.options) { option in
                Button {
                    guard !isLocked else { return }
                    if multiSelection.contains(option.code) {
                        multiSelection.remove(option.code)
                    } else {
                        // Si on sélectionne "none", désélectionner tout le reste (cohérence sémantique).
                        if option.code == "none" {
                            multiSelection = ["none"]
                        } else {
                            multiSelection.remove("none")
                            multiSelection.insert(option.code)
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: multiSelection.contains(option.code) ? "checkmark.square.fill" : "square")
                            .foregroundStyle(multiSelection.contains(option.code) ? Color.coachingPrimary : Color.coachingTextSecondary)
                        Text(LocalizedStringKey(option.labelKey))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color.coachingCard)
                    .foregroundStyle(Color.coachingTextPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(isLocked)
            }

            Button {
                guard !isLocked else { return }
                onAnswer(.multi(Array(multiSelection)))
            } label: {
                Text("questionnaire.options.confirm")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.plain)
            .background(multiSelection.isEmpty ? Color.coachingDisabled : Color.coachingPrimary)
            .foregroundStyle(Color.coachingOnPrimary)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .disabled(multiSelection.isEmpty || isLocked)
        }
    }

    // MARK: - Free text

    private var freeTextEntry: some View {
        VStack(spacing: 12) {
            TextField("", text: $freeTextDraft, axis: .vertical)
                .lineLimit(2...4)
                .textFieldStyle(.roundedBorder)
                .disabled(isLocked)

            HStack(spacing: 8) {
                Button {
                    guard !isLocked else { return }
                    onAnswer(.text(nil))
                } label: {
                    Text("questionnaire.running.q6.action.continueWithoutNote")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.plain)
                .background(Color.coachingCard)
                .foregroundStyle(Color.coachingTextPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .disabled(isLocked)

                Button {
                    guard !isLocked else { return }
                    let trimmed = freeTextDraft.trimmingCharacters(in: .whitespacesAndNewlines)
                    onAnswer(.text(trimmed.isEmpty ? nil : trimmed))
                } label: {
                    Text("questionnaire.options.continue")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.plain)
                .background(Color.coachingPrimary)
                .foregroundStyle(Color.coachingOnPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .disabled(isLocked)
            }
        }
    }
}
