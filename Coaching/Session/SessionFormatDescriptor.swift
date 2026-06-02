// Coaching/Session/SessionFormatDescriptor.swift
// Story 3.32 — calcule la case "Format" caméléon du HUB séance (AC4).
// Mapping data-driven par SportCode (effectif) / SessionType → un libellé court,
// jamais vide, jamais "—" (AC10). 100% logique pure & testable.
//
// Le descripteur renvoie un `Format` structuré (cas + paramètres numériques) ;
// la VUE résout l'i18n via interpolation de placeholders (`Text("key \(n)")`),
// jamais en construisant la *clé* par interpolation (anti-pattern xcstrings, cf
// hotfix 2026-05-12 `LocalizedStringKey("foo.\(bar)")`).
//
// Mode dégradé assumé (R1 spec + chantier C2 "format-aware templates") : quand
// la donnée structurante manque (tours, work/rest, séance-clé), on retombe
// proprement sur "N blocs"/"N intervalles" sans bloquer.
import Foundation
import TemplateModel

enum SessionFormatDescriptor {

    /// Forme structurée du format d'une séance. Chaque cas porte les paramètres
    /// numériques nécessaires au rendu i18n côté vue.
    enum Format: Equatable {
        /// Strength + fallback cardio sans séance-clé détectable → "N blocs".
        case blocks(Int)
        /// HIIT avec work/rest détectés → "N tours · 40/20".
        case rounds(count: Int, workSeconds: Int, restSeconds: Int)
        /// HIIT sans work/rest exploitable → "N intervalles".
        case intervals(Int)
        /// Yoga / mobilité → "N postures".
        case postures(Int)
        /// Natation → "N séries".
        case series(Int)
        /// Cardio avec séance-clé répétée détectable (ex. "4×800 m"). Chaîne
        /// numérique/unité, neutre côté langue (pas de clé i18n).
        case keySession(String)
        /// Fallback générique → "N exercices".
        case exercises(Int)
    }

    /// Résout le format pour une séance et un **code sport effectif** (déjà
    /// résolu par `SessionSportInference` côté HUB : triathlon → sa discipline).
    static func format(for session: AdaptedSession, sportCode: String) -> Format {
        let n = session.exercises.count

        // 1) Résolution prioritaire par sport (plus spécifique que le type).
        switch sportCode {
        case "yoga":
            return .postures(max(n, 1))
        case "swimming":
            return .series(max(n, 1))
        case "hiit":
            return hiitFormat(session)
        case "strengthTraining":
            return .blocks(max(n, 1))
        case "running", "cycling", "hiking":
            return cardioFormat(session)
        default:
            break // tennis/football/triathlon-non-résolu/inconnu → on tente le type
        }

        // 2) Repli par SessionType.
        switch session.type {
        case .interval:
            return hiitFormat(session)
        case .strength:
            return .blocks(max(n, 1))
        case .mobility:
            return .postures(max(n, 1))
        case .endurance, .technique:
            return cardioFormat(session)
        case .mixed, .other, .rest:
            return .exercises(n)
        }
    }

    // MARK: - HIIT

    /// HIIT : "N tours · work/rest" si on sait extraire work & rest, sinon
    /// "N intervalles". Le nombre de tours = `sets` du bloc circuit si présent
    /// (un exo répété R fois), sinon le nombre d'exercices.
    private static func hiitFormat(_ session: AdaptedSession) -> Format {
        let exos = session.exercises
        guard !exos.isEmpty else { return .intervals(0) }

        // Cas circuit : un exo unique porte sets (= tours) + un work/rest.
        if let circuit = exos.first,
           let wr = workRest(from: circuit) {
            let rounds = circuit.sets ?? exos.count
            return .rounds(count: max(rounds, 1), workSeconds: wr.work, restSeconds: wr.rest)
        }
        // Sinon tentative work/rest sur n'importe quel exo, tours = nb d'exos.
        if let wr = exos.compactMap(workRest(from:)).first {
            return .rounds(count: exos.count, workSeconds: wr.work, restSeconds: wr.rest)
        }
        return .intervals(exos.count)
    }

    /// Extrait (work, rest) en secondes d'un exo. Sources tolérées :
    ///   - `duration` au format "40/20", "30s/30s", "40/20s" → (40,20)
    ///   - sinon `duration` numérique simple + `restSeconds` → (duration, rest)
    /// Renvoie nil si rien d'exploitable.
    private static func workRest(from ex: AdaptedExercise) -> (work: Int, rest: Int)? {
        if let d = ex.duration {
            let parts = d.split(separator: "/")
            if parts.count == 2,
               let w = firstInt(in: String(parts[0])),
               let r = firstInt(in: String(parts[1])) {
                return (w, r)
            }
            // "40s" + restSeconds
            if let w = firstInt(in: d), let r = ex.restSeconds {
                return (w, r)
            }
        }
        return nil
    }

    // MARK: - Cardio

    /// Cardio : séance-clé répétée ("4×800 m") si détectable, sinon "N blocs".
    /// Heuristique séance-clé : un exo avec `sets >= 2` et une métrique de
    /// répétition lisible (reps, sinon duration). On compose "sets×metric".
    private static func cardioFormat(_ session: AdaptedSession) -> Format {
        let n = session.exercises.count
        if let key = session.exercises.lazy.compactMap(keySessionString(from:)).first {
            return .keySession(key)
        }
        return .blocks(max(n, 1))
    }

    /// "4×800 m" depuis un exo répété. nil si pas de répétition claire.
    private static func keySessionString(from ex: AdaptedExercise) -> String? {
        guard let sets = ex.sets, sets >= 2 else { return nil }
        let metric = (ex.reps?.trimmingCharacters(in: .whitespaces)).flatMap { $0.isEmpty ? nil : $0 }
            ?? (ex.duration?.trimmingCharacters(in: .whitespaces)).flatMap { $0.isEmpty ? nil : $0 }
        guard let metric, !metric.contains("/") else { return nil } // "/" = work/rest, pas une séance-clé
        return "\(sets)×\(metric)"
    }

    // MARK: - Parsing util

    /// Premier entier rencontré dans une chaîne ("30s" → 30, "x800m" → 800).
    private static func firstInt(in s: String) -> Int? {
        var digits = ""
        for ch in s {
            if ch.isNumber { digits.append(ch) }
            else if !digits.isEmpty { break }
        }
        return Int(digits)
    }
}

extension SessionFormatDescriptor.Format {
    /// Libellé non localisé (anglais simple) — réservé aux tests & previews pour
    /// vérifier AC10 (jamais vide / jamais "—"). L'UI utilise les clés xcstrings.
    var debugLabel: String {
        switch self {
        case .blocks(let n):       return "\(n) blocks"
        case .rounds(let c, let w, let r): return "\(c) rounds · \(w)/\(r)"
        case .intervals(let n):    return "\(n) intervals"
        case .postures(let n):     return "\(n) postures"
        case .series(let n):       return "\(n) series"
        case .keySession(let s):   return s
        case .exercises(let n):    return "\(n) exercises"
        }
    }
}
