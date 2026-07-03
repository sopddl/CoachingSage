// Coaching/Adapter/Rules/DensityRule.swift
// Chantier densité B — vrai levier moteur multi-sport (spec 2026-07-02, revue doctrine
// template-quality-reviewer 07-02 intégrée). Règle 4 du pipeline (post-VolumeModulation,
// pré-LevelPacing) : quand le signal comportemental dit « s'entraîne déjà régulièrement »,
// le programme démarre RÉELLEMENT un cran au-dessus — volume ajouté sur du contenu déjà
// présent, durées affichées recalculées (le visuel qui ne ment pas).
//
// Leviers (jamais d'intensité, jamais de technique neuve, jamais de texte neuf) :
//   L1 « +1 set »        — transversal : exo éligible (whitelist de zones PAR SPORT,
//                          sets ≥ 2, dose estimable) → sets += 1. Bump d'un ENTIER.
//   L2 « extendHold »    — yoga : tenue active brève ×1.5, plafond 45 s (archive 42f996d).
//   L3 « repeatActive »  — yoga : +1 tour du bloc actif, repos intercalé (archive).
//   Yoga = L2+L3 EXCLUSIVEMENT (L1 OFF — sinon double densification vinyasa, revue 07-02).
//
// Garde-fous MDR (spec G1-G8) :
//   G1  requiresMedicalClearance → no-op total.
//   G2  échauffement/retour au calme jamais densifiés (structurel : champs texte de la
//       séance, pas des exos) + exclusion défensive des exos « warmup »/« étirement ».
//   G3  WHITELIST de zones par sport — zone inconnue/absente = inéligible par défaut.
//       Sprints/plio/intervalles/efforts max jamais touchés (cf passe retag inc1 +
//       filet NoPlioSprintInEasyZonesTests).
//   G4  « un cran » = cap +20 % de durée/séance (calculé POST-VolumeModulation, tous
//       leviers confondus), max +1 set par exo, N = 2 exos densifiés par séance.
//   G5  la boucle autoreg (RPE/complétion, RoutineCyclePlanning) reste la redescente.
//   G6  signal = comportement (workouts HK) ou déclaration explicite — jamais santé.
//   G8  semaines décharge/taper (`template.deloadWeeks`, inc1) jamais densifiées.
//
// Gating niveau : beginner + recreational UNIQUEMENT (sur regular/competitive le volume
// est déjà élevé et AutoProfileInference consomme déjà le même signal pour le niveau —
// éviter le double-comptage). Signal absent (nil/nil) → no-op strict : PAS de
// densification par défaut (fork #2 Sophie, ≠ cold-start D5 de la branche archive).
import Foundation
import TemplateModel

public struct DensityRule: AdaptationRule {
    public let ruleType: AppliedRule.RuleType = .density

    /// Bornes chiffrées (doctrine). Injectables pour les tests.
    public struct Bounds: Equatable, Sendable {
        /// Seuil « actif » du signal HK (séances/sem, fenêtre 4 sem). 1,5 = « fait déjà
        /// du sport » (calibré device-test 2026-06-22, branche archive).
        public var activeThreshold: Double
        /// N exos densifiés max par séance (G4 : N = 2, 3 = borne dure doctrine).
        public var maxExercisesPerSession: Int
        /// Cap de volume ajouté par séance : fraction de la durée affichée (G4 : +20 %).
        public var maxAddedDurationFraction: Double
        /// Estimation nominale d'un set reps-only (muscu : ~40 s d'effort, spec § durée).
        public var nominalSetSeconds: Int
        /// Yoga L2 : facteur d'allongement de tenue (30 s → 45 s) et plafond actif.
        public var holdMultiplier: Double
        public var maxActiveHoldSeconds: Int

        public init(
            activeThreshold: Double = 1.5,
            maxExercisesPerSession: Int = 2,
            maxAddedDurationFraction: Double = 0.20,
            nominalSetSeconds: Int = 40,
            holdMultiplier: Double = 1.5,
            maxActiveHoldSeconds: Int = 45
        ) {
            self.activeThreshold = activeThreshold
            self.maxExercisesPerSession = maxExercisesPerSession
            self.maxAddedDurationFraction = maxAddedDurationFraction
            self.nominalSetSeconds = nominalSetSeconds
            self.holdMultiplier = holdMultiplier
            self.maxActiveHoldSeconds = maxActiveHoldSeconds
        }
    }

    public let bounds: Bounds

    public init(bounds: Bounds = Bounds()) {
        self.bounds = bounds
    }

    /// Niveaux éligibles densité (gating anti double-comptage avec l'autoprofil niveau).
    /// SOURCE UNIQUE (review 07-03) — consommée par la règle, par le hot path
    /// (`presentAdaptedProgram` skippe le fetch HK hors gating) et par la question de
    /// calibrage (`UniversalQuestionnaire` ne la pose pas hors gating).
    public static let gatedLevels: Set<Level> = [.beginner, .recreational]

    // MARK: - Whitelists G3 (revue doctrine 07-02 — gisement = renfo/gainage de support)

    /// Zones RPE faciles/modérées — éligibles UNIQUEMENT dans le contexte de séance
    /// listé par sport (le plus souvent : renfo de support, type `strength`).
    private static let easyRPE: Set<String> = ["RPE 4-5", "RPE 5-6", "RPE 6-7"]

    /// Zones éligibles quel que soit le type de séance, par sport.
    private static let anySessionZones: [Sport: Set<String>] = [
        .running: ["Daniels-E"],
        .cycling: ["FTP-Z1", "FTP-Z2"],
        .swimming: ["technique", "EN1", "REC"],
        .tennis: ["technique", "Z2", "tactique"],
        .football: ["technique", "Z2", "tactique"],
        .triathlon: ["Daniels-E", "FTP-Z1", "FTP-Z2", "technique", "EN1", "REC"],
        .strengthTraining: [],
        .hiking: [],
        .hiit: [],
        .yoga: [],  // L1 OFF — L2/L3 exclusivement.
    ]

    /// Types de séance où les zones `easyRPE` sont éligibles, par sport.
    /// hiit : SEULEMENT strength/mobility — tout `interval` intouchable (revue 07-02).
    private static let easyRPESessionTypes: [Sport: Set<SessionType>] = [
        .running: [.strength],
        .cycling: [.strength],
        .hiking: [.strength],
        .tennis: [.strength],
        .football: [.strength],
        .triathlon: [.strength],
        .strengthTraining: [.strength, .mixed, .mobility, .technique, .endurance, .other],
        .hiit: [.strength, .mobility],
        .yoga: [],
    ]

    /// Exclusions par nom (défensif, en plus des whitelists) :
    /// - « FIFA 11+ — … » : protocole figé, jamais densifié (exception name-matching
    ///   documentée, préfixe stable dans les 3 langues — politique nommage 06-17) ;
    /// - étirements : +1 série d'étirement ≠ « un cran au-dessus » (revue 07-02, vélo) ;
    /// - échauffements nommés dans les exos (G2 défensif).
    private static let nameExclusions = ["fifa 11+", "étirement", "stretch", "estiramiento",
                                         "warmup", "warm-up", "échauffement"]

    // MARK: - AdaptationRule

    public func apply(
        weeks: [AdaptedWeek],
        template: ProgramTemplate,
        sport: Sport,
        level: Level,
        sportProfile: AdapterSportProfile,
        coachingProfile: AdapterCoachingProfile
    ) -> RuleResult {
        // G1 — clearance médicale : no-op total.
        guard !coachingProfile.requiresMedicalClearance else {
            return RuleResult(weeks: weeks, appliedRules: [])
        }
        // Gating niveau : beginner + recreational uniquement.
        guard Self.gatedLevels.contains(level) else {
            return RuleResult(weeks: weeks, appliedRules: [])
        }
        // Signal (G6) : HK récent OU déclaration explicite. Absent → no-op strict.
        guard signalDensifies(coachingProfile) else {
            return RuleResult(weeks: weeks, appliedRules: [])
        }

        let deloadWeeks = Set(template.deloadWeeks ?? [])
        var applied: [AppliedRule] = []
        var newWeeks: [AdaptedWeek] = []

        for week in weeks {
            // G8 — semaines décharge/taper intouchées.
            guard !deloadWeeks.contains(week.weekNumber) else {
                newWeeks.append(week)
                continue
            }
            var sessions: [AdaptedSession] = []
            for session in week.sessions {
                guard session.type != .rest else {
                    sessions.append(session)
                    continue
                }
                let (densified, rules) = sport == .yoga
                    ? densifyYoga(session: session, weekNumber: week.weekNumber)
                    : densifyPlusOneSet(session: session, sport: sport, weekNumber: week.weekNumber)
                sessions.append(densified)
                applied.append(contentsOf: rules)
            }
            newWeeks.append(AdaptedWeek(
                weekNumber: week.weekNumber, theme: week.theme, goal: week.goal, sessions: sessions
            ))
        }
        return RuleResult(weeks: newWeeks, appliedRules: applied)
    }

    /// Signal comportemental : activité workouts HK 4 sem ≥ seuil ; la réponse « oui » à la
    /// question de calibrage ne sert QUE quand HK est muet (review 07-03 : le HK frais fait
    /// autorité — une déclaration passée, persistée dans l'historique questionnaire, ne doit
    /// pas surclasser une mesure réelle « inactif » si l'user a activé HK entre-temps).
    private func signalDensifies(_ profile: AdapterCoachingProfile) -> Bool {
        if let avg = profile.weeklyWorkoutsAverage4w { return avg >= bounds.activeThreshold }
        return profile.declaredRegularActivity == true
    }

    // MARK: - L1 « +1 set » (tous sports sauf yoga)

    private func densifyPlusOneSet(
        session: AdaptedSession,
        sport: Sport,
        weekNumber: Int
    ) -> (AdaptedSession, [AppliedRule]) {
        // Cap G4 en secondes, calculé sur la durée POST-VolumeModulation (règle 3 avant nous).
        let budget = Int(Double(session.durationMinutes * 60) * bounds.maxAddedDurationFraction)
        var addedSeconds = 0
        var densifiedCount = 0
        var rules: [AppliedRule] = []

        let exercises = session.exercises.map { exo -> AdaptedExercise in
            guard densifiedCount < bounds.maxExercisesPerSession,
                  let sets = exo.sets,
                  isEligibleL1(exo, sport: sport, sessionType: session.type),
                  let setSeconds = addedSecondsPerSet(exo),
                  addedSeconds + setSeconds <= budget
            else { return exo }

            addedSeconds += setSeconds
            densifiedCount += 1
            rules.append(AppliedRule(
                ruleType: ruleType, weekNumber: weekNumber, day: session.day,
                originalExerciseName: exo.originalName, outcome: .densified,
                detail: "+1 série (\(sets) → \(sets + 1)) — démarrage un cran au-dessus (activité régulière)"
            ))
            return exo.addingOneSet()
        }

        guard addedSeconds > 0 else { return (session, []) }
        // Durée affichée recalculée : base autorée + secondes réellement ajoutées (le
        // `durationMinutes` autoré inclut transitions/installation → on ne re-somme pas).
        let newDuration = session.durationMinutes + Int((Double(addedSeconds) / 60.0).rounded())
        return (AdaptedSession(
            day: session.day, name: session.name, durationMinutes: newDuration,
            type: session.type, warmup: session.warmup, exercises: exercises, cooldown: session.cooldown
        ), rules)
    }

    /// Éligibilité L1 (G3) : zone dans la whitelist du sport (défaut = inéligible),
    /// sets ≥ 2, pas d'exclusion par nom. Checks O(1) (sets/zone) AVANT la construction
    /// de la chaîne de matching nom (review 07-03, perf hot path).
    private func isEligibleL1(_ exo: AdaptedExercise, sport: Sport, sessionType: SessionType) -> Bool {
        guard let sets = exo.sets, sets >= 2 else { return false }
        guard let zone = exo.targetZone else { return false }

        let zoneEligible: Bool
        if Self.anySessionZones[sport, default: []].contains(zone) {
            // Natation : le gisement RPE est « à sec » uniquement — mais technique/EN1/REC
            // (dans l'eau) sont éligibles sans condition (éducatifs +1×25 m = progression
            // classique, revue 07-02).
            zoneEligible = true
        } else if Self.easyRPE.contains(zone) {
            zoneEligible = sport == .swimming
                ? exo.dryLand == true
                : Self.easyRPESessionTypes[sport, default: []].contains(sessionType)
        } else {
            zoneEligible = false
        }
        guard zoneEligible else { return false }

        let hay = "\(exo.originalName) \(exo.name.canonical)".lowercased()
        return !Self.nameExclusions.contains(where: { hay.contains($0) })
    }

    /// Secondes ajoutées par le set supplémentaire, ancrées sur le `dose` STRUCTURÉ quand il
    /// existe (source fiable : le texte `duration` peut porter des unités non temporelles —
    /// « 50 m » natation, « 5 respirations » — que `SessionDurationParser` lirait comme des
    /// secondes, review 07-03) :
    ///   - dose seconds/minutes → temps réel × multiplicateur bilatéral (perSide/perLeg…)
    ///   - dose meters/reps → estimation nominale (~40 s, granularité minute = honnête)
    ///   - autre unité ou qualificateur non temporisable → nil = inéligible (conservateur)
    /// Sans dose structuré : repli texte STRICT (unité temporelle explicite exigée),
    /// puis reps-only → nominale. nil = dose non estimable → exo inéligible.
    private func addedSecondsPerSet(_ exo: AdaptedExercise) -> Int? {
        let rest = exo.restSeconds ?? 0
        if case .structured(let d) = exo.dose {
            switch d.unit {
            case .seconds, .minutes:
                guard let value = Int(d.value),
                      let multiplier = Self.bilateralMultiplier(d.qualifier) else { return nil }
                let seconds = d.unit == .minutes ? value * 60 : value
                return seconds * multiplier + rest
            case .meters, .reps:
                return bounds.nominalSetSeconds + rest
            default:
                return nil
            }
        }
        if exo.dose != nil { return nil }  // interval/freeText : pas de comptage honnête
        if let seconds = Self.strictTimeSeconds(exo.duration) {
            return seconds + rest
        }
        if exo.reps != nil {
            return bounds.nominalSetSeconds + rest
        }
        return nil
    }

    /// Multiplicateur temporel d'un qualificateur de dose : nil (aucun) = ×1, bilatéral
    /// (par côté/jambe/bras/pied/épaule) = ×2, tout autre qualificateur (par posture,
    /// par série…) = non temporisable → nil (l'exo est écarté plutôt que sous-compté).
    private static func bilateralMultiplier(_ q: DoseQualifier?) -> Int? {
        switch q {
        case nil: return 1
        case .perSide, .perLeg, .perArm, .perFoot, .perShoulder: return 2
        default: return nil
        }
    }

    /// Lecture STRICTE d'une durée texte en secondes : chaque segment (« + ») doit être
    /// soit un nombre nu (= secondes), soit un nombre suivi d'une unité TEMPORELLE
    /// explicite (min/mn/sec/s/seconde(s)/minute(s)) — un éventuel libellé peut suivre
    /// (« 1 min course lente »). Rejette « 50 m », « 5 respirations », « 1 cycle complet »
    /// que le parser permissif lirait comme des secondes.
    static func strictTimeSeconds(_ text: String?) -> Int? {
        guard let text else { return nil }
        let segments = text.split(separator: "+")
        guard !segments.isEmpty else { return nil }
        var total = 0
        for segment in segments {
            let s = String(segment)
            guard Self.strictTimePattern.firstMatch(
                in: s, range: NSRange(s.startIndex..., in: s)
            ) != nil, let seconds = SessionDurationParser.seconds(s) else { return nil }
            total += seconds
        }
        return total
    }

    /// nombre nu seul, OU nombre + unité temporelle (+ éventuel « 30 » des « 1 min 30 »
    /// et/ou libellé). Insensible à la casse.
    private static let strictTimePattern = try! NSRegularExpression(
        pattern: #"^\s*\d+\s*$|^\s*\d+\s*(min|mn|minutes?|sec|s|secondes?)(\s|$)"#,
        options: [.caseInsensitive]
    )

    // MARK: - Yoga L2 + L3 (port branche archive 42f996d, doctrine 2026-06-21)

    private func densifyYoga(
        session: AdaptedSession,
        weekNumber: Int
    ) -> (AdaptedSession, [AppliedRule]) {
        let budget = Int(Double(session.durationMinutes * 60) * bounds.maxAddedDurationFraction)
        var addedSeconds = 0
        var densifiedCount = 0
        var rules: [AppliedRule] = []

        // Rôles classifiés UNE fois (L2 préserve ordre et cardinal → réutilisable par L3).
        let roles = session.exercises.map {
            YogaPoseRole.classify(originalName: $0.originalName, displayName: $0.name.canonical)
        }

        // L2. extendHold — postures actives à tenue brève. Gate = dose STRUCTURÉ en
        // SECONDES (review 07-03) : c'est la seule unité que `bumpingHold` sait resynchroniser
        // duration + dose, et le seul comptage temps honnête (« 5 respirations »/« 1 cycle
        // complet » seraient lus 5 s/1 s par le parser texte → bump absurde + budget faussé).
        // Tenue « par côté » : coût réel = ×2 (les deux côtés s'allongent). Cap G4 N=2 exos
        // par séance, tous leviers confondus avec L1 par construction (yoga = L2/L3 only).
        var exos: [AdaptedExercise] = session.exercises.enumerated().map { index, exo in
            guard densifiedCount < bounds.maxExercisesPerSession,
                  roles[index] == .active,
                  let (base, multiplier) = Self.holdBaseSeconds(exo),
                  base < bounds.maxActiveHoldSeconds
            else { return exo }
            let bumped = min(Int((Double(base) * bounds.holdMultiplier).rounded()), bounds.maxActiveHoldSeconds)
            let charge = (bumped - base) * multiplier
            guard bumped > base, addedSeconds + charge <= budget else { return exo }
            addedSeconds += charge
            densifiedCount += 1
            rules.append(AppliedRule(
                ruleType: ruleType, weekNumber: weekNumber, day: session.day,
                originalExerciseName: exo.originalName, outcome: .densified,
                detail: "Tenue allongée \(base)s → \(bumped)s (densité, plafond \(bounds.maxActiveHoldSeconds)s)"
            ))
            return exo.bumpingHold(toSeconds: bumped)
        }

        // L3. repeatActiveBlock — +1 tour du bloc actif, contenu existant, repos intercalé.
        // `copy` est pris APRÈS extendHold → ses tenues reflètent déjà les valeurs allongées.
        // Cap G4 : le tour n'est ajouté que s'il tient dans le budget restant. Le coût du
        // bloc est compté HONNÊTEMENT via le dose structuré (`honestSeconds`) ; un bloc
        // contenant une posture non temporisable (respirations, cycles…) est REFUSÉ en
        // entier — on ne duplique pas ce qu'on ne sait pas compter (review 07-03).
        if let block = activeBlock(roles: roles, count: exos.count) {
            let copy = Array(exos[block])
            let secondsPerExo = copy.map(Self.honestSeconds)
            if !secondsPerExo.contains(nil) {
                let blockSeconds = secondsPerExo.compactMap { $0 }.reduce(0, +)
                if blockSeconds > 0, addedSeconds + blockSeconds <= budget {
                    addedSeconds += blockSeconds
                    exos.insert(contentsOf: copy, at: block.upperBound)
                    rules.append(AppliedRule(
                        ruleType: ruleType, weekNumber: weekNumber, day: session.day,
                        originalExerciseName: session.name.canonical, outcome: .densified,
                        detail: "+1 tour du bloc actif (\(copy.count) postures réutilisées, contenu existant)"
                    ))
                }
            }
        }

        guard addedSeconds > 0 else { return (session, []) }
        let newDuration = session.durationMinutes + Int((Double(addedSeconds) / 60.0).rounded())
        return (AdaptedSession(
            day: session.day, name: session.name, durationMinutes: newDuration,
            type: session.type, warmup: session.warmup, exercises: exos, cooldown: session.cooldown
        ), rules)
    }

    /// Base de tenue L2 (secondes) + multiplicateur de coût : dose structuré en SECONDES
    /// (seule unité que `bumpingHold` resynchronise duration + dose), ou repli texte strict
    /// quand l'exo n'a AUCUN dose (fixtures/contenu futur) — refusé si le texte porte un
    /// marqueur bilatéral qu'on ne saurait pas compter (« par côté »…). nil = inéligible.
    private static func holdBaseSeconds(_ exo: AdaptedExercise) -> (base: Int, multiplier: Int)? {
        if case .structured(let d) = exo.dose {
            guard d.unit == .seconds, let value = Int(d.value),
                  let multiplier = bilateralMultiplier(d.qualifier) else { return nil }
            return (value, multiplier)
        }
        guard exo.dose == nil, let seconds = strictTimeSeconds(exo.duration) else { return nil }
        let lower = (exo.duration ?? "").lowercased()
        guard !lower.contains("côté"), !lower.contains("side"), !lower.contains("lado") else { return nil }
        return (seconds, 1)
    }

    /// Contribution temporelle HONNÊTE (secondes) d'un exo yoga : dose structuré
    /// seconds/minutes × multiplicateur bilatéral + repos ; sans dose structuré, repli
    /// texte STRICT (`strictTimeSeconds`). nil = non temporisable (respirations, cycles,
    /// qualificateur inconnu) → l'appelant refuse le bloc.
    private static func honestSeconds(_ e: AdaptedExercise) -> Int? {
        let rest = e.restSeconds ?? 0
        if case .structured(let d) = e.dose {
            guard d.unit == .seconds || d.unit == .minutes,
                  let value = Int(d.value),
                  let multiplier = bilateralMultiplier(d.qualifier) else { return nil }
            let seconds = d.unit == .minutes ? value * 60 : value
            return seconds * multiplier + rest
        }
        if e.dose != nil { return nil }  // interval/freeText
        guard let seconds = strictTimeSeconds(e.duration) else { return nil }
        return seconds + rest
    }

    /// Bloc actif RÉPÉTABLE = exercices entre l'ouverture (run de tête `openingBreath`) et
    /// la clôture (`finalRelaxation` au dernier rang). Retourné UNIQUEMENT si la séance est
    /// BIEN FORMÉE : dernier exo = relaxation finale ET le bloc se termine par un repos
    /// (le repos intercalé entre les deux tours est ainsi garanti — doctrine). Sinon `nil`
    /// (conservateur : on ne densifie pas une structure non reconnue → zéro absurdité).
    private func activeBlock(roles: [YogaPoseRole], count: Int) -> Range<Int>? {
        guard count >= 3, roles.count == count else { return nil }
        let finalIndex = count - 1
        guard roles[finalIndex] == .finalRelaxation else { return nil }

        var start = 0
        while start < finalIndex, roles[start] == .openingBreath { start += 1 }
        guard start < finalIndex else { return nil }

        // Repos intercalé obligatoire : le bloc doit se terminer par un repos (balasana).
        guard roles[finalIndex - 1] == .rest else { return nil }
        return start..<finalIndex
    }
}
