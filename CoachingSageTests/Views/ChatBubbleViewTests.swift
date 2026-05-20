// CoachingSageTests/Views/ChatBubbleViewTests.swift
// Story 3.14 AC11 — init paths + rétro-compat call sites + AvatarStyle equality.
// Pas de snapshot infra côté CoachingSage : on couvre l'API publique (default
// `.leon`, switch sur sport, user inchangée) via init + Equatable.
import XCTest
import SwiftUI
@testable import CoachingSage

final class ChatBubbleViewTests: XCTestCase {
    // MARK: - AvatarStyle equality

    func test_avatarStyle_leonEqualsLeon() {
        XCTAssertEqual(ChatBubbleView.AvatarStyle.leon, .leon)
    }

    func test_avatarStyle_sportSameCode_isEqual() {
        XCTAssertEqual(
            ChatBubbleView.AvatarStyle.sport(code: "running"),
            ChatBubbleView.AvatarStyle.sport(code: "running")
        )
    }

    func test_avatarStyle_sportDifferentCodes_areNotEqual() {
        XCTAssertNotEqual(
            ChatBubbleView.AvatarStyle.sport(code: "running"),
            ChatBubbleView.AvatarStyle.sport(code: "cycling")
        )
    }

    func test_avatarStyle_leonAndSport_areNotEqual() {
        XCTAssertNotEqual(
            ChatBubbleView.AvatarStyle.leon,
            ChatBubbleView.AvatarStyle.sport(code: "running")
        )
    }

    // MARK: - Init paths (compile-time rétro-compat + default behavior)

    func test_init_defaultAvatarStyle_isLeon() {
        // Call site existant SANS avatarStyle doit compiler ET conserver .leon.
        let bubble = ChatBubbleView(sender: .leon, textRaw: "questionnaire.running.intro")
        XCTAssertEqual(bubble.avatarStyle, .leon)
    }

    func test_init_leonSender_acceptsSportAvatar() {
        let bubble = ChatBubbleView(
            sender: .leon,
            textRaw: "questionnaire.swimming.intro",
            avatarStyle: .sport(code: "swimming")
        )
        XCTAssertEqual(bubble.avatarStyle, .sport(code: "swimming"))
    }

    func test_init_userSender_avatarStyleStillStoredButUnused() {
        // AC6 : pour sender .user, avatarStyle est ignoré dans le rendu (pas
        // d'avatar à gauche). Le param doit néanmoins être accepté sans crash.
        let bubble = ChatBubbleView(
            sender: .user,
            textRaw: "questionnaire.running.q1.option.regular",
            avatarStyle: .sport(code: "running")
        )
        XCTAssertEqual(bubble.sender, .user)
        // L'avatar n'est pas rendu pour .user — invariant garanti par le HStack.
    }

    func test_init_userSender_defaultStyleStillLeon() {
        let bubble = ChatBubbleView(
            sender: .user,
            textRaw: "questionnaire.running.q4.option.knee|questionnaire.running.q4.option.back"
        )
        XCTAssertEqual(bubble.avatarStyle, .leon)
    }
}
