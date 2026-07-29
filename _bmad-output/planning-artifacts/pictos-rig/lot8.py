import sys
sys.path.insert(0, ".")
from posture_rig import *

FIGURES = []
def add_figure(title, caption, svg, zoom=None):
    FIGURES.append((title, caption, svg, zoom))

# ---- Halasana (charrue) : sur le dos, jambes levées PAR-DESSUS la tête, orteils au
# sol derrière. Retour Sophie "faire le mouvement" — ajout d'une flèche de trajectoire
# en pointillé gris (motion_arc) : rond fantôme = jambes verticales (point de départ),
# courbe + pointe de flèche = bascule jusqu'à la position finale au sol ----
c = Chain("shoulder_base", (46, 44))
c.add("hip", TORSO, 280)
c.add("knee", THIGH, 250, key=True, kind='leg')     # jambes basculent par-dessus (geste-clé)
c.add("ankle", SHIN, 200, from_name="knee", kind='leg')
c.add("toe", FOOT, 160, kind='leg')
ghost = pt(c.points["hip"], THIGH + SHIN + FOOT - 2, 270)  # jambes verticales = position de départ du mouvement
svg = [svg_open(), ground(46)]
svg.append(motion_arc(ghost, c.points["toe"], -8))
svg.append(c.render())
svg.append(head((46, 44 + HEAD_R * 0.3)))
svg.append(svg_close())
bounds_check("Halasana", list(c.points.values()))
add_figure("Halasana", "Charrue — flèche = trajectoire des jambes qui basculent (geste-clé)", "".join(svg))

# ---- Karnapidasana : variante Halasana, genoux pliés près des oreilles.
# 2e retour Sophie "je comprends pas genoux aux oreilles" — CAUSE RACINE trouvée :
# la 1ère correction avait rapproché la tête de la CHEVILLE, alors que le geste-clé
# c'est le GENOU près de l'oreille. Refait : angle de cuisse recalculé pour que le
# genou atterrisse vraiment à côté de la tête (gardée à sa position anatomique
# naturelle, comme Halasana), tibia+pied continuent au sol derrière. ----
c = Chain("shoulder_base", (46, 44))
c.add("hip", TORSO, 280)
c.add("knee", THIGH, 120, from_name="hip", key=True, kind='leg')   # genou ramené près de la tête (geste-clé)
c.add("ankle", SHIN, 30, from_name="knee", key=True, kind='leg')
c.add("toe", FOOT, 30, key=True, kind='leg')
head_c = (46, 44 + HEAD_R * 0.3)  # position anatomique naturelle (comme Halasana), pas déplacée
inner = c.render() + head(head_c) + line(c.points["knee"], head_c, w=STROKE * 0.7)
svg = [svg_open(), ground(46), inner, svg_close()]
bounds_check("Karnapidasana", list(c.points.values()) + [head_c])
zoom = zoom_inset(inner, head_c, radius=7)
add_figure("Karnapidasana", "Genoux aux oreilles — le genou touche vraiment la tête (zoom)", "".join(svg), zoom=zoom)

# ---- Viparita Karani : sur le dos, jambes tendues à la verticale CONTRE UN MUR —
# le mur est maintenant dessiné (trait plein vertical), plus seulement suggéré.
# Bras ajoutés relâchés le long du corps (absents avant — question Sophie "pourquoi
# les bras ne sont pas orange" : ils n'existaient tout simplement pas sur le dessin) ----
c = Chain("hip", (46, 40))
c.add("shoulder", TORSO, 180)
# BUG trouvé (retour Sophie "le tronc traverse le mur") : "knee" n'avait pas de
# from_name explicite donc continuait depuis "shoulder" (dernier point ajouté) au
# lieu de brancher depuis "hip" — les jambes partaient du niveau de la tête, pas du
# bassin, ce qui plaçait le mur en plein milieu de la ligne tronc.
c.add("knee", THIGH, 270, key=True, from_name="hip", kind='leg')     # jambes verticales (geste-clé)
c.add("ankle", SHIN, 270, from_name="knee", kind='leg')
c.add("toe", FOOT, 260, kind='leg')
c.add_arm("", 120, 200, from_name="shoulder")   # bras relâchés le long du corps, longueur pleine
head_c, neck_parts = head_and_neck(c.points["shoulder"], 180)
wall_x = c.points["knee"][0] + 3
svg = [svg_open(), ground(43)]
svg.append(f'<line x1="{wall_x:.1f}" y1="6" x2="{wall_x:.1f}" y2="43" stroke="{COL_BODY}" stroke-width="1.6"/>')  # le mur
svg.append(c.render())
svg += neck_parts
svg.append(svg_close())
bounds_check("ViparitaKarani", list(c.points.values()) + [head_c])
add_figure("ViparitaKarani", "Jambes au mur — le mur est dessiné (trait vertical)", "".join(svg))

# ---- Supta Baddha Konasana : allongé, papillon (genoux ouverts, plantes jointes).
# Bras ajoutés (absents avant — retour Sophie "bras manquants/pas clairs") ----
c = Chain("hip", (40, 34))
c.add("shoulder", TORSO, 180)
c.add_leg("R", 30, 200, 260, from_name="hip", key=True)
c.add_arm("", 120, 200, from_name="shoulder")   # bras relâchés le long du corps, longueur pleine
head_c, neck_parts = head_and_neck(c.points["shoulder"], 180)
svg = [svg_open(), ground(38)]
svg.append(c.render())
svg += neck_parts
svg.append(svg_close())
bounds_check("SuptaBaddhaKonasana", list(c.points.values()) + [head_c])
add_figure("SuptaBaddhaKonasana", "Papillon allongé — genou ouvert (geste-clé), bras relâchés", "".join(svg))

# ---- Uttana Padasana : sur le dos, jambes levées tendues à ~45°, buste au sol.
# Bras tendus vers le haut, longeant les jambes en miroir (absents avant — retour
# Sophie "buste et bras pas clairs") ----
c = Chain("hip", (46, 40))
c.add("shoulder", TORSO, 180)
# Même bug que ViparitaKarani (retour Sophie "les jambes partent de la tête") :
# from_name manquant faisait brancher les jambes depuis l'épaule au lieu du bassin.
c.add("knee", THIGH, 300, key=True, from_name="hip", kind='leg')
c.add("ankle", SHIN, 320, from_name="knee", kind='leg')
c.add("toe", FOOT, 320, kind='leg')
c.add_arm("", 300, 320, from_name="shoulder")   # bras tendus vers le haut, parallèles aux jambes
head_c, neck_parts = head_and_neck(c.points["shoulder"], 180)
svg = [svg_open(), ground(43)]
svg.append(ground_contact(c.points["hip"], c.points["shoulder"], y=43))  # dos+bassin restent au sol (geste-clé)
svg.append(c.render())
svg += neck_parts
svg.append(svg_close())
bounds_check("UttanaPadasana", list(c.points.values()) + [head_c])
add_figure("UttanaPadasana", "Jambes+bras levés à 45° — buste reste au sol (trait plein, geste-clé)", "".join(svg))

# ---- Purvottanasana (planche inversée) : mains derrière au sol, hanche levée, face
# vers le haut. BUG trouvé : la cheville atterrissait à y=21.6 alors que le sol est
# à y=40 — les pieds ne touchaient jamais le sol (seule la main était vraiment posée).
# Angles de jambe refaits pour que le pied redescende vraiment au sol. ----
c = Chain("hand", (36, 40))
c.add("elbow", FOREARM, 260, key=True, kind='arm')
c.add("shoulder", UPPER_ARM, 260, kind='arm')
c.add("hip", TORSO, 340, from_name="shoulder")
c.add("knee", THIGH, 60, from_name="hip", kind='leg')
c.add("ankle", SHIN, 80, from_name="knee", kind='leg')
c.add("toe", FOOT, 60, kind='leg')
head_c, neck_parts = head_and_neck(c.points["shoulder"], 320)
svg = [svg_open(), ground(40)]
svg.append(ground_contact(c.points["hand"], c.points["ankle"], y=40))
svg.append(c.render())
svg += neck_parts
svg.append(svg_close())
bounds_check("Purvottanasana", list(c.points.values()) + [head_c])
add_figure("Purvottanasana", "Planche inversée — main ET pied au sol (trait plein), hanche levée", "".join(svg))

# ---- Kapotasana (pigeon roi) : à genoux, buste cambré en arrière, mains vers les pieds ----
c = Chain("knee", (40, 43))
c.add("hip", THIGH, 260, key=True, kind='leg')          # cuisse verticale (à genoux), hanche poussée en avant (geste-clé)
c.add("shoulder", TORSO, 220, from_name="hip", key=True)   # buste cambré en arrière
c.add("elbow", UPPER_ARM, 130, from_name="shoulder", kind='arm')
c.add("wrist", FOREARM, 80, kind='arm')
head_c, neck_parts = head_and_neck(c.points["shoulder"], 200)
svg = [svg_open(), ground(43)]
svg.append(c.render())
svg += neck_parts
svg.append(svg_close())
bounds_check("Kapotasana", list(c.points.values()) + [head_c])
add_figure("Kapotasana", "Pigeon roi — hanche poussée en avant, buste cambré (geste-clé)", "".join(svg))

# ---- Ustrasana (chameau) : à genoux, hanches en avant, buste cambré, mains vers les talons ----
c = Chain("knee", (40, 43))
c.add("hip", THIGH, 270, key=True, kind='leg')
c.add("shoulder", TORSO, 230, from_name="hip", key=True)
c.add("elbow", UPPER_ARM, 140, from_name="shoulder", kind='arm')
c.add("wrist", FOREARM, 90, kind='arm')
head_c, neck_parts = head_and_neck(c.points["shoulder"], 210)
svg = [svg_open(), ground(43)]
svg.append(c.render())
svg += neck_parts
svg.append(svg_close())
bounds_check("Ustrasana", list(c.points.values()) + [head_c])
add_figure("Ustrasana", "Chameau — hanche en avant, buste cambré (geste-clé)", "".join(svg))

# ---- Anjaneyasana (fente basse) : genou avant plié 90°, genou arrière au sol, bras
# levés. BUG trouvé (retour Sophie "genou au sol") : la hanche restait à hauteur de
# debout (y=22.6) — avec THIGH=11, le genou arrière ne pouvait géométriquement PAS
# descendre jusqu'au sol (y=45) depuis une hanche aussi haute. Jambe avant repliée
# bien plus bas (vraie fente basse) pour que le genou arrière touche vraiment le sol ----
c = Chain("ankle", (34, 43))
c.add("knee", SHIN, 220, kind='leg')
c.add("hip", THIGH, 190, from_name="knee", kind='leg')
c.add("shoulder", TORSO, 275, from_name="hip")
c.add("elbow", UPPER_ARM, 325, key=True, from_name="shoulder", kind='arm')
c.add("wrist", FOREARM, 325, key=True, kind='arm')
c.add("kneeB", THIGH, 100, from_name="hip", key=True, kind='leg')    # genou arrière au sol (geste-clé, fente basse)
c.add("ankleB", SHIN, 0, from_name="kneeB", kind='leg')
toe_f = pt(c.points["ankle"], FOOT, 15)
head_c, neck_parts = head_and_neck(c.points["shoulder"], 275)
svg = [svg_open(), ground(45)]
svg.append(ground_contact(c.points["kneeB"], c.points["ankleB"], y=45))  # genou arrière au sol (geste-clé)
svg.append(line(c.points["ankle"], toe_f))
svg.append(joint(c.points["ankle"]))
svg.append(c.render(mark_root_joint=False))
svg.append(joint(c.points["ankle"]))
svg += neck_parts
bounds_check("Anjaneyasana", list(c.points.values()) + [head_c, toe_f])
svg.append(svg_close())
add_figure("Anjaneyasana", "Fente basse — genou arrière VRAIMENT au sol (trait plein, geste-clé)", "".join(svg))

# ---- Garudasana (aigle) : équilibre 1 jambe, jambes ET bras entrelacés. BUG trouvé
# (retour Sophie "pas entrelacé") : un SEUL bras était dessiné — un bras plié seul ne
# peut pas se lire comme "entrelacé", il n'y a rien avec quoi il s'entrelace. 2e bras
# ajouté en miroir pour former un vrai croisement visible (X) ----
c = Chain("ankle", (40, 43))
c.add("knee", SHIN, 270, kind='leg')
c.add("hip", THIGH, 270, kind='leg')
c.add("shoulder", TORSO, 270)
c.add_arm("", 40, 320, from_name="shoulder", key=True)          # bras croisés devant (geste-clé), longueur pleine
c.add_arm("T", 140, 220, from_name="shoulder", key=True)        # 2e bras, miroir — croisement visible
c.add_leg("B", 200, 130, 80, from_name="hip", key=True)   # jambe enroulée PAR L'ANGLE (geste-clé), longueur pleine
head_c, neck_parts = head_and_neck(c.points["shoulder"], 270)
toe_f = pt(c.points["ankle"], FOOT, 15)
svg = [svg_open(), ground(43)]
svg.append(line(c.points["ankle"], toe_f))
svg.append(joint(c.points["ankle"]))
svg.append(c.render(mark_root_joint=False))
svg.append(joint(c.points["ankle"]))
svg += neck_parts
bounds_check("Garudasana", list(c.points.values()) + [head_c, toe_f])
svg.append(svg_close())
add_figure("Garudasana", "Aigle — bras et jambe entrelacés (geste-clé)", "".join(svg))

# ---- Prasarita Padottanasana : VUE DE FACE (retour Sophie "complètement pas clair" —
# comme Triangle, le profil ne montrait qu'UNE jambe, le grand écart était invisible).
# Hanche au centre, 2 jambes symétriques largement écartées, tronc+bras pliés tout
# droit vers le bas entre les jambes (geste-clé) ----
c = Chain("hip", (40, 10))
c.add_leg("R", 50, 50, 350, from_name="hip")
c.add_leg("L", 130, 130, 190, from_name="hip")
c.add("shoulder", TORSO, 90, from_name="hip", key=True)   # tronc plié droit vers le bas (geste-clé)
c.add("elbow", UPPER_ARM, 90, from_name="shoulder", kind='arm')
c.add("wrist", FOREARM, 90, kind='arm')
head_c, neck_parts = head_and_neck(c.points["shoulder"], 90)
svg = [svg_open(), ground(28)]
svg.append(c.render())
svg += neck_parts
svg.append(svg_close())
bounds_check("PrasaritaPadottanasana", list(c.points.values()) + [head_c])
add_figure("PrasaritaPadottanasana", "Vue de face — jambes très écartées, tronc plié droit entre elles (geste-clé)", "".join(svg))

# ---- Padahastasana : flexion avant debout, mains glissées sous les pieds. Même bug
# retrace-la-jambe (torse 95° quasi opposé à jambe 270°) que Padangusthasana ----
c = Chain("ankle", (40, 43))
c.add("knee", SHIN, 270, kind='leg')
c.add("hip", THIGH, 270, kind='leg')
c.add("shoulder", TORSO, 75, key=True)
c.add("elbow", UPPER_ARM, 80, from_name="shoulder", kind='arm')
c.add("wrist", FOREARM, 80, key=True, kind='arm')   # mains sous les pieds (geste-clé)
head_c, neck_parts = head_and_neck(c.points["shoulder"], 75)
toe_f = pt(c.points["ankle"], FOOT, 15)
svg = [svg_open(), ground(43)]
svg.append(line(c.points["ankle"], toe_f))
svg.append(joint(c.points["ankle"]))
svg.append(c.render(mark_root_joint=False))
svg.append(joint(c.points["ankle"]))
svg += neck_parts
bounds_check("Padahastasana", list(c.points.values()) + [head_c, toe_f])
svg.append(svg_close())
add_figure("Padahastasana", "Mains sous les pieds (geste-clé), flexion avant debout", "".join(svg))

# ============================================================
html = ['<!doctype html><html><head><meta charset="utf-8"><title>Lot 8</title><style>',
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
with open("lot8.html", "w") as f:
    f.write("\n".join(html))
print("OK — lot8.html écrit")
