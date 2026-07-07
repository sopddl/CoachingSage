#!/usr/bin/env python3
"""Chantier ÉPURATION DENSITÉ (2026-06-26) — extrait le corpus de notes AFFICHÉES
(champ `notes.fr` dans le bloc weeks) d'un sport, dédupliqué par texte.

Sortie : corpus JSON [{id, len, count, fr}] trié par longueur décroissante.
L'agent rédacteur condense chaque note et renvoie [{id, new}] ; on reconstruit
les règles {old: fr original, new} par id (évite tout souci de verbatim `old`).

Usage: extract_notes.py <sport-prefix> [lang=fr] > corpus.json
"""
import json, glob, os, sys, re
from collections import OrderedDict

TPL = os.path.join(os.path.dirname(__file__), '..', '..', 'Sources', 'TemplateLoader', 'Resources', 'Templates')

def walk(o, lang, acc):
    if isinstance(o, dict):
        for k, v in o.items():
            if k == 'notes' and isinstance(v, dict) and v.get(lang):
                acc.append(v[lang])
            else:
                walk(v, lang, acc)
    elif isinstance(o, list):
        for x in o:
            walk(x, lang, acc)

def main():
    sport = sys.argv[1]
    lang = sys.argv[2] if len(sys.argv) > 2 else 'fr'
    acc = []
    for path in sorted(glob.glob(os.path.join(TPL, f'{sport}-*.json'))):
        walk(json.load(open(path)), lang, acc)
    # dédup par texte, garder l'ordre + compter occurrences
    counts = OrderedDict()
    for t in acc:
        counts[t] = counts.get(t, 0) + 1
    rows = [{'id': i, 'len': len(t), 'count': c, lang: t}
            for i, (t, c) in enumerate(counts.items())]
    rows.sort(key=lambda r: r['len'], reverse=True)
    json.dump(rows, sys.stdout, ensure_ascii=False, indent=1)

if __name__ == '__main__':
    main()
