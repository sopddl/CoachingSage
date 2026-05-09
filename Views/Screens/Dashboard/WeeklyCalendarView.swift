// Views/Screens/Dashboard/WeeklyCalendarView.swift
// Story 3.8 sous-tâche drag&drop (commit 10/3) — vue lecture seule du calendrier
// hebdo. Le drag&drop arrive en commit 11.
//
// **Layout** (verticale, iPhone portrait) :
//   - Section « 📦 À planifier » : pool des sessions sans `plannedDate`
//   - 7 sections jour (Lun→Dim) : sessions placées dans la semaine courante
//   - Chaque session = pastille couleur sport + nom + durée
//
// La couleur sport vient de `Color.coachingSport(forCode:)` — utile en mode
// `.allActivePrograms` (multi-prog). En mode `.singleProgram` toutes les
// pastilles ont la même couleur, ce qui reste lisible et redondant.
//
// Entrées (3 entry points spec ligne 622-625) :
//   1. CTA `↻ Réorganiser ma semaine` depuis `ActiveDashboardView` (mode `.allActivePrograms`)
//   2. Toolbar 📅 dans `AdaptedProgramView` (mode `.singleProgram(id:)`)
//   3. Icône 📅 nav bar `SessionView` (mode `.allActivePrograms`)
import SwiftUI

struct WeeklyCalendarView: View {
    @Environment(\.appDependencies) private var deps

    let mode: WeeklyCalendarViewModel.Mode

    @State private var viewModel: WeeklyCalendarViewModel?

    var body: some View {
        content
            .background(Color.coachingBackground.ignoresSafeArea())
            .navigationTitle(Text("dashboard.weekly.title"))
            .navigationBarTitleDisplayMode(.inline)
            .task { await bootstrapAndLoad() }
    }

    @ViewBuilder
    private var content: some View {
        if let vm = viewModel, vm.hasLoaded {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    poolSection(vm)
                    weekSection(vm)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        } else if viewModel?.error != nil {
            errorState
        } else {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    @ViewBuilder
    private func poolSection(_ vm: WeeklyCalendarViewModel) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("dashboard.weekly.pool.title")
                .font(.coachingCaption.weight(.semibold))
                .foregroundStyle(Color.coachingTextSecondary)
                .textCase(.uppercase)
                .tracking(0.8)
            if vm.pool.isEmpty {
                Text("dashboard.weekly.pool.empty")
                    .font(.coachingBody)
                    .foregroundStyle(Color.coachingTextSecondary)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.coachingCard.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                VStack(spacing: 6) {
                    ForEach(vm.pool) { item in
                        SessionRow(item: item)
                    }
                }
            }
        }
        .accessibilityIdentifier("dashboard.weekly.pool")
    }

    @ViewBuilder
    private func weekSection(_ vm: WeeklyCalendarViewModel) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(vm.daySlots) { slot in
                DayRow(slot: slot)
            }
        }
    }

    private var errorState: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 36, weight: .light))
                .foregroundStyle(Color.coachingError)
            Text("dashboard.weekly.error")
                .font(.coachingBody)
                .foregroundStyle(Color.coachingTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func bootstrapAndLoad() async {
        guard let deps else { return }
        if viewModel == nil {
            viewModel = WeeklyCalendarViewModel(
                mode: mode,
                programRepository: deps.adaptedProgramRepository
            )
        }
        guard let vm = viewModel,
              let userId = SupabaseService.shared.client.auth.currentSession?.user.id
        else { return }
        await vm.refresh(userId: userId)
    }
}

// MARK: - Day row

private struct DayRow: View {
    let slot: WeeklyCalendarViewModel.WeekDaySlot

    private static let dayLabelFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "d MMM"
        return f
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Text(weekdayLabel)
                    .font(.coachingCaption.weight(.semibold))
                    .foregroundStyle(Color.coachingTextSecondary)
                    .textCase(.uppercase)
                    .tracking(0.8)
                Spacer()
                Text(verbatim: Self.dayLabelFormatter.string(from: slot.date))
                    .font(.coachingCaption)
                    .foregroundStyle(Color.coachingTextSecondary.opacity(0.8))
            }
            if slot.items.isEmpty {
                Text("dashboard.weekly.day.empty")
                    .font(.coachingBody)
                    .foregroundStyle(Color.coachingTextSecondary.opacity(0.6))
                    .padding(.vertical, 4)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                VStack(spacing: 6) {
                    ForEach(slot.items) { item in
                        SessionRow(item: item)
                    }
                }
            }
        }
        .padding(12)
        .background(Color.coachingCard.opacity(slot.items.isEmpty ? 0.4 : 0.7))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .accessibilityIdentifier("dashboard.weekly.day.\(slot.id)")
    }

    /// Convertit l'index ISO (lundi=0..dimanche=6) vers le symbole `standalone`
    /// localisé du calendrier système (Sunday=1..Saturday=7).
    private var weekdayLabel: String {
        let symbols = Calendar.current.standaloneWeekdaySymbols
        let isoToSystem = [2, 3, 4, 5, 6, 7, 1]
        let idx = isoToSystem[max(0, min(6, slot.id))] - 1
        return symbols[idx].capitalized
    }
}

// MARK: - Session row

private struct SessionRow: View {
    let item: WeeklyCalendarViewModel.SessionItem

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(Color.coachingSport(forCode: item.sportCode))
                .frame(width: 10, height: 10)
            VStack(alignment: .leading, spacing: 2) {
                Text(verbatim: item.name)
                    .font(.coachingBody)
                    .foregroundStyle(Color.coachingTextPrimary)
                    .lineLimit(1)
                Text("dashboard.weekly.session.duration \(item.durationMinutes)")
                    .font(.coachingCaption)
                    .foregroundStyle(Color.coachingTextSecondary)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .background(Color.coachingBackground.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .accessibilityIdentifier("dashboard.weekly.session.\(item.id)")
    }
}
