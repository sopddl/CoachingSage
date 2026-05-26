// CoachingSageTests/Coaching/Session/ExerciseExplanationServiceTests.swift
// Story 3.24b — couverture du contrat ExerciseExplanationService (seed → cache
// → IA → fallback) + audit garde-fous EU MDR sur le corpus seed.
//
// Stratégie : `tmpCacheDirectory` isolé par test pour ne pas polluer
// Application Support du simu. Fetcher remote stub (échec / succès / délai).
import XCTest
@testable import CoachingSage

final class ExerciseExplanationServiceTests: XCTestCase {

    var tmpDir: URL!

    override func setUp() {
        super.setUp()
        let base = FileManager.default.temporaryDirectory
        tmpDir = base.appendingPathComponent("ExplanationCacheTests-\(UUID().uuidString)", isDirectory: true)
        try? FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tmpDir)
        tmpDir = nil
        super.tearDown()
    }

    // MARK: - Seed catalogue

    func test_seed_returnsExplanationForBenchPress_FR() async throws {
        let service = DefaultExerciseExplanationService(cacheDirectory: tmpDir)
        let exo = AdaptedExercise(name: "Bench press", originalName: "Bench press")

        let result = try await service.explanation(for: exo, language: "fr")

        XCTAssertFalse(result.steps.isEmpty)
        XCTAssertFalse(result.equipment.isEmpty)
        XCTAssertTrue(result.steps.first?.lowercased().contains("banc") == true,
                      "Seed FR bench press doit mentionner 'banc'")
    }

    func test_seed_returnsExplanationForBenchPress_EN() async throws {
        let service = DefaultExerciseExplanationService(cacheDirectory: tmpDir)
        let exo = AdaptedExercise(name: "Bench press", originalName: "Bench press")

        let result = try await service.explanation(for: exo, language: "en")

        XCTAssertFalse(result.steps.isEmpty)
        XCTAssertTrue(result.steps.first?.lowercased().contains("bench") == true,
                      "Seed EN bench press doit mentionner 'bench'")
    }

    func test_seed_matchesDisplayNameWithPatternSuffix() async throws {
        // Cas réel templates strength : "Bench press (pattern pushHorizontal)".
        let service = DefaultExerciseExplanationService(cacheDirectory: tmpDir)
        let exo = AdaptedExercise(
            name: "Bench press (pattern pushHorizontal)",
            originalName: "Bench press (pattern pushHorizontal)"
        )

        let result = try await service.explanation(for: exo, language: "fr")

        XCTAssertFalse(result.steps.isEmpty)
    }

    func test_seed_matchesDeadlift() async throws {
        let service = DefaultExerciseExplanationService(cacheDirectory: tmpDir)
        let exo = AdaptedExercise(name: "Deadlift", originalName: "Deadlift")

        let result = try await service.explanation(for: exo, language: "fr")

        XCTAssertFalse(result.steps.isEmpty)
        XCTAssertTrue(result.equipment.contains(where: { $0.lowercased().contains("barre") }))
    }

    func test_seed_matchesPlank_FR_diacritics() async throws {
        // "Planche" ASCII-normalisé → matche "plank" / "planche".
        let service = DefaultExerciseExplanationService(cacheDirectory: tmpDir)
        let exo = AdaptedExercise(name: "Planche", originalName: "Planche")

        let result = try await service.explanation(for: exo, language: "fr")

        XCTAssertFalse(result.steps.isEmpty)
    }

    func test_seed_returnsNilForUnknownExercise_throwsNotAvailable() async {
        let service = DefaultExerciseExplanationService(cacheDirectory: tmpDir)
        let exo = AdaptedExercise(
            name: "Mouvement totalement inconnu xyz",
            originalName: "Mouvement totalement inconnu xyz"
        )

        do {
            _ = try await service.explanation(for: exo, language: "fr")
            XCTFail("Doit throw .notAvailable pour exo absent du seed et sans cache.")
        } catch ExerciseExplanationError.notAvailable {
            // OK
        } catch {
            XCTFail("Mauvais erreur : \(error)")
        }
    }

    // MARK: - Cache disque

    func test_cache_writeThenReadRoundTrip() async throws {
        let service = DefaultExerciseExplanationService(cacheDirectory: tmpDir)
        let exo = AdaptedExercise(name: "Sword press (custom)", originalName: "Sword press (custom)")
        let payload = ExerciseExplanation(
            steps: ["Step 1", "Step 2"],
            equipment: ["Cool gear"]
        )

        try service.writeCache(payload, for: exo, language: "fr")
        let read = try service.readCache(for: exo, language: "fr")

        XCTAssertEqual(read, payload)
    }

    func test_cache_hitShortCircuitsRemoteFetch() async throws {
        let recorder = RecordingFetcher()
        let service = DefaultExerciseExplanationService(remote: recorder, cacheDirectory: tmpDir)
        let exo = AdaptedExercise(name: "Sword press", originalName: "Sword press")
        let payload = ExerciseExplanation(steps: ["From cache"], equipment: [])

        // Pré-remplit le cache disque.
        try service.writeCache(payload, for: exo, language: "fr")

        let result = try await service.explanation(for: exo, language: "fr")

        XCTAssertEqual(result, payload)
        XCTAssertEqual(recorder.callCount, 0, "Cache hit doit court-circuiter le fetcher distant.")
    }

    func test_cache_isolatedPerLanguage() async throws {
        let service = DefaultExerciseExplanationService(cacheDirectory: tmpDir)
        let exo = AdaptedExercise(name: "Sword press", originalName: "Sword press")
        let frPayload = ExerciseExplanation(steps: ["Fait en FR"], equipment: [])
        let enPayload = ExerciseExplanation(steps: ["Done in EN"], equipment: [])

        try service.writeCache(frPayload, for: exo, language: "fr")
        try service.writeCache(enPayload, for: exo, language: "en")

        XCTAssertEqual(try service.readCache(for: exo, language: "fr"), frPayload)
        XCTAssertEqual(try service.readCache(for: exo, language: "en"), enPayload)
    }

    func test_cache_keyUsesOriginalNameNotSubstituted() {
        let exo1 = AdaptedExercise(name: "Bench press (pattern pushHorizontal)", originalName: "Bench press")
        let exo2 = AdaptedExercise(name: "DB bench press substitue", originalName: "Bench press")
        XCTAssertEqual(
            DefaultExerciseExplanationService.cacheKey(for: exo1),
            DefaultExerciseExplanationService.cacheKey(for: exo2),
            "originalName identique → même clé cache, même si name diffère."
        )
    }

    // MARK: - Remote fetcher

    func test_remote_unavailable_byDefault() async {
        let service = DefaultExerciseExplanationService(cacheDirectory: tmpDir)
        let exo = AdaptedExercise(
            name: "Mouvement custom xyz",
            originalName: "Mouvement custom xyz"
        )

        do {
            _ = try await service.explanation(for: exo, language: "fr")
            XCTFail("V1 doit throw .notAvailable sans backend IA câblé.")
        } catch ExerciseExplanationError.notAvailable {
            // OK
        } catch {
            XCTFail("Mauvais erreur : \(error)")
        }
    }

    func test_remote_success_cachesResult() async throws {
        let payload = ExerciseExplanation(steps: ["From IA"], equipment: ["X"])
        let succeeding = SuccessFetcher(payload: payload)
        let service = DefaultExerciseExplanationService(remote: succeeding, cacheDirectory: tmpDir)
        let exo = AdaptedExercise(name: "Exo custom", originalName: "Exo custom")

        let result = try await service.explanation(for: exo, language: "fr")
        XCTAssertEqual(result, payload)

        // 2ème appel = cache hit, fetcher non-rappelé.
        let result2 = try await service.explanation(for: exo, language: "fr")
        XCTAssertEqual(result2, payload)
        XCTAssertEqual(succeeding.callCount, 1, "2ème appel doit hit cache disque.")
    }

    func test_unsupportedLanguage_throws() async {
        let service = DefaultExerciseExplanationService(cacheDirectory: tmpDir)
        let exo = AdaptedExercise(name: "Bench press", originalName: "Bench press")

        do {
            _ = try await service.explanation(for: exo, language: "de")
            XCTFail("Doit throw .unsupportedLanguage pour 'de'.")
        } catch ExerciseExplanationError.unsupportedLanguage(let lang) {
            XCTAssertEqual(lang, "de")
        } catch {
            XCTFail("Mauvais erreur : \(error)")
        }
    }

    // MARK: - Garde-fous EU MDR (audit corpus seed)

    /// AC-b4 + AC-b7 — aucun mot/expression banni·e prescriptif dans le corpus seed.
    /// Liste alignée sur `epic3_leon_legal_constraints.md` (mots prescriptifs +
    /// vocabulaire médical). On accepte "tu" en sujet mais on bannit les
    /// expressions impératives qui prescrivent quelque chose.
    func test_seedHasNoBannedTermsForEUMDR() {
        let bannedFR = [
            // Prescriptif fort
            "tu dois", "vous devez", "il faut", "obligatoirement", "indispensable",
            // Médical
            "douleur", "blessure", "médical", "diagnostic", "soigner", "guérir",
            "traitement", "thérapie", "pathologie", "symptôme",
        ]
        let bannedEN = [
            "you must", "you have to", "you should always", "mandatory",
            "pain", "injury", "medical", "diagnosis", "cure", "heal",
            "treatment", "therapy", "pathology", "symptom",
        ]

        for entry in ExerciseExplanationSeed.entries {
            audit(entry.fr, banned: bannedFR, entry: entry.matchers.first ?? "?", lang: "fr")
            audit(entry.en, banned: bannedEN, entry: entry.matchers.first ?? "?", lang: "en")
        }
    }

    private func audit(_ explanation: ExerciseExplanation, banned: [String], entry: String, lang: String) {
        let corpus = (explanation.steps + explanation.equipment + [explanation.commonMistakes ?? ""])
            .joined(separator: " ")
            .lowercased()

        for term in banned {
            XCTAssertFalse(
                corpus.contains(term),
                "Seed [\(entry)/\(lang)] contient le terme banni EU MDR : '\(term)'"
            )
        }
    }

    /// 3 à 5 steps par seed (cf AC-b4 format strict).
    func test_seed_stepsCountInRange() {
        for entry in ExerciseExplanationSeed.entries {
            let nameHint = entry.matchers.first ?? "?"
            XCTAssertTrue((3...5).contains(entry.fr.steps.count),
                          "[\(nameHint)/fr] steps count=\(entry.fr.steps.count), attendu 3-5")
            XCTAssertTrue((3...5).contains(entry.en.steps.count),
                          "[\(nameHint)/en] steps count=\(entry.en.steps.count), attendu 3-5")
        }
    }

    func test_seed_allEntriesHaveEquipment() {
        for entry in ExerciseExplanationSeed.entries {
            let nameHint = entry.matchers.first ?? "?"
            XCTAssertFalse(entry.fr.equipment.isEmpty, "[\(nameHint)/fr] equipment vide")
            XCTAssertFalse(entry.en.equipment.isEmpty, "[\(nameHint)/en] equipment vide")
        }
    }

    // MARK: - Prompt builder (J2, V2-ready)

    /// AC-b4 — user prompt ne contient AUCUN mot banni EU MDR (le system prompt,
    /// lui, peut les lister comme contre-exemples → audit séparé).
    func test_userPrompt_FR_hasNoBannedTerms() {
        let exo = AdaptedExercise(name: "Squat barre", originalName: "Squat barre")
        let prompt = ExerciseExplanationPromptBuilder.userPrompt(for: exo, language: "fr")
            .lowercased()

        for term in ["douleur", "blessure", "médical", "diagnostic", "tu dois", "il faut"] {
            XCTAssertFalse(prompt.contains(term),
                           "User prompt FR ne doit pas contenir '\(term)' — \(prompt)")
        }
    }

    func test_userPrompt_EN_hasNoBannedTerms() {
        let exo = AdaptedExercise(name: "Back squat", originalName: "Back squat")
        let prompt = ExerciseExplanationPromptBuilder.userPrompt(for: exo, language: "en")
            .lowercased()

        for term in ["pain", "injury", "medical", "diagnosis", "you must", "you have to"] {
            XCTAssertFalse(prompt.contains(term),
                           "User prompt EN ne doit pas contenir '\(term)' — \(prompt)")
        }
    }

    /// AC-b4 — le system prompt DOIT explicitement contraindre Léon contre les
    /// prescriptions médicales. Sanity check : le mot "médical" / "medical"
    /// apparaît dans la liste de règles → preuve que la contrainte est posée.
    func test_systemPrompt_documentsEUMDRConstraints() {
        let fr = ExerciseExplanationPromptBuilder.systemPrompt(for: "fr").lowercased()
        let en = ExerciseExplanationPromptBuilder.systemPrompt(for: "en").lowercased()

        // Le system prompt doit nommer le terme banni pour l'interdire à Léon.
        XCTAssertTrue(fr.contains("médical"), "System FR doit poser la règle anti-prescription médicale")
        XCTAssertTrue(en.contains("medical"), "System EN must spell out the anti-medical-prescription rule")

        // Format JSON strict doit être imposé.
        XCTAssertTrue(fr.contains("json"), "System FR doit imposer un JSON de sortie strict")
        XCTAssertTrue(en.contains("json"), "System EN must impose strict JSON output")
    }

    func test_userPrompt_includesOriginalNameNotSubstituted() {
        // originalName = nom canonique, name = peut être substitué runtime.
        let exo = AdaptedExercise(
            name: "Marche nordique (substitut)",
            originalName: "Squat barre"
        )
        let prompt = ExerciseExplanationPromptBuilder.userPrompt(for: exo, language: "fr")

        XCTAssertTrue(prompt.contains("Squat barre"), "User prompt doit utiliser originalName, pas name substitué")
        XCTAssertFalse(prompt.contains("Marche nordique"), "User prompt ne doit pas inclure le name substitué")
    }
}

// MARK: - Stubs

private final class RecordingFetcher: ExerciseExplanationRemoteFetcher, @unchecked Sendable {
    var callCount = 0
    func fetch(exercise: AdaptedExercise, language: String) async throws -> ExerciseExplanation {
        callCount += 1
        throw ExerciseExplanationError.notAvailable
    }
}

private final class SuccessFetcher: ExerciseExplanationRemoteFetcher, @unchecked Sendable {
    let payload: ExerciseExplanation
    var callCount = 0
    init(payload: ExerciseExplanation) { self.payload = payload }
    func fetch(exercise: AdaptedExercise, language: String) async throws -> ExerciseExplanation {
        callCount += 1
        return payload
    }
}
