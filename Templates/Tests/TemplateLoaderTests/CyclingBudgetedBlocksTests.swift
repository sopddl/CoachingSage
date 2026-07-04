import XCTest
@testable import TemplateLoader
import TemplateModel

/// Filet de régression — chantier durée réglable, pilote cycling, Increment 1
/// (doctrine `_bmad-output/planning-artifacts/doctrine-duree-cycling-2026-07-04.md`,
/// VALIDÉE Sophie 2026-07-04).
///
/// Garantit que l'annotation en « blocs budgétés » (`role`/`scalingUnit`/`priority`/
/// `estimatedMinutes` par exercice, `warmupMinutes`/`cooldownMinutes` par séance)
/// reste cohérente sur les 4 templates cycling prod — c'est la donnée que consommera
/// le moteur de scaling (Increment 2, pas encore construit). `rest` exclu du scope
/// moteur (placeholder jour off, jamais réglable, cf doctrine section 0).
///
/// Régénéré par `Templates/scripts/duree_seance/annotate_cycling_blocks.py` — toute
/// édition future d'un template cycling qui casse la fermeture du budget ou oublie
/// une annotation doit être rattrapée ici, pas au device-test.
final class CyclingBudgetedBlocksTests: XCTestCase {

    private struct Node {
        let label: String
        let durationMinutes: Int
        let warmupMinutes: Int?
        let cooldownMinutes: Int?
        let exercises: [TemplateExercise]
    }

    func testCyclingSessionsAreFullyBudgeted() async throws {
        let templates = try await TemplateLoader.loadAll()
        let cycling = templates.filter { $0.sport == .cycling }
        guard !cycling.isEmpty else { throw XCTSkip("bundle non peuplé (aucun template cycling)") }

        var failures: [String] = []

        for t in cycling {
            for w in t.weeks {
                for s in w.sessions where s.type != .rest {
                    let label = "[\(t.id)] W\(w.weekNumber)D\(s.day) « \(s.name.canonical.prefix(40)) »"
                    var nodes = [Node(
                        label: label, durationMinutes: s.durationMinutes,
                        warmupMinutes: s.warmupMinutes, cooldownMinutes: s.cooldownMinutes,
                        exercises: s.exercises
                    )]
                    for v in (s.environment != nil ? s.environmentVariants : []) {
                        nodes.append(Node(
                            label: label + " [\(v.environment.rawValue)]",
                            durationMinutes: v.durationMinutes,
                            warmupMinutes: v.warmupMinutes, cooldownMinutes: v.cooldownMinutes,
                            exercises: v.exercises
                        ))
                    }

                    for node in nodes {
                        checkBudgetCloses(node, into: &failures)
                        checkRoleAndScalingUnit(node, into: &failures)
                    }
                }
            }
        }

        XCTAssertTrue(
            failures.isEmpty,
            """
            \(failures.count) anomalie(s) sur les blocs budgétés cycling — régénérer via \
            Templates/scripts/duree_seance/annotate_cycling_blocks.py :
            \(failures.prefix(30).joined(separator: "\n"))
            """
        )
    }

    /// Somme warmup + cooldown + Σ estimatedMinutes ≈ durationMinutes (tolérance ±10%,
    /// cf doctrine section 8 — le script ferme exactement mais on tolère la marge pour
    /// une annotation manuelle future moins précise).
    private func checkBudgetCloses(_ node: Node, into failures: inout [String]) {
        guard let warmup = node.warmupMinutes, let cooldown = node.cooldownMinutes else {
            failures.append("\(node.label) : warmupMinutes/cooldownMinutes absent")
            return
        }
        let exercisesSum = node.exercises.reduce(0) { $0 + ($1.estimatedMinutes ?? -1_000_000) }
        guard exercisesSum > -1_000_000 else {
            failures.append("\(node.label) : au moins un exercice sans estimatedMinutes")
            return
        }
        let total = warmup + cooldown + exercisesSum
        let tolerance = max(2, Int(Double(node.durationMinutes) * 0.10))
        if abs(total - node.durationMinutes) > tolerance {
            failures.append(
                "\(node.label) : budget \(total) min ≠ durationMinutes \(node.durationMinutes) "
                + "(warmup \(warmup) + cooldown \(cooldown) + exos \(exercisesSum), tolérance ±\(tolerance))"
            )
        }
    }

    /// Exactement un bloc `core` par nœud (aucun cas multi-core identifié dans le corpus
    /// prod actuel, cf doctrine section 5) ; `scalingUnit` cohérent avec `sets` ;
    /// `priority` renseigné ssi `role == .accessory`.
    private func checkRoleAndScalingUnit(_ node: Node, into failures: inout [String]) {
        let coreCount = node.exercises.filter { $0.role == .core }.count
        if coreCount != 1 {
            failures.append("\(node.label) : \(coreCount) bloc(s) core (attendu 1) — \(node.exercises.map { "\($0.stableMatchKey):\($0.role?.rawValue ?? "nil")" })")
        }
        for e in node.exercises {
            guard let role = e.role, let scalingUnit = e.scalingUnit else {
                failures.append("\(node.label) : « \(e.stableMatchKey) » sans role/scalingUnit")
                continue
            }
            let expectedUnit: ScalingUnit = (e.sets ?? 1) > 1 ? .roundsReps : .continuous
            if scalingUnit != expectedUnit {
                failures.append(
                    "\(node.label) : « \(e.stableMatchKey) » scalingUnit=\(scalingUnit.rawValue) "
                    + "incohérent avec sets=\(e.sets ?? 1) (attendu \(expectedUnit.rawValue))"
                )
            }
            switch (role, e.priority) {
            case (.core, .some(let p)):
                failures.append("\(node.label) : « \(e.stableMatchKey) » core avec priority=\(p) (attendu nil)")
            case (.accessory, .none):
                failures.append("\(node.label) : « \(e.stableMatchKey) » accessory sans priority")
            default:
                break
            }
        }
    }
}
