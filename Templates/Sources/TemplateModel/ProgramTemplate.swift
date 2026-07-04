import Foundation

public struct ProgramTemplate: Codable, Equatable, Sendable {
    public let id: String
    public let schemaVersion: Int
    public let sport: Sport
    public let level: Level
    public let name: LocalizedText
    public let durationWeeks: Int
    public let sessionsPerWeek: Int
    public let defaultObjective: LocalizedText
    public let assumedProfile: LocalizedText
    public let summary: LocalizedText
    public let weeks: [TemplateWeek]
    public let safetyNotes: LocalizedText
    public let progressionLogic: LocalizedText
    public let validatedAt: Date?
    public let validatedBy: String?

    /// Semaines de décharge/taper (`week_number`) — JAMAIS densifiées (garde-fou G8,
    /// chantier densité B 2026-07-02). Généré build-time depuis les thèmes/goals EN
    /// (`scripts/densite_b/generate_deload_weeks.py`), verrouillé par
    /// `DeloadWeeksMarkerTests`. `nil` = template pré-densité (fixtures, tests).
    public let deloadWeeks: [Int]?

    public init(
        id: String,
        schemaVersion: Int,
        sport: Sport,
        level: Level,
        name: LocalizedText,
        durationWeeks: Int,
        sessionsPerWeek: Int,
        defaultObjective: LocalizedText,
        assumedProfile: LocalizedText,
        summary: LocalizedText,
        weeks: [TemplateWeek],
        safetyNotes: LocalizedText,
        progressionLogic: LocalizedText,
        validatedAt: Date? = nil,
        validatedBy: String? = nil,
        deloadWeeks: [Int]? = nil
    ) {
        self.id = id
        self.schemaVersion = schemaVersion
        self.sport = sport
        self.level = level
        self.name = name
        self.durationWeeks = durationWeeks
        self.sessionsPerWeek = sessionsPerWeek
        self.defaultObjective = defaultObjective
        self.assumedProfile = assumedProfile
        self.summary = summary
        self.weeks = weeks
        self.safetyNotes = safetyNotes
        self.progressionLogic = progressionLogic
        self.validatedAt = validatedAt
        self.validatedBy = validatedBy
        self.deloadWeeks = deloadWeeks
    }
}

public struct TemplateWeek: Codable, Equatable, Sendable {
    public let weekNumber: Int
    public let theme: LocalizedText
    public let goal: LocalizedText
    public let sessions: [TemplateSession]

    public init(weekNumber: Int, theme: LocalizedText, goal: LocalizedText, sessions: [TemplateSession]) {
        self.weekNumber = weekNumber
        self.theme = theme
        self.goal = goal
        self.sessions = sessions
    }
}

public struct TemplateSession: Codable, Equatable, Sendable {
    public let day: Int
    public let name: LocalizedText
    public let durationMinutes: Int
    public let type: SessionType
    public let warmup: LocalizedText?
    public let exercises: [TemplateExercise]
    public let cooldown: LocalizedText?

    /// Minutes annotées du bloc `warmup` (chantier durée réglable, pilote cycling
    /// 2026-07-04) — `nil` = sport non annoté. Intouchable par le moteur de scaling,
    /// sert seulement au calcul de la fourchette plancher/plafond.
    public let warmupMinutes: Int?

    /// Minutes annotées du bloc `cooldown`. Cf `warmupMinutes`.
    public let cooldownMinutes: Int?

    /// Lieu que représente le contenu RACINE de la séance (= variante native/défaut).
    /// `nil` = séance agnostique (pas de bascule lieu — tous les sports hors chantier
    /// indoor/outdoor). Chantier indoor/outdoor vélo 2026-06-10.
    public let environment: SessionEnvironment?

    /// Variantes ALTERNATIVES par lieu (l'autre / les autres lieux). `nil` = séance mono
    /// (comportement historique, rétro-compatible : champ absent du JSON → nil).
    /// Le contenu natif (champs racine ci-dessus) sert de variante par défaut.
    public let variants: [SessionVariant]?

    public init(
        day: Int,
        name: LocalizedText,
        durationMinutes: Int,
        type: SessionType,
        warmup: LocalizedText?,
        exercises: [TemplateExercise],
        cooldown: LocalizedText?,
        environment: SessionEnvironment? = nil,
        variants: [SessionVariant]? = nil,
        warmupMinutes: Int? = nil,
        cooldownMinutes: Int? = nil
    ) {
        self.day = day
        self.name = name
        self.durationMinutes = durationMinutes
        self.type = type
        self.warmup = warmup
        self.exercises = exercises
        self.cooldown = cooldown
        self.environment = environment
        self.variants = variants
        self.warmupMinutes = warmupMinutes
        self.cooldownMinutes = cooldownMinutes
    }

    /// Toutes les variantes de lieu (native incluse), si la séance est « à lieu ».
    /// Vide si la séance est agnostique (`environment == nil`).
    public var environmentVariants: [SessionVariant] {
        guard let environment else { return [] }
        let native = SessionVariant(
            environment: environment, name: name, durationMinutes: durationMinutes,
            warmup: warmup, exercises: exercises, cooldown: cooldown,
            warmupMinutes: warmupMinutes, cooldownMinutes: cooldownMinutes
        )
        return [native] + (variants ?? [])
    }

    /// Variante effective pour un lieu choisi. `nil` env (ou lieu absent des variantes)
    /// → variante native (défaut, = contenu racine). Renvoie `nil` si la séance n'a
    /// aucune variante de lieu (l'appelant utilise alors le contenu racine directement).
    public func variant(for env: SessionEnvironment?) -> SessionVariant? {
        let all = environmentVariants
        guard let native = all.first else { return nil }
        guard let env else { return native }
        return all.first(where: { $0.environment == env }) ?? native
    }
}

public struct TemplateExercise: Codable, Equatable, Sendable {
    /// Contenu localisable AFFICHABLE (fr/en/es). Depuis l'i18n B2, `name.fr` peut être
    /// vulgarisé/traduit → n'est PLUS la clé de matching (cf `stableMatchKey`).
    public let name: LocalizedText

    /// Clé de matching STABLE explicite (JSON `match_key`), découplée du `name` affichable.
    /// Permet de vulgariser/traduire `name` sans casser findExercise / pattern resolver /
    /// illustrations / fiches « comment l'exécuter » / patch IA, tous keyés sur le nom FR
    /// technique. Optionnel : omis du JSON si `nil` (templates pré-i18n → fallback
    /// `name.canonical` via `stableMatchKey`).
    public let matchKey: String?

    /// Clé de matching effective : `matchKey` explicite si présent, sinon `name.canonical`
    /// (rétro-compatible pré-i18n). À utiliser pour TOUT matching interne.
    public var stableMatchKey: String { matchKey ?? name.canonical }

    public let sets: Int?
    public let reps: String?
    public let duration: String?
    public let restSeconds: Int?

    /// Dosage structuré i18n (chantier 2026-06-14, pilote yoga). SOURCE UNIQUE de rendu du
    /// dosage à l'affichage (3 vues) et du label de phase du minuteur, localisé FR/EN/ES via
    /// `DoseFormatter`. Quand présent il PRIME sur `reps`/`duration` (gardés en FR canonique
    /// pour les ~40 consommateurs non-affichage : stats, parser timer fallback, règles adapter).
    /// `nil` = sport pas encore migré → comportement legacy (rendu verbatim `reps`/`duration`).
    public let dose: Dose?

    public let notes: LocalizedText?

    /// Hooks v2 — drive l'algo deterministic Story 3.3a (ProgramAdapter).
    /// `targetZone` reste un CODE brut (rendu verbatim, glossaire) → pas localisé.
    public let targetZone: String?
    public let requiredEquipment: [String]
    public let incompatibleConstraints: [String]
    public let alternatives: [LocalizedText]
    public let volumeAxis: VolumeAxis?

    /// Chantier durée réglable (pilote cycling, 2026-07-04) — `nil` = sport pas encore
    /// annoté. `role` distingue core (jamais retiré) vs accessory (sacrifié en 1er, D5).
    public let role: BlockRole?

    /// Comment ce bloc se scale : `continuous` (minutes), `roundsReps` (`sets`), `fixed`.
    public let scalingUnit: ScalingUnit?

    /// Ordre de sacrifice parmi les blocs `accessory` d'une même séance (1 = en premier).
    /// `nil` pour un bloc `core` ou un sport non annoté.
    public let priority: Int?

    /// Minutes réelles annotées pour CE bloc à sa cardinalité actuelle dans le template —
    /// remplace le calcul impossible depuis `duration`/`sets` en texte libre (cf doctrine
    /// durée réglable, section 2). Source de vérité pour le moteur de scaling.
    public let estimatedMinutes: Int?

    public init(
        name: LocalizedText,
        matchKey: String? = nil,
        sets: Int? = nil,
        reps: String? = nil,
        duration: String? = nil,
        restSeconds: Int? = nil,
        dose: Dose? = nil,
        notes: LocalizedText? = nil,
        targetZone: String? = nil,
        requiredEquipment: [String] = [],
        incompatibleConstraints: [String] = [],
        alternatives: [LocalizedText] = [],
        volumeAxis: VolumeAxis? = nil,
        role: BlockRole? = nil,
        scalingUnit: ScalingUnit? = nil,
        priority: Int? = nil,
        estimatedMinutes: Int? = nil
    ) {
        self.name = name
        self.matchKey = matchKey
        self.sets = sets
        self.reps = reps
        self.duration = duration
        self.restSeconds = restSeconds
        self.dose = dose
        self.notes = notes
        self.targetZone = targetZone
        self.requiredEquipment = requiredEquipment
        self.incompatibleConstraints = incompatibleConstraints
        self.alternatives = alternatives
        self.volumeAxis = volumeAxis
        self.role = role
        self.scalingUnit = scalingUnit
        self.priority = priority
        self.estimatedMinutes = estimatedMinutes
    }

    private enum CodingKeys: String, CodingKey {
        case name, matchKey, sets, reps, duration, restSeconds, dose, notes
        case targetZone, requiredEquipment, incompatibleConstraints, alternatives, volumeAxis
        case role, scalingUnit, priority, estimatedMinutes
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try c.decode(LocalizedText.self, forKey: .name)
        self.matchKey = try c.decodeIfPresent(String.self, forKey: .matchKey)
        self.sets = try c.decodeIfPresent(Int.self, forKey: .sets)
        self.reps = try c.decodeIfPresent(String.self, forKey: .reps)
        self.duration = try c.decodeIfPresent(String.self, forKey: .duration)
        self.restSeconds = try c.decodeIfPresent(Int.self, forKey: .restSeconds)
        self.dose = try c.decodeIfPresent(Dose.self, forKey: .dose)
        self.notes = try c.decodeIfPresent(LocalizedText.self, forKey: .notes)
        self.targetZone = try c.decodeIfPresent(String.self, forKey: .targetZone)
        self.requiredEquipment = try c.decodeIfPresent([String].self, forKey: .requiredEquipment) ?? []
        self.incompatibleConstraints = try c.decodeIfPresent([String].self, forKey: .incompatibleConstraints) ?? []
        self.alternatives = try c.decodeIfPresent([LocalizedText].self, forKey: .alternatives) ?? []
        self.volumeAxis = try c.decodeIfPresent(VolumeAxis.self, forKey: .volumeAxis)
        self.role = try c.decodeIfPresent(BlockRole.self, forKey: .role)
        self.scalingUnit = try c.decodeIfPresent(ScalingUnit.self, forKey: .scalingUnit)
        self.priority = try c.decodeIfPresent(Int.self, forKey: .priority)
        self.estimatedMinutes = try c.decodeIfPresent(Int.self, forKey: .estimatedMinutes)
    }
}
