// Views/Screens/Profile/SportProfileView.swift
// Story 3.16 Phase 2.D2 — écran profil natation poussé depuis le bloc Natation
// de l'onglet Progrès. V1 : records + tendances + répartition styles sur la
// fenêtre HK 1 an (dérivé à la volée, pas de persistance).
//
// Garde-fou produit : la "meilleure allure" est INDICATIVE (caveat affiché),
// jamais présentée comme une vitesse de référence / CSS.
import SwiftUI

struct SportProfileView: View {
    @Environment(\.appDependencies) private var deps
    @Environment(\.locale) private var locale
    @State private var viewModel: SwimProfileViewModel?

    var body: some View {
        content
            .background(Color.coachingBackground.ignoresSafeArea())
            .navigationTitle(Text("progress.swim.title"))
            .navigationBarTitleDisplayMode(.inline)
            .task {
                if viewModel == nil, let deps {
                    viewModel = SwimProfileViewModel(healthKit: deps.healthKitService)
                }
                await viewModel?.load()
            }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel?.state ?? .idle {
        case .idle, .loading:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .empty:
            emptyView
        case .loaded(let summary):
            loadedView(summary: summary, trend: viewModel?.trend)
        }
    }

    private var emptyView: some View {
        VStack(spacing: 12) {
            Image(systemName: "figure.pool.swim")
                .font(.system(size: 40))
                .foregroundStyle(Color.coachingTextSecondary)
            Text("swim.profile.empty")
                .font(.coachingBody)
                .foregroundStyle(Color.coachingTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func loadedView(summary: SwimSummary, trend: SwimTrend?) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                recordsCard(summary)
                if let trend, trend.paceDeltaSecondsPer100m != nil || trend.swolfDelta != nil {
                    trendsCard(trend)
                }
                if !summary.strokeDistribution.isEmpty {
                    stylesCard(summary)
                }
                if !summary.sessions.isEmpty {
                    sessionsCard(summary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
    }

    // MARK: - Records

    private func recordsCard(_ summary: SwimSummary) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("swim.profile.records")
            Text("swim.profile.records_window")
                .font(.caption2)
                .foregroundStyle(Color.coachingTextSecondary)
            HStack(spacing: 0) {
                statColumn(
                    value: summary.bestPaceSecondsPer100m.map(formatPace) ?? "—",
                    label: "swim.profile.best_pace"
                )
                cardDivider
                statColumn(
                    value: formatDistance(summary.longestSessionDistanceMeters),
                    label: "swim.profile.longest"
                )
                cardDivider
                statColumn(
                    value: formatDistance(summary.totalDistanceMeters),
                    label: "progress.swim.distance"
                )
            }
            Text("swim.profile.pace_caveat")
                .font(.caption2)
                .foregroundStyle(Color.coachingTextSecondary)
        }
        .modifier(CardBackground())
    }

    // MARK: - Tendances

    private func trendsCard(_ trend: SwimTrend) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("swim.profile.trends")
            if let pace = trend.paceDeltaSecondsPer100m {
                trendRowBase(label: Text("swim.profile.trend_pace"), delta: pace, unit: "s/100m")
            }
            if let swolf = trend.swolfDelta {
                trendRowBase(label: Text(verbatim: "SWOLF"), delta: swolf, unit: "")
            }
            Text("swim.profile.trend_window")
                .font(.caption2)
                .foregroundStyle(Color.coachingTextSecondary)
        }
        .modifier(CardBackground())
    }

    // labelKey via clé i18n.
    private func trendRow(labelKey: LocalizedStringKey, delta: Double, unit: String) -> some View {
        trendRowBase(label: Text(labelKey), delta: delta, unit: unit)
    }
    // labelKey via texte brut (ex "SWOLF").
    private func trendRow(labelKey: String, deltaText: String, delta: Double, unit: String) -> some View {
        trendRowBase(label: Text(verbatim: deltaText), delta: delta, unit: unit)
    }

    private func trendRowBase(label: Text, delta: Double, unit: String) -> some View {
        // delta < 0 = amélioration (plus rapide / SWOLF plus bas).
        let improving = delta < -0.5
        let worsening = delta > 0.5
        let color: Color = improving ? .coachingSuccess : (worsening ? .coachingError : .coachingTextSecondary)
        let symbol = improving ? "arrow.down.right" : (worsening ? "arrow.up.right" : "minus")
        let sign = delta > 0 ? "+" : ""
        return HStack {
            label
                .font(.subheadline)
                .foregroundStyle(Color.coachingTextPrimary)
            Spacer()
            Image(systemName: symbol)
                .font(.caption.bold())
                .foregroundStyle(color)
            Text(verbatim: "\(sign)\(formatDelta(delta)) \(unit)".trimmingCharacters(in: .whitespaces))
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(color)
        }
    }

    // MARK: - Styles

    private func stylesCard(_ summary: SwimSummary) -> some View {
        let total = max(1, summary.strokeDistribution.values.reduce(0, +))
        let rows = summary.strokeDistribution
            .filter { $0.key.localizationKey != nil }
            .sorted { $0.value > $1.value }
        return VStack(alignment: .leading, spacing: 12) {
            sectionTitle("swim.profile.styles")
            ForEach(rows, id: \.key.rawValue) { style, count in
                HStack {
                    if let key = style.localizationKey {
                        Text(LocalizedStringKey(key))
                            .font(.subheadline)
                            .foregroundStyle(Color.coachingTextPrimary)
                    }
                    Spacer()
                    Text(verbatim: "\(Int((Double(count) / Double(total) * 100).rounded())) %")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.coachingTextSecondary)
                }
            }
        }
        .modifier(CardBackground())
    }

    // MARK: - Séances

    private func sessionsCard(_ summary: SwimSummary) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("swim.profile.sessions_title")
            VStack(spacing: 12) {
                ForEach(summary.sessions.prefix(8)) { session in
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(relativeDate(session.date))
                                .font(.subheadline)
                                .foregroundStyle(Color.coachingTextPrimary)
                            Text(formatDistance(session.totalDistanceMeters))
                                .font(.caption2)
                                .foregroundStyle(Color.coachingTextSecondary)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            if let pace = session.avgPaceSecondsPer100m {
                                Text(verbatim: "\(formatPace(pace))/100m")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundStyle(Color.coachingTextPrimary)
                            }
                            if let swolf = session.avgSwolf {
                                Text(verbatim: "SWOLF \(swolf)")
                                    .font(.caption2)
                                    .foregroundStyle(Color.coachingTextSecondary)
                            }
                        }
                    }
                }
            }
        }
        .modifier(CardBackground())
    }

    // MARK: - Sous-composants

    private func sectionTitle(_ key: LocalizedStringKey) -> some View {
        Text(key)
            .font(.headline)
            .foregroundStyle(Color.coachingTextPrimary)
    }

    private func statColumn(value: String, label: LocalizedStringKey) -> some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(Color.coachingRecord)
            Text(label)
                .font(.caption2)
                .foregroundStyle(Color.coachingTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    private var cardDivider: some View {
        Rectangle()
            .fill(Color.coachingTextSecondary.opacity(0.15))
            .frame(width: 1, height: 36)
    }

    // MARK: - Formatters

    private func formatPace(_ secondsPer100m: Double) -> String {
        let total = Int(secondsPer100m.rounded())
        return String(format: "%d:%02d", total / 60, total % 60)
    }

    private func formatDelta(_ value: Double) -> String {
        // Pace en secondes → entier ; SWOLF → entier. Magnitude affichée.
        String(format: "%.0f", abs(value))
    }

    private func formatDistance(_ meters: Double?) -> String {
        guard let meters, meters > 0 else { return "—" }
        return meters >= 1000 ? String(format: "%.1f km", meters / 1000) : String(format: "%.0f m", meters)
    }

    private func relativeDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        // Suit la langue in-app (LanguageManager → \.locale), pas la locale
        // système du device — sinon « -2 j / -1 sem. » en FR alors que l'app
        // est en EN (cf memo_locale_strict_string_localized_pattern).
        formatter.locale = locale
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

/// Fond de carte commun aux sections de l'écran.
private struct CardBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.vertical, 14)
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.coachingEarth.opacity(0.06), radius: 6, x: 0, y: 2)
            )
    }
}
