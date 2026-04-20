import SwiftUI
import CoreLocation

/// SwiftUI test interface for the GPS background tracking spike.
struct GPSSpikeView: View {

    @StateObject private var loc = LocationService()
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        NavigationStack {
            List {
                statusSection
                liveStatsSection
                qualitySection
                batterySection
                authSection
                controlsSection
                pointsLogSection
                interpretationSection
            }
            .navigationTitle("GPS Spike 0.1")
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .background {
                    loc.appDidEnterBackground()
                }
            }
        }
    }

    // MARK: - Sections

    @ViewBuilder
    private var statusSection: some View {
        Section("Statut") {
            HStack {
                Text("État")
                Spacer()
                Text(loc.status.rawValue)
                    .foregroundStyle(statusColor)
                    .bold()
            }
            HStack {
                Text("Background autorisé")
                Spacer()
                Text(loc.backgroundUpdatesAllowed ? "✅" : "❌")
            }
            HStack {
                Text("Passé en background")
                Spacer()
                Text(loc.didEnterBackground ? "✅" : "—")
            }
            if loc.crashedOrKilled {
                HStack {
                    Text("App killée pendant tracking")
                        .foregroundStyle(.red)
                    Spacer()
                    Text("⚠️")
                }
            }
            if let err = loc.lastError {
                Text(err)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }

    @ViewBuilder
    private var liveStatsSection: some View {
        Section("Stats live") {
            metricRow(label: "Temps écoulé", value: formatDuration(loc.elapsedSeconds))
            metricRow(label: "Distance totale", value: formatDistance(loc.totalDistanceMeters))
            metricRow(label: "Points GPS capturés", value: "\(loc.points.count)")
            if let firstFix = loc.firstFixSeconds {
                metricRow(label: "First fix", value: String(format: "%.1f s", firstFix), color: firstFix < 10 ? .green : .orange)
            } else {
                metricRow(label: "First fix", value: "en attente...")
            }
            if let last = loc.lastUpdate {
                metricRow(label: "Dernier update", value: last.formatted(date: .omitted, time: .standard))
            }
        }
    }

    @ViewBuilder
    private var qualitySection: some View {
        Section("Qualité GPS") {
            metricRow(
                label: "Précision moyenne",
                value: loc.averageAccuracy > 0 ? String(format: "± %.1f m", loc.averageAccuracy) : "—",
                color: loc.averageAccuracy > 0 && loc.averageAccuracy < 10 ? .green : .orange
            )
            if let lastPoint = loc.points.last {
                metricRow(label: "Dernier point — précision", value: String(format: "± %.1f m", lastPoint.horizontalAccuracy))
                metricRow(label: "Dernier point — vitesse", value: String(format: "%.1f m/s", lastPoint.speed))
                metricRow(label: "Dernier point — altitude", value: String(format: "%.0f m", lastPoint.altitude))
            }
        }
    }

    @ViewBuilder
    private var batterySection: some View {
        Section("Batterie") {
            if let start = loc.batteryLevelStart {
                metricRow(label: "Au démarrage", value: formatBattery(start))
            }
            if let now = loc.batteryLevelNow {
                metricRow(label: "Maintenant", value: formatBattery(now))
            }
            if let start = loc.batteryLevelStart, let now = loc.batteryLevelNow, start > 0, now > 0 {
                let drop = (start - now) * 100
                let dropPerHour = loc.elapsedSeconds > 60
                    ? drop / (loc.elapsedSeconds / 3600)
                    : nil
                metricRow(label: "Drop session", value: String(format: "%.1f %%", drop))
                if let perHour = dropPerHour {
                    metricRow(label: "Drop estimé /h", value: String(format: "%.1f %% / h", perHour), color: perHour < 15 ? .green : .orange)
                }
            }
        }
    }

    @ViewBuilder
    private var authSection: some View {
        Section("Autorisation") {
            HStack {
                Text("Statut")
                Spacer()
                Text(authStatusLabel)
                    .foregroundStyle(authStatusColor)
            }
            if loc.authorizationStatus == .notDetermined {
                Button {
                    loc.requestAuthorization()
                } label: {
                    Label("Demander accès localisation", systemImage: "location")
                }
            }
            if loc.authorizationStatus == .authorizedWhenInUse {
                Button {
                    loc.upgradeToAlwaysAuthorization()
                } label: {
                    Label("Demander accès \"Toujours\" (background)", systemImage: "location.fill")
                }
            }
        }
    }

    @ViewBuilder
    private var controlsSection: some View {
        Section("Contrôles") {
            if loc.status == .idle || loc.status == .paused {
                Button {
                    loc.startTracking()
                } label: {
                    Label("Démarrer le tracking", systemImage: "play.circle.fill")
                        .foregroundStyle(.green)
                }
                .disabled(loc.authorizationStatus != .authorizedAlways && loc.authorizationStatus != .authorizedWhenInUse)
            } else {
                Button {
                    loc.pauseTracking()
                } label: {
                    Label("Pause", systemImage: "pause.circle.fill")
                        .foregroundStyle(.orange)
                }
                Button {
                    loc.stopTracking()
                } label: {
                    Label("Arrêter et terminer", systemImage: "stop.circle.fill")
                        .foregroundStyle(.red)
                }
            }
        }
    }

    @ViewBuilder
    private var pointsLogSection: some View {
        Section("5 derniers points") {
            if loc.points.isEmpty {
                Text("Aucun point capturé")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            ForEach(loc.points.suffix(5).reversed()) { point in
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(String(format: "%.5f", point.coordinate.latitude)), \(String(format: "%.5f", point.coordinate.longitude))")
                        .font(.caption.monospaced())
                    Text("± \(String(format: "%.0f", point.horizontalAccuracy))m — \(point.timestamp.formatted(date: .omitted, time: .standard))")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    @ViewBuilder
    private var interpretationSection: some View {
        Section("Critères PASS du spike (Story 0.1)") {
            VStack(alignment: .leading, spacing: 6) {
                criterionRow(label: "Tracking continue en background",
                             passed: loc.didEnterBackground && loc.points.count > 5)
                criterionRow(label: "First fix < 10 s",
                             passed: (loc.firstFixSeconds ?? 999) < 10)
                criterionRow(label: "Précision < 10 m moyenne",
                             passed: loc.averageAccuracy > 0 && loc.averageAccuracy < 10)
                criterionRow(label: "Pas de crash après tracking",
                             passed: !loc.crashedOrKilled && loc.points.count > 0)
                criterionRow(label: "Points capturés > 50",
                             passed: loc.points.count > 50)
            }
            .font(.caption)
        }
    }

    // MARK: - Helpers

    private var statusColor: Color {
        switch loc.status {
        case .tracking: return .green
        case .waitingFix: return .orange
        case .paused: return .blue
        case .idle: return .secondary
        }
    }

    private var authStatusLabel: String {
        switch loc.authorizationStatus {
        case .notDetermined: return "Non demandé"
        case .restricted: return "Restreint"
        case .denied: return "Refusé ❌"
        case .authorizedWhenInUse: return "Pendant utilisation ⚠️ (background non actif)"
        case .authorizedAlways: return "Toujours ✅"
        @unknown default: return "Inconnu"
        }
    }

    private var authStatusColor: Color {
        switch loc.authorizationStatus {
        case .authorizedAlways: return .green
        case .authorizedWhenInUse: return .orange
        case .denied, .restricted: return .red
        default: return .secondary
        }
    }

    @ViewBuilder
    private func metricRow(label: String, value: String, color: Color = .secondary) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .foregroundStyle(color)
                .monospacedDigit()
        }
    }

    @ViewBuilder
    private func criterionRow(label: String, passed: Bool) -> some View {
        HStack {
            Image(systemName: passed ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(passed ? .green : .secondary)
            Text(label)
        }
    }

    private func formatDuration(_ seconds: Double) -> String {
        let h = Int(seconds) / 3600
        let m = (Int(seconds) % 3600) / 60
        let s = Int(seconds) % 60
        if h > 0 {
            return String(format: "%dh %02d'%02d", h, m, s)
        } else {
            return String(format: "%d' %02d", m, s)
        }
    }

    private func formatDistance(_ meters: Double) -> String {
        if meters >= 1000 {
            return String(format: "%.2f km", meters / 1000)
        } else {
            return String(format: "%.0f m", meters)
        }
    }

    private func formatBattery(_ level: Double) -> String {
        if level < 0 { return "—" }
        return String(format: "%.0f %%", level * 100)
    }
}

#Preview {
    GPSSpikeView()
}
