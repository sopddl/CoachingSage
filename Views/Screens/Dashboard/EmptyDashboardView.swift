// Views/Screens/Dashboard/EmptyDashboardView.swift
// Story 3.8 — vue mode vide « Séances » simplifiée Story 3.15.
//
// **Story 3.15 (2026-05-20)** : suppression de la section "SUGGESTIONS POUR
// TOI" (les 3 templates `selectTopN` sont désormais persistés comme dormants
// via `DormantBootstrapService` au post-onboarding). Le mode `.empty` n'est
// plus le chemin d'entrée principal — il n'est atteint que si l'user supprime
// explicitement tous ses programmes (lancés + dormants).
//
// Composition restante :
//   - LeonHintView (texte calibré sur autoprofil HK, fallback générique)
//   - Hero card gradient doré (#D4A85A → #C09548)
//   - Lien dashed « Crée un programme sur mesure → » → questionnaire universel
import SwiftUI

struct EmptyDashboardView: View {
    let hintKey: LocalizedStringKey
    let onTapCustom: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            LeonHintView(hintKey)

            HeroCard()

            CustomProgramLink(onTap: onTapCustom)
        }
    }
}

// MARK: - Hero card

private struct HeroCard: View {
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: "figure.run")
                .font(.system(size: 32, weight: .semibold))
                .foregroundStyle(Color.coachingOnPrimary)
                .frame(width: 38, height: 38)

            VStack(alignment: .leading, spacing: 4) {
                Text("dashboard.empty.hero.title")
                    .font(.system(size: 20, weight: .semibold, design: .serif))
                    .foregroundStyle(Color.coachingOnPrimary)

                Text("dashboard.empty.hero.subtitle")
                    .font(.coachingBody)
                    .foregroundStyle(Color.coachingOnPrimary.opacity(0.92))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 18)
        .background(
            LinearGradient(
                colors: [Color(hex: 0xD4A85A), Color(hex: 0xC09548)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Lien programme sur mesure

private struct CustomProgramLink: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Text("dashboard.empty.custom.cta")
                    .font(.coachingBody)
                    .foregroundStyle(Color.coachingTextPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "arrow.right")
                    .font(.footnote)
                    .foregroundStyle(Color.coachingPrimary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(
                        Color.coachingTextSecondary.opacity(0.45),
                        style: StrokeStyle(lineWidth: 1, dash: [4, 3])
                    )
            )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("dashboard.empty.custom.cta")
    }
}

// MARK: - Color hex helper (privé fichier — ne PAS dupliquer si déjà exposé)

private extension Color {
    init(hex: UInt32, opacity: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: opacity)
    }
}

#Preview {
    ScrollView {
        EmptyDashboardView(
            hintKey: "dashboard.empty.hint.default",
            onTapCustom: {}
        )
        .padding(.horizontal, 16)
    }
    .background(Color.coachingBackground)
}
