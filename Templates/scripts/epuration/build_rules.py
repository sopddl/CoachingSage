#!/usr/bin/env python3
"""Chantier ÉPURATION — reconstruit les règles old->new pour apply_rules.py à partir
du corpus extrait et des réécritures de l'agent (indexées par id).

On prend `old` = texte original VERBATIM du corpus (par id) → zéro risque de
mismatch verbatim côté agent. On filtre les no-op (new == old) et les new vides.

Usage: build_rules.py <corpus.json> <rewrites.json> <lang> > rules.json
  corpus.json   : sortie de extract_notes.py  [{id, len, count, <lang>}]
  rewrites.json : sortie agent {"rewrites":[{id, new}]}
  lang          : fr|en|es (clé texte dans le corpus + clé de sortie rules)

Sortie : {"rules":[{old,new}], "<lang>_rules":[...]} (les deux clés pointent la
même liste → utilisable quelle que soit la rules_key passée à apply_rules.py).
"""
import json, sys

def main():
    corpus = json.load(open(sys.argv[1]))
    rew = json.load(open(sys.argv[2]))
    lang = sys.argv[3] if len(sys.argv) > 3 else 'fr'
    by_id = {r['id']: r[lang] for r in corpus}
    rules = []
    skipped = 0
    # On encode old/new en forme JSON (sans les guillemets englobants) pour matcher
    # EXACTEMENT la ligne brute du fichier (échappements `\"`, etc.). apply_rules
    # opère sur les lignes brutes → l'`old` décodé échouerait sur une note à guillemet.
    enc = lambda s: json.dumps(s, ensure_ascii=False)[1:-1]
    for w in rew['rewrites']:
        old = by_id.get(w['id'])
        new = w.get('new', '')
        if old is None or not new.strip() or new == old:
            skipped += 1
            continue
        rules.append({'old': enc(old), 'new': enc(new)})
    out = {'rules': rules, f'{lang}_rules': rules}
    json.dump(out, sys.stdout, ensure_ascii=False, indent=1)
    print(f'\n# {len(rules)} règles, {skipped} ignorées (no-op/vide)', file=sys.stderr)

if __name__ == '__main__':
    main()
