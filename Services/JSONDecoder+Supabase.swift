// Services/JSONDecoder+Supabase.swift
// Factory JSONDecoder partagée pour le decode des réponses Supabase.
// Postgres timestamptz renvoie "2026-05-03T12:34:56.123456+00:00" (fractions de secondes) ;
// .dateDecodingStrategy = .iso8601 utilise ISO8601DateFormatter sans .withFractionalSeconds
// et lève DataCorrupted sur ces strings → bug hydrate-on-miss en boot Cmd+R.
import Foundation

extension JSONDecoder {
    static func supabase() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let raw = try container.decode(String.self)

            if let date = Self.iso8601WithFractions.date(from: raw) {
                return date
            }
            if let date = Self.iso8601Plain.date(from: raw) {
                return date
            }
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Date inattendue : '\(raw)' (ni ISO8601 standard ni avec fractions)"
            )
        }
        return decoder
    }

    private static let iso8601WithFractions: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    private static let iso8601Plain: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f
    }()
}
