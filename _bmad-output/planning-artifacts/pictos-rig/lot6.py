import sys
sys.path.insert(0, ".")
from posture_rig import *

FIGURES = []
def add_figure(title, caption, svg):
    FIGURES.append((title, caption, svg))

# ---- Cobra : ventre au sol, jambes tendues arrière à plat, buste levé sur les bras.
# Marque de contact sol pleine sous le bassin/bas-ventre (ground_contact) — retour
# Sophie "on ne comprend pas qu'on est sur le ventre" : le pointillé seul ne suffisait
# pas à distinguer "posé sur le sol" de "juste au-dessus" ----
c = Chain("hip", (46, 40))
c.add("knee", THIGH, 355, from_name="hip", kind='leg')   # jambes quasi à plat (pas sous le sol)
c.add("ankle", SHIN, 355, kind='leg')
c.add("toe", FOOT, 345, kind='leg')
c.add("shoulder", TORSO, 220, from_name="hip", key=True)   # buste relevé (geste-clé, cambrure)
c.add_arm("", 130, 190, from_name="shoulder")   # bras d'appui, longueur pleine
head_c, neck_parts = head_and_neck(c.points["shoulder"], 220)
belly_l = pt(c.points["hip"], 5, 5)
belly_r = pt(c.points["hip"], 5, 175)
svg = [svg_open(), ground(40)]
svg.append(ground_contact(belly_l, belly_r, y=40.8))  # décalé sous le rond d'articulation hanche pour rester visible
svg.append(c.render())
svg += neck_parts
svg.append(svg_close())
bounds_check("Cobra", list(c.points.values()) + [head_c])
add_figure("Cobra", "Ventre au sol (trait plein = contact), buste relevé sur les bras (geste-clé)", "".join(svg))

# ---- Enfant (Balasana) : assis sur les talons, buste plié en avant, front vers le sol ----
c = Chain("hip", (44, 32))
c.add_leg("", 30, 200, 260, from_name="hip")     # cuisse+tibia repliés PAR L'ANGLE, longueurs pleines
c.add("shoulder", TORSO, 155, key=True)               # tronc plié vers l'avant-bas (geste-clé), garde un peu de hauteur
c.add_arm("", 165, 165, from_name="shoulder")    # bras tendu en avant au sol, longueur pleine
head_c, neck_parts = head_and_neck(c.points["shoulder"], 175)
svg = [svg_open(), ground(38)]
svg.append(c.render())
svg += neck_parts
svg.append(svg_close())
bounds_check("Child", list(c.points.values()) + [head_c])
add_figure("Child", "Assis sur les talons, tronc plié en avant (geste-clé)", "".join(svg))

# ---- Triangle : VUE DE FACE (retour Sophie — le profil ne montrait qu'UNE seule
# jambe, "jambe large" illisible). Hanche au centre, 2 jambes symétriques largement
# écartées (comme UpavisthaKonasana), buste penché sur le côté (geste-clé) vers la
# jambe droite, bras du dessous continue jusqu'au tibia, bras du dessus tendu vers
# le haut — silhouette en grand triangle, lisible d'un coup d'œil ----
c = Chain("hip", (40, 26))
c.add_leg("R", 20, 20, 350, from_name="hip")     # jambe droite, largement écartée
c.add_leg("L", 160, 160, 190, from_name="hip")   # jambe gauche, symétrique (grand écart)
c.add("shoulder", TORSO, 320, from_name="hip", key=True)   # buste penché sur le côté (geste-clé)
c.add("elbow", UPPER_ARM, 100, from_name="shoulder", kind='arm')   # bras du dessous, continue vers le tibia
c.add("wrist", FOREARM, 100, kind='arm')
c.add("elbowT", UPPER_ARM, 280, from_name="shoulder", kind='arm')  # bras du dessus, tendu vers le haut
c.add("wristT", FOREARM, 280, kind='arm')
head_c, neck_parts = head_and_neck(c.points["shoulder"], 320)
# 2e retour Sophie : "ça veut dire quoi jambe large ?" — la vue de face seule ne
# suffisait pas à le lire comme "2 jambes au sol". Ajout de 2 petits traits perpendi-
# culaires (pieds à plat) aux points de contact au sol, en vert (couleur jambe), pour
# ancrer visuellement "ce sont des pieds posés au sol, très écartés".
foot_r = pt(c.points["Rtoe"], 2.2, 90)
foot_l = pt(c.points["Ltoe"], 2.2, 90)
svg = [svg_open(), ground(33)]
svg.append(c.render())
svg.append(line(c.points["Rtoe"], foot_r, color=COL_LEG, w=STROKE * 0.8))
svg.append(line(c.points["Ltoe"], foot_l, color=COL_LEG, w=STROKE * 0.8))
svg += neck_parts
svg.append(svg_close())
bounds_check("Triangle", list(c.points.values()) + [head_c])
add_figure("Triangle", "Vue de FACE (pas de profil) — 2 pieds au sol très écartés (geste-clé)", "".join(svg))

# ---- Bateau (Navasana) : assis, jambes levées tendues, buste penché en arrière, bras devant ----
c = Chain("hip", (46, 40))
c.add("knee", THIGH, 320, from_name="hip", key=True, kind='leg')   # jambes levées obliques (geste-clé)
c.add("ankle", SHIN, 340, from_name="knee", kind='leg')
c.add("toe", FOOT, 285, kind='leg')   # pieds pointés vers le HAUT (dos assis) — vs Salabhasana : vers le bas (ventre)
c.add("shoulder", TORSO, 245, from_name="hip")          # buste penché en arrière
c.add("elbow", UPPER_ARM, 300, from_name="shoulder", kind='arm')     # bras tendus vers l'avant, parallèles aux jambes
c.add("wrist", FOREARM, 320, kind='arm')
head_c, neck_parts = head_and_neck(c.points["shoulder"], 245)
svg = [svg_open(), ground(43)]
svg.append(c.render())
svg += neck_parts
svg.append(svg_close())
bounds_check("Boat", list(c.points.values()) + [head_c])
add_figure("Boat", "Assis, jambes levées tendues (geste-clé), buste en arrière", "".join(svg))

# ---- Salabhasana (sauterelle) : ventre au sol, jambes ET buste levés simultanément.
# SEUL le bassin reste posé (jambes ET buste décollés en même temps, geste-clé) —
# la marque de contact sol est donc volontairement COURTE (juste le bassin), pour
# bien montrer que tout le reste est en l'air, contrairement à Cobra (jambes au sol) ----
c = Chain("hip", (46, 40))
c.add("knee", THIGH, 320, from_name="hip", key=True, kind='leg')    # jambes levées (geste-clé)
c.add("ankle", SHIN, 340, from_name="knee", kind='leg')
c.add("toe", FOOT, 25, kind='leg')    # pieds pointés vers le BAS (ventre) — vs Boat : vers le haut (dos assis)
c.add("shoulder", TORSO, 230, from_name="hip", key=True)  # buste levé (geste-clé)
c.add_arm("", 250, 250, from_name="shoulder")  # bras tendus en arrière le long du corps, longueur pleine
head_c, neck_parts = head_and_neck(c.points["shoulder"], 230)
pelvis_l = pt(c.points["hip"], 3, 5)
pelvis_r = pt(c.points["hip"], 3, 175)
svg = [svg_open(), ground(40)]
svg.append(ground_contact(pelvis_l, pelvis_r, y=40.8))  # décalé sous le rond d'articulation hanche pour rester visible
svg.append(c.render())
svg += neck_parts
# Retour Sophie : différencier ventre/dos + montrer visage/cheveux. Pieds pointés
# vers le BAS (plantaire, loin du corps) = signature "ventre au sol" — à l'inverse de
# Boat (pieds vers le HAUT). Petits traits de cheveux sur l'arrière du crâne : on est
# allongé sur le ventre, on ne voit que l'arrière de la tête, jamais le visage.
svg.append(hair_tuft(head_c, 230))
svg.append(svg_close())
bounds_check("Salabhasana", list(c.points.values()) + [head_c])
add_figure("Salabhasana", "Ventre au sol — pieds pointés vers le bas + cheveux (dos de la tête) vs Boat", "".join(svg))

# ============================================================
html = ['<!doctype html><html><head><meta charset="utf-8"><title>Lot 6</title><style>',
        'body{margin:0;padding:24px;background:#fff;font-family:-apple-system,sans-serif;}',
        '.grid{display:flex;flex-wrap:wrap;gap:20px;} figure{margin:0;text-align:center;}',
        '.cell{width:220px;height:150px;background:#f7f7f7;border-radius:8px;display:flex;align-items:center;justify-content:center;}',
        'svg{width:88%;height:88%;} figcaption{margin-top:8px;font-size:12px;color:#444;max-width:220px;}',
        '</style></head><body><div class="grid">']
for title, caption, body in FIGURES:
    html.append(f'<figure><div class="cell">{body}</div><figcaption><b>{title}</b><br>{caption}</figcaption></figure>')
html.append('</div></body></html>')
with open("lot6.html", "w") as f:
    f.write("\n".join(html))
print("OK — lot6.html écrit")
