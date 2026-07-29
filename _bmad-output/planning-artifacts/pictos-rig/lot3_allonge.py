import sys, math
sys.path.insert(0, ".")
from posture_rig import *

FIGURES = []
def add_figure(title, caption, svg):
    FIGURES.append((title, caption, svg))

# ---- Savasana (repris tel quel) ----
GY = 30
c = Chain("hip", (46, GY))
c.add("shoulder", TORSO, 180)
c.add("knee", THIGH, 5, from_name="hip", kind='leg')
c.add("ankle", SHIN, 5, kind='leg')
c.add("toe", FOOT, 350, kind='leg')
c.add_arm("", 120, 200, from_name="shoulder")
head_c, neck_parts = head_and_neck(c.points["shoulder"], 180)
svg = [svg_open(), ground(GY + 3)]
svg.append(c.render())
svg += neck_parts
svg.append(svg_close())
bounds_check("Savasana", list(c.points.values()) + [head_c])
add_figure("Savasana", "Allongé relâché — tronc+jambe à l'horizontale", "".join(svg))

# ---- Setu Bandha (pont) : épaule au sol (root), hanche levée, genou plié, pied au
# sol. BUG trouvé (retour Sophie "les pieds au sol ? les bras ?") : la cheville
# atterrissait à y=16 alors que le sol est à y=43 — le pied flottait à 27 unités
# au-dessus du sol, et les bras n'existaient pas du tout. Angles refaits pour que
# la cheville touche vraiment le sol, bras ajoutés relâchés à côté des épaules ----
c = Chain("shoulder", (28, 40))
c.add("hip", TORSO, 300, key=True)          # tronc remonte en oblique (hanche levée = geste-clé)
c.add("knee", THIGH, 30, from_name="hip", kind='leg')    # cuisse redescend vers le genou plié
c.add("ankle", SHIN, 60, from_name="knee", kind='leg')   # tibia vers le pied, qui touche vraiment le sol
c.add("toe", FOOT, 30, kind='leg')
c.add_arm("", 100, 200, from_name="shoulder")  # bras relâchés à côté des épaules, longueur pleine
head_c, neck_parts = head_and_neck(c.points["shoulder"], 165)  # tête posée au sol, cou à l'horizontale
svg = [svg_open(), ground(43)]
svg.append(ground_contact(c.points["ankle"], c.points["toe"], y=43))
svg.append(c.render())
svg += neck_parts
svg.append(svg_close())
bounds_check("SetuBandha", list(c.points.values()) + [head_c])
add_figure("SetuBandha", "Pont — hanche levée (geste-clé), pied au sol (trait plein)", "".join(svg))

# ---- Matsyasana (poisson) : sur le dos, poitrine levée, tête basculée en arrière au
# sol. Retour Sophie "on a l'impression qu'on est juste allongé" — angle du tronc
# poussé bien plus vertical (220°->260°) pour une cambrure du buste nette, plus
# marque de contact sol sous le bassin (seul point qui reste posé) ----
c = Chain("hip", (46, 40))
c.add("shoulder", TORSO, 260, key=True)     # tronc quasi vertical (poitrine bien levée, geste-clé)
c.add("knee", THIGH, 5, from_name="hip", kind='leg')
c.add("ankle", SHIN, 5, kind='leg')
c.add("toe", FOOT, 350, kind='leg')
c.add_arm("", 260, 200, from_name="shoulder")  # avant-bras d'appui au sol, longueur pleine
head_c, neck_parts = head_and_neck(c.points["shoulder"], 165)  # cou bascule en arrière, tête vers le sol
pelvis_l = pt(c.points["hip"], 3, 5)
pelvis_r = pt(c.points["hip"], 3, 175)
svg = [svg_open(), ground(43)]
svg.append(ground_contact(pelvis_l, pelvis_r, y=43.8))
svg.append(c.render())
svg += neck_parts
svg.append(svg_close())
bounds_check("Matsyasana", list(c.points.values()) + [head_c])
add_figure("Matsyasana", "Poisson — poitrine bien levée (geste-clé), bassin au sol (trait plein)", "".join(svg))

# ---- Dhanurasana (arc) : ventre au sol, mains attrapent les chevilles ----
c = Chain("hip", (40, 40))
c.add("shoulder", TORSO, 250)                 # buste relevé vers le haut-arrière
c.add("elbow", UPPER_ARM, 340, key=True, from_name="shoulder", kind='arm')   # bras tendu vers l'arrière pour attraper la cheville
c.add("knee", THIGH, 310, from_name="hip", kind='leg')     # cuisse relevée vers le haut-arrière
c.add("ankle", SHIN, 260, from_name="knee", key=True, kind='leg')  # tibia replié, cheville proche de la main
head_c, neck_parts = head_and_neck(c.points["shoulder"], 250)
belly_l = pt(c.points["hip"], 3, 5)
belly_r = pt(c.points["hip"], 3, 175)
svg = [svg_open(), ground(43)]
svg.append(ground_contact(belly_l, belly_r, y=43.8))
svg.append(c.render())
svg += neck_parts
svg.append(svg_close())
bounds_check("Dhanurasana", list(c.points.values()) + [head_c])
held_object_check("Dhanurasana (main->cheville)", c.points["shoulder"], c.points["elbow"], c.points["ankle"])
add_figure("Dhanurasana", "Arc — main attrape la cheville (geste-clé)", "".join(svg))

# ---- Urdhva Dhanurasana (roue) : mains ET pieds au sol, dos cambré, hanche haute.
# 2 passes de retours Sophie ("dos pas cambré", "confondu avec ForwardFold/chien tête
# en bas") — le problème racine : un TRAIT DROIT ne peut pas se distinguer d'un pli
# (ForwardFold) à cette échelle, cambrure ou pas. Refait en DÔME LARGE (hanche = point
# le plus haut, mains et pieds écartés de chaque côté au sol — silhouette large, pas
# un trait vertical étroit) + le tronc est maintenant une VRAIE COURBE (arc_line),
# seule pose de la galerie à utiliser un trait courbe : ça se voit sans ambiguïté. ----
c = Chain("hip", (40, 8))
c.add("shoulder", TORSO, 145, from_name="hip")
c.add("elbow", UPPER_ARM, 145, from_name="shoulder", kind='arm')
c.add("hand", FOREARM, 145, kind='arm')
c.add("knee", THIGH, 35, from_name="hip", kind='leg')
c.add("ankle", SHIN, 35, from_name="knee", kind='leg')
c.add("toe", FOOT, 75, kind='leg')
head_c, neck_parts = head_and_neck(c.points["shoulder"], 145)
bounds_check("UrdhvaDhanurasana", list(c.points.values()) + [head_c])
svg = [svg_open(), ground(26)]
for a, b, key, kind in c.segments:
    if (a, b) == ("hip", "shoulder"):
        continue  # remplacé par l'arc ci-dessous
    col = COL_ARM if kind == 'arm' else (COL_LEG if kind == 'leg' else COL_BODY)
    svg.append(line(c.points[a], c.points[b], color=col, w=STROKE))
svg.append(arc_line(c.points["hip"], c.points["shoulder"], 6, color=COL_BODY, w=STROKE))  # dos cambré (geste-clé)
for n in c.order:
    svg.append(joint(c.points[n]))
svg += neck_parts
svg.append(svg_close())
add_figure("UrdhvaDhanurasana", "Roue — dos VRAIMENT cambré (trait courbe, geste-clé), mains+pieds écartés au sol", "".join(svg))

# ============================================================
html = ['<!doctype html><html><head><meta charset="utf-8"><title>Lot 3 — allongé</title><style>',
        'body{margin:0;padding:24px;background:#fff;font-family:-apple-system,sans-serif;}',
        '.grid{display:flex;flex-wrap:wrap;gap:20px;} figure{margin:0;text-align:center;}',
        '.cell{width:220px;height:150px;background:#f7f7f7;border-radius:8px;display:flex;align-items:center;justify-content:center;}',
        'svg{width:88%;height:88%;} figcaption{margin-top:8px;font-size:12px;color:#444;max-width:220px;}',
        '</style></head><body><div class="grid">']
for title, caption, body in FIGURES:
    html.append(f'<figure><div class="cell">{body}</div><figcaption><b>{title}</b><br>{caption}</figcaption></figure>')
html.append('</div></body></html>')
with open("lot3.html", "w") as f:
    f.write("\n".join(html))
print("OK — lot3.html écrit")
