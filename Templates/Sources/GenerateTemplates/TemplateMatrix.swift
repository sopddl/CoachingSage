import Foundation

struct TemplateSpec {
    let id: String
    let sport: String
    let level: String
    let name: String
    let durationWeeks: Int
    let sessionsPerWeek: Int
    let defaultObjective: String
    let assumedProfile: String
}

/// DEPRECATED post-Story 0.5.8 (2026-04-29).
/// Cette matrice référençait les anciens IDs FR (`musculation-debutant-...`, `velo-expert-...`).
/// Le renaming Story 0.5.8 vers les codes EN alignés `SportCode` iOS rend tous ces specs obsolètes.
/// Story 0.5.10 (regen qualité sport-spécifique) remplacera ce générateur par des prompts master par sport,
/// sans matrice centralisée.
/// `all` est volontairement vidé pour éviter qu'un dev relance ce CLI et reproduise des fichiers FR fantômes.
enum TemplateMatrix {
    static let all: [TemplateSpec] = []

    static func find(id: String) -> TemplateSpec? {
        all.first { $0.id == id }
    }
}
