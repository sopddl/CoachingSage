#!/usr/bin/env python3
"""Marionnette wall-sit v10 — calques alpha propres depuis M_wall-sit_pilote2.png.

Doctrine (leçon Frankenstein r10-r11) : on découpe UNE FOIS des calques ENTIERS
depuis l'image vierge, on assemble par composition (z-order explicite), zéro
retouche incrémentale.

Calques :
  plate  = fond pur (mur/poteau/tapis reconstruits, personne effacée)
  near   = jambe avant COMPLÈTE (bassin+cuisse+tibia+cheville+chaussure), statique
  far    = copie de near, offset +FAR_DX, assombrie (convention source), derrière
  torso  = tête+cheveux+torse+2 bras+2 poings, calque MOBILE (respiration)

Sorties debug : _seg_overlay.png, _sprite_near.png, _sprite_torso.png,
_base_compose.png (frame repos), _diff_src.png.
"""
import numpy as np
from PIL import Image, ImageFilter

SRC = 'ai-explo/vague4/M_wall-sit_pilote2.png'
OUT = 'puppet_v10'
FAR_DX = 26          # offset x de la jambe lointaine (validé visuellement vs puppet r9)
BREATH_AMP = 5       # px, translation torse (recette v7 validée)
N_FRAMES, FPS = 48, 12

im = np.array(Image.open(SRC).convert('RGB')).astype(np.int16)
H, W = im.shape[:2]

# ---------- couleurs de référence (mesurées par scanlines) ----------
WALL = np.array([168, 163, 170]); POLE = np.array([139, 128, 140])
NAVY_NEAR = np.array([66, 80, 102]); NAVY_FAR = np.array([50, 60, 82])
SKIN = np.array([200, 174, 157]); HAIR = np.array([64, 57, 70])
SHIRT = np.array([237, 234, 231])

def l1(color):
    return np.abs(im - color).sum(axis=2)

# ---------- fond : stamps exacts ----------
# poteau : span mesuré sur une ligne au-dessus de la tête
row130 = im[130]
pole_cols = np.where(np.abs(row130 - POLE).sum(axis=1) < 40)[0]
pole_x0, pole_x1 = pole_cols.min(), pole_cols.max()
print(f'pole span x: {pole_x0}-{pole_x1}')
pole_stamp = im[130, max(0, pole_x0-3):pole_x1+4].copy()   # inclut l'AA des bords

# ---------- masque personne : flood depuis les bords sur les couleurs fond ----------
mat_row_color = im[:, 950]                                  # stamp tapis/mur par ligne
bgdist = np.minimum(l1(WALL), l1(POLE))
bgdist = np.minimum(bgdist, np.abs(im - mat_row_color[:, None, :]).sum(axis=2))
bgish = bgdist < 34
from scipy import ndimage
outside = np.zeros((H, W), bool)
lbl, _ = ndimage.label(bgish)
border_labels = set(lbl[0]) | set(lbl[-1]) | set(lbl[:, 0]) | set(lbl[:, -1])
border_labels.discard(0)
for b in border_labels:
    outside |= (lbl == b)
person = ~outside
# ne garder que la bbox utile (perso + chaussures) : évite le tapis gauche etc.
keep = np.zeros((H, W), bool); keep[140:875, 320:840] = True
keep[846:, 320:545] = False                                 # bord avant du tapis (pas la personne)
keep[812:846, 320:556] = False                              # ligne du bord haut du tapis (idem)
person &= keep
person = ndimage.binary_closing(person, np.ones((3, 3)))
# garder TOUTES les composantes >200px (la chaussure arrière peut être coupée
# du corps par son col ≈ couleur mur) + boucher les trous internes
lblp, np_ = ndimage.label(person)
sizes = ndimage.sum(person, lblp, range(1, np_ + 1))
person = np.isin(lblp, [i + 1 for i, s in enumerate(sizes) if s > 200])
person = ndimage.binary_fill_holes(person)
print('person px:', person.sum())

# ---------- torse ----------
ys, xs = np.mgrid[0:H, 0:W]
skinish = l1(SKIN) < 45
hairish = (l1(HAIR) < 40) & (ys < 340)
shirtish = l1(SHIRT) < 55
torso = person & (skinish | hairish | shirtish) & (ys < 725)
torso = ndimage.binary_closing(torso, np.ones((5, 5)))
lblt, nt = ndimage.label(torso)
head_lbl = lblt[220, 400]                                   # seed dans la tête
torso = (lblt == head_lbl)
torso = ndimage.binary_dilation(torso, np.ones((3, 3))) & person
print('torso px:', torso.sum())

# ---------- jambes : split near / far ----------
legs = person & ~torso & (ys > 455)
d_near, d_far = l1(NAVY_NEAR), l1(NAVY_FAR)
# la couleur ne fait foi que HORS zone chaussures (le contour sombre de la
# chaussure avant est du même navy sombre que la jambe lointaine)
# GÉOMÉTRIE POSITIVE : la jambe avant est définie par une coupe par ligne au
# bord droit de son run navy clair contigu — tout le reste des jambes (ancienne
# jambe lointaine, ses AA, sa chaussure) est old_far PAR DÉFAUT. Plus robuste
# que classer l'ancienne jambe par couleur (son anneau AA échappait à tout).
lightnavy = legs & (d_near < 40)
# composante principale du pantalon avant (pont AA 2px), R(y) = son bord droit
ln = ndimage.binary_dilation(lightnavy, np.ones((5, 5))) & legs
lbl_ln, _ = ndimage.label(ln)
main_ln = (lbl_ln == lbl_ln[750, 600]) & lightnavy          # seed dans le tibia avant
R = np.full(H, 456)
for y in range(538, 790):
    cols = np.where(main_ln[y])[0]
    if len(cols):
        R[y] = cols.max()
# le bord droit du tibia avant est une droite à x≈630 (mesuré) ; le haut du
# tibia ARRIÈRE est localement plus clair dans le src (lumière) et gonflerait R
R[655:790] = np.minimum(R[655:790], 629)
# split chaussures : polyligne qui épouse l'orteil avant (pas de rabot vertical)
shoe_split = np.full(H, 698); shoe_split[825:845] = 702; shoe_split[845:] = 707
skinish_far = (l1(SKIN) < 60) & (xs > 640)
# dessus de la chaussure avant : au-dessus, entre x 629 et l'orteil, c'est
# l'ourlet de l'ancienne jambe lointaine → old_far
shoe_top = (813 + 0.22 * (xs - 629)).astype(int)
near = legs & ~skinish_far & (
    ((ys < 790) & (xs <= R[:, None] + 2))
    | ((ys >= 790) & (xs <= 628))
    | ((ys >= 790) & (xs <= shoe_split[:, None]) & (ys >= shoe_top))
)
old_far = legs & ~near
print('near px:', near.sum(), 'old_far px:', old_far.sum())

# ---------- plate = fond pur ----------
plate = im.copy()
erase = ndimage.binary_dilation(person, np.ones((5, 5)))
mat_row_near = im[:, 848]                                   # bord du tapis légèrement incliné :
# effacement par RÉGION : à droite de la silhouette de la jambe avant, le fond
# doit être PUR — tout pixel déviant (AA de l'ancienne jambe, fantôme de
# chaussure, tirets) est stampé fond, quelle que soit sa classification
near_right = np.full(H, 456)
for y in range(538, 880):
    cols = np.where(near[y])[0]                             # jambe avant SEULE (pas le torse :
    if len(cols):                                           # le t-shirt masquait la bande de taille)
        near_right[y] = cols.max()
region_hits = np.zeros((H, W), bool)
for y in range(538, 880):
    x0 = near_right[y] + 2
    for x in range(x0, 846):
        exp = mat_row_near[y] if y >= 790 else (pole_stamp[x - (pole_x0 - 3)] if pole_x0 - 3 <= x <= pole_x1 + 3 else mat_row_color[y])
        if np.abs(im[y, x] - exp).sum() > 6:
            region_hits[y, x] = True
# dilater les hits (les tirets AA ont des queues à déviation ~4-6)
region_hits = ndimage.binary_dilation(region_hits, np.ones((5, 5)))
for y in range(538, 880):
    region_hits[y, :near_right[y] + 2] = False
erase |= region_hits
ye, xe = np.where(erase)                                    # stamp proche des chaussures pour y>=790
for y, x in zip(ye, xe):
    if y >= 790:
        plate[y, x] = mat_row_near[y]
    elif pole_x0 - 3 <= x <= pole_x1 + 3:
        plate[y, x] = pole_stamp[x - (pole_x0 - 3)]
    else:
        plate[y, x] = mat_row_color[y]                      # mur : stamp ligne x=950
plate = plate.astype(np.uint8)

# ---------- sprite near (RGBA) + fills ----------
def to_sprite(mask):
    a = ndimage.binary_dilation(mask, np.ones((2, 2))).astype(np.float32)
    a = np.array(Image.fromarray((a * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(0.7))) / 255.0
    a[mask] = 1.0
    rgba = np.dstack([im.clip(0, 255).astype(np.uint8), (a * 255).astype(np.uint8)])
    return rgba

near_fill = near.copy()
# trou des poings : le bassin continue sous le poing/avant-bras, MAIS pas
# au-delà du dessous du fessier (le poing pend sous la ligne d'assise, mur
# derrière). Critère robuste : on ne remplit une ligne du poing que si le
# bassin (near) est bien présent juste à droite sur la MÊME ligne.
fist_hole = np.zeros((H, W), bool)
for y in range(552, 661):
    row_t = np.where(torso[y] & (xs[y] >= pole_x1 + 1) & (xs[y] <= 470))[0]
    if len(row_t) == 0:
        continue
    x_right = row_t.max()
    if near[y, x_right + 4:x_right + 90].sum() > 15:
        fist_hole[y, row_t] = True
near_fill |= fist_hole
# extension pantalon sous l'ourlet du t-shirt (12 px) pour la respiration
hem = np.zeros((H, W), bool)
for x in range(320, 840):
    col = np.where(near_fill[:, x])[0]
    if len(col) == 0:
        continue
    y0 = col.min()
    if 535 <= y0 <= 600 and torso[y0 - 2, x]:
        hem[max(0, y0 - 12):y0, x] = True
near_fill |= hem
near_sprite = to_sprite(near_fill)
# couleur des pixels remplis (trou poings + extension) = navy bassin
filled = (fist_hole | hem)
near_sprite[filled, 0:3] = NAVY_NEAR.astype(np.uint8)
# adoucir : re-blur alpha déjà fait ; les remplissages sont internes (cachés au repos)

# ---------- sprite far = near décalé + assombri ----------
# copie depuis la jambe SANS les remplissages internes (poings, extension) :
# ils sont destinés à la respiration derrière le torse, pas à la silhouette
far_src_sprite = to_sprite(near)
far_sprite = np.zeros_like(far_src_sprite)
far_sprite[:, FAR_DX:] = far_src_sprite[:, :W - FAR_DX]
far_sprite[:549, :, 3] = 0                                  # rien au-dessus de la taille
# purger la frange couleur-fond (dilatation de to_sprite) : recopiée décalée
# et assombrie, elle ferait des fantômes gris sur le mur
frgb = far_sprite[:, :, :3].astype(np.int16)
bg_fringe = (np.abs(frgb - WALL).sum(axis=2) < 26) | (np.abs(frgb - mat_row_color[:, None, :]).sum(axis=2) < 26)
bg_fringe &= (ys < 790)   # zone chaussures : languette ≈ couleur mur, et une
                          # frange couleur-tapis décalée en x y est invisible
far_sprite[bg_fringe, 3] = 0
rgbf = far_sprite[:, :, :3].astype(np.float32)
navy_px = (np.abs(rgbf - NAVY_NEAR).sum(axis=2) < 70) & (far_sprite[:, :, 3] > 0)
other_px = (far_sprite[:, :, 3] > 0) & ~navy_px
rgbf[navy_px] *= np.array([50 / 66, 60 / 80, 82 / 102])
rgbf[other_px] *= 0.93
far_sprite[:, :, :3] = rgbf.clip(0, 255).astype(np.uint8)
# zone chaussure/cheville arrière (y>=786) : SILHOUETTE simplifiée — recopier
# les micro-détails (col, peau, lacets) en tranches de 26px lit comme des
# fragments (verdict gate) ; une masse sombre + semelle blanche continue = la
# convention flat d'un pied en retrait
FAR_DARK = np.array([50, 60, 82], dtype=np.uint8)
shoe_zone = (ys >= 786) & (far_sprite[:, :, 3] > 0)
sole_white = shoe_zone & (np.abs(far_sprite[:, :, :3].astype(np.int16) - np.array([220, 220, 223])).sum(axis=2) < 90)
far_sprite[shoe_zone & ~sole_white, 0:3] = FAR_DARK
far_sprite[sole_white, 0:3] = np.array([228, 228, 230], dtype=np.uint8)
far_sprite[shoe_zone, 3] = 255                              # aucune semi-transparence : rien ne « flotte »
# ne PAS dépasser le contour supérieur de la chaussure arrière (= contour de
# la chaussure avant décalé de FAR_DX) : sinon poutre sombre sur le mur
far_shoe_top = 813 + 0.22 * (xs - FAR_DX - 629)
kill_above = (ys >= 786) & (xs >= 629 + FAR_DX) & (ys < far_shoe_top)
far_sprite[kill_above, 3] = 0
# fermer les micro-fentes horizontales (<=4px) le long de la couture des deux
# jambes — la purge de frange y laissait des tirets couleur mur
for y in range(630, 872):
    row_a = far_sprite[y, :, 3]
    on = np.where(row_a > 200)[0]
    if len(on) < 2:
        continue
    gaps = np.where(np.diff(on) > 1)[0]
    for g in gaps:
        x0, x1 = on[g], on[g + 1]
        if x1 - x0 <= 5:
            far_sprite[y, x0:x1, :3] = far_sprite[y, x0, :3]
            far_sprite[y, x0:x1, 3] = 255
# la hanche arrière est dessinée JUSQU'À l'ourlet du t-shirt (convention
# source) : le haut de la bande suit la droite mesurée sur le src —
# (469,555) → (610,600), soit y = 555 + 0.32·(x-469). On remplit le canal
# entre cette droite et le haut actuel de la copie ; le torse (ourlet, main)
# pasté APRÈS recouvre ce qui doit l'être.
FAR_DARK = np.array([50, 60, 82], dtype=np.uint8)
band_xs = np.array([455, 520, 560, 610, 645])
band_ys = np.array([547, 550, 562, 595, 607])               # contour mesuré sur le src
for x in range(455, 646):
    y_band = int(np.interp(x, band_xs, band_ys))
    a = far_sprite[540:680, x, 3]
    solid = np.where((a[:-5] > 200) & (a[1:-4] > 200) & (a[2:-3] > 200)
                     & (a[3:-2] > 200) & (a[4:-1] > 200))[0]
    if len(solid) == 0:
        continue
    y_solid = 540 + solid.min()                             # 1re ligne durablement opaque
    if y_solid > y_band:
        far_sprite[y_band:y_solid + 2, x, :3] = FAR_DARK
        far_sprite[y_band:y_solid + 2, x, 3] = 255

# ---------- sprite torse ----------
torso_sprite = to_sprite(torso)

# ---------- composition ----------
def compose(dy_torso=0):
    base = Image.fromarray(plate).convert('RGBA')
    for spr, off in [(far_sprite, (0, 0)), (near_sprite, (0, 0)), (torso_sprite, (0, dy_torso))]:
        layer = Image.fromarray(spr)
        tmp = Image.new('RGBA', base.size, (0, 0, 0, 0))
        tmp.paste(layer, off, layer)
        base = Image.alpha_composite(base, tmp)
    return base.convert('RGB')

base0 = compose(0)
base0.save(f'{OUT}/_base_compose.png')

# ---------- debug ----------
seg = im.copy().astype(np.uint8)
seg[old_far] = [220, 60, 60]; seg[near] = [60, 200, 90]; seg[torso] = [80, 120, 240]
Image.fromarray(seg).save(f'{OUT}/_seg_overlay.png')
Image.fromarray(near_sprite).save(f'{OUT}/_sprite_near.png')
Image.fromarray(far_sprite).save(f'{OUT}/_sprite_far.png')
Image.fromarray(torso_sprite).save(f'{OUT}/_sprite_torso.png')
Image.fromarray(plate).save(f'{OUT}/_plate.png')
diff = (np.abs(np.array(base0).astype(int) - im).sum(axis=2) > 30)
dbg = np.array(base0).copy(); dbg[diff] = [255, 0, 255]
Image.fromarray(dbg).save(f'{OUT}/_diff_src.png')
print('diff px vs src:', int(diff.sum()))

# ---------- animation respiration ----------
import os, subprocess, sys
if '--frames' in sys.argv:
    fdir = f'{OUT}/frames'
    os.makedirs(fdir, exist_ok=True)
    for k in range(N_FRAMES):
        dy = -round(BREATH_AMP * (1 - np.cos(2 * np.pi * k / N_FRAMES)) / 2)
        compose(int(dy)).save(f'{fdir}/f{k:03d}.png')
    out_mp4 = 'ai-explo/anim/anim_wall-sit_v10.mp4'
    import imageio_ffmpeg
    ffmpeg = imageio_ffmpeg.get_ffmpeg_exe()
    subprocess.run([ffmpeg, '-y', '-framerate', str(FPS), '-i', f'{fdir}/f%03d.png',
                    '-c:v', 'libx264', '-pix_fmt', 'yuv420p', '-crf', '20', out_mp4],
                   check=True, capture_output=True)
    print('mp4 →', out_mp4)
print('done — inspecter _seg_overlay / _base_compose / _diff_src')
