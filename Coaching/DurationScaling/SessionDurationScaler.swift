// Coaching/DurationScaling/SessionDurationScaler.swift
// Chantier durée réglable, pilote cycling (Increment 2) — moteur de scaling ISOLÉ,
// PAS dans la cascade `ProgramAdapter` (doctrine section 7) : appelé À LA DEMANDE sur
// une `PersistedSession` déjà persistée (jamais dans le pipeline d'adaptation initial).
//
// Implémente l'algorithme de
// `_bmad-output/planning-artifacts/doctrine-duree-cycling-2026-07-04.md` section 6,
// avec les tables plancher/plafond section 4 (VALIDÉES Sophie 2026-07-04). 100% pur,
// synchrone, 0 I/O.
import Foundation
import TemplateModel

public enum SessionDurationScaler {

    public struct Result: Equatable, Sendable {
        /// Séance recalculée — MÊME `id` (remplacement in-place, doctrine D-T2).
        public let session: PersistedSession
        /// Vrai si `targetMinutes` dépassait la fourchette plancher/plafond —
        /// `session.durationMinutes` reste alors le chiffre RÉEL appliqué (jamais la
        /// cible brute demandée), cf doctrine D7 « Léon borne honnête ».
        public let wasBounded: Bool
    }

    /// Vrai si `session` porte l'annotation budgétée complète (doctrine section 2) et peut
    /// donc être réglée par `scale(_:toTargetMinutes:level:)`. Sert de garde-fou côté UI
    /// (Increment 3, entrée « Ajuster la durée ») pour n'afficher l'action que sur les
    /// séances effectivement réglables — `rest` exclu, sports hors V1 exclus (annotation
    /// absente), contenu synthétique non annoté exclu (ex. overlay secondary goal).
    public static func isAdjustable(_ session: PersistedSession) -> Bool {
        guard session.type != .rest else { return false }
        let exercises = session.exercises
        // `estimatedMinutes` est la source de vérité (doctrine section 2) : un bloc annoté
        // role/scalingUnit mais SANS estimatedMinutes contribuerait silencieusement 0 aux
        // sommes floor/ceiling/currentTotal. Idem pour warmup/cooldown au niveau séance —
        // l'annotation script les pose toujours ensemble (`annotate_session_like`), donc une
        // séance partiellement annotée est un signal d'incohérence, pas un cas à deviner.
        guard !exercises.isEmpty, session.warmupMinutes != nil, session.cooldownMinutes != nil,
              exercises.allSatisfy({ $0.role != nil && $0.scalingUnit != nil && $0.estimatedMinutes != nil })
        else { return false }
        return exercises.contains { $0.role == .core }
    }

    /// Ajuste `session` vers `targetMinutes`. `level` pilote la table doctrine `endurance`
    /// (section 4.1) — vient du programme parent (`AdaptedProgramRecord.level`), pas de
    /// la séance elle-même (une `PersistedSession` seule ne porte pas le niveau).
    public static func scale(
        _ session: PersistedSession, toTargetMinutes targetMinutes: Int, level: Level
    ) -> Result {
        // Sport/séance pas (encore) annoté en blocs budgétés (hors V1 cycling), contenu
        // synthétique non annoté, ou `rest` (hors scope moteur, doctrine section 0) : pas
        // de fourchette calculable → séance inchangée (garde-fou robustesse).
        guard isAdjustable(session) else {
            return Result(session: session, wasBounded: targetMinutes != session.durationMinutes)
        }

        let exercises = session.exercises
        let coreIndices = exercises.indices.filter { exercises[$0].role == .core }
        let warmup = session.warmupMinutes ?? 0
        let cooldown = session.cooldownMinutes ?? 0
        let allAccessoryIndices = exercises.indices.filter { exercises[$0].role == .accessory }
        // `.fixed` reste intouchable MÊME en accessory (doctrine section 2) — exclu du pool
        // SACRIFIABLE (aucun cas identifié en cycling V1, mais le modèle le permet). Compte
        // quand même dans `accessoriesCurrentTotal` : sa valeur ne bouge jamais mais reste
        // présente dans la séance et donc dans le budget courant/plafond.
        let sacrificeableAccessoryIndices = allAccessoryIndices
            .filter { exercises[$0].scalingUnit != .fixed }
            .sorted { (exercises[$0].priority ?? Int.max) < (exercises[$1].priority ?? Int.max) }

        let coreBounds = coreIndices.map { blockBounds(exercises[$0], level: level) }
        let coreFloorTotal = coreBounds.reduce(0) { $0 + $1.floor }
        let coreCeilingAbsoluteTotal = coreBounds.reduce(0) { $0 + $1.ceiling }
        let coreCurrentTotal = coreIndices.reduce(0) { $0 + (exercises[$1].estimatedMinutes ?? 0) }
        let accessoriesCurrentTotal = allAccessoryIndices.reduce(0) { $0 + (exercises[$1].estimatedMinutes ?? 0) }
        // Contribution des accessoires `.fixed` : ne descendent JAMAIS à 0 (intouchables),
        // donc leur valeur courante fait partie du plancher réel — sinon `floor` sous-estime
        // le minimum réellement atteignable et le rognage laisse un déficit non absorbé.
        let fixedAccessoriesTotal = allAccessoryIndices
            .filter { exercises[$0].scalingUnit == .fixed }
            .reduce(0) { $0 + (exercises[$1].estimatedMinutes ?? 0) }

        // Plancher : accessoires sacrifiables supposés à 0 (doctrine section 5.2/5.3) ;
        // les `.fixed` restent comptés (jamais sacrifiés).
        let floor = warmup + cooldown + coreFloorTotal + fixedAccessoriesTotal
        // Plafond : garde-fou relatif 2× (doctrine section 4, validé Sophie 2026-07-04) —
        // dégénère sur `coreCeilingAbsoluteTotal` si le core courant est à 0 (ne devrait pas
        // arriver, cf `CyclingBudgetedBlocksTests`). Les accessoires ne s'étendent JAMAIS
        // (doctrine section 5.4) : ils comptent pour leur valeur COURANTE (déjà présente
        // dans `durationMinutes` actuel), jamais gonflés au-delà.
        let ceilingRelative = coreCurrentTotal > 0 ? 2 * coreCurrentTotal : coreCeilingAbsoluteTotal
        let ceiling = warmup + cooldown + min(coreCeilingAbsoluteTotal, ceilingRelative) + accessoriesCurrentTotal
        let safeCeiling = max(ceiling, floor)

        let clamped = min(max(targetMinutes, floor), safeCeiling)
        let wasBounded = clamped != targetMinutes

        let currentTotal = warmup + cooldown + coreCurrentTotal + accessoriesCurrentTotal
        var minutesByIndex = Dictionary(
            uniqueKeysWithValues: exercises.indices.map { ($0, exercises[$0].estimatedMinutes ?? 0) }
        )
        var removedIndices = Set<Int>()

        if clamped < currentTotal {
            var deficit = currentTotal - clamped
            // 1) sacrifier les blocs accessory (hors `.fixed`) par priority croissante,
            //    jusqu'à 0 (D5).
            for idx in sacrificeableAccessoryIndices {
                guard deficit > 0 else { break }
                let current = minutesByIndex[idx] ?? 0
                guard current > 0 else { continue }
                let cut = min(current, deficit)
                let remaining = current - cut
                minutesByIndex[idx] = remaining
                if remaining == 0 { removedIndices.insert(idx) }
                deficit -= cut
            }
            // 2) si insuffisant, réduire le(s) bloc(s) core vers leur floor (jamais en dessous).
            // Ordre séquentiel sur `coreIndices` : approximation raisonnable en V1 (aucun cas
            // multi-core identifié dans le corpus prod, cf `CyclingBudgetedBlocksTests` —
            // répartition proportionnelle de la doctrine section 5.5 non implémentée tant
            // qu'aucun cas réel ne l'exige).
            if deficit > 0 {
                for (idx, bounds) in zip(coreIndices, coreBounds) {
                    guard deficit > 0 else { break }
                    let current = minutesByIndex[idx] ?? 0
                    let capacity = max(current - bounds.floor, 0)
                    let cut = min(capacity, deficit)
                    minutesByIndex[idx] = current - cut
                    deficit -= cut
                }
            }
        } else if clamped > currentTotal {
            var surplus = clamped - currentTotal
            // Extension : uniquement le(s) bloc(s) core, vers leur ceiling absolu — les
            // accessoires ne remontent JAMAIS au-dessus de leur dose originale (section 5.4).
            for (idx, bounds) in zip(coreIndices, coreBounds) {
                guard surplus > 0 else { break }
                let current = minutesByIndex[idx] ?? 0
                let capacity = max(bounds.ceiling - current, 0)
                let add = min(capacity, surplus)
                minutesByIndex[idx] = current + add
                surplus -= add
            }
        }

        var newExercises: [AdaptedExercise] = []
        for idx in exercises.indices {
            guard !removedIndices.contains(idx) else { continue }
            let original = exercises[idx]
            let newMinutes = minutesByIndex[idx] ?? (original.estimatedMinutes ?? 0)
            let rescaledExercise = newMinutes == (original.estimatedMinutes ?? 0)
                ? original : rescaled(original, toMinutes: newMinutes)
            // Garde-fou : un accessory `roundsReps` coupé à une valeur non nulle mais trop
            // petite peut arrondir à 0 rep (`rescaled` → `estimatedMinutes == 0`) sans être
            // passé par `removedIndices` (qui ne voit que les coupes en minutes brutes) — on
            // le retire ici pour ne jamais afficher un exercice à 0 rep/0 min.
            if original.role == .accessory, (rescaledExercise.estimatedMinutes ?? 0) <= 0 { continue }
            newExercises.append(rescaledExercise)
        }

        // Chiffre RÉEL affiché = recalculé depuis les blocs effectivement appliqués (jamais
        // `clamped` directement) — absorbe l'éventuel écart d'arrondi entier des blocs.
        let newDuration = warmup + cooldown + newExercises.reduce(0) { $0 + ($1.estimatedMinutes ?? 0) }

        let newSession = PersistedSession(
            id: session.id,
            weekNumber: session.weekNumber,
            weekTheme: session.weekTheme,
            weekGoal: session.weekGoal,
            day: session.day,
            name: session.name,
            durationMinutes: newDuration,
            type: session.type,
            warmup: session.warmup,
            exercises: newExercises,
            cooldown: session.cooldown,
            warmupMinutes: session.warmupMinutes,
            cooldownMinutes: session.cooldownMinutes
        )
        return Result(session: newSession, wasBounded: wasBounded)
    }

    // MARK: - Rescale d'un bloc vers `minutes` nouvelles minutes, selon son `scalingUnit`.

    private static func rescaled(_ exercise: AdaptedExercise, toMinutes minutes: Int) -> AdaptedExercise {
        switch exercise.scalingUnit {
        case .continuous, .none:
            return exercise.scaledToMinutes(max(minutes, 0))
        case .roundsReps:
            let originalMinutes = max(exercise.estimatedMinutes ?? 0, 1)
            let originalSets = max(exercise.sets ?? 1, 1)
            let perRep = Double(originalMinutes) / Double(originalSets)
            guard perRep > 0, minutes != originalMinutes else {
                return exercise.scaledToSets(originalSets)
            }
            var newSets = Int((Double(minutes) / perRep).rounded(.toNearestOrEven))
            // Garde-fou arrondi : une cible à ~une demi-rep de l'original arrondit sur
            // `originalSets` (round-to-nearest) — l'ajustement demandé serait silencieusement
            // ignoré. On force le mouvement d'au moins 1 rep dans le sens demandé — SEULEMENT
            // si `originalSets >= 2` : à 1 seul rep (toujours `.continuous` en pratique, cf
            // `annotate_cycling_blocks.py` — un `.roundsReps` à `sets == 1` violerait cette
            // invariante), forcer +1 rep peut faire déborder très au-delà de la cible (le
            // "prix" d'un rep entier == la durée totale du bloc) — mieux vaut ne pas bouger
            // que d'exploser le budget d'un coup.
            if newSets == originalSets, originalSets >= 2 {
                newSets = minutes < originalMinutes ? originalSets - 1 : originalSets + 1
            }
            return exercise.scaledToSets(max(newSets, 0))
        case .fixed:
            return exercise
        }
    }

    // MARK: - Tables doctrine (section 4)

    /// Plancher/plafond ABSOLU (avant garde-fou 2× relatif appliqué au niveau séance) d'un
    /// bloc, en minutes.
    private static func blockBounds(_ exercise: AdaptedExercise, level: Level) -> (floor: Int, ceiling: Int) {
        let original = exercise.estimatedMinutes ?? 0
        switch exercise.scalingUnit {
        case .continuous, .none:
            return (enduranceFloorMinutes, enduranceCeilingMinutes(for: level))
        case .roundsReps:
            return roundsRepsBoundsMinutes(
                zone: exercise.targetZone, originalSets: exercise.sets ?? 1, originalMinutes: original
            )
        case .fixed:
            // Intouchable même en accessory (doctrine section 2) — aucun cas cycling V1.
            return (original, original)
        }
    }

    /// 4.1 — `endurance` (`scalingUnit == .continuous`) : floor universel (en dessous, le
    /// stimulus aérobie devient négligeable quel que soit le niveau), ceiling par niveau
    /// (long ride max doctrine, cf table doctrine).
    private static let enduranceFloorMinutes = 20
    private static let enduranceCeilingByLevel: [Level: Int] = [
        .beginner: 90, .recreational: 180, .regular: 240, .competitive: 360
    ]
    private static func enduranceCeilingMinutes(for level: Level) -> Int {
        enduranceCeilingByLevel[level] ?? enduranceCeilingByLevel[.regular]!
    }

    /// 4.2 — `interval` (`scalingUnit == .roundsReps`) : plancher/plafond en REPS selon la
    /// zone, converti en minutes via le "prix" par rep (`estimatedMinutes original / sets
    /// original`) pour rester dans l'espace minutes uniforme de l'algorithme (section 6).
    /// FTP-Z3/Sweet-Spot : pas de cap reps — cap direct 90 min (doctrine FasCat « bloc
    /// 30-90 min »). Zone absente/texte libre : fallback générique -1/+2 reps (décision
    /// validée Sophie 2026-07-04, section 9.4). Garde-fous : floor jamais > minutes
    /// courantes, ceiling jamais < minutes courantes (robustesse si l'annotation dévie
    /// des cas typiques doctrine).
    private static func roundsRepsBoundsMinutes(
        zone: String?, originalSets: Int, originalMinutes: Int
    ) -> (floor: Int, ceiling: Int) {
        let sets = max(originalSets, 1)
        let perRep = Double(originalMinutes) / Double(sets)
        let z = (zone ?? "").uppercased()

        let floorReps: Int
        let ceilingMinutes: Int
        if z.contains("Z3") || z.contains("SWEET-SPOT") || z.contains("SWEET SPOT") {
            floorReps = 1
            ceilingMinutes = 90
        } else if z.contains("Z4") || z.contains("THRESHOLD") {
            floorReps = 2
            ceilingMinutes = Int((perRep * 4).rounded(.toNearestOrEven))
        } else if z.contains("Z5") || z.contains("VO2") {
            floorReps = 3
            ceilingMinutes = Int((perRep * 6).rounded(.toNearestOrEven))
        } else if z.contains("Z6") || z.contains("ANAEROBIC") {
            floorReps = 3
            ceilingMinutes = Int((perRep * 8).rounded(.toNearestOrEven))
        } else {
            floorReps = max(sets - 1, 2)
            ceilingMinutes = Int((perRep * Double(sets + 2)).rounded(.toNearestOrEven))
        }
        let floorMinutes = Int((perRep * Double(floorReps)).rounded(.toNearestOrEven))
        return (min(floorMinutes, originalMinutes), max(ceilingMinutes, originalMinutes))
    }
}
