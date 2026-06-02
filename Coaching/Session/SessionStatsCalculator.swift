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

    /// Mapping RPE 1-10 → niveau jauge effort 1-5 (Story 3.19 Jalon 3).
    /// Clampé : valeurs hors plage tombent dans le bucket le plus proche.
    /// 1-2 → 1 (Doux), 3-4 → 2 (Modéré), 5-6 → 3 (Soutenu), 7-8 → 4 (Difficile), 9-10 → 5 (Maximal).
    static func effortLevel(rpe: Int) -> Int {
        let clamped = min(10, max(1, rpe))
        return min(5, max(1, (clamped + 1) / 2))
    }

    /// Story 3.32 (AC5) — libellés figés de l'**Intensité** du HUB, échelle 1-5
    /// commune à TOUS les sports, affichée identiquement (pas de "RPE N" brut).
    /// FR : Très facile · Facile · Modéré · Soutenu · Intense.
    /// Distinct de `effortLabel` (Doux/Modéré/Soutenu/Difficile/Maximal) conservé
    /// pour les usages existants (EffortGauge a11y, cards). Clampé.
    static func intensityLabel(level: Int) -> LocalizedStringKey {
        switch min(5, max(1, level)) {
        case 1: return "coaching.session.intensity.1"
        case 2: return "coaching.session.intensity.2"
        case 3: return "coaching.session.intensity.3"
        case 4: return "coaching.session.intensity.4"
        default: return "coaching.session.intensity.5"
        }
    }

    /// Clé i18n du label sémantique du niveau d'effort (1-5). Clampé.
    static func effortLabel(level: Int) -> LocalizedStringKey {
        switch min(5, max(1, level)) {
        case 1: return "coaching.effort.level.1"
        case 2: return "coaching.effort.level.2"
        case 3: return "coaching.effort.level.3"
        case 4: return "coaching.effort.level.4"
        default: return "coaching.effort.level.5"
        }
    }

    /// Raccourci d'affichage pour une zone d'entraînement (utilisé dans la
    /// grille stats du hero où l'espace est contraint). Les noms Daniels
    /// (Daniels-E/M/T/I/R) sont compactés en "D-x" pour éviter la troncature
    /// "Dani…" sur les écrans étroits. Les autres zones (Z1, EN1, FTP-Z2,
    /// Sweetspot, race.pace…) sont déjà courtes et passent telles quelles.
    static func displayZone(_ zone: String) -> String {
        let lower = zone.lowercased()
        if lower.hasPrefix("daniels-") {
            // "Daniels-E" → "D-E", "Daniels-T" → "D-T", etc.
            let suffix = zone.dropFirst("daniels-".count).uppercased()
            return "D-\(suffix)"
        }
        if lower == "sweetspot" || lower == "sweet-spot" {
            return "SS"
        }
        return zone
    }
}
