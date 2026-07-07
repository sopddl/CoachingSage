// Coaching/Session/VoicePronunciationOverrides.swift
// Story 3.35 (AC8) — table de prononciation de secours + dé-jargonnage des phrases
// vocales. Deux objectifs :
//   1. Le TTS prononce mal certains sigles (VO2max, FTP, RPE…) → on les réécrit
//      en une forme parlable.
//   2. On ne fait PAS dire à l'oral un terme technique non expliqué : on lit son
//      équivalent grand public (ex. « EN2 » → « endurance 2 », « Z2 » → « zone 2 »).
// 100% pur & testable. Extensible : ajouter une entrée dans la table par langue.
import Foundation

enum VoicePronunciationOverrides {

    /// Réécrit une phrase pour la lecture TTS dans la langue donnée ("fr"/"en").
    /// Remplacement insensible à la casse, **borné aux mots entiers** (`\b`) pour
    /// ne pas matcher à l'intérieur d'un mot (ex. « RPE » dans « Bu**rpe**es »),
    /// le plus spécifique d'abord.
    static func apply(to phrase: String, language: String) -> String {
        var result = phrase
        for (pattern, replacement) in table(for: language) {
            let escaped = NSRegularExpression.escapedPattern(for: pattern)
            result = result.replacingOccurrences(
                of: "\\b\(escaped)\\b",
                with: replacement,
                options: [.regularExpression, .caseInsensitive]
            )
        }
        return result
    }

    /// Couples (motif technique → forme parlable). Ordre = du plus spécifique au
    /// plus générique pour éviter qu'un motif court mange un motif long.
    static func table(for language: String) -> [(String, String)] {
        let isFR = language.hasPrefix("fr")
        var entries: [(String, String)] = [
            ("VO2max", isFR ? "V O 2 max" : "V O 2 max"),
            ("VO2", "V O 2"),
            ("FTP", "F T P"),
            ("RPE", isFR ? "effort perçu" : "perceived effort"),
            ("EN1", isFR ? "endurance 1" : "endurance 1"),
            ("EN2", isFR ? "endurance 2" : "endurance 2"),
            ("Daniels-E", isFR ? "Daniels facile" : "Daniels easy"),
            ("Daniels-M", isFR ? "Daniels marathon" : "Daniels marathon"),
            ("Daniels-T", isFR ? "Daniels seuil" : "Daniels threshold"),
            ("Daniels-I", isFR ? "Daniels intervalle" : "Daniels interval"),
            ("Daniels-R", isFR ? "Daniels répétition" : "Daniels repetition"),
        ]
        // Zones Z1..Z5 → "zone N" (après les motifs spécifiques).
        for n in 1...5 {
            entries.append(("Z\(n)", isFR ? "zone \(n)" : "zone \(n)"))
        }
        return entries
    }
}
