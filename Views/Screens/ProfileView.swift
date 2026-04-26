// Views/Screens/ProfileView.swift
// Story 1.2 placeholder — contenu Epic 2 (profil sportif).
// Story 1.4 — section "Zone dangereuse" + NavigationLink vers DeleteAccountView.
// Bouton Déconnexion dispo ici dès Story 1.2 (remplace l'ancien placeholder auth).
import SwiftUI

struct ProfileView: View {
    @Environment(\.appDependencies) private var deps

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "person.crop.circle")
                .font(.system(size: 64))
                .foregroundStyle(Color.coachingPrimary)

            Text("tab.profile")
                .font(.coachingDisplay)
                .foregroundStyle(Color.coachingTextPrimary)

            Text("placeholder.coming_soon")
                .font(.coachingBody)
                .foregroundStyle(Color.coachingTextSecondary)

            Spacer()

            Button("auth.signOut") {
                Task { try? await deps?.authService.signOut() }
            }
            .primaryButtonStyle()
            .padding(.horizontal, 24)

            VStack(alignment: .leading, spacing: 8) {
                Text("profile.section.dangerZone")
                    .font(.coachingCaption)
                    .foregroundStyle(Color.coachingTextSecondary)
                    .textCase(.uppercase)

                NavigationLink {
                    DeleteAccountView()
                } label: {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(Color.coachingError)
                        Text("account.delete.button")
                            .font(.coachingBody)
                            .foregroundStyle(Color.coachingError)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(Color.coachingTextSecondary)
                    }
                    .padding()
                    .background(Color.coachingCard)
                    .cornerRadius(CoachingRadius.md)
                }
                .accessibilityIdentifier("delete_account_link")
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.coachingBackground)
    }
}

#Preview {
    ProfileView()
}
