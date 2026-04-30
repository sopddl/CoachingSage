import Foundation
import CryptoKit
import TemplateModel
import TemplateLoader

@main
struct GenerateManifestCLI {
    static func main() {
        let args = Array(CommandLine.arguments.dropFirst())
        var rawDir = "References/raw"
        var rootRefPath: String? = "References/running-beginner-5k-8sem.json"
        var outResourcesDir = "Sources/TemplateLoader/Resources"
        var dryRun = false
        var validateEach = true

        var i = 0
        while i < args.count {
            let a = args[i]
            switch a {
            case "--raw-dir":
                i += 1; guard i < args.count else { die("--raw-dir expects a path") }
                rawDir = args[i]
            case "--root-ref":
                i += 1; guard i < args.count else { die("--root-ref expects a path or 'none'") }
                rootRefPath = args[i] == "none" ? nil : args[i]
            case "--out":
                i += 1; guard i < args.count else { die("--out expects a path") }
                outResourcesDir = args[i]
            case "--dry-run":
                dryRun = true
            case "--no-validate":
                validateEach = false
            case "-h", "--help":
                printUsage(); exit(0)
            default:
                die("Unknown arg: \(a)")
            }
            i += 1
        }

        let cwd = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        let rawDirURL = cwd.appendingPathComponent(rawDir)
        let outResourcesURL = cwd.appendingPathComponent(outResourcesDir)
        let outTemplatesURL = outResourcesURL.appendingPathComponent(TemplateManifest.templatesSubdir)

        // Collect source JSONs : References/raw/*.json + optional root reference
        var sourceURLs: [URL] = []
        let listing = (try? FileManager.default.contentsOfDirectory(at: rawDirURL, includingPropertiesForKeys: nil)) ?? []
        sourceURLs.append(contentsOf: listing
            .filter { $0.pathExtension == "json" && !$0.lastPathComponent.hasPrefix("_") }
            .sorted { $0.lastPathComponent < $1.lastPathComponent })
        if let rootRef = rootRefPath {
            let rootURL = cwd.appendingPathComponent(rootRef)
            if FileManager.default.fileExists(atPath: rootURL.path) {
                if !sourceURLs.contains(where: { $0.lastPathComponent == rootURL.lastPathComponent }) {
                    sourceURLs.insert(rootURL, at: 0)
                }
            } else {
                die("root reference not found: \(rootURL.path)")
            }
        }

        print("Sources : \(sourceURLs.count) fichiers")
        for u in sourceURLs.prefix(3) { print("  - \(u.lastPathComponent)") }
        if sourceURLs.count > 3 { print("  - ... (+\(sourceURLs.count - 3))") }
        print("Destination : \(outTemplatesURL.path)")
        print("Validation  : \(validateEach)")
        print("Dry run     : \(dryRun)")

        if !dryRun {
            try? FileManager.default.createDirectory(at: outTemplatesURL, withIntermediateDirectories: true)
        }

        // Build entries + copy files
        var entries: [TemplateManifest.Entry] = []
        var seenIds = Set<String>()
        for src in sourceURLs {
            let data: Data
            do { data = try Data(contentsOf: src) }
            catch { die("read \(src.path): \(error)") }

            // Decode to grab id and optionally validate
            let template: ProgramTemplate
            do { template = try TemplateCoding.decode(data) }
            catch { die("decode \(src.lastPathComponent): \(error)") }

            if !seenIds.insert(template.id).inserted {
                die("duplicate id \(template.id) (file: \(src.lastPathComponent))")
            }
            if validateEach {
                do { try TemplateValidator.validate(template) }
                catch { die("validate \(template.id): \(error)") }
            }

            // Re-encode via canonical encoder to ensure byte-stable output, then hash that.
            let canonical: Data
            do { canonical = try TemplateCoding.encode(template) }
            catch { die("encode \(template.id): \(error)") }

            let checksum = TemplateChecksum.sha256Hex(of: canonical)
            let filename = "\(template.id).json"
            entries.append(TemplateManifest.Entry(id: template.id, file: filename, sha256: checksum))

            if !dryRun {
                let dst = outTemplatesURL.appendingPathComponent(filename)
                try? FileManager.default.removeItem(at: dst)
                do { try canonical.write(to: dst) }
                catch { die("write \(dst.path): \(error)") }
            }
        }

        // Build manifest
        let manifest = TemplateManifest(
            schemaVersion: TemplateManifest.currentSchemaVersion,
            generatedAt: Date(),
            templates: entries.sorted { $0.id < $1.id }
        )
        let encoder = TemplateCoding.makeEncoder()
        let manifestData: Data
        do { manifestData = try encoder.encode(manifest) }
        catch { die("encode manifest: \(error)") }

        if dryRun {
            print("\n[DRY RUN] manifest contient \(entries.count) entrées — non écrit")
            print(String(data: manifestData, encoding: .utf8) ?? "<binary>")
        } else {
            let manifestURL = outResourcesURL.appendingPathComponent("\(TemplateManifest.manifestFilename).json")
            do { try manifestData.write(to: manifestURL) }
            catch { die("write manifest: \(error)") }
            print("\n✅ \(entries.count) templates copiés dans \(outTemplatesURL.path)")
            print("✅ manifest écrit dans \(manifestURL.path)")
        }
    }

    static func printUsage() {
        print("""
        Usage: swift run GenerateManifest [options]

        Options:
          --raw-dir <path>    Working dir with raw template JSONs (default: References/raw)
          --root-ref <path>   Root reference template (default: References/running-beginner-5k-8sem.json, 'none' to skip)
          --out <path>        Resources dir for TemplateLoader (default: Sources/TemplateLoader/Resources)
          --dry-run           Build manifest in memory, don't write files
          --no-validate       Skip TemplateValidator on each template
          -h, --help          Show this help
        """)
    }

    static func die(_ msg: String) -> Never {
        FileHandle.standardError.write(Data("ERROR: \(msg)\n".utf8))
        exit(2)
    }
}
