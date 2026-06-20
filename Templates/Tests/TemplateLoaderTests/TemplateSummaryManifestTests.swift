import XCTest
@testable import TemplateLoader
@testable import TemplateModel

/// Filet anti-drift du manifest `template-summaries.json` (chantier perf 2026-06-20).
///
/// Le manifest est une PROJECTION des 40 templates (source unique). S'il dérive
/// du contenu réel (édition d'un nom/sport/level/durée sans régénérer), ce test
/// passe rouge → relancer `swift run GenerateSummaries`. Garantit qu'on ne peut
/// pas servir au dashboard des métadonnées périmées.
final class TemplateSummaryManifestTests: XCTestCase {

    func testManifestMatchesFullTemplates() async throws {
        let full = try await TemplateLoader.loadAll()
        let expected = full.map(\.asSummary).sorted { $0.id < $1.id }

        let manifest = try TemplateLoader.loadSummaries().sorted { $0.id < $1.id }

        XCTAssertEqual(
            manifest.count, expected.count,
            "manifest summaries (\(manifest.count)) ≠ templates réels (\(expected.count)) → `swift run GenerateSummaries`"
        )
        for (m, e) in zip(manifest, expected) {
            XCTAssertEqual(
                m, e,
                "summary périmé pour \(e.id) → régénérer le manifest (`swift run GenerateSummaries`)"
            )
        }
    }

    /// `load(id:)` fast-path (filename==id) renvoie bien le template attendu, et
    /// identique au scan complet — pour tous les ids du manifest.
    func testLoadByIdFastPathMatchesLoadAll() async throws {
        let all = try await TemplateLoader.loadAll()
        let byId = Dictionary(uniqueKeysWithValues: all.map { ($0.id, $0) })

        for summary in try TemplateLoader.loadSummaries() {
            let single = try TemplateLoader.load(id: summary.id)
            XCTAssertEqual(single.id, summary.id)
            XCTAssertEqual(single, byId[summary.id], "load(id:) ≠ loadAll pour \(summary.id)")
        }
    }

    func testLoadByIdUnknownThrows() {
        XCTAssertThrowsError(try TemplateLoader.load(id: "id-inexistant-xyz"))
    }
}
