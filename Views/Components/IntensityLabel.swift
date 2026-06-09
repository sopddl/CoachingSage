// Views/Components/IntensityLabel.swift
// Revue qualité thème #1 — politique d'affichage « sensation d'abord » (2026-06-09).
//
// Point d'affichage UNIQUE du champ `targetZone` d'un exercice. Encapsule la décision
// produit (sensation primaire + code coach secondaire tappable) pour que les deux sites
// d'affichage (SessionFocusView en FOCUS, ExerciseTimelineCard dans le HUB) restent cohérents.
//
// Trois cas :
//   1. RPE (« RPE 6-7 »)      → chip neutre « effort 6-7 sur 10 » (le code RPE n'apporte rien).
//   2. Zone d'allure connue   → chip SENSATION primaire (« endurance — tu peux parler »)
//                                + code coach (« FTP-Z2 ») en sous-texte gris tappable (glossaire).
//   3. Déjà clair / inconnu   → badge glossaire tel quel (« technique », « maintien 30 s »…).
import SwiftUI

struct IntensityLabel: View {
    let zone: String
    @Environment(\.locale) private var locale

    var body: some View {
        if let effort = DosageFormatting.plainEffort(from: zone, locale: locale) {
            neutralChip(effort)
        } else if let sensation = DosageFormatting.sensationLabel(from: zone, locale: locale) {
            HStack(spacing: 6) {
                sensationChip(sensation)
                GlossaryTermBadge(term: zone, secondary: true)
                    .font(.caption2)
            }
        } else {
            GlossaryTermBadge(term: zone)
                .font(.caption2.bold())
                .padding(.horizontal, 8).padding(.vertical, 4)
                .background(Color.coachingPrimary.opacity(0.10))
                .clipShape(Capsule())
        }
    }

    /// Libellé sensation = l'info HÉROS de l'intensité (référentiel dosage, hiérarchie 1+1+0).
    private func sensationChip(_ text: String) -> some View {
        Text(verbatim: text)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(Color.coachingPrimary)
            .padding(.horizontal, 8).padding(.vertical, 4)
            .background(Color.coachingPrimary.opacity(0.10))
            .clipShape(Capsule())
            .fixedSize(horizontal: false, vertical: true)
    }

    /// Chip neutre (RPE → effort) : pas de code à reléguer, donc style support gris.
    private func neutralChip(_ text: String) -> some View {
        Text(verbatim: text)
            .font(.caption2)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 8).padding(.vertical, 4)
            .background(Color(uiColor: .tertiarySystemBackground))
            .clipShape(Capsule())
    }
}

#if DEBUG
#Preview("IntensityLabel — tous les cas") {
    VStack(alignment: .leading, spacing: 12) {
        IntensityLabel(zone: "RPE 6-7")       // → effort 6-7 sur 10
        IntensityLabel(zone: "FTP-Z2")        // → endurance — tu peux parler · FTP-Z2
        IntensityLabel(zone: "Daniels-E")     // → facile — tu peux parler · Daniels-E
        IntensityLabel(zone: "Daniels-I")     // → très dur — 2-3 mots · Daniels-I
        IntensityLabel(zone: "EN1")           // → endurance facile — tu peux parler · EN1
        IntensityLabel(zone: "CSS pace")      // → allure seuil · CSS pace
        IntensityLabel(zone: "Sweet-Spot")    // → allure soutenue · Sweet-Spot
        IntensityLabel(zone: "Z2-cardiac")    // → facile — tu peux parler · Z2-cardiac
        IntensityLabel(zone: "technique")     // → badge tel quel (déjà clair)
    }
    .padding()
}
#endif
