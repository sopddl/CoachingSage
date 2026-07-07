// CoachingSageTests/Persistence/AdaptedProgramRecordTests.swift
// Story 3.8 — tests data model SwiftData :
//   - JSON round-trip pour `sessions` et `completionState` (lesson lessons_swiftdata #1)
//   - bridge `AdaptedProgram → AdaptedProgramRecord` (mode .ondemand par défaut, isActive, sessions flat)
//   - persistance via ModelContext (insert + fetch + update)
import XCTest
import SwiftData
import TemplateModel

@MainActor
final class AdaptedProgramRecordTests: XCTestCase {

    /// **Dette SwiftData test_host hang (2026-05-22)** — le `container` DOIT
    /// être retenu par l'appelant, sinon il est déalloué et le mainContext
    /// crash au fetch. Helper retourne désormais le tuple (container, context).
    private static func makeProgramContext() throws -> (ModelContainer, ModelContext) {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("AdaptedProgramRecord-\(UUID()).sqlite")
        let config = ModelConfiguration(url: url)
        let container = try ModelContainer(for: AdaptedProgramRecord.self, configurations: config)
        return (container, container.mainContext)
    }

    // MARK: - JSON round-trip

    func testSessionsJsonRoundTrip() throws {
        let session = PersistedSession(
            weekNumber: 1, weekTheme: "Découverte", weekGoal: "Reprendre",
            day: 1, name: "Footing 30 min", durationMinutes: 30, type: .endurance,
            warmup: "5 min marche",
            exercises: [
                AdaptedExercise(
                    name: "Footing 30 min", originalName: "Footing 30 min",
                    duration: "30 min", targetZone: "Daniels-E",
                    volumeAxis: .duration
                )
            ],
            cooldown: "5 min étirements"
        )

        let record = AdaptedProgramRecord(
            userId: UUID(),
            sportCode: "running", level: "beginner",
            templateId: "running-beginner-couch-to-5k",
            adaptedAt: Date(),
            weekStartDate: Date(),
            sessions: [session]
        )

        XCTAssertEqual(record.sessions.count, 1)
        XCTAssertEqual(record.sessions.first?.name, "Footing 30 min")
        XCTAssertEqual(record.sessions.first?.day, 1)

        // Ré-écriture via setter doit re-encoder correctement.
        var sessions = record.sessions
        let renamed = PersistedSession(
            id: sessions[0].id,
            weekNumber: sessions[0].weekNumber,
            weekTheme: sessions[0].weekTheme,
            weekGoal: sessions[0].weekGoal,
            day: sessions[0].day,
            name: "Footing 35 min",
            durationMinutes: 35,
            type: sessions[0].type,
            warmup: sessions[0].warmup,
            exercises: sessions[0].exercises,
            cooldown: sessions[0].cooldown
        )
        sessions[0] = renamed
        record.sessions = sessions
        XCTAssertEqual(record.sessions.first?.name, "Footing 35 min")
        XCTAssertEqual(record.sessions.first?.durationMinutes, 35)
    }

    /// **B1 non-régression** : un `sessionsJsonData` persisté AVANT la migration
    /// LocalizedText (champs texte = String nues) doit décoder en `{ fr: … }` via
    /// le decoder tolérant, et résoudre en fallback FR pour une langue absente.
    func testLegacySessionsJsonDecodesBareStringsAsFR() throws {
        let id = UUID().uuidString
        let legacyJSON = """
        [{"id":"\(id)","weekNumber":1,"weekTheme":"Découverte","weekGoal":"Reprendre",\
        "day":1,"name":"Footing 30 min","durationMinutes":30,"type":"endurance",\
        "warmup":"5 min marche","cooldown":"5 min étirements",\
        "exercises":[{"name":"Footing 30 min","originalName":"Footing 30 min","wasSubstituted":false}]}]
        """
        let sessions = try JSONDecoder().decode([PersistedSession].self, from: Data(legacyJSON.utf8))
        XCTAssertEqual(sessions.count, 1)
        let s = sessions[0]
        // String nue → valeur canonique FR.
        XCTAssertEqual(s.name.fr, "Footing 30 min")
        XCTAssertEqual(s.weekTheme.fr, "Découverte")
        XCTAssertEqual(s.weekGoal.fr, "Reprendre")
        XCTAssertEqual(s.warmup?.fr, "5 min marche")
        XCTAssertEqual(s.cooldown?.fr, "5 min étirements")
        XCTAssertEqual(s.exercises.first?.name.fr, "Footing 30 min")
        XCTAssertEqual(s.exercises.first?.originalName, "Footing 30 min")
        // Fallback FR pour une langue non traduite (pré-B2).
        let en = Locale(identifier: "en")
        XCTAssertEqual(s.name.resolved(en), "Footing 30 min")
        XCTAssertEqual(s.warmup?.resolved(en), "5 min marche")
        // Ré-encodage → format objet (migration paresseuse au prochain set).
        let reEncoded = try JSONEncoder().encode(sessions)
        let json = String(decoding: reEncoded, as: UTF8.self)
        XCTAssertTrue(json.contains("\"fr\""), "doit ré-encoder en objet {fr:…}")
    }

    func testCompletionStateJsonRoundTrip() throws {
        let sessionId = UUID()
        let record = AdaptedProgramRecord(
            userId: UUID(),
            sportCode: "running", level: "beginner",
            templateId: "test",
            adaptedAt: Date(), weekStartDate: Date(),
            sessions: []
        )

        // Empty par défaut.
        XCTAssertEqual(record.completionState.sessionRecords.count, 0)
        XCTAssertEqual(record.completionState.completedCount, 0)

        // Update via setter.
        var state = record.completionState
        state.sessionRecords[sessionId] = SessionCompletionRecord(
            completedAt: Date(timeIntervalSince1970: 1_700_000_000),
            actualDurationMinutes: 32,
            perceivedEffort: 6,
            notes: "Genou tendu sur la fin"
        )
        record.completionState = state

        XCTAssertEqual(record.completionState.completedCount, 1)
        XCTAssertEqual(record.completionState.sessionRecords[sessionId]?.actualDurationMinutes, 32)
        XCTAssertEqual(record.completionState.sessionRecords[sessionId]?.perceivedEffort, 6)
    }

    // MARK: - Bridge AdaptedProgram → AdaptedProgramRecord

    func testBridgeFromAdaptedProgramSetsDefaults() {
        let adapted = makeAdaptedFixture()
        let userId = UUID()

        let record = AdaptedProgramRecord(from: adapted, userId: userId)

        XCTAssertEqual(record.userId, userId)
        XCTAssertEqual(record.sportCode, "running")
        XCTAssertEqual(record.level, "beginner")
        XCTAssertEqual(record.templateId, "running-beginner-couch-to-5k")
        XCTAssertEqual(record.adaptedAt, adapted.appliedAt)
        XCTAssertEqual(record.mode, .ondemand)         // pool par défaut
        XCTAssertTrue(record.isActive)                  // actif à la création
        XCTAssertNil(record.archivedAt)
        XCTAssertEqual(record.completionState.completedCount, 0)
        // Story sœur — defaults durée : routineCyclic, pas de date cible, cycle 1.
        XCTAssertEqual(record.durationMode, .routineCyclic)
        XCTAssertNil(record.targetDate)
        XCTAssertEqual(record.cycleNumber, 1)
    }

    // MARK: - Story sœur — durationMode / targetDate / cycleNumber

    func testBridgeFromAdaptedProgramPreservesDeadlineFixed() {
        let target = Date(timeIntervalSince1970: 1_710_000_000)
        let adapted = makeAdaptedFixture(durationMode: .deadlineFixed, targetDate: target)

        let record = AdaptedProgramRecord(from: adapted, userId: UUID())

        XCTAssertEqual(record.durationMode, .deadlineFixed)
        XCTAssertEqual(record.targetDate, target)
        XCTAssertEqual(record.cycleNumber, 1)
    }

    func testBridgeFromAdaptedProgramPreservesDeadlineEstimated() {
        let estimated = Date(timeIntervalSince1970: 1_715_000_000)
        let adapted = makeAdaptedFixture(durationMode: .deadlineEstimated, targetDate: estimated)

        let record = AdaptedProgramRecord(from: adapted, userId: UUID())

        XCTAssertEqual(record.durationMode, .deadlineEstimated)
        XCTAssertEqual(record.targetDate, estimated)
    }

    func testBridgeAcceptsCustomCycleNumber() {
        let adapted = makeAdaptedFixture()  // routineCyclic par défaut

        let record = AdaptedProgramRecord(from: adapted, userId: UUID(), cycleNumber: 3)

        XCTAssertEqual(record.cycleNumber, 3)
        XCTAssertEqual(record.durationMode, .routineCyclic)
    }

    func testToAdaptedProgramRoundtripsDurationFields() {
        let target = Date(timeIntervalSince1970: 1_720_000_000)
        let adapted = makeAdaptedFixture(durationMode: .deadlineFixed, targetDate: target)
        let record = AdaptedProgramRecord(from: adapted, userId: UUID())

        let roundtrip = record.toAdaptedProgram()

        XCTAssertEqual(roundtrip?.durationMode, .deadlineFixed)
        XCTAssertEqual(roundtrip?.targetDate, target)
    }

    func testBridgeFromAdaptedProgramPropagatesAIAssistFlags() {
        let adapted = makeAdaptedFixture(requiresAIAssist: true, aiAssistReason: "Combinaison rare contraintes")

        let record = AdaptedProgramRecord(from: adapted, userId: UUID())

        XCTAssertTrue(record.requiresAIAssist)
        XCTAssertEqual(record.aiAssistReason, "Combinaison rare contraintes")
        XCTAssertFalse(record.aiPatchApplied)
        XCTAssertNil(record.aiPatchJSON)
    }

    func testToAdaptedProgramPreservesAIAssistFlags() {
        let adapted = makeAdaptedFixture(requiresAIAssist: true, aiAssistReason: "Cas atypique")
        let record = AdaptedProgramRecord(from: adapted, userId: UUID())

        let roundtrip = record.toAdaptedProgram()

        XCTAssertEqual(roundtrip?.requiresAIAssist, true)
        XCTAssertEqual(roundtrip?.aiAssistReason, "Cas atypique")
    }

    func testBridgeDefaultsAIAssistFlagsToFalseWhenAdapterClean() {
        let adapted = makeAdaptedFixture()  // requiresAIAssist: false par défaut

        let record = AdaptedProgramRecord(from: adapted, userId: UUID())

        XCTAssertFalse(record.requiresAIAssist)
        XCTAssertNil(record.aiAssistReason)
        XCTAssertFalse(record.aiPatchApplied)
        XCTAssertNil(record.aiPatchJSON)
    }

    // MARK: - Densité B (2026-07-02) — densityApplied

    func testBridgeSetsDensityAppliedWhenDensityRuleActed() {
        let densified = makeAdaptedFixture(appliedRules: [
            AppliedRule(
                ruleType: .density, weekNumber: 1, day: 1,
                originalExerciseName: "Footing", outcome: .densified,
                detail: "+1 série (2 → 3)"
            )
        ])
        XCTAssertTrue(AdaptedProgramRecord(from: densified, userId: UUID()).densityApplied)
    }

    func testBridgeDefaultsDensityAppliedFalseWithoutDensityRule() {
        // Aucune règle, ou des règles NON-densité → false (dormants + programmes sans signal).
        let clean = makeAdaptedFixture()
        XCTAssertFalse(AdaptedProgramRecord(from: clean, userId: UUID()).densityApplied)

        let otherRule = makeAdaptedFixture(appliedRules: [
            AppliedRule(
                ruleType: .volumeModulation, weekNumber: 1, day: 1,
                originalExerciseName: "Footing", outcome: .noChange, detail: ""
            )
        ])
        XCTAssertFalse(AdaptedProgramRecord(from: otherRule, userId: UUID()).densityApplied)
    }

    func testBridgeFlattensWeeksAndSessions() {
        // 2 weeks × 3 sessions = 6 PersistedSession à plat.
        let adapted = makeAdaptedFixture(weeksCount: 2, sessionsPerWeek: 3)

        let record = AdaptedProgramRecord(from: adapted, userId: UUID())

        XCTAssertEqual(record.sessions.count, 6)
        // Méta de week conservées sur chaque session.
        XCTAssertEqual(record.sessions[0].weekNumber, 1)
        XCTAssertEqual(record.sessions[0].weekTheme, "Semaine 1")
        XCTAssertEqual(record.sessions[3].weekNumber, 2)
        XCTAssertEqual(record.sessions[3].weekTheme, "Semaine 2")
        // IDs uniques (un par session, pas dérivé du contenu).
        let ids = record.sessions.map(\.id)
        XCTAssertEqual(Set(ids).count, 6)
    }

    // MARK: - Story 3.3b — patch IA Léon

    func testApplyLeonPatchPersistsFlagsAndJSON() throws {
        let record = AdaptedProgramRecord(from: makeAdaptedFixture(requiresAIAssist: true), userId: UUID())
        XCTAssertFalse(record.aiPatchApplied)
        XCTAssertNil(record.aiPatchJSON)

        let patch = AdaptationPatch(personalizationNote: "Bien joué Sarah")
        try record.applyLeonPatch(patch)

        XCTAssertTrue(record.aiPatchApplied)
        XCTAssertNotNil(record.aiPatchJSON)
    }

    func testDecodedLeonPatchRoundtripsCleanly() throws {
        let record = AdaptedProgramRecord(from: makeAdaptedFixture(requiresAIAssist: true), userId: UUID())
        let original = AdaptationPatch(
            exerciseSubstitutions: [
                .init(weekNumber: 1, day: 2, originalExerciseName: "Footing 30 min",
                      replacementExerciseName: "Marche", reason: "knee")
            ],
            personalizationNote: "Hi"
        )
        try record.applyLeonPatch(original)

        let decoded = record.decodedLeonPatch()
        XCTAssertEqual(decoded?.personalizationNote, "Hi")
        XCTAssertEqual(decoded?.exerciseSubstitutions?.count, 1)
        XCTAssertEqual(decoded?.exerciseSubstitutions?.first?.replacementExerciseName, "Marche")
    }

    func testDecodedLeonPatchReturnsNilWhenNoPatchApplied() {
        let record = AdaptedProgramRecord(from: makeAdaptedFixture(), userId: UUID())
        XCTAssertNil(record.decodedLeonPatch())
    }

    func testToAppliedAdaptedProgramAppliesPersistedPatch() throws {
        let record = AdaptedProgramRecord(from: makeAdaptedFixture(requiresAIAssist: true), userId: UUID())
        try record.applyLeonPatch(AdaptationPatch(personalizationNote: "Hi Sarah"))

        let applied = record.toAppliedAdaptedProgram()

        XCTAssertNotNil(applied)
        XCTAssertEqual(applied?.leonNotes?.personalizationNote, "Hi Sarah")
        XCTAssertEqual(applied?.program.requiresAIAssist, true)
    }

    func testToAppliedAdaptedProgramReturnsBareProgramIfNoPatch() {
        let record = AdaptedProgramRecord(from: makeAdaptedFixture(), userId: UUID())

        let applied = record.toAppliedAdaptedProgram()

        XCTAssertNotNil(applied)
        XCTAssertNil(applied?.leonNotes)
    }

    // MARK: - Persistance ModelContext

    func testInsertAndFetchAdaptedProgramRecord() throws {
        let (container, ctx) = try Self.makeProgramContext()
        _ = container
        let adapted = makeAdaptedFixture()
        let record = AdaptedProgramRecord(from: adapted, userId: UUID())
        ctx.insert(record)
        try ctx.save()

        let fetched = try ctx.fetch(FetchDescriptor<AdaptedProgramRecord>())
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.id, record.id)
    }

    // MARK: - Chantier indoor/outdoor vélo — sessionLocations + environmentDefault

    func testSessionLocationStateSetGetAndRemove() {
        var s = SessionLocationState.empty
        XCTAssertNil(s.environment(week: 3, day: 5))
        s.set(.indoor, week: 3, day: 5)
        XCTAssertEqual(s.environment(week: 3, day: 5), .indoor)
        XCTAssertEqual(SessionLocationState.key(week: 3, day: 5), "3-5")
        s.set(nil, week: 3, day: 5) // retrait override
        XCTAssertNil(s.environment(week: 3, day: 5))
    }

    func testSessionLocationsAndEnvironmentDefaultRoundTripThroughSwiftData() throws {
        let (container, ctx) = try Self.makeProgramContext()
        _ = container
        let record = AdaptedProgramRecord(from: makeAdaptedFixture(), userId: UUID())
        var state = record.sessionLocations
        state.set(.indoor, week: 1, day: 5)
        record.sessionLocations = state
        record.environmentDefaultRaw = "both"
        ctx.insert(record)
        try ctx.save()

        let fetched = try ctx.fetch(FetchDescriptor<AdaptedProgramRecord>()).first
        XCTAssertEqual(fetched?.sessionLocations.environment(week: 1, day: 5), .indoor)
        XCTAssertEqual(fetched?.environmentDefaultRaw, "both")
    }

    func testArchivingFlipsIsActiveAndSetsArchivedAt() throws {
        let (container, ctx) = try Self.makeProgramContext()
        _ = container
        let adapted = makeAdaptedFixture()
        let record = AdaptedProgramRecord(from: adapted, userId: UUID())
        ctx.insert(record)
        try ctx.save()

        record.isActive = false
        record.archivedAt = Date(timeIntervalSince1970: 1_700_000_000)
        try ctx.save()

        let fetched = try ctx.fetch(FetchDescriptor<AdaptedProgramRecord>())
        XCTAssertEqual(fetched.first?.isActive, false)
        XCTAssertNotNil(fetched.first?.archivedAt)
    }

    // MARK: - Story 3.10 AC31 — markStarted + decode rétro-compat

    func testCommitFactoryProducesDormantRecord() {
        let adapted = makeAdaptedFixture()
        let record = AdaptedProgramRecord(from: adapted, userId: UUID())
        // **AC4** — convenience init `(from:)` default `weekStartDate: nil` → dormant.
        XCTAssertNil(record.weekStartDate)
        XCTAssertTrue(record.isActive)
        XCTAssertEqual(record.shiftGeneration, 0)
    }

    func testMarkStartedPosesWeekStartDateOnDormant() {
        let adapted = makeAdaptedFixture()
        let record = AdaptedProgramRecord(from: adapted, userId: UUID())
        XCTAssertNil(record.weekStartDate)

        let now = Date(timeIntervalSince1970: 1_700_000_000)
        record.markStarted(now: now)

        XCTAssertNotNil(record.weekStartDate)
        // Lundi 00:00 (ISO firstWeekday=2) de la semaine de `now`
        XCTAssertEqual(record.weekStartDate, AdaptedProgramRecord.startOfCurrentWeek(now: now))
    }

    func testMarkStartedIsIdempotent() {
        let adapted = makeAdaptedFixture()
        let record = AdaptedProgramRecord(from: adapted, userId: UUID())
        let firstNow = Date(timeIntervalSince1970: 1_700_000_000)
        record.markStarted(now: firstNow)
        let posedDate = record.weekStartDate

        // 2ᵉ appel avec un autre `now` → no-op, date inchangée.
        let laterNow = Date(timeIntervalSince1970: 1_710_000_000)
        record.markStarted(now: laterNow)

        XCTAssertEqual(record.weekStartDate, posedDate)
    }

    func testRegenJournalEntryDecodesWithoutShiftGenerationDefaultsToZero() throws {
        // Cas rétro-compat : entries écrites avant Story 3.10 n'ont pas le champ
        // `shiftGeneration`. Le decode custom doit poser default 0.
        let legacyJSON = """
        {
          "id": "11111111-1111-1111-1111-111111111111",
          "userId": "22222222-2222-2222-2222-222222222222",
          "recordId": "33333333-3333-3333-3333-333333333333",
          "analyzedWeekNumber": 1,
          "targetWeekNumber": 2,
          "appliedAt": -978307200,
          "reason": "onTrack",
          "multiplier": 1.10,
          "pauseLevel": "none",
          "requiresRebuild": false,
          "affectedSessionIds": []
        }
        """.data(using: .utf8)!

        let entry = try JSONDecoder().decode(RegenJournalEntry.self, from: legacyJSON)
        XCTAssertEqual(entry.shiftGeneration, 0)
        XCTAssertEqual(entry.multiplier, 1.10, accuracy: 0.0001)
        XCTAssertEqual(entry.targetWeekNumber, 2)
    }

    func testRegenJournalEntryRoundTripPreservesShiftGeneration() throws {
        let original = RegenJournalEntry(
            userId: UUID(),
            recordId: UUID(),
            analyzedWeekNumber: 3,
            targetWeekNumber: 4,
            reason: .onTrack,
            multiplier: 1.0,
            pauseLevel: .none,
            requiresRebuild: false,
            affectedSessionIds: [UUID()],
            shiftGeneration: 7
        )
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(RegenJournalEntry.self, from: data)
        XCTAssertEqual(decoded.shiftGeneration, 7)
        XCTAssertEqual(decoded, original)
    }

    // MARK: - Helpers

    private func makeAdaptedFixture(
        weeksCount: Int = 2,
        sessionsPerWeek: Int = 3,
        requiresAIAssist: Bool = false,
        aiAssistReason: String? = nil,
        durationMode: ProgramDurationMode = .routineCyclic,
        targetDate: Date? = nil,
        appliedRules: [AppliedRule] = []
    ) -> AdaptedProgram {
        let weeks = (1...weeksCount).map { wn in
            AdaptedWeek(
                weekNumber: wn,
                theme: "Semaine \(wn)",
                goal: "Goal \(wn)",
                sessions: (1...sessionsPerWeek).map { day in
                    AdaptedSession(
                        day: day,
                        name: "Séance W\(wn)D\(day)",
                        durationMinutes: 30 + day * 5,
                        type: .endurance,
                        warmup: nil,
                        exercises: [
                            AdaptedExercise(
                                name: "Footing",
                                originalName: "Footing",
                                duration: "30 min",
                                targetZone: "Daniels-E",
                                volumeAxis: .duration
                            )
                        ],
                        cooldown: nil
                    )
                }
            )
        }
        return AdaptedProgram(
            templateId: "running-beginner-couch-to-5k",
            sport: .running,
            level: .beginner,
            appliedAt: Date(timeIntervalSince1970: 1_700_000_000),
            weeks: weeks,
            appliedRules: appliedRules,
            requiresAIAssist: requiresAIAssist,
            aiAssistReason: aiAssistReason,
            durationMode: durationMode,
            targetDate: targetDate
        )
    }
}
