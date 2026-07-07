// Coaching/Selector/ProgramTemplateLibrary.swift
// Story 3.2 — wrapper léger autour des métadonnées des templates bundlés.
//
// Chantier perf 2026-06-20 : la library ne porte plus les 40 `ProgramTemplate`
// COMPLETS (18 MB décodés au launch) mais leurs `TemplateSummary` (manifest
// ~10 KB). La sélection (`ProgramTemplateSelector`) ne lit que sport/level/id →
// les métadonnées suffisent. Le template COMPLET (avec `weeks`) n'est décodé
// paresseusement — via `fullTemplate(id:)` → `TemplateStore` — qu'au moment
// d'adapter/exécuter une séance. Cf [[v2_chantier_structuration_dosage_i18n]] /
// roadmap single-source.
import Foundation
import TemplateLoader
import TemplateModel

struct ProgramTemplateLibrary {
    /// Métadonnées des templates (source de la sélection).
    let summaries: [TemplateSummary]
    private let index: [Key: [TemplateSummary]]
    /// Résolution paresseuse du template complet par id (bundle ou fixtures mémoire).
    private let fullLoader: (String) async throws -> ProgramTemplate

    private struct Key: Hashable {
        let sport: Sport
        let level: Level
    }

    enum LibraryError: Error { case templateNotFound(String) }

    /// Init métadonnées + résolveur full (chemin bundlé prod).
    init(summaries: [TemplateSummary], fullLoader: @escaping (String) async throws -> ProgramTemplate) {
        precondition(!summaries.isEmpty, "ProgramTemplateLibrary doit contenir au moins un summary (manifest vide ?)")
        self.summaries = summaries
        self.fullLoader = fullLoader
        var idx: [Key: [TemplateSummary]] = [:]
        for s in summaries {
            idx[Key(sport: s.sport, level: s.level), default: []].append(s)
        }
        self.index = idx
    }

    /// Init depuis des templates COMPLETS en mémoire (tests/fixtures) : on en
    /// dérive les summaries pour la sélection et on garde les complets pour
    /// `fullTemplate(id:)`, sans aucun accès bundle.
    init(templates: [ProgramTemplate]) {
        let byId = Dictionary(uniqueKeysWithValues: templates.map { ($0.id, $0) })
        self.init(
            summaries: templates.map(\.asSummary),
            fullLoader: { id in
                guard let t = byId[id] else { throw LibraryError.templateNotFound(id) }
                return t
            }
        )
    }

    func templates(for sport: Sport, level: Level) -> [TemplateSummary] {
        index[Key(sport: sport, level: level)] ?? []
    }

    func templates(for sport: Sport) -> [TemplateSummary] {
        summaries.filter { $0.sport == sport }
    }

    /// Charge le `ProgramTemplate` COMPLET (avec `weeks`) pour ce summary/id.
    /// Coûteux (~450 KB) mais ciblé sur un seul template, mémoïsé par `TemplateStore`.
    func fullTemplate(id: String) async throws -> ProgramTemplate {
        try await fullLoader(id)
    }

    /// Library bundlée prod : métadonnées depuis le manifest léger (~10 KB),
    /// template complet résolu paresseusement + mémoïsé via `TemplateStore`.
    static func bundled() async throws -> ProgramTemplateLibrary {
        let summaries = try TemplateLoader.loadSummaries()
        return ProgramTemplateLibrary(
            summaries: summaries,
            fullLoader: { id in try await TemplateStore.shared.template(id: id) }
        )
    }
}
