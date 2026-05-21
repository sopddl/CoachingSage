// Views/Screens/Dashboard/EmptyDashboardView.swift
// Story 3.8 — vue mode vide « Accueil » simplifiée Story 3.15.
//
// **Story 3.15 v7 (Sophie 2026-05-21)** : refonte complète. La version
// précédente avait LeonHintView (qui s'étirait), HeroCard doré au texte
// obsolète ("Léon a préparé 3 programmes" alors que rien n'est créé) +
// CustomProgramLink. Sophie : « pas de bouton, c'est horrible ».
//
// Nouveau layout, centré et minimal :
//   - Icône sport accent gold
//   - Titre + sous-titre clairs
//   - Bouton CTA primary "Crée mon premier programme"
//   - (Le bouton "+" en toolbar est aussi visible désormais.)
import SwiftUI

struct EmptyDashboardView: View {
    let hintKey: LocalizedStringKey
    let onTapCustom: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 20)

            // Icône hero
            ZStack {
                Circle()
                    .fill(Color.coachingPrimary.opacity(0.12))
                Image(systemName: "figure.run")
                    .font(.system(size: 38, weight: .semibold))
                    .foregroundStyle(Color.coachingPrimary)
            }
            .frame(width: 96, height: 96)

            VStack(spacing: 8) {
                Text("dashboard.empty.title")
                    .font(.system(size: 22, weight: .semibold, design: .serif))
                    .foregroundStyle(Color.coachingTextPrimary)
                    .multilineTextAlignment(.center)
                Text(hintKey)
                    .font(.coachingBody)
                    .foregroundStyle(Color.coachingTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            Button(action: onTapCustom) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.headline)
                    Text("dashboard.empty.cta.create")
                        .font(.headline)
                }
                .foregroundStyle(Color.coachingOnPrimary)
                .padding(.horizontal, 22)
                .padding(.vertical, 14)
                .background(Color.coachingPrimary)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("dashboard.empty.cta.create")

            Spacer(minLength: 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    EmptyDashboardView(
        hintKey: "dashboard.empty.hint.default",
        onTapCustom: {}
    )
    .background(Color.coachingBackground)
}
