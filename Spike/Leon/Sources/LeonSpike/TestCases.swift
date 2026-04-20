import Foundation

/// Test matrix : 10 programs across 5 sports, covering:
/// - Beginner → expert range (FR3)
/// - Multiple objectives (FR4)
/// - Equipment constraints (FR5, FR23)
/// - Physical constraints (FR6, FR24)
/// - Multi-discipline (FR19)
/// - Targeted / ultra-progressive programs (FR20, FR21)
struct TestCase: Codable {
    let id: String
    let sport: String
    let profile: String
    let request: String
    let expectedChecks: [String]
}

enum TestCases {
    static let all: [TestCase] = [
        // RUNNING (2 cases — débutant safety vs avancé performance)
        TestCase(
            id: "01-running-debutant",
            sport: "Running",
            profile: """
            Femme, 38 ans, 68 kg, 165 cm. Niveau débutant absolu. Objectif : courir 5 km sans s'arrêter en 8 semaines. \
            Équipement : aucun (juste chaussures de running). Contrainte : genou droit fragile (arthrose débutante). \
            Fréquence : 3 séances / semaine, 30-45 min max. Disponibilité : soir.
            """,
            request: "Crée-moi un programme de 8 semaines pour atteindre 5 km en course continue, adapté à mon genou.",
            expectedChecks: [
                "Démarrage ultra-progressif (walk/run)",
                "Pas de descente prolongée (protection genou)",
                "Progression raisonnable sur 8 semaines",
                "Pas d'équipement autre que chaussures",
                "3 séances/semaine max"
            ]
        ),
        TestCase(
            id: "02-running-avance",
            sport: "Running",
            profile: """
            Homme, 42 ans, 72 kg, 178 cm. Niveau avancé (courant 5x/semaine depuis 5 ans, record marathon 3h45). \
            Objectif : passer sous 3h30 au marathon de Paris dans 16 semaines. Équipement : GPS watch, cardio, \
            tapis de course, piste d'athlétisme accessible. Contrainte : aucune. Fréquence : 5 séances / semaine, \
            1h30 max en semaine, 2h30 le week-end.
            """,
            request: "Construis-moi un plan marathon 16 semaines pour viser sub-3h30.",
            expectedChecks: [
                "Allures spécifiques (seuil, VMA, allure marathon)",
                "Mention séance longue progressive",
                "Phases : base / spécifique / affûtage",
                "Utilisation de la piste pour VMA",
                "Séance de récup"
            ]
        ),

        // MUSCULATION (2 cases — prise de masse salle vs tonification maison)
        TestCase(
            id: "03-muscu-masse-salle",
            sport: "Musculation",
            profile: """
            Homme, 26 ans, 75 kg, 182 cm. Niveau intermédiaire (1.5 an de pratique, squat 100kg, développé 75kg). \
            Objectif : prise de masse musculaire (+5 kg en 12 semaines). Équipement : salle de sport complète \
            (barres, haltères, machines, câbles). Contrainte : aucune. Fréquence : 4 séances / semaine, 1h15 max.
            """,
            request: "Crée-moi un programme hypertrophie 12 semaines en split 4 jours pour prise de masse.",
            expectedChecks: [
                "Split logique (ex: push/pull/legs/upper ou bro-split)",
                "Volume hypertrophie (3-5 séries, 8-12 reps)",
                "Repos 60-90s sur exercices d'isolation",
                "Progression surcharge progressive",
                "Exercices composés prioritaires"
            ]
        ),
        TestCase(
            id: "04-muscu-tonification-maison",
            sport: "Musculation",
            profile: """
            Femme, 34 ans, 62 kg, 168 cm. Niveau débutante (jamais fait de muscu structurée). Objectif : tonification \
            générale, se sentir plus forte au quotidien. Équipement : maison, élastiques de résistance, tapis, \
            2 haltères de 3 kg. Contrainte : lombaires sensibles (éviter les flexions avant chargées). \
            Fréquence : 2 séances / semaine, 30 min max.
            """,
            request: "Propose-moi un programme de tonification 6 semaines que je peux faire chez moi.",
            expectedChecks: [
                "Aucun exercice nécessitant de gros poids",
                "Utilisation des élastiques et haltères 3kg",
                "Pas de good morning, deadlift lourd, squat barre",
                "Exercices adaptés débutante (gainage, fentes, pompes sur genoux)",
                "Durée 30 min respectée"
            ]
        ),

        // NATATION (1 case — technique)
        TestCase(
            id: "05-natation-technique-crawl",
            sport: "Natation",
            profile: """
            Femme, 29 ans, 58 kg, 172 cm. Niveau intermédiaire (sait nager crawl mais essoufflement rapide au-delà \
            de 200m). Objectif ciblé : améliorer la technique du crawl pour tenir 1000m sans s'arrêter. \
            Équipement : piscine municipale 25m, palmes courtes, plaquettes, pull buoy. Contrainte : épaule droite \
            sensible (ancienne luxation). Fréquence : 3 séances / semaine, 45 min max.
            """,
            request: "Crée-moi un programme 6 semaines pour améliorer mon crawl et tenir 1000m.",
            expectedChecks: [
                "Éducatifs technique crawl (rattrapés, poings fermés, 3 temps)",
                "Usage pull buoy / palmes / plaquettes mentionné",
                "Adaptation épaule droite (ne pas surcharger avec plaquettes lourdes)",
                "Progression de distance",
                "Séance en 25m (pas 50m)"
            ]
        ),

        // TENNIS (1 case — débutant total)
        TestCase(
            id: "06-tennis-debutant-total",
            sport: "Tennis",
            profile: """
            Homme, 45 ans, 80 kg, 175 cm. Niveau débutant total (jamais tenu une raquette). \
            Objectif : apprendre les bases pour jouer avec son fils en 8 semaines. Équipement : court de tennis \
            accessible, mur d'entraînement, raquette, seau de balles. Contrainte : aucune. \
            Fréquence : 2 séances / semaine, 1h.
            """,
            request: "Crée-moi un programme d'apprentissage tennis 8 semaines pour débutant absolu.",
            expectedChecks: [
                "Progression : prise de raquette → coup droit → revers → service",
                "Usage du mur mentionné",
                "Exercices simples et répétitifs",
                "Pas de match technique trop tôt",
                "Inclusion échauffement spécifique"
            ]
        ),

        // REMISE EN FORME POST-GROSSESSE (1 case — ultra-progressif + contrainte)
        TestCase(
            id: "07-remise-en-forme-post-grossesse",
            sport: "Remise en forme",
            profile: """
            Femme, 32 ans, 68 kg, 165 cm, 4 mois post-accouchement, rééducation périnée OK. \
            Niveau débutante reprise. Objectif : retrouver énergie et tonus progressivement. \
            Équipement : maison, tapis, bébé à gérer. Contrainte : diastasis abdominal léger (éviter crunchs classiques, \
            privilégier hypopressifs), fatigue générale. Fréquence : 3 courtes séances / semaine, 20 min max.
            """,
            request: "Crée-moi un programme de reprise douce 6 semaines adapté au post-partum.",
            expectedChecks: [
                "Aucun crunch / sit-up classique",
                "Hypopressifs / respiration mentionnés",
                "Progression très douce",
                "Séances courtes (20 min)",
                "Sécurité diastasis explicitement abordée"
            ]
        ),

        // TRIATHLON (1 case — multi-discipline FR19)
        TestCase(
            id: "08-triathlon-sprint-premier",
            sport: "Triathlon",
            profile: """
            Homme, 35 ans, 78 kg, 180 cm. Niveau intermédiaire en course (10 km en 48 min), intermédiaire en vélo \
            (sorties régulières 40 km), débutant en natation (200m crawl difficile). Objectif : terminer un triathlon \
            sprint (750m natation + 20 km vélo + 5 km course) dans 12 semaines. Équipement : vélo route, GPS watch, \
            piscine 25m accessible. Contrainte : aucune. Fréquence : 6 séances / semaine combinées, 1h15 max en semaine.
            """,
            request: "Crée-moi un plan triathlon sprint 12 semaines, sachant que mon point faible est la natation.",
            expectedChecks: [
                "Répartition logique 3 disciplines",
                "Volume natation renforcé (point faible)",
                "Séance enchaînement (brick) vélo-course",
                "Progression spécifique",
                "6 séances/semaine réparties"
            ]
        ),

        // YOGA / MOBILITÉ (1 case — senior + douleur chronique)
        TestCase(
            id: "09-mobilite-lombaire-50ans",
            sport: "Mobilité / Yoga",
            profile: """
            Femme, 52 ans, 65 kg, 160 cm. Niveau débutante. Objectif bien-être : réduire douleur lombaire chronique \
            et gagner en mobilité. Équipement : tapis de yoga, 2 blocs, une sangle. Contrainte : lombalgie chronique \
            (éviter les flexions avant profondes, les torsions extrêmes). Fréquence : 4 séances / semaine, 25 min.
            """,
            request: "Propose-moi un programme 8 semaines de mobilité et yoga doux pour soulager mon bas du dos.",
            expectedChecks: [
                "Postures adaptées lombaires (pas de flexion avant brutale)",
                "Travail sur gainage doux / transverse",
                "Utilisation blocs et sangle",
                "Progression en amplitude",
                "Respiration intégrée"
            ]
        ),

        // HIIT COURT (1 case — temps très limité)
        TestCase(
            id: "10-hiit-20min-sans-materiel",
            sport: "HIIT",
            profile: """
            Homme, 31 ans, 85 kg, 178 cm. Niveau intermédiaire (actif mais sédentaire au travail). \
            Objectif : perte de gras (5 kg en 8 semaines). Équipement : rien du tout (poids du corps). \
            Contrainte : aucune. Fréquence : 3 séances / semaine, 20 min maximum (temps de travail chargé).
            """,
            request: "Crée-moi un programme HIIT 8 semaines, 20 min max par séance, sans matériel.",
            expectedChecks: [
                "Séances réellement ≤ 20 min (warmup + travail + cooldown)",
                "Exercices au poids du corps uniquement",
                "Format HIIT (tabata, EMOM, AMRAP)",
                "Progression en intensité ou volume",
                "Échauffement court mais présent"
            ]
        )
    ]
}
