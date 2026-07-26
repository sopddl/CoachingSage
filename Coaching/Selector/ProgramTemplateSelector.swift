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

/// Profil léger consommé par `selectTopN` (Story 3.8 mode vide).
/// Bundle : `level` autoprofil HK + `sportCodes` déclarés à l'onboarding
/// (`CoachingProfile.activeSports`). Pas de goals/equipment ici — la suggestion
/// mode vide est une vitrine, le profil sport détaillé arrive au moment où
/// l'utilisateur tape « Voir → » sur une card et entre dans le questionnaire.
struct TopNSelectionProfile: Equatable {
    let level: String
    let sportCodes: [String]
}

struct ProgramTemplateSelector {
    private let library: ProgramTemplateLibrary

    init(library: ProgramTemplateLibrary) {
        self.library = library
    }

    /// Sélectionne le template le plus adapté au profil. Non-optionnel par contrat.
    /// Retourne un `TemplateSummary` (métadonnées) — le caller charge le template
    /// COMPLET via `library.fullTemplate(id:)` au moment d'adapter la séance.
    func select(profile: CoachingSportProfile) -> TemplateSummary {
        let sport = Sport(sportCode: profile.sportCode)
        var level = Level(profileLevel: profile.level) ?? .beginner
        let goal = profile.goals.primary

        // Garde-fou Half-Ironman (décision Sophie 2026-07-26, audit triathlon) : triathlon
        // n'a qu'1 template par level (`pickExact` ne déclenche jamais son tie-break par
        // goal), donc level=competitive assigne TOUJOURS le plan 20 sem. sans que le goal
        // Q2 n'entre en jeu. Sans confirmation explicite des prérequis du template
        // (`assumed_profile` : Olympique bouclé, vélo TT/capteur, 8-10h/sem — posée par
        // `UniversalQuestionnaire.qHalfIronmanPrereq`), on retombe sur `regular`
        // (distance-m 16 sem.).
        if sport == .triathlon,
           level == .competitive,
           UniversalQuestionnaire.halfIronmanPrereqConfirmed(from: profile.conversationHistory) != true {
            level = .regular
        }

        if let sport {
            if let exact = pickExact(sport: sport, level: level, goal: goal) {
                return exact
            }
            if let nearLevel = pickNearestLevel(sport: sport, target: level, goal: goal) {
                return nearLevel
            }
        }

        if let anyLevelMatch = library.summaries.filter({ $0.level == level })
            .min(by: idAscending) {
            return anyLevelMatch
        }

        // Library non vide (precondition init), tri deterministic par id.
        return library.summaries.min(by: idAscending)!
    }

    /// Sélectionne jusqu'à `n` templates calibrés sur (level autoprofil ∩ sports onboarding).
    /// 100% local, deterministic, tie-break alphabétique sur `templateId`.
    ///
    /// Cascade pour atteindre `n` quand l'utilisateur déclare moins de sports
    /// que demandé, ou quand la library bundlée ne couvre pas tout :
    ///   1. Sports déclarés × level exact
    ///   2. Sports déclarés × level proche (distance ascendante, level inférieur préféré à égalité)
    ///   3. Tous sports × level exact
    ///   4. Tout le reste (precondition library non vide pour CoachingSage v2)
    /// À chaque tier : tri `id` ascendant, dédup par `id`, on s'arrête dès `n` atteint.
    func selectTopN(profile: TopNSelectionProfile, n: Int) -> [TemplateSummary] {
        guard n > 0 else { return [] }

        let level = Level(profileLevel: profile.level) ?? .beginner
        let declaredSports = Set(profile.sportCodes.compactMap { Sport(sportCode: $0) })

        var picked: [TemplateSummary] = []
        var pickedIds = Set<String>()

        func append(_ candidates: [TemplateSummary]) {
            for tpl in candidates {
                guard picked.count < n, !pickedIds.contains(tpl.id) else { continue }
                picked.append(tpl)
                pickedIds.insert(tpl.id)
            }
        }

        // Tier 1 — sports déclarés × level exact, tri id ascendant.
        let tier1 = library.summaries
            .filter { declaredSports.contains($0.sport) && $0.level == level }
            .sorted(by: idAscending)
        append(tier1)
        if picked.count >= n { return picked }

        // Tier 2 — sports déclarés × level proche (distance asc, level inférieur préféré, puis id).
        let targetRank = level.rank
        let tier2 = library.summaries
            .filter { declaredSports.contains($0.sport) && $0.level != level }
            .sorted { lhs, rhs in
                let dl = abs(lhs.level.rank - targetRank)
                let dr = abs(rhs.level.rank - targetRank)
                if dl != dr { return dl < dr }
                if lhs.level.rank != rhs.level.rank { return lhs.level.rank < rhs.level.rank }
                return lhs.id < rhs.id
            }
        append(tier2)
        if picked.count >= n { return picked }

        // Tier 3 — n'importe quel sport, level exact, tri id ascendant.
        let tier3 = library.summaries
            .filter { $0.level == level }
            .sorted(by: idAscending)
        append(tier3)
        if picked.count >= n { return picked }

        // Tier 4 — tout le reste, tri id ascendant.
        let tier4 = library.summaries.sorted(by: idAscending)
        append(tier4)
        return picked
    }

    // MARK: - Internal

    private func pickExact(sport: Sport, level: Level, goal: String) -> TemplateSummary? {
        let candidates = library.templates(for: sport, level: level)
        guard !candidates.isEmpty else { return nil }
        return tieBreak(candidates, goal: goal)
    }

    private func pickNearestLevel(sport: Sport, target: Level, goal: String) -> TemplateSummary? {
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
    private func tieBreak(_ candidates: [TemplateSummary], goal: String) -> TemplateSummary? {
        guard !candidates.isEmpty else { return nil }
        if candidates.count == 1 { return candidates.first }
        let normalizedGoal = goal.lowercased()
        if !normalizedGoal.isEmpty,
           let goalHit = candidates.first(where: { $0.id.lowercased().contains(normalizedGoal) }) {
            return goalHit
        }
        return candidates.min(by: idAscending)
    }

    private func idAscending(_ lhs: TemplateSummary, _ rhs: TemplateSummary) -> Bool {
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
