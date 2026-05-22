// Views/Components/GlossaryRichText.swift
// Story 3.17 Phase 1 — rendu d'un texte avec auto-détection inline des termes
// glossaire (cf `Glossary.matches(in:)`). Termes matchés rendus avec underline
// pointillé + couleur primary, tappables → popover définition.
//
// Implémentation : AttributedString avec attribut `.link(URL)` custom scheme
// `coaching-glossary://term/{id}` + `OpenURLAction` env qui intercepte le tap
// pour présenter le popover sans ouvrir Safari.
//
// Si aucun terme n'est matché, rend un `Text(verbatim:)` plat équivalent à avant
// (zéro régression visuelle).
import SwiftUI

struct GlossaryRichText: View {
    let text: String
    var font: Font = .footnote
    var foreground: Color = .primary

    @State private var presentedEntry: GlossaryEntry?
    @State private var presentedSubstring: String = ""

    var body: some View {
        let matches = Glossary.matches(in: text)
        if matches.isEmpty {
            Text(verbatim: text)
                .font(font)
                .foregroundStyle(foreground)
        } else {
            Text(buildAttributedString(matches: matches))
                .font(font)
                .foregroundStyle(foreground)
                .environment(\.openURL, OpenURLAction { url in
                    if let entry = entryFromURL(url, text: text) {
                        presentedEntry = entry.entry
                        presentedSubstring = entry.substring
                        return .handled
                    }
                    return .systemAction
                })
                .sheet(item: $presentedEntry) { entry in
                    GlossaryDefinitionPopover(entry: entry, term: presentedSubstring)
                        .presentationDetents([.fraction(0.35), .medium])
                        .presentationDragIndicator(.visible)
                        .presentationCompactAdaptation(.popover)
                }
        }
    }

    // MARK: - Building

    private func buildAttributedString(matches: [GlossaryMatch]) -> AttributedString {
        var attributed = AttributedString(text)
        for match in matches {
            guard let attrRange = Range(match.range, in: attributed) else { continue }
            // Text.LineStyle combine pattern + couleur (iOS 16+ AttributedString
            // SwiftUI scope). Sépare-toi du foregroundColor pour permettre couleur
            // texte ≠ couleur underline si besoin futur.
            attributed[attrRange].underlineStyle = Text.LineStyle(pattern: .dot, color: Color.coachingPrimary)
            attributed[attrRange].foregroundColor = Color.coachingPrimary
            if let url = URL(string: "coaching-glossary://term/\(match.entry.id)") {
                attributed[attrRange].link = url
            }
        }
        return attributed
    }

    private func entryFromURL(_ url: URL, text: String) -> (entry: GlossaryEntry, substring: String)? {
        guard url.scheme == "coaching-glossary",
              url.host == "term" else { return nil }
        let id = String(url.path.trimmingPrefix("/"))
        guard let entry = Glossary.entries.first(where: { $0.id == id }) else { return nil }
        // Cherche le 1er substring matché dans le texte original (pour affichage
        // du `term` dans le popover — préserve la casse originale).
        let substring = Glossary.matches(in: text)
            .first(where: { $0.entry.id == id })?
            .matchedSubstring ?? id
        return (entry, substring)
    }
}

// Note : GlossaryEntry conforme déjà à Identifiable (cf Glossary.swift).

// MARK: - Conversion Range<String.Index> → Range<AttributedString.Index>

private extension Range where Bound == AttributedString.Index {
    init?(_ range: Range<String.Index>, in attributed: AttributedString) {
        let plain = String(attributed.characters)
        let lowerOffset = plain.distance(from: plain.startIndex, to: range.lowerBound)
        let upperOffset = plain.distance(from: plain.startIndex, to: range.upperBound)
        let lowerAttr = attributed.index(attributed.startIndex, offsetByCharacters: lowerOffset)
        let upperAttr = attributed.index(attributed.startIndex, offsetByCharacters: upperOffset)
        // Garde-fou bornes.
        guard lowerAttr <= attributed.endIndex, upperAttr <= attributed.endIndex else { return nil }
        self = lowerAttr..<upperAttr
    }
}

#if DEBUG
#Preview("GlossaryRichText — running notes") {
    VStack(alignment: .leading, spacing: 20) {
        GlossaryRichText(
            text: "La séance vise un travail au tempo : fais 4×10 min à allure Daniels-T avec 2 min de récupération. Le threshold est la limite où le lactate monte."
        )
        Divider()
        GlossaryRichText(
            text: "Travail cadence : 6×30s strides en fin de warmup. Cible 180 ppm. Plyometric en option si dispo."
        )
        Divider()
        GlossaryRichText(
            text: "EN1 nage tranquille 800m. Travail technique push-off au mur. CSS test pour calibrer."
        )
        Divider()
        GlossaryRichText(
            text: "Texte sans aucun terme technique — affichage plat équivalent."
        )
    }
    .padding()
}
#endif
