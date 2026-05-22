// Views/Screens/Coaching/SessionDetailView.swift
// Détail riche d'une AdaptedSession (push depuis AdaptedProgramView master) :
// header (nom + position S/J + durée + thème de la semaine), warmup, exercices
// avec sets/reps/duration/rest/zone/notes/substitutions, cooldown, adaptations
// filtrées sur cette séance, footer médical EU MDR.
import SwiftUI
import TemplateModel

struct SessionDetailView: View {
    let session: AdaptedSession
    let week: AdaptedWeek
    let program: AdaptedProgram
    /// Phase B.6 — true si cette session a été mutée par la regen S+1 cette
    /// semaine (durée modifiée par `WeeklyRegenApplicationService`). Affiche
    /// un bandeau header explicatif. Default false côté preview.
    var isModifiedByRegen: Bool = false

    /// Phase A boucle complétion — id du `AdaptedProgramRecord` persistant.
    /// Nil sur le hot path post-adapt (programme tout frais) et sur Previews.
    /// Quand non-nil, expose le bouton "Marquer comme terminée".
    var recordId: UUID? = nil

    @Environment(\.appDependencies) private var deps
    @State private var completionVM: SessionCompletionViewModel?
    @State private var showCompleteSheet: Bool = false
    /// Story 3.17 Phase 1 — tooltip 1ère ouverture découvrabilité glossaire.
    @State private var showDiscoveryTooltip: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                SessionHeroHeader(session: session, week: week, program: program)

                SessionWhyPanel(session: session, week: week, program: program)

                if isModifiedByRegen {
                    regenAdjustedBanner
                }

                SessionTimelineView(session: session, sportColor: sessionSportColor)

                if let vm = completionVM {
                    completionSection(vm: vm)
                }

                medicalReminderFooter
            }
            .padding()
        }
        .navigationTitle(Text(verbatim: session.name))
        .navigationBarTitleDisplayMode(.inline)
        .glossaryDiscoveryTooltip(isPresented: $showDiscoveryTooltip)
        .task {
            await bootstrapCompletionVMIfNeeded()
            await presentDiscoveryTooltipIfNeeded()
        }
        .sheet(isPresented: $showCompleteSheet) {
            if let vm = completionVM {
                SessionCompleteSheet(vm: vm, plannedDurationMinutes: session.durationMinutes)
            }
        }
    }

    private func bootstrapCompletionVMIfNeeded() async {
        guard let recordId, let deps, completionVM == nil else { return }
        let vm = SessionCompletionViewModel(
            recordId: recordId,
            weekNumber: week.weekNumber,
            day: session.day,
            repository: deps.adaptedProgramRepository
        )
        completionVM = vm
        await vm.load()
    }

    /// Story 3.17 — présente le tooltip de découvrabilité glossaire à la 1ère
    /// ouverture. Délai 0.6s pour laisser la vue se stabiliser, puis fade-in
    /// via animation du modifier. Skip si déjà vu OU en UI testing.
    private func presentDiscoveryTooltipIfNeeded() async {
        guard GlossaryDiscoveryTooltip.shouldPresent() else { return }
        try? await Task.sleep(nanoseconds: 600_000_000)
        guard !Task.isCancelled else { return }
        showDiscoveryTooltip = true
    }

    // MARK: - Completion section (Phase A)

    @ViewBuilder
    private func completionSection(vm: SessionCompletionViewModel) -> some View {
        if let record = vm.completion {
            completedCard(record: record, vm: vm)
        } else {
            Button {
                showCompleteSheet = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                    Text("coaching.session.complete.button")
                        .font(.callout.bold())
                    Spacer()
                }
                .padding(.vertical, 14)
                .padding(.horizontal, 16)
                .foregroundStyle(.white)
                .background(Color.coachingPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .accessibilityIdentifier("coaching.session.complete.button")
        }
    }

    private func completedCard(record: SessionCompletionRecord, vm: SessionCompletionViewModel) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(.green)
                Text("coaching.session.complete.completedAt \(Self.completionDateFormatter.string(from: record.completedAt))")
                    .font(.subheadline.bold())
                Spacer()
            }
            if let duration = record.actualDurationMinutes {
                Text("coaching.session.complete.duration.recorded \(duration)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            if let rpe = record.perceivedEffort {
                Text("coaching.session.complete.rpe.recorded \(rpe)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            if let notes = record.notes, !notes.isEmpty {
                Text(verbatim: notes)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 2)
            }
            HStack(spacing: 12) {
                Button("coaching.session.complete.modify") {
                    showCompleteSheet = true
                }
                .buttonStyle(.bordered)
                Button("coaching.session.complete.undo", role: .destructive) {
                    Task { await vm.clear() }
                }
                .buttonStyle(.bordered)
            }
            .padding(.top, 4)
        }
        .padding(12)
        .background(Color.green.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .accessibilityIdentifier("coaching.session.complete.completedCard")
    }

    private static let completionDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()

    // MARK: - Regen adjusted banner (Phase B.6)

    /// Bandeau header affiché quand la session a été ajustée par la regen S+1
    /// de la semaine courante. Tint orange cohérent avec le marker sparkles
    /// dans `AdaptedProgramView`. i18n keys remplies en B.7.
    private var regenAdjustedBanner: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "sparkles")
                .foregroundStyle(.orange)
                .font(.callout.weight(.semibold))
            VStack(alignment: .leading, spacing: 2) {
                Text("coaching.adapter.session.regen.banner.title")
                    .font(.subheadline.bold())
                Text("coaching.adapter.session.regen.banner.body")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(Color.orange.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("coaching.adapter.session.regen.banner")
    }

    // MARK: - Sport color helper

    /// Couleur sport effective pour la séance (utilisée par la timeline
    /// pour tinter les pastilles exercices). Triathlon → sub-sport inféré
    /// par `SessionSportInference`.
    private var sessionSportColor: Color {
        let effective = SessionSportInference.sportCode(
            forSessionName: session.name,
            programSportCode: program.sport.appSportCode
        )
        return Color.coachingSport(forCode: effective)
    }

    // MARK: - Medical footer

    private var medicalReminderFooter: some View {
        Text("coaching.adapter.medicalReminder.footer")
            .font(.caption2)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.leading)
            .padding(.top, 4)
    }
}

// MARK: - Preview

#if DEBUG
#Preview("SessionDetail — endurance") {
    NavigationStack {
        SessionDetailView(
            session: AdaptedProgramPreviewFixtures.sampleEnduranceSession(day: 1, name: "Footing facile"),
            week: AdaptedProgramPreviewFixtures.sampleWeek(1, theme: "Découverte"),
            program: AdaptedProgramPreviewFixtures.happyPath
        )
    }
}

#Preview("SessionDetail — intervals avec substitution") {
    NavigationStack {
        SessionDetailView(
            session: AdaptedSession(
                day: 1, name: "Plyo intervals", durationMinutes: 30,
                type: .interval,
                warmup: "10 min footing très lent + 4 lignes droites",
                exercises: [
                    AdaptedExercise(
                        name: "Marche nordique 20 min",
                        originalName: "Bondissements 6×30s",
                        duration: "20 min",
                        notes: "Bâtons en cadence, allure soutenue mais conversation possible.",
                        targetZone: "Daniels-E",
                        volumeAxis: .duration,
                        wasSubstituted: true,
                        substitutionReason: "constraint:knee-injury"
                    )
                ],
                cooldown: "5 min marche + étirements doux"
            ),
            week: AdaptedWeek(weekNumber: 1, theme: "Découverte", goal: "Adapter aux contraintes", sessions: []),
            program: AdaptedProgramPreviewFixtures.kneeInjury
        )
    }
}

#Preview("SessionDetail — strength") {
    NavigationStack {
        SessionDetailView(
            session: AdaptedProgramPreviewFixtures.sampleStrengthSession(day: 5),
            week: AdaptedProgramPreviewFixtures.sampleWeek(1, theme: "Découverte"),
            program: AdaptedProgramPreviewFixtures.happyPath
        )
    }
}
#endif
