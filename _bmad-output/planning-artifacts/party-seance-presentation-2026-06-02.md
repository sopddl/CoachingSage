# Party — Refonte de la présentation des séances (`SessionDetailView`)

**Date** : 2026-06-02
**Sujet** : rendre la présentation/exécution des séances plus ergonomique et user-friendly, sur tous les sports.
**Trigger** : Sophie au test simu — « la présentation des séances est encore peu ergonomique et user-friendly ». Captures réelles : running glossary, running v3, strength illustrations (FR).
**Statut** : ✅ décisions tranchées. Prête pour rédaction des stories S1→S5. **Pas de code lancé** (règle party).
**Sports concernés** : running, cycling, swimming, triathlon, strength, yoga, HIIT, hiking. **Exclus** : tennis, football (non développés).

---

## Casting

**User personas** (source `product-brief-CoachingSage-2026-03-21.md` + ajouts party) :
- ⚖️ **Nathalie** — reprenante 52 ans : scannabilité, anti-surcharge, jargon fait peur.
- 💪 **Maxime** — muscu 22 ans : séries/reps/charge tout de suite, coche rapide.
- 🏃 **Philippe** — runner 48 ans : zones/Daniels OK mais veut durée + séance-clé sans scroller.
- 🧘 **Inès** — yoga 38 ans : séance non-chiffrée (ni zone ni charge), calme visuel.
- 🔥 **Dorian** — HIIT : circuits / tours / work-rest, vibe minuteur.
- *(Sophie = voix triathlète multi-sport dans la salle.)*

**Produit / tech** : 🎨 Léna (UX mobile), 📱 Karim (iOS SwiftUI), 📋 Hugo (PM).

**Matos** : 3 captures simu `/tmp/sess_*`, parties amont (`party-seances-dashboard-2026-05-07`, `party-dashboard-refonte-2026-05-30`), stories 3.17/3.18/3.19 (SessionDetail V2/V3 : hero, stats, « pourquoi », timeline, illustrations, glossaire). **Rework TailorSage HUB+FOCUS** réutilisé.

---

## Problème (cadrage)

L'écran de détail empile toute l'info au même niveau (grille de stats taillée cardio, qui tronque/affiche du vide ; « pourquoi » caché ; longue timeline), si bien qu'on **ne peut ni scanner d'un coup d'œil ce qu'on va faire, ni faire confiance aux chiffres** — quel que soit le sport. **Recadrage Sophie** : ce n'est pas qu'un problème d'affichage, **chaque sport a un mode d'usage différent pendant la séance** (audio pour courir, tactile pour la muscu, minuteur pour le HIIT, flow pour le yoga, montre pour la nage). Donc l'écran fait **deux jobs** : PRÉPARER (lire/comprendre à l'avance) et EXÉCUTER (être guidé pendant, mode propre au sport).

---

## Tour de table — convergences

- La **grille de stats est un gabarit cardio déguisé en universel** → « Zone — » vide en strength, absurde en yoga, « Blocs » ambigu en HIIT.
- L'**info actionnable est enterrée** sous le hero déco + stats + « pourquoi » replié.
- **Bugs = perte de confiance** : « Durée 50… » tronquée sur les 3 écrans.
- **Tension densité** : Maxime/Philippe veulent + de données, Nathalie/Inès veulent - et du calme → résolu par HUB (scannable) + FOCUS (détail à la demande).
- **Pain Decathlon (Sophie)** : on perd le début du 1ᵉʳ exo car rien ne l'annonce avant → règle « anti-Decathlon ».

---

## Modèle de design retenu — **HUB + FOCUS** (réutilisé de TailorSage)

> Deux écrans complémentaires : un **HUB** (vue d'ensemble) et un **FOCUS** plein écran (swipe d'une étape à l'autre, mode « je cuisine »).

**HUB = PRÉPARER** (universel, 1 écran data-driven, zéro exception) :
- Hero **slimmé** (−50 %) : sport + « Semaine 3 · Jour 2 » + **durée totale** (fix troncature).
- **3 stats agnostiques**, jamais de case vide : **Durée · Intensité (effort 1-5 commun) · Format** (case caméléon : « 3 blocs » / « 3 tours · 40-20 » / « 5 postures · 2 min » / « 4×800 »).
- **« Pourquoi cette séance ? » en 1 ligne visible** + détail dépliable.
- **Liste des blocs** avec statut ✓/◐/○ + barre de progression + tap = saute au bloc.
- Bouton **« ▶ Démarrer / Reprendre l'étape N »**.

**FOCUS = EXÉCUTER** (plein écran, identique partout) : points ●◐○ (position/N), illustration grand format, sous-instructions, ‹ Précédent / Suivant ›, « ✓ Marquer fait ». Seule **la façon d'avancer** change :

| Façon d'avancer | Sports | Comportement |
|---|---|---|
| 👆 **Manuel** (swipe / marquer fait) | strength (+ défaut universel) | mode « je cuisine » TailorSage |
| ⏱️ **Minuté auto** | HIIT (work/rest), yoga (tenue de pose) | l'étape avance au chrono |
| 🔊 **Audio-mené** | run / vélo / rando | avance au temps/distance, **voix** annonce, écran glançable/verrouillable |
| ⌚️ **Au poignet** | swimming | le FOCUS vit sur la **montre** (tél au bord) |

→ Triathlon **hérite** du mode de la discipline. **Une seule paire d'écrans, 3 façons d'avancer + relais montre.**

**Règle « anti-Decathlon »** : en mode minuté et audio, FOCUS **pré-annonce l'étape suivante avant qu'elle démarre** (« Prochain : Goblet squat · 4×8. Prêt ? 3·2·1 »), surtout pour le 1ᵉʳ exo.

**Principe audio unificateur** : l'app **ne possède jamais la musique**. Le user joue SA musique (Spotify/Apple Music/podcast) ; on glisse voix/bips **par-dessus via audio ducking** (`AVAudioSession`). Vaut pour run, HIIT et yoga.

---

## Décisions verrouillées

| # | Décision | Raison | Conséquence |
|---|---|---|---|
| T1 | On conçoit **tout le design** ici (PRÉPARER + EXÉCUTER) | besoin d'une vision complète | stories S1→S5 cadrées d'un coup |
| T2 | Swim V1 = **au poignet** (Apple Watch ; autres montres = hors contrôle) | tél inutilisable dans l'eau | app Apple Watch = chantier S5 |
| T3 | App **ne joue pas la musique** → user choisit la sienne, voix par **ducking** | gratuit, zéro droits, marche partout | pas d'intégration musicale à construire |
| D1 | **V1 trilingue FR / EN / ES** (audio + app) | cible marché | ⚠️ localisation ES = **chantier séparé** (xcstrings + 40 templates + onboarding), pas un acquis |
| D2 | Voix **ON discret**, user choisit **homme/femme** | l'intérêt du mode audio | sélecteur voix + invite download voix premium iOS |
| D3 | **Effort 1-5 unifié** dans la case stats | rend la case universelle | détail technique (zones/Daniels) reste *dans l'exo* |

**Tech voix** : `AVSpeechSynthesizer` (gratuit, on-device), homme/femme, FR/EN natifs OK, ES dispo ; voix Premium/Enhanced = bonnes (pas studio) ; prononciation de secours par terme si besoin.

**Garde-fou EU MDR** : pas de claim médical ; « meilleure allure » et estimations restent **indicatives**.

---

## Prochaines actions — stories (ordre le plus efficace, chacune réutilise la précédente)

1. **S1 — HUB** : refonte écran détail en vue d'ensemble (hero slim · 3 stats agnostiques · « pourquoi » visible · progression · liste blocs · **fix Durée tronquée** · bouton ▶). *Socle universel.*
2. **S2 — FOCUS + avance Manuel** (swipe + marquer fait), réutilise composant TailorSage → couvre **strength** tout de suite.
3. **S3 — avance Minuté** (HIIT work/rest + tenue yoga) + **règle anti-Decathlon**.
4. **S4 — avance Audio** (TTS + ducking + sélecteur voix H/F + invite download) → run/vélo/rando. *Chantier.*
5. **S5 — App Apple Watch swim** (FOCUS au poignet + relais). *Chantier à part.*

**Dépendances / chantiers séparés à scoper** :
- 🌍 **Localisation ES complète** (préalable à « V1 trilingue » réel) — story dédiée.
- ⌚️ **App Apple Watch** (préalable à S5) — chantier infra.
- 🔤 **Format-aware templates** (métadonnée « tours/tenue/blocs » par séance) — alimente la case Format de S1 et l'avance Minuté de S3.

**Non fait** (règle party) : pas de code, pas de branche, pas de PR. Lancement implem = sur « on attaque » explicite de Sophie.
