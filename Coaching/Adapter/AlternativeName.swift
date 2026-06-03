// Coaching/Adapter/AlternativeName.swift
// Bug #8 (Sophie 2026-06-03) — une alternative dont le nom embarque une durée
// explicite ("Sortie indoor-trainer FTP-Z1 35 min") était substituée en gardant
// la durée du parent ("40 min") → le nom affichait 35 mais la pastille et le
// minuteur FOCUS partaient sur 40. On extrait la durée du nom de l'alternative
// pour qu'elle fasse foi.
import Foundation

enum AlternativeName {
    /// Renvoie la durée embarquée dans le nom d'une alternative, au format
    /// compris par `SessionDurationParser` ("35 min", "1h30", "1h"). nil si le
    /// nom ne contient pas de durée → on garde celle du parent.
    static func embeddedDuration(in name: String) -> String? {
        // Heures d'abord ("1h30", "1 h 30", "1h") — plus spécifique.
        if let r = name.range(of: #"\d+\s*h(\s*\d+)?"#, options: .regularExpression) {
            return name[r].replacingOccurrences(of: " ", with: "")
        }
        // Minutes ("35 min", "35min", "50 minutes").
        if let r = name.range(of: #"\d+\s*min"#, options: .regularExpression) {
            return String(name[r]).replacingOccurrences(of: "  ", with: " ")
        }
        return nil
    }
}
