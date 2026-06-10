import XCTest
import TemplateModel
@testable import TemplateLoader

final class TemplateLoaderTests: XCTestCase {

    // MARK: - Helpers

    /// Écrit des fichiers JSON dans `<tmp>/Templates/` et renvoie un Bundle pointant sur `<tmp>`.
    /// Source UNIQUE : pas de manifest — le loader énumère le sous-dossier `Templates/`.
    /// `files` = (nom de fichier sans extension, données brutes à écrire).
    private func makeFixtureBundle(files: [(name: String, data: Data)]) throws -> Bundle {
        let tmp = try tempDir()
        let templatesDir = tmp.appendingPathComponent(TemplateLoader.templatesSubdir)
        try FileManager.default.createDirectory(at: templatesDir, withIntermediateDirectories: true)
        for f in files {
            try f.data.write(to: templatesDir.appendingPathComponent("\(f.name).json"))
        }
        guard let bundle = Bundle(url: tmp) else {
            XCTFail("cannot create bundle at \(tmp.path)")
            throw TestError.bundleInitFailed
        }
        return bundle
    }

    private func encoded(_ tpl: ProgramTemplate) throws -> Data {
        try TemplateCoding.encode(tpl)
    }

    private func tempDir() throws -> URL {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent("TemplateLoaderTests-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        addTeardownBlock { try? FileManager.default.removeItem(at: dir) }
        return dir
    }

    private func referenceTemplate() throws -> ProgramTemplate {
        let url = try fixtureURL(named: "running-beginner-5k-8sem")
        let data = try Data(contentsOf: url)
        return try TemplateCoding.decode(data)
    }

    private func fixtureURL(named name: String) throws -> URL {
        guard let url = Bundle.module.url(forResource: name, withExtension: "json") else {
            XCTFail("fixture \(name).json introuvable dans Tests/TemplateLoaderTests/Fixtures")
            throw TestError.fixtureMissing(name)
        }
        return url
    }

    enum TestError: Error { case bundleInitFailed; case fixtureMissing(String) }

    // MARK: - Happy path (énumération du bundle)

    func testLoadAllEnumeratesBundledTemplates() async throws {
        let tpl = try referenceTemplate()
        let bundle = try makeFixtureBundle(files: [(name: tpl.id, data: try encoded(tpl))])
        let loaded = try await TemplateLoader.loadAll(from: bundle)
        XCTAssertEqual(loaded.count, 1)
        XCTAssertEqual(loaded.first?.id, tpl.id)
    }

    func testLoadByIdReturnsMatchingTemplate() async throws {
        let tpl = try referenceTemplate()
        let bundle = try makeFixtureBundle(files: [(name: tpl.id, data: try encoded(tpl))])
        let loaded = try TemplateLoader.load(id: tpl.id, from: bundle)
        XCTAssertEqual(loaded.id, tpl.id)
        XCTAssertEqual(loaded.durationWeeks, tpl.durationWeeks)
    }

    func testLoadByIdThrowsWhenMissing() async throws {
        let tpl = try referenceTemplate()
        let bundle = try makeFixtureBundle(files: [(name: tpl.id, data: try encoded(tpl))])
        XCTAssertThrowsError(try TemplateLoader.load(id: "inexistant", from: bundle)) { err in
            guard case TemplateLoaderError.templateNotFound(let id) = err, id == "inexistant" else {
                return XCTFail("expected templateNotFound, got \(err)")
            }
        }
    }

    // MARK: - Garde-fous (décodage + ids uniques + dossier vide)

    func testInvalidJSONFailsDecode() async throws {
        let garbage = Data("{ not valid json".utf8)
        let bundle = try makeFixtureBundle(files: [(name: "bad", data: garbage)])
        do {
            _ = try await TemplateLoader.loadAll(from: bundle)
            XCTFail("expected templateDecodeFailed")
        } catch TemplateLoaderError.templateDecodeFailed {
            // expected
        } catch {
            XCTFail("unexpected error: \(error)")
        }
    }

    func testDuplicateIdAcrossFilesThrows() async throws {
        let tpl = try referenceTemplate()
        let data = try encoded(tpl)
        // Deux fichiers distincts portant le MÊME id interne.
        let bundle = try makeFixtureBundle(files: [
            (name: "copy-a", data: data),
            (name: "copy-b", data: data),
        ])
        do {
            _ = try await TemplateLoader.loadAll(from: bundle)
            XCTFail("expected duplicateId")
        } catch TemplateLoaderError.duplicateId(let id) {
            XCTAssertEqual(id, tpl.id)
        } catch {
            XCTFail("unexpected error: \(error)")
        }
    }

    func testEmptyBundleThrowsTemplatesDirectoryNotFound() async throws {
        let tmp = try tempDir() // pas de sous-dossier Templates/
        guard let bundle = Bundle(url: tmp) else { XCTFail("bundle init"); return }
        do {
            _ = try await TemplateLoader.loadAll(from: bundle)
            XCTFail("expected templatesDirectoryNotFound")
        } catch TemplateLoaderError.templatesDirectoryNotFound {
            // expected
        } catch {
            XCTFail("unexpected error: \(error)")
        }
    }

    // MARK: - Bundle de production (LE garde-fou : tout décode + valide le schéma + ids uniques)

    func testProductionBundleLoadsAllTemplates() async throws {
        let templates = try await TemplateLoader.loadAll(validate: true)
        XCTAssertGreaterThanOrEqual(templates.count, 30, "bundle prod: \(templates.count) templates (attendu ≥ 30)")
        let ids = Set(templates.map(\.id))
        XCTAssertEqual(ids.count, templates.count, "ids dupliqués dans le bundle de production")
    }

    func testProductionBundleLoadsUnder400ms() async throws {
        let templates = try await TemplateLoader.loadAll()
        guard templates.count >= 30 else { throw XCTSkip("bundle non peuplé (\(templates.count))") }
        // 2 warmups (first run allocates caches inside JSONDecoder internals), then best of 5.
        for _ in 0..<2 { _ = try await TemplateLoader.loadAll() }
        var best = Double.infinity
        for _ in 0..<5 {
            let start = Date()
            _ = try await TemplateLoader.loadAll()
            best = min(best, Date().timeIntervalSince(start) * 1000)
        }
        print("[perf] loadAll best: \(String(format: "%.1f", best))ms for \(templates.count) templates")
        // iOS release reste l'objectif réel (< 100ms). Slack macOS debug (format objet {fr,en,es} i18n B2).
        XCTAssertLessThan(best, 400.0, "loadAll a pris \(String(format: "%.1f", best))ms (cible < 400ms macOS debug, < 100ms iOS release)")
    }
}
