import json, glob, os
TPL='../Sources/TemplateLoader/Resources/Templates'
RULES=[
 ("marathon (soutenu)", "marathon (soutenue)"),            # capital-A variants
 ("à l'allure à allure semi-marathon cible", "à l'allure semi-marathon cible"),
 ("Course/marche en escalier", "Course/marche par paliers"),
]
def fix(v):
    if not isinstance(v,dict) or 'fr' not in v: return 0
    fr=v['fr']; n=0
    for o,nw in RULES:
        if o in fr: n+=fr.count(o); fr=fr.replace(o,nw)
    v['fr']=fr; return n
tot=0
for path in sorted(glob.glob(os.path.join(TPL,'running-*.json'))):
    d=json.load(open(path)); c=0
    for w in d['weeks']:
        for s in w['sessions']:
            for fld in ('warmup','cooldown','name'):
                if isinstance(s.get(fld),dict): c+=fix(s[fld])
            exos=list(s.get('exercises',[]))
            for v in s.get('variants',[]): exos+=v.get('exercises',[])
            for e in exos:
                c+=fix(e.get('name',{})); c+=fix(e.get('notes',{}))
                for a in e.get('alternatives',[]): c+=fix(a)
    json.dump(d,open(path,'w'),ensure_ascii=False,indent=2); tot+=c
print('patch replacements:',tot)
