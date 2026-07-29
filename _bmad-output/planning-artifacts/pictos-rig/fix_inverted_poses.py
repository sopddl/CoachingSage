"""
Fix ponctuel pour les poses INVERSÉES (chandelle, poirier) où
strip_shadow_ellipse() de generate_reliquat.py casse le contour : la
heuristique "plus gros composant = corps, tout ce qui est EN DESSOUS = ombre à
virer" est fausse ici car les jambes (en haut, dressées) sont le plus gros
composant, et la tête/tronc/tapis (en bas) sont pris pour une ombre parasite
et supprimés.

On ne touche PAS generate_reliquat.py (recette verrouillée). On réutilise
flood_remove_border (retrait cadre parasite, toujours valide) mais on SAUTE
strip_shadow_ellipse pour ces deux slugs, sur des réfs vectorielles propres
sans fond encombré (donc pas besoin d'anti-ombre).
"""
import pathlib
from PIL import Image, ImageFilter
import numpy as np

from generate_reliquat import flood_remove_border, OUT, FEMALE
from pilot_flux import replicate_run, b64


def make_control_no_shadow_strip(src, dest, threshold=30, blur=0.4, margin=180):
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
    out = Image.fromarray(mask).convert('RGB')
    side = max(out.size) + margin * 2
    sq = Image.new('RGB', (side, side), 'white')
    sq.paste(out, ((side - out.width) // 2, (side - out.height) // 2))
    sq.resize((1024, 1024)).save(dest)


def generate_inverted(slug, ref_image, pose_description, seed=777, guidance=22, steps=50, template=FEMALE):
    ctrl = OUT / f'{slug}_control.png'
    make_control_no_shadow_strip(ref_image, ctrl)
    dest = OUT / f'{slug}.png'
    ok = replicate_run('black-forest-labs/flux-canny-pro',
        {'prompt': template.format(pose=pose_description), 'control_image': b64(ctrl),
         'guidance': guidance, 'steps': steps, 'seed': seed, 'output_format': 'png',
         'safety_tolerance': 2}, dest)
    return ok


if __name__ == '__main__':
    import sys
    slug, ref, pose = sys.argv[1], sys.argv[2], sys.argv[3]
    print(slug, generate_inverted(slug, ref, pose))
