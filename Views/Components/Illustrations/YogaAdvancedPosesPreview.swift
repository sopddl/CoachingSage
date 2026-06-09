// Views/Components/Illustrations/YogaAdvancedPosesPreview.swift
// Party illustrations 2026-06-08 — preview ISOLÉE des 17 asanas avancées (le #Preview dans
// YogaIllustration.swift ne build plus < 30s vu la taille du fichier). Fichier DEBUG only,
// retiré du build release. Sert au contrôle visuel RenderPreview lot par lot.
#if DEBUG
import SwiftUI

#Preview("Yoga — 17 asanas avancées") {
    let poses: [String] = [
        // contrôle des poses du bas non reconfirmées
        "Karnapidasana (Genoux aux oreilles)", "Garbha Pindasana (Embryon)",
        "Ardha Baddha Padmottanasana (Demi-lotus debout)", "Utthita Hasta Padangusthasana",
        "Kapotasana (Pigeon royal)", "Padahastasana (Mains sous pieds)",
        "Dhanurasana (Arc)", "Uttana Padasana"
    ]
    return ScrollView {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 8) {
            ForEach(poses, id: \.self) { name in
                VStack {
                    Text(verbatim: name).font(.caption2).foregroundStyle(.secondary)
                        .lineLimit(2).multilineTextAlignment(.center)
                    YogaIllustration(sportCode: "yoga", exerciseName: name, size: 120)
                        .frame(maxWidth: .infinity)
                        .background(Color(uiColor: .secondarySystemBackground))
                }
            }
        }.padding()
    }.background(Color.coachingBackground)
}
#endif
