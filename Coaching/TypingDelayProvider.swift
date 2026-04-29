// Coaching/TypingDelayProvider.swift
// Story 3.1 — abstraction du delay du typing indicator Léon (review P1-5).
// Sans abstraction, Task.sleep inline rend les tests unitaires lents (3-6s/test) ou pollue les env vars.
// Avec injection : NoTypingDelay en test = tests rapides et déterministes.
import Foundation

protocol TypingDelayProvider: Sendable {
    /// Attente simulée pour la "réflexion" Léon avant chaque question.
    /// Production : 600-1200ms aléatoire. Test : no-op.
    func wait() async
}

/// Implémentation production : delay aléatoire 600-1200ms (range défini AC2 du draft).
struct RandomTypingDelay: TypingDelayProvider {
    let minMilliseconds: UInt64
    let maxMilliseconds: UInt64

    init(minMs: UInt64 = 600, maxMs: UInt64 = 1_200) {
        self.minMilliseconds = minMs
        self.maxMilliseconds = maxMs
    }

    func wait() async {
        let ms = UInt64.random(in: minMilliseconds...maxMilliseconds)
        try? await Task.sleep(nanoseconds: ms * 1_000_000)
    }
}

/// Implémentation no-op pour tests unitaires + tests UI.
/// Aussi utilisable via env var `DISABLE_LEON_TYPING_DELAY=1` (test UI ad-hoc).
struct NoTypingDelay: TypingDelayProvider {
    func wait() async {}
}
