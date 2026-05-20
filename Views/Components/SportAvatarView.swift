// Views/Components/SportAvatarView.swift
// Story 3.14 — avatar sport-specific dans le questionnaire (remplace Léon
// pendant la génération). Mapping sport→symbol centralisé via
// `Sport(sportCode:)?.sfSymbol`, fond via `Color.coachingSport(forCode:)`
// (fallback `coachingTextSecondary` géré nativement). Sport inconnu →
// SF Symbol `questionmark.circle.fill` + warning console (pas crash).
import SwiftUI
import TemplateModel

struct SportAvatarView: View {
    let sportCode: String
    let size: CGFloat

    init(sportCode: String, size: CGFloat = 40) {
        self.sportCode = sportCode
        self.size = size
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.coachingSport(forCode: sportCode))
            Image(systemName: symbolName)
                .resizable()
                .scaledToFit()
                .foregroundStyle(.white)
                .padding(size * 0.22)
        }
        .frame(width: size, height: size)
        .accessibilityLabel(Text("chat.a11y.questionnaireSportAvatar"))
    }

    private var symbolName: String { Self.symbolName(forSportCode: sportCode) }

    /// Helper testable — résolution sport code → SF Symbol. Tout sport inconnu
    /// renvoie `questionmark.circle.fill` + warning console. Exposé pour tests.
    static func symbolName(forSportCode sportCode: String) -> String {
        if let sport = Sport(sportCode: sportCode) {
            return sport.sfSymbol
        }
        print("⚠️ SportAvatarView: unknown sportCode '\(sportCode)' → fallback questionmark.circle.fill")
        return "questionmark.circle.fill"
    }
}

#Preview("10 sports + fallback") {
    let codes: [String] = [
        "running", "cycling",
        "swimming", "triathlon",
        "strengthTraining", "yoga",
        "hiit", "hiking",
        "tennis", "football",
        "unknownSport", "unknownSport"
    ]
    return VStack(spacing: 12) {
        ForEach(0..<6, id: \.self) { row in
            HStack(spacing: 16) {
                SportAvatarView(sportCode: codes[row * 2], size: 48)
                SportAvatarView(sportCode: codes[row * 2 + 1], size: 48)
            }
        }
    }
    .padding()
    .background(Color.coachingBackground)
}
