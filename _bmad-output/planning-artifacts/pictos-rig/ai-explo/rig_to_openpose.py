"""
PROTOTYPE — convertit les points déjà calculés par notre rig (Chain.points, les
mêmes coordonnées qui servent à dessiner les stick-figures SVG) en squelette au
format OpenPose/COCO-18, le format standard que ControlNet sait lire pour piloter
une génération d'image (Stable Diffusion / SDXL + ControlNet-OpenPose).

Intérêt : on a DÉJÀ les 65 poses codées en angles précis (corps->articulation->objet,
proportions verrouillées). Si on veut un jour du rendu "vrai personnage" au lieu du
stick-figure, on n'a PAS besoin de re-poser 65 fois dans un outil — on réutilise
exactement les mêmes données de pose, juste rendues dans un format différent.

Usage : voir demo_convert.py dans ce même dossier.
"""
import math
from PIL import Image, ImageDraw

# Format COCO-18 (celui que les modèles ControlNet-OpenPose grand public attendent)
KEYPOINT_NAMES = [
    "Nose", "Neck", "RShoulder", "RElbow", "RWrist", "LShoulder", "LElbow", "LWrist",
    "RHip", "RKnee", "RAnkle", "LHip", "LKnee", "LAnkle", "REye", "LEye", "REar", "LEar",
]

POSE_PAIRS = [
    (1, 2), (1, 5), (2, 3), (3, 4), (5, 6), (6, 7),
    (1, 8), (8, 9), (9, 10), (1, 11), (11, 12), (12, 13),
    (1, 0), (0, 14), (14, 16), (0, 15), (15, 17), (2, 17), (5, 16),
]

# Couleurs standard OpenPose (celles que reconnaît le préprocesseur ControlNet —
# la couleur EST l'information : c'est comme ça que le modèle sait "ça c'est le bras
# droit, pas la jambe gauche"). Ne pas changer sans changer le format en même temps.
LIMB_COLORS = [
    (255, 0, 0), (255, 85, 0), (255, 170, 0), (255, 255, 0), (170, 255, 0), (85, 255, 0),
    (0, 255, 0), (0, 255, 85), (0, 255, 170), (0, 255, 255), (0, 170, 255), (0, 85, 255),
    (0, 0, 255), (85, 0, 255), (170, 0, 255), (255, 0, 255), (255, 0, 170), (255, 0, 85),
]

POINT_COLORS = LIMB_COLORS  # même palette pour les ronds d'articulation


def build_keypoints(mapping, canvas_w, canvas_h, src_w=80, src_h=48):
    """`mapping` : dict {nom_keypoint_coco18 -> (x, y)} dans les coordonnées du rig
    (viewBox 80x48 ou 48x48 selon le lot). Les points absents restent None (OpenPose
    gère les keypoints manquants — normal sur une pose de profil où on ne voit qu'un
    bras/une jambe). Retourne une liste de 18 (x, y) ou None, à l'échelle canvas."""
    sx, sy = canvas_w / src_w, canvas_h / src_h
    pts = []
    for name in KEYPOINT_NAMES:
        p = mapping.get(name)
        pts.append((p[0] * sx, p[1] * sy) if p else None)
    return pts


def render_openpose_png(keypoints, canvas_w=512, canvas_h=512, out_path="skeleton.png"):
    """Dessine le squelette coloré fond noir — exactement le format que ControlNet-
    OpenPose attend en entrée (`control image`). Pas de génération d'image réelle ici
    (pas d'accès à un modèle depuis cet environnement) — ce PNG est ce qu'on colle
    dans ComfyUI / Replicate / un des démonstrateurs web gratuits pour tester."""
    img = Image.new("RGB", (canvas_w, canvas_h), (0, 0, 0))
    draw = ImageDraw.Draw(img)
    stick_w = max(2, canvas_w // 90)
    for i, (a, b) in enumerate(POSE_PAIRS):
        pa, pb = keypoints[a], keypoints[b]
        if pa is None or pb is None:
            continue
        draw.line([pa, pb], fill=LIMB_COLORS[i % len(LIMB_COLORS)], width=stick_w)
    r = max(3, canvas_w // 60)
    for i, p in enumerate(keypoints):
        if p is None:
            continue
        draw.ellipse([p[0] - r, p[1] - r, p[0] + r, p[1] + r], fill=POINT_COLORS[i % len(POINT_COLORS)])
    img.save(out_path)
    return out_path
