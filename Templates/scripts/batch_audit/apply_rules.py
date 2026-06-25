#!/usr/bin/env python3
"""Applique un jeu de règles old->new (FR) aux champs AFFICHÉS d'un sport, en
préservant le format Swift JSONEncoder byte-à-byte (édition byte-level scopée au
bloc "weeks" via numéro de ligne — métadonnée progression_logic/safety_notes en
tête de fichier est PRÉSERVÉE).

Usage: apply_rules.py <sport-prefix> <rules.json>
  rules.json = {"rules":[{"old":..,"new":..}, ...]}

Stratégie : on ne re-dumpe PAS le JSON (éviterait le churn "clé" : / tableaux
vides). On lit les lignes, on repère la ligne "weeks" : [ et on n'applique les
remplacements littéraux QUE sur les lignes >= cette ligne. Les valeurs fr/en/es
sont chacune sur UNE ligne physique → remplacement sûr.

Important : les `old` sont des sous-chaînes FR. Comme une même sous-chaîne pourrait
théoriquement exister dans un champ en/es, on restreint l'application aux lignes
dont le contenu commence par `"fr" :` (les règles ciblent le FR affiché)."""
import json, glob, os, sys, re

TPL = os.path.join(os.path.dirname(__file__), '..', '..', 'Sources', 'TemplateLoader', 'Resources', 'Templates')

def weeks_line(lines):
    for i, l in enumerate(lines):
        if re.match(r'\s*"weeks"\s*:\s*\[', l):
            return i
    raise RuntimeError('pas de "weeks" trouvé')

def main():
    sport, rules_path = sys.argv[1], sys.argv[2]
    lang = sys.argv[3] if len(sys.argv) > 3 else 'fr'        # langue ciblée (fr|en|es)
    rules_key = sys.argv[4] if len(sys.argv) > 4 else 'rules' # clé dans le json (rules|en_rules|es_rules)
    rules = json.load(open(rules_path))[rules_key]
    total = 0
    per_rule = {i: 0 for i in range(len(rules))}
    for path in sorted(glob.glob(os.path.join(TPL, f'{sport}-*.json'))):
        with open(path) as f:
            lines = f.readlines()
        wl = weeks_line(lines)
        n = 0
        for i in range(wl, len(lines)):
            # ne toucher que les valeurs de la langue ciblée
            if not re.match(r'\s*"' + lang + r'"\s*:', lines[i]):
                continue
            for ri, r in enumerate(rules):
                old, new = r['old'], r['new']
                if old in lines[i]:
                    c = lines[i].count(old)
                    lines[i] = lines[i].replace(old, new)
                    n += c; per_rule[ri] += c
        with open(path, 'w') as f:
            f.writelines(lines)
        if n:
            print(f'  {os.path.basename(path)}: {n}')
        total += n
    print(f'TOTAL remplacements: {total}')
    unused = [rules[i]['old'][:50] for i, c in per_rule.items() if c == 0]
    if unused:
        print(f'\n⚠️  {len(unused)} règle(s) NON appliquée(s) (old introuvable en FR>=weeks) :')
        for u in unused:
            print('   -', repr(u))

if __name__ == '__main__':
    main()
