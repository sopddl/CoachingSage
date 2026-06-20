// Coaching/Selector/TemplateStore.swift
// Chantier perf 2026-06-20 — cache partagé des templates.
//
// Avant : 4 consommateurs (dashboard, SessionView, bootstrap, factory) appelaient
// chacun `ProgramTemplateLibrary.bundled()` → `TemplateLoader.loadAll()` → décodage
// des 18 MB des 40 templates, sans cache partagé. Le dashboard re-décodait tout au
// refresh, `load(id:)` scannait jusqu'à 40 fichiers (~1,5 s).
//
// Après : un acteur partagé décode chaque template COMPLET au plus une fois et le
// mémoïse. Les métadonnées (sélection/dashboard) passent par le manifest léger
// (`TemplateLoader.loadSummaries`, ~10 KB) — jamais les 18 MB.
import Foundation
import TemplateLoader
import TemplateModel

actor TemplateStore {
    static let shared = TemplateStore()

    private var fullById: [String: ProgramTemplate] = [:]

    /// Template COMPLET par id — décodé une seule fois (fast-path `load(id:)`
    /// O(1) via filename==id) puis mémoïsé pour les appels suivants.
    func template(id: String) async throws -> ProgramTemplate {
        if let cached = fullById[id] { return cached }
        let template = try TemplateLoader.load(id: id)
        fullById[id] = template
        return template
    }

    /// Pré-charge en arrière-plan les templates des programmes actifs/suggérés
    /// pour que l'ouverture d'une séance soit instantanée. Best-effort : toute
    /// erreur est silencieuse (le chemin paresseux re-tentera).
    func warm(ids: [String]) async {
        for id in ids where fullById[id] == nil {
            fullById[id] = try? TemplateLoader.load(id: id)
        }
    }
}
