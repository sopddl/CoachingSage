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
