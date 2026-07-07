// Coaching/Session/InitialLevelResolver.swift
// Chantier charge muscu V2 — TRANCHE 2. Niveau de départ (échelle cachée 1...5) sans
// historique (G5/D-B). Aucun 1RM, aucun kg : on part d'un médian modulé par le niveau
// déclaré du programme. La consigne charge D-A reste identique pour tous au départ ;
// seul le delta (« un peu plus… ») apparaît après le 1er ressenti loggé.
import Foundation

public enum InitialLevelResolver {

    /// `level` = `Level.rawValue` du programme (beginner / recreational / regular / competitive).
    public static func initialLevel(forProfileLevel level: String) -> Int {
        switch level {
        case "beginner":     return 2
        case "competitive":  return 4
        default:             return 3   // recreational, regular, inconnu → médian
        }
    }
}
