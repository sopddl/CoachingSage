import pathlib, sys
sys.path.insert(0, ".")
from pilot_flux import replicate_run, b64 as b64uri
from generate_reliquat import make_control, FEMALE

OUT = pathlib.Path("reliquat_final")
src = pathlib.Path(
    "/private/tmp/claude-501/-Users-sophieslama-CL3-CoachingSage/1ebc4de0-525f-4a83-a3e0-de235546a9ae/"
    "scratchpad/pictos_poc/front_ref.png")  # meme silhouette debout de face que pour GYM
ctrl = OUT / "female-front-ref_control.png"
make_control(src, ctrl)

FRONT_FEMALE = FEMALE.replace('full body visible, side view',
                               'full body visible, standing straight facing directly toward the '
                               'camera, front view, arms relaxed by the sides')
FRONT_FEMALE = FRONT_FEMALE.replace('lying on a thin flat white rectangular exercise mat seen '
                                     'edge-on in profile, a slim horizontal white band right at '
                                     'ground level under her, '
                                     'NOT an oval, NOT an ellipse, NOT a shadow shape, NOT a wide '
                                     'platform — just a thin straight white strip like a real yoga mat, ',
                                     'standing on a thin flat white rectangular exercise mat, ')

pose_desc = "standing in a neutral relaxed position, weight even on both feet"

dest = OUT / "female-front-ref.png"
ok = replicate_run('black-forest-labs/flux-canny-pro',
    {'prompt': FRONT_FEMALE.format(pose=pose_desc), 'control_image': b64uri(ctrl),
     'guidance': 22, 'steps': 50, 'seed': 777, 'output_format': 'png',
     'safety_tolerance': 2}, dest)
print("RESULT", ok, dest)
