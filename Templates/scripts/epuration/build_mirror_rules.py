#!/usr/bin/env python3
"""Chantier ÉPURATION miroir — depuis le mirror corpus + les réécritures EN/ES de
l'agent, produit DEUX fichiers de règles (en_rules.json, es_rules.json) au format
apply_rules.py, encodés JSON (match ligne brute).

Usage: build_mirror_rules.py <sport>
  lit  <sport>_mirror.json        ([{id, fr, en, es}])
       <sport>_mirror_rewrites.json {"rewrites":[{id, en, es}]}
  écrit <sport>_en_rules.json, <sport>_es_rules.json
"""
import json, sys, os

D = os.path.dirname(__file__)
enc = lambda s: json.dumps(s, ensure_ascii=False)[1:-1]

def main():
    sport = sys.argv[1]
    corpus = json.load(open(os.path.join(D, f'{sport}_mirror.json')))
    rew = json.load(open(os.path.join(D, f'{sport}_mirror_rewrites.json')))['rewrites']
    by_id = {r['id']: r for r in corpus}
    for lang in ('en', 'es'):
        rules, skip = [], 0
        for w in rew:
            src = by_id.get(w['id'])
            new = w.get(lang, '')
            if src is None:
                skip += 1; continue
            old = src.get(lang, '')
            if not old or not new.strip() or new == old:
                skip += 1; continue
            rules.append({'old': enc(old), 'new': enc(new)})
        out = {'rules': rules, f'{lang}_rules': rules}
        json.dump(out, open(os.path.join(D, f'{sport}_{lang}_rules.json'), 'w'),
                  ensure_ascii=False, indent=1)
        print(f'{sport} {lang}: {len(rules)} règles, {skip} ignorées', file=sys.stderr)

if __name__ == '__main__':
    main()
