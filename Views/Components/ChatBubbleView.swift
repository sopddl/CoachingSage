// Views/Components/ChatBubbleView.swift
// Story 3.1 — bulle de chat réutilisable (Léon gauche, user droite).
// La résolution localisation se fait via Text(LocalizedStringKey(key)) (review P0-1 : pas de LocalizedStringKey en input).
// Pour les bulles user multi-choix : la chaîne `text` peut contenir plusieurs clés séparées par "|" (cf. ViewModel).
import SwiftUI

struct ChatBubbleView: View {
    enum Sender { case leon, user }

    /// Story 3.14 — avatar à gauche des bulles Léon. Default `.leon` préserve
    /// la rétro-compat 100% sur tous les call sites existants. Le questionnaire
    /// passe `.sport(code:)` pour contextualiser le sport en cours de génération.
    enum AvatarStyle: Equatable {
        case leon
        case sport(code: String)
    }

    let sender: Sender
    /// Pour Léon : clé xcstrings unique. Pour user : clé unique OU "key1|key2|..." pour multi-choix.
    let textRaw: String
    let avatarStyle: AvatarStyle
    /// Story 3.30 — "remonter le fil" : si fourni (bulle user d'une réponse passée), la bulle
    /// devient tappable (crayon + tap) pour rouvrir la question et modifier la réponse.
    let onEdit: (() -> Void)?

    init(sender: Sender, textRaw: String, avatarStyle: AvatarStyle = .leon, onEdit: (() -> Void)? = nil) {
        self.sender = sender
        self.textRaw = textRaw
        self.avatarStyle = avatarStyle
        self.onEdit = onEdit
    }

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if sender == .leon {
                avatar
                bubble
                Spacer(minLength: 40)
            } else {
                Spacer(minLength: 40)
                if let onEdit {
                    Button(action: onEdit) { editableBubble }
                        .buttonStyle(.plain)
                        .accessibilityHint(Text("chat.a11y.editHint"))
                } else {
                    bubble
                }
            }
        }
    }

    /// Bulle user avec affordance d'édition : crayon dans une pastille primary
    /// (assez visible pour signaler "tappable" sans alourdir, Story 3.30 P1 ui-reviewer).
    private var editableBubble: some View {
        HStack(alignment: .center, spacing: 6) {
            Image(systemName: "pencil")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.coachingOnPrimary)
                .padding(5)
                .background(Color.coachingPrimary.opacity(0.55), in: Circle())
            bubble
        }
    }

    @ViewBuilder
    private var avatar: some View {
        switch avatarStyle {
        case .leon:
            LeonAvatarView(size: 32)
        case .sport(let code):
            SportAvatarView(sportCode: code, size: 32)
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
        Divider()
        ChatBubbleView(sender: .leon, textRaw: "questionnaire.running.intro", avatarStyle: .sport(code: "running"))
        ChatBubbleView(sender: .leon, textRaw: "questionnaire.swimming.intro", avatarStyle: .sport(code: "swimming"))
        ChatBubbleView(sender: .leon, textRaw: "questionnaire.triathlon.intro", avatarStyle: .sport(code: "triathlon"))
    }
    .padding()
    .background(Color.coachingBackground)
}
