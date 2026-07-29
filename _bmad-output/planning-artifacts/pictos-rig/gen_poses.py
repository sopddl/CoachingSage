import sys, math
sys.path.insert(0, ".")
from rig import *

FIGURES = []

def add_figure(title, caption, body_svg, w=150, h=150):
    FIGURES.append((title, caption, body_svg, w, h))

def head_and_neck(shoulder, angle):
    """Retourne (head_center, neck_end_point, svg_parts) — NECK + HEAD_R dans la direction angle."""
    neck_end = pt(shoulder, NECK, angle)
    head_c = pt(shoulder, NECK + HEAD_R, angle)
    parts = [line(shoulder, neck_end), head(head_c)]
    return head_c, parts

def arm(shoulder, angle_upper, angle_fore, color_key=False):
    """Bras 2 segments (coude marqué même si tendu). Retourne (wrist, parts)."""
    elbow = pt(shoulder, UPPER_ARM, angle_upper)
    wrist = pt(elbow, FOREARM, angle_fore)
    col = COL_KEY if color_key else COL_BODY
    parts = [line(shoulder, elbow, color=col), joint(elbow),
             line(elbow, wrist, color=col), joint(wrist)]
    return wrist, parts

def leg(hip, angle_thigh, angle_shin, angle_foot, color_key=False):
    """Jambe 2 segments + pied (toujours vers l'avant, jamais vers l'arrière)."""
    knee = pt(hip, THIGH, angle_thigh)
    ankle = pt(knee, SHIN, angle_shin)
    toe = pt(ankle, FOOT, angle_foot)
    col = COL_KEY if color_key else COL_BODY
    parts = [line(hip, knee, color=col), joint(knee),
             line(knee, ankle, color=col), joint(ankle),
             line(ankle, toe, color=col)]
    return ankle, toe, parts


# ============================================================
# POSE 1 — Dhanurasana (l'arc), yoga. Ventre au sol, mains
# attrapent les chevilles, buste + cuisses relevés.
# ============================================================
hip = (24.0, 40.0)
shoulder = pt(hip, TORSO, 232)          # up-left, buste relevé
knee = pt(hip, THIGH, 310)              # up-right
ankle = pt(knee, SHIN, 260)             # tibia replié vers la tête (haut)
toe = pt(ankle, FOOT, 220)              # pied continue vers la tête — jamais vers l'arrière
head_c, neck_parts = head_and_neck(shoulder, 210)  # tête relevée, regard vers l'avant
# bras = geste-clé, tendu shoulder->ankle (16 = upper_arm+forearm), coude marqué sur la ligne
arm_angle = math.degrees(math.atan2(ankle[1]-shoulder[1], ankle[0]-shoulder[0]))
elbow = pt(shoulder, UPPER_ARM, arm_angle)
wrist = pt(elbow, FOREARM, arm_angle)

check_rig("Dhanurasana", {"hip": hip, "shoulder": shoulder, "knee": knee, "ankle": ankle, "toe": toe,
                           "elbow": elbow, "wrist": wrist},
          [("hip", "shoulder", TORSO), ("hip", "knee", THIGH), ("knee", "ankle", SHIN),
           ("ankle", "toe", FOOT), ("shoulder", "elbow", UPPER_ARM), ("elbow", "wrist", FOREARM)])

svg = [svg_open(), ground(43)]
svg += [line(hip, shoulder), joint(hip), joint(shoulder)]
svg += neck_parts
svg += [line(hip, knee), joint(knee), line(knee, ankle), joint(ankle), line(ankle, toe)]
svg += [line(shoulder, elbow, color=COL_KEY), joint(elbow), line(elbow, wrist, color=COL_KEY), joint(wrist)]
svg.append(svg_close())
add_figure("Dhanurasana", "Yoga — l'arc (bras = geste-clé)", "".join(svg))


# ============================================================
# POSE 2 — Phalakasana (planche), yoga. Ligne droite épaules-
# talons, un bras d'appui vertical.
# ============================================================
wrist_support = (18.0, 40.0)
elbow2 = pt(wrist_support, FOREARM, 270)   # avant-bras vertical
shoulder2 = pt(elbow2, UPPER_ARM, 270)     # bras vertical (tendu, coude marqué mais aligné)
hip2 = pt(shoulder2, TORSO, 8)             # tronc STRICTEMENT horizontal (léger angle bas pour lisibilité)
knee2 = pt(hip2, THIGH, 12)
ankle2 = pt(knee2, SHIN, 12)
toe2 = pt(ankle2, FOOT, 55)                # pied vers l'avant-bas, jamais vers l'arrière
head_c2, neck_parts2 = head_and_neck(shoulder2, 250)

check_rig("Phalakasana", {"wrist": wrist_support, "elbow": elbow2, "shoulder": shoulder2,
                           "hip": hip2, "knee": knee2, "ankle": ankle2, "toe": toe2},
          [("wrist", "elbow", FOREARM), ("elbow", "shoulder", UPPER_ARM), ("shoulder", "hip", TORSO),
           ("hip", "knee", THIGH), ("knee", "ankle", SHIN), ("ankle", "toe", FOOT)])

svg = [svg_open(), ground(43)]
svg += [line(wrist_support, elbow2, color=COL_KEY), joint(wrist_support), joint(elbow2)]
svg += [line(elbow2, shoulder2, color=COL_KEY), joint(shoulder2)]
svg += neck_parts2
svg += [line(shoulder2, hip2, color=COL_KEY), joint(hip2)]
svg += [line(hip2, knee2), joint(knee2), line(knee2, ankle2), joint(ankle2), line(ankle2, toe2)]
svg.append(svg_close())
add_figure("Phalakasana", "Yoga — planche (tronc = geste-clé)", "".join(svg))


# ============================================================
# POSE 3 — Squat gobelet (haltère tenue devant, bras visibles),
# muscu. La barbell (back squat) est un mouvement plus avancé —
# le squat "de base" que la plupart des gens font tient une
# charge en mains (haltère/kettlebell), pas une barre sur le dos.
# ============================================================
ankle3 = (26.0, 43.0)
knee3 = pt(ankle3, SHIN, 280)               # genou légèrement devant la cheville (tibia peu incliné)
hip3 = pt(knee3, THIGH, 210)                # hanche reculée (bas du squat)
shoulder3 = pt(hip3, TORSO, 307)            # buste incliné VERS L'AVANT (épaule quasi à l'aplomb du pied, pas en arrière)
toe3 = pt(ankle3, FOOT, 15)                # pied vers l'avant, jamais arrière
head_c3, neck_parts3 = head_and_neck(shoulder3, 307)
# bras replié : le COUDE reste près du corps (proche de la ligne du buste), l'avant-bras
# remonte VERS L'AVANT pour tenir l'haltère loin du corps — ordre corps → coude → haltère,
# jamais l'inverse (sinon ça lit comme un bras tordu qui présente l'haltère vers l'extérieur)
elbow3 = pt(shoulder3, UPPER_ARM, 85)
wrist3 = pt(elbow3, FOREARM, 320)

check_rig("Squat gobelet", {"ankle": ankle3, "knee": knee3, "hip": hip3, "shoulder": shoulder3, "toe": toe3},
          [("ankle", "knee", SHIN), ("knee", "hip", THIGH), ("hip", "shoulder", TORSO), ("ankle", "toe", FOOT)])

svg = [svg_open(), ground(45)]
svg += [line(ankle3, toe3), joint(ankle3)]
svg += [line(ankle3, knee3, color=COL_KEY), joint(knee3)]
svg += [line(knee3, hip3, color=COL_KEY), joint(hip3)]
svg += [line(hip3, shoulder3), joint(shoulder3)]
svg += neck_parts3
svg += [line(shoulder3, elbow3, color=COL_KEY), joint(elbow3), line(elbow3, wrist3, color=COL_KEY), joint(wrist3)]
svg.append(dumbbell(wrist3, angle_deg=90))
svg.append(svg_close())
add_figure("Squat (haltère)", "Muscu — squat gobelet, bras visibles tenant la charge (genou+hanche+bras = geste-clé)", "".join(svg))


# ============================================================
# POSE 4 — Soulevé de terre (bas), muscu.
# ============================================================
ankle4 = (16.0, 43.0)
toe4 = pt(ankle4, FOOT, 10)
knee4 = pt(ankle4, SHIN, 285)               # tibia quasi vertical, genou à peine devant la cheville
hip4 = pt(knee4, THIGH, 220)                # hanche haute et reculée (le geste-clé du hip hinge)
shoulder4 = pt(hip4, TORSO, 315)            # buste penché vers l'avant
head_c4, neck_parts4 = head_and_neck(shoulder4, 315)
# bras tendu, légèrement projeté devant le tibia (pas dans son prolongement — sinon
# bras et jambe se confondent visuellement) — longueur = rig, pas de raccourci
elbow4b = pt(shoulder4, UPPER_ARM, 75)
wrist4 = pt(elbow4b, FOREARM, 75)           # barre nettement devant le pied, pas dessus

check_rig("Deadlift", {"ankle": ankle4, "knee": knee4, "hip": hip4, "shoulder": shoulder4, "toe": toe4,
                       "elbow": elbow4b, "wrist": wrist4},
          [("ankle", "knee", SHIN), ("knee", "hip", THIGH), ("hip", "shoulder", TORSO), ("ankle", "toe", FOOT),
           ("shoulder", "elbow", UPPER_ARM), ("elbow", "wrist", FOREARM)])

svg = [svg_open(), ground(45)]
svg += [line(ankle4, toe4), joint(ankle4)]
svg += [line(ankle4, knee4), joint(knee4)]
svg += [line(knee4, hip4, color=COL_KEY), joint(hip4)]
svg += [line(hip4, shoulder4, color=COL_KEY), joint(shoulder4)]
svg += neck_parts4
svg += [line(shoulder4, elbow4b), joint(elbow4b), line(elbow4b, wrist4), joint(wrist4)]
bar_c4 = wrist4
svg.append(bar_fixed(bar_c4[0]-6, bar_c4[0]+6, bar_c4[1]))
svg.append(plate((bar_c4[0]-6, bar_c4[1])))
svg.append(plate((bar_c4[0]+6, bar_c4[1])))
svg.append(svg_close())
add_figure("Deadlift (barre)", "Muscu — bas du mouvement (hanche+dos = geste-clé)", "".join(svg))


# ============================================================
# POSE 5 — Curl biceps, muscu. Sert à valider la vraie haltère
# (silhouette dédiée manche+2 têtes, taille fixe, bleu vif) —
# tenue en main, à côté d'un corps debout, pour juger l'échelle.
# Construite pieds->tête (debout) pour rester dans le cadre 48x48.
# ============================================================
ankle5 = (24.0, 43.0)
toe5 = pt(ankle5, FOOT, 10)
knee5 = pt(ankle5, SHIN, 270)
hip5 = pt(knee5, THIGH, 270)
shoulder5 = pt(hip5, TORSO, 270)
head_c5, neck_parts5 = head_and_neck(shoulder5, 270)
# coude près du corps, avant-bras remonte VERS L'AVANT — ordre corps → coude → haltère
elbow5 = pt(shoulder5, UPPER_ARM, 80)
wrist5 = pt(elbow5, FOREARM, 340)

check_rig("Curl biceps", {"ankle": ankle5, "knee": knee5, "hip": hip5, "shoulder": shoulder5,
                          "elbow": elbow5, "wrist": wrist5},
          [("ankle", "knee", SHIN), ("knee", "hip", THIGH), ("hip", "shoulder", TORSO),
           ("shoulder", "elbow", UPPER_ARM), ("elbow", "wrist", FOREARM)])

svg = [svg_open(), ground(43)]
svg += [line(ankle5, toe5), joint(ankle5)]
svg += [line(ankle5, knee5), joint(knee5), line(knee5, hip5), joint(hip5), line(hip5, shoulder5), joint(shoulder5)]
svg += neck_parts5
svg += [line(shoulder5, elbow5, color=COL_KEY), joint(elbow5), line(elbow5, wrist5, color=COL_KEY), joint(wrist5)]
svg.append(dumbbell(wrist5, angle_deg=90))
svg.append(svg_close())
add_figure("Curl biceps", "Muscu — haltère au poignet (référence taille/couleur fixe)", "".join(svg))


# ============================================================
# POSE 6 — Squat barre (back squat), variante AVANCÉE du squat
# gobelet (pose 3). Même rig de jambes, barre sur les trapèzes
# au lieu de l'haltère en mains. Pas de bras dessinés (grip
# fixe derrière la nuque, hors-cadre du mouvement illustré).
# ============================================================
ankle6 = (26.0, 43.0)
knee6 = pt(ankle6, SHIN, 280)
hip6 = pt(knee6, THIGH, 210)
shoulder6 = pt(hip6, TORSO, 307)
toe6 = pt(ankle6, FOOT, 15)
head_c6, neck_parts6 = head_and_neck(shoulder6, 307)

check_rig("Squat barre (avancé)", {"ankle": ankle6, "knee": knee6, "hip": hip6, "shoulder": shoulder6, "toe": toe6},
          [("ankle", "knee", SHIN), ("knee", "hip", THIGH), ("hip", "shoulder", TORSO), ("ankle", "toe", FOOT)])

svg = [svg_open(), ground(45)]
svg += [line(ankle6, toe6), joint(ankle6)]
svg += [line(ankle6, knee6, color=COL_KEY), joint(knee6)]
svg += [line(knee6, hip6, color=COL_KEY), joint(hip6)]
svg += [line(hip6, shoulder6), joint(shoulder6)]
svg += neck_parts6
bar_c6 = (shoulder6[0], shoulder6[1] + 2.0)
svg.append(bar_fixed(bar_c6[0]-6, bar_c6[0]+6, bar_c6[1]))
svg.append(plate((bar_c6[0]-6, bar_c6[1])))
svg.append(plate((bar_c6[0]+6, bar_c6[1])))
svg.append(svg_close())
add_figure("Squat (barre) — avancé", "Muscu — back squat, variante plus difficile du squat gobelet (mêmes jambes)", "".join(svg))


# ============================================================
# POSE 7 — Rowing haltère (bent-over row), muscu. Buste penché
# façon hip hinge, un bras tire l'haltère vers les côtes (geste-
# clé), l'autre main prend appui sur un banc (non dessinée).
# ============================================================
ankle7 = (16.0, 43.0)
toe7 = pt(ankle7, FOOT, 10)
knee7 = pt(ankle7, SHIN, 285)
hip7 = pt(knee7, THIGH, 220)
shoulder7 = pt(hip7, TORSO, 320)
head_c7, neck_parts7 = head_and_neck(shoulder7, 320)
# coude près du corps (proche de la ligne du buste), avant-bras continue vers le bas —
# ordre corps → coude → haltère, jamais l'inverse
elbow7 = pt(shoulder7, UPPER_ARM, 95)
wrist7 = pt(elbow7, FOREARM, 100)

check_rig("Rowing haltère", {"ankle": ankle7, "knee": knee7, "hip": hip7, "shoulder": shoulder7,
                             "elbow": elbow7, "wrist": wrist7},
          [("ankle", "knee", SHIN), ("knee", "hip", THIGH), ("hip", "shoulder", TORSO),
           ("shoulder", "elbow", UPPER_ARM), ("elbow", "wrist", FOREARM)])

svg = [svg_open(), ground(45)]
svg += [line(ankle7, toe7), joint(ankle7)]
svg += [line(ankle7, knee7), joint(knee7)]
svg += [line(knee7, hip7), joint(hip7)]
svg += [line(hip7, shoulder7), joint(shoulder7)]
svg += neck_parts7
svg += [line(shoulder7, elbow7, color=COL_KEY), joint(elbow7), line(elbow7, wrist7, color=COL_KEY), joint(wrist7)]
svg.append(dumbbell(wrist7, angle_deg=90))
svg.append(svg_close())
add_figure("Rowing haltère", "Muscu — buste penché (hip hinge), bras = geste-clé", "".join(svg))


# ============================================================
# Comparaison isolée avant/après — juste l'icône, à plat.
# ============================================================
old_svg = [svg_open()]
old_svg.append(f'<rect x="{24-4.6/2:.1f}" y="{24-2.6/2:.1f}" width="4.6" height="2.6" rx="0.6" fill="#2a6067"/>')
old_svg.append(svg_close())
add_figure("Avant", "Ancien : un rectangle plat recyclé du disque de barre, bleu-vert terne", "".join(old_svg))

new_svg = [svg_open()]
new_svg.append(dumbbell((24, 24), angle_deg=90))
new_svg.append(svg_close())
add_figure("Après", "Nouveau : vraie silhouette haltère (manche + 2 têtes), bleu vif, taille fixe", "".join(new_svg))


# ============================================================
# Assemble HTML
# ============================================================
html = ['<!doctype html><html><head><meta charset="utf-8"><title>Rig — proportions fixes</title><style>',
        'body{margin:0;padding:24px;background:#fff;font-family:-apple-system,sans-serif;}',
        'h1{font-size:18px;margin:0 0 4px;} p.sub{color:#666;font-size:13px;max-width:680px;margin:0 0 20px;}',
        '.grid{display:flex;flex-wrap:wrap;gap:20px;} figure{margin:0;text-align:center;}',
        '.cell{width:180px;height:180px;background:#f7f7f7;border-radius:8px;display:flex;align-items:center;justify-content:center;}',
        'svg{width:82%;height:82%;} figcaption{margin-top:8px;font-size:12px;color:#444;max-width:180px;}',
        '.spec{margin-top:28px;font-size:12px;color:#444;background:#f3f4f1;border-radius:8px;padding:14px 16px;max-width:680px;}',
        '.spec b{color:#111;}',
        '</style></head><body>',
        '<h1>Rig unique — mêmes proportions, même trait, mêmes articulations</h1>',
        '<p class="sub">Toutes les poses partagent EXACTEMENT les mêmes longueurs de segment '
        '(tête, cou, bras, avant-bras, tronc, cuisse, tibia, pied), la même épaisseur de trait, '
        'le même style d\'articulation et la même taille d\'haltère/barre. Seuls les ANGLES changent.</p>',
        '<div class="grid">']
for title, caption, body, w, h in FIGURES:
    html.append(f'<figure><div class="cell">{body}</div><figcaption><b>{title}</b><br>{caption}</figcaption></figure>')
html.append('</div>')
html.append(
    '<div class="spec"><b>Table de proportions (unités viewBox 48×48, fixes pour tout le set)</b><br>'
    f'Tête (rayon) {HEAD_R} · Cou {NECK} · Bras (haut) {UPPER_ARM} · Avant-bras {FOREARM} · '
    f'Tronc {TORSO} · Cuisse {THIGH} · Tibia {SHIN} · Pied {FOOT}<br>'
    f'Trait corps {STROKE} · Trait équipement {STROKE_EQUIP} · Articulation r={JOINT_R} (trait {JOINT_STROKE})<br>'
    f'Haltère : manche {DUMBBELL_HANDLE} + 2 têtes {DUMBBELL_HEAD_W}×{DUMBBELL_HEAD_H}, '
    f'couleur {COL_DUMBBELL} (bleu vif) — silhouette dédiée, distincte de la barre<br>'
    'Disque barre 2×7 (fixe, StrengthFigureKit) · Pied toujours orienté vers l\'avant du mouvement.'
    '</div>')
html.append('</body></html>')

with open("rig-poses.html", "w") as f:
    f.write("\n".join(html))
print("OK — rig-poses.html écrit")
