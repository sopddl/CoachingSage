// Views/Components/LeonFloatingButton.swift
// Story 3.8 — FAB Léon accessible depuis tous les onglets de la tab bar.
// Transposition de `~/CL3/GardenSage/Views/Components/FloreFloatingButton.swift`
// adaptée au coach (Color.coachingPrimary #1E5090, icône chat blanche, 54×54).
import SwiftUI

struct LeonFloatingButton: View {
    @Binding var isPresented: Bool

    var body: some View {
        Button {
            isPresented = true
        } label: {
            ZStack {
                Circle()
                    .fill(Color.coachingPrimary)
                    .frame(width: 54, height: 54)
                    .shadow(color: Color.coachingPrimary.opacity(0.35), radius: 8, x: 0, y: 4)
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.white)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("leon.fab.accessibility.label")
        .accessibilityHint("leon.fab.accessibility.hint")
        .accessibilityIdentifier("leon.fab")
    }
}

#Preview {
    LeonFloatingButton(isPresented: .constant(false))
        .padding()
        .background(Color.coachingBackground)
}
