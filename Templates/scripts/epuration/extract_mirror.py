#!/usr/bin/env python3
"""Chantier ÉPURATION — étape miroir EN/ES. Le FR est déjà épuré dans les fichiers ;
chaque objet `notes` porte désormais {fr épuré, en/es encore longs}. On extrait, par
sport, les triples où en OU es dépasse le seuil → l'agent condense en/es en suivant
le FR épuré comme cible de contenu (mêmes coupes).

Sortie : [{id, fr, en, es}] dédupliqué par (en, es), trié par longueur max(en,es) desc.
Seuil par défaut 150 (= densité FR cible). Usage: extract_mirror.py <sport> [seuil] > mirror.json
"""
import json, glob, os, sys
from collections import OrderedDict

TPL = os.path.join(os.path.dirname(__file__), '..', '..', 'Sources', 'TemplateLoader', 'Resources', 'Templates')

def walk(o, acc):
    if isinstance(o, dict):
        for k, v in o.items():
            if k == 'notes' and isinstance(v, dict) and (v.get('en') or v.get('es')):
                acc.append((v.get('fr', ''), v.get('en', ''), v.get('es', '')))
            else:
                walk(v, acc)
    elif isinstance(o, list):
        for x in o:
            walk(x, acc)

def main():
    sport = sys.argv[1]
    seuil = int(sys.argv[2]) if len(sys.argv) > 2 else 150
    acc = []
    for path in sorted(glob.glob(os.path.join(TPL, f'{sport}-*.json'))):
        walk(json.load(open(path)), acc)
    seen = OrderedDict()
    for fr, en, es in acc:
        if len(en) > seuil or len(es) > seuil:
            seen[(en, es)] = fr
    rows = [{'id': i, 'fr': fr, 'en': en, 'es': es}
            for i, ((en, es), fr) in enumerate(seen.items())]
    rows.sort(key=lambda r: max(len(r['en']), len(r['es'])), reverse=True)
    json.dump(rows, sys.stdout, ensure_ascii=False, indent=1)

if __name__ == '__main__':
    main()
