import SwiftUI
import HealthKit

/// SwiftUI test interface for the HealthKit spike.
/// Each section validates one assumption from Story 0.2 acceptance criteria.
struct HealthKitSpikeView: View {

    @StateObject private var hk = HealthKitService()

    var body: some View {
        NavigationStack {
            List {
                statusSection
                stepsSection
                heartRateSection
                workoutsSection
                writeWorkoutSection
                interpretationSection
            }
            .navigationTitle("HealthKit Spike")
            .task {
                hk.checkAvailability()
            }
        }
    }

    // MARK: - Sections

    @ViewBuilder
    private var statusSection: some View {
        Section("Statut HealthKit") {
            HStack {
                Text("Disponibilité")
                Spacer()
                Text(statusLabel)
                    .foregroundStyle(statusColor)
            }
            if let err = hk.lastError {
                Text(err)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
            Button {
                Task { await hk.requestAuthorization() }
            } label: {
                Label("Demander l'autorisation HealthKit", systemImage: "checkmark.shield")
            }
            .disabled(hk.status == .unavailable)
        }
    }

    @ViewBuilder
    private var stepsSection: some View {
        Section("Pas (iPhone seul — FR43)") {
            metricRow(label: "Aujourd'hui", value: hk.stepsToday.map { "\($0) pas" } ?? "—")
            metricRow(label: "Hier", value: hk.stepsYesterday.map { "\($0) pas" } ?? "—")
            Button {
                Task { await hk.readSteps() }
            } label: {
                Label("Lire mes pas", systemImage: "figure.walk")
            }
            Text("Note : sur le simulateur sans données injectées, les valeurs sont 0. C'est normal.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private var heartRateSection: some View {
        Section("Fréquence cardiaque (Apple Watch — FR41/FR42)") {
            if let bpm = hk.latestHeartRate {
                metricRow(label: "Dernière FC", value: "\(Int(bpm)) bpm")
            } else {
                metricRow(label: "Dernière FC", value: "—")
            }
            metricRow(label: "Échantillons (7 jours)", value: "\(hk.heartRateSamples.count)")
            ForEach(hk.heartRateSamples.prefix(5)) { sample in
                VStack(alignment: .leading) {
                    Text("\(Int(sample.bpm)) bpm")
                        .font(.headline)
                    Text("\(sample.date.formatted(date: .abbreviated, time: .shortened)) — \(sample.sourceName)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Button {
                Task { await hk.readRecentHeartRate() }
            } label: {
                Label("Lire ma FC récente", systemImage: "heart.fill")
            }
            Text("Pour avoir des données : tester sur un device avec Apple Watch paire, OU injecter manuellement dans l'app Santé du simulateur.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private var workoutsSection: some View {
        Section("Workouts toutes sources (FR41 — \"hub universel\")") {
            metricRow(label: "Total 30 derniers jours", value: "\(hk.workoutsLast30Days.count)")
            ForEach(hk.workoutsLast30Days.prefix(10)) { workout in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(workout.activityType)
                            .font(.headline)
                        Spacer()
                        Text(workout.startDate.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    HStack(spacing: 12) {
                        Text("\(Int(workout.duration / 60)) min")
                        if let dist = workout.totalDistance {
                            Text(String(format: "%.2f km", dist / 1000))
                        }
                        if let kcal = workout.totalEnergyBurned {
                            Text("\(Int(kcal)) kcal")
                        }
                    }
                    .font(.caption)
                    Text("Source : \(workout.sourceName)")
                        .font(.caption2)
                        .foregroundStyle(.tint)
                }
                .padding(.vertical, 2)
            }
            Button {
                Task { await hk.readRecentWorkouts() }
            } label: {
                Label("Lire mes workouts", systemImage: "figure.run.circle")
            }
            Text("Si tu as Garmin Connect / Strava / Fitbit qui synchronise vers Apple Health, leurs workouts doivent apparaître ici. C'est le test crucial du \"hub universel\".")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private var writeWorkoutSection: some View {
        Section("Écriture d'un workout (FR45)") {
            if let id = hk.lastWrittenWorkoutId {
                Text("Workout écrit ✅\nID : \(id.uuidString.prefix(8))…")
                    .font(.caption)
                    .foregroundStyle(.green)
            }
            Button {
                Task {
                    await hk.writeFakeRunningWorkout()
                    // Re-read to confirm
                    await hk.readRecentWorkouts()
                }
            } label: {
                Label("Écrire un faux workout running 30min/5km", systemImage: "square.and.arrow.up")
            }
            Text("Après écriture, ouvre l'app Santé d'iOS et vérifie que le workout running apparaît dans la liste des Workouts.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private var interpretationSection: some View {
        Section("Interprétation du spike") {
            VStack(alignment: .leading, spacing: 8) {
                Text("Critères PASS")
                    .font(.headline)
                Label("Autorisation accordée sans crash", systemImage: "1.circle")
                Label("Steps lisibles (avec data injectée si simu)", systemImage: "2.circle")
                Label("HR lisible (sur device avec Watch ou data injectée)", systemImage: "3.circle")
                Label("Workouts d'autres sources visibles si elles existent", systemImage: "4.circle")
                Label("Workout écrit visible dans app Santé", systemImage: "5.circle")
            }
            .font(.caption)
        }
    }

    // MARK: - Helpers

    private var statusLabel: String {
        switch hk.status {
        case .unknown: return "Inconnu"
        case .unavailable: return "Non disponible"
        case .notAuthorized: return "Pas encore autorisé"
        case .partiallyAuthorized: return "Partiellement autorisé"
        case .authorized: return "Autorisé ✅"
        }
    }

    private var statusColor: Color {
        switch hk.status {
        case .authorized: return .green
        case .unavailable: return .red
        default: return .orange
        }
    }

    @ViewBuilder
    private func metricRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    HealthKitSpikeView()
}
