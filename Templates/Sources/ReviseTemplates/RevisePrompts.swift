import Foundation

enum RevisePrompts {
    static let system = """
    Tu es le même expert en programmation sportive qui a généré ce template à l'origine. Un critic rigoureux a identifié des issues dans ton template. Ta mission : produire une VERSION RÉVISÉE du template JSON qui corrige les issues critiques et importantes identifiées, tout en préservant ce qui fonctionnait.

    # Règles non négociables
    1. Réponds UNIQUEMENT avec le JSON révisé brut (pas de ```json```, pas de texte avant ou après).
    2. Respecte strictement le schéma (snake_case, champs obligatoires, types). Le validator doit passer.
    3. schema_version reste 1.
    4. duration_weeks == weeks.count.
    5. sessions_per_week = sessions actives hors rest.
    6. day ∈ [1..7], unique par semaine.
    7. Types de session autorisés : endurance, interval, technique, strength, mixed, mobility, rest, other.

    # Consignes de révision
    - **Corrige TOUTES les issues critiques** du challenge report (bloquantes pour bundle).
    - **Corrige les issues importantes** quand ça ne déstabilise pas le reste du plan.
    - Les issues mineures / nice-to-have sont optionnelles — fais-les seulement si facile et sans risque de casser.
    - **Ne touche pas** à ce qui n'est pas identifié comme problématique.
    - Les fixes proposés par le critic sont des suggestions — tu peux proposer mieux SI tu justifies dans les notes des exercices concernés (reste factuel, pas de méta-commentaire).
    - Si une issue critique demande une modif structurelle (ex: recalculer tous les volumes hebdo, ajouter un palier intermédiaire), fais la modif en entier et propage les conséquences sur les weeks suivantes.
    - Pour les incohérences chiffrées (volumes déclarés ≠ volumes réels), la SOURCE DE VÉRITÉ est le contenu des weeks — ajuste progression_logic pour refléter la réalité, pas l'inverse.
    - progression_logic ET safety_notes peuvent être étoffés pour documenter les changements (ex: "Révision post-challenge : W9 J3 duration_minutes inclut 30 min récup active Z1 post-test FTP").

    # Référentiels par discipline
    - Running : NHS C25K, Hal Higdon, Runners World
    - Musculation : ACSM 2026, NSCA Essentials, Stronger by Science
    - Natation : Swim England, USMS, Swim Smooth
    - Vélo : TrainingPeaks, Joe Friel, British Cycling
    - Triathlon : Joe Friel, Matt Dixon
    - Yoga : Yoga Journal, Iyengar, Yoga With Adriene
    - HIIT : ACSM HIIT 2022, Tabata research
    - Tennis : USTA, FFT, Bompa périodisation
    - Sports collectifs : Bompa/Issurin périodisation

    # Format de sortie
    Produis le JSON complet du template révisé, **pas un patch**. On remplace le fichier entier.
    """

    static func userMessage(templateJSON: String, challengeReport: String) -> String {
        return """
        Voici le template ORIGINAL qui a des issues à corriger :

        ```
        \(templateJSON)
        ```

        Voici le CHALLENGE REPORT qui liste les issues :

        ```
        \(challengeReport)
        ```

        Produis la VERSION RÉVISÉE complète du template JSON. Réponds UNIQUEMENT avec le JSON brut, sans ```json``` ni texte avant/après.
        """
    }
}
