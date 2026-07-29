import pathlib, sys
sys.path.insert(0, ".")
from pilot_flux import replicate_run, b64 as b64uri
from generate_reliquat import make_control, GYM

OUT = pathlib.Path("reliquat_final")
src = pathlib.Path(
    "/private/tmp/claude-501/-Users-sophieslama-CL3-CoachingSage/1ebc4de0-525f-4a83-a3e0-de235546a9ae/"
    "scratchpad/pictos_poc/farmer_silhouette.png")
ctrl = OUT / "farmer-carry_control.png"
make_control(src, ctrl)

pose_desc = ("walking forward mid-stride carrying a heavy round weight in one hand, "
             "arm hanging straight down at the side holding the weight low near the hip, "
             "upright posture, front leg stepping forward, back leg trailing behind")

dest = OUT / "farmer-carry.png"
ok = replicate_run('black-forest-labs/flux-canny-pro',
    {'prompt': GYM.format(pose=pose_desc), 'control_image': b64uri(ctrl),
     'guidance': 22, 'steps': 50, 'seed': 777, 'output_format': 'png',
     'safety_tolerance': 2}, dest)
print("RESULT", ok, dest)
