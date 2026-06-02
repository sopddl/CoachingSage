// Views/Components/SessionOverviewList.swift
// Story 3.32 (AC7) — aperçu scannable des blocs d'une séance : un index compact
// (échauffement · exos numérotés · récup) avec, par ligne, le nom + la
// métrique-clé. Tap sur une ligne → ancre/scrolle vers le bloc dans la timeline
// détaillée en dessous (via `ScrollViewReader` + `SessionStepAnchor`). Ce n'est
// PAS une duplication de la timeline riche : juste un sommaire.
import SwiftUI
import TemplateModel

/// Namespace des identifiants d'ancrage partagés entre l'aperçu (index) et la
/// timeline détaillée (cibles de scroll). L'ordre de référence est : warmup (si
/// présent) → exos → cooldown (si présent) — identique des deux côtés.
enum SessionStepAnchor {
    static func id(_ index: Int) -> String { "coaching.session.step.\(index)" }
}

struct SessionOverviewList: View {
    let session: AdaptedSession
    /// Appelé au tap d'une ligne avec l'index d'ancrage (= offset dans l'ordre
    /// de référence). Le parent fait `proxy.scrollTo(SessionStepAnchor.id(index))`.
    var onSelect: (Int) -> Void

    private var rows: [SessionOverviewList.Row] { Self.rows(for: session) }

    var body: some View {
        if !rows.isEmpty {
            VStack(alignment: .leading, spacing: 0) {
                Text("coaching.session.overview.title")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .padding(.bottom, 6)

                ForEach(rows, id: \.anchorIndex) { row in
                    Button {
                        onSelect(row.anchorIndex)
                    } label: {
                        rowLabel(row)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("coaching.session.overview.row.\(row.anchorIndex)")
                }
            }
            .padding(12)
            .background(Color(uiColor: .secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .accessibilityIdentifier("coaching.session.overview")
        }
    }

    @ViewBuilder
    private func rowLabel(_ row: Row) -> some View {
        HStack(spacing: 10) {
            bullet(for: row.kind)
                .frame(width: 22)
            phaseTitle(for: row)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .lineLimit(1)
            Spacer(minLength: 8)
            if let metric = row.metric {
                Text(verbatim: metric)
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Image(systemName: "chevron.right")
                .font(.caption2.bold())
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 7)
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private func bullet(for kind: Kind) -> some View {
        switch kind {
        case .warmup:
            Image(systemName: "flame.fill").font(.caption2.bold()).foregroundStyle(.orange)
        case .cooldown:
            Image(systemName: "snowflake").font(.caption2.bold()).foregroundStyle(.blue)
        case .exercise(let number):
            Text(verbatim: "\(number)")
                .font(.caption.bold())
                .foregroundStyle(Color.coachingPrimary)
        }
    }

    @ViewBuilder
    private func phaseTitle(for row: Row) -> some View {
        switch row.kind {
        case .warmup:   Text("coaching.adapter.session.warmup")
        case .cooldown: Text("coaching.adapter.session.cooldown")
        case .exercise: Text(verbatim: row.title)
        }
    }

    // MARK: - Pure model (testable)

    enum Kind: Equatable {
        case warmup
        case exercise(number: Int)
        case cooldown
    }

    struct Row: Equatable {
        /// Index dans l'ordre de référence (= cible d'ancrage timeline).
        let anchorIndex: Int
        let kind: Kind
        /// Nom affiché (exos seulement ; warmup/cooldown = label localisé en vue).
        let title: String
        /// Métrique-clé courte ("4×8", "20 min", "2 min"), nil si rien d'exploitable.
        let metric: String?
    }

    /// Construit l'aperçu dans l'ordre de référence warmup → exos → cooldown.
    /// Pure & déterministe → testable (AC11).
    static func rows(for session: AdaptedSession) -> [Row] {
        var result: [Row] = []
        var index = 0
        if let w = session.warmup, !w.isEmpty {
            result.append(Row(anchorIndex: index, kind: .warmup, title: "", metric: leadingDuration(in: w)))
            index += 1
        }
        var exNumber = 0
        for ex in session.exercises {
            exNumber += 1
            result.append(Row(
                anchorIndex: index,
                kind: .exercise(number: exNumber),
                title: ex.displayName,
                metric: compactMetric(for: ex)
            ))
            index += 1
        }
        if let c = session.cooldown, !c.isEmpty {
            result.append(Row(anchorIndex: index, kind: .cooldown, title: "", metric: leadingDuration(in: c)))
        }
        return result
    }

    /// Métrique-clé courte d'un exo : "sets×reps", sinon durée, sinon reps.
    static func compactMetric(for ex: AdaptedExercise) -> String? {
        if let s = ex.sets, let r = ex.reps?.trimmingCharacters(in: .whitespaces), !r.isEmpty {
            return "\(s)×\(r)"
        }
        if let d = ex.duration?.trimmingCharacters(in: .whitespaces), !d.isEmpty {
            return d
        }
        if let r = ex.reps?.trimmingCharacters(in: .whitespaces), !r.isEmpty {
            return r
        }
        return nil
    }

    /// Extrait une durée de tête d'un texte libre ("10 min footing…" → "10 min").
    static func leadingDuration(in text: String) -> String? {
        let lower = text.lowercased()
        // cherche premier nombre suivi (proche) d'une unité min/mn/s/sec
        let scalars = Array(lower)
        var i = 0
        while i < scalars.count {
            if scalars[i].isNumber {
                var j = i
                var number = ""
                while j < scalars.count, scalars[j].isNumber { number.append(scalars[j]); j += 1 }
                // skip espaces
                while j < scalars.count, scalars[j] == " " { j += 1 }
                let rest = String(scalars[j...])
                if rest.hasPrefix("min") || rest.hasPrefix("mn") { return "\(number) min" }
                if rest.hasPrefix("sec") || rest.hasPrefix("s") { return "\(number) s" }
                i = j
            } else {
                i += 1
            }
        }
        return nil
    }
}

#if DEBUG
#Preview("Overview — strength") {
    SessionOverviewList(
        session: AdaptedSession(
            day: 1, name: "Full body", durationMinutes: 50, type: .strength,
            warmup: "10 min mobilité articulaire",
            exercises: [
                AdaptedExercise(name: "Goblet squat", originalName: "Goblet squat", sets: 4, reps: "8"),
                AdaptedExercise(name: "Pompes", originalName: "Pompes", sets: 3, reps: "12"),
                AdaptedExercise(name: "Gainage", originalName: "Gainage", duration: "2 min")
            ],
            cooldown: "5 min étirements"
        ),
        onSelect: { _ in }
    )
    .padding()
}
#endif
