// Views/Components/Session/SessionStepCheckmark.swift
// Story 3.33 (FOCUS) — gros bouton de validation « ✓ Fait » d'une étape. Tap →
// coche + auto-avance (géré par la vue). Si déjà fait : style « validé » (vert)
// + tap = décocher.
import SwiftUI

struct SessionStepCheckmark: View {
    let isCompleted: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "checkmark.circle")
                    .font(.title3)
                Text(isCompleted ? "coaching.session.focus.done.completed" : "coaching.session.focus.done")
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .foregroundStyle(.white)
            .background(isCompleted ? Color.coachingSuccess : Color.coachingPrimary)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isCompleted)
        .accessibilityIdentifier("coaching.session.focus.done")
    }
}
