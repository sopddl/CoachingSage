// Views/Screens/TodayView.swift
// Story 1.2 placeholder — contenu Epic 3+ (séance du jour, prochaine séance).
import SwiftUI

struct TodayView: View {
    var body: some View {
        PlaceholderScreen(
            systemImage: "sun.max.fill",
            titleKey: "tab.today",
            subtitleKey: "placeholder.coming_soon"
        )
    }
}

#Preview {
    TodayView()
}
