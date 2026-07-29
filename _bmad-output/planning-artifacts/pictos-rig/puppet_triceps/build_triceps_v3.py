#!/usr/bin/env python3
"""Marionnette TRICEPS OVERHEAD v3 — depuis B_triceps-overhead_fix.png.
v2 avait 2 pivots indépendants mesurés (near = haltère+avant-bras proche,
far = sliver bras loin) mais la rotation ouvrait un GAP visible au pivot :
la zone découverte par le bras qui tourne tombe sur tête/épaule/t-shirt,
pas sur du fond ouvert (contrairement à wall-sit/rdl/fente) — un simple
fill couleur mur ne peut pas la reboucher proprement.
v3 fix : plate générée via kontext (_plate_vierge.png, bras au repos, sans
haltère, même perso/style/fond/mat — vérifié aligné à la silhouette
originale) sert de source de fill RÉELLE (tête/épaule/t-shirt) pour la zone
découverte, au lieu d'une couleur plate.
"""
import numpy as np
from PIL import Image, ImageFilter
from scipy import ndimage
import os, subprocess, sys

SRC = 'ai-explo/muscu/B_triceps-overhead_fix.png'
OUT = 'puppet_triceps'

NEAR_PIVOT = (440, 297)   # épaule proche (mesurée, diag_split.py)
FAR_PIVOT = (596, 285)    # épaule loin (mesurée, diag_split.py)
THETA_MAX = 10.0          # v3 tenté à 32° (fix expert 07-15 : ROM pas assez visible) MAIS
                          # ça casse le rig (segments qui se désolidarisent, cf _pose_ext_v3
                          # à 32°) — bloc rigide unique = même limite que v1, juste repoussée.
                          # Revenu à 10° (propre) : ce n'est pas un vrai fix de la critique
                          # expert, qui reste valide — nécessite la vraie double-rotation IK
                          # par coude (chantier dédié, cf exploration_cat_cow_facepull_triceps).
FAR_SCALE = 0.55          # bras loin = segment court, amplitude réduite proportionnelle
N_FRAMES, FPS = 48, 12

im = np.array(Image.open(SRC).convert('RGB')).astype(np.int16)
H, W = im.shape[:2]
ys, xs = np.mgrid[0:H, 0:W]

WALL = np.array([173, 165, 170]); SKIN = np.array([203, 175, 157])
DBLUE = np.array([40, 68, 95]); GRIP = np.array([160, 163, 178])

def l1(c):
    return np.abs(im - c).sum(axis=2)

UPPER_ZONE = (ys < 350) & (xs > 250) & (xs < 700)
skinish = (l1(SKIN) < 40) & UPPER_ZONE
dbish = (l1(DBLUE) < 45) & UPPER_ZONE
gripish = (l1(GRIP) < 30) & UPPER_ZONE

# ---------- silhouette (person) pour exclure le fond ----------
MAT = im[:, 5]
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

left_arm_zone = (xs >= 390) & (xs <= 470) & (ys >= 130) & (ys <= 310)
right_arm_zone = (xs >= 560) & (xs <= 660) & (ys >= 130) & (ys <= 290)

def clean(mask, minsize=100):
    lbl, n = ndimage.label(mask)
    sizes = ndimage.sum(mask, lbl, range(1, n + 1))
    mask = np.isin(lbl, [i + 1 for i, s in enumerate(sizes) if s > minsize])
    return ndimage.binary_fill_holes(mask)

near_mask = clean((dbish | gripish | (skinish & left_arm_zone)) & person)
far_mask = clean((skinish & right_arm_zone) & person)
print('near px:', near_mask.sum(), 'far px:', far_mask.sum())

moving_mask = near_mask | far_mask

# ---------- plate : trou comblé par la vierge (kontext, bras au repos) ----------
vierge = np.array(Image.open(f'{OUT}/_plate_vierge.png').convert('RGB'))
moving_dilated = ndimage.binary_dilation(moving_mask, np.ones((7, 7)))
plate = im.copy()
plate[moving_dilated] = vierge[moving_dilated]
plate = plate.astype(np.uint8)

# ---------- sprites ----------
def to_sprite(mask):
    a = ndimage.binary_dilation(mask, np.ones((2, 2))).astype(np.float32)
    a = np.array(Image.fromarray((a * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(0.7))) / 255.0
    a[mask] = 1.0
    rgba = np.dstack([im.clip(0, 255).astype(np.uint8), (a * 255).astype(np.uint8)])
    return Image.fromarray(rgba)

near_sprite = to_sprite(near_mask)
far_sprite = to_sprite(far_mask)

def compose(theta):
    base = Image.fromarray(plate).convert('RGBA')
    tmp = Image.new('RGBA', base.size, (0, 0, 0, 0))

    # far segment d'abord (dessous, plus proche de la tête) puis near (dessus, haltère)
    far_theta = -theta * FAR_SCALE
    rot_far = far_sprite.rotate(far_theta, center=FAR_PIVOT, resample=Image.BICUBIC)
    dy_far = -int(round(theta * FAR_SCALE * 1.0))
    tf = Image.new('RGBA', base.size, (0, 0, 0, 0))
    tf.paste(rot_far, (0, dy_far), rot_far)
    tmp = Image.alpha_composite(tmp, tf)

    rot_near = near_sprite.rotate(theta, center=NEAR_PIVOT, resample=Image.BICUBIC)
    dy_near = -int(round(theta * 1.6))
    tn = Image.new('RGBA', base.size, (0, 0, 0, 0))
    tn.paste(rot_near, (0, dy_near), rot_near)
    tmp = Image.alpha_composite(tmp, tn)

    base = Image.alpha_composite(base, tmp)
    return base.convert('RGB')

# ---------- debug ----------
seg = im.clip(0, 255).astype(np.uint8).copy()
seg[near_mask] = [80, 120, 240]
seg[far_mask] = [240, 100, 60]
Image.fromarray(seg).save(f'{OUT}/_seg_v3.png')
Image.fromarray(plate).save(f'{OUT}/_plate_v3.png')
rest = compose(0)
ext = compose(THETA_MAX)
rest.save(f'{OUT}/_pose_rest_v3.png')
ext.save(f'{OUT}/_pose_ext_v3.png')
# vue taille app réelle (340px large) pour jugement au bon référentiel
w = 340
h = int(rest.height * w / rest.width)
rest.resize((w, h), Image.LANCZOS).save(f'{OUT}/_pose_rest_v3_340.png')
ext.resize((w, h), Image.LANCZOS).save(f'{OUT}/_pose_ext_v3_340.png')
print('poses debug écrites')

if '--frames' in sys.argv:
    fdir = f'{OUT}/frames_v3'; os.makedirs(fdir, exist_ok=True)
    for k in range(N_FRAMES):
        theta = THETA_MAX * (1 - np.cos(2 * np.pi * k / N_FRAMES)) / 2
        compose(theta).save(f'{fdir}/f{k:03d}.png')
    import imageio_ffmpeg
    ffmpeg = imageio_ffmpeg.get_ffmpeg_exe()
    out_mp4 = 'ai-explo/anim/anim_triceps-overhead_v3.mp4'
    subprocess.run([ffmpeg, '-y', '-framerate', str(FPS), '-i', f'{fdir}/f%03d.png',
                    '-c:v', 'libx264', '-pix_fmt', 'yuv420p', '-crf', '20', out_mp4],
                   check=True, capture_output=True)
    print('mp4 ->', out_mp4)
