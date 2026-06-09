// Views/Components/ExerciseHowToDisclosure.swift
// Story 3.24b — disclosure "Comment l'exécuter ?" expandable dans la card exo.
//
// Au tap : expansion + fetch async via `ExerciseExplanationServiceProtocol`.
// Cas :
//  - Seed catalogue hit (top 10 exos universels) → liste steps + chips équipement
//    + erreur courante (optionnel). Affichage immédiat, zéro latence perçue.
//  - Cache disque hit → idem (V2, après IA câblée).
//  - Pas de seed et pas de cache → spinner pendant tentative IA puis fallback
//    sur `SessionTipBubble` (tip pattern catalogue) si fetch indisponible.
//
// Fallback gracieux = zéro régression UX par rapport à Story 3.19. L'user voit
// au pire l'ancien tip pattern court — mais sur les top 10 exos il a maintenant
// les 3-5 steps précis.
import SwiftUI

struct ExerciseHowToDisclosure: View {
    let exercise: AdaptedExercise
    /// LocalizedStringKey du tip pattern (`SessionTipCatalog`) utilisé en fallback
    /// gracieux si le service n'a ni seed ni cache pour cet exo.
    let fallbackTip: LocalizedStringKey?
    let service: any ExerciseExplanationServiceProtocol

    @Environment(\.languageManager) private var languageManager

    @State private var isExpanded: Bool
    @State private var explanation: ExerciseExplanation?
    @State private var loading: Bool = false
    @State private var failed: Bool = false

    init(
        exercise: AdaptedExercise,
        fallbackTip: LocalizedStringKey?,
        initiallyExpanded: Bool = false,
        service: any ExerciseExplanationServiceProtocol = DefaultExerciseExplanationService()
    ) {
        self.exercise = exercise
        self.fallbackTip = fallbackTip
        self.service = service
        // POC yoga (Sophie 2026-06-06) : sur le yoga, la description « comment
        // l'exécuter » est dépliée d'emblée (lire la posture = le cœur de la
        // pratique sans coach). Les autres sports restent repliés (compacité).
        _isExpanded = State(initialValue: initiallyExpanded)
    }

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            contentView
                .padding(.top, 6)
        } label: {
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.coachingRecord, Color.coachingRecord.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    Text(verbatim: "L")
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                }
                .frame(width: 24, height: 24)
                .accessibilityHidden(true)

                Text("coaching.exercise.howto.disclose")
                    .font(.footnote.bold())
                    .foregroundStyle(.primary)
            }
        }
        .tint(.coachingPrimary)
        .padding(10)
        .background(Color(uiColor: .tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .accessibilityIdentifier("coaching.exercise.howto.disclosure")
        .onChange(of: isExpanded) { _, newValue in
            guard newValue, explanation == nil, !loading, !failed else { return }
            Task { await loadExplanation() }
        }
        .task {
            // Déplié d'emblée (yoga) : `onChange` ne se déclenche pas → on amorce
            // le chargement de la description à l'apparition.
            guard isExpanded, explanation == nil, !loading, !failed else { return }
            await loadExplanation()
        }
    }

    @ViewBuilder
    private var contentView: some View {
        if let explanation {
            stepsView(explanation)
        } else if loading {
            HStack(spacing: 8) {
                ProgressView()
                Text("coaching.exercise.howto.loading")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        } else if failed, let fallbackTip {
            // Fallback gracieux : tip pattern Story 3.19.
            SessionTipBubble(tip: fallbackTip)
        } else if failed {
            // Pas de tip fallback non plus : on remet le bouton à 0 silencieusement.
            EmptyView()
        }
    }

    @ViewBuilder
    private func stepsView(_ explanation: ExerciseExplanation) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            // Steps numérotées
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(explanation.steps.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: 8) {
                        Text(verbatim: "\(index + 1).")
                            .font(.footnote.bold())
                            .foregroundStyle(Color.coachingPrimary)
                            .frame(width: 20, alignment: .leading)
                        // Pédagogie : le jargon des steps (FTP, Daniels-T, CSS,
                        // EN1, Ujjayi…) devient tappable via glossaire.
                        GlossaryRichText(text: step, font: .footnote, foreground: .primary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }

            // Équipement (chips)
            if !explanation.equipment.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("coaching.exercise.howto.equipment")
                        .font(.caption2.bold())
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                    EquipmentChipsFlow(items: explanation.equipment)
                }
                .padding(.top, 2)
            }

            // Erreur courante
            if let mistake = explanation.commonMistakes, !mistake.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("coaching.exercise.howto.mistake")
                        .font(.caption2.bold())
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                    GlossaryRichText(text: mistake, font: .footnote, foreground: .primary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.top, 2)
            }
        }
    }

    private func loadExplanation() async {
        loading = true
        defer { loading = false }
        let lang = languageManager.currentLanguage.rawValue
        do {
            let result = try await service.explanation(for: exercise, language: lang)
            explanation = result
        } catch {
            failed = true
        }
    }
}

// MARK: - Equipment chips flow (wrap simple)

private struct EquipmentChipsFlow: View {
    let items: [String]

    var body: some View {
        HStack(alignment: .top, spacing: 4) {
            // Flow wrap minimaliste : on aligne à gauche, lineLimit nil.
            // Pour V1 on accepte que tous les chips soient sur une ou deux lignes
            // en pratique (1 à 3 items).
            ForEach(items, id: \.self) { item in
                Text(verbatim: item)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(uiColor: .secondarySystemBackground))
                    .clipShape(Capsule())
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#if DEBUG
#Preview("Howto — bench press FR") {
    ExerciseHowToDisclosure(
        exercise: AdaptedExercise(name: "Bench press", originalName: "Bench press"),
        fallbackTip: "coaching.tip.push.horizontal"
    )
    .padding()
}

#Preview("Howto — exo non seed (fallback)") {
    ExerciseHowToDisclosure(
        exercise: AdaptedExercise(name: "Mouvement inconnu xyz", originalName: "Mouvement inconnu xyz"),
        fallbackTip: "coaching.tip.squat"
    )
    .padding()
}
#endif
