// Utilities/LanguageManager.swift
// [COPIE IDENTIQUE] — synchroniser avec GardenSage et TailorSage.
// Story 2.2 — gestion de la langue de l'app (FR / EN extensible).
import os
import SwiftUI
import SageCore

private let kPreferredLanguage = "preferredLanguage"

// MARK: - LanguageManager

@Observable
final class LanguageManager {
    private(set) var currentLanguage: SupportedLanguage
    private let userDefaults: UserDefaults
    /// UserDefaults partagé via App Group (futur widget).
    private let sharedDefaults: UserDefaults?

    var currentLocale: Locale {
        Locale(identifier: currentLanguage.rawValue)
    }

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        self.sharedDefaults = UserDefaults(suiteName: AppConstants.appGroupIdentifier)
        if let saved = userDefaults.string(forKey: kPreferredLanguage),
           let lang = SupportedLanguage(rawValue: saved) {
            currentLanguage = lang
        } else {
            // Langue primaire de l'appareil iOS, fallback .french
            let deviceLangCode = Locale.current.language.languageCode?.identifier ?? "fr"
            currentLanguage = SupportedLanguage(rawValue: deviceLangCode) ?? .french
        }
        // Synchroniser la langue dans le UserDefaults partagé au démarrage
        sharedDefaults?.set(currentLanguage.rawValue, forKey: kPreferredLanguage)
    }

    func switchLanguage(to language: SupportedLanguage) {
        guard language != currentLanguage else { return }
        currentLanguage = language
        userDefaults.set(language.rawValue, forKey: kPreferredLanguage)
        sharedDefaults?.set(language.rawValue, forKey: kPreferredLanguage)
    }
}

// MARK: - Bundle-based localization

extension Locale {
    /// Returns the Bundle for this locale's language, for use with String(localized:bundle:).
    /// String(localized:locale:) does NOT change which localization is loaded —
    /// only the bundle approach works for in-app language switching.
    ///
    /// Fallback `Bundle.allBundles` (2026-05-22) : nécessaire en logic test mode
    /// (dette SwiftData test_host hang) où `Bundle.main` pointe sur le binary
    /// `xctest` agent qui ne contient pas les `.lproj`. Le test bundle `.xctest`
    /// les contient.
    var localizedBundle: Bundle {
        let langCode = language.languageCode?.identifier ?? "en"
        if let path = Bundle.main.path(forResource: langCode, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return bundle
        }
        for candidate in Bundle.allBundles {
            if let path = candidate.path(forResource: langCode, ofType: "lproj"),
               let bundle = Bundle(path: path) {
                return bundle
            }
        }
        return Bundle.main
    }
}

extension String {
    /// Locale-aware localization using the correct bundle.
    static func localized(_ key: String.LocalizationValue, locale: Locale) -> String {
        String(localized: key, bundle: locale.localizedBundle)
    }
}

// MARK: - SwiftUI EnvironmentKey

struct LanguageManagerKey: EnvironmentKey {
    static let defaultValue: LanguageManager = {
        #if DEBUG
        Logger(subsystem: "com.sopddl.coachingsage", category: "view").warning("LanguageManager: using EnvironmentKey defaultValue — ensure .environment(\\.languageManager, ...) is injected")
        #endif
        return LanguageManager()
    }()
}

extension EnvironmentValues {
    var languageManager: LanguageManager {
        get { self[LanguageManagerKey.self] }
        set { self[LanguageManagerKey.self] = newValue }
    }
}
