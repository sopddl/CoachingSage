// Views/Components/Session/BulletedNotes.swift
// Story 3.35h — rend un texte dense (notes d'exo, échauffement, récap) en PUCES
// (jamais un pavé monolithique — retour Sophie : « pas de bloc de texte »).
// Découpe via `SessionPhaseText.bulletLines` (sur « + » et fins de phrase), chaque
// ligne via `GlossaryRichText` pour garder les termes glossaire tappables.
import SwiftUI

struct BulletedNotes: View {
    let text: String
    var font: Font = .footnote
    /// Durée totale optionnelle (« 8 min ») affichée en haut à droite.
    var totalLabel: String? = nil

    private var lines: [String] { SessionPhaseText.bulletLines(from: text) }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            if let totalLabel {
                HStack {
                    Spacer()
                    Text(verbatim: totalLabel).font(.caption.bold()).foregroundStyle(.secondary)
                }
            }
            ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                HStack(alignment: .top, spacing: 6) {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 4))
                        .foregroundStyle(.secondary)
                        .padding(.top, 6)
                    GlossaryRichText(text: line, font: font, foreground: .primary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}
