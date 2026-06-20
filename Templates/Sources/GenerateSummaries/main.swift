import Foundation
import TemplateModel

// GenerateSummaries — chantier perf 2026-06-20.
// Génère le manifest léger `template-summaries.json` à partir des 40 templates JSON.
// Source unique = le dossier des templates ; le manifest n'est qu'une PROJECTION
// (métadonnées sans `weeks`), re-générable à volonté. Un filet swift
// (`TemplateSummaryManifestTests`) garantit qu'il ne dérive jamais du contenu réel.
//
// Usage :
//   swift run GenerateSummaries [<templatesDir> <outputFile>]
// Défauts (lancé depuis le dossier Templates/) :
//   templatesDir = Sources/TemplateLoader/Resources/Templates
//   outputFile   = Sources/TemplateLoader/Resources/template-summaries.json

let args = CommandLine.arguments
let templatesDir = args.count > 1
    ? args[1]
    : "Sources/TemplateLoader/Resources/Templates"
let outputFile = args.count > 2
    ? args[2]
    : "Sources/TemplateLoader/Resources/template-summaries.json"

let fm = FileManager.default
let dirURL = URL(fileURLWithPath: templatesDir, isDirectory: true)

guard let entries = try? fm.contentsOfDirectory(at: dirURL, includingPropertiesForKeys: nil) else {
    FileHandle.standardError.write(Data("❌ dossier templates introuvable : \(templatesDir)\n".utf8))
    exit(1)
}

let jsonURLs = entries
    .filter { $0.pathExtension == "json" }
    .sorted { $0.lastPathComponent < $1.lastPathComponent }

var summaries: [TemplateSummary] = []
for url in jsonURLs {
    do {
        let data = try Data(contentsOf: url)
        let template = try TemplateCoding.decode(data)
        summaries.append(template.asSummary)
    } catch {
        FileHandle.standardError.write(Data("❌ \(url.lastPathComponent) : \(error)\n".utf8))
        exit(1)
    }
}

do {
    let out = try TemplateSummaryCoding.encode(summaries)
    try out.write(to: URL(fileURLWithPath: outputFile))
    // Newline final POSIX (diff propre).
    let fh = try FileHandle(forWritingTo: URL(fileURLWithPath: outputFile))
    fh.seekToEndOfFile()
    fh.write(Data("\n".utf8))
    try fh.close()
    print("✅ \(summaries.count) summaries → \(outputFile)")
} catch {
    FileHandle.standardError.write(Data("❌ écriture manifest : \(error)\n".utf8))
    exit(1)
}
