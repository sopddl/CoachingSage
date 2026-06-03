// Views/Components/Session/VoiceSettingsControls.swift
// Story 3.35 (AC2/AC3/AC4) — réglages voix accessibles pendant le mode Audio :
// toggle ON/OFF (défaut ON), sélecteur homme/femme, invite « voix premium »
// (lien Réglages iOS) non bloquante au 1ᵉʳ usage si seule la voix compacte existe.
// Persistant via @AppStorage.
import SwiftUI
import AVFoundation

/// Clés de préférences voix (partagées vue ↔ FOCUS).
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

struct VoiceSettingsControls: View {
    @AppStorage(SessionVoicePrefs.enabledKey) private var voiceEnabled = true
    @AppStorage(SessionVoicePrefs.genderKey) private var genderRaw = SessionVoiceGender.female.rawValue

    /// Appelé quand un réglage change, pour répercuter sur le guide voix actif.
    var onChange: (Bool, SessionVoiceGender) -> Void = { _, _ in }

    var body: some View {
        HStack(spacing: 12) {
            Button {
                voiceEnabled.toggle()
                notify()
            } label: {
                Image(systemName: voiceEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                    .font(.callout)
                    .foregroundStyle(voiceEnabled ? Color.coachingPrimary : .secondary)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(Color(uiColor: .secondarySystemBackground)))
            }
            .accessibilityLabel(Text("coaching.session.voice.toggle"))
            .accessibilityValue(Text(voiceEnabled ? "coaching.session.voice.on" : "coaching.session.voice.off"))

            if voiceEnabled {
                Picker("coaching.session.voice.gender", selection: $genderRaw) {
                    Text("coaching.session.voice.female").tag(SessionVoiceGender.female.rawValue)
                    Text("coaching.session.voice.male").tag(SessionVoiceGender.male.rawValue)
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 180)
                .onChange(of: genderRaw) { _, _ in notify() }
            }
            Spacer(minLength: 0) // ancre l'icône à gauche (pas de saut au toggle OFF, P2 review)
        }
        .accessibilityIdentifier("coaching.session.voice.controls")
    }

    private func notify() {
        onChange(voiceEnabled, SessionVoiceGender(rawValue: genderRaw) ?? .female)
    }
}

#if DEBUG
#Preview("Voice controls") {
    VoiceSettingsControls()
        .padding()
}
#endif
