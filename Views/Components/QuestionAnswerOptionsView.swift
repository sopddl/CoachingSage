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
    /// Date picker state pour Q4Date story sœur — minimum demain pour éviter date passée.
    @State private var pickedDate: Date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()

    /// Cas spécial story sœur : Q4Date = date picker plutôt que TextField freeText.
    private var isDatePicker: Bool {
        question.id == UniversalQuestionnaire.q4DateId
    }

    var body: some View {
        VStack(spacing: 12) {
            if isDatePicker {
                datePickerEntry
            } else {
                switch question.answerType {
                case .singleChoice:
                    singleOptions
                case .multiChoice:
                    multiOptions
                case .freeText:
                    freeTextEntry
                }
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
            Text("questionnaire.options.multi.hint")
                .font(.footnote)
                .foregroundStyle(Color.coachingTextSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 4)

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

    // MARK: - Date picker (Q4Date story sœur)

    private var datePickerEntry: some View {
        VStack(spacing: 12) {
            DatePicker(
                "",
                selection: $pickedDate,
                in: Calendar.current.date(byAdding: .day, value: 1, to: Date())!...,
                displayedComponents: [.date]
            )
            .datePickerStyle(.graphical)
            .labelsHidden()
            .tint(Color.coachingPrimary)
            .disabled(isLocked)

            Button {
                guard !isLocked else { return }
                let iso = ISO8601DateFormatter().string(from: pickedDate)
                onAnswer(.text(iso))
            } label: {
                Text("questionnaire.universal.q4_date.continue")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.plain)
            .background(Color.coachingPrimary)
            .foregroundStyle(Color.coachingOnPrimary)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .disabled(isLocked)
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
