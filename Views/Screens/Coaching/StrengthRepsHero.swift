// Views/Screens/Coaching/StrengthRepsHero.swift
// Chantier structuration i18n du dosage — Lot 7 muscu.
//
// Bloc HÉROS reps muscu du mode Minuté, extrait de SessionFocusView pour être rendable seul
// (snapshot + #Preview, sans l'état timer). Le gros chiffre = `value` du dose structuré (propre :
// plus de « 10 par jambe » dans la police 80pt — la latéralité passe par `isLateral`, tirée du
// qualifier perSide/perLeg/perArm/perFoot/perShoulder, pas du strip-string). Le mot « reps » et
// le guidage côté restent minimaux (party muscu reps-héros).
import SwiftUI

struct StrengthRepsHero: View {
    let value: String
    let isLateral: Bool

    var body: some View {
        VStack(spacing: 6) {
            Text(verbatim: value)
                .font(.system(size: 80, weight: .bold, design: .rounded))
                .foregroundStyle(Color.coachingPrimary)
                // Les chiffres courts (« 10 », « 8-10 ») restent énormes ; un schéma freeText long
                // (« max propre », « 5, 5, 5, 5+ AMRAP ») rétrécit/wrappe au lieu de tronquer
                // (« max pro… ») — attrapé au snapshot héros. lineLimit 2 + scale jusqu'à ~28pt.
                .minimumScaleFactor(0.35)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .accessibilityIdentifier("coaching.session.focus.timed.strength.repsHero")
            Text("coaching.dosage.reps.unit")
                .font(.headline)
                .foregroundStyle(.secondary)
            // D4 côté : exo unilatéral (« 10 par côté ») → guidage explicite.
            // Affiché seulement (la voix côté = mode Audio, hors muscu Minuté).
            if isLateral {
                Label {
                    Text("coaching.dosage.side.right")
                        + Text(verbatim: " · ")
                        + Text("coaching.dosage.side.left")
                } icon: {
                    Image(systemName: "arrow.left.arrow.right")
                }
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color.coachingPrimary)
                .padding(.top, 2)
                .accessibilityIdentifier("coaching.session.focus.timed.strength.side")
            }
        }
    }
}

#Preview("StrengthRepsHero") {
    VStack(spacing: 28) {
        StrengthRepsHero(value: "10", isLateral: true)        // unilatéral
        StrengthRepsHero(value: "8-10", isLateral: false)     // plage
        StrengthRepsHero(value: "clean max", isLateral: false) // freeText
    }
    .padding()
}
