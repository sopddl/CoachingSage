// Views/Components/SessionWhyPanel.swift
// Story 3.18 Phase 2 — panneau pédagogique "Pourquoi cette séance ?"
// expandable. Texte généré par SessionWhyExplainer (heuristique locale, 100%
// offline). Rendu via GlossaryRichText pour auto-détecter les termes
// glossaire dans la justification.
import SwiftUI
import TemplateModel

struct SessionWhyPanel: View {
    let session: AdaptedSession
    let week: AdaptedWeek
    let program: AdaptedProgram

    @State private var isExpanded: Bool = false

    /// Clé i18n de la justification, calculée une fois par cycle de body. Nil
    /// = pas de panel (séance .rest ou type non couvert).
    private var explanationKey: String? {
        SessionWhyExplainer.explanationKey(session: session, week: week, program: program)
    }

    var body: some View {
        if let key = explanationKey {
            DisclosureGroup(isExpanded: $isExpanded) {
                // Texte rendu via GlossaryRichText pour rendre tappables les
                // termes techniques de la justification.
                GlossaryRichText(
                    text: localizedExplanation(key: key),
                    font: .footnote,
                    foreground: .primary
                )
                .padding(.top, 8)
                .padding(.bottom, 4)
            } label: {
                // Story 3.32 (AC6) — phrase d'intention sur 1 ligne, visible en
                // permanence : c'est la chose qui rassure. Tap = déplie le détail.
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundStyle(.yellow)
                        .font(.callout)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("coaching.session.why.title")
                            .font(.callout.bold())
                            .foregroundStyle(.primary)
                        Text(verbatim: localizedExplanation(key: key))
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                }
                .accessibilityElement(children: .combine)
                .accessibilityHint(Text("coaching.session.why.expand.hint"))
            }
            .padding(12)
            .background(Color(uiColor: .secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .accessibilityIdentifier("coaching.session.why.panel")
            .animation(.spring(response: 0.35, dampingFraction: 0.85), value: isExpanded)
        }
    }

    /// Résout la string localisée pour la key, en passant par le bundle
    /// principal. On utilise `String(localized:)` avec un `LocalizationValue`
    /// runtime pour que `LanguageManager` (override AppleLanguages) prenne effet
    /// — c'est le pattern Sage standard (cf memo TS 2026-05-18).
    private func localizedExplanation(key: String) -> String {
        String(localized: String.LocalizationValue(key), bundle: .main)
    }
}

#if DEBUG
#Preview("Why — interval early") {
    SessionWhyPanel(
        session: AdaptedSession(
            day: 1, name: "Fractionné court", durationMinutes: 45,
            type: .interval,
            warmup: nil,
            exercises: [
                AdaptedExercise(name: "8×30/30", originalName: "8×30/30",
                                duration: "30/30",
                                targetZone: "Daniels-I")
            ],
            cooldown: nil
        ),
        week: AdaptedProgramPreviewFixtures.sampleWeek(1, theme: "Découverte"),
        program: AdaptedProgramPreviewFixtures.happyPath
    )
    .padding()
}

#Preview("Why — endurance late") {
    SessionWhyPanel(
        session: AdaptedProgramPreviewFixtures.sampleEnduranceSession(day: 1, name: "Footing facile"),
        week: AdaptedWeek(weekNumber: 7, theme: "Affûtage", goal: "—", sessions: []),
        program: AdaptedProgram(
            templateId: "fx", sport: .running, level: .beginner,
            appliedAt: Date(),
            weeks: (1...8).map { AdaptedProgramPreviewFixtures.sampleWeek($0, theme: "—") },
            appliedRules: [], requiresAIAssist: false,
            durationMode: .deadlineEstimated, targetDate: Date().addingTimeInterval(56*86400)
        )
    )
    .padding()
}

#Preview("Why — rest (no panel)") {
    SessionWhyPanel(
        session: AdaptedSession(
            day: 7, name: "Repos", durationMinutes: 0,
            type: .rest, warmup: nil, exercises: [], cooldown: nil
        ),
        week: AdaptedProgramPreviewFixtures.sampleWeek(2, theme: "—"),
        program: AdaptedProgramPreviewFixtures.happyPath
    )
    .padding()
}
#endif
