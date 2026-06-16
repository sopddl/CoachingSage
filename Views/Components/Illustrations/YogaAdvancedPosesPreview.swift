// Views/Components/Illustrations/YogaAdvancedPosesPreview.swift
// Party illustrations 2026-06-08 — preview ISOLÉE des 17 asanas avancées (le #Preview dans
// YogaIllustration.swift ne build plus < 30s vu la taille du fichier). Fichier DEBUG only,
// retiré du build release. Sert au contrôle visuel RenderPreview lot par lot.
#if DEBUG
import SwiftUI

#Preview("Yoga — 17 asanas avancées") {
    let poses: [String] = [
        "Salabhasana (Sauterelle)", "Ustrasana (Chameau)", "Dhanurasana (Arc)",
        "Phalakasana (Plank)", "Upavistha Konasana A+B", "Bakasana (Crow)",
        "Purvottanasana", "Uttana Padasana", "Prasarita Padottanasana A-D",
        "Padahastasana (Mains sous pieds)", "Ardha Matsyendrasana", "Kapotasana (Pigeon royal)",
        "Bhujapidasana (Pression épaule)", "Garbha Pindasana (Embryon)", "Karnapidasana (Genoux aux oreilles)",
        "Utthita Hasta Padangusthasana", "Ardha Baddha Padmottanasana (Demi-lotus debout)"
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
