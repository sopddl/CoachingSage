// Views/Components/LanguageSelectorView.swift
// [COPIE IDENTIQUE] — synchroniser avec GardenSage et TailorSage.
// Story 2.2 — sélecteur de langue extensible (Menu déroulant).
// Pour ajouter une langue : SupportedLanguage += case dans SageCore SPM.
import SwiftUI
import SageCore

struct LanguageSelectorView: View {
    let languageManager: LanguageManager

    var body: some View {
        Menu {
            ForEach(SupportedLanguage.allCases) { lang in
                Button {
                    languageManager.switchLanguage(to: lang)
                } label: {
                    HStack {
                        Text(lang.nativeName)
                        if languageManager.currentLanguage == lang {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                .accessibilityIdentifier("languageSelector.\(lang.rawValue)")
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "globe")
                Text(languageManager.currentLanguage.rawValue.uppercased())
                    .font(.coachingBody.bold())
            }
            .foregroundColor(.coachingTextPrimary)
            .frame(minWidth: 44, minHeight: 44)
            .padding(.horizontal, 8)
        }
        .menuStyle(.borderlessButton)
        .accessibilityLabel("accessibility.languageSelector.label")
        .accessibilityIdentifier("onboarding.languageSelector")
    }
}

#if DEBUG
#Preview("FR sélectionné") {
    LanguageSelectorView(languageManager: LanguageManager())
        .padding()
        .background(Color.coachingBackground)
}

#Preview("EN sélectionné") {
    let lm = LanguageManager()
    lm.switchLanguage(to: .english)
    return LanguageSelectorView(languageManager: lm)
        .padding()
        .background(Color.coachingBackground)
}
#endif
