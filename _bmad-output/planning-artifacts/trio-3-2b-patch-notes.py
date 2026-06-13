#!/usr/bin/env python3
"""Patch B: residual English + élisions + word-order in FR fields, applied to current files.
Deterministic, FR field only, longest-first, lang-scoped raw replacement."""
import json, re, os, glob, sys

TDIR = "Templates/Sources/TemplateLoader/Resources/Templates"
UF = {"theme","goal","name","warmup","cooldown","notes","duration","alternatives"}

# (old, new) — applied to FR strings only, case-insensitive, longest-first, cap-preserving
PAIRS = [
 # élisions introduced by token swap
 ("le éducatif","l'éducatif"),("ce éducatif","cet éducatif"),
 ("du anti-rotation","de l'anti-rotation"),("le anti-rotation","l'anti-rotation"),
 # word-order: English modifier in front -> French behind
 ("à la poulie pull-through","tirage entre les jambes à la poulie"),
 ("à la poulie rope curl marteau","curl marteau à la corde à la poulie"),
 ("élastique développé militaire","développé militaire à l'élastique"),
 ("élastique rowing assis","rowing assis à l'élastique"),
 ("élastique élévations latérales","élévations latérales à l'élastique"),
 ("élastique pass-through","passage par-dessus la tête à l'élastique"),
 ("meadows rowing landmine","rowing Meadows à la landmine"),
 # rope family (longest-first)
 ("rope curl marteau","curl marteau à la corde"),("rope pushdown","extension triceps à la corde"),
 ("rope pull-through","tirage entre les jambes à la corde"),
 ("jump rope","corde à sauter"),("battle rope","corde ondulatoire"),("skip rope","corde à sauter"),
 ("pull-through","tirage entre les jambes"),("rope","corde"),
 # scapula
 ("scapula squeeze","serrage des omoplates"),("scapula retraction","rétraction des omoplates"),
 ("retraction scapulaire","rétraction des omoplates"),("scapula","omoplate"),
 # EZ bar
 ("ez bar curl","curl à la barre EZ"),("ez bar","à la barre EZ"),
 ("pass-through","passage par-dessus la tête"),
 # systematic notes English (low order-risk noun swaps)
 ("leg swings","balancements de jambe"),("leg swing","balancement de jambe"),
 ("cat-cow","chat-vache"),("double-unders","sauts double-tour"),("double-under","saut double-tour"),
 ("hip hinge","charnière de hanche"),("ramp-up","montée en charge"),("ramp up","montée en charge"),
 ("t-spine","colonne dorsale"),("comfortably hard","effort soutenu mais maîtrisé"),
 ("cruise intervals","intervalles"),("cruise interval","intervalle"),
 ("trekking poles","bâtons de marche"),("trekking pole","bâton de marche"),
 ("me workout","séance d'endurance musculaire"),("long run","sortie longue"),
 ("jogging easy","footing facile"),("easy endurance","endurance facile"),
 ("endurance easy","endurance facile"),("easy run","footing facile"),
 ("conversational","en aisance respiratoire"),("swimmer's shoulder","épaule du nageur"),
 ("hill repeats","répétitions en côte"),("very easy","très facile"),
 ("strokes","coups de bras"),("body roll","roulis du corps"),
 ("total immersion","Total Immersion"),
 # interval hard/easy notation
 (" min hard"," min fort"),(" sec hard"," sec fort"),(" min easy"," min facile"),
 (" sec easy"," sec facile"),("min 30 easy","min 30 facile"),(" 30 sec hard"," 30 sec fort"),
 # rpm / gradient / pack
 ("rpm","tr/min"),("gradient","pente"),("pack-multi-day","multi-jours"),("pack-day","journée"),
 ("rolling","vallonné"),
]
PAIRS.sort(key=lambda p: len(p[0]), reverse=True)

def cap_like(s, start, matched, repl):
    if not matched[:1].isupper(): return repl
    pre = s[:start].rstrip()
    if (start==0 or pre=="" or pre[-1:] in ".!?:\n—") and repl[:1].isalpha():
        return repl[:1].upper()+repl[1:]
    return repl

def transform(s):
    for old,new in PAIRS:
        pat = re.compile(re.escape(old), re.IGNORECASE)
        s = pat.sub(lambda m: cap_like(s, m.start(), m.group(0), new), s)
    s = re.sub(r"  +"," ",s)
    return s

def collect(node, field, out):
    if isinstance(node,dict):
        if set(node.keys())<= {"fr","en","es"} and node:
            if field in UF and isinstance(node.get("fr"),str): out.append(node["fr"])
            return
        for k,v in node.items(): collect(v,k,out)
    elif isinstance(node,list):
        for v in node: collect(v,field,out)

dry = "--apply" not in sys.argv
total=0; files=0; log=[]
for f in sorted(glob.glob(os.path.join(TDIR,"*.json"))):
    raw=open(f,encoding="utf-8").read(); d=json.loads(raw)
    leaves=[]; collect(d,None,leaves)
    edits=[]
    for val in set(leaves):
        new=transform(val)
        if new!=val: edits.append((val,new))
    edits.sort(key=lambda e:len(e[0]),reverse=True)
    nr=raw
    for old,new in edits:
        ot=json.dumps(old,ensure_ascii=False); nt=json.dumps(new,ensure_ascii=False)
        pat=re.compile(r'("fr"\s*:\s*)'+re.escape(ot))
        nr,n=pat.subn(lambda m:m.group(1)+nt,nr)
        if n: total+=n; log.append((os.path.basename(f),old,new))
    json.loads(nr)  # validate
    if not dry and nr!=raw:
        open(f,"w",encoding="utf-8").write(nr); files+=1
json.dump(log,open("/tmp/trio3b_log.json","w"),ensure_ascii=False,indent=1)
print(("APPLIED" if not dry else "DRY"),"changes:",total,"files:",files or len({l[0] for l in log}))
import collections
seg=collections.Counter()
for _,o,n in log[:0]: pass
print("sample:")
for fn,o,n in log[:15]:
    import difflib
    d=" | ".join(f"«{o[i1:i2]}»→«{n[j1:j2]}»" for t,i1,i2,j1,j2 in difflib.SequenceMatcher(None,o,n).get_opcodes() if t!='equal')
    print(f"  [{fn[:16]:16}] {d[:110]}")
