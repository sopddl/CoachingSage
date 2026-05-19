// Coaching/Persistence/AutoTitleBuilder.swift
// Story 3.12 — génère le titre auto d'un `AdaptedProgramRecord.customTitle`
// au format "{Sport localisé} — {Goal localisé}" depuis le sportCode + goal.
//
// Story 3.13 Phase D — supporte un ensemble `secondary: [String]` pour les
// programmes multi-objectifs. Format composite : "Sport — Primary + Sec1 + Sec2".
// Si la longueur dépasse `compositeMaxLength` (40), tronque les secondary en
// "+N autre(s)" pour rester lisible dans la nav bar / cards dashboard.
//
// Le titre est calculé dans la langue IN-APP COURANTE (via `LanguageManager`)
// au moment de la création. L'utilisateur peut ensuite le renommer librement.
// Si l'utilisateur change la langue après, le titre reste figé (acceptable V1).
//
// **Pattern bundle obligatoire** : utilise `locale.localizedBundle` +
// `bundle.localizedString(forKey:value:table:)` pour respecter le switch langue
// in-app. Cf mémoire `memo_locale_strict_string_localized_pattern` (bug TS).
//
// Sport : clé i18n statique `onboarding.sport.{code}` (cf SportCodeMapping).
// Goal : clé i18n du questionnaire `questionnaire.{sport}.q2.option.{goal}`
// (alignée sur `UniversalQuestionnaire.goalOptions(for:)`).
import Foundation

enum AutoTitleBuilder {
    /// Seuil au-delà duquel les secondary sont remplacés par "+N autre(s)" pour
    /// que le titre reste affichable dans la nav bar / card dashboard.
    static let compositeMaxLength = 40

    /// Construit le titre auto pour un programme donné.
    /// - `sportCode` : ex. "running", "strengthTraining"
    /// - `goal` : ex. "5k", "cyclosportive". Nil → seul le sport est utilisé.
    /// - `secondary` : objectifs secondaires (Story 3.13). Vide → titre simple.
    /// - `locale` : locale in-app courante (= `LanguageManager.currentLocale`).
    ///   Par défaut `.current` pour les call sites simples (preview UI).
    /// - Retour : ex. "Course — 10K" (FR) / "Running — 10K" (EN) — ou en multi
    ///   "Course — 10K + Endurance" / "Course — 10K +2 autres".
    static func build(
        sportCode: String,
        goal: String?,
        secondary: [String] = [],
        locale: Locale = .current
    ) -> String {
        let bundle = locale.localizedBundle
        let sportName = localizedSport(sportCode, bundle: bundle)
        guard let goal, !goal.isEmpty,
              let goalName = localizedGoal(sportCode: sportCode, goal: goal, bundle: bundle)
        else {
            return sportName
        }
        let primary = "\(sportName) — \(goalName)"
        guard !secondary.isEmpty else { return primary }

        let secondaryNames = secondary.compactMap { code -> String? in
            guard !code.isEmpty else { return nil }
            return localizedGoal(sportCode: sportCode, goal: code, bundle: bundle)
        }
        guard !secondaryNames.isEmpty else { return primary }

        let separator = bundle.localizedString(
            forKey: "program.title.and", value: " + ", table: nil
        )
        let composite = ([primary] + secondaryNames).joined(separator: separator)
        if composite.count <= compositeMaxLength {
            return composite
        }
        let countFormat = bundle.localizedString(
            forKey: "program.title.others_count", value: "+%lld more", table: nil
        )
        let suffix = String(format: countFormat, Int64(secondaryNames.count))
        return "\(primary) \(suffix)"
    }

    /// Lookup la string localisée pour le sport. Fallback : sportCode capitalized.
    private static func localizedSport(_ sportCode: String, bundle: Bundle) -> String {
        let key = "onboarding.sport.\(sportCode)"
        let resolved = bundle.localizedString(forKey: key, value: key, table: nil)
        return resolved == key ? sportCode.capitalized : resolved
    }

    /// Lookup la string localisée pour le goal du sport. Nil si la clé n'existe
    /// pas (= goal hors questionnaire universel, ex. test fixtures).
    private static func localizedGoal(sportCode: String, goal: String, bundle: Bundle) -> String? {
        // Le goal stocké peut contenir des tirets ("half-ironman", "tournoi-prep").
        // La convention xcstrings utilise des underscores ("half_ironman"). On
        // normalise pour matcher la clé i18n.
        let normalizedGoal = goal.replacingOccurrences(of: "-", with: "_")
        let key = "questionnaire.\(sportCode).q2.option.\(normalizedGoal)"
        let resolved = bundle.localizedString(forKey: key, value: key, table: nil)
        guard resolved != key else { return nil }
        return resolved
    }
}
