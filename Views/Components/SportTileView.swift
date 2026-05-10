// Views/Components/SportTileView.swift
// Story sœur post-3.3b — composant partagé pour les 3 grilles sports (onboarding,
// modif profil, sport picker création programme). Garantit que les 3 endroits ont
// EXACTEMENT le même rendu :
//   - carré 1:1 (vs height 96pt fixe legacy)
//   - bordure couleur signature sport (mockup photo 2)
//   - icône en couleur sport (vs uniforme primary)
//   - label sur 2 lignes max + minimumScaleFactor pour les noms longs (Musculation, Randonnée)
//   - état sélectionné (multi-select) → fill couleur sport, label/icône blanc
//   - tooltip HIIT optionnel
import SwiftUI

struct SportTileView: View {
    let sport: SportCode
    /// Pour les modes multi-sélection (onboarding sportsSelection, edit profile).
    /// `false` pour le picker single-tap (création programme).
    let isSelected: Bool
    let onTap: () -> Void
    /// Si fourni, affiche un info badge dans le coin pour HIIT (cf onboarding).
    /// Picker programme = nil (pas besoin du tooltip à ce stade).
    let onShowTooltip: (() -> Void)?
    /// Préfixe accessibilityIdentifier pour distinguer onboarding/profile/picker.
    let identifierPrefix: String

    private var sportColor: Color {
        Color.coachingSport(forCode: sport.rawValue)
    }

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 8) {
                    Image(systemName: sport.sfSymbol)
                        .font(.system(size: 32))
                        .foregroundStyle(isSelected ? Color.coachingOnPrimary : sportColor)
                    Text(LocalizedStringKey(sport.localizationKey))
                        .font(.coachingCaption)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.85)
                        .foregroundStyle(isSelected ? Color.coachingOnPrimary : Color.coachingTextPrimary)
                        .padding(.horizontal, 4)
                }
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .background(
                    RoundedRectangle(cornerRadius: CoachingRadius.md)
                        .fill(isSelected ? sportColor : Color.coachingCard)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: CoachingRadius.md)
                        .strokeBorder(sportColor, lineWidth: 2)
                )

                if sport == .hiit, let onShowTooltip {
                    Button(action: onShowTooltip) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(isSelected ? Color.coachingOnPrimary : sportColor)
                            .padding(8)
                    }
                    .accessibilityIdentifier("\(identifierPrefix).hiit.info")
                    .accessibilityLabel(Text("onboarding.sport.hiit.tooltip.title"))
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("\(identifierPrefix).\(sport.rawValue)")
        .accessibilityAddTraits(isSelected ? [.isSelected, .isButton] : .isButton)
    }
}
