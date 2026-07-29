import math
from rig import (
    pt, dist, fmt, line, joint,
    HEAD_R, NECK, UPPER_ARM, FOREARM, HAND, TORSO, THIGH, SHIN, FOOT,
    STROKE, JOINT_R, JOINT_STROKE, COL_BODY, COL_KEY,
)

def ground(y=44):
    """Sol pointillé — override de rig.ground() : celui de rig.py s'arrête à x=44
    (pensé pour le viewBox carré 48 de la muscu). Ici le viewBox fait 80 de large,
    donc une pose positionnée dans la moitié droite (x>44, fréquent) se retrouvait
    SANS sol visible dessous. Toujours pleine largeur ici."""
    return f'<line x1="4" y1="{y}" x2="{VIEWBOX_W - 4}" y2="{y}" stroke="#dcdcdc" stroke-width="1" stroke-dasharray="2,2"/>'

# RÈGLE NON NÉGOCIABLE #2 (retour Sophie) : on ne sait pas quel membre est quoi quand
# la couleur "geste-clé" change de membre d'une pose à l'autre. Fini le orange variable —
# désormais la couleur dépend UNIQUEMENT du TYPE de membre, toujours le même partout :
#   - bras (add_arm)  -> COL_ARM (orange) TOUJOURS, que ce soit le geste-clé ou pas
#   - jambe (add_leg) -> COL_LEG (vert)   TOUJOURS, que ce soit le geste-clé ou pas
#   - tronc/cou/tête  -> COL_BODY (noir)  toujours ; `key=True` sur un segment de tronc
#     construit à la main (pas via add_arm/add_leg) garde le droit à un highlight orange
#     ponctuel (ex: cambrure du dos) — mais jamais sur un bras ou une jambe.
COL_ARM = COL_KEY       # "#c65a37" — orange, réutilisé tel quel, mais maintenant FIXE = bras
COL_LEG = "#3f8f5c"     # vert — nouveau, FIXE = jambe

# RÈGLE NON NÉGOCIABLE (retour Sophie) : les proportions entre articulations et le
# nombre d'articulations doivent être IDENTIQUES sur tous les schémas. Un segment ne
# prend JAMAIS une longueur "à peu près" ou réduite pour faire une pose compacte —
# seuls les ANGLES changent. Une jambe repliée reste une jambe hip->knee->ankle->toe
# de longueurs THIGH/SHIN/FOOT pleines, juste avec des angles serrés qui la replient
# visuellement. `Chain.add()` refuse toute longueur qui n'est pas un de ces chiffres.
CANONICAL_LENGTHS = {UPPER_ARM, FOREARM, HAND, TORSO, THIGH, SHIN, FOOT, NECK + HEAD_R}

# ============================================================
# POSTURE RIG — extension de rig.py pour les poses yoga/core.
# Réutilise EXACTEMENT les mêmes longueurs de segment, la même
# épaisseur de trait, le même style d'articulation et la même
# règle corps->articulation->objet que le rig muscu validé ce
# matin (ne pas réinventer les chiffres, cf rig.py).
#
# Différence : rig.py construit toujours "des pieds vers le
# haut" (debout). Ici on peut démarrer la chaîne depuis N'IMPORTE
# QUEL point (cheville debout, bassin assis, épaule allongé,
# tête/mains inversé, hanche quadrupède) — SEULE la racine et
# les angles changent, jamais les longueurs.
# ============================================================

VIEWBOX_W = 80  # yoga = large frame (poses allongées/écartées), pas le carré 48x48 de la muscu
VIEWBOX_H = 48

def svg_open():
    return f'<svg viewBox="0 0 {VIEWBOX_W} {VIEWBOX_H}" stroke-linecap="round" stroke-linejoin="round">'

def svg_close():
    return "</svg>"

def head(center, stroke=STROKE):
    return f'<circle cx="{center[0]:.2f}" cy="{center[1]:.2f}" r="{HEAD_R}" fill="none" stroke="{COL_BODY}" stroke-width="{stroke}"/>'

def hair_tuft(head_c, away_angle_deg, stroke=STROKE):
    """3 petits traits (cheveux) sur le dessus de la tête, du côté `away_angle_deg`
    (direction OPPOSÉE au regard). Sert à marquer sans ambiguïté "on voit l'arrière du
    crâne" — retour Sophie : sur les poses ventrales (visage vers le sol), rien ne
    distinguait visuellement une tête vue de dos d'une tête vue de face. Ne pas
    utiliser sur les poses où le visage est visible (assis, debout, sur le dos)."""
    parts = []
    for off in (-22, 0, 22):
        base = pt(head_c, HEAD_R * 0.9, away_angle_deg + off)
        tip = pt(head_c, HEAD_R * 1.7, away_angle_deg + off)
        parts.append(line(base, tip, w=stroke * 0.6))
    return "".join(parts)


def head_and_neck(shoulder, angle_deg, stroke=STROKE):
    """Tête+cou dans N'IMPORTE QUELLE direction (généralise rig.py, qui suppose une tête
    toujours verticale au-dessus de l'épaule). `angle_deg` = direction cou->tête.
    Retourne (head_center, [svg_parts])."""
    neck_end = pt(shoulder, NECK, angle_deg)
    head_c = pt(shoulder, NECK + HEAD_R, angle_deg)
    parts = [line(shoulder, neck_end, w=stroke), head(head_c, stroke=stroke)]
    return head_c, parts

def arc_line(p1, p2, bulge, color=COL_BODY, w=None):
    """Segment courbé (bezier quadratique) entre p1 et p2, qui bombe de `bulge`
    unités perpendiculairement au segment droit. Sert UNIQUEMENT à représenter une
    cambrure du dos (backbend) — un trait droit ne peut pas se distinguer d'un pli
    (ForwardFold) ou d'un dos plat (chien tête en bas) à cette échelle ; la courbe,
    elle, se voit sans ambiguïté. `bulge` positif = bombe vers la droite du vecteur
    p1->p2 (choisir le signe pour que ça bombe vers l'extérieur du corps)."""
    w = w if w is not None else STROKE
    mx, my = (p1[0] + p2[0]) / 2, (p1[1] + p2[1]) / 2
    dx, dy = p2[0] - p1[0], p2[1] - p1[1]
    length = math.hypot(dx, dy) or 1
    nx, ny = -dy / length, dx / length  # normale unitaire
    cx, cy = mx + nx * bulge, my + ny * bulge
    return (f'<path d="M{p1[0]:.2f},{p1[1]:.2f} Q{cx:.2f},{cy:.2f} {p2[0]:.2f},{p2[1]:.2f}" '
            f'stroke="{color}" stroke-width="{w}" fill="none" stroke-linecap="round"/>')


COL_MOTION = "#8a8a8a"  # gris — trajectoire de mouvement, jamais confondu avec un membre


def motion_arc(p_from, p_to, bulge, color=COL_MOTION):
    """Flèche de trajectoire en pointillé gris : un point de départ FANTÔME (petit
    rond creux) relié par une courbe en pointillé à un point d'arrivée sur le corps,
    avec une pointe de flèche. Sert à montrer LE MOUVEMENT (ex: les jambes qui
    basculent par-dessus la tête dans Halasana) là où le dessin final, statique, ne
    montre que la position d'arrivée — retour Sophie "faire le mouvement"."""
    mx, my = (p_from[0] + p_to[0]) / 2, (p_from[1] + p_to[1]) / 2
    dx, dy = p_to[0] - p_from[0], p_to[1] - p_from[1]
    length = math.hypot(dx, dy) or 1
    nx, ny = -dy / length, dx / length
    cx, cy = mx + nx * bulge, my + ny * bulge
    ux, uy = dx / length, dy / length
    # pointe de flèche : 2 petits traits en V juste avant p_to
    back = (p_to[0] - ux * 3 + nx * 0, p_to[1] - uy * 3)
    wing = 1.3
    a1 = (back[0] + nx * wing, back[1] + ny * wing)
    a2 = (back[0] - nx * wing, back[1] - ny * wing)
    return (
        f'<circle cx="{p_from[0]:.2f}" cy="{p_from[1]:.2f}" r="1.6" fill="none" stroke="{color}" stroke-width="1" stroke-dasharray="1,1.2"/>'
        f'<path d="M{p_from[0]:.2f},{p_from[1]:.2f} Q{cx:.2f},{cy:.2f} {p_to[0]:.2f},{p_to[1]:.2f}" '
        f'stroke="{color}" stroke-width="1.3" fill="none" stroke-linecap="round" stroke-dasharray="2.2,1.8"/>'
        f'<path d="M{a1[0]:.2f},{a1[1]:.2f} L{p_to[0]:.2f},{p_to[1]:.2f} L{a2[0]:.2f},{a2[1]:.2f}" '
        f'stroke="{color}" stroke-width="1.3" fill="none" stroke-linecap="round" stroke-linejoin="round"/>'
    )


class Chain:
    """Construit UNE chaîne cinématique continue depuis un point racine.
    Chaque segment : (nom_articulation_suivante, longueur, angle_deg, key=False).
    `key=True` colore ce segment en orange (COL_KEY) — LE geste-clé du mouvement,
    annoté à la main par pose, jamais automatique.

    Usage :
        c = Chain("hip", hip_point)
        c.add("knee", THIGH, 210)
        c.add("ankle", SHIN, 260, key=True)
        c.add("toe", FOOT, 220)
        svg_parts = c.render()
        knee_point = c.points["knee"]
    """
    def __init__(self, root_name, root_point, stroke=STROKE, light=False):
        self.points = {root_name: root_point}
        self.order = [root_name]
        self.segments = []  # (from_name, to_name, key, kind)
        self.stroke = stroke * 0.7 if light else stroke  # trait allégé poses compactes/entortillées

    def add(self, name, length, angle_deg, key=False, from_name=None, kind=None):
        if not any(abs(length - L) < 0.01 for L in CANONICAL_LENGTHS):
            raise ValueError(
                f"'{name}' : longueur {length:.2f} n'est pas une longueur canonique "
                f"{sorted(CANONICAL_LENGTHS)}. Une pose compacte se fait par l'ANGLE, "
                f"jamais en raccourcissant un segment (règle Sophie : proportions et "
                f"nombre d'articulations identiques partout)."
            )
        origin_name = from_name or self.order[-1]
        origin = self.points[origin_name]
        p = pt(origin, length, angle_deg)
        self.points[name] = p
        self.order.append(name)
        self.segments.append((origin_name, name, key, kind))
        return p

    def add_leg(self, prefix, thigh_angle, shin_angle, foot_angle, from_name=None, key=False):
        """Jambe COMPLÈTE, toujours les 3 segments (THIGH/SHIN/FOOT pleins) : hanche
        -> genou -> cheville -> pointe. Jamais de version tronquée/raccourcie.
        Couleur TOUJOURS COL_LEG (vert) — `key` n'affecte plus la couleur, gardé pour
        compat mais ignoré ici : une jambe est verte qu'elle soit le geste-clé ou non."""
        self.add(f"{prefix}knee", THIGH, thigh_angle, from_name=from_name, kind='leg')
        self.add(f"{prefix}ankle", SHIN, shin_angle, kind='leg')
        self.add(f"{prefix}toe", FOOT, foot_angle, kind='leg')
        return self.points[f"{prefix}ankle"]

    def add_arm(self, prefix, upper_angle, fore_angle, hand_angle=None, from_name=None, key=False):
        """Bras COMPLET, toujours UPPER_ARM+FOREARM pleins (+ HAND si `hand_angle` fourni) :
        épaule -> coude -> poignet (-> main). Jamais de version tronquée/raccourcie.
        Couleur TOUJOURS COL_ARM (orange) — `key` n'affecte plus la couleur."""
        self.add(f"{prefix}elbow", UPPER_ARM, upper_angle, from_name=from_name, kind='arm')
        self.add(f"{prefix}wrist", FOREARM, fore_angle, kind='arm')
        if hand_angle is not None:
            self.add(f"{prefix}hand", HAND, hand_angle, kind='arm')
        return self.points[f"{prefix}wrist"]

    def render(self, mark_root_joint=True, skip_joints=None, dim_joints=None):
        """`skip_joints` : noms d'articulations à ne PAS marquer d'un rond — désencombre
        un membre d'appui statique (ex: BirdDog, 2 appuis au sol + 2 membres tendus =
        4 chaînes visibles ensemble, trop de ronds = illisible) sans jamais retirer le
        TRAIT (le membre reste dessiné en entier, juste sans son marqueur — la règle du
        nombre d'articulations porte sur la géométrie, pas sur l'affichage des ronds).
        `dim_joints` : noms d'articulations dont le SEGMENT ENTRANT (from_name->name)
        se dessine plus fin — même déclutter, complémentaire à skip_joints : le membre
        d'appui statique recule visuellement (trait fin) pendant que le geste-clé
        (bras+jambe tendus) reste au trait normal. Couleur inchangée (règle bras=orange
        /jambe=vert toujours respectée, seule l'ÉPAISSEUR change)."""
        skip = skip_joints or set()
        dim = dim_joints or set()
        parts = []
        for a, b, key, kind in self.segments:
            if kind == 'arm':
                color = COL_ARM
            elif kind == 'leg':
                color = COL_LEG
            else:
                color = COL_BODY   # tronc/cou/tête : TOUJOURS noir, jamais de highlight —
                # sinon on retombe dans le problème "on ne sait plus ce que la couleur veut dire"
            w = self.stroke * 0.55 if b in dim else self.stroke
            parts.append(line(self.points[a], self.points[b], color=color, w=w))
        joint_names = self.order if mark_root_joint else self.order[1:]
        for n in joint_names:
            if n in skip:
                continue
            parts.append(joint(self.points[n]))
        return "".join(parts)


def bounds_check(name, points, margin=2, min_fill=0.35):
    """Vérifie que TOUS les points sont dans le viewBox (avec marge) — seule condition
    d'échec dur. Le remplissage (bbox vs canvas) est juste informatif : une pose debout
    droite ou allongée à plat est LÉGITIMEMENT fine sur un axe (hauteur=0 ou largeur
    quasi nulle) — ce n'est pas un bug. On alerte seulement si les DEUX axes sont fins
    (max des deux fills < min_fill), signe d'une pose vraiment ratatinée dans un coin."""
    xs = [p[0] for p in points]
    ys = [p[1] for p in points]
    x0, x1, y0, y1 = min(xs), max(xs), min(ys), max(ys)
    errs = []
    if x0 < -margin or x1 > VIEWBOX_W + margin:
        errs.append(f"  x hors cadre : [{x0:.1f}, {x1:.1f}] (viewBox 0-{VIEWBOX_W})")
    if y0 < -margin or y1 > VIEWBOX_H + margin:
        errs.append(f"  y hors cadre : [{y0:.1f}, {y1:.1f}] (viewBox 0-{VIEWBOX_H})")
    w, h = x1 - x0, y1 - y0
    w_fill, h_fill = w / VIEWBOX_W, h / VIEWBOX_H
    if max(w_fill, h_fill) < min_fill:
        errs.append(f"  pose ratatinée sur les 2 axes : bbox {w:.0f}x{h:.0f} sur canvas {VIEWBOX_W}x{VIEWBOX_H}")
    status = "OK" if not errs else "ECART"
    print(f"[{status}] bounds {name} — bbox {w:.0f}x{h:.0f} (remplissage {w_fill:.0%} x {h_fill:.0%})")
    for e in errs:
        print(e)
    return not errs


def held_object_check(name, body_anchor, joint_pt, object_pt):
    """Vérifie la règle CORPS -> ARTICULATION -> OBJET : la distance body_anchor->joint
    doit être < body_anchor->objet (l'articulation est bien ENTRE le corps et l'objet
    tenu, jamais l'inverse — sinon le membre lit comme tordu)."""
    d_joint = dist(body_anchor, joint_pt)
    d_obj = dist(body_anchor, object_pt)
    ok = d_joint < d_obj
    warn = "" if ok else "  <-- objet plus proche du corps que l'articulation, membre tordu"
    print(f"[{'OK' if ok else 'ECART'}] corps->articulation->objet {name} : "
          f"articulation à {d_joint:.1f}, objet à {d_obj:.1f}{warn}")
    return ok


def zoom_inset(body_inner_svg, center, radius=7):
    """Second panneau — MÊME dessin (`body_inner_svg`, le contenu déjà rendu par
    Chain.render() + neck_parts, SANS svg_open/close) mais avec un viewBox minuscule
    cropé sur `center` (ex: la main, le visage, le genou). Le geste-clé (position de
    main sur le ventre/gorge/visage, genou près de l'oreille...) est souvent illisible
    à l'échelle du corps entier dans une icône 220x150 — ce panneau zoome littéralement
    sur la zone qui distingue la pose, sans redessiner : la ligne+articulation qu'on
    voit ici est un CROP de l'original, jamais une reconstruction séparée (donc jamais
    de désync possible entre le corps entier et le zoom)."""
    cx, cy = center
    vb = f"{cx - radius:.1f} {cy - radius:.1f} {radius * 2} {radius * 2}"
    return f'<svg viewBox="{vb}" stroke-linecap="round" stroke-linejoin="round">{body_inner_svg}</svg>'


COL_CONTACT = "#e8a93d"  # jaune/ambre — DÉLIBÉRÉMENT différent de COL_BODY (retour Sophie :
# le trait plein noir se confondait avec le corps, lisible comme "un objet au sol").


def ground_contact(p1, p2, y=None):
    """Trait plein jaune sur le sol, juste sous le segment corporel p1->p2 (typiquement
    hanche->épaule) — indique explicitement QUELLE partie du corps touche le sol. Petites
    barres perpendiculaires aux 2 bouts pour lire comme un MARQUEUR (surlignage), pas
    comme un bout de corps ou un objet posé. Sert à lever l'ambiguïté "on ne comprend
    pas qu'on est sur le ventre" : le sol normal est un pointillé fin partout, ce trait
    localise le contact réel."""
    yy = y if y is not None else max(p1[1], p2[1])
    x0, x1 = sorted([p1[0], p2[0]])
    tick = 1.2
    return (
        f'<line x1="{x0:.1f}" y1="{yy}" x2="{x1:.1f}" y2="{yy}" stroke="{COL_CONTACT}" stroke-width="2" stroke-linecap="round"/>'
        f'<line x1="{x0:.1f}" y1="{yy - tick:.1f}" x2="{x0:.1f}" y2="{yy + tick:.1f}" stroke="{COL_CONTACT}" stroke-width="1.4" stroke-linecap="round"/>'
        f'<line x1="{x1:.1f}" y1="{yy - tick:.1f}" x2="{x1:.1f}" y2="{yy + tick:.1f}" stroke="{COL_CONTACT}" stroke-width="1.4" stroke-linecap="round"/>'
    )
