// Coaching/Glossary/Glossary.swift
// Phase A — mini-glossaire de termes techniques affichés dans SessionDetailView
// (targetZone des AdaptedExercise). 18 entrées couvrant les familles principales
// utilisées par les 40 templates v2 : zones FC (Z1-5), allures Daniels (E/M/T/I/R),
// natation (EN1/2/3, CSS), vélo (FTP, Sweet-Spot), protocoles (AMRAP, EMOM, Tabata),
// effort (RPE, %1RM, VDOT).
//
// Pas un glossaire exhaustif sport-par-sport (V2 #1 — story dédiée 3-4j). Ici on
// vise les termes les plus opaques pour un user débutant.
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
