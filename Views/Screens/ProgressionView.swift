// Views/Screens/ProgressionView.swift
// Story 3.9 — onglet Progrès : agrégé multi-sport (widget stats, forme physique HK,
// volume par sport, performances récentes). Nommé ProgressionView (pas ProgressView)
// pour éviter le conflit avec SwiftUI.ProgressView.
//
// Pattern : la View est responsable de fetch les programs (via AdaptedProgramRepository)
// et passe au VM qui orchestre le calcul. Garde-fou EU MDR : aucune interprétation
// médicale des chiffres HK (juste valeur + flèche delta neutre).
import SwiftUI
import UIKit
import TemplateModel

struct ProgressionView: View {
    @Environment(\.appDependencies) private var deps

    @State private var viewModel: ProgressViewModel?
    @State private var programs: [AdaptedProgramRecord] = []
    @State private var loading: Bool = true
    @State private var loadFailed: Bool = false
    @State private var periodPickerPresented: Bool = false

    var body: some View {
        NavigationStack {
            content
                .background(Color.coachingBackground.ignoresSafeArea())
                .navigationTitle(Text("progress.title"))
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Text("progress.nav_kicker")
                            .font(.caption2)
                            .foregroundStyle(Color.coachingTextSecondary)
                            .accessibilityHidden(true)
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        // Story sœur 3.z — picker accessible dès qu'il y a du contenu
                        // (programme actif OU historique HK), pas seulement si programs
                        // non vide. Empty state masque le picker.
                        if let viewModel, !viewModel.isEmpty {
                            Button {
                                periodPickerPresented = true
                            } label: {
                                Image(systemName: "clock")
                                    .foregroundStyle(Color.coachingPrimary)
                            }
                            .accessibilityIdentifier("progress.period_picker")
                            .accessibilityLabel(Text("progress.period_picker.a11y"))
                        }
                    }
                }
                .sheet(isPresented: $periodPickerPresented) {
                    if let viewModel {
                        periodPickerSheet(viewModel: viewModel)
                            .presentationDetents([.fraction(0.35)])
                    }
                }
        }
        .task {
            await bootstrap()
        }
    }

    // MARK: - Content router

    @ViewBuilder
    private var content: some View {
        if loading && viewModel == nil {
            ProgressView()
                .progressViewStyle(.circular)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let viewModel {
            if viewModel.isEmpty {
                emptyStateView
            } else {
                loadedScrollView(viewModel: viewModel)
            }
        } else if loadFailed {
            errorView
        }
    }

    // MARK: - Bootstrap

    private func bootstrap() async {
        guard let deps else {
            loading = false
            loadFailed = true
            return
        }
        let vm = viewModel ?? ProgressViewModel(healthKit: deps.healthKitService)
        if viewModel == nil { viewModel = vm }

        // Story 3.z — l'init de la VM a déjà setté period selon le flag UserDefaults
        // (.quarter au premier launch, .week ensuite). Ici on bascule le flag à true
        // pour que les launchs suivants reviennent au défaut .week.
        vm.markFirstLaunchSeen()

        await vm.ensureProgressAuthorization()
        await refreshPrograms(deps: deps, viewModel: vm)
    }

    private func refreshPrograms(
        deps: AppDependencies,
        viewModel: ProgressViewModel
    ) async {
        guard let userId = SupabaseService.shared.client.auth.currentSession?.user.id else {
            loading = false
            loadFailed = true
            return
        }
        loading = true
        loadFailed = false
        do {
            programs = try await deps.adaptedProgramRepository.fetchActive(for: userId)
            await viewModel.reload(programs: programs)
        } catch {
            loadFailed = true
        }
        loading = false
    }

    // MARK: - Loaded scroll

    private func loadedScrollView(viewModel: ProgressViewModel) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Stats hebdo + PR n'ont de sens qu'avec un programme actif (séances
                // trackées par l'app). En mode "HK history only", on les masque.
                if viewModel.hasActivePrograms {
                    weeklyStatsBlock(stats: viewModel.stats)
                }
                hkFitnessBlock(state: viewModel.hkFitness)
                volumeBySportBlock(state: viewModel.volumeRows)
                if viewModel.hasActivePrograms {
                    triathlonDisciplinesBlock(state: viewModel.triathlonDisciplines)
                    personalRecordsBlock(state: viewModel.personalRecords)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
    }

    // MARK: - Bloc 1 — widget stats

    private func weeklyStatsBlock(stats: WeeklyStats) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            blockTitle(LocalizedStringKey(currentPeriodKey))
            HStack(spacing: 0) {
                statColumn(
                    value: formattedDuration(minutes: stats.totalMinutes),
                    labelKey: "progress.stats.volume"
                )
                divider
                statColumn(
                    value: "\(stats.completedCount)",
                    labelKey: "progress.stats.sessions"
                )
                divider
                statColumn(
                    value: "\(stats.streakDays)",
                    labelKey: "progress.stats.streak"
                )
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.coachingEarth.opacity(0.06), radius: 6, x: 0, y: 2)
            )
        }
    }

    private func statColumn(value: String, labelKey: LocalizedStringKey) -> some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(Color.coachingRecord)
            Text(labelKey)
                .font(.caption2)
                .foregroundStyle(Color.coachingTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.coachingTextSecondary.opacity(0.15))
            .frame(width: 1, height: 36)
    }

    // MARK: - Bloc 2 — Forme physique HK

    private func hkFitnessBlock(state: ProgressViewModel.BlockState<HKFitnessReadout>) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            blockTitle("progress.health.title")
            switch state {
            case .idle, .loading:
                skeletonCard(rows: 3)
            case .loaded(let readout):
                hkFitnessCard(readout: readout)
            }
        }
    }

    private func hkFitnessCard(readout: HKFitnessReadout) -> some View {
        VStack(spacing: 0) {
            hkFitnessRow(
                icon: "❤️",
                nameKey: "progress.health.rhr",
                metaKey: hkAverageMetaKey,
                value: readout.restingHR.map { String(format: "%.0f", $0) },
                unitKey: "progress.health.rhr.unit",
                delta: readout.restingHRDelta,
                deltaIsBetterWhenNegative: true
            )
            rowDivider
            hkFitnessRow(
                icon: "📈",
                nameKey: "progress.health.hrv",
                metaKey: hkAverageMetaKey,
                value: readout.hrv.map { String(format: "%.0f", $0) },
                unitKey: "progress.health.hrv.unit",
                delta: readout.hrvDelta,
                deltaIsBetterWhenNegative: false
            )
            rowDivider
            hkFitnessRow(
                icon: "😴",
                nameKey: "progress.health.sleep",
                metaKey: hkAverageMetaKey,
                value: readout.sleepMinutes.map { formattedSleepDuration(minutes: $0) },
                unitKey: nil,
                delta: readout.sleepDelta,
                deltaIsBetterWhenNegative: false
            )

            if readout.isFullyUnavailable {
                hkUnavailableFooter
            }
        }
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemBackground))
                .shadow(color: Color.coachingEarth.opacity(0.06), radius: 6, x: 0, y: 2)
        )
    }

    private func hkFitnessRow(
        icon: String,
        nameKey: LocalizedStringKey,
        metaKey: LocalizedStringKey,
        value: String?,
        unitKey: LocalizedStringKey?,
        delta: Double?,
        deltaIsBetterWhenNegative: Bool
    ) -> some View {
        HStack(alignment: .center, spacing: 12) {
            Text(icon)
                .font(.system(size: 22))
                .frame(width: 30)
            VStack(alignment: .leading, spacing: 2) {
                Text(nameKey)
                    .font(.subheadline)
                    .foregroundStyle(Color.coachingTextPrimary)
                Text(metaKey)
                    .font(.caption2)
                    .foregroundStyle(Color.coachingTextSecondary)
            }
            Spacer()
            HStack(spacing: 4) {
                if let value {
                    Text(value)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.coachingPrimary)
                    if let unitKey {
                        Text(unitKey)
                            .font(.caption)
                            .foregroundStyle(Color.coachingTextSecondary)
                    }
                    deltaArrow(delta: delta, betterWhenNegative: deltaIsBetterWhenNegative)
                } else {
                    Text(verbatim: "—")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.coachingDisabled)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }

    @ViewBuilder
    private func deltaArrow(delta: Double?, betterWhenNegative: Bool) -> some View {
        if let delta, abs(delta) >= 0.5 {
            let isImprovement = betterWhenNegative ? (delta < 0) : (delta > 0)
            Image(systemName: delta > 0 ? "arrow.up.right" : "arrow.down.right")
                .font(.caption.bold())
                .foregroundStyle(isImprovement ? Color.coachingSuccess : Color.coachingError)
                .accessibilityLabel(Text(isImprovement ? "progress.delta.up.a11y" : "progress.delta.down.a11y"))
        }
    }

    private var hkUnavailableFooter: some View {
        VStack(spacing: 6) {
            Text("progress.health.unavailable.hint")
                .font(.caption2)
                .foregroundStyle(Color.coachingTextSecondary)
                .multilineTextAlignment(.center)
            Button {
                openSettings()
            } label: {
                Text("progress.health.unavailable.cta")
                    .font(.caption.bold())
                    .foregroundStyle(Color.coachingPrimary)
            }
            .accessibilityIdentifier("progress.health.cta_settings")
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
    }

    private var rowDivider: some View {
        Rectangle()
            .fill(Color.coachingTextSecondary.opacity(0.1))
            .frame(height: 1)
            .padding(.leading, 56)
    }

    // MARK: - Bloc 3 — Volume par sport

    private func volumeBySportBlock(state: ProgressViewModel.BlockState<[SportVolumeRow]>) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            switch state {
            case .idle, .loading:
                blockTitle("progress.volume.title")
                skeletonCard(rows: 2)
            case .loaded(let rows):
                if !rows.isEmpty {
                    blockTitle("progress.volume.title")
                    VStack(spacing: 10) {
                        ForEach(rows) { row in
                            volumeRow(row: row)
                        }
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.coachingEarth.opacity(0.06), radius: 6, x: 0, y: 2)
                    )
                }
                // Si rows vides → bloc entièrement masqué (AC : pas de "0 min" polluant).
            }
        }
    }

    private func volumeRow(row: SportVolumeRow) -> some View {
        HStack(spacing: 12) {
            Image(systemName: row.sportCode?.sfSymbol ?? "figure.run")
                .font(.system(size: 16))
                .foregroundStyle(Color.coachingSport(forCode: row.sportCode?.rawValue ?? ""))
                .frame(width: 26)
            if let sportCode = row.sportCode {
                Text(LocalizedStringKey(sportCode.localizationKey))
                    .font(.subheadline)
                    .foregroundStyle(Color.coachingTextPrimary)
            } else {
                Text(row.displayName)
                    .font(.subheadline)
                    .foregroundStyle(Color.coachingTextPrimary)
            }
            Spacer()
            Text(formattedDuration(minutes: row.totalMinutes))
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.coachingTextPrimary)
        }
        .overlay(alignment: .bottom) {
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.coachingTextSecondary.opacity(0.1))
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(
                            LinearGradient(
                                colors: [Color.coachingRecord, Color.coachingRecord.opacity(0.6)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(6, proxy.size.width * row.ratio), height: 6)
                }
                .offset(y: 24)
            }
            .frame(height: 6)
        }
        .padding(.bottom, 22)
    }

    // MARK: - Bloc 5 (chantier récap hebdo triathlon 2026-07-06/07) — Répartition triathlon

    /// Séances complétées par discipline (nage/vélo/course) pour un programme
    /// triathlon actif, sur la fenêtre sélectionnée. Source app (completionState),
    /// PAS HealthKit — contrairement au bloc 3 "Volume par sport" (tous sports HK).
    /// Bloc entièrement masqué si pas de programme triathlon actif ou aucune
    /// séance complétée sur la fenêtre (pas de "0 séance" polluant, cf bloc 3).
    private func triathlonDisciplinesBlock(state: ProgressViewModel.BlockState<[TriathlonDisciplineRow]>) -> some View {
        Group {
            if case .loaded(let rows) = state, !rows.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    blockTitle("progress.triathlonDisciplines.title")
                    VStack(spacing: 10) {
                        ForEach(rows) { row in
                            triathlonDisciplineRow(row: row)
                        }
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.coachingEarth.opacity(0.06), radius: 6, x: 0, y: 2)
                    )
                }
            }
        }
    }

    private func triathlonDisciplineRow(row: TriathlonDisciplineRow) -> some View {
        let sportCode = SportCode(rawValue: row.sportCode)
        return HStack(spacing: 12) {
            Image(systemName: sportCode?.sfSymbol ?? "figure.mixed.cardio")
                .font(.system(size: 16))
                .foregroundStyle(Color.coachingSport(forCode: row.sportCode))
                .frame(width: 26)
            Text(LocalizedStringKey(sportCode?.localizationKey ?? row.sportCode))
                .font(.subheadline)
                .foregroundStyle(Color.coachingTextPrimary)
            Spacer()
            Text("progress.triathlonDisciplines.sessionsCount \(row.completedCount)")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.coachingTextPrimary)
        }
        .overlay(alignment: .bottom) {
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.coachingTextSecondary.opacity(0.1))
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(
                            LinearGradient(
                                colors: [Color.coachingRecord, Color.coachingRecord.opacity(0.6)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(6, proxy.size.width * row.ratio), height: 6)
                }
                .offset(y: 24)
            }
            .frame(height: 6)
        }
        .padding(.bottom, 22)
    }

    // MARK: - Bloc 4 — Performances récentes

    private func personalRecordsBlock(state: ProgressViewModel.BlockState<[PRRecord]>) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            switch state {
            case .idle, .loading:
                EmptyView()
            case .loaded(let records):
                if !records.isEmpty {
                    blockTitle("progress.pr.title")
                    VStack(spacing: 10) {
                        ForEach(records) { record in
                            prCard(record: record)
                        }
                    }
                }
            }
        }
    }

    private func prCard(record: PRRecord) -> some View {
        HStack(spacing: 12) {
            Text(verbatim: "🏅")
                .font(.system(size: 28))
            VStack(alignment: .leading, spacing: 4) {
                Text("progress.pr.badge")
                    .font(.caption2.bold())
                    .foregroundStyle(Color.coachingRecord)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule().fill(Color.coachingRecord.opacity(0.15))
                    )
                let sportLabel = sportLabelKey(forSportCode: record.sportCode)
                prDescription(record: record, sportLabel: sportLabel)
                    .font(.subheadline)
                    .foregroundStyle(Color.coachingTextPrimary)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.coachingRecord.opacity(0.12),
                            Color.coachingSuccess.opacity(0.06)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
    }

    // MARK: - Empty state

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 52))
                .foregroundStyle(Color.coachingTextSecondary)
            Text("progress.empty.title")
                .font(.coachingH1)
                .foregroundStyle(Color.coachingTextPrimary)
                .multilineTextAlignment(.center)
            Text("progress.empty.subtitle")
                .font(.coachingBody)
                .foregroundStyle(Color.coachingTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityIdentifier("progress.empty.state")
    }

    // MARK: - Error

    private var errorView: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 32))
                .foregroundStyle(Color.coachingWarning)
            Text("progress.error.title")
                .font(.coachingH2)
                .foregroundStyle(Color.coachingTextPrimary)
            Button {
                Task { await bootstrap() }
            } label: {
                Text("common.retry")
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.coachingPrimary)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Period picker sheet

    private func periodPickerSheet(viewModel: ProgressViewModel) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("progress.period_picker.title")
                    .font(.coachingH2)
                    .foregroundStyle(Color.coachingTextPrimary)
                Spacer()
                Button {
                    periodPickerPresented = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(Color.coachingTextSecondary)
                }
                .accessibilityLabel(Text("common.close"))
            }
            VStack(spacing: 0) {
                ForEach(ProgressPeriod.allCases, id: \.self) { period in
                    periodPickerRow(period: period, viewModel: viewModel)
                    if period != ProgressPeriod.allCases.last {
                        rowDivider
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.systemBackground))
            )
            Spacer(minLength: 0)
        }
        .padding(20)
        .background(Color.coachingBackground.ignoresSafeArea())
    }

    private func periodPickerRow(period: ProgressPeriod, viewModel: ProgressViewModel) -> some View {
        let isSelected = viewModel.period == period
        return Button {
            Task {
                await viewModel.selectPeriod(period, programs: programs)
                periodPickerPresented = false
            }
        } label: {
            HStack {
                Text(periodLabelKey(period))
                    .font(.subheadline)
                    .foregroundStyle(Color.coachingTextPrimary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(Color.coachingPrimary)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("progress.period.\(period.rawValue)")
    }

    // MARK: - Helpers UI

    private func blockTitle(_ key: LocalizedStringKey) -> some View {
        Text(key)
            .font(.coachingH2)
            .foregroundStyle(Color.coachingTextPrimary)
            .padding(.leading, 4)
    }

    private func skeletonCard(rows: Int) -> some View {
        VStack(spacing: 10) {
            ForEach(0..<rows, id: \.self) { _ in
                HStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.coachingTextSecondary.opacity(0.15))
                        .frame(height: 16)
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemBackground))
        )
        .accessibilityHidden(true)
    }

    private var currentPeriodKey: String {
        guard let viewModel else { return "progress.period.week.title" }
        switch viewModel.period {
        case .week:    return "progress.period.week.title"
        case .month:   return "progress.period.month.title"
        case .quarter: return "progress.period.quarter.title"
        }
    }

    private func periodLabelKey(_ period: ProgressPeriod) -> LocalizedStringKey {
        switch period {
        case .week:    return "progress.period.week"
        case .month:   return "progress.period.month"
        case .quarter: return "progress.period.quarter"
        }
    }

    /// Meta « Moy. 7 / 30 / 90 derniers j » selon période.
    private var hkAverageMetaKey: LocalizedStringKey {
        guard let viewModel else { return "progress.health.meta.week" }
        switch viewModel.period {
        case .week:    return "progress.health.meta.week"
        case .month:   return "progress.health.meta.month"
        case .quarter: return "progress.health.meta.quarter"
        }
    }

    private func formattedDuration(minutes: Int) -> String {
        if minutes < 60 {
            return "\(minutes)m"
        }
        let hours = minutes / 60
        let mins = minutes % 60
        return mins == 0 ? "\(hours)h" : "\(hours)h\(String(format: "%02d", mins))"
    }

    private func formattedSleepDuration(minutes: Double) -> String {
        let total = Int(minutes.rounded())
        return formattedDuration(minutes: total)
    }

    private func sportLabelKey(forSportCode code: String) -> LocalizedStringKey {
        guard let sport = SportCode(rawValue: code) else {
            return LocalizedStringKey(code)
        }
        return LocalizedStringKey(sport.localizationKey)
    }

    private func prDescription(record: PRRecord, sportLabel: LocalizedStringKey) -> Text {
        // Description : « Course — plus longue séance : 1h20 (vs 1h05) »
        let value = formattedDuration(minutes: record.valueMinutes)
        let previous = formattedDuration(minutes: record.previousBestMinutes)
        return Text(sportLabel)
            + Text(verbatim: " — ")
            + Text("progress.pr.longest_session")
            + Text(verbatim: " : \(value)")
            + Text(verbatim: " (")
            + Text("progress.pr.previous_best")
            + Text(verbatim: " \(previous))")
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

#Preview("Empty") {
    ProgressionView()
}
