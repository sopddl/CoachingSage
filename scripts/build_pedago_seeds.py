#!/usr/bin/env python3
"""Transcrit les JSON pédago par sport en Swift `generatedSeeds`.

Lit  _bmad-output/implementation-artifacts/pedago-seeds/<sport>.json
Écrit Coaching/Session/ExerciseExplanationSeed+Generated.swift

Format JSON attendu par sport :
{ "sport": "...", "entries": [ {
    "id": "...", "type": "movement|block", "matchers": ["..."],
    "fr": {"steps":[...], "equipment":[...], "commonMistake": "..."|null},
    "en": {"steps":[...], "equipment":[...], "commonMistake": "..."|null} } ] }

Ordre des sports = mouvement d'abord (matchers plus spécifiques priment via
first-hit), endurance ensuite. À l'intérieur d'un sport, on trie les entrées
par longueur de matcher décroissante pour réduire les faux matchs courts.
"""
import json, os, sys, re

ROOT = "/Users/sophieslama/CL3/CoachingSage"
SEED_DIR = f"{ROOT}/_bmad-output/implementation-artifacts/pedago-seeds"
OUT = f"{ROOT}/Coaching/Session/ExerciseExplanationSeed+Generated.swift"

SPORT_ORDER = ["yoga", "strength-training", "hiit", "tennis", "football",
               "cycling", "running", "swimming", "triathlon", "hiking"]

# Matchers dangereux : sous-chaînes courtes qui matchent des mots non liés
# ("om" ⊂ "custom"/"homme", "arc" ⊂ "marche"). Le lookup seed est un simple
# contains → on bannit ces tokens. Le reste des acronymes (rdl, ohp, z5, rsa,
# css, t1…) est spécifique et sûr.
MATCHER_DENY = {"om", "arc"}

def sw(s):
    """Échappe une string pour un littéral Swift sur une ligne."""
    if s is None:
        return None
    s = s.replace("\\", "\\\\").replace('"', '\\"')
    s = s.replace("\n", " ").replace("\r", " ").replace("\t", " ")
    # Sanitize slashes en présentation (règle anti-slash Sophie) — sécurité filet.
    s = re.sub(r"\s*/\s*", " · ", s)
    return s

def arr(items):
    return "[" + ", ".join(f'"{sw(x)}"' for x in items) + "]"

def explanation(d):
    steps = arr(d.get("steps", []))
    equip = arr(d.get("equipment", []))
    cm = d.get("commonMistake")
    cm_lit = f'"{sw(cm)}"' if cm else "nil"
    return f"ExerciseExplanation(steps: {steps}, equipment: {equip}, commonMistakes: {cm_lit})"

def main():
    blocks = []
    total = 0
    per_sport = []
    for sport in SPORT_ORDER:
        path = f"{SEED_DIR}/{sport}.json"
        if not os.path.exists(path):
            per_sport.append((sport, 0, "MANQUANT"))
            continue
        data = json.load(open(path))
        entries = data.get("entries", [])
        # filtre matchers dangereux + dédoublonne
        for e in entries:
            e["matchers"] = [m for m in dict.fromkeys(e.get("matchers", [])) if m not in MATCHER_DENY]
        # tri matcher le plus long d'abord (spécificité)
        entries.sort(key=lambda e: -max((len(m) for m in e.get("matchers", [""])), default=0))
        lines = [f"        // MARK: {sport} ({len(entries)})"]
        for e in entries:
            if not e.get("matchers"):
                print(f"  ⚠️  {sport}/{e.get('id')} : tous matchers filtrés, entrée ignorée")
                continue
            matchers = arr(e.get("matchers", []))
            fr = explanation(e.get("fr", {}))
            en = explanation(e.get("en", {}))
            lines.append(
                f"        SeedEntry(matchers: {matchers},\n"
                f"            fr: {fr},\n"
                f"            en: {en}),"
            )
        blocks.append("\n".join(lines))
        total += len(entries)
        per_sport.append((sport, len(entries), "ok"))

    body = "\n\n".join(blocks)
    swift = f"""// Coaching/Session/ExerciseExplanationSeed+Generated.swift
// Phase 1 pédagogie (2026-06-03) — contenu "comment l'exécuter" généré par sport.
//
// ⚠️ FICHIER GÉNÉRÉ — ne pas éditer à la main.
// Source : _bmad-output/implementation-artifacts/pedago-seeds/<sport>.json
// Régénération : python3 Scripts/build_pedago_seeds.py
//
// Conforme EU MDR : audité par `test_seedHasNoBannedTermsForEUMDR` qui itère
// sur `ExerciseExplanationSeed.entries` (= coreSeeds + generatedSeeds).
// Total : {total} entrées canoniques sur {sum(1 for _,n,_ in per_sport if n>0)} sports.
import Foundation

extension ExerciseExplanationSeed {{
    static let generatedSeeds: [SeedEntry] = [
{body}
    ]
}}
"""
    open(OUT, "w").write(swift)
    print(f"Écrit {OUT} — {total} entrées")
    for sport, n, st in per_sport:
        print(f"  {sport:20} {n:4}  {st}")

if __name__ == "__main__":
    main()
