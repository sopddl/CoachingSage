#!/usr/bin/env python3
"""Patch D: corrections post-revue 10 agents. Root-cause fixes, lang-scoped, applied to current files."""
import json, re, os, glob, sys
TDIR="Templates/Sources/TemplateLoader/Resources/Templates"
UF={"theme","goal","name","warmup","cooldown","notes","duration","alternatives"}

# (lang, sport|None, old, new). longest-first per (lang,sport). Case-insensitive, cap-preserving.
R=[
 # ---- omoplateire / omoplater (scapula→omoplate a cassé scapulaire) ----
 ("fr",None,"Omoplater wall pompe","Pompe murale scapulaire"),
 ("fr",None,"Prone omoplater retraction","Rétraction des omoplates à plat ventre"),
 ("fr",None,"omoplater pompe","pompe scapulaire"),
 ("fr",None,"omoplateires","scapulaires"),("fr",None,"omoplateire","scapulaire"),
 ("fr",None,"Omoplater","Scapulaire"),("fr",None,"omoplater","scapulaire"),
 # ---- foam rolling ----
 ("fr",None,"foam vallonné","rouleau de massage"),
 # ---- band mistranslations (anatomie / resistance) ----
 ("fr",None,"IT-élastique","bandelette ilio-tibiale"),("fr",None,"IT élastique","bandelette ilio-tibiale"),
 ("fr",None,"resistance-élastique","bande élastique"),("fr",None,"resistance élastique","bande élastique"),
 ("fr",None,"resistance band","bande élastique"),
 # ---- élisions / articles ----
 ("fr",None,"de l'enchaîné","de l'enchaîné"),  # noop guard
 ("fr",None,"du enchaîné","de l'enchaîné"),("fr",None,"Du enchaîné","De l'enchaîné"),
 ("fr",None,"le enchaîné","l'enchaîné"),("fr",None,"Le enchaîné","L'enchaîné"),
 ("fr",None,"ce enchaîné","cet enchaîné"),("fr",None,"Ce enchaîné","Cet enchaîné"),
 ("fr",None,"le éducatif","l'éducatif"),("fr",None,"Le éducatif","L'éducatif"),
 ("fr",None,"ce éducatif","cet éducatif"),("fr",None,"Ce éducatif","Cet éducatif"),
 ("fr",None,"Pas d'série","Pas de série"),("fr",None,"d'série","de série"),
 ("fr",None,"au épaule","à l'épaule"),
 ("fr",None,"du anti-rotation","de l'anti-rotation"),("fr",None,"le anti-rotation","l'anti-rotation"),
 # ---- genre: travail d'équilibre (proprioception f -> travail m) ----
 ("fr",None,"de la travail d'équilibre","du travail d'équilibre"),
 ("fr",None,"Maintien de la travail","Maintien du travail"),
 ("fr",None,"Cible la travail","Cible le travail"),("fr",None,"davantage la travail","davantage le travail"),
 ("fr",None,"La travail d'équilibre","Le travail d'équilibre"),
 ("fr",None,"la travail d'équilibre","le travail d'équilibre"),
 ("fr",None,"travail d'équilibre progressive","travail d'équilibre progressif"),
 ("fr",None,"la travail d'équilibre de l'avant-bras vertical","le travail de l'avant-bras vertical (appui coude haut)"),
 # ---- genre: sortie longue (long run m -> sortie f) ----
 ("fr",None,"PREMIER sortie longue","PREMIÈRE sortie longue"),
 ("fr",None,"Premier sortie longue","Première sortie longue"),
 ("fr",None,"premier sortie longue","première sortie longue"),
 ("fr",None,"Le sortie longue","La sortie longue"),("fr",None,"le sortie longue","la sortie longue"),
 ("fr",None,"Ce sortie longue","Cette sortie longue"),("fr",None,"ce sortie longue","cette sortie longue"),
 ("fr",None,"longs runs","sorties longues"),("fr",None,"longs sorties","sorties longues"),
 # ---- genre/accord: sauts dynamiques (plyométrie f -> sauts m pl) ----
 ("fr",None,"introduire la sauts dynamiques","introduire les sauts dynamiques"),
 ("fr",None,"La sauts dynamiques","Les sauts dynamiques"),("fr",None,"la sauts dynamiques","les sauts dynamiques"),
 ("fr",None,"de sauts dynamiques progression","progression de sauts dynamiques"),
 ("fr",None,"sauts dynamiques multidirectionnelle","sauts dynamiques multidirectionnels"),
 ("fr",None,"sauts dynamiques progressive","sauts dynamiques progressifs"),
 ("fr",None,"sauts dynamiques spécifique","sauts dynamiques spécifiques"),
 ("fr",None,"sauts dynamiques modérée","sauts dynamiques modérés"),
 ("fr",None,"sauts dynamiques légère","sauts dynamiques légers"),
 ("fr",None,"sauts dynamiques latérale","sauts dynamiques latéraux"),
 ("fr",None,"sauts dynamiques réactive","sauts dynamiques réactifs"),
 ("fr",None,"Pli ométrie","Sauts dynamiques"),
 # ---- doublons issus de la substitution du nom complet ----
 ("fr",None,"anti-rotation à l'élastique anti-rotation","anti-rotation à l'élastique"),
 ("fr",None,"à l'élastique à l'élastique","à l'élastique"),
 ("fr",None,"à l'élastique élastique","à l'élastique"),
 ("fr",None,"Flexion de buste barre au bâton","Flexion de buste au bâton"),
 ("fr",None,"Flexion de buste barre bâton","Flexion de buste au bâton"),
 ("fr",None,"Flexion de buste barre barre","Flexion de buste barre"),
 ("fr",None,"Développé assis au sol haltères assis","Développé assis au sol haltères"),
 ("fr",None,"Développé assis au sol assis","Développé assis au sol"),
 ("fr",None,"gobelet squat squat-développé","squat-développé gobelet"),
 ("fr",None,"Fente statique statique","Fente statique"),
 ("fr",None,"fente fendue statique","fente statique"),("fr",None,"fente fendue","fente statique"),
 ("fr",None,"Montées sur banc banc","Montées sur banc"),("fr",None,"Montée sur banc banc","Montée sur banc"),
 ("fr",None,"tenu sans bouger tenu","tenu sans bouger"),
 ("fr",None,"tenu (tenu sans bouger)","tenu sans bouger"),
 ("fr",None,"(tenu sans bouger) tenu","tenu sans bouger"),
 ("fr",None,"appui propre appui coude haut","appui propre, coude haut"),
 ("fr",None,"gobelet squat squat","squat gobelet"),
 # ---- contresens hollow ----
 ("fr",None,"gainage dos creusé","gainage creux"),
 # ---- gloses tautologiques (titre déjà FR) ----
 ("fr",None,"Répétitions en côte (répétitions en côte)","Répétitions en côte"),
 ("fr",None,"Montées sur banc chargées (montées sur banc)","Montées sur banc chargées"),
 ("fr",None,"(pointer de chien)","(bird-dog)"),
 ("fr",None," (rattrapé)",""),(" fr","fr"," (rattrapé)",""),
 ("fr",None," (chat-vache)",""),("fr",None," (saut d'appel)",""),
 ("fr",None," (saut d’appel)",""),
 ("fr",None," (traction)",""),(" fr",None," (rotation externe)",""),
 ("fr",None," (rotation externe)",""),
 ("fr",None," (élévations latérales)",""),(" fr",None," (soulevé de terre roumain)",""),
 ("fr",None," (soulevé de terre roumain)",""),
 ("fr",None,"(développé couché, ","("),
 ("fr",None,"Passage entre jambes à la poulie (tirage entre les jambes à la poulie)","Passage entre jambes à la poulie"),
 ("fr",None,"Rétraction des omoplates — rétraction omoplates","Rétraction des omoplates"),
 ("fr",None,"Rétraction des omoplates (rétraction omoplates)","Rétraction des omoplates"),
 # ---- ordre franglais (strength) ----
 ("fr",None,"Buste appuyé rowing haltère","Rowing buste appuyé haltère"),
 ("fr",None,"Haltères développé au sol","Développé au sol haltères"),
 ("fr",None,"Haltères JM développé","JM press haltères"),
 ("fr",None,"Haltère pullover","Pullover haltère"),("fr",None,"Haltère rowing","Rowing haltère"),
 ("fr",None,"Smith machine extensions des mollets","Extensions des mollets à la Smith machine"),
 ("fr",None,"Machine élévations latérales","Élévations latérales à la machine"),
 ("fr",None,"Donkey extensions des mollets","Extensions des mollets donkey"),
 ("fr",None,"Sur une jambe soulevé de terre roumain","Soulevé de terre roumain sur une jambe"),
 ("fr",None,"Sur une jambe pont de hanches","Pont de hanches sur une jambe"),
 ("fr",None,"Sur une jambe pont fessier","Pont fessier sur une jambe"),
 ("fr",None,"Sur une jambe squat","Squat sur une jambe"),
 ("fr",None,"Reverse fentes","Fentes arrière"),("fr",None,"Reverse fente","Fente arrière"),
 ("fr",None,"Pike pompe","Pompe pike"),("fr",None,"Diamond pompe","Pompe diamant"),
 ("fr",None,"T-bar rowing","Rowing barre en T"),("fr",None,"Seal rowing","Rowing seal"),
 ("fr",None,"Close-grip développé couché","Développé couché prise serrée"),
 ("fr",None,"Y-élévation prone","Élévation en Y à plat ventre"),
 ("fr",None,"Y élévation prone","Élévation en Y à plat ventre"),
 ("fr",None,"Y-élévation","Élévation en Y"),("fr",None,"T-élévation","Élévation en T"),
 ("fr",None,"SL soulevé de terre","Soulevé de terre sur une jambe"),
 # ---- résidus anglais ----
 ("fr",None,"agility échelle","échelle d'agilité"),
 ("fr",None,"Un bras bras non-dominant","À un bras — bras non-dominant"),
 ("fr",None,"Un bras bras dominant","À un bras — bras dominant"),
 ("fr",None,"Side-lying","Allongé sur le côté"),
 ("fr",None,"single leg in","appui une jambe"),("fr",None,"sur une jambe in","appui une jambe"),
 ("fr",None,"Forearm gainage","gainage avant-bras"),("fr",None,"Gainage static","Gainage statique"),
 ("fr",None,"Calf au poids du corps","Extensions des mollets au poids du corps"),
 ("fr",None,"en el umbral","au seuil"),
 ("fr","swimming","Side kick","battements sur le côté"),
 ("fr","swimming","Maglischo intervalles","intervalles (Maglischo)"),
 # ---- tennis: drill→exercice (gamme jugé confus) ----
 ("fr","tennis","gamme","exercice"),
 # ---- ES ----
 ("es",None,"fraccionado 20/10 20/10","fraccionado 20/10"),
 ("es",None,"un una serie cada minuto","una serie cada minuto"),
 ("es",None,"protocolo fraccionado 20/10 1996","protocolo fraccionado 20/10 (1996)"),
 # ---- EN ----
 ("en",None,"as many reps as possible (as many reps as possible)","as many reps as possible"),
 ("en",None,"as many rounds as possible (as many rounds as possible)","as many rounds as possible"),
 ("en",None,"static hold holds","static holds"),
 ("en",None,"EVF (early vertical forearm) balance work","EVF (early vertical forearm) proprioception"),
 ("fr",None,"protocole fractionné 20/10 1996","protocole fractionné 20/10 (1996)"),
]

def cap(s,start,m,r):
    if not m[:1].isupper(): return r
    pre=s[:start].rstrip()
    if (start==0 or pre=="" or pre[-1:] in ".!?:\n—") and r[:1].isalpha(): return r[:1].upper()+r[1:]
    return r

def build(sport):
    rules=[(l,o,n) for (l,sp,o,n) in R if sp is None or sp==sport]
    rules.sort(key=lambda x:len(x[1]),reverse=True)
    return rules

def collect(node,field,out):
    if isinstance(node,dict):
        if set(node)<={"fr","en","es"} and node:
            if field in UF:
                for l in ("fr","en","es"):
                    if isinstance(node.get(l),str): out.append((l,node[l]))
            return
        for k,v in node.items(): collect(v,k,out)
    elif isinstance(node,list):
        for v in node: collect(v,field,out)

dry="--apply" not in sys.argv
tot=0; log=[]
for f in sorted(glob.glob(TDIR+"/*.json")):
    sport=os.path.basename(f).split('-')[0]
    rules=build(sport)
    raw=open(f,encoding="utf-8").read(); d=json.loads(raw); lv=[]; collect(d,None,lv)
    # transform per (lang,value)
    byval={}
    for lang,val in set(lv):
        s=val
        for rl,ro,rn in rules:
            if rl!=lang: continue
            if ro==rn: continue
            s=re.compile(re.escape(ro),re.I).sub(lambda m:cap(s,m.start(),m.group(0),rn),s)
        s=re.sub(r"  +"," ",s).replace("( ","(").replace(" )",")")
        if s!=val: byval[(lang,val)]=s
    edits=sorted(byval.items(), key=lambda e:len(e[0][1]),reverse=True)
    nr=raw
    for (lang,old),new in edits:
        ot=json.dumps(old,ensure_ascii=False); nt=json.dumps(new,ensure_ascii=False)
        nr,c=re.compile(r'("'+lang+r'"\s*:\s*)'+re.escape(ot)).subn(lambda m:m.group(1)+nt,nr)
        if c: tot+=c; log.append((os.path.basename(f),lang,old,new))
    json.loads(nr)
    if not dry and nr!=raw: open(f,"w",encoding="utf-8").write(nr)
json.dump(log,open("/tmp/trio3d_log.json","w"),ensure_ascii=False,indent=1)
print(("APPLIED" if not dry else "DRY"),"changes:",tot,"distinct:",len(log))
