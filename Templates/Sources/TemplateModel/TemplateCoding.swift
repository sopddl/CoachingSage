import Foundation

public enum TemplateCoding {
    /// Schema 2 — Story 3.3a : ajout des hooks `target_zone`, `required_equipment`,
    /// `incompatible_constraints`, `alternatives`, `volume_axis` sur `TemplateExercise`.
    public static let currentSchemaVersion = 2

    public static func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }

    public static func makeEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        return encoder
    }

    public static func decode(_ data: Data) throws -> ProgramTemplate {
        try makeDecoder().decode(ProgramTemplate.self, from: data)
    }

    public static func encode(_ template: ProgramTemplate) throws -> Data {
        try makeEncoder().encode(template)
    }
}

public enum TemplateValidationError: Error, CustomStringConvertible, Equatable {
    case schemaVersionMismatch(expected: Int, got: Int)
    case weekCountMismatch(declared: Int, actual: Int)
    case duplicateWeekNumber(Int)
    case sessionCountExceedsDeclared(weekNumber: Int, declared: Int, actual: Int)
    case duplicateDayInWeek(weekNumber: Int, day: Int)
    case emptyField(String)
    case invalidRange(String)

    public var description: String {
        switch self {
        case .schemaVersionMismatch(let expected, let got):
            return "schema_version mismatch: expected \(expected), got \(got)"
        case .weekCountMismatch(let declared, let actual):
            return "duration_weeks=\(declared) mais \(actual) TemplateWeek fournis"
        case .duplicateWeekNumber(let n):
            return "week_number \(n) apparaît plusieurs fois"
        case .sessionCountExceedsDeclared(let wn, let declared, let actual):
            return "semaine \(wn) : sessions_per_week=\(declared) mais \(actual) sessions fournies"
        case .duplicateDayInWeek(let wn, let day):
            return "semaine \(wn) : day \(day) apparaît plusieurs fois"
        case .emptyField(let f):
            return "champ obligatoire vide : \(f)"
        case .invalidRange(let msg):
            return "valeur hors range : \(msg)"
        }
    }
}

public enum TemplateValidator {
    public static func validate(_ t: ProgramTemplate) throws {
        guard t.schemaVersion == TemplateCoding.currentSchemaVersion else {
            throw TemplateValidationError.schemaVersionMismatch(
                expected: TemplateCoding.currentSchemaVersion, got: t.schemaVersion
            )
        }
        guard !t.id.isEmpty else { throw TemplateValidationError.emptyField("id") }
        guard !t.name.canonical.isEmpty else { throw TemplateValidationError.emptyField("name") }
        guard t.durationWeeks >= 1 && t.durationWeeks <= 52 else {
            throw TemplateValidationError.invalidRange("duration_weeks doit être 1..52, got \(t.durationWeeks)")
        }
        guard t.sessionsPerWeek >= 1 && t.sessionsPerWeek <= 14 else {
            throw TemplateValidationError.invalidRange("sessions_per_week doit être 1..14, got \(t.sessionsPerWeek)")
        }
        guard t.weeks.count == t.durationWeeks else {
            throw TemplateValidationError.weekCountMismatch(declared: t.durationWeeks, actual: t.weeks.count)
        }

        var seenWeekNumbers = Set<Int>()
        for week in t.weeks {
            if !seenWeekNumbers.insert(week.weekNumber).inserted {
                throw TemplateValidationError.duplicateWeekNumber(week.weekNumber)
            }
            let active = week.sessions.filter { $0.type != .rest }
            // sessions_per_week = cadence moyenne. Une semaine peak/taper/tournoi peut
            // ajouter 1 session de transition (match, review post-tournoi, etc.). On tolère +1
            // mais on garde le garde-fou contre les vrais bugs de saisie.
            if active.count > t.sessionsPerWeek + 1 {
                throw TemplateValidationError.sessionCountExceedsDeclared(
                    weekNumber: week.weekNumber,
                    declared: t.sessionsPerWeek,
                    actual: active.count
                )
            }
            var seenDays = Set<Int>()
            for s in week.sessions {
                if !seenDays.insert(s.day).inserted {
                    throw TemplateValidationError.duplicateDayInWeek(weekNumber: week.weekNumber, day: s.day)
                }
                guard s.day >= 1 && s.day <= 7 else {
                    throw TemplateValidationError.invalidRange("day doit être 1..7, got \(s.day) en semaine \(week.weekNumber)")
                }
            }
        }
    }
}
