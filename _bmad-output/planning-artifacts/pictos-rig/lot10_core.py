import sys
sys.path.insert(0, ".")
from posture_rig import *
from rig import COL_EQUIP

FIGURES = []
def add_figure(title, caption, svg):
    FIGURES.append((title, caption, svg))

# ---- Core frontal (gainage planche) : question Sophie "quelle différence avec
# Phalakasana ?" — RÉPONSE : aucune, c'est mécaniquement LA MÊME position (planche
# complète, appui mains+pieds, ligne droite). Pas un bug à corriger en inventant une
# fausse variante — reprend donc exactement la construction Phalakasana (prouvée
# lisible), caption explicite pour que ce ne soit plus lu comme un doublon accidentel ----
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
bounds_check("CoreFrontal", list(c.points.values()) + [head_c])
add_figure("CoreFrontal", "Gainage planche — même position que Phalakasana (planche complète)", "".join(svg))

# ---- Core latéral (planche latérale) : appui 1 bras, corps de profil en ligne, autre bras levé ----
c = Chain("wrist", (26, 45))
c.add("elbow", FOREARM, 270, key=True, kind='arm')
c.add("shoulder", UPPER_ARM, 270, kind='arm')
c.add("hip", TORSO, 15, from_name="shoulder")
c.add_leg("", 15, 15, 60, from_name="hip")   # même angle cuisse/tibia = jambes tendues alignées, genou marqué quand même
c.add("elbowT", UPPER_ARM, 280, from_name="shoulder", kind='arm')  # bras du dessus tendu vers le haut
c.add("wristT", FOREARM, 280, kind='arm')
head_c, neck_parts = head_and_neck(c.points["shoulder"], 260)
svg = [svg_open(), ground(47)]
svg.append(c.render())
svg += neck_parts
svg.append(svg_close())
bounds_check("CoreLateral", list(c.points.values()) + [head_c])
add_figure("CoreLateral", "Planche latérale — appui 1 bras (geste-clé), autre bras levé", "".join(svg))

# ---- Forearm plank : comme planche mais appui sur l'avant-bras (coude au sol, pas le poignet) ----
c = Chain("elbow", (22, 40))
c.add("shoulder", UPPER_ARM, 270, kind='arm')
c.add("hip", TORSO, 8, from_name="shoulder")
c.add("knee", THIGH, 12, from_name="hip", kind='leg')
c.add("ankle", SHIN, 12, from_name="knee", kind='leg')
c.add("toe", FOOT, 55, kind='leg')
c.add("hand", FOREARM, 190, from_name="elbow", key=True, kind='arm')  # avant-bras à plat au sol devant le coude, longueur pleine
head_c, neck_parts = head_and_neck(c.points["shoulder"], 250)
svg = [svg_open(), ground(43)]
svg.append(ground_contact(c.points["elbow"], c.points["toe"], y=43))
svg.append(c.render())
svg += neck_parts
svg.append(svg_close())
bounds_check("ForearmPlank", list(c.points.values()) + [head_c])
add_figure("ForearmPlank", "Planche avant-bras — appui coude (geste-clé)", "".join(svg))

# ---- Bird-dog : quadrupède, bras ET jambe opposés tendus (geste-clé), autres appuis au sol ----
c = Chain("hip", (44, 20))
c.add("shoulder", TORSO, 15, from_name="hip")
c.add("elbow", UPPER_ARM, 100, from_name="shoulder", kind='arm')       # bras d'appui au sol
c.add("hand", FOREARM, 100, kind='arm')
c.add("knee", THIGH, 150, from_name="hip", kind='leg')                  # jambe d'appui au sol
c.add("ankle", SHIN, 100, from_name="knee", kind='leg')
c.add("toe", FOOT, 60, kind='leg')
c.add("elbowE", UPPER_ARM, 350, from_name="shoulder", key=True, kind='arm')   # bras tendu vers l'avant (geste-clé)
c.add("wristE", FOREARM, 350, key=True, kind='arm')
c.add("kneeE", THIGH, 180, from_name="hip", key=True, kind='leg')             # jambe tendue vers l'arrière (geste-clé)
c.add("ankleE", SHIN, 180, key=True, kind='leg')
c.add("toeE", FOOT, 190, key=True, kind='leg')
head_c, neck_parts = head_and_neck(c.points["shoulder"], 350)
svg = [svg_open(), ground(46)]
# 2e retour Sophie "trop d'articulation, les articulations sur tous les membres" —
# masquer les ronds ne suffisait pas. Ajout : les 2 appuis STATIQUES (bras+jambe au
# sol) se dessinent maintenant en trait FIN (dim_joints) en plus d'être sans rond —
# ils reculent visuellement, seul le geste-clé (bras+jambe tendus, trait normal +
# ronds) reste au premier plan. Couleur inchangée (règle bras/jambe respectée).
svg.append(c.render(
    skip_joints={"elbow", "hand", "knee", "ankle", "toe"},
    dim_joints={"elbow", "hand", "knee", "ankle", "toe"},
))
svg += neck_parts
svg.append(svg_close())
bounds_check("BirdDog", list(c.points.values()) + [head_c])
add_figure("BirdDog", "Bras+jambe opposés tendus (geste-clé), appuis au sol", "".join(svg))

# ---- Foam rolling : allongé sur le dos, rouleau sous les mollets/le dos (représenté par un cylindre) ----
c = Chain("hip", (46, 32))
c.add("shoulder", TORSO, 180)
c.add("knee", THIGH, 5, from_name="hip", key=True, kind='leg')   # jambes sur le rouleau (geste-clé)
c.add("ankle", SHIN, 5, kind='leg')
c.add("toe", FOOT, 350, kind='leg')
head_c, neck_parts = head_and_neck(c.points["shoulder"], 180)
roller_x0, roller_x1 = c.points["hip"][0] - 3, c.points["knee"][0] + 3
roller_y = c.points["hip"][1] + 3
svg = [svg_open(), ground(38)]
svg.append(f'<rect x="{roller_x0:.1f}" y="{roller_y-3:.1f}" width="{roller_x1-roller_x0:.1f}" height="6" rx="3" fill="none" stroke="{COL_EQUIP}" stroke-width="1.6"/>')
svg.append(c.render())
svg += neck_parts
svg.append(svg_close())
bounds_check("FoamRolling", list(c.points.values()) + [head_c])
add_figure("FoamRolling", "Allongé, rouleau sous les jambes (geste-clé = position des jambes)", "".join(svg))

# ---- Mobility (étirement quadriceps debout) : équilibre 1 jambe, autre pliée derrière, main tient le pied ----
c = Chain("ankle", (40, 43))
c.add("knee", SHIN, 270, kind='leg')
c.add("hip", THIGH, 270, kind='leg')
c.add("shoulder", TORSO, 270)
c.add("elbow", UPPER_ARM, 110, key=True, kind='arm')
c.add("wrist", FOREARM, 100, key=True, kind='arm')
c.add_leg("B", 100, 260, 280, from_name="hip", key=True)
head_c, neck_parts = head_and_neck(c.points["shoulder"], 270)
toe_f = pt(c.points["ankle"], FOOT, 15)
svg = [svg_open(), ground(43)]
svg.append(line(c.points["ankle"], toe_f))
svg.append(joint(c.points["ankle"]))
svg.append(c.render(mark_root_joint=False))
svg.append(joint(c.points["ankle"]))
svg += neck_parts
bounds_check("Mobility", list(c.points.values()) + [head_c, toe_f])
svg.append(svg_close())
add_figure("Mobility", "Étirement quadriceps — main tient le pied (geste-clé)", "".join(svg))

# ============================================================
html = ['<!doctype html><html><head><meta charset="utf-8"><title>Lot core/mobility</title><style>',
        'body{margin:0;padding:24px;background:#fff;font-family:-apple-system,sans-serif;}',
        '.grid{display:flex;flex-wrap:wrap;gap:20px;} figure{margin:0;text-align:center;}',
        '.cell{width:220px;height:150px;background:#f7f7f7;border-radius:8px;display:flex;align-items:center;justify-content:center;}',
        'svg{width:88%;height:88%;} figcaption{margin-top:8px;font-size:12px;color:#444;max-width:220px;}',
        '</style></head><body><div class="grid">']
for title, caption, body in FIGURES:
    html.append(f'<figure><div class="cell">{body}</div><figcaption><b>{title}</b><br>{caption}</figcaption></figure>')
html.append('</div></body></html>')
with open("lot10.html", "w") as f:
    f.write("\n".join(html))
print("OK — lot10.html écrit")
