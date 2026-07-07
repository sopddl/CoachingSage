// Coaching/Session/SessionProgressStore.swift
// Story 3.33 (Décision 6, P0.3) — persistance de la complétion « exo fait » du
// mode FOCUS, en **FICHIER JSON PLAT** (`<Documents>/session_progress.json`).
// AUCUNE entité SwiftData, aucun bump de schema (historique de crashes migration
// `FetchDescriptor<@Model>`, cf RegenJournal passé en JSON plat).
//
// Structure : map `sessionKey → [stepIndex faits]`. La clé identifie une séance
// précise = `recordId-wN-dJ`. Volumes V1 négligeables (quelques dizaines
// d'entrées) → relecture/réécriture synchrone du petit fichier à chaque op.
import Foundation

struct SessionProgressStore: Sendable {
    let fileURL: URL

    /// Variante par défaut : `<Documents>/session_progress.json`.
    static func documentsDefault() -> SessionProgressStore {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        return SessionProgressStore(fileURL: docs.appendingPathComponent("session_progress.json"))
    }

    /// Clé d'une séance dans le fichier.
    static func key(recordId: UUID, week: Int, day: Int) -> String {
        "\(recordId.uuidString)-w\(week)-d\(day)"
    }

    // MARK: - API

    /// Indices d'étapes marquées faites pour une séance.
    func completedSteps(recordId: UUID, week: Int, day: Int) -> Set<Int> {
        let all = (try? loadAll()) ?? [:]
        let indices = all[Self.key(recordId: recordId, week: week, day: day)] ?? []
        return Set(indices)
    }

    /// Marque/démarque une étape. Persiste immédiatement.
    func setStep(_ index: Int, done: Bool, recordId: UUID, week: Int, day: Int) {
        var all = (try? loadAll()) ?? [:]
        let k = Self.key(recordId: recordId, week: week, day: day)
        var set = Set(all[k] ?? [])
        if done { set.insert(index) } else { set.remove(index) }
        if set.isEmpty {
            all[k] = nil
        } else {
            all[k] = set.sorted()
        }
        try? saveAll(all)
    }

    /// Efface toute la progression d'une séance (ex: récap terminé / reset).
    func clear(recordId: UUID, week: Int, day: Int) {
        var all = (try? loadAll()) ?? [:]
        all[Self.key(recordId: recordId, week: week, day: day)] = nil
        try? saveAll(all)
    }

    // MARK: - Fichier

    func loadAll() throws -> [String: [Int]] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return [:] }
        let data = try Data(contentsOf: fileURL)
        guard !data.isEmpty else { return [:] }
        return try JSONDecoder().decode([String: [Int]].self, from: data)
    }

    func saveAll(_ map: [String: [Int]]) throws {
        let data = try JSONEncoder().encode(map)
        try data.write(to: fileURL, options: .atomic)
    }
}
