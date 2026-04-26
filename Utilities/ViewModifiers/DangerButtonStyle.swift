// Utilities/ViewModifiers/DangerButtonStyle.swift
// Bouton action destructive (suppression compte) — Story 1.4.
// Variant rouge de PrimaryButtonStyle, hauteur tactile 52pt (NFR-A04).
import SwiftUI

struct DangerButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.coachingH2)
            .foregroundColor(.coachingOnPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color.coachingError.opacity(configuration.isPressed ? 0.85 : 1.0))
            .cornerRadius(CoachingRadius.md)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
