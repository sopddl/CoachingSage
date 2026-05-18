// Coaching/Regen/RegenInputsBuilder.swift
// Story 3.4 Phase B.3 — implémentation `WeeklyRegenInputsProviding` (seam Phase B.2).
//
// Assemble le contexte runtime nécessaire à `WeeklyRegenEngine.regenerate(...)` :
//   - sessions de S (filtre `record.sessions` par weekNumber)
//   - workouts HK live (2 sem retour, tous sports — filter sport côté engine)
//   - previousReports S-1, S-2, S-3 via `WeeklyRegenRepository`
//   - daysSinceLastWorkout (min `daysAgo` sur tous les workouts HK)
//   - hrMax : `maxObservedHeartRateBpm` si dispo, sinon estimation `220 - age`
//
// Retourne `nil` si les sessions de S sont vides (cas dégénéré : analyzedWeek
// hors range du programme → rien à analyser).
//
// Pur orchestrateur : aucune mutation, aucun side-effect (le service Phase B.2
// applique la décision et persiste). Async pour les lectures HK + SwiftData.
import Foundation
import TemplateModel

@MainActor
final class RegenInputsBuilder: WeeklyRegenInputsProviding {

    /// Fallback `hrMax` quand l'âge ET le maxObservedHeartRate sont indisponibles.
    /// 180 BPM correspond approximativement à un adulte 40 ans (220-40).
    /// Volontairement conservateur pour ne pas surestimer les zones cardio
    /// d'un user dont on n'a aucune donnée.
    static let defaultHRMax: Int = 180

    /// Fenêtre HK à requêter (en semaines) pour englober la semaine analysée
    /// + tolérance ±2j de `WorkoutMatcher`. 2 sem couvre largement la semaine S
    /// quel que soit le décalage entre `now` et `weekStartDate(S)`.
    static let healthKitWeeksBack: Int = 2

    /// Plafond de workouts HK à récupérer (typiquement ≤ 14 pour 2 sem actives).
    static let healthKitWorkoutLimit: Int = 50

    /// Nombre de rapports précédents à charger pour le `PauseDetector`.
    /// 3 suffit (au-delà la doctrine ACSM bascule déjà en `.extended`).
    static let previousReportsLimit: Int = 3

    private let healthKit: HealthKitServiceProtocol
    private let regenRepository: WeeklyRegenRepository
    private let coachingProfileRepository: CoachingProfileRepository
    private let calendar: Calendar

    init(
        healthKit: HealthKitServiceProtocol,
        regenRepository: WeeklyRegenRepository,
        coachingProfileRepository: CoachingProfileRepository,
        calendar: Calendar = .current
    ) {
        self.healthKit = healthKit
        self.regenRepository = regenRepository
        self.coachingProfileRepository = coachingProfileRepository
        self.calendar = calendar
    }

    // MARK: - WeeklyRegenInputsProviding

    func makeDecision(
        for record: AdaptedProgramRecord,
        analyzedWeekNumber: Int,
        now: Date
    ) async throws -> WeeklyRegenDecision? {
        // Garde semaine valide : S ≥ 1.
        guard analyzedWeekNumber >= 1 else { return nil }

        // **Story 3.10** : programme dormant (`weekStartDate == nil`) → pas de
        // semaine close à analyser. Skip silencieux (no-op).
        guard let programStart = record.weekStartDate else { return nil }

        let sessionsOfAnalyzedWeek = record.sessions.filter { $0.weekNumber == analyzedWeekNumber }
        guard !sessionsOfAnalyzedWeek.isEmpty else { return nil }

        let weekStartOfAnalyzed = weekStartDate(
            of: analyzedWeekNumber,
            programStart: programStart
        )

        // Lectures en parallèle : HK workouts + previousReports.
        async let workoutDetails = healthKit.fetchRecentWorkoutDetails(
            limit: Self.healthKitWorkoutLimit,
            weeksBack: Self.healthKitWeeksBack
        )
        async let previousSnapshots = regenRepository.fetchReports(
            recordId: record.id,
            before: analyzedWeekNumber,
            limit: Self.previousReportsLimit
        )
        let details = await workoutDetails
        let snapshots = try await previousSnapshots

        let snapshots_ = snapshots // capture pour reconstruct
        let previousReports = snapshots_.map { WeeklyExecutionReport.from(snapshot: $0) }
        let workouts = details.map { DefaultHealthSummaryBuilder.toSnapshot($0) }
        let daysSinceLastWorkout = details.compactMap { $0.daysAgo }.min()

        let hrMax = try await resolveHRMax(maxObservedFromHK: details.compactMap(\.maxHeartRateBpm).max())

        return WeeklyRegenEngine.regenerate(
            weekNumber: analyzedWeekNumber,
            weekStartDate: weekStartOfAnalyzed,
            sessions: sessionsOfAnalyzedWeek,
            sportCode: record.sportCode,
            workouts: workouts,
            hrMax: hrMax,
            previousReports: previousReports,
            daysSinceLastWorkout: daysSinceLastWorkout,
            now: now
        )
    }

    // MARK: - Helpers

    /// Lundi 00:00 de la semaine `weekNumber` (1-indexed depuis `programStart`).
    /// `programStart` est déjà le lundi 00:00 de S1 (cf `AdaptedProgramRecord.startOfCurrentWeek`).
    func weekStartDate(of weekNumber: Int, programStart: Date) -> Date {
        guard weekNumber > 1 else { return programStart }
        return calendar.date(byAdding: .day, value: (weekNumber - 1) * 7, to: programStart) ?? programStart
    }

    /// Résout l'hrMax du user. Priorité au `maxObservedHeartRateBpm` (mesure réelle
    /// Apple Watch — plus fiable que la formule), fallback `220 - age`, fallback
    /// `defaultHRMax` si l'âge n'est pas connu.
    private func resolveHRMax(maxObservedFromHK: Int?) async throws -> Int {
        if let observed = maxObservedFromHK, observed > 60 {
            return observed
        }
        guard let profile = try await coachingProfileRepository.fetchCurrentProfile(),
              let dob = profile.dateOfBirth else {
            return Self.defaultHRMax
        }
        let ageComponents = calendar.dateComponents([.year], from: dob, to: Date())
        guard let age = ageComponents.year, age > 0, age < 120 else {
            return Self.defaultHRMax
        }
        return 220 - age
    }
}
