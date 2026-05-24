// Views/Components/SessionTipBubble.swift
// Story 3.19 Jalon 3 — bubble inline avatar Léon "L" or + texte tip court.
// Apparaît dans la card exo (`exerciseCard` SessionTimelineView), sous les
// chips métrique. Identité Léon cohérente (avatar circulaire or, cf Story 3.14
// avatar sport contextuel).
//
// Accessibilité : élément combiné, texte = label, "Conseil de Léon" en hint.
import SwiftUI

struct SessionTipBubble: View {
    let tip: LocalizedStringKey

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            // Avatar Léon : cercle 28×28, gradient or, lettre "L" en blanc.
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.coachingRecord,
                                Color.coachingRecord.opacity(0.7)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Text(verbatim: "L")
                    .font(.caption.bold())
                    .foregroundStyle(.white)
            }
            .frame(width: 28, height: 28)
            .accessibilityHidden(true)

            Text(tip)
                .font(.footnote)
                .foregroundStyle(.primary)
                .lineSpacing(2)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .accessibilityElement(children: .combine)
        .accessibilityHint(Text("coaching.session.tip.a11y.hint"))
    }
}

#if DEBUG
#Preview("Tip squat") {
    SessionTipBubble(tip: "coaching.tip.squat")
        .padding()
}

#Preview("Tip run.endurance") {
    SessionTipBubble(tip: "coaching.tip.run.endurance")
        .padding()
}
#endif
