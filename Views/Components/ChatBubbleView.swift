// Views/Components/ChatBubbleView.swift
// Story 3.1 — bulle de chat réutilisable (Léon gauche, user droite).
// La résolution localisation se fait via Text(LocalizedStringKey(key)) (review P0-1 : pas de LocalizedStringKey en input).
// Pour les bulles user multi-choix : la chaîne `text` peut contenir plusieurs clés séparées par "|" (cf. ViewModel).
import SwiftUI

struct ChatBubbleView: View {
    enum Sender { case leon, user }

    let sender: Sender
    /// Pour Léon : clé xcstrings unique. Pour user : clé unique OU "key1|key2|..." pour multi-choix.
    let textRaw: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if sender == .leon {
                LeonAvatarView(size: 32)
                bubble
                Spacer(minLength: 40)
            } else {
                Spacer(minLength: 40)
                bubble
            }
        }
    }

    @ViewBuilder
    private var bubble: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .background(sender == .leon ? Color.coachingCard : Color.coachingPrimary)
        .foregroundStyle(sender == .leon ? Color.coachingTextPrimary : Color.coachingOnPrimary)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }

    @ViewBuilder
    private var content: some View {
        if textRaw.contains("|") {
            // Multi-choix : split + concat avec virgule à la résolution.
            let keys = textRaw.split(separator: "|").map(String.init)
            (Text("").foregroundStyle(.clear) + multiText(from: keys))
        } else {
            Text(LocalizedStringKey(textRaw))
        }
    }

    /// Concat des labels résolus avec une séparation virgule.
    private func multiText(from keys: [String]) -> Text {
        var combined = Text("")
        for (idx, key) in keys.enumerated() {
            if idx > 0 { combined = combined + Text(", ") }
            combined = combined + Text(LocalizedStringKey(key))
        }
        return combined
    }

    private var accessibilityLabel: Text {
        let prefix: LocalizedStringKey = sender == .leon ? "chat.a11y.leonSays" : "chat.a11y.userReplied"
        return Text(prefix) + Text(" ") + (textRaw.contains("|")
            ? multiText(from: textRaw.split(separator: "|").map(String.init))
            : Text(LocalizedStringKey(textRaw)))
    }
}

#Preview {
    VStack(spacing: 12) {
        ChatBubbleView(sender: .leon, textRaw: "questionnaire.running.intro")
        ChatBubbleView(sender: .user, textRaw: "questionnaire.running.q1.option.regular")
        ChatBubbleView(sender: .leon, textRaw: "questionnaire.running.q4.text")
        ChatBubbleView(sender: .user, textRaw: "questionnaire.running.q4.option.knee|questionnaire.running.q4.option.back")
    }
    .padding()
    .background(Color.coachingBackground)
}
