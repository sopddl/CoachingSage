// CoachingSageTests/Coaching/Swim/SwimSummaryBuilderTests.swift
// Story 3.16 Phase 2.A — tests de la logique pure d'agrégat natation.
import XCTest
@testable import CoachingSage

final class SwimSummaryBuilderTests: XCTestCase {

    // MARK: - Fixtures

    private func lap(
        _ index: Int,
        dur: TimeInterval = 30,
        dist: Double? = 25,
        style: SwimStrokeStyle? = .freestyle,
        pace: Double? = 120,
        strokes: Int? = 18,
        swolf: Int? = 48,
        rest: TimeInterval? = 1
    ) -> HealthKitSwimLap {
        HealthKitSwimLap(
            index: index,
            startDate: Date(timeIntervalSince1970: TimeInterval(1_700_000_000 + index * 40)),
            durationSeconds: dur,
            distanceMeters: dist,
            strokeStyle: style,
            paceSecondsPer100m: pace,
            averageHeartRateBpm: nil,
            strokeCount: strokes,
            minHeartRateBpm: nil,
            maxHeartRateBpm: nil,
            swolfScore: swolf,
            restAfterSeconds: rest
        )
    }

    private func workout(
        id: UUID = UUID(),
        daysAgo: Int = 1,
        dist: Double? = 1000,
        hr: Int? = 128,
        kcal: Double? = 300,
        laps: [HealthKitSwimLap]
    ) -> HealthKitSwimWorkoutDetail {
        let start = Date(timeIntervalSince1970: 1_700_000_000 - TimeInterval(daysAgo * 86_400))
        return HealthKitSwimWorkoutDetail(
            id: id,
            startDate: start,
            endDate: start.addingTimeInterval(2400),
            durationSeconds: 2400,
            totalDistanceMeters: dist,
            totalStrokes: 700,
            averageHeartRateBpm: hr,
            maxHeartRateBpm: 142,
            minHeartRateBpm: 110,
            activeEnergyKcal: kcal,
            totalEnergyKcal: kcal.map { $0 + 50 },
            averageMETs: 8.5,
            poolLengthMeters: 25,
            swimLocationType: .pool,
            sourceProductType: "Watch6,16",
            appleWatchDetected: true,
            deviceDescription: "Apple Watch",
            sourceDescription: "Watch",
            isIndoorWorkout: false,
            timeZoneIdentifier: "Europe/Paris",
            eventCounts: ["lap": laps.count],
            laps: laps,
            rawMetadata: [],
            rawStatistics: []
        )
    }

    // MARK: - Détection de séries

    func testDetectSets_splitsOnRestAboveThreshold() {
        // 2 longueurs (repos 1s), grosse pause 18s, 2 longueurs → 2 séries.
        let laps = [
            lap(1, rest: 1),
            lap(2, rest: 18),   // ferme la série 1
            lap(3, rest: 1),
            lap(4, rest: nil)   // fin → ferme la série 2
        ]
        let sets = SwimSummaryBuilder.detectSets(laps: laps, restThreshold: 10)
        XCTAssertEqual(sets.count, 2)
        XCTAssertEqual(sets[0].lapCount, 2)
        XCTAssertEqual(sets[0].restAfterSeconds, 18)
        XCTAssertEqual(sets[1].lapCount, 2)
        XCTAssertNil(sets[1].restAfterSeconds)
    }

    func testDetectSets_continuousSwim_singleSet() {
        let laps = (1...8).map { lap($0, rest: 1) }
        let sets = SwimSummaryBuilder.detectSets(laps: laps, restThreshold: 10)
        XCTAssertEqual(sets.count, 1)
        XCTAssertEqual(sets[0].lapCount, 8)
        XCTAssertEqual(sets[0].distanceMeters, 200) // 8 × 25
    }

    func testDetectSets_emptyLaps_returnsEmpty() {
        XCTAssertTrue(SwimSummaryBuilder.detectSets(laps: [], restThreshold: 10).isEmpty)
    }

    func testDetectSets_restExactlyAtThreshold_closesSet() {
        // rest == seuil (10) doit fermer la série (>=).
        let laps = [lap(1, rest: 10), lap(2, rest: nil)]
        let sets = SwimSummaryBuilder.detectSets(laps: laps, restThreshold: 10)
        XCTAssertEqual(sets.count, 2)
        XCTAssertEqual(sets[0].lapCount, 1)
        XCTAssertEqual(sets[0].restAfterSeconds, 10)
    }

    func testDetectSets_nilRestMidSet_staysInSameSet() {
        // rest nil au milieu ne coupe pas ; seul le repos 18s coupe.
        let laps = [lap(1, rest: 1), lap(2, rest: nil), lap(3, rest: 18), lap(4, rest: nil)]
        let sets = SwimSummaryBuilder.detectSets(laps: laps, restThreshold: 10)
        XCTAssertEqual(sets.count, 2)
        XCTAssertEqual(sets[0].lapCount, 3)
        XCTAssertEqual(sets[1].lapCount, 1)
    }

    func testDetectSets_allBigRests_eachLapOwnSet() {
        let laps = (1...4).map { lap($0, rest: 20) }
        let sets = SwimSummaryBuilder.detectSets(laps: laps, restThreshold: 10)
        XCTAssertEqual(sets.count, 4)
        XCTAssertTrue(sets.allSatisfy { $0.lapCount == 1 })
    }

    // MARK: - Pace exclut kick / unknown

    func testSessionPace_excludesKickboardAndUnknown() {
        let laps = [
            lap(1, style: .freestyle, pace: 120),
            lap(2, style: .freestyle, pace: 140),
            lap(3, style: .kickboard, pace: 300),   // exclu
            lap(4, style: .unknown, pace: 999)      // exclu
        ]
        let s = SwimSummaryBuilder.summarizeSession(workout(laps: laps))
        // Moyenne sur freestyle uniquement = (120+140)/2 = 130
        XCTAssertEqual(try XCTUnwrap(s.avgPaceSecondsPer100m), 130, accuracy: 0.01)
        XCTAssertEqual(try XCTUnwrap(s.bestLapPaceSecondsPer100m), 120, accuracy: 0.01)
    }

    func testSessionStrokeDistribution_andDominant() {
        let laps = [
            lap(1, style: .freestyle),
            lap(2, style: .freestyle),
            lap(3, style: .freestyle),
            lap(4, style: .kickboard)
        ]
        let s = SwimSummaryBuilder.summarizeSession(workout(laps: laps))
        XCTAssertEqual(s.strokeDistribution[.freestyle], 3)
        XCTAssertEqual(s.strokeDistribution[.kickboard], 1)
        XCTAssertEqual(s.dominantStroke, .freestyle)
    }

    func testSession_noLapsButDistance_paceNil_distancePreserved() {
        // Open water / app tierce : pas de laps mais distance totale présente.
        let s = SwimSummaryBuilder.summarizeSession(workout(dist: 1500, laps: []))
        XCTAssertNil(s.avgPaceSecondsPer100m)
        XCTAssertNil(s.bestLapPaceSecondsPer100m)
        XCTAssertNil(s.dominantStroke)
        XCTAssertTrue(s.sets.isEmpty)
        XCTAssertEqual(s.totalDistanceMeters, 1500)
    }

    func testSession_fullKickboard_paceNil_noDominant() {
        let laps = (1...4).map { lap($0, style: .kickboard, pace: 300) }
        let s = SwimSummaryBuilder.summarizeSession(workout(laps: laps))
        XCTAssertNil(s.avgPaceSecondsPer100m)
        XCTAssertNil(s.bestLapPaceSecondsPer100m)
        // dominantStroke exclut unknown mais kickboard reste un contenu valide.
        XCTAssertEqual(s.dominantStroke, .kickboard)
        XCTAssertEqual(s.strokeDistribution[.kickboard], 4)
    }

    func testBestPace_excludesPartialLapBelowFloor() {
        // Push-off tronqué : 5 m en 6 s → pace ultra-rapide mais < 90% de 25m.
        let laps = [
            lap(1, dist: 25, style: .freestyle, pace: 120),
            lap(2, dist: 5,  style: .freestyle, pace: 50)   // partiel → écarté du best
        ]
        let s = SwimSummaryBuilder.summarizeSession(workout(laps: laps))
        XCTAssertEqual(try XCTUnwrap(s.bestLapPaceSecondsPer100m), 120, accuracy: 0.01)
    }

    func testDominantStroke_excludesUnknown() {
        let laps = [
            lap(1, style: .unknown),
            lap(2, style: .unknown),
            lap(3, style: .breaststroke)
        ]
        let s = SwimSummaryBuilder.summarizeSession(workout(laps: laps))
        // unknown majoritaire en count mais exclu → breaststroke dominant.
        XCTAssertEqual(s.dominantStroke, .breaststroke)
    }

    func testSessionHR_isSessionLevel_notPerLap() {
        // Tous les laps sans HR, mais la séance a un HR niveau séance.
        let laps = (1...4).map { lap($0) }
        let s = SwimSummaryBuilder.summarizeSession(workout(hr: 125, laps: laps))
        XCTAssertEqual(s.averageHeartRateBpm, 125)
    }

    // MARK: - Agrégat fenêtre

    func testBuild_aggregatesAcrossSessions() {
        let w1 = workout(daysAgo: 2, dist: 1000, laps: (1...4).map { lap($0, pace: 120) })
        let w2 = workout(daysAgo: 9, dist: 1500, laps: (1...4).map { lap($0, pace: 130) })
        let summary = SwimSummaryBuilder.build(from: [w2, w1], windowWeeks: 12)

        XCTAssertEqual(summary.sessionCount, 2)
        XCTAssertEqual(summary.totalDistanceMeters, 2500)
        XCTAssertEqual(summary.weeklyAverageDistanceMeters, 2500.0 / 12.0, accuracy: 0.01)
        // Ordre antéchrono : w1 (2j) avant w2 (9j).
        XCTAssertEqual(summary.sessions.first?.date, w1.startDate)
        // Pace pondérée distance : (120×1000 + 130×1500)/2500 = 126
        XCTAssertEqual(try XCTUnwrap(summary.avgPaceSecondsPer100m), 126, accuracy: 0.01)
        XCTAssertEqual(try XCTUnwrap(summary.bestPaceSecondsPer100m), 120, accuracy: 0.01)
        XCTAssertEqual(summary.longestSessionDistanceMeters, 1500)
    }

    func testBuild_empty_returnsEmpty() {
        XCTAssertEqual(SwimSummaryBuilder.build(from: [], windowWeeks: 12), .empty)
    }
}
