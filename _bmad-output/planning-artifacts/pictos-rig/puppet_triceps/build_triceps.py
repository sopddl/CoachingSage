#!/usr/bin/env python3
"""Marionnette TRICEPS OVERHEAD — depuis B_triceps-overhead_fix.png (catalogue,
verdict OK, mais anim gelée : kontext refusait de replacer l'haltère derrière
la tête). La marionnette pixel contourne ce blocage : ZÉRO repositionnement
IA, juste une rotation rigide des pixels validés.

Simplification assumée (2 coudes réels, mais silhouette 2D sans pli dessiné
au coude) : bras+avant-bras+haltère+mains traités comme UN bloc rigide qui
pivote autour d'un point central (ligne d'épaules), simulant l'extension —
évite le problème d'IK à 2 pivots indépendants qui étirerait l'haltère.
Amplitude modeste (petit pulse), même doctrine que wall-sit/rdl/fente.
"""
import numpy as np
from PIL import Image, ImageFilter
from scipy import ndimage
import os, subprocess, sys

SRC = 'ai-explo/muscu/B_triceps-overhead_fix.png'
OUT = 'puppet_triceps'
PIVOT = (500, 315)     # ligne d'épaules, centre entre les 2 coudes
THETA_MAX = 12.0       # extension modeste (élévation même mécanisme que rdl arm-plumb)
N_FRAMES, FPS = 48, 12

im = np.array(Image.open(SRC).convert('RGB')).astype(np.int16)
H, W = im.shape[:2]
ys, xs = np.mgrid[0:H, 0:W]

WALL = np.array([173, 165, 170]); SKIN = np.array([203, 175, 157])
HAIR = np.array([60, 55, 68]); DBLUE = np.array([40, 68, 95])
GRIP = np.array([160, 163, 178]); SHIRT = np.array([244, 244, 244])

def l1(c):
    return np.abs(im - c).sum(axis=2)

UPPER_ZONE = (ys < 350) & (xs > 250) & (xs < 700)  # évite shoes/pants ailleurs dans l'image
skinish = (l1(SKIN) < 40) & UPPER_ZONE
dbish = (l1(DBLUE) < 45) & UPPER_ZONE
gripish = (l1(GRIP) < 30) & UPPER_ZONE

# ---------- silhouette propre (soustraction de fond) pour un contour net ----------
MAT = im[:, 60]
bgdist = np.minimum(l1(WALL), np.abs(im - MAT[None, :]).sum(axis=2))
bgish = bgdist < 30
lblbg, _ = ndimage.label(bgish)
border_lbls = set(lblbg[0]) | set(lblbg[-1]) | set(lblbg[:, 0]) | set(lblbg[:, -1])
border_lbls.discard(0)
outside = np.isin(lblbg, list(border_lbls))
person = ~outside
person = ndimage.binary_closing(person, np.ones((3, 3)))
lblper, nper = ndimage.label(person)
sizes_per = ndimage.sum(person, lblper, range(1, nper + 1))
person = (lblper == (1 + int(np.argmax(sizes_per))))
person = ndimage.binary_fill_holes(person)

# ---------- bloc mobile : bras levés + haltère, AU-DESSUS de la ligne d'épaules ----------
# v2 : le seuil peau seul attrapait aussi le VISAGE (même couleur) → exclusion
# géométrique explicite du visage (mesurée) + zone bras gauche/droite séparées
# (le bras droit passe près/derrière la tête, x480-660 ; le gauche x330-480).
# bandes ÉTROITES sur chaque avant-bras (mesurées : gauche x330-460, droit
# x595-660) — pas de bbox large : la peau du cou/épaule est bien plus LARGE
# que la bande d'avant-bras et se ferait avaler par une zone généreuse.
left_arm_zone = (xs >= 330) & (xs <= 460) & (ys >= 105) & (ys <= 320)
right_arm_zone = (xs >= 595) & (xs <= 660) & (ys >= 105) & (ys <= 320)
arm_zone = left_arm_zone | right_arm_zone
moving_mask = (dbish | gripish | (skinish & arm_zone)) & person
moving_mask = ndimage.binary_closing(moving_mask, np.ones((5, 5)))
lblm, nm = ndimage.label(moving_mask)
sizes_m = ndimage.sum(moving_mask, lblm, range(1, nm + 1))
moving_mask = np.isin(lblm, [i + 1 for i, s in enumerate(sizes_m) if s > 150])
moving_mask = ndimage.binary_fill_holes(moving_mask)
print('moving px:', moving_mask.sum())

# ---------- plate : trou comblé par MUR (rien de statique derrière les bras levés) ----------
moving_dilated = ndimage.binary_dilation(moving_mask, np.ones((5, 5)))
plate = im.copy()
wall_col = im[:, 60]
ye, xe = np.where(moving_dilated)
for y, x in zip(ye, xe):
    plate[y, x] = wall_col[y]
plate = plate.astype(np.uint8)

# ---------- sprite ----------
def to_sprite(mask):
    a = ndimage.binary_dilation(mask, np.ones((2, 2))).astype(np.float32)
    a = np.array(Image.fromarray((a * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(0.7))) / 255.0
    a[mask] = 1.0
    rgba = np.dstack([im.clip(0, 255).astype(np.uint8), (a * 255).astype(np.uint8)])
    return Image.fromarray(rgba)

moving_sprite = to_sprite(moving_mask)

def compose(theta):
    base = Image.fromarray(plate).convert('RGBA')
    rot = moving_sprite.rotate(theta, center=PIVOT, resample=Image.BICUBIC)
    # extension = translation verticale légère en plus de la rotation (l'haltère monte)
    dy = -int(round(theta * 1.6))
    tmp = Image.new('RGBA', base.size, (0, 0, 0, 0))
    tmp.paste(rot, (0, dy), rot)
    base = Image.alpha_composite(base, tmp)
    return base.convert('RGB')

# ---------- debug ----------
seg = im.clip(0, 255).astype(np.uint8).copy()
seg[moving_mask] = [80, 120, 240]
Image.fromarray(seg).save(f'{OUT}/_seg.png')
Image.fromarray(plate).save(f'{OUT}/_plate.png')
compose(0).save(f'{OUT}/_pose_rest.png')
compose(THETA_MAX).save(f'{OUT}/_pose_ext.png')
print('poses debug écrites')

if '--frames' in sys.argv:
    fdir = f'{OUT}/frames'; os.makedirs(fdir, exist_ok=True)
    for k in range(N_FRAMES):
        theta = THETA_MAX * (1 - np.cos(2 * np.pi * k / N_FRAMES)) / 2
        compose(theta).save(f'{fdir}/f{k:03d}.png')
    import imageio_ffmpeg
    ffmpeg = imageio_ffmpeg.get_ffmpeg_exe()
    out_mp4 = 'ai-explo/anim/anim_triceps-overhead_v5.mp4'
    subprocess.run([ffmpeg, '-y', '-framerate', str(FPS), '-i', f'{fdir}/f%03d.png',
                    '-c:v', 'libx264', '-pix_fmt', 'yuv420p', '-crf', '20', out_mp4],
                   check=True, capture_output=True)
    print('mp4 →', out_mp4)
