// Views/Screens/GlossaryIndexView.swift
// Story 3.26 Phase B — page glossaire dédiée accessible depuis ProfileView.
// Liste alphabétique searchable de tous les termes du glossaire + filtre
// horizontal par sport (chips). Tap entrée → push GlossaryEntryDetailView.
import SwiftUI
import TemplateModel

struct GlossaryIndexView: View {
    @Environment(\.languageManager) private var languageManager
    @State private var searchText: String = ""
    @State private var selectedSport: Sport? = nil  // nil = tous les sports

    var body: some View {
        VStack(spacing: 0) {
            sportFilterChips
                .padding(.vertical, 8)
                .background(Color.coachingBackground)

            entriesList
        }
        .background(Color.coachingBackground)
        .searchable(
            text: $searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: Text("glossary.index.search.placeholder")
        )
        .navigationTitle("glossary.index.title")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Filter chips

    @ViewBuilder
    private var sportFilterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ChipButton(
                    titleKey: "glossary.index.filter.all",
                    systemImage: nil,
                    isSelected: selectedSport == nil,
                    action: { selectedSport = nil }
                )
                .accessibilityIdentifier("glossary.index.filter.all")

                ForEach(allSports, id: \.rawValue) { sport in
                    ChipButton(
                        titleKey: sport.localizedKey,
                        systemImage: sport.sfSymbol,
                        isSelected: selectedSport == sport,
                        action: { selectedSport = sport }
                    )
                    .accessibilityIdentifier("glossary.index.filter.\(sport.appSportCode)")
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private var allSports: [Sport] {
        [.running, .cycling, .swimming, .triathlon, .strengthTraining,
         .yoga, .hiit, .hiking, .tennis, .football]
    }

    // MARK: - Entries list

    @ViewBuilder
    private var entriesList: some View {
        let sections = sectionedEntries
        if sections.isEmpty {
            ContentUnavailableView(
                "glossary.index.empty.title",
                systemImage: "magnifyingglass",
                description: Text("glossary.index.empty.description")
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.coachingBackground)
        } else {
            List {
                ForEach(sections, id: \.letter) { section in
                    Section(section.letter) {
                        ForEach(section.entries) { entry in
                            NavigationLink {
                                GlossaryEntryDetailView(entry: entry)
                            } label: {
                                GlossaryEntryRow(entry: entry)
                            }
                            .accessibilityIdentifier("glossary.index.row.\(entry.id)")
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color.coachingBackground)
        }
    }

    // MARK: - Filtering + grouping

    private struct AlphaSection {
        let letter: String
        let entries: [GlossaryEntry]
    }

    /// Résout le title localisé d'une entrée pour search + grouping.
    private func resolvedTitle(_ entry: GlossaryEntry) -> String {
        String.localized(String.LocalizationValue(entry.titleKey),
                         locale: languageManager.currentLocale)
    }

    private var filteredEntries: [GlossaryEntry] {
        let search = searchText.trimmingCharacters(in: .whitespaces)
            .folding(options: .diacriticInsensitive, locale: nil)
            .lowercased()
        return Glossary.entries.filter { entry in
            if let sport = selectedSport,
               !entry.sportCodes.contains(sport.rawValue) {
                return false
            }
            guard !search.isEmpty else { return true }
            let title = resolvedTitle(entry)
                .folding(options: .diacriticInsensitive, locale: nil)
                .lowercased()
            return title.contains(search) || entry.id.lowercased().contains(search)
        }
    }

    private var sectionedEntries: [AlphaSection] {
        let entries = filteredEntries
        let grouped = Dictionary(grouping: entries) { entry -> String in
            let title = resolvedTitle(entry)
            let first = String(title.prefix(1))
                .folding(options: .diacriticInsensitive, locale: nil)
                .uppercased()
            // Si le titre commence par un chiffre, regroupe sous "#"
            if let scalar = first.unicodeScalars.first, CharacterSet.decimalDigits.contains(scalar) {
                return "#"
            }
            return first
        }
        return grouped
            .map { (letter, entries) in
                AlphaSection(
                    letter: letter,
                    entries: entries.sorted { resolvedTitle($0) < resolvedTitle($1) }
                )
            }
            .sorted { lhs, rhs in
                // "#" en fin de liste
                if lhs.letter == "#" { return false }
                if rhs.letter == "#" { return true }
                return lhs.letter < rhs.letter
            }
    }
}

// MARK: - Row

private struct GlossaryEntryRow: View {
    let entry: GlossaryEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(LocalizedStringKey(entry.titleKey))
                .font(.coachingBody.weight(.semibold))
                .foregroundStyle(Color.coachingTextPrimary)
            Text(LocalizedStringKey(entry.definitionKey))
                .font(.coachingCaption)
                .foregroundStyle(Color.coachingTextSecondary)
                .lineLimit(2)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Chip

private struct ChipButton: View {
    let titleKey: LocalizedStringKey
    let systemImage: String?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let systemImage {
                    Image(systemName: systemImage).font(.caption)
                }
                Text(titleKey).font(.subheadline.weight(.medium))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.coachingPrimary : Color.coachingCard)
            .foregroundStyle(isSelected ? Color.white : Color.coachingTextPrimary)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Detail

struct GlossaryEntryDetailView: View {
    let entry: GlossaryEntry

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(Color.coachingPrimary)
                        .font(.title3)
                    Text(LocalizedStringKey(entry.titleKey))
                        .font(.coachingH2)
                        .foregroundStyle(Color.coachingTextPrimary)
                    Spacer()
                }

                Text(LocalizedStringKey(entry.definitionKey))
                    .font(.coachingBody)
                    .foregroundStyle(Color.coachingTextPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                if !entry.sportCodes.isEmpty {
                    sportTags
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.coachingBackground)
        .navigationTitle("glossary.entry.detail.title")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var sportTags: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("glossary.entry.detail.sports")
                .font(.coachingCaption)
                .foregroundStyle(Color.coachingTextSecondary)
                .textCase(.uppercase)
            FlowLayout(spacing: 6) {
                ForEach(resolvedSports, id: \.rawValue) { sport in
                    sportTag(sport)
                }
            }
        }
    }

    /// Map sportCodes (snake_case strings) → Sport enum, en ignorant les codes inconnus.
    private var resolvedSports: [Sport] {
        entry.sportCodes.compactMap { Sport(sportCode: $0) }
    }

    @ViewBuilder
    private func sportTag(_ sport: Sport) -> some View {
        HStack(spacing: 4) {
            Image(systemName: sport.sfSymbol).font(.caption2)
            Text(sport.localizedKey).font(.caption)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.coachingCard)
        .clipShape(Capsule())
    }
}

// MARK: - FlowLayout (simple wrap layout pour tags)

private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var totalHeight: CGFloat = 0
        var lineWidth: CGFloat = 0
        var lineHeight: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if lineWidth + size.width > maxWidth, lineWidth > 0 {
                totalHeight += lineHeight + spacing
                lineWidth = 0
                lineHeight = 0
            }
            lineWidth += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
        totalHeight += lineHeight
        return CGSize(width: maxWidth.isFinite ? maxWidth : lineWidth, height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x: CGFloat = bounds.minX
        var y: CGFloat = bounds.minY
        var lineHeight: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                x = bounds.minX
                y += lineHeight + spacing
                lineHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: .init(size))
            x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
    }
}

#if DEBUG
#Preview("Glossary Index — FR") {
    NavigationStack {
        GlossaryIndexView()
    }
    .environment(\.locale, .init(identifier: "fr"))
}
#Preview("Glossary Index — EN") {
    NavigationStack {
        GlossaryIndexView()
    }
    .environment(\.locale, .init(identifier: "en"))
}
#endif
