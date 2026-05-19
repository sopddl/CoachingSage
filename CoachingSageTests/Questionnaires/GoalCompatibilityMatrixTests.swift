// CoachingSageTests/Questionnaires/GoalCompatibilityMatrixTests.swift
// Story 3.13 Phase B (AC20) — matrice compatibilité goals multi-choice Q2.
import Testing
import Foundation
@testable import CoachingSage

@Suite("GoalCompatibilityMatrix")
struct GoalCompatibilityMatrixTests {

    // MARK: - Exclusifs par sport

    @Test
    func exclusiveGoals_running() {
        #expect(GoalCompatibilityMatrix.exclusiveGoals(for: "running") == ["wellness"])
        #expect(GoalCompatibilityMatrix.isExclusive("wellness", sportCode: "running"))
        #expect(!GoalCompatibilityMatrix.isExclusive("10k", sportCode: "running"))
    }

    @Test
    func exclusiveGoals_strengthTraining_twoExclusives() {
        let exclusives = GoalCompatibilityMatrix.exclusiveGoals(for: "strengthTraining")
        #expect(exclusives == ["home-basics", "strength-5x5"])
    }

    @Test
    func exclusiveGoals_yoga_initiationAndAdvanced() {
        let exclusives = GoalCompatibilityMatrix.exclusiveGoals(for: "yoga")
        #expect(exclusives == ["initiation", "advanced"])
    }

    @Test
    func exclusiveGoals_unknownSport_isEmpty() {
        #expect(GoalCompatibilityMatrix.exclusiveGoals(for: "kitesurfing").isEmpty)
        #expect(!GoalCompatibilityMatrix.isExclusive("wellness", sportCode: "kitesurfing"))
    }

    // MARK: - Paires incompatibles par sport

    @Test
    func incompatiblePairs_running_threePairs() {
        let pairs = GoalCompatibilityMatrix.incompatiblePairs(for: "running")
        #expect(pairs.count == 3)
        #expect(pairs.contains(UnorderedPair("5k", "marathon")))
        #expect(pairs.contains(UnorderedPair("marathon", "5k"))) // ordre indifférent
        #expect(pairs.contains(UnorderedPair("10k", "marathon")))
        #expect(pairs.contains(UnorderedPair("5k", "half_marathon")))
    }

    @Test
    func incompatiblePairs_triathlon_threePairs_singleDeFacto() {
        let pairs = GoalCompatibilityMatrix.incompatiblePairs(for: "triathlon")
        #expect(pairs.count == 3)
        #expect(pairs.contains(UnorderedPair("sprint", "distance-m")))
        #expect(pairs.contains(UnorderedPair("distance-m", "half-ironman")))
        #expect(pairs.contains(UnorderedPair("sprint", "half-ironman")))
    }

    @Test
    func incompatiblePairs_hiking_dayHikesVsFastpacking() {
        let pairs = GoalCompatibilityMatrix.incompatiblePairs(for: "hiking")
        #expect(pairs == [UnorderedPair("day-hikes", "fastpacking")])
    }

    @Test
    func incompatiblePairs_strengthTraining_upperlowerVsPpl() {
        let pairs = GoalCompatibilityMatrix.incompatiblePairs(for: "strengthTraining")
        #expect(pairs == [UnorderedPair("upperlower", "ppl")])
    }

    @Test
    func incompatiblePairs_football_loisirVsClubAndSaison() {
        let pairs = GoalCompatibilityMatrix.incompatiblePairs(for: "football")
        #expect(pairs.count == 2)
        #expect(pairs.contains(UnorderedPair("loisir", "club")))
        #expect(pairs.contains(UnorderedPair("loisir", "saison-regional")))
    }

    @Test
    func incompatiblePairs_swimmingCyclingYogaHiitTennis_areEmpty() {
        #expect(GoalCompatibilityMatrix.incompatiblePairs(for: "swimming").isEmpty)
        #expect(GoalCompatibilityMatrix.incompatiblePairs(for: "cycling").isEmpty)
        #expect(GoalCompatibilityMatrix.incompatiblePairs(for: "yoga").isEmpty)
        #expect(GoalCompatibilityMatrix.incompatiblePairs(for: "hiit").isEmpty)
        #expect(GoalCompatibilityMatrix.incompatiblePairs(for: "tennis").isEmpty)
    }

    // MARK: - isCompatible

    @Test
    func isCompatible_running_10kAndHalfMarathon_compatible() {
        // pas dans la matrice incompat → compatibles (cycle préparatoire commun)
        #expect(GoalCompatibilityMatrix.isCompatible("10k", "half_marathon", sportCode: "running"))
    }

    @Test
    func isCompatible_running_5kAndMarathon_incompatible() {
        #expect(!GoalCompatibilityMatrix.isCompatible("5k", "marathon", sportCode: "running"))
        // ordre indifférent
        #expect(!GoalCompatibilityMatrix.isCompatible("marathon", "5k", sportCode: "running"))
    }

    @Test
    func isCompatible_running_exclusiveWellness_excludesEverything() {
        #expect(!GoalCompatibilityMatrix.isCompatible("wellness", "10k", sportCode: "running"))
        #expect(!GoalCompatibilityMatrix.isCompatible("5k", "wellness", sportCode: "running"))
    }

    @Test
    func isCompatible_sameGoal_returnsTrue() {
        #expect(GoalCompatibilityMatrix.isCompatible("10k", "10k", sportCode: "running"))
        // exclusif identique : true (caller doit prévenir doublons UI)
        #expect(GoalCompatibilityMatrix.isCompatible("wellness", "wellness", sportCode: "running"))
    }

    @Test
    func isCompatible_swimming_enduranceAndTechnique_compatible() {
        // doctrine swimming : multi-objectifs combinables (Maglischo)
        #expect(GoalCompatibilityMatrix.isCompatible("endurance", "technique", sportCode: "swimming"))
        #expect(GoalCompatibilityMatrix.isCompatible("endurance", "perfectionnement", sportCode: "swimming"))
    }

    @Test
    func isCompatible_hiking_dayHikesAndMountainTrek_compatible() {
        // pas dans la matrice → compatibles (cardio plus proche que day-hikes/fastpacking)
        #expect(GoalCompatibilityMatrix.isCompatible("day-hikes", "mountain-trek", sportCode: "hiking"))
        // mais fastpacking + day-hikes → incompatibles
        #expect(!GoalCompatibilityMatrix.isCompatible("day-hikes", "fastpacking", sportCode: "hiking"))
        // fastpacking + mountain-trek → compatibles
        #expect(GoalCompatibilityMatrix.isCompatible("mountain-trek", "fastpacking", sportCode: "hiking"))
    }

    @Test
    func isCompatible_strengthTraining_upperlowerAndPpl_incompatible() {
        #expect(!GoalCompatibilityMatrix.isCompatible("upperlower", "ppl", sportCode: "strengthTraining"))
        // Exclusifs strength : home-basics & strength-5x5 → bloquent tout
        #expect(!GoalCompatibilityMatrix.isCompatible("strength-5x5", "ppl", sportCode: "strengthTraining"))
        #expect(!GoalCompatibilityMatrix.isCompatible("home-basics", "ppl", sportCode: "strengthTraining"))
    }

    // MARK: - primaryPriority canonique

    @Test
    func primaryPriority_running_marathonFirst() {
        let priority = GoalCompatibilityMatrix.primaryPriority(for: "running")
        #expect(priority == ["marathon", "half_marathon", "10k", "5k", "wellness"])
    }

    @Test
    func primaryPriority_swimming_enduranceFirst_postReviewerPatch() {
        // Patch reviewer 2026-05-19 : endurance = backbone Maglischo
        let priority = GoalCompatibilityMatrix.primaryPriority(for: "swimming")
        #expect(priority == ["endurance", "perfectionnement", "technique", "initiation"])
    }

    @Test
    func primaryPriority_cycling_cyclosportiveFirst() {
        #expect(GoalCompatibilityMatrix.primaryPriority(for: "cycling") == ["cyclosportive", "sorties-longues", "endurance", "reprise"])
    }

    @Test
    func primaryPriority_yoga_advancedFirst() {
        #expect(GoalCompatibilityMatrix.primaryPriority(for: "yoga") == ["advanced", "vinyasa", "hatha", "initiation"])
    }

    @Test
    func primaryPriority_triathlon_isEmpty_singleDeFacto() {
        #expect(GoalCompatibilityMatrix.primaryPriority(for: "triathlon").isEmpty)
    }

    @Test
    func primaryPriority_unknownSport_isEmpty() {
        #expect(GoalCompatibilityMatrix.primaryPriority(for: "kitesurfing").isEmpty)
    }

    // MARK: - pickPrimary

    @Test
    func pickPrimary_running_5kAnd10kAndHalf_returnsHalf() {
        // Half_marathon est avant 10k/5k dans la canonique → primary = half_marathon
        let picked = GoalCompatibilityMatrix.pickPrimary(from: ["5k", "10k", "half_marathon"], sportCode: "running")
        #expect(picked == "half_marathon")
    }

    @Test
    func pickPrimary_running_singleGoal_returnsThatGoal() {
        #expect(GoalCompatibilityMatrix.pickPrimary(from: ["10k"], sportCode: "running") == "10k")
    }

    @Test
    func pickPrimary_emptyList_returnsNil() {
        #expect(GoalCompatibilityMatrix.pickPrimary(from: [], sportCode: "running") == nil)
    }

    @Test
    func pickPrimary_triathlon_noCanonical_fallbackFirstUser() {
        // primaryPriority(triathlon) = [] → fallback goals.first
        let picked = GoalCompatibilityMatrix.pickPrimary(from: ["sprint"], sportCode: "triathlon")
        #expect(picked == "sprint")
    }

    @Test
    func pickPrimary_unknownSport_fallbackFirstUser() {
        #expect(GoalCompatibilityMatrix.pickPrimary(from: ["foo", "bar"], sportCode: "kitesurfing") == "foo")
    }

    @Test
    func pickPrimary_goalNotInCanonical_fallbackFirstUser() {
        // Le user a coché un goal inconnu de la canonique → fallback
        let picked = GoalCompatibilityMatrix.pickPrimary(from: ["unknown-goal"], sportCode: "running")
        #expect(picked == "unknown-goal")
    }

    @Test
    func pickPrimary_swimming_techniqueAndEndurance_returnsEndurance() {
        // endurance > perfectionnement > technique > initiation
        let picked = GoalCompatibilityMatrix.pickPrimary(from: ["technique", "endurance"], sportCode: "swimming")
        #expect(picked == "endurance")
    }

    // MARK: - isDisabled UI helper

    @Test
    func isDisabled_emptySelection_nothingDisabled() {
        #expect(!GoalCompatibilityMatrix.isDisabled(option: "10k", given: [], sportCode: "running"))
        #expect(!GoalCompatibilityMatrix.isDisabled(option: "wellness", given: [], sportCode: "running"))
    }

    @Test
    func isDisabled_alreadySelected_neverDisabled() {
        // option déjà cochée → uncheck-able même si la sélection est composite
        #expect(!GoalCompatibilityMatrix.isDisabled(option: "10k", given: ["10k", "half_marathon"], sportCode: "running"))
    }

    @Test
    func isDisabled_exclusiveSelected_allOthersGreyed() {
        // wellness exclusif coché → toutes les autres grisées
        #expect(GoalCompatibilityMatrix.isDisabled(option: "10k", given: ["wellness"], sportCode: "running"))
        #expect(GoalCompatibilityMatrix.isDisabled(option: "marathon", given: ["wellness"], sportCode: "running"))
        // wellness lui-même reste interactif (uncheck)
        #expect(!GoalCompatibilityMatrix.isDisabled(option: "wellness", given: ["wellness"], sportCode: "running"))
    }

    @Test
    func isDisabled_exclusiveOptionWhenNonExclusiveSelected_isAllowed_forSwapTap() {
        // 10k coché (non-exclusif). User tape wellness (exclusif) — doit être autorisé
        // pour que le tap déclenche le swap exclusif AC6 côté View/VM.
        #expect(!GoalCompatibilityMatrix.isDisabled(option: "wellness", given: ["10k"], sportCode: "running"))
    }

    @Test
    func isDisabled_incompatiblePair_isGreyed() {
        // 5k coché → marathon grisé (pair-incompat)
        #expect(GoalCompatibilityMatrix.isDisabled(option: "marathon", given: ["5k"], sportCode: "running"))
        // half_marathon coché (compat avec 5k via Pfitzinger) → 10k toujours compatible
        #expect(!GoalCompatibilityMatrix.isDisabled(option: "10k", given: ["half_marathon"], sportCode: "running"))
        // half_marathon coché → 5k incompatible
        #expect(GoalCompatibilityMatrix.isDisabled(option: "5k", given: ["half_marathon"], sportCode: "running"))
    }

    @Test
    func isDisabled_swimming_noConstraintsMultiSelect() {
        // swimming = aucune incompat, initiation exclusif seul.
        // endurance coché → technique reste cliquable
        #expect(!GoalCompatibilityMatrix.isDisabled(option: "technique", given: ["endurance"], sportCode: "swimming"))
        // initiation exclusif coché → endurance grisé
        #expect(GoalCompatibilityMatrix.isDisabled(option: "endurance", given: ["initiation"], sportCode: "swimming"))
    }

    @Test
    func isDisabled_strengthTraining_upperlowerAndPpl() {
        // upperlower coché → ppl grisé (pair-incompat catalogue)
        #expect(GoalCompatibilityMatrix.isDisabled(option: "ppl", given: ["upperlower"], sportCode: "strengthTraining"))
        // ppl coché → upperlower grisé
        #expect(GoalCompatibilityMatrix.isDisabled(option: "upperlower", given: ["ppl"], sportCode: "strengthTraining"))
        // strength-5x5 exclusif coché → tout le reste grisé
        #expect(GoalCompatibilityMatrix.isDisabled(option: "ppl", given: ["strength-5x5"], sportCode: "strengthTraining"))
        #expect(GoalCompatibilityMatrix.isDisabled(option: "upperlower", given: ["strength-5x5"], sportCode: "strengthTraining"))
    }

    // MARK: - UnorderedPair invariants

    @Test
    func unorderedPair_isOrderIndifferent() {
        #expect(UnorderedPair("a", "b") == UnorderedPair("b", "a"))
        #expect(UnorderedPair("a", "b").hashValue == UnorderedPair("b", "a").hashValue)
    }

    @Test
    func unorderedPair_normalizesToSortedLowerUpper() {
        let p = UnorderedPair("zebra", "apple")
        #expect(p.lower == "apple")
        #expect(p.upper == "zebra")
        #expect(p.contains("apple"))
        #expect(p.contains("zebra"))
        #expect(!p.contains("banana"))
    }
}
