// CoachingSageTests/AutoProfile/AutoProfileInferenceTests.swift
// Story Autoprofil HealthKit (Epic 3 Phase 2 #4)
import XCTest

final class AutoProfileInferenceTests: XCTestCase {

    private let sut = AutoProfileInference()

    // MARK: - inferLevel via VO2max

    func testInferLevelBeginnerWhenVO2MaxBelow35() {
        XCTAssertEqual(sut.inferLevel(vo2Max: 28, sportCode: "running"), .beginner)
        XCTAssertEqual(sut.inferLevel(vo2Max: 34.9, sportCode: "running"), .beginner)
    }

    func testInferLevelRecreationalWhenVO2Max35to43() {
        XCTAssertEqual(sut.inferLevel(vo2Max: 35, sportCode: "running"), .recreational)
        XCTAssertEqual(sut.inferLevel(vo2Max: 40, sportCode: "running"), .recreational)
        XCTAssertEqual(sut.inferLevel(vo2Max: 42.9, sportCode: "running"), .recreational)
    }

    func testInferLevelRegularWhenVO2Max43to52() {
        XCTAssertEqual(sut.inferLevel(vo2Max: 43, sportCode: "running"), .regular)
        XCTAssertEqual(sut.inferLevel(vo2Max: 50, sportCode: "running"), .regular)
        XCTAssertEqual(sut.inferLevel(vo2Max: 51.9, sportCode: "running"), .regular)
    }

    func testInferLevelCompetitiveWhenVO2MaxAbove52() {
        XCTAssertEqual(sut.inferLevel(vo2Max: 52, sportCode: "running"), .competitive)
        XCTAssertEqual(sut.inferLevel(vo2Max: 60, sportCode: "running"), .competitive)
    }

    // MARK: - inferLevelFromFrequency (fallback when no vo2Max)

    func testInferLevelFromFrequencyBeginnerWhenZeroWorkouts() {
        XCTAssertEqual(sut.inferLevelFromFrequency(weeklyAverage: 0), .beginner)
    }

    func testInferLevelFromFrequencyRecreationalWhenLessThan2PerWeek() {
        XCTAssertEqual(sut.inferLevelFromFrequency(weeklyAverage: 1), .recreational)
        XCTAssertEqual(sut.inferLevelFromFrequency(weeklyAverage: 1.5), .recreational)
    }

    func testInferLevelFromFrequencyRegularWhen2to3HalfPerWeek() {
        XCTAssertEqual(sut.inferLevelFromFrequency(weeklyAverage: 2), .regular)
        XCTAssertEqual(sut.inferLevelFromFrequency(weeklyAverage: 3), .regular)
        XCTAssertEqual(sut.inferLevelFromFrequency(weeklyAverage: 3.4), .regular)
    }

    func testInferLevelFromFrequencyCompetitiveWhen3HalfPlusPerWeek() {
        XCTAssertEqual(sut.inferLevelFromFrequency(weeklyAverage: 3.5), .competitive)
        XCTAssertEqual(sut.inferLevelFromFrequency(weeklyAverage: 5), .competitive)
    }

    // MARK: - inferFrequencyBucket

    func testInferFrequencyBucketTwoWhenBelow1Half() {
        XCTAssertEqual(sut.inferFrequencyBucket(weeklyAverage: 0), .two)
        XCTAssertEqual(sut.inferFrequencyBucket(weeklyAverage: 1.4), .two)
    }

    func testInferFrequencyBucketThreeWhenOneHalfToThree() {
        XCTAssertEqual(sut.inferFrequencyBucket(weeklyAverage: 1.5), .three)
        XCTAssertEqual(sut.inferFrequencyBucket(weeklyAverage: 2.5), .three)
        XCTAssertEqual(sut.inferFrequencyBucket(weeklyAverage: 2.99), .three)
    }

    func testInferFrequencyBucketFourOrMoreWhenThreeOrMore() {
        XCTAssertEqual(sut.inferFrequencyBucket(weeklyAverage: 3), .fourOrMore)
        XCTAssertEqual(sut.inferFrequencyBucket(weeklyAverage: 5), .fourOrMore)
    }

    // MARK: - frequencyEstimate.perWeek

    func testFrequencyEstimatePerWeekValues() {
        XCTAssertEqual(FrequencyEstimate.two.perWeek, 2)
        XCTAssertEqual(FrequencyEstimate.three.perWeek, 3)
        XCTAssertEqual(FrequencyEstimate.fourOrMore.perWeek, 4)
    }

    // MARK: - equipmentSuggestions

    func testEquipmentSuggestionsAppleWatchDetected() {
        XCTAssertEqual(sut.equipmentSuggestions(appleWatchDetected: true), [.gpsWatch, .heartRateMonitor])
    }

    func testEquipmentSuggestionsNoWatch() {
        XCTAssertTrue(sut.equipmentSuggestions(appleWatchDetected: false).isEmpty)
    }

    // MARK: - suggest() agrégé

    func testSuggestReturnsNilWhenNoSignal() {
        let result = sut.suggest(
            vo2Max: nil,
            workoutSummary: .empty,
            sportCode: "running"
        )
        XCTAssertNil(result)
    }

    func testSuggestUsesVO2MaxWhenAvailable() {
        let summary = HealthKitWorkoutSummary(
            totalCount: 16,
            weeklyAverage: 2.0,
            dominantActivityRawValue: nil,
            appleWatchDetected: true
        )
        let result = sut.suggest(vo2Max: 48, workoutSummary: summary, sportCode: "running")
        let unwrapped = try! XCTUnwrap(result)
        XCTAssertEqual(unwrapped.level, .regular)
        XCTAssertEqual(unwrapped.levelSource, .vo2Max)
        XCTAssertEqual(unwrapped.frequency, .three)
        XCTAssertEqual(unwrapped.equipmentSuggestions, [.gpsWatch, .heartRateMonitor])
    }

    func testSuggestFallsBackToFrequencyWhenNoVO2Max() {
        let summary = HealthKitWorkoutSummary(
            totalCount: 8,
            weeklyAverage: 1.0,
            dominantActivityRawValue: nil,
            appleWatchDetected: false
        )
        let result = sut.suggest(vo2Max: nil, workoutSummary: summary, sportCode: "running")
        let unwrapped = try! XCTUnwrap(result)
        XCTAssertEqual(unwrapped.level, .recreational)
        XCTAssertEqual(unwrapped.levelSource, .workoutFrequency)
        XCTAssertEqual(unwrapped.frequency, .two)
        XCTAssertTrue(unwrapped.equipmentSuggestions.isEmpty)
    }

    func testSuggestVO2MaxAloneWithZeroWorkouts() {
        // VO2max présent (peut-être venu d'un cardio test) mais pas de workouts.
        let result = sut.suggest(
            vo2Max: 55,
            workoutSummary: .empty,
            sportCode: "running"
        )
        let unwrapped = try! XCTUnwrap(result)
        XCTAssertEqual(unwrapped.level, .competitive)
        XCTAssertEqual(unwrapped.levelSource, .vo2Max)
        XCTAssertEqual(unwrapped.frequency, .two) // 0/sem → "2" bucket plancher
    }
}
