// Coaching/Session/SessionStatsCalculator.swift
// Story 3.18 Phase 2 — calcule les stats résumé pour le hero header SessionDetail :
// zone dominante (la plus fréquente parmi `exercises.targetZone`), RPE estimé
// (heuristique par SessionType ajustée par la zone dominante), couleur RPE.
import Foundation
import SwiftUI
import TemplateModel

enum SessionStatsCalculator {

    /// Renvoie la `targetZone` la plus fréquente parmi les exercices d'une séance.
    /// Tie-break = premier rencontré (ordre stable). Renvoie nil si aucun exo
    /// n'a de zone renseignée.
    static func dominantZone(for session: AdaptedSession) -> String? {
        var counts: [String: Int] = [:]
        var orderSeen: [String] = []
        for ex in session.exercises {
            guard let z = ex.targetZone, !z.isEmpty else { continue }
            if counts[z] == nil { orderSeen.append(z) }
            counts[z, default: 0] += 1
        }
        guard !counts.isEmpty else { return nil }
        var best = orderSeen[0]
        var bestCount = counts[best] ?? 0
        for z in orderSeen.dropFirst() {
            if let c = counts[z], c > bestCount {
                best = z
                bestCount = c
            }
        }
        return best
    }

    /// RPE estimé sur 1-10 dérivé du `SessionType` puis ajusté ±1 selon la zone
    /// dominante (zones intenses = +1, zones douces = −1). Clampé à 1...10.
    static func estimatedRPE(for session: AdaptedSession) -> Int {
        let base: Int
        switch session.type {
        case .endurance: base = 4
        case .interval:  base = 8
        case .technique: base = 4
        case .strength:  base = 7
        case .mixed:     base = 6
        case .mobility:  base = 2
        case .rest:      base = 1
        case .other:     base = 5
        }
        let adj = zoneAdjustment(dominantZone(for: session))
        return min(10, max(1, base + adj))
    }

    /// Renvoie +1 pour les zones de haute intensité, −1 pour les zones douces,
    /// 0 pour le reste (ou si aucune zone détectée). Matching case-insensitive
    /// sur les fragments clés (daniels-t/i/r, ftp z4/z5, threshold pour le +1 ;
    /// daniels-e, ftp z1, en1 pour le −1).
    static func zoneAdjustment(_ zone: String?) -> Int {
        guard let z = zone?.lowercased(), !z.isEmpty else { return 0 }
        // Ordre : on teste d'abord les hautes (plus spécifiques), puis les basses.
        let highMarkers = ["daniels-t", "daniels-i", "daniels-r",
                           "ftp-z4", "ftp z4", "ftpz4",
                           "ftp-z5", "ftp z5", "ftpz5",
                           "threshold", "vo2", "sweetspot", "sweet-spot"]
        for m in highMarkers where z.contains(m) { return 1 }
        let lowMarkers = ["daniels-e", "ftp-z1", "ftp z1", "ftpz1",
                          "ftp-z2", "ftp z2", "ftpz2",
                          "en1", "en2", "recovery", "récup"]
        for m in lowMarkers where z.contains(m) { return -1 }
        return 0
    }

    /// Couleur sémantique pour le badge RPE : vert ≤4, orange 5-7, rouge ≥8.
    static func rpeColor(_ rpe: Int) -> Color {
        switch rpe {
        case ...4:   return .coachingSuccess
        case 5...7:  return .coachingWarning
        default:     return .coachingError
        }
    }
}
