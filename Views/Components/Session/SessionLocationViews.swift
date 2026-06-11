// Views/Components/Session/SessionLocationViews.swift
// Chantier indoor/outdoor vélo — UI du lieu de pratique :
//  • SessionLocationChip : puce 🏠/🛣️ flippable affichée au HUB AVANT Démarrer (D3).
// Le défaut de lieu est posé DANS le questionnaire de création (Q5, cf
// UniversalQuestionnaire) depuis 2026-06-11 — plus de sheet au lancement.
import SwiftUI
import TemplateModel

/// Puce de lieu flippable (HUB). Tap → bascule vers l'autre variante (D3 : 1 tap,
/// zéro ambiguïté). Affichée uniquement pour une séance vélo « à lieu ».
struct SessionLocationChip: View {
    let environment: SessionEnvironment
    /// Action de bascule (récrit l'override + recharge la variante effective).
    let onFlip: () -> Void

    private var symbol: String {
        environment == .indoor ? "house.fill" : "road.lanes"
    }

    private var labelKey: LocalizedStringKey {
        environment == .indoor ? "coaching.location.indoor" : "coaching.location.outdoor"
    }

    var body: some View {
        Button(action: onFlip) {
            HStack(spacing: 6) {
                Image(systemName: symbol)
                    .font(.caption2)
                Text(labelKey)
                    .font(.caption.weight(.semibold))
                Image(systemName: "arrow.left.arrow.right")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .foregroundStyle(Color.coachingPrimary)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.coachingPrimary.opacity(0.10))
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(labelKey))
        .accessibilityHint(Text("coaching.location.chip.hint"))
        .accessibilityIdentifier("coaching.location.chip")
    }
}

#if DEBUG
#Preview("Puce lieu — indoor / outdoor") {
    VStack(alignment: .leading, spacing: 16) {
        SessionLocationChip(environment: .indoor, onFlip: {})
        SessionLocationChip(environment: .outdoor, onFlip: {})
    }
    .padding()
}
#endif
