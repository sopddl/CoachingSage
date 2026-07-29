import math

# ============================================================
# RIG — proportions fixes, communes à TOUS les schémas.
# Seuls les ANGLES changent d'une pose à l'autre ; les LONGUEURS
# de segment, l'épaisseur de trait, le rayon des articulations
# et la taille de l'haltère/barre sont IDENTIQUES partout.
# ============================================================

VIEWBOX = 48  # même viewBox carré pour tous les schémas

# Longueurs de segment (unités du viewBox), fixes pour toutes les poses
HEAD_R = 3.0
NECK = 1.8
UPPER_ARM = 8.0
FOREARM = 8.0
HAND = 2.2          # stub main (préhension équipement)
TORSO = 13.0
THIGH = 11.0
SHIN = 11.0
FOOT = 5.0           # toujours orienté vers l'avant (jamais vers l'arrière)

STROKE = 2.2          # UNE SEULE épaisseur de trait, partout, pour le corps
STROKE_EQUIP = 3.2     # UNE SEULE épaisseur pour barre/haltère (distincte du corps mais fixe elle aussi)
JOINT_R = 1.5
JOINT_STROKE = 0.9

COL_BODY = "#1a1a1a"
COL_KEY = "#c65a37"
COL_EQUIP = "#1F6FEB"  # bleu vif — ressort mieux que l'ancien bleu-vert terne
COL_LOAD = "#1F6FEB"

def pt(origin, length, angle_deg):
    """Point à `length` de `origin`, direction `angle_deg` (0=droite,90=bas,180=gauche,270=haut)."""
    a = math.radians(angle_deg)
    return (origin[0] + length * math.cos(a), origin[1] + length * math.sin(a))

def dist(a, b):
    return math.hypot(a[0] - b[0], a[1] - b[1])

def fmt(p):
    return f"{p[0]:.1f},{p[1]:.1f}"

def svg_open():
    return f'<svg viewBox="0 0 {VIEWBOX} {VIEWBOX}" stroke-linecap="round" stroke-linejoin="round">'

def svg_close():
    return "</svg>"

def line(a, b, color=COL_BODY, w=STROKE, dashed=False):
    dash = ' stroke-dasharray="1.6,1.6"' if dashed else ""
    return f'<path d="M{fmt(a)} L{fmt(b)}" stroke="{color}" stroke-width="{w}" fill="none"{dash}/>'

def polyline(pts, color=COL_BODY, w=STROKE):
    d = "M" + " L".join(fmt(p) for p in pts)
    return f'<path d="{d}" stroke="{color}" stroke-width="{w}" fill="none"/>'

def joint(p):
    return f'<circle cx="{p[0]:.1f}" cy="{p[1]:.1f}" r="{JOINT_R}" fill="#fff" stroke="{COL_BODY}" stroke-width="{JOINT_STROKE}"/>'

def head(center):
    return f'<circle cx="{center[0]:.1f}" cy="{center[1]:.1f}" r="{HEAD_R}" fill="none" stroke="{COL_BODY}" stroke-width="{STROKE}"/>'

def ground(y=44):
    return f'<line x1="4" y1="{y}" x2="44" y2="{y}" stroke="#dcdcdc" stroke-width="1" stroke-dasharray="2,2"/>'

def plate(center):
    """Disque de barre (bout de barbell), vu de côté : plus haut que large (silhouette
    de disque rond vu par la tranche), PAS une haltère."""
    w, h = 2.4, 6.5
    return f'<rect x="{center[0]-w/2:.1f}" y="{center[1]-h/2:.1f}" width="{w}" height="{h}" rx="0.7" fill="{COL_LOAD}"/>'

# Haltère tenue en main — silhouette dédiée (manche fin + 2 têtes), PAS un disque de barre recyclé.
# Manche nettement plus fin que le corps (STROKE) pour ne pas faire un "tas" épais.
# Taille et couleur fixes partout, seul l'angle change avec la prise en main.
DUMBBELL_HANDLE = 5.0
DUMBBELL_HEAD_W = 2.0
DUMBBELL_HEAD_H = 8.0
DUMBBELL_HANDLE_STROKE = 1.1
COL_DUMBBELL = "#1F6FEB"  # bleu vif, dédié — distinct du bleu-vert barre/plaque

def dumbbell(center, angle_deg=90):
    """Haltère complète centrée sur `center` (ex: le poignet), orientée selon `angle_deg`."""
    a = math.radians(angle_deg)
    dx, dy = math.cos(a), math.sin(a)
    half = DUMBBELL_HANDLE / 2
    p1 = (center[0] - dx * half, center[1] - dy * half)
    p2 = (center[0] + dx * half, center[1] + dy * half)
    parts = [f'<path d="M{fmt(p1)} L{fmt(p2)}" stroke="{COL_DUMBBELL}" stroke-width="{DUMBBELL_HANDLE_STROKE}" stroke-linecap="round"/>']
    for p in (p1, p2):
        x, y = p[0] - DUMBBELL_HEAD_W / 2, p[1] - DUMBBELL_HEAD_H / 2
        parts.append(
            f'<rect x="{x:.1f}" y="{y:.1f}" width="{DUMBBELL_HEAD_W}" height="{DUMBBELL_HEAD_H}" '
            f'rx="0.7" fill="{COL_DUMBBELL}" transform="rotate({angle_deg:.1f} {p[0]:.1f} {p[1]:.1f})"/>'
        )
    return "".join(parts)

def barbell_side(center, half_len=9):
    parts = [f'<line x1="{center[0]-half_len:.1f}" y1="{center[1]:.1f}" x2="{center[0]+half_len:.1f}" y2="{center[1]:.1f}" stroke="{COL_EQUIP}" stroke-width="{STROKE_EQUIP}"/>']
    for sign in (-1, 1):
        x = center[0] + sign * half_len
        parts.append(f'<rect x="{x-1:.1f}" y="{center[1]-3.5:.1f}" width="2" height="7" rx="0.6" fill="{COL_LOAD}"/>')
    return "".join(parts)

def bar_fixed(x1, x2, y):
    return f'<line x1="{x1}" y1="{y}" x2="{x2}" y2="{y}" stroke="{COL_EQUIP}" stroke-width="{STROKE_EQUIP+0.6}"/>'


def check_rig(name, joints_dict, expected):
    """joints_dict: {name: point}. expected: [(a,b,length),...] — assert segments match rig lengths."""
    errs = []
    for a, b, exp_len in expected:
        d = dist(joints_dict[a], joints_dict[b])
        if abs(d - exp_len) > 0.05:
            errs.append(f"  {a}->{b}: {d:.2f} attendu {exp_len}")
    status = "OK" if not errs else "ECART"
    print(f"[{status}] {name}")
    for e in errs:
        print(e)
