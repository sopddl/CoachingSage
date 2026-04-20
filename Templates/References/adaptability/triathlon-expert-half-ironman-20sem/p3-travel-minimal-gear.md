# Adaptability : triathlon-expert-half-ironman-20sem + p3-travel-minimal-gear

## Rigidity score
**3/10**

## Patch approach
Le template est fondamentalement rigide sur l'équipement (piscine, vélo, home-trainer) et la structure à 3 disciplines parallèles. Une semaine voyage sans accès à ces ressources exige de reconstruire quasi entièrement la semaine, pas simplement de patcher des séances. Les contraintes sécurité (casque obligatoire vélo, drapeaux rouges cardio) rendent l'adaptation dangereuse si elle improvise du cardio intense sans monitoring.

## Concrete modifications
Impossible de proposer un patch crédible pour cette semaine sans reformuler entièrement le plan. Le template ne tolère pas d'absence simultanée de piscine + vélo + accès à des zones de run sécurisées. Exemples concrets de ce qui casse :

- **W<N> J1 (Natation)** : 1900 m continu ou séries longues = zéro substitution crédible en bande élastique. Swimming patterns ne se transfèrent pas à du dry-land élastique sans perte majeure de spécificité.
- **W<N> J2 (Vélo)** : Sortie 110-160 min Z2-Z4 sur home-trainer ou route = aucune alternative viable avec bande élastique (pas de cardio soutenu long possible en salle d'hôtel).
- **W<N> J3 (Course)** : Run long (75-105 min) en ville inconnue, potentiellement sans parcours safe = risque de blessure ou de navigation compromettant le seuil.
- **Brick séances** : Transitions et T1/T2 simulées = impossible sans vélo.
- **Renforcement ischio-jambiers** (Nordic curl, single-leg squat) : Réalisable avec élastique, mais perte de progressivité vs template.

## Rigidity issues
- **Spécificité discipline natation = zéro substitut** : Le template bâtit l'adaptabilité nage autour de la piscine (1900 m continu dès W6, drill EVF, sighting). Aucun équivalent métabolique ou technique en salle sèche. Reculer la nage de 1 semaine enfreint la **progression_logic** (point 1 : parallélisme des 3 disciplines chaque semaine).
- **Vélo 90-160 min : simulation home-trainer obligatoire** : Même avec home-trainer (absent ici), le plan base la progression sur FTP. En bande élastique, impossible de contrôler l'intensité Z2-Z4. Un cardio max durable sur élastique nage (piscine absente) crée un vide structurel.
- **Cutback weeks W4, W8, W12, W16 doivent être honorées** : Si on saute une semaine entière (voyage), le cutback disparaît et **progression_logic point 3** se casse (risque de blessure de surmenage accru).
- **Doubles séances AM/PM (4h minimum entre 2)** : Recommandation W1-W20. En chambre d'hôtel avec bande élastique seule, aucune séance ne dépasse 30 min → doubles séances = temps mort ou surcharge artificielle.
- **Safety_notes : casque obligatoire course à pied** : Le template exige casque pour tout sortie vélo (règle World Triathlon). Hors vélo disponible. Pas de clause pour "si pas d'équipement, sauter la séance" = contradiction muette.

## Contradictions
- **Absence de piscine ↔ natation obligatoire parallèle** : W1-W20 natation progresse Z2 → Z3 → race pace. Semaine voyage sans piscine = impossible de maintenir la progression "natation 1900 m continu dès W6" → deux choix : (1) reporter natation post-voyage (=scinder le plan), (2) inventer un équivalent cardio sec (=perte totale de spécificité nage). Template ne propose ni l'un ni l'autre.

- **Progression_logic point (2) : "10-15%/semaine"** : Dépend du suivi FTP vélo et VMA run. En voyage sans équipement, impossible de calibrer. La reprise après voyage → risque de dépasser 15% de montée (rebound injuries).

- **Brick sessions fondamentales W3-W20** : Le template stipule (summary) "Brick sessions introduites dès W3 et progressivement rallongées." Sans vélo, impossible d'honorer cette progression. Passer une ou deux bricks coupe l'adaptation transition vélo → run (point 1 progression_logic : "parallélisme").

- **Safety_notes : "FC repos + 8-10 bpm au réveil sur 3 jours = overreaching signal"** : En voyage avec mobilité réduite (chambre hôtel, bande, corde), le stress supplémentaire non-entraînement (jet lag, sommeil perturbé, hydratation inconnue) risque de déclencher ce signal même si l'entraînement réel est léger. Template ne distingue pas "overreaching d'entraînement" vs "surcharge vie". Impossible à appliquer fidèlement.

---

## Recommandation (non-patch)
**Ce template ne s'adapte pas élégamment à une semaine voyage sans équipement.** 

Trois options pour l'utilisateur :

1. **Reporter la semaine** (meilleur choix si voyage < 7 jours) : Décaler le plan de +1 semaine post-voyage. Honorer l'intégrité cutback/progression.

2. **Semaine de récupération préemptive** : Si voyage prévu à W9-W10 (pic volume), remplacer par une **cutback agressive** (-30% volume) avant voyage, reprendre post-voyage à W12 intensification. Cela utilise la contrainte comme signal de récupération.

3. **Semaine de remplacement allégée** : Demander à l'utilisateur de construire une semaine ad hoc (mobilité 30 min/jour, run 20-30 min sur n'importe quel terrain safe avec montre GPS, corde à sauter 3 × 2 min Z5 courts). **Mais ce n'est pas un patch du template**—c'est une refonte manuelle.

Le template reste **expert-ready mais équipement-dépendant** : aucune clause de dégradation gracieuse en cas de contrainte matérielle.