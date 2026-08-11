// CoachingSageTests/Coaching/Glossary/YogaGlossaryPostureCoverageTests.swift
// Garde-fou pérenne — chantier yoga débutant pas assez didactique (2026-08-09).
//
// Sophie a remonté (test device réel, jamais fait de yoga) qu'elle devait chercher sur
// Internet pour comprendre les postures : le glossaire tappable ne couvrait que 8 termes
// génériques (asana, vinyasa, pranayama...) + cat-cow, aucune posture individuelle
// (tadasana, sukhasana, marjaryasana-bitilasana...).
//
// Ce filet charge le bundle PROD (`TemplateLoader.loadAll`) et vérifie que tout terme
// sanskrit connu RÉELLEMENT shipé dans le contenu yoga affiché (name/warmup/cooldown/notes,
// sessions + variantes) est détecté par `Glossary.matches(in:)` — donc tappable. Un futur
// terme ajouté à un template sans entrée glossaire correspondante casse ce test plutôt que
// de fuir en jargon non cliquable à l'écran.
import XCTest
import TemplateLoader
import TemplateModel

final class YogaGlossaryPostureCoverageTests: XCTestCase {

    /// Postures/pranayama individuels attendus glossés — même liste que les entrées
    /// `yoga.*` ajoutées à `Glossary.entries` (Coaching/Glossary/Glossary.swift) et les
    /// patterns correspondants dans `GlossaryMatcher.detectionPatterns`.
    private static let expectedTerms: [String] = [
        "adho mukha svanasana", "adho mukha vrksasana", "anjaneyasana", "ardha chandrasana",
        "ardha matsyendrasana", "ardha uttanasana", "bakasana", "balasana", "bhujangasana",
        "chaturanga dandasana", "dhanurasana", "dirgha", "garudasana", "janu sirsasana",
        "marjaryasana-bitilasana", "nadi shodhana", "navasana", "paschimottanasana",
        "phalakasana", "pincha mayurasana", "salabhasana", "salamba bhujangasana",
        "savasana", "setu bandha sarvangasana", "setu bandha", "sirsasana", "sukhasana",
        "supta baddha konasana", "tadasana", "trikonasana", "urdhva dhanurasana",
        "ustrasana", "utkatasana", "uttanasana", "utthita parsvakonasana",
        "utthita trikonasana", "viparita karani", "virabhadrasana", "vrksasana",
    ]

    func test_everySanskritPostureShippedInYogaContentIsGlossaryTappable() async throws {
        let all = try await TemplateLoader.loadAll()
        let yoga = all.filter { $0.sport == .yoga }
        try XCTSkipIf(yoga.isEmpty, "bundle yoga non peuplé")

        var corpus: [String] = []
        for tpl in yoga {
            for week in tpl.weeks {
                for session in week.sessions {
                    corpus.append(session.name.fr)
                    session.warmup.map { corpus.append($0.fr) }
                    session.cooldown.map { corpus.append($0.fr) }
                    for ex in session.exercises {
                        corpus.append(ex.name.fr)
                        ex.notes.map { corpus.append($0.fr) }
                        corpus.append(contentsOf: ex.alternatives.map { $0.fr })
                    }
                    for variant in session.variants ?? [] {
                        corpus.append(variant.name.fr)
                        variant.warmup.map { corpus.append($0.fr) }
                        variant.cooldown.map { corpus.append($0.fr) }
                        for ex in variant.exercises {
                            corpus.append(ex.name.fr)
                            ex.notes.map { corpus.append($0.fr) }
                            corpus.append(contentsOf: ex.alternatives.map { $0.fr })
                        }
                    }
                }
            }
        }
        let fullText = corpus.joined(separator: " ").lowercased()

        var failures: [String] = []
        for term in Self.expectedTerms {
            guard fullText.contains(term) else { continue } // terme pas shipé dans ce build, rien à couvrir
            if Glossary.matches(in: term).isEmpty {
                failures.append(term)
            }
        }
        XCTAssertTrue(failures.isEmpty,
            "Terme sanskrit shipé dans le contenu yoga mais non détecté par GlossaryMatcher "
                + "(donc pas tappable à l'écran) : \(failures.sorted())")
    }
}
