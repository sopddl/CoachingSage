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
    /// Story 3.13 Phase B — sportCode du questionnaire courant. Utilisé par `multiOptions` pour
    /// appliquer la matrice de compatibilité goals Q2 (grisage incompatibles + swap exclusif).
    /// Optionnel pour rétrocompat call sites historiques (autres questions multi sans matrice).
    var sportCode: String? = nil

    @State private var multiSelection: Set<String> = []
    /// **Story 3.16 (Sophie 2026-05-21)** — sélection single avant confirmation
    /// explicite. Avant Story 3.16, le tap singleChoice avançait immédiatement
    /// → inconsistant avec multi/freeText qui ont un bouton Confirmer. Désormais
    /// le tap sélectionne, et l'user doit appuyer "Continuer" pour avancer.
    @State private var singleSelection: String? = nil
    /// Date picker state pour Q4Date story sœur — minimum demain pour éviter date passée.
    @State private var pickedDate: Date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    /// Story 3.13 Phase E (AC25) — toast léger quand un goal exclusif est tapé (auto-désélection).
    @State private var showExclusiveToast: Bool = false

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
            singleSelection = nil       // Story 3.16
            showExclusiveToast = false
        }
    }

    // MARK: - Single

    /// Story 3.13 Phase E — hint pédagogique affichée sous Q2 quand le sport a un catalogue
    /// structurellement exclusif (strengthTraining, triathlon). Rassure l'user que choisir
    /// un seul cycle maintenant n'est pas une frustration finale : il pourra en enchaîner
    /// d'autres après. Nil dans tous les autres cas (= pas de hint cycle parasitaire).
    private var cycleHintKey: LocalizedStringKey? {
        guard let sport = sportCode,
              question.id == UniversalQuestionnaire.q2GoalId,
              UniversalQuestionnaire.isCycleExclusiveSport(sport) else {
            return nil
        }
        return "questionnaire.universal.q2.hint.cycle"
    }

    /// **Story 3.16 (Sophie 2026-05-21)** — singleChoice avec confirmation.
    /// Tap option = sélection (state local), bouton "Continuer" pour confirmer.
    /// Cohérent avec multi/freeText/datePicker. L'user peut changer d'avis
    /// avant de valider et utiliser "Retour" pour revenir à la question
    /// précédente (cf `goBack()` dans le ViewModel).
    private var singleOptions: some View {
        VStack(spacing: 8) {
            if let hint = cycleHintKey {
                Text(hint)
                    .font(.footnote)
                    .foregroundStyle(Color.coachingTextSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 4)
            }
            ForEach(question.options) { option in
                let isSelected = singleSelection == option.code
                Button {
                    guard !isLocked else { return }
                    singleSelection = option.code
                } label: {
                    HStack {
                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(isSelected ? Color.coachingPrimary : Color.coachingTextSecondary)
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

            // **Story 3.16** — bouton Continuer cohérent avec multi/freeText.
            Button {
                guard !isLocked, let code = singleSelection else { return }
                onAnswer(.single(code))
            } label: {
                Text("questionnaire.options.continue")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.plain)
            .background(singleSelection == nil ? Color.coachingDisabled : Color.coachingPrimary)
            .foregroundStyle(Color.coachingOnPrimary)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .disabled(singleSelection == nil || isLocked)
            .padding(.top, 4)
        }
    }

    // MARK: - Multi

    /// Story 3.13 Phase E (AC25) — hint i18n key pour la zone multi-choice. Spécifique Q2 goals
    /// quand sportCode présent (mention "compatibles" pour clarifier les grisages matrice),
    /// sinon hint générique historique.
    private var multiHintKey: LocalizedStringKey {
        if sportCode != nil, question.id == UniversalQuestionnaire.q2GoalId {
            return "questionnaire.universal.q2.hint.multi"
        }
        return "questionnaire.options.multi.hint"
    }

    /// Story 3.13 Phase B — calcule si l'option doit être grisée selon la matrice goals.
    /// Active uniquement si `sportCode` fourni ET question = Q2 goal du questionnaire universel
    /// (les autres questions multi historiques ne sont pas sujettes à la matrice).
    private func goalOptionDisabled(_ optionCode: String) -> Bool {
        guard let sport = sportCode,
              question.id == UniversalQuestionnaire.q2GoalId else {
            return false
        }
        return GoalCompatibilityMatrix.isDisabled(
            option: optionCode,
            given: multiSelection,
            sportCode: sport
        )
    }

    private var multiOptions: some View {
        VStack(spacing: 8) {
            Text(multiHintKey)
                .font(.footnote)
                .foregroundStyle(Color.coachingTextSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 4)

            if showExclusiveToast {
                Text("goal.exclusive.toast")
                    .font(.footnote)
                    .foregroundStyle(Color.coachingOnPrimary)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.coachingPrimary.opacity(0.85))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .transition(.opacity)
                    .accessibilityIdentifier("goalExclusiveToast")
            }

            ForEach(question.options) { option in
                let isSelected = multiSelection.contains(option.code)
                let isDisabledByMatrix = goalOptionDisabled(option.code)
                Button {
                    guard !isLocked, !isDisabledByMatrix else { return }
                    handleMultiTap(optionCode: option.code, isSelected: isSelected)
                } label: {
                    HStack {
                        Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                            .foregroundStyle(isSelected ? Color.coachingPrimary : Color.coachingTextSecondary)
                        Text(LocalizedStringKey(option.labelKey))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color.coachingCard)
                    .foregroundStyle(Color.coachingTextPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .opacity(isDisabledByMatrix ? 0.35 : 1.0)
                }
                .buttonStyle(.plain)
                .disabled(isLocked || isDisabledByMatrix)
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

    /// Logique tap multi-choice avec règles Story 3.13 Phase B :
    ///   • "none" → reset à ["none"] (cohérence sémantique legacy)
    ///   • Q2 goals + sportCode fourni + option exclusive → reset à [exclusive] (swap auto AC6)
    ///   • option non-exclusive tapée alors qu'un exclusif est dans selection → ignore (impossible
    ///     car isDisabled bloque déjà, mais défense en profondeur)
    ///   • sinon : toggle classique
    private func handleMultiTap(optionCode: String, isSelected: Bool) {
        if isSelected {
            multiSelection.remove(optionCode)
            return
        }
        if optionCode == "none" {
            multiSelection = ["none"]
            return
        }
        if let sport = sportCode,
           question.id == UniversalQuestionnaire.q2GoalId,
           GoalCompatibilityMatrix.isExclusive(optionCode, sportCode: sport) {
            // AC6 — exclusif désélectionne tout le reste
            let hadOther = !multiSelection.subtracting([optionCode]).isEmpty
            multiSelection = [optionCode]
            if hadOther { flashExclusiveToast() }
            return
        }
        multiSelection.remove("none")
        multiSelection.insert(optionCode)
    }

    /// Affiche le toast exclusif pendant 2.5s puis le retire (animation opacity).
    private func flashExclusiveToast() {
        withAnimation(.easeInOut(duration: 0.2)) { showExclusiveToast = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeInOut(duration: 0.3)) { showExclusiveToast = false }
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
