// Utilities/ViewModifiers/SecondaryButtonStyle.swift
// CTA outlined sur fond pâle — utilisé pour CTA HealthKit onboarding.
import SwiftUI

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.coachingH2)
            .foregroundColor(.coachingPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                RoundedRectangle(cornerRadius: CoachingRadius.md)
                    .strokeBorder(Color.coachingPrimary, lineWidth: 1.5)
                    .background(
                        Color.coachingPrimary.opacity(configuration.isPressed ? 0.08 : 0)
                            .clipShape(RoundedRectangle(cornerRadius: CoachingRadius.md))
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
