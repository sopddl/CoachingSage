// Views/Components/Session/VoiceGenderSelectorView.swift
// Story 3.35d — sélecteur de voix Homme/Femme du mode Audio, déplacé dans le
// PROFIL (le FOCUS ne garde que le toggle son ON/OFF). Menu déroulant persistant
// @AppStorage. Le toggle ON/OFF reste dans l'écran FOCUS (haut droite).
import SwiftUI

/// Clés de préférences voix (partagées profil ↔ FOCUS).
enum SessionVoicePrefs {
    static let enabledKey = "coaching.voice.enabled"
    static let genderKey = "coaching.voice.gender"

    static var enabled: Bool {
        UserDefaults.standard.object(forKey: enabledKey) as? Bool ?? true // défaut ON
    }
    static var gender: SessionVoiceGender {
        SessionVoiceGender(rawValue: UserDefaults.standard.string(forKey: genderKey) ?? "") ?? .female
    }
}

struct VoiceGenderSelectorView: View {
    @AppStorage(SessionVoicePrefs.genderKey) private var genderRaw = SessionVoiceGender.female.rawValue

    private var selected: SessionVoiceGender { SessionVoiceGender(rawValue: genderRaw) ?? .female }

    var body: some View {
        Menu {
            ForEach(SessionVoiceGender.allCases, id: \.self) { gender in
                Button {
                    genderRaw = gender.rawValue
                } label: {
                    HStack {
                        label(for: gender)
                        if selected == gender { Image(systemName: "checkmark") }
                    }
                }
                .accessibilityIdentifier("voiceGenderSelector.\(gender.rawValue)")
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "waveform")
                label(for: selected).font(.coachingBody.bold())
            }
            .foregroundColor(.coachingTextPrimary)
            .frame(minHeight: 44)
            .padding(.horizontal, 8)
        }
        .menuStyle(.borderlessButton)
        .accessibilityLabel("coaching.session.voice.gender")
        .accessibilityIdentifier("profile.voiceGenderSelector")
    }

    @ViewBuilder
    private func label(for gender: SessionVoiceGender) -> some View {
        switch gender {
        case .female: Text("coaching.session.voice.female")
        case .male:   Text("coaching.session.voice.male")
        }
    }
}

#if DEBUG
#Preview("Voice gender selector") {
    VoiceGenderSelectorView()
        .padding()
        .background(Color.coachingBackground)
}
#endif
