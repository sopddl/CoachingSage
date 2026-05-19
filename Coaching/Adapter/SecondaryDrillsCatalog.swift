// Coaching/Adapter/SecondaryDrillsCatalog.swift
// Story 3.13 Phase C (Epic 3) — catalogue statique des drills/exos secondary par
// (sport × secondary goal). Source unique consommée par `SecondaryGoalOverlay`.
//
// V1 minimal : 1-3 exercices par combinaison, génériques mais doctrinalement plausibles.
// Pas de hooks v2 (requiredEquipment, incompatibleConstraints) — l'overlay s'applique
// APRÈS le ProgramAdapter, donc la couche substitution/équipement a déjà tourné sur le
// primary. Les drills secondary sont assumés universels (corps + sport-shoes minimum).
//
// Évolution V2 prévue : externaliser ce catalogue en JSON bundle, étendre sports/goals.
import Foundation
import TemplateModel

/// Exo synthétique injecté par l'overlay. Forme minimale compatible `AdaptedExercise`.
public struct SecondaryDrill: Equatable, Sendable {
    public let name: String
    public let sets: Int?
    public let reps: String?
    public let duration: String?
    public let restSeconds: Int?
    public let notes: String?
    public let targetZone: String?
    /// Hint warmup propagé sur la session dédiée (premier drill uniquement).
    public let warmupHint: String?

    public init(
        name: String,
        sets: Int? = nil,
        reps: String? = nil,
        duration: String? = nil,
        restSeconds: Int? = nil,
        notes: String? = nil,
        targetZone: String? = nil,
        warmupHint: String? = nil
    ) {
        self.name = name
        self.sets = sets
        self.reps = reps
        self.duration = duration
        self.restSeconds = restSeconds
        self.notes = notes
        self.targetZone = targetZone
        self.warmupHint = warmupHint
    }
}

public enum SecondaryDrillsCatalog {

    // MARK: - Dedicated session

    /// Drills construits en bloc pour une séance dédiée à un secondary goal.
    /// 2-4 exos formant une séance cohérente (warmup → corps → finisher).
    public static func drills(forGoal goal: String, sportCode: String) -> [SecondaryDrill] {
        if let custom = customDrills(forGoal: goal, sportCode: sportCode) {
            return custom
        }
        // Fallback : 1 drill générique "découverte" du goal.
        return [genericDrill(forGoal: goal, sportCode: sportCode, durationMinutes: 30)]
    }

    /// Nom localisable de la séance dédiée. Format : `"session.secondary.<sport>.<goal>"`.
    /// Si pas trouvée dans le bundle, le mécanisme `LocalizedStringKey` retombe sur la clé.
    public static func sessionName(forGoal goal: String, sportCode: String) -> String {
        // V1 : utilise le nom du drill principal ou une formule fallback non-localisée.
        // Phase E ajoutera les keys xcstrings dédiées (AC25 partielle).
        if let first = customDrills(forGoal: goal, sportCode: sportCode)?.first {
            return first.name
        }
        return "Séance \(goal.capitalized)"
    }

    /// Type de séance synthétique selon le secondary goal. Drive le bandeau UI et
    /// le tri VolumeModulationRule si l'overlay tournait à nouveau.
    public static func sessionType(forGoal goal: String, sportCode: String) -> SessionType {
        switch (sportCode, goal) {
        case ("running", "5k"), ("running", "10k"):                       return .interval
        case ("running", "half_marathon"), ("running", "marathon"):       return .endurance
        case ("cycling", "endurance"), ("cycling", "sorties-longues"):    return .endurance
        case ("cycling", "cyclosportive"):                                return .endurance
        case ("swimming", "technique"), ("swimming", "perfectionnement"): return .technique
        case ("swimming", "endurance"):                                    return .endurance
        case ("yoga", "hatha"), ("yoga", "vinyasa"):                       return .mobility
        case ("hiit", "performance"), ("hiit", "conditioning"):            return .interval
        case ("hiking", _):                                                return .endurance
        case ("tennis", "tournoi-prep"), ("tennis", "match-prep"):         return .technique
        case ("tennis", "regularite"):                                     return .mixed
        case ("football", _):                                              return .mixed
        default:                                                            return .mixed
        }
    }

    // MARK: - MixIn drill

    /// Drill court injecté en début de session existante (mixInSession). Durée bornée
    /// par `OverlayConfig` côté caller, ici on construit un exo cohérent avec le secondary.
    public static func mixInDrill(
        forGoal goal: String,
        sportCode: String,
        durationMinutes: Int
    ) -> SecondaryDrill {
        if let custom = customDrills(forGoal: goal, sportCode: sportCode)?.first {
            // Réutilise le premier exo dédié mais ré-écrit la durée pour le mixIn.
            return SecondaryDrill(
                name: custom.name,
                sets: nil,
                reps: nil,
                duration: "\(durationMinutes) min",
                restSeconds: nil,
                notes: custom.notes,
                targetZone: custom.targetZone,
                warmupHint: nil
            )
        }
        return genericDrill(forGoal: goal, sportCode: sportCode, durationMinutes: durationMinutes)
    }

    // MARK: - Catalogue privé

    /// Catalogue principal — V1 couvre les combinaisons les plus utilisées. Sport+goal
    /// non couvert → fallback générique.
    private static func customDrills(forGoal goal: String, sportCode: String) -> [SecondaryDrill]? {
        switch (sportCode, goal) {
        // Running secondary
        case ("running", "5k"):
            return [
                SecondaryDrill(name: "Fractions courtes 200m", sets: 6, reps: "200m", restSeconds: 90,
                               notes: "Allure 5K visée", targetZone: "Z4", warmupHint: "10 min footing Z2 + gammes")
            ]
        case ("running", "10k"):
            return [
                SecondaryDrill(name: "Fractions 1000m", sets: 5, reps: "1000m", restSeconds: 120,
                               notes: "Allure 10K visée", targetZone: "Z4", warmupHint: "15 min footing Z2 + gammes")
            ]
        case ("running", "half_marathon"):
            return [
                SecondaryDrill(name: "Tempo seuil 20-30 min", duration: "25 min", notes: "Allure semi",
                               targetZone: "Z3", warmupHint: "15 min footing Z2")
            ]
        case ("running", "marathon"):
            return [
                SecondaryDrill(name: "Sortie longue Z2", duration: "75 min", notes: "Volume marathon",
                               targetZone: "Z2", warmupHint: "10 min progressif")
            ]

        // Cycling secondary
        case ("cycling", "endurance"):
            return [
                SecondaryDrill(name: "Sortie Z2 fond", duration: "60 min", targetZone: "Z2",
                               warmupHint: "10 min progressif")
            ]
        case ("cycling", "sorties-longues"):
            return [
                SecondaryDrill(name: "Sortie longue 90 min", duration: "90 min", targetZone: "Z2",
                               warmupHint: "10 min progressif")
            ]
        case ("cycling", "cyclosportive"):
            return [
                SecondaryDrill(name: "Bosses + plats alternés", duration: "75 min",
                               notes: "Simule profil cyclo", targetZone: "Z3",
                               warmupHint: "15 min progressif")
            ]

        // Swimming secondary (mixInSession surtout)
        case ("swimming", "technique"):
            return [
                SecondaryDrill(name: "Éducatifs crawl (rattrapé, poings fermés)", duration: "10 min",
                               notes: "Focus alignement + roulis", targetZone: "Z1-Z2")
            ]
        case ("swimming", "perfectionnement"):
            return [
                SecondaryDrill(name: "Drills coordination + respiration 3-5 temps", duration: "10 min",
                               notes: "Alterner les côtés", targetZone: "Z2")
            ]
        case ("swimming", "endurance"):
            return [
                SecondaryDrill(name: "Série 4×200m allure régulière", sets: 4, reps: "200m",
                               restSeconds: 30, targetZone: "Z2")
            ]

        // Yoga secondary
        case ("yoga", "hatha"):
            return [
                SecondaryDrill(name: "Postures hatha tenues", duration: "10 min",
                               notes: "Respiration nasale, 30s/posture", targetZone: nil)
            ]
        case ("yoga", "vinyasa"):
            return [
                SecondaryDrill(name: "Flow vinyasa salutations", duration: "10 min",
                               notes: "Enchaîné, respiration synchrone", targetZone: nil)
            ]

        // HIIT secondary
        case ("hiit", "performance"):
            return [
                SecondaryDrill(name: "Sprints 30s on / 30s off", sets: 8, duration: "30 s",
                               restSeconds: 30, notes: "Effort max", targetZone: "Z5",
                               warmupHint: "8 min mobilité dynamique")
            ]
        case ("hiit", "conditioning"):
            return [
                SecondaryDrill(name: "Circuit cardio 40/20", sets: 6, duration: "40 s",
                               restSeconds: 20, targetZone: "Z4")
            ]

        // Hiking secondary
        case ("hiking", "day-hikes"):
            return [
                SecondaryDrill(name: "Marche soutenue 60 min", duration: "60 min",
                               notes: "Sentier vallonné si possible", targetZone: "Z2")
            ]
        case ("hiking", "fastpacking"):
            return [
                SecondaryDrill(name: "Marche-course avec sac 5kg", duration: "60 min",
                               notes: "Alterner 5 min marche / 2 min course", targetZone: "Z2")
            ]
        case ("hiking", "mountain-trek"):
            return [
                SecondaryDrill(name: "Dénivelé positif 400m", duration: "60 min",
                               notes: "Montée régulière, descente contrôlée", targetZone: "Z2")
            ]

        // Tennis secondary
        case ("tennis", "tournoi-prep"):
            return [
                SecondaryDrill(name: "Sets jeu décisif", duration: "20 min",
                               notes: "Concentration sous pression", targetZone: nil)
            ]
        case ("tennis", "match-prep"):
            return [
                SecondaryDrill(name: "Service + retour ciblé", duration: "15 min",
                               notes: "30 services puis 30 retours zones", targetZone: nil)
            ]
        case ("tennis", "regularite"):
            return [
                SecondaryDrill(name: "Échange fond de court long", duration: "15 min",
                               notes: "Objectif : 20 frappes consécutives", targetZone: nil)
            ]

        // Football secondary
        case ("football", "club"), ("football", "saison-regional"):
            return [
                SecondaryDrill(name: "Vivacité 5-10-5 + passes courtes", duration: "15 min",
                               notes: "Coordination + précision", targetZone: nil)
            ]
        case ("football", "loisir"):
            return [
                SecondaryDrill(name: "Petits jeux 4v4 mini-buts", duration: "20 min",
                               notes: "Plaisir + technique", targetZone: nil)
            ]

        default:
            return nil
        }
    }

    /// Drill générique fallback quand le couple sport+goal n'est pas catalogué.
    /// Évite un crash et offre un placeholder lisible jusqu'à enrichissement V2.
    private static func genericDrill(
        forGoal goal: String,
        sportCode: String,
        durationMinutes: Int
    ) -> SecondaryDrill {
        SecondaryDrill(
            name: "Travail \(goal)",
            duration: "\(durationMinutes) min",
            notes: "Travail complémentaire sur \(goal)",
            targetZone: nil
        )
    }
}
