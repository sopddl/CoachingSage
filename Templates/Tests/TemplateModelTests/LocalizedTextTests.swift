import XCTest
@testable import TemplateModel

final class LocalizedTextTests: XCTestCase {

    private let fr = Locale(identifier: "fr")
    private let en = Locale(identifier: "en")
    private let es = Locale(identifier: "es")

    // MARK: - Décodage tolérant

    func testDecodesBareStringAsCanonicalFR() throws {
        let data = Data(#""Sortie longue""#.utf8)
        let lt = try JSONDecoder().decode(LocalizedText.self, from: data)
        XCTAssertEqual(lt.fr, "Sortie longue")
        XCTAssertNil(lt.en)
        XCTAssertNil(lt.es)
    }

    func testDecodesFullObject() throws {
        let data = Data(#"{"fr":"Sortie longue","en":"Long ride","es":"Salida larga"}"#.utf8)
        let lt = try JSONDecoder().decode(LocalizedText.self, from: data)
        XCTAssertEqual(lt.fr, "Sortie longue")
        XCTAssertEqual(lt.en, "Long ride")
        XCTAssertEqual(lt.es, "Salida larga")
    }

    func testDecodesPartialObjectFROnly() throws {
        let data = Data(#"{"fr":"Sortie longue"}"#.utf8)
        let lt = try JSONDecoder().decode(LocalizedText.self, from: data)
        XCTAssertEqual(lt.fr, "Sortie longue")
        XCTAssertNil(lt.en)
        XCTAssertNil(lt.es)
    }

    func testDecodeObjectWithoutFRThrows() {
        let data = Data(#"{"en":"Long ride"}"#.utf8)
        XCTAssertThrowsError(try JSONDecoder().decode(LocalizedText.self, from: data))
    }

    // MARK: - Résolution + fallback

    func testResolvedPicksLanguage() {
        let lt = LocalizedText(fr: "Sortie longue", en: "Long ride", es: "Salida larga")
        XCTAssertEqual(lt.resolved(fr), "Sortie longue")
        XCTAssertEqual(lt.resolved(en), "Long ride")
        XCTAssertEqual(lt.resolved(es), "Salida larga")
    }

    func testResolvedFallsBackToFRWhenMissing() {
        let lt = LocalizedText(fr: "Sortie longue") // en/es absents (avant B2)
        XCTAssertEqual(lt.resolved(en), "Sortie longue")
        XCTAssertEqual(lt.resolved(es), "Sortie longue")
        XCTAssertEqual(lt.canonical, "Sortie longue")
    }

    // MARK: - Encode toujours en objet

    func testEncodeProducesObjectEvenFromBareString() throws {
        let lt = try JSONDecoder().decode(LocalizedText.self, from: Data(#""X""#.utf8))
        let encoded = try JSONEncoder().encode(lt)
        let json = String(decoding: encoded, as: UTF8.self)
        XCTAssertTrue(json.contains("\"fr\""), "doit ré-encoder en objet, pas String nue : \(json)")
        // round-trip stable
        let reDecoded = try JSONDecoder().decode(LocalizedText.self, from: encoded)
        XCTAssertEqual(reDecoded, lt)
    }

    func testEncodeOmitsNilLanguages() throws {
        let lt = LocalizedText(fr: "X")
        let json = String(decoding: try JSONEncoder().encode(lt), as: UTF8.self)
        XCTAssertFalse(json.contains("\"en\""))
        XCTAssertFalse(json.contains("\"es\""))
    }

    // MARK: - Optional helpers

    func testOptionalResolved() {
        let present: LocalizedText? = LocalizedText(fr: "Note", en: "Note EN")
        let absent: LocalizedText? = nil
        XCTAssertEqual(present.resolved(en), "Note EN")
        XCTAssertNil(absent.resolved(en))
        XCTAssertEqual(present.canonical, "Note")
        XCTAssertNil(absent.canonical)
    }

    // MARK: - Décodage d'un tableau d'alternatives (Strings nues legacy)

    func testDecodesArrayOfBareStrings() throws {
        let data = Data(#"["Alt A","Alt B"]"#.utf8)
        let arr = try JSONDecoder().decode([LocalizedText].self, from: data)
        XCTAssertEqual(arr.map(\.fr), ["Alt A", "Alt B"])
    }
}
