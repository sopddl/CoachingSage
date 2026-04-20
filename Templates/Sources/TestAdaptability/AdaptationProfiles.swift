import Foundation

struct AdaptationProfile {
    let id: String
    let label: String
    let userRequest: String
}

enum AdaptationProfiles {
    static let all: [AdaptationProfile] = [
        AdaptationProfile(
            id: "p1-reduce-frequency",
            label: "Réduction fréquence hebdo",
            userRequest: """
            Cette semaine (et probablement les suivantes) je ne peux faire que 2 séances au lieu des 3-4 prévues dans le plan. \
            Je veux garder la progression mais adapter chaque semaine pour tenir en 2 séances. \
            Priorise les séances essentielles de chaque semaine et explique ce que tu déplaces ou fusionnes.
            """
        ),
        AdaptationProfile(
            id: "p2-short-sessions",
            label: "Séances courtes 30 min max",
            userRequest: """
            Chaque séance doit tenir en 30 minutes MAXIMUM (échauffement + corps de séance + retour au calme). \
            Je ne peux pas faire plus long. Adapte la semaine en cours en compressant intelligemment. \
            Si une séance est incompressible (ex : long run 12 km), explique comment la remplacer ou la scinder.
            """
        ),
        AdaptationProfile(
            id: "p3-travel-minimal-gear",
            label: "Semaine voyage équipement minimal",
            userRequest: """
            Je suis en voyage cette semaine : pas d'accès à mon équipement habituel (salle, piscine, vélo, tapis, barres…). \
            J'ai juste un sac de sport avec une paire de baskets, une bande élastique, une corde à sauter. \
            Adapte la semaine en cours pour maintenir la progression avec ce matériel minimal. \
            Si une séance nécessite un équipement indisponible, propose une substitution équivalente en terme de stimulus.
            """
        ),
        AdaptationProfile(
            id: "p4-more-ambitious-goal",
            label: "Objectif revu à la hausse",
            userRequest: """
            Je veux rehausser l'objectif final du plan : passer au niveau au-dessus de ce qui est prévu \
            (ex : 10K au lieu de 5K ; half-ironman au lieu de olympique ; marathon au lieu de 10K ; \
            niveau avancé au lieu d'intermédiaire sur la séance phare). \
            Adapte la progression et l'intensité pour viser cet objectif plus exigeant, tout en restant sûr. \
            Si le plan ne peut pas monter aussi haut sans risque, dis-le clairement.
            """
        ),
        AdaptationProfile(
            id: "p5-low-energy-week",
            label: "Semaine fatigue baisser intensité",
            userRequest: """
            Grosse semaine de boulot / sommeil dégradé / stress élevé : je dois baisser l'intensité de la semaine en cours \
            sans casser la progression globale. Réduis le volume et l'intensité cible, \
            garde juste ce qui entretient les adaptations, et propose comment rattraper la semaine suivante si nécessaire.
            """
        )
    ]

    static func profile(id: String) -> AdaptationProfile? {
        all.first(where: { $0.id == id })
    }
}
