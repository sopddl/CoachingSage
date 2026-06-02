// Views/Components/Session/SessionStepDots.swift
// Story 3.33 (FOCUS) — points de position ●◐○ portés de TailorSage : rempli =
// fait, anneau = courant, vide = à venir. Masqués si > 14 étapes (le compteur
// « 3/11 » suffit alors).
import SwiftUI

struct SessionStepDots: View {
    let steps: [SessionStep]
    let currentIndex: Int
    let completed: Set<Int>

    var body: some View {
        if steps.count > 1 && steps.count <= 14 {
            HStack(spacing: 6) {
                ForEach(steps) { step in
                    Circle()
                        .fill(dotColor(for: step))
                        .frame(width: 7, height: 7)
                        .overlay(
                            Circle()
                                .strokeBorder(Color.coachingPrimary,
                                              lineWidth: step.index == currentIndex ? 1.5 : 0)
                                .frame(width: 11, height: 11)
                        )
                }
            }
            .frame(height: 12)
            .accessibilityHidden(true)
        }
    }

    private func dotColor(for step: SessionStep) -> Color {
        if completed.contains(step.index) { return .coachingPrimary }
        if step.index == currentIndex { return Color.coachingPrimary.opacity(0.25) }
        return Color.coachingTextSecondary.opacity(0.25)
    }
}
