// CoachingSageTests/Coaching/Session/SessionDurationParserTests.swift
// Story 3.35d — parsing des durées (fix bug device : "1 min" lu comme 1 s).
import XCTest

final class SessionDurationParserTests: XCTestCase {

    func test_seconds_minutes() {
        XCTAssertEqual(SessionDurationParser.seconds("1 min"), 60)
        XCTAssertEqual(SessionDurationParser.seconds("2 min"), 120)
    }

    func test_seconds_minutesAndSeconds() {
        XCTAssertEqual(SessionDurationParser.seconds("1 min 30"), 90)
        XCTAssertEqual(SessionDurationParser.seconds("2 min 15 marche rapide"), 135)
    }

    func test_seconds_secondsForms() {
        XCTAssertEqual(SessionDurationParser.seconds("20 sec"), 20)
        XCTAssertEqual(SessionDurationParser.seconds("30s"), 30)
        XCTAssertEqual(SessionDurationParser.seconds("45 s"), 45)
    }

    func test_seconds_bareNumberIsSeconds() {
        XCTAssertEqual(SessionDurationParser.seconds("40"), 40)
    }

    func test_seconds_nilWhenNoNumber() {
        XCTAssertNil(SessionDurationParser.seconds("marche"))
        XCTAssertNil(SessionDurationParser.seconds(nil))
    }

    func test_segments_runWalkBlock() {
        let segs = SessionDurationParser.segments("1 min course lente + 1 min 30 marche rapide")
        XCTAssertEqual(segs.count, 2)
        XCTAssertEqual(segs[0].seconds, 60)
        XCTAssertEqual(segs[0].label, "course lente")
        XCTAssertEqual(segs[1].seconds, 90)
        XCTAssertEqual(segs[1].label, "marche rapide")
    }

    func test_segments_singleWhenNoPlus() {
        let segs = SessionDurationParser.segments("20 min")
        XCTAssertEqual(segs.count, 1)
        XCTAssertEqual(segs[0].seconds, 1200)
    }

    func test_segments_emptyWhenUnparsable() {
        XCTAssertTrue(SessionDurationParser.segments("au feeling").isEmpty)
    }

    func test_words_stripsUnitsAndDigits() {
        XCTAssertEqual(SessionDurationParser.words(in: "1 min 30 marche rapide"), "marche rapide")
        XCTAssertNil(SessionDurationParser.words(in: "1 min 30"))
    }
}
