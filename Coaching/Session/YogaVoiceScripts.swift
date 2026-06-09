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
        return nil
    }
}
