import Foundation

/// Texte de contenu multilingue (fr/en/es) porté du template JSON jusqu'à
/// l'affichage. Cf chantier i18n FR/EN/ES (Story B1).
///
/// Décodage **tolérant** : accepte indifféremment
/// - une String JSON nue : `"Sortie longue"` (templates encore FR-only + records
///   persistés legacy avant B1) → `{ fr: "Sortie longue" }`,
/// - un objet : `{ "fr": "…", "en": "…", "es": "…" }` (en/es optionnels pendant
///   la traduction incrémentale B2).
///
/// `fr` est la **clé canonique obligatoire** : c'est la valeur de référence pour
/// tout le matching interne (findExercise, pattern resolver, illustrations,
/// completion keys). Ne JAMAIS faire de matching sur `resolved(locale)`.
///
/// Encode toujours en objet → re-persistance forward-compatible.
public struct LocalizedText: Codable, Equatable, Sendable, Hashable {
    public let fr: String
    public let en: String?
    public let es: String?

    public init(fr: String, en: String? = nil, es: String? = nil) {
        self.fr = fr
        self.en = en
        self.es = es
    }

    private enum CodingKeys: String, CodingKey { case fr, en, es }

    public init(from decoder: Decoder) throws {
        // Branche 1 : String JSON nue (legacy / template FR-only).
        if let single = try? decoder.singleValueContainer(),
           let raw = try? single.decode(String.self) {
            self.fr = raw
            self.en = nil
            self.es = nil
            return
        }
        // Branche 2 : objet { fr, en?, es? }. `fr` obligatoire (invariant canonique).
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.fr = try c.decode(String.self, forKey: .fr)
        self.en = try c.decodeIfPresent(String.self, forKey: .en)
        self.es = try c.decodeIfPresent(String.self, forKey: .es)
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(fr, forKey: .fr)
        try c.encodeIfPresent(en, forKey: .en)
        try c.encodeIfPresent(es, forKey: .es)
    }

    /// Valeur affichée pour la locale courante, avec fallback FR si la langue
    /// n'est pas encore traduite (B2 incrémental).
    public func resolved(_ locale: Locale) -> String {
        switch locale.language.languageCode?.identifier {
        case "en": return en ?? fr
        case "es": return es ?? fr
        default:   return fr
        }
    }

    /// Valeur canonique (= `fr`) : référence pour tout matching interne.
    public var canonical: String { fr }
}

/// Ergonomie previews/tests/catalogue synthétique : un literal String devient un
/// `LocalizedText` FR-only. NB : ne s'applique qu'aux **literals**, pas aux
/// variables `String` (qui doivent wrapper explicitement `LocalizedText(fr:)` —
/// force à réfléchir à la traduction). Aucun impact prod : le contenu réel vient
/// du décodage JSON, jamais de literals.
extension LocalizedText: ExpressibleByStringLiteral, ExpressibleByStringInterpolation {
    public init(stringLiteral value: String) {
        self.init(fr: value)
    }

    /// Couvre aussi les literals interpolés (`"Bloc \(i)"`) en previews/tests.
    /// Comme pour le stringLiteral : ne s'applique qu'aux literals, pas aux
    /// variables `String` (qui wrappent explicitement `LocalizedText(fr:)`).
    public init(stringInterpolation: DefaultStringInterpolation) {
        self.init(fr: String(stringInterpolation: stringInterpolation))
    }
}

public extension Optional where Wrapped == LocalizedText {
    /// Résolution localisée d'un champ optionnel (warmup/cooldown/notes).
    func resolved(_ locale: Locale) -> String? {
        self?.resolved(locale)
    }

    /// Valeur canonique d'un champ optionnel.
    var canonical: String? { self?.canonical }
}
