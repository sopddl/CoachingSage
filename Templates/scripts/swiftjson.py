import json
def jstr(s): return json.dumps(s, ensure_ascii=False)
def ser(v, ind):
    if isinstance(v, dict):
        if not v: return "{\n\n"+" "*ind+"}"
        parts=[" "*(ind+2)+jstr(k)+" : "+ser(v[k],ind+2) for k in sorted(v.keys())]
        return "{\n"+",\n".join(parts)+"\n"+" "*ind+"}"
    if isinstance(v, list):
        if not v: return "[\n\n"+" "*ind+"]"
        parts=[" "*(ind+2)+ser(e,ind+2) for e in v]
        return "[\n"+",\n".join(parts)+"\n"+" "*ind+"]"
    if isinstance(v, bool): return "true" if v else "false"
    if v is None: return "null"
    if isinstance(v, int): return str(v)
    if isinstance(v, float):
        return repr(v)
    return jstr(v)
def dumps(obj): return ser(obj,0)
