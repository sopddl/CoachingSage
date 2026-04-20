import Foundation
import TemplateModel

public enum TemplateLoaderError: Error, CustomStringConvertible, Equatable {
    case manifestNotFound
    case manifestDecodeFailed(String)
    case manifestSchemaVersionMismatch(expected: Int, got: Int)
    case templateFileNotFound(id: String, file: String)
    case templateDecodeFailed(id: String, reason: String)
    case checksumMismatch(id: String, expected: String, got: String)
    case validationFailed(id: String, reason: String)
    case duplicateId(String)

    public var description: String {
        switch self {
        case .manifestNotFound:
            return "templates-manifest.json introuvable dans le bundle"
        case .manifestDecodeFailed(let r):
            return "manifest invalide : \(r)"
        case .manifestSchemaVersionMismatch(let e, let g):
            return "manifest schema_version \(g), attendu \(e)"
        case .templateFileNotFound(let id, let file):
            return "template \(id) : fichier \(file) introuvable"
        case .templateDecodeFailed(let id, let r):
            return "template \(id) : décodage échoué : \(r)"
        case .checksumMismatch(let id, let e, let g):
            return "template \(id) : checksum \(g), attendu \(e)"
        case .validationFailed(let id, let r):
            return "template \(id) : validation échouée : \(r)"
        case .duplicateId(let id):
            return "id dupliqué dans le manifest : \(id)"
        }
    }
}

public enum TemplateLoader {
    /// The package resource bundle. Exposed publicly so callers can use the default value without triggering access-level errors on `Bundle.module`.
    public static let defaultBundle: Bundle = .module

    /// Load all templates listed in the bundle manifest.
    /// - Parameters:
    ///   - bundle: Bundle containing the manifest + Templates/ resources. Defaults to the package resource bundle.
    ///   - validate: Run `TemplateValidator.validate` on each template. Default false — templates are pre-validated at bundle time; enable for tests.
    public static func loadAll(from bundle: Bundle = TemplateLoader.defaultBundle, validate: Bool = false) async throws -> [ProgramTemplate] {
        let manifest = try loadManifest(from: bundle)
        let entries = manifest.templates

        return try await withThrowingTaskGroup(of: (Int, ProgramTemplate).self) { group in
            for (idx, entry) in entries.enumerated() {
                group.addTask {
                    let tpl = try loadOne(entry: entry, bundle: bundle, validate: validate)
                    return (idx, tpl)
                }
            }
            var collected: [(Int, ProgramTemplate)] = []
            collected.reserveCapacity(entries.count)
            for try await result in group {
                collected.append(result)
            }
            collected.sort { $0.0 < $1.0 }
            return collected.map(\.1)
        }
    }

    /// Load a single template by id using the bundle manifest.
    public static func load(id: String, from bundle: Bundle = TemplateLoader.defaultBundle, validate: Bool = false) throws -> ProgramTemplate {
        let manifest = try loadManifest(from: bundle)
        guard let entry = manifest.templates.first(where: { $0.id == id }) else {
            throw TemplateLoaderError.templateFileNotFound(id: id, file: "\(id).json")
        }
        return try loadOne(entry: entry, bundle: bundle, validate: validate)
    }

    /// Load and decode only the manifest (no template files).
    public static func loadManifest(from bundle: Bundle = TemplateLoader.defaultBundle) throws -> TemplateManifest {
        guard let url = bundle.url(forResource: TemplateManifest.manifestFilename, withExtension: "json") else {
            throw TemplateLoaderError.manifestNotFound
        }
        let data: Data
        do { data = try Data(contentsOf: url) }
        catch { throw TemplateLoaderError.manifestDecodeFailed("read: \(error)") }

        let manifest: TemplateManifest
        do {
            manifest = try TemplateCoding.makeDecoder().decode(TemplateManifest.self, from: data)
        } catch {
            throw TemplateLoaderError.manifestDecodeFailed("decode: \(error)")
        }

        guard manifest.schemaVersion == TemplateManifest.currentSchemaVersion else {
            throw TemplateLoaderError.manifestSchemaVersionMismatch(
                expected: TemplateManifest.currentSchemaVersion,
                got: manifest.schemaVersion
            )
        }

        var seen = Set<String>()
        for e in manifest.templates {
            if !seen.insert(e.id).inserted {
                throw TemplateLoaderError.duplicateId(e.id)
            }
        }
        return manifest
    }

    /// Decode one template from its bundle file + verify checksum.
    private static func loadOne(entry: TemplateManifest.Entry, bundle: Bundle, validate: Bool) throws -> ProgramTemplate {
        let basename = (entry.file as NSString).deletingPathExtension
        let subdir = TemplateManifest.templatesSubdir
        guard let url = bundle.url(forResource: basename, withExtension: "json", subdirectory: subdir) else {
            throw TemplateLoaderError.templateFileNotFound(id: entry.id, file: entry.file)
        }
        let data: Data
        do { data = try Data(contentsOf: url) }
        catch { throw TemplateLoaderError.templateFileNotFound(id: entry.id, file: entry.file) }

        let actual = TemplateChecksum.sha256Hex(of: data)
        guard actual == entry.sha256 else {
            throw TemplateLoaderError.checksumMismatch(id: entry.id, expected: entry.sha256, got: actual)
        }

        let template: ProgramTemplate
        do {
            template = try TemplateCoding.decode(data)
        } catch {
            throw TemplateLoaderError.templateDecodeFailed(id: entry.id, reason: "\(error)")
        }

        if validate {
            do { try TemplateValidator.validate(template) }
            catch { throw TemplateLoaderError.validationFailed(id: entry.id, reason: "\(error)") }
        }

        return template
    }
}
