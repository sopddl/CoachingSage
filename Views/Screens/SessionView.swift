// Views/Screens/SessionView.swift
// Story 3.2 — entry point « Demander un programme [sport] » sur l'onglet Séance.
// Hot path : tap capsule → si profile sport existe, push direct AdaptedProgramView ;
// sinon, ouvre le questionnaire ; à la fin du questionnaire, hand-off immédiat
// (sélection template + adaptation algo) puis push AdaptedProgramView.
//
// 100% local, 0 réseau, 0 token côté hot path.
// V1 : seul Running a un questionnaire (RunningQuestionnaire). Les 9 autres = capsule disabled + badge "Bientôt".
import SwiftUI

struct SessionView: View {
    @Environment(\.appDependencies) private var deps

    @State private var coachingProfile: CoachingProfile?
    @State private var loadingProfile: Bool = true
    @State private var library: ProgramTemplateLibrary?
    @State private var libraryLoadFailed: Bool = false
    @State private var sheetSelection: SheetSelection?
    @State private var adaptedRoute: AdaptedProgramRoute?
    @State private var presentationError: String?

    private let adapterService = ProgramAdapterService()

    enum SheetSelection: Identifiable {
        case questionnaire(sportCode: String)

        var id: String {
            switch self {
            case .questionnaire(let s): return "questionnaire_\(s)"
            }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("session.requestProgram.title")
                        .font(.title2.bold())
                        .foregroundStyle(Color.coachingTextPrimary)
                        .padding(.top, 8)

                    if loadingProfile {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                    } else if let profile = coachingProfile {
                        sportsList(activeSports: profile.activeSports)
                    } else {
                        Text("session.requestProgram.noProfile")
                            .font(.body)
                            .foregroundStyle(Color.coachingTextSecondary)
                            .padding(.vertical, 16)
                    }

                    if let presentationError {
                        Text(verbatim: presentationError)
                            .font(.footnote)
                            .foregroundStyle(Color.coachingError)
                            .padding(.vertical, 8)
                    }
                }
                .padding(.horizontal, 16)
            }
            .background(Color.coachingBackground.ignoresSafeArea())
            .navigationTitle(Text("tab.session"))
            .navigationBarTitleDisplayMode(.large)
            .task {
                await reloadProfile()
                await loadLibraryIfNeeded()
            }
            .onAppear {
                // Refetch silencieux à chaque retour pour cohérence multi-device (review P1-1).
                Task { await reloadProfile(silent: true) }
            }
            .navigationDestination(item: $adaptedRoute) { route in
                AdaptedProgramView(program: route.program)
            }
        }
        .sheet(item: $sheetSelection) { selection in
            sheet(for: selection)
        }
    }

    // MARK: - Sports list

    @ViewBuilder
    private func sportsList(activeSports: [String]) -> some View {
        if activeSports.isEmpty {
            Text("session.requestProgram.noActiveSports")
                .font(.body)
                .foregroundStyle(Color.coachingTextSecondary)
                .padding(.vertical, 16)
        } else {
            VStack(spacing: 10) {
                ForEach(activeSports, id: \.self) { code in
                    SportCapsule(
                        sportCode: code,
                        isSupported: questionnaireFor(sportCode: code) != nil,
                        onTap: {
                            Task { await handleTap(sportCode: code) }
                        }
                    )
                }
            }
        }
    }

    // MARK: - Tap handler

    private func handleTap(sportCode: String) async {
        guard let deps else { return }
        guard questionnaireFor(sportCode: sportCode) != nil else { return }
        let existing = try? await deps.coachingSportProfileRepository.fetchProfile(for: sportCode)
        if let existing {
            await presentAdaptedProgram(for: existing)
        } else {
            sheetSelection = SheetSelection.questionnaire(sportCode: sportCode)
        }
    }

    // MARK: - Sheet routing

    @ViewBuilder
    private func sheet(for selection: SheetSelection) -> some View {
        switch selection {
        case .questionnaire(let code):
            questionnaireSheet(sportCode: code)
        }
    }

    @ViewBuilder
    private func questionnaireSheet(sportCode: String) -> some View {
        if let deps, let questionnaire = questionnaireFor(sportCode: sportCode) {
            let vm = SportQuestionnaireViewModel(
                questionnaire: questionnaire,
                repository: deps.coachingSportProfileRepository,
                authService: deps.authService
            )
            SportQuestionnaireView(
                viewModel: vm,
                requiresMedicalClearance: coachingProfile?.requiresMedicalClearance ?? false,
                healthKitService: deps.healthKitService,
                onCompleted: { sportProfile in
                    sheetSelection = nil
                    Task {
                        await reloadProfile(silent: true)
                        await presentAdaptedProgram(for: sportProfile)
                    }
                }
            )
        } else {
            Text("session.requestProgram.unsupportedSport")
        }
    }

    // MARK: - Hot path : selector → adapter → push

    private func presentAdaptedProgram(for sportProfile: CoachingSportProfile) async {
        await loadLibraryIfNeeded()
        guard let library else {
            presentationError = String(localized: "session.adapter.libraryUnavailable")
            return
        }
        guard let coachingProfile else {
            // CoachingProfile nécessaire pour MedicalClearanceRule. Pas de profile → pas de programme.
            presentationError = String(localized: "session.adapter.profileMissing")
            return
        }
        presentationError = nil

        let selector = ProgramTemplateSelector(library: library)
        let template = selector.select(profile: sportProfile)
        let adapted = adapterService.adapt(
            template: template,
            sportProfile: sportProfile,
            coachingProfile: coachingProfile
        )
        adaptedRoute = AdaptedProgramRoute(program: adapted)
    }

    // MARK: - Library loading

    private func loadLibraryIfNeeded() async {
        guard library == nil, !libraryLoadFailed else { return }
        do {
            library = try await ProgramTemplateLibrary.bundled()
        } catch {
            libraryLoadFailed = true
            presentationError = String(localized: "session.adapter.libraryUnavailable")
        }
    }

    // MARK: - Dispatch sport → questionnaire

    /// V1 : seul Running est livré. Les 9 autres sports retournent nil → capsule disabled (cf. SportCapsule).
    private func questionnaireFor(sportCode: String) -> SportQuestionnaire? {
        switch sportCode {
        case "running": return RunningQuestionnaire()
        default: return nil
        }
    }

    // MARK: - Profile loading

    private func reloadProfile(silent: Bool = false) async {
        guard let deps else {
            if !silent { loadingProfile = false }
            return
        }
        if !silent { loadingProfile = true }
        coachingProfile = try? await deps.coachingProfileRepository.fetchCurrentProfile()
        loadingProfile = false
    }
}

// MARK: - AdaptedProgramRoute (wrapper Hashable pour navigationDestination)

private struct AdaptedProgramRoute: Hashable {
    let id: UUID = UUID()
    let program: AdaptedProgram

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: AdaptedProgramRoute, rhs: AdaptedProgramRoute) -> Bool { lhs.id == rhs.id }
}

// MARK: - SportCapsule

private struct SportCapsule: View {
    let sportCode: String
    let isSupported: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: sfSymbol(for: sportCode))
                    .font(.title3)
                    .foregroundStyle(isSupported ? Color.coachingPrimary : Color.coachingDisabled)
                    .frame(width: 28)

                Text(SportCapsule.requestProgramKey(for: sportCode))
                    .font(.body)
                    .foregroundStyle(isSupported ? Color.coachingTextPrimary : Color.coachingDisabled)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if isSupported {
                    Image(systemName: "chevron.right")
                        .font(.footnote)
                        .foregroundStyle(Color.coachingTextSecondary)
                } else {
                    Text("session.button.comingSoon")
                        .font(.caption.bold())
                        .foregroundStyle(Color.coachingTextSecondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.coachingCard)
                        .clipShape(Capsule())
                }
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .background(Color.coachingCard)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(!isSupported)
    }

    /// Mapping explicite sport → clé i18n.
    /// `LocalizedStringKey("...\(var)...")` avec interpolation dynamique ne résout PAS la lookup
    /// (SwiftUI traite l'interpolation comme un format spec). Switch verbose mais fiable.
    static func requestProgramKey(for sportCode: String) -> LocalizedStringKey {
        switch sportCode {
        case "running":          return "session.button.requestProgram.running"
        case "cycling":          return "session.button.requestProgram.cycling"
        case "swimming":         return "session.button.requestProgram.swimming"
        case "triathlon":        return "session.button.requestProgram.triathlon"
        case "strengthTraining": return "session.button.requestProgram.strengthTraining"
        case "yoga":             return "session.button.requestProgram.yoga"
        case "hiit":             return "session.button.requestProgram.hiit"
        case "hiking":           return "session.button.requestProgram.hiking"
        case "tennis":           return "session.button.requestProgram.tennis"
        case "football":         return "session.button.requestProgram.football"
        default:                 return "session.requestProgram.unsupportedSport"
        }
    }

    /// SF Symbol par code sport — aligné enum SportCode.
    private func sfSymbol(for sportCode: String) -> String {
        switch sportCode {
        case "running": return "figure.run"
        case "cycling": return "figure.outdoor.cycle"
        case "swimming": return "figure.pool.swim"
        case "triathlon": return "figure.mixed.cardio"
        case "strengthTraining": return "dumbbell.fill"
        case "yoga": return "figure.yoga"
        case "hiit": return "bolt.heart.fill"
        case "hiking": return "figure.hiking"
        case "tennis": return "figure.tennis"
        case "football": return "soccerball"
        default: return "questionmark.circle"
        }
    }
}

#Preview {
    SessionView()
        .environment(\.appDependencies, nil)
}
