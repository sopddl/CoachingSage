#!/usr/bin/env python3
"""Marionnette FENTE — pulse en bas de fente depuis B_lunge-dumbbell_fix.png (catalogue validé).

Mouvement : pulse vertical (torse+tête+bras+2 haltères descendent de PULSE_AMP px
puis remontent), jambes/bassin/pieds STATIQUES. Le pas complet articulé serait
un risque Frankenstein élevé — le pulse montre le travail de la fente.

Z-order (règle Sophie r7 : l'haltère arrière reste DERRIÈRE la jambe) :
  plate (fond+jambes+bassin) → M_rear (bras arrière+haltère arrière, mobile)
  → legs_overlay (fenêtre statique jambe arrière) → M_front (tête+torse+bras
  avant+haltère avant, mobile).
"""
import numpy as np
from PIL import Image, ImageFilter
from scipy import ndimage
import os, subprocess, sys

SRC = 'ai-explo/muscu/B_lunge-dumbbell_fix.png'
OUT = 'puppet_lunge'
PULSE_AMP = 30          # v15 : Sophie r9 « je ne comprends pas le geste, il ne
                        # bouge pas » → vraie descente-remontée lisible, avec
                        # rotation de la cuisse avant autour du genou
# v16 — retour Sophie r10 « je ne comprends pas comment tu bouges le haut sans
# bouger les fesses et les jambes » : MÊME cause racine que le RDL — le bassin
# doit descendre AVEC le torse (pas rester figé), sinon désolidarisation visible.
KNEE = (335, 695)       # genou avant (pivot de la cuisse)
HIP = (470, 578)        # extrémité hanche de la cuisse avant — remontée à la
                        # vraie jonction bassin/cuisse (mesurée), pas un point
                        # arbitraire au milieu du pantalon
N_FRAMES, FPS = 48, 12

im = np.array(Image.open(SRC).convert('RGB')).astype(np.int16)
H, W = im.shape[:2]
ys, xs = np.mgrid[0:H, 0:W]

WALL = np.array([170, 164, 171]); SHIRT = np.array([253, 253, 253])
SKIN = np.array([205, 177, 157]); HAIR = np.array([60, 60, 70])
PANTS = np.array([42, 56, 79]); DBLUE = np.array([44, 69, 98])
GRIP = np.array([163, 162, 176])

def l1(c):
    return np.abs(im - c).sum(axis=2)

shirtish = l1(SHIRT) < 60
skinish = l1(SKIN) < 38
hairish = (l1(HAIR) < 45) & (ys < 320)
# haltères : bleu à dominante verte (G-R élevé) vs pantalon — + grips clairs
dbish = (l1(DBLUE) < 40) & ((im[:, :, 1] - im[:, :, 0]) > 18)
# le grip clair est QUASI couleur mur (L1=14) : le distinguer par sa dominante
# bleue (B-R élevé, le mur est neutre)
gripish = (l1(GRIP) < 30) & ((im[:, :, 2] - im[:, :, 0]) > 10) & (ys > 500) & (ys < 660)
gripish |= (l1(np.array([129, 140, 150])) < 35) & (ys > 600) & (ys < 660) & (xs > 590)  # grip arrière (plus sombre)

# ---------- M_front : tête + t-shirt + bras avant + main + haltère avant ----------
front_zone = (xs < 470)                                     # l'haltère/main avant est à gauche
rear_hand_zone = (xs >= 470) & (ys > 555)                   # main/haltère arrière → m_rear
# l'extrémité saillante de la barre avant (x>=396) reste ENTIÈREMENT statique :
# moitié bleu-clair + moitié couleur-mur — la faire bouger pose sa partie
# claire sur la cuisse sombre (fragment à fort contraste, verdict passe 3),
# statique elle reste sur fond mur où son contraste est ~18/765 (invisible)
m_front = shirtish | hairish | (skinish & (ys < 600) & ~rear_hand_zone) | ((dbish | (gripish & (xs < 396))) & front_zone)
# la section de barre entre la tête droite et la hanche est QUASI couleur mur
# (L1=7) : on la laisse STATIQUE dans le plate — l'inclure dans le sprite
# créait une couture rectangulaire visible (verdict re-gate F4), et son
# immobilité est invisible à 1x (contraste quasi nul)
m_front = ndimage.binary_closing(m_front, np.ones((5, 5)))
lblf, nf = ndimage.label(m_front)
sizes_f = ndimage.sum(m_front, lblf, range(1, nf + 1))
m_front = np.isin(lblf, [i + 1 for i, s in enumerate(sizes_f) if s > 250])
m_front = ndimage.binary_fill_holes(m_front)
print('m_front px:', m_front.sum())

# ---------- M_rear : main arrière + haltère arrière (à droite, derrière la hanche) ----------
rear_zone = (xs >= 470) & (ys > 555) & (ys < 690)
m_rear = (dbish | gripish | (skinish & (ys > 555))) & rear_zone & ~m_front
m_rear = ndimage.binary_closing(m_rear, np.ones((5, 5)))
lblr, nr = ndimage.label(m_rear)
sizes = ndimage.sum(m_rear, lblr, range(1, nr + 1))
m_rear = np.isin(lblr, [i + 1 for i, s in enumerate(sizes) if s > 120])
m_rear = ndimage.binary_fill_holes(m_rear)
print('m_rear px:', m_rear.sum())

# ---------- bassin : rejoint le bloc qui descend (m_front), PAS figé ----------
# silhouette propre par soustraction de fond (même méthode que RDL v10) — un
# seuil couleur brut donne un contour en escalier.
MAT_L = im[:, 60]                                            # stamp tapis colonne propre
bgdist = np.minimum(l1(WALL), np.abs(im - MAT_L[None, :]).sum(axis=2))
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

PELVIS_Y_MAX = 590                                            # bande bassin, sous l'ourlet
pelvis = person & (ys < PELVIS_Y_MAX) & (ys > 500) & (xs > 400) & (xs < 660) & ~m_front & ~m_rear
lblp, _ = ndimage.label(pelvis)
pelvis_lbl = lblp[560, 500]                                   # seed dans le bassin, sous le t-shirt
pelvis = (lblp == pelvis_lbl) if pelvis_lbl else np.zeros_like(pelvis)
m_front |= pelvis
print('pelvis px:', pelvis.sum(), '(fusionné dans m_front — descend avec le torse)')

# ---------- cuisse avant : calque ROTATIF autour du genou ----------
pants_like_all = l1(PANTS) < 55
thigh = pants_like_all & (ys >= PELVIS_Y_MAX - 12) & (ys <= 702) & (xs >= 280) & (xs <= 510) & ~m_front & ~m_rear
thigh = ndimage.binary_closing(thigh, np.ones((5, 5)))
lblth, nth = ndimage.label(thigh)
sizes_t = ndimage.sum(thigh, lblth, range(1, nth + 1))
thigh = np.isin(lblth, [i + 1 for i, s in enumerate(sizes_t) if s > 400])
print('thigh px:', thigh.sum())

# ---------- plate : trous des mobiles comblés ----------
moving = ndimage.binary_dilation(m_front | m_rear | thigh, np.ones((7, 7)))
plate = im.copy()
wall_col = im[:, 150]
pants_like = l1(PANTS) < 55
# v16 : le bassin fait maintenant partie de m_front (descend avec le torse) —
# tout pixel vacaté dans sa zone doit défaulter à MUR (pas de continuation
# pantalon, qui peindrait un bassin fantôme statique — même bug que RDL v9/v10).
# Priorité : fenêtres historiques (crotch, bord cuisse/haltère avant) d'ABORD
# (fixes acquis, ne pas régresser), PUIS zone bassin, PUIS fallback générique.
pelvis_zone = (ys < PELVIS_Y_MAX) & (ys > 500) & (xs > 400) & (xs < 660)
ye, xe = np.where(moving)
for y, x in zip(ye, xe):
    below = y + 1
    while below < H and moving[below, x]:
        below += 1
    if 420 <= x <= 530 and 550 < y < 645:
        # fenêtre crotch/hanche : derrière = TOUJOURS du corps (bassin) — la
        # propagation verticale retombait sur le vide entre-jambes → mur (trou
        # clignotant au mouvement, P0 du gate v15)
        plate[y, x] = im[below, x] if (below < H and pants_like[below, x]) else PANTS
        continue
    x_hip = 455 - (y - 520) * 0.4                            # contour avant de hanche (pente plausible)
    if 337 <= x <= 466 and y > 520:
        # derrière l'haltère avant : bord de cuisse par interpolation sur les
        # points MESURÉS (mes colonnes flanquantes + mesures du re-gate)
        y_edge = np.interp(x, [333, 400, 421, 448, 468], [598, 558, 550, 537, 532])
        if y < y_edge:
            plate[y, x] = wall_col[y]
        else:
            plate[y, x] = im[below, x] if (below < H and pants_like[below, x]) else PANTS
        continue
    if pelvis_zone[y, x]:
        plate[y, x] = wall_col[y]
        continue
    navy_zone = (x_hip <= x <= 591 and y > 520) or (y >= 620)  # fond occlus = pantalon UNIQUEMENT ici
    if below < H and (pants_like[below, x] or np.abs(im[below, x] - np.array([60, 76, 99])).sum() < 45) and navy_zone:
        plate[y, x] = im[below, x]                          # pantalon continue derrière
    else:
        plate[y, x] = wall_col[y]
# (v16 : l'ancienne « extension bassin sous l'ourlet » est retirée — obsolète
# depuis que le bassin fait partie de m_front : il ne glisse plus sous un
# ourlet statique, torse+bassin translatent ensemble, rien à combler ici.)
# nettoyage prescrit par le gate (passe 3) : à la jonction barre/tête, des
# pixels clairs de la SOURCE (AA de jonction, statiques, occlus au repos)
# apparaissent sur la cuisse au dip — tout pixel clair sous le bord de cuisse
# et SOUS la barre (y>=563) → navy cuisse. Invisible au repos (sous le sprite).
for y in range(563, 640):
    for x in range(396, 470):
        if plate[y, x].sum() > 430:
            plate[y, x] = PANTS
plate = plate.astype(np.uint8)

# ---------- overlay statique jambe arrière (occlusion haltère arrière) ----------
ov_zone = (xs > 505) & (xs < 700) & (ys > 630) & (ys < 780)
legs_ov = ov_zone & (pants_like | (l1(np.array([60, 76, 99])) < 40))
# JAMAIS de pixels d'haltère/main dans l'overlay statique (fantôme au dip)
legs_ov &= ~ndimage.binary_dilation(m_rear | dbish, np.ones((5, 5))) & ~thigh
legs_ov = ndimage.binary_closing(legs_ov, np.ones((3, 3)))

# ---------- sprites ----------
def to_sprite(mask):
    a = ndimage.binary_dilation(mask, np.ones((2, 2))).astype(np.float32)
    a = np.array(Image.fromarray((a * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(0.7))) / 255.0
    a[mask] = 1.0
    rgba = np.dstack([im.clip(0, 255).astype(np.uint8), (a * 255).astype(np.uint8)])
    # PAS de purge de frange ici : les sprites ne sont pas recolorés — leur
    # anneau AA d'origine reproduit exactement la source au repos (la purge
    # créait un halo mur autour du plateau avant, verdict gate)
    return Image.fromarray(rgba)

front_sprite = to_sprite(m_front)
rear_sprite = to_sprite(m_rear)
ov_sprite = to_sprite(legs_ov)
thigh_sprite = to_sprite(thigh)

def thigh_delta(dy):
    """Angle (°) de rotation de la cuisse autour du genou pour que l'extrémité
    hanche descende de dy px (résolution numérique, signe testé)."""
    vx, vy = HIP[0] - KNEE[0], HIP[1] - KNEE[1]
    best = 0.0
    for d in np.arange(0, 30, 0.25):
        for s in (1, -1):
            t = np.radians(s * d)
            ny = vx * np.sin(t) + vy * np.cos(t)
            if abs((ny - vy) - dy) < 1.2:
                return s * d
    return best

def compose(dy):
    base = Image.fromarray(plate).convert('RGBA')
    delta = thigh_delta(dy)
    th_rot = thigh_sprite.rotate(-delta, center=KNEE, resample=Image.BICUBIC)
    for spr, off in [(rear_sprite, (0, dy)), (ov_sprite, (0, 0)),
                     (th_rot, (0, 0)), (front_sprite, (0, dy))]:
        tmp = Image.new('RGBA', base.size, (0, 0, 0, 0))
        tmp.paste(spr, off, spr)
        base = Image.alpha_composite(base, tmp)
    return base.convert('RGB')

# ---------- debug ----------
seg = im.clip(0, 255).astype(np.uint8).copy()
seg[m_front] = [80, 120, 240]; seg[m_rear] = [240, 140, 60]; seg[legs_ov] = [60, 200, 90]
Image.fromarray(seg).save(f'{OUT}/_seg.png')
Image.fromarray(plate).save(f'{OUT}/_plate.png')
compose(0).save(f'{OUT}/_pose_rest.png')
compose(PULSE_AMP).save(f'{OUT}/_pose_low.png')
print('poses debug écrites')

if '--frames' in sys.argv:
    fdir = f'{OUT}/frames'; os.makedirs(fdir, exist_ok=True)
    for k in range(N_FRAMES):
        dy = round(PULSE_AMP * (1 - np.cos(2 * np.pi * k / N_FRAMES)) / 2)
        compose(int(dy)).save(f'{fdir}/f{k:03d}.png')
    import imageio_ffmpeg
    ffmpeg = imageio_ffmpeg.get_ffmpeg_exe()
    out_mp4 = 'ai-explo/anim/anim_lunge-dumbbell_v16.mp4'
    subprocess.run([ffmpeg, '-y', '-framerate', str(FPS), '-i', f'{fdir}/f%03d.png',
                    '-c:v', 'libx264', '-pix_fmt', 'yuv420p', '-crf', '20', out_mp4],
                   check=True, capture_output=True)
    print('mp4 →', out_mp4)
