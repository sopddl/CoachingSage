// Views/Components/Session/SessionLocationViews.swift
// Chantier indoor/outdoor vélo (2026-06-10) — UI du lieu de pratique :
//  • SessionLocationChip : puce 🏠/🛣️ flippable affichée au HUB AVANT Démarrer (D3).
//  • CyclingLocationSheet : question « tu roules plutôt où ? » au lancement d'un
//    programme vélo (D2), pose le défaut de lieu.
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

/// Sheet « Tu roules plutôt où ? » présentée au lancement d'un programme vélo (D2).
/// Renvoie le défaut choisi : "indoor" / "outdoor" / "both".
struct CyclingLocationSheet: View {
    let onSelect: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 6) {
                Text("coaching.location.sheet.title")
                    .font(.title3.bold())
                Text("coaching.location.sheet.subtitle")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 8)

            VStack(spacing: 12) {
                choiceButton(titleKey: "coaching.location.sheet.indoor", value: "indoor")
                choiceButton(titleKey: "coaching.location.sheet.outdoor", value: "outdoor")
                choiceButton(titleKey: "coaching.location.sheet.both",
                             subtitleKey: "coaching.location.sheet.both.detail",
                             value: "both")
            }
            Spacer(minLength: 0)
        }
        .padding(20)
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }

    @ViewBuilder
    private func choiceButton(
        titleKey: LocalizedStringKey,
        subtitleKey: LocalizedStringKey? = nil,
        value: String
    ) -> some View {
        Button {
            onSelect(value)
        } label: {
            VStack(alignment: .leading, spacing: 2) {
                Text(titleKey)
                    .font(.callout.bold())
                if let subtitleKey {
                    Text(subtitleKey)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .background(Color.coachingPrimary.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .foregroundStyle(.primary)
        .accessibilityIdentifier("coaching.location.sheet.\(value)")
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

#Preview("Sheet — tu roules où ?") {
    Color.clear.sheet(isPresented: .constant(true)) {
        CyclingLocationSheet { _ in }
    }
}
#endif
