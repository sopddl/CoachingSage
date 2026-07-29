import sys
sys.path.insert(0, ".")
from posture_rig import *

FIGURES = []
def add_figure(title, caption, svg):
    FIGURES.append((title, caption, svg))

# ---- Chien tête en bas (repris tel quel) ----
c = Chain("hip", (40, 15))
c.add("shoulder", TORSO, 15, from_name="hip")
c.add("elbow", UPPER_ARM, 100, kind='arm')
c.add("hand", FOREARM, 100, kind='arm')
c.add("knee", THIGH, 150, from_name="hip", kind='leg')
c.add("ankle", SHIN, 100, kind='leg')
c.add("toe", FOOT, 60, kind='leg')
head_c, neck_parts = head_and_neck(c.points["shoulder"], 100)
svg = [svg_open(), ground(46)]
svg.append(c.render())
svg += neck_parts
svg.append(svg_close())
bounds_check("DownwardDog", list(c.points.values()) + [head_c])
add_figure("Chien tête en bas", "Quadrupède — root=hanche, 2 chaînes vers le sol", "".join(svg))

# ---- Cat-cow (table neutre) : main ET genou touchent VRAIMENT le même sol (angle
# du bras corrigé — avant, la main flottait 6 unités au-dessus du genou). Tibia+pied
# ajoutés à plat derrière le genou (retour Sophie : avant, la jambe s'arrêtait au
# genou, aucune indication de où allait le pied) ----
c = Chain("hip", (46, 20))
c.add("shoulder", TORSO, 5)               # tronc quasi horizontal (dos plat, table neutre)
c.add("elbow", UPPER_ARM, 135, from_name="shoulder", kind='arm')
c.add("hand", FOREARM, 135, kind='arm')
c.add("knee", THIGH, 95, from_name="hip", kind='leg')   # genou au sol
c.add("ankle", SHIN, 180, from_name="knee", kind='leg')  # tibia à plat, tendu vers l'arrière
c.add("toe", FOOT, 185, kind='leg')                       # pied à plat au sol derrière le genou
head_c, neck_parts = head_and_neck(c.points["shoulder"], 60)
svg = [svg_open(), ground(32)]
svg.append(ground_contact(c.points["hand"], c.points["knee"], y=32))
# 2e retour Sophie "les pieds sont où ? allongé ou remontés ?" — le tibia+pied
# touchaient déjà le sol après la 1ère correction mais rien ne le MONTRAIT
# explicitement (contrairement à main/genou qui ont leur marque). Ajoutée ici aussi.
svg.append(ground_contact(c.points["ankle"], c.points["toe"], y=32))
svg.append(c.render())
svg += neck_parts
svg.append(svg_close())
bounds_check("CatCow", list(c.points.values()) + [head_c])
add_figure("CatCow", "Table neutre — main et genou au même sol", "".join(svg))

# ---- Phalakasana (planche) : ligne DROITE poignet->orteils (même angle sur tout le
# corps) pour que main ET pied touchent vraiment le même sol ----
c = Chain("wrist", (20, 40))
c.add("elbow", FOREARM, 270, kind='arm')
c.add("shoulder", UPPER_ARM, 270, kind='arm')
c.add("hip", TORSO, 24, from_name="shoulder")
c.add_leg("", 24, 24, 55, from_name="hip")
head_c, neck_parts = head_and_neck(c.points["shoulder"], 250)
svg = [svg_open(), ground(40)]
svg.append(ground_contact(c.points["wrist"], c.points["toe"], y=40))
svg.append(c.render())
svg += neck_parts
svg.append(svg_close())
bounds_check("Phalakasana", list(c.points.values()) + [head_c])
add_figure("Phalakasana", "Planche — main et pied au même sol, ligne droite", "".join(svg))

# ---- Forward Fold (Uttanasana) : le tronc plie VERS L'AVANT (pas tout droit vers le
# bas — avant, ça retraçait la jambe et faisait un tas illisible au même endroit) ----
c = Chain("ankle", (40, 43))
c.add("knee", SHIN, 270, kind='leg')
c.add("hip", THIGH, 270, kind='leg')
c.add("shoulder", TORSO, 70, from_name="hip")     # tronc plié VERS L'AVANT, pas à la verticale
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
bounds_check("ForwardFold", list(c.points.values()) + [head_c, toe_f])
svg.append(svg_close())
add_figure("ForwardFold", "Flexion avant debout — tronc plié vers l'avant (pas vers le bas)", "".join(svg))

# ---- Dolphin : coude qui descend vers le sol (geste-clé) + avant-bras à plat le
# long du sol ; jambes réglées pour que les pieds touchent le sol SANS PASSER EN
# DESSOUS (bug retour Sophie — l'angle du pied à 55° faisait plonger l'orteil à
# y=36.8 alors que le sol était à y=31, les pieds semblaient s'enfoncer sous terre) ----
c = Chain("hip", (40, 18))
c.add("shoulder", TORSO, 15, from_name="hip")
c.add("elbow", UPPER_ARM, 90, kind='arm')       # coude au sol (geste-clé : appui avant-bras)
c.add("hand", FOREARM, 170, kind='arm')          # avant-bras à PLAT le long du sol
c.add_leg("", 160, 85, 345, from_name="hip")     # pied à plat, ne passe plus sous le sol
head_c, neck_parts = head_and_neck(c.points["shoulder"], 90)
# 2e retour Sophie "les pieds sous le sol c'est bizarre" — la cheville touchait
# y=32.7 alors que le sol était dessiné à y=32 (0.7 unité de trop, visible à cette
# échelle). Sol descendu à 33 pour contenir vraiment cheville+orteil+main au-dessus.
svg = [svg_open(), ground(33)]
svg.append(ground_contact(c.points["ankle"], c.points["toe"], y=33))   # pieds au sol (retour Sophie)
svg.append(ground_contact(c.points["elbow"], c.points["hand"], y=32))  # avant-bras au sol (geste-clé)
svg.append(c.render())
svg += neck_parts
svg.append(svg_close())
bounds_check("DolphinPose", list(c.points.values()) + [head_c])
add_figure("DolphinPose", "Dauphin — avant-bras ET pieds au sol (traits pleins = contact)", "".join(svg))

# ============================================================
html = ['<!doctype html><html><head><meta charset="utf-8"><title>Lot 4 — quadrupède/planche</title><style>',
        'body{margin:0;padding:24px;background:#fff;font-family:-apple-system,sans-serif;}',
        '.grid{display:flex;flex-wrap:wrap;gap:20px;} figure{margin:0;text-align:center;}',
        '.cell{width:220px;height:150px;background:#f7f7f7;border-radius:8px;display:flex;align-items:center;justify-content:center;}',
        'svg{width:88%;height:88%;} figcaption{margin-top:8px;font-size:12px;color:#444;max-width:220px;}',
        '</style></head><body><div class="grid">']
for title, caption, body in FIGURES:
    html.append(f'<figure><div class="cell">{body}</div><figcaption><b>{title}</b><br>{caption}</figcaption></figure>')
html.append('</div></body></html>')
with open("lot4.html", "w") as f:
    f.write("\n".join(html))
print("OK — lot4.html écrit")
