// CoachingSageTests/Models/GoalsPayloadTests.swift
// Story 3.13 Phase A — GoalsPayload évolue { primary, secondary [] }.
// Tests rétrocompat decoder + roundtrip.
import Testing
import Foundation

@Suite("GoalsPayload")
struct GoalsPayloadTests {

    // MARK: - Defaults

    @Test("Init primary seul → secondary défaut []")
    func initPrimaryOnly_secondaryDefaultsEmpty() {
        let g = GoalsPayload(primary: "10k")
        #expect(g.primary == "10k")
        #expect(g.secondary == [])
    }

    @Test("Init primary + secondary explicit")
    func initWithSecondary() {
        let g = GoalsPayload(primary: "10k", secondary: ["wellness"])
        #expect(g.primary == "10k")
        #expect(g.secondary == ["wellness"])
    }

    // MARK: - Decoder rétrocompat

    @Test("Decoder : row v1 sans secondary → secondary = []")
    func decoder_v1RowWithoutSecondary_decodesEmpty() throws {
        let v1Json = #"{"primary":"5k"}"#.data(using: .utf8)!
        let decoded = try JSONDecoder().decode(GoalsPayload.self, from: v1Json)
        #expect(decoded.primary == "5k")
        #expect(decoded.secondary == [])
    }

    @Test("Decoder : row v2 avec secondary [] explicite")
    func decoder_v2RowWithEmptySecondary_decodesOk() throws {
        let v2Json = #"{"primary":"10k","secondary":[]}"#.data(using: .utf8)!
        let decoded = try JSONDecoder().decode(GoalsPayload.self, from: v2Json)
        #expect(decoded.primary == "10k")
        #expect(decoded.secondary == [])
    }

    @Test("Decoder : row v2 avec secondary peuplé")
    func decoder_v2RowWithSecondary_decodesAll() throws {
        let v2Json = #"{"primary":"endurance","secondary":["technique","perfectionnement"]}"#.data(using: .utf8)!
        let decoded = try JSONDecoder().decode(GoalsPayload.self, from: v2Json)
        #expect(decoded.primary == "endurance")
        #expect(decoded.secondary == ["technique", "perfectionnement"])
    }

    // MARK: - Encoder

    @Test("Encoder écrit toujours primary + secondary")
    func encoder_writesPrimaryAndSecondary() throws {
        let g = GoalsPayload(primary: "10k", secondary: ["wellness"])
        let data = try JSONEncoder().encode(g)
        let asString = String(data: data, encoding: .utf8) ?? ""
        #expect(asString.contains("\"primary\":\"10k\""))
        #expect(asString.contains("\"secondary\":[\"wellness\"]"))
    }

    @Test("Encoder secondary vide → écrit []")
    func encoder_emptySecondary_writesEmptyArray() throws {
        let g = GoalsPayload(primary: "wellness")
        let data = try JSONEncoder().encode(g)
        let asString = String(data: data, encoding: .utf8) ?? ""
        #expect(asString.contains("\"secondary\":[]"))
    }

    // MARK: - Roundtrip

    @Test("Roundtrip encode + decode preserves values")
    func roundtrip_preserves() throws {
        let original = GoalsPayload(primary: "marathon", secondary: ["wellness", "vitesse"])
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(GoalsPayload.self, from: data)
        #expect(decoded == original)
    }

    // MARK: - Equatable

    @Test("Equatable distingue secondary order")
    func equatable_ordersMatter() {
        let a = GoalsPayload(primary: "10k", secondary: ["wellness", "vitesse"])
        let b = GoalsPayload(primary: "10k", secondary: ["vitesse", "wellness"])
        #expect(a != b)
    }

    @Test("Equatable distingue primary")
    func equatable_primaryMatters() {
        let a = GoalsPayload(primary: "10k", secondary: ["wellness"])
        let b = GoalsPayload(primary: "5k", secondary: ["wellness"])
        #expect(a != b)
    }
}
