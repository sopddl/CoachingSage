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
OVERRIDES: dict[str, dict[str, list[int]]] = {
    # W16 = semaine de tournoi (matchs) : jamais densifier une semaine de compétition.
    "tennis-competitive-tournoi-prep-16sem": {"add": [16]},
    # W16 = race week marathon (thème sans le mot taper, goal « arrive fresh »).
    "running-competitive-marathon-16sem": {"add": [16]},
    # W16 = race week cyclosportive (thème « race week, cyclosportive on D7 »).
    "cycling-competitive-cyclosportive-16sem": {"add": [16]},
    # W12 check-in -24 % (goal : « no competitive taper » mais volume réduit de bilan).
    "yoga-competitive-advanced-12sem": {"add": [12]},
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
