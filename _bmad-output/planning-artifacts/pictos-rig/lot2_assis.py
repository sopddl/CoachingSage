import sys
sys.path.insert(0, ".")
from posture_rig import *

FIGURES = []
def add_figure(title, caption, svg):
    FIGURES.append((title, caption, svg))

def build_seated(name, hip_xy, torso_angle, extra_legs_fn, arm_fn=None, ground_y=43):
    c = Chain("hip", hip_xy)
    c.add("shoulder", TORSO, torso_angle)
    head_c, neck_parts = head_and_neck(c.points["shoulder"], torso_angle)
    extra_legs_fn(c)
    if arm_fn:
        arm_fn(c)
    svg = [svg_open(), ground(ground_y)]
    svg.append(c.render())
    svg += neck_parts
    svg.append(svg_close())
    bounds_check(name, list(c.points.values()) + [head_c])
    return "".join(svg)

# ---- Sukhasana : jambes qui se croisent en X étroit sous le buste (genoux bas et
# rapprochés) — bien plus étroit que Baddha Konasana ci-dessous (genoux hauts et
# largement écartés en Y plat) : les 2 poses ne peuvent plus être confondues ----
svg = build_seated("Sukhasana", (40, 34), 270, lambda c: (
    c.add_leg("R", 55, 220, 260, from_name="hip"),
    c.add_leg("L", 125, 320, 280, from_name="hip"),
))
add_figure("Sukhasana", "Assis tailleur — jambes croisées en X étroit (vs Baddha Konasana : Y large)", svg)

# ---- Dandasana (bâton) : jambes tendues devant, buste droit, mains au sol À CÔTÉ
# des hanches (bras droit vers le bas, pas en arrière) ----
svg = build_seated("Dandasana", (31, 38), 270, lambda c: (
    c.add_leg("", 5, 5, 350, from_name="hip"),
), arm_fn=lambda c: c.add_arm("", 100, 100, from_name="shoulder"))
add_figure("Dandasana", "Bâton — mains au sol à côté des hanches (bras vertical)", svg)

# ---- Baddha Konasana (papillon) : genoux hauts et largement écartés sur le côté,
# plantes de pieds jointes devant le bassin (Y plat, très différent du X étroit de
# Sukhasana ci-dessus). Bras ajoutés (absents avant — retour Sophie "où sont les
# bras") : mains posées sur les pieds joints, geste réel du papillon ----
svg = build_seated("BaddhaKonasana", (40, 36), 270, lambda c: (
    c.add_leg("R", 10, 190, 270, from_name="hip"),
    c.add_leg("L", 170, 350, 270, from_name="hip"),
), arm_fn=lambda c: c.add_arm("", 100, 100, from_name="shoulder"))
add_figure("BaddhaKonasana", "Papillon — genoux ouverts (geste-clé), bras vers les pieds joints", svg)

# ---- Paschimottanasana : jambes tendues devant, buste PLIÉ vers l'avant, BRAS
# tendus vers les pieds (absents avant — c'était la question) ----
c = Chain("hip", (27, 38))
c.add_leg("", 5, 5, 350, from_name="hip")
c.add("shoulder", TORSO, 320, from_name="hip", key=True)   # tronc plié VERS LES JAMBES, pas vers le bas
c.add_arm("", 30, 15, from_name="shoulder")   # bras tendus vers les pieds
head_c, neck_parts = head_and_neck(c.points["shoulder"], 320)
svg = [svg_open(), ground(38)]
svg.append(c.render())
svg += neck_parts
svg.append(svg_close())
bounds_check("Paschimottanasana", list(c.points.values()) + [head_c])
add_figure("Paschimottanasana", "Pince assise — bras tendus vers les pieds (geste-clé = buste plié)", "".join(svg))

# ---- UpavisthaKonasana : VUE DE FACE (pas de profil) — les 2 jambes symétriques
# largement écartées de chaque côté. Retour Sophie "où sont les bras" — tronc
# RÉELLEMENT plié vers le bas cette fois (avant, l'angle 270° le laissait tout droit
# malgré la légende "plié en avant"), bras ajoutés qui plongent entre les jambes ----
c = Chain("hip", (40, 12))
c.add("shoulder", TORSO, 90, key=True)   # tronc plié droit vers le bas, entre les jambes (geste-clé)
c.add("elbow", UPPER_ARM, 90, from_name="shoulder", kind='arm')
c.add("wrist", FOREARM, 90, kind='arm')
c.add_leg("R", 15, 15, 350, from_name="hip")
c.add_leg("L", 165, 165, 190, from_name="hip")
head_c, neck_parts = head_and_neck(c.points["shoulder"], 90)
svg = [svg_open(), ground(18)]
svg.append(c.render())
svg += neck_parts
svg.append(svg_close())
bounds_check("UpavisthaKonasana", list(c.points.values()) + [head_c])
add_figure("UpavisthaKonasana", "Grand écart assis — bras plongent entre les jambes, tronc plié (geste-clé)", "".join(svg))

# ============================================================
html = ['<!doctype html><html><head><meta charset="utf-8"><title>Lot 2 — assis</title><style>',
        'body{margin:0;padding:24px;background:#fff;font-family:-apple-system,sans-serif;}',
        '.grid{display:flex;flex-wrap:wrap;gap:20px;} figure{margin:0;text-align:center;}',
        '.cell{width:220px;height:150px;background:#f7f7f7;border-radius:8px;display:flex;align-items:center;justify-content:center;}',
        'svg{width:88%;height:88%;} figcaption{margin-top:8px;font-size:12px;color:#444;max-width:220px;}',
        '</style></head><body><div class="grid">']
for title, caption, body in FIGURES:
    html.append(f'<figure><div class="cell">{body}</div><figcaption><b>{title}</b><br>{caption}</figcaption></figure>')
html.append('</div></body></html>')
with open("lot2.html", "w") as f:
    f.write("\n".join(html))
print("OK — lot2.html écrit")
