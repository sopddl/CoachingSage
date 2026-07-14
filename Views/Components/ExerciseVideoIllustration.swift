// Views/Components/ExerciseVideoIllustration.swift
// POC intégration app (2026-07-14 soir) — lecture d'une animation exercice
// bundlée (mp4, marionnette 2D pixel depuis pictos-rig) en boucle silencieuse.
// Isolé du dispatch `ExercisePatternIllustration` tant que l'option d'intégration
// (A/B/C, cf mémoire scope_integration_app_illustrations) n'est pas tranchée —
// ce fichier prouve seulement que la lecture vidéo bouclée fonctionne dans l'app.
import SwiftUI
import AVKit

struct ExerciseVideoIllustration: View {
    let resourceName: String
    var size: CGFloat = IllustrationStyle.frameSize

    @State private var player: AVQueuePlayer?
    @State private var looper: AVPlayerLooper?

    var body: some View {
        Group {
            if let player {
                VideoPlayer(player: player)
                    .disabled(true)
                    .onAppear { player.play() }
            } else {
                Color.clear
            }
        }
        .frame(height: size)
        .aspectRatio(1, contentMode: .fit)
        .onAppear(perform: setUpPlayerIfNeeded)
    }

    private func setUpPlayerIfNeeded() {
        // XcodeGen aplatit `Resources/Illustrations/*` à la racine du bundle
        // (vérifié : pas de sous-dossier préservé) — pas de `subdirectory:` ici.
        guard player == nil, let url = Bundle.main.url(forResource: resourceName, withExtension: "mp4") else { return }
        let item = AVPlayerItem(url: url)
        let queuePlayer = AVQueuePlayer()
        queuePlayer.isMuted = true
        looper = AVPlayerLooper(player: queuePlayer, templateItem: item)
        player = queuePlayer
        queuePlayer.play()
    }
}

#if DEBUG
#Preview("ExerciseVideoIllustration — fente POC") {
    ExerciseVideoIllustration(resourceName: "lunge-dumbbell", size: 200)
        .padding()
        .background(Color.coachingBackground)
}
#endif
