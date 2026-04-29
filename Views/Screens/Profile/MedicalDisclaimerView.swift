// Views/Screens/Profile/MedicalDisclaimerView.swift
// Story 2.3 — disclaimer médical read-only. Réutilise onboarding.disclaimer.body (pas de duplication).
import SwiftUI

struct MedicalDisclaimerView: View {
    let versionAccepted: String?
    let acceptedAt: Date?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("onboarding.disclaimer.title")
                    .font(.coachingH1)
                    .foregroundStyle(Color.coachingTextPrimary)

                Text("onboarding.disclaimer.body")
                    .font(.coachingBody)
                    .foregroundStyle(Color.coachingTextPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                if let version = versionAccepted, let date = acceptedAt {
                    Divider().padding(.vertical, 8)
                    Text("profile.disclaimer.acceptedOn \(version) \(formatted(date))")
                        .font(.coachingCaption)
                        .foregroundStyle(Color.coachingTextSecondary)
                        .accessibilityIdentifier("profile.disclaimer.acceptedOn")
                }
            }
            .padding(24)
        }
        .background(Color.coachingBackground)
        .navigationTitle("profile.disclaimer.title")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func formatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

#Preview {
    NavigationStack {
        MedicalDisclaimerView(versionAccepted: "1.0", acceptedAt: Date())
    }
}
