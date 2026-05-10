// Views/Components/LeonFloatingButton.swift
// Story 3.8 (UI redesign 2026-05-09) — FAB Léon pattern « AppIcon Sages mini ».
//
// Couches (du fond vers le centre) :
//   1. Cercle sable `coachingSand` (#F3EDE2) — visible en bordure
//   2. Anneau doré `coachingRecord` (#D4A85A) stroke 3pt
//   3. Cercle bleu coach `coachingPrimary` (#1E5090) plein
//   4. 5 anneaux entrelacés palette Sages (or · blanc · vert · marine · orange),
//      pivotés -5° à gauche pour rappeler la dynamique sportive (Sophie 2026-05-09)
//
// Tailles : 60×60 extérieur. Badge sage retiré 2026-05-10 (Sophie : la croix
// fait doublon visuel sur le FAB, le cercle bleu + 5 anneaux suffit).
// Cohérent avec AppIcon GS/TS (cercle métier + anneau or 36pt).
import SwiftUI

struct LeonFloatingButton: View {
    @Binding var isPresented: Bool

    private static let fabSize: CGFloat = 60
    private static let goldRingDiameter: CGFloat = 54
    private static let blueCoreDiameter: CGFloat = 46

    var body: some View {
        Button {
            isPresented = true
        } label: {
            ZStack {
                // 1. Cercle sable extérieur
                Circle()
                    .fill(Color.coachingSand)
                    .frame(width: Self.fabSize, height: Self.fabSize)

                // 2. Anneau doré
                Circle()
                    .stroke(Color.coachingRecord, lineWidth: 3)
                    .frame(width: Self.goldRingDiameter, height: Self.goldRingDiameter)

                // 3. Cercle bleu plein
                Circle()
                    .fill(Color.coachingPrimary)
                    .frame(width: Self.blueCoreDiameter, height: Self.blueCoreDiameter)

                // 4. 5 anneaux Sages, pivotés -5° gauche
                fiveRingsSages
                    .rotationEffect(.degrees(-5))
                    .frame(width: Self.blueCoreDiameter - 6, height: Self.blueCoreDiameter - 6)
            }
            .frame(width: Self.fabSize, height: Self.fabSize)
            .shadow(color: Color.coachingPrimary.opacity(0.30), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("leon.fab.accessibility.label")
        .accessibilityHint("leon.fab.accessibility.hint")
        .accessibilityIdentifier("leon.fab")
    }

    // MARK: - 5 anneaux Sages

    /// 5 cercles entrelacés (visuellement empilés sans interlacing path complexe).
    /// Palette CoachingSage non litigieuse — évite les marques CIO. Disposition
    /// 3-haut + 2-bas comme les ronds olympiques classiques.
    @ViewBuilder
    private var fiveRingsSages: some View {
        GeometryReader { geo in
            let ringDiameter = geo.size.width * 0.30
            let lineWidth: CGFloat = 1.6
            let xSpacing = ringDiameter * 0.78
            let yOffset = ringDiameter * 0.30

            ZStack {
                // Top row : doré, blanc, vert
                Circle()
                    .stroke(Color.coachingRecord, lineWidth: lineWidth)
                    .frame(width: ringDiameter, height: ringDiameter)
                    .position(x: geo.size.width / 2 - xSpacing, y: geo.size.height / 2 - yOffset)
                Circle()
                    .stroke(Color.white, lineWidth: lineWidth)
                    .frame(width: ringDiameter, height: ringDiameter)
                    .position(x: geo.size.width / 2, y: geo.size.height / 2 - yOffset)
                Circle()
                    .stroke(Color.coachingAccent, lineWidth: lineWidth)
                    .frame(width: ringDiameter, height: ringDiameter)
                    .position(x: geo.size.width / 2 + xSpacing, y: geo.size.height / 2 - yOffset)

                // Bottom row : marine, orange
                Circle()
                    .stroke(Color.coachingEarth, lineWidth: lineWidth)
                    .frame(width: ringDiameter, height: ringDiameter)
                    .position(x: geo.size.width / 2 - xSpacing / 2, y: geo.size.height / 2 + yOffset)
                Circle()
                    .stroke(Color.coachingWarning, lineWidth: lineWidth)
                    .frame(width: ringDiameter, height: ringDiameter)
                    .position(x: geo.size.width / 2 + xSpacing / 2, y: geo.size.height / 2 + yOffset)
            }
        }
    }

}

#if DEBUG
#Preview {
    VStack(spacing: 24) {
        LeonFloatingButton(isPresented: .constant(false))
        LeonFloatingButton(isPresented: .constant(false))
            .background(Color.coachingPrimary.opacity(0.05))
    }
    .padding(40)
    .background(Color.coachingBackground)
}
#endif
