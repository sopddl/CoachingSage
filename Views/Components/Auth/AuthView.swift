// Views/Components/Auth/AuthView.swift
// [COPIE IDENTIQUE] — synchroniser avec GardenSage et TailorSage
// (avec branding CoachingSage : icône figure.run, tokens coaching*).
import SwiftUI
import AuthenticationServices

struct AuthView: View {
    @State private var viewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    @State private var showResetPasswordAlert = false
    @State private var resetEmail = ""

    init(authService: any AuthServiceProtocol,
         coreProfileRepository: any CoreProfileRepository) {
        _viewModel = State(initialValue: AuthViewModel(
            authService: authService,
            coreProfileRepository: coreProfileRepository
        ))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // En-tête branding CoachingSage
                VStack(spacing: 8) {
                    Image(systemName: "figure.run")
                        .font(.system(size: 72))
                        .foregroundStyle(Color.coachingPrimary)
                    Text("CoachingSage")
                        .font(.coachingDisplay)
                    Text("auth.tagline")
                        .font(.coachingBody)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 48)

                VStack(spacing: 16) {
                    // ─── Apple Sign In EN PREMIER (App Store Review Guidelines 4.8) ───
                    SignInWithAppleButton(
                        onRequest: { request in
                            request.requestedScopes = [.fullName, .email]
                            request.nonce = viewModel.generateAppleSignInNonce()
                        },
                        onCompletion: { result in
                            Task { await viewModel.handleAppleSignIn(result: result) }
                        }
                    )

                    // Séparateur
                    HStack {
                        Rectangle()
                            .frame(height: 1)
                            .foregroundStyle(.quaternary)
                        Text("auth.separator.or")
                            .font(.coachingCaption)
                            .foregroundStyle(.secondary)
                        Rectangle()
                            .frame(height: 1)
                            .foregroundStyle(.quaternary)
                    }

                    // ─── Email / Mot de passe ───
                    VStack(spacing: 12) {
                        TextField("auth.email.placeholder", text: $email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .accessibilityIdentifier("auth.email")
                            .padding()
                            .background(.regularMaterial)
                            .cornerRadius(12)

                        SecureField("auth.password.placeholder", text: $password)
                            .textContentType(isSignUp ? .newPassword : .password)
                            .padding()
                            .background(.regularMaterial)
                            .cornerRadius(12)

                        Button {
                            Task {
                                if isSignUp {
                                    await viewModel.signUp(email: email, password: password)
                                } else {
                                    await viewModel.signIn(email: email, password: password)
                                }
                            }
                        } label: {
                            Group {
                                if case .loading = viewModel.authState {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text(isSignUp ? LocalizedStringKey("auth.createAccount") : LocalizedStringKey("auth.signIn"))
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                        }
                        .primaryButtonStyle()
                        .disabled(email.isEmpty || password.isEmpty || isLoading)
                    }

                    // Mot de passe oublié (visible uniquement en mode connexion)
                    if !isSignUp {
                        Button {
                            resetEmail = email
                            showResetPasswordAlert = true
                        } label: {
                            Text(String(localized: "auth.forgotPassword"))
                        }
                        .font(.coachingCaption)
                    }

                    // Toggle inscription / connexion
                    Button {
                        isSignUp.toggle()
                        viewModel.authState = .idle
                    } label: {
                        Text(isSignUp ? LocalizedStringKey("auth.alreadyHaveAccount") : LocalizedStringKey("auth.noAccount"))
                    }
                    .font(.coachingCaption)

                    #if DEBUG
                    // Login rapide pour tests sur simulateur (pas d'Apple Sign In)
                    Button("Dev Login (test-claude)") {
                        email = "test-claude@coachingsage.app"
                        password = "CoachingTest2026!"
                        Task { await viewModel.signIn(email: email, password: password) }
                    }
                    .font(.coachingCaption)
                    .foregroundStyle(.secondary)
                    #endif

                    // Message d'erreur
                    if case .error(let error) = viewModel.authState {
                        Text(error.localizedDescription)
                            .font(.coachingBody)
                            .foregroundStyle(Color.coachingError)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                .padding(.horizontal, 24)

                Spacer(minLength: 40)
            }
        }
        .background(Color.coachingBackground)
        .alert(String(localized: "auth.forgotPassword.title"), isPresented: $showResetPasswordAlert) {
            TextField(String(localized: "auth.email.placeholder"), text: $resetEmail)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            Button(String(localized: "auth.forgotPassword.send")) {
                Task { await viewModel.resetPassword(email: resetEmail) }
            }
            Button(String(localized: "auth.forgotPassword.cancel"), role: .cancel) { }
        } message: {
            Text(String(localized: "auth.forgotPassword.message"))
        }
        .alert(String(localized: "auth.forgotPassword.sent.title"), isPresented: $viewModel.resetPasswordSent) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(String(localized: "auth.forgotPassword.sent.message"))
        }
        .alert(String(localized: "auth.forgotPassword.error.title"), isPresented: .init(
            get: { viewModel.resetPasswordError != nil },
            set: { if !$0 { viewModel.resetPasswordError = nil } }
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.resetPasswordError ?? "")
        }
    }

    private var isLoading: Bool {
        if case .loading = viewModel.authState { return true }
        return false
    }
}
