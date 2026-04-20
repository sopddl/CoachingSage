// App/AppConstants.swift
// Clés et URLs — chargées depuis .xcconfig
import Foundation

struct AppConstants {
    // App Group partagé entre l'app principale et le futur Widget (Epic ultérieur)
    static let appGroupIdentifier = "group.com.sopddl.coachingsage.shared"
    // Nom du fichier SwiftData partagé
    static let sharedStoreName = "CoachingSage.store"

    // MARK: - URLs légales (GitHub Pages)
    static let privacyPolicyFRURL = URL(string: "https://sopddl.github.io/coachingsage-privacy-fr")!
    static let privacyPolicyENURL = URL(string: "https://sopddl.github.io/coachingsage-privacy-en")!
    static let supportURL = URL(string: "https://sopddl.github.io/coachingsage-support")!

    /// Apple standard EULA — requis par Guideline 3.1.2(c) pour les abonnements.
    static let termsOfUseURL = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!

    /// URL du store SwiftData dans l'App Group. Fallback Documents si App Group indisponible (simulateur).
    static var sharedStoreURL: URL {
        let groupURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupIdentifier
        ) ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return groupURL.appending(path: sharedStoreName)
    }
}
