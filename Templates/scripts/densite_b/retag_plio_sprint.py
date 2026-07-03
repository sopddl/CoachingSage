#!/usr/bin/env python3
"""Passe de retag plio/sprint — chantier densité B, increment 1 (2026-07-02).

Revue doctrine (template-quality-reviewer 07-02) : ~23 instances d'exos
saut/sprint/bond taggés en zone facile/technique alors que leur nature est
explosive. Correction : zone honnête (hors whitelist densité, G3) + notes et
alternatives contradictoires réalignées (3 langues).

Familles (conventions relevées sur les templates bien taggés) :
- sprints 15-20 m           → RPE 8-9  (cf tennis-competitive "Sprint 15 m")
- box jumps / plio légère   → RPE 7-8  (cf hiking/tennis "Box jump bas")

NON retaggés (justifié, cf filet NoPlioSprintInEasyZonesTests) :
- blocs cycling "Z2 + sprints opener" (sets=1, la zone décrit le bloc dominant)
- corde à sauter cardio continu Z2/Z3 (pas de la pliométrie)
- split-step tennis (footwork technique, amplitude minimale)
- Salabhasana « Sauterelle » (posture yoga, faux positif lexical)
"""
import json
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[2] / "Sources/TemplateLoader/Resources/Templates"

# (template, prédicat match_key, ancienne zone, nouvelle zone,
#  remplacements texte {lang: [(old, new), ...]} appliqués à notes ET alternatives)
NOTE_SPRINT = {
    "fr": [
        ("à allure modérée (RPE 6-7, ~75-80 % FCmax)", "à intensité élevée (RPE 8-9)"),
        ("à allure modérée RPE 6-7 (~75-80% FCmax)", "à intensité élevée RPE 8-9"),
        ("à allure modérée à soutenue RPE 6-7 (~78-83% FCmax)", "à intensité élevée RPE 8-9"),
        ("à allure soutenue RPE 6-7 (~78-83% FCmax)", "à intensité élevée RPE 8-9"),
        ("Allure RPE 6-7 (~78-83% FCmax)", "Intensité élevée RPE 8-9"),
        ("à allure modérée RPE 6-7.", "à intensité élevée RPE 8-9."),
        ("6 × 30 sec de course modérée", "6 × 30 sec de course rapide"),
        ("vélo d'appartement modéré", "vélo d'appartement rapide"),
    ],
    "en": [
        ("at moderate pace (RPE 6-7, ~75-80% max HR)", "at high intensity (RPE 8-9)"),
        ("at moderate pace RPE 6-7 (~75-80% max HR)", "at high intensity RPE 8-9"),
        ("at moderate-to-sustained pace RPE 6-7 (~78-83% max HR)", "at high intensity RPE 8-9"),
        ("at sustained pace RPE 6-7 (~78-83% max HR)", "at high intensity RPE 8-9"),
        ("RPE 6-7 pace (~78-83% max HR)", "High intensity RPE 8-9"),
        ("at moderate pace RPE 6-7.", "at high intensity RPE 8-9."),
        ("6 × 30 sec moderate running", "6 × 30 sec fast running"),
        ("moderate stationary bike", "fast stationary bike"),
    ],
    "es": [
        ("a ritmo moderado (RPE 6-7, ~75-80% de la FC máx)", "a intensidad alta (RPE 8-9)"),
        ("a ritmo moderado RPE 6-7 (~75-80% de la FC máx)", "a intensidad alta RPE 8-9"),
        ("a ritmo moderado a sostenido RPE 6-7 (~78-83% de la FC máx)", "a intensidad alta RPE 8-9"),
        ("a ritmo sostenido RPE 6-7 (~78-83% de la FC máx)", "a intensidad alta RPE 8-9"),
        ("Ritmo RPE 6-7 (~78-83% de la FC máx)", "Intensidad alta RPE 8-9"),
        ("a ritmo moderado RPE 6-7.", "a intensidad alta RPE 8-9."),
        ("6 × 30 s de carrera moderada", "6 × 30 s de carrera rápida"),
        ("bicicleta estática moderada", "bicicleta estática rápida"),
    ],
}
NOTE_FOOTBALL = {
    "fr": [("Effort modéré.", "Effort explosif contrôlé.")],
    "en": [("Moderate effort.", "Controlled explosive effort.")],
    "es": [("Esfuerzo moderado.", "Esfuerzo explosivo controlado.")],
}

PASSES = [
    ("tennis-recreational-regularite-10sem",
     lambda mk: mk.startswith("Cardio intermittent —"), "RPE 6-7", "RPE 8-9", NOTE_SPRINT),
    ("strength-training-regular-ppl-12sem",
     lambda mk: mk.startswith("Box jumps"), "technique", "RPE 7-8", {}),
    ("hiking-competitive-fastpacking-16sem",
     lambda mk: "A-skip" in mk, "RPE 6-7", "RPE 7-8", {}),
    ("football-beginner-initiation-8sem",
     lambda mk: "bound" in mk or "Vertical Jump" in mk, "RPE 6-7", "RPE 7-8", NOTE_FOOTBALL),
]


def dump_matching_style(obj, original: str) -> str:
    """Round-trip du style du fichier D'ORIGINE (le repo mélange deux styles) :
    - style JSONEncoder Swift : `"clé" : valeur`, arrays vides sur 3 lignes, pas de \\n final ;
    - style Python : `"clé": valeur`, arrays vides `[]`.
    Indent 2 + clés triées dans les deux cas (vérifié sur les 40 templates)."""
    swift = '" : ' in original[:2000]
    out = json.dumps(obj, ensure_ascii=False, indent=2, sort_keys=True,
                     separators=(",", " : " if swift else ": "))
    if swift:
        out = re.sub(r'^(\s*)("[^"]+" : )\[\](,?)$', r"\1\2[\n\n\1]\3", out, flags=re.M)
    if original.endswith("\n"):
        out += "\n"
    return out


def apply_text(loc: dict, repls: dict) -> int:
    n = 0
    for lang, pairs in repls.items():
        if lang not in loc:
            continue
        for old, new in pairs:
            if old in loc[lang]:
                loc[lang] = loc[lang].replace(old, new)
                n += 1
    return n


def main() -> int:
    total = 0
    for fid, pred, oldz, newz, repls in PASSES:
        path = ROOT / f"{fid}.json"
        orig = path.read_text()
        t = json.loads(orig)
        count = 0
        for w in t["weeks"]:
            for s in w["sessions"]:
                for e in s["exercises"]:
                    mk = e.get("match_key", "")
                    if not (pred(mk) and e.get("target_zone") == oldz):
                        continue
                    e["target_zone"] = newz
                    edits = 0
                    if repls:
                        if isinstance(e.get("notes"), dict):
                            edits += apply_text(e["notes"], repls)
                        for alt in e.get("alternatives", []):
                            if isinstance(alt, dict):
                                edits += apply_text(alt, repls)
                    count += 1
                    print(f"  {fid} | {mk[:55]} | {oldz} -> {newz} (+{edits} textes)")
        path.write_text(dump_matching_style(t, orig))
        print(f"{fid}: {count} instances retaggées")
        total += count
    print(f"TOTAL: {total} instances")
    if total == 0:
        print("(déjà appliqué — rien à faire)")
        return 0
    return 0 if total == 23 else 1


if __name__ == "__main__":
    sys.exit(main())
