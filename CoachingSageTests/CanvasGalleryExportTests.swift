// CoachingSageTests/CanvasGalleryExportTests.swift
// JETABLE — export ponctuel pour galerie de re-jugement (75 schémas Canvas restants,
// 39 yoga + 36 muscu/core/mobilité), suite harmonisation palette IllustrationStyle
// (`.silhouette` unique + `cardBackground(forCode:)`, 2026-07-16). Écrit des PNG
// individuels sous `_bmad-output/planning-artifacts/pictos-rig/vague7/`. À supprimer
// une fois la galerie construite et le round de jugement Sophie passé.
//
// Notes de correction vs la liste fournie (les initializers imaginés ne collaient
// pas tous à la signature réelle) :
// - `MobilityIllustration` n'a PAS de paramètre `size:` (frame fixe 80×48 interne) →
//   appel sans `size:`.
// - Toutes les vues Partie B SAUF CoreIllustration/BirdDogIllustration/MobilityIllustration
//   n'ont PAS de paramètre `size:` mais un paramètre `frame: Int` obligatoire (0/1/2 =
//   position start/mid/end de l'animation triplet). Elles sont nativement dessinées à
//   `IllustrationStyle.frameSize` (48×48) et ne sont JAMAIS montrées à cette taille brute
//   dans l'app — le call-site réel (`ExercisePatternIllustration.tripletStrip`) les
//   agrandit toujours via `.scaleEffect`. On reproduit exactement ce pattern (scaleEffect
//   + frame extérieur) pour obtenir un rendu fidèle et lisible, avec `frame: 1` (pose médiane,
//   la plus représentative du mouvement) comme frame exportée.
// - Le variant de certaines vues Partie B n'est pas un paramètre d'init direct mais dérivé
//   de `exerciseName` via `resolveVariant(from:)` → on passe un `exerciseName` qui déclenche
//   le variant demandé (ex: HingeIllustration variant .barbellRDL ← exerciseName contenant
//   "roumain").
// - La liste fournie énumère 75 entrées (39 Partie A + 36 Partie B), pas 73/34 comme annoncé
//   dans les en-têtes — export FIDÈLE À LA LISTE (75 fichiers), voir rapport agent pour détail.
import XCTest
import SwiftUI
import UIKit

@MainActor
final class CanvasGalleryExportTests: XCTestCase {

    private let outputDir = URL(fileURLWithPath:
        "/Users/sophieslama/CL3/CoachingSage/_bmad-output/planning-artifacts/pictos-rig/vague7")

    // MARK: - Card wrapper (identique au reste de l'app, cf commit harmonisation palette)

    private func card<V: View>(_ v: V, code: String) -> some View {
        v.frame(maxWidth: .infinity)
            .padding(12)
            .background(IllustrationStyle.cardBackground(forCode: code))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .frame(width: 360)
            .padding(10)
            .background(Color(white: 0.97))
    }

    /// Vues Partie B « triplet » (frame: Int, dessinées nativement à 48×48) : on applique
    /// le même `.scaleEffect` que `ExercisePatternIllustration.tripletStrip` pour obtenir un
    /// rendu à taille comparable aux autres cartes (200×200), fidèle à ce que l'app affiche
    /// réellement (jamais montrées à 48×48 brut en prod).
    private func scaledFrame<V: View>(_ v: V) -> some View {
        let scale = 200 / IllustrationStyle.frameSize
        return v.scaleEffect(scale)
            .frame(width: IllustrationStyle.frameSize * scale,
                   height: IllustrationStyle.frameSize * scale)
    }

    // MARK: - Export helper

    private func export<V: View>(_ v: V, slug: String, code: String) {
        let wrapped = card(v, code: code)
        let renderer = ImageRenderer(content: wrapped)
        renderer.scale = 2
        guard let data = renderer.uiImage?.pngData() else {
            XCTFail("Rendu PNG nil pour \(slug)")
            return
        }
        let url = outputDir.appendingPathComponent("\(slug).png")
        do {
            try data.write(to: url)
        } catch {
            XCTFail("Écriture échouée pour \(slug): \(error)")
        }
    }

    // MARK: - Test

    func testExportAll73() throws {
        try FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)

        // MARK: Partie A — 39 poses yoga

        let yogaTriggers: [(String, String)] = [
            ("warrior2", "guerrier 2"),
            ("cobra", "cobra"),
            ("child", "enfant"),
            ("boat", "bateau"),
            ("savasana", "savasana"),
            ("dirgha", "dirgha"),
            ("catCowForearms", "cat-cow avant-bras"),
            ("sarvangasana", "sarvangasana"),
            ("setuBandha", "setu bandha"),
            ("ujjayi", "ujjayi"),
            ("suptaBaddhaKonasana", "supta baddha"),
            ("januSirsasana", "janu sirsasana"),
            ("marichyasanaA", "marichyasana"),
            ("matsyasana", "matsyasana"),
            ("viparitaKarani", "viparita karani"),
            ("halasana", "halasana"),
            ("kurmasana", "kurmasana"),
            ("anjaneyasana", "anjaneyasana"),
            ("urdhvaDhanurasana", "urdhva dhanurasana"),
            ("dolphinPose", "dolphin"),
            ("garudasana", "garudasana"),
            ("warrior3", "warrior 3"),
            ("nadiShodhana", "nadi shodhana"),
            ("sirsasana", "sirsasana"),
            ("salabhasana", "salabhasana"),
            ("ustrasana", "ustrasana"),
            ("dhanurasana", "dhanurasana"),
            ("phalakasana", "phalakasana"),
            ("upavisthaKonasana", "upavistha"),
            ("bakasana", "bakasana"),
            ("purvottanasana", "purvottanasana"),
            ("uttanaPadasana", "uttana padasana"),
            ("prasaritaPadottanasana", "prasarita"),
            ("kapotasana", "kapotasana"),
            ("bhujapidasana", "bhujapidasana"),
            ("garbhaPindasana", "garbha pindasana"),
            ("karnapidasana", "karnapidasana"),
            ("utthitaHastaPadangusthasana", "utthita hasta"),
            ("ardhaBaddhaPadmottanasana", "ardha baddha padmottanasana"),
        ]

        for (slug, trigger) in yogaTriggers {
            let v = YogaIllustration(sportCode: "yoga", exerciseName: trigger, size: 200)
            export(v, slug: slug, code: "yoga")
        }

        // MARK: Partie B — 36 patterns muscu/core/mobilité

        export(CoreIllustration(sportCode: "strength", variant: .lateral, size: 200),
               slug: "side-plank", code: "strength")

        export(MobilityIllustration(sportCode: "strength"),
               slug: "mobility-quad", code: "strength")

        export(BirdDogIllustration(sportCode: "strength", size: 200),
               slug: "bird-dog", code: "strength")

        export(scaledFrame(HingeIllustration(sportCode: "strength", frame: 1, exerciseName: "Soulevé de terre roumain barre")),
               slug: "hinge-rdl-barbell", code: "strength")

        export(scaledFrame(PullVerticalIllustration(sportCode: "strength", frame: 1)),
               slug: "pull-vertical", code: "strength")

        export(scaledFrame(PushHorizontalIllustration(sportCode: "strength", frame: 1, exerciseName: "Développé couché haltères")),
               slug: "push-horizontal-dumbbell", code: "strength")

        export(scaledFrame(PushHorizontalIllustration(sportCode: "strength", frame: 1, exerciseName: "Dips lestés")),
               slug: "push-horizontal-dips", code: "strength")

        export(scaledFrame(PullHorizontalIllustration(sportCode: "strength", frame: 1)),
               slug: "pull-horizontal-row", code: "strength")

        export(scaledFrame(LungeIllustration(sportCode: "strength", frame: 1)),
               slug: "lunge-bodyweight", code: "strength")

        export(scaledFrame(PlyoIllustration(sportCode: "strength", frame: 1, exerciseName: "Burpee")),
               slug: "plyo-burpee", code: "strength")

        export(scaledFrame(PlyoIllustration(sportCode: "strength", frame: 1, exerciseName: "Jump squat")),
               slug: "plyo-jumpsquat", code: "strength")

        export(scaledFrame(HipThrustIllustration(sportCode: "strength", frame: 1)),
               slug: "hip-thrust", code: "strength")

        export(scaledFrame(CalfRaiseIllustration(sportCode: "strength", frame: 1)),
               slug: "calf-raise", code: "strength")

        export(scaledFrame(YTWActivationIllustration(sportCode: "strength", frame: 1)),
               slug: "ytw-activation", code: "strength")

        export(scaledFrame(PallofPressIllustration(sportCode: "strength", frame: 1)),
               slug: "pallof-press", code: "strength")

        export(scaledFrame(NordicCurlIllustration(sportCode: "strength", frame: 1)),
               slug: "nordic-curl", code: "strength")

        export(scaledFrame(DeadBugIllustration(sportCode: "strength", frame: 1)),
               slug: "dead-bug", code: "strength")

        export(scaledFrame(ClamshellIllustration(sportCode: "strength", frame: 1)),
               slug: "clamshell", code: "strength")

        export(scaledFrame(FacePullIllustration(sportCode: "strength", frame: 1)),
               slug: "face-pull", code: "strength")

        export(scaledFrame(BicepsCurlIllustration(sportCode: "strength", frame: 1, exerciseName: "Curl biceps barre")),
               slug: "biceps-curl-barbell", code: "strength")

        export(scaledFrame(TricepsPushdownIllustration(sportCode: "strength", frame: 1)),
               slug: "triceps-pushdown", code: "strength")

        export(scaledFrame(HangingLegRaiseIllustration(sportCode: "strength", frame: 1)),
               slug: "hanging-leg-raise", code: "strength")

        export(scaledFrame(WoodchopperIllustration(sportCode: "strength", frame: 1)),
               slug: "woodchopper", code: "strength")

        export(scaledFrame(PulloverIllustration(sportCode: "strength", frame: 1)),
               slug: "pullover", code: "strength")

        export(scaledFrame(CableFlyIllustration(sportCode: "strength", frame: 1)),
               slug: "cable-fly", code: "strength")

        export(scaledFrame(LegCurlIllustration(sportCode: "strength", frame: 1)),
               slug: "leg-curl", code: "strength")

        export(scaledFrame(LegPressIllustration(sportCode: "strength", frame: 1)),
               slug: "leg-press", code: "strength")

        export(scaledFrame(ReverseHyperIllustration(sportCode: "strength", frame: 1)),
               slug: "reverse-hyper", code: "strength")

        export(scaledFrame(MountainClimberIllustration(sportCode: "strength", frame: 1)),
               slug: "mountain-climber", code: "strength")

        export(scaledFrame(JumpingJackIllustration(sportCode: "strength", frame: 1)),
               slug: "jumping-jack", code: "strength")

        export(scaledFrame(TibialisRaiseIllustration(sportCode: "strength", frame: 1)),
               slug: "tibialis-raise", code: "strength")

        export(scaledFrame(TurkishGetUpIllustration(sportCode: "strength", frame: 1)),
               slug: "turkish-getup", code: "strength")

        export(scaledFrame(PowerCleanIllustration(sportCode: "strength", frame: 1)),
               slug: "power-clean", code: "strength")

        export(scaledFrame(SledPushIllustration(sportCode: "strength", frame: 1)),
               slug: "sled-push", code: "strength")

        export(scaledFrame(FarmerCarryIllustration(sportCode: "strength", frame: 1)),
               slug: "farmer-carry", code: "strength")

        export(scaledFrame(DoubleUndersIllustration(sportCode: "strength", frame: 1)),
               slug: "double-unders", code: "strength")
    }
}
