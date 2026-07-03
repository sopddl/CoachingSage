import XCTest
@testable import TemplateLoader
import TemplateModel

/// Filet de régression chantier densité B, increment 1 (revue doctrine 2026-07-02) :
/// aucun exercice de nature pliométrique/sprint (sauts, bonds, sprints) ne doit être
/// taggé dans une zone facile/technique. Un tel mistag rendrait l'exo éligible à la
/// densification « +1 set » (whitelists G3) alors que le volume plio/sprint ne se
/// densifie jamais (NSCA : progression plio = qualité, pas volume ajouté).
///
/// Passe de retag associée : `scripts/densite_b/retag_plio_sprint.py` (23 instances —
/// sprints tennis-recreational → RPE 8-9, box jumps PPL / A-skip hiking / bonds
/// football-beginner → RPE 7-8).
final class NoPlioSprintInEasyZonesTests: XCTestCase {

    /// Zones « faciles » (aucun exo explosif ne doit y vivre). Aligné sur le gisement
    /// des whitelists G3 + zones techniques/récup.
    private static let easyZones: Set<String> = [
        "technique", "tactique",
        "Z1", "Z2", "Z3", "Z2-cardiac", "walking-recovery",
        "Daniels-E", "FTP-Z1", "FTP-Z2", "EN1", "REC",
        "RPE 4-5", "RPE 5-6", "RPE 6-7",
    ]

    /// Marqueurs lexicaux plio/sprint dans match_key + name FR/EN.
    private static let plioPattern = try! NSRegularExpression(
        pattern: #"sprint|plyo|pliom|plyom|box jump|\bbounds?\b|bounding|bondissement|a-skip|depth jump|vertical jump|jumps?\b|\bsauts?\b|\bsaltos?\b"#,
        options: [.caseInsensitive]
    )

    /// Exceptions VOLONTAIRES (revues une à une, 2026-07-02) — le marqueur lexical est
    /// un faux positif, l'exo n'est pas de la pliométrie/sprint en zone facile :
    /// - blocs vélo Z2 avec openers (sets=1, la zone décrit le bloc dominant) ;
    /// - corde à sauter / skips = cardio continu doux, pas de la plio ;
    /// - échelle d'agilité (petits appuis bas, coordination) ;
    /// - drill technique double-unders (apprentissage corde, séance interval HIIT
    ///   de toute façon exclue du levier L1) ;
    /// - split-step tennis (footwork fondamental, amplitude minimale).
    private static let reviewedExceptions: [String] = [
        "Bloc Z2 +",
        "Pre-race opener Z2",
        "Cardio doux — corde à sauter",
        "Cardio intermittent doux — corde à sauter",
        "Agility ladder",
        "Drill double-unders",
        "Split-step",
    ]

    private func isPlioLike(_ e: TemplateExercise) -> Bool {
        let txt = [e.stableMatchKey, e.name.fr, e.name.en ?? ""].joined(separator: " | ")
        let range = NSRange(txt.startIndex..., in: txt)
        return Self.plioPattern.firstMatch(in: txt, range: range) != nil
    }

    private func isReviewedException(_ e: TemplateExercise) -> Bool {
        Self.reviewedExceptions.contains { e.stableMatchKey.hasPrefix($0) || e.stableMatchKey.contains($0) }
    }

    func testNoPlioSprintExerciseInEasyZone() async throws {
        let templates = try await TemplateLoader.loadAll()
        guard templates.count >= 30 else { throw XCTSkip("bundle non peuplé (\(templates.count))") }

        var failures: [String] = []
        for t in templates {
            for w in t.weeks {
                for s in w.sessions {
                    let allExercises = s.exercises + (s.variants ?? []).flatMap(\.exercises)
                    for e in allExercises {
                        guard let zone = e.targetZone, Self.easyZones.contains(zone) else { continue }
                        guard isPlioLike(e), !isReviewedException(e) else { continue }
                        failures.append("[\(t.id)] W\(w.weekNumber) « \(e.stableMatchKey) » zone=\(zone)")
                    }
                }
            }
        }
        XCTAssertTrue(
            failures.isEmpty,
            """
            \(failures.count) exo(s) plio/sprint en zone facile — retagger en zone haute \
            (RPE 7-8 plio légère / RPE 8-9 sprint) ou documenter l'exception si revue :
            \(failures.prefix(20).joined(separator: "\n"))
            """
        )
    }
}
