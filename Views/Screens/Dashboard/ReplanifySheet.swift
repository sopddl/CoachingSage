// Views/Screens/Dashboard/ReplanifySheet.swift
// Story 3.11 — sheet "Tu n'as pas pu faire ta séance ?".
// Deux actions exposées au caller :
//   - `.reportSession` (AC12)        : déplacer la séance en fin de semaine.
//   - `.shiftWeek(Date)` (AC15-16)   : décaler la semaine en cours à la date choisie.
//
// La sheet gère son propre flux interne en 2 steps via `@State step` :
//   `.choice`   : 2 boutons + Annuler (medium detent).
//   `.pickDate` : DatePicker iOS natif (in: Date()...) + Valider + Retour.
//
// Le caller (SessionView) intercepte les callbacks, exécute le `ReplanifyService`
// et ferme la sheet via `dismiss()` côté caller.
import SwiftUI

/// **Story 3.11** — action choisie par l'utilisateur dans la sheet Replanifier.
enum ReplanifyAction: Equatable {
    case reportSession
    case shiftWeek(Date)
}

struct ReplanifySheet: View {
    let onSelect: (ReplanifyAction) -> Void
    let onCancel: () -> Void

    @State private var step: Step = .choice
    @State private var pickedDate: Date = Date()
    @Environment(\.dismiss) private var dismiss

    enum Step {
        case choice
        case pickDate
    }

    var body: some View {
        VStack(spacing: 0) {
            switch step {
            case .choice:
                choiceView
            case .pickDate:
                pickDateView
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.coachingBackground)
    }

    // MARK: - Step 1 : Choice

    private var choiceView: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 6) {
                Text("replanify.sheet.title")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color.coachingTextPrimary)
                Text("replanify.sheet.subtitle")
                    .font(.coachingBody)
                    .foregroundStyle(Color.coachingTextSecondary)
            }
            .padding(.top, 8)

            VStack(spacing: 12) {
                actionButton(
                    titleKey: "replanify.action.report.title",
                    subtitleKey: "replanify.action.report.subtitle",
                    systemImage: "arrow.right.to.line.compact"
                ) {
                    onSelect(.reportSession)
                }
                .accessibilityIdentifier("replanify.action.report")

                actionButton(
                    titleKey: "replanify.action.shiftWeek.title",
                    subtitleKey: "replanify.action.shiftWeek.subtitle",
                    systemImage: "calendar.badge.clock"
                ) {
                    step = .pickDate
                }
                .accessibilityIdentifier("replanify.action.shiftWeek")
            }

            Spacer(minLength: 8)

            Button {
                onCancel()
                dismiss()
            } label: {
                Text("replanify.cancel")
                    .font(.coachingBody.weight(.semibold))
                    .foregroundStyle(Color.coachingTextSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .accessibilityIdentifier("replanify.cancel")
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .padding(.top, 12)
    }

    private func actionButton(
        titleKey: LocalizedStringKey,
        subtitleKey: LocalizedStringKey,
        systemImage: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.coachingPrimary)
                    .frame(width: 28, height: 28)
                VStack(alignment: .leading, spacing: 4) {
                    Text(titleKey)
                        .font(.coachingBody.weight(.semibold))
                        .foregroundStyle(Color.coachingTextPrimary)
                        .multilineTextAlignment(.leading)
                    Text(subtitleKey)
                        .font(.coachingCaption)
                        .foregroundStyle(Color.coachingTextSecondary)
                        .multilineTextAlignment(.leading)
                }
                Spacer(minLength: 0)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.coachingCard)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Step 2 : DatePicker

    private var pickDateView: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 6) {
                Text("replanify.action.shiftWeek.datePickerTitle")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color.coachingTextPrimary)
            }
            .padding(.top, 8)

            DatePicker(
                "replanify.action.shiftWeek.datePickerTitle",
                selection: $pickedDate,
                in: Date()...,
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .accentColor(Color.coachingPrimary)
            .labelsHidden()
            .accessibilityIdentifier("replanify.shiftWeek.datePicker")

            VStack(spacing: 10) {
                Button(action: {
                    onSelect(.shiftWeek(pickedDate))
                }) {
                    Text("replanify.action.shiftWeek.confirm")
                        .font(.coachingBody.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.coachingPrimary)
                        .foregroundStyle(Color.coachingOnPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .accessibilityIdentifier("replanify.shiftWeek.confirm")

                Button(action: { step = .choice }) {
                    Text("common.back")
                        .font(.coachingBody.weight(.semibold))
                        .foregroundStyle(Color.coachingTextSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
                .accessibilityIdentifier("replanify.shiftWeek.back")
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .padding(.top, 12)
    }
}
