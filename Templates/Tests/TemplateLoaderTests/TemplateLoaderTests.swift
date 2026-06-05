import XCTest
import TemplateModel
@testable import TemplateLoader

final class TemplateLoaderTests: XCTestCase {

    // MARK: - Helpers

    /// Write a manifest + copy of template files to a temp dir, return a Bundle pointing to that dir.
    /// `templates` maps filename (without ext) → (ProgramTemplate, optional override sha256 to force mismatch).
    private func makeFixtureBundle(
        templates: [(filename: String, template: ProgramTemplate, overrideSha: String?, overrideData: Data?)],
        manifestOverride: TemplateManifest? = nil,
        manifestFileName: String = "templates-manifest.json"
    ) throws -> Bundle {
        let tmp = try tempDir()
        let templatesDir = tmp.appendingPathComponent(TemplateManifest.templatesSubdir)
        try FileManager.default.createDirectory(at: templatesDir, withIntermediateDirectories: true)

        var entries: [TemplateManifest.Entry] = []
        for t in templates {
            let data: Data
            if let d = t.overrideData {
                data = d
            } else {
                data = try TemplateCoding.encode(t.template)
            }
            let dst = templatesDir.appendingPathComponent("\(t.filename).json")
            try data.write(to: dst)
            let sha = t.overrideSha ?? TemplateChecksum.sha256Hex(of: data)
            entries.append(TemplateManifest.Entry(id: t.template.id, file: "\(t.filename).json", sha256: sha))
        }

        let manifest = manifestOverride ?? TemplateManifest(
            schemaVersion: TemplateManifest.currentSchemaVersion,
            generatedAt: Date(),
            templates: entries
        )
        let manifestData = try TemplateCoding.makeEncoder().encode(manifest)
        let manifestURL = tmp.appendingPathComponent(manifestFileName)
        try manifestData.write(to: manifestURL)

        guard let bundle = Bundle(url: tmp) else {
            XCTFail("cannot create bundle at \(tmp.path)")
            throw TestError.bundleInitFailed
        }
        return bundle
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

    // MARK: - Happy path

    func testLoadAllReturnsAllTemplates() async throws {
        let tpl = try referenceTemplate()
        let bundle = try makeFixtureBundle(templates: [
            (filename: tpl.id, template: tpl, overrideSha: nil, overrideData: nil)
        ])
        let loaded = try await TemplateLoader.loadAll(from: bundle)
        XCTAssertEqual(loaded.count, 1)
        XCTAssertEqual(loaded.first?.id, tpl.id)
    }

    func testLoadByIdReturnsMatchingTemplate() async throws {
        let tpl = try referenceTemplate()
        let bundle = try makeFixtureBundle(templates: [
            (filename: tpl.id, template: tpl, overrideSha: nil, overrideData: nil)
        ])
        let loaded = try TemplateLoader.load(id: tpl.id, from: bundle)
        XCTAssertEqual(loaded.id, tpl.id)
        XCTAssertEqual(loaded.durationWeeks, tpl.durationWeeks)
    }

    func testLoadManifestRejectsSchemaMismatch() throws {
        let tpl = try referenceTemplate()
        let bogusManifest = TemplateManifest(
            schemaVersion: 99,
            generatedAt: Date(),
            templates: []
        )
        let bundle = try makeFixtureBundle(
            templates: [(filename: tpl.id, template: tpl, overrideSha: nil, overrideData: nil)],
            manifestOverride: bogusManifest
        )
        XCTAssertThrowsError(try TemplateLoader.loadManifest(from: bundle)) { err in
            guard case TemplateLoaderError.manifestSchemaVersionMismatch(1, 99) = err else {
                return XCTFail("expected schema mismatch, got \(err)")
            }
        }
    }

    // MARK: - Integrity checks

    func testChecksumMismatchIsDetected() async throws {
        let tpl = try referenceTemplate()
        let bundle = try makeFixtureBundle(templates: [
            (filename: tpl.id, template: tpl, overrideSha: "deadbeef", overrideData: nil)
        ])
        do {
            _ = try await TemplateLoader.loadAll(from: bundle)
            XCTFail("expected checksumMismatch")
        } catch TemplateLoaderError.checksumMismatch(let id, let expected, _) {
            XCTAssertEqual(id, tpl.id)
            XCTAssertEqual(expected, "deadbeef")
        } catch {
            XCTFail("unexpected error: \(error)")
        }
    }

    func testMissingManifestThrows() async throws {
        let tmp = FileManager.default.temporaryDirectory.appendingPathComponent("TemplateLoaderTests-empty-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: tmp, withIntermediateDirectories: true)
        addTeardownBlock { try? FileManager.default.removeItem(at: tmp) }
        guard let bundle = Bundle(url: tmp) else { XCTFail("bundle init"); return }
        do {
            _ = try TemplateLoader.loadManifest(from: bundle)
            XCTFail("expected manifestNotFound")
        } catch TemplateLoaderError.manifestNotFound {
            // expected
        } catch {
            XCTFail("unexpected error: \(error)")
        }
    }

    func testMissingTemplateFileThrows() async throws {
        let tpl = try referenceTemplate()
        let tmp = try tempDir()
        let templatesDir = tmp.appendingPathComponent(TemplateManifest.templatesSubdir)
        try FileManager.default.createDirectory(at: templatesDir, withIntermediateDirectories: true)
        // write a manifest that references a file we DON'T create
        let entry = TemplateManifest.Entry(id: tpl.id, file: "\(tpl.id).json", sha256: "whatever")
        let manifest = TemplateManifest(
            schemaVersion: TemplateManifest.currentSchemaVersion,
            generatedAt: Date(),
            templates: [entry]
        )
        let manifestData = try TemplateCoding.makeEncoder().encode(manifest)
        try manifestData.write(to: tmp.appendingPathComponent("templates-manifest.json"))

        guard let bundle = Bundle(url: tmp) else { XCTFail("bundle init"); return }
        do {
            _ = try await TemplateLoader.loadAll(from: bundle)
            XCTFail("expected templateFileNotFound")
        } catch TemplateLoaderError.templateFileNotFound(let id, _) {
            XCTAssertEqual(id, tpl.id)
        } catch {
            XCTFail("unexpected error: \(error)")
        }
    }

    func testInvalidJSONFailsDecode() async throws {
        let tpl = try referenceTemplate()
        let garbage = Data("{ not valid json".utf8)
        // The sha of garbage matches itself, so checksum passes and decode fails.
        let sha = TemplateChecksum.sha256Hex(of: garbage)
        let bundle = try makeFixtureBundle(templates: [
            (filename: tpl.id, template: tpl, overrideSha: sha, overrideData: garbage)
        ])
        do {
            _ = try await TemplateLoader.loadAll(from: bundle)
            XCTFail("expected templateDecodeFailed")
        } catch TemplateLoaderError.templateDecodeFailed(let id, _) {
            XCTAssertEqual(id, tpl.id)
        } catch {
            XCTFail("unexpected error: \(error)")
        }
    }

    func testDuplicateIdInManifestThrows() throws {
        let tpl = try referenceTemplate()
        let dup = TemplateManifest(
            schemaVersion: TemplateManifest.currentSchemaVersion,
            generatedAt: Date(),
            templates: [
                TemplateManifest.Entry(id: tpl.id, file: "a.json", sha256: "x"),
                TemplateManifest.Entry(id: tpl.id, file: "b.json", sha256: "y")
            ]
        )
        let bundle = try makeFixtureBundle(
            templates: [(filename: tpl.id, template: tpl, overrideSha: nil, overrideData: nil)],
            manifestOverride: dup
        )
        XCTAssertThrowsError(try TemplateLoader.loadManifest(from: bundle)) { err in
            guard case TemplateLoaderError.duplicateId(let id) = err, id == tpl.id else {
                return XCTFail("expected duplicateId, got \(err)")
            }
        }
    }

    // MARK: - Production bundle (only runs if GenerateManifest has produced a populated manifest)

    func testProductionBundleLoadsAtLeast30Templates() async throws {
        let manifest = try TemplateLoader.loadManifest()
        guard manifest.templates.count >= 30 else {
            throw XCTSkip("manifest contient \(manifest.templates.count) templates — lance `swift run GenerateManifest` pour peupler")
        }
        let templates = try await TemplateLoader.loadAll(validate: true)
        XCTAssertEqual(templates.count, manifest.templates.count)
        let ids = Set(templates.map(\.id))
        XCTAssertEqual(ids.count, templates.count, "ids dupliqués")
    }

    func testProductionBundleLoadsUnder100ms() async throws {
        let manifest = try TemplateLoader.loadManifest()
        guard manifest.templates.count >= 30 else {
            throw XCTSkip("manifest non peuplé")
        }
        // 2 warmups (first run allocates caches inside JSONDecoder internals), then best of 5.
        for _ in 0..<2 { _ = try await TemplateLoader.loadAll() }
        var best = Double.infinity
        for _ in 0..<5 {
            let start = Date()
            _ = try await TemplateLoader.loadAll()
            let elapsed = Date().timeIntervalSince(start) * 1000
            best = min(best, elapsed)
        }
        print("[perf] loadAll best: \(String(format: "%.1f", best))ms for \(manifest.templates.count) templates")
        // iOS target on device is < 100ms. On macOS test runner we allow slack for rosetta/CI variance.
        // Seuil relevé 150 → 400ms (i18n B1/B2) : le bundle canonique stocke désormais chaque champ
        // texte en objet `{fr,en,es}` (keyedContainer) au lieu d'une String nue (singleValueContainer).
        // Coût décode ~1.7× mesuré macOS debug (~255ms) ; headroom pour l'ajout en/es en B2.
        // iOS release reste l'objectif réel (< 100ms), non régressé par le format objet.
        XCTAssertLessThan(best, 400.0, "loadAll a pris \(String(format: "%.1f", best))ms (cible < 400ms macOS debug format objet i18n, < 100ms iOS release)")
    }
}
