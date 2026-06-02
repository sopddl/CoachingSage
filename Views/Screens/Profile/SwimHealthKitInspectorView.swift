// Views/Screens/Profile/SwimHealthKitInspectorView.swift
// Story 3.16 AC11 (Phase 1) — écran d'inspection DEBUG des workouts natation
// HealthKit. Affiche pour chaque séance natation des 12 dernières semaines :
// date, durée, distance totale, total strokes, badge Watch, type de plan d'eau,
// pool length, puis le détail lap-by-lap (stroke / distance / pace / HR).
//
// **DEBUG-only** : ce fichier est compilé uniquement en configuration Debug,
// pas de string i18n, FR en dur. Sert à analyser la donnée brute Apple Watch
// sur iPhone réel avant d'arbitrer Phase 2 (autoprofile / records / adapter).
#if DEBUG
import SwiftUI

struct SwimHealthKitInspectorView: View {
    @Environment(\.appDependencies) private var deps

    private enum EmptyReason: Equatable {
        case noWorkouts
    }

    private enum LoadState: Equatable {
        case idle
        case loading
        case loaded
        case refused
        case empty(reason: EmptyReason)
    }

    @State private var state: LoadState = .idle
    @State private var details: [HealthKitSwimWorkoutDetail] = []
    @State private var exportURL: URL?
    @State private var diagnostics: SwimFetchDiagnostics?
    private let weeksBack: Int = 12
    private let fetchLimit: Int = 12

    var body: some View {
        Group {
            switch state {
            case .idle, .loading:
                ProgressView("Lecture HealthKit natation…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .refused:
                refusedView
            case .empty(.noWorkouts):
                emptyView
            case .loaded:
                loadedList
            }
        }
        .navigationTitle("Inspect HK natation")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task { await refresh() }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .disabled(state == .loading)
                .accessibilityLabel("Rafraîchir")
            }
            ToolbarItem(placement: .topBarLeading) {
                if let exportURL {
                    ShareLink(item: exportURL) {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .accessibilityLabel("Exporter JSON")
                }
            }
        }
        .task {
            await refresh()
        }
    }

    // MARK: - Refresh

    private func refresh() async {
        state = .loading
        guard let service = deps?.healthKitService else {
            state = .refused
            return
        }
        // Ungated : garantit l'autorisation complète (workouts + natation + HR +
        // énergie) même après une demande partielle ou en Dev Login (workoutType).
        try? await service.requestSwimInspectionAuthorization()
        let fetched = await service.fetchRecentSwimWorkoutDetails(
            limit: fetchLimit,
            weeksBack: weeksBack
        )
        details = fetched
        exportURL = Self.writeExport(fetched)
        if fetched.isEmpty {
            // Diagnostic : distinguer vrai « 0 séance » d'un souci auth/sync/erreur.
            diagnostics = await service.diagnoseSwimFetch(weeksBack: weeksBack)
            // On ne peut pas distinguer refus vs vide côté READ HK (Apple ne révèle
            // pas les refus). Heuristique : si l'auth n'a jamais été demandée
            // (cas écran ouvert avant tout hook), traiter comme refus. Sinon vide.
            if !service.hasRequestedSwimAuthorization {
                state = .refused
            } else {
                state = .empty(reason: .noWorkouts)
            }
        } else {
            diagnostics = nil
            state = .loaded
        }
    }

    // MARK: - States

    private var refusedView: some View {
        VStack(spacing: 12) {
            Image(systemName: "lock.shield")
                .font(.system(size: 40))
                .foregroundStyle(Color.coachingTextSecondary)
            Text("Accès Apple Santé natation refusé.")
                .font(.coachingBody)
                .multilineTextAlignment(.center)
            Text("Réglages > Confidentialité > Santé > CoachingSage.")
                .font(.coachingCaption)
                .foregroundStyle(Color.coachingTextSecondary)
                .multilineTextAlignment(.center)
            authorizeButton
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    /// Re-déclenche la demande d'autorisation complète (ungated) puis recharge.
    /// Filet si la feuille système a été fermée/ratée, ou si seul `workoutType`
    /// reste `notDetermined` (cas Dev Login).
    private var authorizeButton: some View {
        Button {
            Task {
                if let service = deps?.healthKitService {
                    try? await service.requestSwimInspectionAuthorization()
                }
                await refresh()
            }
        } label: {
            Label("Autoriser l'accès Santé / Réessayer", systemImage: "heart.text.square")
                .font(.coachingBody)
        }
        .buttonStyle(.borderedProminent)
        .tint(Color.coachingPrimary)
        .padding(.top, 4)
    }

    private var emptyView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Aucune séance natation Apple Watch détectée sur les \(weeksBack) dernières semaines.")
                    .font(.coachingBody)

                if let diag = diagnostics {
                    diagnosticsPanel(diag)
                    authorizeButton
                }

                Text("Vérifie :")
                    .font(.coachingBody.bold())
                Text("1. Tu portes la Watch en piscine.")
                Text("2. Tu démarres le workout `Natation en bassin` sur la Watch.")
                Text("3. La Watch est bien synchronisée avec l'iPhone (ouvre l'app Santé sur l'iPhone et tire pour rafraîchir).")
            }
            .font(.coachingCaption)
            .foregroundStyle(Color.coachingTextSecondary)
            .padding()
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
    }

    @ViewBuilder
    private func diagnosticsPanel(_ diag: SwimFetchDiagnostics) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("🔬 Diagnostic")
                .font(.coachingBody.bold())
                .foregroundStyle(Color.coachingTextPrimary)
            diagLine("HK disponible", diag.healthDataAvailable ? "oui" : "NON")
            diagLine("Auth natation demandée", diag.hasRequestedSwimAuthorization ? "oui" : "non")
            diagLine("Auth workout (statut)", diag.workoutAuthStatus)
            diagLine("Workouts TOUS sports", "\(diag.allWorkoutsCount)")
            diagLine("Workouts natation", "\(diag.swimWorkoutsCount)")
            if let err = diag.swimQueryError {
                diagLine("Erreur requête", err)
            }
            if !diag.activityTypeCounts.isEmpty {
                diagLine("Types trouvés", formatActivityTypes(diag.activityTypeCounts))
            }
            // Lecture humaine du verdict.
            Text(diagVerdict(diag))
                .font(.coachingCaption.italic())
                .foregroundStyle(Color.coachingPrimary)
                .padding(.top, 2)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.coachingCard)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    @ViewBuilder
    private func diagLine(_ label: String, _ value: String) -> some View {
        HStack(alignment: .top, spacing: 6) {
            Text(label)
                .frame(width: 150, alignment: .leading)
            Text(value)
                .font(.coachingCaption.monospaced())
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func diagVerdict(_ diag: SwimFetchDiagnostics) -> String {
        if !diag.healthDataAvailable { return "→ HealthKit indisponible sur cet appareil." }
        if let err = diag.swimQueryError { return "→ La requête a échoué (\(err)) — probablement auth/sync, pas un vrai 0." }
        if diag.allWorkoutsCount == 0 {
            return diag.workoutAuthStatus == "notDetermined"
                ? "→ Aucun workout tous sports + auth jamais demandée : autorise l'accès Santé (workouts)."
                : "→ Aucun workout tous sports détecté : accès lecture workout non accordé OU pas encore synchronisé depuis la Watch."
        }
        if diag.swimWorkoutsCount == 0 {
            return "→ Des workouts existent mais aucun classé « natation » : vérifie le type d'activité sur la Watch (Natation en bassin / eau libre)."
        }
        return "→ Des séances natation existent — si la liste reste vide, c'est un bug de construction (à investiguer)."
    }

    private func formatActivityTypes(_ counts: [UInt: Int]) -> String {
        counts
            .sorted { $0.value > $1.value }
            .prefix(8)
            .map { "type \($0.key): \($0.value)" }
            .joined(separator: ", ")
    }

    private var loadedList: some View {
        List {
            Section {
                Text("\(details.count) séance(s) sur \(weeksBack) semaines")
                    .font(.coachingCaption)
                    .foregroundStyle(Color.coachingTextSecondary)
            }
            ForEach(details) { detail in
                Section {
                    workoutCard(detail)
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Color.coachingBackground)
    }

    // MARK: - Workout card

    @ViewBuilder
    private func workoutCard(_ detail: HealthKitSwimWorkoutDetail) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(relativeDate(detail.endDate))
                    .font(.coachingH2)
                Spacer()
                if detail.appleWatchDetected {
                    Label("Watch", systemImage: "applewatch")
                        .font(.coachingCaption)
                        .foregroundStyle(Color.coachingPrimary)
                }
            }

            HStack(spacing: 12) {
                statBlock("Durée", formatDuration(detail.durationSeconds))
                statBlock("Distance", formatDistance(detail.totalDistanceMeters))
                statBlock("Strokes", detail.totalStrokes.map { String($0) } ?? "—")
            }

            HStack(spacing: 12) {
                statBlock("HR moy", detail.averageHeartRateBpm.map { "\($0) bpm" } ?? "—")
                statBlock("HR min", detail.minHeartRateBpm.map { "\($0) bpm" } ?? "—")
                statBlock("HR max", detail.maxHeartRateBpm.map { "\($0) bpm" } ?? "—")
            }

            HStack(spacing: 12) {
                statBlock("Énergie act.", detail.activeEnergyKcal.map { String(format: "%.0f kcal", $0) } ?? "—")
                statBlock("Énergie tot.", detail.totalEnergyKcal.map { String(format: "%.0f kcal", $0) } ?? "—")
                statBlock("METs", detail.averageMETs.map { String(format: "%.1f", $0) } ?? "—")
            }

            HStack(spacing: 12) {
                statBlock("Bassin", formatPoolLength(detail.poolLengthMeters))
                statBlock("Lieu", formatLocation(detail.swimLocationType))
                statBlock("Indoor", detail.isIndoorWorkout.map { $0 ? "Oui" : "Non" } ?? "—")
            }

            if let device = detail.deviceDescription {
                metaLine("Device", device)
            }
            if let source = detail.sourceDescription {
                metaLine("Source", source)
            }
            if let product = detail.sourceProductType {
                metaLine("Product", product)
            }
            if let tz = detail.timeZoneIdentifier {
                metaLine("Fuseau", tz)
            }
            if !detail.eventCounts.isEmpty {
                metaLine("Events", formatEventCounts(detail.eventCounts))
            }
        }

        // Laps
        if detail.laps.isEmpty {
            Text(emptyLapsMessage(for: detail))
                .font(.coachingCaption)
                .foregroundStyle(Color.coachingTextSecondary)
                .padding(.vertical, 4)
        } else {
            DisclosureGroup("\(detail.laps.count) lap(s)") {
                lapHeaderRow
                ForEach(detail.laps, id: \.index) { lap in
                    lapRow(lap)
                }
            }
            .font(.coachingBody)
        }

        // Dump brut — ne rien cacher de ce que la Watch a écrit.
        if !detail.rawMetadata.isEmpty {
            DisclosureGroup("🔬 Metadata brut (\(detail.rawMetadata.count))") {
                ForEach(detail.rawMetadata) { entry in
                    rawRow(entry)
                }
            }
            .font(.coachingBody)
        }
        if !detail.rawStatistics.isEmpty {
            DisclosureGroup("🔬 Statistics brut (\(detail.rawStatistics.count))") {
                ForEach(detail.rawStatistics) { entry in
                    rawRow(entry)
                }
            }
            .font(.coachingBody)
        }
    }

    @ViewBuilder
    private func metaLine(_ label: String, _ value: String) -> some View {
        HStack(alignment: .top, spacing: 6) {
            Text(label)
                .font(.coachingCaption)
                .foregroundStyle(Color.coachingTextSecondary)
                .frame(width: 70, alignment: .leading)
            Text(value)
                .font(.coachingCaption)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    private func rawRow(_ entry: HealthKitRawEntry) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(entry.key)
                .font(.coachingCaption.monospaced())
                .foregroundStyle(Color.coachingTextSecondary)
            Text(entry.value)
                .font(.coachingCaption.monospaced())
                .textSelection(.enabled)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 1)
    }

    private var lapHeaderRow: some View {
        HStack(spacing: 8) {
            Text("#").font(.coachingCaption.bold()).frame(width: 32, alignment: .leading)
            Text("Nage").font(.coachingCaption.bold()).frame(width: 64, alignment: .leading)
            Text("Pace").font(.coachingCaption.bold()).frame(width: 62, alignment: .trailing)
            Text("Str").font(.coachingCaption.bold()).frame(width: 32, alignment: .trailing)
            Text("SWOLF").font(.coachingCaption.bold()).frame(width: 44, alignment: .trailing)
            Text("HR").font(.coachingCaption.bold()).frame(width: 34, alignment: .trailing)
            Text("Repos").font(.coachingCaption.bold()).frame(width: 44, alignment: .trailing)
        }
        .foregroundStyle(Color.coachingTextSecondary)
    }

    @ViewBuilder
    private func statBlock(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.coachingCaption)
                .foregroundStyle(Color.coachingTextSecondary)
            Text(value)
                .font(.coachingBody)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func lapRow(_ lap: HealthKitSwimLap) -> some View {
        HStack(spacing: 8) {
            Text("\(lap.index)")
                .font(.coachingCaption.monospacedDigit())
                .foregroundStyle(Color.coachingTextSecondary)
                .frame(width: 32, alignment: .leading)
            Text(strokeLabel(lap.strokeStyle))
                .font(.coachingCaption)
                .frame(width: 64, alignment: .leading)
            Text(lap.paceSecondsPer100m.map { formatPaceShort($0) } ?? "—")
                .font(.coachingCaption.monospacedDigit())
                .frame(width: 62, alignment: .trailing)
            Text(lap.strokeCount.map { String($0) } ?? "—")
                .font(.coachingCaption.monospacedDigit())
                .frame(width: 32, alignment: .trailing)
            Text(lap.swolfScore.map { String($0) } ?? "—")
                .font(.coachingCaption.monospacedDigit())
                .frame(width: 44, alignment: .trailing)
            Text(lap.averageHeartRateBpm.map { "\($0)" } ?? "—")
                .font(.coachingCaption.monospacedDigit())
                .foregroundStyle(Color.coachingTextSecondary)
                .frame(width: 34, alignment: .trailing)
            Text(lap.restAfterSeconds.map { String(format: "%.0fs", $0) } ?? "—")
                .font(.coachingCaption.monospacedDigit())
                .foregroundStyle(Color.coachingTextSecondary)
                .frame(width: 44, alignment: .trailing)
        }
        .padding(.vertical, 2)
    }

    // MARK: - Formatters

    private func relativeDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    private func formatDuration(_ seconds: TimeInterval) -> String {
        let total = Int(seconds.rounded())
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        if h > 0 {
            return String(format: "%dh %02dm", h, m)
        } else {
            return String(format: "%dm %02ds", m, s)
        }
    }

    private func formatDistance(_ meters: Double?) -> String {
        guard let meters else { return "—" }
        return String(format: "%.0f m", meters)
    }

    private func formatPoolLength(_ meters: Double?) -> String {
        guard let meters else { return "—" }
        return String(format: "%.0f m", meters)
    }

    private func formatPace(_ secondsPer100m: Double) -> String {
        let total = Int(secondsPer100m.rounded())
        let m = total / 60
        let s = total % 60
        return String(format: "%d:%02d/100m", m, s)
    }

    private func formatEventCounts(_ counts: [String: Int]) -> String {
        counts
            .sorted { $0.key < $1.key }
            .map { "\($0.key): \($0.value)" }
            .joined(separator: ", ")
    }

    private func formatPaceShort(_ secondsPer100m: Double) -> String {
        let total = Int(secondsPer100m.rounded())
        return String(format: "%d:%02d", total / 60, total % 60)
    }

    private func formatLocation(_ location: SwimLocationType?) -> String {
        guard let location else { return "—" }
        switch location {
        case .pool: return "Bassin"
        case .openWater: return "Eau libre"
        case .unknown: return "—"
        }
    }

    private func strokeLabel(_ style: SwimStrokeStyle?) -> String {
        guard let style else { return "—" }
        switch style {
        case .unknown: return "—"
        case .mixed: return "Mixed"
        case .freestyle: return "Crawl"
        case .backstroke: return "Dos"
        case .breaststroke: return "Brasse"
        case .butterfly: return "Papillon"
        case .kickboard: return "Kickboard"
        }
    }

    private func emptyLapsMessage(for detail: HealthKitSwimWorkoutDetail) -> String {
        switch detail.swimLocationType {
        case .openWater:
            return "Eau libre — pas de découpage lap (normal sur ce type de workout)."
        case .pool:
            return "Bassin — aucun lap détecté par la Watch (vérifie que tu as démarré l'activité Natation en bassin sur la Watch)."
        case .unknown, .none:
            return "Pas de découpage lap disponible."
        }
    }

    // MARK: - Export JSON

    /// Sérialise l'intégralité des détails (séances + laps + dump brut) en JSON
    /// pretty-printed dans un fichier temporaire, partageable via ShareLink
    /// (AirDrop vers Mac). Retourne `nil` si rien à exporter ou échec d'écriture.
    private static func writeExport(_ details: [HealthKitSwimWorkoutDetail]) -> URL? {
        guard !details.isEmpty else { return nil }
        let iso = ISO8601DateFormatter()

        func lapDict(_ lap: HealthKitSwimLap) -> [String: Any] {
            [
                "index": lap.index,
                "startDate": iso.string(from: lap.startDate),
                "durationSeconds": lap.durationSeconds,
                "distanceMeters": lap.distanceMeters as Any,
                "strokeStyle": lap.strokeStyle.map { String(describing: $0) } as Any,
                "paceSecondsPer100m": lap.paceSecondsPer100m as Any,
                "averageHeartRateBpm": lap.averageHeartRateBpm as Any,
                "minHeartRateBpm": lap.minHeartRateBpm as Any,
                "maxHeartRateBpm": lap.maxHeartRateBpm as Any,
                "strokeCount": lap.strokeCount as Any,
                "swolfScore": lap.swolfScore as Any,
                "restAfterSeconds": lap.restAfterSeconds as Any
            ]
        }

        func workoutDict(_ d: HealthKitSwimWorkoutDetail) -> [String: Any] {
            [
                "id": d.id.uuidString,
                "startDate": iso.string(from: d.startDate),
                "endDate": iso.string(from: d.endDate),
                "durationSeconds": d.durationSeconds,
                "totalDistanceMeters": d.totalDistanceMeters as Any,
                "totalStrokes": d.totalStrokes as Any,
                "averageHeartRateBpm": d.averageHeartRateBpm as Any,
                "minHeartRateBpm": d.minHeartRateBpm as Any,
                "maxHeartRateBpm": d.maxHeartRateBpm as Any,
                "activeEnergyKcal": d.activeEnergyKcal as Any,
                "totalEnergyKcal": d.totalEnergyKcal as Any,
                "averageMETs": d.averageMETs as Any,
                "poolLengthMeters": d.poolLengthMeters as Any,
                "swimLocationType": d.swimLocationType.map { String(describing: $0) } as Any,
                "sourceProductType": d.sourceProductType as Any,
                "appleWatchDetected": d.appleWatchDetected,
                "deviceDescription": d.deviceDescription as Any,
                "sourceDescription": d.sourceDescription as Any,
                "isIndoorWorkout": d.isIndoorWorkout as Any,
                "timeZoneIdentifier": d.timeZoneIdentifier as Any,
                "eventCounts": d.eventCounts,
                "rawMetadata": Dictionary(d.rawMetadata.map { ($0.key, $0.value) }) { a, _ in a },
                "rawStatistics": Dictionary(d.rawStatistics.map { ($0.key, $0.value) }) { a, _ in a },
                "laps": d.laps.map(lapDict)
            ]
        }

        let root: [String: Any] = [
            "exportedAt": iso.string(from: Date()),
            "weeksBack": 12,
            "workoutCount": details.count,
            "workouts": details.map(workoutDict)
        ]

        guard JSONSerialization.isValidJSONObject(root),
              let data = try? JSONSerialization.data(withJSONObject: root, options: [.prettyPrinted, .sortedKeys])
        else { return nil }

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("swim_hk_export.json")
        do {
            try data.write(to: url, options: .atomic)
            return url
        } catch {
            return nil
        }
    }
}

#Preview {
    NavigationStack {
        SwimHealthKitInspectorView()
    }
}
#endif
