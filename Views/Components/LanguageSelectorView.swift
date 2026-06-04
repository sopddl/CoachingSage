// Views/Components/LanguageSelectorView.swift
// ⚠️ DIVERGE de GardenSage / TailorSage depuis 2026-06-04 (chantier i18n ES) :
// itère sur le type LOCAL `AppLanguage.selectable` au lieu de
// `SageCore.SupportedLanguage.allCases`. Cf `reference_sagecore_no_touch_es_local`.
// Story 2.2 — sélecteur de langue (Menu déroulant).
// Pour exposer une langue : l'ajouter à `AppLanguage.selectable`.
import SwiftUI

struct LanguageSelectorView: View {
    let languageManager: LanguageManager

    var body: some View {
        Menu {
            ForEach(AppLanguage.selectable) { lang in
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
