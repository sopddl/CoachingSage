import pathlib
import sys

import numpy as np
from PIL import Image, ImageFilter, ImageOps

sys.path.insert(0, '.')
from generate_reliquat import flood_remove_border, strip_shadow_ellipse, FEMALE_OPEN_KNEES
from pilot_flux import replicate_run, b64

SRC = 'refs/suptabaddha2.jpg'
SCRATCH = pathlib.Path('/private/tmp/claude-501/-Users-sophieslama-CL3-CoachingSage/'
                        '39275957-db35-4226-a0c3-85c95fdddb22/scratchpad')
OUT = pathlib.Path('reliquat_final')

# Pivot / crop determined by visual inspection of the raw Canny mask
# (supta2_mask_grid.png): the single clean leg silhouette runs from the
# hip attach point (~710,435) out to the knee apex (~1000,360) and down to
# the foot (~900-1000, 580-690). Crop starts exactly at hip_x so mirroring
# reflects cleanly around the hip column.
HIP_X = 710
Y0, Y1 = 340, 700
X1 = 1100


def build_mask(blur=0.4, threshold=30):
    im = Image.open(SRC).convert('L')
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
    return mask


def mirror_composite(mask):
    h, w = mask.shape
    mask_img = Image.fromarray(mask)
    leg_crop = mask_img.crop((HIP_X, Y0, X1, Y1))
    mirrored = ImageOps.mirror(leg_crop)
    canvas = Image.new('L', (w, h), 255)
    paste_x = HIP_X - (X1 - HIP_X)
    canvas.paste(mirrored, (paste_x, Y0))
    mirrored_arr = np.array(canvas)
    composite = np.minimum(mask, mirrored_arr)
    composite = flood_remove_border(composite)
    return composite


def square_and_save(mask, dest, margin=180):
    out = Image.fromarray(mask).convert('RGB')
    side = max(out.size) + margin * 2
    sq = Image.new('RGB', (side, side), 'white')
    sq.paste(out, ((side - out.width) // 2, (side - out.height) // 2))
    sq.resize((1024, 1024)).save(dest)


POSE_V2 = ("lying flat on her back in supta baddha konasana, reclined bound angle pose, "
           "her hips and back resting flat down on the mat, NOT lifted, NOT arched up, no props or blocks under her body, "
           "soles of the feet pressed together close to the pelvis, both knees bent and dropped down wide open to the sides "
           "like an open diamond shape, knees resting low near the mat, not pointing up toward the ceiling")

POSE_V3 = ("view from slightly above looking down at her body, bird's eye elevated view, "
           "lying flat on her back in supta baddha konasana reclined butterfly pose, "
           "her whole back and hips flat on the ground, "
           "her two knees fallen OUTWARD to the left and right sides like open butterfly wings, flat and low, "
           "resting near the mat, the knees are NOT bent upward, this is NOT a bridge pose, this is NOT a hip thrust, "
           "the knees do not point at the ceiling, "
           "the soles of both feet pressed together in front of her pelvis")


def main(seed=777, dry_run=False, blur=0.4, threshold=30, pose=None):
    mask = build_mask(blur=blur, threshold=threshold)
    composite = mirror_composite(mask)
    Image.fromarray(composite).save(SCRATCH / 'supta2_composite_raw.png')

    ctrl = OUT / 'suptaBaddhaKonasana_control.png'
    square_and_save(composite, ctrl, margin=180)
    print('control saved ->', ctrl)

    if dry_run:
        return True

    dest = OUT / 'suptaBaddhaKonasana.png'
    pose = pose or POSE_V2
    ok = replicate_run('black-forest-labs/flux-canny-pro',
        {'prompt': FEMALE_OPEN_KNEES.format(pose=pose), 'control_image': b64(ctrl),
         'guidance': 22, 'steps': 50, 'seed': seed, 'output_format': 'png',
         'safety_tolerance': 2}, dest)
    return ok


if __name__ == '__main__':
    dry = '--dry' in sys.argv
    seed = 777
    blur = 0.4
    threshold = 30
    for a in sys.argv[1:]:
        if a.startswith('--seed='):
            seed = int(a.split('=')[1])
        if a.startswith('--blur='):
            blur = float(a.split('=')[1])
        if a.startswith('--threshold='):
            threshold = int(a.split('=')[1])
    print('OK' if main(seed=seed, dry_run=dry, blur=blur, threshold=threshold) else 'FAIL')
