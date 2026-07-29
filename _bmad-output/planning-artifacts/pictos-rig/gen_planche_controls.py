import subprocess
import sys
sys.path.insert(0, ".")
from posture_rig import Chain, pt, line
from rig import (HEAD_R, NECK, STROKE, COL_BODY, UPPER_ARM, FOREARM, TORSO, THIGH, SHIN, FOOT,
                 dumbbell, bar_fixed, plate)


def head_and_neck_filled(shoulder, angle_deg):
    """Tête PLEINE pour le contrôle lineart — l'anneau du rig (cercle non rempli)
    produit 2 contours concentriques dans la carte lineart, que SDXL peint
    littéralement en donut/disque/ballon (constaté rounds 1-3 : disque de barre
    à la place de la tête du deadlift, tête-ballon downdog). Un disque plein ne
    donne qu'UN contour → lu comme une tête."""
    neck_end = pt(shoulder, NECK, angle_deg)
    head_c = pt(shoulder, NECK + HEAD_R, angle_deg)
    parts = [line(shoulder, neck_end, w=STROKE),
             f'<circle cx="{head_c[0]:.2f}" cy="{head_c[1]:.2f}" r="{HEAD_R}" fill="{COL_BODY}" stroke="none"/>']
    return head_c, parts

# ============================================================
# PLANCHE D'ÉCHANTILLONS — contrôles lineart pour Replicate.
# Recette validée (flat_triangle_v3) : stick-figure SANS ronds
# d'articulation NI sol, fond blanc, canvas CARRÉ 1024x1024.
# Poses reprises TELLES QUELLES des lots validés (mêmes angles),
# seul l'habillage change (pas de joints/ground/ground_contact).
# ============================================================

OUT = "ai-explo/planche"
subprocess.run(["mkdir", "-p", OUT], check=True)

CONTROLS = []  # (slug, svg_inner, points_for_bbox, extra_extents)


def register(slug, parts, points, extra_pts=()):
    CONTROLS.append((slug, "".join(parts), list(points) + list(extra_pts)))


# ---- 1. Warrior1 (debout, femme) — angles = lot1_debout.py ----
c = Chain("ankle", (34, 43))
c.add("knee", SHIN, 260, kind='leg')
c.add("hip", THIGH, 240, kind='leg')
c.add("shoulder", TORSO, 280)
c.add("elbow", UPPER_ARM, 295, kind='arm')   # bras quasi verticaux au-dessus de la tête (review expert 07-11)
c.add("wrist", FOREARM, 295, kind='arm')
c.add("kneeB", THIGH, 38, from_name="hip", kind='leg')   # fente pentue (15° lisait "jambe levée de danseuse")
c.add("ankleB", SHIN, 38, kind='leg')
c.add("toeB", FOOT, 0, kind='leg')  # pied à plat au sol
toe_f = pt(c.points["ankle"], FOOT, 15)
head_c, neck_parts = head_and_neck_filled(c.points["shoulder"], 280)
parts = [line(c.points["ankle"], toe_f), c.render(skip_joints=set(c.order))] + neck_parts
register("warrior1", parts, c.points.values(), [head_c, toe_f, pt(head_c, HEAD_R, 270)])

# ---- 2. Cobra (au sol, femme) — angles = lot6.py ----
c = Chain("hip", (46, 40))
c.add("knee", THIGH, 355, from_name="hip", kind='leg')
c.add("ankle", SHIN, 355, kind='leg')
c.add("toe", FOOT, 345, kind='leg')
c.add("shoulder", TORSO, 220, from_name="hip")
c.add_arm("", 130, 190, from_name="shoulder")
head_c, neck_parts = head_and_neck_filled(c.points["shoulder"], 220)
parts = [c.render(skip_joints=set(c.order))] + neck_parts
register("cobra", parts, c.points.values(), [head_c, pt(head_c, HEAD_R, 270)])

# ---- 3. Chien tête en bas (inversée, femme) — angles = lot4_quadru.py ----
c = Chain("hip", (40, 15))
c.add("shoulder", TORSO, 15, from_name="hip")
c.add("elbow", UPPER_ARM, 100, kind='arm')
c.add("hand", FOREARM, 100, kind='arm')
c.add("knee", THIGH, 150, from_name="hip", kind='leg')
c.add("ankle", SHIN, 100, kind='leg')
c.add("toe", FOOT, 60, kind='leg')
head_c, neck_parts = head_and_neck_filled(c.points["shoulder"], 100)
parts = [c.render(skip_joints=set(c.order))] + neck_parts
register("downdog", parts, c.points.values(), [head_c, pt(head_c, HEAD_R, 90)])

# ---- 4. Squat gobelet (homme, haltère) — angles = gen_poses.py pose 3 ----
c = Chain("ankle", (26, 43))
c.add("knee", SHIN, 280, kind='leg')
c.add("hip", THIGH, 210, kind='leg')
c.add("shoulder", TORSO, 307)
c.add("elbow", UPPER_ARM, 85, kind='arm')
c.add("wrist", FOREARM, 320, kind='arm')
toe_f = pt(c.points["ankle"], FOOT, 15)
head_c, neck_parts = head_and_neck_filled(c.points["shoulder"], 307)
parts = [line(c.points["ankle"], toe_f), c.render(skip_joints=set(c.order)),
         dumbbell(c.points["wrist"], angle_deg=90)] + neck_parts
w = c.points["wrist"]
register("goblet_squat", parts, c.points.values(),
         [head_c, toe_f, pt(head_c, HEAD_R, 270), (w[0] - 5, w[1] - 5), (w[0] + 5, w[1] + 5)])

# ---- 5. Deadlift (homme, barre) — angles = gen_poses.py pose 4 ----
c = Chain("ankle", (16, 43))
c.add("knee", SHIN, 285, kind='leg')
c.add("hip", THIGH, 220, kind='leg')
c.add("shoulder", TORSO, 315)
c.add("elbow", UPPER_ARM, 75, kind='arm')
c.add("wrist", FOREARM, 75, kind='arm')
toe_f = pt(c.points["ankle"], FOOT, 10)
head_c, neck_parts = head_and_neck_filled(c.points["shoulder"], 315)
bar = c.points["wrist"]
parts = [line(c.points["ankle"], toe_f), c.render(skip_joints=set(c.order)),
         bar_fixed(bar[0] - 7, bar[0] + 7, bar[1]),
         f'<circle cx="{bar[0]-7:.1f}" cy="{bar[1]:.1f}" r="4.2" fill="#1F6FEB"/>',
         f'<circle cx="{bar[0]+7:.1f}" cy="{bar[1]:.1f}" r="4.2" fill="#1F6FEB"/>'] + neck_parts
register("deadlift", parts, c.points.values(),
         [head_c, toe_f, pt(head_c, HEAD_R, 270), (bar[0] - 7, bar[1] - 4), (bar[0] + 7, bar[1] + 4)])

# ============================================================
# POSITIONS DE DÉPART (retour Sophie 07-11) : chaque mouvement
# se présente en PAIRE départ → position clé. Départ toujours
# DEBOUT DROIT (ou allongé/assis à plat pour les exos au sol).
# ============================================================

# ---- Départ debout neutre (femme) — tadasana, bras le long ----
c = Chain("ankle", (40, 43))
c.add("knee", SHIN, 270, kind='leg')
c.add("hip", THIGH, 270, kind='leg')
c.add("shoulder", TORSO, 270)
c.add_arm("", 100, 100, from_name="shoulder")
toe_f = pt(c.points["ankle"], FOOT, 15)
head_c, neck_parts = head_and_neck_filled(c.points["shoulder"], 270)
parts = [line(c.points["ankle"], toe_f), c.render(skip_joints=set(c.order))] + neck_parts
register("start_stand", parts, c.points.values(), [head_c, toe_f, pt(head_c, HEAD_R, 270)])

# ---- Départ allongée ventre à plat (femme) — pour cobra : mains sous les épaules ----
c = Chain("hip", (46, 40))
c.add("knee", THIGH, 355, from_name="hip", kind='leg')
c.add("ankle", SHIN, 355, kind='leg')
c.add("toe", FOOT, 345, kind='leg')
c.add("shoulder", TORSO, 184, from_name="hip")   # tronc à plat au sol
c.add("elbow", UPPER_ARM, 150, from_name="shoulder", kind='arm')  # coude replié près du corps
c.add("wrist", FOREARM, 210, kind='arm')          # main posée sous l'épaule
head_c, neck_parts = head_and_neck_filled(c.points["shoulder"], 190)
parts = [c.render(skip_joints=set(c.order))] + neck_parts
register("start_prone", parts, c.points.values(), [head_c, pt(head_c, HEAD_R, 270)])

# ---- Départ debout haltère devant la poitrine (homme) — goblet ----
c = Chain("ankle", (40, 43))
c.add("knee", SHIN, 270, kind='leg')
c.add("hip", THIGH, 270, kind='leg')
c.add("shoulder", TORSO, 270)
c.add("elbow", UPPER_ARM, 85, kind='arm')
c.add("wrist", FOREARM, 320, kind='arm')
toe_f = pt(c.points["ankle"], FOOT, 15)
head_c, neck_parts = head_and_neck_filled(c.points["shoulder"], 270)
parts = [line(c.points["ankle"], toe_f), c.render(skip_joints=set(c.order)),
         dumbbell(c.points["wrist"], angle_deg=90)] + neck_parts
w = c.points["wrist"]
register("start_stand_dumbbell", parts, c.points.values(),
         [head_c, toe_f, pt(head_c, HEAD_R, 270), (w[0] - 5, w[1] - 5), (w[0] + 5, w[1] + 5)])

# ---- Départ debout barre en mains aux cuisses (homme) — deadlift ----
c = Chain("ankle", (40, 43))
c.add("knee", SHIN, 270, kind='leg')
c.add("hip", THIGH, 270, kind='leg')
c.add("shoulder", TORSO, 270)
c.add("elbow", UPPER_ARM, 95, kind='arm')   # bras le long, barre aux cuisses
c.add("wrist", FOREARM, 95, kind='arm')
toe_f = pt(c.points["ankle"], FOOT, 15)
head_c, neck_parts = head_and_neck_filled(c.points["shoulder"], 270)
bar = c.points["wrist"]
parts = [line(c.points["ankle"], toe_f), c.render(skip_joints=set(c.order)),
         bar_fixed(bar[0] - 7, bar[0] + 7, bar[1]),
         f'<circle cx="{bar[0]-7:.1f}" cy="{bar[1]:.1f}" r="4.2" fill="#1F6FEB"/>',
         f'<circle cx="{bar[0]+7:.1f}" cy="{bar[1]:.1f}" r="4.2" fill="#1F6FEB"/>'] + neck_parts
register("start_stand_barbell", parts, c.points.values(),
         [head_c, toe_f, pt(head_c, HEAD_R, 270), (bar[0] - 7, bar[1] - 4), (bar[0] + 7, bar[1] + 4)])


# ---- Départ allongée sur le dos (savasana, lot3) — kontext échoue 3× sur "sur le dos" ----
c = Chain("hip", (46, 30))
c.add("shoulder", TORSO, 180)
c.add("knee", THIGH, 5, from_name="hip", kind='leg')
c.add("ankle", SHIN, 5, kind='leg')
c.add("toe", FOOT, 350, kind='leg')
c.add_arm("", 120, 200, from_name="shoulder")
head_c, neck_parts = head_and_neck_filled(c.points["shoulder"], 180)
parts = [c.render(skip_joints=set(c.order))] + neck_parts
register("start_supine", parts, c.points.values(), [head_c, pt(head_c, HEAD_R, 270)])

# ---- Départ quadrupède (table neutre, lot4) — kontext échoue 3× sur "genoux au sol" ----
c = Chain("hip", (46, 20))
c.add("shoulder", TORSO, 5)
c.add("elbow", UPPER_ARM, 135, from_name="shoulder", kind='arm')
c.add("hand", FOREARM, 135, kind='arm')
c.add("knee", THIGH, 95, from_name="hip", kind='leg')
c.add("ankle", SHIN, 180, from_name="knee", kind='leg')
c.add("toe", FOOT, 185, kind='leg')
head_c, neck_parts = head_and_neck_filled(c.points["shoulder"], 60)
parts = [c.render(skip_joints=set(c.order))] + neck_parts
register("start_tabletop", parts, c.points.values(), [head_c, pt(head_c, HEAD_R, 90)])


# ---- Rendu : SVG carré centré (marge 18%) + PNG 1024 fond blanc ----
# Ligne de SOL PLEINE sous le point le plus bas : le lineart sans sol laisse le
# modèle improviser l'ancrage (jambe arrière de Warrior1 lue "levée" → danseuse,
# constaté round 1-2). Trait continu pleine largeur, le modèle le lit ombre/sol.
for slug, inner, pts in CONTROLS:
    xs = [p[0] for p in pts]
    ys = [p[1] for p in pts]
    w, h = max(xs) - min(xs), max(ys) - min(ys)
    side = max(w, h) * 1.36  # marge ~18% de chaque côté du grand axe
    cx, cy = (min(xs) + max(xs)) / 2, (min(ys) + max(ys)) / 2
    ground_y = max(ys) + 1.2
    vb = f"{cx - side / 2:.2f} {cy - side / 2:.2f} {side:.2f} {side:.2f}"
    svg = (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="{vb}" '
           f'stroke-linecap="round" stroke-linejoin="round">'
           f'<rect x="{cx - side / 2:.2f}" y="{cy - side / 2:.2f}" width="{side:.2f}" height="{side:.2f}" fill="#ffffff"/>'
           f'<line x1="{cx - side / 2 + side * 0.06:.2f}" y1="{ground_y:.2f}" x2="{cx + side / 2 - side * 0.06:.2f}" y2="{ground_y:.2f}" '
           f'stroke="#555555" stroke-width="1.4"/>'
           f'{inner}</svg>')
    svg_path = f"{OUT}/{slug}_control.svg"
    png_path = f"{OUT}/{slug}_control.png"
    with open(svg_path, "w") as f:
        f.write(svg)
    subprocess.run(["rsvg-convert", "-w", "1024", "-h", "1024", svg_path, "-o", png_path], check=True)
    print(f"OK — {png_path}")


