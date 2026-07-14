// Views/Components/ExerciseAssetIllustration.swift
// Intégration app (2026-07-14 soir, décision Sophie « tout remplacer ») —
// point d'entrée unique pour un pattern couvert par un asset pictos-rig :
// vidéo bouclée si un .mp4 existe pour `resourceName`, sinon image statique.
// Évite à `ExercisePatternIllustration` de savoir quel type de média chaque
// pattern a — un seul call site par case du switch.
import SwiftUI

struct ExerciseAssetIllustration: View {
    let resourceName: String
    var size: CGFloat = IllustrationStyle.frameSize

    private var hasVideo: Bool {
        ExerciseAssetBundle.current.url(forResource: resourceName, withExtension: "mp4") != nil
    }

    var body: some View {
        if hasVideo {
            ExerciseVideoIllustration(resourceName: resourceName, size: size)
        } else {
            ExerciseImageIllustration(resourceName: resourceName, size: size)
        }
    }
}
