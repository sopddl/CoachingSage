// Views/Components/GlossaryTermBadge.swift
// Phase A — composant tappable affichant un terme technique (ex: "Daniels-E",
// "Z2", "RPE 7-8") avec icône info. Tap → popover/sheet avec définition courte
// (titre + 1-2 phrases) résolue via `Glossary.entry(forZone:)`.
//
// Si aucun terme connu n'est matché, le composant retombe sur un simple Text
// sans interactivité (pas de bouton mort, pas d'icône info).
import SwiftUI

struct GlossaryTermBadge: View {
    let term: String
    /// Revue qualité thème #1 : quand le code coach est relégué en sous-texte derrière une
    /// sensation (« endurance — tu peux parler » + `FTP-Z2`), on l'affiche en gris discret —
    /// il reste tappable (icône info conservée pour la découvrabilité), mais n'est plus l'accent.
    var secondary: Bool = false

    @State private var showDefinition: Bool = false

    var body: some View {
        if let entry = Glossary.entry(forZone: term) {
            Button {
                showDefinition = true
            } label: {
                HStack(spacing: 4) {
                    Text(verbatim: term)
                    Image(systemName: "info.circle")
                        .font(.caption2)
                }
                .foregroundStyle(secondary ? AnyShapeStyle(.secondary) : AnyShapeStyle(Color.coachingPrimary))
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("coaching.glossary.term.\(entry.id)")
            .popover(isPresented: $showDefinition, attachmentAnchor: .point(.center)) {
                GlossaryDefinitionPopover(entry: entry, term: term)
                    .presentationCompactAdaptation(.popover)
            }
        } else {
            Text(verbatim: term)
        }
    }
}

// Story 3.17 — promu de private à internal pour partage avec GlossaryRichText.
struct GlossaryDefinitionPopover: View {
    let entry: GlossaryEntry
    let term: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "info.circle.fill")
                    .foregroundStyle(Color.coachingPrimary)
                Text(LocalizedStringKey(entry.titleKey))
                    .font(.subheadline.bold())
                Spacer(minLength: 0)
            }
            Text(verbatim: term)
                .font(.caption.monospaced())
                .foregroundStyle(.secondary)
            Text(LocalizedStringKey(entry.definitionKey))
                .font(.callout)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: 320)
    }
}

#if DEBUG
#Preview("Glossary — Daniels-E") {
    VStack(spacing: 20) {
        GlossaryTermBadge(term: "Daniels-E")
        GlossaryTermBadge(term: "Z2")
        GlossaryTermBadge(term: "RPE 7-8")
        GlossaryTermBadge(term: "FTP-Z3")
        GlossaryTermBadge(term: "EN3")
        GlossaryTermBadge(term: "unknown-term")
    }
    .padding()
}
#endif
