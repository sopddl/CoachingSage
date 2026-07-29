import math
import pathlib
import re
import subprocess

from PIL import Image

import posture_rig as PR
from posture_rig import Chain, head_and_neck, bounds_check
from rig import pt, line, HEAD_R, NECK, UPPER_ARM, FOREARM, HAND, TORSO, THIGH, SHIN, FOOT

# VAGUE 4 — contrôles pour « le reste des exos » (à-revoir + gelés faisables).
# Voie validée par le pilote : contrôle lineart propre (tête PLEINE, sol PLEIN,
# pas de ronds d'articulation) → FLUX-canny-pro. Nouveauté : l'ÉQUIPEMENT
# (barre fixe, colonne câble, banc, box, mur) est DESSINÉ dans le contrôle —
# kontext ne savait pas les inventer, canny les suivra.

OUT = pathlib.Path("ai-explo/vague4")
OUT.mkdir(exist_ok=True)
GROUND_Y = 44
VB_W = 64  # assez large pour les scènes équipées, sans écraser le personnage

E = "#1a1a1a"  # tout en noir : canny ne voit que les bords


def eq_line(a, b, w=3.2):
    return line(a, b, color=E, w=w)


def eq_rect(x, y, w, h, rx=0.7, fill=True):
    f = E if fill else "none"
    s = "" if fill else f' stroke="{E}" stroke-width="1.6"'
    return f'<rect x="{x:.1f}" y="{y:.1f}" width="{w:.1f}" height="{h:.1f}" rx="{rx}" fill="{f}"{s}/>'


def eq_circle(c, r, fill=True):
    f = E if fill else "none"
    s = "" if fill else f' stroke="{E}" stroke-width="1.8"'
    return f'<circle cx="{c[0]:.1f}" cy="{c[1]:.1f}" r="{r}" fill="{f}"{s}/>'


def cable(a, b):
    return line(a, b, color=E, w=0.9)


def dumbbell(center, angle_deg=0):
    """Haltère propre : manche + 2 têtes perpendiculaires."""
    h1 = pt(center, 2.6, angle_deg)
    h2 = pt(center, 2.6, angle_deg + 180)
    parts = [line(h1, h2, color=E, w=1.1)]
    for hc in (h1, h2):
        pa = pt(hc, 2.6, angle_deg + 90)
        pb = pt(hc, 2.6, angle_deg - 90)
        parts.append(line(pa, pb, color=E, w=2.4))
    return "".join(parts)


def filled_head(chain_shoulder, angle_deg):
    """Tête pleine (fix planche v1) + cou."""
    neck_end = pt(chain_shoulder, NECK, angle_deg)
    hc = pt(chain_shoulder, NECK + HEAD_R, angle_deg)
    return hc, (line(chain_shoulder, neck_end, w=2.2)
                + f'<circle cx="{hc[0]:.2f}" cy="{hc[1]:.2f}" r="{HEAD_R}" fill="{E}"/>')


POSES = {}


def pose(fn):
    POSES[fn.__name__.replace("_", "-")] = fn
    return fn


# ---------- gainage / sol ----------

@pose
def plank():
    sh = (46, 27.5)
    c = Chain("sh", sh)
    c.add_arm("r", 90, 90)                      # bras verticaux, mains sous épaules
    c.add("hip", TORSO, 162, from_name="sh")
    c.add_leg("r", 162, 162, 105, from_name="hip")
    hc, hd = filled_head(sh, 342)
    return c, hd, "", [c.points["rwrist"], c.points["rtoe"]]


@pose
def pushup():
    sh = (46, 36)
    c = Chain("sh", sh)
    c.add("relbow", UPPER_ARM, 205, from_name="sh")     # coude plié pointant derrière-haut
    c.add("rwrist", FOREARM, 72)                        # avant-bras redescend au sol
    c.add("rhand", HAND, 88)
    c.add("hip", TORSO, 170, from_name="sh")
    c.add_leg("r", 170, 170, 30, from_name="hip")
    hc, hd = filled_head(sh, 350)
    return c, hd, "", [c.points["rhand"], c.points["rtoe"]]


@pose
def glute_bridge():
    # sur le dos : tête/épaules au sol, bassin levé, genoux pliés pieds à plat
    sh = (16, 42)
    c = Chain("sh", sh)
    c.add("hip", TORSO, -26, from_name="sh")            # tronc en pente vers bassin haut
    c.add("rknee", THIGH, 335, from_name="hip")         # cuisse continue de monter vers le genou
    c.add("rankle", SHIN, 95)                           # tibia redescend quasi vertical
    c.add("rtoe", FOOT, 10)
    c.add_arm("r", 8, 2, from_name="sh")                # bras posé au sol vers l'avant
    hc, hd = filled_head(sh, 178)                        # tête posée au sol
    return c, hd, "", [sh, c.points["rtoe"]]


@pose
def dead_bug():
    # sur le dos : bras vertical, une jambe pliée 90/90, l'autre tendue basse
    sh = (22, 41)
    c = Chain("sh", sh)
    c.add("hip", TORSO, 2, from_name="sh")
    c.add("rknee", THIGH, 285, from_name="hip")          # cuisse verticale
    c.add("rankle", SHIN, 10)                            # tibia horizontal (90/90)
    c.add("rtoe", FOOT, 15)
    c.add("lknee", THIGH, 340, from_name="hip")          # jambe tendue basse
    c.add("lankle", SHIN, 348)
    c.add("ltoe", FOOT, 340)
    c.add_arm("r", 272, 268, from_name="sh")             # bras tendu vertical
    hc, hd = filled_head(sh, 182)
    return c, hd, "", [sh, c.points["hip"]]


# ---------- charnières / barre ----------

@pose
def rdl_dumbbell():
    hip = (30, 22)
    c = Chain("hip", hip)
    c.add("sh", TORSO, 322, from_name="hip")             # dos PLAT ~40°
    c.add("rknee", THIGH, 96, from_name="hip")           # genoux à peine fléchis
    c.add("rankle", SHIN, 86)
    c.add("rtoe", FOOT, 5)
    c.add_arm("r", 90, 88, from_name="sh")               # bras pendus
    hc, hd = filled_head(c.points["sh"], 322)            # tête dans l'axe du dos
    eq = dumbbell(pt(c.points["rwrist"], 1.5, 90), 0)
    return c, hd, eq, [c.points["rtoe"]]


@pose
def bentover_row():
    hip = (30, 24)
    c = Chain("hip", hip)
    c.add("sh", TORSO, 320, from_name="hip")
    c.add("rknee", THIGH, 96, from_name="hip")
    c.add("rankle", SHIN, 86)
    c.add("rtoe", FOOT, 5)
    c.add("relbow", UPPER_ARM, 205, from_name="sh")      # coude tiré derrière-haut
    c.add("rwrist", FOREARM, 55)                         # avant-bras vers la barre sous le buste
    hc, hd = filled_head(c.points["sh"], 320)
    w = c.points["rwrist"]
    eq = eq_line((w[0] - 4, w[1]), (w[0] + 4, w[1])) + \
         f'<rect x="{w[0]+3.4:.1f}" y="{w[1]-3:.1f}" width="1.8" height="6" rx="0.6" fill="{E}"/>'
    return c, hd, eq, [c.points["rtoe"]]


@pose
def kb_swing():
    hip = (28, 23)
    c = Chain("hip", hip)
    c.add("sh", TORSO, 318, from_name="hip")
    c.add("rknee", THIGH, 98, from_name="hip")
    c.add("rankle", SHIN, 84)
    c.add("rtoe", FOOT, 5)
    c.add_arm("r", 40, 38, from_name="sh")               # bras tendus vers l'avant-haut
    hc, hd = filled_head(c.points["sh"], 318)
    w = c.points["rwrist"]
    kb = pt(w, 3.0, 40)
    eq = eq_circle(kb, 2.6) + cable(w, kb)
    return c, hd, eq, [c.points["rtoe"]]


# ---------- debout ----------

@pose
def calf_raise():
    # debout droit, talons levés : chevilles au-dessus du sol, pointes au sol
    ankle = (30, 40.5)
    c = Chain("rankle", ankle)
    c.add("rtoe", FOOT, 45)                              # pied incliné, pointe au sol
    c.add("rknee", SHIN, 273, from_name="rankle")
    c.add("hip", THIGH, 272)
    c.add("sh", TORSO, 270)
    c.add_arm("r", 92, 90, from_name="sh")
    hc, hd = filled_head(c.points["sh"], 270)
    return c, hd, "", [c.points["rtoe"]]


@pose
def wall_sit():
    # mur = trait vertical épais ; dos collé, cuisses horizontales
    wall_x = 42
    hip = (38.5, 33)
    c = Chain("hip", hip)
    c.add("sh", TORSO, 270, from_name="hip")             # dos vertical contre mur
    c.add("rknee", THIGH, 180, from_name="hip")          # cuisse horizontale vers l'avant
    c.add("rankle", SHIN, 90)                            # tibia vertical
    c.add("rtoe", FOOT, 175)
    c.add_arm("r", 95, 92, from_name="sh")
    hc, hd = filled_head(c.points["sh"], 270)
    eq = eq_line((wall_x, 4), (wall_x, GROUND_Y), w=2.6)
    return c, hd, eq, [c.points["rtoe"]]


@pose
def box_jump():
    # box pleine largeur perso ; réception fléchie DEUX pieds au centre
    box_x0, box_x1, box_top = 20, 44, 31
    hip = (32, 17)
    c = Chain("hip", hip)
    c.add("sh", TORSO, 288, from_name="hip")             # buste légèrement penché
    c.add("rknee", THIGH, 55, from_name="hip")           # genoux fléchis
    c.add("rankle", SHIN, 118)
    c.add("rtoe", FOOT, 175)
    c.add_arm("r", 30, 5, from_name="sh")                # bras tendus devant (équilibre)
    hc, hd = filled_head(c.points["sh"], 288)
    eq = eq_rect(box_x0, box_top, box_x1 - box_x0, GROUND_Y - box_top, fill=False)
    return c, hd, eq, []


@pose
def nordic_curl():
    # à genoux, chevilles ancrées sous une barre, corps incliné 30° genoux→tête
    knee = (30, 40.5)
    c = Chain("rknee", knee)
    c.add("rankle", SHIN, 178, from_name="rknee")        # tibia à plat au sol
    c.add("rtoe", FOOT, 182)
    c.add("hip", THIGH, 300, from_name="rknee")          # corps incliné vers l'avant
    c.add("sh", TORSO, 300)
    c.add("relbow", UPPER_ARM, 55, from_name="sh")       # bras croisés poitrine (stub plié)
    c.add("rwrist", FOREARM, 160)
    hc, hd = filled_head(c.points["sh"], 300)
    a = c.points["rankle"]
    eq = eq_rect(a[0] - 3, a[1] - 3.4, 6, 2.2)           # boudin d'ancrage sur chevilles
    return c, hd, eq, [c.points["rtoe"]]


# ---------- suspension / appuis ----------

@pose
def pullup():
    bar_y = 7
    c = Chain("rwrist", (32, bar_y))
    c.add("relbow", FOREARM, 115, from_name="rwrist")    # coude plié (traction haute)
    c.add("sh", UPPER_ARM, 100, from_name="relbow")
    c.add("hip", TORSO, 92, from_name="sh")
    c.add("rknee", THIGH, 130, from_name="hip")          # genoux pliés
    c.add("rankle", SHIN, 210)                           # pieds remontés derrière
    c.add("rtoe", FOOT, 150)
    hc, hd = filled_head(c.points["sh"], 275)            # menton vers la barre
    eq = eq_line((10, bar_y), (54, bar_y)) + eq_line((12, bar_y), (12, GROUND_Y), w=2.2) \
         + eq_line((52, bar_y), (52, GROUND_Y), w=2.2)
    return c, hd, eq, []


@pose
def hanging_leg_raise():
    bar_y = 6
    c = Chain("rwrist", (30, bar_y))
    c.add("relbow", FOREARM, 92, from_name="rwrist")     # bras tendus
    c.add("sh", UPPER_ARM, 90, from_name="relbow")
    c.add("hip", TORSO, 88, from_name="sh")
    c.add("rknee", THIGH, 5, from_name="hip")            # jambes tendues horizontales
    c.add("rankle", SHIN, 2)
    c.add("rtoe", FOOT, 30)
    hc, hd = filled_head(c.points["sh"], 268)
    eq = eq_line((8, bar_y), (52, bar_y)) + eq_line((10, bar_y), (10, GROUND_Y), w=2.2)
    return c, hd, eq, []


@pose
def dips():
    sh = (30, 16)
    c = Chain("sh", sh)
    c.add_arm("r", 88, 86, from_name="sh")               # bras tendus verrouillés
    c.add("hip", TORSO, 94, from_name="sh")
    c.add("rknee", THIGH, 125, from_name="hip")
    c.add("rankle", SHIN, 205)                           # pieds remontés derrière, décollés
    c.add("rtoe", FOOT, 150)
    hc, hd = filled_head(sh, 270)
    w = c.points["rwrist"]                               # barre À la main
    eq = eq_line((w[0] - 7, w[1]), (w[0] + 7, w[1])) + \
         eq_line((w[0] - 6, w[1]), (w[0] - 6, GROUND_Y), w=2.2) + \
         eq_line((w[0] + 6, w[1]), (w[0] + 6, GROUND_Y), w=2.2)
    return c, hd, eq, []


# ---------- câble / machines ----------

@pose
def pallof_press():
    col_x = 56
    hip = (24, 23)
    c = Chain("hip", hip)
    c.add("sh", TORSO, 270, from_name="hip")
    c.add("rknee", THIGH, 92, from_name="hip")
    c.add("rankle", SHIN, 88)
    c.add("rtoe", FOOT, 5)
    c.add_arm("r", 20, 0, from_name="sh")                # bras tendus horizontaux devant
    hc, hd = filled_head(c.points["sh"], 270)
    w = c.points["rwrist"]
    eq = eq_line((col_x, 4), (col_x, GROUND_Y), w=3.0) + cable(w, (col_x, w[1]))
    return c, hd, eq, [c.points["rtoe"]]


@pose
def triceps_pushdown():
    col_x = 50
    hip = (26, 23)
    c = Chain("hip", hip)
    c.add("sh", TORSO, 272, from_name="hip")
    c.add("rknee", THIGH, 92, from_name="hip")
    c.add("rankle", SHIN, 88)
    c.add("rtoe", FOOT, 5)
    c.add("relbow", UPPER_ARM, 100, from_name="sh")      # coude au corps
    c.add("rwrist", FOREARM, 30)                         # avant-bras poussant bas-avant
    hc, hd = filled_head(c.points["sh"], 272)
    w = c.points["rwrist"]
    eq = (eq_line((col_x, 4), (col_x, GROUND_Y), w=3.0)
          + eq_line((w[0] - 3.5, w[1]), (w[0] + 3.5, w[1]), w=2.2)   # petite barre
          + cable((w[0], w[1]), (col_x, 6)))
    return c, hd, eq, [c.points["rtoe"]]


@pose
def facepull():
    col_x = 52
    hip = (22, 23)
    c = Chain("hip", hip)
    c.add("sh", TORSO, 272, from_name="hip")
    c.add("rknee", THIGH, 92, from_name="hip")
    c.add("rankle", SHIN, 88)
    c.add("rtoe", FOOT, 5)
    c.add("relbow", UPPER_ARM, 10, from_name="sh")       # coude haut, tirage au visage
    c.add("rwrist", FOREARM, 350)
    hc, hd = filled_head(c.points["sh"], 272)
    w = c.points["rwrist"]
    eq = eq_line((col_x, 4), (col_x, GROUND_Y), w=3.0) + cable(w, (col_x, w[1] - 2))
    return c, hd, eq, [c.points["rtoe"]]


@pose
def cable_row():
    col_x = 54
    hip = (22, 33)
    c = Chain("hip", hip)
    c.add("sh", TORSO, 275, from_name="hip")
    c.add("rknee", THIGH, 8, from_name="hip")            # jambes devant, genoux souples
    c.add("rankle", SHIN, 30)
    c.add("rtoe", FOOT, 320)
    c.add("relbow", UPPER_ARM, 105, from_name="sh")      # coude tiré derrière
    c.add("rwrist", FOREARM, 15)
    hc, hd = filled_head(c.points["sh"], 275)
    w = c.points["rwrist"]
    eq = (eq_line((col_x, 20), (col_x, GROUND_Y), w=3.0)
          + cable(w, (col_x, w[1])) + eq_rect(16, 36.5, 8, 1.8))     # petit banc
    return c, hd, eq, [c.points["rtoe"]]


@pose
def lat_pulldown():
    bar_y = 9
    hip = (30, 30)
    c = Chain("hip", hip)
    c.add("sh", TORSO, 272, from_name="hip")
    c.add("rknee", THIGH, 5, from_name="hip")            # assis, cuisses horizontales
    c.add("rankle", SHIN, 88)
    c.add("rtoe", FOOT, 175)
    c.add("relbow", UPPER_ARM, 200, from_name="sh")      # coudes tirés vers le bas
    c.add("rwrist", FOREARM, 285)                        # mains en haut sur la barre
    hc, hd = filled_head(c.points["sh"], 272)
    w = c.points["rwrist"]
    knee = c.points["rknee"]
    eq = (eq_line((w[0] - 8, w[1]), (w[0] + 8, w[1]), w=2.2)         # barre large
          + cable(((w[0]), w[1]), (w[0] + 2, bar_y)) + eq_line((w[0] - 2, bar_y), (w[0] + 6, bar_y))
          + eq_rect(hip[0] - 5, hip[1] + 4.5, 10, 1.8)               # assise
          + eq_rect(knee[0] - 2.5, knee[1] - 4.2, 5, 1.6))           # boudin genoux
    return c, hd, eq, [c.points["rtoe"]]


@pose
def leg_extension():
    # assis machine, tibia tendu devant avec boudin à la cheville
    hip = (26, 28)
    c = Chain("hip", hip)
    c.add("sh", TORSO, 268, from_name="hip")
    c.add("rknee", THIGH, 5, from_name="hip")
    c.add("rankle", SHIN, 340)                           # tibia tendu devant-haut
    c.add("rtoe", FOOT, 300)
    c.add_arm("r", 80, 95, from_name="sh")               # mains sur poignées bas
    hc, hd = filled_head(c.points["sh"], 268)
    a = c.points["rankle"]
    eq = (eq_rect(hip[0] - 6, hip[1] + 4.5, 12, 2)                    # siège
          + eq_line((hip[0] - 6, hip[1] + 6.5), (hip[0] - 6, GROUND_Y), w=2.6)
          + eq_circle(pt(a, 1.8, 60), 1.6, fill=False))               # boudin cheville
    return c, hd, eq, []


@pose
def leg_curl():
    # allongé ventre sur banc, talons remontés (flexion) — banc = boîte
    bench_y = 30
    hip = (30, bench_y - 1.5)
    c = Chain("hip", hip)
    c.add("sh", TORSO, 178, from_name="hip")             # buste à plat sur le banc
    c.add("rknee", THIGH, 2, from_name="hip")
    c.add("rankle", SHIN, 285)                           # tibia remonté vertical
    c.add("rtoe", FOOT, 300)
    c.add("relbow", UPPER_ARM, 195, from_name="sh")      # bras plié sous le buste
    c.add("rwrist", FOREARM, 150)
    hc, hd = filled_head(c.points["sh"], 178)
    a = c.points["rankle"]
    eq = (eq_rect(12, bench_y, 32, 2.2)
          + eq_line((16, bench_y + 2), (16, GROUND_Y), w=2.2)
          + eq_line((40, bench_y + 2), (40, GROUND_Y), w=2.2)
          + eq_circle(pt(a, 1.9, 30), 1.6, fill=False))
    return c, hd, eq, []


@pose
def bench_press():
    bench_y = 31
    sh = (26, bench_y - 1.5)
    c = Chain("sh", sh)
    c.add("hip", TORSO, 2, from_name="sh")               # allongé sur le banc
    c.add("rknee", THIGH, 22, from_name="hip")           # genoux pliés, pieds au sol
    c.add("rankle", SHIN, 62)
    c.add("rtoe", FOOT, 5)
    c.add_arm("r", 272, 270, from_name="sh")             # bras tendus verticaux
    hc, hd = filled_head(sh, 182)                         # tête posée sur le banc
    w = c.points["rwrist"]
    eq = (eq_rect(12, bench_y, 26, 2.2)
          + eq_line((15, bench_y + 2), (15, GROUND_Y), w=2.2)
          + eq_line((34, bench_y + 2), (34, GROUND_Y), w=2.2)
          + eq_line((w[0] - 7, w[1]), (w[0] + 7, w[1]), w=2.6)        # barre
          + f'<rect x="{w[0]+6:.1f}" y="{w[1]-3.2:.1f}" width="1.9" height="6.4" rx="0.6" fill="{E}"/>')
    return c, hd, eq, [c.points["rtoe"]]


@pose
def hip_thrust():
    bench_y = 29
    sh = (18, bench_y - 1)
    c = Chain("sh", sh)
    c.add("hip", TORSO, 8, from_name="sh")               # hanches hautes alignées
    c.add("rknee", THIGH, 18, from_name="hip")
    c.add("rankle", SHIN, 78)
    c.add("rtoe", FOOT, 5)
    hc, hd = filled_head(sh, 240)                         # tête/haut du dos sur banc
    hip = c.points["hip"]
    eq = (eq_rect(8, bench_y, 12, 2.2)
          + eq_line((10, bench_y + 2), (10, GROUND_Y), w=2.2)
          + eq_line((18, bench_y + 2), (18, GROUND_Y), w=2.2)
          + eq_line((hip[0] - 7, hip[1] - 1.5), (hip[0] + 7, hip[1] - 1.5), w=2.6)   # barre sur bassin
          + f'<rect x="{hip[0]+6:.1f}" y="{hip[1]-4.6:.1f}" width="1.9" height="6.4" rx="0.6" fill="{E}"/>')
    return c, hd, eq, [c.points["rtoe"]]


def render(name, chain, head_svg, eq_svg, ground_pts):
    inner = chain.render(skip_joints=set(chain.order)) + head_svg + eq_svg
    inner += f'<line x1="3" y1="{GROUND_Y}" x2="{VB_W - 3}" y2="{GROUND_Y}" stroke="#555555" stroke-width="1.2"/>'
    svg = (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {VB_W} 48" '
           f'stroke-linecap="round" stroke-linejoin="round">'
           f'<rect x="0" y="0" width="{VB_W}" height="48" fill="#ffffff"/>{inner}</svg>')
    p = OUT / f"{name}_control.svg"
    p.write_text(svg)
    tmp = OUT / f"{name}_raw.png"
    subprocess.run(["rsvg-convert", "-w", "1024", str(p), "-o", str(tmp)], check=True)
    im = Image.open(tmp).convert("RGB")
    side = max(im.size)
    sq = Image.new("RGB", (side, side), "white")
    sq.paste(im, ((side - im.width) // 2, (side - im.height) // 2))
    sq.resize((1024, 1024)).save(OUT / f"{name}_control.png")
    tmp.unlink()
    ok = bounds_check(name, list(chain.points.values()), margin=3)
    for gp in ground_pts:
        if abs(gp[1] - GROUND_Y) > 2.5:
            print(f"  ⚠ {name}: point d'appui à y={gp[1]:.1f} (sol {GROUND_Y})")
    return ok


# ---------- extraction yoga depuis les lots (recette vague3) ----------

YOGA_FIGS = {
    "butterfly": ("lot2.html", "BaddhaKonasana"),
    "head-to-knee": ("lot9.html", "JanuSirsasana"),
    "child": ("lot6.html", "Child"),
    "bird-dog": ("lot10.html", "BirdDog"),
}


def clean_svg(svg):
    svg = re.sub(r'<circle[^>]*r="1\.5"[^>]*/>', "", svg)
    svg = re.sub(r'<[^>]*stroke-dasharray[^>]*/>', "", svg)
    svg = re.sub(r'<path[^>]*stroke="#8a8a8a"[^>]*/>', "", svg)
    svg = re.sub(r'<line[^>]*stroke="#e8a93d"[^>]*/>', "", svg)
    svg = svg.replace('r="3.0" fill="none"', 'r="3.0" fill="#1a1a1a"')
    return svg


def extract_yoga():
    for slug, (html_file, fig) in YOGA_FIGS.items():
        dest = OUT / f"{slug}_control.png"
        if dest.exists():
            continue
        html = pathlib.Path(html_file).read_text()
        svg = None
        for m in re.finditer(r'<figure>(.*?)</figure>', html, re.S):
            t = re.search(r'<figcaption><b>([^<]+)</b>', m.group(1))
            s = re.search(r'(<svg.*?</svg>)', m.group(1), re.S)
            if t and s and t.group(1) == fig:
                svg = clean_svg(s.group(1))
                break
        if not svg:
            print(f"MANQUE {slug} ({fig} pas dans {html_file})")
            continue
        vb = re.search(r'viewBox="([\d\.\s-]+)"', svg)
        x0, y0, w, h = map(float, vb.group(1).split())
        ys = [float(v) for v in re.findall(r'[ML](?:[\d\.-]+),([\d\.-]+)', svg)]
        gy = min(max(ys) + 1.5, y0 + h - 0.5) if ys else y0 + h - 2
        inner = re.sub(r'^<svg[^>]*>', "", svg).rsplit("</svg>", 1)[0]
        full = (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="{x0} {y0} {w} {h}" '
                f'stroke-linecap="round" stroke-linejoin="round">'
                f'<rect x="{x0}" y="{y0}" width="{w}" height="{h}" fill="#ffffff"/>'
                f'<line x1="{x0 + 2}" y1="{gy:.1f}" x2="{x0 + w - 2}" y2="{gy:.1f}" '
                f'stroke="#555555" stroke-width="1.2"/>{inner}</svg>')
        sp = OUT / f"{slug}_control.svg"
        sp.write_text(full)
        tmp = OUT / f"{slug}_raw.png"
        subprocess.run(["rsvg-convert", "-w", "1024", str(sp), "-o", str(tmp)], check=True)
        im = Image.open(tmp).convert("RGB")
        side = max(im.size)
        sq = Image.new("RGB", (side, side), "white")
        sq.paste(im, ((side - im.width) // 2, (side - im.height) // 2))
        sq.resize((1024, 1024)).save(dest)
        tmp.unlink()
        print(f"OK — contrôle yoga {slug}")


if __name__ == "__main__":
    for name, fn in POSES.items():
        c, hd, eq, gpts = fn()
        render(name, c, hd, eq, gpts)
    extract_yoga()
    # feuille de contact des contrôles
    pngs = sorted(OUT.glob("*_control.png"))
    cols = 5
    rows = (len(pngs) + cols - 1) // cols
    sheet = Image.new("RGB", (cols * 256, rows * 256), "white")
    from PIL import ImageDraw
    d = ImageDraw.Draw(sheet)
    for i, p in enumerate(pngs):
        im = Image.open(p).resize((256, 256))
        sheet.paste(im, ((i % cols) * 256, (i // cols) * 256))
        d.text(((i % cols) * 256 + 6, (i // cols) * 256 + 4), p.stem.replace("_control", ""), fill="#c00")
    sheet.save(OUT / "_controls_sheet.png")
    print(f"{len(pngs)} contrôles — feuille _controls_sheet.png")
