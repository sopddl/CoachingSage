// Coaching/Session/YogaVoiceScripts.swift
// POC yoga (party 2026-06-05, décision D2) — table STATIQUE sanskrit→script de
// placement corporel, lu à l'ENTRÉE dans la posture (décision D3 : « place le
// corps », pas une description de bienfaits, pas une pré-annonce style cardio).
//
// Périmètre POC assumé (à industrialiser en V2, cf doc party) :
//   - 5 postures témoins (1 couchée / 1 assise / 1 debout / 1 à genoux / 1 inversée).
//   - FR seul : le script n'est lu que si la langue de contenu est le français
//     (sinon une voix EN/ES lirait du texte FR → prononciation cassée). nil = silence.
//   - Détection par mots-clés sur le `originalName` (= match_key SANSKRIT), même
//     principe que `YogaIllustration.poseKind`. Une posture non reconnue → nil
//     (on se tait plutôt que de réciter un script faux).
import Foundation

enum YogaVoiceScripts {

    /// Script de placement à annoncer à l'entrée d'une posture, ou `nil` si la
    /// posture n'est pas couverte par le POC / la langue n'est pas le FR.
    /// - Parameters:
    ///   - name: nom technique de l'exo (`AdaptedExercise.originalName`, sanskrit).
    ///   - language: langue de contenu courante ("fr"/"en"/"es").
    static func script(forName name: String?, language: String) -> String? {
        // POC FR seul (D2). Les autres langues → silence (pas de mauvaise prononciation).
        guard language.lowercased().hasPrefix("fr") else { return nil }
        guard let lower = name?.lowercased() else { return nil }

        // Couchée — Savasana (relaxation finale).
        if lower.contains("savasana") || lower.contains("cadavre") || lower.contains("relaxation") {
            return "Allonge-toi sur le dos, les jambes légèrement écartées, les bras le long du corps, paumes vers le ciel. Relâche les épaules, ferme les yeux, et laisse ton souffle ralentir."
        }
        // À genoux / repliée — Balasana (enfant). Avant « down dog » (mots proches).
        if lower.contains("balasana") || lower.contains("enfant") || lower.contains("child") {
            return "À genoux, assieds-toi sur les talons, puis penche le buste vers l'avant jusqu'à poser le front au sol. Étire les bras devant toi et relâche tout le dos."
        }
        // Debout inversée — Chien tête en bas (Adho Mukha Svanasana).
        if lower.contains("adho mukha") || lower.contains("chien") || lower.contains("downward") {
            return "Place les mains et les pieds au sol, puis pousse les hanches vers le haut pour dessiner un V inversé. Tends les jambes sans bloquer les genoux, et relâche la tête entre les bras."
        }
        // Debout — Guerrier (Virabhadrasana I/II).
        if lower.contains("virabhadrasana") || lower.contains("guerrier") || lower.contains("warrior") {
            return "Écarte largement les pieds, fléchis le genou avant juste au-dessus de la cheville, et garde la jambe arrière tendue. Ancre les deux pieds dans le sol, grandis le buste et regarde devant toi."
        }
        // Assise — Sukhasana (tailleur / posture facile).
        if lower.contains("sukhasana") || lower.contains("tailleur") || lower.contains("easy pose") {
            return "Assieds-toi en tailleur, les jambes croisées. Allonge la colonne vers le haut, pose les mains sur les genoux, relâche les épaules vers le bas et respire calmement."
        }
        // À quatre pattes — Chat-vache (Marjaryasana-Bitilasana). Retour Sophie
        // 08-08 : jamais scripté malgré "chien" couvert. Mouvement dynamique
        // (pas une tenue statique) → script dédié, pas un fallback générique.
        if lower.contains("marjaryasana") || lower.contains("bitilasana")
            || lower.contains("chat-vache") || lower.contains("cat-cow") {
            return "Mets-toi à quatre pattes, mains sous les épaules, genoux sous les hanches. À l'inspire, crée un creux dans le dos et regarde vers l'avant. À l'expire, arrondis le dos et amène le menton vers la poitrine."
        }
        return nil
    }

    // MARK: - Fallback générique par orientation (chantier yoga débutant, 2026-08-11)

    /// Postures d'équilibre bras / inversion avancées — un fallback générique
    /// (« Mets-toi debout ») serait FAUX et potentiellement dangereux comme
    /// instruction d'entrée. Silence préservé (comportement actuel), pas de
    /// script forcé. Mots-clés sanskrit.
    private static let excludedFromGenericFallback = [
        "sirsasana", "pincha mayurasana", "adho mukha vrksasana", "bakasana",
    ]

    /// Instruction de placement GÉNÉRIQUE (orientation corporelle seule), pour
    /// toute posture non couverte par `script(forName:language:)` — avant ce
    /// fallback, une posture non scriptée = silence total à l'entrée (~100-130
    /// postures en prod contre 5 scriptées). Même principe et mêmes familles de
    /// mots-clés que `YogaIllustration.fallbackOrientation` (décision D1 party
    /// POC 2026-06-05), repris indépendamment ici (pas d'import croisé, zéro
    /// risque sur le fallback visuel). Persona Inès (party) : guide l'entrée
    /// seulement, reste bref — pas de description de bienfaits.
    static func genericPlacement(forName name: String?, language: String) -> String? {
        guard language.lowercased().hasPrefix("fr") else { return nil }
        guard let lower = name?.lowercased() else { return nil }
        // "sirsasana" (headstand) ≠ "janu sirsasana"/"eka pada sirsasana" (flexions
        // avant assises au suffixe sanskrit homonyme) — ne pas exclure ces dernières.
        let isHeadstandFamily = lower.contains("sirsasana") && !lower.contains("janu") && !lower.contains("eka pada")
        guard !isHeadstandFamily,
              !excludedFromGenericFallback.contains(where: { $0 != "sirsasana" && lower.contains($0) })
        else { return nil }

        let allFoursKeys = ["table", "quatre pattes", "all fours", "tabletop"]
        let lyingKeys = ["savasana", "supta", "jathara", "setu", "sarvangasana", "halasana",
                         "viparita", "matsyasana", "dhanurasana", "salabhasana", "bhujangasana",
                         "ananda balasana", "allongé", "allonge", "couché", "couche",
                         "sur le dos", "sur le ventre", "lying", "reclining", "supine", "prone"]
        // "konasana"/"dandasana" bruts retirés (2026-08-11) : suffixes sanskrit génériques
        // qui matchaient à tort des postures DEBOUT (trikonasana, utthita parsvakonasana
        // contiennent "konasana" ; chaturanga dandasana contient "dandasana") — ne garder
        // que les formes composées non-ambiguës, réellement assises.
        let seatedKeys = ["sukhasana", "padmasana", "vajrasana", "baddha konasana",
                          "upavistha konasana", "paschimottanasana", "marichyasana", "navasana",
                          "gomukhasana", "siddhasana", "virasana", "agnistambhasana", "assis",
                          "assise", "seated", "tailleur", "lotus", "à genoux", "a genoux",
                          "genoux", "kneeling"]

        if allFoursKeys.contains(where: lower.contains) {
            return "Mets-toi à quatre pattes, mains sous les épaules, genoux sous les hanches."
        }
        if lyingKeys.contains(where: lower.contains) {
            return "Allonge-toi sur le dos ou le ventre selon la posture, et installe-toi confortablement."
        }
        if seatedKeys.contains(where: lower.contains) {
            return "Assieds-toi au sol, colonne allongée."
        }
        return "Mets-toi debout, pieds ancrés dans le sol."
    }
}
