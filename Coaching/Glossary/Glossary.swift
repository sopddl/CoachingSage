// Coaching/Glossary/Glossary.swift
// Phase A — mini-glossaire de termes techniques affichés dans SessionDetailView.
// Story 3.17 (2026-05-22) — étendu à 29 entrées + API `matches(in:)` pour détecter
// les termes inline dans tout texte (notes exercices, warmup, cooldown, theme).
//
// Familles couvertes :
// - Zones FC (Z1-5), allures Daniels (E/M/T/I/R, VDOT, HMP)
// - Natation : EN1-3, CSS, push-off
// - Vélo : FTP, Sweet-Spot
// - Protocoles : AMRAP, EMOM, Tabata, intervals (générique), fartlek, strides
// - Effort : RPE, %1RM, race.pace
// - Physio : VO2max, lactate, threshold (générique)
// - Strength : hypertrophy, plyometric
// - Multi-sport : tempo (générique), cadence (run/cycle/swim)
import Foundation

public struct GlossaryEntry: Identifiable, Equatable, Sendable {
    public let id: String
    public let titleKey: String
    public let definitionKey: String

    public init(id: String, titleKey: String, definitionKey: String) {
        self.id = id
        self.titleKey = titleKey
        self.definitionKey = definitionKey
    }
}

public enum Glossary {
    public static let entries: [GlossaryEntry] = [
        GlossaryEntry(id: "rpe",        titleKey: "glossary.rpe.title",        definitionKey: "glossary.rpe.definition"),
        GlossaryEntry(id: "1rm",        titleKey: "glossary.1rm.title",        definitionKey: "glossary.1rm.definition"),
        GlossaryEntry(id: "zones",      titleKey: "glossary.zones.title",      definitionKey: "glossary.zones.definition"),
        GlossaryEntry(id: "daniels.e",  titleKey: "glossary.daniels.e.title",  definitionKey: "glossary.daniels.e.definition"),
        GlossaryEntry(id: "daniels.m",  titleKey: "glossary.daniels.m.title",  definitionKey: "glossary.daniels.m.definition"),
        GlossaryEntry(id: "daniels.t",  titleKey: "glossary.daniels.t.title",  definitionKey: "glossary.daniels.t.definition"),
        GlossaryEntry(id: "daniels.i",  titleKey: "glossary.daniels.i.title",  definitionKey: "glossary.daniels.i.definition"),
        GlossaryEntry(id: "daniels.r",  titleKey: "glossary.daniels.r.title",  definitionKey: "glossary.daniels.r.definition"),
        GlossaryEntry(id: "vdot",       titleKey: "glossary.vdot.title",       definitionKey: "glossary.vdot.definition"),
        GlossaryEntry(id: "en",         titleKey: "glossary.en.title",         definitionKey: "glossary.en.definition"),
        GlossaryEntry(id: "css",        titleKey: "glossary.css.title",        definitionKey: "glossary.css.definition"),
        GlossaryEntry(id: "ftp",        titleKey: "glossary.ftp.title",        definitionKey: "glossary.ftp.definition"),
        GlossaryEntry(id: "sweetspot",  titleKey: "glossary.sweetspot.title",  definitionKey: "glossary.sweetspot.definition"),
        GlossaryEntry(id: "amrap",      titleKey: "glossary.amrap.title",      definitionKey: "glossary.amrap.definition"),
        GlossaryEntry(id: "emom",       titleKey: "glossary.emom.title",       definitionKey: "glossary.emom.definition"),
        GlossaryEntry(id: "tabata",     titleKey: "glossary.tabata.title",     definitionKey: "glossary.tabata.definition"),
        GlossaryEntry(id: "hmp",        titleKey: "glossary.hmp.title",        definitionKey: "glossary.hmp.definition"),
        GlossaryEntry(id: "race.pace",  titleKey: "glossary.race.pace.title",  definitionKey: "glossary.race.pace.definition"),
        // Story 3.17 Phase 1 — +11 termes opaques sourcés audit templates.
        GlossaryEntry(id: "cadence",    titleKey: "glossary.cadence.title",    definitionKey: "glossary.cadence.definition"),
        GlossaryEntry(id: "tempo",      titleKey: "glossary.tempo.title",      definitionKey: "glossary.tempo.definition"),
        GlossaryEntry(id: "threshold",  titleKey: "glossary.threshold.title",  definitionKey: "glossary.threshold.definition"),
        GlossaryEntry(id: "vo2max",     titleKey: "glossary.vo2max.title",     definitionKey: "glossary.vo2max.definition"),
        GlossaryEntry(id: "intervals",  titleKey: "glossary.intervals.title",  definitionKey: "glossary.intervals.definition"),
        GlossaryEntry(id: "strides",    titleKey: "glossary.strides.title",    definitionKey: "glossary.strides.definition"),
        GlossaryEntry(id: "fartlek",    titleKey: "glossary.fartlek.title",    definitionKey: "glossary.fartlek.definition"),
        GlossaryEntry(id: "plyometric", titleKey: "glossary.plyometric.title", definitionKey: "glossary.plyometric.definition"),
        GlossaryEntry(id: "hypertrophy",titleKey: "glossary.hypertrophy.title",definitionKey: "glossary.hypertrophy.definition"),
        GlossaryEntry(id: "lactate",    titleKey: "glossary.lactate.title",    definitionKey: "glossary.lactate.definition"),
        GlossaryEntry(id: "pushoff",    titleKey: "glossary.pushoff.title",    definitionKey: "glossary.pushoff.definition"),
        // Story 3.19 — terme strength fréquent (plank / planche / gainage).
        GlossaryEntry(id: "plank",      titleKey: "glossary.plank.title",      definitionKey: "glossary.plank.definition"),
        // Story 3.19 Jalon 2 — mot opaque universel sports cardio (running, swim, cycle).
        GlossaryEntry(id: "drill",      titleKey: "glossary.drill.title",      definitionKey: "glossary.drill.definition"),
        // Story 3.24a — 10 termes strength + mobilité non glossariés (test simu Sophie 2026-05-24).
        // RIR, CARs, scapular, mobilité thoracique, band pull apart, dislocations, cat-cow, ramp up, barre vide, reps.
        GlossaryEntry(id: "rir",            titleKey: "glossary.rir.title",            definitionKey: "glossary.rir.definition"),
        GlossaryEntry(id: "cars",           titleKey: "glossary.cars.title",           definitionKey: "glossary.cars.definition"),
        GlossaryEntry(id: "scapular",       titleKey: "glossary.scapular.title",       definitionKey: "glossary.scapular.definition"),
        GlossaryEntry(id: "thoracic",       titleKey: "glossary.thoracic.title",       definitionKey: "glossary.thoracic.definition"),
        GlossaryEntry(id: "bandpullapart",  titleKey: "glossary.bandpullapart.title",  definitionKey: "glossary.bandpullapart.definition"),
        GlossaryEntry(id: "dislocation",    titleKey: "glossary.dislocation.title",    definitionKey: "glossary.dislocation.definition"),
        GlossaryEntry(id: "catcow",         titleKey: "glossary.catcow.title",         definitionKey: "glossary.catcow.definition"),
        GlossaryEntry(id: "rampup",         titleKey: "glossary.rampup.title",         definitionKey: "glossary.rampup.definition"),
        GlossaryEntry(id: "barrevide",      titleKey: "glossary.barrevide.title",      definitionKey: "glossary.barrevide.definition"),
        GlossaryEntry(id: "reps",           titleKey: "glossary.reps.title",           definitionKey: "glossary.reps.definition"),
    ]

    private static let byId: [String: GlossaryEntry] = Dictionary(
        uniqueKeysWithValues: entries.map { ($0.id, $0) }
    )

    /// Matche un `targetZone` brut (ex: "Daniels-E", "Z2-cardiac", "RPE 7-8",
    /// "FTP-Z3", "CSS+5s/100m", "%1RM 75-80%", "@HMP") à une entrée glossaire.
    /// Renvoie nil si aucun terme connu n'est trouvé.
    public static func entry(forZone raw: String?) -> GlossaryEntry? {
        guard let raw, !raw.isEmpty else { return nil }
        let lower = raw.lowercased()

        // Patterns prioritaires (sport-specific avant générique)
        if lower.contains("daniels-e") { return byId["daniels.e"] }
        if lower.contains("daniels-m") { return byId["daniels.m"] }
        if lower.contains("daniels-t") { return byId["daniels.t"] }
        if lower.contains("daniels-i") { return byId["daniels.i"] }
        if lower.contains("daniels-r") { return byId["daniels.r"] }
        if lower.contains("vdot")      { return byId["vdot"] }
        if lower.contains("css")       { return byId["css"] }
        if lower.contains("ftp")       { return byId["ftp"] }
        if lower.contains("sweet")     { return byId["sweetspot"] }
        if lower.contains("amrap")     { return byId["amrap"] }
        if lower.contains("emom")      { return byId["emom"] }
        if lower.contains("tabata")    { return byId["tabata"] }
        if lower.contains("hmp") || lower.contains("@hmp") { return byId["hmp"] }
        if lower.contains("rpe")       { return byId["rpe"] }
        if lower.contains("1rm")       { return byId["1rm"] }
        if lower.hasPrefix("en")       { return byId["en"] }
        if lower.contains("5k-pace") || lower.contains("10k-pace") { return byId["race.pace"] }

        // Zones FC génériques Z1-Z5 (matche "Z1", "Z2-cardiac", "Z3 haute", etc.)
        if let first = lower.first, first == "z",
           lower.count >= 2,
           lower[lower.index(after: lower.startIndex)].isNumber {
            return byId["zones"]
        }

        return nil
    }
}
