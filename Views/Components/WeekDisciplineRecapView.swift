// Views/Components/WeekDisciplineRecapView.swift
// Chantier récap hebdo triathlon (2026-07-06/07) — ligne compacte icône+libellé
// par discipline effective (nage/vélo/course) présente dans une semaine.
// Réponse au retour persona 2026-07-05 (30 personas × 10 sports) : aucun repère
// "je suis dans un plan multisport" visible sans contexte. Partagée entre
// `AdaptedProgramView` (header de semaine, toujours visible) et
// `SessionDetailView` (ligne "Cette semaine aussi" sous le hero header).
import SwiftUI
import TemplateModel

struct WeekDisciplineRecapView: View {
    let codes: [String]
    /// Préfixe optionnel (ex: "Cette semaine :") — utile hors contexte d'un
    /// titre de semaine déjà visible (AdaptedProgramView n'en a pas besoin,
    /// SessionDetailView oui).
    var label: LocalizedStringKey?

    var body: some View {
        if !codes.isEmpty {
            HStack(spacing: 8) {
                if let label {
                    Text(label)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                HStack(spacing: 10) {
                    ForEach(codes, id: \.self) { code in
                        if let sport = Sport(sportCode: code) {
                            HStack(spacing: 4) {
                                Image(systemName: sport.sfSymbol)
                                    .font(.caption2)
                                Text(sport.localizedKey)
                                    .font(.caption2)
                            }
                            .foregroundStyle(Color.coachingSport(forCode: code))
                        }
                    }
                }
            }
            .accessibilityElement(children: .combine)
        }
    }
}
