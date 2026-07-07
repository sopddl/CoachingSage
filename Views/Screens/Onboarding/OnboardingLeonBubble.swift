// Views/Screens/Onboarding/OnboardingLeonBubble.swift
// Bulle conversationnelle de Léon dans le « fil de Léon » (onboarding app).
// Avatar + bulle bleue (texte clair). Réutilisée par le fil ① et la clôture ③.
import SwiftUI

struct OnboardingLeonBubble: View {
    private let text: Text

    init(_ key: LocalizedStringKey) {
        self.text = Text(key)
    }

    /// Variante pour un texte déjà localisé/interpolé (ex. prénom injecté via String(format:)).
    init(verbatim string: String) {
        self.text = Text(verbatim: string)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 9) {
            LeonAvatarView(size: 33)
            text
                .font(.coachingBody)
                .foregroundStyle(Color.coachingLeonText)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 13)
                .padding(.vertical, 10)
                .background(
                    UnevenRoundedRectangle(
                        cornerRadii: .init(topLeading: 15, bottomLeading: 5, bottomTrailing: 15, topTrailing: 15)
                    )
                    .fill(Color.coachingPrimary)
                )
            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    VStack(spacing: 12) {
        OnboardingLeonBubble("onboarding.fil.greeting")
        OnboardingLeonBubble(verbatim: "Enchanté, Sophie 👋 Dis-moi ce que tu pratiques.")
    }
    .padding()
    .background(Color.coachingBackground)
}
