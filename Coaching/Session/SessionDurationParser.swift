// Coaching/Session/SessionDurationParser.swift
// Story 3.35d — parsing robuste des durées de séance, en SECONDES.
// Gère : "1 min" → 60, "1 min 30" → 90, "20 sec"/"20s" → 20, "40" → 40,
// et la décomposition d'un bloc multi-segments séparés par « + » :
//   "1 min course lente + 1 min 30 marche rapide" → [(course lente,60),(marche rapide,90)].
//
// Corrige le bug device 2026-06-03 où "1 min" était lu comme 1 seconde (les
// unités min/sec étaient ignorées).
import Foundation

enum SessionDurationParser {

    /// Un segment d'un bloc (run/walk, etc.).
    struct Segment: Equatable {
        let label: String?   // texte non numérique du segment ("course lente"), nil si aucun
        let seconds: Int
    }

    /// Durée totale en secondes d'un texte simple. nil si aucun nombre.
    /// "1 min 30" → 90 ; "1 min" → 60 ; "20 sec"/"20s"/"20 s" → 20 ; "40" → 40.
    static func seconds(_ text: String?) -> Int? {
        guard let text else { return nil }
        let lower = text.lowercased()
        let scalars = Array(lower)
        guard let firstDigit = scalars.firstIndex(where: { $0.isNumber }) else { return nil }

        // 1er nombre.
        var i = firstDigit
        let a = readInt(scalars, &i)
        skipSpaces(scalars, &i)

        // Unité ?
        if matches(scalars, i, "min") || matches(scalars, i, "mn") {
            i += matches(scalars, i, "min") ? 3 : 2
            // minutes + secondes optionnelles ("1 min 30")
            skipNonDigits(scalars, &i)
            if i < scalars.count, scalars[i].isNumber {
                let b = readInt(scalars, &i)
                return a * 60 + b
            }
            return a * 60
        }
        // "sec" / "s" → secondes ; sinon nombre nu = secondes.
        return a
    }

    /// Décompose un bloc multi-segments séparés par « + ». Si pas de « + »,
    /// renvoie un seul segment (ou vide si non parsable).
    static func segments(_ text: String?) -> [Segment] {
        guard let text else { return [] }
        let parts = text.split(separator: "+")
        guard parts.count >= 2 else {
            // Pas de « + » : un seul segment si on sait lire une durée.
            if let s = seconds(text) {
                return [Segment(label: words(in: text), seconds: s)]
            }
            return []
        }
        return parts.compactMap { part in
            let str = String(part)
            guard let s = seconds(str) else { return nil }
            return Segment(label: words(in: str), seconds: s)
        }
    }

    // MARK: - Helpers

    /// Mots non numériques d'un segment (sans les unités min/sec/mn/s), trimmés.
    /// "1 min 30 marche rapide" → "marche rapide". nil si rien.
    static func words(in text: String) -> String? {
        let tokens = text.lowercased()
            .split(whereSeparator: { $0 == " " || $0 == "," })
            .map(String.init)
            .filter { tok in
                if tok.allSatisfy({ $0.isNumber }) { return false }
                return !["min", "mn", "sec", "s", "secondes", "seconde", "minutes", "minute"].contains(tok)
            }
        let joined = tokens.joined(separator: " ").trimmingCharacters(in: .whitespaces)
        return joined.isEmpty ? nil : joined
    }

    private static func readInt(_ s: [Character], _ i: inout Int) -> Int {
        var digits = ""
        while i < s.count, s[i].isNumber { digits.append(s[i]); i += 1 }
        return Int(digits) ?? 0
    }

    private static func skipSpaces(_ s: [Character], _ i: inout Int) {
        while i < s.count, s[i] == " " { i += 1 }
    }

    private static func skipNonDigits(_ s: [Character], _ i: inout Int) {
        while i < s.count, !s[i].isNumber { i += 1 }
    }

    private static func matches(_ s: [Character], _ i: Int, _ word: String) -> Bool {
        let w = Array(word)
        guard i + w.count <= s.count else { return false }
        for k in 0..<w.count where s[i + k] != w[k] { return false }
        return true
    }
}
