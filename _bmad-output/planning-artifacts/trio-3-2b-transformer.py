#!/usr/bin/env python3
"""Passe #3 (vulgarisation jargon) + #2b (noms d'exos franglais→FR).
Raw-text targeted replacement of complete escaped JSON string values, user-facing fields only."""
import json, re, os, glob, sys, collections

TDIR = "Templates/Sources/TemplateLoader/Resources/Templates"
GLOSS = "_bmad-output/planning-artifacts/trio-3-2b-glossaire-2026-06-13.json"
USERFACING = {"theme","goal","name","warmup","cooldown","notes","duration","alternatives"}
EXCLUDE = {"summary","progression_logic","default_objective","safety_notes","coaching_notes",
           "assumed_profile","match_key","id","sport","level","type","day"}

g = json.load(open(GLOSS))

# Build ordered replacement rules. Each rule: (kind, old, repl_dict_by_lang_or_fn, scope, wb, pluralize)
# We process: phrase_pairs (exact, case-insensitive) first, then tokens longest-first.

def norm_scope(s):
    return None if s == "global" else set(s)  # None = all sports

PHRASE = []   # (old_lower, new, scope, langs)  langs=None→all 3
for p in g["phrase_pairs_all_langs"]:
    langs = [p["lang"]] if "lang" in p else None
    PHRASE.append((p["old"], p["new"], norm_scope(p["scope"]), langs))

# token rules: list of dict {token, fr, en, es, scope, wb, plural(bool)}
TOKENS = []
def add_tokens(lst, is_name):
    for t in lst:
        TOKENS.append({
            "token": t["token"],
            "fr": t.get("fr"), "en": t.get("en"), "es": t.get("es"),
            "scope": norm_scope(t.get("scope","global")),
            "wb": t.get("wb", False),
            "plural": is_name,   # only exo-names auto-pluralize FR first word
        })
add_tokens(g["tokens_jargon"], False)
add_tokens(g["tokens_polyseme"], False)
add_tokens(g["tokens_swim_names"], True)
add_tokens(g["tokens_exo_names_fr"], True)

# --- second tier: compound lifts + modifiers (FR field only) authored inline ---
TIER2 = [
  # bench / press family (longest-first handled by global sort)
  ("db bench press","développé couché haltères"),("incline bench press","développé incliné"),
  ("decline bench press","développé décliné"),("incline bench","développé incliné"),
  ("db bench","développé couché haltères"),("bench press","développé couché"),
  ("db shoulder press","développé épaules haltères"),("shoulder press","développé épaules"),
  ("overhead press","développé militaire"),("push press","développé avec impulsion"),
  ("landmine press","développé à la landmine"),("floor press","développé au sol"),
  ("z press","développé assis au sol"),("arnold press","développé Arnold"),
  # rows
  ("chest-supported row","rowing buste appuyé"),("cable single-arm row","rowing un bras à la poulie"),
  ("bent-over row","rowing buste penché"),("pendlay row","rowing Pendlay"),
  ("cable row","rowing à la poulie"),("db row","rowing haltère"),("seated row","rowing assis"),
  ("ring rows","tirages aux anneaux"),("ring row","tirage aux anneaux"),("inverted row","rowing inversé"),
  # raises / flyes
  ("glute-ham raise","extension ischio-fessiers"),("hanging knee raise","relevé de genoux suspendu"),
  ("hanging leg raise","relevé de jambes suspendu"),("lateral raise","élévations latérales"),
  ("front raise","élévations frontales"),("bent-over reverse fly","oiseau buste penché"),
  ("reverse fly","oiseau"),("cable fly","écarté à la poulie"),("db fly","écarté haltères"),
  ("reverse pec-deck","pec deck inversé"),
  # arms / triceps
  ("overhead triceps extension","extension triceps au-dessus de la tête"),
  ("triceps extension","extension triceps"),("hammer curl","curl marteau"),
  ("skull crusher","barre au front"),("tricep kickback","extension triceps buste penché"),
  ("kickback","extension triceps buste penché"),
  # olympic-ish
  ("hang power snatch","arraché suspendu"),("power snatch","arraché"),("snatch","arraché"),
  ("hang power clean","épaulé suspendu"),("trap bar","barre hexagonale"),
  # bands / modifiers
  ("external rotation band","rotation externe à l'élastique"),("external rotation","rotation externe"),
  ("band pull-apart","écartement à l'élastique"),("band pull-down","tirage vertical à l'élastique"),
  ("band face pull","tirage visage à l'élastique"),("band pallof press","anti-rotation à l'élastique"),
  ("band pallof","anti-rotation à l'élastique"),("mini-band","mini-bande"),
  ("single-arm","un bras"),("single arm","un bras"),("b-stance","appui décalé"),
  ("body roll","roulis du corps"),("step-jacks","écarts alternés sans saut"),
  ("step jacks","écarts alternés sans saut"),("low-impact","à faible impact"),
  ("low impact","à faible impact"),("push-off","poussée au mur"),
  ("tuck rocks","bascules groupées"),("top set","série lourde"),("kb","kettlebell"),
  # endurance / tennis
  ("strides","accélérations"),("split-step","saut d'appel"),
]
TIER2 += [
  ("z-press","développé assis au sol"),("arnold press","développé Arnold"),
  ("cable curl","curl à la poulie"),("cable overhead triceps","extension triceps nuque à la poulie"),
  ("cable single-arm row","rowing un bras à la poulie"),("cable row","rowing à la poulie"),
  ("cable fly","écarté à la poulie"),("cable lateral raise","élévations latérales à la poulie"),
  ("overhead triceps extension","extension triceps nuque"),("overhead triceps","triceps nuque"),
  ("reverse curl","curl inversé"),("bench dips","dips sur banc"),
  ("fingertip drag","effleurement des doigts"),("fist swim","nage poing fermé"),
  ("barre trap","barre hexagonale"),("band curl","curl à l'élastique"),
  ("band pull-apart","écartement à l'élastique"),
  ("machine chest press","développé poitrine à la machine"),("chest press","développé poitrine"),
  ("machine press","développé à la machine"),
  ("overhead triceps db extension","extension triceps nuque haltères"),
  ("overhead triceps haltères extension","extension triceps nuque haltères"),
  ("overhead triceps dumbbell extension","extension triceps nuque haltères"),
  ("push-press","développé avec impulsion"),("chest supported row","rowing buste appuyé"),
  ("crescent lunge","fente du croissant"),("scapula retraction","rétraction des omoplates"),
  ("shoulder activation","activation des épaules"),("incline barbell press","développé incliné"),
  ("barbell press","développé à la barre"),("chest-supported","buste appuyé"),
]
for old,new in TIER2:
    TOKENS.append({"token":old,"fr":new,"en":None,"es":None,"scope":None,"wb":False,"plural":True})
# bare fallbacks (compounds already matched first via longest-first sort)
for old,new in [("row","rowing"),("fly","écarté"),("raise","élévation"),
                ("ladder","échelle"),("heavy","lourd"),("incline","incliné"),
                ("decline","décliné"),("bench","banc"),("cable","à la poulie"),
                ("band","élastique"),("press","développé")]:
    TOKENS.append({"token":old,"fr":new,"en":None,"es":None,"scope":None,"wb":True,"plural":True})
# db standalone (word boundary, after compounds) → haltères
TOKENS.append({"token":"db","fr":"haltères","en":None,"es":None,"scope":None,"wb":True,"plural":False})

# extra gloss strips (now-redundant English/FR parentheticals) — all langs
for gl in ["(max de tours)","(as many rounds as possible)","(máximo de vueltas)","(paddles)",
           "(cable fly)","(fingertip drag)","(fist swim)","(hang power snatch)","(hang power clean)",
           "(strides)","(skater hop)","(step-up)","(goblet)","(KB)","(DB)"]:
    PHRASE.append((gl, "", None, None))
# residual English plural 'rounds'/'round' in FR only (around Tabata)
TOKENS.append({"token":"rounds","fr":"tours","en":None,"es":None,"scope":None,"wb":True,"plural":False})
TOKENS.append({"token":"round","fr":"tour","en":None,"es":None,"scope":None,"wb":True,"plural":False})

# longest-first so multi-word/compound tokens win over their substrings
TOKENS.sort(key=lambda t: len(t["token"]), reverse=True)

def cap_like(s, start, matched, repl):
    """Capitalize repl[0] iff matched starts uppercase AND sits at a sentence start.
    Mid-sentence (incl. all-caps acronyms like EMOM/AMRAP) → keep glossary lowercase form."""
    if not matched[:1].isupper():
        return repl
    pre = s[:start].rstrip()
    at_start = (start == 0) or (pre == "") or (pre[-1:] in ".!?:\n—")
    if at_start and repl[:1].isalpha():
        return repl[:1].upper() + repl[1:]
    return repl

def pluralize_fr(repl):
    """Pluralize first word of a FR replacement (French plural usually on the noun)."""
    m = re.match(r"(\S+)(.*)", repl, re.S)
    if not m: return repl
    w, rest = m.group(1), m.group(2)
    if w[-1:].lower() in ("s","x","z"): return repl
    return w+"s"+rest

def apply_token(s, rule, lang):
    repl = rule.get(lang)
    if repl is None:
        return s, 0
    tok = rule["token"]
    body = re.escape(tok)
    # optional trailing plural 's' (English) — consumed; pluralize FR if name
    if rule["wb"]:
        pat = r"\b"+body+r"(s?)\b"
    else:
        pat = body+r"(s?)\b"
    cnt = [0]
    def sub(m):
        plural_s = m.group(1) == "s"
        r = repl
        if plural_s and rule["plural"]:
            r = pluralize_fr(r)
        r = cap_like(s, m.start(), m.group(0), r)
        cnt[0]+=1
        return r
    out = re.sub(pat, sub, s, flags=re.IGNORECASE)
    return out, cnt[0]

COLLAPSE = re.compile(r"([\wàâäéèêëîïôöùûüç' \-/]+?) \(\1\)", re.IGNORECASE)

def transform(s, sport, lang):
    orig = s
    # 1) phrase pairs (strip English gloses / reword)
    for old, new, scope, langs in PHRASE:
        if scope is not None and sport not in scope: continue
        if langs is not None and lang not in langs: continue
        if new == "":
            s = re.sub(r"\s*"+re.escape(old), "", s, flags=re.IGNORECASE)
        else:
            s = re.sub(re.escape(old), new, s, flags=re.IGNORECASE)
    # 2) tokens longest-first
    for rule in TOKENS:
        if rule["scope"] is not None and sport not in rule["scope"]: continue
        s,_ = apply_token(s, rule, lang)
    # 3) collapse "X (X)" duplicate glose
    prev=None
    while prev!=s:
        prev=s; s=COLLAPSE.sub(r"\1", s)
    # dedup "fractionné 20/10 20/10" artifact (tabata token + pre-existing 20/10)
    s = re.sub(r"(fractionné 20/10) 20/10", r"\1", s)
    # tidy artifacts from glose-stripping ONLY (do NOT touch French ' :' ' ;' typography)
    s = re.sub(r"  +", " ", s)
    s = re.sub(r" +,", ",", s)
    s = re.sub(r"\(\s+", "(", s); s = re.sub(r"\s+\)", ")", s)
    s = re.sub(r"\(\)", "", s)
    s = s.strip()
    return s

# ---- walk + collect user-facing leaf strings per file ----
def collect(node, field, out):
    if isinstance(node, dict):
        if set(node.keys()) <= {"fr","en","es"} and node:
            if field in USERFACING:
                for lang in ("fr","en","es"):
                    if lang in node and isinstance(node[lang], str):
                        out.append((lang, node[lang]))
            return
        for k,v in node.items():
            collect(v, k, out)
    elif isinstance(node, list):
        for v in node:
            collect(v, field, out)

def run_main():
  global changelog, total
  dryrun = "--apply" not in sys.argv
  changelog = []   # (file, lang, old, new)
  total = 0
  for f in sorted(glob.glob(os.path.join(TDIR,"*.json"))):
    sport = os.path.basename(f).split("-")[0]
    raw = open(f, encoding="utf-8").read()
    d = json.loads(raw)
    leaves = []
    collect(d, None, leaves)
    # unique (lang, value)
    seen=set(); edits=[]
    for lang, val in leaves:
        key=(lang,val)
        if key in seen: continue
        seen.add(key)
        new = transform(val, sport, lang)
        if new != val:
            edits.append((lang, val, new))
    # apply longest-old-first to avoid nested-string collisions
    edits.sort(key=lambda e: len(e[1]), reverse=True)
    newraw = raw
    for lang, old, new in edits:
        # lang-scoped: match the on-disk key prefix `"fr" : "..."` so identical
        # strings in OTHER languages (esp. deferred ES names) are NOT touched.
        old_tok = json.dumps(old, ensure_ascii=False)
        new_tok = json.dumps(new, ensure_ascii=False)
        pat = re.compile(r'("'+lang+r'"\s*:\s*)'+re.escape(old_tok))
        newraw2, n = pat.subn(lambda m: m.group(1)+new_tok, newraw)
        if n:
            newraw = newraw2
            changelog.append((os.path.basename(f), lang, old, new))
            total += n
        else:
            changelog.append((os.path.basename(f), lang+"!MISS", old, new))
    # validate JSON still parses
    try:
        json.loads(newraw)
    except Exception as e:
        print("!! JSON broke in", f, e); sys.exit(1)
    if not dryrun and newraw != raw:
        open(f,"w",encoding="utf-8").write(newraw)

  json.dump(changelog, open("/tmp/trio3_changelog.json","w"), ensure_ascii=False, indent=1)
  miss=[c for c in changelog if c[1].endswith("!MISS")]
  print(("APPLIED" if not dryrun else "DRYRUN"), "changes:", total, "files touched:",
        len({c[0] for c in changelog if not c[1].endswith('!MISS')}))
  print("MISSES (old token not found raw):", len(miss))
  for c in miss[:10]: print("  MISS", c[0], repr(c[2][:60]))

if __name__ == "__main__":
    run_main()
