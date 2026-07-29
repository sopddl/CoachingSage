import pathlib
import sys

import numpy as np
from PIL import Image, ImageFilter

sys.path.insert(0, '.')
from generate_reliquat import flood_remove_border, GYM
from pilot_flux import replicate_run, b64

SCRATCH = pathlib.Path('/private/tmp/claude-501/-Users-sophieslama-CL3-CoachingSage/'
                        '39275957-db35-4226-a0c3-85c95fdddb22/scratchpad')
SRC_CROP = SCRATCH / 'jefit_crop.png'  # tight crop of jefit reverse-hyper GIF mid-frame
OUT = pathlib.Path('reliquat_final')

POSE = ("lying face down on a raised reverse hyperextension bench, hips at the edge of the bench, "
        "torso and chest supported flat on the bench, holding the handles of the bench with both hands, "
        "both legs together extending straight and lifting up behind him into hip extension, "
        "legs raised high behind him, side view")


def build_control(dest, blur=1.2, threshold=55, margin=180):
    im = Image.open(SRC_CROP).convert('L')
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


def main(seed=777, dry_run=False, blur=1.2, threshold=55, pose=None, guidance=22):
    ctrl = OUT / 'reverse-hyper_control.png'
    build_control(ctrl, blur=blur, threshold=threshold)
    print('control saved ->', ctrl)
    if dry_run:
        return True
    dest = OUT / 'reverse-hyper.png'
    ok = replicate_run('black-forest-labs/flux-canny-pro',
        {'prompt': GYM.format(pose=pose or POSE), 'control_image': b64(ctrl),
         'guidance': guidance, 'steps': 50, 'seed': seed, 'output_format': 'png',
         'safety_tolerance': 2}, dest)
    return ok


if __name__ == '__main__':
    dry = '--dry' in sys.argv
    seed = 777
    for a in sys.argv[1:]:
        if a.startswith('--seed='):
            seed = int(a.split('=')[1])
    print('OK' if main(seed=seed, dry_run=dry) else 'FAIL')
