// Coaching/Persistence/AdaptedProgramRecord.swift
// Story 3.8 — persistance SwiftData de l'`AdaptedProgram` retourné par Story 3.3a.
// Avant 3.8, l'AdaptedProgram restait en mémoire (state SessionView). 3.8 le persiste
// pour que le dashboard Séances puisse calculer la prochaine séance, le tri par date,
// le drag&drop hebdo, et la complétion.
//
// Pattern strict CoachingSportProfile : @Model + champs `xxxJsonData: Data` privés
// pour les structs Codable, computed getter/setter pour l'API publique
// (lesson lessons_swiftdata #1).
import Foundation
import SwiftData
import TemplateModel

/// Mode de planification d'un programme adapté.
/// - `.ondemand` : pas de calendrier de semaine ; séances disponibles à tout moment
///   (sport sans deadline, routine cyclique).
/// - `.planned` : programme avec calendrier de semaine (`weekStartDate` posée).
///   Blocage doux par semaine : S(N+1) débloquée quand S(N) complétée (Story 3.11).
///   Pas de prescription de jour calendaire — l'utilisateur fait ses séances dans
///   l'ordre qu'il veut au cours de la semaine.
public enum ProgramMode: String, Codable, Equatable, Sendable {
    case ondemand
    case planned
}

@Model
final class AdaptedProgramRecord {
    @Attribute(.unique) var id: UUID
    var userId: UUID
    var sportCode: String                       // Sport.rawValue (running, cycling, ...)
    var level: String                           // Level.rawValue (beginner, ...)
    var templateId: String                      // ProgramTemplate.id (pour audit + re-adapt)
    var adaptedAt: Date                         // = AdaptedProgram.appliedAt
    /// Début de semaine du programme (lundi 00:00 local).
    /// **Story 3.10** : nullable. `nil` = programme "dormant" (généré en avance,
    /// jamais démarré). La date se pose uniquement au premier tap "Démarrer ma
    /// séance" via `markStarted()`. Un programme reste dormant tant que
    /// `weekStartDate == nil`.
    var weekStartDate: Date?

    /// **Story 3.10** — Câblage Story 3.11 (idempotence regen post-shift) introduit
    /// ici pour ne pas refaire de migration breaking en 3.11. Incrémenté par
    /// chaque "shift week" effectué par Replanifier (Story 3.11). Default 0.
    var shiftGeneration: Int = 0

    /// **Story 3.12** — Titre du programme affiché en nav bar + carrousel.
    /// Posé à la création au format "{Sport} — {Goal}" via `AutoTitleBuilder`.
    /// Modifiable par l'utilisateur via le rename sheet (tap sur le titre nav).
    /// Nullable pour rétro-compat (records pré-Story 3.12) — fallback côté UI
    /// vers le sport seul si nil.
    ///
    /// **Story 3.28 Phase A (i18n re-localisable)** — depuis V11, ce champ
    /// devient SECONDAIRE : on l'utilise UNIQUEMENT si `isUserRenamed == true`
    /// (= l'utilisateur a explicitement nommé son programme). Sinon, le titre
    /// est recalculé dynamiquement via `AutoTitleBuilder` + `goalCode` +
    /// `secondaryGoalsCSV` + locale courante. Fallback rétrocompat : records
    /// pré-3.28 sans `goalCode` utilisent `customTitle` figé.
    var customTitle: String?

    /// **Story 3.28 Phase A** — code de l'objectif primaire (ex "5k",
    /// "cyclosportive"). Stocké pour permettre le recalcul du titre au render
    /// selon `LanguageManager.currentLocale`. Nil = records pré-3.28 ou
    /// programmes sans objectif (sport-seul).
    var goalCode: String?

    /// **Story 3.28 Phase A** — objectifs secondaires (Story 3.13 multi-goals)
    /// sérialisés en CSV pour stockage SwiftData (pas d'array natif). Nil ou
    /// vide = pas de secondary. Re-décomposé via `split(",")` au render.
    var secondaryGoalsCSV: String?

    /// **Story 3.28 Phase A** — true si l'utilisateur a édité manuellement
    /// `customTitle` via le rename sheet. Quand true, `customTitle` gagne
    /// sur le recalcul `AutoTitleBuilder` (sinon le recalcul écraserait le
    /// renommage user à chaque changement de langue).
    var isUserRenamed: Bool = false

    /// Stocké en `String` car SwiftData ne supporte pas les enums comme attribute type.
    /// Utiliser `mode` (computed) plutôt que `modeRaw` côté business code.
    var modeRaw: String
    var mode: ProgramMode {
        get { ProgramMode(rawValue: modeRaw) ?? .ondemand }
        set { modeRaw = newValue.rawValue }
    }

    /// `[PersistedSession]` flatten des weeks/sessions, encodé en `Data`.
    /// Story 3.9 lit `sessionStates` pour le tri prochaine séance + completion.
    private var sessionsJsonData: Data
    var sessions: [PersistedSession] {
        get { (try? JSONDecoder().decode([PersistedSession].self, from: sessionsJsonData)) ?? [] }
        set { sessionsJsonData = (try? JSONEncoder().encode(newValue)) ?? Data() }
    }

    /// `ProgramCompletionState` sérialisé : map sessionId → `SessionRecord`
    /// (completedAt + métriques pour PR detection Story 3.9).
    private var completionStateJsonData: Data
    var completionState: ProgramCompletionState {
        get { (try? JSONDecoder().decode(ProgramCompletionState.self, from: completionStateJsonData)) ?? .empty }
        set { completionStateJsonData = (try? JSONEncoder().encode(newValue)) ?? Data() }
    }

    /// **Chantier charge muscu V2 (T2)** — `ExerciseLevelState` sérialisé : niveau
    /// relatif CACHÉ par exo (clé = stableMatchKey). Default `Data()` (→ `.empty` au
    /// décodage) pour migration SwiftData lightweight sans crash (records pré-feature).
    /// PRÉSERVÉ au renouvellement de cycle (l'apprentissage survit, contrairement à
    /// `completionState`). Jamais de kg.
    private var exerciseLevelsJsonData: Data = Data()
    var exerciseLevels: ExerciseLevelState {
        get { (try? JSONDecoder().decode(ExerciseLevelState.self, from: exerciseLevelsJsonData)) ?? .empty }
        set { exerciseLevelsJsonData = (try? JSONEncoder().encode(newValue)) ?? Data() }
    }

    var isActive: Bool                          // false = archivé (programme terminé/abandonné)
    var archivedAt: Date?                       // timestamp d'archivage, nil tant qu'`isActive`

    /// Story 3.3a : émis par `ProgramAdapter` quand l'algo deterministic n'a pas trouvé
    /// d'alternative propre pour au moins un exercice. Story 3.3b auto-déclenche le
    /// hand-off Léon IA fallback à l'arrivée sur `AdaptedProgramView` si == true.
    var requiresAIAssist: Bool = false
    /// Phrase courte expliquant POURQUOI `requiresAIAssist` est vrai (cas atypique
    /// détecté). Affiché en sous-titre du loader Léon. Nil tant que `requiresAIAssist == false`.
    var aiAssistReason: String?

    /// Story 3.3b : true après application réussie d'un patch IA Léon. Empêche
    /// la ré-application automatique au prochain reload (idempotence).
    var aiPatchApplied: Bool = false
    /// JSON brut du dernier `AdaptationPatch` reçu de Léon. Persisté pour audit
    /// + re-application éventuelle après mise à jour algo. Nil avant 1er patch.
    var aiPatchJSON: String?

    /// Story sœur — mode de durée du programme. Stocké en `String` (rawValue de
    /// `ProgramDurationMode`). Default `.routineCyclic` (= mode le plus permissif :
    /// pas de fin, regenable).
    var durationModeRaw: String = ProgramDurationMode.routineCyclic.rawValue
    var durationMode: ProgramDurationMode {
        get { ProgramDurationMode(rawValue: durationModeRaw) ?? .routineCyclic }
        set { durationModeRaw = newValue.rawValue }
    }

    /// Story sœur — date cible (deadline). Nil pour `routineCyclic`.
    var targetDate: Date?

    /// Story sœur — numéro de cycle pour les programmes en `routineCyclic`.
    /// 1 au premier programme, incrémenté à chaque renouvellement.
    /// Toujours 1 pour les modes deadline.
    var cycleNumber: Int = 1

    var createdAt: Date
    var lastUpdatedAt: Date

    init(
        id: UUID = UUID(),
        userId: UUID,
        sportCode: String,
        level: String,
        templateId: String,
        adaptedAt: Date,
        weekStartDate: Date? = nil,
        mode: ProgramMode = .ondemand,
        sessions: [PersistedSession],
        completionState: ProgramCompletionState = .empty,
        isActive: Bool = true,
        archivedAt: Date? = nil,
        requiresAIAssist: Bool = false,
        aiAssistReason: String? = nil,
        aiPatchApplied: Bool = false,
        aiPatchJSON: String? = nil,
        durationMode: ProgramDurationMode = .routineCyclic,
        targetDate: Date? = nil,
        cycleNumber: Int = 1,
        shiftGeneration: Int = 0,
        customTitle: String? = nil,
        goalCode: String? = nil,
        secondaryGoalsCSV: String? = nil,
        isUserRenamed: Bool = false,
        createdAt: Date = Date(),
        lastUpdatedAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.sportCode = sportCode
        self.level = level
        self.templateId = templateId
        self.adaptedAt = adaptedAt
        self.weekStartDate = weekStartDate
        self.modeRaw = mode.rawValue
        self.sessionsJsonData = (try? JSONEncoder().encode(sessions)) ?? Data()
        self.completionStateJsonData = (try? JSONEncoder().encode(completionState)) ?? Data()
        self.isActive = isActive
        self.archivedAt = archivedAt
        self.requiresAIAssist = requiresAIAssist
        self.aiAssistReason = aiAssistReason
        self.aiPatchApplied = aiPatchApplied
        self.aiPatchJSON = aiPatchJSON
        self.durationModeRaw = durationMode.rawValue
        self.targetDate = targetDate
        self.cycleNumber = cycleNumber
        self.shiftGeneration = shiftGeneration
        self.customTitle = customTitle
        self.goalCode = goalCode
        self.secondaryGoalsCSV = secondaryGoalsCSV
        self.isUserRenamed = isUserRenamed
        self.createdAt = createdAt
        self.lastUpdatedAt = lastUpdatedAt
    }
}

// MARK: - Bridge AdaptedProgram → AdaptedProgramRecord

extension AdaptedProgramRecord {
    /// Bridge appliqué en sortie de Story 3.3a : convertit l'`AdaptedProgram` mémoire
    /// en `AdaptedProgramRecord` SwiftData prêt à insérer dans le `ModelContext`.
    /// Le programme nait en `mode = .ondemand` ; `markStarted()` le bascule en
    /// `.planned` (Story 3.10) en posant `weekStartDate` sur la semaine courante.
    convenience init(
        from adapted: AdaptedProgram,
        userId: UUID,
        weekStartDate: Date? = nil,
        cycleNumber: Int = 1,
        goal: String? = nil,
        secondary: [String] = [],
        locale: Locale = .current
    ) {
        let sessions: [PersistedSession] = adapted.weeks.flatMap { week in
            week.sessions.map { session in
                PersistedSession(
                    id: UUID(),
                    weekNumber: week.weekNumber,
                    weekTheme: week.theme,
                    weekGoal: week.goal,
                    day: session.day,
                    name: session.name,
                    durationMinutes: session.durationMinutes,
                    type: session.type,
                    warmup: session.warmup,
                    exercises: session.exercises,
                    cooldown: session.cooldown
                )
            }
        }
        // **Story 3.28 Phase A** — `customTitle` est posé en bonus rétrocompat
        // (anciens consumers qui le lisaient directement). Mais le titre
        // d'affichage sera recalculé dynamiquement par le ViewModel selon la
        // locale courante, via `goalCode` + `secondaryGoalsCSV` (stockés ci-
        // dessous). `isUserRenamed` reste false : tant que l'user ne renomme
        // pas, le recalcul gagne sur `customTitle`.
        let autoTitle = AutoTitleBuilder.build(
            sportCode: adapted.sport.appSportCode,
            goal: goal,
            secondary: secondary,
            locale: locale
        )
        let secondaryCSV: String? = secondary.isEmpty
            ? nil
            : secondary.joined(separator: ",")
        self.init(
            userId: userId,
            sportCode: adapted.sport.appSportCode,
            level: adapted.level.rawValue,
            templateId: adapted.templateId,
            adaptedAt: adapted.appliedAt,
            weekStartDate: weekStartDate,
            mode: .ondemand,
            sessions: sessions,
            completionState: .empty,
            isActive: true,
            archivedAt: nil,
            requiresAIAssist: adapted.requiresAIAssist,
            aiAssistReason: adapted.aiAssistReason,
            durationMode: adapted.durationMode,
            targetDate: adapted.targetDate,
            cycleNumber: cycleNumber,
            customTitle: autoTitle,
            goalCode: goal,
            secondaryGoalsCSV: secondaryCSV,
            isUserRenamed: false
        )
    }

    /// Lundi 00:00 (heure locale) de la semaine courante.
    static func startOfCurrentWeek(now: Date = Date(), calendar: Calendar = .current) -> Date {
        var cal = calendar
        // ISO-8601 : la semaine commence le lundi (1) — convention européenne.
        cal.firstWeekday = 2
        let comps = cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
        return cal.date(from: comps) ?? now
    }

    /// **Story 3.10** — Bascule le programme de "dormant" à "démarré" en posant
    /// `weekStartDate` sur la semaine courante. Idempotent : si déjà démarré
    /// (`weekStartDate != nil`), no-op.
    ///
    /// Appelée par le call-site "Démarrer ma séance" sur un programme dormant.
    /// Le caller doit ensuite appeler `repository.update(record)` pour persister.
    func markStarted(now: Date = Date()) {
        guard weekStartDate == nil else { return }
        weekStartDate = AdaptedProgramRecord.startOfCurrentWeek(now: now)
        lastUpdatedAt = now
    }

    /// Reconstruction inverse vers `AdaptedProgram` mémoire. Utilisée par les
    /// vues qui consomment la struct (ex. `AdaptedProgramView` push depuis
    /// dashboard Séances mode actif). Les `appliedRules` ne sont pas persistés
    /// (audit-only), donc reconstitués à `[]` — comportement attendu.
    func toAdaptedProgram() -> AdaptedProgram? {
        guard let sport = Sport(sportCode: sportCode),
              let level = Level(profileLevel: level)
        else { return nil }
        let grouped = Dictionary(grouping: sessions, by: \.weekNumber)
        let weeks = grouped.keys.sorted().compactMap { wn -> AdaptedWeek? in
            let weekSessions = (grouped[wn] ?? []).sorted(by: { $0.day < $1.day })
            guard let first = weekSessions.first else { return nil }
            let adapted = weekSessions.map { ps in
                AdaptedSession(
                    day: ps.day,
                    name: ps.name,
                    durationMinutes: ps.durationMinutes,
                    type: ps.type,
                    warmup: ps.warmup,
                    exercises: ps.exercises,
                    cooldown: ps.cooldown
                )
            }
            return AdaptedWeek(
                weekNumber: wn,
                theme: first.weekTheme,
                goal: first.weekGoal,
                sessions: adapted
            )
        }
        return AdaptedProgram(
            templateId: templateId,
            sport: sport,
            level: level,
            appliedAt: adaptedAt,
            weeks: weeks,
            appliedRules: [],
            requiresAIAssist: requiresAIAssist,
            aiAssistReason: aiAssistReason,
            durationMode: durationMode,
            targetDate: targetDate
        )
    }

    // MARK: - Story 3.3b — patch IA Léon

    /// Applique un patch IA reçu de l'Edge Function sage-coaching-ai et persiste
    /// les flags d'idempotence (`aiPatchApplied = true`, `aiPatchJSON = JSON brut`).
    /// Le caller doit appeler `try modelContext.save()` après pour persister sur disque.
    func applyLeonPatch(_ patch: AdaptationPatch) throws {
        let data = try JSONEncoder().encode(patch)
        guard let json = String(data: data, encoding: .utf8) else {
            throw AppliedPatchError.encodingFailed
        }
        self.aiPatchJSON = json
        self.aiPatchApplied = true
        self.lastUpdatedAt = Date()
    }

    /// Decode le patch IA persisté. Nil si aucun patch n'a été appliqué ou si le
    /// JSON stocké est corrompu (cas dégénéré : migration future qui aurait cassé le format).
    func decodedLeonPatch() -> AdaptationPatch? {
        guard aiPatchApplied,
              let json = aiPatchJSON,
              let data = json.data(using: .utf8)
        else { return nil }
        return try? JSONDecoder().decode(AdaptationPatch.self, from: data)
    }

    /// Reconstruit l'`AppliedAdaptedProgram` (programme + notes Léon) à partir
    /// du record. C'est la méthode appelée par l'UI au reload du programme depuis
    /// SwiftData (Story 3.8 dashboard Séances).
    func toAppliedAdaptedProgram() -> AppliedAdaptedProgram? {
        guard let program = toAdaptedProgram() else { return nil }
        return PatchApplier.apply(decodedLeonPatch(), to: program)
    }
}

enum AppliedPatchError: Error {
    case encodingFailed
}
