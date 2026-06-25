import json, glob, os
TPL_DIR = "../Sources/TemplateLoader/Resources/Templates"
rows = []
for path in sorted(glob.glob(os.path.join(TPL_DIR, "running-*.json"))):
    d = json.load(open(path))
    tid = d.get("id", os.path.basename(path))
    for wi, w in enumerate(d["weeks"]):
        for si, s in enumerate(w["sessions"]):
            ctx = f"{tid}|S{wi+1}.{si+1}"
            for fld in ("warmup","cooldown"):
                v = s.get(fld)
                if isinstance(v, dict) and v.get("fr"):
                    rows.append({"ctx":ctx,"field":fld,"fr":v["fr"]})
            sn = s.get("name")
            if isinstance(sn, dict) and sn.get("fr"):
                rows.append({"ctx":ctx,"field":"session_name","fr":sn["fr"]})
            exos = list(s.get("exercises",[]))
            for v in s.get("variants",[]):
                exos += v.get("exercises",[])
            for e in exos:
                nm = e.get("name",{})
                if nm.get("fr"): rows.append({"ctx":ctx,"field":"exo_name","fr":nm["fr"]})
                nt = e.get("notes",{})
                if isinstance(nt,dict) and nt.get("fr"): rows.append({"ctx":ctx,"field":"exo_notes","fr":nt["fr"]})
                for alt in e.get("alternatives",[]):
                    if alt.get("fr"): rows.append({"ctx":ctx,"field":"alternative","fr":alt["fr"]})
# dedup by (field, fr)
seen=set(); uniq=[]
for r in rows:
    k=(r["field"],r["fr"])
    if k in seen: continue
    seen.add(k); uniq.append(r)
json.dump(uniq, open("running_audit/corpus.json","w"), ensure_ascii=False, indent=1)
print(f"{len(rows)} rows, {len(uniq)} unique")
# also a names-only flat list for quick scan
names = sorted(set(r["fr"] for r in uniq if r["field"]=="exo_name"))
open("running_audit/exo_names.txt","w").write("\n".join(names))
print(f"{len(names)} unique exo names")
