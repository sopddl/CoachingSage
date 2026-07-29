import base64
import io
import json
import pathlib

from PIL import Image

from review_widget import CSS as REV_CSS, JS as REV_JS
# round 3 (07-12 soir) : repartir d'une session de jugement vierge
REV_JS = REV_JS.replace("location.pathname.split('/').pop().replace('.html','')", "'galerie-vague4-r3'")

# Galerie VAGUE 4 pour Sophie (gate rendu uniquement) — mêmes codes visuels que
# galerie-muscu. Spécificité : pas d'image A (génération directe rig→FLUX), on
# montre le contrôle rig + le résultat.

V4 = pathlib.Path("ai-explo/vague4")
V3 = pathlib.Path("ai-explo/vague3")
PLANCHE = pathlib.Path("ai-explo/planche")
verdicts = json.loads((V4 / "vague4_verdicts.json").read_text())
COLORS = {"OK": "#3f8f5c", "CANDIDAT": "#3f8f5c", "PRESQUE": "#e8a93d",
          "KO": "#c65a37", "A_REVOIR": "#8a8a8a", "GELE": "#6b7b8c"}

TITRES = {
 "M_plank": "Planche (gainage)", "M_pushup": "Pompes (position basse)",
 "M_glute-bridge": "Pont fessier", "M_dead-bug": "Dead bug",
 "M_rdl-dumbbell": "Soulevé roumain haltère", "M_rdl-barbell": "Soulevé roumain barre",
 "M_bentover-row": "Rowing barre buste penché", "M_kb-swing": "Kettlebell swing",
 "M_calf-raise": "Mollets debout", "M_wall-sit": "Chaise au mur",
 "M_box-jump": "Box jump (réception)", "M_nordic-curl": "Nordic curl",
 "M_pullup": "Traction barre fixe", "M_hanging-leg-raise": "Relevé de jambes suspendu",
 "M_dips": "Dips", "M_pallof-press": "Pallof press",
 "M_triceps-pushdown": "Triceps poulie", "M_facepull": "Face pull",
 "M_cable-row": "Rowing poulie assis", "M_lat-pulldown": "Tirage vertical machine",
 "M_leg-extension": "Leg extension", "M_leg-curl": "Leg curl",
 "M_bench-press": "Développé couché barre", "M_hip-thrust": "Hip thrust",
 "M_side-plank": "Planche latérale", "M_bird-dog": "Bird-dog",
 "M_forearm-plank": "Planche avant-bras",
 "Y_butterfly": "Papillon (baddha konasana)", "Y_child": "Posture de l'enfant (balasana)",
 "Y_head-to-knee": "Tête au genou (janu sirsasana)", "Y_bird-dog": "Bird-dog (yoga)",
 "Y_warrior2": "Guerrier 2", "Y_warrior3": "Guerrier 3",
 "Y_wide-angle-seated-fold": "Grand angle assis", "Y_wide-legged-forward-fold": "Flexion jambes écartées",
 "Y_side-plank-f": "Planche latérale (yoga)",
}
# slug -> chemin du contrôle rig
CONTROLS = {
 "M_side-plank": V3 / "side-plank_control.png", "M_forearm-plank": V3 / "forearm-plank_control.png",
 "M_rdl-barbell": PLANCHE / "deadlift_control.png",
 "Y_warrior2": V3 / "warrior2_control.png", "Y_warrior3": V3 / "warrior3_control.png",
 "Y_wide-angle-seated-fold": V3 / "wide-angle-seated-fold_control.png",
 "Y_wide-legged-forward-fold": V3 / "wide-legged-forward-fold_control.png",
 "Y_side-plank-f": V3 / "side-plank_control.png",
}


def ctrl_path(slug):
    if slug in CONTROLS:
        return CONTROLS[slug]
    name = slug.split("_", 1)[1]
    return V4 / f"{name}_control.png"


def b64(p):
    im = Image.open(p).convert("RGB").resize((512, 512))
    buf = io.BytesIO()
    im.save(buf, "JPEG", quality=82)
    return "data:image/jpeg;base64," + base64.b64encode(buf.getvalue()).decode()


html = ["""<!doctype html><html><head><meta charset="utf-8"><title>Vague 4 — le reste des exos</title><style>
body{margin:0;padding:28px;background:#fafafa;font-family:-apple-system,sans-serif;color:#222;}
h1{font-size:22px;margin:0 0 4px;} h2{font-size:16px;margin:28px 0 10px;color:#555;}
.sub{color:#666;font-size:13px;margin-bottom:8px;max-width:860px;line-height:1.5;}
.grid{display:flex;flex-wrap:wrap;gap:14px;}
.card{background:#fff;border-radius:10px;padding:10px;box-shadow:0 1px 3px rgba(0,0,0,.08);width:330px;}
.card .imgs{display:flex;gap:4px;} .card img{width:160px;height:160px;object-fit:cover;border-radius:6px;}
.card .t{font-weight:600;font-size:13px;margin:8px 0 2px;display:flex;gap:8px;align-items:center;}
.v{font-size:11px;font-weight:600;color:#fff;border-radius:99px;padding:1px 8px;}
.n{font-size:11.5px;color:#555;line-height:1.4;}
.mod{font-size:11px;font-weight:700;color:#fff;background:#4a6fd4;border-radius:99px;padding:1px 8px;}
.card.is-mod{outline:3px solid #4a6fd4;outline-offset:-1px;}
""" + REV_CSS + """
</style></head><body>
<h1>Vague 4 — le reste des exos (rig → FLUX-canny-pro)</h1>
<div class="sub">Nouvelle recette : l'équipement (câbles, barres, banc, box, mur) est DESSINÉ dans le
contrôle rig, ce qui débloque des familles mortes (machines, dos-plat, allongé sur le dos).
Vignettes : contrôle rig → résultat. Juge le RENDU uniquement.</div>
"""]

SECTIONS = [("Candidats (gates expert + UX passés, notes dans les cartes)", ("OK", "CANDIDAT", "PRESQUE")),
            ("À revoir — limites dures du générateur (2 essais)", ("A_REVOIR", "KO")),
            ("Gelés d'office", ("GELE",))]
for title, states in SECTIONS:
    items = [(s, v) for s, v in verdicts.items()
             if isinstance(v, dict) and (v.get("verdict") or v.get("gate1")) in states]
    if not items:
        continue
    html.append(f"<h2>{title} · {len(items)}</h2><div class='grid'>")
    for slug, v in items:
        titre = TITRES.get(slug, slug)
        verdict = v.get("verdict") or v.get("gate1")
        cp = ctrl_path(slug)
        imgs = ""
        if v.get("file"):
            left = f'<img src="{b64(cp)}">' if cp.exists() else ""
            imgs = f'<div class="imgs">{left}<img src="{b64(V4 / v["file"])}"></div>'
        note = v.get("note_retry") or v.get("note", "")
        if v.get("expert"):
            note += f" · <b>Expert :</b> {v['expert']}"
        if v.get("ux"):
            note += f" · <b>UX :</b> {v['ux']}"
        # Badge « MODIFIÉ » : fichier plus récent que last_round.txt (bumpé après chaque round Sophie)
        lr = pathlib.Path("last_round.txt")
        lr_ts = float(lr.read_text().strip()) if lr.exists() else 0.0
        is_mod = bool(v.get("file")) and (V4 / v["file"]).exists() and (V4 / v["file"]).stat().st_mtime > lr_ts
        mod_badge = '<span class="mod">MODIFIÉ</span>' if is_mod else ""
        html.append(
            f'<div class="card{" is-mod" if is_mod else ""}" data-slug="{slug}">{imgs}<div class="t">{titre}'
            f'<span class="v" style="background:{COLORS.get(verdict, "#999")}">{verdict}</span>{mod_badge}</div>'
            f'<div class="n">{note}</div></div>')
    html.append("</div>")
html.append(REV_JS)
html.append("</body></html>")
out = pathlib.Path("galerie-vague4.html")
out.write_text("".join(html))
print(f"OK — {out} ({out.stat().st_size / 1e6:.1f} MB)")
