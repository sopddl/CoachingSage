#!/usr/bin/env python3
"""Génération build-time du marqueur `deload_weeks` — chantier densité B, G8 (2026-07-02).

Le bundle prod n'a AUCUN marqueur structurel de semaine décharge/taper (l'info
n'existe que dans les `theme`/`goal` localisés). G8 (revue doctrine 07-02) impose :
jamais de densification des semaines décharge/taper → on régénère `deload_weeks:
[Int]` top-level par template, détecté depuis theme/goal EN, revu une fois à la main
(overrides explicites ci-dessous), verrouillé ensuite par DeloadWeeksMarkerTests.

Biais assumé : en cas d'ambiguïté on INCLUT (faux positif = une semaine non
densifiée, sans risque ; faux négatif = doctrine-risk).

Usage : generate_deload_weeks.py [--check]  (--check = dry-run, table de revue)
"""
import json
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[2] / "Sources/TemplateLoader/Resources/Templates"

# Marqueurs de semaine allégée dans theme/goal EN.
KEYWORDS = re.compile(r"(easy week|recovery week|deload|cutback|taper)", re.I)

# Contextes où le marqueur ne désigne PAS la semaine courante (build adjacent qui
# RÉFÉRENCE une décharge passée/future). Mêmes règles portées dans le filet swift
# DeloadWeeksMarkerTests — garder les deux synchrones.
MARKER = r"(?:deload|cutback|taper)"
WEEK_REF = r"(?:the )?(?:light |w\d+ |week[-\s]?\d+ )?"
EXCLUSIONS = [
    rf"post[-\s]?{MARKER}",                          # « post-deload return » = build
    rf"pre[-\s]?{MARKER}",                           # « pre-taper build », « pre-cutback »
    rf"(?:after|out of|vs\.?|versus) {WEEK_REF}{MARKER}",  # « after the W4 deload », « +30% vs W4 cutback »
    rf"before {WEEK_REF}(?:{MARKER}|recovery week)",  # « before the W8 cutback »
    rf"{MARKER}(?: that starts| arrives)? in w\d+",   # « the deload arrives in W12 »
    rf"toward the {MARKER}",
    r"no competitive taper",                          # yoga W12 : négation explicite
]
EXCLUSION_RES = [re.compile(p, re.I) for p in EXCLUSIONS]


def excluded(text: str, start: int, end: int) -> bool:
    """L'occurrence keyword [start:end) est-elle couverte par un contexte d'exclusion ?"""
    for er in EXCLUSION_RES:
        for m in er.finditer(text):
            if m.start() <= start and end <= m.end():
                return True
    return False


def detect(theme_en: str, goal_en: str) -> tuple[bool, str]:
    for text in (theme_en, goal_en):
        for m in KEYWORDS.finditer(text):
            if not excluded(text, m.start(), m.end()):
                return True, f"[{m.group(0)}] {text[max(0, m.start() - 30):m.end() + 25]}"
    return False, ""

# Revue manuelle (2026-07-02) des 40 tables générées — ajustements explicites.
# add : semaines allégées/compétition que l'heuristique rate (pas de keyword net).
# remove : faux positifs restants malgré les contextes d'exclusion.
#
# Les 6 "remove" ci-dessous (trouvés 2026-07-25, finding audit "des semaines deload
# sont en fait des pics de charge", complété par une review template-quality-reviewer
# qui a débusqué 2 cas supplémentaires par le même balayage) partagent la même cause :
# un mot-clé taper/deload qualifie UNE SEULE séance de la semaine (souvent J1, allégée
# en prépa d'un pic J5), pas le volume hebdo réel — qui est en fait au maximum ou
# proche du maximum du plan. Un simple élargissement des EXCLUSIONS règle certains cas
# mais en casserait d'autres (ex. tennis-beginner W8 a la même tournure EN et EST un
# vrai taper, vérifié par les chiffres) : la distinction n'est pas lexicale, elle
# nécessite de lire le volume réel de la semaine. D'où override manuel plutôt que
# regex plus agressive.
OVERRIDES: dict[str, dict[str, list[int]]] = {
    # W16 = semaine de tournoi (matchs) : jamais densifier une semaine de compétition.
    "tennis-competitive-tournoi-prep-16sem": {"add": [16]},
    # W16 = race week marathon (thème sans le mot taper, goal « arrive fresh »).
    "running-competitive-marathon-16sem": {"add": [16]},
    # W16 = race week cyclosportive (thème « race week, cyclosportive on D7 »).
    "cycling-competitive-cyclosportive-16sem": {"add": [16]},
    # W12 check-in -24 % (goal : « no competitive taper » mais volume réduit de bilan).
    "yoga-competitive-advanced-12sem": {"add": [12]},
    # W6 = séance phare 1h30, volume hebdo MAX du plan (2h20, > W5 2h15). Le "taper"
    # matché ne qualifie que la 1re des 2 séances de la semaine (goal.en : "Light taper
    # on the first session, then the hero session...").
    "cycling-beginner-reprise-6sem": {"remove": [6]},
    # W14 = construction avant affûtage, volume terrain 8-9h comparable à W13 (build,
    # non-deload). Seul le renforcement accessoire est réduit -30%. Le "taper" matché
    # annonce le DÉBUT futur de l'affûtage (goal.en : "Taper starts with strength cut
    # by 30%"), pas une réduction de la semaine courante.
    "football-competitive-saison-regional-16sem": {"remove": [14]},
    # W11 = "dégressive maintien", intensité maintenue (RPE 9-10), volume 19 min à peine
    # sous les pics réels (W7/W10 = 20 min) et au-dessus de builds normales (W5=17,
    # W9=18) — pas une vraie décharge. theme.en : "taper maintenance: intensity kept".
    "hiit-competitive-athletique-12sem": {"remove": [11]},
    # W11 = "semaine pic" du bloc réalisation (théme.fr explicite), ~95% charge cible en
    # J5 — le volume/intensité le plus haut du cycle. Seul J1 est un "affûtage allégée"
    # (3x3 @85%) pour arriver frais au pic J5. theme.en : "Peak week, taper D1-D3...".
    "strength-training-competitive-strength-5x5-cycle": {"remove": [11]},
    # W10 = séance phare 80 km, volume hebdo ~5.3h (le TEXTE du template le dit,
    # goal.en : "Weekly pedaling volume: ~5.3 h") vs ~4.8h en W9 (goal W9 : "Distance-
    # peak... Weekly pedaling volume: ~4.8 h") — +10%, pas une baisse. Le "Taper" ne
    # qualifie que les 2 premières séances (goal.en : "Taper over the first 2 sessions
    # to arrive fresh for the 80 km hero session").
    "cycling-recreational-endurance-10sem": {"remove": [10]},
    # W8 = séance phare 30 min continu, explicitement appelée "pic W8 J5" dans son
    # propre goal.fr (et "peak" en goal.en) — volume course pure 30min, le plus haut du
    # plan (progression donnée par summary.fr : 16→18→18→22→18(W5 deload)→22→30). Le
    # "Tapering" ne qualifie que les 2 premières séances (goal.en : "Tapering on the
    # first two sessions, W8 D5 peak at 30 min continuous").
    "running-beginner-5k-8sem": {"remove": [8]},
}


def main() -> int:
    check = "--check" in sys.argv
    changed = 0
    for path in sorted(ROOT.glob("*.json")):
        orig = path.read_text()
        t = json.loads(orig)
        weeks = []
        print(f"\n=== {t['id']} ({t['duration_weeks']} sem)")
        for w in t["weeks"]:
            theme_en = w["theme"].get("en") or w["theme"].get("fr", "")
            goal_en = w["goal"].get("en") or w["goal"].get("fr", "")
            hit, why = detect(theme_en, goal_en)
            if hit:
                weeks.append(w["week_number"])
                print(f"  W{w['week_number']:>2} DELOAD {why}")
        ov = OVERRIDES.get(t["id"], {})
        for n in ov.get("add", []):
            if n not in weeks:
                weeks.append(n)
                print(f"  W{n:>2} DELOAD [override add]")
        for n in ov.get("remove", []):
            if n in weeks:
                weeks.remove(n)
                print(f"  W{n:>2} retiré [override remove]")
        weeks.sort()
        print(f"  -> deload_weeks = {weeks}")
        if check:
            continue
        if t.get("deload_weeks") == weeks:
            continue
        if "deload_weeks" in t:
            sys.exit(f"{path.name}: deload_weeks existant divergent — retirer le champ avant de régénérer")
        # Insertion TEXTUELLE (pas de réécriture JSON : 8 fichiers ont un ordre de clés
        # non reproductible). Position alphabétique top-level : avant "duration_weeks".
        sep = " : " if '"duration_weeks" :' in orig else ": "
        lines = orig.split("\n")
        anchor = next(i for i, l in enumerate(lines) if l.startswith('  "duration_weeks"'))
        block = [f'  "deload_weeks"{sep}['] + [f"    {n}," for n in weeks[:-1]] + [f"    {weeks[-1]}", "  ],"]
        path.write_text("\n".join(lines[:anchor] + block + lines[anchor:]))
        changed += 1
    if not check:
        print(f"\n{changed} fichiers réécrits")
    return 0


if __name__ == "__main__":
    sys.exit(main())
