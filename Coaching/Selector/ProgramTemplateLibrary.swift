// Coaching/Selector/ProgramTemplateLibrary.swift
// Story 3.2 — wrapper léger autour de [ProgramTemplate] chargé via TemplateLoader.
// Pré-indexe par (sport, level) pour les lookups O(1) du selector. La library
// bundlée post-Story 0.5.10 couvre 10 sports × 4 levels = 40 templates.
import Foundation
import TemplateLoader
import TemplateModel

struct ProgramTemplateLibrary {
    let templates: [ProgramTemplate]
    private let index: [Key: [ProgramTemplate]]

    private struct Key: Hashable {
        let sport: Sport
        let level: Level
    }

    init(templates: [ProgramTemplate]) {
        precondition(!templates.isEmpty, "ProgramTemplateLibrary doit contenir au moins un template (library bundlée vide ?)")
        self.templates = templates
        var idx: [Key: [ProgramTemplate]] = [:]
        for t in templates {
            idx[Key(sport: t.sport, level: t.level), default: []].append(t)
        }
        self.index = idx
    }

    func templates(for sport: Sport, level: Level) -> [ProgramTemplate] {
        index[Key(sport: sport, level: level)] ?? []
    }

    func templates(for sport: Sport) -> [ProgramTemplate] {
        templates.filter { $0.sport == sport }
    }

    /// Charge la library bundlée (40 templates v2 post-Story 0.5.10).
    static func bundled() async throws -> ProgramTemplateLibrary {
        let all = try await TemplateLoader.loadAll()
        return ProgramTemplateLibrary(templates: all)
    }
}
