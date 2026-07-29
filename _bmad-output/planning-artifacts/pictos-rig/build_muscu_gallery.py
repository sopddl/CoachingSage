import base64
import io
import json
import pathlib

from PIL import Image

# Galerie OK/KO de la VAGUE MUSCU pour Sophie (gate rendu uniquement).
# Lit muscu_verdicts.json {slug: {file, gate1|verdict, note}} — le champ `verdict`
# (final, post gates 2-3) prime sur `gate1` s'il est présent.

M = pathlib.Path("ai-explo/muscu")
verdicts = json.loads((M / "muscu_verdicts.json").read_text())
COLORS = {"OK": "#3f8f5c", "PRESQUE": "#e8a93d", "KO": "#c65a37",
          "A_REVOIR": "#8a8a8a", "GELE": "#6b7b8c", "DEDUP": "#9a8fb8"}

# slug -> (titre FR, image A de départ)
META = {
 "goblet-squat": ("Squat gobelet", "A_m_goblet.png"),
 "plank": ("Planche (gainage)", "A_m_plank.png"),
 "lunge-dumbbell": ("Fente haltères", "A_m_stand_db.png"),
 "rdl-dumbbell": ("Soulevé roumain haltères", "A_m_stand_db.png"),
 "biceps-curl": ("Curl biceps", "A_m_stand_db.png"),
 "rdl-barbell": ("Soulevé roumain barre", "A_m_stand_bb_v2.png"),
 "ohp-barbell": ("Développé militaire", "A_m_stand_bb_v2.png"),
 "back-squat": ("Back squat", "A_m_stand_bb_v2.png"),
 "squat-bodyweight": ("Squat poids du corps", "A_m_stand.png"),
 "triceps-overhead": ("Extension triceps nuque", "A_m_stand_db.png"),
 "deadlift-conventional": ("Soulevé de terre (départ sol)", "A_m_stand_bb_v2.png"),
 "arnold-press-seated": ("Développé épaules assis", "A_m_stand_db.png"),
 "lat-pulldown": ("Tirage vertical machine", "A_m_stand.png"),
 "pullup": ("Traction barre fixe", "A_m_stand.png"),
 "box-jump": ("Box jump", "A_m_stand.png"),
 "bulgarian-split-squat": ("Fente bulgare", "A_m_stand_db.png"),
 "pushup-incline-chair": ("Pompes inclinées (chaise)", "A_m_plank.png"),
 "lateral-raise": ("Élévations latérales", "A_m_stand_db_front.png"),
 "forearm-plank": ("Planche avant-bras", "A_m_plank.png"),
 "calf-raise": ("Mollets debout", "A_m_stand.png"),
 "kb-swing": ("Kettlebell swing", "A_m_stand_db.png"),
 "bentover-row-barbell": ("Rowing barre buste penché", "A_m_stand_bb_v2.png"),
 "pushup": ("Pompes", "A_m_plank.png"),
 "side-plank": ("Planche latérale", "A_m_plank.png"),
 "bird-dog": ("Bird-dog", "A_m_tabletop.png"),
 "wall-sit": ("Chaise au mur", "A_m_stand.png"),
 "hanging-leg-raise": ("Relevé de jambes suspendu", "A_m_stand.png"),
 "pallof-press": ("Pallof press", "A_m_stand.png"),
 "triceps-pushdown": ("Triceps poulie", "A_m_stand.png"),
 "nordic-curl": ("Nordic curl", "A_m_stand.png"),
 "dips": ("Dips", "A_m_stand.png"),
 "glute-bridge": ("Pont fessier", None), "dead-bug": ("Dead bug", None),
 "hollow-hold": ("Hollow hold", None), "clamshell": ("Coquillage", None),
 "bench-press-barbell": ("Développé couché barre", None),
 "bench-press-dumbbell": ("Développé couché haltères", None),
 "pullover": ("Pullover", None), "hip-thrust": ("Hip thrust", None),
 "leg-press": ("Presse à cuisses", None), "leg-extension": ("Leg extension", None),
 "leg-curl": ("Leg curl", None), "reverse-hyper": ("Reverse hyper", None),
 "cable-fly": ("Écarté poulie", None), "cable-row": ("Rowing poulie assis", None),
 "facepull": ("Face pull", None), "ytw": ("Y-T-W", None),
 "walking-lunge": ("Fentes marchées", None),
}


def b64(p):
    im = Image.open(p).convert("RGB").resize((512, 512))
    buf = io.BytesIO()
    im.save(buf, "JPEG", quality=82)
    return "data:image/jpeg;base64," + base64.b64encode(buf.getvalue()).decode()


html = ["""<!doctype html><html><head><meta charset="utf-8"><title>Vague muscu — galerie OK/KO</title><style>
body{margin:0;padding:28px;background:#fafafa;font-family:-apple-system,sans-serif;color:#222;}
h1{font-size:22px;margin:0 0 4px;} h2{font-size:16px;margin:28px 0 10px;color:#555;}
.sub{color:#666;font-size:13px;margin-bottom:8px;max-width:860px;line-height:1.5;}
.grid{display:flex;flex-wrap:wrap;gap:14px;}
.card{background:#fff;border-radius:10px;padding:10px;box-shadow:0 1px 3px rgba(0,0,0,.08);width:330px;}
.card .imgs{display:flex;gap:4px;} .card img{width:160px;height:160px;object-fit:cover;border-radius:6px;}
.card .t{font-weight:600;font-size:13px;margin:8px 0 2px;display:flex;gap:8px;align-items:center;}
.v{font-size:11px;font-weight:600;color:#fff;border-radius:99px;padding:1px 8px;}
.n{font-size:11.5px;color:#555;line-height:1.4;}
</style></head><body>
<h1>Vague muscu — galerie OK/KO</h1>
<div class="sub">Personnage homme canonique (dérivé de la paire squat gobelet validée planche v2).
Paires départ → position clé, pipeline 3 gates (anti-bug Fable pleine taille → expert doctrine →
UX novice). Juge le RENDU uniquement.</div>
"""]

SECTIONS = [("Candidats (gates 2-3 passés ou en cours)", ("OK", "PRESQUE")),
            ("À revoir — limites dures du générateur (2 essais, 2 recettes)", ("A_REVOIR",)),
            ("Gelés d'office — familles réfractaires connues", ("GELE", "DEDUP"))]
for title, states in SECTIONS:
    items = [(s, v) for s, v in verdicts.items() if (v.get("verdict") or v["gate1"]) in states]
    if not items:
        continue
    html.append(f"<h2>{title} · {len(items)}</h2><div class='grid'>")
    for slug, v in items:
        titre, a_name = META.get(slug, (slug, None))
        verdict = v.get("verdict") or v["gate1"]
        imgs = ""
        if v.get("file") and a_name:
            imgs = f'<div class="imgs"><img src="{b64(M / a_name)}"><img src="{b64(M / v["file"])}"></div>'
        note = v.get("note", "")
        if v.get("expert"):
            note += f" · <b>Expert :</b> {v['expert']}"
        if v.get("ux"):
            note += f" · <b>UX :</b> {v['ux']}"
        html.append(
            f'<div class="card">{imgs}<div class="t">{titre}'
            f'<span class="v" style="background:{COLORS.get(verdict, "#999")}">{verdict}</span></div>'
            f'<div class="n">{note}</div></div>')
    html.append("</div>")
html.append("</body></html>")
out = pathlib.Path("galerie-muscu.html")
out.write_text("".join(html))
print(f"OK — {out} ({out.stat().st_size / 1e6:.1f} MB)")
