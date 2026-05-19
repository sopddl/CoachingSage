// Coaching/Questionnaires/GoalCompatibilityMatrix.swift
// Story 3.13 Phase B (Epic 3) — matrice compatibilité goals multi-choice Q2.
//
// Doctrine validée par `template-quality-reviewer` 2026-05-19 (Phase B) puis
// refonte Phase E (2026-05-19) :
//   • EXCLUSIFS RETIRÉS — décision Sophie : ces "modes" (wellness, initiation, etc.)
//     créaient une frustration UX sans vrai bénéfice doctrinal. Un user qui vise
//     marathon entraîne déjà sa forme générale par construction ; mettre wellness
//     "exclusif" sur-contraint le mental model. L'algo primary canonique tranche
//     déjà la priorité (marathon > wellness), donc l'overlay couvre proprement.
//     L'API `exclusiveGoals(for:)` reste exposée et retourne [] partout — code swap
//     + toast reste dormant (filet sécurité futur si on découvre un cas réel).
//   • Paires incompatibles par sport (5k+marathon, sprint+distance-m, etc.) — INCHANGÉES
//   • Ordre canonique primary (sport-specifique, ranking depuis doctrine entraineurs) — INCHANGÉ
//   • `strengthTraining` + `triathlon` : catalogue structurellement exclusif → Q2 forcée en
//     `.singleChoice` côté `UniversalQuestionnaire`, donc la matrice ici n'est appelée
//     qu'avec un seul goal. Pas besoin de gérer paires/exclusifs pour ces 2 sports.
//
// API consommée par :
//   • UniversalQuestionnaire.buildProfile() pour choisir le primary algo (AC8-9)
//   • QuestionAnswerOptionsView Q2 multi pour grisage UI (AC5-6)
//
// Aucun état, tout statique. Sport inconnu → matrice vide (fail-safe).
import Foundation

/// Stratégie d'overlay pour appliquer les goals secondaires par-dessus le template
/// primary. Décidé par sport via `GoalCompatibilityMatrix.overlayStrategy(for:)` (AC10).
/// Consommé par `SecondaryGoalOverlay.apply(...)` (AC14-15).
public enum OverlayStrategy: String, Equatable, Sendable {
    case dedicatedSession    // 1 session/sem dédiée au secondary (si freq ≥ 2)
    case mixInSession        // drills/exos secondary injectés en début de chaque session
    case hybrid              // dedicated si freq ≥ 3, sinon mixInSession
    case notApplicable       // sport single de facto (triathlon, strengthTraining)
}

enum GoalCompatibilityMatrix {

    // MARK: - Exclusifs

    /// Phase E (2026-05-19) — TOUS LES SPORTS retournent désormais [].
    /// Les "modes" (wellness, initiation, reprise, etc.) ne sont plus exclusifs : l'algo
    /// primary canonique gère la priorité, l'overlay traite les secondary normalement.
    /// API conservée pour rester un filet (`isExclusive` est appelée par `isCompatible`,
    /// `handleMultiTap`, etc.) et permettre une réintroduction ciblée si besoin V2.
    static func exclusiveGoals(for sportCode: String) -> Set<String> {
        _ = sportCode  // explicit no-op pour signaler que la branche est intentionnellement vide
        return []
    }

    static func isExclusive(_ goal: String, sportCode: String) -> Bool {
        exclusiveGoals(for: sportCode).contains(goal)
    }

    // MARK: - Paires incompatibles

    /// Paires de goals doctrinalement ou structurellement incompatibles à combiner
    /// (cycle physio différents, distances mutuellement exclusives, splits catalogue
    /// distincts, etc.). Cf doctrine doc Story 3.13 lignes 50-60.
    static func incompatiblePairs(for sportCode: String) -> Set<UnorderedPair<String>> {
        let raw: [(String, String)] = {
            switch sportCode {
            case "running":
                // distances trop écartées → cycles physio incompatibles (Daniels, Pfitzinger)
                return [("5k", "marathon"), ("10k", "marathon"), ("5k", "half_marathon")]
            case "triathlon":
                // distances mutuellement exclusives → de facto single
                return [("sprint", "distance-m"), ("distance-m", "half-ironman"), ("sprint", "half-ironman")]
            case "strengthTraining":
                // splits structurellement différents par catalogue (Upper/Lower vs Push/Pull/Legs).
                // NB doctrine PPLUL combiné valide en pratique — c'est notre catalogue qui force l'exclu.
                return [("upperlower", "ppl")]
            case "hiking":
                // day-hikes (marche pure) ≠ fastpacking (course+pack). Splits cardio incompatibles.
                // Source : American Hiking Society + AdventureAlan.
                return [("day-hikes", "fastpacking")]
            case "football":
                // intensité hebdo trop divergente (loisir 1×/sem ≠ club ou saison régionale)
                return [("loisir", "club"), ("loisir", "saison-regional")]
            default:
                return []
            }
        }()
        return Set(raw.map { UnorderedPair($0.0, $0.1) })
    }

    // MARK: - Compatibilité

    /// Deux goals sont compatibles si :
    ///   • aucun des deux n'est exclusif dans ce sport
    ///   • leur paire n'est pas listée comme incompatible
    /// Goals identiques → true (laisse le caller gérer les doublons côté UI).
    static func isCompatible(_ goalA: String, _ goalB: String, sportCode: String) -> Bool {
        guard goalA != goalB else { return true }
        if isExclusive(goalA, sportCode: sportCode) { return false }
        if isExclusive(goalB, sportCode: sportCode) { return false }
        return !incompatiblePairs(for: sportCode).contains(UnorderedPair(goalA, goalB))
    }

    // MARK: - Primary algo

    /// Ordre canonique de priorité pour choisir le primary parmi N goals sélectionnés.
    /// Le premier de cette liste qui est dans la sélection user devient primary (AC8-9).
    /// Triathlon = single de facto → retour `[]` (fallback `goals.first`).
    static func primaryPriority(for sportCode: String) -> [String] {
        switch sportCode {
        case "running":
            // le plus long = plus structurant (Pfitzinger, Daniels)
            return ["marathon", "half_marathon", "10k", "5k", "wellness"]
        case "cycling":
            // cyclosportive = pic le plus exigeant (Friel)
            return ["cyclosportive", "sorties-longues", "endurance", "reprise"]
        case "swimming":
            // endurance = backbone volume hebdo (Maglischo) — patch reviewer 2026-05-19
            return ["endurance", "perfectionnement", "technique", "initiation"]
        case "strengthTraining":
            // strength-5x5 = plus spécialisé, ppl > upperlower > home-basics
            return ["strength-5x5", "ppl", "upperlower", "home-basics"]
        case "yoga":
            return ["advanced", "vinyasa", "hatha", "initiation"]
        case "hiit":
            return ["performance", "conditioning", "wellness"]
        case "hiking":
            // fastpacking = plus exigeant (course+pack), mountain-trek dénivelé > day-hikes
            return ["fastpacking", "mountain-trek", "day-hikes", "decouverte"]
        case "tennis":
            return ["tournoi-prep", "match-prep", "regularite", "initiation"]
        case "football":
            return ["saison-regional", "club", "loisir", "initiation"]
        case "triathlon":
            return []   // single de facto via incompatible pairs
        default:
            return []
        }
    }

    /// Sélectionne le primary parmi les goals cochés selon l'ordre canonique sport-specifique.
    /// Algorithme : prendre le premier goal du `primaryPriority(for:)` qui est dans `goals`.
    /// Si aucun match canonique (ex: triathlon, ou sport inconnu) → fallback `goals.first`.
    /// Retourne `nil` ssi `goals` est vide.
    static func pickPrimary(from goals: [String], sportCode: String) -> String? {
        guard !goals.isEmpty else { return nil }
        let priority = primaryPriority(for: sportCode)
        if let canonical = priority.first(where: { goals.contains($0) }) {
            return canonical
        }
        return goals.first
    }

    // MARK: - Overlay strategy

    /// Stratégie d'overlay secondary goals sur le template primary par sport.
    /// Doctrine (cf doc Story 3.13 lignes 102-116) :
    ///   • dedicatedSession  : remplacer N sessions du bloc par sessions thématiques secondary
    ///                         (séances vitesse ≠ endurance long, splits cardio incompatibles)
    ///   • mixInSession      : injecter drills/exos secondary en début de session
    ///                         (drills technique + main set endurance = standard natation/yoga)
    ///   • hybrid            : dedicated si freq ≥ 3, sinon mixIn (tennis fitness+match)
    ///   • notApplicable     : sport single de facto, secondary devrait être bloqué en amont
    static func overlayStrategy(for sportCode: String) -> OverlayStrategy {
        switch sportCode {
        case "running":          return .dedicatedSession  // vitesse/seuil ≠ endurance long (Daniels)
        case "cycling":          return .dedicatedSession  // endurance/sorties-longues = séances dédiées (Friel)
        case "swimming":         return .mixInSession      // drills + main set = standard natation (Maglischo)
        case "yoga":             return .mixInSession      // hatha + vinyasa peuvent alterner postures
        case "hiit":             return .dedicatedSession  // séances très spécifiques
        case "hiking":           return .dedicatedSession  // day-hikes ≠ mountain-trek
        case "tennis":           return .hybrid            // fitness drills + match practice
        case "football":         return .dedicatedSession  // physique vs tactique
        case "strengthTraining": return .notApplicable     // splits exclusifs par design catalogue
        case "triathlon":        return .notApplicable     // distance unique de facto
        default:                 return .notApplicable     // sport inconnu → fail-safe noop
        }
    }

    // MARK: - UI helper

    /// Indique si une option Q2 doit être grisée (disabled) compte tenu de la sélection courante.
    /// Règles (AC5) :
    ///   1. option déjà cochée → false (uncheck-able)
    ///   2. selection contient un exclusif → toutes les autres options grisées
    ///   3. option est exclusif et selection non vide (que des non-exclusifs) → false
    ///      (autorise le tap qui déclenchera le swap auto AC6)
    ///   4. option incompatible avec ≥1 goal de selection → true
    ///   5. sinon → false
    static func isDisabled(
        option: String,
        given selection: Set<String>,
        sportCode: String
    ) -> Bool {
        if selection.contains(option) { return false }
        // (2) selection contient un exclusif autre que l'option → grisé
        if selection.contains(where: { isExclusive($0, sportCode: sportCode) }) {
            return true
        }
        // (3) option exclusif + selection que des non-exclusifs → autoriser tap (swap AC6)
        if isExclusive(option, sportCode: sportCode) {
            return false
        }
        // (4) pair-incompat avec un selected
        return selection.contains { !isCompatible(option, $0, sportCode: sportCode) }
    }
}

// MARK: - UnorderedPair

/// Paire non-ordonnée Hashable : `UnorderedPair("a", "b") == UnorderedPair("b", "a")`.
/// Utilisée pour représenter des paires de goals incompatibles indépendamment de l'ordre.
struct UnorderedPair<T: Hashable & Comparable>: Hashable {
    let lower: T
    let upper: T

    init(_ x: T, _ y: T) {
        if x <= y {
            self.lower = x
            self.upper = y
        } else {
            self.lower = y
            self.upper = x
        }
    }

    func contains(_ value: T) -> Bool { value == lower || value == upper }
}
