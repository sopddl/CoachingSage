// Views/Components/ExerciseImageIllustration.swift
// Intégration app (2026-07-14 soir, décision Sophie « tout remplacer ») — affiche
// une illustration exercice bundlée (PNG statique, pictos-rig) à la place du
// dessin Canvas vectoriel. Sœur de `ExerciseVideoIllustration` pour les patterns
// sans animation validée.
import SwiftUI
import UIKit

/// `Bundle.main` résout vers le runner XCTest générique (pas `CoachingSageTests.xctest`)
/// en mode logic-test (`TEST_HOST`/`BUNDLE_LOADER` vidés, cf `project.yml`) — les
/// assets y sont pourtant bien copiés (vérifié dans le `.xctest` compilé), juste
/// introuvables via `Bundle.main`. `Bundle(for:)` sur une classe DÉFINIE dans ce
/// fichier renvoie toujours le bundle qui contient réellement le code compilé —
/// correct que ce fichier tourne dans l'app ou dans le target de test.
final class ExerciseAssetBundleAnchor {}

enum ExerciseAssetBundle {
    static let current = Bundle(for: ExerciseAssetBundleAnchor.self)
}

struct ExerciseImageIllustration: View {
    let resourceName: String
    var size: CGFloat = IllustrationStyle.frameSize

    var body: some View {
        Group {
            // Fichier PNG bundlé en vrac (pas dans Assets.xcassets) : XcodeGen
            // aplatit `Resources/Illustrations/*` à la racine du bundle (vérifié
            // sur la vidéo POC) → lookup direct par URL, pas `UIImage(named:)`.
            if let url = ExerciseAssetBundle.current.url(forResource: resourceName, withExtension: "png"),
               let uiImage = UIImage(contentsOfFile: url.path) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Color.clear
            }
        }
        .frame(height: size)
    }
}

#if DEBUG
#Preview("ExerciseImageIllustration — wall-sit POC") {
    ExerciseImageIllustration(resourceName: "wall-sit", size: 200)
        .padding()
        .background(Color.coachingBackground)
}
#endif
