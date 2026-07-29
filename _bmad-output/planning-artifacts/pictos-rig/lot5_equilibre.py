import sys
sys.path.insert(0, ".")
from posture_rig import *

FIGURES = []
def add_figure(title, caption, svg):
    FIGURES.append((title, caption, svg))

# ---- Sirsasana (repris tel quel) ----
c = Chain("head_base", (40, 45))
c.add("shoulder", NECK + HEAD_R, 270)
c.add("hip", TORSO, 270)
c.add("knee", THIGH, 270, kind='leg')
c.add("ankle", SHIN, 270, kind='leg')
c.add("toe", FOOT, 260, kind='leg')
svg = [svg_open(), ground(46)]
svg.append(c.render())
svg.append(head((40, 45 - HEAD_R)))
svg.append(svg_close())
bounds_check("Sirsasana", list(c.points.values()))
add_figure("Sirsasana", "Poirier — root=tête (contact sol), chaîne remonte", "".join(svg))

# ---- Warrior3 : équilibre 1 jambe, tronc+jambe arrière à l'horizontale (geste-clé),
# bras devant. BUG trouvé (retour Sophie "il est en l'air ?") : la cheville d'appui
# était root à y=26 alors que le sol est à y=43 — il flottait à 17 unités du sol,
# aucun pied posé nulle part. Racine déplacée sur le sol, orteil+marque de contact
# ajoutés pour que l'équilibre 1 jambe se lise sans ambiguïté ----
c = Chain("ankle", (30, 43))
c.add("knee", SHIN, 270, kind='leg')          # jambe d'appui quasi verticale
c.add("hip", THIGH, 280, from_name="knee", kind='leg')
c.add("shoulder", TORSO, 0, from_name="hip", key=True)   # tronc à l'horizontale (geste-clé)
c.add("elbow", UPPER_ARM, 350, from_name="shoulder", kind='arm')
c.add("wrist", FOREARM, 350, kind='arm')
c.add("kneeB", THIGH, 350, from_name="hip", key=True, kind='leg')    # jambe arrière tendue à l'horizontale (geste-clé)
c.add("ankleB", SHIN, 350, from_name="kneeB", kind='leg')
c.add("toeB", FOOT, 20, kind='leg')
toe_f = pt(c.points["ankle"], FOOT, 15)
head_c, neck_parts = head_and_neck(c.points["shoulder"], 0)
svg = [svg_open(), ground(43)]
svg.append(ground_contact(c.points["ankle"], toe_f, y=43))
svg.append(line(c.points["ankle"], toe_f))
svg.append(joint(c.points["ankle"]))
svg.append(c.render(mark_root_joint=False))
svg.append(joint(c.points["ankle"]))
svg += neck_parts
svg.append(svg_close())
bounds_check("Warrior3", list(c.points.values()) + [head_c, toe_f])
add_figure("Warrior3", "Guerrier 3 — pied d'appui bien au sol (trait plein), tronc+jambe à l'horizontale (geste-clé)", "".join(svg))

# ---- Ardha Chandrasana (demi-lune) : appui 1 main au sol, jambe d'appui VERTICALE
# qui touche vraiment le sol (bug retour Sophie — avant, angles 20°/350° faisaient
# flotter les 2 jambes à ~20 unités au-dessus du sol, aucune ne touchait), jambe
# arrière levée à l'horizontale (geste-clé), autre bras vers le haut ----
c = Chain("hand", (24, 40))
c.add("elbow", FOREARM, 280, key=True, kind='arm')
c.add("shoulder", UPPER_ARM, 280, kind='arm')
c.add("hip", TORSO, 340, from_name="shoulder")
c.add("knee", THIGH, 90, from_name="hip", kind='leg')              # jambe d'appui verticale, touche le sol
c.add("ankle", SHIN, 90, from_name="knee", kind='leg')
c.add("toe", FOOT, 15, kind='leg')
c.add("kneeB", THIGH, 350, from_name="hip", key=True, kind='leg')  # jambe levée à l'horizontale, arrière (geste-clé)
c.add("ankleB", SHIN, 350, from_name="kneeB", kind='leg')
c.add("toeB", FOOT, 340, kind='leg')
c.add("elbowT", UPPER_ARM, 280, from_name="shoulder", kind='arm')  # autre bras tendu vers le haut
c.add("wristT", FOREARM, 280, kind='arm')
head_c, neck_parts = head_and_neck(c.points["shoulder"], 320)
svg = [svg_open(), ground(43)]
svg.append(c.render())
svg += neck_parts
svg.append(svg_close())
bounds_check("ArdhaChandrasana", list(c.points.values()) + [head_c])
add_figure("ArdhaChandrasana", "Demi-lune — main au sol, jambe levée horizontale (geste-clé)", "".join(svg))

# ---- Bakasana (corbeau) : mains au sol, corps compact, genoux sur l'arrière des bras, pieds levés ----
c = Chain("hand", (30, 38))
c.add("elbow", FOREARM, 280, key=True, kind='arm')
c.add("shoulder", UPPER_ARM, 260, from_name="elbow", kind='arm')
c.add("hip", TORSO, 320, from_name="shoulder")
c.add_leg("", 260, 200, 180, from_name="hip", key=True)   # genoux repliés PAR L'ANGLE, longueurs pleines
head_c, neck_parts = head_and_neck(c.points["shoulder"], 300)
svg = [svg_open(), ground(43)]
svg.append(c.render())
svg += neck_parts
svg.append(svg_close())
bounds_check("Bakasana", list(c.points.values()) + [head_c])
add_figure("Bakasana", "Corbeau — équilibre bras, genoux repliés dessus (geste-clé)", "".join(svg))

# ---- Sarvangasana (chandelle) : root=épaule (contact sol), jambes+hanche tendues
# vers le haut. 2e retour Sophie "les coudes sont en l'air sur le schéma" — l'angle
# précédent (270°, tout droit vers le haut) plaçait le coude à y=36 alors que le sol
# est à y=46 : le trait de contact était peint au bon endroit mais le COUDE, lui,
# flottait à 10 unités au-dessus. Angle corrigé pour que le coude touche VRAIMENT
# le sol (y≈46.7), avant-bras qui remonte ensuite contre le bas du dos ----
c = Chain("shoulder_base", (40, 44))
c.add("hip", TORSO, 270)
c.add("knee", THIGH, 270, kind='leg')
c.add("ankle", SHIN, 270, kind='leg')
c.add("toe", FOOT, 260, kind='leg')
c.add_arm("", 20, 275, from_name="shoulder_base", key=True)  # coude touche vraiment le sol, main remonte vers le dos
svg = [svg_open(), ground(46)]
svg.append(ground_contact(c.points["shoulder_base"], c.points["elbow"], y=46))  # épaule+coude au sol (appui réel)
svg.append(c.render())
svg.append(head((40, 44 + HEAD_R * 0.3)))  # tête posée au sol, juste sous le point d'appui épaule
svg.append(svg_close())
bounds_check("Sarvangasana", list(c.points.values()))
add_figure("Sarvangasana", "Chandelle — coude au sol, main soutient le bas du dos (geste-clé)", "".join(svg))

# ============================================================
html = ['<!doctype html><html><head><meta charset="utf-8"><title>Lot 5 — équilibre/inversé</title><style>',
        'body{margin:0;padding:24px;background:#fff;font-family:-apple-system,sans-serif;}',
        '.grid{display:flex;flex-wrap:wrap;gap:20px;} figure{margin:0;text-align:center;}',
        '.cell{width:220px;height:150px;background:#f7f7f7;border-radius:8px;display:flex;align-items:center;justify-content:center;}',
        'svg{width:88%;height:88%;} figcaption{margin-top:8px;font-size:12px;color:#444;max-width:220px;}',
        '</style></head><body><div class="grid">']
for title, caption, body in FIGURES:
    html.append(f'<figure><div class="cell">{body}</div><figcaption><b>{title}</b><br>{caption}</figcaption></figure>')
html.append('</div></body></html>')
with open("lot5.html", "w") as f:
    f.write("\n".join(html))
print("OK — lot5.html écrit")
