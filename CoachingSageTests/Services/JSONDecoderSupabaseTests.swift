// CoachingSageTests/Services/JSONDecoderSupabaseTests.swift
// Couvre la factory JSONDecoder.supabase() : doit accepter timestamps Postgres
// avec fractions de secondes (cas réel timestamptz) et sans, refuser le reste.
// Bug d'origine : .iso8601 strict refusait les fractions → DecodingError dans hydrate-on-miss.
import XCTest
@testable import CoachingSage

final class JSONDecoderSupabaseTests: XCTestCase {

    private struct DateOnly: Decodable {
        let timestamp: Date
    }

    func testDecodesISO8601WithFractionalSeconds() throws {
        let json = #"{"timestamp":"2026-05-03T12:34:56.123456+00:00"}"#.data(using: .utf8)!
        let decoded = try JSONDecoder.supabase().decode(DateOnly.self, from: json)

        let expected = ISO8601DateFormatter().date(from: "2026-05-03T12:34:56Z")!
        XCTAssertEqual(decoded.timestamp.timeIntervalSince(expected), 0.123456, accuracy: 0.001)
    }

    func testDecodesISO8601WithoutFractionalSeconds() throws {
        let json = #"{"timestamp":"2026-05-03T12:34:56Z"}"#.data(using: .utf8)!
        let decoded = try JSONDecoder.supabase().decode(DateOnly.self, from: json)

        let expected = ISO8601DateFormatter().date(from: "2026-05-03T12:34:56Z")!
        XCTAssertEqual(decoded.timestamp, expected)
    }

    func testDecodesISO8601WithTimezoneOffset() throws {
        let json = #"{"timestamp":"2026-05-03T14:34:56.000000+02:00"}"#.data(using: .utf8)!
        let decoded = try JSONDecoder.supabase().decode(DateOnly.self, from: json)

        let expected = ISO8601DateFormatter().date(from: "2026-05-03T12:34:56Z")!
        XCTAssertEqual(decoded.timestamp.timeIntervalSince(expected), 0, accuracy: 0.001)
    }

    func testRejectsMalformedDateString() {
        let json = #"{"timestamp":"pas une date"}"#.data(using: .utf8)!

        XCTAssertThrowsError(try JSONDecoder.supabase().decode(DateOnly.self, from: json)) { error in
            guard case DecodingError.dataCorrupted = error else {
                XCTFail("Expected DecodingError.dataCorrupted, got \(error)")
                return
            }
        }
    }
}
