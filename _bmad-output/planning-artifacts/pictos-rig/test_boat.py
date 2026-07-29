import pathlib, sys
sys.path.insert(0, ".")
from pilot_flux import replicate_run, b64 as b64uri
from generate_reliquat import make_control, FEMALE

OUT = pathlib.Path("reliquat_final")
src = pathlib.Path(
    "/private/tmp/claude-501/-Users-sophieslama-CL3-CoachingSage/1ebc4de0-525f-4a83-a3e0-de235546a9ae/"
    "scratchpad/pictos_poc/boat_silhouette.png")
ctrl = OUT / "boat-synth_control.png"
make_control(src, ctrl)

pose_desc = ("boat pose (navasana), balancing on the sit bones, torso leaning back at an angle, "
             "both legs extended straight up and forward at the same angle as the torso leans back "
             "forming a V shape, arms reaching forward parallel to the legs, knees straight not bent")

dest = OUT / "boat-synth.png"
ok = replicate_run('black-forest-labs/flux-canny-pro',
    {'prompt': FEMALE.format(pose=pose_desc), 'control_image': b64uri(ctrl),
     'guidance': 22, 'steps': 50, 'seed': 777, 'output_format': 'png',
     'safety_tolerance': 2}, dest)
print("RESULT", ok, dest)
