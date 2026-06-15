import XCTest
@testable import TemplateLoader
import TemplateModel

/// Filet de cohérence — migration T3 (zéro dette) du chantier dose i18n.
///
/// Garantit que la table `LegacyDoseMigration` (backfill des blobs persistés sans `dose`)
/// couvre EXACTEMENT les mêmes strings `duration`/`reps` que les templates yoga bundlés, et
/// reconstruit un `Dose` identique à celui injecté. Sans ce filet, une édition future des
/// templates ferait diverger silencieusement le contenu neuf et le fallback legacy.
final class LegacyDoseMigrationTests: XCTestCase {

    private static let langs = [Locale(identifier: "fr"), Locale(identifier: "en"), Locale(identifier: "es")]

    func testMigrationTableMatchesBundledYogaDoses() async throws {
        try await assertMigrationMatches(sport: .yoga)
    }

    func testMigrationTableMatchesBundledRunningDoses() async throws {
        try await assertMigrationMatches(sport: .running)
    }

    func testMigrationTableMatchesBundledCyclingDoses() async throws {
        try await assertMigrationMatches(sport: .cycling)
    }

    private func assertMigrationMatches(sport: Sport, file: StaticString = #filePath, line: UInt = #line) async throws {
        let templates = try await TemplateLoader.loadAll()
        guard templates.count >= 30 else { throw XCTSkip("bundle non peuplé (\(templates.count))") }
        let scoped = templates.filter { $0.sport == sport }
        XCTAssertFalse(scoped.isEmpty, "aucun template \(sport) chargé", file: file, line: line)

        var mismatches: [String] = []
        for t in scoped {
            for w in t.weeks {
                for s in w.sessions {
                    let all = s.exercises + (s.variants ?? []).flatMap { $0.exercises }
                    for e in all {
                        guard let injected = e.dose else { continue }
                        // Le backfill depuis les strings legacy doit reproduire le dose injecté.
                        guard let migrated = LegacyDoseMigration.dose(duration: e.duration, reps: e.reps) else {
                            mismatches.append("[\(t.id)] « \(e.stableMatchKey) » : pas de migration pour duration=\(e.duration ?? "∅")/reps=\(e.reps ?? "∅")")
                            continue
                        }
                        // Comparaison sur le rendu FR/EN/ES (l'invariant qui compte pour l'UI).
                        for loc in Self.langs {
                            let a = DoseFormatter.string(injected, locale: loc)
                            let b = DoseFormatter.string(migrated, locale: loc)
                            if a != b {
                                mismatches.append("[\(t.id)] « \(e.stableMatchKey) » \(loc.identifier): injecté=« \(a) » ≠ migré=« \(b) »")
                            }
                        }
                    }
                }
            }
        }
        XCTAssertTrue(
            mismatches.isEmpty,
            "Divergence table migration ↔ templates \(sport) (\(mismatches.count)) :\n" + mismatches.prefix(30).joined(separator: "\n"),
            file: file, line: line
        )
    }
}
