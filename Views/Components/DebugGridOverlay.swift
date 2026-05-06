// Views/Components/DebugGridOverlay.swift
//
// Overlay grille debug pour positionner les taps précisément en automatisation
// simu / screenshots. Activé par env var SHOW_DEBUG_GRID=1 — invisible en prod.
// Affiche lignes verticales/horizontales tous les 10% avec labels pourcentage.
//

import SwiftUI

struct DebugGridOverlay: View {
    /// Pas de la grille en pourcentage (10 = lignes tous les 10%).
    let step: Int

    init(step: Int = 10) {
        self.step = step
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Lignes verticales + labels en haut
                ForEach(Array(stride(from: 0, through: 100, by: step)), id: \.self) { pct in
                    let x = geo.size.width * CGFloat(pct) / 100
                    Path { p in
                        p.move(to: CGPoint(x: x, y: 0))
                        p.addLine(to: CGPoint(x: x, y: geo.size.height))
                    }
                    .stroke(Color.red.opacity(pct % 50 == 0 ? 0.55 : 0.25), lineWidth: pct % 50 == 0 ? 1.0 : 0.5)
                    Text("\(pct)")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundStyle(.red)
                        .padding(2)
                        .background(.white.opacity(0.7))
                        .position(x: x, y: 6)
                }
                // Lignes horizontales + labels à gauche
                ForEach(Array(stride(from: 0, through: 100, by: step)), id: \.self) { pct in
                    let y = geo.size.height * CGFloat(pct) / 100
                    Path { p in
                        p.move(to: CGPoint(x: 0, y: y))
                        p.addLine(to: CGPoint(x: geo.size.width, y: y))
                    }
                    .stroke(Color.red.opacity(pct % 50 == 0 ? 0.55 : 0.25), lineWidth: pct % 50 == 0 ? 1.0 : 0.5)
                    Text("\(pct)")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundStyle(.red)
                        .padding(2)
                        .background(.white.opacity(0.7))
                        .position(x: 14, y: y)
                }
            }
            .allowsHitTesting(false)
        }
    }
}

extension View {
    /// Surimpose une grille debug si SHOW_DEBUG_GRID=1. No-op sinon.
    @ViewBuilder
    func debugGridOverlay() -> some View {
        if ProcessInfo.processInfo.environment["SHOW_DEBUG_GRID"] != nil {
            self.overlay(DebugGridOverlay())
        } else {
            self
        }
    }
}
