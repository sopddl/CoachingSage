import pathlib
import sys
from collections import deque

import numpy as np
from PIL import Image, ImageFilter
from scipy import ndimage

from pilot_flux import replicate_run, b64

# RECETTE VERROUILLÉE — chantier "vrais personnages" (rebond 07-16, résolu 07-17).
# Génère un personnage pictos-rig cohérent avec la prod (staff-pose.png,
# warrior1.png) à partir d'une image de référence de pose (illustration
# vectorielle flat-design trouvée en ligne, PAS une photo — vérifier au cas
# par cas, cf feedback memory chantier_animations_etat_2026_07_17.md).
#
# Pipeline :
#  1. Contour Canny depuis la référence (structure uniquement, pas de
#     pixels/couleurs/style repris — légalement propre).
#  2. Nettoyage du contour : retrait du cadre parasite (flood-fill bords) +
#     retrait de toute ombre/ellipse de la référence source (composants
#     connexes) — SINON flux-canny-pro est obligé de respecter cette forme
#     comme structure quel que soit le prompt (cause racine du bug tapis
#     ovale/rectangle fantôme, round 9).
#  3. flux-canny-pro avec le prompt FEMALE verrouillé (couleur legging hex
#     exacte, trait fin uniforme, tapis = fine bande blanche plate).
#
# Usage : python3 generate_reliquat.py <slug> <chemin_reference.jpg> "<description pose anglaise>"

FEMALE = ('flat vector illustration of a woman practicing yoga, {pose}, '
          'wearing a fitted white sleeveless top fully covering her torso and muted teal-blue leggings color hex #87AAB2, '
          'barefoot, short brown hair in a low bun, minimalist flat design, clean simple shapes, '
          'thin uniform dark outline around shapes with consistent stroke weight throughout, not thick, not a coloring-book style, '
          'soft muted colors, plain warm light beige background filling the entire image with completely uniform flat color and no gradients, '
          'lying on a thin flat white rectangular exercise mat seen edge-on in profile, a slim horizontal white band right at ground level under her, '
          'NOT an oval, NOT an ellipse, NOT a shadow shape, NOT a wide platform — just a thin straight white strip like a real yoga mat, '
          'full body visible, side view')

# Variante FEMALE_OPEN_KNEES — PILOTE, pas verrouillée (07-18). Identique à
# FEMALE (même personnage : legging teal, top blanc, chignon, tapis fin) mais
# sans "side view" câblé en dur en fin de prompt — débloque les poses où le
# détail clé (ex. genoux ouverts en papillon) est invisible de profil.
# Cf mémoire : suptaBaddhaKonasana rendait systématiquement les genoux serrés
# et une vue de profil même avec une réf vue du dessus, à cause de ce "side
# view" imposé qui écrasait le cadrage de la réf.
FEMALE_OPEN_KNEES = ('flat vector illustration of a woman practicing yoga, {pose}, '
          'wearing a fitted white sleeveless top fully covering her torso and muted teal-blue leggings color hex #87AAB2, '
          'barefoot, short brown hair in a low bun, minimalist flat design, clean simple shapes, '
          'thin uniform dark outline around shapes with consistent stroke weight throughout, not thick, not a coloring-book style, '
          'soft muted colors, plain warm light beige background filling the entire image with completely uniform flat color and no gradients, '
          'lying on a thin flat white rectangular exercise mat, '
          'full body visible, camera angle and body orientation matching the reference image exactly, '
          'the two knees clearly spread far apart from each other, wide open, not touching, not stacked together')

# Variante GYM — PILOTE, pas encore verrouillée (07-17). Couleurs mesurées sur
# les illustrations muscu prod existantes (plank.png, deadlift-conventional.png,
# lunge-dumbbell.png) : perso HOMME distinct du perso yoga FEMALE, fond mauve-gris,
# plateforme foncée au lieu du tapis blanc fin.
GYM = ('flat vector illustration of a man doing a strength training exercise, {pose}, '
       'wearing a fitted white short-sleeve t-shirt fully covering his torso and dark navy-slate athletic pants color hex #3B495B, '
       'grey-blue athletic sneakers color hex #515C70, short dark brown hair, plain skin-colored face silhouette with no facial features, '
       'minimalist flat design, clean simple shapes, '
       'thin uniform dark outline around shapes with consistent stroke weight throughout, not thick, not a coloring-book style, '
       'soft muted colors, plain dusty mauve-grey background color hex #B3A8AE filling the entire image with completely uniform flat color and no gradients, '
       'standing on a thin flat dark slate-blue rectangular platform color hex #515C70 seen edge-on in profile, '
       'full body visible, side view')

OUT = pathlib.Path('reliquat_final')
OUT.mkdir(exist_ok=True)


def flood_remove_border(mask):
    h, w = mask.shape
    visited = np.zeros_like(mask, dtype=bool)
    black = mask < 128
    q = deque()
    for x in range(w):
        for y in (0, h - 1):
            if black[y, x] and not visited[y, x]:
                q.append((y, x)); visited[y, x] = True
    for y in range(h):
        for x in (0, w - 1):
            if black[y, x] and not visited[y, x]:
                q.append((y, x)); visited[y, x] = True
    while q:
        y, x = q.popleft()
        mask[y, x] = 255
        for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            ny, nx = y + dy, x + dx
            if 0 <= ny < h and 0 <= nx < w and black[ny, nx] and not visited[ny, nx]:
                visited[ny, nx] = True
                q.append((ny, nx))
    return mask


def strip_shadow_ellipse(mask):
    """Retire tout composant connexe situé sous le point le plus bas du corps
    (l'ombre/ellipse de la référence source), en gardant le plus gros
    composant (le corps) intact. Cf round 9 — bug tapis fantôme."""
    black = mask < 128
    labeled, n = ndimage.label(black, structure=np.ones((3, 3)))
    if n == 0:
        return mask
    sizes = ndimage.sum(black, labeled, range(1, n + 1))
    body_label = int(np.argmax(sizes)) + 1
    body_ys = np.where(labeled == body_label)[0]
    body_max_y = body_ys.max()
    keep = np.ones_like(black)
    for lbl in range(1, n + 1):
        if lbl == body_label:
            continue
        comp_ys = np.where(labeled == lbl)[0]
        if comp_ys.min() > body_max_y - 5:
            keep[labeled == lbl] = False
    out = black & keep
    return np.where(out, 0, 255).astype(np.uint8)


def make_control(src, dest, threshold=30, blur=0.4, margin=180):
    im = Image.open(src).convert('L')
    if max(im.size) > 1200:
        im.thumbnail((1200, 1200), Image.LANCZOS)
    w, h = im.size
    im = im.crop((15, 15, w - 15, h - 15))
    im = im.filter(ImageFilter.GaussianBlur(blur))
    edges = im.filter(ImageFilter.FIND_EDGES)
    arr = np.array(edges)
    mask = (arr > threshold).astype(np.uint8) * 255
    mask = 255 - mask
    mask = flood_remove_border(mask)
    mask = strip_shadow_ellipse(mask)
    out = Image.fromarray(mask).convert('RGB')
    side = max(out.size) + margin * 2
    sq = Image.new('RGB', (side, side), 'white')
    sq.paste(out, ((side - out.width) // 2, (side - out.height) // 2))
    sq.resize((1024, 1024)).save(dest)


def generate(slug, ref_image, pose_description, seed=777, guidance=22, steps=50, template=FEMALE):
    ctrl = OUT / f'{slug}_control.png'
    make_control(ref_image, ctrl)
    dest = OUT / f'{slug}.png'
    ok = replicate_run('black-forest-labs/flux-canny-pro',
        {'prompt': template.format(pose=pose_description), 'control_image': b64(ctrl),
         'guidance': guidance, 'steps': steps, 'seed': seed, 'output_format': 'png',
         'safety_tolerance': 2}, dest)
    return ok


if __name__ == '__main__':
    if len(sys.argv) != 4:
        print('Usage: python3 generate_reliquat.py <slug> <ref.jpg> "<pose description EN>"')
        sys.exit(1)
    slug, ref, pose = sys.argv[1], sys.argv[2], sys.argv[3]
    print(slug, generate(slug, ref, pose))
