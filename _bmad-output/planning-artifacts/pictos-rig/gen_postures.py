import sys
sys.path.insert(0, ".")
from posture_rig import *
from rig import check_rig

FIGURES = []
def add_figure(title, caption, svg):
    FIGURES.append((title, caption, svg))

# ============================================================
# 1. DEBOUT — Tadasana (montagne), root = cheville
# ============================================================
c = Chain("ankle", (40, 43))
c.add("knee", SHIN, 270, kind='leg')
c.add("hip", THIGH, 270, kind='leg')
c.add("shoulder", TORSO, 270)
head_c, neck_parts = head_and_neck(c.points["shoulder"], 270)
svg = [svg_open(), ground(43)]
svg.append(c.render())
svg += neck_parts
svg.append(svg_close())
bounds_check("Tadasana", list(c.points.values()) + [head_c])
add_figure("Tadasana", "Debout — root=cheville", "".join(svg))

# ============================================================
# 2. ASSIS — Sukhasana (tailleur), root = bassin
# ============================================================
c = Chain("hip", (40, 34))
c.add("shoulder", TORSO, 270)
c.add_leg("R", 30, 220, 250, from_name="hip")    # cuisse pleine, tibia replié VERS L'ARRIÈRE (angle, pas longueur)
c.add_leg("L", 150, 320, 290, from_name="hip")
head_c, neck_parts = head_and_neck(c.points["shoulder"], 270)
svg = [svg_open(), ground(43)]
svg.append(c.render())
svg += neck_parts
svg.append(svg_close())
bounds_check("Sukhasana", list(c.points.values()) + [head_c])
add_figure("Sukhasana", "Assis — root=bassin, jambes croisées repliées symétriques", "".join(svg))

# ============================================================
# 3. ALLONGÉ — Savasana, root = hanche (dos au sol, vue de profil)
# ============================================================
GY = 30  # ligne de sol pour la vue allongée (le corps est HORIZONTAL, pas vertical)
c = Chain("hip", (46, GY))
c.add("shoulder", TORSO, 180)                 # tronc à l'horizontale vers la gauche (tête à gauche)
c.add("knee", THIGH, 5, from_name="hip", kind='leg')       # jambe tendue à l'horizontale vers la droite
c.add("ankle", SHIN, 5, kind='leg')
c.add("toe", FOOT, 350, kind='leg')
c.add_arm("", 120, 200, from_name="shoulder")   # bras plein, replié par l'angle (pas raccourci)
head_c, neck_parts = head_and_neck(c.points["shoulder"], 180)
svg = [svg_open(), ground(GY + 3)]
svg.append(c.render())
svg += neck_parts
svg.append(svg_close())
bounds_check("Savasana", list(c.points.values()) + [head_c])
add_figure("Savasana", "Allongé — root=hanche, tronc+jambe à l'horizontale", "".join(svg))

# ============================================================
# 4. QUADRUPÈDE — Chien tête en bas, root = hanche (point le plus haut)
# ============================================================
c = Chain("hip", (40, 15))
c.add("shoulder", TORSO, 15, from_name="hip")     # tronc descend vers l'avant-bas
c.add("elbow", UPPER_ARM, 100, from_name="shoulder", kind='arm')
c.add("hand", FOREARM, 100, kind='arm')                        # main au sol, avant du corps
c.add("knee", THIGH, 150, from_name="hip", kind='leg')          # cuisse descend vers l'arrière-bas
c.add("ankle", SHIN, 100, kind='leg')
c.add("toe", FOOT, 60, kind='leg')                              # pied au sol, arrière du corps
head_c, neck_parts = head_and_neck(c.points["shoulder"], 100)
svg = [svg_open(), ground(46)]
svg.append(c.render())
svg += neck_parts
svg.append(svg_close())
bounds_check("DownwardDog", list(c.points.values()) + [head_c])
add_figure("Chien tête en bas", "Quadrupède — root=hanche (point le plus haut), 2 chaînes vers le sol", "".join(svg))

# ============================================================
# 5. INVERSÉ — Sirsasana (poirier), root = tête (contact sol)
# ============================================================
c = Chain("head_base", (40, 45))   # sommet du crâne au sol
c.add("shoulder", NECK + HEAD_R, 270)   # cou remonte à la verticale depuis le sol
c.add("hip", TORSO, 270)
c.add("knee", THIGH, 270, kind='leg')
c.add("ankle", SHIN, 270, kind='leg')
c.add("toe", FOOT, 260, kind='leg')
svg = [svg_open(), ground(46)]
svg.append(c.render())
svg.append(head((40, 45 - HEAD_R)))  # tête = cercle centré au-dessus du point de contact
svg.append(svg_close())
bounds_check("Sirsasana", list(c.points.values()))
add_figure("Sirsasana", "Inversé — root=tête (contact sol), chaîne remonte à la verticale", "".join(svg))

# ============================================================
# Assemble HTML
# ============================================================
html = ['<!doctype html><html><head><meta charset="utf-8"><title>Posture rig — 5 orientations</title><style>',
        'body{margin:0;padding:24px;background:#fff;font-family:-apple-system,sans-serif;}',
        '.grid{display:flex;flex-wrap:wrap;gap:20px;} figure{margin:0;text-align:center;}',
        '.cell{width:220px;height:150px;background:#f7f7f7;border-radius:8px;display:flex;align-items:center;justify-content:center;}',
        'svg{width:88%;height:88%;} figcaption{margin-top:8px;font-size:12px;color:#444;max-width:220px;}',
        '</style></head><body><div class="grid">']
for title, caption, body in FIGURES:
    html.append(f'<figure><div class="cell">{body}</div><figcaption><b>{title}</b><br>{caption}</figcaption></figure>')
html.append('</div></body></html>')
with open("postures.html", "w") as f:
    f.write("\n".join(html))
print("OK — postures.html écrit")
