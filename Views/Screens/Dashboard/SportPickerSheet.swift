// Views/Screens/Dashboard/SportPickerSheet.swift
// Story 3.8 sous-tâche 6 — bottom sheet « Quel sport ? » utilisée quand
// l'utilisateur tape « Crée un programme sur mesure → » sans avoir choisi
// un sport en amont (cas mode vide). Liste les 10 SportCode, tap → callback
// avec le sport choisi → ouvre `SportQuestionnaireView` (questionnaire universel).
import SwiftUI

struct SportPickerSheet: View {
    let onSelect: (String) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(SportCode.allCases, id: \.rawValue) { sport in
                        Button {
                            onSelect(sport.rawValue)
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: sport.sfSymbol)
                                    .font(.title3)
                                    .foregroundStyle(Color.coachingPrimary)
                                    .frame(width: 28)

                                Text(sport.localizationKey)
                                    .font(.coachingBody)
                                    .foregroundStyle(Color.coachingTextPrimary)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                Image(systemName: "chevron.right")
                                    .font(.footnote)
                                    .foregroundStyle(Color.coachingTextSecondary)
                            }
                            .padding(.vertical, 14)
                            .padding(.horizontal, 16)
                            .background(Color.coachingCard)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("sport.picker.option.\(sport.rawValue)")
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
