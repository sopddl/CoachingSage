// Coaching/Selector/ProgramTemplateSelector.swift
// Story 3.2 — sélection deterministic du template de base le plus adapté
// au profil sport de l'utilisateur. 100% local, 0 réseau, 0 token.
//
// Garantie : la signature retourne TOUJOURS un `ProgramTemplate` non-optionnel.
// La library bundlée (Epic 0.5 post-Story 0.5.10) couvre 10 sports × 4 levels,
// donc le match exact existe pour tout `CoachingSportProfile` valide.
//
// Cascade :
//   1. match exact (sport, level) — tie-break par proximité goal puis id
//   2. fallback level : même sport, level le plus proche (beginner→…→competitive)
//   3. fallback sport : même level sur n'importe quel sport (sport non couvert)
//   4. dernier recours : premier template trié par id (precondition library non vide)
//
// Le mapping `CoachingSportProfile.sportCode` (ex "strengthTraining") →
// `Sport` package (ex `.strengthTraining` avec rawValue "strength_training")
// est centralisé dans `SportCodeMapping.swift`.
import Foundation
import TemplateModel

struct ProgramTemplateSelector {
    private let library: ProgramTemplateLibrary

    init(library: ProgramTemplateLibrary) {
        self.library = library
    }

    /// Sélectionne le template le plus adapté au profil. Non-optionnel par contrat.
    func select(profile: CoachingSportProfile) -> ProgramTemplate {
        let sport = Sport(sportCode: profile.sportCode)
        let level = Level(profileLevel: profile.level) ?? .beginner
        let goal = profile.goals.primary

        if let sport {
            if let exact = pickExact(sport: sport, level: level, goal: goal) {
                return exact
            }
            if let nearLevel = pickNearestLevel(sport: sport, target: level, goal: goal) {
                return nearLevel
            }
        }

        if let anyLevelMatch = library.templates.filter({ $0.level == level })
            .min(by: idAscending) {
            return anyLevelMatch
        }

        // Library non vide (precondition init), tri deterministic par id.
        return library.templates.min(by: idAscending)!
    }

    // MARK: - Internal

    private func pickExact(sport: Sport, level: Level, goal: String) -> ProgramTemplate? {
        let candidates = library.templates(for: sport, level: level)
        guard !candidates.isEmpty else { return nil }
        return tieBreak(candidates, goal: goal)
    }

    private func pickNearestLevel(sport: Sport, target: Level, goal: String) -> ProgramTemplate? {
        let sameSport = library.templates(for: sport)
        guard !sameSport.isEmpty else { return nil }
        // Distance entre Level rangs (beginner=0, recreational=1, regular=2, competitive=3).
        let targetRank = target.rank
        let sorted = sameSport.sorted { lhs, rhs in
            let dl = abs(lhs.level.rank - targetRank)
            let dr = abs(rhs.level.rank - targetRank)
            if dl != dr { return dl < dr }
            // À distance égale, privilégier le level inférieur (sécurité).
            if lhs.level.rank != rhs.level.rank { return lhs.level.rank < rhs.level.rank }
            return lhs.id < rhs.id
        }
        let nearest = sorted.first?.level
        let candidates = sorted.filter { $0.level == nearest }
        return tieBreak(candidates, goal: goal)
    }

    /// V1 : 1 template par (sport, level) → tie-breaker quasi-jamais déclenché.
    /// Si plusieurs candidats partagent (sport, level) à terme, on choisit le plus
    /// proche du goal en cherchant un substring du goal normalisé dans l'id ;
    /// fallback tri ascendant par id pour garantir le déterminisme.
    private func tieBreak(_ candidates: [ProgramTemplate], goal: String) -> ProgramTemplate? {
        guard !candidates.isEmpty else { return nil }
        if candidates.count == 1 { return candidates.first }
        let normalizedGoal = goal.lowercased()
        if !normalizedGoal.isEmpty,
           let goalHit = candidates.first(where: { $0.id.lowercased().contains(normalizedGoal) }) {
            return goalHit
        }
        return candidates.min(by: idAscending)
    }

    private func idAscending(_ lhs: ProgramTemplate, _ rhs: ProgramTemplate) -> Bool {
        lhs.id < rhs.id
    }
}

private extension Level {
    var rank: Int {
        switch self {
        case .beginner: return 0
        case .recreational: return 1
        case .regular: return 2
        case .competitive: return 3
        }
    }
}
