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
    case freeText(LocalizedText)

    private enum CodingKeys: String, CodingKey {
        case freeText
        case value, unit, qualifier, style, modifier
    }

    public init(from decoder: Decoder) throws {
        // Décodeur tolérant : { "freeText": {fr,en,es} } → libre ; { "value","unit",… } →
        // structuré ; une String nue (legacy improbable, dose est un champ neuf) → freeText.fr.
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
        }
    }

    /// Secondes pour le minuteur, ou `nil` si non chronométrable (souffle/cycles/freeText).
    /// `nil` → l'appelant retombe sur `SessionDurationParser` (string legacy) en back-compat.
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

    private static func compose(_ d: StructuredDose, lang: String) -> String {
        let isSingular = (d.value == "1")
        let noun = unitNoun(d.unit, lang: lang, singular: isSingular)
        var parts: [String] = []

        if lang == "en" {
            // EN : adjectif de style AVANT le nom (« 5 Ujjayi breaths », « 3 breath-led cycles »).
            parts.append(d.value)
            if let s = d.style, let w = styleWord(s, lang: lang) { parts.append(w) }
            parts.append(noun)
        } else {
            // FR/ES : style APRÈS le nom (« 5 respirations Ujjayi »).
            parts.append(d.value)
            parts.append(noun)
            if let s = d.style, let w = styleWord(s, lang: lang) { parts.append(w) }
        }
        if let q = d.qualifier { parts.append(qualifierPhrase(q, lang: lang)) }
        if let m = d.modifier { parts.append(modifierWord(m, lang: lang)) }
        return parts.joined(separator: " ")
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
        case .strikes:    return pick(("frappe", "frappes"), ("strike", "strikes"), ("golpe", "golpes"))
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
