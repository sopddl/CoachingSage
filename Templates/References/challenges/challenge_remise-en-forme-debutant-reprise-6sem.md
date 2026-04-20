# Challenge Report : remise-en-forme-debutant-reprise-6sem

## Verdict
Template de très bonne qualité, bundlable en l'état. Structure pédagogique solide, cohérence interne irréprochable, alignement ACSM robuste, sécurité bien documentée. Trois ajustements mineurs recommandés avant production : clarifier la progressivité des pompes classiques (W5-W6), expliciter un repère RPE sur les étirements pour éviter les dépassements, et ajouter une mention des douleurs d'adaptation courantes (DOMS post-W1).

---

## Issues critiques (bloquantes pour bundle)
Aucune issue critique détectée.

---

## Issues importantes (à corriger avant bundle idéal)

- **[W5 J1, W6 J1]** Pompes classiques « transition » : progression ambitieuse. L'énoncé « 5 classiques + 5 sur genoux » puis « 8 classiques (ou 5 classiques + reste) » en W6 laisse trop de latitude. Recommandation : spécifier un palier intermédiaire clair (ex. W5 J1 : « 3-5 classiques selon capacité + complément genoux »). Risque : débutant force 8 pompes classiques en W6 J1 et se blesse avant la séance phare.

- **[W5 J3]** « Deep squat hold » 30 sec : notation maladroite. Il faut clarifier : c'est un mouvement d'étirement statique (mobilité) ou un test de force ? Talon collé au sol est un marqueur de mobilité chevilles/hanches, correct. Mais le contexte « renforcement léger » et la mention « agripper un poteau » suggèrent une instabilité d'équilibre qui n'est pas documentée en sécurité. Recommandation : renommer « Squat profond tenu (mobilité) » et ajouter « arrêter immédiatement si douleur genou antérieure ».

- **[W5 J3, W6 J3]** Manque d'instruction RPE/intensité sur les étirements « avec bras levé ». « Fente basse avec bras levé (deep lunge thoracic rotation) » : aucune notion d'amplitude tolérée. Risque : débutant force en étirement de fléchisseur de hanche et se blesse. Recommandation : ajouter « Sensation : léger étirement douloureux tolérable (4/10), jamais douleur vive. »

---

## Issues mineures (nice-to-have)

- **[W1 à W6]** Safety_notes cite « FC repos augmentée de 10 bpm = surcharge », mais aucune formule simple de FC cible n'est fournie au-delà du théorique. La mention « 50-70% FCmax » est utile mais il faudrait un exemple concret : ex. « À 50 ans : FCmax ~170, cible marche ~85-120 bpm ». Actuellement peu accessible au novice sans calculatrice.

- **[W1 J1]** Warmup « 5 min marche lente + 10 cercles chevilles + 10 rotations bras » = 8 min total annoncé. Chronomètre peu précis : « cercles chevilles + rotations bras » en réalité ~3-4 min selon tempo. Recommandation : spécifier tempo (ex. « 2 sec par cercle »).

- **[W2 J3]** Bird-dog notation : « À 4 pattes, tendre le bras droit et la jambe gauche simultanément ». Pas de clarification de la respiration (très important pour un mouvement de gainage anti-rotation). Ajouter : « Inspirer à 4 pattes, expirer en tendant bras/jambe, inspirer en revenant. »

- **[W3 à W5]** Calf raises : aucune mention de stabilité (risque de perte d'équilibre chez un sédentaire). Ajouter : « Garder la main en contact léger sur un dossier ou mur pour l'équilibre si besoin. »

- **[W4]** Cutback week J5 : "Observe : tu te sens moins fatigué après 25 min qu'en W1 ?" — cette affirmation est correcte mais le contrast avec l'absence de marche en W1 (marche n'existait pas en W1 jour 5 puisqu'on faisait 15 min). Reprendre pédagogiquement : « Observe : tu récupères plus vite après 25 min qu'après 20 min en W2 ? »

---

## Manques notables

- **Indicateurs de surcharge post-W1 oubliés** : Safety_notes liste 5 signes de surcharge (FC repos, courbatures, sommeil, etc.) mais aucun n'est rattaché au moment où il apparaît. DOMS massives sont attendues 24-72h post-W1 chez un sédentaire : citer explicitement « Courbatures W1-W2 : normales, signe d'adaptation, disparaissent en 72h. Ne pas interrompre le plan. » pour rassurer.

- **Continuité post-W6 absente** : Checklist finale est excellente mais aucun lien vers un programme suivant (« si cible atteinte, consulter le plan 'Running débutant C25K' ou 'Musculation poids du corps intermédiaire' »). Manque une phrase de transition/redirection.

- **Absence de dégression en cas d'absence prolongée > 2 semaines** : Safety_notes mentionne « reprendre en W3 ou W4 selon comment tu te sens » mais pas de clarification : faut-il refaire W1 complètement ou juste les exercices de mobilité ? Recommandation : ajouter un flowchart léger.

- **Absence de repère tactile pour les pompes classiques** : Aucune mention des sensations (tremblement involontaire des pectoraux = stop, signe d'épuisement du muscle). Ajouter : « Pompes classiques : arrêter avant tremblements ou perte de forme (dos qui s'affaisse). »

---

## Scores (sur 10)

- **Cohérence interne : 9.5/10**  
  Duration_weeks = 6 ✓, weeks.count = 6 ✓. Progression respecte la règle 10-20% rigoureusement (W1→W2 = +15%, W2→W3 = +18%, W3→W4 = -15% cutback, W4→W5 = +20%, W5→W6 = maintien). Chaque principle de progression_logic est matérialisé dans les weeks (squats W1, bird-dog W2, fentes W3, planche classique W5). Safety_notes ↔ rest_seconds : repos sur renforcement respecte ACSM (45-60 sec sur exercices iso/dynamiques). **-0.5 : progression pompes classiques W5-W6 insuffisamment graduée.**

- **Alignement référentiel : 9/10**  
  Plan adresse ACSM 2026 debutant (40% cardio / 40% renforcement / 20% mobilité ✓). Volume cardio cohérent C25K (W1 15 min → W6 30 min progression lente et fondée). Patterns musculaires couverts : squat ✓, pont fessier (hinge) ✓, pompes (push H) ✓, bird-dog (stabilité) ✓, fentes (unipodal) ✓. Manque : pull H/V non critiques pour débutant, acceptable. Cutback W4 obligatoire appliqué ✓. Progression 10-20% documentée et respectée. **-1 : absence de "pull" pattern (traction, tirage), non bloquant pour remise en forme mais théoriquement complet ACSM .**

- **Sécurité : 8.5/10**  
  Drapeaux rouges exhaustifs (douleur thoracique, vertige, douleur articulaire, lombalgies). Test de la parole intégré (ACSM standard ✓). Hydratation et échauffement non-négociables documentés. Signes de surcharge détaillés. **-1 : manque clarification DOMS post-W1, peut affoler un débutant. -0.5 : Deep squat hold W5 risque d'instabilité non anticipée.**

- **Pédagogie : 8.5/10**  
  Progression par paliers claire (W1 → squats + pompes genoux → W5 pompes classiques). Instructions précises (« descente 2 sec, remontée 1 sec », « genou dans l'axe »). Respiration documentée partiellement (marche ✓, bird-dog manque, étirements manquent). Checklist W6 excellente, auto-évaluation 5 critères pertinente. **-1.5 : progression pompes classiques trop rapide, respiration bird-dog absente, dégression post-interruption > 2 sem peu guidée.**

- **Global : 8.75/10**  
  Template solide, pédagogiquement robuste, aligné ACSM et sûr pour la cible. Trois ajustements mineurs (pompes classiques, RPE étirements, DOMS anticipée) suffisent pour un bundle sans risque. Les forces : progression méthodique, sécurité exhaustive, ratio équilibré, cutback well-motivated. Les faiblesses : graduations pompes classiques et respiration sous-documentées.