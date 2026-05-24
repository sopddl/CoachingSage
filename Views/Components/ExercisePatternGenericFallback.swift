// Views/Components/ExercisePatternGenericFallback.swift
// Story 3.19 — fallback visuel quand `ExercisePatternResolver` retourne `.generic`.
// Garantit qu'on a TOUJOURS un visuel dans la card exo (jamais EmptyView/card vide).
// Utilise le SF Symbol sport iOS 17 en mode `.palette` multi-couleurs pour cohérence
// avec le hero header (couleur signature sport).
import SwiftUI

struct ExercisePatternGenericFallback: View {
    let sportCode: String
    var size: CGFloat = 48

    var body: some View {
        Image(systemName: SportSymbol.symbol(forCode: sportCode))
            .resizable()
            .scaledToFit()
            .symbolRenderingMode(.palette)
            .foregroundStyle(
                Color.coachingSport(forCode: sportCode),
                Color.coachingRecord,
                Color.coachingEarth
            )
            .frame(width: size, height: size)
            .accessibilityHidden(true)
    }
}

#if DEBUG
#Preview("Generic fallback — 6 sports") {
    let codes: [String] = ["running", "cycling", "swimming", "strengthTraining", "tennis", "hiking"]
    return HStack(spacing: 16) {
        ForEach(codes, id: \.self) { code in
            VStack {
                ExercisePatternGenericFallback(sportCode: code, size: 48)
                Text(verbatim: code).font(.caption2)
            }
        }
    }
    .padding()
    .background(Color.coachingBackground)
}
#endif
