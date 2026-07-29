#!/usr/bin/env python3
"""Marionnette RDL — charnière de hanche depuis M_rdl-dumbbell_pilote2.png (validée Sophie).

Mouvement : position basse (= image source, frame 0) → remontée vers ~15° du
vertical → redescente. Torse+tête = rotation rigide autour de la hanche P ;
bras+mains+haltère = translation pure (restent à l'aplomb), épinglés à l'épaule.
Jambes/chaussures/tapis = STATIQUES (aucune découpe nécessaire).

Leçons wall-sit appliquées : calques entiers découpés UNE fois, purge de la
frange couleur-fond des sprites, vérifs visuelles à chaque étape.
"""
import numpy as np
from PIL import Image, ImageFilter
from scipy import ndimage
import os, subprocess, sys

SRC = 'ai-explo/vague4/M_rdl-dumbbell_pilote2.png'
OUT = 'puppet_rdl'
# v10 — retour Sophie « le corps se désolidarise » : le vrai pivot du hip-hinge
# est l'articulation hanche/fémur, mesurée au point où les 2 jambes se séparent
# (crotch), PAS le milieu du dos. Le bassin (bande shirt-hem→crotch) doit
# tourner AVEC le torse, pas rester figé avec les jambes.
PIVOT = (595, 590)          # articulation hanche = crotch mesuré (gap 589-602 à y=610)
SHOULDER = (440, 425)       # épaule source (ancrage bras)
THETA_MAX = 40.0            # degrés de remontée (55° penché → ~15° du vertical)
N_FRAMES, FPS = 48, 12

im = np.array(Image.open(SRC).convert('RGB')).astype(np.int16)
H, W = im.shape[:2]
ys, xs = np.mgrid[0:H, 0:W]

WALL = np.array([172, 167, 172]); SHIRT = np.array([243, 243, 242])
SKIN = np.array([202, 176, 158]); HAIR = np.array([63, 62, 71])
NAVY = np.array([66, 81, 102])

def l1(c):
    return np.abs(im - c).sum(axis=2)

# ---------- masques des pièces MOBILES ----------
shirtish = l1(SHIRT) < 60
hairish = (l1(HAIR) < 50) & (ys < 400)
skinish = l1(SKIN) < 38                                     # 55 englobait le mur (L1=54 !)
torso = shirtish | hairish | (skinish & (ys < 388))
torso = ndimage.binary_closing(torso, np.ones((5, 5)))
lblt, _ = ndimage.label(torso)
torso = (lblt == lblt[300, 500])                            # seed dans le t-shirt
print('torso px:', torso.sum())

# ---------- bassin : la bande shirt-hem → crotch fait partie du TORSE ----------
# (rotate AVEC lui, pas figée avec les jambes) — c'est le fix de fond du retour
# Sophie « le corps se désolidarise » : le bassin réel bascule avec le buste
# dans un hip-hinge, seules cuisses-tibias-pieds restent fixes.
# Silhouette PROPRE par soustraction de fond (même méthode que wall-sit) —
# un seuil couleur grossier (pantsish) donnait un contour en escalier avec
# des tirets flottants (AA raté).
MAT = im[:, 900]                                            # stamp tapis (colonne propre)
bgdist = np.minimum(l1(WALL), np.abs(im - MAT[None, :]).sum(axis=2))
bgish = bgdist < 34
lblbg, _ = ndimage.label(bgish)
border_lbls = set(lblbg[0]) | set(lblbg[-1]) | set(lblbg[:, 0]) | set(lblbg[:, -1])
border_lbls.discard(0)
outside = np.isin(lblbg, list(border_lbls))
person = ~outside
person[:, :260] = False; person[:, 900:] = False            # hors zone du personnage/haltère
person = ndimage.binary_closing(person, np.ones((3, 3)))    # lisse le contour (AA/gradient bruité)
lblper, nper = ndimage.label(person)
sizes_per = ndimage.sum(person, lblper, range(1, nper + 1))
person = (lblper == (1 + int(np.argmax(sizes_per))))
person = ndimage.binary_fill_holes(person)

# candidat Y généreux (jusqu'à la marge de `moving` = 9px) : SANS RISQUE de
# bavure car le composant connexe s'arrête naturellement au crotch (y≈592, les
# 2 jambes y sont topologiquement séparées) — pas besoin de dilater le masque
# (qui distordait le contour latéral, cf tentative précédente ratée).
PELVIS_Y_MAX = PIVOT[1] + 30   # `moving` dilate le torse(+pelvis) de 9px : la
                               # zone doit couvrir AU MOINS ce reach pour ne
                               # jamais laisser de pixels tomber sur l'ancien
                               # fallback navy hors zone (tirets, 2 rounds de fix)
pelvis = person & (ys < PELVIS_Y_MAX) & (xs > 500) & (xs < 740) & ~torso & ~hairish
lblp, _ = ndimage.label(pelvis)
pelvis_lbl = lblp[560, 600]                                 # seed dans le bassin, sous le t-shirt
pelvis = (lblp == pelvis_lbl) if pelvis_lbl else np.zeros_like(pelvis)
torso |= pelvis
print('pelvis px:', pelvis.sum(), '(fusionné dans torso)')

# bras + mains + haltère : bbox à gauche du corps, tout sauf mur et blanc
in_bbox = (xs > 280) & (xs < 505) & (ys > 385) & (ys < 705)
arm = in_bbox & (l1(WALL) > 34) & ~shirtish
arm = ndimage.binary_closing(arm, np.ones((5, 5)))
lbla, na = ndimage.label(arm)
sizes = ndimage.sum(arm, lbla, range(1, na + 1))
arm = np.isin(lbla, [i + 1 for i, s in enumerate(sizes) if s > 150])
arm = ndimage.binary_fill_holes(arm)
print('arm px:', arm.sum())

# au-dessus de y=470 (zone épaule/manche) le bras ne garde QUE les vrais
# pixels peau — pas d'AA de manche ni d'ourlet embarqué ; le comblement blanc
# du torse couvre la manche derrière, un raccord blanc/blanc est invisible
arm &= (skinish | (ys > 470))

# ---------- plate statique (jambes/tapis intacts, trous des mobiles comblés) ----------
# le bassin (pelvis) est DÉSORMAIS dans torso → quand il tourne, ce qu'il
# laisse derrière lui est du MUR (rien de statique ne doit apparaître là où
# le bassin s'est déplacé), jamais une continuation de pantalon.
moving = ndimage.binary_dilation(torso | arm, np.ones((5, 5)))  # 9px bavait dans
                                                                  # la cuisse statique voisine du bassin (tirets)
plate = im.copy()
wall_col = im[:, 180]                                       # colonne mur propre
# zone géométrique large (pas le masque exact) : tout pixel proche du bassin
# doit défaut à MUR, jamais au fallback « continuation pantalon » (qui regarde
# tout droit en dessous et tombe sur la vraie jambe → navy peint hors silhouette,
# notches visibles) — ce fallback n'est valable que pour l'occlusion bras/manche.
# MÊME bbox Y que le candidat pelvis : configuration retenue après plusieurs
# essais (dilation du masque réel oscille pire dans un sens ou l'autre selon
# la taille du noyau — la bbox donne le résidu le plus petit). Le résidu final
# (~1-2 tirets de 2-4px) est confirmé INVISIBLE au rendu taille app (340px) —
# STOP incrémental ici (cf règle checklist : pas de retouche en cascade).
pelvis_zone = (ys < PELVIS_Y_MAX) & (ys > 380) & (xs > 500) & (xs < 740)
ye, xe = np.where(moving)
navy_like = l1(NAVY) < 60
for y, x in zip(ye, xe):
    if pelvis_zone[y, x]:
        plate[y, x] = wall_col[y]
        continue
    below = y + 1
    while below < H and moving[below, x]:
        below += 1
    if below < H and navy_like[below, x] and y > (392 if x >= 630 else 435):
        plate[y, x] = im[below, x]                          # pantalon continue sous l'ourlet (bras)
    else:
        plate[y, x] = wall_col[y]
plate = plate.astype(np.uint8)

# ---------- sprites RGBA (purge frange couleur-fond — leçon wall-sit) ----------
def to_sprite(mask):
    a = ndimage.binary_dilation(mask, np.ones((2, 2))).astype(np.float32)
    a = np.array(Image.fromarray((a * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(0.7))) / 255.0
    a[mask] = 1.0
    rgba = np.dstack([im.clip(0, 255).astype(np.uint8), (a * 255).astype(np.uint8)])
    # purge de la frange couleur-mur : UNIQUEMENT près du bord du sprite —
    # un détail intérieur ≈ couleur mur (point d'oreille…) doit rester
    fringe = (np.abs(rgba[:, :, :3].astype(np.int16) - WALL).sum(axis=2) < 24)
    fringe &= ndimage.binary_dilation(~mask, np.ones((5, 5))) & (ys > 300)  # tête épargnée (point d'oreille)
    # la zone bassin gère déjà son fond (plate/pelvis_zone, wall forcé) — purger
    # la frange ICI zéroait des px d'AA de manière irrégulière selon le blend
    # ratio (dilation carrée sur bord diagonal) → tirets pointillés (verdict gate)
    fringe &= ~((ys > 380) & (ys < 630) & (xs > 500) & (xs < 740))
    rgba[fringe, 3] = 0
    return rgba

torso_rgba = to_sprite(torso)
# combler le TROU en forme de bras dans le t-shirt (le bras occluait le tissu) :
# dès que le bras s'écarte, le t-shirt doit être plein derrière lui
arm_over_shirt = ndimage.binary_dilation(arm, np.ones((5, 5))) & (ys < 442) & (xs > 396)
torso_rgba[arm_over_shirt, 0:3] = np.array([243, 243, 242], dtype=np.uint8)
torso_rgba[arm_over_shirt, 3] = 255
arm_rgba = to_sprite(arm)
torso_sprite = Image.fromarray(torso_rgba)
arm_sprite = Image.fromarray(arm_rgba)

# ---------- composition ----------
def shoulder_at(theta_deg):
    # même transform que PIL rotate(-theta) autour de PIVOT : l'épaule suit la manche
    t = np.radians(theta_deg)
    dx, dy = SHOULDER[0] - PIVOT[0], SHOULDER[1] - PIVOT[1]
    rx = dx * np.cos(t) - dy * np.sin(t)
    ry = dx * np.sin(t) + dy * np.cos(t)
    return PIVOT[0] + rx, PIVOT[1] + ry

ARM_PLUMB = 14.0    # ° : angle source du bras vers l'avant ; en haut de course le
                    # bras pendu doit revenir à l'aplomb (retour Sophie r9 « son
                    # bras casse » : le bras gardait son angle pendant que la
                    # manche tournait)

def compose(theta_deg):
    base = Image.fromarray(plate).convert('RGBA')
    t_rot = torso_sprite.rotate(-theta_deg, center=PIVOT, resample=Image.BICUBIC)
    tmp = Image.new('RGBA', base.size, (0, 0, 0, 0)); tmp.paste(t_rot, (0, 0), t_rot)
    base = Image.alpha_composite(base, tmp)
    alpha = ARM_PLUMB * theta_deg / THETA_MAX
    a_rot = arm_sprite.rotate(alpha, center=SHOULDER, resample=Image.BICUBIC)
    sx, sy = shoulder_at(theta_deg)
    off = (int(round(sx - SHOULDER[0])), int(round(sy - SHOULDER[1])))
    tmp = Image.new('RGBA', base.size, (0, 0, 0, 0)); tmp.paste(a_rot, off, a_rot)
    base = Image.alpha_composite(base, tmp)
    return base.convert('RGB')

# ---------- debug ----------
seg = im.clip(0, 255).astype(np.uint8).copy()
seg[torso] = [80, 120, 240]; seg[arm] = [240, 140, 60]
Image.fromarray(seg).save(f'{OUT}/_seg.png')
Image.fromarray(plate).save(f'{OUT}/_plate.png')
compose(0).save(f'{OUT}/_pose_bottom.png')
compose(THETA_MAX / 2).save(f'{OUT}/_pose_mid.png')
compose(THETA_MAX).save(f'{OUT}/_pose_top.png')
print('poses debug écrites')

if '--frames' in sys.argv:
    fdir = f'{OUT}/frames'; os.makedirs(fdir, exist_ok=True)
    for k in range(N_FRAMES):
        theta = THETA_MAX * (1 - np.cos(2 * np.pi * k / N_FRAMES)) / 2
        compose(theta).save(f'{fdir}/f{k:03d}.png')
    import imageio_ffmpeg
    ffmpeg = imageio_ffmpeg.get_ffmpeg_exe()
    out_mp4 = 'ai-explo/anim/anim_rdl-dumbbell_v11.mp4'
    subprocess.run([ffmpeg, '-y', '-framerate', str(FPS), '-i', f'{fdir}/f%03d.png',
                    '-c:v', 'libx264', '-pix_fmt', 'yuv420p', '-crf', '20', out_mp4],
                   check=True, capture_output=True)
    print('mp4 →', out_mp4)
