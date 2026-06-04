// Coaching/Session/SessionAudioCues.swift
// Story 3.34 (FOCUS Minuté) — bips de transition + configuration `AVAudioSession`.
//
// Bug #9 (2026-06-04) : les bips passaient par `AudioServicesPlaySystemSound`, qui
// SUIT l'interrupteur Silence de l'iPhone → inaudibles quand le téléphone est en
// silencieux (cas typique muscu/HIIT en salle). On génère désormais les bips via
// un `AVAudioEngine` branché sur la session `.playback` : ils sonnent MÊME en mode
// silencieux, comme la voix (`AVSpeechSynthesizer`, déjà sur cette session).
//
// SOCLE RÉUTILISÉ PAR 3.35 : la voix (3.35) duck l'audio tiers via `duck()`/
// `unduck()` (la musique du user baisse pendant la prise de parole puis remonte)
// SANS couper la session ni le moteur de bips — autrement la session était
// désactivée après chaque phrase et les bips du décompte 3·2·1 sautaient, et la
// musique remontait entre chaque chiffre. La catégorie `.playback` + `.mixWithOthers`
// laisse la musique du user tourner ; `.duckOthers` la baisse pendant la voix.
import Foundation
import AVFoundation

/// Cue audio courte, jouée comme un (ou deux) ton(s) sinusoïdaux synthétisés.
enum SessionAudioCue: CaseIterable {
    case prepareTick   // tic du countdown 3·2·1
    case workStart     // début d'effort
    case restStart     // début de récup
    case finish        // fin de séquence

    /// Tons (fréquence Hz, durée s) joués en séquence pour ce cue.
    var tones: [(frequency: Double, duration: Double)] {
        switch self {
        case .prepareTick: return [(1000, 0.07)]                 // tic sec
        case .workStart:   return [(1320, 0.18)]                 // bip aigu « go »
        case .restStart:   return [(700, 0.16)]                  // bip grave « récup »
        case .finish:      return [(880, 0.14), (1320, 0.24)]    // deux tons montants
        }
    }
}

@MainActor
final class SessionAudioCues {
    private var isActive = false
    private var duckOthers = false
    private var engineRunning = false

    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private let sampleRate = 44_100.0
    private let format: AVAudioFormat
    private var buffers: [SessionAudioCue: AVAudioPCMBuffer] = [:]

    init() {
        format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: format)
    }

    /// Active la session audio + démarre le moteur de bips. `duckOthers` baisse
    /// l'audio tiers dès l'activation (la voix 3.35 préfère ducker à la demande via
    /// `duck()`/`unduck()` — laisser false ici).
    func activate(duckOthers: Bool = false) {
        self.duckOthers = duckOthers
        applyCategory()
        try? AVAudioSession.sharedInstance().setActive(true)
        isActive = true
        startEngine()
    }

    /// Baisse l'audio tiers le temps d'une prise de parole — SANS couper la session
    /// ni le moteur (les bips restent audibles, la musique ne remonte pas entre deux
    /// phrases du décompte). Auto-active si besoin.
    func duck() {
        guard isActive else { activate(duckOthers: true); return }
        guard !duckOthers else { return }
        duckOthers = true
        applyCategory()
    }

    /// Restaure l'audio tiers après la prise de parole.
    func unduck() {
        guard isActive, duckOthers else { return }
        duckOthers = false
        applyCategory()
    }

    /// Joue un bip. No-op silencieux si la session n'est pas active ou si le moteur
    /// n'a pas pu démarrer (jamais bloquant).
    func play(_ cue: SessionAudioCue) {
        guard isActive else { return }
        startEngine()
        guard engineRunning else { return }
        player.scheduleBuffer(buffer(for: cue), at: nil, options: [], completionHandler: nil)
    }

    /// Désactive la session et le moteur, et notifie les autres apps (musique remonte).
    func deactivate() {
        guard isActive else { return }
        if engineRunning {
            player.stop()
            engine.stop()
            engineRunning = false
        }
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        isActive = false
        duckOthers = false
    }

    // MARK: - Session / moteur

    private func applyCategory() {
        var options: AVAudioSession.CategoryOptions = [.mixWithOthers]
        if duckOthers { options.insert(.duckOthers) }
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: options)
    }

    private func startEngine() {
        guard !engineRunning else { return }
        engine.prepare()
        do {
            try engine.start()
            player.play()
            engineRunning = true
        } catch {
            engineRunning = false
        }
    }

    // MARK: - Synthèse des tons

    private func buffer(for cue: SessionAudioCue) -> AVAudioPCMBuffer {
        if let cached = buffers[cue] { return cached }
        let made = makeBuffer(tones: cue.tones)
        buffers[cue] = made
        return made
    }

    /// Rend une séquence de tons sinusoïdaux (avec une courte enveloppe attaque/
    /// release pour éviter les clics) dans un buffer PCM mono.
    private func makeBuffer(tones: [(frequency: Double, duration: Double)]) -> AVAudioPCMBuffer {
        let gap = 0.04 // silence entre deux tons
        let total = tones.reduce(0) { $0 + $1.duration } + gap * Double(max(tones.count - 1, 0))
        let frameCount = AVAudioFrameCount(total * sampleRate)
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)!
        buffer.frameLength = frameCount
        let samples = buffer.floatChannelData![0]

        let amplitude: Float = 0.5
        var frame = 0
        for (i, tone) in tones.enumerated() {
            let toneFrames = Int(tone.duration * sampleRate)
            let attack = max(1, Int(0.005 * sampleRate))
            let release = max(1, Int(0.02 * sampleRate))
            for n in 0..<toneFrames {
                let t = Double(n) / sampleRate
                var env: Float = 1
                if n < attack { env = Float(n) / Float(attack) }
                else if n > toneFrames - release { env = Float(max(0, toneFrames - n)) / Float(release) }
                samples[frame] = amplitude * env * Float(sin(2 * .pi * tone.frequency * t))
                frame += 1
            }
            if i < tones.count - 1 {
                for _ in 0..<Int(gap * sampleRate) { samples[frame] = 0; frame += 1 }
            }
        }
        while frame < Int(frameCount) { samples[frame] = 0; frame += 1 }
        return buffer
    }
}
