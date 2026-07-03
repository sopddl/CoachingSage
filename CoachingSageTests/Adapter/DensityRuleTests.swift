// CoachingSageTests/Adapter/DensityRuleTests.swift
// Chantier densité B (2026-07-02) — filets de la spec (§ Filets swift 1-2) :
// éligibilité L1 par famille de sport, caps G4 (N=2, +20 %), no-op G1 (clearance),
// no-op sans signal, no-op hors gating niveau, exclusions G2/G3 (warmup, FIFA 11+,
// zones hautes), G8 (semaines décharge), invariant durée affichée, yoga L2/L3.
import XCTest
import TemplateModel
@testable import CoachingSage

final class DensityRuleTests: XCTestCase {

    private let rule = DensityRule()

    /// Signal actif (HK ≥ 1,5 séance/sem sur 4 sem).
    private let activeProfile = AdapterCoachingProfile(
        requiresMedicalClearance: false, weeklyWorkoutsAverage4w: 2.0
    )
    private let sportProfile = AdapterTestFixtures.sportProfile()

    // MARK: - Helpers

    /// Lift passthrough identique à `ProgramAdapter.adapt` (état d'entrée de la règle 4).
    private func lift(_ template: ProgramTemplate) -> [AdaptedWeek] {
        template.weeks.map { week in
            AdaptedWeek(
                weekNumber: week.weekNumber, theme: week.theme, goal: week.goal,
                sessions: week.sessions.map { s in
                    AdaptedSession(
                        day: s.day, name: s.name, durationMinutes: s.durationMinutes,
                        type: s.type, warmup: s.warmup,
                        exercises: s.exercises.map { AdaptedExercise.passthrough($0, sport: template.sport) },
                        cooldown: s.cooldown
                    )
                }
            )
        }
    }

    private func apply(
        _ template: ProgramTemplate,
        coachingProfile: AdapterCoachingProfile? = nil
    ) -> RuleResult {
        rule.apply(
            weeks: lift(template), template: template, sport: template.sport,
            level: template.level, sportProfile: sportProfile,
            coachingProfile: coachingProfile ?? activeProfile
        )
    }

    /// Template 1 semaine / 1 séance, paramétrable — le squelette de tous les cas L1.
    private func makeTemplate(
        sport: Sport = .strengthTraining,
        level: Level = .beginner,
        sessionType: SessionType = .strength,
        durationMinutes: Int = 45,
        deloadWeeks: [Int]? = nil,
        exercises: [TemplateExercise]
    ) -> ProgramTemplate {
        ProgramTemplate(
            id: "density-fixture", schemaVersion: 2, sport: sport, level: level,
            name: "Density fixture", durationWeeks: 1, sessionsPerWeek: 1,
            defaultObjective: "test", assumedProfile: "test", summary: "test",
            weeks: [TemplateWeek(
                weekNumber: 1, theme: "S1", goal: "G1",
                sessions: [TemplateSession(
                    day: 1, name: "Séance", durationMinutes: durationMinutes,
                    type: sessionType, warmup: "Échauffement 10 min",
                    exercises: exercises, cooldown: "Retour au calme"
                )]
            )],
            safetyNotes: "test", progressionLogic: "test",
            deloadWeeks: deloadWeeks
        )
    }

    private func accessory(_ name: String, sets: Int = 3, zone: String = "RPE 6-7") -> TemplateExercise {
        TemplateExercise(name: LocalizedText(fr: name), sets: sets, reps: "10",
                         restSeconds: 60, targetZone: zone)
    }

    // MARK: - L1 : éligibilité et bump

    func testStrengthAccessoryGetsOneMoreSet() {
        let template = makeTemplate(exercises: [accessory("Curl biceps")])
        let result = apply(template)
        let exo = result.weeks[0].sessions[0].exercises[0]
        XCTAssertEqual(exo.sets, 4, "+1 set attendu (3 → 4)")
        XCTAssertEqual(result.appliedRules.count, 1)
        XCTAssertEqual(result.appliedRules[0].ruleType, .density)
        XCTAssertEqual(result.appliedRules[0].outcome, .densified)
        // reps/duration inchangés — le levier ne touche que l'ENTIER sets.
        XCTAssertEqual(exo.reps, "10")
    }

    func testHighZoneNeverDensified() {
        // G3 whitelist : zones hautes / inconnues / absentes = inéligibles par défaut.
        let template = makeTemplate(exercises: [
            accessory("Squat lourd", sets: 5, zone: "%1RM 85-90%"),
            accessory("Sprint", sets: 6, zone: "RPE 8-9"),
            accessory("Box jumps", sets: 3, zone: "RPE 7-8"),
            TemplateExercise(name: "Sans zone", sets: 3, reps: "10", restSeconds: 60),
        ])
        let result = apply(template)
        XCTAssertTrue(result.appliedRules.isEmpty, "aucune zone haute/inconnue ne doit être densifiée")
        XCTAssertEqual(result.weeks, lift(template), "passthrough strict")
    }

    func testSingleSetExerciseIneligible() {
        // sets < 2 (sorties longues, blocs uniques) = inéligible par construction.
        let template = makeTemplate(exercises: [accessory("Bloc unique", sets: 1)])
        XCTAssertTrue(apply(template).appliedRules.isEmpty)
    }

    func testCapMaxTwoExercisesPerSession() {
        // G4 : N = 2 exos max, pris dans l'ORDRE de la séance (déterministe).
        let template = makeTemplate(exercises: [
            accessory("Premier"), accessory("Deuxième"), accessory("Troisième"),
        ])
        let result = apply(template)
        let sets = result.weeks[0].sessions[0].exercises.map(\.sets)
        XCTAssertEqual(sets, [4, 4, 3], "les 2 PREMIERS éligibles seulement")
        XCTAssertEqual(result.appliedRules.count, 2)
    }

    func testCapTwentyPercentDuration() {
        // G4 : un set trop coûteux pour le cap +20 % est sauté, le suivant qui tient passe.
        // Budget : 10 min → 120 s. Exo 1 : 2 min + 60 s repos = 180 s > 120 → sauté.
        // Exo 2 : reps-only nominal 40 s + 20 s repos = 60 s ≤ 120 → densifié.
        let big = TemplateExercise(name: "Gros bloc", sets: 2, duration: "2 min",
                                   restSeconds: 60, targetZone: "RPE 6-7")
        let small = TemplateExercise(name: "Petit accessoire", sets: 2, reps: "12",
                                     restSeconds: 20, targetZone: "RPE 5-6")
        let template = makeTemplate(durationMinutes: 10, exercises: [big, small])
        let result = apply(template)
        let exos = result.weeks[0].sessions[0].exercises
        XCTAssertEqual(exos[0].sets, 2, "trop coûteux pour le cap → intact")
        XCTAssertEqual(exos[1].sets, 3, "tient dans le budget → +1 set")
    }

    func testDisplayedDurationRecalculated() {
        // Invariant durée : durationMinutes == autoré + round(Σ secondes ajoutées / 60).
        // Ajout = (40 nominal + 60 repos) + (30 + 45) = 175 s → round(2,92) = +3 min.
        let repsOnly = accessory("Curl") // 40 + 60 = 100 s
        let timed = TemplateExercise(name: "Gainage", sets: 2, duration: "30 sec",
                                     restSeconds: 45, targetZone: "RPE 5-6") // 75 s
        let template = makeTemplate(durationMinutes: 45, exercises: [repsOnly, timed])
        let result = apply(template)
        XCTAssertEqual(result.weeks[0].sessions[0].durationMinutes, 48, "45 + round(175/60)")
    }

    func testNoDensificationLeavesDurationUntouched() {
        let template = makeTemplate(exercises: [accessory("Sprint", zone: "RPE 8-9")])
        XCTAssertEqual(apply(template).weeks[0].sessions[0].durationMinutes, 45)
    }

    // MARK: - No-op : G1, signal, gating niveau, G8

    func testMedicalClearanceIsTotalNoOp() {
        let template = makeTemplate(exercises: [accessory("Curl")])
        let profile = AdapterCoachingProfile(
            requiresMedicalClearance: true, weeklyWorkoutsAverage4w: 5.0
        )
        let result = apply(template, coachingProfile: profile)
        XCTAssertTrue(result.appliedRules.isEmpty, "G1 : clearance → no-op total")
        XCTAssertEqual(result.weeks, lift(template))
    }

    func testNoSignalMeansNoDensification() {
        // Fork #2 Sophie : PAS de densification par défaut (≠ cold-start D5 archive).
        let template = makeTemplate(exercises: [accessory("Curl")])
        let noSignal = AdapterCoachingProfile(requiresMedicalClearance: false)
        XCTAssertTrue(apply(template, coachingProfile: noSignal).appliedRules.isEmpty)
    }

    func testSignalBelowThresholdStaysCalm() {
        let template = makeTemplate(exercises: [accessory("Curl")])
        let calm = AdapterCoachingProfile(
            requiresMedicalClearance: false, weeklyWorkoutsAverage4w: 1.4
        )
        XCTAssertTrue(apply(template, coachingProfile: calm).appliedRules.isEmpty)
    }

    func testDeclaredRegularActivityDensifies() {
        // Cold-start : réponse « oui » à la question de calibrage = signal valide (G6).
        let template = makeTemplate(exercises: [accessory("Curl")])
        let declared = AdapterCoachingProfile(
            requiresMedicalClearance: false, declaredRegularActivity: true
        )
        XCTAssertEqual(apply(template, coachingProfile: declared).appliedRules.count, 1)
    }

    func testRegularAndCompetitiveLevelsAreGatedOut() {
        for level in [Level.regular, .competitive] {
            let template = makeTemplate(level: level, exercises: [accessory("Curl")])
            XCTAssertTrue(apply(template).appliedRules.isEmpty,
                          "gating : \(level) jamais densifié (anti double-comptage autoprofil)")
        }
    }

    func testDeloadWeeksNeverDensified() {
        // G8 : semaine marquée décharge → intacte, les autres densifiées.
        let template = ProgramTemplate(
            id: "deload-fixture", schemaVersion: 2, sport: .strengthTraining,
            level: .beginner, name: "Deload fixture", durationWeeks: 2, sessionsPerWeek: 1,
            defaultObjective: "test", assumedProfile: "test", summary: "test",
            weeks: (1...2).map { wn in
                TemplateWeek(weekNumber: wn, theme: "S\(wn)", goal: "G\(wn)", sessions: [
                    TemplateSession(day: 1, name: "Séance", durationMinutes: 45,
                                    type: .strength, warmup: nil,
                                    exercises: [accessory("Curl")], cooldown: nil)
                ])
            },
            safetyNotes: "test", progressionLogic: "test",
            deloadWeeks: [2]
        )
        let result = apply(template)
        XCTAssertEqual(result.weeks[0].sessions[0].exercises[0].sets, 4, "W1 densifiée")
        XCTAssertEqual(result.weeks[1].sessions[0].exercises[0].sets, 3, "W2 décharge intacte (G8)")
    }

    // MARK: - Exclusions par nom (G2 défensif, FIFA 11+, étirements)

    func testFifaElevenPlusProtocolNeverDensified() {
        let fifa = TemplateExercise(name: LocalizedText(fr: "FIFA 11+ — Gainage planche"),
                                    sets: 3, reps: "3", restSeconds: 30, targetZone: "RPE 5-6")
        let drill = TemplateExercise(name: LocalizedText(fr: "Conduite de balle slalom"),
                                     sets: 3, duration: "45 sec", restSeconds: 30, targetZone: "technique")
        let template = makeTemplate(sport: .football, exercises: [fifa, drill])
        let result = apply(template)
        let exos = result.weeks[0].sessions[0].exercises
        XCTAssertEqual(exos[0].sets, 3, "protocole FIFA 11+ figé")
        XCTAssertEqual(exos[1].sets, 4, "drill technique densifié")
    }

    func testStretchingAndWarmupNamedExercisesExcluded() {
        let template = makeTemplate(sport: .cycling, exercises: [
            TemplateExercise(name: LocalizedText(fr: "Étirements quadriceps"),
                             sets: 3, duration: "30 sec", restSeconds: 15, targetZone: "RPE 4-5"),
            TemplateExercise(name: LocalizedText(fr: "Gammes warmup vélo"),
                             sets: 2, duration: "5 min", restSeconds: 60, targetZone: "FTP-Z1"),
        ])
        XCTAssertTrue(apply(template).appliedRules.isEmpty)
    }

    // MARK: - Familles de sport (whitelists G3)

    func testHiitIntervalSessionsUntouchable() {
        let support = accessory("Gainage support", zone: "RPE 6-7")
        let interval = makeTemplate(sport: .hiit, sessionType: .interval, exercises: [support])
        XCTAssertTrue(apply(interval).appliedRules.isEmpty, "HIIT interval intouchable")

        let strength = makeTemplate(sport: .hiit, sessionType: .strength, exercises: [support])
        XCTAssertEqual(apply(strength).appliedRules.count, 1, "HIIT strength densifiable")
    }

    func testRunningEasyRPEOnlyInStrengthSessions() {
        let renfo = accessory("Renfo mollets", zone: "RPE 5-6")
        let endurance = makeTemplate(sport: .running, sessionType: .endurance, exercises: [renfo])
        XCTAssertTrue(apply(endurance).appliedRules.isEmpty, "RPE facile hors renfo = inéligible")

        let strength = makeTemplate(sport: .running, sessionType: .strength, exercises: [renfo])
        XCTAssertEqual(apply(strength).appliedRules.count, 1)
    }

    func testRunningDanielsEEligibleAnySession() {
        let runWalk = TemplateExercise(name: LocalizedText(fr: "Bloc course-marche"),
                                       sets: 4, duration: "3 min", restSeconds: 60,
                                       targetZone: "Daniels-E")
        let template = makeTemplate(sport: .running, sessionType: .endurance,
                                    durationMinutes: 40, exercises: [runWalk])
        XCTAssertEqual(apply(template).appliedRules.count, 1, "bloc run/walk Daniels-E densifiable")
    }

    func testSwimmingRPEOnlyDryLand() {
        // Passthrough natation : équipement non vide sans « pool » → dryLand.
        let dry = TemplateExercise(name: LocalizedText(fr: "Y-T-W épaules"), sets: 3,
                                   reps: "8", restSeconds: 45, targetZone: "RPE 5-6",
                                   requiredEquipment: ["elastic-band"])
        let wet = TemplateExercise(name: LocalizedText(fr: "Battements planche"), sets: 4,
                                   duration: "45 sec", restSeconds: 30, targetZone: "RPE 5-6",
                                   requiredEquipment: ["pool"])
        let drill = TemplateExercise(name: LocalizedText(fr: "Éducatif 25 m"), sets: 4,
                                     duration: "45 sec", restSeconds: 30, targetZone: "technique",
                                     requiredEquipment: ["pool"])
        let template = makeTemplate(sport: .swimming, sessionType: .technique,
                                    exercises: [dry, wet, drill])
        let result = apply(template)
        let exos = result.weeks[0].sessions[0].exercises
        XCTAssertEqual(exos[0].sets, 4, "renfo à sec RPE facile densifié")
        XCTAssertEqual(exos[1].sets, 4, "RPE dans l'eau inéligible")
        XCTAssertEqual(exos[2].sets, 5, "éducatif technique densifié (+1×25 m)")
    }

    // MARK: - Yoga (L2 extendHold + L3 repeatActiveBlock, L1 OFF)

    private func yogaTemplate(durationMinutes: Int, actives: [TemplateExercise]) -> ProgramTemplate {
        let pranayama = TemplateExercise(name: LocalizedText(fr: "Pranayama dirgha (respiration)"),
                                         duration: "3 min", targetZone: "respiration guidée")
        let balasana = TemplateExercise(name: LocalizedText(fr: "Balasana (posture de l'enfant)"),
                                        duration: "30 sec", targetZone: "réparateur")
        let savasana = TemplateExercise(name: LocalizedText(fr: "Savasana (relaxation finale)"),
                                        duration: "5 min", targetZone: "réparateur")
        return makeTemplate(sport: .yoga, sessionType: .mobility,
                            durationMinutes: durationMinutes,
                            exercises: [pranayama] + actives + [balasana, savasana])
    }

    func testYogaExtendsBriefActiveHoldsAndRepeatsShortBlock() {
        // Budget 30 min → 360 s. L2 : 30 s → 45 s (+15 s). L3 : bloc actif (45 + 30 s) = 75 s
        // ≤ budget restant → +1 tour, repos intercalé garanti (balasana ferme le bloc).
        let active = TemplateExercise(name: LocalizedText(fr: "Virabhadrasana II (guerrier)"),
                                      duration: "30 sec", targetZone: "maintien 30 s")
        let template = yogaTemplate(durationMinutes: 30, actives: [active])
        let result = apply(template)
        let exos = result.weeks[0].sessions[0].exercises

        XCTAssertEqual(SessionDurationParser.seconds(exos[1].duration), 45, "L2 : tenue 30 → 45 s")
        XCTAssertEqual(exos.count, 6, "L3 : +1 tour = (guerrier + balasana) dupliqués")
        XCTAssertEqual(SessionDurationParser.seconds(exos[0].duration), 180, "pranayama d'ouverture intact (sacro-saint)")
        XCTAssertEqual(SessionDurationParser.seconds(exos.last?.duration), 300, "savasana 5 min intacte, dernier rang")
        // Durée : +15 (L2) + 75 (L3) = 90 s → +2 min.
        XCTAssertEqual(result.weeks[0].sessions[0].durationMinutes, 32)
    }

    func testYogaStandardSessionRefusesExtraRoundOverCap() {
        // Bloc actif long (10 × 60 s = 600 s) > budget 360 s → PAS de tour ajouté (G4),
        // et tenues 60 s ≥ plafond 45 s → pas de L2 non plus. Passthrough strict.
        let actives = (1...10).map { i in
            TemplateExercise(name: LocalizedText(fr: "Posture active \(i)"),
                             duration: "60 sec", targetZone: "maintien 60 s")
        }
        let template = yogaTemplate(durationMinutes: 30, actives: actives)
        let result = apply(template)
        XCTAssertTrue(result.appliedRules.isEmpty)
        XCTAssertEqual(result.weeks, lift(template))
    }

    func testYogaL1IsOff() {
        // Un exo yoga avec sets ≥ 2 + zone whitelistable ailleurs ne prend JAMAIS +1 set.
        let flow = TemplateExercise(name: LocalizedText(fr: "Salutation au soleil A"),
                                    sets: 3, duration: "60 sec", restSeconds: 30,
                                    targetZone: "enchaînement")
        let template = yogaTemplate(durationMinutes: 40, actives: [flow])
        let result = apply(template)
        XCTAssertEqual(result.weeks[0].sessions[0].exercises[1].sets, 3, "L1 OFF en yoga")
    }

    // MARK: - Comptage temps honnête (review 07-03) — dose structuré prioritaire

    func testStrictTimeSecondsRejectsNonTimeUnits() {
        // Le parser permissif lirait « 50 m » = 50 s, « 5 respirations » = 5 s,
        // « 1 cycle complet » = 1 s → le comptage densité exige une unité TEMPORELLE.
        XCTAssertNil(DensityRule.strictTimeSeconds("50 m"))
        XCTAssertNil(DensityRule.strictTimeSeconds("5 respirations"))
        XCTAssertNil(DensityRule.strictTimeSeconds("1 cycle complet"))
        XCTAssertNil(DensityRule.strictTimeSeconds("8 x 25 m"))
        XCTAssertNil(DensityRule.strictTimeSeconds(nil))
        XCTAssertEqual(DensityRule.strictTimeSeconds("40"), 40, "nombre nu = secondes (convention)")
        XCTAssertEqual(DensityRule.strictTimeSeconds("30 sec"), 30)
        XCTAssertEqual(DensityRule.strictTimeSeconds("1 min 30"), 90)
        XCTAssertEqual(DensityRule.strictTimeSeconds("1 min course lente + 1 min 30 marche rapide"), 150)
    }

    func testYogaBreathAndCycleDosesNeverDensified() {
        // Hatha réel : tenues en respirations/cycles (dose structuré non temporel).
        // L2 ne bumpe pas (« 5 respirations » → « 8 respirations » serait un bump aveugle
        // au coût réel), L3 refuse le bloc entier (coût induplicable honnêtement).
        let breaths = TemplateExercise(
            name: LocalizedText(fr: "Trikonasana (triangle)"),
            duration: "5 respirations",
            dose: .structured(StructuredDose(value: "5", unit: .breaths)),
            targetZone: "maintien"
        )
        let cycles = TemplateExercise(
            name: LocalizedText(fr: "Salutation au soleil A"),
            duration: "1 cycle complet",
            dose: .structured(StructuredDose(value: "1", unit: .cycles)),
            targetZone: "enchaînement"
        )
        let template = yogaTemplate(durationMinutes: 60, actives: [breaths, cycles])
        let result = apply(template)
        XCTAssertTrue(result.appliedRules.isEmpty, "respirations/cycles = non temporisables → passthrough")
        XCTAssertEqual(result.weeks, lift(template))
    }

    func testYogaPerSideHoldChargedBothSides() {
        // « 20 sec par côté » : l'allongement 20 → 30 s coûte 2 × 10 s (les DEUX côtés).
        // Budget 12 s (1 min) : la version par côté (coût 20 s) est REFUSÉE là où la
        // version simple (coût 10 s) passe.
        func hold(_ qualifier: DoseQualifier?) -> TemplateExercise {
            TemplateExercise(
                name: LocalizedText(fr: "Utthita parsvakonasana (angle étiré)"),
                duration: qualifier == nil ? "20 sec" : "20 sec par côté",
                dose: .structured(StructuredDose(value: "20", unit: .seconds, qualifier: qualifier)),
                targetZone: "maintien"
            )
        }
        let perSide = apply(yogaTemplate(durationMinutes: 1, actives: [hold(.perSide)]))
        XCTAssertTrue(perSide.appliedRules.isEmpty, "coût ×2 (20 s) > budget 12 s → refusé")

        let single = apply(yogaTemplate(durationMinutes: 1, actives: [hold(nil)]))
        XCTAssertEqual(single.appliedRules.filter { $0.detail.contains("Tenue allongée") }.count, 1,
                       "coût ×1 (10 s) ≤ budget 12 s → allongé")
    }

    func testYogaPerSideBumpSyncsDurationAndDose() {
        let hold = TemplateExercise(
            name: LocalizedText(fr: "Vrksasana (arbre)"),
            duration: "20 sec par côté",
            dose: .structured(StructuredDose(value: "20", unit: .seconds, qualifier: .perSide)),
            targetZone: "équilibre"
        )
        let result = apply(yogaTemplate(durationMinutes: 30, actives: [hold]))
        let exo = result.weeks[0].sessions[0].exercises[1]
        XCTAssertEqual(exo.duration, "30 sec par côté", "texte : nombre de tête remplacé, libellé conservé")
        guard case .structured(let d)? = exo.dose else { return XCTFail("dose structuré attendu") }
        XCTAssertEqual(d.value, "30", "dose resynchronisé")
        XCTAssertEqual(d.qualifier, .perSide, "qualificateur conservé")
    }

    func testYogaCapTwoHoldsPerSession() {
        // G4 N=2 vaut aussi pour L2 : 3 tenues brèves éligibles → seules les 2 premières allongées.
        let actives = (1...3).map { i in
            TemplateExercise(name: LocalizedText(fr: "Posture active \(i)"),
                             duration: "20 sec", targetZone: "maintien")
        }
        let result = apply(yogaTemplate(durationMinutes: 30, actives: actives))
        let extended = result.appliedRules.filter { $0.detail.contains("Tenue allongée") }
        XCTAssertEqual(extended.count, 2, "cap N=2 exos/séance, L2 compris")
        let exos = result.weeks[0].sessions[0].exercises
        XCTAssertEqual(SessionDurationParser.seconds(exos[3].duration), 20, "3ᵉ tenue intacte")
    }

    func testSwimmingMetersDoseChargedNominalNotAsSeconds() {
        // Dose en mètres = temps inconnu → estimation nominale (~40 s). Et « 50 m » SANS
        // dose n'est plus lu « 50 secondes » par le repli texte → inéligible.
        let dosedDrill = TemplateExercise(
            name: LocalizedText(fr: "Éducatif battements 50 m"), sets: 4,
            duration: "50 m", restSeconds: 25,
            dose: .structured(StructuredDose(value: "50", unit: .meters)),
            targetZone: "technique", requiredEquipment: ["pool"]
        )
        let bareDrill = TemplateExercise(
            name: LocalizedText(fr: "Éducatif rattrapé 25 m"), sets: 4,
            duration: "25 m", restSeconds: 25, targetZone: "EN1",
            requiredEquipment: ["pool"]
        )
        let template = makeTemplate(sport: .swimming, sessionType: .technique,
                                    exercises: [dosedDrill, bareDrill])
        let result = apply(template)
        let exos = result.weeks[0].sessions[0].exercises
        XCTAssertEqual(exos[0].sets, 5, "dose meters → nominale (40+25 s) → densifié")
        XCTAssertEqual(exos[1].sets, 4, "texte « 25 m » sans dose : non temporisable → intact")
        // Durée affichée : +round(65/60) = +1 min, pas +round((50+25)/60).
        XCTAssertEqual(result.weeks[0].sessions[0].durationMinutes, 46)
    }

    func testStaleDeclarationDoesNotOverrideFreshLowHKSignal() {
        // Le HK frais fait autorité : déclaration « oui » passée + mesure réelle 0,5/sem
        // → PAS de densification (la déclaration ne sert que quand HK est muet).
        let template = makeTemplate(exercises: [accessory("Curl")])
        let stale = AdapterCoachingProfile(
            requiresMedicalClearance: false,
            weeklyWorkoutsAverage4w: 0.5,
            declaredRegularActivity: true
        )
        XCTAssertTrue(apply(template, coachingProfile: stale).appliedRules.isEmpty)
    }

    // MARK: - Pipeline complet : non-régression signal nil

    func testFullPipelineWithoutSignalIsUnchanged() {
        // Non-régression par construction : profils historiques (signal nil) → la sortie
        // du pipeline avec DensityRule == sans DensityRule.
        let template = AdapterTestFixtures.makeRunningTemplate()
        let sport = AdapterTestFixtures.sportProfile()
        let coaching = AdapterTestFixtures.coachingProfile()
        let now = Date(timeIntervalSince1970: 1_780_000_000)

        let with = ProgramAdapter().adapt(template: template, sportProfile: sport,
                                          coachingProfile: coaching, now: now)
        let without = ProgramAdapter(rules: [
            ConstraintSubstitutionRule(), EquipmentSubstitutionRule(),
            VolumeModulationRule(), LevelPacingRule(), MedicalClearanceRule(),
        ]).adapt(template: template, sportProfile: sport, coachingProfile: coaching, now: now)

        XCTAssertEqual(with, without)
        XCTAssertFalse(with.appliedRules.contains { $0.ruleType == .density })
    }
}
