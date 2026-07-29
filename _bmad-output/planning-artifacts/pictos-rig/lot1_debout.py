import sys
sys.path.insert(0, ".")
from posture_rig import *

FIGURES = []
def add_figure(title, caption, svg):
    FIGURES.append((title, caption, svg))

# ============================================================
# Tadasana — montagne, debout neutre (repris tel quel, déjà validé)
# ============================================================
c = Chain("ankle", (40, 43))
c.add("knee", SHIN, 270, kind='leg')
c.add("hip", THIGH, 270, kind='leg')
c.add("shoulder", TORSO, 270)
c.add_arm("", 100, 100, from_name="shoulder")   # RÈGLE PAR DÉFAUT : bras le long du corps, LÉGÈREMENT décalé
# (jamais pile à 90/270 : sinon le bras se superpose exactement à la colonne et devient invisible)
head_c, neck_parts = head_and_neck(c.points["shoulder"], 270)
svg = [svg_open(), ground(43)]
svg.append(c.render())
svg += neck_parts
svg.append(svg_close())
bounds_check("Tadasana", list(c.points.values()) + [head_c])
add_figure("Tadasana", "Montagne — debout neutre, bras le long du corps", "".join(svg))

# ============================================================
# Warrior1 — fente avant genou plié 90°, jambe arrière tendue,
# buste droit, bras tendus vers le haut (geste-clé)
# ============================================================
c = Chain("ankle", (34, 43))
c.add("knee", SHIN, 260, kind='leg')             # tibia avant, léger recul (genou au-dessus cheville)
c.add("hip", THIGH, 240, kind='leg')             # cuisse avant repliée, hanche reculée et haute
c.add("shoulder", TORSO, 280)        # buste droit, légèrement en avant
c.add("elbow", UPPER_ARM, 315, key=True, kind='arm')   # bras tendu vers le haut, le plus vertical possible dans le cadre
c.add("wrist", FOREARM, 315, key=True, kind='arm')
c.add("kneeB", THIGH, 15, from_name="hip", kind='leg')   # jambe arrière tendue vers le bas-arrière
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
bounds_check("Warrior1", list(c.points.values()) + [head_c, toe_f])
svg.append(svg_close())
add_figure("Warrior1", "Guerrier 1 — bras tendus au-dessus de la tête (geste-clé)", "".join(svg))

# ============================================================
# Warrior2 — fente avant genou plié 90°, buste vertical (pas
# penché), bras tendu à l'HORIZONTALE vers l'avant (geste-clé)
# ============================================================
c = Chain("ankle", (34, 43))
c.add("knee", SHIN, 260, kind='leg')
c.add("hip", THIGH, 240, kind='leg')
c.add("shoulder", TORSO, 270)         # buste bien vertical (contraste avec Warrior1)
c.add("elbow", UPPER_ARM, 0, key=True, kind='arm')    # bras tendu à l'horizontale vers l'avant
c.add("wrist", FOREARM, 0, key=True, kind='arm')
c.add("kneeB", THIGH, 15, from_name="hip", kind='leg')
c.add("ankleB", SHIN, 15, kind='leg')
c.add("toeB", FOOT, 15, kind='leg')
toe_f = pt(c.points["ankle"], FOOT, 15)
head_c, neck_parts = head_and_neck(c.points["shoulder"], 270)
svg = [svg_open(), ground(45)]
svg.append(line(c.points["ankle"], toe_f))
svg.append(joint(c.points["ankle"]))
svg.append(c.render(mark_root_joint=False))
svg.append(joint(c.points["ankle"]))
svg += neck_parts
bounds_check("Warrior2", list(c.points.values()) + [head_c, toe_f])
svg.append(svg_close())
add_figure("Warrior2", "Guerrier 2 — bras tendu à l'horizontale devant (geste-clé)", "".join(svg))

# ============================================================
# Tree — équilibre 1 jambe, autre pied contre la cuisse,
# bras levés au-dessus de la tête
# ============================================================
c = Chain("ankle", (40, 43))
c.add("knee", SHIN, 270, kind='leg')
c.add("hip", THIGH, 270, kind='leg')
c.add("shoulder", TORSO, 270)
c.add("elbow", UPPER_ARM, 322, key=True, kind='arm')
c.add("wrist", FOREARM, 322, key=True, kind='arm')
c.add_leg("B", 185, 35, 30, from_name="hip", key=True)   # cheville ramenée EXACTEMENT contre la cuisse d'appui
toe_f = pt(c.points["ankle"], FOOT, 15)
head_c, neck_parts = head_and_neck(c.points["shoulder"], 270)
svg = [svg_open(), ground(43)]
svg.append(line(c.points["ankle"], toe_f))
svg.append(joint(c.points["ankle"]))
svg.append(c.render(mark_root_joint=False))
svg.append(joint(c.points["ankle"]))
svg += neck_parts
bounds_check("Tree", list(c.points.values()) + [head_c, toe_f])
svg.append(svg_close())
add_figure("Tree", "Arbre — équilibre 1 jambe, pied contre la cuisse (geste-clé)", "".join(svg))

# ============================================================
# Utkatasana — chaise, genoux pliés comme assis dans l'air,
# buste incliné en avant, bras levés au-dessus de la tête
# ============================================================
c = Chain("ankle", (40, 43))
c.add("knee", SHIN, 280, kind='leg')
c.add("hip", THIGH, 210, key=True, kind='leg')      # hanche reculée et basse (geste-clé : flexion genou+hanche)
c.add("shoulder", TORSO, 300)
c.add("elbow", UPPER_ARM, 300, kind='arm')
c.add("wrist", FOREARM, 300, kind='arm')
toe_f = pt(c.points["ankle"], FOOT, 15)
head_c, neck_parts = head_and_neck(c.points["shoulder"], 300)
svg = [svg_open(), ground(45)]
svg.append(line(c.points["ankle"], toe_f))
svg.append(joint(c.points["ankle"]))
svg.append(c.render(mark_root_joint=False))
svg.append(joint(c.points["ankle"]))
svg += neck_parts
bounds_check("Utkatasana", list(c.points.values()) + [head_c, toe_f])
svg.append(svg_close())
add_figure("Utkatasana", "Chaise — genoux+hanche pliés (geste-clé), bras levés", "".join(svg))

# ============================================================
# Assemble HTML
# ============================================================
html = ['<!doctype html><html><head><meta charset="utf-8"><title>Lot 1 — debout</title><style>',
        'body{margin:0;padding:24px;background:#fff;font-family:-apple-system,sans-serif;}',
        '.grid{display:flex;flex-wrap:wrap;gap:20px;} figure{margin:0;text-align:center;}',
        '.cell{width:220px;height:150px;background:#f7f7f7;border-radius:8px;display:flex;align-items:center;justify-content:center;}',
        'svg{width:88%;height:88%;} figcaption{margin-top:8px;font-size:12px;color:#444;max-width:220px;}',
        '</style></head><body><div class="grid">']
for title, caption, body in FIGURES:
    html.append(f'<figure><div class="cell">{body}</div><figcaption><b>{title}</b><br>{caption}</figcaption></figure>')
html.append('</div></body></html>')
with open("lot1.html", "w") as f:
    f.write("\n".join(html))
print("OK — lot1.html écrit")
