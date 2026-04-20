import Foundation
import Combine
import CoreLocation
import UIKit

/// CoreLocation tracking service for the CoachingSage Spike 0.1.
///
/// Goal of the spike : validate that we can track GPS reliably in the background
/// (Apple Watch Workout-style) — for tracking endurance sessions in CoachingSage.
///
/// What this service measures during a walk/run :
/// - Number of GPS points captured
/// - Total distance (filtered to ignore obvious outliers)
/// - Average accuracy
/// - First-fix latency (time to first reliable point)
/// - Elapsed time
/// - Battery level at start vs at end
/// - Whether tracking survived being put in background
///
/// Production version of this service will live in `Services/Tracking/LocationService.swift`
/// and feed an EnduranceTrackingEngine for CoachingSage Epic 4.
@MainActor
final class LocationService: NSObject, ObservableObject {

    // MARK: - State

    @Published private(set) var status: TrackingStatus = .idle
    @Published private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published private(set) var lastError: String?

    // Live stats
    @Published var points: [TrackedPoint] = []
    @Published var totalDistanceMeters: Double = 0
    @Published var averageAccuracy: Double = 0
    @Published var firstFixSeconds: Double?
    @Published var elapsedSeconds: Double = 0
    @Published var batteryLevelStart: Double?
    @Published var batteryLevelNow: Double?
    @Published var lastUpdate: Date?
    @Published var backgroundUpdatesAllowed: Bool = false
    @Published var didEnterBackground: Bool = false
    @Published var crashedOrKilled: Bool = false

    enum TrackingStatus: String {
        case idle = "Inactif"
        case waitingFix = "Acquisition GPS..."
        case tracking = "Tracking actif"
        case paused = "En pause"
    }

    struct TrackedPoint: Identifiable {
        let id = UUID()
        let coordinate: CLLocationCoordinate2D
        let timestamp: Date
        let horizontalAccuracy: Double
        let speed: Double
        let altitude: Double
    }

    // MARK: - Internals

    private let locationManager = CLLocationManager()
    private var startDate: Date?
    private var elapsedTimer: Timer?
    private var lastValidPoint: CLLocation?

    /// Accumulated duration spent in paused state, to exclude from the "active tracking time".
    private var accumulatedPauseSeconds: TimeInterval = 0
    /// Timestamp of the current pause start (nil if not currently paused).
    private var pauseStartDate: Date?

    /// Filter : reject points with horizontal accuracy worse than this (meters)
    private let maxAcceptableAccuracy: Double = 25.0

    /// Filter : reject points that imply impossible speed between updates
    /// (jump > 50m/s = 180 km/h between 2 points = obvious error)
    private let maxRealisticSpeedMps: Double = 50.0

    // MARK: - Init

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .fitness
        locationManager.distanceFilter = 5.0  // Update every ~5m
        locationManager.pausesLocationUpdatesAutomatically = false  // We want continuous

        UIDevice.current.isBatteryMonitoringEnabled = true

        // Check if tracking was interrupted (crash or kill detection)
        if UserDefaults.standard.bool(forKey: "spike_was_tracking") {
            crashedOrKilled = true
            UserDefaults.standard.set(false, forKey: "spike_was_tracking")
        }
    }

    deinit {
        elapsedTimer?.invalidate()
    }

    // MARK: - Public API

    func requestAuthorization() {
        // For background tracking we need "Always" authorization.
        // The proper flow is : request WhenInUse first, then upgrade to Always once user is engaged.
        // For the spike we go straight to Always since we're testing background.
        locationManager.requestWhenInUseAuthorization()
    }

    func upgradeToAlwaysAuthorization() {
        locationManager.requestAlwaysAuthorization()
    }

    /// Starts tracking. Handles two scenarios :
    /// - Fresh start (from .idle) : resets all data and starts a new session
    /// - Resume (from .paused) : keeps existing data, only re-engages the GPS
    ///
    /// Designed to support day-long tests with multiple pauses (commute → office → lunch walk → office → commute home).
    func startTracking() {
        guard status == .idle || status == .paused else { return }

        let isResume = (status == .paused)

        if !isResume {
            // Fresh start : reset everything
            points.removeAll()
            totalDistanceMeters = 0
            averageAccuracy = 0
            firstFixSeconds = nil
            elapsedSeconds = 0
            accumulatedPauseSeconds = 0
            pauseStartDate = nil
            lastValidPoint = nil
            lastError = nil
            didEnterBackground = false

            startDate = Date()
            batteryLevelStart = Double(UIDevice.current.batteryLevel)
            batteryLevelNow = batteryLevelStart

            // Mark as tracking for crash detection
            UserDefaults.standard.set(true, forKey: "spike_was_tracking")
        } else {
            // Resume : accumulate the pause we just ended
            if let pauseStart = pauseStartDate {
                accumulatedPauseSeconds += Date().timeIntervalSince(pauseStart)
                pauseStartDate = nil
            }
            // Keep lastValidPoint so the next point doesn't get an impossible speed
            // (we reset it here because a long pause will make the speed look instant-jump)
            lastValidPoint = nil
        }

        // Enable background updates (requires Always auth + Background Modes capability)
        if authorizationStatus == .authorizedAlways {
            locationManager.allowsBackgroundLocationUpdates = true
            backgroundUpdatesAllowed = true
        } else {
            backgroundUpdatesAllowed = false
        }

        // Show iOS blue bar when in background
        locationManager.showsBackgroundLocationIndicator = true

        status = .waitingFix
        locationManager.startUpdatingLocation()

        // Timer to update elapsed time UI
        elapsedTimer?.invalidate()
        elapsedTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self, let start = self.startDate else { return }
                // Active tracking time = wall clock - total pause time
                self.elapsedSeconds = Date().timeIntervalSince(start) - self.accumulatedPauseSeconds
                self.batteryLevelNow = Double(UIDevice.current.batteryLevel)
            }
        }
    }

    /// Pauses tracking. Data is preserved. Call startTracking() again to resume.
    func pauseTracking() {
        guard status == .tracking || status == .waitingFix else { return }
        locationManager.stopUpdatingLocation()
        elapsedTimer?.invalidate()
        elapsedTimer = nil
        pauseStartDate = Date()
        status = .paused
    }

    /// Stops tracking and terminates the session. Data is kept in memory until a fresh startTracking() resets it.
    func stopTracking() {
        // If we're stopping while paused, finalize the last pause accumulation
        if let pauseStart = pauseStartDate {
            accumulatedPauseSeconds += Date().timeIntervalSince(pauseStart)
            pauseStartDate = nil
        }
        locationManager.stopUpdatingLocation()
        locationManager.allowsBackgroundLocationUpdates = false
        elapsedTimer?.invalidate()
        elapsedTimer = nil
        status = .idle
        UserDefaults.standard.set(false, forKey: "spike_was_tracking")
    }

    // MARK: - Notifications

    func appDidEnterBackground() {
        if status == .tracking || status == .waitingFix {
            didEnterBackground = true
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationService: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            self.authorizationStatus = manager.authorizationStatus
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Capture locations on the delegate's queue, then hop to MainActor
        let received = locations
        Task { @MainActor in
            for loc in received {
                self.process(location: loc)
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            self.lastError = "Erreur GPS : \(error.localizedDescription)"
        }
    }

    @MainActor
    private func process(location: CLLocation) {
        // Reject points with bad accuracy
        guard location.horizontalAccuracy > 0,
              location.horizontalAccuracy <= maxAcceptableAccuracy else {
            return
        }
        // Reject very old cached points
        let age = Date().timeIntervalSince(location.timestamp)
        guard age < 5.0 else { return }

        // First fix detection
        if firstFixSeconds == nil, let start = startDate {
            firstFixSeconds = Date().timeIntervalSince(start)
            status = .tracking
        }

        // Distance from previous valid point (with speed sanity check)
        if let last = lastValidPoint {
            let dt = location.timestamp.timeIntervalSince(last.timestamp)
            let dist = location.distance(from: last)
            if dt > 0 {
                let speed = dist / dt
                if speed <= maxRealisticSpeedMps {
                    totalDistanceMeters += dist
                }
                // else: GPS jump, ignore
            }
        }
        lastValidPoint = location

        // Save the point
        let point = TrackedPoint(
            coordinate: location.coordinate,
            timestamp: location.timestamp,
            horizontalAccuracy: location.horizontalAccuracy,
            speed: max(0, location.speed),
            altitude: location.altitude
        )
        points.append(point)

        // Average accuracy (running average)
        let totalAccuracy = points.map { $0.horizontalAccuracy }.reduce(0, +)
        averageAccuracy = totalAccuracy / Double(points.count)

        lastUpdate = Date()
    }
}
