// Views/Screens/ProgressionView.swift
// Story 1.2 placeholder — contenu Epic 4+ (progrès, métriques, historique).
// Nommé ProgressionView (pas ProgressView) pour éviter le conflit avec SwiftUI.ProgressView.
import SwiftUI

struct ProgressionView: View {
    var body: some View {
        PlaceholderScreen(
            systemImage: "chart.line.uptrend.xyaxis",
            titleKey: "tab.progress",
            subtitleKey: "placeholder.coming_soon"
        )
    }
}

#Preview {
    ProgressionView()
}
