// Coaching/Session/SessionAudioCues.swift
// Story 3.34 (FOCUS Minuté) — bips de transition + configuration `AVAudioSession`.
//
// SOCLE RÉUTILISÉ PAR 3.35 (review P1.3) : l'interface expose dès maintenant la
// config de session avec `duckOthers` (le mode audio voix de 3.35 branchera la
// voix par-dessus la MÊME session, en passant `duckOthers: true`). On ne code
// donc PAS « bips only » en dur : `activate(duckOthers:)` + `deactivate()` sont
// le point d'extension. La catégorie `.playback` + `.mixWithOthers` laisse la
// musique du user tourner ; `.duckOthers` la baissera pendant les prises de parole.
import Foundation
import AVFoundation
import AudioToolbox

/// Cue audio courte. V1 = bips système ; 3.35 ajoutera la voix sur la même session.
enum SessionAudioCue {
    case prepareTick   // tic du countdown 3·2·1
    case workStart     // début d'effort
    case restStart     // début de récup
    case finish        // fin de séquence
}

@MainActor
final class SessionAudioCues {
    private var isActive = false

    /// Active la session audio. `duckOthers` baisse l'audio tiers (préparé pour la
    /// voix 3.35) ; en 3.34 (bips seuls) on peut laisser false.
    func activate(duckOthers: Bool = false) {
        let session = AVAudioSession.sharedInstance()
        var options: AVAudioSession.CategoryOptions = [.mixWithOthers]
        if duckOthers { options.insert(.duckOthers) }
        try? session.setCategory(.playback, mode: .default, options: options)
        try? session.setActive(true)
        isActive = true
    }

    /// Joue un bip. No-op silencieux si l'audio échoue (jamais bloquant).
    func play(_ cue: SessionAudioCue) {
        AudioServicesPlaySystemSound(Self.systemSoundID(for: cue))
    }

    /// Désactive la session et notifie les autres apps (musique remonte).
    func deactivate() {
        guard isActive else { return }
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        isActive = false
    }

    private static func systemSoundID(for cue: SessionAudioCue) -> SystemSoundID {
        switch cue {
        case .prepareTick: return 1103 // bip court (begin record)
        case .workStart:   return 1104 // bip (end record) — départ effort
        case .restStart:   return 1057 // Tink — passage en récup
        case .finish:      return 1025 // sonnerie courte de fin
        }
    }
}
