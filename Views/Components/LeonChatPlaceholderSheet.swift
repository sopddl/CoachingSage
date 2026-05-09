// Views/Components/LeonChatPlaceholderSheet.swift
// Story 3.8 — placeholder bottom sheet ouverte par le FAB Léon tant que la
// Story 3.6 (chat IA) n'est pas livrée. Anti-pattern "UI bloated" Runna :
// pas d'entrée chat fonctionnelle avant que le backend Léon soit prêt.
import SwiftUI

struct LeonChatPlaceholderSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                LeonAvatarView(size: 96)
                    .padding(.top, 16)

                Text("leon.placeholder.title")
                    .font(.coachingDisplay)
                    .foregroundStyle(Color.coachingTextPrimary)
                    .multilineTextAlignment(.center)

                Text("leon.placeholder.subtitle")
                    .font(.coachingBody)
                    .foregroundStyle(Color.coachingTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.coachingBackground)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("leon.placeholder.close") { dismiss() }
                        .accessibilityIdentifier("leon.placeholder.close")
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    Color.coachingBackground
        .ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            LeonChatPlaceholderSheet()
        }
}
