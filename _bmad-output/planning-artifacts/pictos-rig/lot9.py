import sys
sys.path.insert(0, ".")
from posture_rig import *

FIGURES = []
def add_figure(title, caption, svg):
    FIGURES.append((title, caption, svg))

# ---- Jану Sirsasana : assis, 1 jambe tendue devant, autre pliée pied à la cuisse,
# tronc plié sur la jambe tendue. Bras ajoutés vers le pied (retour Sophie "les bras
# la tête au genou" — absents avant, comme Paschimottanasana avant sa correction) ----
c = Chain("hip", (52, 38))
c.add("knee", THIGH, 5, key=False, kind='leg')
c.add("ankle", SHIN, 5, kind='leg')
c.add("toe", FOOT, 350, kind='leg')
c.add_leg("B", 150, 320, 30, from_name="hip")
c.add("shoulder", TORSO, 320, from_name="hip", key=True)
c.add_arm("", 25, 20, from_name="shoulder")   # bras tendus vers le pied (geste-clé)
head_c, neck_parts = head_and_neck(c.points["shoulder"], 320)
svg = [svg_open(), ground(38)]
svg.append(c.render())
svg += neck_parts
svg.append(svg_close())
bounds_check("JanuSirsasana", list(c.points.values()) + [head_c])
add_figure("JanuSirsasana", "Tête au genou — tronc plié sur la jambe tendue (geste-clé)", "".join(svg))

# ---- Marichyasana A : assis, 1 jambe tendue, autre genou plié au sol, torsion/
# enroulement. 2 bugs trouvés : "footB" (le tibia du genou plié) n'avait pas
# kind='leg' (rendu noir au lieu de vert) et le bras n'avait qu'UN segment (coude
# seul, pas d'avant-bras) — refait pour vraiment enrouler jusqu'au genou (geste-clé) ----
c = Chain("hip", (52, 38))
c.add("knee", THIGH, 5, kind='leg')
c.add("ankle", SHIN, 5, kind='leg')
c.add("toe", FOOT, 350, kind='leg')
c.add("kneeB", THIGH, 260, from_name="hip", key=True, kind='leg')
c.add("footB", SHIN, 350, from_name="kneeB", kind='leg')
c.add("shoulder", TORSO, 300, from_name="hip")
c.add_arm("", 120, 235, from_name="shoulder", key=True)   # bras enroulé jusqu'au genou plié (geste-clé)
head_c, neck_parts = head_and_neck(c.points["shoulder"], 300)
svg = [svg_open(), ground(38)]
svg.append(c.render())
svg += neck_parts
svg.append(svg_close())
bounds_check("MarichyasanaA", list(c.points.values()) + [head_c])
add_figure("MarichyasanaA", "Genou plié + bras enroulé autour (geste-clé)", "".join(svg))

# ---- Parsvakonasana : fente avant genou plié, main au sol près du pied, autre bras tendu en ligne avec la jambe arrière ----
c = Chain("ankle", (34, 43))
c.add("knee", SHIN, 260, kind='leg')
c.add("hip", THIGH, 240, kind='leg')
c.add("shoulder", TORSO, 200, key=True)
c.add("elbow", UPPER_ARM, 100, from_name="shoulder", kind='arm')
c.add("wrist", FOREARM, 100, kind='arm')
c.add("elbowT", UPPER_ARM, 340, from_name="shoulder", key=True, kind='arm')
c.add("wristT", FOREARM, 340, key=True, kind='arm')
c.add("kneeB", THIGH, 15, from_name="hip", kind='leg')
c.add("ankleB", SHIN, 15, kind='leg')
c.add("toeB", FOOT, 15, kind='leg')
head_c, neck_parts = head_and_neck(c.points["shoulder"], 250)
toe_f = pt(c.points["ankle"], FOOT, 15)
svg = [svg_open(), ground(45)]
svg.append(line(c.points["ankle"], toe_f))
svg.append(joint(c.points["ankle"]))
svg.append(c.render(mark_root_joint=False))
svg.append(joint(c.points["ankle"]))
svg += neck_parts
bounds_check("Parsvakonasana", list(c.points.values()) + [head_c, toe_f])
svg.append(svg_close())
add_figure("Parsvakonasana", "Fente + bras en ligne diagonale (geste-clé)", "".join(svg))

# ---- Parsvottanasana : fente jambes tendues, tronc plié vers l'avant sur la jambe
# avant. BUG (même défaut que ForwardFold/Padangusthasana) : torse à 100° quasi
# opposé à la jambe à 270° = retrace la jambe, tas illisible. Angle en avant ----
c = Chain("ankle", (34, 43))
c.add("knee", SHIN, 270, kind='leg')
c.add("hip", THIGH, 270, kind='leg')
c.add("shoulder", TORSO, 75, key=True)
c.add("elbow", UPPER_ARM, 80, from_name="shoulder", kind='arm')
c.add("wrist", FOREARM, 80, kind='arm')
c.add("kneeB", THIGH, 15, from_name="hip", kind='leg')
c.add("ankleB", SHIN, 15, kind='leg')
c.add("toeB", FOOT, 15, kind='leg')
head_c, neck_parts = head_and_neck(c.points["shoulder"], 75)
toe_f = pt(c.points["ankle"], FOOT, 15)
svg = [svg_open(), ground(45)]
svg.append(line(c.points["ankle"], toe_f))
svg.append(joint(c.points["ankle"]))
svg.append(c.render(mark_root_joint=False))
svg.append(joint(c.points["ankle"]))
svg += neck_parts
bounds_check("Parsvottanasana", list(c.points.values()) + [head_c, toe_f])
svg.append(svg_close())
add_figure("Parsvottanasana", "Jambes tendues, tronc plié devant (geste-clé)", "".join(svg))

# ---- Kurmasana (tortue) : assis, jambes écartées, tronc plié TRÈS bas entre les
# jambes, bras sous les genoux. Retour Sophie (via le bug identique de Triangle) :
# le profil ne montrait qu'UNE jambe — refait en vue de face, 2 jambes écartées ----
c = Chain("hip", (40, 10))
c.add_leg("R", 20, 20, 350, from_name="hip")
c.add_leg("L", 160, 160, 190, from_name="hip")
c.add("shoulder", TORSO, 90, from_name="hip", key=True)   # tronc plié TRÈS bas entre les jambes (geste-clé)
c.add("elbow", UPPER_ARM, 60, from_name="shoulder", kind='arm')
c.add("wrist", FOREARM, 340, kind='arm')
head_c, neck_parts = head_and_neck(c.points["shoulder"], 90)
svg = [svg_open(), ground(18)]
svg.append(c.render())
svg += neck_parts
svg.append(svg_close())
bounds_check("Kurmasana", list(c.points.values()) + [head_c])
add_figure("Kurmasana", "Tortue — tronc très plié entre les jambes (geste-clé)", "".join(svg))

# ---- Bhujapidasana : équilibre bras, jambes enroulées autour des bras (pas juste posées dessus) ----
c = Chain("hand", (30, 38))
c.add("elbow", FOREARM, 280, key=True, kind='arm')
c.add("shoulder", UPPER_ARM, 260, from_name="elbow", kind='arm')
c.add("hip", TORSO, 320, from_name="shoulder")
c.add_leg("", 240, 170, 160, from_name="hip", key=True)
head_c, neck_parts = head_and_neck(c.points["shoulder"], 300)
svg = [svg_open(), ground(43)]
svg.append(c.render())
svg += neck_parts
svg.append(svg_close())
bounds_check("Bhujapidasana", list(c.points.values()) + [head_c])
add_figure("Bhujapidasana", "Jambes enroulées autour des bras (geste-clé)", "".join(svg))

# ---- Garbha Pindasana (embryon) : assis, très replié, bras enfilés sous les genoux vers la tête ----
c = Chain("hip", (40, 34))
c.add_leg("R", 30, 220, 250, from_name="hip")
c.add_leg("L", 150, 320, 290, from_name="hip")
c.add("shoulder", TORSO, 270, from_name="hip")
c.add_arm("", 30, 300, from_name="shoulder", key=True)
head_c, neck_parts = head_and_neck(c.points["shoulder"], 270)
svg = [svg_open(), ground(43)]
svg.append(c.render())
svg += neck_parts
svg.append(svg_close())
bounds_check("GarbhaPindasana", list(c.points.values()) + [head_c])
add_figure("GarbhaPindasana", "Embryon — très replié, bras enfilés (geste-clé)", "".join(svg))

# ---- Utthita Hasta Padangusthasana : équilibre 1 jambe, autre jambe tendue devant tenue par la main ----
c = Chain("ankle", (40, 43))
c.add("knee", SHIN, 270, kind='leg')
c.add("hip", THIGH, 270, kind='leg')
c.add("shoulder", TORSO, 270)
c.add("elbow", UPPER_ARM, 30, key=True, kind='arm')
c.add("wrist", FOREARM, 350, key=True, kind='arm')
c.add("kneeB", THIGH, 300, from_name="hip", key=True, kind='leg')
c.add("ankleB", SHIN, 350, from_name="kneeB", key=True, kind='leg')
head_c, neck_parts = head_and_neck(c.points["shoulder"], 270)
toe_f = pt(c.points["ankle"], FOOT, 15)
svg = [svg_open(), ground(43)]
svg.append(line(c.points["ankle"], toe_f))
svg.append(joint(c.points["ankle"]))
svg.append(c.render(mark_root_joint=False))
svg.append(joint(c.points["ankle"]))
svg += neck_parts
bounds_check("UtthitaHastaPadangusthasana", list(c.points.values()) + [head_c, toe_f])
svg.append(svg_close())
add_figure("UtthitaHastaPadangusthasana", "Jambe tendue tenue par la main (geste-clé)", "".join(svg))

# ---- Ardha Baddha Padmottanasana : équilibre 1 jambe, autre en demi-lotus derrière,
# tronc plié devant. Même bug retrace-la-jambe (torse 90° quasi opposé à jambe 270°) ----
c = Chain("ankle", (40, 43))
c.add("knee", SHIN, 270, kind='leg')
c.add("hip", THIGH, 270, kind='leg')
c.add("shoulder", TORSO, 75, key=True)
c.add("elbow", UPPER_ARM, 80, from_name="shoulder", kind='arm')
c.add("wrist", FOREARM, 80, kind='arm')
c.add_leg("B", 300, 230, 190, from_name="hip", key=True)
head_c, neck_parts = head_and_neck(c.points["shoulder"], 75)
toe_f = pt(c.points["ankle"], FOOT, 15)
svg = [svg_open(), ground(43)]
svg.append(line(c.points["ankle"], toe_f))
svg.append(joint(c.points["ankle"]))
svg.append(c.render(mark_root_joint=False))
svg.append(joint(c.points["ankle"]))
svg += neck_parts
bounds_check("ArdhaBaddhaPadmottanasana", list(c.points.values()) + [head_c, toe_f])
svg.append(svg_close())
add_figure("ArdhaBaddhaPadmottanasana", "Demi-lotus derrière, tronc plié devant (geste-clé)", "".join(svg))

# ---- Ardha Matsyendrasana (torsion assise) : jambe croisée par-dessus, bras enroule le genou ----
c = Chain("hip", (40, 34))
c.add("shoulder", TORSO, 270)
c.add_leg("R", 30, 220, 250, from_name="hip")
c.add_leg("L", 150, 40, 200, from_name="hip", key=True)
c.add_arm("", 30, 340, from_name="shoulder", key=True)
head_c, neck_parts = head_and_neck(c.points["shoulder"], 250)
svg = [svg_open(), ground(43)]
svg.append(c.render())
svg += neck_parts
svg.append(svg_close())
bounds_check("ArdhaMatsyendrasana", list(c.points.values()) + [head_c])
add_figure("ArdhaMatsyendrasana", "Torsion assise — jambe croisée + bras enroulé (geste-clé)", "".join(svg))

# ---- Padangusthasana : flexion avant debout, mains tiennent les gros orteils.
# BUG trouvé (même défaut que ForwardFold avant sa correction) : torse à 95° est
# quasi opposé (180°) à la jambe à 270° — le tronc RETRACE la jambe exactement,
# tout se superpose en un tas illisible. Angle penché vers l'avant comme ForwardFold ----
c = Chain("ankle", (40, 43))
c.add("knee", SHIN, 270, kind='leg')
c.add("hip", THIGH, 270, kind='leg')
c.add("shoulder", TORSO, 70, key=True)
c.add("elbow", UPPER_ARM, 80, from_name="shoulder", kind='arm')
c.add("wrist", FOREARM, 80, key=True, kind='arm')
head_c, neck_parts = head_and_neck(c.points["shoulder"], 95)
toe_f = pt(c.points["ankle"], FOOT, 15)
svg = [svg_open(), ground(43)]
svg.append(line(c.points["ankle"], toe_f))
svg.append(joint(c.points["ankle"]))
svg.append(c.render(mark_root_joint=False))
svg.append(joint(c.points["ankle"]))
svg += neck_parts
bounds_check("Padangusthasana", list(c.points.values()) + [head_c, toe_f])
svg.append(svg_close())
add_figure("Padangusthasana", "Mains tiennent les gros orteils (geste-clé)", "".join(svg))

# ---- Cat-cow sur avant-bras : variante table neutre, appui coude/avant-bras au sol.
# Avant-bras à plat + tibia/pied ajoutés (même bug que CatCow standard — la jambe et
# le bras s'arrêtaient à mi-chemin, aucune indication de où allaient main et pied) ----
c = Chain("hip", (46, 20))
c.add("shoulder", TORSO, 5)
c.add("elbow", UPPER_ARM, 100, from_name="shoulder", key=True, kind='arm')
c.add("hand", FOREARM, 175, kind='arm')                   # avant-bras à plat au sol devant le coude
c.add("knee", THIGH, 95, from_name="hip", kind='leg')
c.add("ankle", SHIN, 180, from_name="knee", kind='leg')    # tibia à plat, tendu vers l'arrière
c.add("toe", FOOT, 185, kind='leg')                         # pied à plat au sol derrière le genou
head_c, neck_parts = head_and_neck(c.points["shoulder"], 60)
svg = [svg_open(), ground(32)]
svg.append(ground_contact(c.points["hand"], c.points["knee"], y=32))
svg.append(c.render())
svg += neck_parts
svg.append(svg_close())
bounds_check("CatCowForearms", list(c.points.values()) + [head_c])
add_figure("CatCowForearms", "Table sur avant-bras — coude au sol (trait plein = contact, geste-clé)", "".join(svg))

# ============================================================
html = ['<!doctype html><html><head><meta charset="utf-8"><title>Lot 9</title><style>',
        'body{margin:0;padding:24px;background:#fff;font-family:-apple-system,sans-serif;}',
        '.grid{display:flex;flex-wrap:wrap;gap:20px;} figure{margin:0;text-align:center;}',
        '.cell{width:220px;height:150px;background:#f7f7f7;border-radius:8px;display:flex;align-items:center;justify-content:center;}',
        'svg{width:88%;height:88%;} figcaption{margin-top:8px;font-size:12px;color:#444;max-width:220px;}',
        '</style></head><body><div class="grid">']
for title, caption, body in FIGURES:
    html.append(f'<figure><div class="cell">{body}</div><figcaption><b>{title}</b><br>{caption}</figcaption></figure>')
html.append('</div></body></html>')
with open("lot9.html", "w") as f:
    f.write("\n".join(html))
print("OK — lot9.html écrit")
