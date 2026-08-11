// CoachingSageTests/Coaching/Session/SessionPhaseTextTests.swift
// Story 3.35f — mise en forme échauffement/récup : puces sur « + », durée totale
// extraite, « / » assainis.
import XCTest

final class SessionPhaseTextTests: XCTestCase {

    private let warmup = "5 min de marche progressive + 10 cercles de chevilles/côté + 10 balancements de jambe + 10 demi-squats lents. Total : 8 min. Ne jamais sauter cette étape."

    func test_bulletLines_splitsOnPlus_andSanitizesSlash() {
        let lines = SessionPhaseText.bulletLines(from: warmup)
        // Découpe sur « + » ET fins de phrase → la consigne « Ne jamais sauter… »
        // devient sa propre puce.
        XCTAssertEqual(lines[0], "5 min de marche progressive")
        XCTAssertEqual(lines[1], "10 cercles de chevilles · côté") // « / » → « · »
        XCTAssertTrue(lines.contains("Ne jamais sauter cette étape"))
        // La mention « Total : … » est retirée du corps.
        XCTAssertFalse(lines.joined().contains("Total"))
    }

    func test_bulletLines_splitsProseSentences() {
        let notes = "Allure très lente. Si le souffle coupe, ralentis. Total bloc : 20 min."
        let lines = SessionPhaseText.bulletLines(from: notes)
        XCTAssertEqual(lines, ["Allure très lente", "Si le souffle coupe, ralentis"])
    }

    func test_totalLabel_extractsTotalMinutes() {
        XCTAssertEqual(SessionPhaseText.totalLabel(from: warmup), "8 min")
    }

    func test_totalLabel_nilWhenNoTotal() {
        XCTAssertNil(SessionPhaseText.totalLabel(from: "3 min marche lente. Étirements."))
    }

    // MARK: - Bug #6 — durée totale en secondes (minuteur global échauffement/récup)

    func test_totalSeconds_prefersExplicitTotal() {
        // « Total : 8 min » l'emporte sur la somme des segments.
        XCTAssertEqual(SessionPhaseText.totalSeconds(from: warmup), 480)
    }

    func test_totalSeconds_sumsSegmentsWhenNoExplicitTotal() {
        // « 5 min … + 2 min … » → 300 + 120 = 420.
        XCTAssertEqual(SessionPhaseText.totalSeconds(from: "5 min mobilité + 2 min gainage"), 420)
    }

    func test_totalSeconds_singleDuration() {
        XCTAssertEqual(SessionPhaseText.totalSeconds(from: "3 min marche lente."), 180)
    }

    func test_totalSeconds_nilWhenUnparseable() {
        XCTAssertNil(SessionPhaseText.totalSeconds(from: "Mobilité articulaire douce, sans forcer."))
    }

    func test_bulletLines_singleLineWhenNoPlus() {
        let lines = SessionPhaseText.bulletLines(from: "3 min marche lente.")
        XCTAssertEqual(lines, ["3 min marche lente"]) // point final retiré
    }

    // MARK: - Bug device ui-reviewer 2026-08-10 (chantier yoga, écran 1-sous-pas/écran)

    func test_bulletLines_stripsLeadingTotalDurationPrefix() {
        // « 7 min : » en tête = durée TOTALE du step (déjà affichée à part), pas une
        // instruction. Avant le fix, ce préfixe restait collé au 1ᵉʳ segment et
        // faisait lire `SessionDurationParser.seconds` comme "7 min" + le 1ᵉʳ nombre du
        // texte réel en secondes (7*60+2 = 422s au lieu de 120s pour "Sukhasana 2 min...").
        let lines = SessionPhaseText.bulletLines(
            from: "7 min : Sukhasana 2 min Dirgha + cercles poignets 10/sens.")
        XCTAssertEqual(lines[0], "Sukhasana 2 min Dirgha")
        XCTAssertFalse(lines[0].contains("7 min"))
    }

    func test_bulletLines_leadingPrefixWithLabel_notStripped() {
        // « N min <label> : » (label non vide avant les deux-points) N'EST PAS le
        // même motif que « N min : » seul — ne pas le retirer par erreur (cas déjà
        // couvert par `test_voiceCues_singleProseBlock_readAtStart`, non-régression).
        let lines = SessionPhaseText.bulletLines(
            from: "5 min mobilité articulaire : cercles d'épaules, rotations de poignets.")
        XCTAssertTrue(lines[0].hasPrefix("5 min mobilité articulaire"))
    }

    func test_bulletLines_respectsParenthesesDepth() {
        // « + » à l'intérieur d'une parenthèse ne doit PAS couper la ligne en 2 —
        // sinon 2 phrases orphelines avec une parenthèse non refermée (P1 ui-reviewer).
        let lines = SessionPhaseText.bulletLines(
            from: "échauffement poignets complet (cercles + paumes mur 30s × 2)")
        XCTAssertEqual(lines, ["échauffement poignets complet (cercles + paumes mur 30s × 2)"])
    }

    func test_bulletLines_parenthesesDepth_stillSplitsOutsideParens() {
        let lines = SessionPhaseText.bulletLines(
            from: "Sukhasana 2 min + poignets (cercles + paumes 30s) + chevilles 10/sens.")
        XCTAssertEqual(lines, ["Sukhasana 2 min", "poignets (cercles + paumes 30s)", "chevilles 10 · sens"])
    }

    // MARK: - Voix échauffement/récup égrenée (device-test 2026-06-09)

    func test_voiceCues_egrene_timedSegmentsAtCumulativeOffsets() {
        // Deux segments minutés → 1ʳᵉ annonce d'entrée à 0:00, la 2ᵉ à 5:00 (300 s).
        let cues = SessionPhaseVoiceSchedule.cues(
            text: "5 min vélo facile + 2 min montées de genoux",
            header: "Échauffement, 7 minutes"
        )
        XCTAssertEqual(cues, [
            .init(offset: 0, phrase: "Échauffement, 7 minutes. 5 min vélo facile."),
            .init(offset: 300, phrase: "2 min montées de genoux."),
        ])
    }

    func test_voiceCues_cuesWithoutDuration_spokenAtStart() {
        // Cas B : « épaules détendues » / « fessiers » = cues posturaux sans durée →
        // dits au DÉBUT avec le 1ᵉʳ segment, pas égrenés. Une seule annonce, à 0:00.
        let cues = SessionPhaseVoiceSchedule.cues(
            text: "5 min vélo facile + épaules détendues + fessiers serrés",
            header: "Échauffement, 5 minutes"
        )
        XCTAssertEqual(cues.count, 1)
        XCTAssertEqual(cues[0].offset, 0)
        XCTAssertEqual(cues[0].phrase, "Échauffement, 5 minutes. 5 min vélo facile. épaules détendues. fessiers serrés.")
    }

    func test_voiceCues_cueBetweenTimedSegments_doesNotShiftOffset() {
        // Un cue sans durée intercalé ne décale PAS l'offset du segment minuté suivant
        // (offset = somme des durées chiffrées uniquement).
        let cues = SessionPhaseVoiceSchedule.cues(
            text: "5 min course + dos droit + 2 min vélo",
            header: "Échauffement"
        )
        XCTAssertEqual(cues.count, 2)
        XCTAssertEqual(cues[0], .init(offset: 0, phrase: "Échauffement. 5 min course. dos droit."))
        XCTAssertEqual(cues[1], .init(offset: 300, phrase: "2 min vélo."))
    }

    func test_voiceCues_stripsLeadingTotalDurationPrefix() {
        // Même bug que `test_bulletLines_stripsLeadingTotalDurationPrefix` côté voix :
        // sans le retrait du préfixe « 7 min : », le 1ᵉʳ segment minuté était lu comme
        // 422s (7*60+2) au lieu de 120s → le 2ᵉ cue se déclenchait à un offset faux.
        let cues = SessionPhaseVoiceSchedule.cues(
            text: "7 min : Sukhasana 2 min Dirgha + cercles poignets 3 min",
            header: "Échauffement, 7 minutes"
        )
        XCTAssertEqual(cues.count, 2)
        XCTAssertEqual(cues[0].offset, 0)
        XCTAssertFalse(cues[0].phrase.contains("7 min :"))
        XCTAssertEqual(cues[1].offset, 120) // et pas 422
    }

    func test_voiceCues_singleProseBlock_readAtStart() {
        // Échauffement muscu en prose (un seul bloc minuté, sous-liste sur « . ») →
        // tout lu à 0:00, « Total : … » retiré.
        let cues = SessionPhaseVoiceSchedule.cues(
            text: "5 min mobilité articulaire : cercles d'épaules, rotations de poignets. Total : 7 min.",
            header: "Échauffement, 7 minutes"
        )
        XCTAssertEqual(cues.count, 1)
        XCTAssertEqual(cues[0].offset, 0)
        XCTAssertFalse(cues[0].phrase.contains("Total"))
        XCTAssertTrue(cues[0].phrase.hasPrefix("Échauffement, 7 minutes."))
    }
}
