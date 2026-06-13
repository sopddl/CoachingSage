// CoachingSageTests/Session/SessionEnvironmentResolverTests.swift
// Chantier indoor/outdoor vélo (2026-06-10) — résolution variante de lieu à l'affichage.
import XCTest
import TemplateModel

final class SessionEnvironmentResolverTests: XCTestCase {

    // MARK: - Fixtures

    /// Séance template vélo : racine = outdoor native + 1 variante indoor.
    private func cyclingTemplateSession() -> TemplateSession {
        TemplateSession(
            day: 2,
            name: LocalizedText(fr: "Sortie découverte"),
            durationMinutes: 55,
            type: .endurance,
            warmup: LocalizedText(fr: "10 min souple"),
            exercises: [TemplateExercise(name: LocalizedText(fr: "Sortie route"), matchKey: "Sortie continue FTP-Z1")],
            cooldown: LocalizedText(fr: "5 min retour au calme"),
            environment: .outdoor,
            variants: [
                SessionVariant(
                    environment: .indoor,
                    name: LocalizedText(fr: "Home-trainer découverte"),
                    durationMinutes: 50,
                    warmup: LocalizedText(fr: "10 min résistance min"),
                    exercises: [TemplateExercise(name: LocalizedText(fr: "Pédalage continu"), matchKey: "Sortie continue FTP-Z1")],
                    cooldown: LocalizedText(fr: "5 min léger")
                )
            ]
        )
    }

    private func adaptedOutdoor() -> AdaptedSession {
        AdaptedSession(
            day: 2,
            name: LocalizedText(fr: "Sortie découverte"),
            durationMinutes: 55,
            type: .endurance,
            warmup: LocalizedText(fr: "10 min souple"),
            exercises: [AdaptedExercise(name: LocalizedText(fr: "Sortie route"), originalName: "Sortie continue FTP-Z1")],
            cooldown: LocalizedText(fr: "5 min retour au calme")
        )
    }

    // MARK: - effectiveEnvironment

    func testOverrideWinsOverEverything() {
        let env = SessionEnvironmentResolver.effectiveEnvironment(
            native: .outdoor, sessionOverride: .indoor, programDefault: "outdoor")
        XCTAssertEqual(env, .indoor)
    }

    func testProgramDefaultAppliesWhenNoOverride() {
        let env = SessionEnvironmentResolver.effectiveEnvironment(
            native: .outdoor, sessionOverride: nil, programDefault: "indoor")
        XCTAssertEqual(env, .indoor)
    }

    func testBothAndNilFallBackToNative() {
        XCTAssertEqual(SessionEnvironmentResolver.effectiveEnvironment(
            native: .outdoor, sessionOverride: nil, programDefault: "both"), .outdoor)
        XCTAssertEqual(SessionEnvironmentResolver.effectiveEnvironment(
            native: .outdoor, sessionOverride: nil, programDefault: nil), .outdoor)
        XCTAssertEqual(SessionEnvironmentResolver.effectiveEnvironment(
            native: .indoor, sessionOverride: nil, programDefault: "garbage"), .indoor)
    }

    // MARK: - displaySession

    func testNativeReturnsAdaptedUnchanged() {
        let adapted = adaptedOutdoor()
        let out = SessionEnvironmentResolver.displaySession(
            adapted: adapted, templateSession: cyclingTemplateSession(), effective: .outdoor)
        XCTAssertEqual(out, adapted) // native = contenu adapté inchangé (zéro régression)
    }

    func testAlternateBuildsFromVariant() {
        let out = SessionEnvironmentResolver.displaySession(
            adapted: adaptedOutdoor(), templateSession: cyclingTemplateSession(), effective: .indoor)
        XCTAssertEqual(out.name.fr, "Home-trainer découverte")
        XCTAssertEqual(out.durationMinutes, 50)
        XCTAssertEqual(out.day, 2)            // day conservé depuis l'adaptée
        XCTAssertEqual(out.type, .endurance)  // type conservé (absent de SessionVariant)
        XCTAssertEqual(out.exercises.first?.name.fr, "Pédalage continu")
        XCTAssertEqual(out.exercises.first?.originalName, "Sortie continue FTP-Z1") // stableMatchKey
    }

    func testMonoSessionReturnsAdapted() {
        let mono = TemplateSession(day: 1, name: LocalizedText(fr: "Course"), durationMinutes: 30,
                                   type: .endurance, warmup: nil, exercises: [], cooldown: nil)
        let adapted = adaptedOutdoor()
        let out = SessionEnvironmentResolver.displaySession(adapted: adapted, templateSession: mono, effective: .indoor)
        XCTAssertEqual(out, adapted)
    }

    // MARK: - filteringOffBikeStrength (2A — renfo indoor only)

    /// Séance vélo « mixte » : pédalage + 3 exos de renfo hors-vélo. `originalName` = les
    /// `match_key` réels du template (le resolver classe sur cette clé stable).
    private func mixedAdaptedSession() -> AdaptedSession {
        AdaptedSession(
            day: 5,
            name: LocalizedText(fr: "Sortie endurance — 45 min + renforcement"),
            durationMinutes: 70,
            type: .mixed,
            warmup: LocalizedText(fr: "10 min souple"),
            exercises: [
                AdaptedExercise(name: LocalizedText(fr: "Sortie tranquille"), originalName: "Sortie continue FTP-Z2"),
                AdaptedExercise(name: LocalizedText(fr: "Planche ventrale"), originalName: "Planche ventrale"),
                AdaptedExercise(name: LocalizedText(fr: "Pont fessier (deux jambes)"), originalName: "Pont fessier bipodal"),
                AdaptedExercise(name: LocalizedText(fr: "Mollets debout (deux pieds)"), originalName: "Calf raises bipodal")
            ],
            cooldown: LocalizedText(fr: "5 min retour au calme")
        )
    }

    func testOutdoorCyclingStripsRenfoKeepsPedaling() {
        let out = SessionEnvironmentResolver.filteringOffBikeStrength(
            mixedAdaptedSession(), sport: .cycling, effective: .outdoor)
        XCTAssertEqual(out.exercises.count, 1)
        XCTAssertEqual(out.exercises.first?.originalName, "Sortie continue FTP-Z2") // le pédalage reste
        XCTAssertEqual(out.type, .endurance) // « mixte » sans renfo → requalifiée endurance (why-panel)
    }

    func testIndoorCyclingKeepsRenfo() {
        let session = mixedAdaptedSession()
        let out = SessionEnvironmentResolver.filteringOffBikeStrength(
            session, sport: .cycling, effective: .indoor)
        XCTAssertEqual(out, session) // home-trainer : renfo gardé (no-op)
    }

    func testNonCyclingNeverFiltered() {
        let session = mixedAdaptedSession()
        let out = SessionEnvironmentResolver.filteringOffBikeStrength(
            session, sport: .running, effective: .outdoor)
        XCTAssertEqual(out, session) // le filtre ne touche que le vélo
    }

    func testOutdoorCyclingPureRideUnchanged() {
        let ride = adaptedOutdoor() // un seul exo de pédalage, aucun renfo
        let out = SessionEnvironmentResolver.filteringOffBikeStrength(
            ride, sport: .cycling, effective: .outdoor)
        XCTAssertEqual(out, ride) // rien à retirer → identité
    }

    func testOutdoorCyclingMixedWithoutRenfoStillRequalifiedEndurance() {
        // Cas réel post-fix-template : le natif outdoor n'a plus QUE le pédalage mais son
        // `type` template reste « mixed » (partagé avec l'indoor) → le why-panel disait
        // encore « mixte ». On requalifie en endurance même sans exo à retirer.
        let pedalingOnlyMixed = AdaptedSession(
            day: 5, name: LocalizedText(fr: "Sortie endurance — 45 min"), durationMinutes: 58,
            type: .mixed, warmup: LocalizedText(fr: "10 min souple"),
            exercises: [AdaptedExercise(name: LocalizedText(fr: "Sortie tranquille"), originalName: "Sortie continue FTP-Z2")],
            cooldown: LocalizedText(fr: "5 min retour au calme"))
        let out = SessionEnvironmentResolver.filteringOffBikeStrength(
            pedalingOnlyMixed, sport: .cycling, effective: .outdoor)
        XCTAssertEqual(out.exercises.count, 1)           // rien retiré (déjà propre)
        XCTAssertEqual(out.type, .endurance)             // mais requalifiée endurance
    }

    func testNeverEmptiesSession() {
        // Cas défensif : une séance 100% renfo ne doit pas se vider en outdoor.
        let allRenfo = AdaptedSession(
            day: 5, name: LocalizedText(fr: "Renfo"), durationMinutes: 20, type: .strength, warmup: nil,
            exercises: [AdaptedExercise(name: LocalizedText(fr: "Planche"), originalName: "Planche ventrale")],
            cooldown: nil)
        let out = SessionEnvironmentResolver.filteringOffBikeStrength(
            allRenfo, sport: .cycling, effective: .outdoor)
        XCTAssertEqual(out, allRenfo) // jamais vide → on rend l'original
    }

    // MARK: - flipTarget

    func testFlipTarget() {
        let ts = cyclingTemplateSession()
        XCTAssertEqual(SessionEnvironmentResolver.flipTarget(from: .outdoor, templateSession: ts), .indoor)
        XCTAssertEqual(SessionEnvironmentResolver.flipTarget(from: .indoor, templateSession: ts), .outdoor)
    }

    func testFlipTargetNilForMonoSession() {
        let mono = TemplateSession(day: 1, name: LocalizedText(fr: "Course"), durationMinutes: 30,
                                   type: .endurance, warmup: nil, exercises: [], cooldown: nil)
        XCTAssertNil(SessionEnvironmentResolver.flipTarget(from: .outdoor, templateSession: mono))
    }
}
