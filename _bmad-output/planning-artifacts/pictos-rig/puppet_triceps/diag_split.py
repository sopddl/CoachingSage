#!/usr/bin/env python3
"""Diagnostic : split near/far arm masks + candidate pivots, avant de committer le rig."""
import numpy as np
from PIL import Image, ImageDraw
from scipy import ndimage

SRC = 'ai-explo/muscu/B_triceps-overhead_fix.png'
OUT = 'puppet_triceps'

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

near_mask = (dbish | gripish | (skinish & left_arm_zone)) & person
far_mask = (skinish & right_arm_zone) & person

def clean(mask, minsize=100):
    lbl, n = ndimage.label(mask)
    sizes = ndimage.sum(mask, lbl, range(1, n + 1))
    mask = np.isin(lbl, [i + 1 for i, s in enumerate(sizes) if s > minsize])
    return ndimage.binary_fill_holes(mask)

near_mask = clean(near_mask)
far_mask = clean(far_mask)
print('near px:', near_mask.sum(), 'far px:', far_mask.sum())

def bbox(mask):
    yy, xx = np.where(mask)
    return xx.min(), xx.max(), yy.min(), yy.max()

print('near bbox (xmin,xmax,ymin,ymax):', bbox(near_mask))
print('far bbox (xmin,xmax,ymin,ymax):', bbox(far_mask))

# attachment point candidate = centroid of bottom 12% rows of each mask (closest to torso)
def attach_point(mask, frac=0.12):
    yy, xx = np.where(mask)
    ymax = yy.max()
    ymin = yy.min()
    thresh = ymax - frac * (ymax - ymin)
    sel = yy >= thresh
    return xx[sel].mean(), yy[sel].mean()

near_attach = attach_point(near_mask)
far_attach = attach_point(far_mask)
print('near attach (shoulder candidate):', near_attach)
print('far attach (shoulder candidate):', far_attach)

# top point (dumbbell tip / elbow tip) for reference
def top_point(mask):
    yy, xx = np.where(mask)
    ymin = yy.min()
    sel = yy <= ymin + 5
    return xx[sel].mean(), yy[sel].mean()

print('near top:', top_point(near_mask))
print('far top:', top_point(far_mask))

# annotated view
vis = im.clip(0, 255).astype(np.uint8).copy()
vis[near_mask] = [80, 120, 240]
vis[far_mask] = [240, 100, 60]
img = Image.fromarray(vis)
draw = ImageDraw.Draw(img)
for pt, color in [(near_attach, (0, 255, 0)), (far_attach, (255, 255, 0))]:
    x, y = pt
    draw.ellipse([x - 8, y - 8, x + 8, y + 8], outline=color, width=3)
img.save(f'{OUT}/_diag_split.png')
print('saved _diag_split.png')
