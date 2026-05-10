// Views/Screens/Dashboard/SportPickerSheet.swift
// Story 3.8 sous-tâche 6 — bottom sheet « Quel sport ? » utilisée quand
// l'utilisateur tape « Crée un programme sur mesure → » sans avoir choisi
// un sport en amont (cas mode vide). Tap → callback avec le sport choisi
// → ouvre `SportQuestionnaireView` (questionnaire universel).
//
// Story sœur post-3.3b — alignement layout sur `SportsSelectionView` onboarding :
// helper text + padding 24 + composant `SportTileView` partagé (carrés couleur sport
// avec lineLimit(2) pour pas tronquer Musculation/Randonnée).
import SwiftUI

struct SportPickerSheet: View {
    let onSelect: (String) -> Void

    @Environment(\.dismiss) private var dismiss

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("dashboard.sport.picker.helper")
                        .font(.coachingBody)
                        .foregroundStyle(Color.coachingTextSecondary)
                        .padding(.top, 16)

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(SportCode.allCases, id: \.rawValue) { sport in
                            SportTileView(
                                sport: sport,
                                isSelected: false,            // single-tap, pas de sélection persistée
                                onTap: { onSelect(sport.rawValue) },
                                onShowTooltip: nil,           // tooltip HIIT déjà vu à l'onboarding
                                identifierPrefix: "sport.picker.option"
                            )
                        }
                    }

                    Spacer(minLength: 32)
                }
                .padding(.horizontal, 24)
            }
            .background(Color.coachingBackground.ignoresSafeArea())
            .navigationTitle(Text("dashboard.sport.picker.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("common.close")
                    }
                }
            }
        }
    }
}
