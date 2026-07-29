import base64
import json
import pathlib

# Planche v2 — paires départ → position clé (retour Sophie 07-11), avec les
# verdicts des reviews agents (expert doctrine + UX). Les verdicts sont lus
# depuis planche_verdicts.json (rempli après les reviews).

D = pathlib.Path("ai-explo/planche")
V = json.loads(pathlib.Path("planche_verdicts.json").read_text())

ROWS = [
    ("Guerrier 1", "femme · yoga", "start_stand_fixed.png", "warrior1_fixed2.png"),
    ("Cobra", "femme · yoga", "start_prone_kontext2.png", "cobra_kontext2.png"),
    ("Squat gobelet", "homme · muscu", "start_goblet_kontext2.png", "goblet_squat_kontext2.png"),
    ("Soulevé de terre roumain", "homme · muscu", "start_deadlift_fixed.png", "deadlift_kontext3.png"),
]

VERDICT_COLORS = {"OK": "#3f8f5c", "PRESQUE": "#e8a93d", "KO": "#c65a37"}

SUB_EXTRA = ("Pipeline : image A générée une fois par type de départ (réutilisable pour tout le catalogue), "
             "image B = édition de A par flux-kontext (~0,04 $/image) — personnage et décor préservés par construction.")


def b64(name):
    return "data:image/png;base64," + base64.b64encode((D / name).read_bytes()).decode()


html = ["""<!doctype html><html><head><meta charset="utf-8"><title>Planche v2 — paires départ / position clé</title><style>
body{margin:0;padding:28px;background:#fafafa;font-family:-apple-system,sans-serif;color:#222;}
h1{font-size:22px;margin:0 0 4px;} .sub{color:#666;font-size:13px;margin-bottom:24px;max-width:860px;line-height:1.5;}
.row{background:#fff;border-radius:12px;padding:18px;margin-bottom:16px;box-shadow:0 1px 3px rgba(0,0,0,.08);}
.head{display:flex;align-items:baseline;gap:10px;margin-bottom:12px;}
.head h2{font-size:17px;margin:0;} .tag{font-size:12px;color:#888;}
.verdict{font-size:12px;font-weight:600;color:#fff;border-radius:99px;padding:2px 10px;}
.pair{display:flex;gap:14px;align-items:center;}
.pair img{width:280px;height:280px;object-fit:cover;border-radius:8px;}
.arrow{font-size:28px;color:#bbb;}
.lbl{font-size:11px;color:#999;text-align:center;margin-top:5px;}
.notes{flex:1;min-width:240px;font-size:13px;line-height:1.5;color:#444;padding-left:8px;}
.notes b{font-size:12px;color:#777;text-transform:uppercase;letter-spacing:.4px;}
.notes ul{margin:4px 0 10px;padding-left:18px;}
</style></head><body>
<h1>Planche v2 — mouvement en 2 images : départ → position clé</h1>
<div class="sub">Chaque exercice = position de départ (debout droit / allongé à plat) puis position clé.
Chaque image passe 3 gates : revue anti-bug multimodale (Fable : pieds/mains/orientation/équipement/cohérence de paire), puis expert doctrine sportive, puis UX novice — à toi de juger uniquement le RENDU (style, personnages).<br>""" + SUB_EXTRA + """</div>
"""]
for title, tag, img_a, img_b in ROWS:
    v = V[title]
    expert = "".join(f"<li>{x}</li>" for x in v["expert"])
    ux = "".join(f"<li>{x}</li>" for x in v["ux"])
    html.append(
        f'<div class="row"><div class="head"><h2>{title}</h2><span class="tag">{tag}</span>'
        f'<span class="verdict" style="background:{VERDICT_COLORS[v["verdict"]]}">{v["verdict"]}</span></div>'
        f'<div class="pair">'
        f'<div><img src="{b64(img_a)}"><div class="lbl">1 · départ</div></div>'
        f'<div class="arrow">→</div>'
        f'<div><img src="{b64(img_b)}"><div class="lbl">2 · position clé</div></div>'
        f'<div class="notes"><b>Expert sport</b><ul>{expert}</ul><b>UX novice</b><ul>{ux}</ul></div>'
        f'</div></div>')
html.append("</body></html>")
out = pathlib.Path("planche-echantillons-v2.html")
out.write_text("\n".join(html))
print(f"OK — {out} ({out.stat().st_size // 1024} KB)")
