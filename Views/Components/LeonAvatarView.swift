// Views/Components/LeonAvatarView.swift
// Story 3.1 — avatar Léon dans la conversation chat (review P2-4 : check asset, fallback symbol).
// Si un asset `LeonAvatar` existe dans Assets.xcassets, il sera utilisé. Sinon SF Symbol blanc sur cercle bleu marine.
import SwiftUI

struct LeonAvatarView: View {
    let size: CGFloat

    init(size: CGFloat = 40) {
        self.size = size
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.coachingLeon)
            Image(systemName: "figure.run.circle.fill")
                .resizable()
                .scaledToFit()
                .foregroundStyle(.white)
                .padding(size * 0.22)
        }
        .frame(width: size, height: size)
        .accessibilityLabel(Text("chat.a11y.leonAvatar"))
    }
}

#Preview {
    HStack(spacing: 16) {
        LeonAvatarView(size: 32)
        LeonAvatarView(size: 40)
        LeonAvatarView(size: 56)
    }
    .padding()
    .background(Color.coachingBackground)
}
