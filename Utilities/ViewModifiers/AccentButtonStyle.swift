// Utilities/ViewModifiers/AccentButtonStyle.swift
// « Vert = validation » — règle transversale app (party onboarding 2026-06-22).
// CTA de validation ferme (ex. « C'est parti », « On y va ») : fond `coachingAccent` (#7BC142),
// texte vert sombre, semibold (pas bold). À distinguer du bleu `PrimaryButtonStyle` (action neutre).
// Cible tactile 52pt > 44pt (NFR-A04). VoiceOver : ButtonStyle propage le label du Button.
import SwiftUI

struct AccentButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.coachingH2)
            .fontWeight(.semibold)
            .foregroundColor(.coachingOnAccent)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color.coachingAccent.opacity(configuration.isPressed ? 0.85 : 1.0))
            .cornerRadius(CoachingRadius.md)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

extension View {
    func accentButtonStyle() -> some View {
        self.buttonStyle(AccentButtonStyle())
    }
}
