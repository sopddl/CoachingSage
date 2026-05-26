// Coaching/Session/ExerciseExplanationService.swift
// Story 3.24b — service async "comment exécuter un exo" avec stratégie
// seed → cache disque → IA → fallback (cf AC-b1).
//
// V1 livrable :
//  - seed catalogue manuel (cf `ExerciseExplanationSeed`) : top 10 exos universels.
//  - cache disque dans `Application Support/ExerciseExplanations/<lang>/<sha>.json`.
//    Archi prête mais ne se peuple qu'après un hit IA — V1 ne hit jamais l'IA.
//  - IA Léon on-demand : stub V1 throw `.notAvailable` (pas de backend dédié).
//    Le câblage Edge Function `sage-exercise-explanation` est V2.
//  - fallback : caller catch `.notAvailable` et tombe sur `SessionTipCatalog`.
//
// Cache invariant : path inclut `<language>` → 1 hit IA = 1 entrée FR + 1 entrée EN
// si l'user bascule la langue de l'app via LanguageManager. TTL infini (les exos
// canoniques ne bougent pas).
import Foundation
import os

/// Stub V1 du fetch IA. Toujours throw `.notAvailable` jusqu'à ce que l'Edge
/// Function dédiée soit livrée. Le contrat reste stable pour V2.
public protocol ExerciseExplanationRemoteFetcher: Sendable {
    func fetch(
        exercise: AdaptedExercise,
        language: String
    ) async throws -> ExerciseExplanation
}

/// Implémentation par défaut du fetcher : V1 throw systématiquement. À remplacer
/// par `LeonExerciseExplanationFetcher` (Edge Function `sage-exercise-explanation`)
/// quand l'API est livrée — la signature ne change pas.
public struct UnavailableRemoteFetcher: ExerciseExplanationRemoteFetcher {
    public init() {}
    public func fetch(
        exercise: AdaptedExercise,
        language: String
    ) async throws -> ExerciseExplanation {
        throw ExerciseExplanationError.notAvailable
    }
}

public final class DefaultExerciseExplanationService: ExerciseExplanationServiceProtocol {
    private static let logger = Logger(
        subsystem: "com.sopddl.coachingsage",
        category: "exercise-explanation"
    )

    private let remote: ExerciseExplanationRemoteFetcher
    private let cacheDirectory: URL
    private let fileManager: FileManager
    private let supportedLanguages: Set<String> = ["fr", "en"]

    public init(
        remote: ExerciseExplanationRemoteFetcher = UnavailableRemoteFetcher(),
        cacheDirectory: URL? = nil,
        fileManager: FileManager = .default
    ) {
        self.remote = remote
        self.fileManager = fileManager
        if let cacheDirectory {
            self.cacheDirectory = cacheDirectory
        } else {
            // Application Support/ExerciseExplanations/ — créé lazy au 1er write.
            let appSupport = (try? fileManager.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )) ?? URL(fileURLWithPath: NSTemporaryDirectory())
            self.cacheDirectory = appSupport.appendingPathComponent("ExerciseExplanations", isDirectory: true)
        }
    }

    public func explanation(
        for exercise: AdaptedExercise,
        language: String
    ) async throws -> ExerciseExplanation {
        let lang = language.lowercased()
        guard supportedLanguages.contains(lang) else {
            throw ExerciseExplanationError.unsupportedLanguage(language)
        }

        // 1. Seed catalogue manuel — hit immédiat, zéro IO.
        if let seed = ExerciseExplanationSeed.explanation(for: exercise, language: lang) {
            return seed
        }

        // 2. Cache disque.
        if let cached = try? readCache(for: exercise, language: lang) {
            return cached
        }

        // 3. Fetch IA Léon on-demand (V1 stub → throw .notAvailable).
        let fetched: ExerciseExplanation
        do {
            fetched = try await remote.fetch(exercise: exercise, language: lang)
        } catch {
            // Caller fallback tip pattern.
            throw ExerciseExplanationError.notAvailable
        }

        // 4. Persist cache (best-effort, ne fait pas échouer la requête).
        try? writeCache(fetched, for: exercise, language: lang)
        return fetched
    }

    // MARK: - Cache disque

    func cacheURL(for exercise: AdaptedExercise, language: String) -> URL {
        let key = cacheKey(for: exercise)
        return cacheDirectory
            .appendingPathComponent(language, isDirectory: true)
            .appendingPathComponent("\(key).json")
    }

    /// SHA256 du `originalName` (canonique, pas affecté par les substitutions
    /// runtime) en hex. Stable entre runs.
    static func cacheKey(for exercise: AdaptedExercise) -> String {
        sha256Hex(exercise.originalName)
    }

    func cacheKey(for exercise: AdaptedExercise) -> String {
        Self.cacheKey(for: exercise)
    }

    func readCache(
        for exercise: AdaptedExercise,
        language: String
    ) throws -> ExerciseExplanation {
        let url = cacheURL(for: exercise, language: language)
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(ExerciseExplanation.self, from: data)
    }

    func writeCache(
        _ explanation: ExerciseExplanation,
        for exercise: AdaptedExercise,
        language: String
    ) throws {
        let url = cacheURL(for: exercise, language: language)
        let dir = url.deletingLastPathComponent()
        try fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        let data = try JSONEncoder().encode(explanation)
        try data.write(to: url, options: [.atomic])
    }
}

// MARK: - SHA256 utilitaire (Foundation pure, pas de CryptoKit pour iOS 17 min)

import CryptoKit

private func sha256Hex(_ input: String) -> String {
    let data = Data(input.utf8)
    let digest = SHA256.hash(data: data)
    return digest.map { String(format: "%02x", $0) }.joined()
}
