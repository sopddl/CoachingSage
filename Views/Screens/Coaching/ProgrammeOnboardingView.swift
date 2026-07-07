// Views/Screens/Coaching/ProgrammeOnboardingView.swift
// Onboarding PROGRAMME « fil de Léon » (inc1 — coquille fil + génération).
//
// Présenté en sheet depuis SessionView (remplace SportPickerSheet → questionnaire
// comme chemin de création principal). Garde la barre du bas de l'app derrière.
//
// 3 parties verticales = un seul fil (party 2026-06-23, reco unifiée Sophie) :
//   ① TA DEMANDE          — carrousel de TES sports + champ libre.
//   ② CE QUE LÉON PROPOSE — restitution + récap éditable (rythme), aperçu vivant.
//   ③ CONVERSATION        — bulle d'invite + champ persistant (relances LOGGÉES,
//      PAS interprétées en inc1 ; le routage ✓/⏳/🚫 arrive à l'inc NL).
//
// Le vert « Créer mon programme » est le SEUL moment ferme : il rend le
// `CoachingSportProfile` finalisé à `onCompleted`, qui réutilise le chemin de
// commit du questionnaire (`presentAdaptedProgram(for:)`) côté SessionView.
import SwiftUI

struct ProgrammeOnboardingView: View {
    @State var viewModel: ProgrammeOnboardingViewModel
    let onCompleted: (CoachingSportProfile) -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.locale) private var locale

    @State private var showSportPicker = false
    @State private var conversationDraft = ""

    private static let proposalAnchor = "programme.fil.proposal.anchor"

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    demandeZone
                    proposalZone
                        .id(Self.proposalAnchor)
                    if viewModel.proposal != nil || !viewModel.conversation.isEmpty {
                        conversationZone
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
            // Découvrabilité (device-test Sophie 2026-06-24 : « j'ai pas vu le récap, j'ai
            // basculé tout de suite sur le programme »). Dès qu'une proposition existe, on
            // ferme le clavier + on amène le récap éditable sous les yeux avant le vert.
            .onChange(of: viewModel.proposal) { _, newProposal in
                guard newProposal != nil else { return }
                dismissKeyboard()
                withAnimation(.easeOut(duration: 0.3)) {
                    proxy.scrollTo(Self.proposalAnchor, anchor: .top)
                }
            }
            }
            .background(Color.coachingBackground.ignoresSafeArea())
            .navigationTitle(Text("programme.fil.title"))
            .navigationBarTitleDisplayMode(.inline)
            .tint(Color.coachingPrimary)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark").foregroundStyle(Color.coachingTextPrimary)
                    }
                    .accessibilityIdentifier("programme.fil.close")
                }
            }
            .safeAreaInset(edge: .bottom) { createButtonBar }
            .sheet(isPresented: $showSportPicker) {
                SportPickerSheet { code in
                    showSportPicker = false
                    if let sport = SportCode(rawValue: code) {
                        viewModel.selectSport(sport)
                    }
                }
            }
        }
    }

    // MARK: - Zone ① — Ta demande

    private var demandeZone: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("programme.fil.zone.demande")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(viewModel.activeSports, id: \.rawValue) { sport in
                        SportTileView(
                            sport: sport,
                            isSelected: viewModel.selectedSport == sport,
                            onTap: { viewModel.selectSport(sport) },
                            onShowTooltip: nil,
                            identifierPrefix: "programme.fil.sport"
                        )
                        .frame(width: 92)
                    }
                    autreTile
                }
                .padding(.vertical, 2)
            }

            HStack(alignment: .bottom, spacing: 8) {
                TextField(
                    "programme.fil.placeholder",
                    text: $viewModel.demandeText,
                    axis: .vertical
                )
                .lineLimit(2...5)
                .font(.coachingBody)
                .padding(12)
                .background(Color.coachingCard, in: RoundedRectangle(cornerRadius: CoachingRadius.md))
                .accessibilityIdentifier("programme.fil.demande.field")

                if !demandeIsEmpty {
                    Button {
                        dismissKeyboard()
                        viewModel.submitDemande()
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 30))
                            .foregroundStyle(Color.coachingPrimary)
                    }
                    .accessibilityIdentifier("programme.fil.demande.send")
                }
            }
        }
    }

    private var demandeIsEmpty: Bool {
        viewModel.demandeText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var autreTile: some View {
        Button { showSportPicker = true } label: {
            Color.clear
                .aspectRatio(1, contentMode: .fit)
                .overlay(
                    RoundedRectangle(cornerRadius: CoachingRadius.md)
                        .fill(Color.coachingCard)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: CoachingRadius.md)
                        .strokeBorder(Color.coachingTextSecondary.opacity(0.4),
                                      style: StrokeStyle(lineWidth: 1.5, dash: [4]))
                )
                .overlay(
                    VStack(spacing: 6) {
                        Image(systemName: "plus")
                            .font(.system(size: 26))
                            .foregroundStyle(Color.coachingTextSecondary)
                        Text("programme.fil.sport.autre")
                            .font(.coachingCaption)
                            .foregroundStyle(Color.coachingTextSecondary)
                    }
                )
        }
        .buttonStyle(.plain)
        .frame(width: 92)
        .accessibilityIdentifier("programme.fil.sport.autre")
    }

    // MARK: - Zone ② — Ce que Léon propose

    private var proposalZone: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 9) {
                LeonAvatarView(size: 30)
                Text("programme.fil.zone.proposal")
                    .font(.coachingH2)
                    .foregroundStyle(Color.coachingTextPrimary)
            }

            Group {
                if viewModel.isGenerating {
                    generatingRow
                } else if viewModel.generationFailed {
                    Text("programme.fil.error")
                        .font(.coachingBody)
                        .foregroundStyle(Color.coachingError)
                } else if let proposal = viewModel.proposal {
                    proposalContent(proposal)
                } else {
                    Text("programme.fil.leon.waiting")
                        .font(.coachingBody)
                        .foregroundStyle(Color.coachingTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.coachingPrimary.opacity(0.08), in: RoundedRectangle(cornerRadius: CoachingRadius.lg))
    }

    private var generatingRow: some View {
        HStack(spacing: 10) {
            ProgressView().tint(Color.coachingPrimary)
            Text("programme.fil.generating")
                .font(.coachingBody)
                .foregroundStyle(Color.coachingTextSecondary)
        }
    }

    @ViewBuilder
    private func proposalContent(_ proposal: ProgrammeOnboardingViewModel.Proposal) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(verbatim: restitutionText(for: proposal.sport))
                .font(.coachingBody.weight(.medium))
                .foregroundStyle(Color.coachingTextPrimary)

            recapRow(
                label: "programme.fil.recap.rythme",
                value: rythmeValue(proposal.frequencyPerWeek),
                why: nil,
                editMenu: AnyView(frequencyMenu)
            )
            recapRow(
                label: "programme.fil.recap.duree",
                value: String.localized("programme.fil.recap.duree.value", locale: locale),
                why: "programme.fil.recap.duree.why",
                editMenu: nil
            )

            Text(verbatim: weeksText(proposal.weekCount))
                .font(.coachingCaption)
                .foregroundStyle(Color.coachingTextSecondary)
        }
    }

    private var frequencyMenu: some View {
        Menu {
            ForEach(ProgrammeOnboardingViewModel.frequencyChoices, id: \.self) { value in
                Button {
                    viewModel.setFrequency(value)
                } label: {
                    Text(verbatim: rythmeValue(value))
                }
            }
        } label: {
            Image(systemName: "pencil")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.coachingOnPrimary)
                .padding(6)
                .background(Color.coachingPrimary.opacity(0.55), in: Circle())
        }
        .accessibilityIdentifier("programme.fil.recap.rythme.edit")
    }

    @ViewBuilder
    private func recapRow(label: LocalizedStringKey, value: String, why: LocalizedStringKey?, editMenu: AnyView?) -> some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.coachingCaption)
                    .foregroundStyle(Color.coachingTextSecondary)
                Text(verbatim: value)
                    .font(.coachingBody.weight(.medium))
                    .foregroundStyle(Color.coachingTextPrimary)
                if let why {
                    Text(why)
                        .font(.coachingCaption)
                        .foregroundStyle(Color.coachingTextSecondary.opacity(0.8))
                }
            }
            Spacer()
            if let editMenu { editMenu }
        }
        .padding(.vertical, 6)
    }

    // MARK: - Zone ③ — Conversation (relances : captées + loggées, pas interprétées en inc1)

    private var conversationZone: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(viewModel.conversation) { message in
                conversationBubble(message)
            }

            if viewModel.conversation.isEmpty {
                Text("programme.fil.conversation.invite")
                    .font(.coachingBody)
                    .foregroundStyle(Color.coachingTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack(spacing: 8) {
                TextField("programme.fil.conversation.placeholder", text: $conversationDraft, axis: .vertical)
                    .lineLimit(1...4)
                    .font(.coachingBody)
                    .padding(10)
                    .background(Color.coachingCard, in: RoundedRectangle(cornerRadius: CoachingRadius.md))
                    .accessibilityIdentifier("programme.fil.conversation.field")
                Button {
                    viewModel.sendFollowUp(conversationDraft)
                    conversationDraft = ""
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 30))
                        .foregroundStyle(conversationDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                         ? Color.coachingTextSecondary.opacity(0.4)
                                         : Color.coachingPrimary)
                }
                .disabled(conversationDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .accessibilityIdentifier("programme.fil.conversation.send")
            }
        }
    }

    @ViewBuilder
    private func conversationBubble(_ message: ProgrammeOnboardingViewModel.FilMessage) -> some View {
        switch message.sender {
        case .user:
            HStack {
                Spacer(minLength: 40)
                Text(verbatim: message.text)
                    .font(.coachingBody)
                    .foregroundStyle(Color.coachingOnPrimary)
                    .padding(.vertical, 10).padding(.horizontal, 14)
                    .background(Color.coachingPrimary, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        case .leon:
            HStack(alignment: .top, spacing: 8) {
                LeonAvatarView(size: 28)
                Text(LocalizedStringKey(message.text))
                    .font(.coachingBody)
                    .foregroundStyle(Color.coachingTextPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.vertical, 10).padding(.horizontal, 14)
                    .background(Color.coachingCard, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                Spacer(minLength: 40)
            }
        }
    }

    // MARK: - CTA vert (seul moment ferme)

    private var createButtonBar: some View {
        VStack(spacing: 0) {
            Button {
                guard let profile = viewModel.finalizedSportProfile() else { return }
                onCompleted(profile)
                dismiss()
            } label: {
                Text("programme.fil.cta.create")
            }
            .accentButtonStyle()
            .disabled(!viewModel.canCreate)
            .opacity(viewModel.canCreate ? 1 : 0.5)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .accessibilityIdentifier("programme.fil.cta.create")
        }
        .background(Color.coachingBackground.ignoresSafeArea(edges: .bottom))
    }

    // MARK: - Helpers

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil
        )
    }

    private func sectionLabel(_ key: LocalizedStringKey) -> some View {
        Text(key)
            .font(.coachingCaption.weight(.semibold))
            .foregroundStyle(Color.coachingTextSecondary)
            .textCase(.uppercase)
    }

    private func restitutionText(for sport: SportCode) -> String {
        let sportName = String.localized(String.LocalizationValue(sport.localizationKey), locale: locale)
        let format = String.localized("programme.fil.leon.restitution.format", locale: locale)
        return String(format: format, sportName)
    }

    private func rythmeValue(_ frequency: Int) -> String {
        let format = String.localized("programme.fil.recap.rythme.value.format", locale: locale)
        return String(format: format, frequency)
    }

    private func weeksText(_ weeks: Int) -> String {
        let format = String.localized("programme.fil.recap.weeks.format", locale: locale)
        return String(format: format, weeks)
    }
}
