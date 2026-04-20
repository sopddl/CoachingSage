import Foundation
import TemplateModel

@main
struct ValidatorCLI {
    static func main() {
        let args = CommandLine.arguments.dropFirst()
        guard !args.isEmpty else {
            FileHandle.standardError.write(Data("Usage: TemplateValidator <file.json> [<file.json> ...]\n".utf8))
            exit(2)
        }

        var failed = 0
        for path in args {
            let url = URL(fileURLWithPath: path)
            do {
                let data = try Data(contentsOf: url)
                let template = try TemplateCoding.decode(data)
                try TemplateValidator.validate(template)
                print("OK  \(path)  (\(template.id), \(template.weeks.count) semaines)")
            } catch let e as TemplateValidationError {
                print("KO  \(path)  validation: \(e)")
                failed += 1
            } catch let e as DecodingError {
                print("KO  \(path)  decoding: \(e)")
                failed += 1
            } catch {
                print("KO  \(path)  io: \(error)")
                failed += 1
            }
        }

        if failed > 0 {
            FileHandle.standardError.write(Data("\n\(failed) fichier(s) invalide(s) sur \(args.count).\n".utf8))
            exit(1)
        }
    }
}
