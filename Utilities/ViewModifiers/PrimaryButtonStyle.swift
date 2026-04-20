// Utilities/ViewModifiers/PrimaryButtonStyle.swift
// ⚠️ Protocole ButtonStyle (accès à configuration.isPressed) — PAS ViewModifier.
// Cible tactile : 52pt > 44pt minimum (NFR-A04)
// VoiceOver : ButtonStyle propage automatiquement le label du Button (NFR-A02)
// Placeholder Story 1.1a — valeurs tokens ajustées en Story 1.2.
import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.coachingH2)
            .foregroundColor(.coachingTextPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color.coachingPrimary.opacity(configuration.isPressed ? 0.85 : 1.0))
            .cornerRadius(CoachingRadius.md)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

extension View {
    func primaryButtonStyle() -> some View {
        self.buttonStyle(PrimaryButtonStyle())
    }
}
