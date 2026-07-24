import XCTest
@testable import TemplateLoader
import TemplateModel

/// Filet de régression — chantier vulgarisation par niveau, volet yoga (2026-07-24).
///
/// Verrouille que tout terme sanskrit apparaissant dans `week.goal`/`week.theme` (FR) est
/// glosé, même convention que `exercise.name` (« Posture de la montagne (tadasana) ») :
/// soit le terme sanskrit est immédiatement suivi d'une glose FR entre parenthèses/crochets
/// (ex. « Trikonasana (posture du triangle) »), soit il apparaît lui-même comme la glose
/// sanskrit d'un nom FR qui le précède (ex. « Posture du triangle (trikonasana) »).
///
/// Avant ce filet, le FR de certains templates listait des postures en sanskrit brut
/// (« Découvrir 5 postures de base (Tadasana, Sukhasana...) ») alors que EN/ES utilisaient
/// déjà des noms traduits — trou spécifique au FR, comblé passe par passe (mémoire cs
/// `backlog_vulgarisation_par_niveau`).
final class NoUnglossedSanskritInWeekSummaryTests: XCTestCase {

    /// Termes sanskrit connus (noms de postures/pranayama) susceptibles d'apparaître dans
    /// le texte prose de `goal`/`theme`. Triés plus long d'abord pour matcher les formes
    /// composées (ex. « surya namaskar a ») avant leurs sous-chaînes (« surya namaskar »).
    private static let sanskritTerms: [String] = [
        "adho mukha svanasana", "adho mukha vrksasana", "anjaneyasana", "antar mauna",
        "antara kumbhaka", "ardha baddha padma paschimottanasana", "ardha baddha padmottanasana",
        "ardha chandrasana", "ardha matsyendrasana", "ardha uttanasana", "baddha konasana",
        "bakasana", "balasana", "bhastrika", "bhujangasana", "bhujapidasana",
        "chaturanga dandasana", "dandasana", "dhanurasana", "dharana", "dhyana", "dirgha",
        "eka pada sirsasana", "garudasana", "gomukhasana", "halasana", "janu sirsasana",
        "kapalabhati", "kapotasana", "karnapidasana", "kurmasana", "marichyasana",
        "marjaryasana-bitilasana", "matsyasana", "nadi shodhana", "navasana", "padahastasana",
        "padangusthasana", "parivrtta parsvakonasana", "parivrtta trikonasana", "parsvakonasana",
        "parsvottanasana", "paschimottanasana", "phalakasana", "pincha mayurasana",
        "prasarita padottanasana", "pratyahara", "purvottanasana", "pincha", "salabhasana",
        "salamba balasana", "salamba bhujangasana", "salamba sarvangasana", "sarvangasana",
        "savasana", "setu bandha sarvangasana", "setu bandhasana", "setu bandha", "sirsasana",
        "sukhasana", "supta baddha konasana", "supta kurmasana", "supta padangusthasana",
        "surya namaskar a", "surya namaskar b", "surya namaskar", "tadasana",
        "triang mukha eka pada paschimottanasana", "trikonasana", "ubhaya padangusthasana",
        "ujjayi", "upavistha konasana", "urdhva dhanurasana", "ustrasana", "utkatasana",
        "uttana padasana", "uttanasana", "utthita hasta padangusthasana", "utthita hasta",
        "utthita parsvakonasana", "utthita trikonasana", "viparita karani", "virabhadrasana i",
        "virabhadrasana ii", "virabhadrasana iii", "vrksasana",
    ].sorted { $0.count > $1.count }

    /// Un terme est conforme si le caractère non-blanc juste après est une ouverture
    /// `(`/`[` (glose FR à suivre) ou une fermeture `)`/`]` (le terme EST la glose
    /// sanskrit d'un nom FR qui le précède, ex. « Posture du triangle (trikonasana) »).
    private func offenders(in text: String) -> [String] {
        var covered = Array(repeating: false, count: text.utf16.count)
        var offenders: [String] = []
        let nsText = text as NSString

        for term in Self.sanskritTerms {
            guard let pattern = try? NSRegularExpression(
                pattern: "\\b" + NSRegularExpression.escapedPattern(for: term) + "\\b",
                options: [.caseInsensitive]
            ) else { continue }

            let matches = pattern.matches(in: text, range: NSRange(location: 0, length: nsText.length))
            for match in matches {
                let range = match.range
                if (range.location..<range.location + range.length).contains(where: { $0 < covered.count && covered[$0] }) {
                    continue
                }
                for i in range.location..<(range.location + range.length) where i < covered.count {
                    covered[i] = true
                }

                let afterStart = range.location + range.length
                let afterLength = min(3, nsText.length - afterStart)
                let after = afterLength > 0 ? nsText.substring(with: NSRange(location: afterStart, length: afterLength)) : ""
                let trimmedAfter = after.trimmingCharacters(in: .whitespaces)
                // Cas A : le terme sanskrit introduit sa propre glose FR juste après, ex.
                // « Trikonasana (posture du triangle) ».
                var compliant = trimmedAfter.hasPrefix("(") || trimmedAfter.hasPrefix("[")

                if !compliant {
                    // Cas B : le terme sanskrit EST la glose d'un nom FR qui le précède, ex.
                    // « Posture du triangle (trikonasana) » ou « Rétention pleine (antara
                    // kumbhaka, S8+) » — on doit rester dans la MÊME parenthèse/crochet
                    // (pas de nouvelle ouverture avant la fermeture qui suit).
                    let windowEnd = min(afterStart + 60, nsText.length)
                    if windowEnd > afterStart {
                        let forward = nsText.substring(with: NSRange(location: afterStart, length: windowEnd - afterStart))
                        let nextClose = forward.firstIndex(where: { $0 == ")" || $0 == "]" })
                        let nextOpen = forward.firstIndex(where: { $0 == "(" || $0 == "[" })
                        if let nextClose, (nextOpen == nil || forward.distance(from: forward.startIndex, to: nextClose) < forward.distance(from: forward.startIndex, to: nextOpen!)) {
                            let windowStart = max(range.location - 60, 0)
                            let backward = nsText.substring(with: NSRange(location: windowStart, length: range.location - windowStart))
                            let lastOpen = backward.lastIndex(where: { $0 == "(" || $0 == "[" })
                            let lastClose = backward.lastIndex(where: { $0 == ")" || $0 == "]" })
                            if let lastOpen, (lastClose == nil || backward.distance(from: backward.startIndex, to: lastOpen) > backward.distance(from: backward.startIndex, to: lastClose!)) {
                                compliant = true
                            }
                        }
                    }
                }

                if !compliant {
                    offenders.append(nsText.substring(with: range))
                }
            }
        }
        return offenders
    }

    func testAllSanskritTermsGlossedInWeekGoalAndTheme() async throws {
        let templates = try await TemplateLoader.loadAll()
        guard templates.count >= 30 else { throw XCTSkip("bundle non peuplé (\(templates.count))") }
        let yoga = templates.filter { $0.sport == .yoga }
        XCTAssertFalse(yoga.isEmpty, "aucun template yoga chargé")

        var failures: [String] = []
        for t in yoga {
            for w in t.weeks {
                let goalOffenders = offenders(in: w.goal.fr)
                if !goalOffenders.isEmpty {
                    failures.append("[\(t.id)] W\(w.weekNumber).goal: \(goalOffenders) — « \(w.goal.fr.prefix(100))… »")
                }
                let themeOffenders = offenders(in: w.theme.fr)
                if !themeOffenders.isEmpty {
                    failures.append("[\(t.id)] W\(w.weekNumber).theme: \(themeOffenders) — « \(w.theme.fr.prefix(100))… »")
                }
            }
        }
        XCTAssertTrue(failures.isEmpty,
            "Terme sanskrit non glosé dans \(failures.count) champ(s) week.goal/theme :\n"
                + failures.prefix(40).joined(separator: "\n"))
    }
}
