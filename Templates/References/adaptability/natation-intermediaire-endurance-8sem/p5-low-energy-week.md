# Adaptability : natation-intermediaire-endurance-8sem + p5-low-energy-week

## Rigidity score
**7/10**

Le template contient des mécanismes de flexibilité intégrés (cutback W5, recommandation de pause, escalade de volume progressive) mais la logique de progression hebdomadaire est rigide : chaque semaine cible un objectif spécifique (W1 test, W2 500 m, W3 respiration bilatérale, W4 intervalles, W6 seuil, W7 900 m, W8 1000 m). Adapter une semaine intermédiaire (ex : W4 ou W6) sans briser la cohérence de la progression demande de repositionner les semaines ultérieures ou d'accepter un décalage. Le template se laisse patcher, mais pas élégamment en plein milieu du plan.

## Patch approach

Stratégie : identifier la semaine actuelle dans le cycle, réduire le volume et l'intensité de cette semaine de 35-40% (approche plus agressive que le cutback standard W5 de -15%, car fatigue multifactorielle), **maintenir les drills technique fondamentaux** pour éviter une perte de qualité motrice, et **décaler d'une semaine la progression globale** (W4 → W4bis allégée, puis redémarrage W5 avec objectifs de W4 révisés à la baisse). Exemple concret fourni pour W4 (semaine d'intervalles, souvent énergivore mentalement) et W6 (semaine de seuil, haute demande cardiovasculaire).

## Concrete modifications

**Cas 1 : Semaine fatigue = W4 (intervalles + 700 m)**

- **W4 J2 (Pyramide courte)** : réduire la pyramide de 450 m à 250 m. Nouvelle structure : 25 m + 50 m + 75 m + 50 m + 25 m (repos 60 sec entre chaque, au lieu de 45 sec). Supprimer le drill catch-up (économiser l'attention mentale). Garder le drill 6-3-6 (2 séries au lieu de 4). Remplacer les 100 m de nage technique par 50 m seulement.
  
- **W4 J5 (700 m continu)** : réduire à 500 m continu. Allure identique (endurance standard). Garder le drill Sculling (30 sec à 25 m × 4 = maintien du catch). Supprimer le drill Catch-up. Conserver la nage de récupération 100 m.

- **Volume hebdo W4bis** : 250 m + 500 m + échauffements/drills = ~1100 m total (vs 1200-1300 m en W4 standard). **Réduction ~12%**, acceptable pour récupération sans détérioration technique.

- **Redémarrage W5** : au lieu de cutback (-15% de W4), faire une W5 allégée qui contient l'objectif endurance de W4 (700 m) mais sans intervalles. Séance J2 = drill technique + 700 m continu ; séance J5 = drill technique + 600 m continu. Cela maintient la progression vers 1000 m tout en donnant un bonus de récupération supplémentaire. Semaine W6 ensuite relance avec seuil + 800 m (W6 standard).

---

**Cas 2 : Semaine fatigue = W6 (seuil 4×150 m + 800 m)**

- **W6 J2 (Séries seuil)** : réduire les 4×150 m à 3×100 m à allure endurance standard (pas allure seuil). Ajouter un drill Tarzan court (25 m × 2) pour garder la conscience de propulsion sans surcharge. Total : 300 m d'intervalles doux au lieu de 600 m seuil.

- **W6 J5 (800 m continu)** : réduire à 600 m continu. Allure endurance (non seuil). Garder les drills d'entrée (Catch-up drill 25 m × 4).

- **Volume hebdo W6bis** : 300 m (au lieu de 600 m seuil) + 600 m (au lieu de 800 m) = ~1200 m nage pure + drills (~1450 m total vs ~1550 m W6 standard). **Réduction ~7%**, légère mais intentionnelle.

- **Rattrapage W7** : W7 passe de "900 m + technique sous fatigue" à "900 m + 4×150 m seuil" (absorber les intervalles manqués de W6bis). Cela repousse W8 d'une semaine si nécessaire, ou W7 devient plus exigeante mentalement avec un warning aux notes.

---

## Rigidity issues

1. **Progression linéaire figée** : le template construit une escalade hebdomadaire de volume (W1 200m → W2 500m → W3 600m → W4 700m → W5 500m cutback → W6 800m → W7 900m → W8 1000m). Insérer une semaine allégée en milieu de cycle (ex : W4bis) crée une "marche arrière" qui déstabilise visuellement la progression. Solution : repositionner le cutback W5 pour qu'il absorbe la fatigue accumulée, mais cela change la sémantique (cutback devient "low-energy recovery week" au lieu de "technique consolidation").

2. **Ordre pédagogique des drills** : progression_logic stipule que respiration bilatérale dès W3 uniquement, car "gestion respiration unilatérale doit être automatisée". Si on réduit W4, on ne risque pas de casser W3 (acquis), mais on repousse le travail de seuil à W7 ou W8, ce qui réduit le temps de consolidation avant l'objectif 1000 m. Le template assume une "fenêtre d'apprentissage" (W4 = intervalles pour préparer W6 seuil pour préparer W7-W8 1000 m) ; passer W4 à "endurance lisse" casse cette fenêtre.

3. **Safety_notes assume une allure minimale** : "respiration accrue mais contrôlée en seuil" et "allure seuil 10-15 sec/100 m plus rapide qu'endurance". En W6bis, si on réduit seuil à endurance lisse, on perd le stimulus de puissance aérobie et l'adaptation à "maintenir une allure inconfortable" — fondamentale pour faire les 1000 m sans panique en W8. Cela crée un risque indirect : arriver à W8 moins préparé au travail cardiovasculaire soutenu.

4. **Décalage du pic W8** : si W6bis et W7 bougent, la séance phare 1000 m (W8 J5) arrive avec un décalage potentiel de 1-2 semaines. Le template note "tapering de 2-4 jours suffisant pour 8 semaines" — mais cela assume que W8 arrive pile 8 semaines après W1, pas à la semaine 9-10.

## Contradictions

1. **safety_notes vs réduction W6 seuil** : la note "épaules de l'intermédiaire : tendons coiffe rotateurs sollicités de façon inhabituelle en W6-W7. Si fatigue profonde épaule persistant 48h après, réduire 20% la séance suivante" — elle propose une **baisse réactive et localisée** (juste la séance suivante), pas une baisse **proactive de toute la semaine**. Adapter "basse énergie globale" en réduisant le seuil de W6 n'évalue pas le signal d'alerte épaule. Contradiction : le template dit "surveille l'épaule et ajuste", mais l'adaptation "low-energy week" assume une fatigue **systémique** (sommeil, stress, boulot), pas une fatigue locale. Il faudrait vérifier que l'épaule n'est pas déjà fragile avant de réduire.

2. **progression_logic RÈGLE DES 10-15%** : stipule "augmentation du bloc endurance principal limitée à 100-200 m par semaine" et "jamais deux hausses simultanées (volume + intensité)". Réduire W4 ou W6 crée une **baisse** au lieu d'une hausse, ce qui n'est pas adressé par la règle. La question implicite : doit-on "rebondir" à +200 m en W5 pour compenser la réduction W4 ? Le template n'a pas de règle de "rattrapage après allègement". (Attention : cutback W5 est volontaire et connu à l'avance, pas une adaptation post-facto.)

3. **Checklist d'autonomie W8** : assume que W7 900 m a été complété comme prévu. Si on décale W7 ou qu'on réduit W6, l'athlète arrive à W8 sans avoir tenu 900 m en continu. La checklist dit "(1) Je tiens une allure régulière sur l'ensemble des 1000 m", mais sans passe 900 m, c'est une extrapolation, pas une certification. Le template crée une **dépendance cachée** entre W7 et la validité de W8.

4. **Recommandation 3e séance W4-W7** : progression_logic recommande une 3e séance libre "400-500 m easy" dès W4. Si on réduit W4, il faut aussi réduire ou supprimer cette 3e séance, ce qui accélère la perte de consolidation motrice (le template dit "espacement > 72h réduit la consolidation mémorielle"). Contradiction : réduire W4 est compatible avec l'objectif de "récupération" mais hostile à l'objectif de "motor learning" posé par la recommandation de 3e séance. L'adaptation force un choix : récupération **OU** apprentissage moteur, pas les deux.

---

**Résumé adaptabilité** : le template **peut** être adapté à "low-energy week" en réduisant volume et intensité, mais cela crée des décalages en cascade (W5 repositionnée, W7-W8 décalées) et des contradictions légères entre récupération (baisse W4/W6) et consolidation motrice (besoin de 3e séance + progression respiration W3-W7). Une "vraie" adaptation exigerait de réécrire la logique de progression W4-W8, ce qui dépasse un simple patch et rentre dans la reconstruction. **Le template n'est pas conçu pour absorber une semaine fatigue en milieu de plan de façon transparente.**