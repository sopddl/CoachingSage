// Coaching/Session/String+SessionDisplay.swift
// Story 3.35e — assainit les libellés affichés dans les séances : retire les « / »
// (jamais de slash à l'écran, retour Sophie 2026-06-03) en les remplaçant par un
// séparateur « · ». Ex : « Run/walk découverte » → « Run · walk découverte »,
// « 1 min / 1 min 30 » → « 1 min · 1 min 30 ».
import Foundation

extension String {
    var sanitizedForDisplay: String {
        let replaced = replacingOccurrences(of: "/", with: " · ")
        // Compacte les espaces multiples introduits par le remplacement.
        let collapsed = replaced
            .replacingOccurrences(of: "  ", with: " ")
            .replacingOccurrences(of: "  ", with: " ")
        return collapsed.trimmingCharacters(in: .whitespaces)
    }
}
