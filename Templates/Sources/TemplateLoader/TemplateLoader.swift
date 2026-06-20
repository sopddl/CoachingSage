import Foundation
import TemplateModel

public enum TemplateLoaderError: Error, CustomStringConvertible, Equatable {
    case templatesDirectoryNotFound
    case templateNotFound(id: String)
    case templateDecodeFailed(file: String, reason: String)
    case validationFailed(id: String, reason: String)
    case duplicateId(String)

    public var description: String {
        switch self {
        case .templatesDirectoryNotFound:
            return "aucun template JSON trouvé dans le sous-dossier Templates/ du bundle"
        case .templateNotFound(let id):
            return "template \(id) introuvable dans le bundle"
        case .templateDecodeFailed(let file, let r):
            return "template \(file) : décodage échoué : \(r)"
        case .validationFailed(let id, let r):
            return "template \(id) : validation échouée : \(r)"
        case .duplicateId(let id):
            return "id dupliqué entre deux fichiers du bundle : \(id)"
        }
    }
}

/// Charge les templates depuis le bundle de ressources — SOURCE UNIQUE (chantier
/// 2026-06-10). Le dossier `Resources/Templates/` EST le registre : on l'énumère,
/// pas de manifest ni de checksum (cf [[roadmap_templates_single_source]]). Le filet
/// = décodage JSON + schéma (test sur les 40 templates réels). La signature iOS
/// protège déjà l'intégrité d'un bundle d'app — le sha256 ne servait qu'à garder
/// deux copies synchronisées, et il n'y a plus qu'une copie.
public enum TemplateLoader {
    /// The package resource bundle. Exposed publicly so callers can use the default value without triggering access-level errors on `Bundle.module`.
    public static let defaultBundle: Bundle = .module

    /// Sous-dossier des templates dans le bundle (préservé par `.copy("Resources/Templates")`).
    static let templatesSubdir = "Templates"

    /// Nom du manifest léger des métadonnées (chantier perf 2026-06-20).
    static let summariesManifest = "template-summaries"

    /// URLs de tous les JSON de templates bundlés, triées par nom de fichier (ordre déterministe).
    static func templateURLs(in bundle: Bundle) throws -> [URL] {
        guard let urls = bundle.urls(forResourcesWithExtension: "json", subdirectory: templatesSubdir),
              !urls.isEmpty else {
            throw TemplateLoaderError.templatesDirectoryNotFound
        }
        return urls.sorted { $0.lastPathComponent < $1.lastPathComponent }
    }

    /// Charge tous les templates du bundle.
    /// - Parameters:
    ///   - bundle: bundle contenant `Templates/`. Défaut = bundle de ressources du package.
    ///   - validate: lance `TemplateValidator.validate` sur chaque template (défaut false —
    ///     les templates sont pré-validés au build ; activer dans les tests).
    public static func loadAll(from bundle: Bundle = TemplateLoader.defaultBundle, validate: Bool = false) async throws -> [ProgramTemplate] {
        let urls = try templateURLs(in: bundle)

        let templates = try await withThrowingTaskGroup(of: (Int, ProgramTemplate).self) { group in
            for (idx, url) in urls.enumerated() {
                group.addTask { (idx, try decodeTemplate(at: url, validate: validate)) }
            }
            var collected: [(Int, ProgramTemplate)] = []
            collected.reserveCapacity(urls.count)
            for try await result in group {
                collected.append(result)
            }
            collected.sort { $0.0 < $1.0 }
            return collected.map(\.1)
        }

        // Garde-fou : ids uniques (le dossier ne peut pas l'imposer, deux fichiers
        // pourraient déclarer le même id interne).
        var seen = Set<String>()
        for tpl in templates where !seen.insert(tpl.id).inserted {
            throw TemplateLoaderError.duplicateId(tpl.id)
        }
        return templates
    }

    /// Charge le manifest léger des métadonnées (`template-summaries.json`).
    /// ~10 KB → décodage quasi instantané, contre ~18 MB pour `loadAll`. Les
    /// chemins qui n'exécutent pas une séance (sélection, suggestions, résolution
    /// du nom d'un programme) consomment ça. Chantier perf 2026-06-20.
    public static func loadSummaries(from bundle: Bundle = TemplateLoader.defaultBundle) throws -> [TemplateSummary] {
        guard let url = bundle.url(forResource: summariesManifest, withExtension: "json") else {
            throw TemplateLoaderError.templatesDirectoryNotFound
        }
        let data: Data
        do { data = try Data(contentsOf: url) }
        catch { throw TemplateLoaderError.templateDecodeFailed(file: "\(summariesManifest).json", reason: "read: \(error)") }
        do { return try TemplateSummaryCoding.decode(data) }
        catch { throw TemplateLoaderError.templateDecodeFailed(file: "\(summariesManifest).json", reason: "\(error)") }
    }

    /// Charge un seul template complet par id.
    ///
    /// Fast-path O(1) : le nom de fichier == id (invariant des templates générés),
    /// donc on construit l'URL directement (1 seul décodage ~450 KB) au lieu de
    /// scanner et décoder jusqu'à 40 fichiers (~1,5 s worst-case). Fallback scan
    /// séquentiel si l'invariant ne tient pas (sécurité).
    public static func load(id: String, from bundle: Bundle = TemplateLoader.defaultBundle, validate: Bool = false) throws -> ProgramTemplate {
        // Fast-path : <id>.json existe dans le sous-dossier ?
        if let directURL = bundle.url(forResource: id, withExtension: "json", subdirectory: templatesSubdir) {
            let tpl = try decodeTemplate(at: directURL, validate: false)
            if tpl.id == id {
                if validate {
                    do { try TemplateValidator.validate(tpl) }
                    catch { throw TemplateLoaderError.validationFailed(id: id, reason: "\(error)") }
                }
                return tpl
            }
            // Fichier <id>.json présent mais id interne différent → on retombe sur le scan.
        }

        // Fallback : scan séquentiel (invariant filename==id non garanti).
        for url in try templateURLs(in: bundle) {
            let tpl = try decodeTemplate(at: url, validate: false)
            if tpl.id == id {
                if validate {
                    do { try TemplateValidator.validate(tpl) }
                    catch { throw TemplateLoaderError.validationFailed(id: id, reason: "\(error)") }
                }
                return tpl
            }
        }
        throw TemplateLoaderError.templateNotFound(id: id)
    }

    /// Décode un template depuis son fichier bundle.
    private static func decodeTemplate(at url: URL, validate: Bool) throws -> ProgramTemplate {
        let data: Data
        do { data = try Data(contentsOf: url) }
        catch { throw TemplateLoaderError.templateDecodeFailed(file: url.lastPathComponent, reason: "read: \(error)") }

        let template: ProgramTemplate
        do {
            template = try TemplateCoding.decode(data)
        } catch {
            throw TemplateLoaderError.templateDecodeFailed(file: url.lastPathComponent, reason: "\(error)")
        }

        if validate {
            do { try TemplateValidator.validate(template) }
            catch { throw TemplateLoaderError.validationFailed(id: template.id, reason: "\(error)") }
        }
        return template
    }
}
