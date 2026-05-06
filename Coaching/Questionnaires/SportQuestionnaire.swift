// Coaching/Questionnaires/SportQuestionnaire.swift
// Story 3.1 — protocol pour les questionnaires sportifs locaux (1 par sport).
// 100% local, 0 réseau, 0 token. Génère un CoachingSportProfile à partir des réponses.
// Pattern : ajouter un sport = créer un fichier Swift implémentant ce protocol + dispatch SeanceView.
import Foundation

protocol SportQuestionnaire {
    /// Code aligné avec enum SportCode (running, cycling, swimming, ...).
    var sportCode: String { get }

    /// Marker de version pour migrations futures du flow (ex: "running_v1").
    /// Stocké dans CoachingSportProfile.questionnaireVersion (review P2-7).
    var version: String { get }

    /// Première question du flow.
    var firstQuestion: QuestionnaireQuestion { get }

    /// Question suivante après une réponse, en fonction des réponses accumulées.
    /// Retourne nil = fin du questionnaire (déclenche le buildProfile + save).
    func nextQuestion(
        after questionId: QuestionId,
        answer: AnswerValue,
        accumulated: [QuestionId: AnswerValue]
    ) -> QuestionnaireQuestion?

    /// Lookup d'une question par id — utilisé par le ViewModel pour reconstruire l'état au resume
    /// et pour pré-remplir des réponses depuis l'autoprofil HealthKit (sans hardcoder les textKeys).
    func findQuestion(byId id: QuestionId) -> QuestionnaireQuestion?

    /// Construit le draft du profil sport à partir des réponses + historique conversationnel.
    /// `medicalClearanceAcknowledged` doit être passé par le ViewModel = snapshot
    /// de coachingProfile.requiresMedicalClearance au moment du save (review P0-6).
    func buildProfile(
        userId: UUID,
        answers: [QuestionId: AnswerValue],
        freeTextNotes: String?,
        history: [ConversationEntry],
        medicalClearanceAcknowledged: Bool
    ) -> CoachingSportProfile
}
