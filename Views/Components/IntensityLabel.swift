// Views/Components/IntensityLabel.swift
// Revue qualité thème #1 — politique d'affichage « sensation d'abord » (2026-06-09).
//
// Point d'affichage UNIQUE du champ `targetZone` d'un exercice. Encapsule la décision
// produit pour que les deux sites (SessionFocusView en FOCUS, ExerciseTimelineCard dans
// le HUB) restent cohérents.
//
// Trois cas :
//   1. RPE (« RPE 6-7 »)    → chip neutre « effort 6-7 sur 10 » (le code RPE n'apporte rien).
//   2. Zone d'allure connue → chip SENSATION (« endurance — tu peux parler ») = SEUL libellé
//      visible, tappable → popover glossaire (code coach + définition FR/EN/ES). Décision Q-A
//      2026-06-09 (reco persona novice) : le code coach est CACHÉ de la ligne, pas de bruit jargon.
//   3. Déjà clair / inconnu → badge glossaire tel quel (« technique », « maintien 30 s »…).
import SwiftUI

struct IntensityLabel: View {
    let zone: String
    @Environment(\.locale) private var locale
    @State private var showDefinition = false

    var body: some View {
        if let effort = DosageFormatting.plainEffort(from: zone, locale: locale) {
            neutralChip(effort)
        } else if let sensation = DosageFormatting.sensationLabel(from: zone, locale: locale) {
            if let entry = Glossary.entry(forZone: zone) {
                // Sensation seule, tappable → le code coach n'apparaît QUE dans le popover.
                Button { showDefinition = true } label: {
                    sensationChip(sensation, tappable: true)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("coaching.glossary.term.\(entry.id)")
                .popover(isPresented: $showDefinition, attachmentAnchor: .point(.center)) {
                    GlossaryDefinitionPopover(entry: entry, term: zone)
                        .presentationCompactAdaptation(.popover)
                }
            } else {
                // Sensation mappée mais aucune entrée glossaire (cas défensif) → non tappable.
                sensationChip(sensation, tappable: false)
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
    /// `tappable` ajoute l'icône info (découvrabilité du glossaire).
    private func sensationChip(_ text: String, tappable: Bool) -> some View {
        HStack(spacing: 4) {
            Text(verbatim: text)
            if tappable {
                Image(systemName: "info.circle").font(.caption2)
            }
        }
        .font(.caption2.weight(.semibold))
        .foregroundStyle(Color.coachingPrimary)
        .padding(.horizontal, 8).padding(.vertical, 4)
        .background(Color.coachingPrimary.opacity(0.10))
        .clipShape(Capsule())
        .fixedSize(horizontal: false, vertical: true)
    }

    /// Chip neutre (RPE → effort) : style support gris.
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
        IntensityLabel(zone: "RPE 6-7")       // → effort 6-7 sur 10 (gris)
        IntensityLabel(zone: "FTP-Z2")        // → endurance — tu peux parler ⓘ
        IntensityLabel(zone: "Daniels-I")     // → très dur — 1-2 mots ⓘ
        IntensityLabel(zone: "EN1")           // → endurance facile — tu peux parler ⓘ
        IntensityLabel(zone: "CSS pace")      // → seuil — 2-3 mots ⓘ
        IntensityLabel(zone: "Sweet-Spot")    // → soutenu — juste sous le seuil ⓘ
        IntensityLabel(zone: "Z4")            // → seuil — 2-3 mots ⓘ
        IntensityLabel(zone: "%1RM 85-90%")   // → proche du max — dernière rép dure ⓘ
        IntensityLabel(zone: "technique")     // → badge tel quel (déjà clair, non mappé)
    }
    .padding()
}
#endif
