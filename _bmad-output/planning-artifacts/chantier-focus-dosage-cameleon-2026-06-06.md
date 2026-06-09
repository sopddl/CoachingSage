# Chantier — FOCUS : ligne « dosage / intensité » caméléon par mode

**Date d'ouverture** : 2026-06-06 (décision Sophie suite revue comité, cf `revue-comite-focus-multisport-2026-06-06.md`)
**Statut** : DRAFT à scoper (pas démarré).
**Origine** : finding **n°1 du comité users** — l'écran FOCUS dit toujours QUOI + COMBIEN DE TEMPS, presque jamais le **dosage** qui rend la consigne exécutable sans coach.

## Problème
Le mode caméléon par sport s'arrête à l'illustration. Il faut le pousser **jusqu'au dosage** : une info « cible/intensité » visible à côté du chrono (pas dépliée), adaptée par mode.

## Besoin par persona (du comité)
| Persona | Sport | Dosage manquant |
|---------|-------|-----------------|
| Maxime | muscu | **charge** (kg / « comme au dernier set » / champ à noter) + « Série N/total » en haut (comme « Tour N » du HIIT) |
| Dorian | HIIT | **reps ou AMRAP** du tour + **durée de récup** affichée |
| Philippe | running | **allure / zone FC / distance** à l'écran (filet si la voix coupe) — la donnée existe déjà (`targetZone` Z2/Daniels-T dans le modèle !) |
| Inès | yoga | **respirations** (tenue comptée en souffles, pas en s) + **quel côté** (G/D) |

## Tension à arbitrer (densité ⟷ calme)
Maxime veut +chiffres tout de suite ; Inès veut −texte (didactique à la voix). → un même layout ne sert pas les deux : **mode effort chiffré = métriques denses au-dessus du chrono ; mode yoga = alléger + souffle/côté**. Assumer le caméléon jusqu'au dosage.

## Absorbe 2 « quick wins » de la revue (qui en relèvent)
- **B1 — vide écran audio** : le bon remplissage du vide running = afficher **allure/zone** (`targetZone` déjà dispo), pas un générique « suis la voix ». → traité ici.
- **B4 — couleur « Échauffement »** : running affiche « Échauffement footing » en **bleu** car c'est modélisé comme un **exercice** (`.work`), pas une phase `.warmup` (orange). Structurel (échauffement-en-tant-qu'exercice dans les templates running). À trancher dans ce chantier : tinter par sémantique du label, ou normaliser la structure template. (`phaseTint` est sinon déterministe par `phase.kind`.)

## Hors-scope / séparé
- **B2 — jargon glossaire** (glutes / band / mobilité / Récup / Bloc tempo) : entrées `GlossaryEntry` (titleKey+definitionKey FR/EN/ES) **+** passer les puces d'échauffement de `Text(verbatim:)` à `GlossaryRichText`. = **pass glossaire dédiée** (contenu 3 langues), pas ce chantier.
- Bug comportemental : « Avancer » ne saute pas la phase d'échauffement (constaté simu, 3 taps sans effet) → à logger/investiguer séparément.

## NEXT
Scoper la story (modèle de données dosage par mode, layout caméléon, i18n), puis SOPDDL. Décisions produit probables : champ charge (saisie vs lecture), AMRAP vs reps cible HIIT, comptage souffles yoga.
