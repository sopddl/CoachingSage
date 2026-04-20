// Views/Components/Auth/SignInWithAppleButton.swift
// [COPIE IDENTIQUE] — synchroniser avec GardenSage et TailorSage
// (avec substitution GardenRadius → CoachingRadius).
import SwiftUI
import AuthenticationServices

struct SignInWithAppleButton: View {
    let onRequest: (ASAuthorizationAppleIDRequest) -> Void
    let onCompletion: (Result<ASAuthorization, Error>) -> Void

    var body: some View {
        // Utilise le composant natif Apple — style obligatoire App Store
        AuthenticationServices.SignInWithAppleButton(.signIn,
                                                     onRequest: onRequest,
                                                     onCompletion: onCompletion)
            .signInWithAppleButtonStyle(.black)
            .frame(height: 52)
            .cornerRadius(CoachingRadius.md)
            .accessibilityLabel(Text("auth.signInWithApple.accessibilityLabel"))
    }
}

#Preview {
    SignInWithAppleButton(
        onRequest: { _ in },
        onCompletion: { _ in }
    )
    .padding()
}
