#!/usr/bin/env python3
"""Chantier « anglais large résiduel » (2026-06-19) — applique des traductions FR.

Applique une liste de remplacements {old, new} UNIQUEMENT dans les valeurs `"fr"`
des objets LocalizedText {fr,en,es} (et dose.free_text.fr) des templates d'un sport.
Ne touche JAMAIS en/es, ni les champs structurés (duration/reps/value/unit), ni les
clés. Sérialise via swiftjson -> diff git limité aux seules valeurs fr modifiées.

Usage: python3 apply_fr_translations.py <sport> <replacements.json>
  replacements.json = [{"old": "...", "new": "..."}, ...]  (substring, fr only)
"""
import sys, json, glob, os, re
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from swiftjson import dumps

SPORT_GLOB = {
    'cycling':'cycling-*','football':'football-*','hiit':'hiit-*','hiking':'hiking-*',
    'running':'running-*','strength_training':'strength-training-*','swimming':'swimming-*',
    'tennis':'tennis-*','triathlon':'triathlon-*','yoga':'yoga-*',
}
BASE=os.path.join(os.path.dirname(os.path.abspath(__file__)),'..','Sources','TemplateLoader','Resources','Templates')

def apply_to_fr(o, repls, stats):
    if isinstance(o, dict):
        fr = o.get('fr')
        if isinstance(fr, str) and 'en' in o and 'es' in o:
            new = fr
            # Sequential, IN THE GIVEN ORDER — reproduces the agents' validated
            # "simulation séquentielle" (later rules may target earlier rules' output).
            for r in repls:
                if r['old'] in new:
                    stats[r['old']] = stats.get(r['old'],0)+new.count(r['old'])
                    new = new.replace(r['old'], r['new'])
            if new != fr:
                o['fr'] = new
            return
        for v in o.values(): apply_to_fr(v, repls, stats)
    elif isinstance(o, list):
        for v in o: apply_to_fr(v, repls, stats)

def main():
    sport, replfile = sys.argv[1], sys.argv[2]
    repls = json.load(open(replfile))
    stats={}
    files = sorted(glob.glob(os.path.join(BASE, SPORT_GLOB[sport]+'.json')))
    for f in files:
        orig = open(f).read(); d = json.loads(orig)
        apply_to_fr(d, repls, stats)
        out = dumps(d)
        if out != orig:
            open(f,'w').write(out)
    print(f"# {sport}: {len(files)} fichiers, {len(repls)} règles")
    zero=[r['old'] for r in repls if stats.get(r['old'],0)==0]
    for r in repls:
        print(f"  {stats.get(r['old'],0):4d}  «{r['old'][:50]}» -> «{r['new'][:50]}»")
    if zero:
        print(f"!! {len(zero)} règles SANS match (vérifier): "+ " | ".join(z[:40] for z in zero[:20]))

if __name__=='__main__': main()
