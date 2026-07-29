import sys
sys.path.insert(0, ".")
from posture_rig import *

FIGURES = []
def add_figure(title, caption, svg, zoom=None):
    FIGURES.append((title, caption, svg, zoom))

def seated_breathing(name, upper_angle, fore_angle, caption):
    c = Chain("hip", (40, 34))
    c.add("shoulder", TORSO, 270)
    c.add_leg("R", 55, 220, 260, from_name="hip")
    c.add_leg("L", 125, 320, 280, from_name="hip")
    c.add_arm("", upper_angle, fore_angle, from_name="shoulder", key=True)
    head_c, neck_parts = head_and_neck(c.points["shoulder"], 270)
    inner = c.render() + "".join(neck_parts)
    svg = [svg_open(), ground(43), inner, svg_close()]
    bounds_check(name, list(c.points.values()) + [head_c])
    # 4e retour Sophie : "la main n'est pas sur la gorge" / "pas devant le visage" —
    # le zoom montrait fidèlement la géométrie, mais la géométrie elle-même ratait sa
    # cible (recherche numérique refaite pour que le poignet touche vraiment gorge/
    # visage). Zoom aussi agrandi (panneau trop petit pour être vu — retour Dirgha).
    zoom = zoom_inset(inner, c.points["wrist"], radius=7)
    add_figure(name, caption, "".join(svg), zoom=zoom)

# Les 3 respirations n'ont réellement qu'UN geste différent (position de la main) —
# angles recalculés numériquement pour que le poignet touche vraiment sa cible.
# Dirgha : respiration abdominale, main sur le VENTRE (geste-clé)
seated_breathing("Dirgha", 60, 320, "Assis, main sur le ventre — respiration abdominale (geste-clé)")
# Ujjayi : respiration, main sur la GORGE (geste-clé)
seated_breathing("Ujjayi", 25, 220, "Assis, main sur la gorge — respiration Ujjayi (geste-clé)")
# Nadi Shodhana : respiration alternée, main devant le VISAGE/nez (geste-clé)
seated_breathing("NadiShodhana", 0, 220, "Assis, main devant le visage — respiration alternée (geste-clé)")

# ---- Surya Namaskar A : frame-clé = flexion avant debout (Uttanasana), même construction que ForwardFold (corrigée) ----
c = Chain("ankle", (40, 43))
c.add("knee", SHIN, 270, kind='leg')
c.add("hip", THIGH, 270, kind='leg')
c.add("shoulder", TORSO, 70)     # plié VERS L'AVANT (pas à la verticale, sinon ça retrace la jambe)
c.add("elbow", UPPER_ARM, 80, from_name="shoulder", kind='arm')
c.add("wrist", FOREARM, 80, kind='arm')
head_c, neck_parts = head_and_neck(c.points["shoulder"], 70)
toe_f = pt(c.points["ankle"], FOOT, 15)
svg = [svg_open(), ground(43)]
svg.append(line(c.points["ankle"], toe_f))
svg.append(joint(c.points["ankle"]))
svg.append(c.render(mark_root_joint=False))
svg.append(joint(c.points["ankle"]))
svg += neck_parts
bounds_check("SuryaNamaskarA", list(c.points.values()) + [head_c, toe_f])
svg.append(svg_close())
add_figure("SuryaNamaskarA", "Salutation au soleil A — frame-clé : flexion avant debout", "".join(svg))

# ---- Surya Namaskar B : frame-clé = fente basse guerrier, bras levés ----
c = Chain("ankle", (34, 43))
c.add("knee", SHIN, 260, kind='leg')
c.add("hip", THIGH, 240, kind='leg')
c.add("shoulder", TORSO, 280)
c.add("elbow", UPPER_ARM, 315, kind='arm')
c.add("wrist", FOREARM, 315, kind='arm')
c.add("kneeB", THIGH, 15, from_name="hip", kind='leg')
c.add("ankleB", SHIN, 15, kind='leg')
c.add("toeB", FOOT, 15, kind='leg')
toe_f = pt(c.points["ankle"], FOOT, 15)
head_c, neck_parts = head_and_neck(c.points["shoulder"], 280)
svg = [svg_open(), ground(45)]
svg.append(line(c.points["ankle"], toe_f))
svg.append(joint(c.points["ankle"]))
svg.append(c.render(mark_root_joint=False))
svg.append(joint(c.points["ankle"]))
svg += neck_parts
bounds_check("SuryaNamaskarB", list(c.points.values()) + [head_c, toe_f])
svg.append(svg_close())
add_figure("SuryaNamaskarB", "Salutation au soleil B — frame-clé : fente basse, bras levés", "".join(svg))

# ============================================================
html = ['<!doctype html><html><head><meta charset="utf-8"><title>Lot 7</title><style>',
        'body{margin:0;padding:24px;background:#fff;font-family:-apple-system,sans-serif;}',
        '.grid{display:flex;flex-wrap:wrap;gap:20px;} figure{margin:0;text-align:center;}',
        '.cellrow{display:flex;gap:6px;} .cell{width:220px;height:150px;background:#f7f7f7;border-radius:8px;display:flex;align-items:center;justify-content:center;}',
        '.cell.zoom{width:110px;background:#fff3ea;}',
        'svg{width:88%;height:88%;} figcaption{margin-top:8px;font-size:12px;color:#444;max-width:220px;}',
        '</style></head><body><div class="grid">']
for title, caption, body, zoom in FIGURES:
    zoom_div = f'<div class="cell zoom">{zoom}</div>' if zoom else ''
    html.append(f'<figure><div class="cellrow"><div class="cell">{body}</div>{zoom_div}</div><figcaption><b>{title}</b><br>{caption}</figcaption></figure>')
html.append('</div></body></html>')
with open("lot7.html", "w") as f:
    f.write("\n".join(html))
print("OK — lot7.html écrit")
