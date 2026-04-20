import Foundation

/// Fake pre-made templates used to test Dimension 3 (template adaptation).
///
/// In production these will be in `ProgramTemplateLibrary` bundled with the app,
/// stored as JSON or Swift data, and generated once offline by Léon + validated.
///
/// For the spike we need:
/// - 2 realistic templates (structure close to final product)
/// - Clear "default" content that Léon will have to MODIFY for specific profiles
enum Templates {

    /// Template : Running débutant, 8 semaines, 3×/semaine, objectif 5k
    /// Volontairement standard : aucune contrainte, tapis ou plein air OK, pas d'équipement spécifique
    static let runningBeginner5k: String = """
    {
      "template_id": "running-debutant-5k-8sem",
      "name": "Run5K — Couch to 5K en 8 semaines",
      "sport": "Running",
      "level": "débutant",
      "duration_weeks": 8,
      "sessions_per_week": 3,
      "assumed_profile": "Adulte débutant sans blessure, aucun équipement particulier (juste chaussures de running), extérieur ou tapis, pas de contrainte physique, pas d'objectif de performance au-delà de terminer 5k en course continue.",
      "weeks": [
        {
          "week_number": 1,
          "theme": "Prise de repères",
          "sessions": [
            {
              "day": 1,
              "name": "Marche-course 1",
              "duration_minutes": 30,
              "exercises": [
                {"name": "Marche d'échauffement", "duration": "5 min", "rest_seconds": 0, "notes": "Allure tranquille."},
                {"name": "Intervalles 1 min course / 2 min marche", "sets": 6, "duration": "18 min total", "rest_seconds": 0, "notes": "Course lente et souple."},
                {"name": "Retour au calme marche", "duration": "7 min", "rest_seconds": 0, "notes": "Récupération active."}
              ]
            },
            {
              "day": 3,
              "name": "Marche-course 2",
              "duration_minutes": 30,
              "exercises": [
                {"name": "Marche d'échauffement", "duration": "5 min", "rest_seconds": 0, "notes": ""},
                {"name": "Intervalles 1 min course / 2 min marche", "sets": 7, "duration": "21 min total", "rest_seconds": 0, "notes": ""},
                {"name": "Marche de récup", "duration": "4 min", "rest_seconds": 0, "notes": ""}
              ]
            },
            {
              "day": 5,
              "name": "Marche-course 3",
              "duration_minutes": 30,
              "exercises": [
                {"name": "Marche d'échauffement", "duration": "5 min", "rest_seconds": 0, "notes": ""},
                {"name": "Intervalles 1 min 30 course / 2 min marche", "sets": 6, "duration": "21 min total", "rest_seconds": 0, "notes": ""},
                {"name": "Marche de récup", "duration": "4 min", "rest_seconds": 0, "notes": ""}
              ]
            }
          ]
        },
        {
          "week_number": 4,
          "theme": "Course continue émergente",
          "sessions": [
            {
              "day": 1,
              "name": "Course progressive",
              "duration_minutes": 35,
              "exercises": [
                {"name": "Marche", "duration": "5 min", "rest_seconds": 0},
                {"name": "Course continue", "duration": "8 min", "rest_seconds": 0},
                {"name": "Marche", "duration": "3 min", "rest_seconds": 0},
                {"name": "Course continue", "duration": "8 min", "rest_seconds": 0},
                {"name": "Marche récup", "duration": "5 min", "rest_seconds": 0}
              ]
            }
          ]
        },
        {
          "week_number": 8,
          "theme": "Objectif 5k",
          "sessions": [
            {
              "day": 5,
              "name": "5K test",
              "duration_minutes": 45,
              "exercises": [
                {"name": "Marche + footing d'échauffement", "duration": "10 min", "rest_seconds": 0},
                {"name": "5 km en course continue", "duration": "30 min (estimé)", "rest_seconds": 0, "notes": "Objectif : tenir 5 km sans s'arrêter."},
                {"name": "Retour au calme marche", "duration": "5 min", "rest_seconds": 0}
              ]
            }
          ]
        }
      ],
      "safety_notes": "Écouter son corps, alterner jour de repos entre chaque séance.",
      "progression_logic": "Augmentation progressive du ratio course/marche chaque semaine jusqu'à course continue en S6, maintien et progression de la distance en S7-S8."
    }
    """

    /// Template : Muscu intermédiaire hypertrophie salle, 12 semaines, 4×/semaine
    static let musculationIntermediateHypertrophy: String = """
    {
      "template_id": "muscu-intermediaire-hypertrophie-12sem",
      "name": "Hypertrophie 12 — Upper/Lower Split",
      "sport": "Musculation",
      "level": "intermédiaire",
      "duration_weeks": 12,
      "sessions_per_week": 4,
      "assumed_profile": "Adulte intermédiaire (1-2 ans de pratique régulière), salle de sport complète (barres, haltères, machines, câbles), aucune contrainte physique, objectif prise de masse musculaire via hypertrophie classique.",
      "weeks": [
        {
          "week_number": 1,
          "theme": "Reprise volume",
          "sessions": [
            {
              "day": 1,
              "name": "Upper A",
              "duration_minutes": 70,
              "exercises": [
                {"name": "Développé couché barre", "sets": 4, "reps": "8-10", "rest_seconds": 90, "notes": "RPE 7."},
                {"name": "Rowing barre", "sets": 4, "reps": "8-10", "rest_seconds": 90, "notes": ""},
                {"name": "Développé militaire haltères", "sets": 3, "reps": "10-12", "rest_seconds": 75, "notes": ""},
                {"name": "Tirage vertical", "sets": 3, "reps": "10-12", "rest_seconds": 75, "notes": ""},
                {"name": "Curl biceps barre", "sets": 3, "reps": "12", "rest_seconds": 60, "notes": ""},
                {"name": "Extensions triceps poulie", "sets": 3, "reps": "12", "rest_seconds": 60, "notes": ""}
              ]
            },
            {
              "day": 2,
              "name": "Lower A",
              "duration_minutes": 70,
              "exercises": [
                {"name": "Squat barre", "sets": 4, "reps": "8-10", "rest_seconds": 120, "notes": "Prioritaire. RPE 7."},
                {"name": "Soulevé de terre roumain", "sets": 4, "reps": "8-10", "rest_seconds": 120, "notes": ""},
                {"name": "Presse à cuisses", "sets": 3, "reps": "12", "rest_seconds": 90, "notes": ""},
                {"name": "Leg curl machine", "sets": 3, "reps": "12", "rest_seconds": 75, "notes": ""},
                {"name": "Mollets debout", "sets": 4, "reps": "15", "rest_seconds": 60, "notes": ""}
              ]
            },
            {
              "day": 4,
              "name": "Upper B",
              "duration_minutes": 70,
              "exercises": [
                {"name": "Développé incliné haltères", "sets": 4, "reps": "10", "rest_seconds": 90, "notes": ""},
                {"name": "Tractions (ou tirage horizontal)", "sets": 4, "reps": "8-10", "rest_seconds": 90, "notes": ""},
                {"name": "Élévations latérales", "sets": 3, "reps": "12-15", "rest_seconds": 60, "notes": ""},
                {"name": "Rowing haltère unilatéral", "sets": 3, "reps": "12", "rest_seconds": 75, "notes": ""},
                {"name": "Curl marteau", "sets": 3, "reps": "12", "rest_seconds": 60, "notes": ""},
                {"name": "Dips triceps machine", "sets": 3, "reps": "12", "rest_seconds": 60, "notes": ""}
              ]
            },
            {
              "day": 5,
              "name": "Lower B",
              "duration_minutes": 70,
              "exercises": [
                {"name": "Soulevé de terre sumo", "sets": 4, "reps": "6-8", "rest_seconds": 120, "notes": ""},
                {"name": "Fentes avant haltères", "sets": 3, "reps": "10 par jambe", "rest_seconds": 90, "notes": ""},
                {"name": "Hip thrust", "sets": 3, "reps": "12", "rest_seconds": 90, "notes": ""},
                {"name": "Leg extension", "sets": 3, "reps": "12-15", "rest_seconds": 60, "notes": ""},
                {"name": "Gainage planche", "sets": 3, "duration": "45s", "rest_seconds": 45, "notes": ""}
              ]
            }
          ]
        }
      ],
      "safety_notes": "Forme technique prioritaire. Charges progressives.",
      "progression_logic": "Surcharge progressive sur 4 blocs de 3 semaines, deload en semaine 4/8/12."
    }
    """
}

/// Test cases for Dimension 3 — template adaptation.
/// Each case has a template + a user profile that deviates from the template's assumed profile,
/// forcing Léon to emit meaningful adaptations.
struct AdaptationCase: Codable {
    let id: String
    let sport: String
    let templateId: String
    let template: String
    let userProfile: String
    let expectedAdaptations: [String]
}

enum AdaptationCases {
    static let all: [AdaptationCase] = [
        // Case A: Running beginner template + knee constraint + outdoor only (no treadmill)
        AdaptationCase(
            id: "A01-running-debutant-genou-fragile",
            sport: "Running",
            templateId: "running-debutant-5k-8sem",
            template: Templates.runningBeginner5k,
            userProfile: """
            Femme, 38 ans, 68 kg, 165 cm. Niveau débutant. Contrainte : arthrose débutante au genou droit \
            (déclarée par un médecin, pas de restriction absolue mais éviter les descentes prolongées et les \
            impacts répétés à froid). Équipement : aucun (extérieur uniquement, chaussures de running). \
            Fréquence : 3 séances / semaine, 30-45 min max. Objectif : terminer 5 km en course continue en 8 semaines.
            """,
            expectedAdaptations: [
                "Échauffement allongé / mobilité genoux avant chaque séance",
                "Renforcement quadriceps/fessiers ajouté (substitutions ou notes)",
                "Notes sécurité sur la descente et la foulée",
                "Pacing possiblement ralenti si besoin",
                "Adaptation au fait qu'il n'y a pas de tapis"
            ]
        ),

        // Case B: Musculation intermediate template + home only + elastic bands + lower back pain
        AdaptationCase(
            id: "A02-muscu-maison-elastiques-lombalgie",
            sport: "Musculation",
            templateId: "muscu-intermediaire-hypertrophie-12sem",
            template: Templates.musculationIntermediateHypertrophy,
            userProfile: """
            Homme, 34 ans, 78 kg, 180 cm. Niveau intermédiaire (1,5 an d'expérience en salle, arrêt \
            depuis 3 mois pour déménagement). Équipement : maison uniquement, 1 paire d'haltères \
            ajustables 5-25 kg, bandes élastiques variées, une barre de traction fixée à la porte, \
            un tapis. Pas de banc, pas de squat rack. Contrainte : lombalgie chronique (éviter les \
            soulevés de terre lourds, préférer les alternatives, privilégier gainage transverse). \
            Fréquence : 4 séances / semaine. Objectif : reprendre la masse musculaire progressivement.
            """,
            expectedAdaptations: [
                "Substitutions sur TOUS les exercices barres (développé couché, squat barre, SDT, rowing barre)",
                "Squat barre → goblet squat haltère ou split squat bulgare",
                "Soulevé de terre → alternatives hanches (hip thrust, glute bridge lesté, bon-morning léger)",
                "Rowing barre → rowing haltère ou rowing élastique",
                "Développé couché → développé haltères sol (pas de banc)",
                "Notes de sécurité lombaires explicites"
            ]
        )
    ]
}
