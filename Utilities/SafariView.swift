// Utilities/SafariView.swift
// `Link(destination:)` dans une sheet SwiftUI ouvre Safari sur page blanche
// (régression iOS 18) — utiliser SFSafariViewController in-app à la place.
// Portage du pattern GardenSage (`PrivacySettingsView.swift`).
import SafariServices
import SwiftUI

struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}
