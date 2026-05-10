// Views/Screens/Dashboard/SportPickerSheet.swift
// Story 3.8 sous-tâche 6 — bottom sheet « Quel sport ? » utilisée quand
// l'utilisateur tape « Crée un programme sur mesure → » sans avoir choisi
// un sport en amont (cas mode vide). Tap → callback avec le sport choisi
// → ouvre `SportQuestionnaireView` (questionnaire universel).
//
// Story sœur post-3.3b — refonte en grille 2 colonnes avec icônes (pattern
// `SportsSelectionView` onboarding) pour cohérence visuelle.
import SwiftUI

struct SportPickerSheet: View {
    let onSelect: (String) -> Void

    @Environment(\.dismiss) private var dismiss

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(SportCode.allCases, id: \.rawValue) { sport in
                        SportPickerCell(sport: sport) {
                            onSelect(sport.rawValue)
                        }
                    }
                }
                .padding(16)
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

/// Cellule grille (pattern `SportsSelectionView.SportCell`, simplifié : pas de sélection
/// multi/toggle puisque le picker = single-tap → callback immédiat).
private struct SportPickerCell: View {
    let sport: SportCode
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(systemName: sport.sfSymbol)
                    .font(.system(size: 32))
                    .foregroundStyle(Color.coachingPrimary)
                Text(LocalizedStringKey(sport.localizationKey))
                    .font(.coachingCaption)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.coachingTextPrimary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 96)
            .background(
                RoundedRectangle(cornerRadius: CoachingRadius.md)
                    .fill(Color.coachingCard)
            )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("sport.picker.option.\(sport.rawValue)")
    }
}
