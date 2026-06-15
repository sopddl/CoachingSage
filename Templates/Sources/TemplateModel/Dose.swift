import Foundation

// Chantier structuration i18n du dosage (party figée 2026-06-14, Lot 1 pilote yoga).
//
// Problème : `duration`/`reps` étaient des `String` plates FR rendues verbatim → fuite FR
// en EN/ES (« 3 min (~10 cycles respiratoires) »). Décision A = STRUCTURER le modèle.
//
// Un dosage est SOIT structuré (`StructuredDose`) SOIT libre (`freeText: LocalizedText`),
// jamais à moitié (T2 tout-ou-rien, Sally « no Frankenstein »). `DoseFormatter` est la
// SOURCE UNIQUE de rendu (3 vues d'affichage + label de phase du minuteur), localisée
// FR/EN/ES par une table pure (pas de .xcstrings : doit être atteignable depuis le package
// Templates, y compris le filet de régression `NoFreeTextFRInDose`).
//
// Enums fermés mais extensibles par pilote-sport : tout ce qui n'entre pas dans le gabarit
// tombe en `freeText` traduit à la main → aucune fuite possible.

// MARK: - Taxonomie (enums fermés)

/// Unité d'un dosage structuré. Fermé, extensible par pilote-sport.
public enum DoseUnit: String, Codable, Equatable, Sendable, CaseIterable {
    case reps
    case seconds
    case minutes
    case meters
    case kilometers
    case breaths      // yoga : respirations
    case cycles       // yoga : cycles respiratoires / d'enchaînement
    case holds        // tenues
    case serves       // services (tennis)
    case passes       // passes (sports co)
    case strikes      // frappes (combat)
    case sequences    // séquences (yoga avancé / danse)
    case points       // points (tennis / sports de score)
}

/// Qualificateur optionnel (« par côté », « par posture »…). En TOUTES LETTRES au rendu
/// (« par côté », jamais « /côté » = jargon — décision Sally). Fermé, extensible par sport.
public enum DoseQualifier: String, Codable, Equatable, Sendable, CaseIterable {
    case perSide
    case perLeg
    case perArm
    case perFoot
    case perShoulder
    case perPose       // par posture
    case perPosition   // par position (gainage cyclisme : ventral/dorsal)
    case perVariation  // par variante
    case perSet        // par série
    case perRound      // par round
    case perLetter     // Y/T/W
    case perAttempt    // par essai
    case perPattern
    case perHold       // par tenue (yoga)
    case perEach       // chacune (yoga)
}

/// Style respiratoire (yoga). Optionnel. Position post-nominale FR/ES, pré-nominale EN.
public enum DoseStyle: String, Codable, Equatable, Sendable, CaseIterable {
    case ujjayi
    case dirgha
    case breathLed     // « au souffle » / « breath-led »
}

/// Modificateur d'unité (optionnel). « effectives » (reps en réserve) / « libre ».
public enum DoseModifier: String, Codable, Equatable, Sendable, CaseIterable {
    case effective
    case free
}

/// Activité d'un segment d'intervalle course/marche (Lot 2 running). Fermé, extensible
/// par pilote-sport. Rendu localisé en phrase post-nominale (« 3 min de course »,
/// « 1 min à allure 5K »). Les gloses redondantes du texte FR source (« (RPE 8) »,
/// « (tu peux parler) ») sont DROPPÉES : l'intensité est portée par `target_zone`.
public enum DoseActivity: String, Codable, Equatable, Sendable, CaseIterable {
    case running                  // course
    case walking                  // marche
    case runningSlow              // course lente
    case walkingFast              // marche rapide
    case walkingRecovery          // marche de récupération
    case accelerationProgressive  // accélération progressive
    case easyJog                  // footing tranquille
    case pace5K                   // à allure 5K
    case pace10K                  // à allure 10K
    case work                     // HIIT : phase d'effort
    case rest                     // HIIT : phase de récupération
    // Lot 8 — tennis/football : vocabulaire de drill du segment d'effort. Le segment de
    // récup réutilise `rest`/`walkingRecovery`. Rendu post-nominal (« 5 min de cross »).
    case crossCourt               // tennis : cross / cross-court
    case sequenceDrill            // tennis : séquence (drill enchaîné)
    case game                     // tennis/foot : jeu / jeu réduit
    case patternDrill             // tennis : pattern (schéma de jeu)
    case downTheLine              // tennis : long de ligne
    case tieBreak                 // tennis : tie-break
    case sprint                   // tennis/foot : sprint
    case strikesDrill             // tennis : frappes (bloc minuté)
}

/// Un segment d'un dosage en intervalle (« 3 min course + 2 min marche »). Réutilise la
/// grammaire de `StructuredDose` (value + unit) et porte une `activity` localisée. L'activité
/// est OPTIONNELLE (Lot 8) : un segment de comptage pur (« 30 frappes ») ou un effort nu
/// (« 5 min » + récup) n'en porte pas → seul « value noun » est rendu.
public struct IntervalSegment: Codable, Equatable, Sendable {
    public let value: String
    public let unit: DoseUnit
    public let activity: DoseActivity?

    public init(value: String, unit: DoseUnit, activity: DoseActivity? = nil) {
        self.value = value
        self.unit = unit
        self.activity = activity
    }
}

// MARK: - StructuredDose

/// Dosage régulier décomposé en atomes traduisibles. `value` reste une `String` pour garder
/// les plages (« 8-10 ») — aucun calcul d'affichage dessus.
public struct StructuredDose: Codable, Equatable, Sendable {
    public let value: String
    public let unit: DoseUnit
    public let qualifier: DoseQualifier?
    public let style: DoseStyle?
    public let modifier: DoseModifier?

    public init(
        value: String,
        unit: DoseUnit,
        qualifier: DoseQualifier? = nil,
        style: DoseStyle? = nil,
        modifier: DoseModifier? = nil
    ) {
        self.value = value
        self.unit = unit
        self.qualifier = qualifier
        self.style = style
        self.modifier = modifier
    }
}

// MARK: - Dose

/// Un dosage : structuré OU texte libre traduit. Jamais les deux (tout-ou-rien T2).
public enum Dose: Codable, Equatable, Sendable {
    case structured(StructuredDose)
    case interval([IntervalSegment])
    case freeText(LocalizedText)

    private enum CodingKeys: String, CodingKey {
        case freeText
        case segments
        case value, unit, qualifier, style, modifier
    }

    public init(from decoder: Decoder) throws {
        // Décodeur tolérant : { "freeText": {fr,en,es} } → libre ; { "segments": [...] } →
        // intervalle ; { "value","unit",… } → structuré ; une String nue (legacy improbable,
        // dose est un champ neuf) → freeText.fr.
        if let single = try? decoder.singleValueContainer(),
           let raw = try? single.decode(String.self) {
            self = .freeText(LocalizedText(fr: raw))
            return
        }
        let c = try decoder.container(keyedBy: CodingKeys.self)
        if let ft = try c.decodeIfPresent(LocalizedText.self, forKey: .freeText) {
            self = .freeText(ft)
            return
        }
        if let segs = try c.decodeIfPresent([IntervalSegment].self, forKey: .segments) {
            self = .interval(segs)
            return
        }
        let value = try c.decode(String.self, forKey: .value)
        let unit = try c.decode(DoseUnit.self, forKey: .unit)
        let qualifier = try c.decodeIfPresent(DoseQualifier.self, forKey: .qualifier)
        let style = try c.decodeIfPresent(DoseStyle.self, forKey: .style)
        let modifier = try c.decodeIfPresent(DoseModifier.self, forKey: .modifier)
        self = .structured(StructuredDose(
            value: value, unit: unit, qualifier: qualifier, style: style, modifier: modifier
        ))
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .freeText(let ft):
            try c.encode(ft, forKey: .freeText)
        case .interval(let segs):
            try c.encode(segs, forKey: .segments)
        case .structured(let d):
            try c.encode(d.value, forKey: .value)
            try c.encode(d.unit, forKey: .unit)
            try c.encodeIfPresent(d.qualifier, forKey: .qualifier)
            try c.encodeIfPresent(d.style, forKey: .style)
            try c.encodeIfPresent(d.modifier, forKey: .modifier)
        }
    }
}

// MARK: - DoseFormatter (source unique de rendu)

/// Rend un `Dose` en libellé localisé FR/EN/ES (UI + label minuteur) et calcule les secondes
/// pour le minuteur. Table de gabarits PURE (pas de bundle) → atteignable depuis les tests
/// du package.
public enum DoseFormatter {

    /// Libellé affichable, localisé. C'est le SEUL point de rendu d'un dosage.
    public static func string(_ dose: Dose, locale: Locale) -> String {
        switch dose {
        case .freeText(let ft):
            return ft.resolved(locale)
        case .structured(let d):
            return compose(d, lang: lang(locale))
        case .interval(let segs):
            let l = lang(locale)
            return segs.map { composeSegment($0, lang: l) }.joined(separator: " + ")
        }
    }

    /// Variante « reps compactes » pour la MUSCU (party muscu : affichage reps-héros/chip
    /// minimal « 3 × 12 » / « 10 par côté », PAS « 3 × 12 reps »). Identique à
    /// `string(_:locale:)` SAUF qu'on omet le nom d'unité quand `unit == .reps` ; les autres
    /// unités (tenue « 30 s ») gardent leur nom, freeText/intervalle inchangés. Source unique :
    /// réutilise `compose()`.
    public static func repsCompactString(_ dose: Dose, locale: Locale) -> String {
        if case .structured(let d) = dose, d.unit == .reps {
            return compose(d, lang: lang(locale), omitNoun: true)
        }
        return string(dose, locale: locale)
    }

    /// Secondes pour le minuteur, ou `nil` si non chronométrable (souffle/cycles/freeText/
    /// intervalle). `nil` → l'appelant retombe sur `SessionDurationParser` (string FR legacy,
    /// chiffres language-agnostic) en back-compat : le timer reste piloté par le canonical FR,
    /// pas de pièce non-réversible (cf. SessionTimerPhase, labels run/walk déjà typés).
    public static func timerSeconds(_ dose: Dose) -> Int? {
        guard case .structured(let d) = dose else { return nil }
        guard let n = leadingInt(d.value) else { return nil }
        switch d.unit {
        case .minutes: return n * 60
        case .seconds: return n
        default:       return nil
        }
    }

    // MARK: Composition

    private static func compose(_ d: StructuredDose, lang: String, omitNoun: Bool = false) -> String {
        let isSingular = (d.value == "1")
        let noun = unitNoun(d.unit, lang: lang, singular: isSingular)
        var parts: [String] = []

        if lang == "en" {
            // EN : adjectif de style AVANT le nom (« 5 Ujjayi breaths », « 3 breath-led cycles »).
            parts.append(d.value)
            if let s = d.style, let w = styleWord(s, lang: lang) { parts.append(w) }
            if !omitNoun { parts.append(noun) }
        } else {
            // FR/ES : style APRÈS le nom (« 5 respirations Ujjayi »).
            parts.append(d.value)
            if !omitNoun { parts.append(noun) }
            if let s = d.style, let w = styleWord(s, lang: lang) { parts.append(w) }
        }
        if let q = d.qualifier { parts.append(qualifierPhrase(q, lang: lang)) }
        if let m = d.modifier { parts.append(modifierWord(m, lang: lang)) }
        return parts.joined(separator: " ")
    }

    /// Un segment d'intervalle : « 3 min de course », « 1 min à allure 5K »,
    /// « 100 m d'accélération progressive ». La phrase d'activité porte sa propre préposition.
    private static func composeSegment(_ s: IntervalSegment, lang: String) -> String {
        let isSingular = (s.value == "1")
        let noun = unitNoun(s.unit, lang: lang, singular: isSingular)
        guard let a = s.activity else { return "\(s.value) \(noun)" }
        return "\(s.value) \(noun) \(activityPhrase(a, lang: lang))"
    }

    private static func activityPhrase(_ a: DoseActivity, lang: String) -> String {
        func t(_ fr: String, _ en: String, _ es: String) -> String {
            (lang == "en") ? en : (lang == "es") ? es : fr
        }
        switch a {
        case .running:                 return t("de course", "running", "de carrera")
        case .walking:                 return t("de marche", "walking", "de caminata")
        case .runningSlow:             return t("de course lente", "slow running", "de carrera lenta")
        case .walkingFast:             return t("de marche rapide", "brisk walking", "de caminata rápida")
        case .walkingRecovery:         return t("de marche de récupération", "recovery walk", "de caminata de recuperación")
        case .accelerationProgressive: return t("d'accélération progressive", "progressive acceleration", "de aceleración progresiva")
        case .easyJog:                 return t("de footing tranquille", "easy jogging", "de trote suave")
        case .pace5K:                  return t("à allure 5K", "at 5K pace", "a ritmo 5K")
        case .pace10K:                 return t("à allure 10K", "at 10K pace", "a ritmo 10K")
        case .work:                    return t("d'effort", "work", "de trabajo")
        case .rest:                    return t("de récup", "rest", "de descanso")
        case .crossCourt:              return t("de cross", "cross-court", "cruzado")
        case .sequenceDrill:           return t("de séquence", "sequence", "de secuencia")
        case .game:                    return t("de jeu", "of play", "de juego")
        case .patternDrill:            return t("de pattern", "of patterns", "de patrones")
        case .downTheLine:             return t("de long de ligne", "down-the-line", "paralelos")
        case .tieBreak:                return t("de tie-break", "tie-break", "de tie-break")
        case .sprint:                  return t("de sprint", "sprint", "de sprint")
        case .strikesDrill:            return t("de frappes", "of hitting", "de golpeo")
        }
    }

    private static func lang(_ locale: Locale) -> String {
        switch locale.language.languageCode?.identifier {
        case "en": return "en"
        case "es": return "es"
        default:   return "fr"
        }
    }

    /// Premier entier d'une `value` (gère plages « 20-30 » → 20 ; « 5 » → 5). nil si aucun.
    private static func leadingInt(_ value: String) -> Int? {
        var digits = ""
        for ch in value {
            if ch.isNumber { digits.append(ch) } else if !digits.isEmpty { break }
        }
        return Int(digits)
    }

    // MARK: Tables FR/EN/ES (pures)

    /// Nom d'unité (singulier, pluriel) par langue. s/min/m/km invariants.
    private static func unitNoun(_ unit: DoseUnit, lang: String, singular: Bool) -> String {
        func pick(_ fr: (String, String), _ en: (String, String), _ es: (String, String)) -> String {
            let pair = (lang == "en") ? en : (lang == "es") ? es : fr
            return singular ? pair.0 : pair.1
        }
        switch unit {
        case .reps:       return pick(("rep", "reps"), ("rep", "reps"), ("rep", "reps"))
        case .seconds:    return "s"
        case .minutes:    return "min"
        case .meters:     return "m"
        case .kilometers: return "km"
        case .breaths:    return pick(("respiration", "respirations"), ("breath", "breaths"), ("respiración", "respiraciones"))
        case .cycles:     return pick(("cycle", "cycles"), ("cycle", "cycles"), ("ciclo", "ciclos"))
        case .holds:      return pick(("tenue", "tenues"), ("hold", "holds"), ("posición", "posiciones"))
        case .serves:     return pick(("service", "services"), ("serve", "serves"), ("servicio", "servicios"))
        case .passes:     return pick(("passe", "passes"), ("pass", "passes"), ("pase", "pases"))
        case .strikes:    return pick(("frappe", "frappes"), ("shot", "shots"), ("golpe", "golpes"))
        case .sequences:  return pick(("séquence", "séquences"), ("sequence", "sequences"), ("secuencia", "secuencias"))
        case .points:     return pick(("point", "points"), ("point", "points"), ("punto", "puntos"))
        }
    }

    private static func styleWord(_ style: DoseStyle, lang: String) -> String? {
        switch style {
        case .ujjayi: return "Ujjayi"
        case .dirgha: return "Dirgha"
        case .breathLed:
            switch lang {
            case "en": return "breath-led"
            case "es": return "al ritmo de la respiración"
            default:   return "au rythme du souffle"
            }
        }
    }

    private static func qualifierPhrase(_ q: DoseQualifier, lang: String) -> String {
        func t(_ fr: String, _ en: String, _ es: String) -> String {
            (lang == "en") ? en : (lang == "es") ? es : fr
        }
        switch q {
        case .perSide:      return t("par côté", "per side", "por lado")
        case .perLeg:       return t("par jambe", "per leg", "por pierna")
        case .perArm:       return t("par bras", "per arm", "por brazo")
        case .perFoot:      return t("par pied", "per foot", "por pie")
        case .perShoulder:  return t("par épaule", "per shoulder", "por hombro")
        case .perPose:      return t("par posture", "per pose", "por postura")
        case .perPosition:  return t("par position", "per position", "por posición")
        case .perVariation: return t("par variante", "per variation", "por variación")
        case .perSet:       return t("par série", "per set", "por serie")
        case .perRound:     return t("par round", "per round", "por ronda")
        case .perLetter:    return t("par lettre", "per letter", "por letra")
        case .perAttempt:   return t("par essai", "per attempt", "por intento")
        case .perPattern:   return t("par pattern", "per pattern", "por patrón")
        case .perHold:      return t("par tenue", "per hold", "por posición")
        case .perEach:      return t("chacune", "each", "cada una")
        }
    }

    private static func modifierWord(_ m: DoseModifier, lang: String) -> String {
        func t(_ fr: String, _ en: String, _ es: String) -> String {
            (lang == "en") ? en : (lang == "es") ? es : fr
        }
        switch m {
        case .effective: return t("effectives", "effective", "efectivas")
        case .free:      return t("en libre", "free", "libre")
        }
    }
}
