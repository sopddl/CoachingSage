// Views/Components/EffortGauge.swift
// Story 3.19 Jalon 3 — jauge effort 5 bars animée. Remplace la cellule
// "Intensité 7/10" du SessionHeroHeader par une représentation visuelle
// progressive (5 niveaux Doux→Maximal, mappés depuis RPE 1-10 via
// `SessionStatsCalculator.effortLevel`).
//
// Animation : allumage cascadé des barres (60ms de décalage par bar) au
// premier `onAppear`, spring response 0.4 dampingFraction 0.7. Respecte
// `accessibilityReduceMotion` (allumage statique sans animation).
//
// Accessibilité : la vue elle-même est marquée `accessibilityHidden(true)` ;
// l'a11y label composé (RPE + niveau) est porté par la cellule stat parente
// dans SessionHeroHeader (cf AC8).
import SwiftUI

struct EffortGauge: View {
    /// Niveau 1...5 (Doux → Maximal). Clampé.
    let level: Int
    /// Active l'animation cascadée au premier `onAppear`.
    var animated: Bool = true

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Barres allumées (état d'animation, démarre à 0 si animé).
    @State private var animatedLevel: Int = 0

    /// Hauteurs progressives (8 / 12 / 16 / 20 / 24 pt) — silhouette de la jauge.
    private static let barHeights: [CGFloat] = [8, 12, 16, 20, 24]
    private static let barWidth: CGFloat = 8
    private static let barSpacing: CGFloat = 3

    private var clampedLevel: Int {
        min(5, max(1, level))
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: Self.barSpacing) {
            ForEach(0..<5, id: \.self) { idx in
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .fill(idx < animatedLevel
                          ? Color.coachingPrimary
                          : Color.coachingPrimary.opacity(0.18))
                    .frame(width: Self.barWidth, height: Self.barHeights[idx])
            }
        }
        .frame(height: Self.barHeights.last)
        .accessibilityHidden(true)
        .onAppear {
            if animated && !reduceMotion {
                for i in 0..<clampedLevel {
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.06) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            animatedLevel = i + 1
                        }
                    }
                }
            } else {
                animatedLevel = clampedLevel
            }
        }
    }
}

#if DEBUG
#Preview("EffortGauge — levels 1→5") {
    HStack(spacing: 24) {
        ForEach(1...5, id: \.self) { l in
            VStack(spacing: 4) {
                EffortGauge(level: l, animated: false)
                Text(verbatim: "L\(l)").font(.caption2).foregroundStyle(.secondary)
            }
        }
    }
    .padding()
}
#endif
