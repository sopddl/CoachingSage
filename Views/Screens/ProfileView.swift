// Views/Screens/ProfileView.swift
// Story 1.2 placeholder — contenu Epic 2 (profil sportif).
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
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.coachingBackground)
    }
}

#Preview {
    ProfileView()
}
