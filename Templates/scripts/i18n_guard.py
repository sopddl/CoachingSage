#!/usr/bin/env python3
"""i18n B2 — guard de validation des templates traduits {fr,en,es}.

Usage : python3 Templates/scripts/i18n_guard.py <glob templates raw-v2>
Ex    : python3 Templates/scripts/i18n_guard.py 'Templates/References/raw-v2/cycling-*.json'

Vérifie, sur les 8 champs AFFICHÉS (week.theme/goal, session.name/warmup/cooldown,
exercise.name/notes/alternatives[]) :
  - chaque champ est un objet {fr,en,es} complet (pas de string nue, pas de langue manquante)
  - aucun marqueur espagnol évident dans un champ `fr` (fuite es→fr la plus fréquente)
  - chaque exercice porte un `match_key` (clé de matching stable)
  - les champs doctrine top-level (name/summary/safety_notes/progression_logic/
    assumed_profile/default_objective) restent des strings FR nues (NON traduits)

Sort un rapport + exit code != 0 si erreur bloquante. Les `fr==es` ne sont PAS une
erreur (termes empruntés : « Dead bug », « Fartlek », « Daniels-T »…).
"""
import json, glob, re, sys

ES_IN_FR = re.compile(
    r'\b(sentadilla\w*|empuje|cadera|peso corporal|escal[óo]n|b[úu]lgara|'
    r'piernas?|rodillas?|gl[úu]teos?|tobillos?|hombros?|espalda|pecho|'
    r'abdominales|flexiones|estiramiento\w*|caminata|respiraci[óo]n|'
    r'subidas? a|elevaci[óo]n de|mancuern\w*|pantorrilla\w*)\b', re.I)

DOCTRINE = ["name", "summary", "safety_notes", "progression_logic",
            "assumed_profile", "default_objective"]


def displayed(d):
    for w in d["weeks"]:
        yield "week.theme", w["theme"]
        yield "week.goal", w["goal"]
        for s in w["sessions"]:
            yield "session.name", s["name"]
            for k in ("warmup", "cooldown"):
                if s.get(k) is not None:
                    yield f"session.{k}", s[k]
            for e in s["exercises"]:
                yield "exercise.name", e["name"]
                if e.get("notes") is not None:
                    yield "exercise.notes", e["notes"]
                for a in e.get("alternatives", []):
                    yield "exercise.alternatives", a


def check(path):
    d = json.load(open(path))
    errs, warns = [], []

    # doctrine = strings FR nues
    for k in DOCTRINE:
        if k in d and not isinstance(d[k], str):
            errs.append(f"doctrine `{k}` doit rester une string FR (trouvé {type(d[k]).__name__})")

    for kind, o in displayed(d):
        # Une chaîne vide = champ optionnel légitimement vide (ex warmup/cooldown des
        # séances repos/match), PAS un champ non traduit → on ignore.
        if isinstance(o, str) and o.strip() == "":
            continue
        if not isinstance(o, dict):
            errs.append(f"{kind}: doit être un objet {{fr,en,es}}, trouvé string nue: {o!r}")
            continue
        # Objet tout-vide (ex warmup/cooldown des séances repos/match rendu {fr:"",en:"",es:""})
        # = champ optionnel légitimement vide → on ignore.
        if not any((o.get(l) or "").strip() for l in ("fr", "en", "es")):
            continue
        for lang in ("fr", "en", "es"):
            if not o.get(lang):
                errs.append(f"{kind}: langue `{lang}` manquante/vide → {o!r}")
        if o.get("fr") and ES_IN_FR.search(o["fr"]):
            errs.append(f"{kind}: ESPAGNOL dans `fr` → {o['fr']!r}")

    for w in d["weeks"]:
        for s in w["sessions"]:
            for e in s["exercises"]:
                if "match_key" not in e:
                    nm = e["name"].get("fr") if isinstance(e["name"], dict) else e["name"]
                    errs.append(f"exercise sans `match_key` → {nm!r}")
    return errs, warns


def main():
    pattern = sys.argv[1] if len(sys.argv) > 1 else "Templates/References/raw-v2/*.json"
    files = sorted(glob.glob(pattern))
    if not files:
        print(f"Aucun fichier: {pattern}"); sys.exit(2)
    total = 0
    for f in files:
        errs, warns = check(f)
        status = "OK" if not errs else f"{len(errs)} ERREURS"
        print(f"[{status}] {f.split('/')[-1]}")
        for e in errs[:40]:
            print(f"    ✘ {e}")
        total += len(errs)
    print(f"\n{'✅ GUARD PASS' if total == 0 else f'❌ {total} ERREURS'} sur {len(files)} fichiers")
    sys.exit(0 if total == 0 else 1)


if __name__ == "__main__":
    main()
