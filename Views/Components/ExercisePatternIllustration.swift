// Views/Components/ExercisePatternIllustration.swift
// Story 3.19 — strip horizontal multi-frames pour un exo. Pivot view qui dispatche
// vers l'illu spécifique selon le pattern résolu, et ajoute les flèches entre frames.
// `.generic` → délègue à `ExercisePatternGenericFallback` (SF Symbol sport).
import SwiftUI

struct ExercisePatternIllustration: View {
    let pattern: ExercisePattern
    let sportCode: String
    /// Hint optionnel sur le nom de l'exercice pour détecter des variantes
    /// (ex: "Plank latéral" → variante side plank dans `CoreIllustration`).
    var exerciseName: String? = nil
    var size: CGFloat = IllustrationStyle.frameSize

    var body: some View {
        Group {
            if pattern == .generic {
                ExercisePatternGenericFallback(sportCode: sportCode, size: size)
            } else if pattern.isStatic {
                staticIllustration
                    .frame(height: size)
            } else {
                dynamicStrip
                    .frame(height: size)
            }
        }
        .dynamicTypeSize(.medium ... .accessibility2)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(accessibilityKey))
    }

    // MARK: - Dispatch

    @ViewBuilder
    private var staticIllustration: some View {
        switch pattern {
        case .core:
            CoreIllustration(sportCode: sportCode, variant: coreVariant)
        default:
            // Patterns statiques pas encore dessinés (Jalon 2+) → fallback générique en attendant
            ExercisePatternGenericFallback(sportCode: sportCode, size: size)
        }
    }

    private var coreVariant: CoreIllustration.Variant {
        guard let lower = exerciseName?.lowercased() else { return .frontal }
        if lower.contains("latéral") || lower.contains("lateral") || lower.contains("side") {
            return .lateral
        }
        return .frontal
    }

    @ViewBuilder
    private var dynamicStrip: some View {
        switch pattern {
        case .squat:
            tripletStrip { SquatIllustration(sportCode: sportCode, frame: $0) }
        case .hinge:
            tripletStrip { HingeIllustration(sportCode: sportCode, frame: $0) }
        case .pullVertical:
            tripletStrip { PullVerticalIllustration(sportCode: sportCode, frame: $0) }
        default:
            // Patterns dynamiques pas encore dessinés (Jalon 2+) → fallback générique
            ExercisePatternGenericFallback(sportCode: sportCode, size: size)
        }
    }

    /// Strip de 3 frames séparées par 2 flèches mouvement.
    private func tripletStrip<Content: View>(@ViewBuilder _ frame: @escaping (Int) -> Content) -> some View {
        HStack(spacing: IllustrationStyle.frameSpacing) {
            frame(0)
            arrow
            frame(1)
            arrow
            frame(2)
        }
    }

    private var arrow: some View {
        Image(systemName: "arrow.right")
            .font(.system(size: IllustrationStyle.arrowSize, weight: .semibold))
            .foregroundStyle(IllustrationStyle.movementArrow)
    }

    // MARK: - Accessibility

    private var accessibilityKey: LocalizedStringKey {
        let frameCount = pattern.frameCount
        return "coaching.session.exercise.illustration.a11y \(pattern.rawValue) \(frameCount)"
    }
}

#if DEBUG
#Preview("ExercisePatternIllustration — 4 pilotes strength") {
    VStack(spacing: 12) {
        ExercisePatternIllustration(pattern: .squat, sportCode: "strengthTraining")
        ExercisePatternIllustration(pattern: .hinge, sportCode: "strengthTraining")
        ExercisePatternIllustration(pattern: .pullVertical, sportCode: "strengthTraining")
        ExercisePatternIllustration(pattern: .core, sportCode: "strengthTraining")
        ExercisePatternIllustration(pattern: .generic, sportCode: "tennis")
    }
    .padding()
    .background(Color.coachingBackground)
}
#endif
