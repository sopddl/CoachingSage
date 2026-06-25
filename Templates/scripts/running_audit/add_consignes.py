import json, glob, os
TPL='../Sources/TemplateLoader/Resources/Templates'
fr=json.load(open('running_audit/consignes_fr.json'))
enes=json.load(open('running_audit/consignes_enes.json'))
assert set(fr)==set(enes), set(fr)^set(enes)
M={k:{"fr":fr[k],"en":enes[k]["en"],"es":enes[k]["es"]} for k in fr}

def empty(notes): return not (isinstance(notes,dict) and notes.get('fr','').strip())

filled=0; per={}
for path in sorted(glob.glob(os.path.join(TPL,'running-*.json'))):
    d=json.load(open(path)); c=0
    for w in d['weeks']:
        for s in w['sessions']:
            exos=list(s.get('exercises',[]))
            for v in s.get('variants',[]): exos+=v.get('exercises',[])
            for e in exos:
                nm=(e.get('name',{}) or {}).get('fr','')
                if nm in M and empty(e.get('notes')):
                    e['notes']={"fr":M[nm]['fr'],"en":M[nm]['en'],"es":M[nm]['es']}
                    c+=1
    json.dump(d,open(path,'w'),ensure_ascii=False,indent=2)
    per[os.path.basename(path)]=c; filled+=c
for k,v in per.items(): print(f'{v:4} {k}')
print('TOTAL notes remplies:',filled)
