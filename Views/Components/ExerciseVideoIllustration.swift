// Views/Components/ExerciseVideoIllustration.swift
// Intégration app (2026-07-14 soir, décision Sophie « tout remplacer ») —
// lecture d'une animation exercice bundlée (mp4, marionnette 2D pixel depuis
// pictos-rig) en boucle silencieuse, sans AUCUN chrome de lecteur (pas de
// scrub bar / bouton play — c'est une illustration, pas un lecteur vidéo).
// `VideoPlayer` d'AVKit affiche des contrôles natifs par défaut : on utilise
// directement `AVPlayerLayer` via `UIViewRepresentable`, seul moyen fiable de
// garantir zéro chrome. Poster (image statique du même exercice) affiché en
// dessous le temps que la 1re frame vidéo soit prête (évite un flash vide).
import SwiftUI
import AVFoundation

struct ExerciseVideoIllustration: View {
    let resourceName: String
    var size: CGFloat = IllustrationStyle.frameSize

    @State private var player: AVQueuePlayer?
    @State private var looper: AVPlayerLooper?

    var body: some View {
        ZStack {
            // Poster : même image que l'exercice, sert de fond tant que la vidéo
            // n'a pas rendu sa 1re frame (et si le fichier vidéo est introuvable).
            ExerciseImageIllustration(resourceName: resourceName, size: size)
            if let player {
                PlayerLayerView(player: player)
                    .frame(height: size)
                    .aspectRatio(1, contentMode: .fit)
            }
        }
        .frame(height: size)
        .aspectRatio(1, contentMode: .fit)
        .onAppear(perform: setUpPlayerIfNeeded)
    }

    private func setUpPlayerIfNeeded() {
        // XcodeGen aplatit `Resources/Illustrations/*` à la racine du bundle
        // (vérifié : pas de sous-dossier préservé) — pas de `subdirectory:` ici.
        guard player == nil, let url = ExerciseAssetBundle.current.url(forResource: resourceName, withExtension: "mp4") else { return }
        let item = AVPlayerItem(url: url)
        let queuePlayer = AVQueuePlayer()
        queuePlayer.isMuted = true
        looper = AVPlayerLooper(player: queuePlayer, templateItem: item)
        player = queuePlayer
        queuePlayer.play()
    }
}

/// Wrapper `UIView` minimal autour d'un `AVPlayerLayer` — ZÉRO chrome possible,
/// contrairement à `VideoPlayer` (SwiftUI/AVKit) qui affiche des contrôles natifs.
private struct PlayerLayerView: UIViewRepresentable {
    let player: AVQueuePlayer

    func makeUIView(context: Context) -> PlayerContainerView {
        let view = PlayerContainerView()
        view.playerLayer.player = player
        view.playerLayer.videoGravity = .resizeAspect
        view.backgroundColor = .clear
        return view
    }

    func updateUIView(_ uiView: PlayerContainerView, context: Context) {
        uiView.playerLayer.player = player
    }

    final class PlayerContainerView: UIView {
        override static var layerClass: AnyClass { AVPlayerLayer.self }
        var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
    }
}

#if DEBUG
#Preview("ExerciseVideoIllustration — fente POC") {
    ExerciseVideoIllustration(resourceName: "lunge-dumbbell", size: 200)
        .padding()
        .background(Color.coachingBackground)
}
#endif
