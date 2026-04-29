// Views/Components/TypingIndicatorView.swift
// Story 3.1 — 3 dots animés simulant la réflexion Léon avant chaque question.
// Le delay réel est géré par TypingDelayProvider côté ViewModel ; cette view ne fait QUE l'animation visuelle.
import SwiftUI

struct TypingIndicatorView: View {
    @State private var phase: Int = 0

    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill(Color.coachingTextSecondary)
                    .frame(width: 7, height: 7)
                    .opacity(opacity(for: i))
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .background(Color.coachingCard)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .accessibilityLabel(Text("chat.a11y.leonTyping"))
        .task {
            // Boucle infinie d'animation tant que la view est visible.
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 250_000_000)
                phase = (phase + 1) % 3
            }
        }
    }

    private func opacity(for index: Int) -> Double {
        index == phase ? 1.0 : 0.35
    }
}

#Preview {
    TypingIndicatorView()
        .padding()
        .background(Color.coachingBackground)
}
