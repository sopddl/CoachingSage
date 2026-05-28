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
    /// Codes sport auxquels ce terme s'applique (utilisés par GlossaryIndexView pour le filtre).
    /// Vide = générique multi-sport (affiché dans toutes les sections).
    public let sportCodes: [String]

    public init(id: String, titleKey: String, definitionKey: String, sportCodes: [String] = []) {
        self.id = id
        self.titleKey = titleKey
        self.definitionKey = definitionKey
        self.sportCodes = sportCodes
    }
}

public enum Glossary {
    /// Codes sport canoniques (alignés `SportCode` enum). Story 3.26.
    public enum Sport {
        public static let running = "running"
        public static let cycling = "cycling"
        public static let swimming = "swimming"
        public static let triathlon = "triathlon"
        public static let strengthTraining = "strength_training"
        public static let yoga = "yoga"
        public static let hiit = "hiit"
        public static let hiking = "hiking"
        public static let tennis = "tennis"
        public static let football = "football"

        /// Tous les sports — utilisé pour les termes universels (RPE, zones FC).
        public static let all: [String] = [running, cycling, swimming, triathlon,
                                           strengthTraining, yoga, hiit, hiking,
                                           tennis, football]
    }

    public static let entries: [GlossaryEntry] = [
        // Effort universel
        GlossaryEntry(id: "rpe",        titleKey: "glossary.rpe.title",        definitionKey: "glossary.rpe.definition",
                      sportCodes: Sport.all),
        // Strength
        GlossaryEntry(id: "1rm",        titleKey: "glossary.1rm.title",        definitionKey: "glossary.1rm.definition",
                      sportCodes: [Sport.strengthTraining]),
        // Zones FC multi-sport
        GlossaryEntry(id: "zones",      titleKey: "glossary.zones.title",      definitionKey: "glossary.zones.definition",
                      sportCodes: [Sport.running, Sport.cycling, Sport.swimming, Sport.triathlon, Sport.hiit]),
        // Daniels (running pur)
        GlossaryEntry(id: "daniels.e",  titleKey: "glossary.daniels.e.title",  definitionKey: "glossary.daniels.e.definition",
                      sportCodes: [Sport.running]),
        GlossaryEntry(id: "daniels.m",  titleKey: "glossary.daniels.m.title",  definitionKey: "glossary.daniels.m.definition",
                      sportCodes: [Sport.running]),
        GlossaryEntry(id: "daniels.t",  titleKey: "glossary.daniels.t.title",  definitionKey: "glossary.daniels.t.definition",
                      sportCodes: [Sport.running]),
        GlossaryEntry(id: "daniels.i",  titleKey: "glossary.daniels.i.title",  definitionKey: "glossary.daniels.i.definition",
                      sportCodes: [Sport.running]),
        GlossaryEntry(id: "daniels.r",  titleKey: "glossary.daniels.r.title",  definitionKey: "glossary.daniels.r.definition",
                      sportCodes: [Sport.running]),
        GlossaryEntry(id: "vdot",       titleKey: "glossary.vdot.title",       definitionKey: "glossary.vdot.definition",
                      sportCodes: [Sport.running]),
        // Swimming
        GlossaryEntry(id: "en",         titleKey: "glossary.en.title",         definitionKey: "glossary.en.definition",
                      sportCodes: [Sport.swimming]),
        GlossaryEntry(id: "css",        titleKey: "glossary.css.title",        definitionKey: "glossary.css.definition",
                      sportCodes: [Sport.swimming]),
        // Cycling
        GlossaryEntry(id: "ftp",        titleKey: "glossary.ftp.title",        definitionKey: "glossary.ftp.definition",
                      sportCodes: [Sport.cycling]),
        GlossaryEntry(id: "sweetspot",  titleKey: "glossary.sweetspot.title",  definitionKey: "glossary.sweetspot.definition",
                      sportCodes: [Sport.cycling]),
        // Protocoles HIIT / strength
        GlossaryEntry(id: "amrap",      titleKey: "glossary.amrap.title",      definitionKey: "glossary.amrap.definition",
                      sportCodes: [Sport.hiit, Sport.strengthTraining]),
        GlossaryEntry(id: "emom",       titleKey: "glossary.emom.title",       definitionKey: "glossary.emom.definition",
                      sportCodes: [Sport.hiit, Sport.strengthTraining]),
        GlossaryEntry(id: "tabata",     titleKey: "glossary.tabata.title",     definitionKey: "glossary.tabata.definition",
                      sportCodes: [Sport.hiit]),
        // Race pace running
        GlossaryEntry(id: "hmp",        titleKey: "glossary.hmp.title",        definitionKey: "glossary.hmp.definition",
                      sportCodes: [Sport.running]),
        GlossaryEntry(id: "race.pace",  titleKey: "glossary.race.pace.title",  definitionKey: "glossary.race.pace.definition",
                      sportCodes: [Sport.running]),
        // Story 3.17 Phase 1 — +11 termes opaques sourcés audit templates.
        GlossaryEntry(id: "cadence",    titleKey: "glossary.cadence.title",    definitionKey: "glossary.cadence.definition",
                      sportCodes: [Sport.running, Sport.cycling, Sport.swimming]),
        GlossaryEntry(id: "tempo",      titleKey: "glossary.tempo.title",      definitionKey: "glossary.tempo.definition",
                      sportCodes: [Sport.running, Sport.cycling, Sport.swimming]),
        GlossaryEntry(id: "threshold",  titleKey: "glossary.threshold.title",  definitionKey: "glossary.threshold.definition",
                      sportCodes: [Sport.running, Sport.cycling, Sport.swimming]),
        GlossaryEntry(id: "vo2max",     titleKey: "glossary.vo2max.title",     definitionKey: "glossary.vo2max.definition",
                      sportCodes: [Sport.running, Sport.cycling, Sport.swimming, Sport.hiit]),
        GlossaryEntry(id: "intervals",  titleKey: "glossary.intervals.title",  definitionKey: "glossary.intervals.definition",
                      sportCodes: [Sport.running, Sport.cycling, Sport.swimming, Sport.hiit]),
        GlossaryEntry(id: "strides",    titleKey: "glossary.strides.title",    definitionKey: "glossary.strides.definition",
                      sportCodes: [Sport.running]),
        GlossaryEntry(id: "fartlek",    titleKey: "glossary.fartlek.title",    definitionKey: "glossary.fartlek.definition",
                      sportCodes: [Sport.running]),
        GlossaryEntry(id: "plyometric", titleKey: "glossary.plyometric.title", definitionKey: "glossary.plyometric.definition",
                      sportCodes: [Sport.strengthTraining, Sport.hiit]),
        GlossaryEntry(id: "hypertrophy",titleKey: "glossary.hypertrophy.title",definitionKey: "glossary.hypertrophy.definition",
                      sportCodes: [Sport.strengthTraining]),
        GlossaryEntry(id: "lactate",    titleKey: "glossary.lactate.title",    definitionKey: "glossary.lactate.definition",
                      sportCodes: [Sport.running, Sport.cycling, Sport.swimming, Sport.hiit]),
        GlossaryEntry(id: "pushoff",    titleKey: "glossary.pushoff.title",    definitionKey: "glossary.pushoff.definition",
                      sportCodes: [Sport.swimming]),
        // Story 3.19 — terme strength fréquent (plank / planche / gainage).
        GlossaryEntry(id: "plank",      titleKey: "glossary.plank.title",      definitionKey: "glossary.plank.definition",
                      sportCodes: [Sport.strengthTraining, Sport.yoga, Sport.hiit]),
        // Story 3.19 Jalon 2 — mot opaque universel sports cardio (running, swim, cycle).
        GlossaryEntry(id: "drill",      titleKey: "glossary.drill.title",      definitionKey: "glossary.drill.definition",
                      sportCodes: [Sport.running, Sport.cycling, Sport.swimming, Sport.tennis, Sport.football]),
        // Story 3.24a — 10 termes strength + mobilité non glossariés (test simu Sophie 2026-05-24).
        GlossaryEntry(id: "rir",            titleKey: "glossary.rir.title",            definitionKey: "glossary.rir.definition",
                      sportCodes: [Sport.strengthTraining]),
        GlossaryEntry(id: "cars",           titleKey: "glossary.cars.title",           definitionKey: "glossary.cars.definition",
                      sportCodes: [Sport.strengthTraining, Sport.yoga]),
        GlossaryEntry(id: "scapular",       titleKey: "glossary.scapular.title",       definitionKey: "glossary.scapular.definition",
                      sportCodes: [Sport.strengthTraining]),
        GlossaryEntry(id: "thoracic",       titleKey: "glossary.thoracic.title",       definitionKey: "glossary.thoracic.definition",
                      sportCodes: [Sport.strengthTraining, Sport.yoga]),
        GlossaryEntry(id: "bandpullapart",  titleKey: "glossary.bandpullapart.title",  definitionKey: "glossary.bandpullapart.definition",
                      sportCodes: [Sport.strengthTraining]),
        GlossaryEntry(id: "dislocation",    titleKey: "glossary.dislocation.title",    definitionKey: "glossary.dislocation.definition",
                      sportCodes: [Sport.strengthTraining]),
        GlossaryEntry(id: "catcow",         titleKey: "glossary.catcow.title",         definitionKey: "glossary.catcow.definition",
                      sportCodes: [Sport.strengthTraining, Sport.yoga]),
        GlossaryEntry(id: "rampup",         titleKey: "glossary.rampup.title",         definitionKey: "glossary.rampup.definition",
                      sportCodes: [Sport.strengthTraining]),
        GlossaryEntry(id: "barrevide",      titleKey: "glossary.barrevide.title",      definitionKey: "glossary.barrevide.definition",
                      sportCodes: [Sport.strengthTraining]),
        GlossaryEntry(id: "reps",           titleKey: "glossary.reps.title",           definitionKey: "glossary.reps.definition",
                      sportCodes: [Sport.strengthTraining, Sport.hiit]),
        // Story 3.26 Phase A — 27 termes sport-spécifiques.
        // Yoga (8)
        GlossaryEntry(id: "yoga.asana",         titleKey: "glossary.yoga.asana.title",         definitionKey: "glossary.yoga.asana.definition",        sportCodes: [Sport.yoga]),
        GlossaryEntry(id: "yoga.vinyasa",       titleKey: "glossary.yoga.vinyasa.title",       definitionKey: "glossary.yoga.vinyasa.definition",      sportCodes: [Sport.yoga]),
        GlossaryEntry(id: "yoga.pranayama",     titleKey: "glossary.yoga.pranayama.title",     definitionKey: "glossary.yoga.pranayama.definition",    sportCodes: [Sport.yoga]),
        GlossaryEntry(id: "yoga.mudra",         titleKey: "glossary.yoga.mudra.title",         definitionKey: "glossary.yoga.mudra.definition",        sportCodes: [Sport.yoga]),
        GlossaryEntry(id: "yoga.savasana",      titleKey: "glossary.yoga.savasana.title",      definitionKey: "glossary.yoga.savasana.definition",     sportCodes: [Sport.yoga]),
        GlossaryEntry(id: "yoga.drishti",       titleKey: "glossary.yoga.drishti.title",       definitionKey: "glossary.yoga.drishti.definition",      sportCodes: [Sport.yoga]),
        GlossaryEntry(id: "yoga.bandha",        titleKey: "glossary.yoga.bandha.title",        definitionKey: "glossary.yoga.bandha.definition",       sportCodes: [Sport.yoga]),
        GlossaryEntry(id: "yoga.suryanamaskar", titleKey: "glossary.yoga.suryanamaskar.title", definitionKey: "glossary.yoga.suryanamaskar.definition", sportCodes: [Sport.yoga]),
        // Tennis (5)
        GlossaryEntry(id: "tennis.slice",       titleKey: "glossary.tennis.slice.title",       definitionKey: "glossary.tennis.slice.definition",      sportCodes: [Sport.tennis]),
        GlossaryEntry(id: "tennis.topspin",     titleKey: "glossary.tennis.topspin.title",     definitionKey: "glossary.tennis.topspin.definition",    sportCodes: [Sport.tennis]),
        GlossaryEntry(id: "tennis.kickserve",   titleKey: "glossary.tennis.kickserve.title",   definitionKey: "glossary.tennis.kickserve.definition",  sportCodes: [Sport.tennis]),
        GlossaryEntry(id: "tennis.footwork",    titleKey: "glossary.tennis.footwork.title",    definitionKey: "glossary.tennis.footwork.definition",   sportCodes: [Sport.tennis]),
        GlossaryEntry(id: "tennis.splitstep",   titleKey: "glossary.tennis.splitstep.title",   definitionKey: "glossary.tennis.splitstep.definition",  sportCodes: [Sport.tennis]),
        // Football (4)
        GlossaryEntry(id: "football.sprintrepete", titleKey: "glossary.football.sprintrepete.title", definitionKey: "glossary.football.sprintrepete.definition", sportCodes: [Sport.football]),
        GlossaryEntry(id: "football.unetouche",    titleKey: "glossary.football.unetouche.title",    definitionKey: "glossary.football.unetouche.definition",    sportCodes: [Sport.football]),
        GlossaryEntry(id: "football.transition",   titleKey: "glossary.football.transition.title",   definitionKey: "glossary.football.transition.definition",   sportCodes: [Sport.football]),
        GlossaryEntry(id: "football.rsa",          titleKey: "glossary.football.rsa.title",          definitionKey: "glossary.football.rsa.definition",          sportCodes: [Sport.football]),
        // Hiking (4)
        GlossaryEntry(id: "hiking.denivele",    titleKey: "glossary.hiking.denivele.title",    definitionKey: "glossary.hiking.denivele.definition",   sportCodes: [Sport.hiking]),
        GlossaryEntry(id: "hiking.elevation",   titleKey: "glossary.hiking.elevation.title",   definitionKey: "glossary.hiking.elevation.definition",  sportCodes: [Sport.hiking]),
        GlossaryEntry(id: "hiking.switchback",  titleKey: "glossary.hiking.switchback.title",  definitionKey: "glossary.hiking.switchback.definition", sportCodes: [Sport.hiking]),
        GlossaryEntry(id: "hiking.terrainpace", titleKey: "glossary.hiking.terrainpace.title", definitionKey: "glossary.hiking.terrainpace.definition", sportCodes: [Sport.hiking]),
        // Triathlon (3)
        GlossaryEntry(id: "triathlon.t1",       titleKey: "glossary.triathlon.t1.title",       definitionKey: "glossary.triathlon.t1.definition",      sportCodes: [Sport.triathlon]),
        GlossaryEntry(id: "triathlon.t2",       titleKey: "glossary.triathlon.t2.title",       definitionKey: "glossary.triathlon.t2.definition",      sportCodes: [Sport.triathlon]),
        GlossaryEntry(id: "triathlon.brick",    titleKey: "glossary.triathlon.brick.title",    definitionKey: "glossary.triathlon.brick.definition",   sportCodes: [Sport.triathlon]),
        // HIIT (3)
        GlossaryEntry(id: "hiit.workrest",      titleKey: "glossary.hiit.workrest.title",      definitionKey: "glossary.hiit.workrest.definition",     sportCodes: [Sport.hiit]),
        GlossaryEntry(id: "hiit.epoc",          titleKey: "glossary.hiit.epoc.title",          definitionKey: "glossary.hiit.epoc.definition",         sportCodes: [Sport.hiit]),
        GlossaryEntry(id: "hiit.microinterval", titleKey: "glossary.hiit.microinterval.title", definitionKey: "glossary.hiit.microinterval.definition", sportCodes: [Sport.hiit]),
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
